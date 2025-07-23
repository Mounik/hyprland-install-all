#!/bin/bash
# Détection de distribution pour Hyprland Universal

# Variables globales de distribution
DISTRO_ID=""
DISTRO_NAME=""
DISTRO_VERSION=""
DISTRO_CODENAME=""

# Fonction principale de détection
detect_distribution() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        DISTRO_ID="${ID,,}"  # Convertir en minuscules
        DISTRO_NAME="$NAME"
        DISTRO_VERSION="$VERSION_ID"
        DISTRO_CODENAME="$VERSION_CODENAME"
    else
        # Fallback pour les environnements de test (comme Windows/WSL)
        echo "${WARN} /etc/os-release non trouvé, utilisation de valeurs par défaut pour les tests" | tee -a "$LOG"
        DISTRO_ID="ubuntu"
        DISTRO_NAME="Ubuntu (Test Environment)"
        DISTRO_VERSION="22.04"
        DISTRO_CODENAME="jammy"
    fi
    
    # Normaliser certains IDs de distribution
    case $DISTRO_ID in
        "ubuntu"|"pop"|"elementary"|"linuxmint")
            DISTRO_FAMILY="debian"
            ;;
        "debian")
            DISTRO_FAMILY="debian"
            ;;
        "arch"|"manjaro"|"endeavouros"|"garuda")
            DISTRO_FAMILY="arch"
            ;;
        "fedora"|"centos"|"rhel"|"rocky"|"alma")
            DISTRO_FAMILY="redhat"
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed"|"sled"|"sles")
            DISTRO_FAMILY="suse"
            ;;
        *)
            echo "${WARN} Distribution $DISTRO_ID non testée, tentative de détection automatique..."
            detect_package_manager_fallback
            ;;
    esac
    
    # Vérifier la compatibilité
    if ! is_distribution_supported; then
        echo "${ERROR} Distribution $DISTRO_ID non supportée" | tee -a "$LOG"
        echo "${INFO} Distributions supportées: Arch, Debian, Ubuntu, Fedora, OpenSuse"
        exit 1
    fi
    
    # Afficher les informations détectées
    echo "${INFO} Distribution: $DISTRO_NAME" | tee -a "$LOG"
    echo "${INFO} Version: $DISTRO_VERSION" | tee -a "$LOG"
    echo "${INFO} Famille: $DISTRO_FAMILY" | tee -a "$LOG"
}

# Fonction de fallback pour détecter le gestionnaire de paquets
detect_package_manager_fallback() {
    if command -v pacman &>/dev/null; then
        DISTRO_FAMILY="arch"
        echo "${NOTE} Gestionnaire pacman détecté, assumant famille Arch"
    elif command -v apt &>/dev/null; then
        DISTRO_FAMILY="debian"
        echo "${NOTE} Gestionnaire apt détecté, assumant famille Debian"
    elif command -v dnf &>/dev/null; then
        DISTRO_FAMILY="redhat"
        echo "${NOTE} Gestionnaire dnf détecté, assumant famille RedHat"
    elif command -v yum &>/dev/null; then
        DISTRO_FAMILY="redhat"
        echo "${NOTE} Gestionnaire yum détecté, assumant famille RedHat"
    elif command -v zypper &>/dev/null; then
        DISTRO_FAMILY="suse"
        echo "${NOTE} Gestionnaire zypper détecté, assumant famille SUSE"
    else
        echo "${ERROR} Aucun gestionnaire de paquets supporté détecté"
        exit 1
    fi
}

# Vérifier si la distribution est supportée
is_distribution_supported() {
    case $DISTRO_FAMILY in
        "arch"|"debian"|"redhat"|"suse")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Fonction pour obtenir des informations spécifiques à la distribution
get_distro_info() {
    case $1 in
        "package_manager")
            case $DISTRO_FAMILY in
                "arch") echo "pacman" ;;
                "debian") echo "apt" ;;
                "redhat") echo "dnf" ;;
                "suse") echo "zypper" ;;
            esac
            ;;
        "update_command")
            case $DISTRO_FAMILY in
                "arch") echo "sudo pacman -Sy" ;;
                "debian") echo "sudo apt update" ;;
                "redhat") echo "sudo dnf check-update" ;;
                "suse") echo "sudo zypper refresh" ;;
            esac
            ;;
        "install_command")
            case $DISTRO_FAMILY in
                "arch") echo "sudo pacman -S --noconfirm" ;;
                "debian") echo "sudo apt install -y" ;;
                "redhat") echo "sudo dnf install -y" ;;
                "suse") echo "sudo zypper in -y" ;;
            esac
            ;;
        "remove_command")
            case $DISTRO_FAMILY in
                "arch") echo "sudo pacman -Rns --noconfirm" ;;
                "debian") echo "sudo apt remove -y" ;;
                "redhat") echo "sudo dnf remove -y" ;;
                "suse") echo "sudo zypper rm -y" ;;
            esac
            ;;
        "query_command")
            case $DISTRO_FAMILY in
                "arch") echo "pacman -Q" ;;
                "debian") echo "dpkg -l | grep -q -w" ;;
                "redhat") echo "rpm -q" ;;
                "suse") echo "zypper se -i" ;;
            esac
            ;;
    esac
}

# Fonction pour détecter la version spécifique et adapter les paquets
get_version_specific_packages() {
    local package_type=$1
    
    case $DISTRO_ID in
        "ubuntu")
            case $DISTRO_VERSION in
                "22.04")
                    # Paquets spécifiques à Ubuntu 22.04
                    ;;
                "24.04")
                    # Paquets spécifiques à Ubuntu 24.04
                    ;;
            esac
            ;;
        "debian")
            case $DISTRO_VERSION in
                "11")
                    # Paquets spécifiques à Debian 11
                    ;;
                "12")
                    # Paquets spécifiques à Debian 12
                    ;;
            esac
            ;;
        "fedora")
            case $DISTRO_VERSION in
                "39"|"40"|"41")
                    # Paquets spécifiques aux versions récentes de Fedora
                    ;;
            esac
            ;;
    esac
}

# Fonction pour vérifier les dépôts spéciaux requis
check_special_repositories() {
    case $DISTRO_FAMILY in
        "arch")
            # Vérifier AUR helper
            if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
                echo "${NOTE} Installation d'un helper AUR requis"
                return 1
            fi
            ;;
        "redhat")
            # Vérifier COPR pour Fedora
            if [[ $DISTRO_ID == "fedora" ]]; then
                if ! dnf copr list &>/dev/null; then
                    echo "${NOTE} Plugin COPR requis pour Fedora"
                fi
            fi
            ;;
        "suse")
            # Vérifier Packman repo
            if ! zypper lr | grep -q packman; then
                echo "${NOTE} Dépôt Packman requis pour OpenSuse"
            fi
            ;;
    esac
    return 0
}

echo "${OK} Module de détection de distribution chargé" | tee -a "${LOG:-/dev/null}"