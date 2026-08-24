"use client";

import { useEffect, useState, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import {
  ShieldCheck,
  Loader2,
  CheckCircle2,
  XCircle,
  Clock,
  ExternalLink,
  MessageSquare,
} from "lucide-react";
import { toast } from "sonner";

interface ProofTask {
  id: string;
  user_id: string;
  title: string;
  desc: string | null;
  points: number;
  proof_notes: string | null;
  proof_image: string | null;
  created_at: string;
  profiles: {
    username: string;
    avatar_url: string | null;
  } | null;
  proof_reviews: Array<{
    id: string;
    approved: boolean | null;
    feedback: string | null;
    reviewed_at: string;
  }>;
}

export function MissionProofsSection({ missionId }: { missionId: string }) {
  const supabase = createClient();
  const [tasks, setTasks] = useState<ProofTask[]>([]);
  const [loading, setLoading] = useState(true);
  const [reviewingId, setReviewingId] = useState<string | null>(null);
  const [feedback, setFeedback] = useState<string>("");
  const [submitting, setSubmitting] = useState(false);

  const fetchProofs = useCallback(async () => {
    try {
      setLoading(true);

      // Fetch tasks with proof_image attached that haven't been approved yet
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
        .eq("done", false)
        .not("proof_image", "is", null)
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

  const handleReview = async (task: ProofTask, approved: boolean) => {
    try {
      setSubmitting(true);
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) throw new Error("Authenticated user required");

      if (approved) {
        // 1. Record the approved review
        const { error: reviewErr } = await supabase
          .from("proof_reviews")
          .insert({
            task_id: task.id,
            reviewed_by: user.id,
            approved: true,
            feedback: feedback.trim() || null,
          });
        if (reviewErr) throw reviewErr;

        // 2. Mark task as done
        const { error: taskErr } = await supabase
          .from("tasks")
          .update({ done: true })
          .eq("id", task.id);
        if (taskErr) throw taskErr;

        // 3. Award XP to user's profile
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

        // 4. Update user_stats XP
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

        // 5. Create activity log
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

        toast.success(`Proof approved! ${task.points} XP awarded to user.`);
      } else {
        // 1. Record the rejected review feedback
        await supabase.from("proof_reviews").insert({
          task_id: task.id,
          reviewed_by: user.id,
          approved: false,
          feedback: feedback.trim() || null,
        });

        // 2. Clear proof details from task so it remains undone & allows resubmission
        const { error: resetErr } = await supabase
          .from("tasks")
          .update({
            proof_image: null,
            proof_notes: null,
            done: false,
          })
          .eq("id", task.id);

        if (resetErr) throw resetErr;

        toast.error("Proof rejected. Task reset for member re-submission.");
      }

      setReviewingId(null);
      setFeedback("");

      // Refresh list (removes completed/rejected item from current view)
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
        <Loader2 className="w-6 h-6 animate-spin text-gray-400" />
        <p className="text-sm text-gray-400">
          Loading pending proof submissions...
        </p>
      </div>
    );
  }

  if (tasks.length === 0) {
    return (
      <div className="text-center py-12 border border-dashed rounded-lg border-gray-200">
        <ShieldCheck className="w-10 h-10 text-gray-300 mx-auto mb-2" />
        <h4 className="text-sm font-medium text-gray-600">No Pending Proofs</h4>
        <p className="text-xs text-gray-400 mt-1">
          All submissions have been reviewed or no active proof submissions
          exist.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-800">
          Pending Proof Verifications ({tasks.length})
        </h3>
      </div>

      <div className="grid gap-4">
        {tasks.map((task) => (
          <div
            key={task.id}
            className="border border-[#e8e3db] rounded-xl p-5 bg-[#fafaf9] space-y-4"
          >
            <div className="flex items-start justify-between gap-4">
              <div className="space-y-1">
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="font-semibold text-[#1a1a1a]">
                    {task.title}
                  </span>
                  <span className="text-[10px] bg-black text-white px-2 py-0.5 rounded font-bold">
                    {task.points} XP
                  </span>
                  <span className="inline-flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-full font-medium bg-amber-50 text-amber-700 border border-amber-200">
                    <Clock className="w-3 h-3" /> Awaiting Review
                  </span>
                </div>
                <p className="text-xs text-gray-500">
                  Submitted by:{" "}
                  <span className="font-medium text-gray-700">
                    {task.profiles?.username || "Unknown"}
                  </span>
                </p>
              </div>

              {task.proof_image && (
                <a
                  href={task.proof_image}
                  target="_blank"
                  rel="noreferrer"
                  className="flex items-center gap-1 text-xs text-blue-600 hover:underline shrink-0"
                >
                  View Full Image <ExternalLink className="w-3 h-3" />
                </a>
              )}
            </div>

            {/* Proof Image Preview & Notes */}
            <div className="grid md:grid-cols-2 gap-4 pt-2">
              {task.proof_image && (
                <div className="relative aspect-video bg-gray-100 rounded-lg overflow-hidden border border-gray-200">
                  <img
                    src={task.proof_image}
                    alt="Proof Attachment"
                    className="w-full h-full object-cover"
                  />
                </div>
              )}
              <div className="space-y-2">
                {task.proof_notes ? (
                  <div className="p-3 bg-white border border-gray-200 rounded-lg text-xs text-gray-600">
                    <span className="font-medium text-gray-800 block mb-1">
                      Member Notes:
                    </span>
                    {task.proof_notes}
                  </div>
                ) : (
                  <p className="text-xs italic text-gray-400">
                    No notes provided with submission.
                  </p>
                )}
              </div>
            </div>

            {/* Review Controls */}
            <div className="pt-2 border-t border-gray-200">
              {reviewingId === task.id ? (
                <div className="space-y-3">
                  <textarea
                    value={feedback}
                    onChange={(e) => setFeedback(e.target.value)}
                    placeholder="Add optional feedback (e.g., reason for rejection or approval note)..."
                    className="w-full text-xs p-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-1 focus:ring-black"
                    rows={2}
                  />
                  <div className="flex gap-2 justify-end">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => {
                        setReviewingId(null);
                        setFeedback("");
                      }}
                      disabled={submitting}
                    >
                      Cancel
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleReview(task, false)}
                      disabled={submitting}
                      className="border-rose-200 text-rose-700 hover:bg-rose-50 cursor-pointer"
                    >
                      {submitting ? (
                        <Loader2 className="w-3 h-3 animate-spin mr-1" />
                      ) : (
                        <XCircle className="w-3.5 h-3.5 mr-1" />
                      )}
                      Reject Proof
                    </Button>
                    <Button
                      size="sm"
                      onClick={() => handleReview(task, true)}
                      disabled={submitting}
                      className="bg-black text-white hover:bg-gray-800 cursor-pointer"
                    >
                      {submitting ? (
                        <Loader2 className="w-3 h-3 animate-spin mr-1" />
                      ) : (
                        <CheckCircle2 className="w-3.5 h-3.5 mr-1" />
                      )}
                      Approve & Award {task.points} XP
                    </Button>
                  </div>
                </div>
              ) : (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setReviewingId(task.id)}
                  className="text-xs flex items-center gap-1.5 cursor-pointer"
                >
                  <MessageSquare className="w-3.5 h-3.5" /> Review Submission
                </Button>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
