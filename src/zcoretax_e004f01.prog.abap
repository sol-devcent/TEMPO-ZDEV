*&---------------------------------------------------------------------*
*&  Include           ZCORETAX_E004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_hkont       LIKE LINE OF gr_hkont,
         ls_zgdtxdt0104 LIKE LINE OF gt_zgdtxdt0104,
         ls_blart       LIKE LINE OF gr_blart.

  SELECT *
    FROM zgdtxdt0104
    INTO CORRESPONDING FIELDS OF TABLE gt_zgdtxdt0104
    WHERE bukrs = pa_bukrs.

  LOOP AT gt_zgdtxdt0104 INTO ls_zgdtxdt0104.
    ls_blart-low    = ls_zgdtxdt0104-blart.
    ls_blart-sign   = 'I'.
    ls_blart-option = 'EQ'.
    APPEND ls_blart TO gr_blart.
    CLEAR ls_blart.
  ENDLOOP.

  ls_hkont-low    = '065*'.
  ls_hkont-sign   = 'I'.
  ls_hkont-option = 'CP'.
  APPEND ls_hkont TO gr_hkont.
  CLEAR ls_hkont.

  SELECT *
    FROM zfvattrn
    INTO CORRESPONDING FIELDS OF TABLE gt_zfvattrn
    WHERE vkorg = pa_bukrs.

  SELECT *
    FROM zcoretax0010
    INTO CORRESPONDING FIELDS OF TABLE gt_010
    WHERE coretype = 'NT'
      AND bukrs = pa_bukrs.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'STK' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'SKD' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'SVF' '0' '' '' '',
                                      'SFK' '0' '' '' '',
                                      'SVL' '0' '' '' '',
                                      'STX' '0' '' '' '',
                                      'SKD' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'SKU' '0' '' '' '',
                                      'SVL' '0' '' '' '',
                                      'STX' '0' '' '' '',
                                      'STK' '0' '' '' '',
                                      'SER' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_message USING 'PBU' ''.
  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory TYPE string,
         filetable TYPE filetable,
         line      TYPE LINE OF filetable,
         rc        TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir = directory.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'Select the files'
      initial_directory = directory
      file_filter       = '*.*'
      multiselection    = ' '
    CHANGING
      file_table        = filetable
      rc                = rc.
  IF rc = 1.
    READ TABLE filetable INDEX 1 INTO line.
    fc_fname = line-filename.
  ENDIF.
ENDFORM.                    " F_F4_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

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

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_008   TYPE STANDARD TABLE OF ty_008,
         lr_bbill TYPE RANGE OF zdg2fide0005,
         ls_bbill LIKE LINE OF lr_bbill,
         lt_sd004 TYPE STANDARD TABLE OF zcdssd_004.

  DATA : lv_gjahr TYPE bkpf-gjahr,
         lv_gsber TYPE bseg-gsber.

  PERFORM f_customer_pindah.

  CASE 'X'.
    WHEN radio1.
      lv_gjahr  = so_fkdat-low(4).

      CASE pa_bukrs.
        WHEN '8330'.
          SELECT *
            FROM zcdssd_004
            INTO CORRESPONDING FIELDS OF TABLE gt_sd004
            WHERE vbeln     IN so_vbevf
              AND fkdat     IN so_fkdat
              AND bukrs     = pa_bukrs
              AND kunrg     IN so_kunrg
              AND werks     IN so_vkbur
              AND vgbel     IN so_vbevl.

        WHEN '8020'.
          SELECT *
            FROM zcdssd_004
            INTO CORRESPONDING FIELDS OF TABLE gt_sd004
            WHERE vbeln     IN so_vbevf
              AND fkdat     IN so_fkdat
              AND bukrs     = pa_bukrs
              AND kunrg     IN so_kunrg
              AND vgbel     IN so_vbevl.

          PERFORM f_modify_004.

        WHEN OTHERS.
          SELECT *
            FROM zcdssd_004
            INTO CORRESPONDING FIELDS OF TABLE gt_sd004
            WHERE vbeln     IN so_vbevf
              AND fkdat     IN so_fkdat
              AND bukrs     = pa_bukrs
              AND kunrg     IN so_kunrg
              AND vkbur     IN so_vkbur
              AND vgbel     IN so_vbevl.
      ENDCASE.

      IF gt_zfarsoff[] IS NOT INITIAL.
        PERFORM f_validate_customer USING '-'.
        PERFORM f_validate_customer USING '+'.
      ENDIF.

      lt_sd004[] = gt_sd004[].
      SORT lt_sd004 BY vgbel.
      DELETE ADJACENT DUPLICATES FROM lt_sd004 COMPARING vgbel.
      IF lt_sd004[] IS NOT INITIAL.
        SELECT *
          FROM likp
          INTO CORRESPONDING FIELDS OF TABLE gt_likp
          FOR ALL ENTRIES IN lt_sd004
          WHERE vbeln = lt_sd004-vgbel.

        SELECT *
          FROM zmm_cust_rec
          INTO CORRESPONDING FIELDS OF TABLE gt_custrec
          FOR ALL ENTRIES IN lt_sd004
          WHERE vbeln = lt_sd004-vgbel.
      ENDIF.

      CASE pa_bukrs.
        WHEN '8020'.
          lv_gsber = '0200'.

          SELECT *
            FROM zcdsfi_001
            INTO CORRESPONDING FIELDS OF TABLE gt_fi001
            WHERE bukrs = pa_bukrs
              AND belnr IN so_vbevf
              AND gjahr = lv_gjahr
              AND budat IN so_fkdat
              AND blart IN gr_blart
              AND gsber = lv_gsber
              AND kunnr IN so_kunrg.

        WHEN '8070'.
          lv_gsber = '0700'.

          SELECT *
            FROM zcdsfi_001
            INTO CORRESPONDING FIELDS OF TABLE gt_fi001
            WHERE bukrs = pa_bukrs
              AND belnr IN so_vbevf
              AND gjahr = lv_gjahr
              AND budat IN so_fkdat
              AND blart IN gr_blart
              AND gsber = lv_gsber
              AND kunnr IN so_kunrg.

        WHEN OTHERS.
          SELECT *
            FROM zcdsfi_001
            INTO CORRESPONDING FIELDS OF TABLE gt_fi001
            WHERE bukrs = pa_bukrs
              AND belnr IN so_vbevf
              AND gjahr = lv_gjahr
              AND budat IN so_fkdat
              AND blart IN gr_blart
              AND gsber IN so_vkbur
              AND kunnr IN so_kunrg.
      ENDCASE.

    WHEN radio2.
      lv_gjahr  = so_erdat-low(4).

      CASE pa_bukrs.
        WHEN '8020'.
          SELECT *
            FROM zcdssd_002
            INTO CORRESPONDING FIELDS OF TABLE gt_sd002
            WHERE bukrs = pa_bukrs
              AND tknum IN so_tknum
              AND mjahr = lv_gjahr
              AND datbg IN so_erdat
              AND umwrk IN so_vkbur
              AND kunnr IN so_kunrg.

        WHEN OTHERS.
          SELECT *
            FROM zcdssd_002
            INTO CORRESPONDING FIELDS OF TABLE gt_sd002
            WHERE bukrs = pa_bukrs
              AND tknum IN so_tknum
              AND mjahr = lv_gjahr
              AND erdat IN so_erdat
              AND umwrk IN so_vkbur
              AND kunnr IN so_kunrg.
      ENDCASE.

    WHEN radio3.
      CASE pa_bukrs.
        WHEN '8210'.
          IF so_vbevf[] IS NOT INITIAL.
            LOOP AT so_vbevf.
              ls_bbill-low    = so_vbevf-low+6(4).
              IF so_vbevf-high IS NOT INITIAL.
                ls_bbill-high   = so_vbevf-high+6(4).
              ENDIF.
              ls_bbill-sign   = so_vbevf-sign.
              ls_bbill-option = so_vbevf-option.
              APPEND ls_bbill TO lr_bbill.
              CLEAR ls_bbill.
            ENDLOOP.
          ENDIF.

          SELECT bukrs bbill bidat monat gjahr zzkdctr zzkunn2 kode_ae
            p_name1 zzcur nilai_dpp nilai_ppn
            FROM zdg3fidt0008
            INTO CORRESPONDING FIELDS OF TABLE gt_008
            WHERE zzkdctr IN so_kdctr
              AND bukrs   = pa_bukrs
              AND bbill   IN lr_bbill
              AND bidat   IN so_fkdat
              AND status  <> 'C'.

        WHEN '8220'.
          IF so_vbevf[] IS NOT INITIAL.
            LOOP AT so_vbevf.
              ls_bbill-low    = so_vbevf-low+4(6).
              IF so_vbevf-high IS NOT INITIAL.
                ls_bbill-high   = so_vbevf-high+4(6).
              ENDIF.
              ls_bbill-sign   = so_vbevf-sign.
              ls_bbill-option = so_vbevf-option.
              APPEND ls_bbill TO lr_bbill.
              CLEAR ls_bbill.
            ENDLOOP.
          ENDIF.

          SELECT bukrs bbill bidat monat gjahr zzkdctr zzkunn2 kode_ae
            p_name1 zzcur nilai_dpp nilai_ppn
            FROM zdg2fidt0008
            INTO CORRESPONDING FIELDS OF TABLE gt_008
            WHERE zzkdctr IN so_kdctr
              AND bukrs   = pa_bukrs
              AND bbill   IN lr_bbill
              AND bidat   IN so_fkdat
              AND status  <> 'C'.
      ENDCASE.

      lt_008[] = gt_008[].
      SORT lt_008 BY zzkunn2.
      DELETE ADJACENT DUPLICATES FROM lt_008 COMPARING zzkunn2.
      IF lt_008[] IS NOT INITIAL.
        SELECT kunnr kna1~name1 stceg stcd5 gform name_co
          str_suppl1 str_suppl2 str_suppl3 city1
*          stcd1 stcd3 counc cityc stcd6
          FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
          INTO CORRESPONDING FIELDS OF TABLE gt_kna1
          FOR ALL ENTRIES IN lt_008
          WHERE kunnr = lt_008-zzkunn2.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_radio1_process.
    WHEN radio2.
      PERFORM f_radio2_process.
    WHEN radio3.
      PERFORM f_radio3_process.
  ENDCASE.

  ASSIGN gt_out TO <fs_out>.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF gt_out[] IS NOT INITIAL.
    CALL SCREEN 101.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  IF gt_bapiret2[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ENDIF.

  APPEND '&POS' TO fcode.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  SET TITLEBAR 'TITLE'.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm  TYPE sy-ucomm,
         lv_valid  TYPE c,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&ALL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CALL METHOD g_tabgrid->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_posting_data.
      ENDIF.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      gt_xout[] = gt_out[].

    WHEN '&ILT'.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      CLEAR : gt_filter[].
      CALL METHOD g_tabgrid->get_filtered_entries
        IMPORTING
          et_filtered_entries = lt_fidx.

      IF lt_fidx[] IS INITIAL.
        PERFORM f_select USING ''.
      ELSE.
        LOOP AT lt_fidx INTO ls_fidx.
          ls_filter-index = ls_fidx.
          APPEND ls_filter TO gt_filter.
        ENDLOOP.
      ENDIF.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain01.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report  = gv_repid.
    gs_variant-variant = pa_vari.

    SET HANDLER event_receiver->handle_double_click
                event_receiver->handle_toolbar
                event_receiver->handle_menu_button
                event_receiver->handle_user_command FOR g_tabgrid.

    CALL METHOD g_tabgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_out>[]
        it_fieldcatalog      = gt_main_fieldcat[].

    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-sel_mode            = selected.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-stylefname          = 'STYLE'.
  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
*  gs_layout_alv-totals_bef          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

*  PERFORM f_alv_sort USING : 1 'TKNUM' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
  DATA : lr_tabdescr  TYPE REF TO cl_abap_structdescr,
         lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data,
         lt_dfies     TYPE ddfields,
         ls_dfies     TYPE dfies,
         ls_fieldcat  TYPE lvc_s_fcat.

  CLEAR gt_main_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE 'X'.
      WHEN radio1.
        CASE ls_dfies-fieldname.
          WHEN 'TKNUM' OR 'ERDAT' OR 'ZZKDCTR' OR 'LFDAT'.
            CONTINUE.
        ENDCASE.
      WHEN radio2.
        CASE ls_dfies-fieldname.
          WHEN 'VBELN' OR 'FKDAT' OR 'VGBEL' OR 'LFDAT' OR 'ZZKDCTR' OR
            'WADAT_IST'.
            CONTINUE.
        ENDCASE.
      WHEN radio3.
        CASE ls_dfies-fieldname.
          WHEN 'TKNUM' OR 'ERDAT' OR 'VGBEL' OR 'LFDAT' OR 'WADAT_IST'.
            CONTINUE.
        ENDCASE.
    ENDCASE.

    CASE ls_dfies-fieldname.
      WHEN 'MARK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VGBEL'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'DN No.' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'WADAT_IST'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'DN Date' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ERDAT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Shipment Date' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'KUNRG'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Customer' '' '' '' '' '' '' 'X' '' '' '' 'C111'
        CHANGING ls_fieldcat.
      WHEN 'ZZKDCTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Kode Counter' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'NITKU'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'NITKU' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'TAXCODE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'TxCode' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VATPR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FP No.' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DPPGL'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'DPP GL' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PPNGL'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'PPN GL' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'TAXBASE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Tax Base' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'OTAXBASE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Other Tax Base' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VAT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' 'VAT' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VATRATE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'VAT Rate' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'FILENAME'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Filename' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PDFFILE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'PDF File' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BUKRS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' 'C111'
        CHANGING ls_fieldcat.
      WHEN 'VKBUR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' 'C111'
        CHANGING ls_fieldcat.
      WHEN 'VBELN'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' 'C111'
        CHANGING ls_fieldcat.

      WHEN 'MENGE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DMBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' ''
        CHANGING ls_fieldcat.
    ENDCASE.
    APPEND ls_fieldcat TO gt_main_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.

  ls_dyn_fcat-fieldname   = fu_fieldname.
  ls_dyn_fcat-tabname     = fu_tabname.
  ls_dyn_fcat-currency    = fu_currency.
  ls_dyn_fcat-cfieldname  = fu_cfieldname.
  ls_dyn_fcat-quantity    = fu_quantity.
  ls_dyn_fcat-qfieldname  = fu_qfieldname.
  ls_dyn_fcat-checkbox    = fu_checkbox.
  ls_dyn_fcat-ref_field   = fu_ref_field.
  ls_dyn_fcat-ref_table   = fu_ref_table.
  ls_dyn_fcat-coltext     = fu_coltext.
  ls_dyn_fcat-edit        = fu_edit.
  ls_dyn_fcat-outputlen   = fu_outputlen.
  ls_dyn_fcat-inttype     = fu_inttype.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-key         = fu_key.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  ls_dyn_fcat-do_sum      = fu_sum.
  ls_dyn_fcat-no_sum      = fu_nosum.
  APPEND ls_dyn_fcat TO gt_main_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  USING    fu_spos fu_fieldname fu_up fu_down fu_subtot.

  gt_main_sort-spos      = fu_spos.
  gt_main_sort-fieldname = fu_fieldname.
  gt_main_sort-up        = fu_up.
  gt_main_sort-down      = fu_down.
  gt_main_sort-subtot    = fu_subtot.
  APPEND gt_main_sort.
  CLEAR gt_main_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
*  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
*  DATA : lv_style    TYPE lvc_s_styl-style,
*         lt_stylerow TYPE lvc_t_styl,
*         ls_stylerow TYPE lvc_s_styl,
*         lv_tabix    TYPE sy-tabix,
*         ls_filter   LIKE LINE OF gt_filter.
*
*  DATA : ls_out             LIKE LINE OF gt_out.
*
*  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
*    IMPORTING
*      et_fieldcatalog = ls_fieldcatalog[].
*
*  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
*  IF sy-subrc = 0.
*    IF ls_fieldcatalog-edit IS NOT INITIAL.
*      LOOP AT gt_out INTO ls_out.
*        lv_tabix = sy-tabix.
*
*        READ TABLE ls_out-style INTO ls_stylerow
*                                WITH KEY fieldname = 'MARK'.
*        IF sy-subrc = 0 AND
*            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*          CONTINUE.
*        ENDIF.
*
*        IF fu_check IS NOT INITIAL.
*          CLEAR ls_filter.
*          READ TABLE gt_filter INTO ls_filter
*                               WITH KEY index = lv_tabix.
*          IF sy-subrc = 0.
*            CONTINUE.
*          ENDIF.
*        ENDIF.
*
*        ls_out-mark = fu_check.
*        MODIFY gt_out FROM ls_out.
*        CLEAR ls_out.
*      ENDLOOP.
*    ENDIF.
*    PERFORM f_alv_refresh USING 'X'.
*  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tabgrid IS NOT INITIAL.
      CALL METHOD g_tabgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_out   TYPE STANDARD TABLE OF ty_out.

  lt_out[] = gt_out[].
  IF lt_out[] IS NOT INITIAL.

  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum fu_emphasize
                            CHANGING fs_dyn_fcat  TYPE lvc_s_fcat.

  IF fu_coltext IS NOT INITIAL.
    PERFORM f_isi_judul USING fu_coltext '' '' ''
                        CHANGING fs_dyn_fcat-reptext fs_dyn_fcat-scrtext_l
                                 fs_dyn_fcat-scrtext_m fs_dyn_fcat-scrtext_s.
  ENDIF.

  PERFORM f_move_fieldcat USING fu_currency
                          CHANGING fs_dyn_fcat-currency.
  PERFORM f_move_fieldcat USING fu_cfieldname
                          CHANGING fs_dyn_fcat-cfieldname.
  PERFORM f_move_fieldcat USING fu_quantity
                          CHANGING fs_dyn_fcat-quantity.
  PERFORM f_move_fieldcat USING fu_qfieldname
                          CHANGING fs_dyn_fcat-qfieldname.
  PERFORM f_move_fieldcat USING fu_checkbox
                          CHANGING fs_dyn_fcat-checkbox.
  PERFORM f_move_fieldcat USING fu_edit
                          CHANGING fs_dyn_fcat-edit.
  PERFORM f_move_fieldcat USING fu_outputlen
                          CHANGING fs_dyn_fcat-outputlen.
  PERFORM f_move_fieldcat USING fu_inttype
                          CHANGING fs_dyn_fcat-inttype.
  PERFORM f_move_fieldcat USING fu_no_out
                          CHANGING fs_dyn_fcat-no_out.
  PERFORM f_move_fieldcat USING fu_tech
                          CHANGING fs_dyn_fcat-tech.
  PERFORM f_move_fieldcat USING fu_key
                          CHANGING fs_dyn_fcat-key.
  PERFORM f_move_fieldcat USING fu_fix
                          CHANGING fs_dyn_fcat-fix_column.
  PERFORM f_move_fieldcat USING fu_icon
                          CHANGING fs_dyn_fcat-icon.
  PERFORM f_move_fieldcat USING fu_sum
                          CHANGING fs_dyn_fcat-do_sum.
  PERFORM f_move_fieldcat USING fu_nosum
                          CHANGING fs_dyn_fcat-no_sum.
  PERFORM f_move_fieldcat USING fu_emphasize
                          CHANGING fs_dyn_fcat-emphasize.
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_move_fieldcat  USING    fu_value
                      CHANGING fc_value.
  IF fu_value IS NOT INITIAL.
    fc_value = fu_value.
  ENDIF.
ENDFORM.                    " F_MOVE_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CALC_VALUE
*&---------------------------------------------------------------------*
FORM f_calc_value  USING    fu_belnr
                   CHANGING fc_dppgl fc_ppngl fc_taxbase fc_otaxbase
                            fc_vat fc_vatrate.
  DATA : ls_fi001       LIKE LINE OF gt_fi001,
         ls_zgdtxdt0104 LIKE LINE OF gt_zgdtxdt0104,
         ls_010         LIKE LINE OF gt_010.

  DATA : lv_dmbtr TYPE bseg-dmbtr,
         lv_dppgl TYPE bseg-dmbtr.

  LOOP AT gt_fi001 INTO ls_fi001 WHERE belnr = fu_belnr.
    CLEAR ls_zgdtxdt0104.
    READ TABLE gt_zgdtxdt0104 INTO ls_zgdtxdt0104
                              WITH KEY hkont = ls_fi001-hkont.
    IF sy-subrc = 0.
      ADD ls_fi001-dmbtr TO lv_dmbtr.
    ENDIF.

    CLEAR ls_010.
    READ TABLE gt_010 INTO ls_010
                      WITH KEY hkont = ls_fi001-hkont
                               shkzg = ls_fi001-shkzg.
    IF sy-subrc = 0.
      ADD ls_fi001-dmbtr TO lv_dppgl.
    ENDIF.
  ENDLOOP.

*  PERFORM f_calculate USING lv_dmbtr lv_dppgl
*                      CHANGING fc_dppgl fc_taxbase fc_ppngl
*                               fc_vatrate fc_otaxbase fc_vat.

  PERFORM f_new_calculate USING lv_dmbtr lv_dppgl
                          CHANGING fc_dppgl fc_taxbase fc_ppngl
                                   fc_vatrate fc_otaxbase fc_vat.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_LAST_DAY
*&---------------------------------------------------------------------*
FORM f_last_day  USING    fu_date
                 CHANGING fc_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fu_date
    IMPORTING
      last_day_of_month = fc_date
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_RADIO1_PROCESS
*&---------------------------------------------------------------------*
FORM f_radio1_process .
  DATA : "ls_sd001       LIKE LINE OF gt_sd001,
    ls_fi001       LIKE LINE OF gt_fi001,
    ls_out         LIKE LINE OF gt_out,
    lt_xsd004      TYPE STANDARD TABLE OF zcdssd_004,
    ls_xsd004      LIKE LINE OF lt_xsd004,
    lt_xfi001      TYPE STANDARD TABLE OF zcdsfi_001,
    ls_xfi001      LIKE LINE OF lt_xfi001,
    ls_zgdtxdt0104 LIKE LINE OF gt_zgdtxdt0104,
    lt_005         TYPE STANDARD TABLE OF zcoretax0005,
    ls_005         LIKE LINE OF lt_005,
    ls_zfvattrn    LIKE LINE OF gt_zfvattrn,
    ls_custrec     LIKE LINE OF gt_custrec,
    ls_likp        LIKE LINE OF gt_likp,
    lt_zfvato      TYPE STANDARD TABLE OF zfvato,
    ls_zfvato      LIKE LINE OF lt_zfvato.

  DATA : lv_discount TYPE vbrp-kzwi2,
         lv_subrc    TYPE sy-subrc.

  lt_xsd004[] = gt_sd004.
  SORT lt_xsd004 BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xsd004 COMPARING vbeln.
  lt_xfi001[] = gt_fi001.
  DELETE lt_xfi001 WHERE kunnr IS INITIAL.
  SORT lt_xfi001 BY belnr.
  DELETE ADJACENT DUPLICATES FROM lt_xfi001 COMPARING belnr.

  IF lt_xsd004[] IS NOT INITIAL.
    SELECT *
      FROM zcoretax0005
      INTO CORRESPONDING FIELDS OF TABLE lt_005
      FOR ALL ENTRIES IN lt_xsd004
      WHERE bukrs = pa_bukrs
        AND masatx = lt_xsd004-fkdat(6)
        AND belnr = lt_xsd004-vbeln.

    SELECT *
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE lt_zfvato
      FOR ALL ENTRIES IN lt_xsd004
      WHERE vkorg = pa_bukrs
*        AND vkbur = lt_xsd004-vkbur
        AND vbeln = lt_xsd004-vbeln.
  ENDIF.

  IF lt_xfi001[] IS NOT INITIAL.
    SELECT *
      FROM zcoretax0005
      APPENDING CORRESPONDING FIELDS OF TABLE lt_005
      FOR ALL ENTRIES IN lt_xfi001
      WHERE bukrs = pa_bukrs
        AND masatx = lt_xfi001-budat(6)
        AND belnr = lt_xfi001-belnr.

    SELECT *
      FROM zfvato
      APPENDING CORRESPONDING FIELDS OF TABLE lt_zfvato
      FOR ALL ENTRIES IN lt_xfi001
      WHERE vkorg = pa_bukrs
        AND vbeln = lt_xfi001-belnr.
  ENDIF.

  IF lt_xsd004[] IS NOT INITIAL.
    SELECT * FROM zfvatdtbuyer FOR ALL ENTRIES IN @lt_xsd004
      WHERE vkorg = @lt_xsd004-bukrs
        AND vkbur = @lt_xsd004-vkbur
        AND vbeln = @lt_xsd004-vbeln
        AND kunrg = @lt_xsd004-kunrg
      INTO TABLE @DATA(lt_zfvatdtbuyer).
  ENDIF.

  LOOP AT lt_xsd004 INTO ls_xsd004.
    IF ls_xsd004-vbtyp = '6' AND
      ls_xsd004-sfakn IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING ls_xsd004 TO ls_out.
    IF pa_bukrs = '8330'.
      ls_out-vkbur = ls_xsd004-werks.
    ENDIF.
*    ls_out-taxcode  = '04'.
    CLEAR ls_zfvattrn.
    READ TABLE gt_zfvattrn INTO ls_zfvattrn
                           WITH KEY vkbur = ls_out-vkbur
                                    gform = ls_xsd004-gform.
    IF sy-subrc = 0.
      IF ls_zfvattrn-vattrn = '01'.
        ls_out-taxcode  = '04'.
      ELSE.
        ls_out-taxcode  = ls_zfvattrn-vattrn.
      ENDIF.
    ENDIF.

    ls_out-waers    = ls_xsd004-waerk.
    ls_out-nitku    = ls_xsd004-stcd5.

    ls_out-taxbase  = ls_xsd004-netwr * 100.
    ls_out-ppngl    = ls_xsd004-mwsbk.
    ls_out-dppgl    = ls_xsd004-netwr.
    IF p_check IS INITIAL.
      ls_out-vatrate  = '11'.
      CLEAR ls_out-otaxbase.
      ls_out-vat      = ls_xsd004-mwsbk.
    ELSE.
      ls_out-vatrate  = '12'.
      ls_out-otaxbase = ls_out-taxbase * 11 / ls_out-vatrate.
      ls_out-vat      = ( ls_out-otaxbase * ls_out-vatrate / 100 ) / 100.
    ENDIF.

    CLEAR ls_005.
    READ TABLE lt_005 INTO ls_005
                      WITH KEY belnr = ls_xsd004-vbeln.
    IF sy-subrc = 0.
      ls_out-vatpr    = ls_005-fakturno.
      ls_out-filename = ls_005-files.
      ls_out-pdffile  = ls_005-zfilename.
    ENDIF.

    CLEAR ls_likp.
    READ TABLE gt_likp INTO ls_likp
                       WITH KEY vbeln = ls_xsd004-vgbel.
    IF sy-subrc = 0.
      ls_out-txdat      = ls_likp-wadat_ist.
      ls_out-wadat_ist  = ls_likp-wadat_ist.
    ENDIF.

*    READ TABLE gt_kna1 INTO DATA(ls_kna1)
*                       WITH KEY kunnr = ls_out-kunrg.
*    IF sy-subrc = 0.
*      ls_out-stceg    = ls_kna1-stceg.
*      ls_out-nitku    = ls_kna1-stcd5.
*      ls_out-stcd1    = ls_kna1-stcd1.
*      ls_out-stcd3    = ls_kna1-stcd3.
*      ls_out-counc    = ls_kna1-counc.
*      ls_out-cityc    = ls_kna1-cityc.
*      ls_out-stcd6    = ls_kna1-stcd6.
*    ENDIF.
    IF ls_xsd004-lgort = '1000'.
      CLEAR ls_custrec.
      READ TABLE gt_custrec INTO ls_custrec
                            WITH KEY vbeln = ls_xsd004-vgbel.
      IF sy-subrc = 0.
        ls_out-txdat  =  ls_custrec-txdat.
      ENDIF.
    ENDIF.

    CASE pa_bukrs.
      WHEN '8020' OR '8070'.
        PERFORM f_validasi_taxcode USING ls_xsd004-gform ls_out-dppgl ls_out-ppngl
                                   CHANGING ls_out-taxcode.
      WHEN OTHERS.
*        ls_out-txdat  =  ls_xsd004-fkdat.
    ENDCASE.

    READ TABLE lt_zfvato INTO ls_zfvato
                         WITH KEY vbeln = ls_xsd004-vbeln.
    IF sy-subrc = 0.
      IF ls_out-vatpr IS INITIAL.
        ls_out-vatpr       = ls_zfvato-vatpr.
      ENDIF.
      IF ls_out-filename IS INITIAL.
        ls_out-filename    = ls_zfvato-files.
      ENDIF.
    ENDIF.

    ASSIGN lt_zfvatdtbuyer[ vkorg = ls_xsd004-bukrs
                            vkbur = ls_xsd004-vkbur
                            vbeln = ls_xsd004-vbeln
                            kunrg = ls_xsd004-kunrg ] TO FIELD-SYMBOL(<fs_zfvatdtbuyer>).
    IF <fs_zfvatdtbuyer> IS ASSIGNED.
      ls_out-name_co  =  <fs_zfvatdtbuyer>-name_co.
      ls_out-stceg    =  <fs_zfvatdtbuyer>-stceg.
      ls_out-stcd1    =  <fs_zfvatdtbuyer>-stcd1.
      ls_out-stcd3    =  <fs_zfvatdtbuyer>-stcd3.
      ls_out-counc    =  <fs_zfvatdtbuyer>-counc.
      ls_out-cityc    =  <fs_zfvatdtbuyer>-cityc.
      ls_out-nitku    =  <fs_zfvatdtbuyer>-stcd5.
      ls_out-stcd6    =  <fs_zfvatdtbuyer>-stcd6.
      UNASSIGN <fs_zfvatdtbuyer>.
    ENDIF.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  LOOP AT lt_xfi001 INTO ls_xfi001.
    CASE ls_xfi001-bukrs.
      WHEN '8220'.
      WHEN OTHERS.
        lv_subrc = 4.
        LOOP AT gt_fi001 INTO ls_fi001 WHERE belnr = ls_xfi001-belnr.
          CLEAR ls_zgdtxdt0104.
          READ TABLE gt_zgdtxdt0104 INTO ls_zgdtxdt0104
                                    WITH KEY hkont = ls_fi001-hkont.
          IF sy-subrc = 0.
            CLEAR lv_subrc.
            CONTINUE.
          ENDIF.
        ENDLOOP.
    ENDCASE.

    IF lv_subrc = 0.
      ls_out-bukrs    = ls_xfi001-bukrs.
      ls_out-vbeln    = ls_xfi001-belnr.
      ls_out-fkdat    = ls_xfi001-budat.
      ls_out-vkbur    = ls_xfi001-gsber.
*      ls_out-taxcode  = '04'.
      CLEAR ls_zfvattrn.
      READ TABLE gt_zfvattrn INTO ls_zfvattrn
                             WITH KEY vkbur = ls_xfi001-gsber
                                      gform = ls_xfi001-gform.
      IF sy-subrc = 0.
        IF ls_zfvattrn-vattrn = '01'.
          ls_out-taxcode  = '04'.
        ELSE.
          ls_out-taxcode  = ls_zfvattrn-vattrn.
        ENDIF.
      ENDIF.
      ls_out-vgbel    = ls_xfi001-zuonr.
      ls_out-lfdat    = ls_xfi001-budat.
      ls_out-kunrg    = ls_xfi001-kunnr.
      ls_out-stceg    = ls_xfi001-stceg.
      ls_out-nitku    = ls_xfi001-stcd5.
      IF ls_xfi001-name_co IS INITIAL.
        ls_out-name_co  = ls_xfi001-name1.
      ELSE.
        ls_out-name_co  = ls_xfi001-name_co.
      ENDIF.
      ls_out-waers    = ls_xfi001-waers.
      ls_out-txdat    = ls_xfi001-budat.

      PERFORM f_calc_value USING ls_xfi001-belnr
                           CHANGING ls_out-dppgl ls_out-ppngl ls_out-taxbase
                                    ls_out-otaxbase ls_out-vat ls_out-vatrate.

      CLEAR ls_005.
      READ TABLE lt_005 INTO ls_005
                        WITH KEY belnr = ls_xfi001-belnr.
      IF sy-subrc = 0.
        ls_out-vatpr    = ls_005-fakturno.
        ls_out-filename = ls_005-files.
        ls_out-pdffile  = ls_005-zfilename.
      ENDIF.

      CASE pa_bukrs.
        WHEN '8020' OR '8070'.
          PERFORM f_validasi_taxcode USING ls_xfi001-gform ls_out-dppgl ls_out-ppngl
                                     CHANGING ls_out-taxcode.
      ENDCASE.

      IF ls_out-vatpr IS INITIAL.
        READ TABLE lt_zfvato INTO ls_zfvato
                             WITH KEY vbeln = ls_xfi001-belnr.
        IF sy-subrc = 0.
          ls_out-vatpr    = ls_zfvato-vatpr.
        ENDIF.
      ENDIF.

      APPEND ls_out TO gt_out.
    ENDIF.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_RADIO2_PROCESS
*&---------------------------------------------------------------------*
FORM f_radio2_process .
  TYPES: BEGIN OF ty_eina,
           infnr TYPE eina-lifnr,
           matnr TYPE eina-matnr,
           lifnr TYPE eina-matnr,
         END OF ty_eina.

  DATA : lt_xsd002   TYPE STANDARD TABLE OF zcdssd_002,
         ls_xsd002   LIKE LINE OF lt_xsd002,
         lt_ysd002   TYPE STANDARD TABLE OF zcdssd_002,
         ls_ysd002   LIKE LINE OF lt_ysd002,
         lt_msd002   TYPE STANDARD TABLE OF zcdssd_002,
         ls_msd002   LIKE LINE OF lt_ysd002,
         lt_a017     TYPE STANDARD TABLE OF a017,
         ls_a017     LIKE LINE OF lt_a017,
         lt_eina     TYPE TABLE OF ty_eina,
         ls_eina     LIKE LINE OF lt_eina,
         lt_a934     TYPE STANDARD TABLE OF a934,
         ls_a934     LIKE LINE OF lt_a934,
         lt_konp     TYPE STANDARD TABLE OF konp,
         ls_konp     LIKE LINE OF lt_konp,
         lt_005      TYPE STANDARD TABLE OF zcoretax0005,
         ls_005      LIKE LINE OF lt_005,
         ls_out      LIKE LINE OF gt_out,
         ls_zfvattrn LIKE LINE OF gt_zfvattrn.

  DATA : lv_dmbtr   TYPE mseg-dmbtr.

  lt_msd002[] = lt_ysd002[] = lt_xsd002[] = gt_sd002[].
  SORT lt_xsd002 BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_xsd002 COMPARING tknum.
  SORT lt_ysd002 BY mblnr mjahr zeile.
  DELETE ADJACENT DUPLICATES FROM lt_ysd002 COMPARING mblnr mjahr zeile.
  SORT lt_msd002 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_msd002 COMPARING matnr.

  IF lt_xsd002[] IS NOT INITIAL.
    SELECT *
      FROM zcoretax0005
      INTO CORRESPONDING FIELDS OF TABLE lt_005
      FOR ALL ENTRIES IN lt_xsd002
      WHERE bukrs = pa_bukrs
        AND masatx = lt_xsd002-budat(6)
        AND belnr = lt_xsd002-tknum.
  ENDIF.

  IF lt_msd002[] IS NOT INITIAL.
    CASE pa_bukrs.
      WHEN '8020'.
        SELECT eina~infnr matnr lifnr
          FROM eina JOIN eine ON eina~infnr = eine~infnr
          INTO CORRESPONDING FIELDS OF TABLE lt_eina
          FOR ALL ENTRIES IN lt_msd002
          WHERE eina~matnr = lt_msd002-matnr
            AND eine~ekorg = 'SOM'
            AND eine~esokz = '0'
            AND eine~werks = '0200'
            AND eine~loekz = space.

        SELECT *
          FROM a017
          INTO CORRESPONDING FIELDS OF TABLE lt_a017
          FOR ALL ENTRIES IN lt_msd002
          WHERE kappl = 'M'
            AND kschl = 'ZHJP'
            AND matnr = lt_msd002-matnr
            AND ekorg = 'SOM'
            AND werks = '0200'
            AND esokz = '0'.

        IF lt_a017[] IS NOT INITIAL.
          SELECT *
            FROM konp
            INTO CORRESPONDING FIELDS OF TABLE lt_konp
            FOR ALL ENTRIES IN lt_a017
            WHERE knumh = lt_a017-knumh.
        ENDIF.

      WHEN OTHERS.
        SELECT *
          FROM a934
          INTO CORRESPONDING FIELDS OF TABLE lt_a934
          FOR ALL ENTRIES IN lt_msd002
          WHERE kappl = 'V'
            AND kschl = 'ZHET'
            AND matnr = lt_msd002-matnr.

        IF lt_a934[] IS NOT INITIAL.
          SELECT *
            FROM konp
            INTO CORRESPONDING FIELDS OF TABLE lt_konp
            FOR ALL ENTRIES IN lt_a934
            WHERE knumh = lt_a934-knumh.
        ENDIF.
    ENDCASE.
  ENDIF.

  LOOP AT lt_xsd002 INTO ls_xsd002.
*    ls_out-taxcode  = '04'.
    CLEAR ls_zfvattrn.
    READ TABLE gt_zfvattrn INTO ls_zfvattrn
                           WITH KEY vkbur = ls_xsd002-werks
                                    gform = ls_xsd002-gform.
    IF sy-subrc = 0.
      IF ls_zfvattrn-vattrn = '01'.
        ls_out-taxcode  = '04'.
      ELSE.
        ls_out-taxcode  = ls_zfvattrn-vattrn.
      ENDIF.
    ENDIF.
    ls_out-bukrs    = ls_xsd002-bukrs.
    ls_out-vkbur    = ls_xsd002-werks.
    ls_out-tknum    = ls_xsd002-tknum.
    CASE pa_bukrs.
      WHEN '8020'.
        ls_out-erdat    = ls_xsd002-datbg.
      WHEN OTHERS.
        ls_out-erdat    = ls_xsd002-erdat.
    ENDCASE.

    SORT lt_a017 BY matnr datab.
    SORT lt_a934 BY matnr datab.
    LOOP AT lt_ysd002 INTO ls_ysd002 WHERE tknum = ls_xsd002-tknum.
      CASE pa_bukrs.
        WHEN '8020'.
          LOOP AT lt_a017 INTO ls_a017 WHERE matnr = ls_ysd002-matnr.
            IF ls_a017-datab <= ls_out-erdat AND
              ls_a017-datbi >= ls_out-erdat.
              CLEAR ls_eina.
              READ TABLE lt_eina INTO ls_eina
                                 WITH KEY lifnr = ls_a017-lifnr
                                          matnr = ls_a017-matnr.
              IF sy-subrc = 0.
                CLEAR : ls_konp.
                READ TABLE lt_konp INTO ls_konp
                                   WITH KEY knumh = ls_a017-knumh.
                IF sy-subrc = 0.
                  lv_dmbtr = ls_ysd002-menge * ( ls_konp-kbetr / ls_konp-kpein ).
                  EXIT.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
          ADD lv_dmbtr TO ls_out-dppgl.
        WHEN OTHERS.
          LOOP AT lt_a934 INTO ls_a934 WHERE matnr = ls_ysd002-matnr.
            IF ls_a934-datab <= ls_out-erdat AND
              ls_a934-datbi >= ls_out-erdat.
              CLEAR : ls_konp.
              READ TABLE lt_konp INTO ls_konp
                                 WITH KEY knumh = ls_a934-knumh.
              IF sy-subrc = 0.
                lv_dmbtr = ls_ysd002-menge * ( ls_konp-kbetr / ls_konp-kpein ).
                EXIT.
              ENDIF.
            ENDIF.
          ENDLOOP.
          ADD lv_dmbtr TO ls_out-dppgl.
      ENDCASE.
    ENDLOOP.

    ls_out-kunrg    = ls_xsd002-kunnr.
    ls_out-stceg    = ls_xsd002-stceg.
    ls_out-nitku    = ls_xsd002-stcd5.
    ls_out-name_co  = ls_xsd002-name_co.
    ls_out-txdat    = ls_xsd002-budat.
    ls_out-waers    = ls_xsd002-waers.

    ls_out-ppngl    = ls_out-dppgl * 11 / 100.
    ls_out-taxbase  = ls_out-dppgl.

*    READ TABLE gt_kna1 INTO DATA(ls_kna1)
*                       WITH KEY kunnr = ls_out-kunrg.
*    IF sy-subrc = 0.
*      ls_out-stceg    = ls_kna1-stceg.
*      ls_out-nitku    = ls_kna1-stcd5.
*      ls_out-stcd1    = ls_kna1-stcd1.
*      ls_out-stcd3    = ls_kna1-stcd3.
*      ls_out-counc    = ls_kna1-counc.
*      ls_out-cityc    = ls_kna1-cityc.
*      ls_out-stcd6    = ls_kna1-stcd6.
*    ENDIF.

    IF p_check IS INITIAL.
      ls_out-vatrate  = '11'.
      CLEAR ls_out-otaxbase.
      ls_out-vat      = ls_out-ppngl.
    ELSE.
      ls_out-vatrate  = '12'.
      ls_out-otaxbase = ls_out-dppgl * 11 / ls_out-vatrate.
      ls_out-vat      = ls_out-otaxbase * ( ls_out-vatrate / 100 ).
    ENDIF.

    CLEAR ls_005.
    READ TABLE lt_005 INTO ls_005
                      WITH KEY belnr = ls_xsd002-tknum.
    IF sy-subrc = 0.
      ls_out-vatpr    = ls_005-fakturno.
      ls_out-filename = ls_005-files.
      ls_out-pdffile  = ls_005-zfilename.
    ENDIF.

    CASE pa_bukrs.
      WHEN '8020' OR '8070'.
        PERFORM f_validasi_taxcode USING ls_xsd002-gform ls_out-dppgl ls_out-ppngl
                                   CHANGING ls_out-taxcode.
    ENDCASE.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_RADIO3_PROCESS
*&---------------------------------------------------------------------*
FORM f_radio3_process .
  DATA : ls_008      LIKE LINE OF gt_008,
         ls_kna1     LIKE LINE OF gt_kna1,
         ls_out      LIKE LINE OF gt_out,
         lt_005      TYPE STANDARD TABLE OF zcoretax0005,
         ls_005      LIKE LINE OF lt_005,
         ls_zfvattrn LIKE LINE OF gt_zfvattrn.

  LOOP AT gt_008 INTO ls_008.
    ls_out-bukrs    = ls_008-bukrs.
    CASE pa_bukrs.
      WHEN '8210'.
        ls_out-vkbur    = '2100'.
        CONCATENATE 'KI' ls_008-monat ls_008-gjahr+2(2) ls_008-bbill+4(4)
        INTO ls_out-vbeln.
      WHEN '8220'.
        ls_out-vkbur    = '2200'.
        CONCATENATE ls_008-monat ls_008-gjahr+2(2) ls_008-bbill+2(6)
        INTO ls_out-vbeln.
    ENDCASE.

    ls_out-fkdat    = ls_008-bidat.
    ls_out-kunrg    = ls_008-zzkunn2.
    ls_out-zzkdctr  = ls_008-zzkdctr.
    ls_out-name_co  = ls_008-p_name1.

    CLEAR ls_kna1.
    READ TABLE gt_kna1 INTO ls_kna1
                       WITH KEY kunnr = ls_out-kunrg.
    IF sy-subrc = 0.
      ls_out-stceg    = ls_kna1-stceg.
      ls_out-nitku    = ls_kna1-stcd5.
*      ls_out-stcd1    = ls_kna1-stcd1.
*      ls_out-stcd3    = ls_kna1-stcd3.
*      ls_out-counc    = ls_kna1-counc.
*      ls_out-cityc    = ls_kna1-cityc.
*      ls_out-stcd6    = ls_kna1-stcd6.
      IF ls_out-name_co IS INITIAL AND
        ls_kna1-name_co IS INITIAL.
        ls_out-name_co    = ls_kna1-name1.
      ELSE.
        ls_out-name_co    = ls_kna1-name_co.
      ENDIF.

      CLEAR ls_zfvattrn.
      READ TABLE gt_zfvattrn INTO ls_zfvattrn
                             WITH KEY vkbur = ls_out-vkbur
                                      gform = ls_kna1-gform.
      IF sy-subrc = 0.
        IF ls_zfvattrn-vattrn = '01'.
          ls_out-taxcode  = '04'.
        ELSE.
          ls_out-taxcode  = ls_zfvattrn-vattrn.
        ENDIF.
      ENDIF.
    ENDIF.

    ls_out-txdat    = ls_008-bidat.
    ls_out-waers    = ls_008-zzcur.
    ls_out-dppgl    = ls_008-nilai_dpp.
    ls_out-ppngl    = ls_008-nilai_ppn.
    ls_out-taxbase  = ls_008-nilai_dpp.

    IF p_check IS INITIAL.
*      ls_out-taxcode  = '01'.
      ls_out-vatrate  = '11'.
      ls_out-vat      = ls_008-nilai_ppn.
    ELSE.
*      ls_out-taxcode  = '04'.
      ls_out-vatrate  = '12'.
      ls_out-otaxbase = ls_008-nilai_dpp * 11 / ls_out-vatrate.
      ls_out-vat      = ls_out-otaxbase * ( ls_out-vatrate / 100 ) / 100.
    ENDIF.

    CASE pa_bukrs.
      WHEN '8020' OR '8070'.
        PERFORM f_validasi_taxcode USING ls_kna1-gform ls_out-dppgl ls_out-ppngl
                                   CHANGING ls_out-taxcode.
    ENDCASE.

    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  IF gt_out[] IS NOT INITIAL.
    SELECT *
      FROM zcoretax0005
      INTO CORRESPONDING FIELDS OF TABLE lt_005
      FOR ALL ENTRIES IN gt_out
      WHERE bukrs = pa_bukrs
        AND masatx = gt_out-fkdat(6)
        AND belnr = gt_out-vbeln.

    LOOP AT gt_out INTO ls_out.
      CLEAR ls_005.
      READ TABLE lt_005 INTO ls_005
                        WITH KEY bukrs = pa_bukrs
                                 belnr = ls_out-vbeln.
      IF sy-subrc = 0.
        ls_out-vatpr    = ls_005-fakturno.
        ls_out-filename = ls_005-files.
        ls_out-pdffile  = ls_005-zfilename.
        MODIFY gt_out FROM ls_out
                      TRANSPORTING vatpr filename pdffile.
      ENDIF.
      CLEAR ls_out.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_F4
*&---------------------------------------------------------------------*
FORM f_alv_variant_f4  CHANGING p_pa_vari.
  DATA : rs_variant LIKE disvariant.
  DATA : nof4 TYPE c.

  CLEAR nof4.
  LOOP AT SCREEN.
    IF screen-name = 'PA_VARI'.
      IF screen-input = 0.
        nof4 = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  rs_variant-report   = gv_repid.
  rs_variant-username = sy-uname.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = rs_variant
      i_save     = 'A'
    IMPORTING
      es_variant = rs_variant
    EXCEPTIONS
      OTHERS     = 1.
  IF sy-subrc = 0 AND
    nof4 EQ space.
    pa_vari = rs_variant-variant.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_TAXCODE
*&---------------------------------------------------------------------*
FORM f_validasi_taxcode  USING    fu_gform fu_dppgl fu_ppngl
                         CHANGING fc_taxcode.
  DATA : lv_dmbtr    TYPE bseg-dmbtr.

  CASE fu_gform.
    WHEN 'A4'.
      lv_dmbtr = fu_dppgl + fu_ppngl.
      IF lv_dmbtr <= co_dmbtr1.
        fc_taxcode = '04'.
      ENDIF.
    WHEN 'A3'.
      lv_dmbtr = fu_dppgl.
      IF lv_dmbtr < co_dmbtr2.
        fc_taxcode = '04'.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CUSTOMER_PINDAH
*&---------------------------------------------------------------------*
FORM f_customer_pindah .
  SELECT *
    FROM zfarsoff
    INTO CORRESPONDING FIELDS OF TABLE gt_zfarsoff
    WHERE budat >= so_fkdat-low.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_validate_customer  USING    fu_sign.
  DATA : lt_sd004    TYPE STANDARD TABLE OF zcdssd_004,
         ls_sd004    LIKE LINE OF gt_sd004,
         ls_zfarsoff LIKE LINE OF gt_zfarsoff,
         lr_kunnr    TYPE RANGE OF kunnr,
         ls_kunnr    LIKE LINE OF lr_kunnr.

  CASE fu_sign.
    WHEN '-'.
      LOOP AT gt_sd004 INTO ls_sd004.
        CLEAR ls_zfarsoff.
        READ TABLE gt_zfarsoff INTO ls_zfarsoff
                               WITH KEY kunnr  = ls_sd004-kunrg
                                        zvkbur = ls_sd004-vkbur.
        IF sy-subrc = 0.
          DELETE TABLE gt_sd004 FROM ls_sd004.
        ENDIF.
      ENDLOOP.
    WHEN '+'.
      LOOP AT gt_zfarsoff INTO ls_zfarsoff WHERE zvkbur1 IN so_vkbur.
        ls_kunnr-low    = ls_zfarsoff-kunnr.
        ls_kunnr-sign   = 'I'.
        ls_kunnr-option = 'EQ'.
        APPEND ls_kunnr TO lr_kunnr.
        CLEAR ls_kunnr.
      ENDLOOP.

      SELECT *
        FROM zcdssd_004
        INTO CORRESPONDING FIELDS OF TABLE lt_sd004
        WHERE vbeln     IN so_vbevf
          AND fkdat     IN so_fkdat
          AND bukrs     = pa_bukrs
          AND kunrg     IN lr_kunnr
          AND vgbel     IN so_vbevl.

      LOOP AT lt_sd004 INTO ls_sd004.
        CLEAR ls_zfarsoff.
        READ TABLE gt_zfarsoff INTO ls_zfarsoff
                               WITH KEY kunnr  = ls_sd004-kunrg
                                        zvkbur = ls_sd004-vkbur.
        IF sy-subrc = 0.
          IF ls_zfarsoff-zvkbur1 IN so_vkbur.
            ls_sd004-vkbur  = ls_zfarsoff-zvkbur1.
            APPEND ls_sd004 TO gt_sd004.
          ENDIF.
        ENDIF.
        CLEAR ls_sd004.
      ENDLOOP.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_004
*&---------------------------------------------------------------------*
FORM f_modify_004 .
  DATA : ls_sd004 LIKE LINE OF gt_sd004,
         lt_xd004 TYPE STANDARD TABLE OF zcdssd_004,
         ls_xd004 LIKE LINE OF lt_xd004,
         lr_fkart TYPE RANGE OF fkart,
         ls_fkart LIKE LINE OF lr_fkart,
         lt_knvv  TYPE STANDARD TABLE OF knvv,
         ls_knvv  LIKE LINE OF lt_knvv.

  ls_fkart-low    = 'ZB7A'.
  ls_fkart-sign   = 'I'.
  ls_fkart-option = 'EQ'.
  APPEND ls_fkart TO lr_fkart.
  CLEAR ls_fkart.
  ls_fkart-low    = 'ZB7B'.
  ls_fkart-sign   = 'I'.
  ls_fkart-option = 'EQ'.
  APPEND ls_fkart TO lr_fkart.
  CLEAR ls_fkart.

  lt_xd004[] = gt_sd004[].
  SORT lt_xd004 BY kunrg.
  DELETE ADJACENT DUPLICATES FROM lt_xd004 COMPARING kunrg.
  IF lt_xd004[] IS NOT INITIAL.
    SELECT *
      FROM knvv
      INTO CORRESPONDING FIELDS OF TABLE lt_knvv
      FOR ALL ENTRIES IN lt_xd004
      WHERE kunnr = lt_xd004-kunrg.
  ENDIF.

  LOOP AT gt_sd004 INTO ls_sd004.
    IF ls_sd004-fkart IN lr_fkart.
      CLEAR ls_knvv.
      READ TABLE lt_knvv INTO ls_knvv
                         WITH KEY kunnr = ls_sd004-kunrg.
      IF sy-subrc = 0.
        ls_sd004-vkbur  = ls_knvv-vkbur.
        MODIFY gt_sd004 FROM ls_sd004 TRANSPORTING vkbur.
      ENDIF.
    ENDIF.

    IF ls_sd004-vkbur IN so_vkbur.
      CONTINUE.
    ELSE.
      DELETE TABLE gt_sd004 FROM ls_sd004.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE
*&---------------------------------------------------------------------*
FORM f_calculate  USING    fu_dmbtr fu_dppgl
                  CHANGING fc_dppgl fc_taxbase fc_ppngl fc_vatrate fc_otaxbase
                           fc_vat.
  fc_dppgl    = fu_dmbtr * 100 / 11.
  fc_ppngl    = fu_dmbtr.
  fc_taxbase  = ( fu_dmbtr * 100 / 11 ) * 100.

  IF p_check IS INITIAL.
    fc_vatrate  = '11'.
    CLEAR fc_otaxbase.
    fc_vat      = fu_dmbtr.
  ELSE.
    fc_vatrate  = '12'.
    fc_otaxbase = fc_taxbase * 11 / fc_vatrate.
    fc_vat      = ( fc_otaxbase * fc_vatrate / 100 ) / 100.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_NEW_CALCULATE
*&---------------------------------------------------------------------*
FORM f_new_calculate  USING    fu_dmbtr fu_dppgl
                      CHANGING fc_dppgl fc_taxbase fc_ppngl fc_vatrate fc_otaxbase
                               fc_vat.
  IF fu_dppgl IS INITIAL.
    fc_dppgl    = ( fu_dmbtr * 100 / 11 ).
    fc_taxbase  = ( fu_dmbtr * 100 / 11 ) * 100.
  ELSE.
    fc_dppgl    = fu_dppgl.
    fc_taxbase  = fu_dppgl * 100.
  ENDIF.

  fc_ppngl    = fu_dmbtr.

  IF p_check IS INITIAL.
    fc_vatrate  = '11'.
    CLEAR fc_otaxbase.
    fc_vat      = fu_dmbtr.
  ELSE.
    fc_vatrate  = '12'.
    fc_otaxbase = fc_taxbase * 11 / fc_vatrate.
    fc_vat      = ( fc_otaxbase * fc_vatrate / 100 ) / 100.
  ENDIF.
ENDFORM.
