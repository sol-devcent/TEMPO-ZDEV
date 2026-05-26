
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_201.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_201.
    CHAIN.
      FIELD gs_suppl-nou.
      FIELD gs_suppl-description.
      FIELD gs_suppl-value.
    MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.
  FIELD gv_lifnr  MODULE f_supplier_list.
