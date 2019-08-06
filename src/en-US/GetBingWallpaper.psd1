@{
    CreateSlideshowDir = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Running for the first time. Creating slideshow directory.'
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
    GetImage = @{
        Category = 3000
        EntryType = 'Verbose'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Downloading image {0} -> {1}'
        EventID = 10322
    }
    GetImageFailed = @{
        Category = 3000
        EntryType = 'Error'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Failed to download image {0}: {1}'
        EventID = 10341
    }
    ImageExist = @{
        Category = 3000
        EntryType = 'Information'
        LogName = 'Scheduled Scripts'
        Source = 'Daily'
        Message = 'Image already downloaded: {0}'
        EventID = 10301
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
