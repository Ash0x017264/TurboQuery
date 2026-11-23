#!/usr/bin/env bash
set -euo pipefail
# Run from project root. Requires PostgreSQL CLI and privileges to create/drop test DB.
# Never modifies turboquery source, only turboquery_restore disposable test DB.
source_db='turboquery'
test_db='turboquery_restore'
mkdir -p backups
backup="backups/turboquery_$(date +%Y%m%d_%H%M%S).dump"
pg_dump -Fc --no-owner --no-acl -d "$source_db" -f "$backup"
test -s "$backup"
restore_test() {
  dropdb --if-exists "$test_db"
  createdb "$test_db"
  pg_restore --exit-on-error --no-owner --no-acl -d "$test_db" "$backup"
}
query="SELECT (SELECT COUNT(*) FROM public.sellers)::text || ':' || (SELECT COUNT(*) FROM public.buyers)::text || ':' || (SELECT COUNT(*) FROM public.vehicles)::text || ':' || (SELECT COUNT(*) FROM public.offers)::text;"
restore_test
before=$(psql -X -At -d "$source_db" -c "$query")
after=$(psql -X -At -d "$test_db" -c "$query")
test "$before" = "$after" || { echo 'FAIL: initial restore count mismatch'; exit 1; }
psql -X -v ON_ERROR_STOP=1 -d "$test_db" -c 'TRUNCATE TABLE public.offers;'
test "$(psql -X -At -d "$test_db" -c 'SELECT count(*) FROM public.offers;')" = '0'
restore_test
recovered=$(psql -X -At -d "$test_db" -c "$query")
test "$before" = "$recovered" || { echo 'FAIL: recovered count mismatch'; exit 1; }
echo "PASS: backup $backup, source counts $before, restored counts $recovered"
echo 'Capture logs and verify sample records and referential checks for final report.'
