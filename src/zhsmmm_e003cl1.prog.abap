*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E003CL1
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
          IMPORTING fieldname node_key.
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
    PERFORM f_handle_double_click USING e_row e_column.
  ENDMETHOD.                    "handle_double_click

  METHOD handle_item_double_click.
    PERFORM f_handle_item_double_click USING fieldname node_key.
  ENDMETHOD.                    "handle_item_double_click

  METHOD handle_menu_button1.
    CASE e_ucomm.
      WHEN '&SAVE'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&SAVE'
            text  = text-201.
      WHEN '&OAD'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&LOAD'
            text  = text-202.
    ENDCASE.
  ENDMETHOD.                    "handle_menu_button1

  METHOD handle_toolbar1.
    CLEAR gs_toolbar.
    gs_toolbar-function   = '&LOAD'.
    gs_toolbar-icon       = icon_alv_variant_choose.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-quickinfo  = 'Select layout...'.
    gs_toolbar-disabled   = space.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function   = '&SAVE'.
    gs_toolbar-icon       = icon_alv_variant_save.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-quickinfo  = 'Save layout...'.
    gs_toolbar-disabled   = space.
    APPEND gs_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "handle_toolbar1

  METHOD handle_user_command1.
    CALL METHOD g_tabgrid02->set_function_code
      CHANGING
        c_ucomm = e_ucomm.
  ENDMETHOD.                    "handle_user_command1

  METHOD handle_double_click1.

  ENDMETHOD.                    "handle_double_click1

  METHOD handle_item_double_click1.

  ENDMETHOD.                    "handle_item_double_click1
ENDCLASS.                    "lcl_application IMPLEMENTATION
