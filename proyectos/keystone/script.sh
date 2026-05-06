#!/bin/bash
# Establezco la ruta del keystone y la versión de la API
export OS_AUTH_URL="https://keystone.ivanosuna.com/v3"
export OS_IDENTITY_API_VERSION=3

conectar_con_usuario() {
    local usuario=$1
    local password=$2
    local dominio=$3
    export OS_USERNAME="$usuario"
    export OS_USER_DOMAIN_NAME="$dominio"
    export OS_PASSWORD="$password"
}

ajustar_contexto_sistema() {
    export OS_SYSTEM_SCOPE="all"
    unset OS_DOMAIN_NAME
    unset OS_PROJECT_NAME
    unset OS_PROJECT_DOMAIN_NAME
}

ajustar_contexto_proyecto() {
    export OS_PROJECT_NAME="$1"
    export OS_PROJECT_DOMAIN_NAME="$2"
    unset OS_DOMAIN_NAME
    unset OS_SYSTEM_SCOPE
}

ajustar_contexto_dominio() {
    export OS_DOMAIN_NAME="$1"
    unset OS_SYSTEM_SCOPE
    unset OS_PROJECT_NAME
    unset OS_PROJECT_DOMAIN_NAME
}

USUARIO_ADMINISTRADOR="alumno15"
NUEVO_DOMINIO="dominio-alumno15-cliente"
NUEVO_PROYECTO="proyecto-alumno15-cliente"
USUARIO_MANAGER="alumno15-manager"
USUARIO_OPERADOR="alumno15-operador"
USUARIO_MONITORIZACION="alumno15-monitorizacion"
PASSWORD='Pa$$w0rd'



# Queremos un script (sh, bat)
# - Conectarme con scope de sistema, con mi usuario alumnoX
conectar_con_usuario "$USUARIO_ADMINISTRADOR" "$PASSWORD" "dominio-alumno15"
ajustar_contexto_sistema
# - Creamos un dominio llamado                                                dominio-alumnoX-cliente
openstack domain create --description "Dominio del cliente de $USUARIO_ADMINISTRADOR" "$NUEVO_DOMINIO"
# - Crear un usuario en ese dominio                                           alumnoX-manager
openstack user create --domain "$NUEVO_DOMINIO" --password "$PASSWORD" "$USUARIO_MANAGER"
# - Le asignamos role manager al usuario alumnoX-manager en el dominio dominio-alumnoX-cliente
openstack role add --domain "$NUEVO_DOMINIO" --user "$USUARIO_MANAGER" manager

# Accedemos como usuario alumnoX-manager a nivel de ese dominio
conectar_con_usuario "$USUARIO_MANAGER" "$PASSWORD" "$NUEVO_DOMINIO"
ajustar_contexto_dominio "$NUEVO_DOMINIO"
# - Creamos un proyecto llamado                                               proyecto-alumnoX-cliente
# - Creamos un usuario para el dominio                                        alumnoX-operador
# - Creamos un usuario para el dominio                                        alumnoX-monitorizacion
# - Asigmamos rol de reader al usuario alumnoX-monitorizacion en el proyecto proyecto-alumnoX-cliente
# - Asigmamos rol de member al usuario alumnoX-operador en el proyecto proyecto-alumnoX-cliente

# Probais a conectaros con esos usuarios con scope de proyecto.
# - Y miro que puedo ver los datos del proyecto.
