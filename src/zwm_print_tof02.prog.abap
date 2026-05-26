*&---------------------------------------------------------------------*
*&  Include           ZWM_PRINT_TOF02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_48
*&---------------------------------------------------------------------*
FORM f_get_data_48 .
  DATA : lt_ltak LIKE gt_ltak OCCURS 0,
         lt_ltap LIKE gt_ltap OCCURS 0.

  IF pa_akhir IS INITIAL.
    SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
      vbeln tapri queue lgtor refnr bwlvs tbnum
      FROM ltak
      INTO TABLE gt_ltak
      WHERE lgnum = pa_lgnum
        AND tanum IN so_tanum
        AND bdatu IN so_bdatu
        AND mblnr IN so_mblnr
        AND kquit = space
        AND lznum = space.
  ELSE.
    SELECT lgnum tanum bdatu bzeit mblnr mjahr benum drukz druck lznum
      vbeln tapri queue lgtor refnr bwlvs tbnum
      FROM ltak
      INTO TABLE gt_ltak
      WHERE lgnum = pa_lgnum
        AND tanum IN so_tanum
        AND bdatu IN so_bdatu
        AND mblnr IN so_mblnr
        AND kquit = 'X'
        AND lznum = space.
  ENDIF.

  lt_ltak[] = gt_ltak[].
  SORT lt_ltak BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_ltak COMPARING vbeln.
  IF lt_ltak[] IS NOT INITIAL.
    SELECT *
      FROM likp JOIN kna1 ON likp~kunnr = kna1~kunnr
                JOIN adrc ON kna1~adrnr = adrc~addrnumber
      INTO CORRESPONDING FIELDS OF TABLE gt_likp
      FOR ALL ENTRIES IN lt_ltak
      WHERE likp~vbeln = lt_ltak-vbeln.

    CASE pa_lgnum.
      WHEN '190'.
      WHEN OTHERS.
        SELECT *
          FROM vttp
          INTO CORRESPONDING FIELDS OF TABLE gt_vttp
          FOR ALL ENTRIES IN lt_ltak
          WHERE vbeln = lt_ltak-vbeln.
    ENDCASE.

    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
      FOR ALL ENTRIES IN gt_ltak
      WHERE lgnum = gt_ltak-lgnum
        AND tanum = gt_ltak-tanum
        AND nltyp IN so_lgtyp.

    lt_ltap[] = gt_ltap[].
    SORT lt_ltap BY matnr lgnum vltyp vlpla.
    DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING matnr lgnum vltyp vlpla.
    IF lt_ltap[] IS NOT INITIAL.
      SELECT *
        FROM zprint_to_view
        INTO CORRESPONDING FIELDS OF TABLE it_mat_gr
        FOR ALL ENTRIES IN lt_ltap
        WHERE matnr = lt_ltap-matnr
          AND lgnum = lt_ltap-lgnum
          AND lgtyp = lt_ltap-vltyp
          AND lgpla = lt_ltap-vlpla.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_48
*&---------------------------------------------------------------------*
FORM f_process_data_48 .
  DATA : ls_out  LIKE LINE OF gt_out,
         ls_ltak LIKE LINE OF gt_ltak,
         ls_ltap LIKE LINE OF gt_ltap,
         ls_likp LIKE LINE OF gt_likp,
         ls_vttp LIKE LINE OF gt_vttp.

  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout.

  DATA : lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl.

  DATA : lv_flag,
         lv_tknum  TYPE vttk-tknum.

  LOOP AT gt_ltak INTO ls_ltak.
    ls_out-lgnum = ls_ltak-lgnum.
    ls_out-tanum = ls_ltak-tanum.
    ls_out-queue = ls_ltak-queue.
    ls_out-lgtor = ls_ltak-lgtor.
    ls_out-druck = ls_ltak-druck.
    ls_out-tapri = ls_ltak-tapri.
    ls_out-lznum = ls_ltak-lznum.
    ls_out-mblnr = ls_ltak-mblnr.
    ls_out-bdatu = ls_ltak-bdatu.
    ls_out-bzeit = ls_ltak-bzeit.
    ls_out-bwlvs = ls_ltak-bwlvs.

    LOOP AT gt_ltap INTO ls_ltap WHERE lgnum = ls_ltak-lgnum
                                   AND tanum = ls_ltak-tanum.
      ls_out-vltyp = ls_ltap-vltyp.
      ls_out-vlpla = ls_ltap-vlpla.
      ls_out-nltyp = ls_ltap-nltyp.
      ls_out-nlpla = ls_ltap-nlpla.
      ls_out-vsola = ls_ltap-vsola.
      ls_out-nista = ls_ltap-nista.
      ls_out-altme = ls_ltap-altme.
      ls_out-matnr = ls_ltap-matnr.
      ls_out-maktx = ls_ltap-maktx.

      CLEAR : ls_likp, lv_tknum.
      READ TABLE gt_likp INTO ls_likp
                         WITH KEY vbeln = ls_ltak-vbeln.
      IF sy-subrc = 0.
        IF ls_likp-kunnr IN so_kunnr.
          ls_out-kunnr  = ls_likp-kunnr.
          ls_out-name1  = ls_likp-name1.
          ls_out-route  = ls_likp-route.
          CASE pa_lgnum.
            WHEN '190'.
              lv_tknum  = ls_likp-lifex.
            WHEN OTHERS.
              CLEAR ls_vttp.
              READ TABLE gt_vttp INTO ls_vttp
                                 WITH KEY vbeln = ls_ltak-vbeln.
              IF sy-subrc = 0.
                lv_tknum = ls_vttp-tknum.
              ENDIF.
          ENDCASE.
          IF lv_tknum IN so_tknum.
            ls_out-tknum = lv_tknum.
          ELSE.
            CONTINUE.
          ENDIF.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE it_mat_gr INTO DATA(ls_mat_gr)
                           WITH KEY matnr = ls_ltap-matnr
                                    lgnum = ls_ltap-lgnum
                                    lgtyp = ls_ltap-vltyp
                                    lgpla = ls_ltap-vlpla.
      IF sy-subrc = 0.
        ls_out-matkl = ls_mat_gr-matkl.
        ls_out-kober = ls_mat_gr-kober.
      ENDIF.

      APPEND ls_out TO gt_out.
      CLEAR ls_ltap.
    ENDLOOP.
  ENDLOOP.

  CLEAR : ls_out.

  IF so_kunnr[] IS INITIAL AND
    so_tknum[] IS INITIAL.
    SORT gt_out BY kunnr tanum matnr.
    lt_xout[] = gt_out[].
    SORT lt_xout BY tanum.
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tanum.
    IF lt_xout[] IS NOT INITIAL.
      LOOP AT lt_xout INTO ls_xout.
        CLEAR lv_flag.
        LOOP AT gt_out INTO ls_out WHERE tanum = ls_xout-tanum.
          IF lv_flag IS NOT INITIAL.
            ls_stylerow-fieldname = 'CHECK'.
            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_stylerow TO ls_out-style.
            MODIFY gt_out FROM ls_out TRANSPORTING style.
          ENDIF.
          lv_flag = 'X'.
          CLEAR : ls_out-style[], ls_stylerow.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ELSEIF so_kunnr[] IS NOT INITIAL.
    SORT gt_out BY kunnr tanum matnr.
    lt_xout[] = gt_out[].
    SORT lt_xout BY tanum.
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tanum.
    IF lt_xout[] IS NOT INITIAL.
      LOOP AT lt_xout INTO ls_xout.
        CLEAR lv_flag.
        LOOP AT gt_out INTO ls_out WHERE tanum = ls_xout-tanum.
          IF lv_flag IS NOT INITIAL.
            ls_stylerow-fieldname = 'CHECK'.
            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_stylerow TO ls_out-style.
            MODIFY gt_out FROM ls_out TRANSPORTING style.
          ENDIF.
          lv_flag = 'X'.
          CLEAR : ls_out-style[], ls_stylerow.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ELSEIF so_tknum[] IS NOT INITIAL.
    SORT gt_out BY kunnr tknum kober tanum matnr.
    lt_xout[] = gt_out[].
    SORT lt_xout BY tknum.
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum.
    IF lt_xout[] IS NOT INITIAL.
      LOOP AT lt_xout INTO ls_xout.
        CLEAR lv_flag.
        LOOP AT gt_out INTO ls_out WHERE tknum = ls_xout-tknum.
          IF lv_flag IS NOT INITIAL.
            ls_stylerow-fieldname = 'CHECK'.
            ls_stylerow-style     = cl_gui_alv_grid=>mc_style_disabled.
            APPEND ls_stylerow TO ls_out-style.
            MODIFY gt_out FROM ls_out TRANSPORTING style.
          ENDIF.
          lv_flag = 'X'.
          CLEAR : ls_out-style[], ls_stylerow.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM_48
*&---------------------------------------------------------------------*
FORM f_print_form_48  USING    fu_ucomm.
  DATA : lt_xout TYPE STANDARD TABLE OF ty_out,
         ls_xout LIKE LINE OF lt_xout,
         lt_yout TYPE STANDARD TABLE OF ty_out,
         ls_yout LIKE LINE OF lt_xout,
         lt_zout TYPE STANDARD TABLE OF ty_out,
         ls_zout LIKE LINE OF lt_xout,
         ls_out  LIKE LINE OF gt_out,
         lt_015  TYPE STANDARD TABLE OF zwmdt015,
         ls_015  LIKE LINE OF lt_015.

  DATA : lv_number TYPE numc15,
         lv_lznum  TYPE ltak-lznum,
         lv_subrc  TYPE sy-subrc.

  lt_zout[] = lt_yout[] = lt_xout[] = gt_out[].
  DELETE lt_xout WHERE check = space.

  IF lt_xout[] IS NOT INITIAL.
    CASE fu_ucomm.
      WHEN '&POS'.
        DELETE lt_xout WHERE lznum = space.
        IF lt_xout[] IS NOT INITIAL.
          PERFORM f_print_48 USING 'ZMF_GRP_PICKLIST' 'X'.
        ELSE.
          MESSAGE s000(zab) WITH 'No data print' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN '&PREV'.
        DELETE lt_xout WHERE lznum = space.
        IF lt_xout[] IS NOT INITIAL.
          PERFORM f_print_48 USING 'ZMF_GRP_PICKLIST' ''.
        ELSE.
          MESSAGE s000(zab) WITH 'No data print' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN '&GRP'.
        IF so_tknum[] IS INITIAL.
          DATA: temp_vltyp TYPE ltap-vltyp,
                temp_vlpla TYPE ltap-vlpla.
          LOOP AT lt_xout INTO ls_xout.
            DELETE lt_zout WHERE nlpla = ls_xout-nlpla.
          ENDLOOP.
          LOOP AT lt_zout INTO ls_zout.
            DELETE lt_yout WHERE nlpla = ls_zout-nlpla.
          ENDLOOP.
          SORT lt_yout BY vltyp vlpla.
*          LOOP AT lt_xout INTO ls_xout.
          LOOP AT lt_yout ASSIGNING FIELD-SYMBOL(<fs_out2>). "GROUP BY <fs_out2>-queue.
            IF <fs_out2>-vltyp IS NOT INITIAL AND <fs_out2>-vlpla IS NOT INITIAL.
*              IF <fs_out2>-vlpla(3) = 'FLC'.
*                CONTINUE.
*              ELSE.
              IF temp_vltyp NE <fs_out2>-vltyp OR temp_vlpla NE <fs_out2>-vlpla.
                temp_vltyp = <fs_out2>-vltyp.
                temp_vlpla = <fs_out2>-vlpla.
                PERFORM f_get_num2 CHANGING number.
                <fs_out2>-lznum = number.
                MODIFY gt_out FROM <fs_out2>
                 TRANSPORTING lznum
                 WHERE vltyp = <fs_out2>-vltyp
                 AND vlpla = <fs_out2>-vlpla
                 AND nlpla = <fs_out2>-nlpla.
                TRY.
                    UPDATE ltak SET lznum = <fs_out2>-lznum WHERE lgnum = <fs_out2>-lgnum AND tanum = <fs_out2>-tanum.
                  CATCH cx_sy_open_sql_db.
                    sy-subrc = 4.
                ENDTRY.
                IF sy-subrc = 0.
                  COMMIT WORK AND WAIT.
                ENDIF.
              ELSEIF temp_vltyp = <fs_out2>-vltyp AND temp_vlpla = <fs_out2>-vlpla.
                <fs_out2>-lznum = number.
                MODIFY gt_out FROM <fs_out2>
                 TRANSPORTING lznum
                 WHERE vltyp = <fs_out2>-vltyp
                 AND vlpla = <fs_out2>-vlpla
                 AND nlpla = <fs_out2>-nlpla.
                TRY.
                    UPDATE ltak SET lznum = <fs_out2>-lznum WHERE lgnum = <fs_out2>-lgnum AND tanum = <fs_out2>-tanum.
                  CATCH cx_sy_open_sql_db.
                    sy-subrc = 4.
                ENDTRY.
                IF sy-subrc = 0.
                  COMMIT WORK AND WAIT.
                ENDIF.
*                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
*            MODIFY gt_out FROM <fs_out2>
*             TRANSPORTING lznum
*             WHERE vltyp = <fs_out2>-vltyp
*             AND vlpla = <fs_out2>-vlpla
*             AND nlpla = <fs_out2>-nlpla.
*          ENDLOOP.
*        IF so_tknum[] IS INITIAL.
*          PERFORM f_get_next_number CHANGING lv_number lv_subrc.
*          IF lv_subrc = 0.
*            LOOP AT lt_xout INTO ls_xout.
*              PERFORM f_check_grouping USING ls_xout-lgnum ls_xout-tanum
*                                       CHANGING lv_subrc.
*              IF lv_subrc = 0.
*                ls_xout-lznum = lv_number.
*                CONDENSE ls_xout-lznum NO-GAPS.
*                MODIFY gt_out FROM ls_xout
*                              TRANSPORTING lznum
*                              WHERE lgnum = ls_xout-lgnum
*                                AND tanum = ls_xout-tanum.
*
*                IF gv_testrun IS INITIAL.
*                  TRY.
*                      UPDATE ltak SET lznum = ls_xout-lznum
*                                      lgbzo = ls_xout-lgbzo
*                                  WHERE lgnum = ls_xout-lgnum
*                                    AND tanum = ls_xout-tanum.
*                    CATCH cx_sy_open_sql_db.
*                  ENDTRY.
*                ENDIF.
*
*                CLEAR : ls_xout.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
        ELSE.
*          DATA: temp_vltyp TYPE ltap-vltyp,
*                temp_vlpla TYPE ltap-vlpla.
          LOOP AT lt_xout INTO ls_xout.
            DELETE lt_zout WHERE nlpla = ls_xout-nlpla.
          ENDLOOP.
          LOOP AT lt_zout INTO ls_zout.
            DELETE lt_yout WHERE nlpla = ls_zout-nlpla.
          ENDLOOP.
          SORT lt_yout BY vltyp vlpla.
*          LOOP AT lt_xout INTO ls_xout.
          LOOP AT lt_yout ASSIGNING FIELD-SYMBOL(<fs_out3>). "GROUP BY <fs_out2>-queue.
            IF <fs_out3>-vltyp IS NOT INITIAL AND <fs_out3>-vlpla IS NOT INITIAL.
*              IF <fs_out3>-vlpla(3) = 'FLC'.
*                CONTINUE.
*              ELSE.
              IF temp_vltyp NE <fs_out3>-vltyp OR temp_vlpla NE <fs_out3>-vlpla.
                temp_vltyp = <fs_out3>-vltyp.
                temp_vlpla = <fs_out3>-vlpla.
                PERFORM f_get_num2 CHANGING number.
                <fs_out3>-lznum = number.
                MODIFY gt_out FROM <fs_out3>
                 TRANSPORTING lznum
                 WHERE vltyp = <fs_out3>-vltyp
                 AND vlpla = <fs_out3>-vlpla
                 AND nlpla = <fs_out3>-nlpla.
                TRY.
                    UPDATE ltak SET lznum = <fs_out3>-lznum WHERE lgnum = <fs_out3>-lgnum AND tanum = <fs_out3>-tanum.
                  CATCH cx_sy_open_sql_db.
                    sy-subrc = 4.
                ENDTRY.
                IF sy-subrc = 0.
                  COMMIT WORK AND WAIT.
                ENDIF.
              ELSEIF temp_vltyp = <fs_out3>-vltyp AND temp_vlpla = <fs_out3>-vlpla.
                <fs_out3>-lznum = number.
                MODIFY gt_out FROM <fs_out3>
                 TRANSPORTING lznum
                 WHERE vltyp = <fs_out3>-vltyp
                 AND vlpla = <fs_out3>-vlpla
                 AND nlpla = <fs_out3>-nlpla.
                TRY.
                    UPDATE ltak SET lznum = <fs_out3>-lznum WHERE lgnum = <fs_out3>-lgnum AND tanum = <fs_out3>-tanum.
                  CATCH cx_sy_open_sql_db.
                    sy-subrc = 4.
                ENDTRY.
                IF sy-subrc = 0.
                  COMMIT WORK AND WAIT.
                ENDIF.
              ENDIF.
*              ENDIF.
            ENDIF.
          ENDLOOP.
*            MODIFY gt_out FROM <fs_out3>
*TRANSPORTING lznum
*WHERE vltyp = <fs_out3>-vltyp
*AND vlpla = <fs_out3>-vlpla
*AND nlpla = <fs_out3>-nlpla.
*          ENDLOOP.
*          SORT lt_xout BY tknum.
*          DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum.
*          SORT lt_yout BY tknum kober.
*          DELETE ADJACENT DUPLICATES FROM lt_yout COMPARING tknum kober.
*          SORT lt_zout BY tknum kober queue.
*          DELETE ADJACENT DUPLICATES FROM lt_zout COMPARING tknum kober queue.
*          DATA(gt_out_lpick) = gt_out[].
*          DELETE gt_out_lpick WHERE queue <> 'LPICK'.
*          DATA(gt_out_other) = gt_out[].
*          DELETE gt_out_other WHERE queue = 'LPICK'.
*          DATA: temp_nlpla TYPE ltap-nlpla.
*          LOOP AT lt_xout INTO ls_xout.
*            LOOP AT lt_yout INTO ls_yout WHERE tknum = ls_xout-tknum.
*              LOOP AT lt_zout INTO ls_zout WHERE tknum = ls_yout-tknum
*                                             AND kober = ls_yout-kober.
**                PERFORM f_get_next_number CHANGING lv_number lv_subrc.
*                IF lv_subrc = 0.
*                  IF pa_lgnum = 'C40' AND pa_drukz = '48'.
*                    IF ls_zout-queue = 'LPICK'.
*                      LOOP AT gt_out_lpick INTO ls_out WHERE queue = ls_zout-queue.
*                        IF temp_nlpla <> ls_out-nlpla.
*                          temp_nlpla = ls_out-nlpla.
*                          PERFORM f_get_next_number CHANGING lv_number lv_subrc.
*                        ELSE.
**                          ls_out-lznum = lv_number.
*                        ENDIF.
*                        ls_out-lznum = lv_number.
*                        CONDENSE ls_out-lznum NO-GAPS.
*                        MODIFY gt_out FROM ls_out
*                                      TRANSPORTING lznum
*                                      WHERE lgnum = ls_out-lgnum
*                                        AND tanum = ls_out-tanum
*                                        AND queue = ls_out-queue.
*
*                        IF gv_testrun IS INITIAL.
*                          TRY.
*                              UPDATE ltak SET lznum = ls_out-lznum
*                                              lgbzo = ls_out-lgbzo
*                                          WHERE lgnum = ls_out-lgnum
*                                            AND tanum = ls_out-tanum.
*                            CATCH cx_sy_open_sql_db.
*                          ENDTRY.
*                        ENDIF.
*
*
*                        CLEAR : ls_out.
*                      ENDLOOP.
*                    ELSE.
*                      PERFORM f_get_next_number CHANGING lv_number lv_subrc.
*                      LOOP AT gt_out_other INTO ls_out WHERE tknum = ls_zout-tknum
*                             AND kober = ls_zout-kober
*                             AND queue = ls_zout-queue.
*                        ls_out-lznum = lv_number.
*                        CONDENSE ls_out-lznum NO-GAPS.
*                        MODIFY gt_out FROM ls_out
*                                      TRANSPORTING lznum
*                                      WHERE lgnum = ls_out-lgnum
*                                        AND tanum = ls_out-tanum
*                                        AND queue = ls_out-queue.
*
*                        IF gv_testrun IS INITIAL.
*                          TRY.
*                              UPDATE ltak SET lznum = ls_out-lznum
*                                              lgbzo = ls_out-lgbzo
*                                          WHERE lgnum = ls_out-lgnum
*                                            AND tanum = ls_out-tanum.
*                            CATCH cx_sy_open_sql_db.
*                          ENDTRY.
*                        ENDIF.
*
*                        CLEAR : ls_out.
*                      ENDLOOP.
*                    ENDIF.
*                  ELSE.
*                    LOOP AT gt_out INTO ls_out WHERE tknum = ls_zout-tknum
*                                                 AND kober = ls_zout-kober
*                                                 AND queue = ls_zout-queue.
*                      ls_out-lznum = lv_number.
*                      CONDENSE ls_out-lznum NO-GAPS.
*                      MODIFY gt_out FROM ls_out
*                                    TRANSPORTING lznum
*                                    WHERE lgnum = ls_out-lgnum
*                                      AND tanum = ls_out-tanum.
*
*                      IF gv_testrun IS INITIAL.
*                        TRY.
*                            UPDATE ltak SET lznum = ls_out-lznum
*                                            lgbzo = ls_out-lgbzo
*                                        WHERE lgnum = ls_out-lgnum
*                                          AND tanum = ls_out-tanum.
*                          CATCH cx_sy_open_sql_db.
*                        ENDTRY.
*                      ENDIF.
*
*                      CLEAR : ls_out.
*                    ENDLOOP.
*                  ENDIF.
*                ENDIF.
*              ENDLOOP.
*            ENDLOOP.
*            ls_015-tknum  = ls_xout-tknum.
*            ls_015-lgbzo  = gv_lgbzo.
*            APPEND ls_015 TO lt_015.
*            TRY.
*                INSERT zwmdt015 FROM TABLE lt_015.
*              CATCH cx_sy_open_sql_db.
*            ENDTRY.
*          ENDLOOP.
        ENDIF.
    ENDCASE.
  ELSE.
    MESSAGE s000(zab) WITH 'No data process' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_48
*&---------------------------------------------------------------------*
FORM f_print_48  USING    fu_tdform fu_print.
  DATA : lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         ls_header          TYPE zmfindpick,
         lt_detail          TYPE STANDARD TABLE OF zmfindpick,
         ls_detail          LIKE LINE OF lt_detail,
         lt_temp            TYPE STANDARD TABLE OF ty_out,
         lt_xout            TYPE STANDARD TABLE OF ty_out,
         ls_xout            LIKE LINE OF lt_xout,
         ls_out             LIKE LINE OF gt_out,
         ls_t329d           LIKE LINE OF gt_t329d,
         lt_to              TYPE STANDARD TABLE OF zwmst008.

  DATA : l_funcname TYPE tdsfname,
         lv_close.

  CASE pa_lgnum.
    WHEN '190'.
      lv_close  = 'X'.
    WHEN OTHERS.
      lv_close  = 'X'.
  ENDCASE.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_tdform
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  SELECT SINGLE lnumt
    FROM t300t
    INTO ls_header-company
    WHERE spras EQ sy-langu
      AND lgnum EQ pa_lgnum.

  TRANSLATE ls_header-company TO UPPER CASE.
  ls_header-drukz = pa_drukz.

  IF pa_druck IS NOT INITIAL.
    ls_header-reprint = 'REPRINT'.
  ENDIF.

  ls_header-group = 'X'.

  IF fu_print IS INITIAL.
    IF pa_druck IS INITIAL.
      lwa_output_option-tdnoprint = 'X'.
    ENDIF.
  ELSE.
    lwa_output_option-tdnoprev = 'X'.
  ENDIF.

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE check = space.
  DELETE lt_xout WHERE lznum = space.
  SORT lt_xout BY lznum.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING lznum.

  .
  LOOP AT lt_xout INTO ls_xout.
    LOOP AT gt_out INTO ls_out WHERE check = space
                                 AND tknum = ls_xout-tknum
*                                   AND lznum NE space.
                                 AND lznum = ls_xout-lznum.
      APPEND INITIAL LINE TO lt_temp ASSIGNING FIELD-SYMBOL(<fs_temp>).
      MOVE-CORRESPONDING ls_out TO <fs_temp>.
    ENDLOOP.
  ENDLOOP.
  IF lt_temp[] IS NOT INITIAL.
    APPEND LINES OF lt_temp TO lt_xout.
    SORT lt_xout BY tknum lznum.
    DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tknum lznum.
  ENDIF.
*  ENDIF.

  LOOP AT lt_xout INTO ls_xout.
    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      IF lv_close IS NOT INITIAL.
        lwa_control_option-no_close = space.
      ENDIF.
    ENDAT.

    ls_header-lgnum = ls_xout-lgnum.
    ls_header-kunnr = ls_xout-kunnr.
*    ls_header-name1 = ls_xout-name1.
    ls_header-route = ls_xout-route.
    SELECT SINGLE bezei
      FROM tvrot
      INTO ls_header-bezei
      WHERE spras EQ sy-langu AND
            route EQ ls_xout-route.

    CLEAR : ls_t329d.
    READ TABLE gt_t329d INTO ls_t329d
                        WITH KEY nltyp = ls_xout-nltyp.
    IF sy-subrc = 0.
      lwa_output_option-tddest    = ls_t329d-ldest.
    ELSE.
      lwa_output_option-tddest    = default-spld.
    ENDIF.

    ls_header-lznum = ls_xout-lznum.
    ls_header-bdatu = ls_xout-bdatu.
    ls_header-bzeit = ls_xout-bzeit.
    ls_header-bwlvs = ls_xout-bwlvs.

    CASE pa_lgnum.
      WHEN 'C40'.
        CASE ls_xout-kober.
          WHEN 'ZNA'.
            ls_header-xzona = 'FOOD'.
          WHEN 'ZNB'.
            ls_header-xzona = 'NON FOOD'.
        ENDCASE.
        IF gv_lbzot IS INITIAL.
          SELECT SINGLE lbzot
            FROM t30ct
            INTO gv_lbzot
            WHERE spras = sy-langu
              AND lgnum = ls_xout-lgnum
              AND lgbzo = ls_xout-lgbzo.
*          ls_header-lgbzo = ls_xout-lgbzo.
*          ls_header-queue = ls_xout-queue.
          ls_header-lbzot = gv_lbzot.
        ENDIF.
    ENDCASE.
    ls_header-lgbzo = ls_xout-lgbzo.
    ls_header-queue = ls_xout-queue.
    IF ls_header-queue = 'LPICK'.
      ls_header-vbeln = ls_xout-vbeln.
      ls_header-name1 = ls_xout-name1.
    ELSE.
      ls_header-vbeln = space.
      ls_header-name1 = space.
    ENDIF.
    PERFORM f_prepare_main_48 TABLES lt_detail
                              USING ls_xout-lznum
                              CHANGING ls_header-total.

    PERFORM f_prepare_footer USING ls_xout-tknum
                             CHANGING ls_header-shipno ls_header-zona
                                      ls_header-pickgrp ls_header-delvno.

* Get Picking Group
    DATA(lr_lznum) = VALUE rseloption( FOR wa_out IN gt_out ( sign = 'I'
                                                              option = 'EQ'
                                                              low = wa_out-lznum ) ).
    SORT lr_lznum BY low.
    DELETE ADJACENT DUPLICATES FROM lr_lznum COMPARING low.
    CLEAR ls_header-pickgrp.
    LOOP AT lr_lznum INTO DATA(ls_lznum).
      IF ls_header-pickgrp IS INITIAL.
        ls_header-pickgrp = ls_lznum-low+10(5).
      ELSE.
        ls_header-pickgrp = |{ ls_header-pickgrp }| & |, | & |{ ls_lznum-low+10(5) }|.
      ENDIF.
    ENDLOOP.

    DATA(lv_total) = REDUCE char3( INIT i TYPE int1 FOR wa_lznum IN lr_lznum
                                   NEXT i = i + 1 ).
    CONDENSE lv_total.
    READ TABLE lr_lznum WITH KEY low = ls_xout-lznum
                        TRANSPORTING NO FIELDS.

    DATA(lv_line) = ls_header-vltyp.
    WRITE sy-tabix TO lv_line.
    CONDENSE lv_line.

**    Add L for loose pick in reprint
*    IF pa_lgnum = 'C40'.
*      ls_header-vltyp = ls_xout-vltyp.
*      IF ls_header-vltyp(1) = 'L'.
*        CONCATENATE 'L/' ls_header-reprint INTO ls_header-reprint.
*      ELSE.
*        ls_header-reprint = 'REPRINT'.
*      ENDIF.
*    ENDIF.

    ls_header-counter = |{ lv_line }| & | / | & |{ lv_total }|.

* Get Delivery No
    DATA(lr_vbeln) = VALUE rseloption( FOR wa_out IN gt_out ( sign = 'I'
                                                              option = 'EQ'
                                                              low = wa_out-vbeln ) ).
    SORT lr_vbeln BY low.
    DELETE ADJACENT DUPLICATES FROM lr_vbeln COMPARING low.
    CLEAR ls_header-delvno.
    LOOP AT lr_vbeln INTO DATA(ls_vbeln).
      IF ls_header-delvno IS INITIAL.
        ls_header-delvno = ls_vbeln-low.
      ELSE.
        ls_header-delvno = |{ ls_header-delvno }| & |, | & |{ ls_vbeln-low }|.
      ENDIF.
    ENDLOOP.


    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = space
        gs_head            = ls_header
      TABLES
        gt_detl            = lt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    lwa_control_option-no_open = 'X'.
  ENDLOOP.

  IF lv_close IS INITIAL.
    PERFORM f_prepare_lampiran TABLES lt_to.
    PERFORM f_lampiran_to_number TABLES lt_to
                                 USING 'ZMF_IND_PICKLIST_LAMPIRAN'
                                       lwa_control_option
                                       lwa_output_option
                                       ls_header.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_MAIN_48
*&---------------------------------------------------------------------*
FORM f_prepare_main_48  TABLES   ft_detail STRUCTURE zmfindpick
                        USING    fu_lznum
                        CHANGING fc_total.
  DATA : lt_xout   TYPE STANDARD TABLE OF ty_out,
         ls_xout   LIKE LINE OF lt_xout,
         ls_detail TYPE zmfindpick,
         ls_ltap   LIKE LINE OF gt_ltap,
         ls_out    LIKE LINE OF gt_out,
         lt_xltap  LIKE gt_ltap OCCURS 0,
         ls_xltap  LIKE LINE OF gt_ltap.

  DATA : lv_tvsola TYPE ltap-vsola,
         lv_umrez  TYPE marm-umrez,
         lv_mod    TYPE p DECIMALS 0,
         lv_div    TYPE p DECIMALS 0,
         lv_carton TYPE p DECIMALS 0,
         lv_receh  TYPE p DECIMALS 0,
         lv_t1(20),
         lv_t2(20).

  CLEAR : ft_detail[].

  lt_xout[] = gt_out[].
  DELETE lt_xout WHERE lznum <> fu_lznum.
  SORT lt_xout BY tanum.
  DELETE ADJACENT DUPLICATES FROM lt_xout COMPARING tanum.
*        SORT gt_ltap BY tanum matnr charg vlpla.
  SORT gt_ltap BY matnr charg vlpla.
  lt_xltap[] = gt_ltap[].
*        DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum matnr charg vlpla.
  SORT lt_xltap BY tanum matnr charg vlpla.
  "  DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING tanum matnr charg vlpla.
  LOOP AT lt_xout INTO ls_xout WHERE lznum = fu_lznum.
    LOOP AT lt_xltap INTO ls_xltap WHERE tanum = ls_xout-tanum.
      ls_detail-matnr = ls_xltap-matnr.
      ls_detail-charg = ls_xltap-charg.
      ls_detail-vfdat = ls_xltap-vfdat.
      ls_detail-maktx = ls_xltap-maktx.
      ls_detail-vltyp = ls_xltap-vltyp.
      ls_detail-vlber = ls_xltap-vlber.
      ls_detail-vlpla = ls_xltap-vlpla.
      ls_detail-altme = ls_xltap-altme.

      ls_detail-lgnum = ls_xltap-lgnum.

      IF ls_detail-lgnum = 'C40'.
        ls_detail-nltyp = ls_xltap-nltyp.
        ls_detail-nlber = ls_xltap-nlber.
        "        ls_detail-nlpla = ls_xltap-nlpla.
      ENDIF.

      CLEAR : ls_ltap, lv_tvsola.
**      LOOP AT gt_ltap INTO ls_ltap WHERE tanum = ls_xltap-tanum
**                                     and matnr = ls_xltap-matnr
**                                     AND charg = ls_xltap-charg
**                                     AND vlpla = ls_xltap-vlpla.
**        ADD ls_ltap-vsola TO lv_tvsola.
**      ENDLOOP.
      ls_detail-vsola = ls_xltap-vsola. "lv_tvsola. "
      COLLECT ls_detail INTO ft_detail.
      CLEAR: ls_detail, ls_xltap.
    ENDLOOP.
  ENDLOOP.

  SORT ft_detail BY vlpla.
  LOOP AT ft_detail INTO ls_detail.
    CLEAR : lv_umrez.
    SELECT SINGLE umrez
      FROM marm
      INTO lv_umrez
      WHERE matnr = ls_detail-matnr
        AND meinh = 'KAR'.

    IF sy-subrc = 0.
      CLEAR : lv_mod, lv_div.
      WRITE ls_detail-vsola TO ls_detail-tvsola UNIT ls_detail-altme.
      WRITE lv_umrez TO ls_detail-satuan DECIMALS 0.
      lv_mod    = ls_detail-vsola MOD lv_umrez.
      lv_div    = ls_detail-vsola DIV lv_umrez.
      ls_detail-carton  = lv_div.
      CONDENSE ls_detail-carton NO-GAPS.
      ls_detail-receh   = lv_mod.
      MODIFY ft_detail FROM ls_detail TRANSPORTING tvsola satuan carton receh.
      ADD lv_div TO lv_carton.
      ADD lv_mod TO lv_receh.
    ENDIF.
  ENDLOOP.

  lv_t1 = lv_carton.
  CONDENSE lv_t1 NO-GAPS.
  lv_t2 = lv_receh.
  CONDENSE lv_t2 NO-GAPS.
  fc_total = |{ lv_t1 } { 'CAR' } { lv_t2 } { 'PC' }|.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_STAGING
*&---------------------------------------------------------------------*
FORM f_get_staging .
  CALL SCREEN 101 STARTING AT 10 10.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  F4_LGBZO  INPUT
*&---------------------------------------------------------------------*
MODULE f4_lgbzo INPUT.
  PERFORM f_f4_lgbzo.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  F_F4_LGBZO
*&---------------------------------------------------------------------*
FORM f_f4_lgbzo .
  TYPES : BEGIN OF ty_t30ct,
            lgbzo TYPE t30ct-lgbzo,
            lbzot TYPE t30ct-lbzot,
          END OF ty_t30ct.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         lt_t30ct   TYPE STANDARD TABLE OF ty_t30ct,
         ls_t30ct   LIKE LINE OF lt_t30ct,
         lt_015     TYPE STANDARD TABLE OF zwmdt015,
         ls_015     LIKE LINE OF lt_015,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_subrc TYPE sy-subrc,
         lv_lgbzo TYPE ltak-lgbzo.

  SELECT *
    FROM zwmdt015
    INTO CORRESPONDING FIELDS OF TABLE lt_015.

  SELECT *
    FROM t30ct
    INTO CORRESPONDING FIELDS OF TABLE lt_t30ct
    WHERE spras = sy-langu
      AND lgnum = pa_lgnum.

  LOOP AT lt_t30ct INTO ls_t30ct.
    CLEAR ls_015.
    READ TABLE lt_015 INTO ls_015
                      WITH KEY lgbzo = ls_t30ct-lgbzo.
    IF sy-subrc = 0.
      TRY.
          DELETE lt_t30ct WHERE lgbzo = ls_t30ct-lgbzo.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
    ENDIF.
  ENDLOOP.
  ASSIGN lt_t30ct[] TO <fs_tab>.
  PERFORM f_value_request TABLES return_tab
                          USING 'LGBZO' 'GV_LGBZO'
                          CHANGING lv_subrc.

  IF return_tab[] IS NOT INITIAL.
    READ TABLE return_tab INTO ls_return INDEX 1.
    lv_lgbzo = ls_return-fieldval.
    READ TABLE lt_t30ct INTO ls_t30ct
                        WITH KEY lgbzo = lv_lgbzo.
    IF sy-subrc = 0.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GV_LGBZO' lv_lgbzo ''.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GV_LBZOT' ls_t30ct-lbzot ''.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SHIPMENT_COUNT
*&---------------------------------------------------------------------*
FORM f_shipment_count CHANGING fc_subrc.
  TYPES : BEGIN OF ty_vttk,
            tknum TYPE vttk-tknum,
          END OF ty_vttk.

  DATA : lt_vttk    TYPE STANDARD TABLE OF ty_vttk.

  DATA : lv_count   TYPE i.

  SELECT tknum
    FROM vttk
    INTO TABLE lt_vttk
    WHERE tknum IN so_tknum.

  DESCRIBE TABLE lt_vttk LINES lv_count.
  IF lv_count > 1.
    fc_subrc = 4.
    PERFORM f_error_message USING 'STK' '' 'Proses hanya per 1 Shipment'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_PARAMETER
*&---------------------------------------------------------------------*
FORM f_submit_parameter  TABLES   rspar_tab STRUCTURE rsparams
                         USING    fu_selname fu_value fu_kind.
  DATA : rspar_line     TYPE rsparams.

  rspar_line-selname = fu_selname.
  rspar_line-kind    = fu_kind.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = fu_value.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SHIPMENT_START
*&---------------------------------------------------------------------*
FORM f_shipment_start  CHANGING fc_subrc.
  DATA : lt_015   TYPE STANDARD TABLE OF zwmdt015.

  SELECT *
    FROM zwmdt015
    INTO CORRESPONDING FIELDS OF TABLE lt_015
      WHERE tknum IN so_tknum.
  IF sy-subrc = 0.
    fc_subrc = 4.
    PERFORM f_error_message USING 'STK' '' 'Belum Shipment Start'.
  ENDIF.
ENDFORM.

FORM f_get_num2 CHANGING number.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZCOLPRNTTO'
    IMPORTING
      number                  = number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      OTHERS                  = 7.
ENDFORM.
