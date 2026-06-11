
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE validate_data.

  LOOP AT gt_ltap INTO gs_ltap CURSOR tap_index.
    MODULE tap_display.
  ENDLOOP.

  MODULE pbo.

PROCESS AFTER INPUT.
  MODULE validate_data.

  MODULE exit_commands AT EXIT-COMMAND.

  LOOP .
    MODULE modify_data.
  ENDLOOP.

  FIELD ok_code
  MODULE user_command.
