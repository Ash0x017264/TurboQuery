#!/usr/bin/env python3
"""Repeatable synthetic dataset, Python standard library only (no real PII)."""
import argparse
import csv
import random
from datetime import date, timedelta
from pathlib import Path

CARS = {
    "Toyota": ["Camry", "Corolla", "RAV4", "Tacoma"],
    "Honda": ["Civic", "Accord", "CR-V", "Pilot"],
    "Nissan": ["350Z", "Altima", "Sentra", "Rogue"],
    "Ford": ["Mustang", "F-150", "Escape", "Explorer"],
    "Chevrolet": ["Colorado", "Silverado", "Malibu", "Camaro"],
    "BMW": ["M3", "330i", "X3", "X5"],
    "Hyundai": ["Elantra", "Sonata", "Tucson"],
    "Subaru": ["WRX", "Outback", "Crosstrek"],
}
REGIONS = ["TX", "CA", "VA", "FL", "WA", "NC", "CO", "AZ"]
START = date(2024, 1, 1)

def random_date(rng, days=1000):
    return (START + timedelta(days=rng.randrange(days))).isoformat()

def write_rows(path, headers, rows):
    with path.open('w', newline='', encoding='utf-8') as fh:
        writer = csv.writer(fh)
        writer.writerow(headers)
        writer.writerows(rows)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--rows', type=int, default=100000, help='number of vehicle listings')
    parser.add_argument('--seed', type=int, default=4355)
    parser.add_argument('--out', default='sample_data')
    args = parser.parse_args()
    if args.rows < 1: parser.error('--rows must be positive')
    rng = random.Random(args.seed)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    n_sellers = min(5000, max(1, args.rows // 20))
    n_buyers = min(5000, max(1, args.rows // 20))
    n_offers = max(1, args.rows * 3 // 10)
    write_rows(out/'sellers.csv', ['seller_id','seller_name','region','created_at'],
               ((i,f'Fictional Seller {i}',rng.choice(REGIONS),random_date(rng)) for i in range(1,n_sellers+1)))
    write_rows(out/'buyers.csv', ['buyer_id','buyer_name','region','created_at'],
               ((i,f'Fictional Buyer {i}',rng.choice(REGIONS),random_date(rng)) for i in range(1,n_buyers+1)))
    prices = [0] * (args.rows + 1)
    def vehicles():
        for i in range(1,args.rows+1):
            make = rng.choice(list(CARS))
            model = rng.choice(CARS[make])
            year = rng.randint(1998,2025)
            mileage = rng.randint(5000,280000)
            base = 8500 + (year-2000)*780 - mileage*0.045
            premium = 8000 if model in ('350Z','M3','Mustang','WRX') else 0
            price = max(1500, round((base + premium + rng.randint(-4500,4500))/100)*100)
            prices[i] = price
            status = rng.choices(['active','pending','sold'],weights=[85,5,10],k=1)[0]
            yield (i,rng.randint(1,n_sellers),make,model,year,mileage,f'{price:.2f}',status,random_date(rng))
    write_rows(out/'vehicles.csv', ['vehicle_id','seller_id','make','model','model_year','mileage','price','listing_status','posted_at'], vehicles())
    def offers():
        for i in range(1,n_offers+1):
            vid = rng.randint(1,args.rows)
            amount = max(100,round(prices[vid] * rng.uniform(0.75,1.05)/100)*100)
            yield (i,vid,rng.randint(1,n_buyers),f'{amount:.2f}',
                   rng.choice(['pending','accepted','rejected']),random_date(rng))
    write_rows(out/'offers.csv', ['offer_id','vehicle_id','buyer_id','offer_amount','offer_status','created_at'], offers())
    for file in sorted(out.glob('*.csv')):
        with file.open(encoding='utf-8') as fh:
            count=sum(1 for _ in fh)-1
        print(f'{file}: {count:,} records')
    print(f'Deterministic seed={args.seed}; fictional data only.')

if __name__=='__main__':
    main()
