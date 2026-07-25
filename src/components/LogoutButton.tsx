"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

export default function LogoutButton() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleLogout = async () => {
    setLoading(true);
    await fetch("/api/logout", { method: "POST" });
    router.push("/login");
  };

  return (
    <button
      onClick={handleLogout}
      disabled={loading}
      className="text-[10px] sm:text-xs text-red-500 hover:text-red-400 transition border border-red-500/20 rounded-full px-2 sm:px-3 py-1 bg-red-500/5 hover:bg-red-500/10 disabled:opacity-50"
    >
      {loading ? "…" : "Logout"}
    </button>
  );
}
