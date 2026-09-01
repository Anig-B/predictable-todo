"use client";

import { useState, useMemo } from "react";
import { X, Search, UserCheck, AlertCircle, Loader2 } from "lucide-react";

interface User {
  id: string;
  username: string;
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
    return availableUsers.filter((user) =>
      user.username.toLowerCase().includes(query),
    );
  }, [availableUsers, searchInput]);

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
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="bg-white rounded-lg border border-[#e8e3db] shadow-lg w-full max-w-md overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-[#e8e3db]">
          <h2 className="text-lg font-semibold text-[#1a1a1a]">
            Invite Team Member
          </h2>
          <button
            onClick={onClose}
            aria-label="Close dialog"
            className="p-1.5 text-gray-500 hover:text-[#1a1a1a] rounded-md transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          {errorMessage && (
            <div className="flex items-center gap-2 text-sm text-red-700 bg-red-50 border border-red-200 p-3 rounded-md">
              <AlertCircle className="w-4 h-4 shrink-0" />
              <span>{errorMessage}</span>
            </div>
          )}

          <div className="space-y-3">
            <div className="relative">
              <Search className="w-4 h-4 absolute left-3 top-3 text-gray-400" />
              <input
                type="text"
                placeholder="Search username..."
                value={searchInput}
                onChange={(e) => {
                  setSearchInput(e.target.value);
                  if (selectedUserId) setSelectedUserId("");
                }}
                className="w-full pl-9 pr-3 py-2 border border-[#e8e3db] rounded-md text-sm bg-[#fafaf8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#1a1a1a] focus:border-transparent transition-all"
              />
            </div>

            <div className="max-h-56 overflow-y-auto border border-[#e8e3db] rounded-md divide-y divide-[#e8e3db]">
              {filteredUsers.length === 0 ? (
                <div className="p-4 text-xs text-gray-400 text-center">
                  No registered users found matching query.
                </div>
              ) : (
                filteredUsers.map((user) => (
                  <button
                    key={user.id}
                    type="button"
                    onClick={() => setSelectedUserId(user.id)}
                    className={`w-full flex items-center justify-between p-3 text-left text-sm transition-colors ${
                      selectedUserId === user.id
                        ? "bg-indigo-50 text-indigo-950 font-medium"
                        : "hover:bg-[#fafaf8] text-[#1a1a1a]"
                    }`}
                  >
                    <span className="font-medium">{user.username}</span>
                    {selectedUserId === user.id && (
                      <UserCheck className="w-4 h-4 text-indigo-600" />
                    )}
                  </button>
                ))
              )}
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex justify-end gap-2 pt-3 border-t border-[#e8e3db]">
            <button
              type="button"
              onClick={onClose}
              disabled={loading}
              className="px-4 py-2 text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 border border-[#e8e3db] rounded-md transition-colors disabled:opacity-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading || !selectedUserId}
              className="flex items-center gap-1.5 px-4 py-2 text-sm font-medium text-white bg-[#1a1a1a] hover:bg-[#333333] rounded-md transition-colors disabled:opacity-50 shadow-sm"
            >
              {loading && <Loader2 className="w-4 h-4 animate-spin" />}
              Send Invitation
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
