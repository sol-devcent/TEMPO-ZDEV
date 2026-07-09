*&---------------------------------------------------------------------*
*&  Include           ZCORETAX_E004CL1
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
    PERFORM f_handle_double_click USING 'CC_MAIN' e_row e_column.


  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
ENDCLASS.                    "lcl_application IMPLEMENTATION
*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0065   text
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM f_handle_double_click  USING   fu_container fu_row fu_column.
  FIELD-SYMBOLS : <fs>       TYPE any,
                  <fs_lmain> TYPE any.
  DATA: gs_out  TYPE ty_out.
  data: lv_file(128).

  CASE fu_container.
    WHEN 'CC_MAIN'.
**      CASE fu_column.
**        WHEN 'ZFILENAME'.
**          READ TABLE <fs_out> ASSIGNING <fs_lmain> INDEX fu_row.
**          IF sy-subrc = 0.
**            ASSIGN COMPONENT 'ZFILENAME' OF STRUCTURE <fs_lmain> TO <fs>.
**            gs_out-zfilename = <fs>.
****            ASSIGN COMPONENT 'PATH' OF STRUCTURE <fs_lmain> TO <fs>.
****            gs_out-path = <fs>.
**            IF gs_out-zfilename IS NOT INITIAL.
**              CONCATENATE gv_path gs_out-zfilename into lv_file.
**              PERFORM f_view_pdf USING lv_file.
**            ENDIF.
**          ENDIF.
**      ENDCASE.
  ENDCASE.

ENDFORM.
