FUNCTION ztspppfm001.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      IT_ADD STRUCTURE  ZPPRESB_ADD
*"      IT_IRESB STRUCTURE  RESB
*"      IT_URESB STRUCTURE  RESB
*"      IT_ONR00 STRUCTURE  ONR00
*"      IT_JEST STRUCTURE  JEST OPTIONAL
*"      IT_JSTO STRUCTURE  JSTO OPTIONAL
*"      IT_ZKMMPPDT019 STRUCTURE  ZKMMPPDT019 OPTIONAL
*"      IT_ZSFFPPDT004 STRUCTURE  ZSFFPPDT004 OPTIONAL
*"      IT_ZKMMPPDT024 STRUCTURE  ZKMMPPDT024 OPTIONAL
*"  EXCEPTIONS
*"      ERROR_INSERT_RESB
*"      ERROR_UPDATE_RESB
*"      ERROR_INSERT_ONR00
*"      ERROR_INSERT_ZPPRESB_ADD
*"      ERROR_INSERT_JEST
*"      ERROR_INSERT_JSTO
*"      ERROR_INSERT_ZKMMPPDT019
*"      ERROR_INSERT_ZSFFPPDT004
*"      ERROR_INSERT_ZKMMPPDT024
*"----------------------------------------------------------------------

  DATA : oref            TYPE REF TO cx_root,
         lv_message(100).

  IF it_uresb[] IS NOT INITIAL.
    TRY .
        UPDATE resb FROM TABLE it_uresb.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_update_resb.
    ENDIF.
  ENDIF.

  IF it_onr00[] IS NOT INITIAL.
    TRY .
        INSERT onr00 FROM TABLE it_onr00.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_onr00.
    ENDIF.
  ENDIF.

  IF it_jest[] IS NOT INITIAL.
    TRY .
        INSERT jest FROM TABLE it_jest.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_jest.
    ENDIF.
  ENDIF.

  IF it_jsto[] IS NOT INITIAL.
    TRY .
        INSERT jsto FROM TABLE it_jsto.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_jsto.
    ENDIF.
  ENDIF.

  IF it_iresb[] IS NOT INITIAL.
    TRY .
        INSERT resb FROM TABLE it_iresb.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_resb.
    ENDIF.
  ENDIF.

  IF it_add[] IS NOT INITIAL.
    TRY .
        INSERT zppresb_add FROM TABLE it_add.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_zppresb_add.
    ENDIF.
  ENDIF.

  IF it_zkmmppdt019[] IS NOT INITIAL.
    TRY .
        INSERT zkmmppdt019 FROM TABLE it_zkmmppdt019.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_zkmmppdt019.
    ENDIF.
  ENDIF.

  IF it_zkmmppdt024[] IS NOT INITIAL.
    TRY .
        INSERT zkmmppdt024 FROM TABLE it_zkmmppdt024.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_zkmmppdt024.
    ENDIF.
  ENDIF.

  IF it_zsffppdt004[] IS NOT INITIAL.
    TRY .
        INSERT zsffppdt004 FROM TABLE it_zsffppdt004.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_insert_zsffppdt004.
    ENDIF.
  ENDIF.
ENDFUNCTION.
