# GitHub Issues Setup Guide

This guide explains how to migrate your GitHub repository from the old epics structure to the new **Architecture-Aligned Clean Architecture** structure.

## Overview

The new architecture follows:

- **Clean Architecture** (Domain → Data → Presentation layers)
- **Offline-First** with Drift database
- **Riverpod** for state management
- **21 Epics** across 5 phases (Foundation → Data → Domain → Presentation → Sync/Polish)

---

## Prerequisites

### 1. Install GitHub CLI

Download and install from: https://cli.github.com/

**Windows (PowerShell):**

```powershell
winget install --id GitHub.cli
```

**macOS:**

```bash
brew install gh
```

**Linux:**

```bash
sudo apt install gh
```

### 2. Authenticate with GitHub

```powershell
gh auth login
```

Follow the prompts to authenticate.

### 3. Update Repository Configuration

Edit both scripts to set your repository details:

**In `delete-all-issues.ps1`:**

```powershell
$REPO_OWNER = "your-username"  # Replace with your GitHub username
$REPO_NAME = "shop-list-app"   # Replace with your repository name
```

**In `create-new-architecture-issues.ps1`:**

```powershell
$REPO_OWNER = "your-username"  # Replace with your GitHub username
$REPO_NAME = "shop-list-app"   # Replace with your repository name
```

---

## Migration Steps

### Step 1: Backup Existing Issues (Optional)

If you want to preserve existing issues before closing them:

```powershell
# Export all issues to JSON
gh issue list --repo your-username/shop-list-app --state all --limit 1000 --json number,title,body,labels > issues-backup.json
```

### Step 2: Close Old Issues

⚠️ **Warning**: This will close ALL existing issues in your repository!

```powershell
# Run the deletion script
.\delete-all-issues.ps1
```

You will be prompted to type `DELETE ALL` to confirm.

**What it does:**

- Closes all open and closed issues
- Adds a comment: "Closing to reorganize issues based on new architecture"
- Issues are closed, not permanently deleted (can be reopened if needed)

### Step 3: Clean Up Old Labels and Milestones (Optional)

The new script will create new labels and milestones, but won't delete old ones. To clean up:

1. Go to your repository on GitHub
2. Navigate to **Issues → Labels**
3. Manually delete old labels (or keep them if you prefer)
4. Navigate to **Issues → Milestones**
5. Manually delete old milestones

### Step 4: Create New Architecture-Aligned Issues

```powershell
# Run the creation script
.\create-new-architecture-issues.ps1
```

**What it does:**

1. Creates all new labels (priorities, sizes, phases, epics, layers)
2. Creates 21 milestones (one for each epic)
3. Creates issues for Phase 0 and Phase 1 (examples included in script)

**Note**: The provided script includes **Phase 0 (E0)** and **Phase 1 Epic E1** as fully implemented examples. You can extend the script to create all remaining epics by following the same pattern.

---

## New Label Structure

### Priority Labels

- `priority/P0` - Critical - MVP blocker
- `priority/P1` - High - Core feature for product-market fit
- `priority/P2` - Medium - Important enhancement
- `priority/P3` - Low - Nice-to-have

### Size Labels (Story Points)

- `size/1` - 1-2 hours
- `size/2` - Half day
- `size/3` - Full day
- `size/5` - 2-3 days
- `size/8` - 3-5 days
- `size/13` - 1-2 weeks (needs splitting)

### Phase Labels

- `phase/0-foundation` - Foundation & Infrastructure
- `phase/1-data` - Data Layer
- `phase/2-domain` - Domain Layer
- `phase/3-presentation` - Presentation Layer
- `phase/4-sync` - Cloud Sync & Collaboration (Post-MVP)
- `phase/5-polish` - Performance & Polish

### Epic Labels

- `epic/E0` through `epic/E21` - One for each epic

### Architecture Layer Labels

- `layer/domain` - Domain layer (entities, business logic)
- `layer/data` - Data layer (repositories, data sources)
- `layer/presentation` - Presentation layer (UI, state)
- `layer/infrastructure` - Infrastructure (database, network)

### Release Labels

- `release/MVP-v1.0` - MVP Release (Offline-First)
- `release/v1.1` - v1.1 Release (Cloud Sync)
- `release/v1.2` - v1.2 Release (Smart Features)

### Type Labels

- `type/feature` - New feature
- `type/enhancement` - Enhancement
- `type/technical` - Technical task (no user-facing change)

### Status Labels

- `status/blocked` - Blocked by dependencies
- `status/in-progress` - Currently in progress
- `status/needs-review` - Needs code review

---

## New Milestone Structure

### MVP Scope (Weeks 1-11)

**Phase 0: Foundation**

- E0: Foundation & Infrastructure (7 stories, 34 points) - Week 1-2

**Phase 1: Data Layer**

- E1: Recipe Data Layer (6 stories, 26 points) - Week 2-3
- E2: Shopping List Data Layer (5 stories, 21 points) - Week 3
- E3: Meal Plan Data Layer (5 stories, 20 points) - Week 3-4
- E4: Pantry Data Layer (5 stories, 19 points) - Week 4

**Phase 2: Domain Layer**

- E5: Recipe Use Cases (7 stories, 28 points) - Week 4-5
- E6: Shopping List Use Cases (6 stories, 24 points) - Week 5-6
- E7: Meal Planning Use Cases (6 stories, 26 points) - Week 6
- E8: Pantry Use Cases (5 stories, 21 points) - Week 6-7

**Phase 3: Presentation Layer**

- E9: Core UI Components & Theme (6 stories, 22 points) - Week 7
- E10: Shopping List UI (6 stories, 24 points) - Week 7-8
- E11: Recipe Management UI (7 stories, 29 points) - Week 8-9
- E12: Meal Planning UI (6 stories, 26 points) - Week 9-10
- E13: Pantry Inventory UI (5 stories, 21 points) - Week 10
- E14: Settings & Data Management (5 stories, 20 points) - Week 11

### Post-MVP Scope

**Phase 4: Cloud Sync & Collaboration**

- E15: Sync Engine & Queue (7 stories, 35 points) - Week 12-13
- E16: Cloud Backend Integration (8 stories, 40 points) - Week 13-15
- E17: Authentication & Security (6 stories, 29 points) - Week 15-16
- E18: Family & Collaboration (6 stories, 27 points) - Week 16-17

**Phase 5: Performance & Polish**

- E19: Performance Optimization (6 stories, 26 points) - Week 17-18
- E20: Smart Features & AI (7 stories, 38 points) - Week 18-20
- E21: Testing & Quality Assurance (8 stories, 32 points) - Continuous

---

## Epic Structure

Each epic follows Clean Architecture layers:

### Data Layer Epics (E1-E4)

Each data epic includes:

1. Domain Entities (pure Dart classes)
2. Drift Table & Model (database schema + freezed models)
3. Local Data Source (Drift queries)
4. Repository Interface (in domain layer)
5. Repository Implementation (in data layer)
6. Riverpod Providers

### Domain Layer Epics (E5-E8)

Each domain epic includes:

1. Use Case implementations (business logic)
2. Input validation
3. Use Case providers

### Presentation Layer Epics (E9-E14)

Each presentation epic includes:

1. Pages/Screens
2. Widgets
3. State Providers (Riverpod StateNotifiers)
4. Form handling

---

## Extending the Script

The provided `create-new-architecture-issues.ps1` includes complete examples for:

- ✅ Epic E0 (all 7 stories)
- ✅ Epic E1 (all 6 stories)

To create issues for remaining epics (E2-E21), copy the pattern and add sections for each story. For example:

```powershell
# Epic E2: Shopping List Data Layer
Write-Host "Creating Epic E2: Shopping List Data Layer..." -ForegroundColor Magenta

# US-E2.1
$body = @"
### Description

**As a** developer
**I want to** define ShoppingList and ShoppingItem domain entities
**So that** business logic has clear shopping data structures

### Story Points
3

### Acceptance Criteria
- [ ] ShoppingList entity created
- [ ] ShoppingItem value object created
- [ ] Business methods implemented

### Dependencies
- US-E0.1: Project Setup
"@

if (Create-Issue -title "US-E2.1: Shopping List Domain Entities" -body $body -labels @("priority/P0","size/3","epic/E2","phase/1-data","release/MVP-v1.0","type/feature","layer/domain") -milestone "E2: Shopping List Data Layer") {
    $createdCount++
} else {
    $failedCount++
}

# Continue with US-E2.2, E2.3, etc...
```

---

## Verification

After running the scripts, verify:

1. **Labels Created**: Go to **Issues → Labels** and verify all labels exist
2. **Milestones Created**: Go to **Issues → Milestones** and verify 21 milestones
3. **Issues Created**: Go to **Issues** and filter by milestones to verify stories
4. **Dependencies**: Check that dependency references are correct

---

## Project Board Setup (Optional)

Consider creating a GitHub Project Board to track progress:

1. Go to your repository → **Projects** → **New project**
2. Choose **Board** view
3. Create columns:
   - Backlog
   - Ready
   - In Progress
   - In Review
   - Done
4. Add automation:
   - Move to "In Progress" when issue is assigned
   - Move to "Done" when issue is closed
5. Add all created issues to the board

---

## Sprint Planning

With 2 developers and 2-week sprints:

- **Sprint 1-2**: Phase 0 (E0)
- **Sprint 3-4**: Phase 1 (E1-E4)
- **Sprint 5-7**: Phase 2 (E5-E8)
- **Sprint 8-12**: Phase 3 (E9-E14)
- **Sprints 13+**: Post-MVP (E15-E21)

---

## Troubleshooting

### "gh: command not found"

- Install GitHub CLI (see Prerequisites)
- Restart terminal after installation

### "Not authenticated with GitHub CLI"

```powershell
gh auth login
```

### "Failed to create issue"

- Check repository name is correct
- Verify you have write access to the repository
- Check if milestone exists

### "Failed to create label: already exists"

- This is normal, labels are reused if they exist
- Script will show "Exists" instead of "Created"

---

## Rollback Plan

If you need to rollback:

1. **Reopen closed issues**:

   ```powershell
   gh issue list --repo your-username/shop-list-app --state closed --limit 100 --json number | ConvertFrom-Json | ForEach-Object { gh issue reopen $_.number --repo your-username/shop-list-app }
   ```

2. **Delete new issues** (if needed):
   - Manually delete via GitHub web interface
   - Or create a script to close issues with specific labels

---

## Support

For questions or issues:

1. Check GitHub CLI documentation: https://cli.github.com/manual/
2. Review the architecture document: `epics-and-stories-FINAL-architecture-aligned.md`
3. Verify your repository settings and permissions

---

**Good luck with your architecture-aligned development! 🚀**
