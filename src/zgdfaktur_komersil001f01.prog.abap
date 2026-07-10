*----------------------------------------------------------------------*
*   INCLUDE ZGDFAKTUR_KOMERSIL001F01                                   *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: ld_low  LIKE sy-datum,
        ld_low1 LIKE sy-datum,
        ld_high LIKE sy-datum.

  RANGES: lr_fkdat FOR vbrk-fkdat.

  ld_low = so_fkdat-low - 1.
  ld_low1 = ld_low.
  CONCATENATE ld_low(6) '01' INTO ld_low.
  DO 3 TIMES.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ld_low1
      IMPORTING
        last_day_of_month = ld_high.
    ld_low1 = ld_high + 1.
  ENDDO.

  lr_fkdat-low    = ld_low.
  lr_fkdat-high   = ld_high.
  lr_fkdat-sign   = 'I'.
  lr_fkdat-option = 'BT'.
  APPEND lr_fkdat.

  SELECT *
    FROM zkomernr
    INTO CORRESPONDING FIELDS OF TABLE t_zkomernr
    WHERE vkorg EQ pa_vkorg AND
          gjahr EQ so_fkdat-low(4) ORDER BY PRIMARY KEY. "Add Order by SOH: Shell SCI Adjustment 20240221 RZL

  SELECT *
    FROM zgdsdkomer
    INTO CORRESPONDING FIELDS OF TABLE t_zgdsdkomer
    WHERE vkorg EQ pa_vkorg AND
          vbeln IN so_vbeln AND
          xblnr IN so_xblnr AND
          fkdat IN lr_fkdat ORDER BY PRIMARY KEY. "Add Order by SOH: Shell SCI Adjustment 20240221 RZL

  SELECT SINGLE datab
    FROM zproject
    INTO va_datab
    WHERE name EQ 'ZGDTAX'.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  SELECT *
    FROM vbrk
    INTO CORRESPONDING FIELDS OF TABLE t_vbrk
    WHERE vkorg EQ pa_vkorg        AND
          vbeln IN so_vbeln        AND
          xblnr IN so_xblnr        AND
          fkdat IN so_fkdat        AND
          vbtyp IN ('M', 'P', '5') AND
          expkz EQ space.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  IF radio1 EQ 'X'.
    PERFORM f_alv TABLES t_out.
  ELSE.
    PERFORM f_alv TABLES t_out1.
  ENDIF.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
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
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  IF radio1 EQ 'X'.
    PERFORM f_fieldcatg USING ft_report:
      'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '',
      'VBELN' 'VBRK' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '',
      'FKDAT' 'VBRK' 'FKDAT' '' '' '' '' '' '' '' '' '' '' '' '',
      'XBLNR' 'VBRK' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '',
      'INVO1' 'ZGDSDKOMER' 'INVO1' '' '' '' '' '' '' '' '' '' '' '' '',
      'INVO2' 'ZGDSDKOMER' 'INVO2' '' '' '' '' '' '' '' '' '' '' '' ''.
  ELSEIF radio2 EQ 'X'.
    PERFORM f_fieldcatg USING ft_report:
      'VBELN' 'VBRK' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '',
      'FKDAT' 'VBRK' 'FKDAT' '' '' '' '' '' '' '' '' '' '' '' '',
      'XBLNR' 'VBRK' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '',
      'INVO1' 'ZGDSDKOMER' 'INVO1' '' '' '' '' '' '' '' '' '' '' ''
      '',
      'INVO2' 'ZGDSDKOMER' 'INVO2' '' '' '' '' '' '' '' '' '' '' ''
      va_update.
  ENDIF.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input).

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
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
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
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  IF radio2 EQ 'X'.
    IF va_sts EQ '1'.
      fu_layout-box_fieldname      = 'CHECK'.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'FKDAT'.
  ld_sort-up        = 'X'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'XBLNR'.
  ld_sort-up        = 'X'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  IF radio1 EQ 'X'.
    IF va_sts = 0.
      SET PF-STATUS 'TOEXECUTE'.
    ELSE.
      SET PF-STATUS 'STANDARD'.
    ENDIF.
  ELSEIF radio2 EQ 'X'.
    IF va_sts = 0.
      SET PF-STATUS 'TOUPDATE'.
    ELSE.
      SET PF-STATUS 'TOSAVE'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.
  DATA: BEGIN OF lt_zgdtxdt0002 OCCURS 0.
          INCLUDE STRUCTURE zgdtxdt0002.
  DATA: END OF lt_zgdtxdt0002.

  DATA: ld_vatno LIKE zkomernr-vatno.

  SORT t_vbrk BY fkdat xblnr.

  SORT t_zkomernr BY vkorg. "Add Sort SOH: Shell SCI Adjustment 20240221 RZL
  READ TABLE t_zkomernr WITH KEY vkorg = pa_vkorg
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    va_tabix = sy-tabix.
    ld_vatno = t_zkomernr-vatno.
  ENDIF.

  IF radio1 EQ 'X'.
    IF t_vbrk[] IS NOT INITIAL.
      SELECT bukrs brnch busln vbeln posnr gjahr fakturno
        FROM zgdtxdt0002
        INTO CORRESPONDING FIELDS OF TABLE lt_zgdtxdt0002
        FOR ALL ENTRIES IN t_vbrk
        WHERE bukrs EQ pa_vkorg AND
              brnch EQ pa_vkorg AND
              busln EQ '01'     AND
              vbeln EQ t_vbrk-vbeln.
    ENDIF.

    LOOP AT t_vbrk.
      READ TABLE t_zgdsdkomer WITH KEY vbeln = t_vbrk-vbeln.
      IF sy-subrc EQ 0.
        DELETE t_vbrk.
      ELSE.
        t_out-vkorg = pa_vkorg.
        t_out-gjahr = so_fkdat-low(4).
        t_out-vbeln = t_vbrk-vbeln.
        t_out-vbtyp = t_vbrk-vbtyp.
        t_out-fkdat = t_vbrk-fkdat.
        t_out-xblnr = t_vbrk-xblnr.

        IF sy-datum GE va_datab.
          PERFORM f_new TABLES lt_zgdtxdt0002
                        USING ld_vatno.
        ELSE.
          PERFORM f_old USING ld_vatno.
        ENDIF.

        COLLECT t_out.
        t_data = t_out.
        COLLECT t_data.
        CLEAR: t_out, t_data.
      ENDIF.
    ENDLOOP.
    va_vatno = ld_vatno.
  ELSEIF radio2 EQ 'X'.
    LOOP AT t_vbrk.
      SORT t_zgdsdkomer by vbeln. "Add Sort SOH: Shell SCI Adjustment 20240221 RZL
      READ TABLE t_zgdsdkomer WITH KEY vbeln = t_vbrk-vbeln
      BINARY SEARCH.
      IF sy-subrc NE 0.
        DELETE t_vbrk.
      ELSE.
        t_out1-vkorg = t_zgdsdkomer-vkorg.
        t_out1-gjahr = t_zgdsdkomer-fkdat.
        t_out1-vbeln = t_zgdsdkomer-vbeln.
        t_out1-vbtyp = t_zgdsdkomer-vbtyp.
        t_out1-fkdat = t_zgdsdkomer-fkdat.
        t_out1-xblnr = t_zgdsdkomer-xblnr.
        t_out1-invo1 = t_zgdsdkomer-invo1.
        t_out1-invo2 = t_zgdsdkomer-invo2.
        COLLECT t_out1.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_validate_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA: ld_answer(1).

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.

    WHEN '&UPD'.
      va_update = 'X'.
      va_sts = 1.
      PERFORM f_update_rep.
      LEAVE TO SCREEN 0.

    WHEN '&SAV'.
      CALL FUNCTION 'LC_POPUP_TO_CONFIRM_STEP'
        EXPORTING
          textline1 = 'Save data ???'
          titel     = 'Save data'
        IMPORTING
          answer    = ld_answer.
      IF ld_answer EQ 'J'.
        PERFORM f_save_table.
        LEAVE TO SCREEN 0.
        MESSAGE s000(zab) WITH 'Process complete'.
      ENDIF.

    WHEN '&PRC'.
      IF va_sts IS INITIAL.
        va_sts = 1.
**       Remark by sap_dev04 16/04/2007 FM No longer function in ECC 6.0
*        CALL FUNCTION 'LC_POPUP_TO_CONFIRM_STEP'
*             EXPORTING
*                  textline1 = 'Process data ???'
*                  titel     = 'Process data'
*             IMPORTING
*                  answer    = ld_answer.

**      added by sap_dev04 16/04/2007
        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            defaultoption  = 'Y'
            textline1      = 'Process Data ?'
            titel          = 'Process Data'
            cancel_display = ''
          IMPORTING
            answer         = ld_answer.
**      end of addition by sap_dev04.

        IF ld_answer EQ 'J'.
          PERFORM f_save_table.
          MESSAGE s000(zab) WITH 'Process complete'.
          LEAVE TO SCREEN 0.
        ELSE.
          va_sts = 0.
        ENDIF.
      ELSE.
        MESSAGE e000(zab) WITH 'Data cannot be executed anymore'.
      ENDIF.
  ENDCASE.
ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  f_save_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_table.
  DATA: ld_vatno LIKE zkomernr-vatno,
        ld_tabix LIKE sy-tabix,
        ld_flag(1).

  IF radio1 EQ 'X'.
    LOOP AT t_out WHERE icon EQ '@5B@'.
      t_out-ernam = sy-uname.
      t_out-erdat = sy-datum.
      ld_flag = 'X'.
      MODIFY t_out TRANSPORTING ernam erdat.
      INSERT into zgdsdkomer values t_out.
      COMMIT WORK AND WAIT.
    ENDLOOP.

    IF sy-datum GE va_datab.
      IF ld_flag EQ 'X'.
        UPDATE zkomernr SET vatno = va_vatno
                        WHERE vkorg EQ pa_vkorg AND
                              gjahr EQ so_fkdat-low(4).
        COMMIT WORK AND WAIT.
      ENDIF.
    ELSE.
      UPDATE zkomernr SET vatno = va_vatno
                      WHERE vkorg EQ pa_vkorg AND
                            gjahr EQ so_fkdat-low(4).
      COMMIT WORK AND WAIT.
    ENDIF.
  ELSE.
    READ TABLE t_zkomernr INDEX 1.
    IF sy-subrc EQ 0.
      ld_vatno = t_zkomernr-vatno.
    ENDIF.
    LOOP AT t_out1 WHERE check EQ 'X'.
      UPDATE zgdsdkomer SET invo2 = t_out1-invo2
                            modbe = sy-uname
                            modda = sy-datum
                        WHERE vkorg = t_out1-vkorg AND
                              gjahr = t_out1-gjahr AND
                              vbeln = t_out1-vbeln.

      IF t_out1-invo2 GT ld_vatno.
        UPDATE zkomernr SET vatno = t_out1-invo2
                        WHERE vkorg EQ pa_vkorg AND
                              gjahr EQ so_fkdat-low(4).
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_save_table

*&---------------------------------------------------------------------*
*&      Form  f_update_rep
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_rep.
  PERFORM f_alv TABLES t_out1.
ENDFORM.                    " f_update_rep

*&---------------------------------------------------------------------*
*&      Form  f_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_new TABLES ft_zgdtxdt0002 STRUCTURE zgdtxdt0002
           USING fu_vatno.
  READ TABLE ft_zgdtxdt0002 WITH KEY bukrs  = t_out-vkorg
                                     gjahr  = t_out-gjahr
                                     vbeln  = t_out-vbeln.
  IF sy-subrc EQ 0.
    t_out-icon  = icon_led_green.
    SORT t_zkomernr by vkorg. "Add Sort SOH: Shell SCI Adjustment 20240221 RZL
    READ TABLE t_zkomernr WITH KEY vkorg = t_vbrk-vkorg
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_out-invo1 = t_zkomernr-vatpr.
    ENDIF.
    READ TABLE t_zgdsdkomer WITH KEY xblnr = t_vbrk-xblnr.
    IF sy-subrc EQ 0.
      t_out-invo2 = t_zgdsdkomer-invo2.
    ELSE.
      READ TABLE t_data WITH KEY xblnr = t_vbrk-xblnr.
      IF sy-subrc EQ 0.
        t_out-invo2 = t_data-invo2.
      ELSE.
        ADD 1 TO fu_vatno.
        t_out-invo2 = fu_vatno.
      ENDIF.
    ENDIF.
  ELSE.
    t_out-icon  = icon_led_red.
  ENDIF.

ENDFORM.                    " f_new

*&---------------------------------------------------------------------*
*&      Form  f_old
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_old USING fu_vatno.
  t_out-icon  = icon_led_green.
  SORT t_zkomernr by vkorg. "Add Sort SOH: Shell SCI Adjustment 20240221 RZL
  READ TABLE t_zkomernr WITH KEY vkorg = t_vbrk-vkorg
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    t_out-invo1 = t_zkomernr-vatpr.
  ENDIF.
  READ TABLE t_zgdsdkomer WITH KEY xblnr = t_vbrk-xblnr.
  IF sy-subrc EQ 0.
    t_out-invo2 = t_zgdsdkomer-invo2.
  ELSE.
    READ TABLE t_data WITH KEY xblnr = t_vbrk-xblnr.
    IF sy-subrc EQ 0.
      t_out-invo2 = t_data-invo2.
    ELSE.
      ADD 1 TO fu_vatno.
      t_out-invo2 = fu_vatno.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_old
