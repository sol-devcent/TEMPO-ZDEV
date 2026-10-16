
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_splitq.
    MODULE fill_table_control.
  ENDLOOP.

*  MODULE chart_container.
*
*  MODULE display_chart.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_splitq.
    CHAIN.
      FIELD gs_splitq-revis.
      FIELD gs_splitq-zeile.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.
