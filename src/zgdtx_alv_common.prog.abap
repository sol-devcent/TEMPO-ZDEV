***INCLUDE ZGDTX_ALV_COMMON .

TYPE-POOLS: slis.

DATA: t_alv_fctlg TYPE slis_t_fieldcat_alv,
      t_alv_event TYPE slis_t_event WITH HEADER LINE,
      t_alv_isort TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      t_alv_filtr TYPE slis_t_filter_alv WITH HEADER LINE,
      d_alv_isort TYPE slis_sortinfo_alv,
      d_alv_varnt TYPE disvariant,
      d_alv_lscrl TYPE  slis_list_scroll,
      d_alv_sort_postn TYPE i,
      d_alv_varnm LIKE disvariant-variant,
      d_alv_qinfo TYPE slis_keyinfo_alv,
      d_alv_fctlg TYPE slis_fieldcat_alv,
      d_alv_stats TYPE slis_formname,
      d_alv_ucomm TYPE slis_formname,
      d_alv_print TYPE slis_print_alv,
      d_alv_repid LIKE sy-repid,
      d_alv_tabix LIKE sy-tabix,
      d_alv_subrc LIKE sy-subrc,
      d_alv_screen_start_column TYPE i,
      d_alv_screen_start_line TYPE i,
      d_alv_screen_end_column TYPE i,
      d_alv_screen_end_line TYPE i,
      d_alv_layot TYPE slis_layout_alv,
      d_alv_status LIKE rseux-cpc_value.

*&---------------------------------------------------------------------*
*&      Form  F_GET_CATALOG
*&---------------------------------------------------------------------*
* @FT_FCTLG = internal table to store field catalog result
* @FU_TABLE = internal table name
* @FU_STRCT = Table/Structure name
* description: Purpose to get field attribute from data dictionary
*              (Table/Structure) and save as ALV field catalog
FORM f_alv_get_catalog TABLES ft_fctlg TYPE slis_t_fieldcat_alv
                       USING  fu_table
                              fu_strct.
  DATA: ld_table TYPE slis_tabname,
        ld_strct LIKE dd02l-tabname,
        ld_fctlg TYPE slis_fieldcat_alv,
        lt_fctlg TYPE slis_t_fieldcat_alv.
  ld_table = fu_table.
  ld_strct = fu_strct.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            i_internal_tabname     = ld_table
            i_structure_name       = ld_strct
            i_bypassing_buffer     = 'X'
       CHANGING
            ct_fieldcat            = lt_fctlg
       EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 3.
  IF sy-subrc <> 0.
  ENDIF.

***removed by Rahmadi -- due to currency generalization
*  ld_fctlg-currency = 'IDR'.
*  MODIFY lt_fctlg FROM ld_fctlg TRANSPORTING currency
*    WHERE datatype EQ 'CURR'.
***end of removal
  APPEND LINES OF lt_fctlg TO ft_fctlg.
ENDFORM.                    " F_GET_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_ALV_DISPLAY2
*&---------------------------------------------------------------------*
* @FT_HEADR = Internal table for Header level
* @FT_ITEMS = Internal table for Item level
* @FT_HEADR = Internal table name for Header level
* @FU_ITEMS = Internal table name for Item level
* @FU_FSAVE = Kind of ALV variant
* description: Purpose to get display ALV which contain Header and
*              Item level information
FORM f_alv_display2 TABLES ft_headr
                           ft_items
                    USING  fu_headr TYPE slis_tabname
                           fu_items TYPE slis_tabname
                           fu_fsave.

  d_alv_varnt-report = d_alv_repid.
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
       EXPORTING
            i_callback_program       = d_alv_repid
            i_callback_pf_status_set = d_alv_stats
            i_callback_user_command  = d_alv_ucomm
            is_layout                = d_alv_layot
            i_save                   = fu_fsave
            it_fieldcat              = t_alv_fctlg
            it_sort                  = t_alv_isort[]
            it_events                = t_alv_event[]
            is_variant               = d_alv_varnt
            i_tabname_header         = fu_headr
            i_tabname_item           = fu_items
            is_keyinfo               = d_alv_qinfo
            is_print                 = d_alv_print
            i_screen_start_column    = d_alv_screen_start_column
            i_screen_start_line      = d_alv_screen_start_line
            i_screen_end_column      = d_alv_screen_end_column
            i_screen_end_line        = d_alv_screen_end_line
       TABLES
            t_outtab_header          = ft_headr
            t_outtab_item            = ft_items
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
ENDFORM.                     " F_ALV_DISPLAY2


*&---------------------------------------------------------------------*
*&      Form  F_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort USING fu_table fu_field fu_ascnd.
  DATA: ld_isort TYPE slis_sortinfo_alv.
  d_alv_sort_postn = d_alv_sort_postn + 1.
  ld_isort-tabname   = fu_table.
  ld_isort-fieldname = fu_field.
  IF fu_ascnd = 'X'.
    ld_isort-up = 'X'.
  ELSE.
    ld_isort-down = 'X'.
  ENDIF.
  ld_isort-spos      = d_alv_sort_postn.
  APPEND ld_isort TO t_alv_isort.
ENDFORM.                    " F_SORT


*&---------------------------------------------------------------------*
*&      Form  F_ALV_DISPLAY1
*&---------------------------------------------------------------------*
FORM f_alv_display1 TABLES ft_table
                    USING  fu_table TYPE slis_tabname
                           fu_fsave.
  break ibm_rahmadi.
  d_alv_varnt-report = d_alv_repid.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
            i_callback_program       = d_alv_repid
            i_callback_pf_status_set = d_alv_stats
            i_callback_user_command  = d_alv_ucomm
*           I_STRUCTURE_NAME         =
            is_layout                = d_alv_layot
            it_fieldcat              = t_alv_fctlg
            it_sort                  = t_alv_isort[]
            i_default                = 'X'
            i_save                   = fu_fsave
            is_variant               = d_alv_varnt
            it_events                = t_alv_event[]
            is_print                 = d_alv_print
            i_screen_start_column    = d_alv_screen_start_column
            i_screen_start_line      = d_alv_screen_start_line
            i_screen_end_column      = d_alv_screen_end_column
            i_screen_end_line        = d_alv_screen_end_line
       TABLES
            t_outtab                 = ft_table[]
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
ENDFORM.                    " F_ALV_DISPLAY1

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS d_alv_status.

ENDFORM.                    " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_ALV_BUILD_EVENT
*&---------------------------------------------------------------------*
FORM f_alv_build_event USING fu_pname
                             fu_pform.

  CLEAR t_alv_event.
  t_alv_event-name = fu_pname.
  t_alv_event-form = fu_pform.
  APPEND t_alv_event.
ENDFORM.                    " F_BUILD_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_TABLES2
*&---------------------------------------------------------------------*
FORM f_alv_get_tables2 TABLES ft_headr ft_items.
  CALL FUNCTION 'REUSE_ALV_HS_TABLES_GET'
       TABLES
            et_outtab_master = ft_headr
            et_outtab_detail = ft_items
       EXCEPTIONS
            no_infos         = 1
            OTHERS           = 2.
ENDFORM.                    " F_GET_TABLES

*---------------------------------------------------------------------*
*       FORM f_alv_get_tables                                         *
*---------------------------------------------------------------------*
FORM f_alv_get_tables1 TABLES ft_table.
  CALL FUNCTION 'REUSE_ALV_TABLES_GET'
       TABLES
            et_outtab = ft_table
       EXCEPTIONS
            no_infos  = 1
            OTHERS    = 2.
ENDFORM.                    " F_GET_TABLES

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BOX
*&---------------------------------------------------------------------*
FORM f_alv_check_box USING fu_tname.
  d_alv_layot-box_fieldname = 'CHKBX'.
  d_alv_layot-box_tabname   = fu_tname.
ENDFORM.                    " F_CHECK_BOX

*&---------------------------------------------------------------------*
*&      Form  F_ALV_CATALOG
*&---------------------------------------------------------------------*
FORM f_alv_catalog USING ft_fctlg TYPE slis_t_fieldcat_alv
                         fu_tbnam fu_fname fu_dscrp
                         fu_reftb fu_refld
                         fu_noout fu_outln fu_hotsp fu_jstfy
                         fu_cfield  "added by Rahmadi
                         fu_ctab.   "added by Rahmadi

  DATA: lv_fctlg TYPE slis_fieldcat_alv,
        ld_lngth TYPE i.
  ld_lngth = strlen( fu_dscrp ).
  IF ld_lngth > 10.
    lv_fctlg-seltext_m     = fu_dscrp.
  ELSE.
    lv_fctlg-seltext_s     = fu_dscrp.
    lv_fctlg-seltext_m     = fu_dscrp.
  ENDIF.
  lv_fctlg-tabname       = fu_tbnam.
  lv_fctlg-fieldname     = fu_fname.
  lv_fctlg-ref_tabname   = fu_reftb.
  lv_fctlg-ref_fieldname = fu_refld.
  lv_fctlg-no_out        = fu_noout.
  lv_fctlg-outputlen     = fu_outln.
  lv_fctlg-hotspot       = fu_hotsp.
  lv_fctlg-just          = fu_jstfy.
***added by Rahmadi
  lv_fctlg-cfieldname    = fu_cfield.
  lv_fctlg-ctabname      = fu_ctab.
***end of addition
  APPEND lv_fctlg TO ft_fctlg.
ENDFORM.                               " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_ALV_CATALOG_CRNCY
*&---------------------------------------------------------------------*
FORM f_alv_catalog_crncy USING ft_fctlg TYPE slis_t_fieldcat_alv
                         fu_tbnam fu_fname fu_dscrp
                         fu_reftb fu_refld fu_outln fu_dosum
                         fu_curky fu_cfild fu_ctbnm fu_jstfy.
  DATA: lv_fctlg TYPE slis_fieldcat_alv,
        ld_lngth TYPE i.
  ld_lngth = strlen( fu_dscrp ).

  IF ld_lngth > 25.
    lv_fctlg-seltext_l   = fu_dscrp.
  ELSEIF ld_lngth > 10.
    lv_fctlg-seltext_l   = fu_dscrp.
    lv_fctlg-seltext_m   = fu_dscrp.
  ELSE.
    lv_fctlg-seltext_s   = fu_dscrp.
    lv_fctlg-seltext_m   = fu_dscrp.
    lv_fctlg-seltext_l   = fu_dscrp.
  ENDIF.
  lv_fctlg-tabname       = fu_tbnam.
  lv_fctlg-fieldname     = fu_fname.
  lv_fctlg-ctabname      = fu_reftb.
  lv_fctlg-cfieldname    = fu_refld.
  lv_fctlg-outputlen     = fu_outln.
  lv_fctlg-do_sum        = fu_dosum.
  lv_fctlg-just          = fu_jstfy.
  lv_fctlg-currency      = fu_curky.
  lv_fctlg-datatype      = 'CURR'.
  APPEND lv_fctlg TO ft_fctlg.
ENDFORM.                    " F_ALV_CATALOG_CRNCY

*&---------------------------------------------------------------------*
*&      Form  F_ALV_CATALOG_EXPNT
*&---------------------------------------------------------------------*
FORM f_alv_catalog_expnt USING ft_fctlg TYPE slis_t_fieldcat_alv
                         fu_tbnam fu_fname fu_dscrp
                         fu_reftb fu_refld
                         fu_outln fu_decml fu_expnt fu_jstfy.
  DATA: lv_fctlg TYPE slis_fieldcat_alv,
        ld_lngth TYPE i.
  ld_lngth = strlen( fu_dscrp ).
  IF ld_lngth > 25.
    lv_fctlg-seltext_l   = fu_dscrp.
  ELSEIF ld_lngth > 10.
    lv_fctlg-seltext_l   = fu_dscrp.
    lv_fctlg-seltext_m   = fu_dscrp.
  ELSE.
    lv_fctlg-seltext_s   = fu_dscrp.
    lv_fctlg-seltext_m   = fu_dscrp.
    lv_fctlg-seltext_l   = fu_dscrp.
  ENDIF.

  lv_fctlg-tabname       = fu_tbnam.
  lv_fctlg-fieldname     = fu_fname.
  lv_fctlg-ref_tabname   = fu_reftb.
  lv_fctlg-ref_fieldname = fu_refld.
  lv_fctlg-outputlen     = fu_outln.
  lv_fctlg-decimals_out  = fu_decml.
  lv_fctlg-exponent      = fu_expnt.
  lv_fctlg-datatype      = 'FLTP'.
  lv_fctlg-just          = fu_jstfy.
  APPEND lv_fctlg TO ft_fctlg.
ENDFORM.                    " F_ALV_CATALOG_EXPNT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_F4
*&---------------------------------------------------------------------*
FORM f_alv_variant_f4 CHANGING fc_varnt.
  DATA: rs_variant LIKE disvariant.

  rs_variant-report   = d_alv_repid.
  rs_variant-username = sy-uname.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            is_variant = rs_variant
            i_save     = 'A'
       IMPORTING
            es_variant = rs_variant
       EXCEPTIONS
            OTHERS     = 1.
  IF sy-subrc = 0.
    fc_varnt = rs_variant-variant.
  ENDIF.
ENDFORM.                               " ALV_VARIANT_F4
