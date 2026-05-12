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