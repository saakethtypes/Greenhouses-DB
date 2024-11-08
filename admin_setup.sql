BEGIN
   -- Drop the user if it exists
   BEGIN
      EXECUTE IMMEDIATE 'DROP USER hydro_admin CASCADE';
   EXCEPTION
      WHEN OTHERS THEN
         -- Ignore the error if the user does not exist
         IF SQLCODE != -1918 THEN  -- ORA-01918: user does not exist
            RAISE;  -- Re-raise other unexpected errors
         END IF;
   END;

   -- Create the user
   EXECUTE IMMEDIATE 'CREATE USER hydro_admin IDENTIFIED BY "NeuBoston2024#"';

   -- Grant privileges to the user
   EXECUTE IMMEDIATE 'GRANT CONNECT TO hydro_admin';
   EXECUTE IMMEDIATE 'GRANT RESOURCE TO hydro_admin';

   -- Additional privileges if required
   EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO hydro_admin';
   EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO hydro_admin';
   EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO hydro_admin';
END;
/


GRANT CONNECT TO hydro_admin;
GRANT RESOURCE TO hydro_admin;

GRANT DROP USER TO hydro_admin;
GRANT CREATE USER TO hydro_admin;
GRANT CREATE ROLE TO hydro_admin;
GRANT ALTER USER TO hydro_admin;


GRANT DROP ANY TABLE TO hydro_admin;
ALTER USER hydro_admin QUOTA UNLIMITED ON DATA;

GRANT CREATE SESSION TO hydro_admin;
GRANT CREATE SESSION TO hydro_technician;
GRANT CREATE SESSION TO hydro_agronomist;
GRANT CREATE SESSION TO hydro_sales_manager;

GRANT CREATE SESSION TO admin_role;
GRANT CREATE SESSION TO technician_role;
GRANT CREATE SESSION TO agronomist_role;
GRANT CREATE SESSION TO sales_manager_role;

GRANT CREATE USER TO hydro_admin;
GRANT DROP USER TO hydro_admin;
GRANT CREATE ROLE TO hydro_admin;
GRANT GRANT ANY ROLE TO hydro_admin;

GRANT CREATE ANY TABLE TO hydro_admin;
GRANT ALTER ANY TABLE TO hydro_admin;
GRANT DROP ANY TABLE TO hydro_admin;
GRANT SELECT ANY TABLE TO hydro_admin;
GRANT INSERT ANY TABLE TO hydro_admin;
GRANT UPDATE ANY TABLE TO hydro_admin;
GRANT DELETE ANY TABLE TO hydro_admin;
GRANT CREATE PUBLIC SYNONYM TO hydro_admin;

--drop user hydro_admin cascade;
