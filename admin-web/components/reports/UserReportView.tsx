"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

export interface UserOption {
  id: string;
  name: string;
  xp: number;
  level: number;
  streak: number;
  weeklyXp: number;
}

export interface ActivityItem {
  id: string;
  task: string;
  project: string;
  points: number | null;
  timestamp: string;
}

interface UserReportViewProps {
  usersList: UserOption[];
  selectedUser: UserOption;
  userActivities: ActivityItem[];
  completionStats: { done: number; total: number; rate: number };
  onSelectUser: (user: UserOption) => void;
}

export function UserReportView({
  usersList,
  selectedUser,
  userActivities,
  completionStats,
  onSelectUser,
}: UserReportViewProps) {
  const [dropdownOpen, setDropdownOpen] = useState(false);

  return (
    <div className="space-y-8">
      <div>
        <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
          Team Member
        </label>
        <div className="relative w-96">
          <button
            onClick={() => setDropdownOpen(!dropdownOpen)}
            className="w-full flex items-center justify-between px-4 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a] hover:bg-[#f0ebe4] transition-colors"
          >
            <span>{selectedUser.name}</span>
            <ChevronDown className="w-4 h-4" />
          </button>
          {dropdownOpen && (
            <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10 max-h-48 overflow-y-auto">
              {usersList.map((u) => (
                <button
                  key={u.id}
                  onClick={() => {
                    onSelectUser(u);
                    setDropdownOpen(false);
                  }}
                  className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                >
                  {u.name}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-4 gap-4">
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">XP</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {selectedUser.xp}
          </p>
        </div>
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">Level</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {selectedUser.level}
          </p>
        </div>
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">Streak</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {selectedUser.streak} days
          </p>
        </div>
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
          <p className="text-sm text-[#8b8b8b] mb-2">Weekly XP</p>
          <p className="text-3xl font-semibold text-[#1a1a1a]">
            {selectedUser.weeklyXp}
          </p>
        </div>
      </div>

      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-8">
        <p className="text-sm text-[#8b8b8b] mb-4">
          Managed task completion rate
        </p>
        <div className="flex items-baseline gap-4">
          <p className="text-6xl font-bold text-[#1a1a1a]">
            {completionStats.rate}%
          </p>
          <p className="text-lg text-[#8b8b8b]">
            {completionStats.done} of {completionStats.total} tasks completed in
            your missions
          </p>
        </div>
      </div>

      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-[#e8e3db] bg-[#f5f3f0]">
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Task / Action
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Project
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Points
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                Date
              </th>
            </tr>
          </thead>
          <tbody>
            {userActivities.length === 0 ? (
              <tr>
                <td
                  colSpan={4}
                  className="px-6 py-4 text-center text-[#8b8b8b]"
                >
                  No activity records found for this user in this timeframe
                </td>
              </tr>
            ) : (
              userActivities.map((act) => (
                <tr
                  key={act.id}
                  className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] last:border-0"
                >
                  <td className="px-6 py-4 text-sm text-[#1a1a1a]">
                    {act.task}
                  </td>
                  <td className="px-6 py-4 text-sm text-[#8b8b8b]">
                    {act.project}
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-[#1a1a1a]">
                    {act.points ?? "−"}
                  </td>
                  <td className="px-6 py-4 text-sm text-[#8b8b8b]">
                    {act.timestamp}
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
