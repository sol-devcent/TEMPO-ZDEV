
PROCESS BEFORE OUTPUT.
  MODULE status_9004.
  LOOP WITH CONTROL manhk.
    MODULE fill_table_control_manhk.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL manhk.
    MODULE read_table_control_manhk.
  ENDLOOP.
  MODULE user_command_9004.
