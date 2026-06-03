*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E002CL1
*&---------------------------------------------------------------------*
*  CLASS c_oi_errors DEFINITION LOAD.
*
** Create Instance control for container
*  CALL METHOD c_oi_container_control_creator=>get_container_control
*    IMPORTING
*      control = o_control
*      error   = o_error.
*
*  IF o_error->has_failed = 'X'.
*    CALL METHOD o_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.
*
** Create generic container linked to container in screen 100
*  CREATE OBJECT obj_container
*    EXPORTING
*      container_name              = 'CONTAINER'
*    EXCEPTIONS
*      cntl_error                  = 1
*      cntl_system_error           = 2
*      create_error                = 3
*      lifetime_error              = 4
*      lifetime_dynpro_dynpro_link = 5
*      OTHERS                      = 6.
*
*  IF sy-subrc <> 0.
*    MESSAGE e208(00) WITH 'Error creating container'.
*  ENDIF.
*
** Establish connection to GUI Control
*  CALL METHOD o_control->init_control
*    EXPORTING
*      r3_application_name = 'Excel Document Container'
*      inplace_enabled     = 'X'
*      parent              = obj_container
*    IMPORTING
*      error               = o_error.
*
*  IF o_error->has_failed = 'X'.
*    CALL METHOD o_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.
*
** Create Document Proxy
*  CALL METHOD o_control->get_document_proxy
*    EXPORTING
*      document_type  = soi_doctype_excel_sheet
*    IMPORTING
*      document_proxy = o_document
*      error          = o_error.
*
*  IF o_error->has_failed = 'X'.
*    CALL METHOD o_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.

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
