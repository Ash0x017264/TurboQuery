-- Same SQL and dataset as baseline; indexes must already exist.
\timing on
\o docs/results/optimized.txt
SELECT 'AFTER INDEX: QUERY A / Nissan 350Z' AS benchmark;
SELECT COUNT(*) FROM public.vehicles
WHERE make='Nissan' AND model='350Z' AND listing_status='active'
  AND price BETWEEN 6500 AND 18000;
EXPLAIN (ANALYZE, BUFFERS)
SELECT vehicle_id, make, model, model_year, mileage, price
FROM public.vehicles
WHERE make='Nissan' AND model='350Z' AND listing_status='active'
  AND price BETWEEN 6500 AND 18000
ORDER BY price LIMIT 30;
EXPLAIN (ANALYZE, BUFFERS)
SELECT vehicle_id, make, model, model_year, mileage, price
FROM public.vehicles
WHERE make='Nissan' AND model='350Z' AND listing_status='active'
  AND price BETWEEN 6500 AND 18000
ORDER BY price LIMIT 30;
EXPLAIN (ANALYZE, BUFFERS)
SELECT vehicle_id, make, model, model_year, mileage, price
FROM public.vehicles
WHERE make='Nissan' AND model='350Z' AND listing_status='active'
  AND price BETWEEN 6500 AND 18000
ORDER BY price LIMIT 30;

SELECT 'AFTER INDEX: QUERY B / newer low-mileage Honda Civic' AS benchmark;
SELECT COUNT(*) FROM public.vehicles
WHERE make='Honda' AND model='Civic' AND model_year >= 2019
  AND mileage <= 70000 AND listing_status='active';
EXPLAIN (ANALYZE, BUFFERS)
SELECT vehicle_id, make, model, model_year, mileage, price
FROM public.vehicles
WHERE make='Honda' AND model='Civic' AND model_year >= 2019
  AND mileage <= 70000 AND listing_status='active'
ORDER BY price LIMIT 40;
EXPLAIN (ANALYZE, BUFFERS)
SELECT vehicle_id, make, model, model_year, mileage, price
FROM public.vehicles
WHERE make='Honda' AND model='Civic' AND model_year >= 2019
  AND mileage <= 70000 AND listing_status='active'
ORDER BY price LIMIT 40;
EXPLAIN (ANALYZE, BUFFERS)
SELECT vehicle_id, make, model, model_year, mileage, price
FROM public.vehicles
WHERE make='Honda' AND model='Civic' AND model_year >= 2019
  AND mileage <= 70000 AND listing_status='active'
ORDER BY price LIMIT 40;
\o
\timing off
\echo Optimized evidence saved in docs/results/optimized.txt
