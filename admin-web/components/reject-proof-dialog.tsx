"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { X } from "lucide-react";

interface RejectProofDialogProps {
  proofId: string;
  onClose: () => void;
  onSubmit: (proofId: string, feedback: string) => void;
}

export function RejectProofDialog({
  proofId,
  onClose,
  onSubmit,
}: RejectProofDialogProps) {
  const [feedback, setFeedback] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (feedback.trim()) {
      onSubmit(proofId, feedback);
      setFeedback("");
    }
  };

  return (
    <>
      {/* Overlay */}
      <div className="fixed inset-0 bg-black/20 z-40" onClick={onClose} />

      {/* Dialog */}
      <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md bg-white border border-[#e8e3db] rounded-lg shadow-xl z-50">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#e8e3db]">
          <h2 className="text-lg font-semibold text-[#1a1a1a]">
            Reject review
          </h2>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <X className="w-5 h-5 text-[#6b6b6b]" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Feedback
            </label>
            <textarea
              value={feedback}
              onChange={(e) => setFeedback(e.target.value)}
              placeholder="Why are you rejecting this submission?"
              rows={4}
              className="w-full px-3 py-2 border border-[#e8e3db] rounded-lg bg-[#fafaf8] text-sm text-[#1a1a1a] placeholder-[#8b8b8b] focus:outline-none focus:ring-2 focus:ring-[#1a1a1a] focus:ring-offset-1"
            />
          </div>

          <div className="flex gap-3 pt-4">
            <Button
              type="button"
              onClick={onClose}
              variant="outline"
              className="flex-1 border-[#e8e3db] text-[#6b6b6b] hover:bg-[#f0ebe4]"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={!feedback.trim()}
              className="flex-1 bg-[#991b1b] text-white hover:bg-[#7f1515] disabled:opacity-50"
            >
              Reject
            </Button>
          </div>
        </form>
      </div>
    </>
  );
}
