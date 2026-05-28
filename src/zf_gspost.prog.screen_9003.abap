
PROCESS BEFORE OUTPUT.
  MODULE status_9003.
  LOOP WITH CONTROL manba.
    MODULE fill_table_control_manba.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL manba.
    MODULE read_table_control_manba.
  ENDLOOP.
  MODULE user_command_9003.
