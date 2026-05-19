*----------------------------------------------------------------------*
*   INCLUDE ZF_BANKCASH_PVF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  SELECT *
    FROM zfidt014
    INTO CORRESPONDING FIELDS OF TABLE gt_014
    WHERE bukrs = pa_bukrs.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  PERFORM f_get_bkpf.

  CHECK gt_bkpf[] IS NOT INITIAL.

  PERFORM f_get_bseg.

ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES gt_out.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  CASE 'X'.
    WHEN ra_kr.
    WHEN ra_re.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' ''.
    WHEN ra_sa.
    WHEN ra_krre.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.

  PERFORM f_fieldcatg USING ft_report:
    'BELNR' 'BKPF' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PAYFOR' '' '' '' '25' 'Payment for' '' '' '' '' '' '' '' ''
    '' '',
    'ACCOUNT' '' '' '' '10' 'Account' '' '' '' '' '' '' '' '' '' '',
    'DESCRIPTION' '' '' '' '20' 'Description' '' '' '' '' '' ''
    '' '' '' '',
    'BUDAT' 'BKPF' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BLDAT' 'BKPF' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KURSF' 'BKPF' 'KURSF' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WAERS' 'BKPF' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BKTXT' 'BKPF' 'BKTXT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'XBLNR' 'BKPF' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR1' 'BSEG' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'BSEG' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KOSTL' 'BSEG' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WRBTR1' 'BSEG' 'WRBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BELNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_out, gt_out[], gt_error[], gt_error.
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'TOEXECUTE'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  DATA : lwa_bseg LIKE gt_bseg,
         lwa_out  LIKE gt_out.

  gt_tax[] = gt_bseg[].

  CASE 'X'.
    WHEN ra_kr.
      IF pa_bukrs = '8330' OR pa_bukrs = '8040'.
        CASE pa_bukrs.
          WHEN '8330'.
            DELETE gt_tax WHERE hkont NE '0315100040' AND
                                hkont NE '0315100041' AND
                                hkont NE '0315100020'.
          WHEN '8040'.
            DELETE gt_tax WHERE koart NE 'K'.
          WHEN OTHERS.
        ENDCASE.
      ELSE.
        DELETE gt_tax WHERE koart EQ 'K'
                         OR xbilk NE 'X'.
*        IF pa_bukrs = '8360'.
*          DELETE gt_tax WHERE hkont NE '0142200220'
*                            AND shkzg EQ 'S'.
*        ENDIF.
      ENDIF.
      IF pa_bukrs = '8360'.
        DELETE gt_tax WHERE bukrs = pa_bukrs.
      ENDIF.
    WHEN ra_re.
*      IF pa_bukrs = '8040'.
*        DELETE gt_tax WHERE hkont EQ '0315100040' OR
*                            hkont EQ '0315100020'.
*      ELSE.
      DELETE gt_tax WHERE koart EQ 'K'
                       OR buzid NE 'S'
                       OR xbilk NE 'X'.
*      ENDIF.
      IF pa_bukrs = '8040'.
        DELETE gt_tax WHERE hkont EQ '0315100040' OR
                            hkont EQ '0315100041' OR
                            hkont EQ '0315100020' OR
                            hkont EQ '0314600000'.
      ENDIF.
      IF pa_bukrs = '8360'.
        DELETE gt_tax WHERE bukrs = pa_bukrs.
      ENDIF.
    WHEN ra_sa.
    WHEN ra_krre.
      LOOP AT gt_tax.
        CLEAR gt_bkpf.
        READ TABLE gt_bkpf WITH KEY belnr = gt_tax-belnr.
        CASE gt_bkpf-blart.
          WHEN 'KR'.
            IF gt_tax-koart = 'K' OR
              gt_tax-buzid <> 'X'.
              DELETE gt_tax.
            ENDIF.
          WHEN 'RE'.
            IF gt_tax-koart = 'K' OR
              gt_tax-buzid <> 'S' OR
              gt_tax-xbilk <> 'X'.
              DELETE gt_tax.
            ENDIF.
        ENDCASE.
      ENDLOOP.
      DELETE gt_tax WHERE bukrs = pa_bukrs.
  ENDCASE.

  LOOP AT gt_bkpf.
    lwa_out-belnr  = gt_bkpf-belnr.
    lwa_out-budat  = gt_bkpf-budat.
    lwa_out-bldat  = gt_bkpf-bldat.
    lwa_out-waers  = gt_bkpf-waers.
    lwa_out-bktxt  = gt_bkpf-bktxt.
    lwa_out-xblnr  = gt_bkpf-xblnr.
    IF gt_bkpf-waers NE 'IDR'.
      lwa_out-kursf   = gt_bkpf-kursf.
    ENDIF.
    READ TABLE gt_bseg WITH KEY belnr = gt_bkpf-belnr
                                gvtyp = 'X'.
    IF sy-subrc EQ 0.
      lwa_out-kostl   = gt_bseg-kostl.
    ENDIF.

    LOOP AT gt_bseg INTO lwa_bseg WHERE belnr EQ gt_bkpf-belnr.
      CASE 'X'.
        WHEN ra_kr.
          IF lwa_bseg-koart EQ 'K'.
            PERFORM f_proses_kr TABLES gt_tax
                                USING lwa_bseg '1'
                                CHANGING lwa_out.
          ELSEIF lwa_bseg-xbilk EQ 'X'.
            PERFORM f_proses_kr TABLES gt_tax
                                USING lwa_bseg '2'
                                CHANGING lwa_out.
          ELSE.
            CONTINUE.
          ENDIF.

        WHEN ra_re.
          IF lwa_bseg-koart EQ 'K'.
            PERFORM f_proses_re TABLES gt_tax
                                USING lwa_bseg '1'
                                CHANGING lwa_out.
          ELSEIF ( lwa_bseg-buzid EQ 'S' OR lwa_bseg-buzid EQ 'T' )
                 AND lwa_bseg-xbilk EQ 'X'.
            PERFORM f_proses_re TABLES gt_tax
                                USING lwa_bseg '2'
                                CHANGING lwa_out.
          ELSE.
            CONTINUE.
          ENDIF.

        WHEN ra_sa.
*          IF pa_bukrs = '8190' AND
*             ( lwa_bseg-hkont = '0315100040' OR
*               lwa_bseg-hkont = '0315100041' ).
*            lwa_bseg-gvtyp = 'X'.
*          ENDIF.
          IF lwa_bseg-gvtyp EQ 'X'.
            PERFORM f_proses_sa USING lwa_bseg
                                CHANGING lwa_out.
            lwa_out-payfor  = gt_bkpf-bktxt.
          ELSE.
            CONTINUE.
          ENDIF.

        WHEN ra_krre.
          READ TABLE gt_bkpf WITH KEY belnr = lwa_bseg-belnr.
          CASE gt_bkpf-blart.
            WHEN 'KR'.
              IF lwa_bseg-koart EQ 'K'.
                PERFORM f_proses_kr TABLES gt_tax
                                    USING lwa_bseg '1'
                                    CHANGING lwa_out.
              ELSEIF lwa_bseg-xbilk EQ 'X'.
                PERFORM f_proses_kr TABLES gt_tax
                                    USING lwa_bseg '2'
                                    CHANGING lwa_out.
              ELSE.
                CONTINUE.
              ENDIF.

            WHEN 'RE'.
              IF lwa_bseg-koart EQ 'K'.
                PERFORM f_proses_re TABLES gt_tax
                                    USING lwa_bseg '1'
                                    CHANGING lwa_out.
              ELSEIF ( lwa_bseg-buzid EQ 'S' OR lwa_bseg-buzid EQ 'T' )
                     AND lwa_bseg-xbilk EQ 'X'.
                PERFORM f_proses_re TABLES gt_tax
                                    USING lwa_bseg '2'
                                    CHANGING lwa_out.
              ELSE.
                CONTINUE.
              ENDIF.
          ENDCASE.
      ENDCASE.

***** Cetakan DOD2
*****      IF pa_bukrs = '8360'.
*****        IF lwa_out-account = '0315100040'.
*****          CLEAR lwa_out.
*****        ELSE.
*****          PERFORM f_date_calculate USING lwa_bseg-zbd1t lwa_bseg-zfbdt
*****                                   CHANGING lwa_out-zfbdt.
*****          APPEND lwa_out TO gt_out.
*****        ENDIF.
*****      ELSE.
      APPEND lwa_out TO gt_out.
*****      ENDIF.
    ENDLOOP.
    CLEAR lwa_out.
  ENDLOOP.

  LOOP AT gt_out.
    IF gt_out-icon = icon_led_red.
      gt_out-check  = '2'.
    ELSE.
      gt_out-check  = '2'.
      ON CHANGE OF gt_out-belnr.
        CLEAR gt_out-check.
      ENDON.
    ENDIF.
    IF gt_out-shkzg = 'H'.
      gt_out-wrbtr1 = gt_out-wrbtr * -1.
    ELSE.
      gt_out-wrbtr1 = gt_out-wrbtr.
    ENDIF.
    MODIFY gt_out TRANSPORTING check wrbtr1.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA : lt_dynpread LIKE dynpread OCCURS 0 WITH HEADER LINE,
         lv_lines    TYPE i,
         lv_subrc    TYPE sy-subrc,
         lv_dynnr    TYPE sy-dynnr.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&PRNT'.
      CASE pa_bukrs.
        WHEN '8040'.
          PERFORM f_print_process USING 'PRINT' 'ZFBANKCASHTNP' ''.
        WHEN '8360'.
          PERFORM f_get_budat.
          PERFORM f_print_process USING 'PRINT' 'ZFBANKCASHKMM_NEW' ''.
        WHEN '8330'.
          PERFORM f_get_budat.
          CASE 'X'.
            WHEN ra_kr.
              PERFORM f_print_process USING 'PRINT' 'ZFBANKCASHKMM' ''.
            WHEN ra_re.
              PERFORM f_validate_one_time_vendor CHANGING lv_subrc lv_dynnr.
              IF lv_subrc = 0.
                CASE lv_dynnr.
                  WHEN '0500'.
                    PERFORM f_print_process USING 'PRINT' 'ZFBANKCASH' lv_dynnr.
                  WHEN '0501'.
                    PERFORM f_print_process USING 'PRINT' 'ZFBANKCASHKMM' lv_dynnr.
                ENDCASE.
              ELSE.
                MESSAGE s000(zab) WITH 'Process only for ONE TIME VENDOR' DISPLAY LIKE 'E'.
              ENDIF.
            WHEN OTHERS.
              PERFORM f_print_process USING 'PRINT' 'ZFBANKCASH' ''.
          ENDCASE.
        WHEN OTHERS.
          PERFORM f_print_process USING 'PRINT' 'ZFBANKCASH' ''.
      ENDCASE.
    WHEN '&POS'.
      PERFORM f_post_entries.
    WHEN '&LOG'.
      DESCRIBE TABLE gt_error LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO gt_error.
      ENDIF.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_error.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.

  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_GET_PARAMETERS
*&---------------------------------------------------------------------*
FORM f_get_parameters  USING    fu_value
                       CHANGING fc_value.
  CALL FUNCTION 'ACC_USER_PARAMETER_GET'
    EXPORTING
      i_param_id    = fu_value
    IMPORTING
      e_param_value = fc_value.
ENDFORM.                    " F_GET_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_mess(100).

  IF so_belnr[] IS INITIAL.
    PERFORM f_error_selection_screen USING 'BEL' ''.
  ENDIF.

  IF pa_bukrs IS INITIAL.
    PERFORM f_error_selection_screen USING 'BUK' ''.
  ELSEIF pa_bukrs <> '8360'.
    IF ra_krre IS NOT INITIAL.
      PERFORM f_error_selection_screen USING 'BUK' '1'.
    ENDIF.
  ENDIF.

  IF pa_gjahr IS INITIAL.
    PERFORM f_error_selection_screen USING 'GJA' ''.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
      LOOP AT SCREEN.
        IF screen-group1 = fu_group.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN '1'.
      lv_mess = 'You are not authorized'.
  ENDCASE.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_BKPF
*&---------------------------------------------------------------------*
FORM f_get_bkpf .
  DATA : lv_blart TYPE blart,
         lr_blart TYPE RANGE OF blart,
         ls_blart LIKE LINE OF lr_blart.

  CASE 'X'.
    WHEN ra_kr.
      lv_blart = 'KR'.
    WHEN ra_re.
      lv_blart = 'RE'.
    WHEN ra_sa.
      lv_blart = 'SA'.
    WHEN ra_krre.
      ls_blart-low    = 'KR'.
      ls_blart-sign   = 'I'.
      ls_blart-option = 'EQ'.
      APPEND ls_blart TO lr_blart.
      CLEAR ls_blart.
      ls_blart-low    = 'RE'.
      ls_blart-sign   = 'I'.
      ls_blart-option = 'EQ'.
      APPEND ls_blart TO lr_blart.
      CLEAR ls_blart.
  ENDCASE.

  IF lv_blart IS NOT INITIAL.
    SELECT bukrs belnr gjahr blart bldat budat xblnr bktxt waers kursf
      FROM bkpf
      INTO TABLE gt_bkpf
      WHERE bukrs EQ pa_bukrs
        AND belnr IN so_belnr
        AND gjahr EQ pa_gjahr
        AND blart EQ lv_blart
      ORDER BY PRIMARY KEY.
  ELSE.
    SELECT bukrs belnr gjahr blart bldat budat xblnr bktxt waers kursf
      FROM bkpf
      INTO TABLE gt_bkpf
      WHERE bukrs EQ pa_bukrs
        AND belnr IN so_belnr
        AND gjahr EQ pa_gjahr
        AND blart IN lr_blart
      ORDER BY PRIMARY KEY.
  ENDIF.
ENDFORM.                    " F_GET_BKPF

*&---------------------------------------------------------------------*
*&      Form  F_GET_BSEG
*&---------------------------------------------------------------------*
FORM f_get_bseg .
  DATA : lt_lfa1  LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
         lt_t001w LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
         lt_skat  LIKE gt_bseg OCCURS 0 WITH HEADER LINE.

*  IF pa_bukrs = '8040'.
*    SELECT bukrs belnr gjahr buzei buzid koart gsber wrbtr zuonr sgtxt
*           kostl hkont lifnr xbilk gvtyp shkzg
*      FROM bseg
*      INTO TABLE gt_bseg
*      FOR ALL ENTRIES IN gt_bkpf
*      WHERE bukrs EQ pa_bukrs
*        AND belnr EQ gt_bkpf-belnr
*        AND gjahr EQ pa_gjahr
*        AND zlspr EQ space.
*  ELSE.
  SELECT bukrs belnr gjahr buzei buzid koart gsber wrbtr zuonr sgtxt
         kostl hkont lifnr xbilk gvtyp shkzg zlspr zbd1t zfbdt zterm
         ebeln
    FROM bseg
    INTO TABLE gt_bseg
    FOR ALL ENTRIES IN gt_bkpf
    WHERE bukrs EQ pa_bukrs
      AND belnr EQ gt_bkpf-belnr
      AND gjahr EQ pa_gjahr
    ORDER BY PRIMARY KEY.
*  ENDIF.

*  IF pa_bukrs NE '8360'.
  DELETE gt_bseg WHERE hkont EQ '0142200220'.
*  ENDIF.

  IF pa_bukrs = '8330' OR pa_bukrs = '8040' OR pa_bukrs = '8010' OR pa_bukrs = '8360' OR pa_bukrs = '8190'.
    DELETE gt_bseg WHERE koart EQ 'A'.
  ENDIF.
  IF pa_bukrs = '8010' OR pa_bukrs = '8040'.
    DELETE gt_bseg WHERE hkont EQ '0122370000' OR hkont EQ '0314900000' OR hkont EQ '0142399000'
                      OR hkont EQ '0141110000' OR hkont EQ '0122310300'.
  ENDIF.

  SORT gt_bseg BY bukrs belnr gjahr buzei.
  lt_lfa1[] = gt_bseg[].
  DELETE lt_lfa1 WHERE koart NE 'K'.
  lt_t001w[] = gt_bseg[].
  SORT lt_t001w BY gsber.
  DELETE ADJACENT DUPLICATES FROM lt_t001w COMPARING gsber.

  lt_skat[] = gt_bseg[].
  CASE 'X'.
    WHEN ra_re OR ra_kr OR ra_krre.
*      IF pa_bukrs = '8360'.
*        DELETE lt_skat WHERE ( buzid NE 'S'
*                          AND buzid NE 'T' )
*                          OR xbilk NE 'X'.
*      ELSE.
      DELETE lt_skat WHERE buzid NE 'S'
                        OR xbilk NE 'X'.
*      ENDIF.
    WHEN ra_sa.
      DELETE lt_skat WHERE gvtyp NE 'X'.
  ENDCASE.

  IF lt_lfa1[] IS NOT INITIAL.
    SELECT lifnr name1
      FROM lfa1
      INTO TABLE gt_lfa1
      FOR ALL ENTRIES IN lt_lfa1
      WHERE lifnr EQ lt_lfa1-lifnr
      ORDER BY PRIMARY KEY.

    SELECT * INTO TABLE gt_zfbank_vendor
      FROM zfbank_vendor FOR ALL ENTRIES IN lt_lfa1
      WHERE bukrs = pa_bukrs
        AND lifnr EQ lt_lfa1-lifnr
      ORDER BY PRIMARY KEY.
  ENDIF.

  IF lt_t001w[] IS NOT INITIAL.
    SELECT werks adrc~name1 street
      FROM t001w JOIN adrc ON t001w~adrnr EQ adrc~addrnumber
      INTO TABLE gt_t001w
      FOR ALL ENTRIES IN lt_t001w
      WHERE werks EQ lt_t001w-gsber.
  ENDIF.

  IF lt_skat[] IS NOT INITIAL.
    SELECT saknr txt20
      FROM skat
      INTO TABLE gt_skat
      FOR ALL ENTRIES IN lt_skat
      WHERE spras EQ sy-langu
        AND ktopl EQ 'TSPC'
        AND saknr EQ lt_skat-hkont.
  ENDIF.
ENDFORM.                    " F_GET_BSEG

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_KR
*&---------------------------------------------------------------------*
FORM f_proses_kr  TABLES   ft_tax  STRUCTURE gt_bseg
                  USING    fwa_bseg STRUCTURE gt_bseg
                           fu_flag
                  CHANGING fwa_out STRUCTURE gt_out.

  DATA: lv_wrbtr LIKE ft_tax-wrbtr,
        ls_bseg  LIKE LINE OF gt_bseg.

  CLEAR: ft_tax,lv_wrbtr.

  fwa_out-lifnr   = fwa_bseg-lifnr.

  CASE fu_flag.
    WHEN '1'.
      fwa_out-account       = fwa_bseg-lifnr.
      fwa_out-description   = fwa_bseg-sgtxt.

*      IF pa_bukrs = '8360'.
*        LOOP AT ft_tax WHERE bukrs = fwa_bseg-bukrs
*                         AND belnr = fwa_bseg-belnr
*                         AND gjahr = fwa_bseg-gjahr.
*          IF ft_tax-shkzg = 'S'.
*            ft_tax-wrbtr = ft_tax-wrbtr * -1.
*          ENDIF.
*          ADD ft_tax-wrbtr TO lv_wrbtr.
*        ENDLOOP.
*      ELSE.
      READ TABLE ft_tax WITH KEY bukrs = fwa_bseg-bukrs
                                 belnr = fwa_bseg-belnr
                                 gjahr = fwa_bseg-gjahr.
*      ENDIF.

      IF pa_bukrs = '8330' OR pa_bukrs = '8040'.
        fwa_out-wrbtr         = fwa_bseg-wrbtr.
      ELSEIF pa_bukrs = '8360'.
        fwa_out-wrbtr         = fwa_bseg-wrbtr.
      ELSE.
        fwa_out-wrbtr         = fwa_bseg-wrbtr + ft_tax-wrbtr.
      ENDIF.

      IF pa_bukrs = '8330'.
        LOOP AT ft_tax WHERE bukrs = fwa_bseg-bukrs
                         AND belnr = fwa_bseg-belnr
                         AND gjahr = fwa_bseg-gjahr.
          IF ft_tax-shkzg = 'S'.
            ft_tax-wrbtr = ft_tax-wrbtr * -1.
          ENDIF.
          ADD ft_tax-wrbtr TO lv_wrbtr.
        ENDLOOP.
        fwa_out-wrbtr         = fwa_bseg-wrbtr + lv_wrbtr.
      ENDIF.

    WHEN '2'.
      fwa_out-description   = fwa_bseg-sgtxt.
      fwa_out-account       = fwa_bseg-hkont.

      READ TABLE gt_skat WITH KEY saknr = fwa_bseg-hkont.
      IF sy-subrc EQ 0.
        fwa_out-description = gt_skat-txt20.
      ENDIF.
*      IF pa_bukrs = '8360' AND
*        ( fwa_bseg-hkont = '0315100040' OR
*          fwa_bseg-hkont = '0315100042' OR
*          fwa_bseg-hkont = '0142200220' ).
*        SELECT SINGLE txt20
*          FROM skat
*          INTO fwa_out-description
*          WHERE spras = sy-langu
*            AND ktopl = 'TSPC'
*            AND saknr = fwa_bseg-hkont.
*      ENDIF.
      fwa_out-wrbtr     = fwa_bseg-wrbtr.
  ENDCASE.

  READ TABLE gt_lfa1 WITH KEY lifnr = fwa_bseg-lifnr.
  IF sy-subrc EQ 0.
    fwa_out-payfor  = gt_lfa1-name1.
    pa_name = fwa_out-payfor.
  ENDIF.

  CLEAR gt_zfbank_vendor.
  READ TABLE gt_zfbank_vendor WITH KEY bukrs = pa_bukrs
                                       lifnr = gt_lfa1-lifnr.
  pa_text = gt_zfbank_vendor-norek.

  fwa_out-zuonr1  = fwa_bseg-zuonr.
  fwa_out-gsber   = fwa_bseg-gsber.
  fwa_out-shkzg   = fwa_bseg-shkzg.
  fwa_out-zfbdt   = fwa_bseg-zfbdt.
ENDFORM.                    " F_PROSES_KR

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_PROCESS
*&---------------------------------------------------------------------*
FORM f_print_process  USING    fu_print
                               fu_formname TYPE tdsfname
                               fu_dynnr.
  DATA : lv_wrbtr           TYPE wrbtr,
         l_funcname         TYPE tdsfname,
         l_total_pages      TYPE tdsffpage,
         lwa_control_option TYPE ssfctrlop,
         lwa_output_option  TYPE ssfcompop,
         lwa_doc_info       TYPE ssfcrespd,
         lwa_output_info    TYPE ssfcrescl.

  DATA : lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE.

  DATA : lv_dynnr TYPE sy-dynnr,
         lv_subrc TYPE sy-subrc.

  CLEAR: gt_header, gt_detail[], gt_detail, gt_header[].

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_formname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE check NE 'X'.

  IF lt_out[] IS NOT INITIAL.
    CASE 'X'.
      WHEN ra_kr.
        CLEAR: gt_detail[], gt_detail.
        IF pa_bukrs = '8360' OR
          pa_bukrs = '8330'.
          CALL SELECTION-SCREEN 501 STARTING AT 10 10.
        ELSE.
          CALL SELECTION-SCREEN 500 STARTING AT 10 10.
        ENDIF.

        CHECK sy-subrc IS INITIAL.

        READ TABLE gt_bkpf INDEX 1.
        IF sy-subrc EQ 0.
          CLEAR: gt_detail[], gt_detail.
          PERFORM f_prepare_print TABLES lt_out
                                  USING gt_bkpf 'KR' ''.
        ENDIF.

        IF pa_bukrs = '8360'.
          CALL FUNCTION l_funcname
            EXPORTING
              control_parameters = lwa_control_option
              output_option      = lwa_output_option
              user_settings      = 'X'
              gt_header          = gt_header
            TABLES
              gt_detail          = gt_detail
              lines              = lines
            EXCEPTIONS
              formatting_error   = 1
              internal_error     = 2
              send_error         = 3
              user_canceled      = 4
              OTHERS             = 5.
        ELSE.
          CALL FUNCTION l_funcname
            EXPORTING
              control_parameters = lwa_control_option
              output_option      = lwa_output_option
              user_settings      = 'X'
              gt_header          = gt_header
            TABLES
              gt_detail          = gt_detail
            EXCEPTIONS
              formatting_error   = 1
              internal_error     = 2
              send_error         = 3
              user_canceled      = 4
              OTHERS             = 5.
        ENDIF.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN ra_re.
        CLEAR: gt_detail[], gt_detail.
        CASE pa_bukrs.
          WHEN '8360'.
            CALL SELECTION-SCREEN 501 STARTING AT 10 10.
          WHEN '8330'.
            CALL SELECTION-SCREEN fu_dynnr STARTING AT 10 10.
          WHEN OTHERS.
            CALL SELECTION-SCREEN 500 STARTING AT 10 10.
        ENDCASE.

        CHECK sy-subrc IS INITIAL.

        READ TABLE gt_bkpf INDEX 1.
        IF sy-subrc EQ 0.
          CLEAR: gt_detail[], gt_detail.
          PERFORM f_prepare_print TABLES lt_out
                                  USING gt_bkpf 'RE' fu_dynnr.
        ENDIF.

        IF pa_bukrs = '8360'.
          CALL FUNCTION l_funcname
            EXPORTING
              control_parameters = lwa_control_option
              output_option      = lwa_output_option
              user_settings      = 'X'
              gt_header          = gt_header
            TABLES
              gt_detail          = gt_detail
              lines              = lines
            EXCEPTIONS
              formatting_error   = 1
              internal_error     = 2
              send_error         = 3
              user_canceled      = 4
              OTHERS             = 5.
        ELSE.
          CALL FUNCTION l_funcname
            EXPORTING
              control_parameters = lwa_control_option
              output_option      = lwa_output_option
              user_settings      = 'X'
              gt_header          = gt_header
            TABLES
              gt_detail          = gt_detail
            EXCEPTIONS
              formatting_error   = 1
              internal_error     = 2
              send_error         = 3
              user_canceled      = 4
              OTHERS             = 5.
        ENDIF.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN ra_krre.
        CLEAR: gt_detail[], gt_detail.
*        CALL SELECTION-SCREEN 500 STARTING AT 10 10.
        CALL SCREEN 501 STARTING AT 10 10.

        CHECK sy-subrc IS INITIAL.

        READ TABLE gt_bkpf INDEX 1.
        IF sy-subrc EQ 0.
          CLEAR: gt_detail[], gt_detail.
          PERFORM f_prepare_print TABLES lt_out
                                  USING gt_bkpf 'KRRE' ''.
        ENDIF.

        CALL FUNCTION l_funcname
          EXPORTING
            control_parameters = lwa_control_option
            output_option      = lwa_output_option
            user_settings      = 'X'
            gt_header          = gt_header
          TABLES
            gt_detail          = gt_detail
            lines              = lines
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN OTHERS.
        LOOP AT lt_out.
          AT FIRST.
            lwa_control_option-no_close = 'X'.
          ENDAT.

          AT LAST.
            lwa_control_option-no_close = space.
          ENDAT.

          READ TABLE gt_bkpf WITH KEY belnr = lt_out-belnr.
          IF sy-subrc EQ 0.
            CLEAR: gt_detail[], gt_detail.
            PERFORM f_prepare_print TABLES gt_out
                                    USING gt_bkpf '' ''.
          ELSE.
            CONTINUE.
          ENDIF.

          IF pa_bukrs = '8360'.
            CALL FUNCTION l_funcname
              EXPORTING
                control_parameters = lwa_control_option
                output_option      = lwa_output_option
                user_settings      = 'X'
                gt_header          = gt_header
              TABLES
                gt_detail          = gt_detail
                lines              = lines
              EXCEPTIONS
                formatting_error   = 1
                internal_error     = 2
                send_error         = 3
                user_canceled      = 4
                OTHERS             = 5.
          ELSE.
            CALL FUNCTION l_funcname
              EXPORTING
                control_parameters = lwa_control_option
                output_option      = lwa_output_option
                user_settings      = 'X'
                gt_header          = gt_header
              TABLES
                gt_detail          = gt_detail
              EXCEPTIONS
                formatting_error   = 1
                internal_error     = 2
                send_error         = 3
                user_canceled      = 4
                OTHERS             = 5.
          ENDIF.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          lwa_control_option-no_open = 'X'.
        ENDLOOP.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_PRINT_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT
*&---------------------------------------------------------------------*
FORM f_prepare_print  TABLES   ft_out STRUCTURE gt_out
                      USING    fwa_bkpf STRUCTURE gt_bkpf
                               fu_proc fu_dynnr.
  DATA : lv_flag      TYPE i,
         lv_wrbtr     TYPE wrbtr,
         lv_tax       TYPE wrbtr,
         lwa_spell    LIKE spell,
         lv_langu     TYPE sy-langu,
         lv_matauang  TYPE ktext,
         exch_rate    LIKE bapi1093_0,
         return       LIKE bapiret1,
         ld_exch_rate TYPE p DECIMALS 2.

  DATA : lr_lifnr TYPE RANGE OF lifnr,
         ls_lifnr LIKE LINE OF lr_lifnr.

  DATA : lt_out        LIKE gt_out OCCURS 0 WITH HEADER LINE.

  CASE fu_proc.
    WHEN 'KR' OR 'RE'.
      gt_header-xblnr   = pa_xblnr.
      gt_header-belnr   = pa_belnr.
      CASE pa_bukrs.
        WHEN '8360'.
          gt_header-budat   = pa_budat + gv_zbd1t.
          gt_header-budat2  = gv_budat + gv_zbd1t.
        WHEN '8330'.
          gt_header-budat   = pa_budat + gv_zbd1t.
          gt_header-budat2  = gv_budat + gv_zbd1t.
        WHEN OTHERS.
          gt_header-budat   = pa_budat.
      ENDCASE.
      gt_header-bukrs   = pa_bukrs.
      gt_header-banktxt = pa_text.

      gt_header-waers = gt_bkpf-waers.

      LOOP AT ft_out.
        IF lv_flag IS INITIAL.
          lv_flag   = 1.
          READ TABLE gt_t001w WITH KEY werks = ft_out-gsber.
          gt_header-gsber      = ft_out-gsber.
          gt_header-name1_gsb  = gt_t001w-name1.
          gt_header-street_gsb = gt_t001w-street.
          gt_header-payfor     = ft_out-payfor.

          CASE pa_bukrs.
            WHEN '8360'.
              gt_header-payfor     = pa_name.
            WHEN '8330'.
              IF fu_proc = 'KR'.
                gt_header-payfor     = pa_name.
              ELSEIF fu_proc = 'RE'.
                ls_lifnr-sign   = 'I'.
                ls_lifnr-option = 'EQ'.
                ls_lifnr-low    = '9900000016'.
                APPEND ls_lifnr TO lr_lifnr.
                ls_lifnr-low    = '1900000722'.
                APPEND ls_lifnr TO lr_lifnr.
                ls_lifnr-low    = '0800000529'.
                APPEND ls_lifnr TO lr_lifnr.
                IF ft_out-lifnr IN lr_lifnr.
                  gt_header-payfor     = pa_name.
                ENDIF.
              ENDIF.
          ENDCASE.

          IF ft_out-gsber = '0401'.
            gt_header-name1_gsb  = 'PT. Tempo Natural Products'.
            gt_header-street_gsb = 'Kawasan Industri EJIP PLOT 2 - G2'.
          ENDIF.
        ENDIF.
        gt_detail-account     = ft_out-account.

        IF ft_out-gsber = '0401'.
          gt_detail-description = ft_out-xblnr.
          gt_detail-invoice     = ft_out-description.
        ELSE.
          gt_detail-description = ft_out-description.
          gt_detail-invoice     = ft_out-zuonr1.
        ENDIF.

        gt_detail-kostl       = ft_out-kostl.
        IF ft_out-shkzg EQ 'S'.
          ft_out-wrbtr  = ft_out-wrbtr * -1.
        ENDIF.
        IF ft_out-wrbtr LT 0.
          WRITE ft_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers NO-SIGN.
          CONDENSE gt_detail-zwrbtr.
          CONCATENATE '-' gt_detail-zwrbtr INTO gt_detail-zwrbtr.
        ELSE.
          WRITE ft_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers.
        ENDIF.
        ADD ft_out-wrbtr TO lv_wrbtr.
        APPEND gt_detail.
      ENDLOOP.

* Tax PPh
      LOOP AT gt_tax.
        READ TABLE ft_out WITH KEY belnr = gt_tax-belnr
                          TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
        READ TABLE gt_out WITH KEY belnr = gt_tax-belnr
                                   account = gt_tax-hkont.
        lt_out-account     = gt_out-account.
        IF gt_out-gsber = '0401'.
          CONTINUE.
          lt_out-description = gt_out-xblnr.
          lt_out-invoice     = gt_out-description.
        ELSE.
          lt_out-description = gt_out-description.
          lt_out-invoice     = gt_out-zuonr1.
        ENDIF.
        lt_out-kostl       = gt_out-kostl.
        lt_out-wrbtr       = gt_out-wrbtr.
        IF gt_out-shkzg EQ 'H'.
          lt_out-wrbtr  = gt_out-wrbtr * -1.
        ENDIF.
        COLLECT lt_out.
      ENDLOOP.

      LOOP AT lt_out.
        gt_detail-account     = lt_out-account.
        gt_detail-description = lt_out-description.
        gt_detail-invoice     = lt_out-invoice.
        gt_detail-kostl       = lt_out-kostl.
        IF lt_out-wrbtr LT 0.
          WRITE lt_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers NO-SIGN.
          CONDENSE gt_detail-zwrbtr.
          CONCATENATE '-' gt_detail-zwrbtr INTO gt_detail-zwrbtr.
        ELSE.
          WRITE lt_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers.
        ENDIF.

*        WRITE lt_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers.
        ADD lt_out-wrbtr TO lv_wrbtr.
        APPEND gt_detail.
      ENDLOOP.

      CASE pa_bukrs.
        WHEN '8330'.
          CASE 'X'.
            WHEN ra_kr.
              READ TABLE lines INTO ls_lines INDEX 1.
              IF sy-subrc = 0.
                gt_header-banktxt = ls_lines-tdline.
              ENDIF.
            WHEN ra_re.
              IF gt_header-banktxt IS INITIAL.
                READ TABLE lines INTO ls_lines INDEX 1.
                IF sy-subrc = 0.
                  gt_header-banktxt = ls_lines-tdline.
                ENDIF.
              ENDIF.
          ENDCASE.
      ENDCASE.

    WHEN 'KRRE'.
      gt_header-xblnr   = pa_xblnr.
      gt_header-belnr   = pa_belnr.
      gt_header-bukrs   = pa_bukrs.
      CASE pa_bukrs.
        WHEN '8360'.
          gt_header-budat   = pa_budat + gv_zbd1t.
          gt_header-budat2  = gv_budat + gv_zbd1t.
        WHEN '8330'.
          gt_header-budat   = pa_budat + gv_zbd1t.
          gt_header-budat2  = gv_budat + gv_zbd1t.
        WHEN OTHERS.
          gt_header-budat   = pa_budat.
      ENDCASE.

      gt_header-banktxt = pa_text.
      gt_header-waers   = gt_bkpf-waers.

      LOOP AT ft_out.
        IF lv_flag IS INITIAL.
          lv_flag   = 1.
          READ TABLE gt_t001w WITH KEY werks = ft_out-gsber.
          gt_header-gsber      = ft_out-gsber.
          gt_header-name1_gsb  = gt_t001w-name1.
          gt_header-street_gsb = gt_t001w-street.
          gt_header-payfor     = ft_out-payfor.
          IF pa_bukrs = '8360'.
            gt_header-payfor     = pa_name.
          ENDIF.
          IF ft_out-gsber = '0401'.
            gt_header-name1_gsb  = 'PT. Tempo Natural Products'.
            gt_header-street_gsb = 'Kawasan Industri EJIP PLOT 2 - G2'.
          ENDIF.
        ENDIF.
        gt_detail-account     = ft_out-account.

        IF ft_out-gsber = '0401'.
          gt_detail-description = ft_out-xblnr.
          gt_detail-invoice     = ft_out-description.
        ELSE.
          gt_detail-description = ft_out-description.
          gt_detail-invoice     = ft_out-zuonr1.
        ENDIF.

        gt_detail-kostl       = ft_out-kostl.
        IF ft_out-shkzg EQ 'S'.
          ft_out-wrbtr  = ft_out-wrbtr * -1.
        ENDIF.
        IF ft_out-wrbtr LT 0.
          WRITE ft_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers NO-SIGN.
          CONDENSE gt_detail-zwrbtr.
          CONCATENATE '-' gt_detail-zwrbtr INTO gt_detail-zwrbtr.
        ELSE.
          WRITE ft_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers.
        ENDIF.
        ADD ft_out-wrbtr TO lv_wrbtr.
        APPEND gt_detail.
      ENDLOOP.

* Tax PPh
      LOOP AT gt_tax.
        READ TABLE ft_out WITH KEY belnr = gt_tax-belnr
                          TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
        READ TABLE gt_out WITH KEY belnr = gt_tax-belnr
                                   account = gt_tax-hkont.
        lt_out-account     = gt_out-account.
        IF gt_out-gsber = '0401'.
          CONTINUE.
          lt_out-description = gt_out-xblnr.
          lt_out-invoice     = gt_out-description.
        ELSE.
          lt_out-description = gt_out-description.
          lt_out-invoice     = gt_out-zuonr1.
        ENDIF.
        lt_out-kostl       = gt_out-kostl.
        lt_out-wrbtr       = gt_out-wrbtr.
        IF gt_out-shkzg EQ 'H'.
          lt_out-wrbtr  = gt_out-wrbtr * -1.
        ENDIF.
        COLLECT lt_out.
      ENDLOOP.

      LOOP AT lt_out.
        gt_detail-account     = lt_out-account.
        gt_detail-description = lt_out-description.
        gt_detail-invoice     = lt_out-invoice.
        gt_detail-kostl       = lt_out-kostl.
        IF lt_out-wrbtr LT 0.
          WRITE lt_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers NO-SIGN.
          CONDENSE gt_detail-zwrbtr.
          CONCATENATE '-' gt_detail-zwrbtr INTO gt_detail-zwrbtr.
        ELSE.
          WRITE lt_out-wrbtr TO gt_detail-zwrbtr CURRENCY gt_bkpf-waers.
        ENDIF.

        ADD lt_out-wrbtr TO lv_wrbtr.
        APPEND gt_detail.
      ENDLOOP.

    WHEN OTHERS.
      gt_header-xblnr = fwa_bkpf-xblnr.
      gt_header-belnr = fwa_bkpf-belnr.
      gt_header-budat = fwa_bkpf-budat.
      gt_header-waers = fwa_bkpf-waers.

      LOOP AT ft_out WHERE belnr EQ fwa_bkpf-belnr.
        IF lv_flag IS INITIAL.
          lv_flag   = 1.
          READ TABLE gt_t001w WITH KEY werks = ft_out-gsber.
          gt_header-name1_gsb  = gt_t001w-name1.
          gt_header-street_gsb = gt_t001w-street.
          gt_header-payfor     = ft_out-payfor.
          IF ft_out-gsber = '0401'.
            gt_header-name1_gsb  = 'PT. Tempo Natural Products'.
            gt_header-street_gsb = 'Kawasan Industri EJIP PLOT 2 - G2'.
          ENDIF.
        ENDIF.

        gt_detail-account     = ft_out-account.
        IF ft_out-gsber = '0401'.
          gt_detail-description = ft_out-xblnr.
          gt_detail-invoice     = ft_out-description.
        ELSE.
          gt_detail-description = ft_out-description.
          gt_detail-invoice     = ft_out-zuonr1.
        ENDIF.
        gt_detail-kostl       = ft_out-kostl.

        IF ft_out-shkzg EQ 'H'.
          ft_out-wrbtr  = ft_out-wrbtr * -1.
        ENDIF.
        IF ft_out-wrbtr LT 0.
          WRITE ft_out-wrbtr TO gt_detail-zwrbtr CURRENCY fwa_bkpf-waers NO-SIGN.
          CONDENSE gt_detail-zwrbtr.
          CONCATENATE '-' gt_detail-zwrbtr INTO gt_detail-zwrbtr.
        ELSE.
          WRITE ft_out-wrbtr TO gt_detail-zwrbtr CURRENCY fwa_bkpf-waers.
        ENDIF.

*        WRITE ft_out-wrbtr TO gt_detail-zwrbtr CURRENCY fwa_bkpf-waers.

        ADD ft_out-wrbtr TO lv_wrbtr.
        APPEND gt_detail.
      ENDLOOP.
  ENDCASE.

  IF lv_wrbtr LT 0.
    WRITE lv_wrbtr TO gt_header-total CURRENCY fwa_bkpf-waers NO-SIGN.
    CONDENSE gt_header-total.
    CONCATENATE '-' gt_header-total INTO gt_header-total.
  ELSE.
    WRITE lv_wrbtr TO gt_header-total CURRENCY fwa_bkpf-waers.
*****    IF pa_bukrs = '8330'.
*****      IF lv_wrbtr > 1000000.
*****        gt_header-sign1 = 'RLM'.
*****        gt_header-sign2 = 'MAI'.
*****        gt_header-sign3 = 'OI/ha'.
*****        gt_header-sign4 = 'YSA'.
*****      ELSE.
*****        gt_header-sign1 = 'MAI'.
*****        gt_header-sign2 = 'YSA'.
*****        gt_header-sign3 = 'OI/ha'.
*****        CLEAR gt_header-sign4.
*****      ENDIF.
*****    ENDIF.

    PERFORM f_signature USING pa_bukrs ft_out-lifnr lv_wrbtr
                        CHANGING gt_header-sign1 gt_header-sign2
                                 gt_header-sign3 gt_header-sign4
                                 gt_header-sign5.

******    IF pa_bukrs = '8330'.
******      IF ft_out-lifnr(4) = '0800' OR
******        ft_out-lifnr(4) = '0900'.
******        IF lv_wrbtr <= 1500000.
******          gt_header-sign1 = 'MAI'.  "'LYY'.  "'MAI'.
******          gt_header-sign2 = 'TIO'.  "'SAV'.  "'MAI'.  "'YSA'.
******          gt_header-sign3 = 'ha'.  "'IM/ha'.
******          CLEAR gt_header-sign4.
******          CLEAR gt_header-sign5.
******        ELSEIF lv_wrbtr > 1500000. " AND lv_wrbtr < 3000000.
******          gt_header-sign1 = 'RLM'.
******          gt_header-sign2 = 'MAI'.
******          gt_header-sign3 = 'ha'.  "'IM/ha'.
******          gt_header-sign4 = 'TIO'.  "'SAV'.  "CLEAR gt_header-sign4.
******          CLEAR gt_header-sign5.
*******        ELSE.
*******          gt_header-sign1 = 'LIP'.  "'RLM'.
*******          gt_header-sign2 = 'LYY'.
*******          gt_header-sign3 = 'OI/ha'.
*******          gt_header-sign4 = 'YSA'.
*******          gt_header-sign5 = 'MAI'.
******        ENDIF.
******      ELSEIF ft_out-lifnr(3) EQ 'TSB' OR
******        ft_out-lifnr(3) = 'NSB'.
******        IF lv_wrbtr <= 2000000.
******          gt_header-sign1 = 'MAI'.
******          gt_header-sign2 = 'TIO'.  "'SAV'.     "'YSA'.
******          gt_header-sign3 = 'ha'.      "'OI/ha'.
******          CLEAR gt_header-sign4.
******          CLEAR gt_header-sign5.
******        ELSEIF lv_wrbtr > 2000000. " AND lv_wrbtr < 4000000.
******          gt_header-sign1 = 'RLM'.
******          gt_header-sign2 = 'MAI'.
******          gt_header-sign3 = 'ha'.      "'OI/ha'.
******          gt_header-sign4 = 'TIO'.  "'SAV'.     "'YSA'.
******          CLEAR gt_header-sign5.
*******        ELSE.
*******          gt_header-sign1 = 'LIP'.  "'RLM'.
*******          gt_header-sign2 = 'LYY'.
*******          gt_header-sign3 = 'OI/ha'.
*******          gt_header-sign4 = 'YSA'.
*******          gt_header-sign5 = 'MAI'.
******        ENDIF.
******      ELSE.
******        IF lv_wrbtr <= 250000.
******          gt_header-sign1 = 'MAI'.  "'LYY'.  "'MAI'.
******          gt_header-sign2 = 'TIO'.  "'SAV'.  "'MAI'.  "'YSA'.
******          gt_header-sign3 = 'ha'.   "'IM/ha'.
******          CLEAR gt_header-sign4.
******          CLEAR gt_header-sign5.
******        ELSEIF lv_wrbtr > 250000. " AND lv_wrbtr < 500000.
******          gt_header-sign1 = 'RLM'.
******          gt_header-sign2 = 'MAI'.
******          gt_header-sign3 = 'ha'.  "'IM/ha'.
******          gt_header-sign4 = 'TIO'.  "'SAV'.  "CLEAR gt_header-sign4.
******          CLEAR gt_header-sign5.
*******        ELSE.
*******          gt_header-sign1 = 'LIP'.  "'RLM'.
*******          gt_header-sign2 = 'LYY'.
*******          gt_header-sign3 = 'OI/ha'.
*******          gt_header-sign4 = 'YSA'.
*******          gt_header-sign5 = 'MAI'.
******        ENDIF.
******      ENDIF.
******    ENDIF.
  ENDIF.

  CASE pa_bukrs.
    WHEN '8360'.
      PERFORM f_add_signature.
    WHEN '8330'.
      CASE 'X'.
        WHEN ra_kr.
          PERFORM f_add_signature.
        WHEN ra_re.
          IF fu_dynnr = '0501'.
            PERFORM f_add_signature.
          ENDIF.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  IF fwa_bkpf-waers EQ 'IDR'.
    lv_langu  = 'i'.
  ELSE.
    lv_langu  = sy-langu.
  ENDIF.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = lv_wrbtr
      currency  = fwa_bkpf-waers
      language  = lv_langu
    IMPORTING
      in_words  = lwa_spell
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  CLEAR lv_matauang.
  SELECT SINGLE ktext
    FROM tcurt
    INTO lv_matauang
    WHERE spras EQ sy-langu
      AND waers EQ fwa_bkpf-waers.

  TRANSLATE lv_matauang TO UPPER CASE.

  IF lv_langu EQ sy-langu.
    IF lwa_spell-decword EQ 'ZERO'.
      CONCATENATE lwa_spell-word lv_matauang
      INTO gt_header-terbilang
      SEPARATED BY space.
    ELSE.
      CONCATENATE lwa_spell-word 'AND' lwa_spell-decword lv_matauang
      INTO gt_header-terbilang
      SEPARATED BY space.
    ENDIF.
  ELSE.
    TRANSLATE lv_matauang TO UPPER CASE.
    CONCATENATE lwa_spell-word lv_matauang
    INTO gt_header-terbilang
    SEPARATED BY space .
  ENDIF.

  IF pa_bukrs = '8040'.
    CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
      EXPORTING
        rate_type  = 'M'
        from_curr  = gt_bkpf-waers
        to_currncy = 'IDR'
        date       = gt_bkpf-budat
      IMPORTING
        exch_rate  = exch_rate
        return     = return.
    ld_exch_rate  = gt_bkpf-kursf * exch_rate-to_factor / exch_rate-from_factor.
    WRITE ld_exch_rate TO gt_header-kursft CURRENCY gt_bkpf-waers.
    SHIFT gt_header-kursft LEFT DELETING LEADING space.
  ENDIF.

  gt_header-toppo = gv_toppo.
ENDFORM.                    " F_PREPARE_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_RE
*&---------------------------------------------------------------------*
FORM f_proses_re  TABLES   ft_tax  STRUCTURE gt_bseg
                  USING    fwa_bseg STRUCTURE gt_bseg
                           fu_flag
                  CHANGING fwa_out STRUCTURE gt_out.
  DATA: lv_wrbtr LIKE ft_tax-wrbtr,
        ls_bseg  LIKE gt_bseg,
        ls_error LIKE LINE OF gt_error.

  CLEAR: ft_tax,lv_wrbtr.

  fwa_out-icon    = icon_led_green.
  fwa_out-lifnr   = fwa_bseg-lifnr.
  CASE fu_flag.
    WHEN '1'.
      fwa_out-account       = fwa_bseg-lifnr.
      fwa_out-description   = fwa_bseg-sgtxt.
*      READ TABLE ft_tax WITH KEY bukrs = fwa_bseg-bukrs
*                                 belnr = fwa_bseg-belnr
*                                 gjahr = fwa_bseg-gjahr.
*      fwa_out-wrbtr         = fwa_bseg-wrbtr + ft_tax-wrbtr.
      LOOP AT ft_tax WHERE bukrs = fwa_bseg-bukrs
                       AND belnr = fwa_bseg-belnr
                       AND gjahr = fwa_bseg-gjahr.
        IF ft_tax-shkzg = 'S'.
          ft_tax-wrbtr = ft_tax-wrbtr * -1.
        ENDIF.
        ADD ft_tax-wrbtr TO lv_wrbtr.
      ENDLOOP.

      fwa_out-wrbtr         = fwa_bseg-wrbtr + lv_wrbtr.

      IF fwa_bseg-bukrs = '8010' OR
        fwa_bseg-bukrs = '8040' OR
        fwa_bseg-bukrs = '8090' OR
        fwa_bseg-bukrs = '8190'.
        LOOP AT gt_bseg INTO ls_bseg
                        WHERE bukrs = fwa_bseg-bukrs
                          AND belnr = fwa_bseg-belnr
                          AND gjahr = fwa_bseg-gjahr.
          IF ls_bseg-zlspr IS NOT INITIAL.
            fwa_out-icon        = icon_led_red.
            ls_error-type       = 'E'.
            ls_error-id         = 'ZAB'.
            ls_error-number     = '000'.
            ls_error-message_v1 = 'Invoice'.
            ls_error-message_v2 = fwa_bseg-belnr.
            ls_error-message_v3 = 'blocked for payment'.
            APPEND ls_error TO gt_error.
            CLEAR ls_error.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    WHEN '2'.
      fwa_out-account   = fwa_bseg-hkont.
      READ TABLE gt_skat WITH KEY saknr = fwa_bseg-hkont.
      IF sy-subrc EQ 0.
        fwa_out-description = gt_skat-txt20.
      ENDIF.
      fwa_out-wrbtr     = fwa_bseg-wrbtr.
  ENDCASE.

  READ TABLE gt_lfa1 WITH KEY lifnr = fwa_bseg-lifnr.
  IF sy-subrc EQ 0.
    fwa_out-payfor  = gt_lfa1-name1.
    pa_name = fwa_out-payfor.
  ENDIF.

  CLEAR gt_zfbank_vendor.
  READ TABLE gt_zfbank_vendor WITH KEY bukrs = pa_bukrs
                                       lifnr = gt_lfa1-lifnr.
  pa_text = gt_zfbank_vendor-norek.

  fwa_out-shkzg   = fwa_bseg-shkzg.
  fwa_out-zuonr1  = fwa_bseg-zuonr.
  fwa_out-gsber   = fwa_bseg-gsber.
  fwa_out-zfbdt   = fwa_bseg-zfbdt.
ENDFORM.                    " F_PROSES_RE

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_SA
*&---------------------------------------------------------------------*
FORM f_proses_sa  USING    fwa_bseg STRUCTURE gt_bseg
                  CHANGING fwa_out STRUCTURE gt_out.
  fwa_out-account   = fwa_bseg-hkont.
  READ TABLE gt_skat WITH KEY saknr = fwa_bseg-hkont.
  IF sy-subrc EQ 0.
    fwa_out-description = gt_skat-txt20.
  ENDIF.

  fwa_out-kostl   = fwa_bseg-kostl.
  fwa_out-zuonr1  = fwa_bseg-zuonr.
  fwa_out-gsber   = fwa_bseg-gsber.
  fwa_out-shkzg   = fwa_bseg-shkzg.
  fwa_out-wrbtr   = fwa_bseg-wrbtr.
  fwa_out-zfbdt   = fwa_bseg-zfbdt.
ENDFORM.                    " F_PROSES_SA

**&---------------------------------------------------------------------*
**&      Form  F_MODIFY_SCREEN
**&---------------------------------------------------------------------*
*FORM f_modify_screen .
*  LOOP AT SCREEN.
*    IF screen-name EQ 'PA_BUKRS'.
*
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS 'PF-STATUS'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_ucomm   TYPE sy-ucomm.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&POS'.
      PERFORM f_get_text.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  sy-subrc = 4.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_process_before_output.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_BEFORE_OUTPUT
*&---------------------------------------------------------------------*
FORM f_process_before_output .
  CLEAR : text, lines[].
  IF text_editor IS INITIAL .
    CREATE OBJECT editor_container
      EXPORTING
        container_name              = 'TEXTEDITOR'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    CREATE OBJECT text_editor
      EXPORTING
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_position          = line
        wordwrap_to_linebreak_mode = cl_gui_textedit=>true
        parent                     = editor_container.

    CALL METHOD text_editor->set_toolbar_mode
      EXPORTING
        toolbar_mode = cl_gui_textedit=>false.

    CALL METHOD text_editor->set_statusbar_mode
      EXPORTING
        statusbar_mode = cl_gui_textedit=>false.
  ENDIF.

  CASE pa_bukrs.
    WHEN '8360'.
      PERFORM f_modify_screen USING :
        '' '' 'PA_BUDAT' '' '0' '' ''.
    WHEN '8330'.
      PERFORM f_modify_screen USING :
        '' '' 'PA_BUDAT' '' '0' '' '',
        'KMM' '' '' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_PROCESS_BEFORE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT
*&---------------------------------------------------------------------*
FORM f_get_text .
  DATA : lt_stext  TYPE TABLE OF string,
         ls_stext  LIKE LINE OF lt_stext,
         lv_blank  TYPE string,
         lv_length TYPE i.

  DATA : tab,
         cr,
         new.

  tab = cl_abap_char_utilities=>horizontal_tab.
  cr  = cl_abap_char_utilities=>cr_lf.
  new = cl_abap_char_utilities=>newline.

  CALL METHOD text_editor->get_textstream
    IMPORTING
      text                   = text
    EXCEPTIONS
      error_cntl_call_method = 1
      not_supported_by_gui   = 2
      OTHERS                 = 3.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.

  SPLIT text AT cr INTO TABLE lt_stext.
  LOOP AT lt_stext INTO ls_stext.
    REPLACE new IN ls_stext WITH space.
    REPLACE cr IN ls_stext WITH space.
    ls_lines-tdline        = ls_stext.
    APPEND ls_lines TO lines.
    CLEAR ls_lines.
  ENDLOOP.

  CALL METHOD text_editor->set_textstream
    EXPORTING
      text                   = lv_blank
    EXCEPTIONS
      error_cntl_call_method = 1
      not_supported_by_gui   = 2
      OTHERS                 = 3.

  lv_length = strlen( text ).
  IF lv_length > 255.
    CLEAR text_editor.
  ENDIF.
ENDFORM.                    " F_GET_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_ADD_SIGNATURE
*&---------------------------------------------------------------------*
FORM f_add_signature .
  gt_header-sign1 = pa_autho.
  gt_header-sign2 = pa_verif.
  gt_header-sign3 = pa_appro.
  gt_header-sign4 = pa_input.

  gt_header-sign5 = pa_auth1.
  gt_header-sign6 = pa_veri1.
  gt_header-sign7 = pa_rele1.
  gt_header-sign8 = pa_rele2.
  gt_header-sign9 = pa_recv1.
*    gt_header-sign5 = pa_recei.
ENDFORM.                    " F_ADD_SIGNATURE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_ONE_TIME_VENDOR
*&---------------------------------------------------------------------*
FORM f_validate_one_time_vendor  CHANGING fc_subrc fc_dynnr.
  DATA : lt_out LIKE gt_out OCCURS 0 WITH HEADER LINE,
         ls_out LIKE LINE OF gt_out.

  DATA : lr_lifnr TYPE RANGE OF lifnr,
         ls_lifnr LIKE LINE OF lr_lifnr,
         lv_0501  TYPE sy-dynnr,
         lv_0500  TYPE sy-dynnr.

  CLEAR : fc_subrc, fc_dynnr.

  CASE pa_bukrs.
    WHEN '8330'.
      lt_out[] = gt_out[].
      DELETE lt_out WHERE check NE 'X'.

      ls_lifnr-sign   = 'I'.
      ls_lifnr-option = 'EQ'.
      ls_lifnr-low    = '9900000016'.
      APPEND ls_lifnr TO lr_lifnr.
      ls_lifnr-low    = '1900000722'.
      APPEND ls_lifnr TO lr_lifnr.
      ls_lifnr-low    = '0800000529'.
      APPEND ls_lifnr TO lr_lifnr.

      LOOP AT lt_out INTO ls_out.
        IF ls_out-lifnr IN lr_lifnr.
          lv_0501  = '0501'.
        ELSE.
          lv_0500  = '0500'.
        ENDIF.
      ENDLOOP.

      IF lv_0501 IS NOT INITIAL AND
        lv_0500 IS NOT INITIAL.
        fc_subrc = 4.
      ELSEIF lv_0501 IS NOT INITIAL.
        fc_subrc = 0.
        fc_dynnr = lv_0501.
      ELSEIF lv_0500 IS NOT INITIAL.
        fc_subrc = 0.
        fc_dynnr = lv_0500.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_ONE_TIME_VENDOR

*&---------------------------------------------------------------------*
*&      Form  F_DATE_CALCULATE
*&---------------------------------------------------------------------*
FORM f_date_calculate  USING    fu_zbd1t fu_zfbdt
                       CHANGING fc_zfbdt.
  fc_zfbdt = fu_zfbdt + fu_zbd1t.
ENDFORM.                    " F_DATE_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUDAT
*&---------------------------------------------------------------------*
FORM f_get_budat .
  DATA : lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE,
         lt_xbseg LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
         ls_xbseg LIKE LINE OF lt_xbseg,
         ls_bseg  LIKE LINE OF gt_bseg,
         lt_ekko  TYPE STANDARD TABLE OF ekko,
         ls_ekko  LIKE LINE OF lt_ekko,
         lt_bkpf  LIKE gt_bkpf OCCURS 0 WITH HEADER LINE,
         ls_bkpf  LIKE LINE OF gt_bkpf,
         lv_zbd1t TYPE bseg-zbd1t,
         lv_zterm TYPE bseg-zterm,
         lv_text1 TYPE t052u-text1,
         lv_zfbdt TYPE bseg-zfbdt,
         lv_lines TYPE i,
         lv_krre.

  CLEAR : gv_toppo, gv_zbd1t, gv_budat.
  lt_out[] = gt_out[].
  DELETE lt_out WHERE check NE 'X'.

  SORT lt_out BY budat DESCENDING.
  CLEAR lt_out.
  READ TABLE lt_out INDEX 1.
  IF sy-subrc = 0.
    pa_budat  = lt_out-budat.
  ENDIF.

  LOOP AT gt_bseg.
    READ TABLE gt_out WITH KEY belnr = gt_bseg-belnr
                               check = 'X'.
    IF sy-subrc = 0.
      APPEND gt_bseg TO lt_xbseg.
      IF gt_bseg-zbd1t > lv_zbd1t.
        lv_zbd1t = gt_bseg-zbd1t.
        lv_zterm = gt_bseg-zterm.
      ENDIF.
      IF gt_bseg-koart = 'K'.
        IF gt_bseg-zfbdt > lv_zfbdt.
          lv_zfbdt = gt_bseg-zfbdt.
          gv_budat = gt_bseg-zfbdt.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR gt_bseg.
  ENDLOOP.

  SORT lt_xbseg BY belnr ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_xbseg COMPARING belnr ebeln.
  DELETE lt_xbseg WHERE ebeln = space.
  IF lt_xbseg[] IS NOT INITIAL.
    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE lt_ekko
      FOR ALL ENTRIES IN lt_xbseg
      WHERE ebeln = lt_xbseg-ebeln
      ORDER BY PRIMARY KEY.
  ENDIF.

  CASE 'X'.
    WHEN ra_re.
      CLEAR lv_zbd1t.
      LOOP AT lt_ekko INTO ls_ekko.
        IF ls_ekko-zbd1t > lv_zbd1t.
          lv_zbd1t = ls_ekko-zbd1t.
          lv_zterm = ls_ekko-zterm.
        ENDIF.
      ENDLOOP.
      PERFORM f_get_budat_from_gr TABLES lt_xbseg
                                  USING 'RE' ''
                                  CHANGING gv_budat.
    WHEN ra_krre.
      lt_bkpf[] = gt_bkpf[].

      LOOP AT lt_bkpf INTO ls_bkpf.
        READ TABLE gt_out WITH KEY belnr = ls_bkpf-belnr
                                   check = 'X'.
        IF sy-subrc <> 0.
          DELETE lt_bkpf.
        ENDIF.
      ENDLOOP.

      SORT lt_bkpf BY blart.
      DELETE ADJACENT DUPLICATES FROM lt_bkpf COMPARING blart.
      DESCRIBE TABLE lt_bkpf LINES lv_lines.
      IF lv_lines = 1.
        READ TABLE lt_bkpf INTO ls_bkpf INDEX 1.
      ELSE.
        ls_bkpf-blart = 'RE'.
        lv_krre       = 'X'.
      ENDIF.
      IF lv_krre = 'X'.
        LOOP AT lt_ekko INTO ls_ekko.
          IF ls_ekko-zbd1t > lv_zbd1t.
            lv_zbd1t = ls_ekko-zbd1t.
            lv_zterm = ls_ekko-zterm.
          ENDIF.
        ENDLOOP.
      ENDIF.
      PERFORM f_get_budat_from_gr TABLES lt_xbseg
                                  USING ls_bkpf-blart lv_krre
                                  CHANGING gv_budat.
  ENDCASE.

  SELECT SINGLE text1
    FROM t052u
    INTO lv_text1
    WHERE spras EQ 'i'
      AND zterm = lv_zterm.

  IF lv_text1 IS NOT INITIAL.
    gv_toppo  = lv_text1.
    gv_zbd1t  = lv_zbd1t.
  ENDIF.
ENDFORM.                    " F_GET_BUDAT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group1 fu_group2 fu_name fu_active fu_input
                               fu_invisible fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUDAT_FROM_GR
*&---------------------------------------------------------------------*
FORM f_get_budat_from_gr  TABLES   ft_bseg    TYPE STANDARD TABLE
                          USING    fu_blart fu_krre
                          CHANGING fc_budat.
  TYPES : BEGIN OF ty_ekbe,
            ebeln TYPE ekbe-ebeln,
            ebelp TYPE ekbe-ebelp,
            zekkn TYPE ekbe-zekkn,
            vgabe TYPE ekbe-vgabe,
            gjahr TYPE ekbe-gjahr,
            belnr TYPE ekbe-belnr,
            buzei TYPE ekbe-buzei,
            bewtp TYPE ekbe-bewtp,
            budat TYPE ekbe-budat,
            lfbnr TYPE ekbe-lfbnr,
            lfpos TYPE ekbe-lfpos,
          END OF ty_ekbe.

  DATA : lt_bseg  LIKE gt_bseg OCCURS 0,
         lt_ekbe  TYPE STANDARD TABLE OF ty_ekbe,
         lt_eekbe TYPE STANDARD TABLE OF ty_ekbe,
         lt_qekbe TYPE STANDARD TABLE OF ty_ekbe,
         ls_eekbe LIKE LINE OF lt_eekbe,
         ls_qekbe LIKE LINE OF lt_qekbe,
         lv_budat TYPE sy-datum,
         lr_bewtp TYPE RANGE OF bewtp,
         ls_bewtp LIKE LINE OF lr_bewtp,
         ls_ekbe  LIKE LINE OF lt_ekbe,
         ls_bseg  LIKE LINE OF lt_bseg.

  ls_bewtp-low    = 'E'.
  ls_bewtp-sign   = 'I'.
  ls_bewtp-option = 'EQ'.
  APPEND ls_bewtp TO lr_bewtp.
  ls_bewtp-low    = 'Q'.
  ls_bewtp-sign   = 'I'.
  ls_bewtp-option = 'EQ'.
  APPEND ls_bewtp TO lr_bewtp.

  lt_bseg[] = ft_bseg[].
  IF lt_bseg[] IS NOT INITIAL.
    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp budat lfbnr lfpos
      FROM ekbe
      INTO TABLE lt_ekbe
      FOR ALL ENTRIES IN lt_bseg
      WHERE ebeln = lt_bseg-ebeln
        AND bewtp IN lr_bewtp
      ORDER BY PRIMARY KEY.

    lt_eekbe[] = lt_ekbe[].
    DELETE lt_eekbe[] WHERE bewtp = 'Q'.
    lt_qekbe[] = lt_ekbe[].
    DELETE lt_qekbe[] WHERE bewtp = 'E'.
    LOOP AT lt_qekbe INTO ls_qekbe.
      CLEAR ls_bseg.
      READ TABLE lt_bseg INTO ls_bseg
                         WITH KEY belnr = ls_qekbe-belnr.
      IF sy-subrc <> 0.
        DELETE TABLE lt_qekbe FROM ls_qekbe.
      ENDIF.
    ENDLOOP.

    SORT lt_eekbe BY budat DESCENDING.
    READ TABLE lt_eekbe INTO ls_eekbe INDEX 1.
    IF sy-subrc = 0.
      lv_budat  = ls_eekbe-budat.
    ENDIF.

*****    SORT lt_qekbe BY budat DESCENDING.
*****    SORT lt_eekbe BY budat DESCENDING.
*****    CLEAR : ls_qekbe, ls_eekbe.
*****    READ TABLE lt_qekbe INTO ls_qekbe INDEX 1.
*****    IF sy-subrc = 0.
*****      READ TABLE lt_eekbe INTO ls_eekbe
*****                          WITH KEY ebeln = ls_qekbe-ebeln
*****                                   ebelp = ls_qekbe-ebelp
*****                                   belnr = ls_qekbe-lfbnr
*****                                   buzei = ls_qekbe-lfpos.
*****      lv_budat  = ls_eekbe-budat.
*****    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN ra_re.
      fc_budat  = lv_budat.
    WHEN ra_krre.
      IF fu_krre IS NOT INITIAL.
        IF gv_budat < lv_budat.
          fc_budat = lv_budat.
        ENDIF.
      ELSE.
        IF fu_blart = 'RE'.
          fc_budat  = lv_budat.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_BUDAT_FROM_GR

*&---------------------------------------------------------------------*
*&      Form  F_SIGNATURE
*&---------------------------------------------------------------------*
FORM f_signature  USING    fu_bukrs fu_lifnr fu_wrbtr
                  CHANGING fc_sign1 fc_sign2 fc_sign3 fc_sign4 fc_sign5.
  DATA : lt_014   TYPE STANDARD TABLE OF zfidt014,
         ls_014   LIKE LINE OF gt_014,
         lr_lifnr TYPE RANGE OF lifnr,
         lr_space TYPE RANGE OF lifnr,
         ls_lifnr LIKE LINE OF lr_lifnr,
         lr_wrbtr TYPE RANGE OF wrbtr,
         ls_wrbtr LIKE LINE OF lr_wrbtr.

  DATA : lv_length TYPE i,
         lv_subrc  TYPE sy-subrc.

  CLEAR : fc_sign1, fc_sign2, fc_sign3, fc_sign4, lt_014[].

  lv_subrc = 4.

  LOOP AT gt_014 INTO ls_014.
    CLEAR : lr_lifnr[], ls_lifnr, lr_wrbtr[], ls_wrbtr.
    CASE ls_014-field.
      WHEN 'LIFNR'.
        IF ls_014-value IS INITIAL.
          APPEND ls_014 TO lt_014.
        ENDIF.
        lv_length = strlen( ls_014-value ).
        lv_length = lv_length - 1.
        IF lv_length = 1.
          IF ls_014-value = '*'.
            ls_lifnr-low    = ls_014-value.
            ls_lifnr-sign   = 'I'.
            ls_lifnr-option = 'CP'.
            APPEND ls_lifnr TO lr_lifnr.
            CLEAR ls_lifnr.
          ENDIF.
        ELSEIF lv_length > 1.
          IF ls_014-value+lv_length(1) = '*'.
            ls_lifnr-low    = ls_014-value.
            ls_lifnr-sign   = 'I'.
            ls_lifnr-option = 'CP'.
            APPEND ls_lifnr TO lr_lifnr.
            CLEAR ls_lifnr.
          ENDIF.
        ENDIF.

        IF lr_lifnr[] IS NOT INITIAL.
          IF fu_lifnr IN lr_lifnr.
            ls_wrbtr-low    = ls_014-wrbtr_low.
            ls_wrbtr-high   = ls_014-wrbtr_high.
            ls_wrbtr-sign   = 'I'.
            ls_wrbtr-option = 'BT'.
            APPEND ls_wrbtr TO lr_wrbtr.
            CLEAR ls_wrbtr.

            IF fu_wrbtr IN lr_wrbtr.
              fc_sign1  = ls_014-sign01.
              fc_sign2  = ls_014-sign02.
              fc_sign3  = ls_014-sign03.
              fc_sign4  = ls_014-sign04.
              fc_sign5  = ls_014-sign05.
              CLEAR lv_subrc.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF lv_subrc <> 0.
    LOOP AT lt_014 INTO ls_014.
      ls_wrbtr-low    = ls_014-wrbtr_low.
      ls_wrbtr-high   = ls_014-wrbtr_high.
      ls_wrbtr-sign   = 'I'.
      ls_wrbtr-option = 'BT'.
      APPEND ls_wrbtr TO lr_wrbtr.
      CLEAR ls_wrbtr.

      IF fu_wrbtr IN lr_wrbtr.
        fc_sign1  = ls_014-sign01.
        fc_sign2  = ls_014-sign02.
        fc_sign3  = ls_014-sign03.
        fc_sign4  = ls_014-sign04.
        fc_sign5  = ls_014-sign05.
        CLEAR lv_subrc.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
