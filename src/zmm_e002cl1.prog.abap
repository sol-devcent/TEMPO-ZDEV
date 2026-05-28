*&---------------------------------------------------------------------*
*&  Include           ZMM_E002CL1
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

  ENDMETHOD.                    "handle_menu_button

  METHOD handle_toolbar.

  ENDMETHOD.                    "handle_toolbar

  METHOD handle_user_command.

  ENDMETHOD.                    "handle_user_command

  METHOD handle_double_click.
    PERFORM f_handle_double_click USING e_row e_column.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
ENDCLASS.                    "lcl_application IMPLEMENTATION
