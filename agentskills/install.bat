@echo off
REM Install specified agent skill
REM Usage: install.bat <skill_name> <install path>

set "SKILL_NAME=%~1"
set "INSTALL_PATH=%~2"

if not defined SKILL_NAME (
    echo Error: Skill name not provided.
    echo Usage: install.bat ^<skill_name^> ^<install_path^>
    exit /b 1
)

if not defined INSTALL_PATH (
    echo Error: Install path not provided.
    echo Usage: install.bat ^<skill_name^> ^<install_path^>
    exit /b 1
)

if not exist "%SOURCE_SKILL_PATH%" (
    echo Error: Skill '%SKILL_NAME%' not found at '%~dp0'.
    exit /b 1
)

if not exist "%INSTALL_PATH%" (
    echo Error: Install path '%INSTALL_PATH%' does not exist.
    exit /b 1
)

set "AGENT_SKILL_ROOT="
if exist "%INSTALL_PATH%\.agents" (
    set "AGENT_SKILL_ROOT=%INSTALL_PATH%\.agents"
) else if exist "%INSTALL_PATH%\.github" (
    set "AGENT_SKILL_ROOT=%INSTALL_PATH%\.github"
)

if not defined AGENT_SKILL_ROOT (
    echo Error: Neither '.agents' nor '.github' folder found in '%INSTALL_PATH%'.
    exit /b 1
)

set "SOURCE_SKILL_PATH=%~dp0%SKILL_NAME%"
set "DEST_SKILL_PATH=%AGENT_SKILL_ROOT%\%SKILL_NAME%"
set "BACKUP_SKILL_PATH=%DEST_SKILL_PATH%.bak"

echo Installing skill '%SKILL_NAME%' to '%AGENT_SKILL_ROOT%'...

REM If a backup folder already exists, delete it
if exist "%BACKUP_SKILL_PATH%" (
    echo Removing existing backup: %BACKUP_SKILL_PATH%
    rmdir /s /q "%BACKUP_SKILL_PATH%"
)

REM If the skill folder already exists in the destination, rename it to .bak
if exist "%DEST_SKILL_PATH%" (
    echo Backing up existing skill folder to %SKILL_NAME%.bak
    ren "%DEST_SKILL_PATH%" "%BACKUP_SKILL_PATH%"
)

REM Copy the skill folder to the install path
echo Copying skill folder...
xcopy "%SOURCE_SKILL_PATH%" "%DEST_SKILL_PATH%\" /E /I /Q /Y

if %errorlevel% equ 0 (
    echo Skill '%SKILL_NAME%' installed successfully.
) else (
    echo An error occurred during installation.
)

