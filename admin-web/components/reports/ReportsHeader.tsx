"use client";

import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";

interface ReportsHeaderProps {
  hasMissions: boolean;
  onExportCSV: () => void;
}

export function ReportsHeader({
  hasMissions,
  onExportCSV,
}: ReportsHeaderProps) {
  return (
    <div className="flex items-center justify-between">
      <h1 className="text-3xl font-semibold text-[#1a1a1a]">Manager Reports</h1>
      {hasMissions && (
        <Button
          onClick={onExportCSV}
          variant="outline"
          className="border-[#e8e3db] text-[#6b6b6b] hover:bg-[#f0ebe4] flex items-center gap-2"
        >
          <Download className="w-4 h-4" />
          Export CSV
        </Button>
      )}
    </div>
  );
}
