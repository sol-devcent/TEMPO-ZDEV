*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF11 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GETDATA_SPLITDN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_NO_GS  text
*----------------------------------------------------------------------*
FORM f_getdata_splitdn  USING    p_nogs
                                 p_proses
                        CHANGING p_str.

  DATA: lt_zfgscab TYPE STANDARD TABLE OF zfgscab.
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.

  DATA: lv_err(1).
  DATA: lv_text TYPE text1024.

  CONCATENATE '{ "no_dn" : "' p_nogs '" } ' INTO lt_response_body-line.
  APPEND lt_response_body.
  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                       USING    p_proses
                                       CHANGING p_str lv_err.


ENDFORM.                    " F_GETDATA_SPLITDN
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON_SPLITDN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_STR  text
*      <--P_LV_STATUS  text
*      <--P_LV_MESSAGE  text
*----------------------------------------------------------------------*
FORM f_convert_json_splitdn  USING    p_str
                             CHANGING p_status
                                      p_message.
  TABLES: zfgscab, zfgscab_dtl.

  TYPES: BEGIN OF ty_result,
           no_dn          TYPE string, ": "TSP0224/0119        ",
           amt_dn         TYPE p DECIMALS 0, "string, ": 78500,
           exp_sub_group  TYPE string, ": "CONDITIONAL REBATE",
           exp_type       TYPE string, ": "CONDITIONAL REBATE",
           cust_group     TYPE string, ": "E-COMMERCE",
           cust_sub_group TYPE string, ": "SUKAMART",
           nm_break       TYPE string, ": "all CC",
           mat_code       TYPE string, ": "073-09-00 ",
           amount         TYPE p DECIMALS 2, "string, ": 208.91
           ppn_no         TYPE string, ": "",
           ppn_amount     TYPE p DECIMALS 2, ": 0,
           pph_amount     TYPE p DECIMALS 2, ":
         END OF ty_result.
  TYPES: BEGIN OF ty_dn_split,
           result TYPE STANDARD TABLE OF ty_result WITH NON-UNIQUE DEFAULT KEY,
         END OF ty_dn_split.

  DATA: gv_str TYPE string.
  DATA: gt_zfgscab_dtl TYPE STANDARD TABLE OF zfgscab_dtl.
  DATA: gs_zfgscab_dtl TYPE zfgscab_dtl.
  DATA: gs_zfgscab_hdr TYPE zfgscab_hdr.
  " DATA: gs_dn_split TYPE ty_result.
  DATA: gt_dn_split TYPE ty_dn_split.

  DATA:   lv_json_data     TYPE string. ",
  DATA: lv_text(10), lv_name(15), lv_json TYPE string.
  DATA: ls_result TYPE ty_result.
  DATA: lv_ctr TYPE i.
  DATA: lv_err(1).
  lv_json_data = p_str.


  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = gt_dn_split ).

  CLEAR: lv_ctr.
  LOOP AT gt_dn_split-result INTO ls_result.
    "    AT FIRST.
    gs_zfgscab_hdr-xref2 = ls_result-no_dn.
    gs_zfgscab_hdr-vatno = ls_result-ppn_no.
    gs_zfgscab_hdr-ppn = ls_result-ppn_amount / 100.
    gs_zfgscab_hdr-pph = ls_result-pph_amount / 100.
    gs_zfgscab_hdr-waers = 'IDR'.
    "    ENDAT.
    ADD 1 TO lv_ctr.
    gs_zfgscab_dtl-bukrs = '8020'.
    lv_text = ls_result-no_dn+5(2).
    CONDENSE lv_text.
    CONCATENATE '20' lv_text INTO gs_zfgscab_dtl-gjahr.
    gs_zfgscab_dtl-xref2 = ls_result-no_dn.
    IF lv_ctr = 1.
      CLEAR: lv_err, gs_zfgscab_dtl-fi_posting.
      SELECT SINGLE fi_posting INTO gs_zfgscab_dtl-fi_posting FROM zfgscab_dtl
        WHERE xref2 = gs_zfgscab_dtl-xref2.
      IF sy-subrc EQ 0.
        IF gs_zfgscab_dtl-fi_posting IS NOT INITIAL.
          CONCATENATE 'No. ' gs_zfgscab_dtl-xref2 'sdh di posting dgn no' gs_zfgscab_dtl-fi_posting INTO p_message.
          lv_err = 'E'.
          EXIT.
        ENDIF.
      ELSE.
      ENDIF.
    ENDIF.
    gs_zfgscab_dtl-matnr = ls_result-mat_code.
    gs_zfgscab_dtl-exp_type  = ls_result-exp_type.
    gs_zfgscab_dtl-exp_sub_grp = ls_result-exp_sub_group.
    gs_zfgscab_dtl-cust_grp = ls_result-cust_group.
    gs_zfgscab_dtl-cust_sub_grp = ls_result-cust_sub_group.
    gs_zfgscab_dtl-nm_break = ls_result-nm_break.
    gs_zfgscab_dtl-amount  = ls_result-amount / 100.
    gs_zfgscab_dtl-currency = 'IDR'.
    APPEND gs_zfgscab_dtl TO gt_zfgscab_dtl.
    MODIFY zfgscab_dtl FROM gs_zfgscab_dtl.
  ENDLOOP.
  IF lv_err = 'E'.
    "    p_message = 'Data sudah diproses di SAP'.
    p_status = 'E'.
  ELSE.
    IF gs_zfgscab_hdr-xref2 IS NOT INITIAL AND gt_zfgscab_dtl[] IS NOT INITIAL.
      MODIFY zfgscab_hdr FROM gs_zfgscab_hdr.
    ENDIF.
    IF lv_ctr > 0.
      p_status = 'S'.
      lv_text = lv_ctr.
      CONCATENATE 'Jumlah data yang diproses : '  lv_text INTO p_message.
    ELSE.
      p_status = 'E'.
      p_message = 'Tidak ada data yang diproses'.
    ENDIF.
  ENDIF.
  lv_text = sy-uzeit.
  lv_name = sy-datum.
  CONCATENATE 'TRS_' lv_name lv_text INTO lv_name.
  PERFORM f_create_text_json(ztdsit_i001) USING lv_json_data lv_name '/outbound/trx/' 'TREX_SPLITDN'.
ENDFORM.                    " F_CONVERT_JSON_SPLITDN
