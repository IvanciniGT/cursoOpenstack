
# Neutron

Es el componente/servicio de Openstack encargado de la gestión de las redes.

## Qué tipos de recursos nos permite definir Neutron?

### Red - Network

Nos referimos a la infraestructura... a la parte FISICA! (que va estar virtualizada, pero represneta el cableado)

### Subred - Subnet

Nos referimos a la parte lógica... a la parte de software... a la configuración de esa red. Aquí es donde tendremos el direccionamiento IP, el gateway, etc.

### Puerto - Port

En Openstack el concepto de PUERTO no se refiere al PUERTO LOGICO, sino al PUERTO FISICO.
Pero realmente no representa un agujero en el switch o en un host.
Representa:
- El agujero en el switch
- + El agujero en la máquina que conecto a la red (tarjeta de red)
- + Cable que conecta ambos agujeros.
- + Configuraciones (a nivel de software.. las que hacemos en el switch y en la máquina para que se comuniquen entre sí)
      

- PUERTOS FISICOS. 
  Por ejemplo, un switch tiene puertos físicos!  RJ45
  Los HOSTS tienen puertos físicos!  RJ45
    Las tarjetas de red nos ofrecen puertos físicos.

- Los servicios (software) se comunicaan a través de puertos LOGICOS!
  80 -> http
  3306 -> mysql
  22 -> ssh

### Router

Comunicar unas redes con otras. Es un dispositivo que se encarga de enrutar el tráfico entre diferentes redes.

### Red externa

Aquí hablamos de nuevo de:
- Red física: la parte de cableado, switches, routers... etc.
- Red lógica: la parte de software, configuraciones, protocolos... etc.
Es una red que me permite conectarme con el mundo exterior (en concreto pensada para internet)

### Red provider

Es una red que me permite conectarme con el mundo exterior (en concreto NO pensada para internet)... pensada para conectar mis máquinas dentrop de Openstack con otros elementos de mi infraestructura que no están dentro de Openstack.


### Floating IP

Es una IP pública (acvcesible desde una red provider) que se asigna a una máquina virtual para que pueda ser accesible desde el exterior. Es una IP que "flota" entre diferentes máquinas virtuales, es decir, puede ser reasignada a diferentes máquinas según sea necesario.

### Security Group

Son reglas de firewall que se aplican a las máquinas virtuales para controlar el tráfico de red entrante y saliente. Permiten definir qué puertos están abiertos o cerrados, y qué tipo de tráfico está permitido o bloqueado.

## Esquema de trabajo típico:

1. Creo una red (network), que representa cableado, switches...
2. Creo una (o muchas) subred (subnet), que representa la configuración de esa red, con su direccionamiento IP, gateway, etc.
3. Creo puertos (ports) para conectar mis máquinas virtuales a esa red.
4. Creo un router o varios... para conectar esa red con otras redes (redes internas o externas)
5. Si necesito exponer alguna máquina virtual al exterior, le asigno una floating IP.
6. Configuro los security groups para controlar el tráfico que se vaya a producir.

## En neutron... nos pasa algo muy similar a Kubernetes.

Vamos a tener al menos una red física y 2 máquinas... como poco. Lo normal es tener más máquinas y más redes físicas...
Dentro de esas máquinas físicas, querremos crear máquinas virtuales... pero necesitamos conectar las máquinas virtuales entre si, con independencia del host en el que estén corriendo.


    +-------------------------------------- red de mi empresa (192.168.0.0/16)
    |
    ++- 192.168.1.100 -Máquina 1 de mi cluster de openstack
    |+---------- 10.10.0.107 - VM1
    ||
    ||
    ||
    ++- 192.168.1.101 -Máquina 2 de mi cluster de openstack
     +---------- 10.10.0.108 - VM2
     |
     |
     Es una red que se apoya sobre la red física... pero es una red a la que solo están conectados mis vms... es una red virtual que se apoya sobre la red física de mi empresa. 10.10.0.0/16

Qué usa Openstack para montar esa red virtual? OpenVswitch (OVS)
OVS está siempre por debajo.
Eso no significa que neutron hable directamente con OVS.
A veces, puedo montar encima de ovs, ovn (open virtual network) que es un proyecto que se apoya sobre OVS y me ofrece una capa de abstracción para gestionar mis redes virtuales de una forma más sencilla.

    Neutron --------> OVS (crear y operar con redes virtuales)      ** Nuestro entorno
            -> OVN -> OVS (crear y operar con redes virtuales)      ** RHOSO usa este segundo enfoque.


---
        +------------------------------------------------------------+----------------------------- Red en mi empresa (192.168.0.0/16)
        |                                                            |
        NIC 1                                                       NIC 2
    +-------------------------------+                       +-------------------------------+
    |  HOST 1 (con ovs)             |                       |  HOST 2 (con ovs)             |
    +-------------------------------+                       +-------------------------------+
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |               Switch para     |                       |               Switch para     |
    |       comunicar switches int  |                       |       comunicar switches int  |
    |       br-tun    |             |                       |       br-tun         |        |
    |                 |             |                       |                      |        |
    |  VM1 -------- Switch Interno  |                       |   VM3 -------- Switch Interno |
    |                 |   br-int    |                       |                  |   br-int   |
    |  VM2 -----------+             |                       |   VM4 -----------+            |
    |                               |                       |                               |
    +-------------------------------+                       +-------------------------------+


    En la NIC 1, quizás tengo una interfaz con la IP: 192.168.1.100
    En la NIC 2, quizás tengo una interfaz con la IP: 192.168.1.101


Cómo monto ahora una red virtual.... entre las 2 máquinas

    br-int: Es un switch virtual que me permite conectar mis máquinas virtuales entre sí, dentro de un mismo host.
    br-tun: Es un switch virtual que me permite conectar los switches internos de cada host entre sí, para que mis máquinas virtuales puedan comunicarse entre sí, aunque estén en hosts diferentes. Eso lo hace crando un tunel entre los hosts, que es como un cable virtual que conecta los switches internos de cada host entre sí, pero que va dentro (se aprovecha... encima..) de la red física de mi empresa.

Esto me da conectividad (capacidad de enviar impulsos eléctricos) entre mis máquinas virtuales... pero no me da comunicación (capacidad de enviar datos) entre mis máquinas virtuales... porque para eso necesito configurar la parte lógica de la red... necesito configurar el direccionamiento IP, el gateway, etc.

Necesito configurar ahora esos switches... y necesito configurar las interfaces de red de mis máquinas virtuales... para que puedan comunicarse entre sí a través de esa red virtual que he montado.

    Por cierto, cómo llamábamos a la configuración que hago en un agujero de un switch + un agujero de una máquina + un cable que los conecta ? en Openstack... PUERTO

    En esos switches virtuales, monto, defino, una RED LOGICA (Subnet)
    Y esa subnet operará sobre ciertos PUERTOS (que son los agujeros en los switches virtuales, y en las máquinas virtuales, y el cable que los conecta) para permitir la comunicación entre mis máquinas virtuales a través de esa red virtual.

    Ese es el trabajo que me permite open virtual switch.

---
El montar una red con openstack (NETWORK) es montar todo ese cableado... esos switches virtuales... esos tuneles... etc.

        +------------------------------------------------------------+----------------------------- Red en mi empresa (192.168.0.0/16)
        |                                                            |
        NIC 1                                                       NIC 2
    +-------------------------------+                       +-------------------------------+
    |  HOST 1 (con ovs)             |                       |  HOST 2 (con ovs)             |
    +-------------------------------+                       +-------------------------------+
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |               Switch para     |                       |               Switch para     |
    |       comunicar switches int  |                       |       comunicar switches int  |
    |       br-tun    |             |                       |       br-tun         |        |
    |                 |             |                       |                      |        |
    |               Switch Interno  |                       |                Switch Interno |
    |                    br-int     |                       |                      br-int   |
    |                               |                       |                               |
    |                               |                       |                               |
    +-------------------------------+                       +-------------------------------+

El montar una subnet, es crear configuraciones en esos switches virtuales.
Los puertos, son configurar en el switch, qué IP va a tener cada agujero del switch, y qué máquina virtual va a estar conectada a ese agujero del switch, etc.

Realmente, necesito un switch interno para cada red lógica? NO.
Con un solo cableado físico puedo montar varias redes lógicas... las que necesite.

Realmente ese despliegue, no se hace cuando monto una NETWORK.
El despliegue está hecho de antemano.... y lo reaprovecho.
Entonces, que es realmente una NETWORK? Básicamente una agrupación lógica de recursos (redes, puertos, reglas de red) que van a operar (o a definirse, o a usar) esa infraestructura física que he montado con OVS.

ovs create switch br-tun
ovs create switch br-int
ovs add-port br-tun tun0
ovs add-port br-tun tun1
ovs add-port br-int eth0
ovs add-port br-int eth1

Son un montón de comandos... Openstack puede invocarlos....
Pero hay un experto en esto: OpenVirtualNetwork

ovn create network red1 
 Y cuando le digo eso a OVN, lo que hace es ejecuatr:
    ovs create switch br-tun
    ovs create switch br-int
    ovs add-port br-tun tun0
    ovs add-port br-tun tun1
    ovs add-port br-int eth0
    ....
Esto es lo que prefiere hacer OpenStack.

En realidad Openstack (Neutron) no habla tampoco con OVS... Si no tengo un OVN, en su defecto lo que montamos es un programa que se llama OVS Agent... que hace más o menos lo mismo que OVN... aunque más simple.

HUMANO - Montame una red -> NEUTRON
                                ---> OPCION 1: Ejecutar 10 comandos en OVS
                                ---> OPCION 2: Ejecutar 1 comando en OVN y que OVN Ejecute los 10 comandos contra OVS


# Que es lo que hacemos al final los humanos contra openstack?

Pues depende... del cliente que uses:

## Si uso el cliente de linea de comandos: openstack
    openstack network create red1
    openstack subnet create --network red1 --subnet-range 10.10.0.0/24
    openstack port create --network red1 --fixed-ip ip-address=10.10.0.2
    openstack port create --network red1 --fixed-ip ip-address=10.10.0.3
    openstack server create --flavor m1.small --image cirros --nic port-id=port1 vm1
    openstack server create --flavor m1.small --image cirros --nic port-id=port2 vm2

## Si uso el cliente web: HORIZON:

Apretar botones y rellenar formularios = CACA!!!!

## Si uso una plantilla de HEAT:

    - Escribir un archivo de texto con formato YAML, donde defino los recursos que quiero crear (redes, subredes, puertos, máquinas virtuales, etc.)
    - Pedir a HEAT que aplique esa plantilla, y HEAT se encarga de crear todos esos recursos por mí.

---

# Comentarios / Observaciones.

No siempre usamos OpenVSwitch. Es lo más habitual, con diferencia. RHOSO lo trae de serie (envuelto en el OVN), pero en ocasiones hay vendor specific plugins, como el de Cisco, que se apoya sobre su propia tecnología de virtualización de redes (ACI) y no sobre OVS.

---

        +------------------------------------------------------------+----------------------------- Red en mi empresa (192.168.1.0/24)
        NIC 1                                                       NIC 2
    +-------------------------------+                       +-------------------------------+
    |  HOST 1 (con ovs)             |                       |  HOST 2 (con ovs)             |
    +-------------------------------+                       +-------------------------------+
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |                 |             |                       |                      |        |
    |               Switch para     |                       |               Switch para     |
    |       comunicar switches int  |                       |       comunicar switches int  |
    |       br-tun    |             |                       |       br-tun         |        |
    |                 |             |                       |                      |        |
    |  VM1 -------- Switch Interno  |                       |   VM3 -------- Switch Interno |
    |                 |   br-int    |                       |                  |   br-int   |
    |  VM2 -----------+             |                       |  VM4 ------------+            |
    |                 |             |                       |  | |             |            |
    |                Router         |                       |  | |          Router          |
    |                 |             |                       |  | |             |            |
    |                 |             |                       |  | |             |            | 
    |               Switch Interno2 |                       |  | +--------- Switch Interno2 |  Bocas a las que conectar cosas
    |                     |         |                       |  |                 |          |   En la red de fuera
    |       Switch para comunicar   |                       |  |    Switch para comunicar   |
    |         con redes externas    |                       |  |      con redes externas    |
    |             br-ext            |                       |  |          br-ext            |
    |              |                |                       |  |           |                |
    +-------------------------------+                       +-------------------------------+
        NIC 3                                                       NIC 4
        |                                                            |
        +---------------------------+-----------------------+--------+----------------------------- Otra red en mi empresa (192.168.2.0/24)
                                192.168.2.178           192.168.2.200
                                Servidor BBDD           Otra cosa externa a mi empresa

En ocasiones:
- Tenemos varias redes físicas... por ejemplo, redes con salida a internet... redes con servicios internos de la compañía.

Quiero que una de mis VMs (VM4) pueda conectarse a la Otra red de mi empresa. Qué necesito?
Mi máquina debe conectarse a la 192.168.2.178 (Servidor un BBDD)

Esos router me permiten conectar redes entre si... sean redes internas o externas.
Realmente habíamos dicho que los switches me podían gestionar varias redes lógicas.
El switch interno 2... su trabajo.. podría ser realizado sin problema por el switch interno 1.
Aunque en el dibujo lo hemos representado como si fueran distintos... no tiene sentido que lo sean... será el mismo switch.

Con los routers conseguimos que mis máquinas virtuales (conectadas a uan red A) puedan comunicarse con máquinas que estén en otras redes (red B, red externa, etc.)

Y qué pasa si quiero lo contrario?
Quiero que una máquina externa (por ejemplo la 192.168.2.200) pueda conectarse a mi máquina virtual (VM4).
Aquí hace falta un NAT (Network Address Translation). En este caso, NAT 1-1.
La máquina de fuera con quién va hablar realmente?  a nivel físico...
Con uno de los NICs de los hosts que estén conectados a esa red Otra red en mi empresa 
Y dentro de ese host, el router se encargará de traducir esa IP externa (192.168.2.233) a la IP interna de mi máquina virtual.
Esa regla es lo que llamamos una floating IP en Openstack.

Pregunta... se entera el VM4 de que le pueden atacar vía la IP 192.168.2.233? NO
Le llega tráfico... a través de su switch interno... pero no sabe que ese tráfico viene de la red externa.
Dicho de otra forma... no tiene conciencia de que esa IP externa apunta a él.

> Pregunta: ESA ES LA UNICA FORMA de conseguir que alguien desde fuera llegue a una VM de dentro?
  - Alternativa 1: Conectar directamente VM4 al switch interno 2... que es una extensión de la red Otra red en mi empresa...
                   En este caso, mi máquina tendría 2 NICs... una conectada al switch interno 1 (red virtual) con su IP en la red interna... y otra conectada al switch interno 2 (red física) con su IP en la red externa... y entonces podría comunicarse directamente con la máquina externa sin necesidad de NAT.
                   He quitado una pieza de la comunicación: El router y el NAT que tiene configurado.. Irá quizás más rápido la comunicación... menos gente por en medio.
                   Eso si... menos flexibilidad... y me cuesta más la configuración.
                   Antes lo único que necesitaba es un Floating IP, y a nivel de la VM4 que tenía que hacer? NADA
                   Ahora, para hacer esto, necesito configurar la segunda NIC en la VM4, con su IP. Más gestión.
                   Si el día de mañana la quiero reemplazar por otra máquina... en la nueva tendré que configurar también esa segunda NIC... etc.

  - Alternativa 2.

    Toda NIC admite virtualización interna... lo ofrecen las propias tarjetas de red. Tienen la capacidad de presentarse a la red como si fueran más de una NIC (con mac adress diferentes)... y pillar más de una IP en la red externa. Estamos hablando de SR-IOV (Single Root I/O Virtualization).

    Al hacer esto, el rendimiento mejora bastante (latencia de las comunicaciones)... quito muchas piezas de las que baía por medio.

    Nos gusta esto?
     - Ventajas             Mejora en la latencia de la comunicación.
     - Inconvenientes       Esto va cableado hasta la médula... FLEXIBILIDAD 0.
                            - La gestión se hace más compleja. MUCHO MAS COMPLEJA!
                              Son cambios dentro de la VM.
                            Quito gran parte del automatismo que nos ofrece Openstack...   

                            Por otro lado... pierdo los security groups... pierdo la capacidad de controlar el tráfico a través de reglas de firewall... pierdo la capacidad de aplicar políticas de red... etc.

    En casos donde necesitamos mínima latencia... por ejemplo BBDD... Sistemas de mensajería... etc... puede ser una buena opción.
    Pero tiene un coste! en mantanibilidad! GRANDE!

---

# Cuando se configura un Openstack... los que instalan el openstack.

Parte del trabajo de la instalación de Openstack es dejar configurado no solo la red "física interna" (los switches virtuales.. tuneles entre máquinas...). Una parte es dejar extensiones de las redes lógicas externas (redes provider y redes externas) a las que quiera que las VMs puedan conectarse en el futuro.

Eso son las redes provider. Redes lógicas que existen fuera del cluster, a las que quiero tener acceso desde dentro del cluster.
Openstack permite marcar algunas de estas redes provider como "external". Eso significa que esas tienen conexión a internet.

Las redes external son un tipo concreto de red provider... con conexión a internet.

---

# Donde se montan cada una de estas piezas.

Hemos empezado con una arequitectura de cluster muy sencilla: 2 máquinas!
En un cluster.. tendremos muchas más.


Habitualmente reservamos algunas de esas máquinas para COMPUTOS... es decir, para ejecutar las máquinas virtuales.
Con respecto a la red, que es lo que necesito yo en esas máquinas de cómputo?
Solo los br-int y br-tun... porque son los que me permiten conectar mis máquinas virtuales entre sí, y con el exterior.

Ni los routers ni los br-ext los necesito en esas máquinas de cómputo... pueden estarlo... en el caso de nuestro lab lo están.



    Nodo1
    Nodo2
    Nodo3

    Nodo4   - Nodo de cómputo + OVS (br-int, br-tun) + Router + br-ext
    Nodo5   - Nodo de cómputo + OVS (br-int, br-tun) + Router + br-ext

    En nuestro caso, nodo4 y nodo5 tienen doble tarjeta de red... aunque están conectadas ambas a la misma red física.

---
            +--------------------------------+----------------------+------------------------+   Red para comunicaciones internas
            |                                |                      |                        |
        Nodo cómputo 1                  Nodo cómputo 2          Nodo red 1                Nodo red 2
            |                                  |                      |                        |
            br-tun                          br-tun                 br-tun                     br-tun
              |                                |                      |                         |
            br-int                          br-int                 br-int                     br-int
          SWITCH LOCAL                     SWITCH LOCAL          SWITCH LOCAL               SWITCH LOCAL (el brtun me permite que los br-int al final operen como si fueran                             |                           |
          |    |                            |                      br-ext                      br-ext                       un único switch, pero distribuido)                                               |                      |
          VM1   VM2                         VM3                         interfaz de red concreta 
                                                                        Estas interfaces por debajo pueden tener 
                                                                        asociadas 5 NICs. Bonding de NICs para mejorar la disponibilidad y el rendimiento.

Tengo ciertas máquinas con 15 tarjetas de red de 25Gbs.



---

# Qué es una red?

> Física: Conjunto de elementos físicos que nos permiten conectar máquinas entre sí u otros elementos.
  Cables y conectores rj45... switches... routers... etc.

> Lógica: Software: protocolos, servicios... DHCP, DNS, etc.
  Drivers, configuraciones (switches, routers...) 

El conjunto de esas 2 cosas es lo que me permite la comunicación entre máquinas.


---

## Interfaces de red 

Toda máquina tiene varios interfaces de red. Es algo que gestiona? su sistema operativo.

Qué entendemos por una interfaz de red dentro de un sistema operativo?
    Es un canal de comunicación que me permite enviar y recibir datos a través de una red.

Esto es diferente del concepto de NIC (Network Interface Card) que es el hardware físico(o virtual) que se conecta a la red.

La relación entre interfaz y NIC no tiene por qué ser 1 a 1:
- Una NIC puede tener varias interfaces de red (por ejemplo, una tarjeta de red con varias VLANs)
- Una interfaz de red puede estar asociada a varias NICs (por ejemplo, si quiero HA o balanceo de carga) BOUNDING de NICs.

Qué interfaces encontramos SIEMPRE en cualquier máquina?
- Loopback (lo): Es una interfaz que nos conecta con una red virtual que solo existe dentro de la máquina.
  Esto me permite cxomunicar programas que estan dentro de mi máquina, sin la necesidad de tener una red física.
    Habitualmente trabaja en el 127.0.0.0/8
    Hay un fqdn que se resuelve a una IP en esa red (127.0.0.1) que es el localhost. Y Esa IP la tiene mi máquina asignada a la interfaz loopback.
- Ethernet (eth0, eth1, enp0s3, etc): Son las interfaces que me permiten conectarme a redes fuera de mi máquina (bien sean redes físicas o virtuales). Normalmente haciendo usao de 1 o varias NICs.

---

# Contenedores

docker image pull nginx:latest                                  # Descargaba una imagen de contenedor de un repo de un registry

docker container create --name nginx nginx:latest               # Creamos un contenedor basándonos en esa imagen

docker container start nginx                                    # Arrancamos el contenedor
                                                                # - Esto ejecuta el comando que venga predefinido en la imagen (en este caso, arrancar el servidor nginx: nginx -g 'daemon off;')
                                                                # - Pero lo ejecuta dentro de un contenedor...

curl http://localhost:80                                        # Esto no funcionaba... porque el contenedor tiene su propia IP

docker container inspect nginx                                  # Esto me devuelve la IP del contenedor

curl 172.17.0.2:80                                              # Esto sí funcionaba... porque esa es la IP del contenedor

La pregunta ahora es:... ¿De dónde leches es esa IP? ¿De qué red? ¿De qué interfacz de red?

Básicamente lo que hace docker (o cualquier gestor de contenedores) es crear una red virtual dentro de mi máquina (similar a la de loopback).
Por defecto, docker crea una en 172.17.0.0/16. Los contenedores los pincha a esa red virtual.. en ips consecutivas.
Reserva la 1: 172.17.0.1 para el host (para la máquina física) y luego va asignando a los contenedores a partir de la 2.
La 1 también es la que actúa de GATEWAY para los contenedores, es decir, es la que les permite comunicarse con el exterior (con otras redes) a través de la máquina física.

---

# Contenedores en Kubernetes

Cuando trabajamos en kubernetes, la clave es que kubernetes nos gestiona la HA (básico en cualquier entorno de producción).
Y eso implica tener al menos 2 máquinas.


    +-------------------------------------- red de mi empresa (192.168.0.0/16)
    |
    ++- 192.168.1.100 -Máquina 1
    |+---------- 10.10.0.107 - Contenedor1
    ||
    ||
    ||
    ++- 192.168.1.101 -Máquina 2
     +---------- 10.10.0.108 - Contenedor2
     |
     |
     Es una red que se apoya sobre la red física... pero es una red a la que solo están conectados mis contenedores... es una red virtual que se apoya sobre la red física de mi empresa. 10.10.0.0/16

        Cómo puedo hacer esa virtualización? cómo puedo virtualizar una red física:
            - Capa 2: con VLANs (tags)
            - Capa 3: con VXLANs (túneles)
            - Capa 4: con GRE (túneles)
        Ya veré como me interesa crear esa red virtual... el hecho es que necesito una red virtual. 
        Normalmente, cuanto más baja la capa, mejor rendimiento.

    Al montar un cluster de kubernetes, lo primero es crear una red overlay (red virtual) que me permita conectar mis contenedores entre sí, independientemente de la máquina física en la que estén ejecutándose. Esa red overlay trabaja sobre una red underlay (red física) que es la que me proporciona la conectividad entre mis máquinas físicas.


## Contenedor? 

Entorno aislado (entero de un sistema rodando un kernel Linux) donde ejecutar procesos.



    SWITCH 1 (10.10.0.0/16)
        |
        Router ----> External (internet)
        |
    SWITCH 2 (10.20.0.0/16)



    Realmente no hay 2 switches... solo hay 1 switch (virtual) que me permite montar varias redes lógicas con distinto direccionamiento IP... y luego un router que me permite conectar esas redes lógicas entre sí, y con el exterior.


---
Nosotros ya teníamos 2 máquinas en las que ya existe:
- 1 switch interno en cada una... con un huevo de bocas para conectar mis máquinas virtuales (VM1, VM2, VM3, VM4)
- 1 bridge de comuniación entre esos switches internos (br-tun) para que mis máquinas virtuales puedan comunicarse entre sí aunque estén en hosts diferentes.
- 1 brigde de comunicación a una red externa.

Eso sale de la instalación de openstack.

---
Hemos creado:
- openstack network create mi-red
  Esto ha generado una VXLAN (con un segmento propio) sobre la red física.... (es lo que gestionan los br-tun.) 
- openstack subnet create misubnet1 --network mi-red --subnet-range 10.10.0.0/16 --dns-nameserver 8.8.8.8 --gateway 10.10.0.1
  Esto ha configurado un direccionamiento (subnet) sobre la VXLAN que le he indicado... donde trabajaremos en un determinado CIDR... con un gateway... y con un servidor de DNS.. y con dhcp.

    ESTO SE HA CONFIGURADO EN EL SWITCH INTERNO (que ya existía)
- openstack router create mi-router
  Esto ha creado un router virtual... COMO SI FUERA EL MEDIAMARK y compro un router físico.
  que es un proceso que se ejecuta en el host... y que se encarga de enrutar el tráfico entre mis redes lógicas (redes virtuales) y con el exterior.
- Tiro cable del router a la red externa:
  openstack router set mi-router --external-gateway mi-red-externa
- Conectar en los puertos del router (RJ45) al switch internos (2 cables)
  openstack router add subnet mi-router misubnet1
  openstack router add subnet mi-router misubnet2

- Quién puede acceder a las BBDD? webservers
  Security group
  Solo desde la subnet-webservers se puede ir a la subnet-bbdd... y solo a través del puerto 3306 (mysql) o del 5432 (postgresql)
- Ya podemos ir configurando también PUERTOS
   Puerto para el webserver 1 (IP FIJA)
   Puerto para el webserver 2 (IP DINAMICA)
   Puerto para el servidor de BBDD (IP FIJA)
- Podemos también generar una VIPA (Floating IP) en la red de fuera (external), que asociemos a una de los webservers.