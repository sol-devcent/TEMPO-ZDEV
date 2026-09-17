
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_rfq.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_rfq.
    CHAIN.
      FIELD gs_rfqd-mark.
      FIELD gs_rfqd-lifnr.
      FIELD gs_rfqd-name1.
      FIELD gs_rfqd-matnr.
      FIELD gs_rfqd-maktx.
      FIELD gs_rfqd-anfnr.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD gs_rfqh-asart MODULE value_rfq_type.
