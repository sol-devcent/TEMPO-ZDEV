
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  MODULE tap_display.

  LOOP AT gt_batch INTO gs_batch
                   CURSOR c3
                   FROM n5 TO n6.
    MODULE generate_table.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP.
    MODULE modify_table.
  ENDLOOP.

  MODULE user_command.
