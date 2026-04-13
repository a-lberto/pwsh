[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [string]$Path = ".",

    [Alias("L")]
    [int]$MaxLevel = 0,

    [Alias("a")]
    [switch]$All
)

$script:DirCount = 0
$script:FileCount = 0

function Get-CleanTree {
    param (
        [string]$Directory,
        [string]$Prefix = "",
        [int]$CurrentLevel = 0,
        [int]$Limit = 0,
        [switch]$ShowAll
    )

    if ($Limit -gt 0 -and $CurrentLevel -ge $Limit) { return }

    try {
        $ItemObj = Get-Item $Directory -ErrorAction Stop
        $Items = Get-ChildItem -Path $ItemObj.FullName -ErrorAction Stop | 
                 Where-Object { $ShowAll -or -not $_.Name.StartsWith('.') } | 
                 Sort-Object Name
    }
    catch { return }

    for ($i = 0; $i -lt $Items.Count; $i++) {
        $Item = $Items[$i]
        $IsLast = ($i -eq ($Items.Count - 1))
        
        # Fixed Ternary replacement
        $Connector = if ($IsLast) { "└── " } else { "├── " }

        Write-Host "$Prefix$Connector$($Item.Name)"

        if ($Item.PSIsContainer) {
            $script:DirCount++
            # Fixed Ternary replacement
            $StepPrefix = if ($IsLast) { "    " } else { "│   " }
            $NewPrefix = $Prefix + $StepPrefix

            Get-CleanTree -Directory $Item.FullName `
                          -Prefix $NewPrefix `
                          -CurrentLevel ($CurrentLevel + 1) `
                          -Limit $Limit `
                          -ShowAll:$ShowAll
        }
        else {
            $script:FileCount++
        }
    }
}

if (Test-Path $Path) {
    Write-Host (Get-Item $Path).Name
    
    $Root = Get-Item $Path
    Get-CleanTree -Directory $Root.FullName -Limit $MaxLevel -ShowAll:$All
    
    # Fixed Summary logic for PS 5.1 compatibility
    $dStr = if ($script:DirCount -eq 1) { "directory" } else { "directories" }
    $fStr = if ($script:FileCount -eq 1) { "file" } else { "files" }
    
    Write-Host "`n$script:DirCount $dStr, $script:FileCount $fStr"
}
else {
    Write-Error "tree: [${Path} name not found]: No such file or directory"
}