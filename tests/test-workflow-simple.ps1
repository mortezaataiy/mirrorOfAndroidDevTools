# Simple Test Workflow Script
# Simple workflow test script

Write-Host "🧪 Starting GitHub Action Workflow Test" -ForegroundColor Cyan
Write-Host "📅 Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow

# Check for GitHub CLI existence
$ghPath = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $ghPath)) {
    Write-Error "❌ GitHub CLI not found at path: $ghPath"
    Write-Host "💡 Please install GitHub CLI: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ GitHub CLI found" -ForegroundColor Green

try {
    # Check GitHub authentication status
    Write-Host "🔐 Checking GitHub authentication..." -ForegroundColor Yellow
    $authResult = & $ghPath auth status 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ GitHub authentication failed" -ForegroundColor Red
        Write-Host "💡 Please authenticate with the following command:" -ForegroundColor Yellow
        Write-Host "gh auth login" -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "✅ GitHub authentication successful" -ForegroundColor Green
    
    # Run workflow
    Write-Host "🚀 Running workflow..." -ForegroundColor Cyan
    $runResult = & $ghPath workflow run "android-version-checker.yml" --field force_run=true 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error running workflow: $runResult" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Workflow started successfully" -ForegroundColor Green
    
    # Show latest runs
    Write-Host "📋 Latest workflow runs:" -ForegroundColor Cyan
    & $ghPath run list --workflow="android-version-checker.yml" --limit=5
    
    # Get latest run ID
    Write-Host "🔍 Getting latest run ID..." -ForegroundColor Yellow
    $runListOutput = & $ghPath run list --workflow="android-version-checker.yml" --limit=1 --json=databaseId 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $runData = $runListOutput | ConvertFrom-Json
        if ($runData -and $runData.databaseId) {
            $latestRunId = $runData.databaseId
            Write-Host "🆔 Latest run ID: $latestRunId" -ForegroundColor Yellow
            
            # Suggest useful commands
            Write-Host "💡 Useful commands:" -ForegroundColor Yellow
            Write-Host "  📊 View details: gh run view $latestRunId" -ForegroundColor Cyan
            Write-Host "  📥 Download artifacts: gh run download $latestRunId" -ForegroundColor Cyan
            Write-Host "  📜 View logs: gh run view $latestRunId --log" -ForegroundColor Cyan
        }
    }
    
    Write-Host "✅ Workflow test completed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error in workflow test: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Write-Host "🏁 Test completed" -ForegroundColor Cyan
}