@echo off
chcp 65001 >nul
REM Establezco la ruta del keystone y la version de la API
set OS_AUTH_URL=https://keystone.ivanosuna.com/v3
set OS_IDENTITY_API_VERSION=3

REM ----------------------------------------------------------
REM Parseo de argumentos
REM ----------------------------------------------------------
set USUARIO_ADMINISTRADOR=

:parse_args
if "%~1"=="" goto end_parse
if /i "%~1"=="--username" (
    if "%~2"=="" (
        echo Error: --username requiere un valor
        echo Uso: %~nx0 --username ^<usuario^>
        exit /b 1
    )
    set USUARIO_ADMINISTRADOR=%~2
    shift
    shift
    goto parse_args
)
echo Argumento desconocido: %~1
echo Uso: %~nx0 --username ^<usuario^>
exit /b 1

:end_parse
if "%USUARIO_ADMINISTRADOR%"=="" (
    echo Error: --username es obligatorio
    echo Uso: %~nx0 --username ^<usuario^>
    exit /b 1
)

set DOMINIO_ADMINISTRADOR=dominio-%USUARIO_ADMINISTRADOR%
set NUEVO_DOMINIO=dominio-%USUARIO_ADMINISTRADOR%-cliente
set NUEVO_PROYECTO=proyecto-%USUARIO_ADMINISTRADOR%-cliente
set USUARIO_MANAGER=%USUARIO_ADMINISTRADOR%-manager
set USUARIO_OPERADOR=%USUARIO_ADMINISTRADOR%-operador
set USUARIO_MONITORIZACION=%USUARIO_ADMINISTRADOR%-monitorizacion
set PASSWORD=Pa$$w0rd

REM - Conectarme con scope de sistema, con mi usuario alumnoX
call :conectar_con_usuario %USUARIO_ADMINISTRADOR% %PASSWORD% %DOMINIO_ADMINISTRADOR%
call :ajustar_contexto_sistema

REM - Creamos un dominio llamado                                              dominio-alumnoX-cliente
openstack domain create --description "Dominio del cliente de %USUARIO_ADMINISTRADOR%" %NUEVO_DOMINIO% 2>nul
if %errorlevel% == 0 (echo Se ha creado: %NUEVO_DOMINIO%) else (echo YA existe: %NUEVO_DOMINIO%)

REM - Crear un usuario en ese dominio                                         alumnoX-manager
openstack user create --domain %NUEVO_DOMINIO% --password %PASSWORD% %USUARIO_MANAGER% 2>nul
if %errorlevel% == 0 (echo Se ha creado: %USUARIO_MANAGER%) else (echo YA existe: %USUARIO_MANAGER%)

REM - Le asignamos role manager al usuario alumnoX-manager en el dominio dominio-alumnoX-cliente
openstack role add --domain %NUEVO_DOMINIO% --user %USUARIO_MANAGER% manager 2>nul
if %errorlevel% == 0 (echo Se ha asignado: manager a %USUARIO_MANAGER% en %NUEVO_DOMINIO%) else (echo YA existe: rol manager en %USUARIO_MANAGER%)

REM Accedemos como usuario alumnoX-manager a nivel de ese dominio
call :conectar_con_usuario %USUARIO_MANAGER% %PASSWORD% %NUEVO_DOMINIO%
call :ajustar_contexto_dominio %NUEVO_DOMINIO%

REM - Creamos un proyecto llamado                                             proyecto-alumnoX-cliente
openstack project create --domain %NUEVO_DOMINIO% --description "Proyecto del cliente de %USUARIO_ADMINISTRADOR%" %NUEVO_PROYECTO% 2>nul
if %errorlevel% == 0 (echo Se ha creado: %NUEVO_PROYECTO%) else (echo YA existe: %NUEVO_PROYECTO%)

REM - Creamos un usuario para el dominio                                      alumnoX-operador
openstack user create --domain %NUEVO_DOMINIO% --password %PASSWORD% %USUARIO_OPERADOR% 2>nul
if %errorlevel% == 0 (echo Se ha creado: %USUARIO_OPERADOR%) else (echo YA existe: %USUARIO_OPERADOR%)

REM - Creamos un usuario para el dominio                                      alumnoX-monitorizacion
openstack user create --domain %NUEVO_DOMINIO% --password %PASSWORD% %USUARIO_MONITORIZACION% 2>nul
if %errorlevel% == 0 (echo Se ha creado: %USUARIO_MONITORIZACION%) else (echo YA existe: %USUARIO_MONITORIZACION%)

REM - Asignamos rol de reader al usuario alumnoX-monitorizacion en el proyecto proyecto-alumnoX-cliente
openstack role add --project %NUEVO_PROYECTO% --user %USUARIO_MONITORIZACION% reader 2>nul
if %errorlevel% == 0 (echo Se ha asignado: reader a %USUARIO_MONITORIZACION% en %NUEVO_PROYECTO%) else (echo YA existe: rol reader en %USUARIO_MONITORIZACION%)

REM - Asignamos rol de member al usuario alumnoX-operador en el proyecto proyecto-alumnoX-cliente
openstack role add --project %NUEVO_PROYECTO% --user %USUARIO_OPERADOR% member 2>nul
if %errorlevel% == 0 (echo Se ha asignado: member a %USUARIO_OPERADOR% en %NUEVO_PROYECTO%) else (echo YA existe: rol member en %USUARIO_OPERADOR%)

REM Probais a conectaros con esos usuarios con scope de proyecto.
call :conectar_con_usuario %USUARIO_OPERADOR% %PASSWORD% %NUEVO_DOMINIO%
call :ajustar_contexto_proyecto %NUEVO_PROYECTO% %NUEVO_DOMINIO%
REM - Y miro que puedo ver los datos del proyecto.
openstack project list --my-projects

call :conectar_con_usuario %USUARIO_MONITORIZACION% %PASSWORD% %NUEVO_DOMINIO%
call :ajustar_contexto_proyecto %NUEVO_PROYECTO% %NUEVO_DOMINIO%
REM - Y miro que puedo ver los datos del proyecto.
openstack project list --my-projects

goto :EOF

REM ============================================================
REM FUNCIONES
REM ============================================================

:conectar_con_usuario
    set OS_USERNAME=%~1
    set OS_PASSWORD=%~2
    set OS_USER_DOMAIN_NAME=%~3
    echo Conectado como %~1 en el dominio %~3
    exit /b

:ajustar_contexto_sistema
    set OS_SYSTEM_SCOPE=all
    set OS_DOMAIN_NAME=
    set OS_PROJECT_NAME=
    set OS_PROJECT_DOMAIN_NAME=
    echo Contexto ajustado a sistema
    exit /b

:ajustar_contexto_proyecto
    set OS_PROJECT_NAME=%~1
    set OS_PROJECT_DOMAIN_NAME=%~2
    set OS_DOMAIN_NAME=
    set OS_SYSTEM_SCOPE=
    echo Contexto ajustado a proyecto %~1 en el dominio %~2
    exit /b

:ajustar_contexto_dominio
    set OS_DOMAIN_NAME=%~1
    set OS_SYSTEM_SCOPE=
    set OS_PROJECT_NAME=
    set OS_PROJECT_DOMAIN_NAME=
    echo Contexto ajustado a dominio %~1
    exit /b
