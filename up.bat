@echo off
setlocal
title Claude Container - Up

pushd "%~dp0"

echo Starting claude_code_container...
echo.
docker-compose up -d
set "RESULT=%ERRORLEVEL%"

popd

if not "%RESULT%"=="0" (
    echo.
    echo docker-compose up failed with exit code %RESULT%.
    pause
    exit /b %RESULT%
)

echo.
echo Container is up. Run window.bat to open a terminal.
endlocal
