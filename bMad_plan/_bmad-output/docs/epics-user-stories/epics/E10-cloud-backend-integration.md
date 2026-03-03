# E10: Cloud Backend Integration

**Story Count:** 3 | **Total Points:** 21 | **Priority:** P1 | **Sprint:** 7–8

---

## Epic Goal

Connect the app to a cloud REST or GraphQL backend so data is persisted server-side and accessible from any device.

**Prerequisite:** A backend API must exist (or be mocked). Stories assume a REST API with JWT auth.

---

## Stories

### US-E10.1: API Client Setup & Auth Headers

**As a** developer
**I want to** have a centralised HTTP client that attaches auth tokens to every request
**So that** all API calls are authenticated without repeating token logic

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** E0, E11

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                            |
| --------- | ---------------------------------------------------------------------- |
| Core      | `ApiClient` (Dio) with base URL, timeout, JSON content-type            |
| Core      | `AuthInterceptor` — injects `Authorization: Bearer <token>` header     |
| Core      | `LoggingInterceptor` — logs requests/responses in debug mode           |
| Core      | `ApiErrorMapper` — maps HTTP status codes to `Failure` subtypes        |
| Providers | `apiClientProvider` (singleton), `authInterceptorProvider`             |
| Tests     | Unit: `AuthInterceptor` attaches token to outgoing request headers     |
| Tests     | Unit: `ApiErrorMapper` maps 401 → `AuthFailure`, 500 → `ServerFailure` |

**Acceptance Criteria:**

- [ ] All HTTP requests include `Authorization` header
- [ ] 401 response triggers token refresh (or logout)
- [ ] Network errors map to `NetworkFailure`
- [ ] Requests and responses logged in debug builds only

---

### US-E10.2: Remote Data Sources for Core Entities

**As a** developer
**I want to** have remote data sources for Products, Categories, Recipes, Shopping Lists, and Pantry
**So that** data can be read from and written to the cloud backend

**Story Points:** 10 | **Priority:** P1 | **Dependencies:** US-E10.1, E2–E7

**Vertical Slice Deliverables:**

| Layer | Deliverable                                                                                |
| ----- | ------------------------------------------------------------------------------------------ |
| Data  | `IRemoteProductCategoryDataSource`, `RemoteProductCategoryDataSourceImpl`                  |
| Data  | `IRemoteProductDataSource`, `RemoteProductDataSourceImpl`                                  |
| Data  | `IRemoteRecipeDataSource`, `RemoteRecipeDataSourceImpl`                                    |
| Data  | `IRemoteShoppingListDataSource`, `RemoteShoppingListDataSourceImpl`                        |
| Data  | `IRemotePantryDataSource`, `RemotePantryDataSourceImpl`                                    |
| Data  | Each implements: `getAll()`, `getById(id)`, `create(dto)`, `update(id, dto)`, `delete(id)` |
| Data  | Request/response DTOs with `fromJson` / `toJson`                                           |
| Tests | Unit: each remote data source serialises requests and deserialises responses               |
| Tests | Integration: each remote data source hits a mock server successfully                       |

**Acceptance Criteria:**

- [ ] Each remote data source compiles and has full CRUD operations
- [ ] DTOs validated for null-safety
- [ ] HTTP errors propagated as `Failure` subtypes
- [ ] Mock server integration tests pass for all 5 data sources

---

### US-E10.3: Dual Repository Strategy (Offline-First)

**As a** developer
**I want to** repositories to serve local Drift data immediately and sync with remote in the background
**So that** the app is fast and works offline

**Story Points:** 6 | **Priority:** P1 | **Dependencies:** US-E10.2, US-E9.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                               |
| --------- | ----------------------------------------------------------------------------------------- |
| Data      | Each `RepositoryImpl` gains a remote data source parameter                                |
| Data      | Read: always return from local DB; background `sync()` fetches remote and updates local   |
| Data      | Write: write local first; enqueue to `SyncQueue` via `EnqueueMutationUseCase`             |
| Use Cases | `SyncEntitiesUseCase<T>(entityType)` — pulls remote, writes to local                      |
| Tests     | Integration: write local → verify sync queue entry → process queue → verify remote called |

**Acceptance Criteria:**

- [ ] `watchAll()` always resolves from local DB (not blocked on network)
- [ ] After first sync, local DB is populated from remote
- [ ] Writes enqueue to `SyncQueue` immediately
- [ ] Offline writes are not lost when connectivity returns

---

_See [\_index.md](_index.md) for the full epic list._
