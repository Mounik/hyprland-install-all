# FAQ.md

## Aperçu du Projet

**Hyprland Universal Installer** - Un script d'installation unifié, multi-distribution qui détecte automatiquement la distribution Linux et installe Hyprland avec un environnement de développement complet. L'objectif est de fournir une expérience utilisateur identique, des raccourcis clavier, des thèmes (Dracula) et des outils de développement modernes sur toutes les distributions Linux prises en charge.

## Structure du Dépôt

```
hyprland-install-all/
├── install.sh              # 🎯 Main installation script (entry point)
├── test-installation.sh    # Comprehensive testing script
├── lib/                    # Core libraries and modules
│   ├── global-functions.sh # Shared utilities, logging, progress display
│   ├── distro-detection.sh # Automatic distribution detection
│   ├── package-manager.sh  # Unified package manager abstraction
│   ├── package-mapping.sh  # Cross-distribution package name mapping
│   └── user-interface.sh   # Interactive menu system
├── scripts/                # Installation modules
│   ├── base-dependencies.sh # System dependencies
│   ├── hyprland.sh         # Hyprland window manager
│   ├── fonts.sh            # Nerd Fonts installation
│   ├── audio.sh            # Pipewire audio setup
│   └── dotfiles.sh         # Configuration files
├── tests/                  # Unit tests
│   └── test-runner.sh      # Test execution framework
├── docker-tests/           # Multi-distribution testing
│   ├── arch/Dockerfile-ssh    # Arch Linux test container
│   ├── ubuntu/Dockerfile-ssh  # Ubuntu test container
│   ├── debian/Dockerfile-ssh  # Debian test container
│   ├── fedora/Dockerfile-ssh  # Fedora test container
│   ├── opensuse/Dockerfile-ssh # OpenSuse test container
│   └── run-all-tests.sh       # Automated testing across all distros
├── configs/               # Shared configuration templates
├── Install-Logs/          # Installation logs (auto-generated)
├── README.md              # User documentation
└── CLAUDE.md             # This file - development guidance
```

## Fonctionnalités Clés & Architecture

### 🚀 Installation Universelle
- **Script unique** (`install.sh`) fonctionne sur toutes les distributions supportées
- **Détection automatique** de la distribution Linux et de sa version
- **Installation adaptative** basée sur la famille de distribution (debian/arch/redhat/suse)
- **Expérience cohérente** sur Ubuntu, Debian, Arch, Fedora, OpenSuse

### 🏗️ Conception Modulaire
- **Architecture basée sur des bibliothèques** avec des composants réutilisables
- **Abstraction du gestionnaire de paquets** (apt/pacman/dnf/zypper)
- **Adaptations spécifiques aux distributions** tout en maintenant une interface commune
- **Framework de test complet** avec conteneurs Docker

### 🎨 Configuration Complète de l'Environnement
- **Gestionnaire de fenêtres Hyprland** avec configuration optimisée
- **Thème Dracula** appliqué de manière cohérente sur toutes les applications
- **Outils de développement modernes**: UV (Python), OpenTofu, LazyGit, LazyDocker
- **Raccourcis clavier unifiés** et alias

## Tâches de Développement Courantes

### Exécution de l'Installation
```bash
# Rendre le script exécutable
chmod +x install.sh

# Lancer l'installation (NE PAS exécuter en tant que root)
./install.sh
```

### Test de l'Installation
```bash
# Test des fonctionnalités de base
./test-installation.sh basic

# Validation du mapping des paquets
./test-installation.sh packages

# Test de tous les modules
./test-installation.sh modules

# Test d'intégration complet
./test-installation.sh full
```

### Tests Multi-Distribution avec Docker
```bash
# Tester toutes les distributions
./docker-tests/run-all-tests.sh

# Tester une distribution spécifique
./docker-tests/test-single.sh arch basic
./docker-tests/test-single.sh ubuntu full

# Se connecter au conteneur de test via SSH pour le débogage
ssh testuser@localhost -p 2222  # Ubuntu
ssh testuser@localhost -p 2223  # Arch
ssh testuser@localhost -p 2224  # Debian
ssh testuser@localhost -p 2225  # Fedora
ssh testuser@localhost -p 2226  # OpenSuse
```

## Composants Principaux

### 1. Détection de Distribution (`lib/distro-detection.sh`)
- Détecte automatiquement la distribution Linux depuis `/etc/os-release`
- Associe les distributions aux familles : debian, arch, redhat, suse
- Fournit des variables cohérentes : `$DISTRO_ID`, `$DISTRO_NAME`, `$DISTRO_VERSION`, `$DISTRO_FAMILY`

### 2. Abstraction du Gestionnaire de Paquets (`lib/package-manager.sh`)
- Interface unifiée pour tous les gestionnaires de paquets
- Configuration automatique des dépôts (PPAs, COPRs, AUR, etc.)
- Fonctions communes : `install_package()`, `remove_package()`, `update_system()`

### 3. Mapping des Paquets (`lib/package-mapping.sh`)
- Traduction des noms de paquets entre distributions
- Associe les noms génériques aux paquets spécifiques des distributions
- Exemple : `python` → `python3` (Debian/Ubuntu), `python` (Arch), `python3` (Fedora)

### 4. Fonctions Globales (`lib/global-functions.sh`)
- Système de journalisation avec sortie en couleur
- Indicateurs de progression et retour utilisateur
- Gestion des erreurs et fonctions de nettoyage
- Compatibilité tput pour les environnements Docker

### 5. Interface Utilisateur (`lib/user-interface.sh`)
- Système de menu interactif pour la sélection des composants
- Suivi de la progression pendant l'installation
- Gestion des confirmations et des entrées utilisateur

## Distributions Supportées

| Distribution | Famille | Gestionnaire de Paquets | Statut | Fonctionnalités Spéciales |
|-------------|---------|------------------------|---------|---------------------------|
| **Arch Linux** | arch | pacman + yay | ✅ Entièrement Testé | Support AUR |
| **Ubuntu 22.04+** | debian | apt | ✅ Entièrement Testé | Dépôts PPA |
| **Debian 12+** | debian | apt | ✅ Entièrement Testé | Format moderne de dépôt |
| **Fedora 39+** | redhat | dnf | ✅ Entièrement Testé | Dépôts COPR |
| **OpenSuse Tumbleweed** | suse | zypper | ✅ Entièrement Testé | Dépôt Packman |

## Fonctionnalités de l'Environnement de Développement

### 🎨 Configuration du Thème Dracula
- **Hyprland** : Gestionnaire de fenêtres avec couleurs et animations Dracula
- **Waybar** : Barre d'état avec palette Dracula complète
- **Alacritty** : Terminal avec thème Dracula officiel
- **Applications** : Thèmes GTK et style cohérent

### 🛠️ Outils de Développement Modernes
- **Python** : UV pour la gestion des paquets et de l'environnement
- **Infrastructure** : OpenTofu (alternative open-source à Terraform)
- **Conteneurs** : Docker avec interface LazyDocker
- **Git** : LazyGit pour un workflow Git moderne
- **Éditeurs** : Neovim (LazyVim) + VSCode avec thème Dracula

## Raccourcis clavier personnalisés

Vous pouvez voir tous les raccourcis principaux en appuyant sur **Super + K**.

---

### **Navigation**

| Raccourci             | Fonction                                                          |
| --------------------- | ----------------------------------------------------------------- |
| Super + Espace        | Index et lanceur d'applications                                   |
| Super + W             | Fermer la fenêtre                                                 |
| Super + 1/2/3/4       | Aller à l'espace de travail correspondant                         |
| Maj + Super + 1/2/3/4 | Déplacer la fenêtre vers l'espace de travail                      |
| Ctrl + 1/2/3/...      | Aller à l'onglet du navigateur                                    |
| F11                   | Plein écran                                                       |
| Super + Flèche        | Déplacer le focus vers la fenêtre dans la direction de la flèche  |
| Super + Maj + Flèche  | Échanger la fenêtre avec une autre dans la direction de la flèche |
| Super + Égal          | Agrandir les fenêtres vers la gauche                              |
| Super + Moins         | Agrandir les fenêtres vers la droite                              |
| Super + Maj + Égal    | Agrandir les fenêtres vers le bas                                 |
| Super + Maj + Moins   | Agrandir les fenêtres vers le haut                                |

---

### **Lancement d'applications**

| Raccourci          | Application                               |
| ------------------ | ----------------------------------------- |
| Super + Entrée     | Terminal                                  |
| Super + B          | Navigateur                                |
| Super + F          | Gestionnaire de fichiers                  |
| Super + T          | Activité (btop)                           |
| Super + M          | Musique (Spotify)                         |
| Super + /          | Gestionnaire de mots de passe (Keepass)   |
| Super + N          | Neovim                                    |
| Super + C          | Calendrier (HEY)                          |
| Super + E          | Email (HEY)                               |
| Super + A          | IA (ChatGPT)                              |
| Super + Maj + G    | Messagerie (WhatsApp)                     |
| Super + D          | Docker (LazyDocker)                       |
| Super + G          | Git (LazyGit)                             |
| Super + O          | Obsidian                                  |
| Super + X          | X                                         |


---

### **Notifications**

| Raccourci        | Fonction                                        |
| ---------------- | ----------------------------------------------- |
| Super + ,        | Rejeter la dernière notification                |
| Maj + Super + ,  | Rejeter toutes les notifications                |
| Ctrl + Super + , | Activer/désactiver le silence des notifications |

---

### **Apparence**

| Raccourci                   | Fonction                             |
| --------------------------- | ------------------------------------ |
| Ctrl + Maj + Super + Espace | Thème suivant                        |
| Ctrl + Super + Espace       | Image de fond suivante               |
| Maj + Super + Espace        | Afficher/masquer la barre supérieure |

---

### **Système**

| Raccourci        | Fonction                                                   |
| ---------------- | ---------------------------------------------------------- |
| Super + Échap    | Verrouiller / Suspendre / Relancer / Redémarrer / Éteindre |
| Ctrl + Super + I | Activer/désactiver la prévention de veille/inactivité      |

---

### **Gestionnaire de fichiers**

| Raccourci      | Fonction                                         |
| -------------- | ------------------------------------------------ |
| Ctrl + L       | Aller à un chemin                                |
| Espace         | Prévisualiser le fichier (flèches pour naviguer) |
| Retour arrière | Revenir d’un dossier                             |

---

### **Captures d’écran**

| Raccourci         | Fonction             |
| ----------------- | -------------------- |
| Impr écran        | Capturer une région  |
| Maj + Impr écran  | Capturer une fenêtre |
| Ctrl + Impr écran | Capturer un écran    |

---

### **Neovim (avec LazyVim)**

#### Navigation

| Raccourci                   | Fonction                                |
| --------------------------- | --------------------------------------- |
| Espace                      | Afficher les options de commande        |
| Espace Espace               | Ouvrir un fichier (recherche floue)     |
| Espace E                    | Afficher/masquer la barre latérale      |
| Espace G G                  | Contrôles Git                           |
| Espace S G                  | Recherche dans le contenu des fichiers  |
| Ctrl + W W                  | Passer de l’éditeur à la barre latérale |
| Ctrl + Flèche gauche/droite | Changer la taille de la barre latérale  |
| Maj + H                     | Aller à l’onglet précédent              |
| Maj + L                     | Aller à l’onglet suivant                |
| Espace B D                  | Fermer l’onglet actuel                  |

#### Depuis la barre latérale

| Raccourci | Fonction                                       |
| --------- | ---------------------------------------------- |
| A         | Ajouter un fichier dans le dossier parent      |
| Maj + A   | Ajouter un sous-dossier dans le dossier parent |
| D         | Supprimer le fichier/dossier sélectionné       |
| M         | Déplacer le fichier/dossier sélectionné        |
| R         | Renommer le fichier/dossier sélectionné        |
| ?         | Afficher l’aide de tous les raccourcis         |


---

### **Émojis rapides**

| Raccourci        | Émoji | Signification      |
| ---------------- | ----- | ------------------ |
| Verr Maj + M + S | 😄    | sourire            |
| Verr Maj + M + C | 😂    | pleurer            |
| Verr Maj + M + L | 😍    | amour              |
| Verr Maj + M + V | ✌️    | victoire           |
| Verr Maj + M + H | ❤️    | cœur               |
| Verr Maj + M + Y | 👍    | oui                |
| Verr Maj + M + N | 👎    | non                |
| Verr Maj + M + F | 🖕    | fuck               |
| Verr Maj + M + W | 🤞    | espoir             |
| Verr Maj + M + R | 🤘    | rock               |
| Verr Maj + M + K | 😘    | bisou              |
| Verr Maj + M + E | 🙄    | yeux levés au ciel |
| Verr Maj + M + P | 🙏    | prier              |
| Verr Maj + M + D | 🤤    | baver              |
| Verr Maj + M + M | 💰    | argent             |
| Verr Maj + M + X | 🎉    | célébrer           |
| Verr Maj + M + 1 | 💯    | 100%               |
| Verr Maj + M + T | 🥂    | toast              |
| Verr Maj + M + O | 👌    | ok                 |
| Verr Maj + M + G | 👋    | salut              |
| Verr Maj + M + A | 💪    | force              |
| Verr Maj + M + B | 🤯    | explosion mentale  |

---

### **Complétions rapides**

| Raccourci                | Complétion                                 |
| ------------------------ | ------------------------------------------ |
| Verr Maj + Espace Espace | — (tiret cadratin)                         |
| Verr Maj + Espace N      | Votre nom (entré lors de l’installation)   |
| Verr Maj + Espace E      | Votre email (entré lors de l’installation) |


### 🔧 Alias Intelligents
```bash
# Compatibilité OpenTofu/Terraform
tf                  # tofu (commande principale)
terraform           # tofu (compatibilité complète)
tofu-workflow      # Workflow complet (fmt→init→validate→plan)

# Python Moderne avec UV
py                 # python3
pip                # uv pip (UV remplace pip)
venv               # uv venv
uv-project <nom>   # Créer un projet Python complet avec UV

# Raccourcis Ansible
ap                 # ansible-playbook
av                 # ansible-vault
ag                 # ansible-galaxy
ai                 # ansible-inventory
```

## Modèles d'Architecture

### Gestion des Erreurs & Journalisation
- Les scripts utilisent `set -e` pour un arrêt immédiat en cas d'erreurs
- Journalisation complète dans `Install-Logs/hyprland-universal-YYYYMMDD-HHMMSS.log`
- Sortie colorée avec solutions de repli pour les environnements non-TTY
- Fonctions trap pour le nettoyage à la sortie du script

### Compatibilité Multi-Distribution
- La détection de la famille de distribution pilote la logique d'installation
- Le mapping des noms de paquets gère les différences entre distributions
- La configuration des dépôts s'adapte aux conventions de chaque distribution
- Le framework de test valide le comportement sur toutes les distributions

### Système d'Installation Modulaire
- Chaque composant est un module séparé et testable
- Sélection interactive des composants pendant l'installation
- Résolution automatique des dépendances
- Les modules individuels peuvent être exécutés indépendamment pour le débogage

## Tests & Validation

### Tests Locaux
Le framework de test valide :
- ✅ Précision de la détection de distribution
- ✅ Fonctionnalité du gestionnaire de paquets
- ✅ Mappings des noms de paquets
- ✅ Configurations des dépôts
- ✅ Compatibilité des modules

### Tests Basés sur Docker
- Environnement de test isolé complet pour chaque distribution
- Accès SSH pour le débogage en temps réel et le suivi des logs
- Exécution automatisée des tests sur toutes les distributions supportées
- Journalisation et comparaison des résultats

### Couverture des Tests
- **Tests de base** : Fonctionnalités principales et détection
- **Tests des paquets** : Validation du mapping des paquets entre distributions
- **Tests des modules** : Installation des composants individuels
- **Tests complets** : Installation de bout en bout

## Notes Importantes de Développement

### Sécurité & Bonnes Pratiques
- **Jamais en root** : Les scripts vérifient et refusent l'exécution en root
- **Pas d'identifiants codés en dur** : Toutes les données sensibles sont gérées de manière sécurisée
- **Privilèges minimaux** : Demande sudo uniquement quand absolument nécessaire
- **Validation des entrées** : Toutes les entrées utilisateur sont validées et nettoyées

### Considérations Spécifiques aux Distributions
- **Arch** : Support AUR via yay, paquets bleeding-edge
- **Ubuntu/Debian** : Gestion des PPA, versions stables des paquets
- **Fedora** : Dépôts COPR, considérations SELinux
- **OpenSuse** : Dépôt Packman, spécificités zypper

### Gestion de la Configuration
- **Thème Dracula** : Schémas de couleurs cohérents pour toutes les applications
- **Dotfiles** : Gestion centralisée de la configuration
- **Préférences utilisateur** : Préservées et migrées lors des mises à jour
- **Système de sauvegarde** : Sauvegarde automatique des configurations existantes

## Dépannage & Débogage

### Problèmes Courants
1. **Erreurs tput dans Docker** : Gérées avec des définitions de couleurs de repli
2. **Conflits de paquets** : Résolus via une logique spécifique à la distribution
3. **Accès aux dépôts** : Configuration automatique des dépôts et gestion des clés
4. **Problèmes de permissions** : Utilisation appropriée de sudo et permissions utilisateur

### Outils de Débogage
- Journalisation détaillée avec le flag `--debug`
- Test des modules individuels
- Accès aux conteneurs Docker via SSH
- Outils d'analyse des logs dans `Install-Logs/`

## Guide de Contribution

Pour contribuer à ce projet :
1. **Tester sur plusieurs distributions** en utilisant le framework Docker
2. **Mettre à jour les mappings des paquets** dans `lib/package-mapping.sh` pour les nouveaux paquets
3. **Maintenir une conception modulaire** - chaque fonctionnalité doit être un module séparé
4. **Suivre les conventions de journalisation** - utiliser les fonctions globales pour une sortie cohérente
5. **Mettre à jour la documentation** - à la fois README.md et ce fichier CLAUDE.md

## Développements Futurs

Améliorations prévues :
- Support de distributions supplémentaires (CentOS, Alpine, etc.)
- Système avancé de personnalisation des thèmes
- Fonctionnalité automatisée de sauvegarde et restauration
- Intégration avec les environnements de développement cloud
- Optimisations de performances et système de cache