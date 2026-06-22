# Bug: pgAdmin se queda en blanco tras el login en Codespaces (versión web)

> **Estado: RESUELTO** — solución final: **modo escritorio** (`SERVER_MODE=False`) en
> `.devcontainer/docker-compose.yml`. Los intentos previos con cookies **no** funcionaron;
> se documentan abajo para no repetirlos.

## Síntoma

Al abrir el Codespace **desde el navegador** (VS Code web), pgAdmin se forwardea en el
puerto `5050` y se ve correctamente la **pantalla de login**. Tras introducir las
credenciales y pulsar *Login*:

- La página se queda **completamente en blanco**.
- La interfaz de pgAdmin (árbol de servidores, menús, etc.) **no carga**.

Este problema **no ocurre** cuando se usa **VS Code de escritorio** (instalado en la
máquina host) abriendo el mismo Codespace: ahí pgAdmin carga con normalidad después del
login.

## Causa raíz

El proxy de GitHub (`*.app.github.dev`) **termina el TLS** y reenvía a pgAdmin por HTTP
plano. pgAdmin (Flask) ve la petición como **HTTP**, no HTTPS. En ese escenario, el `POST`
de login genera una **cookie de sesión inválida/vacía**, así que el navegador no conserva una
sesión válida. Resultado:

- Los archivos **estáticos** (`app.bundle.js`, etc.) cargan con **200** (no requieren sesión).
- Las peticiones **XHR autenticadas** del SPA (`preferences/get_all`, `misc/bgprocess/`,
  `status`, `browser/check_corrupted_db_file`...) devuelven **401** → el SPA no recibe datos
  → **página en blanco**.

Con VS Code de escritorio el túnel `localhost` no mete un proxy que rompa el esquema, por eso
el bug solo se veía en la versión web.

> Las XHR son del **mismo origen** que la página, por lo que el atributo `SameSite` de la
> cookie **no** es el problema (una cookie de mismo origen se envía aunque sea `Lax`/`Strict`).
> El problema es que la cookie de login no llega a establecerse de forma válida.

## Intentos que NO funcionaron

Se documentan para no repetirlos:

1. **`ENHANCED_COOKIE_PROTECTION: "False"`** — atacaba una supuesta rotación de IP. No
   resolvió el 401.
2. **`SESSION_COOKIE_SECURE: "True"` + `SESSION_COOKIE_SAMESITE: "'None'"`** — `SameSite` no
   aplica a peticiones de mismo origen, así que tampoco resolvió nada.

## Solución aplicada — modo escritorio

Como es un laboratorio de **un solo usuario local**, no se necesita el modo servidor
multiusuario de pgAdmin (con login y sesiones). Activando el **modo escritorio**
(`SERVER_MODE=False`) pgAdmin **deja de pedir login**: no hay sesión ni cookie, y por tanto
**desaparece el 401 de raíz**. Además, la versión web pasa a funcionar igual que la de escritorio.

```yaml
pgadmin:
  image: dpage/pgadmin4:latest
  environment:
    PGADMIN_DEFAULT_EMAIL: postgres@sql.dev
    PGADMIN_DEFAULT_PASSWORD: 1234
    PGADMIN_CONFIG_SERVER_MODE: "False"
    PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: "False"
```

> **Notas:**
> - `PGADMIN_DEFAULT_EMAIL`/`PASSWORD` siguen siendo necesarios: el *entrypoint* del contenedor
>   los exige aunque no haya login.
> - `MASTER_PASSWORD_REQUIRED: "False"` evita que pgAdmin pida una "master password" para
>   desbloquear las contraseñas guardadas, manteniendo el arranque sin fricción.
> - Las variables `PGADMIN_CONFIG_*` se inyectan **verbatim como literal de Python** en el
>   `config_local.py`; por eso los booleanos se escriben `"False"`/`"True"`.

## Nota de seguridad

El modo escritorio (`SERVER_MODE=False`) desactiva el sistema de login/usuarios de pgAdmin.
Es **seguro y aceptable en este entorno educativo**, donde:

- pgAdmin solo es accesible a través del puerto privado reenviado del propio Codespace del
  alumno (no es público).
- Es un laboratorio local de un único usuario; no hay datos ni credenciales de producción.

En un despliegue **multiusuario o de producción** NO se debe usar modo escritorio: ahí lo
correcto es mantener el modo servidor y configurar el proxy para que pgAdmin reciba el esquema
real (`X-Forwarded-Proto`/`X-Scheme`) y `ProxyFix`, de modo que la cookie de login se genere
como HTTPS.

## Checklist

- [x] Causa raíz real identificada: el proxy termina el TLS y pgAdmin ve HTTP, generando una
      cookie de login inválida → XHR autenticadas con 401 → página en blanco.
- [x] Descartado que sea `SameSite` (las XHR son de mismo origen) o rotación de IP.
- [x] Intentos con cookies documentados como fallidos para no repetirlos.
- [x] `PGADMIN_CONFIG_SERVER_MODE: "False"` y `PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: "False"`
      aplicados en `docker-compose.yml`.
- [x] Nota de seguridad sobre el alcance del modo escritorio incluida.
