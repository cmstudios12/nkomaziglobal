NKOMAZI GLOBAL FET COLLEGE — 2027 WEBSITE

FILES
index.html - public college homepage
apply.html - live Supabase application submission
admin.html - staff-only applications dashboard
style.css, site.js, apply.js, admin.js, config.js - site assets
supabase-setup.sql - database schema and RLS policies

START
1. Extract the ZIP.
2. Add your own licensed college hero photograph as assets/hero.jpg. The homepage has a polished navy gradient fallback until then. You can also add your existing logo by replacing the NG brandmark in the HTML.
3. Use VS Code Live Server or deploy to GitHub Pages / your hosting provider. Don't use file:// for testing authentication.
4. Open https://supabase.com/dashboard/project/zvqssclpdgcwxkssfchk/sql/new and run supabase-setup.sql.
5. Authentication > Users > Add user: create your admin with a strong password. Copy its User UID.
6. SQL Editor: insert into public.admin_users(user_id) values ('YOUR-REAL-USER-UUID');
7. Sign in at admin.html and submit a test application at apply.html.

IMPORTANT
The publishable key is designed for client-side use; never expose service_role keys.
This project does not create student accounts, send emails, process payments or verify admission automatically.
Use anti-spam protections such as CAPTCHA / rate limits before accepting public production submissions.
If collecting information from minors, review applicable privacy requirements and parental consent practices.
The stated price, accreditation wording, transport and subject availability should be verified before publishing.
