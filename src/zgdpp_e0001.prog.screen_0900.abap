
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_order.
    MODULE fill_tc_order.
  ENDLOOP.

  LOOP WITH CONTROL tc_material.
    MODULE fill_tc_material.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP WITH CONTROL tc_order.
    MODULE read_tc_order.
  ENDLOOP.

  LOOP WITH CONTROL tc_material.
    CHAIN.
      FIELD gs_material-icon.
      FIELD gs_material-matnr.
      FIELD gs_material-bdmng.

      MODULE read_tc_material.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command.
