#!/bin/bash
# Test d'installation réelle avec simulation

# Source des fonctions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/global-functions.sh"
source "$SCRIPT_DIR/lib/distro-detection.sh"
source "$SCRIPT_DIR/lib/package-manager.sh"

# Initialiser le logging
create_log_directory

echo "${INFO} Test d'installation réelle Hyprland Universal v1.0.0" | tee -a "$LOG"
echo "${INFO} Simulation d'installation complète..." | tee -a "$LOG"

# Test 1: Détection de distribution
echo "" | tee -a "$LOG"
echo "${NOTE} === Test 1: Détection de distribution ===" | tee -a "$LOG"
detect_distribution
echo "${OK} Distribution détectée: ${DISTRO_NAME} ${DISTRO_VERSION} (${DISTRO_FAMILY})" | tee -a "$LOG"

# Test 2: Initialisation gestionnaire de paquets
echo "" | tee -a "$LOG"
echo "${NOTE} === Test 2: Gestionnaire de paquets ===" | tee -a "$LOG"
init_package_manager
case $DISTRO_FAMILY in
    "arch") PM="pacman" ;;
    "debian") PM="apt" ;;
    "redhat") PM="dnf" ;;
    "suse") PM="zypper" ;;
    *) PM="unknown" ;;
esac
echo "${OK} Gestionnaire: $PM" | tee -a "$LOG"

# Test 3: Test des modules
echo "" | tee -a "$LOG"
echo "${NOTE} === Test 3: Chargement des modules ===" | tee -a "$LOG"

modules=("base-dependencies" "hyprland" "fonts" "audio" "waybar" "applications")
for module in "${modules[@]}"; do
    if [[ -f "$SCRIPT_DIR/scripts/$module.sh" ]]; then
        echo "${OK} Module $module trouvé" | tee -a "$LOG"
        
        # Test de syntaxe
        if bash -n "$SCRIPT_DIR/scripts/$module.sh"; then
            echo "${OK}   Syntaxe correcte" | tee -a "$LOG"
        else
            echo "${ERROR}   Erreur de syntaxe!" | tee -a "$LOG"
        fi
    else
        echo "${ERROR} Module $module manquant!" | tee -a "$LOG"
    fi
done

# Test 4: Simulation installation OpenTofu
echo "" | tee -a "$LOG"
echo "${NOTE} === Test 4: Simulation OpenTofu ===" | tee -a "$LOG"

# Simuler l'installation (sans vraiment installer)
echo "${NOTE} Test du script officiel OpenTofu..." | tee -a "$LOG"
if curl --connect-timeout 5 --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o /dev/null 2>&1; then
    echo "${OK} Script OpenTofu accessible" | tee -a "$LOG"
else
    echo "${WARN} Script OpenTofu inaccessible, utilisation fallback" | tee -a "$LOG"
fi

# Test 5: Simulation Nerd Fonts
echo "" | tee -a "$LOG"
echo "${NOTE} === Test 5: Simulation Nerd Fonts ===" | tee -a "$LOG"
if curl --connect-timeout 5 -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /dev/null 2>&1; then
    echo "${OK} Nerd Fonts accessibles" | tee -a "$LOG"
else
    echo "${WARN} Nerd Fonts inaccessibles" | tee -a "$LOG"
fi

# Test 6: Vérification des dépendances système
echo "" | tee -a "$LOG"
echo "${NOTE} === Test 6: Dépendances système ===" | tee -a "$LOG"

required_commands=("git" "wget" "curl" "unzip")
for cmd in "${required_commands[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        echo "${OK} $cmd disponible" | tee -a "$LOG"
    else
        echo "${ERROR} $cmd manquant!" | tee -a "$LOG"
    fi
done

echo "" | tee -a "$LOG"
echo "${INFO} === RÉSUMÉ DU TEST ===" | tee -a "$LOG"
echo "${OK} Test d'installation terminé" | tee -a "$LOG"
echo "${INFO} Log complet: $LOG" | tee -a "$LOG"

# Afficher les dernières lignes du log
echo "" 
echo "=== DERNIÈRES LIGNES DU LOG ==="
tail -20 "$LOG"