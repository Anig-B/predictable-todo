"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

export interface MissionOption {
  id: string;
  name: string;
  tasksTotal: number;
  tasksDone: number;
  xpEarned: number;
}

export interface MissionMemberBreakdown {
  name: string;
  assigned: number;
  done: number;
  xp: number;
}

interface MissionReportViewProps {
  missionsList: MissionOption[];
  selectedMission: MissionOption;
  missionMembers: MissionMemberBreakdown[];
  onSelectMission: (mission: MissionOption) => void;
}

export function MissionReportView({
  missionsList,
  selectedMission,
  missionMembers,
  onSelectMission,
}: MissionReportViewProps) {
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const completionRate =
    selectedMission.tasksTotal > 0
      ? Math.round(
          (selectedMission.tasksDone / selectedMission.tasksTotal) * 100,
        )
      : 0;

  return (
    <div className="space-y-8">
      <div>
        <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
          Managed Mission
        </label>
        <div className="relative w-96">
          <button
            onClick={() => setDropdownOpen(!dropdownOpen)}
            className="w-full flex items-center justify-between px-4 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a] hover:bg-[#f0ebe4] transition-colors"
          >
            <span>{selectedMission.name}</span>
            <ChevronDown className="w-4 h-4" />
          </button>
          {dropdownOpen && (
            <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10 max-h-48 overflow-y-auto">
              {missionsList.map((m) => (
                <button
                  key={m.id}
                  onClick={() => {
                    onSelectMission(m);
                    setDropdownOpen(false);
                  }}
                  className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                >
                  {m.name}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-4 gap-4">
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">Total tasks</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {selectedMission.tasksTotal}
          </p>
        </div>
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">Completed</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {selectedMission.tasksDone}
          </p>
        </div>
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">Completion rate</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {completionRate}%
          </p>
        </div>
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">XP earned</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {selectedMission.xpEarned}
          </p>
        </div>
      </div>

      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-[#e8e3db] bg-[#f5f3f0]">
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Member
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Assigned
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Done
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                XP earned
              </th>
            </tr>
          </thead>
          <tbody>
            {missionMembers.length === 0 ? (
              <tr>
                <td
                  colSpan={4}
                  className="px-6 py-4 text-center text-[#8b8b8b]"
                >
                  No joined members found for this mission
                </td>
              </tr>
            ) : (
              missionMembers.map((row) => (
                <tr
                  key={row.name}
                  className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] last:border-0"
                >
                  <td className="px-6 py-4 text-sm font-medium text-[#1a1a1a]">
                    {row.name}
                  </td>
                  <td className="px-6 py-4 text-sm text-[#8b8b8b]">
                    {row.assigned}
                  </td>
                  <td className="px-6 py-4 text-sm text-[#8b8b8b]">
                    {row.done}
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-[#1a1a1a]">
                    {row.xp}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
