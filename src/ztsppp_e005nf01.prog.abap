*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E005NF01
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
  SET PF-STATUS 'PFSTATUS'.
  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_BEFORE_OUTPUT
*&---------------------------------------------------------------------*
FORM f_process_before_output .
  DATA : lv_subrc     TYPE sy-subrc,
         ls_operation LIKE LINE OF gt_operation,
         ls_material  LIKE LINE OF gt_material.

  CASE sy-dynnr.
    WHEN '0501'.
      PERFORM f_get_order.

      IF gt_order[] IS INITIAL.
        IF gs_head-werks IS NOT INITIAL AND
          gs_head-gstrp IS NOT INITIAL AND
          gs_head-plnbez IS NOT INITIAL.
          PERFORM f_error_message USING 'E' 'Data not found' '' '' ''.
          CLEAR : gs_head-werks, gs_head-gstrp, gs_head-plnbez.
        ENDIF.

        APPEND INITIAL LINE TO gt_order.
        PERFORM f_modify_screen USING : 'ORD' '0' '' '' '',
                                        'NXT' '0' '' '' ''.
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
      ELSE.
        PERFORM f_cursor_position USING 'GS_HEAD-POSNR' '1'.
      ENDIF.

    WHEN '0504'.
      CASE gs_head-werks.
        WHEN '0101'.
          IF gs_head-cmatnr IS INITIAL AND
            gs_head-rspos IS NOT INITIAL.
            CLEAR ls_material.
            READ TABLE gt_material INTO ls_material
                                   WITH KEY rspos = gs_head-rspos.
            IF sy-subrc = 0.
              gs_head-matnr = ls_material-matnr.
            ENDIF.
            PERFORM f_material_get_detail CHANGING lv_subrc.
            PERFORM f_get_batch CHANGING lv_subrc.
            PERFORM f_get_operation USING '2'
                                    CHANGING lv_subrc.

            PERFORM f_nostock.
          ELSE.
            CLEAR gt_material.
            PERFORM f_material_by_system CHANGING lv_subrc.
          ENDIF.

        WHEN '0102'.
          PERFORM f_modify_screen USING : 'ITM' '0' '' '' ''.
          CLEAR gt_material.
          PERFORM f_material_by_system CHANGING lv_subrc.
      ENDCASE.

    WHEN '0502'.
      IF gs_head-werks = '0102'.
        PERFORM f_modify_screen USING : 'WRO' '0' '' '' ''.
      ENDIF.

      PERFORM f_modify_screen USING : '003' '0' '' '' ''.

      IF gv_post IS INITIAL.
        CLEAR : lv_subrc, gs_head-message, gs_head-total.
      ELSE.
        CLEAR : gv_post, gv_stock.
      ENDIF.

      PERFORM f_printer_check CHANGING default-spld lv_subrc.
      PERFORM f_material_get_detail CHANGING lv_subrc.
      PERFORM f_get_batch CHANGING lv_subrc.
      PERFORM f_get_operation USING '2'
                              CHANGING lv_subrc.

      IF gt_operation[] IS INITIAL.
        APPEND INITIAL LINE TO gt_operation.
      ELSE.
        IF gv_authorization IS NOT INITIAL.
          PERFORM f_check_lock_entry USING 'AUFK'
                                     CHANGING lv_subrc.
          IF lv_subrc = 0.
            PERFORM f_check_lock_entry USING 'MCH1'
                                       CHANGING lv_subrc.
            IF lv_subrc = 0.
              PERFORM f_lock_table USING : 'AUFK',
                                           'MCH1'.
            ELSE.
              CLEAR : gs_head-matnr, gt_operation[].
              APPEND INITIAL LINE TO gt_operation.
            ENDIF.
          ELSE.
            CLEAR : gs_head-matnr, gt_operation[].
            APPEND INITIAL LINE TO gt_operation.
          ENDIF.
        ENDIF.
      ENDIF.

      LOOP AT gt_operation INTO ls_operation.
*        PERFORM f_full_calculate USING ls_operation.
        PERFORM f_full_calculate_new USING ls_operation.

        MODIFY TABLE gt_operation FROM ls_operation
*                            INDEX idx
                            TRANSPORTING clabs erfmg vmeng.

        IF gs_head-werks = '0102'.
          PERFORM f_check_stock USING '3'
                                CHANGING lv_subrc.
        ENDIF.
      ENDLOOP.

      DESCRIBE TABLE gt_operation LINES n4.
*      PERFORM f_check_stock USING '3'
*                            CHANGING lv_subrc.

      IF gs_head-matnr IS INITIAL.
        PERFORM f_modify_screen USING : 'OPR' '0' '' '' '',
                                        'RAW' '0' '' '' '',
                                        'PRT' '0' '' '' '',
                                        'PGI' '0' '' '' ''.
      ENDIF.

      CASE lv_subrc.
        WHEN 3.
          PERFORM f_modify_screen USING : 'OPR' '0' '' '' '',
                                          'RAW' '0' '' '' '',
                                          'PRT' '0' '' '' ''.

        WHEN 5.
          PERFORM f_modify_screen USING : 'OPR' '0' '' '' '',
                                          'PRT' '0' '' '' '',
                                          'PGI' '0' '' '' ''.
        WHEN 7.
          PERFORM f_modify_screen USING : 'CMA' '' '0' '' ''.

        WHEN 9.
          PERFORM f_modify_screen USING : 'PRT' '0' '' '' ''.

        WHEN 99.
          PERFORM f_modify_screen USING : 'OPR' '0' '' '' '',
                                          'RAW' '0' '' '' '',
                                          'PRT' '0' '' '' ''.
      ENDCASE.

    WHEN '0503'.
      PERFORM f_modify_screen USING : '002' '0' '' '' ''.

      PERFORM f_get_operation USING '3'
                              CHANGING lv_subrc.
      IF lv_subrc IS NOT INITIAL.
        PERFORM f_modify_screen USING : '003' '0' '' '' ''.
      ENDIF.
      DESCRIBE TABLE gt_operation LINES n6.

      IF gv_confirm IS NOT INITIAL.
        PERFORM f_modify_screen USING : '003' '0' '' '' ''.
        CLEAR gv_confirm.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  n1 = 1.
  n3 = 1.
  n5 = 1.
  n7 = 1.
  CASE sy-dynnr.
    WHEN '0501'.
      IF gs_head IS INITIAL.
        CLEAR : gs_head.
        LEAVE TO SCREEN 0.
      ELSEIF gs_head-werks IS INITIAL
        AND gs_head-plnbez IS INITIAL.
        CLEAR : gs_head.
        LEAVE TO SCREEN 0.
      ELSE.
        CLEAR : gs_head.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN '0502' OR '0503' OR '0504'.
      CLEAR : gs_head-posnr, gs_head-matnr, gs_head-charg, gs_head-clabs,
              component[], gt_temp[], gt_operation[],
              gs_operation, gs_head-message, gv_mara, gv_matnr,
              gt_mara[], gs_head-rspos, gs_head-bdmng.
      PERFORM f_unlock_table.
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
    WHEN '0501'.

    WHEN '0502'.
      PERFORM f_split_field.

      IF gv_matnr IS NOT INITIAL.
        PERFORM f_material_selection.
        PERFORM f_get_operation USING '1'
                                CHANGING lv_subrc.

*        IF gs_head-message IS INITIAL.
*          PERFORM f_modify_screen USING : 'PRT' '1' '' '' ''.
*        ENDIF.
      ENDIF.

    WHEN '0504'.
      PERFORM f_split_field.

      IF gv_matnr IS NOT INITIAL.
        PERFORM f_material_selection.
        PERFORM f_get_operation USING '1'
                                CHANGING lv_subrc.

*        IF gs_head-message IS INITIAL.
*          PERFORM f_modify_screen USING : 'PRT' '1' '' '' ''.
*        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm    TYPE sy-ucomm,
         ls_ymara    LIKE LINE OF gt_ymara.

  lv_ucomm  = ok_code.
  CLEAR ok_code.
  CASE lv_ucomm.
    WHEN '&LOGOFF'.
      PERFORM f_clear_data.
      CALL 'SYST_LOGOFF'.

    WHEN '&BACK'.
      PERFORM f_clear_data.
      PERFORM f_unlock_table.

    WHEN '&NEXT'.
      PERFORM f_next_button.

    WHEN '&NXRM'.
      ADD 1 TO gv_mara.
      IF gv_mara > gv_lines.
        gv_mara = gv_lines.
      ENDIF.
      CLEAR : gt_operation[], gs_operation, gs_head-matnr, gs_head-charg,
              gv_matnr, gv_duplicate, gt_temp[].

    WHEN '&PRRM'.
      gv_mara = gv_mara - 1.
      IF gv_mara < 1.
        gv_mara = 1.
      ENDIF.
      CLEAR : gt_operation[], gs_operation, gs_head-matnr, gs_head-charg,
              gv_matnr, gv_duplicate, gt_temp[].

    WHEN '&NOSTCK'.
      PERFORM f_nostock.

    WHEN '&CONF'.
      gv_confirm = 'X'.
      PERFORM f_update_resb USING 'W'.
      PERFORM f_refresh_resb USING ''.

*      CLEAR : gt_batch[], component[], gs_head-bdmng.

    WHEN '&PGI'.
      PERFORM f_prepare_data.
      PERFORM f_unlock_table.
      IF gv_nfull = 0.
        PERFORM f_post_goods_issue.
        PERFORM f_update_resb USING ''.
      ELSE.
        PERFORM f_print_form USING ''.
        PERFORM f_update_resb USING 'W'.
      ENDIF.

    WHEN '&PRINT'.
      IF gs_head-message IS INITIAL.
        PERFORM f_prepare_data.
        PERFORM f_unlock_table.
        PERFORM f_print_form USING ''.
        PERFORM f_update_resb USING 'W'.

        PERFORM f_delete_matnr USING gv_matnr.
        PERFORM f_refresh_resb USING '3'.

        CLEAR : gt_operation[], gs_operation, gs_head-matnr, gs_head-charg,
                gv_matnr, gv_duplicate, gt_temp[], gt_label[], gs_head-bdmng.

        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN '&PPGUP'.
      PERFORM f_display_data USING '-'.

    WHEN '&PPGDN'.
      PERFORM f_display_data USING '+'.

    WHEN OTHERS.
*      CASE sy-dynnr.
*        WHEN '0201'.
*          IF gs_head-posnr IS NOT INITIAL.
*            gs_order-check = 'X'.
*            MODIFY gt_order FROM gs_order
*                            TRANSPORTING check
*                            WHERE posnr = gs_head-posnr.
*            CLEAR gs_head-posnr.
*          ENDIF.
*      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_TABLE
*&---------------------------------------------------------------------*
FORM f_generate_table .
  DATA : lv_bdmng   TYPE resb-bdmng,
         lv_subrc   TYPE sy-subrc.

  idx = sy-stepl + line.

  CASE sy-dynnr.
    WHEN '0501'.
    WHEN '0504'.
    WHEN '0502'.
      READ TABLE gt_operation INTO gs_operation INDEX idx.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = gs_operation-meins
        IMPORTING
          output         = gs_operation-meins
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

**      PERFORM f_full_calculate.
**
**      MODIFY gt_operation FROM gs_operation
**                          INDEX idx
**                          TRANSPORTING clabs erfmg vmeng.
**
**      PERFORM f_check_stock USING '3'
**                            CHANGING lv_subrc.
  ENDCASE.
ENDFORM.                    " F_GENERATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table .
  DATA : lv_line        TYPE i.

  GET CURSOR LINE lv_line.

  CASE sy-dynnr.
    WHEN '0501'.
    WHEN '0502'.
  ENDCASE.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER
*&---------------------------------------------------------------------*
FORM f_get_order .
  DATA : ls_order   LIKE LINE OF gt_order,
         lv_subrc   TYPE sy-subrc,
         lv_count   TYPE afpo-posnr,
         lt_afpo    TYPE STANDARD TABLE OF afpo,
         ls_afpo    LIKE LINE OF lt_afpo,
         lt_resb    TYPE STANDARD TABLE OF resb,
         ls_resb    LIKE LINE OF lt_resb,
         ls_makt    LIKE LINE OF gt_makt,
         lt_fevor   TYPE STANDARD TABLE OF range_fev,
         lv_flag.

  CLEAR : gt_order[], gs_head-message.

*  IF gs_head-gstrp IS INITIAL.
*    gs_head-gstrp = sy-datum.
*  ENDIF.

  IF gs_head-werks IS NOT INITIAL AND
    gs_head-gstrp IS NOT INITIAL AND
    gs_head-plnbez IS NOT INITIAL.

    IF gs_head-werks = '0102'.
      PERFORM f_get_prodscheduler TABLES lt_fevor
                                  USING : 'SOL', 'SFI', 'CAP'.

      SELECT *
        FROM marc
        INTO CORRESPONDING FIELDS OF TABLE gt_marc
        WHERE matnr = gs_head-plnbez
          AND werks = gs_head-werks
          AND fevor IN lt_fevor.
    ENDIF.

    IF gt_marc[] IS NOT INITIAL.
      lv_flag  = 'X'.
    ENDIF.

    SELECT afko~aufnr afko~gstrp afko~plnbez aufk~werks aufk~objnr
      FROM afko JOIN aufk ON afko~aufnr = aufk~aufnr
      INTO CORRESPONDING FIELDS OF TABLE gt_order
      WHERE werks   = gs_head-werks
        AND gstrp   = gs_head-gstrp
        AND plnbez  = gs_head-plnbez.

    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      WHERE matnr = gs_head-plnbez
        AND spras = sy-langu.

    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = gs_head-plnbez.
    IF sy-subrc = 0.
      gs_head-maktx = ls_makt-maktx.
    ENDIF.
  ENDIF.

  IF gt_order[] IS NOT INITIAL.
    SELECT *
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE lt_afpo
      FOR ALL ENTRIES IN gt_order
      WHERE aufnr = gt_order-aufnr.
  ENDIF.

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
      WHERE aufnr = gt_order-aufnr
        AND xloek = space.

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

  PERFORM f_order_only_fullpack USING lv_flag.
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
            itx04   TYPE jestd-itx04,
          END OF ty_status.

  DATA : lt_status    TYPE STANDARD TABLE OF ty_status,
         ls_status    LIKE LINE OF lt_status,
         line         TYPE bsvx-sttxt.

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
  DATA : ls_order   LIKE LINE OF gt_order,
         lv_line    TYPE i,
         lv_subrc   TYPE sy-subrc.

  IF gt_order[] IS NOT INITIAL.
    CALL SCREEN 504.
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
  DATA : order_objects    TYPE bapi_pi_order_objects,
         return           TYPE bapiret2.

  DATA : ls_component    LIKE LINE OF component,
         lt_xphase       TYPE STANDARD TABLE OF afvc,
         ls_phase        LIKE LINE OF phase,
         lt_xoperation   TYPE STANDARD TABLE OF ty_operation,
         ls_operation    TYPE ty_operation,
         ls_xoperation   TYPE ty_operation,
         ls_batch        TYPE ty_operation,
         lt_afvu         TYPE STANDARD TABLE OF afvu,
         ls_afvu         LIKE LINE OF lt_afvu,
         ls_resb         LIKE LINE OF gt_resb,
         ls_yresb        LIKE LINE OF gt_yresb,
         ls_order        LIKE LINE OF gt_order,
         ls_afvc         LIKE LINE OF gt_afvc,
         lv_bdmng        TYPE resb-bdmng,
         lv_vornr        TYPE resb-vornr,
         lt_resb         TYPE STANDARD TABLE OF resb,
         ls_xresb        LIKE LINE OF gt_xresb,
         lt_mchb         TYPE STANDARD TABLE OF mchb,
         ls_mchb         LIKE LINE OF lt_mchb,
         lv_c1           TYPE i,
         lv_c2           TYPE i,
*         lv_bdmng        TYPE resb-bdmng,
         lv_erfmg        TYPE resb-erfmg,
         ls_mseg         LIKE LINE OF gt_mseg,
         lv_menge        TYPE mseg-menge.

  IF fc_subrc IS INITIAL.
    CASE fu_flag.
      WHEN '1'.
        IF component[] IS INITIAL.
          LOOP AT gt_resb INTO ls_resb.
            CLEAR ls_order.
            READ TABLE gt_order INTO ls_order
                                WITH KEY aufnr = ls_resb-aufnr.
            IF sy-subrc = 0.
              ls_component = ls_resb.
              APPEND ls_component TO component.
            ENDIF.
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
*        CLEAR : gt_operation[].
        IF gs_head-matnr IS NOT INITIAL.
          DELETE gt_operation WHERE clabs = 0.
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

          IF gt_order[] IS NOT INITIAL.
            CLEAR : gv_bdmng, lv_bdmng.
            LOOP AT gt_order INTO ls_order.
              LOOP AT gt_resb INTO ls_resb WHERE aufnr = ls_order-aufnr
                                             AND matnr = gs_head-matnr.
                lv_bdmng = ls_resb-bdmng - ls_resb-enmng.
                ADD lv_bdmng TO gv_bdmng.
                ls_yresb  = ls_resb.
                APPEND ls_yresb TO gt_yresb.
                CLEAR : ls_yresb, lv_bdmng.
              ENDLOOP.
            ENDLOOP.

            CLEAR lv_bdmng.
            lv_bdmng = gv_bdmng / gs_head-packq.
            CALL FUNCTION 'ROUND'
              EXPORTING
                input         = lv_bdmng
                sign          = '+'
              IMPORTING
                output        = gs_head-total
              EXCEPTIONS
                input_invalid = 1
                overflow      = 2
                type_invalid  = 3
                OTHERS        = 4.
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
              ls_operation-bdmng = ls_component-erfmg - ls_component-enmng.
              ls_operation-meins = ls_component-erfme.
            ENDIF.
            ls_operation-aufnr    = gs_head-aufnr.
            ls_operation-matnr    = gs_head-matnr.
            ls_operation-charg    = gs_head-charg.
            ls_operation-lgort    = ls_component-lgort.

            IF ls_operation-bdmng > gs_head-packq.
              gs_head-message = 'Proses full pack belum selesai'.
              fc_subrc = 8.
              EXIT.
            ENDIF.

            CLEAR ls_xoperation.
            READ TABLE gt_operation INTO ls_xoperation
                                    WITH KEY vornr = ls_component-vornr.
            IF sy-subrc = 0.
              IF ls_xoperation-bdmng = ls_xoperation-erfmg.
                CONTINUE.
*              ELSE.
*                ls_operation-bdmng  = ls_operation-bdmng - ls_xoperation-erfmg.
              ENDIF.
            ENDIF.
            COLLECT ls_operation INTO gt_operation.
            CLEAR ls_operation.
          ENDLOOP.

          lt_xoperation[] = gt_operation[].
          LOOP AT gt_operation INTO ls_operation.
            IF ls_operation-vornr <> lv_vornr.
              CLEAR lv_c1.
            ENDIF.
            ADD 1 TO lv_c1.
            IF lv_c1 = 1.
              lv_bdmng  = ls_operation-bdmng.
              lv_vornr  = ls_operation-vornr.
              CONTINUE.
            ELSE.
              CLEAR lv_erfmg.
              LOOP AT lt_xoperation INTO ls_xoperation WHERE vornr = ls_operation-vornr.
                ADD 1 TO lv_c2.
*                IF lv_c2 < lv_c1.
                ADD ls_xoperation-erfmg TO lv_erfmg.
*                ENDIF.
              ENDLOOP.
            ENDIF.
            ls_operation-bdmng = lv_bdmng - lv_erfmg.
            MODIFY TABLE gt_operation FROM ls_operation TRANSPORTING bdmng.
            CLEAR : ls_operation, lv_c2.
          ENDLOOP.
        ENDIF.

      WHEN '3'.
        LOOP AT gt_yresb INTO ls_yresb.
          MOVE-CORRESPONDING ls_yresb TO ls_component.
          ls_operation-bdmng = ls_component-bdmng - ls_component-enmng.
          ADD ls_operation-bdmng TO gs_head-bdmng.
*          APPEND ls_component TO component.
        ENDLOOP.

        lt_resb[] = gt_yresb[].
        SORT lt_resb BY matnr werks lgort.
        DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr werks lgort.
        IF lt_resb[] IS NOT INITIAL.
          SELECT *
            FROM mchb
            INTO CORRESPONDING FIELDS OF TABLE lt_mchb
            FOR ALL ENTRIES IN lt_resb
            WHERE matnr = lt_resb-matnr
              AND werks = lt_resb-werks
              AND lgort = lt_resb-lgort
              AND clabs <> 0.
        ENDIF.

        IF lt_mchb[] IS INITIAL.
          APPEND INITIAL LINE TO gt_batch.
        ELSE.
          SELECT *
            FROM resb
            INTO CORRESPONDING FIELDS OF TABLE gt_xresb
            FOR ALL ENTRIES IN lt_mchb
            WHERE matnr = lt_mchb-matnr
              AND charg = lt_mchb-charg
*              AND wempf IN ('W', 'T')
              AND bwart = gv_261
              AND kzear = space
              AND xloek = space.

          LOOP AT lt_mchb INTO ls_mchb WHERE matnr = gs_head-matnr.
            ls_batch-charg  = ls_mchb-charg.
            ls_batch-clabs  = ls_mchb-clabs.
            ls_batch-meins  = gs_head-rmein.
            ADD ls_mchb-clabs TO gs_head-clabs.
            COLLECT ls_batch INTO gt_batch.
            CLEAR ls_batch.
          ENDLOOP.

          CLEAR ls_batch.
          LOOP AT gt_batch INTO ls_batch.
            LOOP AT gt_xresb INTO ls_xresb WHERE matnr = gs_head-matnr
                                             AND charg = ls_batch-charg.
              ADD ls_xresb-bdmng TO lv_bdmng.
            ENDLOOP.
            ls_batch-clabs = ls_batch-clabs - lv_bdmng.
            MODIFY TABLE gt_batch FROM ls_batch TRANSPORTING clabs.
            CLEAR : ls_batch, lv_bdmng.
          ENDLOOP.
        ENDIF.

        IF gs_head-clabs < gs_head-bdmng.
          fc_subrc  = 5.
          gs_head-message = 'Stock tidak cukup, lakukan reservasi tambahan'.
        ENDIF.
*        IF gv_confirm IS NOT INITIAL.
*          gs_head-message = 'Alokasi calon timbang selesai dilakukan'.
*        ENDIF.
    ENDCASE.
  ELSE.
    CLEAR gt_batch[].
  ENDIF.
ENDFORM.                    " F_GET_OPERATION

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_FIELD
*&---------------------------------------------------------------------*
FORM f_split_field .
  IF gs_head-cmatnr IS NOT INITIAL.
    SPLIT gs_head-cmatnr AT ';' INTO gv_matnr gs_head-charg
                                     gs_head-count gs_head-qty.
    gv_print = 'X'.
  ENDIF.

  CLEAR : gs_head-cmatnr.
ENDFORM.                    " F_SPLIT_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_material_get_detail CHANGING fc_subrc.
  DATA : material       TYPE bapimatdoa,
         return         TYPE bapireturn,
         lr_mtart       TYPE RANGE OF mtart,
         ls_mtart       LIKE LINE OF lr_mtart.

  IF fc_subrc IS INITIAL.
    IF gs_head-matnr IS NOT INITIAL.
      CLEAR ls_mtart.
      ls_mtart-low    = 'ZRM'.
      ls_mtart-sign   = 'I'.
      ls_mtart-option = 'EQ'.
      APPEND ls_mtart TO lr_mtart.
      CLEAR ls_mtart.
      ls_mtart-low    = 'ZSFG'.
      ls_mtart-sign   = 'I'.
      ls_mtart-option = 'EQ'.
      APPEND ls_mtart TO lr_mtart.
      CLEAR ls_mtart.

      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
        EXPORTING
          material              = gs_head-matnr
          plant                 = gs_head-werks
        IMPORTING
          material_general_data = material
          return                = return.
      IF return-type = 'S' AND
        material-matl_type IN lr_mtart.
        gs_head-maktx  = material-matl_desc.
        gs_head-rmein  = material-base_uom.
        gs_head-mtart  = material-matl_type.
      ELSE.
        fc_subrc  = 1.
      ENDIF.
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
  DATA : ls_mchb        TYPE mchb,
         cob            TYPE STANDARD TABLE OF clbatch,
         ls_cob         LIKE LINE OF cob,
         ls_component   LIKE LINE OF gt_component,
         ls_temp        LIKE LINE OF gt_temp,
         lv_clabs       TYPE resb-bdmng,
         lv_meins       TYPE resb-meins,
         lv_erfme       TYPE resb-erfme,
         ls_xresb       LIKE LINE OF gt_xresb,
         lv_subrc       TYPE sy-subrc,
         ls_marm        TYPE marm,
         lv_erfmg       TYPE resb-erfmg.

  IF fc_subrc IS INITIAL.
    IF gs_head-charg IS NOT INITIAL.
      READ TABLE gt_component INTO ls_component
                              WITH KEY matnr = gs_head-matnr
                                       werks = gs_head-werks.
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
        CLEAR : ls_temp, gv_duplicate.
        READ TABLE gt_temp INTO ls_temp
                           WITH KEY matnr = gs_head-matnr
                                    charg = gs_head-charg.
        IF sy-subrc = 0.
          gv_duplicate    = 'X'.
        ELSE.
          CLEAR ls_component.
          READ TABLE component INTO ls_component
                               WITH KEY matnr = gs_head-matnr.
          PERFORM f_uom_conversion USING ls_component-erfme ls_component-meins
                                         ls_mchb-clabs ''
                                   CHANGING ls_mchb-clabs.

          gs_head-clabs = ls_mchb-clabs.

          LOOP AT gt_xresb INTO ls_xresb WHERE matnr = gs_head-matnr
                                           AND charg = gs_head-charg
                                           AND lgort = ls_component-lgort.
            PERFORM f_uom_conversion USING ls_xresb-erfme ls_xresb-meins
                                           ls_xresb-bdmng ''
                                     CHANGING ls_xresb-bdmng.
            ADD ls_xresb-bdmng TO lv_clabs.
            lv_erfme  = ls_xresb-erfme.
          ENDLOOP.

          CLEAR ls_component.
          LOOP AT component INTO ls_component WHERE matnr = gs_head-matnr.
            PERFORM f_uom_conversion USING ls_component-meins ls_component-erfme
                                           ls_component-erfmg ''
                                     CHANGING ls_component-erfmg.
            ADD ls_component-erfmg TO lv_erfmg.
          ENDLOOP.

          PERFORM f_uom_conversion USING lv_erfme ls_component-erfme
                                         lv_clabs 'X'
                                   CHANGING lv_clabs.

          gs_head-clabs = gs_head-clabs - lv_clabs.
        ENDIF.

        IF gs_head-mtart = 'ZSFG'.
          SELECT SINGLE *
            FROM marm
            INTO CORRESPONDING FIELDS OF ls_marm
            WHERE matnr = gs_head-matnr
              AND meinh = 'DR'.
          IF sy-subrc = 0.
            gs_head-packq  = ls_marm-umrez.
            IF lv_erfmg > ls_mchb-clabs.
              IF ls_mchb-clabs < gs_head-packq.
*                fc_subrc = 5.
                gs_head-message = 'Stock tidak cukup, lakukan reservasi tambahan'.
              ENDIF.
            ENDIF.
          ELSE.
            fc_subrc = 6.
            gs_head-message = 'Pack belum dimaintain'.
          ENDIF.
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
              PERFORM f_uom_conversion USING ls_component-erfme ls_component-meins
                                             gs_head-packq ''
                                       CHANGING gs_head-packq.
              IF lv_erfmg > ls_mchb-clabs.
                IF ls_mchb-clabs < gs_head-packq.
*                  fc_subrc = 5.
                  gs_head-message = 'Stock tidak cukup, lakukan reservasi tambahan'.
                ENDIF.
              ENDIF.
            ELSE.
              fc_subrc = 6.
              gs_head-message = 'Pack belum dimaintain'.
            ENDIF.
          ELSE.
            fc_subrc = 6.
            gs_head-message = 'Pack belum dimaintain'.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      fc_subrc = 99.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table USING fu_tabname.
  CASE fu_tabname.
    WHEN 'AUFK'.
      CALL FUNCTION 'ENQUEUE_ESORDER'
        EXPORTING
          aufnr          = gs_head-aufnr
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
FORM f_check_lock_entry  USING    fu_value
                         CHANGING fc_subrc.
  DATA : enq      TYPE STANDARD TABLE OF seqg3,
         ls_enq   LIKE LINE OF enq,
         lv_gtarg   TYPE seqg3-gtarg.

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
          WHEN 'MCH1'.
            lv_gtarg(3)     = sy-mandt.
            lv_gtarg+3(18)  = gs_head-matnr.
            lv_gtarg+21(10) = gs_head-charg.
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
  DATA : lv_mblnr   TYPE mseg-mblnr,
         lv_mjahr   TYPE mseg-mjahr,
         return     TYPE STANDARD TABLE OF bapiret2,
         ls_return  TYPE bapiret2.

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

    PERFORM f_print_form USING lv_mblnr.

    CONCATENATE 'Document' lv_mblnr 'created' INTO gs_head-message
    SEPARATED BY space.

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
  ENDIF.
ENDFORM.                    " F_POST_GOODS_ISSUE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : ls_temp        LIKE LINE OF gt_temp,
         ls_item        TYPE bapi2017_gm_item_create,
         lt_label       TYPE STANDARD TABLE OF ztspppst004,
         ls_label       TYPE ztspppst004,
         lv_count       TYPE i,
         lv_times       TYPE i,
         lv_erfmg       TYPE resb-erfmg,
         lv_total       TYPE resb-erfmg,
         lt_hazcom      TYPE TABLE OF ztspmdhazcom WITH HEADER LINE,
         h(10), f(10), r(10),
         lv_hazcom      TYPE char30,
         lt_xtemp       TYPE STANDARD TABLE OF ty_operation,
         ls_xtemp       LIKE LINE OF lt_xtemp,
         lt_mtemp       TYPE STANDARD TABLE OF ty_operation,
         ls_mtemp       LIKE LINE OF lt_mtemp.

  CLEAR : goodsmvt_header, goodsmvt_item[].

  goodsmvt_header-pstng_date = sy-datum.
  goodsmvt_header-doc_date   = sy-datum.
  goodsmvt_header-header_txt = gs_head-aufnr.

  LOOP AT gt_operation INTO ls_temp.
    ls_xtemp  = ls_temp.
    CLEAR : ls_xtemp-ltxa1, ls_xtemp-usr00, ls_xtemp-clabs, ls_xtemp-vornr.
    COLLECT ls_xtemp INTO lt_xtemp.
    CLEAR ls_xtemp.

    ls_mtemp-matnr  = ls_temp-matnr.
    APPEND ls_mtemp TO lt_mtemp.
    CLEAR ls_mtemp.
  ENDLOOP.

  SORT lt_mtemp BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mtemp COMPARING matnr.
  IF lt_mtemp[] IS NOT INITIAL.
    SELECT *
      FROM makt
      APPENDING CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN lt_mtemp
      WHERE matnr = lt_mtemp-matnr
        AND spras = sy-langu.
  ENDIF.

  LOOP AT lt_xtemp INTO ls_temp.
    IF ls_temp-erfmg IS INITIAL.
      CONTINUE.
    ENDIF.
    ADD 1 TO lv_count.
    ls_label-aufnr               = gs_head-aufnr.
    ls_label-fcharg              = gs_head-fcharg.
    ls_label-plnbez              = gs_head-plnbez.
    PERFORM f_matnr_description USING gs_head-plnbez ''
                                CHANGING ls_label-fmaktx.
    ls_label-rspos               = ls_temp-rspos.
    PERFORM f_matnr_description USING '' ls_temp-vornr
                                CHANGING ls_label-ltxa1.
    PERFORM f_matnr_description USING ls_temp-matnr ''
                                CHANGING ls_label-maktx.

    ls_label-usr00               = ls_temp-usr00.
    ls_label-matnr               = ls_temp-matnr.
    ls_label-charg               = ls_temp-charg.
    ls_label-vornr               = ls_temp-vornr.
    ls_label-posnr               = ls_temp-posnr.
    ls_label-erfmg               = ls_temp-erfmg.
    ls_label-erfme               = ls_temp-meins.

    lv_erfmg = ls_temp-erfmg / gs_head-packq.
    CALL FUNCTION 'ROUND'
      EXPORTING
        input         = lv_erfmg
        sign          = '+'
      IMPORTING
        output        = lv_times
      EXCEPTIONS
        input_invalid = 1
        overflow      = 2
        type_invalid  = 3
        OTHERS        = 4.

    DO lv_times TIMES.
      APPEND ls_label TO lt_label.
    ENDDO.
*    ADD ls_temp-erfmg TO lv_erfmg.
    CLEAR ls_label.
  ENDLOOP.

*  lv_times  = gs_head-total - lv_count.
*  IF lv_times > 0.
*    READ TABLE lt_label INTO ls_label INDEX 1.
*    ls_label-charg   = gs_head-charg.
*    DO lv_times TIMES.
*      APPEND ls_label TO lt_label.
*    ENDDO.
*  ENDIF.

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

    WRITE ls_label-erfmg TO ls_label-erfmgt UNIT ls_label-erfme.
    CONDENSE ls_label-erfmgt NO-GAPS.
    PERFORM f_meins_convertion USING ls_label-erfme
                               CHANGING ls_label-erfmgt.
    ls_label-nofull              = 'X'.
    APPEND ls_label TO gt_label.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form  USING    fu_mblnr.
  DATA : lv_formname         TYPE tdsfname,
         lv_funcname         TYPE tdsfname,
         ctrl_param          LIKE ssfctrlop,
         output_opt          TYPE ssfcompop,
         ls_label            TYPE ztspppst004,
         lv_ldest            TYPE t329d-ldest.

  lv_formname = 'ZTSPPPF006'.

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
    IF gv_nfull IS NOT INITIAL.
      ls_label-nofull = 'X'.
    ENDIF.

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
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_RESB
*&---------------------------------------------------------------------*
FORM f_update_resb USING fu_wempf.
  DATA : ls_yresb   LIKE LINE OF gt_yresb,
         ls_label   LIKE LINE OF gt_label.

  IF gt_operation[] IS INITIAL.
    LOOP AT gt_yresb INTO ls_yresb WHERE matnr = gs_head-matnr.
      TRY .
          UPDATE resb SET wempf = fu_wempf
                      WHERE rsnum = ls_yresb-rsnum
                        AND rspos = ls_yresb-rspos.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      COMMIT WORK AND WAIT.

      DELETE gt_resb WHERE rsnum = ls_yresb-rsnum
                       AND rspos = ls_yresb-rspos.
    ENDLOOP.
  ELSE.
    LOOP AT gt_yresb INTO ls_yresb WHERE matnr = gs_head-matnr.
*      CLEAR ls_label.
*      READ TABLE gt_label INTO ls_label
*                          WITH KEY vornr = ls_yresb-vornr.
*      IF sy-subrc = 0.
      TRY .
          UPDATE resb SET wempf = fu_wempf
                      WHERE rsnum = ls_yresb-rsnum
                        AND rspos = ls_yresb-rspos.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      COMMIT WORK AND WAIT.

      DELETE gt_resb WHERE rsnum = ls_yresb-rsnum
                       AND rspos = ls_yresb-rspos.
*                       AND vornr = ls_yresb-vornr.
*      ENDIF.
    ENDLOOP.
  ENDIF.

  gs_head-message = 'Alokasi calon timbang selesai dilakukan'.
ENDFORM.                    " F_UPDATE_RESB

*&---------------------------------------------------------------------*
*&      Form  F_MATNR_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_matnr_description  USING    fu_matnr fu_vornr
                          CHANGING fc_description.
  DATA : ls_makt    TYPE makt.

  CLEAR fc_description.

  IF fu_matnr IS NOT INITIAL.
    READ TABLE gt_makt INTO ls_makt
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
FORM f_full_calculate USING fs_operation TYPE ty_operation.
  DATA : lv_div     TYPE i,
         lv_total   TYPE mchb-clabs,
         ls_temp    LIKE LINE OF gt_temp,
         lv_erfmg   TYPE resb-erfmg.

  gv_total = fs_operation-bdmng.

  IF fs_operation-clabs IS INITIAL.
    fs_operation-clabs  = gs_head-clabs.

    IF gv_total >= fs_operation-bdmng.
      IF fs_operation-clabs < fs_operation-bdmng.
        fs_operation-erfmg = fs_operation-clabs.
*        lv_div = gs_operation-clabs DIV gs_head-packq.
      ELSE.
        fs_operation-erfmg = fs_operation-bdmng.
*        lv_div = gs_operation-bdmng DIV gs_head-packq.
      ENDIF.
*      gs_operation-erfmg = gs_head-packq * lv_div.

      IF gv_duplicate IS INITIAL.
        IF fs_operation-matnr IS NOT INITIAL AND
          fs_operation-charg IS NOT INITIAL.
          CLEAR ls_temp.
          READ TABLE gt_temp INTO ls_temp
                             WITH KEY vornr = fs_operation-vornr.
          IF sy-subrc = 0.
            IF ls_temp-erfmg <> fs_operation-erfmg.
              lv_erfmg      = ls_temp-erfmg.
              ls_temp       = fs_operation.
              ls_temp-erfmg = fs_operation-erfmg - lv_erfmg.
              APPEND ls_temp TO gt_temp.
            ENDIF.
          ELSE.
            APPEND fs_operation TO gt_temp.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF gv_total > 0.
        fs_operation-erfmg = gv_total.
        APPEND fs_operation TO gt_temp.
      ENDIF.
    ENDIF.

*    IF gv_stock IS NOT INITIAL.
*      gs_operation-bdmng  = 0.
*    ENDIF.

    gv_total  = gv_total - fs_operation-erfmg.

    IF fs_operation-matnr IS NOT INITIAL AND
      fs_operation-charg IS NOT INITIAL.
      gv_stock  = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FULL_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_PRINTER_CHECK
*&---------------------------------------------------------------------*
FORM f_printer_check  CHANGING fc_spld fc_subrc.
  DATA : ls_tsp03d    TYPE tsp03d,
         ls_tsp06a    TYPE tsp06a.

  DATA : parameter      TYPE STANDARD TABLE OF bapiparam,
         ls_parameter   LIKE LINE OF parameter.

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
*&      Form  F_CHECK_STOCK
*&---------------------------------------------------------------------*
FORM f_check_stock USING    fu_flag
                   CHANGING fc_subrc.
  DATA : ls_operation   LIKE LINE OF gt_operation,
         lv_bdmng       TYPE resb-bdmng,
         lv_erfmg       TYPE resb-erfmg,
         lv_clabs       TYPE mchb-clabs,
         ls_temp        LIKE LINE OF gt_temp.

  IF fc_subrc = 3 OR
    fc_subrc = 9.
    CLEAR fc_subrc.
  ENDIF.
  IF gv_duplicate IS INITIAL.
    CASE fu_flag.
      WHEN '1'.
        CLEAR ls_operation.
        READ TABLE gt_operation INTO ls_operation INDEX 1.
        IF sy-subrc = 0.
          lv_bdmng  = ls_operation-bdmng.
        ENDIF.
        CLEAR ls_operation.
        LOOP AT gt_operation INTO ls_operation.
          ADD ls_operation-erfmg TO lv_erfmg.
        ENDLOOP.
        IF lv_bdmng > lv_erfmg.
          fc_subrc = 9.
          gs_head-message = 'Quantity masih kurang'.
        ENDIF.
      WHEN '2'.
        CLEAR ls_operation.
        LOOP AT gt_operation INTO ls_operation.
          ADD ls_operation-bdmng TO lv_bdmng.
        ENDLOOP.
        IF lv_bdmng > gs_head-clabs.
          fc_subrc = 9.
          gs_head-message = 'Quantity masih kurang'.
        ENDIF.
      WHEN '3'.
        CLEAR ls_operation.
        READ TABLE gt_operation INTO ls_operation INDEX 1.
        IF sy-subrc = 0.
          lv_bdmng  = ls_operation-bdmng.
        ENDIF.
        CLEAR ls_operation.
        LOOP AT gt_operation INTO ls_operation.
          ADD ls_operation-clabs TO lv_clabs.
        ENDLOOP.
        IF lv_bdmng > lv_clabs.
          fc_subrc = 9.
          gs_head-message = 'Quantity masih kurang'.
        ELSE.
          IF gs_head-message = 'Quantity masih kurang'.
            CLEAR gs_head-message.
          ENDIF.
        ENDIF.
    ENDCASE.
  ELSE.
    fc_subrc = 3.
    gs_head-message = 'Duplikasi batch'.
  ENDIF.
ENDFORM.                    " F_CHECK_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_BY_SYSTEM
*&---------------------------------------------------------------------*
FORM f_material_by_system CHANGING fc_subrc.
  DATA : ls_mara    LIKE LINE OF gt_mara,
         ls_resb    LIKE LINE OF gt_resb.

  DATA : lt_xmara       TYPE STANDARD TABLE OF mara,
         ls_xmara       LIKE LINE OF lt_xmara,
         lt_makt        TYPE STANDARD TABLE OF makt,
         ls_makt        LIKE LINE OF lt_makt,
         ls_material    LIKE LINE OF gt_material,
         ls_ymara       LIKE LINE OF gt_ymara,
         lt_resb        TYPE STANDARD TABLE OF resb,
         ls_order       LIKE LINE OF gt_order.

  DATA : lv_rspos       TYPE resb-rspos.

  lt_resb[] = gt_resb[].
  LOOP AT lt_resb INTO ls_resb.
    CLEAR ls_order.
    READ TABLE gt_order INTO ls_order
                        WITH KEY aufnr = ls_resb-aufnr.
    IF sy-subrc = 0.
      APPEND ls_resb TO gt_mara.
    ENDIF.
    CLEAR ls_resb.
  ENDLOOP.

  SORT gt_mara BY matnr posnr.
  DELETE ADJACENT DUPLICATES FROM gt_mara COMPARING matnr.

  IF gt_mara[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_xmara
      FOR ALL ENTRIES IN gt_mara
      WHERE matnr = gt_mara-matnr.

    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN gt_mara
      WHERE matnr = gt_mara-matnr
        AND spras = sy-langu.
  ENDIF.

*  LOOP AT gt_mara INTO ls_mara.
*    CLEAR ls_resb.
*    READ TABLE gt_resb INTO ls_resb
*                       WITH KEY matnr = ls_mara-matnr
*                                kzear = 'X'.
*    IF sy-subrc <> 0.
*      DELETE TABLE gt_mara FROM ls_mara.
*    ENDIF.
*  ENDLOOP.
*
  DESCRIBE TABLE gt_mara LINES gv_lines.

  LOOP AT lt_xmara INTO ls_xmara.
    READ TABLE gt_ymara INTO ls_ymara
                        WITH KEY matnr = ls_xmara-matnr.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
    IF ls_xmara-mtart = 'ZPM'.
      CONTINUE.
    ENDIF.
    READ TABLE lt_makt INTO ls_makt
                       WITH KEY matnr = ls_xmara-matnr.
    IF sy-subrc = 0.
      ls_material-matnr = ls_xmara-matnr.
      ls_material-maktx = ls_makt-maktx.
      READ TABLE gt_mara INTO ls_mara
                         WITH KEY matnr = ls_xmara-matnr.
      IF sy-subrc = 0.
        IF ls_mara-bdmng IS NOT INITIAL.
          ADD 1 TO lv_rspos.
          ls_material-rspos = lv_rspos.
          APPEND ls_material TO gt_material.
        ENDIF.
      ENDIF.
      CLEAR ls_material.
    ENDIF.
  ENDLOOP.

  IF gt_material[] IS INITIAL.
    APPEND INITIAL LINE TO gt_material.
  ELSE.
    DESCRIBE TABLE gt_material LINES n8.

    IF gv_mara IS INITIAL.
      gv_mara = 1.
    ENDIF.

    IF fc_subrc IS INITIAL.
      IF gv_matnr IS NOT INITIAL.
        READ TABLE lt_xmara INTO ls_xmara
                           WITH KEY matnr = gv_matnr.
        IF sy-subrc <> 0.
          gs_head-message = 'Material tidak sesuai'.
          fc_subrc = 3.
        ELSE.
          READ TABLE gt_mara INTO ls_mara
                             WITH KEY matnr = gv_matnr.
          IF sy-subrc = 0.
            gs_head-matnr = ls_mara-matnr.
            gs_head-werks = ls_mara-werks.
            CLEAR gs_head-message.
            CALL SCREEN 502.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MATERIAL_BY_SYSTEM

*&---------------------------------------------------------------------*
*&      Form  F_NOSTOCK
*&---------------------------------------------------------------------*
FORM f_nostock .
  DATA : ls_resb    LIKE LINE OF gt_resb,
         ls_yresb   LIKE LINE OF gt_yresb.

  IF gt_yresb[] IS NOT INITIAL.
    CLEAR : gt_yresb[], gt_operation[].
  ENDIF.

  LOOP AT gt_resb INTO ls_resb WHERE matnr = gs_head-matnr.
    ls_yresb  = ls_resb.
    APPEND ls_yresb TO gt_yresb.
    CLEAR ls_yresb.
  ENDLOOP.

  CALL SCREEN 503.

ENDFORM.                    " F_NOSTOCK

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_ONLY_FULLPACK
*&---------------------------------------------------------------------*
FORM f_order_only_fullpack USING fu_flag.
  DATA : ls_order   LIKE LINE OF gt_order,
         ls_resb    LIKE LINE OF gt_resb,
         lt_xresb   TYPE STANDARD TABLE OF resb,
         ls_xresb   LIKE LINE OF lt_xresb,
         ls_mseg    LIKE LINE OF gt_mseg.

  lt_xresb[] = gt_resb[].
  DELETE lt_xresb WHERE kzear = 'X'.
  SORT lt_xresb BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING aufnr.
  IF lt_xresb[] IS NOT INITIAL.
    SELECT *
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg
      FOR ALL ENTRIES IN lt_xresb
      WHERE aufnr = lt_xresb-aufnr.
  ENDIF.

  IF fu_flag IS INITIAL.
    LOOP AT gt_order INTO ls_order.
      READ TABLE gt_resb INTO ls_resb
                         WITH KEY aufnr = ls_order-aufnr.
      IF ls_resb-kzear IS INITIAL.
        READ TABLE gt_mseg INTO ls_mseg
                           WITH KEY aufnr = ls_order-aufnr.
        IF sy-subrc <> 0.
          DELETE TABLE gt_order FROM ls_order.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT gt_resb INTO ls_resb.
    IF ls_resb-wempf IS NOT INITIAL OR
      ls_resb-kzear IS NOT INITIAL.
      DELETE TABLE gt_resb FROM ls_resb.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ORDER_ONLY_FULLPACK

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_nmein fu_meins fu_enmng fu_simple
                       CHANGING fc_bdmng.

  CASE fu_simple.
    WHEN 'X'.
      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input                = fu_enmng
          unit_in              = fu_nmein
          unit_out             = fu_meins
        IMPORTING
          output               = fc_bdmng
        EXCEPTIONS
          conversion_not_found = 1
          division_by_zero     = 2
          input_invalid        = 3
          output_invalid       = 4
          overflow             = 5
          type_invalid         = 6
          units_missing        = 7
          unit_in_not_found    = 8
          unit_out_not_found   = 9
          OTHERS               = 10.

    WHEN OTHERS.
      CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
        EXPORTING
          input                = fu_enmng
          matnr                = gs_head-matnr
          meinh                = fu_nmein
          meins                = fu_meins
        IMPORTING
          output               = fc_bdmng
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
  ENDCASE.
ENDFORM.                    " F_UOM_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_SELECTION
*&---------------------------------------------------------------------*
FORM f_material_selection .
  CLEAR : gs_head-cmatnr, gt_xresb[], gv_meins.

  SELECT SINGLE meins
    FROM mara
    INTO gv_meins
    WHERE matnr = gv_matnr.

  SELECT *
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE gt_xresb
    WHERE matnr = gv_matnr
      AND charg = gs_head-charg
*      AND wempf IN ('W', 'T')
      AND bwart = gv_261
      AND kzear = space
      AND xloek = space.

  DELETE gt_operation WHERE charg = space.
ENDFORM.                    " F_MATERIAL_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_MATNR
*&---------------------------------------------------------------------*
FORM f_delete_matnr  USING    fu_matnr.
  DATA : ls_ymara       LIKE LINE OF gt_ymara,
         ls_material    LIKE LINE OF gt_material,
         ls_resb        LIKE LINE OF gt_resb,
         lv_subrc       TYPE sy-subrc.

  ls_ymara-matnr = fu_matnr.
  APPEND ls_ymara TO gt_ymara.
  CLEAR ls_ymara.

  LOOP AT gt_material INTO ls_material.
    CLEAR ls_ymara.
    lv_subrc = 4.
    CLEAR ls_ymara.
    READ TABLE gt_ymara INTO ls_ymara
                        WITH KEY matnr = ls_material-matnr.
    IF sy-subrc <> 0.
      CLEAR lv_subrc.
    ELSE.
      LOOP AT gt_ymara INTO ls_ymara WHERE matnr = ls_material-matnr.
        CLEAR ls_resb.
        READ TABLE gt_resb INTO ls_resb
                           WITH KEY matnr = ls_ymara-matnr.
        IF sy-subrc = 0.
          CLEAR lv_subrc.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_subrc <> 0.
      DELETE gt_material WHERE matnr = ls_material-matnr.
    ENDIF.
  ENDLOOP.

  IF gt_material[] IS INITIAL.
    APPEND INITIAL LINE TO gt_material.
  ENDIF.
ENDFORM.                    " F_DELETE_MATNR

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_display_data  USING    fu_sign.
  DATA : lv_lines   TYPE i.

  CASE sy-dynnr.
    WHEN '0501'.
      DESCRIBE TABLE gt_order LINES lv_lines.
      PERFORM f_move_pages USING fu_sign lv_lines
                           CHANGING n1 c1.
    WHEN '0502'.
    WHEN '0503'.
    WHEN '0504'.
      DESCRIBE TABLE gt_material LINES lv_lines.
      PERFORM f_move_pages USING fu_sign lv_lines
                           CHANGING n7 c4.
  ENDCASE.

ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_PAGES
*&---------------------------------------------------------------------*
FORM f_move_pages  USING    fu_sign fu_lines
                   CHANGING fc_n fc_c.
  CASE fu_sign.
    WHEN '+'.
      IF fu_lines > 30.
        fc_n = fc_n + 30.
        IF fc_n > fu_lines.
          fc_n = fu_lines.
        ENDIF.
      ENDIF.
    WHEN '-'.
      fc_n = fc_n - 30.
      IF fc_n < 0.
        fc_n = 1.
      ENDIF.
      fc_c  = fc_c - 30.
  ENDCASE.
ENDFORM.                    " F_MOVE_PAGES

*&---------------------------------------------------------------------*
*&      Module  TAP_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
MODULE tap_display OUTPUT.

ENDMODULE.                 " TAP_DISPLAY  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_FULL_CALCULATE_NEW
*&---------------------------------------------------------------------*
FORM f_full_calculate_new  USING    fs_operation TYPE ty_operation.
  DATA : lv_div     TYPE i,
         lv_total   TYPE mchb-clabs,
         ls_temp    LIKE LINE OF gt_temp,
         lv_erfmg   TYPE resb-erfmg.

  gv_total = fs_operation-bdmng.

  IF fs_operation-clabs IS INITIAL.
    fs_operation-clabs  = gs_head-clabs.
    CLEAR : ls_temp, lv_erfmg.
    LOOP AT gt_temp INTO ls_temp WHERE charg = fs_operation-charg.
      ADD ls_temp-erfmg TO lv_erfmg.
    ENDLOOP.
    fs_operation-clabs = fs_operation-clabs - lv_erfmg.

    IF gv_total >= fs_operation-bdmng.
      IF fs_operation-clabs < fs_operation-bdmng.
        fs_operation-erfmg = fs_operation-clabs.
      ELSE.
        fs_operation-erfmg = fs_operation-bdmng.
      ENDIF.

      IF gv_duplicate IS INITIAL.
        IF fs_operation-matnr IS NOT INITIAL AND
          fs_operation-charg IS NOT INITIAL.
          CLEAR ls_temp.
          READ TABLE gt_temp INTO ls_temp
                             WITH KEY vornr = fs_operation-vornr
                                      charg = fs_operation-charg.
          IF sy-subrc = 0.
            IF ls_temp-erfmg <> fs_operation-erfmg.
              lv_erfmg      = ls_temp-erfmg.
              ls_temp       = fs_operation.
              ls_temp-erfmg = fs_operation-erfmg - lv_erfmg.
              APPEND ls_temp TO gt_temp.
            ENDIF.
          ELSE.
            APPEND fs_operation TO gt_temp.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF gv_total > 0.
        fs_operation-erfmg = gv_total.
        APPEND fs_operation TO gt_temp.
      ENDIF.
    ENDIF.

    gv_total  = gv_total - fs_operation-erfmg.

    IF fs_operation-matnr IS NOT INITIAL AND
      fs_operation-charg IS NOT INITIAL.
      gv_stock  = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_FULL_CALCULATE_NEW

*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_RESB
*&---------------------------------------------------------------------*
FORM f_refresh_resb USING fu_flag.
  DATA : lv_subrc   TYPE sy-subrc,
         ls_resb    LIKE LINE OF gt_resb,
         lv_flag.

  CLEAR : gt_resb[]. ", component[].

  DELETE component WHERE matnr = gv_matnr.

  IF gt_marc[] IS NOT INITIAL.
    lv_flag = 'X'.
  ENDIF.

  SELECT *
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE gt_resb
    FOR ALL ENTRIES IN gt_order
    WHERE aufnr = gt_order-aufnr
      AND xloek = space.

  PERFORM f_order_only_fullpack USING lv_flag.
  PERFORM f_get_operation USING fu_flag
                          CHANGING lv_subrc.

  CASE fu_flag.
    WHEN '3'.
      READ TABLE gt_resb INTO ls_resb
                         WITH KEY matnr = gv_matnr
                                  wempf = space.
      IF sy-subrc = 0.
        CLEAR gs_head-message.
      ENDIF.
    WHEN space.
      CLEAR : gs_head-bdmng, gt_batch[], gt_material[], gt_mara[].
      PERFORM f_material_by_system CHANGING lv_subrc.
  ENDCASE.
ENDFORM.                    " F_REFRESH_RESB

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRODSCHEDULER
*&---------------------------------------------------------------------*
FORM f_get_prodscheduler  TABLES   ft_fevor STRUCTURE range_fev
                          USING    fu_fevor.
  DATA : ls_fevor   TYPE range_fev.

  ls_fevor-low      = fu_fevor.
  ls_fevor-sign     = 'I'.
  ls_fevor-option   = 'EQ'.
  APPEND ls_fevor TO ft_fevor.
  CLEAR ls_fevor.
ENDFORM.                    " F_GET_PRODSCHEDULER
