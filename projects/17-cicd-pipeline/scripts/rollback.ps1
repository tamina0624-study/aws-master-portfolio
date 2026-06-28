param(
    [string]$Environment = "dev",
    [string]$BucketName,
    [switch]$DryRun
)

<#
.SYNOPSIS
Rollback Terraform state and revert infrastructure changes.

.DESCRIPTION
This script performs rollback operations for failed deployments.
It uses Terraform state revision history to identify and restore prior stable state.

.PARAMETER Environment
Target environment (dev/stg/prod).

.PARAMETER BucketName
S3 bucket name to verify rollback (optional).

.PARAMETER DryRun
Show what would happen without executing.
#>

Write-Host "=== Terraform Rollback Procedure ===" -ForegroundColor Yellow
Write-Host "Environment: $Environment"
Write-Host "Bucket: $BucketName"

if ($DryRun) {
    Write-Host "`n[DRY RUN MODE]" -ForegroundColor Cyan
}

# Step 1: Review current state
Write-Host "`n[Step 1] Review Current Terraform State" -ForegroundColor Green
$tfStateCmd = "terraform state list"
Write-Host "Command: $tfStateCmd"
if (-not $DryRun) {
    terraform state list | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "  (would list current resources)"
}

# Step 2: Check state backup
Write-Host "`n[Step 2] Verify State Backup Location" -ForegroundColor Green
$backupPath = ".terraform/terraform.tfstate.backup"
Write-Host "Backup path: $backupPath"
if (Test-Path $backupPath) {
    Write-Host "  ✓ Backup exists"
    $backupInfo = Get-Item $backupPath
    Write-Host "  Size: $($backupInfo.Length) bytes"
} else {
    Write-Host "  ✗ Backup NOT FOUND - manual rollback may be required"
}

# Step 3: Rollback plan
Write-Host "`n[Step 3] Rollback Plan" -ForegroundColor Green
Write-Host "To rollback from current state:"
Write-Host "  a) Restore from backup: Copy-Item $backupPath terraform.tfstate -Force"
Write-Host "  b) Refresh state: terraform refresh"
Write-Host "  c) Verify: terraform plan"
Write-Host "  d) Destroy if needed: terraform destroy -auto-approve"

# Step 4: Recommended manual steps
Write-Host "`n[Step 4] Manual Verification Steps" -ForegroundColor Green
Write-Host "  1. Check terraform.state integrity"
Write-Host "  2. Review git log for last successful commit"
Write-Host "  3. Verify AWS console for orphaned resources"
Write-Host "  4. If using remote state, confirm S3/DynamoDB lock is cleared"

# Step 5: Execution (if not dry-run)
if (-not $DryRun) {
    Write-Host "`n[Step 5] Execute Rollback?" -ForegroundColor Yellow
    $response = Read-Host "Type 'yes' to confirm rollback"

    if ($response -eq 'yes') {
        Write-Host "Executing rollback..."

        # Copy backup
        if (Test-Path $backupPath) {
            Copy-Item $backupPath "terraform.tfstate" -Force
            Write-Host "  ✓ State restored from backup"
        }

        # Refresh
        Write-Host "  Running terraform refresh..."
        terraform refresh -no-color

        Write-Host "`n✓ Rollback completed. Verify with: terraform plan" -ForegroundColor Green
    } else {
        Write-Host "Rollback cancelled."
    }
}

Write-Host "`n=== End Rollback Procedure ===" -ForegroundColor Yellow
