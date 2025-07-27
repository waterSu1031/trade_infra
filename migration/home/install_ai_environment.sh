#!/bin/bash

# Ubuntu Desktop AI Learning Environment Setup Script
# 원격 AI 학습 환경 구성을 위한 자동 설치 스크립트
# 실행: bash install_ai_environment.sh

set -e

echo "==================== Ubuntu AI Environment Setup ===================="
echo "이 스크립트는 AI 학습에 필요한 모든 환경을 자동으로 설치합니다."
echo "===================================================================="

# 시스템 업데이트
echo "1. 시스템 패키지 업데이트..."
sudo apt update && sudo apt upgrade -y

# 기본 개발 도구 설치
echo "2. 기본 개발 도구 설치..."
sudo apt install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    vim \
    htop \
    tmux \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Python 환경 설치
echo "3. Python 및 pip 설치..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python3-wheel \
    python3-setuptools

# Python 패키지 업그레이드
pip3 install --upgrade pip setuptools wheel

# NVIDIA 드라이버 설치 (선택사항)
echo "4. NVIDIA GPU가 있습니까? (y/n)"
read -r has_gpu
if [ "$has_gpu" = "y" ]; then
    echo "NVIDIA 드라이버 설치..."
    sudo add-apt-repository ppa:graphics-drivers/ppa -y
    sudo apt update
    
    # 추천 드라이버 확인
    ubuntu-drivers devices
    
    echo "추천 드라이버를 자동 설치하시겠습니까? (y/n)"
    read -r auto_install
    if [ "$auto_install" = "y" ]; then
        sudo ubuntu-drivers autoinstall
    else
        echo "수동으로 설치: sudo apt install nvidia-driver-535"
    fi
    
    # CUDA Toolkit 설치
    echo "CUDA Toolkit 설치..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
    sudo dpkg -i cuda-keyring_1.0-1_all.deb
    sudo apt update
    sudo apt install -y cuda
    
    # cuDNN 설치 안내
    echo "cuDNN은 NVIDIA 개발자 계정이 필요합니다."
    echo "https://developer.nvidia.com/cudnn 에서 다운로드 후 설치하세요."
fi

# Docker 설치
echo "5. Docker 설치..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# NVIDIA Docker 지원 (GPU가 있는 경우)
if [ "$has_gpu" = "y" ]; then
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt update
    sudo apt install -y nvidia-docker2
    sudo systemctl restart docker
fi

# AI/ML 프레임워크 설치
echo "6. AI/ML 프레임워크 설치..."
pip3 install --user \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    jupyterlab \
    notebook \
    ipython

# TensorFlow 설치
echo "TensorFlow 설치 (GPU 지원 포함)..."
if [ "$has_gpu" = "y" ]; then
    pip3 install --user tensorflow[and-cuda]
else
    pip3 install --user tensorflow
fi

# PyTorch 설치
echo "PyTorch 설치..."
if [ "$has_gpu" = "y" ]; then
    pip3 install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
else
    pip3 install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
fi

# 추가 AI 도구
pip3 install --user \
    transformers \
    datasets \
    accelerate \
    langchain \
    openai \
    gradio \
    streamlit

# VS Code Server 설치
echo "7. VS Code Server 설치..."
wget -O- https://aka.ms/install-vscode-server/setup.sh | sh

# SSH 서버 설정
echo "8. SSH 서버 설정..."
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# VNC 서버 설치 (원격 데스크톱)
echo "9. VNC 서버를 설치하시겠습니까? (y/n)"
read -r install_vnc
if [ "$install_vnc" = "y" ]; then
    sudo apt install -y xfce4 xfce4-goodies tightvncserver
    echo "VNC 비밀번호 설정이 필요합니다. 'vncserver' 명령을 실행하세요."
fi

# 시스템 모니터링 도구
echo "10. 시스템 모니터링 도구 설치..."
sudo apt install -y \
    nvidia-smi \
    nvtop \
    btop \
    iotop \
    nethogs

# Jupyter 설정
echo "11. Jupyter 원격 접속 설정..."
jupyter notebook --generate-config
echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.port = 8888" >> ~/.jupyter/jupyter_notebook_config.py

# 방화벽 설정
echo "12. 방화벽 포트 열기..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 8888/tcp  # Jupyter
sudo ufw allow 5900/tcp  # VNC
sudo ufw allow 8080/tcp  # 웹 서버

echo "==================== 설치 완료 ===================="
echo "다음 단계:"
echo "1. 재부팅: sudo reboot"
echo "2. Docker 그룹 적용: newgrp docker"
echo "3. Jupyter 비밀번호 설정: jupyter notebook password"
echo "4. GPU 확인: nvidia-smi (GPU가 있는 경우)"
echo "=================================================="