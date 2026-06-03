*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

  IF p_bstdk = 'X' AND s_bstdk[] IS INITIAL.
    MESSAGE i000(zgdsd) WITH 'Period Must Entry'.
    STOP.
  ELSEIF p_erdat = 'X' AND s_erdat[] IS INITIAL.
    MESSAGE i000(zgdsd) WITH 'Period Must Entry'.
    STOP.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA : l_menge  LIKE  ekbe-menge,
         l_so     TYPE  i,
         l_po     TYPE  i,
         l_popend TYPE  i.

  SELECT matnr mtart INTO TABLE i_matnr
    FROM mara
    WHERE matnr IN s_matnr AND
          mtart IN s_mtart.

  CHECK NOT i_matnr[] IS INITIAL.

  IF NOT p_so IS INITIAL.
    SELECT a~vkorg a~vkbur a~bstdk a~vbeln a~kunnr
           a~erdat a~bstnk
           b~posnr b~matnr b~arktx b~kwmeng b~vrkme
           c~bstkd
      INTO CORRESPONDING FIELDS OF TABLE i_so
      FROM vbak AS a JOIN vbap AS b ON a~vbeln = b~vbeln
                     JOIN vbkd AS c ON a~vbeln = c~vbeln
      FOR ALL ENTRIES IN i_matnr
      WHERE a~vkbur  IN s_vkbur       AND
            a~vkorg  EQ p_vkorg       AND
            a~vbeln  IN s_vbeln       AND
            a~kunnr  IN s_kunnr       AND
            a~auart  IN s_auart       AND
*            a~bstnk  IN s_bstnk       AND
            a~bstdk  IN s_bstdk       AND
            a~erdat  IN s_erdat       AND
            a~vbtyp  IN ('C','H')     AND
            b~matnr  = i_matnr-matnr  AND
            b~abgru  =  space         AND
            c~bstkd  IN s_bstkd.

    IF NOT i_so[] IS INITIAL.
      SELECT a~wadat_ist
             b~vgbel b~vgpos b~vbeln b~posnr b~lfimg b~fkrel
        INTO CORRESPONDING FIELDS OF TABLE i_sodelv
        FROM likp AS a JOIN lips AS b ON a~vbeln = b~vbeln
                       JOIN vbuk AS c ON a~vbeln = c~vbeln
        FOR ALL ENTRIES IN i_so
        WHERE b~vgbel = i_so-vbeln  AND
              b~posnr GE 900000     AND
*              b~fkrel = space."       AND
              a~wadat_ist NE 0      AND
              c~wbstk = 'C'.
    ENDIF.
  ENDIF.

  IF NOT p_po IS INITIAL.
    SELECT a~vkorg a~kunnr a~ledat a~ebeln
           b~ebelp b~werks b~matnr b~txz01 b~menge b~meins
           c~bsart c~bedat c~reswk c~aedat
      INTO CORRESPONDING FIELDS OF TABLE i_po
      FROM ekpv AS a JOIN ekpo AS b ON a~ebeln = b~ebeln AND
                                       a~ebelp = b~ebelp
                     JOIN ekko AS c ON a~ebeln = c~ebeln
      FOR ALL ENTRIES IN i_matnr
      WHERE a~vkorg  EQ p_vkorg       AND
            a~ebeln  IN s_ebeln       AND
            b~matnr  = i_matnr-matnr  AND
            a~kunnr  IN s_kunnr       AND
*            b~werks  IN s_vkbur       AND
*            b~kunnr  IN s_kunnr       AND
            b~loekz  =  space         AND
            c~reswk  IN s_vkbur       AND
            c~bedat  IN s_bstdk       AND
            c~aedat  IN s_erdat       AND
            c~bsart  IN s_bsart.
*          a~bsart  =  'ZB'          AND

    IF NOT i_po[] IS INITIAL.
      SELECT a~wadat_ist
             b~vgbel b~vgpos b~vbeln b~posnr b~lfimg b~fkrel
        INTO CORRESPONDING FIELDS OF TABLE i_podelv
        FROM likp AS a JOIN lips AS b ON a~vbeln = b~vbeln
                       JOIN vbuk AS c ON a~vbeln = c~vbeln
        FOR ALL ENTRIES IN i_po
        WHERE b~vgbel = i_po-ebeln  AND
*              b~posnr GE 900000     AND
*              b~fkrel = space       AND
              a~wadat_ist NE 0      AND
              c~wbstk = 'C'.

*      SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp
*             menge shkzg
*        INTO CORRESPONDING FIELDS OF TABLE i_popend
*        FROM ekbe
*        FOR ALL ENTRIES IN i_po
*        WHERE ebeln = i_po-ebeln  AND
*              bewtp = 'U'.
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

*  t_main_tmp[] = t_main[].
*  ASSIGN t_main_tmp TO <fs_table>.
*  PERFORM f_alv TABLES i_main.
  PERFORM f_alv1 TABLES i_mainhdr i_maindtl.

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
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
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
      i_tabname_header               = 'I_MAINHDR'
      i_tabname_item                 = 'I_MAINDTL'
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
*   'FLAG' '' '' '' '4' 'Flag' '' '' '' '' '' '' '' 'X' 'X',
*   'VKBUR' 'VBAK' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
   'DOCDT' '' '' '' '12' 'Doc. Date' '' '' '' '' '' '' '' '' '',
   'DOCNO' '' '' '' '12' 'Doc. Number' '' '' '' '' '' '' '' '' '',
   'KUNNR' '' '' '' '12' 'Customer' '' '' '' '' '' '' '' '' '',
   'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' '' '',
   'MATNR' '' '' '' '12' 'Material' '' '' '' '' '' '' '' '' '',
   'DESCR' '' '' '' '40' 'Material Description' '' '' '' '' '' '' '' ''
'',
   'QUANT' 'VBAP' 'KWMENG' '' '' '' '' '' '' '' '' '' '' '' '',
   'UOFME' '' '' '' '5' 'UoM' '' '' '' '' '' '' '' '' '',
   'WADAT_IST' '' '' '' '12' 'Delv. Date' '' '' '' '' '' '' '' '' '',
   'LFIMG' 'LIPS' 'LFIMG' '' '' 'Delivery Qty' 'X' '' '' '' '' '' '' ''
'',
   'PEQTY' 'VBBE' 'OMENG' '' '' 'Pending Qty' '' '' '' '' '' '' '' ''
''.

ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcat1                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report1 ft_report2.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'I_MAINHDR':
   'DOCDT' '' '' '' '15' 'Doc. Date' '' '' '' '' '' '' '' '' '',
   'DOCNO' '' '' '' '12' 'Doc. Number' '' '' '' '' '' '' '' '' '',
   'KUNNR' '' '' '' '12' 'Customer' '' '' '' '' '' '' '' '' '',
   'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' '' '',
   'MATNR' '' '' '' '12' 'Material' '' '' '' '' '' '' '' '' '',
   'DESCR' '' '' '' '40' 'Material Description' '' '' '' '' '' '' '' ''
''.
  IF p_so = 'X'.
    PERFORM f_fieldcatg USING 'I_MAINHDR':
    'DOCPO' '' '' '' '35' 'PO Number' '' '' '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING 'I_MAINHDR':
   'ENTDT' '' '' '' '15' 'Create Date' '' '' '' '' '' '' '' '' '',
   'QUANT' '' '' '' '13' 'Order Qty' 'X' '' '2' '' '' '' '' '' '',
   'UOFME' '' '' '' '5' 'UoM' '' '' '' '' '' '' '' '' '',
   'PEQTY' '' '' '' '13' 'Pending Qty' 'X' '' '2' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'I_MAINDTL':
   'VBELN' 'LIKP' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '',
   'WADAT_IST' '' '' '' '12' 'Delv. Date' '' '' '' '' '' '' '' '' '',
   'LFIMG' '' '' '' '13' 'Delivery Qty' 'X' '' '2' '' '' '' '' '' '',
   'TEXT' '' '' '' '50' 'Header Text' '' '' '' '' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            i_internal_tabname     = 'I_MAINHDR'
       CHANGING
            ct_fieldcat            = t_alv_fieldcat[]
       EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            i_internal_tabname     = 'I_MAINHDR'
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
                          value(fu_checkbox)
                          value(fu_no_sum).

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
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  ld_fieldcat-no_sum        = fu_no_sum.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo USING fu_keyinfo TYPE slis_keyinfo_alv.

  fu_keyinfo-header01 = 'DOCNO'.
  fu_keyinfo-item01   = 'DOCNO'.
  fu_keyinfo-header02 = 'ITMNO'.
  fu_keyinfo-item02   = 'ITMNO'.

ENDFORM.                    " f_build_keyinfo

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

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

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
*  fu_layout-box_fieldname      = 'FLAG'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-info_fieldname     = 'INFO'.  "Color

ENDFORM.


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

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'DOCDT'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'DOCNO'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATNR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

ENDFORM.



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: l_vkbur(30),
        l_date1(10),
        l_date2(10),
        l_date(50).

*  SELECT SINGLE bezei INTO l_vkbur
*    FROM tvkbt WHERE spras = sy-langu AND
*                     vkbur = i_main-vkbur.
*  CONCATENATE 'Plant :' i_main-vkbur '-' l_vkbur INTO l_vkbur
*      SEPARATED BY space.
  SELECT SINGLE bezei INTO l_vkbur
    FROM tvkbt WHERE spras = sy-langu AND
                     vkbur = i_mainhdr-vkbur.
  CONCATENATE 'Plant :' i_mainhdr-vkbur '-' l_vkbur INTO l_vkbur
      SEPARATED BY space.

  IF p_bstdk = 'X'.
    WRITE s_bstdk-low TO l_date1.
    WRITE s_bstdk-high TO l_date2.
    CONCATENATE 'Period by Doc Date:' l_date1 'To' l_date2 INTO l_date
        SEPARATED BY space.
  ELSE.
    WRITE s_erdat-low TO l_date1.
    WRITE s_erdat-high TO l_date2.
    CONCATENATE 'Period by Create Date:' l_date1 'To' l_date2
        INTO l_date SEPARATED BY space.
  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING l_vkbur.
  PERFORM f_hdr_line3 USING l_date.
  PERFORM f_hdr_uline.

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

  DATA : l_sodelv TYPE  i,
         l_podelv TYPE  i,
         l_popend TYPE  i,
         l_stxh  LIKE stxh,
         l_text1 TYPE tline OCCURS 0 WITH HEADER LINE,
         l_text2 TYPE tline OCCURS 0 WITH HEADER LINE.

  IF NOT p_so IS INITIAL.
    SORT i_sodelv BY vgbel vgpos.
    SORT i_so BY vbeln posnr.
    LOOP AT i_so.
      i_mainhdr-vkbur = i_so-vkbur.
      i_mainhdr-docno = i_so-vbeln.
      i_mainhdr-itmno = i_so-posnr.
*      i_mainhdr-docpo = i_so-bstnk.
      i_mainhdr-docpo = i_so-bstkd.
      i_mainhdr-docdt = i_so-bstdk.
      i_mainhdr-entdt = i_so-erdat.
      i_mainhdr-kunnr = i_so-kunnr.
      i_mainhdr-matnr = i_so-matnr.
      i_mainhdr-descr = i_so-arktx.
      i_mainhdr-quant = i_so-kwmeng.
      i_mainhdr-uofme = i_so-vrkme.
      i_mainhdr-peqty = i_mainhdr-quant.

      READ TABLE i_sodelv WITH KEY vgbel = i_so-vbeln
                                   vgpos = i_so-posnr BINARY SEARCH.
      IF sy-subrc = 0.
        l_sodelv = sy-tabix.
      ELSE.
        CLEAR l_sodelv.
      ENDIF.

      LOOP AT i_sodelv FROM l_sodelv.
        IF i_sodelv-vgbel NE i_so-vbeln OR
           i_sodelv-vgpos NE i_so-posnr.
          EXIT.
        ENDIF.
        i_mainhdr-peqty = i_mainhdr-peqty - i_sodelv-lfimg.

        SELECT SINGLE * INTO l_stxh
          FROM stxh
          WHERE tdobject = 'VBBK' AND
                tdname   = i_sodelv-vbeln.

        IF sy-subrc = 0.
          CALL FUNCTION 'READ_TEXT_INLINE'
            EXPORTING
              id                    = l_stxh-tdid
              inline_count          = '1'
              language              = l_stxh-tdspras
              name                  = l_stxh-tdname
              object                = l_stxh-tdobject
*           LOCAL_CAT             = ' '
*         IMPORTING
*           HEADER                =
            TABLES
              inlines               = l_text1
              lines                 = l_text2
*         EXCEPTIONS
*           id                    = 1
*           language              = 2
*           name                  = 3
*           not_found             = 4
*           object                = 5
*           reference_check       = 6
*           OTHERS                = 7
                    .
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          READ TABLE l_text1 INDEX 1.
          i_maindtl-text = l_text1-tdline.
        ENDIF.

        i_maindtl-docno = i_sodelv-vgbel.
        i_maindtl-itmno = i_sodelv-vgpos.
        i_maindtl-wadat_ist = i_sodelv-wadat_ist.
        i_maindtl-vbeln = i_sodelv-vbeln.
        i_maindtl-lfimg = i_sodelv-lfimg.

*        APPEND i_maindtl.
        COLLECT i_maindtl.
        CLEAR: i_maindtl,l_stxh,l_text1,l_text2.
        REFRESH: l_text1,l_text2.
      ENDLOOP.


      SELECT SINGLE name1 FROM kna1
        INTO i_mainhdr-name1
        WHERE kunnr = i_mainhdr-kunnr.

      APPEND i_mainhdr.
      CLEAR: i_mainhdr.
    ENDLOOP.

*    LOOP AT i_sodelv.
*      i_maindtl-docno = i_sodelv-vgbel.
*      i_maindtl-itmno = i_sodelv-vgpos.
*      i_maindtl-wadat_ist = i_sodelv-wadat_ist.
*      i_maindtl-vbeln = i_sodelv-vbeln.
*      i_maindtl-lfimg = i_sodelv-lfimg.
*      APPEND i_maindtl.
*      CLEAR: i_maindtl.
*    ENDLOOP.

  ENDIF.

  IF NOT p_po IS INITIAL.
    SORT i_popend BY ebeln ebelp.
    SORT i_podelv BY vgbel vgpos.
    SORT i_po BY ebeln ebelp.
    LOOP AT i_po.
      i_mainhdr-vkbur = i_po-reswk.
      i_mainhdr-docno = i_po-ebeln.
      i_mainhdr-itmno = i_po-ebelp.
      i_mainhdr-docdt = i_po-bedat.
      i_mainhdr-entdt = i_po-aedat.
      i_mainhdr-kunnr = i_po-kunnr.
      i_mainhdr-matnr = i_po-matnr.
      i_mainhdr-descr = i_po-txz01.
      i_mainhdr-quant = i_po-menge.
      i_mainhdr-uofme = i_po-meins.
      i_mainhdr-peqty = i_mainhdr-quant.

      READ TABLE i_podelv WITH KEY vgbel = i_po-ebeln
                                   vgpos = i_po-ebelp BINARY SEARCH.
      IF sy-subrc = 0.
        l_podelv = sy-tabix.
      ELSE.
        CLEAR l_podelv.
      ENDIF.

      LOOP AT i_podelv FROM l_podelv.
        IF i_podelv-vgbel NE i_po-ebeln OR
           i_podelv-vgpos NE i_po-ebelp.
          EXIT.
        ENDIF.
        i_mainhdr-peqty = i_mainhdr-peqty - i_podelv-lfimg.

        SELECT SINGLE * INTO l_stxh
          FROM stxh
          WHERE tdobject = 'VBBK' AND
                tdname   = i_podelv-vbeln.

        IF sy-subrc = 0.
          CALL FUNCTION 'READ_TEXT_INLINE'
            EXPORTING
              id                    = l_stxh-tdid
              inline_count          = '1'
              language              = l_stxh-tdspras
              name                  = l_stxh-tdname
              object                = l_stxh-tdobject
*           LOCAL_CAT             = ' '
*         IMPORTING
*           HEADER                =
            TABLES
              inlines               = l_text1
              lines                 = l_text2
*         EXCEPTIONS
*           id                    = 1
*           language              = 2
*           name                  = 3
*           not_found             = 4
*           object                = 5
*           reference_check       = 6
*           OTHERS                = 7
                    .
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          READ TABLE l_text1 INDEX 1.
          i_maindtl-text = l_text1-tdline.
        ENDIF.

        i_maindtl-docno = i_podelv-vgbel.
        i_maindtl-itmno = i_podelv-vgpos.
        i_maindtl-wadat_ist = i_podelv-wadat_ist.
        i_maindtl-vbeln = i_podelv-vbeln.
        i_maindtl-lfimg = i_podelv-lfimg.

*      APPEND i_maindtl.
        COLLECT i_maindtl.
        CLEAR: i_maindtl,l_stxh,l_text1,l_text2.
        REFRESH: l_text1,l_text2.
      ENDLOOP.

*      READ TABLE i_popend WITH KEY ebeln = i_po-ebeln
*                                   ebelp = i_po-ebelp BINARY SEARCH.
*      IF sy-subrc = 0.
*        l_popend = sy-tabix.
*      ELSE.
*        CLEAR l_popend.
*      ENDIF.
*
*      LOOP AT i_popend FROM l_popend.
*        IF i_popend-ebeln NE i_po-ebeln OR
*           i_popend-ebelp NE i_po-ebelp.
*          EXIT.
*        ENDIF.
**        IF i_popend-shkzg = 'S'.
**          i_popend-menge = i_popend-menge * -1.
**        ENDIF.
**        i_mainhdr-peqty = i_mainhdr-peqty + i_popend-menge.
*        i_mainhdr-peqty = i_mainhdr-peqty - i_popend-menge.
*      ENDLOOP.

      SELECT SINGLE name1 FROM kna1
        INTO i_mainhdr-name1
        WHERE kunnr = i_mainhdr-kunnr.

      APPEND i_mainhdr.
      CLEAR: i_mainhdr.
    ENDLOOP.

*    LOOP AT i_podelv.
*      SELECT SINGLE * INTO l_stxh
*        FROM stxh
*        WHERE tdobject = 'VBBK' AND
*              tdname   = i_podelv-vbeln.
*
*      IF sy-subrc = 0.
*        CALL FUNCTION 'READ_TEXT_INLINE'
*          EXPORTING
*            id                    = l_stxh-tdid
*            inline_count          = '1'
*            language              = l_stxh-tdspras
*            name                  = l_stxh-tdname
*            object                = l_stxh-tdobject
**           LOCAL_CAT             = ' '
**         IMPORTING
**           HEADER                =
*          TABLES
*            inlines               = l_text1
*            lines                 = l_text2
**         EXCEPTIONS
**           id                    = 1
**           language              = 2
**           name                  = 3
**           not_found             = 4
**           object                = 5
**           reference_check       = 6
**           OTHERS                = 7
*                  .
*        IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.
*
*        READ TABLE l_text1 INDEX 1.
*        i_maindtl-text = l_text1-tdline.
*      ENDIF.
*
*      i_maindtl-docno = i_podelv-vgbel.
*      i_maindtl-itmno = i_podelv-vgpos.
*      i_maindtl-vbeln = i_podelv-vbeln.
*      i_maindtl-lfimg = i_podelv-lfimg.
*      i_maindtl-wadat_ist = i_podelv-wadat_ist.
*
**      APPEND i_maindtl.
*      COLLECT i_maindtl.
*      CLEAR: i_maindtl,l_stxh,l_text1,l_text2.
*      REFRESH: l_text1,l_text2.
*    ENDLOOP.
  ENDIF.

  CLEAR: i_so. REFRESH: i_so.
  CLEAR: i_sodelv. REFRESH: i_sodelv.
  CLEAR: i_popend. REFRESH: i_popend.
  CLEAR: i_podelv. REFRESH: i_podelv.
  CLEAR: i_po. REFRESH: i_po.

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
    WHEN '&ALL'.
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
