
PROCESS BEFORE OUTPUT.
  MODULE status.

  LOOP WITH CONTROL tc_appr.
    MODULE fill_table_control.
  ENDLOOP.


PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_appr.
    CHAIN.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command.
