# PowerShell Script to Create GitHub Issues from github-issues.md
# Prerequisites: Install GitHub CLI (gh) from https://cli.github.com/

# Configuration - UPDATE THESE VALUES
$REPO_OWNER = "your-username"  # Replace with your GitHub username
$REPO_NAME = "shop-list-app"   # Replace with your repository name
$REPO = "$REPO_OWNER/$REPO_NAME"

# Check if gh CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: GitHub CLI (gh) is not installed." -ForegroundColor Red
    Write-Host "Install from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

# Check if authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not authenticated with GitHub CLI" -ForegroundColor Red
    Write-Host "Run: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== GitHub Issues Creator ===" -ForegroundColor Cyan
Write-Host "Repository: $REPO" -ForegroundColor Green
Write-Host ""

# Function to create labels
function Create-Labels {
    Write-Host "Creating labels..." -ForegroundColor Yellow
    
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
    
    foreach ($label in $labels) {
        gh label create $label.name --color $label.color --description $label.description --repo $REPO 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Created: $($label.name)" -ForegroundColor Green
        } else {
            Write-Host "  - Exists: $($label.name)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Function to create milestones
function Create-Milestones {
    Write-Host "Creating milestones..." -ForegroundColor Yellow
    
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
    
    foreach ($milestone in $milestones) {
        gh api repos/$REPO/milestones -f title="$($milestone.title)" -f description="$($milestone.description)" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Created: $($milestone.title)" -ForegroundColor Green
        } else {
            Write-Host "  - Exists: $($milestone.title)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Function to create a single issue
function Create-Issue {
    param(
        [string]$title,
        [string]$body,
        [string[]]$labels,
        [string]$milestone
    )
    
    $labelsArg = $labels -join ","
    
    # Get milestone number
    $milestoneNumber = (gh api repos/$REPO/milestones --jq ".[] | select(.title == `"$milestone`") | .number")
    
    if ($milestoneNumber) {
        gh issue create --repo $REPO --title $title --body $body --label $labelsArg --milestone $milestoneNumber
    } else {
        gh issue create --repo $REPO --title $title --body $body --label $labelsArg
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Created: $title" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ Failed: $title" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "Step 1: Creating Labels" -ForegroundColor Cyan
Create-Labels

Write-Host "Step 2: Creating Milestones" -ForegroundColor Cyan
Create-Milestones

Write-Host "Step 3: Creating Issues" -ForegroundColor Cyan
Write-Host "NOTE: This is a template script. You'll need to parse github-issues.md" -ForegroundColor Yellow
Write-Host "      or create issues manually using the examples below." -ForegroundColor Yellow
Write-Host ""

# Example issue creation (you would parse github-issues.md to get these values)
$exampleBody = @"
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

Write-Host "Example command to create an issue:" -ForegroundColor Cyan
Write-Host @"
gh issue create --repo $REPO \
  --title "US-1.1 - Create and Manage Shopping Lists" \
  --body "$exampleBody" \
  --label "priority/P0,size/M,epic/E1,release/MVP-v1.0,type/feature" \
  --milestone "E1: Shopping List Management"
"@ -ForegroundColor Gray

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host "Labels and milestones are created." -ForegroundColor Green
Write-Host "You can now create issues manually or extend this script to parse github-issues.md" -ForegroundColor Yellow
