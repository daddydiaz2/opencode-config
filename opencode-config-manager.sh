#!/bin/bash
# opencode-config-manager.sh — Backup, restore, update, health para OpenCode Config
set -e

CONFIG_DIR="${HOME}/.config/opencode"
BACKUP_DIR="${HOME}/.config/opencode.backups"
MAX_BACKUPS=10
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

show_help() {
    cat << EOF
OpenCode Config Manager v$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "?")

Usage: $(basename "$0") <command> [options]

Commands:
    backup              Backup config actual
    restore [version]   Restaurar backup (ultimo si sin arg)
    list                Listar backups disponibles
    update              Actualizar desde GitHub
    status              Mostrar estado
    health              Validar config actual (ejecuta validate-config.sh)

Examples:
    $(basename "$0") backup
    $(basename "$0") restore pre-update-20240528_143022
    $(basename "$0") update
    $(basename "$0") health
EOF
}

create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local version="${1:-manual-$timestamp}"
    local backup_path="$BACKUP_DIR/$version"
    
    echo -e "${YELLOW}📦 Creando backup: $version${NC}"
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$CONFIG_DIR" ]; then
        cp -r "$CONFIG_DIR" "$backup_path"
        echo "$version" > "$BACKUP_DIR/current-version"
        echo -e "${GREEN}✓ Backup: $backup_path${NC}"
    else
        echo -e "${YELLOW}⚠ No hay config en $CONFIG_DIR${NC}"
        return
    fi
    
    cleanup_old
}

restore_backup() {
    local version="${1:-}"
    [ -z "$version" ] && version=$(ls -1t "$BACKUP_DIR" 2>/dev/null | head -1)
    
    if [ -z "$version" ] || [ ! -d "$BACKUP_DIR/$version" ]; then
        echo -e "${RED}✗ Backup no encontrado: ${version:-N/A}${NC}"
        list_backups
        exit 1
    fi
    
    echo -e "${YELLOW}🔄 Restaurando: $version${NC}"
    create_backup "pre-restore-$(date +%Y%m%d_%H%M%S)"
    
    rm -rf "$CONFIG_DIR"
    cp -r "$BACKUP_DIR/$version" "$CONFIG_DIR"
    
    echo -e "${GREEN}✓ Restaurado: $version${NC}"
    echo -e "${YELLOW}⚠ Reinicia opencode para aplicar cambios${NC}"
}

list_backups() {
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}No hay backups${NC}"
        return
    fi
    
    echo -e "${GREEN}Backups disponibles:${NC}"
    for b in $(ls -1t "$BACKUP_DIR" | grep -v 'current-version'); do
        local size=$(du -sh "$BACKUP_DIR/$b" 2>/dev/null | cut -f1)
        echo "  • $b ($size)"
    done
    
    local current=$(cat "$BACKUP_DIR/current-version" 2>/dev/null || echo "N/A")
    echo -e "Actual: ${CYAN}$current${NC}"
}

cleanup_old() {
    local count=$(ls -1d "$BACKUP_DIR"/*/ 2>/dev/null | wc -l)
    if [ "$count" -gt "$MAX_BACKUPS" ]; then
        echo -e "${YELLOW}🧹 Purgando backups viejos (max $MAX_BACKUPS)...${NC}"
        ls -1t "$BACKUP_DIR" | grep -v 'current-version' | tail -n +$((MAX_BACKUPS + 1)) | while read old; do
            rm -rf "$BACKUP_DIR/$old"
        done
    fi
}

update_config() {
    echo -e "${YELLOW}🔄 Actualizando OpenCode Config...${NC}"
    create_backup "pre-update-$(date +%Y%m%d_%H%M%S)"
    
    if [ -d "$SCRIPT_DIR/.git" ]; then
        cd "$SCRIPT_DIR"
        git pull origin main
    else
        cd /tmp
        [ -d "/tmp/opencode-config" ] && rm -rf /tmp/opencode-config
        git clone https://github.com/daddydiaz2/opencode-config.git /tmp/opencode-config
        SCRIPT_DIR="/tmp/opencode-config"
    fi
    
    bash "$SCRIPT_DIR/install.sh"
    echo -e "${GREEN}✅ Update completo${NC}"
    echo -e "${YELLOW}Si algo falló: $(basename "$0") restore${NC}"
}

show_status() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 OpenCode Config Status${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    local ver=$(cat "$CONFIG_DIR/VERSION" 2>/dev/null || echo "N/A")
    echo -e "  Version:   ${GREEN}$ver${NC}"
    echo -e "  Config:    ${CYAN}$CONFIG_DIR${NC}"
    [ -d "$CONFIG_DIR" ] && echo -e "  Size:      $(du -sh "$CONFIG_DIR" | cut -f1)"
    
    local backup_count=$(ls -1d "$BACKUP_DIR"/*/ 2>/dev/null | wc -l)
    echo -e "  Backups:   ${CYAN}$backup_count${NC}"
    
    echo -e "\n  ${YELLOW}Ultima instalacion:${NC}"
    cat "$CONFIG_DIR/LAST_INSTALL" 2>/dev/null || echo "  (desconocido)"
    echo ""
}

health_check() {
    if [ -x "$SCRIPT_DIR/validate-config.sh" ]; then
        bash "$SCRIPT_DIR/validate-config.sh"
    elif [ -f "$CONFIG_DIR/opencode.json" ]; then
        echo -e "${YELLOW}⏳ validate-config.sh no encontrado, validacion basica...${NC}"
        python3 -c "import json; json.load(open('$CONFIG_DIR/opencode.json')); print('JSON OK')" 2>/dev/null && \
            echo -e "${GREEN}✓ JSON sintaxis valida${NC}" || \
            echo -e "${RED}✗ JSON invalido${NC}"
    else
        echo -e "${RED}✗ No hay configuracion${NC}"
        exit 1
    fi
}

# ── Main ──
case "${1:-help}" in
    backup)   create_backup "$2" ;;
    restore)  restore_backup "$2" ;;
    list)     list_backups ;;
    update)   update_config ;;
    status)   show_status ;;
    health)   health_check ;;
    help|--help|-h) show_help ;;
    *)        echo -e "${RED}Comando desconocido: $1${NC}"; show_help; exit 1 ;;
esac
