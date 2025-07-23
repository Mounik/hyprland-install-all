#!/bin/bash
# Installation et configuration de Waybar pour Hyprland Universal

echo "${NOTE} Installation de Waybar..." | tee -a "$LOG"

# Fonction pour installer Waybar et ses dépendances
install_waybar() {
    local waybar_packages=()
    
    case $DISTRO_FAMILY in
        "arch")
            waybar_packages=(
                "waybar"
                "otf-font-awesome"
                "ttf-font-awesome"
                "wl-clipboard"
                "jq"
                "playerctl"
                "pavucontrol"
                "brightnessctl"
                "networkmanager"
            )
            ;;
        "debian")
            waybar_packages=(
                "waybar"
                "fonts-font-awesome"
                "wl-clipboard"
                "jq"
                "playerctl"
                "pavucontrol"
                "brightnessctl"
                "network-manager"
            )
            ;;
        "redhat")
            waybar_packages=(
                "waybar"
                "fontawesome-fonts"
                "wl-clipboard"
                "jq"
                "playerctl"
                "pavucontrol"
                "brightnessctl"
                "NetworkManager"
            )
            ;;
        "suse")
            waybar_packages=(
                "waybar"
                "fontawesome-fonts"
                "wl-clipboard"
                "jq"
                "playerctl"
                "pavucontrol"
                "brightnessctl"
                "NetworkManager"
            )
            ;;
    esac
    
    for package in "${waybar_packages[@]}"; do
        install_package "$package"
    done
}

# Fonction pour créer la configuration Waybar avec thème Dracula
create_waybar_config() {
    local config_dir="$HOME/.config/waybar"
    local config_file="$config_dir/config"
    local style_file="$config_dir/style.css"
    
    mkdir -p "$config_dir"
    
    # Configuration principale de Waybar
    cat > "$config_file" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 35,
    "spacing": 4,
    "exclusive": true,
    "gtk-layer-shell": true,
    "passthrough": false,
    "modules-left": [
        "hyprland/workspaces",
        "hyprland/mode",
        "hyprland/scratchpad"
    ],
    "modules-center": [
        "hyprland/window"
    ],
    "modules-right": [
        "mpd",
        "idle_inhibitor",
        "pulseaudio",
        "network",
        "cpu",
        "memory",
        "temperature",
        "backlight",
        "battery",
        "clock",
        "tray"
    ],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "warp-on-scroll": false,
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
        },
        "persistent_workspaces": {
            "1": [],
            "2": [],
            "3": [],
            "4": []
        }
    },
    
    "hyprland/mode": {
        "format": "<span style=\"italic\">{}</span>"
    },
    
    "hyprland/scratchpad": {
        "format": "{icon} {count}",
        "show-empty": false,
        "format-icons": ["", ""],
        "tooltip": true,
        "tooltip-format": "{app}: {title}"
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50,
        "separate-outputs": true
    },
    
    "mpd": {
        "format": "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ",
        "format-disconnected": "Disconnected ",
        "format-stopped": "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ",
        "unknown-tag": "N/A",
        "interval": 2,
        "consume-icons": {
            "on": " "
        },
        "random-icons": {
            "off": "<span color=\"#f53c3c\"></span> ",
            "on": " "
        },
        "repeat-icons": {
            "on": " "
        },
        "single-icons": {
            "on": "1 "
        },
        "state-icons": {
            "paused": "",
            "playing": ""
        },
        "tooltip-format": "MPD (connected)",
        "tooltip-format-disconnected": "MPD (disconnected)"
    },
    
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    
    "tray": {
        "spacing": 10
    },
    
    "clock": {
        "timezone": "Europe/Paris",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}",
        "format": "{:%H:%M}"
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    
    "memory": {
        "format": "{}% "
    },
    
    "temperature": {
        "critical-threshold": 80,
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["", "", ""]
    },
    
    "backlight": {
        "format": "{percent}% {icon}",
        "format-icons": ["", "", "", "", "", "", "", "", ""]
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
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
    }
}
EOF

    # Style CSS avec thème Dracula
    cat > "$style_file" << 'EOF'
/* Waybar Dracula Theme */
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: #282a36;
    border-bottom: 3px solid #6272a4;
    color: #f8f8f2;
    transition-property: background-color;
    transition-duration: .5s;
}

window#waybar.hidden {
    opacity: 0.2;
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 0;
}

button:hover {
    background: inherit;
    box-shadow: inset 0 -3px #f8f8f2;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #f8f8f2;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #6272a4;
    box-shadow: inset 0 -3px #f8f8f2;
}

#workspaces button.urgent {
    background-color: #ff5555;
}

#mode {
    background-color: #6272a4;
    border-bottom: 3px solid #f8f8f2;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#wireplumber,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#scratchpad,
#mpd {
    padding: 0 10px;
    color: #f8f8f2;
}

#window,
#workspaces {
    margin: 0 4px;
}

.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    background-color: #bd93f9;
    color: #282a36;
    font-weight: bold;
}

#battery {
    background-color: #50fa7b;
    color: #282a36;
}

#battery.charging, #battery.plugged {
    color: #282a36;
    background-color: #50fa7b;
}

@keyframes blink {
    to {
        background-color: #f8f8f2;
        color: #282a36;
    }
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

label:focus {
    background-color: #282a36;
}

#cpu {
    background-color: #8be9fd;
    color: #282a36;
}

#memory {
    background-color: #ffb86c;
    color: #282a36;
}

#disk {
    background-color: #f1fa8c;
    color: #282a36;
}

#backlight {
    background-color: #f1fa8c;
    color: #282a36;
}

#network {
    background-color: #ff79c6;
    color: #282a36;
}

#network.disconnected {
    background-color: #ff5555;
}

#pulseaudio {
    background-color: #8be9fd;
    color: #282a36;
}

#pulseaudio.muted {
    background-color: #6272a4;
    color: #f8f8f2;
}

#wireplumber {
    background-color: #f1fa8c;
    color: #282a36;
}

#wireplumber.muted {
    background-color: #ff5555;
}

#custom-media {
    background-color: #50fa7b;
    color: #282a36;
    min-width: 100px;
}

#custom-media.custom-spotify {
    background-color: #50fa7b;
}

#custom-media.custom-vlc {
    background-color: #ffb86c;
}

#temperature {
    background-color: #f0932b;
}

#temperature.critical {
    background-color: #ff5555;
}

#tray {
    background-color: #6272a4;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #ff5555;
}

#idle_inhibitor {
    background-color: #6272a4;
}

#idle_inhibitor.activated {
    background-color: #f8f8f2;
    color: #282a36;
}

#mpd {
    background-color: #50fa7b;
    color: #282a36;
}

#mpd.disconnected {
    background-color: #ff5555;
}

#mpd.stopped {
    background-color: #6272a4;
}

#mpd.paused {
    background-color: #f1fa8c;
    color: #282a36;
}

#language {
    background: #bd93f9;
    color: #282a36;
    padding: 0 5px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state {
    background: #bd93f9;
    color: #282a36;
    padding: 0 0px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state > label {
    padding: 0 5px;
}

#keyboard-state > label.locked {
    background: rgba(0, 0, 0, 0.2);
}

#scratchpad {
    background: rgba(0, 0, 0, 0.2);
}

#scratchpad.empty {
    background-color: transparent;
}

#window {
    background-color: #44475a;
    padding: 0 10px;
}
EOF

    echo "${OK} Configuration Waybar créée avec thème Dracula" | tee -a "$LOG"
}

# Fonction pour créer des scripts utilitaires pour Waybar
create_waybar_scripts() {
    local scripts_dir="$HOME/.config/waybar/scripts"
    mkdir -p "$scripts_dir"
    
    # Script pour afficher les informations système
    cat > "$scripts_dir/system-info.sh" << 'EOF'
#!/bin/bash
# Script d'informations système pour Waybar

get_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    echo "${cpu_usage}%"
}

get_memory_usage() {
    memory_usage=$(free | grep Mem | awk '{printf("%.0f%%", $3/$2 * 100.0)}')
    echo "$memory_usage"
}

get_disk_usage() {
    disk_usage=$(df -h / | awk 'NR==2{printf "%s", $5}')
    echo "$disk_usage"
}

case "$1" in
    cpu)
        get_cpu_usage
        ;;
    memory)
        get_memory_usage
        ;;
    disk)
        get_disk_usage
        ;;
    *)
        echo "Usage: $0 {cpu|memory|disk}"
        exit 1
        ;;
esac
EOF

    chmod +x "$scripts_dir/system-info.sh"
    
    # Script pour contrôler la luminosité
    cat > "$scripts_dir/brightness.sh" << 'EOF'
#!/bin/bash
# Contrôle de luminosité pour Waybar

current_brightness() {
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl get
    else
        cat /sys/class/backlight/*/brightness 2>/dev/null | head -1
    fi
}

max_brightness() {
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl max
    else
        cat /sys/class/backlight/*/max_brightness 2>/dev/null | head -1
    fi
}

percentage() {
    current=$(current_brightness)
    max=$(max_brightness)
    if [[ -n "$current" && -n "$max" && "$max" -gt 0 ]]; then
        echo $((current * 100 / max))
    else
        echo "N/A"
    fi
}

case "$1" in
    get)
        percentage
        ;;
    up)
        if command -v brightnessctl >/dev/null 2>&1; then
            brightnessctl set +5%
        fi
        ;;
    down)
        if command -v brightnessctl >/dev/null 2>&1; then
            brightnessctl set 5%-
        fi
        ;;
    *)
        percentage
        ;;
esac
EOF

    chmod +x "$scripts_dir/brightness.sh"
    
    echo "${OK} Scripts utilitaires Waybar créés" | tee -a "$LOG"
}

# Fonction pour intégrer Waybar avec Hyprland
integrate_with_hyprland() {
    local hyprland_config="$HOME/.config/hypr/hyprland.conf"
    
    if [[ -f "$hyprland_config" ]]; then
        # Vérifier si Waybar est déjà configuré
        if ! grep -q "exec-once = waybar" "$hyprland_config"; then
            echo "" >> "$hyprland_config"
            echo "# Waybar" >> "$hyprland_config"
            echo "exec-once = waybar" >> "$hyprland_config"
            echo "${OK} Waybar ajouté au démarrage de Hyprland" | tee -a "$LOG"
        else
            echo "${NOTE} Waybar déjà configuré dans Hyprland" | tee -a "$LOG"
        fi
        
        # Ajouter des raccourcis pour Waybar
        if ! grep -q "waybar" "$hyprland_config" | grep -q "bind"; then
            echo "" >> "$hyprland_config"
            echo "# Raccourcis Waybar" >> "$hyprland_config"
            echo "bind = SUPER_SHIFT, B, exec, pkill waybar || waybar" >> "$hyprland_config"
            echo "${OK} Raccourci Waybar ajouté (Super+Shift+B)" | tee -a "$LOG"
        fi
    else
        echo "${ERROR} Configuration Hyprland non trouvée" | tee -a "$LOG"
    fi
}

# Fonction pour démarrer Waybar
start_waybar() {
    # Arrêter toute instance existante de Waybar
    pkill waybar 2>/dev/null || true
    
    # Attendre un peu
    sleep 1
    
    # Démarrer Waybar en arrière-plan
    if command -v waybar >/dev/null 2>&1; then
        waybar &
        echo "${OK} Waybar démarré" | tee -a "$LOG"
    else
        echo "${ERROR} Waybar n'est pas installé" | tee -a "$LOG"
    fi
}

# Exécution principale
main() {
    echo "${NOTE} === Installation et configuration de Waybar ===" | tee -a "$LOG"
    
    install_waybar
    create_waybar_config
    create_waybar_scripts
    integrate_with_hyprland
    
    echo "${OK} Installation de Waybar terminée" | tee -a "$LOG"
    echo "${NOTE} Redémarrez Hyprland ou utilisez Super+Shift+B pour démarrer Waybar" | tee -a "$LOG"
}

# Exécuter si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi