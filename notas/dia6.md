Microstack (sobre kubernetes microK8s) - Canonical / Sobre ubuntu
16 Gbs y 8 cores.
---
DevStack. Más orientado a desarrollo. Hay cosas de administración que están cerradas.
---

# Neutron

Nos ofrece una serie de recursos que podemos crear a nuestro antojo:
- Networks          Conectividad (capa2)
- Subnets           Direccionamiento
- Routers           Comunicación entre subnets (internas o externas)
- Floating IPs      VIPAs accesibles desde el exterior
- Security Groups   Control de acceso y reglas de firewall
- Ports             Representan la conexión entre una vm y un switch en la network

Vamos a partir de algunas redes external / provider... salen de la instación (se dejan configuradas).

Red provider es una red de mi empresa pero fuera del cluster.
Red external es un tipo de red provider que se utiliza para conectar el cluster a redes externas, como Internet.

# El trabajo es simple.

1. Crear una red interna (tenant) 
2. Creamos subnets... las que necesitemos
3. Creamos routers y los conectamos a las subnets y las redes provider/external

Cuando vayamos creando máquinas virtuales:
4. Definimos puertos de conexión a la red
5. Si quiero exponer la vm al exterior, creamos floating IPs asociados a ella.
6. Configuro los security groups para controlar el acceso a la vm.

Neutron lo que aporta es la capa de automatización y autoservicio.
Pero realmente la gestión / creación de los recursos de red los hace ovs (o similar)

Sobre todo, cuando quiero que mis máquinas puedan tener conectividad al exterior, hay varias opciones:
- Floating IPs (NAT 1-1 a nivel de router). Es lo más limpio y sencillo
- Conectar una NIC Virtual al host que pinche a la red external. Pongo un puerto adicional al host y lo conecto a la red external.
- Directamente pasar a la MV la tarjeta física del host (passthrough). SR-IOV. La mejor latencia posible... perdemos toda la flixibilidad y funcionalidad que me aporta openstack. ME LO ESTOY SALTANDO.
  Esto no es para que lo haga un usuario del sistema. Debería restringirse a proyectos/vms donde claramente haya una necesidad de mejorar la latencia.

---

# IaC

Importantísimo: VERSIONADO DE LA INFRA!

v1.0.0 de la infra -> desplegar en automático.
v1.1.0 de la infra -> desplegar en automático.

Y genero una v1.2.0 de la infra, y la despliego en automático en un entorno de pruebas/desarrollo.
Y cuando esté guay la llevo a producción.

Le hago a la infra el mismo tratamiento que al software.

Trabajar así a priori puede parecer un tostón. Pero curiosamente es lo que exijo a los desarrolladores.
Porque yo no voy a trabajar así.

ESTO ES UN CAMBIO DE MENTALIDAD Y PARADIGMA ENORME. No os resistais. Abrazarlo.

> Pregunta. Qué tenemos desplegado ahora mismo en nuestra infra?

Cuando creamos uno de estos scripts... cuándo tenemos pensado que se va a ejecutar?
- Para el despliegue
- Para una actualización de versión
- NPI de cuando.

Porque usos - miles!

Estos scripts son IDEMPOTENTES! al menos si los creo bien. Y quiero crearlos bien...
Y la ventaja de eso es enorme.
Porque no solo crean una infra o la actualizan... la curan!
- Alguien ha metido la pata.. ha borrado algo que no debía. Un SO al actualizarse ha jodido la conexión de red....
- Hemos perdido una contraseña

- Mi script es idempotente... se la trae al peiro como esté la infra ahora.. me la deja niquelada.Ante cualquier problema/herida, el script me la cura. Me la arregla. Me la deja como debe ser.
- Y si está bien, no le hace nada.

Puedo tener un sistema de monitorización.. que si detecta un problema, lo primero es pasar el script de IaC para curar la herida. Y si no se cura, entonces ya me pongo a investigar.

Ese concepto de la idempotancia es fundamental. Es lo que hace que el IaC sea tan poderoso.


---

MODULARIZACION

No quiero montar un megascript de HEAT / TERRAFORM.
Prefiero montar 4 pequeños... que ya orquestaré.

Script para crear dominio, usuarios, proyectos, roles -> ID de proyecto

ID PROJECTO -> Script para redes, subnets, routers -> IDS SUBNETS / NETWORKS

ID SUBNETS / NETWORKS -> Script para máquinas virtuales

---

# Nova

Es el servicio que nos ofrece cómputo basado en máquinas virtuales.
Para hacer uso de él, necesitamos keystone, neutron, glance (imágenes), placement (decidir dónde se va a ejecutar la máquina virtual).
Aunque no es obligatorio.. hay otro servicio que acabamos usando siempre que es cinder (almacenamiento en bloque). Porque lo normal es que las máquinas virtuales tengan un disco duro persistente. Y ese disco duro virtual lo gestiona cinder.

No es obligatorio, puedo tener máquinas virtuales efímeras, sin almacenamiento persistente.

## Recursos que nos ofrece nova:

Hemos visto que en keystone hay ciertos recursos que podemos gestionar: dominios, proyectos, usuarios, roles.
Igual en neutron: redes, subnets, routers, floating IPs, security groups, ports.
Nova también me da una serie de recursos:
- Instancia = máquina virtual
- Keypair = par de claves para acceder a la máquina virtual = mentira
            es sólo la clave pública pre-registrada en openstack.
- Flavor = plantilla de hardware virtual (vCPU, RAM, disco duro)


# Keypair

Muchas de nuestras máquinas virtuales serán máquinas Linux. Y lo normal es que queramos acceder a ellas por ssh.
ssh me permite autenticarme mediante:
- Contraseña                Se considera más inseguro
- Clave pública/privada     Se considera más seguro

La contraseña, en algún momento ha de ser expuesta. La copio, la escribo en una terminal.
Cuando trabajo con un par de claves (pública/privada), la privada no es necesario que nunca haya sido expuesta.
Si la registro en openstack... pues ya un sitio donde la estoy exponiendo. Le quita la gracia.
Nunca la vamos a subir. NO SE PUEDE SUBIR LA CLAVE PRIVADA A OPENSTACK. SOLO LA PÚBLICA.
Lo que pasa es que esa pública va a ir asociada siempre a una privada. Y por eso nos hablan de keypair...
Que no nos lie el nombre... keypair = solo la clave pública de un par de claves pública/privada.

Openstack, cuando trabajo con una MV linux, inyecta esa clave publica que yo haya registrado en el momento de la creación de la máquina virtual. Y esa clave pública se inyecta en el fichero ~/.ssh/authorized_keys del usuario por defecto de la imagen que estoy usando.

De forma que luego, con la clave privada que tendré en mi entorno local, puedo acceder a la máquina virtual por ssh en cuanto es creada.

Además de ssh, también puedo acceder a la máquina virtual por consola, desde horizon. Esto es un rollo.

$ openstack keypair create \
    keypair-ivan \
    --private-key clave-privada-ivan.pem

# Flavor

Cuando creamos una máquina virtual, no le decimos a nova cuántas CPUs o cuánta RAM... Lo que elegimos es una talla de máquina: S, L, 2XL, etc.
Cada talla de máquina es lo que se llama un flavor. 
Yo puedo definir mis propios flavours... como administrador. Como usuario no es algo que haga.
Lo que hago es acogerme a esos flavors que ya hay definidos.

$ openstack flavor create \
   --ram 1024 \
   --disk 10 \
   --vcpus 1 \
   talla.mini

---

Fuera de nova, hay conceptos que van asociados a las máquinas virtuales.. No tienen sentido sin una VM.

# Neutron: Ports

Para conectar una VM a una red, lo que hago es crear un puerto (port) en esa red, y luego ese puerto lo conecto a la VM.

# Imágen de SO con la que la máquina virtual va a ser creada.

La imagen la gestiona glance, pero es un recurso que se asocia a la máquina virtual.

Visibilidad de las imágenes de glance:
- Private       Solo el proyecto propietario de la imagen puede usarla
- Shared        La imagen también se crea / sube asociada a un proyecto, 
                pero se puede compartir con otros proyectos. 
                El propietario de la imagen decide con qué proyectos la comparte.
                La compartición es EXPLICITA!
- Community     Cualquier puede usarla... desde cualquier proyecto.
                Lo que pasa es que no sale en los listados.
                Debo conocer el ID de la imagen para poder usarla. 
                No la voy a encontrar.
                Es igual a la típica opción de Compartir "Cualquier con el enlace"
- Public        Cualquier proyecto puede usarla, y además sale en los listados.

Normalmente la carga de imágenes es algo que también hace un administrador.. o un equipo centralizado.

Las imagenes se pueden proteger... eso evita que accidentalmente se borren o modifiquen.
Se le pueden asociar Tags... para facilitar las búsquedas.

Las puedo crear desde un archivo local, que subo al cloud, o también puedo crearla a partir de una URL.

Puedo subir imagenes de distintos tipos:
- ISO: imagen de CD/DVD. No es una imagen de sistema operativo, sino una imagen de instalación. Es como si metiera un CD de instalación en la máquina virtual, y luego arrancara desde ese CD para instalar el sistema operativo.
- QCOW2: es el formato de imagen más común en openstack. Es un formato de imagen de disco duro virtual. Es una imagen de sistema operativo ya instalada y lista para usar.
  En muchas de estas imágenes linux se suele usar un archivo clouds.yaml que es un archivo de configuración que se inyecta en la máquina virtual en el momento de su creación. Y ese archivo clouds.yaml contiene información de configuración para la máquina virtual, como por ejemplo la clave pública del keypair que quiero usar para acceder a la máquina virtual por ssh.

$ openstack image create \
  --disk-format qcow2 \      # Este es el formato de la imagen que estoy subiendo
  --container-format bare \  # Este es el formato del contenedor que va a contener la imagen. El formato bare es el formato más común para las imágenes de sistema operativo.
  --public \                 # Esta imagen va a ser pública, es decir, cualquier proyecto va a poder usarla.
  --property os_distro=cirros \ # Esta es una propiedad personalizada que estoy asociando a la imagen. Es una etiqueta que me va a permitir luego buscar la imagen por esa etiqueta.
  --property os_version=0.6.2 \ # Otra propiedad personalizada que estoy asociando a la imagen.
  "cirros-0.6.2-x86_64"  # Este es el nombre de la imagen que estoy creando.


$ openstack image create \
  --disk-format qcow2 \
  --container-format bare \
  --public \
  --property os_distro=cirros \
  --property os_version=0.6.2 \
  "cirros-0.6.2-x86_64"


$ openstack image import \
  --uri http://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img \
  --method web-download \
  "cirros-0.6.2-x86_64"

# Tendremos afinidades y antiafinidades entre máquinas virtuales.

Eso lo gestiona Placement, pero es algo que asociaremos a la máquina virtual.
Antiafinidades configuramos siempre. Simplementa en cuanto despliego algo en cluster, no quiero que 2 nodos del cluster caígan en el mismo host físico.

---

## Quien gestiona las VMs realmente

NO ES NOVA, nova trabaja por debajo con un hypervisor. 
QEMU + KVM es el hypervisor más común. Es el que se suele usar en openstack.

Pero esto es algo que ya hemos en otros componentes

    Neutron -> OVS
    Cinder, Manila, Swift -> Ceph
    Nova -> QEMU + KVM


---

openstack server create \
    --flavor talla.mini \
    --image cirros-0.6.2-x86_64 \
    --key-name keypair-ivan \
    --network red-alumno15 \
    --security-group 8d1eac36-e89c-463c-92be-9ff0b8f92f13  \
    vm-alumno15 --wait

    