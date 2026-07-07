"use client";

import { useState } from "react";
import { users } from "@/lib/data";
import { UserAvatar } from "./user-avatar";
import { toast } from "sonner";
import { ChevronDown, X } from "lucide-react";

interface UserDetailSheetProps {
  user: (typeof users)[0];
  onClose: () => void;
}

export function UserDetailSheet({ user, onClose }: UserDetailSheetProps) {
  const [roleDropdownOpen, setRoleDropdownOpen] = useState(false);

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  const handleRoleChange = (newRole: string) => {
    setRoleDropdownOpen(false);
    toast.success("Role updated");
  };

  const handleRemove = () => {
    toast.success("Member removed");
    onClose();
  };

  return (
    <>
      {/* Overlay */}
      <div className="fixed inset-0 bg-black/20 z-40" onClick={onClose} />

      {/* Sheet */}
      <div className="fixed right-0 top-0 h-screen w-96 bg-white border-l border-[#e8e3db] shadow-xl z-50 overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-[#e8e3db] px-6 py-4 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-[#1a1a1a]">User details</h2>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <X className="w-5 h-5 text-[#6b6b6b]" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* User Avatar and Info */}
          <div className="flex flex-col items-center text-center">
            <UserAvatar
              name={user.name}
              initials={getInitials(user.name)}
              size="lg"
            />
            <h3 className="text-lg font-semibold text-[#1a1a1a] mt-4">
              {user.name}
            </h3>
            <p className="text-sm text-[#8b8b8b]">{user.shortId}</p>
            <p className="text-sm text-[#8b8b8b]">{user.email}</p>
          </div>

          {/* Stats Row */}
          <div className="grid grid-cols-4 gap-3">
            <div className="bg-[#fafaf8] rounded-lg p-3 text-center">
              <p className="text-lg font-semibold text-[#1a1a1a]">{user.xp}</p>
              <p className="text-xs text-[#8b8b8b] mt-1">XP</p>
            </div>
            <div className="bg-[#fafaf8] rounded-lg p-3 text-center">
              <p className="text-lg font-semibold text-[#1a1a1a]">
                {user.level}
              </p>
              <p className="text-xs text-[#8b8b8b] mt-1">Level</p>
            </div>
            <div className="bg-[#fafaf8] rounded-lg p-3 text-center">
              <p className="text-lg font-semibold text-[#1a1a1a]">
                {user.streak}
              </p>
              <p className="text-xs text-[#8b8b8b] mt-1">Streak</p>
            </div>
            <div className="bg-[#fafaf8] rounded-lg p-3 text-center">
              <p className="text-lg font-semibold text-[#1a1a1a]">
                {user.weeklyXp}
              </p>
              <p className="text-xs text-[#8b8b8b] mt-1">Weekly</p>
            </div>
          </div>

          {/* Missions Section */}
          <div>
            <h4 className="text-sm font-semibold text-[#1a1a1a] mb-3">
              Missions
            </h4>
            <div className="space-y-2">
              <div className="flex items-center justify-between p-3 bg-[#fafaf8] rounded-lg text-sm">
                <span className="text-[#1a1a1a]">Website Redesign</span>
                <span className="px-2 py-1 bg-[#dbeafe] text-[#1e40af] text-xs font-medium rounded">
                  Manager
                </span>
              </div>
              <div className="flex items-center justify-between p-3 bg-[#fafaf8] rounded-lg text-sm">
                <span className="text-[#1a1a1a]">Marketing Q3</span>
                <span className="px-2 py-1 bg-[#f0fdf4] text-[#166534] text-xs font-medium rounded">
                  Member
                </span>
              </div>
            </div>
          </div>

          {/* Recent Activity */}
          <div>
            <h4 className="text-sm font-semibold text-[#1a1a1a] mb-3">
              Recent activity
            </h4>
            <div className="space-y-3">
              <div className="text-sm">
                <p className="text-[#1a1a1a] font-medium">
                  Completed Write homepage copy
                </p>
                <p className="text-xs text-[#8b8b8b] mt-1">2 hours ago</p>
              </div>
              <div className="text-sm">
                <p className="text-[#1a1a1a] font-medium">
                  Joined Website Redesign
                </p>
                <p className="text-xs text-[#8b8b8b] mt-1">1 week ago</p>
              </div>
              <div className="text-sm">
                <p className="text-[#1a1a1a] font-medium">Reached Level 8</p>
                <p className="text-xs text-[#8b8b8b] mt-1">2 weeks ago</p>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="space-y-3 pt-4 border-t border-[#e8e3db]">
            <div>
              <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
                Change role
              </label>
              <div className="relative">
                <button
                  onClick={() => setRoleDropdownOpen(!roleDropdownOpen)}
                  className="w-full flex items-center justify-between px-3 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a] hover:bg-[#f0ebe4] transition-colors"
                >
                  <span className="capitalize">{user.role}</span>
                  <ChevronDown className="w-4 h-4" />
                </button>
                {roleDropdownOpen && (
                  <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10">
                    <button
                      onClick={() => handleRoleChange("admin")}
                      className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] first:rounded-t-lg"
                    >
                      Admin
                    </button>
                    <button
                      onClick={() => handleRoleChange("user")}
                      className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] last:rounded-b-lg"
                    >
                      User
                    </button>
                  </div>
                )}
              </div>
            </div>

            <button
              onClick={handleRemove}
              className="w-full px-3 py-2 bg-[#fee2e2] border border-[#fecaca] text-[#991b1b] rounded-lg text-sm font-medium hover:bg-[#fcd5d5] transition-colors"
            >
              Remove from mission
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
