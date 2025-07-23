#!/bin/bash
# Installation des polices pour Hyprland Universal

echo "${NOTE} Installation des polices..." | tee -a "$LOG"

# Définir les polices selon la distribution
case $DISTRO_FAMILY in
    "arch")
        font_packages=(
            "ttf-jetbrains-mono-nerd"
            "ttf-fira-code"
            "ttf-hack-nerd"
            "noto-fonts"
            "noto-fonts-emoji"
            "ttf-font-awesome"
        )
        ;;
    "debian")
        font_packages=(
            "fonts-jetbrains-mono"
            "fonts-firacode"
            "fonts-hack"
            "fonts-noto"
            "fonts-noto-color-emoji"
            "fonts-font-awesome"
        )
        # Note: Les paquets Debian n'incluent pas les Nerd Fonts complètes
        # Elles seront installées manuellement si nécessaire
        ;;
    "redhat")
        font_packages=(
            "jetbrains-mono-fonts"
            "fira-code-fonts"
            "hack-fonts"
            "google-noto-fonts"
            "google-noto-emoji-color-fonts"
            "fontawesome-fonts"
        )
        ;;
    "suse")
        font_packages=(
            "jetbrains-mono-fonts"
            "fira-code-fonts"
            "hack-fonts"
            "noto-fonts"
            "noto-coloremoji-fonts"
            "fontawesome-fonts"
        )
        ;;
esac

# Installer les polices du système
for font in "${font_packages[@]}"; do
    install_package "$font"
done

# Installation manuelle des Nerd Fonts si nécessaire
install_nerd_fonts_manual() {
    echo "${NOTE} Installation manuelle des Nerd Fonts..." | tee -a "$LOG"
    
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    # Liste des Nerd Fonts à télécharger
    local nerd_fonts=(
        "JetBrainsMono"
        "FiraCode"
        "Hack"
        "SourceCodePro"
    )
    
    for font in "${nerd_fonts[@]}"; do
        if [ ! -d "$fonts_dir/$font" ]; then
            echo "${NOTE} Téléchargement de $font Nerd Font..." | tee -a "$LOG"
            
            # Créer le dossier pour la police
            mkdir -p "$fonts_dir/$font"
            
            # URL de téléchargement
            local download_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
            
            # Télécharger et extraire
            cd "$fonts_dir/$font"
            if wget -q "$download_url" -O "${font}.zip"; then
                unzip -q "${font}.zip"
                rm "${font}.zip"
                echo "${OK} $font Nerd Font installé" | tee -a "$LOG"
            else
                echo "${WARN} Échec du téléchargement de $font" | tee -a "$LOG"
            fi
        else
            echo "${OK} $font Nerd Font déjà installé" | tee -a "$LOG"
        fi
    done
    
    # Mettre à jour le cache des polices
    fc-cache -fv >> "$LOG" 2>&1
    echo "${OK} Cache des polices mis à jour" | tee -a "$LOG"
}

# Vérifier si les Nerd Fonts sont installées
check_nerd_fonts() {
    local required_fonts=(
        "JetBrains Mono"
        "Nerd Font"
        "Font Awesome"
        "Noto"
    )
    
    local missing_fonts=()
    
    for font in "${required_fonts[@]}"; do
        if ! fc-list | grep -i "$font" > /dev/null; then
            missing_fonts+=("$font")
        fi
    done
    
    if [[ ${#missing_fonts[@]} -eq 0 ]]; then
        echo "${OK} Toutes les polices requises sont installées" | tee -a "$LOG"
        return 0
    else
        echo "${WARN} Polices manquantes: ${missing_fonts[*]}" | tee -a "$LOG"
        return 1
    fi
}

# Installation selon la méthode disponible
if ! check_nerd_fonts; then
    case $DISTRO_FAMILY in
        "arch")
            # Utiliser AUR si disponible
            if [[ -n "$AUR_HELPER" ]]; then
                echo "${NOTE} Installation des Nerd Fonts via AUR..." | tee -a "$LOG"
                $AUR_HELPER -S --noconfirm ttf-jetbrains-mono-nerd ttf-hack-nerd ttf-fira-code-nerd >> "$LOG" 2>&1
            fi
            # Toujours tenter l'installation manuelle pour s'assurer que tout est présent
            install_nerd_fonts_manual
            ;;
        *)
            # Installation manuelle pour les autres distributions
            install_nerd_fonts_manual
            ;;
    esac
    
    # Vérification finale
    if check_nerd_fonts; then
        echo "${OK} Installation des polices terminée avec succès" | tee -a "$LOG"
    else
        echo "${WARN} Certaines polices peuvent encore manquer" | tee -a "$LOG"
    fi
fi

# Configuration des polices système
configure_fonts() {
    echo "${NOTE} Configuration des polices système..." | tee -a "$LOG"
    
    # Créer le dossier de configuration fontconfig
    mkdir -p ~/.config/fontconfig
    
    # Configuration fontconfig pour les polices
    cat > ~/.config/fontconfig/fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <alias>
        <family>monospace</family>
        <prefer>
            <family>JetBrainsMono Nerd Font</family>
            <family>Fira Code</family>
            <family>Hack Nerd Font</family>
        </prefer>
    </alias>
    
    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Noto Sans</family>
            <family>DejaVu Sans</family>
        </prefer>
    </alias>
    
    <alias>
        <family>serif</family>
        <prefer>
            <family>Noto Serif</family>
            <family>DejaVu Serif</family>
        </prefer>
    </alias>
    
    <!-- Améliorer le rendu des polices -->
    <match target="font">
        <edit name="antialias" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hinting" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
        </edit>
        <edit name="rgba" mode="assign">
            <const>rgb</const>
        </edit>
        <edit name="lcdfilter" mode="assign">
            <const>lcddefault</const>
        </edit>
    </match>
</fontconfig>
EOF
    
    echo "${OK} Configuration fontconfig créée" | tee -a "$LOG"
}

# Installer les polices d'icônes
install_icon_fonts() {
    echo "${NOTE} Installation des polices d'icônes..." | tee -a "$LOG"
    
    local icon_fonts=()
    
    case $DISTRO_FAMILY in
        "arch")
            icon_fonts=(
                "ttf-font-awesome"
                "ttf-material-design-icons"
            )
            if [[ -n "$AUR_HELPER" ]]; then
                icon_fonts+=("ttf-material-icons-git")
            fi
            ;;
        "debian")
            icon_fonts=(
                "fonts-font-awesome"
                "fonts-material-design-icons-iconfont"
            )
            ;;
        "redhat")
            icon_fonts=(
                "fontawesome-fonts"
            )
            ;;
        "suse")
            icon_fonts=(
                "fontawesome-fonts"
            )
            ;;
    esac
    
    for font in "${icon_fonts[@]}"; do
        if [[ $DISTRO_FAMILY == "arch" ]] && [[ "$font" == *"-git" ]] && [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -S --noconfirm "$font" >> "$LOG" 2>&1
        else
            install_package "$font"
        fi
    done
}

# Vérification finale des polices
verify_fonts() {
    echo "${NOTE} Vérification des polices installées..." | tee -a "$LOG"
    
    local required_fonts=(
        "JetBrains Mono"
        "Nerd Font"
        "Font Awesome"
        "Noto"
    )
    
    local missing_fonts=()
    
    for font in "${required_fonts[@]}"; do
        if ! fc-list | grep -i "$font" > /dev/null; then
            missing_fonts+=("$font")
        fi
    done
    
    if [ ${#missing_fonts[@]} -eq 0 ]; then
        echo "${OK} Toutes les polices requises sont installées" | tee -a "$LOG"
        
        # Afficher quelques polices installées
        echo "${INFO} Polices disponibles:" | tee -a "$LOG"
        fc-list | grep -i "jetbrains\|nerd\|awesome" | head -5 | tee -a "$LOG"
        
        return 0
    else
        echo "${WARN} Polices manquantes: ${missing_fonts[*]}" | tee -a "$LOG"
        return 1
    fi
}

# Appliquer la configuration des polices
configure_fonts

# Installer les polices d'icônes
install_icon_fonts

# Mettre à jour le cache final
fc-cache -fv >> "$LOG" 2>&1

# Vérification finale
verify_fonts

echo "${OK} Installation des polices terminée" | tee -a "$LOG"