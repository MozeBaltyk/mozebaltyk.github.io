SET SERVEROUTPUT ON
DECLARE
    CURSOR cur_invalid_objects IS
      SELECT object_name, object_type FROM user_objects
      WHERE object_type IN ('PROCEDURE','FUNCTION','TRIGGER','SYNONYM','VIEW',
                            'MATERIALIZED VIEW','PACKAGE','PACKAGE BODY')
        AND status = 'INVALID';
    rec_columns cur_invalid_objects%ROWTYPE;
BEGIN
    dbms_output.enable(10000);
    OPEN cur_invalid_objects;
    LOOP
        FETCH cur_invalid_objects INTO rec_columns;
        EXIT WHEN cur_invalid_objects%NOTFOUND;
        dbms_output.put_line('DROP ' || rec_columns.object_type || ' ' || rec_columns.object_name);
        EXECUTE IMMEDIATE 'DROP ' || rec_columns.object_type || ' ' || rec_columns.object_name;
    END LOOP;
    CLOSE cur_invalid_objects;
END;
/
