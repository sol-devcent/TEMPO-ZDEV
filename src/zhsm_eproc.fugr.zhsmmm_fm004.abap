FUNCTION zhsmmm_fm004.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PROSES) TYPE  CHAR15 DEFAULT 'HSM_FORMFPKH'
*"     VALUE(PLANT) TYPE  WERKS_D
*"     VALUE(MATNR) TYPE  MATNR
*"     REFERENCE(TENDER) TYPE  SUBMI OPTIONAL
*"  EXPORTING
*"     REFERENCE(LINKURL) TYPE  ZURL
*"     REFERENCE(NOFORM) TYPE  CHAR80
*"     REFERENCE(LAMPIRAN) TYPE  ZURL
*"----------------------------------------------------------------------

  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  TYPES: BEGIN OF ty_data,
              no_tender TYPE string, ": "3000000319",
              plant  TYPE string,                           ": "2300",
              material_code TYPE string,": "PM00011931     ",
              no_form TYPE string,": "001/P02/8230/05/2024",
              url_fpkh TYPE string,": null
              lampiran type string,
         END OF ty_data.
  TYPES: BEGIN OF ty_result,
              statuscode TYPE string,
              success TYPE string,
              data TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY,
         END OF ty_result.
  DATA: gs_result TYPE ty_result.
  DATA: gs_data TYPE ty_data.

  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.



  DATA: lv_err(1).
  DATA: lv_text TYPE text1024.
  DATA: gv_str TYPE string.
***{
***    "no_tender" : "3000000319",
***    "plant" : "2300",
***    "material" : "PM00011931"
***}
  CONCATENATE '{ "no_tender" : "' tender '",' INTO lt_response_body-line.
  APPEND lt_response_body.
  CONCATENATE '  "plant" : "' plant '",' INTO lt_response_body-line.
  APPEND lt_response_body.
  CONCATENATE '  "material" : "' matnr '" }' INTO lt_response_body-line.
  APPEND lt_response_body.

  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                       USING    proses
                                       CHANGING gv_str lv_err.

  zcl_json=>deserialize(
        EXPORTING
          json             = gv_str
        CHANGING
          data             = gs_result ).
  IF gs_result-statuscode = '200'.
    LOOP AT gs_result-data INTO gs_data.
      linkurl = gs_data-url_fpkh.
      noform = gs_data-no_form.
**      ls_zhsmmmdt008-submi = ls_data-no_tender.
**      ls_zhsmmmdt008-matnr = ls_data-material_code.
**      ls_zhsmmmdt008-werks = ls_data-plant.
**      ls_zhsmmmdt008-url = ls_data-url_fpkh.
**      ls_zhsmmmdt008-noform = ls_data-no_form.
**      APPEND ls_zhsmmmdt008 TO lt_zhsmmmdt008.
**      MODIFY zhsmmmdt008 FROM ls_zhsmmmdt008.
    ENDLOOP.
  ENDIF.



ENDFUNCTION.
