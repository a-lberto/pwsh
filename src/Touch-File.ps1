param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Paths
    )

process {
    foreach ($path in $Paths) {
        if (Test-Path $path) {
            # If file exists, update the LastWriteTime (equivalent to Linux touch)
            (Get-Item $path).LastWriteTime = Get-Date
        } else {
            # If file doesn't exist, create an empty file
            New-Item -ItemType File -Path $path
        }
    }
}