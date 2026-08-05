*&---------------------------------------------------------------------*
*&  Include           ZACCPP_R001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SELECTION
*&---------------------------------------------------------------------*
FORM f_modify_selection .

ENDFORM.                    " F_MODIFY_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .

ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  SELECT *
  FROM t001k
  INTO CORRESPONDING FIELDS OF TABLE gt_t001k.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  TYPES : BEGIN OF ty_key,
            vkorg   TYPE a989-vkorg,
            matnr   TYPE a989-matnr,
            gstrp   TYPE afko-gstrp,
          END OF ty_key.

  DATA : ls_out     LIKE LINE OF gt_out,
         ls_t001k   LIKE LINE OF gt_t001k,
         lt_key     TYPE STANDARD TABLE OF ty_key,
         ls_key     LIKE LINE OF lt_key.

  DATA : lt_out     TYPE STANDARD TABLE OF ty_out,
         lt_afko    TYPE STANDARD TABLE OF afko,
         ls_afko    LIKE LINE OF lt_afko.

  SELECT *
    FROM afko
    INTO CORRESPONDING FIELDS OF TABLE lt_afko
    WHERE aufnr IN so_aufnr.

  SELECT *
    FROM zv_accdtm
    INTO CORRESPONDING FIELDS OF TABLE gt_out
    WHERE aufnr IN so_aufnr
      AND matnr IN so_matnr
      AND charg IN so_charg.

  IF gt_out[] IS NOT INITIAL.
    SELECT *
      FROM zaccdta
      INTO CORRESPONDING FIELDS OF TABLE gt_zaccdta
      FOR ALL ENTRIES IN gt_out
      WHERE matnr = gt_out-matnr
        AND charg = gt_out-charg
        AND senum = gt_out-senum.
  ENDIF.

  lt_out[] = gt_out[].
  SORT lt_out BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr.
  IF lt_out[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN lt_out
      WHERE spras = sy-langu
        AND matnr = lt_out-matnr.
  ENDIF.

  LOOP AT gt_out INTO ls_out.
    READ TABLE gt_t001k INTO ls_t001k
                        WITH KEY bwkey = ls_out-pwerk.
    IF sy-subrc = 0.
      CLEAR ls_afko.
      READ TABLE lt_afko INTO ls_afko
                         WITH KEY aufnr = ls_out-aufnr.
      ls_key-vkorg   = ls_t001k-bukrs.
      ls_key-matnr   = ls_out-matnr.
      ls_key-gstrp   = ls_afko-gstrp.
      APPEND ls_key TO lt_key.
      CLEAR ls_key.
    ENDIF.
  ENDLOOP.

  IF lt_key[] IS NOT INITIAL.
    SELECT *
      FROM a989
      INTO CORRESPONDING FIELDS OF TABLE gt_a989
      FOR ALL ENTRIES IN lt_key
      WHERE kappl = 'V'
        AND kschl = 'ZHET'
        AND vkorg = lt_key-vkorg
        AND matnr = lt_key-matnr
        AND datab <= lt_key-gstrp
        AND datbi >= lt_key-gstrp.

    IF gt_a989[] IS NOT INITIAL.
      SELECT *
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE gt_konp
        FOR ALL ENTRIES IN gt_a989
        WHERE knumh = gt_a989-knumh.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_out     LIKE LINE OF gt_out,
         ls_t001k   LIKE LINE OF gt_t001k,
         ls_a989    LIKE LINE OF gt_a989,
         ls_konp    LIKE LINE OF gt_konp,
         ls_makt    LIKE LINE OF gt_makt,
         ls_zaccdta LIKE LINE OF gt_zaccdta.

  LOOP AT gt_out INTO ls_out.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_out-matnr.
    IF sy-subrc = 0.
      ls_out-maktx  = ls_makt-maktx.
    ENDIF.

    CLEAR ls_zaccdta.
    READ TABLE gt_zaccdta INTO ls_zaccdta
                          WITH KEY matnr = ls_out-matnr
                                   charg = ls_out-charg
                                   senum = ls_out-senum.
    IF sy-subrc = 0.
      ls_out-aggr1      = ls_zaccdta-aggr1.
      ls_out-packdat1   = ls_zaccdta-packdat1.
      ls_out-zact1      = ls_zaccdta-zact1.

      ls_out-aggr2      = ls_zaccdta-aggr2.
      ls_out-packdat2   = ls_zaccdta-packdat2.
      ls_out-zact2      = ls_zaccdta-zact2.
    ENDIF.

    CLEAR ls_t001k.
    READ TABLE gt_t001k INTO ls_t001k
                        WITH KEY bwkey = ls_out-pwerk.
    IF sy-subrc = 0.
      CLEAR ls_a989.
      READ TABLE gt_a989 INTO ls_a989
                         WITH KEY vkorg = ls_t001k-bukrs
                                  matnr = ls_out-matnr.
      IF sy-subrc = 0.
        CLEAR : ls_konp.
        READ TABLE gt_konp INTO ls_konp
                           WITH KEY knumh = ls_a989-knumh.
        IF sy-subrc = 0.
          ls_out-kbetr = ls_konp-kbetr.
        ENDIF.
      ENDIF.
    ENDIF.

    ls_out-count  = 1.
    MODIFY gt_out FROM ls_out TRANSPORTING maktx aggr1 packdat1
                                           zact1 aggr2 packdat2
                                           zact2 kbetr count.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode    TYPE TABLE OF sy-ucomm,
         lv_title(100).

*  SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  lv_title  = 'Accuracy Report'.

  SET TITLEBAR 'TITLE' WITH lv_title.

  PERFORM f_excluding_toolbar USING :
    '&INFO' 'T',
    '&GRAPH' 'T',
    '&MB_VARIANT' 'T',

    '&INFO' 'B',
    '&GRAPH' 'B'.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar  USING    fu_attribute fu_pos.
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = fu_attribute.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_exclude TO gs_exclude_t.
    WHEN 'B'.
      APPEND ls_exclude TO gs_exclude_b.
  ENDCASE.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_SILVER'.

  IF g_maincont IS INITIAL.
    CREATE OBJECT g_maincont
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
        parent  = g_maincont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_top.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 2
*        column    = 1
*      RECEIVING
*        container = g_bottom.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TOP_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE top_alv OUTPUT.
  IF g_tgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_top.

    PERFORM f_build_layout USING 'T'.
    PERFORM f_build_sort USING 'T'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_clickt
                event_receiver->handle_toolbart
                event_receiver->handle_menu_buttont
                event_receiver->handle_user_commandt FOR g_tgrid.

    CALL METHOD g_tgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude_t
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_fieldcat_t[].
*  ELSE.
*    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " TOP_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  BOTTOM_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE bottom_alv OUTPUT.
  IF g_bgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_bgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_bottom.

    PERFORM f_build_layout USING 'B'.
    PERFORM f_build_sort USING 'B'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_clickb
                event_receiver->handle_toolbarb
                event_receiver->handle_menu_buttonb
                event_receiver->handle_user_commandb FOR g_bgrid.

    CALL METHOD g_bgrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude_b
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = <fs_bottom>[]
        it_fieldcatalog      = gt_fieldcat_b[].
  ELSE.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " BOTTOM_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CALL METHOD g_tgrid->set_function_code
    CHANGING
      c_ucomm = ok_code.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    IF g_tgrid IS NOT INITIAL.
      CALL METHOD g_tgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.

    IF g_bgrid IS NOT INITIAL.
      CALL METHOD g_bgrid->refresh_table_display
        EXPORTING
          is_stable = gs_stable.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_pos.
*  gs_layout_alv-box_fname           = 'CHECK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-no_rowmark          = selected.
*  gs_layout_alv-stylefname          = 'STYLE'.
*  gs_layout_alv-ctab_fname          = 'COLOR'.
  gs_layout_alv-cwidth_opt          = selected.
  CASE fu_pos.
    WHEN 'T'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = selected.
    WHEN 'B'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = selected.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort  USING    fu_sort.
  CLEAR gt_main_sort.

  CASE fu_sort.
    WHEN 'T'.
    WHEN 'B'.
*      gt_main_sort-spos      = 1.
*      gt_main_sort-fieldname = ''.
*      gt_main_sort-up        = selected.
*      APPEND gt_main_sort.
*      CLEAR gt_main_sort.
  ENDCASE.

ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table  USING    fu_pos.
  DATA : fname            TYPE string,
         title            TYPE string,
         lt_dyn_table     TYPE REF TO data,
         ls_line          TYPE REF TO data.


  CASE fu_pos.
    WHEN 'T'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'AUFNR' '' '' '' '' '' '' 'AUFNR' 'AFPO' '' '' '' '' '' '' 'X',
        fu_pos 'POSNR' '' '' '' '' '' '' 'POSNR' 'AFPO' '' '' '' '' '' '' 'X',
        fu_pos 'PWERK' '' '' '' '' '' '' 'PWERK' 'AFPO' 'Plant' '' '' '' '' '' 'X',
        fu_pos 'MATNR' '' '' '' '' '' '' 'MATNR' 'AFPO' '' '' '' '' '' '' 'X',
        fu_pos 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' 'X',
        fu_pos 'CHARG' '' '' '' '' '' '' 'CHARG' 'AFPO' '' '' '' '' '' '' 'X',
        fu_pos 'NIE' '' '' '' '' '' '' 'NIE' 'ZTSPMMDT002' '' '' '' '' '' '' '',
        fu_pos 'KEMASAN' '' '' '' '' '' '' 'KEMASAN' 'ZTSPMMDT002' '' '20' '' '' '' '' '',
        fu_pos 'PSMNG' '' '' '' '' 'AMEIN' '' 'PSMNG' 'AFPO' '' '' '' '' '' '' '',
        fu_pos 'AMEIN' '' '' '' '' '' '' 'AMEIN' 'AFPO' '' '' '' '' '' '' '',
        fu_pos 'SENUM' '' '' '' '' '' '' 'SENUM' 'ZACCDTM' '' '' '' '' '' '' '',
        fu_pos 'VBELN' '' '' '' '' '' '' 'VBELN' 'ZACCDTM' '' '' '' '' '' '' '',
        fu_pos 'SNSTA' '' '' '' '' '' '' 'SNSTA' 'ZACCDTM' '' '' '' '' '' '' '',
        fu_pos 'VFDAT' '' '' '' '' '' '' 'VFDAT' 'MCH1' '' '' '' '' '' '' '',
        fu_pos 'HSDAT' '' '' '' '' '' '' 'HSDAT' 'MCH1' '' '' '' '' '' '' '',
        fu_pos 'KBETR' '' 'IDR' '' '' '' '' 'KBETR' 'KONP' '' '' '' '' '' '' '',
        fu_pos 'AGGR1' '' '' '' '' '' '' 'AGGR1' 'ZACCDTA' 'Aggregat 1' '' '' '' '' '' '',
        fu_pos 'PACKDAT1' '' '' '' '' '' '' 'PACKDAT1' 'ZACCDTA' '' '' '' '' '' '' '',
        fu_pos 'ZACT1' '' '' '' '' '' '' 'ZACT1' 'ZACCDTA' 'Active' '' '' '' '' '' '',
        fu_pos 'AGGR2' '' '' '' '' '' '' 'AGGR2' 'ZACCDTA' 'Aggregat 2' '' '' '' '' '' '',
        fu_pos 'PACKDAT2' '' '' '' '' '' '' 'PACKDAT2' 'ZACCDTA' '' '' '' '' '' '' '',
        fu_pos 'ZACT2' '' '' '' '' '' '' 'ZACT2' 'ZACCDTA' 'Active' '' '' '' '' '' '',
        fu_pos 'COUNT' '' '' '' '' '' '' '' '' 'Counter' '' '' '' '' '' ''.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_t
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_top>.
        CREATE DATA ls_line LIKE LINE OF <fs_top>.
        ASSIGN ls_line->* TO <fs_ltop>.
      ENDIF.

    WHEN 'B'.
      PERFORM f_dyn_int_table USING :
        fu_pos 'KUNNR' '' '' '' '' '' '' 'KUNNR' 'KNA1' '' '' '' '' '' '' 'X'.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_fieldcat_b
          i_length_in_byte          = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ASSIGN lt_dyn_table->* TO <fs_bottom>.
        CREATE DATA ls_line LIKE LINE OF <fs_bottom>.
        ASSIGN ls_line->* TO <fs_lbottom>.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_pos fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_no_out fu_edit fu_tech fu_just fu_fix.
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
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-fix_column  = fu_fix.
  CASE fu_pos.
    WHEN 'T'.
      APPEND ls_dyn_fcat TO gt_fieldcat_t.
    WHEN 'B'.
      APPEND ls_dyn_fcat TO gt_fieldcat_b.
    WHEN OTHERS.
  ENDCASE.
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
