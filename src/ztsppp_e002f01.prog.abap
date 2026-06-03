*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  gv_authorization  = 'X'.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  CASE sy-dynnr.
    WHEN '2999'.
      SET PF-STATUS 'STATUS_PASS'.
    WHEN OTHERS.
      SET PF-STATUS 'PFSTATUS'.
  ENDCASE.

  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_BEFORE_OUTPUT
*&---------------------------------------------------------------------*
FORM f_process_before_output .
  DATA : lv_subrc     TYPE sy-subrc,
         lv_lgort     TYPE mchb-lgort,
         ls_operation LIKE LINE OF gt_operation.

  DATA : ls_component   LIKE LINE OF gt_component.

  CASE sy-dynnr.
    WHEN '2999'.
      PERFORM f_pbo99.

    WHEN '0201'.
      PERFORM f_get_order.
      PERFORM f_with_password.

      IF gs_head-operator IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'OPR' '' '0' '' ''.
      ENDIF.
      IF gs_head-pengawas IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'AWS' '' '0' '' ''.
      ENDIF.

      IF gt_order[] IS INITIAL.
        IF gs_head-werks IS NOT INITIAL AND
          gs_head-gstrp IS NOT INITIAL AND
          gs_head-plnbez IS NOT INITIAL.
          PERFORM f_error_message USING 'E' 'Data not found' '' '' ''.
          CLEAR : gs_head-werks, gs_head-gstrp, gs_head-plnbez.
        ENDIF.

        APPEND INITIAL LINE TO gt_order.
        PERFORM f_modify_screen USING : 'ORD' '0' '' '' '',
                                        'NXT' '0' '' '' '',
                                        'UP' '0' '' '' '',
                                        'DN' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'HED' '' '0' '' ''.
      ENDIF.

      DESCRIBE TABLE gt_order LINES n2.

      IF gs_head-werks IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-WERKS' ''.
      ELSEIF gs_head-plnbez IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-PLNBEZ' ''.
      ELSEIF gs_head-gstrp IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-GSTRP' ''.
      ELSEIF gs_head-operator IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-OPERATOR' ''.
      ELSEIF gs_head-pengawas IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-PENGAWAS' ''.
      ELSE.
        PERFORM f_cursor_position USING 'GS_HEAD-POSNR' ''.
      ENDIF.

    WHEN '0202'.
      IF gv_post IS INITIAL.
        CLEAR : lv_subrc, gs_head-message, gs_head-clabs, gs_head-total, gv_stock.
      ELSE.
        CLEAR : gv_post, gv_stock.
      ENDIF.

      PERFORM f_printer_check CHANGING default-spld lv_subrc.
      PERFORM f_material_get_detail CHANGING lv_subrc.
      PERFORM f_get_batch CHANGING lv_subrc.
      PERFORM f_get_operation USING '2'
                              CHANGING lv_subrc.

      IF gt_operation[] IS INITIAL.
        CLEAR gs_head-matnr.
        APPEND INITIAL LINE TO gt_operation.
      ELSE.
        IF gv_authorization IS NOT INITIAL.
          CLEAR ls_component.
          READ TABLE gt_component INTO ls_component
                                  WITH KEY matnr = gs_head-matnr
                                           werks = gs_head-werks.
          lv_lgort  = ls_component-lgort.

*          PERFORM f_check_lock_entry USING 'AUFK' ''
*                                     CHANGING lv_subrc.
*          IF lv_subrc = 0.
          PERFORM f_check_lock_entry USING 'MCHB' lv_lgort
                                     CHANGING lv_subrc.
          IF lv_subrc = 0.
            PERFORM f_lock_table USING : 'AUFK' '',
                                         'MCHB' lv_lgort.
          ELSE.
            CLEAR : gs_head-matnr, gt_operation[].
            APPEND INITIAL LINE TO gt_operation.
          ENDIF.
*          ELSE.
*            CLEAR : gs_head-matnr, gt_operation[].
*            APPEND INITIAL LINE TO gt_operation.
*          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR gv_nfull.
      DESCRIBE TABLE gt_operation LINES n4.

      READ TABLE gt_operation INTO ls_operation
                              WITH KEY aufnr = space.
      IF sy-subrc <> 0.
        LOOP AT gt_operation INTO ls_operation.
          IF ls_operation-bdmng < gs_head-packq.
            ADD 1 TO gv_nfull.
          ENDIF.
        ENDLOOP.
        IF gv_nfull = n4.
          CONCATENATE 'Full Pack proses untuk order' gs_head-aufnr 'material'
                       gs_head-matnr 'sudah selesai'
          INTO gs_head-message
          SEPARATED BY space.
          CLEAR : gs_head-matnr.
        ENDIF.
        CLEAR gv_nfull.
*        CLEAR : gs_head-matnr.

*        PERFORM f_notfull_calculate.
      ENDIF.

      IF gs_head-matnr IS INITIAL.
        PERFORM f_modify_screen USING : 'OPR' '0' '' '' '',
                                        'RAW' '0' '' '' '',
                                        'PRT' '0' '' '' '',
                                        'PGI' '0' '' '' '',
                                        'SPL' '0' '' '' ''.
      ELSE.
        IF gs_head-werks = '0101'.
          PERFORM f_modify_screen USING : 'CMA' '' '0' '' ''.
        ELSE.
          PERFORM f_modify_screen USING : 'SPL' '0' '' '' ''.
        ENDIF.
      ENDIF.

      CASE lv_subrc.
        WHEN 5.
          PERFORM f_modify_screen USING : 'OPR' '0' '' '' '',
                                          'PRT' '0' '' '' '',
                                          'PGI' '0' '' '' ''.
        WHEN 7.
          PERFORM f_modify_screen USING : 'CMA' '' '0' '' ''.
      ENDCASE.

      IF gv_nfull = 0.
        PERFORM f_modify_screen USING : 'PRT' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'PGI' '0' '' '' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  n1 = 1.
  n3 = 1.

  CASE sy-dynnr.
    WHEN '0201'.
      IF gs_head IS INITIAL.
        CLEAR : gs_head.
        LEAVE TO SCREEN 0.
      ELSEIF gs_head-werks IS INITIAL
        AND gs_head-plnbez IS INITIAL.
        CLEAR : gs_head.
        LEAVE TO SCREEN 0.
      ELSE.
        CLEAR : gs_head.
      ENDIF.
    WHEN '0202'.
      CLEAR : gs_head-posnr, component[], gt_scan[].
      PERFORM f_unlock_table.
      LEAVE TO SCREEN 0.
    WHEN '2999'.
      gv_subrc = 9.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    " F_CLEAR_DATA

*&----------------------------------------2-----------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_AFTER_INPUT
*&---------------------------------------------------------------------*
FORM f_process_after_input .
  DATA : lv_subrc   TYPE sy-subrc.
  CASE sy-dynnr.
    WHEN '0201'.

    WHEN '0202'.
      PERFORM f_split_field.
      PERFORM f_get_operation USING '1'
                              CHANGING lv_subrc.
  ENDCASE.
ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm    TYPE sy-ucomm.
  DATA : lv_nrp(30),
         lv_name(30).

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE sy-dynnr.
    WHEN '2999'.
      CASE lv_ucomm.
        WHEN '&NEXT'.
          PERFORM f_next99.

        WHEN '&OK'.
          PERFORM f_ok99.
      ENDCASE.

    WHEN OTHERS.
      CASE lv_ucomm.
        WHEN '&LOGOFF'.
          PERFORM f_clear_data.
          CALL 'SYST_LOGOFF'.

        WHEN '&BACK'.
          PERFORM f_clear_data.
          PERFORM f_unlock_table.

        WHEN '&NEXT'.
          PERFORM f_next_button.

        WHEN '&PGI'.
          PERFORM f_prepare_data.
          PERFORM f_unlock_table.
          IF gv_nfull = 0.
            PERFORM f_add_lines_resb.
            PERFORM f_post_goods_issue.
            IF gv_mblnr IS NOT INITIAL.
              PERFORM f_update_resb USING ''.
            ENDIF.
          ELSE.
*        PERFORM f_print_form USING ''.
*        PERFORM f_update_resb USING 'W'.
          ENDIF.

        WHEN '&PRINT'.
          PERFORM f_prepare_data.
          PERFORM f_unlock_table.
          PERFORM f_print_form USING '' ''.
          PERFORM f_update_resb USING 'W'.

        WHEN '&PPGUP'.
          PERFORM f_display_data USING '-'.

        WHEN '&PPGDN'.
          PERFORM f_display_data USING '+'.

        WHEN OTHERS.
          CASE sy-dynnr.
            WHEN '0201'.
              IF gs_head-operator IS NOT INITIAL.
                SPLIT gs_head-operator AT ';' INTO lv_nrp lv_name.
                IF lv_name IS NOT INITIAL.
                  SPLIT lv_name AT space INTO gs_head-operator lv_name.
                  CONDENSE gs_head-operator.
                ENDIF.
              ENDIF.

              IF gs_head-pengawas IS NOT INITIAL.
                SPLIT gs_head-pengawas AT ';' INTO lv_nrp lv_name.
                IF lv_name IS NOT INITIAL.
                  SPLIT lv_name AT space INTO gs_head-pengawas lv_name.
                  CONDENSE gs_head-pengawas.
                ENDIF.
              ENDIF.

*          IF gs_head-posnr IS NOT INITIAL.
*            gs_order-check = 'X'.
*            MODIFY gt_order FROM gs_order
*                            TRANSPORTING check
*                            WHERE posnr = gs_head-posnr.
*            CLEAR gs_head-posnr.
*          ENDIF.
          ENDCASE.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_TABLE
*&---------------------------------------------------------------------*
FORM f_generate_table .
  DATA : lv_bdmng   TYPE resb-bdmng.

  CASE sy-dynnr.
    WHEN '0201'.
      idx = sy-stepl + line.
*      READ TABLE gt_order INTO gs_order INDEX idx.
    WHEN '0202'.
      idx = sy-stepl + line.
      READ TABLE gt_operation INTO gs_operation INDEX idx.
*      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
*        EXPORTING
*          input          = gs_operation-meins
*        IMPORTING
*          output         = gs_operation-meins
*        EXCEPTIONS
*          unit_not_found = 1
*          OTHERS         = 2.

      IF gs_operation-bdmng >= gs_head-packq.
        PERFORM f_full_calculate.
      ENDIF.

      MODIFY gt_operation FROM gs_operation
                          INDEX idx
                          TRANSPORTING clabs erfmg vmeng.
  ENDCASE.
ENDFORM.                    " F_GENERATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table .
  DATA : lv_line        TYPE i.

  GET CURSOR LINE lv_line.

  CASE sy-dynnr.
    WHEN '0201'.
    WHEN '0202'.
  ENDCASE.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER
*&---------------------------------------------------------------------*
FORM f_get_order .
  DATA : ls_order LIKE LINE OF gt_order,
         lv_subrc TYPE sy-subrc,
         lv_count TYPE afpo-posnr,
         lt_afpo  TYPE STANDARD TABLE OF afpo,
         ls_afpo  LIKE LINE OF lt_afpo,
         lt_resb  TYPE STANDARD TABLE OF resb,
         ls_resb  LIKE LINE OF lt_resb.

  CLEAR : gt_order[], gs_head-message.

*  IF gs_head-gstrp IS INITIAL.
*    gs_head-gstrp = sy-datum.
*  ENDIF.

  IF gs_head-werks IS NOT INITIAL AND
    gs_head-gstrp IS NOT INITIAL AND
    gs_head-plnbez IS NOT INITIAL.
    SELECT afko~aufnr afko~gstrp afko~plnbez aufk~werks aufk~objnr
      FROM afko JOIN aufk ON afko~aufnr = aufk~aufnr
      INTO CORRESPONDING FIELDS OF TABLE gt_order
      WHERE werks   = gs_head-werks
        AND gstrp   = gs_head-gstrp
        AND plnbez  = gs_head-plnbez.

    SELECT SINGLE maktx
      FROM makt
      INTO gs_head-maktx
      WHERE matnr = gs_head-plnbez
        AND spras = sy-langu.
  ENDIF.

  IF gt_order[] IS NOT INITIAL.
    SELECT *
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE lt_afpo
      FOR ALL ENTRIES IN gt_order
      WHERE aufnr = gt_order-aufnr.
  ENDIF.

  SORT gt_order BY aufnr.
  LOOP AT gt_order INTO ls_order.
    PERFORM f_status_order  USING ls_order-objnr
                            CHANGING lv_subrc.
    IF lv_subrc IS INITIAL.
      ADD 1 TO lv_count.
      ls_order-posnr  = lv_count.
      CLEAR ls_afpo.
      READ TABLE lt_afpo INTO ls_afpo
                         WITH KEY aufnr = ls_order-aufnr.
      IF sy-subrc = 0.
        ls_order-fcharg = ls_afpo-charg.
      ENDIF.
      MODIFY gt_order FROM ls_order TRANSPORTING posnr fcharg.
    ENDIF.
  ENDLOOP.

  IF gt_order[] IS NOT INITIAL.
    SELECT *
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FOR ALL ENTRIES IN gt_order
      WHERE aufnr = gt_order-aufnr.

    lt_resb[] = gt_resb[].
    SORT lt_resb BY aufpl.
    DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufpl.
    IF lt_resb[] IS NOT INITIAL.
      SELECT *
        FROM afvc
        INTO CORRESPONDING FIELDS OF TABLE gt_afvc
        FOR ALL ENTRIES IN lt_resb
        WHERE aufpl = lt_resb-aufpl.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_STATUS_ORDER
*&---------------------------------------------------------------------*
FORM f_status_order  USING    fu_objnr
                     CHANGING fc_subrc.
  TYPES : BEGIN OF ty_status,
            itx04 TYPE jestd-itx04,
          END OF ty_status.

  DATA : lt_status TYPE STANDARD TABLE OF ty_status,
         ls_status LIKE LINE OF lt_status,
         line      TYPE bsvx-sttxt.

  CLEAR fc_subrc.
  PERFORM f_range_status USING : 'DLV',
                                 'DLT',
                                 'TECO',
                                 'CLSD'.

  CALL FUNCTION 'STATUS_TEXT_EDIT'
    EXPORTING
      flg_user_stat    = 'X'
      objnr            = fu_objnr
      only_active      = 'X'
      spras            = sy-langu
    IMPORTING
      line             = line
    EXCEPTIONS
      object_not_found = 1
      OTHERS           = 2.

  SPLIT line AT space INTO TABLE lt_status.
  READ TABLE lt_status INTO ls_status
                       WITH KEY itx04 = 'REL'.
  IF sy-subrc <> 0.
    DELETE gt_order WHERE objnr = fu_objnr.
    fc_subrc = 4.
  ELSE.
    IF gr_sttxt[] IS NOT INITIAL.
      LOOP AT lt_status INTO ls_status.
        IF ls_status-itx04 IN gr_sttxt.
          DELETE gt_order WHERE objnr = fu_objnr.
          fc_subrc = 4.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_STATUS_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_NEXT_BUTTON
*&---------------------------------------------------------------------*
FORM f_next_button .
  DATA : ls_order LIKE LINE OF gt_order,
         lv_line  TYPE i,
         lv_subrc TYPE sy-subrc.

  IF gt_order[] IS NOT INITIAL.
    READ TABLE gt_order INTO ls_order
                        WITH KEY posnr = gs_head-posnr.
    IF sy-subrc = 0.
      gs_head-aufnr   = ls_order-aufnr.
      gs_head-fcharg  = ls_order-fcharg.
      CALL SCREEN 202.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEXT_BUTTON

*&---------------------------------------------------------------------*
*&      Form  F_RANGE_STATUS
*&---------------------------------------------------------------------*
FORM f_range_status  USING    fu_sttxt.
  DATA : ls_sttxt     LIKE LINE OF gr_sttxt.

  ls_sttxt-low    = fu_sttxt.
  ls_sttxt-sign   = 'I'.
  ls_sttxt-option = 'EQ'.
  APPEND ls_sttxt TO gr_sttxt.
ENDFORM.                    " F_RANGE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_GET_OPERATION
*&---------------------------------------------------------------------*
FORM f_get_operation USING    fu_flag
                     CHANGING fc_subrc.
  DATA : order_objects TYPE bapi_pi_order_objects,
         return        TYPE bapiret2.

  DATA : ls_component LIKE LINE OF component,
         lt_xphase    TYPE STANDARD TABLE OF afvc,
         ls_phase     LIKE LINE OF phase,
         ls_operation TYPE ty_operation,
         lt_afvu      TYPE STANDARD TABLE OF afvu,
         ls_afvu      LIKE LINE OF lt_afvu,
         ls_resb      LIKE LINE OF gt_resb,
         ls_order     LIKE LINE OF gt_order,
         ls_afvc      LIKE LINE OF gt_afvc.

  IF fc_subrc IS INITIAL.
    CASE fu_flag.
      WHEN '1'.
        IF component[] IS INITIAL.
          LOOP AT gt_resb INTO ls_resb WHERE aufnr = gs_head-aufnr
                                         AND splkz NE '2'.
            ls_component = ls_resb.
            APPEND ls_component TO component.
            CLEAR ls_component.
          ENDLOOP.

          CLEAR ls_component.
          READ TABLE component INTO ls_component INDEX 1.
          LOOP AT gt_afvc INTO ls_afvc WHERE aufpl = ls_component-aufpl.
            ls_phase  = ls_afvc.
            APPEND ls_phase TO phase.
            CLEAR ls_phase.
          ENDLOOP.

          gt_component[] = component[].
          SORT gt_component BY matnr werks lgort.
          DELETE ADJACENT DUPLICATES FROM gt_component
          COMPARING matnr werks lgort.
        ENDIF.

      WHEN '2'.
        CLEAR : gt_operation[].
        IF gs_head-matnr IS NOT INITIAL.
          lt_xphase[]  = phase[].
          SORT lt_xphase BY aufpl aplzl.
          DELETE ADJACENT DUPLICATES FROM lt_xphase COMPARING aufpl aplzl.
          IF lt_xphase[] IS NOT INITIAL.
            SELECT *
              FROM afvu
              INTO CORRESPONDING FIELDS OF TABLE lt_afvu
              FOR ALL ENTRIES IN lt_xphase
              WHERE aufpl = lt_xphase-aufpl
                AND aplzl = lt_xphase-aplzl.
          ENDIF.

          LOOP AT component INTO ls_component WHERE matnr = gs_head-matnr.
            CLEAR ls_phase.
            READ TABLE phase INTO ls_phase
                             WITH KEY vornr = ls_component-vornr.
            IF sy-subrc = 0.
              ls_operation-vornr = ls_phase-vornr.
              ls_operation-ltxa1 = ls_phase-ltxa1.
              CLEAR ls_afvu.
              READ TABLE lt_afvu INTO ls_afvu
                                 WITH KEY aufpl = ls_phase-aufpl
                                          aplzl = ls_phase-aplzl.
              IF sy-subrc = 0.
                ls_operation-usr00  = ls_afvu-usr00.
              ENDIF.
              ls_operation-bdmng = ls_component-bdmng - ls_component-enmng.
              ls_operation-meins = ls_component-meins.
            ENDIF.
            ls_operation-aufnr    = gs_head-aufnr.
*{   INSERT         P01K910834                                        1
* "SOH: Shell Remediation Adjustment 20240417 KRS
            ls_operation-baugr    = ls_component-baugr.
*}   INSERT
            ls_operation-rsnum    = ls_component-rsnum.
            ls_operation-rspos    = ls_component-rspos.
            ls_operation-matnr    = gs_head-matnr.
            ls_operation-charg    = gs_head-charg.
            ls_operation-lgort    = ls_component-lgort.

            CASE ls_component-lgort.
              WHEN '2105'.
                gs_head-wb  = '1U'.
              WHEN '2100'.
                CASE ls_component-werks.
                  WHEN '0101'.
                    gs_head-wb  = '4U'.
                  WHEN '0102'.
                    gs_head-wb  = '2U'.
                ENDCASE.
              WHEN '2110'.
                gs_head-wb  = '3U'.
              WHEN '2300'.
                gs_head-wb  = '5U'.
            ENDCASE.
            ls_operation-posnr    = ls_component-posnr.
*            ls_operation-erfmg    = ls_component-erfmg.
            ls_operation-erfme    = ls_component-erfme.

            IF gs_head-meanval IS NOT INITIAL.
              CONCATENATE '(X=' gs_head-meanval 'mg)' INTO ls_operation-meanval.
            ENDIF.

            APPEND ls_operation TO gt_operation.
            CLEAR ls_operation.
          ENDLOOP.
        ENDIF.
    ENDCASE.
  ELSE.
    CASE fc_subrc.
      WHEN 8 OR 9.
      WHEN OTHERS.
        CLEAR gt_operation[].
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GET_OPERATION

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_FIELD
*&---------------------------------------------------------------------*
FORM f_split_field .
  IF gs_head-cmatnr IS NOT INITIAL.
    IF gs_head-werks = '0102'.
      SPLIT gs_head-cmatnr AT ';' INTO gs_head-matnr gs_head-charg
                                       gs_head-qty gs_head-count.
    ELSE.
      IF gs_head-cmatnr IS NOT INITIAL.
        SPLIT gs_head-cmatnr AT ';' INTO gs_head-matnr gs_head-charg
                                         gs_head-qty gs_head-count.
      ENDIF.
    ENDIF.

    CLEAR: gt_xresb[], gv_meins.

    SELECT SINGLE meins
      FROM mara
      INTO gv_meins
      WHERE matnr = gs_head-matnr.

    SELECT *
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_xresb
      WHERE matnr = gs_head-matnr
        AND charg = gs_head-charg
        AND werks = gs_head-werks
*      AND wempf = 'W'
        AND bwart = gv_261
        AND kzear = space
        AND xloek = space.

    PERFORM f_get_meanval USING gs_head-werks gs_head-matnr gs_head-charg
                          CHANGING gs_head-meanval.

    CLEAR gs_head-cmatnr.
  ENDIF.
ENDFORM.                    " F_SPLIT_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_material_get_detail CHANGING fc_subrc.
  DATA : material TYPE bapimatdoa,
         return   TYPE bapireturn.

  IF gs_head-matnr IS NOT INITIAL.
    CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
      EXPORTING
        material              = gs_head-matnr
        plant                 = gs_head-werks
      IMPORTING
        material_general_data = material
        return                = return.
    IF return-type = 'S' AND
      material-matl_type = 'ZRM'.
      gs_head-maktx  = material-matl_desc.
      gs_head-rmein  = material-base_uom.
    ELSE.
      fc_subrc  = 1.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MATERIAL_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_type fu_msgv1 fu_msgv2 fu_msgv3 fu_msgv4.
  gs_head-message = fu_msgv1.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_BATCH
*&---------------------------------------------------------------------*
FORM f_get_batch CHANGING fc_subrc.
  DATA : ls_mchb      TYPE mchb,
         cob          TYPE STANDARD TABLE OF clbatch,
         ls_cob       LIKE LINE OF cob,
         ls_component LIKE LINE OF gt_component,
         ls_scan      LIKE LINE OF gt_scan,
         lv_bdmng     TYPE resb-bdmng,
         lv_clabs     TYPE resb-bdmng,
         ls_xresb     LIKE LINE OF gt_xresb.

  IF fc_subrc IS INITIAL.
    IF gs_head-charg IS NOT INITIAL.
      IF gt_scan[] IS INITIAL.
        PERFORM f_save_data_scan.
      ELSE.
*        READ TABLE gt_scan INTO ls_scan
*                           WITH KEY matnr = gs_head-matnr
*                                    charg = gs_head-charg.
*        IF sy-subrc <> 0.
*          fc_subrc = 8.
*          gs_head-message = 'Rawmat / Batch berbeda'.
*          READ TABLE gt_scan INTO ls_scan INDEX 1.
*          gs_head-matnr = ls_scan-matnr.
*          gs_head-charg = ls_scan-charg.
*        ELSE.
        IF gs_head-werks = '0102'.
          READ TABLE gt_scan INTO ls_scan
                             WITH KEY matnr = gs_head-matnr
                                      charg = gs_head-charg
                                      count = gs_head-count.
          IF sy-subrc = 0.
            fc_subrc = 9.
            gs_head-message = 'Pack sudah pernah discan'.
            READ TABLE gt_scan INTO ls_scan INDEX 1.
            gs_head-matnr = ls_scan-matnr.
            gs_head-charg = ls_scan-charg.
          ELSE.
            PERFORM f_save_data_scan.
          ENDIF.
        ELSE.
          IF gs_head-squan IS INITIAL.
            PERFORM f_cursor_position USING 'GS_HEAD-SQUAN' ''.
          ELSEIF gs_head-spack IS INITIAL.
            PERFORM f_cursor_position USING 'GS_HEAD-SPACK' ''.
          ENDIF.
        ENDIF.
      ENDIF.
*    ENDIF.

      READ TABLE gt_component INTO ls_component
                              WITH KEY matnr = gs_head-matnr
                                       werks = gs_head-werks.
      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM mchb
          INTO CORRESPONDING FIELDS OF ls_mchb
          WHERE matnr = gs_head-matnr
            AND werks = gs_head-werks
            AND lgort = ls_component-lgort
            AND charg = gs_head-charg.

        IF sy-subrc <> 0.
          gs_head-message = 'Stock tidak ada'.
          fc_subrc = 2.
        ELSE.
          CALL FUNCTION 'VB_BATCH_GET_DETAIL'
            EXPORTING
              matnr              = gs_head-matnr
              charg              = gs_head-charg
              werks              = gs_head-werks
              get_classification = 'X'
            TABLES
              char_of_batch      = cob
            EXCEPTIONS
              no_material        = 1
              no_batch           = 2
              no_plant           = 3
              material_not_found = 4
              plant_not_found    = 5
              no_authority       = 6
              batch_not_exist    = 7
              lock_on_batch      = 8
              OTHERS             = 9.
          IF sy-subrc = 0.
            READ TABLE cob INTO ls_cob
                           WITH KEY atnam = 'QTY_CONVERSION'.
            IF sy-subrc = 0.
              TRANSLATE ls_cob-atwtb USING '. '.
              TRANSLATE ls_cob-atwtb USING ',.'.
              CONDENSE ls_cob-atwtb NO-GAPS.
              gs_head-packq  = ls_cob-atwtb.

              PERFORM f_calculate_sample_quantity USING gs_head-packq
                                                  CHANGING ls_mchb-clabs.

              IF ls_mchb-clabs < gs_head-packq.
                fc_subrc = 5.
                gs_head-message = 'Stock tidak cukup'.
              ELSE.
                LOOP AT gt_xresb INTO ls_xresb WHERE matnr = gs_head-matnr
                                                 AND charg = gs_head-charg
                                                 AND lgort = ls_component-lgort.
                  ADD ls_xresb-bdmng TO lv_clabs.
                ENDLOOP.
                gs_head-clabs = ls_mchb-clabs - lv_clabs.
                IF gs_head-squan <> 0 AND
                  gs_head-spack <> 0.
                  gs_head-clabs = gs_head-clabs - ( gs_head-squan * gs_head-spack ).
                ENDIF.
              ENDIF.
            ELSE.
              fc_subrc = 6.
              gs_head-message = 'Pack belum dimaintain'.
            ENDIF.
          ELSE.
            fc_subrc = 3.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table USING fu_tabname fu_lgort.
  CASE fu_tabname.
    WHEN 'AUFK'.
      CALL FUNCTION 'ENQUEUE_ESORDER'
        EXPORTING
          aufnr          = gs_head-aufnr
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

    WHEN 'MCHB'.
      CALL FUNCTION 'ENQUEUE_EZKMM_MCHB'
        EXPORTING
          matnr          = gs_head-matnr
          werks          = gs_head-werks
          lgort          = fu_lgort
          charg          = gs_head-charg
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

    WHEN 'MCH1'.
      CALL FUNCTION 'ENQUEUE_EMMCH1E'
        EXPORTING
          matnr          = gs_head-matnr
          charg          = gs_head-charg
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
  ENDCASE.
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_LOCK_ENTRY
*&---------------------------------------------------------------------*
FORM f_check_lock_entry  USING    fu_value fu_lgort
                         CHANGING fc_subrc.
  DATA : enq      TYPE STANDARD TABLE OF seqg3,
         ls_enq   LIKE LINE OF enq,
         lv_gtarg TYPE seqg3-gtarg.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = fu_value
      guname                = space
    TABLES
      enq                   = enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  IF enq[] IS NOT INITIAL.
    fc_subrc = 4.
    READ TABLE enq INTO ls_enq INDEX 1.
    IF sy-subrc = 0.
      IF ls_enq-guname = sy-uname.
        CLEAR fc_subrc.
      ELSE.

        CASE fu_value.
          WHEN 'AUFK'.
            CONCATENATE sy-mandt gs_head-aufnr INTO lv_gtarg.
            IF ls_enq-gtarg = lv_gtarg.
              CONCATENATE 'Order' gs_head-aufnr 'lock by' ls_enq-guname
              INTO gs_head-message
              SEPARATED BY space.
            ELSE.
              CLEAR fc_subrc.
            ENDIF.

          WHEN 'MCHB'.
            lv_gtarg(3)     = sy-mandt.
            lv_gtarg+3(18)  = gs_head-matnr.
            lv_gtarg+21(4)  = gs_head-werks.
            lv_gtarg+25(4)  = fu_lgort.
            lv_gtarg+29(10) = gs_head-charg.
            IF ls_enq-gtarg = lv_gtarg.
              CONCATENATE 'Batch' gs_head-charg 'lock by' ls_enq-guname
              INTO gs_head-message
              SEPARATED BY space.
            ELSE.
              CLEAR fc_subrc.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_LOCK_ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table .
  CALL FUNCTION 'DEQUEUE_ALL'.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_POST_GOODS_ISSUE
*&---------------------------------------------------------------------*
FORM f_post_goods_issue .
  DATA : lv_mblnr  TYPE mseg-mblnr,
         lv_mjahr  TYPE mseg-mjahr,
         return    TYPE STANDARD TABLE OF bapiret2,
         ls_return TYPE bapiret2.

  CLEAR gv_mblnr.
  gv_post       = 'X'.
  goodsmvt_code = '03'.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = goodsmvt_header
      goodsmvt_code    = goodsmvt_code
    IMPORTING
      goodsmvt_headret = goodsmvt_headret
      materialdocument = lv_mblnr
      matdocumentyear  = lv_mjahr
    TABLES
      goodsmvt_item    = goodsmvt_item
      return           = return.

  IF lv_mblnr IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    PERFORM f_print_form USING lv_mblnr lv_mjahr.
    PERFORM f_write_ztspppdt011 USING lv_mblnr lv_mjahr.

    CONCATENATE 'Document' lv_mblnr 'created' INTO gs_head-message
    SEPARATED BY space.

    gv_mblnr = lv_mblnr.
    CLEAR : component[].
  ELSE.
    READ TABLE return INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = ls_return-id
          msgnr               = ls_return-number
          msgv1               = ls_return-message_v1
          msgv2               = ls_return-message_v2
          msgv3               = ls_return-message_v3
          msgv4               = ls_return-message_v4
        IMPORTING
          message_text_output = gs_head-message.
    ENDIF.

* Back to condition before PGI
*    DELETE resb   FROM TABLE gt_resb_insert.
*    DELETE onr00  FROM TABLE gt_onr00.
*    DELETE jest   FROM TABLE gt_jest.
*    DELETE jsto   FROM TABLE gt_jsto.
*    DELETE zppresb_add FROM TABLE gt_add.
    CLEAR: gt_add[],gt_resb_update[].
    CALL FUNCTION 'ZTSPPPFM002'
      TABLES
        it_add                   = gt_add
        it_dresb                 = gt_resb_insert
        it_uresb                 = gt_resb_update
        it_onr00                 = gt_onr00
        it_jest                  = gt_jest
        it_jsto                  = gt_jsto
      EXCEPTIONS
        error_delete_resb        = 1
        error_update_resb        = 2
        error_delete_onr00       = 3
        error_delete_jest        = 4
        error_delete_jsto        = 5
        error_delete_zppresb_add = 6.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
    ELSE.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  CLEAR: gt_add[],gt_resb_insert[],gt_resb_update[],gt_onr00[],
         gt_jest,gt_jest[],gt_jsto,gt_jsto[].
ENDFORM.                    " F_POST_GOODS_ISSUE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : ls_operation LIKE LINE OF gt_operation,
         ls_item      TYPE bapi2017_gm_item_create,
         lt_label     TYPE STANDARD TABLE OF ztspppst004,
         ls_label     TYPE ztspppst004,
         lv_count     TYPE i,
         lv_erfmg(20),
         lv_total(20),
         lt_hazcom    TYPE TABLE OF ztspmdhazcom WITH HEADER LINE,
         h(10), f(10), r(10),
         lv_charg     TYPE char10,
         lv_hazcom    TYPE char30,
         lv_to        TYPE resb-erfmg,
         lv_erfme     TYPE resb-erfme.

  DATA : lt_makt      TYPE STANDARD TABLE OF makt,
         lt_operation TYPE STANDARD TABLE OF ty_operation.

  DATA : lv_lifnr LIKE lfa1-lifnr,
         lv_name1 LIKE lfa1-name1.

  CLEAR : goodsmvt_header, goodsmvt_item[], gt_label[].

  SELECT *
    FROM makt
    INTO CORRESPONDING FIELDS OF TABLE lt_makt
    WHERE matnr = gs_head-plnbez
      AND spras = sy-langu.

  lt_operation[] = gt_operation[].
  SORT lt_operation BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_operation COMPARING matnr.
  IF lt_operation[] IS NOT INITIAL.
    SELECT *
      FROM makt
      APPENDING CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN lt_operation
      WHERE matnr = lt_operation-matnr
        AND spras = sy-langu.
  ENDIF.
*{   INSERT         P01K910834                                        1
* "Start SOH: Shell Remediation Adjustment 20240417 KRS
  DATA:
    BEGIN OF ls_afpo,
      aufnr TYPE afpo-aufnr,
      posnr TYPE afpo-posnr,
      matnr TYPE afpo-matnr,
    END OF ls_afpo,
    lt_afpo LIKE TABLE OF ls_afpo.
  CLEAR: lt_afpo[].
  CLEAR: lt_operation[].
  lt_operation[] = gt_operation[].
  SORT lt_operation BY matnr vornr.
  DELETE ADJACENT DUPLICATES FROM lt_operation COMPARING matnr vornr.
  IF lt_operation[] IS NOT INITIAL.
    SELECT aufnr posnr matnr FROM afpo INTO TABLE lt_afpo
      FOR ALL ENTRIES IN lt_operation
      WHERE aufnr = lt_operation-aufnr.
  ENDIF.
  "End SOH: Shell Remediation Adjustment 20240417 KRS
*}   INSERT

  goodsmvt_header-pstng_date        = sy-datum.
  goodsmvt_header-doc_date          = sy-datum.
  CONCATENATE gs_head-wb gs_head-operator gs_head-pengawas
  INTO goodsmvt_header-header_txt
  SEPARATED BY ';'.
  goodsmvt_header-ver_gr_gi_slip    = '1'.
  goodsmvt_header-ver_gr_gi_slipx   = 'X'.

  LOOP AT gt_operation INTO ls_operation.
    IF ls_operation-erfmg IS INITIAL.
      CONTINUE.
    ENDIF.
    ls_item-material             = ls_operation-matnr.
    ls_item-plant                = gs_head-werks.
    ls_item-stge_loc             = ls_operation-lgort.
    ls_item-batch                = ls_operation-charg.
    ls_item-entry_uom            = ls_operation-erfme.
    ls_item-orderid              = ls_operation-aufnr.
    ls_item-order_itno           = ls_operation-posnr.
    ls_item-reserv_no            = ls_operation-rsnum.
    ls_item-res_item             = ls_operation-rspos.
    ls_item-move_type            = '261'.
*{   INSERT         P01K910834                                        2
* "Start SOH: Shell Remediation Adjustment 20240417 KRS
    IF NOT lt_afpo[] IS INITIAL.
      READ TABLE lt_afpo INTO ls_afpo WITH KEY aufnr = ls_operation-aufnr
                                               matnr = ls_operation-baugr.
      IF sy-subrc = 0.
        ls_item-order_itno = ls_afpo-posnr.
      ENDIF.
    ENDIF.
    "End SOH: Shell Remediation Adjustment 20240417 KRS
*}   INSERT

    IF gv_nfull IS INITIAL.
*      ls_item-entry_qnt            = ls_operation-erfmg * gs_head-packq.
      IF ls_operation-erfme = ls_operation-meins.
*        ls_item-quantity         = ls_operation-erfmg * gs_head-packq.
*        ls_item-base_uom         = ls_operation-meins.
        ls_item-entry_qnt        = ls_operation-erfmg * gs_head-packq.
      ELSE.
        ls_item-quantity         = ls_operation-erfmg * gs_head-packq.
        ls_item-base_uom         = ls_operation-meins.
        PERFORM f_uom_conversion USING ls_item-material
                                       ls_item-base_uom
                                       ls_item-entry_uom
                                       ls_item-quantity
                                 CHANGING ls_item-entry_qnt.
      ENDIF.

    ELSE.
      ls_item-entry_qnt            = ls_operation-erfmg.
    ENDIF.

    APPEND ls_item TO goodsmvt_item.
    CLEAR ls_item.

    ls_label-aufnr               = gs_head-aufnr.
    ls_label-fcharg              = gs_head-fcharg.
    ls_label-plnbez              = gs_head-plnbez.
    PERFORM f_matnr_description TABLES lt_makt
                                USING gs_head-plnbez ''
                                CHANGING ls_label-fmaktx.
    ls_label-rspos               = ls_operation-rspos.
    PERFORM f_matnr_description TABLES lt_makt
                                USING '' ls_operation-vornr
                                CHANGING ls_label-ltxa1.
    PERFORM f_matnr_description TABLES lt_makt
                                USING ls_operation-matnr ''
                                CHANGING ls_label-maktx.

    ls_label-usr00               = ls_operation-usr00.
    ls_label-matnr               = ls_operation-matnr.
    ls_label-charg               = ls_operation-charg.
    ls_label-vornr               = ls_operation-vornr.
    ls_label-posnr               = ls_operation-posnr.
    ls_label-erfmg               = ls_operation-erfmg.
    ls_label-erfme               = ls_operation-meins.
    ls_label-meanval             = ls_operation-meanval.

    ls_label-operator            = gs_head-operator.
    ls_label-pengawas            = gs_head-pengawas.
    ls_label-wb                  = gs_head-wb.

    ADD ls_operation-erfmg TO lv_to.
    APPEND ls_label TO lt_label.
    CLEAR ls_label.
  ENDLOOP.

  LOOP AT lt_label INTO ls_label.
    CLEAR: lt_hazcom,lv_hazcom,h,f,r.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF lt_hazcom
      FROM ztspmdhazcom WHERE matnr = ls_label-matnr
                          AND werks = gs_head-werks.
    IF sy-subrc = 0.
      CONCATENATE 'H =' lt_hazcom-health INTO h SEPARATED BY space.
      CONCATENATE 'F =' lt_hazcom-fire   INTO f SEPARATED BY space.
      CONCATENATE 'R =' lt_hazcom-reactivity INTO r SEPARATED BY space.
      CONCATENATE h f r  INTO lv_hazcom SEPARATED BY ' ; '.
      ls_label-hazcom = lv_hazcom.
    ENDIF.

*    SELECT SINGLE a~lifnr a~name1
*      INTO (ls_label-lifnr, ls_label-name1)
*      FROM lfa1 AS a JOIN mch1 AS b ON a~lifnr = b~lifnr
*      WHERE b~matnr = gs_head-matnr
*        AND b~charg = gs_head-charg.
*    IF ls_label-name1 IS NOT INITIAL.
*      CONCATENATE '(' ls_label-name1(30) ')' INTO ls_label-name1.
*    ENDIF.
    CLEAR: lv_lifnr,lv_name1.
    PERFORM f_get_vendor(ztsppp_e001) USING gs_head-matnr
                                            gs_head-charg
                         CHANGING lv_lifnr lv_name1.
    IF lv_name1 IS NOT INITIAL.
      CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
      ls_label-name1 = lv_name1.
    ENDIF.

    IF gv_nfull IS INITIAL.
      DO ls_label-erfmg TIMES.
        WRITE lv_to TO lv_total DECIMALS 0.
        CONDENSE lv_total NO-GAPS.

        ADD 1 TO lv_count.
        WRITE lv_count TO lv_erfmg DECIMALS 0.
        CONDENSE lv_erfmg NO-GAPS.

        CONCATENATE lv_erfmg '/' lv_total INTO ls_label-count.
        CONDENSE ls_label-count NO-GAPS.
        CLEAR ls_label-nofull.
        WRITE gs_head-packq TO ls_label-erfmgt UNIT ls_label-erfme.
        CONDENSE ls_label-erfmgt NO-GAPS.
        PERFORM f_meins_convertion USING ls_label-erfme
                                   CHANGING ls_label-erfmgt.

        lv_charg = ls_label-charg.
        SHIFT lv_charg LEFT DELETING LEADING '0'.
*        CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-fcharg
*                    ls_label-vornr ls_label-matnr ls_label-charg
        CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-vornr
                    ls_label-posnr  ls_label-matnr ls_label-erfmgt
                    ls_label-count 'F' lv_charg
        INTO ls_label-qrcode SEPARATED BY ';'.

        ls_label-budat = sy-datum.
        APPEND ls_label TO gt_label.
      ENDDO.
    ELSE.
      WRITE ls_label-erfmg TO ls_label-erfmgt UNIT ls_label-erfme.
      CONDENSE ls_label-erfmgt NO-GAPS.
      PERFORM f_meins_convertion USING ls_label-erfme
                                 CHANGING ls_label-erfmgt.
      ls_label-nofull              = 'X'.
      ls_label-budat               = sy-datum.
      APPEND ls_label TO gt_label.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form  USING    fu_mblnr fu_mjahr.
  DATA : lv_formname TYPE tdsfname,
         lv_funcname TYPE tdsfname,
         ctrl_param  LIKE ssfctrlop,
         output_opt  TYPE ssfcompop,
         ls_label    TYPE ztspppst004,
         lv_ldest    TYPE t329d-ldest.

  lv_formname = 'ZTSPPPF001'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  LOOP AT gt_label INTO ls_label.
    AT FIRST.
      ctrl_param-no_close = 'X'.
    ENDAT.

    AT LAST.
      ctrl_param-no_close = space.
    ENDAT.

    ctrl_param-no_dialog  = 'X'.

    output_opt-tdnewid    = 'X'.
    output_opt-tdimmed    = 'X'.
    output_opt-tddelete   = ''.
    output_opt-tddest     = default-spld.

    ls_label-mblnr  = fu_mblnr.
*    IF gv_nfull IS NOT INITIAL.
*      ls_label-nofull = 'X'.
*    ENDIF.
    IF ls_label-qrcode IS NOT INITIAL.
      CONCATENATE ls_label-qrcode fu_mblnr
        INTO ls_label-qrcode SEPARATED BY ';'.
    ENDIF.

    CASE gs_head-werks.
      WHEN '0101'.
        ls_label-company  = 'TSP - Cikarang Plant 1'.
        ls_label-weidt    = 'Tgl. Alokasi'.
      WHEN '0102'.
        ls_label-company  = 'TSP - Cikarang Plant 2'.
        ls_label-reprint  = 'X'.
        ls_label-weidt    = 'Tgl. Timbang'.
    ENDCASE.

    ls_label-werks = gs_head-werks.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ctrl_param
        output_options     = output_opt
        user_settings      = space
        gs_label           = ls_label
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    ctrl_param-no_open = 'X'.
  ENDLOOP.

  CLEAR : gt_label[].
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_RESB
*&---------------------------------------------------------------------*
FORM f_update_resb USING fu_wempf.
  DATA : ls_operation LIKE LINE OF gt_operation,
         ls_resb      LIKE LINE OF gt_resb,
         ls_scan      LIKE LINE OF gt_scan,
         lv_sisa,
         lv_bdmng     TYPE resb-bdmng,
         lv_enmng     LIKE resb-enmng,
         ls_xresb     LIKE resb.

  LOOP AT gt_operation INTO ls_operation.
    IF ls_operation-erfmg IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR: lv_enmng,ls_xresb.

    lv_enmng = gs_head-packq * ls_operation-erfmg.

    SELECT SINGLE * INTO ls_xresb
      FROM resb WHERE rsnum = ls_operation-rsnum
                  AND rspos = ls_operation-rspos
                  AND splkz IN (' ','1').

    IF sy-subrc = 0.
      IF ls_xresb-splkz = ' '.
        ls_xresb-nomng = ls_xresb-bdmng.
        ls_xresb-bdmng = ls_xresb-nomng - lv_enmng.
      ELSEIF ls_xresb-splkz = '1'.
        ls_xresb-bdmng = ls_xresb-bdmng - lv_enmng.
      ENDIF.

      ls_xresb-splkz = '1'.
*      ls_xresb-bdmng = ls_xresb-nomng - lv_enmng.
      ls_xresb-erfmg = ls_xresb-vmeng = ls_xresb-bdmng.
      CLEAR ls_xresb-enmng.

      IF ls_xresb-erfme NE ls_xresb-meins.
        PERFORM f_uom_conversion USING ls_xresb-matnr
                                       ls_xresb-meins
                                       ls_xresb-erfme
                                       ls_xresb-bdmng
                                 CHANGING ls_xresb-erfmg.
      ENDIF.

* Update RESB untuk confirm quantity
*      TRY .
*          UPDATE resb SET splkz = ls_xresb-splkz
*                          nomng = ls_xresb-nomng
*                          bdmng = ls_xresb-bdmng
*                          erfmg = ls_xresb-erfmg
*                          enmng = ls_xresb-enmng
*                          vmeng = ls_xresb-vmeng
*                      WHERE rsnum = ls_xresb-rsnum
*                        AND rspos = ls_xresb-rspos.
*        CATCH cx_sy_open_sql_db.
*      ENDTRY.
      CLEAR: gt_resb_update[],gt_add,gt_resb_insert,gt_onr00,gt_jest,gt_jsto.
      APPEND ls_xresb TO gt_resb_update.

      CALL FUNCTION 'ZTSPPPFM001'
        TABLES
          it_add                   = gt_add
          it_iresb                 = gt_resb_insert
          it_uresb                 = gt_resb_update
          it_onr00                 = gt_onr00
          it_jest                  = gt_jest
          it_jsto                  = gt_jsto
        EXCEPTIONS
          error_insert_resb        = 1
          error_update_resb        = 2
          error_insert_onro        = 3
          error_insert_zppresb_add = 4
          error_insert_jest        = 5
          error_insert_jsto        = 6.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  CALL FUNCTION 'ZFMWAIT'.

  IF gt_order[] IS NOT INITIAL.
    CLEAR gt_resb[].
    SELECT *
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FOR ALL ENTRIES IN gt_order
      WHERE aufnr = gt_order-aufnr.

    READ TABLE gt_scan INTO ls_scan INDEX 1.
    LOOP AT gt_resb INTO ls_resb WHERE aufnr = gs_head-aufnr
                                   AND matnr = ls_scan-matnr
                                   AND kzear = space.
      CLEAR ls_operation.
      READ TABLE gt_operation INTO ls_operation
                              WITH KEY rsnum  = ls_resb-rsnum
                                       rspos  = ls_resb-rspos.
      IF sy-subrc = 0.
        IF ls_operation-vmeng = 0.
          CONTINUE.
        ENDIF.
        lv_bdmng = ls_resb-bdmng - ( ls_operation-erfmg * gs_head-packq ).
        IF lv_bdmng >= gs_head-packq.
          lv_sisa = 'X'.
          EXIT.
        ENDIF.
      ENDIF.

*      IF ls_resb-bdmng >= gs_head-packq.
*        lv_sisa = 'X'.
*        EXIT.
*      ENDIF.
    ENDLOOP.

    IF lv_sisa IS NOT INITIAL.
      CONCATENATE gs_head-message '& Alokasi full pack' ls_scan-matnr
                  'belum selesai'
      INTO gs_head-message
      SEPARATED BY space.
    ENDIF.
    CLEAR : component[], gt_component[], gt_scan[].
  ENDIF.
ENDFORM.                    " F_UPDATE_RESB

*&---------------------------------------------------------------------*
*&      Form  F_MATNR_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_matnr_description  TABLES   ft_makt STRUCTURE makt
                          USING    fu_matnr fu_vornr
                          CHANGING fc_description.
  DATA : ls_makt    TYPE makt.

  CLEAR fc_description.

  IF fu_matnr IS NOT INITIAL.
    READ TABLE ft_makt INTO ls_makt
                       WITH KEY matnr = fu_matnr.
    IF sy-subrc = 0.
      fc_description = ls_makt-maktx.
    ENDIF.
  ELSEIF fu_vornr IS NOT INITIAL.
  ENDIF.
ENDFORM.                    " F_MATNR_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_MEINS_CONVERTION
*&---------------------------------------------------------------------*
FORM f_meins_convertion  USING    fu_erfme
                         CHANGING fc_value.
  DATA : lv_meins(5).

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_erfme
    IMPORTING
      output         = lv_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  CONCATENATE fc_value lv_meins INTO fc_value
  SEPARATED BY space.
ENDFORM.                    " F_MEINS_CONVERTION

*&---------------------------------------------------------------------*
*&      Form  F_FULL_CALCULATE
*&---------------------------------------------------------------------*
FORM f_full_calculate .
  DATA : lv_div   TYPE p DECIMALS 0,
         lv_total TYPE mchb-clabs.

  IF gv_stock IS INITIAL.
    gs_operation-clabs  = gs_head-clabs.
    gv_stock            = 'X'.
  ELSEIF gs_head-sisa < gs_head-packq.
    gs_operation-clabs  = 0.
  ELSE.
    gs_operation-clabs  = gs_head-sisa.
  ENDIF.
  IF gs_head-packq = 0.
    lv_div = 0.
  ELSE.
    lv_div = gs_operation-bdmng DIV gs_head-packq.
  ENDIF.
  gs_operation-erfmg = lv_div.
  lv_total           = gs_head-packq * lv_div.
  IF gs_operation-clabs < lv_total.
    IF gs_head-packq = 0.
      lv_div = 0.
    ELSE.
      lv_div             = gs_operation-clabs DIV gs_head-packq.
    ENDIF.
    gs_operation-erfmg = lv_div.
    lv_total           = gs_head-packq * lv_div.
  ENDIF.
  gs_head-sisa       = gs_operation-clabs - lv_total.
  ADD lv_div TO gs_head-total.
  gs_operation-vmeng  = gs_operation-bdmng - ( gs_head-packq * gs_operation-erfmg ).
ENDFORM.                    " F_FULL_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_PRINTER_CHECK
*&---------------------------------------------------------------------*
FORM f_printer_check  CHANGING fc_spld fc_subrc.
  DATA : ls_tsp03d TYPE tsp03d,
         ls_tsp06a TYPE tsp06a.

  DATA : parameter    TYPE STANDARD TABLE OF bapiparam,
         ls_parameter LIKE LINE OF parameter.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = sy-uname
    IMPORTING
      defaults  = default
    TABLES
      parameter = parameter
      return    = return.

  READ TABLE parameter INTO ls_parameter
                       WITH KEY parid = 'PRI'.
  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_SPDEV_INPUT'
      EXPORTING
        input  = ls_parameter-parva
      IMPORTING
        output = fc_spld.
  ENDIF.

  SELECT SINGLE *
    FROM tsp03d
    INTO CORRESPONDING FIELDS OF ls_tsp03d
    WHERE padest = fc_spld.
  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM tsp06a
      INTO CORRESPONDING FIELDS OF ls_tsp06a
      WHERE ptype = ls_tsp03d-patype
        AND paper = 'Z_A7'.
    IF sy-subrc <> 0.
      CONCATENATE 'Printer' ls_tsp03d-name 'tidak support untuk A7'
      INTO gs_head-message
      SEPARATED BY space.
      fc_subrc = 7.
    ENDIF.
  ELSE.
    gs_head-message = 'Printer belum dimaintain'.
    fc_subrc = 7.
  ENDIF.
ENDFORM.                    " F_PRINTER_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_display_data  USING    fu_sign.
  DATA : lv_lines   TYPE i.

  DESCRIBE TABLE gt_order LINES lv_lines.
  CASE fu_sign.
    WHEN '+'.
      n1 = n1 + 30.
      IF n1 > lv_lines.
        n1 = lv_lines.
      ENDIF.
    WHEN '-'.
      n1 = n1 - 30.
      IF n1 < 0.
        n1 = 30.
      ENDIF.
      c1  = c1 - 30.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA_SCAN
*&---------------------------------------------------------------------*
FORM f_save_data_scan .
  DATA : ls_scan      LIKE LINE OF gt_scan,
         lv_bdmng(20),
         lv_meins(20).

  ls_scan-matnr = gs_head-matnr.
  ls_scan-charg = gs_head-charg.
  SPLIT gs_head-qty AT space INTO lv_bdmng lv_meins.
  TRANSLATE lv_bdmng USING '. '.
  TRANSLATE lv_bdmng USING ',.'.
  CONDENSE lv_bdmng NO-GAPS.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = lv_meins
    IMPORTING
      output         = ls_scan-meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  ls_scan-bdmng = lv_bdmng.
  ls_scan-count = gs_head-count.
  APPEND ls_scan TO gt_scan.
  CLEAR ls_scan.
ENDFORM.                    " F_SAVE_DATA_SCAN

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_SAMPLE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_calculate_sample_quantity  USING    fu_packq
                                  CHANGING fc_clabs.
  DATA : ls_scan  LIKE LINE OF gt_scan,
         lv_bdmng TYPE resb-bdmng.

  LOOP AT gt_scan INTO ls_scan.
    IF ls_scan-bdmng < fu_packq.
      ADD ls_scan-bdmng TO lv_bdmng.
    ENDIF.
  ENDLOOP.

  fc_clabs = fc_clabs - lv_bdmng.
ENDFORM.                    " F_CALCULATE_SAMPLE_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_WITH_PASSWORD
*&---------------------------------------------------------------------*
FORM f_with_password .
  IF gv_pass IS NOT INITIAL.
    gs_head-operator = gv_operator.
    gs_head-pengawas = gv_pengawas.
  ENDIF.
ENDFORM.                    " F_WITH_PASSWORD

*&---------------------------------------------------------------------*
*&      Form  F_ADD_LINES_RESB
*&---------------------------------------------------------------------*
FORM f_add_lines_resb .
  DATA : lv_rsnum     TYPE resb-rsnum,
         lv_matnr     TYPE resb-matnr,
         lv_wempf     TYPE numc2,
         lv_aplzl     LIKE resb-aplzl,
         lv_rspos     LIKE resb-rspos,
         lv_total     LIKE mchb-clabs,
         lv_enmng     LIKE resb-enmng,
         ls_onr00     TYPE onr00,
         ls_resb      LIKE LINE OF gt_resb,
*         ls_resb_upd  LIKE LINE OF gt_resb_update,
         ls_operation LIKE LINE OF gt_operation.

  DATA : lt_jest  TYPE TABLE OF jest WITH HEADER LINE,
         ls_jest  LIKE LINE OF gt_jest,
         lt_jsto  TYPE TABLE OF jsto WITH HEADER LINE,
         ls_jsto  LIKE LINE OF gt_jsto,
         lv_objnr LIKE resb-objnr.

  READ TABLE gt_operation INTO ls_operation INDEX 1.
  lv_rsnum = ls_operation-rsnum.

  SELECT MAX( rspos ) INTO lv_rspos
    FROM resb WHERE rsnum = lv_rsnum.

  IF sy-subrc = 0.
    CLEAR: gt_add[],gt_resb_insert[],gt_resb_update[],gt_onr00[],
           gt_jest,gt_jest[],gt_jsto,gt_jsto[].

    LOOP AT gt_operation INTO ls_operation.
      IF ls_operation-erfmg IS INITIAL.
        CONTINUE.
      ENDIF.

      "Insert RESB prepare
      CLEAR: ls_resb-enwrt,ls_resb-stlty,ls_resb-stlnr,ls_resb-stlkn,ls_resb-stpoz,
             lv_total,lv_objnr.

      SELECT SINGLE * INTO ls_resb
        FROM resb WHERE rsnum = ls_operation-rsnum
                    AND rspos = ls_operation-rspos
                    AND splkz IN (' ','1').

      IF sy-subrc = 0.
        SELECT * INTO TABLE lt_jest
          FROM jest WHERE objnr = ls_resb-objnr.
        SELECT * INTO TABLE lt_jsto
          FROM jsto WHERE objnr = ls_resb-objnr.

        ADD 1 TO lv_rspos.
        lv_aplzl = ls_resb-rspos.
        lv_enmng = gs_head-packq * ls_operation-erfmg.

        "Collect itab RESB for Insert
        ls_resb-rspos = lv_rspos.
        ls_resb-charg = ls_operation-charg.
        ls_resb-bdmng = ls_resb-vmeng = lv_enmng.
        ls_resb-splkz = '2'.
        ls_resb-splrv = lv_aplzl.

        IF ls_resb-erfme = ls_resb-meins.
          ls_resb-erfmg = lv_enmng.
        ELSE.
          PERFORM f_uom_conversion USING ls_resb-matnr
                                         ls_resb-meins
                                         ls_resb-erfme
                                         ls_resb-bdmng
                                   CHANGING ls_resb-erfmg.
        ENDIF.

        CLEAR: ls_resb-stvkn,ls_resb-nomng,ls_resb-enmng,ls_resb-enwrt,ls_resb-wempf.
        CONCATENATE ls_resb-objnr(2) ls_resb-rsnum ls_resb-rspos INTO ls_resb-objnr.
        APPEND ls_resb TO gt_resb_insert.

        "Collect itab ONR00 for Insert
        ls_onr00-objnr = ls_resb-objnr.
        APPEND ls_onr00 TO gt_onr00.

        "Collect itab JEST for Insert
        LOOP AT lt_jest.
          MOVE-CORRESPONDING lt_jest TO ls_jest.
          ls_jest-objnr = ls_resb-objnr.
          APPEND ls_jest TO gt_jest.
        ENDLOOP.

        "Collect itab JSTO for Insert
        LOOP AT lt_jsto.
          MOVE-CORRESPONDING lt_jsto TO ls_jsto.
          ls_jsto-objnr = ls_resb-objnr.
          APPEND ls_jsto TO gt_jsto.
        ENDLOOP.

        ADD ls_operation-bdmng TO lv_total.

        "Mofify GI Res. Item for posting GI
        PERFORM f_modify_gi_item USING ls_operation-rsnum
                                       ls_operation-rspos
                                       ls_resb-rspos.
      ENDIF.
    ENDLOOP.

    "Insert & Update RESB
    IF gt_resb_insert[] IS NOT INITIAL.
      CALL FUNCTION 'ZTSPPPFM001'
        TABLES
          it_add                   = gt_add
          it_iresb                 = gt_resb_insert
          it_uresb                 = gt_resb_update
          it_onr00                 = gt_onr00
          it_jest                  = gt_jest
          it_jsto                  = gt_jsto
        EXCEPTIONS
          error_insert_resb        = 1
          error_update_resb        = 2
          error_insert_onro        = 3
          error_insert_zppresb_add = 4
          error_insert_jest        = 5
          error_insert_jsto        = 6.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ADD_LINES_RESB

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_GI_ITEM
*&---------------------------------------------------------------------*
FORM f_modify_gi_item  USING    fu_rsnum
                                fu_rspos
                                fu_rspos2.
  FIELD-SYMBOLS: <fs_item> TYPE bapi2017_gm_item_create.

  READ TABLE goodsmvt_item ASSIGNING <fs_item>
                           WITH KEY reserv_no = fu_rsnum
                                    res_item  = fu_rspos.
  <fs_item>-res_item = fu_rspos2.
ENDFORM.                    " F_MODIFY_GI_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_matnr
                                fu_meins
                                fu_erfme
                                fu_menge
                       CHANGING fu_erfmg.
  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = fu_menge
      matnr                = fu_matnr
      meinh                = fu_erfme
      meins                = fu_meins
    IMPORTING
      output               = fu_erfmg
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.
ENDFORM.                    " F_UOM_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_GET_MEANVAL
*&---------------------------------------------------------------------*
FORM f_get_meanval  USING    fu_werks
                             fu_matnr
                             fu_charg
                    CHANGING fc_meanval.
  DATA: ls_006      TYPE ztspppdt006,
        lv_qty      TYPE resb-enmng,
        lv_meanval  TYPE bapi2045d2-mean_value,
        lv_meanval2 TYPE bapi2045d2-mean_value,
        lv_text     TYPE bapi2045l2-txt_oper,
        lv_inspoper TYPE bapi2045l2-inspoper.

  SELECT SINGLE * INTO ls_006
    FROM ztspppdt006 WHERE werks = fu_werks
                       AND matnr = fu_matnr
                       AND excty = 'P'.

  lv_text     = 'Berat Rata – Rata'.
  lv_inspoper = '9999'.     "'0080'.

  PERFORM f_change_inspoper(ztsppp_e001) USING fu_matnr fu_charg fu_werks
                                         CHANGING lv_text lv_inspoper.

  CALL FUNCTION 'ZQMMATNR_FACTOR'
    EXPORTING
      i_matnr      = fu_matnr
      i_charg      = fu_charg
      i_werks      = fu_werks
      i_text       = lv_text
      i_inspoper   = lv_inspoper
    IMPORTING
      e_mean_value = lv_meanval.

  TRANSLATE lv_meanval USING '. '.
  TRANSLATE lv_meanval USING ',.'.
  CONDENSE lv_meanval.
  IF lv_meanval IS INITIAL.
  ELSE.
    lv_qty        = lv_meanval.
    WRITE lv_qty TO lv_meanval2 DECIMALS 2.
    TRANSLATE lv_meanval2 USING '. '.
    TRANSLATE lv_meanval2 USING ',.'.
    CONDENSE lv_meanval2.
    fc_meanval = lv_meanval2.
  ENDIF.
ENDFORM.                    " F_GET_MEANVAL

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ZTSPPPDT011
*&---------------------------------------------------------------------*
FORM f_write_ztspppdt011 USING    fu_mblnr fu_mjahr.
  DATA: lt_ztspppdt011 TYPE TABLE OF ztspppdt011,
        lw_ztspppdt011 LIKE LINE OF lt_ztspppdt011,
        lv_loop        TYPE int4,
        lv_item        TYPE zeile.

  READ TABLE gt_operation INTO DATA(lw_operation) INDEX 1.

  SORT gt_resb_insert BY rsnum rspos.
  LOOP AT gt_resb_insert INTO DATA(lw_resb).
    CLEAR: lv_loop.   ",lv_item.
    READ TABLE gt_afvc INTO DATA(lw_afvc) WITH KEY aufpl = lw_resb-aufpl
                                                   vornr = lw_resb-vornr.
    IF gs_head-packq = 0.
      lv_loop = 0.
    ELSE.
      lv_loop = lw_resb-erfmg DIV gs_head-packq.
    ENDIF.
    DO lv_loop TIMES.
      ADD 1 TO lv_item.
      lw_ztspppdt011-rsnum      = lw_resb-rsnum.
      lw_ztspppdt011-rspos      = lw_resb-rspos.
      lw_ztspppdt011-rsart      = lw_resb-rsart.
      lw_ztspppdt011-zeile      = lv_item.
      lw_ztspppdt011-aufnr      = lw_resb-aufnr.
      lw_ztspppdt011-posnr      = lw_resb-posnr.
      lw_ztspppdt011-matnr      = lw_resb-matnr.
      lw_ztspppdt011-werks      = lw_resb-werks.
      lw_ztspppdt011-lgort      = lw_resb-lgort.
      lw_ztspppdt011-charg      = lw_resb-charg.
      lw_ztspppdt011-erfmg      = lw_resb-erfmg / lv_loop.
      lw_ztspppdt011-erfme      = lw_resb-erfme.
      lw_ztspppdt011-sortf      = lw_resb-sortf.
      lw_ztspppdt011-vornr      = lw_resb-vornr.
      lw_ztspppdt011-ltxa1      = lw_operation-ltxa1.
      lw_ztspppdt011-phseq      = lw_afvc-phseq.
      lw_ztspppdt011-wbooth     = gs_head-wb.
      lw_ztspppdt011-operator   = gv_operator.
      lw_ztspppdt011-pengawas   = gv_pengawas.
      lw_ztspppdt011-erdat      = sy-datum.
      lw_ztspppdt011-ertim      = sy-uzeit.
      lw_ztspppdt011-mblnr      = fu_mblnr.
      lw_ztspppdt011-mjahr      = fu_mjahr.
      APPEND lw_ztspppdt011 TO lt_ztspppdt011.
      CLEAR lw_ztspppdt011.
    ENDDO.
  ENDLOOP.

  IF lt_ztspppdt011[] IS NOT INITIAL.
    INSERT ztspppdt011 FROM TABLE lt_ztspppdt011.
  ENDIF.
ENDFORM.
