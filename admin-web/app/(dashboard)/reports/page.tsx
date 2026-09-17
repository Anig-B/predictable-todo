"use client";

import { useEffect, useState, useCallback, useMemo } from "react";
import { Loader2, Users, Target } from "lucide-react";
import { toast } from "sonner";
import {
  getManagerReportsData,
  Timeframe,
  ReportsPayload,
} from "@/actions/reports";

import { UserReportView } from "@/components/reports/UserReportView";
import { MissionReportView } from "@/components/reports/MissionReportView";

type ReportTab = "users" | "missions";

const TIMEFRAME_OPTIONS: Timeframe[] = ["daily", "weekly", "monthly", "all"];

// Shared heatmap styling helper
const getHeatmapBg = (percentage: number) => {
  if (percentage === 0) return "bg-gray-100 text-gray-500 border-gray-200";
  if (percentage < 25)
    return "bg-emerald-50 text-emerald-700 border-emerald-200";
  if (percentage < 50)
    return "bg-emerald-100 text-emerald-800 border-emerald-300";
  if (percentage < 75)
    return "bg-emerald-300 text-emerald-950 border-emerald-400";
  return "bg-emerald-500 text-white border-emerald-600";
};

export default function ReportsPage() {
  const [activeTab, setActiveTab] = useState<ReportTab>("users");
  const [timeframe, setTimeframe] = useState<Timeframe>("weekly");
  const [data, setData] = useState<ReportsPayload | null>(null);
  const [isManager, setIsManager] = useState<boolean>(true);
  const [loading, setLoading] = useState<boolean>(true);

  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [selectedMissionId, setSelectedMissionId] = useState<string | null>(
    null,
  );

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const res = await getManagerReportsData(timeframe);
      setIsManager(res.isManager ?? true);
      setData(res.data);

      if (res.data?.users?.length) {
        const users = res.data.users;
        setSelectedUserId((prev) =>
          prev && users.some((u) => String(u.id) === String(prev))
            ? String(prev)
            : String(users[0].id),
        );
      }

      if (res.data?.missions?.length) {
        const missions = res.data.missions;
        setSelectedMissionId((prev) =>
          prev && missions.some((m) => String(m.id) === String(prev))
            ? String(prev)
            : String(missions[0].id),
        );
      }
    } catch (err: unknown) {
      const error = err as Error;
      toast.error(error?.message || "Failed to load reports data");
    } finally {
      setLoading(false);
    }
  }, [timeframe]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // Derived active selections
  const activeUser = useMemo(() => {
    if (!data?.users?.length) return null;
    return (
      data.users.find((u) => String(u.id) === String(selectedUserId)) ||
      data.users[0]
    );
  }, [data?.users, selectedUserId]);

  const activeMission = useMemo(() => {
    if (!data?.missions?.length) return null;
    return (
      data.missions.find((m) => String(m.id) === String(selectedMissionId)) ||
      data.missions[0]
    );
  }, [data?.missions, selectedMissionId]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-6 h-6 animate-spin text-gray-500" />
      </div>
    );
  }

  if (!isManager || !data) {
    return (
      <div className="p-8 min-h-screen">
        <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
          <p className="text-gray-500 text-sm">
            You do not have access to manager reports or no data is available.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 relative min-h-screen pb-24">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-semibold text-[#1a1a1a]">
            Manager Reports
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Track member performance, mission outputs, and completion metrics.
          </p>
        </div>

        {/* Timeframe Selector */}
        <div className="flex items-center gap-1.5 bg-gray-100/80 p-1 rounded-lg border border-[#e8e3db]">
          {TIMEFRAME_OPTIONS.map((tf) => (
            <button
              key={tf}
              onClick={() => setTimeframe(tf)}
              className={`px-3 py-1.5 text-xs font-medium rounded-md capitalize transition-colors ${
                timeframe === tf
                  ? "bg-white text-[#1a1a1a] shadow-sm"
                  : "text-gray-500 hover:text-[#1a1a1a]"
              }`}
            >
              {tf}
            </button>
          ))}
        </div>
      </div>

      {/* View Switcher Tabs */}
      <div className="flex items-center gap-2 border-b border-[#e8e3db] pb-4 mb-6">
        <button
          onClick={() => setActiveTab("users")}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            activeTab === "users"
              ? "bg-[#1a1a1a] text-white shadow-sm"
              : "bg-white text-gray-600 border border-[#e8e3db] hover:border-gray-400"
          }`}
        >
          <Users className="w-4 h-4" />
          By User
        </button>
        <button
          onClick={() => setActiveTab("missions")}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            activeTab === "missions"
              ? "bg-[#1a1a1a] text-white shadow-sm"
              : "bg-white text-gray-600 border border-[#e8e3db] hover:border-gray-400"
          }`}
        >
          <Target className="w-4 h-4" />
          By Mission
        </button>
      </div>

      {/* Render Active View Component */}
      {activeTab === "users" && activeUser && (
        <UserReportView
          data={data}
          activeUser={activeUser}
          onSelectUser={(id) => setSelectedUserId(id)}
          getHeatmapBg={getHeatmapBg}
        />
      )}

      {activeTab === "missions" && activeMission && (
        <MissionReportView
          data={data}
          activeMission={activeMission}
          onSelectMission={(id) => setSelectedMissionId(id)}
          getHeatmapBg={getHeatmapBg}
        />
      )}
    </div>
  );
}
