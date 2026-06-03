*&---------------------------------------------------------------------*
*&  Include           ZWM_E001CL1
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
    DATA : ls_out   LIKE LINE OF gt_out.

    CASE e_column.
      WHEN 'TANUM'.
        READ TABLE gt_out INTO ls_out INDEX e_row-index.
        IF sy-subrc = 0.
          SET PARAMETER ID 'TAN' FIELD ls_out-tanum.
          SET PARAMETER ID 'LGN' FIELD ls_out-lgnum.
          CALL TRANSACTION 'LT21' AND SKIP FIRST SCREEN.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
ENDCLASS.                    "lcl_application IMPLEMENTATION
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
 PERFORM f_exit.
ENDMODULE.
