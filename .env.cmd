@ECHO OFF

SET DOTENVDIR=%~dp0
ECHO [INFO] DOTENVDIR: %DOTENVDIR%

CALL :LOAD_ENV_FILE %DOTENVDIR%.env
IF NOT [%PROFILE%] == [] (
    ECHO [INFO] PROFILE: %PROFILE%
    CALL :LOAD_ENV_FILE %DOTENVDIR%.env.%PROFILE%
)
CALL :LOAD_ENV_FILE %DOTENVDIR%.env-local
IF NOT [%DOTENVFILE%] == [] (
    ECHO [INFO] DOTENVFILE: %DOTENVFILE%
    FOR /F %%P IN ("%DOTENVFILE%") DO MKDIR %%~dpP
    COPY /Y NUL %DOTENVFILE% >NUL
    COPY /Y NUL %DOTENVFILE%.raw >NUL
    FOR /F "eol=#" %%A IN ('ECHO.%DOTENVFILE_VARS: = ^& ECHO.%') DO (
        CALL ECHO %%A="%%%%A%%" >> %DOTENVFILE%.raw
        CALL :SAVE_ENV_FILE %%A "%%%%A:"=%%"
    )
)
GOTO :EOF

:LOAD_ENV_FILE
IF NOT EXIST %1 GOTO :EOF
ECHO [INFO] ENVFILE: %1
SET "DOTENVFILE_VARS= "
FOR /F "eol=# delims=" %%A IN (%1) DO (
    SET %%A
    FOR /F "tokens=1 delims==" %%B IN ("%%A") DO CALL :SET_VALUE %%B "%%%%B:"=%%"
    IF NOT [%DOTENVFILE%] == [] (
        FOR /F "tokens=1 delims==" %%B IN ("%%A") DO (
            CALL :ADD_IF DOTENVFILE_VARS %%B "%%DOTENVFILE_VARS%%" "%%DOTENVFILE_VARS: %%B =%%"
        )
    )
)
GOTO :EOF

:SET_VALUE
SET "%1=%~2"
GOTO :EOF

:ADD_IF
IF "%~3" == "%~4" CALL SET "%1=%%%1%%%2 "
GOTO :EOF

:SAVE_ENV_FILE
SETLOCAL
SET "_=%~2"
ECHO.%~1=${%~1:-"%_:\=\\%"} >> %DOTENVFILE%
ENDLOCAL
GOTO :EOF
