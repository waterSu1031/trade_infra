#!/bin/bash

# Ubuntu Desktop 필수 유틸리티 설치 스크립트
# 일반 사용과 개발에 유용한 도구들
# 실행: bash ubuntu_utilities.sh

set -e

echo "==================== Ubuntu 유틸리티 설치 ===================="
echo "Ubuntu Desktop에서 유용한 유틸리티들을 설치합니다."
echo "============================================================="

# 1. 시스템 유틸리티
echo "1. 시스템 유틸리티 설치..."
sudo apt update
sudo apt install -y \
    neofetch \
    screenfetch \
    inxi \
    hardinfo \
    gparted \
    synaptic \
    gnome-tweaks \
    dconf-editor

# 2. 터미널 도구
echo "2. 터미널 향상 도구..."
sudo apt install -y \
    terminator \
    tilix \
    zsh \
    fish \
    powerline \
    fonts-powerline

# Oh My Zsh 설치 (선택사항)
echo "Oh My Zsh를 설치하시겠습니까? (y/n)"
read -r install_omz
if [ "$install_omz" = "y" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 3. 파일 관리 도구
echo "3. 파일 관리 도구..."
sudo apt install -y \
    mc \
    ranger \
    ncdu \
    tree \
    fd-find \
    ripgrep \
    fzf \
    bat \
    exa

# bat와 fd 별칭 설정
echo "alias bat='batcat'" >> ~/.bashrc
echo "alias fd='fdfind'" >> ~/.bashrc

# 4. 네트워크 도구
echo "4. 네트워크 도구..."
sudo apt install -y \
    net-tools \
    traceroute \
    nmap \
    iftop \
    nethogs \
    speedtest-cli \
    wireshark \
    tcpdump

# 5. 개발 도구
echo "5. 추가 개발 도구..."
sudo apt install -y \
    meld \
    gitg \
    git-cola \
    httpie \
    jq \
    yq \
    direnv

# VS Code 설치
echo "VS Code를 설치하시겠습니까? (y/n)"
read -r install_vscode
if [ "$install_vscode" = "y" ]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
fi

# 6. 미디어 도구
echo "6. 미디어 관련 도구..."
sudo apt install -y \
    vlc \
    mpv \
    audacity \
    obs-studio \
    ffmpeg \
    imagemagick

# 7. 시스템 모니터링 GUI
echo "7. 시스템 모니터링 GUI 도구..."
sudo apt install -y \
    gnome-system-monitor \
    conky \
    conky-all \
    psensor

# Conky 기본 설정
mkdir -p ~/.config/conky
cat > ~/.config/conky/conky.conf << 'EOF'
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    use_xft = true,
    font = 'DejaVu Sans Mono:size=12',
    gap_x = 60,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 5,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_stderr = false,
    extra_newline = false,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = true,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    show_graph_scale = false,
    show_graph_range = false
}

conky.text = [[
${color grey}System:$color ${scroll 32 $sysname $nodename $kernel $machine}
$hr
${color grey}Uptime:$color $uptime
${color grey}CPU Usage:$color $cpu% ${cpubar 4}
${color grey}RAM Usage:$color $mem/$memmax - $memperc% ${membar 4}
${color grey}Swap Usage:$color $swap/$swapmax - $swapperc% ${swapbar 4}
$hr
${color grey}File systems:
 / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
${color grey}Networking:
Up:$color ${upspeed} ${color grey} - Down:$color ${downspeed}
]]
EOF

# 8. 생산성 도구
echo "8. 생산성 도구..."
sudo apt install -y \
    keepassxc \
    flameshot \
    peek \
    copyq \
    albert \
    ulauncher

# 9. 클라우드 스토리지 (선택사항)
echo "9. 클라우드 스토리지 클라이언트를 설치하시겠습니까? (y/n)"
read -r install_cloud
if [ "$install_cloud" = "y" ]; then
    # Dropbox
    wget -O ~/dropbox.deb "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
    sudo dpkg -i ~/dropbox.deb || sudo apt-get install -f -y
    rm ~/dropbox.deb
    
    # rclone (여러 클라우드 지원)
    curl https://rclone.org/install.sh | sudo bash
fi

# 10. 도커 GUI 관리 도구
echo "10. Docker Desktop 대안 (Portainer)을 설치하시겠습니까? (y/n)"
read -r install_portainer
if [ "$install_portainer" = "y" ]; then
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    echo "Portainer가 https://localhost:9443 에서 실행 중입니다."
fi

# 11. 터미널 테마 및 폰트
echo "11. 프로그래밍 폰트 설치..."
sudo apt install -y \
    fonts-firacode \
    fonts-cascadia-code \
    fonts-jetbrains-mono

# 12. GNOME 확장 (GNOME 사용시)
echo "12. GNOME 확장 도구..."
sudo apt install -y \
    gnome-shell-extensions \
    chrome-gnome-shell \
    gnome-shell-extension-manager

# 유용한 별칭 추가
cat >> ~/.bashrc << 'EOF'

# 유용한 별칭
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop'
alias py='python3'
alias pip='pip3'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

# 디렉토리 이동 시 자동 ls
cd() {
    builtin cd "$@" && ls -CF
}

# 추출 함수
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
EOF

echo "==================== 설치 완료 ===================="
echo "설치된 주요 도구:"
echo "- 터미널: terminator, tilix, zsh"
echo "- 파일관리: mc, ranger, ncdu"
echo "- 시스템: htop, btop, neofetch"
echo "- 네트워크: nethogs, iftop, nmap"
echo "- 개발: VS Code, meld, gitg"
echo "- 생산성: flameshot, peek, keepassxc"
echo ""
echo "터미널을 재시작하거나 'source ~/.bashrc' 실행"
echo "================================================="