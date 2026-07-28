*----------------------------------------------------------------------*
*   INCLUDE ZM_LEAD_TIMEF01                                            *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: ld_count   TYPE i.

  SELECT a~ebeln a~bsart a~ekgrp a~bukrs a~lifnr a~bedat a~waers a~wkurs a~knumv
         b~ebelp b~werks b~matnr b~txz01 b~meins b~netwr b~lewed b~menge b~elikz
    FROM ekko AS a JOIN ekpo AS b ON a~ebeln EQ b~ebeln
    INTO CORRESPONDING FIELDS OF TABLE t_vdata
    WHERE a~ebeln IN so_ebeln AND
          b~ebelp IN so_ebelp AND
          a~bukrs IN so_bukrs AND
          b~werks IN so_werks AND
          a~ekorg EQ pa_ekorg AND
          a~bedat IN so_bedat AND
          a~ekgrp IN so_ekgrp AND
          a~bsart IN so_bsart AND
          a~lifnr IN so_lifnr AND
          a~bstyp EQ 'F'      AND
          b~matnr IN so_matnr AND
          b~mtart IN so_mtart AND
          b~matkl IN so_matkl AND
          b~loekz IN so_loekz.

  IF t_vdata[] IS NOT INITIAL.
    SELECT ebeln ebelp belnr buzei bwart budat shkzg menge matnr bldat lfbnr
      FROM ekbe
      INTO CORRESPONDING FIELDS OF TABLE t_ekbe
      FOR ALL ENTRIES IN t_vdata
      WHERE ebeln EQ t_vdata-ebeln AND
            ebelp EQ t_vdata-ebelp AND
*            budat IN so_budat      AND
            zekkn EQ 0             AND
            vgabe EQ 1             AND
            bwart IN ('101', '102', '122', '123').

    LOOP AT t_ekbe.
      t_ekbedata-ebeln  = t_ekbe-ebeln.
      t_ekbedata-ebelp  = t_ekbe-ebelp.
      t_ekbedata-count  = 1.
      IF t_ekbe-shkzg EQ 'H'.
        t_ekbedata-cancel  = 1.
      ENDIF.
      COLLECT t_ekbedata.
      CLEAR: t_ekbedata.
    ENDLOOP.

    SELECT ebeln ebelp etenr banfn bnfpo eindt menge wemng
      FROM eket
      INTO CORRESPONDING FIELDS OF TABLE t_eket
      FOR ALL ENTRIES IN t_vdata
      WHERE ebeln EQ t_vdata-ebeln AND
            ebelp EQ t_vdata-ebelp AND
            eindt IN so_budat.

    IF t_eket[] IS NOT INITIAL.
      SELECT banfn bnfpo badat menge lfdat frgkz
        FROM eban
        INTO CORRESPONDING FIELDS OF TABLE t_eban
        FOR ALL ENTRIES IN t_eket
        WHERE banfn EQ t_eket-banfn AND
              bnfpo EQ t_eket-bnfpo.
    ENDIF.

    LOOP AT t_vdata.
      t_knumv-knumv  = t_vdata-knumv.
      t_knumv-kposn  = t_vdata-ebelp.
      COLLECT t_knumv.
      t_lifnr-lifnr  = t_vdata-lifnr.
      COLLECT t_lifnr.
      t_matnr-matnr  = t_vdata-matnr.
      COLLECT t_matnr.
    ENDLOOP.

    IF t_lifnr[] IS NOT INITIAL.
      SELECT lifnr name1
        FROM lfa1
        INTO CORRESPONDING FIELDS OF TABLE t_lfa1
        FOR ALL ENTRIES IN t_lifnr
        WHERE lifnr EQ t_lifnr-lifnr.
    ENDIF.

    IF t_knumv[] IS NOT INITIAL.
      SELECT knumv kposn kbetr kkurs kpein kschl waers
        FROM konv
        INTO CORRESPONDING FIELDS OF TABLE t_konv
        FOR ALL ENTRIES IN t_knumv
        WHERE knumv EQ t_knumv-knumv AND
              kposn EQ t_knumv-kposn AND
              kappl EQ 'M'           AND
              kschl IN ('ZPB0', 'ZPB1').
    ENDIF.

    IF t_matnr[] IS NOT INITIAL.
      SELECT matnr bismt
        FROM mara
        INTO CORRESPONDING FIELDS OF TABLE t_mara
        FOR ALL ENTRIES IN t_matnr
        WHERE matnr EQ t_matnr-matnr.

      SELECT matnr plifz
        FROM marc
        INTO CORRESPONDING FIELDS OF TABLE t_marc
        FOR ALL ENTRIES IN t_matnr
        WHERE matnr EQ t_matnr-matnr AND
              werks IN so_werks.
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
*CURR_SAT
  PERFORM f_fieldcatg USING ft_report:
    'EKGRP' 'EKKO' 'EKGRP' '' '' '' '' '' '' '' '' '' '' '',
    'BSART' 'EKKO' 'BSART' '' '' '' '' '' '' '' '' '' '' '',
    'BUKRS' 'EKKO' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'EKPO' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
    'BANFN' 'EBAN' 'BANFN' '' '' '' '' '' '' '' '' '' '' '',
    'BADAT' 'EBAN' 'BADAT' '' '' '' '' '' '' '' '' '' '' '',
    'MENGE_EBAN' 'EBAN' 'MENGE' '' '' '' '' '' '' '' '' '' 'MEINS' '',
    'RELDT' '' '' '' '14' 'Final Rel.Date' '' '' '' '' '' '' '' '',
    'LFDAT' 'EBAN' 'LFDAT' '' '' '' '' '' '' '' '' '' '' '',
    'LIFNR' 'EKKO' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '',
    'EBELN' 'EKKO' 'EBELN' '' '' '' '' '' '' '' '' '' '' '',
    'BEDAT' 'EKKO' 'BEDAT' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'EKPO' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'BISMT' 'MARA' 'BISMT' '' '' '' '' '' '' '' '' '' '' '',
    'TXZ01' 'EKPO' 'TXZ01' '' '' '' '' '' '' '' '' '' '' '',
    'EINDT' 'EKET' 'EINDT' '' '' '' '' '' '' '' '' '' '' '',
    'MENGE_EKET' 'EKET' 'MENGE' '' '' 'PO Qty' '' '' '' '' '' '' 'MEINS' '',
    'MEINS' 'EKPO' 'MEINS' '' '' '' '' '' '' '' '' '' '' '',
    'CURR_SAT' 'EKKO' 'WAERS' '' '' '' '' '' '' '' '' '' '' '',
    'HRGSAT' '' '' '' '15' 'Harga/Unit'  '' '' '' '' '' '' '' '',
*    'VALUE_IDR' '' '' '' '15' 'Value IDR' '' '' '' 'IDR' '' '' '' '',
    'VALUE_IDR' '' '' '' '15' 'Value IDR' '' '' '0' '' '' '' '' '',
    'BUDGET_CURR' '' '' '' '11' 'Curr.Budget' '' '' '' '' '' '' '' '',
    'EXC_RATE' '' '' '' '11' 'Exch.Rate' '' '' '' '' '' '' '' '',
    'NETWR' 'EKPO' 'NETWR' '' '' '' '' '' '' '' '' 'WAERS' '' '',
    'WAERS' 'EKKO' 'WAERS' '' '' '' '' '' '' '' '' '' '' '',
    'WEMNG' 'EKET' 'WEMNG' '' '' 'GR Qty' '' '' '' '' '' '' 'MEINS' '',
    'FIRSTBUDAT' 'EKBE' 'BUDAT' '' '12' 'First GR Date' '' '' '' '' '' '' '' '',
    'BUDAT' 'EKBE' 'BUDAT' '' '12' 'Last GR Date' '' '' '' '' '' '' '' '',
    'PLIFZ' 'MARC' 'PLIFZ' '' '' 'LT' '' '' '' '' '' '' '' '',
    'DELREL' '' '' '' '22' 'PR Del.Dt-Final Rel.PR' '' '' '' '' '' '' '' '',
    'GRPR' '' '' '' '15' 'GR Dt-PR Del.Dt' '' '' '' '' '' '' '' '',
    'FIRSTQTYGR' 'EKET' 'MENGE' '' '' 'Qty First GR' '' '' '' '' '' '' 'MEINS' '',
    'GRPO_LAST' '' '' '' '25' 'Last GR vs PO Del.Date' '' '' '' '' '' '' '' '',
    'GRPO_FIRST' '' '' '' '25' 'First GR vs PO Del.Date' '' '' '' '' '' '' '' ''.

  CASE pa_inter.
    WHEN 1.
      PERFORM f_fieldcatg USING ft_report:
      'QTYOTIM' 'EKET' 'MENGE' '' '20' 'QTY Interval I' '' '' '' '' '' '' '' '',
*      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '' 'IDR' '' '' '' ''.
      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '0' '' '' '' '' ''.

    WHEN 2.
      PERFORM f_fieldcatg USING ft_report:
      'QTYOTIM' 'EKET' 'MENGE' '' '20' 'QTY Interval I' '' '' '' '' '' '' '' '',
*      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '' 'IDR' '' '' '' '',
      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '0' '' '' '' '' '',
      'QTYLATE01' 'EKET' 'MENGE' '' '20' 'QTY Interval II' '' '' '' '' '' '' '' '',
*      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '' 'IDR' '' '' '' ''.
      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '0' '' '' '' '' ''.
    WHEN 3.
      PERFORM f_fieldcatg USING ft_report:
      'QTYOTIM' 'EKET' 'MENGE' '' '20' 'QTY Interval I' '' '' '' '' '' '' '' '',
*      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '' 'IDR' '' '' '' '',
      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '0' '' '' '' '' '',
      'QTYLATE01' 'EKET' 'MENGE' '' '20' 'QTY Interval II' '' '' '' '' '' '' '' '',
*      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '' 'IDR' '' '' '' '',
      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '0' '' '' '' '' '',
      'QTYLATE02' 'EKET' 'MENGE' '' '20' 'QTY Interval III' '' '' '' '' '' '' '' '',
*      'VALLATE02' 'EKET' 'WEMNG' '' '20' 'Value Interval III' '' '' '' 'IDR' '' '' '' ''.
      'VALLATE02' 'EKET' 'WEMNG' '' '20' 'Value Interval III' '' '' '0' '' '' '' '' ''.
    WHEN 4.
      PERFORM f_fieldcatg USING ft_report:
      'QTYOTIM' 'EKET' 'MENGE' '' '20' 'QTY Interval I' '' '' '' '' '' '' '' '',
*      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '' 'IDR' '' '' '' '',
      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '0' '' '' '' '' '',
      'QTYLATE01' 'EKET' 'MENGE' '' '20' 'QTY Interval II' '' '' '' '' '' '' '' '',
*      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '' 'IDR' '' '' '' '',
      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '0' '' '' '' '' '',
      'QTYLATE02' 'EKET' 'MENGE' '' '20' 'QTY Interval III' '' '' '' '' '' '' '' '',
*      'VALLATE02' 'EKET' 'WEMNG' '' '20' 'Value Interval III' '' '' '' 'IDR' '' '' '' '',
      'VALLATE02' 'EKET' 'WEMNG' '' '20' 'Value Interval III' '' '' '0' '' '' '' '' '',
      'QTYLATE03' 'EKET' 'MENGE' '' '20' 'QTY Interval IV' '' '' '' '' '' '' '' '',
*      'VALLATE03' 'EKET' 'WEMNG' '' '20' 'Value Interval IV' '' '' '' 'IDR' '' '' '' ''.
      'VALLATE03' 'EKET' 'WEMNG' '' '20' 'Value Interval IV' '' '' '0' '' '' '' '' ''.
    WHEN 5.
      PERFORM f_fieldcatg USING ft_report:
      'QTYOTIM' 'EKET' 'MENGE' '' '20' 'QTY Interval I' '' '' '' '' '' '' '' '',
*      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '' 'IDR' '' '' '' '',
      'VALOTIM' 'EKET' 'WEMNG' '' '20' 'Value Interval I' '' '' '0' '' '' '' '' '',
      'QTYLATE01' 'EKET' 'MENGE' '' '20' 'QTY Interval II' '' '' '' '' '' '' '' '',
*      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '' 'IDR' '' '' '' '',
      'VALLATE01' 'EKET' 'WEMNG' '' '20' 'Value Interval II' '' '' '0' '' '' '' '' '',
      'QTYLATE02' 'EKET' 'MENGE' '' '20' 'QTY Interval III' '' '' '' '' '' '' '' '',
*      'VALLATE02' 'EKET' 'WEMNG' '' '20' 'Value Interval III' '' '' '' 'IDR' '' '' '' '',
      'VALLATE02' 'EKET' 'WEMNG' '' '20' 'Value Interval III' '' '' '0' '' '' '' '' '',
      'QTYLATE03' 'EKET' 'MENGE' '' '20' 'QTY Interval IV' '' '' '' '' '' '' '' '',
*      'VALLATE03' 'EKET' 'WEMNG' '' '20' 'Value Interval IV' '' '' '' 'IDR' '' '' '' '',
      'VALLATE03' 'EKET' 'WEMNG' '' '20' 'Value Interval IV' '' '' '0' '' '' '' '' '',
      'QTYLATE04' 'EKET' 'MENGE' '' '20' 'QTY Interval V' '' '' '' '' '' '' '' '',
*      'VALLATE04' 'EKET' 'WEMNG' '' '20' 'Value Interval V' '' '' '' 'IDR' '' '' '' ''.
      'VALLATE04' 'EKET' 'WEMNG' '' '20' 'Value Interval V' '' '' '0' '' '' '' '' ''.
  ENDCASE.

  PERFORM f_fieldcatg USING ft_report:
  'GRPO' 'EKET' 'MENGE' '' '20' 'Jumlah Barang Terima' '' '' '' '' '' '' 'MEINS' '',
  'TEXT' '' '' '' '100' 'Keterangan' '' '' '' '' '' '' '' '',
  'ELIKZ' 'EKPO' 'ELIKZ' '' '' '' '' '' '' '' '' '' '' ''.
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
                          value(fu_checkbox).

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
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'EBELP'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'EINDT'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'ETENR'.
  ld_sort-up        = 'X'.
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
  REFRESH: t_vdata, t_eket, t_eban, t_lifnr, t_knumv, t_matnr,
           t_lfa1, t_konv, t_mara, t_marc.
  CLEAR: t_vdata, t_eket, t_eban, t_lifnr, t_knumv, t_matnr,
         t_lfa1, t_konv, t_mara, t_marc.
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
  DATA: ld_tabkey    LIKE cdpos-tabkey,
        ld_objectid  LIKE cdhdr-objectid,
        ld_bedat     LIKE ekko-bedat,
        ld_waers     LIKE konv-waers,
        ld_menge     LIKE ekbe-menge,
        ld_menge1    LIKE ekbe-menge,
        ld_budat     LIKE ekbe-budat,
        ld_flag      TYPE i,
        ld_banfn     LIKE eket-banfn,
        ld_badat     LIKE eban-badat,
        ld_reldt     LIKE sy-datum,
        ld_lfdat     LIKE eban-lfdat,
        ld_name1     LIKE lfa1-name1,
        ld_hrgsat    TYPE p DECIMALS 4,
        ld_wemng     LIKE eket-wemng,
        ld_gr_date   LIKE ekbe-budat,
        ld_count     TYPE i,
        ld_eindt     LIKE eket-eindt.

  DATA: ld_name    LIKE thead-tdname,
        ld_object  LIKE thead-tdobject.
  DATA: BEGIN OF lt_tline OCCURS 0.
          INCLUDE STRUCTURE tline.
  DATA: END OF lt_tline.

  DATA: lt_tcurf     TYPE STANDARD TABLE OF tcurf,
        lw_tcurf     TYPE tcurf.

  DATA: BEGIN OF lt_editpos OCCURS 0.
          INCLUDE STRUCTURE cdred.
  DATA: END OF lt_editpos.

  DATA: ld_time    TYPE i.

  SORT t_vdata BY ebeln ebelp.
*  SORT t_eket BY ebeln ebelp etenr.
  SORT t_eket BY ebeln ebelp eindt etenr.

  LOOP AT t_eket.
    t_eketdata-ebeln   = t_eket-ebeln.
    t_eketdata-ebelp   = t_eket-ebelp.
    t_eketdata-count   = 1.
    IF t_eket-menge IS NOT INITIAL.
      t_eketdata-menge = 1.
    ELSE.
      CLEAR: t_eketdata-menge.
    ENDIF.
    IF t_eket-wemng IS NOT INITIAL.
      t_eketdata-wemng = 1.
    ELSE.
      CLEAR: t_eketdata-wemng.
    ENDIF.
    COLLECT t_eketdata.
    t_out-budget_curr  = 'IDR'.
    t_out-ebeln        = t_eket-ebeln.
    t_out-etenr        = t_eket-etenr.
    t_out-ebelp        = t_eket-ebelp.
    t_out-banfn        = t_eket-banfn.
    t_out-bnfpo        = t_eket-bnfpo.
    t_out-eindt        = t_eket-eindt.
    t_out-menge_eket   = t_eket-menge.
    t_out-wemng        = t_eket-wemng.
    READ TABLE t_vdata WITH KEY ebeln = t_eket-ebeln
                                ebelp = t_eket-ebelp
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING t_vdata TO t_out.
* Get Vendor Name
      READ TABLE t_lfa1 WITH KEY lifnr = t_vdata-lifnr.
      IF sy-subrc EQ 0.
        t_out-name1  = t_lfa1-name1.
      ENDIF.
      READ TABLE t_eban WITH KEY banfn = t_eket-banfn
                                 bnfpo = t_eket-bnfpo.
      IF sy-subrc EQ 0.
        t_out-badat       = t_eban-badat.
        t_out-menge_eban  = t_eban-menge.
        t_out-lfdat       = t_eban-lfdat.

* Get Old Material Number
        READ TABLE t_mara WITH KEY matnr = t_vdata-matnr.
        IF sy-subrc EQ 0.
          t_out-bismt  = t_mara-bismt.
        ENDIF.
* Get LT
        READ TABLE t_marc WITH KEY matnr = t_vdata-matnr.
        IF sy-subrc EQ 0.
          t_out-plifz  = t_marc-plifz.
        ENDIF.
* Get Final Release Date
        IF t_eban-frgkz EQ '2'.
          CONCATENATE sy-mandt t_eban-banfn t_eban-bnfpo INTO ld_tabkey.
          ld_objectid = t_eban-banfn.

          CALL FUNCTION 'CHANGEDOCUMENT_READ'
            EXPORTING
              objectclass = 'BANF'
              objectid    = ld_objectid
              tablekey    = ld_tabkey
              tablename   = 'EBAN'
            TABLES
              editpos     = lt_editpos.

          READ TABLE lt_editpos WITH KEY tabname = 'EBAN'
                                         tabkey  = ld_tabkey
                                         chngind = 'U'
                                         fname   = 'FRGKZ'
                                         f_new   = '2'.
          IF sy-subrc EQ 0.
            t_out-reldt  = lt_editpos-udate.
          ENDIF.
        ENDIF.
      ENDIF.

      PERFORM f_get_harga USING    t_out-knumv t_out-ebeln t_out-ebelp t_out-waers
                                   t_out-menge_eket t_out-menge t_out-bedat t_out-wkurs
                          CHANGING t_out-curr_sat t_out-exc_rate t_out-hrgsat
                                   t_out-netwr t_out-value_idr.

      ON CHANGE OF t_eket-ebeln OR t_eket-ebelp.
        CLEAR: ld_menge, ld_budat.
      ENDON.

      ld_menge = t_out-wemng.

      IF t_vdata-matnr CP 'PCC*'.
        SORT t_ekbe BY ebeln ebelp bldat belnr.
      ELSE.
        SORT t_ekbe BY ebeln ebelp budat belnr.
      ENDIF.

      IF t_out-lfdat IS NOT INITIAL AND
        t_out-reldt IS NOT INITIAL.
        t_out-delrel  = t_out-lfdat - t_out-reldt.
      ELSE.
        CLEAR: t_out-delrel.
      ENDIF.

      IF t_out-lfdat IS NOT INITIAL AND
        t_out-budat IS NOT INITIAL.
        t_out-grpr    = t_out-budat - t_out-lfdat.
      ELSE.
        CLEAR: t_out-grpr.
      ENDIF.

      IF t_out-werks = '1601' AND
        t_out-lewed NE '00000000'.
        t_out-budat = t_out-lewed.
      ENDIF.

      t_out-grpo  = t_out-wemng - t_out-menge_eket.

      IF t_out-banfn IS INITIAL.
        t_out-banfn = ld_banfn.
        t_out-badat = ld_badat.
        t_out-reldt = ld_reldt.
        t_out-lfdat = ld_lfdat.
      ELSE.
        ld_banfn  = t_out-banfn.
        ld_badat  = t_out-badat.
        ld_reldt  = t_out-reldt.
        ld_lfdat  = t_out-lfdat.
      ENDIF.

*    Get Keterangan, dari text di PO Item Detail -- Texts -- Delivery text
      CONCATENATE t_out-ebeln t_out-ebelp INTO ld_name.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'F04'
          language                = sy-langu
          name                    = ld_name
          object                  = 'EKPO'
        TABLES
          lines                   = lt_tline
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
        REFRESH: lt_tline.
        CLEAR: lt_tline.
      ENDIF.

      LOOP AT lt_tline.
        CONCATENATE t_out-text lt_tline-tdline INTO t_out-text
        SEPARATED BY space.
      ENDLOOP.
*    ---end Get Keterangan
      APPEND t_out.

      IF t_eket-etenr EQ 1.
        t_eketdat1-ebeln       = t_out-ebeln.
        t_eketdat1-ebelp       = t_out-ebelp.
        t_eketdat1-banfn       = t_out-banfn.
        t_eketdat1-badat       = t_out-badat.
        t_eketdat1-menge_eban  = t_out-menge_eban.
        t_eketdat1-reldt       = t_out-reldt.
        t_eketdat1-lfdat       = t_out-lfdat.
        APPEND t_eketdat1.
      ENDIF.
      CLEAR: t_out, ld_flag.
    ENDIF.
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
*&      Form  f_hitung_qty_ontime_late
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BSART  text
*      -->FU_DATE  text
*      -->FU_EINDT  text
*      -->FU_MENGE  text
*      <--FC_QTYOTIM  text
*      <--FC_QTYLATE01  text
*      <--FC_QTYLATE02  text
*      <--FC_QTYLATE03  text
*      <--FC_QTYLATE04  text
*----------------------------------------------------------------------*
FORM f_hitung_qty_ontime_late  USING    fu_bsart fu_date fu_eindt fu_menge fu_lfdat
                               CHANGING fc_qtyotim fc_qtylate01 fc_qtylate02
                                        fc_qtylate03 fc_qtylate04 fu_time.
  DATA: ld_int01  LIKE sy-datum,
        ld_int02  LIKE sy-datum,
        ld_int03  LIKE sy-datum,
        ld_int04  LIKE sy-datum,
        ld_int05  LIKE sy-datum,
        ld_int06  LIKE sy-datum,
        ld_int07  LIKE sy-datum,
        ld_int08  LIKE sy-datum.
  DATA: ld_otim  LIKE eket-menge.

  CASE fu_bsart.
    WHEN 'ZLOC'.
      ld_int01  = fu_eindt + pa_int01.
      ld_int02  = fu_eindt + pa_int02.
      ld_int03  = fu_eindt + pa_int03.
      ld_int04  = fu_eindt + pa_int04.
      ld_int05  = fu_eindt + pa_int05.
      ld_int06  = fu_eindt + pa_int06.
      ld_int07  = fu_eindt + pa_int07.
      ld_int08  = fu_eindt + pa_int08.

      IF fu_date LE ld_int01.
        ADD fu_menge TO fc_qtyotim.
        fu_time  = 1.
      ELSEIF fu_date GE ld_int02 AND fu_date LE ld_int03.
        ADD fu_menge TO fc_qtylate01.
        fu_time  = 2.
      ELSEIF fu_date GE ld_int04 AND fu_date LE ld_int05.
        ADD fu_menge TO fc_qtylate02.
        fu_time  = 3.
      ELSEIF fu_date GE ld_int06 AND fu_date LE ld_int07.
        ADD fu_menge TO fc_qtylate03.
        fu_time  = 4.
      ELSEIF fu_date GE ld_int08.
        ADD fu_menge TO fc_qtylate04.
        fu_time  = 5.
      ENDIF.

    WHEN 'ZIMP'.
      ld_int01  = fu_eindt + pa_int01.
      ld_int02  = fu_eindt + pa_int02.
      ld_int03  = fu_eindt + pa_int03.
      ld_int04  = fu_eindt + pa_int04.
      ld_int05  = fu_eindt + pa_int05.
      ld_int06  = fu_eindt + pa_int06.
      ld_int07  = fu_eindt + pa_int07.
      ld_int08  = fu_eindt + pa_int08.

      IF fu_date LE ld_int01.
        ADD fu_menge TO fc_qtyotim.
        fu_time  = 1.
      ELSEIF fu_date GE ld_int02 AND fu_date LE ld_int03.
        ADD fu_menge TO fc_qtylate01.
        fu_time  = 2.
      ELSEIF fu_date GE ld_int04 AND fu_date LE ld_int05.
        ADD fu_menge TO fc_qtylate02.
        fu_time  = 3.
      ELSEIF fu_date GE ld_int06 AND fu_date LE ld_int07.
        ADD fu_menge TO fc_qtylate03.
        fu_time  = 4.
      ELSEIF fu_date GE ld_int08.
        ADD fu_menge TO fc_qtylate04.
        fu_time  = 5.
      ENDIF.
  ENDCASE.

  CLEAR: va_flag.
*  PERFORM f_hitung_qty_minus USING va_flag
*                             CHANGING fc_qtyotim fc_qtylate01 fc_qtylate02
*                                      fc_qtylate03 fc_qtylate04 ld_otim.
ENDFORM.                    " f_hitung_qty_ontime_late

*&---------------------------------------------------------------------*
*&      Form  f_validate_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: ld_mess(50) VALUE 'Error in interval'.

  IF pa_inter GT 5.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'INT'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_int01 GE pa_int02.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IN2'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_int02 GE pa_int03.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IN3'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_int03 GE pa_int04.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IN4'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_int04 GE pa_int05.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IN5'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_int05 GE pa_int06.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IN6'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_int06 GE pa_int07.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IN7'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_int07 GE pa_int08.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IN8'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.
ENDFORM.                    " f_validate_screen_1000

*&---------------------------------------------------------------------*
*&      Form  f_vs_tanggal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BSART  text
*      -->FU_DATE  text
*      -->FU_EINDT  text
*      -->FU_LFDAT  text
*      -->FU_FIRSTBUDAT  text
*      <--FC_GRPO_FIRST  text
*      <--FC_GRPO_LAST  text
*----------------------------------------------------------------------*
FORM f_vs_tanggal  USING    fu_bsart fu_date fu_eindt fu_lfdat fu_firstbudat
                   CHANGING fc_grpo_first fc_grpo_last.

  CASE fu_bsart.
    WHEN 'ZLOC'.
      fc_grpo_last  = fu_date - fu_eindt.
      IF fu_firstbudat IS NOT INITIAL.
        fc_grpo_first = fu_firstbudat - fu_eindt.
      ENDIF.
    WHEN 'ZIMP'.
      fc_grpo_last  = fu_date - fu_eindt.
      IF fu_firstbudat IS NOT INITIAL.
        fc_grpo_first = fu_firstbudat - fu_eindt.
      ENDIF.
  ENDCASE.
ENDFORM.                    " f_vs_tanggal

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE pa_inter.
    WHEN 1.
      LOOP AT SCREEN.
        IF screen-group1 = 'IN2' OR
          screen-group1 = 'IN3' OR
          screen-group1 = 'IN4' OR
          screen-group1 = 'IN5' OR
          screen-group1 = 'IN6' OR
          screen-group1 = 'IN7' OR
          screen-group1 = 'IN8'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE1' OR
          screen-group1 = 'GE2' OR
          screen-group1 = 'GE3' OR
          screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 2.
      LOOP AT SCREEN.
        IF screen-group1 = 'IN3' OR
          screen-group1 = 'IN4' OR
          screen-group1 = 'IN5' OR
          screen-group1 = 'IN6' OR
          screen-group1 = 'IN7' OR
          screen-group1 = 'IN8'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE2' OR
           screen-group1 = 'GE3' OR
           screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 3.
      LOOP AT SCREEN.
        IF screen-group1 = 'IN5' OR
          screen-group1 = 'IN6' OR
          screen-group1 = 'IN7' OR
          screen-group1 = 'IN8'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE1' OR
           screen-group1 = 'GE3' OR
           screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 4.
      LOOP AT SCREEN.
        IF screen-group1 = 'IN7' OR
          screen-group1 = 'IN8'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GE1' OR
           screen-group1 = 'GE2' OR
           screen-group1 = 'GE4'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 5.
      LOOP AT SCREEN.
        IF screen-group1 = 'GE1' OR
           screen-group1 = 'GE2' OR
           screen-group1 = 'GE3'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_modify_screen_1000

*&---------------------------------------------------------------------*
*&      Form  F_GET_HARGA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_harga  USING    fu_knumv fu_ebeln fu_ebelp fu_waers
                           fu_eket_menge fu_ekpo_menge fu_bedat fu_wkurs
                  CHANGING fc_curr_sat fc_exc_rate fc_hrgsat fc_netwr fc_value_idr.

  DATA: d_kbetr     TYPE konv-kbetr,
        d_kkurs     TYPE konv-kkurs,
        d_kpein     TYPE konv-kpein.

  DATA: lt_tcurf    TYPE STANDARD TABLE OF tcurf,
        l_tcurf_new TYPE tcurf,
        i_date      TYPE ekko-bedat.

  DATA: lt_tcurr    TYPE STANDARD TABLE OF tcurr,
        l_tcurr_new TYPE tcurr.

  DATA: d_currdec   TYPE i,
  v_currdec   TYPE i,
  d_hrgsat    TYPE p LENGTH 9 DECIMALS 5.

  CLEAR : d_kbetr, d_kkurs, fc_curr_sat, d_hrgsat.
  d_currdec = 2.
  v_currdec = 2.
  d_kpein   = 1.

  SELECT SINGLE kbetr kpein waers kkurs
  FROM konv
  INTO (d_kbetr, d_kpein, fc_curr_sat, d_kkurs)
  WHERE knumv EQ fu_knumv  AND
        kposn EQ fu_ebelp AND
        kappl EQ 'M'      AND
        kschl IN ('ZPB0', 'ZPB1').

  SELECT SINGLE currdec INTO d_currdec
  FROM tcurx
  WHERE currkey = fc_curr_sat.

  IF d_currdec = 0.
    d_hrgsat = d_kbetr / d_kpein * 100.
  ELSE.
    IF d_currdec = 3.
      d_hrgsat = d_kbetr / d_kpein * 10.
    ELSE.
      d_hrgsat = d_kbetr / d_kpein.
    ENDIF.
  ENDIF.

  fc_hrgsat = d_hrgsat.
  fc_netwr = fc_netwr * fu_eket_menge / fu_ekpo_menge.


* Exchange Rate

  IF fu_waers <> 'IDR' AND fu_waers EQ fc_curr_sat.
    i_date = fu_bedat.
    CONVERT DATE i_date INTO INVERTED-DATE i_date.
    l_tcurf_new-tfact = '1'.

    SELECT *
    FROM tcurf
    INTO TABLE lt_tcurf
    WHERE kurst = 'M' AND
          fcurr = fc_curr_sat AND
          tcurr = 'IDR' AND
          gdatu >= i_date.

    IF sy-subrc = 0.
      SORT lt_tcurf BY gdatu.
      READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
      l_tcurf_new-tfact = l_tcurf_new-tfact.
    ENDIF.

    fc_exc_rate   = d_kkurs * l_tcurf_new-tfact.
  ELSEIF fu_waers <> 'IDR' AND fu_waers NE fc_curr_sat.

    i_date = fu_bedat.
    CONVERT DATE i_date INTO INVERTED-DATE i_date.
    l_tcurr_new-ukurs = 1.
    SELECT *
    FROM tcurr
    INTO TABLE lt_tcurr
    WHERE kurst = 'M' AND
          fcurr = fu_waers AND
          tcurr = 'IDR' AND
          gdatu >= i_date.
    IF sy-subrc = 0.
      SORT lt_tcurr BY gdatu.
      READ TABLE lt_tcurr INTO l_tcurr_new INDEX 1.
      l_tcurr_new-ukurs = l_tcurr_new-ukurs.
    ENDIF.


    i_date = fu_bedat.
    CONVERT DATE i_date INTO INVERTED-DATE i_date.
    l_tcurf_new-tfact = '1'.

    SELECT *
    FROM tcurf
    INTO TABLE lt_tcurf
    WHERE kurst = 'M' AND
          fcurr = fu_waers AND
          tcurr = 'IDR' AND
          gdatu >= i_date.

    IF sy-subrc = 0.
      SORT lt_tcurf BY gdatu.
      READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
      l_tcurf_new-tfact = l_tcurf_new-tfact.
    ENDIF.

    fc_exc_rate   = l_tcurr_new-ukurs * l_tcurf_new-tfact.
  ELSE.
    fc_exc_rate   = 1.
  ENDIF.

* Value IDR

  IF fu_waers <> 'IDR'.
    fc_value_idr = fc_netwr * fc_exc_rate.
  ELSE.
    fc_value_idr = fc_netwr.
  ENDIF.

  SELECT SINGLE currdec INTO v_currdec
  FROM tcurx
  WHERE currkey = fu_waers.

  IF v_currdec = 0.
    fc_value_idr = fc_value_idr * 100.
  ELSE.
    IF v_currdec = 3.
      fc_value_idr = fc_value_idr * 10.
    ELSE.
      fc_value_idr = fc_value_idr.
    ENDIF.
  ENDIF.

* If these codes are wanna be activated/uncomment, please activate/uncomment the codes in the f_build_fieldcat form
* like Value_IDR, Valotim, Vallate01, Vallate02, Vallate03, Vallate04
*
*  DATA: d_kbetr     TYPE konv-kbetr,
*        d_kkurs     TYPE konv-kkurs,
*        d_kpein     TYPE konv-kpein,
*        d_wkurs     TYPE p DECIMALS 5.
*  DATA: lt_tcurf    TYPE STANDARD TABLE OF tcurf,
*        l_tcurf_new TYPE tcurf,
*        i_date      TYPE ekko-bedat.
*
*  CLEAR : d_kbetr, fc_curr_sat.
*
*  SELECT SINGLE kbetr kpein waers kkurs
*  FROM konv
*  INTO (d_kbetr, d_kpein, fc_curr_sat, d_kkurs)
*  WHERE knumv EQ fu_knumv  AND
*        kposn EQ fu_ebelp AND
*        kappl EQ 'M'      AND
*        kschl IN ('ZPB0', 'ZPB1').
*
*  fc_hrgsat  = d_kbetr.
*
*  IF fu_waers = 'IDR' AND fc_curr_sat <> 'IDR'.
*    SELECT SINGLE kbetr
*    INTO d_kbetr
*    FROM konv
*    WHERE knumv = fu_knumv AND
*          kposn = fu_ebelp AND
*          kappl = 'M' AND
*          kschl = 'ZEXC'.
*    IF sy-subrc EQ 0.
*      IF fc_curr_sat = 'JPY'.
*        d_wkurs = d_kbetr / 1000.
*      ELSE.
*        d_wkurs = d_kbetr * 100.
*      ENDIF.
*    ELSE.
*      d_wkurs = fu_wkurs.
*      fc_hrgsat = d_kbetr / d_kpein.
*    ENDIF.
*  ELSE.
*    d_wkurs = fu_wkurs.
*    IF fu_waers = 'IDR' AND fc_curr_sat EQ 'IDR'.
*      fc_hrgsat = d_kbetr / d_kpein * 100.
*    ENDIF.
*  ENDIF.
*
*  fc_netwr = fc_netwr * fu_eket_menge / fu_ekpo_menge.
*
** Exchange Rate
*  IF fu_waers NE 'IDR'.
*    i_date = fu_bedat.
*    CONVERT DATE i_date INTO INVERTED-DATE i_date.
*    l_tcurf_new-tfact = '1'.
*    SELECT *
*    FROM tcurf
*    INTO TABLE lt_tcurf
*    WHERE kurst = 'M' AND
*          fcurr = fu_waers AND
*          tcurr = 'IDR' AND
*          gdatu >= i_date.
*    IF sy-subrc = 0.
*      SORT lt_tcurf BY gdatu.
*      READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
*      l_tcurf_new-tfact = l_tcurf_new-tfact.
*    ENDIF.
*    fc_exc_rate   = d_kkurs * l_tcurf_new-tfact.
*  ELSE.
*    fc_exc_rate = 1.
*    IF fu_waers = 'IDR' AND fc_curr_sat <> 'IDR'.
*      i_date = fu_bedat.
*      CONVERT DATE i_date INTO INVERTED-DATE i_date.
*      l_tcurf_new-tfact = '1'.
*      SELECT *
*      FROM tcurf
*      INTO TABLE lt_tcurf
*      WHERE kurst = 'M' AND
*            fcurr = fc_curr_sat AND
*            tcurr = 'IDR' AND
*            gdatu >= i_date.
*      IF sy-subrc = 0.
*        SORT lt_tcurf BY gdatu.
*        READ TABLE lt_tcurf INTO l_tcurf_new INDEX 1.
*        l_tcurf_new-tfact = l_tcurf_new-tfact.
*      ENDIF.
*      fc_exc_rate = d_kkurs * l_tcurf_new-tfact.
*    ENDIF.
*  ENDIF.
*
** Value IDR
*  IF fu_waers EQ 'IDR'.
*    fc_value_idr = fc_netwr.
*  ELSE.
*    SELECT SINGLE * FROM tcurx WHERE currkey = fu_waers.
*    IF sy-subrc EQ 0.
*      fc_value_idr = d_wkurs * fc_netwr.
*    ELSE.
*      fc_value_idr = d_wkurs * fc_netwr * 10.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_GET_HARGA

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_QTY_MINUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--FC_QTYOTIM  text
*      <--FC_QTYLATE01  text
*      <--FC_QTYLATE02  text
*      <--FC_QTYLATE03  text
*      <--FC_QTYLATE04  text
*----------------------------------------------------------------------*
FORM f_hitung_qty_minus  USING fu_inter fu_tabix fu_tabix1 fu_ebeln fu_ebelp
                               fu_qtyotim fu_qtylate01 fu_qtylate02
                               fu_qtylate03 fu_qtylate04
                         CHANGING fc_menge_eket fc_date.
  DATA: ld_qty  LIKE eket-menge.
  DATA: lw_out  LIKE t_out.

  CASE fu_inter.
    WHEN 1.
      ld_qty  = fu_qtyotim.
    WHEN 2.
      ld_qty  = fu_qtylate01.
    WHEN 3.
      ld_qty  = fu_qtylate02.
    WHEN 4.
      ld_qty  = fu_qtylate03.
    WHEN 5.
      ld_qty  = fu_qtylate04.
  ENDCASE.

  WHILE ld_qty LT 0.
    IF fu_inter IS NOT INITIAL.
      IF fu_qtylate04 LT 0.
        fu_qtylate03 = fu_qtylate03 + fu_qtylate04.
        ld_qty       = fu_qtylate03.
        fu_qtylate04 = 0.
        MODIFY t_out INDEX fu_tabix1 TRANSPORTING qtylate04 qtylate03.
      ENDIF.
      IF fu_qtylate03 LT 0.
        fu_qtylate02 = fu_qtylate02 + fu_qtylate03.
        ld_qty       = fu_qtylate02.
        fu_qtylate03 = 0.
        MODIFY t_out INDEX fu_tabix1 TRANSPORTING qtylate03 qtylate02.
      ENDIF.
      IF fu_qtylate02 LT 0.
        fu_qtylate01 = fu_qtylate01 + fu_qtylate02.
        ld_qty       = fu_qtylate01.
        fu_qtylate02 = 0.
        MODIFY t_out INDEX fu_tabix1 TRANSPORTING qtylate02 qtylate01.
      ENDIF.
      IF fu_qtylate01 LT 0.
        fu_qtyotim   = fu_qtyotim + fu_qtylate01.
        ld_qty       = fu_qtyotim.
        fu_qtylate01 = 0.
        MODIFY t_out INDEX fu_tabix1 TRANSPORTING qtylate01 qtyotim.
      ENDIF.
      IF fu_qtyotim LT 0.
        READ TABLE t_out INTO lw_out INDEX fu_tabix.
        IF lw_out-ebeln EQ fu_ebeln AND
          lw_out-ebelp EQ fu_ebelp.
          lw_out-qtylate04 = lw_out-qtylate04 + fu_qtyotim.
          ld_qty           = fu_qtylate04 = lw_out-qtylate04.
          fu_qtyotim       = 0.
          MODIFY t_out INDEX fu_tabix1 TRANSPORTING qtyotim.
          fu_qtylate03     = lw_out-qtylate03.
          fu_qtylate02     = lw_out-qtylate02.
          fu_qtylate01     = lw_out-qtylate01.
          fu_qtyotim       = lw_out-qtyotim.
          fu_tabix1        = fu_tabix.
          MODIFY t_out FROM lw_out INDEX fu_tabix TRANSPORTING qtylate04.
          fu_tabix         = fu_tabix - 1.
        ELSE.
          ld_qty  = 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDWHILE.

  IF lw_out-wemng IS INITIAL.
    READ TABLE t_out INTO lw_out INDEX fu_tabix1.
  ELSE.
    IF lw_out-ebeln NE fu_ebeln OR
      lw_out-ebelp NE fu_ebelp.
      READ TABLE t_out INTO lw_out INDEX fu_tabix1.
    ENDIF.
  ENDIF.

  fc_menge_eket  = lw_out-menge_eket - fu_qtyotim - fu_qtylate01 - fu_qtylate02 -
                   fu_qtylate03 - fu_qtylate04.
  fc_date        = lw_out-eindt.
ENDFORM.                    " F_HITUNG_QTY_MINUS

*&---------------------------------------------------------------------*
*&      Form  F_UNDO_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_TIME  text
*      -->P_LD_MENGE  text
*      <--P_T_OUT_QTYOTIM  text
*      <--P_T_OUT_QTYLATE01  text
*      <--P_T_OUT_QTYLATE02  text
*      <--P_T_OUT_QTYLATE03  text
*      <--P_T_OUT_QTYLATE04  text
*----------------------------------------------------------------------*
FORM f_undo_qty  USING    fu_time
                          fu_menge
                 CHANGING fc_menge fc_qtyotim fc_qtylate01
                          fc_qtylate02 fc_qtylate03 fc_qtylate04.

  fc_menge     = fc_menge + fu_menge.

  CASE fu_time.
    WHEN 1.
      fc_qtyotim   = fc_qtyotim - fu_menge.
    WHEN 2.
      fc_qtylate01 = fc_qtylate01 - fu_menge.
    WHEN 3.
      fc_qtylate02 = fc_qtylate02 - fu_menge.
    WHEN 4.
      fc_qtylate03 = fc_qtylate03 - fu_menge.
    WHEN 5.
      fc_qtylate04 = fc_qtylate04 - fu_menge.
  ENDCASE.

  fu_menge  = fu_menge - fc_menge.
ENDFORM.                    " F_UNDO_QTY

*&---------------------------------------------------------------------*
*&      Form  F_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_interval .
  DATA: lw_out          LIKE t_out,
        ld_tabix        LIKE sy-tabix,
        ld_tabix1       LIKE sy-tabix,
        ld_tabix2       LIKE sy-tabix,
        ld_count        TYPE i,
        ld_noexit       TYPE i,
        lw_ekbe         LIKE t_ekbe,
        ld_eindt        LIKE sy-datum,
        ld_first        TYPE i,
        ld_cancel       TYPE i,
        ld_flag         TYPE i,
        ld_ebeln        LIKE eket-ebeln,
        ld_ebelp        LIKE eket-ebelp.

  DATA: ld_firstqtygr   LIKE t_out-firstqtygr,
        ld_switch       TYPE i,
        ld_menge        LIKE ekbe-menge.

  SORT t_out BY ebeln ebelp eindt etenr.
  SORT t_ekbedata BY ebeln ebelp.
  SORT t_eketdata BY ebeln ebelp.
  SORT t_eketdat1 BY ebeln ebelp.

  t_ekbe1[]  = t_ekbe[].
  LOOP AT t_out.
    ADD 1 TO ld_count.
    lw_out       = t_out.
    ld_tabix     = sy-tabix - 1.
    ld_tabix1    = sy-tabix.
    ld_tabix2    = sy-tabix.
    IF t_ekbe-matnr CP 'PCC*'.
      SORT t_ekbe BY ebeln ebelp bldat belnr buzei.
      SORT t_ekbe1 BY ebeln ebelp bldat belnr buzei.
    ELSE.
      SORT t_ekbe BY ebeln ebelp budat belnr buzei.
      SORT t_ekbe1 BY ebeln ebelp budat belnr buzei.
    ENDIF.

    ld_noexit = 1.
    IF ld_flag IS INITIAL.
      ld_flag = 1.
      READ TABLE t_ekbedata WITH KEY ebeln = t_out-ebeln
                                     ebelp = t_out-ebelp
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        ld_cancel = t_ekbedata-cancel.
      ENDIF.
    ENDIF.

    READ TABLE t_eketdata WITH KEY ebeln = t_out-ebeln
                                   ebelp = t_out-ebelp
    BINARY SEARCH.

    WHILE ld_noexit IS NOT INITIAL.
      PERFORM f_get_interval USING lw_out-eindt.
      PERFORM f_loop_ekbe USING ld_tabix ld_tabix1 ld_tabix2 ld_count ld_cancel
                                lw_out-ebeln lw_out-ebelp lw_out-wemng
                          CHANGING lw_out-menge_eket ld_noexit ld_eindt
                                   ld_first.
      IF ld_eindt IS NOT INITIAL.
        lw_out-eindt  = ld_eindt.
      ENDIF.
      DELETE t_ekbe WHERE ebeln EQ lw_out-ebeln AND
                          ebelp EQ lw_out-ebelp AND
                          menge EQ 0.
      READ TABLE t_ekbe INTO lw_ekbe WITH KEY ebeln = lw_out-ebeln
                                              ebelp = lw_out-ebelp.
      IF sy-subrc NE 0.
        CLEAR: ld_noexit.
      ENDIF.
      CLEAR: t_out, ld_eindt.
    ENDWHILE.

    CLEAR: ld_first.
    AT END OF ebeln.
      CLEAR: ld_count, lw_out, ld_first, ld_flag, ld_cancel, ld_tabix2.
    ENDAT.

    AT END OF ebelp.
      CLEAR: ld_count, lw_out, ld_flag, ld_cancel, ld_tabix2.
    ENDAT.
  ENDLOOP.

  SORT t_out BY ebeln ebelp eindt etenr.
*  SORT t_ekbe1 BY ebeln ebelp budat belnr buzei.
  LOOP AT t_out.
*    CLEAR: ld_ebeln, ld_ebelp, t_out-banfn, t_out-badat,
*           t_out-menge_eban, t_out-reldt, t_out-lfdat.
*    MODIFY t_out.
*
*    ld_ebeln  = t_out-ebeln.
*    ld_ebelp  = t_out-ebelp.
*    AT NEW ebeln.
*      PERFORM f_data_top_rec USING ld_ebeln ld_ebelp.
*    ENDAT.
*
*    AT NEW ebelp.
*      PERFORM f_data_top_rec USING ld_ebeln ld_ebelp.
*    ENDAT.

    t_out-grpo_last  = t_out-budat - t_out-eindt.
    IF t_out-firstbudat IS NOT INITIAL.
      t_out-grpo_first = t_out-firstbudat - t_out-eindt.
    ENDIF.
    MODIFY t_out TRANSPORTING grpo_last grpo_first.

    IF t_out-menge NE 0.
      t_out-vallate01  = t_out-value_idr / t_out-menge_eket * t_out-qtylate01.
      t_out-vallate02  = t_out-value_idr / t_out-menge_eket * t_out-qtylate02.
      t_out-vallate03  = t_out-value_idr / t_out-menge_eket * t_out-qtylate03.
      t_out-vallate04  = t_out-value_idr / t_out-menge_eket * t_out-qtylate04.
      t_out-valotim    = t_out-value_idr / t_out-menge_eket * t_out-qtyotim.
      MODIFY t_out TRANSPORTING valotim vallate01 vallate02 vallate03 vallate04.
    ENDIF.

    CLEAR: ld_switch.
    ld_firstqtygr  = t_out-menge_eket.
    LOOP AT t_ekbe1 WHERE ebeln EQ t_out-ebeln AND
                          ebelp EQ t_out-ebelp.
      IF t_ekbe1-shkzg EQ 'H'.
        t_ekbe1-menge = t_ekbe1-menge * -1.
      ENDIF.

      IF ld_switch IS INITIAL.
        IF t_ekbe1-menge LT 0.
          t_out-menge_eket  = t_out-menge_eket + t_ekbe1-menge.
          DELETE t_ekbe1.
        ELSE.
          IF t_out-menge_eket LT 0.
            t_out-menge_eket  = t_out-menge_eket + t_ekbe1-menge.
            IF t_out-menge_eket EQ ld_firstqtygr.
              DELETE t_ekbe1.
            ENDIF.
          ELSE.
            IF t_out-menge_eket LT t_ekbe1-menge.
              t_ekbe1-menge     = t_ekbe1-menge - t_out-menge_eket.
              MODIFY t_ekbe1 TRANSPORTING menge.
              IF ld_switch IS INITIAL.
                ld_switch  = 1.
                t_out-firstqtygr  = ld_firstqtygr.
                MODIFY t_out TRANSPORTING firstqtygr.
              ENDIF.
              EXIT.
            ENDIF.
          ENDIF.

          IF t_out-menge_eket GE t_ekbe1-menge.
            IF ld_switch IS INITIAL.
              ld_switch  = 1.
              t_out-firstqtygr  = t_ekbe1-menge.
              MODIFY t_out TRANSPORTING firstqtygr.
            ENDIF.
            t_out-menge_eket  = t_out-menge_eket - t_ekbe1-menge.
            DELETE t_ekbe1.
          ENDIF.
        ENDIF.
      ELSE.
        IF t_out-menge_eket LT t_ekbe1-menge.
          t_ekbe1-menge     = t_ekbe1-menge - t_out-menge_eket.
          MODIFY t_ekbe1 TRANSPORTING menge.
          IF ld_switch IS INITIAL.
            ld_switch  = 1.
            t_out-firstqtygr  = ld_firstqtygr.
            MODIFY t_out TRANSPORTING firstqtygr.
          ENDIF.
          EXIT.
        ENDIF.

        IF t_out-menge_eket GE t_ekbe1-menge.
          IF ld_switch IS INITIAL.
            ld_switch  = 1.
            t_out-firstqtygr  = t_ekbe1-menge.
            MODIFY t_out TRANSPORTING firstqtygr.
          ENDIF.
          t_out-menge_eket  = t_out-menge_eket - t_ekbe1-menge.
        ENDIF.
        DELETE t_ekbe1.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_INTERVAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_interval USING fu_eindt.
  CASE pa_inter.
    WHEN 1.
      ra_inter1-low    = fu_eindt + pa_int01.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'GE'.
      APPEND ra_inter1.

    WHEN 2.
      ra_inter1-low    = fu_eindt + pa_int01.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_int02.
      ra_inter2-high   = fu_eindt + pa_int03.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'GE'.
      APPEND ra_inter2.

    WHEN 3.
      ra_inter1-low    = fu_eindt + pa_int01.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_int02.
      ra_inter2-high   = fu_eindt + pa_int03.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'BT'.
      APPEND ra_inter2.

      ra_inter3-low    = fu_eindt + pa_int04.
      ra_inter3-high   = fu_eindt + pa_int05.
      ra_inter3-sign   = 'I'.
      ra_inter3-option = 'GE'.
      APPEND ra_inter3.

    WHEN 4.
      ra_inter1-low    = fu_eindt + pa_int01.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_int02.
      ra_inter2-high   = fu_eindt + pa_int03.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'BT'.
      APPEND ra_inter2.

      ra_inter3-low    = fu_eindt + pa_int04.
      ra_inter3-high   = fu_eindt + pa_int05.
      ra_inter3-sign   = 'I'.
      ra_inter3-option = 'BT'.
      APPEND ra_inter3.

      ra_inter4-low    = fu_eindt + pa_int06.
      ra_inter4-high   = fu_eindt + pa_int07.
      ra_inter4-sign   = 'I'.
      ra_inter4-option = 'GE'.
      APPEND ra_inter4.

    WHEN 5.
      ra_inter1-low    = fu_eindt + pa_int01.
      ra_inter1-sign   = 'I'.
      ra_inter1-option = 'LE'.
      APPEND ra_inter1.

      ra_inter2-low    = fu_eindt + pa_int02.
      ra_inter2-high   = fu_eindt + pa_int03.
      ra_inter2-sign   = 'I'.
      ra_inter2-option = 'BT'.
      APPEND ra_inter2.

      ra_inter3-low    = fu_eindt + pa_int04.
      ra_inter3-high   = fu_eindt + pa_int05.
      ra_inter3-sign   = 'I'.
      ra_inter3-option = 'BT'.
      APPEND ra_inter3.

      ra_inter4-low    = fu_eindt + pa_int06.
      ra_inter4-high   = fu_eindt + pa_int07.
      ra_inter4-sign   = 'I'.
      ra_inter4-option = 'BT'.
      APPEND ra_inter4.

      ra_inter5-low    = fu_eindt + pa_int08.
      ra_inter5-sign   = 'I'.
      ra_inter5-option = 'GE'.
      APPEND ra_inter5.
  ENDCASE.
ENDFORM.                    " F_GET_INTERVAL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_interval USING fu_date fu_wmeng
                       CHANGING fc_qtyotim fc_qtylate01 fc_qtylate02
                                fc_qtylate03 fc_qtylate04 fc_inter.
  IF ra_inter1[] IS NOT INITIAL.
    IF fu_date IN ra_inter1.
      ADD fu_wmeng TO fc_qtyotim.
      IF fc_qtyotim LT 0.
        fc_inter  = 1.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter2[] IS NOT INITIAL.
    IF fu_date IN ra_inter2.
      ADD fu_wmeng TO fc_qtylate01.
      IF fc_qtylate01 LT 0.
        fc_inter  = 2.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter3[] IS NOT INITIAL.
    IF fu_date IN ra_inter3.
      ADD fu_wmeng TO fc_qtylate02.
      IF fc_qtylate02 LT 0.
        fc_inter  = 3.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter4[] IS NOT INITIAL.
    IF fu_date IN ra_inter4.
      ADD fu_wmeng TO fc_qtylate03.
      IF fc_qtylate03 LT 0.
        fc_inter  = 4.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ra_inter5[] IS NOT INITIAL.
    IF fu_date IN ra_inter5.
      ADD fu_wmeng TO fc_qtylate04.
      IF fc_qtylate04 LT 0.
        fc_inter  = 5.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_INTERVAL

*&---------------------------------------------------------------------*
*&      Form  F_LOOP_EKBE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_EBELN  text
*      -->FU_EBELP  text
*----------------------------------------------------------------------*
FORM f_loop_ekbe  USING fu_tabix fu_tabix1 fu_tabix2 fu_count fu_cancel
                        fu_ebeln fu_ebelp fu_wemng
                  CHANGING fc_menge_eket fc_noexit fc_eindt
                           fc_first.

  DATA: ld_date      TYPE sy-datum,
        ld_qtyinter  LIKE ekbe-menge,
        ld_count     TYPE i,
        ld_inter     TYPE i,
        ld_menge     LIKE ekbe-menge,
        lw_out       LIKE t_out,
        lw_ekbe      LIKE t_ekbe,
        ld_flag      TYPE i,
        ld_flag1     TYPE i.

  CLEAR: ld_flag.
  READ TABLE t_eketdata WITH KEY ebeln = fu_ebeln
                                 ebelp = fu_ebelp
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    IF t_eketdata-menge NE t_eketdata-wemng.
      READ TABLE t_ekbe WITH KEY ebeln = fu_ebeln
                                 ebelp = fu_ebelp
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF fu_wemng IS INITIAL.
          LOOP AT t_ekbe WHERE ebeln EQ fu_ebeln AND
                               ebelp EQ fu_ebelp.
            ADD 1 TO ld_flag.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT t_ekbe WHERE ebeln EQ fu_ebeln AND
                       ebelp EQ fu_ebelp.

    t_out-budat  = t_ekbe-budat.
    IF t_ekbe-matnr CP 'PCC*'.
      ld_date = t_ekbe-bldat.
    ELSE.
      ld_date = t_ekbe-budat.
    ENDIF.

    IF t_ekbe-shkzg EQ 'H'.
      t_ekbe-menge = t_ekbe-menge * -1.
    ENDIF.

    IF fc_first IS INITIAL AND t_ekbe-menge GT 0.
      fc_first  = 1.
      t_out-firstbudat  = t_ekbe-budat.
*      IF t_ekbe-menge GT t_out-menge_eket.
*        t_out-firstqtygr  = t_out-menge_eket.
*      ELSE.
*        t_out-firstqtygr  = t_ekbe-menge.
*      ENDIF.
      MODIFY t_out INDEX fu_tabix1 TRANSPORTING firstbudat.
    ENDIF.

    IF fc_menge_eket IS INITIAL.
      IF t_ekbe-menge GE 0.
        IF fu_cancel IS NOT INITIAL.
          PERFORM f_hitung_qtyinter_cancel USING lw_out
                                           CHANGING fu_tabix fu_tabix1 ld_count fc_menge_eket
                                                    t_out-qtyotim t_out-qtylate01 t_out-qtylate02 t_out-qtylate03
                                                    t_out-qtylate04 ld_menge ld_qtyinter.
        ELSE.
          PERFORM f_hitung_qtyinter CHANGING fc_menge_eket ld_count ld_menge ld_qtyinter fu_cancel.
        ENDIF.
      ELSE.
        PERFORM f_hitung_qtyinter CHANGING fc_menge_eket ld_count ld_menge ld_qtyinter fu_cancel.
      ENDIF.
    ELSE.
      IF ld_flag EQ 1.
        fu_tabix      = fu_tabix - 1.
        fu_tabix1     = fu_tabix1 - 1.
        fc_menge_eket = t_ekbe-menge.
      ENDIF.
      PERFORM f_hitung_qtyinter CHANGING fc_menge_eket ld_count ld_menge ld_qtyinter fu_cancel.
    ENDIF.

    CLEAR: ld_inter.

    PERFORM f_modify_interval USING ld_date ld_qtyinter
                              CHANGING t_out-qtyotim t_out-qtylate01 t_out-qtylate02
                                       t_out-qtylate03 t_out-qtylate04 ld_inter.

    IF ld_inter IS NOT INITIAL.
      PERFORM f_hitung_qty_minus USING ld_inter fu_tabix fu_tabix1 fu_ebeln fu_ebelp
                                       t_out-qtyotim t_out-qtylate01 t_out-qtylate02
                                       t_out-qtylate03 t_out-qtylate04
                                 CHANGING fc_menge_eket ld_date.
      REFRESH: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
      CLEAR: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
      PERFORM f_get_interval USING ld_date.
    ELSE.
      IF ld_qtyinter IS NOT INITIAL.
        MODIFY t_out INDEX fu_tabix1 TRANSPORTING qtyotim qtylate01 qtylate02
                                                  qtylate03 qtylate04 budat.
      ENDIF.
    ENDIF.

    IF ld_count IS INITIAL.
      READ TABLE t_eketdata WITH KEY ebeln = fu_ebeln
                                     ebelp = fu_ebelp.
      IF sy-subrc EQ 0.
        IF fu_count EQ t_eketdata-count.
          PERFORM f_delete_menge_0 USING fu_ebeln fu_ebelp lw_out lw_ekbe
                                   CHANGING fu_tabix fu_tabix1 fc_menge_eket fc_eindt
                                            fc_noexit.
          EXIT.
        ELSE.
          IF fu_tabix1 LT fu_tabix2.
            IF ld_count IS INITIAL.
              ld_flag1 = fu_tabix2 - fu_tabix1.
              IF ld_flag1 EQ 1.
                PERFORM f_delete_menge_0 USING fu_ebeln fu_ebelp lw_out lw_ekbe
                                         CHANGING fu_tabix fu_tabix1 fc_menge_eket fc_eindt
                                                  fc_noexit.
                EXIT.
              ELSE.
                IF ld_flag IS INITIAL.
                  PERFORM f_delete_menge_0 USING fu_ebeln fu_ebelp lw_out lw_ekbe
                                           CHANGING fu_tabix fu_tabix1 fc_menge_eket fc_eindt
                                                    fc_noexit.
                  EXIT.
                ELSE.
                  CLEAR: fc_noexit.
                  EXIT.
                ENDIF.
              ENDIF.
            ELSE.
              CLEAR: fc_noexit.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR: fc_noexit.
            EXIT.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR: fc_noexit.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
  CLEAR: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
  CLEAR: lw_out, ld_count.
ENDFORM.                    " F_LOOP_EKBE

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_QTYINTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_qtyinter CHANGING fc_menge_eket fc_count fc_menge fc_qtyinter fc_cancel.
  IF fc_menge_eket GE t_ekbe-menge.
    fc_count      = 1.
    fc_menge_eket = fc_menge_eket - t_ekbe-menge.
    fc_menge      = t_ekbe-menge.
    fc_qtyinter   = fc_menge.
    t_ekbe-menge  = 0.
    MODIFY t_ekbe TRANSPORTING menge.
    IF fc_menge_eket EQ fc_qtyinter.
      IF fc_cancel IS NOT INITIAL.
        CLEAR: fc_count.
      ENDIF.
    ENDIF.
    CLEAR: fc_menge.
  ELSE.
    ADD t_ekbe-menge TO fc_menge.
    fc_qtyinter  = fc_menge_eket.
    t_ekbe-menge = t_ekbe-menge - fc_menge_eket.
    MODIFY t_ekbe TRANSPORTING menge.
    CLEAR: fc_count, fc_menge_eket.
  ENDIF.
ENDFORM.                    " F_HITUNG_QTYINTER

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_QTYINTER_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hitung_qtyinter_cancel USING ft_out STRUCTURE t_out
                              CHANGING fc_tabix fc_tabix1 fc_count fc_menge_eket fc_qtyotim
                                       fc_qtylate01 fc_qtylate02 fc_qtylate03 fc_qtylate04
                                       fc_menge fc_qtyinter.
  fc_tabix  = fc_tabix + 1.
  fc_tabix1 = fc_tabix1 + 1.
  READ TABLE t_out INTO ft_out INDEX fc_tabix1.
  IF sy-subrc EQ 0.
    fc_count        = 1.
    fc_menge_eket   = ft_out-menge_eket.
    fc_qtyotim      = ft_out-qtyotim.
    fc_qtylate01    = ft_out-qtylate01.
    fc_qtylate02    = ft_out-qtylate02.
    fc_qtylate03    = ft_out-qtylate03.
    fc_qtylate04    = ft_out-qtylate04.
    REFRESH: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
    CLEAR: ra_inter1, ra_inter2, ra_inter3, ra_inter4, ra_inter5.
    PERFORM f_get_interval USING ft_out-eindt.
    fc_menge_eket = fc_menge_eket - t_ekbe-menge.
    fc_menge      = t_ekbe-menge.
    fc_qtyinter   = fc_menge.
    t_ekbe-menge  = 0.
    MODIFY t_ekbe TRANSPORTING menge.
    CLEAR: fc_menge.
  ENDIF.
ENDFORM.                    " F_HITUNG_QTYINTER_CANCEL

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_MENGE_0
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delete_menge_0 USING fu_ebeln fu_ebelp
                            fw_out STRUCTURE t_out
                            fw_ekbe STRUCTURE t_ekbe
                      CHANGING fc_tabix fc_tabix1 fc_menge_eket fc_eindt
                               fc_noexit.

  DELETE t_ekbe WHERE ebeln EQ fu_ebeln AND
                      ebelp EQ fu_ebelp AND
                      menge EQ 0.

  READ TABLE t_ekbe INTO fw_ekbe WITH KEY ebeln = fu_ebeln
                                          ebelp = fu_ebelp.
  IF sy-subrc EQ 0.
    fc_tabix   = fc_tabix + 1.
    fc_tabix1  = fc_tabix1 + 1.
    READ TABLE t_out INTO fw_out INDEX fc_tabix1.
    IF fw_out-ebeln EQ fu_ebeln AND
      fw_out-ebelp EQ fu_ebelp.
      fc_menge_eket   = fw_out-menge_eket.
      fc_eindt        = fw_out-eindt.
      fc_noexit       = 1.
    ELSE.
      CLEAR: fc_noexit.
    ENDIF.
  ELSE.
    CLEAR: fc_noexit.
  ENDIF.
ENDFORM.                    " F_DELETE_MENGE_0

*&---------------------------------------------------------------------*
*&      Form  F_DATA_TOP_REC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_data_top_rec USING fu_ebeln fu_ebelp.
  READ TABLE t_eketdat1 WITH KEY ebeln = fu_ebeln
                                 ebelp = fu_ebelp
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    t_out-banfn       = t_eketdat1-banfn.
    t_out-badat       = t_eketdat1-badat.
    t_out-menge_eban  = t_eketdat1-menge_eban.
    t_out-reldt       = t_eketdat1-reldt.
    t_out-lfdat       = t_eketdat1-lfdat.
    MODIFY t_out TRANSPORTING banfn badat menge_eban reldt lfdat.
  ENDIF.
ENDFORM.                    " F_DATA_TOP_REC
