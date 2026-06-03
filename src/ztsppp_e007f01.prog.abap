*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E007F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .

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
  CASE sy-dynnr.
    WHEN '0701'.
      PERFORM f_get_order.

      IF gt_operation[] IS INITIAL.
        APPEND INITIAL LINE TO gt_operation.
        PERFORM f_modify_screen USING : 'CMA' '0' '' '' '',
                                        'OPR' '0' '' '' '',
                                        'UP' '0' '' '' '',
                                        'DN' '0' '' '' '',
                                        'STS' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'CAU' '' '0' '' ''.
        IF gv_subrc <> 6.
          PERFORM f_modify_screen USING : 'STS' '0' '' '' ''.
        ENDIF.
      ENDIF.

      IF gv_complt = 'X'.
        PERFORM f_modify_screen USING : 'CMA' '' '0' '' ''.
      ENDIF.

      IF gs_head-caufnr IS INITIAL OR
        ( gv_subrc IS NOT INITIAL AND gv_complt IS INITIAL ).
        PERFORM f_modify_screen USING : 'PGI' '' '0' '' ''.
      ENDIF.

      DESCRIBE TABLE gt_operation LINES n2.

      CASE gv_subrc.
        WHEN 1.
          gs_head-message = 'Material tidak ada'.
        WHEN 2.
          gs_head-message = 'Material FG tidak sama'.
        WHEN 3.
          gs_head-message = 'Process Order berbeda'.
        WHEN 4.
          gs_head-message = 'PGI belum bisa dilakukan'.
        WHEN 5.
          gs_head-message = 'Quantity tidak sama'.
        WHEN 6.
          gs_head-message = 'Stock kurang'.
      ENDCASE.
      CLEAR gv_subrc.
  ENDCASE.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  n1 = 1.
  CASE sy-dynnr.
    WHEN '0701'.
      IF gs_head IS INITIAL.
        LEAVE TO SCREEN 0.
      ENDIF.
      CLEAR : gs_head, gt_operation[], gt_resb[].
    WHEN '0702'.
  ENDCASE.
ENDFORM.                    " F_CLEAR_DATA

*&---------------------------------------------------------------------*
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
    WHEN '0701'.
    WHEN '0702'.
  ENDCASE.
ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm        TYPE sy-ucomm,
         ls_operation    LIKE LINE OF gt_operation,
*         lv_menge       TYPE mseg-menge,
*         ls_mseg        LIKE LINE OF gt_mseg,
         lv_quantity(20),
         lv_meins(5),
         lv_erfmg        TYPE resb-erfmg,
         lv_total        TYPE resb-erfmg,
         lv_subrc        TYPE sy-subrc,
         lv_plnbez       TYPE resb-baugr,
         lv_aufnr        TYPE resb-aufnr.

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
*      PERFORM f_next_order.

    WHEN '&PGI'.
      PERFORM f_pgi_validasi.
      IF gv_subrc IS INITIAL.
        PERFORM f_prepare_data.
        PERFORM f_post_goods_issue.
      ELSE.
      ENDIF.

    WHEN '&PRINT'.
      IF gs_head-message IS INITIAL.
*        PERFORM f_prepare_data.
*        PERFORM f_unlock_table.
*        PERFORM f_print_form USING ''.
*        PERFORM f_update_resb USING 'W'.
*        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN '&PPGUP'.
      PERFORM f_display_data USING '-'.

    WHEN '&PPGDN'.
      PERFORM f_display_data USING '+'.

    WHEN OTHERS.
      IF gs_head-caufnr IS NOT INITIAL.
        IF gs_head-aufnr IS INITIAL.
          SPLIT gs_head-caufnr AT ';' INTO gs_head-plnbez gs_head-aufnr
                                           gs_head-fcharg gs_head-vornr.
        ENDIF.
        gs_head-caufnr = gs_head-aufnr.
        PERFORM f_conversion_alpha USING gs_head-aufnr
                                   CHANGING gs_head-aufnr.
      ENDIF.

      IF gs_head-cmatnr IS NOT INITIAL.
        CLEAR : gs_head-message.
        SPLIT gs_head-cmatnr AT ';' INTO lv_plnbez lv_aufnr
                                         gs_head-vornr gs_head-posnr
                                         gs_head-matnr lv_quantity.

        IF gs_head-plnbez <> lv_plnbez.
          gv_subrc = 2.
        ENDIF.

        PERFORM f_conversion_alpha USING lv_aufnr
                                   CHANGING lv_aufnr.

        IF gs_head-aufnr <> lv_aufnr.
          gv_subrc = 3.
        ENDIF.

        IF gv_subrc IS INITIAL.
          SPLIT lv_quantity AT space INTO lv_quantity lv_meins.
          TRANSLATE lv_quantity USING '. '.
          TRANSLATE lv_quantity USING ',.'.
          CONDENSE lv_quantity NO-GAPS.

          lv_erfmg = lv_quantity.

          CLEAR gs_head-cmatnr.
*          LOOP AT gt_mseg INTO ls_mseg WHERE matnr = gs_head-matnr.
*            ADD ls_mseg-menge TO lv_menge.
*          ENDLOOP.

          LOOP AT gt_operation INTO ls_operation WHERE vornr = gs_head-vornr
                                                   AND matnr = gs_head-matnr
                                                   AND posnr = gs_head-posnr.
*                                                 AND erfmg = lv_erfmg.
            ls_operation-check = 'X'.
            MODIFY gt_operation FROM ls_operation TRANSPORTING check.
            PERFORM f_update_resb USING ls_operation-rsnum ls_operation-rspos 'T'.
            ADD ls_operation-erfmg TO lv_total.
          ENDLOOP.
          IF sy-subrc <> 0.
            gv_subrc = 1.
          ELSE.
            IF sy-uname = 'PPIFA' OR sy-uname = 'PPMRA'.
              IF lv_total <> lv_erfmg.
                gv_subrc = 5.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_TABLE
*&---------------------------------------------------------------------*
FORM f_generate_table .
  DATA : ls_xresb LIKE LINE OF gt_xresb,
         lv_bdmng TYPE resb-bdmng.

  idx = sy-stepl + line.

  CASE sy-dynnr.
    WHEN '0701'.
    WHEN '0702'.
  ENDCASE.
ENDFORM.                    " F_GENERATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table .
  DATA : lv_line        TYPE i.

  GET CURSOR LINE lv_line.

  CASE sy-dynnr.
    WHEN '0701'.
    WHEN '0702'.
  ENDCASE.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER
*&---------------------------------------------------------------------*
FORM f_get_order .
  DATA : ls_operation LIKE LINE OF gt_operation,
         ls_resb      LIKE LINE OF gt_resb,
         lv_aufnr     TYPE resb-aufnr,
         lv_sfg       TYPE flag,
         lv_oth       TYPE flag,
         lt_mara      TYPE STANDARD TABLE OF mara,
         ls_mara      LIKE LINE OF lt_mara,
         lt_resb      TYPE STANDARD TABLE OF resb.

  IF gs_head-aufnr IS NOT INITIAL AND
    gs_head-vornr IS NOT INITIAL.
    IF gs_head-plnbez IS NOT INITIAL.
      SELECT SINGLE maktx
        FROM makt
        INTO gs_head-maktx
        WHERE matnr = gs_head-plnbez
          AND spras = sy-langu.
    ENDIF.

    IF gt_resb[] IS INITIAL.
      SELECT *
        FROM resb
        INTO CORRESPONDING FIELDS OF TABLE gt_resb
        WHERE aufnr = gs_head-aufnr
          AND vornr = gs_head-vornr
*          AND charg <> space
          AND vmeng <> 0
          AND kzear = space.

      IF sy-subrc = 0.
        CLEAR : gt_operation[], gv_werks.
        LOOP AT gt_resb INTO ls_resb.
*          IF ls_resb-charg IS INITIAL.
*            CONTINUE.
*          ENDIF.
          IF ls_resb-wempf = 'T'.
            ls_operation-check  = 'X'.
          ENDIF.
          ls_operation-vornr  = ls_resb-vornr.
          ls_operation-matnr  = ls_resb-matnr.
          ls_operation-charg  = ls_resb-charg.
          ls_operation-werks  = ls_resb-werks.
          ls_operation-lgort  = ls_resb-lgort.
          ls_operation-rsnum  = ls_resb-rsnum.
          ls_operation-rspos  = ls_resb-rspos.
          ls_operation-erfmg  = ls_resb-erfmg.
          ls_operation-meins  = ls_resb-erfme.
          ls_operation-posnr  = ls_resb-posnr.
          ls_operation-splrv  = ls_resb-splrv.
          APPEND ls_operation TO gt_operation.
          CLEAR ls_operation.
        ENDLOOP.
      ENDIF.

      lt_resb[] = gt_resb[].
      SORT lt_resb BY matnr werks.
      DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr werks.
      IF lt_resb[] IS NOT INITIAL.
        SELECT *
          FROM ztnpppdt002
          INTO CORRESPONDING FIELDS OF TABLE gt_002
          FOR ALL ENTRIES IN lt_resb
          WHERE matnr  = lt_resb-matnr
            AND werks  = lt_resb-werks.
      ENDIF.

*      lt_resb[] = gt_resb[].
*      SORT lt_resb BY matnr charg lgort.
*      DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr charg lgort.
*      IF lt_resb[] IS NOT INITIAL.
*        SELECT *
*          FROM mchb
*          INTO CORRESPONDING FIELDS OF TABLE gt_mchb
*          FOR ALL ENTRIES IN lt_resb
*          WHERE matnr = lt_resb-matnr
*            AND charg = lt_resb-charg
*            AND lgort = lt_resb-lgort.
*      ENDIF.
*      PERFORM f_conversion_alpha USING gs_head-aufnr
*                                 CHANGING lv_aufnr.
*      SELECT *
*        FROM mseg
*        INTO CORRESPONDING FIELDS OF TABLE gt_mseg
*        WHERE aufnr = lv_aufnr.
    ENDIF.


    READ TABLE gt_operation WITH KEY check = ' '
                            TRANSPORTING NO FIELDS.
    IF sy-subrc = 0 AND gv_subrc IS INITIAL.
      gv_subrc = 4.
      CLEAR gv_complt.
    ELSEIF sy-subrc IS NOT INITIAL.
      gv_complt = 'X'.
    ENDIF.

    " Untuk Plant 0102
    " Jika tersisa material ZSFG, boleh PGI
    READ TABLE gt_resb INTO ls_resb INDEX 1.
    IF gv_subrc = 4 AND ls_resb-werks = '0102'.

      SELECT matnr mtart
        INTO CORRESPONDING FIELDS OF TABLE lt_mara
        FROM mara FOR ALL ENTRIES IN gt_operation
        WHERE matnr = gt_operation-matnr.

      LOOP AT gt_operation INTO ls_operation
                           WHERE check = ' '.
        CLEAR ls_mara.
        READ TABLE lt_mara INTO ls_mara
                           WITH KEY matnr = ls_operation-matnr.

        CASE ls_mara-mtart.
          WHEN 'ZSFG'.
            lv_sfg = 'X'.
          WHEN OTHERS.
            lv_oth = 'X'.
        ENDCASE.
      ENDLOOP.

      IF lv_sfg = 'X' AND lv_oth = ' '.
        CLEAR gv_subrc.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING   fu_type fu_msgv1 fu_msgv2 fu_msgv3 fu_msgv4.
  gs_head-message = fu_msgv1.
ENDFORM.                    " F_ERROR_MESSAGE

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
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table .
  CALL FUNCTION 'DEQUEUE_ALL'.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : ls_operation LIKE LINE OF gt_operation,
         ls_002       LIKE LINE OF gt_002,
         ls_item      TYPE bapi2017_gm_item_create,
         lt_label     TYPE STANDARD TABLE OF ztspppst004,
         ls_label     TYPE ztspppst004,
         lv_count     TYPE i,
         lv_erfmg(20),
         lv_total(20).

  PERFORM f_pre_update_tbl_dumping.

  CLEAR : goodsmvt_header, goodsmvt_item[].

  PERFORM f_conversion_alpha USING gs_head-aufnr
                             CHANGING gs_head-aufnr.

  goodsmvt_header-pstng_date        = sy-datum.
  goodsmvt_header-doc_date          = sy-datum.
  goodsmvt_header-header_txt        = gs_head-aufnr.
  goodsmvt_header-ver_gr_gi_slip    = '1'.
  goodsmvt_header-ver_gr_gi_slipx   = 'X'.

  LOOP AT gt_operation INTO ls_operation WHERE check = 'X'.
    IF ls_operation-erfmg IS INITIAL.
      CONTINUE.
    ENDIF.
    ls_item-material             = ls_operation-matnr.
    ls_item-plant                = ls_operation-werks.
    ls_item-stge_loc             = ls_operation-lgort.
    ls_item-batch                = ls_operation-charg.
    ls_item-entry_uom            = ls_operation-meins.
    ls_item-orderid              = gs_head-aufnr.
    ls_item-reserv_no            = ls_operation-rsnum.
    ls_item-res_item             = ls_operation-rspos.
    ls_item-move_type            = '261'.
    ls_item-entry_qnt            = ls_operation-erfmg.
*    CLEAR ls_002.
*    READ TABLE gt_002 INTO ls_002
*                      WITH KEY matnr = ls_operation-matnr
*                               werks = ls_operation-werks.
*    IF sy-subrc = 0.
*      IF ls_002-factor IS NOT INITIAL.
*        ls_item-withdrawn            = 'X'.
*      ENDIF.
*    ENDIF.

    APPEND ls_item TO goodsmvt_item.
    CLEAR ls_item.

    DELETE TABLE gt_operation FROM ls_operation.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_POST_GOODS_ISSUE
*&---------------------------------------------------------------------*
FORM f_post_goods_issue .
  DATA : lv_mblnr  TYPE mseg-mblnr,
         lv_mjahr  TYPE mseg-mjahr,
         return    TYPE STANDARD TABLE OF bapiret2,
         ls_return TYPE bapiret2.

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

    CONCATENATE 'Document' lv_mblnr 'created' INTO gs_head-message
    SEPARATED BY space.

*    PERFORM f_final_issue_factorisasi.
    CLEAR : component[].

    PERFORM f_update_table_dmp.
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
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_display_data  USING    fu_sign.
  DATA : lv_lines   TYPE i.

  DESCRIBE TABLE gt_operation LINES lv_lines.
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
      c  = c - 30.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_RESB
*&---------------------------------------------------------------------*
FORM f_update_resb  USING    fu_rsnum fu_rspos fu_wempf.
  TRY .
      UPDATE resb SET wempf = fu_wempf
                  WHERE rsnum = fu_rsnum
                    AND rspos = fu_rspos.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
ENDFORM.                    " F_UPDATE_RESB

*&---------------------------------------------------------------------*
*&      Form  F_PGI_VALIDASI
*&---------------------------------------------------------------------*
FORM f_pgi_validasi .
  DATA : lt_resb      TYPE STANDARD TABLE OF resb,
         ls_resb      TYPE resb,
         lt_xresb     TYPE STANDARD TABLE OF resb,
         ls_xresb     TYPE resb,
         ls_mchb      LIKE LINE OF gt_mchb,
         ls_operation LIKE LINE OF gt_operation.

  PERFORM f_conversion_alpha USING gs_head-aufnr
                             CHANGING gs_head-aufnr.

  SELECT *
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE lt_resb
    WHERE aufnr = gs_head-aufnr
      AND vornr = gs_head-vornr
      AND xloek = space.
*      AND splkz = '2'.

  LOOP AT lt_resb INTO ls_resb.
    IF ls_resb-werks = '0102'.
      IF ls_resb-splkz <> '2'.
        DELETE TABLE lt_resb FROM ls_resb.
      ENDIF.
    ELSEIF ls_resb-werks = '0101'.
      IF ls_resb-charg IS INITIAL AND
        ls_resb-nomng = 0.
        DELETE TABLE lt_resb FROM ls_resb.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DELETE lt_resb WHERE wempf <> 'T'.

  lt_xresb[] = lt_resb[].
  SORT lt_xresb BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING matnr.

  LOOP AT lt_xresb INTO ls_xresb.
    IF ls_xresb-bdmng = 0.
      CONTINUE.
    ENDIF.
    CLEAR ls_resb.
    READ TABLE lt_resb INTO ls_resb
                       WITH KEY matnr = ls_xresb-matnr.
    IF sy-subrc <> 0.
      gv_subrc = 4.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PGI_VALIDASI

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_ALPHA
*&---------------------------------------------------------------------*
FORM f_conversion_alpha  USING    fu_aufnr
                         CHANGING fc_aufnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_aufnr
    IMPORTING
      output = fc_aufnr.
ENDFORM.                    " F_CONVERSION_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_FINAL_ISSUE_FACTORISASI
*&---------------------------------------------------------------------*
FORM f_final_issue_factorisasi .
  DATA : ls_item LIKE LINE OF goodsmvt_item,
         ls_002  LIKE LINE OF gt_002.

  LOOP AT goodsmvt_item INTO ls_item.
    CLEAR ls_002.
    READ TABLE gt_002 INTO ls_002
                      WITH KEY matnr = ls_item-material
                               werks = ls_item-plant.
    IF sy-subrc = 0.
      IF ls_002-factor IS NOT INITIAL.
        TRY .
            UPDATE resb SET kzear = 'X'
                        WHERE rsnum = ls_item-reserv_no
                          AND matnr = ls_item-material.
          CATCH cx_sy_open_sql_db.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FINAL_ISSUE_FACTORISASI

*&---------------------------------------------------------------------*
*&      Form  F_PRE_UPDATE_TBL_DUMPING
*&---------------------------------------------------------------------*
FORM f_pre_update_tbl_dumping .
  DATA: lv1(2),lv2(2),lv3(3),lv4(2),lv5(3).

  CLEAR gt_ztspppdt012.

  READ TABLE gt_operation INTO DATA(ls_operation) INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE * INTO @DATA(ls_resb)
      FROM resb WHERE rsnum = @ls_operation-rsnum
                  AND rspos = @ls_operation-rspos.
    IF sy-subrc = 0.
      SELECT SINGLE phseq INTO @DATA(lv_phseq)
        FROM afvc WHERE aufpl = @ls_resb-aufpl
                    AND aplzl = @ls_resb-aplzl.
      IF sy-subrc = 0.
        lv1 = lv2 = lv3 = lv4 = lv5 = lv_phseq.
        lv1(1) = 'D'.
        lv2(1) = 'E'.
        lv3(1) = 'G'.
        lv4(1) = 'L'.
        lv5(1) = 'O'.
      ENDIF.

      SELECT rsnum, rspos, rsart, aufnr, vornr, aufpl, aplzl, sortf, wempf
        INTO TABLE @DATA(lt_resb)
        FROM resb FOR ALL ENTRIES IN @gt_operation
        WHERE rsnum = @gt_operation-rsnum
          AND rspos = @gt_operation-rspos.

      READ TABLE lt_resb WITH KEY sortf = 'D'
                         TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.
        SELECT * INTO TABLE @DATA(lt_afvc)
          FROM afvc WHERE aufpl = @ls_resb-aufpl
                      AND phseq IN (@lv1,@lv2,@lv3,@lv4,@lv5)
                      AND steus = 'ZP01'.
      ELSE.
        SELECT * INTO TABLE lt_afvc
          FROM afvc WHERE aufpl = ls_resb-aufpl
                      AND phseq IN (lv1,lv3,lv4,lv5)
                      AND steus = 'ZP01'.
      ENDIF.

      IF sy-subrc = 0.
        SELECT * INTO TABLE @DATA(lt_ztspppdt012)
          FROM ztspppdt012 FOR ALL ENTRIES IN @lt_afvc
          WHERE aufpl = @lt_afvc-aufpl
            AND aplzl = @lt_afvc-aplzl
            AND stats = '0010'
            AND vornr = @lt_afvc-vornr
            AND actwh = @ls_resb-vornr.

        LOOP AT lt_afvc INTO DATA(ls_afvc).
          READ TABLE lt_ztspppdt012 INTO DATA(ls_ztspppdt012)
                                    WITH KEY aufpl = ls_afvc-aufpl
                                             aplzl = ls_afvc-aplzl
                                             stats = '0010'
                                             vornr = ls_afvc-vornr
                                             actwh = ls_resb-vornr.

          IF sy-subrc = 0.
            APPEND INITIAL LINE TO gt_ztspppdt012 ASSIGNING FIELD-SYMBOL(<fs_ztspppdt012>).
            MOVE-CORRESPONDING ls_ztspppdt012 TO <fs_ztspppdt012>.
            <fs_ztspppdt012>-datef = sy-datum.
            <fs_ztspppdt012>-timef = sy-uzeit.
          ELSE.
            APPEND INITIAL LINE TO gt_ztspppdt012 ASSIGNING <fs_ztspppdt012>.
            <fs_ztspppdt012>-aufpl = ls_afvc-aufpl.
            <fs_ztspppdt012>-aplzl = ls_afvc-aplzl.
            <fs_ztspppdt012>-stats = '0010'.
            <fs_ztspppdt012>-vornr = ls_afvc-vornr.
            <fs_ztspppdt012>-actwh = ls_resb-vornr.
            <fs_ztspppdt012>-aufnr = ls_resb-aufnr.
*          <fs_ztspppdt012>-werks = ls_resb-werks.
*          <fs_ztspppdt012>-ltxa1 = ls_afvc-ltxa1.
            <fs_ztspppdt012>-rooms = 'Post Weighing'.
            <fs_ztspppdt012>-dates = sy-datum.
            <fs_ztspppdt012>-times = sy-uzeit.
            <fs_ztspppdt012>-datef = sy-datum.
            <fs_ztspppdt012>-timef = sy-uzeit.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TABLE_DMP
*&---------------------------------------------------------------------*
FORM f_update_table_dmp .
  IF gt_ztspppdt012[] IS NOT INITIAL.
    MODIFY ztspppdt012 FROM TABLE gt_ztspppdt012.
    COMMIT WORK AND WAIT.
  ENDIF.
  CLEAR gt_ztspppdt012.
ENDFORM.
