@echo off
setlocal enabledelayedexpansion

:: =========================================================
:: ROG ALLY X - AUTO-SWITCH INSTALLER
:: =========================================================

:: 1. Check for Administrator Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Administrator privileges required.
    echo ---------------------------------------------------
    echo Please Right-Click this file and select "Run as Administrator"
    echo ---------------------------------------------------
    pause
    exit /b
)

:: 2. Locate the PowerShell script (Must be in the same folder)
set "ScriptDir=%~dp0"
set "PSFile=%ScriptDir%GPU_Config_Swapper.ps1"

if not exist "%PSFile%" (
    echo [ERROR] Could not find "GPU_Config_Swapper.ps1"
    echo ---------------------------------------------------
    echo Please move "GPU_Config_Swapper.ps1" into this folder:
    echo %ScriptDir%
    echo ---------------------------------------------------
    pause
    exit /b
)

echo Found script at: %PSFile%
echo.
echo Installing Scheduled Task...

:: 3. Delete existing task (to ensure a clean install)
schtasks /delete /tn "ROG_Ally_GPU_Swapper" /f >nul 2>&1

:: 4. Create the new task
::    /sc ONLOGON  -> Runs when you log into Windows
::    /rl HIGHEST  -> Runs with Admin rights (Crucial for file copying)
::    /tr          -> Commands PowerShell to run the script in Hidden mode with -Monitor
schtasks /create /tn "ROG_Ally_GPU_Swapper" /sc ONLOGON /rl HIGHEST /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%PSFile%\" -Monitor"

if %errorLevel% equ 0 (
    echo.
    echo [SUCCESS] Task created successfully!
    echo.
    echo The script is designed to run silently in the background.
    echo We are starting it for you right now...

    :: 5. Launch the script immediately so no reboot is needed
    start "" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%PSFile%" -Monitor
) else (
    echo.
    echo [ERROR] Failed to create task. Please check the error message above.
)

echo.
echo Press any key to close...
pause >nul@echo off
          setlocal enabledelayedexpansion

          :: =========================================================
          :: ROG ALLY X - AUTO-SWITCH INSTALLER
          :: =========================================================

          :: 1. Check for Administrator Privileges
          net session >nul 2>&1
          if %errorLevel% neq 0 (
              echo [ERROR] Administrator privileges required.
              echo ---------------------------------------------------
              echo Please Right-Click this file and select "Run as Administrator"
              echo ---------------------------------------------------
              pause
              exit /b
          )

          :: 2. Locate the PowerShell script (Must be in the same folder)
          set "ScriptDir=%~dp0"
          set "PSFile=%ScriptDir%GPU_Config_Swapper.ps1"

          if not exist "%PSFile%" (
              echo [ERROR] Could not find "GPU_Config_Swapper.ps1"
              echo ---------------------------------------------------
              echo Please move "GPU_Config_Swapper.ps1" into this folder:
              echo %ScriptDir%
              echo ---------------------------------------------------
              pause
              exit /b
          )

          echo Found script at: %PSFile%
          echo.
          echo Installing Scheduled Task...

          :: 3. Delete existing task (to ensure a clean install)
          schtasks /delete /tn "ROG_Ally_GPU_Swapper" /f >nul 2>&1

          :: 4. Create the new task
          ::    /sc ONLOGON  -> Runs when you log into Windows
          ::    /rl HIGHEST  -> Runs with Admin rights (Crucial for file copying)
          ::    /tr          -> Commands PowerShell to run the script in Hidden mode with -Monitor
          schtasks /create /tn "ROG_Ally_GPU_Swapper" /sc ONLOGON /rl HIGHEST /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%PSFile%\" -Monitor"

          if %errorLevel% equ 0 (
              echo.
              echo [SUCCESS] Task created successfully!
              echo.
              echo The script is designed to run silently in the background.
              echo We are starting it for you right now...

              :: 5. Launch the script immediately so no reboot is needed
              start "" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%PSFile%" -Monitor
          ) else (
              echo.
              echo [ERROR] Failed to create task. Please check the error message above.
          )

          echo.
          echo Press any key to close...
          pause >nul