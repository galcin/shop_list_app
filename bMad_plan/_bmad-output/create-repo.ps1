# Create GitHub Repository
$REPO_NAME = "shop_list_app"
$GITHUB_TOKEN = "your-github-token-here"  # Replace with your GitHub Personal Access Token

$headers = @{
    "Authorization" = "Bearer $GITHUB_TOKEN"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$repoData = @{
    name = $REPO_NAME
    description = "Shopping List and Meal Planning Flutter App"
    private = $false
    has_issues = $true
    has_projects = $true
    has_wiki = $true
} | ConvertTo-Json

Write-Host "Creating repository: $REPO_NAME" -ForegroundColor Cyan

try {
    $result = Invoke-RestMethod -Uri "https://api.github.com/user/repos" `
        -Method POST `
        -Headers $headers `
        -Body $repoData `
        -ContentType "application/json"
    
    Write-Host "Repository created successfully!" -ForegroundColor Green
    Write-Host "URL: $($result.html_url)" -ForegroundColor Cyan
}
catch {
    Write-Host "Error creating repository: $_" -ForegroundColor Red
}
