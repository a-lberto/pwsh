#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs the necessary PowerShell module and repairs the WinGet Package Manager.
.DESCRIPTION
    This script ensures the system is prepared by checking for Admin rights and internet connectivity.
    It then installs or updates the 'Microsoft.WinGet.Client' module from the PSGallery.
    Finally, it attempts to repair the WinGet installation, with a retry mechanism for robustness.
	Tested on Windows 10 IoT Enterprise LTSC.
	Base commands from https://learn.microsoft.com/en-us/windows/package-manager/winget/
	
#>

# --- Initial Checks ---
# Check for internet connection.
if (-not (Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet)) {
    Write-Error "Error: Internet connection not found. Please connect to the internet and try again."
    exit 1
}

# --- Configuration ---
$progressPreference = 'silentlyContinue'
$moduleName = "Microsoft.WinGet.Client"
$maxRetries = 3

# --- Module Installation ---
try {
    # Ensure NuGet Package Provider is installed
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        Write-Host "Installing NuGet Package Provider..."
        Install-PackageProvider -Name NuGet -Force | Out-Null
    }

    # Check if the module is installed and install if missing
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Host "Installing WinGet client module..."
        Install-Module -Name $moduleName -Force -Repository PSGallery -ErrorAction Stop | Out-Null
    }
}
catch {
    Write-Error "Fatal: Failed to install the '$moduleName' module. Error: $($_.Exception.Message)"
    exit 1
}


# --- Repair WinGet ---
$retryCount = 0
$success = $false

do {
    try {
        # Attempt to repair the package manager. -ErrorAction Stop is crucial for the catch block.
        Repair-WinGetPackageManager -AllUsers -ErrorAction Stop
        $success = $true
    }
    catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            # Wait for a moment before the next attempt.
            Start-Sleep -Seconds 3
        }
    }
} until ($success -or ($retryCount -ge $maxRetries))

# --- Final Status ---
if ($success) {
    # Verify the repair by checking the version.
    $wingetVersion = (winget --version)
    Write-Host "Success: WinGet is ready. $wingetVersion"
}
else {
    Write-Error "Failure: Could not repair WinGet Package Manager after $maxRetries attempts."
    exit 1
}
