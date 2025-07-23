#!/bin/bash
# Installation de Hyprland et composants essentiels

echo "${NOTE} Installation de Hyprland..." | tee -a "$LOG"

# Définir les paquets Hyprland selon la distribution
case $DISTRO_FAMILY in
    "arch")
        hyprland_packages=(
            "hyprland"
            "xdg-desktop-portal-hyprland"
            "polkit-kde-agent"
            "qt5-wayland"
            "qt6-wayland"
        )
        # Utiliser AUR pour certains paquets si disponible
        if [[ -n "$AUR_HELPER" ]]; then
            hyprland_packages+=(
                "hyprpaper"
                "hypridle"
                "hyprlock"
                "hyprpicker"
            )
        fi
        ;;
    "debian")
        # Pour Ubuntu/Debian, essayer d'abord les PPA puis compilation
        hyprland_packages=(
            "xdg-desktop-portal-wlr"
            "polkit-kde-agent-1"
            "qtwayland5"
        )
        
        # Tenter l'installation via PPA pour Ubuntu
        if [[ "$DISTRO_ID" == "ubuntu" ]]; then
            setup_hyprland_ppa_ubuntu
        else
            COMPILE_HYPRLAND=true
        fi
        ;;
    "redhat")
        hyprland_packages=(
            "hyprland"
            "xdg-desktop-portal-hyprland"
            "polkit"
            "qt5-qtwayland"
            "qt6-qtwayland"
        )
        ;;
    "suse")
        hyprland_packages=(
            "hyprland"
            "xdg-desktop-portal-hyprland"
            "polkit-kde-agent-1"
            "libqt5-qtwayland"
            "qt6-wayland"
        )
        ;;
esac

# Installer les dépendances Wayland communes
wayland_deps=(
    "wayland"
    "wayland-utils"
    "wlroots"
)

case $DISTRO_FAMILY in
    "arch")
        wayland_deps+=("wayland" "wayland-utils" "wlroots")
        ;;
    "debian")
        wayland_deps=("wayland-protocols" "libwayland-dev")
        # wlroots n'est pas disponible dans les repos Ubuntu/Debian standards
        # Il sera compilé avec Hyprland si nécessaire
        ;;
    "redhat")
        wayland_deps+=("wayland-devel" "wayland-utils")
        # Tentative d'installation de wlroots, sinon compilation
        if ! install_package "wlroots-devel"; then
            echo "${WARN} wlroots-devel non disponible, compilation requise" | tee -a "$LOG"
        fi
        ;;
    "suse")
        wayland_deps+=("wayland-devel" "wayland-utils")
        # Tentative d'installation de wlroots, sinon compilation
        if ! install_package "wlroots-devel"; then
            echo "${WARN} wlroots-devel non disponible, compilation requise" | tee -a "$LOG"
        fi
        ;;
esac

echo "${NOTE} Installation des dépendances Wayland..." | tee -a "$LOG"
for package in "${wayland_deps[@]}"; do
    install_package "$package"
done

# Installer Hyprland
echo "${NOTE} Installation des paquets Hyprland..." | tee -a "$LOG"

if [[ "$COMPILE_HYPRLAND" == "true" ]]; then
    echo "${NOTE} Compilation de Hyprland depuis les sources (requis pour $DISTRO_ID)..." | tee -a "$LOG"
    compile_hyprland_from_source
else
    # Installation via gestionnaire de paquets
    for package in "${hyprland_packages[@]}"; do
        if [[ $DISTRO_FAMILY == "arch" ]] && is_aur_package "$package"; then
            if [[ -n "$AUR_HELPER" ]]; then
                echo "${NOTE} Installation AUR: $package" | tee -a "$LOG"
                $AUR_HELPER -S --noconfirm "$package" >> "$LOG" 2>&1 &
                local pid=$!
                show_progress $pid "$package"
                wait $pid
            fi
        else
            install_package "$package"
        fi
    done
fi

# Installer des composants Hyprland additionnels
install_hyprland_ecosystem

# Configuration initiale
configure_hyprland

echo "${OK} Installation de Hyprland terminée" | tee -a "$LOG"

# Fonction pour compiler Hyprland depuis les sources
compile_hyprland_from_source() {
    echo "${NOTE} Préparation de la compilation de Hyprland..." | tee -a "$LOG"
    
    # Dépendances de compilation
    local build_deps=()
    case $DISTRO_FAMILY in
        "debian")
            build_deps=(
                "meson" "ninja-build" "cmake" "pkg-config"
                "libwayland-dev" "libxkbcommon-dev" "libpixman-1-dev"
                "libdrm-dev" "libgtk-3-dev" "libglib2.0-dev"
                "libegl1-mesa-dev" "libgles2-mesa-dev" "libgl1-mesa-dev"
                "libvulkan-dev" "libinput-dev" "libxcb1-dev"
                "libtomlplusplus-dev" "libzip-dev" "librsvg2-dev"
                "libmagic-dev" "libpango1.0-dev" "libcairo2-dev"
            )
            ;;
        "redhat")
            build_deps=(
                "meson" "ninja-build" "cmake" "pkgconfig"
                "wayland-devel" "libxkbcommon-devel" "pixman-devel"
                "libdrm-devel" "gtk3-devel" "glib2-devel"
                "mesa-libEGL-devel" "mesa-libGLES-devel" "mesa-libGL-devel"
                "vulkan-devel" "libinput-devel" "libxcb-devel"
                "tomlplusplus-devel" "libzip-devel" "librsvg2-devel"
                "file-devel" "pango-devel" "cairo-devel"
            )
            ;;
        "suse")
            build_deps=(
                "meson" "ninja" "cmake" "pkg-config"
                "wayland-devel" "libxkbcommon-devel" "pixman-devel"
                "libdrm-devel" "gtk3-devel" "glib2-devel"
                "Mesa-libEGL-devel" "Mesa-libGLESv2-devel" "Mesa-libGL-devel"
                "vulkan-devel" "libinput-devel" "libxcb-devel"
            )
            ;;
    esac
    
    echo "${NOTE} Installation des dépendances de compilation..." | tee -a "$LOG"
    for dep in "${build_deps[@]}"; do
        install_package "$dep"
    done
    
    # Créer un dossier de build temporaire
    local build_dir="/tmp/hyprland-build"
    mkdir -p "$build_dir"
    cd "$build_dir"
    
    # Cloner Hyprland
    echo "${NOTE} Clonage du repository Hyprland..." | tee -a "$LOG"
    git clone --recursive https://github.com/hyprwm/Hyprland.git >> "$LOG" 2>&1
    cd Hyprland
    
    # Compiler
    echo "${NOTE} Compilation en cours... (cela peut prendre du temps)" | tee -a "$LOG"
    make all >> "$LOG" 2>&1 &
    local pid=$!
    show_progress $pid "Compilation Hyprland"
    wait $pid
    
    if [ $? -eq 0 ]; then
        echo "${NOTE} Installation de Hyprland..." | tee -a "$LOG"
        sudo make install >> "$LOG" 2>&1
        
        # Créer le fichier desktop si nécessaire
        if [ ! -f "/usr/share/wayland-sessions/hyprland.desktop" ]; then
            sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
        fi
        
        echo "${OK} Hyprland compilé et installé avec succès" | tee -a "$LOG"
    else
        echo "${ERROR} Échec de la compilation de Hyprland" | tee -a "$LOG"
        return 1
    fi
    
    # Nettoyer
    cd - > /dev/null
    rm -rf "$build_dir"
}

# Configuration PPA pour Ubuntu
setup_hyprland_ppa_ubuntu() {
    echo "${NOTE} Configuration du PPA Hyprland pour Ubuntu..." | tee -a "$LOG"
    
    # Vérifier la version Ubuntu
    local ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "unknown")
    
    if [[ "$ubuntu_version" == "unknown" ]]; then
        echo "${WARN} Version Ubuntu inconnue, compilation requise" | tee -a "$LOG"
        COMPILE_HYPRLAND=true
        return 1
    fi
    
    # Ubuntu 24.04+ a des paquets très récents dans les dépôts standard
    if version_compare "$ubuntu_version" ">=" "24.04"; then
        echo "${NOTE} Ubuntu $ubuntu_version détecté - version moderne avec paquets récents" | tee -a "$LOG"
        
        # Ubuntu 24.04+ devrait avoir Hyprland dans les dépôts universe
        sudo apt-get update >> "$LOG" 2>&1
        
        # Activer universe si pas déjà fait
        sudo add-apt-repository universe -y >> "$LOG" 2>&1
        
        # Tenter l'installation directe
        if install_package "hyprland" && install_package "libwlroots-dev"; then
            echo "${OK} Hyprland installé directement depuis les dépôts Ubuntu $ubuntu_version" | tee -a "$LOG"
            return 0
        else
            echo "${NOTE} Hyprland pas encore disponible dans universe, compilation requise" | tee -a "$LOG"
            COMPILE_HYPRLAND=true
            return 1
        fi
        
    # Ubuntu 22.04-23.10 : utiliser les backports
    elif version_compare "$ubuntu_version" ">=" "22.04"; then
        echo "${NOTE} Ubuntu $ubuntu_version détecté, tentative d'installation via backports..." | tee -a "$LOG"
        
        # Ajouter les backports si pas déjà présents
        if ! grep -q "backports" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
            echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/backports.list >> "$LOG" 2>&1
            sudo apt-get update >> "$LOG" 2>&1
        fi
        
        # Tenter l'installation des dépendances récentes
        if install_package "libwlroots-dev" && install_package "hyprland"; then
            echo "${OK} Hyprland installé via backports Ubuntu" | tee -a "$LOG"
            return 0
        else
            echo "${WARN} Installation via backports échouée, compilation requise" | tee -a "$LOG"
            COMPILE_HYPRLAND=true
            return 1
        fi
        
    # Ubuntu < 22.04 : trop ancien, compilation obligatoire
    else
        echo "${WARN} Ubuntu $ubuntu_version trop ancien, compilation requise" | tee -a "$LOG"
        COMPILE_HYPRLAND=true
        return 1
    fi
}

# Fonction utilitaire pour comparer les versions
version_compare() {
    local version1="$1"
    local operator="$2"
    local version2="$3"
    
    # Conversion simple pour comparaison
    version1=$(echo "$version1" | sed 's/\.//g')
    version2=$(echo "$version2" | sed 's/\.//g')
    
    case $operator in
        ">=")
            [[ $version1 -ge $version2 ]]
            ;;
        ">")
            [[ $version1 -gt $version2 ]]
            ;;
        "<=")
            [[ $version1 -le $version2 ]]
            ;;
        "<")
            [[ $version1 -lt $version2 ]]
            ;;
        "==")
            [[ $version1 -eq $version2 ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Installer l'écosystème Hyprland
install_hyprland_ecosystem() {
    echo "${NOTE} Installation de l'écosystème Hyprland..." | tee -a "$LOG"
    
    local ecosystem_packages=()
    
    case $DISTRO_FAMILY in
        "arch")
            ecosystem_packages=(
                "waybar"
                "wofi"
                "mako"
                "grim"
                "slurp"
                "swappy"
                "wl-clipboard"
                "brightnessctl"
                "pamixer"
            )
            if [[ -n "$AUR_HELPER" ]]; then
                ecosystem_packages+=(
                    "swww"
                    "swaync"
                    "hyprshot"
                )
            fi
            ;;
        "debian")
            ecosystem_packages=(
                "waybar"
                "wofi"
                "mako-notifier"
                "grim"
                "slurp"
                "swappy"
                "wl-clipboard"
                "brightnessctl"
            )
            ;;
        "redhat")
            ecosystem_packages=(
                "waybar"
                "wofi"
                "mako"
                "grim"
                "slurp" 
                "wl-clipboard"
                "brightnessctl"
            )
            ;;
        "suse")
            ecosystem_packages=(
                "waybar"
                "wofi"
                "mako"
                "grim"
                "slurp"
                "wl-clipboard"
                "brightnessctl"
            )
            ;;
    esac
    
    # Installer les paquets de l'écosystème
    for package in "${ecosystem_packages[@]}"; do
        if [[ $DISTRO_FAMILY == "arch" ]] && is_aur_package "$package"; then
            if [[ -n "$AUR_HELPER" ]]; then
                $AUR_HELPER -S --noconfirm "$package" >> "$LOG" 2>&1
            fi
        else
            install_package "$package"
        fi
    done
}

# Configuration initiale de Hyprland
configure_hyprland() {
    echo "${NOTE} Configuration initiale de Hyprland..." | tee -a "$LOG"
    
    # Créer le dossier de configuration
    mkdir -p ~/.config/hypr
    
    # Copier la configuration par défaut si elle n'existe pas
    if [ ! -f ~/.config/hypr/hyprland.conf ]; then
        if [ -f "/usr/share/hyprland/hyprland.conf" ]; then
            cp /usr/share/hyprland/hyprland.conf ~/.config/hypr/
        else
            # Créer une configuration de base
            cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Configuration Hyprland de base
monitor=,preferred,auto,auto

input {
    kb_layout = fr
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0
}

general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Keybindings
$mainMod = SUPER

bind = $mainMod, Q, exec, alacritty
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4

# Move to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4

# Scroll through workspaces
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF
        fi
        echo "${OK} Configuration Hyprland créée" | tee -a "$LOG"
    fi
    
    # Configurer xdg-desktop-portal
    mkdir -p ~/.config/xdg-desktop-portal
    cat > ~/.config/xdg-desktop-portal/portals.conf << EOF
[preferred]
default=hyprland;gtk
EOF
    
    echo "${OK} Configuration initiale terminée" | tee -a "$LOG"
}