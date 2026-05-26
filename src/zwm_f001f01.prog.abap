*&---------------------------------------------------------------------*
*&  Include           ZWM_F001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_004   TYPE STANDARD TABLE OF zwmdt004,
         lt_likp  TYPE STANDARD TABLE OF likp,
         ls_plant LIKE LINE OF gt_plant.

  CASE 'X'.
    WHEN radio1.
      READ TABLE gt_plant INTO ls_plant INDEX 1.

      SELECT *
        FROM zwmdt004
        INTO CORRESPONDING FIELDS OF TABLE gt_004
        WHERE lgnum = ls_plant-lgnum
          AND tknum IN so_tknum
          AND ( lfimg <> 0 OR zero = 'X' ).

      PERFORM f_validate_004.

      lt_004[]  = gt_004[].
      SORT lt_004 BY tknum.
      DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tknum.
      IF lt_004[] IS NOT INITIAL.
        SELECT *
          FROM vttp
          INTO CORRESPONDING FIELDS OF TABLE gt_vttp
          FOR ALL ENTRIES IN lt_004
          WHERE tknum = lt_004-tknum.
        IF gt_vttp[] IS NOT INITIAL.
          SELECT *
            FROM likp
            INTO CORRESPONDING FIELDS OF TABLE lt_likp
            FOR ALL ENTRIES IN gt_vttp
            WHERE vbeln = gt_vttp-vbeln
              AND werks = pa_werks.
          IF lt_likp[] IS NOT INITIAL.
            SELECT *
              FROM lips
              INTO CORRESPONDING FIELDS OF TABLE gt_lips
              FOR ALL ENTRIES IN lt_likp
              WHERE vbeln = lt_likp-vbeln
                AND lfimg <> 0.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio2.
*      SELECT *
*        FROM zwmdt006
*        INTO CORRESPONDING FIELDS OF TABLE gt_006
*        WHERE ebeln IN so_ebel1
*          AND vbeln IN so_vbeln.

      SELECT *
        FROM zwmdt004
        INTO CORRESPONDING FIELDS OF TABLE gt_004
        WHERE tknum IN so_ebel1
          AND vbeln IN so_vbeln
          AND lfimg <> 0.

      PERFORM f_validate_004.

      lt_004[]  = gt_004[].
      SORT lt_004 BY tknum.
      DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tknum.
      IF lt_004[] IS NOT INITIAL.
        SELECT *
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
          FOR ALL ENTRIES IN lt_004
          WHERE ebeln = lt_004-tknum.
      ENDIF.
  ENDCASE.

  lt_004[] = gt_004[].
  SORT lt_004 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING matnr.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN lt_004
      WHERE matnr = lt_004-matnr
        AND spras = sy-langu.
  ENDIF.

  lt_004[] = gt_004[].
  SORT lt_004 BY lgnum tanum.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING lgnum tanum.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
      FOR ALL ENTRIES IN lt_004
      WHERE lgnum = lt_004-lgnum
        AND tanum = lt_004-tanum.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_head      LIKE LINE OF gt_head,
         ls_detl      LIKE LINE OF gt_detl,
         ls_ltap      LIKE LINE OF gt_ltap,
         lt_sum       TYPE STANDARD TABLE OF ty_sum,
         lt_x004      TYPE STANDARD TABLE OF zwmdt004,
         ls_x004      LIKE LINE OF lt_x004,
         ls_ekpo      LIKE LINE OF gt_ekpo,
         ls_004       LIKE LINE OF gt_004,
         ls_006       LIKE LINE OF gt_006,
         ls_sum       LIKE LINE OF lt_sum,
         ls_plant     LIKE LINE OF gt_plant,
         ls_makt      LIKE LINE OF gt_makt,
         ls_vttp      LIKE LINE OF gt_vttp,
         ls_lips      LIKE LINE OF gt_lips,
         lv_count     TYPE i,
         lv_vrkme(10),
         lv_nsolm     TYPE ltap-nsolm,
         lv_menge     TYPE ekpo-menge,
         lv_diffe     TYPE ekpo-menge,
         lv_rusak     TYPE ekpo-menge,
         ls_kond      LIKE LINE OF gt_kond.

  SORT gt_004 BY tknum matnr charg.
  LOOP AT gt_004 INTO ls_004.
    ls_sum-tknum  = ls_004-tknum.
    ls_sum-posnr  = ls_004-posnr.
    ls_sum-matnr  = ls_004-matnr.
    ls_sum-charg  = ls_004-charg.
    ls_sum-lfimg  = ls_004-lfimg.
    ls_sum-vrkme  = ls_004-vrkme.
    IF ls_004-rusak IS NOT INITIAL.
      ls_sum-rusak  = ls_004-lfimg.
    ENDIF.
    CLEAR ls_ltap.
    LOOP AT gt_ltap INTO ls_ltap
                    WHERE lgnum = ls_004-lgnum
                      AND tanum = ls_004-tanum.
      ADD ls_ltap-nsolm TO lv_nsolm.
    ENDLOOP.
    ls_sum-nsolm  = lv_nsolm.
    COLLECT ls_sum INTO lt_sum.
    CLEAR : ls_sum, lv_nsolm.
  ENDLOOP.

  lt_x004[]  = gt_004[].
  SORT lt_x004 BY lgnum tknum.
  DELETE ADJACENT DUPLICATES FROM lt_x004 COMPARING lgnum tknum.

  LOOP AT lt_x004 INTO ls_x004.
    CLEAR ls_plant.
    READ TABLE gt_plant INTO ls_plant
                        WITH KEY lgnum = ls_x004-lgnum.
    IF sy-subrc = 0.
      ls_head-name1   = ls_plant-name1.
    ENDIF.

    ls_head-noreg   = ls_x004-bastno.
    ls_head-lgnum   = ls_x004-lgnum.
    ls_head-tknum   = ls_x004-tknum.
    ls_head-zdtsul  = ls_x004-zdtsul.
    APPEND ls_head TO gt_head.

    CLEAR lv_count.
    LOOP AT lt_sum INTO ls_sum WHERE tknum = ls_x004-tknum.
      ls_detl-tknum   = ls_sum-tknum.
      ls_detl-matnr   = ls_sum-matnr.
      CLEAR ls_makt.
      READ TABLE gt_makt INTO ls_makt
                         WITH KEY matnr = ls_sum-matnr.
      IF sy-subrc = 0.
        ls_detl-maktx   = ls_makt-maktx.
      ENDIF.
      ls_detl-charg   = ls_sum-charg.

      CLEAR lv_menge.
      CASE 'X'.
        WHEN radio1.
          LOOP AT gt_vttp INTO ls_vttp WHERE tknum = ls_x004-tknum.
            LOOP AT gt_lips INTO ls_lips WHERE matnr = ls_sum-matnr
                                           AND charg = ls_sum-charg
                                           AND vbeln = ls_vttp-vbeln
                                           AND posnr = ls_sum-posnr.
              ADD ls_lips-lfimg TO lv_menge.
            ENDLOOP.
          ENDLOOP.

          WRITE lv_menge TO ls_detl-value UNIT ls_sum-vrkme.
          CONDENSE ls_detl-value NO-GAPS.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = ls_sum-vrkme
            IMPORTING
              output         = lv_vrkme
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.

          CONCATENATE ls_detl-value lv_vrkme
          INTO ls_detl-value
          SEPARATED BY space.

          CLEAR ls_004.
          READ TABLE gt_004 INTO ls_004
                            WITH KEY tknum = ls_sum-tknum
                                     matnr = ls_sum-matnr
                                     charg = ls_sum-charg.
          IF ls_004-newch IS NOT INITIAL.
            lv_diffe = ls_sum-lfimg * -1.
          ELSE.
            lv_diffe = lv_menge - ls_sum-nsolm - ls_sum-rusak.
          ENDIF.

          IF lv_diffe <> 0.
            IF lv_diffe < 0.
              ADD 1 TO lv_count.
              ls_detl-more  = 'X'.
            ELSE.
              ADD 1 TO lv_count.
              ls_detl-less  = 'X'.
            ENDIF.
            ls_detl-no      = lv_count.
            lv_diffe = abs( lv_diffe ).
            WRITE lv_diffe TO ls_detl-abnormal UNIT ls_sum-vrkme.
            CONDENSE ls_detl-abnormal NO-GAPS.
            CONCATENATE ls_detl-abnormal lv_vrkme
            INTO ls_detl-abnormal
            SEPARATED BY space.
          ENDIF.

          IF ls_sum-rusak <> 0.
            ADD 1 TO lv_count.
            ls_detl-no      = lv_count.
            WRITE ls_sum-rusak TO ls_detl-abnormal UNIT ls_sum-vrkme.
            CONDENSE ls_detl-abnormal NO-GAPS.
            CONCATENATE ls_detl-abnormal lv_vrkme
            INTO ls_detl-abnormal
            SEPARATED BY space.
            ls_detl-rusak = 'X'.
          ENDIF.
          APPEND ls_detl TO gt_detl.

        WHEN radio2.
*          CLEAR : ls_006, lv_menge.
*          LOOP AT gt_006 INTO ls_006 WHERE ebeln = ls_x004-tknum
*                                       AND matnr = ls_sum-matnr.
*            ADD ls_006-menge TO lv_menge.
*            CLEAR ls_006.
*          ENDLOOP.

          LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_sum-tknum
                                         AND ebelp = ls_sum-posnr.
            ADD ls_ekpo-menge TO lv_menge.
          ENDLOOP.

          WRITE lv_menge TO ls_detl-value UNIT ls_sum-vrkme.
          CONDENSE ls_detl-value NO-GAPS.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = ls_sum-vrkme
            IMPORTING
              output         = lv_vrkme
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.

          CONCATENATE ls_detl-value lv_vrkme
          INTO ls_detl-value
          SEPARATED BY space.

          lv_diffe = lv_menge - ls_sum-nsolm - ls_sum-rusak.
          IF lv_diffe <> 0.
            IF lv_diffe < 0.
              ADD 1 TO lv_count.
              ls_detl-more  = 'X'.
            ELSE.
              ADD 1 TO lv_count.
              ls_detl-less  = 'X'.
            ENDIF.
            ls_detl-no      = lv_count.
            lv_diffe = abs( lv_diffe ).
            WRITE lv_diffe TO ls_detl-abnormal UNIT ls_sum-vrkme.
            CONDENSE ls_detl-abnormal NO-GAPS.
            CONCATENATE ls_detl-abnormal lv_vrkme
            INTO ls_detl-abnormal
            SEPARATED BY space.
          ENDIF.

          IF ls_sum-rusak <> 0.
            ADD 1 TO lv_count.
            ls_detl-no      = lv_count.
            WRITE ls_sum-rusak TO ls_detl-abnormal UNIT ls_sum-vrkme.
            CONDENSE ls_detl-abnormal NO-GAPS.
            CONCATENATE ls_detl-abnormal lv_vrkme
            INTO ls_detl-abnormal
            SEPARATED BY space.
            ls_detl-rusak = 'X'.
          ENDIF.
          APPEND ls_detl TO gt_detl.
      ENDCASE.

      CLEAR ls_detl.
    ENDLOOP.
    CLEAR lv_count.
  ENDLOOP.

  LOOP AT gt_head INTO ls_head.
    READ TABLE gt_detl INTO ls_detl
                       WITH KEY tknum = ls_head-tknum.
    IF sy-subrc <> 0.
      DELETE TABLE gt_head FROM ls_head.
    ELSE.
      CLEAR lv_count.
      LOOP AT gt_detl INTO ls_detl WHERE tknum = ls_head-tknum.
        ls_kond-lgnum = ls_detl-lgnum.
        ls_kond-tknum = ls_detl-tknum.
        IF ls_detl-less IS NOT INITIAL.
          PERFORM f_add_condition USING ls_kond ls_detl-no 'KURANG'
                                  CHANGING lv_count.
          ls_head-less = 'X'.
        ENDIF.
        IF ls_detl-more IS NOT INITIAL.
          PERFORM f_add_condition USING ls_kond ls_detl-no 'LEBIH'
                                  CHANGING lv_count.
          ls_head-more = 'X'.
        ENDIF.
        IF ls_detl-rusak IS NOT INITIAL.
          PERFORM f_add_condition USING ls_kond ls_detl-no 'RUSAK'
                                  CHANGING lv_count.
          ls_head-rusak = 'X'.
        ENDIF.
      ENDLOOP.

      MODIFY gt_head FROM ls_head TRANSPORTING less more rusak.

      IF ls_kond IS NOT INITIAL.
        APPEND ls_kond TO gt_kond.
        CLEAR ls_kond.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_formname       TYPE tdsfname,
         lv_funcname       TYPE tdsfname,
         ls_control_option TYPE ssfctrlop,
         ls_output_option  TYPE ssfcompop.

  DATA : ls_head LIKE LINE OF gt_head,
         ls_detl LIKE LINE OF gt_detl,
         lt_detl TYPE STANDARD TABLE OF zwmst004,
         lt_kond TYPE STANDARD TABLE OF zwmst004x,
         ls_kond LIKE LINE OF lt_kond.

  lv_formname = 'ZWM_SF001'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  LOOP AT gt_head INTO ls_head.
    AT FIRST.
      ls_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      ls_control_option-no_close = space.
    ENDAT.

    IF pa_proc IS NOT INITIAL.
      ls_control_option-no_dialog = 'X'.
      ls_output_option-tdnewid    = 'X'.
      ls_output_option-tdimmed    = 'X'.
      ls_output_option-tddelete   = ''.
    ENDIF.

    IF pa_prev IS INITIAL.
      ls_output_option-tdnoprev   = 'X'.
    ELSE.
      ls_output_option-tdnoprint  = 'X'.
    ENDIF.

    ls_head-nopol = space.

    IF ls_head-noreg IS INITIAL.
      PERFORM f_get_next_number USING ls_head-lgnum ls_head-tknum
                                CHANGING ls_head-noreg.
    ENDIF.

    CLEAR : lt_detl[].
    LOOP AT gt_detl INTO ls_detl WHERE tknum = ls_head-tknum.
      APPEND ls_detl TO lt_detl.
      CLEAR ls_detl.
    ENDLOOP.

    CLEAR : lt_kond[].
    LOOP AT gt_kond INTO ls_kond WHERE tknum = ls_head-tknum.
      APPEND ls_kond TO lt_kond.
      CLEAR ls_kond.
    ENDLOOP.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ls_control_option
        output_options     = ls_output_option
        gs_head            = ls_head
      TABLES
        gt_detl            = lt_detl
        gt_kond            = lt_kond
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    ls_control_option-no_open = 'X'.
  ENDLOOP.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT t320~lgnum t001w~werks t001w~name1
    FROM t320 JOIN t001w ON t320~werks = t001w~werks
    INTO CORRESPONDING FIELDS OF TABLE gt_plant.

  CASE 'X'.
    WHEN radio1 OR radio2.
      gv_object = 'ZBASTNO'.
      gv_sub    = pa_werks.
    WHEN OTHERS.
      gv_object = 'ZBASTTL'.
      gv_sub    = pa_lgnum.
  ENDCASE.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  IF sy-uname(3) = 'PTT'.
    PERFORM f_modify_screen USING : 'TL' '0' '' '' ''.
  ELSEIF sy-uname(3) = 'BKS'.
    PERFORM f_modify_screen USING : 'PTT' '0' '' '' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'SE1' '0' '' '' '',
                                      'SE2' '0' '' '' '',
                                      'SVN' '0' '' '' '',
                                      'SIN' '0' '' '' '',
                                      'SMN' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PLG' '0' '' '' '',
                                      'PLF' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'STK' '0' '' '' '',
                                      'SIN' '0' '' '' '',
                                      'SMN' '0' '' '' '',
                                      'SE2' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PLG' '0' '' '' '',
                                      'PLF' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'SVN' '0' '' '' '',
                                      'STK' '0' '' '' '',
                                      'SIN' '0' '' '' '',
                                      'SMN' '0' '' '' '',
                                      'SE1' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PWE' '0' '' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'SE1' '0' '' '' '',
                                      'STK' '0' '' '' '',
                                      'SIN' '0' '' '' '',
                                      'SMN' '0' '' '' '',
                                      'SE2' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PWE' '0' '' '' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'SE1' '0' '' '' '',
                                      'STK' '0' '' '' '',
                                      'SVN' '0' '' '' '',
                                      'SMN' '0' '' '' '',
                                      'SE2' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PWE' '0' '' '' ''.
    WHEN radio6.
      PERFORM f_modify_screen USING : 'SE1' '0' '' '' '',
                                      'STK' '0' '' '' '',
                                      'SIN' '0' '' '' '',
                                      'SVN' '0' '' '' '',
                                      'SE2' '0' '' '' '',
                                      'SBA' '0' '' '' '',
                                      'PWE' '0' '' '' ''.
    WHEN radio7.
      PERFORM f_modify_screen USING : 'SE1' '0' '' '' '',
                                      'STK' '0' '' '' '',
                                      'SVN' '0' '' '' '',
                                      'SMN' '0' '' '' '',
                                      'SE2' '0' '' '' '',
                                      'PMJ' '0' '' '' '',
                                      'SIN' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'PLF' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION-SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  USING    fu_lgnum fu_tknum
                        CHANGING fc_noreg.
  DATA : lv_number(5),
         lv_gjahr     TYPE inri-toyear,
         lv_subrc     TYPE sy-subrc,
         lv_nrlevel   TYPE nriv-nrlevel.

  DATA : ls_head        LIKE LINE OF gt_head.

  lv_gjahr  = sy-datum(4).

  IF pa_prev IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = gv_object
        subobject               = gv_sub
        toyear                  = lv_gjahr
      IMPORTING
        number                  = lv_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    lv_subrc  = sy-subrc.
  ELSE.
    SELECT SINGLE nrlevel
      FROM nriv
      INTO lv_nrlevel
      WHERE object    = gv_object
        AND subobject = gv_sub
        AND nrrangenr = '01'
        AND toyear    = lv_gjahr.

    lv_number = lv_nrlevel+15(5) + 1.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_number
      IMPORTING
        output = lv_number.

    lv_subrc  = sy-subrc.
  ENDIF.

  IF lv_subrc = 0.
    IF pa_prev IS INITIAL.
      CASE 'X'.
        WHEN radio1 OR radio2.
          CONCATENATE lv_number '8020' gv_sub sy-datum+4(2) sy-datum(4)
          INTO fc_noreg
          SEPARATED BY '/'.

          UPDATE zwmdt004 SET bastno = fc_noreg
                          WHERE lgnum = fu_lgnum
                            AND tknum = fu_tknum.
        WHEN OTHERS.
          CONCATENATE lv_number gv_sub sy-datum+4(2) sy-datum(4)
          INTO fc_noreg
          SEPARATED BY '/'.

          LOOP AT gt_head INTO ls_head.
            UPDATE zwmdt007 SET bastno = fc_noreg
                                lfsnr  = pa_lfsnr
                            WHERE lgnum = ls_head-lgnum
                              AND ebeln = ls_head-tknum
                              AND bastno = space
                              AND ( newch = 'X' OR zero = 'X' OR rusak = 'X' OR
                                    menge_l <> 0 OR menge_k <> 0 OR menge_r <> 0 ).
          ENDLOOP.
      ENDCASE.
    ELSE.
      CASE 'X'.
        WHEN radio1 OR radio2.
        WHEN OTHERS.
          CONCATENATE lv_number gv_sub sy-datum+4(2) sy-datum(4)
          INTO fc_noreg
          SEPARATED BY '/'.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_ADD_CONDITION
*&---------------------------------------------------------------------*
FORM f_add_condition  USING    fs_kond  TYPE zwmst004x
                               fu_no fu_kond
                      CHANGING fc_count.
  DATA : lv_no(3).

  lv_no = fu_no.
  CONDENSE lv_no NO-GAPS.
  ADD 1 TO fc_count.

  CASE fc_count.
    WHEN 1.
      CONCATENATE lv_no fu_kond INTO fs_kond-kond01
      SEPARATED BY space.
    WHEN 2.
      CONCATENATE lv_no fu_kond INTO fs_kond-kond02
      SEPARATED BY space.
    WHEN 3.
      CONCATENATE lv_no fu_kond INTO fs_kond-kond03
      SEPARATED BY space.
  ENDCASE.

  IF fc_count = 3.
    APPEND fs_kond TO gt_kond.
    CLEAR : fs_kond, fc_count.
  ENDIF.
ENDFORM.                    " F_ADD_CONDITION

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_004
*&---------------------------------------------------------------------*
FORM f_validate_004 .
  DATA : lt_ltap  TYPE STANDARD TABLE OF ltap,
         ls_ltap  LIKE LINE OF lt_ltap,
         lt_004   TYPE STANDARD TABLE OF zwmdt004,
         ls_004   LIKE LINE OF lt_004,
         ls_plant LIKE LINE OF gt_plant.

  READ TABLE gt_plant INTO ls_plant
                      WITH KEY werks = pa_werks.
  lt_004[] = gt_004[].
  SORT lt_004 BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_004 COMPARING tanum.
  IF lt_004[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_004
      WHERE lgnum = ls_plant-lgnum
        AND tanum = lt_004-tanum.

    LOOP AT lt_004 INTO ls_004.
      CLEAR ls_ltap.
      READ TABLE lt_ltap INTO ls_ltap
                         WITH KEY tanum = ls_004-tanum.
      IF sy-subrc = 0.
        IF ls_ltap-vorga = 'ST' OR
          ls_ltap-vorga = 'SL'.
          DELETE TABLE gt_004 FROM ls_004.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_VALIDATE_004

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  CASE 'X'.
    WHEN radio1 OR radio2.
      IF pa_werks IS INITIAL.
        PERFORM f_error_message USING 'PWE' ''.
      ENDIF.
    WHEN radio6.
      IF pa_lgnum IS INITIAL.
        PERFORM f_error_message USING 'PLG' ''.
      ENDIF.
      IF pa_mjahr IS INITIAL.
        PERFORM f_error_message USING 'PMJ' ''.
      ENDIF.
      IF pa_lfsnr IS INITIAL.
        PERFORM f_error_message USING 'PLF' ''.
      ENDIF.
    WHEN OTHERS.
      IF pa_lgnum IS INITIAL.
        PERFORM f_error_message USING 'PLG' ''.
      ENDIF.
      IF radio7 IS INITIAL.
        IF pa_lfsnr IS INITIAL.
          PERFORM f_error_message USING 'PLF' ''.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_TL
*&---------------------------------------------------------------------*
FORM f_get_data_tl .
  DATA : lt_007   TYPE STANDARD TABLE OF zwmdt007.

  CASE 'X'.
    WHEN radio3.
      SELECT *
        FROM zwmdt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        WHERE lgnum = pa_lgnum
          AND catyp = 'V'
          AND ebeln IN so_ebel2
          AND bastno = space
*          AND ( newch = 'X' OR zero = 'X' OR rusak = 'X' OR
*                menge_l <> 0 OR
*                menge_k <> 0 OR
*                menge_r <> 0 )
          AND lfsnr = space.

      lt_007[] = gt_007[].
      SORT lt_007 BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_007 COMPARING ebeln.
      IF lt_007[] IS NOT INITIAL.
        PERFORM f_get_purchasing_document TABLES lt_007.
      ENDIF.

      lt_007[] = gt_007[].
      SORT lt_007 BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_007 COMPARING matnr.
      IF lt_007[] IS NOT INITIAL.
        SELECT *
          FROM makt
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_007
          WHERE matnr = lt_007-matnr
            AND spras = sy-langu.
      ENDIF.

    WHEN radio4.
      SELECT *
        FROM zwmdt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        WHERE lgnum = pa_lgnum
          AND catyp = 'J'
          AND ebeln IN so_vbeln
*          AND ( newch = 'X' OR zero = 'X' OR rusak = 'X' OR
*                menge_l <> 0 OR
*                menge_k <> 0 OR
*                menge_r <> 0 )
          AND lfsnr = space.

      lt_007[] = gt_007[].
      SORT lt_007 BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_007 COMPARING ebeln.
      IF lt_007[] IS NOT INITIAL.
        PERFORM f_get_delivery TABLES lt_007.
      ENDIF.

    WHEN radio5.
      SELECT *
        FROM zwmdt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        WHERE lgnum = pa_lgnum
          AND catyp = '7'
          AND ebeln IN so_inbdn
*          AND ( newch = 'X' OR zero = 'X' OR rusak = 'X' OR
*                menge_l <> 0 OR
*                menge_k <> 0 OR
*                menge_r <> 0 )
          AND lfsnr = space.

      lt_007[] = gt_007[].
      SORT lt_007 BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_007 COMPARING ebeln.
      IF lt_007[] IS NOT INITIAL.
        PERFORM f_get_delivery TABLES lt_007.
      ENDIF.

    WHEN radio6.
      SELECT *
        FROM zwmdt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        WHERE lgnum = pa_lgnum
          AND catyp = 'R'
          AND ebeln IN so_mblnr
*          AND ( newch = 'X' OR zero = 'X' OR rusak = 'X' OR
*                menge_l <> 0 OR
*                menge_k <> 0 OR
*                menge_r <> 0 )
          AND lfsnr = space.

      lt_007[] = gt_007[].
      SORT lt_007 BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_007 COMPARING ebeln.
      IF lt_007[] IS NOT INITIAL.
        PERFORM f_get_material_document TABLES lt_007.
      ENDIF.

    WHEN radio7.
      SELECT *
        FROM zwmdt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        WHERE lgnum = pa_lgnum
          AND bastno IN so_bastn.

      PERFORM f_get_jumlah_produk.
  ENDCASE.

  lt_007[] = gt_007[].
  SORT lt_007 BY lgnum tanum.
  DELETE ADJACENT DUPLICATES FROM lt_007 COMPARING lgnum tanum.
  IF lt_007[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
      FOR ALL ENTRIES IN lt_007
      WHERE lgnum = lt_007-lgnum
        AND tanum = lt_007-tanum.
  ENDIF.
ENDFORM.                    " F_GET_DATA_TL

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_TL
*&---------------------------------------------------------------------*
FORM f_process_data_tl .
  DATA : lt_x007  TYPE STANDARD TABLE OF zwmdt007,
         ls_x007  LIKE LINE OF lt_x007,
         lt_y007  TYPE STANDARD TABLE OF zwmdt007,
         ls_y007  LIKE LINE OF lt_x007,
         lt_s007  TYPE STANDARD TABLE OF zwmdt007,
         ls_s007  LIKE LINE OF lt_s007,
         lt_head  TYPE STANDARD TABLE OF zwmst004,
         ls_007   LIKE LINE OF gt_007,
         ls_head  LIKE LINE OF gt_head,
         ls_plant LIKE LINE OF gt_plant,
         ls_detl  LIKE LINE OF gt_detl,
         ls_makt  LIKE LINE OF gt_makt,
         ls_kond  LIKE LINE OF gt_kond,
         ls_ltap  LIKE LINE OF gt_ltap.

  DATA : lv_flag,
         lv_menge  TYPE ekpo-menge,
         lv_count  TYPE i,
         lv_no     TYPE i,
         lv_zdtsul TYPE sy-datum,
         lv_subrc  TYPE sy-subrc.

  lt_x007[] = gt_007[].
  SORT lt_x007 BY ebeln matnr.
  DELETE ADJACENT DUPLICATES FROM lt_x007 COMPARING ebeln matnr.
  lt_y007[] = lt_x007[].
  SORT lt_y007 BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_y007 COMPARING ebeln.

  LOOP AT gt_007 INTO ls_007.
    ls_s007-ebeln   = ls_007-ebeln.
    ls_s007-matnr   = ls_007-matnr.
    ls_s007-charg   = ls_007-charg.
    ls_s007-meins   = ls_007-meins.
    ls_s007-newch   = ls_007-newch.
    ls_s007-zero    = ls_007-zero.
    ls_s007-rusak   = ls_007-rusak.
    ls_s007-catyp   = ls_007-catyp.

    IF ls_007-newch = 'X'.
      ls_s007-menge   = ls_007-menge.
      COLLECT ls_s007 INTO lt_s007.
      CLEAR ls_s007-newch.
    ENDIF.
    IF ls_007-menge_l <> 0.
      ls_s007-menge   = ls_007-menge_l.
      ls_s007-newch   = 'X'.
      COLLECT ls_s007 INTO lt_s007.
      CLEAR ls_s007-newch.
    ENDIF.
    IF ls_007-zero = 'X'.
      ls_s007-menge   = ls_007-menge.
      COLLECT ls_s007 INTO lt_s007.
      CLEAR ls_s007-zero.
    ENDIF.
    IF ls_007-menge_k <> 0.
      ls_s007-menge   = ls_007-menge_k.
      ls_s007-menge_k = ls_007-menge_k.
      ls_s007-zero    = 'X'.
      COLLECT ls_s007 INTO lt_s007.
      CLEAR ls_s007-zero.
    ENDIF.
    IF ls_007-rusak = 'X'.
      ls_s007-menge   = ls_007-menge.
      COLLECT ls_s007 INTO lt_s007.
      CLEAR ls_s007-rusak.
    ENDIF.
    IF ls_007-menge_r <> 0.
      ls_s007-menge   = ls_007-menge_r.
      ls_s007-rusak   = 'X'.
      COLLECT ls_s007 INTO lt_s007.
      CLEAR ls_s007-rusak.
    ENDIF.
    CLEAR ls_s007.
  ENDLOOP.

  LOOP AT lt_y007 INTO ls_y007.
    LOOP AT lt_x007 INTO ls_x007 WHERE ebeln = ls_y007-ebeln.
      CASE 'X'.
        WHEN radio3.
          PERFORM f_ekko_read USING ls_x007-ebeln
                              CHANGING lv_zdtsul lv_subrc.
        WHEN radio4 OR radio5 OR radio6.
          lv_zdtsul = ls_x007-gstri.
        WHEN radio7.
          IF ls_x007-catyp = 'V'.
            PERFORM f_ekko_read USING ls_x007-ebeln
                                CHANGING lv_zdtsul lv_subrc.
          ELSE.
            lv_zdtsul = ls_x007-gstri.
          ENDIF.
      ENDCASE.

      IF lv_subrc = 0.
        ls_head-lgnum   = ls_x007-lgnum.
        ls_head-tknum   = ls_x007-ebeln.
        ls_head-noreg   = ls_x007-bastno.
        ls_head-zdtsul  = lv_zdtsul.
        READ TABLE gt_ltap INTO ls_ltap INDEX 1.
        IF sy-subrc = 0.
          ls_head-werks   = ls_ltap-werks.
        ENDIF.
        READ TABLE gt_plant INTO ls_plant
                            WITH KEY werks = ls_head-werks.
        IF sy-subrc = 0.
          ls_head-name1   = ls_plant-name1.
        ENDIF.

        CLEAR ls_s007.
        LOOP AT lt_s007 INTO ls_s007 WHERE ebeln = ls_x007-ebeln
                                       AND matnr = ls_x007-matnr.
          ADD 1 TO lv_no.
          ls_detl-no      = lv_no.
          ls_detl-tknum   = ls_s007-ebeln.
          ls_detl-matnr   = ls_s007-matnr.
          CLEAR ls_makt.
          READ TABLE gt_makt INTO ls_makt
                             WITH KEY matnr = ls_s007-matnr.
          IF sy-subrc = 0.
            ls_detl-maktx   = ls_makt-maktx.
          ENDIF.
          ls_detl-charg   = ls_s007-charg.

          IF lv_flag IS INITIAL.
            CASE 'X'.
              WHEN radio3.
                lv_flag = 'X'.
                PERFORM f_ekpo_read USING ls_s007-ebeln ls_s007-matnr
                                    CHANGING lv_menge.
              WHEN radio4 OR radio5.
                PERFORM f_lips_read USING ls_s007-ebeln ls_s007-matnr ls_s007-charg
                                    CHANGING lv_menge.
              WHEN radio6.
                PERFORM f_mseg_read USING ls_s007-ebeln ls_s007-matnr ls_s007-charg
                                    CHANGING lv_menge.
              WHEN radio7.
                CASE ls_s007-catyp.
                  WHEN 'V'.
                    lv_flag = 'X'.
                    PERFORM f_ekpo_read USING ls_s007-ebeln ls_s007-matnr
                                        CHANGING lv_menge.
                  WHEN 'J' OR '7'.
                    PERFORM f_lips_read USING ls_s007-ebeln ls_s007-matnr ls_s007-charg
                                        CHANGING lv_menge.
                  WHEN 'R'.
                    PERFORM f_mseg_read USING ls_s007-ebeln ls_s007-matnr ls_s007-charg
                                        CHANGING lv_menge.
                ENDCASE.
            ENDCASE.
          ELSE.
            CLEAR lv_menge.
          ENDIF.

          IF lv_menge IS NOT INITIAL.
            WRITE lv_menge TO ls_detl-value UNIT ls_x007-meins.
          ENDIF.

          IF ls_s007-newch IS NOT INITIAL.
            WRITE ls_s007-menge TO ls_detl-abnormal UNIT ls_x007-meins.
            ls_kond-lgnum = ls_detl-lgnum.
            ls_kond-tknum = ls_detl-tknum.
            PERFORM f_add_condition USING ls_kond ls_detl-no 'LEBIH'
                                    CHANGING lv_count.
            ls_head-more = 'X'.
          ELSEIF ls_s007-rusak IS NOT INITIAL.
            WRITE ls_s007-menge TO ls_detl-abnormal UNIT ls_x007-meins.
            ls_kond-lgnum = ls_detl-lgnum.
            ls_kond-tknum = ls_detl-tknum.
            PERFORM f_add_condition USING ls_kond ls_detl-no 'RUSAK'
                                    CHANGING lv_count.
            ls_head-rusak = 'X'.
          ELSEIF ls_s007-zero IS NOT INITIAL.
            CASE 'X'.
              WHEN radio3.
                IF ls_s007-menge_k <> 0.
                  WRITE ls_s007-menge TO ls_detl-abnormal UNIT ls_x007-meins.
                ENDIF.
              WHEN radio4 OR radio6.
                IF ls_s007-menge_k <> 0.
                  WRITE ls_s007-menge TO ls_detl-abnormal UNIT ls_x007-meins.
                ELSE.
                  WRITE lv_menge TO ls_detl-abnormal UNIT ls_x007-meins.
                ENDIF.
            ENDCASE.
            ls_kond-lgnum = ls_detl-lgnum.
            ls_kond-tknum = ls_detl-tknum.
            PERFORM f_add_condition USING ls_kond ls_detl-no 'KURANG'
                                    CHANGING lv_count.
            ls_head-less = 'X'.
          ENDIF.

          APPEND ls_detl TO gt_detl.
          CLEAR ls_detl.
        ENDLOOP.
      ENDIF.

      CLEAR : lv_menge, lv_count.

      IF ls_kond IS NOT INITIAL.
        APPEND ls_kond TO gt_kond.
        CLEAR ls_kond.
      ENDIF.
    ENDLOOP.

    CASE 'X'.
      WHEN radio3.
        ls_head-head01  = 'PO'.
      WHEN radio4.
        ls_head-head01  = 'DN'.
      WHEN radio5.
        ls_head-head01  = 'INBOUND'.
      WHEN radio6.
        ls_head-head01  = 'MATDOC'.
    ENDCASE.
    APPEND ls_head TO gt_head.
    CLEAR ls_head.
  ENDLOOP.

  LOOP AT gt_head INTO ls_head.
    gs_head-lgnum   = ls_head-lgnum.
    gs_head-werks   = ls_head-werks.
    gs_head-name1   = ls_head-name1.
    gs_head-head01  = ls_head-head01.
    gs_head-zdtsul  = ls_head-zdtsul.
    IF ls_head-less IS NOT INITIAL.
      gs_head-less    = ls_head-less.
    ENDIF.
    IF ls_head-more IS NOT INITIAL.
      gs_head-more    = ls_head-more.
    ENDIF.
    IF ls_head-rusak IS NOT INITIAL.
      gs_head-rusak    = ls_head-rusak.
    ENDIF.
    gs_head-lfsnr   = pa_lfsnr.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_TL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen  USING    fu_retfield fu_dynprofield.
  TYPES : BEGIN OF ty_f4,
            number TYPE ekko-ebeln,
          END OF ty_f4.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval,
         lt_f407    TYPE STANDARD TABLE OF zwmdt007,
         ls_f407    LIKE LINE OF lt_f407,
         lt_f4      TYPE STANDARD TABLE OF ty_f4,
         ls_f4      LIKE LINE OF lt_f4.

  DATA : lv_subrc     TYPE sy-subrc,
         lv_mess(100).

  CASE fu_retfield.
    WHEN 'NUMBER'.
      SELECT *
        FROM zwmdt007
        INTO CORRESPONDING FIELDS OF TABLE lt_f407
        WHERE catyp = 'V'.
  ENDCASE.

  SORT lt_f407 BY ebeln.
  LOOP AT lt_f407 INTO ls_f407.
    ls_f4-number = ls_f407-ebeln.
    COLLECT ls_f4 INTO lt_f4.
    CLEAR ls_f4.
  ENDLOOP.
  IF lt_f4[] IS NOT INITIAL.
    SORT lt_f4 BY number.
    DELETE ADJACENT DUPLICATES FROM lt_f4 COMPARING number.
    ASSIGN lt_f4[] TO <fs_tab>.
  ENDIF.

  IF <fs_tab> IS ASSIGNED.
    PERFORM f_get_request TABLES return_tab
                          USING fu_retfield fu_dynprofield.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_REQUEST
*&---------------------------------------------------------------------*
FORM f_get_request  TABLES   return_tab STRUCTURE ddshretval
                    USING    fu_retfield fu_dynprofield.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.
ENDFORM.                    " F_GET_REQUEST

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_EKKO_READ
*&---------------------------------------------------------------------*
FORM f_ekko_read  USING    fu_ebeln
                  CHANGING fc_zdtsul fc_subrc.

  DATA : ls_ekko  LIKE LINE OF gt_ekko.

  CLEAR : ls_ekko, fc_subrc.
  READ TABLE gt_ekko INTO ls_ekko
                     WITH KEY ebeln = fu_ebeln.

  fc_subrc = sy-subrc.
  IF fc_subrc = 0.
    fc_zdtsul = ls_ekko-bedat.
  ENDIF.
ENDFORM.                    " F_EKKO_READ

*&---------------------------------------------------------------------*
*&      Form  F_EKPO_READ
*&---------------------------------------------------------------------*
FORM f_ekpo_read  USING    fu_ebeln fu_matnr
                  CHANGING fc_menge.
  DATA : ls_ekpo    LIKE LINE OF gt_ekpo.

  LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = fu_ebeln
                                 AND matnr = fu_matnr.
    ADD ls_ekpo-menge TO fc_menge.
  ENDLOOP.
ENDFORM.                    " F_EKPO_READ

*&---------------------------------------------------------------------*
*&      Form  F_LIPS_READ
*&---------------------------------------------------------------------*
FORM f_lips_read  USING    fu_vbeln fu_matnr fu_charg
                  CHANGING fc_menge.

  DATA : ls_lips    LIKE LINE OF gt_lips.

  CLEAR fc_menge.
  LOOP AT gt_lips INTO ls_lips WHERE vbeln = fu_vbeln
                                 AND matnr = fu_matnr
                                 AND charg = fu_charg.
    ADD ls_lips-lfimg TO fc_menge.
  ENDLOOP.
ENDFORM.                    " F_LIPS_READ

*&---------------------------------------------------------------------*
*&      Form  F_MSEG_READ
*&---------------------------------------------------------------------*
FORM f_mseg_read  USING    fu_mblnr fu_matnr fu_charg
                  CHANGING fc_menge.
  DATA : ls_mseg    LIKE LINE OF gt_mseg.

  CLEAR fc_menge.
  LOOP AT gt_mseg INTO ls_mseg WHERE mblnr = fu_mblnr
                                 AND mjahr = pa_mjahr
                                 AND matnr = fu_matnr
                                 AND charg = fu_charg.
    ADD ls_mseg-menge TO fc_menge.
  ENDLOOP.
ENDFORM.                    " F_MSEG_READ

*&---------------------------------------------------------------------*
*&      Form  F_GET_JUMLAH_PRODUK
*&---------------------------------------------------------------------*
FORM f_get_jumlah_produk .
  DATA : lt_007 TYPE STANDARD TABLE OF zwmdt007,
         lt_v   TYPE STANDARD TABLE OF zwmdt007,
         lt_r   TYPE STANDARD TABLE OF zwmdt007,
         lt_j   TYPE STANDARD TABLE OF zwmdt007.

  lt_v[] = lt_r[] = lt_j[] = gt_007[].
  DELETE lt_v WHERE catyp <> 'V'.
  DELETE lt_r WHERE catyp <> 'R'.
  DELETE lt_j WHERE catyp <> 'J'.

  IF lt_v[] IS NOT INITIAL.
    PERFORM f_get_purchasing_document TABLES lt_v.
  ENDIF.

  IF lt_r[] IS NOT INITIAL.
    PERFORM f_get_material_document TABLES lt_r.
  ENDIF.

  IF lt_j[] IS NOT INITIAL.
    PERFORM f_get_delivery TABLES lt_j.
  ENDIF.
ENDFORM.                    " F_GET_JUMLAH_PRODUK

*&---------------------------------------------------------------------*
*&      Form  F_GET_PURCHASING_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_purchasing_document  TABLES   ft_007 STRUCTURE zwmdt007.
  SELECT *
    FROM ekko
    INTO CORRESPONDING FIELDS OF TABLE gt_ekko
    FOR ALL ENTRIES IN ft_007
    WHERE ebeln = ft_007-ebeln.

  SELECT *
    FROM ekpo
    INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
    FOR ALL ENTRIES IN ft_007
    WHERE ebeln = ft_007-ebeln.
ENDFORM.                    " F_GET_PURCHASING_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DELIVERY
*&---------------------------------------------------------------------*
FORM f_get_delivery  TABLES   ft_007 STRUCTURE zwmdt007.
  SELECT *
    FROM lips
    INTO CORRESPONDING FIELDS OF TABLE gt_lips
    FOR ALL ENTRIES IN ft_007
    WHERE vbeln = ft_007-ebeln.
ENDFORM.                    " F_GET_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_material_document  TABLES   ft_007 STRUCTURE zwmdt007.
  SELECT *
    FROM mseg
    INTO CORRESPONDING FIELDS OF TABLE gt_mseg
    FOR ALL ENTRIES IN ft_007
    WHERE mblnr = ft_007-ebeln
      AND mjahr = pa_mjahr.
ENDFORM.                    " F_GET_MATERIAL_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM_TL
*&---------------------------------------------------------------------*
FORM f_print_form_tl .
  DATA : lv_formname       TYPE tdsfname,
         lv_funcname       TYPE tdsfname,
         ls_control_option TYPE ssfctrlop,
         ls_output_option  TYPE ssfcompop.

  DATA : ls_head LIKE LINE OF gt_head,
         ls_detl LIKE LINE OF gt_detl,
         lt_detl TYPE STANDARD TABLE OF zwmst004,
         lt_kond TYPE STANDARD TABLE OF zwmst004x,
         ls_kond LIKE LINE OF lt_kond.

  lv_formname = 'ZWM_SF001'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

*  LOOP AT gt_head INTO ls_head.
*    AT FIRST.
*      ls_control_option-no_close = 'X'.
*    ENDAT.
*
*    AT LAST.
*      ls_control_option-no_close = space.
*    ENDAT.

  IF pa_proc IS NOT INITIAL.
    ls_control_option-no_dialog = 'X'.
    ls_output_option-tdnewid    = 'X'.
    ls_output_option-tdimmed    = 'X'.
    ls_output_option-tddelete   = ''.
  ENDIF.

  IF pa_prev IS INITIAL.
    ls_output_option-tdnoprev   = 'X'.
  ELSE.
    ls_output_option-tdnoprint  = 'X'.
  ENDIF.

  gs_head-nopol = 'X'.

  IF gs_head-noreg IS INITIAL.
    PERFORM f_get_next_number USING '' ''
                              CHANGING gs_head-noreg.
  ENDIF.

  CLEAR : lt_detl[].
  LOOP AT gt_detl INTO ls_detl.
    APPEND ls_detl TO lt_detl.
    CLEAR ls_detl.
  ENDLOOP.

  CLEAR : lt_kond[].
  LOOP AT gt_kond INTO ls_kond.
    APPEND ls_kond TO lt_kond.
    CLEAR ls_kond.
  ENDLOOP.

  CALL FUNCTION lv_funcname
    EXPORTING
      control_parameters = ls_control_option
      output_options     = ls_output_option
      gs_head            = gs_head
    TABLES
      gt_detl            = lt_detl
      gt_kond            = lt_kond
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

*    ls_control_option-no_open = 'X'.
*  ENDLOOP.
ENDFORM.                    " F_PRINT_FORM_TL

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_TLX
*&---------------------------------------------------------------------*
FORM f_process_data_tlx .
  DATA : ls_007   LIKE LINE OF gt_007,
         lt_s007  TYPE STANDARD TABLE OF zwmdt007,
         ls_s007  LIKE LINE OF lt_s007,
         lt_x007  TYPE STANDARD TABLE OF zwmdt007,
         ls_x007  LIKE LINE OF lt_x007,
         ls_head  LIKE LINE OF gt_head,
         ls_ltap  LIKE LINE OF gt_ltap,
         ls_plant LIKE LINE OF gt_plant,
         ls_detl  LIKE LINE OF gt_detl,
         ls_makt  LIKE LINE OF gt_makt,
         lt_xkond TYPE STANDARD TABLE OF zwmst004x,
         ls_xkond LIKE LINE OF lt_xkond,
         ls_kond  LIKE LINE OF gt_kond.

  DATA : lv_menge  TYPE ekpo-menge,
         lv_xmenge TYPE ekpo-menge,
         lv_no     TYPE i,
         lv_count  TYPE i.

  SORT gt_007 BY matnr charg.
  LOOP AT gt_007 INTO ls_007.
    ls_x007-matnr     = ls_007-matnr.
    ls_x007-charg     = ls_007-charg.
    ls_x007-meins     = ls_007-meins.
    ls_x007-menge     = ls_007-menge.
    ls_x007-menge_r   = ls_007-menge_r.
    ls_x007-menge_k   = ls_007-menge_k.
    ls_x007-menge_l   = ls_007-menge_l.
    IF ls_007-newch IS NOT INITIAL.
      ls_x007-menge_l   = ls_007-menge.
    ENDIF.
    IF ls_007-rusak IS NOT INITIAL.
      ls_x007-menge_r   = ls_007-menge.
    ENDIF.
    COLLECT ls_x007 INTO lt_x007.
    CLEAR ls_x007.
  ENDLOOP.

  LOOP AT lt_x007 INTO ls_x007.
    IF ls_x007-menge_r IS NOT INITIAL.
      gs_head-rusak   = 'X'.
      ADD 1 TO lv_no.
      PERFORM f_add_detail USING lv_no ls_x007-matnr ls_x007-charg 'RUSAK'
                                 ls_x007-meins ls_x007-menge ls_x007-menge_r.
    ENDIF.
    IF ls_x007-menge_k IS NOT INITIAL.
      gs_head-less   = 'X'.
      ADD 1 TO lv_no.
      PERFORM f_add_detail USING lv_no ls_x007-matnr ls_x007-charg 'KURANG'
                                 ls_x007-meins ls_x007-menge ls_x007-menge_k.
    ENDIF.
    IF ls_x007-menge_l IS NOT INITIAL.
      gs_head-more   = 'X'.
      ADD 1 TO lv_no.
      PERFORM f_add_detail USING lv_no ls_x007-matnr ls_x007-charg 'LEBIH'
                                 ls_x007-meins ls_x007-menge ls_x007-menge_l.
    ENDIF.

    gs_head-lgnum   = ls_x007-lgnum.
    gs_head-noreg   = ls_x007-bastno.
    gs_head-lfsnr   = pa_lfsnr.
    gs_head-zdtsul  = sy-datum.
    READ TABLE gt_ltap INTO ls_ltap INDEX 1.
    IF sy-subrc = 0.
      gs_head-werks   = ls_ltap-werks.
    ENDIF.
    READ TABLE gt_plant INTO ls_plant
                        WITH KEY werks = gs_head-werks.
    IF sy-subrc = 0.
      gs_head-name1   = ls_plant-name1.
    ENDIF.

    CASE 'X'.
      WHEN radio3.
        ls_head-head01  = 'PO'.
      WHEN radio4.
        ls_head-head01  = 'DN'.
      WHEN radio5.
        ls_head-head01  = 'INBOUND'.
      WHEN radio6.
        ls_head-head01  = 'MATDOC'.
    ENDCASE.
  ENDLOOP.

  lt_xkond[] = gt_kond[].
  CLEAR gt_kond[].
  LOOP AT lt_xkond INTO ls_xkond.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        ls_kond-kond01  = ls_xkond-kond01.
      WHEN 2.
        ls_kond-kond02  = ls_xkond-kond01.
      WHEN 3.
        ls_kond-kond03  = ls_xkond-kond01.
    ENDCASE.
    IF lv_count = 3.
      APPEND ls_kond TO gt_kond.
      CLEAR : ls_kond, lv_count.
    ENDIF.
  ENDLOOP.

  IF ls_kond IS NOT INITIAL.
    APPEND ls_kond TO gt_kond.
    CLEAR ls_kond.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA_TLX

*&---------------------------------------------------------------------*
*&      Form  F_ADD_DETAIL
*&---------------------------------------------------------------------*
FORM f_add_detail  USING    fu_no fu_matnr fu_charg fu_condition fu_meins
                            fu_menge fu_xmenge.
  DATA : ls_detl LIKE LINE OF gt_detl,
         ls_makt LIKE LINE OF gt_makt,
         ls_kond LIKE LINE OF gt_kond.

  ls_detl-no      = fu_no.
  ls_detl-matnr   = fu_matnr.
  ls_detl-charg   = fu_charg.
  CLEAR ls_makt.
  READ TABLE gt_makt INTO ls_makt
                     WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    ls_detl-maktx   = ls_makt-maktx.
  ENDIF.

  IF fu_menge IS NOT INITIAL.
    WRITE fu_menge TO ls_detl-value UNIT fu_meins.
  ENDIF.

  IF fu_xmenge IS NOT INITIAL.
    WRITE fu_xmenge TO ls_detl-abnormal UNIT fu_meins.
    APPEND ls_detl TO gt_detl.
  ENDIF.

  CONDENSE ls_detl-no NO-GAPS.
  CONCATENATE ls_detl-no fu_condition INTO ls_kond-kond01
  SEPARATED BY space.
  APPEND ls_kond TO gt_kond.
  CLEAR ls_detl.
ENDFORM.                    " F_ADD_DETAIL
