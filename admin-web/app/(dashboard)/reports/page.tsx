"use client";

import { useEffect, useState, useCallback } from "react";
import {
  Loader2,
  BarChart3,
  Clock,
  CheckCircle2,
  AlertCircle,
  FileText,
  Users,
  Target,
} from "lucide-react";
import { toast } from "sonner";
import {
  getManagerReportsData,
  Timeframe,
  ReportsPayload,
} from "@/actions/reports";

type ReportViewType = "users" | "missions";

export default function ReportsPage() {
  const [reportType, setReportType] = useState<ReportViewType>("users");
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
    } catch (err: any) {
      toast.error(err?.message || "Failed to load reports data");
    } finally {
      setLoading(false);
    }
  }, [timeframe]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
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

  // Active User Selection
  const activeUser =
    data.users.find((u) => String(u.id) === String(selectedUserId)) ||
    data.users[0];
  const activeUserId = activeUser ? String(activeUser.id) : null;

  // Active Mission Selection
  const activeMission =
    data.missions.find((m) => String(m.id) === String(selectedMissionId)) ||
    data.missions[0];
  const activeMissionId = activeMission ? String(activeMission.id) : null;

  // Data lookups for Selected User
  const userStats =
    activeUserId && data.completionStats
      ? data.completionStats[activeUserId] || null
      : null;

  const rawUserActivities =
    activeUserId && data.activities ? data.activities[activeUserId] || [] : [];

  const selectedUserMissionIds =
    activeUserId && data.userAssignedMissionIds
      ? data.userAssignedMissionIds[activeUserId] || []
      : [];

  const assignedMissions = data.missions
    ? data.missions.filter((m) =>
        selectedUserMissionIds.map(String).includes(String(m.id)),
      )
    : [];

  // Data lookups for Selected Mission
  const activeMissionMembers =
    activeMissionId && data.missionMembers
      ? data.missionMembers[activeMissionId] || []
      : [];

  return (
    <div className="p-8 relative min-h-screen pb-24">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-semibold text-[#1a1a1a]">
            Manager Reports
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Track operational progress, member output, and mission outcomes.
          </p>
        </div>

        {/* Timeframe Selector */}
        <div className="flex items-center gap-1.5 bg-gray-100/80 p-1 rounded-lg border border-[#e8e3db]">
          {(["daily", "weekly", "monthly", "all"] as Timeframe[]).map((tf) => (
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

      {/* Report View Mode Switcher */}
      <div className="flex items-center gap-2 border-b border-[#e8e3db] pb-4 mb-6">
        <button
          onClick={() => setReportType("users")}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            reportType === "users"
              ? "bg-[#1a1a1a] text-white shadow-sm"
              : "bg-white text-gray-600 border border-[#e8e3db] hover:border-gray-400"
          }`}
        >
          <Users className="w-4 h-4" />
          By Member
        </button>
        <button
          onClick={() => setReportType("missions")}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            reportType === "missions"
              ? "bg-[#1a1a1a] text-white shadow-sm"
              : "bg-white text-gray-600 border border-[#e8e3db] hover:border-gray-400"
          }`}
        >
          <Target className="w-4 h-4" />
          By Mission
        </button>
      </div>

      {/* VIEW 1: BY MEMBER */}
      {reportType === "users" && (
        <>
          {/* User Tabs */}
          <div className="flex items-center gap-2 overflow-x-auto pb-2 w-full mb-6">
            {data.users.map((u) => {
              const userIdStr = String(u.id);
              const isSelected = activeUserId === userIdStr;
              return (
                <button
                  key={userIdStr}
                  onClick={() => setSelectedUserId(userIdStr)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium border transition-all whitespace-nowrap ${
                    isSelected
                      ? "bg-[#1a1a1a] text-white border-[#1a1a1a]"
                      : "bg-white text-gray-600 border-[#e8e3db] hover:border-gray-400"
                  }`}
                >
                  {u.name || (u as any).username || "Unknown User"}
                </button>
              );
            })}
          </div>

          {/* Metric Cards */}
          {userStats && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
              <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Completion Rate
                  </span>
                  <BarChart3 className="w-4 h-4 text-gray-400" />
                </div>
                <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">
                  {userStats.rate ?? 0}%
                </p>
              </div>

              <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Completed Tasks
                  </span>
                  <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                </div>
                <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">
                  {userStats.done ?? 0} / {userStats.total ?? 0}
                </p>
              </div>

              <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Pending Review
                  </span>
                  <AlertCircle className="w-4 h-4 text-amber-500" />
                </div>
                <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">
                  {userStats.pending ?? 0}
                </p>
              </div>

              <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total Logs
                  </span>
                  <Clock className="w-4 h-4 text-gray-400" />
                </div>
                <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">
                  {rawUserActivities.length}
                </p>
              </div>
            </div>
          )}

          {/* Member Details Section */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2 border border-[#e8e3db] rounded-xl bg-white p-6">
              <div className="flex items-center justify-between mb-6">
                <div>
                  <h2 className="text-lg font-semibold text-[#1a1a1a]">
                    Recent Activity Logs
                  </h2>
                  <p className="text-sm text-gray-500 mt-0.5">
                    Detailed task history for{" "}
                    <span className="font-medium text-gray-800">
                      {activeUser?.name || "Selected User"}
                    </span>
                    .
                  </p>
                </div>
                <span className="text-xs font-medium px-2.5 py-1 bg-gray-100 text-gray-600 rounded-md capitalize">
                  {timeframe} view
                </span>
              </div>

              {rawUserActivities.length === 0 ? (
                <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
                  <FileText className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                  <p className="text-gray-500 text-sm font-medium">
                    No activity recorded for this timeframe.
                  </p>
                  <p className="text-gray-400 text-xs mt-1">
                    Try selecting "all" or choosing another timeframe filter.
                  </p>
                </div>
              ) : (
                <div className="space-y-3">
                  {rawUserActivities.map((act: any, idx: number) => {
                    const taskTitle = act.task || act.title || "Untitled Task";
                    const projectTitle = act.project || "General";
                    const points = act.points ?? act.xp;
                    const timeString = act.timestamp || act.time || "Recent";

                    return (
                      <div
                        key={act.id || `act-${idx}`}
                        className="flex items-center justify-between p-3.5 border border-[#e8e3db] rounded-lg hover:border-gray-300 transition-colors"
                      >
                        <div>
                          <p className="text-sm font-medium text-[#1a1a1a]">
                            {taskTitle}
                          </p>
                          <p className="text-xs text-gray-500 mt-0.5">
                            {projectTitle} • {timeString}
                          </p>
                        </div>
                        {points !== undefined && points !== null && (
                          <span className="text-xs font-semibold px-2.5 py-1 bg-gray-100 text-[#1a1a1a] rounded-full">
                            +{points} XP
                          </span>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            <div className="border border-[#e8e3db] rounded-xl bg-white p-6">
              <h2 className="text-lg font-semibold text-[#1a1a1a]">
                Assigned Missions
              </h2>
              <p className="text-sm text-gray-500 mt-1 mb-6">
                Active mission packs assigned to{" "}
                <span className="font-medium text-gray-800">
                  {activeUser?.name || "Selected User"}
                </span>
                .
              </p>

              {assignedMissions.length === 0 ? (
                <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
                  <p className="text-gray-500 text-sm font-medium">
                    No active missions assigned to this user.
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  {assignedMissions.map((m: any) => {
                    const total = m.tasksTotal ?? 0;
                    const done = m.tasksDone ?? 0;
                    const xp = m.xpEarned ?? 0;
                    const progressPct =
                      total > 0 ? Math.round((done / total) * 100) : 0;

                    return (
                      <div
                        key={m.id}
                        className="p-3.5 border border-[#e8e3db] rounded-lg"
                      >
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-sm font-medium text-[#1a1a1a]">
                            {m.name}
                          </span>
                          <span className="text-xs text-gray-500 font-medium">
                            {xp} XP
                          </span>
                        </div>
                        <div className="w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
                          <div
                            className="bg-[#1a1a1a] h-full rounded-full transition-all duration-300"
                            style={{ width: `${progressPct}%` }}
                          />
                        </div>
                        <p className="text-xs text-gray-500 mt-2">
                          {done} of {total} tasks completed
                        </p>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </>
      )}

      {/* VIEW 2: BY MISSION */}
      {reportType === "missions" && (
        <>
          {/* Mission Tabs */}
          <div className="flex items-center gap-2 overflow-x-auto pb-2 w-full mb-6">
            {data.missions.map((m) => {
              const missionIdStr = String(m.id);
              const isSelected = activeMissionId === missionIdStr;
              return (
                <button
                  key={missionIdStr}
                  onClick={() => setSelectedMissionId(missionIdStr)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium border transition-all whitespace-nowrap ${
                    isSelected
                      ? "bg-[#1a1a1a] text-white border-[#1a1a1a]"
                      : "bg-white text-gray-600 border-[#e8e3db] hover:border-gray-400"
                  }`}
                >
                  {m.name}
                </button>
              );
            })}
          </div>

          {/* Mission Metric Cards */}
          {activeMission && (
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
              <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total Tasks
                  </span>
                  <BarChart3 className="w-4 h-4 text-gray-400" />
                </div>
                <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">
                  {activeMission.tasksTotal}
                </p>
              </div>

              <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Completed Tasks
                  </span>
                  <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                </div>
                <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">
                  {activeMission.tasksDone} / {activeMission.tasksTotal}
                </p>
              </div>

              <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total XP Earned
                  </span>
                  <Clock className="w-4 h-4 text-gray-400" />
                </div>
                <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">
                  {activeMission.xpEarned} XP
                </p>
              </div>
            </div>
          )}

          {/* Member Breakdown Table for Selected Mission */}
          <div className="border border-[#e8e3db] rounded-xl bg-white p-6">
            <h2 className="text-lg font-semibold text-[#1a1a1a]">
              Member Progress for {activeMission?.name}
            </h2>
            <p className="text-sm text-gray-500 mt-0.5 mb-6">
              Individual contributions and task outputs under this mission pack.
            </p>

            {activeMissionMembers.length === 0 ? (
              <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
                <p className="text-gray-500 text-sm font-medium">
                  No members assigned to this mission.
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {activeMissionMembers.map((mem: any, idx: number) => {
                  const progressPct =
                    mem.assigned > 0
                      ? Math.round((mem.done / mem.assigned) * 100)
                      : 0;

                  return (
                    <div
                      key={idx}
                      className="p-4 border border-[#e8e3db] rounded-lg flex items-center justify-between gap-4"
                    >
                      <div className="w-1/3">
                        <p className="text-sm font-semibold text-[#1a1a1a]">
                          {mem.name}
                        </p>
                        <p className="text-xs text-gray-500 mt-0.5">
                          {mem.done} of {mem.assigned} tasks done
                        </p>
                      </div>

                      <div className="w-1/3">
                        <div className="flex items-center justify-between text-xs text-gray-500 mb-1">
                          <span>Completion</span>
                          <span>{progressPct}%</span>
                        </div>
                        <div className="w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
                          <div
                            className="bg-[#1a1a1a] h-full rounded-full transition-all duration-300"
                            style={{ width: `${progressPct}%` }}
                          />
                        </div>
                      </div>

                      <div className="text-right w-1/4">
                        <span className="text-xs font-semibold px-3 py-1 bg-gray-100 text-[#1a1a1a] rounded-full">
                          {mem.xp} XP
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}
