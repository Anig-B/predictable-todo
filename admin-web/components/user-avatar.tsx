import { getAvatarColor } from "@/lib/data";
import { cn } from "@/lib/utils";

interface UserAvatarProps {
  name: string;
  initials: string;
  size?: "sm" | "md" | "lg";
  className?: string;
}

export function UserAvatar({
  name,
  initials,
  size = "md",
  className,
}: UserAvatarProps) {
  const sizeClass = {
    sm: "w-8 h-8 text-xs",
    md: "w-10 h-10 text-sm",
    lg: "w-12 h-12 text-base",
  };

  return (
    <div
      className={cn(
        "rounded-full flex items-center justify-center font-semibold text-white",
        getAvatarColor(name),
        sizeClass[size],
        className,
      )}
    >
      {initials}
    </div>
  );
}
