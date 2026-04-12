$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"

if ($ResolveWingetPath){

    $WingetPath = $ResolveWingetPath[-1].Path

    # Fixing Permissions
    TAKEOWN /F $WingetPath /R /A /D Y
    ICACLS $WingetPath /grant Administrators:F /T

    # Adding it to current shell path
    $ENV:PATH += ";$WingetPath"

    # Adding it to path permanently
    [Environment]::SetEnvironmentVariable(
        "Path",
        [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";$WingetPath",
        [EnvironmentVariableTarget]::Machine)
}