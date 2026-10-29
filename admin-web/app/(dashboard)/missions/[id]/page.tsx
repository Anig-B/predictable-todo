"use client";

import { use, useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import {
  ArrowLeft,
  Loader2,
  Target,
  Users,
  ShieldCheck,
  AlertCircle,
} from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { getMissionById, Mission } from "@/actions/missions";
import { MissionTasksSection } from "@/components/missions/MissionTasksSection";
import { MissionMembersSection } from "@/components/missions/MissionMemberSection";
import { MissionProofsSection } from "@/components/missions/MissionProofSection";
export default function MissionDetailPage({
  params: paramsPromise,
}: {
  params: Promise<{ id: string }>;
}) {
  const params = use(paramsPromise);
  const router = useRouter();

  const [mission, setMission] = useState<Mission | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"tasks" | "members" | "proofs">(
    "tasks",
  );

  useEffect(() => {
    async function fetchMissionDetail() {
      try {
        setLoading(true);
        const data = await getMissionById(params.id);
        setMission(data);
      } catch (err: any) {
        toast.error(err?.message || "Could not load mission details");
      } finally {
        setLoading(false);
      }
    }

    if (params.id) {
      fetchMissionDetail();
    }
  }, [params.id]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3">
        <Loader2 className="w-8 h-8 animate-spin text-[#1a1a1a]" />
        <p className="text-xs font-medium text-[#8b8b8b] uppercase tracking-wider">
          Loading mission details...
        </p>
      </div>
    );
  }

  if (!mission) {
    return (
      <div className="p-8 max-w-lg mx-auto my-12 text-center space-y-4 bg-[#fafaf8] border border-[#e8e3db] rounded-lg shadow-xs">
        <div className="p-3 w-fit mx-auto rounded-full bg-amber-50 text-amber-600 border border-amber-200">
          <AlertCircle className="w-6 h-6" />
        </div>
        <div className="space-y-1">
          <h2 className="text-base font-bold text-[#1a1a1a]">
            Mission Pack Not Found
          </h2>
          <p className="text-xs text-[#8b8b8b]">
            The requested mission pack does not exist or you do not have
            permission to access it.
          </p>
        </div>
        <Button
          onClick={() => router.push("/missions")}
          variant="outline"
          className="border-[#e8e3db] text-[#1a1a1a] hover:bg-[#f8f7f4] text-xs uppercase font-semibold tracking-wider cursor-pointer mt-2"
        >
          Return to Missions
        </Button>
      </div>
    );
  }

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto space-y-6">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-2 border-b border-[#e8e3db]">
        <div className="flex items-start gap-3.5">
          <button
            type="button"
            onClick={() => router.back()}
            className="p-2 mt-0.5 hover:bg-[#e8e3db]/60 text-[#8b8b8b] hover:text-[#1a1a1a] rounded-md transition-colors cursor-pointer"
            title="Go back"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div className="space-y-1">
            <div className="flex items-center gap-3 flex-wrap">
              <h1 className="text-2xl font-bold text-[#1a1a1a] tracking-tight">
                {mission.name}
              </h1>
              <span
                className={`text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded border ${
                  mission.is_active
                    ? "bg-emerald-50 text-emerald-800 border-emerald-200"
                    : "bg-[#f8f7f4] text-[#8b8b8b] border-[#e8e3db]"
                }`}
              >
                {mission.is_active ? "Active Pack" : "Archived"}
              </span>
            </div>
            {mission.description && (
              <p className="text-xs text-[#8b8b8b] max-w-2xl leading-relaxed">
                {mission.description}
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="flex gap-1 border-b border-[#e8e3db] overflow-x-auto">
        <button
          type="button"
          onClick={() => setActiveTab("tasks")}
          className={`flex items-center gap-2 px-4 py-3 text-xs font-bold uppercase tracking-wider border-b-2 transition-all cursor-pointer whitespace-nowrap ${
            activeTab === "tasks"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#1a1a1a]"
          }`}
        >
          <Target className="w-4 h-4" />
          Tasks
        </button>
        <button
          type="button"
          onClick={() => setActiveTab("members")}
          className={`flex items-center gap-2 px-4 py-3 text-xs font-bold uppercase tracking-wider border-b-2 transition-all cursor-pointer whitespace-nowrap ${
            activeTab === "members"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#1a1a1a]"
          }`}
        >
          <Users className="w-4 h-4" />
          Members
        </button>
        <button
          type="button"
          onClick={() => setActiveTab("proofs")}
          className={`flex items-center gap-2 px-4 py-3 text-xs font-bold uppercase tracking-wider border-b-2 transition-all cursor-pointer whitespace-nowrap ${
            activeTab === "proofs"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#1a1a1a]"
          }`}
        >
          <ShieldCheck className="w-4 h-4" />
          Proof Verification
        </button>
      </div>

      {/* Dynamic Section Content */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-xs">
        {activeTab === "tasks" && (
          <MissionTasksSection missionId={mission.id} />
        )}
        {activeTab === "members" && (
          <MissionMembersSection missionId={mission.id} />
        )}
        {activeTab === "proofs" && (
          <MissionProofsSection missionId={mission.id} />
        )}
      </div>
    </div>
  );
}
