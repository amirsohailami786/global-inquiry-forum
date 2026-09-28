-- Global Inquiry Forum — initial Supabase schema
-- Run in Supabase SQL Editor after creating the project.

create extension if not exists "pgcrypto";

create type public.submission_status as enum (
  'received','under_review','revision_requested','accepted','rejected','published'
);

create type public.publication_type as enum (
  'research_article','policy_analysis','review_interview_essay','other'
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  affiliation text,
  bio text,
  research_interests text,
  avatar_url text,
  website_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.articles (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references public.profiles(id) on delete set null,
  title text not null,
  slug text unique not null,
  abstract text,
  body text,
  publication_type public.publication_type not null default 'research_article',
  field text,
  keywords text[],
  status text not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  submitter_id uuid references public.profiles(id) on delete set null,
  full_name text not null,
  email text not null,
  working_title text not null,
  publication_type public.publication_type not null,
  abstract text not null,
  originality_confirmed boolean not null default false,
  status public.submission_status not null default 'received',
  editorial_notes text,
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.editorial_reviews (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.submissions(id) on delete cascade,
  reviewer_id uuid references public.profiles(id) on delete set null,
  recommendation text,
  notes text,
  created_at timestamptz not null default now()
);

create table public.topics (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  description text,
  created_at timestamptz not null default now()
);

create table public.article_topics (
  article_id uuid not null references public.articles(id) on delete cascade,
  topic_id uuid not null references public.topics(id) on delete cascade,
  primary key (article_id, topic_id)
);

create table public.integrity_records (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid references public.submissions(id) on delete cascade,
  article_id uuid references public.articles(id) on delete cascade,
  record_type text not null,
  notes text not null,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  subscribed_at timestamptz not null default now(),
  active boolean not null default true
);

alter table public.profiles enable row level security;
alter table public.articles enable row level security;
alter table public.submissions enable row level security;
alter table public.editorial_reviews enable row level security;
alter table public.topics enable row level security;
alter table public.article_topics enable row level security;
alter table public.integrity_records enable row level security;
alter table public.newsletter_subscribers enable row level security;

-- Public readers can see published articles and topics.
create policy "published articles are public"
on public.articles for select
using (status = 'published');

create policy "topics are public"
on public.topics for select
using (true);

-- Authenticated users can view/update their own researcher profile.
create policy "users view own profile"
on public.profiles for select
using (auth.uid() = id);

create policy "users create own profile"
on public.profiles for insert
with check (auth.uid() = id);

create policy "users update own profile"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

-- Submitters can create submissions; private editorial fields are protected
-- by later admin/editor policies.
create policy "authenticated users submit work"
on public.submissions for insert
with check (auth.uid() = submitter_id);

create policy "submitters view own submissions"
on public.submissions for select
using (auth.uid() = submitter_id);

-- Newsletter signup is intentionally open to anonymous readers.
create policy "anyone can subscribe"
on public.newsletter_subscribers for insert
with check (true);
