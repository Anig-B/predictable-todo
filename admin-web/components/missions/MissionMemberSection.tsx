"use client";

import { useEffect, useState } from "react";
import { Loader2, UserPlus, Check } from "lucide-react";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import { getMissionTasksAndMembers, MissionMember } from "@/actions/missions";
import { Button } from "@/components/ui/button";

interface AssignableUser {
  id: string;
  username: string;
  avatar_url?: string | null;
}

export function MissionMembersSection({ missionId }: { missionId: string }) {
  const supabase = createClient();

  const [members, setMembers] = useState<MissionMember[]>([]);
  const [loading, setLoading] = useState(true);

  // Modal / Picker State
  const [showAddModal, setShowAddModal] = useState(false);
  const [availableUsers, setAvailableUsers] = useState<AssignableUser[]>([]);
  const [fetchingAvailable, setFetchingAvailable] = useState(false);
  const [selectedUserIds, setSelectedUserIds] = useState<string[]>([]);
  const [addingMembers, setAddingMembers] = useState(false);

  const loadMissionData = async () => {
    try {
      setLoading(true);
      const data = await getMissionTasksAndMembers(missionId);
      setMembers(data.members);
    } catch (err: any) {
      toast.error("Failed to load members");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMissionData();
  }, [missionId]);

  const handleOpenAddModal = async () => {
    setShowAddModal(true);
    setFetchingAvailable(true);
    setSelectedUserIds([]);

    try {
      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();
      if (authError || !user) throw new Error("Authentication failed");

      // 1. Fetch users invited by this manager who HAVE ACCEPTED their invite (joined_at IS NOT NULL)
      const { data: teamMembers, error: teamError } = await supabase
        .from("mission_members")
        .select("user_id")
        .eq("invited_by", user.id)
        .not("joined_at", "is", null);

      if (teamError) throw teamError;

      const acceptedTeamUserIds = Array.from(
        new Set((teamMembers || []).map((m) => m.user_id)),
      );

      // 2. Exclude users who are already part of THIS mission (and current manager)
      const existingMissionUserIds = new Set(
        members
          .filter((m) => m.joined_at !== null) // Only count accepted existing members
          .map((m) => m.user_id),
      );

      const candidateIds = acceptedTeamUserIds.filter(
        (id) => id !== user.id && !existingMissionUserIds.has(id),
      );

      if (candidateIds.length === 0) {
        setAvailableUsers([]);
        return;
      }

      // 3. Retrieve profiles for eligible accepted users
      const { data: profiles, error: profilesError } = await supabase
        .from("profiles")
        .select("id, username, avatar_url")
        .in("id", candidateIds)
        .order("username", { ascending: true });

      if (profilesError) throw profilesError;

      const mapped: AssignableUser[] = (profiles || []).map((p) => ({
        id: p.id,
        username: p.username || p.id.slice(0, 8),
        avatar_url: p.avatar_url,
      }));

      setAvailableUsers(mapped);
    } catch (err: any) {
      toast.error("Failed to load available team members");
    } finally {
      setFetchingAvailable(false);
    }
  };

  const toggleSelectUser = (userId: string) => {
    setSelectedUserIds((prev) =>
      prev.includes(userId)
        ? prev.filter((id) => id !== userId)
        : [...prev, userId],
    );
  };

  const handleAddMembers = async () => {
    if (selectedUserIds.length === 0) return;

    try {
      setAddingMembers(true);
      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();
      if (authError || !user) throw new Error("Authentication failed");

      // Insert new accepted members into mission_members ONLY
      // No tasks are created or backfilled for them
      const inserts = selectedUserIds.map((userId) => ({
        mission_id: missionId,
        user_id: userId,
        role: "member",
        invited_by: user.id,
        joined_at: new Date().toISOString(),
      }));

      const { error: insertError } = await supabase
        .from("mission_members")
        .insert(inserts);

      if (insertError) throw insertError;

      toast.success(
        `${selectedUserIds.length} member(s) added to mission scope`,
      );
      setShowAddModal(false);
      loadMissionData();
    } catch (err: any) {
      toast.error(err.message || "Failed to add members");
    } finally {
      setAddingMembers(false);
    }
  };

  if (loading) {
    return (
      <Loader2 className="w-6 h-6 animate-spin text-gray-400 mx-auto my-4" />
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-800">Team Members</h3>
        <Button
          type="button"
          size="sm"
          onClick={handleOpenAddModal}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333] text-xs flex items-center gap-1.5 h-8"
        >
          <UserPlus className="w-3.5 h-3.5" />
          Add Member
        </Button>
      </div>

      <div className="divide-y divide-gray-100 border border-[#e8e3db] rounded-lg px-4 bg-white">
        {members.map((m) => (
          <div
            key={m.user_id}
            className="py-3 flex items-center justify-between"
          >
            <div>
              <p className="text-sm font-medium text-gray-800">{m.username}</p>
              <p className="text-xs text-gray-400 capitalize">{m.role}</p>
            </div>
            <span className="text-xs text-gray-400">
              {m.joined_at
                ? `Joined ${new Date(m.joined_at).toLocaleDateString()}`
                : "Pending invite"}
            </span>
          </div>
        ))}
      </div>

      {/* Modal */}
      {showAddModal && (
        <>
          <div
            className="fixed inset-0 bg-black/30 z-40 backdrop-blur-xs"
            onClick={() => setShowAddModal(false)}
          />
          <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md bg-white border border-[#e8e3db] rounded-xl shadow-2xl z-50 p-5 space-y-4">
            <div>
              <h4 className="text-base font-bold text-gray-900">
                Add Members to Mission
              </h4>
              <p className="text-xs text-gray-500 mt-0.5">
                Only team members who have accepted their invitation are shown.
                New members will not receive previously created tasks.
              </p>
            </div>

            {fetchingAvailable ? (
              <div className="flex items-center justify-center py-6 text-xs text-gray-400 gap-2">
                <Loader2 className="w-4 h-4 animate-spin" /> Loading accepted
                members...
              </div>
            ) : availableUsers.length === 0 ? (
              <p className="text-xs text-gray-500 italic py-4 text-center">
                No new accepted team members available to add.
              </p>
            ) : (
              <div className="flex flex-wrap gap-2 max-h-48 overflow-y-auto py-2">
                {availableUsers.map((u) => {
                  const selected = selectedUserIds.includes(u.id);
                  return (
                    <button
                      key={u.id}
                      type="button"
                      onClick={() => toggleSelectUser(u.id)}
                      className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all border ${
                        selected
                          ? "bg-[#1a1a1a] text-white border-[#1a1a1a]"
                          : "bg-[#fafaf8] text-gray-600 border-[#e8e3db] hover:bg-gray-100"
                      }`}
                    >
                      {selected ? (
                        <Check className="w-3 h-3" />
                      ) : (
                        <UserPlus className="w-3 h-3" />
                      )}
                      {u.username}
                    </button>
                  );
                })}
              </div>
            )}

            <div className="flex gap-2 pt-2 border-t border-[#e8e3db]">
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() => setShowAddModal(false)}
                disabled={addingMembers}
                className="flex-1 border-[#e8e3db] text-[#6b6b6b]"
              >
                Cancel
              </Button>
              <Button
                type="button"
                size="sm"
                onClick={handleAddMembers}
                disabled={addingMembers || selectedUserIds.length === 0}
                className="flex-1 bg-[#1a1a1a] text-white hover:bg-[#333333]"
              >
                {addingMembers ? (
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                ) : (
                  `Add ${selectedUserIds.length > 0 ? `(${selectedUserIds.length})` : ""}`
                )}
              </Button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
