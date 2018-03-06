@{
    CreateSlideshowDir = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Running for the first time. Creating slideshow directory...'
        EventID = 10300
    }
    ClearOccupiedPath = @{
        Category = 3000
        EntryType = 'Warning'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'The path "{0}" is occupied. Deleting it now.'
        EventID = 10310
    }
    Get8Image = @{
        Category = 3000
        EntryType = 'Verbose'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Querying metadata for the latest 8 images from resource server'
        EventID = 10311
    }   
    Get1Image = @{
        Category = 3000
        EntryType = 'Verbose'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Querying metadata for the latest image from resource server'
        EventID = 10320
    }
    ParseJsonContent = @{
        Category = 3000
        EntryType = 'Verbose'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Parsing JSON content'
        EventID = 10321
    }
    MetadataMalform = @{
        Category = 3000
        EntryType = 'Error'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Response data from the resource server was malformed: (property) {0}, (value) {1}'
        EventID = 10340
    }
    GetPreferredImage = @{
        Category = 3000
        EntryType = 'Verbose'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Downloading image with preferred resolution: {0} -> {1}'
        EventID = 10322
    }
    GetFallbackImage = @{
        Category = 3000
        EntryType = 'Verbose'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Preferred image resolution not available. Downloading image with available resolution: {0} -> {1}'
        EventID = 10323
    }
    GetImageFailed = @{
        Category = 3000
        EntryType = 'Error'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Failed to download image: {0}'
        EventID = 10341
    }
    PreferredImageExist = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Image with the preferred resolution has already been downloaded: {0}'
        EventID = 10301
    }
    FallbackImageExist = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Image has already been downloaded: {0}'
        EventID = 10302
    }
    GenericError = @{
        Category = 3000
        EntryType = 'Error'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'An error has occured: {0}'
        EventID = 10342
    }
}
