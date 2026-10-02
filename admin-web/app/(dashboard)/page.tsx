"use client";

import React, { useEffect, useState, useMemo } from "react";
import { Loader2, LayoutDashboard, RefreshCw } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

import StatCards from "@/components/StatCards";
import CompanyActivity from "@/components/CompanyActivity";
import ProofQueue from "@/components/ProofQueue";
import MissionProgressList from "@/components/MissionProgressList";
import TopMembersList from "@/components/TopMembersList";
import { Button } from "@/components/ui/button";

export default function DashboardPage() {
  const supabase = useMemo(() => createClient(), []);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<{
    stats?: any;
    activities?: any[];
    proofs?: any[];
    activeMissions?: any[];
    topMembers?: any[];
  } | null>(null);

  const loadDashboard = async () => {
    try {
      setLoading(true);
      setError(null);

      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        setError("User authentication required");
        return;
      }

      // 1 single RPC call replaces multiple network waterfalls
      const { data: dashboardData, error: rpcError } = await supabase.rpc(
        "get_manager_dashboard",
        { p_manager_id: user.id },
      );

      if (rpcError) throw rpcError;
      setData(dashboardData);
    } catch (err: any) {
      console.error("Dashboard load failed:", err);
      setError(err?.message || "Failed to load dashboard data");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboard();
  }, [supabase]);

  // Modern Skeleton Loading State
  if (loading) {
    return (
      <div className="p-8 max-w-7xl mx-auto space-y-8 animate-pulse">
        {/* Header Skeleton */}
        <div className="space-y-2 pb-4 border-b border-[#e8e3db]">
          <div className="h-8 bg-[#e8e3db] rounded w-1/4"></div>
          <div className="h-4 bg-[#e8e3db] rounded w-1/3"></div>
        </div>

        {/* Stat Cards Skeleton */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div
              key={i}
              className="h-28 bg-[#e8e3db] rounded-lg border border-[#e8e3db]"
            ></div>
          ))}
        </div>

        {/* Content Skeleton Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-8">
          <div className="space-y-8">
            <div className="h-64 bg-[#e8e3db] rounded-lg"></div>
            <div className="h-80 bg-[#e8e3db] rounded-lg"></div>
          </div>
          <div className="space-y-8">
            <div className="h-64 bg-[#e8e3db] rounded-lg"></div>
            <div className="h-80 bg-[#e8e3db] rounded-lg"></div>
          </div>
        </div>
      </div>
    );
  }

  // Error State Handling
  if (error) {
    return (
      <div className="p-8 max-w-7xl mx-auto min-h-100 flex flex-col items-center justify-center text-center space-y-4">
        <div className="w-12 h-12 rounded-full bg-red-50 text-red-600 flex items-center justify-center border border-red-200">
          <LayoutDashboard className="w-6 h-6" />
        </div>
        <div>
          <h2 className="text-lg font-bold text-[#1a1a1a]">
            Unable to Load Dashboard
          </h2>
          <p className="text-sm text-[#8b8b8b] max-w-sm mt-1">{error}</p>
        </div>
        <Button
          onClick={loadDashboard}
          variant="outline"
          className="border-[#e8e3db] text-[#1a1a1a] hover:bg-[#f8f7f4] flex items-center gap-2 text-xs uppercase tracking-wider font-semibold"
        >
          <RefreshCw className="w-3.5 h-3.5" />
          Try Again
        </Button>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      {/* Page Header */}
      <div className="pb-4 border-b border-[#e8e3db]">
        <h1 className="text-2xl font-bold tracking-tight text-[#1a1a1a]">
          Company Overview
        </h1>
        <p className="text-sm text-[#8b8b8b] mt-1">
          Showing members, missions, and proof queues scoped to your
          organization.
        </p>
      </div>

      {/* Overview Stat Cards */}
      <StatCards stats={data?.stats} />

      {/* Main Content Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-8 items-start">
        {/* Left Column: Activity & Proof Approvals */}
        <div className="space-y-8 min-w-0">
          <CompanyActivity activities={data?.activities || []} />
          <ProofQueue proofs={data?.proofs || []} />
        </div>

        {/* Right Column: Mission Progress & Member Leaderboard */}
        <div className="space-y-8 min-w-0">
          <MissionProgressList activeMissions={data?.activeMissions || []} />
          <TopMembersList topMembers={data?.topMembers || []} />
        </div>
      </div>
    </div>
  );
}
