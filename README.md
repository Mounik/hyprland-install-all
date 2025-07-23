# 🚀 Hyprland Universal Installer

**Installation unifiée de Hyprland sur toutes les distributions Linux supportées**

[![Tests](https://img.shields.io/badge/tests-Docker-blue)](./docker-tests/)
[![Distributions](https://img.shields.io/badge/distributions-5-green)](#distributions-supportées)
[![License](https://img.shields.io/badge/license-MIT-orange)](./LICENSE)

## 🎯 Objectif

Hyprland Universal Installer fournit un script d'installation unique qui :
- ✅ Détecte automatiquement votre distribution Linux
- ✅ Adapte l'installation aux spécificités de chaque distribution
- ✅ Applique une configuration cohérente avec le thème Dracula
- ✅ Installe les mêmes applications et raccourcis sur toutes les plateformes
- ✅ Fournit un environnement de développement complet et moderne

## 🖥️ Distributions Supportées

| Distribution | Version | Status | Notes |
|--------------|---------|--------|-------|
| **Arch Linux** | Latest | ✅ Stable | Support AUR complet |
| **Ubuntu** | 22.04+ | ✅ Stable | Compilation depuis sources |
| **Debian** | 12+ | ✅ Stable | Compilation depuis sources |
| **Fedora** | 39+ | ✅ Stable | Support COPR |
| **openSUSE** | Tumbleweed | ✅ Beta | Support Packman |

## 🚀 Installation Rapide

```bash
# Cloner le repository
git clone https://github.com/Mounik/hyprland-install-all
cd hyprland-install-all

# Rendre le script exécutable
chmod +x install.sh

# Lancer l'installation
./install.sh
```

## 📋 Fonctionnalités

### 🎨 Thème Dracula Complet
- **Hyprland** : Configuration avec couleurs et animations Dracula
- **Waybar** : Barre de statut avec palette Dracula
- **Alacritty** : Terminal avec thème Dracula officiel
- **Applications** : Thème cohérent sur toutes les applications

### 🛠️ Outils de Développement Modernes
- **Python** : UV pour la gestion des environnements et paquets
- **Infrastructure** : OpenTofu (remplaçant Terraform open-source)
- **Conteneurs** : Docker avec LazyDocker
- **Git** : LazyGit pour interface Git moderne
- **Éditeurs** : Neovim (LazyVim) + VSCode avec thème Dracula

### ⌨️ Raccourcis Clavier Unifiés

| Raccourci | Fonction |
|-----------|----------|
| `Super + Entrée` | Terminal (Alacritty) |
| `Super + Espace` | Lanceur d'applications |
| `Super + F` | Gestionnaire de fichiers |
| `Super + W` | Fermer la fenêtre |
| `Super + 1-4` | Changer d'espace de travail |
| `Super + G` | Git (LazyGit) |
| `Super + D` | Docker (LazyDocker) |
| `Super + N` | Neovim |

[Voir tous les raccourcis](./FAQ.md#raccourcis-clavier-personnalisés)

### 🔧 Aliases Intelligents

```bash
# OpenTofu/Terraform
tf                  # tofu (raccourci principal)
terraform           # tofu (compatibilité totale)
tofu-workflow      # Workflow complet (fmt→init→validate→plan)

# Python moderne avec UV
py                 # python3
pip                # uv pip (UV devient le gestionnaire par défaut)
venv               # uv venv
uv-project <nom>   # Crée un projet Python complet avec UV

# Ansible
ap                 # ansible-playbook
av                 # ansible-vault
ag                 # ansible-galaxy
ai                 # ansible-inventory
```

## 🏗️ Architecture

```
hyprland-install-all/
├── install.sh              # 🎯 Script principal d'installation
├── test-installation.sh    # Script de tests
├── lib/                    # Bibliothèques communes
│   ├── global-functions.sh # Fonctions utilitaires
│   ├── distro-detection.sh # Détection de distribution
│   ├── package-manager.sh  # Gestionnaires de paquets unifiés
│   ├── package-mapping.sh  # Correspondance des noms de paquets
│   └── user-interface.sh   # Interface utilisateur
├── scripts/                # Modules d'installation
│   ├── base-dependencies.sh
│   ├── hyprland.sh
│   ├── fonts.sh
│   ├── audio.sh
│   └── dotfiles.sh
├── tests/                  # Tests unitaires
│   └── test-runner.sh
├── docker-tests/           # Tests sur toutes les distributions
│   ├── arch/Dockerfile-ssh
│   ├── ubuntu/Dockerfile-ssh
│   ├── debian/Dockerfile-ssh
│   ├── fedora/Dockerfile-ssh
│   ├── opensuse/Dockerfile-ssh
│   └── run-all-tests.sh
├── configs/               # Configurations communes
├── Install-Logs/          # Logs d'installation
├── README.md              # Documentation
└── CLAUDE.md             # Instructions pour Claude Code
```

## 🧪 Tests et Validation

### Tests Locaux

```bash
# Test de base (détection, compatibilité)
./test-installation.sh basic

# Test des correspondances de paquets
./test-installation.sh packages

# Test des modules d'installation
./test-installation.sh modules

# Test complet
./test-installation.sh full
```

### Tests Docker (Multi-Distribution)

```bash
# Tester toutes les distributions
./docker-tests/run-all-tests.sh

# Tester une distribution spécifique
./docker-tests/test-single.sh arch basic
./docker-tests/test-single.sh ubuntu full

# Tests avec nettoyage automatique
./docker-tests/run-all-tests.sh --cleanup
```

[Documentation complète des tests](./docker-tests/README.md)

## 📦 Composants Installés

### Interface Utilisateur
- **Hyprland** : Gestionnaire de fenêtres Wayland
- **Waybar** : Barre de statut moderne
- **SDDM** : Gestionnaire de connexion (optionnel)
- **Wofi** : Lanceur d'applications

### Applications de Base
- **Alacritty** : Terminal rapide
- **Thunar** : Gestionnaire de fichiers
- **Chromium** : Navigateur web
- **mpv** : Lecteur multimédia

### Développement
- **Neovim** : Éditeur avec LazyVim
- **VSCode** : IDE avec extensions
- **Git** : Avec LazyGit
- **Docker** : Avec LazyDocker

### Outils Système
- **Pipewire** : Serveur audio moderne
- **Polices Nerd** : JetBrains Mono avec icônes
- **btop** : Moniteur système
- **fastfetch** : Informations système

## ⚙️ Configuration Avancée

### Sélection de Composants

L'installateur propose une interface interactive pour choisir :
- Dépendances de base (requis)
- Hyprland et écosystème (requis)
- Polices Nerd Fonts
- Thèmes GTK
- Gestionnaire de connexion SDDM
- Barre de statut Waybar
- Applications essentielles

### Configuration Post-Installation

Après installation, vous pouvez :
- Modifier `~/.config/hypr/hyprland.conf` pour Hyprland
- Personnaliser `~/.config/waybar/config.jsonc` pour Waybar
- Ajuster `~/.config/alacritty/alacritty.toml` pour le terminal
- Utiliser les aliases dans votre shell préféré

## 🐛 Dépannage

### Problèmes Courants

**Hyprland ne démarre pas :**
```bash
# Vérifier les logs
journalctl -f _COMM=Hyprland

# Vérifier la configuration
hyprland --config ~/.config/hypr/hyprland.conf --check
```

**Audio ne fonctionne pas :**
```bash
# Redémarrer Pipewire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Vérifier les périphériques
pactl list short sinks
```

**Polices manquantes :**
```bash
# Mettre à jour le cache
fc-cache -fv

# Vérifier les polices installées
fc-list | grep -i nerd
```

### Logs et Diagnostics

Les logs d'installation sont sauvegardés dans :
- `Install-Logs/hyprland-universal-YYYYMMDD-HHMMSS.log`
- Résultats des tests dans `docker-tests/results/`

## 🤝 Contribution

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/nouvelle-fonctionnalité`)
3. **Tester** sur plusieurs distributions avec Docker
4. **Commit** vos changements (`git commit -am 'Add: nouvelle fonctionnalité'`)
5. **Push** vers la branche (`git push origin feature/nouvelle-fonctionnalité`)
6. **Créer** une Pull Request

### Ajouter une Distribution

1. Créer le Dockerfile dans `docker-tests/nouvelle-distro/`
2. Ajouter les correspondances de paquets dans `lib/package-mapping.sh`
3. Tester avec `./docker-tests/test-single.sh nouvelle-distro`
4. Mettre à jour la documentation

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](./LICENSE) pour plus de détails.

## 🙏 Remerciements

- [Hyprland](https://github.com/hyprwm/Hyprland) pour le gestionnaire de fenêtres
- [Dracula Theme](https://github.com/dracula/dracula-theme) pour le thème
- Les mainteneurs des scripts d'installation par distribution originaux
- La communauté open-source pour les outils et bibliothèques utilisés

## 📞 Support

- 🐛 **Issues** : [GitHub Issues](https://github.com/Mounik/hyprland-install-all/issues)
- 💬 **Discussions** : [GitHub Discussions](https://github.com/Mounik/hyprland-install-all/discussions)
- 📧 **Contact** : Créer une issue pour toute question

---

<div align="center">
  <strong>Fait avec ❤️ pour la communauté Linux</strong>
</div>