-- PostgreSQL 테이블 구조 추출 SQL
-- 이 스크립트는 현재 데이터베이스의 모든 테이블 구조를 추출합니다.

-- 1. 모든 테이블의 CREATE TABLE 문 생성
SELECT 
    'CREATE TABLE ' || schemaname || '.' || tablename || ' (' || E'\n' ||
    string_agg(
        '    ' || column_name || ' ' || 
        data_type || 
        CASE 
            WHEN character_maximum_length IS NOT NULL 
            THEN '(' || character_maximum_length || ')'
            WHEN numeric_precision IS NOT NULL 
            THEN '(' || numeric_precision || 
                CASE 
                    WHEN numeric_scale IS NOT NULL 
                    THEN ',' || numeric_scale 
                    ELSE '' 
                END || ')'
            ELSE ''
        END ||
        CASE 
            WHEN is_nullable = 'NO' 
            THEN ' NOT NULL'
            ELSE ''
        END ||
        CASE 
            WHEN column_default IS NOT NULL 
            THEN ' DEFAULT ' || column_default
            ELSE ''
        END,
        E',\n'
        ORDER BY ordinal_position
    ) || E'\n);' AS create_table_statement
FROM 
    information_schema.columns c
    JOIN pg_tables t ON c.table_name = t.tablename 
        AND c.table_schema = t.schemaname
WHERE 
    t.schemaname NOT IN ('pg_catalog', 'information_schema')
GROUP BY 
    schemaname, tablename
ORDER BY 
    schemaname, tablename;

-- 2. 모든 PRIMARY KEY 제약조건 추출
SELECT 
    'ALTER TABLE ' || n.nspname || '.' || c.relname || 
    ' ADD CONSTRAINT ' || con.conname || 
    ' PRIMARY KEY (' || 
    string_agg(a.attname, ', ' ORDER BY array_position(con.conkey, a.attnum)) || 
    ');' AS primary_key_statement
FROM 
    pg_constraint con
    JOIN pg_class c ON con.conrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY(con.conkey)
WHERE 
    con.contype = 'p'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
GROUP BY 
    n.nspname, c.relname, con.conname
ORDER BY 
    n.nspname, c.relname;

-- 3. 모든 FOREIGN KEY 제약조건 추출
SELECT 
    'ALTER TABLE ' || n.nspname || '.' || c.relname || 
    ' ADD CONSTRAINT ' || con.conname || 
    ' FOREIGN KEY (' || 
    string_agg(a.attname, ', ' ORDER BY array_position(con.conkey, a.attnum)) || 
    ') REFERENCES ' || 
    fn.nspname || '.' || fc.relname || ' (' ||
    string_agg(fa.attname, ', ' ORDER BY array_position(con.confkey, fa.attnum)) || 
    ')' ||
    CASE 
        WHEN con.confupdtype = 'c' THEN ' ON UPDATE CASCADE'
        WHEN con.confupdtype = 'r' THEN ' ON UPDATE RESTRICT'
        WHEN con.confupdtype = 'n' THEN ' ON UPDATE NO ACTION'
        WHEN con.confupdtype = 's' THEN ' ON UPDATE SET NULL'
        WHEN con.confupdtype = 'd' THEN ' ON UPDATE SET DEFAULT'
        ELSE ''
    END ||
    CASE 
        WHEN con.confdeltype = 'c' THEN ' ON DELETE CASCADE'
        WHEN con.confdeltype = 'r' THEN ' ON DELETE RESTRICT'
        WHEN con.confdeltype = 'n' THEN ' ON DELETE NO ACTION'
        WHEN con.confdeltype = 's' THEN ' ON DELETE SET NULL'
        WHEN con.confdeltype = 'd' THEN ' ON DELETE SET DEFAULT'
        ELSE ''
    END || ';' AS foreign_key_statement
FROM 
    pg_constraint con
    JOIN pg_class c ON con.conrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY(con.conkey)
    JOIN pg_class fc ON con.confrelid = fc.oid
    JOIN pg_namespace fn ON fc.relnamespace = fn.oid
    JOIN pg_attribute fa ON fa.attrelid = fc.oid AND fa.attnum = ANY(con.confkey)
WHERE 
    con.contype = 'f'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
GROUP BY 
    n.nspname, c.relname, con.conname, fn.nspname, fc.relname, 
    con.confupdtype, con.confdeltype
ORDER BY 
    n.nspname, c.relname;

-- 4. 모든 UNIQUE 제약조건 추출
SELECT 
    'ALTER TABLE ' || n.nspname || '.' || c.relname || 
    ' ADD CONSTRAINT ' || con.conname || 
    ' UNIQUE (' || 
    string_agg(a.attname, ', ' ORDER BY array_position(con.conkey, a.attnum)) || 
    ');' AS unique_constraint_statement
FROM 
    pg_constraint con
    JOIN pg_class c ON con.conrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY(con.conkey)
WHERE 
    con.contype = 'u'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
GROUP BY 
    n.nspname, c.relname, con.conname
ORDER BY 
    n.nspname, c.relname;

-- 5. 모든 CHECK 제약조건 추출
SELECT 
    'ALTER TABLE ' || n.nspname || '.' || c.relname || 
    ' ADD CONSTRAINT ' || con.conname || 
    ' CHECK (' || pg_get_constraintdef(con.oid, true) || ');' AS check_constraint_statement
FROM 
    pg_constraint con
    JOIN pg_class c ON con.conrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE 
    con.contype = 'c'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 
    n.nspname, c.relname, con.conname;

-- 6. 모든 인덱스 추출 (PRIMARY KEY 인덱스 제외)
SELECT 
    pg_get_indexdef(i.oid) || ';' AS index_statement
FROM 
    pg_index idx
    JOIN pg_class i ON idx.indexrelid = i.oid
    JOIN pg_class t ON idx.indrelid = t.oid
    JOIN pg_namespace n ON t.relnamespace = n.oid
WHERE 
    NOT idx.indisprimary
    AND NOT idx.indisunique
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 
    n.nspname, t.relname, i.relname;

-- 7. 모든 시퀀스 추출
SELECT 
    'CREATE SEQUENCE ' || sequence_schema || '.' || sequence_name || 
    ' START WITH ' || start_value ||
    ' INCREMENT BY ' || increment ||
    CASE 
        WHEN minimum_value IS NOT NULL 
        THEN ' MINVALUE ' || minimum_value 
        ELSE ' NO MINVALUE' 
    END ||
    CASE 
        WHEN maximum_value IS NOT NULL 
        THEN ' MAXVALUE ' || maximum_value 
        ELSE ' NO MAXVALUE' 
    END ||
    CASE 
        WHEN cycle_option = 'YES' 
        THEN ' CYCLE' 
        ELSE ' NO CYCLE' 
    END || ';' AS sequence_statement
FROM 
    information_schema.sequences
WHERE 
    sequence_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY 
    sequence_schema, sequence_name;

-- 8. 모든 뷰 추출
SELECT 
    'CREATE VIEW ' || schemaname || '.' || viewname || ' AS ' || E'\n' || 
    definition AS view_statement
FROM 
    pg_views
WHERE 
    schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 
    schemaname, viewname;

-- 9. 모든 함수/프로시저 추출
SELECT 
    pg_get_functiondef(p.oid) || ';' AS function_statement
FROM 
    pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    AND p.prokind IN ('f', 'p') -- f: function, p: procedure
ORDER BY 
    n.nspname, p.proname;

-- 10. 모든 트리거 추출
SELECT 
    'CREATE TRIGGER ' || trigger_name || E'\n' ||
    action_timing || ' ' || event_manipulation || E'\n' ||
    'ON ' || event_object_schema || '.' || event_object_table || E'\n' ||
    'FOR EACH ' || action_orientation || E'\n' ||
    CASE 
        WHEN action_condition IS NOT NULL 
        THEN 'WHEN (' || action_condition || ')' || E'\n'
        ELSE ''
    END ||
    'EXECUTE FUNCTION ' || action_statement || ';' AS trigger_statement
FROM 
    information_schema.triggers
WHERE 
    trigger_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY 
    trigger_schema, trigger_name;