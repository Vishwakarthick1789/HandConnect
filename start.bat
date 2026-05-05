@echo off
echo ==========================================
echo Starting HandConnect Flutter App
echo ==========================================

echo.
echo [1/2] Fetching dependencies...
call c:\src\flutter\bin\flutter.bat pub get

echo.
echo [2/2] Running the app...
echo Running natively on your laptop or a connected device.
call c:\src\flutter\bin\flutter.bat run

pause
