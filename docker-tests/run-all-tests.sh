#!/bin/bash
# Script pour tester Hyprland Universal sur toutes les distributions avec Docker

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPRLAND_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Distributions à tester
DISTRIBUTIONS=("arch" "ubuntu" "debian" "fedora" "opensuse")

# Créer le dossier de résultats
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              HYPRLAND UNIVERSAL - TESTS DOCKER              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Fonction pour logger
log() {
    echo -e "$1" | tee -a "$RESULTS_DIR/test-summary-$TIMESTAMP.log"
}

# Fonction pour tester une distribution
test_distribution() {
    local distro=$1
    local dockerfile_dir="$SCRIPT_DIR/$distro"
    local image_name="hyprland-universal-test-$distro"
    local container_name="hyprland-test-$distro-$TIMESTAMP"
    local result_file="$RESULTS_DIR/test-$distro-$TIMESTAMP.log"
    
    log "${BLUE}=== Test de $distro ===${NC}"
    
    # Vérifier que le Dockerfile existe
    if [ ! -f "$dockerfile_dir/Dockerfile" ]; then
        log "${RED}❌ Dockerfile non trouvé pour $distro${NC}"
        return 1
    fi
    
    # Construire l'image Docker
    log "${YELLOW}🔨 Construction de l'image Docker pour $distro...${NC}"
    if ! docker build -t "$image_name" "$dockerfile_dir" --build-context default="$HYPRLAND_DIR" > "$result_file" 2>&1; then
        log "${RED}❌ Échec de la construction de l'image pour $distro${NC}"
        return 1
    fi
    
    # Exécuter les tests dans le container
    log "${YELLOW}🧪 Exécution des tests pour $distro...${NC}"
    local exit_code=0
    
    # Copier les fichiers dans le container et exécuter les tests
    if ! docker run --name "$container_name" --rm \
        -v "$HYPRLAND_DIR:/tmp/hyprland-universal:ro" \
        "$image_name" \
        bash -c "
            cp -r /tmp/hyprland-universal/* /home/testuser/hyprland-universal/ && \
            chown -R testuser:testuser /home/testuser/hyprland-universal && \
            chmod +x /home/testuser/hyprland-universal/install.sh && \
            chmod +x /home/testuser/hyprland-universal/test-installation.sh && \
            chmod +x /home/testuser/hyprland-universal/scripts/*.sh && \
            su testuser -c 'cd /home/testuser/hyprland-universal && ./test-installation.sh full'
        " >> "$result_file" 2>&1; then
        exit_code=1
    fi
    
    # Analyser les résultats
    if [ $exit_code -eq 0 ]; then
        log "${GREEN}✅ Tests réussis pour $distro${NC}"
        echo "$distro: SUCCESS" >> "$RESULTS_DIR/summary-$TIMESTAMP.txt"
        return 0
    else
        log "${RED}❌ Tests échoués pour $distro${NC}"
        echo "$distro: FAILED" >> "$RESULTS_DIR/summary-$TIMESTAMP.txt"
        
        # Afficher les dernières lignes d'erreur
        log "${RED}Dernières erreur pour $distro:${NC}"
        tail -10 "$result_file" | tee -a "$RESULTS_DIR/test-summary-$TIMESTAMP.log"
        return 1
    fi
}

# Fonction pour nettoyer les images Docker
cleanup_docker() {
    log "${YELLOW}🧹 Nettoyage des images Docker...${NC}"
    for distro in "${DISTRIBUTIONS[@]}"; do
        local image_name="hyprland-universal-test-$distro"
        if docker images | grep -q "$image_name"; then
            docker rmi "$image_name" >/dev/null 2>&1 || true
        fi
    done
}

# Fonction pour générer un rapport détaillé
generate_report() {
    local report_file="$RESULTS_DIR/report-$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# Rapport de Tests Hyprland Universal

**Date:** $(date)  
**Timestamp:** $TIMESTAMP

## Résumé des Tests

EOF

    local total_tests=0
    local successful_tests=0
    
    for distro in "${DISTRIBUTIONS[@]}"; do
        total_tests=$((total_tests + 1))
        if grep -q "$distro: SUCCESS" "$RESULTS_DIR/summary-$TIMESTAMP.txt" 2>/dev/null; then
            echo "- ✅ **$distro**: SUCCÈS" >> "$report_file"
            successful_tests=$((successful_tests + 1))
        else
            echo "- ❌ **$distro**: ÉCHEC" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

## Statistiques

- Tests totaux: $total_tests
- Tests réussis: $successful_tests
- Tests échoués: $((total_tests - successful_tests))
- Taux de réussite: $((successful_tests * 100 / total_tests))%

## Détails

EOF

    for distro in "${DISTRIBUTIONS[@]}"; do
        echo "### $distro" >> "$report_file"
        if [ -f "$RESULTS_DIR/test-$distro-$TIMESTAMP.log" ]; then
            echo "\`\`\`" >> "$report_file"
            tail -20 "$RESULTS_DIR/test-$distro-$TIMESTAMP.log" >> "$report_file"
            echo "\`\`\`" >> "$report_file"
        fi
        echo "" >> "$report_file"
    done
    
    log "${GREEN}📊 Rapport généré: $report_file${NC}"
}

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS] [DISTRIBUTIONS...]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Afficher cette aide"
    echo "  -c, --cleanup   Nettoyer les images Docker après les tests"
    echo "  -q, --quiet     Mode silencieux"
    echo "  --build-only    Construire les images sans exécuter les tests"
    echo "  --test-only     Exécuter seulement les tests (images déjà construites)"
    echo ""
    echo "Distributions disponibles: ${DISTRIBUTIONS[*]}"
    echo ""
    echo "Exemples:"
    echo "  $0                    # Tester toutes les distributions"
    echo "  $0 arch ubuntu        # Tester seulement Arch et Ubuntu"
    echo "  $0 --cleanup fedora   # Tester Fedora et nettoyer après"
}

# Fonction principale
main() {
    local cleanup_after=false
    local quiet_mode=false
    local build_only=false
    local test_only=false
    local test_distributions=()
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--cleanup)
                cleanup_after=true
                shift
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            --build-only)
                build_only=true
                shift
                ;;
            --test-only)
                test_only=true
                shift
                ;;
            *)
                # Vérifier si c'est une distribution valide
                if [[ " ${DISTRIBUTIONS[*]} " == *" $1 "* ]]; then
                    test_distributions+=("$1")
                else
                    echo "Distribution inconnue: $1"
                    echo "Distributions disponibles: ${DISTRIBUTIONS[*]}"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Si aucune distribution spécifiée, tester toutes
    if [ ${#test_distributions[@]} -eq 0 ]; then
        test_distributions=("${DISTRIBUTIONS[@]}")
    fi
    
    # Vérifier que Docker est disponible
    if ! command -v docker &> /dev/null; then
        log "${RED}❌ Docker n'est pas installé ou accessible${NC}"
        exit 1
    fi
    
    # Démarrer les tests
    log "${BLUE}🚀 Début des tests pour: ${test_distributions[*]}${NC}"
    log "${BLUE}📁 Résultats dans: $RESULTS_DIR${NC}"
    
    local failed_tests=()
    
    for distro in "${test_distributions[@]}"; do
        if ! test_distribution "$distro"; then
            failed_tests+=("$distro")
        fi
        echo ""
    done
    
    # Générer le rapport final
    generate_report
    
    # Afficher le résumé
    log "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    log "${BLUE}║                         RÉSUMÉ FINAL                        ║${NC}"
    log "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    local total=${#test_distributions[@]}
    local failed=${#failed_tests[@]}
    local success=$((total - failed))
    
    log "${GREEN}✅ Tests réussis: $success/$total${NC}"
    
    if [ $failed -gt 0 ]; then
        log "${RED}❌ Tests échoués: $failed ($failed_tests)${NC}"
    fi
    
    # Nettoyer si demandé
    if [ "$cleanup_after" = true ]; then
        cleanup_docker
    fi
    
    # Code de sortie
    if [ $failed -gt 0 ]; then
        exit 1
    else
        log "${GREEN}🎉 Tous les tests sont passés avec succès!${NC}"
        exit 0
    fi
}

# Gérer les signaux
trap cleanup_docker EXIT

# Exécuter le script principal
main "$@"