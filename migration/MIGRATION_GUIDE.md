# Windows에서 Linux로 마이그레이션 가이드

## 개요
이 문서는 Windows 환경에서 개발된 트레이딩 시스템을 Linux 환경으로 마이그레이션하기 위한 가이드입니다.

## 1. 시스템 패키지 설치

### 자동 설치 스크립트 실행
```bash
cd migration
./install_packages.sh
```

### 설치되는 주요 패키지
- **개발 도구**: build-essential, git, curl, wget
- **Python 3.11**: 프로젝트의 주 프로그래밍 언어
- **Node.js 20.x**: Frontend 개발용
- **Java 17**: Spring Boot 배치 애플리케이션용
- **Docker & Docker Compose**: 컨테이너 환경
- **PostgreSQL Client**: 데이터베이스 연결
- **Redis**: 캐싱 및 메시지 브로커

## 2. 프로젝트별 환경 설정

### 2.1 trade_engine (Python)
```bash
cd trade_engine
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**주의사항**:
- Windows 전용 패키지 제거 필요: `pywin32`
- TA-Lib의 경우 Linux용으로 재설치:
  ```bash
  pip uninstall ta-lib
  pip install ta-lib
  ```

### 2.2 trade_dashboard (Python FastAPI)
```bash
cd trade_dashboard
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2.3 trade_frontend (Node.js)
```bash
cd trade_frontend
npm install
```

### 2.4 trade_batch (Java Spring Boot)
```bash
cd trade_batch
# IBKR TWS API JAR 설치
mvn install:install-file \
  -Dfile=lib/TwsApi.jar \
  -DgroupId=com.ibkr \
  -DartifactId=TwsApi \
  -Dversion=10.30 \
  -Dpackaging=jar

# 프로젝트 빌드
mvn clean package
```

## 3. 추가 설치가 필요한 프로그램

### 3.1 Interactive Brokers Gateway/TWS
Linux 버전 다운로드 및 설치:
```bash
# IB Gateway 다운로드
wget https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh

# 실행 권한 부여 및 설치
chmod +x ibgateway-latest-standalone-linux-x64.sh
./ibgateway-latest-standalone-linux-x64.sh
```

### 3.2 데이터베이스 설정

#### PostgreSQL 서버 설치 (필요시)
```bash
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### 데이터베이스 마이그레이션
```bash
cd migration/sql
./run_export.sh [database_name] [host] [port] [username]
```

### 3.3 Docker Compose 환경 실행
```bash
cd docker/compose

# 개발 환경
docker compose -f docker-compose.dev.yml up -d

# 프로덕션 환경
docker compose -f docker-compose.yml up -d

# 전체 스택 (모니터링 포함)
docker compose -f docker-compose.full.yml up -d
```

## 4. 환경 변수 설정

### .env 파일 생성
각 프로젝트 디렉토리에 `.env` 파일 생성:

```bash
# trade_dashboard/.env
DATABASE_URL=postgresql://trade_user:trade_pass@localhost:5432/trade_db
REDIS_URL=redis://localhost:6379
IB_HOST=localhost
IB_PORT=7497
IB_CLIENT_ID=1

# trade_frontend/.env
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000

# docker/compose/.env
DB_PASSWORD=trade_pass
IB_HOST=localhost
IB_PORT=7497
ENVIRONMENT=production
```

## 5. 서비스 시작 순서

1. **데이터베이스 시작**
   ```bash
   docker compose up -d db redis
   ```

2. **IB Gateway 시작**
   ```bash
   # GUI 환경에서 실행하거나 IBC를 사용하여 자동화
   ```

3. **백엔드 서비스 시작**
   ```bash
   # Python 서비스
   cd trade_dashboard
   source venv/bin/activate
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   
   # Java 배치
   cd trade_batch
   java -jar target/trade_batch-0.0.1-SNAPSHOT.jar
   ```

4. **프론트엔드 시작**
   ```bash
   cd trade_frontend
   npm run dev  # 개발 모드
   npm run build && npm run preview  # 프로덕션 모드
   ```

## 6. 시스템 서비스 등록 (선택사항)

### systemd 서비스 파일 예시
```bash
# /etc/systemd/system/trade-dashboard.service
[Unit]
Description=Trade Dashboard API
After=network.target postgresql.service redis.service

[Service]
Type=simple
User=trade
WorkingDirectory=/opt/trade/trade_dashboard
Environment="PATH=/opt/trade/trade_dashboard/venv/bin"
ExecStart=/opt/trade/trade_dashboard/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## 7. 문제 해결

### 권한 문제
```bash
# Docker 권한
sudo usermod -aG docker $USER
newgrp docker

# 파일 권한
chmod +x *.sh
```

### 포트 충돌
```bash
# 사용 중인 포트 확인
sudo netstat -tlnp | grep -E ':(5432|6379|8000|3000)'
```

### 로그 확인
```bash
# Docker 로그
docker compose logs -f [service_name]

# 시스템 로그
journalctl -u trade-dashboard -f
```

## 8. 백업 및 복구

### 데이터베이스 백업
```bash
pg_dump -h localhost -U trade_user -d trade_db > backup_$(date +%Y%m%d).sql
```

### 설정 파일 백업
```bash
tar -czf config_backup_$(date +%Y%m%d).tar.gz \
  trade_dashboard/.env \
  trade_frontend/.env \
  docker/compose/.env
```

## 9. 모니터링

### 시스템 리소스 모니터링
```bash
htop  # CPU, 메모리 사용량
iotop  # 디스크 I/O
iftop  # 네트워크 트래픽
```

### Docker 모니터링
```bash
docker stats  # 컨테이너 리소스 사용량
docker compose ps  # 서비스 상태
```

## 10. 보안 고려사항

1. **방화벽 설정**
   ```bash
   sudo ufw allow 22/tcp  # SSH
   sudo ufw allow 80/tcp  # HTTP
   sudo ufw allow 443/tcp  # HTTPS
   sudo ufw enable
   ```

2. **환경 변수 보호**
   - `.env` 파일은 절대 Git에 커밋하지 않음
   - 프로덕션 환경에서는 환경 변수를 안전하게 관리

3. **SSL 인증서 설정**
   - Let's Encrypt 사용 권장
   - Nginx를 통한 HTTPS 설정

## 마이그레이션 체크리스트

- [ ] 시스템 패키지 설치 완료
- [ ] Python 가상환경 생성 및 패키지 설치
- [ ] Node.js 패키지 설치
- [ ] Java 프로젝트 빌드
- [ ] IB Gateway 설치 및 설정
- [ ] 데이터베이스 마이그레이션
- [ ] Docker 환경 테스트
- [ ] 환경 변수 설정
- [ ] 서비스 정상 작동 확인
- [ ] 백업 절차 수립
- [ ] 모니터링 설정
- [ ] 보안 설정 완료