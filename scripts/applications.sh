#!/bin/bash
# Installation des applications pour Hyprland Universal

echo "${NOTE} Installation des applications..." | tee -a "$LOG"

# Fonction pour installer le terminal Alacritty
install_terminal() {
    echo "${NOTE} Installation du terminal Alacritty..." | tee -a "$LOG"
    
    case $DISTRO_FAMILY in
        "arch")
            install_package "alacritty"
            ;;
        "debian")
            install_package "alacritty"
            ;;
        "redhat")
            install_package "alacritty"
            ;;
        "suse")
            install_package "alacritty"
            ;;
    esac
    
    # Configuration Alacritty avec thème Dracula
    local alacritty_config="$HOME/.config/alacritty/alacritty.yml"
    mkdir -p "$(dirname "$alacritty_config")"
    
    cat > "$alacritty_config" << 'EOF'
# Configuration Alacritty avec thème Dracula
window:
  opacity: 0.95
  padding:
    x: 10
    y: 10
  decorations: none
  startup_mode: Windowed
  title: Alacritty
  class:
    instance: Alacritty
    general: Alacritty

scrolling:
  history: 10000
  multiplier: 3

font:
  normal:
    family: "JetBrainsMono Nerd Font"
    style: Regular
  bold:
    family: "JetBrainsMono Nerd Font"
    style: Bold
  italic:
    family: "JetBrainsMono Nerd Font"
    style: Italic
  bold_italic:
    family: "JetBrainsMono Nerd Font"
    style: Bold Italic
  size: 12.0

colors:
  primary:
    background: '#282a36'
    foreground: '#f8f8f2'
  cursor:
    text:   '#282a36'
    cursor: '#f8f8f2'
  vi_mode_cursor:
    text:   '#282a36'
    cursor: '#f8f8f2'
  selection:
    text:       '#f8f8f2'
    background: '#44475a'
  search:
    matches:
      foreground: '#44475a'
      background: '#50fa7b'
    focused_match:
      foreground: '#44475a'
      background: '#ffb86c'
  normal:
    black:   '#21222c'
    red:     '#ff5555'
    green:   '#50fa7b'
    yellow:  '#f1fa8c'
    blue:    '#bd93f9'
    magenta: '#ff79c6'
    cyan:    '#8be9fd'
    white:   '#f8f8f2'
  bright:
    black:   '#6272a4'
    red:     '#ff6e6e'
    green:   '#69ff94'
    yellow:  '#ffffa5'
    blue:    '#d6acff'
    magenta: '#ff92df'
    cyan:    '#a4ffff'
    white:   '#ffffff'

bell:
  animation: EaseOutExpo
  duration: 0
  color: '#ffffff'

mouse:
  hide_when_typing: true

cursor:
  style:
    shape: Block
    blinking: On
  blink_interval: 750

shell:
  program: /bin/zsh

key_bindings:
  - { key: V,        mods: Control|Shift, action: Paste            }
  - { key: C,        mods: Control|Shift, action: Copy             }
  - { key: Insert,   mods: Shift,         action: PasteSelection   }
  - { key: Key0,     mods: Control,       action: ResetFontSize    }
  - { key: Equals,   mods: Control,       action: IncreaseFontSize }
  - { key: Plus,     mods: Control,       action: IncreaseFontSize }
  - { key: Minus,    mods: Control,       action: DecreaseFontSize }
  - { key: F11,      mods: None,          action: ToggleFullscreen }
  - { key: Paste,    mods: None,          action: Paste            }
  - { key: Copy,     mods: None,          action: Copy             }
  - { key: L,        mods: Control,       action: ClearLogNotice   }
  - { key: L,        mods: Control,       chars: "\x0c"            }
  - { key: PageUp,   mods: None,          action: ScrollPageUp,    mode: ~Alt }
  - { key: PageDown, mods: None,          action: ScrollPageDown,  mode: ~Alt }
  - { key: Home,     mods: Shift,         action: ScrollToTop,     mode: ~Alt }
  - { key: End,      mods: Shift,         action: ScrollToBottom,  mode: ~Alt }
EOF
    
    echo "${OK} Terminal Alacritty configuré avec thème Dracula" | tee -a "$LOG"
}

# Fonction pour installer le lanceur d'applications
install_launcher() {
    echo "${NOTE} Installation du lanceur Wofi..." | tee -a "$LOG"
    
    case $DISTRO_FAMILY in
        "arch")
            install_package "wofi"
            ;;
        "debian")
            install_package "wofi"
            ;;
        "redhat")
            install_package "wofi"
            ;;
        "suse")
            install_package "wofi"
            ;;
    esac
    
    # Configuration Wofi avec thème Dracula
    local wofi_config="$HOME/.config/wofi/config"
    local wofi_style="$HOME/.config/wofi/style.css"
    
    mkdir -p "$(dirname "$wofi_config")"
    
    cat > "$wofi_config" << 'EOF'
width=600
height=400
location=center
show=drun
prompt=Applications
filter_rate=100
allow_markup=true
no_actions=true
halign=fill
orientation=vertical
content_halign=fill
insensitive=true
allow_images=true
image_size=40
gtk_dark=true
EOF

    cat > "$wofi_style" << 'EOF'
/* Wofi Dracula Theme */
window {
    margin: 0px;
    border: 2px solid #6272a4;
    background-color: #282a36;
    border-radius: 10px;
}

#input {
    margin: 10px;
    border: 2px solid #6272a4;
    color: #f8f8f2;
    background-color: #44475a;
    border-radius: 5px;
    padding: 8px;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 14px;
}

#inner-box {
    margin: 10px;
    border: none;
    background-color: #282a36;
}

#outer-box {
    margin: 0px;
    border: none;
    background-color: #282a36;
}

#scroll {
    margin: 0px;
    border: none;
}

#text {
    margin: 5px;
    border: none;
    color: #f8f8f2;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
}

#entry {
    margin: 2px;
    border: none;
    border-radius: 5px;
    background-color: transparent;
}

#entry:selected {
    background-color: #6272a4;
}

#entry:selected #text {
    color: #f8f8f2;
    font-weight: bold;
}

#img {
    margin-right: 10px;
}
EOF
    
    echo "${OK} Lanceur Wofi configuré avec thème Dracula" | tee -a "$LOG"
}

# Fonction pour installer le gestionnaire de fichiers
install_file_manager() {
    echo "${NOTE} Installation du gestionnaire de fichiers Thunar..." | tee -a "$LOG"
    
    case $DISTRO_FAMILY in
        "arch")
            install_package "thunar" "thunar-volman" "thunar-media-tags-plugin"
            ;;
        "debian")
            install_package "thunar" "thunar-volman" "thunar-media-tags-plugin"
            ;;
        "redhat")
            install_package "thunar" "thunar-volman"
            ;;
        "suse")
            install_package "thunar" "thunar-volman"
            ;;
    esac
    
    echo "${OK} Gestionnaire de fichiers Thunar installé" | tee -a "$LOG"
}

# Fonction pour installer les applications de développement
install_development_apps() {
    echo "${NOTE} Installation des applications de développement..." | tee -a "$LOG"
    
    local dev_packages=()
    
    case $DISTRO_FAMILY in
        "arch")
            dev_packages=(
                "code" "neovim" "git" "lazygit" "docker" "docker-compose"
                "nodejs" "npm" "python" "python-pip" "go" "rust"
                "btop" "fastfetch" "tree" "curl" "wget"
            )
            ;;
        "debian")
            dev_packages=(
                "code" "neovim" "git" "docker.io" "docker-compose"
                "nodejs" "npm" "python3" "python3-pip" "golang-go"
                "btop" "fastfetch" "tree" "curl" "wget"
            )
            ;;
        "redhat")
            dev_packages=(
                "code" "neovim" "git" "docker" "docker-compose"
                "nodejs" "npm" "python3" "python3-pip" "golang"
                "btop" "tree" "curl" "wget"
            )
            ;;
        "suse")
            dev_packages=(
                "code" "neovim" "git" "docker" "docker-compose"
                "nodejs" "npm" "python3" "python3-pip" "go"
                "btop" "tree" "curl" "wget"
            )
            ;;
    esac
    
    for package in "${dev_packages[@]}"; do
        install_package "$package"
    done
    
    # Installation de LazyDocker
    if ! command -v lazydocker &> /dev/null; then
        echo "${NOTE} Installation de LazyDocker..." | tee -a "$LOG"
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    fi
    
    # Installation de LazyGit si pas disponible
    if ! command -v lazygit &> /dev/null; then
        echo "${NOTE} Installation de LazyGit..." | tee -a "$LOG"
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi
    
    echo "${OK} Applications de développement installées" | tee -a "$LOG"
}

# Fonction pour installer les applications multimédias
install_multimedia_apps() {
    echo "${NOTE} Installation des applications multimédias..." | tee -a "$LOG"
    
    local media_packages=()
    
    case $DISTRO_FAMILY in
        "arch")
            media_packages=(
                "mpv" "imv" "grim" "slurp" "wf-recorder"
                "pavucontrol" "playerctl" "obs-studio"
            )
            ;;
        "debian")
            media_packages=(
                "mpv" "imv" "grim" "slurp" "wf-recorder"
                "pavucontrol" "playerctl" "obs-studio"
            )
            ;;
        "redhat")
            media_packages=(
                "mpv" "grim" "slurp" "pavucontrol" "playerctl"
            )
            ;;
        "suse")
            media_packages=(
                "mpv" "grim" "slurp" "pavucontrol" "playerctl"
            )
            ;;
    esac
    
    for package in "${media_packages[@]}"; do
        install_package "$package"
    done
    
    echo "${OK} Applications multimédias installées" | tee -a "$LOG"
}

# Fonction pour installer les applications de communication
install_communication_apps() {
    echo "${NOTE} Installation des applications de communication..." | tee -a "$LOG"
    
    # Discord via Flatpak si disponible
    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub com.discordapp.Discord 2>/dev/null || true
        flatpak install -y flathub org.telegram.desktop 2>/dev/null || true
    fi
    
    # Installation via gestionnaire de paquets
    case $DISTRO_FAMILY in
        "arch")
            install_package "discord" "telegram-desktop" "firefox"
            ;;
        "debian")
            install_package "firefox-esr" "telegram-desktop"
            ;;
        "redhat")
            install_package "firefox" "telegram-desktop"
            ;;
        "suse")
            install_package "firefox" "telegram-desktop"
            ;;
    esac
    
    echo "${OK} Applications de communication installées" | tee -a "$LOG"
}

# Fonction pour installer les applications de productivité
install_productivity_apps() {
    echo "${NOTE} Installation des applications de productivité..." | tee -a "$LOG"
    
    # LibreOffice et KeePass
    case $DISTRO_FAMILY in
        "arch")
            install_package "libreoffice-fresh" "keepass" "obsidian"
            ;;
        "debian")
            install_package "libreoffice" "keepass2" 
            ;;
        "redhat")
            install_package "libreoffice" "keepass"
            ;;
        "suse")
            install_package "libreoffice" "keepass"
            ;;
    esac
    
    # Obsidian via Flatpak si disponible
    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null || true
    fi
    
    echo "${OK} Applications de productivité installées" | tee -a "$LOG"
}

# Fonction pour configurer les applications par défaut
configure_default_apps() {
    echo "${NOTE} Configuration des applications par défaut..." | tee -a "$LOG"
    
    # Applications par défaut
    local mimeapps_config="$HOME/.config/mimeapps.list"
    
    cat > "$mimeapps_config" << 'EOF'
[Default Applications]
text/plain=code.desktop
application/json=code.desktop
application/javascript=code.desktop
text/html=firefox.desktop
application/pdf=firefox.desktop
image/jpeg=imv.desktop
image/png=imv.desktop
image/gif=imv.desktop
video/mp4=mpv.desktop
video/x-matroska=mpv.desktop
audio/mpeg=mpv.desktop
audio/flac=mpv.desktop
inode/directory=thunar.desktop
application/zip=thunar.desktop
application/x-tar=thunar.desktop

[Added Associations]
text/plain=code.desktop;
application/json=code.desktop;
text/html=firefox.desktop;
image/jpeg=imv.desktop;
image/png=imv.desktop;
video/mp4=mpv.desktop;
audio/mpeg=mpv.desktop;
EOF
    
    echo "${OK} Applications par défaut configurées" | tee -a "$LOG"
}

# Exécution principale
main() {
    echo "${NOTE} === Installation des applications ===" | tee -a "$LOG"
    
    install_terminal
    install_launcher
    install_file_manager
    install_development_apps
    install_multimedia_apps
    install_communication_apps
    install_productivity_apps
    configure_default_apps
    
    echo "${OK} Installation des applications terminée" | tee -a "$LOG"
}

# Exécuter si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi