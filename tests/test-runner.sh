#!/bin/bash
# Test runner pour Hyprland Universal

# Source des fonctions nécessaires
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

source "$LIB_DIR/global-functions.sh"
source "$LIB_DIR/distro-detection.sh"

# Variables de test
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo "${NOTE} Test: $test_name" | tee -a "$LOG"
    ((TESTS_TOTAL++))
    
    if $test_function; then
        echo "${OK} ✓ $test_name" | tee -a "$LOG"
        ((TESTS_PASSED++))
        return 0
    else
        echo "${ERROR} ✗ $test_name" | tee -a "$LOG"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Tests de détection de distribution
test_distribution_detection() {
    [[ -n "$DISTRO_ID" ]] && [[ -n "$DISTRO_FAMILY" ]]
}

test_package_manager_available() {
    case $DISTRO_FAMILY in
        "arch") command -v pacman &>/dev/null ;;
        "debian") command -v apt &>/dev/null ;;
        "redhat") command -v dnf &>/dev/null || command -v yum &>/dev/null ;;
        "suse") command -v zypper &>/dev/null ;;
        *) return 1 ;;
    esac
}

# Tests de dépendances de base
test_base_dependencies() {
    local required_commands=("git" "wget" "curl" "python3")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "${ERROR} Commande manquante: $cmd"
            return 1
        fi
    done
    return 0
}

test_build_tools() {
    local build_tools=("make" "cmake")
    
    case $DISTRO_FAMILY in
        "arch"|"redhat"|"suse") build_tools+=("ninja") ;;
        "debian") build_tools+=("ninja-build") ;;
    esac
    
    for tool in "${build_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            echo "${ERROR} Outil de build manquant: $tool"
            return 1
        fi
    done
    return 0
}

# Tests Hyprland
test_hyprland_installed() {
    command -v Hyprland &>/dev/null || command -v hyprland &>/dev/null
}

test_hyprland_config() {
    [[ -f ~/.config/hypr/hyprland.conf ]]
}

test_wayland_session() {
    [[ -f /usr/share/wayland-sessions/hyprland.desktop ]] || \
    [[ -f /usr/local/share/wayland-sessions/hyprland.desktop ]]
}

# Tests de l'écosystème
test_waybar_installed() {
    command -v waybar &>/dev/null
}

test_terminal_installed() {
    command -v alacritty &>/dev/null || command -v kitty &>/dev/null
}

test_launcher_installed() {
    command -v wofi &>/dev/null || command -v rofi &>/dev/null
}

# Tests audio
test_pipewire_running() {
    systemctl --user is-active pipewire &>/dev/null || \
    pgrep -x pipewire &>/dev/null
}

test_audio_controls() {
    command -v pactl &>/dev/null || command -v pamixer &>/dev/null
}

# Tests graphiques
test_gpu_drivers() {
    if detect_nvidia; then
        # Tester les drivers NVIDIA
        nvidia-smi &>/dev/null || return 1
    fi
    
    # Tester les drivers génériques
    [[ -d /dev/dri ]] || return 1
    return 0
}

# Tests réseau et connexion
test_internet_connection() {
    ping -c 1 -W 3 8.8.8.8 &>/dev/null
}

# Tests de polices
test_fonts_installed() {
    fc-list | grep -i "nerd\|jetbrains" &>/dev/null
}

# Tests de thèmes
test_gtk_themes() {
    [[ -d ~/.themes ]] || [[ -d /usr/share/themes ]]
}

# Tests spécifiques à la distribution
test_arch_specific() {
    if [[ $DISTRO_FAMILY == "arch" ]]; then
        # Tester l'helper AUR
        command -v yay &>/dev/null || command -v paru &>/dev/null
    else
        return 0  # Skip pour les autres distributions
    fi
}

test_debian_specific() {
    if [[ $DISTRO_FAMILY == "debian" ]]; then
        # Vérifier les sources
        grep -q "deb-src" /etc/apt/sources.list || \
        find /etc/apt/sources.list.d -name "*.list" | xargs grep -l "deb-src" &>/dev/null
    else
        return 0
    fi
}

# Test de performance système
test_system_resources() {
    local total_ram=$(free -m | awk 'NR==2{print $2}')
    local available_space=$(df / | awk 'NR==2{print $4}')
    
    # Minimum 4GB RAM et 10GB espace libre
    [[ $total_ram -gt 4000 ]] && [[ $available_space -gt 10000000 ]]
}

# Fonction principale des tests
run_all_tests() {
    echo "${INFO} Démarrage des tests d'installation..." | tee -a "$LOG"
    echo "${INFO} Distribution: $DISTRO_NAME ($DISTRO_FAMILY)" | tee -a "$LOG"
    
    # Tests système de base
    run_test "Détection de distribution" test_distribution_detection
    run_test "Gestionnaire de paquets disponible" test_package_manager_available
    run_test "Connexion internet" test_internet_connection
    run_test "Ressources système suffisantes" test_system_resources
    
    # Tests des dépendances
    run_test "Dépendances de base installées" test_base_dependencies
    run_test "Outils de compilation installés" test_build_tools
    
    # Tests Hyprland
    run_test "Hyprland installé" test_hyprland_installed
    run_test "Configuration Hyprland présente" test_hyprland_config
    run_test "Session Wayland configurée" test_wayland_session
    
    # Tests écosystème
    run_test "Waybar installé" test_waybar_installed
    run_test "Terminal installé" test_terminal_installed
    run_test "Lanceur d'applications installé" test_launcher_installed
    
    # Tests système
    run_test "Pilotes graphiques fonctionnels" test_gpu_drivers
    run_test "Pipewire en cours d'exécution" test_pipewire_running
    run_test "Contrôles audio disponibles" test_audio_controls
    
    # Tests apparence
    run_test "Polices installées" test_fonts_installed
    run_test "Thèmes GTK disponibles" test_gtk_themes
    
    # Tests spécifiques à la distribution
    run_test "Configuration spécifique Arch" test_arch_specific
    run_test "Configuration spécifique Debian" test_debian_specific
}

# Test de validation post-installation
test_post_install_validation() {
    echo "${NOTE} Tests de validation post-installation..." | tee -a "$LOG"
    
    # Vérifier que Hyprland peut démarrer (mode dry-run)
    if command -v Hyprland &>/dev/null; then
        # Test de syntaxe de configuration
        if Hyprland --help &>/dev/null; then
            echo "${OK} Hyprland peut s'exécuter" | tee -a "$LOG"
        else
            echo "${ERROR} Problems avec l'exécutable Hyprland" | tee -a "$LOG"
            return 1
        fi
    fi
    
    # Vérifier les permissions
    if [[ ! -w ~/.config ]]; then
        echo "${ERROR} Permissions insuffisantes dans ~/.config" | tee -a "$LOG"
        return 1
    fi
    
    return 0
}

# Fonction pour générer un rapport
generate_report() {
    echo "" | tee -a "$LOG"
    echo "╔══════════════════════════════════════════════════════════════╗" | tee -a "$LOG"
    echo "║                    RAPPORT DE TESTS                         ║" | tee -a "$LOG"
    echo "╠══════════════════════════════════════════════════════════════╣" | tee -a "$LOG"
    echo "║ Distribution: $DISTRO_NAME ($DISTRO_FAMILY)" | tee -a "$LOG"
    echo "║ Tests exécutés: $TESTS_TOTAL" | tee -a "$LOG"
    echo "║ Tests réussis:  $TESTS_PASSED" | tee -a "$LOG"
    echo "║ Tests échoués:  $TESTS_FAILED" | tee -a "$LOG"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo "║ Statut: ${GREEN}SUCCÈS${RESET}" | tee -a "$LOG"
        echo "╚══════════════════════════════════════════════════════════════╝" | tee -a "$LOG"
        echo "" | tee -a "$LOG"
        echo "${OK} Tous les tests sont passés! Installation validée." | tee -a "$LOG"
        return 0
    else
        echo "║ Statut: ${RED}ÉCHEC${RESET}" | tee -a "$LOG"
        echo "╚══════════════════════════════════════════════════════════════╝" | tee -a "$LOG"
        echo "" | tee -a "$LOG"
        echo "${ERROR} $TESTS_FAILED tests ont échoué. Vérifiez les logs." | tee -a "$LOG"
        return 1
    fi
}

# Point d'entrée principal
main() {
    # Initialiser la détection
    detect_distribution
    
    # Exécuter tous les tests
    run_all_tests
    
    # Tests post-installation
    run_test "Validation post-installation" test_post_install_validation
    
    # Générer le rapport
    generate_report
}

# Permettre l'exécution en tant que script indépendant
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi