@echo off
REM Opens a new terminal window running an independent zsh inside the running
REM container. Run it as many times as you want windows.
REM
REM   window.bat              -> shell in /workspace
REM   window.bat ForeverWar   -> shell in /workspace/ForeverWar

setlocal

set "CONTAINER=claude_code_container"
set "RUNNING="

set "WORKDIR=/workspace"
if not "%~1"=="" set "WORKDIR=/workspace/%~1"

for /f "tokens=*" %%i in ('docker inspect -f "{{.State.Running}}" %CONTAINER% 2^>nul') do set "RUNNING=%%i"

if not "%RUNNING%"=="true" (
    echo Container %CONTAINER% is not running.
    echo Run up.bat first, or up_build.bat to rebuild the image.
    echo.
    pause
    exit /b 1
)

start "Claude - %WORKDIR%" cmd /k docker exec -it -w "%WORKDIR%" %CONTAINER% zsh

endlocal
