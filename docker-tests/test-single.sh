#!/bin/bash
# Script pour tester rapidement une seule distribution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPRLAND_DIR="$(dirname "$SCRIPT_DIR")"

# Vérifier les arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <distribution> [test-type]"
    echo ""
    echo "Distributions disponibles: arch, ubuntu, debian, fedora, opensuse"
    echo "Types de test: basic, packages, modules, full (défaut: basic)"
    echo ""
    echo "Exemples:"
    echo "  $0 arch basic       # Test de base sur Arch"
    echo "  $0 ubuntu full      # Test complet sur Ubuntu"
    exit 1
fi

DISTRO=$1
TEST_TYPE=${2:-basic}

echo "🧪 Test rapide - $DISTRO ($TEST_TYPE)"

# Construire et exécuter
cd "$HYPRLAND_DIR"
docker build -t "hyprland-test-$DISTRO" -f "$SCRIPT_DIR/$DISTRO/Dockerfile" .

echo "▶️  Exécution du test..."
docker run --rm \
    "hyprland-test-$DISTRO" \
    bash -c "sudo -u testuser bash -c 'cd /home/testuser/hyprland-universal && ./test-installation.sh $TEST_TYPE'"

echo "✅ Test terminé pour $DISTRO"