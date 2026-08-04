import type { SupabaseClient } from "@supabase/supabase-js";

export type WebAppRole =
  | { kind: "admin" } // profiles.role = 'admin' — sees all missions
  | { kind: "manager"; missionIds: string[] } // scoped to managed missions
  | { kind: "forbidden" }; // regular member → 403

export async function resolveWebAppRole(
  supabase: SupabaseClient,
  userId: string,
): Promise<WebAppRole> {
  // 1. Profile role check
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", userId)
    .single();

  if (profileError) throw profileError;

  // System admin check
  if (profile?.role === "admin") return { kind: "admin" };

  // 2. Fetch manager's assigned missions
  const { data: memberships, error: memberError } = await supabase
    .from("mission_members")
    .select("mission_id")
    .eq("user_id", userId)
    .not("joined_at", "is", null);

  if (memberError) throw memberError;

  const missionIds = memberships ? memberships.map((m) => m.mission_id as string) : [];

  // 3. If profiles.role is 'manager', grant access regardless of mission count
  if (profile?.role === "manager") {
    return {
      kind: "manager",
      missionIds: missionIds, // returns [] if 0 missions exist, but DOES NOT FORBID LOG IN
    };
  }

  // 4. Fallback: Check if they are assigned as 'manager' in mission_members table
  // (In case role in profiles table is still 'user')
  const { data: roleMemberships } = await supabase
    .from("mission_members")
    .select("mission_id")
    .eq("user_id", userId)
    .eq("role", "manager")
    .not("joined_at", "is", null);

  if (roleMemberships && roleMemberships.length > 0) {
    return {
      kind: "manager",
      missionIds: roleMemberships.map((m) => m.mission_id as string),
    };
  }

  // 5. Regular member / no membership → not allowed in the web app
  return { kind: "forbidden" };
}