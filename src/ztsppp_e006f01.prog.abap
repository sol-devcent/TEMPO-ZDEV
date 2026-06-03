*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E006F01
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
    WHEN '0601'.
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
                                        'PRT' '0' '' '' ''.
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
      ELSEIF gs_head-posnr IS INITIAL.
        PERFORM f_cursor_position USING 'GS_HEAD-POSNR' ''.
      ELSE.
        PERFORM f_cursor_position USING 'GS_HEAD-VORNR' ''.
      ENDIF.

    WHEN '0602'.
  ENDCASE.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  n1 = 1.
  CASE sy-dynnr.
    WHEN '0601'.
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
    WHEN '0602'.
    WHEN '2999'.
*      CLEAR gs_head.
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
    WHEN '0601'.
    WHEN '0602'.
  ENDCASE.
ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm    TYPE sy-ucomm.

  lv_ucomm  = ok_code.
  CLEAR ok_code.
  CASE sy-dynnr.
    WHEN 2999.
      CASE lv_ucomm.
        WHEN 'CANC'.
          PERFORM f_clear_data.
          LEAVE TO SCREEN 0.
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
*      PERFORM f_next_button.

        WHEN '&PRINT'.
          IF gs_head-message IS INITIAL.
            PERFORM f_prepare_data.
            PERFORM f_unlock_table.
            PERFORM f_print_form.

            IF gt_label[] IS NOT INITIAL.
              CLEAR : gt_label[], gs_head-posnr, gs_head-vornr.
              gv_subrc = '1'.
              CALL SCREEN 2999.
            ELSE.
              gv_subrc = '2'.
              CALL SCREEN 2999.
            ENDIF.
*        PERFORM f_display_message.
*        LEAVE TO SCREEN 0.
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
    WHEN '0601'.
    WHEN '0602'.
  ENDCASE.
ENDFORM.                    " F_GENERATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table .
  DATA : lv_line        TYPE i.

  GET CURSOR LINE lv_line.

  CASE sy-dynnr.
    WHEN '0601'.
    WHEN '0602'.
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

  DATA : lr_steus TYPE RANGE OF steus,
         ls_steus LIKE LINE OF lr_steus.

  CLEAR : gt_order[], gs_head-message, ls_steus.

  ls_steus-low    = 'ZP01'.
  ls_steus-sign   = 'I'.
  ls_steus-option = 'EQ'.
  APPEND ls_steus TO lr_steus.
  ls_steus-low    = 'ZP00'.
  ls_steus-sign   = 'I'.
  ls_steus-option = 'EQ'.
  APPEND ls_steus TO lr_steus.
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
    SORT lt_resb BY aufpl aplzl.
    DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufpl aplzl.
    IF lt_resb[] IS NOT INITIAL.
      SELECT *
        FROM afvu
        INTO CORRESPONDING FIELDS OF TABLE gt_afvu
        FOR ALL ENTRIES IN lt_resb
        WHERE aufpl = lt_resb-aufpl
          AND aplzl = lt_resb-aplzl.
    ENDIF.

    SORT lt_resb BY aufpl.
    DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufpl.
    IF lt_resb[] IS NOT INITIAL.
      SELECT *
        FROM afvc
        INTO CORRESPONDING FIELDS OF TABLE gt_afvc
        FOR ALL ENTRIES IN lt_resb
        WHERE aufpl = lt_resb-aufpl
          AND phflg = 'X'
*          AND phseq = 'W1'
          AND phseq LIKE 'W%'
          AND steus IN lr_steus.
    ENDIF.

    lt_resb[] = gt_resb[].
    SORT lt_resb BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr.
    IF lt_resb[] IS NOT INITIAL.
      SELECT *
        FROM mara
        INTO CORRESPONDING FIELDS OF TABLE gt_mara
        FOR ALL ENTRIES IN lt_resb
        WHERE matnr = lt_resb-matnr.
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

  CLEAR : fc_subrc, gr_sttxt[].
  PERFORM f_range_status USING : ""'DLV',
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
  DATA : ls_order LIKE LINE OF gt_order,
         ls_label LIKE LINE OF gt_label,
         ls_resb  LIKE LINE OF gt_resb,
         ls_afvc  LIKE LINE OF gt_afvc,
         ls_afvu  LIKE LINE OF gt_afvu,
         lt_resb  TYPE STANDARD TABLE OF resb,
         ls_mara  LIKE LINE OF gt_mara,
         lv_vornr TYPE resb-vornr.

  CLEAR : gv_werks, gv_lgort.

  IF gt_order[] IS NOT INITIAL.
    READ TABLE gt_order INTO ls_order
                        WITH KEY posnr = gs_head-posnr.
    IF sy-subrc = 0.
      lt_resb[] = gt_resb[].
      SORT lt_resb BY aufnr aufpl aplzl.
      DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufnr aufpl aplzl.

      IF gs_head-vornr IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
          EXPORTING
            input  = gs_head-vornr
          IMPORTING
            output = lv_vornr.
      ENDIF.

      LOOP AT lt_resb INTO ls_resb WHERE aufnr = ls_order-aufnr.
        IF lv_vornr IS NOT INITIAL.
          IF ls_resb-vornr <> lv_vornr.
            CONTINUE.
          ENDIF.
        ENDIF.
        CLEAR ls_mara.
        READ TABLE gt_mara INTO ls_mara
                           WITH KEY matnr = ls_resb-matnr.
        IF ls_mara-mtart = 'ZRM'.
          gv_werks    = ls_resb-werks.
          gv_lgort    = ls_resb-lgort.
        ENDIF.
        CLEAR ls_afvc.
        READ TABLE gt_afvc INTO ls_afvc
                           WITH KEY aufpl = ls_resb-aufpl
                                    aplzl = ls_resb-aplzl.
        IF sy-subrc = 0.
          ls_label-aufnr   = ls_order-aufnr.
          ls_label-plnbez  = ls_order-plnbez.
          ls_label-maktx   = gs_head-maktx.
          ls_label-fcharg  = ls_order-fcharg.
          ls_label-gstrp   = gs_head-gstrp.

          ls_label-vornr   = ls_afvc-vornr.
          ls_label-ltxa1   = ls_afvc-ltxa1.
          CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-charg
                      ls_label-vornr
          INTO ls_label-qrcode
          SEPARATED BY ';'.
          ls_label-flag    = space.
          APPEND ls_label TO gt_label.
          CLEAR ls_label.
        ENDIF.

        READ TABLE gt_afvu INTO ls_afvu
                           WITH KEY aufpl = ls_resb-aufpl
                                    aplzl = ls_resb-aplzl.
        IF sy-subrc = 0.
          IF ls_afvu-usr01 IS NOT INITIAL.
            ls_label-aufnr   = ls_order-aufnr.
            ls_label-plnbez  = ls_order-plnbez.
            ls_label-maktx   = gs_head-maktx.
            ls_label-fcharg  = ls_order-fcharg.
            ls_label-gstrp   = gs_head-gstrp.

            ls_label-vornr   = ls_afvc-vornr.
            ls_label-ltxa1   = ls_afvu-usr01.
            CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-charg
                        ls_label-vornr 'D'
            INTO ls_label-qrcode
            SEPARATED BY ';'.
            ls_label-flag    = 'X'.
            APPEND ls_label TO gt_label.
            CLEAR ls_label.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_formname TYPE tdsfname,
         lv_funcname TYPE tdsfname,
         ctrl_param  LIKE ssfctrlop,
         output_opt  TYPE ssfcompop,
         ls_label    TYPE ztspppst004,
         default     TYPE bapidefaul,
         return      TYPE STANDARD TABLE OF bapiret2,
         lv_ldest    TYPE t329d-ldest.

  DATA : lv_lname            TYPE ztspppdt004-lname.

  lv_formname = 'ZTSPPPF003'.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = default
    TABLES
      return   = return.

  SELECT SINGLE lname
    FROM ztspppdt004
    INTO lv_lname
    WHERE werks = gv_werks
      AND lgort = gv_lgort.

  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_SPDEV_INPUT'
      EXPORTING
        input  = lv_lname
      IMPORTING
        output = default-spld.
  ENDIF.

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

*  CLEAR : gt_label[], gs_head-posnr, gs_head-vornr.
ENDFORM.                    " F_PRINT_FORM

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
      c  = c - 30.
  ENDCASE.
ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
FORM f_display_message .
*  DATA : message_id            LIKE t100-arbgb VALUE 'LF',
*         message_lang          LIKE t100-sprsl,
*         message_type          LIKE sy-msgty VALUE 'E',
*         message_number        LIKE t100-msgnr ,
*         message_var1          LIKE sprot_u-var1,
*         message_var2          LIKE sprot_u-var2,
*         message_var3          LIKE sprot_u-var3,
*         message_var4          LIKE sprot_u-var4,
*         answer.
*  message_lang    = sy-langu.
*  message_id      = 'ZAB'.
*  message_number  = '000'.
*  message_var1    = 'Label telah'.
*  message_var2    = 'di print'.
*
*  CALL FUNCTION 'CALL_MESSAGE_SCREEN'
*    EXPORTING
*      i_msgid          = message_id
*      i_lang           = message_lang
*      i_msgno          = message_number
*      i_msgv1          = message_var1
*      i_msgv2          = message_var2
*      i_msgv3          = message_var3
*      i_msgv4          = message_var4
*      i_condense       = 'X'
*    IMPORTING
*      o_answer         = answer
*    EXCEPTIONS
*      invalid_message1 = 01.

  DATA : lv_message(20).
  CLEAR : message1, message2, message3, message4, message5, message6,
          message7.

  CASE gv_subrc.
    WHEN 1.
      message1 = 'Label telah'.
      message2 = 'di print'.
    WHEN 2.
      message1 = 'Label gagal'.
      message2 = 'di print'.
  ENDCASE.

  CLEAR gv_subrc.
ENDFORM.                    " F_DISPLAY_MESSAGE
