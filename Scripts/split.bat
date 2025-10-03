@echo off
setlocal enabledelayedexpansion

:: Ensure that the user passed the file to the script
if "%~1"=="" (
    echo Please provide a file to process. You can drag the file onto the script.
    exit /b
)

set "split_at=%~2"

:: Ensure that the user passed the file to the script
if "%~2"=="" (
    set "split_at=1000"
)

set "input_file_name=%~1"
set "output_file_base_name=%~n1"
set "split_count=1"
set "line_count=1"

:: Move to the directory where the file is
pushd %~dp1

for /f "delims=" %%A in (%input_file_name%) do (
    >>%output_file_base_name%.!split_count! echo(%%A
    set /a line_count+=1

    :: If we've reached the split_number, roll the log over
    if !line_count! gtr %split_at% (
        set line_count=1
        set /a split_count+=1
    )
)
