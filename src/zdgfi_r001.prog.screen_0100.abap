
PROCESS BEFORE OUTPUT.
  MODULE pbo.

  LOOP WITH CONTROL tc_007.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_007.
    CHAIN.
      FIELD gs_007-mark.
      FIELD gs_007-statu.
      FIELD gs_007-belnr.
      FIELD gs_007-hkont.
      FIELD gs_007-waers.
      FIELD gs_007-dmbtr.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command.
