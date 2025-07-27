# PostgreSQL 테이블 구조 마이그레이션

이 디렉토리는 PostgreSQL 데이터베이스의 테이블 구조를 추출하고 마이그레이션하기 위한 SQL 스크립트를 포함합니다.

## 파일 설명

### 1. export_table_structure.sql
PostgreSQL 시스템 카탈로그를 쿼리하여 다음 정보를 추출하는 SQL 스크립트:
- CREATE TABLE 문
- PRIMARY KEY 제약조건
- FOREIGN KEY 제약조건
- UNIQUE 제약조건
- CHECK 제약조건
- 인덱스
- 시퀀스
- 뷰
- 함수/프로시저
- 트리거

### 2. run_export.sh
테이블 구조를 자동으로 추출하는 쉘 스크립트:
- 전체 스키마 덤프 (데이터 제외)
- 테이블별 개별 SQL 파일 생성
- 상세 구조 정보 추출
- 테이블 요약 정보 생성
- 테이블 의존성 정보 추출

## 사용 방법

### 방법 1: SQL 직접 실행
```bash
psql -h localhost -U postgres -d your_database -f export_table_structure.sql > table_structure.txt
```

### 방법 2: 자동화 스크립트 사용
```bash
./run_export.sh [database_name] [host] [port] [username]
```

예시:
```bash
./run_export.sh mydb localhost 5432 postgres
```

## 출력 결과

`run_export.sh` 실행 시 `exported_structures` 디렉토리에 다음 파일들이 생성됩니다:

1. **full_schema_YYYYMMDD_HHMMSS.sql**: 전체 데이터베이스 스키마
2. **tables/[schema]/[table].sql**: 각 테이블별 개별 SQL 파일
3. **detailed_structure_YYYYMMDD_HHMMSS.txt**: 상세 구조 정보
4. **table_summary_YYYYMMDD_HHMMSS.txt**: 테이블 크기 및 컬럼 수 요약
5. **table_dependencies_YYYYMMDD_HHMMSS.txt**: 외래 키 의존성 정보

## 마이그레이션 시 주의사항

1. 추출된 SQL은 PostgreSQL 전용 구문을 포함할 수 있으므로 다른 데이터베이스로 마이그레이션 시 수정이 필요할 수 있습니다.
2. 권한(GRANT/REVOKE) 정보는 포함되지 않으므로 별도로 관리해야 합니다.
3. 데이터는 포함되지 않으므로 필요시 별도로 백업해야 합니다.