*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
       EXPORTING
            langu = sy-langu
       TABLES
            users = t_user.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

** Get Material
  SELECT a~matnr b~maktx a~meins
    INTO TABLE t_matnr
    FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
    WHERE a~matnr IN s_matnr AND
          a~profl = 'P'     AND
          b~spras = sy-langu
    ORDER BY a~matnr.

** Get Current Stock
  SELECT a~matnr werks SUM( cmbwbest ) SUM( cwbwbest )
    INTO TABLE t_s035
    FROM s035 AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE vrsio = '000'     AND
          a~matnr IN s_matnr AND
          werks = p_werks   AND
          b~profl = 'P'
    GROUP by a~matnr werks.

** Get Transaction Stock
*  SELECT a~matnr werks SUM( cmagbb ) SUM( cwzubb )
  SELECT a~matnr werks SUM( cmagbb ) SUM( cmzubb )
    INTO TABLE t_s034
    FROM s034 AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE vrsio = '000'     AND
          spmon = p_spmon   AND
          werks = p_werks   AND
          a~matnr IN s_matnr AND
          b~profl = 'P'
    GROUP by a~matnr werks .

** Get Jumlah  --- to be changed
  SELECT a~matnr werks SUM( menge )
    INTO TABLE t_s931
*    FROM s931 AS a JOIN mara AS b ON a~matnr = b~matnr
    FROM s933 AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE vrsio = '000'          AND
          spmon = p_spmon        AND
          werks = p_werks        AND
          a~matnr IN s_matnr      AND
          lgort = '1000'         AND
          bwart IN ('321','322') AND
          b~profl = 'P'
    GROUP by a~matnr werks.

** Get Jumlah Bahan Baku
  SELECT a~matnr werks budat aufnr SUM( menge )
    INTO TABLE t_s933
    FROM s933 AS a JOIN mara AS b ON a~matnr = b~matnr
    WHERE vrsio = '000'            AND
          spmon = p_spmon          AND
          werks = p_werks          AND
          a~matnr IN s_matnr        AND
          lgort IN ('1000','2000') AND
          bwart IN ('261','262')   AND
          b~profl = 'P'
    GROUP by a~matnr werks budat aufnr.

** Get Produksi
  SELECT aufnr plnbez gmein igmng gamng
    INTO TABLE t_afko
    FROM afko
    FOR ALL ENTRIES IN t_s933
    WHERE aufnr = t_s933-aufnr.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

*  t_main_tmp[] = t_main[].
*  ASSIGN t_main_tmp TO <fs_table>.
*  PERFORM f_alv TABLES <fs_table>.
*  PERFORM f_alv TABLES t_main.
  PERFORM f_alv1 TABLES t_mainhdr t_maindtl.

ENDFORM.

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
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
    is_layout                      = d_layout
    it_fieldcat                    = t_alv_fieldcat[]
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
    it_sort                        = t_alv_isort[]
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
    i_default                      = 'X'
    i_save                         = 'A'
    is_variant                     = d_alv_variant
    it_events                      = t_alv_event[]
    it_event_exit                  = t_event_exit[]
    is_print                       = d_print
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = ft_report
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_alv1                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA1 FT_DATA2                                             *
*---------------------------------------------------------------------*
FORM f_alv1 TABLES ft_report1 ft_report2.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat1   TABLES  ft_report1 ft_report2.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK              = ' '
      i_callback_program             = d_repid
      i_callback_pf_status_set       = 'F_SET_PF_STATUS'
      i_callback_user_command        = 'F_USER_COMMAND'
      is_layout                      = d_layout
      it_fieldcat                    = t_alv_fieldcat[]
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
      it_sort                        = t_alv_isort[]
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
      i_default                      = 'X'
      i_save                         = 'A'
*     IS_VARIANT                     =
      it_events                      = t_alv_event[]
*     IT_EVENT_EXIT                  =
      i_tabname_header               = 'T_MAINHDR'
      i_tabname_item                 = 'T_MAINDTL'
*     I_STRUCTURE_NAME_HEADER        =
*     I_STRUCTURE_NAME_ITEM          =
      is_keyinfo                     = d_alv_keyinfo
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_BUFFER_ACTIVE                =
*     I_BYPASSING_BUFFER             =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab_header                = ft_report1
      t_outtab_item                  = ft_report2
*   EXCEPTIONS
*     PROGRAM_ERROR                  = 1
*     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
*    'SPMON' 'S034' 'SPMON' '' '' '' '' '' '' '' '' '' '' '',
*    'WERKS' 'T_MAIN' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'MARA' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
    'SAWAL' '' '' '' '15' 'Stok Awal' 'X' '' '2' '' '' '' '' '',
    'SPINO' '' '' '' '10' 'SPI No' '' '' '2' '' '' '' '' '',
    'JUMLAH' '' '' '' '15' 'Jumlah' 'X' '' '2' '' '' '' '' '',
    'TOTAL' '' '' '' '15' 'Total' 'X' '' '2' '' '' '' '' '',
    'BASME' '' '' '' '5' 'Unit' '' '' '' '' '' '' '' '',
    'MENGE' '' '' '' '15' 'Bahan Baku' 'X' '' '2' '' '' '' '' '',
    'BUDAT' '' '' '' '10' 'Tgl Prod' '' '' '' '' '' '' '' '',
    'PLNBEZ' '' '' '' '10' 'Produk' '' '' '' '' '' '' '' '',
    'PLNBEX' '' '' '' '30' 'Description' '' '' '' '' '' '' '' '',
    'CHARG' '' '' '' '5' 'Batch' '' '' '' '' '' '' '' '',
    'GAMNG' '' '' '' '15' 'Target Qty' 'X' '' '2' '' '' '' '' '',
    'GMEIN' '' '' '' '5' 'Satuan' '' '' '' '' '' '' '' '',
    'SAKHIR' '' '' '' '15' 'Stok Akhir' 'X' '' '2' '' '' '' '' ''.

ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcat1                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report1 ft_report2.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'T_MAINHDR':
*    'SPMON' 'S034' 'SPMON' '' '' '' '' '' '' '' '' '' '' '',
*    'WERKS' 'T_MAIN' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'MARA' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
    'SAWAL' '' '' '' '15' 'Stok Awal' 'X' '' '2' '' '' '' '' '',
    'SPINO' '' '' '' '10' 'SPI No' '' '' '2' '' '' '' '' '',
    'JUMLAH' '' '' '' '15' 'Jumlah' 'X' '' '2' '' '' '' '' '',
    'TOTAL' '' '' '' '15' 'Total' 'X' '' '2' '' '' '' '' '',
    'BASME' '' '' '' '5' 'Unit' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'T_MAINDTL':
    'MENGE' '' '' '' '15' 'Bahan Baku' 'X' '' '2' '' '' '' '' '',
    'BUDAT' '' '' '' '10' 'Tgl Prod' '' '' '' '' '' '' '' '',
    'PLNBEZ' '' '' '' '10' 'Produk' '' '' '' '' '' '' '' '',
    'PLNBEX' '' '' '' '30' 'Description' '' '' '' '' '' '' '' '',
    'CHARG' 'AFPO' 'CHARG' '' '' '' '' '' '' '' '' '' '' '',
    'GAMNG' '' '' '' '15' 'Target Qty' 'X' '' '2' '' '' '' '' '',
    'GMEIN' '' '' '' '6' 'Satuan' '' '' '' '' '' '' '' '',
    'SAKHIR' '' '' '' '15' 'Stok Akhir' '' '' '2' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            i_internal_tabname     = 'T_MAINHDR'
       CHANGING
            ct_fieldcat            = t_alv_fieldcat[]
       EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            i_internal_tabname     = 'T_MAINHDR'
       CHANGING
            ct_fieldcat            = t_alv_fieldcat[]
       EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 3.

ENDFORM.                    " F_FIELDCAT1

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
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency    = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
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

  CLEAR ft_events.
  ft_events-name = slis_ev_end_of_list.
  ft_events-form = 'F_END_OF_LIST'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.





ENDFORM.

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

ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
*  fu_layout-totals_before_items = 'X'.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo USING fu_keyinfo TYPE slis_keyinfo_alv.

  fu_keyinfo-header01 = 'WERKS'.
  fu_keyinfo-item01   = 'WERKS'.
  fu_keyinfo-header02 = 'MATNR'.
  fu_keyinfo-item02   = 'MATNR'.

ENDFORM.                    " f_build_keyinfo

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.


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
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATNR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'VERSB'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.

ENDFORM.



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA : l_period(30),
         l_butxt(60),
         l_plant(60),
         l_stras LIKE t001w-stras,
         l_ort01 LIKE t001w-ort01.

  SELECT SINGLE butxt INTO l_butxt
    FROM t001 WHERE bukrs = p_bukrs.

  SELECT SINGLE stras ort01 INTO (l_stras, l_ort01)
    FROM t001w WHERE werks = p_werks.

  CONCATENATE p_spmon+4(2) '.' p_spmon(4) INTO l_period.
  CONCATENATE 'Period : ' l_period INTO l_period SEPARATED BY space.
*  CONCATENATE p_bukrs l_butxt INTO l_butxt SEPARATED BY space.
  CONCATENATE l_stras l_ort01 INTO l_plant SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING l_period.
  PERFORM f_hdr_line3 USING l_butxt.
  PERFORM f_hdr_line4 USING l_plant.
  PERFORM f_hdr_uline.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE4
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING fu_title.

*--- output line
  PERFORM f_hdr_pad_title USING '' fu_title ''.

ENDFORM.                    " F_HDR_LINE4

*---------------------------------------------------------------------*
*       FORM F_END_OF_LIST                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_end_of_list.
  WRITE:/ 'Jakarta, ', sy-datum.
  WRITE:/ 'Penanggung Jawab Produksi'.
  SKIP 3.
  WRITE:/ '(', (20) p_sign CENTERED, ')'.
  WRITE:/ sy-uline(24).
  WRITE:/ ' ', (20) p_sik CENTERED, ' '.
ENDFORM.

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
* refresh:

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
ENDFORM.


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
  IF t_mainhdr[] IS INITIAL.
    MESSAGE i000(zgdmm) WITH 'No Data'.
  ENDIF.
ENDFORM.                    " f_validate_data

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

ENDFORM.
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


*data: gs_lineinfo type kkblo_lineinfo.
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.
  BREAK-POINT.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA: l_charg LIKE afpo-charg.

*  LOOP AT t_matnr.
*    CLEAR: t_s034, t_s035, t_s931, t_s933, t_afko.
*    READ TABLE t_s034 WITH KEY matnr = t_matnr-matnr
*                               werks = p_werks BINARY SEARCH.
*    READ TABLE t_s035 WITH KEY matnr = t_matnr-matnr
*                               werks = p_werks BINARY SEARCH.
*    READ TABLE t_s931 WITH KEY matnr = t_matnr-matnr
*                               werks = p_werks BINARY SEARCH.
*    READ TABLE t_s933 WITH KEY matnr = t_matnr-matnr
*                               werks = p_werks BINARY SEARCH.
*
*    IF sy-subrc = 0.
*      LOOP AT t_s933 WHERE matnr = t_matnr-matnr AND
*                           werks = p_werks.
*
*        READ TABLE t_afko WITH KEY aufnr = t_s933-aufnr.
*        SELECT SINGLE charg INTO l_charg
*          FROM afpo WHERE aufnr = t_afko-aufnr.
*        SELECT SINGLE maktx INTO t_main-plnbex
*          FROM makt WHERE matnr = t_afko-plnbez AND
*                          spras = sy-langu.
*
*        t_main-spmon = p_spmon.
*        t_main-matnr = t_matnr-matnr.
*        t_main-maktx = t_matnr-maktx.
*        t_main-werks = p_werks.
**        t_main-sawal = t_s035-cmbwbest + t_s034-cmagbb - t_s034-cwzubb
  .
*        t_main-sawal = t_s035-cmbwbest + t_s034-cmagbb - t_s034-cmzubb.
*        t_main-jumlah = t_s931-menge.
*        t_main-total = t_main-sawal + t_main-jumlah.
*        t_main-basme = t_matnr-meins.
*        t_main-menge = t_s933-menge.
*        t_main-budat = t_s933-budat.
*        t_main-plnbez = t_afko-plnbez.
*        t_main-charg = l_charg.
*        t_main-igmng = t_afko-igmng.
*        t_main-gmein = t_afko-gmein.
*        t_main-sakhir = t_main-total + t_main-menge.
*
*        IF t_main-sawal NE 0  OR
*           t_main-jumlah NE 0 OR
*           t_main-menge NE 0  OR
*           t_main-igmng NE 0  OR
*           t_main-sakhir NE 0.
*          APPEND t_main.
*        ENDIF.
*
*        CLEAR: t_s933, t_afko, l_charg.
*      ENDLOOP.
*    ELSE.
*      CLEAR: t_s933, t_afko, l_charg.
*      t_main-spmon = p_spmon.
*      t_main-matnr = t_matnr-matnr.
*      t_main-maktx = t_matnr-maktx.
*      t_main-werks = p_werks.
**      t_main-sawal = t_s035-cmbwbest + t_s034-cmagbb - t_s034-cwzubb.
*      t_main-sawal = t_s035-cmbwbest + t_s034-cmagbb - t_s034-cmzubb.
*      t_main-jumlah = t_s931-menge.
*      t_main-total = t_main-sawal + t_main-jumlah.
*      t_main-basme = t_matnr-meins.
*      t_main-menge = t_s933-menge.
*      t_main-budat = t_s933-budat.
*      t_main-plnbez = t_afko-plnbez.
*      t_main-charg = l_charg.
*      t_main-igmng = t_afko-igmng.
*      t_main-gmein = t_afko-gmein.
*      t_main-sakhir = t_main-total - t_main-menge.
*
*      IF t_main-sawal NE 0  OR
*         t_main-jumlah NE 0 OR
*         t_main-menge NE 0  OR
*         t_main-igmng NE 0  OR
*         t_main-sakhir NE 0.
*        APPEND t_main.
*      ENDIF.
*    ENDIF.
*
*  ENDLOOP.

  LOOP AT t_matnr.

*** Get main Header
    CLEAR: t_s034, t_s035, t_s931, t_s933, t_afko, t_mainhdr, t_maindtl.
*{   INSERT         P01K910232                                        1
    "Start SOH: Shell SCI Adjustment 20240221 RZL
     SORT t_s034 by matnr werks.
    "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
    READ TABLE t_s034 WITH KEY matnr = t_matnr-matnr
                               werks = p_werks BINARY SEARCH.
*{   INSERT         P01K910232                                        2
    "Start SOH: Shell SCI Adjustment 20240221 RZL
     SORT t_s035 by matnr werks.
    "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
    READ TABLE t_s035 WITH KEY matnr = t_matnr-matnr
                               werks = p_werks BINARY SEARCH.
*{   INSERT         P01K910232                                        3
    "Start SOH: Shell SCI Adjustment 20240221 RZL
     SORT t_s931 by matnr werks.
    "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
    READ TABLE t_s931 WITH KEY matnr = t_matnr-matnr
                               werks = p_werks BINARY SEARCH.
    t_mainhdr-spmon = p_spmon.
    t_mainhdr-matnr = t_matnr-matnr.
    t_mainhdr-maktx = t_matnr-maktx.
    t_mainhdr-werks = p_werks.
*    t_mainhdr-sawal = t_s035-cmbwbest + t_s034-cmagbb - t_s034-cwzubb.
    t_mainhdr-sawal = t_s035-cmbwbest + t_s034-cmagbb - t_s034-cmzubb.
    t_mainhdr-jumlah = t_s931-menge.
    t_mainhdr-total = t_mainhdr-sawal + t_mainhdr-jumlah.
    t_mainhdr-basme = t_matnr-meins.
    t_maindtl-sakhir = t_mainhdr-total.

    IF t_mainhdr-sawal NE 0  OR
       t_mainhdr-jumlah NE 0.
      APPEND t_mainhdr.
    ELSE.
*{   INSERT         P01K910232                                        4
     "Start SOH: Shell SCI Adjustment 20240221 RZL
     SORT t_s933 by matnr werks.
    "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
      READ TABLE t_s933 WITH KEY matnr = t_matnr-matnr
                                 werks = p_werks BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND t_mainhdr.
      ENDIF.
    ENDIF.

*** Get main Detail
    LOOP AT t_s933 WHERE matnr = t_matnr-matnr AND
                         werks = p_werks.

      READ TABLE t_afko WITH KEY aufnr = t_s933-aufnr.
      SELECT SINGLE charg INTO l_charg
        FROM afpo WHERE aufnr = t_afko-aufnr.
      SELECT SINGLE maktx INTO t_maindtl-plnbex
        FROM makt WHERE matnr = t_afko-plnbez AND
                        spras = sy-langu.

      t_maindtl-spmon = p_spmon.
      t_maindtl-matnr = t_matnr-matnr.
      t_maindtl-maktx = t_matnr-maktx.
      t_maindtl-werks = p_werks.
      t_maindtl-menge = t_s933-menge.
      t_maindtl-budat = t_s933-budat.
      t_maindtl-plnbez = t_afko-plnbez.
      t_maindtl-charg = l_charg.
      t_maindtl-igmng = t_afko-igmng.
      t_maindtl-gamng = t_afko-gamng.
      t_maindtl-gmein = t_afko-gmein.
*      t_maindtl-sakhir = t_maindtl-sakhir + t_maindtl-menge.
      t_maindtl-sakhir = t_maindtl-sakhir - t_maindtl-menge.
      APPEND t_maindtl.
      CLEAR: t_s933, t_afko, l_charg.
    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " f_process_data
