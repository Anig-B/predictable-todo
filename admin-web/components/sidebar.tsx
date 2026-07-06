"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Zap,
  Users,
  Inbox,
  BarChart3,
  ClipboardList,
  Settings,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";

export function Sidebar() {
  const pathname = usePathname();

  const isActive = (path: string) =>
    pathname === path || pathname?.startsWith(path + "/");

  return (
    <aside className="fixed left-0 top-0 w-55 h-screen bg-[#f8f7f4] border-r border-[#e8e3db] flex flex-col">
      {/* Logo section */}
      <div className="px-4 py-6 border-b border-[#e8e3db]">
        <div className="flex items-center gap-2 mb-1">
          <Zap className="w-6 h-6 text-[#1a1a1a]" />
          <span className="font-semibold text-[#1a1a1a]">Predictable</span>
        </div>
        <p className="text-xs text-[#6b6b6b]">admin panel</p>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-2 py-4 overflow-y-auto">
        <div className="mb-6">
          <p className="px-3 text-xs font-medium text-[#8b8b8b] uppercase tracking-wider mb-2">
            Main
          </p>
          <ul className="space-y-1">
            <li>
              <Link
                href="/"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors ${
                  isActive("/")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb]"
                }`}
              >
                <span className="w-4 h-4" />
                Dashboard
              </Link>
            </li>
            <li>
              <Link
                href="/users"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors ${
                  isActive("/users")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb]"
                }`}
              >
                <Users className="w-4 h-4" />
                Users
              </Link>
            </li>
            <li>
              <Link
                href="/missions"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors ${
                  isActive("/missions")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb]"
                }`}
              >
                <ClipboardList className="w-4 h-4" />
                Missions
              </Link>
            </li>
          </ul>
        </div>

        <div className="mb-6">
          <p className="px-3 text-xs font-medium text-[#8b8b8b] uppercase tracking-wider mb-2">
            Review
          </p>
          <ul className="space-y-1">
            <li>
              <Link
                href="/reviews"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors ${
                  isActive("/reviews")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb]"
                }`}
              >
                <Inbox className="w-4 h-4" />
                <span className="flex-1">Proof inbox</span>
                <Badge className="bg-[#fbbf24] text-[#1a1a1a] text-xs px-1.5 py-0 h-5 flex items-center">
                  3{/* Fetch new proof from users */}
                </Badge>
              </Link>
            </li>
            <li>
              <Link
                href="/reports"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors ${
                  isActive("/reports")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb]"
                }`}
              >
                <BarChart3 className="w-4 h-4" />
                Reports
              </Link>
            </li>
          </ul>
        </div>
      </nav>

      {/* User profile */}
      <div className="border-t border-[#e8e3db] px-3 py-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-linear-to-br from-[#14b8a6] to-[#06b6d4] flex items-center justify-center text-white font-semibold text-sm">
            AD
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-[#1a1a1a]">Admin</p>
            <p className="text-xs text-[#8b8b8b]">system admin</p>
          </div>
          <button className="p-1.5 hover:bg-[#efefeb] rounded-md transition-colors">
            <Settings className="w-4 h-4 text-[#6b6b6b]" />
          </button>
        </div>
      </div>
    </aside>
  );
}
