@{
    NoVHDToMount= @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Host Access'
        Source = 'Startup'
        Message = 'No VHD mount requirement defined.'
        EventID = 10050
    }
    MountingVHD = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Host Access'
        Source = 'Startup'
        Message = 'Mounting VHD: {0}'
        EventID = 10055
    }
    VHDAlreadyMounted = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Host Access'
        Source = 'Startup'
        Message = 'VHD is already mounted: {0}'
        EventID = 10056
    }
    MountVHDToDriveLetter = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Host Access'
        Source = 'Startup'
        Message = 'Mounting VHD to drive letter "{0}": {1}'
        EventID = 10060
    }
    MountDriveLetterInUse = @{
        Category = 3000
        EntryType = 'Error'
        LogName = 'Host Access'
        Source = 'Startup'
        Message = 'Unable to mount VHD because the drive letter "{0}" is already in use: {1}'
        EventID = 10065
    }
    MountVHDError = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Host Access'
        Source = 'Startup'
        Message = 'Unable to mount VHD "{0}": {1}'
        EventID = 10066
    }
    MountVHDNotFound = @{
        Category = 3000
        EntryType = 'Error'
        LogName = 'Host Access'
        Source = 'Startup'
        Message = 'Unable to mount VHD "{0}" because the file does not exist.'
        EventID = 10067
    }
}
