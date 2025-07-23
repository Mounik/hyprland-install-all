#!/bin/bash
# Interface utilisateur pour Hyprland Universal

# Variables de sélection globales
INSTALL_BASE="true"
INSTALL_HYPRLAND="true"
INSTALL_FONTS="true"
INSTALL_THEMES="true"
INSTALL_SDDM="true"
INSTALL_WAYBAR="true"
INSTALL_APPS="true"

# Fonction pour afficher le menu principal
show_main_menu() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 HYPRLAND UNIVERSAL INSTALLER                 ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║ Distribution détectée: $DISTRO_NAME                            "
    echo "║ Version: $DISTRO_VERSION                                      "
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Vérifier si whiptail est disponible
    if command -v whiptail &>/dev/null; then
        show_whiptail_menu
    else
        # Fallback vers menu texte
        show_text_menu
    fi
}

# Interface avec whiptail (plus jolie)
show_whiptail_menu() {
    # Installation de whiptail si nécessaire
    if ! command -v whiptail &>/dev/null; then
        echo "${NOTE} Installation de whiptail pour l'interface..."
        case $DISTRO_FAMILY in
            "arch") sudo pacman -S --noconfirm libnewt ;;
            "debian") sudo apt install -y whiptail ;;
            "redhat") sudo dnf install -y newt ;;
            "suse") sudo zypper in -y newt ;;
        esac
    fi
    
    # Menu de sélection des composants
    local options=(
        "base" "Dépendances de base" ON
        "hyprland" "Hyprland Window Manager" ON
        "fonts" "Polices (Nerd Fonts)" ON
        "themes" "Thèmes GTK et icônes" ON
        "sddm" "Gestionnaire de connexion SDDM" ON
        "waybar" "Barre de statut Waybar" ON
        "apps" "Applications essentielles" ON
        "nvidia" "Configuration NVIDIA (auto-détecté)" OFF
    )
    
    local choices
    choices=$(whiptail --title "Sélection des Composants" \
        --checklist "Choisissez les composants à installer:" \
        20 70 10 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        # Parser les choix
        parse_selections "$choices"
        
        # Menu de configuration avancée
        show_advanced_menu
        
        # Confirmation finale
        show_confirmation_menu
    else
        echo "${NOTE} Installation annulée par l'utilisateur"
        exit 0
    fi
}

# Interface texte de fallback
show_text_menu() {
    echo "${INFO} Sélection des composants à installer:"
    echo ""
    echo "Composants disponibles:"
    echo "1. ✓ Dépendances de base (requis)"
    echo "2. ✓ Hyprland Window Manager (requis)"
    echo "3. ? Polices (Nerd Fonts)"
    echo "4. ? Thèmes GTK et icônes" 
    echo "5. ? Gestionnaire de connexion SDDM"
    echo "6. ? Waybar (barre de statut)"
    echo "7. ? Applications essentielles"
    echo ""
    
    # Configuration NVIDIA
    if detect_nvidia; then
        echo "${INFO} GPU NVIDIA détecté, configuration automatique activée"
    fi
    
    echo "Appuyez sur Entrée pour une installation complète avec les paramètres par défaut,"
    echo "ou tapez 'custom' pour une sélection personnalisée:"
    
    read -r choice
    
    if [[ "$choice" == "custom" ]]; then
        show_custom_selection
    else
        echo "${OK} Installation complète sélectionnée"
    fi
}

# Sélection personnalisée en mode texte
show_custom_selection() {
    echo ""
    echo "${NOTE} Sélection personnalisée des composants:"
    
    ask_yes_no "Installer les polices Nerd Fonts?" INSTALL_FONTS
    ask_yes_no "Installer les thèmes GTK?" INSTALL_THEMES
    ask_yes_no "Installer SDDM (gestionnaire de connexion)?" INSTALL_SDDM
    ask_yes_no "Installer Waybar (barre de statut)?" INSTALL_WAYBAR
    ask_yes_no "Installer les applications essentielles?" INSTALL_APPS
}

# Fonction pour poser une question oui/non
ask_yes_no() {
    local question="$1"
    local var_name="$2"
    local default_value="${!var_name}"
    
    if [[ "$default_value" == "true" ]]; then
        local prompt="$question [Y/n]: "
    else
        local prompt="$question [y/N]: "
    fi
    
    read -p "$prompt" -n 1 -r response
    echo
    
    case $response in
        [Yy]) declare -g "$var_name"="true" ;;
        [Nn]) declare -g "$var_name"="false" ;;
        "") ;; # Garder la valeur par défaut
        *) ask_yes_no "$question" "$var_name" ;; # Redemander
    esac
}

# Parser les sélections whiptail
parse_selections() {
    local selections="$1"
    
    # Réinitialiser toutes les options à false
    INSTALL_BASE="true"  # Toujours true
    INSTALL_HYPRLAND="true"  # Toujours true
    INSTALL_FONTS="false"
    INSTALL_THEMES="false"
    INSTALL_SDDM="false"
    INSTALL_WAYBAR="false"
    INSTALL_APPS="false"
    
    # Parser les sélections
    for selection in $selections; do
        case ${selection//\"/} in  # Supprimer les guillemets
            "fonts") INSTALL_FONTS="true" ;;
            "themes") INSTALL_THEMES="true" ;;
            "sddm") INSTALL_SDDM="true" ;;
            "waybar") INSTALL_WAYBAR="true" ;;
            "apps") INSTALL_APPS="true" ;;
        esac
    done
}

# Menu de configuration avancée
show_advanced_menu() {
    if ! command -v whiptail &>/dev/null; then
        return 0  # Skip si whiptail n'est pas disponible
    fi
    
    local advanced_choice
    advanced_choice=$(whiptail --title "Configuration Avancée" \
        --menu "Options avancées:" \
        15 60 5 \
        "1" "Configuration par défaut (recommandé)" \
        "2" "Personnaliser les thèmes" \
        "3" "Sélectionner les applications" \
        "4" "Configuration développeur" \
        "5" "Continuer sans options avancées" \
        3>&1 1>&2 2>&3)
    
    case $advanced_choice in
        1) 
            echo "${OK} Configuration par défaut sélectionnée"
            ;;
        2)
            show_theme_selection
            ;;
        3)
            show_app_selection  
            ;;
        4)
            show_developer_options
            ;;
        5|*)
            echo "${NOTE} Options avancées ignorées"
            ;;
    esac
}

# Sélection de thèmes
show_theme_selection() {
    local theme_choice
    theme_choice=$(whiptail --title "Sélection de Thème" \
        --radiolist "Choisissez un thème principal:" \
        15 60 5 \
        "dracula" "Dracula (par défaut)" ON \
        "nord" "Nord" OFF \
        "catppuccin" "Catppuccin" OFF \
        "gruvbox" "Gruvbox" OFF \
        "tokyo-night" "Tokyo Night" OFF \
        3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        SELECTED_THEME="$theme_choice"
        echo "${OK} Thème sélectionné: $SELECTED_THEME"
    fi
}

# Sélection d'applications
show_app_selection() {
    local app_options=(
        "terminal" "Terminal (Alacritty)" ON
        "browser" "Navigateur (Chromium)" ON
        "editor" "Éditeur (Neovim + VSCode)" ON
        "files" "Gestionnaire de fichiers (Thunar)" ON
        "media" "Lecteur multimédia (mpv)" ON
        "communication" "Apps communication (Discord, Telegram)" OFF
        "productivity" "Productivité (LibreOffice, Obsidian)" OFF
        "development" "Outils développement (Docker, Git)" ON
    )
    
    local app_choices
    app_choices=$(whiptail --title "Sélection d'Applications" \
        --checklist "Choisissez les applications à installer:" \
        20 70 10 \
        "${app_options[@]}" \
        3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        SELECTED_APPS="$app_choices"
        echo "${OK} Applications sélectionnées"
    fi
}

# Options développeur
show_developer_options() {
    local dev_options=(
        "python" "Environnement Python (UV)" ON
        "nodejs" "Node.js et npm" OFF
        "rust" "Rust et Cargo" OFF
        "go" "Go language" OFF
        "docker" "Docker et Docker Compose" ON
        "terraform" "OpenTofu (Terraform)" ON
        "ansible" "Ansible" OFF
        "kubernetes" "Kubectl et outils K8s" OFF
    )
    
    local dev_choices
    dev_choices=$(whiptail --title "Outils de Développement" \
        --checklist "Sélectionnez les outils de développement:" \
        20 70 10 \
        "${dev_options[@]}" \
        3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        SELECTED_DEV_TOOLS="$dev_choices"
        echo "${OK} Outils de développement sélectionnés"
    fi
}

# Menu de confirmation finale
show_confirmation_menu() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      RÉCAPITULATIF                          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║ Distribution: $DISTRO_NAME ($DISTRO_VERSION)"
    echo "║ "
    echo "║ Composants à installer:"
    [[ "$INSTALL_BASE" == "true" ]] && echo "║ ✓ Dépendances de base"
    [[ "$INSTALL_HYPRLAND" == "true" ]] && echo "║ ✓ Hyprland Window Manager"
    [[ "$INSTALL_FONTS" == "true" ]] && echo "║ ✓ Polices Nerd Fonts"
    [[ "$INSTALL_THEMES" == "true" ]] && echo "║ ✓ Thèmes GTK"
    [[ "$INSTALL_SDDM" == "true" ]] && echo "║ ✓ Gestionnaire SDDM"
    [[ "$INSTALL_WAYBAR" == "true" ]] && echo "║ ✓ Waybar"
    [[ "$INSTALL_APPS" == "true" ]] && echo "║ ✓ Applications essentielles"
    
    if detect_nvidia; then
        echo "║ ✓ Configuration NVIDIA (auto-détecté)"
    fi
    
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    read -p "Continuer avec cette configuration? [Y/n]: " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "${OK} Installation confirmée!"
        return 0
    else
        echo "${NOTE} Installation annulée"
        exit 0
    fi
}

# Fonction pour afficher la progression globale
show_installation_progress() {
    local current_step=$1
    local total_steps=$2
    local step_description="$3"
    
    local percentage=$((current_step * 100 / total_steps))
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║ Progression: ${percentage}% (${current_step}/${total_steps})"
    echo "║ Étape: $step_description"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

# Fonction pour calculer le nombre total d'étapes
calculate_total_steps() {
    local total=2  # Base + final
    
    [[ "$INSTALL_HYPRLAND" == "true" ]] && ((total++))
    [[ "$INSTALL_FONTS" == "true" ]] && ((total++))
    [[ "$INSTALL_THEMES" == "true" ]] && ((total++))
    [[ "$INSTALL_SDDM" == "true" ]] && ((total++))
    [[ "$INSTALL_WAYBAR" == "true" ]] && ((total++))
    [[ "$INSTALL_APPS" == "true" ]] && ((total++))
    
    if detect_nvidia; then
        ((total++))
    fi
    
    echo $total
}

echo "${OK} Module d'interface utilisateur chargé" | tee -a "${LOG:-/dev/null}"