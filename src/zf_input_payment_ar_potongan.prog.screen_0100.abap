
PROCESS BEFORE OUTPUT.
  MODULE status_0100.

  MODULE fill_screen.

  LOOP WITH CONTROL input.
    MODULE fill_table_control.
  ENDLOOP.

  CALL SUBSCREEN t_tabstrip_scr
  INCLUDING sy-repid gt_tabstrip-subscreen.

PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.

  CALL SUBSCREEN t_tabstrip_scr.

  LOOP WITH CONTROL input.
    MODULE read_table_control.
  ENDLOOP.

  MODULE user_command_0100.

