*&---------------------------------------------------------------------*
*&  Include           ZCO_COGS_CUSTCL1
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS LCL_APPLICATION DEFINITION
*---------------------------------------------------------------------*

CLASS lcl_application DEFINITION.

  PUBLIC SECTION.

    METHODS:
      handle_double_click
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column.

ENDCLASS.                    "lcl_application DEFINITION

*---------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD handle_double_click.
    CASE e_column.
      WHEN 'EBELN'.
*        READ TABLE gt_out INTO wa_out INDEX e_row-index.
*        IF sy-subrc = 0.
*          SET PARAMETER ID 'BES' FIELD wa_out-ebeln.
*          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
*        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
ENDCLASS.                    "lcl_application IMPLEMENTATION
