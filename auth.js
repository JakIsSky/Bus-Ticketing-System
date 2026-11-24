(function (global) {
    'use strict';

    // Only used if supabase.js does not already expose a client.
    const FALLBACK_SUPABASE_URL = '';
    const FALLBACK_SUPABASE_ANON_KEY = '';

    const LOGIN_PAGE = 'login.html';
    const HOME_PAGE = 'index.html';
    const PROFILE_KEY = 'bts_profile';
    const ACTIVITY_KEY = 'bts_last_activity';
    const IDLE_LIMIT_MS = 30 * 60 * 1000; // auto sign-out after 30 min idle

    const ALL_PAGES = [
        'index.html', 'bus_management.html', 'route_management.html',
        'schedule_management.html', 'passenger_management.html', 'booking.html',
        'payment.html', 'ticket.html', 'user.html', 'report.html'
    ];

    // Lab 32 – pages each role may open
    const BOOKING_PAGES = ['index.html', 'passenger_management.html', 'schedule_management.html', 'booking.html'];
    const ROLE_PAGES = {
        'Admin': ['*'],
        'Transportation Manager': ['index.html', 'bus_management.html', 'route_management.html', 'schedule_management.html', 'report.html'],
        'Booking Staff': BOOKING_PAGES,
        'Staff': BOOKING_PAGES, // legacy role value
        'Cashier': ['index.html', 'payment.html', 'ticket.html'],
        'Dispatcher': ['index.html', 'bus_management.html', 'schedule_management.html'],
        'Management': ['index.html', 'report.html']
    };

    const ROLE_LABELS = {
        'Admin': 'Administrator',
        'Transportation Manager': 'Transportation Manager',
        'Booking Staff': 'Booking Staff',
        'Staff': 'Booking Staff',
        'Cashier': 'Cashier',
        'Dispatcher': 'Dispatcher',
        'Management': 'Management'
    };

    /* ------------------------------ client ------------------------------ */
    let clientInstance = null;

    function findExistingClient() {
        try { if (typeof supabaseClient !== 'undefined' && supabaseClient && supabaseClient.from) return supabaseClient; } catch (e) {}
        try { if (typeof sbClient !== 'undefined' && sbClient && sbClient.from) return sbClient; } catch (e) {}
        try { if (typeof _supabase !== 'undefined' && _supabase && _supabase.from) return _supabase; } catch (e) {}
        try { if (typeof db !== 'undefined' && db && db.from) return db; } catch (e) {}
        try { if (typeof sb !== 'undefined' && sb && sb.from) return sb; } catch (e) {}
        try { if (typeof supabase !== 'undefined' && supabase && supabase.from) return supabase; } catch (e) {}
        return null;
    }

    function client() {
        if (clientInstance) return clientInstance;
        clientInstance = findExistingClient();
        if (!clientInstance) {
            if (!FALLBACK_SUPABASE_URL || !FALLBACK_SUPABASE_ANON_KEY || !global.supabase || !global.supabase.createClient) {
                throw new Error('auth.js: no Supabase client found. Fill FALLBACK_SUPABASE_URL / FALLBACK_SUPABASE_ANON_KEY at the top of auth.js.');
            }
            clientInstance = global.supabase.createClient(FALLBACK_SUPABASE_URL, FALLBACK_SUPABASE_ANON_KEY);
        }
        return clientInstance;
    }

    /* ------------------------------ helpers ----------------------------- */
    function currentPage() {
        let file = decodeURIComponent(location.pathname.split('/').pop() || '');
        if (!file) return HOME_PAGE;
        if (!file.includes('.')) file += '.html'; // Vercel clean URLs
        return file.toLowerCase();
    }

    function canAccess(role, page) {
        const allowed = ROLE_PAGES[role];
        if (!allowed) return false;
        return allowed.includes('*') || allowed.includes(page);
    }

    function cacheProfile(p) { try { localStorage.setItem(PROFILE_KEY, JSON.stringify(p)); } catch (e) {} }
    function clearLocal() {
        try { localStorage.removeItem(PROFILE_KEY); localStorage.removeItem(ACTIVITY_KEY); } catch (e) {}
    }
    function readCachedProfile() {
        try { return JSON.parse(localStorage.getItem(PROFILE_KEY) || 'null'); } catch (e) { return null; }
    }
    function touchActivity() { try { localStorage.setItem(ACTIVITY_KEY, String(Date.now())); } catch (e) {} }
    function idleExpired() {
        try {
            const t = Number(localStorage.getItem(ACTIVITY_KEY) || 0);
            return t > 0 && Date.now() - t > IDLE_LIMIT_MS;
        } catch (e) { return false; }
    }

    function redirectToLogin(reason) {
        location.replace(LOGIN_PAGE + (reason ? '?reason=' + encodeURIComponent(reason) : ''));
    }

    // Fresh copy of the profile from the database (so deactivation takes effect)
    async function fetchProfile(userId) {
        const { data, error } = await client()
            .from('users')
            .select('user_id, username, full_name, role, status')
            .eq('user_id', userId)
            .maybeSingle();
        if (error) throw error;
        return data;
    }

    // Account activation / deactivation check. Returns an error message or null.
    function profileProblem(profile) {
        if (!profile) return 'Account not found.';
        if (profile.status === 'Pending') return 'Your account is waiting for administrator approval.';
        if (profile.status !== 'Active') return 'Your account is inactive. Please contact an administrator.';
        if (!ROLE_PAGES[profile.role]) return 'Your account has no valid role.';
        return null;
    }

    /* --------------------------- password rules ------------------------- */
    function passwordProblems(pw) {
        const problems = [];
        pw = pw || '';
        if (pw.length < 8) problems.push('at least 8 characters');
        if (!/[A-Z]/.test(pw)) problems.push('an uppercase letter');
        if (!/[a-z]/.test(pw)) problems.push('a lowercase letter');
        if (!/[0-9]/.test(pw)) problems.push('a number');
        return problems;
    }

    /* ------------------------------- login ------------------------------ */
    async function login(username, password) {
        username = (username || '').trim();
        if (!username || !password) {
            return { ok: false, message: 'Please enter your username and password.' };
        }
        try {
            const { data, error } = await client().rpc('mock_login', { p_username: username, p_password: password });
            if (error) throw error;
            const profile = Array.isArray(data) ? data[0] : data;
            if (!profile) return { ok: false, message: 'Invalid username or password.' };

            const problem = profileProblem(profile);
            if (problem) return { ok: false, message: problem };

            cacheProfile(profile);
            touchActivity();
            return { ok: true, profile: profile };
        } catch (err) {
            console.error('Login error:', err);
            return { ok: false, message: 'Unable to sign in right now. Did you run mock_auth.sql in Supabase?' };
        }
    }

    /* ------------------------------- sign up ---------------------------- */
    async function signup(form) {
        const username = (form.username || '').trim();
        const password = form.password || '';

        if (!/^[A-Za-z0-9_.]{3,30}$/.test(username)) {
            return { ok: false, message: 'Username must be 3–30 characters: letters, numbers, dot or underscore.' };
        }
        const problems = passwordProblems(password);
        if (problems.length) return { ok: false, message: 'Password needs ' + problems.join(', ') + '.' };
        if (password !== form.confirm) return { ok: false, message: 'Passwords do not match.' };
        if (!ROLE_PAGES[form.role] || form.role === 'Staff') return { ok: false, message: 'Please choose a role.' };

        try {
            const { data, error } = await client().rpc('mock_signup', {
                p_username: username,
                p_full_name: (form.fullName || '').trim(),
                p_password: password,
                p_role: form.role
            });
            if (error) throw error;
            if (data !== 'OK') return { ok: false, message: data };
            return { ok: true, pending: true, message: 'Account created. An administrator must approve it before you can sign in.' };
        } catch (err) {
            console.error('Signup error:', err);
            return { ok: false, message: 'Unable to create the account right now. Did you run mock_auth.sql in Supabase?' };
        }
    }

    /* ------------------------------- logout ----------------------------- */
    function logout(reason) {
        clearLocal();
        redirectToLogin(reason || 'loggedout');
    }

    /* ----------------------------- session check ------------------------ */
    async function hasActiveSession() {
        const cached = readCachedProfile();
        if (!cached || idleExpired()) return false;
        try {
            return !profileProblem(await fetchProfile(cached.user_id));
        } catch (e) {
            return false;
        }
    }

    function getSession() { return readCachedProfile(); }

    /* ------------------------------ page guard -------------------------- */
    let guardPromise = null;

    function domReady() {
        return new Promise(function (resolve) {
            if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', resolve);
            else resolve();
        });
    }

    function reveal() { document.documentElement.style.visibility = ''; }

    function showDenied() {
        document.body.innerHTML =
            '<div style="font-family:system-ui,sans-serif;max-width:420px;margin:15vh auto;text-align:center;padding:24px">' +
            '<div style="font-size:48px">🔒</div>' +
            '<h2 style="margin:12px 0 6px">Access denied</h2>' +
            '<p style="color:#64748b">Your role is not allowed to open this page. Taking you back to the dashboard…</p></div>';
        reveal();
    }

    function requireAuth() {
        if (!guardPromise) guardPromise = runGuard();
        return guardPromise;
    }

    async function runGuard() {
        const page = currentPage();
        const cached = readCachedProfile();

        if (!cached) { redirectToLogin(); return null; }
        if (idleExpired()) { logout('timeout'); return null; }

        let profile = null;
        try { profile = await fetchProfile(cached.user_id); } catch (e) { console.error(e); }

        const problem = profileProblem(profile);
        if (problem) {
            clearLocal();
            redirectToLogin(profile && profile.status === 'Pending' ? 'pending' : (profile && profile.status !== 'Active' ? 'inactive' : 'denied'));
            return null;
        }

        cacheProfile(profile);
        await domReady();

        if (!canAccess(profile.role, page)) {
            showDenied();
            setTimeout(function () { location.replace(HOME_PAGE); }, 1800);
            return null;
        }

        touchActivity();
        startIdleWatch();
        applyUi(profile);
        reveal();
        return { user: profile, profile: profile };
    }

    function startIdleWatch() {
        let last = 0;
        ['click', 'keydown', 'mousemove', 'touchstart', 'scroll'].forEach(function (ev) {
            document.addEventListener(ev, function () {
                const now = Date.now();
                if (now - last > 15000) { last = now; touchActivity(); }
            }, { passive: true });
        });
        setInterval(function () { if (idleExpired()) logout('timeout'); }, 30000);

        // Logged out in another tab -> leave this one too
        window.addEventListener('storage', function (e) {
            if (e.key === PROFILE_KEY && !e.newValue) redirectToLogin('loggedout');
        });
    }

    /* --------------------------------- UI ------------------------------- */
    function applyUi(profile) {
        const role = profile.role;

        document.querySelectorAll('a[href]').forEach(function (a) {
            const href = a.getAttribute('href') || '';
            if (!href || /^(https?:|#|mailto:|tel:|javascript:)/i.test(href)) return;
            const file = href.split(/[?#]/)[0].split('/').pop().toLowerCase();
            if (ALL_PAGES.includes(file) && !canAccess(role, file)) a.style.display = 'none';
        });

        // Optional: <button data-roles="Admin,Cashier"> is hidden for other roles
        document.querySelectorAll('[data-roles]').forEach(function (el) {
            const roles = el.getAttribute('data-roles').split(',').map(function (r) { return r.trim(); });
            if (!roles.includes(role)) el.style.display = 'none';
        });

        injectUserBox(profile);
    }

    function injectUserBox(profile) {
        if (document.getElementById('btsUserBox')) return;

        const style = document.createElement('style');
        style.textContent =
            '.bts-userbox{margin-top:auto;padding:14px 16px;border-top:1px solid rgba(127,127,127,.35);font-size:.85rem}' +
            '.bts-userbox.bts-floating{position:fixed;right:16px;bottom:16px;background:#fff;color:#0f172a;border:1px solid #e2e8f0;border-radius:10px;box-shadow:0 4px 16px rgba(0,0,0,.12);z-index:9999}' +
            '.bts-name{font-weight:600;word-break:break-word}' +
            '.bts-role{display:inline-block;margin:4px 0 10px;padding:2px 8px;border-radius:999px;background:rgba(127,127,127,.22);font-size:.75rem}' +
            '.bts-logout{display:block;width:100%;padding:8px;border:0;border-radius:6px;background:#ef4444;color:#fff;font-weight:600;cursor:pointer}' +
            '.bts-logout:hover{background:#dc2626}';
        document.head.appendChild(style);

        const box = document.createElement('div');
        box.id = 'btsUserBox';
        box.className = 'bts-userbox';

        const name = document.createElement('div');
        name.className = 'bts-name';
        name.textContent = profile.full_name || profile.username;

        const role = document.createElement('div');
        role.className = 'bts-role';
        role.textContent = ROLE_LABELS[profile.role] || profile.role;

        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'bts-logout';
        btn.textContent = 'Logout';
        btn.addEventListener('click', function () { logout('loggedout'); });

        box.appendChild(name);
        box.appendChild(role);
        box.appendChild(btn);

        const sidebar = document.querySelector('.sidebar');
        if (sidebar) sidebar.appendChild(box);
        else { box.classList.add('bts-floating'); document.body.appendChild(box); }
    }

    /* -------------------------------- export ---------------------------- */
    global.Auth = {
        login: login,
        signup: signup,
        logout: logout,
        requireAuth: requireAuth,
        hasActiveSession: hasActiveSession,
        getSession: getSession,
        passwordProblems: passwordProblems,
        canAccess: function (page) {
            const p = readCachedProfile();
            return !!p && canAccess(p.role, String(page).toLowerCase());
        },
        getRole: function () { const p = readCachedProfile(); return p ? p.role : null; },
        ROLE_LABELS: ROLE_LABELS,
        client: client
    };

    // Auto-protect every page except the login page
    if (currentPage() !== LOGIN_PAGE) {
        document.documentElement.style.visibility = 'hidden';
        requireAuth();
    }
})(window);