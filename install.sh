#!/bin/bash

# Colores para la terminal
VERDE="\e[0;32m"
AZUL="\e[0;34m"
RESET="\e[0m"

echo -e "${AZUL}[*] Actualizando repositorios e instalando dependencias generales...${RESET}"
sudo apt update
# Se añade 'unzip' y 'wget' aquí
sudo apt install -y xclip rofi neovim bat git pip kitty playerctl gir1.2-playerctl-2.0 unzip wget fonts-font-awesome -y

echo -e "${AZUL}[*] Instalando dependencias de desarrollo para AwesomeWM...${RESET}"
sudo apt install -y build-essential cmake lua5.3 liblua5.3-dev luarocks \
libxcb-cursor-dev libxcb-xtest0-dev libxcb-xinerama0-dev libxcb-keysyms1-dev \
libxcb-icccm4-dev libxcb-randr0-dev libxcb-shape0-dev libxcb-xkb-dev \
libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libstartup-notification0-dev \
libgdk-pixbuf-2.0-dev libglib2.0-dev libdbus-1-dev libxdg-basedir-dev \
libpango1.0-dev gettext libxcb-xfixes0-dev lua-lgi libgirepository1.0-dev -y

echo -e "${AZUL}[*] Compilando e instalando la última versión de AwesomeWM (Git)...${RESET}"
if [ -d "/tmp/awesome-git" ]; then
    rm -rf /tmp/awesome-git
fi
git clone https://github.com/awesomeWM/awesome.git /tmp/awesome-git
cd /tmp/awesome-git
make
sudo make install
sudo cp /usr/local/share/xsessions/awesome.desktop /usr/share/xsessions/ 2>/dev/null || true
cd - 

echo -e "${AZUL}[*] Descargando e instalando JetBrainsMono Nerd Font...${RESET}"
mkdir -p "$HOME/.local/share/fonts"
wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip -O /tmp/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/"
rm /tmp/JetBrainsMono.zip
fc-cache -fv

echo -e "${AZUL}[*] Descargando e instalando Iosevka Nerd Font...${RESET}"
wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Iosevka.zip -O /tmp/Iosevka.zip
unzip -o /tmp/Iosevka.zip -d "$HOME/.local/share/fonts/"
rm /tmp/Iosevka.zip
fc-cache -fv

echo -e "${AZUL}[*] Creando copia de seguridad de la configuración actual...${RESET}"
if [ -d "$HOME/.config/awesome" ]; then
    mv "$HOME/.config/awesome" "$HOME/.config/awesome.bak_$(date +%Y%m%d_%H%M%S)"
    echo -e "${VERDE}[+] Antigua configuración de Awesome guardada...${RESET}"
fi

if [ -d "$HOME/.config/kitty" ]; then
    mv "$HOME/.config/kitty" "$HOME/.config/kitty.bak_$(date +%Y%m%d_%H%M%S)"
    echo -e "${VERDE}[+] Antigua configuración de Kitty guardada...${RESET}"
fi

echo -e "${AZUL}[*] Instalando tu nuevo entorno personalizado...${RESET}"
mkdir -p "$HOME/.config"
cp -r .config/awesome "$HOME/.config/"
cp -r .config/kitty "$HOME/.config/"

echo -e "${VERDE}[+] ¡Instalación completada con éxito!${RESET}"
echo -e "${VERDE}[+] Cierra sesión y selecciona AwesomeWM en tu pantalla de inicio para entrar.${RESET}"
