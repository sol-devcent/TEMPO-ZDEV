
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_simtran.
    MODULE fill_table_control.
  ENDLOOP.

  LOOP WITH CONTROL tc_simship.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_simtran.
    CHAIN.
      FIELD zfexpense-znopol.
      FIELD zfexpense-ltext.
      FIELD zfexpense-description.
      FIELD zfexpense-departemen.
      FIELD zfexpense-meins.
      FIELD zfexpense-menge.
      FIELD zfexpense-speed.
      FIELD zfexpense-kmstr.
      FIELD zfexpense-kmend.
      FIELD zfexpense-waers.
      FIELD zfexpense-wrbtr.
      FIELD zfexpense-trf_hari.
      FIELD zfexpense-trf_inap.
      FIELD zfexpense-vbund.
      FIELD zfexpense-text.
      FIELD zfexpense-type.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  LOOP WITH CONTROL tc_simship.
    CHAIN.
      FIELD zfshipment-znopol.
      FIELD zfshipment-tknum.
      FIELD zfshipment-erdat.
      FIELD zfshipment-sttrg.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.
