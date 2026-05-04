# Define Paths
$ghFolder = Join-Path -Path $env:LOCALAPPDATA -ChildPath "GitHubCLI"
if (-not (Test-Path $ghFolder)) {
    New-Item -Path $ghFolder -ItemType Directory | Out-Null
}

# 2. Get the latest version via GitHub API (much more reliable than scraping HTML)
try {
    $apiResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/cli/cli/releases/latest"
    $version = $apiResponse.tag_name # e.g., "v2.40.0"
    $versionNoV = $version.TrimStart('v')
} catch {
    Write-Error "Failed to fetch latest version from GitHub API."
    return
}

# 3. Download the zip
$zipFileName = "gh_$($versionNoV)_windows_amd64.zip"
$downloadUrl = "https://github.com/cli/cli/releases/download/$version/$zipFileName"
$zipPath = Join-Path -Path $env:TEMP -ChildPath $zipFileName

Write-Host "Downloading GH CLI $version..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

# 4. Extract and Organize
# The zip contains a folder named 'gh_v.v.v_windows_amd64'
$extractTemp = Join-Path -Path $env:TEMP -ChildPath "gh_temp_extract"
if (Test-Path $extractTemp) { Remove-Item $extractTemp -Recurse -Force }

Expand-Archive -LiteralPath $zipPath -DestinationPath $extractTemp -Force

# Move the 'bin' content to our permanent folder
$extractedFolder = Get-ChildItem -Path $extractTemp -Directory | Select-Object -First 1
Copy-Item -Path "$($extractedFolder.FullName)\*" -Destination $ghFolder -Recurse -Force

# 5. Clean up temp files
Remove-Item $zipPath -Force
Remove-Item $extractTemp -Recurse -Force

# 6. Update Environment PATH
$ghBinPath = $ghFolder
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')

if ($userPath -split ';' -notcontains $ghBinPath) {
    Write-Host "Adding $ghBinPath to User PATH..." -ForegroundColor Yellow
    $newUserPath = "$userPath;$ghBinPath".TrimEnd(';')
    [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
    
    # Update current session path so you can use 'gh' immediately
    $env:Path += ";$ghBinPath"
}

Write-Host "Success! GitHub CLI ($version) is installed at $ghFolder" -ForegroundColor Green
Write-Host "You may need to restart your terminal to use 'gh'." -ForegroundColor Gray