# Turbo Query - technical video demonstration outline

Both members MUST speak or perform meaningful demonstrations.

1. **Introduction (both):** Explain simulated used-car marketplace and project boundaries. Show four linked tables.
2. **Daniel - schema/data:** Open schema.sql and run `sql/verify_data.sql`; show 100,000 vehicle rows and zero broken foreign keys. Explain deterministic fictional generation.
3. **Daniel - security:** Show `sql/roles.sql` and run `sql/security_tests.sql`; show allowed SELECT/status update and denied INSERT/DELETE/price update (PASS notices).
4. **Ashton - performance:** Open saved `docs/results/baseline.txt`, `docs/results/optimized.txt` and `sql/indexes.sql`. Discuss EXPLAIN plan nodes, repeated execution times, and buffers. Explain tradeoffs and any query where the index was not chosen.
5. **Daniel - backup/recovery:** Run `scripts/backup_restore.ps1` in PowerShell (or sh variant); show backup existence, simulated offers deletion in `turboquery_restore`, and recovered row counts. Never delete source DB.
6. **Both - wrap up:** State actual measured results, limitations (synthetic workload / no web app), role/module responsibilities, future work.

Record actual PostgreSQL, psql, PowerShell/terminal output. **Do not submit slide narration alone.** Test unlisted video link in an incognito/private browser.
