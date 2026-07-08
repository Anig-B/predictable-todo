"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuthCheck } from "@/hooks/useAuthCheck";

export default function AdminPage() {
  const router = useRouter();
  const { role, loading } = useAuthCheck();

  useEffect(() => {
    if (!loading && role?.kind !== "admin") {
      router.replace("/forbidden");
    }
  }, [loading, role, router]);

  if (loading || role?.kind !== "admin") return null;

  return <div className="p-8">Admin</div>;
}
