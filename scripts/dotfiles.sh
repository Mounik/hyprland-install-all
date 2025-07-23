#!/bin/bash
# Configuration finale et dotfiles pour Hyprland Universal

echo "${NOTE} Configuration finale et dotfiles..." | tee -a "$LOG"

# Fonction pour créer la configuration Hyprland complète
create_hyprland_config() {
    echo "${NOTE} Création de la configuration Hyprland..." | tee -a "$LOG"
    
    mkdir -p ~/.config/hypr
    
    # Configuration principale avec thème Dracula
    cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Configuration Hyprland Universal - Thème Dracula
# Généré par Hyprland Universal Installer

# Moniteurs
monitor=,preferred,auto,auto

# Variables d'environnement
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

# Entrée
input {
    kb_layout = fr
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    touchpad {
        natural_scroll = yes
    }

    sensitivity = 0
}

# Apparence générale - Thème Dracula
general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(bd93f9ee) rgba(ff79c6ee) 45deg
    col.inactive_border = rgba(44475aaa)
    layout = dwindle
    allow_tearing = false
}

# Décorations - Style Dracula
decoration {
    rounding = 10
    
    blur {
        enabled = true
        size = 3
        passes = 1
        vibrancy = 0.1696
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(282a36ee)
}

# Animations
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

# Layout dwindle
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Layout master
master {
    new_is_master = true
}

# Gestes
gestures {
    workspace_swipe = off
}

# Divers
misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
}

# Variables
$mainMod = SUPER

# Raccourcis clavier - Compatible avec la documentation README
bind = $mainMod, RETURN, exec, alacritty
bind = $mainMod, W, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, F, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, SPACE, exec, wofi --show drun
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Navigation avec les flèches
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Espaces de travail
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Déplacer vers les espaces de travail
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Applications spécifiques
bind = $mainMod, B, exec, chromium
bind = $mainMod, T, exec, alacritty -e btop
bind = $mainMod, N, exec, alacritty -e nvim
bind = $mainMod, G, exec, alacritty -e lazygit
bind = $mainMod, D, exec, alacritty -e lazydocker

# Contrôles audio
bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
bind = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t

# Contrôles de luminosité
bind = , XF86MonBrightnessUp, exec, brightnessctl s +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy
bind = CTRL, Print, exec, grim

# Défilement des espaces de travail avec la souris
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Déplacer/redimensionner avec la souris
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Règles de fenêtre
windowrulev2 = float,class:^(pavucontrol)$
windowrulev2 = float,class:^(file-roller)$
windowrulev2 = float,title:^(Picture-in-Picture)$

# Démarrage automatique
exec-once = waybar
exec-once = swaync
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = swww init
exec-once = swww img ~/.config/hypr/wallpaper.jpg
EOF

    echo "${OK} Configuration Hyprland créée" | tee -a "$LOG"
}

# Fonction pour configurer Alacritty avec le thème Dracula
create_alacritty_config() {
    echo "${NOTE} Configuration d'Alacritty..." | tee -a "$LOG"
    
    mkdir -p ~/.config/alacritty
    
    cat > ~/.config/alacritty/alacritty.toml << 'EOF'
# Configuration Alacritty - Thème Dracula

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
size = 12.0

[window]
opacity = 0.95
padding = { x = 10, y = 10 }

# Thème Dracula
[colors.primary]
background = "#282a36"
foreground = "#f8f8f2"
bright_foreground = "#ffffff"

[colors.cursor]
text = "#282a36"
cursor = "#f8f8f2"

[colors.vi_mode_cursor]
text = "#282a36"
cursor = "#f8f8f2"

[colors.search.matches]
foreground = "#44475a"
background = "#50fa7b"

[colors.search.focused_match]
foreground = "#44475a"
background = "#ffb86c"

[colors.footer_bar]
background = "#282a36"
foreground = "#f8f8f2"

[colors.hints.start]
foreground = "#282a36"
background = "#f1fa8c"

[colors.hints.end]
foreground = "#f1fa8c"
background = "#282a36"

[colors.selection]
text = "#f8f8f2"
background = "#44475a"

[colors.normal]
black = "#21222c"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#f8f8f2"

[colors.bright]
black = "#6272a4"
red = "#ff6e6e"
green = "#69ff94"
yellow = "#ffffa5"
blue = "#d6acff"
magenta = "#ff92df"
cyan = "#a4ffff"
white = "#ffffff"
EOF

    echo "${OK} Configuration Alacritty créée" | tee -a "$LOG"
}

# Fonction pour configurer Waybar
create_waybar_config() {
    echo "${NOTE} Configuration de Waybar..." | tee -a "$LOG"
    
    mkdir -p ~/.config/waybar
    
    # Configuration Waybar
    cat > ~/.config/waybar/config.jsonc << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "network", "pulseaudio", "battery", "custom/power"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50
    },
    
    "tray": {
        "spacing": 10
    },
    
    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d %H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": " {signalStrength}%",
        "format-ethernet": " {ipaddr}",
        "format-linked": " {ifname}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip-format": "{essid}: {ipaddr}"
    },
    
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " {volume}%",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    
    "custom/power": {
        "format": "",
        "tooltip": "Power menu",
        "on-click": "wlogout"
    }
}
EOF

    # Style Waybar - Thème Dracula
    cat > ~/.config/waybar/style.css << 'EOF'
* {
    font-family: 'JetBrainsMono Nerd Font';
    font-size: 14px;
}

window#waybar {
    background-color: rgba(40, 42, 54, 0.9);
    border-bottom: 3px solid rgba(189, 147, 249, 1);
    color: #f8f8f2;
    transition-property: background-color;
    transition-duration: .5s;
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 0;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #f8f8f2;
}

#workspaces button:hover {
    background: rgba(68, 71, 90, 0.2);
}

#workspaces button.focused {
    background-color: #bd93f9;
    color: #282a36;
}

#workspaces button.urgent {
    background-color: #ff5555;
    color: #f8f8f2;
}

#clock,
#battery,
#network,
#pulseaudio,
#tray,
#window,
#custom-power {
    padding: 0 10px;
    color: #f8f8f2;
}

#window {
    color: #50fa7b;
}

#battery.charging, #battery.plugged {
    color: #50fa7b;
}

#battery.critical:not(.charging) {
    background-color: #ff5555;
    color: #f8f8f2;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#network.disconnected {
    color: #ff5555;
}

#pulseaudio.muted {
    color: #ff5555;
}

#custom-power {
    color: #ff79c6;
}

#custom-power:hover {
    background-color: #ff79c6;
    color: #282a36;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}
EOF

    echo "${OK} Configuration Waybar créée" | tee -a "$LOG"
}

# Fonction pour configurer les aliases bash/zsh
setup_shell_aliases() {
    echo "${NOTE} Configuration des aliases shell..." | tee -a "$LOG"
    
    # Détecter le shell principal
    local shell_rc=""
    if [ -n "$ZSH_VERSION" ] || [ -f ~/.zshrc ]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi
    
    # Créer le fichier d'aliases
    cat > ~/.config/shell-aliases << 'EOF'
# Aliases Hyprland Universal - Conformes à la documentation

# Aliases OpenTofu/Terraform
alias tf='tofu'
alias terraform='tofu'
alias tofu-workflow='tofu fmt && tofu init && tofu validate && tofu plan'

# Aliases Python avec UV
alias py='python3'
alias pip='uv pip'
alias venv='uv venv'
uv-project() {
    if [ -z "$1" ]; then
        echo "Usage: uv-project <nom-du-projet>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
    uv init
    echo "Projet UV créé: $1"
}

# Aliases Ansible
alias ap='ansible-playbook'
alias av='ansible-vault'
alias ag='ansible-galaxy'
alias ai='ansible-inventory'

# Aliases système
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Aliases Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Aliases Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Aliases Hyprland
alias hypr-reload='hyprctl reload'
alias hypr-logs='journalctl -f _COMM=Hyprland'
alias waybar-reload='killall waybar && waybar &'
EOF

    # Ajouter le source dans le shell RC
    if ! grep -q "source ~/.config/shell-aliases" "$shell_rc" 2>/dev/null; then
        echo "" >> "$shell_rc"
        echo "# Aliases Hyprland Universal" >> "$shell_rc"
        echo "source ~/.config/shell-aliases" >> "$shell_rc"
        echo "${OK} Aliases ajoutés à $shell_rc" | tee -a "$LOG"
    fi
}

# Fonction pour configurer les services de démarrage automatique
setup_autostart() {
    echo "${NOTE} Configuration du démarrage automatique..." | tee -a "$LOG"
    
    # Créer le script de démarrage automatique
    mkdir -p ~/.config/hypr/scripts
    
    cat > ~/.config/hypr/scripts/autostart.sh << 'EOF'
#!/bin/bash
# Script de démarrage automatique Hyprland

# Agent d'authentification
/usr/lib/polkit-kde-authentication-agent-1 &

# Waybar
waybar &

# Notifications
swaync &

# Papier peint
if command -v swww &> /dev/null; then
    swww init &
    sleep 1
    swww img ~/.config/hypr/wallpaper.jpg &
fi

# Idle manager
if command -v hypridle &> /dev/null; then
    hypridle &
fi

# Applications personnalisées
# Ajoutez vos applications ici
EOF

    chmod +x ~/.config/hypr/scripts/autostart.sh
    echo "${OK} Script de démarrage automatique créé" | tee -a "$LOG"
}

# Fonction pour télécharger un papier peint par défaut
setup_wallpaper() {
    echo "${NOTE} Configuration du papier peint..." | tee -a "$LOG"
    
    local wallpaper_dir="$HOME/.config/hypr"
    local wallpaper_url="https://raw.githubusercontent.com/dracula/wallpaper/master/first-collection/arch-dracula.png"
    
    if [ ! -f "$wallpaper_dir/wallpaper.jpg" ]; then
        echo "${NOTE} Téléchargement du papier peint Dracula..." | tee -a "$LOG"
        if wget -q "$wallpaper_url" -O "$wallpaper_dir/wallpaper.jpg" 2>/dev/null; then
            echo "${OK} Papier peint téléchargé" | tee -a "$LOG"
        else
            # Créer un papier peint de fallback uni
            if command -v convert &>/dev/null; then
                convert -size 1920x1080 xc:"#282a36" "$wallpaper_dir/wallpaper.jpg"
                echo "${OK} Papier peint uni créé" | tee -a "$LOG"
            fi
        fi
    fi
}

# Fonction pour créer les raccourcis bureau
create_desktop_entries() {
    echo "${NOTE} Création des raccourcis bureau..." | tee -a "$LOG"
    
    mkdir -p ~/.local/share/applications
    
    # Raccourci pour les paramètres Hyprland
    cat > ~/.local/share/applications/hyprland-settings.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland Settings
Comment=Configure Hyprland window manager
Exec=alacritty -e nvim ~/.config/hypr/hyprland.conf
Icon=preferences-system
Type=Application
Categories=Settings;
EOF

    echo "${OK} Raccourcis bureau créés" | tee -a "$LOG"
}

# Fonction pour configurer les mimes types
setup_mime_types() {
    echo "${NOTE} Configuration des types MIME..." | tee -a "$LOG"
    
    # Associer les applications par défaut
    mkdir -p ~/.config
    
    cat > ~/.config/mimeapps.list << 'EOF'
[Default Applications]
text/plain=nvim.desktop
application/pdf=chromium.desktop
image/png=imv.desktop
image/jpeg=imv.desktop
video/mp4=mpv.desktop
audio/mpeg=mpv.desktop
inode/directory=thunar.desktop

[Added Associations]
text/plain=nvim.desktop;
application/pdf=chromium.desktop;
image/png=imv.desktop;
image/jpeg=imv.desktop;
video/mp4=mpv.desktop;
audio/mpeg=mpv.desktop;
inode/directory=thunar.desktop;
EOF

    echo "${OK} Types MIME configurés" | tee -a "$LOG"
}

# Fonction pour créer le fichier d'information système
create_system_info() {
    echo "${NOTE} Création du fichier d'information système..." | tee -a "$LOG"
    
    cat > ~/.config/hyprland-universal-info.txt << EOF
Hyprland Universal Installer
Installation terminée le: $(date)
Distribution: $DISTRO_NAME ($DISTRO_VERSION)
Famille: $DISTRO_FAMILY

Configuration appliquée:
- Thème: Dracula
- Terminal: Alacritty
- Shell: $(basename "$SHELL")
- Gestionnaire de fichiers: Thunar
- Barre de statut: Waybar

Raccourcis principaux:
- Super + Entrée: Terminal
- Super + Espace: Lanceur d'applications
- Super + F: Gestionnaire de fichiers
- Super + W: Fermer la fenêtre
- Super + 1-4: Changer d'espace de travail

Pour plus d'informations, consultez le README.md
EOF

    echo "${OK} Fichier d'information créé: ~/.config/hyprland-universal-info.txt" | tee -a "$LOG"
}

# Exécution principale de la configuration
main_dotfiles_setup() {
    echo "${NOTE} Configuration finale en cours..." | tee -a "$LOG"
    
    # 1. Configurations principales
    create_hyprland_config
    create_alacritty_config
    create_waybar_config
    
    # 2. Shell et aliases
    setup_shell_aliases
    
    # 3. Démarrage automatique
    setup_autostart
    
    # 4. Papier peint
    setup_wallpaper
    
    # 5. Raccourcis et mimes
    create_desktop_entries
    setup_mime_types
    
    # 6. Information système
    create_system_info
    
    echo "${OK} Configuration finale terminée" | tee -a "$LOG"
}

# Lancer la configuration
main_dotfiles_setup

echo "${OK} Installation des dotfiles terminée" | tee -a "$LOG"