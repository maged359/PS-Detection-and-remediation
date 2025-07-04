# Detection Script for Chrome, 7-Zip, TeamViewer, Firefox, Company Portal, Zoom, Quick Assist

$missingApps = @()

# Check Chrome
if (-not (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe")) {
    $missingApps += "Google Chrome"
}

# Check 7-Zip
if (-not (Test-Path "C:\Program Files\7-Zip\7zFM.exe")) {
    $missingApps += "7-Zip"
}

# Check TeamViewer
if (-not (Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")) {
    $missingApps += "TeamViewer"
}

# Check Firefox
if (-not (Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {
    $missingApps += "Firefox"
}

# Check Company Portal via AppxPackage
$companyPortal = Get-AppxPackage -Name "Microsoft.CompanyPortal" -ErrorAction SilentlyContinue
if (-not $companyPortal) {
    $missingApps += "Company Portal"
}

# Check Zoom
if (-not (Test-Path "C:\Program Files (x86)\Zoom\bin\Zoom.exe")) {
    $missingApps += "Zoom"
}

# Check Quick Assist
if (-not (Test-Path "C:\Windows\System32\quickassist.exe")) {
    $missingApps += "Quick Assist"
}

# Output results
if ($missingApps.Count -eq 0) {
    Write-Output "All required applications are installed."
    exit 0
} else {
    Write-Output "Missing applications: $($missingApps -join ', ')"
    exit 1
}
