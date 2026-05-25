
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_transaction.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_transaction.
    CHAIN.
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

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfexpense-znopol MODULE value_znopol.
  FIELD zftransaction-vbund MODULE value_vbund.
  FIELD zftransaction-ltext MODULE value_trans.
  FIELD zftransaction-departemen MODULE value_departemen.
