*&---------------------------------------------------------------------*
*&  Include           ZSFASD_I0001F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INIT_PATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_path .
  DATA: ld_link TYPE ibipparms-path.

*  gv_type = 'A'.
*  CLEAR ld_link.
*  CALL METHOD zcl_util=>m_get_link
*    EXPORTING
*      i_type   = gv_type
*      i_folder = 'SOURCE'
*    IMPORTING
*      e_path   = ld_link.
*  p_path = ld_link.
*  IF p_path IS INITIAL.
*    p_path = '/acc/inbound/'.
*  ENDIF.
  p_path = '/interface/'.
ENDFORM.                    " F_INIT_PATH


*&---------------------------------------------------------------------*
*&      Form  F_GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_ZDG2MMST0001  text
*      -->FU_AN8           text
*      <--FU_PATH          text
*----------------------------------------------------------------------*
FORM f_get_filename  USING    fu_an8
                     CHANGING fu_path
                              fu_filename.
  DATA: lv_kunnr TYPE kunnr,
        lv_currno TYPE numc3,
        lv_filename	TYPE zdg2cade0039.

  CONCATENATE  fu_an8 sy-datum 'DCP'
         INTO fu_filename SEPARATED BY '_'.

  CONCATENATE p_path fu_filename '.txt' INTO fu_path.
*  ENDIF.
ENDFORM.                    " F_GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_GET_LOG_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_log_number .
*  LOOP AT gt_zdg3mmdt0009 ASSIGNING <fs_zdg3mmdt0009>.
**    CONDENSE: <fs_zdg3mmdt0009>-cnum,<fs_zdg3mmdt0009>-trx.
*    SHIFT <fs_zdg3mmdt0009>-trx LEFT DELETING LEADING '0'.
*    CONCATENATE <fs_zdg3mmdt0009>-cnum <fs_zdg3mmdt0009>-trx
*      INTO <fs_zdg3mmdt0009>-zznrbon.
*  ENDLOOP.
*
*  SELECT * INTO TABLE gt_zdg3cadt0001h
*    FROM zdg3cadt0001h FOR ALL ENTRIES IN gt_zdg3mmdt0009
*    WHERE vkorg EQ gt_zdg3mmdt0009-vkorg
*      AND  zznrbon EQ gt_zdg3mmdt0009-zznrbon
*      AND ( logno NE space OR logno NE '0000000000' ).
*
*  IF gt_zdg3cadt0001h[] IS NOT INITIAL.
*    SELECT * INTO TABLE gt_zdg3cadt0005
*      FROM zdg3cadt0005 FOR ALL ENTRIES IN gt_zdg3cadt0001h
*      WHERE vkorg EQ gt_zdg3cadt0001h-vkorg
*          AND logno EQ gt_zdg3cadt0001h-logno.
*  ENDIF.
ENDFORM.                    " F_GET_LOG_NUMBER
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .
  DATA: lw_itabline TYPE zchar1500,
        lt_zaccmmdt001 TYPE TABLE OF zaccmmdt001 WITH HEADER LINE.

  CLEAR:  wa_itabline.
  LOOP AT itabline INTO wa_itabline.
* Skip EOF
    IF wa_itabline(1) NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
      CONTINUE.
    ENDIF.

    lw_itabline = wa_itabline.

    "Replace '#' to space
    CALL METHOD zcl_util=>m_replace_eol_flag
      EXPORTING
        pvi_char = lw_itabline
      IMPORTING
        pvo_char = lw_itabline.

    wa_itabline = lw_itabline.

    PERFORM f_append_itab_c.
  ENDLOOP.

  IF gt_itab_c[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_zaccmmdt001
      FROM zaccmmdt001 FOR ALL ENTRIES IN gt_itab_c
      WHERE ivnr  = gt_itab_c-ivnr7
        AND brcod = gt_itab_c-brcod
        AND matnr = gt_itab_c-matnr
        AND sn = gt_itab_c-sn.

    SELECT * INTO TABLE gt_zaccdta
      FROM zaccdta FOR ALL ENTRIES IN gt_itab_c
      WHERE senum  = gt_itab_c-sn.

    SELECT matnr meins INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FROM mara FOR ALL ENTRIES IN gt_itab_c
      WHERE matnr = gt_itab_c-matnr.
  ENDIF.

  SORT lt_zaccmmdt001 BY ivnr brcod matnr sn.
  SORT gt_itab_c BY ivnr brcod matnr sn.

  LOOP AT gt_itab_c.
    READ TABLE lt_zaccmmdt001 WITH KEY ivnr  = gt_itab_c-ivnr7
                                       brcod = gt_itab_c-brcod
                                       matnr = gt_itab_c-matnr
                                       sn    = gt_itab_c-sn
                                       BINARY SEARCH.
    IF sy-subrc NE 0.
      PERFORM f_save_prepare.
    ELSE.
      gv_error = 'X'.
      CONCATENATE i_file_list-name 'Ada data yang sudah di Upload'
        INTO gv_msg SEPARATED BY space.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF gv_error IS INITIAL.
    PERFORM f_update_table.
  ENDIF.

  PERFORM f_list_data.
ENDFORM.                    " F_PROSES_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DATA
*&---------------------------------------------------------------------*
FORM f_list_data.
  WRITE:/ gv_msg.
ENDFORM.                    " F_LIST_DATA

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_ITAB_C
*&---------------------------------------------------------------------*
FORM f_append_itab_c .
  gt_itab_c = wa_itabline.
  CONCATENATE gt_itab_c-acode gt_itab_c-sqcode gt_itab_c-scode
    INTO gt_itab_c-matnr SEPARATED BY '-'.
  gt_itab_c-ivnr7 = gt_itab_c-ivnr.

  APPEND gt_itab_c.
  CLEAR: gt_itab_c.
ENDFORM.                    " F_APPEND_ITAB_C

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TABLE
*&---------------------------------------------------------------------*
FORM f_update_table .
  CALL FUNCTION 'ZACC_MODIFY' IN UPDATE TASK
    EXPORTING
      tabname        = 'ZACCMMDT001'
    TABLES
      it_zaccmmdt001 = gt_zaccmmdt001.

  IF sy-subrc = 0.
    COMMIT WORK.
    CONCATENATE i_file_list-name 'Successfully Upload'
      INTO gv_msg SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_UPDATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_PREPARE
*&---------------------------------------------------------------------*
FORM f_save_prepare .
  CLEAR: gt_zaccdta,gt_mara.
  APPEND INITIAL LINE TO gt_zaccmmdt001 ASSIGNING <fs_zaccmmdt001>.
  <fs_zaccmmdt001>-ivnr   = gt_itab_c-ivnr7.
  <fs_zaccmmdt001>-brcod  = gt_itab_c-brcod.
  <fs_zaccmmdt001>-matnr  = gt_itab_c-matnr.
  <fs_zaccmmdt001>-charg  = gt_itab_c-nobatch.
  <fs_zaccmmdt001>-sn     = gt_itab_c-sn.

  READ TABLE gt_zaccdta WITH KEY senum = <fs_zaccmmdt001>-sn.
  <fs_zaccmmdt001>-aggr1  = gt_zaccdta-aggr1.
  <fs_zaccmmdt001>-aggr2  = gt_zaccdta-aggr2.
  <fs_zaccmmdt001>-upldat = sy-datum.
  IF gt_itab_c-aggr1 IS NOT INITIAL.
    <fs_zaccmmdt001>-zact1 = 'X'.
  ENDIF.
  IF gt_itab_c-aggr2 IS NOT INITIAL.
    <fs_zaccmmdt001>-zact2 = 'X'.
  ENDIF.

  READ TABLE gt_mara WITH KEY matnr  = gt_itab_c-matnr.
  <fs_zaccmmdt001>-meins = gt_mara-meins.
ENDFORM.                    " F_SAVE_PREPARE
