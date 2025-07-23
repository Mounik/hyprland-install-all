#!/bin/bash
# Gestionnaire de paquets unifié pour toutes les distributions

# Variables globales
PACKAGE_MANAGER=""
AUR_HELPER=""

# Fonction d'initialisation du gestionnaire de paquets
init_package_manager() {
    case $DISTRO_FAMILY in
        "arch")
            PACKAGE_MANAGER="pacman"
            detect_aur_helper
            ;;
        "debian")
            PACKAGE_MANAGER="apt"
            ;;
        "redhat")
            PACKAGE_MANAGER="dnf"
            ;;
        "suse")
            PACKAGE_MANAGER="zypper"
            ;;
        *)
            echo "${ERROR} Famille de distribution non supportée: $DISTRO_FAMILY" | tee -a "$LOG"
            exit 1
            ;;
    esac
    
    echo "${OK} Gestionnaire de paquets: $PACKAGE_MANAGER" | tee -a "$LOG"
    
    # Initialiser les dépôts spéciaux si nécessaire
    setup_special_repositories
}

# Détecter l'helper AUR pour Arch
detect_aur_helper() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        echo "${NOTE} Aucun helper AUR détecté, installation de yay..." | tee -a "$LOG"
        install_yay
    fi
    
    if [[ -n "$AUR_HELPER" ]]; then
        echo "${OK} Helper AUR: $AUR_HELPER" | tee -a "$LOG"
    fi
}

# Installer yay pour Arch
install_yay() {
    echo "${NOTE} Installation de yay..." | tee -a "$LOG"
    
    # Cloner et compiler yay
    cd /tmp
    git clone https://aur.archlinux.org/yay.git >> "$LOG" 2>&1
    cd yay
    makepkg -si --noconfirm >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        AUR_HELPER="yay"
        echo "${OK} yay installé avec succès" | tee -a "$LOG"
    else
        echo "${ERROR} Échec de l'installation de yay" | tee -a "$LOG"
        return 1
    fi
    
    cd - > /dev/null
}

# Configuration des dépôts spéciaux
setup_special_repositories() {
    case $DISTRO_FAMILY in
        "redhat")
            setup_fedora_repos
            ;;
        "suse")
            setup_opensuse_repos
            ;;
        "debian")
            setup_debian_repos
            ;;
    esac
}

# Configuration des dépôts Fedora
setup_fedora_repos() {
    if [[ $DISTRO_ID == "fedora" ]]; then
        echo "${NOTE} Configuration des dépôts Fedora..." | tee -a "$LOG"
        
        # Activer RPM Fusion
        if ! dnf repolist | grep -q rpmfusion; then
            echo "${NOTE} Installation de RPM Fusion..." | tee -a "$LOG"
            sudo dnf install -y \
                https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
                >> "$LOG" 2>&1
        fi
        
        # Installer dnf-plugins-core pour COPR
        if ! dnf list installed dnf-plugins-core &>/dev/null; then
            echo "${NOTE} Installation de dnf-plugins-core..." | tee -a "$LOG"
            sudo dnf install -y dnf-plugins-core >> "$LOG" 2>&1
        fi
        
        # Ajouter des COPRs nécessaires
        local coprs=("solopasha/hyprland" "atim/lazygit")
        for copr in "${coprs[@]}"; do
            if ! dnf copr list | grep -q "$copr"; then
                echo "${NOTE} Ajout du COPR: $copr" | tee -a "$LOG"
                sudo dnf copr enable -y "$copr" >> "$LOG" 2>&1
            fi
        done
    fi
}

# Configuration des dépôts OpenSuse
setup_opensuse_repos() {
    echo "${NOTE} Configuration des dépôts OpenSuse..." | tee -a "$LOG"
    
    # Ajouter le dépôt Packman
    if ! zypper lr | grep -q packman; then
        echo "${NOTE} Ajout du dépôt Packman..." | tee -a "$LOG"
        sudo zypper ar -f http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman >> "$LOG" 2>&1
        sudo zypper refresh >> "$LOG" 2>&1
    fi
    
    # Ajouter le dépôt home:X0rg pour les outils Hyprland
    if ! zypper lr | grep -q "home:X0rg"; then
        echo "${NOTE} Ajout du dépôt home:X0rg..." | tee -a "$LOG"
        sudo zypper ar -f https://download.opensuse.org/repositories/home:X0rg/openSUSE_Tumbleweed/ home-X0rg >> "$LOG" 2>&1
        sudo zypper refresh >> "$LOG" 2>&1
    fi
}

# Configuration des dépôts Debian/Ubuntu
setup_debian_repos() {
    case $DISTRO_ID in
        "ubuntu")
            # Activer universe et multiverse
            sudo add-apt-repository universe >> "$LOG" 2>&1
            sudo add-apt-repository multiverse >> "$LOG" 2>&1
            ;;
        "debian")
            # Vérifier les sources contrib et non-free
            if [ -f /etc/apt/sources.list ]; then
                if ! grep -q "contrib" /etc/apt/sources.list; then
                    echo "${NOTE} Ajout des dépôts contrib et non-free..." | tee -a "$LOG"
                    sudo sed -i 's/main$/main contrib non-free/' /etc/apt/sources.list
                fi
            else
                # Debian 12+ utilise sources.list.d/
                echo "${NOTE} Configuration des dépôts Debian moderne..." | tee -a "$LOG"
                echo "deb http://deb.debian.org/debian bookworm main contrib non-free" | sudo tee /etc/apt/sources.list.d/main.list > /dev/null
            fi
            ;;
    esac
    
    # Ajouter des PPAs nécessaires pour Ubuntu
    if [[ $DISTRO_ID == "ubuntu" ]]; then
        local ppas=()
        # Note: Hyprland n'est pas encore dans les dépôts Ubuntu officiels
        # On utilisera les paquets compilés ou les flatpaks
    fi
}

# Fonction unifiée d'installation de paquets
unified_install() {
    local packages=("$@")
    local aur_packages=()
    local repo_packages=()
    
    # Pour Arch, séparer les paquets AUR des paquets officiels
    if [[ $DISTRO_FAMILY == "arch" ]]; then
        for package in "${packages[@]}"; do
            if is_aur_package "$package"; then
                aur_packages+=("$package")
            else
                repo_packages+=("$package")
            fi
        done
        
        # Installer les paquets officiels
        if [ ${#repo_packages[@]} -gt 0 ]; then
            sudo pacman -S --noconfirm "${repo_packages[@]}" >> "$LOG" 2>&1 &
            local pid=$!
            show_progress $pid "Paquets officiels"
            wait $pid
        fi
        
        # Installer les paquets AUR
        if [ ${#aur_packages[@]} -gt 0 ] && [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -S --noconfirm "${aur_packages[@]}" >> "$LOG" 2>&1 &
            local pid=$!
            show_progress $pid "Paquets AUR"
            wait $pid
        fi
    else
        # Pour les autres distributions
        case $DISTRO_FAMILY in
            "debian")
                sudo apt-get install -y "${packages[@]}" >> "$LOG" 2>&1 &
                ;;
            "redhat")
                sudo dnf install -y "${packages[@]}" >> "$LOG" 2>&1 &
                ;;
            "suse")
                sudo zypper in -y "${packages[@]}" >> "$LOG" 2>&1 &
                ;;
        esac
        
        local pid=$!
        show_progress $pid "Paquets"
        wait $pid
    fi
}

# Vérifier si un paquet est disponible dans AUR
is_aur_package() {
    local package=$1
    
    # Liste des paquets connus comme étant dans AUR
    local aur_packages=("hyprland-git" "waybar-hyprland" "swaync" "hyprpicker" "hyprshot")
    
    for aur_pkg in "${aur_packages[@]}"; do
        if [[ "$package" == "$aur_pkg" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Fonction pour installer des paquets avec fallback
install_with_fallback() {
    local primary_packages=("$@")
    local fallback_packages=()
    
    # Définir des alternatives pour certains paquets
    case $DISTRO_FAMILY in
        "debian")
            # Hyprland n'est pas encore dans les dépôts Debian/Ubuntu
            for package in "${primary_packages[@]}"; do
                case $package in
                    "hyprland")
                        fallback_packages+=("sway")  # Fallback vers Sway
                        ;;
                    *)
                        fallback_packages+=("$package")
                        ;;
                esac
            done
            ;;
        *)
            fallback_packages=("${primary_packages[@]}")
            ;;
    esac
    
    # Tenter l'installation
    if unified_install "${fallback_packages[@]}"; then
        return 0
    else
        echo "${WARN} Échec de l'installation, tentative avec des alternatives..." | tee -a "$LOG"
        # Implémenter la logique de fallback ici
        return 1
    fi
}

# Fonction pour compiler des paquets depuis les sources si nécessaire
compile_from_source() {
    local package=$1
    
    case $package in
        "hyprland")
            compile_hyprland
            ;;
        "waybar")
            compile_waybar
            ;;
        *)
            echo "${ERROR} Compilation depuis les sources non supportée pour $package" | tee -a "$LOG"
            return 1
            ;;
    esac
}

# Compiler Hyprland depuis les sources
compile_hyprland() {
    echo "${NOTE} Compilation de Hyprland depuis les sources..." | tee -a "$LOG"
    
    # Dépendances de compilation
    local build_deps=()
    case $DISTRO_FAMILY in
        "debian")
            build_deps=("meson" "ninja-build" "cmake" "libwayland-dev" "libxkbcommon-dev" 
                        "libpixman-1-dev" "libdrm-dev" "libgtk-3-dev")
            ;;
        "redhat")
            build_deps=("meson" "ninja-build" "cmake" "wayland-devel" "libxkbcommon-devel"
                        "pixman-devel" "libdrm-devel" "gtk3-devel")
            ;;
        "suse")
            build_deps=("meson" "ninja" "cmake" "wayland-devel" "libxkbcommon-devel"
                        "pixman-devel" "libdrm-devel" "gtk3-devel")
            ;;
    esac
    
    # Installer les dépendances
    unified_install "${build_deps[@]}"
    
    # Cloner et compiler
    cd /tmp
    git clone --recursive https://github.com/hyprwm/Hyprland.git >> "$LOG" 2>&1
    cd Hyprland
    make all >> "$LOG" 2>&1
    sudo make install >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "${OK} Hyprland compilé et installé avec succès" | tee -a "$LOG"
        return 0
    else
        echo "${ERROR} Échec de la compilation de Hyprland" | tee -a "$LOG"
        return 1
    fi
}

# Fonction pour installer via Flatpak si disponible
install_flatpak_fallback() {
    local app_id=$1
    
    if command -v flatpak &>/dev/null; then
        echo "${NOTE} Installation via Flatpak: $app_id" | tee -a "$LOG"
        flatpak install -y flathub "$app_id" >> "$LOG" 2>&1
        return $?
    else
        return 1
    fi
}

echo "${OK} Module gestionnaire de paquets chargé" | tee -a "${LOG:-/dev/null}"