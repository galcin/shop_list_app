# UX Design Specification

## Flutter Shopping List & Meal Planning App

**Document Version:** 1.0  
**Date:** February 25, 2026  
**Status:** Draft  
**Related Documents:** [PRD](prd-shopping-list-app.md), [Brainstorming Session](brainstorming/brainstorming-session-2026-02-25.md)

---

## Executive Summary

This document outlines the complete user experience design for the Flutter Shopping List & Meal Planning App, including information architecture, user flows, wireframe specifications, design system, and interaction patterns. The design prioritizes offline-first functionality, privacy, and seamless integration between meal planning and shopping.

### Design Principles

1. **Offline-First** - Every screen must work without connectivity
2. **Privacy by Design** - No forced sign-in, clear data controls
3. **Clarity Over Cleverness** - Intuitive interactions, minimal learning curve
4. **Progressive Disclosure** - Advanced features discoverable, not overwhelming
5. **Accessibility First** - Readable, navigable, inclusive for all abilities
6. **Speed Matters** - Instant feedback, optimistic UI updates
7. **Family-Friendly** - Accommodates multiple users and preferences

---

## Table of Contents

1. [Information Architecture](#information-architecture)
2. [Navigation Design](#navigation-design)
3. [User Flows](#user-flows)
4. [Screen Specifications](#screen-specifications)
5. [Design System](#design-system)
6. [Interaction Patterns](#interaction-patterns)
7. [Responsive Design](#responsive-design)
8. [Accessibility](#accessibility)
9. [Onboarding](#onboarding)
10. [Edge Cases & Error States](#edge-cases--error-states)

---

## Information Architecture

### App Structure Map

```
App Root
│
├── 📱 Home / Dashboard
│   ├── Quick Actions (Add to List, Plan Meal, Check Pantry)
│   ├── Expiring Soon Widget
│   ├── This Week's Meals Widget
│   └── Shopping List Summary Widget
│
├── 🛒 Shopping Lists (Tab 1)
│   ├── All Lists View
│   ├── Active List Detail
│   │   ├── List/Grid Toggle
│   │   ├── Add Item (Text/Voice/Photo)
│   │   ├── Category Sections
│   │   ├── Check Off Items
│   │   └── Share List
│   └── Create New List
│
├── 🍽️ Meal Planning (Tab 2)
│   ├── Weekly Calendar View
│   ├── Meal Slot Detail
│   │   ├── Assign Recipe
│   │   ├── View Recipe
│   │   └── Swap/Remove Meal
│   ├── Generate Shopping List
│   └── Previous/Next Week Navigation
│
├── 📖 Recipes (Tab 3)
│   ├── All Recipes Grid/List
│   ├── Search & Filter
│   ├── Recipe Detail
│   │   ├── Ingredients
│   │   ├── Instructions
│   │   ├── Photos/Videos
│   │   ├── Portion Scaling
│   │   ├── Add to Meal Plan
│   │   └── Add to Shopping List
│   ├── Add New Recipe
│   │   ├── Manual Entry
│   │   ├── Import from URL
│   │   └── Photo OCR (future)
│   └── "What Can I Make?" View
│
├── 🥫 Pantry (Tab 4)
│   ├── All Items List
│   ├── Expiring Soon View
│   ├── Categories Filter
│   ├── Add Item
│   ├── Edit Item
│   └── Quick Add from Shopping
│
└── ⚙️ Settings (Tab 5 or Menu)
    ├── Profile & Preferences
    ├── Household Management
    ├── Dietary Restrictions
    ├── "Never Suggest" List
    ├── Notifications
    ├── Privacy & Data
    ├── Cloud Sync Toggle
    ├── Export Data
    └── About/Help
```

---

### Screen Hierarchy & Priority

| Level         | Screens                                           | User Frequency   | Design Priority               |
| ------------- | ------------------------------------------------- | ---------------- | ----------------------------- |
| **Primary**   | Shopping List Detail, Meal Planner, Recipe Detail | Daily            | Highest - Perfect these first |
| **Secondary** | Recipe List, Pantry, Home Dashboard               | 2-3x/week        | High - Must be polished       |
| **Tertiary**  | Add Recipe, Settings, What Can I Make             | Weekly           | Medium - Functional is OK     |
| **Utility**   | Onboarding, Empty States, Errors                  | One-time or rare | Important but not frequent    |

---

## Navigation Design

### Bottom Navigation Bar (Primary)

**5-Tab Structure:**

```
┌─────────────────────────────────────────────────────────────┐
│ [🏠 Home] [🛒 Lists] [🍽️ Meals] [📖 Recipes] [⚙️ More]    │
└─────────────────────────────────────────────────────────────┘
```

**Tab Specifications:**

| Tab        | Icon                   | Label   | Badge                   | Purpose                    |
| ---------- | ---------------------- | ------- | ----------------------- | -------------------------- |
| 1. Home    | home_outlined          | Home    | Expiring count (red)    | Dashboard & quick actions  |
| 2. Lists   | shopping_cart_outlined | Lists   | Active lists count      | Shopping list management   |
| 3. Meals   | restaurant_menu        | Meals   | Incomplete slots        | Weekly meal planning       |
| 4. Recipes | menu_book              | Recipes | -                       | Recipe library & discovery |
| 5. More    | more_horiz             | More    | Sync pending (blue dot) | Pantry, settings, profile  |

**Navigation Behavior:**

- Tapping active tab scrolls to top
- State preservation on tab switch
- Smooth crossfade animation (200ms)
- Haptic feedback on tab change

---

### Alternative: 4-Tab with Hamburger Menu

**For Simpler MVP:**

```
┌─────────────────────────────────────────────────────────────┐
│ [☰] Shopping App                              [🔍] [••• ]   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│                        Content Area                           │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│ [🛒 Lists] [🍽️ Meals] [📖 Recipes] [🥫 Pantry]            │
└─────────────────────────────────────────────────────────────┘
```

**Hamburger Menu Contents:**

- Home Dashboard
- Settings
- Profile
- Help & Feedback
- About

---

### Floating Action Button (FAB)

**Context-Sensitive FAB:**

| Active Tab | FAB Action              | Icon              |
| ---------- | ----------------------- | ----------------- |
| Lists      | Add Item to Active List | add_shopping_cart |
| Meals      | Quick Add Meal          | add_circle        |
| Recipes    | Add New Recipe          | add               |
| Pantry     | Add Pantry Item         | inventory_2       |

**FAB Behavior:**

- Primary color background
- White icon
- Elevation: 6dp
- Press ripple effect
- Shows tooltip on long-press

---

## User Flows

### Flow 1: First-Time User (Happy Path)

```
App Launch (First Time)
    ↓
Welcome Screen (Swipeable)
    → Screen 1: "Plan meals, shop smart"
    → Screen 2: "Works offline, always"
    → Screen 3: "Your data, your control"
    ↓
Permission Requests (Optional)
    → Notifications: "Get expiration alerts?"
    → Camera: "For product photos?"
    ↓
Core Value Demo
    → Show sample shopping list
    → "This works right now, no sign-up"
    ↓
Home Dashboard
    → Quick Action Cards
    → "Create Your First Shopping List"
    ↓
Shopping List Created
    ↓
Success Celebration (Micro-animation)
    ↓
Optional: "Want to plan meals too?"
    → Yes: Go to Meal Planner
    → Skip: Return to Lists
```

**Design Notes:**

- 3 onboarding screens maximum
- Skip button visible on all screens
- "Get Started" on final screen
- No account creation required
- Emphasize offline capability

---

### Flow 2: Weekly Meal Planning

```
Tap "Meals" Tab
    ↓
Weekly Calendar View
    → Current week shown (Monday-Sunday)
    → Empty slots with "+ Add Meal" prompts
    ↓
User Taps Empty Meal Slot
    ↓
Recipe Selection Sheet (Bottom Sheet)
    ├─ Quick Picks: Recently Used (3-5 recipes)
    ├─ Favorites (5-10 recipes)
    ├─ "What Can I Make?" (based on pantry)
    └─ Browse All Recipes →
    ↓
Select Recipe
    ↓
Recipe Assigned to Slot
    → Visual confirmation (recipe image appears)
    → Subtle haptic feedback
    ↓
Repeat for Other Meals
    ↓
Week Completed (5+ meals)
    ↓
Action Button Appears:
"Generate Shopping List" (Prominent)
    ↓
Tap Generate
    ↓
Processing Sheet
    → "Checking your pantry..."
    → "Consolidating ingredients..."
    → "Creating your list..."
    ↓
Shopping List Created
    ↓
Review Screen
    → Show all items organized by category
    → Highlight items already in pantry (grayed)
    → Allow edits before finalizing
    ↓
User Confirms
    ↓
Shopping List Ready
    → Navigate to Lists tab
    → New list marked as "From This Week's Meals"
```

**Design Notes:**

- Empty state shows example meals
- Drag-drop to reschedule meals
- "Copy last week" quick action
- Visual meal prep timeline

---

### Flow 3: Grocery Shopping (In-Store)

```
User Enters Store (Low/No Connectivity)
    ↓
Open App → Lists Tab
    ↓
Active Shopping List Loads (Offline)
    → No loading indicators
    → Instant display
    ↓
User Navigates Store
    ↓
Per Item:
    ├─ Tap Checkbox to Mark Purchased
    │   → Instant visual update (strikethrough)
    │   → Item moves to "Purchased" section
    │   → Subtle haptic feedback
    │   → Local DB write (queued for sync)
    │
    ├─ Swipe Right for Quick Purchase
    │   → Faster than tapping checkbox
    │
    └─ Long-Press for Options
        ├─ Edit Quantity
        ├─ Add Note
        ├─ Remove from List
        └─ View Recipe Source
    ↓
All Items Purchased
    ↓
Automatic Prompt:
"Add purchased items to pantry?"
    ├─ Yes: Bulk add to pantry with expiration prompts
    └─ No: Just mark list complete
    ↓
List Marked Complete
    → Remains accessible in "Past Lists"
    → Archived after 30 days
    ↓
User Leaves Store (Connectivity Restored)
    ↓
Background Sync Activates
    → Sync indicator in status bar
    → Syncs to cloud (if enabled)
    → No user interruption
```

**Design Notes:**

- Offline badge in header (if no connection)
- Progress bar: "12 of 24 items"
- Category grouping with smart ordering
- Undo action for accidental checks

---

### Flow 4: Recipe Discovery & Import

```
User Finds Recipe Online (Safari/Chrome)
    ↓
Tap Share Button
    ├─ Select "Shopping List App"
    │   ↓
    │   Share Extension Opens
    │       → Shows URL parsing
    │       → "Importing recipe..."
    │       ↓
    │   Recipe Preview
    │       → Title, image, ingredients
    │       → "Add to Recipes"
    │       ↓
    │   Success: "Recipe saved!"
    │
    └─ Copy URL Manually
        ↓
        Open App → Recipes Tab
        ↓
        Tap FAB (+ Add Recipe)
        ↓
        Options Sheet:
        ├─ Paste URL (Auto-detects clipboard)
        ├─ Manual Entry
        └─ Take Photo of Recipe Card (future)
        ↓
        Select "Paste URL"
        ↓
        Parsing Process (3-5 seconds)
        ↓
        Preview Screen
        ├─ Title ✓
        ├─ Ingredients ✓ (allows edits)
        ├─ Instructions ✓ (allows edits)
        ├─ Image ✓
        └─ Automatically categorized
        ↓
        User Reviews & Edits
        ↓
        Tap "Save Recipe"
        ↓
        Recipe Added to Library
        ↓
        Quick Action Prompt:
        "Add to this week's meal plan?"
```

**Design Notes:**

- Share extension for iOS/Android
- Clipboard detection with permission
- Failed import → manual entry form
- Save draft during editing

---

### Flow 5: "What Can I Make?" Flow

```
User Wonders "What's for Dinner?"
    ↓
Opens App → Recipes Tab
    ↓
Taps "What Can I Make?" Card
    (OR: Floating filter chip)
    ↓
Algorithm Runs (< 500ms)
    → Matches recipes against pantry
    → Calculates match percentages
    ↓
Results View
┌────────────────────────────────────┐
│ 🟢 Can Make Now (100%)             │
│   → 5 recipes with all ingredients │
│                                    │
│ 🟡 Almost There (80-99%)           │
│   → 8 recipes missing 1-2 items   │
│                                    │
│ 🟠 Need a Few Things (60-79%)     │
│   → 12 recipes missing 3-5 items  │
└────────────────────────────────────┘
    ↓
User Taps Recipe
    ↓
Recipe Detail (Enhanced View)
    → Ingredients List
       ├─ ✓ In Pantry (green checkmark)
       ├─ ✗ Missing (red X with quantity)
       └─ ⚠️ Low/Expiring (yellow warning)
    ↓
Bottom Actions:
    ├─ "Cook This" → Start cooking mode
    ├─ "Add to Meal Plan" → Pick day/meal
    └─ "Add Missing to List" → One-tap shop
    ↓
User Selects Action
    ↓
Appropriate flow continues...
```

**Design Notes:**

- Color-coded match percentages
- Missing items highlighted
- Filter by difficulty/time
- Sort by match % or expiration urgency

---

### Flow 6: Collaborative Family Shopping

```
Parent A: Creates Shopping List
    ↓
Taps Share Icon (top-right)
    ↓
Share Options Sheet:
┌────────────────────────────────────┐
│ Share Shopping List                │
├────────────────────────────────────┤
│ [QR] Generate QR Code              │
│ [📧] Send Link (Email/SMS)         │
│ [📋] Copy Link                     │
└────────────────────────────────────┘
    ↓
Parent A: Selects "Generate QR Code"
    ↓
QR Code Screen
    → Large QR code displayed
    → "Scan to view shared list"
    → Link also shown (for manual copy)
    ↓
Parent B: Opens App
    ↓
Taps "Scan QR" or "Add Shared List"
    ↓
Camera View (QR Scanner)
    ↓
Scans QR Code
    ↓
Permission Prompt:
"[Parent A] wants to share a shopping list"
    → Preview: "Grocery Run - 15 items"
    → [Accept] [Decline]
    ↓
Parent B: Accepts
    ↓
List Added to Their Lists
    → Real-time sync enabled
    → Both see same list
    ↓
Both Users Can Now:
    ├─ Add items (appears for other)
    ├─ Check off items (syncs instantly)
    ├─ See who added/checked items
    └─ Chat/comment (future)
    ↓
Shopping Completed
    → Both see completion
    → Option to archive or keep active
```

**Design Notes:**

- Real-time sync with conflict resolution
- Show "typing..." indicators
- Activity log: "Parent B added milk"
- Offline changes sync on reconnect

---

## Screen Specifications

### 1. Home Dashboard

**Purpose:** Central hub for quick actions and status overview

**Layout:**

```
┌─────────────────────────────────────────────────┐
│ ☰  Shopping List App          🔍  🔔  👤       │ ← Header
├─────────────────────────────────────────────────┤
│                                                 │
│ 🎯 Quick Actions (Horizontal Scroll)           │
│ ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐           │
│ │ Add │  │Plan │  │What │  │ Add │           │
│ │Item │  │Meal │  │Can I│  │Recipe│          │
│ └─────┘  └─────┘  │Make?│  └─────┘           │
│                    └─────┘                      │
│                                                 │
│ ⚠️ Expiring Soon (3 items)                    │
│ ┌─────────────────────────────────────────┐   │
│ │ 🥛 Milk        Expires in 2 days    ✓   │   │
│ │ 🥬 Lettuce     Expires tomorrow     ✓   │   │
│ │ 🍅 Tomatoes    Expires in 3 days    ✓   │   │
│ └─────────────────────────────────────────┘   │
│ → View All Pantry Items                       │
│                                                 │
│ 🍽️ This Week's Meals                          │
│ ┌─────────────────────────────────────────┐   │
│ │ Mon  Tue  Wed  Thu  Fri  Sat  Sun       │   │
│ │ [🍝] [🍗] [🥗] [  ] [  ] [🍕] [🍔]      │   │
│ └─────────────────────────────────────────┘   │
│ → Complete Your Meal Plan                     │
│                                                 │
│ 🛒 Active Shopping Lists (2)                  │
│ ┌─────────────────────────────────────────┐   │
│ │ Grocery Run           12 of 24 items    │   │
│ │ ▓▓▓▓▓▓░░░░░░ 50%                       │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ Costco Run             2 of 8 items     │   │
│ │ ▓▓▓░░░░░░░░░ 25%                       │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Components:**

- **Header:** App name/logo, search icon, notification bell (with badge), profile avatar
- **Quick Actions:** 4-6 action cards (horizontally scrollable)
- **Expiring Soon Widget:** Expandable card showing urgent items (1-3 days)
- **Meal Plan Widget:** Horizontal week view with meal icons
- **Shopping Lists Widget:** Active lists with progress bars

**Interactions:**

- Pull-to-refresh entire dashboard
- Swipe to dismiss expiring items (marks as used)
- Tap quick action → opens relevant flow
- Tap widget → navigates to full screen

**States:**

- **Empty State:** "Let's get started!" with setup prompts
- **Loading:** Skeleton screens for each widget
- **Error:** Retry button if sync fails

---

### 2. Shopping List Detail

**Purpose:** Primary shopping interface for in-store use

**Layout (List View):**

```
┌─────────────────────────────────────────────────┐
│ ← Grocery Run                    ⋮ (List/Grid) │ ← Header
│   Updated 2 min ago              Share  More    │
├─────────────────────────────────────────────────┤
│ ╔═══════════════════════════════════════════╗   │
│ ║ Progress: 12 of 24 items (50%)           ║   │ ← Progress Bar
│ ║ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░                ║   │
│ ╚═══════════════════════════════════════════╝   │
│                                                 │
│ 🥬 Produce (3 items)                    [▼]    │ ← Category Header (Collapsible)
│ ┌─────────────────────────────────────────┐   │
│ │ ☐ 🥬 Lettuce           2 heads          │   │ ← Unchecked Item
│ │   Organic if available                  │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ ☑ 🍅 Tomatoes          1 lb             │   │ ← Checked Item (Grayed)
│ │   From meal: Pasta Night                │   │   (Strikethrough text)
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ ☐ 🥑 Avocados          3                │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ 🥛 Dairy (2 items)                      [▼]    │
│ ┌─────────────────────────────────────────┐   │
│ │ ☐ 🥛 Milk              1 gallon         │   │
│ │   Whole milk                            │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ ☐ 🧀 Cheddar Cheese    8 oz             │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ 🥩 Meat (1 item)                        [▼]    │
│ ... (collapsed by default)                     │
│                                                 │
│                                                 │
│                                   [+] Add Item  │ ← FAB
└─────────────────────────────────────────────────┘
```

**Layout (Grid View):**

```
┌─────────────────────────────────────────────────┐
│ ← Grocery Run              Toggle [Grid]  ⋮    │
├─────────────────────────────────────────────────┤
│ Progress: 12 of 24 items ▓▓▓▓▓▓▓▓░░░░░░ 50%   │
├─────────────────────────────────────────────────┤
│ 🥬 Produce                              [▼]    │
├─────────────────────────────────────────────────┤
│  ┌──────┐  ┌──────┐  ┌──────┐                 │
│  │  🥬  │  │  🍅  │  │  🥑  │                 │
│  │Letter│  │Tomat-│  │Avoca-│                 │
│  │  2x  │  │  1lb │  │  3x  │                 │
│  │  ☐   │  │  ☑   │  │  ☐   │                 │
│  └──────┘  └──────┘  └──────┘                 │
│                                                 │
│ 🥛 Dairy                                [▼]    │
├─────────────────────────────────────────────────┤
│  ┌──────┐  ┌──────┐                            │
│  │  🥛  │  │  🧀  │                            │
│  │ Milk │  │Chedd-│                            │
│  │ 1gal │  │  8oz │                            │
│  │  ☐   │  │  ☐   │                            │
│  └──────┘  └──────┘                            │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Item Interactions:**

| Gesture          | Action           | Visual Feedback               |
| ---------------- | ---------------- | ----------------------------- |
| **Tap checkbox** | Toggle purchased | Strikethrough, move to bottom |
| **Swipe right**  | Quick purchase   | Green checkmark animation     |
| **Swipe left**   | Delete item      | Red delete background         |
| **Long-press**   | Options menu     | Bottom sheet appears          |
| **Drag**         | Reorder manually | Item lifts, haptic feedback   |

**Options Menu (Long-press):**

- Edit Item
- Change Quantity
- Add Note
- Move to Category
- View Recipe Source
- Delete

**Header Actions:**

- **List/Grid Toggle:** Switch view modes
- **Share:** QR code or link
- **More Menu:**
  - Rename List
  - Duplicate List
  - Mark All Purchased
  - Clear Purchased Items
  - Delete List

**States:**

- **Empty List:** "Tap + to add your first item"
- **All Items Purchased:** Celebration animation, "Add to pantry?" prompt
- **Offline Mode:** Banner: "Offline - changes will sync later"

---

### 3. Weekly Meal Planner

**Purpose:** Visual calendar for planning weekly meals

**Layout:**

```
┌─────────────────────────────────────────────────┐
│ ← Meal Plan          Week of Mar 3-9       →   │ ← Navigation
├─────────────────────────────────────────────────┤
│                                                 │
│ Monday, Mar 3                                   │
│ ┌─────────────────────────────────────────┐   │
│ │ 🌅 Breakfast                            │   │
│ │ + Add meal                               │   │ ← Empty Slot
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ ☀️ Lunch                                 │   │
│ │ [Image] Chicken Caesar Salad            │   │ ← Assigned Meal
│ │ ⏱️ 20 min | 🔪 Easy                      │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ 🌙 Dinner                                │   │
│ │ [Image] Pasta Primavera                 │   │
│ │ ⏱️ 35 min | 🔪 Medium | 👨‍👩‍👧‍👦 4 servings   │   │
│ │ 🥬🍅🧀 (3 items in pantry)              │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ Tuesday, Mar 4                                  │
│ ┌─────────────────────────────────────────┐   │
│ │ 🌅 Breakfast   + Add meal                │   │
│ └─────────────────────────────────────────┘   │
│ ... (Similar structure for each day)           │
│                                                 │
├─────────────────────────────────────────────────┤
│ [🗓️ Generate Shopping List] (Primary Button)  │ ← Action Button
└─────────────────────────────────────────────────┘
```

**Compact Week View (Alternative):**

```
┌─────────────────────────────────────────────────┐
│ Week of March 3-9                 [Cal] [List]  │
├─────────────────────────────────────────────────┤
│ Mon  Tue  Wed  Thu  Fri  Sat  Sun             │
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│ │🍳│ │  │ │🥗│ │🍝│ │🍕│ │🍔│ │🌮│ Breakfast │
│ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘           │
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│ │🥗│ │🍲│ │  │ │🥙│ │🍜│ │  │ │🌯│ Lunch     │
│ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘           │
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│ │🍝│ │🍗│ │  │ │  │ │🍣│ │🍖│ │🍕│ Dinner    │
│ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘           │
└─────────────────────────────────────────────────┘
```

**Interactions:**

| Interaction           | Action                                               |
| --------------------- | ---------------------------------------------------- |
| **Tap empty slot**    | Opens recipe picker bottom sheet                     |
| **Tap assigned meal** | Opens recipe detail (with "Remove from plan" option) |
| **Long-press meal**   | Drag to reschedule                                   |
| **Swipe week**        | Navigate previous/next week                          |
| **Pinch out**         | Expand to daily detail view                          |
| **Pinch in**          | Collapse to week grid view                           |

**Recipe Picker Bottom Sheet:**

```
┌─────────────────────────────────────────────────┐
│ ─              Add Meal - Monday Dinner         │ ← Handle
├─────────────────────────────────────────────────┤
│ 🔍 Search recipes...                            │ ← Search Bar
├─────────────────────────────────────────────────┤
│ 🌟 Recommended for You                          │
│ [Recipe Card] [Recipe Card] [Recipe Card] →     │ ← Horizontal Scroll
│                                                 │
│ 🕐 Recently Used                                │
│ [Recipe Card] [Recipe Card] [Recipe Card] →     │
│                                                 │
│ 🥫 What Can I Make?                             │
│ [Recipe Card] [Recipe Card] [Recipe Card] →     │
│                                                 │
│ 📚 Browse All Recipes →                         │ ← Link to Full Recipe List
│                                                 │
│ ➕ Add New Recipe                               │
└─────────────────────────────────────────────────┘
```

**Generate Shopping List Flow:**

1. Tap "Generate Shopping List" button
2. Loading modal appears:
   - "Checking your pantry..."
   - "Consolidating ingredients..."
   - "Creating your list..."
3. Preview screen shows:
   - All ingredients organized by category
   - Items in pantry shown grayed with checkbox
   - Estimated cost (if price data available)
4. User can:
   - Uncheck items to exclude
   - Edit quantities
   - Add additional items
5. Confirm → Shopping list created and linked to meal plan

---

### 4. Recipe Detail

**Purpose:** Comprehensive recipe view with cooking mode

**Layout (Reading Mode):**

```
┌─────────────────────────────────────────────────┐
│ ←                                    ⋮  ⭐  📤  │ ← Actions
├─────────────────────────────────────────────────┤
│                                                 │
│           [Hero Image]                          │ ← Large Photo
│         Chicken Pad Thai                        │ ← Recipe Title
│                                                 │
├─────────────────────────────────────────────────┤
│ ⏱️ 35 min | 🔪 Medium | 👨‍👩‍👧‍👦 4 servings       │ ← Meta Info
│ 🏷️ Thai · Noodles · Weeknight                  │ ← Tags
├─────────────────────────────────────────────────┤
│ 📝 Description                                  │
│ A quick and authentic Pad Thai with perfect    │
│ balance of sweet, sour, and savory flavors...  │
│                                                 │
├─────────────────────────────────────────────────┤
│ 🥘 Ingredients                      Serves: [4▼]│ ← Portion Scaler
│ ┌─────────────────────────────────────────┐   │
│ │ ✓ 8 oz rice noodles                     │   │ ← In Pantry
│ │ ✗ 2 chicken breasts (diced)            │   │ ← Not in Pantry
│ │ ✓ 3 cloves garlic (minced)             │   │
│ │ ⚠️ 2 eggs                    Exp: 2 days │   │ ← Expiring Soon
│ │ ✗ 3 Tbsp fish sauce                     │   │
│ │ ... (12 more ingredients)                │   │
│ └─────────────────────────────────────────┘   │
│ [Add Missing to Shopping List] (14 items)      │ ← Quick Action
│                                                 │
├─────────────────────────────────────────────────┤
│ 👨‍🍳 Instructions                                │
│ ┌─────────────────────────────────────────┐   │
│ │ 1. Soak rice noodles in warm water for  │   │
│ │    20 minutes until softened. Drain.    │   │
│ │    ⏲️ 20 min                             │   │
│ │                                          │   │
│ │ 2. Heat wok over high heat. Add oil...  │   │
│ │    ⏲️ 5 min                              │   │
│ │                                          │   │
│ │ 3. Push noodles to side. Crack eggs...  │   │
│ │    ⏲️ 3 min                              │   │
│ │                                          │   │
│ │ ... (8 more steps)                       │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
├─────────────────────────────────────────────────┤
│ 📷 Photos (3)                                   │
│ [Thumbnail] [Thumbnail] [Thumbnail]             │
│                                                 │
├─────────────────────────────────────────────────┤
│ 💭 Notes                                        │
│ "Kids loved this! Used less spice next time."  │
│ - You, 2 weeks ago                              │
│ [+ Add Note]                                    │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Bottom Action Bar:**

```
┌─────────────────────────────────────────────────┐
│ [📅 Add to Meal Plan] [🍳 Start Cooking]       │
└─────────────────────────────────────────────────┘
```

**Cooking Mode (Full Screen):**

```
┌─────────────────────────────────────────────────┐
│                    [Exit Cooking Mode]     ✕    │
├─────────────────────────────────────────────────┤
│                                                 │
│                  Step 2 of 11                   │
│                  ▓▓▓░░░░░░░░░                   │ ← Progress
│                                                 │
│                                                 │
│        Heat wok over high heat.                 │
│        Add 2 Tbsp cooking oil.                  │
│        Swirl to coat the surface.               │
│                                                 │
│              [Step Photo/Video]                 │
│                                                 │
│                  ⏲️ Timer: 5:00                  │
│              [Start Timer] [Add +1min]          │
│                                                 │
│                                                 │
│        [◀ Previous]    [Next Step ▶]            │ ← Large Buttons
│                                                 │
│        🎙️ Voice: "Next" "Previous" "Timer"     │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Cooking Mode Features:**

- Large, readable text (24-28pt)
- One step at a time (minimal distraction)
- Step-specific timers
- Voice control ("Alexa, next step")
- Screen stays on (prevent sleep)
- Splatter-proof mode (larger touch targets)
- Hands-free scrolling (voice-activated)

**Header Actions:**

- **Star Icon:** Favorite/unfavorite
- **Share Icon:** Share recipe via link or export
- **More Menu:**
  - Edit Recipe
  - Duplicate Recipe
  - Transform Recipe (dietary)
  - Print Recipe
  - Delete Recipe

---

### 5. Recipe List / Library

**Purpose:** Browse, search, and discover recipes

**Layout:**

```
┌─────────────────────────────────────────────────┐
│ ☰  Recipes                       🔍  [Grid/List]│ ← Header
├─────────────────────────────────────────────────┤
│ 🔍 Search recipes, ingredients, tags...         │ ← Search Bar
├─────────────────────────────────────────────────┤
│ 🌟 What Can I Make?  |  🔥 Quick Meals (< 30m) │ ← Filter Chips
│ ❤️ Favorites  |  🥗 Healthy  |  🎂 Desserts     │  (Horizontal Scroll)
├─────────────────────────────────────────────────┤
│                                                 │
│ All Recipes (42)                      Sort: ▼   │ ← Section Header
│                                                 │
│ ┌────────────────┐  ┌────────────────┐         │ ← Grid View (2 columns)
│ │  [Image]       │  │  [Image]       │         │
│ │  Pad Thai      │  │  Tacos         │         │
│ │  ⭐ 4.5 · 35m  │  │  ⭐ 5.0 · 20m  │         │
│ │  🥘 12 ingred. │  │  🥘 8 ingred.  │         │
│ │  ❤️           │  │  ❤️ ✓         │         │
│ └────────────────┘  └────────────────┘         │
│                                                 │
│ ┌────────────────┐  ┌────────────────┐         │
│ │  [Image]       │  │  [Image]       │         │
│ │  Pasta         │  │  Salad         │         │
│ │  ⭐ 4.2 · 40m  │  │  ⭐ 4.8 · 15m  │         │
│ │  🥘 15 ingred. │  │  🥘 6 ingred.  │         │
│ │  ❤️ ✓         │  │  ❤️           │         │
│ └────────────────┘  └────────────────┘         │
│                                                 │
│ ... (More recipes)                              │
│                                                 │
│                                   [+] Add Recipe│ ← FAB
└─────────────────────────────────────────────────┘
```

**List View Alternative:**

```
│ ┌──────────────────────────────────────────┐   │
│ │ [Img] Chicken Pad Thai          ❤️ ⭐ 4.5 │   │
│ │       Thai · Noodles                      │   │
│ │       ⏱️ 35m · 🔪 Medium · 🥘 12 items    │   │
│ │       ✓ 8 in pantry · ✗ 4 missing        │   │
│ └──────────────────────────────────────────┘   │
│ ┌──────────────────────────────────────────┐   │
│ │ [Img] Fish Tacos                ❤️✓ ⭐ 5.0│   │
│ │       Mexican · Quick                     │   │
│ │       ⏱️ 20m · 🔪 Easy · 🥘 8 items       │   │
│ │       ✓ 5 in pantry · ✗ 3 missing        │   │
│ └──────────────────────────────────────────┘   │
```

**Sort Options:**

- Alphabetical (A-Z)
- Recently Added
- Most Cooked
- Highest Rated
- Shortest Time
- Can Make Now (pantry match %)

**Filter Sheet (Advanced):**

```
┌─────────────────────────────────────────────────┐
│ ─                 Filter Recipes                │
├─────────────────────────────────────────────────┤
│ Cooking Time                                    │
│ ○ Any  ○ <15m  ○ <30m  ○ <60m  ○ 60m+        │
│                                                 │
│ Difficulty                                      │
│ ☐ Easy  ☐ Medium  ☐ Hard                       │
│                                                 │
│ Dietary                                         │
│ ☐ Vegetarian  ☐ Vegan  ☐ Gluten-Free          │
│ ☐ Dairy-Free  ☐ Low-Carb                       │
│                                                 │
│ Cuisine                                         │
│ ☐ Italian  ☐ Mexican  ☐ Thai  ☐ Chinese       │
│ ☐ American  ☐ Indian  ☐ Mediterranean         │
│                                                 │
│ Meal Type                                       │
│ ☐ Breakfast  ☐ Lunch  ☐ Dinner  ☐ Snack       │
│                                                 │
│ Pantry Match                                    │
│ [─────●─────] 60% or higher                    │ ← Slider
│                                                 │
│         [Clear All]      [Apply Filters]        │
└─────────────────────────────────────────────────┘
```

**Empty States:**

- **No Recipes:** "Add your first recipe to get started!"
- **No Search Results:** "No recipes found. Try different keywords."
- **Filters Too Narrow:** "No matches. Relax some filters?"

---

### 6. Pantry Inventory

**Purpose:** Track what's in stock, expiration dates, and quantities

**Layout:**

```
┌─────────────────────────────────────────────────┐
│ ← Pantry                         🔍  Sort  ⋮   │
├─────────────────────────────────────────────────┤
│ ⚠️ Expiring Soon  |  ✓ In Stock  |  🗑️ All     │ ← Filter Tabs
├─────────────────────────────────────────────────┤
│                                                 │
│ 🥬 Produce (12 items)                   [▼]    │ ← Category (Collapsible)
│ ┌─────────────────────────────────────────┐   │
│ │ 🥬 Lettuce                              │   │
│ │ 2 heads · Expires in 3 days    🟡 ⚠️  │   │ ← Warning State
│ │ Added from: Grocery Run 3/1             │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ 🍅 Tomatoes                             │   │
│ │ 1.5 lbs · Expires tomorrow      🔴 ⚠️  │   │ ← Urgent State
│ │ Used in: Pasta Night (Mon)              │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ 🥑 Avocados                             │   │
│ │ 3 · Expires in 5 days          🟢      │   │ ← Fresh State
│ │ No planned use                          │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ 🥛 Dairy (5 items)                      [▼]    │
│ ┌─────────────────────────────────────────┐   │
│ │ 🥛 Milk (Whole)                         │   │
│ │ 1 gallon · Expires in 6 days   🟢      │   │
│ │ Used in: 3 recipes this week            │   │
│ └─────────────────────────────────────────┘   │
│ ... (more dairy items)                         │
│                                                 │
│ 🥫 Pantry Staples (18 items)           [▼]    │
│ ... (collapsed)                                │
│                                                 │
│                                [+] Add Item     │ ← FAB
└─────────────────────────────────────────────────┘
```

**Item Detail (Tap to Expand):**

```
┌─────────────────────────────────────────────────┐
│ 🍅 Tomatoes                                     │
│                                                 │
│ Quantity: 1.5 lbs                               │
│ Location: Fridge - Crisper Drawer               │
│ Purchased: Mar 1, 2026 (4 days ago)            │
│ Expires: Mar 6, 2026 (tomorrow) 🔴             │
│ Price: $3.49                                    │
│                                                 │
│ Used in upcoming meals:                         │
│ • Pasta Night (Monday)                          │
│ • Salad (Wednesday)                             │
│                                                 │
│ [Use Item] [Edit] [Mark as Depleted] [Delete]  │
└─────────────────────────────────────────────────┘
```

**Add Pantry Item Form:**

```
┌─────────────────────────────────────────────────┐
│ ─                Add Pantry Item                │
├─────────────────────────────────────────────────┤
│ 📷 [Take Photo] or 🔍 [Search Item]            │
├─────────────────────────────────────────────────┤
│                                                 │
│ Item Name *                                     │
│ ┌─────────────────────────────────────────┐   │
│ │ e.g., Chicken Breast                     │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ Quantity *          Unit                        │
│ ┌──────────┐      ┌─────────────────────┐     │
│ │ 2        │      │ lbs            ▼    │     │
│ └──────────┘      └─────────────────────┘     │
│                                                 │
│ Category                                        │
│ ┌─────────────────────────────────────────┐   │
│ │ 🥩 Meat                   ●             │   │ ← Radio Select
│ │ 🥬 Produce                              │   │
│ │ 🥛 Dairy                                │   │
│ │ 🥫 Pantry Staples                       │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ Expiration Date (Optional)                     │
│ ┌─────────────────────────────────────────┐   │
│ │ Mar 15, 2026          📅               │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ Location (Optional)                             │
│ ┌─────────────────────────────────────────┐   │
│ │ Fridge - Main Shelf      ▼             │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│             [Cancel]      [Add Item]            │
└─────────────────────────────────────────────────┘
```

**Expiring Soon Widget (On Home):**

Color-coded freshness indicators:

- 🟢 **Green:** 7+ days fresh
- 🟡 **Yellow:** 3-6 days (use soon)
- 🔴 **Red:** 1-2 days (urgent)
- ⚫ **Gray:** Expired (should discard)

---

### 7. Settings & More

**Purpose:** App configuration, preferences, and utility functions

**Layout:**

```
┌─────────────────────────────────────────────────┐
│ ← Settings                                       │
├─────────────────────────────────────────────────┤
│                                                 │
│ 👤 Profile                                      │
│ ┌─────────────────────────────────────────┐   │
│ │ [Avatar] Sarah M.                       │   │
│ │          sarah@example.com               │   │
│ │          [Edit Profile]                  │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ PREFERENCES                                     │
│ ┌─────────────────────────────────────────┐   │
│ │ 👨‍👩‍👧‍👦 Household                             │   │
│ │    Manage members and preferences       │   │
│ ├─────────────────────────────────────────┤   │
│ │ 🥗 Dietary Restrictions                  │   │
│ │    Vegetarian, Gluten-Free              │   │
│ ├─────────────────────────────────────────┤   │
│ │ 🚫 "Never Suggest" List                  │   │
│ │    12 blocked ingredients               │   │
│ ├─────────────────────────────────────────┤   │
│ │ 🔔 Notifications                         │   │
│ │    Expiration alerts, meal reminders    │   │
│ ├─────────────────────────────────────────┤   │
│ │ 🌐 Language & Region                     │   │
│ │    English (US)                          │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ DATA & PRIVACY                                  │
│ ┌─────────────────────────────────────────┐   │
│ │ ☁️ Cloud Sync             [Toggle: ON] │   │
│ │    Last synced: 2 min ago               │   │
│ ├─────────────────────────────────────────┤   │
│ │ 🔒 Privacy Settings                      │   │
│ │    Control what data is synced          │   │
│ ├─────────────────────────────────────────┤   │
│ │ 📥 Export Data                           │   │
│ │    Download all your data (JSON)        │   │
│ ├─────────────────────────────────────────┤   │
│ │ 🗑️ Delete Account                        │   │
│ │    Permanently delete all data          │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ APP                                             │
│ ┌─────────────────────────────────────────┐   │
│ │ 🎨 Theme                                 │   │
│ │    ○ Light  ● Auto  ○ Dark              │   │
│ ├─────────────────────────────────────────┤   │
│ │ 📦 Storage                               │   │
│ │    Used: 45 MB of 500 MB                │   │
│ │    [Clear Cache]                         │   │
│ ├─────────────────────────────────────────┤   │
│ │ ℹ️ About                                  │   │
│ │    Version 1.0.0 (Build 42)             │   │
│ ├─────────────────────────────────────────┤   │
│ │ 💬 Help & Feedback                       │   │
│ │    Get support or send feedback         │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Household Management:**

```
┌─────────────────────────────────────────────────┐
│ ← Household                                      │
├─────────────────────────────────────────────────┤
│ Family Members (4)                    [+ Add]   │
│ ┌─────────────────────────────────────────┐   │
│ │ 👩 Sarah (You) - Admin                  │   │
│ │    Vegetarian · Advanced Cook           │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ 👨 John - Member                         │   │
│ │    No restrictions · Intermediate       │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ 👧 Emma (Age 9) - Child                  │   │
│ │    Picky eater · Kid-friendly only      │   │
│ └─────────────────────────────────────────┘   │
│ ┌─────────────────────────────────────────┐   │
│ │ 👦 Max (Age 6) - Child                   │   │
│ │    Dairy-free · Kid-friendly only       │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ Household Preferences                           │
│ ┌─────────────────────────────────────────┐   │
│ │ Default Serving Size: 4                  │   │
│ │ Weekly Meal Goal: 5 dinners              │   │
│ │ Shopping Day: Saturday                   │   │
│ │ Meal Voting: Enabled                     │   │
│ └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## Design System

### Color Palette

**Primary Colors:**

```
Primary (Brand):      #2E7D32  (Green - Fresh, Growth, Food)
Primary Light:        #60AD5E
Primary Dark:         #005005
Primary Container:    #B2DFAF

Secondary (Accent):   #FF6F00  (Orange - Energy, Appetite)
Secondary Light:      #FFA040
Secondary Dark:       #C43E00
Secondary Container:  #FFE0B2

Tertiary:            #5E35B1  (Purple - Premium, Creativity)
Tertiary Light:      #9162E4
Tertiary Dark:       #280680
```

**Semantic Colors:**

```
Success:    #4CAF50  (Actions completed, fresh items)
Warning:    #FF9800  (Expiring soon, attention needed)
Error:      #F44336  (Expired, urgent, deletions)
Info:       #2196F3  (Tips, information, sync status)

Surface:    #FFFFFF  (Cards, sheets, elevated surfaces)
Background: #FAFAFA  (Screen background)
Outline:    #79747E  (Borders, dividers)
```

**Text Colors:**

```
On Primary:         #FFFFFF  (Text on primary color)
On Secondary:       #FFFFFF  (Text on secondary color)
On Background:      #1C1B1F  (Primary text)
On Surface:         #1C1B1F  (Card text)
On Surface Variant: #49454F  (Secondary text)
Outline:            #79747E  (Disabled text)
```

**Expiration Color Scale:**

```
Fresh (7+ days):      #4CAF50  🟢
Good (4-6 days):      #8BC34A  🟢
Warning (3 days):     #FFC107  🟡
Urgent (1-2 days):    #FF9800  🟠
Critical (today):     #F44336  🔴
Expired:              #9E9E9E  ⚫
```

---

### Typography

**Type Scale:**

| Style               | Font            | Size | Weight  | Line Height | Use Case            |
| ------------------- | --------------- | ---- | ------- | ----------- | ------------------- |
| **Display Large**   | SF Pro / Roboto | 57px | Regular | 64px        | Marketing, splashes |
| **Display Medium**  | SF Pro / Roboto | 45px | Regular | 52px        | Hero sections       |
| **Display Small**   | SF Pro / Roboto | 36px | Regular | 44px        | Section headers     |
| **Headline Large**  | SF Pro / Roboto | 32px | Regular | 40px        | Screen titles       |
| **Headline Medium** | SF Pro / Roboto | 28px | Regular | 36px        | Card titles         |
| **Headline Small**  | SF Pro / Roboto | 24px | Regular | 32px        | List headers        |
| **Title Large**     | SF Pro / Roboto | 22px | Medium  | 28px        | Prominent items     |
| **Title Medium**    | SF Pro / Roboto | 16px | Medium  | 24px        | List items, buttons |
| **Title Small**     | SF Pro / Roboto | 14px | Medium  | 20px        | Dense lists         |
| **Body Large**      | SF Pro / Roboto | 16px | Regular | 24px        | Primary body text   |
| **Body Medium**     | SF Pro / Roboto | 14px | Regular | 20px        | Secondary text      |
| **Body Small**      | SF Pro / Roboto | 12px | Regular | 16px        | Captions, helper    |
| **Label Large**     | SF Pro / Roboto | 14px | Medium  | 20px        | Buttons, chips      |
| **Label Medium**    | SF Pro / Roboto | 12px | Medium  | 16px        | Tab labels          |
| **Label Small**     | SF Pro / Roboto | 11px | Medium  | 16px        | Tiny labels         |

**Font Families:**

- **iOS:** SF Pro Text/Display (System default)
- **Android:** Roboto (System default)
- **Fallback:** System UI font

---

### Spacing System

**8px Grid:**

```
4px   (0.5x)  - Tight spacing, icon padding
8px   (1x)    - Default spacing unit
12px  (1.5x)  - Compact spacing
16px  (2x)    - Standard spacing (most common)
24px  (3x)    - Comfortable spacing
32px  (4x)    - Section spacing
48px  (6x)    - Large section gaps
64px  (8x)    - Screen margins (rare)
```

**Component Padding:**

- **Cards:** 16px all sides
- **List Items:** 16px horizontal, 12px vertical
- **Buttons:** 16px horizontal, 12px vertical
- **Sheets:** 24px horizontal, 16px vertical

**Screen Margins:**

- **Horizontal:** 16px (default), 24px (tablets)
- **Vertical:** 16px top, 8px between sections

---

### Elevation & Shadows

**Material Design Elevation:**

| Level | Elevation | Use Case                        |
| ----- | --------- | ------------------------------- |
| 0     | None      | Screen background               |
| 1     | 1dp       | Cards, filled buttons           |
| 2     | 3dp       | Raised cards, app bar (resting) |
| 3     | 6dp       | FAB (resting), snackbar         |
| 4     | 8dp       | Bottom nav, app bar (scrolled)  |
| 5     | 12dp      | Modal sheets, dialogs           |
| 6     | 16dp      | FAB (pressed)                   |

**Shadow Values (CSS/Flutter):**

```dart
elevation: 1, // boxShadow: [0px 1px 2px rgba(0,0,0,0.3)]
elevation: 2, // boxShadow: [0px 1px 5px rgba(0,0,0,0.2)]
elevation: 3, // boxShadow: [0px 1px 8px rgba(0,0,0,0.12)]
elevation: 4, // boxShadow: [0px 2px 4px rgba(0,0,0,0.14)]
elevation: 6, // boxShadow: [0px 3px 5px rgba(0,0,0,0.12)]
```

---

### Component Library

#### 1. Buttons

**Primary Button:**

```
┌─────────────────────┐
│ Generate List       │  ← Filled button, primary color
└─────────────────────┘
Height: 48px
Padding: 16px horizontal
Border Radius: 24px (fully rounded)
Text: Label Large, all caps or sentence case
```

**Secondary Button:**

```
┌─────────────────────┐
│ Cancel              │  ← Outlined button, primary outline
└─────────────────────┘
Height: 48px
Border: 1px solid primary
Background: Transparent
Text: Primary color
```

**Text Button:**

```
  Skip  ← No background, primary color text
```

**States:**

- Default: Normal colors
- Hover: +8% opacity overlay
- Pressed: +12% opacity overlay, haptic feedback
- Disabled: 38% opacity, no interaction

---

#### 2. Input Fields

**Text Input:**

```
┌─────────────────────────────────────┐
│ Item Name                            │  ← Label (floating)
│ ┌─────────────────────────────────┐ │
│ │ Chicken Breast                   │ │  ← Input area
│ └─────────────────────────────────┘ │
│ e.g., Organic, boneless             │  ← Helper text
└─────────────────────────────────────┘
```

**Styling:**

- Height: 56px
- Border: 1px solid outline color
- Border Radius: 4px (top)
- Padding: 16px horizontal
- Focus: 2px primary color border

**States:**

- Empty: Label at top, placeholder visible
- Filled: Label floats above, content shows
- Error: Red border, error text below
- Disabled: Gray background, no interaction

---

#### 3. Cards

**Recipe Card (Grid):**

```
┌──────────────────┐
│                  │
│   [Image 16:9]   │  ← Recipe photo
│                  │
├──────────────────┤
│ Recipe Title     │  ← Title (1-2 lines, ellipsis)
│ ⭐ 4.5 · 35 min  │  ← Metadata
│ 🥘 12 ingredients│
│            ❤️   │  ← Favorite icon (top-right)
└──────────────────┘
Width: (Screen - 48px) / 2
Aspect Ratio: 3:4
Border Radius: 12px
Elevation: 1dp
```

**Meal Plan Card (Horizontal):**

```
┌─────────────────────────────────────┐
│ [80x80 Img] Monday Dinner           │  ← Small image + title
│              Chicken Pad Thai       │  ← Recipe name
│              ⏱️ 35m · 🔪 Medium      │  ← Quick stats
└─────────────────────────────────────┘
Height: 96px
Border Radius: 8px
Padding: 12px
```

---

#### 4. Lists & List Items

**Standard List Item:**

```
┌─────────────────────────────────────┐
│ [Icon] Title Text                   │  ← Primary text
│        Subtitle or detail text      │  ← Secondary text
│                              [►]    │  ← Trailing icon
└─────────────────────────────────────┘
Height: 56px (single-line) or 72px (two-line)
Padding: 16px horizontal
Divider: 1px line (optional)
```

**Shopping List Item:**

```
┌─────────────────────────────────────┐
│ ☐ 🥬 Lettuce           2 heads      │  ← Checkbox, icon, name, qty
│      Organic if available           │  ← Note (if present)
└─────────────────────────────────────┘
```

**Swipe Actions:**

- Swipe Right (30%+): Quick action (mark done, favorite)
- Swipe Left (30%+): Destructive action (delete)
- Background shows icon + color during swipe

---

#### 5. Navigation

**Bottom Navigation Bar:**

```
┌─────────────────────────────────────┐
│ [🏠]   [🛒]   [🍽️]   [📖]   [⚙️]  │
│ Home   Lists  Meals  Recipes  More  │
└─────────────────────────────────────┘
Height: 56px (Android), 49px (iOS with safe area)
Selected: Primary color, filled icon
Unselected: On-surface color, outline icon
Badge: Small red dot or number
```

**Top App Bar:**

```
┌─────────────────────────────────────┐
│ [☰] Screen Title       [🔍] [⋮]    │  ← Nav, title, actions
└─────────────────────────────────────┘
Height: 56dp (Android), 44px (iOS)
Elevation: 0dp (flat) or 4dp (scrolled)
Background: Surface color
```

---

#### 6. Chips & Tags

**Filter Chip:**

```
┌──────────────┐
│ 🌟 Favorites │  ← Icon + label
└──────────────┘
Height: 32px
Padding: 12px horizontal
Border Radius: 16px
States: Unselected (outline), Selected (filled)
```

**Tag Chip (Small):**

```
┌────────┐
│ Thai   │  ← Small label
└────────┘
Height: 24px
Padding: 8px horizontal
Border Radius: 12px
Background: Primary container
```

---

#### 7. Dialogs & Sheets

**Bottom Sheet:**

```
┌─────────────────────────────────────┐
│ ──                                  │  ← Drag handle
│                                     │
│ Sheet Title                         │  ← Title
│                                     │
│ Content area with scrollable        │  ← Content
│ content if needed...                │
│                                     │
│ [Cancel]            [Confirm]       │  ← Actions
└─────────────────────────────────────┘
Min Height: 200px
Max Height: 90% of screen
Border Radius: 28px (top corners)
Padding: 24px horizontal, 16px vertical
Backdrop: 40% black scrim
```

**Alert Dialog:**

```
┌───────────────────────────────┐
│ Delete Recipe?                │  ← Title
│                               │
│ This action cannot be undone. │  ← Message
│                               │
│     [Cancel]    [Delete]      │  ← Actions
└───────────────────────────────┘
Max Width: 320px (mobile)
Border Radius: 28px
Elevation: 24dp
```

---

#### 8. Progress Indicators

**Linear Progress:**

```
▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░ 50%
Height: 4px
Width: 100%
Colors: Primary (filled), outline (track)
```

**Circular Progress:**

```
    ●●●○
   ●    ○
  ●      ○
  ●      ○
   ●    ○
    ○○○
Size: 24px (small), 48px (large)
Stroke: 4px
Indeterminate: Animated spinning
```

---

## Interaction Patterns

### Gestures

| Gesture                | Use Case                           | Feedback                         |
| ---------------------- | ---------------------------------- | -------------------------------- |
| **Tap**                | Select, activate, toggle           | Ripple effect, state change      |
| **Long-press**         | Context menu, drag prep            | Vibration, menu appears          |
| **Swipe right**        | Quick action (mark done, favorite) | Color background, icon reveal    |
| **Swipe left**         | Destructive action (delete)        | Red background, trash icon       |
| **Drag**               | Reorder items, reschedule meals    | Item lifts, follows finger       |
| **Pinch**              | Zoom images, collapse/expand week  | Smooth scaling animation         |
| **Pull-down**          | Refresh content                    | Spinner appears, content updates |
| **Swipe between tabs** | Navigate horizontal screens        | Crossfade animation              |

---

### Animations

**Timing:**

- **Instant:** 0ms - Immediate feedback
- **Fast:** 100-200ms - UI state changes
- **Standard:** 300ms - Most animations (default)
- **Slow:** 500ms - Emphasis animations
- **Very Slow:** 1000ms+ - Celebrations, onboarding

**Easing Curves:**

- **Linear:** Constant speed (rare use)
- **Ease-out:** Fast start, slow end (entering screens)
- **Ease-in:** Slow start, fast end (exiting screens)
- **Ease-in-out:** Slow-fast-slow (moving items)
- **Spring:** Bouncy, playful (success states)

**Common Animations:**

1. **Screen Transitions:**
   - Forward: Slide from right (iOS) or fade up (Android)
   - Back: Slide to right or fade down
   - Duration: 300ms

2. **List Item Changes:**
   - Add: Fade in + slide down (200ms)
   - Remove: Fade out + slide up (200ms)
   - Reorder: Smooth position change (300ms)

3. **Bottom Sheets:**
   - Open: Slide up (300ms, ease-out)
   - Close: Slide down (250ms, ease-in)
   - Backdrop: Fade in/out (200ms)

4. **Loading States:**
   - Skeleton: Shimmer animation (1500ms loop)
   - Spinner: Rotation (1000ms loop)
   - Progress bar: Smooth fill (100ms per % change)

5. **Success Feedback:**
   - Checkmark: Scale + fade in (300ms, spring)
   - Confetti: Particle burst (1000ms)
   - Celebration: Lottie animation (2000ms)

---

### Haptic Feedback

**iOS & Android Haptics:**

| Event         | Haptic Type  | Use Case                            |
| ------------- | ------------ | ----------------------------------- |
| Light Impact  | Light tap    | Toggling switches, selecting chips  |
| Medium Impact | Medium tap   | Checking off items, tapping buttons |
| Heavy Impact  | Heavy thud   | Completing tasks, deleting items    |
| Success       | Gentle pulse | Saved successfully, sync complete   |
| Warning       | Sharp buzz   | Approaching limit, expiring soon    |
| Error         | Double buzz  | Action failed, validation error     |
| Selection     | Subtle tick  | Scrolling through pickers, sliders  |

---

### State Management

**Loading States:**

1. **Initial Load (First Launch):**
   - Splash screen (1-2 seconds max)
   - Skeleton screens for content
   - Progressive content reveal

2. **Background Refresh:**
   - Silent sync (no UI interruption)
   - Subtle status indicator
   - Toast notification on completion (optional)

3. **User-Triggered Load:**
   - Button shows spinner
   - Disabled during load
   - Success/error feedback

**Empty States:**

```
┌─────────────────────────────────────┐
│                                     │
│         [Large Icon/Illustration]   │  ← Visual
│                                     │
│      No recipes yet!                │  ← Headline
│                                     │
│   Add your first recipe to start    │  ← Description
│   planning delicious meals.         │
│                                     │
│      [Add Your First Recipe]        │  ← CTA Button
│                                     │
└─────────────────────────────────────┘
```

**Error States:**

```
┌─────────────────────────────────────┐
│         [Error Icon]                │
│                                     │
│     Couldn't load recipes           │  ← Headline
│                                     │
│   Check your connection and try     │  ← Explanation
│   again.                            │
│                                     │
│         [Try Again]                 │  ← Retry Button
│                                     │
└─────────────────────────────────────┘
```

---

## Responsive Design

### Breakpoints

| Device                 | Width Range | Layout Adjustments                  |
| ---------------------- | ----------- | ----------------------------------- |
| **Small Phone**        | < 360px     | Single column, compact spacing      |
| **Phone**              | 360-599px   | Default design (primary target)     |
| **Large Phone**        | 600-719px   | Slightly larger cards, more padding |
| **Tablet (Portrait)**  | 720-839px   | 2 columns for recipes/cards         |
| **Tablet (Landscape)** | 840-1439px  | Side-by-side layouts, split views   |
| **Desktop**            | 1440px+     | Max width 1200px, centered content  |

---

### Adaptive Layouts

**Phone (Primary):**

- Single column layouts
- Bottom navigation
- Full-width cards
- Modal sheets from bottom

**Tablet:**

- Two-column grids
- Side navigation drawer (landscape)
- Split-view (list + detail)
- Sheets from center or side

**Landscape Mode:**

- Horizontal recipe steps
- Side-by-side meal planner
- Wider sheet modals

---

## Accessibility

### WCAG 2.1 Level AA Compliance

**Color Contrast:**

- Normal text (< 18pt): Minimum 4.5:1
- Large text (≥ 18pt): Minimum 3:1
- UI components: Minimum 3:1
- Don't rely on color alone (use icons + text)

**Touch Targets:**

- Minimum: 44x44px (iOS), 48x48dp (Android)
- Spacing: 8px between targets
- Expandable hit areas for small visuals

**Text Sizing:**

- Support Dynamic Type (iOS) / Font Scale (Android)
- Test at 200% zoom
- Avoid fixed pixel sizing
- Reflow content, no horizontal scrolling

**Screen Reader Support:**

**iOS (VoiceOver):**

```dart
Semantics(
  label: 'Chicken Pad Thai recipe',
  hint: 'Double tap to view details',
  value: 'Rated 4.5 stars, takes 35 minutes',
  child: RecipeCard(...)
)
```

**Android (TalkBack):**

```dart
Semantics(
  label: 'Add to shopping list',
  button: true,
  onTapHint: 'Adds missing ingredients to shopping list',
  child: ElevatedButton(...)
)
```

**Semantic Labels:**

- Descriptive labels for all interactive elements
- Announce state changes ("Added to favorites")
- Group related content logically
- Skip repetitive content (navigation shortcuts)

**Keyboard Navigation:**

- Tab order follows visual flow
- Focus indicators clearly visible
- Escape key dismisses sheets/dialogs
- Enter/Space activates buttons

---

### Inclusive Design Considerations

**Motor Impairments:**

- Large touch targets (48px minimum)
- Avoid time-based interactions
- Provide alternatives to gestures
- Sticky FAB (doesn't disappear on scroll)

**Visual Impairments:**

- High contrast mode support
- Text scalability (up to 200%)
- Clear focus indicators
- Sans-serif fonts for readability

**Cognitive Accessibility:**

- Simple, predictable navigation
- Clear error messages with solutions
- Undo options for destructive actions
- Progress indicators for multi-step flows

**Localization Ready:**

- RTL language support (Arabic, Hebrew)
- Date/time format localization
- Number format localization
- Expandable text areas (translations vary 30-50%)

---

## Onboarding

### First Launch Experience

**Goal:** Get users to their first valuable action in < 60 seconds

**Flow:**

**Screen 1: Welcome**

```
┌─────────────────────────────────────┐
│                                     │
│     [App Icon / Illustration]       │
│                                     │
│  Welcome to [App Name]!             │
│                                     │
│  Plan meals, shop smart, and        │
│  reduce food waste—all offline.     │
│                                     │
│              ● ○ ○                  │  ← Pagination dots
│                                     │
│ [Skip]                    [Next →]  │
└─────────────────────────────────────┘
```

**Screen 2: Offline-First**

```
┌─────────────────────────────────────┐
│                                     │
│   [Offline/Airplane Illustration]   │
│                                     │
│  Works Anywhere                     │
│                                     │
│  No internet? No problem. Full      │
│  functionality even when offline.   │
│                                     │
│              ○ ● ○                  │
│                                     │
│ [Skip]                    [Next →]  │
└─────────────────────────────────────┘
```

**Screen 3: Privacy**

```
┌─────────────────────────────────────┐
│                                     │
│      [Privacy/Lock Illustration]    │
│                                     │
│  Your Data, Your Control            │
│                                     │
│  No sign-up required. Your data     │
│  stays on your device.              │
│                                     │
│              ○ ○ ●                  │
│                                     │
│ [Skip]              [Get Started →] │
└─────────────────────────────────────┘
```

**Optional Permissions:**

- Notifications: "Get alerts for expiring food?"
- Camera: "Take photos of recipes and products?"
- Can skip all, request at point of use

**First Action Prompt:**

```
┌─────────────────────────────────────┐
│  What would you like to do first?   │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🛒 Create a Shopping List     │ │  ← Quick start options
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ 🍽️ Plan This Week's Meals     │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ 📖 Browse Sample Recipes      │ │
│  └───────────────────────────────┘ │
│                                     │
│         [Explore on My Own]         │  ← Skip option
└─────────────────────────────────────┘
```

---

### Progressive Disclosure

**Tooltips (First Use):**

```
┌─────────────────────────────────────┐
│ [FAB Button]                         │
│      ↑                               │
│    ┌─────────────────────────────┐  │
│    │ Tap here to add your first  │  │  ← Tooltip (dismissible)
│    │ item to the shopping list   │  │
│    └─────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Feature Discovery:**

- Tooltips on first encounter
- "What's New" on app updates
- Help icon in context (? button)
- Optional interactive tutorials

---

## Edge Cases & Error States

### Offline Mode

**Indicators:**

```
┌─────────────────────────────────────┐
│ ⚠️ Offline - Changes will sync later │ ← Banner (dismissible)
└─────────────────────────────────────┘
```

**Behavior:**

- All core features work normally
- Sync queue icon shows pending changes
- Cloud-dependent features gracefully degrade
- Clear messaging about what won't work

---

### Sync Conflicts

**Conflict Resolution UI:**

```
┌─────────────────────────────────────┐
│ Sync Conflict Detected              │
│                                     │
│ Shopping list "Grocery Run" was     │
│ changed on another device.          │
│                                     │
│ Your version:            Their:     │
│ • Milk (1 gal)          • Milk (2)  │
│ • Eggs (12)             • Eggs (12) │
│                         • Bread     │
│                                     │
│ [Keep Mine] [Use Theirs] [Merge]   │
└─────────────────────────────────────┘
```

---

### Failed Operations

**Retry Pattern:**

```
┌─────────────────────────────────────┐
│ ⚠️ Couldn't sync changes             │
│                                     │
│ Your changes are safe. We'll retry  │
│ automatically when connection       │
│ improves.                           │
│                                     │
│            [Try Now]                │
└─────────────────────────────────────┘
```

---

### Validation Errors

**Inline Errors:**

```
┌─────────────────────────────────────┐
│ Recipe Name *                        │
│ ┌─────────────────────────────────┐ │
│ │                                  │ │  ← Empty field
│ └─────────────────────────────────┘ │
│ ⚠️ Recipe name is required           │  ← Error text (red)
└─────────────────────────────────────┘
```

---

### Storage Full

**Graceful Degradation:**

```
┌─────────────────────────────────────┐
│ Storage Almost Full                 │
│                                     │
│ 480 MB of 500 MB used.              │
│                                     │
│ Consider clearing cached images     │
│ or removing old recipes.            │
│                                     │
│ [Clear Cache] [Manage Storage]     │
└─────────────────────────────────────┘
```

---

### No Search Results

**Helpful Empty State:**

```
┌─────────────────────────────────────┐
│         [Magnifying Glass Icon]     │
│                                     │
│     No recipes found                │
│                                     │
│  Try different keywords or relax    │
│  your filters.                      │
│                                     │
│      [Clear Filters]                │
│      [Browse All Recipes]           │
└─────────────────────────────────────┘
```

---

## Next Steps

### Design Deliverables

1. **High-Fidelity Mockups** (Figma/Sketch)
   - All primary screens (10-15 screens)
   - Key user flows
   - Component library
   - Interactive prototype

2. **Design System Documentation**
   - Color palette (hex values)
   - Typography specs
   - Component specifications
   - Spacing guidelines

3. **Asset Preparation**
   - App icons (all sizes)
   - Launch screens
   - Illustration set
   - Empty state graphics

4. **User Testing**
   - Prototype testing (5-8 users)
   - Usability testing session guide
   - Findings report
   - Iteration recommendations

5. **Developer Handoff**
   - Annotated designs
   - Asset export (SVG, PNG @1x, @2x, @3x)
   - Design tokens (JSON)
   - Implementation notes

---

## Appendix

### Design Tools Recommended

- **UI Design:** Figma (preferred), Sketch, Adobe XD
- **Prototyping:** Figma, ProtoPie, Principle
- **Animation:** Lottie (After Effects), Rive
- **Icons:** Material Icons, SF Symbols, custom
- **Illustrations:** UnDraw, Humaaans, custom
- **Collaboration:** Figma comments, Zeplin, Abstract

### Design Resources

- [Material Design 3](https://m3.material.io/)
- [Human Interface Guidelines (iOS)](https://developer.apple.com/design/human-interface-guidelines/)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Accessibility Guidelines (WCAG)](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Document End**

---

## Change Log

| Version | Date       | Changes                         | Author      |
| ------- | ---------- | ------------------------------- | ----------- |
| 1.0     | 2026-02-25 | Initial UX design specification | Design Team |

---

**Approval Required:**

- [ ] Product Manager
- [ ] UX Lead
- [ ] Tech Lead
- [ ] Stakeholders
