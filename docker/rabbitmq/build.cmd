@ECHO OFF

git log -1 > .gitinfo
git show --oneline -s >> .gitinfo

:: SETUP :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET DOTENVFILE=%~dp0\env-local
CALL %~dp0\..\..\.env.cmd

::------------------------------------------------------------------------------

SET build_args=
SET build_args=%build_args% -t "%RABBITMQ_IMAGE_NAME%"
@ECHO ON
docker build %build_args% -f %~dp0Dockerfile %DOTENVDIR%
@IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORCODE%
@ECHO OFF

::------------------------------------------------------------------------------

SET run_args=
SET run_args=%run_args% --name "%RABBITMQ_CNAME%" --hostname "%RABBITMQ_HOST%" --network "%DOCKER_NETWORK%"
SET run_args=%run_args% --env "RABBITMQ_DEFAULT_USER=%RABBITMQ_DEFAULT_USER%" --env "RABBITMQ_DEFAULT_PASS=%RABBITMQ_DEFAULT_USER%"
SET run_args=%run_args% -p "%RABBITMQ_PORT%:5672"
SET run_args=%run_args% -p "%RABBITMQ_ADMIN_PORT%:15672"

@ECHO ON
docker stop "%RABBITMQ_CNAME%"
docker rm   "%RABBITMQ_CNAME%"
docker run %run_args% --detach -it "%RABBITMQ_IMAGE_NAME%"
@IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORCODE%
@ECHO OFF

::------------------------------------------------------------------------------

::SET _TAGNAME=%APP_REGISTRY_BASE%%APACHE_IMAGE_NAME%:latest
::@ECHO ON
::docker tag %APACHE_IMAGE_NAME% %_TAGNAME%
::@IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORCODE%
::@ECHO OFF

::------------------------------------------------------------------------------

::IF /I [%APP_REGISTRY_PUBLISH%] == [true] (
::    @ECHO ON
::    docker push %_TAGNAME%
::    @ECHO OFF
::)

::------------------------------------------------------------------------------
