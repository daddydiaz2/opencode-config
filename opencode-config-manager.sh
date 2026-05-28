#!/bin/bash
set -e

# OpenCode Config - Safe Update System
# Provides backup before changes and rollback capability

CONFIG_DIR="$HOME/.config/opencode"
BACKUP_DIR="$HOME/.config/opencode.backups"
VERSION_FILE="$BACKUP_DIR/current-version"
MAX_BACKUPS=10

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
OpenCode Config Manager

Usage: $0 [command] [options]

Commands:
    backup              Create backup of current config
    restore [version]   Restore to specific version (or latest)
    list                List available backups
    update              Update to latest from repo
    status              Show current status
    health              Run health checks

Examples:
    $0 backup                    # Backup current config
    $0 restore                   # Restore latest backup
    $0 restore v1.2.0           # Restore specific version
    $0 update                   # Update and auto-backup
    $0 health                   # Check all systems
EOF
}

# Create timestamped backup
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local version="${1:-manual-$timestamp}"
    local backup_path="$BACKUP_DIR/$version"
    
    echo -e "${YELLOW}📦 Creating backup: $version${NC}"
    
    mkdir -p "$BACKUP_DIR"
    
    # Copy config
    if [ -d "$CONFIG_DIR" ]; then
        cp -r "$CONFIG_DIR" "$backup_path"
        echo "$version" > "$VERSION_FILE"
        echo -e "${GREEN}✅ Backup created: $backup_path${NC}"
    else
        echo -e "${RED}❌ Config directory not found: $CONFIG_DIR${NC}"
        exit 1
    fi
    
    # Cleanup old backups
    cleanup_old_backups
}

# Restore from backup
restore_backup() {
    local version="${1:-}"
    
    # If no version specified, use latest
    if [ -z "$version" ]; then
        version=$(ls -1 "$BACKUP_DIR" | sort -r | head -1)
        if [ -z "$version" ]; then
            echo -e "${RED}❌ No backups found${NC}"
            exit 1
        fi
    fi
    
    local backup_path="$BACKUP_DIR/$version"
    
    if [ ! -d "$backup_path" ]; then
        echo -e "${RED}❌ Backup not found: $version${NC}"
        echo "Available backups:"
        list_backups
        exit 1
    fi
    
    echo -e "${YELLOW}🔄 Restoring backup: $version${NC}"
    
    # Create backup of current before restoring
    create_backup "pre-restore-$(date +%Y%m%d_%H%M%S)"
    
    # Restore
    rm -rf "$CONFIG_DIR"
    cp -r "$backup_path" "$CONFIG_DIR"
    
    echo -e "${GREEN}✅ Restored: $version${NC}"
    echo -e "${YELLOW}⚠️  Please restart opencode for changes to take effect${NC}"
}

# List available backups
list_backups() {
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}No backups found${NC}"
        return
    fi
    
    echo -e "${GREEN}📋 Available backups:${NC}"
    ls -1 "$BACKUP_DIR" | sort -r | while read backup; do
        local size=$(du -sh "$BACKUP_DIR/$backup" 2>/dev/null | cut -f1)
        local date=$(echo "$backup" | grep -oP '\d{8}_\d{6}' || echo "N/A")
        echo "  • $backup ($size)"
    done
    
    local current=$(cat "$VERSION_FILE" 2>/dev/null || echo "N/A")
    echo ""
    echo -e "${GREEN}Current: $current${NC}"
}

# Cleanup old backups (keep only MAX_BACKUPS)
cleanup_old_backups() {
    local count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
    if [ "$count" -gt "$MAX_BACKUPS" ]; then
        echo -e "${YELLOW}🧹 Cleaning up old backups (keeping $MAX_BACKUPS)...${NC}"
        ls -1 "$BACKUP_DIR" | sort | head -n -$MAX_BACKUPS | while read old_backup; do
            rm -rf "$BACKUP_DIR/$old_backup"
            echo "  Removed: $old_backup"
        done
    fi
}

# Update from repo
update_config() {
    echo -e "${YELLOW}🔄 Updating OpenCode Config...${NC}"
    
    # Create backup before update
    create_backup "pre-update-$(date +%Y%m%d_%H%M%S)"
    
    # Pull latest
    if [ -d "/tmp/opencode-config" ]; then
        cd /tmp/opencode-config
        git pull origin main
        ./install.sh
    else
        echo -e "${YELLOW}📥 Cloning repo...${NC}"
        git clone https://github.com/daddydiaz2/opencode-config.git /tmp/opencode-config
        cd /tmp/opencode-config
        ./install.sh
    fi
    
    echo -e "${GREEN}✅ Update complete!${NC}"
    echo -e "${YELLOW}If something broke, run: $0 restore${NC}"
}

# Show status
show_status() {
    echo -e "${GREEN}📊 OpenCode Config Status${NC}"
    echo "========================"
    
    # Current version
    local current=$(cat "$VERSION_FILE" 2>/dev/null || echo "N/A")
    echo -e "Current version: ${GREEN}$current${NC}"
    
    # Config directory
    if [ -d "$CONFIG_DIR" ]; then
        local size=$(du -sh "$CONFIG_DIR" 2>/dev/null | cut -f1)
        echo -e "Config size: ${GREEN}$size${NC}"
    fi
    
    # Backups
    local backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
    echo -e "Backups: ${GREEN}$backup_count${NC}"
    
    # LSP Status
    echo ""
    echo -e "${YELLOW}LSP Status:${NC}"
    check_lsp_health
}

# Health checks
check_lsp_health() {
    echo -e "${YELLOW}🏥 Health Check${NC}"
    echo "=============="
    
    local issues=0
    
    # Check opencode binary
    if command -v opencode >/dev/null 2>&1; then
        local version=$(opencode --version 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} OpenCode: $version"
    else
        echo -e "  ${RED}✗${NC} OpenCode not found"
        ((issues++))
    fi
    
    # Check LSPs
    local lsps=("omnisharp" "pyright" "intelephense" "bash-language-server" "typescript-language-server")
    for lsp in "${lsps[@]}"; do
        if command -v "$lsp" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $lsp installed"
        else
            echo -e "  ${RED}✗${NC} $lsp missing"
            ((issues++))
        fi
    done
    
    # Check config files
    if [ -f "$CONFIG_DIR/opencode.json" ]; then
        echo -e "  ${GREEN}✓${NC} Config file exists"
    else
        echo -e "  ${RED}✗${NC} Config file missing"
        ((issues++))
    fi
    
    # Check MCPs
    echo ""
    echo -e "${YELLOW}MCP Status:${NC}"
    opencode mcp list 2>/dev/null | grep -E "^●|^○" | while read line; do
        if echo "$line" | grep -q "✓"; then
            echo -e "  ${GREEN}$line${NC}"
        else
            echo -e "  ${YELLOW}$line${NC}"
        fi
    done
    
    echo ""
    if [ "$issues" -eq 0 ]; then
        echo -e "${GREEN}✅ All systems healthy!${NC}"
    else
        echo -e "${RED}⚠️  $issues issue(s) found${NC}"
        echo -e "${YELLOW}Run: ./setup-lsps.sh to fix missing LSPs${NC}"
    fi
}

# Main
case "${1:-help}" in
    backup)
        create_backup "$2"
        ;;
    restore)
        restore_backup "$2"
        ;;
    list)
        list_backups
        ;;
    update)
        update_config
        ;;
    status)
        show_status
        ;;
    health)
        check_lsp_health
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
