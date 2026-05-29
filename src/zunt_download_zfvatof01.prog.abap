*&---------------------------------------------------------------------*
*&  Include           ZDG2MM_I0007F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

  IF g_custom_container IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sortfield.
    PERFORM f_toolbar_excluding.

* Create_object_container
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.

* Create_object_grid
    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_custom_container.

* Create_display_ALV
    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_outtab            = gt_out[]
        it_sort              = gt_sort[].

* When edit display
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  ELSE.
    CALL METHOD g_grid->refresh_table_display( ).
  ENDIF.
ENDMODULE.                 " PBO100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR gt_fieldcat[].

  PERFORM f_fieldcatg USING 'GT_OUT':
*    'CHBOX' '' '' '' '3' 'Chk' '' '' '' '' '' '' '' 'X' '' '' '' 'X' '',
    'VKORG' 'ZFVATO' 'VKORG' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFVATO' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNRG' 'ZFVATO' 'KUNRG' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VATNO' 'ZFVATO' 'VATNO' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'ZFVATO' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' '' '' '' '' 'No.DN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUEYR' '' '' '' '' 'Year' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUDAT' 'ZFVATO' 'DUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELV' 'ZFVATO' 'VBELV' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VATPR' 'ZFVATO' 'VATPR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EBELN' 'EKBE' 'EBELN' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNR' '' '' '' '10' 'No.MIRO' '' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
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
                          value(fu_input)
                          value(fu_emphasize)
                          value(fu_hotspot)
                          value(fu_edit)
                          value(fu_no_zero).

  DATA: ld_fieldcat  TYPE  lvc_t_fcat WITH HEADER LINE.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-hotspot           = fu_hotspot.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-no_zero           = fu_no_zero.
  APPEND ld_fieldcat TO gt_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout-zebra       = 'X'.
  gs_layout-cwidth_opt  = 'X'.
  gs_layout-col_opt     = 'X'.
  gs_layout-no_headers  = space.
  gs_layout-no_rowmark  = 'X'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_sortfield .
  CLEAR gt_sort[].

  CLEAR gt_sort.
  gt_sort-spos      = '1'.
  gt_sort-fieldname = 'VKORG'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '2'.
  gt_sort-fieldname = 'VKBUR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '3'.
  gt_sort-fieldname = 'VATNO'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '4'.
  gt_sort-fieldname = 'VBELN'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '5'.
  gt_sort-fieldname = 'ZUONR'.
  APPEND gt_sort.

  CLEAR gt_sort.
  gt_sort-spos      = '6'.
  gt_sort-fieldname = 'DUEYR'.
  APPEND gt_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Module  PAI100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'ESC' OR 'CANC'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      LEAVE TO SCREEN 0.
    WHEN '&ALL'.
      PERFORM select_all_checkboxes.
    WHEN '&SAL'.
      PERFORM deselect_all_checkboxes.
    WHEN '&EXEC'.
      PERFORM f_execute.
  ENDCASE.
ENDMODULE.                 " PAI100  INPUT

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_CHECKBOXES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all_checkboxes .
*  gt_out-chbox = abap_true.
*  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_false.
*  CALL METHOD g_grid->refresh_table_display( ).
ENDFORM.                    " SELECT_ALL_CHECKBOXES

*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL_CHECKBOXES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deselect_all_checkboxes .
*  gt_out-chbox = abap_false.
*  MODIFY gt_out TRANSPORTING chbox WHERE chbox = abap_true.
*  CALL METHOD g_grid->refresh_table_display( ).
ENDFORM.                    " DESELECT_ALL_CHECKBOXES

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data .

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  DATA : BEGIN OF lt_out OCCURS 0,
           xblnr    TYPE xblnr1,
         END OF lt_out.

  SELECT vkorg vkbur kunrg vatno vbeln zuonr dueyr dudat vbelv vatpr
    INTO CORRESPONDING FIELDS OF TABLE gt_out FROM zfvato
    WHERE vkorg EQ p_vkorg
      AND vkbur IN s_vkbur
      AND vatno IN s_vatno
      AND vbeln IN s_vbeln
      AND zuonr IN s_zuonr
      AND dueyr IN s_dueyr
      AND fkdat IN s_fkdat
      AND kunrg IN s_kunrg.
  IF sy-subrc EQ 0.
    LOOP AT gt_out.
      lt_out-xblnr  = gt_out-zuonr.
      APPEND lt_out.
    ENDLOOP.
    SORT lt_out BY xblnr.
    DELETE ADJACENT DUPLICATES FROM lt_out COMPARING xblnr.

    IF lt_out[] IS NOT INITIAL.
*      SELECT DISTINCT ebeln ebelp zekkn vgabe gjahr belnr buzei xblnr shkzg
*        INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
*        FROM ekbe FOR ALL ENTRIES IN lt_out
*        WHERE xblnr EQ lt_out-xblnr
*          AND vgabe EQ '2'.
      SELECT DISTINCT ebeln ebelp zekkn vgabe a~gjahr a~belnr buzei a~xblnr shkzg
        INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
        FROM ekbe AS a JOIN rbkp AS b ON a~belnr = b~belnr AND
                                         a~gjahr = b~gjahr
        FOR ALL ENTRIES IN lt_out
        WHERE a~xblnr EQ lt_out-xblnr
          AND vgabe EQ '2'
          AND stblg = space.
    ENDIF.

*    SELECT DISTINCT vbeln posnr vgbel
*      INTO CORRESPONDING FIELDS OF TABLE gt_lips
*      FROM lips FOR ALL ENTRIES IN gt_out
*      WHERE vbeln EQ gt_out-zuonr.
*    IF sy-subrc EQ 0.
*      SELECT DISTINCT ebeln ebelp zekkn vgabe gjahr belnr buzei
*        INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
*        FROM ekbe FOR ALL ENTRIES IN gt_lips
*        WHERE ebeln EQ gt_lips-vgbel
*          AND vgabe EQ '2'.
*    ENDIF.
  ELSE.
    MESSAGE 'No data' TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data .
  DATA : lv_xblnr   TYPE xblnr1.

  SORT gt_out BY zuonr.
  SORT gt_lips BY vbeln.
  SORT gt_ekbe BY ebeln belnr DESCENDING.

  LOOP AT gt_out ASSIGNING <fs_out>.
    CLEAR: gt_lips,gt_ekbe,lv_xblnr.
*    READ TABLE gt_lips WITH KEY vbeln = <fs_out>-zuonr BINARY SEARCH.
*    IF sy-subrc NE 0.
*      SORT gt_lips BY vbeln.
*      READ TABLE gt_lips WITH KEY vbeln = <fs_out>-zuonr BINARY SEARCH.
*    ENDIF.
*
*    READ TABLE gt_ekbe WITH KEY ebeln = gt_lips-vgbel BINARY SEARCH.
*    IF sy-subrc NE 0.
*      SORT gt_ekbe BY ebeln.
*      READ TABLE gt_ekbe WITH KEY ebeln = gt_lips-vgbel BINARY SEARCH.
*    ENDIF.

    lv_xblnr = <fs_out>-zuonr.

    READ TABLE gt_ekbe WITH KEY xblnr = lv_xblnr.
*    IF sy-subrc NE 0.
*      SORT gt_ekbe BY ebeln.
*      READ TABLE gt_ekbe WITH KEY ebeln = gt_lips-vgbel BINARY SEARCH.
*    ENDIF.

    <fs_out>-ebeln = gt_ekbe-ebeln.

    IF gt_ekbe-shkzg = 'S'.
      <fs_out>-belnr = gt_ekbe-belnr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory .

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_toolbar_excluding .
  DATA ls_exclude TYPE ui_func.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND ls_exclude TO gt_exclude.
ENDFORM.                    " F_TOOLBAR_EXCLUDING

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'MO1'.
        screen-invisible = '0'.
        screen-input     = '1'.
        MODIFY SCREEN.
      WHEN 'MO2'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
      WHEN 'MO3'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
      WHEN 'MO4'.
        screen-invisible = '1'.
        screen-input     = '0'.
        MODIFY SCREEN.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : name(20),
         ext(20).

*  IF s_matnr[] IS INITIAL.
*    MESSAGE 'Please input material number' TYPE 'I'.
*    RETURN.
*  ENDIF.
  IF filename IS NOT INITIAL.
    SPLIT filename AT '.' INTO name ext.
    TRANSLATE ext TO UPPER CASE.
    IF ext <> 'XLS' AND
      ext <> 'XLSX'.
      MESSAGE e000(zab) WITH 'Data must in excel format'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_EXECUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_execute .
  LOOP AT gt_out.
    gt_download-zuonr = gt_out-zuonr.
    gt_download-vbeln = gt_out-vbeln.
    gt_download-belnr = gt_out-belnr.
    gt_download-gjahr = gt_out-dueyr.
    PERFORM f_modify USING gt_out-vatpr
                     CHANGING gt_download-alloc_nmbr.
    PERFORM f_date_modify USING gt_out-dudat
                          CHANGING gt_download-fkdat.
    APPEND gt_download.
  ENDLOOP.

  CONCATENATE folder '\' filename INTO gv_filename.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = gv_filename
      filetype                = 'DBF'
    TABLES
      data_tab                = gt_download
      fieldnames              = download_field
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
ENDFORM.                    " F_EXECUTE

*&---------------------------------------------------------------------*
*&      Form  F_FOLDER_F4
*&---------------------------------------------------------------------*
FORM f_folder_f4  CHANGING fc_filename.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'File Directory'
      initial_folder  = 'C:'
    CHANGING
      selected_folder = gv_path.

  CALL METHOD cl_gui_cfw=>flush.

  CONCATENATE gv_path '' INTO fc_filename.
ENDFORM.                    " F_FOLDER_F4

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DWNFIELD
*&---------------------------------------------------------------------*
FORM f_crt_dwnfield .
  download_field-txt_field = 'No.DN'.
  APPEND download_field.
  download_field-txt_field = 'No.Billing'.
  APPEND download_field.
  download_field-txt_field = 'No.MIRO'.
  APPEND download_field.
  download_field-txt_field = 'Year'.
  APPEND download_field.
  download_field-txt_field = 'No.FP'.
  APPEND download_field.
  download_field-txt_field = 'Tgl.FP'.
  APPEND download_field.
ENDFORM.                    " F_CRT_DWNFIELD

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY
*&---------------------------------------------------------------------*
FORM f_modify  USING    fu_value
               CHANGING fc_value.
  DATA : lv_value(20),
         lv_subrc   TYPE sy-subrc.

  lv_value  = fu_value.

  REPLACE '-' WITH space INTO lv_value.

  WHILE lv_subrc IS INITIAL.
    REPLACE '.' WITH space INTO lv_value.
    lv_subrc  = sy-subrc.
  ENDWHILE.

  CONDENSE lv_value NO-GAPS.
  fc_value  = lv_value.

ENDFORM.                    " F_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_DATE_MODIFY
*&---------------------------------------------------------------------*
FORM f_date_modify  USING    fu_value
                    CHANGING fc_value.
  CONCATENATE fu_value+6(2) fu_value+4(2) fu_value(4)
  INTO fc_value
  SEPARATED BY '.'.
ENDFORM.                    " F_DATE_MODIFY
