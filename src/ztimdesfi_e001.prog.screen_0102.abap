PROCESS BEFORE OUTPUT.
  MODULE status.
  MODULE pbo.
  LOOP WITH CONTROL tc_cust.
    MODULE fill_table_control.
  ENDLOOP.

  LOOP WITH CONTROL tc_main.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  LOOP WITH CONTROL tc_cust.
    CHAIN.
      FIELD gs_cust-kunnr.
      FIELD gs_cust-name1.
      FIELD gs_cust-kzwi5.
      FIELD gs_cust-dmbtr.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  LOOP WITH CONTROL tc_main.
    CHAIN.
      FIELD gs_out-icon.
      FIELD gs_out-kunnr.
      FIELD gs_out-vbeva.
      FIELD gs_out-kzwi5.
      FIELD gs_out-dmbtr.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.
  MODULE pai.
  MODULE user_command.
