import { createBrowserClient } from "@supabase/ssr";

// Browser client — use inside "use client" components (e.g. the login page).
// Uses the same Supabase instance as the Flutter app.
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );
}
