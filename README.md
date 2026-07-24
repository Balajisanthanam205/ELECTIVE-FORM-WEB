# 📚 Elective Course Registration Portal

A **production-ready**, **race-condition-proof** elective subject registration system built for 250+ concurrent users.

Built with **Next.js 15 · TypeScript · Tailwind CSS · Supabase (PostgreSQL)**.

---

## ✨ Features

| Feature | Detail |
|---|---|
| 🔒 Atomic registration | PostgreSQL `SELECT FOR UPDATE` prevents overbooking |
| 🚀 250+ concurrent users | Supabase connection pooling + DB-level locking |
| 📱 Fully responsive | 320px → 1920px, mobile-first, touch-friendly |
| 🌙 Dark mode | Premium glassmorphism university portal |
| ⚡ Real-time seats | Auto-refreshes every 10 seconds |
| ✅ Server-side validation | Zod + parameterized queries |
| 🎯 One registration | Roll number + email uniqueness enforced at DB level |
| 🍞 Toast notifications | Sonner for success/error feedback |

---

## 🗂 Project Structure

```
elective-portal/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── subjects/route.ts     # GET — list subjects with seat count
│   │   │   └── register/route.ts     # POST — atomic registration
│   │   ├── globals.css               # Global dark theme styles
│   │   ├── layout.tsx                # Root layout + metadata
│   │   └── page.tsx                  # Homepage with animated background
│   ├── components/
│   │   ├── ui/
│   │   │   ├── button.tsx            # Gradient button component
│   │   │   ├── input.tsx             # Dark input component
│   │   │   ├── label.tsx             # Radix label
│   │   │   └── select.tsx            # Radix select with dark styling
│   │   └── RegistrationForm.tsx      # Main form + seat cards + success screen
│   └── lib/
│       ├── constants.ts              # Subjects, sections, domain config
│       ├── supabase.ts               # Browser Supabase client
│       ├── supabase-admin.ts         # Server-side admin client
│       ├── utils.ts                  # cn() tailwind merge helper
│       └── validations.ts            # Zod schemas + TypeScript types
├── supabase/
│   └── migration.sql                 # Complete DB schema + RPC function
├── .env.example                      # Environment variable template
└── README.md
```

---

## 🚀 Setup Instructions

### 1. Clone & Install

```bash
cd elective-portal
npm install
```

### 2. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Choose a region close to your users
3. Note your **Project URL** and **API keys**

### 3. Run the Database Migration

1. Open Supabase Dashboard → **SQL Editor**
2. Copy the entire contents of `supabase/migration.sql`
3. Paste and click **Run**

This creates:
- `subjects` table with 4 elective subjects (48 seats each)
- `registrations` table with unique constraints
- `register_student()` PostgreSQL function (atomic, race-condition-proof)
- Row Level Security policies

### 4. Configure Environment Variables

```bash
cp .env.example .env.local
```

Edit `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

> **Security note**: `SUPABASE_SERVICE_ROLE_KEY` is only used server-side in API routes. It is **never** exposed to the browser.

### 5. Update College Email Domain

In `src/lib/constants.ts`, update:

```ts
export const COLLEGE_EMAIL_DOMAIN = "@svce.ac.in"; // Change to your domain
```

### 6. Run Locally

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## 🌐 Deploy to Vercel

1. Push to GitHub
2. Go to [vercel.com](https://vercel.com) → **Import Project**
3. Add all three environment variables in Vercel project settings
4. Deploy

---

## 🏗 How Race Conditions Are Prevented

The `register_student` PostgreSQL function uses:

```sql
SELECT * FROM subjects WHERE id = p_subject_id FOR UPDATE;
```

This **row-level lock** ensures that when 250 students hit register simultaneously, only **one** can hold the lock on that subject row at a time. The sequence is:

1. Lock subject row → check duplicate roll/email → check seats → insert → increment → unlock
2. All other concurrent requests wait for the lock, then correctly see the updated seat count

This is **ACID-compliant** — no overbooking is possible even under extreme load.

---

## 🗃 Database Schema

### `subjects` table
| Column | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| subject_code | TEXT | e.g. VD22704 |
| subject_name | TEXT | Full subject name |
| max_seats | INTEGER | 48 |
| filled_seats | INTEGER | Auto-incremented by RPC |
| status | TEXT | 'open' or 'full' |

### `registrations` table
| Column | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| student_name | TEXT | |
| roll_number | TEXT | **UNIQUE** |
| section | TEXT | |
| college_email | TEXT | **UNIQUE** |
| subject_id | UUID | FK → subjects |
| registered_at | TIMESTAMPTZ | Auto |

---

## 📊 Checking Registrations (Admin)

In Supabase SQL Editor:

```sql
-- All registrations with subject name
SELECT r.roll_number, r.student_name, r.section, r.college_email,
       s.subject_code, s.subject_name, r.registered_at
FROM registrations r
JOIN subjects s ON s.id = r.subject_id
ORDER BY r.registered_at DESC;

-- Seat summary
SELECT subject_code, subject_name, filled_seats, max_seats, status
FROM subjects ORDER BY subject_code;
```

---

## 🔒 Security

- All validation is **server-side** (Zod in API routes)
- **Never** trusts client input
- Parameterized queries via Supabase client (prevents SQL injection)
- Service role key is **server-only** (never in browser bundle)
- RLS blocks direct table access from browser
- All writes go through the SECURITY DEFINER RPC function

---

## 📱 Responsive Breakpoints

| Breakpoint | Target |
|---|---|
| 320px+ | Small mobile |
| 375px+ | Mobile |
| 425px+ | Large mobile |
| 768px+ | Tablet |
| 1024px+ | Laptop |
| 1440px+ | Desktop |
| 1920px+ | Ultra-wide |

- `font-size: 16px` on inputs (prevents iOS Safari zoom)
- `min-height: 44px` on all interactive elements (WCAG touch target)
- No horizontal scrolling at any viewport width
