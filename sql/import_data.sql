-- Run with psql from repository root; only on the new, disposable database.
-- \copy resolves these paths relative to your current shell directory.
\echo Importing generated sellers, buyers, vehicles and offers ...
\copy public.sellers (seller_id, seller_name, region, created_at) FROM 'sample_data/sellers.csv' WITH (FORMAT csv, HEADER true)
\copy public.buyers (buyer_id, buyer_name, region, created_at) FROM 'sample_data/buyers.csv' WITH (FORMAT csv, HEADER true)
\copy public.vehicles (vehicle_id, seller_id, make, model, model_year, mileage, price, listing_status, posted_at) FROM 'sample_data/vehicles.csv' WITH (FORMAT csv, HEADER true)
\copy public.offers (offer_id, vehicle_id, buyer_id, offer_amount, offer_status, created_at) FROM 'sample_data/offers.csv' WITH (FORMAT csv, HEADER true)

-- Since CSV supplies explicit IDs, advance identity sequences before later INSERTs.
SELECT setval(pg_get_serial_sequence('public.sellers','seller_id'), (SELECT MAX(seller_id) FROM public.sellers), true);
SELECT setval(pg_get_serial_sequence('public.buyers','buyer_id'), (SELECT MAX(buyer_id) FROM public.buyers), true);
SELECT setval(pg_get_serial_sequence('public.vehicles','vehicle_id'), (SELECT MAX(vehicle_id) FROM public.vehicles), true);
SELECT setval(pg_get_serial_sequence('public.offers','offer_id'), (SELECT MAX(offer_id) FROM public.offers), true);
ANALYZE public.sellers;
ANALYZE public.buyers;
ANALYZE public.vehicles;
ANALYZE public.offers;
\echo Data import complete.
