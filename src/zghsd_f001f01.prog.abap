*&---------------------------------------------------------------------*
*&  Include           ZTSPFI_F001F01
*&---------------------------------------------------------------------*
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
  CLEAR: gs_header,gt_detail[],gt_lips[],gt_makt[],gt_konv[],gv_knumv,gv_ihrez.
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
  SELECT SINGLE vbeln erdat lifex inco2
    INTO (gs_header-vbeln, gs_header-erdat, gs_header-lifex,
          gs_header-inco2)
    FROM likp WHERE vbeln = p_vbeln.

  CASE gs_header-inco2.
    WHEN 'COD'.
      gs_header-inco2 = 'Cash On Delivery'.
      gs_header-inco3 = 'Tunai'.
    WHEN 'TOD'.
      gs_header-inco2 = 'Cash On Delivery'.
      gs_header-inco3 = 'Transfer'.
    WHEN 'CBD'.
      gs_header-inco2 = 'Cash Before Delivery'.
      gs_header-inco3 = 'Transfer (LUNAS)'.
    WHEN OTHERS.
*      CLEAR: gs_header-inco2,gs_header-inco3.
      gs_header-inco2 = 'Cash Before Delivery'.
      gs_header-inco3 = 'Transfer (LUNAS)'.
  ENDCASE.

  SELECT SINGLE adrnr
    INTO gs_header-adrnr
    FROM vbpa WHERE vbeln = p_vbeln
                AND parvw = 'WE'.

  SELECT SINGLE name1 name2 name3 name4 city1 city2
    INTO (gs_header-name1, gs_header-name2, gs_header-name3,
          gs_header-name4, gs_header-city1, gs_header-city2)
    FROM adrc WHERE addrnumber = gs_header-adrnr.

  SELECT vbeln posnr matnr lfimg meins kcmeng vgbel vgpos
    INTO CORRESPONDING FIELDS OF TABLE gt_lips
    FROM lips WHERE vbeln = p_vbeln
                AND uecha = '000000'.

  IF gt_lips[] IS NOT INITIAL.
    READ TABLE gt_lips INDEX 1.
    SELECT SINGLE knumv ihrez
      INTO (gv_knumv, gv_ihrez)
      FROM ekko WHERE ebeln = gt_lips-vgbel.

    SELECT knumv kposn stunr zaehk kappl kschl kbetr waers
      INTO CORRESPONDING FIELDS OF TABLE gt_konv
      FROM konv FOR ALL ENTRIES IN gt_lips
      WHERE knumv = gv_knumv
        AND kposn = gt_lips-vgpos
        AND kschl = 'ZHJO'.

    SELECT matnr maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN gt_lips
      WHERE matnr = gt_lips-matnr.

    PERFORM f_read_text USING    gt_lips-vgbel
                        CHANGING gs_header-vacct.
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
  LOOP AT gt_lips.
    CLEAR: gt_makt,gt_konv.
    READ TABLE gt_makt WITH KEY matnr = gt_lips-matnr.
    READ TABLE gt_konv WITH KEY knumv = gv_knumv
                                kposn = gt_lips-vgpos
                                kschl = 'ZHJO'.

    gt_detail-matnr   = gt_lips-matnr.
    gt_detail-maktx   = gt_makt-maktx.
    gt_detail-lfimg   = gt_lips-lfimg + gt_lips-kcmeng.
    gt_detail-meins   = gt_lips-meins.
    gt_detail-kbetr   = gt_konv-kbetr.
    gt_detail-value   = gt_detail-lfimg * gt_detail-kbetr.
    gt_detail-waers   = gt_konv-waers.

    WRITE: gt_detail-lfimg UNIT gt_detail-meins TO gt_detail-jumlah,
           gt_detail-kbetr CURRENCY gt_detail-waers TO gt_detail-harga,
           gt_detail-value CURRENCY gt_detail-waers TO gt_detail-amount.

    CONDENSE: gt_detail-jumlah,gt_detail-harga,gt_detail-amount.

*    gs_header-total = gs_header-total + gt_detail-value.
    gs_header-waers = gt_detail-waers.

    APPEND gt_detail. CLEAR gt_detail.
  ENDLOOP.

*  WRITE gs_header-total CURRENCY gs_header-waers TO gs_header-totalc.
  gs_header-total = gv_ihrez.
  WRITE gs_header-total TO gs_header-totalc.
  CONDENSE gs_header-totalc.
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

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
*      call the generated function module of the form
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gs_header          = gs_header
      TABLES
        gt_detail          = gt_detail[].
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
  CLEAR: gs_header,gt_detail[],gt_lips[],gt_makt[],gt_konv[],gv_knumv,
         gv_ihrez.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
FORM f_read_text  USING    fu_vgbel
                  CHANGING fc_vacct.
  DATA: lv_id     LIKE thead-tdid,
        lv_name   LIKE thead-tdname,
        lv_object LIKE thead-tdobject,
        lv_header LIKE thead,
        lt_lines  LIKE tline OCCURS 0 WITH HEADER LINE.

  lv_id     = 'F02'.
  lv_name   = fu_vgbel.
  lv_object = 'EKKO'.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lv_id
      language                = sy-langu
      name                    = lv_name
      object                  = lv_object
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE lt_lines INDEX 1.
    fc_vacct = lt_lines-tdline.
  ENDIF.
ENDFORM.                    " F_READ_TEXT
