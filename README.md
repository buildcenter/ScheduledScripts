TL;DR
=====
1. Write your PowerShell script
2. Drop it in C:\ProgramData\Scheduled Scripts\Tasks\Daily
3. Watch mom, it runs every day!


Windows Scheduled Script
========================
Linux users are familiar with cron - a daemon that launches programs and scripts at predefined 
intervals. Likewise, Windows has a more full-featured (and complicated) service called Task Scheduler. It 
comes with almost all editions of Windows, both client and server.

Task Scheduler has lots of advanced features, but sometimes we just want to do something simple, 
like running something daily, weekly, on computer startup, etc. For that, the Linux world has a 
clever solution - just drop your scripts in a hardcoded path (`/etc/cron/monthly`, 
`/etc/cron/daily`, etc.) and it's done!

This project aims to let you do just that, on Windows!


Install
=======
Unzip the installation archive to your local drive (e.g. `%temp%`).

Run Powershell with administrative privileges (WIN+x > Windows PowerShell (Admin)). Make sure your 
system can execute script:

```powershell
Get-ExecutionPolicy
```

If not 'Unrestricted' (you can change it back later):

```powershell
Set-ExecutionPolicy Unrestricted
```

Then:

```powershell
. .\install.ps1
```

This script does 3 things:

1. Copy out the contents of the `src` under it to `%ProgramData%\Scheduled Scripts`.

2. Create 2 logs: `Host Access` and `Scheduled Scripts`. You can see them by running 
`compmgmt.msc` (Event Viewer > Applications and Services).

3. Create various scheduled tasks. See the `System Scripts` folder in the Task Scheduler 
(run `taskschd.msc` with administrative privileges).


Using Windows Scheduled Script
==============================
Simply copy your script to one of the appropriate folders in `%programdata%\Scheduled Scripts\Tasks`.

- Daily: Runs all scripts under `%PROGRAMDATA%\Scheduled Scripts\Tasks\Daily\*.ps1` every day from about 3:00PM to 3:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on. 

- Monthly: Runs all scripts under `%PROGRAMDATA%\Scheduled Scripts\Tasks\Monthly\*.ps1` on the first day of every month from about 5:00PM to 5:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on.

- Weekly: Runs all scripts under `%PROGRAMDATA%\Scheduled Scripts\Tasks\Weekly\*.ps1` every Monday from about 4:00PM to 4:30PM. All scripts will execute with the "NT AUTHORITY\NETWORKSERVICE" privileges. No user needs to be logged on.

The above will not run if the system is running on battery. Their 'battery exempted' versions are exactly the same, but will run even if the PC is running on batteries.

- Startup: Runs all scripts under `%PROGRAMDATA%\Scheduled Scripts\Tasks\Startup\*.ps1` every time this computer starts up with the current operating system. No user needs to be logged on. This task will run on both battery and AC power.

All tasks **will not execute again** until the next scheduled time if it missed its scheduled start for any reason.


Security Matters
================
Scripts are protected by NTFS filesystem security itself. The access control for `%PROGRAMDATA%\Scheduled Scripts` is designed to require administrative privileges for write operation, thus preventing a malicious program from making changes to your script folder.

PowerShell execution policy is not used, because it is very trivial to get around its restriction.


Sample Scripts
==============
Here are the ones that comes with this package:

Tasks/Startup/MountVHD
----------------------
Automatically mount VHD to your preferred drive letter on PC start up. **YOU MUST EDIT** `Configuration\MountVHD.json` for it to work.

```json
{
    "logLevel": "Information",
    "vhdBasePath": "C:\\ProgramData\\Blobs",
    "vhd": {
        "Profile": {
            "driveLetter": "E",
            "ensure": true
        }
    }
}
```

The above will mount `C:\ProgramData\Blobs\Profile.vhdx` to `E:` on computer start up. The `ensure` flag 
means failing the script if `E:` is occupied. Set to `false` to use the next available drive letter.

You can omit `vhdBasePath`. It defaults to `%ProgramData%\Blobs`.

Valid values for `logLevel`: Error, Warning, Information, Verbose. Defaults to 'Information'.


Tasks/Daily/GetBingWallpaper
----------------------------
Download wallpapers off Bing.

This task does not need a configuration file to run, but you can customize it by creating a file under `Configuration\GetBingWallpaper.json`:

```json
{
    "logLevel": "Information",
    "apiServerUrl": "http://www.bing.com",
    "slideshowPath": "C:\\Users\\Public\\Pictures\\Slideshow",
    "firstRunDownloadCount": 8
}
```

- `slideshowPath`: Pictures are saved here. Defaults to `%public%\Pictures\Slideshow`. Folder will be automatically created if not already exists.

- `firstRunDownloadCount`: On first run, down this number of images. Defaults to the past 8 days. 8 is the maximum supported by Bing.com

- `apiServerUrl`: the script will query this server for image metadata and download url. If you have an alternate server that implements Bing's, you can enter it here.

- `logLevel`: Error, Warning, Information, Verbose. Defaults to 'Information'.
