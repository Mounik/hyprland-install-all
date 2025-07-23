#!/bin/bash
# Hyprland Universal Installer
# Support: Arch, Debian, Ubuntu, Fedora, OpenSuse
# https://github.com/Mounik/hyprland-install-all

clear

# Script version
VERSION="1.0.0"

# Chemins relatifs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
CONFIGS_DIR="$SCRIPT_DIR/configs"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Source des librairies
source "$LIB_DIR/global-functions.sh"
source "$LIB_DIR/distro-detection.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/package-mapping.sh"
source "$LIB_DIR/user-interface.sh"

# Vérifications préliminaires
echo "${INFO} Hyprland Universal Installer v${VERSION}"
echo "${INFO} Détection de l'environnement..."

# Vérifier que le script n'est pas exécuté en root
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR} Ce script ne doit ${WARNING}PAS${RESET} être exécuté en root! Exiting..." | tee -a "$LOG"
    exit 1
fi

# Détecter la distribution
detect_distribution
echo "${OK} Distribution détectée: ${DISTRO_NAME} ${DISTRO_VERSION}"

# Initialiser le gestionnaire de paquets
init_package_manager

# Vérifier les prérequis système
check_prerequisites

# Interface utilisateur pour la sélection des composants
show_main_menu

# Installation des composants sélectionnés
echo "${NOTE} Début de l'installation..."

# Calculer le nombre total d'étapes
TOTAL_STEPS=$(calculate_total_steps)
CURRENT_STEP=0

# 1. Installation des dépendances de base
if [[ $INSTALL_BASE == "true" ]]; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Installation des dépendances de base"
    execute_module "base-dependencies"
fi

# 2. Installation Hyprland
if [[ $INSTALL_HYPRLAND == "true" ]]; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Installation de Hyprland"
    execute_module "hyprland"
fi

# 3. Installation des polices
if [[ $INSTALL_FONTS == "true" ]]; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Installation des polices"
    execute_module "fonts"
fi

# 4. Installation des thèmes GTK
if [[ $INSTALL_THEMES == "true" ]]; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Installation des thèmes"
    execute_module "gtk-themes"
fi

# 5. Installation du gestionnaire de connexion
if [[ $INSTALL_SDDM == "true" ]]; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Installation de SDDM"
    execute_module "sddm"
fi

# 6. Installation de Waybar et composants UI
if [[ $INSTALL_WAYBAR == "true" ]]; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Installation de Waybar"
    execute_module "waybar"
fi

# 7. Installation des applications
if [[ $INSTALL_APPS == "true" ]]; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Installation des applications"
    execute_module "applications"
fi

# 8. Configuration NVIDIA si détectée
if detect_nvidia; then
    ((CURRENT_STEP++))
    show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Configuration NVIDIA"
    execute_module "nvidia"
fi

# 9. Configuration audio
((CURRENT_STEP++))
show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Configuration audio"
execute_module "audio"

# 10. Configuration finale et dotfiles
((CURRENT_STEP++))
show_installation_progress $CURRENT_STEP $TOTAL_STEPS "Configuration finale"
execute_module "dotfiles"

# Vérification finale
echo "${NOTE} Vérification de l'installation..."
source "$SCRIPT_DIR/tests/test-runner.sh"
run_all_tests

echo "${OK} Installation terminée!"
echo "${INFO} Redémarrez votre session et sélectionnez Hyprland"
echo "${INFO} Appuyez sur Super + K pour voir tous les raccourcis"

# Proposer un redémarrage
echo "Voulez-vous redémarrer maintenant? (y/N): "
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${NOTE} Redémarrage du système..."
    sudo reboot
fi