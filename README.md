# 🚀 OpenCode Config

<div align="center">

![OpenCode](https://img.shields.io/badge/OpenCode-Professional-2563eb?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge)

**Configuración profesional multi-proyecto para OpenCode AI**

*Domina cualquier stack tecnológico con detección automática, LSPs potentes y skills inteligentes.*

[Características](#-características) •
[Instalación](#-instalación-rápida) •
[Documentación](#-documentación) •
[Contribuir](#-contribuir)

</div>

---

## 🎯 Problema que Resuelve

> *"Cada proyecto tiene su propio stack, sus propias convenciones. ¿Por qué tu AI assistant no las detecta automáticamente?"*

**Desafíos comunes:**
- ❌ Cambias de proyecto Python a .NET y pierdes autocompletado
- ❌ Tienes que reconfigurar LSPs en cada máquina
- ❌ Los skills no se cargan según el framework (Radzen, MudBlazor, React)
- ❌ Comentarios de código insuficientes, sin análisis profesional
- ❌ Respuestas verbose que consumen tokens innecesarios

**Con esta config:**
- ✅ Detección automática de stack y frameworks
- ✅ LSPs funcionando en cualquier proyecto
- ✅ Skills generados por `npx autoskills` según tecnología
- ✅ Código comentado profesionalmente
- ✅ Modo caveman para máxima eficiencia de tokens

---

## ✨ Características

### 🌐 Auto-Detección Inteligente

```
Proyecto .NET + Radzen     → Carga radzen-blazor MCP automáticamente
Proyecto .NET + MudBlazor  → Carga mudblazor MCP automáticamente
Proyecto React/Vue/Angular → Carga skills de frontend
Proyecto Python             → Activa pyright LSP
Proyecto PHP                 → Activa intelephense LSP
```

### 🔧 Language Servers (LSPs)

| Lenguaje | LSP | Estado |
|----------|-----|--------|
| C# / ASP.NET Core | lsp-mcp | ✅ |
| Razor / Blazor | vscode-html-ls | ✅ |
| Python | pyright | ✅ |
| PHP | intelephense | ✅ |
| JavaScript / TypeScript | typescript-language-server | ✅ |
| HTML / CSS / JSON | vscode-{html,css,json}-ls | ✅ |
| YAML | yaml-language-server | ✅ |
| Markdown | remark-language-server | ✅ |
| Bash | bash-language-server | ✅ |

### 🤖 Model Context Protocol (MCP)

**Universales (siempre activos):**
- `context7` — Documentación actualizada de librerías
- `git` — Control de versiones
- `memory` — Memoria persistente entre sesiones
- `filesystem` — Acceso a archivos del proyecto

**Auto-detectados por proyecto:**
- `radzen-blazor` — Componentes Radzen
- `mudblazor` — Componentes MudBlazor
- `fluentui` — Validación FluentValidation

### 🎓 Skills Automáticos

```bash
npx autoskills
```

Detecta automáticamente el stack del proyecto e instala los mejores skills:

| Tecnología | Skills Instalados |
|------------|-------------------|
| .NET / C# | dotnet-best-practices, csharp-async, aspnet-core |
| Python | python-*, django-*, fastapi-* |
| React | react-best-practices, next-* |
| Vue | vue-*, nuxt-* |
| PHP | laravel-*, php-* |

### 💬 Modos de Comunicación

#### Modo Profesional (Español)
Siempre antes de actuar:
1. **Análisis** — Problema, contexto, riesgos, impacto
2. **Opciones** — 2-3 alternativas con pros/contras
3. **Recomendación** — Enfoque sugerido con razonamiento
4. **Espera confirmación** antes de ejecutar

#### Modo Caveman (Ultra-Comprimido)
- ~75% reducción de tokens
- Elimina artículos, filler, hedging
- Mantiene precisión técnica absoluta
- Ideal para sesiones largas

---

## ⚡ Instalación Rápida

### Una línea (global)

```bash
curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash
```

### Por Proyecto

```bash
# Detectar frameworks y configurar
./detect-frameworks.sh /ruta/proyecto

# O inicialización completa con autoskills
./init-project.sh
```

---

## 📖 Documentación

### Estructura del Proyecto

```
opencode-config/
├── install.sh                 # Instalación global
├── setup-lsps.sh             # Instalar Language Servers
├── detect-frameworks.sh       # Detectar frameworks → cargar MCPs
├── init-project.sh            # Inicializar proyecto completo
├── configs/
│   ├── global/              # Config que va a ~/.config/opencode/
│   │   ├── opencode.json    # LSPs + MCPs universales
│   │   └── agent/core/
│   │       └── openagent.md # Prompt sistema (español + profesional)
│   └── project-template/     # Template para nuevos proyectos
└── .github/workflows/       # CI/CD
```

### Scripts Explicados

| Script | Función | Cuándo usarlo |
|--------|---------|--------------|
| `install.sh` | Instalación global + LSPs | Una vez por máquina |
| `setup-lsps.sh` | Instala pyright, intelephense, bash-ls | Una vez |
| `detect-frameworks.sh` | Escanea deps → genera .opencode/mcp.json | Al cambiar de proyecto |
| `init-project.sh` | Detecta + autoskills + estructura | Nuevo proyecto |

### Configuración de LSPs

Los LSPs se configuran en `~/.config/opencode/opencode.json`:

```json
{
  "lsp": {
    "csharp": {
      "command": ["lsp-mcp"],
      "extensions": [".cs"]
    },
    "python": {
      "command": ["pyright"],
      "extensions": [".py"]
    }
  }
}
```

### Agregar Nuevo Framework

Edita `detect-frameworks.sh` y agrega el mapeo:

```bash
# En la sección .NET Projects
if grep -rqi "MiFramework" "$PROJECT_DIR" 2>/dev/null; then
    echo "  ✓ MiFramework → mi-framework MCP"
    jq '.mcp.servers += ["mi-framework"]' "$MCP_FILE" > /tmp/mcp.json && mv /tmp/mcp.json "$MCP_FILE"
fi
```

---

## 🧪 Verificación

### Test de Instalación

```bash
# Verificar LSPs instalados
npm list -g pyright intelephense bash-language-server

# Verificar MCPs activos
opencode mcp list

# Test LSP diagnostics (archivo vacío = sin errores)
opencode debug lsp diagnostics tu-proyecto/Archivo.cs
```

### Troubleshooting LSP

**Problema: No veo indicador visual de LSP activo**

**Respuesta:** Es normal. Los LSPs trabajan silenciosamente en background. No hay indicador visual en la CLI.

**Verificar que funciona:**
```bash
# Test 1: Diagnostics en archivo existente
opencode debug lsp diagnostics tu-proyecto/Archivo.cs
# {} = sin errores, o {errors: [...]} = tiene errores

# Test 2: Crear error intencional y verificar que el LSP lo detecta
# En un archivo .py escribe: print(
# Guarda y ejecuta: opencode debug lsp diagnostics tu-archivo.py
# Debe detectar el error de sintaxis

# Test 3: Symbols (autocompletado)
opencode debug lsp symbols TuClase
# Debe listar símbolos del proyecto
```

**Problema: LSP no responde / se cuelga**

```bash
# Opción 1: Timeout del LSP (30s por defecto)
# Los LSPs tienen timeout. Si un archivo es muy grande, puede expirar.

# Opción 2: Reiniciar session
exit
opencode

# Opción 3: Ver logs detallados
opencode debug --log-level DEBUG
# Ejecutar el comando que falló
# Revisar los logs en stderr
```

**Problema: Autocompletado lento en archivos grandes**

```bash
# Los LSPs pueden ser lentos en archivos >1000 líneas
# Solución: LSP solo analiza el archivo actual y imports

# Para mejorar velocidad:
# 1. Cerrar archivos innecesarios
# 2. Usar navegación por símbolos en lugar de búsqueda global
opencode debug lsp symbols miClase
```

### Troubleshooting MCP

**Verificar estado de MCPs:**
```bash
opencode mcp list
# ● = activo, ○ = inactivo, ✗ = error
```

**Debuggear MCP específico:**
```bash
opencode mcp debug <nombre-mcp>
# Muestra logs detallados de conexión
```

**MCPs no cargan:**
```bash
# Verificar que el comando existe
which lsp-mcp
which intelephense
which pyright

# Si no existe, reinstalar
npm install -g pyright intelephense bash-language-server
```

---

## 🛠️ Desarrollo

### Requisitos

- Node.js 18+
- Git
- curl
- npm (para LSPs adicionales)

### Instalar desde Fuente

```bash
git clone https://github.com/daddydiaz2/opencode-config.git
cd opencode-config
./install.sh
```

### Actualizar

```bash
cd ~/.config/opencode
git pull origin main
```

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una branch (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -m 'Agregar nueva característica'`)
4. Push a la branch (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

---

## 📋清单 Checklist de Verificación

### Después de instalar

- [ ] `opencode mcp list` muestra los MCPs
- [ ] `npm list -g pyright intelephense bash-language-server` confirma LSPs
- [ ] `ls ~/.config/opencode/` tiene configs
- [ ] En proyecto .NET: archivos `.cs` tienen syntax highlighting
- [ ] En proyecto Python: archivos `.py` tienen autocompletado

### En nuevo proyecto

- [ ] `npx autoskills` se ejecuta sin errores
- [ ] `.opencode/mcp.json` se genera
- [ ] Skills aparecen en `.claude/skills/`
- [ ] LSPs funcionan al editar archivos del stack

---

## 📞 Soporte

- 📝 Abre un [Issue](https://github.com/daddydiaz2/opencode-config/issues)
- 💬 Discusiones en [GitHub Discussions](https://github.com/daddydiaz2/opencode-config/discussions)

---

## 📄 Licencia

MIT © daddydiaz2

---

<div align="center">

**Hecho con ❤️ para desarrolladores profesionales**

</div>
