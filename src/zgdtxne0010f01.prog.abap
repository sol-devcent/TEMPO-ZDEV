*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0009F01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
FORM f_initialization.
*$*$ change initial value if needed
*  p_dest = 'LOCL'.
  p_disp = 'X'.

***added for Tempo --- to get Default printer device for the user
  PERFORM f_get_printer_def USING sy-uname
                         CHANGING p_dest.
***end of Tempo addition

ENDFORM.                    " F_INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data.
  d_repid = sy-repid.
  DATA: BEGIN OF lt_setleaf OCCURS 0,
        setname   TYPE setleaf-setname,
        valfrom   TYPE setleaf-valfrom,
        valto     TYPE setleaf-valto,
      END OF lt_setleaf.
  RANGES: lr_setname  FOR setleaf-setname.
  lr_setname-low      = 'GL_ACCOUNT_BKP'.
  lr_setname-sign     = 'I'.
  lr_setname-option   = 'EQ'.
  APPEND lr_setname.
  lr_setname-low      = 'GL_ACCOUNT_JKP'.
  lr_setname-sign     = 'I'.
  lr_setname-option   = 'EQ'.
  APPEND lr_setname.

  IF p_bukrs EQ '8050' OR p_bukrs EQ '8800'.
    SELECT setname valfrom valto
      FROM setleaf
      INTO TABLE lt_setleaf
      WHERE setname IN lr_setname.

    LOOP AT lt_setleaf.
      CASE lt_setleaf-setname.
        WHEN 'GL_ACCOUNT_BKP'.
          ra_bkp-low      = lt_setleaf-valfrom.
          ra_bkp-high     = lt_setleaf-valto.
          ra_bkp-sign     = 'I'.
          ra_bkp-option   = 'BT'.
          APPEND ra_bkp.
        WHEN 'GL_ACCOUNT_JKP'.
          ra_jkp-low      = lt_setleaf-valfrom.
          ra_jkp-high     = lt_setleaf-valto.
          ra_jkp-sign     = 'I'.
          ra_jkp-option   = 'BT'.
          APPEND ra_jkp.
      ENDCASE.
    ENDLOOP.
  ENDIF.

*$*$ don't change below
  CLEAR: d_frm_subrc,sy-subrc.
  REFRESH : t_itab.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data.
  DATA lt_zgdtxdt0012 LIKE t_itab OCCURS 0 WITH HEADER LINE.

  SELECT * FROM zgdtxdt0012
   INTO CORRESPONDING FIELDS OF TABLE lt_zgdtxdt0012
   WHERE bukrs    = p_bukrs AND
         brnch    = p_brnch AND
         gjahr    = p_masatx(4) AND
         masatx   = p_masatx AND
         belnr IN s_belnr AND
         credit = 'R'.

  d_frm_subrc = 1.
  CHECK NOT lt_zgdtxdt0012[] IS INITIAL.
  d_frm_subrc = 0.

  PERFORM f_get_npwp_pkp USING p_brnch.

*  LOOP AT lt_zgdtxdt0012.
** Start of change by sutoyo
**    t_itab-vkorg    = lt_ZGDTXdt0002-vkorg.
**    t_itab-gsber    = lt_ZGDTXdt0002-gsber.
**    t_itab-spart    = lt_ZGDTXdt0002-spart.
*    t_itab-bukrs    = lt_zgdtxdt0012-bukrs.
*    t_itab-brnch    = lt_zgdtxdt0012-brnch.
*    t_itab-busln    = lt_zgdtxdt0012-busln.
** End of change
*    t_itab-gjahr    = lt_zgdtxdt0012-gjahr.
*    t_itab-masatx   = lt_zgdtxdt0012-masatx.
*    t_itab-belnr    = lt_zgdtxdt0012-belnr.
*    t_itab-fakturno = lt_zgdtxdt0012-fakturno.
*    t_itab-fakdat   = lt_zgdtxdt0012-fakdat.
*    t_itab-budat    = lt_zgdtxdt0012-budat.
*    t_itab-item     = lt_zgdtxdt0012-item.
*    t_itab-itqty    = lt_zgdtxdt0012-itqty.
*      t_itab-harga = lt_zgdtxdt0012-itamt /
*                     lt_zgdtxdt0012-itqty.
*    t_itab-itamt = lt_zgdtxdt0012-itamt.
*    t_itab-dpp   = lt_zgdtxdt0012-itamt.
*    t_itab-ppn   = lt_zgdtxdt0012-fakppn.
*    t_itab-ppnbm = lt_zgdtxdt0012-ppnbmlast.
*    t_itab-disc  = lt_zgdtxdt0012-itdisclast.
*
** Start of change by sutoyo
** READ TABLE lt_ZGDTXdt0003 WITH KEY vkorg    = lt_ZGDTXdt0002-vkorg
**                                      gsber    = lt_ZGDTXdt0002-gsber
**                                      spart    = lt_ZGDTXdt0002-spart
*    READ TABLE lt_zgdtxdt0003 WITH KEY bukrs    = lt_zgdtxdt0002-bukrs
*                                       brnch    = lt_zgdtxdt0002-brnch
*                                       busln    = lt_zgdtxdt0002-busln
**End of change
*                                     fakturno = lt_zgdtxdt0002-fakturno
**                                     masatx   = lt_ZGDTXdt0002-masatx
*                                                          BINARY SEARCH
*.
*    IF sy-subrc = 0.
*      t_itab-fakdat = lt_zgdtxdt0003-fakdat.
*      t_itab-name   = lt_zgdtxdt0003-name.
*      t_itab-addrs1 = lt_zgdtxdt0003-addrs1.
*      t_itab-npwp   = lt_zgdtxdt0003-npwp.
*    ENDIF.
*
*    APPEND t_itab.
*    CLEAR t_itab.
*  ENDLOOP.

  LOOP AT lt_zgdtxdt0012.
    MOVE-CORRESPONDING lt_zgdtxdt0012 TO t_itab.
    CLEAR t_itab-harga.
    IF NOT lt_zgdtxdt0012-itqty IS INITIAL.
      t_itab-harga = lt_zgdtxdt0012-itamt /
                     lt_zgdtxdt0012-itqty.
    ENDIF.
    CLEAR t_itab-stenr.
    IF NOT t_itab-lifnr IS INITIAL.
      SELECT SINGLE stenr adrnr INTO (t_itab-stenr, t_itab-adrnr1)
                                FROM lfa1
                                WHERE lifnr = t_itab-lifnr.

      SELECT SINGLE street str_suppl3 location city1
        FROM adrc
        INTO (t_itab-street, t_itab-str_suppl3, t_itab-location, t_itab-city1)
        WHERE addrnumber EQ t_itab-adrnr1.
    ENDIF.
    APPEND t_itab.
  ENDLOOP.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_DATA
*&---------------------------------------------------------------------*
FORM f_write_data.
*Contoh untuk ALV Grid yang Jelas di BALVST02_GRID

  t_alv[] = t_itab[].
  SORT t_alv BY bukrs brnch busln belnr gjahr fakturno masatx.
  DELETE ADJACENT DUPLICATES FROM t_alv COMPARING
****modified by Rahmadi
*                                                  vkorg
*                                                  gsber
*                                                  spart
                                                  bukrs
                                                  brnch
                                                  busln
****end of modification
                                                  belnr
                                                  gjahr
                                                  fakturno
                                                  masatx.

  PERFORM f_fieldcats USING :
    'BELNR'    'ZGDTXDT0012' 'BELNR'    'Nota Retur'      '15',
    'BUDAT'    'ZGDTXDT0012' 'BUDAT'    'NR Date'         '15',
    'NAME'     'ZGDTXDT0012' 'NAME'     'Vendor Name'     '30',
    'FAKTURNO' 'ZGDTXDT0012' 'FAKTURNO' 'No Faktur Pajak' '20'.

  PERFORM f_build_sortfield  USING   t_sort[].
  PERFORM f_eventtab_build   USING t_events[].
  PERFORM f_comment_build    USING t_list_top_of_page[].
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_print      USING   d_print.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*         I_BYPASSING_BUFFER          =
*         I_BUFFER_ACTIVE             =
*         I_INTERFACE_CHECK           = ' '
          i_callback_program          = d_repid
          i_callback_pf_status_set    = 'F_SET_PF_STATUS'
          i_callback_user_command     = 'F_USER_COMMAND'
*         I_CALLBACK_TOP_OF_PAGE      = ' '
*         I_CALLBACK_HTML_TOP_OF_PAGE = ' '
*         I_CALLBACK_HTML_END_OF_LIST = ' '
*         I_STRUCTURE_NAME            = ' '
          i_background_id             = 'ALV_BACKGROUND'
*         I_GRID_TITLE                =
*         I_GRID_SETTINGS             =
          is_layout                   = d_layout
          it_fieldcat                 = t_fieldcat[]
*         IT_EXCLUDING                =
*         IT_SPECIAL_GROUPS           =
          it_sort                     = t_sort[]
*         IT_FILTER                   =
*         IS_SEL_HIDE                 =
          i_default                   = 'X'
          i_save                      = 'A'
          is_variant                  = d_variant
          it_events                   = t_events
*         IT_EVENT_EXIT               =
          is_print                    = d_print
*         IS_REPREP_ID                =
*         I_SCREEN_START_COLUMN       = 0
*         I_SCREEN_START_LINE         = 0
*         I_SCREEN_END_COLUMN         = 0
*         I_SCREEN_END_LINE           = 0
*    IMPORTING
*         E_EXIT_CAUSED_BY_CALLER     =
*         ES_EXIT_CAUSED_BY_USER      =
       TABLES
            t_outtab                    = t_alv[]
      EXCEPTIONS
           program_error               = 1
           OTHERS                      = 2.


ENDFORM.                    " F_WRITE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATS
*&---------------------------------------------------------------------*
FORM f_fieldcats USING fu_fname
                       fu_reftb
                       fu_reffname
                       fu_text
                       fu_len.

  DATA : lt_fieldcat TYPE slis_fieldcat_alv.
  lt_fieldcat-fieldname      = fu_fname.
  lt_fieldcat-ref_tabname    = fu_reftb.
  lt_fieldcat-ref_fieldname  = fu_reffname.
  lt_fieldcat-outputlen      = fu_len.
  lt_fieldcat-seltext_l      = fu_text.
  lt_fieldcat-reptext_ddic   = fu_text.
  lt_fieldcat-ddictxt        = 'L'.
  APPEND lt_fieldcat TO t_fieldcat.
  CLEAR: lt_fieldcat.
ENDFORM.                    " F_FIELDCATS

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout USING p_layout TYPE slis_layout_alv.
  p_layout-f2code            = d_f2code.
*  p_layout-zebra             = 'X'.
  p_layout-group_change_edit = 'X'.
  p_layout-window_titlebar   = ' '.
  p_layout-box_fieldname     ='CEK'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield USING  p_t_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BELNR'.
  ld_sort-up      = 'X'.
  APPEND ld_sort TO p_t_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_EVENTTAB_BUILD
*&---------------------------------------------------------------------*
FORM f_eventtab_build USING ft_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = ft_events.
  READ TABLE ft_events WITH KEY name =  slis_ev_top_of_page
                           INTO ls_event.

  IF sy-subrc = 0.
    MOVE c_formname_top_of_page TO ls_event-form.
    APPEND ls_event TO ft_events.
  ENDIF.
ENDFORM.                    " F_EVENTTAB_BUILD


*&---------------------------------------------------------------------*
*&      Form  F_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM f_comment_build USING  ft_top_of_page TYPE slis_t_listheader.
  DATA: ls_line TYPE slis_listheader.

* Start of change by sutoyo
*  DATA : ld_vtext        LIKE tvkot-vtext,
*         ld_gtext        LIKE tgsbt-gtext,
  DATA : ld_vtext        LIKE t001-butxt,
         ld_gtext        LIKE zgdtxdt0101-bdesc,
         ld_company(100) TYPE c,
         ld_buss(100)    TYPE c.

* Start of change by sutoyo
*  SELECT SINGLE vtext
*   INTO ld_vtext
*   FROM tvkot
*   WHERE vkorg = p_vkorg AND
*         spras = sy-langu.

  SELECT SINGLE butxt
    INTO ld_vtext
    FROM t001
    WHERE bukrs = p_bukrs.

*  CONCATENATE p_vkorg ld_vtext INTO ld_company SEPARATED BY space.
  CONCATENATE p_bukrs ld_vtext INTO ld_company SEPARATED BY space.

*  SELECT SINGLE gtext
*   INTO ld_gtext
*   FROM tgsbt
*   WHERE gsber = p_gsber AND
*         spras = sy-langu.
  SELECT SINGLE bdesc
   INTO ld_gtext
   FROM zgdtxdt0101
   WHERE brnch = p_brnch.

*  CONCATENATE p_gsber ld_gtext INTO ld_buss SEPARATED BY space.
  CONCATENATE p_brnch ld_gtext INTO ld_buss SEPARATED BY space.
* End of change by sutoyo

  CLEAR ls_line.
  ls_line-typ  = 'H'.
* LS_LINE-KEY:  not used for this type
  ls_line-info = 'CETAK NOTA RETUR - PPN'.
  APPEND ls_line TO ft_top_of_page.
* Kopfinfo: Typ S
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Company Code'.
  ls_line-info = ld_company.
  APPEND ls_line TO ft_top_of_page.
  ls_line-key  = 'Branch'.
  ls_line-info = ld_buss.
  APPEND ls_line TO ft_top_of_page.
  ls_line-key  = 'Tax period'.
  ls_line-info = p_masatx.
  APPEND ls_line TO ft_top_of_page.

ENDFORM.                    " F_COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM f_top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
*           i_logo             = 'HTMLCNTL_TESTHTM2_SAPLOGO'
*            i_logo             = 'ENJOYSAP_LOGO'
            it_list_commentary = t_list_top_of_page.

ENDFORM.                    " F_TOP_OF_PAGE


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT
*&---------------------------------------------------------------------*
FORM f_build_print USING p_print TYPE slis_print_alv.
  d_print-no_print_listinfos = 'X'.
ENDFORM.                    " F_BUILD_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_SET_PF_STATUS
*&---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.
ENDFORM.                    " F_SET_PF_STATUS


*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  sy-lsind = 0.
  CASE fu_ucomm.
    WHEN 'TAMPIL'.
      p_disp = 'X'.
      PERFORM f_tampil.
    WHEN 'CETAK'.
      p_disp = ' '.
      PERFORM f_tampil.
  ENDCASE.

ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_TAMPIL
*&---------------------------------------------------------------------*
FORM f_tampil.
  DATA:   lt_bseg     LIKE t_bseg OCCURS 0 WITH HEADER LINE.

  REFRESH : t_display, t_bseg.

***added by Rahmadi
  d_lyt_tddst = p_dest.
***end of addition

*kembalikan semua ke uncheck
  t_itab-cek = ''.
  MODIFY t_itab TRANSPORTING cek WHERE cek EQ 'X'.

  IF p_bukrs EQ '8050' OR
    p_bukrs EQ '8800' OR
    p_bukrs EQ '8220' OR
    p_bukrs EQ '8180' OR
    p_bukrs EQ '8210' OR
    p_bukrs EQ '8040'.
    IF t_alv[] IS NOT INITIAL.
      SELECT bukrs belnr gjahr buzei buzid shkzg mwskz wrbtr hkont sgtxt menge meins dmbtr matnr
        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE t_bseg
        FOR ALL ENTRIES IN t_alv
        WHERE bukrs EQ t_alv-bukrs AND
              belnr EQ t_alv-belnr AND
              gjahr EQ t_alv-gjahr.

      IF p_bukrs EQ '8220' OR
        p_bukrs EQ '8180' OR
        p_bukrs EQ '8210' OR
        p_bukrs EQ '8040'.
        lt_bseg[] = t_bseg[].
        SORT lt_bseg BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING matnr .
        IF lt_bseg[] IS NOT INITIAL.
          SELECT matnr maktx INTO TABLE t_makt
              FROM makt
               FOR ALL ENTRIES IN lt_bseg
            WHERE matnr = lt_bseg-matnr AND
                  spras = sy-langu.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT t_alv WHERE cek = 'X'.
    t_itab-cek = 'X'.
    MODIFY t_itab TRANSPORTING cek WHERE
****modified by Rahmadi
*                                         vkorg = t_alv-vkorg AND
*                                         gsber = t_alv-gsber AND
*                                         spart = t_alv-spart AND
                                         bukrs = t_alv-bukrs AND
                                         brnch = t_alv-brnch AND
                                         busln = t_alv-busln AND
****end of modification
                                         belnr = t_alv-belnr AND
                                         gjahr = t_alv-gjahr AND
                                         fakturno = t_alv-fakturno AND
                                         masatx   = t_alv-masatx.
  ENDLOOP.

*Costanta Max Row
  d_firstone_main = 18.
  d_firsttwo_main = 18.

  IF p_bukrs EQ '8050' OR p_bukrs EQ '8800'.
* Special case for 8050
    PERFORM f_tampil1.
*** Add by sukardi req by Andre -- Project DG2
*** Proses menambahkan item data yg diambil dari BSEG dengan buzid = 'W'.
  ELSEIF p_bukrs = '8220' OR
    p_bukrs = '8180' OR
    p_bukrs = '8040'.
    PERFORM f_tampil3.
*** end add
  ELSEIF p_bukrs EQ '8210'.
    PERFORM f_tampil4.
  ELSE.
    PERFORM f_tampil2.
  ENDIF.
ENDFORM.                    " F_TAMPIL

*&---------------------------------------------------------------------*
*&      Form  F_CETAK
*&---------------------------------------------------------------------*
FORM f_cetak.
  DATA : ld_qty      TYPE i,
         ld_dpp      LIKE zgdtxdt0002-dpplast,
         ld_ppn      LIKE zgdtxdt0002-ppnlast,
         ld_ppnbm    LIKE zgdtxdt0002-ppnbmlast,
         ld_disc     LIKE zgdtxdt0002-itdisclast,
         ld_dtretur  LIKE zgdtxdt0002-dtretur,
         ld_fakdat   LIKE zgdtxdt0003-fakdat,
         ld_bulan(2)   TYPE c,
         ld_tanggal(2) TYPE c,
         ld_tahun(4)   TYPE c,
         ld_harga      TYPE zgdtxdt0012-itamt.


  CLEAR : ld_qty, d_itqtyc, d_totline, d_ppnc, d_hal,
          d_ppnbmc, d_no, ld_ppn, ld_ppnbm, ld_disc, d_hal, d_suffix,
          d_discc, d_tanggal, ld_bulan, ld_tanggal, ld_tahun, ld_dpp,
          d_dppc.


  PERFORM f_check_pages.

  CASE d_pages.
    WHEN 1.
      CLEAR : ld_bulan, ld_tanggal, ld_tahun.
      PERFORM f_lyt_start_form USING 'FIRSTONE'.
      d_suffix = 'X'.
      PERFORM f_cetak_atas.

      LOOP AT t_display.
        CLEAR : d_satuanc, d_itamtc.

        ld_qty = t_display-itqty.
        ADD 1 TO d_totline.
        ADD 1 TO d_no.
        ADD t_display-fakppn   TO ld_ppn.
        ADD t_display-ppnbm    TO ld_ppnbm.
        ADD t_display-itamt    TO ld_dpp.
        WRITE ld_qty TO d_itqtyc.
        SHIFT d_itqtyc LEFT DELETING LEADING space.
        d_meins = t_display-meins.
****modified for Tempo -- show negative as positive
****don't show for ZERO
        PERFORM f_change_value USING t_display-itamt '' '' ''
                               CHANGING d_itamtc.
        IF t_display-bukrs EQ '8050' OR t_display-bukrs EQ '8800' OR
          t_display-bukrs EQ '8220' OR t_display-bukrs EQ '8180' OR
          t_display-bukrs EQ '8210'.
          ld_harga  = t_display-itamt / ld_qty.
          PERFORM f_change_value USING ld_harga '' '' ''
                                 CHANGING d_satuanc.
        ELSE.
          PERFORM f_change_value USING t_display-harga '' '' ''
                                 CHANGING d_satuanc.
        ENDIF.
*        WRITE t_display-harga TO d_satuanc CURRENCY 'IDR'.
*        WRITE t_display-itamt TO d_itamtc  CURRENCY 'IDR'.
****end of Tempo modification
        ld_fakdat = t_display-fakdat.
        ld_dtretur = t_display-budat.
        PERFORM f_lyt_write_form USING 'WRITE' 'MAIN'.
      ENDLOOP.

      IF NOT ld_fakdat IS INITIAL.
        ld_bulan   = ld_fakdat+4(2).
        ld_tanggal = ld_fakdat+6(2).
        ld_tahun   = ld_fakdat+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_fakdat.
        CONCATENATE ld_tanggal d_fakdat ld_tahun INTO d_fakdat
                   SEPARATED BY space.
      ENDIF.

      IF NOT ld_dtretur IS INITIAL.
        ld_bulan   = ld_dtretur+4(2).
        ld_tanggal = ld_dtretur+6(2).
        ld_tahun   = ld_dtretur+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_tanggal.
        CONCATENATE ld_tanggal d_tanggal ld_tahun INTO d_tanggal
                     SEPARATED BY space.
      ENDIF.

****modified for Tempo -- show negative as positive
****don't show for ZERO
      PERFORM f_change_value USING ld_dpp '' '' ''
                             CHANGING d_dppc.
      PERFORM f_change_value USING ld_ppn '' '' ''
                             CHANGING d_ppnc.
      PERFORM f_change_value USING ld_ppnbm '' '' ''
                             CHANGING d_ppnbmc.

*      WRITE ld_dpp   TO d_dppc   CURRENCY 'IDR'.
*      WRITE ld_ppn   TO d_ppnc   CURRENCY 'IDR'.
*      WRITE ld_ppnbm TO d_ppnbmc CURRENCY 'IDR'.
****end of Tempo modification

      PERFORM f_lyt_write_form USING 'WRITE' 'WINDOW03'.

      PERFORM f_lyt_end_form.

    WHEN OTHERS.
      d_suffix = 'Y'.  "For Flag In Form - NO Hal
      PERFORM f_more_pages.
  ENDCASE.
ENDFORM.                    " F_CETAK

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PAGES
*&---------------------------------------------------------------------*
FORM f_check_pages.
  DATA : ld_temp TYPE i,
         ld_apage TYPE i,
         ld_bpage TYPE f.

  d_atab = 0.
  DESCRIBE TABLE t_display LINES d_atab.
  ld_temp = d_firstone_main + d_firsttwo_main.
  IF d_atab <= ld_temp.
    d_pages = 2.
  ELSE.
    ld_apage = d_atab - ld_temp.
    ld_bpage = ld_apage / d_firsttwo_main.
    d_pages = CEIL( ld_bpage ).
    ADD 2 TO d_pages.
  ENDIF.

  IF d_atab <= d_firstone_main.
    d_pages = 1.
  ENDIF.

ENDFORM.                    " F_CHECK_PAGES


*&---------------------------------------------------------------------*
*&      Form  F_MORE_PAGES
*&---------------------------------------------------------------------*
FORM f_more_pages.
  DATA : ld_qty   TYPE i,
         ld_dpp   LIKE zgdtxdt0002-dpplast,
         ld_ppn   LIKE zgdtxdt0002-ppnlast,
         ld_ppnbm LIKE zgdtxdt0002-ppnbmlast,
         ld_disc LIKE zgdtxdt0002-itdisclast,
         ld_dtretur  LIKE zgdtxdt0002-dtretur,
         ld_awal  TYPE i,
         ld_akhir TYPE i,
         ld_fakdat   LIKE zgdtxdt0003-fakdat,
         ld_bulan(2)   TYPE c,
         ld_tanggal(2) TYPE c,
         ld_tahun(4)   TYPE c,
         ld_harga      TYPE zgdtxdt0012-itamt.

  ld_awal = 1.
  ld_akhir = d_firsttwo_main.

  DO d_pages TIMES.
    CLEAR : d_totline, ld_ppn, ld_ppnbm, ld_disc, ld_dpp.

    PERFORM f_lyt_start_form USING 'FIRSTONE'.
    ADD 1 TO d_hal.
    PERFORM f_cetak_atas.

    LOOP AT t_display FROM ld_awal TO ld_akhir.
      CLEAR : d_satuanc, d_itamtc.

      ld_qty = t_display-itqty.
      ADD 1 TO d_totline.
      ADD 1 TO d_no.
      ADD t_display-fakppn   TO ld_ppn.
      ADD t_display-itamt    TO ld_dpp.
      ADD t_display-ppnbm    TO ld_ppnbm.
      WRITE ld_qty TO d_itqtyc.
      SHIFT d_itqtyc LEFT DELETING LEADING space.
      d_meins = t_display-meins.
****modified for Tempo -- show negative as positive
****don't show for ZERO
      PERFORM f_change_value USING t_display-itamt '' '' ''
                             CHANGING d_itamtc.
      IF t_display-bukrs EQ '8050' OR t_display-bukrs EQ '8800'.
        ld_harga  = t_display-itamt / ld_qty.
        PERFORM f_change_value USING ld_harga '' '' ''
                               CHANGING d_satuanc.
      ELSE.
        PERFORM f_change_value USING t_display-harga '' '' ''
                               CHANGING d_satuanc.
      ENDIF.
*      WRITE t_display-harga TO d_satuanc CURRENCY 'IDR'.
*      WRITE t_display-itamt TO d_itamtc  CURRENCY 'IDR'.
****end of Tempo modification
      ld_fakdat = t_display-fakdat.
      ld_dtretur = t_display-budat.
      PERFORM f_lyt_write_form USING 'WRITE' 'MAIN'.
    ENDLOOP.

    IF NOT ld_fakdat IS INITIAL.
      ld_bulan   = ld_fakdat+4(2).
      ld_tanggal = ld_fakdat+6(2).
      ld_tahun   = ld_fakdat+0(4).
      PERFORM f_bulan USING ld_bulan
                      CHANGING d_fakdat.
      CONCATENATE ld_tanggal d_fakdat ld_tahun INTO d_fakdat
                 SEPARATED BY space.
    ENDIF.

    IF NOT ld_dtretur IS INITIAL.
      ld_bulan   = ld_dtretur+4(2).
      ld_tanggal = ld_dtretur+6(2).
      ld_tahun   = ld_dtretur+0(4).
      PERFORM f_bulan USING ld_bulan
                      CHANGING d_tanggal.
      CONCATENATE ld_tanggal d_tanggal ld_tahun INTO d_tanggal
                   SEPARATED BY space.
    ENDIF.

****modified for Tempo -- show negative as positive
****don't show for ZERO
    PERFORM f_change_value USING ld_dpp '' '' ''
                           CHANGING d_dppc.
    PERFORM f_change_value USING ld_ppn '' '' ''
                           CHANGING d_ppnc.
    PERFORM f_change_value USING ld_ppnbm '' '' ''
                           CHANGING d_ppnbmc.
    PERFORM f_change_value USING ld_disc '' '' ''
                           CHANGING d_discc.

*    WRITE ld_dpp   TO d_dppc   CURRENCY 'IDR'.
*    WRITE ld_ppn   TO d_ppnc   CURRENCY 'IDR'.
*    WRITE ld_ppnbm TO d_ppnbmc CURRENCY 'IDR'.
*    WRITE ld_disc  TO d_discc  CURRENCY 'IDR'.
****end of Tempo modification

    PERFORM f_lyt_write_form USING 'WRITE' 'WINDOW03'.

    PERFORM f_lyt_end_form.

    ld_awal = ld_akhir + 1.
    ld_akhir = ld_akhir + d_firsttwo_main.
    IF ld_akhir > d_atab.
      ld_akhir = d_atab.
    ENDIF.
  ENDDO.

ENDFORM.                    " F_MORE_PAGES

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_ATAS
*&---------------------------------------------------------------------*
FORM f_cetak_atas.
  PERFORM f_lyt_write_form USING 'WRITE' 'WINDOW01'.
  PERFORM f_lyt_write_form USING 'WRITE' 'WINDOW02'.
ENDFORM.                    " F_CETAK_ATAS

*&---------------------------------------------------------------------*
*&      Form  F_BULAN
*&---------------------------------------------------------------------*
FORM f_bulan USING    fu_bulan
             CHANGING fc_tanggal.
  CASE fu_bulan.
    WHEN '01'.
      fc_tanggal = 'Januari'.
    WHEN '02'.
      fc_tanggal = 'Februari'.
    WHEN '03'.
      fc_tanggal = 'Maret'.
    WHEN '04'.
      fc_tanggal = 'April'.
    WHEN '05'.
      fc_tanggal = 'Mei'.
    WHEN '06'.
      fc_tanggal = 'Juni'.
    WHEN '07'.
      fc_tanggal = 'Juli'.
    WHEN '08'.
      fc_tanggal = 'Agustus'.
    WHEN '09'.
      fc_tanggal = 'September'.
    WHEN '10'.
      fc_tanggal = 'Oktober'.
    WHEN '11'.
      fc_tanggal = 'November'.
    WHEN '12'.
      fc_tanggal = 'Desember'.
  ENDCASE.
ENDFORM.                    " F_BULAN

*&---------------------------------------------------------------------*
*&      Form  F_GET_NPWP_PKP
*&---------------------------------------------------------------------*
FORM f_get_npwp_pkp USING fu_brnch. "fu_gsber.

***removed by Rahmadi
*  PERFORM f_get_signoff(ZABP_SMARTFORM)

** Start of change by sutoyo
**                            USING 'ZPYGLST_TYT_' p_gsber:
*                            USING 'ZPYGLST_TYT_' fu_gsber:
** End of change
*                                  'NPWP' d_npwp,
*                                  'AlmtNPWP' d_alamat.
***end of removal

***added by Rahmadi
  CLEAR: d_ho_brnch, t_pkp.
  REFRESH t_pkp.
  SELECT
         masafrom pkpnpwp pkpkuh pkpname pkpaddrs1 pkpaddrs2 pkpcity
         INTO TABLE t_pkp
         FROM zgdtxdt0005
         WHERE bukrs = p_bukrs AND
               brnch = p_brnch AND
               masafrom <= p_masatx.
  IF sy-subrc = 0.
    SORT t_pkp BY masafrom DESCENDING.
    READ TABLE t_pkp INDEX 1.
    d_npwp = t_pkp-pkpnpwp.
    d_kuh = t_pkp-pkpkuh.
    d_name = t_pkp-pkpname.
    d_alamat = t_pkp-pkpaddrs1.
    d_alamat2 = t_pkp-pkpaddrs2.
    d_city = t_pkp-pkpcity.
**** Tambahan untuk cetak smartform
    gv_header-pkpnpwp = t_pkp-pkpnpwp.
    gv_header-pkpnppkp = t_pkp-pkpkuh.
    gv_header-pkpname = t_pkp-pkpname.
    gv_header-pkpaddrs1 = t_pkp-pkpaddrs1.
    gv_header-pkpaddrs2 = t_pkp-pkpaddrs2.
    gv_header-pkpcity  = t_pkp-pkpcity.
*    gv_header-PKPPOSTAL
*    gv_header-PKPTELP
*    gv_header-PJKUNNR
*    gv_header-PJNPWP
*    gv_header-PJNPPKP
*    gv_header-PJNAME
**** End
  ELSE.
    SELECT SINGLE brnch INTO d_ho_brnch
                        FROM zgdtxdt0101
                        WHERE bukrs = p_bukrs AND
                              ho_ind = 'X'.
    IF sy-subrc <> 0.
      MESSAGE i000(ztx)
              WITH 'Head office is not assigned for company code'
                   p_bukrs.
      STOP.
    ENDIF.

    SELECT
           masafrom pkpnpwp pkpkuh pkpname pkpaddrs1 pkpaddrs2 pkpcity
           INTO TABLE t_pkp
           FROM zgdtxdt0005
           WHERE bukrs = p_bukrs AND
                 brnch = d_ho_brnch AND
                 masafrom <= p_masatx.
    IF sy-subrc = 0.
      SORT t_pkp BY masafrom DESCENDING.
      READ TABLE t_pkp INDEX 1.
      d_npwp = t_pkp-pkpnpwp.
      d_kuh = t_pkp-pkpkuh.
      d_name = t_pkp-pkpname.
      d_alamat = t_pkp-pkpaddrs1.
      d_alamat2 = t_pkp-pkpaddrs2.
      d_city = t_pkp-pkpcity.
**** Tambahan untuk cetak smartform
      gv_header-pkpnpwp = t_pkp-pkpnpwp.
      gv_header-pkpnppkp = t_pkp-pkpkuh.
      gv_header-pkpname = t_pkp-pkpname.
      gv_header-pkpaddrs1 = t_pkp-pkpaddrs1.
      gv_header-pkpaddrs2 = t_pkp-pkpaddrs2.
      gv_header-pkpcity  = t_pkp-pkpcity.
**** End
    ELSE.
      MESSAGE i000(zab) WITH 'PKP data is not available for branch'
                             p_brnch.
      STOP.
    ENDIF.
  ENDIF.
***end of addition

ENDFORM.                    " F_GET_NPWP_PKP

*&---------------------------------------------------------------------*
*&      Form  f_change_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_HARGA  text
*      <--FC_HARGA  text
*----------------------------------------------------------------------*
FORM f_change_value USING    fu_harga fu_qty fu_total fu_decim
                    CHANGING fc_harga.

  DATA : ld_harga   LIKE t_display-harga,
         lv_harga   TYPE p DECIMALS 4.

  lv_harga = ( fu_total * 100 ) / fu_qty.

  IF fu_harga < 0.
    ld_harga = ( -1 ) * fu_harga.
    IF fu_decim IS INITIAL.
      WRITE ld_harga TO fc_harga CURRENCY 'IDR'.
    ELSE.
      lv_harga = lv_harga * -1.
      WRITE lv_harga TO fc_harga DECIMALS fu_decim.
    ENDIF.
  ELSEIF fu_harga = 0.
    CLEAR fc_harga.
  ELSE.
    ld_harga = fu_harga.
    IF fu_decim IS INITIAL.
      WRITE ld_harga TO fc_harga CURRENCY 'IDR'.
    ELSE.
      WRITE lv_harga TO fc_harga DECIMALS fu_decim.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_change_value

*&---------------------------------------------------------------------*
*&      Form  f_get_printer_def
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_printer_def USING fu_uname
                       CHANGING fc_print.

  CLEAR fc_print.
  SELECT SINGLE spld INTO fc_print
                     FROM usr01
                     WHERE bname = fu_uname.

ENDFORM.                    " f_get_printer_def

*&---------------------------------------------------------------------*
*&      Form  F_TAMPIL1
*&---------------------------------------------------------------------*
FORM f_tampil1 .
  DATA: ld_type(3),
        ld_wrbtr  TYPE bseg-wrbtr,
        ld_fakppn TYPE bseg-wrbtr,
        ld_itamt  TYPE bseg-wrbtr,
        ld_tdname TYPE stxh-tdname.
  DATA: BEGIN OF lt_itab OCCURS 0.
          INCLUDE STRUCTURE t_itab.
  DATA:   type(3),
          hkontbelnr(20),
        END OF lt_itab.

  SORT t_itab STABLE BY belnr fakturno.
  LOOP AT t_itab WHERE cek = 'X'.
    LOOP AT t_bseg WHERE bukrs EQ t_itab-bukrs AND
                         belnr EQ t_itab-belnr AND
                         gjahr EQ t_itab-gjahr.
      IF t_bseg-shkzg EQ 'H'.
        ld_wrbtr  = t_bseg-wrbtr * -1.
      ELSE.
        ld_wrbtr  = t_bseg-wrbtr.
      ENDIF.

      CASE t_bseg-mwskz.
        WHEN 'B5'.
          PERFORM f_tax_calc USING '' p_masatx ld_wrbtr 'H'
                             CHANGING ld_fakppn.
          PERFORM f_tax_calc USING '' p_masatx ld_wrbtr 'I'
                             CHANGING ld_itamt.
*          ld_fakppn   = ld_wrbtr * ( 10 / 110 ).
*          ld_itamt    = ld_wrbtr * ( 100 / 110 ).
        WHEN 'B6'.
          ld_fakppn   = ld_wrbtr * ( 1 / 101 ).
          ld_itamt    = ld_wrbtr * ( 100 / 101 ).
        WHEN OTHERS.
          PERFORM f_tax_calc USING '' p_masatx ld_wrbtr 'H'
                             CHANGING ld_fakppn.
          PERFORM f_tax_calc USING '' p_masatx ld_wrbtr 'I'
                             CHANGING ld_itamt.
*          ld_fakppn   = ld_wrbtr * ( 10 / 110 ).
*          ld_itamt    = ld_wrbtr * ( 100 / 110 ).
      ENDCASE.
      IF t_bseg-hkont IN ra_bkp.
        lt_itab = t_itab.
        lt_itab-hkont   = t_bseg-hkont.
        lt_itab-fakppn  = ld_fakppn.
        lt_itab-itamt   = ld_itamt.
        lt_itab-type    = 'BKP'.
        CONCATENATE t_bseg-bukrs t_bseg-belnr t_bseg-gjahr t_bseg-buzei INTO ld_tdname.
        PERFORM f_read_text USING ld_tdname
                            CHANGING lt_itab-item.
        CONCATENATE t_bseg-hkont t_bseg-belnr INTO lt_itab-hkontbelnr.
        APPEND lt_itab.
      ENDIF.
      IF t_bseg-hkont IN ra_jkp.
        lt_itab = t_itab.
        lt_itab-hkont   = t_bseg-hkont.
        lt_itab-fakppn  = ld_fakppn.
        lt_itab-itamt   = ld_itamt.
        lt_itab-type    = 'JKP'.
        CONCATENATE t_bseg-bukrs t_bseg-belnr t_bseg-gjahr t_bseg-buzei INTO ld_tdname.
        PERFORM f_read_text USING ld_tdname
                            CHANGING lt_itab-item.
        CONCATENATE t_bseg-hkont t_bseg-belnr INTO lt_itab-hkontbelnr.
        APPEND lt_itab.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT lt_itab BY hkontbelnr fakturno.
  LOOP AT lt_itab WHERE cek = 'X'.
    t_display = lt_itab.
    CONCATENATE lt_itab-fakturno(3) '.' lt_itab-fakturno+3(3) '-'
                lt_itab-fakturno+6(2) '.' lt_itab-fakturno+8(8)
    INTO t_display-fakturnot.
    APPEND t_display.
    CLEAR t_display.

    ld_type = lt_itab-type.

    AT END OF hkontbelnr.
      CASE ld_type.
        WHEN 'BKP'.
          p_tdform  = 'ZDGTXF0004_01BKP'.
        WHEN 'JKP'.
          p_tdform  = 'ZDGTXF0004_01JKP'.
      ENDCASE.
      PERFORM f_lyt_open_form USING p_tdform p_disp p_disp.
      PERFORM f_cetak.
      PERFORM f_lyt_close_form.
      REFRESH t_display.
    ENDAT.
  ENDLOOP.
ENDFORM.                                                    " F_TAMPIL1

*&---------------------------------------------------------------------*
*&      Form  F_TAMPIL2
*&---------------------------------------------------------------------*
FORM f_tampil2.

  SORT t_itab STABLE BY belnr fakturno.
  LOOP AT t_itab WHERE cek = 'X'.
    t_display = t_itab.
* DG2
    IF p_bukrs EQ '8230'.
      CONCATENATE t_itab-fakturno(3) '.' t_itab-fakturno+3(3) '-'
                  t_itab-fakturno+6(2) '.' t_itab-fakturno+8(8)
      INTO t_display-fakturnot.
    ENDIF.
    APPEND t_display.
    CLEAR t_display.

    AT END OF belnr.
      PERFORM f_lyt_open_form USING p_tdform p_disp p_disp.
      PERFORM f_cetak.
      PERFORM f_lyt_close_form.
      REFRESH t_display.
    ENDAT.
  ENDLOOP.
ENDFORM.                                                    " F_TAMPIL2

*&---------------------------------------------------------------------*
*&      Form  F_TAMPIL3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tampil3 .
  DATA: ld_type(3),
        ld_wrbtr    TYPE bseg-wrbtr,
        ld_fakppn   TYPE bseg-wrbtr,
        ld_dec4     TYPE p DECIMALS 4,
        ld_itamt    TYPE bseg-wrbtr,
        ld_dpp      LIKE zgdtxdt0002-dpplast,
        ld_ppn      LIKE zgdtxdt0002-ppnlast,
        ld_ppnbm    LIKE zgdtxdt0002-ppnbmlast,
        ld_dtretur  LIKE zgdtxdt0002-dtretur,
        ld_fakdat   LIKE zgdtxdt0003-fakdat,
        ld_bulan(2)   TYPE c,
        ld_tanggal(2) TYPE c,
        ld_tahun(4)   TYPE c,
        ld_harga      TYPE zgdtxdt0012-itamt,
        ld_tdname TYPE stxh-tdname,
        ld_sign,
        lv_decim      TYPE i.

  DATA: BEGIN OF lt_itab OCCURS 0.
          INCLUDE STRUCTURE t_itab.

  DATA:                                                     " type(3),
          fakppnh LIKE t_itab-fakppn,
          "hkontbelnr(20),
        END OF lt_itab.

  p_smartform = 'ZDG2FIF002'.
  nast-dimme = p_disp.
  DELETE t_bseg WHERE buzid NE 'W'.
  SORT t_itab STABLE BY belnr fakturno.
  LOOP AT t_itab WHERE cek = 'X'.
    LOOP AT t_bseg WHERE bukrs EQ t_itab-bukrs AND
                         belnr EQ t_itab-belnr AND
                         gjahr EQ t_itab-gjahr.
      IF t_bseg-shkzg EQ 'H'.
        ld_wrbtr  = t_bseg-dmbtr * -1.
      ELSE.
        ld_wrbtr  = t_bseg-dmbtr.
      ENDIF.

*      ld_fakppn   = ld_wrbtr / 10. "* ( 10 / 110 ).

      IF ld_wrbtr < 0.
        ld_sign = '+'.
      ELSE.
        ld_sign = '-'.
      ENDIF.

      ld_dec4     = ld_wrbtr / 10.
      CALL FUNCTION 'ROUND'
        EXPORTING
          decimals      = 2
          input         = ld_dec4
          sign          = ld_sign
        IMPORTING
          output        = ld_fakppn
        EXCEPTIONS
          input_invalid = 1
          overflow      = 2
          type_invalid  = 3
          OTHERS        = 4.

      ld_itamt    = ld_wrbtr. " * ( 100 / 110 ).
      lt_itab = t_itab.
      lt_itab-hkont   = t_bseg-hkont.
      lt_itab-fakppn  = ld_fakppn.
      lt_itab-itamt   = ld_itamt.
      lt_itab-meins   = t_bseg-meins.
      lt_itab-itqty   = t_bseg-menge.
      lt_itab-harga   = ld_wrbtr / t_bseg-menge.
      lt_itab-fakppnh = t_itab-fakppn.
      CONCATENATE t_bseg-bukrs t_bseg-belnr t_bseg-gjahr t_bseg-buzei INTO ld_tdname.
      PERFORM f_read_text USING ld_tdname
                          CHANGING lt_itab-item.
      IF lt_itab-item IS INITIAL.
        SORT t_makt BY matnr.
        READ TABLE t_makt WITH KEY matnr = t_bseg-matnr.
        IF sy-subrc EQ 0.
          lt_itab-item = t_makt-maktx.
        ELSE.
          lt_itab-item = 'Tidak ada'.
        ENDIF.
      ENDIF.
*      CONCATENATE t_bseg-hkont t_bseg-belnr INTO lt_itab-hkontbelnr.
      APPEND lt_itab.
    ENDLOOP.
  ENDLOOP.

  SORT lt_itab BY belnr fakturno.
  CLEAR: d_no.
  LOOP AT lt_itab WHERE cek = 'X'.
    t_display = lt_itab.
*    break bcdik.
    CONCATENATE lt_itab-fakturno(3) '.' lt_itab-fakturno+3(3) '-'
                lt_itab-fakturno+6(2) '.' lt_itab-fakturno+8(8)
    INTO t_display-fakturnot.
    gv_header-fakturnot = t_display-fakturnot.
    WRITE lt_itab-fakdat TO gv_header-fakturdate.
    gv_header-belnr     = lt_itab-belnr.

    gv_header-pjname    = lt_itab-name.

    IF p_bukrs = 8220.
      CONCATENATE t_itab-street t_itab-str_suppl3 t_itab-location t_itab-city1
        INTO gv_header-pjaddrs1 SEPARATED BY space.
    ELSE.
      gv_header-pjaddrs1 = lt_itab-street.
    ENDIF.

    gv_header-pjnpwp     = lt_itab-npwp.
    ADD 1 TO d_no.
    gt_detail-nourut    = d_no.
    gt_detail-itemtext  = lt_itab-item.
    gt_detail-itqty   = lt_itab-itqty.
    WRITE lt_itab-itqty TO gt_detail-itqty UNIT lt_itab-meins.
*    ld_harga = lt_itab-itamt / lt_itab-itqty.

    IF lt_itab-bukrs = '8040'.
      lv_decim  = 2.
    ELSE.
      CLEAR lv_decim.
    ENDIF.

    PERFORM f_change_value USING lt_itab-harga lt_itab-itqty
                                 lt_itab-itamt lv_decim "ld_harga
                       CHANGING gt_detail-itamt.
    PERFORM f_change_value USING lt_itab-itamt '' '' '' "
                       CHANGING gt_detail-harga.

    APPEND gt_detail.
    ADD lt_itab-fakppn   TO ld_ppn.
    ADD lt_itab-ppnbm    TO ld_ppnbm.
    ADD lt_itab-itamt    TO ld_dpp.
    ld_fakdat = lt_itab-fakdat.
    ld_dtretur = lt_itab-budat.
    ld_ppn = lt_itab-fakppnh.
    AT END OF belnr.
      PERFORM f_change_value USING ld_dpp '' '' ''
                         CHANGING gv_header-hargapkp.
      PERFORM f_change_value USING ld_dpp '' '' ''
                         CHANGING gv_header-hargadpp.
      PERFORM f_change_value USING ld_ppn '' '' ''
                         CHANGING gv_header-pajaktambah.
      ld_harga = 0.
      PERFORM f_change_value USING ld_harga '' '' '' "ld_harga
                         CHANGING gv_header-discount.

      gv_header-cityttd = gv_header-pkpcity.
*       if gv_header-CITYTTD is INITIAL.
      IF p_bukrs EQ '8040'.
        gv_header-cityttd = 'Bekasi'.
      ELSE.
        gv_header-cityttd = 'Jakarta'.
      ENDIF.
*       endif.
      gv_header-namattd = p_sign.
      IF NOT ld_fakdat IS INITIAL.
        ld_bulan   = ld_fakdat+4(2).
        ld_tanggal = ld_fakdat+6(2).
        ld_tahun   = ld_fakdat+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_fakdat.
        CONCATENATE ld_tanggal d_fakdat ld_tahun INTO gv_header-datettd
                   SEPARATED BY space.
      ENDIF.

      IF NOT ld_dtretur IS INITIAL.
        ld_bulan   = ld_dtretur+4(2).
        ld_tanggal = ld_dtretur+6(2).
        ld_tahun   = ld_dtretur+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_tanggal.
        CONCATENATE ld_tanggal d_tanggal ld_tahun INTO gv_header-datettd
                     SEPARATED BY space.
      ENDIF.
      IF gv_header-datettd IS INITIAL.
        ld_bulan   = sy-datum+4(2).
        ld_tanggal = sy-datum+6(2).
        ld_tahun   = sy-datum+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_tanggal.
        CONCATENATE ld_tanggal d_tanggal ld_tahun INTO gv_header-datettd
                     SEPARATED BY space.
      ENDIF.
      PERFORM f_print_form.
      REFRESH gt_detail.
      CLEAR: d_no, ld_dpp, ld_ppn.
    ENDAT.
  ENDLOOP.

ENDFORM.                                                    " F_TAMPIL3




*&---------------------------------------------------------------------*
*&      Form  F_TAMPIL4  "Khusus buat Pulau Mahoni
*&---------------------------------------------------------------------*
*       "Request by Abun - 26 Sept 2018
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tampil4 .
  DATA: ld_type(3),
        ld_wrbtr    TYPE bseg-wrbtr,
        ld_fakppn   TYPE bseg-wrbtr,
        ld_dec4     TYPE p DECIMALS 4,
        ld_itamt    TYPE bseg-wrbtr,
        ld_dpp      LIKE zgdtxdt0002-dpplast,
        ld_ppn      LIKE zgdtxdt0002-ppnlast,
        ld_ppnbm    LIKE zgdtxdt0002-ppnbmlast,
        ld_dtretur  LIKE zgdtxdt0002-dtretur,
        ld_fakdat   LIKE zgdtxdt0003-fakdat,
        ld_bulan(2)   TYPE c,
        ld_tanggal(2) TYPE c,
        ld_tahun(4)   TYPE c,
        ld_harga      TYPE zgdtxdt0012-itamt,
        ld_tdname TYPE stxh-tdname,
        ld_sign.

  DATA: BEGIN OF lt_itab OCCURS 0.
          INCLUDE STRUCTURE t_itab.

  DATA:                                                     " type(3),
          fakppnh LIKE t_itab-fakppn,
          "hkontbelnr(20),
        END OF lt_itab.
  DATA: lwa_itab LIKE lt_itab.

  p_smartform = 'ZDG2FIF002'.
  nast-dimme = p_disp.
  DELETE t_bseg WHERE buzid NE 'W' AND buzid NE 'M' AND buzid NE 'P'.
  SORT t_itab STABLE BY belnr fakturno.
  SORT t_bseg BY bukrs belnr gjahr matnr.
  LOOP AT t_itab WHERE cek = 'X'.
    LOOP AT t_bseg WHERE bukrs EQ t_itab-bukrs AND
                         belnr EQ t_itab-belnr AND
                         gjahr EQ t_itab-gjahr.
      IF t_bseg-shkzg EQ 'H'.
        ld_wrbtr  = ld_wrbtr + t_bseg-dmbtr * -1.
      ELSE.
        ld_wrbtr  = ld_wrbtr + t_bseg-dmbtr.
      ENDIF.
      IF ld_wrbtr < 0.
        ld_sign = '+'.
      ELSE.
        ld_sign = '-'.
      ENDIF.
      ld_dec4     = ld_wrbtr / 10.
      CALL FUNCTION 'ROUND'
        EXPORTING
          decimals      = 2
          input         = ld_dec4
          sign          = ld_sign
        IMPORTING
          output        = ld_fakppn
        EXCEPTIONS
          input_invalid = 1
          overflow      = 2
          type_invalid  = 3
          OTHERS        = 4.

      ld_itamt    = ld_wrbtr. " * ( 100 / 110 ).
      lt_itab = t_itab.
      lt_itab-hkont   = t_bseg-hkont.
      lt_itab-fakppn  = ld_fakppn.
      lt_itab-itamt   = ld_itamt.
      lt_itab-meins   = t_bseg-meins.
      lt_itab-itqty   = t_bseg-menge.
      lt_itab-harga   = ld_wrbtr / t_bseg-menge.
      lt_itab-fakppnh = t_itab-fakppn.
      CONCATENATE t_bseg-bukrs t_bseg-belnr t_bseg-gjahr t_bseg-buzei INTO ld_tdname.
      PERFORM f_read_text USING ld_tdname
                          CHANGING lt_itab-item.
      IF lt_itab-item IS INITIAL.
        SORT t_makt BY matnr.
        READ TABLE t_makt WITH KEY matnr = t_bseg-matnr.
        IF sy-subrc EQ 0.
          lt_itab-item = t_makt-maktx.
        ELSE.
          lt_itab-item = 'Tidak ada'.
        ENDIF.
      ENDIF.
*      CONCATENATE t_bseg-hkont t_bseg-belnr INTO lt_itab-hkontbelnr.
      "      COLLECT lt_itab.
      AT END OF matnr.
        APPEND lt_itab.
        CLEAR: ld_wrbtr, lt_itab.
      ENDAT.
    ENDLOOP.
  ENDLOOP.

  SORT lt_itab BY belnr fakturno.
  CLEAR: d_no.
  LOOP AT lt_itab WHERE cek = 'X'.
    t_display = lt_itab.
*    break bcdik.
    CONCATENATE lt_itab-fakturno(3) '.' lt_itab-fakturno+3(3) '-'
                lt_itab-fakturno+6(2) '.' lt_itab-fakturno+8(8)
    INTO t_display-fakturnot.
    gv_header-fakturnot = t_display-fakturnot.
    WRITE lt_itab-fakdat TO gv_header-fakturdate.
    gv_header-belnr     = lt_itab-belnr.

    gv_header-pjname    = lt_itab-name.
    gv_header-pjaddrs1 = lt_itab-street.
    gv_header-pjnpwp     = lt_itab-npwp.
    ADD 1 TO d_no.
    gt_detail-nourut    = d_no.
    gt_detail-itemtext  = lt_itab-item.
    gt_detail-itqty   = lt_itab-itqty.
    WRITE lt_itab-itqty TO gt_detail-itqty UNIT lt_itab-meins.
*    ld_harga = lt_itab-itamt / lt_itab-itqty.
    PERFORM f_change_value USING lt_itab-harga '' '' '' "ld_harga
                       CHANGING gt_detail-itamt.
    PERFORM f_change_value USING lt_itab-itamt '' '' '' "
                       CHANGING gt_detail-harga.

    APPEND gt_detail.
    ADD lt_itab-fakppn   TO ld_ppn.
    ADD lt_itab-ppnbm    TO ld_ppnbm.
    ADD lt_itab-itamt    TO ld_dpp.
    ld_fakdat = lt_itab-fakdat.
    ld_dtretur = lt_itab-budat.
    ld_ppn = lt_itab-fakppnh.
    AT END OF belnr.
      PERFORM f_change_value USING ld_dpp '' '' ''
                         CHANGING gv_header-hargapkp.
      PERFORM f_change_value USING ld_dpp '' '' ''
                         CHANGING gv_header-hargadpp.
      PERFORM f_change_value USING ld_ppn '' '' ''
                         CHANGING gv_header-pajaktambah.
      ld_harga = 0.
      PERFORM f_change_value USING ld_harga '' '' ''"ld_harga
                         CHANGING gv_header-discount.

      gv_header-cityttd = gv_header-pkpcity.
*       if gv_header-CITYTTD is INITIAL.
      gv_header-cityttd = 'Jakarta'.
*       endif.
      gv_header-namattd = p_sign.
      IF NOT ld_fakdat IS INITIAL.
        ld_bulan   = ld_fakdat+4(2).
        ld_tanggal = ld_fakdat+6(2).
        ld_tahun   = ld_fakdat+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_fakdat.
        CONCATENATE ld_tanggal d_fakdat ld_tahun INTO gv_header-datettd
                   SEPARATED BY space.
      ENDIF.

      IF NOT ld_dtretur IS INITIAL.
        ld_bulan   = ld_dtretur+4(2).
        ld_tanggal = ld_dtretur+6(2).
        ld_tahun   = ld_dtretur+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_tanggal.
        CONCATENATE ld_tanggal d_tanggal ld_tahun INTO gv_header-datettd
                     SEPARATED BY space.
      ENDIF.
      IF gv_header-datettd IS INITIAL.
        ld_bulan   = sy-datum+4(2).
        ld_tanggal = sy-datum+6(2).
        ld_tahun   = sy-datum+0(4).
        PERFORM f_bulan USING ld_bulan
                        CHANGING d_tanggal.
        CONCATENATE ld_tanggal d_tanggal ld_tahun INTO gv_header-datettd
                     SEPARATED BY space.
      ENDIF.
      PERFORM f_print_form.
      REFRESH gt_detail.
      CLEAR: d_no, ld_dpp, ld_ppn.
    ENDAT.
  ENDLOOP.

ENDFORM.                                                    " F_TAMPIL4


*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LINES  text
*      -->P_LD_TDNAME  text
*----------------------------------------------------------------------*
FORM f_read_text  USING    fu_tdname
                  CHANGING fc_sgtxt.
  DATA: lines   LIKE tline OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = '0001'
      language                = sy-langu
      name                    = fu_tdname
      object                  = 'DOC_ITEM'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  READ TABLE lines INDEX 1.
  IF sy-subrc EQ 0.
    fc_sgtxt  = lines-tdline.
  ENDIF.
ENDFORM.                    " F_READ_TEXT


*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.

  PERFORM f_determine_smrt_funcmod USING p_smartform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gv_header          = gv_header
      TABLES
        gt_detail          = gt_detail.
  ENDIF.
ENDFORM.                    " f_print_form



*&---------------------------------------------------------------------*
*&      Form  f_determine_smrt_funcmod
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TDFORM  text
*      <--P_D_SMRT_FUNCMOD  text
*----------------------------------------------------------------------*
FORM f_determine_smrt_funcmod USING    fu_tdform  TYPE  tdsfname
                              CHANGING fc_funcmod TYPE  rs38l_fnam
                                       fc_subrc.

  CLEAR: fc_funcmod, fc_subrc.
  CLEAR: d_ctrl_param,
         d_output_opt,
         d_smrt_funcmod,
         d_ssfscreen.


  IF fu_tdform IS INITIAL.
    fc_subrc = 8.
  ELSE.
    SET PARAMETER ID 'SSFNAME' FIELD fu_tdform.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname                 = fu_tdform
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
     IMPORTING
       fm_name                  = fc_funcmod
     EXCEPTIONS
       no_form                  = 1
       no_function_module       = 2
       OTHERS                   = 3.

    fc_subrc = sy-subrc.

  ENDIF.

* set output options
  d_output_opt-tddest    = p_dest.
  CLEAR: d_output_opt-tdimmed.
  IF p_disp IS INITIAL.
    d_output_opt-tdimmed   = 'X'.
  ENDIF.

  d_output_opt-tdnewid   = 'X'.

  d_ctrl_param-preview   = p_disp.
  d_ctrl_param-no_dialog = 'X'.

  d_ssfscreen-fname = fu_tdform.


ENDFORM.                    " f_determine_smrt_funcmod




*&---------------------------------------------------------------------*
*&      Form  F_GET_SIGNOFF
*&---------------------------------------------------------------------*
FORM f_get_stdtext USING fu_tdnam fu_brnch fu_idkey fu_reslt.
  DATA: ld_tdnam LIKE rssce-tdname,
        ld_idkey(40),
        ld_reslt(72),
        ld_keyin(40).

  CLEAR fu_reslt.
  ld_keyin = fu_idkey.
  CONCATENATE fu_tdnam fu_brnch INTO ld_tdnam.
  IF ld_tdnam NE d_tdnam OR t_lines[] IS INITIAL..
    REFRESH: t_lines.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*     CLIENT                        = SY-MANDT
        id                            = 'ST'
        language                      = sy-langu
        name                          = ld_tdnam
        object                        = 'TEXT'
*     ARCHIVE_HANDLE                = 0
*     LOCAL_CAT                     = ' '
*   IMPORTING
*     HEADER                        =
      TABLES
        lines                         = t_lines
     EXCEPTIONS
       id                            = 1
       language                      = 2
       name                          = 3
       not_found                     = 4
       object                        = 5
       reference_check               = 6
       wrong_access_to_archive       = 7
       OTHERS                        = 8.
  ELSE.
    d_tdnam = ld_tdnam.
    d_tdnam = ld_tdnam.
    TRANSLATE ld_keyin TO UPPER CASE.
  ENDIF.
  LOOP AT t_lines.
    SPLIT t_lines-tdline AT ':' INTO ld_idkey ld_reslt.
    TRANSLATE ld_idkey TO UPPER CASE.
    IF ld_keyin NE space AND ld_keyin EQ ld_idkey.
      fu_reslt = ld_reslt.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_SIGNOFF

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_mastx fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE netwr_ak.

  lv_wrbtr  = fu_wrbtr.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
      pi_mastx = fu_mastx
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC
