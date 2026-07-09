*&---------------------------------------------------------------------*
*&  Include           ZCO_COCOCL1
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       Class (Definition)  lcl_application
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
          IMPORTING e_ucomm.
ENDCLASS.                    "lcl_application DEFINITION

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
ENDCLASS.               "lcl_application
