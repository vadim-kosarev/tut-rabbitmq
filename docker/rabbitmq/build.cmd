@ECHO OFF

git log -1 > .gitinfo
git show --oneline -s >> .gitinfo

:: SETUP :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET DOTENVFILE=%~dp0\env-local
CALL %~dp0\..\..\.env.cmd
exit

::------------------------------------------------------------------------------
SET build_args=
SET build_args=%build_args% -t "%APACHE_IMAGE_NAME%"
@ECHO ON
docker build %build_args% -f %~dp0Dockerfile %DOTENVDIR%
@IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORCODE%
@ECHO OFF
::------------------------------------------------------------------------------

SET run_args=
SET run_args=%run_args% --name "%APACHE_CNAME%" --hostname "%APACHE_HOST%" -p %APACHE_PORT%:80 --network "%DOCKER_NETWORK%"
SET run_args=%run_args% --env-file %DOTENVFILE%.raw
SET run_args=%run_args% --env DOMAIN
SET run_args=%run_args% --env CI_API_HOSTPORT --env CI_USER --env CI_PASSWORD
SET run_args=%run_args% --env CI_DBHOST --env CI_DBPORT --env CI_DBNAME --env CI_DBNAME_RTS --env CI_DBUSER --env CI_DBPASSWORD
SET run_args=%run_args% --env SVN_BASE_URL --env SVN_USER --env SVN_PASSWORD
SET run_args=%run_args% --env REMOTE_USER
IF NOT [%APACHE_CUSTOMS%] == [] SET run_args=%run_args% --mount "type=bind,source=%~dp0%APACHE_CUSTOMS%,target=/opt/custom"
SET run_args=%run_args% --mount "type=bind,source=%DOTENVDIR%\Perl,target=/var/www/Perl"
SET run_args=%run_args% --mount "type=bind,source=%DOTENVDIR%\WebUI_CI,target=/var/www/WebUI_CI"

@ECHO ON
docker stop %APACHE_CNAME%
docker rm   %APACHE_CNAME%
docker run %run_args% --detach -it %APACHE_IMAGE_NAME%
@IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORCODE%
@ECHO OFF

::------------------------------------------------------------------------------

SET _TAGNAME=%APP_REGISTRY_BASE%%APACHE_IMAGE_NAME%:latest
@ECHO ON
docker tag %APACHE_IMAGE_NAME% %_TAGNAME%
@IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORCODE%
@ECHO OFF

::------------------------------------------------------------------------------

IF /I [%APP_REGISTRY_PUBLISH%] == [true] (
    @ECHO ON
    docker push %_TAGNAME%
    @ECHO OFF
)

::------------------------------------------------------------------------------
