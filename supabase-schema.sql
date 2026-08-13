-- R2 Gaming Demo Software Control — Supabase schema
-- Run this once in your Supabase project's SQL editor (Project > SQL Editor > New query).

create table if not exists inventory_items (
  id uuid primary key default gen_random_uuid(),
  item_id text not null,
  manufacturer text,
  media_type text,
  title text not null,
  part_version text,
  qty integer default 1,
  status text not null default 'Lockbox' check (status in ('Lockbox','Cabinet','Controller','Returned')),
  notes text,
  last_audited date,
  updated_at timestamptz default now()
);

create table if not exists checkout_log (
  id uuid primary key default gen_random_uuid(),
  log_id text not null,
  item_id text not null,
  description text,
  out_date timestamptz default now(),
  target text,
  checked_out_by text,
  expected_return date,
  in_date timestamptz,
  checked_in_by text,
  notes text
);

-- Row Level Security: anyone signed in (via magic link) can read and write.
-- This matches "everyone who has access can view and edit" from the request.
-- Tighten later with per-role policies if you want read-only viewers.
alter table inventory_items enable row level security;
alter table checkout_log enable row level security;

create policy "authenticated read/write inventory" on inventory_items
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "authenticated read/write checkout" on checkout_log
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Seed data (your current Master Inventory). Safe to delete/edit after import.
insert into inventory_items (item_id, manufacturer, media_type, title, part_version, qty, status, notes, last_audited) values
('S1','SegaSammy','CFast Card','Super Burst Bouncing Lions','SB3-GMPXNCXX 02.02 GSd',1,'Cabinet','Installed on Showroom Cab #Crest', null),
('S2','SegaSammy','CFast Card','Railroad Riches Sheriff','RR2-GXPXNCXX 01.04 ATMd',1,'Cabinet','Installed on Showroom Cab #ATMOS', null),
('S3','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.41d GEM/A',1,'Cabinet','Installed on Showroom Cab #Crest', null),
('S4','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.41d GEM/A',1,'Cabinet','Installed on Showroom Cab #ATMOS', null),
('S5','SegaSammy','BIOS Chip','Show Version BIOS','B219.10A',1,'Cabinet','Installed on Showroom Cab #Crest', null),
('S6','SegaSammy','BIOS Chip','Show Version BIOS','B219.10A',1,'Cabinet','Installed on Showroom Cab #ATMOS', null),
('S7','SegaSammy','CFast Card','AKANE LINK2','AL2-GXPXNCXX 01.03',1,'Controller','Installed on Showroom Controller', null),
('S8','SegaSammy','CFast Card','Railroad Riches Sheriff','RR2-GXXXNCXX 01.02 ATM',1,'Lockbox','CGS 2025', null),
('S9','SegaSammy','CFast Card','Railroad Riches Sheriff','RR2-GXXXNCXX 01.02 ATM',1,'Lockbox','CGS 2025', null),
('S10','SegaSammy','CFast Card','Railroad Riches Sheriff','RR2-GXXXNCXX 01.02 ATM',1,'Lockbox','CGS 2025', null),
('S11','SegaSammy','CFast Card','Railroad Riches Sheriff','RR2-GXXXNCXX 01.02 ATM',1,'Lockbox','CGS 2025', null),
('S12','SegaSammy','CFast Card','Railroad Riches Tycoon','RR1-GXXXNCXX 01.01 ATM',1,'Lockbox','CGS 2025', null),
('S13','SegaSammy','CFast Card','Railroad Riches Tycoon','RR1-GXXXNCXX 01.01 ATM',1,'Lockbox','CGS 2025', null),
('S14','SegaSammy','CFast Card','Railroad Riches Tycoon','RR1-GXXXNCXX 01.01 ATM',1,'Lockbox','CGS 2025', null),
('S15','SegaSammy','CFast Card','Railroad Riches Tycoon','CGS 2025',1,'Lockbox','CGS 2025', null),
('S16','SegaSammy','CFast Card','Railroad Riches Outlaw','CGS 2025',1,'Lockbox','CGS 2025', null),
('S17','SegaSammy','CFast Card','Raise''m Up Leprechaun','CGS 2025',1,'Lockbox','CGS 2025', null),
('S18','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S19','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S20','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S21','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S22','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S23','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S24','SegaSammy','CFast Card','AKANE System Software','AKN-GMPXNCXX 04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S25','SegaSammy','CFast Card','AKANE System Software','AKN-04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S26','SegaSammy','CFast Card','AKANE System Software','AKN-04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S27','SegaSammy','CFast Card','AKANE System Software','AKN-04.37 GEM/A',1,'Lockbox','CGS 2025', null),
('S28','SegaSammy','CFast Card','AKANE System Software','AKN- 04.30 GEM',1,'Lockbox','CGS 2025', null),
('S29','SegaSammy','CFast Card','AKANE System Software','AKN- 04.29 GEM',1,'Lockbox','CGS 2025', null),
('S30','SegaSammy','BIOS Chip','Show Version BIOS','B219.10A',1,'Lockbox','CGS 2025', null),
('S31','SegaSammy','BIOS Chip','Show Version BIOS','Base BOS',1,'Lockbox','CGS 2025', null),
('S32','SegaSammy','BIOS Chip','Show Version BIOS','Base BOS',1,'Lockbox','CGS 2025', null),
('S33','SegaSammy','BIOS Chip','Show Version BIOS','Base BOS',1,'Lockbox','CGS 2025', null),
('S34','SegaSammy','BIOS Chip','Show Version BIOS','Base BOS',1,'Lockbox','CGS 2025', null);
