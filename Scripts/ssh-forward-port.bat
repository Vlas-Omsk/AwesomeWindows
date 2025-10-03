@echo off

set target=%1
set port=%2

:loop
	ssh %target% "kill $(lsof -t -i:%port%)"
	ssh -NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -R %port%:localhost:%port% %target%
	timeout 10
goto loop