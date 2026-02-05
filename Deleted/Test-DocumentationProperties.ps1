Import-Module Pester -Force

Describe "Documentation System Property Tests" {
    
    It "Should have installation documents for all components" {
        $ExpectedComponents = @(
            "01-jdk17-installation.md",
            "02-android-studio-installation.md", 
            "03-gradle-installation.md",
            "04-commandline-tools-installation.md",
            "05-platform-tools-installation.md",
            "06-build-tools-installation.md",
            "07-sdk-platforms-installation.md",
            "08-system-images-installation.md",
            "09-repositories-installation.md",
            "10-sdk-licenses-installation.md"
        )
        
        $DocsPath = "docs"
        $MissingDocs = @()
        
        foreach ($ComponentFile in $ExpectedComponents) {
            $DocPath = Join-Path $DocsPath $ComponentFile
            if (-not (Test-Path $DocPath)) {
                $MissingDocs += $ComponentFile
            }
        }
        
        $MissingDocs.Count | Should Be 0
    }
    
    It "Each document should contain basic content" {
        $ExpectedComponents = @(
            "01-jdk17-installation.md",
            "02-android-studio-installation.md", 
            "03-gradle-installation.md",
            "04-commandline-tools-installation.md",
            "05-platform-tools-installation.md",
            "06-build-tools-installation.md",
            "07-sdk-platforms-installation.md",
            "08-system-images-installation.md",
            "09-repositories-installation.md",
            "10-sdk-licenses-installation.md"
        )
        
        $IncompleteDocuments = @()
        
        foreach ($ComponentFile in $ExpectedComponents) {
            $DocPath = Join-Path "docs" $ComponentFile
            if (Test-Path $DocPath) {
                $Content = Get-Content $DocPath -Raw -Encoding UTF8
                if ($Content.Length -lt 100) {
                    $IncompleteDocuments += $ComponentFile
                }
            }
        }
        
        $IncompleteDocuments.Count | Should Be 0
    }
    
    It "Test guides should include code blocks" {
        $ExpectedComponents = @(
            "01-jdk17-installation.md",
            "02-android-studio-installation.md", 
            "03-gradle-installation.md",
            "04-commandline-tools-installation.md",
            "05-platform-tools-installation.md",
            "06-build-tools-installation.md",
            "07-sdk-platforms-installation.md",
            "08-system-images-installation.md",
            "09-repositories-installation.md",
            "10-sdk-licenses-installation.md"
        )
        
        $TestsWithoutCommands = @()
        $CodeBlockPattern = '```'
        
        foreach ($ComponentFile in $ExpectedComponents) {
            $DocPath = Join-Path "docs" $ComponentFile
            if (Test-Path $DocPath) {
                $Content = Get-Content $DocPath -Raw -Encoding UTF8
                if ($Content -notmatch $CodeBlockPattern) {
                    $TestsWithoutCommands += $ComponentFile
                }
            }
        }
        
        $TestsWithoutCommands.Count | Should Be 0
    }
}