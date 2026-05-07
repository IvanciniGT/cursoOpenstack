# Contenedores

Son una alternativa a las máquinas virtuales para ejecutar procesos de forma aislada.
Son mucho más ligeros que las máquinas virtuales, ya que comparten el mismo kernel del sistema operativo< del host.

Los contenedores se crean desde imágenes, que son archivos comprimidos que contienen todo lo necesario para ejecutar una los procesos que queremos correr dentro de ese contenedor.

Para trabajar con contenedores necesitamos un gestor de contenedores, como Docker o Podman.
Hoy en día, los entornos de producción se están moviendo a contenedores. 
Y ahí sale una herramienta llamada Kubernetes.
Permite es Crear y Operar un entorno de producción basado en contenedores.

Hay distros de kubernetes, que añaden funcionalidades: Openshift, AKS, EKS, GKS, Tanzu, etc.

# Instalación de Openstack

Instalar un openstack es muy complejo, de los tipos de sistemas más complejos con mucha diferencia que hay.
Son muchas piezas, con muchas configuraciones muy especiales y muy adaptadas a mi infra y entorno.

De hecho, openstack consta de muchos proyectos, cada uno con su función específica (un tipo de servicio que ofreceré en el cloud que voy a montar).

En paralelo con eso, existen un huevo de proyectos solo para la instalación de openstack, que se encargan de instalar y configurar todos los servicios de openstack.

- Openstack-helm. Oficial, Opensource. Basado en Kubernetes.
- Rhoso (Red Hat OpenStack). Basado en Openshift, de Red Hat.
- SunBeam (Canocical). Basado en Kubernetes.
- Ansible-Kolla (Openstack). Basado en Docker.
- ...

Además de los componentes oficiales, Openstack necesita más cosas:
- BBDD                              MariaDB, MySQL (los puedo poner en cluster activo, o en activo/pasivo)
- Sistema de mensajes               RabbitMQ, Kafka, etc.
- Sistema de almacenamiento         Ceph
- Sistema de cache                  Redis, Memcached
- Monitorización y observabilidad   Prometheus, Grafana, Loki, ELK, etc.
- ...

## Proyectos principales de Openstack

- Keystone: Servicio de identidad y autenticación.
            Catálogo de servicios.
- Cómputo:
  - Máquinas virtuales: Nova
  - Contenedores:       Zun             *
  - Hierro:             Ironic          *
- Red:
  - Redes virtuales:        Neutron
  - Balanceadores de carga: Octavia     *
  - DNS:                    Designate   *
- Almacenamiento:
  - Bloques:                Cinder
  - Objetos:                Swift
  - Archivos:               Manila
  - Imágenes:               Glance
- Plantillas:               Heat
- ...

# Keystone

Nos permite gestionar varios conceptos:

    Usuarios          >                    <             Dominios
        v                   Asignación                    ^
    Grupos de usuarios >                   <             Proyectos 
                                v
                              Roles

* Dominio:   Agrupación  lógica de usuarios, grupos y proyectos.
* Proyectos: Agrupaciones lógicas de recursos, que se gestionan de forma conjunta. 

La asignación de roles se hace a nivel de:
- Proyecto                      (editor, viewer)
- Dominio                       (manager)
- Sistema                       (admin)

Yo puedo crear todos los roles que me de la gana... pero... atente a las consecuencias.
Los roles se definen vía API HTTP (cualquier cliente de Openstack puede crear roles, y asignarlos a usuarios, grupos, proyectos o dominios).

Amigo.. pero lo que puede hacer eses rol (PERMISOS) eso va por otro lado.
Eso se define a nivel de cada servicio, en archivos de texto de políticas de OSLO*.

En esos archivos se define:
- Operación a Operación que reglas se deben cumplir para que un usuario con un rol determinado y habiéndose conectado con un determinado SCOPE pueda ejecutar esa operación:
  - Necesita tener role de ADMINISTRADOR
  - Necesita tener role de MANAGER y haberse conectado con scope de DOMINIO sobre el DOMINIO sobre el que quiere hacer una determinada operación.

Keystone se encarga de la AUTENTICACION GLOBAL de Openstac.
Genera un token de acceso que se puede usar para acceder a los servicios de Openstack.
Para ello, precisa que:
- El usuario se autentique con un método de autenticación (contraseña, certificado, etc.)
- Elija un SCOPE (proyecto, dominio o sistema) sobre el que se va a conectar.
    Muchas operaciones solo están disponibles cuando me contecto con un scope concreto.
        Por ejemplo, para crear VMs necesito conectarme con un scope de proyecto, no con un scope de dominio.

En ese token que se genera, KeyStone mete los roles que tiene el usuario para el scope con el que se ha conectado.

---

* OSLO: Proyecto que incluye todas las librerias transversales a todos los servicios de Openstack. 
        Incluye librerias de autorización, de gestión de configuración, de gestión de logs, etc.

        Usuario -> petición:
                    Quiero una VM de 4 cores y 16 gbs
                    Quiero que tenga 200 Gbs de Disco rapidito
                    Quiero que se le abran los puertos 80 y 443
                    Quiero poder acceder a ella mediante este nombre dns.*
                                                                                                    v
                     v                                                                              v AUTOSERVICIO
                    Alguien la procesa (sistema CENTRALIZADO)                                       v
                     (o alguienes!)
                     v 

                    Crear los recursos necesarios con las herramientas que manejamos:   |
                     - VMWare                                                           | Este trabajo lo hace Openstack
                     - PaloAlto                                                         |
                     - Cabinas  de almacenamiento                                       |

    Antes iba a la carnicería y le pedía al carnicero 2 kgs de filetes de ternera cortados finitos.
        Y el carnicero me los preparaba y me los vendía.

    Hoy en día usamos un modelo de AUTOSERVICIO, en un Supermercado.
    Voy y mi petición no se la hago a nadie... Miro las bandejas en la sección de carnicería, y cojo lo que quiero.

    Este modelo tiene sus ventajas e inconvenientes:
    Ventajas:
    - Rapidez: No tengo que esperar a que alguien me prepare lo que quiero.
    - Desde el punto de vista de la empresa, sale más barato... no necesito carnicero... o necesito menos carniceros.
      Tendré una central, donde preparo bandejas... 
    Inconvenientes:
    - Tengo que adaptarme a las bandejas que hay.
    - Es un mundo de desparrame / de consumismo *2

    Sastre / Pret-a-porter

---

*2
        JAVA y la gestión de memoria.

        JAVA es un lenguaje que hace un uso abusivo de la memoria. La misma app hecho en Java y hecha en C++ puede consumir 2x veces más memoria en Java que en C++.
        Qué os parece? Esto es bueno o malo? Feature! Es una característica de JAVA

        Lo curioso es que JAVA se diseño intencionalmente para haacer un uso abusivo y desproprcionado de la RAM.

            La appX , hacerla con C++ (que permite un control de la memoria finito) necesita 200h de desarrollador caro (60€/h)
            esa misma appX, hecha con JAVA (que hace un uso abusivo de la RAM)      necesita 150h de desarrollador barato (50€/h)

                Total: En C++ = 200h * 60€/h = 12000€
                       En JAVA = 150h * 50€/h = 7500€
                                                -----
                                                4500€

                                                Cuánto cuesta meter unas pastilla de RAM al servidor? 1500?
                                                No hay duda.

                                                Lo del consumir silicio y materiales raros.. y explotar los recursos naturales indiscriminadamente... eso es un tema aparte, pero no es un tema de coste económico, sino de coste medioambiental.

    Quiero una BBDD Oracle:
        - Antes la pedía a mi DBA (un tio que sabía cojones del oracle)... Y la BBDD iba niquelada!
          - Con una máquina con 8 cores y 32gbs atendía la hueva de gente
        - Ahora... la contrato a un cloud.. y el cloud la administra.
          - Va a ir igual? Ni parecido.. irá mucho menos fina... más lenta... peor.
          - Qué hago? Compensa con harware
            - Mete 12 cores y 64 gbs de RAM... ya va igual!
        Pero eso sale más caro.. No.. me ahorro al DBA!
        Y si meto ese coste, ya sale más barato

        ESTE ES EL MUNDO EN QUE ESTAMOS ! 

---

Cluster de Openstack:
5 mac mini
    Cluster de kubernetes
    Y dentro Openstack con algunos componentes:
        - Keystone                                  keystone.ivanosuna.com
        - Cinder
        - Swift
        - Nova
        - Compute
        - Neutron
        - Heat
        - Placement
        - ...
    El cliente web de openstack: horizon           horizon.ivanosuna.com


---

Nostros vamos a usar principalmente la linea de comandos: 
    
> openstack   TIPO_RECURSO    OPERACION    args

openstack       server          list

openstack       image           show        ubuntu-24-04

openstack      network         create       red-privada 

openstack      volume          delete       vol-12345678

--

Para ejecutar cualquier comando, antes de nada debemos generar un token de acceso...
Y ese token lo genera: KEYSTONE.

Hay 2 formas de pasarle los datos de generación de token a la CLI de Openstack:
- Variables de entorno
- Archivo clouds.yaml


# Variables de entorno que vamos a usar:

## La URL del keystone
OS_AUTH_URL =   http://keystone.ivanosuna.com:5000/v3

## La versión de API que habla ese keystone (depende de la versión de openstack con que esté instalado el keystone)
OS_IDENTITY_API_VERSION = 3

## Credenciales de usuario
OS_USERNAME = alumno15
OS_PASSWORD = <tu contraseña>
### Como parte de las credenciales: El dominio donde ese usuario ha sido creado
### Nota: Puedo tener 2 usuarios con el mismo nombre, pero en dominios diferentes. Para diferenciarlos, necesito el dominio.
OS_USER_DOMAIN_NAME = dominio-alumno15

## El scope con el que me voy a conectar

### Scope de proyecto

#### Nombre del proyecto
OS_PROJECT_NAME = proyecto-alumno15
#### Nota: El proyecto también pertenece a un dominio... y en dominios distintos puedo tener proyectos con el mismo nombre... para diferenciarlos, necesito el dominio.
#### Nombre del dominio donde ese proyecto ha sido creado
OS_PROJECT_DOMAIN_NAME = dominio-alumno15 

### Scope de dominio
#### Esto es el dominio sobre el que quiero conectarme... y sobre el que quiero hacer operaciones... y sobre el que tengo roles asignados.
OS_DOMAIN_NAME = dominio-alumno15

### Scope de sistema
#### Esto es el scope más alto... el que me da acceso a todo el sistema... a todos los dominios, a todos los proyectos... a todo... pero para conectarme con este scope necesito tener un rol de ADMINISTRADOR a nivel de SISTEMA.
OS_SYSTEM_SCOPE = all


## Los scopes son excluyentes entre si...
## Si el cliente ve todas esas variables de entorno, se vuelve loco


---

# Nombres e Identificadores en Openstack

En openstack TODO elemento tiene un ID único a nivel global, que es un UUID (Universally Unique Identifier).

Y además, cada elemento tiene un nombre.
Ese nombre NO TIENE PORQUE SER UNICO.
Puedo tener 2 objetos del mismo tipo con el mismo nombre, pero con IDs diferentes.
Esto es posible en openstack.

Los comandos de openstack admiten nombre y ID indistintamente.
Pero... si hay 2 objetos con el mismo nombre, el cliente de openstack se vuelve loco y no sabe a cual de los 2 objetos con el mismo nombre me estoy refiriendo... y me da un error.

RESUMEN. Si estoy a mano, puedo usar el nombre

Si estoy montando un script! SIEMPRE IDs
Esto no falla.

        Me saca el mio
            v
SYSTEM > DOMINIO > PROYECTO
  ^                     ^
Me muestra todo      Me vuelve a sacar todo!



openstack project list:
GET.      https://keystone.ivanosuna.com:443/v3/projects 
GET       https://keystone.ivanosuna.com/v3/users/b2bb4fa595fb44fb9ce07a857e42993d/projects


---

# KEYSTONE

- Gestión de Usuarios, Roles, grupos, dominios, proyectos, asignación de roles.

# Almacenamiento

## Ceph

Ceph es un sistema de almacenamiento distribuido, que se puede usar para almacenar bloques, objetos y archivos.

Los tipos de almacenamiento están ahí por un motivo. Depende el software que monte, así el tipo de almacenamiento que necesito usar.

### Almacenamiento de bloques

Es un tipo de almacenamiento que se presenta como un disco a la máquina (física o virtual) o un contenedor.
La gestión del disco la hace el cliente (la máquina o el contenedor) que lo monta:
- Particionado
- Formateado
- Montado

Ejemplos de almacenamiento de bloques: iscsi, Fibre Channel

### Almacenamiento de ficheros 

Es un tipo de almacenamiento cuya gestión la hace el sistema de almacenamiento, y yo puedo montarla como una unidad de re / carpeta en mi máquina o contenedor.
Ejemplos de almacenamiento de ficheros: NFS, SMB

### Almacenamiento de objetos

Es un tipo de almacenamiento basado en el modelo: SERVICIO DE ALMACENAMIENTO.
Qué puedo guardar ahí? Lo que quiera... bytes.
Y ese conjunto de bytes que mando, tiene un ID único, que es el que me devuelve el servicio de almacenamiento cuando le mando un objeto a guardar.
Cuando quiero recuperar aquello, le digo al servicio de almacenamiento: "Dame el objeto con ID tal", y el servicio me lo devuelve.
Como si fuera una BBDD simplona, pero sin SQL ni nada... solo con un ID.

> En qué casos conviene usar uno u otro?

>>BBDD? MariaDB Galera (cluster de mariadb para el backend del openstack.. quiero 3 instancias del mariadb)
 
De bloques. A cada instancia de la BBDD le pongo un "disco"... y que guarde ahñi sus datos... 
Me interesa que:
- La BBDD pueda tener rápido acceso a los bytes... pero bytes a trozos. (Habrá un fichero enorme de BBDD) y la BBDD se encargará de leer o escribir trozos (páginas) dentro de ese fichero.
- El archivo no es compartido.
- No me interesan sobrecargas de protocolos raros ni nada.

>> Cuándo me interesa un almacenamiento de archivos?

Compartir archivos entre varias máquinas o contenedores.
Quiero que varias máquinas o contenedores puedan acceder a los mismos archivos, y que el sistema de almacenamiento se encargue de gestionar el acceso concurrente a esos archivos.

  X:\Multimedia\Peliculas\2024\Película1.mkv
  X:\Multimedia\Peliculas\2024\Película2.mkv        Carpetas!
  X:\Multimedia\Canciones\2024\Canción1.mp3

>> Cuándo me interesa un almacenamiento de objetos?

Cuando los datos no van estructurados (no es por dentro... sino por fuera!... no hay carpetas... puede haberlas.. pero es secundario.)

Soy instagram, fb, twitter, wordpress.
Necesito guardar una foto, relacionada con un post. Lo unico que quiero es un ID... para guardar y para sacar.
No hay sobrecarga de otros conceptos.


CEPH ofrece todos esos tipos de almacenamiento.
Pero en realidad para CEPH, todo son objetos:
- Un volumen / disco de bloques es un objeto          El objeto será Gigas, Teras
- Un archivo de un sistema de archivos es un objeto   El objeto será Megas, Kbs
- Un objeto de almacenamiento de objetos es un objeto El objeto será Megas, Kbs

Usa una infraestructura hiperconvergente, donde el almacenamiento y el acceso a ese almacenamiento.
Nos ofrece resiliencia, alta disponibilidad, escalabilidad, etc.

CEPH usa el concepto de OSD (Object Storage Daemon), que es el proceso que se encarga de gestionar el almacenamiento de objetos sobre un dispositivo de almacenamiento (HDD, SSD, NVME, etc.) de un nodo.
Cada dispositivo de almacenamiento que tengo, lo asigno a un OSD, y el OSD se encarga de gestionar ese dispositivo de almacenamiento.

  Maquina 1
    HDD1   -    OSD1
    HDD2   -    OSD2
    SSD1   -    OSD3
  Maquina 2
    HDD1   -    OSD4
    HDD2 
    SSD1
  Maquina 3
    HDD1
    HDD2
    SSD1
    NVME1

Esos OSDs los uso para guardar cosas o sacar cosas.

Pero luego tiene otro concepto. El concepto de PG (Placement Group).
Un PG es un grupo de objetos, que se asignan a un conjunto de OSDs.

Cuando quiero guardar algo dentro de un CEPH lo guardo en un PG, y ese PG se encarga de gestionar el almacenamiento de ese objeto en los OSDs que tiene asignados.

Cada cosa (fichero, disco, objeto) que guardo en CEPH se parte en trozos. Trozos pequeños (configurable)... y de cada trozo se guardan varias copias (replicas) en diferentes OSDs, para garantizar la disponibilidad y la resiliencia de los datos.

Ese factor de replicación se define a nivel de cada PG.

Qué ofrece esto...
- El poder escribir un fichero en trozos sobre 40 HDD a la vez
- El poder leer un fichero en trozos sobre 40 HDD a la vez

El limitante aquí no suele ser la velocidad de los HDDs, sino la red.

Pero si tengo una buena red (25 Gbps, 40 Gbps, etc.) puedo conseguir velocidades de lectura y escritura muy altas.
Si la red es una mierduli (1G....) entonces el cuello de botella va a ser la red, y no los HDDs.
En una red de 1G el máximo que puedo conseguir es 125 MB/s, menos de los que da un HDD rotacional de 5400 rpm.
Pero si tengo una red de 25 Gbps, entonces el máximo que puedo conseguir es 3.125 GB/s, que es mucho más de lo que da un nvme.

Lo que guardamos en los placement groups son objetos.
Ceph ofrece 3 protocolos (gestionados por programas internos diferentes que tiene CEPH) para acceder a esos objetos:
- RBD (Rados Block Device): Para acceder a los objetos como si fueran discos de bloques.
- CephFS: Para acceder a los objetos como si fueran archivos de un sistema de archivos.
- RGW (Rados Gateway): Para acceder a los objetos como si fueran objetos de almacenamiento de objetos.

CEPH Es un proyecto OpenSource. Pero hay distros comerciales de CEPH, como Red Hat Ceph Storage, SUSE Enterprise Storage, etc.

Esto no está pensado para tener 4 HDD. Esto está pensado para cantidades GIGANTES de almacenamiento.

## Volviendo a Openstack

Openstack está altamente vinculado a CEPH, y se puede usar CEPH como backend de almacenamiento para los servicios de Openstack.

- Cinder (almacenamiento de bloques)
  Realmente cinder no guarda nada... 
  Solo me ofrece una capa de AUTOMATICAION/AUTOSERVICIO para crear y gestionar volúmenes de bloques sobre un CEPH (RBD).
- Swift (almacenamiento de objetos)
  Realmente swift no guarda nada... 
  Solo me ofrece una capa de AUTOMATICAION/AUTOSERVICIO para crear y gestionar objetos de almacenamiento de objetos sobre un CEPH (RGW).
- Manila (almacenamiento de archivos)
  Realmente manila no guarda nada... 
  Solo me ofrece una capa de AUTOMATICAION/AUTOSERVICIO para crear y gestionar sistemas de archivos sobre un CEPH (CephFS).

- Glance (almacenamiento de imágenes)
  Realmente glance no guarda nada... 
  Solo me ofrece una capa de AUTOMATICAION/AUTOSERVICIO para crear y gestionar imágenes de máquinas virtuales sobre:
  - Un CEPH (RGW)
  - Swift (almacenamiento de objetos)
  - Cinder (almacenamiento de bloques)

- Nova (cómputo)
  Para crear máquinas virtuales, necesita ESPACIO DE ALMACENAMIENTO.. aunque sean efímeras!
  Puedo crearlas sobre el FS del nodo.
  O puedo crearlas sobre CEPH (RBD).

  Si las creo en el FS del nodo:
  - No tengo posibilidad de migrar esa máquina virtual a otro nodo en caliente.
    La migración se hace vía : Stop de la máquina virtual, mover el fichero de la máquina virtual al otro nodo (scp), y arrancar la máquina virtual en el otro nodo. 
  - Si tengo un sistema de almacenamiento compartido entre los nodos como backend (CEPH), entonces puedo crear la máquina virtual sobre ese sistema de almacenamiento compartido, y entonces sí que puedo migrar la máquina virtual en caliente, sin necesidad de pararla, ni de mover ningún fichero, ni de nada... porque el sistema de almacenamiento compartido ya se encarga de que la máquina virtual esté disponible en todos los nodos.