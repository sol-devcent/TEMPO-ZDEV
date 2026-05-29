
PROCESS BEFORE OUTPUT.
  MODULE status.

  LOOP AT   gt_out
       INTO gs_out
       WITH CONTROL tc_out
       CURSOR tc_out-current_line.
    MODULE fill_table_control.
    MODULE disable.
  ENDLOOP.

  MODULE cursor.

PROCESS AFTER INPUT.
  LOOP AT gt_out.
    CHAIN.
      FIELD gs_out-vbeln.
      FIELD gs_out-kunnr.
      FIELD gs_out-name1.
      FIELD gs_out-tknum.
      FIELD gs_out-crdat.
      FIELD gs_out-crtim.
      FIELD gs_out-crexrsdesc.
      FIELD gs_out-zreason.
    ENDCHAIN.

    MODULE read_table_control.
  ENDLOOP.

  MODULE cursor.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD gs_out-crexrsdesc MODULE value-field.
  FIELD gs_out-zreason MODULE value_reason.
