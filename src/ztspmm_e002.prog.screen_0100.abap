
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_items.
    MODULE fill_tc_items.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP WITH CONTROL tc_items.
    CHAIN.
      FIELD gs_items-icon.
      FIELD gs_items-matnr.
      FIELD gs_items-maktx.
      FIELD gs_items-erfmg.
      FIELD gs_items-meins.
      FIELD gs_items-charg.
      FIELD gs_items-text.

      MODULE read_tc_items.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.
  FIELD gs_head-umlgo MODULE f4_storage_location.
  FIELD gs_head-lgort MODULE f4_storage_location.
  FIELD gs_items-charg MODULE ft_batch.
