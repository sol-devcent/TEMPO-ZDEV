
PROCESS BEFORE OUTPUT.

  MODULE status_7000.

PROCESS AFTER INPUT.

  MODULE user_command_7000e AT EXIT-COMMAND.

  CHAIN.
    FIELD:
***modified by Rahmadi
*          t_sel-vkorg,
*          t_sel-gsber,
          t_sel-bukrs,
          t_sel-brnch,
***end of modification
          t_sel-masa.

    MODULE user_command_7000.
  ENDCHAIN.

