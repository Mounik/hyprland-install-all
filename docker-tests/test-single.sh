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
docker build -t "hyprland-test-$DISTRO" "$SCRIPT_DIR/$DISTRO" --build-context default="$HYPRLAND_DIR"

echo "▶️  Exécution du test..."
docker run --rm \
    -v "$HYPRLAND_DIR:/tmp/hyprland-universal:ro" \
    "hyprland-test-$DISTRO" \
    bash -c "
        cp -r /tmp/hyprland-universal/* /home/testuser/hyprland-universal/ && \
        chown -R testuser:testuser /home/testuser/hyprland-universal && \
        chmod +x /home/testuser/hyprland-universal/test-installation.sh && \
        su testuser -c 'cd /home/testuser/hyprland-universal && ./test-installation.sh $TEST_TYPE'
    "

echo "✅ Test terminé pour $DISTRO"