*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CASE sy-dynnr.
    WHEN '0100'.
      APPEND '&SAVE' TO fcode.
      SET TITLEBAR 'TITLE-001'.
      CASE sy-tcode.
        WHEN 'ZKMMMME001'.
          SET TITLEBAR 'TITLE-003'.
        WHEN OTHERS.
          SET TITLEBAR 'TITLE-001'.
      ENDCASE.
    WHEN '0101'.
      APPEND '&PREV' TO fcode.
      APPEND '&REPRINT' TO fcode.
      APPEND '&DELETE' TO fcode.
      APPEND '&SAVE' TO fcode.
      SET TITLEBAR 'TITLE-001'.
    WHEN '0102'.
      APPEND '&PREV' TO fcode.
      APPEND '&REPRINT' TO fcode.
      APPEND '&DELETE' TO fcode.
      APPEND '&POS' TO fcode.
      SET TITLEBAR 'TITLE-002'.
  ENDCASE.

  SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  gs_btn-delete = icon_delete.

  IF gs_btn-werks IS INITIAL.
    PERFORM f_modify_screen USING : 'WER' '0' '' '' ''.
  ENDIF.

  IF gs_btn-bwart IS INITIAL.
    PERFORM f_modify_screen USING : 'BWA' '0' '' '' ''.
  ENDIF.

  IF gs_btn-umlgo IS INITIAL.
    PERFORM f_modify_screen USING : 'UML' '0' '' '' ''.
  ENDIF.

  IF gs_btn-lgort IS INITIAL.
    PERFORM f_modify_screen USING : 'LGO' '0' '' '' ''.
  ENDIF.

  DESCRIBE TABLE gt_items LINES fitems.
  tc_items-lines = fitems.

  IF gs_head-werks IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-WERKS' ''.
  ELSEIF gs_head-bwart IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-BWART' ''.
  ELSEIF gs_head-lgort IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-LGORT' ''.
  ELSEIF gs_head-umlgo IS INITIAL.
    PERFORM f_cursor_position USING 'GS_HEAD-UMLGO' ''.
  ELSE.
    PERFORM f_cursor_position USING 'GS_ITEMS-MATNR' '1'.
  ENDIF.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TC_ITEMS
*&---------------------------------------------------------------------*
FORM f_fill_tc_items .

  PERFORM f_validate_data USING tc_items-current_line.

  IF gs_items-matnr IS INITIAL AND
    gs_items-erfmg IS INITIAL AND
    gs_items-charg IS INITIAL.
    IF gv_isi IS NOT INITIAL.
      PERFORM f_cursor_position USING 'GS_ITEMS-MATNR'
                                      tc_items-current_line.
    ENDIF.
    CLEAR gv_isi.
  ELSEIF gs_items-erfmg IS INITIAL AND
    gs_items-charg IS INITIAL.
    PERFORM f_cursor_position USING 'GS_ITEMS-ERFMG'
                                    tc_items-current_line.
    CLEAR gv_isi.
  ELSEIF gs_items-charg IS INITIAL.
    PERFORM f_cursor_position USING 'GS_ITEMS-CHARG'
                                    tc_items-current_line.
    CLEAR gv_isi.
  ELSE.
    gv_isi = 'X'.
  ENDIF.
ENDFORM.                    " F_FILL_TC_ITEMS

*&---------------------------------------------------------------------*
*&      Form  F_PAI
*&---------------------------------------------------------------------*
FORM f_pai .

ENDFORM.                    " F_PAI

*&---------------------------------------------------------------------*
*&      Form  F_READ_TC_ITEMS
*&---------------------------------------------------------------------*
FORM f_read_tc_items .
  gs_items-rspos = tc_items-current_line.

  MODIFY gt_items FROM gs_items INDEX tc_items-current_line.
  IF sy-subrc <> 0.
    APPEND gs_items TO gt_items.
  ENDIF.
ENDFORM.                    " F_READ_TC_ITEMS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm TYPE sy-ucomm,
         lv_line  TYPE i.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'WERKS' OR 'BWART' OR 'UMLGO' OR 'LGORT'.
      PERFORM f_display_message USING lv_ucomm ''.

    WHEN '&DELETE'.
      GET CURSOR LINE lv_line.
      PERFORM f_delete_data USING lv_line.

    WHEN '&STATUS'.
      GET CURSOR LINE lv_line.
      PERFORM f_display_message USING '' lv_line.

    WHEN '&PREV'.
      IF gt_error[] IS INITIAL.
        PERFORM f_prepare_print.
        IF gt_error[] IS INITIAL.
          PERFORM f_print_form USING 'PREV'.
        ENDIF.
      ENDIF.

    WHEN '&REPRINT'.
      CALL SCREEN 101 STARTING AT 10 10.

    WHEN '&POS'.
      IF gt_error[] IS INITIAL.
        IF sy-dynnr = '0100'.
          PERFORM f_reservation_prepare.
          PERFORM f_reservation_process.
          IF gt_error[] IS INITIAL.
            PERFORM f_clear_data.
            PERFORM f_print_form USING 'PRINT'.
            MESSAGE s000(zab) WITH 'Document' gs_prth-rsnum 'posted'.
            CLEAR : gs_prth, gt_prtd[].
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
      IF sy-dynnr = '0101'.
        PERFORM f_reprint.
        PERFORM f_print_form USING ''.
        CLEAR gs_head-rsnum.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_F4_STORAGE_LOCATION
*&---------------------------------------------------------------------*
FORM f_f4_storage_location .
  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : ls_sloc  LIKE LINE OF gt_sloc,
         lv_subrc TYPE sy-subrc,
         lv_werks TYPE t001l-werks,
         lv_lgort TYPE t001l-lgort,
         lv_field TYPE help_info-dynprofld.

  CLEAR : dynpfields[], dynpfields.

  GET CURSOR FIELD lv_field.

  PERFORM f_dynp_value_read USING 'GS_HEAD-WERKS' ''
                            CHANGING lv_werks.

  IF lv_werks IS NOT INITIAL.
    PERFORM f_get_storage_lcoation USING lv_werks.

    ASSIGN gt_sloc[] TO <fs_tab>.

    CLEAR lv_subrc.
    PERFORM f_value_request TABLES return_tab
                            USING 'LGORT' lv_field
                            CHANGING lv_subrc.

    IF lv_subrc = 0.
      READ TABLE return_tab INTO ls_return INDEX 1.
      IF sy-subrc = 0.
        lv_lgort  = ls_return-fieldval.
        CLEAR ls_sloc.
        READ TABLE gt_sloc INTO ls_sloc
                           WITH KEY lgort = lv_lgort.
        IF sy-subrc = 0.
          PERFORM f_dynpfield TABLES dynpfields
                              USING lv_field ls_sloc-lgort ''.
        ENDIF.

        PERFORM f_dyn_values_update.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_F4_STORAGE_LOCATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_STORAGE_LCOATION
*&---------------------------------------------------------------------*
FORM f_get_storage_lcoation USING fu_werks.
  DATA : ls_t001l LIKE LINE OF gt_t001l,
         ls_sloc  LIKE LINE OF gt_sloc.

  IF gt_sloc[] IS INITIAL AND fu_werks IS NOT INITIAL.
    LOOP AT gt_t001l INTO ls_t001l WHERE werks = fu_werks.
      MOVE-CORRESPONDING ls_t001l TO ls_sloc.
      APPEND ls_sloc TO gt_sloc.
      CLEAR : ls_t001l, ls_sloc.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_STORAGE_LCOATION

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname line
                        CHANGING fc_value.

  DATA : lt_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields LIKE LINE OF lt_dynpfields.

  ls_dynpfields-fieldname   = fieldname.
  IF line IS NOT INITIAL.
    ls_dynpfields-stepl       = line.
  ENDIF.
  APPEND ls_dynpfields TO lt_dynpfields.
  CLEAR ls_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      request              = 'A'
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  LOOP AT lt_dynpfields INTO ls_dynpfields.
    CASE ls_dynpfields-fieldname.
      WHEN fieldname.
        IF ls_dynpfields-stepl = line.
          fc_value  = ls_dynpfields-fieldvalue.
          EXIT.
        ELSE.
          fc_value  = ls_dynpfields-fieldvalue.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_DYNP_VALUE_READ

*&---------------------------------------------------------------------*
*&      Form  F4CALLBACK
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                    " F4CALLBACK

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
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
    FROM t001w
    INTO CORRESPONDING FIELDS OF TABLE gt_t001w.

  SELECT *
    FROM t001l
    INTO CORRESPONDING FIELDS OF TABLE gt_t001l.

  SELECT *
    FROM t156t
    INTO CORRESPONDING FIELDS OF TABLE gt_t156t
    WHERE spras = sy-langu
      AND bwart IN ('311', '325', '501').
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data  USING    fu_row.
  DATA : ls_t001l LIKE LINE OF gt_t001l,
         ls_t001w LIKE LINE OF gt_t001w,
         ls_t156t LIKE LINE OF gt_t156t.

  DATA : material  TYPE bapimatdoa,
         lt_return TYPE STANDARD TABLE OF bapiret2,
         ls_return LIKE LINE OF lt_return,
         return    TYPE bapireturn.

  DATA : lv_message(100).

  IF fu_row IS INITIAL.
    IF gs_head-werks IS NOT INITIAL AND
      gs_head-lgort IS NOT INITIAL.
      CLEAR ls_t001l.
      READ TABLE gt_t001l INTO ls_t001l
                          WITH KEY werks = gs_head-werks
                                   lgort = gs_head-lgort.
      IF sy-subrc <> 0.
        gs_btn-lgort  = icon_led_red.
        PERFORM f_add_error_message USING '' 'Sloc' gs_head-lgort
                                          'not supported'
                                          '(check your entry)' '' 'LGORT'.
      ELSE.
        PERFORM f_del_error_message USING '' 'LGORT'.
        gs_head-lgofr = ls_t001l-lgobe.
      ENDIF.
    ENDIF.

    IF gs_head-werks IS NOT INITIAL AND
      gs_head-umlgo IS NOT INITIAL.
      CLEAR ls_t001l.
      READ TABLE gt_t001l INTO ls_t001l
                          WITH KEY werks = gs_head-werks
                                   lgort = gs_head-umlgo.
      IF sy-subrc <> 0.
        gs_btn-umlgo  = icon_led_red.
        PERFORM f_add_error_message USING '' 'Sloc' gs_head-umlgo
                                          'not supported'
                                          '(check your entry)' '' 'UMLGO'.
      ELSE.
        PERFORM f_del_error_message USING '' 'UMLGO'.
        gs_head-lgoto = ls_t001l-lgobe.
      ENDIF.
    ENDIF.

    IF gs_head-werks IS NOT INITIAL.
      CLEAR ls_t001w.
      READ TABLE gt_t001w INTO ls_t001w
                          WITH KEY werks = gs_head-werks.
      IF sy-subrc <> 0.
        gs_btn-werks  = icon_led_red.
        PERFORM f_add_error_message USING '' 'Plant' gs_head-werks
                                          'not supported'
                                          '(check your entry)' '' 'WERKS'.
      ELSE.
        PERFORM f_del_error_message USING '' 'WERKS'.
        gs_head-name1 = ls_t001w-name1.
        gs_head-name2 = ls_t001w-name2.
      ENDIF.
    ENDIF.

    IF gs_head-bwart IS NOT INITIAL.
      CLEAR ls_t156t.
      READ TABLE gt_t156t INTO ls_t156t
                          WITH KEY bwart = gs_head-bwart.
      IF sy-subrc <> 0.
        gs_btn-bwart  = icon_led_red.
        PERFORM f_add_error_message USING '' 'Movement Type ' gs_head-bwart
                                          'not supported'
                                          '(check your entry)' '' 'BWART'.
      ELSE.
        PERFORM f_del_error_message USING '' 'BWART'.
        gs_head-btext = ls_t156t-btext.
        CASE gs_head-bwart.
          WHEN '311' OR '501'.
            gs_head-status  = 'UU'.
          WHEN '325'.
            gs_head-status  = 'REJECT'.
        ENDCASE.
      ENDIF.
    ENDIF.
  ELSE.
    READ TABLE gt_items INTO gs_items INDEX fu_row.
    IF sy-subrc = 0.
      IF gs_items-icon <> icon_delete.
        PERFORM f_del_error_message USING fu_row 'MATNR'.
        CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
          EXPORTING
            material              = gs_items-matnr
            plant                 = gs_head-werks
          IMPORTING
            material_general_data = material
            return                = return.

        IF return-type = 'S'.
          gs_items-maktx  = material-matl_desc.
          gs_items-meins  = material-base_uom.
        ELSE.
          IF gs_items-icon <> icon_delete.
            gs_items-icon = icon_led_red.
            PERFORM f_add_error_message USING return '' '' '' ''
                                              fu_row 'MATNR'.
          ENDIF.
        ENDIF.

        IF gs_items-charg IS NOT INITIAL AND gs_head-bwart NE '501'.
          PERFORM f_del_error_message USING fu_row 'CHARG'.
          CALL FUNCTION 'BAPI_BATCH_GET_DETAIL'
            EXPORTING
              material = gs_items-matnr
              batch    = gs_items-charg
              plant    = gs_head-werks
            TABLES
              return   = lt_return.

          IF lt_return[] IS NOT INITIAL.
            IF gs_items-icon <> icon_delete.
              gs_items-icon = icon_led_red.
              LOOP AT lt_return INTO ls_return.
                PERFORM f_add_error_message USING ls_return '' '' '' ''
                                                  fu_row 'CHARG'.
              ENDLOOP.
            ENDIF.
          ENDIF.

          PERFORM f_batch_detail USING gs_items-matnr gs_items-charg gs_head-werks
                                 CHANGING gs_items-manufacture.
        ENDIF.

        IF gs_items-erfmg IS NOT INITIAL
          AND gs_items-charg IS NOT INITIAL AND gs_head-bwart NE '501'.
          CLEAR lv_message.
          PERFORM f_stock_checking USING gs_items-matnr gs_head-werks
                                         gs_head-lgort gs_items-charg
                                         gs_items-erfmg gs_items-meins
                                   CHANGING lv_message.
          IF gs_items-icon <> icon_delete.
            IF lv_message IS NOT INITIAL.
              gs_items-icon = icon_led_red.
              PERFORM f_add_error_message USING '' 'Only' lv_message
                                                gs_items-matnr 'available'
                                                fu_row 'CHARG'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_add_error_message  USING    fs_return
                                   fu_v1 fu_v2 fu_v3 fu_v4
                                   fu_row fu_field.

  DATA : ls_error  LIKE LINE OF gt_error,
         ls_return TYPE bapireturn.

  IF fs_return IS INITIAL.
    ls_error-type         = 'E'.
    ls_error-id           = 'ZAB'.
    ls_error-number       = '000'.
    ls_error-message_v1   = fu_v1.
    ls_error-message_v2   = fu_v2.
    ls_error-message_v3   = fu_v3.
    ls_error-message_v4   = fu_v4.
  ELSE.
    CASE fu_field.
      WHEN 'MATNR' OR 'BAPI'.
        ls_return             = fs_return.
        ls_error-type         = 'E'.
        ls_error-id           = ls_return-code(2).
        ls_error-number       = ls_return-code+2(3).
        ls_error-message      = ls_return-message.
        ls_error-message_v1   = ls_return-message_v1.
        ls_error-message_v2   = ls_return-message_v2.
        ls_error-message_v3   = ls_return-message_v3.
        ls_error-message_v4   = ls_return-message_v4.
      WHEN OTHERS.
        ls_error             = fs_return.
    ENDCASE.
  ENDIF.
  ls_error-row          = fu_row.
  ls_error-field        = fu_field.
  APPEND ls_error TO gt_error.
  CLEAR ls_error.
ENDFORM.                    " F_ADD_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_DEL_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_del_error_message  USING    fu_row fu_field.
  DATA : lv_field(20),
         ls_error   LIKE LINE OF gt_error.

  FIELD-SYMBOLS <fs> TYPE any.

  IF fu_row IS INITIAL.
    CONCATENATE 'GS_BTN-' fu_field INTO lv_field.
    ASSIGN (lv_field) TO <fs>.
    CLEAR <fs>.

    DELETE gt_error WHERE row   = fu_row
                      AND field = fu_field.
  ELSE.
    DELETE gt_error WHERE row   = fu_row
                      AND field = fu_field.
    CLEAR ls_error.
    READ TABLE gt_error INTO ls_error
                        WITH KEY row    = fu_row
                                 field  = fu_field.
    IF sy-subrc <> 0.
      gs_items-icon = icon_led_green.
      MODIFY gt_items FROM gs_items INDEX fu_row
                                    TRANSPORTING icon.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DEL_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
FORM f_display_message  USING    fu_field fu_row.
  DATA : lt_error TYPE STANDARD TABLE OF bapiret2,
         ls_error LIKE LINE OF gt_error,
         ls_items LIKE LINE OF gt_items.

  IF fu_row IS INITIAL.
    LOOP AT gt_error INTO ls_error WHERE field = fu_field.
      APPEND ls_error TO lt_error.
      CLEAR ls_error.
    ENDLOOP.
  ELSE.
    READ TABLE gt_items INTO ls_items INDEX fu_row.
    IF sy-subrc = 0.
      IF ls_items-icon = icon_delete.
        CLEAR ls_items-icon.
        MODIFY gt_items FROM ls_items INDEX fu_row
                                      TRANSPORTING icon.
      ELSE.
        LOOP AT gt_error INTO ls_error WHERE row = fu_row.
          APPEND ls_error TO lt_error.
          CLEAR ls_error.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lt_error[] IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_error.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        i_bapiret2_tab = lt_error.
  ENDIF.
ENDFORM.                    " F_DISPLAY_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position USING fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_F4_BATCH
*&---------------------------------------------------------------------*
FORM f_f4_batch .
  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : ls_mchb  LIKE LINE OF gt_mchb,
         ls_items LIKE LINE OF gt_items,
         lv_subrc TYPE sy-subrc,
         lv_werks TYPE mchb-werks,
         lv_matnr TYPE mchb-matnr,
         lv_lgort TYPE mchb-lgort,
         lv_charg TYPE mchb-charg,
         lv_field TYPE help_info-dynprofld,
         lv_line  TYPE i.

  CLEAR : dynpfields[], dynpfields.

  GET CURSOR FIELD lv_field LINE lv_line.

  READ TABLE gt_items INTO ls_items INDEX lv_line.

  PERFORM f_dynp_value_read USING 'GS_HEAD-WERKS' ''
                            CHANGING lv_werks.

  lv_line = lv_line + tc_items-top_line - 1.
  PERFORM f_dynp_value_read USING 'GS_ITEMS-MATNR' lv_line
                            CHANGING lv_matnr.
  PERFORM f_dynp_value_read USING 'GS_ITEMS-LGORT' lv_line
                            CHANGING lv_lgort.

  IF lv_werks IS NOT INITIAL AND
    lv_matnr IS NOT INITIAL AND
    lv_lgort IS NOT INITIAL.
    PERFORM f_get_batch USING lv_werks lv_matnr lv_lgort.

    ASSIGN gt_mchb[] TO <fs_tab>.

    CLEAR lv_subrc.
    PERFORM f_value_request TABLES return_tab
                            USING 'CHARG' lv_field
                            CHANGING lv_subrc.

    IF lv_subrc = 0.
      READ TABLE return_tab INTO ls_return INDEX 1.
      IF sy-subrc = 0.
        lv_charg  = ls_return-fieldval.
        CLEAR ls_mchb.
        READ TABLE gt_mchb INTO ls_mchb
                           WITH KEY matnr = lv_matnr
                                    werks = lv_werks
                                    lgort = lv_lgort
                                    charg = lv_charg.
        IF sy-subrc = 0.
          PERFORM f_dynpfield TABLES dynpfields
                              USING lv_field ls_mchb-charg ''.
        ENDIF.

        PERFORM f_dyn_values_update.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_F4_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_GET_BATCH
*&---------------------------------------------------------------------*
FORM f_get_batch  USING    fu_werks fu_matnr fu_lgort.
  SELECT *
    FROM mchb
    INTO CORRESPONDING FIELDS OF TABLE gt_mchb
    WHERE matnr = fu_matnr
      AND werks = fu_werks
      AND lgort = fu_lgort.
ENDFORM.                    " F_GET_BATCH

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data  USING    fu_line.
  DATA : ls_items  LIKE LINE OF gt_items.

  LOOP AT gt_items INTO ls_items WHERE mark IS NOT INITIAL.
    IF ls_items-icon = icon_led_red.
      DELETE gt_error WHERE row = fu_line.
    ENDIF.

    ls_items-icon  = icon_delete.
    MODIFY gt_items FROM ls_items
                    TRANSPORTING icon.

    CLEAR ls_items.
  ENDLOOP.
ENDFORM.                    " F_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_RESERVATION_PREPARE
*&---------------------------------------------------------------------*
FORM f_reservation_prepare .
  DATA : ls_items  LIKE LINE OF gt_items,
         ls_xitems LIKE LINE OF reservation_items.

  PERFORM f_validate_data USING ''.

  reservation_header-plant       = gs_head-werks.
  reservation_header-res_date    = sy-datum.
  reservation_header-created_by  = sy-uname.
  reservation_header-move_type   = gs_head-bwart.
  reservation_header-move_plant  = gs_head-werks.
  reservation_header-move_stloc  = gs_head-umlgo.
  reservation_header-gr_rcpt     = sy-uname.

  PERFORM f_header_print.
  PERFORM f_number_get_next CHANGING gs_prth-bstbno.

  LOOP AT gt_items INTO ls_items WHERE icon <> icon_delete.
    IF ls_items-icon = space.
      PERFORM f_validate_data USING ls_items-rspos.
    ENDIF.
    ls_xitems-material   = ls_items-matnr.
    ls_xitems-plant      = gs_head-werks.
    ls_xitems-store_loc  = gs_head-lgort.
    ls_xitems-batch      = ls_items-charg.
    ls_xitems-quantity   = ls_items-erfmg.
    ls_xitems-unit       = ls_items-meins.
    ls_xitems-req_date   = sy-datum.
    ls_xitems-unload_pt  = gs_prth-bstbno.
    ls_xitems-short_text = ls_items-text.
    APPEND ls_xitems TO reservation_items.
    CLEAR ls_xitems.

    PERFORM f_detail_print USING ls_items.
  ENDLOOP.
ENDFORM.                    " F_RESERVATION_PREPARE

*&---------------------------------------------------------------------*
*&      Form  F_RESERVATION_PROCESS
*&---------------------------------------------------------------------*
FORM f_reservation_process .
  DATA : ls_return    LIKE LINE OF return.

  IF gt_error[] IS INITIAL.
    CALL FUNCTION 'BAPI_RESERVATION_CREATE'
      EXPORTING
        reservation_header = reservation_header
        no_commit          = 'X'
        movement_auto      = 'X'
      IMPORTING
        reservation        = reservation
      TABLES
        reservation_items  = reservation_items
        return             = return.

    IF reservation IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      gs_prth-rsnum = reservation.
    ELSE.
      IF reservation_items[] IS INITIAL.
        MESSAGE s000(zab) WITH 'No data processed' DISPLAY LIKE 'E'.
      ELSE.
        READ TABLE return INTO ls_return INDEX 1.
        IF sy-subrc = 0.
          PERFORM f_add_error_message USING ls_return '' '' '' ''
                                            '' 'BAPI'.
          PERFORM f_display_message USING 'BAPI' ''.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RESERVATION_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
FORM f_clear_data .
  CLEAR : gt_head[], gt_head, gs_head, gt_items[], gs_items, dynpfields[],
          dynpfields, gt_sloc[], gt_sloc, gt_mchb[], gt_mchb, gt_error[],
          gt_error, gs_btn, ok_code, fitems, gv_isi.

  CLEAR : reservation_header, reservation_items[], reservation_items,
          return[], return, reservation.
ENDFORM.                    " F_CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form USING fu_flag.
  DATA : lv_formname       TYPE tdsfname,
         lv_funcname       TYPE tdsfname,
         ls_control_option TYPE ssfctrlop,
         ls_output_option  TYPE ssfcompop.

  IF gs_prth IS NOT INITIAL.
    lv_formname = 'ZTSPMMF001'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = lv_formname
      IMPORTING
        fm_name            = lv_funcname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CASE fu_flag.
      WHEN 'PREV'.
        ls_output_option-tdnoprint  = 'X'.
      WHEN 'PRINT'.
        ls_control_option-no_dialog = 'X'.
        ls_output_option-tdnewid    = 'X'.
        ls_output_option-tdimmed    = 'X'.
    ENDCASE.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = ls_control_option
        output_options     = ls_output_option
        gs_head            = gs_prth
      TABLES
        gt_detl            = gt_prtd
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT
*&---------------------------------------------------------------------*
FORM f_prepare_print .
  DATA : ls_items   LIKE LINE OF gt_items.

  PERFORM f_validate_data USING ''.
  PERFORM f_header_print.
  LOOP AT gt_items INTO ls_items WHERE icon <> icon_delete.
    IF ls_items-icon = space.
      PERFORM f_validate_data USING ls_items-rspos.
    ENDIF.
    ls_items-maktx        = ls_items-maktx.
    ls_items-meins        = ls_items-meins.
    PERFORM f_batch_detail USING ls_items-matnr ls_items-charg gs_head-werks
                           CHANGING ls_items-manufacture.
    PERFORM f_detail_print USING ls_items.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_PRINT
*&---------------------------------------------------------------------*
FORM f_header_print .
  DATA : ls_t001w LIKE LINE OF gt_t001w,
         ls_t001l LIKE LINE OF gt_t001l.

  CLEAR : gs_prth, gt_prtd[].

  gs_prth-werks   = gs_head-werks.
  gs_prth-name2   = gs_head-name2.
  TRANSLATE gs_prth-name2 TO UPPER CASE.
  gs_prth-name1   = gs_head-name1.
  TRANSLATE gs_prth-name1 TO UPPER CASE.

  gs_prth-lgort   = gs_head-lgort.
  gs_prth-lgofr   = gs_head-lgofr.

  gs_prth-umlgo   = gs_head-umlgo.
  gs_prth-lgoto   = gs_head-lgoto.

  IF gs_head-werks = '1900' AND
    gs_head-bwart = '501'.
    gs_prth-lgofr   = 'WH Production'.
    gs_prth-lgoto   = 'WH Limbah'.
  ENDIF.

  gs_prth-budat   = sy-datum.
  gs_prth-bwart   = gs_head-bwart.
  gs_prth-status  = gs_head-status.
ENDFORM.                    " F_HEADER_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL-PRINT
*&---------------------------------------------------------------------*
FORM f_detail_print  USING    fs_items  LIKE LINE OF gt_items.
  DATA : ls_prtd    LIKE LINE OF gt_prtd.

  ls_prtd-rspos   = fs_items-rspos.
  ls_prtd-matnr   = fs_items-matnr.
  ls_prtd-maktx   = fs_items-maktx.
  ls_prtd-meins   = fs_items-meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fs_items-meins
    IMPORTING
      output         = ls_prtd-erfme
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  ls_prtd-charg   = fs_items-charg.
  ls_prtd-erfmg   = fs_items-erfmg.
  WRITE ls_prtd-erfmg TO ls_prtd-erfmgt UNIT ls_prtd-meins.
  CONDENSE ls_prtd-erfmgt NO-GAPS.
  PERFORM f_batch_detail USING fs_items-matnr fs_items-charg gs_head-werks
                       CHANGING ls_prtd-manufacture.
  ls_prtd-text        = fs_items-text.
  APPEND ls_prtd TO gt_prtd.
  CLEAR ls_prtd.
ENDFORM.                    " F_DETAIL-PRINT

*&---------------------------------------------------------------------*
*&      Form  F_STOCK_CHECKING
*&---------------------------------------------------------------------*
FORM f_stock_checking  USING    fu_matnr fu_werks fu_lgort fu_charg
                                fu_erfmg fu_meins
                       CHANGING fc_message.
  DATA : ls_mchb      TYPE mchb,
         lv_stock     TYPE mchb-clabs,
         lv_meins(10).

  SELECT SINGLE *
    FROM mchb
    INTO CORRESPONDING FIELDS OF ls_mchb
    WHERE matnr = fu_matnr
      AND werks = fu_werks
      AND lgort = fu_lgort
      AND charg = fu_charg.

  CASE gs_head-bwart.
    WHEN '311'.
      lv_stock        = ls_mchb-clabs.
    WHEN '325'.
      lv_stock  = ls_mchb-cspem.
  ENDCASE.

  IF fu_erfmg > lv_stock.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = fu_meins
      IMPORTING
        output         = lv_meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    WRITE lv_stock TO fc_message UNIT fu_meins.
    CONDENSE fc_message NO-GAPS.
    CONCATENATE fc_message lv_meins 'at' INTO fc_message
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_STOCK_CHECKING

*&---------------------------------------------------------------------*
*&      Form  F_NUMBER_GET_NEXT
*&---------------------------------------------------------------------*
FORM f_number_get_next  CHANGING fc_bstbno.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZBSTB'
      subobject               = gs_head-werks
    IMPORTING
      number                  = fc_bstbno
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
ENDFORM.                    " F_NUMBER_GET_NEXT

*&---------------------------------------------------------------------*
*&      Form  F_REPRINT
*&---------------------------------------------------------------------*
FORM f_reprint .
  DATA : ls_resb  LIKE LINE OF gt_resb,
         lv_head,
         ls_t001l LIKE LINE OF gt_t001l,
         ls_t001w LIKE LINE OF gt_t001w,
         ls_prtd  LIKE LINE OF gt_prtd.

  DATA : material TYPE bapimatdoa,
         return   TYPE bapireturn.

  CLEAR : gs_prth, gt_prtd[].

  SELECT *
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE gt_resb
    WHERE rsnum = gs_head-rsnum.

  LOOP AT gt_resb INTO ls_resb.
    IF lv_head IS INITIAL.
      lv_head = 'X'.

      gs_prth-werks   = ls_resb-werks.
      CLEAR ls_t001w.
      READ TABLE gt_t001w INTO ls_t001w
                          WITH KEY werks = ls_resb-werks.
      IF sy-subrc = 0.
        gs_prth-name2   = ls_t001w-name2.
        TRANSLATE gs_prth-name2 TO UPPER CASE.
        gs_prth-name1   = ls_t001w-name1.
        TRANSLATE gs_prth-name1 TO UPPER CASE.
      ENDIF.

      gs_prth-budat = ls_resb-bdter.
      gs_prth-lgort = ls_resb-lgort.
      CLEAR ls_t001l.
      READ TABLE gt_t001l INTO ls_t001l
                    WITH KEY werks = ls_resb-werks
                             lgort = ls_resb-lgort.
      IF sy-subrc = 0.
        gs_prth-lgofr = ls_t001l-lgobe.
      ENDIF.

      gs_prth-umlgo = ls_resb-umlgo.
      CLEAR ls_t001l.
      READ TABLE gt_t001l INTO ls_t001l
                    WITH KEY werks = ls_resb-werks
                             lgort = ls_resb-umlgo.
      IF sy-subrc = 0.
        gs_prth-lgoto = ls_t001l-lgobe.
      ENDIF.

      IF ls_resb-werks = '1900' AND
        ls_resb-bwart = '501'.
        gs_prth-lgofr   = 'WH Production'.
        gs_prth-lgoto   = 'WH Limbah'.
      ENDIF.

      gs_prth-bstbno  = ls_resb-ablad.
      gs_prth-rsnum   = ls_resb-rsnum.
      gs_prth-bwart   = ls_resb-bwart.
    ENDIF.

    ls_prtd-rspos   = ls_resb-rspos.
    ls_prtd-matnr   = ls_resb-matnr.

    CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
      EXPORTING
        material              = ls_resb-matnr
        plant                 = ls_resb-werks
      IMPORTING
        material_general_data = material
        return                = return.

    IF sy-subrc = 0.
      ls_prtd-maktx  = material-matl_desc.
      ls_prtd-meins  = material-base_uom.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = ls_prtd-meins
      IMPORTING
        output         = ls_prtd-erfme
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    ls_prtd-charg   = ls_resb-charg.
    ls_prtd-erfmg   = ls_resb-erfmg.
    WRITE ls_prtd-erfmg TO ls_prtd-erfmgt UNIT ls_prtd-meins.
    CONDENSE ls_prtd-erfmgt NO-GAPS.

    PERFORM f_batch_detail USING ls_resb-matnr ls_resb-charg ls_resb-werks
                           CHANGING ls_prtd-manufacture.

    ls_prtd-bwart   = ls_resb-bwart.
    CASE ls_resb-bwart.
      WHEN '311' OR '501'.
        gs_prth-status   = 'UU'.
      WHEN '325'.
        gs_prth-status   = 'REJECT'.
    ENDCASE.

    ls_prtd-text    = ls_resb-sgtxt.
    APPEND ls_prtd TO gt_prtd.
    CLEAR ls_prtd.
  ENDLOOP.
ENDFORM.                    " F_REPRINT

*&---------------------------------------------------------------------*
*&      Form  F_BATCH_DETAIL
*&---------------------------------------------------------------------*
FORM f_batch_detail  USING    fu_matnr fu_charg fu_werks
                     CHANGING fc_manufacture.

  DATA : cob    TYPE STANDARD TABLE OF clbatch,
         ls_cob LIKE LINE OF cob.

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
                   WITH KEY atnam = 'ZMF'.
    IF sy-subrc = 0.
      fc_manufacture = ls_cob-atwtb.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_BATCH_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_RESB
*&---------------------------------------------------------------------*
FORM f_check_resb .
  DATA: ls_resb TYPE resb.

  SELECT SINGLE * INTO ls_resb
    FROM resb WHERE rsnum = p_rsnum.

  IF sy-subrc = 0.
    IF ls_resb-lgort(1) = '2' OR
      ls_resb-lgort(1) = '6'.
    ELSE.
      MESSAGE 'For S.Loc "2*" or "6*"' TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'Reservation Number does not Exist' TYPE 'E'.
  ENDIF.
ENDFORM.                    " F_CHECK_RESB

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_BSTB
*&---------------------------------------------------------------------*
FORM f_cancel_bstb .
  DATA: lt_bapireturn TYPE bapiret2 OCCURS 0 WITH HEADER LINE,
        lv_msg(50).

  CALL FUNCTION 'BAPI_RESERVATION_DELETE'
    EXPORTING
      reservation = p_rsnum
    TABLES
      return      = lt_bapireturn[]
    EXCEPTIONS
      OTHERS      = 1.

  IF lt_bapireturn[] IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CONCATENATE 'BSTB Reservation' p_rsnum 'Canceled'
      INTO lv_msg SEPARATED BY space.
    MESSAGE lv_msg TYPE 'S'.

  ELSE.
    READ TABLE lt_bapireturn WITH KEY type  = 'E'
                             TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      CONCATENATE 'BSTB Reservation' p_rsnum 'Canceled'
        INTO lv_msg SEPARATED BY space.
      MESSAGE lv_msg TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CANCEL_BSTB
