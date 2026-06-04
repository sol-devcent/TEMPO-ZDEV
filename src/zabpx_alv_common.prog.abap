*&---------------------------------------------------------------------*
*& Program Name     : ZABPX_ALV_COMMON                                 *
*& Author           : Aji (SAP_DEV02)                                  *
*& Create Date      : 19/09/2013                                       *
*& SAP Release      : ECC6                                             *
*& Description      : Common Include for Build ALV                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& ----           ----         ------         -----------              *
*& DEVK936275     19/09/13      Aji         Initial Creation           *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZABPX_ALV_COMMON
*&---------------------------------------------------------------------*
type-pools: slis.

*---------------------------------------------------------------------*
*     Data object declaration
*---------------------------------------------------------------------*
data: t_alv_fctlg type slis_t_fieldcat_alv,
      t_alv_event type slis_t_event with header line,
      t_alv_isort type slis_t_sortinfo_alv with header line,
      t_alv_extab type slis_t_extab with header line,
      t_alv_header    type slis_t_listheader,
      x_alv_varnt type disvariant,
      d_alv_sort_postn type i,
      d_alv_save(1) type c,
      d_alv_varnm like disvariant-variant,
      x_alv_qinfo type slis_keyinfo_alv,
      d_alv_stats type slis_formname,
      d_alv_ucomm type slis_formname,
      x_alv_print type slis_print_alv,
      d_alv_repid like sy-repid,
      d_alv_tabix like sy-tabix,
      d_alv_subrc like sy-subrc,
      d_alv_bg_id like bapibds01-objkey value 'ALV_BACKGROUND',
      d_alv_screen_start_column type i,
      d_alv_screen_start_line   type i,
      d_alv_screen_end_column   type i,
      d_alv_screen_end_line     type i,
      x_alv_layout type slis_layout_alv,
      p_vari like disvariant-variant,
      gt_alv_header type slis_t_listheader.

** Variant
*selection-screen begin of block 0 with frame title text-v01.
*parameters: p_vari like disvariant-variant.
*selection-screen end of block 0.
*
** Process on value request
*at selection-screen on value-request for p_vari.
*  perform f_alv_variant_f4 changing x_alv_varnt-variant.


*at selection-screen.
*  perform f_alv_selscr_input.

*&---------------------------------------------------------------------*
*&      FORM F_ALV_INIT
*&---------------------------------------------------------------------*
*       Initialize ALV variables
*----------------------------------------------------------------------*
form f_alv_init.
  d_alv_repid = sy-repid.
  d_alv_save = 'A'.
  x_alv_varnt-report = sy-repid.
endform. " f_alv_init

*---------------------------------------------------------------------*
*       FORM F_ALV_BUILD_COMMENT                                      *
*---------------------------------------------------------------------*
*       Build ALV Header                                              *
*---------------------------------------------------------------------*
form f_alv_build_comment tables ft_top_of_page type slis_t_listheader
                         using  fu_typ fu_key fu_info.

* fu_typ = H, S, or A.
*   H = Header (big), S = Selection (reg) , A = Action (small)
  ft_top_of_page-typ  = fu_typ.
  ft_top_of_page-key  = fu_key.
  ft_top_of_page-info = fu_info.
  append ft_top_of_page.

endform.

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE                                            *
*---------------------------------------------------------------------*
*       TOP-OF-PAGE                                                   *
*---------------------------------------------------------------------*
form f_top_of_page_alv.
  call function 'REUSE_ALV_COMMENTARY_WRITE'
       exporting
*            i_logo             = 'TRVPICTURE00'
            it_list_commentary = gt_alv_header.
endform. "F_TOP_OF_PAGE_ALV


*&---------------------------------------------------------------------*
*&      Form  F_ALV_BUILD_EVENT
*&---------------------------------------------------------------------*
*       Build ALV events (TOP-OF-PAGE, END-OF-PAGE, etc)
*----------------------------------------------------------------------*
form f_alv_build_event using fu_pname fu_pform.

  clear t_alv_event.
  t_alv_event-name = fu_pname.
  t_alv_event-form = fu_pform.
  append t_alv_event.
endform. " F_BUILD_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
*       Sort ALV catalog
*----------------------------------------------------------------------*
form f_alv_sort using fu_table fu_field fu_ascnd.
  data: lx_isort type slis_sortinfo_alv.
  d_alv_sort_postn = d_alv_sort_postn + 1.
  lx_isort-tabname   = fu_table.
  lx_isort-fieldname = fu_field.
  if fu_ascnd = 'X'.
    lx_isort-up      = 'X'.
  else.
    lx_isort-down    = 'X'.
  endif.
  lx_isort-spos      = d_alv_sort_postn.
  append lx_isort to t_alv_isort.
endform. " F_ALV_SORT

*---------------------------------------------------------------------*
*       FORM F_ALV_BUILD_KEY_INFO                                     *
*---------------------------------------------------------------------*
*       Build foreign key between Header & Detail                     *
*---------------------------------------------------------------------*
form f_alv_build_key_info using fu_header01 type slis_fieldname
                                fu_item01 type slis_fieldname
                                fu_header02 type slis_fieldname
                                fu_item02 type slis_fieldname
                                fu_header03 type slis_fieldname
                                fu_item03 type slis_fieldname
                                fu_header04 type slis_fieldname
                                fu_item04 type slis_fieldname
                                fu_header05 type slis_fieldname
                                fu_item05 type slis_fieldname.

  x_alv_qinfo-header01 = fu_header01.
  x_alv_qinfo-item01  = fu_item01.
  x_alv_qinfo-header02 = fu_header02.
  x_alv_qinfo-item02  = fu_item02.
  x_alv_qinfo-header03 = fu_header03.
  x_alv_qinfo-item03  = fu_item03.
  x_alv_qinfo-header04 = fu_header04.
  x_alv_qinfo-item04  = fu_item04.
  x_alv_qinfo-header05 = fu_header05.
  x_alv_qinfo-item05  = fu_item05.

endform.

*&---------------------------------------------------------------------*
*&      Form  F_ALV_BUILD_CATALOG
*&---------------------------------------------------------------------*
form f_alv_build_catalog using fu_tbnam
                               fu_fname
                               fu_dscrp
                               fu_reftb
                               fu_refld
                               fu_outln
                               fu_jstfy
                               fu_dosum
                               fu_invis.
  data: lx_fctlg type slis_fieldcat_alv.

  lx_fctlg-seltext_s     = fu_dscrp.
  lx_fctlg-seltext_m     = fu_dscrp.
  lx_fctlg-seltext_l     = fu_dscrp.
*  lx_fctlg-reptext_ddic  = fu_dscrp.
  lx_fctlg-tabname       = fu_tbnam.
  lx_fctlg-fieldname     = fu_fname.
  lx_fctlg-outputlen     = fu_outln.
  lx_fctlg-ref_tabname   = fu_reftb.
  lx_fctlg-ref_fieldname = fu_refld.
  lx_fctlg-just          = fu_jstfy.
  lx_fctlg-do_sum        = fu_dosum.
  lx_fctlg-no_out        = fu_invis.
  append lx_fctlg to t_alv_fctlg.
endform. " F_ALV_BUILD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_GET_CATALOG
*&---------------------------------------------------------------------*
* @FT_FCTLG = internal table to store field catalog result
* @FU_TABLE = internal table name
* @FU_STRCT = Table/Structure name
* description: Purpose to get field attribute from data dictionary
*              (Table/Structure) and save as ALV field catalog
form f_alv_get_catalog tables ft_fctlg type slis_t_fieldcat_alv
                       using  fu_table
                              fu_strct.
  data: ld_table type slis_tabname,
        ld_strct like dd02l-tabname,
        lt_fctlg type slis_t_fieldcat_alv.
  ld_table = fu_table.
  ld_strct = fu_strct.
  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
       exporting
            i_internal_tabname     = ld_table
            i_structure_name       = ld_strct
            i_bypassing_buffer     = 'X'
       changing
            ct_fieldcat            = lt_fctlg
       exceptions
            inconsistent_interface = 1
            program_error          = 2
            others                 = 3.
  if sy-subrc <> 0.
  endif.
  append lines of lt_fctlg to ft_fctlg.
endform. " F_GET_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_ALV_LIST_DISPLAY
*&---------------------------------------------------------------------*
*       Generate ALV classic display
*----------------------------------------------------------------------*
form f_alv_list_display tables ft_table
                        using  fu_table type slis_tabname.
  x_alv_varnt-report = d_alv_repid.
  call function 'REUSE_ALV_LIST_DISPLAY'
      exporting
            i_callback_program       = d_alv_repid
            i_callback_pf_status_set = d_alv_stats
            i_callback_user_command  = d_alv_ucomm
*           I_STRUCTURE_NAME         =
            is_layout                = x_alv_layout
            it_fieldcat              = t_alv_fctlg
            it_excluding             = t_alv_extab[]
            it_sort                  = t_alv_isort[]
            i_default                = 'X'
            i_save                   = space
            is_variant               = x_alv_varnt
            it_events                = t_alv_event[]
            is_print                 = x_alv_print
            i_screen_start_column    = d_alv_screen_start_column
            i_screen_start_line      = d_alv_screen_start_line
            i_screen_end_column      = d_alv_screen_end_column
            i_screen_end_line        = d_alv_screen_end_line
       tables
            t_outtab                 = ft_table[]
       exceptions
            program_error            = 1
            others                   = 2.
endform. " F_ALV_LIST_DISPLAY

*---------------------------------------------------------------------*
*       FORM F_ALV_GRID_DISPLAY                                       *
*---------------------------------------------------------------------*
*       Generate ALV grid display                                     *
*---------------------------------------------------------------------*
form f_alv_grid_display tables ft_table.
  x_alv_varnt-report = d_alv_repid.
  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
         i_callback_program       = d_alv_repid
         i_callback_pf_status_set = d_alv_stats
         i_callback_user_command  = d_alv_ucomm
*         i_background_id          = d_alv_bg_id
         is_layout                = x_alv_layout
         it_fieldcat              = t_alv_fctlg
         it_excluding             = t_alv_extab[]
         it_sort                  = t_alv_isort[]
         i_default                = 'X'
         i_save                   = d_alv_save
         is_variant               = x_alv_varnt
         it_events                = t_alv_event[]
         is_print                 = x_alv_print
         i_screen_start_column    = d_alv_screen_start_column
         i_screen_start_line      = d_alv_screen_start_line
         i_screen_end_column      = d_alv_screen_end_column
         i_screen_end_line        = d_alv_screen_end_line
    tables
         t_outtab                 = ft_table
    exceptions
         program_error            = 1
         others                   = 2.
endform. " F_ALV_GRID_DISPLAY


*&---------------------------------------------------------------------*
*&      Form  F_ALV_HIER_DISPLAY
*&---------------------------------------------------------------------*
*       Generate ALV hierarchical display (header & item level)
*----------------------------------------------------------------------*
form f_alv_hier_display tables ft_headr
                               ft_items
                        using  fu_headr type slis_tabname
                               fu_items type slis_tabname.
  x_alv_varnt-report = d_alv_repid.
  call function 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
       exporting
            i_callback_program       = d_alv_repid
            i_callback_pf_status_set = d_alv_stats
            i_callback_user_command  = d_alv_ucomm
            is_layout                = x_alv_layout
            i_save                   = space
            it_fieldcat              = t_alv_fctlg
            it_excluding             = t_alv_extab[]
            it_sort                  = t_alv_isort[]
            it_events                = t_alv_event[]
            is_variant               = x_alv_varnt
            i_tabname_header         = fu_headr
            i_tabname_item           = fu_items
            is_keyinfo               = x_alv_qinfo
            is_print                 = x_alv_print
            i_screen_start_column    = d_alv_screen_start_column
            i_screen_start_line      = d_alv_screen_start_line
            i_screen_end_column      = d_alv_screen_end_column
            i_screen_end_line        = d_alv_screen_end_line
       tables
            t_outtab_header          = ft_headr
            t_outtab_item            = ft_items
       exceptions
            program_error            = 1
            others                   = 2.
endform. " F_ALV_HIER_DISPLAY


*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_F4
*&---------------------------------------------------------------------*
form f_alv_variant_f4 changing fc_varnt.
  data: rs_variant like disvariant.
  rs_variant-report   = d_alv_repid.
  rs_variant-username = sy-uname.
  call function 'REUSE_ALV_VARIANT_F4'
       exporting
            is_variant = rs_variant
            i_save     = 'A'
       importing
            es_variant = rs_variant
       exceptions
            others     = 1.
  if sy-subrc = 0.
    fc_varnt = rs_variant-variant.
    p_vari = rs_variant-variant.
  endif.
endform. " ALV_VARIANT_F4

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SELSCR_INPUT
*&---------------------------------------------------------------------*
*       PAI of ALV selection screen
*----------------------------------------------------------------------*
form f_alv_selscr_input.
  data : rs_variant like disvariant.

  if not p_vari is initial.
    move x_alv_varnt to rs_variant.
    move p_vari to rs_variant-variant.
    call function 'REUSE_ALV_VARIANT_EXISTENCE'
         exporting
              i_save     = d_alv_save
         changing
              cs_variant = rs_variant.

    x_alv_varnt = rs_variant.
  else.
    clear x_alv_varnt.
    x_alv_varnt  = d_alv_repid.
  endif.

endform. " f_alv_selscr_input
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_build_print changing fc_print type slis_print_alv.

  fc_print-no_print_listinfos = 'X'.
  fc_print-no_print_selinfos = 'X'.
  fc_print-no_coverpage = 'X'.

endform. " F_BUILD_PRINT
