
PROCESS BEFORE OUTPUT.

  MODULE status_1300.

  MODULE display_header.

  LOOP AT t_vbrkscr WITH CONTROL ctrl_1300
                       CURSOR ctrl_1300-current_line.

    MODULE display_billing.

  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit_screen AT EXIT-COMMAND.

  LOOP AT t_vbrkscr.
    CHAIN.

***added for Tempo --- FAKDAT can be changed from screen
      FIELD t_vbrkscr-fakdat MODULE m_check_fakdat.
***end of addition

      MODULE check_billing.
    ENDCHAIN.

    FIELD t_vbrkscr-vbeln MODULE display_detail AT CURSOR-SELECTION.

  ENDLOOP.

***added by Rahmadi
  CHAIN.
    FIELD: r_act5,
           d_petugas_e,
           d_jabat_e.

    MODULE m_check_custom_field.
  ENDCHAIN.
***end of addition

  MODULE user_command_1300.

PROCESS ON HELP-REQUEST.
  FIELD t_vbrkscr-tax  MODULE m_help_request_tax.

