@ECHO OFF
SETLOCAL EnableDelayedExpansion
SETLOCAL

:: Set Unity Project Name
SET UNITY_PROJECT_NAME=UnityProject

:: Set Current Directory
SET CURRENT_DIR=%~dp0

:: Remove the last delimiter
SET CURRENT_DIR=%CURRENT_DIR:~0,-1%

CALL :SetAdministrativePrivilage

CALL :SetUnityProjectName

CALL :SetProjectEnvironment

REM CALL :OpenUnityProject

CALL :Success

:SetAdministrativePrivilage
ECHO ------------------------------------------
ECHO Setting Administrative Privilage
ECHO ------------------------------------------
ECHO.

FOR /F "tokens=3 delims=\ " %%I IN ('whoami /groups') DO (
	SET ENVIRONMENT_LEVEL=%%I
	IF "!ENVIRONMENT_LEVEL!"=="High" (
		EXIT /b 0
	)
)

IF NOT "%ENVIRONMENT_LEVEL%"=="High" (
	@powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process %~f0 -Verb runas"
	EXIT 0
)

EXIT /b 0

:SetUnityProjectName
IF NOT "%UNITY_PROJECT_NAME%"=="" (
	EXIT /b 0
)

ECHO ------------------------------------------
ECHO Setting Unity Project Name
ECHO ------------------------------------------
ECHO.

SET /P UNITY_PROJECT_NAME="Please enter unity project name: "
ECHO.

ECHO UNITY_PROJECT_NAME=%UNITY_PROJECT_NAME%
ECHO.

EXIT /b 0

:SetProjectEnvironment
CALL "%CURRENT_DIR%\02_setup_proj_env.bat"
EXIT /b 0

:OpenUnityProject
ECHO ------------------------------------------
ECHO Opening Unity Project
ECHO ------------------------------------------
ECHO.

:: Check if variable is defined
IF NOT DEFINED UNITY_DIR (
	GOTO :Failed
	ECHO.
	ECHO Unity directory is not defined!
	ECHO.
	GOTO :End
)

:: Check if directory exists
IF NOT EXIST "%UNITY_DIR%" (
	GOTO :Failed
	ECHO.
	ECHO Unity directory does not exist!
	ECHO UNITY_DIR=%UNITY_DIR%
	ECHO.
	GOTO :End
)

START "Unity" "%UNITY_DIR%\unity.exe" -projectPath "%CURRENT_DIR%\..\%UNITY_PROJECT_NAME%"

ECHO Opening unity project ...
ECHO.

EXIT /b 0

:Success
ECHO ------------------------------------------
ECHO Setup SUCCESS!
ECHO ------------------------------------------
ECHO.

ECHO Closing command line ..

TIMEOUT /T 5 > NUL /NOBREAK 
EXIT 0

:Failed
ECHO ------------------------------------------
ECHO Setup FAILED!
ECHO ------------------------------------------
ECHO.

EXIT /b 0

:End
PAUSE
EXIT 0

ENDLOCAL