"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

interface AvailableUser {
  id: string;
  username: string;
}

interface InviteMemberDialogProps {
  availableUsers: AvailableUser[];
  onClose: () => void;
  onSubmit: (data: { userId?: string; email?: string }) => Promise<void>;
}

export function InviteMemberDialog({
  availableUsers,
  onClose,
  onSubmit,
}: InviteMemberDialogProps) {
  const [inviteMethod, setInviteMethod] = useState<"username" | "email">(
    "username",
  );
  const [selectedUserId, setSelectedUserId] = useState("");
  const [searchInput, setSearchInput] = useState("");
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);

  const filteredUsers = availableUsers.filter((user) =>
    user.username.toLowerCase().includes(searchInput.toLowerCase()),
  );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (inviteMethod === "username") {
        if (!selectedUserId) {
          return;
        }
        await onSubmit({ userId: selectedUserId });
      } else {
        if (!email.trim()) return;
        await onSubmit({ email: email.trim() });
      }

      // Reset on successful confirmation mutation execution
      setSelectedUserId("");
      setSearchInput("");
      setEmail("");
    } catch (err) {
      console.error("Form transmission failed:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-8 w-full max-w-md border border-[#e8e3db] shadow-xl">
        <h2 className="text-2xl font-semibold text-[#1a1a1a] mb-6">
          Invite Member
        </h2>

        {/* Form correctly wraps all sub-tab inputs and triggers natively */}
        <form onSubmit={handleSubmit} className="space-y-6">
          <Tabs
            value={inviteMethod}
            onValueChange={(v) => {
              setInviteMethod(v as "username" | "email");
              // Clear complementary configurations when changing contexts
              setSelectedUserId("");
              setSearchInput("");
              setEmail("");
            }}
            className="w-full"
          >
            <TabsList className="grid w-full grid-cols-2 bg-[#f5f3f0] p-1 rounded-lg">
              <TabsTrigger
                value="username"
                className="text-sm rounded-md data-[state=active]:bg-white data-[state=active]:shadow-sm"
              >
                Select User
              </TabsTrigger>
              <TabsTrigger
                value="email"
                className="text-sm rounded-md data-[state=active]:bg-white data-[state=active]:shadow-sm"
              >
                By Email
              </TabsTrigger>
            </TabsList>

            <TabsContent
              value="username"
              className="space-y-4 mt-4 outline-none"
            >
              <div>
                <label className="block text-sm font-medium text-[#1a1a1a] mb-2">
                  Search & Select User
                </label>
                <Input
                  type="text"
                  value={searchInput}
                  onChange={(e) => {
                    setSearchInput(e.target.value);
                    if (selectedUserId) setSelectedUserId(""); // Reset verification if they keep typing
                  }}
                  placeholder="Type username..."
                  disabled={loading}
                  className="w-full bg-[#fafaf8] border-[#e8e3db]"
                />

                <div className="mt-2 border border-[#e8e3db] rounded-lg max-h-40 overflow-y-auto bg-white divide-y divide-[#e8e3db]">
                  {filteredUsers.length === 0 ? (
                    <div className="p-3 text-sm text-[#8b8b8b] text-center italic">
                      No matching users found
                    </div>
                  ) : (
                    filteredUsers.map((user) => (
                      <div
                        key={user.id}
                        onClick={() => {
                          setSelectedUserId(user.id);
                          setSearchInput(user.username);
                        }}
                        className={`p-3 text-sm cursor-pointer transition-colors ${
                          selectedUserId === user.id
                            ? "bg-indigo-50 text-indigo-700 font-medium"
                            : "hover:bg-[#f5f3f0] text-[#1a1a1a]"
                        }`}
                      >
                        {user.username}
                      </div>
                    ))
                  )}
                </div>

                {selectedUserId && (
                  <div className="mt-3 p-2.5 bg-green-50 border border-green-200 rounded-md text-xs font-medium text-green-800 flex items-center gap-1.5 animate-in fade-in duration-200">
                    <span>✓</span> Ready to invite:{" "}
                    <strong>
                      {
                        availableUsers.find((u) => u.id === selectedUserId)
                          ?.username
                      }
                    </strong>
                  </div>
                )}
              </div>
            </TabsContent>

            <TabsContent value="email" className="space-y-4 mt-4 outline-none">
              <div>
                <label className="block text-sm font-medium text-[#1a1a1a] mb-2">
                  Email Address
                </label>
                <Input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="member@example.com"
                  disabled={loading}
                  required={inviteMethod === "email"}
                  className="w-full bg-[#fafaf8] border-[#e8e3db]"
                />
              </div>
            </TabsContent>
          </Tabs>

          <div className="flex gap-3 pt-2">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={loading}
              className="flex-1 border-[#e8e3db] text-[#1a1a1a] hover:bg-gray-100"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={
                loading ||
                (inviteMethod === "username" ? !selectedUserId : !email.trim())
              }
              className="flex-1 bg-[#1a1a1a] text-white hover:bg-[#333]"
            >
              {loading ? "Inviting..." : "Send Invite"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
