# Clouds

Un conjunto de servicios (relacionados con IT) que una proveedor ofrece a traves de internet:
- Pago por uso
- Automatizado de su lado -> AUTOSERVICIO

Hay muchos tipos de servicios que se ofrecen en cloud:
- Infraestructura como servicio (IaaS)
  - Cómputo  (Máquinas físicas, virtuales, contenedores)
  - Almacenamiento (Bloques, objetos, archivos)
  - Redes (IP, balanceadores de carga, firewalls)
- Plataforma como servicio (PaaS)
  - BBDD
  - Kubernetes
  - ...
- Software como servicio (SaaS)

## Openstack

Una herramienta que nos permite montar nuestro propio cloud, con infra on prem.
Mi cloud estará personalizado... ofreceré los servicios que yo quiera, con las características que yo quiera, y lo podré usar para lo que yo quiera.

Openstack tiene muchos proyectos.
Cada uno orientado a un tipo de servicio:
- Keystone -> Usuarios, Grupos, Autorización, Autenticación
           -> Registro de servicios del cloud y descubrimiento de servicios
- Cómputo
  - Ironic  -> Máquinas físicas
  - Nova    -> Máquinas virtuales
  - Zun     -> Contenedores
- Almacenamiento
  - Cinder   -> Bloques  (iscsi)
  - Swift    -> Objetos  (S3, MinIO)
  - Manila   -> Archivos (nfs)
  - Glance   -> Imágenes (qcow2, raw, vmdk)
- Redes
  - Neutron  -> Redes virtuales, IP flotantes, Security groups, Routers
  - Octavia  -> Balanceadores de carga
  - Designate -> DNS
- Y algunos más...

# Devops

Es una cultura, un movimiento, una filosofía que trata de promover la automatización de todo lo que sea susceptible de ser automatizado.
- Primer nivel de automatización:
  - Automatizar empaquetado de un producto
  - Automatizar ejecución de pruebas
  - Automatizar la creación de infraestructura
  - Automatizar el planchado de esa infraestructura
  - Automatizar el despliegue de la aplicación
  - Automatizar el monitoreo de la aplicación
- Segundo nivel de automatización:
  - Crear pipelines (script) de CI/CD para orquestar todos esos automatismos de primer nivel
  - Lo solemos hacer con un Jenkins o similar

El trabajo de todos los profesionales de IT se ve afectado.. y mucho de lo que antes hacían a mano ya no.
Su trabajo (o parte importante de él) es automatizar (=programar) lo que antes hacían a mano.
- Desarrolladores : Todo el trabajo de gestión de dependencias, compilación, empaquetado... lo automatizan con herramientas como Maven, Gradle, npm, etc.
- Testers : Todo el trabajo de ejecución de pruebas lo automatizan con herramientas como JUnit, Selenium, etc.
- SysAdmin : Todo el trabajo de creación, planchado, despliegue y monitoreo de infraestructura lo automatizan con herramientas como Ansible, Terraform, etc.

Hay cierta tendencia en la industria a llamar DEVOPS a los SysAdmins V2 (de automatización) y si encima tocan clouds mejor que mejor.

Realmente, El perfil DEVOPS, al menos cuando empieza se orientaba al profesional que maneja el Jenkins.

# Internet 

Ha cambiado la forma de uso de las apps... Tenemos picos y valles enormes.
El escalado debe ir por un cloud.

# IaC

No es solo tener la infra en ficheros (programas).
Deciamos que implica tratarla como si de código se tratase -> Versionado.
Solo eso, cambia TOTALMENTE la forma de entender y lidiar con la infra!

# Lenguajes declarativos

Los lenguajes de programación tradicionales (que hablan lenguaje imperativo) SON UN TOSTON!
Me hacen centrarme en la forma de conseguir algo... y no en lo que quiero conseguir.

Y para conseguir cierta IDEMPOTENCIA (que no importe el estado actual antes de ejecutar el programa) sudábamos... muchos if... muchos casitos. ASQUETE!

Esto lo cambian los paradigmas declarativos. Es otra forma de expresarnos... donde me centro en describir (declarar) lo que es.

> Felipe, Debajo de la ventana tiene que haber una silla. NO ES UNA ORDEN. Es lo que ES.

Da gusto trabajar con lenguajes declarativos:
- Terraform, HEAT
- Ansible
- Kubernetes
- Spring, Angular, .net, etc.

GRACIAS de los lenguajes declarativos:
- Ofrecen idempotencia de forma implícita
- Me permiten centrarme en lo que quiero conseguir

---

# Contenedores

Un contenedor es un entorno aislado dentro de un SO Linux, donde ejecuto procesos.
Aislado en qué sentido?
- Como entorno aislado que es, tiene sus propias variables de entorno
- Tiene su propio sistema de archivos (y ojo, que eso en Linux es decir mucho)
- Tiene su propia configuración de red (y por ende su propia IP)
- Puede tener limitaciones de acceso al Hardware (CPU, RAM, etc.)

Un proceso puede ser:
- Un mcroservicio
- Una BBDD
- Un sistema de mensajería
- Un triste comando
- Un script

---

# Modelos de despliegue de software

## Modelo tradicional

        App1 + App2 + App3          Esto es simple.
    -------------------------       Pero presenta problemas graves:
        Sistema Operativo               - Hay veces que las apps tiene bugs
    -------------------------               App1 (100% CPU) --> Offline
            Hierro                          App2 y App3 van detrás
                                        - Seguridad (app1 potencialmente puede espiar a app2 y app3)
                                        - Incompatibilidades (app1 necesita java 8, app2 necesita java 11, etc.)

## Modelo basado en Máquinas virtuales

     App1 + App2 |   App3
    -------------------------       Esta forma de trabajo nos resuelve todos los problemas del modelo tradicional.
          SO 1   |   SO 2           Viene con sus problemas:
    -------------------------        - Merma de recursos físicos efectivos.
          MV 1   |   MV 2            - Pérdida de rendimiento
    -------------------------        - Complejidad del entorno
           Hypervisor
    -------------------------
        Sistema Operativo
    -------------------------
             Hierro

## Modelo basado en Contenedores (2013)

     App1 + App2 |   App3
    -------------------------
          C 1   |   C 2    
    -------------------------
      Gestor de contenedores
      Docker, Podman, CRIO
      ContainerD, etc.
    -------------------------
    Sistema Operativo (Linux)
    -------------------------
             Hierro

Dentro de un contenedor no ejecuto un SO. De hecho no se puede!

Los contenedores los creamos desde IMAGENES DE CONTENEDOR.

Los contenedores no me resuelven lo mismo que las máquinas virtuales... 
Pero si me resuleven los problemas de las instalaciones tradicionales, cosa que también resuelven las máquinas virtuales.
Y para ese caso de uso (que al final era el 90% de las máquinas virtuales que creábamos) los contenedores son la mejor opción, mucho más ligeros, no penalizan rendimiento, no añaden complejidad, etc.

Y por eso, hoy en día, los contenedores se han convertido en el estandar de factor para el despliegue de aplicaciones.
Y TODO SOFTWARE empresarial se distribuye en forma de imágenes de contenedor.

# Imágen de contenedor

Triste fichero comprimido (tar) que lleva dentro 
- Una estructura de carpetas compatible pocon POSIX (Linux)
    /bin, /usr, /tmp, /var, /home, etc.
- Programas PREINSTALADOS en esas carpetas:
  - Programa principal que quiero correr en el contenedor
  - Otros programas de utilidad que pueda necesitar
- Configuraciones preestablecidas (variables de entorno, etc.)

Estas imágenes las descargamos de REGISTROS DE REPOSITORIOS DE IMAGENES DE CONTENEDOR.
- DockerHub
- Quay.io       <- REDHAT
- Microsoft Artifact Registry <- Microsoft
- Oracle Container Registry <- Oracle
- ...

Las imágenes llevan dentro programas PREINSTALADOS.
No es tampoco un concepto nuevo...
Desde qué creo una Máquina virtual? 
- Imagen ISO (plantilla, oficial)

Las imágenes de máquinas virtuales ocupan Gigas... las imágenes de contenedores ocupan Megas.
No llevan SO dentro.

 
---

# Qué era Unix?

Unis era un Sistema operativo creado por un departamento (laboratorios bell) de la americana de telecomunicaciones AT&T (La telefónica de los americanos) en los 70.
Ese sistema operativo se licenciaba de forma diferente a cómo se hace hoy en día (EULA = End User License Agreement).

AT&T lo licenciaba a grandes empresas, universidades y fabricantes de hardware...
Éstos lo modificaban para su uso (adaptándolo a sus necesidades y su HARDWARE).
Qué pasó? llegó a haber más de 400 versiones diferentes de UNIX. Muchas empezaron a mostrar incompatibilidades.

Cómo se le metió mano. 2 estándares:
- POSIX -> Portable Operating System Interface for Unix
- SUS   -> Single UNIX Specification

A principios de los años 2000 murió el SO Unix.

# Qué es Unix?

Unix Es esos 2 estándares, que siguen en evolución.
Muchos fabricantes de hardware crean sus propios SO basados en esos estándares... y los certifican.

IBM     -> AIX (UNIX®)
HP      -> HP-UX (UNIX®)
Oracle  -> Solaris (UNIX®)
Apple   -> MacOS (UNIX®)

# En paralelo

Muchos desarrolladores comienzan a crear SO basados en esos estándares. Pero no quieren certificarlos, que cuesta pasta!

- Universidad de berkley en california: 386-BSD (Berkeley Software Distribution). Lo consiguieron.
  La cagaron. Dijeron: TENEMOS UN SO UNIX GRATIS!
  Y AT&T demandó. Años de litigios.. el software parado. Cuando al final se resolvió (y se dió la razón a Universidad de berkley) ya habían pasado años y el software estaba obsoleto (ya no usábamos arquitectura 386).
  
  No obstante ese código se fue reusando para dar lugar a nuevos SO que si se usan a día de hoy:
  - FreeBSD, NetBSD, OpenBSD, DragonFly BSD, etc.
  - MacOS (UNIX®) de Apple

- GNU (Richard Stallman) -> GNU's Not Unix <- Pulla directa a AT&T por lo de BSD.
  Quería crear un SO libre, que cualquiera pudiera usar, modificar y distribuir.
  Montaron de todo lo que hace falta para un SO:
  - Cargadores de arranque
  - Shells (bash)
  - GUI (gnome)
  - compiladores (gcc)
  - chess
  No valieron para montar el kernel.

- Linus Torvalds... se mete en una cabañita ahñi en Finlandia.. yunpar de fines de semana y 7 millones de lineas de códgo más tarde sale con un kernel de SO "supuestamente" compatible (o que cumple) con los estánderes POSIX y SUS. 

Linux + GNU -> GNU/Linux (ESTO SI ES UN SISTEMA OPERATIVO)

Ese SO GNU/Linux se distribuye en forma de distros, que son sistemas operativos completos basados en GNU/Linux.
Sobre la base de GNU/Linux se ponen distintos paquetes de software y se toman decisiones opinionadas para crear distros orientadas a distintos tipos de usuarios:
- Se eligen shells, gestores de ventanas, etc.
- Se eligen paquetes de software preinstalados (navegadores, editores de texto, etc.)
- Se elige un sistema de gestión de paquetes (apt, yum, etc.)
- Se elige un ciclo de vida (cada cuánto se actualiza, cada cuánto se lanzan nuevas versiones, etc.)

- RHEL (Fedora, Oracle Unbreakable Linux, etc.)
- Debian (Ubuntu, Mint, etc.)
- Suse (OpenSUSE, etc.)
- Arch Linux (Manjaro, etc.)
- ...

# Linux?

Linux es un kernel de SO... de hecho, el kernel más usado del mundo.
Hay un sistema operativo que por si solo ya hace que Linux sea el kernel más usado del mundo... y ese sistema operativo es Android.

Hoy en día podemos correr el Kernel de Linux de forma nativa incluso en Windows.
Windows, entre sus características básicas, tiene la capacidad de ejecutar un kernel de Linux dentro de Windows:
Windows Subsystem for Linux (WSL)

---

Los contenedores se basan en utilidades que hay dentro del kernel de linux para generar esos entornos aislados.

Un contenedor corre en una máquina.
Qué pasa si pierdo la máquina? pierdo el contenedor.
Perder el contenedor, en si, no es problema. Creo otro... en otra máquina! y se acabó!
Dónde está el problema? En los datos que tenga ese contenedor!
Si cogemos y ponemos a funcionar unaa bbdd (mariadb) en un contenedor, los datos de la BBDD se guardan en una ruta relativa al Filesystem de ese contenedor: /var/lib/mysql
Si pierdo el contenedor, pierdo los datos de la BBDD.

Cómo resuelvo eso? Y cómo lo llevamos resolviendo décadas?
Guardando los datos en un almacenamiento externo al contenedor (Cabina de disco, NAS, SAN, etc.) y montando ese almacenamiento dentro del filesystem del contenedor : mount -t ... /var/lib/mysql

Si hubiera editado el contenido que venía originalmente en la imagen (una vez descomprimida) y lo hubiera guardado dentro del contenedor (sin estar en volumen externo)... también lo perdería al perder el contenedor.

PERO AQUI HAY ALGO INTERESANTE.
Con los contenedores no trabajamos como con las máquinas virtuales.
Cuándo se borra una VM? Cuando muera el proyecto donde se necesitaba.
Creo una VM... le instalo un mariaDB versión 10.3... 
Y Ahora quiero montar la 10.4... que hago?
El miso que si tuviera el mariadb en máquina física: Entro a la máquina virtual, actualizo el mariadb a 10.4, y listo.

Con contenedores no trabajsmo así. Cogería y borro el contenedor, y creo un contenedor nuevo con la imagen de mariadb 10.4. Y PUNTO PELOTA!
Los datos? Como están fuera no hay problema. Al nuevo le monto el mismo volumen y santas pascuas.

Los contenedores los borramos de continuo. De continuo significa que incluso varias veces al dia en entornos de producción!

Cualquier imágen de contenedor viene bien documentada, indicando en qué carpetas el programa principal que corre dentro guarda los datos. Y lo que necesito es asegurarme que el contenido de esas carpetas se guarde en un almacenamiento externo al contenedor, para no perder los datos al borrar el contenedor.

Los contenedores NO SE MUEVEN ENTRE HOSTS... como si se hace con las máquinas virtuales.
En el mundo de los contenedores, MOVER UN CONTENEDOR ES:
- Borrar el contenedor del host antiguo
- Crear un contenedor nuevo en el host nuevo, con la misma imagen (o una actualizada) y montando el mismo volumen de datos que tenía el contenedor antiguo.

Nunca entramos a un contenedor a tocarle cosas...
JAMAS! No es la forma de trabajo. No trabajo con ellos, como trabajo con las máquinas virtuales.

Los fabricantes me dan ROADMAPS de actualización de sus imágenes de contenedor.

Y si es necesario, ellos mismos meten programas para migrar datos entre versiones de la imagen del contenedor.
Tienes un Mariadb 10.3 en un contenedor... 
Si quieres migrar, puedes hacerlo a la 10.4...
Pero quiero ir a la 11.4
Pues entonces tienes que:
- Subir a la ultima versión de la 10.X que haya,
- Subir ddespues a la 11.0 
- Y luego ya a la 11.4

ESTO ES UN EJEMPLO. Cada fabricante para sus imágenes me da sus roadmaps.

---

# Kubernetes

Me permite definir un entorno de producción basado en contenedores.


    Cluster:
        Host Maestro 1
            Kubernetes      < Quiero tener el nginx allí dentro, en v1.19
        Host Maestro 2        Quiero tener un nombre DNS que apunte a una VIPA que apunte al nginx  
            Kubernetes        Quiero tener entre 3 y 7 réplicas.
        Host Maestro 3        Cada una con 4 cores y 16 gbs de ram
            Kubernetes        Quiero que sea escalado cuando la CPU pase del 50%
        Host1                 o la RAM del 80%
            docker
        Host2                   OFFLINE
            docker
                ~~contenedor nginx v1.19~~
        HostN
            docker (o similar)
               contenedor nginx v1.19

Balanceo de carga :
    que antes apuntaba al contenedor del host 2
    Y ahora apunta al del hostN.
Y eso se lo come Kubernetes

Y Kubernetes, con esas instrucciones que le estoy dando. QUE SIGUEN SIENDO INSTRUCCIONES (pero en lenguaje declarativo) se encarga de:
- Montar en el entorno de producción lo que sea necesario
- Mantenerlo funcionando 24x7, 365 días al año, sin que yo tenga que preocuparme de nada.

Hay algo mágico con los contenedores.
El comando para arrancar el programa que viene dentro de un contenedor viene predefinido en la imagen del contenedor.
Da igual lo que tenga dentro, yo solo necesito ejectar:
    $ docker container start nombre-contenedor
Y para pararlo?
    $ docker container stop nombre-contenedor
Y para reiniciarlo?
    $ docker container restart nombre-contenedor
Y para eliminarlo?
    $ docker container rm nombre-contenedor
Y para crear un contenedor nuevo a partir de una imagen?
    $ docker container create --name nombre-contenedor imagen-contenedor
Y para ver los logs? 
    $ docker container logs nombre-contenedor

Todo está estandarizado!   <<<< ESTO ES BRUTAL !
Y como está estandarizado, en lugar de hacerlo yo, puedo contratar a un pendejo que lo haga por mi: KUBERNETES

A kubernetes se la trae al peiro lo que haya dentro. Haya lo que haya siempre se opera igual:
- docker container start LO QUE SEA
- docker container stop LO QUE SEA
- docker container restart LO QUE SEA
- docker container rm LO QUE SEA
- docker container create --name LO QUE SEA LO QUE SEA  
- docker container logs LO QUE SEA

Kubernetes me permite definirle cosas que quiero en mi entorno de producción.
Y de serie trae como unas 50 tipos de cosas:
- Namespace                 Entorno aislado dentro del cluster para una aplicación/cliente/entorno
                                bbdd-produccion-appX
- Deployment                Cluster de un tipo de programa
                            Donde todas las instancias del programa compartan los mismos volumenes de datos (si es que necesitan datos)
- StatefulSet               Cluster de un tipo de programa 
                            Donde cada instancia del programa tenga sus propios volumenes de datos independientes de las otras instancias del programa 
- DaemonSet                 Cluster de un tipo de programa
                            Eso si, el programa que esté en todos los nodos del cluster
                            (se usa para monitoreo, logging, etc.) 
- Service                   Entrada en DNS + IP de balanceo (VIPA) para acceder a un programa
- Ingress                   Regla de proxy inverso para acceder a un programa
- ConfigMap                 Variables de entorno para el programa o ficheros de configuración para el programa
- Secret                    Variables de entorno para el programa o ficheros de configuración para el programa, pero con cifrado
- PersistentVolume          Volumen en un almacenamiento externo al cluster.
- PersistentVolumeClaim     Petición de volumen que hace negocio.
- Job                       Programa que ejecuta en un momento dado, y termina (ETL, backup, etc.)
- CronJob                   La misma mierda, pero que se haga según un calendario.
- ...

Openshift, Tanzu... lo que me permiten es hacer un kubernetes más LISTO. Que sepa gestionar no solo esos 50 tipos de cosas, sino muchas más.
- Certificate               Certificados SSL (lo que implica a su ves una CA... programas que generen certificados...)

Esto es lo que dan las distribuciones de kubernetes de pago (RedHat, VMware, etc.) más tipos de cosas que puedo gestionar out-of-the-box.
Qué me da EKS (Elastic Kubernetes Service) de Amazon?
- Que si me quedo sin hosts en el cluster, me los añaden ellos automáticamente (tengo el concepto de AUTOESCALADO DE HOSTS)
Que me da el TANZU? (el de VMware)
- Que si me quedo sin hosts en el cluster, me los añaden ellos automáticamente (tengo el concepto de AUTOESCALADO DE HOSTS)
  En este caso, con máquinas Virtuales creadas dentro de los hosts esXI de VMware.
Que me da Karbon (el de Nutanix)
- Que si me quedo sin hosts en el cluster, me los añaden ellos automáticamente (tengo el concepto de AUTOESCALADO DE HOSTS)
  En este caso, con máquinas Virtuales creadas dentro de los hosts de Nutanix.
Que me da el Magnum (el de Openstack)
- Que si me quedo sin hosts en el cluster, me los añaden ellos automáticamente (tengo el concepto de AUTOESCALADO DE HOSTS)
  En este caso, con máquinas Virtuales creadas dentro de los hosts de Openstack.

Un nodo (host) de kubernetes es un host físico o virtual donde se ejecutan contenedores. Y habitualmente es virtual!
Y meto nodos a ese cluster... o a otro cluster .. al que haga falta en cada momento.

Y no me pasa como antaño:
Montaba la app1.. y la necesitaba en HA... Activo-Pasivo
Tenía 2 máquinas, una de ellas parada todo el santo día.

Montaba la app2.. y la necesitaba en HA... Activo-Activo
Tenía 4 máquinas... al 25% de uso cada una.

Montaba la app3.. y la necesitaba en HA... Activo-Pasivo
Tenía 2 máquinas, una de ellas parada todo el santo día.

Y ahora monto todo eso en un cluster... y las máquinas pasivas (las que no se usan) se reutilizan entre todas las apps.
Y si hacen falta más hosts... los pido al cloud.

Y mientras no los necesito, están disponibles para quien los necesite!

Y esto acaba de forma muy loca!

    HOST1   HOST2   HOST3   HOST4   HOST5   HOST6
    ---------------------------------------------
    Cluster de Kubernetes
    ---------------------------------------------
    Openstack! (los programas de openstack)
    Keystone, Nova, Neutron, cinder, etc. Ejecuándose como contenedores dentro del cluster de kubernetes
    ---------------------------------------------
    Pero a su vez, puedo usar esos programas para provisionar nuevos clusters de kubernetes, o nuevas máquinas virtuales, o nuevos volúmenes de almacenamiento, etc. dentro de la misma infra de hosts! LOCURA !

MariaDB en cluster: (galera)

    MariaDB 1   Dato1   Dato2
    MariaDB 2   Dato1   Dato3
    MariaDB 3   Dato2   Dato3

Esto me da HA (tengo al menos 2 réplicas, si una muere, tengo otra que me da el servicio) y escalabilidad (más discos donde escribir en paralelo).
Es una KK... He multiplicado por 3 la infra... y la mejora máxima de rendimiento teórica (que será mucho menos en la prática) es del 50%.. no del 300%


Aunque tenga un cluster, cada instancia tiene sus propios datos... y por ende, necesita su propio volumen en un dispositivo de almacenamiento externo al contenedor.
Si tengo una cabina de fibra, cada instancia apuntará a un LUN diferente de la cabina.

---

Antiguamente, Openstack se montaba a hierro!
Hoy en día Openstack se monta sobre Kubernetes, ejecutando sus programas en contenedores dentro de un cluster de Kubernetes.

RHOSO (RedHat OpenStack on OpenShift) es la distribución de Openstack de RedHat, que se monta sobre su distribución de Kubernetes (OpenShift).
Canonical: Sunbeam es la distribución de Openstack de Canonical, que se monta sobre su distribución de Kubernetes (MicroK8s).

Kolla-Ansible. Este trabajaba con contenedores.. pero sin kubernetes. YA pasó!


    HOST 1  Programas de Openstack   15% del host
    HOST 2  Programas de Openstack   15% del host
    HOST 3  Programas de Openstack   5% del host
    HOST 4
    HOST 5

    Qué pasa si el HOST 1 se muere? Poca cosa... tienes copias de los programas de Openstack en el host 2.. y alguno en el 3.
    Y si se muere también el host 2? ESTOY JODIDO!
    Me toca mover (instalar/arrancar) los programas de Openstack en el host 3 o 4 o 5

        Si lo tengo con kubernetes, es lo que kubernetes va a hacer por mi.


        192.168.2.0/16--------------- red de mi oficina -----> red de mi casa 192.168.0.0 /16----> internet
                               | 
                               |-192.168.2.105-HOST 1 -|
                               |-192.168.2.102-HOST 2 -| Red física de comunicacion interna
                               |-192.168.2.103-HOST 3 -|        Redes virtuales
                               |-192.168.2.106-HOST 4 -|
                               |-192.168.2.107-HOST 5 -|
                                                      10.10.0.0


Neutron no monta redes virtuales.                           > Tecnologia de virtualización : OpenVSwitch / OpenVLAN
Nova    no monta máquinas virtuales.                        > Tecnologia de virtualización : KVM
Cinder  no monta volúmenes de almacenamiento de bloques     > Tecnologia de virtualización de almacenamiento : CEPH
Manila  no monta volúmenes de almacenamiento de archivos    > Tecnologia de virtualización de almacenamiento de archivos : CEPH
Swift   no monta volúmenes de almacenamiento de objetos     > Tecnologia de virtualización de almacenamiento de objetos : CEPH

  Estos programas me dan la capa de AUTOSERVICIO                Estos programas me dan la capa de virtualización

Puedo cambiar/elegir la tecnología de virtualización que hay debajo?
Depende. Hay distros de Openstack que vienen muy abiertas, para que yo elija.
         Hay distros de Openstack que vienen muy opinionadas, y ya vienen preconfiguradas para una tecnología concreta de virtualización.
            RHOSO: OpenVLan, Redhat CEPH, KVM
            OpenStack-helm (el opensource). Este es más flexible... pero por defecto, yaa vienen configurado para OpenVSwitch, CEPH y KVM.
                                            Aunque puedo cambiar... y en lugar de usar OpenVSwitch, usar OpenVlan

Openstack, además de esos componentes, necesita de otras cosas:
- BBDD:
    Rhoso: MariaDB galera
    Canonical: MySQL Inno cluster
    OpenStack-helm: MariaDB (si lo quiero galera o no.. eso ya es mierda mía)
- Sistema de cache:
    Rhoso: Redis
    Canonical: Memcached
    OpenStack-helm: Memcached (si quiero Redis, eso ya es cosa mía)
- Sistema de mensajería:
    Rhoso: RabbitMQ
    Canonical: RabbitMQ
    OpenStack-helm: RabbitMQ 


De hecho, solo montar el CEPH que hay por debajo de todo! es una aventura en si misma!

---

# Keystone

- Gestión de usuarios, grupos, roles, etc.
- Registro de servicios del cloud y descubrimiento de servicios

## Gestión de usuarios / Autenticación

Cuando nos conectamos a un OpenStack, lo que vamos a a trabajar es contra la URL de uno de los servicios del cluster:
- keystone.midominio.com
- nova.midominio.com
- neutron.midominio.com
- cinder.midominio.com
- etc.

Cada componente es un MICROSERVICIO, con su propia URL, su propia API, etc.
En realidad nosotros no hablamos con esos microservicios directamente, lo hacemos a través de un cliente:
- Comando CLI (openstack client):       $ openstack ...
- UI Gráfica: (horizon):                http://horizon.midominio.com

Esos programas son los que hablan con los microservicios de Openstack, y lo hacen a través de la API REST de cada microservicio.

Pero.. cuales son las URLs de cada microservicio? Eso lo indica keystone.
Nosotros lo que vamos a configurar en los clientes (CLI, UI, etc.) es la URL de keystone.

Los clientes le pregunta a keystone qué servicios hay en el cluster, y keystone les devuelve UNA TABLA, con el nombre de cada servicio, el tipo de servicio, y la URL de ese servicio.

    | Servicio  | Tipo de servicio | URL del servicio                       |
    | Keystone  | Identity         | http://keystone.midominio.com:5000/v3  |
    | Nova      | Compute          | http://nova.midominio.com:8774/v2.1    |
    | Neutron   | Network          | http://neutron.midominio.com:9696      |
    | Cinder    | Block Storage    | http://cinder.midominio.com:8776/v3    |
    | Glance    | Image            | http://glance.midominio.com:9292/v2    |
    | etc.      | etc.             | etc                                    |


En nuestro caso, la URL de keystone es                  "https://keystone.ivanosuna.com/v3"
Por supuesto, yo podría hacer peticiones HTTP a esas URLs directamente.. pero es infumable!... para eso tengo los cliente.

No obstante, lo primero que Keystone va a hacer cuando queramos hablar con el, es preguntarnos quien hostias somos.
Autenticarnos. 
- Para ello, tendremos que dar: Usuario + Contraseña + SCOPE
  Ese SCOPE Es el ámbito en el que queremos trabajar:
    - Puede ser a nivel de todo el sistema (ADMIN)
    - Puede ser a nivel de un dominio
    - Puede ser a nivel de un proyecto


En keystone podemos definir DOMINIOS.
Un dominio es un ámbito de trabajo dentro del cloud. Los usuarios podrán hacer cosas dentro de ese dominio en base a los ROLES que tengan asignados dentro de ese dominio.
Dentro de un dominio, definimos PROYECTOS. Es un segundo nivel de trabajo.
El proyecto es un grupo lógico de recursos (redes, volumenes, máquinas virtuales, etc.) que se quieren gestionar como una unidad.
A un usuario también se le pueden dar ROLES a nivel de proyecto, para que pueda hacer cosas dentro de ese proyecto.


    USUARIOS                                                DOMINIOS

    GRUPOS             Asignación de roles                  PROYECTOS

                                ROLES

Hay un caso especial de asignación de roles... Asignarlos a nivel de SISTEMA (esto lo hacemos para los administradores)
    ROLE: ADMIN
    SCOPE: SYSTEM

En openstack, por defecto vienen una serie de ROLES predefinidos:
- admin         SYSTEM
- manager       DOMINIO
- member        DOMINIO, PROYECTO
- reader        DOMINIO, PROYECTO

Cuando me conecto al openstack, que ya hemos dicho que se hace através del keystone, 
Keystone genera un TOKEN de autenticación, que es un string alfanumérico que me identifica como usuario autenticado.
Previamente habrá validado mis credenciales (USUARIO + CONTRASEÑA)
En el Token, inyecta los ROLES que tengo asignados en base al SCOPE que he indicado en el momento de la autenticación.

Ejemplo:
- Soy "Iván", mi contraseña es "Manzana" y quiero conectarme a nivel de "sistema"
    Si Iván tiene esa contraseña, keystone genera un TOKEN que contenga los roles que Iván tenga asignados a nivel de sistema (en este caso, el rol admin)
- Soy "Iván", mi contraseña es "Manzana" y quiero conectarme a nivel del proyecto ESTRELLA del domino DE LA MUERTE
    Si Iván tiene esa contraseña, keystone genera un TOKEN que contenga los roles que Iván tenga asignados a nivel de la ESTRELLA DE LA MUERTE!

    Claro.. si despues con ese token quiero generar una Máquina Virtual en el proyecto ESTRELLA DE LA MUERTE podrá hacerlo...
    Pero si quiero generar una máquina virtual en el proyecto DESTRUCTOR IMPERIAL, no podré hacerlo, porque el token no tiene los roles necesarios para hacer eso.

Posteriormente cada vez que hagamos una petición a cualquier microservicio de Openstack, el cliente (CLI, UI, etc.) le pasará ese token al microservicio de turno... 
> Si lo quiero es crear una MV se lo pedirá a NOVA, y le pasará el token.
> Nova verificará que el token es correcto, que no ha caducado, y de él saca los roles que tiene Iván para el proyecto de turno

Quién decide en base a esos roles si Iván puede crear esa máquina virtual o no. AUTORIZACIÓN!?!?
- [√] Nova
- [x] Keystone

EIN??? SI... cada microservicio tiene sus propias reglas de autorización
Keystone autoriza... las operaciones sobre keystone.
Nova autoriza... las operaciones sobre nova.
Neutron autoriza... las operaciones sobre neutron.

Y esto tiene un impacto... y da lugar a algo RARO DE COJONES cuando trabajamos con Openstack!

Openstack tiene un conjunto de librerias que son comunes a todos los proyectos: "OSLO"
Entre otras cosas se encargan de: logging, autenticación, AUTORIZACION.

En Keystone puedo crearme ROLES NUEVOS... y asignar esos ROLES a personas/grupos a nivel de sistema, dopminio o proyecto.

Ahora, que pasa si una persona tiene un determinado ROLE: Qué permisos tiene la persona por tener ese ROL?
Eso no se define en keystone.

En muchas herramientas, los ROLES son grupos de permisos.
Puedo crear nuevos ROLES y les asigno los permisos que me interesa.

EN OPENSTACK NO FUNCIONA ASI!

En openstack, vía Keystone, puedo crear roles... y asignarlos... pero lo qué puede hacer alguien que tenga un determinado ROLE
se define en cada MICROSERVICIO.

Cómo se define aquello? No se define vía un CLI, ni con endpoints http...V
Va en ficheros estáticos de configuración en cada microservicio.

VER EJEMPLO DE KEYSTONE

La gestión de ROLES/Permisos e Openstack NO ES TRIVIAL! Y el hacer una configuración CUSTOM es un proyecto en si mismo! CON SU CLICLO DE VIDA!

En la mayor parte de los casos, pasamos! y tiro con lo que hay...Y meto, si necesito un cambio lo menos posible!

---

# Seguridad

Identificación          Decir quién soy
Autenticación           Comprobar que eres quien dices ser
Autorización            Sabiendo que eres quien dices ser, decidir qué puedes hacer y qué no puedes hacer

De esas de ahí, Keystone hace la parte de identificación, autenticación y autorización a medias!

---

# Dejar un entorno de trabajo estable para el curso

    - VisualStudio CODE?
    - python --version
      - METERLO EN PATH         CARPETA\python.ese
                                -------
                                Esta es la que hay que añadir al path  VARIABLES DE ENTORNO
