#!/bin/bash
# Correspondance des noms de paquets entre distributions

# Tables de correspondance des paquets
declare -A PACKAGE_MAP

# Fonction pour initialiser les correspondances de paquets
init_package_mapping() {
    # Paquets de base système
    PACKAGE_MAP["base_devel,arch"]="base-devel"
    PACKAGE_MAP["base_devel,debian"]="build-essential"
    PACKAGE_MAP["base_devel,redhat"]="@development-tools"
    PACKAGE_MAP["base_devel,suse"]="patterns-devel-base-devel_basis"
    
    # Git
    PACKAGE_MAP["git,arch"]="git"
    PACKAGE_MAP["git,debian"]="git"
    PACKAGE_MAP["git,redhat"]="git"
    PACKAGE_MAP["git,suse"]="git"
    
    # Wget
    PACKAGE_MAP["wget,arch"]="wget"
    PACKAGE_MAP["wget,debian"]="wget"
    PACKAGE_MAP["wget,redhat"]="wget2"
    PACKAGE_MAP["wget,suse"]="wget"
    
    # ImageMagick
    PACKAGE_MAP["imagemagick,arch"]="imagemagick"
    PACKAGE_MAP["imagemagick,debian"]="imagemagick"
    PACKAGE_MAP["imagemagick,redhat"]="ImageMagick"
    PACKAGE_MAP["imagemagick,suse"]="ImageMagick"
    
    # Python et paquets Python
    PACKAGE_MAP["python,arch"]="python"
    PACKAGE_MAP["python,debian"]="python3"
    PACKAGE_MAP["python,redhat"]="python3"
    PACKAGE_MAP["python,suse"]="python3"
    
    PACKAGE_MAP["python_requests,arch"]="python-requests"
    PACKAGE_MAP["python_requests,debian"]="python3-requests"
    PACKAGE_MAP["python_requests,redhat"]="python3-requests"
    PACKAGE_MAP["python_requests,suse"]="python3-requests"
    
    # Hyprland et composants Wayland
    PACKAGE_MAP["hyprland,arch"]="hyprland"
    PACKAGE_MAP["hyprland,debian"]="hyprland"
    PACKAGE_MAP["hyprland,redhat"]="hyprland"
    PACKAGE_MAP["hyprland,suse"]="hyprland"
    
    PACKAGE_MAP["waybar,arch"]="waybar"
    PACKAGE_MAP["waybar,debian"]="waybar"
    PACKAGE_MAP["waybar,redhat"]="waybar"
    PACKAGE_MAP["waybar,suse"]="waybar"
    
    PACKAGE_MAP["wofi,arch"]="wofi"
    PACKAGE_MAP["wofi,debian"]="wofi"
    PACKAGE_MAP["wofi,redhat"]="wofi"
    PACKAGE_MAP["wofi,suse"]="wofi"
    
    # Terminal et shell
    PACKAGE_MAP["alacritty,arch"]="alacritty"
    PACKAGE_MAP["alacritty,debian"]="alacritty"
    PACKAGE_MAP["alacritty,redhat"]="alacritty"
    PACKAGE_MAP["alacritty,suse"]="alacritty"
    
    PACKAGE_MAP["zsh,arch"]="zsh"
    PACKAGE_MAP["zsh,debian"]="zsh"
    PACKAGE_MAP["zsh,redhat"]="zsh"
    PACKAGE_MAP["zsh,suse"]="zsh"
    
    # Polices
    PACKAGE_MAP["nerd_fonts,arch"]="ttf-jetbrains-mono-nerd"
    PACKAGE_MAP["nerd_fonts,debian"]="fonts-jetbrains-mono"
    PACKAGE_MAP["nerd_fonts,redhat"]="jetbrains-mono-fonts"
    PACKAGE_MAP["nerd_fonts,suse"]="jetbrains-mono-fonts"
    
    # Thèmes et apparence
    PACKAGE_MAP["kvantum,arch"]="kvantum"
    PACKAGE_MAP["kvantum,debian"]="qt5-style-kvantum"
    PACKAGE_MAP["kvantum,redhat"]="kvantum"
    PACKAGE_MAP["kvantum,suse"]="kvantum-qt5"
    
    # Gestionnaire de connexion
    PACKAGE_MAP["sddm,arch"]="sddm"
    PACKAGE_MAP["sddm,debian"]="sddm"
    PACKAGE_MAP["sddm,redhat"]="sddm"
    PACKAGE_MAP["sddm,suse"]="sddm"
    
    # Gestionnaire de fichiers
    PACKAGE_MAP["thunar,arch"]="thunar"
    PACKAGE_MAP["thunar,debian"]="thunar"
    PACKAGE_MAP["thunar,redhat"]="thunar"
    PACKAGE_MAP["thunar,suse"]="thunar"
    
    # Audio
    PACKAGE_MAP["pipewire,arch"]="pipewire pipewire-pulse pipewire-alsa"
    PACKAGE_MAP["pipewire,debian"]="pipewire pipewire-pulse pipewire-alsa"
    PACKAGE_MAP["pipewire,redhat"]="pipewire pipewire-pulseaudio pipewire-alsa"
    PACKAGE_MAP["pipewire,suse"]="pipewire pipewire-pulseaudio pipewire-alsa"
    
    # NVIDIA
    PACKAGE_MAP["nvidia,arch"]="nvidia-dkms nvidia-utils nvidia-settings"
    PACKAGE_MAP["nvidia,debian"]="nvidia-driver nvidia-settings"
    PACKAGE_MAP["nvidia,redhat"]="akmod-nvidia xorg-x11-drv-nvidia-cuda"
    PACKAGE_MAP["nvidia,suse"]="nvidia-video-G06 nvidia-gl-G06 nvidia-utils-G06"
    
    # Notifications
    PACKAGE_MAP["notifications,arch"]="swaync"
    PACKAGE_MAP["notifications,debian"]="sway-notification-center"
    PACKAGE_MAP["notifications,redhat"]="swaync"
    PACKAGE_MAP["notifications,suse"]="swaync"
    
    # Screenshots
    PACKAGE_MAP["screenshot,arch"]="grim slurp"
    PACKAGE_MAP["screenshot,debian"]="grim slurp"
    PACKAGE_MAP["screenshot,redhat"]="grim slurp"
    PACKAGE_MAP["screenshot,suse"]="grim slurp"
    
    # Éditeurs
    PACKAGE_MAP["neovim,arch"]="neovim"
    PACKAGE_MAP["neovim,debian"]="neovim"
    PACKAGE_MAP["neovim,redhat"]="neovim"
    PACKAGE_MAP["neovim,suse"]="neovim"
    
    PACKAGE_MAP["vscode,arch"]="code"
    PACKAGE_MAP["vscode,debian"]="code"
    PACKAGE_MAP["vscode,redhat"]="code"
    PACKAGE_MAP["vscode,suse"]="code"
    
    # Outils système
    PACKAGE_MAP["btop,arch"]="btop"
    PACKAGE_MAP["btop,debian"]="btop"
    PACKAGE_MAP["btop,redhat"]="btop"
    PACKAGE_MAP["btop,suse"]="btop"
    
    PACKAGE_MAP["fastfetch,arch"]="fastfetch"
    PACKAGE_MAP["fastfetch,debian"]="fastfetch"
    PACKAGE_MAP["fastfetch,redhat"]="fastfetch"
    PACKAGE_MAP["fastfetch,suse"]="fastfetch"
    
    # Applications multimédia
    PACKAGE_MAP["mpv,arch"]="mpv"
    PACKAGE_MAP["mpv,debian"]="mpv"
    PACKAGE_MAP["mpv,redhat"]="mpv"
    PACKAGE_MAP["mpv,suse"]="mpv"
    
    # Navigateurs
    PACKAGE_MAP["chromium,arch"]="chromium"
    PACKAGE_MAP["chromium,debian"]="chromium"
    PACKAGE_MAP["chromium,redhat"]="chromium"
    PACKAGE_MAP["chromium,suse"]="chromium"
    
    PACKAGE_MAP["firefox,arch"]="firefox"
    PACKAGE_MAP["firefox,debian"]="firefox"
    PACKAGE_MAP["firefox,redhat"]="firefox"
    PACKAGE_MAP["firefox,suse"]="firefox"
}

# Fonction pour obtenir le nom de paquet pour la distribution actuelle
get_package_name() {
    local generic_name=$1
    local key="${generic_name},${DISTRO_FAMILY}"
    
    if [[ -n "${PACKAGE_MAP[$key]}" ]]; then
        echo "${PACKAGE_MAP[$key]}"
    else
        # Fallback: retourner le nom générique si pas de correspondance
        echo "$generic_name"
    fi
}

# Fonction pour obtenir une liste de paquets pour la distribution
get_package_list() {
    local generic_names=("$@")
    local result=()
    
    for name in "${generic_names[@]}"; do
        local mapped_name=$(get_package_name "$name")
        if [[ -n "$mapped_name" ]]; then
            # Séparer les paquets multiples si ils sont dans une chaîne
            IFS=' ' read -ra packages <<< "$mapped_name"
            result+=("${packages[@]}")
        fi
    done
    
    echo "${result[@]}"
}

# Fonction pour vérifier si un paquet générique existe pour la distribution
package_exists_for_distro() {
    local generic_name=$1
    local key="${generic_name},${DISTRO_FAMILY}"
    
    [[ -n "${PACKAGE_MAP[$key]}" ]]
}

# Fonction pour lister tous les paquets disponibles pour une famille de distribution
list_packages_for_distro() {
    local family=${1:-$DISTRO_FAMILY}
    
    echo "${INFO} Paquets disponibles pour la famille $family:"
    for key in "${!PACKAGE_MAP[@]}"; do
        if [[ $key == *",$family" ]]; then
            local generic_name=${key%,*}
            local package_name=${PACKAGE_MAP[$key]}
            echo "  $generic_name -> $package_name"
        fi
    done
}

# Fonction pour valider la correspondance des paquets
validate_package_mapping() {
    local errors=0
    
    echo "${NOTE} Validation des correspondances de paquets..."
    
    # Vérifier que tous les paquets de base sont définis
    local base_packages=("base_devel" "git" "wget" "python" "hyprland" "waybar" "alacritty" "zsh")
    
    for package in "${base_packages[@]}"; do
        if ! package_exists_for_distro "$package"; then
            echo "${ERROR} Paquet $package non défini pour $DISTRO_FAMILY"
            ((errors++))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        echo "${OK} Toutes les correspondances de paquets sont valides"
        return 0
    else
        echo "${ERROR} $errors erreurs dans les correspondances"
        return 1
    fi
}

# Fonction pour ajouter des correspondances personnalisées
add_custom_mapping() {
    local generic_name=$1
    local family=$2
    local package_name=$3
    
    PACKAGE_MAP["${generic_name},${family}"]="$package_name"
    echo "${OK} Correspondance ajoutée: $generic_name -> $package_name ($family)"
}

# Initialiser les correspondances
init_package_mapping

echo "${OK} Module de correspondance des paquets chargé" | tee -a "${LOG:-/dev/null}"