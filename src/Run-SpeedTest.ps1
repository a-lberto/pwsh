if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "Winget not found. Install App Installer from Store."
}

$id = "Ookla.Speedtest"
if (-not (winget list --id $id -e --accept-source-agreements)) {
    winget install --id $id --exact --silent --accept-source-agreements --accept-package-agreements
}

# Run speedtest. Output CSV for easy post-processing.
speedtest --format=csv