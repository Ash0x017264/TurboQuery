-- Run only AFTER baseline performance evidence has been captured.
CREATE INDEX IF NOT EXISTS idx_vehicles_make_model_status_price
    ON public.vehicles(make, model, listing_status, price);
CREATE INDEX IF NOT EXISTS idx_vehicles_make_model_year_mileage
    ON public.vehicles(make, model, model_year, mileage);
ANALYZE public.vehicles;
-- Added indexes have write/storage cost; document observed tradeoffs.
SELECT indexname, indexdef FROM pg_indexes
WHERE schemaname='public' AND tablename='vehicles'
ORDER BY indexname;
