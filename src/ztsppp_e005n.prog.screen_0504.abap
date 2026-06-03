
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  MODULE tap_display.

  LOOP AT gt_material INTO gs_material
                       CURSOR c4
                       FROM n7 TO n8.
    MODULE generate_table.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP.
    MODULE modify_table.
  ENDLOOP.

  MODULE user_command.
