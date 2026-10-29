"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

// --- Types ---

export interface ProofReview {
  id: string;
  approved: boolean | null;
  feedback: string | null;
  reviewed_at: string;
  reviewer?: { username: string } | null;
}

export interface ProofTask {
  id: string;
  user_id: string;
  title: string;
  desc: string | null;
  points: number;
  status?: "active" | "pending_review" | "completed" | "expired";
  is_active?: boolean;
  due_at?: string | null;
  proof_notes: string | null;
  proof_image: string | null;
  created_at: string;
  done: boolean;
  mission_id_fk?: string | null;
  profiles: {
    username: string;
    avatar_url: string | null;
  } | null;
  proof_reviews?: ProofReview[];
}

// --- Server Actions ---

/**
 * Fetches all mission tasks awaiting manager proof review.
 */
export async function getPendingProofs(): Promise<ProofTask[]> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("tasks")
    .select(
      `
      id,
      user_id,
      title,
      desc,
      points,
      status,
      is_active,
      due_at,
      proof_notes,
      proof_image,
      created_at,
      done,
      mission_id_fk,
      profiles:user_id (
        username,
        avatar_url
      ),
      proof_reviews (
        id,
        approved,
        feedback,
        reviewed_at,
        reviewer:profiles!reviewed_by ( username )
      )
    `,
    )
    .eq("status", "pending_review")
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Error fetching pending proofs:", error.message);
    throw new Error(error.message);
  }

  return (data as unknown as ProofTask[]) || [];
}

/**
 * Approves or rejects a submitted task proof.
 */
export async function reviewProofSubmission(
  taskId: string,
  approved: boolean,
  feedback?: string,
) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  // 1. Record the manager's review decision
  const { error: reviewError } = await supabase.from("proof_reviews").insert({
    task_id: taskId,
    reviewed_by: user.id,
    approved,
    feedback: feedback?.trim() || null,
  });

  if (reviewError) throw new Error(reviewError.message);

  // 2. Update task state accordingly
  if (approved) {
    const { error: taskError } = await supabase
      .from("tasks")
      .update({
        done: true,
        status: "completed",
        is_active: false,
        lastCompletedAt: new Date().toISOString(),
      })
      .eq("id", taskId);

    if (taskError) throw new Error(taskError.message);
  } else {
    // Soft reset on rejection
    const { error: taskError } = await supabase
      .from("tasks")
      .update({
        proof_image: null,
        proof_notes: null,
        status: "active",
        done: false,
      })
      .eq("id", taskId);

    if (taskError) throw new Error(taskError.message);
  }

  revalidatePath("/dashboard");
  revalidatePath("/proofs");
}
