#!/bin/bash

# =============================================
# Script de instalação (Fedora 41/42, GNOME 48)
# =============================================

# Definição de cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sem Cor (NC = No Color)

# Diretórios
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Função para exibir mensagens de status
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# Função para verificar o sucesso do último comando
check_success() {
    if [ $? -eq 0 ]; then
        log "$1 ✓"
    else
        log_error "$2 ✗"
        # Pode-se adicionar exit 1 aqui se quiser que o script pare em caso de erro
    fi
}

# Função para fazer backup de um arquivo se ele existir
backup_file() {
    if [ -e "$1" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$1" "$BACKUP_DIR/"
        log "Backup de $1 criado em $BACKUP_DIR"
    fi
}

# Função para criar links simbólicos
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Verificar se o arquivo de destino já existe
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_file "$target"
        rm -rf "$target"
    fi
    
    # Criar o diretório pai se não existir
    mkdir -p "$(dirname "$target")"
    
    # Criar o link simbólico
    ln -sf "$source" "$target"
    check_success "Link simbólico criado: $target -> $source" "Falha ao criar link simbólico para $target"
}

# Início da instalação
log "Iniciando script de instalação..."

# Criar diretório de backup
mkdir -p "$BACKUP_DIR"
log "Diretório de backup criado: $BACKUP_DIR"

# Atualizar o sistema
log "Atualizando o sistema..."
sudo dnf upgrade -y
check_success "Sistema atualizado" "Falha ao atualizar o sistema"

# Instalar Flatpak e adicionar o repositório Flathub
log "Instalando Flatpak e adicionando o repositório Flathub..."
sudo dnf install flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
check_success "Flatpak e Flathub configurados" "Falha ao configurar Flatpak e Flathub"

# Instalar o RPM Fusion
log "Instalando RPM Fusion..."
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
check_success "RPM Fusion instalado" "Falha ao instalar RPM Fusion"

# Instalar Wine e dependências essenciais
log "Instalando Wine e pacotes necessários..."
sudo dnf install wine winetricks -y
check_success "Wine instalado" "Falha ao instalar Wine"

# Instalar o Wine Gecko e Mono
log "Instalando componentes do Wine..."
wine --install-gecko
wine --install-mono
check_success "Componentes do Wine instalados" "Falha ao instalar componentes do Wine"

# Instalar fontes do Windows
log "Instalando fontes do Windows..."
sudo dnf install msttcore-fonts-installer -y
check_success "Fontes do Windows instaladas" "Falha ao instalar fontes do Windows"

# Instalar winetricks components
log "Instalando componentes adicionais para o Wine..."
winetricks vcrun2008 directx9
check_success "Componentes adicionais para o Wine instalados" "Falha ao instalar componentes adicionais para o Wine"

# Corrigir problemas de codec
log "Corrigindo problemas de codec..."
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
sudo dnf groupupdate sound-and-video -y
sudo dnf install amrnb amrwb faad2 flac gpac-libs lame libde265 libfc14audiodecoder mencoder x264 x265 ffmpegthumbnailer -y
check_success "Codecs instalados" "Falha ao instalar codecs"

# Instalar o Git
log "Instalando o Git..."
sudo dnf install git -y
check_success "Git instalado" "Falha ao instalar Git"

# Instalar o Zsh e configurar como shell padrão
log "Instalando Zsh..."
sudo dnf install zsh -y
check_success "Zsh instalado" "Falha ao instalar Zsh"

# Alterar o shell padrão para Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    log "Alterando shell padrão para Zsh..."
    chsh -s $(which zsh)
    check_success "Shell alterado para Zsh" "Falha ao alterar shell para Zsh"
fi

# Instalar Oh My Zsh se não estiver instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    check_success "Oh My Zsh instalado" "Falha ao instalar Oh My Zsh"
else
    log "Oh My Zsh já está instalado"
fi

# Instalar Powerlevel10k se não estiver instalado
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    log "Instalando tema Powerlevel10k para Zsh..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    check_success "Powerlevel10k instalado" "Falha ao instalar Powerlevel10k"
else
    log "Powerlevel10k já está instalado"
fi

# Instalar softwares nativos via DNF
log "Instalando pacotes nativos via DNF..."
DNF_SOFTWARE_LIST="librewolf fastfetch ghostty strawberry ytdl"

for software in $DNF_SOFTWARE_LIST; do
    log "Instalando $software via DNF..."
    sudo dnf install $software -y
    check_success "$software instalado" "Falha ao instalar $software"
done

# Instalar aplicativos Flatpak
log "Instalando aplicativos via Flatpak..."

# Definir array de aplicativos Flatpak
declare -A FLATPAKS=(
    ["GNOME Tweaks"]="org.gnome.tweaks"
    ["Bitwarden"]="com.bitwarden.desktop"
    ["Discord"]="com.discordapp.Discord" 
    ["Extension Manager"]="com.mattjakeman.ExtensionManager"
    ["GNOME Extensions"]="org.gnome.Extensions"
    ["Gear Lever"]="it.mijorus.gearlever"
    ["GitHub Desktop"]="io.github.shiftey.Desktop"
    ["Heroic Games Launcher"]="com.heroicgameslauncher.hgl"
    ["Komikku"]="info.febvre.Komikku"
    ["LibreOffice"]="org.libreoffice.LibreOffice"
    ["Lutris"]="net.lutris.Lutris"
    ["qBittorrent"]="org.qbittorrent.qBittorrent"
    ["VLC"]="org.videolan.VLC"
    ["SaveDesktop"]="io.github.vikdevelop.SaveDesktop"
    ["Steam"]="com.valvesoftware.Steam"
    ["Visual Studio Code"]="com.visualstudio.code"
    ["Telegram"]="org.telegram.desktop"
    ["Tor Browser"]="com.github.micahflee.torbrowser-launcher"
    ["Spotify"]="com.spotify.Client"
)

# Instalar cada Flatpak
for app_name in "${!FLATPAKS[@]}"; do
    app_id="${FLATPAKS[$app_name]}"
    log "Instalando $app_name via Flatpak..."
    flatpak install flathub "$app_id" -y
    check_success "$app_name instalado via Flatpak" "Falha ao instalar $app_name via Flatpak"
done

# Instalar as fontes Meslo para Powerlevel10k
log "Instalando fontes Meslo para Powerlevel10k..."
mkdir -p ~/.local/share/fonts
for font in "$DOTFILES_DIR"/fonts/*.ttf; do
    cp "$font" ~/.local/share/fonts/
done
fc-cache -f
check_success "Fontes instaladas" "Falha ao instalar fontes"

# Criando links simbólicos para dotfiles
log "Criando links simbólicos para dotfiles..."

# Lista de arquivos para criar links simbólicos (origem no repositório -> destino)
declare -A symlinks=(
    ["$DOTFILES_DIR/.gitconfig"]="$HOME/.gitconfig"
    ["$DOTFILES_DIR/.zshrc"]="$HOME/.zshrc"
    ["$DOTFILES_DIR/.p10k.zsh"]="$HOME/.p10k.zsh"
    ["$DOTFILES_DIR/.config/fastfetch/config.jsonc"]="$HOME/.config/fastfetch/config.jsonc"
    # Adicione mais arquivos conforme necessário
)

# Criar links simbólicos para cada arquivo
for src in "${!symlinks[@]}"; do
    create_symlink "$src" "${symlinks[$src]}"
done

# Se Ghostty estiver instalado, criar link para sua configuração
if command -v ghostty &> /dev/null; then
    if [ -f "$DOTFILES_DIR/.config/ghostty/config" ]; then
        create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
    fi
fi

# Atualizar o sistema novamente
log "Atualizando o sistema novamente..."
sudo dnf upgrade -y
check_success "Sistema atualizado" "Falha ao atualizar o sistema"

# Avisos de configurações manuais
log_warning "Alguns programas precisam de configuração manual:"
echo -e " - DroidCam - Configure manualmente."
echo -e " - Firewall - Certifique-se de configurar as regras de firewall adequadas."
echo -e " - Spicetify - Configuração manual necessária para integração com o Spotify."
echo -e " - YouTube Music - Configure manualmente para integração com o Spotify."

log_warning "Configurações do GNOME Tweaks para aplicar manualmente:"
echo -e " - Cursor: Skyrim by ry5tyshark"
echo -e " - Ícones: Gruvbox-plus-dark"
echo -e " - Shell: Adwaita"
echo -e " - Aplicativos legados: Adwaita"
echo -e " - Configurar o monitor para 144Hz"
echo -e " - Habilitar botão de maximizar/minimizar janelas no GNOME Tweaks"

log "Instalação concluída! Reiniciar o sistema."
