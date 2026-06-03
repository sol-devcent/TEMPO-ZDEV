
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP AT gt_operation INTO gs_operation
                       CURSOR c2
                       FROM n3 TO n4.
    MODULE generate_table.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP.
    MODULE modify_table.
  ENDLOOP.

  MODULE user_command.
