"use client";

import { useState } from "react";
import { users } from "@/lib/data";
import { UserAvatar } from "./user-avatar";
import { Button } from "@/components/ui/button";
import { ChevronDown, Trash2 } from "lucide-react";
import { toast } from "sonner";
import { InviteMemberDialog } from "./invite-member-dialog";

interface MissionMembersTabProps {
  missionId: string;
}

const missionMembers = [
  {
    userId: "1",
    role: "Manager" as const,
    status: "Accepted" as const,
    invitedBy: "Admin",
    joinedDate: "2026-01-12",
  },
  {
    userId: "2",
    role: "Member" as const,
    status: "Accepted" as const,
    invitedBy: "Alice",
    joinedDate: "2026-01-15",
  },
  {
    userId: "3",
    role: "Member" as const,
    status: "Pending" as const,
    invitedBy: "Admin",
    joinedDate: "2026-01-20",
  },
];

export function MissionMembersTab({ missionId }: MissionMembersTabProps) {
  const [showInviteDialog, setShowInviteDialog] = useState(false);
  const [openRoleDropdownId, setOpenRoleDropdownId] = useState<string | null>(
    null,
  );

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  const getRoleColor = (role: string) => {
    return role === "Manager"
      ? "bg-[#dbeafe] text-[#1e40af]"
      : "bg-[#f0fdf4] text-[#166534]";
  };

  const getStatusColor = (status: string) => {
    return status === "Accepted"
      ? "bg-[#d1fae5] text-[#065f46]"
      : "bg-[#fed7aa] text-[#92400e]";
  };

  const handleRoleChange = (userId: string, newRole: string) => {
    setOpenRoleDropdownId(null);
    toast.success("Role updated");
  };

  const handleRemove = (userName: string) => {
    toast.success("Member removed");
  };

  return (
    <>
      <div className="flex justify-end mb-6">
        <Button
          onClick={() => setShowInviteDialog(true)}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333]"
        >
          Invite member
        </Button>
      </div>

      {/* Members Table */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-[#e8e3db] bg-[#f5f3f0]">
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Name
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Role
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Status
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Invited by
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Joined
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {missionMembers.map((member) => {
              const user = users.find((u) => u.id === member.userId);
              if (!user) return null;

              return (
                <tr
                  key={member.userId}
                  className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] transition-colors last:border-0"
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <UserAvatar
                        name={user.name}
                        initials={getInitials(user.name)}
                        size="sm"
                      />
                      <span className="text-sm font-medium text-[#1a1a1a]">
                        {user.name}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="relative">
                      <button
                        onClick={() =>
                          setOpenRoleDropdownId(
                            openRoleDropdownId === member.userId
                              ? null
                              : member.userId,
                          )
                        }
                        className="flex items-center gap-1 px-2 py-1 text-xs font-medium rounded transition-colors hover:opacity-80"
                      >
                        <span className={getRoleColor(member.role)}>
                          {member.role}
                        </span>
                        <ChevronDown className="w-3 h-3" />
                      </button>
                      {openRoleDropdownId === member.userId && (
                        <div className="absolute top-full left-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10">
                          <button
                            onClick={() =>
                              handleRoleChange(member.userId, "Member")
                            }
                            className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] first:rounded-t-lg"
                          >
                            Member
                          </button>
                          <button
                            onClick={() =>
                              handleRoleChange(member.userId, "Manager")
                            }
                            className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] last:rounded-b-lg"
                          >
                            Manager
                          </button>
                        </div>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-block px-2 py-1 rounded text-xs font-medium ${getStatusColor(member.status)}`}
                    >
                      {member.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-[#6b6b6b]">
                    {member.invitedBy}
                  </td>
                  <td className="px-6 py-4 text-sm text-[#6b6b6b]">
                    {member.joinedDate}
                  </td>
                  <td className="px-6 py-4">
                    <button
                      onClick={() => handleRemove(user.name)}
                      className="p-1.5 hover:bg-[#fee2e2] rounded-md transition-colors text-[#991b1b]"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {showInviteDialog && (
        <InviteMemberDialog
          onClose={() => setShowInviteDialog(false)}
          onSubmit={(data) => {
            setShowInviteDialog(false);
            toast.success("Member invited");
          }}
        />
      )}
    </>
  );
}
