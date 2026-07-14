#!/bin/bash

# Colores para la terminal
VERDE="\e[0;32m"
AZUL="\e[0;34m"
RESET="\e[0m"

echo -e "${AZUL}[*] Actualizando repositorios e instalando dependencias...${RESET}"
sudo apt update
# Aquí añades todas las dependencias que usa tu entorno
sudo apt install -y awesome xclip rofi neovim bat git pip

echo -e "${AZUL}[*] Creando copia de seguridad de la configuración actual...${RESET}"
if [ -d "$HOME/.config/awesome" ]; then
    mv "$HOME/.config/awesome" "$HOME/.config/awesome.bak_$(date +%Y%m%d_%H%M%S)"
    echo -e "${VERDE}[+] Antigua configuración guardada en .config/awesome.bak_...${RESET}"
fi

echo -e "${AZUL}[*] Instalando tu nuevo entorno personalizado...${RESET}"
mkdir -p "$HOME/.config"
cp -r .config/awesome "$HOME/.config/"

echo -e "${VERDE}[+] ¡Instalación completada con éxito!${RESET}"
echo -e "${VERDE}[+] Cierra sesión o reinicia AwesomeWM para ver los cambios.${RESET}"
