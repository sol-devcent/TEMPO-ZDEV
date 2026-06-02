
PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  LOOP WITH CONTROL reverse.
    MODULE fill_table_control.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL reverse.
    MODULE read_table_control.
  ENDLOOP.
  MODULE user_command_0100.
