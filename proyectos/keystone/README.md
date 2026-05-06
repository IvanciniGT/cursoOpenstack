Queremos un script (sh, bat)
- Conectarme con scope de sistema, con mi usuario alumnoX
- Creamos un dominio llamado                                                dominio-alumnoX-cliente
- Crear un usuario en ese dominio                                           alumnoX-manager
- Le asignamos role manager al usuario alumnoX-manager en el dominio dominio-alumnoX-cliente
----
- Accedemos como usuario alumnoX-manager a nivel de ese dominio
- Creamos un proyecto llamado                                               proyecto-alumnoX-cliente
- Creamos un usuario para el dominio                                        alumnoX-operador
- Creamos un usuario para el dominio                                        alumnoX-monitorizacion
- Asigmamos rol de reader al usuario alumnoX-monitorizacion en el proyecto proyecto-alumnoX-cliente
- Asigmamos rol de member al usuario alumnoX-operador en el proyecto proyecto-alumnoX-cliente

----
- Probais a conectaros con esos usuarios con scope de proyecto.
- Y miro que puedo ver los datos del proyecto.
