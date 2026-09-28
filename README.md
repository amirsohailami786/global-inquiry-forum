# Global Inquiry Forum

**Research • Ideas • Perspectives**

Global Inquiry Forum is an interdisciplinary research and public scholarship platform.

## Initial stack

- Frontend: HTML/CSS/JavaScript
- Repository: GitHub
- Hosting target: Cloudflare Pages
- Backend target: Supabase
- Authentication: Supabase Auth
- Database: PostgreSQL via Supabase

## Current status

The included `index.html` is the current website prototype. The three research items shown on the site are demonstrations marked **Coming soon**; they are not published research.

The `supabase/schema.sql` file defines the initial database architecture for:

- Researcher profiles
- Articles
- Submissions
- Editorial reviews
- Topics
- Research-integrity records
- Newsletter subscribers

## Deployment

1. Create the GitHub repository `global-inquiry-forum`.
2. Upload the contents of this folder.
3. Connect the repository to Cloudflare Pages.
4. Create a Supabase project.
5. Run `supabase/schema.sql` in the Supabase SQL Editor.
6. Connect the frontend to Supabase only after the project keys and RLS policies are configured.
7. Add authentication and the researcher/admin dashboards in the next development stage.

## Security

Never put a Supabase `service_role` key or other private credential into browser JavaScript or GitHub.

## Editorial principle

Real publications should be added only after the submission, editorial, attribution, research-integrity and authentication systems are ready.
