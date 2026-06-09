FUNCTION ztdnsd_f0009.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(KUNNR) TYPE  KUNNR
*"     REFERENCE(VWERK) TYPE  VWERK
*"     REFERENCE(KUNN2) TYPE  KUNNR
*"     REFERENCE(KUNRG) TYPE  KUNRG
*"  EXPORTING
*"     VALUE(SAP_ID) TYPE  KUNNR
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------

  DATA: ls_kna1 TYPE kna1. " WITH HEADER LINE.
  DATA: ls_okna1 TYPE kna1. " WITH HEADER LINE.
  DATA: ls_knvv TYPE knvv. " WITH HEADER LINE.
  DATA: gv_kunnr TYPE knvv-kunnr.
  DATA: gv_kunn2 TYPE knvv-kunnr.
  DATA: gv_vkbur TYPE knvv-vkbur.
  DATA: gv_kunrg TYPE kunrg.
  DATA: lv_kunnr TYPE kna1-kunnr.
  DATA: lv_message(100).

  "  DATA: gv_werks TYPE knvv-vwerk.

  DATA: lt_xknvp TYPE STANDARD TABLE OF fknvp WITH HEADER LINE.
  DATA: ls_xknvp TYPE fknvp. " WITH HEADER LINE.
  DATA: lt_yknvp TYPE STANDARD TABLE OF fknvp WITH HEADER LINE.
  DATA: ls_yknvp TYPE fknvp. " WITH HEADER LINE.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = kunnr
    IMPORTING
      output = gv_kunnr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = kunrg
    IMPORTING
      output = gv_kunrg.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = kunn2
    IMPORTING
      output = gv_kunn2.

  SELECT SINGLE kunnr INTO gv_kunn2 FROM kna1 WHERE kunnr = gv_kunn2.
  IF sy-subrc NE 0.
    status = 'E'.
    CONCATENATE 'Code Customer : ' gv_kunn2 'not found' INTO message SEPARATED BY space.
    RETURN.
  ENDIF.
  SELECT SINGLE kunnr INTO gv_kunrg FROM kna1 WHERE kunnr = gv_kunrg.
  IF sy-subrc NE 0.
    status = 'E'.
    CONCATENATE 'Code Customer : ' gv_kunrg 'not found' INTO message SEPARATED BY space.
    RETURN.
  ENDIF.

  CALL FUNCTION 'ZTDNSD_F0002'
    EXPORTING
      kunnr   = gv_kunn2
    IMPORTING
      kunnr   = lv_kunnr
      vkbur   = gv_vkbur
      message = lv_message.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_kna1 FROM kna1 WHERE kunnr = gv_kunnr.
  IF sy-subrc NE 0.
    status = 'E'.
    CONCATENATE 'Code Customer : ' gv_kunnr 'not found' INTO message SEPARATED BY space.
    RETURN.
  ELSE.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_knvv FROM knvv WHERE kunnr = gv_kunnr.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_xknvp FROM knvp WHERE kunnr = gv_kunnr.
  ENDIF.
  SELECT SINGLE werks INTO ls_knvv-vwerk FROM t001w WHERE werks = vwerk.
  IF sy-subrc NE 0.
    status = 'E'.
    CONCATENATE 'Delivery Plant : ' vwerk 'not found' INTO message SEPARATED BY space.
    RETURN.
  ENDIF.
  "  ls_knvv-vsbed = '00'.
  SELECT SINGLE vsbed INTO ls_knvv-vsbed FROM tvstz WHERE werks  = ls_knvv-vwerk AND vstel = ls_knvv-vwerk.
  IF vwerk = '3800'.
    ls_knvv-vsbed = '00'.
  ENDIF.
  ls_knvv-bzirk = gv_vkbur.
  IF lt_xknvp[] IS NOT INITIAL.
    LOOP AT lt_xknvp.
      MOVE-CORRESPONDING lt_xknvp TO lt_yknvp.
      "      lt_yknvp-kunn2 = gv_kunn2.
      IF lt_yknvp-parvw = 'AG' OR lt_yknvp-parvw = 'RE' OR lt_yknvp-parvw = 'RG'. "OR lt_yknvp-parvw = 'WE'
        lt_yknvp-kunn2 = gv_kunrg.
        lt_yknvp-kz = 'U'.
      ENDIF.
      IF lt_yknvp-parvw = 'ZS'.
        lt_yknvp-kunn2 = gv_kunn2.
        lt_yknvp-kz = 'U'.
      ENDIF.
      APPEND lt_yknvp.
    ENDLOOP.
  ELSE.
    status = 'E'.
    CONCATENATE 'Data Customer  : ' kunnr 'not found' INTO message SEPARATED BY space.
    RETURN.
  ENDIF.
  "  CLEAR: gv_kunnr.
  CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
    EXPORTING
      i_kna1                  = ls_kna1
"     i_knb1                  = ls_knb1
      i_knvv                  = ls_knvv
    IMPORTING
      e_kunnr                 = gv_kunnr " i_bapiaddr1 = ls_bapiaddr1
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
"     OTHERS                  = 23
      error_message           = 99.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    sap_id = ls_okna1-kunnr.
    status = 'S'.
    CONCATENATE 'Customer Code : ' ls_okna1-kunnr 'has been changed' INTO message SEPARATED BY space.
  ELSEIF sy-subrc = 99.
    CLEAR: sap_id.
    status = 'E'.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id        = sy-msgid
        lang      = sy-langu
        no        = sy-msgno
        v1        = sy-msgv1
        v2        = sy-msgv2
        v3        = sy-msgv3
        v4        = sy-msgv4
      IMPORTING
        msg       = message "gv_message
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
  ELSE.
    CLEAR: sap_id.
    status = 'E'.
    CONCATENATE 'Error : Change Customer Code : ' kunnr  INTO message SEPARATED BY space.
  ENDIF.
ENDFUNCTION.
