-- Every count and foreign key check must match expected data.
SELECT 'sellers' AS table_name, COUNT(*) AS row_count FROM public.sellers
UNION ALL SELECT 'buyers', COUNT(*) FROM public.buyers
UNION ALL SELECT 'vehicles', COUNT(*) FROM public.vehicles
UNION ALL SELECT 'offers', COUNT(*) FROM public.offers;

SELECT 'vehicles_without_seller' AS check_name, COUNT(*) AS bad_rows
FROM public.vehicles v LEFT JOIN public.sellers s USING (seller_id)
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'offers_without_vehicle', COUNT(*)
FROM public.offers o LEFT JOIN public.vehicles v USING (vehicle_id)
WHERE v.vehicle_id IS NULL
UNION ALL
SELECT 'offers_without_buyer', COUNT(*)
FROM public.offers o LEFT JOIN public.buyers b USING (buyer_id)
WHERE b.buyer_id IS NULL;

SELECT make, model, COUNT(*) AS listings FROM public.vehicles
GROUP BY make, model ORDER BY listings DESC LIMIT 10;
SELECT COUNT(*) AS negative_mileage FROM public.vehicles WHERE mileage < 0;
SELECT COUNT(*) AS non_positive_prices FROM public.vehicles WHERE price <= 0;
