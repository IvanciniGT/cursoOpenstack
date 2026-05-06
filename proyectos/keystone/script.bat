@echo off
REM Establezco la ruta del keystone y la version de la API
set OS_AUTH_URL=https://keystone.ivanosuna.com/v3
set OS_IDENTITY_API_VERSION=3

set USUARIO_ADMINISTRADOR=alumno15
set NUEVO_DOMINIO=dominio-alumno15-cliente
set NUEVO_PROYECTO=proyecto-alumno15-cliente
set USUARIO_MANAGER=alumno15-manager
set USUARIO_OPERADOR=alumno15-operador
set USUARIO_MONITORIZACION=alumno15-monitorizacion
set PASSWORD=Pa$$w0rd



REM - Conectarme con scope de sistema, con mi usuario alumnoX
call :conectar_con_usuario %USUARIO_ADMINISTRADOR% %PASSWORD% dominio-alumno15
call :ajustar_contexto_sistema
REM - Creamos un dominio llamado                                              dominio-alumnoX-cliente
openstack domain create --description "Dominio del cliente de %USUARIO_ADMINISTRADOR%" %NUEVO_DOMINIO%
REM - Crear un usuario en ese dominio                                         alumnoX-manager
openstack user create --domain %NUEVO_DOMINIO% --password %PASSWORD% %USUARIO_MANAGER%
REM - Le asignamos role manager al usuario alumnoX-manager en el dominio dominio-alumnoX-cliente


REM Accedemos como usuario alumnoX-manager a nivel de ese dominio
REM - Creamos un proyecto llamado                                             proyecto-alumnoX-cliente
REM - Creamos un usuario para el dominio                                      alumnoX-operador
REM - Creamos un usuario para el dominio                                      alumnoX-monitorizacion
REM - Asignamos rol de reader al usuario alumnoX-monitorizacion en el proyecto proyecto-alumnoX-cliente
REM - Asignamos rol de member al usuario alumnoX-operador en el proyecto proyecto-alumnoX-cliente

REM Probais a conectaros con esos usuarios con scope de proyecto.
REM - Y miro que puedo ver los datos del proyecto.

goto :EOF

REM ============================================================
REM FUNCIONES
REM ============================================================

:conectar_con_usuario
    set OS_USERNAME=%~1
    set OS_PASSWORD=%~2
    set OS_USER_DOMAIN_NAME=%~3
    exit /b

:ajustar_contexto_sistema
    set OS_SYSTEM_SCOPE=all
    set OS_DOMAIN_NAME=
    set OS_PROJECT_NAME=
    set OS_PROJECT_DOMAIN_NAME=
    exit /b

:ajustar_contexto_proyecto
    set OS_PROJECT_NAME=%~1
    set OS_PROJECT_DOMAIN_NAME=%~2
    set OS_DOMAIN_NAME=
    set OS_SYSTEM_SCOPE=
    exit /b

:ajustar_contexto_dominio
    set OS_DOMAIN_NAME=%~1
    set OS_SYSTEM_SCOPE=
    set OS_PROJECT_NAME=
    set OS_PROJECT_DOMAIN_NAME=
    exit /b
