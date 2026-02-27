# ============================================================
#  GitHub Issues Creator
#  Parses epics-and-stories-FINAL-architecture-aligned.md
#  and creates labels, milestones, and issues via GitHub CLI.
#
#  Prerequisites:
#    - GitHub CLI installed : https://cli.github.com/
#    - Authenticated        : gh auth login
#
#  Usage:
#    .\create-issues-from-epics.ps1 -RepoOwner "galcin" -RepoName "shop_list_app"
#
#  Optional flags:
#    -SkipLabels       Skip label creation
#    -SkipMilestones   Skip milestone creation
#    -DryRun           Preview without touching GitHub
#    -EpicFilter "E0"  Only process one epic
#    -MVPOnly          Only Phases 0-3 (E0-E14)
# ============================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]  [string]$RepoOwner,
    [Parameter(Mandatory = $true)]  [string]$RepoName,
    [string]$EpicsFile = "",
    [switch]$SkipLabels,
    [switch]$SkipMilestones,
    [switch]$DryRun,
    [string]$EpicFilter = "",
    [switch]$MVPOnly
)

# Resolve path: if blank use default relative to script; if relative, resolve from script directory
if ([string]::IsNullOrEmpty($EpicsFile)) {
    $EpicsFile = Join-Path $PSScriptRoot ".." | Join-Path -ChildPath "_bmad-output" | Join-Path -ChildPath "docs" | Join-Path -ChildPath "epics-user-stories" | Join-Path -ChildPath "epics-and-stories-FINAL-architecture-aligned.md"
    $EpicsFile = [IO.Path]::GetFullPath($EpicsFile)
} elseif (-not [IO.Path]::IsPathRooted($EpicsFile)) {
    $EpicsFile = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot $EpicsFile))
}

# --- Sanity Checks -------------------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: GitHub CLI (gh) is not installed." -ForegroundColor Red
    Write-Host "       Install from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

$null = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not authenticated. Run: gh auth login" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $EpicsFile)) {
    Write-Host "ERROR: Epics file not found:" -ForegroundColor Red
    Write-Host "       $EpicsFile" -ForegroundColor Yellow
    exit 1
}

$REPO = "$RepoOwner/$RepoName"

Write-Host ""
Write-Host "=== GitHub Issues Creator ===" -ForegroundColor Cyan
Write-Host "  Repository : $REPO" -ForegroundColor Green
Write-Host "  Source     : $EpicsFile" -ForegroundColor Green
if ($DryRun)  { Write-Host "  ** DRY RUN - no changes will be made **" -ForegroundColor Yellow }
if ($MVPOnly) { Write-Host "  ** MVP ONLY (Phases 0-3) **" -ForegroundColor Yellow }
Write-Host ""

# --- Helper: invoke gh or dry-run ----------------------------
function Invoke-Gh ([string[]]$GhArgs) {
    if ($DryRun) {
        Write-Host "  [DRY-RUN] gh $($GhArgs -join ' ')" -ForegroundColor DarkGray
        return 0
    }
    & gh @GhArgs
    return $LASTEXITCODE
}

# --- Phase label map -----------------------------------------
$PhaseLabel = @{
    "0" = "phase/0-foundation"
    "1" = "phase/1-data"
    "2" = "phase/2-domain"
    "3" = "phase/3-presentation"
    "4" = "phase/4-sync"
    "5" = "phase/5-polish"
}

$MVPEpics = @("E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","E10","E11","E12","E13","E14")

# --- 1. Create Labels ----------------------------------------
function Create-Labels {
    Write-Host "Creating labels..." -ForegroundColor Yellow

    $labels = @(
        @{ name="priority/P0"; color="d73a4a"; description="Critical - MVP blocker" },
        @{ name="priority/P1"; color="ff9800"; description="High - Core feature" },
        @{ name="priority/P2"; color="fbca04"; description="Medium - Enhancement" },
        @{ name="priority/P3"; color="0e8a16"; description="Low - Nice-to-have" },
        @{ name="size/1";  color="c5def5"; description="1 point - 1-2 hours" },
        @{ name="size/2";  color="c5def5"; description="2 points - Half day" },
        @{ name="size/3";  color="c5def5"; description="3 points - Full day" },
        @{ name="size/4";  color="c5def5"; description="4 points - 1-2 days" },
        @{ name="size/5";  color="c5def5"; description="5 points - 2-3 days" },
        @{ name="size/8";  color="c5def5"; description="8 points - 3-5 days" },
        @{ name="size/13"; color="c5def5"; description="13 points - 1-2 weeks" },
        @{ name="phase/0-foundation";   color="6a0dad"; description="Phase 0: Foundation" },
        @{ name="phase/1-data";         color="7057ff"; description="Phase 1: Data Layer" },
        @{ name="phase/2-domain";       color="8b7fff"; description="Phase 2: Domain Layer" },
        @{ name="phase/3-presentation"; color="a599ff"; description="Phase 3: Presentation" },
        @{ name="phase/4-sync";         color="bfb3ff"; description="Phase 4: Cloud Sync" },
        @{ name="phase/5-polish";       color="d9ccff"; description="Phase 5: Performance & Polish" },
        @{ name="layer/domain";         color="1d76db"; description="Domain layer" },
        @{ name="layer/data";           color="1d76db"; description="Data layer" },
        @{ name="layer/presentation";   color="1d76db"; description="Presentation layer" },
        @{ name="layer/infrastructure"; color="1d76db"; description="Infrastructure" },
        @{ name="release/MVP-v1.0"; color="1d76db"; description="MVP Release" },
        @{ name="release/v1.1";     color="1d76db"; description="v1.1 Cloud Sync" },
        @{ name="release/v1.2";     color="1d76db"; description="v1.2 Smart Features" },
        @{ name="type/feature";     color="0052cc"; description="New feature" },
        @{ name="type/technical";   color="5319e7"; description="Technical task" },
        @{ name="type/enhancement"; color="84b6eb"; description="Enhancement" },
        @{ name="status/blocked";      color="e11d21"; description="Blocked" },
        @{ name="status/in-progress";  color="fbca04"; description="In progress" },
        @{ name="status/needs-review"; color="0e8a16"; description="Needs review" }
    )

    $epicNames = @{
        "E0"="Foundation & Infrastructure"; "E1"="Recipe Data Layer"
        "E2"="Shopping List Data Layer";    "E3"="Meal Plan Data Layer"
        "E4"="Pantry Data Layer";           "E5"="Recipe Use Cases"
        "E6"="Shopping List Use Cases";     "E7"="Meal Planning Use Cases"
        "E8"="Pantry Use Cases";            "E9"="Core UI Components & Theme"
        "E10"="Shopping List UI";           "E11"="Recipe Management UI"
        "E12"="Meal Planning UI";           "E13"="Pantry Inventory UI"
        "E14"="Settings & Data Management"; "E15"="Sync Engine & Queue"
        "E16"="Cloud Backend Integration";  "E17"="Authentication & Security"
        "E18"="Family & Collaboration";     "E19"="Performance Optimization"
        "E20"="Smart Features & AI";        "E21"="Testing & Quality Assurance"
    }
    foreach ($k in $epicNames.Keys) {
        $labels += @{ name="epic/$k"; color="7057ff"; description="${k}: $($epicNames[$k])" }
    }

    foreach ($label in $labels) {
        $rc = Invoke-Gh @("label","create",$label.name,"--color",$label.color,"--description",$label.description,"--repo",$REPO,"--force")
        if ($DryRun -or $rc -eq 0) {
            Write-Host "  OK  $($label.name)" -ForegroundColor Green
        } else {
            Write-Host "  --  $($label.name) (exists/skipped)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# --- 2. Parse markdown file ----------------------------------
function Parse-EpicsDoc ([string]$Path) {
    $lines   = Get-Content -LiteralPath $Path -Encoding UTF8
    $epics   = New-Object System.Collections.Generic.List[hashtable]
    $stories = New-Object System.Collections.Generic.List[hashtable]

    $curPhase  = ""
    $curEpic   = $null
    $curStory  = $null
    $bodyLines = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {

        # Phase heading: ## PHASE 0:
        if ($line -match '^## PHASE (\d+):') {
            $curPhase = $Matches[1]
            continue
        }

        # Epic heading: ### Epic E0: Title
        if ($line -match '^### Epic (E\d+): (.+)$') {
            if ($null -ne $curStory) {
                $curStory.Body = ($bodyLines -join "`n").Trim()
                $stories.Add($curStory)
                $curStory = $null
                $bodyLines.Clear()
            }
            $curEpic = @{
                Id          = $Matches[1].Trim()
                Title       = $Matches[2].Trim()
                Phase       = $curPhase
                Description = ""
            }
            $epics.Add($curEpic)
            continue
        }

        # Epic goal line
        if ($null -ne $curEpic -and $null -eq $curStory -and $line -match '^\*\*Epic Goal:\*\*\s*(.+)$') {
            $curEpic.Description = $Matches[1].Trim()
            continue
        }

        # Full story heading: #### US-E0.1: Title
        if ($line -match '^#### (US-E[\d.]+): (.+)$') {
            if ($null -ne $curStory) {
                $curStory.Body = ($bodyLines -join "`n").Trim()
                $stories.Add($curStory)
            }
            $storyId    = $Matches[1].Trim()
            $storyTitle = $Matches[2].Trim()
            $epicIdVal  = if ($null -ne $curEpic) { $curEpic.Id } else { "" }
            $curStory = @{
                Id           = $storyId
                Title        = $storyTitle
                EpicId       = $epicIdVal
                Phase        = $curPhase
                Points       = 0
                Priority     = ""
                Dependencies = ""
                Body         = ""
                IsStub       = $false
            }
            $bodyLines.Clear()
            $bodyLines.Add("### $storyId - $storyTitle`n")
            continue
        }

        # Stub story bullet: - US-E3.1: Title
        if ($null -ne $curEpic -and $null -eq $curStory -and $line -match '^- (US-E[\d.]+):\s*(.+)$') {
            $storyId    = $Matches[1].Trim()
            $storyTitle = $Matches[2].Trim()
            $stubStory = @{
                Id           = $storyId
                Title        = $storyTitle
                EpicId       = $curEpic.Id
                Phase        = $curPhase
                Points       = 0
                Priority     = ""
                Dependencies = ""
                Body         = "### $storyId - $storyTitle"
                IsStub       = $true
            }
            $stories.Add($stubStory)
            continue
        }

        # Story metadata: **Story Points:** 5 | **Priority:** P0 | **Dependencies:** None
        if ($null -ne $curStory -and
            $line -match '\*\*Story Points:\*\*\s*(\d+)\s*\|\s*\*\*Priority:\*\*\s*(P\d)\s*\|\s*\*\*Dependencies:\*\*\s*(.+)') {
            $curStory.Points       = [int]$Matches[1]
            $curStory.Priority     = $Matches[2].Trim()
            $curStory.Dependencies = $Matches[3].Trim()
            $bodyLines.Add($line)
            continue
        }

        # Accumulate body
        if ($null -ne $curStory) {
            $bodyLines.Add($line)
        }
    }

    # flush last story
    if ($null -ne $curStory) {
        $curStory.Body = ($bodyLines -join "`n").Trim()
        $stories.Add($curStory)
    }

    return @{ Epics=$epics; Stories=$stories }
}

# --- 3. Create Milestones ------------------------------------
function Create-Milestones ([System.Collections.Generic.List[hashtable]]$Epics) {
    Write-Host "Creating milestones..." -ForegroundColor Yellow
    foreach ($epic in $Epics) {
        if ($EpicFilter -ne "" -and $epic.Id -ne $EpicFilter) { continue }
        if ($MVPOnly -and $MVPEpics -notcontains $epic.Id)     { continue }

        $title = "$($epic.Id): $($epic.Title)"
        $rc = Invoke-Gh @("api","repos/$REPO/milestones",
                          "--method","POST",
                          "--field","title=$title",
                          "--field","description=$($epic.Description)",
                          "--field","state=open")
        if ($DryRun -or $rc -eq 0) {
            Write-Host "  OK  Milestone: $title" -ForegroundColor Green
        } else {
            Write-Host "  --  Exists: $title" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# --- 4. (milestone number lookup removed - gh accepts title string directly) --

# --- 5. Create Issues ----------------------------------------
function Create-Issues (
    [System.Collections.Generic.List[hashtable]]$Stories,
    [System.Collections.Generic.List[hashtable]]$Epics
) {
    Write-Host "Creating issues..." -ForegroundColor Yellow

    $total = 0
    $created = 0
    $failed = 0
    $tmpFile = [IO.Path]::GetTempFileName()

    foreach ($story in $Stories) {
        if ($EpicFilter -ne "" -and $story.EpicId -ne $EpicFilter) { continue }
        if ($MVPOnly -and $MVPEpics -notcontains $story.EpicId)     { continue }
        $total++

        $labels = New-Object System.Collections.Generic.List[string]
        if ($story.Priority -ne "") { $labels.Add("priority/$($story.Priority)") }
        if ($story.Points   -gt 0)  { $labels.Add("size/$($story.Points)") }
        if ($story.EpicId   -ne "") { $labels.Add("epic/$($story.EpicId)") }
        if ($PhaseLabel[$story.Phase]) { $labels.Add($PhaseLabel[$story.Phase]) }
        $labels.Add("type/feature")

        $body  = $story.Body + "`n`n---`n"
        $body += "**Epic:** $($story.EpicId)  `n"
        $body += "**Story Points:** $($story.Points)  `n"
        $body += "**Priority:** $($story.Priority)  `n"
        if ($story.Dependencies -and $story.Dependencies -ne "None") {
            $body += "**Dependencies:** $($story.Dependencies)  `n"
        }
        if ($story.IsStub) {
            $body += "`n> _This story is a backlog stub. Full acceptance criteria to be defined during sprint planning._`n"
        }

        $issueTitle = "[$($story.Id)] $($story.Title)"

        $epicTitle = ($Epics | Where-Object { $_.Id -eq $story.EpicId } | Select-Object -First 1).Title
        $msTitle   = "$($story.EpicId): $epicTitle"

        if ($DryRun) {
            Write-Host "  [DRY-RUN] $issueTitle" -ForegroundColor DarkGray
            $created++
            continue
        }

        # Write body to temp file to avoid shell-escaping issues
        Set-Content -LiteralPath $tmpFile -Value $body -Encoding UTF8

        $ghArgs = @(
            "issue","create",
            "--repo",      $REPO,
            "--title",     $issueTitle,
            "--body-file", $tmpFile,
            "--label",     ($labels -join ",")
        )
        if ($story.EpicId -ne "" -and $epicTitle) {
            $ghArgs += @("--milestone", $msTitle)
        }

        Write-Host "  $($story.Id) - $($story.Title)" -NoNewline -ForegroundColor White
        $out = & gh @ghArgs 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  -> $out" -ForegroundColor Green
            $created++
        } else {
            Write-Host " FAILED" -ForegroundColor Red
            Write-Host "    $out" -ForegroundColor DarkRed
            $failed++
        }

        Start-Sleep -Milliseconds 300
    }

    Remove-Item -LiteralPath $tmpFile -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "--- Summary ---" -ForegroundColor Cyan
    Write-Host "  Total   : $total"   -ForegroundColor White
    Write-Host "  Created : $created" -ForegroundColor Green
    if ($failed -gt 0) {
        Write-Host "  Failed  : $failed" -ForegroundColor Red
    }
    Write-Host ""
}

# --- Main ----------------------------------------------------
$parsed = Parse-EpicsDoc -Path $EpicsFile

Write-Host "Parsed: $($parsed.Epics.Count) epics, $($parsed.Stories.Count) stories found." -ForegroundColor Cyan
Write-Host ""

if (-not $SkipLabels)     { Create-Labels }
if (-not $SkipMilestones) { Create-Milestones -Epics $parsed.Epics }
Create-Issues -Stories $parsed.Stories -Epics $parsed.Epics

Write-Host "Done!" -ForegroundColor Green
