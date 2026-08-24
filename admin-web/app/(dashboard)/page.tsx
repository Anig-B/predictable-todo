"use client";

import { useEffect, useState } from "react";
import { Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

import StatCards from "@/components/StatCards";
import CompanyActivity from "@/components/CompanyActivity";
import ProofQueue from "@/components/ProofQueue";
import MissionProgressList from "@/components/MissionProgressList";
import TopMembersList from "@/components/TopMembersList";

export default function DashboardPage() {
  const supabase = createClient();
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    async function loadDashboard() {
      try {
        const {
          data: { user },
        } = await supabase.auth.getUser();
        if (!user) return;

        // 1 single RPC call replaces 5+ network waterfalls
        const { data: dashboardData, error } = await supabase.rpc(
          "get_manager_dashboard",
          { p_manager_id: user.id },
        );

        if (error) throw error;
        setData(dashboardData);
      } catch (err) {
        console.error("Dashboard load failed:", err);
      } finally {
        setLoading(false);
      }
    }

    loadDashboard();
  }, [supabase]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-100">
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
          Showing members, missions, and proof queues scoped to your
          organization.
        </p>
      </div>

      <StatCards stats={data?.stats} />

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-8">
        <div className="space-y-8">
          <CompanyActivity activities={data?.activities || []} />
          <ProofQueue proofs={data?.proofs || []} />
        </div>

        <div className="space-y-8">
          <MissionProgressList activeMissions={data?.activeMissions || []} />
          <TopMembersList topMembers={data?.topMembers || []} />
        </div>
      </div>
    </div>
  );
}
