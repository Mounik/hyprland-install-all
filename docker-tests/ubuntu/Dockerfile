# Dockerfile pour tester Hyprland Universal sur Ubuntu
FROM ubuntu:22.04

# Éviter les interactions pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# Mettre à jour le système et installer les outils de base
RUN apt update && apt upgrade -y && \
    apt install -y \
    build-essential \
    git \
    wget \
    curl \
    sudo \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gpg \
    lsb-release \
    nano \
    vim

# Créer un utilisateur non-root
RUN useradd -m -G sudo -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configurer les locales
RUN apt install -y locales && \
    locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

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
    echo 'echo "=== Test de détection Ubuntu ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh basic' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des correspondances de paquets ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh packages' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des modules ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh modules' >> /home/testuser/run-tests.sh && \
    echo 'echo "=== Test des performances ==="' >> /home/testuser/run-tests.sh && \
    echo './test-installation.sh performance' >> /home/testuser/run-tests.sh && \
    chmod +x /home/testuser/run-tests.sh

WORKDIR /home/testuser/hyprland-universal
CMD ["/home/testuser/run-tests.sh"]