# leren-cli

CLI interno de **Leren** para laburar themes Tiendanube (`tn-*`) atado a un issue de GitHub.

Al iniciar lista los issues recientes, obliga a elegir uno abierto o crear uno nuevo, y a partir de ahí todos los commits llevan el prefijo `[#<número>]`. Sin sesión activa, `git commit` se aborta.

> Antes se llamaba `issue-env`. Misma idea: consola por issue, prefijo de commits, modo shell y lint Liquid.

## Para quién

Desarrollo interno Leren sobre repos de tienda (sobre todo los creados desde [`github-template-tiendanube`](https://github.com/Leren-Dev/github-template-tiendanube)). No es un producto público.

## Requisitos

- [Node.js](https://nodejs.org/) ≥ 18
- [GitHub CLI](https://cli.github.com/) (`gh`) autenticado (`gh auth login`)
- Acceso al org `Leren-Dev` (el repo es **privado**)

En Windows, si `npx github:Leren-Dev/leren-cli` no clona el repo, corré una vez:

```bash
gh auth setup-git
```

## Uso desde un repo de tienda

```bash
# Git Bash / macOS / Linux (wrapper del template)
./leren-cli

# Windows cmd
leren-cli.cmd

# Sin wrapper
npx --yes github:Leren-Dev/leren-cli
```

La primera vez, `setup` (también corre al start) instala los hooks en **`.git/hooks` de la tienda**, no en este repo.

| Comando | Qué hace |
| --- | --- |
| `leren-cli` | Lista issues, obliga a elegir o crear, abre la consola |
| `leren-cli status` | Muestra el issue activo |
| `leren-cli stop` | Cierra la sesión (los commits quedan bloqueados) |
| `leren-cli login` | Fuerza un nuevo `gh auth login` |
| `leren-cli setup` | Instala los hooks en `.git/hooks` de **este** repo (la tienda) |

Alias corto si el paquete está linkeado: `leren`.

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
| `/commit` | Vuelve a modo commit (desde shell) |
| `/lint` | En modo shell: test de sintaxis Liquid en todos los `.tpl` / `.liquid` |
| `/menu` | Vuelve al menú de issues |
| `/close` | Cierra el issue activo en GitHub |
| `/dpy` | Commitea con el prefijo `[#N] [deploy]` (dispara el workflow FTP del theme) |
| `/exit` | Sale del entorno |

`pull`, `merge` y `push` vanilla siguen funcionando. Solo `git commit` exige issue activo.

Los mensajes quedan así (el prefijo no usa `#` al inicio de la línea porque Git lo trata como comentario):

```
[#12] corrige validación del formulario
[#12] [deploy] sube el home
```

`[#N] [deploy]` es lo que disparan las Actions FTP del template (`main.yml`).

## Autenticación

El login se hace **una sola vez por entorno**: la primera vez corre `gh auth login` si no hay sesión, y después queda cacheado en `.git/leren-cli-auth.json`. Para rehacerlo, `leren-cli login`.

## Contribuir al CLI

```bash
git clone https://github.com/Leren-Dev/leren-cli.git
cd leren-cli
npm link          # deja `leren-cli` y `leren` en el PATH
npm test          # fixtures de Liquid en examples/liquid
```

## Cómo está armado

- `bin/leren-cli.js` + `src/` — auth, issues, consola y hooks.
- `leren-cli` / `leren-cli.cmd` — atajos locales del clone.
- El `pre-commit` revisa Liquid en stage: `if`/`for`/`set`/`block`/`embed`/`macro`, asignaciones `set`, y paréntesis/llaves dentro de `{{ }}` y `{% %}`. Cancela el commit si hay errores.
- En una tienda los hooks delegan a `npx github:Leren-Dev/leren-cli hook …` (no hace falta copiar `src/` al theme).
