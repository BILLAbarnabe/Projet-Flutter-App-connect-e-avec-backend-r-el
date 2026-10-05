create extension if not exists pgcrypto;

create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null unique,
  description text not null,
  label text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  title text not null unique,
  description text not null,
  label text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null unique,
  description text not null,
  label text not null default 'À faire',
  created_at timestamptz not null default now()
);

alter table public.articles enable row level security;
alter table public.books enable row level security;
alter table public.tasks enable row level security;

drop policy if exists "Authenticated users can read articles" on public.articles;
create policy "Authenticated users can read articles"
  on public.articles for select to authenticated using (true);

drop policy if exists "Authenticated users can read books" on public.books;
create policy "Authenticated users can read books"
  on public.books for select to authenticated using (true);

drop policy if exists "Authenticated users can read tasks" on public.tasks;
create policy "Authenticated users can read tasks"
  on public.tasks for select to authenticated using (true);

grant select on public.articles, public.books, public.tasks to authenticated;

insert into public.articles (title, description, label) values
  ('La beauté des petites habitudes', 'Quelques gestes simples, répétés avec attention, peuvent transformer le rythme d''une journée.', 'Bien-être'),
  ('Apprendre à ralentir', 'Prendre le temps de faire une seule chose à la fois aide à retrouver de la clarté.', 'Inspiration'),
  ('Un carnet pour soi', 'Écrire quelques lignes chaque soir permet de garder une trace des idées et des moments importants.', 'Écriture')
on conflict (title) do nothing;

insert into public.books (title, description, label) values
  ('L''art de la simplicité', 'Une lecture pour faire de la place à ce qui compte vraiment.', 'Dominique Loreau'),
  ('Les mots sont des fenêtres', 'Un guide pratique pour mieux écouter et communiquer.', 'Marshall B. Rosenberg'),
  ('Marcher, une philosophie', 'Une invitation à découvrir le monde à hauteur de pas.', 'Frédéric Gros')
on conflict (title) do nothing;

insert into public.tasks (title, description, label) values
  ('Préparer la semaine', 'Choisir trois priorités et bloquer du temps pour les réaliser.', 'Aujourd''hui'),
  ('Lire quelques pages', 'Reprendre le livre posé sur la table de nuit.', 'Cette semaine'),
  ('Faire une pause dehors', 'Prendre l''air entre deux rendez-vous.', 'À planifier')
on conflict (title) do nothing;
