*----------------------------------------------------------------------*
*   INCLUDE ZS_CLAIM_DISCOUNTF01                                       *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  CONCATENATE pa_spmon(6) '01' INTO ra_sptag-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ra_sptag-low
    IMPORTING
      last_day_of_month = ra_sptag-high.
  ra_sptag-sign    = 'I'.
  ra_sptag-option  = 'BT'.
  APPEND ra_sptag.

  LOOP AT so_vkbur.
    vkbur-selname      = 'VKBUR'.
    vkbur-kind         = 'S'.
    vkbur-sign         = 'I'.
    IF so_vkbur-high IS NOT INITIAL.
      vkbur-option       = 'BT'.
      vkbur-high         = so_vkbur-high.
    ELSE.
      vkbur-option       = 'EQ'.
    ENDIF.
    vkbur-low          = so_vkbur-low.
    APPEND vkbur.
  ENDLOOP.

  LOOP AT so_prodh.
    prodh-selname      = 'PRODH'.
    prodh-kind         = 'S'.
    prodh-sign         = 'I'.
    IF so_prodh-high IS NOT INITIAL.
      prodh-option       = 'BT'.
      prodh-high         = so_prodh-high.
    ELSE.
      prodh-option       = 'EQ'.
    ENDIF.
    prodh-low          = so_prodh-low.
    APPEND prodh.
  ENDLOOP.

  LOOP AT so_matkl.
    matkl-selname      = 'MATKL'.
    matkl-kind         = 'S'.
    matkl-sign         = 'I'.
    IF so_matkl-high IS NOT INITIAL.
      matkl-option       = 'BT'.
      matkl-high         = so_matkl-high.
    ELSE.
      matkl-option       = 'EQ'.
    ENDIF.
    matkl-low          = so_matkl-low.
    APPEND matkl.
  ENDLOOP.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lt_prodh     LIKE t_vdata OCCURS 0 WITH HEADER LINE,
        ld_answer(1).

  CALL FUNCTION 'ZRFC_CLAIM_DISCOUNT'
    EXPORTING
      sptag_low  = ra_sptag-low
      sptag_high = ra_sptag-high
    TABLES
      vkbur      = vkbur
      prodh      = prodh
      matkl      = matkl
      t_s626     = t_s626
      t_kna1     = t_kna1
      t_adrc     = t_adrc
      t_makt     = t_makt
      t_vdata    = t_vdata.

  IF so_vkbur-low(2) = 'T2'.
    pa_disc = 'X'.          "Flag agar baca discount
  ENDIF.

  IF pa_disc IS NOT INITIAL.
    IF t_vdata[] IS NOT INITIAL.
      lt_prodh[] = t_vdata[].
      SORT lt_prodh BY prodh1.
      DELETE ADJACENT DUPLICATES FROM lt_prodh COMPARING prodh1.

      SELECT a~kappl a~kschl a~vkorg a~vkbur a~prodh1 a~prodh2 a~prodh3
             a~matnr a~datbi a~datab a~knumh b~kbetr
        INTO CORRESPONDING FIELDS OF TABLE t_a603
        FROM a603 AS a JOIN konp AS b ON b~knumh = a~knumh AND
                                         b~kappl = a~kappl AND
                                         b~kschl = a~kschl
        FOR ALL ENTRIES IN lt_prodh
        WHERE a~kappl = c_kappl AND
              a~kschl = c_kschl_zclm AND
              a~vkorg = c_vkorg AND
              a~prodh1 = lt_prodh-prodh1 AND
              a~datbi GE sy-datum AND
              a~datab LE sy-datum.

      IF t_a603[] IS INITIAL AND so_vkbur-low(2) NE 'T2'.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Confirm Message'
            text_question         = TEXT-099
            display_cancel_button = ' '
          IMPORTING
            answer                = ld_answer.
        IF ld_answer = '2'.
          STOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF t_vdata[] IS NOT INITIAL.
    SELECT a~vbeln a~knumv b~posnr b~prodh b~matnr b~uepos
      INTO CORRESPONDING FIELDS OF TABLE t_vbrk
      FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
      FOR ALL ENTRIES IN t_vdata
      WHERE a~vbeln = t_vdata-vbeln
        AND b~uepos = '000000'.
    IF t_vbrk[] IS NOT INITIAL.
      SELECT knumv kposn stunr zaehk kappl kschl kwert
        INTO CORRESPONDING FIELDS OF TABLE t_konv
        FROM konv FOR ALL ENTRIES IN t_vbrk
        WHERE knumv = t_vbrk-knumv
          AND kposn = t_vbrk-posnr
          AND kschl IN ('ZTDV','ZTCV' ).
    ENDIF.
  ENDIF.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES t_out.
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

  PERFORM f_fieldcatg USING ft_report:
    'VKBUR' 'S626' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
    'PRODH1' '' '' '' '10' 'Principal' '' '' '' '' '' '' '' '' '',
    'TYPE' '' '' '' '5' 'Type' '' '' '' '' '' '' '' '' '',
    'VBELN' 'S626' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '',
    'SPTAG' 'S626' 'SPTAG' '' '' '' '' '' '' '' '' '' '' '' '',
    'KDGRP' 'S626' 'KDGRP' 'X' '' 'CGrp' '' '' '' '' '' '' '' '' '',
    'KVGR3' 'S626' 'KVGR3' '' '' 'SCGrp' '' '' '' '' '' '' '' '' '',
    'PKUNWE' 'S626' 'PKUNWE' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' 'Description' '' '' '' '' '' '' '' '' '',
    'NAME2' 'KNA1' 'NAME2' 'X' '' 'Address' '' '' '' '' '' '' '' '' '',
    'MATKL' 'S626' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'S626' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '',
    'STWAE' 'S626' 'STWAE' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'BASME' 'S626' 'BASME' 'X' '' '' '' '' '' '' '' '' '' '' '',
    'GROSS' '' '' '' '17' 'Gross' 'X' '' '' '' '' 'STWAE' '' '' '',
    'QTY' '' '' '' '17' 'Qty' '' '' '' '' '' '' 'BASME' '' '',
    'ZDISA' '' '' '' '17' 'Discount A' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZDISB' '' '' '' '17' 'Discount B' 'X' '' '' '' '' 'STWAE' '' '' '',
    'PRCT1' '' '' '' '10' '%' '' '' '2' '' '' '' '' '' '',
    'ZDISC' '' '' '' '17' 'Discount C' 'X' '' '' '' '' 'STWAE' '' '' '',
    'PRCT2' '' '' '' '10' '%' '' '' '2' '' '' '' '' '' '',
    'ZDISE' '' '' '' '17' 'Discount E' 'X' '' '' '' '' 'STWAE' '' '' '',
    'PRCT3' '' '' '' '10' '%' '' '' '2' '' '' '' '' '' '',
    'ZDISF' '' '' '' '17' 'Discount F' 'X' '' '' '' '' 'STWAE' '' '' '',
    'PRCT4' '' '' '' '10' '%' '' '' '2' '' '' '' '' '' '',
    'ZDISF3' '' '' '' '17' 'Discount F3' 'X' '' '' '' '' 'STWAE' '' '' '',
    'PRCT5' '' '' '' '10' '%' '' '' '2' '' '' '' '' '' '',
    'ZDISF9' '' '' '' '17' 'Discount F9' 'X' '' '' '' '' 'STWAE' '' '' '',
    'PRCT7' '' '' '' '10' '%' '' '' '2' '' '' '' '' '' '',
    'ZDISVOL' '' '' '' '17' 'Discount Vol.' 'X' '' '' '' '' 'STWAE' '' '' '',
    'PRCT6' '' '' '' '10' '%' '' '' '2' '' '' '' '' '' '',
    'TDISC' '' '' '' '17' 'Total Discount' 'X' '' '' '' '' 'STWAE' '' '' ''.
  PERFORM f_fieldcatg USING ft_report:
    'VKBUR' 'S626' 'VKBUR' 'X' '' '' '' '' '' '' '' '' '' '' ''.
  PERFORM f_fieldcatg USING ft_report:
    'ZDISA1' '' '' '' '17' 'Discount A Fin' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZDISB1' '' '' '' '17' 'Discount B Fin' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZDISC1' '' '' '' '17' 'Discount C Fin' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZDISE1' '' '' '' '17' 'Discount E Fin' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZDISF1' '' '' '' '17' 'Discount F Fin' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZDISF3T' '' '' '' '17' 'Discount F3 Fin' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZDISF9T' '' '' '' '17' 'Discount F9 Fin' 'X' '' '' '' '' 'STWAE' '' '' '',
    'ZPMP' '' '' '' '17' 'Margin' 'X' '' '' '' '' 'STWAE' '' '' ''.
  PERFORM f_fieldcatg USING ft_report:
    'VOLFIN' '' '' '' '17' 'Discount Vol.Fin' 'X' '' '' '' '' 'STWAE' '' '' ''.
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
                          VALUE(fu_no_sign).

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
  ld_fieldcat-no_sign           = fu_no_sign.
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
  fu_layout-detail_popup       = 'X'.
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

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'PRODH1'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  CASE 'X'.
*    WHEN radio1.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'MATKL'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'MATNR'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'VKBUR'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*    WHEN radio2.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'VKBUR'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'PKUNWE'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'VBELN'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'MATNR'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*    WHEN radio3.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'MATKL'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'VKBUR'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'PKUNWE'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'MATNR'.
*      ld_sort-up        = 'X'.
*      ld_sort-subtot    = 'X'.
*      APPEND ld_sort TO fu_sort.
*  ENDCASE.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline1.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline1.

  PERFORM f_header.
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
  REFRESH: t_s626, t_kna1, t_makt, t_vdata.
  CLEAR: t_s626, t_kna1, t_makt, t_vdata.
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
  SET PF-STATUS 'STANDARD'.
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
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: ld_process TYPE i,
        wa_out     LIKE zsts626.

  SORT t_a603 BY prodh1.
  SORT t_vdata BY prodh1 sptag vkbur vbeln pkunwe matnr.
  SORT t_s626 BY prodh1 sptag vkbur vbeln pkunwe matnr.
  LOOP AT t_vdata.
    PERFORM f_calculate_disc USING t_vdata-sptag
                                   t_vdata-vkbur
                                   t_vdata-vbeln
                                   t_vdata-pkunwe
                                   t_vdata-prodh1
                                   t_vdata-matnr
                                   t_vdata-fkart
                                   t_vdata-matkl
                             CHANGING t_vdata-zdisvol
                                      t_vdata-tdisc
                                      t_vdata-volfin.

*    ld_process  = 1.
*    PERFORM f_selection_data USING t_vdata-vkbur
*                                   t_vdata-prodh1
*                                   t_vdata-matkl
*                             CHANGING ld_process.
*    IF ld_process EQ 1.

    IF pa_all IS NOT INITIAL.
      IF t_vdata-tdisc NE 0.
        t_out  = t_vdata.
        t_out-kdgrp = t_s626-kdgrp.
        t_out-kvgr3 = t_s626-kvgr3.
        t_out-zpmp  = t_s626-zpmp.
        APPEND t_out.
        PERFORM f_standard_list CHANGING wa_out.
        CASE 'X'.
          WHEN radio2.
            MOVE-CORRESPONDING wa_out TO t_out1.
            APPEND t_out1.
          WHEN radio3.
            MOVE-CORRESPONDING wa_out TO t_out2.
            APPEND t_out2.
          WHEN radio4.
            MOVE-CORRESPONDING wa_out TO t_out3.
            APPEND t_out3.
        ENDCASE.
      ENDIF.
    ELSE.
      t_out  = t_vdata.
      t_out-kdgrp = t_s626-kdgrp.
      t_out-kvgr3 = t_s626-kvgr3.
      t_out-zpmp  = t_s626-zpmp.
      APPEND t_out.
      PERFORM f_standard_list CHANGING wa_out.
      CASE 'X'.
        WHEN radio2.
          MOVE-CORRESPONDING wa_out TO t_out1.
          APPEND t_out1.
        WHEN radio3.
          MOVE-CORRESPONDING wa_out TO t_out2.
          APPEND t_out2.
        WHEN radio4.
          MOVE-CORRESPONDING wa_out TO t_out3.
          APPEND t_out3.
      ENDCASE.
    ENDIF.
*    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
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
*&      Form  F_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header .
  WRITE:/ 'Bulan      :', pa_spmon+4(2), '-', pa_spmon(4).
*  WRITE:/ 'Principal  :', t_vdata-prodh1.
ENDFORM.                    " F_header

*&---------------------------------------------------------------------*
*&      Form  f_selection_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_PROCESS  text
*----------------------------------------------------------------------*
FORM f_selection_data USING fd_vkbur
                            fd_prodh1
                            fd_matkl
                      CHANGING fd_process.
  IF fd_process EQ 1.
    IF so_vkbur[] IS NOT INITIAL.
      IF fd_vkbur IN so_vkbur.
        fd_process  = 1.
      ELSE.
        fd_process  = 0.
      ENDIF.
    ENDIF.
  ENDIF.
  IF fd_process EQ 1.
    IF so_prodh[] IS NOT INITIAL.
      IF fd_prodh1 IN so_prodh.
        fd_process  = 1.
      ELSE.
        fd_process  = 0.
      ENDIF.
    ENDIF.
  ENDIF.
  IF fd_process EQ 1.
    IF so_matkl[] IS NOT INITIAL.
      IF fd_matkl IN so_matkl.
        fd_process  = 1.
      ELSE.
        fd_process  = 0.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_selection_data

*&---------------------------------------------------------------------*
*&      Form  f_download_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_text .
  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl.

  DATA : l_dataset1(70) TYPE c,
         l_command(125) TYPE c.

  CONCATENATE pa_path 'ClaimDisc' sy-datum '.DBF'
        INTO l_dataset1.

* Open Dataset Consolidation
  OPEN DATASET l_dataset1 FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    DELETE DATASET l_dataset1.
    OPEN DATASET l_dataset1 FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  ELSE.
    OPEN DATASET l_dataset1 FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
  ENDIF.

* Write Dataset Consolidation
  LOOP AT t_out.
    t_dataset-type     = t_out-type.
    t_dataset-vbeln    = t_out-vbeln.
    t_dataset-prodh1   = t_out-prodh1.
    t_dataset-matkl    = t_out-matkl.
    t_dataset-matnr    = t_out-matnr.
    t_dataset-vkbur    = t_out-vkbur.
    t_dataset-sptag    = t_out-sptag.
    t_dataset-pkunwe   = t_out-pkunwe.
    t_dataset-name1    = t_out-name1.
    t_dataset-maktx    = t_out-maktx.
    t_dataset-stwae    = t_out-stwae.
    t_dataset-basme    = t_out-basme.
    t_dataset-gross    = t_out-gross.
    t_dataset-qty      = t_out-qty.
    t_dataset-zdisa    = t_out-zdisa.
    t_dataset-zdisb    = t_out-zdisb.
    t_dataset-prct1    = t_out-prct1.
    t_dataset-zdisc    = t_out-zdisc.
    t_dataset-prct2    = t_out-prct2.
    t_dataset-zdise    = t_out-zdise.
    t_dataset-prct3    = t_out-prct3.
    t_dataset-zdisf    = t_out-zdisf.
    t_dataset-prct4    = t_out-prct4.
    t_dataset-tdisc    = t_out-tdisc.
    TRANSFER t_dataset TO l_dataset1.
  ENDLOOP.

* Close Dataset Consolidation
  CLOSE DATASET l_dataset1.

* Change Mode 777
  CLEAR l_command.
  CONCATENATE 'chmod 777' l_dataset1 INTO l_command SEPARATED BY ' '.
  CALL 'SYSTEM' ID 'COMMAND' FIELD l_command
                ID 'TAB' FIELD tabl-*sys*.
ENDFORM.                    " f_download_text

*&---------------------------------------------------------------------*
*&      Form  f_standard_list1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_list1 .
  DATA: ld_zebra  TYPE i,
        ld_stwae  LIKE zsts626-stwae,
        ld_vkbur  LIKE zsts626-gross, ld_matnr  LIKE zsts626-gross, ld_matkl  LIKE zsts626-gross,
        ld_prodh1 LIKE zsts626-gross, ld_vbeln  LIKE zsts626-gross, ld_pkunwe LIKE zsts626-gross.
  DATA: ld_zdisa_vkbur  LIKE zsts626-zdisa, ld_zdisa_matnr  LIKE zsts626-zdisa, ld_zdisa_matkl  LIKE zsts626-zdisa,
        ld_zdisa_prodh1 LIKE zsts626-zdisa, ld_zdisa_vbeln  LIKE zsts626-zdisa, ld_zdisa_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisb_vkbur  LIKE zsts626-zdisa, ld_zdisb_matnr  LIKE zsts626-zdisa, ld_zdisb_matkl  LIKE zsts626-zdisa,
        ld_zdisb_prodh1 LIKE zsts626-zdisa, ld_zdisb_vbeln  LIKE zsts626-zdisa, ld_zdisb_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisc_vkbur  LIKE zsts626-zdisa, ld_zdisc_matnr  LIKE zsts626-zdisa, ld_zdisc_matkl  LIKE zsts626-zdisa,
        ld_zdisc_prodh1 LIKE zsts626-zdisa, ld_zdisc_vbeln  LIKE zsts626-zdisa, ld_zdisc_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdise_vkbur  LIKE zsts626-zdisa, ld_zdise_matnr  LIKE zsts626-zdisa, ld_zdise_matkl  LIKE zsts626-zdisa,
        ld_zdise_prodh1 LIKE zsts626-zdisa, ld_zdise_vbeln  LIKE zsts626-zdisa, ld_zdise_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisf_vkbur  LIKE zsts626-zdisa, ld_zdisf_matnr  LIKE zsts626-zdisa, ld_zdisf_matkl  LIKE zsts626-zdisa,
        ld_zdisf_prodh1 LIKE zsts626-zdisa, ld_zdisf_vbeln  LIKE zsts626-zdisa, ld_zdisf_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisf3_vkbur  LIKE zsts626-zdisa, ld_zdisf3_matnr  LIKE zsts626-zdisa, ld_zdisf3_matkl  LIKE zsts626-zdisa,
        ld_zdisf3_prodh1 LIKE zsts626-zdisa, ld_zdisf3_vbeln  LIKE zsts626-zdisa, ld_zdisf3_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisvol_vkbur  LIKE zsts626-zdisa, ld_zdisvol_matnr  LIKE zsts626-zdisa, ld_zdisvol_matkl  LIKE zsts626-zdisa,
        ld_zdisvol_prodh1 LIKE zsts626-zdisa, ld_zdisvol_vbeln  LIKE zsts626-zdisa, ld_zdisvol_pkunwe LIKE zsts626-zdisa.
  DATA: ld_tdisc_vkbur  LIKE zsts626-zdisa, ld_tdisc_matnr  LIKE zsts626-zdisa, ld_tdisc_matkl  LIKE zsts626-zdisa,
        ld_tdisc_prodh1 LIKE zsts626-zdisa, ld_tdisc_vbeln  LIKE zsts626-zdisa, ld_tdisc_pkunwe LIKE zsts626-zdisa.

  LOOP AT t_out1.
    va_prodh1  = t_out1-prodh1.
    IF ld_zebra IS INITIAL.
      ld_zebra = 1.
    ELSE.
      ld_zebra = 0.
    ENDIF.
    PERFORM f_zebra USING ld_zebra.

    ld_stwae  = t_out1-stwae.
    PERFORM f_add_data USING t_out1-gross
                             t_out1-zdisa
                             t_out1-zdisb
                             t_out1-zdisc
                             t_out1-zdise
                             t_out1-zdisf
                             t_out1-zdisf3
                             t_out1-zdisvol
                             t_out1-tdisc
                        CHANGING ld_vkbur ld_matnr ld_matkl ld_prodh1 ld_vbeln ld_pkunwe
                                 ld_zdisa_vkbur ld_zdisa_matnr ld_zdisa_matkl
                                 ld_zdisa_prodh1 ld_zdisa_vbeln ld_zdisa_pkunwe
                                 ld_zdisb_vkbur ld_zdisb_matnr ld_zdisb_matkl
                                 ld_zdisb_prodh1 ld_zdisb_vbeln ld_zdisb_pkunwe
                                 ld_zdisc_vkbur ld_zdisc_matnr ld_zdisc_matkl
                                 ld_zdisc_prodh1 ld_zdisc_vbeln ld_zdisc_pkunwe
                                 ld_zdise_vkbur ld_zdise_matnr ld_zdise_matkl
                                 ld_zdise_prodh1 ld_zdise_vbeln ld_zdise_pkunwe
                                 ld_zdisf_vkbur ld_zdisf_matnr ld_zdisf_matkl
                                 ld_zdisf_prodh1 ld_zdisf_vbeln ld_zdisf_pkunwe
                                 ld_zdisf3_vkbur ld_zdisf3_matnr ld_zdisf3_matkl
                                 ld_zdisf3_prodh1 ld_zdisf3_vbeln ld_zdisf3_pkunwe
                                 ld_zdisvol_vkbur ld_zdisvol_matnr ld_zdisvol_matkl
                                 ld_zdisvol_prodh1 ld_zdisvol_vbeln ld_zdisvol_pkunwe
                                 ld_tdisc_vkbur ld_tdisc_matnr ld_tdisc_matkl
                                 ld_tdisc_prodh1 ld_tdisc_vbeln ld_tdisc_pkunwe.

    PERFORM f_write_detail.

    AT END OF vkbur.
      PERFORM f_hdr_uline1.
      PERFORM f_total_vkbur USING t_out1-vkbur
                                  ld_stwae
                                  ld_vkbur ld_zdisa_vkbur ld_zdisb_vkbur
                                  ld_zdisc_vkbur ld_zdise_vkbur ld_zdisf_vkbur
                                  ld_zdisf3_vkbur ld_zdisvol_vkbur ld_tdisc_vkbur.
      CLEAR: ld_vkbur, ld_zebra,
             ld_zdisa_vkbur, ld_zdisb_vkbur, ld_zdisc_vkbur,
             ld_zdise_vkbur, ld_zdisf_vkbur, ld_zdisf3_vkbur,
             ld_zdisvol_vkbur, ld_tdisc_vkbur.
      PERFORM f_hdr_uline1.
    ENDAT.

    AT END OF matnr.
      PERFORM f_total_matnr USING t_out1-matnr
                                  ld_stwae
                                  ld_matnr ld_zdisa_matnr ld_zdisb_matnr
                                  ld_zdisc_matnr ld_zdise_matnr ld_zdisf_matnr
                                  ld_zdisf3_matnr ld_zdisvol_matnr ld_tdisc_matnr.
      CLEAR: ld_matnr, ld_zebra,
             ld_zdisa_matnr, ld_zdisb_matnr, ld_zdisc_matnr,
             ld_zdise_matnr, ld_zdisf_matnr,  ld_zdisf3_matnr,
             ld_zdisvol_matnr, ld_tdisc_matnr.
      PERFORM f_hdr_uline1.
    ENDAT.

    AT END OF matkl.
      PERFORM f_hdr_uline1.
      PERFORM f_total_matkl USING t_out1-matkl
                                  ld_stwae
                                  ld_matkl ld_zdisa_matkl ld_zdisb_matkl
                                  ld_zdisc_matkl ld_zdise_matkl ld_zdisf_matkl
                                  ld_zdisf3_matkl ld_zdisvol_matkl ld_tdisc_matkl.
      CLEAR: ld_matkl, ld_zebra,
             ld_zdisa_matkl, ld_zdisb_matkl, ld_zdisc_matkl,
             ld_zdise_matkl, ld_zdisf_matkl, ld_zdisf3_matkl,
             ld_zdisvol_matkl, ld_tdisc_matkl.
      PERFORM f_hdr_uline1.
    ENDAT.

    AT END OF prodh1.
      PERFORM f_total_prodh1 USING t_out1-prodh1
                                   ld_stwae
                                   ld_prodh1 ld_zdisa_prodh1 ld_zdisb_prodh1
                                   ld_zdisc_prodh1 ld_zdise_prodh1 ld_zdisf_prodh1
                                   ld_zdisf3_prodh1 ld_zdisvol_prodh1 ld_tdisc_prodh1.
      CLEAR: ld_prodh1, ld_zebra,
             ld_zdisa_prodh1, ld_zdisb_prodh1, ld_zdisc_prodh1,
             ld_zdise_prodh1, ld_zdisf_prodh1, ld_zdisf3_prodh1,
             ld_zdisvol_prodh1, ld_tdisc_prodh1.
      PERFORM f_hdr_uline1.
      NEW-PAGE.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " f_standard_list1

*&---------------------------------------------------------------------*
*&      Form  f_standard_list2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_list2 .
  DATA: ld_zebra  TYPE i,
        ld_stwae  LIKE zsts626-stwae,
        ld_vkbur  LIKE zsts626-gross, ld_matnr  LIKE zsts626-gross, ld_matkl  LIKE zsts626-gross,
        ld_prodh1 LIKE zsts626-gross, ld_vbeln  LIKE zsts626-gross, ld_pkunwe LIKE zsts626-gross.
  DATA: ld_zdisa_vkbur  LIKE zsts626-zdisa, ld_zdisa_matnr  LIKE zsts626-zdisa,
        ld_zdisa_matkl  LIKE zsts626-zdisa, ld_zdisa_prodh1 LIKE zsts626-zdisa,
        ld_zdisa_vbeln  LIKE zsts626-zdisa, ld_zdisa_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisb_vkbur  LIKE zsts626-zdisa, ld_zdisb_matnr  LIKE zsts626-zdisa,
        ld_zdisb_matkl  LIKE zsts626-zdisa, ld_zdisb_prodh1 LIKE zsts626-zdisa,
        ld_zdisb_vbeln  LIKE zsts626-zdisa, ld_zdisb_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisc_vkbur  LIKE zsts626-zdisa, ld_zdisc_matnr  LIKE zsts626-zdisa,
        ld_zdisc_matkl  LIKE zsts626-zdisa, ld_zdisc_prodh1 LIKE zsts626-zdisa,
        ld_zdisc_vbeln  LIKE zsts626-zdisa, ld_zdisc_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdise_vkbur  LIKE zsts626-zdisa, ld_zdise_matnr  LIKE zsts626-zdisa,
        ld_zdise_matkl  LIKE zsts626-zdisa, ld_zdise_prodh1 LIKE zsts626-zdisa,
        ld_zdise_vbeln  LIKE zsts626-zdisa, ld_zdise_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisf_vkbur  LIKE zsts626-zdisa, ld_zdisf_matnr  LIKE zsts626-zdisa,
        ld_zdisf_matkl  LIKE zsts626-zdisa, ld_zdisf_prodh1 LIKE zsts626-zdisa,
        ld_zdisf_vbeln  LIKE zsts626-zdisa, ld_zdisf_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisf3_vkbur  LIKE zsts626-zdisa, ld_zdisf3_matnr  LIKE zsts626-zdisa,
        ld_zdisf3_matkl  LIKE zsts626-zdisa, ld_zdisf3_prodh1 LIKE zsts626-zdisa,
        ld_zdisf3_vbeln  LIKE zsts626-zdisa, ld_zdisf3_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisvol_vkbur  LIKE zsts626-zdisa, ld_zdisvol_matnr  LIKE zsts626-zdisa,
        ld_zdisvol_matkl  LIKE zsts626-zdisa, ld_zdisvol_prodh1 LIKE zsts626-zdisa,
        ld_zdisvol_vbeln  LIKE zsts626-zdisa, ld_zdisvol_pkunwe LIKE zsts626-zdisa.
  DATA: ld_tdisc_vkbur  LIKE zsts626-zdisa, ld_tdisc_matnr  LIKE zsts626-zdisa,
        ld_tdisc_matkl  LIKE zsts626-zdisa, ld_tdisc_prodh1 LIKE zsts626-zdisa,
        ld_tdisc_vbeln  LIKE zsts626-zdisa, ld_tdisc_pkunwe LIKE zsts626-zdisa.

  LOOP AT t_out2.
    va_prodh1  = t_out2-prodh1.
    IF ld_zebra IS INITIAL.
      ld_zebra = 1.
    ELSE.
      ld_zebra = 0.
    ENDIF.
    PERFORM f_zebra USING ld_zebra.

    ld_stwae  = t_out2-stwae.

    PERFORM f_add_data USING t_out2-gross
                             t_out2-zdisa
                             t_out2-zdisb
                             t_out2-zdisc
                             t_out2-zdise
                             t_out2-zdisf
                             t_out2-zdisf3
                             t_out2-zdisvol
                             t_out2-tdisc
                        CHANGING ld_vkbur ld_matnr ld_matkl ld_prodh1 ld_vbeln ld_pkunwe
                                 ld_zdisa_vkbur ld_zdisa_matnr ld_zdisa_matkl
                                 ld_zdisa_prodh1 ld_zdisa_vbeln ld_zdisa_pkunwe
                                 ld_zdisb_vkbur ld_zdisb_matnr ld_zdisb_matkl
                                 ld_zdisb_prodh1 ld_zdisb_vbeln ld_zdisb_pkunwe
                                 ld_zdisc_vkbur ld_zdisc_matnr ld_zdisc_matkl
                                 ld_zdisc_prodh1 ld_zdisc_vbeln ld_zdisc_pkunwe
                                 ld_zdise_vkbur ld_zdise_matnr ld_zdise_matkl
                                 ld_zdise_prodh1 ld_zdise_vbeln ld_zdise_pkunwe
                                 ld_zdisf_vkbur ld_zdisf_matnr ld_zdisf_matkl
                                 ld_zdisf_prodh1 ld_zdisf_vbeln ld_zdisf_pkunwe
                                 ld_zdisf3_vkbur ld_zdisf3_matnr ld_zdisf3_matkl
                                 ld_zdisf3_prodh1 ld_zdisf3_vbeln ld_zdisf3_pkunwe
                                 ld_zdisvol_vkbur ld_zdisvol_matnr ld_zdisvol_matkl
                                 ld_zdisvol_prodh1 ld_zdisvol_vbeln ld_zdisvol_pkunwe
                                 ld_tdisc_vkbur ld_tdisc_matnr ld_tdisc_matkl
                                 ld_tdisc_prodh1 ld_tdisc_vbeln ld_tdisc_pkunwe.

    PERFORM f_write_detail.

*    AT END OF matnr.
*      PERFORM f_hdr_uline1.
*      PERFORM f_total_matnr USING t_out2-matnr
*                                  ld_stwae
*                                  ld_matnr.
*      CLEAR: ld_matnr, ld_zebra.
*      PERFORM f_hdr_uline1.
*    ENDAT.

    AT END OF vbeln.
      PERFORM f_hdr_uline1.
      PERFORM f_total_vbeln USING t_out2-vbeln
                                  ld_stwae
                                  ld_vbeln ld_zdisa_vbeln ld_zdisb_vbeln
                                  ld_zdisc_vbeln ld_zdise_vbeln ld_zdisf_vbeln
                                  ld_zdisf3_vbeln ld_zdisvol_vbeln ld_tdisc_vbeln.
      CLEAR: ld_vbeln, ld_zebra,
             ld_zdisa_vbeln, ld_zdisb_vbeln, ld_zdisc_vbeln,
             ld_zdise_vbeln, ld_zdisf_vbeln, ld_zdisf3_vbeln,
             ld_zdisvol_vbeln, ld_tdisc_vbeln.
      PERFORM f_hdr_uline1.
    ENDAT.

*    AT END OF pkunwe.
*      PERFORM f_total_pkunwe USING t_out2-pkunwe
*                                   ld_stwae
*                                   ld_pkunwe.
*      CLEAR: ld_pkunwe, ld_zebra.
*      PERFORM f_hdr_uline1.
*    ENDAT.

    AT END OF vkbur.
      PERFORM f_total_vkbur USING t_out2-vkbur
                                  ld_stwae
                                  ld_vkbur ld_zdisa_vkbur ld_zdisb_vkbur
                                  ld_zdisc_vkbur ld_zdise_vkbur ld_zdisf_vkbur
                                  ld_zdisf3_vkbur ld_zdisvol_vkbur ld_tdisc_vkbur.
      CLEAR: ld_vkbur, ld_zebra,
             ld_zdisa_vkbur, ld_zdisb_vkbur, ld_zdisc_vkbur,
             ld_zdise_vkbur, ld_zdisf_vkbur, ld_zdisf3_vkbur,
             ld_zdisvol_vkbur, ld_tdisc_vkbur.
      PERFORM f_hdr_uline1.
    ENDAT.

    AT END OF prodh1.
      PERFORM f_total_prodh1 USING t_out2-prodh1
                                   ld_stwae
                                   ld_prodh1 ld_zdisa_prodh1 ld_zdisb_prodh1
                                   ld_zdisc_prodh1 ld_zdise_prodh1 ld_zdisf_prodh1
                                   ld_zdisf3_prodh1 ld_zdisvol_prodh1 ld_tdisc_prodh1.
      CLEAR: ld_prodh1, ld_zebra,
             ld_zdisa_prodh1, ld_zdisb_prodh1, ld_zdisc_prodh1,
             ld_zdise_prodh1, ld_zdisf_prodh1, ld_zdisf3_prodh1,
             ld_zdisvol_prodh1, ld_tdisc_prodh1.
      PERFORM f_hdr_uline1.
      NEW-PAGE.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " f_standard_list2

*&---------------------------------------------------------------------*
*&      Form  f_standard_list3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_list3.
  DATA: ld_zebra  TYPE i,
        ld_stwae  LIKE zsts626-stwae,
        ld_vkbur  LIKE zsts626-gross, ld_matnr  LIKE zsts626-gross, ld_matkl  LIKE zsts626-gross,
        ld_prodh1 LIKE zsts626-gross, ld_vbeln  LIKE zsts626-gross, ld_pkunwe LIKE zsts626-gross.
  DATA: ld_zdisa_vkbur  LIKE zsts626-zdisa, ld_zdisa_matnr  LIKE zsts626-zdisa, ld_zdisa_matkl  LIKE zsts626-zdisa,
        ld_zdisa_prodh1 LIKE zsts626-zdisa, ld_zdisa_vbeln  LIKE zsts626-zdisa, ld_zdisa_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisb_vkbur  LIKE zsts626-zdisa, ld_zdisb_matnr  LIKE zsts626-zdisa, ld_zdisb_matkl  LIKE zsts626-zdisa,
        ld_zdisb_prodh1 LIKE zsts626-zdisa, ld_zdisb_vbeln  LIKE zsts626-zdisa, ld_zdisb_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisc_vkbur  LIKE zsts626-zdisa, ld_zdisc_matnr  LIKE zsts626-zdisa, ld_zdisc_matkl  LIKE zsts626-zdisa,
        ld_zdisc_prodh1 LIKE zsts626-zdisa, ld_zdisc_vbeln  LIKE zsts626-zdisa, ld_zdisc_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdise_vkbur  LIKE zsts626-zdisa, ld_zdise_matnr  LIKE zsts626-zdisa, ld_zdise_matkl  LIKE zsts626-zdisa,
        ld_zdise_prodh1 LIKE zsts626-zdisa, ld_zdise_vbeln  LIKE zsts626-zdisa, ld_zdise_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisf_vkbur  LIKE zsts626-zdisa, ld_zdisf_matnr  LIKE zsts626-zdisa, ld_zdisf_matkl  LIKE zsts626-zdisa,
        ld_zdisf_prodh1 LIKE zsts626-zdisa, ld_zdisf_vbeln  LIKE zsts626-zdisa, ld_zdisf_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisf3_vkbur  LIKE zsts626-zdisa, ld_zdisf3_matnr  LIKE zsts626-zdisa, ld_zdisf3_matkl  LIKE zsts626-zdisa,
        ld_zdisf3_prodh1 LIKE zsts626-zdisa, ld_zdisf3_vbeln  LIKE zsts626-zdisa, ld_zdisf3_pkunwe LIKE zsts626-zdisa.
  DATA: ld_zdisvol_vkbur  LIKE zsts626-zdisa, ld_zdisvol_matnr  LIKE zsts626-zdisa, ld_zdisvol_matkl  LIKE zsts626-zdisa,
        ld_zdisvol_prodh1 LIKE zsts626-zdisa, ld_zdisvol_vbeln  LIKE zsts626-zdisa, ld_zdisvol_pkunwe LIKE zsts626-zdisa.
  DATA: ld_tdisc_vkbur  LIKE zsts626-zdisa, ld_tdisc_matnr  LIKE zsts626-zdisa, ld_tdisc_matkl  LIKE zsts626-zdisa,
        ld_tdisc_prodh1 LIKE zsts626-zdisa, ld_tdisc_vbeln  LIKE zsts626-zdisa, ld_tdisc_pkunwe LIKE zsts626-zdisa.

  LOOP AT t_out3.
    va_prodh1  = t_out3-prodh1.
    IF ld_zebra IS INITIAL.
      ld_zebra = 1.
    ELSE.
      ld_zebra = 0.
    ENDIF.
    PERFORM f_zebra USING ld_zebra.

    ld_stwae  = t_out3-stwae.

    PERFORM f_add_data USING t_out3-gross
                             t_out3-zdisa
                             t_out3-zdisb
                             t_out3-zdisc
                             t_out3-zdise
                             t_out3-zdisf
                             t_out3-zdisf3
                             t_out3-zdisvol
                             t_out3-tdisc
                        CHANGING ld_vkbur ld_matnr ld_matkl ld_prodh1 ld_vbeln ld_pkunwe
                                 ld_zdisa_vkbur ld_zdisa_matnr ld_zdisa_matkl
                                 ld_zdisa_prodh1 ld_zdisa_vbeln ld_zdisa_pkunwe
                                 ld_zdisb_vkbur ld_zdisb_matnr ld_zdisb_matkl
                                 ld_zdisb_prodh1 ld_zdisb_vbeln ld_zdisb_pkunwe
                                 ld_zdisc_vkbur ld_zdisc_matnr ld_zdisc_matkl
                                 ld_zdisc_prodh1 ld_zdisc_vbeln ld_zdisc_pkunwe
                                 ld_zdise_vkbur ld_zdise_matnr ld_zdise_matkl
                                 ld_zdise_prodh1 ld_zdise_vbeln ld_zdise_pkunwe
                                 ld_zdisf_vkbur ld_zdisf_matnr ld_zdisf_matkl
                                 ld_zdisf_prodh1 ld_zdisf_vbeln ld_zdisf_pkunwe
                                 ld_zdisf3_vkbur ld_zdisf3_matnr ld_zdisf3_matkl
                                 ld_zdisf3_prodh1 ld_zdisf3_vbeln ld_zdisf3_pkunwe
                                 ld_zdisvol_vkbur ld_zdisvol_matnr ld_zdisvol_matkl
                                 ld_zdisvol_prodh1 ld_zdisvol_vbeln ld_zdisvol_pkunwe
                                 ld_tdisc_vkbur ld_tdisc_matnr ld_tdisc_matkl
                                 ld_tdisc_prodh1 ld_tdisc_vbeln ld_tdisc_pkunwe.

    PERFORM f_write_detail.

*    AT END OF matnr.
*      PERFORM f_hdr_uline1.
*      PERFORM f_total_matnr USING t_out3-matnr
*                                  ld_stwae
*                                  ld_matnr.
*      CLEAR: ld_matnr, ld_zebra.
*      PERFORM f_hdr_uline1.
*    ENDAT.

*    AT END OF pkunwe.
*      PERFORM f_total_pkunwe USING t_out3-pkunwe
*                                   ld_stwae
*                                   ld_pkunwe.
*      CLEAR: ld_pkunwe, ld_zebra.
*      PERFORM f_hdr_uline1.
*    ENDAT.

    AT END OF vkbur.
      PERFORM f_hdr_uline1.
      PERFORM f_total_vkbur USING t_out3-vkbur
                                  ld_stwae
                                  ld_vkbur ld_zdisa_vkbur ld_zdisb_vkbur
                                  ld_zdisc_vkbur ld_zdise_vkbur ld_zdisf_vkbur
                                  ld_zdisf3_vkbur ld_zdisvol_vkbur ld_tdisc_vkbur.
      CLEAR: ld_vkbur, ld_zebra,
             ld_zdisa_vkbur, ld_zdisb_vkbur, ld_zdisc_vkbur,
             ld_zdise_vkbur, ld_zdisf_vkbur, ld_zdisf3_vkbur,
             ld_zdisvol_vkbur, ld_tdisc_vkbur.
      PERFORM f_hdr_uline1.
    ENDAT.

    AT END OF matkl.
      PERFORM f_total_matkl USING t_out3-matkl
                                  ld_stwae
                                  ld_matkl ld_zdisa_matkl ld_zdisb_matkl
                                  ld_zdisc_matkl ld_zdise_matkl ld_zdisf_matkl
                                  ld_zdisf3_matkl ld_zdisvol_matkl ld_tdisc_matkl.
      CLEAR: ld_matkl, ld_zebra,
             ld_zdisa_matkl, ld_zdisb_matkl, ld_zdisc_matkl,
             ld_zdise_matkl, ld_zdisf_matkl, ld_zdisf3_matkl,
             ld_zdisvol_matkl, ld_tdisc_matkl.
      PERFORM f_hdr_uline1.
    ENDAT.

    AT END OF prodh1.
      PERFORM f_total_prodh1 USING t_out3-prodh1
                                   ld_stwae
                                   ld_prodh1 ld_zdisa_prodh1 ld_zdisb_prodh1
                                   ld_zdisc_prodh1 ld_zdise_prodh1 ld_zdisf_prodh1
                                   ld_zdisf3_prodh1 ld_zdisvol_prodh1 ld_tdisc_prodh1.
      CLEAR: ld_prodh1, ld_zebra,
             ld_zdisa_prodh1, ld_zdisb_prodh1, ld_zdisc_prodh1,
             ld_zdise_prodh1, ld_zdisf_prodh1, ld_zdisf3_prodh1,
             ld_zdisvol_prodh1, ld_tdisc_prodh1.
      PERFORM f_hdr_uline1.
      NEW-PAGE.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " f_standard_list3

*&---------------------------------------------------------------------*
*&      Form  f_hdrline_standard
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_TITLE  text
*----------------------------------------------------------------------*
FORM f_hdrline_standard  USING fu_title.
  DATA: page_number(10) VALUE 'Page: nnnn',
        principal(42),
        ld_month(20),
        ld_sort(100),
        page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.

  CONCATENATE 'Bulan :' pa_spmon+4(2) '-' pa_spmon(4) INTO ld_month
  SEPARATED BY space.

*--- Output line
  PERFORM f_hdrpad_standard USING '' fu_title page_number.
  PERFORM f_hdrpad_standard USING '' ld_month ''.
  SKIP 1.
  CASE 'X'.
    WHEN radio2.
      ld_sort  = 'Sort by Principal, Material Group, Material, Sales Office'.
    WHEN radio3.
      ld_sort  = 'Sort by Principal, Sales Office, Customer, No.Document, Material'.
    WHEN radio4.
      ld_sort  = 'Sort by Principal, Material Group, Sales Office, Customer, Material'.
  ENDCASE.
  PERFORM f_hdrpad_standard USING ld_sort '' ''.
  CONCATENATE 'Principal :' va_prodh1 INTO principal SEPARATED BY space.
  PERFORM f_hdrpad_standard USING principal '' ''.
*  IF radio4 IS NOT INITIAL.
  SKIP.
*  ENDIF.
ENDFORM.                    " f_hdrline_standard

*&---------------------------------------------------------------------*
*&      Form  f_hdrpad_standard
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PROGNAME  text
*      -->P_1393   text
*      -->P_PAGE_NUMBER  text
*----------------------------------------------------------------------*
FORM f_hdrpad_standard  USING v_left_text v_middle_text v_right_text.
  DATA:
    page_width    TYPE i,       " Width of page
    middle_length TYPE i,    " Length of title text
    left_length   TYPE i,      " Length of left text
    right_length  TYPE i,     " Length of right text
    left_start    TYPE i,       " Position on line for start of left tex
    middle_start  TYPE i,     " Position on line for start of middl tex
    right_start   TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
*  IF radio4 IS INITIAL.
*    page_width = sy-linsz - 1.
*  ELSE.
  page_width = 248.
*  ENDIF.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = strlen( v_middle_text ).
  COMPUTE left_length = strlen( v_left_text ).
  COMPUTE right_length = strlen( v_right_text ).

*  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.
  COMPUTE middle_start = ( page_width - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
*  right_start = sy-linsz - left_start - right_length - 1.
  right_start = page_width - left_start - right_length - 1.
  WRITE:/ space.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
ENDFORM.                    " f_hdr_pad_title_standard

*&---------------------------------------------------------------------*
*&      Form  f_zebra
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_ZEBRA  text
*----------------------------------------------------------------------*
FORM f_zebra  USING fd_zebra.
  CASE fd_zebra.
    WHEN 0.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED ON.
    WHEN 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
  ENDCASE.
ENDFORM.                    " f_zebra

*&---------------------------------------------------------------------*
*&      Form  f_top_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_top_header .
  FORMAT COLOR 1.
*  IF radio4 IS INITIAL.
*    WRITE:/ sy-vline NO-GAP, 'Ty' NO-GAP,
*            sy-vline NO-GAP, (10) 'Bill.Doc.' NO-GAP,
*            sy-vline NO-GAP, (10) 'Date' NO-GAP,
*            sy-vline NO-GAP, (10) 'Customer' NO-GAP,
*            sy-vline NO-GAP, (17) 'Customer Name' NO-GAP,
*            sy-vline NO-GAP, (9) 'Matl Grp.' NO-GAP,
*            sy-vline NO-GAP, (9) 'Material' NO-GAP,
*            sy-vline NO-GAP, (33) 'Material Description' NO-GAP,
*            sy-vline NO-GAP, (13) 'Gross' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (11) 'Qty' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Discount A' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Discount B' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Discount C' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Discount E' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Discount F' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Discount F3' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Discount Vol.' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline NO-GAP, (13) 'Total Disc.' RIGHT-JUSTIFIED NO-GAP,
*            sy-vline.
*  ELSE.
  WRITE:/ sy-vline NO-GAP, 'Ty' NO-GAP,
          sy-vline NO-GAP, (10) 'Bill.Doc.' NO-GAP,
          sy-vline NO-GAP, (10) 'Date' NO-GAP,
          sy-vline NO-GAP, (10) 'Customer' NO-GAP,
          sy-vline NO-GAP, (17) 'Customer Name' NO-GAP,
          sy-vline NO-GAP, (9) 'Matl Grp.' NO-GAP,
          sy-vline NO-GAP, (9) 'Material' NO-GAP,
          sy-vline NO-GAP, (33) 'Material Description' NO-GAP,
          sy-vline NO-GAP, (13) 'Gross' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (11) 'Qty' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Discount A' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Discount B' RIGHT-JUSTIFIED NO-GAP,
*          sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Discount C' RIGHT-JUSTIFIED NO-GAP,
*          sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Discount E' RIGHT-JUSTIFIED NO-GAP,
*          sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Discount F' RIGHT-JUSTIFIED NO-GAP,
*          sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Discount F3' RIGHT-JUSTIFIED NO-GAP,
*          sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Discount Vol.' RIGHT-JUSTIFIED NO-GAP,
*          sy-vline NO-GAP, (8) '%' RIGHT-JUSTIFIED NO-GAP,
          sy-vline NO-GAP, (13) 'Total Disc.' RIGHT-JUSTIFIED NO-GAP,
          sy-vline.
*  ENDIF.
  FORMAT COLOR OFF.
ENDFORM.                    " f_top_header

*&---------------------------------------------------------------------*
*&      Form  f_total_prodh1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_PRODH1  text
*----------------------------------------------------------------------*
FORM f_total_prodh1 USING fd_prodh1
                          fd_stwae
                          fd_gross fd_zdisa fd_zdisb
                          fd_zdisc fd_zdise fd_zdisf
                          fd_zdisf3 fd_zdisvol fd_tdisc.
  DATA: ld_total(105).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
  CONCATENATE 'Total Principal :' fd_prodh1 INTO ld_total
  SEPARATED BY space.

*  IF radio4 IS INITIAL.
*    WRITE:/ sy-vline, ld_total,
*            sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
*            sy-vline NO-GAP, (11) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline.
*  ELSE.
  WRITE:/ sy-vline, ld_total,
          sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (11) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-GAP,
          sy-vline.
*  ENDIF.
ENDFORM.                    " f_total_prodh1

*&---------------------------------------------------------------------*
*&      Form  f_total_matkl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_MATKL  text
*----------------------------------------------------------------------*
FORM f_total_matkl USING fd_matkl
                         fd_stwae
                         fd_gross fd_zdisa fd_zdisb
                         fd_zdisc fd_zdise fd_zdisf
                         fd_zdisf3 fd_zdisvol fd_tdisc.
  DATA: ld_total(105).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
  CONCATENATE 'Total Material Group :' fd_matkl INTO ld_total
  SEPARATED BY space.

*  IF radio4 IS INITIAL.
*    WRITE:/ sy-vline, ld_total,
*            sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
*            sy-vline NO-GAP, (11) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline.
*  ELSE.
  WRITE:/ sy-vline, ld_total,
          sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (11) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-GAP,
          sy-vline.
*  ENDIF.
ENDFORM.                    " f_total_matkl

*&---------------------------------------------------------------------*
*&      Form  f_total_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_MATNR  text
*----------------------------------------------------------------------*
FORM f_total_matnr USING fd_matnr
                         fd_stwae
                         fd_gross fd_zdisa fd_zdisb
                         fd_zdisc fd_zdise fd_zdisf
                         fd_zdisf3 fd_zdisvol fd_tdisc.
  DATA: ld_total(105).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
  CONCATENATE 'Total Material :' fd_matnr INTO ld_total
  SEPARATED BY space.

  WRITE:/ sy-vline, ld_total,
          sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (11) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-GAP,
          sy-vline.
ENDFORM.                    " f_total_matnr

*&---------------------------------------------------------------------*
*&      Form  f_total_vkbur
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_VKBUR  text
*----------------------------------------------------------------------*
FORM f_total_vkbur USING fd_vkbur
                         fd_stwae
                         fd_gross fd_zdisa fd_zdisb
                         fd_zdisc fd_zdise fd_zdisf
                         fd_zdisf3 fd_zdisvol fd_tdisc.
  DATA: ld_total(105).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
  CONCATENATE 'Total Sales Office :' fd_vkbur INTO ld_total
  SEPARATED BY space.

*  IF radio4 IS INITIAL.
*    WRITE:/ sy-vline, ld_total,
*            sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
*            sy-vline NO-GAP, (11) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline NO-GAP, (8) space NO-GAP,
*            sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-SIGN NO-GAP,
*            sy-vline.
*  ELSE.
  WRITE:/ sy-vline, ld_total,
          sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (11) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-GAP,
          sy-vline.
*  ENDIF.
ENDFORM.                    " f_total_vkbur

*&---------------------------------------------------------------------*
*&      Form  f_total_pkunwe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_PKUNWE  text
*----------------------------------------------------------------------*
FORM f_total_pkunwe USING fd_pkunwe
                          fd_stwae
                          fd_gross fd_zdisa fd_zdisb
                          fd_zdisc fd_zdise fd_zdisf.
  DATA: ld_total(105).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
  CONCATENATE 'Total Customer :' fd_pkunwe INTO ld_total
  SEPARATED BY space.

  WRITE:/ sy-vline, ld_total,
          sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (11) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) space NO-GAP,
          sy-vline.
ENDFORM.                    " f_total_pkunwe

*&---------------------------------------------------------------------*
*&      Form  f_total_vbeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FD_VBELN  text
*----------------------------------------------------------------------*
FORM f_total_vbeln USING fd_vbeln
                         fd_stwae
                         fd_gross fd_zdisa fd_zdisb
                         fd_zdisc fd_zdise fd_zdisf
                         fd_zdisf3 fd_zdisvol fd_tdisc.
  DATA: ld_total(105).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.
  CONCATENATE 'Total No.Document :' fd_vbeln INTO ld_total
  SEPARATED BY space.

  WRITE:/ sy-vline, ld_total,
          sy-vline NO-GAP, (13) fd_gross CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (11) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisa CURRENCY fd_stwae NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisb CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisc CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdise CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisf3 CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_zdisvol CURRENCY fd_stwae NO-GAP,
*          sy-vline NO-GAP, (8) space NO-GAP,
          sy-vline NO-GAP, (13) fd_tdisc CURRENCY fd_stwae NO-GAP,
          sy-vline.
ENDFORM.                    " f_total_vbeln

*&---------------------------------------------------------------------*
*&      Form  f_standard_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_standard_list CHANGING ft_out STRUCTURE zsts626.
  ft_out-prodh1  = t_out-prodh1.
  ft_out-matkl   = t_out-matkl.
  ft_out-matnr   = t_out-matnr.
  ft_out-vkbur   = t_out-vkbur.
  ft_out-type    = t_out-type.
  ft_out-vbeln   = t_out-vbeln.
  ft_out-sptag   = t_out-sptag.
  ft_out-pkunwe  = t_out-pkunwe.
  ft_out-name1   = t_out-name1.
  ft_out-maktx   = t_out-maktx.
  ft_out-stwae   = t_out-stwae.
  ft_out-basme   = t_out-basme.
  ft_out-gross   = t_out-gross.
  ft_out-qty     = t_out-qty.
  ft_out-zdisa   = t_out-zdisa.
  ft_out-zdisb   = t_out-zdisb.
  ft_out-prct1   = t_out-prct1.
  ft_out-zdisc   = t_out-zdisc.
  ft_out-prct2   = t_out-prct2.
  ft_out-zdise   = t_out-zdise.
  ft_out-prct3   = t_out-prct3.
  ft_out-zdisf   = t_out-zdisf.
  ft_out-prct4   = t_out-prct4.
  ft_out-zdisf3   = t_out-zdisf3.
  ft_out-prct5   = t_out-prct5.
  ft_out-zdisvol = t_out-zdisvol.
  ft_out-prct6   = t_out-prct6.
  ft_out-tdisc   = t_out-tdisc.
ENDFORM.                    " f_standard_list

*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
  CASE 'X'.
    WHEN radio2.
      WRITE:/ sy-vline NO-GAP, t_out1-type NO-GAP,
              sy-vline NO-GAP, t_out1-vbeln NO-GAP,
              sy-vline NO-GAP, t_out1-sptag NO-GAP,
              sy-vline NO-GAP, t_out1-pkunwe NO-GAP,
              sy-vline NO-GAP, (17) t_out1-name1 NO-GAP,
              sy-vline NO-GAP, t_out1-matkl NO-GAP,
              sy-vline NO-GAP, (9) t_out1-matnr NO-GAP,
              sy-vline NO-GAP, (33) t_out1-maktx NO-GAP,
              sy-vline NO-GAP, (13) t_out1-gross CURRENCY t_out1-stwae NO-GAP,
              sy-vline NO-GAP, (11) t_out1-qty UNIT t_out1-basme NO-GAP,
              sy-vline NO-GAP, (13) t_out1-zdisa CURRENCY t_out1-stwae NO-GAP,
              sy-vline NO-GAP, (13) t_out1-zdisb CURRENCY t_out1-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out1-prct1 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out1-zdisc CURRENCY t_out1-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out1-prct2 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out1-zdise CURRENCY t_out1-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out1-prct3 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out1-zdisf CURRENCY t_out1-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out1-prct4 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out1-zdisf3 CURRENCY t_out1-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out1-prct5 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out1-zdisvol CURRENCY t_out1-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out1-prct6 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out1-tdisc CURRENCY t_out1-stwae NO-GAP,
              sy-vline.
    WHEN radio3.
      WRITE:/ sy-vline NO-GAP, t_out2-type NO-GAP,
              sy-vline NO-GAP, t_out2-vbeln NO-GAP,
              sy-vline NO-GAP, t_out2-sptag NO-GAP,
              sy-vline NO-GAP, t_out2-pkunwe NO-GAP,
              sy-vline NO-GAP, (17) t_out2-name1 NO-GAP,
              sy-vline NO-GAP, t_out2-matkl NO-GAP,
              sy-vline NO-GAP, (9) t_out2-matnr NO-GAP,
              sy-vline NO-GAP, (33) t_out2-maktx NO-GAP,
              sy-vline NO-GAP, (13) t_out2-gross CURRENCY t_out2-stwae NO-GAP,
              sy-vline NO-GAP, (11) t_out2-qty UNIT t_out2-basme NO-GAP,
              sy-vline NO-GAP, (13) t_out2-zdisa CURRENCY t_out2-stwae NO-GAP,
              sy-vline NO-GAP, (13) t_out2-zdisb CURRENCY t_out2-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out2-prct1 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out2-zdisc CURRENCY t_out2-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out2-prct2 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out2-zdise CURRENCY t_out2-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out2-prct3 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out2-zdisf CURRENCY t_out2-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out2-prct4 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out2-zdisf3 CURRENCY t_out2-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out2-prct5 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out2-zdisvol CURRENCY t_out2-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out2-prct6 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out2-tdisc CURRENCY t_out2-stwae NO-GAP,
              sy-vline.
    WHEN radio4.
      WRITE:/ sy-vline NO-GAP, t_out3-type NO-GAP,
              sy-vline NO-GAP, t_out3-vbeln NO-GAP,
              sy-vline NO-GAP, t_out3-sptag NO-GAP,
              sy-vline NO-GAP, t_out3-pkunwe NO-GAP,
              sy-vline NO-GAP, (17) t_out3-name1 NO-GAP,
              sy-vline NO-GAP, t_out3-matkl NO-GAP,
              sy-vline NO-GAP, (9) t_out3-matnr NO-GAP,
              sy-vline NO-GAP, (33) t_out3-maktx NO-GAP,
              sy-vline NO-GAP, (13) t_out3-gross CURRENCY t_out3-stwae NO-GAP,
              sy-vline NO-GAP, (11) t_out3-qty UNIT t_out3-basme NO-GAP,
              sy-vline NO-GAP, (13) t_out3-zdisa CURRENCY t_out3-stwae NO-GAP,
              sy-vline NO-GAP, (13) t_out3-zdisb CURRENCY t_out3-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out3-prct1 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out3-zdisc CURRENCY t_out3-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out3-prct2 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out3-zdise CURRENCY t_out3-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out3-prct3 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out3-zdisf CURRENCY t_out3-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out3-prct4 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out3-zdisf3 CURRENCY t_out3-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out3-prct5 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out3-zdisvol CURRENCY t_out3-stwae NO-GAP,
*              sy-vline NO-GAP, (8) t_out3-prct6 NO-SIGN NO-GAP,
              sy-vline NO-GAP, (13) t_out3-tdisc CURRENCY t_out3-stwae NO-GAP,
              sy-vline.
  ENDCASE.
ENDFORM.                    " f_write_detail

*&---------------------------------------------------------------------*
*&      Form  f_add_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_OUT1_GROSS  text
*      -->FU_ZDISA  text
*      -->FU_ZDISB  text
*      -->FU_ZDISC  text
*      -->FU_ZDISE  text
*      -->FU_ZDISF  text
*      <--FC_VKBUR  text
*      <--FC_MATNR  text
*      <--FC_MATKL  text
*      <--FC_PRODH1  text
*      <--FC_VBELN  text
*      <--FC_PKUNWE  text
*      <--FC_ZDISA_VKBUR  text
*      <--FC_ZDISA_MATNR  text
*      <--FC_ZDISA_MATKL  text
*      <--FC_ZDISA_PRODH1  text
*      <--FC_ZDISA_VBELN  text
*      <--FC_ZDISA_PKUNWE  text
*      <--FC_ZDISB_VKBUR  text
*      <--FC_ZDISB_MATNR  text
*      <--FC_ZDISB_MATKL  text
*      <--FC_ZDISB_PRODH1  text
*      <--FC_ZDISB_VBELN  text
*      <--FC_ZDISB_PKUNWE  text
*      <--FC_ZDISC_VKBUR  text
*      <--FC_ZDISC_MATNR  text
*      <--FC_ZDISC_MATKL  text
*      <--FC_ZDISC_PRODH1  text
*      <--FC_ZDISC_VBELN  text
*      <--FC_ZDISC_PKUNWE  text
*      <--FC_ZDISE_VKBUR  text
*      <--FC_ZDISE_MATNR  text
*      <--FC_ZDISE_MATKL  text
*      <--FC_ZDISE_PRODH1  text
*      <--FC_ZDISE_VBELN  text
*      <--FC_ZDISE_PKUNWE  text
*      <--FC_ZDISF_VKBUR  text
*      <--FC_ZDISF_MATNR  text
*      <--FC_ZDISF_MATKL  text
*      <--FC_ZDISF_PRODH1  text
*      <--FC_ZDISF_VBELN  text
*      <--FC_ZDISF_PKUNWE  text
*----------------------------------------------------------------------*
FORM f_add_data  USING    fu_gross fu_zdisa fu_zdisb fu_zdisc fu_zdise fu_zdisf  fu_zdisf3 fu_zdisvol fu_tdisc
                 CHANGING fc_vkbur fc_matnr fc_matkl fc_prodh1 fc_vbeln fc_pkunwe
                          fc_zdisa_vkbur fc_zdisa_matnr fc_zdisa_matkl fc_zdisa_prodh1
                          fc_zdisa_vbeln fc_zdisa_pkunwe
                          fc_zdisb_vkbur fc_zdisb_matnr fc_zdisb_matkl fc_zdisb_prodh1
                          fc_zdisb_vbeln fc_zdisb_pkunwe
                          fc_zdisc_vkbur fc_zdisc_matnr fc_zdisc_matkl fc_zdisc_prodh1
                          fc_zdisc_vbeln fc_zdisc_pkunwe
                          fc_zdise_vkbur fc_zdise_matnr fc_zdise_matkl fc_zdise_prodh1
                          fc_zdise_vbeln fc_zdise_pkunwe
                          fc_zdisf_vkbur fc_zdisf_matnr fc_zdisf_matkl fc_zdisf_prodh1
                          fc_zdisf_vbeln fc_zdisf_pkunwe
                          fc_zdisf3_vkbur fc_zdisf3_matnr fc_zdisf3_matkl fc_zdisf3_prodh1
                          fc_zdisf3_vbeln fc_zdisf3_pkunwe
                          fc_zdisvol_vkbur fc_zdisvol_matnr fc_zdisvol_matkl fc_zdisvol_prodh1
                          fc_zdisvol_vbeln fc_zdisvol_pkunwe
                          fc_tdisc_vkbur fc_tdisc_matnr fc_tdisc_matkl fc_tdisc_prodh1
                          fc_tdisc_vbeln fc_tdisc_pkunwe.

  ADD fu_gross TO fc_vkbur.
  ADD fu_gross TO fc_matnr.
  ADD fu_gross TO fc_matkl.
  ADD fu_gross TO fc_prodh1.
  ADD fu_gross TO fc_vbeln.
  ADD fu_gross TO fc_pkunwe.

  ADD fu_zdisa TO fc_zdisa_vkbur.
  ADD fu_zdisa TO fc_zdisa_matnr.
  ADD fu_zdisa TO fc_zdisa_matkl.
  ADD fu_zdisa TO fc_zdisa_prodh1.
  ADD fu_zdisa TO fc_zdisa_vbeln.
  ADD fu_zdisa TO fc_zdisa_pkunwe.

  ADD fu_zdisb TO fc_zdisb_vkbur.
  ADD fu_zdisb TO fc_zdisb_matnr.
  ADD fu_zdisb TO fc_zdisb_matkl.
  ADD fu_zdisb TO fc_zdisb_prodh1.
  ADD fu_zdisb TO fc_zdisb_vbeln.
  ADD fu_zdisb TO fc_zdisb_pkunwe.

  ADD fu_zdisc TO fc_zdisc_vkbur.
  ADD fu_zdisc TO fc_zdisc_matnr.
  ADD fu_zdisc TO fc_zdisc_matkl.
  ADD fu_zdisc TO fc_zdisc_prodh1.
  ADD fu_zdisc TO fc_zdisc_vbeln.
  ADD fu_zdisc TO fc_zdisc_pkunwe.

  ADD fu_zdise TO fc_zdise_vkbur.
  ADD fu_zdise TO fc_zdise_matnr.
  ADD fu_zdise TO fc_zdise_matkl.
  ADD fu_zdise TO fc_zdise_prodh1.
  ADD fu_zdise TO fc_zdise_vbeln.
  ADD fu_zdise TO fc_zdise_pkunwe.

  ADD fu_zdisf TO fc_zdisf_vkbur.
  ADD fu_zdisf TO fc_zdisf_matnr.
  ADD fu_zdisf TO fc_zdisf_matkl.
  ADD fu_zdisf TO fc_zdisf_prodh1.
  ADD fu_zdisf TO fc_zdisf_vbeln.
  ADD fu_zdisf TO fc_zdisf_pkunwe.

  ADD fu_zdisf3 TO fc_zdisf3_vkbur.
  ADD fu_zdisf3 TO fc_zdisf3_matnr.
  ADD fu_zdisf3 TO fc_zdisf3_matkl.
  ADD fu_zdisf3 TO fc_zdisf3_prodh1.
  ADD fu_zdisf3 TO fc_zdisf3_vbeln.
  ADD fu_zdisf3 TO fc_zdisf3_pkunwe.

  ADD fu_zdisvol TO fc_zdisvol_vkbur.
  ADD fu_zdisvol TO fc_zdisvol_matnr.
  ADD fu_zdisvol TO fc_zdisvol_matkl.
  ADD fu_zdisvol TO fc_zdisvol_prodh1.
  ADD fu_zdisvol TO fc_zdisvol_vbeln.
  ADD fu_zdisvol TO fc_zdisvol_pkunwe.

  ADD fu_tdisc TO fc_tdisc_vkbur.
  ADD fu_tdisc TO fc_tdisc_matnr.
  ADD fu_tdisc TO fc_tdisc_matkl.
  ADD fu_tdisc TO fc_tdisc_prodh1.
  ADD fu_tdisc TO fc_tdisc_vbeln.
  ADD fu_tdisc TO fc_tdisc_pkunwe.
ENDFORM.                    " f_add_data

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hdr_uline1 .
  IF d_hdr_rpt_lines = 'X'.
*    IF radio4 IS INITIAL.
*      ULINE.
*    ELSE.
    ULINE (247).
*    ENDIF.
  ENDIF.
ENDFORM.                    " F_HDR_ULINE1

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DISC
*&---------------------------------------------------------------------*
FORM f_calculate_disc  USING    fu_sptag
                                fu_vkbur
                                fu_vbeln
                                fu_pkunwe
                                fu_prodh1
                                fu_matnr
                                fu_fkart
                                fu_matkl
                       CHANGING fc_zdisvol
                                fc_tdisc
                                fc_volfin.

  DATA: ld_zdisvol LIKE t_vdata-zdisvol.

  CLEAR: t_a603,t_s626,t_konv.
  READ TABLE t_a603 WITH KEY prodh1 = fu_prodh1 BINARY SEARCH.
  READ TABLE t_s626 WITH KEY prodh1 = fu_prodh1
                             sptag  = fu_sptag
                             vkbur  = fu_vkbur
                             vbeln  = fu_vbeln
                             pkunwe = fu_pkunwe
                             matnr  = fu_matnr BINARY SEARCH.

  IF pa_disc IS NOT INITIAL.
    fc_zdisvol = ( t_s626-umkzwi4 + t_s626-gukzwi4 ).
    IF fu_vkbur(2) NE 'T2'.
      fc_zdisvol = fc_zdisvol * ( t_a603-kbetr / 1000 ).
    ENDIF.
    fc_tdisc = t_vdata-zdisa + t_vdata-zdisb + t_vdata-zdisc +
               t_vdata-zdise + t_vdata-zdisf + t_vdata-zdisf3 +
               fc_zdisvol.
  ENDIF.

  LOOP AT t_vbrk WHERE vbeln = fu_vbeln
                   AND prodh = fu_matkl
                   AND matnr = fu_matnr.
    CASE fu_fkart(2).
      WHEN 'ZB' OR 'YB'.
        CASE fu_fkart(3).
          WHEN 'ZBS' OR 'YBS'.
            READ TABLE t_konv WITH KEY knumv = t_vbrk-knumv
                                       kposn = t_vbrk-posnr
                                       kschl = 'ZTCV'.
          WHEN OTHERS.
            READ TABLE t_konv WITH KEY knumv = t_vbrk-knumv
                                       kposn = t_vbrk-posnr
                                       kschl = 'ZTDV'.
        ENDCASE.
      WHEN 'ZC' OR 'YC'.
        CASE fu_fkart(3).
          WHEN 'ZCS' OR 'YCS'.
            READ TABLE t_konv WITH KEY knumv = t_vbrk-knumv
                                       kposn = t_vbrk-posnr
                                       kschl = 'ZTDV'.
          WHEN OTHERS.
            READ TABLE t_konv WITH KEY knumv = t_vbrk-knumv
                                       kposn = t_vbrk-posnr
                                       kschl = 'ZTCV'.
        ENDCASE.
    ENDCASE.
    ADD t_konv-kwert TO fc_volfin.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_DISC
