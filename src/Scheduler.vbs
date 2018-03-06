Dim shell, args
Dim scriptDir
Dim command, psScriptPath, recurrance, retCode

Set args = Wscript.Arguments
If args.Count = 0 Then
    Wscript.Echo "Scheduler.vbs Startup|Shutdown|Daily|Weekly|Monthly|EnsureDaily|EnsureWeekly|EnsureMonthly"
    Wscript.Quit
End If

scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

recurrance = args(0)

Set shell = CreateObject("WScript.Shell")
psScriptPath = scriptDir & "\Scheduler.ps1"
command = "powershell.exe -ExecutionPolicy Unrestricted -NonInteractive -NoLogo -NoProfile -WindowStyle Hidden -Command ""& { . '" & psScriptPath & "' -Recurrance " & recurrance & " }"""

retCode = shell.Run(command, 0, True)
If retCode <> 0 Then 
End If
