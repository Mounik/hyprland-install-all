#!/bin/bash
# Configuration audio pour Hyprland Universal

echo "${NOTE} Configuration audio..." | tee -a "$LOG"

# Fonction pour vérifier et supprimer PulseAudio
remove_pulseaudio() {
    local pulseaudio_packages=()
    
    case $DISTRO_FAMILY in
        "arch")
            pulseaudio_packages=("pulseaudio" "pulseaudio-alsa")
            ;;
        "debian")
            pulseaudio_packages=("pulseaudio" "pulseaudio-utils")
            ;;
        "redhat")
            pulseaudio_packages=("pulseaudio" "pulseaudio-utils")
            ;;
        "suse")
            pulseaudio_packages=("pulseaudio" "pulseaudio-utils")
            ;;
    esac
    
    for package in "${pulseaudio_packages[@]}"; do
        if is_package_installed "$package"; then
            echo "${NOTE} PulseAudio détecté: $package" | tee -a "$LOG"
            read -p "Voulez-vous supprimer PulseAudio pour installer Pipewire? [Y/n]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                echo "${NOTE} Suppression de $package..." | tee -a "$LOG"
                uninstall_package "$package"
            else
                echo "${WARN} PulseAudio conservé. Pipewire pourrait ne pas fonctionner correctement." | tee -a "$LOG"
            fi
        fi
    done
}

# Fonction pour installer Pipewire
install_pipewire() {
    echo "${NOTE} Installation de Pipewire..." | tee -a "$LOG"
    
    local pipewire_packages=()
    
    case $DISTRO_FAMILY in
        "arch")
            pipewire_packages=(
                "pipewire"
                "pipewire-alsa"
                "pipewire-pulse"
                "pipewire-jack"
                "wireplumber"
                "pamixer"
                "pavucontrol"
            )
            ;;
        "debian")
            pipewire_packages=(
                "pipewire"
                "pipewire-alsa"
                "pipewire-pulse"
                "pipewire-jack"
                "wireplumber"
                "pamixer"
                "pavucontrol"
            )
            ;;
        "redhat")
            pipewire_packages=(
                "pipewire"
                "pipewire-alsa"
                "pipewire-pulseaudio"
                "pipewire-jack-audio-connection-kit"
                "wireplumber"
                "pamixer"
                "pavucontrol"
            )
            ;;
        "suse")
            pipewire_packages=(
                "pipewire"
                "pipewire-alsa"
                "pipewire-pulseaudio"
                "pipewire-libjack-0_3"
                "wireplumber"
                "pamixer"
                "pavucontrol"
            )
            ;;
    esac
    
    # Installer les paquets Pipewire
    for package in "${pipewire_packages[@]}"; do
        install_package "$package"
    done
}

# Fonction pour configurer Pipewire
configure_pipewire() {
    echo "${NOTE} Configuration de Pipewire..." | tee -a "$LOG"
    
    # Créer les dossiers de configuration
    mkdir -p ~/.config/pipewire
    mkdir -p ~/.config/wireplumber
    
    # Activer les services utilisateur
    systemctl --user enable pipewire.service >> "$LOG" 2>&1
    systemctl --user enable pipewire-pulse.service >> "$LOG" 2>&1
    systemctl --user enable wireplumber.service >> "$LOG" 2>&1
    
    # Démarrer les services
    systemctl --user start pipewire.service >> "$LOG" 2>&1
    systemctl --user start pipewire-pulse.service >> "$LOG" 2>&1
    systemctl --user start wireplumber.service >> "$LOG" 2>&1
    
    echo "${OK} Services Pipewire activés" | tee -a "$LOG"
}

# Fonction pour installer les codecs audio
install_audio_codecs() {
    echo "${NOTE} Installation des codecs audio..." | tee -a "$LOG"
    
    local codec_packages=()
    
    case $DISTRO_FAMILY in
        "arch")
            codec_packages=(
                "gst-plugins-good"
                "gst-plugins-bad"
                "gst-plugins-ugly"
                "gst-libav"
            )
            ;;
        "debian")
            codec_packages=(
                "gstreamer1.0-plugins-good"
                "gstreamer1.0-plugins-bad"
                "gstreamer1.0-plugins-ugly"
                "gstreamer1.0-libav"
            )
            ;;
        "redhat")
            # RPM Fusion requis pour les codecs propriétaires
            codec_packages=(
                "gstreamer1-plugins-good"
                "gstreamer1-plugins-bad-free"
                "gstreamer1-plugins-ugly"
                "gstreamer1-libav"
            )
            ;;
        "suse")
            # Packman repo requis
            codec_packages=(
                "gstreamer-plugins-good"
                "gstreamer-plugins-bad"
                "gstreamer-plugins-ugly"
                "gstreamer-plugins-libav"
            )
            ;;
    esac
    
    for package in "${codec_packages[@]}"; do
        install_package "$package"
    done
}

# Fonction pour configurer les contrôles audio
setup_audio_controls() {
    echo "${NOTE} Configuration des contrôles audio..." | tee -a "$LOG"
    
    # Vérifier si les contrôles audio fonctionnent
    if command -v pamixer &>/dev/null; then
        echo "${OK} pamixer disponible pour les contrôles audio" | tee -a "$LOG"
    else
        echo "${WARN} pamixer non disponible" | tee -a "$LOG"
    fi
    
    if command -v pactl &>/dev/null; then
        echo "${OK} pactl disponible pour les contrôles audio" | tee -a "$LOG"
    else
        echo "${WARN} pactl non disponible" | tee -a "$LOG"
    fi
}

# Fonction pour tester l'audio
test_audio_setup() {
    echo "${NOTE} Test de la configuration audio..." | tee -a "$LOG"
    
    # Vérifier si Pipewire fonctionne
    if systemctl --user is-active pipewire.service &>/dev/null; then
        echo "${OK} Service Pipewire actif" | tee -a "$LOG"
    else
        echo "${ERROR} Service Pipewire inactif" | tee -a "$LOG"
        return 1
    fi
    
    if systemctl --user is-active pipewire-pulse.service &>/dev/null; then
        echo "${OK} Service Pipewire-Pulse actif" | tee -a "$LOG"
    else
        echo "${ERROR} Service Pipewire-Pulse inactif" | tee -a "$LOG"
        return 1
    fi
    
    if systemctl --user is-active wireplumber.service &>/dev/null; then
        echo "${OK} Service WirePlumber actif" | tee -a "$LOG"
    else
        echo "${ERROR} Service WirePlumber inactif" | tee -a "$LOG"
        return 1
    fi
    
    # Tester les périphériques audio
    if command -v pactl &>/dev/null; then
        local audio_devices=$(pactl list short sinks 2>/dev/null | wc -l)
        if [ "$audio_devices" -gt 0 ]; then
            echo "${OK} $audio_devices périphérique(s) audio détecté(s)" | tee -a "$LOG"
        else
            echo "${WARN} Aucun périphérique audio détecté" | tee -a "$LOG"
        fi
    fi
    
    return 0
}

# Fonction pour créer des aliases audio
create_audio_aliases() {
    echo "${NOTE} Création des aliases audio..." | tee -a "$LOG"
    
    # Ajouter des aliases pour les contrôles audio
    local aliases_file="$HOME/.bashrc"
    if [ -f "$HOME/.zshrc" ]; then
        aliases_file="$HOME/.zshrc"
    fi
    
    # Vérifier si les aliases existent déjà
    if ! grep -q "# Audio aliases" "$aliases_file" 2>/dev/null; then
        cat >> "$aliases_file" << 'EOF'

# Audio aliases
alias vol-up='pamixer -i 5'
alias vol-down='pamixer -d 5'
alias vol-mute='pamixer -t'
alias vol-status='pamixer --get-volume'
alias audio-restart='systemctl --user restart pipewire pipewire-pulse wireplumber'
alias audio-status='systemctl --user status pipewire pipewire-pulse wireplumber'
EOF
        echo "${OK} Aliases audio ajoutés à $aliases_file" | tee -a "$LOG"
    fi
}

# Fonction pour corriger les problèmes audio courants
fix_common_audio_issues() {
    echo "${NOTE} Correction des problèmes audio courants..." | tee -a "$LOG"
    
    # S'assurer que l'utilisateur est dans le groupe audio
    if ! groups | grep -q audio; then
        echo "${NOTE} Ajout de l'utilisateur au groupe audio..." | tee -a "$LOG"
        sudo usermod -a -G audio "$USER"
        echo "${OK} Utilisateur ajouté au groupe audio (redémarrage requis)" | tee -a "$LOG"
    fi
    
    # Configurer les permissions pour /dev/snd
    if [ -d "/dev/snd" ]; then
        echo "${OK} Périphériques audio détectés dans /dev/snd" | tee -a "$LOG"
    else
        echo "${WARN} Répertoire /dev/snd non trouvé" | tee -a "$LOG"
    fi
    
    # Créer une configuration par défaut pour WirePlumber si nécessaire
    if [ ! -f ~/.config/wireplumber/main.lua.d/50-alsa-config.lua ]; then
        mkdir -p ~/.config/wireplumber/main.lua.d
        cat > ~/.config/wireplumber/main.lua.d/50-alsa-config.lua << 'EOF'
-- Configuration ALSA pour WirePlumber
alsa_monitor.properties = {
  -- Réduire la latence
  ["alsa.jack-device"] = false,
  ["alsa.reserve"] = false,
}
EOF
        echo "${OK} Configuration WirePlumber créée" | tee -a "$LOG"
    fi
}

# Exécution principale
main_audio_setup() {
    # 1. Vérifier et supprimer PulseAudio si nécessaire
    remove_pulseaudio
    
    # 2. Installer Pipewire
    install_pipewire
    
    # 3. Configurer Pipewire
    configure_pipewire
    
    # 4. Installer les codecs audio
    install_audio_codecs
    
    # 5. Configurer les contrôles
    setup_audio_controls
    
    # 6. Corriger les problèmes courants
    fix_common_audio_issues
    
    # 7. Créer les aliases
    create_audio_aliases
    
    # 8. Tester la configuration
    sleep 2  # Laisser le temps aux services de démarrer
    test_audio_setup
}

# Lancer la configuration audio
main_audio_setup

echo "${OK} Configuration audio terminée" | tee -a "$LOG"
echo "${INFO} Redémarrez votre session pour appliquer tous les changements audio" | tee -a "$LOG"