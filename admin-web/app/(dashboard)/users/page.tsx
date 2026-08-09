"use client";

import { useState, useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthCheck } from "@/hooks/useAuthCheck";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { InviteMemberDialog } from "@/components/invite-member-dialog";
import { toast } from "sonner";
import { Trash2 } from "lucide-react";

interface TeamMember {
  id: string;
  missionId: string;
  userId: string | null;
  username: string;
  role: "member" | "manager";
  joinedAt: string;
  level: number;
  streak: number;
  weeklyXp: number;
  status: "active" | "pending";
}

interface AvailableUser {
  id: string;
  username: string;
}

export default function UsersPage() {
  const { role, loading: authLoading } = useAuthCheck();
  const router = useRouter();
  const supabase = createClient();

  const [members, setMembers] = useState<TeamMember[]>([]);
  const [availableUsers, setAvailableUsers] = useState<AvailableUser[]>([]);
  const [selectedMember, setSelectedMember] = useState<TeamMember | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [showInviteDialog, setShowInviteDialog] = useState(false);
  const [loading, setLoading] = useState(true);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);

  useEffect(() => {
    if (authLoading) return;
    fetchCurrentUser();
  }, [role, authLoading]);

  const fetchCurrentUser = async () => {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      const userId = user?.id || null;
      setCurrentUserId(userId);

      // Always query fresh missions managed by this user to keep state consistent across devices
      let missionIds: string[] = [];
      if (userId) {
        const { data: managedMissions } = await supabase
          .from("mission_members")
          .select("mission_id")
          .eq("user_id", userId)
          .eq("role", "manager");

        if (managedMissions && managedMissions.length > 0) {
          missionIds = managedMissions.map((m) => m.mission_id);
          sessionStorage.setItem("userMissionIds", JSON.stringify(missionIds));
        }
      }

      await Promise.all([fetchTeamMembers(missionIds), fetchAvailableUsers()]);
    } catch (err) {
      console.error("Error initializing context:", err);
    } finally {
      setLoading(false);
    }
  };

  const fetchTeamMembers = async (missionIds: string[]) => {
    if (!missionIds || missionIds.length === 0) {
      setMembers([]);
      return;
    }

    try {
      setLoading(true);

      const { data: missionMembers, error } = await supabase
        .from("mission_members")
        .select(
          `
          mission_id,
          user_id,
          role,
          joined_at,
          user:profiles!user_id(username, level, streak, role)  
        `,
        )
        .in("mission_id", missionIds);

      if (error) throw error;

      const rawMembers = await Promise.all(
        (missionMembers || [])
          .filter((member: any) => member.user?.role !== "admin")
          .map(async (member: any) => {
            let weeklyXp = 0;

            if (member.user_id) {
              const { data: stats } = await supabase
                .from("user_stats")
                .select("weekly_xp")
                .eq("user_id", member.user_id)
                .single();
              if (stats) weeklyXp = stats.weekly_xp;
            }

            const isActive = !!member.joined_at;

            return {
              id: `${member.mission_id}-${member.user_id ?? "pending"}`,
              missionId: member.mission_id,
              userId: member.user_id,
              username: member.user?.username || "Pending Registration",
              role: member.role as "member" | "manager",
              joinedAt: isActive
                ? new Date(member.joined_at).toLocaleDateString()
                : "Awaiting App Sync",
              level: member.user?.level || 1,
              streak: member.user?.streak || 0,
              weeklyXp: weeklyXp,
              status: isActive ? ("active" as const) : ("pending" as const),
            };
          }),
      );

      // Deduplicate members by userId (or username for pending invites)
      const memberMap = new Map<string, TeamMember>();

      for (const m of rawMembers) {
        const key = m.userId || m.username;
        const existing = memberMap.get(key);

        if (!existing) {
          memberMap.set(key, m);
        } else {
          // Keep 'manager' role if the user holds a manager role in any assigned mission
          const highestRole =
            existing.role === "manager" || m.role === "manager"
              ? "manager"
              : "member";

          // Keep active status if active in any mission
          const bestStatus =
            existing.status === "active" || m.status === "active"
              ? "active"
              : "pending";

          memberMap.set(key, {
            ...existing,
            role: highestRole,
            status: bestStatus,
          });
        }
      }

      setMembers(Array.from(memberMap.values()));
    } catch (err) {
      console.error("Error fetching team members:", err);
      toast.error("Failed to sync team membership rosters");
    } finally {
      setLoading(false);
    }
  };

  const fetchAvailableUsers = async () => {
    try {
      const { data: users, error } = await supabase
        .from("profiles")
        .select("id, username")
        .neq("role", "admin")
        .order("username", { ascending: true });

      if (error) throw error;
      setAvailableUsers(users || []);
    } catch (err) {
      console.error("Error fetching available baseline users:", err);
    }
  };

  const handleInvite = async (data: { userId?: string; email?: string }) => {
    try {
      let missionIds = JSON.parse(
        sessionStorage.getItem("userMissionIds") || "[]",
      );

      if (!missionIds.length && currentUserId) {
        const { data: fallbackMissions } = await supabase
          .from("mission_members")
          .select("mission_id")
          .eq("user_id", currentUserId)
          .eq("role", "manager");

        if (fallbackMissions && fallbackMissions.length > 0) {
          missionIds = fallbackMissions.map((m) => m.mission_id);
          sessionStorage.setItem("userMissionIds", JSON.stringify(missionIds));
        }
      }

      if (!missionIds.length) {
        toast.error(
          "Missing valid management scope. Make sure your profile owns a mission.",
        );
        return;
      }

      if (data.userId) {
        const existingMember = members.find((m) => m.userId === data.userId);
        if (existingMember) {
          toast.error(
            "User already holds a position or pending invite within this mission scope.",
          );
          return;
        }

        const { error: memberError } = await supabase
          .from("mission_members")
          .insert({
            mission_id: missionIds[0],
            user_id: data.userId,
            role: "member",
            invited_by: currentUserId,
            joined_at: null,
          });

        if (memberError) throw memberError;
        toast.success("Invitation dispatched to user dashboard!");
      }

      setShowInviteDialog(false);
      fetchTeamMembers(missionIds);
    } catch (err: any) {
      console.error("Error executing invitation mutation:", err);
      toast.error(
        err?.message
          ? `Invite failed: ${err.message}`
          : "Failed to execute membership invitation",
      );
    }
  };

  const handleRoleChange = async (
    missionId: string,
    userId: string | null,
    newRole: "member" | "manager",
  ) => {
    if (!userId) return;
    try {
      let missionIds = JSON.parse(
        sessionStorage.getItem("userMissionIds") || "[]",
      );

      // Update the user's role across all managed missions
      const { error } = await supabase
        .from("mission_members")
        .update({ role: newRole })
        .in("mission_id", missionIds.length > 0 ? missionIds : [missionId])
        .eq("user_id", userId);

      if (error) throw error;

      setMembers((prev) =>
        prev.map((m) => (m.userId === userId ? { ...m, role: newRole } : m)),
      );

      toast.success(`Role updated successfully to ${newRole}`);
    } catch (err) {
      console.error("Error updating role relationship context:", err);
      toast.error("Could not alter authorization properties");
    }
  };

  const handleDeleteMember = async (
    missionId: string,
    userId: string | null,
    username: string,
  ) => {
    if (!userId) return;

    const confirmDelete = window.confirm(
      `Are you sure you want to remove ${username} from your team? This action will revoke their access across your managed missions.`,
    );
    if (!confirmDelete) return;

    try {
      let missionIds = JSON.parse(
        sessionStorage.getItem("userMissionIds") || "[]",
      );

      const { error } = await supabase
        .from("mission_members")
        .delete()
        .in("mission_id", missionIds.length > 0 ? missionIds : [missionId])
        .eq("user_id", userId);

      if (error) throw error;

      setMembers((prev) => prev.filter((m) => m.userId !== userId));
      toast.success(`${username} removed from team roster.`);
    } catch (err) {
      console.error("Error offboarding team member:", err);
      toast.error("Failed to delete team member. Check your RLS policies.");
    }
  };

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  const filteredMembers = members.filter((member) =>
    member.username.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  if (authLoading || loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="space-y-3">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-16 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-semibold text-[#1a1a1a]">
            Team Members
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Manage your team, send invitations, and delegate roles.
          </p>
        </div>
        <Button
          onClick={() => setShowInviteDialog(true)}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333]"
        >
          Invite Member
        </Button>
      </div>

      <div className="mb-6">
        <Input
          placeholder="Search members by name..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-md bg-[#fafaf8] border-[#e8e3db]"
        />
      </div>

      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-[#e8e3db] bg-[#f5f3f0]">
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Member
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Level
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Streak
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Weekly XP
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Role
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Joined
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Status
              </th>
              <th className="px-6 py-4 text-center text-sm font-medium text-[#6b6b6b] w-20">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {filteredMembers.length === 0 ? (
              <tr>
                <td
                  colSpan={8}
                  className="px-6 py-4 text-center text-[#8b8b8b]"
                >
                  No team members found
                </td>
              </tr>
            ) : (
              filteredMembers.map((member) => (
                <tr
                  key={member.userId || member.username}
                  onClick={() => setSelectedMember(member)}
                  className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] cursor-pointer transition-colors last:border-0"
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 font-bold text-xs flex items-center justify-center">
                        {getInitials(member.username)}
                      </div>
                      <span className="text-sm font-medium text-[#1a1a1a]">
                        {member.username}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-700">
                    Lvl {member.level}
                  </td>
                  <td className="px-6 py-4">
                    <span className="inline-block px-2 py-0.5 rounded text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                      {member.streak} days 🔥
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm font-bold text-indigo-600">
                    {member.weeklyXp} XP
                  </td>
                  <td className="px-6 py-4">
                    <select
                      value={member.role}
                      disabled={
                        !member.userId || member.userId === currentUserId
                      }
                      onChange={(e) =>
                        handleRoleChange(
                          member.missionId,
                          member.userId,
                          e.target.value as "member" | "manager",
                        )
                      }
                      onClick={(e) => e.stopPropagation()}
                      className="px-2 py-1 text-sm rounded border border-[#e8e3db] bg-white text-[#1a1a1a] disabled:opacity-50"
                    >
                      <option value="member">Member</option>
                      <option value="manager">Manager</option>
                    </select>
                  </td>
                  <td className="px-6 py-4 text-sm text-[#6b6b6b]">
                    {member.joinedAt}
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-block px-2 py-0.5 rounded text-xs font-semibold ${
                        member.status === "active"
                          ? "bg-green-50 text-green-700 border border-green-200"
                          : "bg-yellow-50 text-yellow-700 border border-yellow-200"
                      }`}
                    >
                      {member.status === "active" ? "Active" : "Pending"}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <button
                      type="button"
                      disabled={member.userId === currentUserId}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleDeleteMember(
                          member.missionId,
                          member.userId,
                          member.username,
                        );
                      }}
                      className="p-1.5 text-gray-400 hover:text-red-600 disabled:opacity-30 disabled:hover:text-gray-400 rounded transition-colors"
                      title={
                        member.userId === currentUserId
                          ? "You cannot remove yourself"
                          : "Remove Member"
                      }
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {showInviteDialog && (
        <InviteMemberDialog
          availableUsers={availableUsers}
          onClose={() => setShowInviteDialog(false)}
          onSubmit={handleInvite}
        />
      )}
    </div>
  );
}