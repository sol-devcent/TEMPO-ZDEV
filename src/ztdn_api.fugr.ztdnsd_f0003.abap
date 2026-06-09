FUNCTION ZTDNSD_F0003.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PROSES) TYPE  CHAR10 DEFAULT 'TDN_TRD'
*"     VALUE(SALES_OFFICE) TYPE  VKBUR
*"     VALUE(PERIODE) TYPE  SPMON
*"     VALUE(API) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"  TABLES
*"      T_MATERIAL STRUCTURE  MARA OPTIONAL
*"--------------------------------------------------------------------
  TABLES: s940.
  TYPES: BEGIN OF t_s940,
          sales_office LIKE s940-vkbur,
          periode LIKE s940-spmon,
          material LIKE s940-matnr,
          quantity(15), " LIKE s940-mkabest,
          satuan LIKE s940-basme,
         END OF t_s940.
  TYPES: BEGIN OF t_stock,
          t_s940 TYPE STANDARD TABLE OF  t_s940 WITH NON-UNIQUE DEFAULT KEY,
         END OF t_stock.
  "  RANGES s_matnr FOR s940-matnr.
  DATA: i_stock TYPE STANDARD TABLE OF   t_stock WITH HEADER LINE.
  DATA: wa_s940 TYPE t_s940.
  DATA: gt_s940 TYPE STANDARD TABLE OF  s940.
  DATA: gs_s940 TYPE s940.
  DATA: p_str TYPE string.
  DATA : cl_json_data   TYPE REF TO zcl_trex_json_serializer,
         gv_json        TYPE string.
  DATA: gv_proses TYPE char15.
  DATA: p_return(1).
**  DATA: ld_name1(40).
**  SELECT SINGLE name1 INTO ld_name1 FROM tvbur AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
**    WHERE vkbur = sales_office.
  gv_proses = proses.
  IF api = 'X'.
    PERFORM f_get_data USING gv_proses CHANGING p_str p_return.
    PERFORM f_proses_json USING p_str CHANGING sales_office periode.
  ELSE.
    IF t_material[] IS NOT INITIAL.
      REFRESH s_matnr.
      LOOP AT t_material.
        s_matnr-sign = 'I'.
        s_matnr-option = 'EQ'.
        s_matnr-low = t_material-matnr.
        APPEND s_matnr.
      ENDLOOP.
    ENDIF.
  ENDIF.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_s940
    FROM s940 AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE vkbur = sales_office AND
          spmon = periode AND
          a~matnr IN s_matnr.
  DELETE gt_s940[] WHERE mkabest = 0.
  LOOP AT gt_s940 INTO gs_s940.
    wa_s940-sales_office = gs_s940-vkbur.
    wa_s940-periode = gs_s940-spmon.
    wa_s940-material = gs_s940-matnr.
    WRITE gs_s940-mkabest TO wa_s940-quantity NO-GAP NO-GROUPING DECIMALS 0.
    wa_s940-satuan =  gs_s940-basme.
    APPEND wa_s940 TO i_stock-t_s940.
  ENDLOOP.
  IF i_stock-t_s940[] IS NOT INITIAL.
    CREATE OBJECT cl_json_data
      EXPORTING
        DATA = i_stock.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json gv_proses sy-subrc p_str.
    DATA: lv_name(15).
    lv_name = sales_office.
    CONCATENATE 'TRD2' lv_name INTO lv_name SEPARATED BY '_'.
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_name '/outbound/tdn/' gv_proses.
    status = 'S'.
    IF p_str IS NOT INITIAL.
      FIND 'error' IN p_str.
      IF sy-subrc EQ 0.
        status = 'E'.
        message = p_str.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
