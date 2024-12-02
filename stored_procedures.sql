BEGIN
    -- Drop sequence if exists
    FOR seq IN (SELECT sequence_name FROM user_sequences WHERE sequence_name = 'CUSTOMERS_SEQ') 
    LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || seq.sequence_name;
    END LOOP;
    
    -- Drop procedure if exists
    FOR proc IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE' AND object_name = 'REGISTER_CUSTOMER') 
    LOOP
        EXECUTE IMMEDIATE 'DROP PROCEDURE ' || proc.object_name;
    END LOOP;
    
    -- Drop function if exists
   FOR func IN (SELECT object_name FROM user_objects WHERE object_type = 'FUNCTION' AND object_name = 'x') 
   LOOP
       EXECUTE IMMEDIATE 'DROP FUNCTION ' || func.object_name;
   END LOOP;

 -- Drop synonym if exists
     FOR syn IN (SELECT synonym_name FROM all_synonyms WHERE synonym_name = 'REGISTER_CUSTOMER' AND owner = 'PUBLIC') 
    LOOP
        EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || syn.synonym_name;
    END LOOP;
      
  -- Attempt to revoke from public silently
    BEGIN
        EXECUTE IMMEDIATE 'REVOKE EXECUTE ON register_customer FROM PUBLIC';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;


END;
/


--- First create the sequence
CREATE SEQUENCE customers_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE PROCEDURE hydro_admin.register_customer (
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_address IN VARCHAR2
)
AUTHID CURRENT_USER
IS
BEGIN
    INSERT INTO hydro_admin.customers (
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        address
    ) VALUES (
        hydro_admin.customers_seq.NEXTVAL,
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_address
    );
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Customer registered: ' || p_first_name || ' ' || p_last_name);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Grant only to sales_manager_role
GRANT EXECUTE ON hydro_admin.register_customer TO sales_manager_role;
GRANT SELECT ON hydro_admin.customers_seq TO sales_manager_role;

-- Create new public synonym
CREATE OR REPLACE PUBLIC SYNONYM register_customer FOR hydro_admin.register_customer;
