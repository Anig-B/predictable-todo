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
import {
  Trash2,
  Flame,
  Search,
  UserPlus,
  Zap,
  CheckCircle2,
  Clock,
} from "lucide-react";
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
      <tr className="border-b border-[#e8e3db] hover:bg-[#f8f7f4] transition-colors last:border-0">
        {/* Member Profile Info */}
        <td className="px-6 py-4">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-[#1a1a1a] text-white font-semibold text-xs flex items-center justify-center shrink-0 shadow-sm">
              {getInitials(member.username || "User")}
            </div>
            <div>
              <span className="text-sm font-semibold text-[#1a1a1a] block">
                {member.username}
              </span>
              {isSelf && (
                <span className="text-[10px] font-medium text-[#8b8b8b] uppercase tracking-wider">
                  You
                </span>
              )}
            </div>
          </div>
        </td>

        {/* Level */}
        <td className="px-6 py-4 text-sm font-medium text-[#6b6b6b]">
          <span className="inline-flex items-center gap-1 font-mono text-xs font-semibold px-2 py-1 bg-[#f0ebe4] text-[#1a1a1a] rounded">
            LVL {member.level}
          </span>
        </td>

        {/* Streak (Replaced 🔥 emoji with sleek Lucide Flame Icon) */}
        <td className="px-6 py-4">
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-800 border border-amber-200/60">
            <Flame className="w-3.5 h-3.5 fill-amber-500 text-amber-500 shrink-0" />
            <span>{member.streak} Days</span>
          </span>
        </td>

        {/* Weekly XP */}
        <td className="px-6 py-4 text-sm font-semibold text-[#1a1a1a]">
          <div className="flex items-center gap-1 text-xs font-mono">
            <Zap className="w-3.5 h-3.5 text-amber-500 fill-amber-500" />
            <span>{member.weeklyXp.toLocaleString()} XP</span>
          </div>
        </td>

        {/* Assigned Tasks */}
        <td className="px-6 py-4 text-sm font-medium text-[#1a1a1a]">
          {member.tasksAssigned ?? 0}
        </td>

        {/* Date Joined */}
        <td className="px-6 py-4 text-xs font-medium text-[#6b6b6b]">
          {member.joinedAt}
        </td>

        {/* Status Badge */}
        <td className="px-6 py-4">
          <span
            className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium border ${
              member.status === "active"
                ? "bg-emerald-50 text-emerald-700 border-emerald-200"
                : "bg-amber-50 text-amber-700 border-amber-200"
            }`}
          >
            {member.status === "active" ? (
              <>
                <CheckCircle2 className="w-3 h-3 text-emerald-600" /> Active
              </>
            ) : (
              <>
                <Clock className="w-3 h-3 text-amber-600" /> Pending
              </>
            )}
          </span>
        </td>

        {/* Action Button */}
        <td className="px-6 py-4 text-center">
          <button
            type="button"
            disabled={isSelf}
            onClick={() => onRequestDelete(member)}
            className="p-1.5 text-[#8b8b8b] hover:text-red-600 hover:bg-red-50 disabled:opacity-20 disabled:hover:bg-transparent disabled:hover:text-[#8b8b8b] rounded-md transition-all cursor-pointer"
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
      <div className="p-8 max-w-7xl mx-auto">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-[#e8e3db] rounded w-1/4"></div>
          <div className="h-10 bg-[#e8e3db] rounded w-1/3"></div>
          <div className="space-y-3">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-16 bg-[#e8e3db] rounded-lg"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-[#e8e3db]">
        <div>
          <h1 className="text-2xl font-bold text-[#1a1a1a] tracking-tight">
            Team Members
          </h1>
          <p className="text-sm text-[#8b8b8b] mt-1">
            Manage your team, track active task contributions, and issue
            invitations.
          </p>
        </div>
        <Button
          onClick={() => setShowInviteDialog(true)}
          className="bg-[#1a1a1a] hover:bg-black text-white text-xs uppercase font-semibold tracking-wider px-4 py-2 flex items-center gap-2 shadow-sm cursor-pointer"
        >
          <UserPlus className="w-4 h-4" />
          Invite Member
        </Button>
      </div>

      {/* Search Bar */}
      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#8b8b8b]" />
        <Input
          placeholder="Search members by username..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="pl-9 bg-white border-[#e8e3db] text-sm text-[#1a1a1a] focus:outline-none focus:border-[#1a1a1a]"
        />
      </div>

      {/* Members Table */}
      <div className="bg-white border border-[#e8e3db] rounded-lg overflow-hidden shadow-sm">
        <table className="w-full text-left">
          <thead>
            <tr className="border-b border-[#e8e3db] bg-[#f8f7f4]">
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b]">
                Member
              </th>
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b]">
                Level
              </th>
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b]">
                Streak
              </th>
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b]">
                Weekly XP
              </th>
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b]">
                Active Tasks
              </th>
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b]">
                Joined
              </th>
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b]">
                Status
              </th>
              <th className="px-6 py-3.5 text-xs font-semibold uppercase tracking-wider text-[#8b8b8b] text-center w-20">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {filteredMembers.length === 0 ? (
              <tr>
                <td
                  colSpan={8}
                  className="px-6 py-8 text-center text-sm text-[#8b8b8b]"
                >
                  No team members matching your search query.
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

      {/* Delete Confirmation Dialog */}
      <AlertDialog
        open={Boolean(memberToDelete)}
        onOpenChange={(open) => {
          if (!open) setMemberToDelete(null);
        }}
      >
        <AlertDialogContent className="bg-white border-[#e8e3db]">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-base font-bold text-[#1a1a1a]">
              Remove {memberToDelete?.username}?
            </AlertDialogTitle>
            <AlertDialogDescription className="text-sm text-[#6b6b6b]">
              This action will permanently unassign active tasks associated with
              this user and remove them from your team mission.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel
              disabled={isDeleting}
              className="border-[#e8e3db]"
            >
              Cancel
            </AlertDialogCancel>
            <AlertDialogAction
              disabled={isDeleting}
              onClick={handleConfirmDelete}
              className="bg-red-600 hover:bg-red-700 text-white"
            >
              {isDeleting ? "Removing..." : "Remove Member"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
