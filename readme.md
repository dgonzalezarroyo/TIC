Autores: Aarón Barcenas y Ulyses Huete

Este script realiza varias tareas de configuración en el sistema y prepara la **duplicación de pantallas** para que funcione correctamente en equipos donde la pantalla del portátil y la del proyector o monitor externo tienen **resoluciones diferentes**.

El objetivo es que:

- La **pantalla del portátil sea siempre la principal**.
- Utilice **su resolución máxima disponible**.
- El **proyector o monitor externo se adapte automáticamente** a dicha resolución.
- Si el proyector no soporta esa resolución, el script selecciona **la resolución más alta compatible entre ambos dispositivos**.

---

# Funcionalidades del Script

## 1. Comprobación de permisos

El script verifica que se está ejecutando como **root**.

Esto es necesario porque realiza cambios en:

- Contraseñas de usuarios
- Archivos del sistema
- Configuraciones globales

Si no se ejecuta con privilegios de administrador, el script no continuará.

---

## 2. Cambio de contraseñas

El script actualiza automáticamente las contraseñas de los usuarios:

- `madrid`
- `profesor`

Este proceso se realiza **sin intervención manual**.

---

## 3. Configuración de GRUB

Se modifica la configuración de **GRUB** para reducir el tiempo de espera del menú de arranque.

```bash
GRUB_TIMEOUT=1
````

Esto permite **acelerar el inicio del sistema**.

---

# Sistema Inteligente de Duplicado de Pantalla

El script genera automáticamente el archivo:

```bash
/usr/local/bin/duplicar_pantalla.sh
```

Este script se encarga de gestionar la duplicación de pantallas de forma **automática e inteligente**.

## Funcionamiento

El script realiza las siguientes acciones:

1. Detecta la **pantalla interna del portátil** (normalmente `eDP` o `LVDS`).

2. Detecta la **pantalla externa** (proyector o monitor).

3. Obtiene todas las **resoluciones disponibles del portátil**, ordenadas de mayor a menor.

4. Obtiene todas las **resoluciones soportadas por el proyector o monitor externo**.

5. Busca la **resolución más alta compatible entre ambas pantallas**.

6. Si **no existe ninguna resolución común**:

   * Se mantiene la **resolución máxima del portátil**
   * El proyector se adapta mediante **escalado**.

7. Apaga temporalmente la pantalla externa para **evitar errores de configuración**.

8. Activa la pantalla del portátil con la **resolución seleccionada**.

9. Activa la pantalla externa **duplicando exactamente la imagen** del portátil usando:

```bash
--same-as
```

---

# Garantías del Sistema

Este sistema garantiza que:

* La **pantalla del portátil siempre es la principal**
* El **proyector o monitor externo se adapta automáticamente**
* **La resolución del portátil nunca se reduce**
* Si el proyector no soporta la resolución máxima, se usa **la mejor resolución común**
* La **imagen se duplica correctamente** en ambas pantallas
* **No se invierte el orden de pantallas**
* **No se producen cambios inesperados de resolución**

---

# Inicio Automático (Autostart)

Se crea un archivo `.desktop` para que el sistema de duplicado se ejecute **automáticamente al iniciar sesión**.

Este archivo se copia en:

* `/etc/skel` → para **usuarios nuevos**
* Los **directorios de todos los usuarios existentes**

De esta forma, la configuración se aplica **independientemente del usuario que inicie sesión**.

---

# Integración con Migasfree

Si **Migasfree** está instalado:

* Se actualiza el **agente**
* Se asigna la **etiqueta correspondiente al equipo**

Si **no está instalado**, el script **omite esta parte automáticamente**.

---

# Autodestrucción del Script

Una vez completado todo el proceso, el script:

* **Se elimina a sí mismo del sistema**

Esto evita:

* Dejar archivos innecesarios
* Ejecuciones accidentales posteriores
* Restos de instalación

---

# Resumen

Este script automatiza completamente:

* Configuración inicial del sistema
* Optimización del arranque
* Gestión inteligente de duplicado de pantalla
* Integración con sistemas de gestión
* Configuración automática para todos los usuarios

Todo el proceso se ejecuta **sin intervención manual** y queda **listo tras una única ejecución**.
