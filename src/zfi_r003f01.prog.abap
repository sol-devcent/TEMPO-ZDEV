*&---------------------------------------------------------------------*
*&  Include           ZFI_R003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_auart     LIKE LINE OF gr_auart,
         ls_vbtyp     LIKE LINE OF gr_vbtyp.

  ls_auart-low    = 'ZR*'.
  ls_auart-sign   = 'I'.
  ls_auart-option = 'CP'.
  APPEND ls_auart TO gr_auart.

  ls_vbtyp-low    = 'H'.
  ls_vbtyp-sign   = 'I'.
  ls_vbtyp-option = 'EQ'.
  APPEND ls_vbtyp TO gr_vbtva.

  ls_vbtyp-low    = 'T'.
  ls_vbtyp-sign   = 'I'.
  ls_vbtyp-option = 'EQ'.
  APPEND ls_vbtyp TO gr_vbtvl.

  ls_vbtyp-low    = 'O'.
  ls_vbtyp-sign   = 'I'.
  ls_vbtyp-option = 'EQ'.
  APPEND ls_vbtyp TO gr_vbtvf.
  ls_vbtyp-low    = '6'.
  ls_vbtyp-sign   = 'I'.
  ls_vbtyp-option = 'EQ'.
  APPEND ls_vbtyp TO gr_vbtvf.

  SELECT *
    FROM t151t
    INTO CORRESPONDING FIELDS OF TABLE gt_t151t
    WHERE spras = sy-langu.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF pa_vkorg IS INITIAL.
    PERFORM f_error_message USING 'PVO' ''.
  ENDIF.

  IF so_vkbur[] IS INITIAL.
    PERFORM f_error_message USING 'SVU' ''.
  ENDIF.

  IF so_erdva[] IS INITIAL.
    PERFORM f_error_message USING 'SER' ''.
  ELSEIF so_erdva-high IS NOT INITIAL.
    IF so_erdva-low(6) <> so_erdva-high(6).
      PERFORM f_error_message USING 'SER'
        'Transaction only in the same period'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

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
  DATA : lt_vbfa    TYPE STANDARD TABLE OF ty_vbfa,
         ls_vbrk    LIKE LINE OF gt_vbrk,
         ls_fidoc   LIKE LINE OF gt_fidoc.

  PERFORM f_get_customer.

  IF gt_kna1[] IS NOT INITIAL.
    IF so_rtvnr[] IS NOT INITIAL OR
      so_rtvdt[] IS NOT INITIAL.
      PERFORM f_get_order TABLES lt_vbfa
                          USING 'Y' 'N'.
      PERFORM f_get_document_flow TABLES lt_vbfa
                                  USING 'VBELV'.
      PERFORM f_get_outbound_delivery TABLES lt_vbfa
                                      USING ''.
      PERFORM f_get_billing_document TABLES lt_vbfa
                                     USING ''.
    ELSEIF so_vbeva[] IS NOT INITIAL OR
      so_erdva[] IS NOT INITIAL.
      PERFORM f_get_order TABLES lt_vbfa
                          USING 'X' 'N'.
      PERFORM f_get_document_flow TABLES lt_vbfa
                                  USING 'VBELV'.
      PERFORM f_get_outbound_delivery TABLES lt_vbfa
                                      USING ''.
      PERFORM f_get_billing_document TABLES lt_vbfa
                                     USING ''.
    ELSEIF so_vbevl[] IS NOT INITIAL OR
      so_erdvl[] IS NOT INITIAL.
      PERFORM f_get_outbound_delivery TABLES lt_vbfa
                                      USING 'X'.
      PERFORM f_get_document_flow TABLES lt_vbfa
                                  USING 'VBELN'.
      PERFORM f_get_order TABLES lt_vbfa
                          USING '' 'N'.
      PERFORM f_get_document_flow TABLES lt_vbfa
                                  USING 'VBELV'.
      PERFORM f_get_billing_document TABLES lt_vbfa
                                     USING ''.

    ELSEIF so_vbevf[] IS NOT INITIAL OR
      so_fkdat[] IS NOT INITIAL.
      PERFORM f_get_billing_document TABLES lt_vbfa
                                     USING 'X'.
      PERFORM f_get_document_flow TABLES lt_vbfa
                                  USING 'VBELN'.
      PERFORM f_get_order TABLES lt_vbfa
                          USING '' 'V'.
      PERFORM f_get_document_flow TABLES lt_vbfa
                                  USING 'VBELV'.
      PERFORM f_get_outbound_delivery TABLES lt_vbfa
                                      USING ''.
    ENDIF.
  ENDIF.

  CLEAR gt_fidoc[].
  IF gt_vbrk[] IS NOT INITIAL.
    LOOP AT gt_vbrk INTO ls_vbrk.
      ls_fidoc-zuonr = ls_vbrk-vbeln.
      ls_fidoc-kunnr = ls_vbrk-kunag.
      APPEND ls_fidoc TO gt_fidoc.
      CLEAR ls_fidoc.
    ENDLOOP.
  ENDIF.

  IF gt_fidoc[] IS NOT INITIAL.
    PERFORM f_get_nota_retur.
    PERFORM f_get_payment.
    PERFORM f_get_bi.
    PERFORM f_get_bi_sfa.
    PERFORM f_get_bi_paycust.
  ENDIF.

  IF gt_arpot[] IS NOT INITIAL.
    PERFORM f_get_ar_potongan.
  ENDIF.

  IF gt_vbak[] IS NOT INITIAL.
    SELECT vbeln posnr mwsbp
      FROM vbap
      INTO TABLE gt_vbap
      FOR ALL ENTRIES IN gt_vbak
      WHERE vbeln = gt_vbak-vbeln.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_kna1x     TYPE STANDARD TABLE OF ty_kna1,
         ls_kna1      LIKE LINE OF gt_kna1,
         ls_kna1x     LIKE LINE OF lt_kna1x,
         ls_vbak      LIKE LINE OF gt_vbak,
         ls_t151t     LIKE LINE OF gt_t151t,
         ls_out       LIKE LINE OF gt_out,
         ls_vbap      LIKE LINE OF gt_vbap,
         lt_likp      TYPE STANDARD TABLE OF ty_likp,
         lt_xlikp     TYPE STANDARD TABLE OF ty_likp,
         ls_likp      LIKE LINE OF lt_likp,
         ls_xlikp     LIKE LINE OF lt_xlikp.

  DATA : lv_kodat     TYPE likp-kodat,
         lv_budat     TYPE bsid-budat,
         lv_text      TYPE tline-tdline,
         lv_refdo     TYPE vbak-vbeln.

  FIELD-SYMBOLS : <fs> TYPE ANY.

  PERFORM f_additional_dyn_int_table.

  SORT gt_kna1 BY kunnr.
  SORT gt_vbak BY kunnr.

  lt_kna1x[] = gt_kna1[].

  LOOP AT gt_kna1 INTO ls_kna1.
    READ TABLE gt_vbak INTO ls_vbak
                       WITH KEY kunnr = ls_kna1-kunnr
                       BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR ls_vbak.
      LOOP AT gt_vbak INTO ls_vbak FROM sy-tabix.
        IF ls_vbak-kunnr <> ls_kna1-kunnr.
          EXIT.
        ENDIF.
        PERFORM f_assign_component USING : 'VKBUR' ls_kna1-vkbur,
                                           'KDGRP' ls_kna1-kdgrp.

        CLEAR ls_t151t.
        READ TABLE gt_t151t INTO ls_t151t
                            WITH KEY kdgrp = ls_kna1-kdgrp.
        IF sy-subrc = 0.
          PERFORM f_assign_component USING : 'KTEXT' ls_t151t-ktext.
        ENDIF.

        PERFORM f_assign_component USING : 'KUNNR' ls_kna1-kunnr,
                                           'NAME1' ls_kna1-name1,
                                           'KNKLI' ls_vbak-knkli,
                                           'AUART' ls_vbak-auart,
                                           'VBEVA' ls_vbak-vbeln,
                                           'ERDVA' ls_vbak-erdat,
                                           'ERZVA' ls_vbak-erzet,
                                           'RTVNR' ls_vbak-bstnk,
                                           'RTVDT' ls_vbak-bstdk,
                                           'WAERK' ls_vbak-waerk,
                                           'DPPCN' ls_vbak-netwr.

        CLEAR : ls_kna1x.
        READ TABLE lt_kna1x INTO ls_kna1x
                            WITH KEY kunnr = ls_vbak-knkli.
        IF sy-subrc = 0.
          PERFORM f_assign_component USING : 'NAME2' ls_kna1x-name1.
        ENDIF.

        CLEAR : ls_vbap, ls_out-ppncn.
        LOOP AT gt_vbap INTO ls_vbap WHERE vbeln = ls_vbak-vbeln.
          ADD ls_vbap-mwsbp TO ls_out-ppncn.
        ENDLOOP.
        ls_out-total    = ls_vbak-netwr + ls_out-ppncn.

        PERFORM f_read_data USING ls_vbak-vbeln 'VBBK' 'Z012' ''
                            CHANGING ls_out-bstnk.
        PERFORM f_read_data USING ls_vbak-vbeln 'VBBK' 'Z013' 'D'
                            CHANGING ls_out-bstdk.
        PERFORM f_read_data USING ls_vbak-vbeln 'VBBK' 'Z004' ''
                            CHANGING ls_out-refdo.

        ls_xlikp-vbeln = ls_out-refdo.
        APPEND ls_xlikp TO lt_xlikp.
        CLEAR ls_xlikp.

        PERFORM f_outbound_delivery USING ls_vbak-vbeln
                                    CHANGING ls_out-vbevl ls_out-erdvl
                                             ls_out-erzvl lv_kodat.
        IF ls_out-vbevl IN so_vbevl.
        ELSE.
          CONTINUE.
        ENDIF.

        PERFORM f_billing_document USING ls_vbak-vbeln
                                   CHANGING ls_out-vbevf ls_out-fkdat
                                            ls_out-erzvf.
        IF ls_out-vbevf IN so_vbevf.
        ELSE.
          CONTINUE.
        ENDIF.

        PERFORM f_payment_date USING ls_out-vbevf ls_kna1-kunnr
                               CHANGING lv_budat.
        IF lv_budat IN so_budat.
        ELSE.
          CONTINUE.
        ENDIF.

        PERFORM f_read_data USING ls_out-vbevf 'VBBK' 'Z008' ''
                            CHANGING lv_text.
        PERFORM f_split_text USING lv_text
                             CHANGING ls_out-vatpr ls_out-vatdt.

        PERFORM f_assign_component USING : 'PPNCN' ls_out-ppncn,
                                           'TOTAL' ls_out-total,
                                           'BSTNK' ls_out-bstnk,
                                           'BSTDK' ls_out-bstdk,
                                           'REFDO' ls_out-refdo,
                                           'VBEVL' ls_out-vbevl,
                                           'ERDVL' ls_out-erdvl,
                                           'ERZVL' ls_out-erzvl,
                                           'VBEVF' ls_out-vbevf,
                                           'FKDAT' ls_out-fkdat,
                                           'ERZVF' ls_out-erzvf,
                                           'VATPR' ls_out-vatpr,
                                           'VATDT' ls_out-vatdt.

        PERFORM f_ar_potongan USING ls_vbak-bstnk ls_kna1-kunnr.
        PERFORM f_nota_retur USING ls_kna1-vkbur ls_out-vbevf ls_kna1-kunnr.
        PERFORM f_bi USING ls_out-vbevf ls_kna1-kunnr.

        APPEND <fs_line> TO <fs_tab>.
        CLEAR : ls_out, <fs_line>.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF lt_xlikp[] IS NOT INITIAL.
    SELECT vbeln erdat erzet fkdat kodat
      FROM likp
      INTO TABLE lt_likp
      FOR ALL ENTRIES IN lt_xlikp
      WHERE vbeln = lt_xlikp-vbeln.
  ENDIF.

  CLEAR <fs_line>.
  LOOP AT <fs_tab> ASSIGNING <fs_line>.
    ASSIGN COMPONENT 'REFDO' OF STRUCTURE <fs_line> TO <fs>.
    lv_refdo = <fs>.
    IF lv_refdo IS NOT INITIAL.
      CLEAR ls_likp.
      READ TABLE lt_likp INTO ls_likp
                         WITH KEY vbeln = lv_refdo.
      IF sy-subrc = 0.
        PERFORM f_assign_component USING : 'REFDT' ls_likp-fkdat.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DATA : lv_text(60).

  IF <fs_tab>[] IS NOT INITIAL.
    CALL SCREEN 101.

*    PERFORM f_build_layout.
*    PERFORM f_build_sort.
*
*    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
*      EXPORTING
*        i_callback_program       = sy-repid
*        i_callback_pf_status_set = 'F_SET_PF_STATUS'
*        i_callback_user_command  = 'F_USER_COMMAND'
*        is_layout_lvc            = gs_layout_alv
*        it_fieldcat_lvc          = gt_main_fieldcat[]
*        it_sort_lvc              = gt_main_sort[]
*        i_default                = 'X'
*        i_save                   = 'A'
*      TABLES
*        t_outtab                 = <fs_tab>
*      EXCEPTIONS
*        program_error            = 1
*        OTHERS                   = 2.
  ELSE.
    MESSAGE s033(msitem) WITH lv_text DISPLAY LIKE 'E'.
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
  DATA : lv_ucomm       TYPE sy-ucomm,
         lv_valid       TYPE c,
         lt_fidx        TYPE lvc_t_fidx,
         ls_fidx        TYPE sy-tabix,
         ls_filter      LIKE LINE OF gt_filter.

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
        it_outtab            = <fs_tab>[]
        it_fieldcatalog      = gt_main_fieldcat[].

    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
*  gs_layout_alv-sel_mode            = 'B'.
*  gs_layout_alv-box_fname           = 'MARK'.
  gs_layout_alv-s_dragdrop-row_ddid = g_handle_alv.
  gs_layout_alv-cwidth_opt          = selected.
  gs_layout_alv-zebra               = selected.
  gs_layout_alv-no_toolbar          = selected.
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
  DATA : lr_tabdescr   TYPE REF TO cl_abap_structdescr,
         lt_dyn_table  TYPE REF TO data,
         ls_line       TYPE REF TO data,
         lt_dfies      TYPE ddfields,
         ls_dfies      TYPE dfies,
         ls_fieldcat   TYPE lvc_s_fcat.

  DATA : lv_title(30),
         lv_sum.

  CLEAR gt_main_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_dfies-fieldname.
      WHEN 'ICON'.
        CONTINUE.
      WHEN 'MARK'.
        CONTINUE.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' 'X' '' '' '' 'X' 'X' '' '' 'X' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VKBUR' OR 'KDGRP' OR 'KUNNR' OR 'NAME1' OR 'AUART' OR
        'KNKLI' OR 'NAME2' OR 'TOTAL' OR 'DPPCN' OR 'PPNCN' OR 'WAERK'.
        IF ls_dfies-fieldname = 'TOTAL' OR
          ls_dfies-fieldname = 'DPPCN' OR
          ls_dfies-fieldname = 'PPNCN'.
          lv_sum  = 'X'.
        ELSE.
          CLEAR lv_sum.
        ENDIF.

        CLEAR lv_title.
        IF ls_dfies-fieldname = 'KUNNR'.
          lv_title = 'Sold-to party'.
        ELSEIF ls_dfies-fieldname = 'NAME1'.
          lv_title = 'Sold-to name'.
        ELSEIF ls_dfies-fieldname = 'KNKLI'.
          lv_title = 'Ship-to party'.
        ELSEIF ls_dfies-fieldname = 'NAME2'.
          lv_title = 'Ship-to name'.
        ENDIF.

        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' lv_title '' '' '' '' '' '' 'X' '' lv_sum ''
        CHANGING ls_fieldcat.
      WHEN 'KTEXT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'CGrp.Desc.' '' '' '' '' '' '' 'X' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'RTVNR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FTTBR/RTV No' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'RTVDT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FTTBR/RTV Date' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BSTNK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Ref.No PO' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'BSTDK'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Receive Date' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VBEVA'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'SO Number' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ERDVA'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'SO Date' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ERZVA'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'SO Time' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VBEVL'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'DO Number' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ERDVL'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'DO Date' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ERZVL'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'DO Time' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VBEVF'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Billing No.' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'FKDAT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Billing Date' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ERZVF'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'Billing Time' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'REFDO'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'DN Ref.No.' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'REFDT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'DN Ref.Date' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VATPR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FP Ref.No.' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'VATDT'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' 'FP Ref.Date' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
    ENDCASE.

    CASE ls_dfies-datatype.
      WHEN 'CURR'.
        PERFORM f_change_title USING ls_dfies-fieldname
                               CHANGING lv_title.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERK' '' '' '' lv_title '' '' '' '' '' '' '' '' '' ''
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
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style           TYPE lvc_s_styl-style,
         lt_stylerow        TYPE lvc_t_styl,
         ls_stylerow        TYPE lvc_s_styl,
         lv_tabix           TYPE sy-tabix,
         ls_filter          LIKE LINE OF gt_filter.

  DATA : ls_out             LIKE LINE OF gt_out.

  FIELD-SYMBOLS : <fs>  TYPE ANY.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT <fs_tab> ASSIGNING <fs_line>.
        lv_tabix = sy-tabix.
        CLEAR ls_filter.
        READ TABLE gt_filter INTO ls_filter
                             WITH KEY INDEX = lv_tabix.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
        ASSIGN COMPONENT 'MARK' OF STRUCTURE <fs_line> TO <fs>.
        <fs> = fu_check.
*        MODIFY gt_out FROM ls_out.
*        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
    PERFORM f_alv_refresh USING 'X'.
  ENDIF.
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
  DELETE lt_out WHERE mark IS INITIAL.
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
                                     fu_nosum
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
*&      Form  F_GET_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_get_customer.
  SELECT kunnr name1 vkorg vkbur kdgrp
    FROM kna1vv
    INTO TABLE gt_kna1
    WHERE vkorg = pa_vkorg
      AND vkbur IN so_vkbur
      AND kdgrp IN so_kdgrp.
ENDFORM.                    " F_GET_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER
*&---------------------------------------------------------------------*
FORM f_get_order TABLES   ft_vbfa   LIKE gt_vbfa
                 USING    fu_select fu_flag.
  DATA : lt_vbfa      TYPE STANDARD TABLE OF ty_vbfa,
         ls_vbak      LIKE LINE OF gt_vbak,
         ls_vbfa      LIKE LINE OF gt_vbfa,
         ls_arpot     LIKE LINE OF gt_arpot.

  CASE fu_select.
    WHEN 'X'.
      SELECT vbeln erdat erzet auart netwr waerk vkbur bstnk bstdk
        kunnr knkli
        FROM vbak
        INTO TABLE gt_vbak
        FOR ALL ENTRIES IN gt_kna1
        WHERE vbeln IN so_vbeva
          AND erdat IN so_erdva
          AND kunnr = gt_kna1-kunnr
          AND knkli IN so_knkli
          AND vkorg = pa_vkorg
          AND vkbur IN so_vkbur
          AND auart IN gr_auart.
    WHEN 'Y'.
      SELECT vbeln erdat erzet auart netwr waerk vkbur bstnk bstdk
        kunnr knkli
        FROM vbak
        INTO TABLE gt_vbak
        FOR ALL ENTRIES IN gt_kna1
        WHERE erdat IN so_erdva
          AND kunnr = gt_kna1-kunnr
          AND knkli IN so_knkli
          AND vkorg = pa_vkorg
          AND vkbur IN so_vkbur
          AND bstnk IN so_rtvnr
          AND bstdk IN so_rtvdt
          AND auart IN gr_auart.
    WHEN OTHERS.
      LOOP AT gt_vbfa INTO ls_vbfa.
        CASE fu_flag.
          WHEN 'N'.
            IF ls_vbfa-vbtyp_n IN gr_vbtvl.
              APPEND ls_vbfa TO lt_vbfa.
            ENDIF.
          WHEN 'V'.
            IF ls_vbfa-vbtyp_v IN gr_vbtva.
              APPEND ls_vbfa TO lt_vbfa.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      SORT lt_vbfa BY vbelv.
      DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbelv.
      IF lt_vbfa[] IS NOT INITIAL.
        SELECT vbeln erdat erzet auart netwr waerk vkbur bstnk bstdk
          kunnr knkli
          FROM vbak
          INTO TABLE gt_vbak
          FOR ALL ENTRIES IN lt_vbfa
          WHERE vbeln = lt_vbfa-vbelv
            AND vkorg = pa_vkorg
            AND vkbur IN so_vkbur
            AND auart IN gr_auart.
      ENDIF.
  ENDCASE.

  CLEAR ft_vbfa[].

  LOOP AT gt_vbak INTO ls_vbak.
    ls_vbfa-vbelv     = ls_vbak-vbeln.
    APPEND ls_vbfa TO ft_vbfa.
    ls_arpot-bukrs    = pa_vkorg.
    ls_arpot-vkbur    = ls_vbak-vkbur.
    ls_arpot-kunnr    = ls_vbak-kunnr.
    ls_arpot-rtvnr    = ls_vbak-bstnk.
    APPEND ls_arpot TO gt_arpot.
  ENDLOOP.
  SORT ft_vbfa BY vbelv.
  DELETE ADJACENT DUPLICATES FROM ft_vbfa COMPARING vbelv.
  SORT gt_arpot BY bukrs vkbur kunnr rtvnr.
  DELETE ADJACENT DUPLICATES FROM gt_arpot COMPARING bukrs kunnr rtvnr.
ENDFORM.                    " F_GET_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_GET_OUTBOUND_DELIVERY
*&---------------------------------------------------------------------*
FORM f_get_outbound_delivery TABLES   ft_vbfa   LIKE gt_vbfa
                             USING    fu_select.
  DATA : lt_vbfa    TYPE STANDARD TABLE OF ty_vbfa,
         ls_vbfa    LIKE LINE OF gt_vbfa,
         ls_likp    LIKE LINE OF gt_likp.

  IF fu_select IS INITIAL.
    LOOP AT gt_vbfa INTO ls_vbfa.
      IF ls_vbfa-vbtyp_n IN gr_vbtvl.
        APPEND ls_vbfa TO lt_vbfa.
      ENDIF.
    ENDLOOP.

    SORT lt_vbfa BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbeln.
    IF lt_vbfa[] IS NOT INITIAL.
      SELECT vbeln erdat erzet fkdat kodat
        FROM likp
        INTO TABLE gt_likp
        FOR ALL ENTRIES IN lt_vbfa
        WHERE vbeln = lt_vbfa-vbeln.
    ENDIF.
  ELSE.
    SELECT vbeln erdat erzet fkdat kodat
      FROM likp
      INTO TABLE gt_likp
      WHERE vbeln IN so_vbevl
        AND erdat IN so_erdvl.

    LOOP AT gt_likp INTO ls_likp.
      ls_vbfa-vbeln = ls_likp-vbeln.
      APPEND ls_vbfa TO ft_vbfa.
    ENDLOOP.
    SORT ft_vbfa BY vbeln.
    DELETE ADJACENT DUPLICATES FROM ft_vbfa COMPARING vbeln.
  ENDIF.
ENDFORM.                    " F_GET_OUTBOUND_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_billing_document TABLES   ft_vbfa LIKE gt_vbfa
                            USING    fu_select.
  DATA : lt_vbfa    TYPE STANDARD TABLE OF ty_vbfa,
         ls_vbfa    LIKE LINE OF gt_vbfa,
         ls_vbrk    LIKE LINE OF gt_vbrk.

  IF fu_select IS INITIAL.
    LOOP AT gt_vbfa INTO ls_vbfa.
      IF ls_vbfa-vbtyp_n IN gr_vbtvf.
        APPEND ls_vbfa TO lt_vbfa.
      ENDIF.
    ENDLOOP.

    SORT lt_vbfa BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbeln.
    IF lt_vbfa[] IS NOT INITIAL.
      SELECT vbeln fkdat erzet netwr mwsbk waerk kunag
        FROM vbrk
        INTO TABLE gt_vbrk
        FOR ALL ENTRIES IN lt_vbfa
        WHERE vbeln = lt_vbfa-vbeln.
    ENDIF.
  ELSE.
    SELECT vbeln fkdat erzet netwr mwsbk waerk kunag
      FROM vbrk
      INTO TABLE gt_vbrk
      WHERE vbeln IN so_vbevf
        AND fkdat IN so_fkdat.

    LOOP AT gt_vbrk INTO ls_vbrk.
      ls_vbfa-vbeln = ls_vbrk-vbeln.
      APPEND ls_vbfa TO ft_vbfa.
    ENDLOOP.
    SORT ft_vbfa BY vbeln.
    DELETE ADJACENT DUPLICATES FROM ft_vbfa COMPARING vbeln.
  ENDIF.
ENDFORM.                    " F_GET_BILLING_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_NOTA_RETUR
*&---------------------------------------------------------------------*
FORM f_get_nota_retur .
  DATA : lt_xfppnnrd    TYPE STANDARD TABLE OF ty_zfppnnrd,
         ls_xfppnnrd    LIKE LINE OF lt_xfppnnrd,
         ls_zfppnnrd    LIKE LINE OF gt_zfppnnrd.

  DATA : lv_count       TYPE i.

  SELECT vrsio bukrs vkbur belnr zuonr kunnr monat gjahr
    nonr nrdt
    FROM zfppnnrd
    INTO TABLE gt_zfppnnrd
    FOR ALL ENTRIES IN gt_fidoc
    WHERE bukrs = pa_vkorg
      AND vkbur IN so_vkbur
      AND zuonr = gt_fidoc-zuonr.

  CLEAR : lt_xfppnnrd[], gv_count.
  lt_xfppnnrd[] = gt_zfppnnrd[].
  SORT lt_xfppnnrd BY vkbur zuonr kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_xfppnnrd COMPARING vkbur zuonr kunnr.
  LOOP AT lt_xfppnnrd INTO ls_xfppnnrd.
    CLEAR lv_count.
    LOOP AT gt_zfppnnrd INTO ls_zfppnnrd WHERE vkbur = ls_xfppnnrd-vkbur
                                           AND zuonr = ls_xfppnnrd-zuonr
                                           AND kunnr = ls_xfppnnrd-kunnr.
      ADD 1 TO lv_count.
    ENDLOOP.
    IF lv_count > gv_count.
      gv_count = lv_count.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_NOTA_RETUR

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_TITLE
*&---------------------------------------------------------------------*
FORM f_change_title  USING    fu_fieldname
                     CHANGING fc_title.
  CASE fu_fieldname.
    WHEN 'TOTAL'.
      fc_title  = 'Total CN'.
    WHEN 'DPPCN'.
      fc_title  = 'DPP CN'.
    WHEN 'PPNCN'.
      fc_title  = 'PPN CN'.
  ENDCASE.
ENDFORM.                    " F_CHANGE_TITLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOCUMENT_FLOW
*&---------------------------------------------------------------------*
FORM f_get_document_flow  TABLES   ft_vbfa LIKE gt_vbfa
                          USING    fu_fieldname.
  CLEAR gt_vbfa[].
  IF ft_vbfa[] IS NOT INITIAL.
    CASE fu_fieldname.
      WHEN 'VBELV'.
        SELECT vbelv vbeln vbtyp_n vbtyp_v erdat erzet
          FROM vbfa
          APPENDING TABLE gt_vbfa
          FOR ALL ENTRIES IN ft_vbfa
          WHERE vbelv = ft_vbfa-vbelv.
      WHEN 'VBELN'.
        SELECT vbelv vbeln vbtyp_n vbtyp_v erdat erzet
          FROM vbfa
          APPENDING TABLE gt_vbfa
          FOR ALL ENTRIES IN ft_vbfa
          WHERE vbeln = ft_vbfa-vbeln.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_GET_DOCUMENT_FLOW

*&---------------------------------------------------------------------*
*&      Form  F_OUTBOUND_DELIVERY
*&---------------------------------------------------------------------*
FORM f_outbound_delivery  USING    fu_vbeln
                          CHANGING fc_vbeln fc_erdat fc_erzet fc_kodat.
  DATA : ls_vbfa        LIKE LINE OF gt_vbfa,
         ls_likp        LIKE LINE OF gt_likp.

  CLEAR : fc_vbeln, fc_erdat, fc_erzet, fc_kodat.
  LOOP AT gt_vbfa INTO ls_vbfa WHERE vbelv = fu_vbeln.
    IF ls_vbfa-vbtyp_n IN gr_vbtvl.
      fc_vbeln  = ls_vbfa-vbeln.
      fc_erdat  = ls_vbfa-erdat.
      fc_erzet  = ls_vbfa-erzet.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_likp INTO ls_likp
                     WITH KEY vbeln = fc_vbeln.
  IF sy-subrc = 0.
    fc_kodat  = ls_likp-kodat.
  ENDIF.
ENDFORM.                    " F_OUTBOUND_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_BILLING_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_billing_document  USING    fu_vbeln
                         CHANGING fc_vbeln fc_erdat fc_erzet.
  DATA : ls_vbfa        LIKE LINE OF gt_vbfa,
         ls_vbrk        LIKE LINE OF gt_vbrk.

  CLEAR : fc_vbeln, fc_erdat, fc_erzet.
  LOOP AT gt_vbfa INTO ls_vbfa WHERE vbelv = fu_vbeln.
    IF ls_vbfa-vbtyp_n IN gr_vbtvf.
      fc_vbeln  = ls_vbfa-vbeln.
      fc_erdat  = ls_vbfa-erdat.
      fc_erzet  = ls_vbfa-erzet.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_BILLING_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_READ_DATA
*&---------------------------------------------------------------------*
FORM f_read_data  USING    fu_vbeln fu_object fu_id fu_type
                  CHANGING fc_value.
  DATA : lv_id      TYPE thead-tdid,
         lv_name    TYPE thead-tdname,
         lv_object  TYPE thead-tdobject,
         lines      TYPE STANDARD TABLE OF tline,
         ls_lines   LIKE LINE OF lines.

  CLEAR fc_value.
  lv_id     = fu_id.
  lv_name   = fu_vbeln.
  lv_object = fu_object.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lv_id
      language                = sy-langu
      name                    = lv_name
      object                  = lv_object
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  READ TABLE lines INTO ls_lines INDEX 1.
  IF sy-subrc = 0.
    CASE fu_type.
      WHEN 'D'.
        TRANSLATE ls_lines-tdline USING '. '.
        CONDENSE ls_lines-tdline NO-GAPS.
        CONCATENATE ls_lines-tdline+4(4) ls_lines-tdline+2(2) ls_lines-tdline(2)
        INTO fc_value.
      WHEN OTHERS.
        fc_value   = ls_lines-tdline.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_READ_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_TEXT
*&---------------------------------------------------------------------*
FORM f_split_text  USING    fu_text
                   CHANGING fc_vatpr fc_vatdt.
  DATA : lv_text    TYPE tline-tdline,
         lv_str1    TYPE string,
         lv_str2    TYPE string,
         lv_vatpr(20),
         lv_vatdt(10),
         lv_length  TYPE i.

  CLEAR : fc_vatpr, fc_vatdt.
  IF fu_text IS NOT INITIAL.
    lv_text = fu_text.
    TRANSLATE lv_text USING '/ '.
    SPLIT lv_text AT space INTO lv_str1 lv_str2.
    lv_vatpr = lv_str1.
    TRANSLATE lv_vatpr USING '- '.
    TRANSLATE lv_vatpr USING '. '.
    CONDENSE lv_vatpr NO-GAPS.
    WRITE lv_vatpr TO lv_vatpr USING EDIT MASK '___.___-__.________'.
    lv_vatdt = lv_str2.
    TRANSLATE lv_vatdt USING '. '.
    CONDENSE lv_vatdt NO-GAPS.
    WRITE lv_vatdt TO lv_vatdt USING EDIT MASK '__.__.____'.

    IF lv_str1 = lv_vatpr.
      fc_vatpr  = lv_str1.
    ENDIF.
    IF lv_str2 = lv_vatdt.
      lv_length = STRLEN( lv_str2 ).
      IF lv_length = 10.
*        CONCATENATE lv_str2+6(4) lv_str2+3(2) lv_str2(2) INTO fc_vatdt.
        fc_vatdt = lv_str2.
      ELSE.
        fc_vatdt = lv_str2.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SPLIT_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_ADDITIONAL_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_additional_dyn_int_table .
  DATA : lt_dyn_table     TYPE REF TO data,
         ls_lines         TYPE REF TO data.

  DATA : lv_count(3),
         lv_fname(20).

  IF gv_count = 0.
    CONCATENATE 'NONR' lv_count INTO lv_fname.
    CONDENSE lv_fname NO-GAPS.
    PERFORM f_add_dyn_fieldcat USING :
    lv_fname '' '' 'CHAR' 'C' '50' 'Nota Retur No.' '' '' '' '' '' '' '' '' ''.
    CONCATENATE 'NRDT' lv_count INTO lv_fname.
    CONDENSE lv_fname NO-GAPS.
    PERFORM f_add_dyn_fieldcat USING :
    lv_fname '' '' 'DATS' 'D' '10' 'Nota Retur Date' '' '' '' '' '' '' '' '' ''.
  ELSE.
    DO gv_count TIMES.
      ADD 1 TO lv_count.
      CONCATENATE 'NONR' lv_count INTO lv_fname.
      CONDENSE lv_fname NO-GAPS.
      PERFORM f_add_dyn_fieldcat USING :
      lv_fname '' '' 'CHAR' 'C' '50' 'Nota Retur No.' '' '' '' '' '' '' '' '' ''.
      CONCATENATE 'NRDT' lv_count INTO lv_fname.
      CONDENSE lv_fname NO-GAPS.
      PERFORM f_add_dyn_fieldcat USING :
      lv_fname '' '' 'DATS' 'D' '10' 'Nota Retur Date' '' '' '' '' '' '' '' '' ''.
    ENDDO.
  ENDIF.

  PERFORM f_add_dyn_fieldcat USING :
  'BELNR' '' '' 'CHAR' 'C' '10' 'Payment No.' '' '' '' '' '' '' '' '' '',
  'BUDAT' '' '' 'DATS' 'D' '10' 'Payment Date' '' '' '' '' '' '' '' '' '',
  'BBELN' '' '' 'CHAR' 'C' '7' 'BI No.' '' '' '' '' '' '' '' '' '',
  'BIDAT' '' '' 'DATS' 'D' '10' 'BI Date' '' '' '' '' '' '' '' '' '',
  'PTYPE' '' 'X' 'CHAR' 'C' '20' 'Jenis Payment' '' '' '' '' '' '' '' '' '',
  'BFLAG' '' '' 'CHAR' 'C' '5' 'BI Stat' '' '' '' '' '' '' '' '' ''.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = 'X'
      it_fieldcatalog           = gt_main_fieldcat
      i_length_in_byte          = 'X'
    IMPORTING
      ep_table                  = lt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc EQ 0.
    ASSIGN lt_dyn_table->* TO <fs_tab>.
    CREATE DATA ls_lines LIKE LINE OF <fs_tab>.
    ASSIGN ls_lines->* TO <fs_line>.
  ENDIF.
ENDFORM.                    " F_ADDITIONAL_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_add_dyn_fieldcat  USING    fu_fname fu_tabnm fu_noout fu_datatyp
                                  fu_inttype fu_outln fu_fltxt fu_dosum
                                  fu_hotsp fu_dec fu_waers fu_meins
                                  fu_waers_f fu_meins_f fu_checkbox
                                  fu_emphasize.
  DATA : ls_fieldcat    TYPE lvc_s_fcat.

  CLEAR : ls_fieldcat.
  ls_fieldcat-fieldname         = fu_fname.
  ls_fieldcat-tabname           = fu_tabnm.
  ls_fieldcat-no_out            = fu_noout.
  ls_fieldcat-datatype          = fu_datatyp.
  ls_fieldcat-inttype           = fu_inttype.
  ls_fieldcat-outputlen         = fu_outln.
  ls_fieldcat-scrtext_l         = fu_fltxt.
  ls_fieldcat-scrtext_m         = fu_fltxt.
  ls_fieldcat-scrtext_s         = fu_fltxt.
  ls_fieldcat-reptext           = fu_fltxt.
  ls_fieldcat-no_out            = fu_noout.
  ls_fieldcat-do_sum            = fu_dosum.
  ls_fieldcat-hotspot           = fu_hotsp.
  ls_fieldcat-decimals_o        = fu_dec.
  ls_fieldcat-currency          = fu_waers.
  ls_fieldcat-quantity          = fu_meins.
  ls_fieldcat-qfieldname        = fu_meins_f.
  ls_fieldcat-cfieldname        = fu_waers_f.
  ls_fieldcat-checkbox          = fu_checkbox.
  ls_fieldcat-emphasize         = fu_emphasize.
  APPEND ls_fieldcat TO gt_main_fieldcat.
  CLEAR ls_fieldcat.
ENDFORM.                    " F_ADD_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_COMPONENT
*&---------------------------------------------------------------------*
FORM f_assign_component  USING    fu_component fu_value.
  FIELD-SYMBOLS <fs>  TYPE ANY.

  ASSIGN COMPONENT fu_component OF STRUCTURE <fs_line> TO <fs>.
  <fs> = fu_value.
ENDFORM.                    " F_ASSIGN_COMPONENT

*&---------------------------------------------------------------------*
*&      Form  F_NOTA_RETUR
*&---------------------------------------------------------------------*
FORM f_nota_retur  USING    fu_vkbur fu_vbeln fu_kunnr.
  DATA : ls_zfppnnrd    LIKE LINE OF gt_zfppnnrd.

  DATA : lv_count(3),
         lv_fname(20).

  LOOP AT gt_zfppnnrd INTO ls_zfppnnrd WHERE vkbur = fu_vkbur
                                         AND zuonr = fu_vbeln
                                         AND kunnr = fu_kunnr.
    ADD 1 TO lv_count.
    CONCATENATE 'NONR' lv_count INTO lv_fname.
    CONDENSE lv_fname NO-GAPS.
    PERFORM f_assign_component USING : lv_fname ls_zfppnnrd-nonr.
    CONCATENATE 'NRDT' lv_count INTO lv_fname.
    CONDENSE lv_fname NO-GAPS.
    PERFORM f_assign_component USING : lv_fname ls_zfppnnrd-nrdt.
  ENDLOOP.
ENDFORM.                    " F_NOTA_RETUR

*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT
*&---------------------------------------------------------------------*
FORM f_get_payment .
  DATA : lv_blart       TYPE bsid-blart.

  lv_blart  = 'DZ'.

  SELECT bukrs kunnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    budat bldat
    FROM bsid
    APPENDING TABLE gt_bsid
    FOR ALL ENTRIES IN gt_fidoc
    WHERE budat <= sy-datum
      AND bukrs = pa_vkorg
      AND kunnr = gt_fidoc-kunnr
      AND zuonr = gt_fidoc-zuonr
      AND blart = lv_blart.

  SELECT bukrs kunnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    budat bldat
    FROM bsad
    APPENDING TABLE gt_bsid
    FOR ALL ENTRIES IN gt_fidoc
    WHERE budat <= sy-datum
      AND augdt > sy-datum
      AND bukrs = pa_vkorg
      AND kunnr = gt_fidoc-kunnr
      AND zuonr = gt_fidoc-zuonr
      AND blart = lv_blart.
ENDFORM.                    " F_GET_PAYMENT

*&---------------------------------------------------------------------*
*&      Form  F_PAYMENT_DATE
*&---------------------------------------------------------------------*
FORM f_payment_date  USING    fu_zuonr fu_kunnr
                     CHANGING fc_budat.
  DATA : ls_bsid      LIKE LINE OF gt_bsid.

  SORT gt_bsid BY kunnr zuonr budat DESCENDING.
  CLEAR ls_bsid.
  READ TABLE gt_bsid INTO ls_bsid
                     WITH KEY kunnr = fu_kunnr
                              zuonr = fu_zuonr.
  IF sy-subrc = 0.
    fc_budat  = ls_bsid-budat.
    PERFORM f_assign_component USING : 'BELNR' ls_bsid-belnr,
                                       'BUDAT' ls_bsid-budat.
  ENDIF.
ENDFORM.                    " F_PAYMENT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_BI
*&---------------------------------------------------------------------*
FORM f_get_bi .
  DATA : lt_zfbid           TYPE STANDARD TABLE OF ty_zfbid6,
         lt_xfbid           TYPE STANDARD TABLE OF ty_zfbid6,
         lt_zfbih           TYPE STANDARD TABLE OF ty_zfbih6,
         ls_zfbid           LIKE LINE OF lt_zfbid,
         ls_zfbih           LIKE LINE OF lt_zfbih,
         ls_bi              LIKE LINE OF gt_bi.

  SELECT bukrs vkbur bbeln ebelp vbeln zuonr gsber kunnr bflag ptype
    FROM zfbid
    INTO TABLE lt_zfbid
    FOR ALL ENTRIES IN gt_fidoc
    WHERE bukrs = pa_vkorg
      AND vkbur IN so_vkbur
      AND zuonr = gt_fidoc-zuonr
      AND kunnr = gt_fidoc-kunnr.

  CLEAR : lt_xfbid[].
  lt_xfbid[] = lt_zfbid[].
  SORT lt_xfbid BY bukrs vkbur bbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xfbid COMPARING bukrs vkbur bbeln.
  IF lt_zfbid[] IS NOT INITIAL.
    SELECT bukrs vkbur bbeln bidat
      FROM zfbih
      INTO TABLE lt_zfbih
      FOR ALL ENTRIES IN lt_zfbid
      WHERE bukrs = lt_zfbid-bukrs
        AND vkbur = lt_zfbid-vkbur
        AND bbeln = lt_zfbid-bbeln.
  ENDIF.

  LOOP AT lt_zfbih INTO ls_zfbih.
    LOOP AT lt_zfbid INTO ls_zfbid WHERE bukrs = ls_zfbih-bukrs
                                     AND vkbur = ls_zfbih-vkbur
                                     AND bbeln = ls_zfbih-bbeln.
      ls_bi-bbeln   = ls_zfbih-bbeln.
      ls_bi-bidat   = ls_zfbih-bidat.
      ls_bi-zuonr   = ls_zfbid-zuonr.
      ls_bi-kunnr   = ls_zfbid-kunnr.
      ls_bi-bflag   = ls_zfbid-bflag.
      ls_bi-ptype   = ls_zfbid-ptype.
      APPEND ls_bi TO gt_bi.
      CLEAR ls_bi.
    ENDLOOP.
  ENDLOOP.

  SORT gt_bi BY zuonr bbeln DESCENDING.
ENDFORM.                    " F_GET_BI

*&---------------------------------------------------------------------*
*&      Form  F_GET_BI_SFA
*&---------------------------------------------------------------------*
FORM f_get_bi_sfa .
  DATA : lt_zfbid           TYPE STANDARD TABLE OF ty_zfbid7,
         lt_xfbid           TYPE STANDARD TABLE OF ty_zfbid7,
         lt_zfbih           TYPE STANDARD TABLE OF ty_zfbih7,
         ls_zfbid           LIKE LINE OF lt_zfbid,
         ls_zfbih           LIKE LINE OF lt_zfbih,
         ls_bi              LIKE LINE OF gt_bi.

  SELECT bukrs vkbur bbeln ebelp vbeln zuonr gsber kunnr bflag ptype
    FROM zfbid_sfa
    INTO CORRESPONDING FIELDS OF TABLE lt_zfbid
    FOR ALL ENTRIES IN gt_fidoc
    WHERE bukrs = pa_vkorg
      AND vkbur IN so_vkbur
      AND zuonr = gt_fidoc-zuonr
      AND kunnr = gt_fidoc-kunnr.

  CLEAR : lt_xfbid[].
  lt_xfbid[] = lt_zfbid[].
  SORT lt_xfbid BY bukrs vkbur bbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xfbid COMPARING bukrs vkbur bbeln.
  IF lt_zfbid[] IS NOT INITIAL.
    SELECT bukrs vkbur bbeln bidat
      FROM zfbih_sfa
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbih
      FOR ALL ENTRIES IN lt_zfbid
      WHERE bukrs = lt_zfbid-bukrs
        AND vkbur = lt_zfbid-vkbur
        AND bbeln = lt_zfbid-bbeln.
  ENDIF.

  LOOP AT lt_zfbih INTO ls_zfbih.
    LOOP AT lt_zfbid INTO ls_zfbid WHERE bukrs = ls_zfbih-bukrs
                                     AND vkbur = ls_zfbih-vkbur
                                     AND bbeln = ls_zfbih-bbeln.
      ls_bi-bbeln   = ls_zfbih-bbeln.
      ls_bi-bidat   = ls_zfbih-bidat.
      ls_bi-zuonr   = ls_zfbid-zuonr.
      ls_bi-kunnr   = ls_zfbid-kunnr.
      ls_bi-bflag   = ls_zfbid-bflag.
      ls_bi-ptype   = ls_zfbid-ptype.
      APPEND ls_bi TO gt_bi.
      CLEAR ls_bi.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_GET_BI_SFA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BI_PAYCUST
*&---------------------------------------------------------------------*
FORM f_get_bi_paycust .
  DATA : lt_zfbid           TYPE STANDARD TABLE OF ty_zfbid7,
         lt_xfbid           TYPE STANDARD TABLE OF ty_zfbid7,
         lt_zfbih           TYPE STANDARD TABLE OF ty_zfbih7,
         ls_zfbid           LIKE LINE OF lt_zfbid,
         ls_zfbih           LIKE LINE OF lt_zfbih,
         ls_bi              LIKE LINE OF gt_bi.

  SELECT bukrs vkbur bbeln ebelp vbeln zuonr gsber kunnr bflag ptype
    FROM zfbid_paycust
    INTO CORRESPONDING FIELDS OF TABLE lt_zfbid
    FOR ALL ENTRIES IN gt_fidoc
    WHERE bukrs = pa_vkorg
      AND vkbur IN so_vkbur
      AND zuonr = gt_fidoc-zuonr
      AND kunnr = gt_fidoc-kunnr.

  CLEAR : lt_xfbid[].
  lt_xfbid[] = lt_zfbid[].
  SORT lt_xfbid BY bukrs vkbur bbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xfbid COMPARING bukrs vkbur bbeln.
  IF lt_zfbid[] IS NOT INITIAL.
    SELECT bukrs vkbur bbeln bidat
      FROM zfbih_paycust
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbih
      FOR ALL ENTRIES IN lt_zfbid
      WHERE bukrs = lt_zfbid-bukrs
        AND vkbur = lt_zfbid-vkbur
        AND bbeln = lt_zfbid-bbeln.
  ENDIF.

  LOOP AT lt_zfbih INTO ls_zfbih.
    LOOP AT lt_zfbid INTO ls_zfbid WHERE bukrs = ls_zfbih-bukrs
                                     AND vkbur = ls_zfbih-vkbur
                                     AND bbeln = ls_zfbih-bbeln.
      ls_bi-bbeln   = ls_zfbih-bbeln.
      ls_bi-bidat   = ls_zfbih-bidat.
      ls_bi-zuonr   = ls_zfbid-zuonr.
      ls_bi-kunnr   = ls_zfbid-kunnr.
      ls_bi-bflag   = ls_zfbid-bflag.
      ls_bi-ptype   = ls_zfbid-ptype.
      APPEND ls_bi TO gt_bi.
      CLEAR ls_bi.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_GET_BI_PAYCUST

*&---------------------------------------------------------------------*
*&      Form  F_BI
*&---------------------------------------------------------------------*
FORM f_bi  USING    fu_vbeln fu_kunnr.
  DATA : ls_bi      LIKE LINE OF gt_bi.

  DATA : lv_ptype(50).

  READ TABLE gt_bi INTO ls_bi
                   WITH KEY kunnr = fu_kunnr
                            zuonr = fu_vbeln.
  IF sy-subrc = 0.
    CASE ls_bi-ptype.
      WHEN 'P1'.
        CONCATENATE ls_bi-ptype '- Tunai/Transfer & Giro' INTO lv_ptype
        SEPARATED BY space.
      WHEN 'P2'.
        CONCATENATE ls_bi-ptype '- Tunai/Transfer' INTO lv_ptype
        SEPARATED BY space.
      WHEN 'P3'.
        CONCATENATE ls_bi-ptype '- Giro' INTO lv_ptype
        SEPARATED BY space.
    ENDCASE.

    PERFORM f_assign_component USING : 'BBELN' ls_bi-bbeln,
                                       'BIDAT' ls_bi-bidat,
                                       'BFLAG' ls_bi-bflag,
                                       'PTYPE' lv_ptype.
  ENDIF.
ENDFORM.                    " F_BI

*&---------------------------------------------------------------------*
*&      Form  F_GET_AR_POTONGAN
*&---------------------------------------------------------------------*
FORM f_get_ar_potongan .
  SELECT zfarpotd~bukrs zfarpotd~gsber zfarpotd~vkbur zfarpotd~noarp
    zfarpotd~mjahr zfarpotd~posnr zfarpotd~kunnr zfarpotd~rtvtyp
    zfarpotd~rtvnr zfarpotd~rtvdt
    FROM zfarpotd JOIN zfarpoth ON  zfarpotd~bukrs  = zfarpoth~bukrs
                                AND zfarpotd~gsber  = zfarpoth~gsber
                                AND zfarpotd~vkbur  = zfarpoth~vkbur
                                AND zfarpotd~noarp  = zfarpoth~noarp
                                AND zfarpotd~mjahr  = zfarpoth~mjahr
    INTO TABLE gt_zfarpotd
    FOR ALL ENTRIES IN gt_arpot
    WHERE zfarpotd~bukrs = gt_arpot-bukrs
      AND zfarpotd~vkbur = gt_arpot-vkbur
      AND zfarpotd~kunnr = gt_arpot-kunnr
      AND zfarpotd~rtvnr = gt_arpot-rtvnr
      AND zfarpoth~belnrrev = space.
ENDFORM.                    " F_GET_AR_POTONGAN

*&---------------------------------------------------------------------*
*&      Form  F_AR_POTONGAN
*&---------------------------------------------------------------------*
FORM f_ar_potongan  USING    fu_rtvnr fu_kunnr.
  DATA : ls_zfarpotd      LIKE LINE OF gt_zfarpotd.

  READ TABLE gt_zfarpotd INTO ls_zfarpotd
                         WITH KEY kunnr = fu_kunnr
                                  rtvnr = fu_rtvnr.
  IF sy-subrc = 0.
    PERFORM f_assign_component USING : 'NOARP' ls_zfarpotd-noarp.
  ENDIF.
ENDFORM.                    " F_AR_POTONGAN

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING    rt_extab TYPE slis_t_extab.
  DATA fcode  TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.

  APPEND '&POS' TO fcode.
  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
ENDFORM.                    " F_SET_PF_STATUS

**---------------------------------------------------------------------*
**       FORM F_USER_COMMAND
**---------------------------------------------------------------------*
*FORM f_user_command USING     fu_ucomm LIKE sy-ucomm
*                              fu_selfield TYPE slis_selfield.
*
*ENDFORM.                    "F_USER_COMMAND
