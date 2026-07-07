interface StatCardProps {
  label: string;
  value: string | number;
}

export function StatCard({ label, value }: StatCardProps) {
  return (
    <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6">
      <p className="text-sm text-[#8b8b8b] mb-2">{label}</p>
      <p className="text-3xl font-semibold text-[#1a1a1a]">{value}</p>
    </div>
  );
}
