*&---------------------------------------------------------------------*
*&  Include           ZTDS_FTMPF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data CHANGING p_return.
  DATA: lv_tdname     TYPE tdobname.
  DATA: lv_lines   TYPE i.
  DATA: lv_message TYPE char250_d.
  SELECT SINGLE * INTO gs_likp FROM likp WHERE vbeln = pa_vbeln.
  IF sy-subrc EQ 0.
    SELECT SINGLE * INTO gs_ztdnsddt022
      FROM ztdnsddt022 WHERE bstkd = gs_likp-lifex AND ( status NE 'E' OR status NE 'D' ).
    IF sy-subrc EQ 0.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ztdnsddt022d FROM ztdnsddt022d
        WHERE bstkd = gs_ztdnsddt022-bstkd
          AND kode_mp = gs_ztdnsddt022-kode_mp
          AND kode_shop = gs_ztdnsddt022-kode_shop
          AND znotrans = gs_ztdnsddt022-znotrans
          AND ( status NE 'E' OR status NE 'D' ).
      gs_ztdnsddt022-vbeln = pa_vbeln.
      CLEAR: lv_tdname, gt_stxbitmaps[].
      CONCATENATE gs_ztdnsddt022-no_awb '%' INTO lv_tdname.
      SELECT tdobject tdname tdid tdbtype
        INTO CORRESPONDING FIELDS OF TABLE gt_stxbitmaps
        FROM stxbitmaps WHERE tdobject = 'GRAPHICS'
                          AND tdname   LIKE lv_tdname
                          AND tdid     = 'BMAP'
                          AND tdbtype  = 'BMON'.
    ENDIF.
  ENDIF.
  p_return = sy-subrc.
  IF  sy-subrc NE 0.
    gv_message = 'Error: Image tidak ditemukan'.
    p_return = 3.
***    PERFORM f_protocol_update USING 'ZAB' '000' gv_message.
***    gs_ztdnsddt022-status = 'D'.
***    MODIFY ztdnsddt022 FROM gs_ztdnsddt022.
***    LOOP AT gt_ztdnsddt022d INTO gs_ztdnsddt022d.
***      gs_ztdnsddt022d-status = 'D'.
***      MODIFY  ztdnsddt022d FROM gs_ztdnsddt022d.
***    ENDLOOP.
***    gv_message = 'Re Upload Image AWB'.
***    PERFORM f_protocol_update USING 'ZAB' '000' gv_message.
***    CALL FUNCTION 'ZTDNSD_F0005'
***      EXPORTING
***        no_order = gs_likp-lifex
***      IMPORTING
***        no_awb   = lv_tdname
***        status   = p_return
***        MESSAGE  = lv_message.
***    IF sy-subrc EQ 0 AND p_return IS INITIAL.
***      gv_message = 'Sukses - Re Upload Image AWB'.
***      PERFORM f_protocol_update USING 'ZAB' '000' gv_message.
***      CLEAR: gs_ztdnsddt022, gt_ztdnsddt022d[], gs_ztdnsddt022d, gt_stxbitmaps[].
***      SELECT SINGLE * INTO gs_ztdnsddt022
***        FROM ztdnsddt022 WHERE bstkd = gs_likp-lifex.
***      IF sy-subrc EQ 0.
***        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ztdnsddt022d FROM ztdnsddt022d
***          WHERE bstkd = gs_ztdnsddt022-bstkd
***            AND kode_mp = gs_ztdnsddt022-kode_mp
***            AND kode_shop = gs_ztdnsddt022-kode_shop
***            AND znotrans = gs_ztdnsddt022-znotrans.
***        gs_ztdnsddt022-vbeln = pa_vbeln.
***        CLEAR: lv_tdname, gt_stxbitmaps[].
***        CONCATENATE gs_ztdnsddt022-no_awb '%' INTO lv_tdname.
***        SELECT tdobject tdname tdid tdbtype
***          INTO CORRESPONDING FIELDS OF TABLE gt_stxbitmaps
***          FROM stxbitmaps WHERE tdobject = 'GRAPHICS'
***                            AND tdname   LIKE lv_tdname
***                            AND tdid     = 'BMAP'
***                            AND tdbtype  = 'BMON'.
***        IF sy-subrc NE 0.
***          gv_message = 'Error: Image tidak ditemukan'.
***          p_return = 3.
***        ELSE.
***          CLEAR p_return.
***        ENDIF.
***      ELSE.
***        gv_message = 'Error: Image tidak ditemukan'.
***        p_return = 3.
***      ENDIF.
***    ELSE.
***      p_return = 3.
***    ENDIF.
  ELSE.
    DESCRIBE TABLE gt_stxbitmaps LINES lv_lines.
    IF lv_lines NE gs_ztdnsddt022-zpage.
      gv_message = 'Error: Image tidak lengkap'.
      p_return = 4.
    ENDIF.
  ENDIF.
  gs_ztdnsddt022-zmessage = gv_message.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .

ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form CHANGING p_return.
  DATA : lv_formname       TYPE tdsfname,
         lv_funcname       TYPE tdsfname,
         lv_objname        TYPE tdobname,
         ls_control_option TYPE ssfctrlop,
         ls_output_option  TYPE ssfcompop.

  DATA : ls_head LIKE LINE OF gt_head,
         ls_detl LIKE LINE OF gt_detl,
         lt_detl TYPE STANDARD TABLE OF zwmdt004.
  DATA: ld_ssfcrespd TYPE ssfcrespd,
        ld_ssfcrescl TYPE ssfcrescl,
        ld_ssfcresop TYPE ssfcresop.
  DATA: lwa_spoolids TYPE  tsfspoolid,
        lwa_rspoid   TYPE rspoid.

  DATA : lv_count     TYPE i,
         lv_countc(3).

  lv_formname = 'ZTDNSDSF001'.
  PERFORM f_determine_smrt_funcmod USING lv_formname
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_ctrl_param-no_close = space.
    d_ctrl_param-no_open  = space.
    CLEAR: gs_ztdnsddt022d.
    LOOP AT gt_ztdnsddt022d INTO gs_ztdnsddt022d.
      ADD 1 TO lv_count.
      CLEAR: lv_objname.
      lv_objname = gs_ztdnsddt022d-no_awb.
      d_output_opt-tddelete = nast-delet. "'X'.
      IF lv_count = gs_ztdnsddt022-zpage.
        d_ctrl_param-no_close = space.
      ELSE.
        d_ctrl_param-no_close = 'X'.
      ENDIF.

      SELECT SINGLE padest
        FROM tsp03d
        INTO d_output_opt-tddest
        WHERE name = p_dest.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters   = d_ctrl_param
          output_options       = d_output_opt
          user_settings        = space
          objname              = lv_objname
        IMPORTING
          document_output_info = ld_ssfcrespd
          job_output_info      = ld_ssfcrescl
          job_output_options   = ld_ssfcresop
        EXCEPTIONS
          formatting_error     = 1
          internal_error       = 2
          send_error           = 3
          user_canceled        = 4
          OTHERS               = 5.
      p_return = sy-subrc.
      IF lv_count = gs_ztdnsddt022-zpage.
        d_ctrl_param-no_open  = space.
      ELSE.
        d_ctrl_param-no_open  = 'X'.
      ENDIF.
    ENDLOOP.
**    DO gs_ztdnsddt022-zpage TIMES.
**      ADD 1 TO lv_count.
**      CLEAR: lv_countc,lv_objname.
**      lv_countc = lv_count.
**      CONDENSE lv_countc.
**    ENDDO.
    lwa_spoolids = ld_ssfcrescl-spoolids.
    LOOP AT ld_ssfcrescl-spoolids INTO gs_ztdnsddt022-nospool.

    ENDLOOP.
  ELSE.
    p_return = d_frm_subrc.
    gv_message = 'Error: Gagal Generate form'.
    gs_ztdnsddt022-zmessage = gv_message.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_TYPE
*&---------------------------------------------------------------------*
FORM f_output_type CHANGING return_code.
  DATA: lv_return(4).
  PERFORM f_get_data CHANGING return_code.
  IF return_code EQ 0.
    gv_message = 'Start Cetak Image'.
    PERFORM f_protocol_update USING 'ZAB' '000' gv_message.
  ELSE.
    lv_return = return_code.
    gv_message = 'Gagal Cetak Image Return code : '.
    CONCATENATE gv_message lv_return INTO gv_message.
    PERFORM f_protocol_update USING 'ZAB' '000' gv_message.
  ENDIF.
  PERFORM f_print_form CHANGING return_code.
ENDFORM.                    " F_OUTPUT_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_STR  text
*----------------------------------------------------------------------*
FORM f_protocol_update  USING   p_msgid p_msgno  p_update.
  DATA: lv_ctr TYPE i, lv_len TYPE i.
  DATA: lv_char1 TYPE char50.
  DATA: lv_char2 TYPE char50.
  DATA: lv_char3 TYPE char50.
  DATA: lv_char4 TYPE char50.
  DATA: lv_char5 TYPE char50.
  DATA: lv_char6 TYPE char50.
  DATA: lv_char7 TYPE char50.
  DATA: lv_char8 TYPE char50.
  DATA: lv_posisi TYPE i.
  DATA: lv_cal TYPE i.
  DATA: lv_text(10).
  DATA: lv_msgty TYPE sy-msgty.
  FIELD-SYMBOLS <fs>. " TYPE ANY.

  FIND 'Error' IN p_update.
  IF sy-subrc EQ 0.
    lv_msgty = 'E'.
  ELSE.
    lv_msgty = 'I'.
  ENDIF.

  lv_ctr = strlen( p_update ).
  lv_posisi = 0.
  lv_len = strlen( p_update ).
  lv_cal = 1.
  WHILE lv_ctr > 1.
    IF lv_ctr > 50.
      lv_len = 50.
    ELSE.
      lv_len = lv_ctr.
    ENDIF.
    lv_text = lv_cal.
    CONDENSE lv_text.
    CONCATENATE 'LV_CHAR' lv_text INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = p_update+lv_posisi(lv_len).
    IF lv_ctr > 50.
      lv_ctr = lv_ctr - 50.
      lv_posisi = lv_posisi + 50.
    ELSE.
      EXIT.
    ENDIF.
    ADD 1 TO lv_cal.
    IF lv_cal > 8.
      EXIT.
    ENDIF.
  ENDWHILE.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = p_msgid "'ZAB'
      msg_nr    = p_msgno "'000'
      msg_ty    = lv_msgty "'I'
      msg_v1    = lv_char1
      msg_v2    = lv_char2
      msg_v3    = lv_char3
      msg_v4    = lv_char4
    EXCEPTIONS
      OTHERS    = 1.
  IF lv_char5 IS NOT INITIAL.
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        msg_arbgb = p_msgid "'ZAB'
        msg_nr    = p_msgno "'000'
        msg_ty    = lv_msgty "'I'
        msg_v1    = lv_char5
        msg_v2    = lv_char6
        msg_v3    = lv_char7
        msg_v4    = lv_char8
      EXCEPTIONS
        OTHERS    = 1.
  ENDIF.

ENDFORM.                    " F_PROTOCOL_UPDATE
