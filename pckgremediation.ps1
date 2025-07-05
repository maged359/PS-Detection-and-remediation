# Multi-App Proactive Remediation Script: Chrome, 7-Zip, TeamViewer, Firefox, Company Portal, Zoom, Quick Assist

# Define working folder and log
$downloadFolder = "C:\Apps"
$logFile = Join-Path $downloadFolder "InstallApps.log"

# Create download folder if it doesn't exist
if (-not (Test-Path $downloadFolder)) {
    try {
        New-Item -Path $downloadFolder -ItemType Directory -Force | Out-Null
        Add-Content -Path $logFile -Value "$(Get-Date) - Created folder: $downloadFolder"
    } catch {
        Add-Content -Path $logFile -Value "$(Get-Date) - Failed to create folder: $_"
        exit 1
    }
}

# Application definitions
$apps = @(
    @{
        Name = "Google Chrome"
        Url  = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        Installer = "ChromeSetup.exe"
        Arguments = "/silent /install"
        VerifyPath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    },
    @{
        Name = "7-Zip"
        Url  = "https://www.7-zip.org/a/7z2301-x64.exe"
        Installer = "7zipSetup.exe"
        Arguments = "/S"
        VerifyPath = "C:\Program Files\7-Zip\7zFM.exe"
    },
    @{
        Name = "TeamViewer"
        Url  = "https://download.teamviewer.com/download/TeamViewer_Setup.exe"
        Installer = "TeamViewerSetup.exe"
        Arguments = "/S"
        VerifyPath = "C:\Program Files (x86)\TeamViewer\TeamViewer.exe"
    },
    @{
        Name = "Firefox"
        Url  = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US"
        Installer = "FirefoxSetup.exe"
        Arguments = "-ms"
        VerifyPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
    },
    @{
        Name = "Company Portal"
        Url  = "https://aka.ms/companyportal"
        Installer = "CompanyPortal.msixbundle"
        Arguments = $null  # Installed with Add-AppxPackage
        VerifyPath = "C:\Program Files\WindowsApps\Microsoft.CompanyPortal_*"
        IsAppx = $true
    },
    @{
        Name = "Zoom"
        Url  = "https://zoom.us/client/latest/ZoomInstallerFull.msi"
        Installer = "ZoomInstaller.msi"
        Arguments = "/quiet"
        VerifyPath = "C:\Program Files (x86)\Zoom\bin\Zoom.exe"
        IsMSI = $true
    },
    @{
        Name = "Quick Assist"
        Url  = $null
        Installer = $null
        Arguments = $null
        VerifyPath = "C:\Windows\System32\quickassist.exe"
    }
)

foreach ($app in $apps) {
    $name = $app.Name
    $installer = if ($app.Installer) { Join-Path $downloadFolder $app.Installer } else { $null }

    if ($app.Url) {
        # Download
        try {
            Invoke-WebRequest -Uri $app.Url -OutFile $installer -UseBasicParsing
            Add-Content -Path $logFile -Value "$(Get-Date) - Downloaded ${name}"
        } catch {
            Add-Content -Path $logFile -Value "$(Get-Date) - Failed to download ${name}: $_"
            continue
        }

        # Install
        try {
            if ($app.IsAppx) {
                Add-AppxPackage -Path $installer -ForceApplicationShutdown
                Add-Content -Path $logFile -Value "$(Get-Date) - Installed ${name} via Add-AppxPackage"
            } elseif ($app.IsMSI) {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$installer`" $($app.Arguments)" -Wait -NoNewWindow
                Add-Content -Path $logFile -Value "$(Get-Date) - Installed ${name} via MSI"
            } else {
                Start-Process -FilePath $installer -ArgumentList $app.Arguments -Wait -NoNewWindow
                Start-Sleep -Seconds 10
                Add-Content -Path $logFile -Value "$(Get-Date) - Installed ${name} silently"
            }
        } catch {
            Add-Content -Path $logFile -Value "$(Get-Date) - Installation failed for ${name}: $_"
            continue
        }
    }

    # Verify
    $isInstalled = $false

    if ($app.IsAppx) {
        $isInstalled = Get-AppxPackage | Where-Object { $_.Name -eq "Microsoft.CompanyPortal" }
    } elseif (Test-Path $app.VerifyPath) {
        $isInstalled = $true
    }

    if ($isInstalled) {
        Add-Content -Path $logFile -Value "$(Get-Date) - ${name} verified at $($app.VerifyPath)"
    } else {
        Add-Content -Path $logFile -Value "$(Get-Date) - ${name} not found at $($app.VerifyPath)"
    }
}

exit 0
