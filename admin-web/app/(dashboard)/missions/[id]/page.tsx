"use client";

import { useState } from "react";
import { missions, quests, users, proofSubmissions } from "@/lib/data";
import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";
import { useRouter } from "next/navigation";
import { UserAvatar } from "@/components/user-avatar";
import { MissionMembersTab } from "@/components/mission-member-tab";
import { MissionQuestsTab } from "@/components/mission-quests-tab";
import { MissionProofsTab } from "@/components/mission-proofs-tab";
import { toast } from "sonner";

export default function MissionDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const router = useRouter();
  const mission = missions.find((m) => m.id === params.id);
  const [activeTab, setActiveTab] = useState("members");

  if (!mission) {
    return <div className="p-8">Mission not found</div>;
  }

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  return (
    <div className="p-8">
      {/* Page Header */}
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-4">
          <button
            onClick={() => router.back()}
            className="p-2 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-[#6b6b6b]" />
          </button>
          <h1 className="text-3xl font-semibold text-[#1a1a1a]">
            {mission.name}
          </h1>
        </div>
        <Button className="bg-[#1a1a1a] text-white hover:bg-[#333333]">
          Edit mission
        </Button>
      </div>

      {/* Tabs */}
      <div className="flex gap-0 mb-8 border-b border-[#e8e3db]">
        <button
          onClick={() => setActiveTab("members")}
          className={`px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "members"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          Members
        </button>
        <button
          onClick={() => setActiveTab("quests")}
          className={`px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "quests"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          Quests
        </button>
        <button
          onClick={() => setActiveTab("proofs")}
          className={`px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "proofs"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          Proofs
        </button>
      </div>

      {/* Tab Content */}
      {activeTab === "members" && <MissionMembersTab missionId={mission.id} />}
      {activeTab === "quests" && <MissionQuestsTab missionId={mission.id} />}
      {activeTab === "proofs" && <MissionProofsTab missionId={mission.id} />}
    </div>
  );
}
