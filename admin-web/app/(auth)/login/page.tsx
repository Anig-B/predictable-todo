"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { resolveWebAppRole } from "@/lib/auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      // 1. Authenticate against the shared Supabase instance
      const { data, error: signInError } =
        await supabase.auth.signInWithPassword({ email, password });

      if (signInError) {
        setError(
          signInError.message === "Invalid login credentials"
            ? "Incorrect email or password"
            : signInError.message,
        );
        return;
      }

      const userId = data.user?.id;
      if (!userId) {
        setError("Sign-in failed. Try again.");
        return;
      }

      // 2. Role gate: admin → all missions, manager → scoped, else 403
      const role = await resolveWebAppRole(supabase, userId);

      if (role.kind === "forbidden") {
        // Regular members manage quests from the Flutter app.
        // End the web session so they don't hold a half-usable login.
        await supabase.auth.signOut();
        router.push("/forbidden");
        return;
      }

      // 3. Route based on role
      if (role.kind === "admin") {
        router.push("/admin");
      } else if (role.kind === "manager") {
        // Store manager's accessible mission IDs in sessionStorage for quick access
        sessionStorage.setItem(
          "userMissionIds",
          JSON.stringify(role.missionIds),
        );
        router.push("/");
      }

      router.refresh();
    } catch (err) {
      console.error("Login error:", err);
      setError("Something went wrong. Try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-white px-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="mb-8 text-center">
          <h1 className="text-3xl font-semibold text-[#1a1a1a] mb-2">
            Predictable
          </h1>
          <p className="text-sm text-[#6b6b6b]">Admin Panel</p>
        </div>

        {/* Login Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Email Field */}
          <div>
            <label
              htmlFor="email"
              className="block text-sm font-medium text-[#1a1a1a] mb-2"
            >
              Email
            </label>
            <Input
              id="email"
              type="email"
              autoComplete="email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={loading}
              required
              className="w-full px-4 py-2 border border-[#e8e3db] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#1a1a1a] disabled:opacity-50"
            />
          </div>

          {/* Password Field */}
          <div>
            <label
              htmlFor="password"
              className="block text-sm font-medium text-[#1a1a1a] mb-2"
            >
              Password
            </label>
            <Input
              id="password"
              type="password"
              autoComplete="current-password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={loading}
              required
              className="w-full px-4 py-2 border border-[#e8e3db] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#1a1a1a] disabled:opacity-50"
            />
          </div>

          {/* Error Message */}
          {error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-600">
              {error}
            </div>
          )}

          {/* Submit Button */}
          <Button
            type="submit"
            disabled={loading}
            className="w-full px-4 py-2 bg-[#1a1a1a] text-white rounded-lg text-sm font-medium transition-all hover:bg-[#333] disabled:opacity-60 disabled:cursor-not-allowed"
          >
            {loading ? "Signing in..." : "Sign In"}
          </Button>
        </form>
      </div>
    </div>
  );
}
