import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { resolveWebAppRole } from "@/lib/auth";
import type { WebAppRole } from "@/lib/auth";

export function useAuthCheck() {
  const router = useRouter();
  const supabase = createClient();
  const [role, setRole] = useState<WebAppRole | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const {
          data: { user },
        } = await supabase.auth.getUser();

        if (!user) {
          router.push("/auth/login");
          return;
        }

        const userRole = await resolveWebAppRole(supabase, user.id);
        setRole(userRole);

        if (userRole.kind === "forbidden") {
          router.push("/forbidden");
        }
      } catch (err) {
        console.error("Auth check error:", err);
        router.push("/auth/login");
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, [router, supabase]);

  return { role, loading };
}
