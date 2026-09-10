# issue-env

Consola de trabajo atada a un issue de GitHub. Al iniciar lista los issues **no cerrados**, y **es obligatorio** elegir uno o crear uno nuevo. A partir de ahí todos los commits llevan el prefijo `[#<número>]`.

## Uso

```bash
npm start
# o
./issue.sh
```

| Comando | Qué hace |
| --- | --- |
| `./issue.sh` | Lista issues abiertos, obliga a elegir o crear, abre la consola del issue |
| `./issue.sh status` | Muestra el issue activo |
| `./issue.sh stop` | Cierra la sesión (los commits quedan bloqueados) |
| `./issue.sh login` | Fuerza un nuevo `gh auth login` |
| `./issue.sh setup` | Instala los hooks de git |

## Dentro del entorno

La consola queda abierta hasta que escribas `/exit`. Todo lo que no sea un comando se toma como mensaje de commit: stagea lo que falte, commitea con el prefijo y ofrece pushear.

```
[#12] › corrige validación del formulario
  ¿Push a origin/main? [S/n]
```

| Comando | Qué hace |
| --- | --- |
| `/status`, `/diff`, `/log` | Estado, cambios y últimos commits |
| `/add` | Stagea todo |
| `/push`, `/pull` | Envía o trae de origin |
| `/issue` | Cambia de issue sin salir |
| `!<cmd>` | Ejecuta cualquier comando en la shell |
| `/exit` | Sale del entorno |

Sin issue activo, `git commit` se aborta.

Los mensajes quedan así (el prefijo no usa `#` al inicio de la línea porque Git lo trata como comentario):

```
[#12] corrige validación del formulario
```

## Autenticación

Requiere [GitHub CLI](https://cli.github.com/). El login se hace **una sola vez por entorno**: la primera vez corre `gh auth login` si no hay sesión, y después queda cacheado en `.git/issue-env-auth.json`. Para rehacerlo, `./issue.sh login`.

## Cómo está armado

- `bin/issue.js` + `src/` — auth, listado, selección de issue y la consola del entorno.
- `issue.sh` — atajo que llama al CLI de Node.
- La consola es un prompt propio (`src/repl.js`), no un bash anidado: un bash interactivo lanzado desde Node sobre MSYS se cierra apenas arranca.
- Hooks `prepare-commit-msg` y `commit-msg` en `.git/hooks` (copia versionada en `.githooks/`).
