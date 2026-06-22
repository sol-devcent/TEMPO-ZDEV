FUNCTION zsfasd_f001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCESS) TYPE  CHAR30
*"     VALUE(PI_DATA) TYPE  STRING
*"     REFERENCE(PI_SORTL) TYPE  KNA1-SORTL OPTIONAL
*"  EXPORTING
*"     REFERENCE(CUSTOMER_CODE) TYPE  CHAR10
*"     REFERENCE(PI_TYPE) TYPE  CHAR1
*"     REFERENCE(PI_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
  DATA: ls_customer TYPE ty_customer.
  DATA : lv_json_data  TYPE string.

  DATA: ls_kna1 TYPE kna1. " WITH HEADER LINE.
  DATA: ls_knb1 TYPE knb1. " WITH HEADER LINE.
  DATA: ls_knvv TYPE knvv. " WITH HEADER LINE.
  DATA: ls_bapiaddr1 TYPE bapiaddr1.

  DATA: lt_knvi TYPE STANDARD TABLE OF fknvi WITH HEADER LINE.
  DATA: ls_knvi TYPE fknvi. " WITH HEADER LINE.
  DATA: lt_knvk TYPE STANDARD TABLE OF fknvk WITH HEADER LINE.
  DATA: ls_knvk TYPE knvk. " WITH HEADER LINE.

  DATA: lt_knvp TYPE STANDARD TABLE OF fknvp WITH HEADER LINE.
  DATA: ls_knvp TYPE fknvp. " WITH HEADER LINE.

  TYPES: BEGIN OF ty_data,
           search_term   TYPE string,
           customer_code TYPE string,
         END OF ty_data.
  DATA: ls_data TYPE ty_data.
  DATA: lv_nama(15).
  RANGES: s_kunnr FOR kna1-kunnr.
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: lv_knka  TYPE knka,
        lv_knkk  TYPE knkk,
        "  lv_knka  TYPE knka,
        lv_yknkk TYPE knkk.

  lv_json_data = pi_data.
  CONCATENATE 'Get_'  pi_sortl INTO lv_nama.

  PERFORM f_create_text_json(ztdsit_i001) USING lv_json_data lv_nama '/outbound/sfa/api/' 'SFA_CUSTOMER'.

  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_customer ).

  ls_kna1-land1 = 'ID'.
  ls_kna1-name1 = ls_customer-customer_name.
  ls_kna1-name2 = ls_customer-alamat_kirim1.
  ls_kna1-ort01 = ls_customer-city.
  ls_kna1-pstlz = ls_customer-postal_code_npwp.
  ls_kna1-regio = ls_customer-region. "ptt_ec_region. "/ls_customer-provinsi '17'.
  ls_kna1-sortl = ls_customer-search_term1.
  ls_kna1-telf1 = ls_customer-telephone.
  ls_kna1-telfx = ls_customer-fax.
  ls_kna1-anred = 'Company'.
  ls_kna1-brsch = ls_customer-industry.
  ls_kna1-bubkz = '0'.
  ls_kna1-erdat = sy-datum.
  ls_kna1-ernam = sy-uname.
  IF ls_customer-account_group IS INITIAL.
    IF ls_customer-sales_org = '8020'.
      ls_customer-account_group = 'ZC04'.
    ELSE.
      ls_customer-account_group = 'ZSU1'.
    ENDIF.
  ENDIF.
  ls_kna1-ktokd = ls_customer-account_group. "'ZC04'.
  ls_kna1-kukla = ls_customer-sales_force_grp. "'01'.
  ls_kna1-name3 = ls_customer-alamat_kirim2.
  ls_kna1-name4 = ls_customer-alamat_kirim3.
  ls_kna1-niels = ls_customer-ptt_ec_region. "'04'.
  ls_kna1-ort02 = ls_customer-kecamatan.
  ls_kna1-counc = '00'.
  ls_kna1-cityc = ls_customer-city_code.
  ls_kna1-spras = sy-langu.
  ls_kna1-stcd1 = ls_customer-nik.
  ls_kna1-stkza = 'X'.
  ls_kna1-lzone = ls_customer-transzone.
  ls_kna1-vbund = 'OUTLET'.
  ls_kna1-stceg = ls_customer-vat_reg_no. "ls_customer-company_npwp. "
  ls_kna1-gform = ls_customer-legal_status.
  ls_kna1-bran1 = '0001'.
  ls_kna1-katr1 = ls_customer-dklk. "'LK'.

  ls_knb1-bukrs = ls_customer-sales_org.
  ls_knb1-erdat = sy-datum.
  ls_knb1-ernam = sy-uname.
  ls_knb1-zuawa = ls_customer-sort_key.
  ls_knb1-akont = ls_customer-recon_account.
  ls_knb1-zterm =  ls_customer-term_of_payment."'ZT30'.

  ls_knvv-vkorg = ls_customer-sales_org.
  ls_knvv-vtweg = ls_customer-distiribution_channel."'10'.
  ls_knvv-spart = ls_customer-division."'00'.
  ls_knvv-ernam = sy-uname.
  ls_knvv-erdat = sy-datum.
  ls_knvv-versg = '1'.
  ls_knvv-kalks = '2'. "ls_customer-cust_pric_proc.
  ls_knvv-kdgrp = ls_customer-customer_group.
  ls_knvv-bzirk = ls_customer-sales_district. "'SLK1'.
  ls_knvv-konda = '01'. "ls_customer-price_group."
  ls_knvv-pltyp = '01'. "ls_customer-price_list. "
  ls_knvv-awahr = '100'.
  ls_knvv-inco1 = 'FCA'. "ls_customer-incoterms1. "
  ls_knvv-inco2 = 'FREE CARRIER'. "ls_customer-incoterms2. "
  ls_knvv-autlf = 'X'. "ls_customer-complete_delivery
  ls_knvv-antlf = '0'.
  ls_knvv-kztlf =  'C'. "ls_customer-partial_delivery." 'C'.
  ls_knvv-lprio =  ls_customer-delivery_priority. "'01'.
  ls_knvv-vsbed = '00'. "ls_customer-shipping_condition. " .
  ls_knvv-mrnkz = 'X'. "ls_customer-subinvoice. "
  ls_knvv-waers = 'IDR'.
  ls_knvv-ktgrd = ls_customer-account_assigment. "'01'.
  ls_knvv-zterm = ls_customer-term_of_payment. "'ZT30'.
  ls_knvv-vwerk = ls_customer-sales_office. "'0268'.
  ls_knvv-vkgrp = ls_customer-sales_group. "'110'.
  ls_knvv-vkbur = ls_customer-sales_office. "'0268'.
  "ls_knvv-VSORT =
  ls_knvv-kvgr1 = ls_customer-ptt_ec_region."'04'.
  ls_knvv-kvgr2 = ls_customer-sales_force_grp."'01'.
  ls_knvv-kvgr3 = ls_customer-customer_subgroup.
  "ls_knvv-KVGR4
  ls_knvv-kvgr5 = 'NKA'.
  ls_knvv-podkz = 'X'. "ls_customer-relevant_for_pod. "
  ls_bapiaddr1-title = 'Company'.
  ls_bapiaddr1-name = ls_customer-customer_name.
  ls_bapiaddr1-name_2 = ls_customer-alamat_kirim1.
  ls_bapiaddr1-name_3 = ls_customer-alamat_kirim2.
  ls_bapiaddr1-name_4 = ls_customer-alamat_kirim3.
  ls_bapiaddr1-c_o_name = ls_customer-company_npwp.
  ls_bapiaddr1-city = ls_customer-city.
  ls_bapiaddr1-district = ls_customer-kecamatan.
  ls_bapiaddr1-postl_cod1 = ls_customer-postal_code_npwp.
  ls_bapiaddr1-street = ls_customer-kelurahan.
  ls_bapiaddr1-str_suppl1 = ls_customer-alamat_npwp1.
  ls_bapiaddr1-str_suppl2 = ls_customer-alamat_npwp2.
  ls_bapiaddr1-str_suppl3 = ls_customer-alamat_npwp3.
  ls_bapiaddr1-location = ls_customer-location.
  ls_bapiaddr1-country = 'ID'.   "ls_customer-country_code
  ls_bapiaddr1-langu = sy-langu.
  ls_bapiaddr1-region = ls_customer-region. " ls_customer-provinsi '17'.
  ls_bapiaddr1-tel1_numbr = ls_customer-telephone.
  ls_bapiaddr1-sort1 = ls_customer-search_term1.
  ls_bapiaddr1-transpzone = ls_customer-transzone.
  ls_bapiaddr1-postl_cod1 = ls_customer-postal_code_npwp.
  ls_bapiaddr1-fax_number = ls_customer-fax.
  ls_bapiaddr1-e_mail = ls_customer-email.

  ls_knvi-aland = 'ID'.
  ls_knvi-tatyp = 'ZVAT'.
  IF ls_knvv-vkbur = '0246'.
    ls_knvi-taxkd = '0'. "khusus batam dibuat jadi 0
  ELSE.
    ls_knvi-taxkd = '1'. "ls_customer-tax_classification. "
  ENDIF.
  APPEND ls_knvi TO lt_knvi.

**** No Izin Sarana
  IF ls_customer-sika_no IS NOT INITIAL.
    CLEAR: ls_knvk.
    ls_knvk-namev = ls_customer-sika_expired_date.
    ls_knvk-name1 = ls_customer-sika_no.
    ls_knvk-abtnr = 'A5'.
    APPEND ls_knvk TO lt_knvk.
  ENDIF.
*** SIPA PJ
  IF ls_customer-sia_no IS NOT INITIAL.
    CLEAR: ls_knvk.
    ls_knvk-namev = ls_customer-sia_expired_date.
    ls_knvk-name1 = ls_customer-sia_no.
    ls_knvk-abtnr = 'A2'.
    APPEND ls_knvk TO lt_knvk.
  ENDIF.
**  --> Nama PJ
  IF ls_customer-contact_prsn_name IS NOT INITIAL.
    CLEAR: ls_knvk.
    ls_knvk-name1 = ls_customer-contact_prsn_name.
    ls_knvk-abtnr = 'A4'.
    APPEND ls_knvk TO lt_knvk.
  ENDIF.
**  --> Kode Sipnap
** --> NIB > nomor induk berusaha
  IF ls_customer-nib_no IS NOT INITIAL.
    CLEAR: ls_knvk.
    ls_knvk-namev = ls_customer-nib_expired_date.
    ls_knvk-name1 = ls_customer-nib_no.
    ls_knvk-abtnr = 'A6'.
    APPEND ls_knvk TO lt_knvk.
  ENDIF.


** collector_route_list
  IF ls_customer-collector_route_list IS NOT INITIAL.
    CLEAR: ls_knvp.
    ls_knvp-vkorg = ls_customer-sales_org.
    ls_knvp-vtweg = ls_customer-distiribution_channel."'10'.
    ls_knvp-spart = ls_customer-division."'00'.
    ls_knvp-parza = ' '.
    ls_knvp-parvw = 'ZC'.
    ls_knvp-kunn2 = ls_customer-collector_route_list.
    APPEND ls_knvp TO lt_knvp.
  ENDIF.
** delivery_route_list
  IF ls_customer-delivery_route_list IS NOT INITIAL.
    CLEAR: ls_knvp.
    ls_knvp-vkorg = ls_customer-sales_org.
    ls_knvp-vtweg = ls_customer-distiribution_channel."'10'.
    ls_knvp-spart = ls_customer-division."'00'.
    ls_knvp-parza = ' '.
    ls_knvp-parvw = 'ZS'.
    ls_knvp-kunn2 = ls_customer-delivery_route_list.
    APPEND ls_knvp TO lt_knvp.
  ENDIF.
  CLEAR: ls_knvp.
  ls_knvp-vkorg = ls_customer-sales_org.
  ls_knvp-vtweg = ls_customer-distiribution_channel."'10'.
  ls_knvp-spart = ls_customer-division."'00'.
  ls_knvp-parza = ' '.
  ls_knvp-parvw = 'ZT'.
  ls_knvp-kunn2 = 'TSB8020'.
  APPEND ls_knvp TO lt_knvp.

  DATA: lv_kunnr TYPE kna1-kunnr.
  DATA: p_return TYPE sy-subrc.

  CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
    EXPORTING
      i_kna1                  = ls_kna1
      i_knb1                  = ls_knb1
      i_knvv                  = ls_knvv
      i_bapiaddr1             = ls_bapiaddr1
    IMPORTING
      e_kunnr                 = lv_kunnr " i_bapiaddr1 = ls_bapiaddr1
"     o_kna1                  = ls_okna1
    TABLES
      t_xknvi                 = lt_knvi
      t_xknvk                 = lt_knvk
      t_xknvp                 = lt_knvp
    EXCEPTIONS
      client_error            = 1 "T_XKNVK STRUCTURE FKNVK OPTIONAL
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
  p_return = sy-subrc.
  IF sy-subrc NE 0.
    pi_type = p_return.
    CALL FUNCTION 'ZSFASD_F002'
      EXPORTING
        pi_subrc    = p_return
        pi_function = 'SD_CUSTOMER_MAINTAIN_ALL'
      IMPORTING
        pe_message  = pi_message.
    "    WRITE: / 'Code: ', sy-subrc.
    " WRITE: / wa_order-no_order, sy-vline, wa_order-phone_cust, sy-vline, wa_order-nama_cust, ' --> ', lv_kunnr.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    "    WRITE: / lv_kunnr.
    customer_code = lv_kunnr.
    pi_type = 'S'.
    CONCATENATE 'Search Term no.'  ls_customer-search_term1 ' terbentuk customer code : ' lv_kunnr
         INTO pi_message.

    CLEAR: lv_knkk, lv_knka.
    lv_knka-kunnr = lv_kunnr..
    lv_knkk-kunnr = lv_kunnr..
    lv_knkk-klimk = 1 / 100.
    lv_knkk-dbekr = 1 / 100.
    lv_knkk-dbwae = 'IDR'.
    lv_knkk-ctlpc = '800'.
    lv_knkk-sbgrp = '800'.
    lv_knkk-knkli = lv_kunnr.
    lv_knkk-aedat = sy-datum.
    lv_knkk-aenam = sy-uname.
    IF ls_customer-sales_org = '8020'.
      lv_knkk-kkber = '8000'.
    ELSE.
      lv_knkk-kkber = '8070'.
    ENDIF.

    CALL FUNCTION 'CREDITLIMIT_CHANGE' IN UPDATE TASK
      EXPORTING
        i_knka   = lv_knka
        i_knkk   = lv_knkk
        upd_knka = ''
        upd_knkk = 'I'
        yknka    = lv_knka
        yknkk    = lv_yknkk
        xneua    = ''
        xrefl    = ''.
    IF sy-subrc EQ 0.
**      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
**        EXPORTING
**          wait = 'X'.
    ELSE.
      pi_message =  'Update Credit Limit permanen Gagal'.
    ENDIF.
*    MODIFY knkk FROM lv_knkk.
*    MODIFY knka FROM lv_knka.
    COMMIT WORK AND WAIT.

    ls_data-search_term   = ls_customer-search_term1.
    ls_data-customer_code = ls_customer-customer_code.
    CREATE OBJECT zl_json_data
      EXPORTING
        data = ls_data.
    zl_json_data->serialize( ).
    lv_json_data = zl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING lv_json_data 'SFA_CUSTOMER' sy-subrc lv_str.
    CONCATENATE 'Post_'  pi_sortl INTO lv_nama.

    CONDENSE lv_nama.
    PERFORM f_create_text_json(ztdsit_i001) USING lv_json_data lv_nama '/outbound/sfa/api/' 'SFA_CUSTOMER'.
    REFRESH s_kunnr.
    s_kunnr-sign = 'I'.
    s_kunnr-option = 'EQ'.
    s_kunnr-low = lv_kunnr.
    APPEND s_kunnr.

    SUBMIT rbdsedeb WITH selkunnr IN s_kunnr
                    WITH mestyp = 'DEBMAS'
                    WITH logsys = 'SFA'
                    AND RETURN.

  ENDIF.
ENDFUNCTION.
