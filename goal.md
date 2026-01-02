GOAL:
Create a COMPLETE, RELIABLE, and DEFENSIVE offline Android development pipeline.

SCOPE:
1. GitHub Actions workflow
2. Offline Windows installer automation
3. End-to-end validation (SDK → build → Hello World APK)

HARD REQUIREMENTS (do NOT violate):
- Everything must be fully offline after artifacts are downloaded
- Every downloadable file MUST be:
  - downloaded via direct binary URL (NO HTML pages)
  - validated before use (ZIP integrity test)
  - uploaded as a SEPARATE GitHub Artifact
- No assumptions about folder names or structure
- Defensive error handling with clear messages
- No emojis
- No placeholders
- Use actions/upload-artifact@v4 only

────────────────────────────────────────
PART 1 — GitHub Actions (Downloader + Validator)
────────────────────────────────────────

Create ONE GitHub Actions workflow that:

1. Downloads ALL required Android offline components, EACH AS A SEPARATE FILE:
   - JDK 17 (Windows x64 ZIP)
   - Gradle (exact version compatible with Android Studio 2022.3.1)
   - Android SDK Command-line Tools (Windows)
   - Platform-tools
   - Build-tools 33.x
   - SDK Platforms: API 33, API 30, API 27
   - Android Emulator system image (API 33 x86_64 Google APIs)
   - AndroidX / Google Maven repositories (android_m2repository, google_m2repository)

2. For EACH downloaded file:
   - Validate it is a real ZIP (not HTML, not redirect)
   - Fail immediately if:
     - file size is suspiciously small
     - ZIP integrity check fails
   - Upload it as its OWN artifact (one file = one artifact)

3. Artifacts must be clearly named (example):
   - jdk-17
   - gradle-7.5
   - sdk-platform-33
   - build-tools-33.0.2
   - etc.

4. The workflow MUST FAIL if ANY single file is invalid.

────────────────────────────────────────
PART 2 — Offline Windows Installer Script
────────────────────────────────────────

Create ONE PowerShell script that:

1. Runs fully offline
2. Installs everything under:
   D:\Android\

3. For EACH required component (JDK, Gradle, SDK, etc):
   - If already installed → skip
   - Else:
     - Search recursively for an extracted folder containing the expected executable
     - If not found → search recursively for a ZIP
     - If ZIP found → validate ZIP → extract → install
     - If nothing found → FAIL with explicit error

4. NEVER assume:
   - file names
   - folder names
   - archive layout

5. Validate installation by checking:
   - java -version
   - gradle -v
   - adb version
   - sdkmanager list

6. Set system-wide environment variables:
   - JAVA_HOME
   - ANDROID_HOME
   - ANDROID_SDK_ROOT
   - PATH

────────────────────────────────────────
PART 3 — Automated Validation Build
────────────────────────────────────────

After installation, the script MUST:

1. Create a brand-new Android project:
   - Hello World
   - Minimum SDK: 21
   - Compile SDK: 33
   - No Compose (XML-based)

2. Build the project completely offline:
   - ./gradlew assembleDebug --offline

3. Verify:
   - APK exists
   - Build succeeded

4. Output:
   - Absolute path to the generated APK
   - Clear SUCCESS message

────────────────────────────────────────
FAILURE POLICY
────────────────────────────────────────

- If ANY step fails:
  - Stop immediately
  - Print:
    - What failed
    - Why
    - What file or component is missing or corrupted

────────────────────────────────────────
DELIVERABLES
────────────────────────────────────────

Return:
1. Full GitHub Actions YAML
2. Full PowerShell installer script
3. Short explanation of verification logic

NO explanations in between.
NO assumptions.
NO shortcuts.