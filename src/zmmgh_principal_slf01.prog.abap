*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  pa_grid = 'X'.

  SELECT bwart xstbw
    FROM t156
    INTO TABLE gt_t156.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: ld_ekpo LIKE t_ekpo OCCURS 0 WITH HEADER LINE.

  SELECT k~ebeln k~bukrs k~bstyp bsart lifnr ekorg bedat ekgrp k~aedat
         ebelp matnr menge meins werks lgort bednr
    INTO CORRESPONDING FIELDS OF TABLE t_ekpo
    FROM ekko AS k JOIN ekpo AS p ON k~ebeln = p~ebeln
    WHERE k~bstyp EQ only_po
      AND k~bsart IN s_bsart
      AND bedat   IN s_bedat
      AND lifnr   IN s_lifnr
      AND ekorg   IN s_ekorg
      AND ekgrp   IN s_ekgrp
      AND k~bukrs EQ p_bukrs
      AND matnr   IN s_matnr
      AND werks   IN s_werks
      AND p~loekz EQ space
    ORDER BY k~ebeln ebelp.

  IF sy-subrc = 0.
    SELECT ebeln ebelp etenr eindt menge wemng wamng
      INTO CORRESPONDING FIELDS OF TABLE t_eket
      FROM eket
      FOR ALL ENTRIES IN t_ekpo
      WHERE ebeln EQ t_ekpo-ebeln AND
            ebelp EQ t_ekpo-ebelp.

    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei
           bewtp bwart budat menge xblnr
      INTO CORRESPONDING FIELDS OF TABLE t_ekbe
      FROM ekbe
      FOR ALL ENTRIES IN t_ekpo
      WHERE ebeln EQ t_ekpo-ebeln AND
            ebelp EQ t_ekpo-ebelp AND
            bewtp EQ 'E'.

    CLEAR: ld_ekpo,ld_ekpo[].
    ld_ekpo[] = t_ekpo[].
    SORT ld_ekpo BY matnr.
    DELETE ADJACENT DUPLICATES FROM ld_ekpo COMPARING matnr.
    SELECT a~matnr a~maktx b~prdha b~extwg
      INTO TABLE t_makt
      FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
      FOR ALL ENTRIES IN ld_ekpo
      WHERE a~matnr EQ ld_ekpo-matnr AND
            a~spras EQ sy-langu.

    SELECT * INTO TABLE gt_mean
      FROM mean FOR ALL ENTRIES IN ld_ekpo
      WHERE matnr EQ ld_ekpo-matnr
        AND eantp EQ 'Z2'.

    SELECT a~matnr a~knumh b~kbetr a~datab a~datbi
    INTO CORRESPONDING FIELDS OF TABLE i_nsp
    FROM a510 AS a JOIN konp AS b ON a~knumh = b~knumh
    FOR ALL ENTRIES IN ld_ekpo
    WHERE a~kappl EQ 'V'           AND
          a~kschl EQ 'ZN01'        AND
          a~matnr EQ ld_ekpo-matnr AND
*            a~datbi GE so_bedat-high AND
*            a~datab LE so_bedat-low  AND
          b~loevm_ko NE 'X'.
    SORT i_nsp BY matnr datab datbi.

    CLEAR: ld_ekpo,ld_ekpo[].
    ld_ekpo[] = t_ekpo[].
    SORT ld_ekpo BY lifnr.
    DELETE ADJACENT DUPLICATES FROM ld_ekpo COMPARING lifnr.
    SELECT lifnr name1 werks
      INTO TABLE t_lfa1
      FROM lfa1
      FOR ALL ENTRIES IN ld_ekpo
      WHERE lifnr EQ ld_ekpo-lifnr AND
            spras EQ sy-langu.
  ENDIF.

  SORT t_eket BY ebeln ebelp etenr.
  SORT t_ekbe BY ebeln ebelp.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
*  SORT t_header BY lifnr bedat ebeln ebelp.
*  SORT t_detail BY ebeln ebelp.
*  PERFORM f_alv TABLES t_header t_detail.
  PERFORM f_alv1 TABLES t_out.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report1 ft_report2.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report1 ft_report2.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
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
      i_tabname_header         = 'T_HEADER'
      i_tabname_item           = 'T_DETAIL'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report1
      t_outtab_item            = ft_report2
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report1 ft_report2.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'T_HEADER':
    'LIFNR' 'EKKO' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEDAT' 'EKKO' 'BEDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EBELN' 'EKKO' 'EBELN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EBELP' 'EKPO' 'EBELP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AEDAT' 'EKKO' 'AEDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PRDHA' 'MARA' 'PRDHA' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'EKPO' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EAN11' 'MEAN' 'EAN11' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EINDT' '' '' '' '10' 'Devl.Date' '' '' '' '' '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'PO Qty' '' '' '' '' '' '' 'MEINS' '' '' '',
    'WEMNG' '' '' '' '15' 'GR Qty' '' '' '' '' '' '' 'MEINS' '' '' '',
    'OUTQT' '' '' '' '15' 'Outs Qty' '' '' '' '' '' '' 'MEINS' '' '' '',
    'MEINS' 'EKPO' 'MEINS' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' ''.

  PERFORM f_fieldcatg USING 'T_DETAIL':
    'BUDAT' '' '' '' '10' 'GR Date' '' '' '' '' '' '' '' '' '' '',
    'BELNR' '' '' '' '10' 'GR Document' '' '' '' '' '' '' '' '' '' '',
    'GRQTY' '' '' '' '15' 'GR Quantity' '' '' '' '' '' '' 'MEINS' '' '' '',
    'INFULL' '' '' '' '15' 'InFull %' '' '' '' '' '' '' '' '' '' '',
    'BWART' 'EKBE' 'BWART' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'OTD' '' '' '' '15' 'OTD %' '' '' '' '' '' '' '' '' '' '',
    'FULLFIL' '' '' '' '15' 'FullFil %' '' '' '' '' '' '' '' '' '' '',
    'LEAD' '' '' '' '5' 'Lead' '' '' '' '' '' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'T_HEADER'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'T_DETAIL'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

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
                          VALUE(fu_input)
                          VALUE(fu_no_zero).

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
  ld_fieldcat-no_zero           = fu_no_zero.
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
  fu_layout-expand_fieldname   = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo USING fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'EBELN'.
  fu_keyinfo-item01   = 'EBELN'.

  fu_keyinfo-header02 = 'EBELP'.
  fu_keyinfo-item02   = 'EBELP'.
ENDFORM.                    " f_build_keyinfo

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
  ld_sort-fieldname = 'LIFNR'.
  ld_sort-tabname   = 'I_HEADER'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BEDAT'.
  ld_sort-tabname   = 'I_HEADER'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'EBELN'.
  ld_sort-tabname   = 'I_HEADER'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'EBELP'.
  ld_sort-tabname   = 'I_HEADER'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'EBELN'.
*  ld_sort-tabname   = 'I_DETAIL'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'EBELP'.
*  ld_sort-tabname   = 'I_DETAIL'.
*  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'BUDAT'.
*  ld_sort-tabname   = 'I_DETAIL'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'BELNR'.
*  ld_sort-tabname   = 'I_DETAIL'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: lv_text(100).

*  CONCATENATE t_header-lifnr t_header-name1 INTO lv_text
*                                            SEPARATED BY ' - '.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING lv_text.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*---------------------------------------------------------------------*
*       FORM F_ALV1
*---------------------------------------------------------------------*
FORM f_alv1 TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat1   TABLES  ft_report.
  PERFORM f_build_layout1     USING   d_layout.
  PERFORM f_build_sortfield1  USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  IF pa_grid IS NOT INITIAL.
    PERFORM f_build_event1      TABLES  t_alv_event[].
    lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
    lv_title   = sy-title.
  ELSE.
    PERFORM f_build_event       TABLES  t_alv_event[].
    lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
*     i_grid_title             = lv_title
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
*       FORM F_FIELDCAT1
*---------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'LIFNR' 'EKKO' 'LIFNR' '' '11' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEDAT' 'EKKO' 'BEDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EBELN' 'EKKO' 'EBELN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BEDNR' 'EKPO' 'BEDNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'AEDAT' 'EKKO' 'AEDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'XBLNR' '' '' '' '10' 'DN Number' '' '' '' '' '' '' '' '' '' '',
*    'EBELP' 'EKPO' 'EBELP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PRDHA' 'MARA' 'PRDHA' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EXTWG' 'MARA' 'EXTWG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PRDGR' '' '' '' '10' 'Prod.Grp.' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'EKPO' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EAN11' 'MEAN' 'EAN11' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'EKPO' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LGORT' 'EKPO' 'LGORT' '' '10' '' '' '' '' '' '' '' '' '' '' '',
    'EINDT' '' '' '' '10' 'Devl.Date' '' '' '' '' '' '' '' '' '' '',
    'MNTH_DELV' '' '' '' '10' 'Delv.Month' '' '' '' '' '' '' '' '' '' '',
    'WEEK_DELV' '' '' '' '5' 'Delv.Week' '' '' '' '' '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'PO Qty' '' '' '' '' '' '' 'MEINS' '' '' 'X',
    'POCAR' '' '' '' '15' 'PO Qty(CAR)' '' '' '' '' '' '' 'MECAR' '' '' 'X',
    'MECAR' '' '' '' '15' 'CAR' '' '' '' '' '' '' '' '' '' '',
    'POVAL' '' '' '' '15' 'PO Value' '' '' '' 'IDR' '' '' '' '' '' 'X',
    'WEMNG' '' '' '' '15' 'GR Qty Total' '' '' '' '' '' '' 'MEINS' '' '' 'X',
    'OUTQT' '' '' '' '15' 'Outs Qty' '' '' '' '' '' '' 'MEINS' '' '' 'X',
    'BUDAT' '' '' '' '10' 'GR Date' '' '' '' '' '' '' '' '' '' '',
    'MNTH_GR' '' '' '' '10' 'GR Month' '' '' '' '' '' '' '' '' '' '',
    'WEEK_GR' '' '' '' '7' 'GR Week' '' '' '' '' '' '' '' '' '' '',
    'BELNR' '' '' '' '10' 'GR Document' '' '' '' '' '' '' '' '' '' '',
    'GRQTY' '' '' '' '15' 'GR Quantity' 'X' '' '' '' '' '' 'MEINS' '' '' '',
    'INFULL' '' '' '' '15' 'InFull %' 'X' '' '' '' '' '' '' '' '' '',
    'BWART' 'EKBE' 'BWART' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'OTD' '' '' '' '15' 'OTD' 'X' '' '' '' '' '' '' '' '' '',
    'FULLFIL' '' '' '' '15' 'FullFil %' 'X' '' '' '' '' '' '' '' '' '',
    'LEAD' '' '' '' '10' 'Lead time' 'X' '' '' '' '' '' '' '' '' '',
    'MEINS' 'EKPO' 'MEINS' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' '',
    'GRVAL' '' '' '' '15' 'GR Value' '' '' '' 'IDR' '' '' '' '' '' 'X',
    'OTDVAL' '' '' '' '15' 'OTD Value' '' '' '' 'IDR' '' '' '' '' '' 'X',
    'TDLINE' '' '' '' '20' 'Header Text' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_build_layout1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout1 USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD1
*---------------------------------------------------------------------*
FORM f_build_sortfield1 USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'LIFNR'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'NAME1'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BEDAT'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'EBELN'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'AEDAT'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATNR'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MAKTX'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'WERKS'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'LGORT'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'EINDT'.
  ld_sort-tabname   = 'I_OUT'.
  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM f_build_event1                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event1 TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE1'.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE1                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page1.

  DATA: ld_principal(50).

  ihead_ln-typ = 'H'.
  ihead_ln-key = 'Title'.
  ihead_ln-info = sy-title.
  APPEND ihead_ln TO ihead.

*  ihead_ln-typ = 'S'.
*  ihead_ln-key = 'Principal'.
*  CONCATENATE t_out-lifnr t_out-name1 INTO ihead_ln-info.
*  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Date Process'.
  WRITE sy-datum TO ihead_ln-info.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Time Process'.
  WRITE sy-uzeit TO ihead_ln-info.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Factory Calender ID'.
  WRITE p_factid TO ihead_ln-info.
  APPEND ihead_ln TO ihead.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = ihead.
  REFRESH ihead.

ENDFORM.                    "F_TOP_OF_PAGE1

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
  REFRESH: t_header,t_detail,t_ekpo,t_eket,t_ekbe,t_makt,t_lfa1,gt_mean.
  CLEAR: t_header,t_detail,t_ekpo,t_eket,t_ekbe,t_makt,t_lfa1,gt_mean.
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
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  DATA: ld_delvdate LIKE sy-datum,
        ld_factdays TYPE i,
        lv_werks    LIKE lfa1-werks,
        lv_subrc    TYPE sy-subrc.

  DATA : lt_zmmt0001 LIKE zmmt0001 OCCURS 0 WITH HEADER LINE,
         ls_zmmt0001 LIKE zmmt0001.

  DATA : lt_outint  LIKE t_out OCCURS 0 WITH HEADER LINE.
  DATA : lv_tdline  TYPE tdline.

  LOOP AT t_ekpo.
    CLEAR: t_eket,t_makt,t_lfa1,gt_mean.
    READ TABLE t_eket WITH KEY ebeln = t_ekpo-ebeln
                               ebelp = t_ekpo-ebelp.
    READ TABLE t_makt WITH KEY matnr = t_ekpo-matnr.
    READ TABLE t_lfa1 WITH KEY lifnr = t_ekpo-lifnr.
    READ TABLE gt_mean WITH KEY matnr = t_ekpo-matnr.

    IF t_makt-extwg IN s_extwg.
      AUTHORITY-CHECK OBJECT 'Z_MATGROUP'
               ID 'EXTWG' FIELD t_makt-extwg.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'Z_PRODHIER'
             ID 'PRDHA' FIELD t_makt-prdha.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING t_ekpo TO t_out.

    t_out-name1 = t_lfa1-name1.
    t_out-maktx = t_makt-maktx.
    t_out-ean11 = gt_mean-ean11.
    t_out-prdha = t_makt-prdha.
    t_out-extwg = t_makt-extwg.
    t_out-eindt = t_eket-eindt.
    t_out-wemng = t_eket-wemng.
    t_out-outqt = t_out-menge - t_eket-wemng.

    CLEAR i_nsp.
    LOOP AT i_nsp WHERE matnr =  t_out-matnr
                    AND datab LE t_out-bedat
                    AND datbi GE t_out-bedat.
      t_out-poval = t_out-menge * i_nsp-kbetr.
    ENDLOOP.
    IF sy-subrc <> 0.
      CLEAR: t_out-poval.
    ENDIF.

    LOOP AT t_ekbe WHERE ebeln = t_ekpo-ebeln AND
                         ebelp = t_ekpo-ebelp.
      t_out-budat = t_ekbe-budat.

      IF t_ekbe-budat+6(2) BETWEEN so_dat01-low AND so_dat01-high.
        t_out-w1 = t_ekbe-menge.
      ELSEIF t_ekbe-budat+6(2) BETWEEN so_dat02-low AND so_dat02-high.
        t_out-w2 = t_ekbe-menge.
      ELSEIF t_ekbe-budat+6(2) BETWEEN so_dat03-low AND so_dat03-high.
        t_out-w3 = t_ekbe-menge.
      ELSEIF t_ekbe-budat+6(2) BETWEEN so_dat04-low AND so_dat04-high.
        t_out-w4 = t_ekbe-menge.
      ENDIF.

      t_out-belnr = t_ekbe-belnr.
      t_out-grqty = t_ekbe-menge.
      t_out-bwart = t_ekbe-bwart.
      t_out-xblnr = t_ekbe-xblnr.

      READ TABLE gt_t156 WITH KEY bwart = t_ekbe-bwart.
      IF sy-subrc EQ 0.
        IF gt_t156-xstbw EQ 'X'.
          t_out-grqty = t_out-grqty * -1.
        ENDIF.
      ENDIF.

      CLEAR ld_delvdate.
      ld_delvdate = t_eket-eindt + 1.

*      IF t_out-budat LT ld_delvdate.
*        t_out-otd = t_out-grqty / t_ekpo-menge * 100.
*      ENDIF.


      t_out-fullfil = t_out-grqty / t_ekpo-menge * 100.
      t_out-infull  = t_out-grqty / t_ekpo-menge * 100.

*      PERFORM f_factory_calendar USING t_out-bedat t_out-budat p_factid
*                                 CHANGING ld_factdays.
      PERFORM f_factory_calendar USING t_out-eindt t_out-budat p_factid
                                 CHANGING ld_factdays.

      t_out-lead = ld_factdays.

      IF t_out-lead < 2.
        t_out-otd = t_out-grqty.
      ELSE.
        t_out-otd = 0.
      ENDIF.

      t_out-grval = t_out-grqty * i_nsp-kbetr.
      t_out-otdval = t_out-otd * i_nsp-kbetr.

      COLLECT t_out.
      CLEAR: t_out-budat,t_out-belnr,t_out-grqty,t_out-bwart,
             t_out-otd,t_out-fullfil,t_out-menge,t_out-wemng,t_out-infull,
             t_out-outqt,t_out-lead,t_out-w1,t_out-w2,t_out-w3,t_out-w4,t_out-poval.
    ENDLOOP.

    IF sy-subrc NE 0.
      COLLECT t_out.
    ENDIF.
    CLEAR t_out.
  ENDLOOP.

  SELECT matnr, meinh, umrez, umren INTO TABLE @DATA(lt_marm)
    FROM marm FOR ALL ENTRIES IN @t_out
    WHERE matnr = @t_out-matnr
      AND meinh = 'KAR'.

  SORT t_out BY lifnr werks lgort ebeln matnr budat belnr.
  LOOP AT t_out.

    CLEAR lv_tdline.
    PERFORM f_get_header_text USING t_out-ebeln
                              CHANGING lv_tdline.
    IF lv_tdline IS NOT INITIAL.
      t_out-tdline = lv_tdline.
      MODIFY t_out TRANSPORTING tdline.
    ENDIF.

    CLEAR: ld_factdays,t_out-lead.
    PERFORM f_factory_calendar USING t_out-eindt t_out-budat p_factid
                               CHANGING ld_factdays.
    t_out-lead = ld_factdays.

    IF t_out-eindt IS NOT INITIAL.
      PERFORM f_hitung_week USING t_out-eindt
                            CHANGING t_out-week_delv t_out-mnth_delv.
    ENDIF.

    IF t_out-budat IS NOT INITIAL.
      PERFORM f_hitung_week USING t_out-budat
                            CHANGING t_out-week_gr t_out-mnth_gr.
    ENDIF.

* Material tertentu dan summary week dan quantity
    IF t_out-prdha(5) = 'TSPCH' OR
      t_out-prdha(5) = 'SFFCH' OR
      t_out-prdha(3) = 'BCL'.
      IF t_out-lifnr IS NOT INITIAL.
        gt_weeksum-matnr  = t_out-matnr.
        IF t_out-w1 IS NOT INITIAL.
          gt_weeksum-w1 = 1.
        ENDIF.
        IF t_out-w2 IS NOT INITIAL.
          gt_weeksum-w2 = 1.
        ENDIF.
        IF t_out-w3 IS NOT INITIAL.
          gt_weeksum-w3 = 1.
        ENDIF.
        IF t_out-w3 IS NOT INITIAL.
          gt_weeksum-w3 = 1.
        ENDIF.
        gt_weeksum-menge = t_out-menge.
        COLLECT gt_weeksum.
        lv_subrc = 0.
      ENDIF.
      CLEAR gt_weeksum.
    ELSE.
      lv_subrc = 4.
    ENDIF.

    t_out-prdgr = t_out-prdha+3(3).

    IF line_exists( lt_marm[ matnr = t_out-matnr ] ).
      t_out-mecar    = VALUE #( lt_marm[ matnr = t_out-matnr ]-meinh OPTIONAL ).
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = t_out-matnr
          i_in_me              = t_out-meins
          i_out_me             = t_out-mecar
          i_menge              = t_out-menge
        IMPORTING
          e_menge              = t_out-pocar
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.
    ENDIF.

    MODIFY t_out TRANSPORTING lead week_gr mnth_gr week_delv mnth_delv prdgr pocar mecar.

    IF lv_subrc = 0.
      lt_outint = t_out.
      APPEND lt_outint.
      DELETE t_out.
    ENDIF.

    CLEAR : t_out, lt_outint.
  ENDLOOP.

  CLEAR gv_remgrw4qty.

* Hitung otd & fullfill
  LOOP AT lt_outint.
    CLEAR lv_werks.
    READ TABLE t_lfa1 WITH KEY lifnr  = lt_outint-lifnr.
    IF sy-subrc = 0.
      lv_werks  = t_lfa1-werks.

      PERFORM f_factory_commitment_weekly USING    lv_werks '1'
                                          CHANGING lt_outint.

      MODIFY lt_outint TRANSPORTING otd fullfil.
    ENDIF.

    CLEAR lt_outint.
  ENDLOOP.

* Modify OTD & Fullfill penambahan dari tabungan yang ada di table ZMMT0001
  PERFORM f_modify_otdfullfil TABLES lt_outint.

  LOOP AT lt_outint.
    t_out = lt_outint.
    APPEND t_out.
    CLEAR t_out.
  ENDLOOP.

  LOOP AT gt_zmmt0001 INTO ls_zmmt0001.
    UPDATE zmmt0001 SET remgrw4qty = ls_zmmt0001-remgrw4qty
                     WHERE vrsio = ls_zmmt0001-vrsio
                       AND spmon = ls_zmmt0001-spmon
                       AND werks = ls_zmmt0001-werks
                       AND matnr = ls_zmmt0001-matnr.
    CLEAR ls_zmmt0001.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
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
*&      Form  F_FACTORY_CALENDAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_DATAB  text
*      -->FU_DATBI  text
*      -->FU_ID     text
*      <--FC_FACTDAYS  text
*----------------------------------------------------------------------*
FORM f_factory_calendar  USING    fu_datab fu_datbi fu_id
                         CHANGING fc_factdays.
  DATA: eth_dats  LIKE rke_dat OCCURS 0 WITH HEADER LINE.

  IF fu_datab IS INITIAL OR
     fu_datbi IS INITIAL.
    fc_factdays = 0.
  ELSE.
    IF fu_datab LE fu_datbi.
      CALL FUNCTION 'RKE_SELECT_FACTDAYS_FOR_PERIOD'
        EXPORTING
          i_datab               = fu_datab
          i_datbi               = fu_datbi
          i_factid              = fu_id
        TABLES
          eth_dats              = eth_dats
        EXCEPTIONS
          date_conversion_error = 1
          OTHERS                = 2.

      DESCRIBE TABLE eth_dats LINES fc_factdays.
      SUBTRACT 1 FROM fc_factdays.
    ELSE.
      CALL FUNCTION 'RKE_SELECT_FACTDAYS_FOR_PERIOD'
        EXPORTING
          i_datab               = fu_datbi
          i_datbi               = fu_datab
          i_factid              = fu_id
        TABLES
          eth_dats              = eth_dats
        EXCEPTIONS
          date_conversion_error = 1
          OTHERS                = 2.
      DESCRIBE TABLE eth_dats LINES fc_factdays.
      SUBTRACT 1 FROM fc_factdays.
      fc_factdays = fc_factdays * -1.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FACTORY_CALENDAR

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_WEEK
*&---------------------------------------------------------------------*
FORM f_hitung_week  USING    fu_budat
                    CHANGING fc_week fc_month.

  DATA : lv_week1    LIKE scal-week,
         lv_week2    LIKE scal-week,
         lv_date     TYPE sy-datum,
         lv_month(2).

  DATA : lv_budat TYPE sy-datum.

  IF fu_budat+6(2) BETWEEN so_dat01-low AND so_dat01-high.
    fc_week = 1.
  ELSEIF fu_budat+6(2) BETWEEN so_dat02-low AND so_dat02-high.
    fc_week = 2.
  ELSEIF fu_budat+6(2) BETWEEN so_dat03-low AND so_dat03-high.
    fc_week = 3.
  ELSEIF fu_budat+6(2) BETWEEN so_dat04-low AND so_dat04-high.
    fc_week = 4.
  ENDIF.

*  IF fu_budat = space.
*    lv_budat  = '00000000'.
*  ELSE.
*    lv_budat  = fu_budat.
*  ENDIF.
*
*  CHECK lv_budat IS NOT INITIAL.
*
*  CALL FUNCTION 'DATE_GET_WEEK'
*    EXPORTING
*      date = fu_budat
*    IMPORTING
*      week = lv_week1.
*
*  CONCATENATE fu_budat(6) '01' INTO lv_date.
*
*  CALL FUNCTION 'DATE_GET_WEEK'
*    EXPORTING
*      date = lv_date
*    IMPORTING
*      week = lv_week2.
*
*  fc_week = lv_week1+4(2) - lv_week2+4(2).
*
*  IF fc_week = 0.
*    fc_week = 1.
*  ELSEIF fc_week < 0.
*    fc_week = fc_week + lv_week2+4(2).
*  ENDIF.

  lv_month  = fu_budat+4(2).

  CALL FUNCTION 'ZMONTH_NAME'
    EXPORTING
      month = lv_month
    IMPORTING
      name  = fc_month.
ENDFORM.                    " F_HITUNG_WEEK

*&---------------------------------------------------------------------*
*&      Form  F_FACTORY_COMMITMENT_WEEKLY
*&---------------------------------------------------------------------*
FORM f_factory_commitment_weekly USING    fu_werks fu_proc
                                 CHANGING fs_out STRUCTURE t_out.

  DATA : lr_spmon TYPE RANGE OF spmon,
         ls_spmon LIKE LINE OF lr_spmon,
         lv_datum TYPE sy-datum.

  DATA : lt_ekpo      LIKE t_ekpo OCCURS 0 WITH HEADER LINE,
         lt_lfa1      LIKE t_lfa1 OCCURS 0 WITH HEADER LINE,
         ls_zmmt0001  TYPE zmmt0001,
         ls_zmmt0001a TYPE zmmt0001,
         ls_ekpo      LIKE t_ekpo.

  DATA : BEGIN OF lt_marc OCCURS 0,
           matnr LIKE marc-matnr,
           werks LIKE marc-werks,
         END OF lt_marc.

  DATA : lv_w1       LIKE ekbe-menge,
         lv_w2       LIKE ekbe-menge,
         lv_w3       LIKE ekbe-menge,
         lv_w4       LIKE ekbe-menge,
         lv_mengesum LIKE ekbe-menge,
         lv_menge    LIKE ekbe-menge,
         lv_remgrqty LIKE ekbe-menge,
         lv_fcomqty  LIKE ekbe-menge.

  IF fu_proc IS INITIAL.
* Get data factory commitment
    lt_ekpo[] = t_ekpo[].
    SORT lt_ekpo BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING matnr.

    lt_lfa1[] = t_lfa1[].
    SORT lt_lfa1 BY werks.
    DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING werks.

    LOOP AT lt_ekpo.
      lt_marc-matnr = lt_ekpo-matnr.
      LOOP AT lt_lfa1.
        lt_marc-werks = lt_lfa1-werks.
        APPEND lt_marc.
      ENDLOOP.
    ENDLOOP.

    CONCATENATE s_bedat-low(6) '01' INTO lv_datum.
    lv_datum  = lv_datum - 1.

    gv_spmon  = s_bedat-low(6).
    gv_spmon1 = lv_datum(6).

    ls_spmon-low    = lv_datum(6).
    ls_spmon-high   = s_bedat-high(6).
    ls_spmon-sign   = 'I'.
    ls_spmon-option = 'BT'.
    APPEND ls_spmon TO lr_spmon.

    IF lt_marc[] IS NOT INITIAL.
      SELECT *
        FROM zmmt0001
        INTO CORRESPONDING FIELDS OF TABLE gt_zmmt0001
        FOR ALL ENTRIES IN lt_marc
        WHERE vrsio = 'A00'
          AND spmon IN lr_spmon
          AND werks = lt_marc-werks
          AND matnr = lt_marc-matnr.
    ENDIF.
  ELSE.
* Process data factory commitment
    CLEAR : ls_zmmt0001a, ls_zmmt0001.
    READ TABLE gt_zmmt0001 INTO ls_zmmt0001a
                           WITH KEY werks = fu_werks
                                    matnr = fs_out-matnr
                                    spmon = gv_spmon1.

    READ TABLE gt_zmmt0001 INTO ls_zmmt0001
                           WITH KEY werks = fu_werks
                                    matnr = fs_out-matnr
                                    spmon = gv_spmon.

    IF sy-subrc = 0.
      IF fs_out-w1 IS NOT INITIAL.
        IF fs_out-eindt(6) = fs_out-budat(6).
          READ TABLE gt_weeksum WITH KEY matnr = fs_out-matnr.
          IF sy-subrc = 0.
            lv_mengesum   = gt_weeksum-menge.
            lv_menge      = fs_out-w1 + ls_zmmt0001a-remgrw4qty - gv_remgrw4qty.

            IF lv_menge > ls_zmmt0001-fcomw1qty.
              lv_w1 = ls_zmmt0001-fcomw1qty.
              ls_zmmt0001-remgrw1qty  = ( ls_zmmt0001-remgrw1qty + lv_menge ) -
                                          ls_zmmt0001-fcomw1qty.
              CLEAR : ls_zmmt0001-fcomw1qty.
            ELSE.
              ls_zmmt0001-fcomw1qty = ls_zmmt0001-fcomw1qty - lv_menge.

              IF ls_zmmt0001a-remgrw4qty IS NOT INITIAL.
                lv_w1 = lv_menge.
              ELSE.
                lv_w1 = fs_out-w1.
              ENDIF.
            ENDIF.
            gv_remgrw4qty = ls_zmmt0001a-remgrw4qty.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_menge IS INITIAL.
        IF fs_out-w2 IS NOT INITIAL.
          IF fs_out-eindt(6) = fs_out-budat(6).
            READ TABLE gt_weeksum WITH KEY matnr = fs_out-matnr.
            IF sy-subrc = 0.
              lv_mengesum   = gt_weeksum-menge.
              lv_menge      = fs_out-w2 + ls_zmmt0001-remgrw1qty.

              IF lv_menge > ls_zmmt0001-fcomw2qty.
                lv_w2 = ls_zmmt0001-fcomw2qty.
                ls_zmmt0001-remgrw2qty  = ( ls_zmmt0001-remgrw2qty + lv_menge ) -
                                            ls_zmmt0001-fcomw2qty.
                CLEAR : ls_zmmt0001-fcomw2qty.
              ELSE.
                ls_zmmt0001-fcomw2qty = ls_zmmt0001-fcomw2qty - lv_menge.

                IF ls_zmmt0001-remgrw1qty IS NOT INITIAL.
                  lv_w2 = lv_menge.
                ELSE.
                  lv_w2 = fs_out-w2.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_menge IS INITIAL.
        IF fs_out-w3 IS NOT INITIAL.
          IF fs_out-eindt(6) = fs_out-budat(6).
            READ TABLE gt_weeksum WITH KEY matnr = fs_out-matnr.
            IF sy-subrc = 0.
              lv_mengesum   = gt_weeksum-menge.
              lv_menge      = fs_out-w3 + ls_zmmt0001-remgrw2qty.

              IF lv_menge > ls_zmmt0001-fcomw3qty.
                lv_w3 = ls_zmmt0001-fcomw3qty.
                ls_zmmt0001-remgrw3qty  = ( ls_zmmt0001-remgrw3qty + lv_menge ) -
                                            ls_zmmt0001-fcomw3qty.
                CLEAR : ls_zmmt0001-fcomw3qty.
              ELSE.
                ls_zmmt0001-fcomw3qty = ls_zmmt0001-fcomw3qty - lv_menge.

                IF ls_zmmt0001-remgrw2qty IS NOT INITIAL.
                  lv_w3 = lv_menge.
                ELSE.
                  lv_w3 = fs_out-w3.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_menge IS INITIAL.
        IF fs_out-w4 IS NOT INITIAL.
          IF fs_out-eindt(6) = fs_out-budat(6).
            READ TABLE gt_weeksum WITH KEY matnr = fs_out-matnr.
            IF sy-subrc = 0.
              lv_mengesum   = gt_weeksum-menge.
              lv_menge      = fs_out-w4 + ls_zmmt0001-remgrw3qty.

              IF lv_menge > ls_zmmt0001-fcomw4qty.
                lv_w4 = ls_zmmt0001-fcomw4qty.
                ls_zmmt0001-remgrw4qty  = ( ls_zmmt0001-remgrw4qty + lv_menge ) -
                                            ls_zmmt0001-fcomw4qty.
                CLEAR : ls_zmmt0001-fcomw4qty.
              ELSE.
                ls_zmmt0001-fcomw4qty = ls_zmmt0001-fcomw4qty - lv_menge.

                IF ls_zmmt0001-remgrw3qty IS NOT INITIAL.
                  lv_w4 = lv_menge.
                ELSE.
                  lv_w4 = fs_out-w4.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      MODIFY TABLE gt_zmmt0001 FROM ls_zmmt0001
                               TRANSPORTING fcomw1qty fcomw2qty
                                            fcomw3qty fcomw4qty
                                            remgrw1qty remgrw2qty
                                            remgrw3qty remgrw4qty.

      fs_out-otd = lv_w1 + lv_w2 + lv_w3 + lv_w4.

      CLEAR : ls_ekpo.
      READ TABLE t_ekpo INTO ls_ekpo WITH KEY ebeln = fs_out-ebeln
                                              matnr = fs_out-matnr.
      IF sy-subrc = 0.
        fs_out-fullfil = fs_out-otd / lv_mengesum * 100.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FACTORY_COMMITMENT_WEEKLY

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: lv_mess(100),
        lv_date   TYPE bkpf-monat.

  IF s_bedat-high IS NOT INITIAL.
    IF s_bedat-high(6) <> s_bedat-low(6).
      LOOP AT SCREEN.
        IF screen-group1 = 'BED'.
          screen-input  = 1.
        ELSE.
          screen-input  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

      MESSAGE e000(zab) WITH 'Purch.Doc.Date is not in the same period'.
    ENDIF.
  ENDIF.

  IF so_dat01-low IS INITIAL OR
    so_dat01-high IS INITIAL.
    PERFORM f_error_selection_screen USING 'SD1' '0'.
  ENDIF.
  IF so_dat02-low IS INITIAL OR
    so_dat02-high IS INITIAL.
    PERFORM f_error_selection_screen USING 'SD2' '0'.
  ENDIF.
  IF so_dat03-low IS INITIAL OR
    so_dat03-high IS INITIAL.
    PERFORM f_error_selection_screen USING 'SD3' '0'.
  ENDIF.
  IF so_dat04-low IS INITIAL OR
    so_dat04-high IS INITIAL.
    PERFORM f_error_selection_screen USING 'SD4' '0'.
  ENDIF.

  IF so_dat01-high <= so_dat01-low.
    PERFORM f_error_selection_screen USING 'SD1' '1'.
  ENDIF.
  lv_date = so_dat01-high + 1.
  IF so_dat02-low <> lv_date.
    PERFORM f_error_selection_screen USING : 'SD2' '1'.
  ENDIF.
  IF so_dat02-high <= so_dat02-low.
    PERFORM f_error_selection_screen USING 'SD2' '1'.
  ENDIF.
  lv_date = so_dat02-high + 1.
  IF so_dat03-low <> lv_date.
    PERFORM f_error_selection_screen USING : 'SD3' '1'.
  ENDIF.
  IF so_dat03-high <= so_dat03-low.
    PERFORM f_error_selection_screen USING 'SD3' '1'.
  ENDIF.
  lv_date = so_dat03-high + 1.
  IF so_dat04-low <> lv_date.
    PERFORM f_error_selection_screen USING : 'SD4' '1'.
  ENDIF.
  IF so_dat04-high <= so_dat04-low.
    PERFORM f_error_selection_screen USING 'SD4' '1'.
  ENDIF.

  PERFORM f_authorization CHANGING lv_mess.
  IF lv_mess = '2'.
    PERFORM f_error_selection_screen USING 'SEX' lv_mess.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_OTDFULLFIL
*&---------------------------------------------------------------------*
FORM f_modify_otdfullfil TABLES ft_out STRUCTURE t_out.
  DATA : lt_out      LIKE t_out OCCURS 0 WITH HEADER LINE,
         ls_zmmt0001 TYPE zmmt0001,
         lv_fcomwqty LIKE zmmt0001-fcomw1qty,
         ls_ekpo     LIKE t_ekpo.

  DATA : lv_menge LIKE ekpo-menge,
         lv_cntw1 TYPE int4.

  lt_out[]  = ft_out[].
  SORT ft_out BY matnr.
  SORT lt_out BY matnr week_gr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr.

  CLEAR : lv_menge.
  LOOP AT lt_out.
    CHECK lt_out-week_gr < 4.

    READ TABLE gt_zmmt0001 INTO ls_zmmt0001 WITH KEY spmon = lt_out-budat(6)
                                                     matnr = lt_out-matnr.
    IF sy-subrc = 0.
      CLEAR : lv_fcomwqty.
      CASE lt_out-week_gr.
        WHEN 3.
          IF ls_zmmt0001-fcomw4qty < ls_zmmt0001-remgrw3qty.
            lt_out-otd = lt_out-otd + ls_zmmt0001-fcomw4qty.
          ELSE.
            lt_out-otd = lt_out-otd + ls_zmmt0001-remgrw3qty.
          ENDIF.
        WHEN 2.
          lv_fcomwqty = ls_zmmt0001-fcomw3qty + ls_zmmt0001-fcomw4qty.
          IF lv_fcomwqty < ls_zmmt0001-remgrw2qty.
            lt_out-otd = lt_out-otd + lv_fcomwqty.
          ELSE.
            lt_out-otd = lt_out-otd + ls_zmmt0001-remgrw2qty.
          ENDIF.
        WHEN 1.
          lv_fcomwqty = ls_zmmt0001-fcomw2qty + ls_zmmt0001-fcomw3qty +
                        ls_zmmt0001-fcomw4qty.
          IF lv_fcomwqty < ls_zmmt0001-remgrw1qty.
            lt_out-otd = lt_out-otd + lv_fcomwqty.
          ELSE.
            lt_out-otd = lt_out-otd + ls_zmmt0001-remgrw1qty.
          ENDIF.
      ENDCASE.

      READ TABLE gt_weeksum WITH KEY matnr = lt_out-matnr.
      IF sy-subrc = 0.
        lt_out-fullfil = lt_out-otd / gt_weeksum-menge * 100.
      ENDIF.

      MODIFY lt_out TRANSPORTING otd fullfil.
      MODIFY ft_out FROM lt_out TRANSPORTING otd fullfil
                                WHERE lifnr = lt_out-lifnr
                                  AND werks = lt_out-werks
                                  AND lgort = lt_out-lgort
                                  AND ebeln = lt_out-ebeln
                                  AND matnr = lt_out-matnr
                                  AND budat = lt_out-budat
                                  AND belnr = lt_out-belnr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_OTDFULLFIL

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Lower limit is greater than upper limit'.
    WHEN '2'.
      lv_mess = 'You are not authorization'.
  ENDCASE.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER_TEXT
*&---------------------------------------------------------------------*
FORM f_get_header_text  USING    fu_ebeln
                        CHANGING fc_tdline.
  DATA: lt_lines TYPE STANDARD TABLE OF tline,
        ls_lines LIKE LINE OF lt_lines,
        lv_name  LIKE  thead-tdname.

  CLEAR: lt_lines[],ls_lines,lv_name.
  lv_name = fu_ebeln.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'F01'
      language                = 'E'
      name                    = lv_name
      object                  = 'EKKO'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc = 0.
    READ TABLE lt_lines INTO ls_lines INDEX 1.
    fc_tdline = ls_lines-tdline.
  ENDIF.
ENDFORM.                    " F_GET_HEADER_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_authorization  CHANGING fc_mess.
  TYPES : BEGIN OF ty_mara,
            extwg TYPE mara-extwg,
          END OF ty_mara.
  DATA : lt_mara TYPE STANDARD TABLE OF ty_mara,
         ls_mara LIKE LINE OF lt_mara.

  IF s_extwg[] IS NOT INITIAL.
    SELECT extwg
      FROM mara
      INTO TABLE lt_mara
      WHERE extwg IN s_extwg.

    LOOP AT lt_mara INTO ls_mara.
      AUTHORITY-CHECK OBJECT 'Z_MATGROUP'
               ID 'EXTWG' FIELD ls_mara-extwg.
      IF sy-subrc <> 0.
        fc_mess = '2'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_AUTHORIZATION
