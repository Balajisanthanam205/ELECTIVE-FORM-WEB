import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";
import * as XLSX from "xlsx";

const ADMIN_USERNAME = "ramya";
const ADMIN_PASSWORD = "123svce";

function checkAuth(request: NextRequest): boolean {
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Basic ")) return false;
  const base64 = authHeader.slice(6);
  const decoded = Buffer.from(base64, "base64").toString("utf-8");
  const [user, pass] = decoded.split(":");
  return user === ADMIN_USERNAME && pass === ADMIN_PASSWORD;
}

export async function GET(request: NextRequest) {
  if (!checkAuth(request)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Fetch all registrations with subject data
  const { data, error } = await supabaseAdmin
    .from("registrations")
    .select(
      `
      student_name,
      roll_number,
      phone_number,
      section,
      college_email,
      registered_at,
      subjects (
        subject_code,
        subject_name
      )
    `
    )
    .order("registered_at", { ascending: true });

  if (error || !data) {
    return NextResponse.json(
      { error: "Failed to fetch data." },
      { status: 500 }
    );
  }

  // Build flat rows for Excel
  const rows = data.map((reg, idx) => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const sub = reg.subjects as any;
    const registeredAt = reg.registered_at
      ? new Date(reg.registered_at).toLocaleString("en-IN", {
          timeZone: "Asia/Kolkata",
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
          second: "2-digit",
        })
      : "";

    return {
      "S.No": idx + 1,
      "Student Name": reg.student_name,
      "Registration No.": reg.roll_number,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      "Phone No.": (reg as any).phone_number ?? "",
      Section: reg.section,
      "College Email": reg.college_email,
      "Subject Code": sub?.subject_code ?? "",
      "Subject Name": sub?.subject_name ?? "",
      "Registered At (IST)": registeredAt,
    };
  });

  // Build workbook with a summary sheet + a per-subject breakdown sheet
  const wb = XLSX.utils.book_new();

  // ── Sheet 1: All Registrations ──
  const ws1 = XLSX.utils.json_to_sheet(rows);

  // Column widths
  ws1["!cols"] = [
    { wch: 6 },  // S.No
    { wch: 28 }, // Student Name
    { wch: 20 }, // Registration No.
    { wch: 14 }, // Phone No.
    { wch: 10 }, // Section
    { wch: 36 }, // College Email
    { wch: 14 }, // Subject Code
    { wch: 52 }, // Subject Name
    { wch: 22 }, // Registered At
  ];

  XLSX.utils.book_append_sheet(wb, ws1, "All Registrations");

  // ── Sheet 2: Summary by Subject ──
  const { data: subjectData } = await supabaseAdmin
    .from("subjects")
    .select("subject_code, subject_name, filled_seats, max_seats, status")
    .order("subject_code");

  if (subjectData) {
    const summaryRows = subjectData.map((s) => ({
      "Subject Code": s.subject_code,
      "Subject Name": s.subject_name,
      "Registered Students": s.filled_seats,
      "Total Seats": s.max_seats,
      "Available Seats": s.max_seats - s.filled_seats,
      Status: s.status === "full" ? "FULL" : "OPEN",
    }));

    const ws2 = XLSX.utils.json_to_sheet(summaryRows);
    ws2["!cols"] = [
      { wch: 14 },
      { wch: 52 },
      { wch: 22 },
      { wch: 14 },
      { wch: 18 },
      { wch: 10 },
    ];
    XLSX.utils.book_append_sheet(wb, ws2, "Subject Summary");
  }

  // ── Sheet 3–N: Per-subject breakdown ──
  if (subjectData) {
    for (const subject of subjectData) {
      const subRows = rows.filter(
        (r) => r["Subject Code"] === subject.subject_code
      );
      if (subRows.length === 0) continue;

      const ws = XLSX.utils.json_to_sheet(subRows);
      ws["!cols"] = [
        { wch: 6 },
        { wch: 28 },
        { wch: 18 },
        { wch: 14 }, // Phone No.
        { wch: 10 },
        { wch: 36 },
        { wch: 14 },
        { wch: 52 },
        { wch: 22 },
      ];
      // Sheet name max 31 chars
      const sheetName = subject.subject_code.substring(0, 31);
      XLSX.utils.book_append_sheet(wb, ws, sheetName);
    }
  }

  // Generate buffer
  const buf = XLSX.write(wb, { type: "buffer", bookType: "xlsx" });

  const dateStr = new Date()
    .toISOString()
    .slice(0, 10)
    .replace(/-/g, "");

  return new NextResponse(buf, {
    status: 200,
    headers: {
      "Content-Type":
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "Content-Disposition": `attachment; filename="VAC_Registrations_${dateStr}.xlsx"`,
      "Cache-Control": "no-store",
    },
  });
}
