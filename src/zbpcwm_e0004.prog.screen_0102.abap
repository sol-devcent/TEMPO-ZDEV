
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  MODULE validate_data.

  MODULE tap_display.

  LOOP AT gt_mara INTO gs_mara
                  CURSOR c
                  FROM m1 TO m2.
    MODULE generate_table.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP.
    MODULE modify_table.
  ENDLOOP.

  FIELD ok_code MODULE user_command.
