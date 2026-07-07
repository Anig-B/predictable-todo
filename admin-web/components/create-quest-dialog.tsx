"use client";

import { useState } from "react";
import { users } from "@/lib/data";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { X, ChevronDown } from "lucide-react";

interface CreateQuestDialogProps {
  onClose: () => void;
  onSubmit: (data: any) => void;
}

export function CreateQuestDialog({
  onClose,
  onSubmit,
}: CreateQuestDialogProps) {
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    points: "",
    priority: "Medium",
    category: "Work",
    timeEstimate: "",
    assignedTo: "",
  });
  const [openDropdown, setOpenDropdown] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (formData.title.trim()) {
      onSubmit(formData);
      setFormData({
        title: "",
        description: "",
        points: "",
        priority: "Medium",
        category: "Work",
        timeEstimate: "",
        assignedTo: "",
      });
    }
  };

  return (
    <>
      {/* Overlay */}
      <div className="fixed inset-0 bg-black/20 z-40" onClick={onClose} />

      {/* Dialog */}
      <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md bg-white border border-[#e8e3db] rounded-lg shadow-xl z-50 max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 flex items-center justify-between px-6 py-4 border-b border-[#e8e3db] bg-white">
          <h2 className="text-lg font-semibold text-[#1a1a1a]">Create quest</h2>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <X className="w-5 h-5 text-[#6b6b6b]" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Title
            </label>
            <Input
              value={formData.title}
              onChange={(e) =>
                setFormData({ ...formData, title: e.target.value })
              }
              placeholder="Quest title"
              className="bg-[#fafaf8] border-[#e8e3db]"
            />
          </div>

          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Description
            </label>
            <textarea
              value={formData.description}
              onChange={(e) =>
                setFormData({ ...formData, description: e.target.value })
              }
              placeholder="Quest description"
              rows={3}
              className="w-full px-3 py-2 border border-[#e8e3db] rounded-lg bg-[#fafaf8] text-sm text-[#1a1a1a] placeholder-[#8b8b8b] focus:outline-none focus:ring-2 focus:ring-[#1a1a1a] focus:ring-offset-1"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
                Points
              </label>
              <Input
                value={formData.points}
                onChange={(e) =>
                  setFormData({ ...formData, points: e.target.value })
                }
                placeholder="0"
                type="number"
                className="bg-[#fafaf8] border-[#e8e3db]"
              />
            </div>
            <div>
              <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
                Priority
              </label>
              <div className="relative">
                <button
                  type="button"
                  onClick={() =>
                    setOpenDropdown(
                      openDropdown === "priority" ? null : "priority",
                    )
                  }
                  className="w-full flex items-center justify-between px-3 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a]"
                >
                  <span>{formData.priority}</span>
                  <ChevronDown className="w-4 h-4" />
                </button>
                {openDropdown === "priority" && (
                  <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10">
                    {["High", "Medium", "Low"].map((priority) => (
                      <button
                        key={priority}
                        type="button"
                        onClick={() => {
                          setFormData({ ...formData, priority });
                          setOpenDropdown(null);
                        }}
                        className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                      >
                        {priority}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>

          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Category
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={() =>
                  setOpenDropdown(
                    openDropdown === "category" ? null : "category",
                  )
                }
                className="w-full flex items-center justify-between px-3 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a]"
              >
                <span>{formData.category}</span>
                <ChevronDown className="w-4 h-4" />
              </button>
              {openDropdown === "category" && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10">
                  {["Work", "Health", "Learning", "Personal"].map(
                    (category) => (
                      <button
                        key={category}
                        type="button"
                        onClick={() => {
                          setFormData({ ...formData, category });
                          setOpenDropdown(null);
                        }}
                        className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                      >
                        {category}
                      </button>
                    ),
                  )}
                </div>
              )}
            </div>
          </div>

          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Time estimate
            </label>
            <Input
              value={formData.timeEstimate}
              onChange={(e) =>
                setFormData({ ...formData, timeEstimate: e.target.value })
              }
              placeholder="e.g. 2 hours"
              className="bg-[#fafaf8] border-[#e8e3db]"
            />
          </div>

          <div>
            <label className="text-sm font-medium text-[#6b6b6b] block mb-2">
              Assign to
            </label>
            <div className="relative">
              <button
                type="button"
                onClick={() =>
                  setOpenDropdown(
                    openDropdown === "assigned" ? null : "assigned",
                  )
                }
                className="w-full flex items-center justify-between px-3 py-2 bg-[#fafaf8] border border-[#e8e3db] rounded-lg text-sm text-[#1a1a1a]"
              >
                <span>
                  {formData.assignedTo
                    ? users.find((u) => u.id === formData.assignedTo)?.name
                    : "Select member"}
                </span>
                <ChevronDown className="w-4 h-4" />
              </button>
              {openDropdown === "assigned" && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10 max-h-40 overflow-y-auto">
                  {users.map((user) => (
                    <button
                      key={user.id}
                      type="button"
                      onClick={() => {
                        setFormData({ ...formData, assignedTo: user.id });
                        setOpenDropdown(null);
                      }}
                      className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                    >
                      {user.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          <div className="flex gap-3 pt-4">
            <Button
              type="button"
              onClick={onClose}
              variant="outline"
              className="flex-1 border-[#e8e3db] text-[#6b6b6b] hover:bg-[#f0ebe4]"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              className="flex-1 bg-[#1a1a1a] text-white hover:bg-[#333333]"
            >
              Create
            </Button>
          </div>
        </form>
      </div>
    </>
  );
}
