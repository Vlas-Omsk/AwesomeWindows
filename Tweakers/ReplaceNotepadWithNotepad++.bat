@echo off

rem Replacing Z:\Windows\notepad.exe

takeown /f "Z:\Windows\notepad.exe"
icacls "Z:\Windows\notepad.exe" /grant administrators:F

if not exist "Z:\Windows\notepad-default.exe" (
	move  "Z:\Windows\notepad.exe"  "Z:\Windows\notepad-default.exe"
) else (
	del "Z:\Windows\notepad.exe"
)

mklink "Z:\Windows\notepad.exe" "Z:\Program Files\Notepad++\notepad++.exe"

echo "Replaced 'Z:\Windows\notepad.exe'"

rem Replacing Z:\Windows\SysWOW64\notepad.exe

takeown /f "Z:\Windows\SysWOW64\notepad.exe"
icacls "Z:\Windows\SysWOW64\notepad.exe" /grant administrators:F

if not exist "Z:\Windows\SysWOW64\notepad-default.exe" (
	move "Z:\Windows\SysWOW64\notepad.exe" "Z:\Windows\SysWOW64\notepad-default.exe"
) else (
	del "Z:\Windows\SysWOW64\notepad.exe"
)

mklink "Z:\Windows\SysWOW64\notepad.exe" "Z:\Program Files\Notepad++\notepad++.exe"

echo "Replaced 'Z:\Windows\SysWOW64\notepad.exe'"

rem Replacing Z:\Windows\System32\notepad.exe

takeown /f "Z:\Windows\System32\notepad.exe"
icacls "Z:\Windows\System32\notepad.exe" /grant administrators:F

if not exist "Z:\Windows\System32\notepad-default.exe" (
	move "Z:\Windows\System32\notepad.exe" "Z:\Windows\System32\notepad-default.exe"
) else (
	del "Z:\Windows\System32\notepad.exe"
)

mklink "Z:\Windows\System32\notepad.exe" "Z:\Program Files\Notepad++\notepad++.exe"

echo "Replaced 'Z:\Windows\System32\notepad.exe'"

pause