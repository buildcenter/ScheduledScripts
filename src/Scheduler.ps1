Param(
    [Parameter(Mandatory, Position = 1)]
    [ValidateSet(
        'Startup', 'Shutdown',
        'Daily', 'Weekly', 'Monthly', 
        'EnsureDaily', 'EnsureWeekly', 'EnsureMonthly'
    )]
    [string]$Recurrance
)

# Global preference
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot -ChildPath 'Logging.ps1')

if ($Recurrance -in @('Startup', 'Shutdown'))
{
    $cronScriptPath = Join-Path "$PSScriptRoot\Tasks" -ChildPath $Recurrance
    $logSource = $Recurrance
    $logName = 'Host Access'
}
elseif ($Recurrance -like 'Ensure*')
{
    $cronScriptPath = Join-Path "$PSScriptRoot\Tasks\Battery Exempted" -ChildPath $Recurrance.Substring(6)
    $logSource = $Recurrance.Substring(6)
    $logName = 'Scheduled Scripts'
}
else
{
    $cronScriptPath = Join-Path "$PSScriptRoot\Tasks" -ChildPath $Recurrance
    $logSource = $Recurrance
    $logName = 'Scheduled Scripts'
}

if ($Recurrance -eq 'Startup')
{
    $existingLogs = Get-EventLog -List | select -expand Log

    $requiredLogs = @{
        'Scheduled Scripts' = @{
            'Source' = @('Daily', 'Monthly', 'Weekly')
        }
        'Host Access' = @{
            'Source' = @('Startup', 'Shutdown', 'Logon', 'Logout', 'UserOOBE')
        }
    }

    $requiredLogs.Keys | ForEach-Object {
        if ($_ -notin $existingLogs)
        {
            $createLogName = $_

            try
            {
                New-EventLog -LogName $createLogName -Source $requiredLogs."$createLogName".Source
                WriteWindowsLog StartupCreateLog -Data $createLogName
            }
            catch
            {
                WriteWindowsLog StartupCreateLogError -Data ($createLogName, ($_ | Out-String))
                return
            }
        }
    }
}


#######################################################################
#  Main
#######################################################################

try
{
    WriteWindowsLog ScheduleScriptStarted -LogName $logName -Source $logSource -Data "$env:USERDOMAIN\$env:USERNAME"
}
catch
{
    WriteWindowsLog WriteLogError -Data ($logName, ($_ | Out-String))
    return
}

try
{
    if (-not (Test-Path $cronScriptPath -PathType Container))
    {
        WriteWindowsLog ScriptDirNotFound -LogName $logName -Source $logSource -Data $cronScriptPath
        return
    }

    $cronScripts = dir $cronScriptPath -File | where { $_.Extension -eq '.ps1' }
    if (-not $cronScripts)
    {
        WriteWindowsLog NoScriptFile -LogName $logName -Source $logSource
        return
    }

    $cronScripts | ForEach-Object {
        WriteWindowsLog RunningScript -LogName $logName -Source $logSource -Data $_.BaseName
        powershell.exe -ExecutionPolicy Unrestricted -NonInteractive -NoLogo -NoProfile -File $_.FullName
    }

    WriteWindowsLog ScheduleScriptFinished -LogName $logName -Source $logSource
}
catch
{
    WriteWindowsLog ScheduleScriptError -LogName $logName -Source $logSource -Data ($_ | Out-String)
}
