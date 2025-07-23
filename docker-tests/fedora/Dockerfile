# Dockerfile pour tester Hyprland Universal sur Fedora
FROM fedora:39

# Mettre à jour le système et installer les outils de base
RUN dnf update -y && \
    dnf install -y \
    @development-tools \
    git \
    wget \
    curl \
    sudo \
    which \
    procps-ng \
    nano \
    vim \
    dnf-plugins-core

# Créer un utilisateur non-root
RUN useradd -m -G wheel -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configurer RPM Fusion (pour les tests complets)
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

USER testuser
WORKDIR /home/testuser

# Copier le script d'installation
COPY --chown=testuser:testuser . /home/testuser/hyprland-universal/

# Rendre les scripts exécutables
RUN chmod +x /home/testuser/hyprland-universal/install.sh && \
    chmod +x /home/testuser/hyprland-universal/test-installation.sh && \
    chmod +x /home/testuser/hyprland-universal/scripts/*.sh

# Script de test
RUN echo '#!/bin/bash' > /home/testuser/run-tests.sh && \
    echo 'cd /home/testuser/hyprland-universal' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test de détection Fedora ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh basic' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des correspondances de paquets ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh packages' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des modules ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh modules' >> /home/testuser/run-tests.sh && \
    chmod +x /home/testuser/run-tests.sh

WORKDIR /home/testuser/hyprland-universal
CMD ["/home/testuser/run-tests.sh"]