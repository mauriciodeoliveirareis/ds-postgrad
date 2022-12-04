DECLARE
CURSOR emp_table_cursor IS SELECT * FROM USER_TAB_COLUMNS WHERE TABLE_NAME = 'EMP';
   v_emp_table emp_table_cursor%rowtype;
   /* or we could do v_employee employees%rowtype */
BEGIN
   DBMS_OUTPUT.PUT_LINE ('******************');
   OPEN emp_table_cursor;
   FETCH emp_table_cursor into v_emp_table;
   WHILE emp_table_cursor%found LOOP
      DBMS_OUTPUT.PUT_LINE(v_emp_table.COLUMN_NAME|| ' ' ||v_emp_table.DATA_TYPE|| ': ');
      FETCH emp_table_cursor into v_emp_table;
   END LOOP;
   CLOSE emp_table_cursor;
END;



