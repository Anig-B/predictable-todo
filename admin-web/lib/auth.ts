import type { SupabaseClient } from "@supabase/supabase-js";

export type WebAppRole =
  | { kind: "admin" } // profiles.role = 'admin' — sees all missions
  | { kind: "manager"; missionIds: string[] } // scoped to managed missions
  | { kind: "forbidden" }; // regular member → 403

/**
 * Workflow spec §1 Auth:
 *  - profiles.role = 'admin'                          → full access
 *  - mission_members row with role = 'manager'        → scoped access
 *  - otherwise                                        → 403
 *
 * RLS allows a user to SELECT their own profile row and their own
 * mission_members rows, so both queries work with the anon key + session.
 */
export async function resolveWebAppRole(
  supabase: SupabaseClient,
  userId: string,
): Promise<WebAppRole> {
  // 1. System admin check
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", userId)
    .single();

  if (profileError) throw profileError;
  if (profile?.role === "admin") return { kind: "admin" };

  // 2. Manager check — only missions where the invite was accepted
  //    (joined_at IS NULL means the invite is still pending)
  const { data: memberships, error: memberError } = await supabase
    .from("mission_members")
    .select("mission_id")
    .eq("user_id", userId)
    .eq("role", "manager")
    .not("joined_at", "is", null);

  if (memberError) throw memberError;

  if (memberships && memberships.length > 0) {
    return {
      kind: "manager",
      missionIds: memberships.map((m) => m.mission_id as string),
    };
  }

  // 3. Regular member / no membership → not allowed in the web app
  return { kind: "forbidden" };
}
