// Runs in GitHub Actions on a schedule. Checks Supabase for items whose
// last_audited date is 75+ days old (due soon) or 90+ days old (overdue),
// and emails the notification list via Resend if there's anything to flag.
//
// Required environment variables (set as GitHub repo secrets):
//   SUPABASE_URL          — same as in config.js
//   SUPABASE_SERVICE_KEY  — Project Settings > API > service_role key (NOT the anon key —
//                            this one bypasses RLS so the Action can read everything;
//                            never put it in config.js or any frontend file)
//   RESEND_API_KEY        — from resend.com
//   NOTIFY_EMAILS          — comma-separated list, e.g. "rocco@r2gaming.com,steve@r2gaming.com"
//   FROM_EMAIL             — verified sender in Resend, e.g. "tracker@r2gaming.com"

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const RESEND_API_KEY = process.env.RESEND_API_KEY;
const NOTIFY_EMAILS = (process.env.NOTIFY_EMAILS || "").split(",").map(s => s.trim()).filter(Boolean);
const FROM_EMAIL = process.env.FROM_EMAIL;

function daysSince(dateStr) {
  if (!dateStr) return Infinity;
  return Math.floor((Date.now() - new Date(dateStr + "T00:00:00Z").getTime()) / 86400000);
}

async function main() {
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY || !RESEND_API_KEY || !FROM_EMAIL || NOTIFY_EMAILS.length === 0) {
    console.error("Missing one or more required environment variables/secrets. Check the workflow's secrets are all set.");
    process.exit(1);
  }

  const res = await fetch(`${SUPABASE_URL}/rest/v1/inventory_items?select=item_id,title,status,last_audited`, {
    headers: {
      apikey: SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
    },
  });
  if (!res.ok) {
    console.error("Supabase query failed:", res.status, await res.text());
    process.exit(1);
  }
  const items = await res.json();

  const overdue = items.filter(i => daysSince(i.last_audited) >= 90);
  const dueSoon = items.filter(i => { const d = daysSince(i.last_audited); return d >= 75 && d < 90; });

  if (overdue.length === 0 && dueSoon.length === 0) {
    console.log("Nothing due or overdue — no email sent.");
    return;
  }

  const row = (i) => {
    const d = daysSince(i.last_audited);
    const label = i.last_audited ? `${d} days ago` : "never confirmed";
    return `<tr><td style="padding:4px 10px;border-bottom:1px solid #eee;">${i.item_id}</td><td style="padding:4px 10px;border-bottom:1px solid #eee;">${i.title}</td><td style="padding:4px 10px;border-bottom:1px solid #eee;">${i.status}</td><td style="padding:4px 10px;border-bottom:1px solid #eee;">${label}</td></tr>`;
  };

  const html = `
    <h2>Demo Software Control — Audit Reminder</h2>
    ${overdue.length ? `<h3 style="color:#a13d2f;">Overdue (90+ days since last confirmed)</h3><table style="border-collapse:collapse;">${overdue.map(row).join("")}</table>` : ""}
    ${dueSoon.length ? `<h3 style="color:#a8763e;">Due soon (75+ days since last confirmed)</h3><table style="border-collapse:collapse;">${dueSoon.map(row).join("")}</table>` : ""}
    <p style="margin-top:16px;color:#666;font-size:13px;">Sign in to the tracker and confirm the physical location of these items, then hit "Confirm all media present today" once checked.</p>
  `;

  const sendRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: NOTIFY_EMAILS,
      subject: `Demo Software Audit: ${overdue.length} overdue, ${dueSoon.length} due soon`,
      html,
    }),
  });

  if (!sendRes.ok) {
    console.error("Resend send failed:", sendRes.status, await sendRes.text());
    process.exit(1);
  }
  console.log(`Email sent to ${NOTIFY_EMAILS.join(", ")} — ${overdue.length} overdue, ${dueSoon.length} due soon.`);
}

main();
