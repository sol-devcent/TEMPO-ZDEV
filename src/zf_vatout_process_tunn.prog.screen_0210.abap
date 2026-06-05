
PROCESS BEFORE OUTPUT.
  MODULE status_0210.
  LOOP WITH CONTROL input.
    MODULE fill_table_control.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL input.
    MODULE read_table_control.
  ENDLOOP.
  MODULE user_command_0210.
