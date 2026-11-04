CLASS zstatus_approved_pemusnahan DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             status  TYPE char1,
             message TYPE char255,
           END OF ty_result.
    TYPES: tt_result TYPE TABLE OF ty_result WITH EMPTY KEY.
*    TYPES: BEGIN OF ty_detl,
*             approved_user   TYPE c LENGTH 12,
*             approved_status TYPE c LENGTH 50,
*             approved_date   TYPE c LENGTH 10,
*             approved_time   TYPE c LENGTH 8,
*           END OF ty_detl.
*    TYPES: tt_detl TYPE TABLE OF ty_detl WITH EMPTY KEY.
    TYPES: tt_detl TYPE TABLE OF zcl_zup_web_srv_mpc_ext=>ts_details WITH EMPTY KEY,
           tt_001  TYPE TABLE OF zgdmmt0001 WITH EMPTY KEY,
           tt_005  TYPE TABLE OF zgdmmt0005 WITH EMPTY KEY.
    METHODS: run
      IMPORTING ls_header        TYPE zcl_zup_web_srv_mpc_ext=>ts_statusapproved
                lt_detl          TYPE tt_detl
      RETURNING VALUE(gt_result) TYPE tt_result.

PROTECTED SECTION.
  PRIVATE SECTION.
   METHODS: get_005
      IMPORTING ls_header     TYPE zcl_zup_web_srv_mpc_ext=>ts_statusapproved
      RETURNING VALUE(gt_005) TYPE tt_005.
    METHODS: get_001
      IMPORTING ls_header     TYPE zcl_zup_web_srv_mpc_ext=>ts_statusapproved
      RETURNING VALUE(gt_001) TYPE tt_001.
    METHODS: update_001
      IMPORTING ls_header        TYPE zcl_zup_web_srv_mpc_ext=>ts_statusapproved
                lt_detl          TYPE tt_detl
      RETURNING VALUE(gs_result) TYPE ty_result.
    METHODS: insert_005
      IMPORTING ls_header        TYPE zcl_zup_web_srv_mpc_ext=>ts_statusapproved
                lt_detl          TYPE tt_detl
      RETURNING VALUE(gt_result) TYPE tt_result.
  ENDCLASS.



CLASS zstatus_approved_pemusnahan IMPLEMENTATION.
    METHOD run.
      IF ls_header IS NOT INITIAL AND lt_detl[] IS NOT INITIAL.
        DATA(gt_001) = me->get_001( ls_header = ls_header ).
        DATA(gt_005) = me->get_005( ls_header = ls_header ).
        IF gt_001[] IS NOT INITIAL AND gt_005[] IS INITIAL.
          DATA(gs_result)  = me->update_001( ls_header = ls_header lt_detl = lt_detl ).
          IF gs_result-status = 'S'.
            gt_result = me->insert_005( ls_header = ls_header lt_detl = lt_detl ).
            COMMIT WORK AND WAIT.
          ELSE.
            gs_result-status = 'E'.
            gs_result-message = 'Fail to insert to table'.
            ROLLBACK WORK.
          ENDIF.
          APPEND gs_result TO gt_result.
        ELSE.
          IF gt_001[] IS INITIAL.
            gs_result-status = 'E'.
            gs_result-message = 'No data in table'.
          ELSEIF gt_005[] IS NOT INITIAL.
            gs_result-status = 'S'.
            gs_result-message = 'Data is in table'.
          ENDIF.
          APPEND gs_result TO gt_result.
        ENDIF.
      ENDIF.
    ENDMETHOD.
    METHOD update_001.
*    relstatus fileurl formatletter -> reqno werks lgort
      DATA(temp_detl) = VALUE tt_detl( FOR wa IN lt_detl WHERE ( rel_status = 'REJECT' ) ( wa ) ).
      IF temp_detl IS INITIAL.
        IF ls_header-up_number IS NOT INITIAL AND ls_header-lgort IS NOT INITIAL AND ls_header-werks IS NOT INITIAL.
          UPDATE zgdmmt0001 SET zurl = @ls_header-zurl, relstatus = 'X' WHERE req_no = @ls_header-up_number AND lgort = @ls_header-lgort AND werks = @ls_header-werks.
        ENDIF.
        IF sy-subrc = 0.
          gs_result-status = 'S'.
          gs_result-message = 'Success update table'.
        ELSE.
          gs_result-status = 'E'.
          gs_result-message = 'Update table error'.
        ENDIF.
      ELSE.
        TRY.
            IF ls_header-up_number IS NOT INITIAL AND ls_header-lgort IS NOT INITIAL AND ls_header-werks IS NOT INITIAL.
              UPDATE zgdmmt0001 SET status = 'DELETE', zurl = @ls_header-zurl WHERE req_no = @ls_header-up_number AND lgort = @ls_header-lgort AND werks = @ls_header-werks.
            ENDIF.

*        IF sy-subrc = 0.
            gs_result-status = 'S'.
            gs_result-message = 'Success update table'.
*        ELSE.
          CATCH cx_sy_open_sql_error INTO DATA(lo_err).
            gs_result-status = 'E'.
            gs_result-message = lo_err->get_text(  ).
*        ENDIF.
        ENDTRY.
      ENDIF.
    ENDMETHOD.
    METHOD insert_005.
      DATA: lt_005    TYPE TABLE OF zgdmmt0005,
            gs_result TYPE ty_result.
      LOOP AT lt_detl INTO DATA(ls_detl).
        APPEND INITIAL LINE TO lt_005 ASSIGNING FIELD-SYMBOL(<fs_005>).
        <fs_005>-up_number = ls_header-up_number.
        <fs_005>-werks = ls_header-werks.
        <fs_005>-lgort = ls_header-lgort.
        <fs_005>-username = ls_detl-username.
        CONCATENATE ls_detl-update_date+6(4) ls_detl-update_date+3(2) ls_detl-update_date(2) INTO <fs_005>-update_date.
        CONCATENATE ls_detl-update_time(2) ls_detl-update_time+3(2) ls_detl-update_time+6(2) INTO <fs_005>-update_time.
        <fs_005>-rel_status = ls_detl-rel_status.
      ENDLOOP.
      IF lt_005[] IS NOT INITIAL.
        TRY.
            INSERT zgdmmt0005 FROM TABLE lt_005.
*        IF sy-subrc = 0.
            gs_result-status = 'S'.
            gs_result-message = 'Success update table'.
            APPEND gs_result TO gt_result.
*        ELSE.
          CATCH cx_sy_open_sql_error INTO DATA(lo_err).
            gs_result-status = 'E'.
            gs_result-message = lo_err->get_text(  ).
            APPEND gs_result TO gt_result.
*        ENDIF.
        ENDTRY.
      ENDIF.
    ENDMETHOD.
     METHOD get_005.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_005 FROM zgdmmt0005
        WHERE up_number = ls_header-up_number
        AND werks = ls_header-werks
        AND lgort = ls_header-lgort.
    ENDMETHOD.
    METHOD get_001.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_001 FROM zgdmmt0001
        WHERE req_no = ls_header-up_number
        AND werks = ls_header-werks
        AND lgort = ls_header-lgort.
    ENDMETHOD.
ENDCLASS.
