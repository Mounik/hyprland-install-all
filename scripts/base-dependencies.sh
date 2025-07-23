#!/bin/bash
# Installation des dépendances de base

echo "${NOTE} Installation des dépendances de base..." | tee -a "$LOG"

# Définir les paquets de base selon la distribution
base_packages=(
    "base_devel"
    "git"
    "wget"
    "curl"
    "unzip"
    "python"
    "imagemagick"
)

# Paquets spécifiques selon la famille de distribution
case $DISTRO_FAMILY in
    "arch")
        additional_packages=(
            "base-devel"
            "git"
            "wget" 
            "curl"
            "unzip"
            "python"
            "python-pip"
            "imagemagick"
            "polkit"
            "cmake"
            "meson"
            "ninja"
        )
        ;;
    "debian")
        additional_packages=(
            "build-essential"
            "git"
            "wget"
            "curl" 
            "unzip"
            "python3"
            "python3-pip"
            "imagemagick"
            "policykit-1"
            "cmake"
            "meson"
            "ninja-build"
            "pkg-config"
        )
        ;;
    "redhat")
        additional_packages=(
            "@development-tools"
            "git"
            "wget2"
            "curl"
            "unzip"
            "python3"
            "python3-pip"
            "ImageMagick"
            "polkit"
            "cmake"
            "meson"
            "ninja-build"
            "pkgconfig"
        )
        ;;
    "suse")
        additional_packages=(
            "patterns-devel-base-devel_basis"
            "git"
            "wget"
            "curl"
            "unzip"
            "python3"
            "python3-pip"
            "ImageMagick"
            "polkit"
            "cmake"
            "meson"
            "ninja"
            "pkg-config"
        )
        ;;
esac

# Installer les paquets
echo "${NOTE} Installation des paquets de base pour $DISTRO_FAMILY..." | tee -a "$LOG"

failed_packages=()
for package in "${additional_packages[@]}"; do
    if ! install_package "$package"; then
        failed_packages+=("$package")
    fi
done

# Vérifier les échecs
if [ ${#failed_packages[@]} -gt 0 ]; then
    echo "${WARN} Paquets qui ont échoué: ${failed_packages[*]}" | tee -a "$LOG"
    echo "${NOTE} Tentative d'installation individuelle..." | tee -a "$LOG"
    
    # Réessayer individuellement
    for package in "${failed_packages[@]}"; do
        echo "${NOTE} Nouvelle tentative pour $package..." | tee -a "$LOG"
        case $DISTRO_FAMILY in
            "arch")
                sudo pacman -S --noconfirm "$package" >> "$LOG" 2>&1 || echo "${WARN} $package toujours en échec" | tee -a "$LOG"
                ;;
            "debian")
                sudo apt install -y "$package" >> "$LOG" 2>&1 || echo "${WARN} $package toujours en échec" | tee -a "$LOG"
                ;;
            "redhat")
                sudo dnf install -y "$package" >> "$LOG" 2>&1 || echo "${WARN} $package toujours en échec" | tee -a "$LOG"
                ;;
            "suse")
                sudo zypper in -y "$package" >> "$LOG" 2>&1 || echo "${WARN} $package toujours en échec" | tee -a "$LOG"
                ;;
        esac
    done
fi

# Vérifications spécifiques selon la distribution
case $DISTRO_FAMILY in
    "arch")
        # Vérifier PulseAudio (doit être désinstallé)
        if pacman -Qq | grep -qw '^pulseaudio$'; then
            echo "${ERROR} PulseAudio détecté. Il doit être désinstallé avant d'installer Pipewire." | tee -a "$LOG"
            read -p "Voulez-vous désinstaller PulseAudio maintenant? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo pacman -Rns --noconfirm pulseaudio >> "$LOG" 2>&1
                echo "${OK} PulseAudio désinstallé" | tee -a "$LOG"
            else
                echo "${ERROR} Installation annulée. Désinstallez PulseAudio manuellement." | tee -a "$LOG"
                exit 1
            fi
        fi
        ;;
    "debian")
        # Vérifier les sources deb-src
        if ! grep -q "^deb-src" /etc/apt/sources.list; then
            echo "${NOTE} Activation des sources deb-src..." | tee -a "$LOG"
            sudo sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
            sudo apt update >> "$LOG" 2>&1
        fi
        ;;
esac

# Installation d'outils modernes Python (UV)
echo "${NOTE} Installation d'UV pour Python..." | tee -a "$LOG"
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh >> "$LOG" 2>&1
    if [ $? -eq 0 ]; then
        echo "${OK} UV installé avec succès" | tee -a "$LOG"
        # Ajouter au PATH
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "${WARN} Échec de l'installation d'UV, utilisation de pip standard" | tee -a "$LOG"
    fi
fi

# Installation de OpenTofu (remplacement Terraform)
echo "${NOTE} Installation d'OpenTofu..." | tee -a "$LOG"
if ! command -v tofu &>/dev/null; then
    case $DISTRO_FAMILY in
        "arch")
            if [[ -n "$AUR_HELPER" ]]; then
                $AUR_HELPER -S --noconfirm opentofu-bin >> "$LOG" 2>&1
            fi
            ;;
        *)
            # Installation via script officiel
            curl -fsSL https://get.opentofu.org/install-opentofu.sh | sudo bash >> "$LOG" 2>&1
            ;;
    esac
    
    if command -v tofu &>/dev/null; then
        echo "${OK} OpenTofu installé avec succès" | tee -a "$LOG"
    else
        echo "${WARN} Échec de l'installation d'OpenTofu" | tee -a "$LOG"
    fi
fi

echo "${OK} Installation des dépendances de base terminée" | tee -a "$LOG"