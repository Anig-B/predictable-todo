"use client";

import { use, useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Loader2, Edit3, Target, Users, ShieldCheck } from "lucide-react";
import { useRouter } from "next/navigation";
import { MissionMembersTab } from "@/components/mission-member-tab";
import { MissionQuestsTab } from "@/components/mission-quests-tab";
import { MissionProofsTab } from "@/components/mission-proofs-tab";
import { toast } from "sonner";

interface Mission {
  id: string;
  name: string;
  description: string | null;
  created_by: string;
  is_active: boolean;
  created_at: string;
}

export default function MissionDetailPage({
  params: paramsPromise,
}: {
  params: Promise<{ id: string }>;
}) {
  const params = use(paramsPromise);
  const router = useRouter();
  const supabase = createClient();

  const [mission, setMission] = useState<Mission | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"members" | "quests" | "proofs">("quests");

  useEffect(() => {
    async function fetchMissionDetail() {
      try {
        setLoading(true);

        const { data, error } = await supabase
          .from("missions")
          .select("*")
          .eq("id", params.id)
          .single();

        if (error) {
          throw error;
        }

        setMission(data);
      } catch (err: any) {
        toast.error(err.message || "Could not load mission details");
      } finally {
        setLoading(false);
      }
    }

    if (params.id) {
      fetchMissionDetail();
    }
  }, [params.id, supabase]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3">
        <Loader2 className="w-8 h-8 animate-spin text-gray-500" />
        <p className="text-sm text-gray-400">Loading mission details...</p>
      </div>
    );
  }

  if (!mission) {
    return (
      <div className="p-8 max-w-xl mx-auto text-center space-y-4">
        <h2 className="text-xl font-semibold text-gray-800">Mission Not Found</h2>
        <p className="text-sm text-gray-500">
          The requested mission pack does not exist or you do not have permission to view it.
        </p>
        <Button
          onClick={() => router.push("/missions")}
          variant="outline"
          className="border-[#e8e3db]"
        >
          Return to Missions
        </Button>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => router.back()}
            className="p-2 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-[#6b6b6b]" />
          </button>
          <div>
            <div className="flex items-center gap-3">
              <h1 className="text-3xl font-semibold text-[#1a1a1a]">
                {mission.name}
              </h1>
              <span
                className={`text-xs px-2.5 py-0.5 rounded-full font-medium ${
                  mission.is_active
                    ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                    : "bg-gray-100 text-gray-600 border border-gray-200"
                }`}
              >
                {mission.is_active ? "Active" : "Archived"}
              </span>
            </div>
            {mission.description && (
              <p className="text-sm text-gray-500 mt-1 max-w-2xl">
                {mission.description}
              </p>
            )}
          </div>
        </div>

        <Button
          onClick={() => toast.info("Mission edit modal trigger")}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333] flex items-center gap-2"
        >
          <Edit3 className="w-4 h-4" />
          Edit Mission
        </Button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-8 border-b border-[#e8e3db]">
        <button
          onClick={() => setActiveTab("quests")}
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "quests"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          <Target className="w-4 h-4" />
          Tasks & Quests
        </button>
        <button
          onClick={() => setActiveTab("members")}
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "members"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          <Users className="w-4 h-4" />
          Members
        </button>
        <button
          onClick={() => setActiveTab("proofs")}
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "proofs"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          <ShieldCheck className="w-4 h-4" />
          Proof Verification
        </button>
      </div>

      {/* Tab Content */}
      <div className="bg-white border border-[#e8e3db] rounded-xl p-6 shadow-xs">
        {activeTab === "quests" && <MissionQuestsTab missionId={mission.id} />}
        {activeTab === "members" && <MissionMembersTab missionId={mission.id} />}
        {activeTab === "proofs" && <MissionProofsTab missionId={mission.id} />}
      </div>
    </div>
  );
}