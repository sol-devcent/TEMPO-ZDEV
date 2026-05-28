
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP AT gt_detl INTO gs_detl
                      CURSOR c
                      FROM n1 TO n2.
    MODULE generate_table.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP.
    MODULE modify_table.
  ENDLOOP.

  MODULE pai.
  MODULE user_command.

PROCESS ON VALUE-REQUEST.
  FIELD gs_head-stktyp MODULE f4stktyp.
