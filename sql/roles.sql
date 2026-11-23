-- Dedicated project database only. Run as PostgreSQL superuser / CREATEROLE admin.
-- Uses NOLOGIN roles; tests use SET ROLE to validate effective privileges.
DO $roles$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'tq_admin') THEN
        CREATE ROLE tq_admin NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'tq_reader') THEN
        CREATE ROLE tq_reader NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'tq_editor') THEN
        CREATE ROLE tq_editor NOLOGIN;
    END IF;
END
$roles$;

GRANT CONNECT ON DATABASE turboquery TO tq_admin, tq_reader, tq_editor;
GRANT USAGE ON SCHEMA public TO tq_admin, tq_reader, tq_editor;
-- Revoke PUBLIC access; apply only in dedicated demo database.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO tq_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO tq_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO tq_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO tq_editor;
GRANT UPDATE (listing_status) ON public.vehicles TO tq_editor;
GRANT INSERT ON public.offers TO tq_editor;
GRANT USAGE ON SEQUENCE public.offers_offer_id_seq TO tq_editor;
