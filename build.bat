@echo off

echo Building examples...
cd examples
call build.bat
if %ERRORLEVEL% NEQ 0 (ECHO Example build failed with error:%ERRORLEVEL% && exit /B %ERRORLEVEL%)
cd ..
