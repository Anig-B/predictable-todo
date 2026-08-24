"use client";

import { useEffect, useState } from "react";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";
import { getMissionTasksAndMembers, MissionMember } from "@/actions/missions";

export function MissionMembersSection({ missionId }: { missionId: string }) {
  const [members, setMembers] = useState<MissionMember[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchMembers() {
      try {
        setLoading(true);
        const data = await getMissionTasksAndMembers(missionId);
        setMembers(data.members);
      } catch (err: any) {
        toast.error("Failed to load members");
      } finally {
        setLoading(false);
      }
    }
    fetchMembers();
  }, [missionId]);

  if (loading) {
    return (
      <Loader2 className="w-6 h-6 animate-spin text-gray-400 mx-auto my-4" />
    );
  }

  return (
    <div className="space-y-4">
      <h3 className="text-lg font-semibold text-gray-800">Team Members</h3>
      <div className="divide-y divide-gray-100">
        {members.map((m) => (
          <div
            key={m.user_id}
            className="py-3 flex items-center justify-between"
          >
            <div>
              <p className="text-sm font-medium text-gray-800">{m.username}</p>
              <p className="text-xs text-gray-400 capitalize">{m.role}</p>
            </div>
            <span className="text-xs text-gray-400">
              {m.joined_at
                ? `Joined ${new Date(m.joined_at).toLocaleDateString()}`
                : "Pending invite"}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
