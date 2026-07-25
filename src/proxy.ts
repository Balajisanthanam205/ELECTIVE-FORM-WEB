import { NextRequest, NextResponse } from "next/server";

export async function proxy(request: NextRequest) {
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
    
    // We can verify token against /api/portal-status internally, or we can just 
    // let the API routes check it if we don't want to make a DB call on every asset fetch.
    // However, checking the DB here ensures true single-device enforcement on all routes.
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;
    
    // Edge-compatible fetch to Supabase RPC
    const res = await fetch(`${supabaseUrl}/rest/v1/rpc/verify_session_token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`
      },
      body: JSON.stringify({ p_token: session.token })
    });
    
    if (res.ok) {
      const data = await res.json();
      if (!data?.valid) {
        throw new Error("Invalid session token in DB");
      }
    }
    
    return NextResponse.next();
  } catch (err) {
    console.error("Middleware Auth Error:", err);
    // If it's an API request, return 401
    if (pathname.startsWith("/api/")) {
      const response = NextResponse.json({ error: "Session expired or active on another device." }, { status: 401 });
      response.cookies.set("vac_session", "", { maxAge: 0, path: "/" });
      return response;
    }
    
    // Otherwise redirect to login
    const response = NextResponse.redirect(new URL("/login?reason=session_replaced", request.url));
    response.cookies.set("vac_session", "", { maxAge: 0, path: "/" });
    return response;
  }
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|.*\\.(?:png|svg|jpg|jpeg|gif|webp|ico)$).*)"],
};
