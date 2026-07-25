import { NextRequest, NextResponse } from "next/server";

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // ── Paths that never need auth ─────────────────────────────
  const publicPrefixes = [
    "/login",
    "/api/login",
    "/api/logout",
    "/api/portal-status",
    "/_next",
    "/favicon.ico",
    "/svce-logo.png",
  ];
  if (publicPrefixes.some((p) => pathname.startsWith(p))) {
    return NextResponse.next();
  }

  // ── Admin path — handled separately ───────────────────────
  if (pathname.startsWith("/admin")) {
    return NextResponse.next();
  }

  // ── Check for session cookie ───────────────────────────────
  const sessionCookie = request.cookies.get("vac_session")?.value;

  if (!sessionCookie) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  try {
    const session = JSON.parse(sessionCookie);
    if (!session?.token || !session?.reg_number) throw new Error("bad session");
    return NextResponse.next();
  } catch {
    const res = NextResponse.redirect(new URL("/login", request.url));
    res.cookies.set("vac_session", "", { maxAge: 0, path: "/" });
    return res;
  }
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|.*\\.(?:png|svg|jpg|jpeg|gif|webp|ico)$).*)"],
};
