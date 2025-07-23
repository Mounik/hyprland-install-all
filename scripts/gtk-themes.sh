#!/bin/bash
# Installation et configuration des thèmes GTK pour Hyprland Universal

echo "${NOTE} Installation des thèmes GTK..." | tee -a "$LOG"

# Fonction pour installer les thèmes GTK
install_gtk_themes() {
    local gtk_packages=()

    case $DISTRO_FAMILY in
        "arch")
            gtk_packages=(
                "gtk3"
                "gtk4"
                "dracula-gtk-theme"
                "dracula-icons-git"
                "lxappearance"
                "qt5ct"
                "kvantum"
            )
            ;;
        "debian")
            gtk_packages=(
                "gtk2-engines-murrine"
                "gtk2-engines-pixbuf"
                "sassc"
                "lxappearance"
                "qt5ct"
                "qt5-style-kvantum"
            )
            ;;
        "redhat")
            gtk_packages=(
                "gtk-murrine-engine"
                "gtk2-engines"
                "sassc"
                "lxappearance"
                "qt5ct"
                "kvantum"
            )
            ;;
        "suse")
            gtk_packages=(
                "gtk2-engine-murrine"
                "gtk3-tools"
                "sassc"
                "lxappearance"
                "libqt5-qttools"
                "kvantum-manager"
            )
            ;;
    esac

    for package in "${gtk_packages[@]}"; do
        install_package "$package"
    done
}

# Fonction pour installer le thème Dracula manuellement si nécessaire
install_dracula_theme() {
    local themes_dir="$HOME/.themes"
    local icons_dir="$HOME/.icons"

    mkdir -p "$themes_dir" "$icons_dir"

    # Installation du thème Dracula GTK
    if [[ ! -d "$themes_dir/Dracula" ]]; then
        echo "${NOTE} Installation du thème Dracula GTK..." | tee -a "$LOG"
        cd /tmp
        if git clone https://github.com/dracula/gtk.git dracula-gtk 2>/dev/null; then
            cp -r dracula-gtk/theme "$themes_dir/Dracula"
            rm -rf dracula-gtk
            echo "${OK} Thème Dracula GTK installé" | tee -a "$LOG"
        else
            echo "${ERROR} Échec de l'installation du thème Dracula GTK" | tee -a "$LOG"
        fi
    fi

    # Installation des icônes Dracula
    if [[ ! -d "$icons_dir/Dracula" ]]; then
        echo "${NOTE} Installation des icônes Dracula..." | tee -a "$LOG"
        cd /tmp
        if git clone https://github.com/dracula/gtk.git dracula-icons 2>/dev/null; then
            if [[ -d "dracula-icons/icons" ]]; then
                cp -r dracula-icons/icons "$icons_dir/Dracula"
            fi
            rm -rf dracula-icons
            echo "${OK} Icônes Dracula installées" | tee -a "$LOG"
        else
            echo "${ERROR} Échec de l'installation des icônes Dracula" | tee -a "$LOG"
        fi
    fi
}

# Fonction pour configurer les thèmes GTK
configure_gtk_themes() {
    local gtk3_config="$HOME/.config/gtk-3.0/settings.ini"
    local gtk4_config="$HOME/.config/gtk-4.0/settings.ini"
    local gtkrc_config="$HOME/.gtkrc-2.0"

    # Configuration GTK3
    mkdir -p "$(dirname "$gtk3_config")"
    cat > "$gtk3_config" << 'EOF'
[Settings]
gtk-theme-name=Dracula
gtk-icon-theme-name=Dracula
gtk-font-name=JetBrainsMono Nerd Font 11
gtk-cursor-theme-name=Dracula-cursors
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

    # Configuration GTK4
    mkdir -p "$(dirname "$gtk4_config")"
    cat > "$gtk4_config" << 'EOF'
[Settings]
gtk-theme-name=Dracula
gtk-icon-theme-name=Dracula
gtk-font-name=JetBrainsMono Nerd Font 11
gtk-cursor-theme-name=Dracula-cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

    # Configuration GTK2
    cat > "$gtkrc_config" << 'EOF'
gtk-theme-name="Dracula"
gtk-icon-theme-name="Dracula"
gtk-font-name="JetBrainsMono Nerd Font 11"
gtk-cursor-theme-name="Dracula-cursors"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
gtk-xft-rgba="rgb"
EOF

    echo "${OK} Configuration GTK appliquée" | tee -a "$LOG"
}

# Fonction pour configurer Qt5
configure_qt5_theme() {
    local qt5ct_config="$HOME/.config/qt5ct/qt5ct.conf"

    mkdir -p "$(dirname "$qt5ct_config")"
    cat > "$qt5ct_config" << 'EOF'
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/dracula.conf
custom_palette=false
icon_theme=Dracula
standard_dialogs=default
style=kvantum-dark

[Fonts]
fixed=@Variant(\0\0\0@\0\0\0\x1c\0J\0\x65\0t\0\x42\0r\0\x61\0i\0n\0s\0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
general=@Variant(\0\0\0@\0\0\0\x1c\0J\0\x65\0t\0\x42\0r\0\x61\0i\0n\0s\0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray()
EOF

    # Configuration des variables d'environnement Qt
    local env_config="$HOME/.config/environment.d/qt.conf"
    mkdir -p "$(dirname "$env_config")"
    cat > "$env_config" << 'EOF'
QT_QPA_PLATFORMTHEME=qt5ct
QT_STYLE_OVERRIDE=kvantum
EOF

    echo "${OK} Configuration Qt5 appliquée" | tee -a "$LOG"
}

# Fonction pour installer les curseurs Dracula
install_dracula_cursors() {
    local cursors_dir="$HOME/.icons"

    if [[ ! -d "$cursors_dir/Dracula-cursors" ]]; then
        echo "${NOTE} Installation des curseurs Dracula..." | tee -a "$LOG"
        cd /tmp
        if git clone https://github.com/dracula/cursor-theme.git dracula-cursors 2>/dev/null; then
            mkdir -p "$cursors_dir"
            cp -r dracula-cursors/dist "$cursors_dir/Dracula-cursors"
            rm -rf dracula-cursors
            echo "${OK} Curseurs Dracula installés" | tee -a "$LOG"
        else
            echo "${ERROR} Échec de l'installation des curseurs Dracula" | tee -a "$LOG"
        fi
    fi
}

# Fonction pour activer les thèmes
apply_themes() {
    # Application immédiate des thèmes GTK
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
        gsettings set org.gnome.desktop.interface icon-theme "Dracula"
        gsettings set org.gnome.desktop.interface cursor-theme "Dracula-cursors"
        gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font 11"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
        echo "${OK} Thèmes appliqués via gsettings" | tee -a "$LOG"
    fi

    # Rechargement des thèmes pour les applications en cours
    if command -v xsettingsd &> /dev/null; then
        pkill -HUP xsettingsd 2>/dev/null || true
    fi
}

# Exécution principale
main() {
    echo "${NOTE} === Installation des thèmes GTK ===" | tee -a "$LOG"

    install_gtk_themes
    install_dracula_theme
    install_dracula_cursors
    configure_gtk_themes
    configure_qt5_theme
    apply_themes

    echo "${OK} Installation des thèmes GTK terminée" | tee -a "$LOG"
}

# Exécuter si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi