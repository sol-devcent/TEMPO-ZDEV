
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP AT gt_operation INTO gs_operation CURSOR c
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
