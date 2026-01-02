$ErrorActionPreference = "Stop"

Write-Host "== Android Offline Auto Setup (Smart Discovery) =="

$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$INSTALL = "D:\Android"

$JAVA_HOME    = "$INSTALL\JDK17"
$GRADLE_HOME  = "$INSTALL\Gradle"
$SDK_ROOT     = "$INSTALL\Sdk"
$GRADLE_CACHE = "$INSTALL\.gradle"

# ---------------- utils ----------------

function Fail($msg) {
    Write-Host "❌ ERROR: $msg" -ForegroundColor Red
    exit 1
}

function Ensure($p) {
    if (!(Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

function Valid-Zip($zip) {
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $fs = [IO.File]::OpenRead($zip)
        $z = New-Object IO.Compression.ZipArchive($fs)
        $z.Dispose(); $fs.Close()
        return $true
    } catch { return $false }
}

function Expand-ZipSmart($zip) {
    if (!(Valid-Zip $zip)) { Fail "Corrupted zip: $zip" }
    $target = Join-Path $ROOT ([IO.Path]::GetFileNameWithoutExtension($zip))
    Write-Host "Extracting $($zip | Split-Path -Leaf)"
    Expand-Archive $zip $target -Force
    return $target
}

function Find-Or-Extract($predicate) {

    # 1️⃣ Search folders
    Get-ChildItem $ROOT -Recurse -Directory | ForEach-Object {
        if (& $predicate $_) { return $_.FullName }
    }

    # 2️⃣ Search zip files
    Get-ChildItem $ROOT -Recurse -Filter *.zip | ForEach-Object {
        $dir = Expand-ZipSmart $_.FullName
        if (& $predicate (Get-Item $dir)) { return $dir }
    }

    return $null
}

# ---------------- prepare ----------------

Ensure $INSTALL
Ensure $JAVA_HOME
Ensure $GRADLE_HOME
Ensure $SDK_ROOT
Ensure $GRADLE_CACHE

# ---------------- JDK ----------------

Write-Host "Searching for JDK 17..."
$jdk = Find-Or-Extract { Test-Path "$($_.FullName)\bin\java.exe" }
if (!$jdk) { Fail "JDK 17 not found (java.exe missing)" }
Copy-Item "$jdk\*" $JAVA_HOME -Recurse -Force

# ---------------- Gradle ----------------

Write-Host "Searching for Gradle..."
$gradle = Find-Or-Extract { Test-Path "$($_.FullName)\bin\gradle.bat" }
if (!$gradle) { Fail "Gradle not found (gradle.bat missing)" }
Copy-Item "$gradle\*" $GRADLE_HOME -Recurse -Force

# ---------------- Android SDK ----------------

Write-Host "Searching for Android SDK..."
$sdk = Find-Or-Extract { Test-Path "$($_.FullName)\platforms\android-33" }
if (!$sdk) { Fail "Android SDK (platform 33) not found" }
Copy-Item "$sdk\*" $SDK_ROOT -Recurse -Force

# ---------------- platform-tools check ----------------

if (!(Test-Path "$SDK_ROOT\platform-tools\adb.exe")) {
    Fail "platform-tools missing (adb.exe not found)"
}

# ---------------- env vars ----------------

Write-Host "Configuring environment variables..."

[Environment]::SetEnvironmentVariable("JAVA_HOME",$JAVA_HOME,"Machine")
[Environment]::SetEnvironmentVariable("ANDROID_HOME",$SDK_ROOT,"Machine")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT",$SDK_ROOT,"Machine")
[Environment]::SetEnvironmentVariable("GRADLE_HOME",$GRADLE_HOME,"Machine")

$path = [Environment]::GetEnvironmentVariable("Path","Machine")
@(
 "$JAVA_HOME\bin",
 "$GRADLE_HOME\bin",
 "$SDK_ROOT\platform-tools"
) | ForEach-Object {
    if ($path -notlike "*$_*") { $path += ";$_" }
}

[Environment]::SetEnvironmentVariable("Path",$path,"Machine")

# ---------------- seed project ----------------

Write-Host "Creating seed project..."
$PROJ = "$INSTALL\SeedProject"

if (!(Test-Path $PROJ)) {
    & "$GRADLE_HOME\bin\gradle.bat" init `
        --type basic `
        --dsl groovy `
        --project-name SeedProject `
        --project-dir $PROJ `
        --no-daemon
}

Write-Host ""
Write-Host "✅ Android Offline Environment Ready" -ForegroundColor Green
Write-Host "Reboot Windows once."