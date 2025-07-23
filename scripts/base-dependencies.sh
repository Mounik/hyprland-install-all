#!/bin/bash
# Installation des dépendances de base

# S'assurer que le logging est initialisé
ensure_log_exists

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
                sudo apt-get install -y "$package" >> "$LOG" 2>&1 || echo "${WARN} $package toujours en échec" | tee -a "$LOG"
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
            echo "Voulez-vous désinstaller PulseAudio maintenant? (y/N): "
            read -n 1 -r
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
            sudo apt-get update >> "$LOG" 2>&1
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

# Installation d'OpenTofu (Infrastructure as Code)
install_opentofu() {
    echo "${NOTE} Installation d'OpenTofu..." | tee -a "$LOG"
    
    if command -v tofu &>/dev/null; then
        echo "${OK} OpenTofu déjà installé: $(tofu version | head -1)" | tee -a "$LOG"
        return 0
    fi
    
    # Méthode 1: Script officiel universel (recommandé)
    echo "${NOTE} Utilisation du script d'installation officiel OpenTofu..." | tee -a "$LOG"
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Télécharger le script officiel avec retry
    local max_attempts=3
    local attempt=1
    local script_success=false
    
    while [ $attempt -le $max_attempts ] && [ "$script_success" = false ]; do
        echo "${NOTE} Tentative $attempt/$max_attempts du script officiel..." | tee -a "$LOG"
        
        if curl --connect-timeout 10 --max-time 30 --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh 2>&1 | tee -a "$LOG"; then
            chmod +x install-opentofu.sh
            
            # Exécuter l'installation en mode standalone
            if timeout 120 ./install-opentofu.sh --install-method standalone --skip-verify >> "$LOG" 2>&1; then
                echo "${OK} OpenTofu installé via script officiel" | tee -a "$LOG"
                script_success=true
                cd - > /dev/null
                rm -rf "$temp_dir"
                return 0
            else
                echo "${WARN} Échec de l'exécution du script (tentative $attempt)" | tee -a "$LOG"
            fi
        else
            echo "${WARN} Échec du téléchargement du script (tentative $attempt)" | tee -a "$LOG"
        fi
        
        ((attempt++))
        [ $attempt -le $max_attempts ] && sleep 3
    done
    
    if [ "$script_success" = false ]; then
        echo "${WARN} Script officiel échoué après $max_attempts tentatives, utilisation des méthodes alternatives..." | tee -a "$LOG"
    fi
    
    # Méthode 2: Gestionnaires de paquets spécifiques (fallback)
    echo "${NOTE} Utilisation des méthodes alternatives..." | tee -a "$LOG"
    
    case $DISTRO_FAMILY in
        "arch")
            if [[ -n "$AUR_HELPER" ]]; then
                echo "${NOTE} Installation via AUR..." | tee -a "$LOG"
                $AUR_HELPER -S --noconfirm opentofu-bin >> "$LOG" 2>&1
            fi
            ;;
        "debian")
            # Snap pour Ubuntu/Debian si disponible
            if command -v snap &>/dev/null; then
                echo "${NOTE} Installation via Snap..." | tee -a "$LOG"
                
                # Vérifier la connexion au Snap Store
                if snap find opentofu &>/dev/null; then
                    sudo snap install --classic opentofu 2>&1 | tee -a "$LOG"
                    
                    # Créer un lien symbolique pour compatibilité
                    if [[ ! -f /usr/local/bin/tofu ]] && [[ -f /snap/bin/tofu ]]; then
                        sudo ln -sf /snap/bin/tofu /usr/local/bin/tofu 2>/dev/null || true
                    fi
                else
                    echo "${WARN} Snap Store inaccessible, essai méthode alternative..." | tee -a "$LOG"
                fi
            else
                # Repository APT officiel
                echo "${NOTE} Installation via repository APT..." | tee -a "$LOG"
                if ! grep -q "packages.opentofu.org" /etc/apt/sources.list.d/opentofu.list 2>/dev/null; then
                    curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/opentofu.gpg >> "$LOG" 2>&1
                    echo "deb [signed-by=/usr/share/keyrings/opentofu.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list >> "$LOG" 2>&1
                    sudo apt-get update >> "$LOG" 2>&1
                fi
                sudo apt-get install -y tofu >> "$LOG" 2>&1
            fi
            ;;
        "redhat")
            # Repository YUM/DNF officiel
            echo "${NOTE} Installation via repository DNF..." | tee -a "$LOG"
            if [[ ! -f /etc/yum.repos.d/opentofu.repo ]]; then
                sudo tee /etc/yum.repos.d/opentofu.repo >> "$LOG" 2>&1 << 'EOF'
[opentofu]
name=OpenTofu repository
baseurl=https://packages.opentofu.org/opentofu/tofu/rpm/
enabled=1
gpgcheck=1
gpgkey=https://packages.opentofu.org/opentofu/tofu/gpgkey
EOF
            fi
            sudo dnf install -y tofu >> "$LOG" 2>&1
            ;;
        "suse")
            # Installation manuelle GitHub releases
            echo "${NOTE} Installation manuelle via GitHub releases..." | tee -a "$LOG"
            install_opentofu_manual
            ;;
        *)
            # Fallback: Installation manuelle
            echo "${NOTE} Installation manuelle universelle..." | tee -a "$LOG"
            install_opentofu_manual
            ;;
    esac
    
    cd - > /dev/null 2>&1
    rm -rf "$temp_dir" 2>/dev/null
    
    # Vérification finale
    if command -v tofu &>/dev/null; then
        local version=$(tofu version | head -1 2>/dev/null || echo "version inconnue")
        echo "${OK} OpenTofu installé avec succès: $version" | tee -a "$LOG"
    else
        echo "${ERROR} Échec de l'installation d'OpenTofu" | tee -a "$LOG"
        return 1
    fi
}

# Fonction d'installation manuelle pour cas particuliers
install_opentofu_manual() {
    echo "${NOTE} Installation manuelle d'OpenTofu via GitHub releases..." | tee -a "$LOG"
    
    # Obtenir la dernière version
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/opentofu/opentofu/releases/latest | grep -o '"tag_name": "v[^"]*' | grep -o 'v[^"]*' 2>/dev/null)
    
    if [[ -z "$latest_version" ]]; then
        echo "${ERROR} Impossible de récupérer la version d'OpenTofu" | tee -a "$LOG"
        return 1
    fi
    
    local download_url="https://github.com/opentofu/opentofu/releases/download/${latest_version}/tofu_${latest_version#v}_linux_amd64.zip"
    local temp_file="/tmp/tofu_${latest_version}.zip"
    
    # Télécharger
    if wget -q "$download_url" -O "$temp_file" >> "$LOG" 2>&1; then
        # Extraire et installer
        cd /tmp
        unzip -q "$temp_file" >> "$LOG" 2>&1
        sudo mv tofu /usr/local/bin/ >> "$LOG" 2>&1
        sudo chmod +x /usr/local/bin/tofu >> "$LOG" 2>&1
        rm -f "$temp_file" tofu_* >> "$LOG" 2>&1
        
        echo "${OK} OpenTofu $latest_version installé manuellement" | tee -a "$LOG"
        return 0
    else
        echo "${ERROR} Échec du téléchargement d'OpenTofu" | tee -a "$LOG"
        return 1
    fi
}

# Lancer l'installation d'OpenTofu
install_opentofu

echo "${OK} Installation des dépendances de base terminée" | tee -a "$LOG"