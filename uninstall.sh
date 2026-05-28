#!/bin/bash
# uninstall.sh — Remueve OpenCode Config del sistema con backup previo
set -e

CONFIG_DIR="${HOME}/.config/opencode"
BACKUP_DIR="${HOME}/.config/opencode.backups"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  🗑️  OpenCode Config — Uninstall${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}No hay configuracion que remover en:${NC}"
    echo "  $CONFIG_DIR"
    exit 0
fi

# ── Confirm ──
echo -e "${YELLOW}⚠  Esto ELIMINARA permanentemente:${NC}"
echo -e "  ${CYAN}$CONFIG_DIR${NC}"
echo ""
echo -e "${YELLOW}Se creara backup automatico antes de eliminar.${NC}"
echo ""
read -p "¿Continuar? (s/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[sS]$ ]]; then
    echo -e "${GREEN}Cancelado. No se realizaron cambios.${NC}"
    exit 0
fi

# ── Backup ──
echo ""
echo -e "${YELLOW}📦 Creando backup...${NC}"
mkdir -p "$BACKUP_DIR"
BACKUP_PATH="$BACKUP_DIR/pre-uninstall-$BACKUP_TIMESTAMP"
cp -r "$CONFIG_DIR" "$BACKUP_PATH"
echo -e "${GREEN}✓ Backup: $BACKUP_PATH${NC}"

# ── Remove ──
echo -e "${YELLOW}🗑️  Eliminando $CONFIG_DIR...${NC}"
rm -rf "$CONFIG_DIR"
echo -e "${GREEN}✓ Eliminado${NC}"

# Check if anything remains
if [ -d "$CONFIG_DIR" ]; then
    echo -e "${RED}⚠ No se pudo eliminar completamente. Revisa permisos:${NC}"
    echo "  ls -la $CONFIG_DIR"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ OpenCode Config removido exitosamente${NC}"
echo ""
echo -e "${CYAN}Para restaurar:${NC}"
echo -e "  cp -r $BACKUP_PATH ${HOME}/.config/opencode"
echo ""
echo -e "${CYAN}Para reinstalar:${NC}"
echo -e "  curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash"
echo ""
