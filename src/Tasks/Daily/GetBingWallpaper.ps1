# Global preference
$ErrorActionPreference = 'Stop'

$localizedDataFile = 'GetBingWallpaper.psd1'
$basePath = Resolve-Path "$PSScriptRoot\..\.." | select -expand Path
$taskConfigPath = Join-Path "$basePath" -ChildPath "Configuration\GetBingWallpaper.json"
if (Test-Path $taskConfigPath -PathType Leaf)
{
    $taskConfig = ConvertFrom-Json ((Get-Content -Path $taskConfigPath) -join [Environment]::NewLine)
}

# --- Config ---
# Error, Information, Verbose
$logLevel = $(if ($taskConfig.logLevel) { $taskConfig.logLevel } else { 'Information' })
$apiServerUrl = $(if ($taskConfig.apiServerUrl) { $taskConfig.apiServerUrl } else { 'http://www.bing.com' }) 
$slideshowPath = $(if ($taskConfig.slideshowPath) { $taskConfig.slideshowPath } else { (Join-Path $env:PUBLIC -ChildPath 'Pictures\Slideshow') })
$preferredResolution = $(if ($taskConfig.preferredResolution) { $taskConfig.preferredResolution } else { '1920x1200' })
$firstRunDownloadCount = $(if ($taskConfig.firstRunDownloadCount) { $taskConfig.firstRunDownloadCount } else { '8' })
# --- /Config ---

. (Join-Path $basePath -ChildPath 'Logging.ps1')

try
{
    if (-not (Test-Path $slideshowPath))
    {
        WriteWindowsLog CreateSlideshowDir
        md $slideshowPath -Force | Out-Null
    }
    elseif (Test-Path $slideshowPath -PathType Leaf)
    {
        WriteWindowsLog ClearOccupiedPath -Data $slideshowPath
        del $slideshowPath -Force

        WriteWindowsLog CreateSlideshowDir
        md $slideshowPath -Force | Out-Null
    }

    $slideshowFiles = dir $slideshowPath -File
    if (-not $slideshowFiles)
    {
        WriteWindowsLog Get8Image
        $apiResponseContent = Invoke-WebRequest -UseBasicParsing -Uri ('{0}/HPImageArchive.aspx?format=js&idx=0&n={1}' -f $apiServerUrl, $firstRunDownloadCount)
    }
    else
    {
        WriteWindowsLog Get1Image
        $apiResponseContent = Invoke-WebRequest -UseBasicParsing -Uri ('{0}/HPImageArchive.aspx?format=js&idx=0&n=1' -f $apiServerUrl)
    }

    WriteWindowsLog ParseJsonContent
    $apiResponse = ConvertFrom-Json $apiResponseContent.Content

    $apiResponse.images | where { $_ -is [psobject] } | ForEach-Object {
        if (($_.url -isnot [string]) -or (-not $_.url.Contains('.')))
        {
            WriteWindowsLog MetadataMalform -Data 'url', $_.url
        }
        elseif (($_.urlbase -isnot [string]) -or (-not $_.urlbase.Contains('/')))
        {
            WriteWindowsLog MetadataMalform -Data 'urlbase', $_.urlbase
        }
        else
        {
            $fileExtension = $_.url.Substring($_.url.LastIndexOf('.'))
            $fileBaseName = $_.urlbase.Substring($_.urlbase.LastIndexOf('/') + 1)
            $filename = $_.url.Substring($_.url.LastIndexOf('/') + 1)

            $imgUrl = $apiServerUrl + $_.urlbase + '_' + $preferredResolution + $fileExtension
            $imgOutFile = Join-Path $slideshowPath -ChildPath ('{0}_{1}{2}' -f $fileBaseName, $preferredResolution, $fileExtension)
    
            $fallbackImageUrl = $apiServerUrl + $_.url
            $fallbackImgOutFile = Join-Path $slideshowPath -ChildPath ('{0}' -f $filename)

            if (Test-Path $imgOutFile -PathType Leaf)
            {
                WriteWindowsLog PreferredImageExist -Data $imgOutFile
            }
            elseif (Test-Path $fallbackImgOutFile -PathType Leaf)
            {
                WriteWindowsLog FallbackImageExist -Data $fallbackImgOutFile
            }
            else
            {
                try
                {
                    WriteWindowsLog GetPreferredImage -Data $imgUrl, $imgOutFile
                    Invoke-WebRequest -Uri $imgUrl -OutFile $imgOutFile -UseBasicParsing -TimeoutSec 10
                }
                catch
                {
                    try
                    {
                        WriteWindowsLog GetFallbackImage -Data $fallbackImageUrl, $fallbackImgOutFile
                        Invoke-WebRequest -UseBasicParsing -Uri $fallbackImageUrl -OutFile $fallbackImgOutFile -TimeoutSec 10
                    }
                    catch
                    {
                        WriteWindowsLog GetImageFailed -Data $fallbackImageUrl
                    }
                }
            }
        }
    }
}
catch
{
    WriteWindowsLog GenericError -Data ($_ | Out-String)
}
