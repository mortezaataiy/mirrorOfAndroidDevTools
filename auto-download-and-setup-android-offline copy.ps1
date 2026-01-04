# ==========================================
# Android Offline Installer
# ==========================================

param(
    [Parameter(HelpMessage="Custom installation path")]
    [string]$InstallPath = "D:\Android",
    
    [Parameter(HelpMessage="Source files search path")]
    [string]$SourcePath = ".\downloaded"
)

# Set error handling
$ErrorActionPreference = "Stop"

# Global variables
$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$INSTALL = $InstallPath
$SOURCE_PATH = if (Test-Path $SourcePath) { $SourcePath } else { Join-Path $ROOT $SourcePath }

$JAVA_HOME = "$INSTALL\JDK17"
$GRADLE_HOME = "$INSTALL\Gradle"
$SDK_ROOT = "$INSTALL\Sdk"

# Logging functions
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Write-Success { param([string]$Message) Write-Log $Message "SUCCESS" }
function Write-Info { param([string]$Message) Write-Log $Message "INFO" }
function Write-Warning { param([string]$Message) Write-Log $Message "WARNING" }
function Write-Error { param([string]$Message) Write-Log $Message "ERROR" }

function Stop-WithError {
    param([string]$Message)
    Write-Error $Message
    Write-Host ""
    Write-Host "Installation failed. Please check the error above and try again." -ForegroundColor Red
    exit 1
}

# Utility functions
function Ensure-Directory {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        try {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Info "Created directory: $Path"
        }
        catch {
            Stop-WithError "Failed to create directory: $Path - $($_.Exception.Message)"
        }
    }
}

function Test-ZipFile {
    param([string]$ZipPath)
    try {
        if (-not (Test-Path $ZipPath)) {
            return $false
        }
        
        $fileInfo = Get-Item $ZipPath
        if ($fileInfo.Length -eq 0) {
            return $false
        }
        
        # Test ZIP integrity by trying to read it
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
        $entryCount = $zip.Entries.Count
        $zip.Dispose()
        
        return $entryCount -gt 0
    }
    catch {
        return $false
    }
}

function Extract-ZipSmart {
    param(
        [string]$ZipPath,
        [string]$DestinationPath,
        [string]$ComponentName
    )
    
    Write-Info "Extracting $ComponentName from: $([IO.Path]::GetFileName($ZipPath))"
    
    if (-not (Test-ZipFile $ZipPath)) {
        Stop-WithError "Invalid or corrupted ZIP file: $ZipPath"
    }
    
    try {
        # Create extraction directory
        if (Test-Path $DestinationPath) {
            Remove-Item $DestinationPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        
        # Extract ZIP
        Expand-Archive -Path $ZipPath -DestinationPath $DestinationPath -Force
        
        # Check for nested ZIP (double-zipped files)
        $extractedFiles = Get-ChildItem $DestinationPath -File -ErrorAction SilentlyContinue
        $nestedZip = $extractedFiles | Where-Object { $_.Extension -eq ".zip" }
        
        if ($nestedZip) {
            Write-Info "Found nested ZIP file, extracting again..."
            $nestedExtractPath = Join-Path $DestinationPath "nested"
            Expand-Archive -Path $nestedZip.FullName -DestinationPath $nestedExtractPath -Force
            
            # Move contents up one level
            $nestedContents = Get-ChildItem $nestedExtractPath
            foreach ($item in $nestedContents) {
                Move-Item $item.FullName $DestinationPath -Force
            }
            Remove-Item $nestedExtractPath -Recurse -Force
            Remove-Item $nestedZip.FullName -Force
        }
        
        Write-Success "Successfully extracted $ComponentName to: $DestinationPath"
        return $DestinationPath
    }
    catch {
        Stop-WithError "Failed to extract $ComponentName : $($_.Exception.Message)"
    }
}

function Find-ComponentFile {
    param(
        [string]$SearchPath,
        [string[]]$FileNames,
        [int]$MaxDepth = 5
    )
    
    # Search recursively for the files
    foreach ($fileName in $FileNames) {
        $found = Get-ChildItem $SearchPath -Name $fileName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            return Join-Path $SearchPath $found
        }
    }
    return $null
}

function Install-Component {
    param(
        [string]$ComponentName,
        [string]$ZipPattern,
        [string]$TargetPath,
        [string[]]$ValidateFiles
    )
    
    Write-Info "Installing $ComponentName..."
    
    # Find ZIP file
    $zipFile = Get-ChildItem $SOURCE_PATH -Filter $ZipPattern | Select-Object -First 1
    if (-not $zipFile) {
        Stop-WithError "Could not find $ComponentName ZIP file matching pattern: $ZipPattern"
    }
    
    Write-Info "Found $ComponentName file: $($zipFile.Name)"
    
    # Extract to temporary location first
    $tempExtractPath = Join-Path $SOURCE_PATH "extracted_$ComponentName"
    Extract-ZipSmart $zipFile.FullName $tempExtractPath $ComponentName
    
    # Find the actual component directory by looking for validation files
    $componentPath = $tempExtractPath
    
    # First try to find validation files in the extracted directory
    $foundValidationFile = $null
    foreach ($validateFile in $ValidateFiles) {
        $foundValidationFile = Find-ComponentFile $tempExtractPath @($validateFile)
        if ($foundValidationFile) {
            # Get the directory that contains the validation file
            $componentPath = Split-Path $foundValidationFile -Parent
            # For JDK, we want the parent of the bin directory
            if ($ComponentName -eq "JDK" -and (Split-Path $componentPath -Leaf) -eq "bin") {
                $componentPath = Split-Path $componentPath -Parent
            }
            break
        }
    }
    
    # If no validation files found, try to find the main component directory
    if (-not $foundValidationFile) {
        $subDirs = Get-ChildItem $tempExtractPath -Directory
        if ($subDirs.Count -eq 1) {
            $componentPath = $subDirs[0].FullName
        }
    }
    
    Write-Info "Using component path: $componentPath"
    
    # Validate component by checking for required files
    $isValid = $true
    foreach ($validateFile in $ValidateFiles) {
        $foundFile = Find-ComponentFile $componentPath @($validateFile)
        if (-not $foundFile) {
            Write-Warning "Validation file not found: $validateFile in $componentPath"
            $isValid = $false
        } else {
            Write-Info "Found validation file: $foundFile"
        }
    }
    
    if (-not $isValid) {
        Stop-WithError "$ComponentName validation failed - required files not found"
    }
    
    # Copy to final destination
    Ensure-Directory (Split-Path $TargetPath -Parent)
    if (Test-Path $TargetPath) {
        Remove-Item $TargetPath -Recurse -Force
    }
    
    Copy-Item $componentPath $TargetPath -Recurse -Force
    Write-Success "$ComponentName installed successfully to: $TargetPath"
    
    # Cleanup temporary extraction
    if (Test-Path $tempExtractPath) {
        Remove-Item $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Set-EnvironmentVariables {
    Write-Info "Setting up environment variables..."
    
    try {
        # Set JAVA_HOME
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $JAVA_HOME, "Machine")
        $env:JAVA_HOME = $JAVA_HOME
        Write-Success "Set JAVA_HOME = $JAVA_HOME"
        
        # Set ANDROID_HOME and ANDROID_SDK_ROOT
        [Environment]::SetEnvironmentVariable("ANDROID_HOME", $SDK_ROOT, "Machine")
        [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SDK_ROOT, "Machine")
        $env:ANDROID_HOME = $SDK_ROOT
        $env:ANDROID_SDK_ROOT = $SDK_ROOT
        Write-Success "Set ANDROID_HOME = $SDK_ROOT"
        Write-Success "Set ANDROID_SDK_ROOT = $SDK_ROOT"
        
        # Update PATH
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        $pathsToAdd = @(
            "$JAVA_HOME\bin",
            "$GRADLE_HOME\bin",
            "$SDK_ROOT\platform-tools",
            "$SDK_ROOT\cmdline-tools\latest\bin"
        )
        
        $newPath = $currentPath
        foreach ($pathToAdd in $pathsToAdd) {
            if ($currentPath -notlike "*$pathToAdd*") {
                $newPath = "$pathToAdd;$newPath"
                Write-Info "Added to PATH: $pathToAdd"
            }
        }
        
        [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        $env:Path = $newPath
        Write-Success "Environment variables configured successfully"
        
    }
    catch {
        Stop-WithError "Failed to set environment variables: $($_.Exception.Message)"
    }
}

function Test-Installation {
    Write-Info "Testing installation..."
    
    # Test Java
    try {
        $javaVersion = & "$JAVA_HOME\bin\java.exe" -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Java is working correctly"
        } else {
            Write-Warning "Java test failed"
        }
    }
    catch {
        Write-Warning "Could not test Java installation"
    }
    
    # Test Gradle
    try {
        $gradleVersion = & "$GRADLE_HOME\bin\gradle.bat" --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Gradle is working correctly"
        } else {
            Write-Warning "Gradle test failed"
        }
    }
    catch {
        Write-Warning "Could not test Gradle installation"
    }
    
    # Test ADB
    try {
        $adbVersion = & "$SDK_ROOT\platform-tools\adb.exe" version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "ADB is working correctly"
        } else {
            Write-Warning "ADB test failed"
        }
    }
    catch {
        Write-Warning "Could not test ADB installation"
    }
}

function Create-SampleProject {
    Write-Info "Creating sample Android project..."
    
    $sampleProjectPath = Join-Path $ROOT "sampleProject"
    
    try {
        # Remove existing project
        if (Test-Path $sampleProjectPath) {
            Remove-Item $sampleProjectPath -Recurse -Force
        }
        
        # Create project structure
        Ensure-Directory $sampleProjectPath
        Ensure-Directory "$sampleProjectPath\app\src\main\java\com\example\helloworld"
        Ensure-Directory "$sampleProjectPath\app\src\main\res\layout"
        Ensure-Directory "$sampleProjectPath\app\src\main\res\values"
        
        # Create build.gradle (project level)
        $projectBuildGradle = @"
// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id 'com.android.application' version '8.1.0' apply false
}
"@
        $projectBuildGradle | Out-File "$sampleProjectPath\build.gradle" -Encoding UTF8
        
        # Create settings.gradle
        $settingsGradle = @"
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "HelloWorld"
include ':app'
"@
        $settingsGradle | Out-File "$sampleProjectPath\settings.gradle" -Encoding UTF8
        
        # Create app/build.gradle
        $appBuildGradle = @"
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.example.helloworld'
    compileSdk 33

    defaultConfig {
        applicationId "com.example.helloworld"
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
"@
        $appBuildGradle | Out-File "$sampleProjectPath\app\build.gradle" -Encoding UTF8
        
        # Create MainActivity.java
        $mainActivity = @"
package com.example.helloworld;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }
}
"@
        $mainActivity | Out-File "$sampleProjectPath\app\src\main\java\com\example\helloworld\MainActivity.java" -Encoding UTF8
        
        # Create activity_main.xml
        $activityMain = @"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World!"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
"@
        $activityMain | Out-File "$sampleProjectPath\app\src\main\res\layout\activity_main.xml" -Encoding UTF8
        
        # Create strings.xml
        $strings = @"
<resources>
    <string name="app_name">HelloWorld</string>
</resources>
"@
        $strings | Out-File "$sampleProjectPath\app\src\main\res\values\strings.xml" -Encoding UTF8
        
        # Create AndroidManifest.xml
        $manifest = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.AppCompat"
        tools:targetApi="31">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
"@
        $manifest | Out-File "$sampleProjectPath\app\src\main\AndroidManifest.xml" -Encoding UTF8
        
        Write-Success "Sample project created at: $sampleProjectPath"
        
        # Build the project
        Write-Info "Building sample project..."
        Set-Location $sampleProjectPath
        
        $buildResult = & "$GRADLE_HOME\bin\gradle.bat" assembleDebug 2>&1
        $buildExitCode = $LASTEXITCODE
        
        Write-Info "Build output:"
        Write-Host $buildResult -ForegroundColor Gray
        
        if ($buildExitCode -eq 0) {
            Write-Success "Sample project built successfully!"
            
            # Check for APK
            $apkPath = "$sampleProjectPath\app\build\outputs\apk\debug\app-debug.apk"
            if (Test-Path $apkPath) {
                Write-Success "APK created successfully: $apkPath"
            } else {
                Write-Warning "Build succeeded but APK not found at expected location"
            }
        } else {
            Write-Error "Sample project build failed"
            Write-Host "Build output: $buildResult" -ForegroundColor Red
        }
        
    }
    catch {
        Write-Error "Failed to create or build sample project: $($_.Exception.Message)"
    }
    finally {
        Set-Location $ROOT
    }
}

# Spec Discovery and Selection System
function Get-AvailableSpecs {
    Write-Info "Discovering available specs..."
    
    $specsPath = ".kiro\specs"
    if (-not (Test-Path $specsPath)) {
        Write-Warning "No specs directory found"
        return @()
    }
    
    $specs = @()
    $specDirs = Get-ChildItem $specsPath -Directory
    
    foreach ($specDir in $specDirs) {
        $specInfo = @{
            Name = $specDir.Name
            Path = $specDir.FullName
            HasRequirements = Test-Path (Join-Path $specDir.FullName "requirements.md")
            HasDesign = Test-Path (Join-Path $specDir.FullName "design.md")
            HasTasks = Test-Path (Join-Path $specDir.FullName "tasks.md")
        }
        
        # Read spec description from requirements if available
        if ($specInfo.HasRequirements) {
            try {
                $reqContent = Get-Content (Join-Path $specDir.FullName "requirements.md") -Raw
                if ($reqContent -match "## Introduction\s*\n\n([^\n]+)") {
                    $specInfo.Description = $matches[1]
                } elseif ($reqContent -match "## مقدمه\s*\n\n([^\n]+)") {
                    $specInfo.Description = $matches[1]
                } else {
                    $specInfo.Description = "No description available"
                }
            }
            catch {
                $specInfo.Description = "Could not read description"
            }
        } else {
            $specInfo.Description = "No requirements file found"
        }
        
        $specs += $specInfo
    }
    
    return $specs
}

function Select-Spec {
    param([array]$AvailableSpecs)
    
    if ($AvailableSpecs.Count -eq 0) {
        Write-Warning "No specs available for selection"
        return $null
    }
    
    Write-Host ""
    Write-Host "Available Specs:" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $AvailableSpecs.Count; $i++) {
        $spec = $AvailableSpecs[$i]
        $status = ""
        if ($spec.HasRequirements) { $status += "R" } else { $status += "-" }
        if ($spec.HasDesign) { $status += "D" } else { $status += "-" }
        if ($spec.HasTasks) { $status += "T" } else { $status += "-" }
        
        Write-Host "$($i + 1). $($spec.Name) [$status]" -ForegroundColor White
        Write-Host "   $($spec.Description)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Legend: [R]equirements [D]esign [T]asks" -ForegroundColor DarkGray
    Write-Host ""
    
    do {
        $selection = Read-Host "Select a spec (1-$($AvailableSpecs.Count)) or 'q' to quit"
        if ($selection -eq 'q') {
            return $null
        }
        
        $index = $null
        if ([int]::TryParse($selection, [ref]$index) -and $index -ge 1 -and $index -le $AvailableSpecs.Count) {
            return $AvailableSpecs[$index - 1]
        }
        
        Write-Warning "Invalid selection. Please enter a number between 1 and $($AvailableSpecs.Count)"
    } while ($true)
}

# Main execution
Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "Android Offline Installer" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host "Install Path: $INSTALL" -ForegroundColor Cyan
Write-Host "Source Path: $SOURCE_PATH" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

# Spec Discovery and Selection (Task 1.5)
Write-Info "Discovering available specs..."
$availableSpecs = Get-AvailableSpecs
if ($availableSpecs.Count -gt 0) {
    Write-Success "Found $($availableSpecs.Count) available specs"
    foreach ($spec in $availableSpecs) {
        Write-Host "  - $($spec.Name): $($spec.Description)" -ForegroundColor Gray
    }
} else {
    Write-Warning "No specs found in .kiro/specs directory"
}

# Check if source directory exists
if (-not (Test-Path $SOURCE_PATH)) {
    Stop-WithError "Source directory not found: $SOURCE_PATH"
}

Write-Info "Found source directory: $SOURCE_PATH"

# List available files
$availableFiles = Get-ChildItem $SOURCE_PATH -Filter "*.zip" | Select-Object Name, @{Name="Size";Expression={[math]::Round($_.Length/1MB,2)}}
Write-Info "Available ZIP files:"
$availableFiles | ForEach-Object { Write-Host "  - $($_.Name) ($($_.Size) MB)" -ForegroundColor Gray }

# Create installation directories
Write-Info "Creating installation directories..."
Ensure-Directory $INSTALL
Ensure-Directory $JAVA_HOME
Ensure-Directory $GRADLE_HOME
Ensure-Directory $SDK_ROOT

# Install components
try {
    # Install JDK
    Install-Component "JDK" "jdk-17*.zip" $JAVA_HOME @("java.exe", "javac.exe")
    
    # Install Gradle
    Install-Component "Gradle" "gradle-*.zip" $GRADLE_HOME @("gradle.bat", "gradle")
    
    # Install Android SDK Command Line Tools
    $cmdlineToolsPath = "$SDK_ROOT\cmdline-tools\latest"
    Install-Component "Android SDK Command Line Tools" "commandlinetools-*.zip" $cmdlineToolsPath @("sdkmanager.bat", "avdmanager.bat")
    
    # Install Platform Tools
    $platformToolsPath = "$SDK_ROOT\platform-tools"
    Install-Component "Platform Tools" "platform-tools*.zip" $platformToolsPath @("adb.exe", "fastboot.exe")
    
    # Install Build Tools
    $buildToolsPath = "$SDK_ROOT\build-tools\33.0.2"
    Install-Component "Build Tools" "build-tools-*.zip" $buildToolsPath @("aapt.exe", "aapt2.exe")
    
    # Install SDK Platforms
    $platformsPath = "$SDK_ROOT\platforms"
    Ensure-Directory $platformsPath
    
    $platformZips = Get-ChildItem $SOURCE_PATH -Filter "sdk-platform-*.zip"
    foreach ($platformZip in $platformZips) {
        $platformName = [System.IO.Path]::GetFileNameWithoutExtension($platformZip.Name) -replace "sdk-platform-", "android-"
        $platformPath = "$platformsPath\$platformName"
        Install-Component "SDK Platform $platformName" $platformZip.Name $platformPath @("android.jar")
    }
    
    # Install System Images (optional)
    $systemImagesPath = "$SDK_ROOT\system-images"
    $sysImageZips = Get-ChildItem $SOURCE_PATH -Filter "sysimage-*.zip"
    if ($sysImageZips) {
        Ensure-Directory $systemImagesPath
        foreach ($sysImageZip in $sysImageZips) {
            $imageName = [System.IO.Path]::GetFileNameWithoutExtension($sysImageZip.Name)
            $imagePath = "$systemImagesPath\$imageName"
            Install-Component "System Image $imageName" $sysImageZip.Name $imagePath @("*.img")
        }
    }
    
    Write-Success "All components installed successfully!"
    
}
catch {
    Stop-WithError "Component installation failed: $($_.Exception.Message)"
}

# Set up environment variables
Set-EnvironmentVariables

# Test installation
Test-Installation

# Create and build sample project
Create-SampleProject

# Run comprehensive tests on sample project
Test-SampleProjectComprehensive

function Test-SampleProjectComprehensive {
    Write-Info "Running comprehensive tests on sample project..."
    
    $sampleProjectPath = Join-Path $ROOT "sampleProject"
    
    if (-not (Test-Path $sampleProjectPath)) {
        Write-Error "Sample project not found at: $sampleProjectPath"
        return $false
    }
    
    $testResults = @{
        ProjectStructure = $false
        GradleFiles = $false
        SourceFiles = $false
        BuildSuccess = $false
        APKGenerated = $false
        APKValid = $false
        OfflineBuild = $false
    }
    
    try {
        Set-Location $sampleProjectPath
        
        # Test 1: Project Structure
        Write-Info "Testing project structure..."
        $requiredDirs = @(
            "app\src\main\java\com\example\helloworld",
            "app\src\main\res\layout",
            "app\src\main\res\values"
        )
        
        $structureValid = $true
        foreach ($dir in $requiredDirs) {
            if (-not (Test-Path $dir)) {
                Write-Warning "Missing directory: $dir"
                $structureValid = $false
            }
        }
        $testResults.ProjectStructure = $structureValid
        
        # Test 2: Gradle Files
        Write-Info "Testing Gradle configuration files..."
        $requiredFiles = @(
            "build.gradle",
            "settings.gradle",
            "app\build.gradle"
        )
        
        $gradleValid = $true
        foreach ($file in $requiredFiles) {
            if (-not (Test-Path $file)) {
                Write-Warning "Missing Gradle file: $file"
                $gradleValid = $false
            } else {
                $content = Get-Content $file -Raw
                if ($content.Length -lt 10) {
                    Write-Warning "Gradle file appears empty: $file"
                    $gradleValid = $false
                }
            }
        }
        $testResults.GradleFiles = $gradleValid
        
        # Test 3: Source Files
        Write-Info "Testing source files..."
        $sourceFiles = @(
            "app\src\main\java\com\example\helloworld\MainActivity.java",
            "app\src\main\res\layout\activity_main.xml",
            "app\src\main\res\values\strings.xml",
            "app\src\main\AndroidManifest.xml"
        )
        
        $sourceValid = $true
        foreach ($file in $sourceFiles) {
            if (-not (Test-Path $file)) {
                Write-Warning "Missing source file: $file"
                $sourceValid = $false
            }
        }
        $testResults.SourceFiles = $sourceValid
        
        # Test 4: Clean Build
        Write-Info "Testing clean build..."
        if (Test-Path "app\build") {
            Remove-Item "app\build" -Recurse -Force
        }
        
        $cleanResult = & "$GRADLE_HOME\bin\gradle.bat" clean 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Clean build successful"
        } else {
            Write-Warning "Clean build failed: $cleanResult"
        }
        
        # Test 5: Debug Build
        Write-Info "Testing debug build..."
        $buildResult = & "$GRADLE_HOME\bin\gradle.bat" assembleDebug 2>&1
        $buildExitCode = $LASTEXITCODE
        
        if ($buildExitCode -eq 0) {
            Write-Success "Debug build successful"
            $testResults.BuildSuccess = $true
        } else {
            Write-Error "Debug build failed"
            Write-Host "Build output: $buildResult" -ForegroundColor Red
        }
        
        # Test 6: APK Generation
        Write-Info "Testing APK generation..."
        $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            $apkInfo = Get-Item $apkPath
            Write-Success "APK generated successfully: $($apkInfo.Name) ($([math]::Round($apkInfo.Length/1MB,2)) MB)"
            $testResults.APKGenerated = $true
            
            # Test 7: APK Validation
            Write-Info "Validating APK structure..."
            if ($apkInfo.Length -gt 1MB) {
                Write-Success "APK size is reasonable"
                $testResults.APKValid = $true
            } else {
                Write-Warning "APK size seems too small: $($apkInfo.Length) bytes"
            }
        } else {
            Write-Error "APK not found at expected location: $apkPath"
        }
        
        # Test 8: Offline Build Test
        Write-Info "Testing offline build capability..."
        if (Test-Path "app\build") {
            Remove-Item "app\build" -Recurse -Force
        }
        
        $offlineResult = & "$GRADLE_HOME\bin\gradle.bat" assembleDebug --offline 2>&1
        $offlineExitCode = $LASTEXITCODE
        
        if ($offlineExitCode -eq 0) {
            Write-Success "Offline build successful"
            $testResults.OfflineBuild = $true
        } else {
            Write-Warning "Offline build failed - this may be expected for first build"
            Write-Host "Offline build output: $offlineResult" -ForegroundColor Yellow
        }
        
        # Test 9: Gradle Tasks
        Write-Info "Testing available Gradle tasks..."
        $tasksResult = & "$GRADLE_HOME\bin\gradle.bat" tasks --all 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Gradle tasks command successful"
        } else {
            Write-Warning "Gradle tasks command failed"
        }
        
        # Test 10: Dependencies Check
        Write-Info "Testing dependencies resolution..."
        $depsResult = & "$GRADLE_HOME\bin\gradle.bat" dependencies 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Dependencies resolution successful"
        } else {
            Write-Warning "Dependencies resolution failed"
        }
        
    }
    catch {
        Write-Error "Error during comprehensive testing: $($_.Exception.Message)"
        return $false
    }
    finally {
        Set-Location $ROOT
    }
    
    # Generate test report
    Write-Host ""
    Write-Host "===========================================" -ForegroundColor Yellow
    Write-Host "Sample Project Test Results" -ForegroundColor Yellow
    Write-Host "===========================================" -ForegroundColor Yellow
    
    $passedTests = 0
    $totalTests = $testResults.Keys.Count
    
    foreach ($test in $testResults.Keys) {
        $status = if ($testResults[$test]) { "PASS" } else { "FAIL" }
        $color = if ($testResults[$test]) { "Green" } else { "Red" }
        
        Write-Host "$test : $status" -ForegroundColor $color
        if ($testResults[$test]) { $passedTests++ }
    }
    
    Write-Host ""
    Write-Host "Overall Result: $passedTests/$totalTests tests passed" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })
    Write-Host "===========================================" -ForegroundColor Yellow
    
    return ($passedTests -eq $totalTests)
}

# Complete validation with real project
Test-CompleteValidation

function Test-CompleteValidation {
    Write-Info "Starting complete validation of Android development environment..."
    
    $validationResults = @{
        EnvironmentVariables = $false
        JavaInstallation = $false
        GradleInstallation = $false
        AndroidSDK = $false
        PlatformTools = $false
        BuildTools = $false
        SDKPlatforms = $false
        SampleProjectCreation = $false
        SampleProjectBuild = $false
        APKGeneration = $false
        OfflineCapability = $false
        MultipleAPILevels = $false
    }
    
    try {
        # Test 1: Environment Variables
        Write-Info "Validating environment variables..."
        $envValid = $true
        
        if (-not $env:JAVA_HOME) {
            Write-Warning "JAVA_HOME not set"
            $envValid = $false
        } else {
            Write-Success "JAVA_HOME: $env:JAVA_HOME"
        }
        
        if (-not $env:ANDROID_HOME) {
            Write-Warning "ANDROID_HOME not set"
            $envValid = $false
        } else {
            Write-Success "ANDROID_HOME: $env:ANDROID_HOME"
        }
        
        $validationResults.EnvironmentVariables = $envValid
        
        # Test 2: Java Installation
        Write-Info "Validating Java installation..."
        try {
            $javaVersion = & java -version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Java is working: $($javaVersion[0])"
                $validationResults.JavaInstallation = $true
            }
        }
        catch {
            Write-Warning "Java validation failed"
        }
        
        # Test 3: Gradle Installation
        Write-Info "Validating Gradle installation..."
        try {
            $gradleVersion = & gradle --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                $versionLine = $gradleVersion | Where-Object { $_ -like "*Gradle*" } | Select-Object -First 1
                Write-Success "Gradle is working: $versionLine"
                $validationResults.GradleInstallation = $true
            }
        }
        catch {
            Write-Warning "Gradle validation failed"
        }
        
        # Test 4: Android SDK
        Write-Info "Validating Android SDK..."
        try {
            $sdkmanagerPath = "$SDK_ROOT\cmdline-tools\latest\bin\sdkmanager.bat"
            if (Test-Path $sdkmanagerPath) {
                $sdkList = & $sdkmanagerPath --list 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Android SDK is working"
                    $validationResults.AndroidSDK = $true
                }
            }
        }
        catch {
            Write-Warning "Android SDK validation failed"
        }
        
        # Test 5: Platform Tools
        Write-Info "Validating Platform Tools..."
        try {
            $adbVersion = & adb version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "ADB is working: $($adbVersion[0])"
                $validationResults.PlatformTools = $true
            }
        }
        catch {
            Write-Warning "Platform Tools validation failed"
        }
        
        # Test 6: Build Tools
        Write-Info "Validating Build Tools..."
        $buildToolsPath = "$SDK_ROOT\build-tools"
        if (Test-Path $buildToolsPath) {
            $buildToolsDirs = Get-ChildItem $buildToolsPath -Directory
            if ($buildToolsDirs.Count -gt 0) {
                $latestBuildTools = $buildToolsDirs | Sort-Object Name -Descending | Select-Object -First 1
                $aaptPath = Join-Path $latestBuildTools.FullName "aapt.exe"
                if (Test-Path $aaptPath) {
                    Write-Success "Build Tools found: $($latestBuildTools.Name)"
                    $validationResults.BuildTools = $true
                }
            }
        }
        
        # Test 7: SDK Platforms
        Write-Info "Validating SDK Platforms..."
        $platformsPath = "$SDK_ROOT\platforms"
        if (Test-Path $platformsPath) {
            $platforms = Get-ChildItem $platformsPath -Directory
            if ($platforms.Count -gt 0) {
                Write-Success "Found $($platforms.Count) SDK platforms: $($platforms.Name -join ', ')"
                $validationResults.SDKPlatforms = $true
                if ($platforms.Count -gt 1) {
                    $validationResults.MultipleAPILevels = $true
                }
            }
        }
        
        # Test 8: Sample Project Creation
        Write-Info "Testing sample project creation..."
        $testProjectPath = Join-Path $ROOT "validationTestProject"
        
        if (Test-Path $testProjectPath) {
            Remove-Item $testProjectPath -Recurse -Force
        }
        
        # Create a more complex test project
        Ensure-Directory $testProjectPath
        Ensure-Directory "$testProjectPath\app\src\main\java\com\example\validation"
        Ensure-Directory "$testProjectPath\app\src\main\res\layout"
        Ensure-Directory "$testProjectPath\app\src\main\res\values"
        
        # Create build.gradle with multiple dependencies
        $projectBuildGradle = @"
plugins {
    id 'com.android.application' version '8.1.0' apply false
}
"@
        $projectBuildGradle | Out-File "$testProjectPath\build.gradle" -Encoding UTF8
        
        $settingsGradle = @"
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "ValidationTest"
include ':app'
"@
        $settingsGradle | Out-File "$testProjectPath\settings.gradle" -Encoding UTF8
        
        $appBuildGradle = @"
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.example.validation'
    compileSdk 33

    defaultConfig {
        applicationId "com.example.validation"
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.lifecycle:lifecycle-livedata-ktx:2.6.1'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1'
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
"@
        $appBuildGradle | Out-File "$testProjectPath\app\build.gradle" -Encoding UTF8
        
        # Create MainActivity with more complex functionality
        $mainActivity = @"
package com.example.validation;

import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.Button;
import android.view.View;

public class MainActivity extends AppCompatActivity {
    private int counter = 0;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        TextView textView = findViewById(R.id.textView);
        Button button = findViewById(R.id.button);
        
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter++;
                textView.setText("Clicked " + counter + " times");
            }
        });
    }
}
"@
        $mainActivity | Out-File "$testProjectPath\app\src\main\java\com\example\validation\MainActivity.java" -Encoding UTF8
        
        # Create more complex layout
        $activityMain = @"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <TextView
        android:id="@+id/textView"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Validation Test App"
        android:textSize="18sp"
        app:layout_constraintBottom_toTopOf="@+id/button"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <Button
        android:id="@+id/button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Click Me"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@+id/textView" />

</androidx.constraintlayout.widget.ConstraintLayout>
"@
        $activityMain | Out-File "$testProjectPath\app\src\main\res\layout\activity_main.xml" -Encoding UTF8
        
        $strings = @"
<resources>
    <string name="app_name">ValidationTest</string>
</resources>
"@
        $strings | Out-File "$testProjectPath\app\src\main\res\values\strings.xml" -Encoding UTF8
        
        $manifest = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.AppCompat"
        tools:targetApi="31">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
"@
        $manifest | Out-File "$testProjectPath\app\src\main\AndroidManifest.xml" -Encoding UTF8
        
        Write-Success "Validation test project created"
        $validationResults.SampleProjectCreation = $true
        
        # Test 9: Build Test Project
        Write-Info "Building validation test project..."
        Set-Location $testProjectPath
        
        $buildResult = & gradle assembleDebug 2>&1
        $buildExitCode = $LASTEXITCODE
        
        if ($buildExitCode -eq 0) {
            Write-Success "Validation test project built successfully"
            $validationResults.SampleProjectBuild = $true
            
            # Test 10: APK Generation
            $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
            if (Test-Path $apkPath) {
                $apkInfo = Get-Item $apkPath
                Write-Success "Validation APK generated: $($apkInfo.Name) ($([math]::Round($apkInfo.Length/1MB,2)) MB)"
                $validationResults.APKGeneration = $true
            }
        } else {
            Write-Warning "Validation test project build failed"
            Write-Host "Build output: $buildResult" -ForegroundColor Red
        }
        
        # Test 11: Offline Build Capability
        Write-Info "Testing offline build capability..."
        if (Test-Path "app\build") {
            Remove-Item "app\build" -Recurse -Force
        }
        
        $offlineResult = & gradle assembleDebug --offline 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Offline build capability confirmed"
            $validationResults.OfflineCapability = $true
        } else {
            Write-Warning "Offline build not available (may need initial online build)"
        }
        
    }
    catch {
        Write-Error "Error during complete validation: $($_.Exception.Message)"
    }
    finally {
        Set-Location $ROOT
        
        # Cleanup test project
        if (Test-Path $testProjectPath) {
            Remove-Item $testProjectPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    # Generate comprehensive validation report
    Write-Host ""
    Write-Host "===========================================" -ForegroundColor Magenta
    Write-Host "Complete Android Environment Validation" -ForegroundColor Magenta
    Write-Host "===========================================" -ForegroundColor Magenta
    
    $passedValidations = 0
    $totalValidations = $validationResults.Keys.Count
    
    foreach ($validation in $validationResults.Keys) {
        $status = if ($validationResults[$validation]) { "PASS" } else { "FAIL" }
        $color = if ($validationResults[$validation]) { "Green" } else { "Red" }
        
        Write-Host "$validation : $status" -ForegroundColor $color
        if ($validationResults[$validation]) { $passedValidations++ }
    }
    
    Write-Host ""
    Write-Host "Validation Summary: $passedValidations/$totalValidations checks passed" -ForegroundColor $(if ($passedValidations -eq $totalValidations) { "Green" } else { "Yellow" })
    
    if ($passedValidations -eq $totalValidations) {
        Write-Host ""
        Write-Host "🎉 CONGRATULATIONS! 🎉" -ForegroundColor Green
        Write-Host "Your Android development environment is fully functional and ready for offline development!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️  Some validations failed. Please review the issues above." -ForegroundColor Yellow
    }
    
    Write-Host "===========================================" -ForegroundColor Magenta
    
    return ($passedValidations -eq $totalValidations)
}
Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host "JAVA_HOME: $JAVA_HOME" -ForegroundColor Cyan
Write-Host "GRADLE_HOME: $GRADLE_HOME" -ForegroundColor Cyan
Write-Host "ANDROID_HOME: $SDK_ROOT" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sample project created at: $ROOT\sampleProject" -ForegroundColor Yellow
Write-Host ""
Write-Host "Please restart your system to ensure all environment" -ForegroundColor Yellow
Write-Host "variables are properly loaded." -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Green