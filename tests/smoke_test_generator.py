"""Run: python tests/smoke_test_generator.py - no PostgreSQL required."""
import csv
import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts' / 'seed_data.py'
with tempfile.TemporaryDirectory() as d:
    base = Path(d)
    def generate(out):
        subprocess.run([sys.executable, str(SCRIPT), '--rows','200', '--seed','4355','--out',str(out)],check=True,capture_output=True,text=True)
    generate(base/'a')
    generate(base/'b')
    for filename, expected in [('sellers.csv',10),('buyers.csv',10),('vehicles.csv',200),('offers.csv',60)]:
        p=base/'a'/filename
        with p.open(newline='',encoding='utf8') as f:
            rows=list(csv.DictReader(f))
        assert len(rows)==expected,(filename,len(rows),expected)
        assert p.read_bytes()==(base/'b'/filename).read_bytes(),f'Generator not deterministic: {filename}'
        if filename=='vehicles.csv':
            assert all(int(r['mileage'])>=0 and float(r['price'])>0 for r in rows)
            assert all(1<=int(r['seller_id'])<=10 for r in rows)
        if filename=='offers.csv':
            assert all(1<=int(r['vehicle_id'])<=200 and 1<=int(r['buyer_id'])<=10 for r in rows)
    print('PASS: deterministic CSV generation and basic simulated referential integrity (200 vehicles).')
