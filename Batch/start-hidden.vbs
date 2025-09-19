Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & WScript.Arguments(0) & Chr(34), 0
Set WinScriptHost = Nothing