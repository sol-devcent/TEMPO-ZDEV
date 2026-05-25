
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_final.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  MODULE validate_data.

  LOOP WITH CONTROL tc_final.
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
      FIELD zfexpense-wrbtrv.
      FIELD zfexpense-vbund.
      FIELD zfexpense-text.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command.
