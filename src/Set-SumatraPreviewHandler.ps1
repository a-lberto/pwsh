# CLSID for SumatraPDF Preview Handler
$sumatraPdfPreviewHandlerClsid = "{3D3B1846-CC43-42AE-BFF9-D914083C2BA3}"

# Registry path for the PDF preview handler for the current user
$pdfPreviewHandlerRegPath = "Registry::HKEY_CURRENT_USER\Software\Classes\.pdf\shellex\{8895b1c6-b41f-4c1c-a562-0d564250836f}"

Write-Host "Attempting to set SumatraPDF as the default PDF preview handler for the current user..."
Write-Host "This script does not require administrative privileges."

# Ensure the full registry path exists, creating it if necessary.
# New-Item -Force creates parent keys if they don't exist.
Try {
    If (-not (Test-Path $pdfPreviewHandlerRegPath)) {
        New-Item -Path $pdfPreviewHandlerRegPath -Force -ErrorAction Stop | Out-Null
        Write-Host "Created registry path: $pdfPreviewHandlerRegPath"
    }
}
Catch {
    Write-Error "Failed to create necessary registry path: $($_.Exception.Message)."
    Write-Error "Please ensure you have permissions to write to HKEY_CURRENT_USER\Software\Classes."
    Exit 1
}

# Set SumatraPDF as the default preview handler for PDFs for the current user
Try {
    Set-ItemProperty -Path $pdfPreviewHandlerRegPath -Name "(Default)" -Value $sumatraPdfPreviewHandlerClsid -Force -ErrorAction Stop
    Write-Host "Successfully set SumatraPDF as the default PDF preview handler for the current user."
    Write-Host "You may need to restart Windows Explorer (File Explorer) or log off and back on for the changes to take full effect."

    # Optional: Attempt to restart Windows Explorer to apply changes immediately
    Write-Warning "Restarting Windows Explorer will close and reopen all File Explorer windows and your taskbar."
    $confirmation = Read-Host "Do you want to attempt to restart Windows Explorer now? (Y/N)"
    If ($confirmation -match '^[Yy]$') {
        Try {
            Get-Process explorer | Stop-Process -Force -ErrorAction Stop
            Write-Host "Windows Explorer stopping... Please wait a moment for it to restart."
            # Explorer usually restarts automatically. Wait a bit to check.
            Start-Sleep -Seconds 5
            If (-not (Get-Process explorer -ErrorAction SilentlyContinue)) {
                Write-Host "Explorer did not restart automatically, attempting to start it..."
                Start-Process explorer
                Write-Host "Windows Explorer started."
            } Else {
                Write-Host "Windows Explorer should have restarted."
            }
        } Catch {
            Write-Warning "An error occurred while trying to restart Windows Explorer: $($_.Exception.Message)"
            Write-Warning "Please restart Windows Explorer manually or log off/on."
        }
    } Else {
        Write-Host "Windows Explorer was not restarted. Please do so manually or log off/on for changes to apply."
    }
}
Catch {
    Write-Error "Failed to set SumatraPDF as the default PDF preview handler: $($_.Exception.Message)."
    Write-Error "Ensure that SumatraPDF is installed correctly and its preview handler is registered on the system."
}