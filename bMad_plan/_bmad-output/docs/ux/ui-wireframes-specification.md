# UI Wireframes & Component Specifications

## Flutter Shopping List & Meal Planning App

**Document Version:** 2.0  
**Date:** March 3, 2026  
**Author:** BMad Master  
**Status:** Design Updated — Dark Theme  
**Related Documents:** [PRD](prd-shopping-list-app.md), [Architecture](architecture-shopping-list-app.md), [Revised Epics](revised-epics-database-first.md)

> **Design Direction (v2):** Dark charcoal/black backgrounds, warm orange accent (#FF6B35), full-bleed image cards with gradient title overlays, Poppins typeface. Inspired by premium cooking app aesthetics.

---

## Document Overview

This document provides detailed UI/UX specifications including:

- Navigation structure and information architecture
- Screen wireframes with component breakdowns
- Widget specifications (properties, states, behaviors)
- Interaction patterns and gestures
- Design tokens and style guide
- Accessibility considerations

### Design Philosophy

1. **Dark & Immersive** — Charcoal (#121212) canvas puts food photography centre-stage
2. **Orange as Voice** — Single warm accent (#FF6B35) drives all calls-to-action; nothing competes with it
3. **Full-Bleed First** — Recipe images fill cards edge-to-edge; gradient overlays keep text readable without obscuring the food
4. **Kitchen-Friendly** — Poppins typeface at generous sizes; 48 dp minimum touch targets, 56 dp recommended
5. **Offline-First Visibility** — Sync status always visible via a subtle chip in the app bar
6. **Progressive Disclosure** — Home/Discovery screen shows curated content; depth unlocks on tap

---

## Table of Contents

1. [Navigation Architecture](#navigation-architecture)
2. [Design System](#design-system)
3. [Core Components Library](#core-components-library)
4. [Shopping List Screens](#shopping-list-screens)
5. [Recipe Screens](#recipe-screens)
6. [Meal Planning Screens](#meal-planning-screens)
7. [Pantry Screens](#pantry-screens)
8. [Settings & Onboarding](#settings--onboarding)
9. [Interaction Patterns](#interaction-patterns)
10. [Responsive & Accessibility](#responsive--accessibility)

---

## Navigation Architecture

### Bottom Navigation Structure

**5-Tab Navigation (Material Design 3)**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│            [ACTIVE SCREEN CONTENT]              │
│                                                 │
│                                                 │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │
│  Plan   Shop  Recipes Pantry Settings          │
│   ●                                             │ ← Active indicator
└─────────────────────────────────────────────────┘
```

**Tab Definitions:**

| Icon | Label    | Route        | Primary Action             | Badge          |
| ---- | -------- | ------------ | -------------------------- | -------------- |
| 🗓️   | Plan     | `/meal-plan` | Assign recipe to meal slot | None           |
| 🛒   | Shop     | `/shopping`  | Add item to list           | Item count     |
| 📚   | Recipes  | `/recipes`   | Add new recipe             | None           |
| 🥫   | Pantry   | `/pantry`    | Add pantry item            | Expiring count |
| ⚙️   | Settings | `/settings`  | N/A                        | None           |

**Navigation State Management:**

```dart
// Navigation provider
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// Current route provider
final currentRouteProvider = Provider<String>((ref) {
  final index = ref.watch(navigationIndexProvider);
  return ['/meal-plan', '/shopping', '/recipes', '/pantry', '/settings'][index];
});
```

---

### Screen Hierarchy

```
App Root
├── Meal Plan Tab
│   ├── Weekly Calendar View (default)
│   ├── Recipe Picker Bottom Sheet
│   └── Meal Detail Modal
│
├── Shopping Tab
│   ├── Shopping Lists Page (default)
│   ├── List Detail Page
│   └── Add Item Bottom Sheet
│
├── Recipes Tab
│   ├── Recipe List Page (default)
│   ├── Recipe Detail Page
│   ├── Recipe Form Page (create/edit)
│   └── Recipe Search Page
│
├── Pantry Tab
│   ├── Inventory List (default)
│   ├── Expiring Items Dashboard
│   └── Add Item Form
│
└── Settings Tab
    ├── General Settings
    ├── Cloud Sync Setup
    ├── Dietary Preferences
    └── About/Privacy
```

---

## Design System

### Color Palette

**Primary Colors (Dark Theme — v2):**

```dart
class AppColors {
  // ── Brand / Accent ────────────────────────────────────
  static const Color primary      = Color(0xFFFF6B35); // Orange — main accent
  static const Color primaryLight = Color(0xFFFF8C5A); // Orange hover/highlight
  static const Color primaryDark  = Color(0xFFE04E1A); // Orange pressed
  static const Color secondary    = Color(0xFFFFB347); // Amber — secondary accent

  // ── Backgrounds & Surfaces ───────────────────────────
  static const Color background  = Color(0xFF121212); // Page background
  static const Color surface     = Color(0xFF1E1E1E); // Cards, elevated areas
  static const Color surfaceHigh = Color(0xFF2A2A2A); // Input fields, chips
  static const Color bottomBar   = Color(0xFF1A1A1A); // Bottom navigation bar

  // ── Semantic / Food freshness ────────────────────────
  static const Color fresh   = Color(0xFF22C55E); // Green — fresh
  static const Color useSoon = Color(0xFFF59E0B); // Amber — use within days
  static const Color urgent  = Color(0xFFEF4444); // Red   — urgent/expired
  static const Color neutral = Color(0xFF6B7280); // Gray  — no expiration

  // ── Feedback ────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Text ─────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF); // White on dark bg
  static const Color textSecondary = Color(0xFFA0A0A0); // Muted labels
  static const Color textDisabled  = Color(0xFF555555); // Disabled
  static const Color textOnImage   = Color(0xFFFFFFFF); // Text on photo overlay

  // ── Full-bleed card gradient (transparent → 80% black) ────────
  static const Color cardOverlayStart = Color(0x00000000); // transparent
  static const Color cardOverlayEnd   = Color(0xCC000000); // 80% black
}
```

**Color Usage Guidelines:**

- **Orange (`primary`):** FABs, primary buttons, active nav icon, active chips, progress bars, step numbers
- **Amber (`secondary`):** Time/serving badges, leftover pills, cooking-mode highlights
- **Dark surfaces:** All pages use `background` (#121212); cards use `surface` (#1E1E1E)
- **Full-bleed image cards:** Always apply `cardOverlay` gradient so white text stays legible
- **Red:** Expiry urgency, delete swipe actions — same semantic meaning
- **Gray (`neutral`):** Inactive nav icons, disabled inputs, purchased items (strikethrough + dimmed)

---

### Typography

**Type Scale (Material Design 3 — Poppins):**

Font: **Poppins** (Google Fonts). SemiBold (600) for display/headline, Medium (500) for titles/labels, Regular (400) for body. All text on dark surfaces uses white or muted-gray.

```dart
class AppTypography {
  static const String fontFamily = 'Poppins'; // Google Fonts

  static const TextTheme textTheme = TextTheme(
    // Display (large hero text)
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 64 / 57,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 52 / 45,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 44 / 36,
    ),

    // Headline (section headers)
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 40 / 32,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 36 / 28,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
    ),

    // Title (card titles, list items)
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 28 / 22,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 24 / 16,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 20 / 14,
    ),

    // Body (content text)
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 24 / 16,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 20 / 14,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 16 / 12,
    ),

    // Label (buttons, captions)
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 20 / 14,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 16 / 12,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 16 / 11,
    ),
  );
}
```

**Typography Usage:**

- **Headlines:** Screen titles, section headers — white, Poppins SemiBold
- **Titles:** Card/overlay titles — white on dark image, Poppins SemiBold
- **Body:** Recipe instructions, descriptions — `textSecondary` (#A0A0A0), Poppins Regular
- **Labels:** Buttons (orange bg, white text), chips, badges, metadata — Poppins Medium
- **Category chips:** Poppins Medium 12 px; inactive = `surfaceHigh` bg + white text; active = `primary` bg + white text

---

### Spacing & Layout

**Spacing Scale (4px base):**

```dart
class AppSpacing {
  static const double xs = 4.0;   // Tight spacing (chip padding)
  static const double sm = 8.0;   // Small spacing (list item vertical)
  static const double md = 16.0;  // Default spacing (card padding)
  static const double lg = 24.0;  // Large spacing (screen padding)
  static const double xl = 32.0;  // Extra large (section gaps)
  static const double xxl = 48.0; // Huge (between major sections)
}
```

**Touch Targets (Accessibility):**

```dart
class AppSizes {
  static const double minTouchTarget = 48.0;  // Minimum tap area (Material)
  static const double comfortableTap = 56.0;  // Comfortable for kitchen use

  // Common widget sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;

  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;
}
```

**Border Radius:**

```dart
class AppBorderRadius {
  static const double sm = 4.0;   // Chips, small buttons
  static const double md = 8.0;   // Cards, buttons
  static const double lg = 16.0;  // Bottom sheets, large cards
  static const double xl = 24.0;  // Modal dialogs
  static const double circular = 999.0; // Fully rounded (FAB, avatar)
}
```

---

### Elevation & Shadows

**Material Elevation Levels:**

```dart
class AppElevation {
  static const double level0 = 0;   // Flat (background)
  static const double level1 = 2;   // Cards
  static const double level2 = 4;   // FAB at rest
  static const double level3 = 8;   // FAB raised, app bar
  static const double level4 = 12;  // Bottom sheets
  static const double level5 = 16;  // Dialogs
}
```

**Usage:**

- Use elevation sparingly to maintain hierarchy
- Avoid elevation > 8 except for modals
- Dark mode: Use surface tint instead of shadows

---

## Core Components Library

### 1. App Bar Components

#### Primary App Bar

**Visual:**

```
┌─────────────────────────────────────────────────┐
│  ←  Screen Title                    [🔍] [⋮]   │
└─────────────────────────────────────────────────┘
```

**Specification:**

```dart
class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const PrimaryAppBar({
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(title),
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 3,
    );
  }
}
```

**States:**

- Default: 0 elevation
- Scrolled: 3 elevation (when content scrolls underneath)

---

#### App Bar with Sync Status

**Visual:**

```
┌─────────────────────────────────────────────────┐
│  ←  Shopping List            ✓ Synced    [⋮]   │
└─────────────────────────────────────────────────┘
```

**Specification:**

```dart
class AppBarWithSync extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final SyncStatus syncStatus;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        SyncStatusIndicator(status: syncStatus),
        if (actions != null) ...actions!,
      ],
    );
  }
}
```

**Sync Status States:**

| Status  | Icon | Color | Label        | Behavior                  |
| ------- | ---- | ----- | ------------ | ------------------------- |
| Synced  | ✓    | Green | "Synced"     | Static                    |
| Syncing | ↻    | Blue  | "Syncing..." | Rotating animation        |
| Offline | ⚡   | Gray  | "Offline"    | Static, tap shows message |
| Error   | ⚠    | Red   | "Sync Error" | Tap to retry              |

---

### 2. Card Components

#### Recipe Card (Grid) — Full-Bleed with Gradient Overlay

**Visual:**

```
┌─────────────────────┐
│                     │
│  [Full-bleed food   │
│   photo  4:3]       │
│                     │
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ← gradient transparent→#CC000000
│ Chicken Tacos       │ ← white, Poppins SemiBold
│ ⭐ 4.5  🕐 30 min   │ ← amber star, white text, Poppins Medium 11px
└─────────────────────┘
```

Corner radius: **16 px**. No separate content area below the image — all text sits **inside** the card on the gradient overlay.

**Specification:**

```dart
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RecipeCard({
    required this.recipe,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg), // 16 px
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            // Full-bleed image (4:3 aspect ratio)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: RecipeImage(
                imageUrl: recipe.photoUrls.firstOrNull,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: AppColors.surfaceHigh,
                  child: const Icon(Icons.restaurant, size: 48,
                      color: AppColors.textSecondary),
                ),
              ),
            ),

            // Gradient overlay (bottom 60 % of card)
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.35, 1.0],
                    colors: [
                      AppColors.cardOverlayStart,
                      AppColors.cardOverlayEnd,
                    ],
                  ),
                ),
              ),
            ),

            // Text overlaid at the bottom of the card
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textOnImage,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12,
                          color: AppColors.secondary),
                      const SizedBox(width: 2),
                      Text(
                        recipe.rating?.toStringAsFixed(1) ?? '—',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.textOnImage),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.access_time_rounded, size: 12,
                          color: AppColors.textOnImage),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.totalTime.inMinutes} min',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.textOnImage),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Dimensions:**

- Width: Flexible (2-column grid on phone, 3–4 on tablet)
- Image: 4:3 aspect ratio, full-bleed edge-to-edge
- Corner radius: 16 px
- No content area below the image; title + meta sit on gradient overlay

**States:**

- Default: gradient overlay at natural opacity
- Pressed: orange ink ripple + subtle scale-down (0.97×)
- Long-press: orange border ring 2 px (selection mode)

---

#### Shopping List Card

**Visual (dark theme):**

```
┌─────────────────────────────────────────────────┐  bg #1E1E1E, radius 16 px
│  Weekly Groceries               [⋮]            │  ← white Poppins SemiBold + muted icon
│  12 items • 5 purchased                         │  ← textSecondary #A0A0A0
│  ▰▰▰▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱  (42%)          │  ← orange LinearProgressIndicator
│  Updated 2 hours ago                            │  ← bodySmall, textSecondary
└─────────────────────────────────────────────────┘
```

**Specification:**

```dart
class ShoppingListCard extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final progress = list.purchasedCount / list.totalCount;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onMore,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Item count
              Text(
                '${list.totalCount} items • ${list.purchasedCount} purchased',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.neutral.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(
                  progress == 1.0 ? AppColors.success : AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Last updated
              Text(
                'Updated ${_formatRelativeTime(list.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 3. List Item Components

#### Shopping Item Tile

**Visual (Unpurchased):**

```
┌─────────────────────────────────────────────────┐
│  ☐  Milk (2L)                                   │
│     Dairy                           $4.99       │
└─────────────────────────────────────────────────┘
```

**Visual (Purchased):**

```
┌─────────────────────────────────────────────────┐
│  ☑  Milk (2L)                                   │
│     Dairy                           $4.99       │ ← Grayed & strikethrough
└─────────────────────────────────────────────────┘
```

**Specification:**

```dart
class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      background: _buildSwipeBackground(AppColors.primary, Icons.edit, Alignment.centerLeft),
      secondaryBackground: _buildSwipeBackground(AppColors.error, Icons.delete, Alignment.centerRight),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
        } else {
          onDelete?.call();
        }
      },
      child: CheckboxListTile(
        value: item.isPurchased,
        onChanged: onToggle,
        title: Text(
          item.name,
          style: item.isPurchased
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
        subtitle: Row(
          children: [
            Text(item.category),
            const Spacer(),
            if (item.price != null)
              Text('\$${item.price!.toStringAsFixed(2)}'),
          ],
        ),
        secondary: CategoryIcon(category: item.category),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildSwipeBackground(Color color, IconData icon, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Icon(icon, color: Colors.white),
    );
  }
}
```

**Swipe Actions:**

- Swipe right: Edit
- Swipe left: Delete

**Dimensions:**

- Height: 72px (comfortable tap target)
- Checkbox: 24px
- Category icon: 24px

---

#### Pantry Item Tile (with Expiration)

**Visual:**

```
┌─────────────────────────────────────────────────┐
│  🥛  Milk (2L)                          🟡      │ ← Freshness indicator
│      Exp: Feb 28 (2 days)              1.5L    │
└─────────────────────────────────────────────────┘
```

**Specification:**

```dart
class PantryItemTile extends StatelessWidget {
  final PantryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final freshnessColor = _getFreshnessColor(item.expirationDate);
    final daysUntilExpiration = _getDaysUntil(item.expirationDate);

    return ListTile(
      leading: CategoryIcon(category: item.category),
      title: Text(item.name),
      subtitle: item.expirationDate != null
          ? Text('Exp: ${_formatDate(item.expirationDate)} ($daysUntilExpiration days)')
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${item.quantity} ${item.unit}'),
          const SizedBox(width: AppSpacing.sm),
          FreshnessIndicator(color: freshnessColor),
        ],
      ),
      onTap: onTap,
    );
  }

  Color _getFreshnessColor(DateTime? expiration) {
    if (expiration == null) return AppColors.neutral;

    final daysUntil = expiration.difference(DateTime.now()).inDays;
    if (daysUntil < 0) return AppColors.urgent;      // Expired
    if (daysUntil <= 2) return AppColors.urgent;     // 0-2 days
    if (daysUntil <= 7) return AppColors.useSoon;    // 3-7 days
    return AppColors.fresh;                          // 8+ days
  }
}
```

**Freshness Indicator Widget:**

```dart
class FreshnessIndicator extends StatelessWidget {
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
```

---

### 4. Input Components

#### Search Bar

**Visual:**

```
┌─────────────────────────────────────────────────┐
│  🔍  Search recipes...                    [X]  │
└─────────────────────────────────────────────────┘
```

**Specification:**

```dart
class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
```

---

#### Quantity Input

**Visual:**

```
┌─────────────────────┐
│  [-]   2.5   [+]    │  ← Stepper controls
│      cups           │  ← Unit dropdown
└─────────────────────┘
```

**Specification:**

```dart
class QuantityInput extends StatelessWidget {
  final double value;
  final String unit;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<String> onUnitChanged;
  final List<String> unitOptions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => onValueChanged(value - 0.25),
        ),
        SizedBox(
          width: 60,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: InputBorder.none),
            controller: TextEditingController(text: value.toString()),
            onChanged: (text) => onValueChanged(double.tryParse(text) ?? value),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onValueChanged(value + 0.25),
        ),
        const SizedBox(width: AppSpacing.sm),
        DropdownButton<String>(
          value: unit,
          onChanged: (newUnit) => onUnitChanged(newUnit!),
          items: unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
        ),
      ],
    );
  }
}
```

---

### 5. Button Components

#### Primary Action Button (FAB)

**Visual:**

```
    ┌─────┐
    │  +  │  ← Floating Action Button
    └─────┘
```

**Specification:**

```dart
class PrimaryFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
```

**Usage:**

- Shopping: Add item
- Recipes: Create recipe
- Meal Plan: Assign meal
- Pantry: Add item

---

#### Secondary Action Button

**Visual:**

```
┌─────────────────────┐
│  Generate List  🛒  │  ← Outlined button
└─────────────────────┘
```

**Specification:**

```dart
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
      ),
    );
  }
}
```

---

### 6. Empty State Components

**Visual:**

```
        ┌─────────────────────┐
        │                     │
        │       [Icon]        │  ← Large icon (48px)
        │                     │
        │   No recipes yet    │  ← Title
        │                     │
        │  Tap + to add your  │  ← Message
        │   first recipe      │
        │                     │
        │  [+ Add Recipe]     │  ← Optional CTA button
        │                     │
        └─────────────────────┘
```

**Specification:**

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### 7. Loading Components

#### Skeleton Loader (Card) — Dark Theme

**Visual:**

```
┌─────────────────────┐  bg #1E1E1E, radius 16px
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  ← shimmer on dark: #2A2A2A → #3A3A3A
│ ▓▓▓▓▓ [4:3 image area] ▓▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│ ▓▓▓▓▓▓▓▓▓▓▓▓       │  ← title bar
│ ▓▓▓▓▓▓             │  ← metadata bar
└─────────────────────┘
```

**Specification:**

```dart
class RecipeCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(height: 150), // Image placeholder
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: double.infinity, height: 20), // Title
                const SizedBox(height: AppSpacing.xs),
                Skeleton(width: 100, height: 16), // Metadata
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Skeleton extends StatelessWidget {
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),  // dark shimmer base
      highlightColor: const Color(0xFF3A3A3A), // dark shimmer highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
      ),
    );
  }
}
```

---

## Shopping List Screens

### Home / Discovery Screen _(new in v2)_

**Screen Layout:**

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Good Morning, Alex 👋          [🔔] [👤]      │  ← white Poppins SemiBold 18px
│  What would you like to cook today?             │  ← textSecondary
├─────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────┐   │
│  │ 🔍  Search recipes, ingredients...     │   │  ← pill search bar, bg #2A2A2A
│  └─────────────────────────────────────────┘   │
├─────────────────────────────────────────────────┤
│  [🍕 All] [🥗 Healthy] [🍝 Pasta] [🥩 Meat]  │  ← horizontal scroll chips
│  [🍜 Asian] [🌮 Mexican] [🥐 Breakfast]       │     active = orange #FF6B35
├─────────────────────────────────────────────────┤
│  Featured                              See all  │  ← SemiBold 16px + orange link
│  ┌─────────────────────────────────────┐        │
│  │  [Full-bleed 16:9 hero image]      │        │  ← radius 20px
│  │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│        │  ← gradient overlay
│  │ Chicken Tacos             🕐 30m   │        │  ← white overlay text
│  │ ⭐ 4.8  •  Mexican                │        │
│  └─────────────────────────────────────┘        │
│                                                 │
│  Popular Recipes                       See all  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │[Full img]│  │[Full img]│  │[Full img]│     │  ← 4:3, radius 16px
│  │▓ Pasta   │  │▓ Salmon  │  │▓ Tacos   │     │
│  │ ⭐4.5    │  │ ⭐4.7    │  │ ⭐4.9    │     │
│  │ 🕐20min  │  │ 🕐40min  │  │ 🕐30min  │     │
│  └──────────┘  └──────────┘  └──────────┘     │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │  ← nav bar #1A1A1A; active = orange
└─────────────────────────────────────────────────┘
```

---

### Shopping Lists Page (Grid View)

**Screen Layout:**

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Shopping Lists                      [🔍]      │  ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌──────────────┐           │  ← cards bg #1E1E1E radius 16px
│  │ Weekly       │  │ Party        │           │
│  │ Groceries    │  │ Supplies     │           │
│  │ 12 items     │  │ 5 items      │           │
│  │ 5 purchased  │  │ 2 purchased  │           │
│  │ ▰▰▰▰▰▱▱▱▱   │  │ ▰▰▰▱▱▱▱▱▱   │           │  ← orange progress bar
│  └──────────────┘  └──────────────┘           │
│                                                 │
│  ┌──────────────┐  ┌──────────────┐           │
│  │ Costco Run   │  │ + New List   │           │  ← new-list card: dashed orange border
│  │ 3 items      │  │  (dashed)    │           │
│  │ 0 purchased  │  │              │           │
│  └──────────────┘  └──────────────┘           │
│                                                 │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │  ← nav bar #1A1A1A, active = orange
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange #FF6B35, white icon
    └─────┘
```

**Widget Tree:**

```dart
class ShoppingListsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(shoppingListsProvider);

    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Shopping Lists',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: lists.when(
        data: (data) => _buildGrid(context, data),
        loading: () => _buildLoadingSkeleton(),
        error: (error, stack) => ErrorState(error: error),
      ),
      floatingActionButton: PrimaryFAB(
        icon: Icons.add,
        onPressed: () => _createNewList(context),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<ShoppingList> lists) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: lists.length + 1, // +1 for "New List" card
      itemBuilder: (context, index) {
        if (index == lists.length) {
          return _buildNewListCard(context);
        }
        return ShoppingListCard(
          list: lists[index],
          onTap: () => _openList(context, lists[index]),
          onMore: () => _showListOptions(context, lists[index]),
        );
      },
    );
  }
}
```

---

### Shopping List Detail Page

**Screen Layout:**

```
┌─────────────────────────────────────────────────┐  bg #121212
│  ← Weekly Groceries        ✓ Synced    [⋮]    │  ← white; sync status chip
├─────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────┐   │
│  │  5 / 12 items                  42%      │   │  ← progress card bg #1E1E1E
│  │  ▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱▱▱▱  (orange)       │   │
│  └─────────────────────────────────────────┘   │
├─────────────────────────────────────────────────┤
│  [All ▼]  [By Category ▼]                     │  ← pill chips bg #2A2A2A
├─────────────────────────────────────────────────┤
│  ✓ Produce (3/4)                        [▾]   │  ← section header; ✓ = green
├─────────────────────────────────────────────────┤
│  Dairy (0/3)                            [▾]   │  ← expanded section
│  ┌─────────────────────────────────────────┐   │
│  │  ○  Milk (2L)               Dairy  $5  │   │  ← item row bg #1E1E1E radius 12px
│  │  ○  Cheddar Cheese          Dairy  $7  │   │
│  │  ○  Greek Yogurt            Dairy  $6  │   │
│  └─────────────────────────────────────────┘   │
│  Meat & Seafood (0/2)                   [▾]   │
│  ┌─────────────────────────────────────────┐   │
│  │  ○  Chicken Breast (1kg)    Meat  $12  │   │
│  │  ○  Salmon Fillet           Meat  $15  │   │
│  └─────────────────────────────────────────┘   │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │  ← nav bar #1A1A1A
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange
    └─────┘
```

**Design Notes:**

- Checked items: text dims to `textSecondary`, strikethrough applied; checkbox becomes solid orange ✓
- Swipe right on item row → edit (orange bg); swipe left → delete (red #EF4444)
- Section headers: Poppins Medium 13 px, `textSecondary`; item rows sit in `#1E1E1E` grouped card

**Widget Tree:**

```dart
class ShoppingListDetailPage extends ConsumerWidget {
  final ShoppingList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingItemsProvider(list.id));
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBarWithSync(
        title: list.name,
        syncStatus: syncStatus,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showListOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          ShoppingListProgressHeader(list: list),
          ShoppingListFilters(
            onFilterChanged: (filter) => _updateFilter(ref, filter),
            onSortChanged: (sort) => _updateSort(ref, sort),
          ),
          Expanded(
            child: ShoppingItemsListView(
              items: items,
              groupBy: ref.watch(groupByProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: PrimaryFAB(
        icon: Icons.add,
        onPressed: () => _showAddItemSheet(context),
      ),
    );
  }
}
```

---

### Add Item Bottom Sheet

**Visual:**

```
        ┌─────────────────────────────────────┐
        │  ●●●                                │ ← Drag handle
        ├─────────────────────────────────────┤
        │  Add Item                           │ ← Title
        ├─────────────────────────────────────┤
        │  ┌───────────────────────────────┐ │
        │  │ Milk                          │ │ ← Item name input
        │  └───────────────────────────────┘ │
        │  milk, whole milk, 2% milk...    │ ← Autocomplete suggestions
        │                                     │
        │  ┌─────────────┐  ┌─────────────┐ │
        │  │ Quantity: 2 │  │ Unit: L   ▼ │ │ ← Quantity + unit
        │  └─────────────┘  └─────────────┘ │
        │                                     │
        │  Category: Dairy               ▼   │ ← Category dropdown
        │                                     │
        │  ┌───────────────────────────────┐ │
        │  │ Notes (optional)              │ │ ← Notes
        │  └───────────────────────────────┘ │
        │                                     │
        │  ┌───┐ ┌───┐ ┌───┐               │
        │  │ 🎤│ │ 📷│ │ ⌨️ │               │ ← Input method toggles
        │  └───┘ └───┘ └───┘               │
        │                                     │
        │  ┌─────────────────────────────┐   │
        │  │      Add to List            │   │ ← Primary button
        │  └─────────────────────────────┘   │
        │                                     │
        └─────────────────────────────────────┘
```

**Specification:**

```dart
class AddItemBottomSheet extends ConsumerStatefulWidget {
  final ShoppingList list;

  @override
  ConsumerState<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends ConsumerState<AddItemBottomSheet> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  double _quantity = 1.0;
  String _unit = 'pcs';
  String _category = 'Other';
  InputMethod _inputMethod = InputMethod.text;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppBorderRadius.lg),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              const DragHandle(),

              // Title
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Add Item',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Item name input
                    if (_inputMethod == InputMethod.text)
                      AutocompleteTextField(
                        controller: _nameController,
                        label: 'Item name',
                        suggestions: ref.watch(itemSuggestionsProvider),
                        onSuggestionSelected: (suggestion) {
                          _nameController.text = suggestion.name;
                          _category = suggestion.category;
                          setState(() {});
                        },
                      ),

                    if (_inputMethod == InputMethod.voice)
                      VoiceInputWidget(
                        onResult: (text) {
                          _nameController.text = text;
                          setState(() {});
                        },
                      ),

                    if (_inputMethod == InputMethod.photo)
                      PhotoCaptureWidget(
                        onItemRecognized: (item) {
                          _nameController.text = item.name;
                          _category = item.category;
                          setState(() {});
                        },
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Quantity and unit
                    Row(
                      children: [
                        Expanded(
                          child: QuantityInput(
                            value: _quantity,
                            unit: _unit,
                            onValueChanged: (value) => setState(() => _quantity = value),
                            onUnitChanged: (unit) => setState(() => _unit = unit),
                            unitOptions: const ['pcs', 'kg', 'g', 'L', 'mL', 'lb', 'oz'],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Category
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) => setState(() => _category = value!),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Notes
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Input method toggles
                    InputMethodToggle(
                      selected: _inputMethod,
                      onChanged: (method) => setState(() => _inputMethod = method),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Add button
                    ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
                      ),
                      child: const Text('Add to List'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItem() async {
    final item = ShoppingItem(
      id: Uuid().v4(),
      name: _nameController.text,
      quantity: _quantity,
      unit: _unit,
      category: _category,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      isPurchased: false,
    );

    await ref.read(addShoppingItemUseCaseProvider).call(widget.list.id, item);

    if (mounted) Navigator.pop(context);
  }
}
```

---

## Recipe Screens

### Recipe List Page

**Screen Layout:**

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Recipes                       [🔍] [⋮]        │  ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │ 🔍  Search recipes...                     │  │  ← pill search bar bg #2A2A2A
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│  [All] [⭐ Faves] [🕐 Recent] [🥗 Healthy]    │  ← pill chips; active = orange #FF6B35
├─────────────────────────────────────────────────┤
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │[Full img] │  │[Full img] │  │[Full img] │  │  ← full-bleed 4:3, radius 16px
│  │▓ Chicken  │  │▓ Pasta    │  │▓ Salmon   │  │  ← gradient + white overlay text
│  │   Tacos   │  │   Carbonar│  │   Teriyaki│  │
│  │ ⭐4.8      │  │ ⭐4.5      │  │ ⭐4.7      │  │
│  │ 🕐30min   │  │ 🕐20min   │  │ 🕐40min   │  │
│  └───────────┘  └───────────┘  └───────────┘  │
│                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │[Full img] │  │[Full img] │  │[Full img] │  │
│  │▓ Thai     │  │▓ Vegan    │  │▓ BBQ      │  │
│  │   Curry   │  │   Buddha  │  │   Ribs    │  │
│  │ ⭐4.4      │  │ ⭐4.1      │  │ ⭐4.9      │  │
│  │ 🕐45min   │  │ 🕐25min   │  │ 🕐2hrs    │  │
│  └───────────┘  └───────────┘  └───────────┘  │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │  ← nav bar #1A1A1A
└─────────────────────────────────────────────────┘
    ┌────────────────┐
    │  + New Recipe  │  ← Extended FAB, orange bg #FF6B35
    └────────────────┘
```

---

### Recipe Detail Page

**Screen Layout:**

```
┌─────────────────────────────────────────────────┐
│  ← (transparent)                    ⭐  [⋮]   │  ← icons over image, white
│                                                 │
│       [Full-bleed hero photo 16:9]              │  ← swipeable carousel
│       ● ○ ○  (page dots, orange active)         │
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ← gradient bottom
├─────────────────────────────────────────────────┤  ← content card #1E1E1E, top-radius 24px
│  Chicken Tacos                                  │  ← white, Poppins SemiBold 22px
│  ⭐ 4.5  (12 ratings)                          │  ← amber stars, textSecondary
│                                                 │
│  ┌───────┐  ┌──────────┐  ┌─────────┐  │
│  │🕐30m │  │🍽️4 serv.│  │🔥Medium│  │  ← orange-bordered badge chips
│  └───────┘  └──────────┘  └─────────┘  │
├─────────────────────────────────────────────────┤
│  [Ingredients]  [Instructions]  [Notes]        │  ← orange underline on active tab
├─────────────────────────────────────────────────┤
│                                                 │
│  🥬 Produce                                    │  ← category label, textSecondary
│    ○  1 head Lettuce, shredded                 │  ← circle checkbox, white text
│    ○  2 Tomatoes, diced                        │
│    ○  1/2 cup Cilantro, chopped                │
│                                                 │
│  🍗 Meat                                       │
│    ○  500g Chicken breast                      │
│                                                 │
│  🧂 Pantry                                     │
│    ○  12 Taco shells                           │
│    ○  2 tbsp Taco seasoning                    │
├─────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌───────────────────┐ │
│  │ Add to Meal Plan  │  │  Start Cooking 🔥  │ │  ← left = outlined; right = orange
│  └──────────────────┘  └───────────────────┘ │
│  ┌───────────────────────────────────────┐   │
│  │  + Add Missing Items to Shopping List  │   │  ← full-width outlined orange
│  └───────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

**Instructions Tab:**

```
│  Instructions                                   │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────┐   │
│  │● 1  Heat oil in skillet. Cook chicken    │   │  ← step card bg #2A2A2A radius 12px
│  │       until browned (5–7 min).           │   │  ← ● = orange step number circle
│  │       [□ Mark done]                        │   │  ← checkbox; checked = orange ✓
│  └───────────────────────────────────────┘   │
│  ┌───────────────────────────────────────┐   │
│  │● 2  Add taco seasoning + 1/4 cup water. │   │
│  │       Simmer until thick (2–3 min).       │   │
│  │       [□ Mark done]                        │   │
│  └───────────────────────────────────────┘   │
│                                                 │
│  [ 🎤 Voice Chef ]  ← orange outlined button    │
```

**Design Notes:**

- Hero image is full-width 16:9; content card slides up over it with top-radius 24 px
- Active instruction step card gets an orange left border when "Mark done" is tapped
- Serving stepper (− / count / +) inline next to the serving badge chip

---

## Meal Planning Screens

### Weekly Meal Calendar

**Screen Layout:**

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Meal Plan           Feb 26 – Mar 4    ← →   │  ← white Poppins SemiBold + week arrows
├─────────────────────────────────────────────────┤
│  [Mon] [Tue] [Wed] [Thu] [Fri] [Sat] [Sun]   │  ← day pill chips, horiz. scroll
│   ███                                          │  ← active chip = orange #FF6B35 bg
├─────────────────────────────────────────────────┤
│  Monday, Feb 26                                 │  ← section label white
│                                                 │
│  🌅 Breakfast                                  │  ← meal-type label, textSecondary
│  ┌───────────────────────────────────────┐   │
│  │ [img] Oatmeal with Berries              │   │  ← recipe card #1E1E1E radius 14px
│  │       🕐 10 min  •  2 servings  ✓       │   │  ← ✓ green = all ingredients on hand
│  └───────────────────────────────────────┘   │
│                                                 │
│  🌞 Lunch                                      │
│  ┌───────────────────────────────────────┐   │
│  │ 🍲  Leftover Pasta Carbonara           │   │  ← amber leftover pill chip
│  │     from Sun dinner                     │   │
│  └───────────────────────────────────────┘   │
│                                                 │
│  🌙 Dinner                                     │
│  ┌───────────────────────────────────────┐   │
│  │ [img] Chicken Tacos                    │   │
│  │       🕐 30 min  •  ⚠️ 2 missing ingred. │   │  ← ⚠️ in orange
│  └───────────────────────────────────────┘   │
│                                                 │
│  ┌───────────────────────────────────────┐   │
│  │  📝  Generate Shopping List for Week   │   │  ← orange full-width button
│  └───────────────────────────────────────┘   │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │  ← nav bar #1A1A1A
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange
    └─────┘
```

**Empty slot:**

```
│  ┌───────────────────────────────────────┐   │
│  │    [+ Tap to add meal]                  │   │  ← dashed orange border, dark bg
│  └───────────────────────────────────────┘   │
```

**Recipe Picker Bottom Sheet (dark):**

```
┌─────────────────────────────────────────────────┐  bg #1E1E1E top-radius 24px
│  ···                                            │  ← drag handle
│  Select — Monday Dinner                         │  ← white Poppins SemiBold
│  ┌───────────────────────────────────────────┐  │
│  │ 🔍  Search recipes...                     │  │  ← pill search bar #2A2A2A
│  └───────────────────────────────────────────┘  │
│  [All] [⭐ Faves] [🔥 Trending] [⏰ <30min]  │  ← orange-active pill chips
│  🧑‍🍳 What Can I Make? (23)                  │  ← smart filter, orange icon
│                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │[Full img] │  │[Full img] │  │[Full img] │  │  ← same full-bleed cards
│  │▓ Chicken  │  │▓ Pasta    │  │▓ Salmon   │  │
│  └───────────┘  └───────────┘  └───────────┘  │
└─────────────────────────────────────────────────┘
```

---

## Pantry Screens

### Pantry Inventory

**Screen Layout:**

```
┌─────────────────────────────────────────────────┐  bg #121212
│  Pantry                          [🔍] [⋮]      │  ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │  ⚠️  3 items expiring within 3 days       │  │  ← alert banner bg #2A1F16 radius 12px
│  │       Tap to view →                       │  │  ← orange-amber left stripe
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│  [All] [🚨 Expiring] [🟢 Fresh]               │  ← pill chips, active = orange
├─────────────────────────────────────────────────┤
│  🥛 Dairy                                  [▾] │  ← section label white + collapse icon
│  ┌───────────────────────────────────────┐   │
│  │  🥛  Milk (2L)                  🔴 1.5L │   │  ← item card bg #1E1E1E radius 12px
│  │       Exp: Feb 28 (2 days)              │   │  ← red dot = urgent
│  ├───────────────────────────────────────┤   │
│  │  🧀  Cheddar Cheese            🟡 250g  │   │  ← amber dot = use soon (3–7 days)
│  │       Exp: Mar 5 (7 days)               │   │
│  └───────────────────────────────────────┘   │
│                                                 │
│  🍎 Produce                                [▾] │
│  ┌───────────────────────────────────────┐   │
│  │  🍎  Apples                    🟢 6 pcs │   │  ← green dot = fresh (8+ days)
│  │       Exp: Mar 15 (17 days)             │   │
│  ├───────────────────────────────────────┤   │
│  │  🥬  Lettuce                   🔴 1 head │   │
│  │       Exp: Feb 27 (1 day)               │   │
│  └───────────────────────────────────────┘   │
│                                                 │
│  🍞 Pantry Staples                         [▾] │
│  ┌───────────────────────────────────────┐   │
│  │  🍝  Pasta                      ⚪ 500g │   │  ← grey dot = no expiry
│  │       No expiration                     │   │
│  └───────────────────────────────────────┘   │
├─────────────────────────────────────────────────┤
│  🗓️      🛒      📚      🥫      ⚙️           │  ← Pantry tab badge = orange count
└─────────────────────────────────────────────────┘
    ┌─────┐
    │  +  │  ← FAB orange
    └─────┘
```

    └─────┘

```

---

### Expiring Items Dashboard

**Screen Layout:**

```

┌─────────────────────────────────────────────────┐ bg #121212
│ ← Expiring Soon │ ← white Poppins SemiBold
├─────────────────────────────────────────────────┤
│ 🚨 Urgent (0–2 days) · 3 items │ ← red label textSecondary
│ │
│ ┌───────────────────────────────────────────┐ │
│ │ 🥛 Milk (2L) 🔴 1.5L │ │ ← item card bg #1E1E1E radius 12px
│ │ Expires in 2 days (Feb 28) │ │ ← red dot + expiry text
│ │ │ │
│ │ 💡 Recipe Ideas: │ │ ← amber section label
│ │ ┌──────────┐ ┌──────────┐ │ │
│ │ │[img] │ │[img] │ │ │ ← mini recipe fullbleed cards
│ │ │▓Pancakes │ │▓Pasta │ │ │
│ │ └──────────┘ └──────────┘ │ │
│ └───────────────────────────────────────────┘ │
│ │
│ ┌───────────────────────────────────────────┐ │
│ │ 🥬 Lettuce 🔴 1 head │ │
│ │ Expires in 1 day (Feb 27) │ │
│ │ │ │
│ │ 💡 Recipe Ideas: │ │
│ │ ┌──────────┐ ┌──────────┐ │ │
│ │ │[img] │ │[img] │ │ │
│ │ │▓Caesar │ │▓Tacos │ │ │
│ │ └──────────┘ └──────────┘ │ │
│ └───────────────────────────────────────────┘ │
│ │
│ ⚠️ Use Soon (3–7 days) · 2 items │ ← amber label
│ [... similar cards ...] │
│ │
├─────────────────────────────────────────────────┤
│ 🗓️ 🛒 📚 🥫 ⚙️ │ ← nav bar #1A1A1A
└─────────────────────────────────────────────────┘

````

---

## Interaction Patterns

### Swipe Gestures

**Shopping Item:**

- **Swipe Right (→):** Edit item
  - Background: Primary color
  - Icon: Edit pencil
- **Swipe Left (←):** Delete item
  - Background: Red/error color
  - Icon: Delete trash can
  - Requires confirmation if expensive or important

**Pantry Item:**

- **Swipe Right:** Mark as used/depleted
- **Swipe Left:** Edit expiration date

**Recipe Card:**

- **Swipe Right:** Add to favorites
- **Swipe Left:** Hide/never suggest

---

### Long Press Actions

**Recipe Card:**

- **Long Press** → Selection mode enters
  - Checkboxes appear on all cards
  - Multi-select enabled
  - Bottom action bar appears:
    - Delete selected
    - Add to meal plan
    - Export selected

**Shopping Item:**

- **Long Press** → Quick edit mode
  - Quantity stepper appears inline
  - Category quick-change chips

---

### Pull to Refresh

All list views support pull-to-refresh:

- Pull down from top
- Circular progress indicator
- Sync with cloud (if enabled)
- Update local timestamps

---

### Drag and Drop

**Meal Planning:**

- Drag recipe card from calendar slot to another slot
- Drag from recipe list to meal slot
- Visual feedback: card lifts with shadow
- Drop zone highlights

---

## Responsive & Accessibility

### Breakpoints

```dart
class Breakpoints {
  static const double compact = 600;     // Phone (portrait)
  static const double medium = 840;      // Large phone, small tablet
  static const double expanded = 1200;   // Tablet, desktop
}
````

**Layout Adaptations:**

| Breakpoint       | Shopping Lists | Recipes       | Meal Plan       |
| ---------------- | -------------- | ------------- | --------------- |
| Compact (<600)   | 2-column grid  | 2-column grid | Single day view |
| Medium (600-840) | 3-column grid  | 3-column grid | 3-day view      |
| Expanded (>1200) | 4-column grid  | 4-column grid | 7-day grid      |

---

### Accessibility

**Semantic Labels:**

```dart
// Ensure all interactive elements have semantic labels
Semantics(
  label: 'Add milk to shopping list',
  button: true,
  child: IconButton(...)
);
```

**Minimum Touch Targets:**

- All tappable areas: 48x48 dp minimum
- Kitchen-optimized: 56x56 dp recommended

**Color Contrast:**

- Text: 4.5:1 minimum ratio
- Interactive elements: 3:1 minimum

**Screen Reader Support:**

- Ingredient checkboxes announce state
- Recipe steps announce progress
- Expiration dates announce urgency

**Keyboard Navigation:**

- Tab order follows visual hierarchy
- Enter/Space activates buttons
- Arrow keys navigate lists

---

## Dark Mode

**Auto Color Switching:**

```dart
// Colors automatically adapt
Theme.of(context).colorScheme.primary  // Green in light, lighter green in dark
Theme.of(context).colorScheme.surface  // White in light, dark gray in dark
```

**Special Considerations:**

- Recipe photos: Overlay gradient for text legibility
- Expiration colors: Maintain semantic meaning (red = urgent in both themes)
- Elevation: Use surface tint instead of shadows in dark mode

---

**Document End**

**Next Steps:**

1. Build component library in Storybook/Widgetbook
2. Create Figma prototypes based on these specs
3. User test with target personas
4. Implement using revised epics timeline
