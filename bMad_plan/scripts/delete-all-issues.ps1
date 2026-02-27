# PowerShell Script to Delete All GitHub Issues
# Use this to clean up before creating new architecture-aligned issues

# Configuration - UPDATE THESE VALUES
$REPO_OWNER = "your-username"  # Replace with your GitHub username
$REPO_NAME = "shop-list-app"   # Replace with your repository name
$REPO = "$REPO_OWNER/$REPO_NAME"

# Safety check
Write-Host "=== GitHub Issues Deletion Tool ===" -ForegroundColor Red
Write-Host "Repository: $REPO" -ForegroundColor Yellow
Write-Host ""
Write-Warning "This will DELETE ALL ISSUES in the repository!"
$confirm = Read-Host "Type 'DELETE ALL' to confirm (case-sensitive)"

if ($confirm -ne "DELETE ALL") {
    Write-Host "Cancelled. No issues were deleted." -ForegroundColor Green
    exit 0
}

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

Write-Host ""
Write-Host "Fetching all issues..." -ForegroundColor Cyan

# Get all issue numbers (open and closed)
$allIssues = gh issue list --repo $REPO --state all --limit 1000 --json number,title --jq '.[] | "\(.number)|\(.title)"'

if (-not $allIssues) {
    Write-Host "No issues found in repository." -ForegroundColor Green
    exit 0
}

$issueCount = ($allIssues | Measure-Object).Count
Write-Host "Found $issueCount issues to delete" -ForegroundColor Yellow
Write-Host ""

$deletedCount = 0
$failedCount = 0

foreach ($issueLine in $allIssues) {
    $parts = $issueLine -split '\|'
    $issueNumber = $parts[0]
    $issueTitle = $parts[1]
    
    Write-Host "Deleting #$issueNumber - $issueTitle" -ForegroundColor Gray
    
    # Close the issue first (GitHub CLI doesn't have direct delete for issues)
    gh issue close $issueNumber --repo $REPO --comment "Closing to reorganize issues based on new architecture" 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        $deletedCount++
        Write-Host "  ✓ Closed issue #$issueNumber" -ForegroundColor Green
    } else {
        $failedCount++
        Write-Host "  ✗ Failed to close issue #$issueNumber" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Closed: $deletedCount" -ForegroundColor Green
Write-Host "Failed: $failedCount" -ForegroundColor Red
Write-Host ""
Write-Host "Note: Issues are closed, not deleted. To permanently delete, you must manually delete them via GitHub web interface." -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Delete old labels and milestones via GitHub web interface (optional)" -ForegroundColor White
Write-Host "2. Run: .\create-new-architecture-issues.ps1" -ForegroundColor White
