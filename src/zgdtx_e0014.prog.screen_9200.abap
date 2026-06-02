
PROCESS BEFORE OUTPUT.

  MODULE m_9200_status.

  MODULE m_9200_preparescreen.

  CALL SUBSCREEN s_9200_subscreen_header INCLUDING sy-repid '9300'.

  CALL SUBSCREEN s_9200_subscreen_tax INCLUDING sy-repid '9400'.

  LOOP AT    s_9200_table
       INTO  s_9200_table
       WITH  CONTROL s_9200_tc.

    MODULE m_9092_set_tblcntrl_visible.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE m_9200_exit AT EXIT-COMMAND.

  CALL SUBSCREEN s_9200_subscreen_header.

  CALL SUBSCREEN s_9200_subscreen_tax.

  LOOP AT    s_9200_table.
    CHAIN.
      FIELD: s_9200_table-kode.

      MODULE m_9200_read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE m_9200_user_command.


PROCESS ON HELP-REQUEST.
  FIELD s_9200_table-kode MODULE m_help_request_kode.

