-- Must run as a superuser or member allowed to SET ROLE to both demo roles.
-- All writes are either no-op or rolled back. Check console NOTICEs.
\echo TEST: reader can SELECT but cannot INSERT or DELETE.
BEGIN;
SET LOCAL ROLE tq_reader;
SELECT COUNT(*) AS reader_can_select_listings FROM public.vehicles;
DO $test$
BEGIN
    BEGIN
        EXECUTE 'DELETE FROM public.vehicles WHERE vehicle_id = -1';
        RAISE EXCEPTION 'FAIL: reader DELETE unexpectedly succeeded';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: reader DELETE denied';
    END;
    BEGIN
        EXECUTE 'INSERT INTO public.offers (vehicle_id,buyer_id,offer_amount,offer_status,created_at) VALUES (1,1,10000,''pending'',CURRENT_DATE)';
        RAISE EXCEPTION 'FAIL: reader INSERT unexpectedly succeeded';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: reader INSERT denied';
    END;
END
$test$;
ROLLBACK;

\echo TEST: editor can edit listing_status but cannot edit vehicle price or DELETE.
BEGIN;
SET LOCAL ROLE tq_editor;
UPDATE public.vehicles SET listing_status=listing_status WHERE vehicle_id=1;
DO $test$
BEGIN
    BEGIN
        EXECUTE 'UPDATE public.vehicles SET price = price WHERE vehicle_id=1';
        RAISE EXCEPTION 'FAIL: editor price UPDATE unexpectedly succeeded';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: editor price UPDATE denied';
    END;
    BEGIN
        EXECUTE 'DELETE FROM public.vehicles WHERE vehicle_id=-1';
        RAISE EXCEPTION 'FAIL: editor DELETE unexpectedly succeeded';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: editor DELETE denied';
    END;
END
$test$;
ROLLBACK;

\echo Privilege matrix / verification:
SELECT role_name, has_table_privilege(role_name, 'public.vehicles', 'SELECT') AS can_read,
       has_column_privilege(role_name, 'public.vehicles','listing_status','UPDATE') AS can_update_status,
       has_column_privilege(role_name, 'public.vehicles','price','UPDATE') AS can_update_price,
       has_table_privilege(role_name, 'public.vehicles', 'DELETE') AS can_delete
FROM (VALUES ('tq_admin'), ('tq_reader'), ('tq_editor')) r(role_name);
