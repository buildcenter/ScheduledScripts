# Global preference
$ErrorActionPreference = 'Stop'

$localizedDataFile = 'MountVHD.psd1'
$basePath = Resolve-Path "$PSScriptRoot\..\.." | select -expand Path
$taskConfigPath = Join-Path "$basePath" -ChildPath "Configuration\MountVHD.json"
if (Test-Path $taskConfigPath -PathType Leaf)
{
    $taskConfig = ConvertFrom-Json ((Get-Content -Path $taskConfigPath) -join [Environment]::NewLine)
}

# --- Config ---
# Error, Information, Verbose
$logLevel = $(if ($taskConfig.logLevel) { $taskConfig.logLevel } else { 'Information' })
$vhdBasePath = $(if ($taskConfig.vhdBasePath) { $taskConfig.vhdBasePath } else { (Join-Path $env:ProgramData -ChildPath "Blobs") })
# --- /Config ---

. (Join-Path $basePath -ChildPath 'Logging.ps1')

if ((-not $taskConfig) -or ($taskConfig.vhd -isnot [psobject]))
{
    WriteToWindowsLog NoVHDToMount
    return
}

$vhdNames = $taskConfig.vhd | Get-Member -MemberType NoteProperty | select -expand Name

$vhdNames | where { ($_ -ne $null) -and ($_ -ne '') } | ForEach-Object {
    $vhdFilePath = Join-Path $vhdBasePath -ChildPath "$_.vhdx"
    $vhdToMount = $taskConfig.vhd."$_"

    if (Test-Path $vhdFilePath -PathType Leaf)
    {
        try
        {
            $vhdInfo = Get-VHD $vhdFilePath

            if ($vhdInfo.Attached -eq $true)
            {
                WriteWindowsLog VHDAlreadyMounted -Data $vhdFilePath
            }
            else
            {
                if (-not $vhdToMount.driveLetter)
                {
                    WriteWindowsLog MountingVHD -Data $vhdFilePath
                    Mount-VHD -Path $vhdFilePath
                }
                else
                {
                    $usedDriveLetters = Get-PSDrive -PSProvider FileSystem | select -expand Name

                    if (($vhdToMount.driveLetter -in $usedDriveLetters) -and
                        ($vhdToMount.ensure -eq $true))
                    {
                        WriteWindowsLog MountDriveLetterInUse -Data $vhdToMount.driveLetter, $vhdFilePath
                    }
                    else
                    {
                        WriteWindowsLog MountVHDToDriveLetter -Data $vhdToMount.driveLetter, $vhdFilePath
                        $vhd = Mount-VHD -Path $vhdFilePath -NoDriveLetter -Passthru
                        Add-PartitionAccessPath $vhd.Number -PartitionNumber 2 -AccessPath ('{0}:\' -f $vhdToMount.driveLetter)
                    }
                }
            }
        }
        catch
        {
            WriteWindowsLog MountVHDError -Data $vhdFilePath, ($_ | Out-String)
        }
    }
}