"use client";

import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";

export default function ForbiddenPage() {
  const router = useRouter();

  return (
    <div className="min-h-screen flex items-center justify-center bg-white px-4">
      <div className="text-center">
        <h1 className="text-4xl font-semibold text-[#1a1a1a] mb-2">403</h1>
        <p className="text-sm text-[#6b6b6b] mb-6">
          You don't have access to the admin panel. Manage quests from the
          QuestLog app instead.
        </p>
        <Button
          onClick={() => router.push("/auth/login")}
          className="bg-[#1a1a1a] text-white hover:bg-[#333]"
        >
          Back to Login
        </Button>
      </div>
    </div>
  );
}
