*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SELECTION
*&---------------------------------------------------------------------*
FORM f_modify_selection .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PAU' '0' '' '' '',
                                      'PMA' '0' '' '' '',
                                      'PCH' '0' '' '' '',
                                      'PAD' '0' '' '' '',
                                      'PBA' '0' '' '' ''.

    WHEN radio2.
      PERFORM f_modify_screen USING : 'SAU' '0' '' '' '',
                                      'SMA' '0' '' '' '',
                                      'SCH' '0' '' '' '',
                                      'PMA' '0' '' '' '',
                                      'PCH' '0' '' '' '',
                                      'SGS' '0' '' '' '',
                                      'PBA' '0' '' '' ''.

    WHEN radio3.
      PERFORM f_modify_screen USING : 'PAU' '0' '' '' '',
                                      'PMA' '0' '' '' '',
                                      'PCH' '0' '' '' '',
                                      'PAD' '0' '' '' '',
                                      'PBA' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .
  CASE 'X'.
    WHEN radio1.
      IF pa_dwerk IS INITIAL.
        PERFORM f_error_message USING 'PDW' ''.
      ENDIF.
    WHEN radio2.
      IF pa_dwerk IS INITIAL.
        PERFORM f_error_message USING 'PDW' ''.
      ENDIF.
      IF pa_aufnr IS INITIAL.
        PERFORM f_error_message USING 'PAU' ''.
      ENDIF.
*      IF pa_matnr IS INITIAL.
*        PERFORM f_error_message USING 'PMA' ''.
*      ENDIF.
*      IF pa_charg IS INITIAL.
*        PERFORM f_error_message USING 'PCH' ''.
*      ENDIF.
      IF pa_add IS INITIAL.
        PERFORM f_error_message USING 'PAD' ''.
      ENDIF.
    WHEN radio3.
      IF pa_dwerk IS INITIAL.
        PERFORM f_error_message USING 'PDW' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_zaccdtu   LIKE LINE OF gt_zaccdtu,
         lv_procid    TYPE zaccdtu-procid.

  SELECT *
    FROM zaccdtu
    INTO CORRESPONDING FIELDS OF TABLE gt_zaccdtu
    WHERE company = 'POLYMARK'.

  CASE 'X'.
    WHEN radio3.
      lv_procid = 1.
  ENDCASE.

  READ TABLE gt_zaccdtu INTO ls_zaccdtu
                        WITH KEY procid = lv_procid.
  IF sy-subrc = 0.
    gv_uri  =  ls_zaccdtu-uri.
  ENDIF.

  SELECT *
    FROM t001k
    INTO CORRESPONDING FIELDS OF TABLE gt_t001k
    WHERE bwkey = pa_dwerk.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_afpo    TYPE STANDARD TABLE OF ty_afpo,
         ls_afpo    LIKE LINE OF lt_afpo,
         lt_resb    TYPE STANDARD TABLE OF resb.

  CASE 'X'.
    WHEN radio1.
      SELECT *
        FROM tj02t
        INTO CORRESPONDING FIELDS OF TABLE gt_tj02t
        WHERE spras = sy-langu.

      SELECT afpo~aufnr afpo~posnr afpo~matnr afpo~dwerk
        afpo~charg afpo~lgort afpo~psmng afpo~amein
        afko~gstrp
        FROM afpo JOIN afko ON afko~aufnr = afpo~aufnr
        INTO CORRESPONDING FIELDS OF TABLE gt_afpo
        WHERE afpo~aufnr  IN so_aufnr
          AND afpo~matnr  IN so_matnr
          AND afpo~charg  IN so_charg
          AND afpo~dwerk  = pa_dwerk
          AND afko~gstrp  IN so_gstrp.

      IF gt_afpo[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_xaccdtm
          FOR ALL ENTRIES IN gt_afpo
          WHERE matnr = gt_afpo-matnr
            AND charg = gt_afpo-charg.
      ENDIF.

      lt_afpo[] = gt_afpo[].
      SORT lt_afpo BY aufnr.
      DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING aufnr.
      IF lt_afpo[] IS NOT INITIAL.
        SELECT aufnr objnr
          FROM aufk
          INTO CORRESPONDING FIELDS OF TABLE gt_aufk
          FOR ALL ENTRIES IN lt_afpo
          WHERE aufnr = lt_afpo-aufnr.

        IF gt_aufk[] IS NOT INITIAL.
          SELECT *
            FROM jest
            INTO CORRESPONDING FIELDS OF TABLE gt_jest
            FOR ALL ENTRIES IN gt_aufk
            WHERE objnr = gt_aufk-objnr
              AND inact = space.
        ENDIF.
      ENDIF.

      PERFORM f_batch_detail TABLES lt_afpo.
      PERFORM f_get_nie TABLES lt_afpo.
      PERFORM f_get_het TABLES lt_afpo.

    WHEN radio2.
      SELECT afpo~aufnr afpo~posnr afpo~matnr afpo~dwerk
        afpo~charg afpo~lgort afpo~psmng afpo~amein
        afko~gstrp afko~rsnum
        FROM afpo JOIN afko ON afko~aufnr = afpo~aufnr
        INTO CORRESPONDING FIELDS OF TABLE gt_afpo
        WHERE afpo~aufnr  = pa_aufnr
          AND afpo~dwerk  = pa_dwerk.

      lt_afpo[] = gt_afpo[].
      SORT lt_afpo BY rsnum.
      DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING rsnum.
      IF lt_afpo[] IS NOT INITIAL.
        SELECT *
          FROM resb
          INTO CORRESPONDING FIELDS OF TABLE gt_resb
          FOR ALL ENTRIES IN lt_afpo
          WHERE rsnum = lt_afpo-rsnum
            AND matkl IN ('PMPP', 'PMSP').

        lt_resb[] = gt_resb[].
        SORT lt_resb BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr.
        IF lt_resb[] IS NOT INITIAL.
          SELECT *
            FROM makt
            INTO CORRESPONDING FIELDS OF TABLE gt_makt
            FOR ALL ENTRIES IN lt_resb
            WHERE matnr = lt_resb-matnr
              AND spras = sy-langu.
        ENDIF.
      ENDIF.

      IF gt_afpo[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_xaccdtm
          FOR ALL ENTRIES IN gt_afpo
          WHERE matnr = gt_afpo-matnr
            AND charg = gt_afpo-charg
            AND aufnr = gt_afpo-aufnr.
      ENDIF.

      lt_afpo[] = gt_afpo[].
      PERFORM f_batch_detail TABLES lt_afpo.
      PERFORM f_get_nie TABLES lt_afpo.
      PERFORM f_get_het TABLES lt_afpo.

    WHEN radio3.
      SELECT afpo~aufnr afpo~posnr afpo~matnr afpo~dwerk
        afpo~charg afpo~lgort afpo~psmng afpo~amein
        afko~gstrp
        FROM afpo JOIN afko ON afko~aufnr = afpo~aufnr
        INTO CORRESPONDING FIELDS OF TABLE gt_afpo
        WHERE afpo~aufnr  IN so_aufnr
          AND afpo~matnr  IN so_matnr
          AND afpo~dwerk  = pa_dwerk
          AND afpo~charg  IN so_charg
          AND afko~gstrp  IN so_gstrp.

      lt_afpo[] = gt_afpo[].
      SORT lt_afpo BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM lt_afpo COMPARING matnr charg.
      IF lt_afpo[] IS NOT INITIAL.
        SELECT *
          FROM zaccdtm
          INTO CORRESPONDING FIELDS OF TABLE gt_xaccdtm
          FOR ALL ENTRIES IN lt_afpo
          WHERE matnr = lt_afpo-matnr
            AND charg = lt_afpo-charg
            AND snsta = 'CRTD'.
      ENDIF.

      PERFORM f_batch_detail TABLES lt_afpo.
      PERFORM f_get_nie TABLES lt_afpo.
      PERFORM f_get_het TABLES lt_afpo.
      PERFORM f_get_material_detail TABLES lt_afpo.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .

  FIELD-SYMBOLS : <fs> TYPE ANY.
  DATA : ls_afpo          LIKE LINE OF gt_afpo,
         ls_zaccdtm       LIKE LINE OF gt_zaccdtm,
         ls_xaccdtm       LIKE LINE OF gt_xaccdtm,
         ls_post          LIKE LINE OF gt_post,
         lv_count         TYPE i,
         lv_add           TYPE i,
         ls_resb          LIKE LINE OF gt_resb.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_afpo INTO ls_afpo.
        CLEAR ls_xaccdtm.
        READ TABLE gt_xaccdtm INTO ls_xaccdtm
                              WITH KEY matnr = ls_afpo-matnr
                                       charg = ls_afpo-charg.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        PERFORM f_prepare_layout USING ls_afpo ls_afpo-psmng 'CRTD' ''
                                 CHANGING ls_post.
      ENDLOOP.

    WHEN radio2.
      CLEAR ls_afpo.
      READ TABLE gt_afpo INTO ls_afpo INDEX 1.
      IF sy-subrc = 0.
        PERFORM f_check_packmat USING ls_afpo-amein.
      ENDIF.

      LOOP AT gt_afpo INTO ls_afpo.
        CLEAR ls_xaccdtm.
        READ TABLE gt_xaccdtm INTO ls_xaccdtm
                              WITH KEY matnr = ls_afpo-matnr
                                       charg = ls_afpo-charg.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        LOOP AT gt_xaccdtm INTO ls_xaccdtm
                           WHERE matnr = ls_afpo-matnr
                             AND charg = ls_afpo-charg.
          ADD 1 TO lv_count.
        ENDLOOP.

*        IF ls_afpo-psmng <= lv_count.
*          gv_subrc = 4.
*          EXIT.
*        ENDIF.

        CLEAR ls_resb.
        READ TABLE gt_resb INTO ls_resb
                           WITH KEY rsnum = ls_afpo-rsnum.
        IF sy-subrc = 0.
          IF ls_resb-bdmng <= lv_count.
            gv_subrc = 4.
            EXIT.
          ELSE.
            lv_add = ls_resb-bdmng - lv_count.
            IF pa_add > lv_add.
              pa_add = lv_add.
            ENDIF.
          ENDIF.
        ENDIF.

        PERFORM f_prepare_layout USING ls_afpo pa_add 'CRTD' ''
                                 CHANGING ls_post.
      ENDLOOP.

    WHEN radio3.
      LOOP AT gt_afpo INTO ls_afpo.
        CLEAR ls_zaccdtm.
        LOOP AT gt_xaccdtm INTO ls_zaccdtm
                           WHERE matnr = ls_afpo-matnr
                             AND charg = ls_afpo-charg.
          CLEAR ls_post.
          PERFORM f_material_detail USING ls_afpo-matnr ls_zaccdtm-werks
                                          ls_afpo-amein
                                          CHANGING ls_post.

          PERFORM f_prepare_layout USING ls_afpo '1' '' ls_zaccdtm-senum
                                   CHANGING ls_post.

          PERFORM f_prepare_post_http USING ls_afpo ls_post ls_zaccdtm-senum.
        ENDLOOP.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  IF <fs_top>[] IS NOT INITIAL.
    IF pa_backg IS INITIAL.
      CALL SCREEN 100.
    ELSE.
      PERFORM f_save_data.
    ENDIF.
  ELSE.
    IF gv_subrc IS NOT INITIAL.
      MESSAGE s000(zab) WITH 'Update qty di Process Order' DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE s000(zab) WITH 'No datas found'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : fcode    TYPE TABLE OF sy-ucomm,
         lv_title(100),
         dynfield(20).

  CASE 'X'.
    WHEN radio1.
      lv_title  = 'Create Serial Number'.
    WHEN radio2.
      lv_title  = 'Add Serial Number'.
    WHEN radio3.
      lv_title  = 'Send Serial Number'.
      dynfield  = 'ICON'.
      READ TABLE <fs_top> INTO <fs_ltop>
                          WITH KEY (dynfield) = icon_led_red.
      IF sy-subrc = 0.
        APPEND 'SAVE' TO fcode.
      ENDIF.
  ENDCASE.

  IF gt_message[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ELSE.
    CLEAR dynlog.
  ENDIF.

  SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
  SET TITLEBAR 'TITLE' WITH lv_title.

  PERFORM f_excluding_toolbar USING :
    '&INFO' 'T',
    '&GRAPH' 'T',

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
        it_outtab            = <fs_top>[]
        it_fieldcatalog      = gt_fieldcat_t[].
  ELSE.
    PERFORM f_alv_refresh USING 'X'.
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
  CASE ok_code.
    WHEN 'SAVE'.
      PERFORM f_save_data.
      CASE 'X'.
        WHEN radio1.
          MESSAGE s000(zab) WITH 'Data already saved'.
        WHEN radio2.
          MESSAGE s000(zab) WITH 'Data already added'.
        WHEN radio3.
          MESSAGE s000(zab) WITH 'Data already send'.
      ENDCASE.
      LEAVE TO SCREEN 0.

    WHEN '&LOG'.
      PERFORM f_display_message.

    WHEN OTHERS.
  ENDCASE.
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
  CASE fu_pos.
    WHEN 'T'.
      gs_layout_alv-zebra               = space.
      gs_layout_alv-no_toolbar          = space.
    WHEN 'B'.
      gs_layout_alv-zebra               = selected.
      gs_layout_alv-no_toolbar          = space.
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
        fu_pos 'ICON' '' '' '' '' '' '' '' '' 'Sts' '' '' '' '' '' 'X' 'X',
        fu_pos 'AUFNR' '' '' '' '' '' '' 'AUFNR' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'MATNR' '' '' '' '' '' '' 'MATNR' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'WERKS' '' '' '' '' '' '' 'DWERK' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'LGORT' '' '' '' '' '' '' 'LGORT' 'AFPO' '' '' '' '' '' '' '' 'X',
        fu_pos 'PSMNG' '' '' '' '' 'AMEIN' '' 'PSMNG' 'AFPO' '' '' '' '' '' '' '' '',
        fu_pos 'AMEIN' '' '' '' '' '' '' 'AMEIN' 'AFPO' '' '' '' '' '' '' '' '',
        fu_pos 'NIE' '' '' '' '' '' '' 'NIE' 'ZTSPMMDT002' '' '' '' '' '' '' '' '',
        fu_pos 'CHARG' '' '' '' '' '' '' 'CHARG' 'AFPO' '' '' '' '' '' '' '' '',
        fu_pos 'VFDAT' '' '' '' '' '' '' 'VFDAT' 'MCHA' '' '' '' '' '' '' '' '',
        fu_pos 'SENUM' '' '' '' '' '' '' 'SENUM' 'ZACCDTM' '' '' '' '' '' '' '' '',
        fu_pos 'HSDAT' '' '' '' '' '' '' 'HSDAT' 'MCHA' '' '' '' '' '' '' '' '',
        fu_pos 'KBETR' '' 'IDR' '' '' '' '' 'KBETR' 'KONP' 'HET' '' '' '' '' '' '' ''.

      CASE 'X'.
        WHEN radio3.
          PERFORM f_dyn_int_table USING :
            fu_pos 'MEINH1' '' '' '' '' '' '' 'AMEIN' 'AFPO' 'Alt.UOM1' '' '' '' '' '' '' '',
            fu_pos 'MEINH2' '' '' '' '' '' '' 'AMEIN' 'AFPO' 'Alt.UOM2' '' '' '' '' '' '' '',
            fu_pos 'MEINH3' '' '' '' '' '' '' 'AMEIN' 'AFPO' 'Alt.UOM3' '' '' '' '' '' '' '',
            fu_pos 'MEINH4' '' '' '' '' '' '' 'AMEIN' 'AFPO' 'Alt.UOM4' '' '' '' '' '' '' '',
            fu_pos 'MEINH5' '' '' '' '' '' '' 'AMEIN' 'AFPO' 'Alt.UOM5' '' '' '' '' '' '' ''.
      ENDCASE.

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
        fu_pos 'KUNNR' '' '' '' '' '' '' 'KUNNR' 'KNA1' '' '' '' '' '' '' '' 'X'.

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
                               fu_no_out fu_edit fu_tech fu_just fu_icon
                               fu_fix.
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
  ls_dyn_fcat-icon        = fu_icon.
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

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
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

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
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

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE
*&---------------------------------------------------------------------*
FORM f_prepare_save  USING    fs_afpo   LIKE LINE OF gt_afpo
                              fu_senum fu_status.
  DATA : ls_zaccdtm   LIKE LINE OF gt_zaccdtm.

  ls_zaccdtm-matnr  = fs_afpo-matnr.
  ls_zaccdtm-charg  = fs_afpo-charg.
  ls_zaccdtm-senum  = fu_senum.
  ls_zaccdtm-werks  = fs_afpo-dwerk.
  ls_zaccdtm-lgort  = fs_afpo-lgort.
  ls_zaccdtm-aufnr  = fs_afpo-aufnr.
  CASE fu_status.
    WHEN 'CRTD'.
      ls_zaccdtm-erdat  = sy-datum.
      ls_zaccdtm-ernam  = sy-uname.
*    WHEN 'SEND'.
*      ls_zaccdtm-sendt  = sy-datum.
  ENDCASE.
  ls_zaccdtm-snsta  = fu_status.
  APPEND ls_zaccdtm TO gt_zaccdtm.
  CLEAR ls_zaccdtm.
ENDFORM.                    " F_PREPARE_SAVE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  FIELD-SYMBOLS : <fs_post>   TYPE ANY,
                  <fs_xpost>  TYPE ANY,
                  <fs>        TYPE ANY,
                  <fs1>       TYPE ANY,
                  <fs2>       TYPE ANY.

  DATA : ls_zaccdtm   LIKE LINE OF gt_zaccdtm,
         lv_tabix     TYPE sy-tabix,
         lv_subrc     TYPE sy-subrc,
         lt_xpost     TYPE STANDARD TABLE OF zaccstp,
         ls_xpost     LIKE LINE OF lt_xpost,
         ls_post      LIKE LINE OF gt_post,
         ls_reqhead   LIKE LINE OF gt_reqhead,
         ls_reqbody   LIKE LINE OF gt_reqbody,
         fname(20)    VALUE 'AUFNR',
         lv_count     TYPE sy-index,
         lt_zaccdtm   TYPE STANDARD TABLE OF zaccdtm,
         lv_matnr     TYPE zaccdtm-matnr,
         lv_charg     TYPE zaccdtm-charg,
         lv_senum     TYPE zaccdtm-senum.

  DATA : lv_total     TYPE sy-index.

  CASE 'X'.
    WHEN radio1.
      TRY.
          INSERT zaccdtm FROM TABLE gt_zaccdtm.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

    WHEN radio2.
      TRY.
          INSERT zaccdtm FROM TABLE gt_zaccdtm.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

    WHEN radio3.
      lt_xpost[] = gt_post[].
      SORT lt_xpost BY (fname).
      DELETE ADJACENT DUPLICATES FROM lt_xpost COMPARING (fname).
      LOOP AT lt_xpost ASSIGNING <fs_xpost>.
        ls_reqhead-header = 'Content-Type: application/json'.
        APPEND ls_reqhead TO gt_reqhead.

        PERFORM f_json_format USING :
          '[' '' '' '' ''.
        ASSIGN COMPONENT fname OF STRUCTURE <fs_xpost> TO <fs1>.
        LOOP AT gt_post ASSIGNING <fs_post>.
          CLEAR : lv_matnr, lv_charg, lv_senum.
          ASSIGN COMPONENT fname OF STRUCTURE <fs_post> TO <fs2>.
          IF <fs2> = <fs1>.
            PERFORM f_request_body USING <fs_post>
                                   CHANGING lv_matnr lv_charg lv_senum.

            READ TABLE gt_zaccdtm INTO ls_zaccdtm
                                  WITH KEY matnr = lv_matnr
                                           charg = lv_charg
                                           senum = lv_senum.
            IF sy-subrc = 0.
              APPEND ls_zaccdtm TO lt_zaccdtm.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.

        DESCRIBE TABLE gt_reqbody LINES lv_count.
        ls_reqbody-body = '}'.
        MODIFY gt_reqbody FROM ls_reqbody  INDEX lv_count TRANSPORTING body.
        PERFORM f_json_format USING :
          '' '' '' '' ']'.

        PERFORM f_http_post CHANGING lv_subrc.

*        IF lv_subrc IS INITIAL.
*          LOOP AT lt_zaccdtm INTO ls_zaccdtm.
*            UPDATE zaccdtm SET sendt = sy-datum
*                               snsta = ls_zaccdtm-snsta
*                           WHERE matnr = ls_zaccdtm-matnr
*                             AND charg = ls_zaccdtm-charg
*                             AND senum = ls_zaccdtm-senum.
*          ENDLOOP.
*        ENDIF.
        CLEAR : lt_zaccdtm[], lt_zaccdtm.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_LAYOUT
*&---------------------------------------------------------------------*
FORM f_prepare_layout  USING    fs_afpo LIKE LINE OF gt_afpo
                                fu_add fu_status fu_senum
                       CHANGING fs_post  LIKE LINE OF gt_post.
  FIELD-SYMBOLS <fs>   TYPE ANY.

  DATA : ls_ztspmmdt002   LIKE LINE OF gt_ztspmmdt002,
         ls_mcha          LIKE LINE OF gt_mcha,
         ls_mch1          LIKE LINE OF gt_mch1,
         ls_aufk          LIKE LINE OF gt_aufk,
         ls_jest          LIKE LINE OF gt_jest,
         ls_tj02t         LIKE LINE OF gt_tj02t,
         lv_release,
         ls_t001k         LIKE LINE OF gt_t001k,
         ls_a989          LIKE LINE OF gt_a989,
         ls_konp          LIKE LINE OF gt_konp.

  DATA : lt_data          TYPE zaccttm,
         ls_data          LIKE LINE OF lt_data.
  DATA : lv_count         TYPE int4.

  ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <fs_ltop> TO <fs>.
  <fs> = fs_afpo-aufnr.
  ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_ltop> TO <fs>.
  <fs> = fs_afpo-matnr.
  ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_ltop> TO <fs>.
  <fs> = fs_afpo-dwerk.
  ASSIGN COMPONENT 'CHARG' OF STRUCTURE <fs_ltop> TO <fs>.
  <fs> = fs_afpo-charg.
  ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_ltop> TO <fs>.
  <fs> = fs_afpo-lgort.
  ASSIGN COMPONENT 'PSMNG' OF STRUCTURE <fs_ltop> TO <fs>.
  <fs> = fs_afpo-psmng.
  ASSIGN COMPONENT 'AMEIN' OF STRUCTURE <fs_ltop> TO <fs>.
  <fs> = fs_afpo-amein.

  CLEAR ls_ztspmmdt002.
  READ TABLE gt_ztspmmdt002 INTO ls_ztspmmdt002
                            WITH KEY werks = fs_afpo-dwerk
                                     matnr = fs_afpo-matnr.
  IF sy-subrc = 0.
    ASSIGN COMPONENT 'NIE' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_ztspmmdt002-nie.
    fs_post-nie      = ls_ztspmmdt002-nie.
    fs_post-kemasan  = ls_ztspmmdt002-kemasan.
  ENDIF.

  CLEAR ls_mch1.
  READ TABLE gt_mch1 INTO ls_mch1
                     WITH KEY matnr = fs_afpo-matnr
                              charg = fs_afpo-charg.
  IF sy-subrc = 0.
    ASSIGN COMPONENT 'VFDAT' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_mch1-vfdat.
    ASSIGN COMPONENT 'HSDAT' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = ls_mch1-hsdat.

    fs_post-vfdat = ls_mch1-vfdat.
    fs_post-hsdat = ls_mch1-hsdat.
  ENDIF.

  CLEAR ls_t001k.
  READ TABLE gt_t001k INTO ls_t001k
                      WITH KEY bwkey = fs_afpo-dwerk.
  IF sy-subrc = 0.
    CLEAR ls_a989.
    READ TABLE gt_a989 INTO ls_a989
                       WITH KEY vkorg = ls_t001k-bukrs
                                matnr = fs_afpo-matnr.
    IF sy-subrc = 0.
      CLEAR : ls_konp.
      READ TABLE gt_konp INTO ls_konp
                         WITH KEY knumh = ls_a989-knumh.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'KBETR' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = ls_konp-kbetr.
        fs_post-het   = ls_konp-kbetr.
*        WRITE ls_konp-kbetr TO fs_post-het CURRENCY 'IDR'.
*        TRANSLATE fs_post-het USING '. '.
*        TRANSLATE fs_post-het USING ',.'.
*        CONDENSE fs_post-het NO-GAPS.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      CLEAR ls_aufk.
      READ TABLE gt_aufk INTO ls_aufk WITH KEY aufnr = fs_afpo-aufnr.
      IF sy-subrc = 0.
        CLEAR ls_jest.
        LOOP AT gt_jest INTO ls_jest WHERE objnr = ls_aufk-objnr.
          CLEAR ls_tj02t.
          READ TABLE gt_tj02t INTO ls_tj02t WITH KEY istat = ls_jest-stat.
          IF sy-subrc = 0.
            IF ls_tj02t-txt04 = 'REL'.
              lv_release  = 'X'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN radio2.
      lv_release  = 'X'.
    WHEN radio3.
      lv_release  = 'X'.
  ENDCASE.

  IF lv_release IS NOT INITIAL.
    lv_count  = fu_add.

    CALL METHOD zcl_util=>m_acc_create_sn
      EXPORTING
        pvi_count = lv_count
        pvi_split = 2
      IMPORTING
        pto_data  = lt_data.

    DO fu_add TIMES.
      IF fs_post-vfdat = '00000000' OR
        fs_post-hsdat = '00000000' OR
        fs_post-het IS INITIAL OR
        ls_ztspmmdt002-nie IS INITIAL.
        ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = icon_led_red.

        IF fs_post-vfdat = '00000000'.
          PERFORM f_add_error_message USING fs_afpo 'SLED not yet maintain'.
        ENDIF.
        IF fs_post-hsdat = '00000000'.
          PERFORM f_add_error_message USING fs_afpo 'Manuf. Dte not yet maintain'.
        ENDIF.
        IF fs_post-het IS INITIAL.
          PERFORM f_add_error_message USING fs_afpo 'HET not yet maintain'.
        ENDIF.
        IF fs_post-het IS INITIAL.
          PERFORM f_add_error_message USING fs_afpo 'NIE not yet maintain'.
        ENDIF.
      ELSE.
        IF radio3 IS INITIAL.
          ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = icon_led_green.
        ELSE.
          IF fs_post-meinh1 IS INITIAL AND
            fs_post-meinh2 IS INITIAL AND
            fs_post-meinh3 IS INITIAL AND
            fs_post-meinh4 IS INITIAL AND
            fs_post-meinh5 IS INITIAL.
            ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ltop> TO <fs>.
            <fs> = icon_led_red.

            PERFORM f_add_error_message USING fs_afpo 'Alter UoM not yet maintain'.
          ELSE.
            ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ltop> TO <fs>.
            <fs> = icon_led_green.
          ENDIF.
        ENDIF.
      ENDIF.

      IF fu_senum IS INITIAL.
        READ TABLE lt_data INTO ls_data INDEX sy-index.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'SENUM' OF STRUCTURE <fs_ltop> TO <fs>.
          <fs> = ls_data-senum.
        ENDIF.
      ELSE.
        ls_data-senum = fu_senum.
        ASSIGN COMPONENT 'SENUM' OF STRUCTURE <fs_ltop> TO <fs>.
        <fs> = fu_senum.
      ENDIF.

      ASSIGN COMPONENT 'MEINH1' OF STRUCTURE <fs_ltop> TO <fs>.
      PERFORM f_conversion_uom USING 'INPUT' fs_post-meinh1
                               CHANGING <fs>.
      ASSIGN COMPONENT 'MEINH2' OF STRUCTURE <fs_ltop> TO <fs>.
      PERFORM f_conversion_uom USING 'INPUT' fs_post-meinh2
                               CHANGING <fs>.
      ASSIGN COMPONENT 'MEINH3' OF STRUCTURE <fs_ltop> TO <fs>.
      PERFORM f_conversion_uom USING 'INPUT' fs_post-meinh3
                               CHANGING <fs>.

      PERFORM f_prepare_save USING fs_afpo
                                   ls_data-senum fu_status.
      APPEND <fs_ltop> TO <fs_top>.
    ENDDO.
  ELSE.
    ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ltop> TO <fs>.
    <fs> = icon_led_red.
    APPEND <fs_ltop> TO <fs_top>.

    PERFORM f_add_error_message USING fs_afpo 'not yet released'.
  ENDIF.

  CLEAR : <fs_ltop>, lv_release.
ENDFORM.                    " F_PREPARE_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BATCH_DETAIL
*&---------------------------------------------------------------------*
FORM f_batch_detail TABLES ft_afpo  LIKE gt_afpo.
  DATA : lt_afpo    TYPE STANDARD TABLE OF ty_afpo,
         ls_afpo    LIKE LINE OF lt_afpo.

  SORT ft_afpo BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM ft_afpo COMPARING matnr charg.
  IF ft_afpo[] IS NOT INITIAL.
    SELECT *
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE gt_mch1
      FOR ALL ENTRIES IN ft_afpo
      WHERE matnr = ft_afpo-matnr
        AND charg = ft_afpo-charg
        AND lvorm = space.
  ENDIF.
ENDFORM.                    " F_BATCH_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_NIE
*&---------------------------------------------------------------------*
FORM f_get_nie TABLES ft_afpo   LIKE gt_afpo.
  DATA : lt_afpo    TYPE STANDARD TABLE OF ty_afpo,
         ls_afpo    LIKE LINE OF lt_afpo.

  SORT ft_afpo BY dwerk matnr.
  DELETE ADJACENT DUPLICATES FROM ft_afpo COMPARING dwerk matnr.
  IF ft_afpo[] IS NOT INITIAL.
    SELECT *
      FROM ztspmmdt002
      INTO CORRESPONDING FIELDS OF TABLE gt_ztspmmdt002
      FOR ALL ENTRIES IN ft_afpo
      WHERE werks    = ft_afpo-dwerk
        AND matnr    = ft_afpo-matnr
        AND trandtrc = 'X'.
  ENDIF.
ENDFORM.                    " F_GET_NIE

*&---------------------------------------------------------------------*
*&      Form  F_GET_HET
*&---------------------------------------------------------------------*
FORM f_get_het  TABLES   ft_afpo LIKE gt_afpo.
  DATA : ls_afpo        LIKE LINE OF gt_afpo,
         lt_a989_key    TYPE STANDARD TABLE OF ty_a989_key,
         ls_a989_key    LIKE LINE OF lt_a989_key,
         ls_t001k       LIKE LINE OF gt_t001k.

  LOOP AT ft_afpo INTO ls_afpo.
    READ TABLE gt_t001k INTO ls_t001k
                        WITH KEY bwkey = ls_afpo-dwerk.
    IF sy-subrc = 0.
      ls_a989_key-vkorg   = ls_t001k-bukrs.
      ls_a989_key-matnr   = ls_afpo-matnr.
      ls_a989_key-gstrp   = ls_afpo-gstrp.
      APPEND ls_a989_key TO lt_a989_key.
      CLEAR ls_a989_key.
    ENDIF.
  ENDLOOP.

  IF lt_a989_key[] IS NOT INITIAL.
    SELECT *
      FROM a989
      INTO CORRESPONDING FIELDS OF TABLE gt_a989
      FOR ALL ENTRIES IN lt_a989_key
      WHERE kappl = 'V'
        AND kschl = 'ZHET'
        AND vkorg = lt_a989_key-vkorg
        AND matnr = lt_a989_key-matnr
        AND datab <= lt_a989_key-gstrp
        AND datbi >= lt_a989_key-gstrp.

    IF gt_a989[] IS NOT INITIAL.
      SELECT *
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE gt_konp
        FOR ALL ENTRIES IN gt_a989
        WHERE knumh = gt_a989-knumh.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_HET

*&---------------------------------------------------------------------*
*&      Form  F_REQUEST_BODY
*&---------------------------------------------------------------------*
FORM f_request_body  USING    fs_post   LIKE LINE OF gt_post
                     CHANGING fc_matnr fc_charg fc_senum.
  PERFORM f_json_format USING :
    '{' '' '' '' '',
    '' 'ProcessOrder' fs_post-aufnr '' '',
    '' 'OrderQty' fs_post-psmng 'X' '',
    '' 'Material' fs_post-matnr '' '',
    '' 'Description' fs_post-maktx '' '',
    '' 'Plant' fs_post-werks '' '',
    '' 'SLoc' fs_post-lgort '' '',
    '' 'Kemasan_ID' fs_post-kemasan '' '',
    '' 'NIE' fs_post-nie '' '',
    '' 'GTIN' fs_post-gtin '' '',
    '' 'Batch' fs_post-charg '' '',
    '' 'ED' fs_post-vfdat '' '',
    '' 'SN' fs_post-senum '' '',
    '' 'MD' fs_post-hsdat '' '',
    '' 'HET' fs_post-het 'X' '',

    '' 'Numerator1' fs_post-umrez1 'X' '',
    '' 'BaseUOM1' fs_post-meins1 '' '',
    '' 'Denominator1' fs_post-umren1 'X' '',
    '' 'AltUOM1' fs_post-meinh1 '' '',

    '' 'Numerator2' fs_post-umrez2 'X' '',
    '' 'BaseUOM2' fs_post-meins2 '' '',
    '' 'Denominator2' fs_post-umren2 'X' '',
    '' 'AltUOM2' fs_post-meinh2 '' '',

    '' 'Numerator3' fs_post-umrez3 'X' '',
    '' 'BaseUOM3' fs_post-meins3 '' '',
    '' 'Denominator3' fs_post-umren3 'X' '',
    '' 'AltUOM3' fs_post-meinh3 '' '',

    '' 'Aggregasi1' fs_post-aggr1 '' '',
    '' 'Pack_date1' fs_post-packdat1 '' '',
    '' 'Aggregasi2' fs_post-aggr2 '' '',
    '' 'Pack_date2' fs_post-packdat2 '' '',
    '' '' '' '' '},'.

  fc_matnr  = fs_post-matnr.
  fc_charg  = fs_post-charg.
  fc_senum  = fs_post-senum.
ENDFORM.                    " F_REQUEST_BODY

*&---------------------------------------------------------------------*
*&      Form  F_HTTP_POST
*&---------------------------------------------------------------------*
FORM f_http_post CHANGING fc_subrc.

  DATA : ls_resbody   LIKE LINE OF gt_resbody,
         lv_subrc     TYPE sy-subrc,
         lv_code(10),
         lv_text(100).

  lv_subrc  = 4.

  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri               = gv_uri
      request_entity_body_length = 300
      blankstocrlf               = 'X'
    IMPORTING
      status_code                = lv_code
      status_text                = lv_text
    TABLES
      request_entity_body        = gt_reqbody
      response_entity_body       = gt_resbody
      response_headers           = gt_reshead
      request_headers            = gt_reqhead
    EXCEPTIONS
      connect_failed             = 1
      timeout                    = 2
      internal_error             = 3
      tcpip_error                = 4
      system_failure             = 5
      communication_failure      = 6
      OTHERS                     = 7.

  IF lv_code  = '200' AND
    lv_text = 'OK'.
    CLEAR lv_subrc.
  ENDIF.

  fc_subrc  = lv_subrc.

  CLEAR : gt_reqbody[], gt_reqbody, gt_resbody[], gt_resbody,
          gt_reshead[], gt_reshead, gt_reqhead[], gt_reqhead.
ENDFORM.                    " F_HTTP_POST

*&---------------------------------------------------------------------*
*&      Form  F_JSON_FORMAT
*&---------------------------------------------------------------------*
FORM f_json_format  USING    fu_open fu_fname fu_value fu_nchar
                             fu_close.
  DATA : ls_reqbody   LIKE LINE OF gt_reqbody,
         lv_value(20).

  IF fu_open IS NOT INITIAL.
    ls_reqbody-body   = fu_open.
  ELSEIF fu_close IS NOT INITIAL.
    ls_reqbody-body   = fu_close.
  ELSE.
    IF fu_nchar IS NOT INITIAL.
*      WRITE fu_value TO lv_value UNIT fu_meins.
*      TRANSLATE lv_value USING '. '.
*      TRANSLATE lv_value USING ',.'.
      lv_value  = fu_value.
      CONDENSE lv_value NO-GAPS.
      CONCATENATE '"' fu_fname '":' lv_value ',' INTO ls_reqbody-body.
    ELSE.
      IF fu_fname = 'Pack_date2'.
        CONCATENATE '"' fu_fname '":"' fu_value '"' INTO ls_reqbody-body.
      ELSE.
        CONCATENATE '"' fu_fname '":"' fu_value '",' INTO ls_reqbody-body.
      ENDIF.
    ENDIF.
  ENDIF.
  APPEND ls_reqbody TO gt_reqbody.
  CLEAR ls_reqbody.
ENDFORM.                    " F_JSON_FORMAT

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_material_detail  TABLES   ft_afpo LIKE gt_afpo.
  DATA : lt_afpo    TYPE STANDARD TABLE OF ty_afpo,
         ls_afpo    LIKE LINE OF lt_afpo,
         lr_meins   TYPE RANGE OF meins,
         ls_meins   LIKE LINE OF lr_meins.

  ls_meins-low    = 'EA'.
  ls_meins-sign   = 'E'.
  ls_meins-option = 'EQ'.
  APPEND ls_meins TO lr_meins.
  CLEAR ls_meins.
  ls_meins-low    = 'PAL'.
  ls_meins-sign   = 'E'.
  ls_meins-option = 'EQ'.
  APPEND ls_meins TO lr_meins.
  CLEAR ls_meins.

  SORT ft_afpo BY matnr.
  DELETE ADJACENT DUPLICATES FROM ft_afpo COMPARING matnr.
  IF ft_afpo[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN ft_afpo
      WHERE spras    = sy-langu
        AND matnr    = ft_afpo-matnr.

    SELECT *
      FROM marm
      INTO CORRESPONDING FIELDS OF TABLE gt_marm
      FOR ALL ENTRIES IN ft_afpo
      WHERE matnr = ft_afpo-matnr
        AND meinh IN lr_meins.

    SELECT *
      FROM zaccdtuom
      INTO CORRESPONDING FIELDS OF TABLE gt_auom
      FOR ALL ENTRIES IN ft_afpo
      WHERE werks = pa_dwerk
        AND matnr = ft_afpo-matnr.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_DETAIL
*&---------------------------------------------------------------------*
FORM f_material_detail  USING    fu_matnr fu_werks fu_amein
                        CHANGING fs_post   LIKE LINE OF gt_post.
  DATA : ls_makt    LIKE LINE OF gt_makt.

  CLEAR ls_makt.
  READ TABLE gt_makt INTO ls_makt
                     WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    fs_post-maktx  = ls_makt-maktx.
  ENDIF.

*  PERFORM f_uom_marm USING    fu_matnr fu_amein
*                     CHANGING fs_post.

  PERFORM f_uom_auom USING    fu_matnr fu_werks fu_amein
                     CHANGING fs_post.

**  PERFORM f_unit_of_measure USING fu_matnr fu_amein 'KAR'
**                            CHANGING fs_post-meins1 fs_post-meinh1
**                                     fs_post-umrez1 fs_post-umren1.
***  PERFORM f_unit_of_measure USING fu_matnr fu_amein 'PAL'
***                            CHANGING fs_post-meins2 fs_post-meinh2
***                                     fs_post-umrez2 fs_post-umren2.
ENDFORM.                    " F_MATERIAL_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_OF_MEASURE
*&---------------------------------------------------------------------*
FORM f_unit_of_measure  USING    fu_matnr fu_meins fu_meinh
                        CHANGING fc_meins fc_meinh fc_umrez fc_umren.
  DATA : ls_marm    LIKE LINE OF gt_marm.

  READ TABLE gt_marm INTO ls_marm
                     WITH KEY matnr = fu_matnr
                              meinh = fu_meinh.
  IF sy-subrc = 0.
    fc_umrez = ls_marm-umrez.
*    TRANSLATE fc_umrez USING '. '.
*    TRANSLATE fc_umrez USING ',.'.
*    CONDENSE fc_umrez NO-GAPS.
    fc_umren = ls_marm-umren.
*    TRANSLATE fc_umren USING '. '.
*    TRANSLATE fc_umren USING ',.'.
*    CONDENSE fc_umren NO-GAPS.

    PERFORM f_conversion_uom USING '' fu_meinh
                             CHANGING fc_meinh.
    PERFORM f_conversion_uom USING '' fu_meins
                             CHANGING fc_meins.
  ENDIF.
ENDFORM.                    " F_UNIT_OF_MEASURE

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_UOM
*&---------------------------------------------------------------------*
FORM f_conversion_uom  USING    fu_conversion fu_meins
                       CHANGING fc_meins.

  CASE fu_conversion.
    WHEN 'INPUT'.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = fu_meins
        IMPORTING
          output         = fc_meins
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
    WHEN OTHERS.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = fu_meins
        IMPORTING
          output         = fc_meins
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
  ENDCASE.
ENDFORM.                    " F_CONVERSION_UOM

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_POST_HTTP
*&---------------------------------------------------------------------*
FORM f_prepare_post_http  USING    fs_afpo   LIKE LINE OF gt_afpo
                                   fs_post   LIKE LINE OF gt_post
                                   fu_senum.

  DATA : ls_post    LIKE LINE OF gt_post.

  ls_post-aufnr     = fs_afpo-aufnr.
  ls_post-psmng     = fs_afpo-psmng.
*  WRITE fs_afpo-psmng TO ls_post-psmng UNIT fs_afpo-amein.
*  TRANSLATE ls_post-psmng USING '. '.
*  TRANSLATE ls_post-psmng USING ',.'.
*  CONDENSE ls_post-psmng NO-GAPS.
  ls_post-matnr     = fs_afpo-matnr.
  ls_post-maktx     = fs_post-maktx.
  ls_post-werks     = fs_afpo-dwerk.
  ls_post-lgort     = fs_afpo-lgort.
  ls_post-kemasan   = fs_post-kemasan.
  ls_post-nie       = fs_post-nie.
  ls_post-gtin      = fs_post-gtin.
  ls_post-charg     = fs_afpo-charg.
  ls_post-vfdat     = fs_post-vfdat.
  ls_post-senum     = fu_senum.
  ls_post-hsdat     = fs_post-hsdat.
  ls_post-het       = fs_post-het.

  ls_post-umrez1    = fs_post-umrez1.
  ls_post-meins1    = fs_post-meins1.
  ls_post-umren1    = fs_post-umren1.
  ls_post-meinh1    = fs_post-meinh1.

  ls_post-umrez2    = fs_post-umrez2.
  ls_post-meins2    = fs_post-meins2.
  ls_post-umren2    = fs_post-umren2.
  ls_post-meinh2    = fs_post-meinh2.

  ls_post-umrez3    = fs_post-umrez3.
  ls_post-meins3    = fs_post-meins3.
  ls_post-umren3    = fs_post-umren3.
  ls_post-meinh3    = fs_post-meinh3.

  ls_post-aggr1     = fs_post-aggr1.
  ls_post-packdat1  = fs_post-packdat1.
  ls_post-aggr2     = fs_post-aggr2.
  ls_post-packdat2  = fs_post-packdat2.
  APPEND ls_post TO gt_post.
  CLEAR ls_post.
ENDFORM.                    " F_PREPARE_POST_HTTP

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FR_API
*&---------------------------------------------------------------------*
FORM f_upload_fr_api  USING    fu_uri.
  DATA : lv_uri(1000),
         temp_json          TYPE string,
         lv_str             TYPE string,
         writer             TYPE REF TO cl_sxml_string_writer,
         xml                TYPE xstring,
         ls_rif_ex          TYPE REF TO cx_root,
         ls_reqhead         LIKE LINE OF gt_reqhead,
         ls_var_text        TYPE string.

  DATA : lt_xml    TYPE abap_trans_resbind_tab,
         ls_xml    TYPE abap_trans_resbind.

*  CONCATENATE fu_uri gv_token INTO lv_uri.
  CLEAR : gt_reqbody[], gt_resbody[],
          gt_reshead[], gt_reqhead[].

  ls_reqhead-header = 'Content-Type: application/json'.
  APPEND ls_reqhead TO gt_reqhead.

  CALL FUNCTION 'HTTP_POST'
    EXPORTING
      absolute_uri                = fu_uri
      request_entity_body_length  = 300
      blankstocrlf                = 'X'
    IMPORTING
      status_code                 = status_code
      status_text                 = status_text
      response_entity_body_length = len
    TABLES
      request_entity_body         = gt_reqbody
      response_entity_body        = gt_resbody
      response_headers            = gt_reshead
      request_headers             = gt_reqhead
    EXCEPTIONS
      connect_failed              = 1
      timeout                     = 2
      internal_error              = 3
      tcpip_error                 = 4
      data_error                  = 5
      system_failure              = 6
      communication_failure       = 7
      OTHERS                      = 8.

  IF sy-subrc = 0.
    LOOP AT gt_resbody INTO temp_json.
      CONDENSE : temp_json, lv_str.
      CONCATENATE lv_str temp_json INTO lv_str.
      REPLACE ALL OCCURRENCES OF REGEX 'null' IN lv_str WITH '" "'.
    ENDLOOP.

    writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ).
    TRY.
        CALL TRANSFORMATION id SOURCE XML lv_str
                               RESULT XML writer.
        xml = writer->get_output( ).
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error JSON to XML: ', ls_var_text.
    ENDTRY.

    TRY.
        CALL TRANSFORMATION zacc_ackno_poly SOURCE XML xml
                                            RESULT ackno = gt_ackno.
      CATCH cx_root INTO ls_rif_ex.
        ls_var_text = ls_rif_ex->get_text( ).
*        WRITE: / 'Message Error XML to ITAB: ', ls_var_text.
    ENDTRY.
  ENDIF.
ENDFORM.                    " F_UPLOAD_FR_API

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_add_error_message  USING    fs_afpo  LIKE LINE OF gt_afpo
                                   fu_message.
  DATA : ls_message  LIKE LINE OF gt_message.

  ls_message-icon     = icon_led_red.
  ls_message-aufnr    = fs_afpo-aufnr.
  ls_message-matnr    = fs_afpo-matnr.
  ls_message-charg    = fs_afpo-charg.
  ls_message-message  = fu_message.
  APPEND ls_message TO gt_message.
ENDFORM.                    " F_ADD_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
FORM f_display_message .
  DATA : ls_selfield  TYPE slis_selfield,
         lv_exit.

  IF gt_message[] IS NOT INITIAL.
    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title                 = 'List message'
        i_selection             = space
        i_allow_no_selection    = 'X'
        i_zebra                 = 'X'
        i_screen_start_column   = 2
        i_screen_start_line     = 2
        i_screen_end_column     = 150
        i_screen_end_line       = 15
        i_tabname               = 'GT_MESSAGE'
        i_structure_name        = 'ZACCPPST001'
        i_callback_program      = gv_repid
        i_callback_user_command = 'F_CALLBACK_USER_COMMAND'
      IMPORTING
        es_selfield             = ls_selfield
        e_exit                  = lv_exit
      TABLES
        t_outtab                = gt_message
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.
  ENDIF.
ENDFORM.                    " F_DISPLAY_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_UOM_MARM
*&---------------------------------------------------------------------*
FORM f_uom_marm  USING    fu_matnr fu_amein
                 CHANGING fs_post   LIKE LINE OF gt_post.

  DATA : ls_marm    LIKE LINE OF gt_marm.

  DATA : lv_count   TYPE i.

  SORT gt_marm BY matnr umrez umren DESCENDING.
  LOOP AT gt_marm INTO ls_marm.
    IF ls_marm-umrez = 1 AND
      ls_marm-umren = 1.
      CONTINUE.
    ENDIF.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_marm-meinh
                                  CHANGING fs_post-meins1 fs_post-meinh1
                                           fs_post-umrez1 fs_post-umren1.
      WHEN 2.
        PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_marm-meinh
                                  CHANGING fs_post-meins2 fs_post-meinh2
                                           fs_post-umrez2 fs_post-umren2.
      WHEN 3.
        PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_marm-meinh
                                  CHANGING fs_post-meins3 fs_post-meinh3
                                           fs_post-umrez3 fs_post-umren3.
      WHEN 4.
        PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_marm-meinh
                                  CHANGING fs_post-meins4 fs_post-meinh4
                                           fs_post-umrez4 fs_post-umren4.
      WHEN 5.
        PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_marm-meinh
                                  CHANGING fs_post-meins5 fs_post-meinh5
                                           fs_post-umrez5 fs_post-umren5.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_UOM_MARM

*&---------------------------------------------------------------------*
*&      Form  F_UOM_AUOM
*&---------------------------------------------------------------------*
FORM f_uom_auom  USING    fu_matnr fu_werks fu_amein
                 CHANGING fs_post   LIKE LINE OF gt_post.

  DATA : ls_auom    LIKE LINE OF gt_auom.

  READ TABLE gt_auom  INTO ls_auom
                      WITH KEY werks = fu_werks
                               matnr = fu_matnr.
  IF sy-subrc = 0.
    PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_auom-meinh1
                              CHANGING fs_post-meins1 fs_post-meinh1
                                       fs_post-umrez1 fs_post-umren1.
    PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_auom-meinh2
                              CHANGING fs_post-meins2 fs_post-meinh2
                                       fs_post-umrez2 fs_post-umren2.
    PERFORM f_unit_of_measure USING fu_matnr fu_amein ls_auom-meinh3
                              CHANGING fs_post-meins3 fs_post-meinh3
                                       fs_post-umrez3 fs_post-umren3.
  ENDIF.
ENDFORM.                    " F_UOM_AUOM

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PACKMAT
*&---------------------------------------------------------------------*
FORM f_check_packmat  USING    fu_amein.
  DATA : lt_xresb   TYPE STANDARD TABLE OF resb,
         ls_xresb   LIKE LINE OF lt_xresb.

  DATA : ls_resb    LIKE LINE OF gt_resb,
         ls_makt    LIKE LINE OF gt_makt.

  DATA : lv_meins   TYPE mara-meins,
         lv_lines   TYPE i,
         lv_label.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_amein
    IMPORTING
      output         = lv_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  LOOP AT gt_resb INTO ls_resb.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_resb-matnr.
    CASE lv_meins.
      WHEN 'TUB' OR 'FBX' OR 'BOX' OR 'BX'.
        IF ls_makt-maktx NP '*FB*'.
          DELETE TABLE gt_resb FROM ls_resb.
        ENDIF.
      WHEN 'BT'.
        IF ls_makt-maktx CP '*LABEL*'.
          APPEND ls_resb TO lt_xresb.
        ELSE.
          DELETE TABLE gt_resb FROM ls_resb.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  SORT lt_xresb BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING matnr.
  DESCRIBE TABLE lt_xresb LINES lv_lines.
  IF lv_lines > 1.
  ENDIF.
  LOOP AT lt_xresb INTO ls_xresb.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt
                       WITH KEY matnr = ls_xresb-matnr.
    IF sy-subrc = 0.
      TRANSLATE ls_makt-maktx TO UPPER CASE.
      IF ls_makt-maktx NP '*BACK*'.
        DELETE gt_resb WHERE matnr = ls_xresb-matnr.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR lt_xresb[].
  lt_xresb[] = gt_resb[].
  CLEAR : gt_resb[], ls_resb.
  SORT lt_xresb BY rsnum matnr.
  LOOP AT lt_xresb INTO ls_xresb.
    ls_resb-rsnum = ls_xresb-rsnum.
    ls_resb-matnr = ls_xresb-matnr.
    ls_resb-bdmng = ls_xresb-bdmng.
    COLLECT ls_resb INTO gt_resb.
    CLEAR ls_resb.
  ENDLOOP.
ENDFORM.                    " F_CHECK_PACKMAT
