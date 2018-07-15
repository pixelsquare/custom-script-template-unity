@ECHO OFF
SETLOCAL EnableDelayedExpansion
REM SETLOCAL

CALL :SetAdministrativePrivilage

CALL :SetUnityEditorPath

CALL :SetEnvironmentAuthor

CALL :CopyCSTemplates

CALL :Success

:SetAdministrativePrivilage
ECHO ------------------------------------------
ECHO Setting Administrative Privilage
ECHO ------------------------------------------
ECHO.

FOR /F "tokens=3 delims=\ " %%I IN ('whoami /groups') DO (
	SET ENVIRONMENT_LEVEL=%%I
	IF "!ENVIRONMENT_LEVEL!" EQU "High" (
		EXIT /b 0
	)
)

IF NOT "%ENVIRONMENT_LEVEL%" EQU "High" (
	@powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process %~f0 -Verb runas"
	EXIT 0
)

EXIT /b 0

:SetUnityEditorPath
ECHO ------------------------------------------
ECHO Setting Unity Environment
ECHO ------------------------------------------
ECHO.

:: Check if variable is already defined in environment vars
IF DEFINED UNITY_DIR (
	IF EXIST "%UNITY_DIR%" (
		EXIT /b 0
	)
)

IF NOT EXIST "%UNITY_DIR%" (
	SET /P UNITY_DIR="Please enter unity path: "
	ECHO.
	
	IF NOT EXIST "!UNITY_DIR!" GOTO :SetUnityEditorPath
)

IF EXIST "%UNITY_DIR%" (
	SETX UNITY_DIR "%UNITY_DIR%" > NUL
	ECHO.
)

EXIT /b 0

:SetEnvironmentAuthor
ECHO ------------------------------------------
ECHO Author Credentials Setup
ECHO ------------------------------------------
ECHO.

IF DEFINED AUTHOR_NAME (
	SET /P CHANGE_NAME="Author name is set to "%AUTHOR_NAME%". Do you want to change it [y/n]? "
	ECHO.
	
	IF /I  "!CHANGE_NAME!" NEQ "y" (
		EXIT /b 0
	)
)

IF NOT DEFINED AUTHOR_NAME (
	GOTO :SetAuthorFirstName
)

:SetAuthorFirstName
SET /P AUTHOR_FIRST_NAME="Please enter your first name: "
ECHO.

GOTO :SetAuthorLastName

:SetAuthorLastName
SET /P AUTHOR_LAST_NAME="Please enter your last name: "
ECHO.

SET AUTHOR_NAME=%AUTHOR_FIRST_NAME% %AUTHOR_LAST_NAME%

ECHO Author Name: %AUTHOR_NAME%
SET /P CONFIRMATION="Please confirm your name [y/n]: "

IF /I  "!CONFIRMATION!" NEQ "y" (
	EXIST /b 0
)

SETX AUTHOR_NAME "%AUTHOR_NAME%" > NUL
ECHO.

EXIT /b 0

:CopyCSTemplates
SET MODIFIED_CSTEMPLATE=%~dp0\CSharpTemplates
SET UNITY_CSTEMPLATE=%UNITY_DIR%\Data\Resources\ScriptTemplates

IF NOT EXIST %MODIFIED_CSTEMPLATE% (
	ECHO ------------------------------------------
	ECHO Copying CSharp Templates from Unity
	ECHO ------------------------------------------
	ECHO.
	
	MKDIR %MODIFIED_CSTEMPLATE%
	
	IF EXIST "%UNITY_CSTEMPLATE%" (
		XCOPY /S /E /Q /Y "%UNITY_CSTEMPLATE%" "%MODIFIED_CSTEMPLATE%"
	)
)

GOTO :OverwriteCSTemplates

EXIT /b 0

:OverwriteCSTemplates
ECHO ------------------------------------------
ECHO Overwriting CSharp Templates from Unity
ECHO ------------------------------------------
ECHO.

ECHO Please do your changes NOW on CSharpTemplates files.
ECHO.

SET /P OVERWRITE_CSTEMPLATES="Overwrite Unity CSharp templates [y/n]?"
ECHO.

IF /I  "!OVERWRITE_CSTEMPLATES!" NEQ "y" (
	EXIT /b 0
)

IF EXIST %UNITY_CSTEMPLATE% (
	IF EXIST "%MODIFIED_CSTEMPLATE%" (
		XCOPY /S /E /Q /Y "%MODIFIED_CSTEMPLATE%" "%UNITY_CSTEMPLATE%"
	)
)

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

REM ENDLOCAL