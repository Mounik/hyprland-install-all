# Dockerfile pour tester Hyprland Universal sur Arch Linux
FROM archlinux:latest

# Mettre à jour le système et installer les outils de base
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    sudo \
    which \
    man-db \
    nano \
    vim

# Créer un utilisateur non-root
RUN useradd -m -G wheel -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Installer yay pour l'AUR
USER testuser
WORKDIR /home/testuser
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay

# Copier le script d'installation
COPY --chown=testuser:testuser . /home/testuser/hyprland-universal/

# Rendre les scripts exécutables
RUN chmod +x /home/testuser/hyprland-universal/install.sh && \
    chmod +x /home/testuser/hyprland-universal/test-installation.sh && \
    chmod +x /home/testuser/hyprland-universal/scripts/*.sh

# Script de test
RUN echo '#!/bin/bash' > /home/testuser/run-tests.sh && \
    echo 'cd /home/testuser/hyprland-universal' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test de détection Arch Linux ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh basic' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des correspondances de paquets ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh packages' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des modules ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh modules' >> /home/testuser/run-tests.sh && \
    chmod +x /home/testuser/run-tests.sh

WORKDIR /home/testuser/hyprland-universal
CMD ["/home/testuser/run-tests.sh"]