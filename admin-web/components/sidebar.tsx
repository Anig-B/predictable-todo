"use client";

import React, { useEffect, useState, useMemo } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import type { AuthChangeEvent, Session } from "@supabase/supabase-js";
import {
  Zap,
  Users,
  BarChart3,
  ClipboardList,
  Settings,
  LayoutDashboard,
} from "lucide-react";

interface NavItem {
  label: string;
  href: string;
  icon: React.ElementType;
  exact?: boolean;
}

const NAV_GROUPS: { title: string; items: NavItem[] }[] = [
  {
    title: "Main",
    items: [
      { label: "Dashboard", href: "/", icon: LayoutDashboard, exact: true },
      { label: "Users", href: "/users", icon: Users },
      { label: "Missions", href: "/missions", icon: ClipboardList },
    ],
  },
  {
    title: "Analytics",
    items: [{ label: "Reports", href: "/reports", icon: BarChart3 }],
  },
];

export function Sidebar() {
  const pathname = usePathname();
  const supabase = useMemo(() => createClient(), []);

  const [username, setUsername] = useState<string>("Loading...");
  const [role, setRole] = useState<string>("Manager");
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    async function loadUserProfile() {
      try {
        setIsLoading(true);

        const {
          data: { user },
          error: authError,
        } = await supabase.auth.getUser();

        if (authError || !user) {
          setUsername("Guest");
          setRole("Not signed in");
          setIsLoading(false);
          return;
        }

        const { data: profile, error: profileError } = await supabase
          .from("profiles")
          .select("username, role")
          .eq("id", user.id)
          .maybeSingle();

        if (profileError) {
          console.warn("Error loading profile details:", profileError.message);
        }

        if (profile?.username) {
          setUsername(profile.username);
        } else if (user.email) {
          setUsername(user.email.split("@")[0]);
        } else {
          setUsername("User");
        }

        if (profile?.role) setRole(profile.role);
      } catch (err) {
        console.error("Unexpected profile load error:", err);
        setUsername("User");
      } finally {
        setIsLoading(false);
      }
    }

    loadUserProfile();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(
      async (_event: AuthChangeEvent, session: Session | null) => {
        if (session?.user) {
          await loadUserProfile();
        } else {
          setUsername("Guest");
          setRole("Not signed in");
          setIsLoading(false);
        }
      },
    );

    return () => {
      subscription.unsubscribe();
    };
  }, [supabase]);

  const getInitials = (name: string) => {
    if (!name || name === "Loading..." || name === "Guest") return "U";

    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  };

  const checkIsActive = (item: NavItem) => {
    if (item.exact) {
      return pathname === item.href;
    }
    return pathname === item.href || pathname?.startsWith(item.href + "/");
  };

  return (
    <aside className="fixed left-0 top-0 w-56 h-screen bg-[#f8f7f4] border-r border-[#e8e3db] flex flex-col z-40 select-none">
      {/* Brand Header */}
      <div className="px-5 py-6 border-b border-[#e8e3db]">
        <Link href="/" className="flex items-center gap-2.5 mb-0.5 group">
          <div className="p-1 rounded bg-[#1a1a1a] text-white transition-transform group-hover:scale-105">
            <Zap className="w-4 h-4 fill-current" />
          </div>
          <span className="font-bold text-[#1a1a1a] text-base tracking-tight">
            QuestLog
          </span>
        </Link>
        <p className="text-[11px] text-[#8b8b8b] pl-7 font-medium uppercase tracking-wider">
          Manager Portal
        </p>
      </div>

      {/* Navigation Sections */}
      <nav className="flex-1 px-3 py-5 overflow-y-auto space-y-6">
        {NAV_GROUPS.map((group) => (
          <div key={group.title}>
            <p className="px-3 text-[10px] font-bold text-[#8b8b8b] uppercase tracking-wider mb-2">
              {group.title}
            </p>
            <ul className="space-y-1">
              {group.items.map((item) => {
                const active = checkIsActive(item);
                const Icon = item.icon;
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      className={`flex items-center gap-3 px-3 py-2 rounded-md text-xs font-semibold tracking-wide transition-all ${
                        active
                          ? "bg-[#1a1a1a] text-white shadow-sm"
                          : "text-[#6b6b6b] hover:bg-[#efefeb] hover:text-[#1a1a1a]"
                      }`}
                    >
                      <Icon className="w-4 h-4 shrink-0" />
                      {item.label}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      {/* User Profile Footer */}
      <div className="border-t border-[#e8e3db] px-4 py-3.5 bg-[#f3f2ee]">
        <div className="flex items-center gap-3">
          {isLoading ? (
            <>
              <div className="w-8 h-8 rounded-full bg-[#e8e3db] animate-pulse shrink-0" />
              <div className="flex-1 min-w-0 space-y-1.5">
                <div className="h-3 bg-[#e8e3db] rounded animate-pulse w-3/4" />
                <div className="h-2 bg-[#e8e3db] rounded animate-pulse w-1/2" />
              </div>
            </>
          ) : (
            <>
              <div className="w-8 h-8 rounded-full bg-[#1a1a1a] flex items-center justify-center text-white font-bold text-xs tracking-wider shrink-0 shadow-sm">
                {getInitials(username)}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-xs font-bold text-[#1a1a1a] truncate leading-tight">
                  {username}
                </p>
                <p className="text-[10px] text-[#8b8b8b] truncate capitalize font-medium">
                  {role}
                </p>
              </div>
              <Link
                href="/settings"
                title="Settings"
                className={`p-1.5 rounded-md transition-colors ${
                  pathname === "/settings"
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#e8e3db] hover:text-[#1a1a1a]"
                }`}
              >
                <Settings className="w-4 h-4" />
              </Link>
            </>
          )}
        </div>
      </div>
    </aside>
  );
}
