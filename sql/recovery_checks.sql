-- Run in both turboquery and turboquery_restore for before/after comparison.
SELECT 'sellers' AS table_name, COUNT(*) AS row_count, SUM(seller_id) AS id_checksum FROM public.sellers
UNION ALL SELECT 'buyers', COUNT(*), SUM(buyer_id) FROM public.buyers
UNION ALL SELECT 'vehicles', COUNT(*), SUM(vehicle_id) FROM public.vehicles
UNION ALL SELECT 'offers', COUNT(*), SUM(offer_id) FROM public.offers;
SELECT vehicle_id, make, model, model_year, mileage, price
FROM public.vehicles ORDER BY vehicle_id LIMIT 5;
SELECT COUNT(*) AS invalid_mileage FROM public.vehicles WHERE mileage < 0;
SELECT COUNT(*) AS broken_offer_links FROM public.offers o
LEFT JOIN public.vehicles v ON v.vehicle_id=o.vehicle_id
LEFT JOIN public.buyers b ON b.buyer_id=o.buyer_id
WHERE v.vehicle_id IS NULL OR b.buyer_id IS NULL;
