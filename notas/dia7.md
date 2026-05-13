
Memoria, Volumenes... en cualquier cloud lo vereis expresado en:

GiB (Gibibytes) y no en GB (Gigabytes).
MiB (Mebibytes) y no en MB (Megabytes).
TiB (Tebibytes) y no en TB (Terabytes).

1 kB = 1000B
1MB = 1000kB = 1.000.000B
1GB = 1000MB = 1.000.000.000B
1TB = 1000GB = 1.000.000.000.000B


Hace 20 años que cambiaron esto.
Antiguamente, 1kB= 1024B, 1MB=1024kB, 1GB=1024MB, 1TB=1024GB.
Eso ya no... Por norma ISO.
La idea era estandarizar prefijos del Sistema Internacional.

Se creo una nueva unidad de medida: bybites... En base 2.

1KiB = 1024B
1KB  = 1000B

En cualquier cloud, cuando veais GiB, MiB, TiB... son nuestros GB, MB, TB de toda la vida. 
Es decir, 1GiB=1024MiB=1024*1024KiB=1024*1024*1024B.


El volumen pone que es de tipo rbd1.

Lo hemos creado con cinder... pero por detrás de cinder está CEPH.
Y CEPH ofrece 3 servicios diferentes: 
    RBD         Bloques 
    RGW         Objetos
    CephFS      Ficheros


---

# Volumenes en Cinder.

Admiten 2 operaciones que a veces son confusas entre si:
- Snapshot / Instantánea            Se guardan en el mismo almacenamiento que el volumen.
                                    - Rápidas
                                    - Volver a un estado anterior
                                    - Clonar un volumen a partir de una instantánea
                                    - Protegerme antes de una operación peligrosa
                                    Están en el mismo sistema de almacenamiento... si se jode... se jode el volumen y la instantánea. 
- Copia de seguridad / Backup       Se guardan en un almacenamiento diferente al del volumen.
                                    - Son más Lentas de ejecutar que las instantáneas
                                    - Nos permiten guardar a salvo información fiera del sistema de almacenamiento del volumen.
                                    - Les puedo configurar politicas de retención, etc...

# Instancia

- Snapshot: Es una imagen de la máquina virtual. Se guarda en el mismo almacenamiento que la máquina virtual.
            Al final se hace un snapshot del volumen raiz de la máquina virtual.
            Solo que ese volumen no se está guardando a través de cinder, sino a través de CEPH (o de FS del nodo)

Lo más serio es:
- Creo un volumen desde una imagen 
- Creo una máquina virtual a partir de ese volumen
- Y a ese volumen le hago un snapshot... que se guardará en el mismo almacenamiento que el volumen.
- Y a ese volumen le hago un backup... que se guardará en un almacenamiento diferente al del volumen.