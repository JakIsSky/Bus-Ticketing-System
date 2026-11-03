const DB = {
    async getAll(tableName) {
        try {
            const { data, error } = await supabaseClient.from(tableName).select('*');
            if (error) {
                console.error(`Error fetching ${tableName}:`, error.message);
                return [];
            }
            return data || [];
        } catch (err) {
            console.error(`Unexpected error fetching ${tableName}:`, err);
            return [];
        }
    },

    async insert(tableName, record) {
        try {
            const { data, error } = await supabaseClient
                .from(tableName)
                .insert([record])
                .select();

            if (error) {
                console.error(`Insert Error on ${tableName}:`, error);
                alert(`Supabase Error: ${error.message}`);
                return null;
            }
            return data ? data[0] : null;
        } catch (err) {
            console.error(`Unexpected error inserting into ${tableName}:`, err);
            alert(`Unexpected Error: ${err.message}`);
            return null;
        }
    },

    async create(tableName, record) {
        return await this.insert(tableName, record);
    },

    async update(tableName, idColumn, idValue, updates) {
        try {
            const { data, error } = await supabaseClient
                .from(tableName)
                .update(updates)
                .eq(idColumn, idValue)
                .select();

            if (error) {
                console.error(`Update Error on ${tableName}:`, error);
                alert(`Supabase Error: ${error.message}`);
                return null;
            }
            return data ? data[0] : null;
        } catch (err) {
            console.error(`Unexpected error updating ${tableName}:`, err);
            alert(`Unexpected Error: ${err.message}`);
            return null;
        }
    },

    async delete(tableName, idColumn, idValue) {
        try {
            const { error } = await supabaseClient
                .from(tableName)
                .delete()
                .eq(idColumn, idValue);

            if (error) {
                console.error(`Delete Error on ${tableName}:`, error);
                alert(`Supabase Error: ${error.message}`);
                return false;
            }
            return true;
        } catch (err) {
            console.error(`Unexpected error deleting from ${tableName}:`, err);
            alert(`Unexpected Error: ${err.message}`);
            return false;
        }
    }
};