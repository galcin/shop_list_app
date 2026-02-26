# GitHub Issues Creator - ALL 57 User Stories
# Configuration
$REPO_OWNER = "your-username"  # Replace with your GitHub username
$REPO_NAME = "shop_list_app"
$GITHUB_TOKEN = "your-github-token-here"  # Replace with your GitHub Personal Access Token
$BASE_URL = "https://api.github.com"

# Helper function for API calls
function Invoke-GitHubAPI {
    param(
        [string]$Method = "GET",
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    $headers = @{
        "Authorization" = "Bearer $GITHUB_TOKEN"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $url = "$BASE_URL$Endpoint"
    
    try {
        $params = @{
            Uri = $url
            Method = $Method
            Headers = $headers
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 422) {
            # Already exists
            return $null
        }
        Write-Host "API Error: $_" -ForegroundColor Red
        return $null
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " GitHub Issues Creator - ALL 57 Stories" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Repository: $REPO_OWNER/$REPO_NAME" -ForegroundColor Green
Write-Host ""

# Test connection
Write-Host "Testing GitHub API connection..." -ForegroundColor Yellow
$user = Invoke-GitHubAPI -Endpoint "/user"
if (-not $user) {
    Write-Host "Failed to connect to GitHub API" -ForegroundColor Red
    exit 1
}
Write-Host "Connected as: $($user.login)" -ForegroundColor Green
Write-Host ""

# Get milestone numbers
Write-Host "Fetching milestones..." -ForegroundColor Cyan
$milestoneList = Invoke-GitHubAPI -Endpoint "/repos/$REPO_OWNER/$REPO_NAME/milestones?state=all"
$milestoneMap = @{}
foreach ($m in $milestoneList) {
    $milestoneMap[$m.title] = $m.number
}
Write-Host "Found $($milestoneMap.Count) milestones" -ForegroundColor Green
Write-Host ""

# Ask for confirmation
Write-Host "This will create all 57 user stories" -ForegroundColor Yellow
$confirmation = Read-Host "Continue? (yes/no)"
if ($confirmation -ne "yes" -and $confirmation -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Define ALL 57 issues
Write-Host "Preparing all 57 user stories..." -ForegroundColor Cyan

$issues = @(
    # Epic 1: Shopping List Management (8 issues)
    @{
        title = "US-1.1 - Create and Manage Shopping Lists"
        body = @"
### Description

As a **user**  
I want to **create multiple shopping lists with custom names**  
So that **I can organize different shopping trips (weekly groceries, party supplies, etc.)**

### Acceptance Criteria

- [ ] User can create new shopping list with custom name
- [ ] User can view all shopping lists
- [ ] User can rename existing shopping lists
- [ ] User can delete shopping lists (with confirmation)
- [ ] User can mark one list as "active" (default for quick adds)
- [ ] Empty state shows helpful prompt to create first list

### Technical Notes

- Local storage with Hive/Drift
- List model: ``id``, ``name``, ``createdAt``, ``updatedAt``, ``isActive``, ``itemCount``
- Implement soft delete with recovery option

### Testing Requirements

- Unit tests for CRUD operations
- Widget tests for UI

### Dependencies

None
"@
        labels = @("priority/P0", "size/M", "epic/E1", "release/MVP-v1.0", "type/feature")
        milestone = "E1: Shopping List Management"
    },
    @{
        title = "US-1.2 - Add Items to Shopping List"
        body = @"
### Description

As a **user**  
I want to **add items to my shopping list via text, voice, or photo**  
So that **I can quickly capture what I need to buy**

### Acceptance Criteria

- [ ] Text input with autocomplete from previous items
- [ ] Voice input using speech-to-text
- [ ] Photo capture with optional AI product recognition
- [ ] Manual quantity and unit entry (optional)
- [ ] Category auto-assignment based on item type
- [ ] Duplicate detection with merge option

### Technical Notes

- Speech recognition: Flutter ``speech_to_text`` package
- Photo recognition: ML Kit or Google Cloud Vision API (deferred processing if offline)
- Item model: ``id``, ``name``, ``quantity``, ``unit``, ``category``, ``isPurchased``, ``notes``

### Testing Requirements

- E2E test for each input method

### Dependencies

- Depends on US-1.1
"@
        labels = @("priority/P0", "size/L", "epic/E1", "release/MVP-v1.0", "type/feature")
        milestone = "E1: Shopping List Management"
    },
    @{
        title = "US-1.3 - Organize Items by Category"
        body = @"
### Description

As a **user**  
I want to **see shopping list items grouped by category**  
So that **I can shop efficiently aisle by aisle**

### Acceptance Criteria

- [ ] Items auto-grouped by category (Produce, Dairy, Meat, Bakery, etc.)
- [ ] User can manually change item category
- [ ] Categories sorted by typical store layout
- [ ] User can customize category order
- [ ] Collapse/expand category sections
- [ ] Show item count per category

### Technical Notes

- Predefined category list with icons
- User preferences for category ordering stored locally
- Category model: ``id``, ``name``, ``icon``, ``sortOrder``, ``colorCode``

### Testing Requirements

- Widget tests for categorization, sorting

### Dependencies

- Depends on US-1.2
"@
        labels = @("priority/P0", "size/M", "epic/E1", "release/MVP-v1.0", "type/feature")
        milestone = "E1: Shopping List Management"
    },
    @{
        title = "US-1.4 - Check Off Purchased Items"
        body = @"
### Description

As a **shopper in a store**  
I want to **check off items as I purchase them**  
So that **I track what's in my cart and what remains**

### Acceptance Criteria

- [ ] Tap item to toggle purchased state
- [ ] Visual indication (checkbox, strikethrough)
- [ ] Purchased items move to bottom or separate section
- [ ] Undo accidental check-off
- [ ] Show progress indicator (5/12 items purchased)
- [ ] Option to hide completed items

### Technical Notes

- Optimistic UI updates
- Local state management with Riverpod
- Persist state immediately to local DB

### Testing Requirements

- Widget interaction tests

### Dependencies

- Depends on US-1.2
"@
        labels = @("priority/P0", "size/S", "epic/E1", "release/MVP-v1.0", "type/feature")
        milestone = "E1: Shopping List Management"
    },
    @{
        title = "US-1.5 - Offline Shopping List Access"
        body = @"
### Description

As a **shopper in a store with poor connectivity**  
I want to **access and modify my shopping list offline**  
So that **I can use the app regardless of network availability**

### Acceptance Criteria

- [ ] All shopping lists accessible without internet
- [ ] All CRUD operations work offline
- [ ] Changes saved to local database immediately
- [ ] No loading delays or errors when offline
- [ ] Sync status indicator visible but non-intrusive

### Technical Notes

- Offline-first architecture (local DB as source of truth)
- Sync queue for changes to propagate when online
- Network status detection

### Testing Requirements

- Integration tests simulating offline scenarios

### Dependencies

- Depends on US-1.1, US-1.2
- Related to Epic E5 (Offline & Sync)
"@
        labels = @("priority/P0", "size/L", "epic/E1", "release/MVP-v1.0", "type/feature")
        milestone = "E1: Shopping List Management"
    },
    @{
        title = "US-1.6 - View List in Grid or List Mode"
        body = @"
### Description

As a **user**  
I want to **toggle between grid and list view**  
So that **I can choose the layout that works best for me**

### Acceptance Criteria

- [ ] Toggle button switches between list and grid view
- [ ] Grid view shows items as cards with images
- [ ] List view shows compact rows
- [ ] View preference persists across sessions
- [ ] Smooth transition animation between views

### Technical Notes

- Shared Preferences for view mode storage
- GridView and ListView widgets with same data source
- Animated switcher for transitions

### Testing Requirements

- Widget tests for both views

### Dependencies

- Depends on US-1.2
"@
        labels = @("priority/P2", "size/S", "epic/E1", "type/enhancement")
        milestone = "E1: Shopping List Management"
    },
    @{
        title = "US-1.7 - Edit and Delete Items"
        body = @"
### Description

As a **user**  
I want to **edit or remove items from my shopping list**  
So that **I can fix mistakes or change my mind**

### Acceptance Criteria

- [ ] Swipe left/right to reveal edit and delete actions
- [ ] Tap item to open edit dialog
- [ ] Edit item name, quantity, category, notes
- [ ] Delete with undo snackbar (3 second revert window)
- [ ] Bulk delete selected items
- [ ] Confirmation for bulk operations

### Technical Notes

- Dismissible widget for swipe actions
- Dialog form for editing
- Soft delete with recovery

### Testing Requirements

- Widget tests for edit/delete flows

### Dependencies

- Depends on US-1.2
"@
        labels = @("priority/P0", "size/M", "epic/E1", "release/MVP-v1.0", "type/feature")
        milestone = "E1: Shopping List Management"
    },
    @{
        title = "US-1.8 - Share Shopping List"
        body = @"
### Description

As a **household member**  
I want to **share my shopping list with family**  
So that **anyone can shop from the same list**

### Acceptance Criteria

- [ ] Generate shareable link or QR code
- [ ] Share via messaging, email, or clipboard
- [ ] Recipient can view list in web browser (read-only)
- [ ] Optional: Allow recipient to install app from link
- [ ] Shared list updates in real-time when synced

### Technical Notes

- Generate unique share token
- Public read-only API endpoint for shared lists
- Deep linking for app installation
- Real-time sync via WebSocket or Firebase Firestore listeners

### Testing Requirements

- Integration tests for sharing flow

### Dependencies

- Depends on US-1.1
- Related to Epic E5 (Sync), Epic E6 (Collaboration)
"@
        labels = @("priority/P1", "size/XL", "epic/E1", "release/v1.1", "type/feature")
        milestone = "E1: Shopping List Management"
    },
    
    # Epic 2: Meal Planning (7 issues)
    @{
        title = "US-2.1 - Weekly Meal Calendar"
        body = @"
### Description

As a **meal planner**  
I want to **view a 7-day calendar to plan my meals**  
So that **I can visualize my weekly menu at a glance**

### Acceptance Criteria

- [ ] Calendar displays 7 days (Monday-Sunday or user-defined start)
- [ ] Each day shows 3 meal slots (Breakfast, Lunch, Dinner)
- [ ] Tap slot to assign recipe
- [ ] Empty slots show placeholder "Tap to add meal"
- [ ] Navigate to previous/next week
- [ ] Jump to specific date

### Technical Notes

- Calendar widget using Flutter ``table_calendar`` or custom
- MealPlan model: ``id``, ``date``, ``mealType``, ``recipeId``, ``servings``
- Efficient date-based queries

### Testing Requirements

- Widget tests for calendar navigation

### Dependencies

None
"@
        labels = @("priority/P0", "size/L", "epic/E2", "release/MVP-v1.0", "type/feature")
        milestone = "E2: Meal Planning"
    },
    @{
        title = "US-2.2 - Assign Recipes to Meal Slots"
        body = @"
### Description

As a **meal planner**  
I want to **assign recipes to specific meal slots**  
So that **I know what to cook each day**

### Acceptance Criteria

- [ ] Tap meal slot to open recipe picker
- [ ] Search and filter recipes in picker
- [ ] Select recipe to assign to slot
- [ ] Preview recipe before assigning
- [ ] Drag-drop recipe between slots (optional)
- [ ] Remove recipe from slot

### Technical Notes

- Modal bottom sheet for recipe selection
- Recipe picker with search, filters, favorites
- Optimistic UI update

### Testing Requirements

- Integration tests for assignment flow

### Dependencies

- Depends on US-2.1
- Related to Epic E3 (Recipe Management)
"@
        labels = @("priority/P0", "size/L", "epic/E2", "release/MVP-v1.0", "type/feature")
        milestone = "E2: Meal Planning"
    },
    @{
        title = "US-2.3 - Auto-Generate Shopping List from Meal Plan"
        body = @"
### Description

As a **meal planner**  
I want to **automatically create a shopping list from my weekly meal plan**  
So that **I don't manually transcribe ingredients**

### Acceptance Criteria

- [ ] "Generate Shopping List" button on meal planner
- [ ] Collect all ingredients from assigned recipes
- [ ] Consolidate duplicate ingredients (sum quantities)
- [ ] Cross-reference pantry inventory
- [ ] Only include items not in stock (or below threshold)
- [ ] Preview generated list before creating
- [ ] Allow manual edits before finalizing

### Technical Notes

- Ingredient aggregation algorithm
- Unit conversion for consolidation (cups, tbsp, etc.)
- Pantry stock checking
- Create shopping list with link to meal plan

### Testing Requirements

- Unit tests for ingredient consolidation logic

### Dependencies

- Depends on US-2.1, US-2.2
- Related to Epic E3 (Recipes), Epic E4 (Pantry)
"@
        labels = @("priority/P0", "size/XL", "epic/E2", "release/MVP-v1.0", "type/feature")
        milestone = "E2: Meal Planning"
    },
    @{
        title = "US-2.4 - Recipe-Pantry Matching (What Can I Make?)"
        body = @"
### Description

As a **cook**  
I want to **see which recipes I can make with my current pantry**  
So that **I use what I have before buying more**

### Acceptance Criteria

- [ ] "What Can I Make?" filter in recipe list
- [ ] Match recipes against pantry inventory
- [ ] Show complete matches first (100% ingredients available)
- [ ] Show partial matches with missing ingredient count
- [ ] Sort by completion percentage
- [ ] Highlight missing ingredients in recipe view
- [ ] One-tap add missing items to shopping list

### Technical Notes

- Recipe-ingredient matching algorithm
- Ingredient normalization for matching
- Performance optimization for large pantries

### Testing Requirements

- Unit tests for matching algorithm

### Dependencies

- Related to Epic E3 (Recipes), Epic E4 (Pantry)
"@
        labels = @("priority/P0", "size/XL", "epic/E2", "release/MVP-v1.0", "type/feature")
        milestone = "E2: Meal Planning"
    },
    @{
        title = "US-2.5 - Copy Previous Week's Meal Plan"
        body = @"
### Description

As a **busy meal planner**  
I want to **duplicate last week's meal plan**  
So that **I can reuse successful menus without starting from scratch**

### Acceptance Criteria

- [ ] "Copy from previous week" button
- [ ] Select which week to copy from
- [ ] Option to copy all meals or select specific days
- [ ] Preview before confirming
- [ ] Adjust servings if needed
- [ ] Overwrite or merge with existing plan

### Technical Notes

- Date offset calculation
- Bulk meal plan creation
- Conflict resolution for existing meals

### Testing Requirements

- Integration tests for copy operation

### Dependencies

- Depends on US-2.1, US-2.2
"@
        labels = @("priority/P1", "size/M", "epic/E2", "release/v1.1", "type/feature")
        milestone = "E2: Meal Planning"
    },
    @{
        title = "US-2.6 - Serving Size Adjustment"
        body = @"
### Description

As a **meal planner**  
I want to **adjust recipe servings when planning meals**  
So that **I cook the right amount for my household**

### Acceptance Criteria

- [ ] Set default household size in settings
- [ ] Override servings per meal slot
- [ ] Ingredient quantities scale proportionally
- [ ] Shopping list reflects adjusted quantities
- [ ] Common fractions (1/2, 1/3, 1/4) handled correctly
- [ ] Visual indicator shows serving adjustment

### Technical Notes

- Recipe scaling algorithm
- Fraction normalization
- Rounding logic for practical measurements

### Testing Requirements

- Unit tests for scaling calculations

### Dependencies

- Depends on US-2.2, US-2.3
"@
        labels = @("priority/P1", "size/L", "epic/E2", "release/v1.1", "type/feature")
        milestone = "E2: Meal Planning"
    },
    @{
        title = "US-2.7 - Meal Plan Templates"
        body = @"
### Description

As a **user seeking inspiration**  
I want to **use pre-built meal plan templates**  
So that **I can quickly adopt healthy eating patterns**

### Acceptance Criteria

- [ ] Library of meal plan templates (Vegetarian Week, Budget Friendly, etc.)
- [ ] Preview template before applying
- [ ] Apply template to current week
- [ ] Templates include recipes or recipe suggestions
- [ ] User can create custom templates from their plans
- [ ] Share templates with community (future)

### Technical Notes

- Template data structure (JSON or model)
- Template marketplace (cloud-based, future)
- User-created template storage

### Testing Requirements

- Widget tests for template application

### Dependencies

- Depends on US-2.1, US-2.2
"@
        labels = @("priority/P2", "size/L", "epic/E2", "type/feature")
        milestone = "E2: Meal Planning"
    },
    
    # Epic 3: Recipe Management (9 issues)
    @{
        title = "US-3.1 - Manual Recipe Entry"
        body = @"
### Description

As a **user**  
I want to **manually enter my own recipes**  
So that **I can digitize my cookbook collection**

### Acceptance Criteria

- [ ] Form with fields: title, description, servings, prep time, cook time
- [ ] Multi-step ingredient entry with quantity, unit, name
- [ ] Rich text editor for instructions
- [ ] Add multiple photos via camera or gallery
- [ ] Tag categories (cuisine, meal type, difficulty)
- [ ] Save as draft or publish
- [ ] Preview before saving

### Technical Notes

- Recipe model with nested ingredients, instructions
- Image upload to local storage (cloud sync later)
- Rich text editor: ``flutter_quill`` or ``html_editor``
- Draft storage for recovery

### Testing Requirements

- Integration tests for recipe creation

### Dependencies

None
"@
        labels = @("priority/P0", "size/XL", "epic/E3", "release/MVP-v1.0", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.2 - Recipe URL Import"
        body = @"
### Description

As a **user**  
I want to **import recipes from website URLs**  
So that **I quickly save online recipes**

### Acceptance Criteria

- [ ] Paste URL into import field
- [ ] Auto-extract title, ingredients, instructions, images
- [ ] Support major recipe sites (AllRecipes, NYT Cooking, Food Network)
- [ ] Preview extracted data before saving
- [ ] Manual edit imported recipe
- [ ] Handle failed imports with fallback to manual entry

### Technical Notes

- Web scraping or recipe schema parsing
- Support for Recipe Schema (schema.org/Recipe)
- Cloud function for scraping (avoid app bloat)
- Rate limiting and error handling

### Testing Requirements

- Integration tests with test URLs

### Dependencies

- Depends on US-3.1
"@
        labels = @("priority/P1", "size/XL", "epic/E3", "release/v1.1", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.3 - Recipe Search and Filter"
        body = @"
### Description

As a **user**  
I want to **search and filter my recipe library**  
So that **I can quickly find recipes matching my needs**

### Acceptance Criteria

- [ ] Full-text search across title, ingredients, tags
- [ ] Filter by category (cuisine, meal type, difficulty)
- [ ] Filter by dietary restrictions (vegetarian, vegan, gluten-free)
- [ ] Filter by prep/cook time
- [ ] Multi-select filters
- [ ] Save filter presets
- [ ] Sort by: name, date added, rating, cook time

### Technical Notes

- Search index for fast full-text search
- Multi-criteria filter logic
- Filter persistence in preferences

### Testing Requirements

- Unit tests for search/filter logic
- Widget tests for UI

### Dependencies

- Depends on US-3.1
"@
        labels = @("priority/P0", "size/L", "epic/E3", "release/MVP-v1.0", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.4 - Recipe Detail View"
        body = @"
### Description

As a **user**  
I want to **view recipe details in a clean, readable format**  
So that **I can follow the recipe while cooking**

### Acceptance Criteria

- [ ] Beautiful layout with hero image, title, description
- [ ] Display servings, prep time, cook time, total time
- [ ] Ingredient list with checkboxes
- [ ] Step-by-step instructions (numbered or bulleted)
- [ ] Scroll-free view or keep-screen-on option
- [ ] Zoom in on recipe photos
- [ ] Share recipe button

### Technical Notes

- Custom scrollable layout with image parallax
- Wake lock to keep screen on during cooking
- Share via platform share sheet

### Testing Requirements

- Widget tests for layout
- Screenshot tests

### Dependencies

- Depends on US-3.1
"@
        labels = @("priority/P0", "size/M", "epic/E3", "release/MVP-v1.0", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.5 - Recipe Rating and Notes"
        body = @"
### Description

As a **user**  
I want to **rate recipes and add personal notes**  
So that **I remember which recipes I loved and any tweaks I made**

### Acceptance Criteria

- [ ] 5-star rating system
- [ ] Add personal notes/comments after cooking
- [ ] Edit notes later
- [ ] View all my notes on recipe detail page
- [ ] Filter recipes by rating
- [ ] Sort recipes by rating

### Technical Notes

- RecipeRating model: ``recipeId``, ``rating``, ``notes``, ``cookedDate``
- Relationship: one recipe to many ratings (for tracking over time)

### Testing Requirements

- Unit tests for rating CRUD
- Widget tests for UI

### Dependencies

- Depends on US-3.1, US-3.4
"@
        labels = @("priority/P1", "size/M", "epic/E3", "release/v1.1", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.6 - Recipe Cook Mode"
        body = @"
### Description

As a **cook**  
I want to **follow recipe in hands-free mode**  
So that **I can cook without touching my device with messy hands**

### Acceptance Criteria

- [ ] Large text mode for easy reading from distance
- [ ] Voice commands: "next step", "previous step", "repeat"
- [ ] Timer integration for each step
- [ ] Auto-advance option
- [ ] Keep screen always on
- [ ] Simplified UI (hide extra elements)
- [ ] Background mode continues timers when app minimized

### Technical Notes

- Voice command recognition
- Multiple timer management
- Wake lock implementation
- Background timer service

### Testing Requirements

- Integration tests for voice commands
- Timer accuracy tests

### Dependencies

- Depends on US-3.4
"@
        labels = @("priority/P1", "size/L", "epic/E3", "release/v1.1", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.7 - Favorite Recipes"
        body = @"
### Description

As a **user**  
I want to **mark recipes as favorites**  
So that **I can quickly access my go-to recipes**

### Acceptance Criteria

- [ ] Heart/star icon to toggle favorite status
- [ ] "Favorites" filter in recipe list
- [ ] Favorite count visible in recipe card
- [ ] Sort favorites by recently added or alphabetically
- [ ] Unfavorite from detail view or list view

### Technical Notes

- Boolean field on Recipe model: ``isFavorite``
- Index for fast favorite filtering

### Testing Requirements

- Widget tests for favorite toggle
- Unit tests for filter

### Dependencies

- Depends on US-3.1
"@
        labels = @("priority/P0", "size/S", "epic/E3", "release/MVP-v1.0", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.8 - Recipe Categories and Tags"
        body = @"
### Description

As a **user**  
I want to **organize recipes with categories and tags**  
So that **I can browse recipes by type**

### Acceptance Criteria

- [ ] Predefined categories: Breakfast, Lunch, Dinner, Snacks, Desserts
- [ ] Cuisine tags: Italian, Mexican, Asian, American, etc.
- [ ] Dietary tags: Vegetarian, Vegan, Gluten-Free, Dairy-Free, etc.
- [ ] Difficulty tags: Easy, Medium, Hard
- [ ] Multi-select tags when creating recipe
- [ ] Browse recipes by category/tag
- [ ] Tag-based filtering in search

### Technical Notes

- Many-to-many relationship: recipes to tags
- Tag model: ``id``, ``name``, ``type`` (category, cuisine, dietary, difficulty)
- Predefined tag library with ability to add custom tags

### Testing Requirements

- Unit tests for tag relationships
- Widget tests for tag selection

### Dependencies

- Depends on US-3.1
"@
        labels = @("priority/P0", "size/M", "epic/E3", "release/MVP-v1.0", "type/feature")
        milestone = "E3: Recipe Management"
    },
    @{
        title = "US-3.9 - Recipe Import from Photo"
        body = @"
### Description

As a **user**  
I want to **take a photo of a recipe card and extract text**  
So that **I can quickly digitize physical recipes**

### Acceptance Criteria

- [ ] Camera interface to capture recipe photo
- [ ] OCR to extract text from image
- [ ] Smart parsing to identify ingredients vs instructions
- [ ] Preview extracted recipe before saving
- [ ] Manual editing of extracted recipe
- [ ] Support multiple languages

### Technical Notes

- OCR: Google ML Kit Text Recognition or Tesseract
- NLP for ingredient vs instruction parsing
- May require cloud processing for accuracy

### Testing Requirements

- Integration tests with sample recipe photos
- Accuracy testing

### Dependencies

- Depends on US-3.1
"@
        labels = @("priority/P2", "size/XL", "epic/E3", "release/v1.2", "type/feature")
        milestone = "E3: Recipe Management"
    },
    
    # Epic 4: Pantry & Inventory (6 issues)
    @{
        title = "US-4.1 - Pantry Item Management"
        body = @"
### Description

As a **user**  
I want to **track what's in my pantry**  
So that **I avoid buying duplicates and know what I have**

### Acceptance Criteria

- [ ] Add item to pantry with name, quantity, unit, location
- [ ] View all pantry items
- [ ] Edit item details
- [ ] Delete items
- [ ] Mark items as "running low"
- [ ] Search pantry items
- [ ] Filter by category or location (fridge, freezer, pantry)

### Technical Notes

- PantryItem model: ``id``, ``name``, ``quantity``, ``unit``, ``location``, ``category``, ``expirationDate``, ``isLow``
- Similar CRUD operations as shopping list items

### Testing Requirements

- Unit tests for pantry CRUD
- Widget tests for UI

### Dependencies

None
"@
        labels = @("priority/P0", "size/L", "epic/E4", "release/MVP-v1.0", "type/feature")
        milestone = "E4: Pantry & Inventory"
    },
    @{
        title = "US-4.2 - Expiration Date Tracking"
        body = @"
### Description

As a **user**  
I want to **track expiration dates of pantry items**  
So that **I use items before they spoil**

### Acceptance Criteria

- [ ] Set expiration date when adding item
- [ ] Visual indicator for items expiring soon (within 7 days)
- [ ] Alert for expired items
- [ ] Sort pantry by expiration date
- [ ] Filter: "Expiring Soon", "Expired"
- [ ] Notification for items expiring tomorrow (optional)

### Technical Notes

- Date picker for expiration date
- Background job to check expirations daily
- Local notifications

### Testing Requirements

- Unit tests for expiration logic
- Widget tests for date picker

### Dependencies

- Depends on US-4.1
"@
        labels = @("priority/P0", "size/L", "epic/E4", "release/MVP-v1.0", "type/feature")
        milestone = "E4: Pantry & Inventory"
    },
    @{
        title = "US-4.3 - Quick Add from Shopping List"
        body = @"
### Description

As a **user**  
I want to **transfer purchased items to pantry**  
So that **I track inventory after shopping**

### Acceptance Criteria

- [ ] "Add to Pantry" action on checked-off shopping list items
- [ ] Bulk transfer all purchased items to pantry
- [ ] Prompt for expiration date during transfer
- [ ] Automatically set quantity based on shopping list
- [ ] Clear purchased items from shopping list after transfer

### Technical Notes

- Batch operation to create pantry items from shopping list
- Transaction handling for data consistency

### Testing Requirements

- Integration tests for transfer flow

### Dependencies

- Depends on US-1.4, US-4.1
"@
        labels = @("priority/P0", "size/M", "epic/E4", "release/MVP-v1.0", "type/feature")
        milestone = "E4: Pantry & Inventory"
    },
    @{
        title = "US-4.4 - Inventory Consumption Tracking"
        body = @"
### Description

As a **user**  
I want to **track when I use pantry items**  
So that **quantities stay accurate**

### Acceptance Criteria

- [ ] Reduce quantity when cooking from recipe
- [ ] Manual quantity adjustment
- [ ] Track usage history
- [ ] Auto-add to shopping list when quantity reaches threshold
- [ ] Set minimum stock level per item

### Technical Notes

- Recipe cooking triggers pantry deduction
- UsageLog model: ``pantryItemId``, ``quantity``, ``usedDate``, ``recipeId``
- Threshold-based shopping list automation

### Testing Requirements

- Unit tests for inventory deduction
- Integration tests for recipe-pantry link

### Dependencies

- Depends on US-4.1, Recipe cooking feature
"@
        labels = @("priority/P1", "size/L", "epic/E4", "release/v1.1", "type/feature")
        milestone = "E4: Pantry & Inventory"
    },
    @{
        title = "US-4.5 - Barcode Scanning"
        body = @"
### Description

As a **user**  
I want to **scan product barcodes to add to pantry**  
So that **I can quickly inventory items**

### Acceptance Criteria

- [ ] Camera interface for barcode scanning
- [ ] Recognize UPC, EAN, QR codes
- [ ] Look up product details from barcode
- [ ] Auto-fill item name, category from product database
- [ ] Manual entry if product not found
- [ ] Add quantity after scanning

### Technical Notes

- Barcode scanning: ``mobile_scanner`` or ``barcode_scan2``
- Product lookup: Open Food Facts API or similar
- Cache product data locally

### Testing Requirements

- Integration tests with sample barcodes

### Dependencies

- Depends on US-4.1
"@
        labels = @("priority/P1", "size/L", "epic/E4", "release/v1.1", "type/feature")
        milestone = "E4: Pantry & Inventory"
    },
    @{
        title = "US-4.6 - Shopping List Auto-Replenishment"
        body = @"
### Description

As a **user**  
I want to **automatically add low-stock items to shopping list**  
So that **I never run out of essentials**

### Acceptance Criteria

- [ ] Set minimum stock threshold per pantry item
- [ ] Auto-add to shopping list when below threshold
- [ ] Option to disable auto-add per item
- [ ] Notification when items auto-added
- [ ] "Essentials" shopping list for recurring items

### Technical Notes

- Background job to check stock levels
- Integration with shopping list creation
- User preferences for auto-add behavior

### Testing Requirements

- Unit tests for threshold logic

### Dependencies

- Depends on US-4.1, US-1.1
"@
        labels = @("priority/P2", "size/M", "epic/E4", "type/feature")
        milestone = "E4: Pantry & Inventory"
    },
    
    # Epic 5: Offline & Sync (5 issues)
    @{
        title = "US-5.1 - Local Database Setup"
        body = @"
### Description

As a **developer**  
I want to **set up local database infrastructure**  
So that **the app works offline and data persists locally**

### Acceptance Criteria

- [ ] Choose local database (Hive, Drift/Moor, or SQLite)
- [ ] Define data models for all entities
- [ ] Implement CRUD operations
- [ ] Database migrations support
- [ ] Database schema versioning
- [ ] Data seeding for initial setup

### Technical Notes

- Recommendation: Drift for relational data with type safety
- Migration strategy for schema changes
- Indexed queries for performance

### Testing Requirements

- Unit tests for all CRUD operations
- Migration tests

### Dependencies

None
"@
        labels = @("priority/P0", "size/L", "epic/E5", "release/MVP-v1.0", "type/feature")
        milestone = "E5: Offline & Sync"
    },
    @{
        title = "US-5.2 - Offline-First State Management"
        body = @"
### Description

As a **developer**  
I want to **implement offline-first state management**  
So that **all app features work without internet**

### Acceptance Criteria

- [ ] All data operations use local DB as source of truth
- [ ] State management with Riverpod/Bloc
- [ ] Optimistic UI updates
- [ ] No blocking network calls on UI thread
- [ ] Network status monitoring
- [ ] Graceful degradation when offline (hide sync-only features)

### Technical Notes

- Riverpod for state management
- Connectivity Plus for network detection
- Local DB as single source of truth

### Testing Requirements

- Integration tests in offline mode
- State management tests

### Dependencies

- Depends on US-5.1
"@
        labels = @("priority/P0", "size/L", "epic/E5", "release/MVP-v1.0", "type/feature")
        milestone = "E5: Offline & Sync"
    },
    @{
        title = "US-5.3 - Sync Queue & Conflict Resolution"
        body = @"
### Description

As a **user**  
I want to **have my changes sync across devices**  
So that **I can access my data anywhere**

### Acceptance Criteria

- [ ] Queue local changes for sync when online
- [ ] Upload queue items to backend
- [ ] Download changes from backend
- [ ] Conflict resolution strategy (last-write-wins or custom)
- [ ] Sync status indicator (syncing, synced, error)
- [ ] Manual sync trigger
- [ ] Auto-sync on network reconnection

### Technical Notes

- SyncQueue model: ``operation``, ``entityType``, ``entityId``, ``data``, ``timestamp``, ``status``
- Conflict resolution: timestamp-based or user prompt
- Background sync service

### Testing Requirements

- Integration tests for sync scenarios
- Conflict resolution tests

### Dependencies

- Depends on US-5.1, US-5.2, US-5.4

### Notes

**This story is 13 points and should be split into smaller stories:**

- US-5.3a: Sync Queue (5 pts)
- US-5.3b: Conflict Resolution (8 pts)
"@
        labels = @("priority/P0", "size/XXL", "epic/E5", "release/MVP-v1.0", "type/feature")
        milestone = "E5: Offline & Sync"
    },
    @{
        title = "US-5.4 - Cloud Backend & API"
        body = @"
### Description

As a **developer**  
I want to **set up cloud backend and API**  
So that **data syncs across devices**

### Acceptance Criteria

- [ ] Choose backend (Firebase, Supabase, custom)
- [ ] User authentication (email, Google, Apple)
- [ ] REST or GraphQL API for data sync
- [ ] Real-time subscriptions (optional)
- [ ] Data schema in cloud matches local DB
- [ ] API rate limiting and error handling
- [ ] Data backup and recovery

### Technical Notes

- Recommendation: Firebase (Authentication + Firestore) or Supabase
- API versioning strategy
- Security rules for multi-user access

### Testing Requirements

- API integration tests
- Authentication tests

### Dependencies

- Depends on US-5.1

### Notes

**This story is 13 points and should be split into smaller stories:**

- US-5.4a: Backend Setup & Auth (5 pts)
- US-5.4b: API Implementation (8 pts)
"@
        labels = @("priority/P0", "size/XXL", "epic/E5", "release/MVP-v1.0", "type/feature")
        milestone = "E5: Offline & Sync"
    },
    @{
        title = "US-5.5 - Sync Settings & Preferences"
        body = @"
### Description

As a **user**  
I want to **control sync settings**  
So that **I manage data usage and privacy**

### Acceptance Criteria

- [ ] Enable/disable automatic sync
- [ ] Sync only on WiFi option
- [ ] Sync frequency settings
- [ ] View sync history/log
- [ ] Clear sync queue
- [ ] Force full re-sync option

### Technical Notes

- Sync preferences stored locally
- Background sync respects preferences
- Sync log for debugging

### Testing Requirements

- Widget tests for settings UI
- Integration tests for sync behavior

### Dependencies

- Depends on US-5.3
"@
        labels = @("priority/P1", "size/M", "epic/E5", "release/v1.1", "type/feature")
        milestone = "E5: Offline & Sync"
    },
    
    # Epic 6: Family & Collaboration (6 issues)
    @{
        title = "US-6.1 - Household Profiles"
        body = @"
### Description

As a **user**  
I want to **create a household profile**  
So that **I can collaborate with family members**

### Acceptance Criteria

- [ ] Create household with name and description
- [ ] Invite family members via email or link
- [ ] Accept household invitations
- [ ] View household members
- [ ] Leave household
- [ ] Admin can remove members

### Technical Notes

- Household model: ``id``, ``name``, ``ownerId``, ``members[]``
- Invitation system with tokens
- Role-based permissions (admin, member)

### Testing Requirements

- Integration tests for household creation/joining

### Dependencies

- Related to US-5.4 (requires cloud backend)
"@
        labels = @("priority/P1", "size/L", "epic/E6", "release/v1.1", "type/feature")
        milestone = "E6: Family & Collaboration"
    },
    @{
        title = "US-6.2 - Shared Shopping Lists"
        body = @"
### Description

As a **household member**  
I want to **share shopping lists with my household**  
So that **anyone can add items and shop**

### Acceptance Criteria

- [ ] Mark shopping list as "shared with household"
- [ ] All household members can view and edit
- [ ] Real-time updates when others change list
- [ ] See who added each item (optional)
- [ ] Activity log for shared lists
- [ ] Unshare list (admin only)

### Technical Notes

- Real-time sync via Firestore listeners or WebSocket
- List ownership and permissions
- Conflict handling for concurrent edits

### Testing Requirements

- Integration tests for multi-user scenarios

### Dependencies

- Depends on US-6.1, US-5.3
"@
        labels = @("priority/P1", "size/L", "epic/E6", "release/v1.1", "type/feature")
        milestone = "E6: Family & Collaboration"
    },
    @{
        title = "US-6.3 - Collaborative Meal Planning"
        body = @"
### Description

As a **household member**  
I want to **plan meals together with my family**  
So that **everyone has input on weekly menu**

### Acceptance Criteria

- [ ] Shared meal calendar for household
- [ ] All members can add/edit meals
- [ ] Real-time updates on meal changes
- [ ] Comment/react on meal suggestions
- [ ] Vote on meal options (before finalizing)
- [ ] Notification when meal plan updated

### Technical Notes

- Shared meal plan model
- Voting system for meal selection
- Real-time collaboration features
- Conflict resolution for concurrent edits

### Testing Requirements

- Integration tests for collaborative scenarios

### Dependencies

- Depends on US-6.1, US-2.1
"@
        labels = @("priority/P1", "size/XL", "epic/E6", "release/v1.1", "type/feature")
        milestone = "E6: Family & Collaboration"
    },
    @{
        title = "US-6.4 - Family Member Preferences"
        body = @"
### Description

As a **household admin**  
I want to **set dietary preferences for family members**  
So that **meal planning considers everyone's needs**

### Acceptance Criteria

- [ ] Add family member profiles (name, age, dietary restrictions)
- [ ] Assign dietary preferences: vegetarian, allergies, dislikes
- [ ] Filter recipes compatible with all members
- [ ] Warning when recipe conflicts with member preference
- [ ] Schedule tracking (who's eating which meals)

### Technical Notes

- FamilyMember model: ``id``, ``name``, ``dietaryRestrictions[]``, ``allergies[]``, ``dislikes[]``
- Recipe compatibility checking
- Member presence tracking for meal planning

### Testing Requirements

- Unit tests for preference filtering

### Dependencies

- Depends on US-6.1
"@
        labels = @("priority/P1", "size/M", "epic/E6", "release/v1.1", "type/feature")
        milestone = "E6: Family & Collaboration"
    },
    @{
        title = "US-6.5 - Shopping Assignment"
        body = @"
### Description

As a **household member**  
I want to **assign shopping tasks to family members**  
So that **we coordinate who shops for what**

### Acceptance Criteria

- [ ] Assign shopping list (or items) to specific household member
- [ ] Notification when assigned to shop
- [ ] Mark assignment as complete
- [ ] View all assignments
- [ ] Reassign if needed

### Technical Notes

- Assignment model: ``listId``, ``assignedTo``, ``assignedBy``, ``status``, ``dueDate``
- Push notifications for assignments

### Testing Requirements

- Integration tests for assignment workflow

### Dependencies

- Depends on US-6.1, US-6.2
"@
        labels = @("priority/P2", "size/M", "epic/E6", "type/feature")
        milestone = "E6: Family & Collaboration"
    },
    @{
        title = "US-6.6 - Activity Feed"
        body = @"
### Description

As a **household member**  
I want to **see recent activity in my household**  
So that **I stay informed about changes**

### Acceptance Criteria

- [ ] Feed shows: new items added, meals planned, lists completed
- [ ] Filter by activity type
- [ ] See who performed each action
- [ ] Timestamp for each activity
- [ ] Mark activities as read
- [ ] Clear old activities

### Technical Notes

- Activity model: ``id``, ``type``, ``userId``, ``description``, ``timestamp``, ``metadata``
- Real-time feed updates
- Pagination for performance

### Testing Requirements

- Widget tests for feed display

### Dependencies

- Depends on US-6.1
"@
        labels = @("priority/P2", "size/M", "epic/E6", "type/feature")
        milestone = "E6: Family & Collaboration"
    },
    
    # Epic 7: Smart Features & AI (7 issues)
    @{
        title = "US-7.1 - Smart Recipe Suggestions"
        body = @"
### Description

As a **user**  
I want to **receive personalized recipe suggestions**  
So that **I discover new recipes I'll enjoy**

### Acceptance Criteria

- [ ] AI analyzes cooking history and favorites
- [ ] Suggest recipes based on available pantry items
- [ ] Consider seasonal ingredients
- [ ] Factor in dietary preferences
- [ ] "Try This Week" section with recommendations
- [ ] Feedback mechanism (liked/disliked suggestion)

### Technical Notes

- ML model for recommendations (collaborative filtering or content-based)
- May use cloud-based ML service (Google Cloud AI, AWS SageMaker)
- Feature engineering: user preferences, cooking frequency, ratings

### Testing Requirements

- Recommendation accuracy testing
- A/B testing for algorithm improvements

### Dependencies

- Depends on cooking history tracking
"@
        labels = @("priority/P1", "size/XL", "epic/E7", "release/v1.2", "type/feature")
        milestone = "E7: Smart Features & AI"
    },
    @{
        title = "US-7.2 - Leftover Recipe Suggestions"
        body = @"
### Description

As a **user**  
I want to **get recipe ideas using my leftovers**  
So that **I reduce food waste**

### Acceptance Criteria

- [ ] "Use Leftovers" feature in pantry
- [ ] Tag items as leftovers
- [ ] AI suggests recipes using leftover ingredients
- [ ] Prioritize recipes with multiple leftovers
- [ ] One-tap add recipe to meal plan

### Technical Notes

- Ingredient matching algorithm
- Recipe compatibility scoring
- May leverage external recipe APIs

### Testing Requirements

- Unit tests for matching logic

### Dependencies

- Depends on US-4.1, Recipe database
"@
        labels = @("priority/P1", "size/L", "epic/E7", "release/v1.2", "type/feature")
        milestone = "E7: Smart Features & AI"
    },
    @{
        title = "US-7.3 - Seasonal & Trending Recipes"
        body = @"
### Description

As a **user**  
I want to **discover seasonal and trending recipes**  
So that **I cook what's fresh and popular**

### Acceptance Criteria

- [ ] "Trending Now" section in recipe library
- [ ] "Seasonal Picks" based on current month
- [ ] Recipe popularity algorithm
- [ ] Community favorites (if recipe sharing enabled)
- [ ] Regional trending (based on user location)

### Technical Notes

- Recipe popularity metrics
- Seasonal ingredient database
- Cloud-based trending data

### Testing Requirements

- Algorithm validation

### Dependencies

None (or recipe sharing feature)
"@
        labels = @("priority/P2", "size/M", "epic/E7", "release/v1.2", "type/feature")
        milestone = "E7: Smart Features & AI"
    },
    @{
        title = "US-7.4 - Smart Grocery Categorization"
        body = @"
### Description

As a **user**  
I want to **have items auto-categorized intelligently**  
So that **I don't manually organize my lists**

### Acceptance Criteria

- [ ] AI learns from user's category assignments
- [ ] Auto-categorize new items based on patterns
- [ ] Improve accuracy over time
- [ ] Handle regional/store-specific layouts
- [ ] User can correct miscategorizations
- [ ] Corrections feed back into ML model

### Technical Notes

- ML classification model
- Training data from user corrections
- On-device ML (TensorFlow Lite) or cloud-based

### Testing Requirements

- Classification accuracy testing
- Performance testing

### Dependencies

- Depends on US-1.3
"@
        labels = @("priority/P1", "size/L", "epic/E7", "release/v1.2", "type/feature")
        milestone = "E7: Smart Features & AI"
    },
    @{
        title = "US-7.5 - Predictive Shopping Lists"
        body = @"
### Description

As a **user**  
I want to **have shopping list pre-populated based on patterns**  
So that **I save time on routine shopping**

### Acceptance Criteria

- [ ] AI analyzes shopping history
- [ ] Predict weekly recurring items
- [ ] Suggest list before user creates it
- [ ] "Smart Weekly List" feature
- [ ] User approval before adding predicted items
- [ ] Learn from accepted/rejected predictions

### Technical Notes

- Time-series analysis of shopping patterns
- Predictive algorithm (e.g., recurrent neural network)
- May require several weeks of data for accuracy

### Testing Requirements

- Prediction accuracy testing

### Dependencies

- Depends on shopping history data
"@
        labels = @("priority/P2", "size/XL", "epic/E7", "release/v1.2", "type/feature")
        milestone = "E7: Smart Features & AI"
    },
    @{
        title = "US-7.6 - Nutrition Insights"
        body = @"
### Description

As a **health-conscious user**  
I want to **see nutritional information for recipes and meal plans**  
So that **I make informed dietary choices**

### Acceptance Criteria

- [ ] Display calories, protein, carbs, fat per recipe
- [ ] Nutrition breakdown per serving
- [ ] Weekly nutrition summary from meal plan
- [ ] Track daily nutrition goals (optional)
- [ ] Filter recipes by nutrition criteria
- [ ] Nutrition database lookup for ingredients

### Technical Notes

- Nutrition API: USDA FoodData Central, Nutritionix, or Edamam
- Calculation logic for recipe totals
- Storage of nutrition data per recipe

### Testing Requirements

- Calculation accuracy tests

### Dependencies

- Depends on US-3.1
"@
        labels = @("priority/P2", "size/L", "epic/E7", "release/v1.2", "type/feature")
        milestone = "E7: Smart Features & AI"
    },
    @{
        title = "US-7.7 - Budget Tracking"
        body = @"
### Description

As a **budget-conscious user**  
I want to **track grocery spending**  
So that **I stay within budget**

### Acceptance Criteria

- [ ] Set monthly/weekly grocery budget
- [ ] Add prices to shopping list items (optional)
- [ ] Track spending per shopping trip
- [ ] Budget vs. actual spending comparison
- [ ] Spending trends over time
- [ ] Budget alerts when approaching limit
- [ ] Suggest budget-friendly recipes

### Technical Notes

- Budget model: ``period``, ``amount``, ``spent``, ``remaining``
- Price database for common items (optional)
- Charts for spending visualization

### Testing Requirements

- Unit tests for budget calculations
- Widget tests for UI

### Dependencies

None
"@
        labels = @("priority/P2", "size/L", "epic/E7", "release/v1.2", "type/feature")
        milestone = "E7: Smart Features & AI"
    },
    
    # Epic 8: User Settings & Privacy (5 issues)
    @{
        title = "US-8.1 - User Preferences"
        body = @"
### Description

As a **user**  
I want to **customize app settings**  
So that **the app works how I prefer**

### Acceptance Criteria

- [ ] Default measurement units (metric/imperial)
- [ ] Default household size
- [ ] First day of week (Monday/Sunday)
- [ ] Theme preference (light/dark/auto)
- [ ] Language selection
- [ ] Notification preferences
- [ ] Data usage settings (WiFi-only sync)

### Technical Notes

- Shared Preferences for settings storage
- Settings screen with categorized options
- Apply settings across app

### Testing Requirements

- Widget tests for settings UI

### Dependencies

None
"@
        labels = @("priority/P0", "size/S", "epic/E8", "release/MVP-v1.0", "type/feature")
        milestone = "E8: User Settings & Privacy"
    },
    @{
        title = "US-8.2 - Dietary Restrictions Profile"
        body = @"
### Description

As a **user**  
I want to **set my dietary restrictions and preferences**  
So that **recipe suggestions match my needs**

### Acceptance Criteria

- [ ] Select dietary restrictions: vegetarian, vegan, pescatarian, etc.
- [ ] Specify allergies
- [ ] List disliked ingredients
- [ ] Filter recipes automatically based on profile
- [ ] Warning when recipe violates restrictions

### Technical Notes

- User profile with dietary data
- Recipe filtering based on profile
- Ingredient exclusion lists

### Testing Requirements

- Unit tests for filtering logic

### Dependencies

None
"@
        labels = @("priority/P0", "size/S", "epic/E8", "release/MVP-v1.0", "type/feature")
        milestone = "E8: User Settings & Privacy"
    },
    @{
        title = "US-8.3 - Account Management"
        body = @"
### Description

As a **user**  
I want to **manage my account**  
So that **I control my profile and security**

### Acceptance Criteria

- [ ] View profile information
- [ ] Change email address
- [ ] Change password
- [ ] Enable two-factor authentication (optional)
- [ ] Connect social accounts (Google, Apple)
- [ ] View connected devices
- [ ] Sign out from all devices

### Technical Notes

- Authentication backend integration
- 2FA via SMS or authenticator app
- OAuth for social logins

### Testing Requirements

- Integration tests for account operations

### Dependencies

- Depends on US-5.4 (authentication)
"@
        labels = @("priority/P1", "size/M", "epic/E8", "release/v1.1", "type/feature")
        milestone = "E8: User Settings & Privacy"
    },
    @{
        title = "US-8.4 - Data Export & Import"
        body = @"
### Description

As a **user**  
I want to **export and import my data**  
So that **I can backup or migrate my information**

### Acceptance Criteria

- [ ] Export all data to JSON/CSV format
- [ ] Download export file
- [ ] Import data from file
- [ ] Preview import before confirming
- [ ] Merge or replace options on import
- [ ] Data validation during import

### Technical Notes

- Serialization of all user data
- File picker for import
- Data integrity checks

### Testing Requirements

- Integration tests for export/import

### Dependencies

None
"@
        labels = @("priority/P1", "size/L", "epic/E8", "release/v1.1", "type/feature")
        milestone = "E8: User Settings & Privacy"
    },
    @{
        title = "US-8.5 - Privacy & Data Deletion"
        body = @"
### Description

As a **user**  
I want to **control my privacy and delete my data**  
So that **I comply with my privacy preferences**

### Acceptance Criteria

- [ ] View privacy policy
- [ ] View data collection practices
- [ ] Opt out of analytics (optional)
- [ ] Delete account (with confirmation)
- [ ] Permanent data deletion from cloud
- [ ] Confirmation of deletion

### Technical Notes

- GDPR/CCPA compliance
- Hard delete vs. soft delete
- Data retention policies

### Testing Requirements

- Integration tests for deletion flow

### Dependencies

- Depends on US-5.4
"@
        labels = @("priority/P1", "size/M", "epic/E8", "release/v1.1", "type/feature")
        milestone = "E8: User Settings & Privacy"
    },
    
    # Epic 9: Onboarding & Help (4 issues)
    @{
        title = "US-9.1 - App Onboarding Flow"
        body = @"
### Description

As a **new user**  
I want to **be guided through app setup**  
So that **I understand how to use the app**

### Acceptance Criteria

- [ ] Welcome screen with app benefits
- [ ] Feature highlights (3-5 slides)
- [ ] Quick setup: dietary preferences, household size
- [ ] Option to skip onboarding
- [ ] Create first shopping list prompt
- [ ] Add sample recipe for demo

### Technical Notes

- Onboarding package: ``introduction_screen`` or custom
- Store onboarding completion status
- Sample data seeding

### Testing Requirements

- Widget tests for onboarding screens

### Dependencies

None
"@
        labels = @("priority/P0", "size/M", "epic/E9", "release/MVP-v1.0", "type/feature")
        milestone = "E9: Onboarding & Help"
    },
    @{
        title = "US-9.2 - In-App Help & Tutorials"
        body = @"
### Description

As a **user**  
I want to **access help documentation**  
So that **I can learn how to use features**

### Acceptance Criteria

- [ ] Help center with searchable articles
- [ ] Video tutorials (optional)
- [ ] FAQ section
- [ ] Feature tooltips (coach marks)
- [ ] "What's New" for app updates
- [ ] Feedback/support contact form

### Technical Notes

- Help content as markdown files or CMS
- Search functionality
- In-app webview or external link

### Testing Requirements

- Widget tests for help UI

### Dependencies

None
"@
        labels = @("priority/P1", "size/M", "epic/E9", "release/v1.1", "type/feature")
        milestone = "E9: Onboarding & Help"
    },
    @{
        title = "US-9.3 - Contextual Tips"
        body = @"
### Description

As a **user**  
I want to **see tips relevant to what I'm doing**  
So that **I discover features naturally**

### Acceptance Criteria

- [ ] Contextual tooltips on first use of features
- [ ] Dismiss tips permanently
- [ ] "Did you know?" tips on home screen
- [ ] Tips rotate based on user behavior
- [ ] Reset tips option in settings

### Technical Notes

- Tip tracking: which tips shown, dismissed
- Trigger logic for contextual display

### Testing Requirements

- Widget tests for tooltips

### Dependencies

None
"@
        labels = @("priority/P1", "size/S", "epic/E9", "release/v1.1", "type/feature")
        milestone = "E9: Onboarding & Help"
    },
    @{
        title = "US-9.4 - Empty States & Prompts"
        body = @"
### Description

As a **user**  
I want to **see helpful prompts when screens are empty**  
So that **I know what to do next**

### Acceptance Criteria

- [ ] Empty shopping list: "Tap + to add your first item"
- [ ] Empty recipes: "Import or create your first recipe"
- [ ] Empty meal plan: "Start planning your week"
- [ ] Empty pantry: "Track your pantry inventory"
- [ ] Illustrations or icons for visual appeal
- [ ] Action buttons in empty states

### Technical Notes

- Custom empty state widgets
- Illustrations from asset library

### Testing Requirements

- Widget tests for empty states

### Dependencies

None
"@
        labels = @("priority/P0", "size/S", "epic/E9", "release/MVP-v1.0", "type/feature")
        milestone = "E9: Onboarding & Help"
    }
)

# Create all issues
$created = 0
$failed = 0
$total = $issues.Count

Write-Host "Creating $total user stories..." -ForegroundColor Cyan
Write-Host ""

foreach ($issue in $issues) {
    $milestoneNum = $milestoneMap[$issue.milestone]
    
    $issueData = @{
        title = $issue.title
        body = $issue.body
        labels = $issue.labels
    }
    
    if ($milestoneNum) {
        $issueData.milestone = $milestoneNum
    }
    
    Write-Host "Creating: $($issue.title)" -ForegroundColor Yellow
    $result = Invoke-GitHubAPI -Method POST -Endpoint "/repos/$REPO_OWNER/$REPO_NAME/issues" -Body $issueData
    
    if ($result) {
        Write-Host "  ✓ Created issue #$($result.number)" -ForegroundColor Green
        $created++
    }
    else {
        Write-Host "  ✗ Failed or already exists" -ForegroundColor Red
        $failed++
    }
    
    # Rate limiting: sleep briefly between requests
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total user stories: $total" -ForegroundColor Cyan
Write-Host "Created: $created" -ForegroundColor Green
Write-Host "Failed/Skipped: $failed" -ForegroundColor Yellow
Write-Host ""
Write-Host "View at: https://github.com/$REPO_OWNER/$REPO_NAME/issues" -ForegroundColor Cyan
Write-Host ""
