PROCESS BEFORE OUTPUT.

  MODULE status_1500.

  LOOP AT t_scrsplit WITH CONTROL ctrl_1500
                       CURSOR ctrl_1500-current_line.

    MODULE display_billing_split.

  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit_screen AT EXIT-COMMAND.

  LOOP AT t_scrsplit.
    CHAIN.

      MODULE check_billing_split.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command_1500.
