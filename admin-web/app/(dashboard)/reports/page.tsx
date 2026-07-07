"use client";

import { useState } from "react";
import { users, missions, activities } from "@/lib/data";
import { Button } from "@/components/ui/button";
import { ChevronDown } from "lucide-react";
import { toast } from "sonner";
import { UserAvatar } from "@/components/user-avatar";

export default function ReportsPage() {
  const [viewMode, setViewMode] = useState<"user" | "mission">("user");
  const [timeframe, setTimeframe] = useState<"daily" | "weekly" | "monthly">(
    "weekly",
  );
  const [selectedUser, setSelectedUser] = useState(users[0]);
  const [selectedMission, setSelectedMission] = useState(missions[0]);
  const [dropdownOpen, setDropdownOpen] = useState<string | null>(null);

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  const handleExportCSV = () => {
    toast.success("Exported 8 rows");
  };

  return (
    <div className="p-8">
      {/* Page Header */}
      <h1 className="text-3xl font-semibold text-[#1a1a1a] mb-8">Reports</h1>

      {/* Controls */}
      <div className="flex items-center gap-4 mb-8">
        {/* Toggle View Mode */}
        <div className="flex gap-2 bg-[#fafaf8] p-1 rounded-lg border border-[#e8e3db]">
          <button
            onClick={() => setViewMode("user")}
            className={`px-3 py-2 rounded text-sm font-medium transition-colors ${
              viewMode === "user"
                ? "bg-white text-[#1a1a1a]"
                : "text-[#8b8b8b] hover:text-[#6b6b6b]"
            }`}
          >
            By user
          </button>
          <button
            onClick={() => setViewMode("mission")}
            className={`px-3 py-2 rounded text-sm font-medium transition-colors ${
              viewMode === "mission"
                ? "bg-white text-[#1a1a1a]"
                : "text-[#8b8b8b] hover:text-[#6b6b6b]"
            }`}
          >
            By mission
          </button>
        </div>

        {/* Timeframe Selector */}
        <div className="flex gap-2">
          {["Daily", "Weekly", "Monthly"].map((label) => (
            <button
              key={label}
              onClick={() => setTimeframe(label.toLowerCase() as any)}
              className={`px-3 py-2 rounded text-sm font-medium transition-colors ${
                timeframe === label.toLowerCase()
                  ? "bg-[#1a1a1a] text-white"
                  : "bg-[#fafaf8] text-[#8b8b8b] border border-[#e8e3db] hover:text-[#6b6b6b]"
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {/* By User View */}
      {viewMode === "user" && (
        <div className="space-y-8">
          {/* User Selector */}
          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              User
            </label>
            <div className="relative w-96">
              <button
                onClick={() =>
                  setDropdownOpen(dropdownOpen === "user" ? null : "user")
                }
                className="w-full flex items-center justify-between px-4 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a] hover:bg-[#f0ebe4] transition-colors"
              >
                <span>{selectedUser.name}</span>
                <ChevronDown className="w-4 h-4" />
              </button>
              {dropdownOpen === "user" && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10 max-h-48 overflow-y-auto">
                  {users.map((user) => (
                    <button
                      key={user.id}
                      onClick={() => {
                        setSelectedUser(user);
                        setDropdownOpen(null);
                      }}
                      className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                    >
                      {user.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* User Stats */}
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

          {/* Completion Rate */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-8">
            <p className="text-sm text-[#8b8b8b] mb-4">Quest completion rate</p>
            <div className="flex items-baseline gap-4">
              <p className="text-6xl font-bold text-[#1a1a1a]">67%</p>
              <p className="text-lg text-[#8b8b8b]">6 of 9 quests completed</p>
            </div>
          </div>

          {/* Activity Table */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="border-b border-[#e8e3db] bg-[#f5f3f0]">
                  <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                    Task
                  </th>
                  <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                    Mission
                  </th>
                  <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                    Points
                  </th>
                  <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                    Notes
                  </th>
                  <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                    Date
                  </th>
                </tr>
              </thead>
              <tbody>
                {activities.slice(0, 5).map((activity) => (
                  <tr
                    key={activity.id}
                    className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] last:border-0"
                  >
                    <td className="px-6 py-4 text-sm text-[#1a1a1a]">
                      {activity.action}
                    </td>
                    <td className="px-6 py-4 text-sm text-[#8b8b8b]">
                      {activity.missionName || "−"}
                    </td>
                    <td className="px-6 py-4 text-sm font-medium text-[#1a1a1a]">
                      {activity.points || "−"}
                    </td>
                    <td className="px-6 py-4 text-sm text-[#8b8b8b]">−</td>
                    <td className="px-6 py-4 text-sm text-[#8b8b8b]">
                      {activity.timestamp}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* By Mission View */}
      {viewMode === "mission" && (
        <div className="space-y-8">
          {/* Mission Selector */}
          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Mission
            </label>
            <div className="relative w-96">
              <button
                onClick={() =>
                  setDropdownOpen(dropdownOpen === "mission" ? null : "mission")
                }
                className="w-full flex items-center justify-between px-4 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a] hover:bg-[#f0ebe4] transition-colors"
              >
                <span>{selectedMission.name}</span>
                <ChevronDown className="w-4 h-4" />
              </button>
              {dropdownOpen === "mission" && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10 max-h-48 overflow-y-auto">
                  {missions.map((mission) => (
                    <button
                      key={mission.id}
                      onClick={() => {
                        setSelectedMission(mission);
                        setDropdownOpen(null);
                      }}
                      className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                    >
                      {mission.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Mission Stats */}
          <div className="grid grid-cols-4 gap-4">
            <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
              <p className="text-sm text-[#8b8b8b] mb-2">Total quests</p>
              <p className="text-3xl font-semibold text-[#1a1a1a]">
                {selectedMission.questsTotal}
              </p>
            </div>
            <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
              <p className="text-sm text-[#8b8b8b] mb-2">Completed</p>
              <p className="text-3xl font-semibold text-[#1a1a1a]">
                {selectedMission.questsDone}
              </p>
            </div>
            <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
              <p className="text-sm text-[#8b8b8b] mb-2">Completion rate</p>
              <p className="text-3xl font-semibold text-[#1a1a1a]">
                {Math.round(
                  (selectedMission.questsDone / selectedMission.questsTotal) *
                    100,
                )}
                %
              </p>
            </div>
            <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
              <p className="text-sm text-[#8b8b8b] mb-2">XP earned</p>
              <p className="text-3xl font-semibold text-[#1a1a1a]">340</p>
            </div>
          </div>

          {/* Per-Member Breakdown */}
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
                {[
                  { name: "Alice", assigned: 4, done: 3, xp: 180 },
                  { name: "Bob", assigned: 3, done: 2, xp: 120 },
                  { name: "Carol", assigned: 1, done: 0, xp: 0 },
                ].map((row) => (
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
                ))}
              </tbody>
            </table>
          </div>

          {/* Export Button */}
          <div>
            <Button
              onClick={handleExportCSV}
              variant="outline"
              className="border-[#e8e3db] text-[#6b6b6b] hover:bg-[#f0ebe4]"
            >
              Export CSV
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
