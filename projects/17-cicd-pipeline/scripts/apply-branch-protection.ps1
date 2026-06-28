param(
    [string]$Owner = "tamina0624-study",
    [string]$Repo = "aws-master-portfolio2",
    [string]$Branch = "main",
    [string[]]$RequiredChecks = @(
        "python-quality",
        "python-test",
        "security-scan",
        "terraform-check"
    ),
    [switch]$DryRun
)

$token = $env:GITHUB_TOKEN
if (-not $DryRun -and -not $token) {
    Write-Error "GITHUB_TOKEN is not set. Export a token with repo admin permission and retry."
    exit 1
}

$headers = @{
    Authorization = "Bearer $token"
    Accept        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$payload = @{
    required_status_checks = @{
        strict   = $true
        contexts = $RequiredChecks
    }
    enforce_admins = $true
    required_pull_request_reviews = @{
        dismiss_stale_reviews           = $true
        require_code_owner_reviews      = $false
        required_approving_review_count = 1
    }
    restrictions = $null
    required_linear_history = $true
    allow_force_pushes = $false
    allow_deletions = $false
    block_creations = $false
    required_conversation_resolution = $true
    lock_branch = $false
    allow_fork_syncing = $false
}

$uri = "https://api.github.com/repos/$Owner/$Repo/branches/$Branch/protection"
$body = $payload | ConvertTo-Json -Depth 10

if ($DryRun) {
    Write-Host "Dry run mode. The following payload will be sent:" -ForegroundColor Yellow
    Write-Host $body
    exit 0
}

Write-Host "Applying branch protection to $Owner/${Repo}:$Branch ..."
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $body -ContentType "application/json"
Write-Host "Branch protection applied successfully." -ForegroundColor Green
