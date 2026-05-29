PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_bank.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_bank.
    CHAIN.
      FIELD gs_bpvd-zbank2.
      FIELD gs_bpvd-znorek2.
      FIELD gs_bpvd-wrbtr2.
      FIELD gs_bpvd-zdesc2.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.
  FIELD gs_bpv-zbank1 MODULE f4_bank1.
  FIELD gs_bpvd-zbank2 MODULE f4_bank2.
  FIELD gs_bpv-znorek1 MODULE f4_norek1.
  FIELD gs_bpvd-znorek2 MODULE f4_norek2.
