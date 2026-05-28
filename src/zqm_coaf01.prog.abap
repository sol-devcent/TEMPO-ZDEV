*&---------------------------------------------------------------------*
*&  Include           ZQM_COAF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_qals  TYPE STANDARD TABLE OF qals,
         lv_lines TYPE i.

  SELECT *
    FROM qals
    INTO CORRESPONDING FIELDS OF TABLE gt_qals
    WHERE prueflos IN so_pruef.

  lt_qals[] = gt_qals[].
  SORT lt_qals BY werk.
  DELETE ADJACENT DUPLICATES FROM lt_qals COMPARING werk.
  DESCRIBE TABLE lt_qals LINES lv_lines.
  IF lv_lines > 1.
    gv_subrc = 1.
  ENDIF.

  IF gv_subrc IS INITIAL.
    IF lt_qals[] IS NOT INITIAL.
      SELECT *
        FROM qcvm
        INTO CORRESPONDING FIELDS OF TABLE gt_qcvm
        FOR ALL ENTRIES IN lt_qals
        WHERE ctyp    = pa_ctyp
          AND vorlnr  = pa_vorln
          AND version = pa_vers
          AND zaehler = lt_qals-werk.
    ENDIF.

    lt_qals[] = gt_qals[].
    SORT lt_qals BY matnr charg.
    DELETE ADJACENT DUPLICATES FROM lt_qals COMPARING matnr charg.
    IF lt_qals[] IS NOT INITIAL.
      SELECT *
        FROM mch1
        INTO CORRESPONDING FIELDS OF TABLE gt_mch1
        FOR ALL ENTRIES IN lt_qals
        WHERE matnr = lt_qals-matnr
          AND charg = lt_qals-charg.
    ENDIF.

    SORT lt_qals BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_qals COMPARING matnr.
    IF lt_qals[] IS NOT INITIAL.
      SELECT *
        FROM makt
        INTO CORRESPONDING FIELDS OF TABLE gt_makt
        FOR ALL ENTRIES IN lt_qals
        WHERE spras = pa_langu
          AND matnr = lt_qals-matnr.
    ENDIF.

    SELECT *
      FROM qamr
      INTO CORRESPONDING FIELDS OF TABLE gt_qamr
      FOR ALL ENTRIES IN gt_qals
      WHERE prueflos = gt_qals-prueflos
        AND maschine <> space.

    SELECT *
      FROM qasr
      INTO CORRESPONDING FIELDS OF TABLE gt_qasr
      FOR ALL ENTRIES IN gt_qals
      WHERE prueflos = gt_qals-prueflos
        AND maschine <> space.

    SELECT *
      FROM qase
      INTO CORRESPONDING FIELDS OF TABLE gt_qase
      FOR ALL ENTRIES IN gt_qals
      WHERE prueflos = gt_qals-prueflos
        AND maschine <> space.

    IF gt_qcvm[] IS NOT INITIAL.
      SELECT *
        FROM qpmt
        INTO CORRESPONDING FIELDS OF TABLE gt_qpmt
        FOR ALL ENTRIES IN gt_qcvm
        WHERE zaehler = gt_qcvm-zaehler
          AND mkmnr   = gt_qcvm-mkmnr
          AND sprache = pa_langu.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : char_requirements TYPE STANDARD TABLE OF bapi2045d1,
         inspoper_list     TYPE STANDARD TABLE OF bapi2045l2,
         ls_requirements   LIKE LINE OF char_requirements,
         ls_list           LIKE LINE OF inspoper_list,
         char_result       TYPE bapi2045d2,
         sample_result     TYPE bapi2045d3,
         single_results    TYPE STANDARD TABLE OF bapi2045d4,
         ls_qals           LIKE LINE OF gt_qals,
         ls_qamr           LIKE LINE OF gt_qamr,
         ls_qasr           LIKE LINE OF gt_qasr,
         ls_qase           LIKE LINE OF gt_qase,
         ls_makt           LIKE LINE OF gt_makt,
         ls_mch1           LIKE LINE OF gt_mch1,
         ls_head           LIKE LINE OF gt_head,
         ls_qcvm           LIKE LINE OF gt_qcvm,
         ls_qpmt           LIKE LINE OF gt_qpmt,
         ls_detl           LIKE LINE OF gt_detl,
         lv_char1(50),
         lv_char2(50),
         lv_inspoper.

  LOOP AT gt_qals INTO ls_qals.
    ls_head-langu     = pa_langu.
    ls_head-werk      = ls_qals-werk.
    ls_head-prueflos  = ls_qals-prueflos.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_qals-matnr.
    IF sy-subrc = 0.
      ls_head-maktx     = ls_makt-maktx.
    ENDIF.
    ls_head-matnr     = ls_qals-matnr.

    CASE 'X'.
      WHEN radio1.
        ls_head-charg     = ls_qals-charg.
      WHEN radio2.
        SPLIT ls_qals-charg AT space INTO lv_char1 lv_char2.
        ls_head-charg     = lv_char1.
    ENDCASE.

    CLEAR ls_mch1.
    READ TABLE gt_mch1 INTO ls_mch1
                       WITH KEY matnr = ls_qals-matnr
                                charg = ls_qals-charg.
    IF sy-subrc = 0.
      ls_head-hsdat     = ls_mch1-hsdat.
      ls_head-vfdat     = ls_mch1-vfdat.
    ENDIF.

    CLEAR ls_qamr.
    READ TABLE gt_qamr INTO ls_qamr INDEX 1.
    CLEAR : lv_char1, lv_char2.
    SPLIT ls_qamr-maschine AT '=' INTO lv_char1 lv_char2.
    IF lv_char2 IS NOT INITIAL.
      CONCATENATE lv_char2+6(4) lv_char2+3(2) lv_char2(2)
      INTO ls_head-zanld.
    ENDIF.

    IF ls_head-zanld IS INITIAL.
      CLEAR ls_qasr.
      READ TABLE gt_qasr INTO ls_qasr INDEX 1.
      CLEAR : lv_char1, lv_char2.
      SPLIT ls_qasr-maschine AT '=' INTO lv_char1 lv_char2.
      IF lv_char2 IS NOT INITIAL.
        CONCATENATE lv_char2+6(4) lv_char2+3(2) lv_char2(2)
        INTO ls_head-zanld.
      ENDIF.
    ENDIF.

    IF ls_head-zanld IS INITIAL.
      CLEAR ls_qase.
      READ TABLE gt_qase INTO ls_qase INDEX 1.
      CLEAR : lv_char1, lv_char2.
      SPLIT ls_qase-maschine AT '=' INTO lv_char1 lv_char2.
      IF lv_char2 IS NOT INITIAL.
        CONCATENATE lv_char2+6(4) lv_char2+3(2) lv_char2(2)
        INTO ls_head-zanld.
      ENDIF.
    ENDIF.

    IF pa_langu = sy-langu.
      ls_head-footer1 = 'Analyzed & Released by,'.
      ls_head-footer2 = 'Approved by,'.
      ls_head-footer3 = 'QC Manager'.
      ls_head-footer4 = 'QA Manager'.
    ELSE.
      ls_head-footer1 = 'Dianalisa & diluluskan oleh,'.
      ls_head-footer2 = 'Disetujui oleh,'.
      ls_head-footer3 = 'QC Manager'.
      ls_head-footer4 = 'QA Manager'.
    ENDIF.

    APPEND ls_head TO gt_head.

    CLEAR : inspoper_list[].
    CALL FUNCTION 'BAPI_INSPLOT_GETOPERATIONS'
      EXPORTING
        number        = ls_head-prueflos
      TABLES
        inspoper_list = inspoper_list.

    CLEAR : char_requirements[], single_results[], char_result, sample_result.
    LOOP AT inspoper_list INTO ls_list.
      CALL FUNCTION 'BAPI_INSPOPER_GETDETAIL'
        EXPORTING
          insplot                = ls_head-prueflos
          inspoper               = ls_list-inspoper
          read_char_requirements = 'X'
          char_filter_no         = space
        TABLES
          char_requirements      = char_requirements.

      IF char_requirements[] IS NOT INITIAL.
        LOOP AT char_requirements INTO ls_requirements.
          CLEAR ls_qcvm.
          READ TABLE gt_qcvm INTO ls_qcvm
                             WITH KEY mkmnr = ls_requirements-mstr_char.
          IF sy-subrc = 0.
            ls_detl-prueflos    = ls_head-prueflos.
            ls_detl-sortnr      = ls_qcvm-sortnr.
            ls_detl-char_descr  = ls_requirements-char_descr.
            IF ls_requirements-meas_unit IS INITIAL.
              ls_detl-meas_unit   = '-'.
            ELSE.
              ls_detl-meas_unit   = ls_requirements-meas_unit.
            ENDIF.
            ls_detl-lw_tol_lmt  = ls_requirements-lw_tol_lmt.
            ls_detl-up_tol_lmt  = ls_requirements-up_tol_lmt.

            CALL FUNCTION 'BAPI_INSPCHAR_GETRESULT'
              EXPORTING
                insplot        = ls_head-prueflos
                inspoper       = ls_requirements-inspoper
                inspchar       = ls_requirements-inspchar
                inspsample     = '000000'
              IMPORTING
                char_result    = char_result
                sample_result  = sample_result
              TABLES
                single_results = single_results.

            CASE ls_requirements-char_type.
              WHEN '01'.
                IF ls_requirements-target_val IS NOT INITIAL.
                  CONDENSE ls_requirements-target_val.
                  ls_detl-infofield3  = ls_requirements-target_val.
                ELSE.
                  CONDENSE ls_requirements-lw_tol_lmt NO-GAPS.
                  CONDENSE ls_requirements-up_tol_lmt NO-GAPS.

                  IF ls_requirements-lw_tol_lmt IS NOT INITIAL AND
                    ls_requirements-up_tol_lmt IS INITIAL.
                    CONCATENATE '>=' ls_requirements-lw_tol_lmt
                    INTO ls_detl-infofield3
                    SEPARATED BY space.
                  ELSEIF ls_requirements-lw_tol_lmt IS INITIAL AND
                    ls_requirements-up_tol_lmt IS NOT INITIAL.
                    CONCATENATE '<=' ls_requirements-up_tol_lmt
                    INTO ls_detl-infofield3
                    SEPARATED BY space.
                  ELSE.
                    CONCATENATE ls_requirements-lw_tol_lmt '-'
                                ls_requirements-up_tol_lmt
                           INTO ls_detl-infofield3
                    SEPARATED BY space.
                  ENDIF.
                ENDIF.

                IF ls_requirements-up_tol_lmt IS NOT INITIAL.
                  IF ls_requirements-mstr_char(1) = 'R'.
                    IF char_result-maximum IS NOT INITIAL AND
                      char_result-minimum IS NOT INITIAL.
                      PERFORM f_char_to_packed CHANGING : char_result-minimum,
                                                          char_result-maximum.
                      CONDENSE char_result-minimum NO-GAPS.
                      CONDENSE char_result-maximum NO-GAPS.
                      CONCATENATE char_result-minimum '-' char_result-maximum
                      INTO ls_detl-mean_value.
                    ELSE.
                      ls_detl-mean_value    = char_result-mean_value.
                      PERFORM f_char_to_packed CHANGING ls_detl-mean_value.
                      CONDENSE ls_detl-mean_value NO-GAPS.
                    ENDIF.
                  ELSE.
                    ls_detl-mean_value    = char_result-mean_value.
                    PERFORM f_char_to_packed CHANGING ls_detl-mean_value.
                    CONDENSE ls_detl-mean_value NO-GAPS.
                  ENDIF.
                ELSE.
                  ls_detl-mean_value    = char_result-mean_value.
                  PERFORM f_char_to_packed CHANGING ls_detl-mean_value.
                  CONDENSE ls_detl-mean_value NO-GAPS.
                ENDIF.

              WHEN '02'.
                CONDENSE ls_requirements-infofield3 NO-GAPS.
                IF pa_langu = sy-langu.
                  ls_detl-infofield3  = ls_requirements-infofield3.
                ELSE.
                  ls_detl-infofield3  = ls_requirements-infofield2.
                ENDIF.
                CASE char_result-evaluation.
                  WHEN 'A'.
                    IF pa_langu = sy-langu.
                      ls_detl-mean_value    = 'CONFIRM'.
                    ELSE.
                      ls_detl-mean_value    = 'SESUAI'.
                    ENDIF.
                  WHEN 'R'.
                    IF pa_langu = sy-langu.
                      ls_detl-mean_value    = 'NOT CONFIRM'.
                    ELSE.
                      ls_detl-mean_value    = 'TIDAK SESUAI'.
                    ENDIF.
                ENDCASE.
            ENDCASE.

            IF ls_detl-mean_value IS INITIAL.
              CONTINUE.
            ENDIF.

            IF pa_langu <> sy-langu.
              CLEAR ls_qpmt.
              READ TABLE gt_qpmt INTO ls_qpmt
                                 WITH KEY mkmnr = ls_requirements-mstr_char.
              IF sy-subrc = 0.
                ls_detl-char_descr = ls_qpmt-kurztext.
              ENDIF.
            ENDIF.
            APPEND ls_detl TO gt_detl.
            CLEAR ls_detl.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
    CLEAR ls_head.
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

  DATA : ls_head  LIKE LINE OF gt_head,
         ls_detl  LIKE LINE OF gt_detl,
         lt_xdetl TYPE STANDARD TABLE OF zqmstcoa,
         ls_xdetl LIKE LINE OF lt_xdetl.

  lv_formname = 'ZQMCOAF'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  gs_head-werk = gt_head[ 1 ]-werk.
  IF gs_head-werk = '1900'.
    CALL SELECTION-SCREEN 110 STARTING AT 10 5
                              ENDING AT   100  10.

    IF sy-subrc NE 0.
      STOP.
    ENDIF.
  ENDIF.

  LOOP AT gt_head INTO ls_head.
    AT FIRST.
      ls_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      ls_control_option-no_close = space.
    ENDAT.

*    IF p_disp IS INITIAL.
*      ls_output_option-tdnoprev   = 'X'.
*    ELSE.
*      ls_output_option-tdnoprint  = 'X'.
*    ENDIF.

    CLEAR : lt_xdetl[].
    SORT gt_detl BY sortnr.
    LOOP AT gt_detl INTO ls_detl WHERE prueflos = ls_head-prueflos.
      ls_xdetl-char_descr  = ls_detl-char_descr.
      ls_xdetl-meas_unit   = ls_detl-meas_unit.
      ls_xdetl-infofield3  = ls_detl-infofield3.
      ls_xdetl-mean_value  = ls_detl-mean_value.
      APPEND ls_xdetl TO lt_xdetl.
      CLEAR ls_xdetl.
    ENDLOOP.

    ls_head-qc_tdname  = gs_head-qc_tdname.
    ls_head-qc_jabatan = gs_head-qc_jabatan.
    ls_head-qc_name    = gs_head-qc_name.
    ls_head-pm_tdname  = gs_head-pm_tdname.
    ls_head-pm_jabatan = gs_head-pm_jabatan.
    ls_head-pm_name    = gs_head-pm_name.

    IF gs_head-werk = '1900'.
      ls_head-footer1 = 'Checked by,'.
    ENDIF.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ls_control_option
        output_options     = ls_output_option
        gs_head            = ls_head
      TABLES
        gt_detl            = lt_xdetl
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
*&      Form  F_OUTPUT_TYPE
*&---------------------------------------------------------------------*
FORM f_output_type .
  PERFORM f_get_data.
  IF gv_subrc IS INITIAL.
    PERFORM f_process_data.
    PERFORM f_print_form.
  ELSE.
    MESSAGE s000(zab) WITH 'Berbeda Plant'.
  ENDIF.
ENDFORM.                    " F_OUTPUT_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  IF so_pruef[] IS INITIAL.
    PERFORM f_error_message USING 'PPR' ''.
  ENDIF.
  IF pa_vorln IS INITIAL.
    PERFORM f_error_message USING 'PVO' ''.
  ENDIF.
  IF pa_ctyp IS INITIAL.
    PERFORM f_error_message USING 'PCT' ''.
  ENDIF.
  IF pa_vers IS INITIAL.
    PERFORM f_error_message USING 'PVE' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION-SCREEN

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

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_CHAR_TO_PACKED
*&---------------------------------------------------------------------*
FORM f_char_to_packed  CHANGING fc_value.
  DATA : lv_cvalue(22),
         lv_value(16)  TYPE p DECIMALS 3,
         result_tab    TYPE match_result_tab.

  lv_cvalue = fc_value.
  TRANSLATE lv_cvalue USING '. '.
  TRANSLATE lv_cvalue USING ',.'.
  CONDENSE lv_cvalue NO-GAPS.
  FIND ALL OCCURRENCES OF '.' IN lv_cvalue RESULTS result_tab.
  IF sy-subrc = 0.
    lv_value = lv_cvalue.
    WRITE lv_value TO fc_value DECIMALS 3.
  ENDIF.
ENDFORM.                    " F_CHAR_TO_PACKED

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING   fu_group fu_active fu_input fu_invisible
                              fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
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

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_SIGN
*&---------------------------------------------------------------------*
FORM f_get_sign  USING    fu_type
                 CHANGING fc_name.
  DATA: lt_return TYPE TABLE OF ddshretval.

  SELECT tdname, zjabatan, name_text INTO TABLE @DATA(lt_jabatan)
    FROM zhgqmdt001 WHERE werks = @gs_head-werk
                      AND zsign = @fu_type
    ORDER BY zjabatan.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TDNAME'
      value_org       = 'S'
    TABLES
      value_tab       = lt_jabatan
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  DATA(lw_ret) = lt_return[ 1 ].
  DATA(lw_jabatan) = lt_jabatan[ tdname = lw_ret-fieldval ].
  fc_name = lw_jabatan-name_text.

  CASE fu_type.
    WHEN '02'.
      gs_head-qc_tdname  = lw_jabatan-tdname.
      gs_head-qc_jabatan = lw_jabatan-zjabatan.
      gs_head-qc_name    = lw_jabatan-name_text.
    WHEN '03'.
      gs_head-pm_tdname  = lw_jabatan-tdname.
      gs_head-pm_jabatan = lw_jabatan-zjabatan.
      gs_head-pm_name    = lw_jabatan-name_text.
  ENDCASE.
ENDFORM.
