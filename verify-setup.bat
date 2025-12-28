@echo off
REM ============================================
REM   Project Setup Verification Script
REM   Verifies all files are in place
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ============================================
echo   Microservices Project Verification
echo ============================================
echo.

set /A total=0
set /A found=0

REM Check Documentation Files
echo Checking Documentation Files...
echo.

call :check_file "README.md"
call :check_file "QUICK_START.md"
call :check_file "DOCKER_DEPLOYMENT_GUIDE.md"
call :check_file "DEMO_SCENARIOS.md"
call :check_file "API_TESTING_GUIDE.md"
call :check_file "DOCKERFILE_GUIDE.md"
call :check_file "KUBERNETES_GUIDE.md"
call :check_file "SETUP_SUMMARY.md"

REM Check Docker Configuration
echo.
echo Checking Docker Configuration...
echo.

call :check_file "docker-compose.yml"
call :check_file ".env.example"
call :check_file ".gitignore"

REM Check Dockerfiles
echo.
echo Checking Dockerfiles...
echo.

call :check_file "api-gateway/Dockerfile"
call :check_file "identity-service/Dockerfile"
call :check_file "profile-service/Dockerfile"
call :check_file "post-service/Dockerfile"
call :check_file "file-service/Dockerfile"
call :check_file "chat-service/Dockerfile"
call :check_file "notification-service/Dockerfile"
call :check_file "web-app/Dockerfile"

REM Check Spring Boot Configurations
echo.
echo Checking Spring Boot Docker Configurations...
echo.

call :check_file "api-gateway/src/main/resources/application-docker.yaml"
call :check_file "identity-service/src/main/resources/application-docker.yaml"
call :check_file "profile-service/src/main/resources/application-docker.yaml"
call :check_file "post-service/src/main/resources/application-docker.yaml"
call :check_file "file-service/src/main/resources/application-docker.yaml"
call :check_file "chat-service/src/main/resources/application-docker.yaml"
call :check_file "notification-service/src/main/resources/application-docker.yaml"

REM Summary
echo.
echo ============================================
echo   Verification Summary
echo ============================================
echo.
echo Total Files Expected: %total%
echo Files Found: %found%

if %total% equ %found% (
    echo.
    echo [SUCCESS] All files are in place! ✓
    echo.
    echo Next steps:
    echo   1. Review QUICK_START.md
    echo   2. Run: docker-compose build
    echo   3. Run: docker-compose up -d
    echo.
) else (
    set /A missing=%total% - %found%
    echo.
    echo [WARNING] Missing !missing! files
    echo Please ensure all services have Dockerfiles created
    echo.
)

echo.
pause
goto :eof

REM Function to check if file exists
:check_file
if exist "%~1" (
    set /A found+=1
    echo [✓] %~1
) else (
    echo [✗] %~1
)
set /A total+=1
goto :eof

