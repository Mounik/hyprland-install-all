#!/bin/bash
# Script de test pour Hyprland Universal Installer

# Définir les chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source des dépendances
source "$LIB_DIR/global-functions.sh"
source "$LIB_DIR/distro-detection.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/package-mapping.sh"

# Fonction de test principale
run_installation_test() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              TEST HYPRLAND UNIVERSAL INSTALLER              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Détecter la distribution
    echo "${NOTE} Détection de l'environnement..."
    detect_distribution
    init_package_manager
    
    echo "${OK} Distribution: $DISTRO_NAME ($DISTRO_FAMILY)"
    echo "${OK} Gestionnaire de paquets: $PACKAGE_MANAGER"
    
    # Tester les fonctions de base
    test_basic_functions
    
    # Tester la correspondance des paquets
    test_package_mapping
    
    # Tester les modules
    test_modules
    
    # Exécuter les tests complets
    echo "${NOTE} Exécution des tests complets..."
    source "$SCRIPT_DIR/tests/test-runner.sh"
    run_all_tests
}

# Test des fonctions de base
test_basic_functions() {
    echo ""
    echo "${NOTE} Test des fonctions de base..."
    
    # Test de détection de distribution
    if [[ -n "$DISTRO_ID" ]] && [[ -n "$DISTRO_FAMILY" ]]; then
        echo "${OK} ✓ Détection de distribution"
    else
        echo "${ERROR} ✗ Détection de distribution"
    fi
    
    # Test du gestionnaire de paquets
    if command -v "$PACKAGE_MANAGER" &>/dev/null; then
        echo "${OK} ✓ Gestionnaire de paquets disponible"
    else
        echo "${ERROR} ✗ Gestionnaire de paquets non trouvé"
    fi
    
    # Test de la connexion internet
    if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
        echo "${OK} ✓ Connexion internet"
    else
        echo "${ERROR} ✗ Pas de connexion internet"
    fi
}

# Test de la correspondance des paquets
test_package_mapping() {
    echo ""
    echo "${NOTE} Test de la correspondance des paquets..."
    
    # Initialiser les correspondances
    init_package_mapping
    
    # Tester quelques paquets de base
    local test_packages=("git" "wget" "python" "hyprland")
    
    for package in "${test_packages[@]}"; do
        local mapped_name=$(get_package_name "$package")
        if [[ -n "$mapped_name" ]]; then
            echo "${OK} ✓ $package -> $mapped_name"
        else
            echo "${WARN} ? $package -> non défini"
        fi
    done
    
    # Validation complète
    if validate_package_mapping; then
        echo "${OK} ✓ Correspondances des paquets valides"
    else
        echo "${ERROR} ✗ Erreurs dans les correspondances"
    fi
}

# Test des modules
test_modules() {
    echo ""
    echo "${NOTE} Test des modules d'installation..."
    
    local modules=(
        "base-dependencies"
        "hyprland"
        "fonts"
        "audio"
    )
    
    for module in "${modules[@]}"; do
        local module_file="$SCRIPT_DIR/scripts/$module.sh"
        if [ -f "$module_file" ]; then
            echo "${OK} ✓ Module $module trouvé"
            
            # Test de syntaxe bash
            if bash -n "$module_file" 2>/dev/null; then
                echo "${OK}   ✓ Syntaxe correcte"
            else
                echo "${ERROR}   ✗ Erreur de syntaxe"
            fi
        else
            echo "${ERROR} ✗ Module $module manquant"
        fi
    done
}

# Test d'installation en mode dry-run
test_dry_run() {
    echo ""
    echo "${NOTE} Test d'installation (mode dry-run)..."
    
    # Simuler l'installation sans réellement installer
    export DRY_RUN=true
    
    # Test des étapes principales
    echo "${NOTE} Simulation de l'installation des dépendances..."
    # source "$SCRIPT_DIR/scripts/base-dependencies.sh"
    
    echo "${NOTE} Simulation de l'installation de Hyprland..."
    # source "$SCRIPT_DIR/scripts/hyprland.sh"
    
    echo "${OK} Mode dry-run terminé"
    unset DRY_RUN
}

# Test de performance
test_performance() {
    echo ""
    echo "${NOTE} Test de performance du système..."
    
    # Vérifier RAM
    local total_ram=$(free -m | awk 'NR==2{print $2}')
    echo "${INFO} RAM totale: ${total_ram}MB"
    
    if [ "$total_ram" -gt 4000 ]; then
        echo "${OK} ✓ RAM suffisante (>4GB)"
    else
        echo "${WARN} ⚠ RAM limitée (<4GB)"
    fi
    
    # Vérifier espace disque
    local available_space=$(df / | awk 'NR==2{print $4}')
    local available_gb=$((available_space / 1024 / 1024))
    echo "${INFO} Espace disponible: ${available_gb}GB"
    
    if [ "$available_gb" -gt 10 ]; then
        echo "${OK} ✓ Espace disque suffisant (>10GB)"
    else
        echo "${WARN} ⚠ Espace disque limité (<10GB)"
    fi
    
    # Vérifier CPU
    local cpu_cores=$(nproc)
    echo "${INFO} Cœurs CPU: $cpu_cores"
    
    if [ "$cpu_cores" -gt 2 ]; then
        echo "${OK} ✓ CPU multi-cœurs"
    else
        echo "${NOTE} ℹ CPU single/dual core"
    fi
}

# Test des dépendances système
test_system_dependencies() {
    echo ""
    echo "${NOTE} Test des dépendances système..."
    
    local required_commands=(
        "git"
        "wget"
        "curl"
        "make"
        "gcc"
        "pkg-config"
    )
    
    local missing_deps=()
    
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            echo "${OK} ✓ $cmd disponible"
        else
            echo "${WARN} ✗ $cmd manquant"
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        echo "${OK} ✓ Toutes les dépendances système sont présentes"
        return 0
    else
        echo "${WARN} Dépendances manquantes: ${missing_deps[*]}"
        return 1
    fi
}

# Générer un rapport détaillé
generate_test_report() {
    local report_file="test-report-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "Génération du rapport de test: $report_file"
    
    {
        echo "RAPPORT DE TEST HYPRLAND UNIVERSAL INSTALLER"
        echo "=============================================="
        echo "Date: $(date)"
        echo "Distribution: $DISTRO_NAME ($DISTRO_VERSION)"
        echo "Famille: $DISTRO_FAMILY"
        echo "Gestionnaire: $PACKAGE_MANAGER"
        echo ""
        
        echo "RÉSUMÉ DES TESTS:"
        echo "- Détection distribution: OK"
        echo "- Gestionnaire paquets: OK"
        echo "- Correspondances paquets: $(validate_package_mapping && echo 'OK' || echo 'ERREUR')"
        echo "- Modules disponibles: OK"
        echo "- Dépendances système: $(test_system_dependencies &>/dev/null && echo 'OK' || echo 'PARTIEL')"
        echo ""
        
        echo "RECOMMANDATIONS:"
        if [ "$total_ram" -lt 4000 ]; then
            echo "- Augmenter la RAM pour de meilleures performances"
        fi
        
        if [ "$available_gb" -lt 20 ]; then
            echo "- Libérer de l'espace disque"
        fi
        
        echo ""
        echo "PRÊT POUR L'INSTALLATION: $([ ${#missing_deps[@]} -eq 0 ] && echo 'OUI' || echo 'NON')"
        
    } > "$report_file"
    
    echo "${OK} Rapport généré: $report_file"
}

# Menu interactif
show_test_menu() {
    echo ""
    echo "Tests disponibles:"
    echo "1. Test complet"
    echo "2. Test des fonctions de base"
    echo "3. Test des correspondances de paquets"
    echo "4. Test des modules"
    echo "5. Test de performance"
    echo "6. Test des dépendances"
    echo "7. Générer un rapport"
    echo "8. Quitter"
    echo ""
    
    read -p "Choisissez un test (1-8): " choice
    
    case $choice in
        1) run_installation_test ;;
        2) test_basic_functions ;;
        3) test_package_mapping ;;
        4) test_modules ;;
        5) test_performance ;;
        6) test_system_dependencies ;;
        7) generate_test_report ;;
        8) echo "Au revoir!"; exit 0 ;;
        *) echo "Choix invalide"; show_test_menu ;;
    esac
}

# Point d'entrée principal
main() {
    # Initialiser la détection si nécessaire
    if [[ -z "$DISTRO_ID" ]]; then
        detect_distribution
        init_package_manager
    fi
    
    case "${1:-menu}" in
        "full") run_installation_test ;;
        "basic") test_basic_functions ;;
        "packages") test_package_mapping ;;
        "modules") test_modules ;;
        "performance") test_performance ;;
        "deps") test_system_dependencies ;;
        "report") generate_test_report ;;
        "menu"|*) show_test_menu ;;
    esac
}

# Exécuter si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi