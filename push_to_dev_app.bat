@echo off
echo =======================================================
echo Pushing HRMS App to https://github.com/Devashish8894/dev_app ...
echo =======================================================

cd /d "E:\hrms_app\v1"

git init
git remote remove origin 2>nul
git remote add origin https://github.com/Devashish8894/dev_app.git
git branch -M main

git add .
git commit -m "Build mobile app"
git push -u origin main --force

echo =======================================================
echo PUSH COMPLETE!
echo.
echo Now open this link in your browser to get your APK and iOS package:
echo https://github.com/Devashish8894/dev_app/actions
echo =======================================================
pause
