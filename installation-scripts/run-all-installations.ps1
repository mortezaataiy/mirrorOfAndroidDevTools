# run-all-installations.ps1 - Master Installation Script
param(
    [string]$DownloadPath = "downloaded",
    [string]$InstallPath = "C:\AndroidDev",
    [switch]$Force
)

Write-Host "=== Android Development Tools Installation ===" -ForegroundColor Cyan
Write-Host "Download Path: $DownloadPath" -ForegroundColor Gray
Write-Host "Install Path: $InstallPath" -ForegroundColor Gray
Write-Host ""

$components = @(
    @{ Name = "JDK 17"; Path = "jdk17"; InstallPath = "$InstallPath\Java" }
)

$results = @()

foreach ($component in $components) {
    Write-Host "Installing $($component.Name)..." -ForegroundColor Yellow
    
    $componentPath = "installation-scripts\$($component.Path)"
    
    # Run prerequisites check
    Write-Host "  Checking prerequisites..." -ForegroundColor Gray
    & "$componentPath\01-check-prerequisites.ps1" -DownloadPath $DownloadPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Prerequisites check failed for $($component.Name)" -ForegroundColor Red
        $results += @{ Component = $component.Name; Status = "Prerequisites Failed" }
        continue
    }
    
    # Run installation
    Write-Host "  Installing component..." -ForegroundColor Gray
    if ($Force) {
        & "$componentPath\02-install-component.ps1" -DownloadPath $DownloadPath -InstallPath $component.InstallPath -Force
    } else {
        & "$componentPath\02-install-component.ps1" -DownloadPath $DownloadPath -InstallPath $component.InstallPath
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Installation failed for $($component.Name)" -ForegroundColor Red
        $results += @{ Component = $component.Name; Status = "Installation Failed" }
        continue
    }
    
    # Run tests
    Write-Host "  Testing installation..." -ForegroundColor Gray
    & "$componentPath\03-test-installation.ps1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Tests failed for $($component.Name)" -ForegroundColor Red
        $results += @{ Component = $component.Name; Status = "Tests Failed" }
        continue
    }
    
    Write-Host "  $($component.Name) installed successfully!" -ForegroundColor Green
    $results += @{ Component = $component.Name; Status = "Success" }
}

Write-Host ""
Write-Host "=== Installation Summary ===" -ForegroundColor Cyan
foreach ($result in $results) {
    $color = if ($result.Status -eq "Success") { "Green" } else { "Red" }
    Write-Host "$($result.Component): $($result.Status)" -ForegroundColor $color
}

$successCount = ($results | Where-Object { $_.Status -eq "Success" }).Count
$totalCount = $results.Count

Write-Host ""
Write-Host "Completed: $successCount/$totalCount components" -ForegroundColor $(if($successCount -eq $totalCount) {"Green"} else {"Yellow"})

if ($successCount -eq $totalCount) {
    Write-Host "All components installed successfully!" -ForegroundColor Green
    Write-Host "Please restart PowerShell to apply environment changes" -ForegroundColor Yellow
} else {
    Write-Host "Some components failed to install. Check the logs above." -ForegroundColor Red
}
