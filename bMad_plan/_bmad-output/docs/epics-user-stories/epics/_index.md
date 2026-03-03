# Epics & User Stories — Index

## Flutter Shopping List & Meal Planning App

**Document Version:** 5.0 | **Date:** March 3, 2026 | **Approach:** Vertical Slices

> Each epic file contains all user stories for that epic, including full vertical-slice deliverables, acceptance criteria, and test requirements.

---

## Why Vertical Slices?

Every story cuts through **all layers** (DB → Domain → Repository → Use Cases → Riverpod Providers → UI) so each completed story can be demo'd and tested from the UI immediately.

---

## Epic Files

| Epic | File                                                                 | Stories | Points | Priority | Sprint       |
| ---- | -------------------------------------------------------------------- | ------- | ------ | -------- | ------------ |
| E0   | [E0-foundation-infrastructure.md](E0-foundation-infrastructure.md)   | 7       | 34     | P0       | ✅ Done      |
| E1   | [E1-app-shell-navigation.md](E1-app-shell-navigation.md)             | 2       | 7      | P0       | Sprint 1     |
| E2   | [E2-product-category-feature.md](E2-product-category-feature.md)     | 3       | 14     | P0       | Sprint 1     |
| E3   | [E3-product-feature.md](E3-product-feature.md)                       | 3       | 15     | P0       | Sprint 2     |
| E4   | [E4-shopping-list-feature.md](E4-shopping-list-feature.md)           | 5       | 24     | P0       | Sprint 2–3   |
| E5   | [E5-recipe-management-feature.md](E5-recipe-management-feature.md)   | 5       | 26     | P0       | Sprint 3–4   |
| E6   | [E6-meal-planning-feature.md](E6-meal-planning-feature.md)           | 4       | 22     | P0       | Sprint 4–5   |
| E7   | [E7-pantry-inventory-feature.md](E7-pantry-inventory-feature.md)     | 3       | 16     | P0       | Sprint 5     |
| E8   | [E8-settings-data-management.md](E8-settings-data-management.md)     | 4       | 17     | P0       | Sprint 6     |
| E9   | [E9-sync-engine-queue.md](E9-sync-engine-queue.md)                   | 7       | 35     | P1       | Sprint 7–8   |
| E10  | [E10-cloud-backend-integration.md](E10-cloud-backend-integration.md) | 8       | 40     | P1       | Sprint 8–10  |
| E11  | [E11-authentication-security.md](E11-authentication-security.md)     | 6       | 29     | P1       | Sprint 10–11 |
| E12  | [E12-family-collaboration.md](E12-family-collaboration.md)           | 6       | 27     | P2       | Sprint 11–12 |
| E13  | [E13-smart-features-ai.md](E13-smart-features-ai.md)                 | 7       | 38     | P2       | Sprint 12–14 |
| E14  | [E14-performance-optimisation.md](E14-performance-optimisation.md)   | 6       | 26     | P1       | Sprint 14–15 |
| E15  | [E15-testing-quality-assurance.md](E15-testing-quality-assurance.md) | 8       | 32     | P0       | Ongoing      |

**MVP (E1–E8):** ~141 story points ≈ 7 sprints × 2 weeks = **14 weeks** for 2 developers

---

## Current Implementation Status (March 2026)

| Area                       | Status                                                                          |
| -------------------------- | ------------------------------------------------------------------------------- |
| E0 — Foundation            | ✅ ~90% Done                                                                    |
| Product Category (data+UI) | 🔶 Partial — table, entity, repo, pages exist; no use cases; no Riverpod wiring |
| Product (data+UI)          | 🔶 Partial — table, entity, repo, pages exist; no use cases; no Riverpod wiring |
| Recipes (data+partial UI)  | 🔶 Partial — table, entity, repo, list UI exist; no use cases                   |
| Meal Planning              | 🔶 UI skeleton only — no data layer yet                                         |
| Shopping Lists             | ❌ Not started                                                                  |
| Pantry                     | ❌ Not started                                                                  |

---

## Release Planning

### MVP v1.0 (Epics E1–E8)

| Sprint | Focus                               | Epics     | Points |
| ------ | ----------------------------------- | --------- | ------ |
| 1      | App Shell + Product Categories      | E1, E2    | ~21    |
| 2      | Products + Shopping List foundation | E3, E4 P0 | ~38    |
| 3      | Shopping List P1 features           | E4 P1–P2  | ~12    |
| 4      | Recipes                             | E5        | ~26    |
| 5      | Meal Planning                       | E6        | ~22    |
| 6      | Pantry + Settings                   | E7, E8    | ~33    |
| 7      | Bug fixes, polish, QA               | E15       | ~20    |

### v1.1 — Cloud Sync & Auth (E9–E12)

### v1.2 — Smart Features & Performance (E13–E14)

---

## Story Point Scale

| Points | Effort          |
| ------ | --------------- |
| 1      | 1–2 hours       |
| 2      | Half day        |
| 3      | Full day        |
| 5      | 2–3 days        |
| 8      | 3–5 days        |
| 13     | Needs splitting |

## Priority Levels

| Level | Meaning                      |
| ----- | ---------------------------- |
| P0    | MVP blocker                  |
| P1    | Core feature for product fit |
| P2    | Important enhancement        |
| P3    | Nice-to-have, future release |

---

## Technology Stack

| Concern          | Technology                                       |
| ---------------- | ------------------------------------------------ |
| Framework        | Flutter 3.16+                                    |
| Language         | Dart 3.2+                                        |
| State Management | Riverpod 2.x (`AsyncNotifier`, `StreamProvider`) |
| Local Database   | Drift 2.x (type-safe SQLite)                     |
| Functional       | Dartz (`Either<Failure, T>`)                     |
| JSON / Models    | freezed + json_serializable                      |
| Navigation       | GoRouter                                         |
| Settings         | shared_preferences                               |
| Testing          | flutter_test, mockito, integration_test, patrol  |
| CI/CD            | GitHub Actions                                   |
