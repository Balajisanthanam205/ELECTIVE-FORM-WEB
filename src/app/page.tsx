import RegistrationForm from "@/components/RegistrationForm";

export default function HomePage() {
  return (
    <main className="relative min-h-dvh flex flex-col overflow-x-hidden">
      {/* Animated background */}
      <BackgroundEffects />

      {/* College Header Banner */}
      <header className="relative z-10 w-full border-b border-white/5 bg-[#070d1a]/80 backdrop-blur-xl">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-14 sm:h-16">
            <div className="flex items-center gap-3">
              {/* Logo placeholder — SVG crest */}
              <div className="w-8 h-8 sm:w-10 sm:h-10 rounded-lg bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center shadow-lg shadow-blue-500/20 shrink-0">
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  className="w-4 h-4 sm:w-5 sm:h-5 text-white"
                >
                  <path
                    d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </div>
              <div>
                <p className="text-xs sm:text-sm font-bold text-white leading-tight">
                  SVCE
                </p>
                <p className="text-[10px] sm:text-xs text-slate-400 leading-tight hidden xs:block">
                  Sri Venkateswara College of Engineering
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-[10px] sm:text-xs text-slate-500 border border-white/10 rounded-full px-2 sm:px-3 py-1 bg-white/5">
                Academic Year 2024–25
              </span>
            </div>
          </div>
        </div>
      </header>

      {/* Page Content */}
      <div className="relative z-10 flex-1 flex items-start justify-center px-4 sm:px-6 lg:px-8 py-8 sm:py-12 lg:py-16">
        <div className="w-full max-w-2xl">
          {/* Decorative grid lines */}
          <div className="absolute inset-0 pointer-events-none opacity-[0.03]"
            style={{
              backgroundImage:
                "linear-gradient(rgba(255,255,255,0.4) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.4) 1px, transparent 1px)",
              backgroundSize: "60px 60px",
            }}
          />

          {/* Main registration card */}
          <div className="relative rounded-2xl sm:rounded-3xl border border-white/8 bg-[#0f1729]/90 shadow-2xl shadow-black/50 glow-blue backdrop-blur-xl overflow-hidden">
            {/* Top accent glow */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-gradient-to-r from-transparent via-blue-500/60 to-transparent" />
            {/* Left side glow orb */}
            <div className="absolute -top-20 -left-20 w-64 h-64 bg-blue-600/10 rounded-full blur-3xl pointer-events-none" />
            {/* Right side glow orb */}
            <div className="absolute -bottom-20 -right-20 w-64 h-64 bg-violet-600/8 rounded-full blur-3xl pointer-events-none" />

            <div className="relative p-5 sm:p-8 lg:p-10">
              <RegistrationForm />
            </div>
          </div>

          {/* Footer note */}
          <div className="mt-6 text-center">
            <p className="text-xs text-slate-600">
              Department of Electronics &amp; Communication Engineering
              &nbsp;•&nbsp; Elective Registration Portal
            </p>
            <p className="text-xs text-slate-700 mt-1">
              Each subject is limited to 48 students. Registration is on a first-come, first-served basis.
            </p>
          </div>
        </div>
      </div>
    </main>
  );
}

function BackgroundEffects() {
  return (
    <>
      {/* Base gradient */}
      <div
        className="fixed inset-0 pointer-events-none z-0"
        style={{
          background:
            "radial-gradient(ellipse 80% 60% at 50% -10%, rgba(59,130,246,0.12) 0%, transparent 60%), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(99,102,241,0.08) 0%, transparent 60%), #070d1a",
        }}
      />
      {/* Floating particles */}
      <div className="bg-particles" aria-hidden="true">
        {[...Array(12)].map((_, i) => (
          <span
            key={i}
            className="particle"
            style={{
              left: `${(i * 8.33) % 100}%`,
              animationDuration: `${12 + (i * 3) % 15}s`,
              animationDelay: `${(i * 2.5) % 12}s`,
              width: i % 3 === 0 ? "3px" : "2px",
              height: i % 3 === 0 ? "3px" : "2px",
              opacity: 0.3 + (i % 4) * 0.1,
            }}
          />
        ))}
      </div>
    </>
  );
}
