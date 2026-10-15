*&---------------------------------------------------------------------*
*&  Include           ZMMPIDDCCBRANCHF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  PERFORM f_modify_screen USING : '' '' ''.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_mess(100),
         ls_t001w   LIKE LINE OF gt_t001w,
         lv_actvt   TYPE tact-actvt.

  SELECT *
    FROM t001w
    INTO CORRESPONDING FIELDS OF TABLE gt_t001w
    WHERE werks IN so_werks.

  IF gt_t001w IS NOT INITIAL.
    LOOP AT gt_t001w INTO ls_t001w.
      AUTHORITY-CHECK OBJECT 'M_MSEG_WMB'
        ID 'ACTVT' FIELD '01' "lv_actvt
        ID 'WERKS' FIELD ls_t001w-werks.
      IF sy-subrc NE 0.
        CONCATENATE 'You are not authorized for Plant'
                    ls_t001w-werks
               INTO lv_mess.
        PERFORM f_error_message USING 'SWE' lv_mess.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA lv_mess(100) VALUE 'Fill in all required entry fields'.

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
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
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
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_batch             TYPE STANDARD TABLE OF ty_material,
         lt_nbatch            TYPE STANDARD TABLE OF ty_material.

  IF pa_lvorm IS INITIAL.
    SELECT mara~matnr mara~meins mara~xchpf marc~werks
      FROM mara JOIN marc ON mara~matnr = marc~matnr
      INTO TABLE gt_material
      WHERE mara~matnr IN so_matnr
        AND mara~mtart IN so_mtart
        AND mara~matkl IN so_matkl
        AND marc~werks IN so_werks
        AND marc~lvorm = space.
  ELSE.
    SELECT mara~matnr mara~meins mara~xchpf marc~werks
      FROM mara JOIN marc ON mara~matnr = marc~matnr
      INTO TABLE gt_material
      WHERE mara~matnr IN so_matnr
        AND mara~mtart IN so_mtart
        AND mara~matkl IN so_matkl
        AND marc~werks IN so_werks.
  ENDIF.

  lt_batch[] = gt_material[].
  lt_nbatch[] = gt_material[].
  DELETE lt_batch WHERE xchpf IS INITIAL.
  DELETE lt_nbatch WHERE xchpf IS NOT INITIAL.

  IF lt_batch[] IS NOT INITIAL.
    SELECT *
      FROM mchb
      INTO CORRESPONDING FIELDS OF TABLE gt_mchb
      FOR ALL ENTRIES IN lt_batch
      WHERE matnr = lt_batch-matnr
        AND werks = lt_batch-werks
        AND lgort IN so_lgort
        AND charg IN so_charg.
    SELECT *
      FROM zmdcc_branch
      INTO CORRESPONDING FIELDS OF TABLE gt_zmdcc
      FOR ALL ENTRIES IN lt_batch
      WHERE matnr  = lt_batch-matnr
        AND werks  = lt_batch-werks
        AND lgort  IN so_lgort
        AND charg  IN so_charg
        AND zfinal = space
        AND xloek  = space.
  ENDIF.

  IF lt_nbatch[] IS NOT INITIAL.
    SELECT *
      FROM mard
      INTO CORRESPONDING FIELDS OF TABLE gt_mard
      FOR ALL ENTRIES IN lt_nbatch
      WHERE matnr = lt_nbatch-matnr
        AND werks = lt_nbatch-werks
        AND lgort IN so_lgort.
    SELECT *
      FROM zmdcc_branch
      APPENDING CORRESPONDING FIELDS OF TABLE gt_zmdcc
      FOR ALL ENTRIES IN lt_nbatch
      WHERE matnr  = lt_nbatch-matnr
        AND werks  = lt_nbatch-werks
        AND lgort  IN so_lgort
        AND zfinal = space
        AND xloek  = space.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_save       LIKE LINE OF gt_save,
         ls_mchb       LIKE LINE OF gt_mchb,
         ls_mard       LIKE LINE OF gt_mard,
         lv_count      TYPE iseg-zeili,
         ls_material   LIKE LINE OF gt_material,
         lv_iblnr      TYPE iseg-iblnr,
         lv_zeili      TYPE iseg-zeili,
         lv_retcd      TYPE inri-returncode.

  CLEAR lv_count.
  LOOP AT gt_mchb INTO ls_mchb.
    ls_save-gjahr = sy-datum(4).
    ls_save-werks = ls_mchb-werks.
    ls_save-matnr = ls_mchb-matnr.
    ls_save-lgort = ls_mchb-lgort.
    ls_save-charg = ls_mchb-charg.
    ls_save-buchm = ls_mchb-clabs + ls_mchb-cinsm + ls_mchb-cspem.
    IF ls_save-buchm IS INITIAL.
      CONTINUE.
    ENDIF.
    READ TABLE gt_zmdcc WITH KEY matnr = ls_mchb-matnr
                                 charg = ls_mchb-charg
                                 werks = ls_mchb-werks
                                 lgort = ls_mchb-lgort
                                 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CLEAR ls_material.
    READ TABLE gt_material INTO ls_material
                           WITH KEY matnr = ls_mchb-matnr.
    IF sy-subrc = 0.
      ls_save-meins = ls_material-meins.
    ENDIF.

    ls_save-erdat  = sy-datum.
    ls_save-erzet  = sy-uzeit.
    ls_save-zuser1 = sy-uname.
    APPEND ls_save TO gt_save.
    CLEAR ls_save.
  ENDLOOP.

  CLEAR ls_mard.
  LOOP AT gt_mard INTO ls_mard.
    ls_save-gjahr = sy-datum(4).
    ls_save-werks = ls_mard-werks.
    ls_save-matnr = ls_mard-matnr.
    ls_save-lgort = ls_mard-lgort.
    ls_save-buchm = ls_mard-labst + ls_mard-insme + ls_mard-speme.
    IF ls_save-buchm IS INITIAL.
      CONTINUE.
    ENDIF.
    READ TABLE gt_zmdcc WITH KEY matnr = ls_mard-matnr
                                 werks = ls_mard-werks
                                 lgort = ls_mard-lgort
                                 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CLEAR ls_material.
    READ TABLE gt_material INTO ls_material
                           WITH KEY matnr = ls_mard-matnr.
    IF sy-subrc = 0.
      ls_save-meins = ls_material-meins.
    ENDIF.

    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-zuser1 = sy-uname.
    APPEND ls_save TO gt_save.
    CLEAR ls_save.
  ENDLOOP.

  SORT gt_save BY werks lgort matnr charg.

*  LOOP AT gt_save INTO ls_save.
*    ASSIGN COMPONENT 'IBLNR'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-iblnr.
*    ASSIGN COMPONENT 'GJAHR'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-gjahr.
*    ASSIGN COMPONENT 'ZEILI'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-zeili.
*    ASSIGN COMPONENT 'WERKS'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-werks.
*    ASSIGN COMPONENT 'LGORT'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-lgort.
*    ASSIGN COMPONENT 'MATNR'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-matnr.
*    ASSIGN COMPONENT 'CHARG'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-charg.
*    ASSIGN COMPONENT 'MEINS'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-meins.
*    ASSIGN COMPONENT 'BUCHM'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-buchm.
*    ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-menge.
*    ASSIGN COMPONENT 'ERDAT'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-erdat.
*    ASSIGN COMPONENT 'ERZET'  OF STRUCTURE <fs_gs> TO <fs>.
*    <fs> = ls_save-erzet.
*    APPEND <fs_gs> TO <fs_gt>.
*    CLEAR : <fs_gs>.
*  ENDLOOP.
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
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CLEAR : fcode, fcode[].

  IF gv_pos IS NOT INITIAL.
    APPEND '&POS' TO fcode.
  ENDIF.

  SET TITLEBAR 'TITLE'.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
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
        container = g_contain.

*    CALL METHOD g_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = g_contain02.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  IF g_tabgrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_tabgrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_contain.

    PERFORM f_build_layout.
    PERFORM f_build_sort.

    gs_variant-report = gv_repid.

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
        it_outtab            = gt_save[]
        it_fieldcatalog      = gt_main_fieldcat[].
*  ELSE.
*    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-box_fname            = 'CHECK'.
  gs_layout_alv-zebra                = selected.
  gs_layout_alv-cwidth_opt           = selected.
  gs_layout_alv-s_dragdrop-row_ddid  = g_handle_alv.
  gs_layout_alv-no_toolbar           = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort .
  CLEAR gt_main_sort.

ENDFORM.                    " F_BUILD_SORT

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
  DATA : lv_ucomm   TYPE sy-ucomm.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN '&LOG'.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_error.

    WHEN '&POS'.
      PERFORM f_save_data.
      CALL METHOD g_tabgrid->refresh_table_display.
      gv_pos  = selected.
      MESSAGE s000(zab) WITH 'Data already processed'.

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table .
  DATA : lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data,
         ls_tab        TYPE dfies,
         lv_pos        TYPE i,
         ls_dyn_fcat   TYPE lvc_s_fcat.

  PERFORM f_get_field USING 'ZMDCC_BRANCH'.
  LOOP AT dfies_tab INTO ls_tab.
    MOVE-CORRESPONDING ls_tab TO ls_dyn_fcat.
    CASE ls_tab-fieldname.
      WHEN 'MANDT' OR 'ZUSER1' OR 'ZCOUDT' OR 'ZCOUZT' OR
           'ZCOUUN' OR 'ZFINDT' OR 'ZFINZT' OR 'ZFINUN' OR
           'ZFINAL' OR 'XLOEK' OR 'ZSESSI'.
        CONTINUE.
      WHEN 'BUCHM' OR 'MENGE'.
        lv_pos = lv_pos + 1.
        ls_dyn_fcat-qfieldname  = 'MEINS'.
      WHEN OTHERS.
        lv_pos = lv_pos + 1.
    ENDCASE.
    ls_dyn_fcat-col_pos     = lv_pos.
    APPEND ls_dyn_fcat TO gt_main_fieldcat.
    CLEAR ls_dyn_fcat.
  ENDLOOP.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_main_fieldcat
      i_length_in_byte          = 'X'
      i_style_table             = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_gt>.
    CREATE DATA ls_line LIKE LINE OF <fs_gt>.
    ASSIGN ls_line->* TO <fs_gs>.
  ENDIF.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_FIELD
*&---------------------------------------------------------------------*
FORM f_get_field  USING    tabname.
  CLEAR : dfies_tab[], dfies_tab.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = tabname
    TABLES
      dfies_tab      = dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
ENDFORM.                    " F_GET_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA : lv_zeili   TYPE iseg-zeili,
         lv_retcd   TYPE inri-returncode,
         lv_iblnr   TYPE iseg-iblnr,
         ls_save    LIKE LINE OF gt_save.

  LOOP AT gt_save INTO ls_save.
    ON CHANGE OF ls_save-werks OR ls_save-lgort.
      CLEAR lv_zeili.
    ENDON.
    ADD 1 TO lv_zeili.
    IF lv_zeili = 1.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZMDCCBRANC'
        IMPORTING
          returncode  = lv_retcd
          number      = lv_iblnr.
    ENDIF.
    ls_save-iblnr = lv_iblnr.
    ls_save-zeili = lv_zeili.
    MODIFY gt_save FROM ls_save TRANSPORTING iblnr zeili.
    IF lv_zeili = pa_zeili.
      CLEAR lv_zeili.
    ENDIF.
  ENDLOOP.

  TRY .
      MODIFY zmdcc_branch FROM TABLE gt_save.
    CATCH cx_root.
  ENDTRY.

ENDFORM.                    " F_SAVE_DATA
