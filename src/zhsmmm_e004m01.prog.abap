*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E004M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  PERFORM f_docking_split_container.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  IF g_tabgrid01 IS INITIAL.
    PERFORM f_main_alv.
  ENDIF.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  PERFORM f_exit.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_pbo.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  PERFORM f_fill_table_control.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  PERFORM f_read_table_control.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_validate_quantity.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  DETAIL_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE detail_alv OUTPUT.
  IF g_tabgrid02 IS INITIAL.
    PERFORM f_detail_alv.
  ENDIF.
ENDMODULE.                 " DETAIL_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  GET_FILENAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_filename INPUT.
  PERFORM f_f4_filename CHANGING gv_filename.
ENDMODULE.                 " GET_FILENAME  INPUT

*&---------------------------------------------------------------------*
*&      Module  DISPLAY_CHART  OUTPUT
*&---------------------------------------------------------------------*
MODULE display_chart OUTPUT.
  PERFORM f_display_chart.
ENDMODULE.                 " DISPLAY_CHART  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHART_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE chart_container OUTPUT.
  PERFORM chart_container.
ENDMODULE.                 " CHART_CONTAINER  OUTPUT
