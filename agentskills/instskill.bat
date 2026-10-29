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

if not exist "%INSTALL_PATH%" (
    echo Error: Install path '%INSTALL_PATH%' does not exist.
    exit /b 1
)

set "AGENT_SKILL_ROOT="
if exist "%INSTALL_PATH%\.agents" (
    set "AGENT_SKILL_ROOT=%INSTALL_PATH%\.agents\skills"
) else if exist "%INSTALL_PATH%\.github" (
    set "AGENT_SKILL_ROOT=%INSTALL_PATH%\.github\skills"
) else if exist "%INSTALL_PATH%\.claude" (
    set "AGENT_SKILL_ROOT=%INSTALL_PATH%\.claude\skills"
)


if not defined AGENT_SKILL_ROOT (
    echo Error: Neither '.agents' nor '.github' not '.claude' folder found in '%INSTALL_PATH%'.
    exit /b 1
)

set "SOURCE_SKILL_PATH=%~dp0%SKILL_NAME%"
set "DEST_SKILL_PATH=%AGENT_SKILL_ROOT%\%SKILL_NAME%"
set "BACKUP_SKILL_NAME=%SKILL_NAME%.bak"

echo Installing skill '%SKILL_NAME%' to '%AGENT_SKILL_ROOT%'...

REM Back up the skill in every possible destination folder
for %%R in (".agents" ".github" ".claude") do (
    call :backup_skill "%INSTALL_PATH%\%%~R\skills\%SKILL_NAME%"
)

REM Copy the skill folder to the install path
echo Copying skill folder...
xcopy "%SOURCE_SKILL_PATH%" "%DEST_SKILL_PATH%\" /E /I /Q /Y

if %errorlevel% equ 0 (
    echo Skill '%SKILL_NAME%' installed successfully.
) else (
    echo An error occurred during installation.
)
exit /b %errorlevel%

:backup_skill
set "SKILL_DIR=%~1"
if exist "%SKILL_DIR%" (
    if exist "%SKILL_DIR%.bak" (
        echo Removing existing backup: %SKILL_DIR%.bak
        rmdir /s /q "%SKILL_DIR%.bak"
    )
    echo Backing up existing skill folder to %SKILL_DIR%.bak
    ren "%SKILL_DIR%" "%BACKUP_SKILL_NAME%"
)
exit /b 0

