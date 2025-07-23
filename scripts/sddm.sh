#!/bin/bash
# Installation et configuration de SDDM pour Hyprland Universal

echo "${NOTE} Installation de SDDM..." | tee -a "$LOG"

# Fonction pour installer SDDM et ses dépendances
install_sddm() {
    local sddm_packages=()

    case $DISTRO_FAMILY in
        "arch")
            sddm_packages=(
                "sddm"
                "qt5-graphicaleffects"
                "qt5-svg"
                "qt5-quickcontrols2"
            )
            ;;
        "debian")
            sddm_packages=(
                "sddm"
                "qml-module-qtquick-controls2"
                "qml-module-qtgraphicaleffects"
            )
            ;;
        "redhat")
            sddm_packages=(
                "sddm"
                "qt5-qtquickcontrols2"
                "qt5-qtgraphicaleffects"
            )
            ;;
        "suse")
            sddm_packages=(
                "sddm"
                "libqt5-qtquickcontrols2"
                "libqt5-qtgraphicaleffects"
            )
            ;;
    esac

    for package in "${sddm_packages[@]}"; do
        install_package "$package"
    done
}

# Fonction pour désactiver d'autres gestionnaires de connexion
disable_other_display_managers() {
    local display_managers=("gdm" "lightdm" "kdm" "xdm" "lxdm")

    for dm in "${display_managers[@]}"; do
        if systemctl is-active --quiet "$dm" 2>/dev/null; then
            echo "${NOTE} Désactivation de $dm..." | tee -a "$LOG"
            sudo systemctl disable "$dm" 2>/dev/null || true
            sudo systemctl stop "$dm" 2>/dev/null || true
        fi
    done
}

# Fonction pour configurer SDDM
configure_sddm() {
    local sddm_config="/etc/sddm.conf"

    # Créer le fichier de configuration SDDM
    echo "${NOTE} Configuration de SDDM..." | tee -a "$LOG"

    sudo tee "$sddm_config" > /dev/null << 'EOF'
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=dracula
CursorTheme=Dracula-cursors

[Users]
MaximumUid=60513
MinimumUid=500
RememberLastSession=true
RememberLastUser=true

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

    echo "${OK} Configuration SDDM créée" | tee -a "$LOG"
}

# Fonction pour installer le thème Dracula pour SDDM
install_sddm_dracula_theme() {
    local themes_dir="/usr/share/sddm/themes"
    local dracula_theme_dir="$themes_dir/dracula"

    # Créer le répertoire de thèmes s'il n'existe pas
    sudo mkdir -p "$themes_dir"

    if [[ ! -d "$dracula_theme_dir" ]]; then
        echo "${NOTE} Installation du thème Dracula pour SDDM..." | tee -a "$LOG"

        cd /tmp
        if git clone https://github.com/dracula/sddm.git sddm-dracula 2>/dev/null; then
            sudo cp -r sddm-dracula "$dracula_theme_dir"
            sudo chown -R root:root "$dracula_theme_dir"
            rm -rf sddm-dracula
            echo "${OK} Thème Dracula SDDM installé" | tee -a "$LOG"
        else
            # Créer un thème Dracula basique si le git clone échoue
            echo "${NOTE} Création d'un thème Dracula basique..." | tee -a "$LOG"
            create_basic_dracula_theme "$dracula_theme_dir"
        fi
    fi
}

# Fonction pour créer un thème Dracula basique
create_basic_dracula_theme() {
    local theme_dir="$1"

    sudo mkdir -p "$theme_dir"

    # Créer le fichier metadata.desktop
    sudo tee "$theme_dir/metadata.desktop" > /dev/null << 'EOF'
[SddmGreeterTheme]
Name=Dracula
Description=Dracula theme for SDDM
Author=Hyprland Universal
Copyright=Dracula Team
License=MIT
Type=sddm-theme
Version=1.0
Website=https://draculatheme.com/
MainScript=Main.qml
ConfigFile=theme.conf
TranslationsDirectory=translations
Theme-Id=dracula
Theme-API=2.0
EOF

    # Créer le fichier theme.conf
    sudo tee "$theme_dir/theme.conf" > /dev/null << 'EOF'
[General]
background=/usr/share/sddm/themes/dracula/background.jpg
showLoginButton=true
showUserList=true
showPasswordVisibilityButton=true
showClearPasswordButton=true

[Design]
Font="JetBrainsMono Nerd Font"
FontSize=12
Locale=""

[Colors]
Primary=#bd93f9
Secondary=#6272a4
Success=#50fa7b
Info=#8be9fd
Warning=#f1fa8c
Error=#ff5555
Background=#282a36
Surface=#44475a
OnPrimary=#282a36
OnSecondary=#f8f8f2
OnSuccess=#282a36
OnInfo=#282a36
OnWarning=#282a36
OnError=#282a36
OnBackground=#f8f8f2
OnSurface=#f8f8f2
EOF

    # Créer un fichier Main.qml basique
    sudo tee "$theme_dir/Main.qml" > /dev/null << 'EOF'
import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#282a36"

    property string notificationMessage
    property bool passwordFieldOutlined: config.PasswordFieldOutlined == "true"
    property bool userFieldOutlined: config.UserFieldOutlined == "true"

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginFailed() {
            notificationMessage = textConstants.loginFailed
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: 300
        color: "#44475a"
        radius: 10
        border.color: "#6272a4"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "Hyprland"
                color: "#bd93f9"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: userField
                width: 300
                placeholderText: textConstants.userName
                color: "#f8f8f2"
                background: Rectangle {
                    color: "#282a36"
                    border.color: "#6272a4"
                    border.width: 1
                    radius: 5
                }
                text: userModel.lastUser
            }

            TextField {
                id: passwordField
                width: 300
                placeholderText: textConstants.password
                color: "#f8f8f2"
                echoMode: TextInput.Password
                background: Rectangle {
                    color: "#282a36"
                    border.color: "#6272a4"
                    border.width: 1
                    radius: 5
                }
                onAccepted: sddm.login(userField.text, passwordField.text, sessionCombo.currentIndex)
            }

            ComboBox {
                id: sessionCombo
                width: 300
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                background: Rectangle {
                    color: "#282a36"
                    border.color: "#6272a4"
                    border.width: 1
                    radius: 5
                }
            }

            Button {
                text: textConstants.login
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                background: Rectangle {
                    color: "#bd93f9"
                    radius: 5
                }
                onClicked: sddm.login(userField.text, passwordField.text, sessionCombo.currentIndex)
            }
        }
    }

    Text {
        id: notificationText
        text: notificationMessage
        color: "#ff5555"
        font.pixelSize: 14
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        visible: notificationMessage.length > 0
    }
}
EOF

    echo "${OK} Thème Dracula basique créé" | tee -a "$LOG"
}

# Fonction pour activer SDDM
enable_sddm() {
    echo "${NOTE} Activation de SDDM..." | tee -a "$LOG"

    if sudo systemctl enable sddm 2>/dev/null; then
        echo "${OK} SDDM activé au démarrage" | tee -a "$LOG"
    else
        echo "${ERROR} Échec de l'activation de SDDM" | tee -a "$LOG"
        return 1
    fi

    # Créer le répertoire de session Wayland s'il n'existe pas
    sudo mkdir -p /usr/share/wayland-sessions

    # Créer le fichier de session Hyprland si nécessaire
    if [[ ! -f "/usr/share/wayland-sessions/hyprland.desktop" ]]; then
        sudo tee "/usr/share/wayland-sessions/hyprland.desktop" > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
        echo "${OK} Session Hyprland créée pour SDDM" | tee -a "$LOG"
    fi
}

# Fonction pour configurer la résolution automatique
configure_display_setup() {
    local sddm_script_dir="/usr/share/sddm/scripts"
    local setup_script="$sddm_script_dir/Xsetup"

    sudo mkdir -p "$sddm_script_dir"

    sudo tee "$setup_script" > /dev/null << 'EOF'
#!/bin/sh
# Script de configuration d'affichage pour SDDM

# Détection automatique de la résolution optimale
if command -v xrandr >/dev/null 2>&1; then
    # Obtenir le nom de l'écran principal
    primary_output=$(xrandr | grep " connected primary" | cut -d" " -f1)
    if [[ -z "$primary_output" ]]; then
        primary_output=$(xrandr | grep " connected" | head -1 | cut -d" " -f1)
    fi

    if [[ -n "$primary_output" ]]; then
        # Obtenir la résolution préférée
        preferred_resolution=$(xrandr | grep -A1 "^$primary_output" | tail -1 | awk '{print $1}')
        if [[ -n "$preferred_resolution" ]]; then
            xrandr --output "$primary_output" --mode "$preferred_resolution"
        fi
    fi
fi

# Configurer le curseur
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -cursor_name left_ptr
fi
EOF

    sudo chmod +x "$setup_script"
    echo "${OK} Script de configuration d'affichage créé" | tee -a "$LOG"
}

# Exécution principale
main() {
    echo "${NOTE} === Installation et configuration de SDDM ===" | tee -a "$LOG"

    disable_other_display_managers
    install_sddm
    configure_sddm
    install_sddm_dracula_theme
    configure_display_setup
    enable_sddm

    echo "${OK} Installation de SDDM terminée" | tee -a "$LOG"
    echo "${NOTE} Redémarrez le système pour utiliser SDDM" | tee -a "$LOG"
}

# Exécuter si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi