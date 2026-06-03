*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E003F01
*&---------------------------------------------------------------------*
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
  IF gs_print-mblnr IS INITIAL.
    PERFORM f_cursor_position USING 'GS_PRINT-MBLNR' ''.
  ELSEIF gs_print-mjahr IS INITIAL.
    PERFORM f_cursor_position USING 'GS_PRINT-MJAHR' ''.
  ELSEIF gs_print-aufnr IS NOT INITIAL.
    PERFORM f_cursor_position USING 'GS_PRINT-AUFNR' ''.
  ELSE.
    PERFORM f_cursor_position USING 'GS_PRINT-MJAHR' ''.
  ENDIF.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .

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

ENDFORM.                    " F_PROCESS_AFTER_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm   TYPE sy-ucomm.

  lv_ucomm = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOGOFF'.
      CALL 'SYST_LOGOFF'.
    WHEN '&BACK'.
      IF gs_print IS INITIAL.
        CLEAR : gs_print.
        LEAVE TO SCREEN 0.
      ELSE.
        CLEAR : gs_print.
      ENDIF.
    WHEN '&PRINT'.
      PERFORM f_get_data.
      IF gv_message IS INITIAL.
        PERFORM f_prepare_data.
        PERFORM f_print_form.
        CLEAR : gs_print.
        PERFORM f_display_message.
      ELSE.
        CLEAR : gs_print.
      ENDIF.
    WHEN OTHERS.
      CLEAR : gv_message.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_mseg    TYPE STANDARD TABLE OF mseg,
         lt_resb    TYPE STANDARD TABLE OF resb.

  IF gs_print-aufnr IS INITIAL.
    SELECT *
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE lt_mseg
      WHERE smbln = gs_print-mblnr
        AND sjahr = gs_print-mjahr.
    IF sy-subrc = 0.
      CONCATENATE 'Document' gs_print-mblnr 'telah dicancel'
      INTO gv_message
      SEPARATED BY space.
    ELSE.
      SELECT *
        FROM mkpf
        INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
        WHERE mblnr = gs_print-mblnr
          AND mjahr = gs_print-mjahr.

      SELECT *
        FROM mseg
        INTO CORRESPONDING FIELDS OF TABLE gt_mseg
        WHERE mblnr = gs_print-mblnr
          AND mjahr = gs_print-mjahr
          AND bwart = '261'
          AND smbln = space.
      IF sy-subrc = 0.
        lt_mseg[] = gt_mseg[].
        SORT lt_mseg BY aufnr.
        IF lt_mseg[] IS NOT INITIAL.
          SELECT *
            FROM afpo
            INTO CORRESPONDING FIELDS OF TABLE gt_afpo
            FOR ALL ENTRIES IN lt_mseg
            WHERE aufnr = lt_mseg-aufnr.
        ENDIF.

        lt_mseg[] = gt_mseg[].
        SORT lt_mseg BY rsnum rspos.
        IF lt_mseg[] IS NOT INITIAL.
          SELECT *
            FROM resb
            INTO CORRESPONDING FIELDS OF TABLE gt_resb
            FOR ALL ENTRIES IN lt_mseg
            WHERE rsnum = lt_mseg-rsnum
              AND rspos = lt_mseg-rspos.

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
        ENDIF.
      ELSE.
        CONCATENATE 'Document' gs_print-mblnr 'tidak ditemukan'
        INTO gv_message
        SEPARATED BY space.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT *
      FROM ztspppdt003
      INTO CORRESPONDING FIELDS OF TABLE gt_003
      WHERE aufnr = gs_print-aufnr.

    SELECT *
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE gt_afpo
      WHERE aufnr = gs_print-aufnr.

    SELECT *
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      WHERE aufnr = gs_print-aufnr
        AND wempf = 'W'.

    IF sy-subrc = 0.
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
    ELSE.
      CONCATENATE 'Order' gs_print-aufnr 'tidak ditemukan'
      INTO gv_message
      SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form .
  DATA : lv_formname         TYPE tdsfname,
         lv_funcname         TYPE tdsfname,
         ctrl_param          LIKE ssfctrlop,
         parameter           TYPE STANDARD TABLE OF bapiparam,
         ls_parameter        LIKE LINE OF parameter,
         output_opt          TYPE ssfcompop,
         ls_label            TYPE ztspppst004,
         default             TYPE bapidefaul,
         return              TYPE STANDARD TABLE OF bapiret2,
         lv_ldest            TYPE t329d-ldest.

  lv_formname = 'ZTSPPPF001'.

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

    ls_label-reprint      = 'X'.
    ls_label-weidt        = 'Tgl. Timbang'.

    CASE gv_werks.
      WHEN '0101'.
        ls_label-company  = 'TSP - Cikarang Plant 1'.
      WHEN '0102'.
        ls_label-company  = 'TSP - Cikarang Plant 2'.
    ENDCASE.

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
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : ls_mseg    LIKE LINE OF gt_mseg,
         ls_mkpf    LIKE LINE OF gt_mkpf,
         ls_label   LIKE LINE OF gt_label,
         ls_afpo    LIKE LINE OF gt_afpo,
         ls_resb    LIKE LINE OF gt_resb,
         ls_003     LIKE LINE OF gt_003,
         lv_menge   TYPE mseg-menge,
         lv_times   TYPE p DECIMALS 0,
         lv_count   TYPE p DECIMALS 0,
         lv_erfmg(20),
         lv_total(20),
         lv_cnt1(20),
         lv_cnt2(20),
         lv_to      TYPE mseg-menge,
         lt_hazcom  TYPE TABLE OF ztspmdhazcom WITH HEADER LINE,
         h(10), f(10), r(10),
         lv_charg   TYPE char10,
         lv_hazcom  TYPE char30,
         lv_flag.

  DATA : lv_lifnr LIKE lfa1-lifnr,
         lv_name1 LIKE lfa1-name1,
         lv_meanval TYPE qmean_val.

  IF gs_print-aufnr IS INITIAL.
    DESCRIBE TABLE gt_mseg LINES lv_to.

    LOOP AT gt_mseg INTO ls_mseg.
      IF ls_mseg-menge IS INITIAL.
        CONTINUE.
      ENDIF.

      IF gv_werks IS INITIAL.
        gv_werks  = ls_mseg-werks.
      ENDIF.

      PERFORM f_gty_conversion USING ls_mseg-matnr ls_mseg-werks ls_mseg-charg
                                     ls_mseg-menge
                               CHANGING lv_menge lv_times.
      IF lv_flag IS INITIAL.
        lv_to   = lv_to * lv_times.
        lv_flag = 'X'.
      ENDIF.

      CLEAR: lt_hazcom,lv_hazcom,h,f,r.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF lt_hazcom
        FROM ztspmdhazcom WHERE matnr = ls_mseg-matnr
                            AND werks = gv_werks.
      IF sy-subrc = 0.
        CONCATENATE 'H =' lt_hazcom-health INTO h SEPARATED BY space.
        CONCATENATE 'F =' lt_hazcom-fire   INTO f SEPARATED BY space.
        CONCATENATE 'R =' lt_hazcom-reactivity INTO r SEPARATED BY space.
        CONCATENATE h f r  INTO lv_hazcom SEPARATED BY ' ; '.
      ENDIF.

      CLEAR: lv_lifnr,lv_name1.
      PERFORM f_get_vendor(ztsppp_e001) USING ls_mseg-matnr
                                              ls_mseg-charg
                           CHANGING lv_lifnr lv_name1.
      IF lv_name1 IS NOT INITIAL.
        CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
      ENDIF.

      CLEAR lv_meanval.
      PERFORM f_get_meanval(ztsppp_e002)
              USING ls_mseg-werks ls_mseg-matnr ls_mseg-charg
              CHANGING lv_meanval.
      IF lv_meanval IS NOT INITIAL.
        CONCATENATE '(X=' lv_meanval 'mg)' INTO lv_meanval.
      ENDIF.

      DO lv_times TIMES.
        WRITE lv_to TO lv_total DECIMALS 0.
        CONDENSE lv_total NO-GAPS.

        ADD 1 TO lv_count.
        ls_label-aufnr  = ls_mseg-aufnr.

        CLEAR ls_afpo.
        READ TABLE gt_afpo INTO ls_afpo
                           WITH KEY aufnr = ls_mseg-aufnr.
        IF sy-subrc = 0.
          ls_label-fcharg   = ls_afpo-charg.
          ls_label-plnbez   = ls_afpo-matnr.
        ENDIF.

        PERFORM f_matnr_description USING ls_label-plnbez ''
                                    CHANGING ls_label-fmaktx.

        ls_label-rspos      = ls_mseg-rspos.
        CLEAR ls_resb.
        READ TABLE gt_resb INTO ls_resb
                           WITH KEY rsnum = ls_mseg-rsnum
                                    rspos = ls_mseg-rspos.
        IF sy-subrc = 0.
          ls_label-vornr      = ls_resb-vornr.
          ls_label-posnr      = ls_resb-posnr.
          PERFORM f_matnr_description USING '' ls_resb-vornr
                                      CHANGING ls_label-ltxa1.
          PERFORM f_get_user_field USING ls_resb-aufpl ls_resb-aplzl
                                   CHANGING ls_label-usr00.
        ENDIF.

        PERFORM f_matnr_description USING ls_mseg-matnr ''
                                    CHANGING ls_label-maktx.

        ls_label-matnr      = ls_mseg-matnr.
        ls_label-charg      = ls_mseg-charg.
        ls_label-erfmg      = ls_mseg-menge.
        ls_label-erfme      = ls_mseg-meins.
        ls_label-mblnr      = ls_mseg-mblnr.

        WRITE lv_menge TO ls_label-erfmgt UNIT ls_mseg-meins.
        CONDENSE ls_label-erfmgt NO-GAPS.

        PERFORM f_meins_convertion USING ls_label-erfme
                                   CHANGING ls_label-erfmgt.

        lv_charg = ls_label-charg.
        SHIFT lv_charg LEFT DELETING LEADING '0'.
*        CONCATENATE ls_label-aufnr ls_label-plnbez ls_label-vornr
*                    ls_label-posnr ls_label-matnr ls_label-charg
*                    ls_label-erfmgt
        CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-vornr
                    ls_label-posnr  ls_label-matnr ls_label-erfmgt
                    ls_label-count  'F' lv_charg ls_label-mblnr
        INTO ls_label-qrcode
        SEPARATED BY ';'.

        WRITE lv_count TO lv_erfmg DECIMALS 0.
        CONDENSE lv_erfmg NO-GAPS.

        CONCATENATE lv_erfmg '/' lv_total INTO ls_label-count.
        CONDENSE ls_label-count NO-GAPS.

        READ TABLE gt_mkpf INTO ls_mkpf INDEX 1.
        IF sy-subrc = 0.
          SPLIT ls_mkpf-bktxt AT ';' INTO ls_label-wb ls_label-operator ls_label-pengawas.
          ls_label-budat  = ls_mkpf-budat.
        ENDIF.

        ls_label-hazcom = lv_hazcom.
        ls_label-lifnr  = lv_lifnr.
        ls_label-name1  = lv_name1.
        ls_label-meanval = lv_meanval.

        APPEND ls_label TO gt_label.
        CLEAR ls_label.
      ENDDO.
    ENDLOOP.
  ELSE.
    LOOP AT gt_resb INTO ls_resb.
      IF gv_werks IS INITIAL.
        gv_werks  = ls_resb-werks.
      ENDIF.

      ls_label-aufnr = gs_print-aufnr.

      CLEAR ls_afpo.
      READ TABLE gt_afpo INTO ls_afpo
                         WITH KEY aufnr = gs_print-aufnr.
      IF sy-subrc = 0.
        ls_label-fcharg = ls_afpo-charg.
        ls_label-plnbez = ls_afpo-matnr.
      ENDIF.

      PERFORM f_matnr_description USING ls_resb-baugr ''
                                  CHANGING ls_label-fmaktx.
      ls_label-rspos               = ls_resb-rspos.
      PERFORM f_matnr_description USING '' ls_resb-vornr
                                  CHANGING ls_label-ltxa1.
      PERFORM f_matnr_description USING ls_resb-matnr ''
                                  CHANGING ls_label-maktx.

      ls_label-matnr               = ls_resb-matnr.
      CLEAR ls_003.
      READ TABLE gt_003 INTO ls_003
                        WITH KEY rsnum = ls_resb-rsnum
                                 rspos = ls_resb-rspos.
      IF sy-subrc = 0.
        ls_label-charg               = ls_003-charg.
      ENDIF.
      ls_label-vornr               = ls_resb-vornr.
      ls_label-erfmg               = ls_resb-erfmg.
      ls_label-erfme               = ls_resb-meins.
      ls_label-nofull              = 'X'.
      WRITE ls_label-erfmg TO ls_label-erfmgt UNIT ls_label-erfme.
      CONDENSE ls_label-erfmgt NO-GAPS.
      PERFORM f_meins_convertion USING ls_label-erfme
                                 CHANGING ls_label-erfmgt.

      READ TABLE gt_mkpf INTO ls_mkpf INDEX 1.
      IF sy-subrc = 0.
        SPLIT ls_mkpf-bktxt AT ';' INTO ls_label-wb ls_label-operator ls_label-pengawas.
        ls_label-budat  = ls_mkpf-budat.
      ENDIF.

      CLEAR: lv_lifnr,lv_name1.
      PERFORM f_get_vendor(ztsppp_e001) USING ls_resb-matnr
                                              ls_resb-charg
                           CHANGING lv_lifnr lv_name1.
      ls_label-lifnr = lv_lifnr.
      IF lv_name1 IS NOT INITIAL.
        CONCATENATE '(' lv_name1(30) ')' INTO lv_name1.
      ENDIF.
      ls_label-name1 = lv_name1.

      CLEAR lv_meanval.
      PERFORM f_get_meanval(ztsppp_e002)
              USING ls_mseg-werks ls_mseg-matnr ls_mseg-charg
              CHANGING lv_meanval.
      IF lv_meanval IS NOT INITIAL.
        CONCATENATE '(X=' lv_meanval 'mg)' INTO lv_meanval.
      ENDIF.
      ls_label-meanval = lv_meanval.

      APPEND ls_label TO gt_label.
      CLEAR ls_label.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE gt_label LINES lv_to.
  WRITE lv_to TO lv_total DECIMALS 0.
  CONDENSE lv_total NO-GAPS.

  LOOP AT gt_label INTO ls_label.
    SPLIT ls_label-count AT '/' INTO lv_cnt1 lv_cnt2.
    CONDENSE lv_cnt1 NO-GAPS.
    CONDENSE lv_cnt2 NO-GAPS.
    CONCATENATE lv_cnt1 '/' lv_total INTO ls_label-count.

    lv_charg = ls_label-charg.
    SHIFT lv_charg LEFT DELETING LEADING '0'.
    CONCATENATE ls_label-plnbez ls_label-aufnr ls_label-vornr
                ls_label-posnr  ls_label-matnr ls_label-erfmgt
                ls_label-count  'F' lv_charg ls_label-mblnr
    INTO ls_label-qrcode
    SEPARATED BY ';'.

    MODIFY gt_label FROM ls_label TRANSPORTING count qrcode.
    CLEAR ls_label.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MATNR_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_matnr_description  USING    fu_matnr fu_vornr
                          CHANGING fc_description.
  CLEAR fc_description.

  IF fu_matnr IS NOT INITIAL.
    SELECT SINGLE maktx
    FROM makt
    INTO fc_description
    WHERE matnr = fu_matnr
      AND spras = sy-langu.
  ELSEIF fu_vornr IS NOT INITIAL.
  ENDIF.
ENDFORM.                    " F_MATNR_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_GTY_CONVERSION
*&---------------------------------------------------------------------*
FORM f_gty_conversion  USING    fu_matnr fu_werks fu_charg fu_menge
                       CHANGING fc_menge fc_times.
  DATA : cob        TYPE STANDARD TABLE OF clbatch,
         ls_cob     LIKE LINE OF cob.

  CLEAR fc_menge.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
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
      fc_menge  = ls_cob-atwtb.

      fc_times = fu_menge DIV fc_menge.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GTY_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_GET_USER_FIELD
*&---------------------------------------------------------------------*
FORM f_get_user_field  USING    fu_aufpl fu_aplzl
                       CHANGING fc_usr00.
  DATA : ls_afvu    LIKE LINE OF gt_afvu.

  CLEAR ls_afvu.
  READ TABLE gt_afvu INTO ls_afvu
                     WITH KEY aufpl = fu_aufpl
                              aplzl = fu_aplzl.
  IF sy-subrc = 0.
    fc_usr00  = ls_afvu-usr00.
  ENDIF.
ENDFORM.                    " F_GET_USER_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
FORM f_display_message .
  DATA : message_id            LIKE t100-arbgb VALUE 'LF',
         message_lang          LIKE t100-sprsl,
         message_type          LIKE sy-msgty VALUE 'E',
         message_number        LIKE t100-msgnr ,
         message_var1          LIKE sprot_u-var1,
         message_var2          LIKE sprot_u-var2,
         message_var3          LIKE sprot_u-var3,
         message_var4          LIKE sprot_u-var4.

  message_lang    = sy-langu.

  message_id      = 'ZAB'.
  message_number  = '000'.
  message_var1    = 'Label telah'.
  message_var2    = 'di print'.

  CALL FUNCTION 'CALL_MESSAGE_SCREEN'
    EXPORTING
      i_msgid          = message_id
      i_lang           = message_lang
      i_msgno          = message_number
      i_msgv1          = message_var1
      i_msgv2          = message_var2
      i_msgv3          = message_var3
      i_msgv4          = message_var4
      i_condense       = 'X'
    EXCEPTIONS
      invalid_message1 = 01.
ENDFORM.                    " F_DISPLAY_MESSAGE

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
