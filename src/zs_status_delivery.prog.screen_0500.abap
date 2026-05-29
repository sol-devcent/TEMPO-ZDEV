
PROCESS BEFORE OUTPUT.
  MODULE status_0500.

  LOOP AT   gt_dn
       INTO wa_dn
       WITH CONTROL tc_dn
       CURSOR tc_dn-current_line.
    MODULE fill_table_control.
  ENDLOOP.

  MODULE cursor.

PROCESS AFTER INPUT.
  LOOP AT gt_dn.
    CHAIN.
      FIELD wa_dn-check.
      FIELD wa_dn-vbeln.
    ENDCHAIN.

    MODULE read_table_control.
  ENDLOOP.

  MODULE cursor.

  MODULE user_command_0500.
