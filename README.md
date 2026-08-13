# R2 Gaming — Demo Software Control Tracker

A shared, permissioned web app for tracking SegaSammy demo media: master inventory, checkout log,
and a quarterly audit reminder emailed to your team.

## What this is
- `index.html` — the whole app (frontend). Hosted for free on GitHub Pages.
- `config.js` — where you paste your Supabase project keys.
- `supabase-schema.sql` — run once to set up your database (includes your 34 real items).
- `scripts/send-audit-email.js` + `.github/workflows/audit-check.yml` — a scheduled job that
  checks for overdue items and emails your list via Resend.

## Setup — do these in order

### 1. Create a Supabase project (free)
1. Go to [supabase.com](https://supabase.com) → New project.
2. Once it's created, go to **SQL Editor** → New query, paste in the contents of
   `supabase-schema.sql`, and run it. This creates the tables and loads your 34 items.
3. Go to **Project Settings > API**. You'll need two values:
   - **Project URL** (e.g. `https://xxxx.supabase.co`)
   - **anon / public key** (long string, safe for frontend use)
4. Go to **Authentication > Providers**, make sure **Email** is enabled, and under
   **Authentication > URL Configuration**, add the GitHub Pages URL you'll get in step 3 below
   as a **Redirect URL** (you can come back and do this after step 3 if you don't have the URL yet).

### 2. Fill in `config.js`
Open `config.js` and paste in your Project URL and anon key from step 1.3.

### 3. Push to GitHub and turn on Pages
1. Create a new GitHub repo (can be private or public — Pages works either way on paid GitHub
   plans; on free plans, Pages sites are public even if the repo is private, so use a public
   repo unless you're on GitHub Team/Enterprise).
2. Push all these files to it.
3. Go to repo **Settings > Pages** → Source: **Deploy from branch** → Branch: `main` (or
   whichever branch you pushed), folder `/ (root)`. Save.
4. GitHub gives you a URL like `https://yourusername.github.io/repo-name/` — that's your live
   site. Add this URL back into Supabase's Redirect URLs (step 1.4) so magic links work.

### 4. Set up Resend for email sending (free tier)
1. Go to [resend.com](https://resend.com) → sign up.
2. Verify a sending domain (e.g. `r2gaming.com`) under **Domains** — this needs a DNS record
   added, so you may need whoever manages your domain. Alternatively, Resend gives you a
   `onboarding@resend.dev` test address that works without domain verification, useful for
   testing before your domain is verified.
3. Create an **API key** under **API Keys**.

### 5. Add GitHub repo secrets (for the scheduled email)
In your repo: **Settings > Secrets and variables > Actions > New repository secret**. Add all
of these:
| Secret name | Value |
|---|---|
| `SUPABASE_URL` | same Project URL as in `config.js` |
| `SUPABASE_SERVICE_KEY` | Supabase Project Settings > API > **service_role** key (different from anon key — keep this one secret, never put it in `config.js`) |
| `RESEND_API_KEY` | from step 4.3 |
| `NOTIFY_EMAILS` | comma-separated list, e.g. `rocco@r2gaming.com,steve@r2gaming.com,kuldip@r2gaming.com` |
| `FROM_EMAIL` | a verified sender, e.g. `tracker@r2gaming.com` (or the Resend test address while testing) |

### 6. Test it
- Visit your GitHub Pages URL, sign in with your email, confirm you get a magic link and can
  see the 34 items.
- In your repo's **Actions** tab, find "Quarterly Audit Check" and click **Run workflow** to
  trigger it manually — check that the email arrives (it'll only send if something is 75+
  days since last confirmed, which will be everything at first since none have been confirmed
  yet).

## Notes
- **Access control:** anyone who signs in with a magic link can view and edit everything —
  there's no view-only role yet. If you want read-only access for some people later, that's a
  Supabase Row Level Security policy change (I can help with that when you're ready).
- **Changing the schedule:** the cron in `audit-check.yml` runs quarterly. Edit the `cron` line
  if you want it to check weekly or monthly instead — for example `0 9 * * 1` runs every Monday.
