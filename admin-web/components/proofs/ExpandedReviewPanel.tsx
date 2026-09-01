"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { ExternalLink, Check, X, FileText, Loader2 } from "lucide-react";
import { ProofTask } from "@/actions/proofs";

interface ExpandedReviewPanelProps {
  task: ProofTask;
  submitting: boolean;
  onClose: () => void;
  onReview: (
    task: ProofTask,
    approved: boolean,
    feedback: string,
  ) => Promise<void>;
}

export function ExpandedReviewPanel({
  task,
  submitting,
  onClose,
  onReview,
}: ExpandedReviewPanelProps) {
  const [feedback, setFeedback] = useState("");

  return (
    <div className="p-5 pt-0 border-t border-border/40 mt-2">
      <div className="grid md:grid-cols-2 gap-6 pt-5">
        {/* Left: Full Image View */}
        <div className="space-y-2">
          {task.proof_image ? (
            <div className="relative aspect-4/3 rounded-xl overflow-hidden bg-black/40 border border-border/50">
              <img
                src={task.proof_image}
                alt="Proof Submission"
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-x-0 bottom-0 p-3 bg-linear-to-t from-black/80 to-transparent flex items-center justify-between text-white text-xs">
                <span>Evidence attachment</span>
                <a
                  href={task.proof_image}
                  target="_blank"
                  rel="noreferrer"
                  className="hover:underline flex items-center gap-1 font-medium"
                >
                  Open full size <ExternalLink className="w-3 h-3" />
                </a>
              </div>
            </div>
          ) : (
            <div className="aspect-4/3 rounded-xl bg-muted/40 border border-border/50 flex flex-col items-center justify-center text-muted-foreground">
              <FileText className="w-8 h-8 mb-2 opacity-50" />
              <span className="text-xs">No image attached</span>
            </div>
          )}
        </div>

        {/* Right: Notes & Action Form */}
        <div className="flex flex-col justify-between space-y-4">
          <div className="space-y-4">
            <div className="p-4 rounded-xl bg-muted/40 border border-border/50 space-y-1.5">
              <div className="flex items-center gap-1.5 text-xs font-semibold text-foreground">
                <FileText className="w-3.5 h-3.5 text-muted-foreground" />
                Member note
              </div>
              <p className="text-xs text-muted-foreground leading-relaxed">
                {task.proof_notes || "No notes provided with submission."}
              </p>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-medium text-muted-foreground">
                Feedback{" "}
                <span className="text-muted-foreground/60">(optional)</span>
              </label>
              <textarea
                value={feedback}
                onChange={(e) => setFeedback(e.target.value)}
                placeholder="Add context for the member..."
                rows={3}
                className="w-full p-3 text-xs bg-muted/40 text-foreground border border-border/60 rounded-xl focus:outline-none focus:ring-1 focus:ring-ring resize-none placeholder:text-muted-foreground/50"
              />
            </div>
          </div>

          <div className="flex items-center justify-end gap-2 pt-2">
            <Button
              variant="ghost"
              size="sm"
              onClick={onClose}
              disabled={submitting}
              className="rounded-xl text-xs text-muted-foreground hover:text-foreground"
            >
              <X className="w-3.5 h-3.5 mr-1" /> Cancel
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => onReview(task, false, feedback)}
              disabled={submitting}
              className="rounded-xl text-xs border-rose-500/30 text-rose-500 hover:bg-rose-500/10 hover:text-rose-500"
            >
              {submitting ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin mr-1" />
              ) : (
                <X className="w-3.5 h-3.5 mr-1" />
              )}
              Request changes
            </Button>
            <Button
              size="sm"
              onClick={() => onReview(task, true, feedback)}
              disabled={submitting}
              className="rounded-xl text-xs bg-foreground text-background hover:bg-foreground/90 font-medium"
            >
              {submitting ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin mr-1" />
              ) : (
                <Check className="w-3.5 h-3.5 mr-1" />
              )}
              Approve & award
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
