*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_RETURN  text
*----------------------------------------------------------------------*
FORM F_GET_DATA  using p_proses p_vkbur type vstel CHANGING p_str type string p_return .
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_err(1).
  CLEAR: lt_response_body[], lt_response_body.
  "  CLEAR: ok_code.
  CONCATENATE '{ "sales_office": "' p_vkbur '"  } ' INTO lt_response_body-line.
  APPEND lt_response_body.
  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                       USING    p_proses
                                       CHANGING p_str lv_err.

**  WRITE: gv_str.
  IF p_str IS NOT INITIAL.
    FIND 'error' IN p_str.
    IF sy-subrc EQ 0.
      p_return = '4'.
      RETURN.
    ENDIF.
    FIND 'material' IN p_str.
    IF sy-subrc NE 0.
      p_return = '3'.
      RETURN.
    ENDIF.
  ELSE.
    p_return = '2'.
    RETURN.
  ENDIF.

ENDFORM.                    " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_PROSES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_STR  text
*      <--P_GT_MATLP  text
*----------------------------------------------------------------------*
FORM F_PROSES  USING    p_str.
               "CHANGING t_matlp TYPE STANDARD TABLE ty_matlp.

  FIELD-SYMBOLS:
    <data>        TYPE data,
    <data1>        TYPE ANY TABLE,
    <results>     TYPE ANY,
    <structure>   TYPE ANY,
    <table>       TYPE ANY TABLE,
    <field>       TYPE ANY,
    <field_value> TYPE data.
  DATA:         lr_data          TYPE REF TO data.
  DATA: ls_matlp         TYPE ty_matlp.
  zcl_json=>deserialize(
        EXPORTING
          json             = p_str
        CHANGING
          data             = lr_data ).
  REFRESH: gt_matlp.
  IF lr_data IS BOUND.
    ASSIGN lr_data->* TO <data>.
    ASSIGN COMPONENT 'RESULT' OF STRUCTURE <data> TO <results>.
    IF <results> IS ASSIGNED.
      ASSIGN <results>->* TO <table>.
      LOOP AT <table> ASSIGNING <structure>.
        ASSIGN <structure>->* TO <data>.
        ASSIGN COMPONENT 'SALES_OFFICE' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED AND <field> IS NOT INITIAL.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          ls_matlp-sales_office = <field_value>.
        ENDIF.
        UNASSIGN: <field>, <field_value>.
        ASSIGN COMPONENT 'MATERIAL_CODE' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED AND <field> IS NOT INITIAL.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          ls_matlp-material_code = <field_value>.
        ENDIF.
        UNASSIGN: <field>, <field_value>.
        APPEND ls_matlp TO gt_matlp.
      ENDLOOP.
    ENDIF.
  ENDIF.


ENDFORM.                    " F_PROSES
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UPDATE. " using p_vstel.
  DATA: ls_matlp TYPE ty_matlp.
  IF gt_matlp[] IS NOT INITIAL.
    DELETE FROM zmlogika_lgtyp WHERE vstel = gv_vkbur.
    LOOP AT gt_matlp INTO ls_matlp.
      gs_zmlogika_lgtyp-vstel = ls_matlp-sales_office.
      gs_zmlogika_lgtyp-matnr = ls_matlp-material_code.
      APPEND gs_zmlogika_lgtyp TO gt_zmlogika_lgtyp.
      MODIFY zmlogika_lgtyp FROM gs_zmlogika_lgtyp.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_UPDATE
*&---------------------------------------------------------------------*
*&      Form  F_SEND_TO_API
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VKBUR  text
*----------------------------------------------------------------------*
FORM F_SEND_TO_API  USING    p_vkbur p_proses CHANGING p_mess.
  DATA : p_str          TYPE string,
         lv_json        TYPE string.
  DATA: l_name(15).
  DATA: l_time(8).
  CONCATENATE '{ "sales_office" : "' p_vkbur '" }' INTO lv_json. " SEPARATED BY space.
  write: / lv_json.
  PERFORM f_post_data_json(ztdsit_i001) USING lv_json p_proses sy-subrc p_str.
  p_mess = p_str.
  l_name = sy-datum.
  l_time = sy-uzeit.

  CONDENSE: l_name, l_time.
  CONCATENATE p_vkbur '_' l_name l_time INTO l_name.
  CONDENSE l_name.
  PERFORM f_create_text_json(ztdsit_i001) USING lv_json l_name '/outbound/tws/' 'TWS_MATDOC'.

ENDFORM.                    " F_SEND_TO_API
