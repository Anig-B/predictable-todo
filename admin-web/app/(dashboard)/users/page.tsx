"use client";

import { useState } from "react";
import { users, UserData } from "@/lib/data"; // Corrected data import path
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

// Placeholder fallback elements until you finalize your custom sheet/avatar subcomponents
function UserAvatar({
  name,
  initials,
}: {
  name: string;
  initials: string;
  size?: string;
}) {
  return (
    <div className="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 font-bold text-xs flex items-center justify-center shrink-0">
      {initials}
    </div>
  );
}

export default function UsersPage() {
  const [selectedUser, setSelectedUser] = useState<UserData | null>(null);
  const [searchQuery, setSearchQuery] = useState("");

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  // Filter based on existing keys in your isolated data.ts file
  const filteredUsers = users.filter((user) =>
    user.name.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  return (
    <div className="p-8">
      {/* Page Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-semibold text-[#1a1a1a]">Users</h1>
          <p className="text-sm text-gray-500 mt-1">
            Manage platform members, execution streaks, and earned progress.
          </p>
        </div>
        <Button className="bg-[#1a1a1a] text-white hover:bg-[#333333]">
          Invite to mission
        </Button>
      </div>

      {/* Search */}
      <div className="mb-6">
        <Input
          placeholder="Search users by name..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-md bg-[#fafaf8] border-[#e8e3db]"
        />
      </div>

      {/* Users Table */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg overflow-hidden shadow-sm">
        <table className="w-full">
          <thead>
            <tr className="border-b border-[#e8e3db] bg-[#f5f3f0]">
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                User
              </th>
              <th className="px-6 py-4 text-left text-sm font-medium text-[#6b6b6b]">
                ID
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
            </tr>
          </thead>
          <tbody>
            {filteredUsers.map((user) => (
              <tr
                key={user.id}
                onClick={() => setSelectedUser(user)}
                className="border-b border-[#e8e3db] hover:bg-[#f0ebe4] cursor-pointer transition-colors last:border-0"
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
                <td className="px-6 py-4 text-sm text-[#6b6b6b]">
                  #00{user.id}
                </td>
                <td className="px-6 py-4 text-sm font-medium text-gray-700">
                  Lvl {user.level}
                </td>
                <td className="px-6 py-4">
                  <span className="inline-block px-2 py-0.5 rounded text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                    {user.streak} days 🔥
                  </span>
                </td>
                <td className="px-6 py-4 text-sm font-bold text-indigo-600">
                  {user.weeklyXp} XP
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Details Preview Sidebar/Sheet Placeholder */}
      {selectedUser && (
        <div className="fixed right-0 top-0 h-screen w-80 bg-white border-l border-[#e8e3db] shadow-xl p-6 z-50 animate-in slide-in-from-right">
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-bold text-lg text-[#1a1a1a]">User Profile</h3>
            <button
              onClick={() => setSelectedUser(null)}
              className="text-gray-400 hover:text-gray-600 text-sm"
            >
              Close
            </button>
          </div>
          <div className="space-y-4">
            <div className="flex items-center gap-3 pb-4 border-b border-[#e8e3db]">
              <div className="w-12 h-12 rounded-full bg-indigo-600 text-white font-bold flex items-center justify-center">
                {getInitials(selectedUser.name)}
              </div>
              <div>
                <p className="font-bold text-base">{selectedUser.name}</p>
                <p className="text-xs text-gray-500">
                  ID: #00{selectedUser.id}
                </p>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4 pt-2">
              <div className="bg-[#fafaf8] p-3 border border-[#e8e3db] rounded">
                <p className="text-xs text-gray-400 font-medium">
                  Current Level
                </p>
                <p className="text-xl font-bold text-gray-800">
                  {selectedUser.level}
                </p>
              </div>
              <div className="bg-[#fafaf8] p-3 border border-[#e8e3db] rounded">
                <p className="text-xs text-gray-400 font-medium">
                  Activity Streak
                </p>
                <p className="text-xl font-bold text-amber-600">
                  {selectedUser.streak} Days
                </p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
