#!/bin/bash

# Colores para la terminal
VERDE="\e[0;32m"
AZUL="\e[0;34m"
RESET="\e[0m"

echo -e "${AZUL}[*] Actualizando repositorios e instalando dependencias...${RESET}"
sudo apt update
# 1. SE AÑADE 'kitty' A LAS DEPENDENCIAS
sudo apt install -y awesome xclip rofi neovim bat git pip Kitty playerctl gir1.2-playerctl-2.0

echo -e "${AZUL}[*] Creando copia de seguridad de la configuración actual...${RESET}"
# Copia de seguridad de AwesomeWM
if [ -d "$HOME/.config/awesome" ]; then
    mv "$HOME/.config/awesome" "$HOME/.config/awesome.bak_$(date +%Y%m%d_%H%M%S)"
    echo -e "${VERDE}[+] Antigua configuración de Awesome guardada en .config/awesome.bak_...${RESET}"
fi

# 2. SE AÑADE RESPALDO PARA KITTY
if [ -d "$HOME/.config/kitty" ]; then
    mv "$HOME/.config/kitty" "$HOME/.config/kitty.bak_$(date +%Y%m%d_%H%M%S)"
    echo -e "${VERDE}[+] Antigua configuración de Kitty guardada en .config/kitty.bak_...${RESET}"
fi

echo -e "${AZUL}[*] Instalando tu nuevo entorno personalizado...${RESET}"
mkdir -p "$HOME/.config"

# 3. SE COPIAN AMBAS CONFIGURACIONES
cp -r .config/awesome "$HOME/.config/"
cp -r .config/kitty "$HOME/.config/"

echo -e "${VERDE}[+] ¡Instalación completada con éxito!${RESET}"
echo -e "${VERDE}[+] Cierra sesión o reinicia AwesomeWM para ver los cambios.${RESET}"
