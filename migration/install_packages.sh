#!/bin/bash

# Linux 마이그레이션을 위한 패키지 설치 스크립트
# Ubuntu/Debian 기반 시스템용

echo "=== Linux 마이그레이션 패키지 설치 시작 ==="
echo "이 스크립트는 Ubuntu/Debian 기반 시스템에서 실행됩니다."
echo ""

# 시스템 업데이트
echo "시스템 패키지 목록 업데이트 중..."
sudo apt update

# 기본 개발 도구
echo ""
echo "=== 기본 개발 도구 설치 ==="
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    net-tools \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Python 및 관련 패키지
echo ""
echo "=== Python 3.11 및 관련 패키지 설치 ==="
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-tk

# PostgreSQL 클라이언트 및 개발 라이브러리
echo ""
echo "=== PostgreSQL 클라이언트 설치 ==="
sudo apt install -y \
    postgresql-client \
    postgresql-client-common \
    libpq-dev

# Redis
echo ""
echo "=== Redis 설치 ==="
sudo apt install -y redis-server redis-tools

# Docker 설치
echo ""
echo "=== Docker 설치 ==="
# Docker의 공식 GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker 레포지토리 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt update
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# Node.js 및 npm (Node.js 20.x LTS)
echo ""
echo "=== Node.js 20.x LTS 설치 ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Java 17 (Spring Boot용)
echo ""
echo "=== Java 17 설치 ==="
sudo apt install -y openjdk-17-jdk openjdk-17-jre

# Maven
echo ""
echo "=== Maven 설치 ==="
sudo apt install -y maven

# 시스템 모니터링 도구
echo ""
echo "=== 시스템 모니터링 도구 설치 ==="
sudo apt install -y \
    iotop \
    iftop \
    ncdu \
    tmux \
    screen

# TA-Lib 설치 (Python 기술적 분석 라이브러리)
echo ""
echo "=== TA-Lib 설치 ==="
# TA-Lib C 라이브러리 설치
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/
./configure --prefix=/usr
make
sudo make install
cd ..
rm -rf ta-lib ta-lib-0.4.0-src.tar.gz

# 기타 유용한 도구들
echo ""
echo "=== 기타 유용한 도구 설치 ==="
sudo apt install -y \
    jq \
    tree \
    zip \
    unzip \
    rsync \
    cron \
    logrotate

# Python 가상환경 생성 도구
echo ""
echo "=== Python 가상환경 도구 설정 ==="
python3.11 -m pip install --upgrade pip
python3.11 -m pip install virtualenv

echo ""
echo "=== 설치 완료 ==="
echo ""
echo "다음 명령어를 실행하여 설치를 확인하세요:"
echo "  python3.11 --version"
echo "  node --version"
echo "  npm --version"
echo "  java -version"
echo "  mvn --version"
echo "  docker --version"
echo "  docker compose version"
echo "  redis-server --version"
echo "  psql --version"
echo ""
echo "Docker를 사용하려면 로그아웃 후 다시 로그인하거나 'newgrp docker' 명령을 실행하세요."