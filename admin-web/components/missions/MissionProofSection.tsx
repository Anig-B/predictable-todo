"use client";

import { useEffect, useState, useCallback, useMemo } from "react";
import { createClient } from "@/lib/supabase/client";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";

import { ProofTask } from "@/actions/proofs";
import { ProofCard } from "@/components/proofs/ProofCard";
import { HistoryCard } from "@/components/proofs/HistoryCard";

export function MissionProofsSection({ missionId }: { missionId: string }) {
  const supabase = useMemo(() => createClient(), []);

  const [tasks, setTasks] = useState<ProofTask[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"needs_review" | "history">(
    "needs_review",
  );
  const [submitting, setSubmitting] = useState(false);

  const fetchProofs = useCallback(async () => {
    try {
      setLoading(true);

      const { data, error } = await supabase
        .from("tasks")
        .select(
          `
          id,
          user_id,
          title,
          desc,
          points,
          proof_notes,
          proof_image,
          created_at,
          done,
          profiles:user_id (
            username,
            avatar_url
          ),
          proof_reviews (
            id,
            approved,
            feedback,
            reviewed_at
          )
        `,
        )
        .eq("mission_id_fk", missionId)
        .order("created_at", { ascending: false });

      if (error) throw error;
      setTasks((data as unknown as ProofTask[]) || []);
    } catch (err: any) {
      toast.error(err?.message || "Failed to load proof submissions");
    } finally {
      setLoading(false);
    }
  }, [missionId, supabase]);

  useEffect(() => {
    fetchProofs();
  }, [fetchProofs]);

  const handleReview = async (
    task: ProofTask,
    approved: boolean,
    feedback: string,
  ) => {
    try {
      setSubmitting(true);
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) throw new Error("Authenticated user required");

      const currentFeedback = feedback.trim() || null;

      if (approved) {
        const { error: reviewErr } = await supabase
          .from("proof_reviews")
          .insert({
            task_id: task.id,
            reviewed_by: user.id,
            approved: true,
            feedback: currentFeedback,
          });
        if (reviewErr) throw reviewErr;

        const { error: taskErr } = await supabase
          .from("tasks")
          .update({ done: true })
          .eq("id", task.id);
        if (taskErr) throw taskErr;

        const { data: profile } = await supabase
          .from("profiles")
          .select("xp")
          .eq("id", task.user_id)
          .single();

        if (profile) {
          await supabase
            .from("profiles")
            .update({ xp: (profile.xp || 0) + task.points })
            .eq("id", task.user_id);
        }

        const { data: stats } = await supabase
          .from("user_stats")
          .select("xp, total_lifetime_tasks")
          .eq("user_id", task.user_id)
          .single();

        if (stats) {
          await supabase
            .from("user_stats")
            .update({
              xp: (stats.xp || 0) + task.points,
              total_lifetime_tasks: (stats.total_lifetime_tasks || 0) + 1,
            })
            .eq("user_id", task.user_id);
        }

        await supabase.from("activity_logs").insert({
          user_id: task.user_id,
          task: task.title,
          points: task.points,
          time: new Date().toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
          }),
          icon: "ShieldCheck",
          task_id: task.id,
          image_url: task.proof_image,
        });

        toast.success(`Proof approved! ${task.points} XP awarded.`);
      } else {
        const { error: reviewErr } = await supabase
          .from("proof_reviews")
          .insert({
            task_id: task.id,
            reviewed_by: user.id,
            approved: false,
            feedback: currentFeedback,
          });
        if (reviewErr) throw reviewErr;

        const { error: resetErr } = await supabase
          .from("tasks")
          .update({
            proof_image: null,
            proof_notes: null,
            done: false,
          })
          .eq("id", task.id);

        if (resetErr) throw resetErr;

        toast.error("Proof rejected. Task reset for re-submission.");
      }

      fetchProofs();
    } catch (err: any) {
      toast.error(err?.message || "Failed to process review");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center p-12 gap-3">
        <Loader2 className="w-6 h-6 animate-spin text-muted-foreground" />
        <p className="text-sm text-muted-foreground">Loading proof inbox...</p>
      </div>
    );
  }

  const pendingTasks = tasks.filter((t) => !t.done && t.proof_image !== null);
  const reviewedTasks = tasks.filter(
    (t) => t.proof_reviews && t.proof_reviews.length > 0,
  );

  return (
    <div className="w-full space-y-6 text-foreground font-sans">
      <div className="space-y-4 border-b border-border/40 pb-4">
        <div>
          <h2 className="text-xl font-bold tracking-tight text-foreground">
            Proof inbox
          </h2>
          <p className="text-sm text-muted-foreground mt-0.5">
            Make a quick, fair decision on every submission.
          </p>
        </div>

        <div className="flex items-center gap-6 pt-2">
          <button
            onClick={() => setActiveTab("needs_review")}
            className={`flex items-center gap-2 pb-2 text-sm font-medium border-b-2 transition-colors ${
              activeTab === "needs_review"
                ? "border-primary text-foreground"
                : "border-transparent text-muted-foreground hover:text-foreground"
            }`}
          >
            Needs review
            <span className="px-2 py-0.5 text-xs rounded-full bg-muted text-foreground font-semibold">
              {pendingTasks.length}
            </span>
          </button>
          <button
            onClick={() => setActiveTab("history")}
            className={`flex items-center gap-2 pb-2 text-sm font-medium border-b-2 transition-colors ${
              activeTab === "history"
                ? "border-primary text-foreground"
                : "border-transparent text-muted-foreground hover:text-foreground"
            }`}
          >
            Review history
            <span className="px-2 py-0.5 text-xs rounded-full bg-muted text-foreground font-semibold">
              {reviewedTasks.length}
            </span>
          </button>
        </div>
      </div>

      {activeTab === "needs_review" ? (
        <div className="space-y-4">
          {pendingTasks.length === 0 ? (
            <div className="text-center py-12 border border-dashed rounded-xl border-border">
              <h4 className="text-sm font-medium text-foreground">
                No Pending Proofs
              </h4>
              <p className="text-xs text-muted-foreground mt-1">
                All submissions have been reviewed.
              </p>
            </div>
          ) : (
            pendingTasks.map((task) => (
              <ProofCard
                key={task.id}
                task={task}
                submitting={submitting}
                onReview={handleReview}
              />
            ))
          )}
        </div>
      ) : (
        <div className="space-y-4">
          {reviewedTasks.length === 0 ? (
            <div className="text-center py-12 border border-dashed rounded-xl border-border">
              <h4 className="text-sm font-medium text-foreground">
                No Review History
              </h4>
              <p className="text-xs text-muted-foreground mt-1">
                Completed and rejected decisions will appear here.
              </p>
            </div>
          ) : (
            reviewedTasks.map((t) =>
              t.proof_reviews.map((rev) => (
                <HistoryCard key={rev.id} task={t} review={rev} />
              )),
            )
          )}
        </div>
      )}
    </div>
  );
}
