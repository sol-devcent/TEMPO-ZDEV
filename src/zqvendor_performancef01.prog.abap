*----------------------------------------------------------------------*
*   INCLUDE ZQVENDOR_PERFORMANCEF01                                    *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  ra_bwart-low     = '101'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'EQ'.
  APPEND ra_bwart.
  ra_bwart-low     = '102'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'EQ'.
  APPEND ra_bwart.
  ra_bwart-low     = '122'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'EQ'.
  APPEND ra_bwart.
  ra_bwart-low     = '123'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'EQ'.
  APPEND ra_bwart.
*  ra_bwart-low     = '344'.
*  ra_bwart-sign    = 'I'.
*  ra_bwart-option  = 'EQ'.
*  APPEND ra_bwart.

  LOOP AT so_werks.
    IF so_werks-low = '3301' OR
      so_werks-low = '3302'.
      va_plant  = 'PLI'.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_mch1  LIKE t_mseg OCCURS 0 WITH HEADER LINE.
  DATA : lv_atinn TYPE atinn.

*  SELECT mblnr mjahr budat cpudt cputm tcode2
*    FROM mkpf
*    INTO CORRESPONDING FIELDS OF TABLE t_mkpf
*    WHERE budat IN so_budat.

*  IF t_mkpf[] IS NOT INITIAL.
  SELECT a~mblnr a~mjahr a~zeile a~bwart a~shkzg
         a~matnr a~werks a~charg a~lifnr a~menge
         a~meins a~ebeln a~ebelp a~smbln
         b~budat b~cpudt b~cputm b~tcode2
    FROM mseg AS a JOIN mkpf AS b ON a~mblnr EQ b~mblnr AND
                                     a~mjahr EQ b~mjahr
    INTO CORRESPONDING FIELDS OF TABLE t_mseg
*      FOR ALL ENTRIES IN t_mkpf
    WHERE a~matnr  IN so_matnr     AND
          a~werks  IN so_werks     AND
          a~bwart  IN ra_bwart     AND
          a~lifnr  IN so_lifnr     AND
          b~budat  IN so_budat.

*    LOOP AT t_msegdata.
*      IF t_msegdata-bwart EQ '101'.
*        READ TABLE t_msegdata WITH KEY smbln = t_msegdata-mblnr.
*        IF sy-subrc NE 0.
*          t_mseg = t_msegdata.
*          APPEND t_mseg.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.

  IF t_mseg[] IS NOT INITIAL.
    t_lifnr[] = t_mseg[].
    SORT t_lifnr BY lifnr.
    DELETE ADJACENT DUPLICATES FROM t_lifnr COMPARING lifnr.
    t_matnr[] = t_mseg[].
    SORT t_matnr BY matnr.
    DELETE ADJACENT DUPLICATES FROM t_matnr COMPARING matnr.

    IF t_lifnr[] IS NOT INITIAL.
      SELECT lifnr name1
        FROM lfa1
        INTO CORRESPONDING FIELDS OF TABLE t_lfa1
        FOR ALL ENTRIES IN t_lifnr
        WHERE lifnr EQ t_lifnr-lifnr.
    ENDIF.

    IF t_matnr[] IS NOT INITIAL.
      SELECT matnr maktx
        FROM makt
        INTO CORRESPONDING FIELDS OF TABLE t_makt
        FOR ALL ENTRIES IN t_matnr
        WHERE matnr EQ t_matnr-matnr AND
              spras EQ sy-langu.
    ENDIF.

    SELECT a~mblnr a~zeile a~mjahr a~lmenge01 a~lmenge04 a~prueflos a~matnr a~charg
           b~qkennzahl b~vcode b~vdatum
      FROM qals AS a JOIN qave AS b ON a~prueflos EQ b~prueflos
      INTO CORRESPONDING FIELDS OF TABLE t_qmdata
      FOR ALL ENTRIES IN t_mseg
      WHERE mblnr EQ t_mseg-mblnr AND
            zeile EQ t_mseg-zeile AND
            mjahr EQ t_mseg-mjahr.

    SELECT matnr mawerk charg qmdat qmnum qmtxt prueflos rkmng
           qmgrp qmcod mblnr
      FROM viqmel
      INTO CORRESPONDING FIELDS OF TABLE t_viqmel
      FOR ALL ENTRIES IN t_mseg
      WHERE matnr    EQ t_mseg-matnr AND
            mawerk   EQ t_mseg-werks AND
            charg    EQ t_mseg-charg AND
            qmgrp    NE space        AND
            qmcod    NE space        AND
            kzloesch NE 'X'.

    SELECT ebeln ebelp etenr eindt wemng menge
      FROM eket
      INTO CORRESPONDING FIELDS OF TABLE t_eket
      FOR ALL ENTRIES IN t_mseg
      WHERE ebeln EQ t_mseg-ebeln AND
            ebelp EQ t_mseg-ebelp.

    SELECT ebeln ebelp menge meins bprme lmein bpumn bpumz umren umrez
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE t_ekpo
      FOR ALL ENTRIES IN t_mseg
      WHERE ebeln EQ t_mseg-ebeln AND
            ebelp EQ t_mseg-ebelp.

    SELECT ebeln ebelp belnr budat cpudt cputm shkzg menge charg
           bwart lfbnr lfpos
      FROM ekbe
      INTO CORRESPONDING FIELDS OF TABLE t_ekbe
      FOR ALL ENTRIES IN t_mseg
      WHERE ebeln EQ t_mseg-ebeln AND
            ebelp EQ t_mseg-ebelp AND
            bewtp EQ 'E'.

*      LOOP AT t_ekbe.
*        CASE t_ekbe-bwart.
*          WHEN '122'.
*            t_ekbe1  = t_ekbe.
*            APPEND t_ekbe1.
*        ENDCASE.
*      ENDLOOP.

    lt_mch1[] = t_mseg[].
    SORT lt_mch1 BY matnr charg.
    DELETE ADJACENT DUPLICATES FROM lt_mch1 COMPARING matnr charg.
    CHECK lt_mch1[] IS NOT INITIAL.
    SELECT matnr charg cuobj_bm
      FROM mch1
      INTO TABLE gt_mch1
      FOR ALL ENTRIES IN lt_mch1
      WHERE matnr = lt_mch1-matnr
        AND charg = lt_mch1-charg.

    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
        EXPORTING
          input  = 'ZMF'
        IMPORTING
          output = lv_atinn.

      LOOP AT gt_mch1.
        gt_mch1-objek = gt_mch1-cuobj_bm.
        MODIFY gt_mch1 TRANSPORTING objek.
      ENDLOOP.

      SELECT objek atwrt
        FROM ausp
        INTO TABLE gt_ausp
        FOR ALL ENTRIES IN gt_mch1
        WHERE objek = gt_mch1-objek
          AND atinn = lv_atinn.
    ENDIF.
  ENDIF.
*  ENDIF.
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
    'LIFNR' 'MSEG' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'LFA1' 'NAME1' '' '' 'Vendor Description' '' '' '' '' '' '' '' '' '',
    'ATWRT' 'AUSP' 'ATWRT' '' '' 'Manufacturer' '' '' '' '' '' '' '' '' '',
    'MATNR' 'MSEG' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' 'Material Description' '' '' '' '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' 'UoM' '' '' '' '' '' '' '' '' '',
    'POUOM' 'EKPO' 'MEINS' 'X' '' 'PO UoM' '' '' '' '' '' '' '' '' '',
    'WERKS' 'MSEG' 'WERKS' '' '' 'Plant' '' '' '' '' '' '' '' '' '',
    'EBELN' 'MSEG' 'EBELN' '' '' 'PO No.' '' '' '' '' '' '' '' '' '',
    'EBELP' 'MSEG' 'EBELP' '' '' 'PO Item No.' '' '' '' '' '' '' '' '' '',
*    'POQTY' 'EKPO' 'MENGE' '' '' 'PO Qty' 'X' '' '' '' '' '' 'POUOM' '' '',
    'POQTYOUT' 'EKPO' 'MENGE' '' '' 'PO Qty' 'X' '' '' '' '' '' 'POUOM' '' '',
    'ETENR' 'EKET' 'ETENR' '' '20' 'PO Sched. Delv. Line' '' '' '' '' '' '' '' '' '',
    'EINDT' 'EKET' 'EINDT' '' '20' 'PO Sched. Delv. Date' '' '' '' '' '' '' '' '' '',
    'PODLVQTY' 'EKET' 'MENGE' '' '20' 'PO Sched. Delv. Qty' '' '' '' '' '' '' 'POUOM' '' '',
    'MBLNR' 'MSEG' 'MBLNR' '' '' 'Material Doc.' '' '' '' '' '' '' '' '' '',
    'ZEILE' 'MSEG' 'ZEILE' '' '' 'GR Item No.' '' '' '' '' '' '' '' '' '',
    'MENGE101' 'MSEG' 'MENGE' '' '' 'GR Qty' 'X' '' '' '' '' '' 'MEINS' '' '',
    'MENGE102' 'MSEG' 'MENGE' '' '' 'Cancel GR Qty' 'X' '' '' '' '' '' 'MEINS' '' '',
    'MENGE122' 'MSEG' 'MENGE' '' '' 'RDTV Qty' 'X' '' '' '' '' '' 'MEINS' '' '',
    'MENGE123' 'MSEG' 'MENGE' '' '' 'Cancel RDTV Qty' 'X' '' '' '' '' '' 'MEINS' '' '',
*    'RDTV' 'MSEG' 'MENGE' '' '' 'RDTV' '' '' '' '' '' '' 'MEINS' '' '',
    'BUDAT' 'MKPF' 'BUDAT' '' '15' 'Posting Date' '' '' '' '' '' '' '' '' '',
    'CHARG' 'MSEG' 'CHARG' '' '14' 'Internal Batch' '' '' '' '' '' '' '' '' '',
    'POVGR' 'EKPO' 'MENGE' '' '26' 'Qty OSO' '' '' '' '' '' '' 'MEINS' '' '',
    'PERCEN' '' '' '' '10' '% Qty OSO' '' '' '' '' '' '' '' '' '',
    'OPENPO' 'EKET' 'MENGE' '' '25' 'Open PO Sched. Delv. Qty' '' '' '' '' '' '' 'POUOM' '' '',
    'TMDIF' '' '' '' '25' 'Time Diff. Delv ( Days )' '' '' '' '' '' '' '' '' ''.
  IF va_plant IS NOT INITIAL.
    PERFORM f_fieldcatg USING ft_report:
      'QKENNZAHL ' 'QAVE' 'QKENNZAHL ' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING ft_report:
    'VCODE' 'QAVE' 'VCODE' '' '8' '' '' '' '' '' '' '' '' '' '',
    'VDATUM' 'QAVE' 'VDATUM' '' '' 'UD Date' '' '' '' '' '' '' '' '' '',
    'LMENGE01' 'QALS' 'LMENGE01' '' '' 'UU Stock' '' '' '' '' '' '' 'MEINS' '' '',
    'LMENGE04' 'QALS' 'LMENGE04' '' '' '' '' '' '' '' '' '' 'MEINS' '' '',
    'QMDAT' 'VIQMEL' 'QMDAT' '' '' 'Notif.Date' '' '' '' '' '' '' '' '' '',
    'QMGRP' 'VIQMEL' 'QMGRP' '' '' 'Coding' '' '' '' '' '' '' '' '' '',
    'QMCOD' 'VIQMEL' 'QMCOD' '' '12' 'Coding Code' '' '' '' '' '' '' '' '' '',
    'QMNUM' 'VIQMEL' 'QMNUM' '' '' 'Notif.No.' '' '' '' '' '' '' '' '' '',
    'QMTXT' 'VIQMEL' 'QMTXT' '' '' 'Notification Description' '' '' '' '' '' '' '' '' '',
    'RKMNG' 'VIQMEL' 'RKMNG' '' '' 'Complaint Qty' '' '' '' '' '' '' 'MEINS' '' ''.
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
                          value(fu_offset).

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
  ld_fieldcat-offset            = fu_offset.
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

  CLEAR ld_sort.
  ld_sort-fieldname = 'EBELN'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'EBELP'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'CHARG'.
*  ld_sort-up        = 'X'.
**  ld_sort-group     = 'UL'.
**  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.

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
  REFRESH: t_msegdata, t_mseg, t_mkpf, t_viqmel, t_eket,
           t_ekpo, t_lifnr, t_matnr, t_lfa1, t_makt.
  CLEAR: t_msegdata, t_mseg, t_mkpf, t_viqmel, t_eket,
         t_ekpo, t_lifnr, t_matnr, t_lfa1, t_makt.
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
  DATA: ld_povgr  LIKE ekpo-menge,
        ld_mblnr  LIKE mseg-mblnr,
        ld_flag   TYPE i,
        ld_menge  LIKE ekbe-menge,
        ld_menge1 LIKE ekbe-menge,
        ld_addmenge LIKE ekbe-menge,
        ld_etenr  LIKE eket-etenr,
        ld_line TYPE i,
        ld_schedline TYPE i,
        ld_notif_line1 TYPE i,
        openpo_flag TYPE i,
        flag_timediff TYPE i,
        ld_eket_qty TYPE i,
        ld_previousgr TYPE i,
        ld_qty_gr TYPE i.

*  SORT t_mseg BY ebeln ebelp matnr mblnr charg.
*  SORT t_ekbe BY ebeln ebelp belnr. "budat cpudt cputm.

  SORT t_mseg BY ebeln ebelp budat mblnr.
  SORT t_ekbe BY ebeln ebelp budat belnr.

  LOOP AT t_mseg.
    t_out-mblnr  = t_mseg-mblnr.
    t_out-zeile  = t_mseg-zeile.
    t_out-matnr  = t_mseg-matnr.
    t_out-werks  = t_mseg-werks.
    t_out-charg  = t_mseg-charg.
    t_out-menge  = t_mseg-menge.
    t_out-lifnr  = t_mseg-lifnr.
    t_out-meins  = t_mseg-meins.
    t_out-ebeln  = t_mseg-ebeln.
    t_out-ebelp  = t_mseg-ebelp.

    t_out-budat  = t_mseg-budat.
    t_out-cpudt  = t_mseg-cpudt.
    t_out-cputm  = t_mseg-cputm.

    READ TABLE gt_mch1 WITH KEY matnr = t_mseg-matnr
                                charg = t_mseg-charg.
    IF sy-subrc = 0.
      READ TABLE gt_ausp WITH KEY objek = gt_mch1-objek.
      IF sy-subrc = 0.
        t_out-atwrt   = gt_ausp-atwrt.
      ENDIF.
    ENDIF.

    READ TABLE t_lfa1 WITH KEY lifnr = t_mseg-lifnr.
    IF sy-subrc EQ 0.
      t_out-name1  = t_lfa1-name1.
    ENDIF.

    READ TABLE t_makt WITH KEY matnr = t_mseg-matnr.
    IF sy-subrc EQ 0.
      t_out-maktx  = t_makt-maktx.
    ENDIF.

*    READ TABLE t_mkpf WITH KEY mblnr = t_mseg-mblnr
*                               mjahr = t_mseg-mjahr.
*    IF sy-subrc EQ 0.
*      t_out-budat  = t_mkpf-budat.
*      t_out-cpudt  = t_mkpf-cpudt.
*      t_out-cputm  = t_mkpf-cputm.
*    ENDIF.

    READ TABLE t_ekpo WITH KEY ebeln = t_mseg-ebeln
                               ebelp = t_mseg-ebelp.
    IF sy-subrc EQ 0.
      t_out-pouom  = t_ekpo-meins.
      t_out-poqty  = t_ekpo-menge.

*     Convert GR qty if PO UoM <> GR UoM (ekpo-meins <> mseg-meins)
      IF t_ekpo-meins NE t_mseg-meins.
        IF t_ekpo-meins NE t_ekpo-bprme AND t_mseg-meins EQ t_ekpo-bprme.
          t_out-menge = t_mseg-menge * t_ekpo-bpumn / t_ekpo-bpumz.
        ELSE.
          IF t_ekpo-meins NE t_ekpo-lmein AND t_mseg-meins EQ t_ekpo-lmein.
            t_out-menge = t_mseg-menge * t_ekpo-umren / t_ekpo-umrez.
          ENDIF.
        ENDIF.
      ENDIF.
*     ---end Convert
    ENDIF.

    CASE t_mseg-bwart.
      WHEN '101'.
        t_out-menge101 = t_out-menge.
      WHEN '102'.
        t_out-menge    = t_out-menge * -1.
        t_out-menge102 = t_out-menge.
      WHEN '122'.
        t_out-menge    = t_out-menge * -1.
        t_out-menge122 = t_out-menge.
      WHEN '123'.
        t_out-menge123 = t_out-menge.
    ENDCASE.

    ON CHANGE OF t_mseg-ebeln OR t_mseg-ebelp.
      CLEAR: ld_etenr, flag_timediff.
    ENDON.

    ADD 1 TO ld_etenr.

*   Get OSO Qty
    LOOP AT t_ekbe WHERE ebeln EQ t_out-ebeln AND
                         ebelp EQ t_out-ebelp.

      IF t_ekbe-shkzg EQ 'H'.
        t_ekbe-menge = t_ekbe-menge * -1.
      ENDIF.

      IF t_ekbe-budat EQ t_out-budat AND
        t_ekbe-belnr GT t_out-mblnr.
        EXIT.
      ENDIF.

      IF t_ekbe-budat LE t_out-budat.
        CASE t_ekbe-bwart.
          WHEN 101.
            IF ld_flag IS INITIAL.
              ld_flag = 1.
              t_out-povgr = t_out-poqty - t_ekbe-menge.
            ELSE.
              t_out-povgr = ld_povgr - t_ekbe-menge.
            ENDIF.
          WHEN 102.
            IF ld_flag IS INITIAL.
              ld_flag = 1.
              t_out-povgr = t_out-poqty - t_ekbe-menge.
            ELSE.
              t_out-povgr = ld_povgr - t_ekbe-menge.
            ENDIF.
          WHEN 122.
            IF ld_flag IS INITIAL.
              ld_flag = 1.
              t_out-povgr = t_out-poqty - t_ekbe-menge.
            ELSE.
              t_out-povgr = ld_povgr - t_ekbe-menge.
            ENDIF.
          WHEN 123.
            IF ld_flag IS INITIAL.
              ld_flag = 1.
              t_out-povgr = t_out-poqty - t_ekbe-menge.
            ELSE.
              t_out-povgr = ld_povgr - t_ekbe-menge.
            ENDIF.
        ENDCASE.
        ld_povgr = t_out-povgr.
      ENDIF.

*      IF t_ekbe-belnr LE t_out-mblnr.
*        IF t_ekbe-budat EQ t_out-budat.
*          IF t_ekbe-cpudt GT t_out-cpudt.
*            IF t_ekbe-cputm LT t_out-cputm.
*              IF t_ekbe-bwart NE '122'.
*                EXIT.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*        IF ld_flag IS INITIAL.
*          ld_flag = 1.
*          t_out-povgr = t_out-poqty - t_ekbe-menge.
*        ELSE.
*          t_out-povgr = ld_povgr - t_ekbe-menge.
*        ENDIF.
*        ld_povgr = t_out-povgr.
*      ENDIF.
    ENDLOOP.

*   Get RDTV Qty
*    LOOP AT t_ekbe1 WHERE lfbnr EQ t_out-mblnr AND
*                          lfpos EQ t_out-ebelp.
*      IF t_ekbe1-shkzg EQ 'H'.
*        t_ekbe1-menge = t_ekbe1-menge * -1.
*      ENDIF.
*      ADD t_ekbe1-menge TO t_out-rdtv.
*    ENDLOOP.
    CLEAR: ld_flag.

    ON CHANGE OF t_mseg-ebeln OR t_mseg-ebelp.
      t_out-poqtyout  = t_out-poqty.
      CLEAR : openpo_flag, ld_menge, ld_addmenge, ld_schedline.
    ENDON.

*   Get % OSO Qty
    IF t_out-poqty IS NOT INITIAL.
      t_out-percen  = t_out-povgr * 100 / t_out-poqty.
    ENDIF.

* UD Process
    READ TABLE t_qmdata WITH KEY mblnr = t_mseg-mblnr
                                 mjahr = t_mseg-mjahr
                                 matnr = t_mseg-matnr
                                 charg = t_mseg-charg.
*   Get UD Code, UD date, UD Qty (UU & Block stock)
    IF sy-subrc EQ 0.
      t_out-lmenge01  = t_qmdata-lmenge01.
      t_out-lmenge04  = t_qmdata-lmenge04.
      t_out-qkennzahl = t_qmdata-qkennzahl.
      t_out-vcode     = t_qmdata-vcode.
      t_out-vdatum    = t_qmdata-vdatum.
    ENDIF.

*   Get PO schedule delivery, time difference
    CLEAR : ld_line.
    LOOP AT t_eket WHERE ebeln EQ t_mseg-ebeln AND
                         ebelp EQ t_mseg-ebelp.
      ADD 1 TO ld_line.
      IF ld_line GT 1.
        EXIT.
      ENDIF.
    ENDLOOP.

    ld_addmenge  = t_out-poqty - t_out-povgr. " + t_out-rdtv.
    ld_menge = ld_addmenge.
    ld_qty_gr = t_out-menge.

    LOOP AT t_eket WHERE ebeln EQ t_out-ebeln AND
                         ebelp EQ t_out-ebelp.
      t_out-eindt     = t_eket-eindt.
      t_out-etenr     = t_eket-etenr.
      t_out-podlvqty  = t_eket-menge.

*     Change Qty OSO (if there is an RDTV).
*      IF t_out-rdtv IS NOT INITIAL.
*        t_out-povgr = t_out-povgr - t_out-rdtv.
*      ENDIF.

      IF ld_menge GE t_out-podlvqty.
        ld_menge      = ld_menge - t_out-podlvqty.
        IF ld_line GT 1.
          t_out-openpo  = 0.
          IF t_eket-etenr GT ld_schedline.
            t_out-tmdif  = t_out-budat - t_eket-eindt.
            ld_schedline = t_eket-etenr.
          ENDIF.
        ELSE.
          t_out-openpo  = t_out-povgr.
          t_out-tmdif   = t_out-budat - t_eket-eindt.
        ENDIF.
      ELSE.
        IF openpo_flag IS INITIAL.
          ld_menge      = t_out-podlvqty - ld_menge.
          IF ld_line GT 1.
            t_out-openpo  = ld_menge.

*           Check "Schedule Qty PO", if it changed then input "time difference"
            IF ld_menge NE t_out-podlvqty.
              t_out-tmdif = t_out-budat - t_eket-eindt.

*             This "IF" is used if "Schedule Qty PO"(that has full-qty) opens again now(because of RDTV/Cancel GR)
              IF ld_schedline GE t_eket-etenr.
                ld_schedline = t_eket-etenr - 1.
              ENDIF.
            ENDIF.

          ELSE.
            t_out-openpo  = t_out-povgr.
            t_out-tmdif   = t_out-budat - t_eket-eindt.
          ENDIF.
          openpo_flag = 1.
          ld_menge = 0.
        ELSE.
          IF ld_line GT 1.
            t_out-openpo  = t_out-podlvqty.
          ELSE.
            t_out-openpo  = t_out-povgr.
            t_out-tmdif   = t_out-budat - t_eket-eindt.
          ENDIF.
        ENDIF.
      ENDIF.

*     This "IF" is used to handle "time difference" if there is a "GR history" that isn't displayed from the first time of GR.
      IF flag_timediff IS INITIAL AND t_out-openpo = 0 AND ld_qty_gr LT ld_addmenge.
        ld_eket_qty = ld_eket_qty + t_eket-menge.
        ld_previousgr = ld_addmenge - ld_qty_gr.
        IF ld_eket_qty LE ld_previousgr.
          t_out-tmdif = 0.
        ENDIF.
      ENDIF.

      APPEND t_out.
      CLEAR: t_out-vcode, t_out-vdatum, t_out-lmenge01, t_out-lmenge04, t_out-menge,
             t_out-poqtyout, t_out-menge101, t_out-menge102, t_out-menge122, t_out-menge123,
             t_out-povgr, t_out-percen, t_out-podlvqty, t_out-etenr, t_out-openpo,
             t_out-rdtv, t_out-tmdif.
    ENDLOOP.
    flag_timediff = 1.
    CLEAR: t_out-poqtyout, openpo_flag, ld_eket_qty, ld_previousgr, ld_qty_gr.

    ld_mblnr = t_out-mblnr.

* Notification Process
    LOOP AT t_viqmel WHERE matnr  EQ t_mseg-matnr AND
                           mawerk EQ t_mseg-werks AND
                           charg  EQ t_mseg-charg.

      CLEAR: t_out-vcode, t_out-vdatum, t_out-lmenge01, t_out-lmenge04, t_out-menge,
             t_out-menge101, t_out-menge102, t_out-menge122, t_out-menge123,
             t_out-povgr, t_out-percen,  t_out-tmdif, t_out-poqtyout, t_out-podlvqty,
             t_out-etenr, t_out-openpo, t_out-rdtv, t_out-eindt, t_out-poqty, t_out-qmdat,
             t_out-qmnum, t_out-qmtxt, t_out-rkmng, t_out-prueflos.

      IF t_viqmel-qmdat GE t_out-budat.
        IF t_viqmel-prueflos IS INITIAL.
          t_out-qmdat    = t_viqmel-qmdat.
          t_out-qmnum    = t_viqmel-qmnum.
          t_out-qmgrp    = t_viqmel-qmgrp.
          t_out-qmcod    = t_viqmel-qmcod.
          t_out-qmtxt    = t_viqmel-qmtxt.
          t_out-rkmng    = t_viqmel-rkmng.
          t_out-prueflos = t_viqmel-prueflos.

          APPEND t_out.
        ELSE.
          LOOP AT t_out WHERE mblnr EQ t_viqmel-mblnr AND
                              matnr EQ t_mseg-matnr   AND
                              charg EQ t_mseg-charg.
            IF ld_notif_line1 IS INITIAL.
              t_out-qmdat    = t_viqmel-qmdat.
              t_out-qmnum    = t_viqmel-qmnum.
              t_out-qmgrp    = t_viqmel-qmgrp.
              t_out-qmcod    = t_viqmel-qmcod.
              t_out-qmtxt    = t_viqmel-qmtxt.
              t_out-rkmng    = t_viqmel-rkmng.
              t_out-prueflos = t_viqmel-prueflos.

              MODIFY t_out TRANSPORTING qmdat qmnum qmgrp qmcod qmtxt rkmng prueflos.
              ld_notif_line1 = 1.
            ENDIF.
          ENDLOOP.
          CLEAR: ld_notif_line1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR: t_out.
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
*&      Form  f_validate_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF so_matnr[] IS INITIAL AND
    so_lifnr[] IS INITIAL.
    va_error  = 1.
    MESSAGE e000(zab) WITH 'Material atau Vendor harus diisi'.
    CLEAR: sscrfields-ucomm.
  ELSE.
    CLEAR: va_error.
  ENDIF.
ENDFORM.                    " f_validate_screen_1000
