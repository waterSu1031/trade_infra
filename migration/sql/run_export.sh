#!/bin/bash

# PostgreSQL 테이블 구조 추출 스크립트
# 사용법: ./run_export.sh [database_name] [host] [port] [username]

# 기본값 설정
DATABASE="${1:-your_database_name}"
HOST="${2:-localhost}"
PORT="${3:-5432}"
USERNAME="${4:-postgres}"
OUTPUT_DIR="./exported_structures"

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR"

# 타임스탬프 생성
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "PostgreSQL 테이블 구조 추출 시작..."
echo "데이터베이스: $DATABASE"
echo "호스트: $HOST:$PORT"
echo "사용자: $USERNAME"
echo "출력 디렉토리: $OUTPUT_DIR"

# 1. 전체 스키마 덤프 (데이터 제외)
echo "전체 스키마 덤프 생성 중..."
pg_dump -h "$HOST" -p "$PORT" -U "$USERNAME" -d "$DATABASE" \
    --schema-only \
    --no-owner \
    --no-privileges \
    --no-tablespaces \
    --no-unlogged-table-data \
    -f "$OUTPUT_DIR/full_schema_${TIMESTAMP}.sql"

# 2. 테이블별 개별 파일 생성
echo "테이블별 개별 파일 생성 중..."
TABLES=$(psql -h "$HOST" -p "$PORT" -U "$USERNAME" -d "$DATABASE" -t -c "
    SELECT schemaname || '.' || tablename 
    FROM pg_tables 
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY schemaname, tablename;
")

for TABLE in $TABLES; do
    SCHEMA=$(echo $TABLE | cut -d'.' -f1)
    TABLENAME=$(echo $TABLE | cut -d'.' -f2)
    
    # 스키마별 디렉토리 생성
    mkdir -p "$OUTPUT_DIR/tables/$SCHEMA"
    
    echo "  - $TABLE 추출 중..."
    pg_dump -h "$HOST" -p "$PORT" -U "$USERNAME" -d "$DATABASE" \
        --schema-only \
        --no-owner \
        --no-privileges \
        --table="$TABLE" \
        -f "$OUTPUT_DIR/tables/$SCHEMA/${TABLENAME}.sql"
done

# 3. 커스텀 SQL 쿼리 실행
echo "상세 구조 정보 추출 중..."
psql -h "$HOST" -p "$PORT" -U "$USERNAME" -d "$DATABASE" \
    -f export_table_structure.sql \
    -o "$OUTPUT_DIR/detailed_structure_${TIMESTAMP}.txt"

# 4. 테이블 정보 요약 생성
echo "테이블 정보 요약 생성 중..."
psql -h "$HOST" -p "$PORT" -U "$USERNAME" -d "$DATABASE" -t -c "
    SELECT 
        schemaname || '.' || tablename AS table_name,
        pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
        (SELECT COUNT(*) FROM information_schema.columns 
         WHERE table_schema = schemaname AND table_name = tablename) AS column_count
    FROM pg_tables
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
" > "$OUTPUT_DIR/table_summary_${TIMESTAMP}.txt"

# 5. 의존성 정보 추출
echo "테이블 의존성 정보 추출 중..."
psql -h "$HOST" -p "$PORT" -U "$USERNAME" -d "$DATABASE" -t -c "
    WITH RECURSIVE dep_tree AS (
        SELECT 
            c.conname AS constraint_name,
            n1.nspname || '.' || c1.relname AS child_table,
            n2.nspname || '.' || c2.relname AS parent_table,
            1 AS level
        FROM pg_constraint c
        JOIN pg_class c1 ON c.conrelid = c1.oid
        JOIN pg_namespace n1 ON c1.relnamespace = n1.oid
        JOIN pg_class c2 ON c.confrelid = c2.oid
        JOIN pg_namespace n2 ON c2.relnamespace = n2.oid
        WHERE c.contype = 'f'
        AND n1.nspname NOT IN ('pg_catalog', 'information_schema')
    )
    SELECT * FROM dep_tree ORDER BY level, child_table;
" > "$OUTPUT_DIR/table_dependencies_${TIMESTAMP}.txt"

echo "추출 완료!"
echo "결과 파일들이 $OUTPUT_DIR 디렉토리에 저장되었습니다."