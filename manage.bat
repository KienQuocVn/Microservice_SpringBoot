@echo off
REM ============================================
REM   Microservices Management Script
REM   For Windows PowerShell
REM ============================================

setlocal enabledelayedexpansion

:menu
cls
echo.
echo ============================================
echo   Microservices Management
echo ============================================
echo.
echo 1. View all services status
echo 2. Start all services
echo 3. Stop all services
echo 4. Restart all services
echo 5. View logs (all services)
echo 6. View logs (specific service)
echo 7. Build all images
echo 8. Rebuild and restart a service
echo 9. Stop a specific service
echo 10. Start a specific service
echo 11. Clean up (remove containers and volumes)
echo 12. Check Docker stats
echo 0. Exit
echo.
set /p choice="Select an option: "

if "%choice%"=="1" goto status
if "%choice%"=="2" goto start_all
if "%choice%"=="3" goto stop_all
if "%choice%"=="4" goto restart_all
if "%choice%"=="5" goto logs_all
if "%choice%"=="6" goto logs_service
if "%choice%"=="7" goto build_all
if "%choice%"=="8" goto rebuild_service
if "%choice%"=="9" goto stop_service
if "%choice%"=="10" goto start_service
if "%choice%"=="11" goto cleanup
if "%choice%"=="12" goto stats
if "%choice%"=="0" goto end

goto menu

:status
cls
echo.
echo Checking status of all services...
echo.
docker-compose ps
echo.
pause
goto menu

:start_all
cls
echo.
echo Starting all services...
echo.
docker-compose up -d
echo.
echo All services started!
pause
goto menu

:stop_all
cls
echo.
echo Stopping all services...
echo.
docker-compose stop
echo.
echo All services stopped!
pause
goto menu

:restart_all
cls
echo.
echo Restarting all services...
echo.
docker-compose restart
echo.
echo All services restarted!
pause
goto menu

:logs_all
cls
echo.
echo Showing logs (press Ctrl+C to exit)...
echo.
docker-compose logs -f
goto menu

:logs_service
cls
echo.
set /p service="Enter service name: "
docker-compose logs -f !service!
goto menu

:build_all
cls
echo.
echo Building all images (this may take a while)...
echo.
docker-compose build
echo.
echo Build completed!
pause
goto menu

:rebuild_service
cls
echo.
set /p service="Enter service name: "
echo Rebuilding !service!...
docker-compose build !service!
docker-compose up -d !service!
echo !service! rebuilt and started!
pause
goto menu

:stop_service
cls
echo.
set /p service="Enter service name: "
docker-compose stop !service!
echo !service! stopped!
pause
goto menu

:start_service
cls
echo.
set /p service="Enter service name: "
docker-compose up -d !service!
echo !service! started!
pause
goto menu

:cleanup
cls
echo.
echo WARNING: This will remove all containers and volumes!
set /p confirm="Are you sure? (yes/no): "
if /i "%confirm%"=="yes" (
    echo.
    echo Cleaning up...
    docker-compose down -v
    echo.
    echo Cleanup completed!
) else (
    echo Cancelled.
)
pause
goto menu

:stats
cls
echo.
echo Docker stats (press Ctrl+C to exit)...
echo.
docker stats
goto menu

:end
echo.
echo Goodbye!
echo.

