
PROCESS BEFORE OUTPUT.
  MODULE status_9005.
  LOOP WITH CONTROL mantext.
    MODULE fill_table_control_mantext.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL mantext.
    MODULE read_table_control_mantext.
  ENDLOOP.
  MODULE user_command_9005.
