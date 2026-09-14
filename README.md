# issue-env

Consola de trabajo atada a un issue de GitHub. Al iniciar lista solo los issues **abiertos**, y **es obligatorio** elegir uno o crear uno nuevo. A partir de ahí todos los commits llevan el prefijo `[#<número>]`.

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
| `./issue.sh setup` | Instala los hooks de git y regenera la copia versionada en `.githooks/` |

## Dentro del entorno

Hay dos modos. En **commit**, el texto es el mensaje: stagea lo que falte, commitea con el prefijo y ofrece pushear. En **shell**, cada línea se ejecuta en la terminal (`git status`, `git push`, etc.).

```
[#12] › corrige validación del formulario
  ¿Push a origin/main? [S/n]
[#12] shell › git status
```

| Comando | Qué hace |
| --- | --- |
| `/shell` | Pasa a modo shell (desde commit) |
| `/commit` | Pasa a modo commit (desde shell) |
| `/menu` | Vuelve al menú de issues |
| `/close` | Cierra el issue activo en GitHub |
| `/deploy` | Commitea con el prefijo `[#N] [deploy]` (solo commit) |
| `/exit` | Sale del entorno |

Sin issue activo, `git commit` se aborta. Los colores se apagan solos si la salida no es una terminal, o con `NO_COLOR=1`.

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
- Los comandos de git se corren capturando la salida en vez de heredar la consola. En Windows, git resetea el modo VT de la terminal y desde ahí los códigos ANSI se imprimen en crudo (`←[1G←[0J`).
- Hooks `prepare-commit-msg` y `commit-msg` en `.git/hooks` (copia versionada en `.githooks/`). El start solo instala los hooks locales y escribe únicamente si el contenido cambió; la copia versionada se regenera con `./issue.sh setup`.
