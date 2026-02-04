:: Please note that Chrome must be started to have more than one tab launched.
:: Batch file launching the widgets, testing the custom widgets, in Chrome tabs.
@echo off
set BROWSER="C:\Program Files\Google\Chrome\Application\chrome.exe"
cd ../..
echo "After launching the terminals, programm to wait for the web servers to be completely started before opening the browser tabs"
timeout /t 5 >nul

:: Waiting for the web servers to start
timeout /t 70 >nul 
