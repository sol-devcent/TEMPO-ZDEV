
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_shipnew.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_shipnew.
    CHAIN.
      FIELD zfshipment-tknum.
      FIELD zfshipment-erdat.
      FIELD zfshipment-sttrg.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfshipment-tknum MODULE value_tknum.
