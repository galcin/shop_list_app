# Epics and User Stories

## Flutter Shopping List & Meal Planning App

**Document Version:** 1.0  
**Date:** February 26, 2026  
**Author:** BMad Master  
**Status:** Ready for Development  
**Related Documents:** [PRD](prd-shopping-list-app.md), [Architecture](architecture-shopping-list-app.md), [UX Design](ux-design-shopping-list-app.md)

---

## Document Overview

This document organizes all development work into **Epics** (large feature areas) and **User Stories** (specific deliverable features). Each story includes acceptance criteria, story points, priority, and dependencies to support sprint planning and development.

### Story Point Scale

- **1 point:** 1-2 hours (trivial changes)
- **2 points:** Half day (simple feature)
- **3 points:** Full day (standard feature)
- **5 points:** 2-3 days (complex feature)
- **8 points:** 3-5 days (very complex)
- **13 points:** 1-2 weeks (should be split)

### Priority Levels

- **P0 (Critical):** MVP requirement, app doesn't work without it
- **P1 (High):** Core feature, needed for product-market fit
- **P2 (Medium):** Important but can launch without it
- **P3 (Low):** Nice-to-have, future enhancement

---

## Table of Contents

1. [Epic Summary](#epic-summary)
2. [Epic 1: Shopping List Management](#epic-1-shopping-list-management)
3. [Epic 2: Meal Planning](#epic-2-meal-planning)
4. [Epic 3: Recipe Management](#epic-3-recipe-management)
5. [Epic 4: Pantry & Inventory](#epic-4-pantry--inventory)
6. [Epic 5: Offline & Sync](#epic-5-offline--sync)
7. [Epic 6: Family & Collaboration](#epic-6-family--collaboration)
8. [Epic 7: Smart Features & AI](#epic-7-smart-features--ai)
9. [Epic 8: User Settings & Privacy](#epic-8-user-settings--privacy)
10. [Epic 9: Onboarding & Help](#epic-9-onboarding--help)
11. [Release Planning](#release-planning)

---

## Epic Summary

| Epic ID   | Epic Name                | Total Stories | Total Points | Priority | Target Release |
| --------- | ------------------------ | ------------- | ------------ | -------- | -------------- |
| E1        | Shopping List Management | 8             | 31           | P0       | MVP v1.0       |
| E2        | Meal Planning            | 7             | 38           | P0       | MVP v1.0       |
| E3        | Recipe Management        | 9             | 45           | P0       | MVP v1.0       |
| E4        | Pantry & Inventory       | 6             | 29           | P0       | MVP v1.0       |
| E5        | Offline & Sync           | 5             | 34           | P0       | MVP v1.0       |
| E6        | Family & Collaboration   | 6             | 27           | P1       | v1.1           |
| E7        | Smart Features & AI      | 7             | 41           | P1       | v1.2           |
| E8        | User Settings & Privacy  | 5             | 18           | P0/P1    | MVP v1.0       |
| E9        | Onboarding & Help        | 4             | 15           | P0       | MVP v1.0       |
| **Total** |                          | **57**        | **278**      |          |                |

**MVP Scope:** Epics E1, E2, E3, E4, E5, E8, E9 = **210 story points** (~10-12 weeks for 2 developers)

---

## Epic 1: Shopping List Management

**Epic Goal:** Enable users to create, manage, and organize shopping lists with offline support and intuitive item entry methods.

**Business Value:** Core app functionality - users must have reliable shopping list management to find the app useful.

**Story Count:** 8 stories | **Total Points:** 31

---

### US-1.1: Create and Manage Shopping Lists

**As a** user  
**I want to** create multiple shopping lists with custom names  
**So that** I can organize different shopping trips (weekly groceries, party supplies, etc.)

**Acceptance Criteria:**

- [ ] User can create new shopping list with custom name
- [ ] User can view all shopping lists
- [ ] User can rename existing shopping lists
- [ ] User can delete shopping lists (with confirmation)
- [ ] User can mark one list as "active" (default for quick adds)
- [ ] Empty state shows helpful prompt to create first list

**Technical Notes:**

- Local storage with Hive/Drift
- List model: `id`, `name`, `createdAt`, `updatedAt`, `isActive`, `itemCount`
- Implement soft delete with recovery option

**Story Points:** 3  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Unit tests for CRUD operations, widget tests for UI

---

### US-1.2: Add Items to Shopping List

**As a** user  
**I want to** add items to my shopping list via text, voice, or photo  
**So that** I can quickly capture what I need to buy

**Acceptance Criteria:**

- [ ] Text input with autocomplete from previous items
- [ ] Voice input using speech-to-text
- [ ] Photo capture with optional AI product recognition
- [ ] Manual quantity and unit entry (optional)
- [ ] Category auto-assignment based on item type
- [ ] Duplicate detection with merge option

**Technical Notes:**

- Speech recognition: Flutter `speech_to_text` package
- Photo recognition: ML Kit or Google Cloud Vision API (deferred processing if offline)
- Item model: `id`, `name`, `quantity`, `unit`, `category`, `isPurchased`, `notes`

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** US-1.1  
**Acceptance Tests:** E2E test for each input method

---

### US-1.3: Organize Items by Category

**As a** user  
**I want to** see shopping list items grouped by category  
**So that** I can shop efficiently aisle by aisle

**Acceptance Criteria:**

- [ ] Items auto-grouped by category (Produce, Dairy, Meat, Bakery, etc.)
- [ ] User can manually change item category
- [ ] Categories sorted by typical store layout
- [ ] User can customize category order
- [ ] Collapse/expand category sections
- [ ] Show item count per category

**Technical Notes:**

- Predefined category list with icons
- User preferences for category ordering stored locally
- Category model: `id`, `name`, `icon`, `sortOrder`, `colorCode`

**Story Points:** 3  
**Priority:** P0 (MVP)  
**Dependencies:** US-1.2  
**Acceptance Tests:** Widget tests for categorization, sorting

---

### US-1.4: Check Off Purchased Items

**As a** shopper in a store  
**I want to** check off items as I purchase them  
**So that** I track what's in my cart and what remains

**Acceptance Criteria:**

- [ ] Tap item to toggle purchased state
- [ ] Visual indication (checkbox, strikethrough)
- [ ] Purchased items move to bottom or separate section
- [ ] Undo accidental check-off
- [ ] Show progress indicator (5/12 items purchased)
- [ ] Option to hide completed items

**Technical Notes:**

- Optimistic UI updates
- Local state management with Riverpod
- Persist state immediately to local DB

**Story Points:** 2  
**Priority:** P0 (MVP)  
**Dependencies:** US-1.2  
**Acceptance Tests:** Widget interaction tests

---

### US-1.5: Offline Shopping List Access

**As a** shopper in a store with poor connectivity  
**I want to** access and modify my shopping list offline  
**So that** I can use the app regardless of network availability

**Acceptance Criteria:**

- [ ] All shopping lists accessible without internet
- [ ] All CRUD operations work offline
- [ ] Changes saved to local database immediately
- [ ] No loading delays or errors when offline
- [ ] Sync status indicator visible but non-intrusive

**Technical Notes:**

- Offline-first architecture (local DB as source of truth)
- Sync queue for changes to propagate when online
- Network status detection

**Story Points:** 5 (includes offline infrastructure setup)  
**Priority:** P0 (MVP)  
**Dependencies:** US-1.1, US-1.2, E5 (Offline & Sync)  
**Acceptance Tests:** Integration tests simulating offline scenarios

---

### US-1.6: View List in Grid or List Mode

**As a** user  
**I want to** toggle between grid and list view  
**So that** I can choose the layout that works best for me

**Acceptance Criteria:**

- [ ] Toggle button switches between list and grid view
- [ ] Grid view shows items as cards with images
- [ ] List view shows compact rows
- [ ] View preference persists across sessions
- [ ] Smooth transition animation between views

**Technical Notes:**

- Shared Preferences for view mode storage
- GridView and ListView widgets with same data source
- Animated switcher for transitions

**Story Points:** 2  
**Priority:** P2 (Nice-to-have)  
**Dependencies:** US-1.2  
**Acceptance Tests:** Widget tests for both views

---

### US-1.7: Edit and Delete Items

**As a** user  
**I want to** edit or remove items from my shopping list  
**So that** I can fix mistakes or change my mind

**Acceptance Criteria:**

- [ ] Swipe left/right to reveal edit and delete actions
- [ ] Tap item to open edit dialog
- [ ] Edit item name, quantity, category, notes
- [ ] Delete with undo snackbar (3 second revert window)
- [ ] Bulk delete selected items
- [ ] Confirmation for bulk operations

**Technical Notes:**

- Dismissible widget for swipe actions
- Dialog form for editing
- Soft delete with recovery

**Story Points:** 3  
**Priority:** P0 (MVP)  
**Dependencies:** US-1.2  
**Acceptance Tests:** Widget tests for edit/delete flows

---

### US-1.8: Share Shopping List

**As a** household member  
**I want to** share my shopping list with family  
**So that** anyone can shop from the same list

**Acceptance Criteria:**

- [ ] Generate shareable link or QR code
- [ ] Share via messaging, email, or clipboard
- [ ] Recipient can view list in web browser (read-only)
- [ ] Optional: Allow recipient to install app from link
- [ ] Shared list updates in real-time when synced

**Technical Notes:**

- Generate unique share token
- Public read-only API endpoint for shared lists
- Deep linking for app installation
- Real-time sync via WebSocket or Firebase Firestore listeners

**Story Points:** 8  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-1.1, E5 (Sync), E6 (Collaboration)  
**Acceptance Tests:** Integration tests for sharing flow

---

## Epic 2: Meal Planning

**Epic Goal:** Enable users to plan weekly meals, auto-generate shopping lists from meal plans, and match recipes against pantry inventory.

**Business Value:** Core differentiation - integrating meal planning with shopping is key value proposition.

**Story Count:** 7 stories | **Total Points:** 38

---

### US-2.1: Weekly Meal Calendar

**As a** meal planner  
**I want to** view a 7-day calendar to plan my meals  
**So that** I can visualize my weekly menu at a glance

**Acceptance Criteria:**

- [ ] Calendar displays 7 days (Monday-Sunday or user-defined start)
- [ ] Each day shows 3 meal slots (Breakfast, Lunch, Dinner)
- [ ] Tap slot to assign recipe
- [ ] Empty slots show placeholder "Tap to add meal"
- [ ] Navigate to previous/next week
- [ ] Jump to specific date

**Technical Notes:**

- Calendar widget using Flutter `table_calendar` or custom
- MealPlan model: `id`, `date`, `mealType`, `recipeId`, `servings`
- Efficient date-based queries

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Widget tests for calendar navigation

---

### US-2.2: Assign Recipes to Meal Slots

**As a** meal planner  
**I want to** assign recipes to specific meal slots  
**So that** I know what to cook each day

**Acceptance Criteria:**

- [ ] Tap meal slot to open recipe picker
- [ ] Search and filter recipes in picker
- [ ] Select recipe to assign to slot
- [ ] Preview recipe before assigning
- [ ] Drag-drop recipe between slots (optional)
- [ ] Remove recipe from slot

**Technical Notes:**

- Modal bottom sheet for recipe selection
- Recipe picker with search, filters, favorites
- Optimistic UI update

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** US-2.1, E3 (Recipe Management)  
**Acceptance Tests:** Integration tests for assignment flow

---

### US-2.3: Auto-Generate Shopping List from Meal Plan

**As a** meal planner  
**I want to** automatically create a shopping list from my weekly meal plan  
**So that** I don't manually transcribe ingredients

**Acceptance Criteria:**

- [ ] "Generate Shopping List" button on meal planner
- [ ] Collect all ingredients from assigned recipes
- [ ] Consolidate duplicate ingredients (sum quantities)
- [ ] Cross-reference pantry inventory
- [ ] Only include items not in stock (or below threshold)
- [ ] Preview generated list before creating
- [ ] Allow manual edits before finalizing

**Technical Notes:**

- Ingredient aggregation algorithm
- Unit conversion for consolidation (cups, tbsp, etc.)
- Pantry stock checking
- Create shopping list with link to meal plan

**Story Points:** 8  
**Priority:** P0 (MVP)  
**Dependencies:** US-2.1, US-2.2, E3 (Recipes), E4 (Pantry)  
**Acceptance Tests:** Unit tests for ingredient consolidation logic

---

### US-2.4: Recipe-Pantry Matching ("What Can I Make?")

**As a** cook  
**I want to** see which recipes I can make with my current pantry  
**So that** I use what I have before buying more

**Acceptance Criteria:**

- [ ] "What Can I Make?" filter in recipe list
- [ ] Match recipes against pantry inventory
- [ ] Show complete matches first (100% ingredients available)
- [ ] Show partial matches with missing ingredient count
- [ ] Sort by completion percentage
- [ ] Highlight missing ingredients in recipe view
- [ ] One-tap add missing items to shopping list

**Technical Notes:**

- Recipe-ingredient matching algorithm
- Ingredient normalization for matching
- Performance optimization for large pantries

**Story Points:** 8  
**Priority:** P0 (MVP)  
**Dependencies:** E3 (Recipes), E4 (Pantry)  
**Acceptance Tests:** Unit tests for matching algorithm

---

### US-2.5: Copy Previous Week's Meal Plan

**As a** busy meal planner  
**I want to** duplicate last week's meal plan  
**So that** I can reuse successful menus without starting from scratch

**Acceptance Criteria:**

- [ ] "Copy from previous week" button
- [ ] Select which week to copy from
- [ ] Option to copy all meals or select specific days
- [ ] Preview before confirming
- [ ] Adjust servings if needed
- [ ] Overwrite or merge with existing plan

**Technical Notes:**

- Date offset calculation
- Bulk meal plan creation
- Conflict resolution for existing meals

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-2.1, US-2.2  
**Acceptance Tests:** Integration tests for copy operation

---

### US-2.6: Serving Size Adjustment

**As a** meal planner  
**I want to** adjust recipe servings when planning meals  
**So that** I cook the right amount for my household

**Acceptance Criteria:**

- [ ] Set default household size in settings
- [ ] Override servings per meal slot
- [ ] Ingredient quantities scale proportionally
- [ ] Shopping list reflects adjusted quantities
- [ ] Common fractions (1/2, 1/3, 1/4) handled correctly
- [ ] Visual indicator shows serving adjustment

**Technical Notes:**

- Recipe scaling algorithm
- Fraction normalization
- Rounding logic for practical measurements

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-2.2, US-2.3  
**Acceptance Tests:** Unit tests for scaling calculations

---

### US-2.7: Meal Plan Templates

**As a** user seeking inspiration  
**I want to** use pre-built meal plan templates  
**So that** I can quickly adopt healthy eating patterns

**Acceptance Criteria:**

- [ ] Library of meal plan templates (Vegetarian Week, Budget Friendly, etc.)
- [ ] Preview template before applying
- [ ] Apply template to current week
- [ ] Templates include recipes or recipe suggestions
- [ ] User can create custom templates from their plans
- [ ] Share templates with community (future)

**Technical Notes:**

- Template data structure (JSON or model)
- Template marketplace (cloud-based, future)
- User-created template storage

**Story Points:** 5  
**Priority:** P2 (Future)  
**Dependencies:** US-2.1, US-2.2  
**Acceptance Tests:** Widget tests for template application

---

## Epic 3: Recipe Management

**Epic Goal:** Enable users to create, import, organize, and discover recipes with rich media support.

**Business Value:** Essential content foundation - app needs robust recipe library for meal planning.

**Story Count:** 9 stories | **Total Points:** 45

---

### US-3.1: Manual Recipe Entry

**As a** user  
**I want to** manually enter my own recipes  
**So that** I can digitize my cookbook collection

**Acceptance Criteria:**

- [ ] Form with fields: title, description, servings, prep time, cook time
- [ ] Multi-step ingredient entry with quantity, unit, name
- [ ] Rich text editor for instructions
- [ ] Add multiple photos via camera or gallery
- [ ] Tag categories (cuisine, meal type, difficulty)
- [ ] Save as draft or publish
- [ ] Preview before saving

**Technical Notes:**

- Recipe model with nested ingredients, instructions
- Image upload to local storage (cloud sync later)
- Rich text editor: `flutter_quill` or `html_editor`
- Draft storage for recovery

**Story Points:** 8  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Integration tests for recipe creation

---

### US-3.2: Recipe URL Import

**As a** user  
**I want to** import recipes from website URLs  
**So that** I quickly save online recipes

**Acceptance Criteria:**

- [ ] Paste URL into import field
- [ ] Auto-extract title, ingredients, instructions, images
- [ ] Support major recipe sites (AllRecipes, NYT Cooking, Food Network)
- [ ] Preview extracted data before saving
- [ ] Manual edit imported recipe
- [ ] Handle failed imports with fallback to manual entry

**Technical Notes:**

- Web scraping or recipe schema parsing
- Support for Recipe Schema (schema.org/Recipe)
- Cloud function for scraping (avoid app bloat)
- Rate limiting and error handling

**Story Points:** 8  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-3.1  
**Acceptance Tests:** Integration tests with test URLs

---

### US-3.3: Recipe Search and Filter

**As a** user  
**I want to** search and filter my recipe library  
**So that** I can quickly find recipes matching my needs

**Acceptance Criteria:**

- [ ] Full-text search across title, ingredients, tags
- [ ] Filter by category (cuisine, meal type, difficulty)
- [ ] Filter by dietary restrictions (vegetarian, vegan, gluten-free)
- [ ] Filter by prep/cook time
- [ ] Multi-select filters
- [ ] Save filter presets
- [ ] Sort by: name, date added, rating, cook time

**Technical Notes:**

- Search index for fast full-text search
- Multi-criteria filter logic
- Filter persistence in preferences

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** US-3.1  
**Acceptance Tests:** Unit tests for search/filter logic

---

### US-3.4: Recipe Detail View

**As a** user  
**I want to** view complete recipe details  
**So that** I can follow cooking instructions

**Acceptance Criteria:**

- [ ] Display title, photo, description, servings
- [ ] Ingredient list with quantities
- [ ] Step-by-step instructions
- [ ] Prep time, cook time, total time
- [ ] Category tags
- [ ] Add to meal plan button
- [ ] Add ingredients to shopping list button
- [ ] Scale servings (increase/decrease)

**Technical Notes:**

- Scrollable detail view
- Image carousel for multiple photos
- Quick action buttons for meal plan, shopping list
- Serving size calculator

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** US-3.1  
**Acceptance Tests:** Widget tests for recipe display

---

### US-3.5: Recipe Photo Management

**As a** user  
**I want to** add multiple photos to recipes  
**So that** I can visualize the dish and cooking steps

**Acceptance Criteria:**

- [ ] Add multiple photos per recipe
- [ ] Capture via camera or select from gallery
- [ ] Reorder photos (set cover image)
- [ ] Delete photos
- [ ] Compress images for storage efficiency
- [ ] View photos in full-screen gallery

**Technical Notes:**

- Image picker: `image_picker` package
- Image compression: `flutter_image_compress`
- Local storage with cloud sync
- Image model: `id`, `recipeId`, `url`, `order`, `isCover`

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-3.1  
**Acceptance Tests:** Integration tests for photo operations

---

### US-3.6: Recipe Rating and Notes

**As a** user  
**I want to** rate and add personal notes to recipes  
**So that** I remember what worked or didn't work

**Acceptance Criteria:**

- [ ] 5-star rating system
- [ ] Personal notes field (private)
- [ ] Track when recipe was last cooked
- [ ] View rating and notes in recipe detail
- [ ] Filter by rating (4+ stars)
- [ ] Edit/delete notes

**Technical Notes:**

- RecipeMetadata model: `recipeId`, `rating`, `notes`, `lastCooked`, `cookCount`
- Local storage only (private to user)

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-3.1, US-3.4  
**Acceptance Tests:** Widget tests for rating/notes

---

### US-3.7: Favorite Recipes

**As a** user  
**I want to** mark recipes as favorites  
**So that** I can quickly access my go-to meals

**Acceptance Criteria:**

- [ ] Heart icon to toggle favorite status
- [ ] "Favorites" filter in recipe list
- [ ] Favorite recipes appear in quick-pick meal planner
- [ ] Sort favorites by frequency cooked
- [ ] Export favorites list

**Technical Notes:**

- Boolean `isFavorite` flag on Recipe model
- Quick filter for favorites
- Analytics on favorite usage

**Story Points:** 2  
**Priority:** P0 (MVP)  
**Dependencies:** US-3.1  
**Acceptance Tests:** Widget tests for favorite toggle

---

### US-3.8: Recipe Categories and Tags

**As a** user  
**I want to** organize recipes with categories and tags  
**So that** I can browse by cuisine, meal type, or occasion

**Acceptance Criteria:**

- [ ] Predefined categories: Breakfast, Lunch, Dinner, Snack, Dessert
- [ ] Cuisine tags: Italian, Mexican, Asian, etc.
- [ ] Difficulty tags: Easy, Medium, Hard
- [ ] Custom user-created tags
- [ ] Multi-tag support per recipe
- [ ] Browse recipes by tag

**Technical Notes:**

- Tag model: `id`, `name`, `type`, `isCustom`
- Many-to-many relationship between recipes and tags
- Tag cloud visualization

**Story Points:** 3  
**Priority:** P0 (MVP)  
**Dependencies:** US-3.1  
**Acceptance Tests:** Unit tests for tag associations

---

### US-3.9: Serving Size Scaling

**As a** cook  
**I want to** scale recipe quantities up or down  
**So that** I can adjust for different household sizes

**Acceptance Criteria:**

- [ ] Increase/decrease serving size buttons
- [ ] All ingredient quantities scale proportionally
- [ ] Handle fractional quantities (1/2 cup → 1 cup)
- [ ] Reset to original serving size
- [ ] Display scaling factor (e.g., "2x original")
- [ ] Scaled quantities shown in practical units

**Technical Notes:**

- Quantity parser and scaler
- Fraction handling library
- Rounding to practical measurements

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-3.1, US-3.4  
**Acceptance Tests:** Unit tests for scaling algorithm

---

## Epic 4: Pantry & Inventory

**Epic Goal:** Enable users to track pantry inventory, monitor expiration dates, and auto-update from shopping.

**Business Value:** Reduces food waste and enables smart recipe matching.

**Story Count:** 6 stories | **Total Points:** 29

---

### US-4.1: Pantry Item Management

**As a** user  
**I want to** add and manage items in my pantry  
**So that** I know what ingredients I have available

**Acceptance Criteria:**

- [ ] Add item with name, quantity, unit, category
- [ ] Optional expiration date
- [ ] Optional purchase date and price
- [ ] Search and filter pantry items
- [ ] Edit item details
- [ ] Delete items (mark as used or discarded)
- [ ] View pantry in list or grid mode

**Technical Notes:**

- PantryItem model: `id`, `name`, `quantity`, `unit`, `category`, `expirationDate`, `purchaseDate`, `price`
- CRUD operations with local DB
- Category grouping similar to shopping lists

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Integration tests for pantry CRUD

---

### US-4.2: Expiration Tracking and Alerts

**As a** user  
**I want to** track when food expires and receive alerts  
**So that** I use items before they spoil

**Acceptance Criteria:**

- [ ] Color-coded freshness indicator (green/yellow/red)
- [ ] "Expiring Soon" view (items expiring in 3 days, 1 week)
- [ ] Push notification 1-2 days before expiration
- [ ] Sort pantry by expiration date
- [ ] Snooze or dismiss expiration alerts
- [ ] Mark as used/discarded to stop alerts

**Technical Notes:**

- Background task for daily expiration check
- Local notifications: `flutter_local_notifications`
- Notification settings (enable/disable, timing)

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** US-4.1  
**Acceptance Tests:** Unit tests for expiration logic, notification tests

---

### US-4.3: Auto-Update Pantry from Shopping

**As a** shopper  
**I want to** automatically add purchased items to my pantry  
**So that** my inventory updates without double-entry

**Acceptance Criteria:**

- [ ] Toggle "Add to pantry" checkbox on shopping list items
- [ ] Auto-add to pantry when item marked as purchased
- [ ] Default quantity based on item type
- [ ] Prompt for expiration date (optional)
- [ ] Bulk add all purchased items to pantry
- [ ] Review and edit before confirming additions

**Technical Notes:**

- Link between shopping list items and pantry items
- Batch pantry insert operation
- Smart defaults for quantities and expiration

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-4.1, E1 (Shopping Lists)  
**Acceptance Tests:** Integration tests for auto-add flow

---

### US-4.4: Pantry Inventory Dashboard

**As a** user  
**I want to** see an overview of my pantry status  
**So that** I understand what I have at a glance

**Acceptance Criteria:**

- [ ] Total item count
- [ ] Items expiring soon (with count)
- [ ] Low stock items (with count)
- [ ] Recent additions
- [ ] Pantry value estimate (if prices tracked)
- [ ] Quick actions: Add Item, View Expiring, Run "What Can I Make"

**Technical Notes:**

- Dashboard widget composition
- Aggregation queries for counts
- Cache dashboard data for performance

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-4.1, US-4.2  
**Acceptance Tests:** Widget tests for dashboard

---

### US-4.5: Consumption Tracking and Predictions

**As a** user  
**I want to** track how quickly I use items  
**So that** I can predict when to restock

**Acceptance Criteria:**

- [ ] Log when item quantity decreases (manually or via recipe use)
- [ ] Track usage patterns over time
- [ ] Predict depletion date based on consumption rate
- [ ] "Running Low" alert at configurable threshold
- [ ] One-tap add to shopping list from low stock
- [ ] Learn from user corrections to improve predictions

**Technical Notes:**

- Consumption history model: `itemId`, `date`, `quantityUsed`
- Prediction algorithm (moving average or simple linear)
- Machine learning for better predictions (future)

**Story Points:** 8  
**Priority:** P2 (Future)  
**Dependencies:** US-4.1  
**Acceptance Tests:** Unit tests for prediction algorithm

---

### US-4.6: Pantry Search and Quick Actions

**As a** cook in the kitchen  
**I want to** quickly search my pantry and take actions  
**So that** I can manage inventory while cooking

**Acceptance Criteria:**

- [ ] Fast search by item name
- [ ] Voice search support
- [ ] Barcode scan to find item (future)
- [ ] Quick subtract quantity (mark as used)
- [ ] Quick add to shopping list
- [ ] Recent items for fast access

**Technical Notes:**

- Search optimization (indexed fields)
- Speech recognition integration
- Barcode scanner: `mobile_scanner` package (future)

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-4.1  
**Acceptance Tests:** Integration tests for search and quick actions

---

## Epic 5: Offline & Sync

**Epic Goal:** Implement offline-first architecture with seamless cloud synchronization when online.

**Business Value:** Critical for grocery store use case - app must work without internet.

**Story Count:** 5 stories | **Total Points:** 34

---

### US-5.1: Local Database Setup

**As a** developer  
**I want to** implement local database persistence  
**So that** all app data is stored locally and accessible offline

**Acceptance Criteria:**

- [ ] Set up local database (Hive or Drift)
- [ ] Define schemas for all entities (recipes, shopping lists, pantry, meals)
- [ ] CRUD operations for all entities
- [ ] Database migrations for schema changes
- [ ] Database backup and restore
- [ ] Performance optimization (indexing, queries)

**Technical Notes:**

- Choose between Hive (NoSQL, simple) or Drift (SQL, relational)
- Repository pattern for data access
- Entity models with JSON serialization

**Story Points:** 8  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Unit tests for all DB operations

---

### US-5.2: Offline-First State Management

**As a** user  
**I want to** perform all app operations offline  
**So that** I can use the app anywhere without connectivity

**Acceptance Criteria:**

- [ ] All CRUD operations work offline
- [ ] Local data is source of truth
- [ ] No blocking API calls
- [ ] Optimistic UI updates
- [ ] Changes persist immediately to local DB
- [ ] No loading spinners for local data

**Technical Notes:**

- Riverpod providers for state management
- Repository layer handles offline-first logic
- Network status checking: `connectivity_plus`

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** US-5.1  
**Acceptance Tests:** Integration tests simulating offline usage

---

### US-5.3: Sync Queue and Conflict Resolution

**As a** user  
**I want to** have my changes sync to the cloud when I'm online  
**So that** my data is backed up and available on other devices

**Acceptance Criteria:**

- [ ] Changes queued for sync when offline
- [ ] Automatic sync when connectivity restored
- [ ] Manual sync trigger
- [ ] Sync status indicator (synced, pending, error)
- [ ] Conflict resolution strategy (last-write-wins or manual)
- [ ] Sync error handling and retry logic

**Technical Notes:**

- Sync queue with priority and retry
- Change tracking (created, updated, deleted flags)
- Timestamp-based conflict resolution
- Background sync using WorkManager or similar

**Story Points:** 13 (complex, should be split)  
**Priority:** P0 (MVP)  
**Dependencies:** US-5.1, US-5.2  
**Acceptance Tests:** Integration tests for sync scenarios

**Recommendation:** Split into:

- US-5.3a: Sync Queue Implementation (8 points)
- US-5.3b: Conflict Resolution (5 points)

---

### US-5.4: Cloud Backend Integration

**As a** user  
**I want to** optionally sync my data to the cloud  
**So that** I can access it from multiple devices or restore if I lose my phone

**Acceptance Criteria:**

- [ ] Optional cloud sync (no-login default)
- [ ] Firebase/Supabase authentication
- [ ] Cloud database setup (Firestore or PostgreSQL)
- [ ] Real-time sync for shared lists
- [ ] Cloud storage for recipe images
- [ ] Data export and import (JSON)

**Technical Notes:**

- Choose Firebase or Supabase based on requirements
- Authentication: email/password, Google, Apple
- Security rules for data access
- Cloud Functions for server-side logic

**Story Points:** 13 (complex, should be split)  
**Priority:** P0 (MVP)  
**Dependencies:** US-5.1, US-5.3  
**Acceptance Tests:** Integration tests for cloud sync

**Recommendation:** Split into:

- US-5.4a: Authentication Setup (5 points)
- US-5.4b: Cloud Database Sync (8 points)

---

### US-5.5: Network Status Indicator

**As a** user  
**I want to** see my app's connection and sync status  
**So that** I understand whether my changes are backed up

**Acceptance Criteria:**

- [ ] Subtle indicator shows: online, offline, syncing, sync error
- [ ] Icon or badge in app bar
- [ ] Tap to view sync details
- [ ] Show pending changes count
- [ ] Show last sync timestamp
- [ ] Manual sync button when errors occur

**Technical Notes:**

- Network connectivity monitoring
- Sync status provider (Riverpod)
- Non-intrusive UI indicator

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-5.2, US-5.3  
**Acceptance Tests:** Widget tests for status indicator

---

## Epic 6: Family & Collaboration

**Epic Goal:** Enable household members to collaborate on meal planning, shopping, and inventory management.

**Business Value:** Key differentiator for family-focused users.

**Story Count:** 6 stories | **Total Points:** 27

---

### US-6.1: Household Profiles

**As a** household member  
**I want to** create individual profiles with preferences  
**So that** the app accommodates everyone's dietary needs

**Acceptance Criteria:**

- [ ] Create multiple user profiles per household
- [ ] Profile fields: name, photo, dietary restrictions, skill level
- [ ] Individual favorite recipes per profile
- [ ] Set allergies and "never suggest" ingredients
- [ ] Switch active profile easily
- [ ] Privacy settings per profile

**Technical Notes:**

- Profile model: `id`, `name`, `photo`, `dietaryRestrictions[]`, `skillLevel`, `allergies[]`
- Active profile stored in app state
- Filter recipes based on active profile restrictions

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** None  
**Acceptance Tests:** Integration tests for profile management

---

### US-6.2: Meal Voting

**As a** family  
**I want to** vote on meal choices  
**So that** everyone has input in the weekly menu

**Acceptance Criteria:**

- [ ] Share meal plan for household voting
- [ ] Vote using thumbs up/down or star rating
- [ ] See vote tallies before finalizing
- [ ] "Veto" option for allergies or strong dislikes
- [ ] Majority-wins auto-scheduling (optional)
- [ ] Parent override mechanism

**Technical Notes:**

- Vote model: `mealPlanId`, `profileId`, `vote`, `isVeto`
- Real-time vote updates via cloud sync
- Voting period and finalization

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-6.1, US-2.1 (Meal Planning)  
**Acceptance Tests:** Integration tests for voting flow

---

### US-6.3: Shared Shopping Lists (Real-Time)

**As a** household member  
**I want to** collaborate on shopping lists in real-time  
**So that** multiple people can add items or shop together

**Acceptance Criteria:**

- [ ] Share shopping list with household members
- [ ] Real-time sync when multiple users viewing
- [ ] Show who added each item
- [ ] Show who checked off items
- [ ] Conflict resolution for simultaneous edits
- [ ] Presence indicator (who's currently viewing)

**Technical Notes:**

- Real-time sync via WebSocket or Firestore listeners
- Operational transformation for conflict resolution
- Presence tracking

**Story Points:** 8  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-1.1 (Shopping Lists), US-5.4 (Cloud Sync), US-6.1  
**Acceptance Tests:** Integration tests for real-time collaboration

---

### US-6.4: Household Pantry Management

**As a** household  
**I want to** share a common pantry inventory  
**So that** everyone knows what's available

**Acceptance Criteria:**

- [ ] Shared household pantry
- [ ] Any member can add/edit/remove items
- [ ] Activity log shows who made changes
- [ ] Notifications for low stock or expiring items
- [ ] Permission levels (admin, member, viewer)

**Technical Notes:**

- Household model with member associations
- Shared pantry linked to household
- Audit log for changes

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-4.1 (Pantry), US-6.1  
**Acceptance Tests:** Integration tests for shared pantry

---

### US-6.5: Recipe Sharing Within Household

**As a** family member  
**I want to** share recipes with my household  
**So that** everyone can access family recipes

**Acceptance Criteria:**

- [ ] Share recipe with household members
- [ ] Recipient can view and cook from shared recipe
- [ ] Option to copy shared recipe to personal library
- [ ] Track who shared what
- [ ] Unshare or revoke access

**Technical Notes:**

- Recipe sharing permissions
- Copy-on-write for personal edits
- Shared recipe library view

**Story Points:** 3  
**Priority:** P2 (Nice-to-have)  
**Dependencies:** US-3.1 (Recipes), US-6.1  
**Acceptance Tests:** Integration tests for recipe sharing

---

### US-6.6: Family Activity Feed

**As a** household member  
**I want to** see what other family members are doing in the app  
**So that** I stay informed about meal plans and shopping

**Acceptance Criteria:**

- [ ] Activity feed shows: meals planned, items added to lists, recipes saved
- [ ] Filter by activity type or family member
- [ ] Tap activity to view details
- [ ] Like or comment on activities (optional)
- [ ] Privacy settings to hide certain activities

**Technical Notes:**

- Activity model: `userId`, `activityType`, `entityId`, `timestamp`
- Real-time activity stream
- Privacy filters

**Story Points:** 5  
**Priority:** P2 (Future)  
**Dependencies:** US-6.1, E5 (Sync)  
**Acceptance Tests:** Widget tests for activity feed

---

## Epic 7: Smart Features & AI

**Epic Goal:** Implement AI-driven features for intelligent suggestions, waste reduction, and personalization.

**Business Value:** Key differentiators that provide "wow" moments and improve retention.

**Story Count:** 7 stories | **Total Points:** 41

---

### US-7.1: Expiration-Aware Menu Suggestions

**As a** user with expiring food  
**I want to** receive recipe suggestions using soon-to-expire items  
**So that** I reduce food waste

**Acceptance Criteria:**

- [ ] Algorithm prioritizes recipes with expiring ingredients
- [ ] "Use This First" badge on time-sensitive recipes
- [ ] Filter recipes by urgency (expires in 3 days, 1 week)
- [ ] Push notification for critical expirations (1-2 days)
- [ ] One-tap add recipe to meal plan
- [ ] Mark ingredients as used to stop notifications

**Technical Notes:**

- Recipe ranking algorithm based on expiration dates
- Notification scheduling based on expiration
- ML model for better suggestions (future)

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** E3 (Recipes), US-4.2 (Expiration Tracking)  
**Acceptance Tests:** Unit tests for suggestion algorithm

---

### US-7.2: Leftover Planning and Transformation

**As a** efficient cook  
**I want to** plan meals around expected leftovers  
**So that** I intentionally reuse food without waste

**Acceptance Criteria:**

- [ ] Mark recipes as "batch cooking" with expected leftover quantity
- [ ] "Leftover transformation" library suggests second-life recipes
- [ ] Visual leftover chain (Monday roast → Tuesday tacos → Wednesday soup)
- [ ] Automatic portion calculation for leftover recipes
- [ ] Track leftover usage over time
- [ ] Opt-out of leftover suggestions

**Technical Notes:**

- Leftover model: `recipeId`, `quantity`, `usedByRecipeId`, `date`
- Transformation recipe library (curated)
- Leftover matching algorithm

**Story Points:** 8  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-2.1 (Meal Planning), E3 (Recipes)  
**Acceptance Tests:** Unit tests for leftover matching

---

### US-7.3: Personalized Recipe Recommendations

**As a** user  
**I want to** receive recipe suggestions based on my preferences and history  
**So that** I discover new meals I'll enjoy

**Acceptance Criteria:**

- [ ] Recommendations based on: favorites, ratings, dietary restrictions, recent cooks
- [ ] "Try This" section in recipe library
- [ ] Explanation for why recipe is recommended
- [ ] Feedback mechanism (like/dislike) to improve suggestions
- [ ] Weekly email with recipe ideas (optional)
- [ ] Seasonal and trending recipe suggestions

**Technical Notes:**

- Collaborative filtering or content-based recommendation
- User preference tracking
- ML model training on user behavior
- Integration with recipe API for discovery

**Story Points:** 8  
**Priority:** P2 (Future)  
**Dependencies:** E3 (Recipes), US-3.6 (Ratings)  
**Acceptance Tests:** Unit tests for recommendation algorithm

---

### US-7.4: Smart Shopping List Generator

**As a** user  
**I want to** have the app intelligently suggest what to buy  
**So that** I maintain a well-stocked pantry without over-purchasing

**Acceptance Criteria:**

- [ ] Analyze meal plan and pantry to suggest shopping list
- [ ] Consider usage patterns and typical consumption rates
- [ ] Detect missing staples (milk, eggs, bread)
- [ ] One-tap accept suggestions or edit manually
- [ ] Learn from user edits to improve future suggestions
- [ ] Budget-aware suggestions (stay within spending limit)

**Technical Notes:**

- Suggestion algorithm based on meal plan, pantry, and history
- Staple detection and restocking logic
- Machine learning for personalization

**Story Points:** 8  
**Priority:** P2 (Future)  
**Dependencies:** E1 (Shopping), E2 (Meal Planning), E4 (Pantry)  
**Acceptance Tests:** Unit tests for suggestion logic

---

### US-7.5: Voice Assistant Integration

**As a** hands-free user in the kitchen  
**I want to** use voice commands to interact with the app  
**So that** I can cook without touching my phone

**Acceptance Criteria:**

- [ ] Voice commands: "Add milk to shopping list", "Start breakfast recipe", "Read next step"
- [ ] Integration with Google Assistant or Siri
- [ ] Hands-free recipe navigation (read ingredients, read instructions)
- [ ] Voice confirmation for actions
- [ ] Wake word or button activation
- [ ] Multi-language support

**Technical Notes:**

- Speech recognition: platform APIs or cloud services
- Intent parsing for command understanding
- Text-to-speech for responses
- App shortcuts for common actions

**Story Points:** 8  
**Priority:** P2 (Future)  
**Dependencies:** E1 (Shopping), E2 (Meal Planning), E3 (Recipes)  
**Acceptance Tests:** Integration tests for voice commands

---

### US-7.6: Nutrition Analysis and Tracking

**As a** health-conscious user  
**I want to** track nutritional information for my meals  
**So that** I make informed dietary choices

**Acceptance Criteria:**

- [ ] Auto-calculate nutrition for recipes (calories, protein, fat, carbs)
- [ ] Display nutrition per serving
- [ ] Weekly nutrition dashboard (aggregate from meal plan)
- [ ] Set nutrition goals (e.g., daily calorie limit)
- [ ] Track progress toward goals
- [ ] Nutrition API integration (USDA, Nutritionix)

**Technical Notes:**

- Nutrition API for ingredient data
- Calculation engine for recipes
- NutritionFacts model: `calories`, `protein`, `fat`, `carbs`, `fiber`, etc.
- Caching to minimize API calls

**Story Points:** 8  
**Priority:** P2 (Future)  
**Dependencies:** E2 (Meal Planning), E3 (Recipes)  
**Acceptance Tests:** Unit tests for nutrition calculation

---

### US-7.7: Budget Tracking and Cost Estimation

**As a** budget-conscious user  
**I want to** track grocery spending and estimate costs  
**So that** I stay within my food budget

**Acceptance Criteria:**

- [ ] Enter prices for pantry items and shopping list items
- [ ] Estimate shopping list total cost
- [ ] Track actual spending over time
- [ ] Weekly/monthly budget goals
- [ ] Spending reports and trends
- [ ] Price history and comparison (if using store APIs)

**Technical Notes:**

- Price tracking in pantry and shopping models
- Budget model: `monthlyLimit`, `currentSpending`, `alerts`
- Reporting queries and charts
- Integration with receipt scanning (future)

**Story Points:** 5  
**Priority:** P2 (Future)  
**Dependencies:** E1 (Shopping), E4 (Pantry)  
**Acceptance Tests:** Unit tests for budget calculations

---

## Epic 8: User Settings & Privacy

**Epic Goal:** Provide user control over preferences, data, and privacy settings.

**Business Value:** Builds trust and accommodates user preferences.

**Story Count:** 5 stories | **Total Points:** 18

---

### US-8.1: User Preferences and Settings

**As a** user  
**I want to** customize app settings to my liking  
**So that** the app works the way I prefer

**Acceptance Criteria:**

- [ ] Settings screen with organized sections
- [ ] Theme selection (light, dark, system)
- [ ] Language selection
- [ ] Measurement units (metric, imperial)
- [ ] Default household size for recipe scaling
- [ ] Notification preferences (types, timing)
- [ ] App version and build info

**Technical Notes:**

- SharedPreferences for settings storage
- Settings provider for app-wide access
- Localization support (i18n)

**Story Points:** 3  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Widget tests for settings screen

---

### US-8.2: Dietary Restrictions and Allergies

**As a** user with dietary needs  
**I want to** set my dietary restrictions and allergies  
**So that** the app filters inappropriate recipes

**Acceptance Criteria:**

- [ ] Predefined restrictions: Vegetarian, Vegan, Gluten-Free, Dairy-Free, etc.
- [ ] Custom allergy list (ingredient blacklist)
- [ ] "Never Suggest" ingredient list
- [ ] Auto-filter recipes based on restrictions
- [ ] Warning when adding restricted item to shopping/pantry
- [ ] Override mechanism for intentional purchases (e.g., cooking for guests)

**Technical Notes:**

- DietaryProfile model: `restrictions[]`, `allergies[]`, `neverSuggest[]`
- Recipe filtering logic
- Warning dialogs for restricted items

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** US-8.1  
**Acceptance Tests:** Unit tests for filtering logic

---

### US-8.3: Privacy Controls and Data Export

**As a** privacy-conscious user  
**I want to** control my data and export it  
**So that** I maintain ownership and can leave if I choose

**Acceptance Criteria:**

- [ ] Clear privacy policy and data usage explanation
- [ ] Toggle cloud sync on/off (stay local-only)
- [ ] View what data is synced to cloud
- [ ] Export all data as JSON
- [ ] Delete cloud account and data
- [ ] Delete local data (reset app)
- [ ] Import data from backup

**Technical Notes:**

- Data export to JSON file
- Cloud account deletion API
- Local DB wipe function
- Import validation and merging

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-5.4 (Cloud Sync)  
**Acceptance Tests:** Integration tests for export/import

---

### US-8.4: Notification Management

**As a** user  
**I want to** control what notifications I receive  
**So that** I'm not overwhelmed by alerts

**Acceptance Criteria:**

- [ ] Enable/disable push notifications globally
- [ ] Granular control: expiration alerts, meal reminders, low stock, sync errors
- [ ] Set quiet hours (no notifications during specific times)
- [ ] Notification preview in settings
- [ ] Badge count controls
- [ ] Sound and vibration preferences

**Technical Notes:**

- Notification settings in SharedPreferences
- Notification channel configuration (Android)
- Notification category setup (iOS)

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-8.1  
**Acceptance Tests:** Integration tests for notifications

---

### US-8.5: App Theme and Appearance

**As a** user  
**I want to** customize the app's appearance  
**So that** it matches my aesthetic preference

**Acceptance Criteria:**

- [ ] Light, dark, and system theme options
- [ ] Primary color customization (optional)
- [ ] Font size adjustment (accessibility)
- [ ] High contrast mode (accessibility)
- [ ] Theme preview before applying
- [ ] Persist theme choice

**Technical Notes:**

- ThemeData configuration
- Dynamic theme switching
- Custom color schemes
- Accessibility considerations

**Story Points:** 3  
**Priority:** P2 (Nice-to-have)  
**Dependencies:** US-8.1  
**Acceptance Tests:** Widget tests for theme switching

---

## Epic 9: Onboarding & Help

**Epic Goal:** Provide smooth onboarding experience and in-app help for new users.

**Business Value:** Reduces churn and improves user activation.

**Story Count:** 4 stories | **Total Points:** 15

---

### US-9.1: First-Time Onboarding Flow

**As a** new user  
**I want to** understand the app's core features quickly  
**So that** I can start using it effectively

**Acceptance Criteria:**

- [ ] Welcome screen with app benefits
- [ ] 3-5 screen tutorial (swipe walkthrough)
- [ ] Optional account creation (can skip)
- [ ] Set basic preferences (household size, dietary restrictions)
- [ ] Sample data option (pre-populate with examples)
- [ ] Skip or complete onboarding

**Technical Notes:**

- Onboarding screen flow
- First-launch detection
- Sample data seeding
- Preference initialization

**Story Points:** 5  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Widget tests for onboarding flow

---

### US-9.2: Interactive Tooltips and Hints

**As a** new user exploring the app  
**I want to** see contextual hints and tooltips  
**So that** I discover features organically

**Acceptance Criteria:**

- [ ] Tooltips on first use of each major feature
- [ ] Tap "?" icon for feature explanations
- [ ] Highlight new features after updates
- [ ] Don't show tooltips after user dismisses them
- [ ] "Show me again" option in settings
- [ ] Animated coach marks for complex flows

**Technical Notes:**

- Tooltip/coach mark library (e.g., `showcaseview`)
- Feature discovery tracking
- First-use detection per feature

**Story Points:** 3  
**Priority:** P1 (Post-MVP)  
**Dependencies:** US-9.1  
**Acceptance Tests:** Widget tests for tooltips

---

### US-9.3: In-App Help and FAQs

**As a** user with questions  
**I want to** access help documentation within the app  
**So that** I can solve problems without leaving the app

**Acceptance Criteria:**

- [ ] Help center with searchable FAQs
- [ ] Category organization (Getting Started, Features, Troubleshooting)
- [ ] Step-by-step guides with screenshots
- [ ] Video tutorials (optional)
- [ ] Contact support option
- [ ] Report a bug feature

**Technical Notes:**

- Help content in markdown or HTML
- Local help files or cloud-hosted
- Search functionality
- Feedback form integration

**Story Points:** 5  
**Priority:** P1 (Post-MVP)  
**Dependencies:** None  
**Acceptance Tests:** Widget tests for help center

---

### US-9.4: Contextual Empty States

**As a** user viewing an empty section  
**I want to** see helpful guidance on what to do next  
**So that** I'm not confused by blank screens

**Acceptance Criteria:**

- [ ] Empty state for: no recipes, no shopping lists, no meal plans, no pantry items
- [ ] Friendly illustration or icon
- [ ] Clear explanation of what the section is for
- [ ] Primary action button (e.g., "Add Your First Recipe")
- [ ] Secondary help link
- [ ] Consistent empty state design across app

**Technical Notes:**

- Empty state widgets for each entity type
- Illustration assets
- Consistent UX patterns

**Story Points:** 2  
**Priority:** P0 (MVP)  
**Dependencies:** None  
**Acceptance Tests:** Widget tests for empty states

---

## Release Planning

### MVP v1.0 Scope

**Target:** 10-12 weeks | **Story Points:** 210

**Epics Included:**

- E1: Shopping List Management (31 pts)
- E2: Meal Planning (38 pts)
- E3: Recipe Management (45 pts)
- E4: Pantry & Inventory (29 pts)
- E5: Offline & Sync (34 pts - split large stories)
- E8: User Settings & Privacy (core stories, 10 pts)
- E9: Onboarding & Help (15 pts)

**Must-Have Stories:** All P0 stories

**Sprint Breakdown (2-week sprints):**

**Sprint 1-2:** Foundation (35 pts)

- US-5.1: Local Database Setup
- US-8.1: User Preferences
- US-8.2: Dietary Restrictions
- US-9.1: Onboarding
- US-9.4: Empty States

**Sprint 3-4:** Shopping Lists (31 pts)

- US-1.1: Create Shopping Lists
- US-1.2: Add Items
- US-1.3: Organize by Category
- US-1.4: Check Off Items
- US-1.5: Offline Access
- US-1.7: Edit/Delete Items

**Sprint 5-6:** Recipes (40 pts)

- US-3.1: Manual Recipe Entry
- US-3.3: Search and Filter
- US-3.4: Recipe Detail View
- US-3.7: Favorite Recipes
- US-3.8: Categories and Tags

**Sprint 7-8:** Meal Planning (38 pts)

- US-2.1: Weekly Calendar
- US-2.2: Assign Recipes
- US-2.3: Auto-Generate Shopping List
- US-2.4: What Can I Make

**Sprint 9-10:** Pantry (29 pts)

- US-4.1: Pantry Management
- US-4.2: Expiration Tracking

**Sprint 11-12:** Sync & Polish (37 pts)

- US-5.2: Offline-First State
- US-5.3: Sync Queue (split)
- US-5.4: Cloud Backend (split)
- Bug fixes, testing, beta release

---

### v1.1 Release (Post-MVP)

**Target:** +4 weeks | **Story Points:** 68

**Epics Included:**

- E6: Family & Collaboration (27 pts)
- E8: Additional Settings (8 pts)
- E9: Help Features (8 pts)
- Deferred P1 stories from MVP epics (25 pts)

**Key Features:**

- Household profiles and meal voting
- Shared shopping lists
- Recipe URL import
- Enhanced onboarding

---

### v1.2 Release (Smart Features)

**Target:** +6 weeks | **Story Points:** 80+

**Epics Included:**

- E7: Smart Features & AI (41 pts)
- Additional enhancements (39 pts)

**Key Features:**

- AI-driven recipe suggestions
- Leftover planning
- Nutrition tracking
- Budget tracking
- Voice assistant integration

---

## Appendix

### Estimation Guidelines

**Story Point Breakdown:**

- **1 pt:** Simple UI change, config update
- **2 pts:** Simple form, basic CRUD
- **3 pts:** Standard feature with DB + UI
- **5 pts:** Complex feature with business logic
- **8 pts:** Very complex with integrations
- **13 pts:** Epic-level work, needs splitting

### Definition of Done

**All User Stories Must:**

- [ ] Code complete and reviewed
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests for critical flows
- [ ] Widget tests for UI components
- [ ] Documentation updated
- [ ] Acceptance criteria met
- [ ] QA tested on iOS and Android
- [ ] No critical bugs
- [ ] Accessibility verified
- [ ] Performance acceptable (<100ms interactions)

### Risk Assessment

**High-Risk Stories (need mitigation):**

- US-5.3, US-5.4: Sync complexity - consider Firebase for simplicity
- US-7.x: AI features - may need cloud ML services, budget impact
- US-6.3: Real-time collaboration - complex conflict resolution

**Dependencies:**

- Cloud infrastructure selection (Firebase vs. Supabase) - Sprint 1
- ML service selection (Google ML Kit vs. custom) - Sprint 8
- Recipe API selection (Spoonacular, Edamam) - Sprint 6

---

**Document End**

_Generated by BMad Master - February 26, 2026_
