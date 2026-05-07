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
    echo "Conectado como $usuario en el dominio $dominio"
}

ajustar_contexto_sistema() {
    export OS_SYSTEM_SCOPE="all"
    unset OS_DOMAIN_NAME
    unset OS_PROJECT_NAME
    unset OS_PROJECT_DOMAIN_NAME
    echo "Contexto ajustado a sistema"
}

ajustar_contexto_proyecto() {
    export OS_PROJECT_NAME="$1"
    export OS_PROJECT_DOMAIN_NAME="$2"
    unset OS_DOMAIN_NAME
    unset OS_SYSTEM_SCOPE
    echo "Contexto ajustado a proyecto $1 en el dominio $2"
}

ajustar_contexto_dominio() {
    export OS_DOMAIN_NAME="$1"
    unset OS_SYSTEM_SCOPE
    unset OS_PROJECT_NAME
    unset OS_PROJECT_DOMAIN_NAME
    echo "Contexto ajustado a dominio $1"
}

recoger_parametros() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --username)
                if [[ -z "$2" ]]; then
                    echo "Error: --username requiere un valor"
                    echo "Uso: $0 --username <usuario>"
                    exit 1
                fi
                USUARIO_ADMINISTRADOR="$2"
                shift 2
                ;;
            *)
                echo "Argumento desconocido: $1"
                echo "Uso: $0 --username <usuario>"
                exit 1
                ;;
        esac
    done
    if [[ -z "$USUARIO_ADMINISTRADOR" ]]; then
        echo "Error: --username es obligatorio"
        echo "Uso: $0 --username <usuario>"
        exit 1
    fi
}

recoger_parametros "$@"

DOMINIO_ADMINISTRADOR="dominio-$USUARIO_ADMINISTRADOR"
NUEVO_DOMINIO="dominio-$USUARIO_ADMINISTRADOR-cliente"
NUEVO_PROYECTO="proyecto-$USUARIO_ADMINISTRADOR-cliente"
USUARIO_MANAGER="$USUARIO_ADMINISTRADOR-manager"
USUARIO_OPERADOR="$USUARIO_ADMINISTRADOR-operador"
USUARIO_MONITORIZACION="$USUARIO_ADMINISTRADOR-monitorizacion"
PASSWORD='Pa$$w0rd'



# Queremos un script (sh, bat)
# - Conectarme con scope de sistema, con mi usuario alumnoX
conectar_con_usuario "$USUARIO_ADMINISTRADOR" "$PASSWORD" "$DOMINIO_ADMINISTRADOR"
ajustar_contexto_sistema
# - Creamos un dominio llamado                                                dominio-alumnoX-cliente
openstack domain create --description "Dominio del cliente de $USUARIO_ADMINISTRADOR" "$NUEVO_DOMINIO" 2>/dev/null \
    && echo "Se ha creado: $NUEVO_DOMINIO" || echo "YA existe: $NUEVO_DOMINIO"
# - Crear un usuario en ese dominio                                           alumnoX-manager
openstack user create --domain "$NUEVO_DOMINIO" --password "$PASSWORD" "$USUARIO_MANAGER" 2>/dev/null \
    && echo "Se ha creado: $USUARIO_MANAGER" || echo "YA existe: $USUARIO_MANAGER"
# - Le asignamos role manager al usuario alumnoX-manager en el dominio dominio-alumnoX-cliente
openstack role add --domain "$NUEVO_DOMINIO" --user "$USUARIO_MANAGER" manager 2>/dev/null \
    && echo "Se ha asignado: manager a $USUARIO_MANAGER en $NUEVO_DOMINIO" || echo "YA existe: rol manager en $USUARIO_MANAGER"

# Accedemos como usuario alumnoX-manager a nivel de ese dominio
conectar_con_usuario "$USUARIO_MANAGER" "$PASSWORD" "$NUEVO_DOMINIO"
ajustar_contexto_dominio "$NUEVO_DOMINIO"
# - Creamos un proyecto llamado                                               proyecto-alumnoX-cliente
openstack project create --domain "$NUEVO_DOMINIO" --description "Proyecto del cliente de $USUARIO_ADMINISTRADOR" "$NUEVO_PROYECTO" 2>/dev/null \
    && echo "Se ha creado: $NUEVO_PROYECTO" || echo "YA existe: $NUEVO_PROYECTO"
# - Creamos un usuario para el dominio                                        alumnoX-operador
openstack user create --domain "$NUEVO_DOMINIO" --password "$PASSWORD" "$USUARIO_OPERADOR" 2>/dev/null \
    && echo "Se ha creado: $USUARIO_OPERADOR" || echo "YA existe: $USUARIO_OPERADOR"
# - Creamos un usuario para el dominio                                        alumnoX-monitorizacion
openstack user create --domain "$NUEVO_DOMINIO" --password "$PASSWORD" "$USUARIO_MONITORIZACION" 2>/dev/null \
    && echo "Se ha creado: $USUARIO_MONITORIZACION" || echo "YA existe: $USUARIO_MONITORIZACION"
# - Asigmamos rol de reader al usuario alumnoX-monitorizacion en el proyecto proyecto-alumnoX-cliente
openstack role add --project "$NUEVO_PROYECTO" --user "$USUARIO_MONITORIZACION" reader 2>/dev/null \
    && echo "Se ha asignado: reader a $USUARIO_MONITORIZACION en $NUEVO_PROYECTO" || echo "YA existe: rol reader en $USUARIO_MONITORIZACION"
# - Asigmamos rol de member al usuario alumnoX-operador en el proyecto proyecto-alumnoX-cliente
openstack role add --project "$NUEVO_PROYECTO" --user "$USUARIO_OPERADOR" member 2>/dev/null \
    && echo "Se ha asignado: member a $USUARIO_OPERADOR en $NUEVO_PROYECTO" || echo "YA existe: rol member en $USUARIO_OPERADOR"

# Probais a conectaros con esos usuarios con scope de proyecto.
conectar_con_usuario "$USUARIO_OPERADOR" "$PASSWORD" "$NUEVO_DOMINIO"
ajustar_contexto_proyecto "$NUEVO_PROYECTO" "$NUEVO_DOMINIO"
# - Y miro que puedo ver los datos del proyecto.
openstack project list --my-projects

conectar_con_usuario "$USUARIO_MONITORIZACION" "$PASSWORD" "$NUEVO_DOMINIO"
ajustar_contexto_proyecto "$NUEVO_PROYECTO" "$NUEVO_DOMINIO"
# - Y miro que puedo ver los datos del proyecto.
openstack project list --my-projects


