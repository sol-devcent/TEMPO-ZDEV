*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPF01                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_print_form.
  PERFORM f_free_memory.

ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_name1_plant LIKE t001w-name1,
        l_ort01_plant LIKE t001w-ort01.

  DATA : ls_charreq   LIKE LINE OF charreq.

* Get plant name.
  SELECT SINGLE name1 ort01
    FROM t001w
    INTO (l_name1_plant, l_ort01_plant)
    WHERE werks EQ pa_werk.

* Get header data from QALS
*{   REPLACE        P01K910379                                        1
*\  SELECT werk prueflos charg matnr stat35 ktextmat enstehdat entstezeit
*\         ersteldat gesstichpr einhprobe ersteller mblnr mjahr lifnr
*\         lichn plnty plnnr plnal gebeh prbnaverf anzgeb losmenge lagortchrg
*\    FROM qals
*\    INTO CORRESPONDING FIELDS OF TABLE i_hd
*\    WHERE prueflos IN so_pruef AND
*\          werk     EQ pa_werk  AND
*\          herkunft EQ pa_herku AND
*\          matnr    EQ pa_matnr." AND
*\*          stat35   NE space.
  SELECT werk prueflos charg matnr stat35 ktextmat enstehdat entstezeit
         ersteldat gesstichpr einhprobe ersteller mblnr mjahr lifnr
         lichn plnty plnnr plnal gebeh prbnaverf anzgeb losmenge lagortchrg
    FROM qals
    INTO CORRESPONDING FIELDS OF TABLE i_hd
    WHERE prueflos IN so_pruef AND
          werk     EQ pa_werk  AND
          herkunft EQ pa_herku AND
          matnr    EQ pa_matnr
    ORDER BY PRIMARY KEY." AND
*          stat35   NE space.
*}   REPLACE

  CLEAR: wa_itab.
  LOOP AT i_hd INTO wa_itab.
    IF wa_itab-prbnaverf IS INITIAL.
      wa_itab-zgesstichpr = wa_itab-gesstichpr.
      wa_itab-gebeh       = wa_itab-einhprobe.
    ELSE.
      CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
        EXPORTING
          input                = wa_itab-gesstichpr
          matnr                = wa_itab-matnr
          meinh                = wa_itab-gebeh
          meins                = wa_itab-einhprobe
        IMPORTING
          output               = wa_itab-zgesstichpr
        EXCEPTIONS
          conversion_not_found = 1
          input_invalid        = 2
          material_not_found   = 3
          meinh_not_found      = 4
          meins_missing        = 5
          no_meinh             = 6
          output_invalid       = 7
          overflow             = 8
          OTHERS               = 9.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDIF.

    wa_itab-name1_plant = l_name1_plant.
    wa_itab-ort01_plant = l_ort01_plant.

* Get vendor name
    SELECT SINGLE name1
      FROM lfa1
      INTO wa_itab-name1_vendor
      WHERE lifnr EQ wa_itab-lifnr.

* Get material document date
    SELECT SINGLE bldat
      FROM mkpf
      INTO wa_itab-bldat
      WHERE mblnr EQ wa_itab-mblnr AND
            mjahr EQ wa_itab-mjahr.

    IF wa_itab-gebeh IS INITIAL.
      wa_itab-gebeh = wa_itab-einhprobe.
    ENDIF.

    wa_itab-mtart = va_mtart.

    SELECT SINGLE lgobe
      FROM t001l
      INTO wa_itab-lgobe
      WHERE werks = wa_itab-werk
        AND lgort = wa_itab-lagortchrg.

    MODIFY i_hd FROM wa_itab
      TRANSPORTING name1_plant ort01_plant name1_vendor bldat
                   zgesstichpr gebeh lgobe.
    APPEND wa_itab TO i_link.
    PERFORM f_get_result USING wa_itab-prueflos.
    CLEAR: wa_itab.
  ENDLOOP.

* Link header data and detail data

  DELETE ADJACENT DUPLICATES FROM i_link COMPARING plnty plnnr plnal.
  IF NOT i_link[] IS INITIAL.
* new selection for link header data and detail data
    SELECT plnty plnnr plnal plnkn datuv
      FROM plas
      INTO CORRESPONDING FIELDS OF TABLE i_hd1
      FOR ALL ENTRIES IN i_link
      WHERE plnty EQ i_link-plnty AND
            plnnr EQ i_link-plnnr AND
            plnal EQ i_link-plnal AND
            datuv LE i_link-enstehdat AND
            loekz NE 'X'.
  ENDIF.

* Get detail data from PLMK
  IF NOT i_hd1[] IS INITIAL.
    SELECT a~plnty a~plnnr a~plnkn a~kurztext a~toleranzun a~toleranzob
             a~stellen a~katab1 a~dummy40 a~probemgeh a~masseinhsw
             a~merknr
             b~vornr
           FROM plmk AS a JOIN plpo AS b ON a~plnty EQ b~plnty AND
                                            a~plnnr EQ b~plnnr AND
                                            a~plnkn EQ b~plnkn
           INTO CORRESPONDING FIELDS OF TABLE i_dt
           FOR ALL ENTRIES IN i_hd1
           WHERE a~plnty EQ i_hd1-plnty AND
                 a~plnnr EQ i_hd1-plnnr AND
                 a~plnkn EQ i_hd1-plnkn AND
                 a~loekz NE 'X'."         AND
*                 a~codegrqual NE space.
  ENDIF.

  IF pa_werk  = '0401'.
    CLEAR wa_itab.
    LOOP AT i_hd INTO wa_itab.
      CLEAR: wa_dt.
      LOOP AT i_dt INTO wa_dt WHERE plnty = wa_itab-plnty
                                AND plnnr = wa_itab-plnnr.
        wa_dt-mtart = va_mtart.
        wa_dt-prueflos = wa_itab-prueflos.

        IF va_mtart EQ 'ZPM'.
          SELECT SINGLE annahmez
            FROM qasv
            INTO wa_dt-annahmez
            WHERE prueflos EQ wa_dt-prueflos AND
                  merknr   EQ wa_dt-merknr.
        ENDIF.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = wa_dt-toleranzun
            ivalu = 'X'
            decim = wa_dt-stellen
          IMPORTING
            flstr = wa_dt-toleranzun1.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            input = wa_dt-toleranzob
            ivalu = 'X'
            decim = wa_dt-stellen
          IMPORTING
            flstr = wa_dt-toleranzob1.

        SHIFT wa_dt-toleranzun1 LEFT DELETING LEADING space.
        SHIFT wa_dt-toleranzob1 LEFT DELETING LEADING space.
        CONCATENATE wa_dt-toleranzun1 '-' wa_dt-toleranzob1
          INTO wa_dt-standard
          SEPARATED BY space.

        CLEAR wa_dt-meas_unit.
        READ TABLE charreq INTO ls_charreq WITH KEY insplot  = wa_dt-prueflos
                                                    inspoper = wa_dt-vornr
                                                    inspchar = wa_dt-merknr.
        IF sy-subrc = 0.
          IF ls_charreq-up_tol_lmt IS NOT INITIAL AND
            ls_charreq-lw_tol_lmt IS NOT INITIAL.
            CONDENSE ls_charreq-up_tol_lmt NO-GAPS.
            CONDENSE ls_charreq-lw_tol_lmt NO-GAPS.
            CONCATENATE ls_charreq-lw_tol_lmt '-' ls_charreq-up_tol_lmt
            INTO wa_dt-standard
            SEPARATED BY space.
            wa_dt-meas_unit = ls_charreq-meas_unit.
          ELSEIF ls_charreq-up_tol_lmt IS INITIAL AND
            ls_charreq-lw_tol_lmt IS NOT INITIAL.
            CONDENSE ls_charreq-lw_tol_lmt NO-GAPS.
            CONCATENATE '>=' ls_charreq-lw_tol_lmt
            INTO wa_dt-standard
            SEPARATED BY space.
            wa_dt-meas_unit = ls_charreq-meas_unit.
          ELSEIF ls_charreq-up_tol_lmt IS NOT INITIAL AND
            ls_charreq-lw_tol_lmt IS INITIAL.
            CONDENSE ls_charreq-up_tol_lmt NO-GAPS.
            CONCATENATE '<=' ls_charreq-up_tol_lmt
            INTO wa_dt-standard
            SEPARATED BY space.
            wa_dt-meas_unit = ls_charreq-meas_unit.
          ENDIF.
        ENDIF.

        IF wa_dt-mtart NE 'ZPM'.
          IF wa_dt-katab1 EQ space.
            wa_dt-dummy40 = wa_dt-standard.
          ENDIF.
        ENDIF.

        CLEAR wa_dt-zresult.
        LOOP AT i_result INTO wa_result WHERE prueflos = wa_dt-prueflos
                                          AND vornr    = wa_dt-vornr
                                          AND merknr   = wa_dt-merknr.
          CONDENSE wa_result-zresult NO-GAPS.
          IF wa_dt-zresult IS INITIAL.
            wa_dt-zresult = wa_result-zresult.
          ELSE.
            CONCATENATE wa_dt-zresult ';'
            INTO wa_dt-zresult.
            CONCATENATE wa_dt-zresult wa_result-zresult
            INTO wa_dt-zresult
            SEPARATED BY space.
          ENDIF.
        ENDLOOP.

        APPEND wa_dt TO i_dtout.

        MODIFY i_dt FROM wa_dt TRANSPORTING mtart toleranzun1 toleranzob1
                                            meas_unit standard annahmez
                                            dummy40 zresult.
        CLEAR: wa_dt.
      ENDLOOP.
      CLEAR wa_itab.
    ENDLOOP.
  ELSE.
    CLEAR: wa_dt.
    LOOP AT i_dt INTO wa_dt.
      wa_dt-mtart = va_mtart.
      READ TABLE i_hd INTO wa_itab WITH KEY plnty = wa_dt-plnty
                                            plnnr = wa_dt-plnnr.
      IF sy-subrc EQ 0.
        wa_dt-prueflos = wa_itab-prueflos.
      ENDIF.

      IF va_mtart EQ 'ZPM'.
        SELECT SINGLE annahmez
          FROM qasv
          INTO wa_dt-annahmez
          WHERE prueflos EQ wa_dt-prueflos AND
                merknr   EQ wa_dt-merknr.
      ENDIF.

      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          input = wa_dt-toleranzun
          ivalu = 'X'
          decim = wa_dt-stellen
        IMPORTING
          flstr = wa_dt-toleranzun1.

      CALL FUNCTION 'FLTP_CHAR_CONVERSION'
        EXPORTING
          input = wa_dt-toleranzob
          ivalu = 'X'
          decim = wa_dt-stellen
        IMPORTING
          flstr = wa_dt-toleranzob1.

      SHIFT wa_dt-toleranzun1 LEFT DELETING LEADING space.
      SHIFT wa_dt-toleranzob1 LEFT DELETING LEADING space.
      CONCATENATE wa_dt-toleranzun1 '-' wa_dt-toleranzob1
        INTO wa_dt-standard
        SEPARATED BY space.

      IF wa_dt-mtart NE 'ZPM'.
        IF wa_dt-katab1 EQ space.
          wa_dt-dummy40 = wa_dt-standard.
        ENDIF.
      ENDIF.

      READ TABLE i_result INTO wa_result WITH KEY prueflos = wa_dt-prueflos
                                                  vornr    = wa_dt-vornr
                                                  merknr   = wa_dt-merknr.
      IF sy-subrc EQ 0.
*-- Modify by Budi 30/10/2013 Req. by Monika
*      wa_dt-zresult = wa_result-zresult+4(20).
        wa_dt-zresult = wa_result-zresult.
*-- End Modify 30/10/2013
      ENDIF.

      IF wa_dt-mtart = 'ZPM'.
        IF wa_dt-masseinhsw IS INITIAL AND
          wa_dt-toleranzun1 = '0' AND
          wa_dt-toleranzob1 = '0'.
          CLEAR wa_dt-flag_std.
        ELSE.
          wa_dt-flag_std = 'X'.
        ENDIF.
      ENDIF.

      MODIFY i_dt FROM wa_dt TRANSPORTING mtart toleranzun1 toleranzob1
                                          meas_unit standard annahmez
                                          dummy40 zresult flag_std.
      CLEAR: wa_dt.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  DATA : lt_dt      TYPE ta_hd OCCURS 0.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_output_opt-tdnoprint = p_disp.

  IF d_frm_subrc IS INITIAL AND
    NOT ( i_hd IS INITIAL ).
    IF pa_werk = '0401'.
      LOOP AT i_hd INTO wa_itab.
        AT FIRST.
          d_ctrl_param-no_close = 'X'.
        ENDAT.

        AT LAST.
          d_ctrl_param-no_close = space.
        ENDAT.

        CLEAR : lt_dt[], lt_dt.
        LOOP AT i_dtout INTO wa_dt WHERE prueflos = wa_itab-prueflos.
          APPEND wa_dt TO lt_dt.
          CLEAR wa_dt.
        ENDLOOP.

        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            wa_itab            = wa_itab
          TABLES
            i_dt               = lt_dt.

        d_ctrl_param-no_open = 'X'.
      ENDLOOP.
    ELSE.
* call the generated function module of the form
      LOOP AT i_hd INTO wa_itab.

* One Spool
        AT FIRST.
          d_ctrl_param-no_close = 'X'.
        ENDAT.

* to cater multiple printing
        AT LAST.
          d_ctrl_param-no_close = space.
        ENDAT.

        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            wa_itab            = wa_itab
          TABLES
            i_dt               = i_dt.

* One Spool
        d_ctrl_param-no_open = 'X'.
      ENDLOOP.
    ENDIF.
  ELSE.
    MESSAGE i000(zab) WITH 'Data not found'.
  ENDIF.
ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  REFRESH: i_hd, i_dt.
  CLEAR: wa_itab, wa_dt.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_RESULT
*&---------------------------------------------------------------------*
FORM f_get_result  USING    fu_prueflos.
  DATA: return            LIKE bapireturn1 OCCURS 0 WITH HEADER LINE,
        inspoper_list     LIKE bapi2045l2 OCCURS 0 WITH HEADER LINE,
        insppoints        LIKE bapi2045l4 OCCURS 0 WITH HEADER LINE,
        char_requirements LIKE bapi2045d1 OCCURS 0 WITH HEADER LINE,
        char_results      LIKE bapi2045d2 OCCURS 0 WITH HEADER LINE,
        sample_results    LIKE bapi2045d3 OCCURS 0 WITH HEADER LINE.

  DATA : ls_charreq        LIKE LINE OF charreq.

  CALL FUNCTION 'BAPI_INSPLOT_GETOPERATIONS'
    EXPORTING
      number        = fu_prueflos
    IMPORTING
      return        = return
    TABLES
      inspoper_list = inspoper_list.

  LOOP AT inspoper_list.
    CLEAR wa_result-zresult.
    wa_result-prueflos  = fu_prueflos.
    CALL FUNCTION 'BAPI_INSPOPER_GETDETAIL'
      EXPORTING
        insplot                = fu_prueflos
        inspoper               = inspoper_list-inspoper
        read_insppoints        = 'X'
        read_char_requirements = 'X'
        read_char_results      = 'X'
        read_sample_results    = 'X'
      TABLES
        insppoints             = insppoints
        char_requirements      = char_requirements
        char_results           = char_results
        sample_results         = sample_results.

    IF sy-subrc EQ 0.
      SORT char_requirements BY inspchar.
      LOOP AT char_requirements.
        ls_charreq = char_requirements.
        APPEND ls_charreq TO charreq.

        wa_result-vornr   = char_requirements-inspoper.
        wa_result-merknr  = char_requirements-inspchar.

*-- Modify by Budi 30/10/2013 Req. by Monika
*-- Diganti ambil item pertama
*        SORT insppoints BY insplot inspoper insppoint DESCENDING.
        SORT insppoints BY insplot inspoper insppoint.
*-- End Modify 30/10/2013

        IF pa_werk  = '0401'.
**          PERFORM f_result_0401 TABLES insppoints sample_results char_results
**                                USING  char_requirements.
          PERFORM f_result_0401_new TABLES insppoints sample_results char_results
                                    USING  char_requirements.
        ELSE.
          READ TABLE insppoints WITH KEY insplot   = char_requirements-insplot
                                         inspoper  = char_requirements-inspoper.
          IF sy-subrc EQ 0.
            READ TABLE sample_results WITH KEY insplot    = char_requirements-insplot
                                               inspoper   = char_requirements-inspoper
                                               inspchar   = char_requirements-inspchar
                                               inspsample = insppoints-insppoint.
*{   REPLACE        P01K910722                                        1
*\            IF sy-subrc EQ 0.
*\              wa_result-zresult = sample_results-original_input.
*\            ENDIF.
            "Start SOH: Shell Remediation Adjustment 20240319 RZL
            IF sample_results-original_input IS NOT INITIAL.
              wa_result-zresult = sample_results-original_input.
            ELSEIF sample_results-code1 IS NOT INITIAL AND sample_results-code_grp1 IS NOT INITIAL.
              SELECT SINGLE kurztext INTO wa_result-zresult
                FROM qpct WHERE code = sample_results-code1
                            AND codegruppe = sample_results-code_grp1.
            ENDIF.
            "End SOH: Shell Remediation Adjustment 20240319 RZL
*}   REPLACE
          ELSE.
            READ TABLE char_results WITH KEY insplot  = char_requirements-insplot
                                             inspoper = char_requirements-inspoper
                                             inspchar = char_requirements-inspchar.
*{   REPLACE        P01K910722                                        2
*\            IF sy-subrc EQ 0.
*\              wa_result-zresult = char_results-original_input.
*\            ENDIF.
            "Start SOH: Shell Remediation Adjustment 20240319 RZL
            IF sample_results-original_input IS NOT INITIAL.
              wa_result-zresult = sample_results-original_input.
            ELSEIF sample_results-code1 IS NOT INITIAL AND sample_results-code_grp1 IS NOT INITIAL.
              SELECT SINGLE kurztext INTO wa_result-zresult
                FROM qpct WHERE code = sample_results-code1
                            AND codegruppe = sample_results-code_grp1.
            ENDIF.
            "End SOH: Shell Remediation Adjustment 20240319 RZL
*}   REPLACE
          ENDIF.
          APPEND wa_result TO i_result.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_RESULT

*&---------------------------------------------------------------------*
*&      Form  F_RESULT_0401
*&---------------------------------------------------------------------*
FORM f_result_0401  TABLES   insppoints     STRUCTURE bapi2045l4
                             sample_results STRUCTURE bapi2045d3
                             char_results   STRUCTURE bapi2045d2
                    USING    char_requirements   LIKE bapi2045d1.

  READ TABLE insppoints WITH KEY insplot   = char_requirements-insplot
                                 inspoper  = char_requirements-inspoper.
  IF sy-subrc EQ 0.
    LOOP AT sample_results WHERE insplot    = char_requirements-insplot
                             AND inspoper   = char_requirements-inspoper
                             AND inspchar   = char_requirements-inspchar.
      IF sample_results-mean_value IS NOT INITIAL.
        wa_result-zresult = sample_results-mean_value.
      ELSE.
        wa_result-zresult = sample_results-original_input.
      ENDIF.
      APPEND wa_result TO i_result.
    ENDLOOP.
  ELSE.
    LOOP AT char_results WHERE insplot  = char_requirements-insplot
                           AND inspoper = char_requirements-inspoper
                           AND inspchar = char_requirements-inspchar.
      IF char_results-mean_value IS NOT INITIAL.
        wa_result-zresult = char_results-mean_value.
      ELSEIF char_results-original_input IS NOT INITIAL.
        wa_result-zresult = char_results-original_input.
      ELSE.
        SELECT SINGLE kurztext
          FROM qpct
          INTO wa_result-zresult
          WHERE katalogart  = '1'
            AND codegruppe  = char_results-code_grp1
            AND code        = char_results-code1
            AND sprache     = sy-langu
            AND version     = '000001'.
        IF sy-subrc = 0.
          CONCATENATE char_results-code1 wa_result-zresult
          INTO wa_result-zresult
          SEPARATED BY space.
        ENDIF.
      ENDIF.
*      IF char_results-original_input IS INITIAL.
*        wa_result-zresult = char_results-mean_value.
*      ELSE.
*        wa_result-zresult = char_results-original_input.
*      ENDIF.
      APPEND wa_result TO i_result.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_RESULT_0401

*&---------------------------------------------------------------------*
*&      Form  F_RESULT_0401_NEW
*&---------------------------------------------------------------------*
FORM f_result_0401_new  TABLES   insppoints     STRUCTURE bapi2045l4
                                 sample_results STRUCTURE bapi2045d3
                                 char_results   STRUCTURE bapi2045d2
                        USING    char_requirements   LIKE bapi2045d1.
  DATA : lv_char.

  READ TABLE insppoints WITH KEY insplot   = char_requirements-insplot
                                 inspoper  = char_requirements-inspoper.
  IF sy-subrc EQ 0.
    LOOP AT sample_results WHERE insplot    = char_requirements-insplot
                             AND inspoper   = char_requirements-inspoper
                             AND inspchar   = char_requirements-inspchar.
      IF sample_results-mean_value IS NOT INITIAL.
        wa_result-zresult = sample_results-mean_value.
      ELSEIF sample_results-original_input IS NOT INITIAL.
        wa_result-zresult = sample_results-original_input.
      ELSEIF sample_results-code1 IS NOT INITIAL AND
        sample_results-code_grp1 IS NOT INITIAL.
        SELECT SINGLE kurztext
          FROM qpct
          INTO wa_result-zresult
          WHERE katalogart = '1'
            AND codegruppe = sample_results-code_grp1
            AND code       = sample_results-code1
            AND sprache    = sy-langu.
      ENDIF.
      APPEND wa_result TO i_result.
    ENDLOOP.
  ELSE.
    LOOP AT char_results WHERE insplot  = char_requirements-insplot
                           AND inspoper = char_requirements-inspoper
                           AND inspchar = char_requirements-inspchar.
      IF char_results-mean_value IS NOT INITIAL.
        wa_result-zresult = char_results-mean_value.
      ELSEIF char_results-original_input IS NOT INITIAL.
        wa_result-zresult = char_results-original_input.
      ELSE.
        SELECT SINGLE kurztext
          FROM qpct
          INTO wa_result-zresult
          WHERE katalogart  = '1'
            AND codegruppe  = char_results-code_grp1
            AND code        = char_results-code1
            AND sprache     = sy-langu
            AND version     = '000001'.
        IF sy-subrc = 0.
          CONCATENATE char_results-code1 wa_result-zresult
          INTO wa_result-zresult
          SEPARATED BY space.
        ENDIF.
      ENDIF.
      APPEND wa_result TO i_result.
    ENDLOOP.
  ENDIF.



*ELSE.
*
*ENDIF.
ENDFORM.
