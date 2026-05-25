
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_shipment.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_shipment.
    CHAIN.
      FIELD zfexpense-tknum.
      FIELD zfexpense-erdat.
      FIELD zfexpense-sttrg.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfexpense-zidno MODULE value_zidno.
  FIELD zfexpense-znopol MODULE value_znopol.
  FIELD zfexpense-tknum MODULE value_tknum.
  FIELD zfexpense-ktext MODULE value_hkont.
