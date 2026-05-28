*----------------------------------------------------------------------*
*   INCLUDE ZTDSFORMTEMPF01                                            *
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
  DATA: lt_jest  TYPE TABLE OF jest WITH HEADER LINE,
        lt_tj02t TYPE TABLE OF tj02t WITH HEADER LINE.

  DATA: lv_qmnum TYPE qmnum,
        lv_manum TYPE manum.

  DATA : lv_menge TYPE zgdqmst0007-menge,
         lv_meins TYPE mseg-meins.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF wa_zgdqmst0007
    FROM qmel WHERE qmnum = pa_qmnum.

  IF sy-subrc = 0.
*    IF wa_zgdqmst0007-qmart NE 'T2'.
*      MESSAGE 'Notification Type harus T2' TYPE 'S' DISPLAY LIKE 'E'.
*      STOP.
*    ENDIF.
    CASE wa_zgdqmst0007-mawerk.
      WHEN '3600' OR '3603'.
        SELECT SINGLE parnr INTO wa_zgdqmst0007-uname
          FROM ihpa WHERE objnr = wa_zgdqmst0007-objnr
                      AND parvw = 'KU'.
        IF sy-subrc = 0.
          SELECT SINGLE title INTO wa_zgdqmst0007-title
            FROM zdgqmdt001 WHERE mawerk = wa_zgdqmst0007-mawerk
                              AND uname  = wa_zgdqmst0007-uname.
        ENDIF.
      WHEN '2300'.
        wa_zgdqmst0007-title = 'QA MANAGER'.
      WHEN '1900'.
        wa_zgdqmst0007-title = 'QA-QC MANAGER'.
      WHEN OTHERS.
        wa_zgdqmst0007-title = 'QC MANAGER'.
    ENDCASE.
  ELSE.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  SELECT SINGLE qmnum manum erlnam
    INTO (lv_qmnum,lv_manum,wa_zgdqmst0007-erlnam)
    FROM qmsm WHERE qmnum = wa_zgdqmst0007-qmnum.

  CLEAR wa_zgdqmst0007-erlnam.
  PERFORM f_get_item_text USING lv_qmnum lv_manum
                          CHANGING wa_zgdqmst0007-erlnam.

  SELECT SINGLE qmartx INTO wa_zgdqmst0007-qmartx
    FROM tq80_t WHERE spras = sy-langu
                  AND qmart = wa_zgdqmst0007-qmart.

  SELECT SINGLE mtart INTO wa_zgdqmst0007-mtart
    FROM mara WHERE matnr = wa_zgdqmst0007-matnr.

  SELECT SINGLE maktx INTO wa_zgdqmst0007-maktx
    FROM makt WHERE matnr = wa_zgdqmst0007-matnr
                AND spras = sy-langu.

  SELECT SINGLE name1 ort01 INTO (wa_zgdqmst0007-name1, wa_zgdqmst0007-ort01)
    FROM t001w WHERE werks = wa_zgdqmst0007-mawerk.

  SELECT * INTO TABLE lt_jest
    FROM jest WHERE objnr = wa_zgdqmst0007-objnr
                AND inact = space.

  IF lt_jest[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_tj02t
      FROM tj02t FOR ALL ENTRIES IN lt_jest
      WHERE istat = lt_jest-stat
        AND spras = sy-langu.
  ENDIF.

  LOOP AT lt_tj02t.
    IF wa_zgdqmst0007-status IS INITIAL.
      wa_zgdqmst0007-status = lt_tj02t-txt04.
    ELSE.
      CONCATENATE wa_zgdqmst0007-status lt_tj02t-txt04
        INTO wa_zgdqmst0007-status SEPARATED BY space.
    ENDIF.
  ENDLOOP.

  SELECT SINGLE xblnr budat
    FROM mkpf
    INTO (wa_zgdqmst0007-xblnr, wa_zgdqmst0007-grdat)
    WHERE mblnr = wa_zgdqmst0007-mblnr
      AND mjahr = wa_zgdqmst0007-mjahr.

*  PERFORM f_get_mseg USING wa_zgdqmst0007.

  SELECT SINGLE licha
    FROM mch1
    INTO wa_zgdqmst0007-licha
    WHERE matnr = wa_zgdqmst0007-matnr
      AND charg = wa_zgdqmst0007-charg.

  SELECT SINGLE name1
    FROM lfa1
    INTO wa_zgdqmst0007-name1_lifnr
    WHERE lifnr = wa_zgdqmst0007-lifnum.

  SELECT SINGLE hsdat vfdat
    FROM mch1
    INTO (wa_zgdqmst0007-hsdat, wa_zgdqmst0007-vfdat)
    WHERE matnr = wa_zgdqmst0007-matnr
      AND charg = wa_zgdqmst0007-charg.

  SELECT SINGLE a~landx
    INTO wa_zgdqmst0007-landx
    FROM t005t AS a JOIN lfa1 AS b ON a~land1 = b~land1 AND
                                      a~spras = b~spras
    WHERE b~lifnr = wa_zgdqmst0007-lifnum
      AND a~spras = sy-langu.

  IF wa_zgdqmst0007-prueflos IS INITIAL.
    wa_zgdqmst0007-prueflos = wa_zgdqmst0007-refnum.
  ENDIF.

  SELECT SINGLE anzgeb gebeh lmengeist mengeneinh
    FROM qals
    INTO (wa_zgdqmst0007-anzgeb, wa_zgdqmst0007-gebeh,
          wa_zgdqmst0007-menge, wa_zgdqmst0007-meins)
    WHERE prueflos = wa_zgdqmst0007-prueflos.

  IF wa_zgdqmst0007-mawerk = '3600'.
    SELECT SINGLE smtp_addr INTO wa_zgdqmst0007-smtp_addr
      FROM adr6 AS a JOIN usr21 AS b ON a~persnumber = b~persnumber
      WHERE b~bname = wa_zgdqmst0007-uname.

    CASE wa_zgdqmst0007-lgortcharg.
      WHEN '1010' OR '1011' OR '2010' OR '20U1' OR '2110' OR
           '2210' OR '2310' OR '3010' OR '30U1' OR '5010' .
        wa_zgdqmst0007-zkmm = 'KMM Plant 2'.
        wa_zgdqmst0007-ort01 = 'Mojokerto'.
      WHEN OTHERS.
        wa_zgdqmst0007-zkmm = 'KMM Plant 1'.
        wa_zgdqmst0007-ort01 = 'Surabaya'.
    ENDCASE.
  ELSEIF wa_zgdqmst0007-mawerk = '3603'.
    SELECT SINGLE smtp_addr INTO wa_zgdqmst0007-smtp_addr
      FROM adr6 AS a JOIN usr21 AS b ON a~persnumber = b~persnumber
      WHERE b~bname = wa_zgdqmst0007-uname.

    wa_zgdqmst0007-ort01 = 'Cikarang'.
  ELSE.
    SELECT SINGLE smtp_addr INTO wa_zgdqmst0007-smtp_addr
      FROM adr6 AS a JOIN usr21 AS b ON a~persnumber = b~persnumber
      WHERE b~bname = wa_zgdqmst0007-ernam.
  ENDIF.

  IF wa_zgdqmst0007-qmart NE 'T3'.
*    wa_zgdqmst0007-reject = ( CEIL( wa_zgdqmst0007-rkmng / wa_zgdqmst0007-menge *
*                            wa_zgdqmst0007-anzgeb ) ).

    TRY .
        lv_menge = wa_zgdqmst0007-menge / wa_zgdqmst0007-anzgeb.
      CATCH cx_sy_zerodivide.
    ENDTRY.

    TRY .
        wa_zgdqmst0007-reject = ceil( wa_zgdqmst0007-rkmng / lv_menge ).
      CATCH cx_sy_zerodivide.
    ENDTRY.
  ENDIF.

  IF wa_zgdqmst0007-ebeln IS INITIAL.
    IF wa_zgdqmst0007-prueflos IS INITIAL.
      SELECT SINGLE ebeln
        INTO wa_zgdqmst0007-ebeln
        FROM qals WHERE prueflos = wa_zgdqmst0007-refnum.
    ELSE.
      SELECT SINGLE ebeln
        INTO wa_zgdqmst0007-ebeln
        FROM qals WHERE prueflos = wa_zgdqmst0007-prueflos.
    ENDIF.
  ENDIF.

  CLEAR lv_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = wa_zgdqmst0007-meins
    IMPORTING
      output = lv_meins.
  IF sy-subrc = 0.
    wa_zgdqmst0007-meins = lv_meins.
  ENDIF.

  CLEAR lv_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = wa_zgdqmst0007-mgein
    IMPORTING
      output = lv_meins.
  IF sy-subrc = 0.
    wa_zgdqmst0007-mgein = lv_meins.
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

  IF wa_zgdqmst0007-mawerk = '1900'.
*    PERFORM f_init_sign USING '03' CHANGING pa_qam.
*    PERFORM f_init_sign USING '04' CHANGING pa_pm.

    CALL SELECTION-SCREEN 110 STARTING AT 10 5
                              ENDING AT   100  10.

    IF sy-subrc NE 0.
      STOP.
    ENDIF.
  ENDIF.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        header             = wa_zgdqmst0007.
*      TABLES
*        gt_detail          = gt_detail.
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

ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_ITEM_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_QMNUM  text
*      -->P_LV_MANUM  text
*      <--P_WA_ZGDQMST0007_ERLNAM  text
*----------------------------------------------------------------------*
FORM f_get_item_text  USING    fu_qmnum
                               fu_manum
                      CHANGING fc_erlnam.
  DATA: lv_id     LIKE thead-tdid,
        lv_name   LIKE thead-tdname,
        lv_object LIKE thead-tdobject,
        lv_header LIKE thead,
        lt_lines  LIKE tline OCCURS 0 WITH HEADER LINE,
        lv_clustr LIKE stxl-clustr.

  lv_id     = 'LTQM'.
  lv_object = 'QMSM'.
  CONCATENATE fu_qmnum fu_manum INTO lv_name.

  SELECT SINGLE clustr INTO lv_clustr
    FROM stxl WHERE relid = 'TX'
                AND tdobject = lv_object
                AND tdname = lv_name
                AND tdid = lv_id
                AND tdspras = sy-langu.

  IF sy-subrc = 0.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id       = lv_id
        language = sy-langu
        name     = lv_name
        object   = lv_object
      IMPORTING
        header   = lv_header
      TABLES
        lines    = lt_lines.
    IF sy-subrc = 0.
      READ TABLE lt_lines INDEX 1.
      fc_erlnam = lt_lines-tdline.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ITEM_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_MSEG
*&---------------------------------------------------------------------*
FORM f_get_mseg  USING    fs_zgdqmst0007 STRUCTURE zgdqmst0007.
  DATA: lv_meins TYPE mseg-meins.

  SELECT SINGLE menge meins
    FROM mseg
    INTO (wa_zgdqmst0007-menge, wa_zgdqmst0007-meins)
    WHERE mblnr = wa_zgdqmst0007-mblnr
      AND mjahr = wa_zgdqmst0007-mjahr
      AND zeile = wa_zgdqmst0007-mblpo.
  IF sy-subrc NE 0.
    SELECT SINGLE  mblnr mjahr zeile
      INTO (wa_zgdqmst0007-mblnr,wa_zgdqmst0007-mjahr,wa_zgdqmst0007-mblpo)
      FROM qals WHERE prueflos = wa_zgdqmst0007-prueflos.
    IF sy-subrc NE 0.
      SELECT SINGLE  mblnr mjahr zeile
        INTO (wa_zgdqmst0007-mblnr,wa_zgdqmst0007-mjahr,wa_zgdqmst0007-mblpo)
        FROM qals WHERE prueflos = wa_zgdqmst0007-refnum.
    ENDIF.
    SELECT SINGLE menge meins
      FROM mseg
      INTO (wa_zgdqmst0007-menge, wa_zgdqmst0007-meins)
      WHERE mblnr = wa_zgdqmst0007-mblnr
        AND mjahr = wa_zgdqmst0007-mjahr
        AND zeile = wa_zgdqmst0007-mblpo.
  ENDIF.

  CLEAR lv_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = wa_zgdqmst0007-meins
    IMPORTING
      output = lv_meins.
  IF sy-subrc = 0.
    wa_zgdqmst0007-meins = lv_meins.
  ENDIF.
ENDFORM.                    " F_GET_MSEG

*&---------------------------------------------------------------------*
*&      Form  F_GET_SIGN
*&---------------------------------------------------------------------*
FORM f_get_sign  USING    fu_type
                 CHANGING fc_name.
  DATA: it_return TYPE TABLE OF ddshretval.

  SELECT tdname, zjabatan, name_text INTO TABLE @DATA(lt_jabatan)
    FROM zhgqmdt001 WHERE werks = @wa_zgdqmst0007-mawerk
                      AND zsign = @fu_type
    ORDER BY zjabatan.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TDNAME'
      value_org       = 'S'
    TABLES
      value_tab       = lt_jabatan
      return_tab      = it_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  DATA(lw_ret) = it_return[ 1 ].
  DATA(lw_jabatan) = lt_jabatan[ tdname = lw_ret-fieldval ].
  fc_name = lw_jabatan-name_text.

  CASE fu_type.
    WHEN '03'.
      wa_zgdqmst0007-qc_tdname  = lw_jabatan-tdname.
      wa_zgdqmst0007-qc_jabatan = lw_jabatan-zjabatan.
      wa_zgdqmst0007-qc_name    = lw_jabatan-name_text.
    WHEN '04'.
      wa_zgdqmst0007-pm_tdname  = lw_jabatan-tdname.
      wa_zgdqmst0007-pm_jabatan = lw_jabatan-zjabatan.
      wa_zgdqmst0007-pm_name    = lw_jabatan-name_text.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SIGN
*&---------------------------------------------------------------------*
FORM f_init_sign  USING    fu_type
                  CHANGING fc_name.
  SELECT SINGLE tdname, zjabatan, name_text
    INTO @DATA(ls_zhgqmdt001)
    FROM zhgqmdt001 WHERE werks = @wa_zgdqmst0007-mawerk
                      AND zsign = @fu_type.
  IF sy-subrc = 0.
    fc_name = ls_zhgqmdt001-name_text.
    CASE fu_type.
      WHEN '03'.
        wa_zgdqmst0007-qc_tdname  = ls_zhgqmdt001-tdname.
        wa_zgdqmst0007-qc_jabatan = ls_zhgqmdt001-zjabatan.
        wa_zgdqmst0007-qc_name    = ls_zhgqmdt001-name_text.
      WHEN '04'.
        wa_zgdqmst0007-pm_tdname  = ls_zhgqmdt001-tdname.
        wa_zgdqmst0007-pm_jabatan = ls_zhgqmdt001-zjabatan.
        wa_zgdqmst0007-pm_name    = ls_zhgqmdt001-name_text.
    ENDCASE.
  ENDIF.
ENDFORM.
