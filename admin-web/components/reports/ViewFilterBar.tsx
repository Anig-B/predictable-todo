"use client";

export type ViewMode = "user" | "mission";
export type Timeframe = "daily" | "weekly" | "monthly";

interface ViewFilterBarProps {
  viewMode: ViewMode;
  timeframe: Timeframe;
  onViewModeChange: (mode: ViewMode) => void;
  onTimeframeChange: (tf: Timeframe) => void;
}

export function ViewFilterBar({
  viewMode,
  timeframe,
  onViewModeChange,
  onTimeframeChange,
}: ViewFilterBarProps) {
  const timeframes: Timeframe[] = ["daily", "weekly", "monthly"];

  return (
    <div className="flex items-center gap-4">
      <div className="flex gap-2 bg-[#fafaf8] p-1 rounded-lg border border-[#e8e3db]">
        <button
          onClick={() => onViewModeChange("user")}
          className={`px-3 py-2 rounded text-sm font-medium transition-colors ${
            viewMode === "user"
              ? "bg-white text-[#1a1a1a]"
              : "text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          By user
        </button>
        <button
          onClick={() => onViewModeChange("mission")}
          className={`px-3 py-2 rounded text-sm font-medium transition-colors ${
            viewMode === "mission"
              ? "bg-white text-[#1a1a1a]"
              : "text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          By mission
        </button>
      </div>

      <div className="flex gap-2">
        {timeframes.map((tf) => (
          <button
            key={tf}
            onClick={() => onTimeframeChange(tf)}
            className={`px-3 py-2 rounded text-sm font-medium capitalize transition-colors ${
              timeframe === tf
                ? "bg-[#1a1a1a] text-white"
                : "bg-[#fafaf8] text-[#8b8b8b] border border-[#e8e3db] hover:text-[#6b6b6b]"
            }`}
          >
            {tf}
          </button>
        ))}
      </div>
    </div>
  );
}
