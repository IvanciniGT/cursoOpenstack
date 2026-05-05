
# Automatizar?

Crear una máquina (o cambiar el comportamiento de una que ya tengo) para que haga lo que antes hacía un humano... con sus manos.

> Puedo automatizar el lavado de la ropa : LAVADORA
> A la que incluso puedo ajusterle su comportamiento mediante PROGRAMAS de lavado (fría, delicadas...)

En nuestro mundo, la máquina es una COMPUTADORA... y por ende: AUTOMATIZAR = CREAR PROGRAMAS que hagan lo que antes hacía un humano... con sus manos.

Esto lo llevamos haciendo décadas: Scripts de bash, ps1.

# Qué es un cloud?

El conjunto de servicios (Relacionados con el mundo IT) que una empresa ofrece a través de internet, de forma:
- Automatizada (*1) -> Con autoservicio
- Bajo un modelo de pago por uso

Esos servicios pueden ser:
- IaaS (Infrastructure as a Service)
  - Cómputo:
     - Máquinas virtuales
     - Contenedores
     - Máquinas físicas
   - Almacenamiento
   - Red
- PaaS (Platform as a Service)     Implica no solo el HW, sino también el SW (no pensado para usuario final)
  - BBDD (opera sobre una infra)
  - Registro de repositorios de imágenes de contenedores (opera sobre una infra)
- SaaS (Software as a Service)     Pensado para usuario final

## *1: Automatizada?

Del lado del proveedor, las operaciones no son realizadas por personas humanas. Están automatizadas.

## *2: Autoservicio?

Yo, usuario/cliente puedo hacer una petición (manual o automática) y tengo los recursos en el momento sin necesidad de que ningun HUMANO del lado del proveedor tenga que intervenir.

    OJO! Esto es un cambio de PARADIGMA ENORME!

    Esto no me lo da el VSPHERE... ni ningún software de virtualización. NO ESTAN PENSADOS PARA AUTOSERVICIO
    
        Empresa                                     
            Equipo de desarrollo    --> petición al CAU --> Departamento de Virtualización --> VSphere -> Máquina Virtual

    El modelo cloud es un modelo orientado al autoservicio:
        
        Empresa                                     
            Equipo de desarrollo    --> petición al Cloud --> Máquina Virtual (en el momento)
            La gestión de la máquina es responsabilidad del equipo de desarrollo, no del departamento de virtualización.

    Es más... La tendencia es que el equipo de virtualización DESAPAREZCA.

    por qué? es lento, ineficiente, costoso, limitante.. No porque hagan mal trabajo.. Si no porque el modelo de trabajo es pastoso, burocrático, limitante.

        - No se está cambiando VMWARE por OPENSTACK. Esto no es lo que está ocurriendo en telefónica!
          Como si estuivieran cambiando VMWare por RedHat Virtualization, o por Proxmox, o por cualquier otro software de virtualización.
        - Lo que está ocurriendo es un cambio de MODELO DE TRABAJO.
        
    Pero.. esto no está ocurriendo en teléfonica exclusivamente. Es lo que está ocurriendo en el mundo de las TI en general.

        FASE 1: 
            Equipo de desarrollo    --> petición al CAU --> Departamento de Virtualización/Cloud --> Openstack -> Máquina Virtual
        FASE 2: 
            Equipo de desarrollo    --> petición --> Openstack -> Máquina Virtual           ESTE MODELO TAMBIEN HA FALLADO
        FASE 3: 
            Equipo de desarrollo    --> petición --> Openstack -> Máquina Virtual
                                                  ^
                                        Departamento de Excelencia
                                                        Devops
                                                        ???
                                                        INGENIERIA DE PLATAFORMA

## Entornos de producción

- HA: Alta disponibilidad.
   Es tratar de garantizar un determinado % de tiempo de servicio... sobre el total que el servicio debería estar disponible.
   Es tratar de garantizar el acceso a la información
   Normalmente lo medimos en 9s

                    ASUMO
    90%         36 días de inactividad al año               |   €
    99%         3.65 días de inactividad al año             |   €€
    99.9%       8.76 horas de inactividad al año            |   €€€€€€€€€€
    99.99%      52.56 minutos de inactividad al año         |   €€€€€€€€€€€€€€€€€€€€€€€€€€€€€
                                                            v

    Aplicamos / Usamos REDUNDANCIA.    

    De alguna forma, los 9s son una medida de la criticidad de un servicio.
    Y a más crítico, más REDUNDANCIA, y por ende, mucho más COSTE.

- Escalabilidad.
   Hacer un uso eficiente de los recursos, y ser capaz de adaptarse a las necesidades de cada momento.

   app1:   Departamental
    Día 1:        100 usuarios
    Día 100:      105 usuarios              NO NECESITO ESCALABILIDAD
    Día 1000:      98 usuarios

   app2:   Un servicio que va teniendo más clientes.
    Día 1:        100 usuarios
    Día 100:      1.000 usuarios            NECESITO ESCALABILIDAD: ESCALABILIDAD VERTICAL
    Día 1000:     10.000 usuarios                                   MAS MAQUINA!

   app3:   Esto es lo normal hoy en día: INTERNET
    Día n:        100 usuarios
    Día n+1:      1.000.000 usuarios
    Día n+2:      1.000 usuarios            NECESITO ESCALABILIDAD: ESCALABILIDAD HORIZONTAL
    Día n+3:      0 usuarios                                        MAS MAQUINAS! (O menos)
    Día n+4:      10.000.000 usuarios

    Soy la app de pedidos del telepi:
       00:00h -   0 estoy cerrado
       09:00h -   0 estoy abierto
       11:00h -   4 despistaos
       14:00h -   1000 pedidos
       16:00h -   100 pedidos
       18:00h -   50 pedidos
       20:30h -   Madrid - Barça : 1.000.000 pedidos
       23:00h -   0 estoy cerrado

    Quién me resuelve este problema? CLOUDs
        1. Me ofrecen un modelo de pago por uso
        2. Está automatizado de su lado.. No hay FERMIN (Comercial de dell.. no hay técnicos que vienen a montarme los servidores en el CPD)
           Yo hago una petición (manual o automática) y la empresa proveedora tiene programas que se encargan de gestionar esa petición, y de poner a mi disposición los recursos que necesito.
           Su trabajo lo tienen automatizado.

## IaC: Infraestructura como código.

Me temo que el concepto de IaC va mucho más allá que el hecho de que la infraestructura se defina mediante código (programa) o automatizar su creación.

IaC es un cambio de mentalidad, una nueva forma de entender la infraestructura.
La infractura no es que la vaya a crear con código, es que la voy A TRATAR COMO SI FUERA CODIGO.

- VERSIONAR la infraestructura, igual que se versiona un programa.

Cuando monto una infra, la monto para instalarle encima ciertos programas.
Y por programa, no me refiero al SO... esop es infra.
Ni me refiero a una BBDD, eso es INFRA!

Me refiero a una aplicación/sistema que manipula datos de negocio.

> Sistema de facturación.

Es una app web, desarrollada en JAVA (Weblogic, Tomcat, Websphere), que conecta con una BBDD Oracle y precisa de un KAFKA para la gestión de colas de mensajes...

    Y ese sistema/app tendrá una versión: v1.0.0

Qué infra necesito para ese sistema?      v1.0.0
    Al menos 2 Entornos con 4 cores y 16 Gbs de RAM para lo weblogic.. Y eso hoy... quizás mañana 4... y pasado 3.
    Al menos 3 Entornos con 4 cores y 16 Gbs de RAM para la BBDD Oracle RAC
    Al menos 3 máquinas con 2 cores y 8 gbs para el kafka
    Algo por delante apra hacer balanceo de carga
    Espacio en sistemas de almacenamiento para los logs, para los backups, para los datos...
    Conectividad entre todos estos elementos... Y politicas de seguridad
    Herramientas de monitorización, de gestión de la configuración, de gestión de los cambios...

El día de mañana, la app evoluciona Y ese sistema/app tendrá una versión: v2.0.0, metiendo un REDIS para cachear ciertas consultas a la BBDD Y entonces, necesito una v1.1.0 de mi infraestructura:
    Al menos 2 Entornos con 4 cores y 16 Gbs de RAM para lo weblogic.. Y eso hoy... quizás mañana 4... y pasado 3.
    Al menos 3 Entornos con 4 cores y 16 Gbs de RAM para la BBDD Oracle RAC
    Al menos 3 máquinas con 2 cores y 8 gbs para el kafka
    Al menos 3 máquinas con 2 cores y 8 gbs para el REDIS
    Algo por delante apra hacer balanceo de carga
    Espacio en sistemas de almacenamiento para los logs, para los backups, para los datos...
    Conectividad entre todos estos elementos... Y politicas de seguridad
    Herramientas de monitorización, de gestión de la configuración, de gestión de los cambios...

No es solo que esa infra la vaya a definir en archivos. Y que gracias a eso AUTOAMTICE su creación... es que esa infra la voy a tratar como si fuera código, lo primero CON CONTROL DE VERSIONES.

Y Esto cambia TODO!


### Me sale una pregunta!

Quién sabe las necesidades de infra del sistema? Sistemas o Desarrollo/Negocio
Desarrollo. Al menos en parte! Otra parte no...
    Por ejemplo la gestión de recursos (CPU/RAM) desarrollo tiene un estimado. SOLO MONITORIZACION tiene la información REAL.
    Aunque... NEGOCIO/DESARROLLO/La unidad que gestiona ese sistema (y que es quien paga!) es quien decide su presupuesto!
    Lo cierro a 16 cores... no tengo más pasta para este proyecto.

Y aquí entramos en algo divertido. COMO LLEVO/GESTIONO LOS COSTES de cada sistema?
    Si tengo un departamento de IT centralizado que hace trabajo para 40 sistemas...
    Cuánto cuesta mantener un sistema en producción? NPI
    Si claro.. si tuviera centralizado y organizado y analizado el control de costes por sistema:
    - Recursos
    - Horas de intervención de cada persona del departamento de IT (reuniones...)
    - Licencias...
    - ...
    Podría sacar la cuenta...
    Eso se hace en al realidad? NO... por imposibilidad. Y ES UN PROBLEMA desde el punto de vista de gestión!

Y es otro de los motivos de querer DESCENTRALIZAR. Control de costes REAL y EFECTIVO.

Todo ello sigue empuejando a que ese modelo CENTRALIZADO no es eficiente, ni sostenible, ni escalable... y que el modelo descentralizado FEDERADO es el camino a seguir.

Y esto encaja mejor con la cultura DEVOPS y con el concepto de metodologías ágiles.
Es mi sistema... yo me encargo de su desarrollo, de su despliegue, de su operación... y de su coste.
Voy más rápido, menos burocrático, más eficiente... y con un control real de costes.
Eso si, necesito AUTOMATIZAR TODO EL PROCESO... porque a nivel de unidad de negocio, no tengo tantos recursos / tiempo / dinero como para que todo eso se haga a manita!

Y esto es en la que nos hemos metido en los últimos años.... pero esto ha fracasado/está fracasando.
Suena bien... pero o ponemor cordura o acabo de nuevo con la ANARQUÍA... y eso no lo queremos!

Y entonces está guay que cada unidad de negocio gestione sus mierdas... pero todos trabajando según unas directrices comunes, con unos estandares comunes, con unas metodologías comunes.

Eso se debe seguir haciendo / definiendo / asegurando desde un departamento CENTRALIZADO. A esto estamos yendo:
- Ingeniería de plataforma
- CoE: Centro de Excelencia
- ...

## Versionado. Habitualmente para software y hoy en día para infra, usamos el esquema de versionado semántico: vX.Y.Z

                ¿Cuándo cambian a nivel software?                   ¿Cuándo cambian a nivel infra?  
    X: MAJOR    Cuando hago BREACKING CHAGES
                Cambios que no respetan la compatibilidad 
                    con versiones anteriores.
    Y: MINOR    Cuando se añade funcionalidad.                      Añado máquinas nuevas para otro programa (REDIS)
                O cuando una funcionalidad se marca como obsoleta.
    Z: PATCH    Cuando se arregla un bug.                           Por ejemplo si monto un patch de mi SO.
                                                                    Tenía una configuración de memoria mal.

La versión 1.1.0 de la infra, sirve para la v1.0.0 del programa/sistema que tenía? Claro.. pero no uso el redis. No pasa nada.. más allá que pierdo pasta.

Es decir, aunque hay relación entre la versión del sistema y la de la infra, cada una lleva su ciclo de vida independiente. La versión de la infra no tiene por qué cambiar cada vez que cambia la versión del sistema, y viceversa.

Quizás sale un minor nuevo o patch del sistema, y no necesito cambiar nada en la infra. 
O quizás sale un patch de la infra (subo RAM), y no necesito cambiar nada en el sistema.


## El paradigma de programación DECLARATIVO? Lenguajes DECLARATIVOS?

Hemos dicho que AUTOMATIZAR = PROGRAMAR (o al menos a configurar programas para que hagan lo que antes hacía un humano... con sus manos).

PROGRAMAS IMPLICA usar un LENGUAJE DE PROGRAMACION.

Terraform me ofrece un lenguaje de programación llamado: HCL (HashiCorp Configuration Language)
    Describo como quiero que se gestiones una infra.
Ansible me ofrece un lenguaje de programación basado en YAML (YAML Ain't Markup Language)
    Describo como quiero el planchado de una infra.
Kubernetes me ofrece un lenguaje de programación basado en YAML (YAML Ain't Markup Language)
    Describo como quiero que se cree el entorno de producción para mi sistema/app y cómo debe ser operado.

Y ya las herramientas se encargan.

Kubernetes <- archivos de manifiesto -> Crea y Opera el entorno de producción.
Terraform <- script  -> Gestiona la infraestructura.
Ansible <- playbook -> Plancha la infraestructura.

Lo que pasa es que... qué herramientas he usado tradicionalmente para automatizar el planchado de infra (crear usuarios, abrir puertos, montar volumenes nfs, configurar proxies, hacer una instalación)? Scrips de bash, ps1...
Y ahora que operamos con clouds.. con que herramientas hempezamos a operar los clouds?
    Cada cloud me daba su herramienta cliente:
        AWS -> AWS CLI
        Azure -> Azure CLI
        Google Cloud -> Google Cloud SDK
        Openstack -> Openstack Client

Lo que pasa es que esas herramientas / lenguajes usan paradigma IMPERATIVO!
Y NOS ASQUEAN! No por la herramienta en si.. sino por el paradigma IMPERATIVO, que es un ascazo!

## Paradigma IMPERATIVO vs DECLARATIVO

Paradigma de programación: Nombre hortera que los desarrolladores ponemos a la forma en la que sse usa un lenguaje para conseguir algo.
Pero.. es un concepto que realmente existe fuera del mundo de la programación... en los lenguajes naturales (ESPAÑOL, INGLÉS, CATALAN, EUSKERA...):

> Felipe IF(Si) hay algo que no sea una silla debajo de la ventana,         CONDICIONAL
  > QUITALO!                                                                IMPERATIVO
> Felipe IF no hay silla debajo de la ventana:                              CONDICIONAL
>   Felipe, IF not silla (silla == False)
    >   GOTO Ikea y compra silla    
> Felipe, pon una silla debajo de la ventana                                IMPERATIVO

Odiamos el lenguaje imperativo.. aunque estemos muy acostumbrados a él. Y lo odiamos por qué: Me hace olvidarme de mi objetivo para pasar a centrarme en lo que tengo que hacer para conseguir ese objetivo. Me hace centrarme en el CÓMO, y no en el QUÉ.

mkdir ventana -> make directory ventana                       IMPERATIVO
cd ventana -> change directory ventana                        IMPERATIVO

> Felipe, Debajo de la ventana tiene que haber una silla. Es tu responsabilidad.  NO ES IMPERATIVO. ES DECLARATIVO.
> 
No me centro en lo queFelipe debe hacer. Solo digo COMO SON LAS COSAS..
Realmente esty delegando en Felipe el conseguir lo que quiero. Su trabajo empieza ahora determinando el cómo!

Kubernetes nos ofrece un lenguaje de programación declarativo.
Ansible nos ofrece un lenguaje de programación declarativo.
Terraform nos ofrece un lenguaje de programación declarativo.
Spring (framework de java) nos ofrece un lenguaje de programación declarativo.
Angular (framework de JS) nos ofrece un lenguaje de programación declarativo.

El lenguaje declarativo tiene una gracia IMPLICITA: Ofrece per sé IDEMPOTENCIA!

## Idempotencia?

En el mundo IT lo entendemos como:
- Si ejecuto un programa, y después lo vuelvo a ejecutar, el resultado es el mismo que si lo hubiera ejecutado una sola vez.
- Da igual el estado inicial del sistema, después de ejecutar el programa siempre se llega al mismo estado final.

> Felipe IF(Si) hay algo que no sea una silla debajo de la ventana,         CONDICIONAL
  > QUITALO!                                                                IMPERATIVO
> Felipe IF no hay silla debajo de la ventana:                              CONDICIONAL
>   Felipe, IF not silla (silla == False)
    >   GOTO Ikea y compra silla    
> Felipe, pon una silla debajo de la ventana                                IMPERATIVO

Al meter todos estos condicionales, lo que estaba buscando es la idempotencia. 
Es decir, que si habia algo, o no, o habia sillas o no... al final el resultado es el mismo: HAY UNA SILLA DEBAJO DE LA VENTANA.

Intentaba hacer un programa que funcionase con independencia del estado inicial del sistema, y que siempre llegase al mismo estado final.

Pero el lenguaje declarativo ya me ofrece esa idempotencia de forma implícita. No tengo que hacer nada extra para conseguirla.

> Felipe, Debajo de la ventana tiene que haber una silla. Es tu responsabilidad.  NO ES IMPERATIVO. ES DECLARATIVO.

A mi ya me la trae al peiro si hay sillas, si no, si hay algo abajo previo o no.. Si hay ventana! o no!

En terraform, solo creo un fichero donde DECLARO la infraestructura.
Esto mismo lo tenemos en OpenStack: HEAT 
HEAT es un proyecto de los muchos que tiene OpenStack, que me ofrece un lenguaje de programación declarativo para definir la infraestructura que quiero montar en mi cloud desarrollado con OpenStack.
---

# Docker, Podma, Crio, Containerd

Son gestores de contenedores. Son herramientas que me permiten crear, gestionar, ejecutar contenedores.

# Qué es Kubernetes / Openshift?

Son herramientas que me ofrencen lenguajes para definir entornos de producción (basados en contenedores)... y operarlos automaticamente.

En kubernetes hablamos de los conceptos típicos de un entorno de producción:

- Balanceadores de carga                Service
- Proxies reversos                      IngressController 
                                         (A las reglas que pongo en un proxy reverso - VirtualHost del Apache) se les llama Ingress
- Reglas de firewall                    NetworkPolicy
- Políticas de escalado                 HorizontalPodAutoscaler
- Volumenes de almacenamiento           PersistentVolume, PersistentVolumeClaim
- Clusters de programas                 Deployment, StatefulSet, DaemonSet
- Configuración de programas            ConfigMap, Secret

Openshift es una distro de Kubernetes.. De las muchas distros que hay.
Tanzu Kubernetes Grid (VMware) es otra distro de Kubernetes.
Nutanix - Karbon es otra distro de Kubernetes.
AKS (Azure Kubernetes Service) es otra distro de Kubernetes.
EKS (Elastic Kubernetes Service) es otra distro de Kubernetes - AWS
GKS (Google Kubernetes Service) es otra distro de Kubernetes.

---

# La gran crisis del software?

Ocurre a finales de los años 60. Después de 2 décadas de desarrollo y despliegue de software llegamos a un momento de CAOS.
Cada persona creaba y operaba software.. como podría/quería/sabía. No había estandares, metodologías, departementos de IT CENTRALES.
Trabajábamos en reinos de taifas, cada uno a su bola, sin coordinación, sin estandares, sin metodologías... y el resultado caos.

CAOS ABSOLUTO. 

En los inicios de los 70, ocurren muchas cosas... pero básicamente centradas en un objetivo: ORDENAR EL CAOS:
- Metodologías de desarrollo de software
- Departamentos de IT centralizados
  Controlar las infras
  Estandarizar esas infras y su operación
  Procedimientos de trabajo RIGIDOS

Esto fué necesario... precisamente para domar el caos... pero... pasamos de la ANARQUÍA a un estado CENTRALIZADO: BUROCRACIA, PROCEDIMIENTOS RIGIDOS, LENTITUD, INEFICIENCIA, COSTOSIDAD...

Con el tiempo nos dimos cuenta que esto no era sostenible... pero tampoco queríamos volver a la anarquía... y entonces empezamos a buscar un punto intermedio: AGILIDAD, FLEXIBILIDAD, VELOCIDAD... pero sin perder el CONTROL.

Y empezamos a caminar hacia un modelo descentralizado pero FEDERADO.

# DEVOPS

Es parte de ese camino que estamos recorriendo.

También hay mucho humo.

Devops NO ES UN PERFIL PROFESIONAL. O al menos no lo era en sus origenes.

Devops es una cultura, un movimiento, una filosofía. Todo movimiento, cultura, filosofía defiende algo: AUTOMATIZACION.

Automatización de qué? De todo lo que pueda entre el DEV -> OPS.

                Esto es automatizable?                  HERRAMIENTAS
    PLAN            Poco
    CODE            Cada día más (IAs, frameworks)
    BUILD           (empaquetado -> ARTEFACTO)
                    Totalmente                          JAVA: MAVEN, GRADLE
                                                        JS:   NPM, YARN
                                                        .Net: Nuget, Dotnet, MSBuild
    TEST            
        Diseño/Desarrollo. Cada día más
        Ejecución   Totalmente                          JUnit, NUnit, Pytest, Selenium, Postman, JMeter, Gatling, SonarQube...

            Esas pruebas, dónde las ejecuto?
                - Las ejecuto en la máquina del desarrollador? NO... porque no me fio de esa máquina. ESTA MALEADA!
                - Las ejecuto en la máquina del tester?        NO... porque no me fio de esa máquina. ESTA MALEADA!
                - Las ejecuto en un entorno de pruebas/test/QA precreado al inicio del proyecto?
                  La realidad es que hoy en día tampoco.. esto hace 20 años si era una estrategia. Hoy en día NO. 
                  Hoy en día, con las metodologías ágilesm que entregamos el producto de forma incremental al cliente
                  cada mes, 2 meses hacemos entrega, que requiere previamente PRUEBAS INTENSAS, 
                  instalamos en el entorno de pruebas 30 veces... y después de 5 meses, el entorno de pruebas está tan mal que no me fío de él... ESTA MALEADO!
                - La tendencia hoy en día es a tener entornos de pruebas efímeros de usar y tirar.
                  Cuando hago pruebas, CREO ENTORNO, INSTALO PRODUCTO, EJECUTO PRUEBAS, GENERO INFORME, DESTRUYO ENTORNO.
                   Esto debe estar automatizado!        Docker, Kubernetes, Terraform, Ansible.
    -----> Automatizar hasta aquí: INTEGRACIÓN CONTINUA (CI)
        Tener CONTINUAMENTE en el entorno de INTEGRACION la última versión del códig desaarrollado, sometido a pruebas automatizadas, y con un informe de resultados de esas pruebas. PRODUCTO ES UN INFORME DE PRUEBAS.
    RELEASE       
    Poner en manos de mi cliente el producto.
        App Movil -> RELEASE (liberación) -> Google Play, Apple Store
        Producto de software -> RELEASE (liberación) -> Repositorio de artefactos (Nexus, Artifactory, Generar una imagen de contenedor), poner un enlace en mi web, enviar un correo a mis clientes con el enlace de descarga...
                Totalmente                          
    ------> Automatizar hasta aquí: ENTREGA CONTINUA (CD)
        Que mi cliente tenga CONTINUAMENTE la ultima versión probada de mi producto a su disposición.
    DEPLOY      Desde hace más años que maricastaña... BASH, PS1, Ansible
        En qué infra?
                Y cómo creo esa infra? Y aquí hay un nuevo cambio de mentalidad: INFRA AS CODE (IaC)
                Kubernetes, Terraform, CloudFormation,...
    ------> Automatizar hasta aquí: DESPLIEGUE CONTINUO (CD)
        Que mi cliente tenga CONTINUAMENTE la ultima versión probada de mi producto desplegada en su entorno de producción.
    OPERATE     Totalmente:
                Kubernetes, ...
    MONITOR     Totalmente:
                Prometheus, Grafana, ELK, Splunk...
    -----> Automatizar hasta aquí: He adoptado una cultura DEVOPS.


Una vez que tengo automatizadas cada una de estas tareas... puedo plantear un SEGUNDO NIVEL DE AUTOMATIZACION.
Puedo plantearme ahora automatizar la ORQUESTACION de todas estas tareas. 
    Es decir, que cuando yo haga un cambio en el código, se ejecute automáticamente todo el proceso: 
        BUILD -> TEST -> RELEASE -> DEPLOY -> OPERATE -> MONITOR.

Esto es lo que hacemos con Jenkins y herramientas similares: Gitlab CI, Azure Devops, CircleCI, TravisCI, TeamCity, Bamboo...
Montamos pipelines de integración continua y entrega/despiegue continuo (CI/CD) para automatizar la orquestación de todas estas tareas.

Estamos evolucionando todos los perfiles.
    Antes: Desarrollador compilaba lanmzando comandos a mano. Descargaba dependencias a mano.
           Ahora crea un programa con ayuda de maven para que eso se haga sin que el mueva un dedo (bueno... darle a play)
           Desarrollador v1 -> Desarrollador v2 (que sabe automatizar algunos de sus trabajos)
    Antes: Tester ejecutaba pruebas manualmente, y generaba informes a mano.
           Ahora: Tester crea scripts de prueba automatizados y genera informes automáticamente (Selenium, Karma, Cypress, JMeter, SonarQube...)
           Tester v1 -> Tester v2 (que sabe automatizar algunos de sus trabajos)
    Antes: Operador de sistemas hacía despliegues manuales, y monitorizaba a mano.
           Ahora: Operador de sistemas crea scripts de despliegue automatizados, y monitoriza automáticos 
                  (Esto ya se hacía en realidad... con bash, ps1... pero ahora con herramientas más potentes como Ansible, Terraform, Kubernetes...)
           Sysadmin v1 -> Sysadmin v2 (que sabe automatizar algunos de sus trabajos con herramientas modernitas)
  * Muchas emmpresas se empañan en llamar a este SysAdminV2 = DEVOPS
  Por la misma regla de 3, por qué no llamamos DEVOPS al TesterV2? O al DesarrolladorV2? RIDICULO! 

Si os fijaís, SI HACE FALTA UN NUEVO PERFIL.. que no existía ANTES en las empresas.
        Ahora hay que orquestar todo esto... y para eso hay que crear pipelines de CI/CD... 
        Necesito tios/tias que tengan visión 360. Que conocan todas esas herramienats. No para usarlas y configurarlas...
        Pero si que entiendan su papel, sepan hablar con ellas... llamarcas en el momento adecuado, capturar los datos de vuelta de cada una...
        Configurar pipelines en Jenkins, Gitlab CI, Azure Devops, CircleCI, TravisCI, TeamCity, Bamboo...

        Ese perfil es el que inicialmente se llamó DEVOPS (y tiene sentido ponerle un nombre.. y DEVOPS está bien)

        El problema es que ese trabajo, inicialmente fué asumido por gente de sistemas... y el nombre empezó a desvirtuarse.

## DEVSECOPS.

Simplemente es mentalizarnos de que en cada uno de los pasos de automatización que vamos a hacer en DEVOPS (pipelines de CI/CD), tenemos que tener en cuenta la seguridad.
- Llevar claves bien gestionadas: Generar claves adhoc para casa sistema, tenerlas bien guardaditas
- Cuando descargo dependencias de un sistema asegurarme que esas dependencias no tienen vulnerabilidades conocidas (SonarQube, Snyk...)
- Cuando hago un despliegue, asegurarme que abro solo los puertos necesarios, que no dejo contraseñas por defecto, que no dejo servicios innecesarios corriendo...

# Qué es Openstack?

Es una herramienta que me permite montar un cloud. 
Ese cloud podrá ser público o privado. Es decir, voy a ofrecer servicios a clientes internos o externos. Tu sabrás!
Vamos a usar infra on prem.

Con los grandes cloud públicos ha habido mucho humo!
Muchas empresas han movido su infra a clouds públicos -> PROBLEMAS DE COSTES !!!
- Ojo que la cuenta hay que echarla bien.
  No es cuánto me cuesta comprar 4 SDDs de 2 Tbs en la empresa y comparar eso con lo que me cuesta comprar 4 SDDs de 2 Tbs en el cloud público. No es eso. 
  El cloud me ofgrece la Administración de eso... Es decir.. al precio de comprarlos YO, he de sumar los costes de los empleados que se encargan de gestionar esa infra, el coste de la electricidad, el coste de la refrigeración, el coste del espacio físico, el coste de las licencias de software... Y todo eso lo tengo que comparar con el precio que me ofrece el cloud público por ese mismo servicio.
  Cuando comparo esto.. ya no sale TAN CARO!
  Pero.. dependendiendo del tipo de empresa, compensa o no!
    Empresa pequeña.. que escala a lo loco: CLOUD PUBLICO !
    Startup.. que no sabes cómo va a ir la cosa: CLOUD PUBLICO !
    Un banco, una telco, con un determinado nivel de operación muy estable: CLOUD PRIVADO te interesa fijo. Y otra parte quizás la dejas más variable en un cloud público. Y acabas con una estratergía de CLOUD HÍBRIDO.

Son un montón de proyectos Open Source.
    Dentro del cloud que montemos con Openstack, la pregunta será:
    Qué servicios quiero ofrecer? Yo monto mi cloud.. y decido que servicios quiero ofrecer a mis clientes (internos o externos).
        - Servicios de máquinas virtuales?
        - Servicios de contenedores?
        - Servicios de máquians físicas?
        - Servicios de almacenamiento en bloque?
        - Servicios de almacenamiento de objetos?
        - Servicios de almacenamiento de archivos?
        - Servicios de red?
        - Servicios de BBDD?
        - ???

Cada tipo de servicio en Openstack es un proyecto diferente.
Openstack me da piezas, como si fueran de un lego, para que yo monte mi cloud. Yo elijo qué piezas quiero usar, y cómo las quiero configurar.

## Qué es Opensource?

Qué puedo ver el código.

Opensources es GRATIS? No necesariamente.
RHEL es Opensource, pero no es gratis. Para usarlo tengo que pagar una suscripción con RedHat.

FreeWare: Es software que es gratis, Podré ver el código o no.
Free Software: Es software que es gratis, y además puedo ver el código, modificarlo, compartirlo... 

Openstack, al igual que GNU/Linux, o Kubernetes es Opensource.. y la base de los proyectos es Free Software.
Ahora... hay distribuciones de Openstack, como RHOSO (Redhat Openstack), CANONICAL (tiene un par de ellas) que no son gratis. Para usarla, tengo que pagar una suscripción a RedHat o a Canonical.

## Componentes de Openstack?

En el curso no vamos a ver todos los componentes de Openstack... solo veremos los que habéis pedido.

- Keystone:                 Azure: EntraID, AWS: IAM
  - Gestión de identidades, usuarios, grupos, roles, permisos... Es el servicio de autenticación y autorización de Openstack.
  - Registro de servicios.
- Cómputo:
  - Ironic: Gestión de máquinas físicas.                                            Azure: Máquinas, AWS: EC2
  - Nova:   Gestión de máquinas virtuales.              <<<< EN EL CURSO 
  - Zun:    Gestión de contenedores.                                                AWS: Elastic Container ???
- Almacenamiento:
  - Cinder: Almacenamiento en bloque (iscsi)            <<<< EN EL CURSO            AWS: EBS, Azure: Discos gestionados
  - Swift:  Almacenamiento de objetos (s3, minIo)       <<<< EN EL CURSO            AWS: S3,  Azure: Blob Storage
  - Manila: Almacenamiento de archivos (nfs)                                        AWS: EFS, Azure: Azure Files
  - Glance:  Registro de imágenes de máquinas virtuales. <<<< EN EL CURSO            AWS: AMI, Azure: Imágenes de máquina virtual
- Redes:
  - Neutron: Gestión de redes, subredes, routers, firewalls       <<<< EN EL CURSO  AWS: VPC, Azure: Virtual Network
  - Octavia: Gestión de balanceadores de carga
  - Designate: DNS as a Service
- Orquestación:
  - Heat: Orquestación de la infraestructura. Permite definir la infraestructura que quiero montar en mi cloud mediante código (archivos de texto). Es decir, es un servicio de Infraestructura como Código (IaC).    <<<<< EN EL CURSO

Hay muchos más:
- BBDD: Trove (postgresql, mysql, mongodb...)
- Mensajería: Zaqar (RabbitMQ, Kafka...)
- Kubernetes: Magnum   (equivalente al servicio EKS de AWS, AKS de Azure, GKS de Google Cloud...)
- ...

Nos quedan algunos conceptos generales aún por definir.         MARTES
    - Contenedores
    - Kubernetes
    - Instalaciones de Openstack
Después Entraremos a fondo con Keystone    (MIERCOLES / Jueves)                             | 3 formas de operar:
Después Entraremos a fondo con Almacenamiento (Cinder, Swift, Glance)    (Jueves/Lunes)     |   - openstack client (CLI)
Después Entraremos a fondo con Redes (Neutron)    (Lunes/Martes)                            |   - horizon (interfaz gráfica)
Después Entraremos a fondo con Nova                 (Miércoles)                             |   - plantillas de heat (IaC)
Jueves: Orquestación (Heat) + otros
    Terraform