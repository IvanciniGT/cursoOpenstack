# Entender como funciona Openstack
# Entender como usar Openstack -> Autoservicio
# Hacer prácticas: Horizon, openstack, heat (IaC)

---

# Placement -> NOVA

Placement es un servicio de Openstack que se encarga de planificar la ubicación de las máquinas virtuales en los nodos de computación.

Placement tiene en cuenta muchos factores a la hora de dedidir dónde ubicar una VM:
- Recursos disponibles (no comprometidos) en cada nodo de computación (CPU, RAM, etc...)
- Recursos que solicita la máquina virtual (CPU, RAM, etc...)

Eso es lo más básico... pero también tiene en cuenta otros factores como:
- Afinidad/Anti-Afinidad entre las VMs
- Regiones, zonas de disponibilidad, etc...
- Requisitos de hardware (GPU, etc...)

Para la gestión de todo esto, tenemos un montón de conceptos:
- Agregados de hosts
- Sabores / Flavors
- Grupos de servidores

OJO: Nosotros lo que queremos es influir en Placement, pero la decisión la toma él.

## Afinidad/Anti-Afinidad entre las VMs

Eso se hace mediante los grupos de servidores.

De hecho, un grupo de servidores, es simplemente un grupo de máquinas virtuales 
a las que se asocia una política de afinidad o anti-afinidad entre ellas.

Esa afinidad o anti-afinidad puede configurarse como rígida o suave.

Forma de trabajo:
- Creo un grupo de servidores con una política de afinidad o anti-afinidad (dura o blanda)
- Creo VMs y las voy metiendo en ese grupo de servidores.

En base a eso, cuando placement tenga que ubicar una VM, tendrá en cuenta esa política de afinidad o anti-afinidad entre las VMs del grupo de servidores.

Politicas duras son imperativas... si no se pueden cumplir, no se planifica la VM.
Politicas blandas son preferencias... si no se pueden respetar, se planifica la VM igual, rompiendo la política de afinidad o anti-afinidad.

> Tengo un cluster de servidore nginx para una app. 4 servidores.

Oye.. los quiero en máquinas diferentes... a ser posible. Si no hay hueco.. pues ponlas juntas... que el servicio hay que darlo!
Esto sería una politica de anti-afinidad moderadas.

En ocasiones quiero que ciertas VMs estén juntas. Afinidad.
Esto muchas veces, es para mejorar latencia en comunicaciones.
A veces quiero que se compartan recursos del HOST.

A nivel del cli de linea de comandos:

 $ openstack server group

Otras herramientas tienen rglas de afinidad/anti-afinidad más potentes que Placement... como por ejemplo Kubernetes.
En Opestack los grupos de servidores sobre los que se aplican las reglas son nominativos... no se pueden aplicar a todas las VMs que cumplan una característica.

Es simple en Openstack, pero suficiente para la mayor parte de los casos.

Cluster 2 nginx: 
    Nginx1: 25%
    Nginx2: 25%         Estoy tirando a la basura de continuo 3 Máquinas.
    Nginx3: 25%             La HA es cara!
    Nginx4: 25%

La idea de las antiafinidades no es REPARTIR CARGA DE TRABAJO ENTRE NODOS... sino que es para mejorar la disponibilidad de los servicios. Que si pierdo nodo, no pierdo el servicio (ni puntualmente)

## Agregados de hosts

Suena parecido a los grupos de servidores... pero no lo es.
    Los grupos de servidores son grupos de VMs.
    Los agregados de hosts   son grupos de hosts.

Son hosts que comparten una o varias características comunes... como por ejemplo, que tengan GPU, o que estén en una zona de disponibilidad concreta, que tengan una determinada arquitectura de CPU, etc...

Esto se usa en conjunto con los SABORES (Flavors) para influir en la planificación de las VMs.

A un sabor le puedo asociar una o varias características que se van a exigir a los hosts donde se planifiquen las VMs que usen ese sabor.
Incluso a un sabor le puedo prohibir ciertas características... por ejemplo, que no se planifiquen en hosts que tengan esas características.
 ^^^^
 CUTRE DE NARICES! y complejo a rabiar!

> MI CLUSTER DE COMPUTO: Tengo 3 nodos con GPU y tengo 3 nodos sin GPU.

Puedo crear un agregado de hosts con los 3 nodos con GPU y otro grupo de hosts con los 3 nodos sin GPU.

Cuando creo un agregado de hosts elijo:
- Un nombre
- Los hosts que quiero meter en ese agregado de hosts
- Y una o varias características (metadatos|etiquetas con valor) que quiero asociar a ese agregado de hosts.
  Una característica son 2 cosas:
    - Una etiqueta (clave)      gpu                 architectura
    - Un valor                  true                x86_64

Con el cliente de openstack es sencillo:

 $ openstack aggregate create AGREGADO_GPU
 $ openstack aggregate add host AGREGADO_GPU NODO1
 $ openstack aggregate add host AGREGADO_GPU NODO2
 $ openstack aggregate add host AGREGADO_GPU NODO3
 $ openstack aggregate set --property gpu=true AGREGADO_GPU

Ya tengo un grupo de hosts con GPU. y ahora qué?

Ahora entra el sabor (flavor).
Hasta ahora, los flavours habíamos visto que nos permitían:
- Configurar la cantidad de CPU, RAM, DISCO, etc... que queremos para nuestras VMs.
Eso es lo más básico.

La cosa es que también puedo asociarle metadatos al flavor.

Esos metadatos son etiquetas con valor... igual que las características de los agregados de hosts.

Cuando placement tenga que ubicar una VM, tendrá en cuenta los metadatos de los flavors para buscar un grupo de hosts con características compatibles.

Hay 2 tipos de requisitos que podemos asociar a un flavor:
- Trait:         Es un requisito de presencia. Es decir, que el host donde se planifique la VM tenga esa característica.

    openstack flavor set --property trait:gpu=true FLAVOR_GPU

- Resource       Es un requisito de cantidad de recursos. Es decir, que el host donde se planifique la VM tenga una cantidad de recursos INVENTARIABLES disponibles (no comprometidos) igual o superior a la cantidad de recursos que se le exige a ese flavor.

    openstack flavor set --property resources:VGPU=2 FLAVOR_GPU # Necesito una cantidad de recursos disponibles (no comprometidos) igual o superior a 2 VGPU.


Pregunta:
- Me resuelve esto el problema que de mi VM se vaya a montar en un HOST con GPU? SI
  Si no tengo disponibilidad de hosts con GPU, la VM no se podrá planificar. Esto es otro problema. Y ES ALGO DESEABLE!

Con esas cosas... lo que estoy diciendo es que quiero que mi VM vaya a un host con GPU.
Pero eso implica que pueda usar la GPU?
Que hace falta para que la VM pueda usar la GPU? Solo que el host tenga GPU? Inyectar a la VM... por PCI Passthrough? 
Y esto lo consigo con una etiquetita que me he inventado? NO

Esto se consigue con los pci passthrough... que es una cosa muy compleja de configurar y que no es nada trivial.

    $ openstack flavor set --property pci_passthrough:alias=ALIAS_PREREGSITRADO_EN_NOVA FLAVOR_GPU

    ALIAS_PREREGISTRADO_EN_NOVA, va en ficheros de configuración de nova... y es un alias que para configurarlo necesito datos concretos del hardware de los hosts... VendorId, ProductId... tener activada virtualización en el host...
    Esto hay que montarlo. No es trivial.. pero si lo necesi, hoy que montarlo.

    Sobre todo aquñi entender 2 cosas:
    - Que para cosas como gpu, tarjeta de red... Lo primero eso requiere configuración a nivel de host y de nova
    - En los sabores es donde se solicita que se haga un passthrough de esa gpu, tarjeta de red, etc... a la VM.

Esto no me resuelve otros problemas gordos:
- Que pueda usar la GPU
- Y que pasa con lo contrario? ESTE ES MUY JODIDO.. y el que está muy mal resuelto en Openstack.

> Tengo 3 nodos con GPU y 3 nodos sin GPU.

Voy a soltar una VM con sabor QUIERO_GPU... quiero que se planifique en un host con GPU.
Voy a soltar otra VM con otro sabor que no requiere GPU... quiero que se planifique en un host con GPU? NO
Son nodos muy especiales, que están ahí para las VMs que SI requieren GPU... usarlos para VMs que no requieren GPU es un desperdicio de recursos.

En herramientas como Kubernetes existen 2 conceptos:
- Afinidades a nivel de host: Es decir, que la VM se planifique en un host con GPU. <<< Esto es lo que pide un usuario
    Esto se define en kubernetes a nivel de PO (como si era a nivel de MV... en el flavor) 
- Tintes (taints) a nivel de host: Es decir, marco un host como que no es apto para planif
    Esto se define a nivel de host... no a nivel de Pod/VM (flavor). 
    Es decir, que el host se marca como que no es apto para planificar VMs que no requieran GPU.

Pero en Openstack no existe el concepto de tintes a nivel de host... y eso es un gran problema.

Todo se hace vía FLAVOR... y eso es un dolor de cabeza enorme al crear sabores... porque tengo que crear sabores para cada combinación de características que quiera exigir a los hosts donde se planifiquen las VMs.


    SABOR normal.medium:                2vCPU, 4GB RAM, 20GB DISCO
        extra: trait:gpu=forbidden                                  <<< Y esto es una jodienda!
    SABOR gpu.medium:                   2vCPU, 4GB RAM, 20GB DISCO
        extra: trait:gpu=required
    

    Continuamente al definir los sabores necesito pensar en las exclusiones.
    No pienso solo en positivos... sino también en negativos... y eso es un dolor de cabeza enorme.


> Hosts y agregados de hosts:

            HOST 1  
 SI_GPU     HOST 2      AGG_GPU
            HOST 3                  gpu=true

            HOST 4
 NO_GPU     HOST 5      AGG_NO_GPU
            HOST 6                  gpu=false

> Sabores

    | nombre                | vCPU | RAM | DISCO | GPU             | Mas de 1 característica |
    |-----------------------|------|-----|-------|-----------------|
    | normal.s              | 1    | 1GB | 10GB  | forbidden       |  forbidden        |
    | normal.m              | 2    | 4GB | 20GB  | forbidden       |. forbidden        |
    | normal.l              | 4    | 8GB | 40GB  | forbidden       |  forbidden        |
    | normal.xl             | 8    | 16GB| 80GB  | forbidden       |  forbidden        |
    | gpu.s                 | 1    | 1GB | 10GB  | required        |  forbidden        |
    | gpu.m                 | 2    | 4GB | 20GB  | required        |. forbidden        |
    | gpu.l                 | 4    | 8GB | 40GB  | required        |  forbidden        |
    | gpu.xl                | 8    | 16GB| 80GB  | required        |. forbidden        |
    | otra_combinacion.s    | 1    | 1GB | 10GB  | forbidden       |  required         |
    | otra_combinacion.m    | 2    | 4GB | 20GB  | forbidden       |. required         |
    | otra_combinacion.l    |  4   | 8GB | 40GB  | forbidden       |  required         |
    | otra_combinacion.xl   | 8    | 16GB| 80GB  | forbidden       |. required         |


---

Resumen:

Afinidades /antiafinidades entre VMs: Grupos de servidores, que contendrán VMs NOMINATIVAS. SIMPLE... poco potente.. pero simple.

Afinidad / Antiafinidad a HOSTS: Agregados de hosts (metadatos) + Flavors (metadatos). COMPLEJO...
                                    A veces basta con pedir que la máquina tenga una característica concreta.
                                    Además necesito excluir máquinas que tengan otras características que no necesito
                                    En ciertos casos, es necesario configruar cosas adicionales a niveld e host y de nova... como por ejemplo, para usar GPU, tarjetas de red, etc... necesito configurar el PCI Passthrough.

Los sabores no es algo que vaya a estar configurando en cada proyecto... ni que cada dominio vaya a tener sus propios sabores.
Es algo que necesito centralizar, por el impacto y configuración que se requiere.

Tendré gente al cargo de la gestión de los sabores. ES IMPORTANTE ESTE TEMA!

---

En estos días nos hemos centrado en entender cómo funciona Openstack y en crear recursos:
- Dominios
- Proyectos
- Usuarios / roles
- Redes
- Subnets
- Routers
- Grupos de seguridad
- Floating IPs
- Volúmenes Cinder
- VM Nova
- Keypairs
- Flavors
- Grupo de servidores
- Agregados de hosts
- Imágenes Glance

Ahora.. una vez que tengo los recursos creados, especialmente las VMs...hay que operarlas!
Las VMs van a requerir de cierta operación en el día a día.
Esa no está automatizada en Openstack. Distintos si tuvieramos contenedores (aquí si automatizamos la operación de los contenedores con Kubernetes... pero eso es otro tema)

Hay nos salen muchas operaciones que necesitamos conocer. Esas las hacemos: HORIZON o CLI (openstack).
NO LAS TENEMOS EN HEAT. Heat es para automatizar la creación de pilas (stacks) de recursos.


### 1 Listado de vms

    $ openstack server list

### 2 Detalles de una VM

    $ openstack server show NOMBRE_VM | ID_VM

    Esto me da mucha información:
    - Creación: imagen, flavor, red, volumenes, etc...
    - status

#### Estados de una VM:

Como consecuencia de las operaciones que vayamos haciendo, la VM va a ir cambiando de estado. Es importante conocer los estados de las VMs para entender qué operaciones puedo hacer sobre ellas en cada momento.
- ACTIVE: La VM está arrancada y funcionando.
- SHUTOFF: La VM está apagada. 
- SUSPENDED: La VM está suspendida. Es decir, que se ha guardado su estado en disco y se ha apagado. Es como si hibernara.

### 3 Ver los logs

    $ openstack server console log show NOMBRE_VM | ID_VM

### 4 Pedir la RUTA de acceso a la consola de la VM

    $ openstack server console url show NOMBRE_VM | ID_VM

### 5 Arrancar/Parar una VM

    $ openstack server start NOMBRE_VM | ID_VM
    $ openstack server stop NOMBRE_VM | ID_VM

    Apago la máquina VM. Eso si... sigue contando como recursos consumidos... desde el punto de vista de PLACEMENT.
    Lo que si libero es RAM.

#### 5.5 Reinicio

    $ openstack server reboot NOMBRE_VM | ID_VM
    $ openstack server reboot --soft NOMBRE_VM | ID_VM

    Esto es un reinicio suave... es decir, que se le manda la señal de reinicio a la máquina virtual... y la máquina virtual se reinicia de forma normal.
    Si por alguna razón, la máquina virtual no responde a esa señal de reinicio... puedo forzar el reinicio:

    $ openstack server reboot --hard NOMBRE_VM | ID_VM

    Esto es un reinicio duro... es decir, que se apaga la máquina virtual de forma forzada... y se vuelve a arrancar.
    Es como si desenchufara la máquina virtual y la volviera a enchufar.

### 6. Pausar una VM

    $ openstack server pause NOMBRE_VM | ID_VM
    $ openstack server unpause NOMBRE_VM | ID_VM

    Mantiene el estado de la VM... sin apagarla. Cuando digo el estado:
    - Lo que tiene cargado en RAM
    - Los procesos que tuviera en ejecución

    A partir del momento que la pauso, la máquina virtual deja de consumir CPU y deja de hacer trabajo.
    Pero sigue consumiendo RAM en el host.
    ES EL TIPICO SUSPENDER DE WINDOWS! 

### 7. Suspender una VM

    $ openstack server suspend NOMBRE_VM | ID_VM
    $ openstack server resume NOMBRE_VM | ID_VM

    Mantiene el estado de la VM... sin apagarla.
    Lo que pasa es que se hace un volcado de la RAM al disco... y se libera RAM.
    Esto es más lento que pausar... pero es más eficiente en cuanto a recursos del host.
    ES EL TIPICO HIBERNAR!

### 8. Aparcar una VM

    $ openstack server shelve NOMBRE_VM | ID_VM
    $ openstack server unshelve NOMBRE_VM | ID_VM

Esto apaga la VM... pero la quita del nodo de cómputo.. y la deja sin planificar.
Liberando todos los recursos desde el punto de vista de PLACEMENT.

Cuando hago esto, la VM queda en estado: SHELVED


### 9. Bloquear instancia

    $ openstack server lock NOMBRE_VM | ID_VM
    $ openstack server unlock NOMBRE_VM | ID_VM

Es una medida de precaución para evitar que se hagan operaciones peligrosas sobre la VM.

Cuando ya tengo una VM funcionando... y no quiero que nadie la pare, la reinicie, la suspenda, etc... puedo bloquearla.
AY cuando se vaya a hacer algo, la desbloqueo... hago la operación... y la vuelvo a bloquear.

### 10. Redimensionar una VM

    $ openstack server resize NOMBRE_VM | ID_VM --flavor NUEVO_FLAVOR

    Una vez solicitado, hay que:
    - Confirmarlo
        $ openstack server resize confirm NOMBRE_VM | ID_VM 
    - Rechazarlo
        $ openstack server resize revert NOMBRE_VM | ID_VM

### 11 Migrar una VM

    El hecho de redimensionarla, ya puede provocar una migración... porque el nuevo flavor puede requerir características que no tiene el host donde está planificada la VM... y entonces, placement se ve obligado a migrarla a otro host que si tenga esas características.

    $ openstack server migrate NOMBRE_VM | ID_VM

    Y esa migración hay que confirmarla o rechazarla... igual que el redimensionamiento.
    De hecho antiguamente el comando era el mismo:
        $ openstack server resize confirm NOMBRE_VM | ID_VM
        $ openstack server resize revert NOMBRE_VM | ID_VM
    Después se pasó al comando:
        $ openstack server migrate confirm NOMBRE_VM | ID_VM
        $ openstack server migrate revert NOMBRE_VM | ID_VM
    Y ahora: 
        $ openstack server migration confirm NOMBRE_VM | ID_VM    
        $ openstack server migration revert NOMBRE_VM | ID_VM

    Hay 2 formas de hacer una migracion
        - En frio: La máquina virtual se apaga, se migra, y se vuelve a arrancar en el nuevo host.
        - En caliente: La máquina virtual se migra sin apagarla. Es decir, que se va migrando mientras la máquina virtual sigue funcionando. 
          Pero ojo! 
          Este tipo de migración requiere que la vm esté guardada en un almacenamiento compartido entre los hosts... como por ejemplo, CEPH... y que el nuevo host tenga acceso a ese almacenamiento compartido.

            La migración en caliente implica: 
                - Que el almacenamiento esté disponible para ambos hosts
                - Copiar la RAM de la máquina virtual del host origen al host destino... 

            No hay indisponibilidad, pero si hay un retraso en la contestacióna peticiones (se hace una especie de pausado) para que la migración sea consistente.

    NOTAS: Con independencia de que la VM tenga o no un volumen atachado, creado via cinder! Siempre hay un volumen donde se despliega la imagen.
    Cuando no es creado via cinder, ese volumen se crea en función de la configuración de nova para los discos efimeros:
    - A nivel del host
    - En CEPH
    Si estoy trabajando a nivel de HOST, lo que hace nova es scp del disco efímero de la VM al nuevo host... y eso es una migración en frío.
    Y previo a eso para la vm. 


    Con el parametro --live-migration es con el que se fuerza a hacer una migración en caliente... 
    Tengo la opción de especificar host destino: --host DESTINO


### 12 Entrar en modo de rescate

    $ openstack server rescue NOMBRE_VM | ID_VM
    $ openstack server unrescue NOMBRE_VM | ID_VM

Cuando entramos en este modo (es un tipo de inicio de una VM) muchas operaciones básicas quedan anuladas: Pausar, suspender, shelve, etc... porque el objetivo de este modo es rescatar la VM de un estado en el que no arranca normalmente.
Si le he dejado la RED mal configurada... He jodido alfo del /etc/fstab

### 13 Asociar SG, FLOATING IP, VOLUMENES CINDER, PUERTOS DE RED,  etc... a una VM

    $ openstack server add security group NOMBRE_VM | ID_VM NOMBRE_SG
    $ openstack server remove security group NOMBRE_VM | ID_VM NOMBRE_SG

    $ openstack server add floating ip NOMBRE_VM | ID_VM FLOATING_IP
    $ openstack server remove floating ip NOMBRE_VM | ID_VM FLOATING_IP

    $ openstack server add volume NOMBRE_VM | ID_VM VOLUMEN_CINDER
    $ openstack server remove volume NOMBRE_VM | ID_VM VOLUMEN_CINDER

    $ openstack server add port NOMBRE_VM | ID_VM PUERTO_RED
    $ openstack server remove port NOMBRE_VM | ID_VM PUERTO_RED

    Todas estas operaciones no deberíamos hacerlas de la misma forma que las anteriores...
    Esto ya es cambio en la infra. Lo mismo sería con el resize!
    Esto debería ir por IaC (versionado..) deberiamos hacerlo con algo como HEAT

### 14 Reconstruir una VM

    $ openstack server rebuild NOMBRE_VM | ID_VM --image NUEVA_IMAGEN

    Esto es como si borrara la máquina virtual y la volviera a crear con la misma configuración pero con una imagen diferente.
    Es decir, que se mantiene el mismo flavor, la misma red, los mismos volúmenes atachados, etc... pero se cambia la imagen.
        - Revertir cambios que he hecho sobre la imagen base
        - Actualizar la imagen base de la máquina virtual <---- Lo más conveniente de nuevo sería hacerlo mediante HEAT (IaC)

### 15 SNAPSHOTS / BACKUPS


---

# Almacenamiento en Openstack.

Openstack es de las cosas más complejas que hay para instalar. Es una instalación muy compleja, con muchos matices.. muy personalziada.
Y que involucra muchos componentes.

El almacenamiento es especialmente delicado.

Se usa para muchas cosas.
Y por defecto, la mayor parte de las instalaciones de Openstack vienen preparadas y empujan hacia CEPH.

Eso no significa que sea siempre la mejor opción. Tampoco significa que sea la única opción en mi cluster.

CEPH está pensado/trabaja sobre nodos con arrays de HDD (ssd, nvmes...)
CEPH no está pensado para trabajar con una cabina de almacenamiento tradicional... aunque se puede hacer... pero no es lo ideal.

Muchas veces tenemos nodos de almacenamiento, independientes a los nodos de cómputo.
Otras veces tiramos a hacia infraestructura hiperconvergentes, donde tenemos nodos de computo + almacenamiento.

CINDER es uno de los servicios de Openstack que se encarga de gestionar el almacenamiento (en bloque).
MANILA es otro servicio de Openstack que se encarga de gestionar el almacenamiento en ficheros.
SWIFT es otro servicio de Openstack que se encarga de gestionar el almacenamiento en objetos.
NOVA también tiene su propio almacenamiento efímero para las máquinas virtuales.

Para cada uno de esos puedo configurar distintos backends de almacenamiento
Pero incluso, para uno de ellos puedo definir también muchos backends de almacenamiento, que den lugar a distintos tipos de volumenes.

CINDER
    - Volúmenes
      - Snapshots
    - Backups

Pero... por ejemplo puedo tener volumenes de distintos tipos:
- Rápidos, Normalitos, Lentos
- Encriptados, No encriptados
- Más o menos nivel de replicación

NO TODOS LOS BACKENDS DE ALMACENAMIENTO OFRECEN LAS MISMAS CARACTERÍSTICAS... ni siquiera las mismas características básicas... como por ejemplo, la posibilidad de hacer snapshots o backups.

Quizás tengo una cabina guay de almacenamiento llena hasta las trancas de discos solidos. Y eso me dará un almacenamiento de tipo GOLD.
Quizás tengo una cabina de almacenamiento tradicional, con discos duros mecánicos. Y eso me dará un almacenamiento de tipo BRONZE.
Quizás tengo un cluster de CEPH con discos duros mecánicos + ssd + nvme... y eso me dará un almacenamiento de tipo PLATA.
Quizás tengo un NAS, que ofrece NFS... con sus propios discos del tipo que sean dentro.

CINDER me permite definir distintos tipos de volumenes, que se corresponden con distintos backends de almacenamiento...Necesito instalarle drivers específicos para cada backend que tenga. Cabina EMC2, me vendrá con sus drivers. Una cabina HUAWEI me vendrá con sus drivers. CEPH me vendrá con sus drivers... y así con cada backend de almacenamiento que tenga.

Hace un snapshot de un volumen (o de una VM), es una operación interna del backend de almacenamiento.   

POR EJEMPLO: Cinder o NOVA le piden al backend de almacenamiento (CEPH): Hazme un snapshot de este volumen... y ceph (cabina) hace ese snapshot.
El backend que tenga, tensdrá su propia estrategia para hacer ese snapshot. Y en muchos casos no tiene ni que copiar archivos... ni datos.Muchas veces, cierra e volume(no sobreescribe bytes adicionales) y lo nuevo lo va escribiendo en otrro sitio... y el snapshot es instantáneo.

Un backup es otra cosa. En un backup SE COPIAN DATOS (Nova no permite hacer backups)
NO ES POSIBLE EN OPENSTACK HACER UNA COPIA DE SEGUDIDAD (UN BACKUP) de una VM.
Puedo hacer un snapshot... y eso hace snapshoot del volumen raiz.
Si tengo volumenes adicionales montados, de esos no se está haciendo snapshot... eso lo tendré que hacer de forma independiente.
Lo que habré hecho es un snapshot que incluta la referencia al volumen externo...

El backup copia datos... pero además con la posibilidad (Y NO SOLO POSIBILIDAD... sino que lo querré) de llevar los datos a otro sitio (BACKEND)

Para las VMs o sus volumenes adicionales, querré volumenes DECENTES! (que sean rápidos)
Para los backups quiero volúmenes rápidos. Quererlo SI puede que quiera.. pero €€€€ manda! 
No es necesario... Y tiraré de almacenamientos MUCHO MAS BARATOS (COLD)

Los backups implican movimiento de datos. De dónde a dónde? Esto va a depender de cada caso / cada instalación / cada empresa.
Un backup puede mover muchos datos. Si esos datos se mueven por una red... puedes flipar.
En muchos casos tiene sentido montar redes para esto, a las que les fijo politicas. QoS.

Desde luego no es anivel de redes de NEUTRON que se configura esto. Las redes del neutron son para VMs
Habrá que configurar interfaces dedicadas a e sto a nivel del host (SO)... y configurarlas en los servicios: CINDER


---


USUARIO -> TICKET -> DPTO VIRTUALIZACION -> VMWARE  (esXI)      -> Crear MV

USUARIO -> TICKET -> DPTO VIRTUALIZACION -> TICKET -> NOVA (OS)           -> LIBVIRT/QEMU/KVM    -> Crear MV

USUARIO -> TICKET -> NOVA (OS)           -> LIBVIRT/QEMU/KVM    -> Crear MV

Antes yo entraba a VMWare y daba de alta la VM
Ahora yo entro en Nova y pido una la VM

Antes yo (dpto almacenamiento) creaba un volumen en ???
Ahora yo (depto de almacenamiento) pido a cinder un volumen... y cinder ya irá al backend a crearlo... y me lo devuelve.

Un cluster, necesita administradores... que revisen que los backends están sanos

Debe haber un equipo central que:
- Instale todo
- Tome decisiones (backends)
- Flavors
- Imágenes
- Cree dominios / usuarios
- Y que revise todo y vaya haciendo evolutivos.
- Además podrían crear plantillas para estandarizar tareas.

Yo ahora entro en AWS -> Lanzar instancia! -> Y NO HAY NADIE EN AMAZON HACIENDO ESO EN UN VMWARE








---

Pila o Stack de recursos.

Pila es una estructura de datos... es como una lista como una cola.
Queue = COLA = estructura FIFO (First In First Out)
Stack = PILA = estructura LIFO (Last In First Out) <- Dependencias entre recursos.

    Dominio
        Proyecto
            Usuario
            Red
                Subnet
                    Router
                    Grupo de seguridad
            Keypair
            Flavor
            Imagen
            Volumenes Cinder
                VM Nova
