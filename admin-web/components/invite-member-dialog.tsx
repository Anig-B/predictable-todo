"use client";

import { useState, useMemo } from "react";
import { X, Search, Check, AlertCircle, Loader2, UserPlus } from "lucide-react";
import { Button } from "@/components/ui/button";

interface User {
  id: string;
  username: string;
  email?: string;
}

interface InviteMemberDialogProps {
  availableUsers: User[];
  onClose: () => void;
  onSubmit: (data: { userId: string }) => Promise<void>;
}

export default function InviteMemberDialog({
  availableUsers,
  onClose,
  onSubmit,
}: InviteMemberDialogProps) {
  const [selectedUserId, setSelectedUserId] = useState<string>("");
  const [searchInput, setSearchInput] = useState<string>("");
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const filteredUsers = useMemo(() => {
    if (!searchInput.trim()) return availableUsers;
    const query = searchInput.toLowerCase();
    return availableUsers.filter(
      (user) =>
        user.username.toLowerCase().includes(query) ||
        (user.email && user.email.toLowerCase().includes(query)),
    );
  }, [availableUsers, searchInput]);

  const getInitials = (name: string) => {
    if (!name) return "U";
    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);

    if (!selectedUserId) {
      setErrorMessage("Please select a user to invite.");
      return;
    }

    setLoading(true);

    try {
      await onSubmit({ userId: selectedUserId });
      onClose();
    } catch (err: any) {
      console.error("Form transmission failed:", err);
      setErrorMessage(err?.message || "Failed to dispatch invitation.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4 animate-in fade-in duration-150">
      <div className="bg-white rounded-lg border border-[#e8e3db] shadow-xl w-full max-w-md overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#e8e3db] bg-[#fafaf8]">
          <div className="flex items-center gap-2.5">
            <div className="p-1.5 rounded bg-[#1a1a1a] text-white">
              <UserPlus className="w-4 h-4" />
            </div>
            <div>
              <h2 className="text-base font-bold text-[#1a1a1a] tracking-tight">
                Invite Team Member
              </h2>
              <p className="text-[11px] text-[#8b8b8b]">
                Assign workspace permissions to an available user
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            aria-label="Close dialog"
            className="p-1.5 text-[#8b8b8b] hover:text-[#1a1a1a] hover:bg-[#e8e3db]/50 rounded-md transition-colors cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-5 space-y-4">
          {errorMessage && (
            <div className="flex items-start gap-2.5 text-xs text-red-900 bg-red-50 border border-red-200 p-3 rounded-md">
              <AlertCircle className="w-4 h-4 shrink-0 text-red-600 mt-0.5" />
              <span>{errorMessage}</span>
            </div>
          )}

          <div className="space-y-3">
            {/* Search Input */}
            <div className="relative">
              <Search className="w-4 h-4 absolute left-3 top-2.5 text-[#8b8b8b]" />
              <input
                type="text"
                placeholder="Search by username or email..."
                value={searchInput}
                onChange={(e) => {
                  setSearchInput(e.target.value);
                  if (selectedUserId) setSelectedUserId("");
                }}
                className="w-full pl-9 pr-3 py-2 border border-[#e8e3db] rounded-md text-xs bg-[#f8f7f4] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#1a1a1a] focus:border-transparent transition-all placeholder:text-[#8b8b8b]"
              />
            </div>

            {/* Users Selection List */}
            <div className="max-h-60 overflow-y-auto border border-[#e8e3db] rounded-md divide-y divide-[#e8e3db] bg-white">
              {filteredUsers.length === 0 ? (
                <div className="py-8 px-4 text-xs text-[#8b8b8b] text-center">
                  No registered users found matching query.
                </div>
              ) : (
                filteredUsers.map((user) => {
                  const isSelected = selectedUserId === user.id;
                  return (
                    <button
                      key={user.id}
                      type="button"
                      onClick={() => setSelectedUserId(user.id)}
                      className={`w-full flex items-center justify-between p-3 text-left transition-colors cursor-pointer ${
                        isSelected ? "bg-[#f8f7f4]" : "hover:bg-[#fafaf8]"
                      }`}
                    >
                      <div className="flex items-center gap-3 min-w-0">
                        <div
                          className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs tracking-wider shrink-0 transition-colors ${
                            isSelected
                              ? "bg-[#1a1a1a] text-white"
                              : "bg-[#e8e3db] text-[#1a1a1a]"
                          }`}
                        >
                          {getInitials(user.username)}
                        </div>
                        <div className="min-w-0">
                          <p className="text-xs font-semibold text-[#1a1a1a] truncate">
                            {user.username}
                          </p>
                          {user.email && (
                            <p className="text-[11px] text-[#8b8b8b] truncate">
                              {user.email}
                            </p>
                          )}
                        </div>
                      </div>

                      {isSelected && (
                        <div className="p-1 rounded-full bg-[#1a1a1a] text-white shrink-0">
                          <Check className="w-3 h-3" />
                        </div>
                      )}
                    </button>
                  );
                })
              )}
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex justify-end gap-2 pt-3 border-t border-[#e8e3db]">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={loading}
              className="border-[#e8e3db] text-[#1a1a1a] hover:bg-[#f8f7f4] text-xs uppercase font-semibold tracking-wider cursor-pointer"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={loading || !selectedUserId}
              className="bg-[#1a1a1a] hover:bg-black text-white text-xs uppercase font-semibold tracking-wider px-4 flex items-center gap-2 cursor-pointer disabled:opacity-50"
            >
              {loading && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
              Send Invitation
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
