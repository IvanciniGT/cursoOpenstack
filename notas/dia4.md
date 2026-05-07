# HEAT

Es un componente adicional que puedo instalar/usar en mi cloud de openstack.

Tenemos que pensar en HAT como si pensásemos en otro cliente de openstack:
Clientes de openstack:
- Cliente de linea de comandos:       $ openstack server list
- Cliente Web:                          Horizon
- Cliente Heat

Para usarlo, lo que haremos es DEFINIR PLANTILLAS (HOT) que son archivos de texto con formato YAML, donde se definen/declarar los recursos sobre los que querremos hacer alguna operación en el futuro!
Operaciones como: Crearlos, Actualizarlos, Borrarlos, etc.

La idea es simple:

    PASO 1: Escribo una plantilla, que declara RECURSOS.

    PASO 2: Pedimos a HEAT que aplique esa plantilla, y HEAT se encarga de crear los recursos que hemos declarado. Es decir, de hacer un DESPLIEGUE, que tendrá un NOMBRE DE DESPLIEGUE!

    PASO 3: Según avance el proyecto, vamos modificando esa plantilla.
    
    PASO 4: Pedimos a HEAT que aplique la plantilla modificada, y HEAT se encarga de actualizar los recursos que de MI DESPLIEGUE para que se ajusten a lo que he declarado en la nueva versión de la plantilla.
    Lo que dará lugar a una nueva versión de mi despliegue.

    Y... Vuelta al PASO 3.... hasta que el proyecto esté terminado, y entonces necesitemos desmantelar todo lo que hemos creado

    PASO FINAL: Pedimos a HEAT que borre todos los recursos que hayamos generado para mi despliegue.

        PLANTILLA (HOT)
         --> Se aplica todas las veces que quiera para ir dando lugar a DESPLIEGUES!
         --> La pllantilla puede evolucionar... y podré ir solicitando la actualización de mis despliegues para que se ajusten a la nueva versión de la plantilla.

A los despliegues en HEAT se les llama STACKS, y cada vez que aplicamos una plantilla, se genera un nuevo STACK, con su nombre, su versión, etc.

    Imaginad esta plantilla:
        - Plantilla de "DEFINICION DE DOMINIO":                   v1
            - DOMINIO NUEVO
            - tener un usuario ESPECIAL para ese DOMINIO
            - con rol MANAGER al usuario nuevo
          Pero esa plantilla puede estar parametrizada... puedo querer que al aplicarla, se me pregunte el NOMBRE DEL DOMINIO y el NOMBRE DEL USUARIO.

        - Y ahora la aplico, para generar:
          - Stack "UNIDAD DE NEGOCIO A"                    v1
            - DOMINIO "UNIDAD DE NEGOCIO A"
            - USUARIO "Menchu"
          - Stack "UNIDAD DE NEGOCIO B"                    v1
            - DOMINIO "UNIDAD DE NEGOCIO B"
            - USUARIO "Felipe"
      
        - Modifico la plantilla... Quiero que cree un segundo usuario MONITORIZACION, con rol READER en el dominio:                                              v2
      
        - El día de mañana puedo pedir que se replaique la plantilla (la nueva versión) sobre el DESPLIEGUE "UNIDAD DE NEGOCIO A", y HEAT se encargará de crear el nuevo usuario "MONITORIZACION" con rol READER en el dominio "UNIDAD DE NEGOCIO A"
           - Stack "UNIDAD DE NEGOCIO A"                    v2
            - DOMINIO "UNIDAD DE NEGOCIO A"
            - USUARIO "Menchu"
            - USUARIO "MONITORIZACION"

        - Pero en paralelo puedo seguir con la versión v1 del despliegue "UNIDAD DE NEGOCIO B", sin que se vea afectado por los cambios que he hecho en la plantilla, y sin que se vea afectado por los cambios que he hecho en el despliegue "UNIDAD DE NEGOCIO A"
           - Stack "UNIDAD DE NEGOCIO B"                    v1
            - DOMINIO "UNIDAD DE NEGOCIO B"
            - USUARIO "Felipe" 

Y como vemos, nos aparece muy claro en concepto de VERSION DE LA INFRAESTRUCTURA!
Que irá cambiando con el tiempo.

HEAT Es quién se encarga de:
- Aplicar las plantillas sobre despliegues (para crearlos, actualizarlos, o borrarlos)
- E ir llevando el control de versiones de los despliegues, para que podamos tener claro:
  - En que estado (versión) se encuentra cada despliegue
  - Qué cambios ocurrieron la última vez que se actualizó cada despliegue
  - Cuándo se hicieron esos cambios
  - etc.

El trabajar así no solo facilita la escritura de los scripts.
Me permite llevar un CONTROL FERREO sobre mi infraestructura, y me permite tener un HISTORIAL DE CAMBIOS de mi infraestructura, que es algo que no tengo si hago las cosas a mano.
Podría incluso echar marcha atrás en una versión... o ir incluso a 4 versiones atrás de LA INFRA!

Flujo normal:

    - Creo una plantilla, con parámetrización.
    - Defino un fichero de configuración con VALORES PARA LOS PARÁMETROS DE LA PLANTILLA, apra un primer despliegue!
    - Y subo eso a un repo de GIT... git commit & push
    - Y he acabado! A tomar café!
    - Mañana me piden que la VM tenga más RAM.
    - Abro el fichero de parámetros, y cambio el valor de la RAM.
    - Hago git commit & push
    - Y he acabado! A tomar café!
    - Pasado me piden 2 máquinas nuevas.
    - Abro la plantilla, y añado la declaración de las 2 máquinas nuevas.
    - Abro el fichero de parámetros, y añado los valores de los parámetros que he añadido en la plantilla.
    - Hago git commit & push
    - Y he acabado! A tomar café!

Y lo querré es un PIPELINE DE CI/CD, que se encargue de:
- Detectar en automático que he hecho cambios en mi repo de GIT
- Que saque esos cambios en un contenedor, que tenga instalado el cliente de Openstack, jutno con la extensión de heat, que se instala aparte.
- Y que ejecute el comando de HEAT para aplicar la plantilla
- Que le haga unas pruebas mínimas para verificar que el despliegue se ha hecho correctamente
- Si no ha sido así: 
  - Que eche marcha atrás a la versión anterior de mi infraestructura, para que no se quede en un estado roto
  - Y que me mande 40 mensajes por teams, correo... lo que sea.
- Si si ha sido así:
  - Que me mande un mensaje de éxito y un café pa' celebrarlo!

Ese script... que lo monte un "DEVOPS" de esos.
Mi trabajo es escribir la plantilla, y el fichero de parámetros, y subirlo a GIT... y a tomar café!

Me acaban de quitar la "emoción" de entrar al VSphere a buscar la Máquina Virtual, y darle al botón de editar, cambiarle la RAM... reiniciarla...
Yo ya no hago eso... eso queda AUTOMATIZADO!
Mi trabajo ahora es editar unos ficheros de texto y subirlos a GIT... y a tomar café!

MIERDAS! ME ACABAN DE CONVERTIR EN UN PUÑETERO PROGRAMADOR DE ESOS!
Ups! Es lo que hay!



---

Para mi, un usuario es INFRAESTRUCTURA!
Un ROLE, es INFRAESTRUCTURA!
Un proyecto, es INFRAESTRUCTURA!
Una máquina virtual, es INFRAESTRUCTURA!
Una red, es INFRAESTRUCTURA!

---

Cualquier proceso que arranco en un entorno linux (windows igual) Tiene 3 canales por defecto configurados para comunicarme con el:

Canal 0: STDIN (Standard Input) --> Para enviarle información al proceso
Canal 1: STDOUT (Standard Output) --> Para recibir información del proceso
Canal 2: STDERR (Standard Error) --> Para recibir los mensajes de error del proceso

Y todo proceso, cuando acaba devuelve un código de salida (exitCode).
- Si es 0, entendemos que el proceso ha acabado correctamente.
- Si es distinto de 0, entendemos que el proceso ha acabado con error.
- Cada programa lanza codigos distintos de cero para distintos tipos de error, pero eso ya depende de cada programa.
  En un programa X, el código:
    1 -> Error de conexión a la base de datos
    2 -> Error de autenticación
    3 -> Error de permisos