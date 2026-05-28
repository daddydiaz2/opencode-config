<div align="center">

# ⚡ OpenCode Config

**Configuración portable, auto-detectora y validada para [OpenCode AI](https://opencode.ai)**

---

![Version](https://img.shields.io/badge/version-2.0.0-blue?style=flat-square)
![CI](https://img.shields.io/github/actions/workflow/status/daddydiaz2/opencode-config/ci.yml?style=flat-square&label=CI)
![License](https://img.shields.io/github/license/daddydiaz2/opencode-config?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-bash%20≥4-green?style=flat-square)
![LSPs](https://img.shields.io/badge/LSPs-11-yellow?style=flat-square)

> Detecta tu entorno. Genera tu config. Valida todo. Sin hardcodear nada.

</div>

---

## 🎯 ¿Qué es esto?

OpenCode Config es un sistema que convierte tu máquina en un entorno de desarrollo AI completo con **un solo comando**. Detecta tu stack, resuelve Language Servers, genera configuración portátil, y mantiene todo con backups automáticos.

```bash
curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash
```

**Un comando. Cero configuración manual. Configuración que viaja entre máquinas.**

---

## 📋 Tabla de Contenidos

- [🚀 Instalación Rápida](#-instalación-rápida)
- [📐 Arquitectura](#-arquitectura)
- [🔧 Componentes](#-componentes)
- [⚙️ Sistema de Templates](#️-sistema-de-templates)
- [🔌 Sistema LSP](#-sistema-lsp)
- [🧠 Sistema MCP](#-sistema-mcp)
- [📚 Context Files](#-context-files)
- [🧪 Tests](#-tests)
- [🛡️ Seguridad](#️-seguridad)
- [💻 Desarrollo](#-desarrollo)
- [📋 Requisitos](#-requisitos)

---

## 🚀 Instalación Rápida

### Opción 1 — Una línea (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash
```

### Opción 2 — Clone manual

```bash
git clone https://github.com/daddydiaz2/opencode-config.git
cd opencode-config
./install.sh
```

### Opción 3 — Docker / CI

```bash
./install.sh --skip-lsps
```

> 💡 **¿Qué hace?** Detecta Node.js, Python3, jq, y cada LSP. Genera `~/.config/opencode/opencode.json` con 11 LSPs y 8 MCPs. Instala LSPs faltantes. Valida todo al final.

---

## 📐 Arquitectura

```
opencode-config/
│
│  ┌─────────────────────────────────────────────────────────────────┐
│  │                    🏗️  SCRIPTS PRINCIPALES                     │
│  ├─────────────────────────────────────────────────────────────────┤
│  │  install.sh                 → Detector + generador + instalador │
│  │  uninstall.sh               → Limpieza con backup automático    │
│  │  setup-lsps.sh              → 12 Language Servers               │
│  │  validate-config.sh         → Validador post-instalación        │
│  │  opencode-config-manager.sh → Gestor: backup/restore/status     │
│  │  lsp-health-check.sh        → Monitor de salud LSP              │
│  │  init-project.sh            → Inicialización por proyecto       │
│  │  detect-frameworks.sh       → Detección de stack                │
│  └─────────────────────────────────────────────────────────────────┘
│
│  ┌─────────────────────────────────────────────────────────────────┐
│  │                    📦  TEMPLATES (el corazón)                   │
│  ├─────────────────────────────────────────────────────────────────┤
│  │  templates/opencode.json      → Config con placeholders         │
│  │  templates/agent/core/        → Prompt del agente               │
│  │  templates/context/           → 6 archivos de estándares        │
│  └─────────────────────────────────────────────────────────────────┘
│
│  ┌─────────────────────────────────────────────────────────────────┐
│  │                    🧪  TESTS (locales + CI)                     │
│  ├─────────────────────────────────────────────────────────────────┤
│  │  tests/run.sh                → Runner central                   │
│  │  tests/test_install.sh       → Install en HOME temporal         │
│  │  tests/test_json.sh          → Validación JSON                  │
│  │  tests/test_portability.sh   → 0 paths hardcodeados            │
│  │  tests/test_placeholders.sh  → Placeholders correctos          │
│  │  tests/test_shellcheck.sh    → Lint de scripts                  │
│  └─────────────────────────────────────────────────────────────────┘
│
│  .github/workflows/ci.yml      → CI: checkout → shellcheck → tests
│  VERSION
│  CHANGELOG.md
│  README.md
```

---

## 🔧 Componentes

### Scripts Principales

<table>
<tr>
<td width="50%" valign="top">

#### `install.sh` — Instalador principal

**Propósito:** Único comando para poner opencode operativo.

**Flujo:**
1. 🗂️ Backup automático de config previa
2. 🔍 Detección de Node.js, Python3, jq
3. 🧩 Resolución de LSPs via `resolve_lsp()`
4. ⚙️ Generación de configs desde templates
5. 📄 Instalación de context files
6. ✅ Validación del JSON generado
7. 📦 Instalación de LSPs faltantes

**Flags:**
| Flag | Efecto |
|------|--------|
| `--dry-run` | Solo muestra detección, no escribe |
| `--force` | Sobrescribe sin preguntar |
| `--skip-lsps` | Salta instalación de LSPs |
| `--help` | Muestra ayuda |

</td>
<td width="50%" valign="top">

#### `setup-lsps.sh` — Instalador de Language Servers

**Propósito:** Instala los 12 LSPs que opencode necesita.

| # | LSP | Tipo |
|---|-----|------|
| 1 | OmniSharp | .NET/C# |
| 2 | html-languageserver | HTML/Razor |
| 3 | css-languageserver | CSS/SCSS |
| 4 | vscode-json-languageserver | JSON |
| 5 | typescript-language-server | JS/TS |
| 6 | yaml-language-server | YAML |
| 7 | remark-language-server | Markdown |
| 8 | intelephense | PHP |
| 9 | pyright | Python |
| 10 | bash-language-server | Bash |
| 11 | lsp-mcp | Fallback |

</td>
</tr>
<tr>
<td>

#### `validate-config.sh` — Validador

**Propósito:** Auditoría post-instalación. Verifica 4 aspectos:

| Check | Qué hace |
|-------|----------|
| ✅ JSON válido | Parsea `opencode.json` |
| ✅ Binarios LSP | Cada `command[0]` existe |
| ✅ Binarios MCP | Cada MCP local accesible |
| ✅ Portabilidad | 0 paths `/home/` hardcodeados |

</td>
<td>

#### `opencode-config-manager.sh` — Gestor

**Propósito:** Mantenimiento de la instalación activa.

| Comando | Función |
|---------|---------|
| `backup` | Respaldo manual |
| `restore [ver]` | Restaurar versión |
| `update` | Re-ejecutar install |
| `status` | Ver versión y fecha |
| `health` | Verificar archivos |

</td>
</tr>
</table>

---

## ⚙️ Sistema de Templates

El corazón de la portabilidad. Los templates usan placeholders que `install.sh` resuelve dinámicamente.

### Flujo de Resolución

```
┌──────────────────────┐      ┌────────────────────────┐      ┌──────────────────────┐
│  📝 TEMPLATE         │      │  🔍 DETECCIÓN          │      │  📄 CONFIG FINAL      │
│                      │      │                        │      │                      │
│  __LSP_CSHARP__      │ ───→ │  omnisharp encontrado? │ ───→ │  ["omnisharp", "-lsp"]│
│  __LSP_RAZOR__       │      │  ¿npm? ¿node?          │      │  ["node", "/usr/..."] │
│  {{HOME}}/.config/…  │      │  $HOME resuelto        │      │  /home/user/.config/… │
└──────────────────────┘      └────────────────────────┘      └──────────────────────┘
```

### Placeholders Soportados

| Placeholder | Tipo | Resolución |
|-------------|------|------------|
| `__LSP_CSHARP__` | JSON array | `["omnisharp", "-lsp"]` o `null` |
| `__LSP_RAZOR__` | JSON array | `["node", "path/to/htmlServerMain.js", "--stdio"]` o `null` |
| `{{HOME}}` | String | `$HOME` del usuario actual |

### Procesamiento

1. Lee template como texto
2. Reemplaza `__LSP_*__` por arrays JSON reales (vía `resolve_lsp()`)
3. Reemplaza `__*__` restantes por `null`
4. Parsea como JSON y agrega MCPs condicionales
5. Escribe a `~/.config/opencode/opencode.json`

> 💡 **Fallback:** Si Python3 no está disponible, usa `sed` + `jq`. Todos los LSPs quedan como `null`.

---

## 🔌 Sistema LSP

OpenCode Config maneja **11 Language Servers**. Cada uno se resuelve en 2 pasos:

### 1. Detección (`install.sh`)

```
resolve_lsp("omnisharp", "", "-lsp", false)
  │
  ├─→ ¿which omnisharp?  ──── SÍ ──→ ["/path/to/omnisharp", "-lsp"]
  │                          │
  │                         NO
  │                          │
  └─→ ¿npm root -g/omnisharp? ─→ SÍ ──→ ["node", "/npm/root/omnisharp", "-lsp"]
                                   │
                                  NO
                                   │
                                   └──→ null
```

### 2. Instalación (`setup-lsps.sh`)

- Verifica si ya está instalado
- Si no, instala vía `npm install -g` o `dotnet tool install`
- Reporta: instalados ✅, fallidos ❌, omitidos ⏭️

> ⚠️ **Caso Razor/HTML/CSS:** npm crea symlink `html-languageserver`, no `vscode-html-languageserver`. El script busca por el nombre real.

---

## 🧠 Sistema MCP

Los MCPs (Model Context Protocols) son herramientas que opencode expone al agente AI.

### Siempre Activos (7)

| MCP | Fuente | Función |
|-----|--------|---------|
| `context7` | built-in | Documentación actualizada de librerías |
| `git` | built-in | Operaciones Git |
| `memory` | built-in | Memoria persistente del agente |
| `sequential-thinking` | built-in | Razonamiento estructurado |
| `grep` | built-in | Búsqueda en código |
| `filesystem` | built-in | Acceso a archivos del workspace |
| `microsoft-learn` | built-in | Documentación Microsoft |

### Condicionales (4)

Se agregan automáticamente si los encuentra en el sistema:

| MCP | Condición | Función |
|-----|-----------|---------|
| `radzen-blazor` | `~/.agents/skills/radzen-mcp/index.js` | Documentación Radzen |
| `mudblazor` | `~/.agents/skills/mudblazor-mcp/index.js` | Documentación MudBlazor |
| `fluentui` | `~/.agents/skills/fluentui-mcp/index.js` | Documentación Fluent UI |
| `lsp-mcp` | `lsp-mcp` en `$PATH` | Fallback de LSPs |

---

## 📚 Context Files

6 archivos que definen estándares del proyecto. El agente los carga automáticamente antes de ejecutar tareas.

| Archivo | Propósito | Cargado cuando… |
|---------|-----------|-----------------|
| 📋 `navigation.md` | Índice de todos los context files | — |
| 🎨 `standards/code-quality.md` | Convenciones C#, EF, Razor, DataTables | Se escribe/edita código |
| 📖 `standards/documentation.md` | Formato de documentación, commits | Se escribe documentación |
| 🧪 `standards/test-coverage.md` | Framework de tests, patrones AAA | Se escriben tests |
| 👀 `workflows/code-review.md` | Checklist de revisión | Se revisa código |
| 📤 `workflows/task-delegation-basics.md` | Cuándo y cómo delegar | Se delegan tareas |

### Ejemplo de Uso

```markdown
<!-- En openagent.md (template) -->
## Antes de ejecutar, cargar contexto:
{{HOME}}/.config/opencode/context/core/standards/code-quality.md
{{HOME}}/.config/opencode/context/core/workflows/code-review.md
```

Después de `install.sh`, se resuelve a:
```markdown
## Antes de ejecutar, cargar contexto:
/home/usuario/.config/opencode/context/core/standards/code-quality.md
/home/usuario/.config/opencode/context/core/workflows/code-review.md
```

---

## 🧪 Tests

Suite portable que corre **localmente** y en **CI** con los mismos comandos.

### Ejecutar

```bash
# Todos los tests
bash tests/run.sh

# Modo rápido (sin install)
bash tests/run.sh --quick
```

### Qué se Verifica

<table>
<tr>
<th>Test</th>
<th>Qué verifica</th>
<th>Por qué importa</th>
</tr>
<tr>
<td><code>test_install.sh</code></td>
<td>Install en HOME temporal → 11 archivos, JSON válido, 0 placeholders sin resolver</td>
<td>Garantiza que <code>install.sh</code> funciona de extremo a extremo</td>
</tr>
<tr>
<td><code>test_json.sh</code></td>
<td>Sintaxis JSON de todos los <code>.json</code></td>
<td>Evita commits con JSON roto</td>
</tr>
<tr>
<td><code>test_portability.sh</code></td>
<td>0 paths <code>/home/</code> literales en templates/</td>
<td>Mantiene la portabilidad</td>
</tr>
<tr>
<td><code>test_placeholders.sh</code></td>
<td><code>{{HOME}}</code> presente en templates</td>
<td>Asegura que no se cuelen paths absolutos</td>
</tr>
<tr>
<td><code>test_shellcheck.sh</code></td>
<td>Lint de todos los <code>.sh</code></td>
<td>Previene bugs sutiles en bash</td>
</tr>
</table>

### CI/CD

El workflow `.github/workflows/ci.yml` corre en cada push/PR a `main`:

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Checkout │ ──→ │ Node.js  │ ──→ │Shellcheck│ ──→ │  Tests   │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
```

---

## 🛡️ Seguridad

| Aspecto | Medida | Estado |
|---------|--------|--------|
| 🔒 Filesystem MCP | Scoped a `.` (workspace actual) | ✅ |
| 🚫 Paths hardcodeados | 0 — todos resueltos dinámicamente | ✅ |
| 💾 Backup pre-instalación | Automático en `~/.config/opencode.backups/` | ✅ |
| ↩️ Rollback | `opencode-config-manager.sh restore` | ✅ |
| 🗑️ Uninstall | `uninstall.sh` respalda antes de eliminar | ✅ |
| 📦 LSPs | Solo npm global + dotnet tool | ✅ |

---

## 💻 Desarrollo

### Estructura de un Test

```bash
#!/bin/bash
# tests/test_mi_feature.sh
set -euo pipefail

# Tu lógica de test
echo "  → Verificando algo..."
if [ condición ]; then
    echo "  ✓ Pasa"
else
    echo "  ✗ Falla"
    exit 1
fi
```

> 💡 El runner (`tests/run.sh`) descubre automáticamente los tests por nombre (`test_*.sh`).

### Agregar un Test

1. Crear `tests/test_mi_feature.sh`
2. Usar `set -euo pipefail`
3. Exit 0 = pasa, cualquier otro = falla
4. Push — CI lo ejecuta automáticamente

### Comandos Útiles

```bash
# Tests rápidos (sin install)
bash tests/run.sh --quick

# Suite completa
bash tests/run.sh

# Verificar un script específico
shellcheck -x install.sh

# Validar JSON
python3 -c "import json; json.load(open('templates/opencode.json'))"
```

---

## 📋 Requisitos

<table>
<tr>
<th>Dependencia</th>
<th>Necesaria para</th>
<th>Notas</th>
</tr>
<tr>
<td><code>bash ≥4</code></td>
<td>Todos los scripts</td>
<td>—</td>
</tr>
<tr>
<td><code>Node.js ≥18 + npm</code></td>
<td>LSPs Node, <code>templates/opencode.json</code></td>
<td>10 de 12 LSPs son Node</td>
</tr>
<tr>
<td><code>Python3 ≥3.8</code></td>
<td>Procesamiento de templates</td>
<td>Fallback a jq si no existe</td>
</tr>
<tr>
<td><code>jq</code></td>
<td>Fallback de templates</td>
<td>Solo si no hay Python3</td>
</tr>
<tr>
<td><code>.NET SDK</code></td>
<td>OmniSharp (LSP C#)</td>
<td>Opcional</td>
</tr>
</table>

---

<div align="center">

### 📊 Resumen

| Métrica | Valor |
|---------|-------|
| 📁 Scripts | 8 |
| 🔌 LSPs | 11 |
| 🧠 MCPs | 11 (7 siempre + 4 condicionales) |
| 🧪 Tests | 5 |
| 📚 Context Files | 6 |
| ⚡ Instalación | ~30 segundos |

---

**Hecho con ❤️ para la comunidad de OpenCode AI**

[📥 Instalar Ahora](#-instalación-rápida) · [📖 Documentación](#-tabla-de-contenidos) · [🐛 Issues](https://github.com/daddydiaz2/opencode-config/issues)

---

## ☕ ¡Invítame a un Café!

<div align="center">

Si este proyecto te ha sido útil, considera invitarme a un café. ☕

Cada donación me ayuda a seguir mejorando y manteniendo este proyecto para toda la comunidad.

**Tu apoyo hace la diferencia.** 🙌

<br>

<a href="https://www.paypal.com/donate/?hosted_button_id=VDP69Z8GNTAR2" target="_blank">
  <img src="https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white" alt="Donar con PayPal" />
</a>

> *"Un café, una idea. Un dono, un proyecto mejor."* ☕✨

</div>
