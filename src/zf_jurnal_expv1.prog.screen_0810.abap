
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_advance.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_advance.
    CHAIN.
      FIELD zfexpense-zuonr.
      FIELD zfexpense-belnr.
      FIELD zfexpense-gjahr.
      FIELD zfexpense-budat.
      FIELD zfexpense-bldat.
      FIELD zfexpense-dmbtr.
      FIELD zfexpense-sgtxt.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfexpense-zidno MODULE value_zidno.
  FIELD zfexpense-znopol MODULE value_znopol.
  FIELD zfexpense-ktext MODULE value_hkont.
