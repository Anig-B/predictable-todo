"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Zap,
  Users,
  BarChart3,
  ClipboardList,
  Settings,
  LayoutDashboard,
} from "lucide-react";

export function Sidebar() {
  const pathname = usePathname();

  const isActive = (path: string) =>
    pathname === path || pathname?.startsWith(path + "/");

  return (
    <aside className="fixed left-0 top-0 w-56 h-screen bg-[#f8f7f4] border-r border-[#e8e3db] flex flex-col">
      {/* Logo section */}
      <div className="px-5 py-6 border-b border-[#e8e3db]">
        <div className="flex items-center gap-2.5 mb-0.5">
          <Zap className="w-5 h-5 text-[#1a1a1a] fill-[#1a1a1a]" />
          <span className="font-bold text-[#1a1a1a] text-base tracking-tight">
            QuestLog
          </span>
        </div>
        <p className="text-xs text-[#8b8b8b] pl-7">Manager Section</p>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-5 overflow-y-auto space-y-6">
        <div>
          <p className="px-3 text-[11px] font-semibold text-[#8b8b8b] uppercase tracking-wider mb-2">
            Main
          </p>
          <ul className="space-y-1">
            <li>
              <Link
                href="/"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  isActive("/")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb] hover:text-[#1a1a1a]"
                }`}
              >
                <LayoutDashboard className="w-4 h-4" />
                Dashboard
              </Link>
            </li>
            <li>
              <Link
                href="/users"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  isActive("/users")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb] hover:text-[#1a1a1a]"
                }`}
              >
                <Users className="w-4 h-4" />
                Users
              </Link>
            </li>
            <li>
              <Link
                href="/missions"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  isActive("/missions")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb] hover:text-[#1a1a1a]"
                }`}
              >
                <ClipboardList className="w-4 h-4" />
                Missions
              </Link>
            </li>
          </ul>
        </div>

        <div>
          <p className="px-3 text-[11px] font-semibold text-[#8b8b8b] uppercase tracking-wider mb-2">
            Analytics
          </p>
          <ul className="space-y-1">
            <li>
              <Link
                href="/reports"
                className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  isActive("/reports")
                    ? "bg-[#1a1a1a] text-white"
                    : "text-[#6b6b6b] hover:bg-[#efefeb] hover:text-[#1a1a1a]"
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
      <div className="border-t border-[#e8e3db] px-4 py-4 bg-[#f3f2ee]">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-[#1a1a1a] flex items-center justify-center text-white font-semibold text-xs tracking-wider">
            AD
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-semibold text-[#1a1a1a] truncate">
              Admin
            </p>
            <p className="text-[11px] text-[#8b8b8b] truncate">Manager</p>
          </div>
          <button className="p-1.5 hover:bg-[#e8e3db] rounded-md transition-colors text-[#6b6b6b]">
            <Settings className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  );
}
