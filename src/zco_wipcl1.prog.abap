*&---------------------------------------------------------------------*
*&  Include           ZCO_WIPCL1
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar
          FOR EVENT toolbar
          OF cl_gui_alv_grid
          IMPORTING e_object e_interactive,

      handle_menu_button
          FOR EVENT menu_button
          OF cl_gui_alv_grid
          IMPORTING e_object e_ucomm,

      handle_user_command
          FOR EVENT user_command
          OF cl_gui_alv_grid
          IMPORTING e_ucomm,

      handle_data_changed
          FOR EVENT data_changed
          OF cl_gui_alv_grid
          IMPORTING er_data_changed e_ucomm,

      handle_double_click
          FOR EVENT double_click
          OF cl_gui_alv_grid
          IMPORTING e_row e_column.
ENDCLASS.               "lcl_application

*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD handle_toolbar.

  ENDMETHOD.                    "handle_toolbar

  METHOD handle_menu_button.

  ENDMETHOD.                    "handle_menu_button

  METHOD handle_user_command.

  ENDMETHOD.                    "handle_user_command

  METHOD handle_data_changed.

  ENDMETHOD.                    "handle_data_changed

  METHOD handle_double_click.
    DATA : ls_out     LIKE LINE OF gt_out,
           lv_matnr   TYPE mara-matnr.

    CLEAR : gt_out2[], gt_out2, gv_matnr.
    READ TABLE gt_out1 INTO ls_out INDEX e_row-index.
    IF sy-subrc = 0.
      lv_matnr  = ls_out-matnr.
      CONCATENATE ls_out-matnr '-' ls_out-maktx INTO gv_matnr
      SEPARATED BY space.
      CLEAR ls_out.
      LOOP AT gt_out INTO ls_out WHERE matnr = lv_matnr.
        APPEND ls_out TO gt_out2.
      ENDLOOP.
    ENDIF.

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_outgrid1.

    CALL METHOD cl_gui_cfw=>flush.

    PERFORM f_alv_refresh.
  ENDMETHOD.                    "handle_double_click
ENDCLASS.               "lcl_application
