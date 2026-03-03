# E12: Family Collaboration

**Story Count:** 3 | **Total Points:** 19 | **Priority:** P2 | **Sprint:** 9

---

## Epic Goal

Users can share shopping lists and meal plans with family members. Changes made by one family member are visible to others in real time.

**Prerequisite:** E11 (Authentication) must be complete.

---

## Stories

### US-E12.1: Household Group Management

**As a** user
**I want to** create a household group and invite family members to join
**So that** we can share lists and plans

**Story Points:** 7 | **Priority:** P2 | **Dependencies:** US-E11.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                                                 |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Domain    | `Household` entity: `id`, `name`, `ownerId`, `members List<HouseholdMember>`                                                                |
| Domain    | `HouseholdMember` value object: `userId`, `displayName`, `role` (owner/member), `joinedAt`                                                  |
| Domain    | `IHouseholdRepository`: `watchMyHousehold()`, `createHousehold(name)`, `generateInviteCode()`, `joinByCode(code)`, `removeMember(memberId)` |
| Data      | `HouseholdDataSource` (remote) + `HouseholdRepositoryImpl`                                                                                  |
| Use Cases | `CreateHouseholdUseCase(name)`, `GenerateInviteCodeUseCase()`, `JoinHouseholdUseCase(code)`, `LeaveHouseholdUseCase()`                      |
| Providers | `householdProvider`                                                                                                                         |
| UI        | Settings → "Family & Sharing" section                                                                                                       |
| UI        | "Create Household" form + member list                                                                                                       |
| UI        | "Invite" button → QR code or shareable link                                                                                                 |
| UI        | Pending invites list                                                                                                                        |
| Tests     | Unit: `JoinHouseholdUseCase` rejects expired or invalid invite code                                                                         |
| Tests     | Integration: create household → generate code → second user joins → member visible                                                          |

**Acceptance Criteria:**

- [ ] Settings shows "Family & Sharing" section
- [ ] User can create a household with a name
- [ ] Invite codes expire after 24 hours
- [ ] Joining household adds user to member list
- [ ] Owner can remove members
- [ ] User can leave their household (ownership must be transferred first if owner)
- [ ] Integration test: create → invite → join → verify member listed

---

### US-E12.2: Shared Shopping Lists

**As a** family member
**I want to** share a shopping list with my household
**So that** anyone can add items or check them off

**Story Points:** 6 | **Priority:** P2 | **Dependencies:** US-E12.1, US-E4.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                             |
| --------- | --------------------------------------------------------------------------------------- |
| DB        | `ShoppingListsTable` gains `householdId` (FK nullable), `isShared` boolean              |
| Use Cases | `ShareListWithHouseholdUseCase(listId, householdId)`                                    |
| Use Cases | `UnshareListUseCase(listId)`                                                            |
| Data      | `ShoppingListDataSource` extended to pull shared lists from household members           |
| UI        | Shopping list card shows "Shared" badge with member avatars                             |
| UI        | List detail app bar shows avatars of members currently viewing the list                 |
| UI        | Real-time updates via WebSocket or SSE when family member checks or adds an item        |
| Tests     | Unit: `ShareListUseCase` sets `householdId` and `isShared = true`                       |
| Tests     | Integration: User A checks item → User B sees item checked (may require mock websocket) |

**Acceptance Criteria:**

- [ ] Shopping list card has a "Share with family" action
- [ ] Shared list visible to all household members in their shopping tab
- [ ] Changes propagate in near-real-time to all members
- [ ] Unsharing removes household access for all members
- [ ] Integration test: share list → second user sees it in their list

---

### US-E12.3: Shared Meal Planning

**As a** family
**I want to** see and edit a shared meal plan
**So that** everyone knows what is planned for each meal

**Story Points:** 5 | **Priority:** P2 | **Dependencies:** US-E12.1, US-E6.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                            |
| --------- | ---------------------------------------------------------------------- |
| DB        | `MealPlansTable` gains `householdId` (FK nullable), `isShared` boolean |
| Use Cases | `ShareMealPlanUseCase(planId, householdId)`                            |
| UI        | Meal plan screen shows "Shared" badge in week header                   |
| UI        | Slot assignment by any family member updates shared plan in real time  |
| Tests     | Integration: User A assigns recipe → User B sees recipe in same slot   |

**Acceptance Criteria:**

- [ ] Meal plan sharing follows same pattern as shopping list sharing
- [ ] All household members can assign and clear slots
- [ ] Plan owner can resolve conflicts (last-write-wins as default)
- [ ] "Generate Shopping List" from a shared plan includes all assigned recipes

---

_See [\_index.md](_index.md) for the full epic list._
