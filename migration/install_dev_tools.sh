#!/bin/bash

# 개발 도구 설치 스크립트
# Ubuntu/Debian 기반 시스템용

echo "=== 개발 도구 설치 시작 ==="
echo "이 스크립트는 VSCode, PyCharm, IntelliJ IDEA 등의 개발 도구를 설치합니다."
echo ""

# 색상 코드 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 함수: 설치 성공/실패 메시지
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 설치 완료${NC}"
    else
        echo -e "${RED}✗ $1 설치 실패${NC}"
    fi
}

# 1. Visual Studio Code 설치
echo ""
echo -e "${YELLOW}=== Visual Studio Code 설치 ===${NC}"
# Microsoft GPG 키 추가
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/

# VSCode 저장소 추가
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# apt 업데이트 및 VSCode 설치
sudo apt update
sudo apt install -y code
print_status "Visual Studio Code"

# VSCode 확장 프로그램 설치
echo "VSCode 확장 프로그램 설치 중..."
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.debugpy
code --install-extension ms-vscode.cpptools
code --install-extension vscjava.vscode-java-pack
code --install-extension svelte.svelte-vscode
code --install-extension bradlc.vscode-tailwindcss
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension redhat.vscode-yaml
code --install-extension mtxr.sqltools
code --install-extension mtxr.sqltools-driver-pg
code --install-extension golang.go
code --install-extension rust-lang.rust-analyzer

# 2. JetBrains Toolbox 설치 (PyCharm, IntelliJ IDEA 관리용)
echo ""
echo -e "${YELLOW}=== JetBrains Toolbox 설치 ===${NC}"
JETBRAINS_TOOLBOX_VERSION=$(curl -s https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release | grep -Po '"version":"\K[^"]*')
wget -O jetbrains-toolbox.tar.gz "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_TOOLBOX_VERSION}.tar.gz"
tar -xzf jetbrains-toolbox.tar.gz
sudo mv jetbrains-toolbox-*/jetbrains-toolbox /opt/jetbrains-toolbox
sudo ln -s /opt/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
rm -rf jetbrains-toolbox.tar.gz jetbrains-toolbox-*
print_status "JetBrains Toolbox"

# 3. PyCharm Community Edition 설치 (snap 사용)
echo ""
echo -e "${YELLOW}=== PyCharm Community Edition 설치 ===${NC}"
sudo snap install pycharm-community --classic
print_status "PyCharm Community Edition"

# 4. IntelliJ IDEA Community Edition 설치 (snap 사용)
echo ""
echo -e "${YELLOW}=== IntelliJ IDEA Community Edition 설치 ===${NC}"
sudo snap install intellij-idea-community --classic
print_status "IntelliJ IDEA Community Edition"

# 5. DBeaver (데이터베이스 관리 도구)
echo ""
echo -e "${YELLOW}=== DBeaver 설치 ===${NC}"
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
sudo apt update
sudo apt install -y dbeaver-ce
print_status "DBeaver"

# 6. Postman (API 테스트 도구)
echo ""
echo -e "${YELLOW}=== Postman 설치 ===${NC}"
sudo snap install postman
print_status "Postman"

# 7. Git GUI 도구들
echo ""
echo -e "${YELLOW}=== Git GUI 도구 설치 ===${NC}"
sudo apt install -y gitk git-gui gitg
print_status "Git GUI 도구"

# 8. 터미널 도구
echo ""
echo -e "${YELLOW}=== 터미널 도구 설치 ===${NC}"
# Terminator (고급 터미널 에뮬레이터)
sudo apt install -y terminator

# Zsh 및 Oh My Zsh
sudo apt install -y zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
print_status "터미널 도구"

# 9. 개발 유틸리티
echo ""
echo -e "${YELLOW}=== 개발 유틸리티 설치 ===${NC}"
sudo apt install -y \
    meld \
    filezilla \
    remmina \
    peek \
    flameshot

# httpie (curl 대체 HTTP 클라이언트)
sudo apt install -y httpie

# jq (JSON 프로세서)
sudo apt install -y jq

# fzf (fuzzy finder)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-bash --no-fish

print_status "개발 유틸리티"

# 10. 컨테이너 관리 도구
echo ""
echo -e "${YELLOW}=== 컨테이너 관리 도구 설치 ===${NC}"
# Lazydocker
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# ctop
sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

print_status "컨테이너 관리 도구"

# 11. Python 개발 도구
echo ""
echo -e "${YELLOW}=== Python 개발 도구 설치 ===${NC}"
pip3 install --user \
    ipython \
    jupyter \
    notebook \
    black \
    flake8 \
    pylint \
    mypy \
    pytest \
    poetry \
    pipenv

print_status "Python 개발 도구"

# 12. Node.js 개발 도구
echo ""
echo -e "${YELLOW}=== Node.js 개발 도구 설치 ===${NC}"
sudo npm install -g \
    yarn \
    pnpm \
    typescript \
    ts-node \
    nodemon \
    pm2 \
    eslint \
    prettier

print_status "Node.js 개발 도구"

# 13. 성능 분석 도구
echo ""
echo -e "${YELLOW}=== 성능 분석 도구 설치 ===${NC}"
sudo apt install -y \
    sysstat \
    dstat \
    glances \
    nethogs \
    bmon

print_status "성능 분석 도구"

# 14. 추가 추천 도구
echo ""
echo -e "${YELLOW}=== 추가 추천 도구 정보 ===${NC}"
echo "다음 도구들은 필요에 따라 수동으로 설치하세요:"
echo ""
echo "1. Sublime Text:"
echo "   wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -"
echo "   sudo apt-add-repository 'deb https://download.sublimetext.com/ apt/stable/'"
echo "   sudo apt update && sudo apt install sublime-text"
echo ""
echo "2. DataGrip (상용):"
echo "   JetBrains Toolbox를 통해 설치"
echo ""
echo "3. TablePlus (데이터베이스 GUI):"
echo "   https://tableplus.com/linux 에서 다운로드"
echo ""
echo "4. Beyond Compare (파일 비교 도구):"
echo "   https://www.scootersoftware.com/download.php"
echo ""

# 설치 완료 메시지
echo ""
echo -e "${GREEN}=== 개발 도구 설치 완료 ===${NC}"
echo ""
echo "설치된 도구 확인:"
echo "  code --version           # VS Code"
echo "  pycharm-community        # PyCharm"
echo "  intellij-idea-community  # IntelliJ IDEA"
echo "  dbeaver                  # DBeaver"
echo "  postman                  # Postman"
echo ""
echo "터미널을 재시작하거나 'source ~/.bashrc'를 실행하여 설정을 적용하세요."
echo ""
echo "JetBrains Toolbox는 '/opt/jetbrains-toolbox'에서 실행할 수 있습니다."
echo "VSCode 확장 프로그램은 자동으로 설치되었습니다."