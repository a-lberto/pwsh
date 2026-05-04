# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms

$wsh = New-Object -ComObject WScript.Shell
Write-Host "Keep-Alive script started. Press Ctrl+C to stop." -ForegroundColor Green

while ($true) {
    # 1. Move the mouse slightly (randomly within a 5-pixel range)
    $currentPos = [System.Windows.Forms.Cursor]::Position
    $x = $currentPos.X + (Get-Random -Minimum -5 -Maximum 5)
    $y = $currentPos.Y + (Get-Random -Minimum -5 -Maximum 5)
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)

    # 2. Press a non-intrusive key (Scroll Lock is classic for this)
    # We press it twice to toggle it back to the original state
    $wsh.SendKeys('{SCROLLLOCK}')
    Start-Sleep -Milliseconds 100
    $wsh.SendKeys('{SCROLLLOCK}')

    # 3. Wait for a random interval (e.g., every 30 to 60 seconds)
    $wait = Get-Random -Minimum 30 -Maximum 60
    Write-Host "Activity simulated. Next check in $wait seconds..."
    Start-Sleep -Seconds $wait
}