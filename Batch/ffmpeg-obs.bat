@echo off
setlocal enabledelayedexpansion

set "args=%*"
set "accuracy=%~1"
set "input=%~2"
set "output=%~3"

if "!accuracy!" == "" (
	goto HELP
)

if "!accuracy:~0,1!" == "-" (
	goto HELP
)

if "!accuracy:~0,2!" == "/?" (
	goto HELP
)

if "!input!" == "" (
	set "input="
	set "output="
	set /a "inputLength=0"
	set /a "outputLength=0"
)

if "!input:~0,1!" == "-" (
	set "input="
	set "output="
	set /a "inputLength=0"
	set /a "outputLength=0"
)

if "!inputLength!" == "" (
	call :STR_LENGTH %2 inputLength
	set /a "inputLength+=1"
	
	if "!output:~0,1!" == "-" (
		call :SET_OUTPUT_FROM_INPUT
		set /a "outputLength=0"
	)

	if "!output!" == "" (
		call :SET_OUTPUT_FROM_INPUT
		set /a "outputLength=0"
	)
	
	if "!outputLength!" == "" (
		call :STR_LENGTH %3 outputLength
		set /a "outputLength+=1"
	)
)

call :STR_LENGTH %1 accuracyLength
set /a "accuracyLength+=1"

set /a "argsLength+=!accuracyLength!"
set /a "argsLength+=!inputLength!"
set /a "argsLength+=!outputLength!"

set "beforeFfmpegArgs=!args:~%argsLength%!"
set "afterFfmpegArgs="

set /a "dashPosition=0"

for %%A in (!beforeFfmpegArgs!) do (
	call :STR_LENGTH %%A length
	set /a "length+=1"
	
    if "%%A"=="-" (
		for %%B in (!dashPosition!) do (
			set "beforeFfmpegArgs=!args:~%argsLength%,%%B!"
			set "afterFfmpegArgs=!args:~%argsLength%!"
			
			set /a "afterSkip=%%B+!length!"
			
			for %%C in (!afterSkip!) do (
				set "afterFfmpegArgs=!afterFfmpegArgs:~%%C!"
			)
		)
		
        goto DASH_FOUND
    )
	
	set /a "dashPosition+=!length!"
)

:DASH_FOUND

if "!input!" neq "" (
	set "beforeFfmpegArgs=!beforeFfmpegArgs! -i ^"!input!^""
)

if "!output!" neq "" (
	set "afterFfmpegArgs=!afterFfmpegArgs! ^"!output!^""
)

if "!accuracy!" == "absolute" (
	ffmpeg -hwaccel cuda ^
	!beforeFfmpegArgs! ^
	-map 0:v:0 -map 0:a:0 ^
	-vf "zscale=t=linear:npl=100,tonemap=tonemap=linear:desat=0,zscale=p=bt709:t=bt709:m=bt709,eq=brightness=0.5:contrast=0.5,colorchannelmixer=rr=0.5:gg=0.5:bb=0.5,format=yuv420p,scale=1920:1080:force_original_aspect_ratio=decrease" ^
	-c:v h264_nvenc -preset p7 -rc vbr -minrate 5M -b:v 25M ^
	-color_primaries bt709 -color_trc bt709 -colorspace bt709 ^
	-flags +global_header ^
	-pix_fmt yuv420p ^
	-brand mp42 ^
	-metadata compatible_brands=mp42isom ^
	-movflags +faststart ^
	-c:a aac ^
	!afterFfmpegArgs!
) else if "!accuracy!" == "relative" (
	ffmpeg -hwaccel cuda ^
	!beforeFfmpegArgs! ^
	-map 0:v:0 -map 0:a:0 ^
	-vf "zscale=t=linear:npl=100,tonemap=tonemap=linear:desat=0,zscale=p=bt709:t=bt709:m=bt709,eq=gamma=0.5:brightness=0.4:contrast=1.4:saturation=1.9,format=yuv420p,scale=1920:1080:force_original_aspect_ratio=decrease" ^
	-c:v h264_nvenc -preset p7 -rc vbr -minrate 5M -b:v 25M ^
	-color_primaries bt709 -color_trc bt709 -colorspace bt709 ^
	-flags +global_header ^
	-pix_fmt yuv420p ^
	-brand mp42 ^
	-metadata compatible_brands=mp42isom ^
	-movflags +faststart ^
	-c:a aac ^
	!afterFfmpegArgs!
) else (
	echo Tone map accuracy level not supported
)

goto END

:SET_OUTPUT_FROM_INPUT
for %%f in ("!input!") do (
	set "output=%%~nf"
	set "output=!output!_converted%%~xf"
)
goto :EOF

:HELP
echo Use ffmpeg-obs ^<absolute/relative^> ^<input^> ^<output^> ^*
goto END

:STR_LENGTH
setlocal enabledelayedexpansion

set "str=%1"
set "str=!str:"='!"

:STR_LENGTH_LOOP
if not "!str:~%len%!"=="" set /A len+=1 & goto :STR_LENGTH_LOOP
(endlocal & set /a "%~2=%len%")
goto :EOF

:END

endlocal