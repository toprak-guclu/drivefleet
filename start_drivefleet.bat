@echo off
setlocal
title DriveFleet
cd /d "%~dp0"

echo ==========================================
echo  DriveFleet - one-click start
echo ==========================================
echo.

rem --- Node.js -------------------------------------------------------------
where node >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js was not found.
    echo Install Node.js 20.12 or newer from https://nodejs.org and run this file again.
    pause
    exit /b 1
)

rem --- Database settings (.env, created on the first run) ---------------------
if exist ".env" goto loadEnv
echo First run: enter your MySQL connection details.
echo They are saved to .env in this folder ^(this file is never uploaded to GitHub^).
echo.
set "DB_USER=root"
set /p "DB_USER=MySQL user [root]: "
set "DB_PASSWORD="
set /p "DB_PASSWORD=MySQL password (leave empty if none): "
setlocal EnableDelayedExpansion
(
    echo DB_HOST=localhost
    echo DB_USER=!DB_USER!
    echo DB_PASSWORD=!DB_PASSWORD!
    echo DB_NAME=drivefleet
    echo PORT=3000
) > ".env"
endlocal
echo Saved .env
echo.

:loadEnv
for /f "usebackq eol=# tokens=1,* delims==" %%A in (".env") do set "%%A=%%B"
if not defined DB_HOST set "DB_HOST=localhost"
if not defined DB_NAME set "DB_NAME=drivefleet"
if not defined PORT set "PORT=3000"

rem --- Database: import drivefleet.sql if the database does not exist yet ------
set "MYSQL_EXE="
where mysql >nul 2>nul && set "MYSQL_EXE=mysql"
if not defined MYSQL_EXE for /d %%D in ("%ProgramFiles%\MySQL\MySQL Server *") do if exist "%%D\bin\mysql.exe" set "MYSQL_EXE=%%D\bin\mysql.exe"
if not defined MYSQL_EXE (
    echo [INFO] MySQL command line client not found, skipping the database check.
    echo        If this is the first run, import database\drivefleet.sql once with MySQL Workbench
    echo        ^(File ^> Open SQL Script, then run it^).
    echo.
    goto deps
)
"%MYSQL_EXE%" --host=%DB_HOST% --user=%DB_USER% "--password=%DB_PASSWORD%" -e "USE %DB_NAME%" >nul 2>nul
if not errorlevel 1 (
    echo Database "%DB_NAME%" found.
    goto deps
)
echo Database "%DB_NAME%" was not found ^(or the login failed^).
choice /c YN /m "Import database\drivefleet.sql now"
if errorlevel 2 goto deps
"%MYSQL_EXE%" --host=%DB_HOST% --user=%DB_USER% "--password=%DB_PASSWORD%" < "database\drivefleet.sql"
if errorlevel 1 (
    echo [ERROR] Import failed. Check the user and password in .env ^(delete .env to enter them again^).
    pause
    exit /b 1
)
echo Database imported.
echo.

:deps
rem --- npm packages ------------------------------------------------------------
if not exist "node_modules" (
    echo Installing npm packages...
    call npm install
    if errorlevel 1 (
        echo [ERROR] npm install failed.
        pause
        exit /b 1
    )
)

rem --- Start the API and open the dashboard -------------------------------------
echo Starting the API server in a new window...
start "DriveFleet API Server" cmd /k "cd /d ""%~dp0"" && node server_admin.js"

echo Waiting for the server...
for /l %%i in (1,1,20) do (
    curl -s "http://localhost:%PORT%/api/health" >nul 2>nul && goto open
    timeout /t 1 /nobreak >nul
)
echo [WARNING] The server did not answer yet. Check the "DriveFleet API Server" window for errors.

:open
start "" "%~dp0car_rental_dashboard_admin.html"
echo.
echo Done. Keep the server window open while using the dashboard.
timeout /t 5 >nul
exit /b 0
