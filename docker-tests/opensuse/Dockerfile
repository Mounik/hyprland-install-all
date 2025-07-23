# Dockerfile pour tester Hyprland Universal sur openSUSE
FROM opensuse/tumbleweed:latest

# Mettre à jour le système et installer les outils de base
RUN zypper refresh && \
    zypper update -y && \
    zypper install -y \
    patterns-devel-base-devel_basis \
    git \
    wget \
    curl \
    sudo \
    which \
    procps \
    nano \
    vim \
    gzip

# Créer un utilisateur non-root
RUN useradd -m -G wheel -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Ajouter les dépôts Packman (pour les tests complets)
RUN zypper ar -f http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman && \
    zypper refresh

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
    echo 'echo "=== Test de détection openSUSE ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh basic' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des correspondances de paquets ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh packages' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des modules ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh modules' >> /home/testuser/run-tests.sh && \
    chmod +x /home/testuser/run-tests.sh

WORKDIR /home/testuser/hyprland-universal
CMD ["/home/testuser/run-tests.sh"]