*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF08 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_STR  text
*----------------------------------------------------------------------*
FORM f_convert_json_trapproval  USING    p_str p_INVOICE type ZINVNO.
  TYPES: BEGIN OF ty_result,
            statuscode  TYPE string, ": 200,
            success  TYPE string, ": true,
            message  TYPE string, ": "Success Get Data Final",
            status_approval  TYPE string, ": "C",
            no_pra_invoice  TYPE string, ": "TR-KP/TGB/O/052/II/2025",
            date_approval  TYPE string, ": "20240514"
           END OF ty_result.
  TYPES: BEGIN OF ty_respon,
            budget_no TYPE string,
            status TYPE string,
            message TYPE string,
         END OF ty_respon.

  DATA: gs_result TYPE ty_result.
  DATA: gs_respon TYPE ty_respon.
  DATA: gt_zrevtr001 TYPE TABLE OF zrevtr001 WITH HEADER LINE.
  DATA: gs_zrevtr001 TYPE zrevtr001.
  DATA: gs_invno(50). " LIKE zrevtr001-invno.
  DATA: gs_date TYPE datum.
  DATA: lv_json_data     TYPE string. ",
  DATA: lv_text(10), lv_name(15), lv_str TYPE string.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer.

  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = gs_result ).

  IF gs_result-status_approval = 'C'.
    gs_invno = gs_result-no_pra_invoice.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zrevtr001
     FROM zrevtr001
      WHERE invno = gs_invno.
    IF gt_zrevtr001[] IS NOT INITIAL.
      LOOP AT gt_zrevtr001 INTO gs_zrevtr001.
        gs_date = gs_result-date_approval.
        gs_zrevtr001-date_approval = gs_date.
        UPDATE zrevtr001 SET date_approval = gs_date
                             aedat = sy-datum
                             aenam = sy-uname
                             aezet = sy-uzeit
                WHERE bukrs = gs_zrevtr001-bukrs
                  AND gjahr = gs_zrevtr001-gjahr
                  AND linno = gs_zrevtr001-linno
                  AND invno = gs_zrevtr001-invno.
        IF sy-subrc EQ 0.
          gv_status = 'S'.
        ELSE.
          gv_status = 'E'.
          CONDENSE gs_zrevtr001-invno.
          "CONCATENATE gs_zrevtr001-invno.
          gv_message = 'Update gagal table ZREVTR001'.
        ENDIF.
      ENDLOOP.
    ELSE.
      gv_status = 'E'.
      CONDENSE p_INVOICE.
      CONCATENATE p_INVOICE ' Tidak ditemukan di SAP' INTO gv_message.
      "          gv_message = 'Update gagal table ZREVTR001'.
    ENDIF.
  ELSE.
    gv_status = 'E'.
    CONDENSE p_INVOICE.
    CONCATENATE p_INVOICE 'status belum Complete' INTO gv_message.
  ENDIF.
  gs_respon-budget_no = p_INVOICE.
  gs_respon-status = gv_status.
  gs_respon-message = gv_message.
  CLEAR: lv_json_data.
  CREATE OBJECT cl_json_data
    EXPORTING
      DATA = gs_respon.
  cl_json_data->serialize( ).
  lv_json_data = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING lv_json_data 'TR_APPROVAL' sy-subrc lv_str.
  IF gv_status = 'S'.
    gv_message = lv_str.
  ENDIF.
ENDFORM.                    " F_CONVERT_JSON
