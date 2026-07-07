"use client";

import { useState } from "react";
import { users } from "@/lib/data";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { X, ChevronDown } from "lucide-react";

interface InviteMemberDialogProps {
  onClose: () => void;
  onSubmit: (data: { userId: string; role: string }) => void;
}

export function InviteMemberDialog({
  onClose,
  onSubmit,
}: InviteMemberDialogProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [roleDropdownOpen, setRoleDropdownOpen] = useState(false);
  const [selectedRole, setSelectedRole] = useState("Member");

  const filteredUsers = users.filter((user) =>
    user.name.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedUserId) {
      onSubmit({ userId: selectedUserId, role: selectedRole });
    }
  };

  return (
    <>
      {/* Overlay */}
      <div className="fixed inset-0 bg-black/20 z-40" onClick={onClose} />

      {/* Dialog */}
      <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md bg-white border border-[#e8e3db] rounded-lg shadow-xl z-50">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#e8e3db]">
          <h2 className="text-lg font-semibold text-[#1a1a1a]">
            Invite member
          </h2>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <X className="w-5 h-5 text-[#6b6b6b]" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Search users
            </label>
            <Input
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by name"
              className="bg-[#fafaf8] border-[#e8e3db]"
            />
          </div>

          {filteredUsers.length > 0 && (
            <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg max-h-40 overflow-y-auto">
              {filteredUsers.map((user) => (
                <button
                  key={user.id}
                  type="button"
                  onClick={() => {
                    setSelectedUserId(user.id);
                    setSearchQuery("");
                  }}
                  className="w-full text-left px-4 py-3 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] border-b border-[#e8e3db] last:border-0"
                >
                  {user.name}
                </button>
              ))}
            </div>
          )}

          {selectedUserId && (
            <div className="p-3 bg-[#f0fdf4] border border-[#bbf7d0] rounded-lg text-sm">
              <p className="text-[#166534]">
                <span className="font-medium">
                  {users.find((u) => u.id === selectedUserId)?.name}
                </span>{" "}
                selected
              </p>
            </div>
          )}

          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Role
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={() => setRoleDropdownOpen(!roleDropdownOpen)}
                className="w-full flex items-center justify-between px-3 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a] hover:bg-[#f0ebe4] transition-colors"
              >
                <span>{selectedRole}</span>
                <ChevronDown className="w-4 h-4" />
              </button>
              {roleDropdownOpen && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10">
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedRole("Member");
                      setRoleDropdownOpen(false);
                    }}
                    className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] first:rounded-t-lg"
                  >
                    Member
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedRole("Manager");
                      setRoleDropdownOpen(false);
                    }}
                    className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] last:rounded-b-lg"
                  >
                    Manager
                  </button>
                </div>
              )}
            </div>
          </div>

          <div className="flex gap-3 pt-4">
            <Button
              type="button"
              onClick={onClose}
              variant="outline"
              className="flex-1 border-[#e8e3db] text-[#6b6b6b] hover:bg-[#f0ebe4]"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={!selectedUserId}
              className="flex-1 bg-[#1a1a1a] text-white hover:bg-[#333333] disabled:opacity-50"
            >
              Invite
            </Button>
          </div>
        </form>
      </div>
    </>
  );
}
