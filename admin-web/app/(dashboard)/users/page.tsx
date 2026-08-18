"use client";

import { useState, useEffect, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthCheck } from "@/hooks/useAuthCheck";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { InviteMemberDialog } from "@/components/invite-member-dialog";
import { toast } from "sonner";
import { Trash2 } from "lucide-react";

interface TeamMember {
  id: string;
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
  const supabase = createClient();

  const [members, setMembers] = useState<TeamMember[]>([]);
  const [availableUsers, setAvailableUsers] = useState<AvailableUser[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [showInviteDialog, setShowInviteDialog] = useState(false);
  const [loading, setLoading] = useState(true);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);
  const [primaryMissionId, setPrimaryMissionId] = useState<string | null>(null);

  const fetchTeamMembers = useCallback(
    async (userId: string) => {
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
          .eq("invited_by", userId);

        if (error) throw error;

        const memberMap = new Map<string, TeamMember>();

        for (const member of (missionMembers || []) as any[]) {
          // Safely extract profile whether Supabase returns an array or single object
          const profile = Array.isArray(member.user)
            ? member.user[0]
            : member.user;

          if (!member.user_id || profile?.role === "admin") continue;

          let weeklyXp = 0;
          const { data: stats } = await supabase
            .from("user_stats")
            .select("weekly_xp")
            .eq("user_id", member.user_id)
            .single();

          if (stats) weeklyXp = stats.weekly_xp;

          const isActive = !!member.joined_at;
          const existing = memberMap.get(member.user_id);

          const memberObj: TeamMember = {
            id: member.user_id,
            userId: member.user_id,
            username: profile?.username || "Pending Registration",
            role: member.role as "member" | "manager",
            joinedAt: isActive
              ? new Date(member.joined_at!).toLocaleDateString()
              : "Awaiting App Sync",
            level: profile?.level || 1,
            streak: profile?.streak || 0,
            weeklyXp: weeklyXp,
            status: isActive ? "active" : "pending",
          };

          if (!existing) {
            memberMap.set(member.user_id, memberObj);
          } else {
            memberMap.set(member.user_id, {
              ...existing,
              role:
                existing.role === "manager" || member.role === "manager"
                  ? "manager"
                  : "member",
              status:
                existing.status === "active" || isActive ? "active" : "pending",
            });
          }
        }

        setMembers(Array.from(memberMap.values()));
      } catch (err) {
        console.error("Error fetching team members:", err);
        toast.error("Failed to sync team roster");
      } finally {
        setLoading(false);
      }
    },
    [supabase],
  );

  const fetchAvailableUsers = useCallback(async () => {
    try {
      const { data: users, error } = await supabase
        .from("profiles")
        .select("id, username")
        .neq("role", "admin")
        .order("username", { ascending: true });

      if (error) throw error;
      setAvailableUsers(users || []);
    } catch (err) {
      console.error("Error fetching baseline users:", err);
    }
  }, [supabase]);

  const initContext = useCallback(async () => {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      const userId = user?.id || null;
      setCurrentUserId(userId);

      if (userId) {
        const { data: managedMission } = await supabase
          .from("mission_members")
          .select("mission_id")
          .eq("user_id", userId)
          .eq("role", "manager")
          .limit(1)
          .maybeSingle();

        if (managedMission) {
          setPrimaryMissionId(managedMission.mission_id);
        }

        await Promise.all([fetchTeamMembers(userId), fetchAvailableUsers()]);
      }
    } catch (err) {
      console.error("Error initializing user page:", err);
    } finally {
      setLoading(false);
    }
  }, [supabase, fetchTeamMembers, fetchAvailableUsers]);

  useEffect(() => {
    if (authLoading) return;
    initContext();
  }, [authLoading, initContext]);

  const handleInvite = async (data: { userId?: string; email?: string }) => {
    if (!currentUserId || !primaryMissionId) {
      toast.error(
        "You must create or manage at least one mission to invite users.",
      );
      return;
    }

    try {
      if (data.userId) {
        const existingMember = members.find((m) => m.userId === data.userId);
        if (existingMember) {
          toast.error("User is already on your team.");
          return;
        }

        const { error } = await supabase.from("mission_members").insert({
          mission_id: primaryMissionId,
          user_id: data.userId,
          role: "member",
          invited_by: currentUserId,
          joined_at: null,
        });

        if (error) throw error;
        toast.success("Invitation dispatched!");
      }

      setShowInviteDialog(false);
      fetchTeamMembers(currentUserId);
    } catch (err: any) {
      toast.error(err?.message || "Failed to invite user");
    }
  };

  const handleRoleChange = async (
    userId: string | null,
    newRole: "member" | "manager",
  ) => {
    if (!userId || !currentUserId) return;

    try {
      const { error } = await supabase
        .from("mission_members")
        .update({ role: newRole })
        .eq("user_id", userId)
        .eq("invited_by", currentUserId);

      if (error) throw error;

      setMembers((prev) =>
        prev.map((m) => (m.userId === userId ? { ...m, role: newRole } : m)),
      );

      toast.success(`Role updated to ${newRole}`);
    } catch (err) {
      toast.error("Could not update role");
    }
  };

  const handleDeleteMember = async (
    userId: string | null,
    username: string,
  ) => {
    if (!userId || !currentUserId) return;

    if (!window.confirm(`Remove ${username} from your team?`)) return;

    try {
      const { error } = await supabase
        .from("mission_members")
        .delete()
        .eq("user_id", userId)
        .eq("invited_by", currentUserId);

      if (error) throw error;

      setMembers((prev) => prev.filter((m) => m.userId !== userId));
      toast.success(`${username} removed from team.`);
    } catch (err) {
      toast.error("Failed to remove team member");
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
                  className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] transition-colors last:border-0"
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
                          member.userId,
                          e.target.value as "member" | "manager",
                        )
                      }
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
                      onClick={() =>
                        handleDeleteMember(member.userId, member.username)
                      }
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
