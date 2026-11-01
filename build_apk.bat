@echo off
echo =======================================================
echo Building HRMS Android Release APK...
echo =======================================================

cd /d "E:\hrms_app\v1"

echo 1. Fetching Flutter packages...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] flutter pub get failed. Ensure Flutter SDK is installed and on your PATH.
    pause
    exit /b %ERRORLEVEL%
)

echo 2. Compiling Release APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter APK compilation failed.
    pause
    exit /b %ERRORLEVEL%
)

echo =======================================================
echo SUCCESS! Your Android APK is ready at:
echo E:\hrms_app\v1\build\app\outputs\flutter-apk\app-release.apk
echo =======================================================
pause
