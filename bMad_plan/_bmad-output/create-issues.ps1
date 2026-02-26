# GitHub Issues Creator using REST API
# Configuration
$REPO_OWNER = "galcin"
$REPO_NAME = "shop_list_app"
$GITHUB_TOKEN = "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"
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
Write-Host " GitHub Issues Creator" -ForegroundColor Cyan
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

# Ask for confirmation
Write-Host "This will create labels, milestones, and issues" -ForegroundColor Yellow
$confirmation = Read-Host "Continue? (yes/no)"
if ($confirmation -ne "yes" -and $confirmation -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Create Labels
Write-Host "Creating labels..." -ForegroundColor Cyan
$labels = @(
    @{name="priority/P0"; color="d73a4a"; description="Critical, MVP requirement"},
    @{name="priority/P1"; color="ff9800"; description="High, core feature"},
    @{name="priority/P2"; color="fbca04"; description="Medium, important"},
    @{name="priority/P3"; color="0e8a16"; description="Low, nice-to-have"},
    @{name="size/XS"; color="c5def5"; description="1 point"},
    @{name="size/S"; color="c5def5"; description="2 points"},
    @{name="size/M"; color="c5def5"; description="3 points"},
    @{name="size/L"; color="c5def5"; description="5 points"},
    @{name="size/XL"; color="c5def5"; description="8 points"},
    @{name="size/XXL"; color="c5def5"; description="13 points"},
    @{name="epic/E1"; color="7057ff"; description="Shopping List Management"},
    @{name="epic/E2"; color="7057ff"; description="Meal Planning"},
    @{name="epic/E3"; color="7057ff"; description="Recipe Management"},
    @{name="epic/E4"; color="7057ff"; description="Pantry & Inventory"},
    @{name="epic/E5"; color="7057ff"; description="Offline & Sync"},
    @{name="epic/E6"; color="7057ff"; description="Family & Collaboration"},
    @{name="epic/E7"; color="7057ff"; description="Smart Features & AI"},
    @{name="epic/E8"; color="7057ff"; description="User Settings & Privacy"},
    @{name="epic/E9"; color="7057ff"; description="Onboarding & Help"},
    @{name="release/MVP-v1.0"; color="1d76db"; description="MVP Release"},
    @{name="release/v1.1"; color="1d76db"; description="v1.1 Release"},
    @{name="release/v1.2"; color="1d76db"; description="v1.2 Release"},
    @{name="type/feature"; color="0052cc"; description="New feature"},
    @{name="type/enhancement"; color="84b6eb"; description="Enhancement"},
    @{name="status/blocked"; color="e11d21"; description="Blocked"}
)

$created = 0
foreach ($label in $labels) {
    $result = Invoke-GitHubAPI -Method POST -Endpoint "/repos/$REPO_OWNER/$REPO_NAME/labels" -Body $label
    if ($result) {
        Write-Host "  Created: $($label.name)" -ForegroundColor Green
        $created++
    }
    else {
        Write-Host "  Exists: $($label.name)" -ForegroundColor Gray
    }
}
Write-Host "Labels created: $created" -ForegroundColor Green
Write-Host ""

# Create Milestones
Write-Host "Creating milestones..." -ForegroundColor Cyan
$milestones = @(
    @{title="E1: Shopping List Management"; description="8 issues, 31 points"},
    @{title="E2: Meal Planning"; description="7 issues, 38 points"},
    @{title="E3: Recipe Management"; description="9 issues, 45 points"},
    @{title="E4: Pantry & Inventory"; description="6 issues, 29 points"},
    @{title="E5: Offline & Sync"; description="5 issues, 34 points"},
    @{title="E6: Family & Collaboration"; description="6 issues, 27 points"},
    @{title="E7: Smart Features & AI"; description="7 issues, 41 points"},
    @{title="E8: User Settings & Privacy"; description="5 issues, 18 points"},
    @{title="E9: Onboarding & Help"; description="4 issues, 15 points"}
)

$created = 0
foreach ($milestone in $milestones) {
    $result = Invoke-GitHubAPI -Method POST -Endpoint "/repos/$REPO_OWNER/$REPO_NAME/milestones" -Body $milestone
    if ($result) {
        Write-Host "  Created: $($milestone.title)" -ForegroundColor Green
        $created++
    }
    else {
        Write-Host "  Exists: $($milestone.title)" -ForegroundColor Gray
    }
}
Write-Host "Milestones created: $created" -ForegroundColor Green
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

# Create sample issues (first 5 from Epic 1)
Write-Host "Creating issues..." -ForegroundColor Cyan

$issues = @(
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
    }
)

$created = 0
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
        Write-Host "  Created issue #$($result.number)" -ForegroundColor Green
        $created++
        Start-Sleep -Milliseconds 300
    }
    else {
        Write-Host "  Failed or exists" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Created $created sample issues" -ForegroundColor Green
Write-Host "View at: https://github.com/$REPO_OWNER/$REPO_NAME/issues" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: This script created first 3 issues as a test." -ForegroundColor Yellow
Write-Host "To create all 57 issues, you can:" -ForegroundColor Yellow
Write-Host "1. Use this script as template and add all issue data" -ForegroundColor Yellow
Write-Host "2. Or create remaining issues manually from github-issues.md" -ForegroundColor Yellow
Write-Host ""
