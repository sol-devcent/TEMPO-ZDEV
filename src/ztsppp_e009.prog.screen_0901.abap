
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP AT gt_others INTO gs_others CURSOR c11
                                   FROM n11 TO n21.
    MODULE generate_table.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  CHAIN.
    FIELD : gs_head-aufnr.
    MODULE validate_aufnr.
  ENDCHAIN.

  MODULE pai.

  LOOP.
    MODULE modify_table.
  ENDLOOP.

  MODULE user_command.

*PROCESS ON VALUE-REQUEST.
*  FIELD gs_head-vornr MODULE m_value_vornr.
