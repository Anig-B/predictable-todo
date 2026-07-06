import { Sidebar } from "@/components/sidebar"; // Double check this points to your file!
import { Toaster } from "sonner";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="bg-white min-h-screen">
      <Sidebar />
      {/* Shifts the main page layout rightward to perfectly give room to the sidebar */}
      <main className="pl-55 bg-white">{children}</main>
      <Toaster position="top-right" richColors />
    </div>
  );
}
