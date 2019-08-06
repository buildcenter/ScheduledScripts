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
$logLevel = $(
    if ($taskConfig.logLevel) { $taskConfig.logLevel } 
    else { 'Information' }
)
$apiServerUrl = $(
    if ($taskConfig.apiServerUrl) { $taskConfig.apiServerUrl } 
    else { 'http://www.bing.com' }
)
$slideshowPath = $(
    if ($taskConfig.slideshowPath) { $taskConfig.slideshowPath } 
    else { (Join-Path $env:PUBLIC -ChildPath 'Pictures\Slideshow') }
)
$firstRunDownloadCount = $(
    if ($taskConfig.firstRunDownloadCount) { $taskConfig.firstRunDownloadCount } 
    else { '8' }
)

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

    $bingImageListApi = '/HPImageArchive.aspx?format=js&idx=0&n={0}'

    $slideshowFiles = dir $slideshowPath -File
    if (-not $slideshowFiles)
    {
        WriteWindowsLog Get8Image
        $apiResponseContent = Invoke-WebRequest -UseBasicParsing -Uri ($apiServerUrl + ($bingImageListApi -f $firstRunDownloadCount))
    }
    else
    {
        WriteWindowsLog Get1Image
        $apiResponseContent = Invoke-WebRequest -UseBasicParsing -Uri ($apiServerUrl + ($bingImageListApi -f '1'))
    }

    WriteWindowsLog ParseJsonContent
    $apiResponse = ConvertFrom-Json $apiResponseContent.Content

    $imageContentExtension = @{
        'image/jpeg' = '.jpg'
        'image/jpg' = '.jpg'
        'image/png' = '.png'
    }

    $apiResponse.images | where { $_ -is [psobject] } | ForEach-Object {
        if (($_.url -isnot [string]) -or ($_.url -notlike '/*'))
        {
            WriteWindowsLog MetadataMalform -Data 'url', ($_.url | Out-String)
        }
        elseif (($_.urlbase -isnot [string]) -or ($_.urlbase -notlike '/*'))
        {
            WriteWindowsLog MetadataMalform -Data 'urlbase', ($_.urlbase | Out-String)
        }
        else
        {
            $fileBaseName = $_.hsh
            $imageUrl = $apiServerUrl + $_.url

            try
            {
                WriteWindowsLog GetImage -Data $imageUrl, $fileBaseName
                $imageResponse = Invoke-WebRequest -Uri $imageUrl -UseBasicParsing -TimeoutSec 10

                if ($imageResponse.StatusCode -ne 200)
                {
                    throw ('bad_response {0}' -f $imageResponse.StatusCode)
                }

                $fileExtension = $imageContentExtension."$($imageResponse.Headers.'Content-Type')"
                if (-not $fileExtension)
                {
                    throw ('supported_image_extension {0}' -f $imageResponse.Headers.'Content-Type')
                }

                $imageFileName = '{0}{1}' -f $fileBaseName, $fileExtension
                $imageSavePath = Join-Path $slideshowPath -ChildPath $imageFileName

                if (Test-Path $imageSavePath -PathType Leaf)
                {
                    WriteWindowsLog ImageExist -Data $imageSavePath
                }
                else
                {
                    Set-Content -Path $imageSavePath -Value $imageResponse.Content -Encoding Byte
                }
            }
            catch
            {
                WriteWindowsLog GetImageFailed -Data $imageUrl, ($_ | Out-String)
            }
        }
    }
}
catch
{
    WriteWindowsLog GenericError -Data ($_ | Out-String)
}
