
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP AT gt_others INTO gs_others CURSOR c1
                                   FROM n1 TO n2.
    MODULE generate_table.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP.
    MODULE modify_table.
  ENDLOOP.

  MODULE user_command.
