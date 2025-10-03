tasklist /fi "ImageName eq obs64.exe" /fo csv 2>NUL | find /I "obs64.exe">NUL

if "%ERRORLEVEL%"=="0" exit /b 0

cd /d "Z:\Program Files\obs-studio\bin\64bit"

start obs64.exe --startreplaybuffer --minimize-to-tray --disable-updater --disable-shutdown-check