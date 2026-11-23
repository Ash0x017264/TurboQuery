# Turbo Query - Used Car Marketplace DBA Final Project (starter implementation)

Course: **CSCE 4355** | Team: **Ashton Murdock and Daniel Pham**

This is an independently runnable **starter implementation** for the team's proposed project. It is **not** a verified copy of an existing private GitHub repository. If Daniel already has schema/data, **compare and merge instead of overwriting his files**. No performance measurements are claimed until run against PostgreSQL.

## Scope
- `sellers`, `buyers`, `vehicles`, `offers` with primary/foreign keys and CHECK constraints.
- Deterministic Python-generated fictional dataset (100,000 vehicles by default).
- PostgreSQL NOLOGIN roles and effective permission tests via `SET ROLE`.
- Baseline/optimized EXPLAIN (ANALYZE, BUFFERS) with **same SQL** and 3 repeats each.
- `pg_dump` custom-format backup, controlled simulated data loss in a **separate restore database**, `pg_restore` verification.
- No public website, payments or real users.

## Requirements
PostgreSQL 14+ with `psql`, `pg_dump`, `pg_restore`, `createdb`, `dropdb` on PATH. Python 3.9+ standard library. For Windows, PowerShell 5.1+. You need PostgreSQL privileges to create databases and roles; easiest classroom environment is PostgreSQL's `postgres` superuser. Command examples assume you run from the folder containing this README. For Windows, use PowerShell; it may prompt you for your password (do **not** store it in code). If you have a non-default username, set environment variable `PGUSER` or add `-U YOUR_USER` to psql/createdb commands.

## Fastest route: one-command Windows execution

Unzip the starter, open PowerShell **in the extracted TurboQuery folder**, and run:
```powershell
$env:PGUSER = 'postgres'
.\scripts\run_all.ps1
```
This checks required PostgreSQL tools, refuses to overwrite existing `turboquery` or `turboquery_restore` databases, builds the schema/data, collects benchmark evidence, tests roles and permissions, creates a backup and verifies recovery. It needs local PostgreSQL (with `postgres` access) and Python if generated CSVs are not included. If you already have a team database/repo, **DO NOT run the one-command setup**; integrate only the appropriate module files with Daniel's existing schema.

## 1. Create a NEW database (one time, does not touch another team's existing DB)

In PowerShell, from this folder:
```powershell
createdb -U postgres turboquery
python scripts/seed_data.py --rows 100000 --seed 4355
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/schema.sql
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/import_data.sql
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/verify_data.sql
```
If `createdb` reports an existing database, **stop**. Do not rerun imports in a populated database. Use a new disposable DB, or inspect the existing schema first.

The import script uses `\copy` (client-side relative CSV paths) and must be run with `psql`, not inside pgAdmin Query Tool. `sql/schema.sql` assumes `turboquery` is a fresh, dedicated project database.

## 2. Capture optimization evidence (Ashton's module)

```powershell
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/baseline_queries.sql
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/indexes.sql
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/performance_tests.sql
```
Evidence saves to `docs/results/baseline.txt` and `docs/results/optimized.txt`. Read **Execution Time** lines, median of three runs for Query A and for Query B, buffers and scan types. Planner may legitimately choose a sequential scan for some cases; describe what happened rather than claiming guaranteed improvements. The result of running the scripts is the evidence. The query A filter is Nissan 350Z (price, active) with an appropriate `(make, model, listing_status, price)` index; query B targets newer Honda Civic listings with a different index.

Capture terminal screenshots of each plan, index statement, and comparison table. No results are prefilled.

## 3. Security (Daniel's module)

```powershell
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/roles.sql
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/security_tests.sql
```
`roles.sql` creates **NOLOGIN** demo roles, not login accounts. Test script uses `SET LOCAL ROLE` to show effective permissions; must run as a superuser or permitted member. The reader can SELECT but may not INSERT/DELETE. The editor can SELECT and update `vehicles.listing_status`, but cannot modify prices or delete vehicles. Test transactions roll back any changes. Capture NOTICE `PASS` messages plus privilege matrix. The roles are cluster-global; `roles.sql` contains grants specific to a database called `turboquery`.

## 4. Backup, simulated failure & restoration (Daniel's module)

Run in **PowerShell**, from the project root:
```powershell
$env:PGUSER = 'postgres'
.\scripts\backup_restore.ps1
psql -U postgres -d turboquery -v ON_ERROR_STOP=1 -f sql/recovery_checks.sql
psql -U postgres -d turboquery_restore -v ON_ERROR_STOP=1 -f sql/recovery_checks.sql
```
Or for macOS/Linux: `bash scripts/backup_restore.sh`. These scripts intentionally **DROP `turboquery_restore`** if it exists; it must be exclusively a disposable demo database. They **never** drop or truncate `turboquery`. The scripts create a custom-format `.dump` in local `backups/` (gitignored), restore the test DB, compare table counts, simulate offers-table data loss in the test DB, restore it again, then recheck counts. `pg_dump --no-acl` excludes role privileges; use `roles.sql` separately for cluster-global role setup. To fully document recovery, compare both `sql/recovery_checks.sql` outputs, including sample records and integrity checks.

> **IMPORTANT:** Do not use the test DB name for anything valuable. The backup script deletes `turboquery_restore` automatically. Source DB is never dropped.

## 5. Demo, report, submission
- `docs/demo_outline.md`: live demonstration sequence with both members participating.
- `docs/report_evidence_template.md`: professor-aligned report headings and unfilled evidence table. Turn this into PDF/Word after real results are obtained; never invent measurements.
- Include actual screenshots/captions, measured results, full test evidence, architecture diagram, member contributions, source references and accessible links.
- Submit **one report** (PDF or Word), **GitHub repository URL**, and **public/unlisted video URL** through Canvas. **Do not submit a ZIP unless Canvas asks for one.** This ZIP is for exchanging/developing the source code only.

## Repository structure
```
README.md
sql/            schema, import, roles, security tests, queries, indexes, recovery checks
scripts/        Python generator, PowerShell/Bash recovery demo
docs/           report worksheet, demo outline, observed results
sample_data/    generated CSV (gitignored)
tests/          local generator smoke test
```

## Troubleshooting
- `psql not recognized`: add PostgreSQL `bin` (typically under `C:\Program Files\PostgreSQL\<version>\bin`) to your PATH; restart PowerShell.
- `password authentication failed`: use PostgreSQL account/password, not Windows or GitHub login.
- `permission denied to create role`: run roles.sql as a PostgreSQL admin/superuser.
- `\copy ... file not found`: `cd` to the project root before using `psql -f`.
- `relation already exists` / duplicate keys: don't rerun the schema/import on a previously populated DB.
- `DROP DATABASE ... being accessed`: close pgAdmin connections to disposable `turboquery_restore` and rerun.
- Baseline/optimized comparison invalid if indexes already existed; perform an isolated fresh test DB or explicitly drop only the benchmark indexes after recording/approving their removal.

Official docs: https://www.postgresql.org/docs/current/sql-grant.html | https://www.postgresql.org/docs/current/using-explain.html | https://www.postgresql.org/docs/current/app-pgdump.html | https://www.postgresql.org/docs/current/app-pgrestore.html
