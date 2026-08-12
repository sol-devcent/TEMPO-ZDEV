FUNCTION ztspppfm002.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      IT_ADD STRUCTURE  ZPPRESB_ADD
*"      IT_DRESB STRUCTURE  RESB
*"      IT_URESB STRUCTURE  RESB
*"      IT_ONR00 STRUCTURE  ONR00
*"      IT_JEST STRUCTURE  JEST
*"      IT_JSTO STRUCTURE  JSTO
*"      IT_ZKMMPPDT024 STRUCTURE  ZKMMPPDT024 OPTIONAL
*"      IT_ZKMMPPDT023 STRUCTURE  ZKMMPPDT023 OPTIONAL
*"      IT_ZKMMPPDT019 STRUCTURE  ZKMMPPDT019 OPTIONAL
*"      IT_ZTSPPPDT011 STRUCTURE  ZTSPPPDT011 OPTIONAL
*"      IT_ZTSPPPDT012 STRUCTURE  ZTSPPPDT012 OPTIONAL
*"      IT_ZSFFPPDT002 STRUCTURE  ZSFFPPDT002 OPTIONAL
*"      IT_ZSFFPPDT004 STRUCTURE  ZSFFPPDT004 OPTIONAL
*"  EXCEPTIONS
*"      ERROR_DELETE_RESB
*"      ERROR_UPDATE_RESB
*"      ERROR_DELETE_ONR00
*"      ERROR_DELETE_JEST
*"      ERROR_DELETE_JSTO
*"      ERROR_DELETE_ZPPRESB_ADD
*"      ERROR_DELETE_ZKMMPPDT019
*"      ERROR_DELETE_ZTSPPPDT011
*"      ERROR_DELETE_ZTSPPPDT012
*"      ERROR_DELETE_ZSFFPPDT002
*"      ERROR_DELETE_ZKMMPPDT023
*"      ERROR_DELETE_ZKMMPPDT024
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
        DELETE onr00 FROM TABLE it_onr00.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_onr00.
    ENDIF.
  ENDIF.

  IF it_jest[] IS NOT INITIAL.
    TRY .
        DELETE jest FROM TABLE it_jest.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_jest.
    ENDIF.
  ENDIF.

  IF it_jsto[] IS NOT INITIAL.
    TRY .
        DELETE jsto FROM TABLE it_jsto.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_jsto.
    ENDIF.
  ENDIF.

  IF it_dresb[] IS NOT INITIAL.
    TRY .
        DELETE resb FROM TABLE it_dresb.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_resb.
    ENDIF.
  ENDIF.

  IF it_add[] IS NOT INITIAL.
    TRY .
        DELETE zppresb_add FROM TABLE it_add.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_zppresb_add.
    ENDIF.
  ENDIF.

  IF it_zkmmppdt023[] IS NOT INITIAL.
    TRY .
        DELETE zkmmppdt023 FROM TABLE it_zkmmppdt023.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_zkmmppdt023.
    ENDIF.
  ENDIF.

  IF it_zkmmppdt024[] IS NOT INITIAL.
    TRY .
        DELETE zkmmppdt024 FROM TABLE it_zkmmppdt024.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_zkmmppdt024.
    ENDIF.
  ENDIF.

  IF it_zkmmppdt019[] IS NOT INITIAL.
    TRY .
        DELETE zkmmppdt019 FROM TABLE it_zkmmppdt019.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_zkmmppdt019.
    ENDIF.
  ENDIF.

  IF it_ztspppdt011[] IS NOT INITIAL.
    TRY .
        DELETE ztspppdt011 FROM TABLE it_ztspppdt011.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_ztspppdt011.
    ENDIF.
  ENDIF.

  IF it_ztspppdt012[] IS NOT INITIAL.
    TRY .
        MODIFY ztspppdt012 FROM TABLE it_ztspppdt012.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_ztspppdt012.
    ENDIF.
  ENDIF.

  IF it_zsffppdt002[] IS NOT INITIAL.
    TRY .
        DELETE zsffppdt002 FROM TABLE it_zsffppdt002.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_zsffppdt002.
    ENDIF.
  ENDIF.

  IF it_zsffppdt004[] IS NOT INITIAL.
    TRY .
        DELETE zsffppdt004 FROM TABLE it_zsffppdt004.
      CATCH cx_sy_open_sql_db INTO oref.
        lv_message = oref->get_text( ).
    ENDTRY.

    IF lv_message IS NOT INITIAL.
      RAISE error_delete_zsffppdt004.
    ENDIF.
  ENDIF.
ENDFUNCTION.
