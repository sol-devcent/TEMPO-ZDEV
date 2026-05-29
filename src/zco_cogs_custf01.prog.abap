*&---------------------------------------------------------------------*
*&  Include           ZCO_COGS_CUSTF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
*  PERFORM f_modify_screen USING : 'XXX' '0' ''.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
*  PERFORM f_screen_error USING 'XXX'.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

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
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lr_budat   TYPE RANGE OF budat,
         ls_budat   LIKE LINE OF lr_budat.

  SELECT SINGLE name1
    FROM t001w
    INTO gv_name1
    WHERE werks = pa_werks.

  CONCATENATE pa_gjahr pa_monat '01' INTO ls_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_budat-low
    IMPORTING
      last_day_of_month = ls_budat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  ls_budat-sign   = 'I'.
  ls_budat-option = 'BT'.
  APPEND ls_budat TO lr_budat.

  SELECT mblnr mjahr budat
    FROM mkpf
    INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
    WHERE budat IN lr_budat.

  IF gt_mkpf[] IS NOT INITIAL.
    SELECT mblnr gjahr zeile bwart matnr werks shkzg meins menge kunnr
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE gt_mseg
      FOR ALL ENTRIES IN gt_mkpf
      WHERE mblnr = gt_mkpf-mblnr
        AND mjahr = gt_mkpf-mjahr
        AND werks = pa_werks.

    DELETE gt_mseg WHERE kunnr IS INITIAL.

    PERFORM f_get_material_ledger.

    PERFORM f_get_description USING 'MAKT' 'MATNR'.
    PERFORM f_get_description USING 'KNA1' 'KUNNR'.

    PERFORM f_get_billing_doc.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_out     TYPE STANDARD TABLE OF mseg INITIAL SIZE 0,
         ls_out     TYPE mseg,
         ls_mseg    TYPE mseg,
         ls_makt    TYPE makt,
         ls_kna1    TYPE kna1,
         ls_mbew    TYPE mbew,
         ls_mlcd    TYPE mlcd,
         lv_salk3   TYPE p DECIMALS 5.

  DATA : lt_bwart TYPE STANDARD TABLE OF selopt INITIAL SIZE 0.

  PERFORM f_range_bwart TABLES lt_bwart.

  SORT gt_vbrk BY kunag.
  SORT gt_mseg BY matnr kunnr mblnr.
  lt_out[]  = gt_mseg[].
  SORT lt_out BY matnr kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr kunnr.

  "Start SOH Adjustment 20240808
  SORT gt_mbew BY matnr bwkey.
  SORT gt_mlcd BY kalnr.
  "End SOH Adjustment 20240808

  LOOP AT lt_out INTO ls_out.
    gs_out-matnr  = ls_out-matnr.
    CLEAR ls_makt.
    READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_out-matnr.
    IF sy-subrc = 0.
      gs_out-maktx  = ls_makt-maktx.
    ENDIF.
    gs_out-meins  = ls_out-meins.
    gs_out-kunnr  = ls_out-kunnr.
    CLEAR ls_kna1.
    READ TABLE gt_kna1 INTO ls_kna1 WITH KEY kunnr = ls_out-kunnr.
    IF sy-subrc = 0.
      gs_out-name1  = ls_kna1-name1.
    ENDIF.

    LOOP AT gt_mseg INTO ls_mseg WHERE matnr = ls_out-matnr
                                   AND kunnr = ls_out-kunnr.
      IF ls_mseg-bwart IN lt_bwart.
        IF ls_mseg-shkzg = 'S'.
          ls_mseg-menge = ls_mseg-menge * -1.
        ENDIF.
        ADD ls_mseg-menge TO gs_out-lbkum.
      ENDIF.
    ENDLOOP.

    LOOP AT gt_vbrk WHERE kunag = ls_out-kunnr.
      LOOP AT gt_vbrp WHERE vbeln = gt_vbrk-vbeln
                        AND matnr = ls_out-matnr.
        IF gt_vbrp-shkzg = 'X'.
          gt_vbrp-kzwi1 = gt_vbrp-kzwi1 * -1.
        ENDIF.
        ADD gt_vbrp-kzwi1 TO gs_out-kzwi1.
      ENDLOOP.
    ENDLOOP.

    READ TABLE gt_mbew INTO ls_mbew WITH KEY matnr = ls_out-matnr
                                             bwkey = pa_werks.
    IF sy-subrc = 0.
      CLEAR : ls_mlcd, lv_salk3.
      READ TABLE gt_mlcd INTO ls_mlcd WITH KEY kalnr = ls_mbew-kaln1.
      IF sy-subrc = 0.
        gs_out-waers  = ls_mlcd-waers.
        IF ls_mlcd-lbkum IS NOT INITIAL.
          gs_out-salkv = ( ( ls_mlcd-salk3 + ls_mlcd-estprd + ls_mlcd-estkdm ) / ls_mlcd-lbkum ) * gs_out-lbkum.
        ENDIF.
      ENDIF.
    ENDIF.

*    gs_out-salkv  = lv_salk3 * gs_out-lbkum.

    APPEND gs_out TO gt_out.
    CLEAR gs_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.

  CLEAR : fcode, fcode[].
  IF gt_error[] IS INITIAL.
    APPEND '&LOG'  TO fcode.
    SET PF-STATUS 'PF_STATUS' EXCLUDING fcode.
  ELSE.
    SET PF-STATUS 'PF_STATUS'.
  ENDIF.

  SET TITLEBAR 'TITLE'.
  PERFORM f_excluding_toolbar.
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
        container = g_container.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut .
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  MAIN_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE main_alv OUTPUT.
  IF g_maingrid IS INITIAL.
    CREATE OBJECT event_receiver.

    CREATE OBJECT g_maingrid
      EXPORTING
        i_appl_events = selected
        i_parent      = g_container.

    PERFORM f_build_fieldcat USING 'MAIN'.
    PERFORM f_build_layout USING 'MAIN'.
    PERFORM f_build_sort_tab_grid USING 'MAIN'.

    gs_variant-report = gv_repid.

    SET HANDLER event_receiver->handle_double_click FOR g_maingrid.

*                event_receiver->handle_hotspot_click FOR g_grid1.
*
*    SET HANDLER event_receiver->handle_user_command1
*                event_receiver->handle_menu_button1
*                event_receiver->handle_toolbar1 FOR g_grid1.
*
    CALL METHOD g_maingrid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_alv
        i_save               = 'A'
        is_variant           = gs_variant
        i_default            = 'X'
        it_toolbar_excluding = gs_exclude
      CHANGING
        it_sort              = gt_main_sort[]
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_main_fieldcat[].

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_maingrid.

    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.

  PERFORM f_alv_refresh USING 'X'.
ENDMODULE.                 " MAIN_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat USING fu_container.
  CLEAR : gt_main_fieldcat[], gt_main_fieldcat.

  CASE fu_container.
    WHEN 'MAIN'.
      PERFORM f_fieldcat USING 'GT_OUT' :
        'MATNR' 'MSEG' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'KUNNR' 'MSEG' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '' 'Customer Name' '' '' '' '' '' '' ''
        '' '' '' '' '' '' '',
        'LBKUM' '' '' '' '15' 'COGS Qty' 'X' '' '' '' '' '' 'MEINS'
        '' '' '' '' '' '' '',
        'KZWI1' '' '' '' '15' 'NET Sales Value' 'X' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' '' '',
        'SALKV' '' '' '' '15' 'COGS Value' 'X' '' '' '' '' 'WAERS' ''
        '' '' '' '' '' '' ''.
  ENDCASE.

ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refr01.
  IF fu_refr01 IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD g_maingrid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcat  USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_colpos)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_icon)
                          value(fu_just)
                          value(fu_edit)
                          value(fu_colopt)
                          value(fu_emphasize).

  DATA: ld_fieldcat  TYPE  lvc_s_fcat.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-scrtext_l         = fu_fltxt.
  ld_fieldcat-scrtext_m         = fu_fltxt.
  ld_fieldcat-scrtext_s         = fu_fltxt.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-col_pos           = fu_colpos.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-just              = fu_just.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-emphasize         = fu_emphasize.

  CASE fu_types.
    WHEN 'GT_OUT'.
      APPEND ld_fieldcat TO gt_main_fieldcat.
  ENDCASE.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout  USING    fu_layout.
  gs_layout_alv-zebra               = selected.
  CASE fu_layout.
    WHEN 'MAIN'.
      gs_layout_alv-box_fname           = 'CHECK'.
*      gs_layout_alv-totals_bef          = selected.
  ENDCASE.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
*  gs_layout_alv-no_rowmark          = selected.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT_TAB_GRID
*&---------------------------------------------------------------------*
FORM f_build_sort_tab_grid  USING    fu_sort.
  CLEAR gt_main_sort.

  CASE fu_sort.
    WHEN 'MAIN'.
      gt_main_sort-spos = 1.
      gt_main_sort-fieldname = 'MATNR'.
      gt_main_sort-up        = selected.
      gt_main_sort-subtot    = selected.
      APPEND gt_main_sort.
      CLEAR gt_main_sort.

      gt_main_sort-spos = 2.
      gt_main_sort-fieldname = 'KUNNR'.
      gt_main_sort-up        = selected.
      gt_main_sort-subtot    = selected.
      APPEND gt_main_sort.
      CLEAR gt_main_sort.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT_TAB_GRID

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF NOT g_container IS INITIAL.
        CALL METHOD g_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        CLEAR : g_container, g_maingrid.
      ENDIF.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CALL FUNCTION 'BUFFER_REFRESH_ALL'.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  HEADER  OUTPUT
*&---------------------------------------------------------------------*
MODULE header OUTPUT.
  DATA : lr_rows      TYPE REF TO cl_salv_form_layout_grid,
         lr_element   TYPE REF TO cl_salv_form_element,
         lr_container TYPE REF TO cl_gui_container,
         lr_dydos     TYPE REF TO cl_salv_form_dydos.

  CREATE OBJECT lr_rows.

  g_content = lr_rows.

  CLEAR lr_element.
  PERFORM header_line CHANGING lr_element.
  lr_rows->set_element( r_element = lr_element
                        row       = 1
                        column    = 1 ).

  CREATE OBJECT lr_container
    TYPE
      cl_gui_custom_container
    EXPORTING
      container_name          = 'CC_HEADER'.

  CREATE OBJECT lr_dydos
    EXPORTING
      r_container = lr_container
      r_content   = g_content.

  lr_dydos->display( ).
ENDMODULE.                 " HEADER  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  HEADER_LINE
*&---------------------------------------------------------------------*
FORM header_line  CHANGING cr_element TYPE REF TO cl_salv_form_element.

  DATA: lr_rows   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_1 TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_2 TYPE REF TO cl_salv_form_layout_grid,
        lr_label  TYPE REF TO cl_salv_form_label,
        lr_text   TYPE REF TO cl_salv_form_text.

  CREATE OBJECT lr_rows.

  lr_grid = lr_rows->create_grid(
              row    = 3
              column = 1 ).
  lr_grid_1 = lr_grid->create_grid(
    row    = 1
    column = 1 ).
  lr_grid_2 = lr_grid->create_grid(
    row    = 1
    column = 2 ).

  lr_label = lr_grid_1->create_label(
    row    = 1
    column = 1
    text   = text-t06 ).
  lr_text = lr_grid_1->create_text(
    row    = 1
    column = 2
    text   = pa_werks ).
  lr_grid_1->create_text(
    row    = 1
    column = 3
    text   = gv_name1 ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_1->create_label(
    row    = 2
    column = 1
    text   = text-t08 ).
  lr_text = lr_grid_1->create_text(
    row    = 2
    column = 2
    text   = pa_monat ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_1->create_label(
    row    = 3
    column = 1
    text   = text-t07 ).
  lr_text = lr_grid_1->create_text(
    row    = 3
    column = 2
    text   = pa_gjahr ).
  lr_label->set_label_for( lr_text ).

  lr_rows->add_row( ).

  cr_element = lr_rows.
ENDFORM.                    " HEADER_LINE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DESCRIPTION
*&---------------------------------------------------------------------*
FORM f_get_description  USING    fu_table fu_field.
  DATA : lt_desc  TYPE STANDARD TABLE OF mseg INITIAL SIZE 0.

  lt_desc[] = gt_mseg[].
  SORT lt_desc BY (fu_field).
  DELETE ADJACENT DUPLICATES FROM lt_desc COMPARING (fu_field).

  IF lt_desc[] IS NOT INITIAL.
    CASE fu_table.
      WHEN 'MAKT'.
        SELECT matnr maktx
          FROM (fu_table)
          INTO CORRESPONDING FIELDS OF TABLE gt_makt
          FOR ALL ENTRIES IN lt_desc
          WHERE matnr = lt_desc-matnr
            AND spras = sy-langu.

      WHEN 'KNA1'.
        SELECT kunnr name1
          FROM (fu_table)
          INTO CORRESPONDING FIELDS OF TABLE gt_kna1
          FOR ALL ENTRIES IN lt_desc
          WHERE kunnr = lt_desc-kunnr.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GET_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_LEDGER
*&---------------------------------------------------------------------*
FORM f_get_material_ledger .
  DATA : lt_mbew    TYPE STANDARD TABLE OF mseg INITIAL SIZE 0,
         lt_mlcd    TYPE STANDARD TABLE OF mbew INITIAL SIZE 0,
         lv_bdatj   TYPE ckmlpp-bdatj,
         lv_poper   TYPE ckmlpp-poper.

  lv_bdatj  = pa_gjahr.
  lv_poper  = pa_monat.

  lt_mbew[] = gt_mseg[].
  SORT lt_mbew BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_mbew COMPARING matnr werks.

  IF lt_mbew[] IS NOT INITIAL.
    SELECT matnr bwkey bwtar kaln1 peinh
      FROM mbew
      INTO CORRESPONDING FIELDS OF TABLE gt_mbew
      FOR ALL ENTRIES IN lt_mbew
      WHERE matnr = lt_mbew-matnr
        AND bwkey = lt_mbew-werks.

    lt_mlcd[] = gt_mbew[].
    SORT lt_mlcd BY kalnr.
    DELETE ADJACENT DUPLICATES FROM lt_mlcd COMPARING kaln1.

    IF lt_mlcd[] IS NOT INITIAL.
      SELECT kalnr bdatj poper untper categ ptyp bvalt curtp
        salk3 estprd estkdm lbkum waers meins
        FROM mlcd
        INTO CORRESPONDING FIELDS OF TABLE gt_mlcd
        FOR ALL ENTRIES IN lt_mlcd
        WHERE kalnr = lt_mlcd-kaln1
          AND bdatj = lv_bdatj
          AND poper = lv_poper
          AND categ = 'VN'
          "Start SOH Adjustment 20240808
          AND ptyp  = 'V+'.
          "End SOH Adjustment 20240808
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_LEDGER

*&---------------------------------------------------------------------*
*&      Form  F_RANGE_BWART
*&---------------------------------------------------------------------*
FORM f_range_bwart  TABLES   ft_bwart STRUCTURE selopt.
  DATA : ls_bwart TYPE selopt.

  ls_bwart-sign   = 'I'.
  ls_bwart-option = 'EQ'.

  ls_bwart-low  = '601'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '602'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '645'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '646'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '657'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '658'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '901'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '902'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '928'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '929'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '959'.
  APPEND ls_bwart TO ft_bwart.
  ls_bwart-low  = '960'.
  APPEND ls_bwart TO ft_bwart.
ENDFORM.                    " F_RANGE_BWART

*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING_DOC
*&---------------------------------------------------------------------*
FORM f_get_billing_doc .
  DATA : lv_vkorg   LIKE vbrk-vkorg.
  DATA : lr_fkdat   TYPE RANGE OF fkdat,
         lv_fkdat   LIKE LINE OF lr_fkdat.
  DATA : lt_mseg    TYPE STANDARD TABLE OF mseg INITIAL SIZE 0.

  CONCATENATE pa_gjahr pa_monat '01' INTO lv_fkdat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_fkdat-low
    IMPORTING
      last_day_of_month = lv_fkdat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  lv_fkdat-sign   = 'I'.
  lv_fkdat-option = 'BT'.
  APPEND lv_fkdat TO lr_fkdat.

  lt_mseg[] = gt_mseg[].
  SORT lt_mseg BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING kunnr.

  SELECT SINGLE bukrs
    FROM t001k
    INTO lv_vkorg
    WHERE bwkey = pa_werks.

  IF lt_mseg[] IS NOT INITIAL.
    SELECT vbeln vkorg fkdat kunag
      FROM vbrk
      INTO CORRESPONDING FIELDS OF TABLE gt_vbrk
      FOR ALL ENTRIES IN lt_mseg
      WHERE vkorg = lv_vkorg
        AND kunag = lt_mseg-kunnr
        AND fkdat IN lr_fkdat
        AND rfbsk <> space.

    IF gt_vbrk[] IS NOT INITIAL.
      SELECT vbeln posnr shkzg kzwi1 matnr
        FROM vbrp
        INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
        FOR ALL ENTRIES IN gt_vbrk
        WHERE vbeln = gt_vbrk-vbeln.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_BILLING_DOC
