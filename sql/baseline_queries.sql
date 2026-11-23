-- IMPORTANT: Run BEFORE sql/indexes.sql.
-- Run FROM repository root with psql so docs/results/ path resolves.
-- Compare repeated runs, not a single timing. Do not fabricate conclusions.
\timing on
\o docs/results/baseline.txt
SELECT 'BEFORE INDEX: QUERY A / Nissan 350Z' AS benchmark;
-- Warm query execution so measurements are less dominated by first-use disk I/O.
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

SELECT 'BEFORE INDEX: QUERY B / newer low-mileage Honda Civic' AS benchmark;
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
\echo Baseline evidence saved in docs/results/baseline.txt
