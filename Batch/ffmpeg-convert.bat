@echo off
setlocal enabledelayedexpansion

rem Config
set "absoluteTonemapAccuracyFilters=eq=brightness=0.5:contrast=0.5,colorchannelmixer=rr=0.5:gg=0.5:bb=0.5"
set "relativeTonemapAccuracyFilters=eq=gamma=0.5:brightness=0.4:contrast=1.4:saturation=1.9"
set "anyTargetH264Codec=h264_nvenc"
set "hwaccel=cuda"

rem Options
set "ffmpegArgsPosition=before"
set "beforeFfmpegArgs="
set "betweenFfmpegArgs="
set "afterFfmpegArgs="
set "tonemapAccuracy=relative"
set "videoFilter="
set "input="
set "output="
set "source=default"
set "target=default"

:READ_OPTIONS
set "arg=%~1"

if /I "!arg!" == "/?" (
	goto :HELP
) else if /I "!arg!" == "-tonemap_accuracy" (
	set "tonemapAccuracy=%~2"
	shift
) else if /I "!arg!" == "-source" (
	set "source=%~2"
	shift
) else if /I "!arg!" == "-target" (
	set "target=%~2"
	shift
) else if /I "!arg!" == "-vf" (
	set "videoFilter=%~2"
	shift
) else if /I "!arg!" == "-i" (
	set "input=%~2"
	shift
) else if /I "!arg!" == "-" (
	set "ffmpegArgsPosition=after"
) else if /I "!arg:~0,1!" == "-" (
	if "!ffmpegArgsPosition!" == "before" (
		set "beforeFfmpegArgs=!beforeFfmpegArgs! %1 %2"
	) else if "!ffmpegArgsPosition!" == "after" (
		set "afterFfmpegArgs=!afterFfmpegArgs! %1 %2"
	) else (
		exit /b
	)
	shift
) else (
	if "!ffmpegArgsPosition!" == "after" (
		set "output=%~1"
	) else (
		set "afterFfmpegArgs=!afterFfmpegArgs! %1"
	)
)
shift
if not "%~1" == "" goto :READ_OPTIONS

if "!target!" == "any" (
	if "!source!" == "desktop" (
		set "beforeFfmpegArgs=!beforeFfmpegArgs! -map 0:v:0 -map 0:a:0"
		
		if "!tonemapAccuracy!" == "absolute" (
			set "videoFilter=!videoFilter!,zscale=t=linear:npl=100,tonemap=tonemap=linear:desat=0,zscale=p=bt709:t=bt709:m=bt709,!absoluteTonemapAccuracyFilters!,format=yuv420p"
		) else if "!tonemapAccuracy!" == "relative" (
			set "videoFilter=!videoFilter!,zscale=t=linear:npl=100,tonemap=tonemap=linear:desat=0,zscale=p=bt709:t=bt709:m=bt709,!relativeTonemapAccuracyFilters!,format=yuv420p"
		) else (
			exit /b
		)
		
		set "betweenFfmpegArgs=!betweenFfmpegArgs! -c:v !anyTargetH264Codec! -preset p7 -rc vbr -minrate 5M -b:v 25M -color_primaries bt709 -color_trc bt709 -colorspace bt709 -flags +global_header -pix_fmt yuv420p -brand mp42 -metadata compatible_brands=mp42isom -movflags +faststart -c:a aac"
	)
	
	set "beforeFfmpegArgs=!beforeFfmpegArgs! -r 60"
	set "videoFilter=!videoFilter!,scale=1920:1080:force_original_aspect_ratio=decrease"
)

if "!output!" == "" (
	call :SET_OUTPUT_FROM_INPUT
)

if "!videoFilter:~0,1!" == "," (
	set "videoFilter=!videoFilter:~1!"
)

set "ffmpegArgs=-hwaccel !hwaccel!"

if "!input!" neq "" (
	set "ffmpegArgs=!ffmpegArgs! -i ^"!input!^""
)

if "!beforeFfmpegArgs!" neq "" (
	set "ffmpegArgs=!ffmpegArgs! !beforeFfmpegArgs!"
)

if "!videoFilter!" neq "" (
	set "ffmpegArgs=!ffmpegArgs! -vf ^"!videoFilter!^""
)

if "!betweenFfmpegArgs!" neq "" (
	set "ffmpegArgs=!ffmpegArgs! !betweenFfmpegArgs!"
)

if "!afterFfmpegArgs!" neq "" (
	set "ffmpegArgs=!ffmpegArgs! !afterFfmpegArgs!"
)

if "!output!" neq "" (
	set "ffmpegArgs=!ffmpegArgs! ^"!output!^""
)

ffmpeg !ffmpegArgs!

goto END

:SET_OUTPUT_FROM_INPUT
for %%f in ("!input!") do (
	set "output=%%~nf"
	set "output=!output!_converted%%~xf"
)
goto :EOF

:HELP
echo Use ffmpeg-convert ^*
goto END

:END

endlocal