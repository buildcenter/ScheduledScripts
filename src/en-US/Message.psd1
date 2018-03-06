@{
    # Create/Write log
    StartupCreateLog = @{
        Category = 3000
        EntryType = 'Warning'
        Source = 'Startup'
        EventId = 4052
        Message = 'Creating a new Windows log "{0}".'
        LogName = 'Host Access'
    }
    StartupCreateLogError = @{
        Category = 100
        EntryType = 'Error'
        LogName = 'Application'
        Source = 'Application Error'
        EventId = 0
        Message = 'Unable to create log "{0}": {1}'
    }
    WriteLogError = @{
        Category = 100
        EntryType = 'Error'
        LogName = 'Application'
        Source = 'Application Error'
        Message = 'A fatal error has occured. Unable to write log to "{0}": {1}'
        EventId = 0
    }

    # Core messages
    ScheduleScriptStarted = @{
        Category = 3000
        EntryType = 'Information'
        Message  = 'Starting scheduled script as "{0}"'
        EventId = 4000
    }
    ScheduleScriptFinished = @{
        Category = 3000
        EntryType = 'Information'
        Message  = 'Scheduled scripts has finished executing all tasks.'
        EventId = 4010
    }
    ScheduleScriptError = @{
        Category = 3000
        EntryType = 'Error'
        Message  = 'A fatal error has occured: {0}'
        EventId = 4050
    }
    ScriptDirNotFound = @{
        Category = 3000
        EntryType = 'Information'
        Message = 'The script directory does not exist: {0}'
        EventId = 4044
    }
    NoScriptFile = @{
        Category = 3000
        EntryType = 'Information'
        Message = 'The script directory does not contain any script file.'
        EventId = 4046
    }
    RunningScript = @{
        Category = 3000
        EntryType = 'Information'
        Message = 'Running script: {0}'
        EventId = 4060
    }
}