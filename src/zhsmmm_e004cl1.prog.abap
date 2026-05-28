*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E004CL1
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
          IMPORTING e_row e_column,

      handle_item_double_click
          FOR EVENT item_double_click
          OF cl_gui_alv_tree
          IMPORTING fieldname node_key,

      handle_toolbar1
          FOR EVENT toolbar
          OF cl_gui_alv_grid
          IMPORTING e_object e_interactive,

      handle_menu_button1
          FOR EVENT menu_button
          OF cl_gui_alv_grid
          IMPORTING e_object e_ucomm,

      handle_user_command1
          FOR EVENT user_command
          OF cl_gui_alv_grid
          IMPORTING e_ucomm,

      handle_double_click1
          FOR EVENT double_click
          OF cl_gui_alv_grid
          IMPORTING e_row e_column,

      handle_item_double_click1
          FOR EVENT item_double_click
          OF cl_gui_alv_tree
          IMPORTING fieldname node_key.            .

ENDCLASS.                    "lcl_application DEFINITION

*---------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD handle_menu_button.

  ENDMETHOD.                    "handle_menu_button

  METHOD handle_toolbar.

  ENDMETHOD.                    "handle_toolbar

  METHOD handle_user_command.

  ENDMETHOD.                    "handle_user_command

  METHOD handle_double_click.
    PERFORM f_handle_double_click USING 'MAIN' e_row e_column.
  ENDMETHOD.                    "handle_double_click

  METHOD handle_item_double_click.
    PERFORM f_handle_item_double_click USING fieldname node_key.
  ENDMETHOD.                    "handle_item_double_click

  METHOD handle_menu_button1.
    CASE e_ucomm.
      WHEN '&UPLOAD'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&UPLOAD'
            text  = text-102.
    ENDCASE.
  ENDMETHOD.                    "handle_menu_button1

  METHOD handle_toolbar1.
    CASE gv_trtyp.
      WHEN 'A'.
      WHEN 'H' OR 'V'.
        IF gv_zalno IS INITIAL.
          CLEAR gs_toolbar.
          MOVE 3 TO gs_toolbar-butn_type.
          APPEND gs_toolbar TO e_object->mt_toolbar.

          CLEAR gs_toolbar.
          gs_toolbar-function   = '&UPLOAD'.
          gs_toolbar-icon       = icon_set_copy_in_a.
          gs_toolbar-butn_type  = 0.
          gs_toolbar-quickinfo  = 'Upload data...'.
          gs_toolbar-disabled   = space.
          gs_toolbar-text       = 'Upload'.
          APPEND gs_toolbar TO e_object->mt_toolbar.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "handle_toolbar1

  METHOD handle_user_command1.
    CALL METHOD cl_gui_cfw=>flush.

    CASE e_ucomm.
      WHEN '&UPLOAD'.
        PERFORM f_upload_data USING e_ucomm.
    ENDCASE.
  ENDMETHOD.                    "handle_user_command1

  METHOD handle_double_click1.
    PERFORM f_handle_double_click USING 'DETL' e_row e_column.
  ENDMETHOD.                    "handle_double_click1

  METHOD handle_item_double_click1.

  ENDMETHOD.                    "handle_item_double_click1
ENDCLASS.                    "lcl_application IMPLEMENTATION
