*----------------------------------------------------------------------*
*   INCLUDE ZTNTSD_F0002F01                                            *
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
  DATA : lt_vbkd    LIKE lips OCCURS 0 WITH HEADER LINE,
         lt_marm    LIKE lips OCCURS 0 WITH HEADER LINE.

  SELECT vbeln erdat vstel kunnr wadat_ist bldat
    FROM likp
    INTO CORRESPONDING FIELDS OF TABLE gt_likp
    WHERE vbeln = pa_vbeln.

  CHECK gt_likp[] IS NOT INITIAL.

  READ TABLE gt_likp INDEX 1.

  SELECT SINGLE *
    FROM tvst
    INTO CORRESPONDING FIELDS OF wa_tvst
    WHERE vstel = gt_likp-vstel.

  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM adrc
      INTO CORRESPONDING FIELDS OF wa_adrc
      WHERE addrnumber = wa_tvst-adrnr.
  ENDIF.

  SELECT SINGLE *
    FROM zpbf
    INTO CORRESPONDING FIELDS OF wa_zpbf
    WHERE vkbur = gt_likp-vstel.

  SELECT SINGLE *
    FROM zsign
    INTO CORRESPONDING FIELDS OF wa_zsign
    WHERE s_point = gt_likp-vstel.

  SELECT kunnr adrc~name1 adrc~name2 adrc~name3
    FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
    INTO TABLE gt_kna1
    FOR ALL ENTRIES IN gt_likp
    WHERE kunnr = gt_likp-kunnr.

  SELECT vbeln posnr matnr lichn lfimg meins vrkme arktx vgbel vgpos
    FROM lips
    INTO CORRESPONDING FIELDS OF TABLE gt_lips
    FOR ALL ENTRIES IN gt_likp
    WHERE vbeln = gt_likp-vbeln
      AND lfimg NE 0.

  lt_vbkd[] = gt_lips[].
  SORT lt_vbkd BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_vbkd COMPARING vgbel.

  IF lt_vbkd[] IS NOT INITIAL.
    SELECT vbeln bstkd bstdk
      FROM vbkd
      INTO CORRESPONDING FIELDS OF TABLE gt_vbkd
      FOR ALL ENTRIES IN lt_vbkd
      WHERE vbeln = lt_vbkd-vgbel.
  ENDIF.

  lt_marm[] = gt_lips[].
  SORT lt_marm BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_marm COMPARING matnr.

  IF lt_marm[] IS NOT INITIAL.
    SELECT *
      FROM marm
      INTO CORRESPONDING FIELDS OF TABLE gt_marm
      FOR ALL ENTRIES IN lt_marm
      WHERE matnr = lt_marm-matnr
        AND meinh <> lt_marm-meins.
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
  DATA : lv_umrent(10),
         lv_umrezt(10),
         lv_meins   TYPE meins,
         lv_meinh	  TYPE lrmei,
         lv_lfimg   TYPE lfimg,
         lv_norut   LIKE gt_detail-norut.

  LOOP AT gt_likp.
    MOVE-CORRESPONDING gt_likp TO gs_header.
    READ TABLE gt_lips WITH KEY vbeln = gt_likp-vbeln.
    IF sy-subrc = 0.
      READ TABLE gt_vbkd WITH KEY vbeln = gt_lips-vgbel.
      IF sy-subrc = 0.
        gs_header-bstkd   = gt_vbkd-bstkd.
        gs_header-bstdk   = gt_vbkd-bstdk.
      ENDIF.
    ENDIF.

    gs_header-object_name   = wa_zsign-object_name.
    gs_header-nmperiksa     = wa_zsign-user_name.
    gs_header-no_sk         = wa_zsign-no_sk1.

    gs_header-street        = wa_adrc-street.
    gs_header-pbfno         = wa_zpbf-pbfno.

    READ TABLE gt_kna1 WITH KEY kunnr = gt_likp-kunnr.
    IF sy-subrc = 0.
      gs_header-name1   = gt_kna1-name1.
      gs_header-name2   = gt_kna1-name2.
      gs_header-name3   = gt_kna1-name3.
    ENDIF.

    SELECT SINGLE str03
      FROM zsd_sertifikasi
      INTO gs_header-str03
      WHERE vkbur = gt_likp-vstel.
  ENDLOOP.


  LOOP AT gt_lips.
    MOVE-CORRESPONDING gt_lips TO gt_detail.
    ADD gt_detail-lfimg TO gs_header-total.
    COLLECT gt_detail.
  ENDLOOP.

  LOOP AT gt_detail.
    ADD 1 TO lv_norut.
    gt_detail-norut = lv_norut.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input  = gt_detail-meins
      IMPORTING
        output = lv_meins.

    READ TABLE gt_marm WITH KEY matnr = gt_detail-matnr.
    IF sy-subrc = 0.
      WRITE gt_marm-umren TO lv_umrent DECIMALS 0.
      CONDENSE lv_umrent NO-GAPS.
      WRITE gt_marm-umrez TO lv_umrezt DECIMALS 0.
      CONDENSE lv_umrezt NO-GAPS.
      CONCATENATE lv_umrent gt_marm-meinh '='
                  lv_umrezt lv_meins
      INTO gt_detail-unit
      SEPARATED BY space.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input  = gt_marm-meinh
        IMPORTING
          output = lv_meinh.

      lv_lfimg  = gt_detail-lfimg / gt_marm-umrez.
      WRITE lv_lfimg TO gt_detail-satuan UNIT gt_marm-meinh.
      CONDENSE gt_detail-satuan.
      CONCATENATE gt_detail-satuan lv_meinh "gt_marm-meinh
      INTO gt_detail-satuan
      SEPARATED BY space.
    ENDIF.

    WRITE gt_detail-lfimg TO gt_detail-lfimgt UNIT gt_detail-meins.
    CONDENSE gt_detail-lfimgt NO-GAPS.
    CONCATENATE gt_detail-lfimgt lv_meins
    INTO gt_detail-lfimgt
    SEPARATED BY space.

    MODIFY gt_detail TRANSPORTING unit satuan lfimgt norut.
  ENDLOOP.

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
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gs_header          = gs_header
      TABLES
        gt_detail          = gt_detail.
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
  CLEAR:  gt_detail, gt_detail[], gs_header.
ENDFORM.                    " f_free_memory
