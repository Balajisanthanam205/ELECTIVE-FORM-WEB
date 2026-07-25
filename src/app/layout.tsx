import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import { Toaster } from "sonner";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "VAC Registration Portal | ECE – SVCE",
  description:
    "VAC (Value Added Course) elective registration portal for ECE students. AY 2026-2027. One registration per student. Real-time seat availability.",
  keywords: [
    "VAC registration",
    "elective registration",
    "ECE",
    "SVCE",
    "student portal",
    "AY 2026-2027",
  ],
  openGraph: {
    title: "VAC Registration Portal | SVCE ECE",
    description: "Register for your VAC elective subject — fast, secure, and real-time.",
    type: "website",
  },
  robots: { index: false, follow: false },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
  themeColor: "#070d1a",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={inter.variable}>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
      </head>
      <body className="font-sans antialiased">
        {children}
        <Toaster
          position="top-center"
          richColors
          expand
          toastOptions={{
            style: {
              background: "#0f1729",
              border: "1px solid rgba(255,255,255,0.1)",
              color: "#f8fafc",
            },
          }}
        />
      </body>
    </html>
  );
}
