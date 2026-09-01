"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import { useAuthCheck } from "@/hooks/useAuthCheck";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import InviteMemberDialog from "@/components/invite-member-dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { toast } from "sonner";
import { Trash2 } from "lucide-react";
import {
  getUsersPageData,
  inviteTeamMember,
  removeTeamMember,
  TeamMember,
  AvailableUser,
} from "@/actions/users";

const getInitials = (name: string) => {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
};

interface MemberRowProps {
  member: TeamMember;
  currentUserId: string | null;
  onRequestDelete: (member: TeamMember) => void;
}

const MemberRow = React.memo(
  ({ member, currentUserId, onRequestDelete }: MemberRowProps) => {
    const isSelf = member.userId === currentUserId;

    return (
      <tr className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] transition-colors last:border-0">
        <td className="px-6 py-4">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 font-bold text-xs flex items-center justify-center">
              {getInitials(member.username || "User")}
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
        <td className="px-6 py-4 text-sm font-semibold text-[#1a1a1a]">
          {member.tasksAssigned ?? 0}
        </td>
        <td className="px-6 py-4 text-sm text-[#6b6b6b]">{member.joinedAt}</td>
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
            disabled={isSelf}
            onClick={() => onRequestDelete(member)}
            className="p-1.5 text-gray-400 hover:text-red-600 disabled:opacity-30 disabled:hover:text-gray-400 rounded transition-colors"
            title={isSelf ? "You cannot remove yourself" : "Remove Member"}
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </td>
      </tr>
    );
  },
);
MemberRow.displayName = "MemberRow";

export default function UsersPage() {
  const { loading: authLoading } = useAuthCheck();

  const [members, setMembers] = useState<TeamMember[]>([]);
  const [availableUsers, setAvailableUsers] = useState<AvailableUser[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [showInviteDialog, setShowInviteDialog] = useState(false);
  const [loading, setLoading] = useState(true);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);
  const [primaryMissionId, setPrimaryMissionId] = useState<string | null>(null);

  // Target deletion state for confirmation dialog
  const [memberToDelete, setMemberToDelete] = useState<TeamMember | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const data = await getUsersPageData();
      setCurrentUserId(data.currentUserId);
      setPrimaryMissionId(data.primaryMissionId);
      setMembers(data.members);
      setAvailableUsers(data.availableUsers);
    } catch (err) {
      console.error("Error initializing users page:", err);
      toast.error("Failed to load team members");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (authLoading) return;
    loadData();
  }, [authLoading, loadData]);

  const handleInvite = useCallback(
    async (data: { userId?: string; email?: string }) => {
      if (!currentUserId || !primaryMissionId) {
        toast.error(
          "You must create or manage at least one mission to invite users.",
        );
        return;
      }

      if (!data.userId) return;

      const existingMember = members.find((m) => m.userId === data.userId);
      if (existingMember) {
        toast.error("User is already on your team.");
        return;
      }

      try {
        await inviteTeamMember(primaryMissionId, data.userId);
        toast.success("Invitation dispatched!");
        setShowInviteDialog(false);
        await loadData();
      } catch (err: any) {
        toast.error(err?.message || "Failed to invite user");
      }
    },
    [currentUserId, primaryMissionId, members, loadData],
  );

  const handleConfirmDelete = async () => {
    if (!memberToDelete?.userId || !primaryMissionId) return;

    setIsDeleting(true);
    const target = memberToDelete;

    setMembers((prev) => prev.filter((m) => m.userId !== target.userId));

    try {
      await removeTeamMember(target.userId, primaryMissionId);
      toast.success(`${target.username} removed successfully`);
    } catch (err: any) {
      setMembers((prev) => [...prev, target]);
      toast.error(err?.message || `Failed to remove ${target.username}`);
    } finally {
      setIsDeleting(false);
      setMemberToDelete(null);
    }
  };

  const filteredMembers = useMemo(() => {
    if (!searchQuery.trim()) return members;
    const query = searchQuery.toLowerCase();
    return members.filter((member) =>
      member.username.toLowerCase().includes(query),
    );
  }, [members, searchQuery]);

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
            Manage your team, track task completion, and send invitations.
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
                No. of Tasks
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
              filteredMembers.map((member, index) => (
                <MemberRow
                  key={member.userId || `member-${index}`}
                  member={member}
                  currentUserId={currentUserId}
                  onRequestDelete={(target) => setMemberToDelete(target)}
                />
              ))
            )}
          </tbody>
        </table>
      </div>

      {showInviteDialog && (
        <InviteMemberDialog
          availableUsers={availableUsers.map((user) => ({
            ...user,
            email: (user as any).email || "",
          }))}
          onClose={() => setShowInviteDialog(false)}
          onSubmit={handleInvite}
        />
      )}

      {/* Yes/No Delete Confirmation Dialog */}
      <AlertDialog
        open={Boolean(memberToDelete)}
        onOpenChange={(open) => {
          if (!open) setMemberToDelete(null);
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>
              Do you wanna delete {memberToDelete?.username}?
            </AlertDialogTitle>
            <AlertDialogDescription>
              Warning: This action will permanently remove this member from your
              team mission and unassign all active tasks associated with them.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isDeleting}>No</AlertDialogCancel>
            <AlertDialogAction
              disabled={isDeleting}
              onClick={handleConfirmDelete}
              className="bg-red-600 hover:bg-red-700 text-white"
            >
              {isDeleting ? "Deleting..." : "Yes"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
