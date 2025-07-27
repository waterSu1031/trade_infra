# 개발 도구 설정 가이드

## 개요
이 문서는 Linux 환경에서 트레이딩 시스템 개발에 필요한 IDE와 도구들의 설정 방법을 안내합니다.

## 1. 자동 설치

```bash
cd migration
./install_dev_tools.sh
```

## 2. 설치되는 주요 개발 도구

### 2.1 통합 개발 환경 (IDE)

#### Visual Studio Code
- **설치 확인**: `code --version`
- **주요 확장 프로그램** (자동 설치됨):
  - Python (ms-python.python)
  - Pylance (ms-python.vscode-pylance)
  - Java Extension Pack
  - Svelte for VS Code
  - Docker
  - Remote Development
  - PostgreSQL 도구

#### PyCharm Community Edition
- **실행**: `pycharm-community`
- **Python 프로젝트 설정**:
  1. File → Settings → Project → Python Interpreter
  2. 가상환경 선택: `/path/to/project/venv/bin/python`

#### IntelliJ IDEA Community Edition
- **실행**: `intellij-idea-community`
- **Spring Boot 프로젝트 설정**:
  1. File → Project Structure → Project SDK → Java 17
  2. Maven 설정 자동 감지

### 2.2 데이터베이스 도구

#### DBeaver
- **실행**: `dbeaver`
- **PostgreSQL 연결 설정**:
  ```
  Host: localhost
  Port: 5432
  Database: trade_db
  Username: trade_user
  Password: trade_pass
  ```

### 2.3 API 개발 도구

#### Postman
- **실행**: `postman`
- **환경 변수 설정**:
  ```json
  {
    "baseUrl": "http://localhost:8000",
    "wsUrl": "ws://localhost:8000"
  }
  ```

## 3. 프로젝트별 IDE 설정

### 3.1 trade_engine (Python)

#### VS Code 설정
`.vscode/settings.json` 생성:
```json
{
    "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.testing.pytestEnabled": true,
    "files.exclude": {
        "**/__pycache__": true,
        "**/*.pyc": true
    }
}
```

#### PyCharm 설정
1. **인터프리터 설정**:
   - Settings → Project → Python Interpreter
   - Add Interpreter → Existing Environment
   - `trade_engine/venv/bin/python` 선택

2. **코드 스타일**:
   - Settings → Editor → Code Style → Python
   - Line length: 88 (Black 기본값)

### 3.2 trade_dashboard (FastAPI)

#### VS Code 디버그 설정
`.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "FastAPI",
            "type": "python",
            "request": "launch",
            "module": "uvicorn",
            "args": [
                "app.main:app",
                "--reload",
                "--host", "0.0.0.0",
                "--port", "8000"
            ],
            "jinja": true,
            "envFile": "${workspaceFolder}/.env"
        }
    ]
}
```

### 3.3 trade_frontend (Svelte + TypeScript)

#### VS Code 설정
`.vscode/settings.json`:
```json
{
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "[svelte]": {
        "editor.defaultFormatter": "svelte.svelte-vscode"
    },
    "svelte.enable-ts-plugin": true,
    "typescript.tsdk": "node_modules/typescript/lib"
}
```

### 3.4 trade_batch (Spring Boot)

#### IntelliJ IDEA 설정
1. **프로젝트 가져오기**:
   - File → Open → `trade_batch/pom.xml` 선택
   - "Open as Project" 선택

2. **실행 구성**:
   - Run → Edit Configurations
   - Add New Configuration → Spring Boot
   - Main class: `com.trade.batch.BatchApplication`

## 4. 터미널 환경 설정

### 4.1 Zsh + Oh My Zsh
```bash
# 기본 셸을 zsh로 변경
chsh -s $(which zsh)

# 플러그인 설치 (자동완성, 구문 강조)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# ~/.zshrc 편집
plugins=(git docker docker-compose python node npm mvn zsh-autosuggestions zsh-syntax-highlighting)
```

### 4.2 유용한 별칭 설정
`~/.zshrc` 또는 `~/.bashrc`에 추가:
```bash
# Docker 별칭
alias dc='docker compose'
alias dps='docker ps'
alias dlog='docker logs -f'

# Python 별칭
alias py='python3.11'
alias venv='source venv/bin/activate'
alias pipr='pip install -r requirements.txt'

# Git 별칭
alias gs='git status'
alias gd='git diff'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph'

# 프로젝트 디렉토리 바로가기
alias trade='cd ~/workspace/trade'
alias engine='cd ~/workspace/trade/trade_engine && venv'
alias dashboard='cd ~/workspace/trade/trade_dashboard && venv'
alias frontend='cd ~/workspace/trade/trade_frontend'
alias batch='cd ~/workspace/trade/trade_batch'
```

## 5. 개발 도구 통합

### 5.1 Git 설정
```bash
# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 유용한 설정
git config --global core.editor "code --wait"
git config --global merge.tool "meld"
git config --global diff.tool "meld"
```

### 5.2 Docker 개발 환경
VS Code Remote Containers 사용:
1. F1 → "Remote-Containers: Open Folder in Container"
2. Docker Compose 파일 선택
3. 컨테이너 내에서 개발

### 5.3 디버깅 설정

#### Python (VS Code)
```json
{
    "name": "Python: Remote Attach",
    "type": "python",
    "request": "attach",
    "connect": {
        "host": "localhost",
        "port": 5678
    },
    "pathMappings": [
        {
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/app"
        }
    ]
}
```

#### Java (IntelliJ IDEA)
1. Run → Edit Configurations
2. Add New Configuration → Remote JVM Debug
3. Port: 5005
4. Docker 컨테이너 실행 시 JVM 옵션 추가:
   ```
   -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
   ```

## 6. 성능 모니터링 도구

### 6.1 시스템 모니터링
- **htop**: 향상된 프로세스 뷰어
- **glances**: 시스템 모니터링 대시보드
- **dstat**: 시스템 리소스 통계

### 6.2 Docker 모니터링
- **lazydocker**: TUI Docker 관리 도구
- **ctop**: 컨테이너 메트릭 뷰어

## 7. 추가 권장 설정

### 7.1 VS Code 동기화
Settings Sync 기능을 사용하여 Windows와 Linux 간 설정 동기화:
1. Ctrl+Shift+P → "Settings Sync: Turn On"
2. GitHub 또는 Microsoft 계정으로 로그인

### 7.2 JetBrains 도구 동기화
JetBrains 계정을 통해 설정 동기화:
1. File → Manage IDE Settings → Sync Settings to JetBrains Account

### 7.3 커스텀 단축키
각 IDE에서 Windows와 동일한 단축키 설정:
- VS Code: File → Preferences → Keybindings
- PyCharm/IntelliJ: File → Settings → Keymap

## 8. 문제 해결

### IDE가 느린 경우
```bash
# swap 파일 크기 늘리기
sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile bs=1G count=8
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 폰트 렌더링 개선
```bash
sudo apt install fonts-firacode
# IDE에서 Fira Code 폰트 선택
```

### GPU 가속 활성화 (있는 경우)
VS Code에서 GPU 가속:
```json
{
    "terminal.integrated.gpuAcceleration": "on",
    "editor.experimentalWhitespaceRendering": "font"
}
```