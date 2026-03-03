# E13: Smart Features & AI Integration

**Story Count:** 3 | **Total Points:** 20 | **Priority:** P3 | **Sprint:** 10

---

## Epic Goal

Add AI-assisted features: smart item parsing from free-text, recipe suggestions based on pantry contents, and predictive shopping list generation.

**Note:** These are post-MVP enhancements. Implement them as optional features that degrade gracefully when AI is unavailable.

---

## Stories

### US-E13.1: Smart Text Parsing for Shopping Items

**As a** user
**I want to** type a natural-language shopping item like "2 kg of rice" and have it parsed automatically
**So that** I don't have to fill in quantity, unit, and name separately

**Story Points:** 6 | **Priority:** P3 | **Dependencies:** US-E4.2

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                 |
| --------- | --------------------------------------------------------------------------- |
| Domain    | `ParsedShoppingItem` value object: `name`, `quantity`, `unit`               |
| Data      | `SmartParseDataSource` — calls AI endpoint (POST `/ai/parse-item`)          |
| Use Cases | `ParseShoppingItemUseCase(rawText)` → `Either<Failure, ParsedShoppingItem>` |
| UI        | `AddItemBottomSheet` — single text field with "Smart add" mode              |
| UI        | After parse: show parsed fields for confirmation before saving              |
| UI        | Manual fallback fields visible if parse fails or user prefers               |
| Tests     | Unit: parse "2 kg of rice" → `{name: rice, quantity: 2, unit: kg}`          |
| Tests     | Unit: parse failure → falls back gracefully, fields remain editable         |

**Acceptance Criteria:**

- [ ] Smart add mode available in the add-item sheet (toggle)
- [ ] Parsing shows extracted quantity, unit, and name for confirmation
- [ ] User can edit any parsed field before saving
- [ ] Parse failure shows a helpful message + manual form fallback
- [ ] No crash when AI service is unavailable

---

### US-E13.2: Recipe Suggestions from Pantry

**As a** user
**I want to** get recipe suggestions based on what I have in my pantry
**So that** I can reduce food waste and decide what to cook

**Story Points:** 8 | **Priority:** P3 | **Dependencies:** US-E7.1, US-E5.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                                    |
| --------- | -------------------------------------------------------------------------------------------------------------- |
| Use Cases | `GetPantryBasedRecipeSuggestionsUseCase()` — sends pantry inventory to AI endpoint, returns ranked recipe list |
| Data      | `RecipeSuggestionDataSource` — POST `/ai/suggest-recipes` with pantry contents                                 |
| Domain    | `RecipeSuggestion` value object: `recipe`, `matchScore`, `missingIngredients`                                  |
| UI        | "Suggest recipes" floating button on Pantry page                                                               |
| UI        | `RecipeSuggestionsPage` — cards showing match %, recipe name, missing ingredients                              |
| UI        | "Add missing to shopping list" one-tap action on suggestion card                                               |
| Tests     | Unit: suggestions sorted by descending `matchScore`                                                            |
| Tests     | Integration: suggestions with missing ingredients → one-tap adds them to shopping list                         |

**Acceptance Criteria:**

- [ ] "Suggest recipes" button visible on Pantry page
- [ ] Suggestions ranked by match score (% of ingredients available)
- [ ] Each suggestion card shows name, thumbnail, match %, missing ingredients
- [ ] One-tap adds all missing ingredients to a new shopping list
- [ ] Feature gracefully disabled when AI service unavailable

---

### US-E13.3: Predictive Shopping List Generation

**As a** user
**I want to** generate a shopping list based on my purchase history and upcoming meal plan
**So that** I don't forget regularly needed items

**Story Points:** 6 | **Priority:** P3 | **Dependencies:** US-E9.1, US-E6.1

**Vertical Slice Deliverables:**

| Layer     | Deliverable                                                                                |
| --------- | ------------------------------------------------------------------------------------------ |
| Data      | `PredictiveListDataSource` — POST `/ai/predict-shopping` with purchase history + meal plan |
| Use Cases | `GeneratePredictiveListUseCase()` → predicted shopping items                               |
| UI        | Settings → "AI Features" → "Generate smart shopping list"                                  |
| UI        | Preview page showing predicted items with confidence indicators                            |
| UI        | User can deselect individual items before adding to a list                                 |
| Tests     | Unit: use case deduplicates predictions against existing shopping list items               |

**Acceptance Criteria:**

- [ ] Smart list accessible from Settings → AI Features
- [ ] Predicted items show confidence indicator (high / medium / low)
- [ ] User confirms items before they are added
- [ ] Items already in an active shopping list are excluded from predictions
- [ ] Feature gracefully disabled when AI service unavailable

---

_See [\_index.md](_index.md) for the full epic list._
