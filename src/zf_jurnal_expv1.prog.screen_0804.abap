
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_expense.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_expense.
    CHAIN.
      FIELD zfexpense-type.
      FIELD zfexpense-buzei.
      FIELD zfexpense-ltext.
      FIELD zfexpense-description.
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
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfexpense-vbund MODULE value_vbund.
