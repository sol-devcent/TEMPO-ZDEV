
PROCESS BEFORE OUTPUT.
  MODULE status_9002.
  LOOP WITH CONTROL mantax.
    MODULE fill_table_control_mantax.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL mantax.
    MODULE read_table_control_mantax.
  ENDLOOP.
  MODULE user_command_9002.
