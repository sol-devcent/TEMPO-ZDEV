*&---------------------------------------------------------------------*
*&  Include           ZGHMMSD_BLOCK_STOCKCL1
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
          IMPORTING er_data_changed e_ucomm.
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
ENDCLASS.               "lcl_application
