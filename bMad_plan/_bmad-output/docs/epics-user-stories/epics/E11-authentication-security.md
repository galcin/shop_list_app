# E11: Authentication & Security

**Story Count:** 3 | **Total Points:** 16 | **Priority:** P1 | **Sprint:** 8

---

## Epic Goal

Users can register, log in, and log out securely. JWT tokens are stored safely, refreshed automatically, and user identity is available throughout the app.

---

## Stories

### US-E11.1: User Registration

**As a** new user
**I want to** create an account with an email address and password
**So that** I can have a personal, persistent data storage

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E10.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                      |
| --------- | ---------------------------------------------------------------------------------------------------------------- |
| Domain    | `User` entity: `id`, `email`, `displayName`, `avatarUrl?`                                                        |
| Domain    | `IAuthRepository`: `register(email, password, name)`, `login(email, password)`, `logout()`, `watchCurrentUser()` |
| Data      | `AuthDataSource` (remote) — calls POST `/auth/register`                                                          |
| Data      | `SecureStorageTokenStore` — stores JWT using `flutter_secure_storage`                                            |
| Use Cases | `RegisterUseCase(email, password, name)` — validates email format + password ≥ 8 chars                           |
| Providers | `authRepositoryProvider`, `currentUserProvider`                                                                  |
| State     | `AuthNotifier` — unauthenticated / loading / authenticated states                                                |
| UI        | `RegisterPage` — form: name, email, password, confirm password                                                   |
| UI        | Inline validation on each field                                                                                  |
| Router    | Redirect unauthenticated users to `/login`                                                                       |
| Tests     | Unit: `RegisterUseCase` rejects invalid email format                                                             |
| Tests     | Widget: `RegisterPage` shows errors for mismatched passwords                                                     |
| Tests     | Integration: register → verify user is logged in → home screen visible                                           |

**Acceptance Criteria:**

- [ ] Registration form has: name, email, password, confirm password
- [ ] Password must be ≥ 8 characters (shown as inline hint)
- [ ] Mismatched passwords show inline error before submit
- [ ] On success, user is navigated to home screen (logged in)
- [ ] JWT stored securely in `flutter_secure_storage`
- [ ] Integration test: register → home screen visible

---

### US-E11.2: Login & Logout

**As a** returning user
**I want to** log in with my email and password and log out when I'm done
**So that** my data is accessible to me and no one else

**Story Points:** 5 | **Priority:** P1 | **Dependencies:** US-E11.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                      |
| --------- | -------------------------------------------------------------------------------- |
| Data      | `AuthDataSource.login(email, password)` — calls POST `/auth/login`, stores token |
| Data      | `AuthDataSource.logout()` — clears stored token, calls POST `/auth/logout`       |
| Use Cases | `LoginUseCase(email, password)`                                                  |
| Use Cases | `LogoutUseCase()` — clears token, clears user from `AuthNotifier`                |
| UI        | `LoginPage` — email + password + "Login" button + "Sign up" link                 |
| UI        | "Forgot Password?" link (navigates to `PasswordResetPage` — stub acceptable)     |
| UI        | Settings → "Sign Out" option                                                     |
| Tests     | Unit: `LoginUseCase` stores tokens on success                                    |
| Tests     | Unit: `LogoutUseCase` clears tokens                                              |
| Tests     | Integration: login → see home; logout → redirected to login page                 |

**Acceptance Criteria:**

- [ ] Login form has email + password fields
- [ ] Invalid credentials show error snackbar
- [ ] On login success, navigated to home screen
- [ ] Settings has "Sign Out" option
- [ ] Signing out clears stored token and navigates to login page
- [ ] Integration test: login → logout → at login page

---

### US-E11.3: Token Refresh & Session Persistence

**As a** user
**I want to** stay logged in between app launches and have my token refreshed automatically
**So that** I don't have to log in every time I open the app

**Story Points:** 6 | **Priority:** P1 | **Dependencies:** US-E11.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                               |
| --------- | --------------------------------------------------------------------------------------------------------- |
| Data      | `AuthInterceptor` extended with auto-refresh: on 401 → call POST `/auth/refresh` → retry original request |
| Data      | Circular dependency guard: refresh request itself returns 401 → logout                                    |
| Use Cases | `InitialAuthCheckUseCase()` — called on app start; restores user from secure storage or forces re-login   |
| State     | `AuthNotifier` starts with `loading` state; resolves to `authenticated` or `unauthenticated`              |
| Router    | `SplashPage` shown while auth state loads — redirects to Home or Login                                    |
| Tests     | Unit: 401 on non-refresh endpoint triggers refresh and retries                                            |
| Tests     | Unit: 401 on refresh endpoint triggers logout                                                             |
| Tests     | Integration: start app with stored token → home screen visible (no login required)                        |

**Acceptance Criteria:**

- [ ] App shows splash screen while auth state is determined
- [ ] Valid stored token → lands on home screen without login screen
- [ ] Expired token → automatic refresh attempt before login redirect
- [ ] After 5 failed refreshes → user logged out and shown login page
- [ ] Integration test: cold start with stored token → home screen

---

_See [\_index.md](_index.md) for the full epic list._
