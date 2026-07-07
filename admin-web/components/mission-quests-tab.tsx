"use client";

import { useState } from "react";
import { quests, users } from "@/lib/data";
import { UserAvatar } from "./user-avatar";
import { Button } from "@/components/ui/button";
import { CheckCircle2 } from "lucide-react";
import { toast } from "sonner";
import { CreateQuestDialog } from "./create-quest-dialog";

interface MissionQuestsTabProps {
  missionId: string;
}

export function MissionQuestsTab({ missionId }: MissionQuestsTabProps) {
  const [showCreateQuestDialog, setShowCreateQuestDialog] = useState(false);

  const missionQuests = quests.filter((q) => q.missionId === missionId);

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  const getAssignedUserName = (userId: string) => {
    return users.find((u) => u.id === userId)?.name || "Unknown";
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "High":
        return "bg-[#fee2e2] text-[#991b1b]";
      case "Medium":
        return "bg-[#fef3c7] text-[#92400e]";
      case "Low":
        return "bg-[#d1fae5] text-[#065f46]";
      default:
        return "bg-[#f3f4f6] text-[#6b7280]";
    }
  };

  const getProofStatusColor = (status: string | null) => {
    switch (status) {
      case "Approved":
        return "bg-[#d1fae5] text-[#065f46]";
      case "Pending review":
        return "bg-[#fed7aa] text-[#92400e]";
      default:
        return "bg-[#f3f4f6] text-[#6b7280]";
    }
  };

  return (
    <>
      <div className="flex justify-end mb-6">
        <Button
          onClick={() => setShowCreateQuestDialog(true)}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333]"
        >
          Create quest
        </Button>
      </div>

      {/* Quests Table */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-[#e8e3db] bg-[#f5f3f0]">
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Title
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Assigned to
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Points
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Priority
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Category
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Status
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Proof
              </th>
            </tr>
          </thead>
          <tbody>
            {missionQuests.map((quest) => (
              <tr
                key={quest.id}
                className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] transition-colors last:border-0"
              >
                <td className="px-6 py-4">
                  <span className="text-sm font-medium text-[#1a1a1a]">
                    {quest.title}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <div className="flex items-center gap-2">
                    <UserAvatar
                      name={getAssignedUserName(quest.assignedTo)}
                      initials={getInitials(
                        getAssignedUserName(quest.assignedTo),
                      )}
                      size="sm"
                    />
                    <span className="text-sm text-[#6b6b6b]">
                      {getAssignedUserName(quest.assignedTo)}
                    </span>
                  </div>
                </td>
                <td className="px-6 py-4 text-sm text-[#1a1a1a] font-medium">
                  {quest.points}
                </td>
                <td className="px-6 py-4">
                  <span
                    className={`inline-block px-2 py-1 rounded text-xs font-medium ${getPriorityColor(quest.priority)}`}
                  >
                    {quest.priority}
                  </span>
                </td>
                <td className="px-6 py-4 text-sm text-[#6b6b6b]">
                  {quest.category}
                </td>
                <td className="px-6 py-4">
                  <div className="flex items-center gap-2 text-sm text-[#6b6b6b]">
                    {quest.status === "Done" ? (
                      <CheckCircle2 className="w-4 h-4 text-[#14b8a6]" />
                    ) : (
                      <span className="text-[#8b8b8b]">−</span>
                    )}
                    <span>{quest.status === "Done" ? "Done" : "Pending"}</span>
                  </div>
                </td>
                <td className="px-6 py-4">
                  {quest.proofStatus ? (
                    <span
                      className={`inline-block px-2 py-1 rounded text-xs font-medium ${getProofStatusColor(quest.proofStatus)}`}
                    >
                      {quest.proofStatus}
                    </span>
                  ) : (
                    <span className="text-sm text-[#8b8b8b]">−</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showCreateQuestDialog && (
        <CreateQuestDialog
          onClose={() => setShowCreateQuestDialog(false)}
          onSubmit={(data) => {
            setShowCreateQuestDialog(false);
            toast.success("Quest created");
          }}
        />
      )}
    </>
  );
}
