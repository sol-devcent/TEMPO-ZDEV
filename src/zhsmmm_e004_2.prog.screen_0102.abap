
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_vendor.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_vendor.
    CHAIN.
      FIELD gs_vendor-mark.
      FIELD gs_vendor-revis.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.
