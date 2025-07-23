# Tests Docker pour Hyprland Universal

Ce dossier contient les outils pour tester l'installateur Hyprland Universal sur toutes les distributions supportées en utilisant Docker.

## 🏗️ Structure

```
docker-tests/
├── arch/           # Dockerfile pour Arch Linux
├── ubuntu/         # Dockerfile pour Ubuntu 22.04
├── debian/         # Dockerfile pour Debian 12
├── fedora/         # Dockerfile pour Fedora 39
├── opensuse/       # Dockerfile pour openSUSE Tumbleweed
├── run-all-tests.sh    # Script pour tester toutes les distributions
├── test-single.sh      # Script pour tester une seule distribution
└── results/            # Dossier des résultats (créé automatiquement)
```

## 🚀 Utilisation Rapide

### Tester une seule distribution

```bash
# Test de base sur Arch Linux
./docker-tests/test-single.sh arch basic

# Test complet sur Ubuntu
./docker-tests/test-single.sh ubuntu full
```

### Tester toutes les distributions

```bash
# Tester toutes les distributions
./docker-tests/run-all-tests.sh

# Tester seulement certaines distributions
./docker-tests/run-all-tests.sh arch ubuntu fedora

# Nettoyer les images après les tests
./docker-tests/run-all-tests.sh --cleanup
```

## 📋 Types de Tests Disponibles

| Type | Description |
|------|-------------|
| `basic` | Tests de base (détection, gestionnaire de paquets) |
| `packages` | Tests des correspondances de paquets |
| `modules` | Tests des modules d'installation |
| `performance` | Tests des performances système |
| `deps` | Tests des dépendances système |
| `full` | Tests complets (tous les tests) |

## 🐋 Prérequis Docker

Assurez-vous que Docker est installé et en cours d'exécution :

```bash
# Vérifier Docker
docker --version
docker ps

# Si Docker n'est pas démarré
sudo systemctl start docker    # Linux
# ou
open Docker Desktop           # macOS/Windows
```

## 📊 Analyse des Résultats

Les résultats sont sauvegardés dans le dossier `results/` avec un timestamp :

```
results/
├── test-summary-YYYYMMDD-HHMMSS.log    # Résumé des tests
├── test-arch-YYYYMMDD-HHMMSS.log       # Détails Arch Linux
├── test-ubuntu-YYYYMMDD-HHMMSS.log     # Détails Ubuntu
├── summary-YYYYMMDD-HHMMSS.txt         # Résumé succès/échecs
└── report-YYYYMMDD-HHMMSS.md           # Rapport complet en Markdown
```

## 🔧 Configuration des Tests

### Variables d'Environnement

Vous pouvez personnaliser les tests avec ces variables :

```bash
# Désactiver la compilation Hyprland depuis les sources (plus rapide)
export SKIP_HYPRLAND_COMPILE=true

# Mode debug (plus de logs)
export DEBUG_MODE=true

# Timeout personnalisé (secondes)
export TEST_TIMEOUT=1800
```

### Modification des Dockerfiles

Chaque distribution a son propre Dockerfile dans son dossier. Structure type :

```dockerfile
FROM distribution:version

# Installation des outils de base
RUN package-manager install base-tools

# Création d'un utilisateur de test
RUN useradd testuser

# Copie des scripts
COPY . /home/testuser/hyprland-universal/

# Exécution des tests
CMD ["./run-tests.sh"]
```

## 🐛 Débogage

### Exécuter un container interactif

```bash
# Construire l'image
docker build -t hyprland-test-arch docker-tests/arch --build-context default=.

# Lancer un shell interactif
docker run -it --rm hyprland-test-arch bash
```

### Analyser les logs d'erreur

```bash
# Voir les dernières erreurs pour une distribution
tail -50 docker-tests/results/test-ubuntu-*.log

# Rechercher des erreurs spécifiques
grep -i "error\|failed\|échec" docker-tests/results/test-*.log
```

### Tests personnalisés

Pour ajouter des tests spécifiques, modifiez les scripts `run-tests.sh` dans chaque Dockerfile :

```bash
# Exemple d'ajout de test
echo 'echo "=== Test personnalisé ==="' >> run-tests.sh
echo './test-installation.sh custom-test' >> run-tests.sh
```

## ⚡ Optimisations

### Mise en cache Docker

Pour accélérer les builds répétés :

```bash
# Utiliser le cache Docker
docker build --cache-from hyprland-test-arch -t hyprland-test-arch docker-tests/arch

# Construire toutes les images en parallèle
parallel -j4 docker build -t hyprland-test-{} docker-tests/{} ::: arch ubuntu debian fedora opensuse
```

### Tests en parallèle

```bash
# Exécuter les tests en parallèle (si vous avez assez de RAM)
parallel -j2 ./docker-tests/test-single.sh {} basic ::: arch ubuntu debian
```

## 📈 Métriques de Performance

Le script de test mesure automatiquement :

- Temps de construction des images Docker
- Temps d'exécution des tests
- Utilisation mémoire des containers
- Taux de succès par distribution

Ces métriques sont incluses dans le rapport final.

## 🤝 Contribution

Pour ajouter une nouvelle distribution :

1. Créer un nouveau dossier `docker-tests/nouvelle-distro/`
2. Ajouter un `Dockerfile` approprié
3. Tester avec `./test-single.sh nouvelle-distro basic`
4. Ajouter la distribution à la liste dans `run-all-tests.sh`

## 🆘 Support

En cas de problème :

1. Vérifiez les logs dans `docker-tests/results/`
2. Testez une distribution individuellement avec `test-single.sh`
3. Utilisez le mode debug : `DEBUG_MODE=true ./run-all-tests.sh`
4. Consultez les issues GitHub du projet

## 📄 Licence

Les tests Docker suivent la même licence que le projet principal Hyprland Universal.