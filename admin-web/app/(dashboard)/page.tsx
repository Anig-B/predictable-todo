"use client";

import { TrendingUp } from "lucide-react";
import { users, missions, activities, proofSubmissions } from "@/lib/data";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function DashboardPage() {
  // Compute reactive states directly from mock data structures
  const totalUsers = users?.length || 0;
  const newUsersThisWeek = 3;
  const activeMissions = missions?.filter((m) => m.active).length || 0;
  const archivedMissions = missions?.filter((m) => !m.active).length || 0;
  const pendingProofs =
    proofSubmissions?.filter((p) => p.status === "pending").length || 0;
  const totalXpEarned = 48.2;
  const xpEarnedToday = 0.84;

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  return (
    <div className="p-8 space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-[#1a1a1a]">
          Dashboard
        </h1>
        <p className="text-muted-foreground">
          Tracking live execution state and proof verifications.
        </p>
      </div>

      {/* Stat Cards Grid */}
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
        {/* Total Users */}
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-[#8b8b8b] mb-1">
                Total Users
              </p>
              <p className="text-3xl font-bold text-[#1a1a1a]">{totalUsers}</p>
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1 text-sm font-medium text-emerald-600">
                <TrendingUp className="w-4 h-4" />
                <span>+{newUsersThisWeek}</span>
              </div>
              <p className="text-xs text-[#8b8b8b]">this week</p>
            </div>
          </div>
        </div>

        {/* Active Missions */}
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-[#8b8b8b] mb-1">
                Active Missions
              </p>
              <p className="text-3xl font-bold text-[#1a1a1a]">
                {activeMissions}
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs text-muted-foreground font-medium bg-secondary px-2 py-1 rounded">
                {archivedMissions} archived
              </p>
            </div>
          </div>
        </div>

        {/* Pending Proofs */}
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-[#8b8b8b] mb-1">
                Pending Proofs
              </p>
              <p className="text-3xl font-bold text-[#1a1a1a]">
                {pendingProofs}
              </p>
            </div>
            <div className="text-right">
              <div className="px-2.5 py-1 bg-amber-500 text-white text-xs font-semibold rounded animate-pulse">
                Needs Review
              </div>
            </div>
          </div>
        </div>

        {/* Total XP */}
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-[#8b8b8b] mb-1">
                Total XP Earned
              </p>
              <p className="text-3xl font-bold text-[#1a1a1a]">
                {totalXpEarned.toFixed(1)}k
              </p>
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1 text-sm font-medium text-emerald-600">
                <TrendingUp className="w-4 h-4" />
                <span>+{xpEarnedToday.toFixed(2)}k</span>
              </div>
              <p className="text-xs text-[#8b8b8b]">today</p>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content - Two Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-8">
        {/* Left Column */}
        <div className="space-y-8">
          {/* Recent Activity */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Recent Activity
            </h2>
            <div className="space-y-4">
              {activities?.map((activity) => (
                <div
                  key={activity.id}
                  className="flex items-start gap-4 pb-4 border-b border-[#e8e3db] last:border-0 last:pb-0"
                >
                  <div className="w-8 h-8 rounded-full bg-primary/10 text-primary font-bold text-xs flex items-center justify-center shrink-0">
                    {getInitials(activity.userName)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-[#1a1a1a]">
                      <span className="font-semibold">{activity.userName}</span>{" "}
                      {activity.action}
                      {activity.points && (
                        <span className="font-semibold text-emerald-600">
                          {" "}
                          +{activity.points} XP
                        </span>
                      )}
                    </p>
                    <div className="flex items-center gap-2 mt-1">
                      {activity.missionName && (
                        <p className="text-xs text-muted-foreground">
                          {activity.missionName}
                        </p>
                      )}
                      <p className="text-xs text-[#8b8b8b]">
                        {activity.timestamp}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Pending Proofs Preview */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Proof Verification Queue
            </h2>
            <div className="space-y-4">
              {proofSubmissions
                ?.filter((p) => p.status === "pending")
                .map((proof) => (
                  <div
                    key={proof.id}
                    className="flex items-center justify-between pb-4 border-b border-[#e8e3db] last:border-0 last:pb-0"
                  >
                    <div className="flex items-center gap-3 flex-1 min-w-0">
                      <div className="w-8 h-8 rounded-full bg-amber-500/10 text-amber-600 font-bold text-xs flex items-center justify-center shrink-0">
                        {getInitials(proof.userName)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold text-[#1a1a1a] truncate">
                          {proof.questTitle}
                        </p>
                        <p className="text-xs text-muted-foreground truncate">
                          {proof.missionName} • By {proof.userName}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <button className="px-2.5 py-1 text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100 rounded transition-colors">
                        Approve
                      </button>
                      <button className="px-2.5 py-1 text-xs font-semibold bg-rose-50 text-rose-700 border border-rose-200 hover:bg-rose-100 rounded transition-colors">
                        Reject
                      </button>
                    </div>
                  </div>
                ))}
            </div>
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-8">
          {/* Active Missions Status */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Active Mission Progress
            </h2>
            <div className="space-y-5">
              {missions
                ?.filter((m) => m.active)
                .map((mission) => (
                  <div key={mission.id} className="space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div
                          className="w-2.5 h-2.5 rounded-full"
                          style={{
                            backgroundColor: mission.color || "#6366f1",
                          }}
                        />
                        <p className="text-sm font-semibold text-[#1a1a1a] truncate max-w-40">
                          {mission.name}
                        </p>
                      </div>
                      <span className="text-xs text-muted-foreground font-medium">
                        {mission.questsDone}/{mission.questsTotal} Done
                      </span>
                    </div>

                    <div className="w-full bg-[#e8e3db] rounded-full h-2">
                      <div
                        className="h-2 rounded-full transition-all duration-300"
                        style={{
                          backgroundColor: mission.color || "#6366f1",
                          width: `${Math.min(100, ((mission.questsDone || 0) / (mission.questsTotal || 1)) * 100)}%`,
                        }}
                      />
                    </div>
                    <p className="text-xs text-[#8b8b8b]">
                      {mission.memberCount || 0} active adventurers
                    </p>
                  </div>
                ))}
            </div>
          </div>

          {/* Top Leaderboard Members */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Top Members
            </h2>
            <div className="space-y-4">
              {[...(users || [])]
                .sort((a, b) => (b.weeklyXp || 0) - (a.weeklyXp || 0))
                .slice(0, 4)
                .map((user, idx) => (
                  <div
                    key={user.id}
                    className="flex items-center justify-between pb-3 border-b border-[#e8e3db] last:border-0 last:pb-0 text-sm"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <span className="font-bold text-muted-foreground w-4">
                        {idx + 1}
                      </span>
                      <div className="w-8 h-8 rounded-full bg-slate-100 font-bold text-xs flex items-center justify-center shrink-0">
                        {getInitials(user.name)}
                      </div>
                      <div className="min-w-0">
                        <p className="font-semibold text-[#1a1a1a] truncate">
                          {user.name}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          Lvl {user.level} • {user.streak}d streak
                        </p>
                      </div>
                    </div>
                    <span className="font-bold text-primary shrink-0">
                      {user.weeklyXp} XP
                    </span>
                  </div>
                ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
