SET TERMOUT ON
SET SERVEROUTPUT ON
DECLARE
    CURSOR cur_invalid_objects IS
      SELECT object_name, object_type FROM user_objects
      WHERE object_type IN ('PROCEDURE','FUNCTION','TRIGGER','SYNONYM','VIEW',
                            'MATERIALIZED VIEW','PACKAGE','PACKAGE BODY')
        AND status = 'INVALID';
    rec_columns cur_invalid_objects%ROWTYPE;
    err_status  NUMBER;
BEGIN
    dbms_output.enable(10000);
    OPEN cur_invalid_objects;
    LOOP
        FETCH cur_invalid_objects INTO rec_columns;
        EXIT WHEN cur_invalid_objects%NOTFOUND;
        BEGIN
            IF rec_columns.object_type IN ('VIEW','SYNONYM','MATERIALIZED VIEW','PACKAGE') THEN
                dbms_output.put_line('Recompiling ' || rec_columns.object_type || '  ' || rec_columns.object_name);
                EXECUTE IMMEDIATE 'ALTER ' || rec_columns.object_type || ' "' || rec_columns.object_name || '" COMPILE';
            ELSIF rec_columns.object_type = 'PACKAGE BODY' THEN
                dbms_output.put_line('Recompiling ' || rec_columns.object_type || '  ' || rec_columns.object_name);
                EXECUTE IMMEDIATE 'ALTER PACKAGE "' || rec_columns.object_name || '" COMPILE BODY';
            ELSE
                dbms_output.put_line('Recompiling ' || rec_columns.object_type || '  ' || rec_columns.object_name);
                dbms_ddl.alter_compile(rec_columns.object_type, NULL, rec_columns.object_name);
            END IF;
        EXCEPTION WHEN OTHERS THEN
            err_status := SQLCODE;
            dbms_output.put_line('Recompilation failed: ' || SQLERRM(err_status));
        END;
    END LOOP;
    CLOSE cur_invalid_objects;
END;
/
