*----------------------------------------------------------------------*
***INCLUDE LZTDN_APIF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_ENCRYPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KDMAT  text
*      <--P_L_KDMAT  text
*----------------------------------------------------------------------*
FORM f_get_encryption  USING    fu_vcr_encrp
                       CHANGING fc_vcr_encrp.

  DATA : add_param      TYPE sxpgcolist-parameters.

*  Return status
  DATA: funcstatus TYPE extcmdexex-status.

*  Command line listing returned by the function
  DATA: iserveroutput    TYPE STANDARD TABLE OF btcxpm,
        gs_iserveroutput LIKE LINE OF iserveroutput.

  add_param = fu_vcr_encrp.

  CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
    EXPORTING
      commandname                   = 'ZTDN_ENC'
      additional_parameters         = add_param
    IMPORTING
      status                        = funcstatus
    TABLES
      exec_protocol                 = iserveroutput
    EXCEPTIONS
      no_permission                 = 1
      command_not_found             = 2
      parameters_too_long           = 3
      security_risk                 = 4
      wrong_check_call_interface    = 5
      program_start_error           = 6
      program_termination_error     = 7
      x_error                       = 8
      parameter_expected            = 9
      too_many_parameters           = 10
      illegal_command               = 11
      wrong_asynchronous_parameters = 12
      cant_enq_tbtco_entry          = 13
      jobcount_generation_error     = 14
      OTHERS                        = 15.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR gs_iserveroutput.
    READ TABLE iserveroutput INTO gs_iserveroutput INDEX 1.
    fc_vcr_encrp = gs_iserveroutput-message.
  ENDIF.

ENDFORM.                    " F_GET_ENCRYPTION
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data USING p_proses CHANGING p_str TYPE string p_return ..
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_err(1).
**  CLEAR: lt_response_body[], lt_response_body.
**  "  CLEAR: ok_code.
**  CONCATENATE '{ "sales_office": "' p_vkbur '"  } ' INTO lt_response_body-line.
**  APPEND lt_response_body.
  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                       USING    p_proses
                                       CHANGING p_str lv_err.
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
*&      Form  F_PROSES_JSON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_STR  text
*      <--P_SALES_OFFICE  text
*      <--P_PERIODE  text
*      <--P_T_MATERIAL  text
*----------------------------------------------------------------------*
FORM f_proses_json  USING    p_str
                    CHANGING p_sales_office
                             p_periode.
  FIELD-SYMBOLS:
    <data>        TYPE data,
    <data1>       TYPE ANY TABLE,
    <results>     TYPE any,
    <structure>   TYPE any,
    <table>       TYPE ANY TABLE,
    <field>       TYPE any,
    <field_value> TYPE data.
  DATA:         lr_data          TYPE REF TO data.
  DATA: BEGIN OF li_material OCCURS 0,
          material(10),
        END OF li_material.
  "  DATA: ls_matlp         TYPE ty_matlp.
  zcl_json=>deserialize(
        EXPORTING
          json             = p_str
        CHANGING
          data             = lr_data ).
  IF lr_data IS BOUND.
    ASSIGN lr_data->* TO <data>.
    ASSIGN COMPONENT 'SALES_OFFICE' OF STRUCTURE <data> TO <field>.
    IF <field> IS ASSIGNED AND <field> IS NOT INITIAL.
      lr_data = <field>.
      ASSIGN lr_data->* TO <field_value>.
      p_sales_office = <field_value>.
    ENDIF.
    UNASSIGN: <field>, <field_value>.
    ASSIGN COMPONENT 'PERIODE' OF STRUCTURE <data> TO <field>.
    IF <field> IS ASSIGNED AND <field> IS NOT INITIAL.
      lr_data = <field>.
      ASSIGN lr_data->* TO <field_value>.
      p_periode = <field_value>.
    ENDIF.
    UNASSIGN: <field>, <field_value>.

    ASSIGN COMPONENT 'DETAIL' OF STRUCTURE <data> TO <results>.
    IF <results> IS ASSIGNED.
      ASSIGN <results>->* TO <table>.
      LOOP AT <table> ASSIGNING <structure>.
        ASSIGN <structure>->* TO <data>.
        ASSIGN COMPONENT 'MATERIAL' OF STRUCTURE <data> TO <field>.
        IF <field> IS ASSIGNED AND <field> IS NOT INITIAL.
          lr_data = <field>.
          ASSIGN lr_data->* TO <field_value>.
          li_material-material = <field_value>.
          IF li_material-material IS NOT INITIAL.
            APPEND li_material.
          ENDIF.
        ENDIF.
        UNASSIGN: <field>, <field_value>.
      ENDLOOP.
    ENDIF.
  ENDIF.
  IF li_material[] IS NOT INITIAL.
    LOOP AT li_material.
      CONDENSE li_material-material.
      IF li_material-material IS NOT INITIAL.
        s_matnr-sign = 'I'.
        s_matnr-option = 'EQ'.
        s_matnr-low = li_material-material.
        APPEND s_matnr.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROSES_JSON
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_STR  text
*      <--P_P_KUNNR  text
*      <--P_P_MESSAGE  text
*----------------------------------------------------------------------*
FORM f_convert_json  USING    p_str
                     CHANGING p_kunnr
                              p_message.
  TYPES: BEGIN OF customer,
           nama_cust     TYPE string,
           alamat_cust1  TYPE string,
           alamat_cust2  TYPE string,
           kecamatan     TYPE string,
           kota_cust     TYPE string,
           sap_region_id TYPE string,
           zip_cust      TYPE string,
           phone_cust    TYPE string,
           store_code    TYPE string,
           kode_ba       TYPE string,
           tdn_plant     TYPE string,
         END OF customer.

  TYPES: BEGIN OF ty_customer,
           customer TYPE STANDARD TABLE OF customer WITH NON-UNIQUE DEFAULT KEY,
         END OF ty_customer.

  DATA: lt_customer TYPE ty_customer.
  DATA: ls_customer TYPE customer.
  DATA:   lv_json_data     TYPE string.

  DATA: lt_kna1 TYPE STANDARD TABLE OF kna1 WITH HEADER LINE.
  DATA: ls_kna1 TYPE kna1. " WITH HEADER LINE.
  DATA: lv_sort1 LIKE adrc-sort1.
  DATA: lv_addrnumber LIKE adrc-addrnumber.
  DATA: ls_okna1 TYPE kna1. " WITH HEADER LINE.
  DATA: lt_knvv TYPE STANDARD TABLE OF knvv WITH HEADER LINE.
  DATA: ls_knvv TYPE knvv. " WITH HEADER LINE.
  DATA: lt_knvi TYPE STANDARD TABLE OF fknvi WITH HEADER LINE.
  DATA: ls_knvi TYPE knvi. " WITH HEADER LINE.
  DATA: lt_knb1 TYPE STANDARD TABLE OF knb1 WITH HEADER LINE.
  DATA: ls_knb1 TYPE knb1. " WITH HEADER LINE.
  DATA: lt_bapiaddr1 TYPE STANDARD TABLE OF bapiaddr1 WITH HEADER LINE.
  DATA: ls_bapiaddr1 TYPE bapiaddr1. " WITH HEADER LINE.
  DATA: lv_kunnr LIKE knvv-kunnr.

  DATA: lt_xknvp TYPE STANDARD TABLE OF fknvp WITH HEADER LINE.
  DATA: ls_xknvp TYPE fknvp. " WITH HEADER LINE.
  DATA: lt_yknvp TYPE STANDARD TABLE OF fknvp WITH HEADER LINE.
  DATA: ls_yknvp TYPE fknvp. " WITH HEADER LINE.
  DATA: lv_temp(5).
  DATA: lv_flag(1).
  DATA: lv_sw(1).
  DATA: lv_name(15).
  CLEAR: p_kunnr.
  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = lt_customer ).
  IF lt_customer-customer[] IS NOT INITIAL.
    LOOP AT lt_customer-customer INTO ls_customer.
      lv_name = ls_customer-phone_cust.
      CLEAR: ls_kna1, lt_kna1[], ls_bapiaddr1, lt_bapiaddr1[], ls_knvv, lt_knvv[],
             ls_knvi, lt_knvi[], ls_knb1,  lt_knb1[], ls_okna1, lv_kunnr, lv_sort1, lv_flag.
      lv_sort1 = ls_customer-phone_cust.
      SELECT SINGLE addrnumber INTO lv_addrnumber FROM adrc WHERE sort1 = lv_sort1.
      SELECT SINGLE kunnr INTO lv_kunnr FROM kna1 WHERE adrnr = lv_addrnumber.
      IF sy-subrc EQ 0.
        ls_kna1-kunnr = lv_kunnr.
        ls_knvv-kunnr = lv_kunnr.
        ls_knvi-kunnr = lv_kunnr.
        ls_knb1-kunnr = lv_kunnr.
        p_kunnr =  lv_kunnr..
        lv_flag = 'C'.
      ENDIF.
      ls_kna1-ktokd = 'ZTS4'.
      ls_kna1-mcod2 = ls_customer-phone_cust.
      ls_kna1-sortl = ls_customer-phone_cust.
      ls_kna1-name2 = ls_customer-phone_cust.
      ls_kna1-name1 = ls_customer-nama_cust.
      ls_kna1-name3 = gv_no_order.
      ls_kna1-regio = ls_customer-sap_region_id.
      ls_kna1-ort01 = ls_customer-kota_cust.
      ls_kna1-ort02 = ls_customer-kecamatan.
      ls_kna1-pstlz = ls_customer-zip_cust.
      "      ls_kna1-sortl = ls_customer-store_code.
      ls_kna1-spras = sy-langu.
      ls_kna1-counc = '00'.
      APPEND ls_kna1 TO lt_kna1.

      ls_bapiaddr1-name     = ls_customer-nama_cust.
      ls_bapiaddr1-name_2   = ls_customer-phone_cust.
      ls_bapiaddr1-name_3   = gv_no_order.
      ls_bapiaddr1-country  = 'ID'.
      "    ls_bapiaddr1-region   = ls_customer-prov_cust.  " kode propinsi
      ls_bapiaddr1-city     = ls_customer-kota_cust.
      ls_bapiaddr1-district = ls_customer-kecamatan.
      ls_bapiaddr1-region = ls_customer-sap_region_id.
      ls_bapiaddr1-postl_cod1 = ls_customer-zip_cust.
      ls_bapiaddr1-str_suppl1 = ls_customer-alamat_cust1.
      ls_bapiaddr1-str_suppl2 = ls_customer-alamat_cust2.
      ls_bapiaddr1-sort2 = ls_customer-store_code.
      ls_bapiaddr1-sort1 = ls_customer-phone_cust.
      ls_bapiaddr1-langu = sy-langu.
      APPEND ls_bapiaddr1 TO lt_bapiaddr1.


      ls_knvv-vkbur = '3800'.
      ls_knvv-vkgrp = 'DO'.
      ls_knvv-kdgrp = 'T1'.
      ls_knvv-versg = '1'.
      ls_knvv-awahr = '100'.
      ls_knvv-vsbed = '00'.
      IF ls_customer-tdn_plant IS INITIAL.
        ls_customer-tdn_plant = '3800'.
      ENDIF.
      ls_knvv-vwerk = ls_customer-tdn_plant.                " '3800'.
      SELECT SINGLE vsbed INTO ls_knvv-vsbed FROM tvstz WHERE werks  = ls_knvv-vwerk AND vstel = ls_knvv-vwerk.
      IF sy-subrc EQ 0.
      ENDIF.
      IF ls_knvv-vwerk = '3800'.
        ls_knvv-vsbed = '00'.
      ENDIF.
      ls_knvv-kztlf = 'C'.
      ls_knvv-autlf = 'X'.
      ls_knvv-vkorg	=	'8380'.
      ls_knvv-vtweg	=	'10'.
      ls_knvv-spart	=	'00'.
      APPEND ls_knvv TO lt_knvv.

      ls_knvi-aland	=	'ID'.
      ls_knvi-tatyp	=	'ZVAT'.
      ls_knvi-taxkd	=	'6'.
      APPEND ls_knvi TO lt_knvi.
      ls_knb1-bukrs = '8380'.
      APPEND ls_knb1 TO lt_knb1.


      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
        EXPORTING
          i_kna1                  = ls_kna1
          i_knb1                  = ls_knb1
          i_knvv                  = ls_knvv
          i_bapiaddr1             = ls_bapiaddr1
        IMPORTING
          e_kunnr                 = lv_kunnr
          o_kna1                  = ls_okna1
        TABLES
          "          t_xknvp                 = lt_xknvp
          t_xknvi                 = lt_knvi
        EXCEPTIONS
          client_error            = 1
          kna1_incomplete         = 2
          knb1_incomplete         = 3
          knb5_incomplete         = 4
          knvv_incomplete         = 5
          kunnr_not_unique        = 6
          sales_area_not_unique   = 7
          sales_area_not_valid    = 8
          insert_update_conflict  = 9
          number_assignment_error = 10
          number_not_in_range     = 11
          number_range_not_extern = 12
          number_range_not_intern = 13
          account_group_not_valid = 14
          parnr_invalid           = 15
          bank_address_invalid    = 16
          tax_data_not_valid      = 17
          no_authority            = 18
          company_code_not_unique = 19
          dunning_data_not_valid  = 20
          knb1_reference_invalid  = 21
          cam_error               = 22
          OTHERS                  = 23.
      IF sy-subrc NE 0.
        WRITE: sy-subrc TO lv_temp.
        CONCATENATE 'Error Message Code : ' lv_temp INTO p_message.
        "      WRITE: / 'Code: ', sy-subrc.
        "      WRITE: / wa_order-no_order, sy-vline, wa_order-phone_cust, sy-vline, wa_order-nama_cust, ' --> ', lv_kunnr.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        IF lv_flag = 'C'.
        ELSE.
          p_kunnr = lv_kunnr.
        ENDIF.
        CLEAR: p_message.
        "      WRITE: / wa_order-no_order, sy-vline, wa_order-phone_cust, sy-vline, wa_order-nama_cust, ' --> ', lv_kunnr.
        CLEAR: ls_kna1, ls_knvv, ls_knvi, ls_knb1.
        SELECT SINGLE * INTO ls_kna1 FROM kna1 WHERE kunnr = p_kunnr.
        SELECT SINGLE * INTO ls_knvv FROM knvv WHERE kunnr = p_kunnr.
        SELECT SINGLE * INTO ls_knb1 FROM knb1 WHERE kunnr = p_kunnr.

        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_xknvp FROM knvp WHERE kunnr = p_kunnr.
        CLEAR: lv_sw.
        LOOP AT lt_xknvp.
          MOVE-CORRESPONDING lt_xknvp TO lt_yknvp.
          IF lt_yknvp-parvw = 'ZS'.
            IF ls_customer-kode_ba IS NOT INITIAL.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_customer-kode_ba
                IMPORTING
                  output = lt_yknvp-kunn2.
              "          lt_xknvp-kunn2 = ls_customer-kode_ba.
              SELECT SINGLE kunnr INTO lt_yknvp-kunn2 FROM kna1 WHERE kunnr = lt_yknvp-kunn2.
              IF sy-subrc EQ 0.
                "                lt_yknvp-kz = 'U'.
                lv_sw = 'T'.
              ENDIF.
            ENDIF.
          ELSE.
            IF lt_yknvp-kunn2 EQ lt_yknvp-kunnr.
              lt_yknvp-kunn2 = 'TS101'.
            ENDIF.
          ENDIF.
          APPEND lt_yknvp.
        ENDLOOP.
**        LOOP AT lt_xknvp.
**          IF lt_xknvp-parvw = 'WE'.
**            IF lt_xknvp-kunn2 = lt_xknvp-kunnr.
**              CONTINUE.
**            ENDIF.
**            lt_xknvp-kunn2 = lt_xknvp-kunnr.
**          ELSEIF  lt_xknvp-parvw = 'ZS'.
**            IF ls_customer-kode_ba IS NOT INITIAL.
**              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**                EXPORTING
**                  input  = ls_customer-kode_ba
**                IMPORTING
**                  output = lt_xknvp-kunn2.
**              "          lt_xknvp-kunn2 = ls_customer-kode_ba.
**              SELECT SINGLE kunnr INTO lt_xknvp-kunn2 FROM kna1 WHERE kunnr = lt_xknvp-kunn2.
**              IF sy-subrc EQ 0.
**                lt_xknvp-kz = 'U'.
**                lv_sw = 'T'.
**              ENDIF.
**            ENDIF.
**          ELSE.
**            IF lt_xknvp-kunn2 EQ lt_xknvp-kunnr.
**              lt_xknvp-kunn2 = 'TS101'.
**            ENDIF.
**          ENDIF.
**          "          lt_xknvp-kz = 'U'.
**          APPEND lt_xknvp TO lt_yknvp.
**          MODIFY lt_xknvp.
**        ENDLOOP.
        IF ls_customer-kode_ba IS NOT INITIAL AND lv_sw NE 'T'.
          MOVE-CORRESPONDING lt_xknvp TO lt_yknvp.
          lt_yknvp-parvw = 'ZS'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_customer-kode_ba
            IMPORTING
              output = lt_yknvp-kunn2.
          "          lt_xknvp-kunn2 = ls_customer-kode_ba.
          SELECT SINGLE kunnr INTO lt_yknvp-kunn2 FROM kna1 WHERE kunnr = lt_yknvp-kunn2.
          IF sy-subrc EQ 0.
            SELECT SINGLE kunnr INTO lt_yknvp-kunnr FROM knvp
              WHERE kunnr = lt_yknvp-kunnr
                AND kunn2 = lt_yknvp-kunn2
                AND parvw = 'ZS'.
            IF sy-subrc EQ 0.
              lt_yknvp-kz = 'U'.
            ELSE.
              lt_yknvp-kz = 'I'.
            ENDIF.
            APPEND lt_yknvp.
            "            APPEND lt_xknvp.
          ENDIF.
        ENDIF.
        IF lt_yknvp[] IS NOT INITIAL.
          SORT lt_yknvp BY kunnr vkorg.
          DELETE ADJACENT DUPLICATES FROM lt_yknvp COMPARING ALL FIELDS.
        ENDIF.
        IF lt_xknvp[] IS NOT INITIAL.
          SORT lt_xknvp BY kunnr vkorg.
          DELETE ADJACENT DUPLICATES FROM lt_xknvp COMPARING ALL FIELDS.
        ENDIF.
        "      APPEND lt_xknvp.
        CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
          EXPORTING
            i_kna1                  = ls_kna1
            i_knb1                  = ls_knb1
            i_knvv                  = ls_knvv
          IMPORTING
            e_kunnr                 = lv_kunnr " i_bapiaddr1 = ls_bapiaddr1
            o_kna1                  = ls_okna1
          TABLES " t_xknvi = lt_knvi
            t_xknvp                 = lt_yknvp
            t_yknvp                 = lt_xknvp
            "            T_XKNVL
          EXCEPTIONS
            client_error            = 1
            kna1_incomplete         = 2
            knb1_incomplete         = 3
            knb5_incomplete         = 4
            knvv_incomplete         = 5
            kunnr_not_unique        = 6
            sales_area_not_unique   = 7
            sales_area_not_valid    = 8
            insert_update_conflict  = 9
            number_assignment_error = 10
            number_not_in_range     = 11
            number_range_not_extern = 12
            number_range_not_intern = 13
            account_group_not_valid = 14
            parnr_invalid           = 15
            bank_address_invalid    = 16
            tax_data_not_valid      = 17
            no_authority            = 18
            company_code_not_unique = 19
            dunning_data_not_valid  = 20
            knb1_reference_invalid  = 21
            cam_error               = 22
            OTHERS                  = 23.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.
    PERFORM f_create_text_json(ztdsit_i001) USING lv_json_data lv_name '/inbound/tdn/customer/' 'TDN_CREATECUST'.
  ELSE.
    CLEAR: p_kunnr.
  ENDIF.
ENDFORM.                    " F_CONVERT_JSON
