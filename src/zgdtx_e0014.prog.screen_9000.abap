
PROCESS BEFORE OUTPUT.

  MODULE m_9000_status.

  MODULE m_9000_preparescreen.

  CALL SUBSCREEN s_9000_subscreen_header INCLUDING sy-repid '9300'.

*  CALL SUBSCREEN s_9000_subscreen_tax    INCLUDING sy-repid '9400'.

  LOOP AT    s_9000_table
       INTO  s_9000_table
       WITH  CONTROL s_9000_tc.

    MODULE m_9092_set_tblcntrl_visible.

  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE m_9000_exit AT EXIT-COMMAND.

  CALL SUBSCREEN s_9000_subscreen_header .

*  CALL SUBSCREEN s_9000_subscreen_tax.

  LOOP AT    s_9000_table.
    CHAIN.
      FIELD: s_9000_table-nqty1,
             s_9000_table-nqty2,
             s_9000_table-nqty3.

      MODULE m_9000_read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE m_9000_check_column_qty.

  MODULE m_9000_user_command.

