# Meus Dotfiles

Este repositório contém meus arquivos de configuração pessoal (dotfiles) e um script de instalação para configurar rapidamente um novo sistema Fedora com minhas ferramentas e configurações.

##  Pacotes e Aplicativos Instalados

### Via DNF
- Librewolf
- Fastfetch
- Ghostty
- Strawberry
- Ytdl
- Wine e componentes

### Via Flatpak
- GNOME Tweaks
- Bitwarden
- Discord
- Gerenciador de Extensões
- GNOME Extensions
- Gear Lever
- GitHub Desktop
- Heroic Games Launcher
- Komikku
- LibreOffice
- Lutris
- qBittorrent
- VLC
- SaveDesktop
- Steam
- Visual Studio Code
- Telegram
- Navegador Tor
- Spotify

##  Instalação

### Pré-requisitos

- Sistema Linux
- Acesso a sudo

### Instalação Automática

1. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/dotfiles.git
   cd dotfiles
   ```

2. Torne o script de instalação executável:
   ```bash
   chmod +x install.sh
   ```

3. Execute o script de instalação:
   ```bash
   ./install.sh
   ```

4. Reinicie o sistema após a conclusão da instalação para aplicar todas as alterações.

### O que o script faz

1. Cria um backup de seus arquivos de configuração existentes
2. Atualiza o sistema
3. Instala o Flatpak e configura o repositório Flathub
4. Instala o RPM Fusion (repositórios free e nonfree)
5. Instala o Wine e seus componentes
6. Corrige problemas de codec
7. Instala o Git, Zsh, Oh My Zsh e Powerlevel10k
8. Instala aplicativos via DNF e Flatpak
9. Instala fontes para o Powerlevel10k
10. Cria links simbólicos para todos os dotfiles
11. Atualiza o sistema novamente

## ⚙️ Configurações Manuais

Após a instalação, algumas configurações precisam ser feitas manualmente:

### GNOME Tweaks
- Cursor: Skyrim by ry5tyshark
- Ícones: Gruvbox-plus-dark
- Shell: Adwaita
- Aplicativos legados: Adwaita
- Configurar o monitor para 144Hz
- Habilitar botão de maximizar/minimizar janelas

### Outros Programas
- DroidCam - Requer configuração manual
- Firewall - Configurar regras adequadas
- Spicetify - Para integração com o Spotify
- YouTube Music - Baixar pelo repositório do github
