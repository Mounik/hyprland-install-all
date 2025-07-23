#!/bin/bash
# Fonctions globales pour l'installation Hyprland Universal

# Couleurs pour l'affichage - avec fallback si tput n'est pas disponible
if command -v tput >/dev/null 2>&1 && [ -n "$TERM" ] && [ "$TERM" != "unknown" ]; then
    OK="$(tput setaf 2)[OK]$(tput sgr0)"
    ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
    NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
    INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
    WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
    CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
    MAGENTA="$(tput setaf 5)"
    ORANGE="$(tput setaf 214)"
    WARNING="$(tput setaf 1)"
    YELLOW="$(tput setaf 3)"
    GREEN="$(tput setaf 2)"
    BLUE="$(tput setaf 4)"
    SKY_BLUE="$(tput setaf 6)"
    RESET="$(tput sgr0)"
else
    # Fallback sans couleurs
    OK="[OK]"
    ERROR="[ERROR]"
    NOTE="[NOTE]"
    INFO="[INFO]"
    WARN="[WARN]"
    CAT="[ACTION]"
    MAGENTA=""
    ORANGE=""
    WARNING=""
    YELLOW=""
    GREEN=""
    BLUE=""
    SKY_BLUE=""
    RESET=""
fi

# Créer le dossier de logs
create_log_directory() {
    if [ ! -d "Install-Logs" ]; then
        mkdir -p Install-Logs
    fi
    LOG="Install-Logs/hyprland-universal-$(date +%d-%H%M%S).log"
}

# Fonction d'affichage de progression
show_progress() {
    local pid=$1
    local package_name=$2
    local spin_chars=("●○○○○○○○○○" "○●○○○○○○○○" "○○●○○○○○○○" "○○○●○○○○○○" "○○○○●○○○○" \
                      "○○○○○●○○○○" "○○○○○○●○○○" "○○○○○○○●○○" "○○○○○○○○●○" "○○○○○○○○○●") 
    local i=0

    tput civis 
    printf "\r${NOTE} Installation ${YELLOW}%s${RESET} ..." "$package_name"

    while ps -p $pid &> /dev/null; do
        printf "\r${NOTE} Installation ${YELLOW}%s${RESET} %s" "$package_name" "${spin_chars[i]}"
        i=$(( (i + 1) % 10 ))  
        sleep 0.3  
    done

    printf "\r${NOTE} Installation ${YELLOW}%s${RESET} ... Done!%-20s \n" "$package_name" ""
    tput cnorm  
}

# Fonction pour vérifier si un paquet est installé
is_package_installed() {
    local package=$1
    case $DISTRO_ID in
        "arch"|"manjaro")
            pacman -Q "$package" &>/dev/null
            ;;
        "ubuntu"|"debian"|"pop")
            dpkg -l | grep -q -w "$package"
            ;;
        "fedora"|"centos"|"rhel")
            rpm -q "$package" &>/dev/null
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed")
            zypper se -i "$package" &>/dev/null
            ;;
        *)
            echo "${ERROR} Distribution non supportée: $DISTRO_ID"
            return 1
            ;;
    esac
}

# Fonction pour installer un paquet
install_package() {
    local package=$1
    local display_name=${2:-$package}
    
    if is_package_installed "$package"; then
        echo "${OK} $display_name est déjà installé"
        return 0
    fi
    
    echo "${NOTE} Installation de $display_name..." | tee -a "$LOG"
    
    case $DISTRO_ID in
        "arch"|"manjaro")
            sudo pacman -S --noconfirm "$package" >> "$LOG" 2>&1 &
            ;;
        "ubuntu"|"debian"|"pop")
            sudo apt install -y "$package" >> "$LOG" 2>&1 &
            ;;
        "fedora"|"centos"|"rhel")
            sudo dnf install -y "$package" >> "$LOG" 2>&1 &
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed")
            sudo zypper in -y "$package" >> "$LOG" 2>&1 &
            ;;
        *)
            echo "${ERROR} Distribution non supportée: $DISTRO_ID" | tee -a "$LOG"
            return 1
            ;;
    esac
    
    local pid=$!
    show_progress $pid "$display_name"
    wait $pid
    
    if [ $? -eq 0 ]; then
        echo "${OK} $display_name installé avec succès" | tee -a "$LOG"
        return 0
    else
        echo "${ERROR} Échec de l'installation de $display_name" | tee -a "$LOG"
        return 1
    fi
}

# Fonction pour installer plusieurs paquets
install_packages() {
    local packages=("$@")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        if ! install_package "$package"; then
            failed_packages+=("$package")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        echo "${WARN} Paquets échoués: ${failed_packages[*]}" | tee -a "$LOG"
        return 1
    fi
    
    return 0
}

# Fonction pour désinstaller un paquet
uninstall_package() {
    local package=$1
    local display_name=${2:-$package}
    
    if ! is_package_installed "$package"; then
        echo "${NOTE} $display_name n'est pas installé"
        return 0
    fi
    
    echo "${NOTE} Désinstallation de $display_name..." | tee -a "$LOG"
    
    case $DISTRO_ID in
        "arch"|"manjaro")
            sudo pacman -Rns --noconfirm "$package" >> "$LOG" 2>&1
            ;;
        "ubuntu"|"debian"|"pop")
            sudo apt remove -y "$package" >> "$LOG" 2>&1
            ;;
        "fedora"|"centos"|"rhel")
            sudo dnf remove -y "$package" >> "$LOG" 2>&1
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed")
            sudo zypper rm -y "$package" >> "$LOG" 2>&1
            ;;
        *)
            echo "${ERROR} Distribution non supportée: $DISTRO_ID" | tee -a "$LOG"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo "${OK} $display_name désinstallé avec succès" | tee -a "$LOG"
        return 0
    else
        echo "${ERROR} Échec de la désinstallation de $display_name" | tee -a "$LOG"
        return 1
    fi
}

# Fonction pour exécuter un module d'installation
execute_module() {
    local module_name=$1
    local module_script="$SCRIPTS_DIR/$module_name.sh"
    
    if [ -f "$module_script" ]; then
        echo "${CAT} Exécution du module: $module_name" | tee -a "$LOG"
        source "$module_script"
        
        if [ $? -eq 0 ]; then
            echo "${OK} Module $module_name terminé avec succès" | tee -a "$LOG"
        else
            echo "${ERROR} Échec du module $module_name" | tee -a "$LOG"
            return 1
        fi
    else
        echo "${ERROR} Module non trouvé: $module_script" | tee -a "$LOG"
        return 1
    fi
}

# Fonction pour détecter NVIDIA
detect_nvidia() {
    if lspci | grep -i "nvidia" &>/dev/null; then
        echo "${INFO} GPU NVIDIA détecté"
        return 0
    else
        return 1
    fi
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    echo "${NOTE} Vérification des prérequis..."
    
    # Vérifier la connexion internet
    if ! ping -c 1 google.com &>/dev/null; then
        echo "${ERROR} Connexion internet requise" | tee -a "$LOG"
        exit 1
    fi
    
    # Vérifier sudo
    if ! sudo -n true 2>/dev/null; then
        echo "${NOTE} Droits sudo requis. Entrez votre mot de passe:"
        sudo true
    fi
    
    # Mettre à jour les repos
    update_repositories
    
    # Installer les dépendances de base pour l'installateur
    install_base_dependencies
}

# Fonction pour mettre à jour les dépôts
update_repositories() {
    echo "${NOTE} Mise à jour des dépôts..." | tee -a "$LOG"
    
    case $DISTRO_ID in
        "arch"|"manjaro")
            sudo pacman -Sy >> "$LOG" 2>&1
            ;;
        "ubuntu"|"debian"|"pop")
            sudo apt update >> "$LOG" 2>&1
            ;;
        "fedora"|"centos"|"rhel")
            sudo dnf check-update >> "$LOG" 2>&1 || true
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed")
            sudo zypper refresh >> "$LOG" 2>&1
            ;;
    esac
    
    echo "${OK} Dépôts mis à jour" | tee -a "$LOG"
}

# Fonction pour installer les dépendances de base de l'installateur
install_base_dependencies() {
    local base_deps=()
    
    case $DISTRO_ID in
        "arch"|"manjaro")
            base_deps=("base-devel" "git" "wget" "curl")
            ;;
        "ubuntu"|"debian"|"pop")
            base_deps=("build-essential" "git" "wget" "curl")
            ;;
        "fedora"|"centos"|"rhel")
            base_deps=("@development-tools" "git" "wget" "curl")
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed")
            base_deps=("patterns-devel-base-devel_basis" "git" "wget" "curl")
            ;;
    esac
    
    install_packages "${base_deps[@]}"
}

# Initialiser le système de logs
create_log_directory

echo "${OK} Fonctions globales chargées" | tee -a "${LOG:-/dev/null}"