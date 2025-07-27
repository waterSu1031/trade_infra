# Ubuntu Desktop AI 학습 환경 소프트웨어 목록

## 1. 시스템 및 개발 도구

### 필수 시스템 패키지
- **build-essential**: C/C++ 컴파일러 및 개발 도구
- **cmake**: 크로스 플랫폼 빌드 시스템
- **git**: 버전 관리 시스템
- **curl, wget**: 파일 다운로드 도구
- **vim**: 텍스트 에디터
- **tmux**: 터미널 멀티플렉서 (원격 세션 유지)

### Python 환경
- **python3**: Python 3.x
- **python3-pip**: Python 패키지 관리자
- **python3-venv**: 가상 환경 도구
- **jupyterlab**: 대화형 개발 환경

## 2. AI/ML 프레임워크

### 핵심 프레임워크
- **TensorFlow**: Google의 딥러닝 프레임워크
  - CPU 버전: `pip install tensorflow`
  - GPU 버전: `pip install tensorflow[and-cuda]`
  
- **PyTorch**: Facebook의 딥러닝 프레임워크
  - CUDA 11.8: `pip install torch --index-url https://download.pytorch.org/whl/cu118`
  - CPU: `pip install torch --index-url https://download.pytorch.org/whl/cpu`

### AI 도구 및 라이브러리
- **transformers**: Hugging Face의 사전 학습 모델 라이브러리
- **langchain**: LLM 애플리케이션 개발 프레임워크
- **openai**: OpenAI API 클라이언트
- **gradio**: ML 모델 웹 인터페이스 생성
- **streamlit**: 데이터 앱 생성 도구

### 데이터 과학 도구
- **numpy**: 수치 연산 라이브러리
- **pandas**: 데이터 분석 라이브러리
- **matplotlib**: 시각화 라이브러리
- **scikit-learn**: 전통적 ML 알고리즘

## 3. GPU 및 CUDA 환경

### NVIDIA 드라이버
- **nvidia-driver-535**: 최신 안정 드라이버
- **cuda-toolkit**: CUDA 개발 도구
- **cudnn**: 딥러닝 가속 라이브러리

### GPU 모니터링
- **nvidia-smi**: NVIDIA GPU 상태 모니터
- **nvtop**: GPU 프로세스 모니터 (htop의 GPU 버전)

## 4. 컨테이너 및 가상화

### Docker
- **docker-ce**: Docker 커뮤니티 에디션
- **docker-compose**: 멀티 컨테이너 관리
- **nvidia-docker2**: GPU 지원 Docker (NVIDIA GPU 필요)

## 5. 원격 접속 도구

### SSH 및 원격 개발
- **openssh-server**: SSH 서버
- **vs-code-server**: VS Code 원격 개발 서버

### 원격 데스크톱 (선택사항)
- **tightvncserver**: VNC 서버
- **xrdp**: Windows 원격 데스크톱 프로토콜 지원

## 6. 시스템 모니터링

### 성능 모니터링
- **htop**: 향상된 프로세스 뷰어
- **btop**: 더 현대적인 시스템 모니터
- **iotop**: 디스크 I/O 모니터
- **nethogs**: 네트워크 트래픽 모니터

## 7. 추가 유틸리티

### 네트워크 도구
- **net-tools**: ifconfig 등 기본 네트워크 도구
- **ufw**: 방화벽 관리 도구

### 파일 시스템
- **ncdu**: 디스크 사용량 분석기
- **tree**: 디렉토리 구조 시각화

## 8. 설치 우선순위

### 1단계 (필수)
1. 시스템 업데이트
2. Python 환경
3. Docker
4. SSH 서버

### 2단계 (AI 개발)
1. NVIDIA 드라이버 (GPU 있는 경우)
2. TensorFlow/PyTorch
3. Jupyter Lab

### 3단계 (편의 도구)
1. 시스템 모니터링 도구
2. VS Code Server
3. 원격 데스크톱 (필요시)

## 9. 포트 설정

기본 사용 포트:
- **22**: SSH
- **8888**: Jupyter Notebook
- **8080**: 웹 애플리케이션
- **5900**: VNC
- **3389**: RDP (xrdp)

## 10. 주의사항

1. **GPU 메모리**: AI 모델 학습 시 GPU 메모리 모니터링 필수
2. **디스크 공간**: 모델과 데이터셋으로 인한 대용량 스토리지 필요
3. **냉각**: GPU 집약적 작업 시 충분한 냉각 필요
4. **전원**: 안정적인 전원 공급 필요 (UPS 권장)