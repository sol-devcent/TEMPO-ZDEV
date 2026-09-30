*----------------------------------------------------------------------*
***INCLUDE LZWMSFG001F05.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_POST_DCC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_TO  text
*      -->PI_DATA  text
*----------------------------------------------------------------------*
FORM f_proses_post_dcc  TABLES   pt_dcc   STRUCTURE zwmsst010
                        USING    p_json
                        CHANGING p_invno p_status p_message.


  TYPES:
    BEGIN OF ty_dcc_d,
      dcc_number            TYPE string,
      dcc_item_number       TYPE c LENGTH 4,
      quant_counter         TYPE c LENGTH 10,
      material_number       TYPE c LENGTH 18,
      material_description  TYPE c LENGTH 40,
      batch                 TYPE c LENGTH 18,
      stock_category        TYPE c LENGTH 1,
      shelf_life_expiration TYPE c LENGTH 10,
      quantity_satuan       TYPE c LENGTH 15,
      uom_satuan            TYPE c LENGTH 3,
      quantity_carton       TYPE c LENGTH 15,
      uom_carton            TYPE c LENGTH 3,
      zero_indicator        TYPE c LENGTH 1,
      new_item_indicator    TYPE c LENGTH 1,
    END OF ty_dcc_d ,

    BEGIN OF ty_dcc,
      warehouse    TYPE c LENGTH 3,
      storage_type TYPE c LENGTH 3,
      storage_bin  TYPE c LENGTH 10,
      dcc_number   TYPE c LENGTH 10,
      counted_by   TYPE c LENGTH 12,
      counted_date TYPE c LENGTH 10,
      counted_time TYPE c LENGTH 10,
      nav_dcc      TYPE TABLE OF ty_dcc_d WITH DEFAULT KEY,
    END OF  ty_dcc .
  DATA: ls_zwmsst010 TYPE zwmsst010.
  DATA: ls_dcc    TYPE ty_dcc.
  DATA : lv_json_data  TYPE string.
  DATA: ls_dcc_d TYPE ty_dcc_d.
  DATA: lt_zbpc0005 TYPE STANDARD TABLE OF zbpc0005 WITH DEFAULT KEY.
  DATA: lt_zbpc0005_upd TYPE STANDARD TABLE OF zbpc0005 WITH DEFAULT KEY.
  DATA: ls_zbpc0005 TYPE zbpc0005.

  DATA: lv_lgnum TYPE zbpc0005-lgnum.
  DATA: lv_lgtyp TYPE zbpc0005-lgtyp.
  DATA: lv_lgpla TYPE zbpc0005-lgpla.
  DATA: lv_ivnum TYPE zbpc0005-ivnum.
  DATA: lv_ivpos TYPE zbpc0005-ivpos.
  DATA: lv_werks TYPE zbpc0005-werks.
  DATA: lt_marm TYPE STANDARD TABLE OF marm.
  DATA: ls_marm TYPE marm.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_dcc  ).
  lv_lgnum = ls_dcc-warehouse.
  lv_lgtyp = ls_dcc-storage_type.
  lv_lgpla = ls_dcc-storage_bin.
  lv_ivnum = ls_dcc-dcc_number.
  p_invno = ls_dcc-dcc_number.
  CONDENSE: lv_lgnum, lv_lgtyp, lv_lgpla, lv_ivnum.
  ls_zwmsst010-warehouse = ls_dcc-warehouse.
  ls_zwmsst010-storage_type = ls_dcc-storage_type.
  ls_zwmsst010-storage_bin = ls_dcc-storage_bin.
  ls_zwmsst010-dcc_number = ls_dcc-dcc_number.
  " CONCATENATE '%' lv_ivnum '%' INTO lv_ivnum.
  CONDENSE lv_ivnum.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zbpc0005
    FROM zbpc0005
    WHERE lgnum = lv_lgnum AND
          lgtyp = lv_lgtyp AND
          lgpla = lv_lgpla AND
          ivnum = lv_ivnum.
  IF sy-subrc EQ 0.
    SELECT SINGLE MAX( ivpos ) MAX( werks ) INTO (lv_ivpos, lv_werks)
    FROM zbpc0005
    WHERE lgnum = lv_lgnum AND
          lgtyp = lv_lgtyp AND
          lgpla = lv_lgpla AND
          ivnum = lv_ivnum.
    IF lt_zbpc0005[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_marm FROM marm
        FOR ALL ENTRIES IN lt_zbpc0005
        WHERE matnr = lt_zbpc0005-matnr AND
              meinh = 'KAR'.
    ENDIF.
    SORT lt_zbpc0005 BY ivnum ivpos.
    SORT ls_dcc-nav_dcc BY dcc_item_number material_number.
    LOOP AT ls_dcc-nav_dcc INTO ls_dcc_d.
      ls_zwmsst010-quant_counter = ls_dcc_d-quant_counter.
      ls_zwmsst010-material_number = ls_dcc_d-material_number.
      IF ls_dcc_d-batch(1) = '?'.
        ls_dcc_d-batch(1) = ' '.
      ENDIF.
      ls_zwmsst010-batch = ls_dcc_d-batch.
      ls_zwmsst010-quantity_satuan = ls_dcc_d-quantity_satuan.
      ls_zwmsst010-uom_satuan = ls_dcc_d-uom_satuan.
      ls_zwmsst010-quantity_carton = ls_dcc_d-quantity_carton.
      ls_zwmsst010-uom_carton = ls_dcc_d-uom_carton.
      ls_zwmsst010-zero_indicator = ls_dcc_d-zero_indicator.
      ls_zwmsst010-new_item_indicator = ls_dcc_d-new_item_indicator.
      ls_zwmsst010-status = 'S'.
      SORT lt_zbpc0005 BY ivnum ivpos matnr lgnum charg.
      READ TABLE lt_zbpc0005 INTO ls_zbpc0005
           WITH KEY ivpos = ls_dcc_d-dcc_item_number
                    matnr = ls_dcc_d-material_number
                    lqnum = ls_dcc_d-quant_counter
                    charg = ls_dcc_d-batch
                    BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF ls_dcc_d-zero_indicator = 'X'.
          CLEAR: ls_zbpc0005-menga, ls_zbpc0005-menge.
          ls_zbpc0005-kznul = 'X'.
        ELSE.
          ls_zbpc0005-menga = ls_dcc_d-quantity_carton.
          ls_zbpc0005-menge = ls_dcc_d-quantity_satuan.
          ls_zbpc0005-altme = ls_dcc_d-uom_carton.
          IF ls_zbpc0005-menga NE 0.
            SORT lt_marm BY matnr.
            READ TABLE lt_marm INTO ls_marm
            WITH KEY matnr = ls_dcc_d-material_number "meinh = 'CAR'
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              ls_zbpc0005-gesme1 = ls_zbpc0005-menga * ls_marm-umrez.
              ls_zbpc0005-gesme1 = ls_zbpc0005-gesme1 + ls_zbpc0005-menge.
            ENDIF.
          ENDIF.
          ls_zbpc0005-altme = 'CAR'. "ls_dcc_d-uom_carton.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = ls_zbpc0005-altme
            IMPORTING
              output         = ls_zbpc0005-altme
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
        ENDIF.
        ls_zbpc0005-zcoudt = ls_dcc-counted_date.
        ls_zbpc0005-zcouzt = ls_dcc-counted_time.
        ls_zbpc0005-zcouun = ls_dcc-counted_by.
        APPEND ls_zbpc0005 TO lt_zbpc0005_upd.
      ELSE.
        IF ls_dcc_d-new_item_indicator = 'X'.
          CLEAR: ls_zbpc0005.
          ls_zbpc0005-lgnum =  ls_dcc-warehouse.
          ls_zbpc0005-lgtyp =  ls_dcc-storage_type.
          ls_zbpc0005-lgpla = ls_dcc-storage_bin.
          ls_zbpc0005-ivnum = ls_dcc-dcc_number.
          lv_ivpos = lv_ivpos + 1.
          ls_zbpc0005-ivpos = lv_ivpos. "ls_dcc_d-dcc_item_number.
          ls_zbpc0005-matnr = ls_dcc_d-material_number.
          ls_zbpc0005-charg = ls_dcc_d-batch.
          ls_zbpc0005-werks = lv_werks.
          ls_zbpc0005-meins = ls_dcc_d-uom_satuan.
          ls_zbpc0005-lqnum = ls_dcc_d-quant_counter.
          ls_zbpc0005-menge = ls_dcc_d-quantity_satuan.
          ls_zbpc0005-menga = ls_dcc_d-quantity_carton.
          IF ls_zbpc0005-menga NE 0.
            SORT lt_marm BY matnr.
            READ TABLE lt_marm INTO ls_marm
            WITH KEY matnr = ls_dcc_d-material_number "meinh = 'CAR'
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              ls_zbpc0005-gesme1 = ls_zbpc0005-menga * ls_marm-umrez.
              ls_zbpc0005-gesme1 = ls_zbpc0005-gesme1 + ls_zbpc0005-menge.
            ENDIF.
          ENDIF.
          ls_zbpc0005-altme = 'CAR'. "ls_dcc_d-uom_carton.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = ls_zbpc0005-altme
            IMPORTING
              output         = ls_zbpc0005-altme
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          ls_zbpc0005-zcoudt = ls_dcc-counted_date.
          ls_zbpc0005-zcouzt = ls_dcc-counted_time.
          ls_zbpc0005-zcouun = ls_dcc-counted_by.
          ls_zbpc0005-addni = 'X'.
          "          MODIFY zbpc0005 FROM ls_zbpc0005.
          APPEND ls_zbpc0005 TO lt_zbpc0005_upd.
          CLEAR: ls_zbpc0005.
        ELSE.
          ls_zwmsst010-status = 'E'.
          ls_zwmsst010-message = 'Data tidak ditemukan'.
        ENDIF.
      ENDIF.
      IF ls_zwmsst010-status = 'E'.
        p_status = 'E'.
        p_message = ls_zwmsst010-message.
      ENDIF.
      APPEND ls_zwmsst010 TO pt_dcc.
      CLEAR: ls_zwmsst010.
    ENDLOOP.
  ELSE.
    p_status = 'E'.
    CONCATENATE 'DCC no.' ls_zwmsst010-dcc_number ' tidak ditemukan ditable ZBPC00005' INTO  p_message.
    ls_zwmsst010-status = 'E'.
    ls_zwmsst010-message = p_message.
    "    APPEND ls_zwmsst010 TO pt_dcc.
    p_status = 'E'.
  ENDIF.
  DATA: lv_subrc TYPE sy-subrc.
  IF lt_zbpc0005_upd[] IS NOT INITIAL.
    CLEAR: lv_subrc.
    PERFORM f_save_zbpc005 TABLES lt_zbpc0005_upd
                           CHANGING lv_subrc.
    IF lv_subrc NE 0.
      LOOP AT pt_dcc INTO ls_zwmsst010.
        ls_zwmsst010-status = 'E'.
        ls_zwmsst010-message = 'Gagal Update Table ZBPC00005'.
        MODIFY pt_dcc FROM ls_zwmsst010 TRANSPORTING status message.
        p_status = 'E'.
        CONCATENATE 'DCC no.' lv_ivnum ' Gagal Update Table ZBPC00005' INTO  p_message.
      ENDLOOP.
    ENDIF.
    "proses update table zbpc0005
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_ZBPC005
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZPBC005  text
*----------------------------------------------------------------------*
FORM f_save_zbpc005  TABLES   pt_dcc STRUCTURE zbpc0005
                 CHANGING fc_subrc.
  DATA : ls_zbpc0005   TYPE zbpc0005.

  CLEAR fc_subrc.
  LOOP AT pt_dcc INTO ls_zbpc0005.
    IF ls_zbpc0005 IS NOT INITIAL.
      TRY .
          MODIFY zbpc0005 FROM ls_zbpc0005.
        CATCH cx_sy_open_sql_db.
          fc_subrc = 4.
      ENDTRY.
    ENDIF.
  ENDLOOP.
  IF fc_subrc = 0.
    COMMIT WORK.
  ENDIF.
ENDFORM.
