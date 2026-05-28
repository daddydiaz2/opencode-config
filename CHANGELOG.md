# Changelog

## [2.0.0] — 2026-05-28 — Rewrite Completo

### 🔴 Breaking
- Configuracion completamente regenerada desde templates (NO usar configs/ anteriores)
- `install.sh` ahora detecta sistema y GENERA configs, no copia estaticas
- Eliminado `configs/` — reemplazado por `templates/` con variables portatiles

### ✨ Features
- **Sistema de templates**: `templates/opencode.json` y `templates/agent/core/openagent.md`
- **Deteccion automatica de LSPs**: resolve_lsp() busca en PATH y npm root -g
- **MCPs condicionales**: radzen/mudblazor/fluentui/lsp-mcp solo si existen en el sistema
- **Sin paths hardcodeados**: 0 referencias a `/home/daniel` en templates
- **validate-config.sh**: Valida JSON, binarios, paths, y portabilidad
- **uninstall.sh**: Remocion completa con backup automatico
- **setup-lsps.sh**: 12 LSPs (antes 3), con deteccion de estado
- **VERSION + CHANGELOG**: Versionado semantico

### 🐛 Fixes
- `setup-lsps.sh` instalaba solo 3 de 12 LSPs → ahora instala todos
- `configs/global/opencode.json` tenia filesystem apuntando a `/home/daniel` → scoped a `"."`
- `init-project.sh` referencia a directorio `.claude` inexistente
- `detect-frameworks.sh` generaba formato incompatible con opencode

### 🔧 Infrastructure
- `install.sh` reescrito: backup, deteccion, generacion, validacion
- `configs/` → `templates/` con variables `__LSP_CSHARP__` y `{{HOME}}`
- Todos los scripts ejecutables y autocontenidos

---

## [1.0.0] — 2026-05-27 — Inicial

- Configuracion inicial: LSPs, MCPs, comandos, formatters
- Scripts: install.sh, setup-lsps.sh, init-project.sh, detect-frameworks.sh
- openagent.md con modo caveman, profesional, espanol
- autoskills integration
- GitHub Actions CI
- opencode-config-manager.sh (backup/restore/update)
- lsp-health-check.sh
