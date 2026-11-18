// Use only the public anon (or publishable) key here. NEVER use service_role.
const supabaseUrl = 'https://tplidcszxawmtgzswogg.supabase.co';
const supabaseAnonKey = 'sb_publishable_VlsNt45YaDMAL7kUurS_Wg_DtWPAT_d';
bool get isSupabaseConfigured =>
    supabaseUrl.startsWith('https://') &&
    !supabaseAnonKey.startsWith('YOUR_') &&
    supabaseAnonKey.isNotEmpty;
