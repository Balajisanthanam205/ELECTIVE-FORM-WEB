"use client";

import React, { useState } from "react";
import Image from "next/image";
import { Menu, X } from "lucide-react";
import LogoutButton from "./LogoutButton";

interface HeaderProps {
  studentName?: string;
  showAdmin?: boolean;
}

export default function Header({ studentName = "", showAdmin = true }: HeaderProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="relative z-10 w-full border-b border-white/5 bg-[#070d1a]/80 backdrop-blur-xl">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-14 sm:h-16">
          {/* Logo & Title */}
          <div className="flex items-center gap-3 flex-shrink-0">
            <div className="shrink-0">
              <Image
                src="/svce-logo.png"
                alt="SVCE Logo"
                width={80}
                height={32}
                className="h-8 sm:h-10 w-auto object-contain"
                priority
              />
            </div>
            <div className="hidden sm:block">
              <p className="text-xs sm:text-sm font-bold text-white leading-tight">
                Sri Venkateswara College of Engineering
              </p>
              <p className="text-[10px] sm:text-xs text-slate-400 leading-tight">
                VAC Registration Portal
              </p>
            </div>
          </div>

          {/* Desktop Navigation */}
          <div className="hidden sm:flex items-center gap-2">
            {studentName && (
              <span className="text-xs text-slate-400">
                👋 {studentName}
              </span>
            )}
            <span className="text-xs text-blue-400 border border-blue-500/20 rounded-full px-3 py-1 bg-blue-500/10 font-semibold">
              ECE
            </span>
            <span className="text-xs text-slate-500 border border-white/10 rounded-full px-3 py-1 bg-white/5">
              AY 2026–2027
            </span>
            {showAdmin && (
              <a
                href="/admin"
                className="text-xs text-slate-600 hover:text-blue-400 transition border border-white/8 rounded-full px-3 py-1 bg-white/[0.03] hover:bg-blue-500/10"
              >
                Admin
              </a>
            )}
            <LogoutButton />
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="sm:hidden p-2 rounded-lg hover:bg-white/5 transition text-slate-400 hover:text-white"
            aria-label="Toggle menu"
          >
            {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <div className="sm:hidden border-t border-white/5 py-4 space-y-3">
            {studentName && (
              <div className="text-xs text-slate-400 px-2 py-2 border-l-2 border-blue-400/50">
                👋 {studentName}
              </div>
            )}
            <div className="flex gap-2 px-2 flex-wrap">
              <span className="text-[10px] text-blue-400 border border-blue-500/20 rounded-full px-2 py-1 bg-blue-500/10 font-semibold">
                ECE
              </span>
              <span className="text-[10px] text-slate-500 border border-white/10 rounded-full px-2 py-1 bg-white/5">
                AY 2026–2027
              </span>
            </div>
            {showAdmin && (
              <a
                href="/admin"
                className="block text-xs text-slate-600 hover:text-blue-400 transition border border-white/8 rounded-lg px-3 py-2 bg-white/[0.03] hover:bg-blue-500/10 text-center"
              >
                Admin Dashboard
              </a>
            )}
            <div className="flex gap-2">
              <LogoutButton />
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
