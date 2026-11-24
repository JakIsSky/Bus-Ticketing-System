# 🚌 Bus Ticketing System

A web-based system for managing buses, routes, schedules, passengers, bookings, payments and tickets, with a dashboard, reports and role-based access control.

**Workflow:** Bus → Route → Schedule → Passenger → Booking → Payment → Ticket → Reports

## Tech Stack

| Layer | Technology |
|---|---|
| Front end | HTML, CSS, JavaScript |
| Database | Supabase (PostgreSQL) |
| Charts | Chart.js (dashboard) |
| Hosting | Vercel |

## Modules

| Page | Purpose |
|---|---|
| `login.html` | Sign in / create a test account |
| `index.html` | Dashboard: bus, route, schedule, booking and revenue statistics with charts |
| `bus_management.html` | Register, search, edit and change status of buses |
| `route_management.html` | Register, search and edit routes and fares |
| `schedule_management.html` | Create and view schedules |
| `passenger_management.html` | Passenger records |
| `booking.html` | Bookings and seat selection |
| `payment.html` | Payment processing |
| `ticket.html` | Ticket generation and lookup |
| `user.html` | User accounts |
| `report.html` | Reports |

## Project Structure

```
/
├── index.html
├── login.html
├── bus_management.html
├── route_management.html
├── schedule_management.html
├── passenger_management.html
├── booking.html
├── payment.html
├── ticket.html
├── user.html
├── report.html
├── style.css            # login page + shared styles
├── style_2.css          # dashboard styles
├── supabase.js          # Supabase client / connection
├── supabase-db.js       # DB helper (DB.getAll, etc.)
├── auth.js              # login, logout, sessions, role-based access
└── mock_auth.sql        # database setup for login + test accounts
```

## Database

Tables: `buses`, `routes`, `schedules`, `passengers`, `bookings`, `payments`, `tickets`, `users`.

```
buses ──< schedules >── routes
passengers ──< bookings >── schedules
bookings ──1:1── payments
bookings ──1:1── tickets
```

The `users` table holds the login accounts (`username`, `password`, `role`, `status`, plus `full_name`, `created_at`, `last_login`).

## Setup

1. **Create the database** in Supabase and run your table script (buses, routes, schedules, passengers, bookings, payments, tickets, users).
2. **Add your Supabase URL and anon key** in `supabase.js`.
3. **Run `mock_auth.sql`** in the Supabase SQL Editor. It adds the login functions, the six roles and the test accounts.
4. **Deploy to Vercel** (import the project or drag the folder in). No build step is needed.
5. Open your Vercel link. You will be sent to the login page first.

Every page must include these scripts in the `<head>`, in this order:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="supabase.js"></script>
<script src="supabase-db.js"></script>
<script src="auth.js"></script>
```

## Authentication

- Username and password login (no email). Accounts live in the `users` table.
- Pages redirect to `login.html` when no one is signed in.
- Accounts with status `Inactive` cannot sign in.
- Password rules for new accounts: at least 8 characters, with an uppercase letter, a lowercase letter and a number.
- Automatic sign-out after 30 minutes of inactivity.
- A **Logout** button, with the user's name and role, is added to the sidebar of every page by `auth.js`.

### Test accounts

| Username | Password | Role |
|---|---|---|
| `admin` | `Admin@123` | Administrator |
| `manager` | `Manager@123` | Transportation Manager |
| `booking` | `Booking@123` | Booking Staff |
| `cashier` | `Cashier@123` | Cashier |
| `dispatcher` | `Dispatcher@123` | Dispatcher |
| `management` | `Management@123` | Management |
| `inactive_test` | `Inactive@123` | Inactive (login is blocked) |

## Role-Based Access Control

| Role | Pages |
|---|---|
| Administrator (`Admin`) | All pages |
| Transportation Manager | Dashboard, buses, routes, schedules, reports |
| Booking Staff | Dashboard, passengers, schedules, bookings |
| Cashier | Dashboard, payments, tickets |
| Dispatcher | Dashboard, buses, schedules |
| Management | Dashboard, reports |

Links to pages a role cannot use are hidden. Opening one directly shows "Access denied" and returns to the dashboard. To change who can open what, edit `ROLE_PAGES` at the top of `auth.js`.

## Security Notice

The current login is a **mock-up for testing**:

- Passwords are stored as plain text in `users.password`.
- The signed-in profile is kept in the browser, and row-level security is turned off on all tables.
- Anyone with the site's anon key can read or change the data directly.

Do not use it with real data. For production, switch to Supabase Auth with hashed passwords and enable row-level security.

## Known Schema Notes

- The `schedules.schedule_status` check contains `'Òngoing'` (accented Ò). Inserting `'Ongoing'` fails until the constraint is corrected.
- The dashboard counts buses with status `Available`, `Assigned` and `In Transit`, but the `buses.status` check only allows `Active`, `Maintenance` and `Inactive`. Align the two so those statuses can be saved.

## License

© 2026 Bus Ticketing System. All rights reserved.
