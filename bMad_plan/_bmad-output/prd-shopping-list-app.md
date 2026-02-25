# Product Requirements Document (PRD)

## Flutter Shopping List & Meal Planning App

**Document Version:** 1.0  
**Date:** February 25, 2026  
**Author:** Product Team  
**Status:** Draft  
**Source:** Brainstorming Session 2026-02-25 (101 ideas)

---

## Executive Summary

### Product Vision

A privacy-first Flutter mobile application that intelligently combines shopping list management with weekly meal planning, featuring robust offline/online synchronization, AI-driven menu suggestions, and smart inventory tracking to help families reduce food waste, save time, and streamline their cooking workflow.

### Key Differentiators

1. **Offline-First Architecture** - Seamless functionality regardless of connectivity
2. **Privacy by Design** - No-login default with optional cloud sync
3. **Leftover-Centric Planning** - Unique reverse planning flow to reduce food waste
4. **Emergency Preparedness** - Dual-purpose inventory for daily cooking and disaster readiness
5. **Family-Oriented** - Built for household collaboration with voting, skill levels, and dietary accommodations

### Target Users

- **Primary:** Busy parents (25-45) managing family meals and grocery shopping
- **Secondary:** Home cooks seeking meal planning efficiency and food waste reduction
- **Tertiary:** Health-conscious individuals tracking nutrition and dietary restrictions

### Success Metrics

- **Retention:** 70%+ weekly active users after month 1
- **Engagement:** 3+ meals planned per week per user
- **Shopping:** 5+ shopping trips with app per month
- **Growth:** 500+ active users in first 3 months
- **Satisfaction:** Net Promoter Score (NPS) > 40

---

## Table of Contents

1. [Product Overview](#product-overview)
2. [User Personas](#user-personas)
3. [User Stories](#user-stories)
4. [Functional Requirements](#functional-requirements)
5. [Non-Functional Requirements](#non-functional-requirements)
6. [Technical Requirements](#technical-requirements)
7. [Feature Prioritization](#feature-prioritization)
8. [Release Roadmap](#release-roadmap)
9. [Success Criteria](#success-criteria)
10. [Dependencies & Constraints](#dependencies--constraints)
11. [Appendix](#appendix)

---

## Product Overview

### Problem Statement

Families waste an average of 30-40% of purchased food due to poor meal planning, forgotten inventory, and disconnected shopping experiences. Current solutions either focus solely on shopping lists OR meal planning, but fail to integrate both seamlessly, especially in offline environments like grocery stores and kitchens.

**Key Pain Points:**

- Meal planning feels like a chore, leading to reactive shopping
- No visibility into what's already in the pantry during planning
- Shopping lists disconnected from meal plans cause forgotten ingredients
- Apps fail in grocery stores with poor connectivity
- Food expires because users forget what they have
- Family dietary needs and preferences aren't accommodated systematically

### Solution Overview

An intelligent mobile app that treats meal planning and shopping as a unified workflow, working seamlessly offline with smart features that:

- Auto-generate shopping lists from weekly meal plans
- Match recipes against current pantry inventory
- Prioritize recipes based on expiring ingredients
- Work flawlessly without internet connectivity
- Learn family preferences and dietary needs
- Reduce food waste through leftover planning

### Core Value Propositions

| User Segment     | Primary Value                                | Secondary Benefits                     |
| ---------------- | -------------------------------------------- | -------------------------------------- |
| Busy Parents     | Save 2+ hours/week on meal planning          | Reduce food waste, healthier meals     |
| Budget-Conscious | Track spending, reduce waste                 | Plan around sales, batch cooking       |
| Health-Focused   | Nutritional tracking, dietary control        | Meal variety, ingredient awareness     |
| Tech-Savvy Cooks | Smart automation, algorithm-driven discovery | Community recipes, trend participation |

---

## User Personas

### Persona 1: Sarah - The Busy Parent

**Demographics:** 35, working mom, 2 kids (ages 6 & 9)  
**Goals:**

- Plan weekly meals efficiently on Sunday
- Never forget ingredients at the store
- Accommodate kids' picky eating while maintaining nutrition
- Work with what's already in the pantry

**Pain Points:**

- Forgets what's in fridge/pantry when planning meals
- Kids complain about dinner choices
- Wastes 20% of groceries to spoilage
- Phone loses connection in grocery store basement

**Needs:**

- ✅ Weekly meal planner with family voting
- ✅ Offline shopping list access
- ✅ Expiration tracking and alerts
- ✅ Kid-friendly recipe filters

---

### Persona 2: Marcus - The Budget Cook

**Demographics:** 28, single, tight grocery budget ($200/month)  
**Goals:**

- Maximize food budget efficiency
- Use all purchased ingredients
- Learn to cook with what he has
- Avoid food waste

**Pain Points:**

- Buys ingredients for one recipe, rest spoils
- No visibility into actual grocery spending
- Struggles to find recipes using what he owns
- Repeats same 5 meals due to planning paralysis

**Needs:**

- ✅ Budget tracking with cost estimates
- ✅ "What can I make?" recipe finder
- ✅ Leftover transformation suggestions
- ✅ Shopping list with price tracking

---

### Persona 3: Elena - The Health Planner

**Demographics:** 42, health-conscious, multiple dietary restrictions (gluten-free, low-sodium)  
**Goals:**

- Maintain strict dietary requirements
- Track nutritional intake
- Discover new recipes within constraints
- Plan balanced weekly nutrition

**Pain Points:**

- Must manually check every recipe for restrictions
- Difficult to track nutritional balance across week
- Limited recipe discovery within dietary constraints
- Ingredient substitutions require research

**Needs:**

- ✅ Dietary profile with auto-filtering
- ✅ Nutritional tracking and goals
- ✅ Smart ingredient substitution engine
- ✅ "Never suggest" blocked ingredients

---

## User Stories

### Epic 1: Shopping List Management

**US-001: Create Shopping List**  
**As a** user  
**I want to** create and manage shopping lists  
**So that** I can organize my grocery trips efficiently

**Acceptance Criteria:**

- Create new shopping list with custom name
- Add items via text input, voice, or photo
- Organize items by categories (produce, dairy, etc.)
- Mark items as purchased with checkbox
- Delete or edit items
- View list in grid or list mode

**Priority:** P0 (MVP)

---

**US-002: Offline Shopping List Access**  
**As a** shopper in a store  
**I want to** access my shopping list without internet  
**So that** I can check items regardless of connectivity

**Acceptance Criteria:**

- All shopping lists accessible offline
- Changes saved locally immediately
- UI indicates sync status clearly
- No functionality loss in offline mode
- Auto-sync when connectivity restored

**Priority:** P0 (MVP)

---

**US-003: Photo-Based Item Entry**  
**As a** user adding items  
**I want to** take a photo of a product  
**So that** I can quickly add items without typing

**Acceptance Criteria:**

- Camera access for product photo
- Optional AI suggestion for product name
- Manual override of suggested name
- Photo attachment to item
- Works offline with delayed AI processing

**Priority:** P0 (MVP)

---

### Epic 2: Meal Planning

**US-101: Weekly Meal Planner**  
**As a** meal planner  
**I want to** plan my meals for the week  
**So that** I know what to cook each day

**Acceptance Criteria:**

- 7-day calendar grid view
- Assign recipes to specific meals (breakfast/lunch/dinner)
- Drag-drop to reschedule meals
- Leave slots empty for flexibility
- Copy previous week's plan
- View plan in list or calendar format

**Priority:** P0 (MVP)

---

**US-102: Auto-Generate Shopping List from Meal Plan**  
**As a** meal planner  
**I want to** automatically create a shopping list from my weekly meals  
**So that** I don't manually transcribe ingredients

**Acceptance Criteria:**

- One-tap generation from meal plan
- Consolidate duplicate ingredients (sum quantities)
- Cross-reference pantry inventory
- Only add items not in stock
- Allow manual edits before finalizing
- Link shopping list to source meal plan

**Priority:** P0 (MVP)

---

**US-103: Recipe-Pantry Matching**  
**As a** cook  
**I want to** see which recipes I can make with current pantry  
**So that** I use what I have before buying more

**Acceptance Criteria:**

- "What can I make?" recipe filter
- Match recipes against pantry inventory
- Show partial matches (e.g., "need 2 more ingredients")
- Sort by completion percentage
- Highlight missing ingredients
- One-tap add missing items to shopping list

**Priority:** P0 (MVP)

---

**US-104: Expiration-Aware Menu Suggestions**  
**As a** user with expiring food  
**I want to** receive recipe suggestions using soon-to-expire items  
**So that** I reduce food waste

**Acceptance Criteria:**

- Algorithm prioritizes recipes with expiring ingredients
- "Use This First" badge on time-sensitive items
- Filter recipes by urgency (3 days, 1 week)
- Push notification for critical expirations (1-2 days)
- Option to postpone or mark as used

**Priority:** P1 (Post-MVP)

---

**US-105: Leftover Planning**  
**As a** efficient cook  
**I want to** plan meals around expected leftovers  
**So that** I intentionally use food without waste

**Acceptance Criteria:**

- Mark recipes as "batch cooking" with expected leftover quantity
- "Leftover transformation library" suggests second-life recipes
- Visual leftover chain display (Mon roast → Tue tacos → Wed soup)
- Automatic portion calculation for leftover recipes
- Skip leftover suggestions if user doesn't want them

**Priority:** P1 (Post-MVP)

---

### Epic 3: Recipe Management

**US-201: Manual Recipe Entry**  
**As a** user  
**I want to** manually enter my recipes  
**So that** I can digitize my cookbook collection

**Acceptance Criteria:**

- Form with title, ingredients, instructions
- Ingredient parser (auto-detect quantity, unit, name)
- Add photos (upload or camera)
- Tag categories (cuisine, meal type, difficulty)
- Set servings/yield
- Save as draft or publish

**Priority:** P0 (MVP)

---

**US-202: Recipe URL Import**  
**As a** user  
**I want to** import recipes from URLs  
**So that** I quickly save online recipes

**Acceptance Criteria:**

- Paste URL to import
- Auto-extract title, ingredients, instructions, images
- Support major recipe sites (AllRecipes, NYT Cooking, etc.)
- Preview before saving
- Manual edit imported recipe
- Handle failed imports gracefully

**Priority:** P1 (Post-MVP)

---

**US-203: Recipe Transformation Templates**  
**As a** user with dietary needs  
**I want to** transform recipes with one tap  
**So that** I adapt recipes to my restrictions

**Acceptance Criteria:**

- One-tap filters: Make Vegetarian, Vegan, Gluten-Free, Dairy-Free, Kid-Friendly
- Auto-suggest ingredient substitutions
- Preserve original recipe (create variant)
- Community-created transformation templates
- Undo transformations
- Save custom transformation preferences

**Priority:** P1 (Post-MVP)

---

### Epic 4: Pantry Inventory

**US-301: Pantry Tracker**  
**As a** user  
**I want to** track what's in my pantry  
**So that** I know what I have before shopping

**Acceptance Criteria:**

- Add items with quantity and unit
- Expiration date entry (optional)
- Categories (produce, dairy, grains, etc.)
- Search and filter inventory
- Edit quantities and details
- Mark as depleted/used

**Priority:** P0 (MVP)

---

**US-302: Expiration Tracking**  
**As a** user  
**I want to** track when food expires  
**So that** I use items before spoilage

**Acceptance Criteria:**

- Enter expiration dates when adding items
- Color-coded freshness indicator (green/yellow/red)
- "Expiring Soon" dashboard (3 days, 1 week filters)
- Push notification 1-2 days before expiration
- Sort inventory by expiration date
- Quick-add to meal plan from expiring items

**Priority:** P0 (MVP)

---

**US-303: Auto-Update Inventory from Shopping**  
**As a** shopper  
**I want to** automatically add purchased items to pantry  
**So that** my inventory stays current without double-entry

**Acceptance Criteria:**

- Toggle "Add to pantry" on shopping list items
- Auto-populate pantry when marked as purchased
- Default quantities based on product type
- Manual override of quantity/expiration
- Bulk add all purchased items
- Review before confirming additions

**Priority:** P1 (Post-MVP)

---

**US-304: Consumption Predictions**  
**As a** user  
**I want to** receive alerts before items run out  
**So that** I add them to shopping list proactively

**Acceptance Criteria:**

- Track usage patterns over time
- Predict depletion dates for staples
- "Running Low" alerts (configurable threshold)
- One-tap add to shopping list
- Manual override predictions
- Learn from user corrections

**Priority:** P2 (Social/Engagement)

---

### Epic 5: Family & Collaboration

**US-401: Household Profiles**  
**As a** family member  
**I want to** have individual profiles with preferences  
**So that** the app accommodates everyone's needs

**Acceptance Criteria:**

- Create multiple user profiles per household
- Individual dietary restrictions per profile
- Skill level assignment (beginner/intermediate/advanced)
- Favorite recipes per profile
- Privacy settings per profile
- Switch active profile easily

**Priority:** P1 (Post-MVP)

---

**US-402: Meal Voting**  
**As a** family  
**I want to** vote on meal choices  
**So that** everyone has input in the menu

**Acceptance Criteria:**

- Share meal plan for household voting
- Thumbs up/down or 1-5 star voting
- See vote tallies before finalizing
- "Veto" option for allergies/strong dislikes
- Majority-wins auto-scheduling
- Override mechanism for parent

**Priority:** P1 (Post-MVP)

---

**US-403: Shared Shopping Lists**  
**As a** household member  
**I want to** share shopping lists with family  
**So that** anyone can shop from the same list

**Acceptance Criteria:**

- Generate QR code or link to share list
- Real-time sync when multiple users viewing
- Show who added each item
- Show who checked off items
- Offline changes sync when connected
- Remove access/sharing option

**Priority:** P1 (Post-MVP)

---

### Epic 6: Discovery & Personalization

**US-501: Recipe Recommendations**  
**As a** user  
**I want to** discover new recipes tailored to my tastes  
**So that** I expand my cooking repertoire

**Acceptance Criteria:**

- "Discover Weekly Meals" algorithmic playlist
- Personalization based on cooking history
- Filters by cuisine, difficulty, time, dietary restrictions
- "For You" feed learning from interactions
- Save/reject to improve recommendations
- Mix familiar + exploratory suggestions (60/40 split)

**Priority:** P2 (Social/Engagement)

---

**US-502: Swipe-Based Recipe Discovery**  
**As a** user browsing recipes  
**I want to** swipe through recipe cards  
**So that** I quickly find inspiration

**Acceptance Criteria:**

- Tinder-style swipe interface
- Swipe right to save, left to skip
- Double-tap to add ingredients to shopping list
- Long-press for quick preview
- Algorithm learns from swipe patterns
- Daily personalized discovery stack (20-30 recipes)

**Priority:** P2 (Social/Engagement)

---

**US-503: Never Suggest Filtering**  
**As a** user with strong dislikes  
**I want to** permanently block certain ingredients/recipes  
**So that** I never see suggestions I won't cook

**Acceptance Criteria:**

- "Never Suggest" list management
- Block by ingredient, cuisine, or dish type
- Multi-level intensity: Hard No (allergies), Soft No (preferences), Context-Dependent
- All recommendations pre-filtered by blocks
- Override temporarily for special occasions
- Explain why blocked recipes are hidden

**Priority:** P1 (Post-MVP)

---

### Epic 7: Privacy & Security

**US-601: No-Login Default Operation**  
**As a** privacy-conscious user  
**I want to** use the app without creating an account  
**So that** I maintain privacy and avoid signup friction

**Acceptance Criteria:**

- Full functionality without account/login
- Local-only data storage by default
- No data sent to servers unless user opts in
- Clear value demonstration before requesting signup
- Optional account creation for cloud features
- One-tap local-to-cloud migration

**Priority:** P0 (MVP)

---

**US-602: Optional Cloud Sync**  
**As a** multi-device user  
**I want to** optionally sync data to cloud  
**So that** I access recipes across devices

**Acceptance Criteria:**

- Toggle cloud sync on/off in settings
- Selective sync (choose what to sync)
- Encryption in transit and at rest
- Anonymous mode (no personal data)
- One-click data deletion (GDPR compliant)
- Export full data backup (JSON/CSV)

**Priority:** P0 (MVP)

---

### Epic 8: Advanced Features

**US-701: Voice Chef Assistant**  
**As a** cook with messy hands  
**I want to** control the app via voice  
**So that** I navigate recipes hands-free

**Acceptance Criteria:**

- Voice commands: "Next step", "Set timer", "Repeat", "Go back"
- Continuous listening mode during cooking
- Multiple voice personalities (Chef/Casual/Quick)
- Read instructions aloud automatically
- Answer technique questions mid-recipe
- Works offline with basic commands

**Priority:** P3 (Advanced Intelligence)

---

**US-702: Budget Tracking**  
**As a** budget-conscious shopper  
**I want to** track grocery spending  
**So that** I stay within budget

**Acceptance Criteria:**

- Enter prices when shopping (optional)
- Track spending over time (weekly/monthly)
- Budget alerts when approaching limit
- Running total during shopping
- Category-wise spending breakdown
- Compare actual vs. estimated costs

**Priority:** P1 (Post-MVP)

---

**US-703: Smart Appliance Integration**  
**As a** tech-savvy cook  
**I want to** send recipes to smart appliances  
**So that** cooking temps/times are set automatically

**Acceptance Criteria:**

- Connect via WiFi/Bluetooth to supported devices
- One-tap send recipe to oven, Instant Pot, etc.
- Detect compatible appliances automatically
- Manual device configuration
- Support major brands (June, Breville, Instant)
- Graceful fallback if device unavailable

**Priority:** P4 (Ecosystem Integration)

---

**US-704: Emergency Preparedness Mode**  
**As a** prepared household  
**I want to** use pantry tracking for disaster readiness  
**So that** I maintain emergency supplies

**Acceptance Criteria:**

- "Emergency Readiness" dashboard with 7-day scoring
- Gradual prep through regular shopping
- Scenario profiles (weather, disaster, quarantine)
- No-power recipe filter
- FIFO rotation of emergency supplies
- Dietary-aware emergency planning

**Priority:** P5 (Specialized Features)

---

## Functional Requirements

### FR-1: Shopping List Management

**Priority:** P0 (MVP)

| Req ID  | Requirement                                                                                  | Priority |
| ------- | -------------------------------------------------------------------------------------------- | -------- |
| FR-1.1  | System shall support creating multiple shopping lists with unique names                      | P0       |
| FR-1.2  | Users shall add items via text input, voice dictation, or photo capture                      | P0       |
| FR-1.3  | Items shall be categorizable into predefined categories (produce, dairy, meat, pantry, etc.) | P0       |
| FR-1.4  | Users shall mark items as purchased via checkbox                                             | P0       |
| FR-1.5  | System shall support editing item details (name, quantity, notes)                            | P0       |
| FR-1.6  | Users shall delete individual items or entire lists                                          | P0       |
| FR-1.7  | List view shall toggle between grid and list modes                                           | P0       |
| FR-1.8  | System shall sort items by category, manual order, or alphabetical                           | P0       |
| FR-1.9  | Users shall duplicate existing shopping lists                                                | P1       |
| FR-1.10 | System shall track unpurchased items for next shopping trip                                  | P1       |

---

### FR-2: Offline Functionality

**Priority:** P0 (MVP)

| Req ID  | Requirement                                                    | Priority |
| ------- | -------------------------------------------------------------- | -------- |
| FR-2.1  | All core features shall function without internet connectivity | P0       |
| FR-2.2  | System shall store all user data locally on device             | P0       |
| FR-2.3  | Changes made offline shall queue for sync when online          | P0       |
| FR-2.4  | UI shall clearly indicate online/offline status                | P0       |
| FR-2.5  | System shall auto-detect connectivity changes                  | P0       |
| FR-2.6  | Queued changes shall sync automatically on reconnection        | P0       |
| FR-2.7  | Users shall manually trigger sync via UI action                | P1       |
| FR-2.8  | System shall handle sync conflicts gracefully                  | P1       |
| FR-2.9  | Failed syncs shall retry with exponential backoff              | P1       |
| FR-2.10 | Users shall view sync queue status and pending changes         | P2       |

---

### FR-3: Meal Planning

**Priority:** P0 (MVP)

| Req ID  | Requirement                                                                 | Priority |
| ------- | --------------------------------------------------------------------------- | -------- |
| FR-3.1  | System shall provide 7-day meal planning calendar                           | P0       |
| FR-3.2  | Users shall assign recipes to specific meals (breakfast/lunch/dinner/snack) | P0       |
| FR-3.3  | Users shall drag-drop meals to reschedule                                   | P0       |
| FR-3.4  | Meal slots shall be optional (leave empty for flexibility)                  | P0       |
| FR-3.5  | System shall auto-generate shopping list from weekly meal plan              | P0       |
| FR-3.6  | Generated shopping lists shall consolidate duplicate ingredients            | P0       |
| FR-3.7  | System shall cross-reference pantry to exclude owned items                  | P0       |
| FR-3.8  | Users shall manually adjust generated shopping list before finalizing       | P0       |
| FR-3.9  | System shall link shopping lists to source meal plans                       | P0       |
| FR-3.10 | Users shall copy previous week's meal plan                                  | P1       |
| FR-3.11 | System shall provide daily check-in/swap capability                         | P1       |
| FR-3.12 | Multi-week planning view shall be available                                 | P2       |

---

### FR-4: Recipe Management

**Priority:** P0 (MVP)

| Req ID  | Requirement                                                               | Priority |
| ------- | ------------------------------------------------------------------------- | -------- |
| FR-4.1  | Users shall manually create recipes with title, ingredients, instructions | P0       |
| FR-4.2  | Ingredient entries shall parse quantity, unit, and name                   | P0       |
| FR-4.3  | Recipes shall support multiple photos                                     | P0       |
| FR-4.4  | Users shall categorize recipes by tags (cuisine, meal type, difficulty)   | P0       |
| FR-4.5  | Recipes shall define servings/yield                                       | P0       |
| FR-4.6  | System shall scale ingredient quantities based on serving adjustments     | P0       |
| FR-4.7  | Users shall save recipes as drafts or published                           | P0       |
| FR-4.8  | Recipe search shall support text search across titles, ingredients, tags  | P0       |
| FR-4.9  | Users shall filter recipes by multiple criteria simultaneously            | P0       |
| FR-4.10 | System shall import recipes from URLs                                     | P1       |
| FR-4.11 | Imported recipes shall auto-extract structured data                       | P1       |
| FR-4.12 | Users shall edit imported recipes before saving                           | P1       |
| FR-4.13 | Failed imports shall provide fallback manual entry                        | P1       |
| FR-4.14 | Recipes shall support video attachments                                   | P2       |
| FR-4.15 | System shall detect duplicate recipes and suggest merging                 | P1       |

---

### FR-5: Pantry Inventory

**Priority:** P0 (MVP)

| Req ID  | Requirement                                                                 | Priority |
| ------- | --------------------------------------------------------------------------- | -------- |
| FR-5.1  | Users shall track pantry items with name, quantity, unit                    | P0       |
| FR-5.2  | Items shall support optional expiration dates                               | P0       |
| FR-5.3  | Items shall be categorizable (produce, dairy, grains, etc.)                 | P0       |
| FR-5.4  | Pantry list shall be searchable and filterable                              | P0       |
| FR-5.5  | Users shall edit item quantities and details                                | P0       |
| FR-5.6  | Items shall be marked as depleted/used                                      | P0       |
| FR-5.7  | System shall display expiration status with color coding (green/yellow/red) | P0       |
| FR-5.8  | "Expiring Soon" view shall filter items by timeframe (3 days, 1 week)       | P0       |
| FR-5.9  | Users shall receive push notifications for expiring items (1-2 days before) | P0       |
| FR-5.10 | Pantry shall sort by expiration date, category, or alphabetical             | P0       |
| FR-5.11 | Purchased shopping items shall auto-add to pantry when marked complete      | P1       |
| FR-5.12 | Cooking recipes shall auto-decrement used pantry items                      | P1       |
| FR-5.13 | System shall predict consumption based on usage patterns                    | P2       |
| FR-5.14 | Low inventory alerts shall trigger before depletion                         | P2       |

---

### FR-6: Recipe-Pantry Matching

**Priority:** P0 (MVP)

| Req ID | Requirement                                                       | Priority |
| ------ | ----------------------------------------------------------------- | -------- |
| FR-6.1 | System shall match recipes against current pantry inventory       | P0       |
| FR-6.2 | "What Can I Make?" view shall show fully-cookable recipes         | P0       |
| FR-6.3 | Partial matches shall display with missing ingredient count       | P0       |
| FR-6.4 | Results shall sort by match percentage (100%, 90%, 80%, etc.)     | P0       |
| FR-6.5 | Missing ingredients shall be highlighted with quantities          | P0       |
| FR-6.6 | Users shall add missing ingredients to shopping list with one tap | P0       |
| FR-6.7 | Recipe matching shall respect "Never Suggest" filters             | P1       |
| FR-6.8 | System shall prioritize recipes with expiring ingredients         | P1       |

---

### FR-7: User Authentication & Privacy

**Priority:** P0 (MVP)

| Req ID  | Requirement                                                      | Priority |
| ------- | ---------------------------------------------------------------- | -------- |
| FR-7.1  | App shall function fully without user account creation           | P0       |
| FR-7.2  | All data shall store locally by default                          | P0       |
| FR-7.3  | No data shall transmit to servers without explicit user opt-in   | P0       |
| FR-7.4  | Users shall optionally create accounts for cloud sync            | P0       |
| FR-7.5  | Account creation shall require email/password or OAuth providers | P0       |
| FR-7.6  | Cloud sync shall be toggleable in settings                       | P0       |
| FR-7.7  | Users shall selectively choose what data to sync                 | P1       |
| FR-7.8  | System shall support one-click data deletion (GDPR compliance)   | P0       |
| FR-7.9  | Users shall export complete data backup (JSON/CSV format)        | P1       |
| FR-7.10 | Anonymous mode shall strip identifying information during sync   | P1       |

---

### FR-8: Multi-Device Sync

**Priority:** P0 (MVP)

| Req ID  | Requirement                                                            | Priority |
| ------- | ---------------------------------------------------------------------- | -------- |
| FR-8.1  | Cloud sync shall synchronize recipes across devices                    | P0       |
| FR-8.2  | Meal plans shall sync bidirectionally                                  | P0       |
| FR-8.3  | Shopping lists shall sync in real-time when multiple devices connected | P0       |
| FR-8.4  | Pantry inventory shall sync with conflict resolution                   | P0       |
| FR-8.5  | Sync conflicts shall present user with resolution options              | P1       |
| FR-8.6  | Last-write-wins strategy shall apply to preferences/settings           | P1       |
| FR-8.7  | Operational transform shall handle concurrent edits to lists           | P1       |
| FR-8.8  | System shall track sync version per entity                             | P1       |
| FR-8.9  | Differential sync shall only transmit changes since last sync          | P1       |
| FR-8.10 | Sync failures shall queue operations for retry                         | P1       |

---

### FR-9: Notifications

**Priority:** P0 (MVP)

| Req ID | Requirement                                                                      | Priority |
| ------ | -------------------------------------------------------------------------------- | -------- |
| FR-9.1 | System shall send push notifications for expiring items (configurable threshold) | P0       |
| FR-9.2 | Users shall configure notification times and frequency                           | P0       |
| FR-9.3 | Notifications shall be dismissible or actionable                                 | P0       |
| FR-9.4 | System shall notify for meal plan reminders (e.g., prep time for dinner)         | P1       |
| FR-9.5 | Multi-stage notifications shall support customizable cascade (3h, 1h, prep time) | P1       |
| FR-9.6 | System shall learn optimal notification timing from user behavior                | P2       |
| FR-9.7 | Morning prep notifications shall trigger for slow cooker recipes                 | P1       |

---

### FR-10: Personalization & Discovery

**Priority:** P2 (Social/Engagement)

| Req ID  | Requirement                                                                      | Priority |
| ------- | -------------------------------------------------------------------------------- | -------- |
| FR-10.1 | System shall provide "Discover Weekly Meals" algorithmic recommendations         | P2       |
| FR-10.2 | Recommendation algorithm shall learn from cooking history and saves              | P2       |
| FR-10.3 | Personalized feed shall balance familiar (60%) and exploratory (40%) suggestions | P2       |
| FR-10.4 | Swipe interface shall enable quick recipe browsing                               | P2       |
| FR-10.5 | Algorithm shall improve from swipe patterns (right=save, left=skip)              | P2       |
| FR-10.6 | Curated playlists shall offer themed discovery (Comfort, Adventure, Quick)       | P2       |
| FR-10.7 | Recommendations shall respect dietary restrictions and preferences               | P2       |
| FR-10.8 | Users shall provide explicit feedback (rate recipes) to improve recommendations  | P2       |

---

### FR-11: Dietary Management

**Priority:** P1 (Post-MVP)

| Req ID  | Requirement                                                                | Priority |
| ------- | -------------------------------------------------------------------------- | -------- |
| FR-11.1 | Users shall define dietary profiles (vegetarian, vegan, gluten-free, etc.) | P1       |
| FR-11.2 | System shall filter all recipes by active dietary restrictions             | P1       |
| FR-11.3 | "Never Suggest" list shall permanently block ingredients/recipes           | P1       |
| FR-11.4 | Block intensity levels shall include Hard No, Soft No, Context-Dependent   | P1       |
| FR-11.5 | One-tap recipe transformations shall adapt recipes to dietary needs        | P1       |
| FR-11.6 | Transformation templates shall suggest ingredient substitutions            | P1       |
| FR-11.7 | System shall preserve original recipes when creating variants              | P1       |
| FR-11.8 | Auto-substitution shall replace blocked ingredients in recipes             | P1       |

---

### FR-12: Family & Collaboration

**Priority:** P1 (Post-MVP)

| Req ID  | Requirement                                                                  | Priority |
| ------- | ---------------------------------------------------------------------------- | -------- |
| FR-12.1 | System shall support multiple user profiles per household                    | P1       |
| FR-12.2 | Each profile shall have individual dietary restrictions and preferences      | P1       |
| FR-12.3 | Skill level shall be assignable per profile (beginner/intermediate/advanced) | P1       |
| FR-12.4 | Meal voting system shall collect preferences from household members          | P1       |
| FR-12.5 | Vote tallies shall influence final meal plan selections                      | P1       |
| FR-12.6 | Veto mechanism shall override votes for allergies/strong dislikes            | P1       |
| FR-12.7 | Shopping lists shall be shareable via QR code or link                        | P1       |
| FR-12.8 | Real-time collaboration shall show concurrent edits by multiple users        | P1       |
| FR-12.9 | Activity log shall show who added/checked off items                          | P1       |

---

## Non-Functional Requirements

### NFR-1: Performance

| Req ID   | Requirement                      | Target Metric                         |
| -------- | -------------------------------- | ------------------------------------- |
| NFR-1.1  | App launch time (cold start)     | < 2 seconds                           |
| NFR-1.2  | App launch time (warm start)     | < 1 second                            |
| NFR-1.3  | Shopping list scroll performance | 60 FPS with 500+ items                |
| NFR-1.4  | Recipe search response time      | < 500ms for 1000+ recipes             |
| NFR-1.5  | Meal plan view render time       | < 300ms                               |
| NFR-1.6  | Image loading (cached)           | < 100ms                               |
| NFR-1.7  | Image loading (network)          | Progressive (show placeholder < 50ms) |
| NFR-1.8  | Sync operation (differential)    | < 3 seconds for typical changes       |
| NFR-1.9  | Offline mode detection           | < 200ms                               |
| NFR-1.10 | Database query performance       | < 50ms for 95th percentile            |

---

### NFR-2: Reliability

| Req ID  | Requirement                        | Target Metric                       |
| ------- | ---------------------------------- | ----------------------------------- |
| NFR-2.1 | App crash rate                     | < 0.5% per session                  |
| NFR-2.2 | Data loss incidents                | Zero tolerance                      |
| NFR-2.3 | Sync success rate                  | > 99.5%                             |
| NFR-2.4 | Offline functionality availability | 100% (no degradation)               |
| NFR-2.5 | Backup completion rate             | 100% (hourly local, daily cloud)    |
| NFR-2.6 | Conflict resolution accuracy       | > 99% (user intervention for rest)  |
| NFR-2.7 | App recovery from crash            | Auto-restore state within 2 seconds |

---

### NFR-3: Scalability

| Req ID  | Requirement                             | Target Metric                    |
| ------- | --------------------------------------- | -------------------------------- |
| NFR-3.1 | Maximum recipes per user                | 10,000+                          |
| NFR-3.2 | Maximum shopping list items             | 500+ per list                    |
| NFR-3.3 | Maximum pantry items                    | 1,000+                           |
| NFR-3.4 | Maximum meal plans stored               | 52+ weeks                        |
| NFR-3.5 | Maximum concurrent devices per account  | 5                                |
| NFR-3.6 | Recipe search performance with large DB | No degradation up to 10K recipes |
| NFR-3.7 | Cloud storage per user                  | 1GB (images + data)              |

---

### NFR-4: Usability

| Req ID   | Requirement                        | Target Metric                                 |
| -------- | ---------------------------------- | --------------------------------------------- |
| NFR-4.1  | Time to create first shopping list | < 30 seconds (new user)                       |
| NFR-4.2  | Time to plan weekly meals          | < 5 minutes (with 10+ saved recipes)          |
| NFR-4.3  | Time to add recipe                 | < 2 minutes (manual entry)                    |
| NFR-4.4  | Time to find recipe                | < 10 seconds (with search/filter)             |
| NFR-4.5  | Accessibility compliance           | WCAG 2.1 Level AA                             |
| NFR-4.6  | Font size adjustability            | System font scaling support (50%-200%)        |
| NFR-4.7  | Color contrast ratios              | Minimum 4.5:1 (normal text), 3:1 (large text) |
| NFR-4.8  | Screen reader compatibility        | Full VoiceOver/TalkBack support               |
| NFR-4.9  | Onboarding completion rate         | > 80%                                         |
| NFR-4.10 | Feature discoverability            | > 70% users find core features without help   |

---

### NFR-5: Security

| Req ID   | Requirement                | Implementation                                       |
| -------- | -------------------------- | ---------------------------------------------------- |
| NFR-5.1  | Data encryption at rest    | AES-256 encryption for local database                |
| NFR-5.2  | Data encryption in transit | TLS 1.3 for all network communication                |
| NFR-5.3  | Authentication security    | OAuth 2.0 + JWT tokens (15-min expiry)               |
| NFR-5.4  | Password requirements      | Min 8 chars, complexity check, breach database check |
| NFR-5.5  | Session management         | Auto-logout after 30 days inactivity                 |
| NFR-5.6  | API security               | Rate limiting (100 req/min per user)                 |
| NFR-5.7  | Input validation           | Server-side validation for all inputs                |
| NFR-5.8  | XSS protection             | Content sanitization for user-generated content      |
| NFR-5.9  | SQL injection protection   | Parameterized queries only                           |
| NFR-5.10 | GDPR compliance            | Right to access, delete, export data                 |

---

### NFR-6: Compatibility

| Req ID  | Requirement             | Specification                                            |
| ------- | ----------------------- | -------------------------------------------------------- |
| NFR-6.1 | iOS version support     | iOS 13.0+ (latest 4 major versions)                      |
| NFR-6.2 | Android version support | Android 8.0+ (API level 26+)                             |
| NFR-6.3 | Screen size support     | 4.7" to 6.7" smartphones (primary), tablets (acceptable) |
| NFR-6.4 | Orientation support     | Portrait (primary), landscape (acceptable)               |
| NFR-6.5 | Language support        | English (launch), Spanish/French (phase 2)               |
| NFR-6.6 | RTL language support    | Phase 3 (Arabic, Hebrew)                                 |
| NFR-6.7 | Dark mode support       | System theme auto-switching                              |

---

### NFR-7: Maintainability

| Req ID  | Requirement           | Implementation                        |
| ------- | --------------------- | ------------------------------------- |
| NFR-7.1 | Code coverage         | > 80% unit test coverage              |
| NFR-7.2 | Documentation         | Inline code docs + architecture docs  |
| NFR-7.3 | Build automation      | CI/CD pipeline with automated tests   |
| NFR-7.4 | Dependency management | Quarterly dependency updates          |
| NFR-7.5 | Error tracking        | Crashlytics/Sentry integration        |
| NFR-7.6 | Analytics             | Privacy-respecting analytics (opt-in) |
| NFR-7.7 | Feature flags         | Remote config for gradual rollouts    |
| NFR-7.8 | Version control       | Git with trunk-based development      |

---

### NFR-8: Offline Capability

| Req ID  | Requirement                | Target Metric                               |
| ------- | -------------------------- | ------------------------------------------- |
| NFR-8.1 | Offline duration support   | Indefinite (fully functional)               |
| NFR-8.2 | Offline data storage       | 500MB local cache minimum                   |
| NFR-8.3 | Sync queue size            | 1000+ pending operations                    |
| NFR-8.4 | Conflict resolution time   | < 5 seconds per conflict                    |
| NFR-8.5 | Recovery from long offline | < 30 seconds to sync 1 week of changes      |
| NFR-8.6 | Storage full handling      | Graceful degradation with user notification |

---

## Technical Requirements

### TR-1: Technology Stack

**Frontend (Mobile App):**

- **Framework:** Flutter 3.16+ (Dart 3.2+)
- **State Management:** Riverpod 2.x or Bloc 8.x
- **Navigation:** Go Router 12.x
- **UI Components:** Material Design 3 with custom theme
- **Animations:** Flutter built-in animation library

**Local Data Layer:**

- **Database:** Hive 2.x (NoSQL) OR Drift 2.x (SQLite with type-safe queries)
- **Recommendation:** Hive for MVP simplicity, migrate to Drift if complex queries needed
- **Cache:** Flutter Cache Manager for images
- **Secure Storage:** Flutter Secure Storage for sensitive data

**Backend (Cloud Services):**

- **Option A - Firebase:**
  - Firestore (NoSQL database)
  - Firebase Authentication (email, Google, Apple Sign-In)
  - Firebase Storage (images)
  - Cloud Functions (serverless processing)
  - Firebase Analytics + Crashlytics

- **Option B - Supabase (Open Source Alternative):**
  - PostgreSQL database
  - Supabase Auth
  - Supabase Storage
  - Edge Functions
  - Self-hosted analytics

**Recommendation:** Firebase for MVP (faster setup), Supabase for Phase 2 if migration needed for cost/control

**Additional Services:**

- **Push Notifications:** Firebase Cloud Messaging (FCM) or OneSignal
- **Image Processing:** Cloud Functions or Cloudflare Images
- **Recipe Import:** Custom web scraper service or Spoonacular API

---

### TR-2: Architecture Pattern

**Overall Pattern:** Clean Architecture + Offline-First

```
┌─────────────────────────────────────────────────┐
│             Presentation Layer                  │
│  (Widgets, Pages, State Management)             │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│            Application Layer                    │
│  (Use Cases, Business Logic, DTOs)              │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│              Domain Layer                       │
│  (Entities, Value Objects, Domain Logic)        │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│             Data Layer                          │
│  ┌─────────────────────────────────────────┐   │
│  │  Repository (Abstract Interface)        │   │
│  └──────┬──────────────────────────┬───────┘   │
│         │                          │            │
│  ┌──────▼────────┐         ┌───────▼────────┐  │
│  │ Local Data    │         │  Remote Data   │  │
│  │ Source (Hive) │         │ Source (API)   │  │
│  └───────────────┘         └────────────────┘  │
└─────────────────────────────────────────────────┘
```

**Key Principles:**

1. **Repository Pattern:** Abstract data sources behind interfaces
2. **Dependency Injection:** Use Riverpod providers or GetIt
3. **Feature-Based Structure:** Organize by feature, not layer
4. **Immutable State:** Use freezed for data classes
5. **Functional Error Handling:** Result/Either types (fpdart or dartz)

---

### TR-3: Data Models

**Core Entity Schema (Simplified):**

```dart
// Recipe Entity
class Recipe {
  final String id;              // UUID
  final String title;
  final String? description;
  final int servings;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final List<String> imageUrls;
  final List<String> tags;     // ["italian", "pasta", "easy"]
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final int syncVersion;
}

// Ingredient Value Object
class Ingredient {
  final String id;
  final double? quantity;
  final String? unit;          // "cup", "tbsp", "g", etc.
  final String name;
  final String? notes;         // "minced", "optional"
}

// Meal Plan Entity
class MealPlan {
  final String id;
  final DateTime weekStartDate;
  final Map<String, String?> meals;  // Key: "monday_dinner", Value: recipeId
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Shopping List Entity
class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingItem> items;
  final String? linkedMealPlanId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Shopping Item Value Object
class ShoppingItem {
  final String id;
  final String name;
  final double? quantity;
  final String? unit;
  final String? category;      // "produce", "dairy", etc.
  final bool isPurchased;
  final String? notes;
}

// Pantry Item Entity
class PantryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final DateTime? expirationDate;
  final DateTime addedAt;
  final DateTime updatedAt;
}

// User Profile Entity (optional, for cloud sync)
class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final List<String> dietaryRestrictions;  // ["vegetarian", "gluten-free"]
  final List<String> blockedIngredients;   // "Never suggest" list
  final Map<String, dynamic> preferences;  // Flexible JSON for settings
  final DateTime createdAt;
}
```

---

### TR-4: Sync Architecture

**Offline-First Sync Strategy:**

1. **Write Path:**

   ```
   User Action → Local DB (immediate) → UI Update (instant)
                 ↓
   Background Queue → Network Check → Cloud Sync (when available)
   ```

2. **Read Path:**

   ```
   App Launch → Load from Local DB (instant)
                ↓
   Background → Fetch Cloud Updates → Merge → Update Local + UI
   ```

3. **Conflict Resolution:**
   - **Shopping Lists:** Operational Transform (preserve all edits)
   - **Meal Plans:** Last-Write-Wins with timestamp
   - **Recipes:** Server version + local version both preserved, user chooses
   - **Pantry:** Merge quantities, flag for review

4. **Sync Protocol:**

   ```
   Client:
   - Tracks lastSyncTimestamp per entity type
   - Sends GET /sync?entity=recipes&since=timestamp

   Server:
   - Returns {updates: [...], deletions: [...], conflicts: [...]}

   Client:
   - Applies non-conflicting updates
   - Resolves conflicts (auto or manual)
   - Sends POST /sync with local changes

   Server:
   - Returns {accepted: [...], rejected: [...]}
   ```

---

### TR-5: Database Schema (Hive/Local)

**Collections/Boxes:**

- **recipes** (Recipe entity)
- **meal_plans** (MealPlan entity)
- **shopping_lists** (ShoppingList entity)
- **pantry_items** (PantryItem entity)
- **user_profile** (UserProfile entity)
- **sync_queue** (Pending sync operations)
- **sync_metadata** (Last sync timestamps, version tracking)

**Indexes:**

- recipes: title, tags, createdAt, updatedAt
- pantry_items: expirationDate, category
- shopping_lists: createdAt, isCompleted
- meal_plans: weekStartDate

---

### TR-6: API Endpoints (Cloud Services)

**Authentication:**

- POST /auth/register (email + password)
- POST /auth/login (email + password)
- POST /auth/oauth (Google, Apple)
- POST /auth/refresh (refresh JWT token)
- POST /auth/logout

**Sync Endpoints:**

- GET /sync/recipes?since={timestamp}
- POST /sync/recipes (batch upload)
- GET /sync/meal_plans?since={timestamp}
- POST /sync/meal_plans
- GET /sync/shopping_lists?since={timestamp}
- POST /sync/shopping_lists
- GET /sync/pantry?since={timestamp}
- POST /sync/pantry

**Recipe Discovery (Future):**

- GET /discover/recipes (algorithmic recommendations)
- GET /recipes/popular
- GET /recipes/search?q={query}&tags={tags}
- GET /recipes/import?url={url} (web scraping service)

**User Profile:**

- GET /profile
- PUT /profile
- DELETE /profile (GDPR deletion)
- GET /profile/export (full data export)

---

### TR-7: Third-Party Integrations

| Service                  | Purpose                                  | Priority |
| ------------------------ | ---------------------------------------- | -------- |
| Firebase/Supabase        | Backend, auth, database                  | P0       |
| Firebase Cloud Messaging | Push notifications                       | P0       |
| Sentry/Crashlytics       | Error tracking                           | P0       |
| Google ML Kit            | On-device OCR for ingredient recognition | P1       |
| Spoonacular API          | Recipe import/parsing fallback           | P1       |
| OpenFoodFacts API        | Barcode scanning for products            | P2       |
| Nutritionix API          | Nutritional data enrichment              | P3       |
| Instacart/Walmart API    | Grocery delivery integration             | P4       |

---

### TR-8: Testing Strategy

**Unit Tests (80% coverage target):**

- All business logic in Use Cases
- All domain entities and value objects
- Repository implementations
- State management logic

**Widget Tests:**

- Critical UI components (shopping list, meal planner)
- User input forms
- Navigation flows
- Error states

**Integration Tests:**

- End-to-end flows (create meal plan → generate shopping list)
- Offline mode functionality
- Sync operations
- Database migrations

**Tools:**

- Flutter built-in test framework
- Mockito for mocking
- Golden tests for UI regression

---

### TR-9: CI/CD Pipeline

**Build Pipeline:**

1. Code lint (flutter analyze)
2. Unit tests (flutter test)
3. Widget tests
4. Build iOS (Xcode Cloud or Codemagic)
5. Build Android (GitHub Actions or Codemagic)
6. Beta deployment (TestFlight, Play Internal Testing)

**Release Pipeline:**

1. Tag release version (semantic versioning)
2. Run full test suite
3. Build release builds
4. Code signing (iOS, Android)
5. Deploy to App Store / Play Store
6. Monitor crash reports and rollback if needed

**Recommended Tools:**

- **CI/CD:** GitHub Actions, Codemagic, or Bitrise
- **Code Coverage:** Codecov
- **Static Analysis:** flutter analyze + custom lint rules

---

### TR-10: Performance Optimization

**Strategies:**

1. **Lazy Loading:** Load recipes on-demand, not all at once
2. **Pagination:** Paginate long lists (shopping, recipes)
3. **Image Caching:** Aggressive caching with size limits
4. **Database Indexing:** Index frequently queried fields
5. **Debouncing:** Search input with 300ms debounce
6. **Memoization:** Cache expensive computation results
7. **Background Processing:** Heavy tasks (sync, image processing) in isolates

**Monitoring:**

- Performance metrics via Firebase Performance
- Network call duration tracking
- Database query profiling
- Frame rate monitoring (DevTools)

---

## Feature Prioritization

### Priority Levels

| Level  | Description                      | Timeline    | Examples                                          |
| ------ | -------------------------------- | ----------- | ------------------------------------------------- |
| **P0** | MVP - Must have for launch       | Month 1-4   | Shopping lists, meal planning, offline mode       |
| **P1** | Post-MVP - Early differentiators | Month 5-7   | Recipe import, smart suggestions, family features |
| **P2** | Engagement - Growth features     | Month 7-10  | Social discovery, video content, gamification     |
| **P3** | Advanced - AI/ML enhancements    | Month 10-14 | Voice assistant, advanced AI, predictive features |
| **P4** | Ecosystem - Integrations         | Month 14+   | Smart appliances, delivery, partnerships          |
| **P5** | Specialized - Niche features     | Post-launch | Emergency prep, budget analytics, marketplace     |

---

### MVP Feature Set (P0)

**Must-Have for Launch:**

✅ **Core Shopping (4 weeks)**

- Shopping list CRUD
- Text, voice, photo entry
- List/grid view toggle
- Offline functionality
- Basic categories

✅ **Core Meal Planning (5 weeks)**

- 7-day meal planner
- Recipe database (manual entry)
- Auto-generate shopping list from plan
- Pantry inventory tracker
- Recipe-pantry matching

✅ **Essential UX (3 weeks)**

- Clean, intuitive UI
- Multi-language support (English initially)
- Dark mode
- Onboarding flow
- Settings management

✅ **Privacy & Sync (4 weeks)**

- No-login default
- Local-first storage
- Optional cloud sync
- Basic conflict resolution
- Data export

✅ **Quality (2 weeks)**

- Error handling
- Loading states
- Empty states
- Notifications (expiring items)
- Basic analytics

**Total MVP Timeline:** 16-18 weeks (4-4.5 months)

---

### Post-MVP Features (P1)

**Next Wave (Months 5-7):**

🎯 **Intelligence Layer**

- Consumption predictions
- Expiration-aware planning
- Leftover-first planning
- Smart meal suggestions

🎯 **Enhanced Input**

- Recipe URL import
- OCR for recipe cards
- Barcode scanning
- Improved voice commands

🎯 **Family Features**

- Household profiles
- Meal voting
- Shared shopping lists
- Skill level filtering

🎯 **Dietary Management**

- "Never suggest" filtering
- One-tap transformations
- Dietary profiles
- Auto-substitution

🎯 **Robust Sync**

- Operational transform conflicts
- Multi-device real-time sync
- Progressive sync
- Crash recovery

---

### Growth Features (P2)

**Engagement Phase (Months 7-10):**

📱 **Social Discovery**

- 60-second recipe videos
- Swipe-based browsing
- "Discover Weekly" playlists
- Community sharing
- Recipe challenges

📱 **Community**

- Public recipe library
- Follow/clone functionality
- "I Made This" photo sharing
- Trending recipes
- User reviews/ratings

---

### Advanced Features (P3-P5)

**Future Enhancements:**

🧠 **P3: Advanced Intelligence**

- Voice chef assistant
- Computer vision (ingredient recognition)
- Advanced behavioral learning
- Nutritional optimization
- Budget algorithms

🌐 **P4: Ecosystem**

- Smart appliance integration
- Grocery delivery APIs
- Store partnerships (pricing)
- 3D store maps with AR
- Calendar sync

💎 **P5: Specialized**

- Emergency preparedness mode
- Gamification with XP
- Meal plan marketplace
- Professional chef content
- Advanced analytics dashboard

---

## Release Roadmap

### Phase 1: MVP (Months 1-4)

**Milestone 1.1: Foundation (Weeks 1-4)**

- Project setup, architecture
- Local database implementation
- Basic UI components
- Shopping list CRUD (text entry)
- Offline-first proof of concept

**Deliverable:** Working prototype with offline shopping list

---

**Milestone 1.2: Core Features (Weeks 5-10)**

- Recipe management (manual entry)
- Weekly meal planner UI
- Pantry inventory tracker
- Auto-generate shopping list from meal plan
- Recipe-pantry matching
- Photo capture for items

**Deliverable:** Alpha build with core workflow

---

**Milestone 1.3: Polish & Sync (Weeks 11-16)**

- Cloud sync implementation
- Optional authentication
- Expiration tracking + notifications
- Portion scaling
- Multi-language UI
- Dark mode
- Onboarding flow
- Beta testing preparation

**Deliverable:** Beta release (TestFlight, Play Internal Testing)

---

**Milestone 1.4: Launch Prep (Weeks 17-18)**

- Bug fixes from beta feedback
- Performance optimization
- App Store assets (screenshots, descriptions)
- Launch marketing materials
- Analytics and crash reporting setup

**Deliverable:** Public App Store release v1.0

---

### Phase 2: Intelligence (Months 5-7)

**Milestone 2.1: Smart Features (Weeks 19-24)**

- Recipe URL import
- Basic recommendation algorithm
- Consumption predictions
- Expiration-aware suggestions
- "Never suggest" filtering
- Dietary transformation templates

**Deliverable:** v1.1 with smart planning features

---

**Milestone 2.2: Family & Collaboration (Weeks 25-30)**

- Household profiles
- Meal voting system
- Shared shopping lists (QR/link)
- Real-time collaboration
- Skill level filtering
- Leftover planning mode

**Deliverable:** v1.2 with family features

---

### Phase 3: Growth (Months 7-10)

**Milestone 3.1: Social Discovery (Weeks 31-36)**

- Public recipe library
- "Discover Weekly" algorithm
- Swipe-based recipe browser
- Recipe sharing & cloning
- Community features (follow, likes)

**Deliverable:** v2.0 with social features

---

**Milestone 3.2: Engagement (Weeks 37-42)**

- 60-second video recipe feed
- "I Made This" photo sharing
- Recipe challenges & hashtags
- Trending recipes view
- User ratings and reviews

**Deliverable:** v2.1 with viral features

---

### Phase 4: Advanced (Months 10-14)

**Milestone 4.1: AI Enhancement (Weeks 43-50)**

- Voice chef assistant
- Computer vision for ingredients
- Advanced behavioral learning
- Nutritional tracking & goals
- Budget optimization

**Deliverable:** v3.0 with premium AI features

---

**Milestone 4.2: Ecosystem (Weeks 51-58)**

- Smart appliance integration
- Grocery delivery API integration
- Store partnerships (pricing data)
- Calendar sync
- 3D store maps (pilot cities)

**Deliverable:** v3.1 with ecosystem integrations

---

## Success Criteria

### North Star Metric

**Meals Planned & Cooked per Week**  
Target: Average 3+ meals planned and executed per active user per week

---

### Key Performance Indicators (KPIs)

#### Acquisition Metrics

| Metric                 | Baseline | 3 Months | 6 Months | 12 Months |
| ---------------------- | -------- | -------- | -------- | --------- |
| Total Downloads        | 0        | 1,000    | 5,000    | 25,000    |
| Active Users (MAU)     | 0        | 500      | 2,500    | 15,000    |
| Install-to-Active Rate | -        | 60%      | 65%      | 70%       |
| Organic vs. Paid       | -        | 80/20    | 70/30    | 60/40     |

---

#### Engagement Metrics

| Metric                     | Target (Month 3) | Target (Month 6) | Target (Month 12) |
| -------------------------- | ---------------- | ---------------- | ----------------- |
| Daily Active Users (DAU)   | 150              | 800              | 5,000             |
| Weekly Active Users (WAU)  | 350              | 1,750            | 10,500            |
| Monthly Active Users (MAU) | 500              | 2,500            | 15,000            |
| DAU/MAU Ratio              | 30%              | 32%              | 33%               |
| Average Session Length     | 4 min            | 5 min            | 6 min             |
| Sessions per Week          | 3                | 4                | 5                 |
| Meals Planned per Week     | 2.5              | 3                | 4                 |
| Shopping Trips with App    | 3                | 4                | 5                 |

---

#### Retention Metrics

| Metric            | Target (Month 3) | Target (Month 6) | Target (Month 12) |
| ----------------- | ---------------- | ---------------- | ----------------- |
| Day 1 Retention   | 40%              | 45%              | 50%               |
| Day 7 Retention   | 30%              | 35%              | 40%               |
| Day 30 Retention  | 20%              | 25%              | 30%               |
| Week 4 Retention  | 70%              | 75%              | 80%               |
| Resurrection Rate | -                | 15%              | 20%               |

---

#### Feature Adoption

| Feature                | Adoption Target | Timeline |
| ---------------------- | --------------- | -------- |
| Shopping List Creation | 95% of users    | Month 1  |
| Meal Planning          | 70% of users    | Month 2  |
| Pantry Tracking        | 50% of users    | Month 3  |
| Recipe Import          | 40% of users    | Month 5  |
| Cloud Sync Opt-In      | 50% of users    | Month 3  |
| Family Sharing         | 25% of users    | Month 7  |
| Recipe Discovery       | 60% of users    | Month 9  |

---

#### Satisfaction Metrics

| Metric                         | Target | Measurement Method      |
| ------------------------------ | ------ | ----------------------- |
| Net Promoter Score (NPS)       | > 40   | In-app survey (monthly) |
| App Store Rating               | > 4.3  | Organic reviews         |
| Customer Satisfaction (CSAT)   | > 85%  | Post-feature surveys    |
| Feature Request Implementation | > 20%  | Community feedback      |

---

#### Business Metrics

| Metric                               | 3 Months | 6 Months | 12 Months |
| ------------------------------------ | -------- | -------- | --------- |
| Monthly Active Users                 | 500      | 2,500    | 15,000    |
| Cloud Sync Users (potential premium) | 250      | 1,250    | 7,500     |
| Avg. Revenue per User (ARPU)         | $0       | $0.50    | $2        |
| Monthly Recurring Revenue (MRR)      | $0       | $1,250   | $30,000   |
| Churn Rate                           | -        | 5%       | 4%        |

_Note: Monetization via freemium model (premium features: advanced AI, unlimited cloud sync, family plans) starting Month 9+_

---

### Success Milestones

**Month 1 (Post-Launch):**

- ✅ 100+ active users
- ✅ < 1% crash rate
- ✅ 40%+ Day 1 retention
- ✅ App Store approval

**Month 3:**

- ✅ 500+ active users
- ✅ 70%+ Week 4 retention
- ✅ 4.0+ App Store rating
- ✅ NPS > 30

**Month 6:**

- ✅ 2,500+ active users
- ✅ Featured in App Store / Play Store
- ✅ 4.3+ App Store rating
- ✅ NPS > 40
- ✅ First premium subscriptions

**Month 12:**

- ✅ 15,000+ active users
- ✅ Product-market fit confirmed (high NPS + retention)
- ✅ $30K+ MRR
- ✅ Expansion to 2nd language market

---

## Dependencies & Constraints

### Critical Dependencies

**Technical:**

- Flutter framework stability (3.x)
- Firebase/Supabase service availability (99.9% SLA)
- App Store / Play Store approval (2-7 days lead time)
- Third-party API reliability (Spoonacular, nutrition APIs)
- Cloud infrastructure costs within budget ($500/mo at 5K MAU)

**Team:**

- 2-3 Flutter developers (full-time)
- 1 UI/UX designer (full-time Month 1-2, part-time ongoing)
- 1 Backend developer (part-time for API/cloud functions)
- 1 QA tester (part-time Month 3+)
- 1 Product manager / Founder (full-time)

**Resources:**

- Development budget: $150K-$200K for MVP (4 months)
- Marketing budget: $20K for first 6 months
- Cloud infrastructure: $500-$2,000/mo (scales with users)
- Third-party services: $500-$1,000/mo

---

### Key Constraints

**Time:**

- MVP launch target: 4 months from kickoff
- Beta testing minimum: 2 weeks
- App Store review: 2-7 days additional

**Technical:**

- Offline functionality is non-negotiable (critical for success)
- Privacy-first approach limits data collection for personalization
- Cross-platform parity (iOS and Android must have feature parity)
- Device storage limitations (target < 100MB base app size)
- Network bandwidth constraints (optimize image sizes)

**Regulatory:**

- GDPR compliance (EU users)
- CCPA compliance (California users)
- Children's privacy (COPPA) - avoid marketing to <13
- Food safety disclaimers (recipes are user-generated)
- Accessibility standards (WCAG 2.1)

**Business:**

- Bootstrap or limited funding (cost-conscious decisions)
- No monetization pressure in first 6 months (focus on growth)
- Competitive landscape (Paprika, Mealime, AnyList, Bring!)

---

### Risk Mitigation

| Risk                             | Impact | Likelihood | Mitigation Strategy                                       |
| -------------------------------- | ------ | ---------- | --------------------------------------------------------- |
| **Offline sync complexity**      | High   | High       | Allocate 20% extra time, hire sync expert for review      |
| **Low user adoption**            | High   | Medium     | Extensive beta testing, pivot features based on feedback  |
| **App Store rejection**          | High   | Low        | Follow guidelines strictly, pre-submission review service |
| **Performance issues at scale**  | Medium | Medium     | Load testing with 10K+ recipes, database optimization     |
| **Competition from big players** | High   | Medium     | Focus on offline-first + privacy differentiation          |
| **Developer availability**       | Medium | Medium     | Cross-train team, document thoroughly, contractor backup  |
| **Cloud cost overruns**          | Medium | Low        | Set billing alerts, optimize storage, cache aggressively  |
| **Recipe import legal issues**   | Medium | Low        | User-generated content only, clear ToS, DMCA process      |

---

## Appendix

### A. Glossary

| Term                      | Definition                                                                     |
| ------------------------- | ------------------------------------------------------------------------------ |
| **Meal Plan**             | A weekly schedule of recipes assigned to specific days/meals                   |
| **Pantry**                | Virtual inventory of ingredients/food items currently owned                    |
| **Shopping List**         | Checklist of items to purchase, optionally generated from meal plan            |
| **Recipe**                | Structured cooking instructions with ingredients, steps, and metadata          |
| **Leftover Chain**        | Sequence of meals where one recipe's leftovers become ingredients for the next |
| **Operational Transform** | Algorithm for resolving concurrent edits to shared data structures             |
| **Offline-First**         | Architecture pattern where app functions fully without internet, syncing later |
| **FIFO**                  | First In, First Out - inventory rotation strategy for food freshness           |

---

### B. User Research Insights

**Key Findings from User Interviews (Simulated):**

1. **Meal Planning Friction:**
   - "I spend 2 hours every Sunday just figuring out what to cook"
   - "I plan meals but always forget to check what I already have"
   - Pain points: Decision fatigue, lack of inspiration, time-consuming

2. **Shopping Disconnection:**
   - "I plan meals, but then forget to add ingredients to my list"
   - "I'm at the store and realize I don't have cell service to check my list"
   - Pain points: Manual transcription, connectivity issues, forgotten items

3. **Food Waste:**
   - "I throw away vegetables every week because I forget about them"
   - "I buy ingredients for one recipe, rest of the package spoils"
   - Pain points: Poor visibility, no expiration tracking, over-purchasing

4. **Family Dynamics:**
   - "My kids complain about every dinner I plan without their input"
   - "Partner and I both shop, end up with duplicates"
   - Pain points: Lack of collaboration, miscommunication, preference conflicts

5. **Privacy Concerns:**
   - "I don't want to create another account for a shopping list"
   - "Why does a recipe app need my email?"
   - Preferences: No-login default, local-first, optional cloud

---

### C. Competitive Analysis

| Competitor   | Strengths                            | Weaknesses                            | Our Advantage                                         |
| ------------ | ------------------------------------ | ------------------------------------- | ----------------------------------------------------- |
| **Paprika**  | Excellent recipe import, clean UI    | No meal planning, paid upfront, no AI | Integrated meal planning, freemium, AI suggestions    |
| **Mealime**  | Strong meal planning, diet-focused   | No pantry tracking, requires account  | Offline-first, no-login default, pantry integration   |
| **AnyList**  | Great shopping lists, family sharing | Weak recipe management, no AI         | Recipe-centric, AI recommendations, leftover planning |
| **Bring!**   | Simple, fast, beautiful UI           | No meal planning, no recipes          | All-in-one solution, intelligence layer               |
| **Cooklist** | Pantry tracking, expiration alerts   | Poor UX, limited recipe database      | Better UX, community recipes, discovery               |

---

### D. Open Questions

**To Be Resolved During MVP Development:**

1. **Recipe Import Quality:**
   - How accurate is web scraping across different sites?
   - Fallback strategy when import fails?
   - Should we partner with recipe platforms for official API access?

2. **Monetization Strategy:**
   - When to introduce premium features (Month 6? Month 9?)?
   - Pricing: $3.99/mo, $29.99/yr, or $9.99 one-time?
   - Which features behind paywall vs. free forever?

3. **Content Cold Start:**
   - Should we seed new users with 20-30 popular recipes?
   - Curate starter collections by cuisine/diet?
   - Rely on user imports only?

4. **Sync Complexity:**
   - Is Hive sufficient or do we need Drift/SQLite for complex queries?
   - Should we implement operational transform for MVP or defer to P1?
   - Acceptable sync conflict rate before needing manual resolution?

5. **Notification Strategy:**
   - How many push notifications before users disable them?
   - Optimal timing for meal prep reminders?
   - Smart batching vs. individual alerts?

---

### E. Related Documents

- [Brainstorming Session Output](brainstorming-session-2026-02-25.md) - 101 ideas generated
- [User Research Summary](#) - TBD (Conduct 10 interviews)
- [Technical Architecture Spec](#) - TBD (Detailed system design)
- [UI/UX Design System](#) - TBD (Figma prototypes)
- [Go-to-Market Strategy](#) - TBD (Marketing plan)
- [API Documentation](#) - TBD (Endpoint specs)

---

**Document End**

---

## Document Approval

| Role            | Name | Date       | Signature |
| --------------- | ---- | ---------- | --------- |
| Product Manager | TBD  | 2026-02-25 | Pending   |
| Tech Lead       | TBD  | -          | Pending   |
| UX Lead         | TBD  | -          | Pending   |
| Stakeholder     | TBD  | -          | Pending   |

---

**Next Steps:**

1. Review and approve PRD with stakeholders
2. Conduct user interviews to validate assumptions
3. Create detailed technical architecture document
4. Begin UI/UX design (wireframes → mockups → prototypes)
5. Set up development environment and project structure
6. Kick off Sprint 1 (Week 1-2): Project foundation
