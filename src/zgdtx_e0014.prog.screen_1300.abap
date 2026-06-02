
PROCESS BEFORE OUTPUT.

  LOOP AT t_vbrkscr WITH CONTROL ctrl_1300
                       CURSOR ctrl_1300-current_line.

    MODULE display_billing.

  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit_screen AT EXIT-COMMAND.

  LOOP AT t_vbrkscr.
    CHAIN.

      MODULE check_billing.

    ENDCHAIN.
  ENDLOOP.

  MODULE display_detail AT CURSOR-SELECTION.

  MODULE user_command_1300.
