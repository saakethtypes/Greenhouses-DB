

CREATE OR REPLACE PROCEDURE print_schema_objects IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== HYDRO_ADMIN Schema Objects ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Print Packages and their contents
    FOR pkg_rec IN (
        SELECT DISTINCT object_name 
        FROM user_objects 
        WHERE object_type = 'PACKAGE'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? Package: ' || pkg_rec.object_name);
        
        -- Get package procedures using ALL_PROCEDURES
        FOR proc_rec IN (
            SELECT DISTINCT subprogram_id, procedure_name
            FROM all_procedures
            WHERE object_type = 'PACKAGE'
            AND object_name = pkg_rec.object_name
            AND owner = USER
            AND procedure_name IS NOT NULL
            ORDER BY subprogram_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ?? ' || proc_rec.procedure_name);
            
            -- Get arguments for this procedure
            FOR arg_rec IN (
                SELECT argument_name, data_type, position, in_out
                FROM all_arguments
                WHERE package_name = pkg_rec.object_name
                AND object_name = proc_rec.procedure_name
                AND owner = USER
                ORDER BY position
            ) LOOP
                IF arg_rec.argument_name IS NOT NULL THEN
                    DBMS_OUTPUT.PUT_LINE('      ' || RPAD(arg_rec.argument_name, 30) || 
                                       ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
                END IF;
            END LOOP;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Standalone Procedures
    DBMS_OUTPUT.PUT_LINE('=== Standalone Procedures ===');
    FOR proc_rec IN (
        SELECT object_name 
        FROM user_objects 
        WHERE object_type = 'PROCEDURE'
        AND object_name NOT LIKE 'SYS_%'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || proc_rec.object_name);
        
        -- Get procedure arguments
        FOR arg_rec IN (
            SELECT argument_name, data_type, position, in_out
            FROM all_arguments
            WHERE object_name = proc_rec.object_name
            AND package_name IS NULL
            AND owner = USER
            ORDER BY position
        ) LOOP
            IF arg_rec.argument_name IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('    ' || RPAD(arg_rec.argument_name, 30) || 
                                   ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Functions
    DBMS_OUTPUT.PUT_LINE('=== Functions ===');
    FOR func_rec IN (
        SELECT object_name 
        FROM user_objects 
        WHERE object_type = 'FUNCTION'
        AND object_name NOT LIKE 'SYS_%'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || func_rec.object_name);
        
        -- Get function arguments
        FOR arg_rec IN (
            SELECT argument_name, data_type, position, in_out
            FROM all_arguments
            WHERE object_name = func_rec.object_name
            AND package_name IS NULL
            AND owner = USER
            ORDER BY position
        ) LOOP
            IF arg_rec.argument_name IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('    ' || RPAD(arg_rec.argument_name, 30) || 
                                   ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Triggers
    DBMS_OUTPUT.PUT_LINE('=== Triggers ===');
    FOR trg_rec IN (
        SELECT trigger_name, triggering_event, table_name, status
        FROM user_triggers
        WHERE trigger_name NOT LIKE 'SYS_%'
        ORDER BY trigger_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || trg_rec.trigger_name);
        DBMS_OUTPUT.PUT_LINE('    Table: ' || trg_rec.table_name);
        DBMS_OUTPUT.PUT_LINE('    Event: ' || trg_rec.triggering_event);
        DBMS_OUTPUT.PUT_LINE('    Status: ' || trg_rec.status);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/

-- Execute the procedure
BEGIN
    print_schema_objects;
END;
/

CREATE OR REPLACE PROCEDURE cleanup_schema IS
    v_sql VARCHAR2(1000);
BEGIN
    -- First drop all triggers
    FOR r IN (SELECT trigger_name FROM user_triggers) LOOP
        v_sql := 'DROP TRIGGER ' || r.trigger_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped trigger: ' || r.trigger_name);
    END LOOP;

    -- Drop all public synonyms owned by HYDRO_ADMIN
    FOR r IN (SELECT synonym_name FROM all_synonyms 
              WHERE table_owner = 'HYDRO_ADMIN' 
              AND owner = 'PUBLIC') LOOP
        v_sql := 'DROP PUBLIC SYNONYM ' || r.synonym_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped public synonym: ' || r.synonym_name);
    END LOOP;

    -- Revoke all grants from roles
    FOR r IN (SELECT owner, table_name, grantee 
              FROM user_tab_privs
              WHERE grantee IN ('TECHNICIAN_ROLE', 'AGRONOMIST_ROLE', 'SALES_MANAGER_ROLE')) LOOP
        v_sql := 'REVOKE ALL ON ' || r.owner || '.' || r.table_name || ' FROM ' || r.grantee;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Revoked privileges on ' || r.table_name || ' from ' || r.grantee);
    END LOOP;

    -- Drop package bodies first
    FOR r IN (SELECT object_name FROM user_objects 
              WHERE object_type = 'PACKAGE BODY') LOOP
        v_sql := 'DROP PACKAGE BODY ' || r.object_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped package body: ' || r.object_name);
    END LOOP;

    -- Drop packages
    FOR r IN (SELECT object_name FROM user_objects 
              WHERE object_type = 'PACKAGE') LOOP
        v_sql := 'DROP PACKAGE ' || r.object_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped package: ' || r.object_name);
    END LOOP;

    -- Drop procedures
    FOR r IN (SELECT object_name FROM user_objects 
              WHERE object_type = 'PROCEDURE'
              AND object_name != 'CLEANUP_SCHEMA') LOOP
        v_sql := 'DROP PROCEDURE ' || r.object_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped procedure: ' || r.object_name);
    END LOOP;

    -- Drop functions
    FOR r IN (SELECT object_name FROM user_objects 
              WHERE object_type = 'FUNCTION') LOOP
        v_sql := 'DROP FUNCTION ' || r.object_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped function: ' || r.object_name);
    END LOOP;

    -- Drop sequences
    FOR r IN (SELECT sequence_name FROM user_sequences) LOOP
        v_sql := 'DROP SEQUENCE ' || r.sequence_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped sequence: ' || r.sequence_name);
    END LOOP;

    -- Drop tables (need to handle foreign key constraints)
    -- First disable all constraints
    FOR r IN (SELECT table_name, constraint_name 
              FROM user_constraints 
              WHERE constraint_type = 'R') LOOP
        v_sql := 'ALTER TABLE ' || r.table_name || ' DISABLE CONSTRAINT ' || r.constraint_name;
        EXECUTE IMMEDIATE v_sql;
    END LOOP;

    -- Now drop all tables
    FOR r IN (SELECT table_name FROM user_tables) LOOP
        v_sql := 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped table: ' || r.table_name);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Schema cleanup completed successfully');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error during cleanup: ' || SQLERRM);
        RAISE;
END cleanup_schema;
/

-- Execute the cleanup
BEGIN
    cleanup_schema;
END;
/

---- Drop the cleanup procedure itself
--DROP PROCEDURE cleanup_schema;


CREATE OR REPLACE PROCEDURE print_schema_objects IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== HYDRO_ADMIN Schema Objects ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Print Packages and their contents
    FOR pkg_rec IN (
        SELECT DISTINCT object_name 
        FROM user_objects 
        WHERE object_type = 'PACKAGE'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? Package: ' || pkg_rec.object_name);
        
        -- Get package procedures using ALL_PROCEDURES
        FOR proc_rec IN (
            SELECT DISTINCT subprogram_id, procedure_name
            FROM all_procedures
            WHERE object_type = 'PACKAGE'
            AND object_name = pkg_rec.object_name
            AND owner = USER
            AND procedure_name IS NOT NULL
            ORDER BY subprogram_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ?? ' || proc_rec.procedure_name);
            
            -- Get arguments for this procedure
            FOR arg_rec IN (
                SELECT argument_name, data_type, position, in_out
                FROM all_arguments
                WHERE package_name = pkg_rec.object_name
                AND object_name = proc_rec.procedure_name
                AND owner = USER
                ORDER BY position
            ) LOOP
                IF arg_rec.argument_name IS NOT NULL THEN
                    DBMS_OUTPUT.PUT_LINE('      ' || RPAD(arg_rec.argument_name, 30) || 
                                       ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
                END IF;
            END LOOP;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Standalone Procedures
    DBMS_OUTPUT.PUT_LINE('=== Standalone Procedures ===');
    FOR proc_rec IN (
        SELECT object_name 
        FROM user_objects 
        WHERE object_type = 'PROCEDURE'
        AND object_name NOT LIKE 'SYS_%'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || proc_rec.object_name);
        
        -- Get procedure arguments
        FOR arg_rec IN (
            SELECT argument_name, data_type, position, in_out
            FROM all_arguments
            WHERE object_name = proc_rec.object_name
            AND package_name IS NULL
            AND owner = USER
            ORDER BY position
        ) LOOP
            IF arg_rec.argument_name IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('    ' || RPAD(arg_rec.argument_name, 30) || 
                                   ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Functions
    DBMS_OUTPUT.PUT_LINE('=== Functions ===');
    FOR func_rec IN (
        SELECT object_name 
        FROM user_objects 
        WHERE object_type = 'FUNCTION'
        AND object_name NOT LIKE 'SYS_%'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || func_rec.object_name);
        
        -- Get function arguments
        FOR arg_rec IN (
            SELECT argument_name, data_type, position, in_out
            FROM all_arguments
            WHERE object_name = func_rec.object_name
            AND package_name IS NULL
            AND owner = USER
            ORDER BY position
        ) LOOP
            IF arg_rec.argument_name IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('    ' || RPAD(arg_rec.argument_name, 30) || 
                                   ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Triggers
    DBMS_OUTPUT.PUT_LINE('=== Triggers ===');
    FOR trg_rec IN (
        SELECT trigger_name, triggering_event, table_name, status
        FROM user_triggers
        WHERE trigger_name NOT LIKE 'SYS_%'
        ORDER BY trigger_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || trg_rec.trigger_name);
        DBMS_OUTPUT.PUT_LINE('    Table: ' || trg_rec.table_name);
        DBMS_OUTPUT.PUT_LINE('    Event: ' || trg_rec.triggering_event);
        DBMS_OUTPUT.PUT_LINE('    Status: ' || trg_rec.status);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/

-- Execute the procedure
BEGIN
    print_schema_objects;
END;
/
