# Turbo Query - report evidence worksheet (fill ONLY with measured facts)

## Title page
Project: Turbo Query - Used Car Marketplace Database Administration System
Course: CSCE 4355 Database Administration
Team: Ashton Murdock and Daniel Pham
Submission date: [actual]

## Executive summary
[Implemented system and measured results after testing]

## 1. Introduction & Problem
[Proposal problem, goals, scope and out-of-scope]

## 2. System / Database Architecture
[PostgreSQL version, OS, psql/pgAdmin, synthetic Python data, diagram from approved proposal]

## 3. Database Design
[Describe sellers/buyers/vehicles/offers, keys, CHECK constraints, indexes]

## 4. DBA Implementation
Security: [roles, GRANT/REVOKE, denied and allowed operations]
Optimization: [exact search predicates, index definitions, ANALYZE and plan selection]
Backup/recovery: [pg_dump/pg_restore, separate test DB, restore checks]

## 5. Implementation Evidence
Figure 1: [schema + caption/explanation]
Figure 2: [roles test + caption/explanation]
Figure 3: [before EXPLAIN plan + caption/explanation]
Figure 4: [after EXPLAIN plan + caption/explanation]
Figure 5: [restore log + caption/explanation]

## 6. Testing & Verification
| Test | Expected | Actual (attach evidence) | Pass/Fail |
|---|---|---|---|
| Generated 100,000 vehicles | 100000 | [query output] | [ ] |
| Foreign key validation | 0 broken links | [query output] | [ ] |
| Reader INSERT forbidden | Permission denied | [notice] | [ ] |
| Editor price UPDATE forbidden | Permission denied | [notice] | [ ] |
| Restore after data loss | Counts and records match | [logs] | [ ] |

## 7. Results & Discussion
| Query | Baseline median execution ms | Indexed median execution ms | Plan changes | Buffers |
|---|---:|---:|---|---|
| A Nissan 350Z | [ ] | [ ] | [ ] | [ ] |
| B Honda Civic | [ ] | [ ] | [ ] | [ ] |

Describe median from three measured `Execution Time` lines for each query.

## 8. Challenges & Limitations
[Document issues encountered; no real frontend or production workload]

## 9. Team Contributions
| Member | Implementation modules | Report contributions | Video/demo contributions |
|---|---|---|---|
| Daniel Pham | Schema, synthetic data, roles/security, backup/recovery | Architecture, dataset, security tests | Schema/data, permission tests, backup/restore |
| Ashton Murdock | Search queries, indexes, EXPLAIN ANALYZE comparisons | Index choice, performance results, recovery test analysis | Baseline and indexed plans |

Adjust to reflect **actual** work performed.

## 10. Conclusion & Future Work
[Actual results, realistic improvements]

## References
PostgreSQL official docs for GRANT, EXPLAIN, pg_dump and pg_restore; project proposal; other sources actually used.

GitHub: [actual accessible repository]
Recorded demo: [actual public/unlisted URL]
