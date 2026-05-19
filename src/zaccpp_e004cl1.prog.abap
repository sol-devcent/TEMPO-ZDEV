*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E004CL1
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbart
          FOR EVENT toolbar
          OF cl_gui_alv_grid
          IMPORTING e_object e_interactive,

      handle_menu_buttont
          FOR EVENT menu_button
          OF cl_gui_alv_grid
          IMPORTING e_object e_ucomm,

      handle_user_commandt
          FOR EVENT user_command
          OF cl_gui_alv_grid
          IMPORTING e_ucomm,

      handle_double_clickt
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column,

      handle_toolbarb
          FOR EVENT toolbar
          OF cl_gui_alv_grid
          IMPORTING e_object e_interactive,

      handle_menu_buttonb
          FOR EVENT menu_button
          OF cl_gui_alv_grid
          IMPORTING e_object e_ucomm,

      handle_user_commandb
          FOR EVENT user_command
          OF cl_gui_alv_grid
          IMPORTING e_ucomm,

      handle_double_clickb
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column.
ENDCLASS.               "lcl_application

*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD handle_menu_buttont.
    CASE e_ucomm.
      WHEN '&AVE'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&AVE'
            text  = text-102.
      WHEN '&OAD'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&OAD'
            text  = text-103.
    ENDCASE.
  ENDMETHOD.                    "handle_menu_buttont

  METHOD handle_toolbart.
    CLEAR gs_toolbar.
    gs_toolbar-function   = '&OAD'.
    gs_toolbar-icon       = icon_alv_variant_choose.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-quickinfo  = 'Select layout...'.
    gs_toolbar-disabled   = space.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function   = '&AVE'.
    gs_toolbar-icon       = icon_alv_variant_save.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-quickinfo  = 'Save layout...'.
    gs_toolbar-disabled   = space.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 3 TO gs_toolbar-butn_type.
    APPEND gs_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "handle_toolbart

  METHOD handle_user_commandt.
    CALL METHOD cl_gui_cfw=>flush.

    CASE e_ucomm.
      WHEN '&OAD'.
        CALL METHOD g_tgrid->set_function_code
          CHANGING
            c_ucomm = e_ucomm.

      WHEN '&AVE'.
        CALL METHOD g_tgrid->set_function_code
          CHANGING
            c_ucomm = e_ucomm.
    ENDCASE.
  ENDMETHOD.                    "handle_user_commandt

  METHOD handle_double_clickt.
  ENDMETHOD.                    "handle_double_clickt

  METHOD handle_menu_buttonb.
    CASE e_ucomm.
      WHEN '&AVE'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&AVE'
            text  = text-102.
      WHEN '&OAD'.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode = '&OAD'
            text  = text-103.
    ENDCASE.
  ENDMETHOD.                    "handle_menu_buttonb

  METHOD handle_toolbarb.
    CLEAR gs_toolbar.
    gs_toolbar-function   = '&OAD'.
    gs_toolbar-icon       = icon_alv_variant_choose.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-quickinfo  = 'Select layout...'.
    gs_toolbar-disabled   = space.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function   = '&AVE'.
    gs_toolbar-icon       = icon_alv_variant_save.
    gs_toolbar-butn_type  = 0.
    gs_toolbar-quickinfo  = 'Save layout...'.
    gs_toolbar-disabled   = space.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 3 TO gs_toolbar-butn_type.
    APPEND gs_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "handle_toolbarb

  METHOD handle_user_commandb.
    CALL METHOD cl_gui_cfw=>flush.

    CASE e_ucomm.
      WHEN '&OAD'.
        CALL METHOD g_bgrid->set_function_code
          CHANGING
            c_ucomm = e_ucomm.

      WHEN '&AVE'.
        CALL METHOD g_bgrid->set_function_code
          CHANGING
            c_ucomm = e_ucomm.
    ENDCASE.
  ENDMETHOD.                    "handle_user_commandb

  METHOD handle_double_clickb.
  ENDMETHOD.                    "handle_double_clickb

ENDCLASS.               "lcl_application
