#######################################################################
#  Localization data
#######################################################################

if (-not $localizedDataFile)
{
    $localizedDataFile = 'Message.psd1'
}
if (-not $logLevel)
{
    $logLevel = 'Information'
}

# Ignore error if localization for current UICulture is unavailable
Import-LocalizedData -BindingVariable LocalizedData -BaseDirectory $PSScriptRoot -FileName $localizedDataFile -ErrorAction $(
    if ($PSVersionTable.PSVersion.Major -ge 3) { 'Ignore' } 
    else { 'SilentlyContinue' }
)

# Fallback to US English if localization data failed to load
# Do not continue if fallback failed to load too
if (-not $LocalizedData)
{
    Import-LocalizedData -BindingVariable LocalizedData -BaseDirectory $PSScriptRoot -UICulture 'en-US' -FileName $localizedDataFile -ErrorVariable loadDefaultLocalizationError -ErrorAction $(
        if ($PSVersionTable.PSVersion.Major -ge 3) { 'Ignore' } 
        else { 'SilentlyContinue' }
    )

    # Continue with error if localization variable is available
    # Otherwise stop
    if ($loadDefaultLocalizationError)
    {
        if (-not $LocalizedData)
        {
            $PSCmdlet.ThrowTerminatingError($loadDefaultLocalizationError[0])            
        }
        else
        {
            $loadDefaultLocalizationError[0]
        }
    }
}


#######################################################################
#  Logging
#######################################################################

function WriteWindowsLog
{
    Param(
        [Parameter(Mandatory, Position = 1)]
        [string]$MessageID,

        [Parameter()]
        [string[]]$Data,

        [Parameter()]
        [string]$LogName,

        [Parameter()]
        [string]$Source
    )

    if (-not $LocalizedData.ContainsKey($MessageID))
    {
        return
    }

    $writeLogParams = $LocalizedData."$MessageID"

    if (($logLevel -eq 'Error') -and 
        ($writeLogParams.EntryType -ne 'Error'))
    {
        return
    }
    elseif (($logLevel -eq 'Warning') -and 
        ($writeLogParams.EntryType -notin @('Error', 'Warning')))
    {
        return
    }
    elseif (($logLevel -eq 'Information') -and 
        ($writeLogParams.EntryType -notin @('Error', 'Warning', 'Information')))
    {
        return
    }

    if ($Data)
    {
        $writeLogParams.Message = $writeLogParams.Message -f $Data
    }

    if ($LogName)
    {
        $writeLogParams.LogName = $LogName
    }

    if ($Source)
    {
        $writeLogParams.Source = $Source
    }

    if ($writeLogParams.EntryType -eq 'Verbose')
    {
        $writeLogParams.EntryType = 'Information'
    }

    Write-EventLog @writeLogParams
}
