# E14: Performance Optimisation

**Story Count:** 3 | **Total Points:** 15 | **Priority:** P2 | **Sprint:** 9

---

## Epic Goal

Ensure the app is fast, responsive, and memory-efficient — meeting startup, frame rate, and DB performance targets.

**Note:** These stories are primarily engineering investment. Tackle them after E1–E8 are stable.

---

## Performance Targets

| Metric                              | Target              |
| ----------------------------------- | ------------------- |
| Cold start (non-first launch)       | < 2 seconds         |
| Frame rate during scroll            | ≥ 60 fps (no jank)  |
| Shopping list query (500 items)     | < 50 ms             |
| Sync queue processing (100 entries) | < 2 seconds         |
| App binary size                     | < 20 MB (non-debug) |

---

## Stories

### US-E14.1: Database Indexing & Query Optimisation

**As a** developer
**I want to** add database indexes on frequently queried columns
**So that** queries remain fast even with large amounts of data

**Story Points:** 5 | **Priority:** P2 | **Dependencies:** E2–E7

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                                                                                                                                                                                     |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DB    | Indexes: `product_category_table(sort_order)`, `product_table(category_id)`, `shopping_items_table(list_id, is_checked)`, `recipe_table(created_at)`, `pantry_items_table(expiry_date)`, `sync_queue_table(status, created_at)` |
| DB    | Drift migration adding new indexes                                                                                                                                                                                              |
| Tests | Performance test: query 1,000 shopping items by `listId` < 50 ms                                                                                                                                                                |
| Tests | Performance test: search 5,000 products by name < 100 ms                                                                                                                                                                        |

**Acceptance Criteria:**

- [ ] All indexes added via Drift schema migration
- [ ] No existing tests broken by migration
- [ ] Performance test: 500 item list query < 50 ms

---

### US-E14.2: List Virtualisation & Lazy Loading

**As a** user
**I want to** scroll through long lists without the app lagging
**So that** the experience is smooth even with hundreds of items

**Story Points:** 5 | **Priority:** P2 | **Dependencies:** E2–E7

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                                   |
| ----- | ----------------------------------------------------------------------------- |
| Data  | Pagination added to Drift queries: `watchPage(offset, limit)` on large tables |
| UI    | Replace all large `ListView` instances with `ListView.builder` (lazy render)  |
| UI    | Infinite scroll pagination where lists can exceed 100 items                   |
| State | `PaginatedNotifier<T>` base class for paginated async state                   |
| Tests | Widget test: scroll to bottom → second page loads                             |

**Acceptance Criteria:**

- [ ] All lists with potential for > 20 items use `ListView.builder`
- [ ] Infinite scroll triggers next page load when near bottom
- [ ] No dropped frames during scroll (verified with Flutter DevTools)
- [ ] Memory usage does not grow unbounded with pagination

---

### US-E14.3: App Startup Optimisation

**As a** user
**I want to** see the app ready in under 2 seconds after tapping the icon
**So that** the app feels instant

**Story Points:** 5 | **Priority:** P2 | **Dependencies:** E11

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                                         |
| ----- | ----------------------------------------------------------------------------------- |
| Core  | Defer non-critical providers (sync, analytics) using `Riverpod` lazy initialisation |
| Core  | Move heavy init (DB migration, auth check) to a `SplashPage` future                 |
| Core  | Disable debug logs and DevTools extensions in release builds                        |
| Tests | Startup benchmark: measure time from `main()` to first interactive frame            |

**Acceptance Criteria:**

- [ ] Cold start (second launch) < 2 seconds on a mid-range device
- [ ] Splash screen shown while auth + DB init runs (never blank white screen)
- [ ] Non-critical providers initialised after first frame is shown
- [ ] Release APK size < 20 MB

---

_See [\_index.md](_index.md) for the full epic list._
