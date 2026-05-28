*&---------------------------------------------------------------------*
*&  Include           ZF_TTFCL1
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS LCL_APPLICATION DEFINITION
*---------------------------------------------------------------------*

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

      handle_double_click
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column.

ENDCLASS.                    "lcl_application DEFINITION

*---------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD handle_menu_button.
    CASE e_ucomm.
      WHEN '&SALL'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&SALL'
            text  = text-101.
      WHEN '&DALL'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&DALL'
            text  = text-102.
    ENDCASE.
  ENDMETHOD.                    "handle_menu_button

  METHOD handle_toolbar.
    CLEAR gs_toolbar.
    gs_toolbar-function   = '&SALL'.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-icon       = icon_select_all.
    gs_toolbar-disabled   = space.
    gs_toolbar-quickinfo  = 'Select all'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function   = '&DALL'.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-icon       = icon_deselect_all.
    gs_toolbar-disabled   = space.
    gs_toolbar-quickinfo  = 'Deselect all'.
    APPEND gs_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_user_command.
    DATA : lv_valid   TYPE c,
           lt_rows    TYPE lvc_t_row.

    CALL METHOD g_maingrid->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    CALL METHOD cl_gui_cfw=>flush.

    CASE e_ucomm.
      WHEN '&SALL'.
        CALL METHOD g_maingrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_select USING 'X' ''.
        ENDIF.

      WHEN '&DALL'.
        CALL METHOD g_maingrid->check_changed_data
          IMPORTING
            e_valid = lv_valid.

        IF lv_valid IS NOT INITIAL.
          PERFORM f_select USING '' ''.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_double_click.

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
ENDCLASS.                    "lcl_application IMPLEMENTATION
