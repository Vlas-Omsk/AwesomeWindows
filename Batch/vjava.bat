@echo off
setlocal enabledelayedexpansion

set "javaPath=Z:\Program Files\Java\"

set "args=%*"
set "firstArg=%1"

if "!firstArg!" == "" (
	set /a "firstArgNum=0"
) else (
	set /a "firstArgNum=!firstArg:.=!"
)

if "!firstArgNum!" == "!firstArg!" (
	call :STR_LENGTH firstArg firstArgLength

	set /a "firstArgLength+=1"

	for /F "tokens=1 delims=." %%F in ("!firstArg!") do set "enteredVersion1=%%F"
	for /F "tokens=2 delims=." %%F in ("!firstArg!") do set "enteredVersion2=00%%F"
	for /F "tokens=3 delims=." %%F in ("!firstArg!") do set "enteredVersion3=000%%F"
	for /F "tokens=4 delims=." %%F in ("!firstArg!") do set "enteredVersion4=00%%F"
) else (
	set "firstArg="
	set /a "firstArgLength=0"
)

if "!enteredVersion1!" == "" set "enteredVersion1=99"
if "!enteredVersion2!" == "" set "enteredVersion2=99"
if "!enteredVersion3!" == "" set "enteredVersion3=999"
if "!enteredVersion4!" == "" set "enteredVersion4=99"

set "enteredVersion2=!enteredVersion2:~-2!"
set "enteredVersion3=!enteredVersion3:~-3!"
set "enteredVersion4=!enteredVersion4:~-2!"

set "currentDifference=999999999"

if exist "!javaPath!jdk-*" (
	for /F "tokens=2 delims=-" %%E in ('dir /b "!javaPath!jdk-*"') do (
		set "version1=1"
		set "version2=00"
		set "version3=000"
		set "version4=00"

		for /F "tokens=1 delims=." %%F in ("%%E") do set "version1=%%F"
		for /F "tokens=2 delims=." %%F in ("%%E") do set "version2=00%%F"
		for /F "tokens=3 delims=." %%F in ("%%E") do set "version3=000%%F"
		for /F "tokens=4 delims=." %%F in ("%%E") do set "version4=00%%F"
		
		set "version2=!version2:~-2!"
		set "version3=!version3:~-3!"
		set "version4=!version4:~-2!"
		
		set "condition=0"

		if "!enteredVersion1!" == "99" set "condition=1"
		if "!enteredVersion1!" == "!version1!" set "condition=1"
		
		if "!condition!" == "1" (
			set /a "difference=!enteredVersion1!!enteredVersion2!!enteredVersion3!!enteredVersion4!-!version1!!version2!!version3!!version4!"
			
			if !difference! leq 0 set /a "difference=0-!difference!"

			if !difference! leq !currentDifference! (
				set "currentDifference=!difference!"
				set "currentVersionDir=jdk-%%E"
			)
		)
	)
)

if exist "!javaPath!jre*" (
	for /F %%E in ('dir /b "!javaPath!jre*"') do (
		set "version1=1"
		set "version2=00"
		set "version3=000"

		for /F "tokens=2 delims=." %%F in ("%%E") do set "version1=%%F"
		for /F "tokens=3 delims=._" %%F in ("%%E") do set "version2=00%%F"
		for /F "tokens=2 delims=_" %%F in ("%%E") do set "version3=000%%F"
		
		set "version2=!version2:~-2!"
		set "version3=!version3:~-3!"

		set "condition=0"

		if "!enteredVersion1!" == "99" set "condition=1"
		if "!enteredVersion1!" == "!version1!" set "condition=1"

		if "!condition!" == "1" (
			set /a "difference=!enteredVersion1!!enteredVersion2!!enteredVersion3!!enteredVersion4!-!version1!!version2!!version3!00"
			
			if !difference! leq 0 set /a "difference=0-!difference!"
			
			if !difference! leq !currentDifference! (
				set "currentDifference=!difference!"
				set "currentVersionDir=%%E"
			)
		)
	)
)

if "!currentVersionDir!" == "" (
	echo Java version not found
	goto END
)

echo Executing using !currentVersionDir!

if "!args!" == "" (
	set "javaArgs="
) else (
	set "javaArgs=!args:~%firstArgLength%!"
)

"!javaPath!!currentVersionDir!\bin\java.exe" !javaArgs!

goto END

:STR_LENGTH
setlocal enabledelayedexpansion

:STR_LENGTH_LOOP
if not "!%1:~%len%!"=="" set /A len+=1 & goto :STR_LENGTH_LOOP
(endlocal & set %2=%len%)
goto :EOF

:END

endlocal