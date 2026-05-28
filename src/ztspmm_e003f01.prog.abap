*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
    FROM ztspmmdt007
    INTO CORRESPONDING FIELDS OF TABLE gt_007.
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
  DATA : ls_detl    LIKE LINE OF gt_detl.

  IF gs_head-charg IS NOT INITIAL.
    PERFORM f_validate_data USING '3'.
    IF gv_subrc IS NOT INITIAL.
      PERFORM f_error_message.
      CLEAR : gs_head-charg, gs_head-matnr, gs_head-maktx.
    ENDIF.
  ENDIF.

*  IF gs_head-pidres IS NOT INITIAL.
*    PERFORM f_validate_data USING '4'.
*    IF gv_subrc IS NOT INITIAL.
*      PERFORM f_error_message.
*      CLEAR : gs_head-charg, gs_head-matnr, gs_head-maktx.
*    ENDIF.
*  ENDIF.

  IF gs_head-werks IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-WERKS' ''.
  ELSEIF gs_head-lgort IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-LGORT' ''.
  ELSEIF gs_head-stktyp IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-STKTYP' ''.
  ELSEIF gs_head-padest IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-PADEST' ''.
  ELSEIF gs_head-maktx IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-CMATNR' ''.
  ELSEIF gs_head-charg IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-CHARG' ''.
  ELSEIF gs_head-menge IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-MENGE' ''.
  ELSEIF gs_head-pidres IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-PIDRES' ''.
  ELSE.
    PERFORM f_cursor_position USING 'GS_HEAD-COPY' ''.
  ENDIF.

  IF gs_head-werks IS NOT INITIAL AND
    gs_head-lgort IS NOT INITIAL AND
    gs_head-stktypt IS NOT INITIAL AND
    gs_head-padest IS NOT INITIAL.
    IF gs_head-werks IS NOT INITIAL.
      PERFORM f_modify_screen USING : 'WER' '' '0' '' ''.
    ENDIF.
    IF gs_head-lgort IS NOT INITIAL.
      PERFORM f_modify_screen USING : 'LGO' '' '0' '' ''.
    ENDIF.
    IF gs_head-stktypt IS NOT INITIAL.
      PERFORM f_modify_screen USING : 'STP' '' '0' '' ''.
    ENDIF.
    IF gs_head-padest IS NOT INITIAL.
      PERFORM f_modify_screen USING : 'PDE' '' '0' '' ''.
    ENDIF.

    IF gs_head-maktx IS INITIAL.
      PERFORM f_modify_screen USING : 'CHA' '0' '' '' '',
                                      'CFM' '0' '' '' '',
                                      'HED' '0' '' '' '',
                                      'TSP' '0' '' '' ''.
    ELSE.
      IF gs_head-charg IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'CHA' '' '0' '' ''.
      ENDIF.
      IF gv_tsp IS INITIAL.
        PERFORM f_modify_screen USING : 'TSP' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'TSP' '1' '' '' ''.
      ENDIF.
    ENDIF.

    IF gt_detl[] IS NOT INITIAL.
      CLEAR ls_detl.
      READ TABLE gt_detl INTO ls_detl INDEX 1.
      IF ls_detl IS INITIAL.
        PERFORM f_modify_screen USING : 'SAV' '0' '' '' '',
                                        'DET' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'BCK' '' '0' '' ''.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM f_modify_screen USING : 'CHA' '0' '' '' '',
                                    'CFM' '0' '' '' '',
                                    'SAV' '0' '' '' '',
                                    'SCN' '0' '' '' '',
                                    'HED' '0' '' '' '',
                                    'TSP' '0' '' '' '',
                                    'DET' '0' '' '' ''.
  ENDIF.

  IF gv_tsp IS INITIAL.
    PERFORM f_modify_screen USING : 'STP' '0' '' '' ''.
    PERFORM f_modify_screen USING : 'PDE' '0' '' '' ''.
  ELSE.
    PERFORM f_modify_screen USING : 'STP' '1' '' '' ''.
    PERFORM f_modify_screen USING : 'PDE' '1' '' '' ''.
  ENDIF.

  IF gt_detl[] IS INITIAL.
    APPEND INITIAL LINE TO gt_detl.
  ELSE.
    LOOP AT gt_detl INTO ls_detl.
      IF ls_detl IS NOT INITIAL.
        ADD 1 TO gv_zeile.
        ls_detl-ivpos = gv_zeile.
        MODIFY gt_detl FROM ls_detl
                       TRANSPORTING ivpos.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE gt_detl LINES n2.
  CLEAR gv_zeile.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_AFTER_INPUT
*&---------------------------------------------------------------------*
FORM f_process_after_input .
  IF gs_head-werks = '0101' OR gs_head-werks = '0102'.
    gv_tsp = 'X'.
  ELSE.
    CLEAR gv_tsp.
    gs_head-stktyp = 1.
    gs_head-padest = 1.
  ENDIF.
ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_matnr TYPE mseg-matnr,
         lv_charg TYPE mseg-charg.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'NEXT'.
      IF gs_head-stktyp IS NOT INITIAL.
        PERFORM f_get_stock_type.
      ENDIF.

      IF gs_head-cmatnr IS NOT INITIAL.
        gv_new  = 'X'.
      ENDIF.
      IF gv_new IS NOT INITIAL.
        SPLIT gs_head-cmatnr AT ';' INTO lv_matnr lv_charg.
        CLEAR gs_head-cmatnr.

        IF gs_head-matnr IS INITIAL.
          gs_head-matnr = lv_matnr.
        ENDIF.
        IF gs_head-charg IS INITIAL.
          gs_head-charg = lv_charg.
        ENDIF.

        PERFORM f_get_material.
        PERFORM f_error_message.
      ELSE.
        PERFORM f_modify_qty.
      ENDIF.

    WHEN 'CONFIRM'.
      PERFORM f_cetak_form.
      PERFORM f_validate_data USING '5'.
      IF gv_subrc IS INITIAL.
        PERFORM f_validate_data USING '2'.
        IF gv_subrc IS INITIAL.
          PERFORM f_confirm_data USING ''.
        ELSE.
          PERFORM f_error_message.
        ENDIF.
      ELSE.
        PERFORM f_error_message.
      ENDIF.

    WHEN 'DELETE'.
      PERFORM f_delete_data.

    WHEN 'SAVE'.
      PERFORM f_prepare_save.
      PERFORM f_save_data.
      PERFORM f_send_mail.
      PERFORM f_clear_data USING 'X'.
      LEAVE TO SCREEN 0.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'PPGUP'.
      PERFORM f_updown USING '-'.

    WHEN 'PPGDN'.
      PERFORM f_updown USING '+'.

    WHEN 'ZERO'.
      PERFORM f_confirm_data USING 'X'.

  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND102
*&---------------------------------------------------------------------*
FORM f_user_command102 .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_matnr TYPE mseg-matnr,
         lv_charg TYPE mseg-charg.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'PRINT'.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_GENERATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_TABLE
*&---------------------------------------------------------------------*
FORM f_generate_table .
  idx = sy-stepl + line.

  READ TABLE gt_detl INTO gs_detl INDEX idx.
ENDFORM.                    " F_GENERATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table .

ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
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

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
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
*&      Form  F_GET_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_material .
  IF gs_head-matnr IS NOT INITIAL.
    SELECT *
      FROM mchb
      APPENDING CORRESPONDING FIELDS OF TABLE gt_mchb
      WHERE matnr = gs_head-matnr
        AND werks = gs_head-werks
        AND lgort = gs_head-lgort.

    IF sy-subrc = 0.
      SELECT SINGLE meins
        FROM mara
        INTO gs_head-meins
        WHERE matnr = gs_head-matnr.

      SELECT SINGLE maktx
        FROM makt
        INTO gs_head-maktx
        WHERE matnr = gs_head-matnr
          AND spras = sy-langu.

      PERFORM f_get_actual_stock.
    ELSE.
      gv_subrc  = '1'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRM_DATA
*&---------------------------------------------------------------------*
FORM f_confirm_data USING fu_kznul.
  DATA : ls_detl LIKE LINE OF gt_detl,
         ls_mchb LIKE LINE OF gt_mchb.

  IF gv_new IS NOT INITIAL.
    PERFORM f_new_record USING fu_kznul.
  ELSEIF gv_xeile IS INITIAL.
    PERFORM f_new_record USING fu_kznul.
  ELSE.
    READ TABLE gt_detl INTO ls_detl
                       WITH KEY ivpos = gv_xeile.
    IF sy-subrc = 0.
      IF fu_kznul IS NOT INITIAL.
        ls_detl-menge = 0.
      ELSE.
        ls_detl-menge = gs_head-menge.
      ENDIF.
      ls_detl-kznul   = fu_kznul.
      ls_detl-pidres  = gs_head-pidres.
      ls_detl-copy    = gs_head-copy.
      MODIFY gt_detl FROM ls_detl
                     TRANSPORTING menge kznul pidres copy
                     WHERE ivpos = gv_xeile.
    ELSE.
      gs_detl-matnr   = gs_head-matnr.
      gs_detl-charg   = gs_head-charg.
      gs_detl-meins   = gs_head-meins.
      gs_detl-pidres  = gs_head-pidres.
      gs_detl-copy    = gs_head-copy.

      CLEAR ls_mchb.
      READ TABLE gt_mchb INTO ls_mchb
                         WITH KEY matnr = gs_head-matnr
                                  werks = gs_head-werks
                                  lgort = gs_head-lgort
                                  charg = gs_head-charg.
      IF sy-subrc = 0.
        CASE gs_head-stktypt.
          WHEN 'UU'.
            gs_detl-labst = ls_mchb-clabs.
          WHEN 'QI'.
            gs_detl-cinsm = ls_mchb-cinsm.
          WHEN 'BLOCKED'.
            gs_detl-cspem = ls_mchb-cspem.
        ENDCASE.
      ENDIF.

      IF fu_kznul IS NOT INITIAL.
        gs_detl-menge = 0.
      ELSE.
        gs_detl-menge = gs_head-menge.
      ENDIF.
      gs_detl-kznul = fu_kznul.
*      APPEND gs_detl TO gt_detl.
      COLLECT gs_detl INTO gt_detl.
    ENDIF.
  ENDIF.

  CLEAR gs_detl.

  LOOP AT gt_detl INTO ls_detl.
    IF ls_detl IS INITIAL.
      DELETE TABLE gt_detl FROM ls_detl.
    ENDIF.
  ENDLOOP.

  PERFORM f_block_stock USING 'X' gs_head-matnr gs_head-werks
                              gs_head-lgort gs_head-charg.

  CLEAR : gs_head-matnr, gs_head-charg, gs_head-meins,
          gs_head-menge, gs_head-maktx, gs_head-pidres,
          gs_head-actqty, gs_head-pidtxt, gs_head-copy, gv_new.
ENDFORM.                    " F_CONFIRM_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message .
  IF gv_subrc IS NOT INITIAL.
    CASE gv_subrc.
      WHEN '1'.
        message1 = 'Material tidak ada'.
      WHEN '2'.
        message1 = 'Avaiable Qty kosong'.
      WHEN '3'.
        message1 = 'Batch tidak ada'.
      WHEN '4'.
        message1 = 'Reason belum'.
        message2 = 'dimaintain'.
      WHEN '5'.
        message1 = 'Reason harus'.
        message2 = 'diisi'.
      WHEN '6'.
        message1 = 'Qty Reservasi '.
        message2 = 'lebih besar dari'.
        message3 = 'Act.Quantity'.
    ENDCASE.
    CLEAR gv_subrc.
    CALL SCREEN 2999.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_QTY
*&---------------------------------------------------------------------*
FORM f_modify_qty .
  DATA : ls_detl    LIKE LINE OF gt_detl.

  IF gs_head-ivpos IS NOT INITIAL.
    gv_xeile  = gs_head-ivpos.
    CLEAR gs_head-ivpos.

    READ TABLE gt_detl INTO ls_detl
                       WITH KEY ivpos = gv_xeile.
    IF sy-subrc = 0.
      gs_head-matnr   = ls_detl-matnr.
      gs_head-charg   = ls_detl-charg.
      gs_head-meins   = ls_detl-meins.
      gs_head-menge   = ls_detl-menge.
      gs_head-pidres  = ls_detl-pidres.

      SELECT SINGLE maktx
        FROM makt
        INTO gs_head-maktx
        WHERE matnr = gs_head-matnr
          AND spras = sy-langu.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_QTY

*&---------------------------------------------------------------------*
*&      Form  F_NEW_RECORD
*&---------------------------------------------------------------------*
FORM f_new_record USING fu_kznul.
  DATA : ls_detl LIKE LINE OF gt_detl,
         ls_mchb LIKE LINE OF gt_mchb.

*  READ TABLE gt_detl INTO ls_detl
*                     WITH KEY matnr = gs_head-matnr
*                              charg = gs_head-charg.
*  IF sy-subrc = 0.
*    ls_detl-kznul = fu_kznul.
*    IF fu_kznul IS NOT INITIAL.
*      ls_detl-menge = 0.
*    ENDIF.
*    MODIFY gt_detl FROM ls_detl
*                   TRANSPORTING kznul menge
*                   WHERE matnr = gs_head-matnr
*                     AND charg = gs_head-charg.
*  ENDIF.

  gs_detl-matnr   = gs_head-matnr.
  gs_detl-charg   = gs_head-charg.
  gs_detl-meins   = gs_head-meins.
  gs_detl-pidres  = gs_head-pidres.
  gs_detl-copy    = gs_head-copy.

  CLEAR ls_mchb.
  READ TABLE gt_mchb INTO ls_mchb
                     WITH KEY matnr = gs_head-matnr
                              werks = gs_head-werks
                              lgort = gs_head-lgort
                              charg = gs_head-charg.
  IF sy-subrc = 0.
    CASE gs_head-stktypt.
      WHEN 'UU'.
        gs_detl-labst = ls_mchb-clabs.
      WHEN 'QI'.
        gs_detl-cinsm = ls_mchb-cinsm.
      WHEN 'BLOCKED'.
        gs_detl-cspem = ls_mchb-cspem.
    ENDCASE.
  ENDIF.

  IF fu_kznul IS NOT INITIAL.
    gs_detl-menge = 0.
  ELSE.
    gs_detl-menge = gs_head-menge.
  ENDIF.
  gs_detl-kznul = fu_kznul.
*  APPEND gs_detl TO gt_detl.
  COLLECT gs_detl INTO gt_detl.
ENDFORM.                    " F_NEW_RECORD

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE
*&---------------------------------------------------------------------*
FORM f_prepare_save .
  DATA : ls_detl  LIKE LINE OF gt_detl,
         ls_006   LIKE LINE OF gt_006,
         lv_ivnum TYPE lqua-ivnum,
         lv_ivpos TYPE lqua-ivpos.

  PERFORM f_get_number CHANGING lv_ivnum.

  LOOP AT gt_detl INTO ls_detl.
    IF ls_detl-loekz IS NOT INITIAL.
      CONTINUE.
    ENDIF.
    ADD 1 TO lv_ivpos.
    ls_006-werks    = gs_head-werks.
    ls_006-lgort    = gs_head-lgort.
    ls_006-ivnum    = lv_ivnum.
    ls_006-ivpos    = lv_ivpos.   "ls_detl-ivpos.
    ls_006-matnr    = ls_detl-matnr.
    ls_006-charg    = ls_detl-charg.
    ls_006-meins    = ls_detl-meins.
    ls_006-labst    = ls_detl-labst.
    ls_006-cinsm    = ls_detl-cinsm.
    ls_006-cspem    = ls_detl-cspem.
    ls_006-kznul    = ls_detl-kznul.
    ls_006-pidres   = ls_detl-pidres.
    ls_006-menge    = ls_detl-menge.
    ls_006-qdatu    = sy-datum.
    ls_006-qzeit    = sy-uzeit.
    ls_006-qname    = sy-uname.
    ls_006-stktyp   = gs_head-stktyp.
    APPEND ls_006 TO gt_006.
    CLEAR ls_006.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_SAVE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  TRY .
      INSERT ztspmmdt006 FROM TABLE gt_006.
    CATCH cx_sy_open_sql_db.
  ENDTRY.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UPDOWN
*&---------------------------------------------------------------------*
FORM f_updown  USING    fu_sign.
  DATA : lv_total   TYPE i.
  CASE fu_sign.
    WHEN '+'.
      ADD 1 TO line.
      lv_total  = line + 10.
      IF lv_total > n2.
        line = line - 1.
      ENDIF.
    WHEN '-'.
      line = line - 1.
      IF line < 1.
        line  = 0.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_UPDOWN

*&---------------------------------------------------------------------*
*&      Form  F_BLOCK_STOCK
*&---------------------------------------------------------------------*
FORM f_block_stock  USING    fu_kzics fu_matnr fu_werks fu_lgort fu_charg.
  UPDATE mchb SET kzics = fu_kzics
              WHERE matnr = fu_matnr
                AND werks = fu_werks
                AND lgort = fu_lgort
                AND charg = fu_charg.
ENDFORM.                    " F_BLOCK_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data  USING    fu_kzils.
  DATA : ls_detl    LIKE LINE OF gt_detl.

  IF fu_kzils IS NOT INITIAL.
    LOOP AT gt_detl INTO ls_detl.
      PERFORM f_block_stock USING '' ls_detl-matnr gs_head-werks
                                  gs_head-lgort ls_detl-charg.
      CLEAR ls_detl.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data USING fu_subrc.
  DATA : ls_mchb LIKE LINE OF gt_mchb,
         ls_007  LIKE LINE OF gt_007.

  CASE fu_subrc.
    WHEN '2'.
      IF gs_head-menge IS INITIAL.
        gv_subrc = '2'.
      ENDIF.
    WHEN '3'.
      CLEAR ls_mchb.
      READ TABLE gt_mchb INTO ls_mchb
                         WITH KEY matnr = gs_head-matnr
                                  werks = gs_head-werks
                                  lgort = gs_head-lgort
                                  charg = gs_head-charg.
      IF sy-subrc <> 0.
        gv_subrc = '3'.
      ENDIF.
    WHEN '4'.
      CLEAR ls_007.
      READ TABLE gt_007 INTO ls_007
                         WITH KEY werks  = gs_head-werks
                                  pidres = gs_head-pidres.
      IF sy-subrc <> 0.
        gv_subrc = '4'.
      ELSE.
        gs_head-pidtxt  = ls_007-pidtxt.
      ENDIF.
    WHEN '5'.
      IF gs_head-pidres IS INITIAL.
        gv_subrc = '5'.
      ELSE.
        CLEAR ls_007.
        READ TABLE gt_007 INTO ls_007
                           WITH KEY werks  = gs_head-werks
                                    pidres = gs_head-pidres.
        IF sy-subrc <> 0.
          gv_subrc = '4'.
        ELSE.
          gs_head-pidtxt  = ls_007-pidtxt.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_number  CHANGING fc_ivnum.
  DATA : lv_mjahr   TYPE mkpf-mjahr.

  lv_mjahr  = sy-datum(4).

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZINVSW'
      subobject               = gs_head-werks
      toyear                  = lv_mjahr
    IMPORTING
      number                  = fc_ivnum
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
ENDFORM.                    " F_GET_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_SEND_MAIL
*&---------------------------------------------------------------------*
FORM f_send_mail .
  DATA : lt_mail  TYPE STANDARD TABLE OF zmail.

  DATA : lo_mime_helper  TYPE REF TO cl_gbt_multirelated_service,
         lt_soli         TYPE TABLE OF soli,
         ls_soli         TYPE soli,
         lo_doc_bcs      TYPE REF TO cl_document_bcs,
         lo_bcs          TYPE REF TO cl_bcs,
         ls_mail         LIKE LINE OF lt_mail,
         lo_recipient    TYPE REF TO if_recipient_bcs,
         lv_status       TYPE bcs_rqst,
         lv_subject(50),
         lw_document_bcs TYPE REF TO cx_document_bcs.

  SELECT *
    FROM zmail
    INTO CORRESPONDING FIELDS OF TABLE lt_mail
    WHERE project = 'CEK'
      AND werks   = gs_head-werks
      AND lgort   = gs_head-lgort.

  IF gt_006[] IS NOT INITIAL.
    lv_subject = 'PID Sub Warehouse'.

    CLEAR lt_soli[].
    PERFORM f_create_email_body TABLES lt_soli.

    CREATE OBJECT lo_mime_helper.

    CALL METHOD lo_mime_helper->set_main_html
      EXPORTING
        content = lt_soli.

    lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
                    i_subject          = lv_subject
                    i_importance       = '9'
                    i_multirel_service = lo_mime_helper ).

    lo_bcs = cl_bcs=>create_persistent( ).

    lo_bcs->set_document( i_document = lo_doc_bcs ).

* Set the email address
    LOOP AT lt_mail INTO ls_mail.
      IF ls_mail-zto IS NOT INITIAL.
        CLEAR lo_recipient.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                          i_address_string = ls_mail-email ).
        lo_bcs->add_recipient( i_recipient = lo_recipient ).
      ENDIF.

      IF ls_mail-cc IS NOT INITIAL.
        CLEAR lo_recipient.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                      i_address_string = ls_mail-email ).
        lo_bcs->add_recipient( i_recipient = lo_recipient
                               i_copy      = 'X').
      ENDIF.
    ENDLOOP.

    lv_status = 'N'.
    CALL METHOD lo_bcs->set_status_attributes
      EXPORTING
        i_requested_status = lv_status.
    TRY.
        lo_bcs->send( ).
        COMMIT WORK.
      CATCH cx_bcs.
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_SEND_MAIL

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_EMAIL_BODY
*&---------------------------------------------------------------------*
FORM f_create_email_body  TABLES   ft_soli STRUCTURE soli.
  DATA : ls_soli TYPE soli,
         ls_006  LIKE LINE OF gt_006.

  PERFORM f_create_merge USING 'ZPID_3BODY' ''.
  PERFORM f_create_merge USING 'ZPID_IVNUM' ''.
  PERFORM f_create_merge USING 'ZPID_3FOOTER' ''.

  LOOP AT gt_body INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
  LOOP AT gt_html INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
  LOOP AT gt_foot INTO ls_soli.
    APPEND ls_soli TO ft_soli.
    CLEAR ls_soli.
  ENDLOOP.
ENDFORM.                    " F_CREATE_EMAIL_BODY

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_MERGE
*&---------------------------------------------------------------------*
FORM f_create_merge  USING    fu_template fu_itab.
  TYPES : BEGIN OF ty_x006,
            werks      TYPE ztspmmdt006-werks,
            lgort      TYPE ztspmmdt006-lgort,
            ivnum      TYPE ztspmmdt006-ivnum,
            qdatu      TYPE ztspmmdt006-qdatu,
            ivpos      TYPE ztspmmdt006-ivpos,
            matnr      TYPE ztspmmdt006-matnr,
            maktx      TYPE makt-maktx,
            charg      TYPE ztspmmdt006-charg,
            meins      TYPE ztspmmdt006-meins,
            labst(20),
            menge(20),
            lebih(20),
            kurang(20),
            pidtxt     TYPE ztspmmdt007-pidtxt,
          END OF ty_x006.

  DATA : ls_006    LIKE LINE OF gt_006,
         lt_x006   TYPE STANDARD TABLE OF ty_x006,
         ls_x006   LIKE LINE OF lt_x006,
         lt_fields TYPE STANDARD TABLE OF w3fields WITH HEADER LINE,
         lt_header TYPE STANDARD TABLE OF w3head WITH HEADER LINE,
         lv_kurang TYPE ztspmmdt006-menge,
         lv_lebih  TYPE ztspmmdt006-menge,
         ls_007    LIKE LINE OF gt_007,
         lt_fcat   TYPE lvc_t_fcat,
         ls_fcat   TYPE lvc_s_fcat,
         w_head    TYPE w3head.

  CASE fu_template.
    WHEN 'ZPID_3BODY'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_body[]
        CHANGING
          merge_table = gt_bmerge[].

    WHEN 'ZPID_IVNUM'.
      ls_fcat-coltext = 'Plant'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'SLoc.'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'No. PID'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Tanggal PID'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Item'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Material'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Description'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Batch'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Uom'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Quantity'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Counted Qty'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Qty Lebih'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Qty Kurang'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-coltext = 'Reason'.
      APPEND ls_fcat TO lt_fcat.

      LOOP AT lt_fcat INTO ls_fcat.
        w_head-text = ls_fcat-coltext.

        CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
          EXPORTING
            field_nr = sy-tabix
            text     = w_head-text
            fgcolor  = 'black'
            bgcolor  = 'green'
          TABLES
            header   = lt_header.

        CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
          EXPORTING
            field_nr = sy-tabix
            fgcolor  = 'black'
            size     = '3'
          TABLES
            fields   = lt_fields.
      ENDLOOP.

      LOOP AT gt_006 INTO ls_006.
        ls_x006-werks = ls_006-werks.
        ls_x006-lgort = ls_006-lgort.
        ls_x006-ivnum = ls_006-ivnum.
        ls_x006-qdatu = ls_006-qdatu.
        ls_x006-ivpos = ls_006-ivpos.
        ls_x006-matnr = ls_006-matnr.

        SELECT SINGLE maktx
          FROM makt
          INTO ls_x006-maktx
          WHERE matnr = ls_006-matnr
            AND spras = sy-langu.

        ls_x006-charg = ls_006-charg.
        PERFORM f_conversion_meins USING ls_006-meins
                                   CHANGING ls_x006-meins.
        PERFORM f_unit_conversion USING ls_006-meins ls_006-labst
                                  CHANGING ls_x006-labst.
        PERFORM f_unit_conversion USING ls_006-meins ls_006-menge
                                  CHANGING ls_x006-menge.
        lv_kurang = ls_006-menge - ls_006-labst.
        IF lv_kurang < 0.
          lv_kurang = abs( lv_kurang ).
          lv_lebih  = 0.
        ELSE.
          lv_lebih  = lv_kurang.
          lv_kurang = 0.
        ENDIF.
        PERFORM f_unit_conversion USING ls_006-meins lv_kurang
                                  CHANGING ls_x006-kurang.
        PERFORM f_unit_conversion USING ls_006-meins lv_lebih
                                  CHANGING ls_x006-lebih.
        READ TABLE gt_007 INTO ls_007
                          WITH KEY werks  = ls_006-werks
                                   pidres = ls_006-pidres.
        IF sy-subrc = 0.
          ls_x006-pidtxt  = ls_007-pidtxt.
        ENDIF.
        APPEND ls_x006 TO lt_x006.
        CLEAR ls_x006.
      ENDLOOP.

      CLEAR gt_html[].
      CALL FUNCTION 'WWW_ITAB_TO_HTML'
        TABLES
          html       = gt_html
          fields     = lt_fields
          row_header = lt_header
          itable     = lt_x006.

*      CALL FUNCTION 'WWW_HTML_MERGER'
*        EXPORTING
*          template    = fu_template
*        IMPORTING
*          html_table  = gt_table[]
*        CHANGING
*          merge_table = gt_tmerge[].

    WHEN 'ZPID_3FOOTER'.
      CALL FUNCTION 'WWW_HTML_MERGER'
        EXPORTING
          template    = fu_template
        IMPORTING
          html_table  = gt_foot[]
        CHANGING
          merge_table = gt_fmerge[].
  ENDCASE.
ENDFORM.                    " F_CREATE_MERGE

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_MEINS
*&---------------------------------------------------------------------*
FORM f_conversion_meins  USING    fu_meins
                         CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_MEINS

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_meins fu_menge
                        CHANGING fc_menge.
  WRITE fu_menge TO fc_menge UNIT fu_meins.
  CONDENSE fc_menge.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data .
  DATA : ls_detl      LIKE LINE OF gt_detl.

  READ TABLE gt_detl INTO ls_detl
                     WITH KEY ivpos = gs_head-ivpos.
  IF sy-subrc = 0.
    IF ls_detl-loekz IS INITIAL.
      ls_detl-loekz   = 'X'.
    ELSE.
      ls_detl-loekz   = space.
    ENDIF.
    MODIFY gt_detl FROM ls_detl
                   TRANSPORTING loekz
                   WHERE ivpos = gs_head-ivpos.
  ENDIF.
  CLEAR gs_head-ivpos.
ENDFORM.                    " F_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_F4_STKTYP
*&---------------------------------------------------------------------*
FORM f_f4_stktyp.
  TYPES: BEGIN OF ty_stktyp,
           no     TYPE char1,
           stktyp TYPE char10,
         END OF ty_stktyp.

  DATA: lv_dynprofield TYPE help_info-dynprofld,
        lv_domname     TYPE dd07l-domname,
        lt_values_tab  TYPE TABLE OF dd07v,
        lt_stktyp      TYPE TABLE OF ty_stktyp.

  lv_domname = 'ZTSPDM001'.
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname    = lv_domname
    TABLES
      values_tab = lt_values_tab.
  IF sy-subrc = 0.
    LOOP AT lt_values_tab INTO DATA(lw_values_tab)
                          WHERE domvalue_l LE 3.
      APPEND INITIAL LINE TO lt_stktyp ASSIGNING FIELD-SYMBOL(<fs_stktyp>).
      <fs_stktyp>-no     = lw_values_tab-domvalue_l.
      <fs_stktyp>-stktyp = lw_values_tab-ddtext.
    ENDLOOP.

    lv_dynprofield = 'GS_HEAD-STKTYP'.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = 'NO'
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = lv_dynprofield
        value_org   = 'S'
      TABLES
        value_tab   = lt_stktyp.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACTUAL_STOCK
*&---------------------------------------------------------------------*
FORM f_get_actual_stock .
  IF gs_head-charg IS NOT INITIAL.
    READ TABLE gt_mchb INTO DATA(lw_mchb)
                       WITH KEY matnr = gs_head-matnr
                                werks = gs_head-werks
                                lgort = gs_head-lgort
                                charg = gs_head-charg.
    IF sy-subrc = 0.
      CASE gs_head-stktypt.
        WHEN 'UU'.
          SELECT SUM( bdmng ) INTO @DATA(lv_bdmng)
            FROM resb WHERE werks = @gs_head-werks
                        AND lgort = @gs_head-lgort
                        AND charg = @gs_head-charg
                        AND xloek = ' '
                        AND kzear = ' '
                        AND xwaok = 'X'.

          IF lv_bdmng > lw_mchb-clabs.
            gv_subrc = '6'.
          ELSE.
            gs_head-actqty = lw_mchb-clabs - lv_bdmng.
          ENDIF.
        WHEN 'QI'.
          gs_head-actqty = lw_mchb-cinsm.
        WHEN 'BLOCKED'.
          gs_head-actqty = lw_mchb-cspem.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_STOCK_TYPE
*&---------------------------------------------------------------------*
FORM f_get_stock_type .
  DATA: lv_domname    TYPE dd07l-domname,
        lt_values_tab TYPE TABLE OF dd07v.

  IF gs_head-stktyp IS NOT INITIAL.
    lv_domname = 'ZTSPDM001'.
    CALL FUNCTION 'GET_DOMAIN_VALUES'
      EXPORTING
        domname    = lv_domname
      TABLES
        values_tab = lt_values_tab.
    IF sy-subrc = 0.
      READ TABLE lt_values_tab INTO DATA(lw_values_tab)
            WITH KEY domvalue_l = gs_head-stktyp.
      IF sy-subrc = 0.
        gs_head-stktypt = lw_values_tab-ddtext.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  PBO102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo102 OUTPUT.
  PERFORM f_pbo102.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  F_PBO102
*&---------------------------------------------------------------------*
FORM f_pbo102 .
  LOOP AT gt_detl INTO gs_detl.
    APPEND INITIAL LINE TO gt_prnt ASSIGNING FIELD-SYMBOL(<fs_prnt>).
    MOVE-CORRESPONDING gs_detl TO <fs_prnt>.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GENERATE_TABLE102
*&---------------------------------------------------------------------*
FORM f_generate_table102 .
  idx = sy-stepl + line.

  READ TABLE gt_prnt INTO gs_prnt INDEX idx.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE102
*&---------------------------------------------------------------------*
FORM f_modify_table102 .
  ASSIGN gt_prnt[ idx ]-copy TO FIELD-SYMBOL(<fs_prnt>).
  <fs_prnt> = gs_prnt-copy.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_FORM
*&---------------------------------------------------------------------*
FORM f_cetak_form .
  DATA: ls_ztspmmst003 TYPE ztspmmst003,
        lv_cntr        TYPE int1,
        lv_formname    TYPE tdsfname,
        lv_funcname    TYPE tdsfname,
        ctrl_param     LIKE ssfctrlop,
        output_opt     TYPE ssfcompop.

  MOVE-CORRESPONDING gs_head TO ls_ztspmmst003.

  CASE ls_ztspmmst003-werks.
    WHEN '0101'.
      ls_ztspmmst003-company = 'TSP - Cikarang Plant 1'.
    WHEN '0102'.
      ls_ztspmmst003-company = 'TSP - Cikarang Plant 2'.
  ENDCASE.

  CASE ls_ztspmmst003-stktypt.
    WHEN 'UU'.
      ls_ztspmmst003-status = 'Unrestricted Use'.
    WHEN 'QI'.
      ls_ztspmmst003-status = 'Quality Inspection'.
    WHEN OTHERS.
      ls_ztspmmst003-status = 'Blocked'.
  ENDCASE.

  WRITE ls_ztspmmst003-menge TO ls_ztspmmst003-qty DECIMALS 2.
  CONDENSE ls_ztspmmst003-qty.

  lv_formname = 'ZTSPMM_F003'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc = 0.
    ctrl_param-no_close   = space.
    ctrl_param-no_dialog  = 'X'.

    output_opt-tdnewid    = 'X'.
    output_opt-tdimmed    = 'X'.
*    output_opt-tddelete   = 'X'.
    output_opt-tddest     = ls_ztspmmst003-padest.
*    output_opt-tdcopies   = ls_ztspmmst003-copy.

    CLEAR lv_cntr.
    DO ls_ztspmmst003-copy TIMES.
      ADD 1 TO lv_cntr.

      ls_ztspmmst003-zpage = lv_cntr.
      ls_ztspmmst003-zformpage = ls_ztspmmst003-copy.

      CALL FUNCTION lv_funcname
        EXPORTING
          control_parameters = ctrl_param
          output_options     = output_opt
          user_settings      = space
          gs_head            = ls_ztspmmst003
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      IF sy-subrc = 0.

      ENDIF.
    ENDDO.
  ENDIF.
ENDFORM.
