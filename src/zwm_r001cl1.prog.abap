*&---------------------------------------------------------------------*
*&  Include           ZWM_R001CL1
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

      handle_top_of_page
          FOR EVENT top_of_page
          OF cl_gui_alv_grid
          IMPORTING e_dyndoc_id.
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

  METHOD handle_top_of_page.
    PERFORM f_top_of_page USING g_dyndoc_id.
  ENDMETHOD.                            "top_of_page
ENDCLASS.                    "lcl_application IMPLEMENTATION
