"use client";

import { useEffect, useState } from "react";
import { TrendingUp, Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

interface DashboardStats {
  totalUsers: number;
  newUsersThisWeek: number;
  activeMissionsCount: number;
  archivedMissionsCount: number;
  pendingProofsCount: number;
  totalXpEarned: number;
  xpEarnedToday: number;
}

interface ActivityItem {
  id: string;
  userName: string;
  action: string;
  points?: number;
  missionName?: string;
  timestamp: string;
}

interface ProofItem {
  taskId: string;
  questTitle: string;
  missionName: string;
  userName: string;
}

interface MissionProgress {
  id: string;
  name: string;
  questsDone: number;
  questsTotal: number;
  memberCount: number;
}

interface TopMember {
  id: string;
  name: string;
  level: number;
  streak: number;
  xp: number;
}

export default function DashboardPage() {
  const supabase = createClient();

  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    newUsersThisWeek: 0,
    activeMissionsCount: 0,
    archivedMissionsCount: 0,
    pendingProofsCount: 0,
    totalXpEarned: 0,
    xpEarnedToday: 0,
  });

  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [proofs, setProofs] = useState<ProofItem[]>([]);
  const [activeMissions, setActiveMissions] = useState<MissionProgress[]>([]);
  const [topMembers, setTopMembers] = useState<TopMember[]>([]);

  useEffect(() => {
    fetchCompanyDashboardData();
  }, []);

  const fetchCompanyDashboardData = async () => {
    setLoading(true);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        setLoading(false);
        return;
      }

      const managerId = user.id;
      const now = new Date();
      const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();
      const startOfToday = new Date(now.setHours(0, 0, 0, 0)).toISOString();

      // 1. Fetch Missions created by or managed by this user
      const { data: managerMissionsData } = await supabase
        .from("missions")
        .select("id, name, is_active, tasks(id, done), mission_members(user_id, joined_at)")
        .eq("created_by", managerId);

      const managerMissions = managerMissionsData || [];
      const managedMissionIds = managerMissions.map((m) => m.id);

      const activeCount = managerMissions.filter((m) => m.is_active !== false).length;
      const archivedCount = managerMissions.filter((m) => m.is_active === false).length;

      // 2. Extract Unique Company Members across all managed missions
      const memberJoinedDates = new Map<string, string>();

      managerMissions.forEach((m: any) => {
        (m.mission_members || []).forEach((mem: any) => {
          if (mem.user_id) {
            // Keep the earliest joined date for multi-mission members
            const existingDate = memberJoinedDates.get(mem.user_id);
            if (!existingDate || (mem.joined_at && mem.joined_at < existingDate)) {
              memberJoinedDates.set(mem.user_id, mem.joined_at || "");
            }
          }
        });
      });

      // Always include the manager in their own workspace stats
      if (!memberJoinedDates.has(managerId)) {
        memberJoinedDates.set(managerId, "");
      }

      const uniqueMemberIds = Array.from(memberJoinedDates.keys());

      // 3. Fetch Profile Metadata strictly for these company members
      let companyProfiles: any[] = [];
      if (uniqueMemberIds.length > 0) {
        const { data: profilesData } = await supabase
          .from("profiles")
          .select("id, username, level, streak, xp, created_at")
          .in("id", uniqueMemberIds);

        companyProfiles = profilesData || [];
      }

      const totalUsers = companyProfiles.length;

      // Count new company members added in the last 7 days
      const newUsersThisWeek = companyProfiles.filter((p) => {
        const joinedAt = memberJoinedDates.get(p.id) || p.created_at;
        return joinedAt && joinedAt >= oneWeekAgo;
      }).length;

      // 4. Mission Progress Setup
      const formattedActiveMissions: MissionProgress[] = managerMissions
        .filter((m) => m.is_active !== false)
        .map((m: any) => {
          const taskList = m.tasks || [];
          const completedCount = taskList.filter((t: any) => t.done === true).length;
          return {
            id: m.id,
            name: m.name,
            questsDone: completedCount,
            questsTotal: taskList.length,
            memberCount: m.mission_members?.length || 0,
          };
        });

      // 5. Pending Proofs Queue for managed missions
      let pendingProofsList: ProofItem[] = [];
      if (managedMissionIds.length > 0) {
        const { data: reviewedProofs } = await supabase
          .from("proof_reviews")
          .select("task_id");

        const reviewedTaskIds = new Set((reviewedProofs || []).map((r) => r.task_id));

        const { data: pendingTasksData } = await supabase
          .from("tasks")
          .select("id, title, proof_image, profiles(username), missions:mission_id_fk(name)")
          .in("mission_id_fk", managedMissionIds)
          .not("proof_image", "is", null)
          .neq("proof_image", "");

        pendingProofsList = (pendingTasksData || [])
          .filter((task) => !reviewedTaskIds.has(task.id))
          .map((task: any) => ({
            taskId: task.id,
            questTitle: task.title,
            missionName: task.missions?.name || "Company Quest",
            userName: task.profiles?.username || "Unknown",
          }));
      }

      // 6. Recent Activity Logs for company members
      let formattedActivities: ActivityItem[] = [];
      let totalXp = 0;
      let xpToday = 0;

      if (uniqueMemberIds.length > 0) {
        const { data: activityData } = await supabase
          .from("activity_logs")
          .select("id, task, points, project, created_at, profiles(username)")
          .in("user_id", uniqueMemberIds)
          .order("created_at", { ascending: false })
          .limit(10);

        formattedActivities = (activityData || []).map((act: any) => ({
          id: act.id,
          userName: act.profiles?.username || "Member",
          action: `completed "${act.task}"`,
          points: act.points,
          missionName: act.project !== "General" ? act.project : undefined,
          timestamp: new Date(act.created_at).toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
          }),
        }));

        const { data: xpLogs } = await supabase
          .from("activity_logs")
          .select("points, created_at")
          .in("user_id", uniqueMemberIds);

        (xpLogs || []).forEach((log) => {
          const pts = log.points || 0;
          totalXp += pts;
          if (log.created_at && log.created_at >= startOfToday) {
            xpToday += pts;
          }
        });
      }

      // 7. Company Leaderboard
      const formattedTopMembers: TopMember[] = companyProfiles
        .sort((a, b) => (b.xp || 0) - (a.xp || 0))
        .slice(0, 4)
        .map((p) => ({
          id: p.id,
          name: p.username || "Member",
          level: p.level || 1,
          streak: p.streak || 0,
          xp: p.xp || 0,
        }));

      setStats({
        totalUsers,
        newUsersThisWeek,
        activeMissionsCount: activeCount,
        archivedMissionsCount: archivedCount,
        pendingProofsCount: pendingProofsList.length,
        totalXpEarned: totalXp / 1000,
        xpEarnedToday: xpToday / 1000,
      });

      setTopMembers(formattedTopMembers);
      setActiveMissions(formattedActiveMissions);
      setProofs(pendingProofsList);
      setActivities(formattedActivities);
    } catch (error) {
      console.error("Error fetching company dashboard data:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleProofReview = async (taskId: string, approved: boolean) => {
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) return;

    const { error } = await supabase.from("proof_reviews").insert({
      task_id: taskId,
      reviewed_by: user.id,
      approved,
      feedback: approved ? "Approved by Manager" : "Rejected by Manager",
    });

    if (!error) {
      setProofs((prev) => prev.filter((p) => p.taskId !== taskId));
      setStats((prev) => ({
        ...prev,
        pendingProofsCount: Math.max(0, prev.pendingProofsCount - 1),
      }));
    }
  };

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="w-8 h-8 animate-spin text-gray-500" />
      </div>
    );
  }

  return (
    <div className="p-8 space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-[#1a1a1a]">
          Company Overview
        </h1>
        <p className="text-muted-foreground">
          Showing members, missions, and proof queues scoped to your organization.
        </p>
      </div>

      {/* Stat Cards Grid */}
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
        {/* Scoped Company Members */}
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-[#8b8b8b] mb-1">
                Company Members
              </p>
              <p className="text-3xl font-bold text-[#1a1a1a]">{stats.totalUsers}</p>
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1 text-sm font-medium text-emerald-600">
                <TrendingUp className="w-4 h-4" />
                <span>+{stats.newUsersThisWeek}</span>
              </div>
              <p className="text-xs text-[#8b8b8b]">this week</p>
            </div>
          </div>
        </div>

        {/* Managed Missions */}
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-[#8b8b8b] mb-1">
                Active Missions
              </p>
              <p className="text-3xl font-bold text-[#1a1a1a]">
                {stats.activeMissionsCount}
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs text-muted-foreground font-medium bg-secondary px-2 py-1 rounded">
                {stats.archivedMissionsCount} archived
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
                {stats.pendingProofsCount}
              </p>
            </div>
            <div className="text-right">
              {stats.pendingProofsCount > 0 && (
                <div className="px-2.5 py-1 bg-amber-500 text-white text-xs font-semibold rounded animate-pulse">
                  Needs Review
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Company XP */}
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium text-[#8b8b8b] mb-1">
                Company XP Earned
              </p>
              <p className="text-3xl font-bold text-[#1a1a1a]">
                {stats.totalXpEarned.toFixed(1)}k
              </p>
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1 text-sm font-medium text-emerald-600">
                <TrendingUp className="w-4 h-4" />
                <span>+{stats.xpEarnedToday.toFixed(2)}k</span>
              </div>
              <p className="text-xs text-[#8b8b8b]">today</p>
            </div>
          </div>
        </div>
      </div>

      {/* Content Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-8">
        <div className="space-y-8">
          {/* Company Activity */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Company Activity
            </h2>
            <div className="space-y-4">
              {activities.length === 0 ? (
                <p className="text-xs text-muted-foreground">No activity from company members yet.</p>
              ) : (
                activities.map((activity) => (
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
                ))
              )}
            </div>
          </div>

          {/* Proof Verification Queue */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Proof Verification Queue
            </h2>
            <div className="space-y-4">
              {proofs.length === 0 ? (
                <p className="text-xs text-muted-foreground">No pending proof reviews for your company missions.</p>
              ) : (
                proofs.map((proof) => (
                  <div
                    key={proof.taskId}
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
                      <button
                        onClick={() => handleProofReview(proof.taskId, true)}
                        className="px-2.5 py-1 text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100 rounded transition-colors"
                      >
                        Approve
                      </button>
                      <button
                        onClick={() => handleProofReview(proof.taskId, false)}
                        className="px-2.5 py-1 text-xs font-semibold bg-rose-50 text-rose-700 border border-rose-200 hover:bg-rose-100 rounded transition-colors"
                      >
                        Reject
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        {/* Right Side Column */}
        <div className="space-y-8">
          {/* Mission Progress */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Company Mission Progress
            </h2>
            <div className="space-y-5">
              {activeMissions.length === 0 ? (
                <p className="text-xs text-muted-foreground">No active company missions.</p>
              ) : (
                activeMissions.map((mission) => (
                  <div key={mission.id} className="space-y-2">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-semibold text-[#1a1a1a] truncate max-w-40">
                        {mission.name}
                      </p>
                      <span className="text-xs text-muted-foreground font-medium">
                        {mission.questsDone}/{mission.questsTotal} Done
                      </span>
                    </div>

                    <div className="w-full bg-[#e8e3db] rounded-full h-2">
                      <div
                        className="h-2 rounded-full bg-indigo-600 transition-all duration-300"
                        style={{
                          width: `${Math.min(
                            100,
                            ((mission.questsDone || 0) /
                              (mission.questsTotal || 1)) *
                              100
                          )}%`,
                        }}
                      />
                    </div>
                    <p className="text-xs text-[#8b8b8b]">
                      {mission.memberCount} assigned members
                    </p>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Company Members Leaderboard */}
          <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
              Top Members
            </h2>
            <div className="space-y-4">
              {topMembers.length === 0 ? (
                <p className="text-xs text-muted-foreground">No company members found.</p>
              ) : (
                topMembers.map((user, idx) => (
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
                      {user.xp} XP
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}