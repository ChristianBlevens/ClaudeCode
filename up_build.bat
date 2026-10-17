@echo off
setlocal
title Claude Container - Up (rebuild)

pushd "%~dp0"

echo Rebuilding image and starting claude_code_container...
echo.
docker-compose up -d --build
set "RESULT=%ERRORLEVEL%"

popd

if not "%RESULT%"=="0" (
    echo.
    echo docker-compose up --build failed with exit code %RESULT%.
    pause
    exit /b %RESULT%
)

echo.
echo Container is up. Run window.bat to open a terminal.
endlocal
