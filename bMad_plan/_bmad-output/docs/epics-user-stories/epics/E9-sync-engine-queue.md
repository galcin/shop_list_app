# E9: Sync Engine & Queue

**Story Count:** 3 | **Total Points:** 21 | **Priority:** P1 | **Sprint:** 7

---

## Epic Goal

Establish a robust offline-first sync mechanism that queues local mutations while offline and replays them against the cloud backend when connectivity is restored.

**Prerequisite:** E10 (Cloud Backend) must be at least partially available for integration testing.

---

## Stories

### US-E9.1: Sync Queue Infrastructure

**As a** developer
**I want to** record every local mutation (create / update / delete) in a `SyncQueue` table
**So that** no change is lost while offline

**Story Points:** 8 | **Priority:** P1 | **Dependencies:** E0 (SyncQueue table), E8

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                                                        |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DB        | `SyncQueueTable` (exists) — verify: `id`, `entityType`, `entityId`, `operation` (CREATE/UPDATE/DELETE), `payload`, `createdAt`, `retryCount`, `status` (pending/processing/failed) |
| Domain    | `SyncQueueEntry` entity                                                                                                                                                            |
| Data      | `SyncQueueDataSource` — `add()`, `markProcessing()`, `markFailed()`, `removeDone()`, `watchPending()`                                                                              |
| Use Cases | `EnqueueMutationUseCase(entityType, entityId, operation, payload)`                                                                                                                 |
| Use Cases | `GetPendingSyncEntriesUseCase()`                                                                                                                                                   |
| Providers | `syncQueueProvider`                                                                                                                                                                |
| Tests     | Unit: enqueueing 3 mutations → all appear as pending entries                                                                                                                       |
| Tests     | Integration: create 2 items offline → 2 queue entries visible in pending list                                                                                                      |

**Acceptance Criteria:**

- [ ] Every `save()` and `delete()` call in any repository enqueues a sync entry
- [ ] Queue entries have: `entityType`, `entityId`, `operation`, serialised `payload`
- [ ] Queue is queryable by status (pending / processing / failed)
- [ ] Integration test: create 2 items offline → 2 pending queue entries

---

### US-E9.2: Sync Engine — Process Queue When Online

**As a** user
**I want to** see my changes automatically synced to the cloud when I go online
**So that** data is consistent across devices

**Story Points:** 8 | **Priority:** P1 | **Dependencies:** US-E9.1, US-E10.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                            |
| --------- | ------------------------------------------------------------------------------------------------------ |
| Use Cases | `ProcessSyncQueueUseCase()` — iterates pending entries, calls API, marks done or increments retryCount |
| Use Cases | Retry strategy: exponential back-off (1s, 2s, 4s, max 60s), max 5 retries, then `failed`               |
| Data      | `SyncQueueDataSource.markProcessing(id)`, `markDone(id)`, `markFailed(id, error)`                      |
| Providers | `syncEngineProvider` — triggered by network change events                                              |
| UI        | Sync status badge on Settings tab icon: 0 pending = no badge; N pending = badge                        |
| UI        | Settings → Sync Status page: list of pending/failed entries                                            |
| Tests     | Unit: process queue sends each entry to API and marks done                                             |
| Tests     | Unit: API 4xx on entry → marks failed after max retries                                                |
| Tests     | Integration: create items offline → go online → queue clears                                           |

**Acceptance Criteria:**

- [ ] Queue is processed automatically when `NetworkInfo` reports connectivity
- [ ] Sync is idempotent (replaying a processed entry does not create duplicates)
- [ ] Failed entries (after max retries) are retained with error message for user review
- [ ] Sync status badge visible in Settings tab
- [ ] Integration test: offline create → go online → queue clears → no duplicates

---

### US-E9.3: Conflict Resolution

**As a** user
**I want to** have conflicts resolved automatically when the same item is edited on two devices
**So that** I never lose data or see weird duplicates

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E9.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                    |
| --------- | ------------------------------------------------------------------------------ |
| Domain    | Conflict resolution strategy: "last write wins" based on `updatedAt` timestamp |
| Use Cases | `ResolveConflictUseCase(localEntry, serverEntry)` — picks winner               |
| Tests     | Unit: server record with later `updatedAt` wins over local                     |
| Tests     | Unit: local record with later `updatedAt` wins over server                     |
| Tests     | Unit: equal timestamps → server wins (conservative)                            |

**Acceptance Criteria:**

- [ ] Conflict resolved automatically using last-write-wins on `updatedAt`
- [ ] When server wins, local record is updated to match server
- [ ] When local wins, local version is sent to server as an update
- [ ] No duplicate records created during conflict resolution
- [ ] Unit tests cover all three timestamp scenarios

---

_See [\_index.md](_index.md) for the full epic list._
