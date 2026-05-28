*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E004CL1
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

      handle_data_changed
      FOR EVENT data_changed
                  OF cl_gui_alv_grid
        IMPORTING er_data_changed e_ucomm.

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

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD handle_data_changed.
    DATA: ls_good   TYPE lvc_s_modi,
          lv_pidres TYPE zpidres,
          lv_notgi  TYPE znotgi,
          lv_diffe  TYPE ztspmmdt006-labst.

*    IF sy-subrc = 0.
    LOOP AT er_data_changed->mt_good_cells INTO ls_good
                                           WHERE fieldname = 'PIDRES'
                                              OR fieldname = 'NOTGI'.
      CASE ls_good-fieldname.
        WHEN 'PIDRES'.
          CLEAR: lv_pidres.
          CALL METHOD er_data_changed->get_cell_value
            EXPORTING
              i_row_id    = ls_good-row_id
              i_fieldname = 'PIDRES'
            IMPORTING
              e_value     = lv_pidres.

          IF lv_pidres IS NOT INITIAL.
            READ TABLE gt_out ASSIGNING FIELD-SYMBOL(<fs_out>)
                              INDEX ls_good-row_id.
            IF sy-subrc = 0.
              <fs_out>-pidres = lv_pidres.
              SELECT SINGLE pidtxt INTO <fs_out>-pidtxt
                FROM ztspmmdt007 WHERE werks  = <fs_out>-werks
                                   AND pidres = <fs_out>-pidres.
            ENDIF.
          ENDIF.

        WHEN 'NOTGI'.
          CLEAR: lv_notgi,lv_diffe.
          CALL METHOD er_data_changed->get_cell_value
            EXPORTING
              i_row_id    = ls_good-row_id
              i_fieldname = 'NOTGI'
            IMPORTING
              e_value     = lv_notgi.

*          IF lv_notgi IS NOT INITIAL.
            READ TABLE gt_out ASSIGNING <fs_out>
                              INDEX ls_good-row_id.
            IF sy-subrc = 0.
              <fs_out>-notgi = lv_notgi.
              <fs_out>-total = <fs_out>-menge + <fs_out>-notgi.
              lv_diffe = <fs_out>-labst - <fs_out>-total.
              IF lv_diffe < 0.
                <fs_out>-shkzg  = 'H'.
                <fs_out>-diffp  = abs( lv_diffe ).
                CLEAR <fs_out>-diffm.
              ELSEIF lv_diffe > 0.
                <fs_out>-shkzg  = 'S'.
                <fs_out>-diffm  = lv_diffe.
                CLEAR <fs_out>-diffp.
              ELSE.
                CLEAR: <fs_out>-diffp,<fs_out>-diffm.
                PERFORM f_style_cell USING '' 'MARK' ''
                                     CHANGING <fs_out>-style.
              ENDIF.
              TRY .
                  IF <fs_out>-diffp IS NOT INITIAL.
                    <fs_out>-qty311% = ( <fs_out>-diffp / <fs_out>-qty311 ) * 100.
                  ELSEIF <fs_out>-diffm IS NOT INITIAL.
                    <fs_out>-qty311% = ( <fs_out>-diffm / <fs_out>-qty311 ) * -100.
                  ELSE.
                    CLEAR <fs_out>-qty311%.
                  ENDIF.
                CATCH cx_sy_zerodivide.
              ENDTRY.
            ENDIF.
*          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF sy-subrc = 0 AND er_data_changed->mt_good_cells[] IS NOT INITIAL.
      PERFORM f_alv_refresh USING 'X'.
    ENDIF.
*    ENDIF.
  ENDMETHOD.                    "handle_data_Change
ENDCLASS.                    "lcl_application IMPLEMENTATION
