# 🐘 Tutorial: Configuración de PostgreSQL y pgAdmin 4 en GitHub Codespaces

¡Bienvenido! En esta guía aprenderás a instalar, configurar y arrancar un entorno completo de base de datos relacional utilizando **PostgreSQL** y la interfaz web **pgAdmin 4**, todo corriendo de forma online dentro de tu entorno de desarrollo en la nube (GitHub Codespaces).

> ⚠️ **Nota importante:** Este entorno está diseñado para fines educativos. Al ser un contenedor virtual temporal, los datos que crees en la base de datos se borrarán cuando el Codespace se destruya o se reinicie. ¡Es una excelente oportunidad para practicar comandos sin miedo a romper nada!

---

## 🛠️ Paso 1: Instalar PostgreSQL

Lo primero que haremos será actualizar el gestor de paquetes de Linux e instalar el servidor de bases de datos.

1. Abre una **Terminal** en tu Codespace.
2. Ejecuta el siguiente comando para actualizar la lista de paquetes e instalar PostgreSQL:
   ```bash
   sudo apt update && sudo apt install postgresql -y

```

---

## 🔑 Paso 2: Iniciar el Servicio y Configurar la Contraseña

Por defecto, PostgreSQL se instala pero no se inicia automáticamente en entornos de Codespaces. Además, el usuario administrador (`postgres`) viene sin una contraseña asignada.

1. **Enciende el servidor de bases de datos** ejecutando:
```bash
sudo service postgresql start

```


*(Si quieres verificar que encendió correctamente, puedes usar `sudo service postgresql status`)*.
2. **Asigna una contraseña al usuario administrador.** Para evitar que el sistema te pida claves de administrador de Linux, utilizaremos el comando directo de la siguiente manera (usaremos la contraseña fácil `1234` para este laboratorio):
```bash
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '1234';"

```



---

## 🌐 Paso 3: Instalar pgAdmin 4 (Versión Web)

Dado que estamos trabajando completamente en la nube, instalaremos la versión web de pgAdmin para poder gestionarlo todo desde el navegador.

1. **Agrega la llave de seguridad del repositorio oficial de pgAdmin:**
```bash
curl -fsS [https://www.pgadmin.org/static/packages_pgadmin_org.pub](https://www.pgadmin.org/static/packages_pgadmin_org.pub) | sudo gpg --dearmor -o /usr/share/keyrings/pgadmin-archive-keyring.gpg

```


2. **Añade el repositorio oficial a las fuentes del sistema:**
```bash
echo "deb [signed-by=/usr/share/keyrings/pgadmin-archive-keyring.gpg] [https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$)(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list

```


3. **Actualiza e instala la versión web de pgAdmin:**
```bash
sudo apt update && sudo apt install pgadmin4-web -y

```



---

## 📝 Paso 4: Configurar tu Cuenta de pgAdmin 4

Las versiones actuales de pgAdmin manejan su propio entorno aislado de Python. Para inicializar la base de datos de usuarios, usaremos su comando específico:

1. Ejecuta el asistente de inicialización:
```bash
sudo /usr/pgadmin4/venv/bin/python3 /usr/pgadmin4/web/setup.py setup-db

```


2. La terminal te solicitará los siguientes datos interactivamente:
* **Email address:** Introduce un correo electrónico (puede ser ficticio, por ejemplo: `alumno@clase.com`). Este será tu usuario de inicio de sesión.
* **Password:** Ingresa una contraseña para tu cuenta web de pgAdmin y luego repítela para confirmar.



---

## 🚀 Paso 5: Arrancar el Servidor Web de pgAdmin y Exponer el Puerto

Para poder ver la interfaz gráfica en nuestro navegador, debemos encender el servicio web interno de pgAdmin.

1. **Ejecuta el servidor web** con el siguiente comando:
```bash
sudo /usr/pgadmin4/venv/bin/python3 /usr/pgadmin4/web/pgAdmin4.py

```


*Nota: Verás que la terminal se queda ejecutando este proceso en primer plano y "escuchando". No la cierres.*
2. **Hacer público el puerto en Codespaces (CRUCIAL):**
* En la parte inferior de VS Code, ve a la pestaña **Ports** (Puertos).
* Busca el puerto que se ha abierto automáticamente (suele ser el `5050` o el `80`).
* Haz **clic derecho** sobre ese puerto en la lista y selecciona **Port Visibility** -> **Public**.
* *¿Por qué hacemos esto?* Si el puerto se mantiene privado, los sistemas de seguridad de GitHub bloquearán las cookies y no te dejarán iniciar sesión en pgAdmin.


3. Haz clic en el icono del **globo terráqueo / abrir en el navegador** que aparece al lado del puerto modificado. ¡Se abrirá una nueva pestaña con pgAdmin 4!

---

## 🔌 Paso 6: Conectarse al Servidor de PostgreSQL desde pgAdmin

Una vez dentro de la web de pgAdmin, inicia sesión con el **Email** y **Contraseña** que creaste en el **Paso 4**. Ahora vincularemos la interfaz con la base de datos que instalamos al principio:

1. Haz clic en **Add New Server** (Añadir nuevo servidor).
2. En la pestaña **General**:
* En el campo **Name**, escribe un nombre identificativo para tu clase (por ejemplo: `Servidor Local`).


3. Cambia a la pestaña **Connection** (Conexión) y rellena los campos exactamente así:
* **Host name/address:** `127.0.0.1` *(apunta a la propia máquina del Codespace)*
* **Port:** `5432` *(puerto por defecto de Postgres)*
* **Maintenance database:** `postgres`
* **Username:** `postgres` *(es el superusuario que creamos en el paso 2, asegúrate de cambiar el que venga por defecto)*
* **Password:** `1234` *(o la contraseña que elegiste en el paso 2)*
* Activa la casilla **Save password?** para mayor comodidad.


4. Haz clic en **Save** (Guardar).

¡Listo! Verás cómo se despliega el árbol de servidores a la izquierda. Ya puedes crear tablas, ejecutar consultas SQL y gestionar tu base de datos de manera 100% interactiva.