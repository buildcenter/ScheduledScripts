$cronScriptPath = Join-Path $env:ProgramData -ChildPath 'Scheduled Scripts'
$cronVbsLauncher = Join-Path $cronScriptPath -ChildPath 'Scheduler.vbs'

# ---[ START CONFIG ]---

$cronFolderPath = 'System Scripts'

$taskProfiles = @{
    'Daily Tasks' = @{
        Description = 'Runs all scripts under "%PROGRAMDATA%\Scheduled Scripts\Tasks\Daily\*.ps1" every day from about 3:00PM to 3:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on, but the PC should be running on AC power. This task will not execute again until the next scheduled time if it missed its scheduled start for any reason.'
        Action = @{
            Execute = 'wscript.exe'
            Arguments = '"{0}" Daily' -f $cronVbsLauncher
        }
        StartTime = '15:00:00'
    }
    'Daily Tasks (battery exempted)' = @{
        Description = 'Runs all scripts under "%PROGRAMDATA%\Scheduled Scripts\Tasks\Battery Exempted\Daily\*.ps1" every day from about 3:00PM to 3:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on. This task will run on both battery and AC power. This task will not execute again until the next scheduled time if it missed its scheduled start for any reason.'
        Action = @{
            Execute = 'wscript.exe'
            Arguments = '"{0}" EnsureDaily' -f $cronVbsLauncher
        }
        StartTime = '15:00:00'
    }
    'Weekly Tasks' = @{
        Description = 'Runs all scripts under "%PROGRAMDATA%\Scheduled Scripts\Tasks\Weekly\*.ps1" every Monday from about 4:00PM to 4:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on, but the PC should be running on AC power. This task will not execute again until the next scheduled time if it missed its scheduled start for any reason.'
        Action = @{
            Execute = 'wscript.exe'
            Arguments = '"{0}" Weekly' -f $cronVbsLauncher
        }
        StartTime = '16:00:00'
    }
    'Weekly Tasks (battery exempted)' = @{
        Description = 'Runs all scripts under "%PROGRAMDATA%\Scheduled Scripts\Tasks\Battery Exempted\Weekly\*.ps1" every Monday from about 4:00PM to 4:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on. This task will run on both battery and AC power. This task will not execute again until the next scheduled time if it missed its scheduled start for any reason.'
        Action = @{
            Execute = 'wscript.exe'
            Arguments = '"{0}" EnsureWeekly' -f $cronVbsLauncher
        }
        StartTime = '16:00:00'
    }
    'Monthly Tasks' = @{
        Description = 'Runs all scripts under "%PROGRAMDATA%\Scheduled Scripts\Tasks\Monthly\*.ps1" on the first day of every month from about 5:00PM to 5:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on, but the PC should be running on AC power. This task will not execute again until the next scheduled time if it missed its scheduled start for any reason.'
        Action = @{
            Execute = 'wscript.exe'
            Arguments = '"{0}" Monthly' -f $cronVbsLauncher
        }
        StartTime = '17:00:00'
    }
    'Monthly Tasks (battery exempted)' = @{
        Description = 'Runs all scripts under "%PROGRAMDATA%\Scheduled Scripts\Tasks\Battery Exempted\Monthly\*.ps1" on the first day of every month from about 5:00PM to 5:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on. This task will run on both battery and AC power. This task will not execute again until the next scheduled time if it missed its scheduled start for any reason.'
        Action = @{
            Execute = 'wscript.exe'
            Arguments = '"{0}" EnsureMonthly' -f $cronVbsLauncher
        }
        StartTime = '17:00:00'
    }
}

# ---[ END CONFIG ]---

$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin)
{
    throw "This installer requires administrative privileges."
}

if (Test-Path $cronScriptPath -PathType Container)
{
    throw "Remove existing installation first!"
}

$taskXmlTemplate = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>{{ $creationTimestamp }}</Date>
    <Author>NT AUTHORITY\TrustedInstaller</Author>
    <URI>\{{ $taskPath }}\{{ $taskName }}</URI>
    <Description>{{ $description }}</Description>
  </RegistrationInfo>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-20</UserId>
    </Principal>
  </Principals>
  <Settings>
{{ $batterySetting }}
    <ExecutionTimeLimit>PT30M</ExecutionTimeLimit>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <IdleSettings>
      <Duration>PT10M</Duration>
      <WaitTimeout>PT1H</WaitTimeout>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
  </Settings>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>{{ $startTimestamp }}</StartBoundary>
{{ $calendarConfig }}
    </CalendarTrigger>
  </Triggers>
  <Actions Context="Author">
    <Exec>
      <Command>{{ $execute }}</Command>
      <Arguments>{{ $argument }}</Arguments>
    </Exec>
  </Actions>
</Task>
'@

$batteryConfig = @'
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
'@

$batteryExemptConfig = @'
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
'@

$dailyConfig = @'
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
'@

$weeklyConfig = @'
      <ScheduleByWeek>
        <WeeksInterval>1</WeeksInterval>
        <DaysOfWeek>
          <Monday />
        </DaysOfWeek>
      </ScheduleByWeek>
'@

$monthlyConfig = @'
      <ScheduleByMonth>
        <Months>
          <January />
          <February />
          <March />
          <April />
          <May />
          <June />
          <July />
          <August />
          <September />
          <October />
          <November />
          <December />
        </Months>
        <DaysOfMonth>
          <Day>1</Day>
        </DaysOfMonth>
      </ScheduleByMonth>
'@

$comService = New-Object -ComObject Schedule.Service
$comService.Connect()
$rootFolder = $comService.GetFolder('\')

try
{
    $baseFolder = $rootFolder.GetFolder($cronFolderPath)
}
catch
{
    if ($_.FullyQualifiedErrorId -ne 'System.IO.FileNotFoundException')
    {
        throw $_
    }

    $baseFolder = $rootFolder.CreateFolder('\' + $cronFolderPath)
}

$taskProfiles.Keys | ForEach-Object {
    $taskName = $_
    $registerScheduledTaskParams = $taskProfiles."$taskName"

    $xmlContent = $taskXmlTemplate

    $taskXmlParams = @{
        'taskPath' = $cronFolderPath
        'taskName' = $taskName
        'description' = $taskProfiles."$taskName".Description
        'execute' = $taskProfiles."$taskName".Action.Execute
        'argument' = $taskProfiles."$taskName".Action.Arguments
        'creationTimestamp' = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        'startTimestamp' = Get-Date -Format ('yyyy-MM-ddT{0}' -f $taskProfiles."$taskName".StartTime)
    }

    $taskXmlParams.Keys | ForEach-Object {
        $xmlContent = $xmlContent.Replace('{{ $' + $_ + ' }}', $taskXmlParams."$_")
    }

    if ($taskName -like '*battery exempted*')
    {
        $xmlContent = $xmlContent.Replace('{{ $batterySetting }}', $batteryExemptConfig)
    }
    else
    {
        $xmlContent = $xmlContent.Replace('{{ $batterySetting }}', $batteryConfig)
    }

    if ($taskName -like '*Monthly*')
    {
        $xmlContent = $xmlContent.Replace('{{ $calendarConfig }}', $monthlyConfig)
    }
    elseif ($taskName -like '*Weekly*')
    {
        $xmlContent = $xmlContent.Replace('{{ $calendarConfig }}', $weeklyConfig)
    }
    elseif ($taskName -like '*Daily*')
    {
        $xmlContent = $xmlContent.Replace('{{ $calendarConfig }}', $dailyConfig)
    }
    else
    {
        throw "task name must be *Monthly|Weekly|Daily*"
    }

    $taskItem = $comService.NewTask(0)
    $taskItem.XmlText = $xmlContent
    $baseFolder.RegisterTaskDefinition($taskName, $taskItem, 6, $null, $null, 5, $null)
}

$computerStartXml = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>{{ $creationTimestamp }}</Date>
    <Author>NT AUTHORITY\TrustedInstaller</Author>
    <URI>\{{ $taskPath }}\{{ $taskName }}</URI>
    <Description>{{ $description }}</Description>
  </RegistrationInfo>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
    </Principal>
  </Principals>
  <Settings>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
  </Settings>
  <Triggers>
    <BootTrigger />
  </Triggers>
  <Actions Context="Author">
    <Exec>
      <Command>{{ $execute }}</Command>
      <Arguments>{{ $argument }}</Arguments>
    </Exec>
  </Actions>
</Task>
'@

$computerStartXmlParams = @{
    'taskPath' = $cronFolderPath
    'taskName' = 'Computer Startup'
    'description' = 'Runs all scripts under "%PROGRAMDATA%\Scheduled Scripts\Tasks\Startup\*.ps1" every time this computer starts up with the current operating system. No user needs to be logged on. This task will run on both battery and AC power.'
    'execute' = 'wscript.exe'
    'argument' = '"{0}" Startup' -f $cronVbsLauncher
    'creationTimestamp' = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
}
$computerStartXmlParams.Keys | ForEach-Object {
    $computerStartXml = $computerStartXml.Replace('{{ $' + $_ + ' }}', $computerStartXmlParams."$_")
}
$taskItem = $comService.NewTask(0)
$taskItem.XmlText = $computerStartXml
$baseFolder.RegisterTaskDefinition($computerStartXmlParams.taskName, $taskItem, 6, $null, $null, 5, $null)


# --- CREATE LOGS ---
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
        New-EventLog -LogName $createLogName -Source $requiredLogs."$createLogName".Source
    }
    else
    {
        Write-Warning "Log $_ already exists. If you encounter logging problems with sources, remove them manually and install again."
    }
}


# --- WRITE FILES ---

if (Test-Path $cronScriptPath -PathType Leaf)
{
    del $cronScriptPath -Force
}

if (-not (Test-Path $cronScriptPath))
{
    md $cronScriptPath -Force | Out-Null
}

copy "$PSScriptRoot\src\*" "$cronScriptPath\" -Recurse

@('Daily', 'Weekly', 'Monthly') | ForEach-Object {
    if (-not (Test-Path (Join-Path $cronScriptPath -ChildPath "Tasks\$_")))
    {
        md (Join-Path $cronScriptPath -ChildPath "Tasks\$_") -Force | Out-Null
    }
    if (-not (Test-Path (Join-Path $cronScriptPath -ChildPath "Tasks\Battery Exempted\$_")))
    {
        md (Join-Path $cronScriptPath -ChildPath "Tasks\Battery Exempted\$_") -Force | Out-Null
    }
}

$sddl = 'O:S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464G:S-1-5-21-3743141187-1647405133-3778558433-513D:PAI(A;OICIIO;FA;;;CO)(A;OICI;FA;;;SY)(A;OICI;0x1200a9;;;NS)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;BU)'
$acl = Get-Acl -Path $cronScriptPath
$acl.SetSecurityDescriptorSddlForm($sddl)
$acl | Set-Acl -Path $cronScriptPath

dir $cronScriptPath -File -Recurse | ForEach-Object { $_ | Unblock-File }
