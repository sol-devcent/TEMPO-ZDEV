*&---------------------------------------------------------------------*
*&  Include           ZCO_RCOGMF01
*&---------------------------------------------------------------------*
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
  IF pa_werks IS INITIAL.
    PERFORM f_error_message USING 'PWE' ''.
  ENDIF.
  IF pa_monat IS INITIAL.
    PERFORM f_error_message USING 'PMO' ''.
  ENDIF.
  IF pa_gjahr IS INITIAL.
    PERFORM f_error_message USING 'PGJ' ''.
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
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : ls_datum   LIKE LINE OF gr_datum.

  CONCATENATE pa_gjahr pa_monat '01' INTO ls_datum-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_datum-low
    IMPORTING
      last_day_of_month = ls_datum-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  ls_datum-sign   = 'I'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO gr_datum.

  SELECT SINGLE waers
    FROM tka01
    INTO gv_waers
    WHERE kokrs = '8010'.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_resb    TYPE STANDARD TABLE OF resb,
         lt_covp    TYPE STANDARD TABLE OF covp,
         lt_cosp    TYPE STANDARD TABLE OF cosp,
         lt_coss    TYPE STANDARD TABLE OF coss,
         lt_caufv   TYPE STANDARD TABLE OF caufv.

  DATA : lv_udate   TYPE sy-datum.

  SELECT *
    FROM caufv
    INTO CORRESPONDING FIELDS OF TABLE gt_caufv
    WHERE werks   = pa_werks
      AND plnbez  IN so_matnr
      AND ( gstri IN gr_datum
       OR gltri   IN gr_datum ).

  IF gt_caufv[] IS NOT INITIAL.
    CONCATENATE pa_gjahr pa_monat '01' INTO lv_udate.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = lv_udate
      IMPORTING
        last_day_of_month = lv_udate
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.

    SELECT *
      FROM jcds
      INTO CORRESPONDING FIELDS OF TABLE gt_jcds
      FOR ALL ENTRIES IN gt_caufv
      WHERE objnr = gt_caufv-objnr
        AND udate <= lv_udate.

    SELECT *
      FROM afko
      INTO CORRESPONDING FIELDS OF TABLE gt_afko
      FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr = gt_caufv-aufnr.
    IF gt_afko[] IS NOT INITIAL.
      SELECT *
        FROM stko
        INTO CORRESPONDING FIELDS OF TABLE gt_stko
        FOR ALL ENTRIES IN gt_afko
        WHERE stlnr = gt_afko-stlnr.
    ENDIF.

    SELECT *
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE gt_afpo
      FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr = gt_caufv-aufnr.

    SELECT *
      FROM covp
      INTO CORRESPONDING FIELDS OF TABLE lt_covp
      FOR ALL ENTRIES IN gt_caufv
      WHERE lednr = '00'
        AND objnr = gt_caufv-objnr.

    PERFORM f_summary_data TABLES lt_covp
                           USING  'COVP'.

    SELECT *
      FROM cosp
      INTO CORRESPONDING FIELDS OF TABLE lt_cosp
      FOR ALL ENTRIES IN gt_caufv
      WHERE lednr = '00'
        AND objnr = gt_caufv-objnr.

    PERFORM f_summary_data TABLES lt_cosp
                           USING  'COSP'.

    SELECT *
      FROM coss
      INTO CORRESPONDING FIELDS OF TABLE lt_coss
      FOR ALL ENTRIES IN gt_caufv
      WHERE lednr = '00'
        AND objnr = gt_caufv-objnr.

    PERFORM f_summary_data TABLES lt_coss
                           USING  'COSS'.

    SELECT *
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FOR ALL ENTRIES IN gt_caufv
      WHERE aufnr = gt_caufv-aufnr
        AND baugr = gt_caufv-plnbez
        AND werks = pa_werks.
  ENDIF.

  lt_caufv[] = gt_caufv[].
  SORT lt_caufv BY plnbez.
  DELETE ADJACENT DUPLICATES FROM lt_caufv COMPARING plnbez.
  IF lt_caufv[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FOR ALL ENTRIES IN lt_caufv
      WHERE matnr = lt_caufv-plnbez.

    CASE 'X'.
      WHEN radio1.
        SELECT *
          FROM mbew
          INTO CORRESPONDING FIELDS OF TABLE gt_fmbew
          FOR ALL ENTRIES IN lt_caufv
          WHERE matnr = lt_caufv-plnbez
            AND bwkey = pa_werks.
    ENDCASE.

    lt_resb[]  = gt_resb[].
    SORT lt_resb BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING matnr.
    IF lt_resb[] IS NOT INITIAL.
      SELECT *
        FROM mbew
        INTO CORRESPONDING FIELDS OF TABLE gt_mbew
        FOR ALL ENTRIES IN lt_resb
        WHERE matnr = lt_resb-matnr
          AND bwkey = pa_werks.

      IF gt_mbew[] IS NOT INITIAL.
        SELECT *
          FROM ckmlcr
          INTO CORRESPONDING FIELDS OF TABLE gt_ckmlcr
          FOR ALL ENTRIES IN gt_mbew
          WHERE kalnr = gt_mbew-kaln1.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gt_fmbew[] IS NOT INITIAL.
    SELECT *
      FROM ckmlprkeph
      INTO CORRESPONDING FIELDS OF TABLE gt_ckmlprkeph
      FOR ALL ENTRIES IN gt_fmbew
      WHERE kalnr = gt_fmbew-kaln1
        AND bdatj = pa_gjahr
        AND poper = pa_monat
        AND kkzst = space
        AND prtyp = 'S'.

    SELECT *
      FROM mlcd
      INTO CORRESPONDING FIELDS OF TABLE gt_mlcd
      FOR ALL ENTRIES IN gt_fmbew
      WHERE kalnr = gt_fmbew-kaln1
        AND bdatj = pa_gjahr
        AND poper = pa_monat
        AND categ = 'ZU'.

    SELECT *
      FROM keko
      INTO CORRESPONDING FIELDS OF TABLE gt_keko
      FOR ALL ENTRIES IN gt_fmbew
      WHERE bzobj = '0'
        AND kalnr = gt_fmbew-kaln1
        AND freidat <> '00000000'.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_color   TYPE lvc_t_scol,
         lt_resb    TYPE STANDARD TABLE OF resb.

  DATA : ls_caufv   LIKE LINE OF gt_caufv,
         ls_afko    LIKE LINE OF gt_afko,
         ls_afpo    LIKE LINE OF gt_afpo,
         ls_stko    LIKE LINE OF gt_stko,
         ls_out     LIKE LINE OF gt_out,
         ls_mara    LIKE LINE OF gt_mara.

  DATA : lv_gltri   TYPE caufv-gltri,
         lv_wemng   TYPE afpo-wemng.

  lt_resb[] = gt_resb[].
  SORT lt_resb BY aufnr matnr.
  DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufnr matnr.

  LOOP AT gt_caufv INTO ls_caufv.
    PERFORM f_status_order USING ls_caufv-objnr
                           CHANGING ls_out-sttxt.

    ls_out-plnbez   = ls_caufv-plnbez.
    ls_out-aufnr    = ls_caufv-aufnr.

    CLEAR ls_mara.
    READ TABLE gt_mara INTO ls_mara
                       WITH KEY matnr = ls_caufv-plnbez.
    IF sy-subrc = 0.
      ls_out-meinh  = ls_mara-meins.
    ENDIF.

    ls_out-gamng    = ls_caufv-gamng.
    CLEAR ls_afko.
    READ TABLE gt_afko INTO ls_afko
                       WITH KEY aufnr = ls_caufv-aufnr.
    IF sy-subrc = 0.
      CLEAR ls_stko.
      READ TABLE gt_stko INTO ls_stko
                         WITH KEY stlnr = ls_afko-stlnr.
      IF sy-subrc = 0.
        ls_out-stktx  = ls_stko-stktx.
      ENDIF.
    ENDIF.

    CLEAR ls_afpo.
    READ TABLE gt_afpo INTO ls_afpo
                       WITH KEY aufnr = ls_caufv-aufnr.
    IF sy-subrc = 0.
      ls_out-charg  = ls_afpo-charg.
      ls_out-verid  = ls_afpo-verid.
      lv_gltri      = ls_afpo-ltrmi.
      lv_wemng      = ls_afpo-wemng.
    ENDIF.


    PERFORM f_alpha_conversion USING 'OUT' ls_caufv-stlal
                               CHANGING ls_out-stlal.

    CASE 'X'.
      WHEN radio1.
        PERFORM f_calc_actual_1 TABLES lt_resb
                                USING lv_gltri lv_wemng ls_caufv-objnr
                                      ls_caufv-aufnr
                                CHANGING ls_out-megbtr ls_out-meinh
                                         ls_out-raact ls_out-paact
                                         ls_out-laact ls_out-nlact
                                         ls_out-lahac ls_out-nlhac.

        PERFORM f_calc_standard_2 USING ls_caufv-aufnr ls_caufv-objnr
                                 CHANGING ls_out-rastd ls_out-pastd
                                          ls_out-lastd ls_out-nlstd
                                          ls_out-lahst ls_out-nlhst.
      WHEN radio2.
        PERFORM f_calc_actual_2 USING ls_caufv-aufnr ls_caufv-objnr
                                CHANGING ls_out-megbtr ls_out-meinh
                                         ls_out-raact ls_out-paact
                                         ls_out-laact ls_out-nlact
                                         ls_out-lahac ls_out-nlhac.
        PERFORM f_calc_standard_2 USING ls_caufv-aufnr ls_caufv-objnr
                                 CHANGING ls_out-rastd ls_out-pastd
                                          ls_out-lastd ls_out-nlstd
                                          ls_out-lahst ls_out-nlhst.
    ENDCASE.

    ls_out-toact  = ls_out-raact + ls_out-paact +
                    ls_out-laact + ls_out-nlact.
    PERFORM f_calc_divide USING ls_out-raact ls_out-megbtr
                          CHANGING ls_out-raacu.
    PERFORM f_calc_divide USING ls_out-paact ls_out-megbtr
                          CHANGING ls_out-paacu.
    PERFORM f_calc_divide USING ls_out-laact ls_out-megbtr
                          CHANGING ls_out-laacu.
    PERFORM f_calc_divide USING ls_out-nlact ls_out-megbtr
                          CHANGING ls_out-nlacu.
    ls_out-toacu  = ls_out-raacu + ls_out-paacu +
                    ls_out-laacu + ls_out-nlacu.

    ls_out-tostd  = ls_out-rastd + ls_out-pastd +
                    ls_out-lastd + ls_out-nlstd.
    PERFORM f_calc_divide USING ls_out-rastd ls_out-gamng
                          CHANGING ls_out-rastu.
    PERFORM f_calc_divide USING ls_out-pastd ls_out-gamng
                          CHANGING ls_out-pastu.
    PERFORM f_calc_divide USING ls_out-lastd ls_out-gamng
                          CHANGING ls_out-lastu.
    PERFORM f_calc_divide USING ls_out-nlstd ls_out-gamng
                          CHANGING ls_out-nlstu.

    ls_out-tostu  = ls_out-rastu + ls_out-pastu +
                    ls_out-lastu + ls_out-nlstu.

    PERFORM f_calc_divide USING ls_out-laact ls_out-lahac
                          CHANGING ls_out-rlaac.
    PERFORM f_calc_divide USING ls_out-nlact ls_out-nlhac
                          CHANGING ls_out-rnlac.
    PERFORM f_calc_divide USING ls_out-lastd ls_out-lahst
                          CHANGING ls_out-rlast.
    PERFORM f_calc_divide USING ls_out-nlstd ls_out-nlhst
                          CHANGING ls_out-rnlst.

    ls_out-total  = ls_out-toacu - ls_out-tostu.
    PERFORM f_calc_divide USING ls_out-total ls_out-toacu
                          CHANGING ls_out-topct.

    ls_out-topct  =  ls_out-topct * 100.
    IF ls_out-topct > 5.
      ls_out-indi1 = icon_alert.
    ENDIF.

    PERFORM set_cell_colours TABLES lt_color
                             USING 'TOACT' 3 '1' '0'.
    ls_out-color = lt_color.
    PERFORM set_cell_colours TABLES lt_color
                             USING 'TOACU' 3 '1' '0'.
    ls_out-color = lt_color.
    PERFORM set_cell_colours TABLES lt_color
                             USING 'TOSTD' 3 '1' '0'.
    ls_out-color = lt_color.
    PERFORM set_cell_colours TABLES lt_color
                             USING 'TOSTU' 3 '1' '0'.
    ls_out-color = lt_color.
    PERFORM set_cell_colours TABLES lt_color
                             USING 'STTXT' 1 '0' '1'.
    ls_out-color = lt_color.

    ls_out-waers  = gv_waers.
    APPEND ls_out TO gt_out.
    CLEAR : ls_out, lt_color[].
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 101.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_create_dyn_int_table .
*  PERFORM f_dyn_int_table USING :
*    'MARK' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
*    '' '' '' '' ''.
*    'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
*    'X' 'X' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'PLNBEZ' '' '' '' '' '' '' 'PLNBEZ' 'CAUFV' 'FG Material' '' ''
    '' '' '' '' 'X' 'X' '' '' '',
    'STKTX' '' '' '' '' '' '' 'STKTX' 'STKO' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'AUFNR' '' '' '' '' '' '' 'AUFNR' 'CAUFV' '' '' '' '' '' '' ''
    'X' 'X' '' '' '',
    'CHARG' '' '' '' '' '' '' 'CHARG' 'AFPO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'STLAL' '' '' '' '' '' '' 'STLAL' 'AFKO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'VERID' '' '' '' '' '' '' 'VERID' 'AFPO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MEINH' '' '' '' '' '' '' 'MEINH' 'COVP' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'MEGBTR' '' '' '' '' 'MEINH' '' '' '' 'GR Qty Act' '' ''
    '' '' '' '' '' '' '' '' '',
    'GAMNG' '' '' '' '' 'MEINH' '' '' '' 'GR Qty Std' '' ''
    '' '' '' '' '' '' '' '' '',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'TKA01' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'RAACT' '' '' 'WAERS' '' '' '' '' '' 'Rawmat(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'PAACT' '' '' 'WAERS' '' '' '' '' '' 'Packmat(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'LAACT' '' '' 'WAERS' '' '' '' '' '' 'Labor(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'NLACT' '' '' 'WAERS' '' '' '' '' '' 'Non Labor(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'TOACT' '' '' 'WAERS' '' '' '' '' '' 'Total(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'RAACU' '' '' 'WAERS' '' '' '' '' '' 'Rawmat/Unit(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'PAACU' '' '' 'WAERS' '' '' '' '' '' 'Packmat/Unit(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'LAACU' '' '' 'WAERS' '' '' '' '' '' 'Labor/Unit(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'NLACU' '' '' 'WAERS' '' '' '' '' '' 'Non Labor/Unit(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'TOACU' '' '' 'WAERS' '' '' '' '' '' 'Total(Act)/Unit' '' '' '' '' ''
    '' '' '' '' '' '',
    'RASTD' '' '' 'WAERS' '' '' '' '' '' 'Rawmat(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'PASTD' '' '' 'WAERS' '' '' '' '' '' 'Packmat(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'LASTD' '' '' 'WAERS' '' '' '' '' '' 'Labor(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'NLSTD' '' '' 'WAERS' '' '' '' '' '' 'Non Labor(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'TOSTD' '' '' 'WAERS' '' '' '' '' '' 'Total(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'RASTU' '' '' 'WAERS' '' '' '' '' '' 'Rawmat/Unit(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'PASTU' '' '' 'WAERS' '' '' '' '' '' 'Packmat/Unit(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'LASTU' '' '' 'WAERS' '' '' '' '' '' 'Labor/Unit(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'NLSTU' '' '' 'WAERS' '' '' '' '' '' 'Non Labor/Unit(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'TOSTU' '' '' 'WAERS' '' '' '' '' '' 'Total(Std)/Unit' '' '' '' '' ''
    '' '' '' '' '' '',
    'LAHAC' '' '' 'WAERS' '' '' '' '' '' 'Labor Hr(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'NLHAC' '' '' 'WAERS' '' '' '' '' '' 'Non Labor Hr(Act)' '' '' '' '' ''
    '' '' '' '' '' '',
    'LAHST' '' '' 'WAERS' '' '' '' '' '' 'Labor Hr(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'NLHST' '' '' 'WAERS' '' '' '' '' '' 'Non Labor Hr(Std)' '' '' '' '' ''
    '' '' '' '' '' '',
    'RLAAC' '' '' '' '' '' '' '' '' 'Rate Labor(Act)' '' '' '' '' '' ''
    '' '' '' '' '',
    'RNLAC' '' '' '' '' '' '' '' '' 'Rate Non Labor(Act)' '' '' '' '' '' ''
    '' '' '' '' '',
    'RLAST' '' '' '' '' '' '' '' '' 'Rate Labor(Std)' '' '' '' '' '' ''
    '' '' '' '' '',
    'RNLST' '' '' '' '' '' '' '' '' 'Rate Non Labor(Std)' '' '' '' '' '' ''
    '' '' '' '' '',
    'TOTAL' '' '' 'WAERS' '' '' '' '' '' 'Incr/Dec Rp.' '' '' '' '' ''
    '' '' '' '' '' '',
    'TOPCT' '' '' '' '' '' '' '' '' 'Incr/Dec %' '' '' '' '' ''
    '' '' '' '' '' '',
    'INDI1' '' '' '' '' '' '' '' '' 'Indicator' '' '' '' '' ''
    'C' '' '' '' '' '',
    'STTXT' '' '' '' '' '' '' '' '' 'Status' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  APPEND '&POS' TO fcode.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  CASE 'X'.
    WHEN radio1.
      SET TITLEBAR 'TITLE1'.
    WHEN radio2.
      SET TITLEBAR 'TITLE2'.
  ENDCASE.
ENDFORM.                    " F_STATUS

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
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

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
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_main_fieldcat[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout_alv-box_fname           = 'MARK'.
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

  PERFORM f_alv_sort USING : 1 'PLNBEZ' 'X' '' '',
                             2 'AUFNR' 'X' '' ''.
ENDFORM.                    " F_BUILD_SORT

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
*&      Form  F_USER_COMMANND
*&---------------------------------------------------------------------*
FORM f_user_commannd .
  DATA : lv_ucomm   TYPE sy-ucomm,
         lv_valid   TYPE c.

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

    WHEN OTHERS.
      CALL METHOD g_tabgrid->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMANND

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style           TYPE lvc_s_styl-style,
         lt_stylerow        TYPE lvc_t_styl,
         ls_stylerow        TYPE lvc_s_styl.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.
        ls_out-mark = fu_check.
        MODIFY gt_out FROM ls_out.
        CLEAR ls_out.
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
*&      Form  F_ALPHA_CONVERSION
*&---------------------------------------------------------------------*
FORM f_alpha_conversion  USING    fu_io fu_value
                         CHANGING fc_value.

  CASE fu_io.
    WHEN 'IN'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = fu_value
        IMPORTING
          output = fc_value.

    WHEN 'OUT'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = fu_value
        IMPORTING
          output = fc_value.
  ENDCASE.
ENDFORM.                    " F_ALPHA_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_CALC_ACTUAL_2
*&---------------------------------------------------------------------*
FORM f_calc_actual_2  USING    fu_aufnr fu_objnr
                      CHANGING fc_megbtr fc_meinh fc_raact fc_paact
                               fc_laact fc_nlact fc_lahac fc_nlhac.
  DATA : ls_covp    LIKE LINE OF gt_covp.

  DATA : lv_raact   TYPE covp-megbtr,
         lv_paact   TYPE covp-megbtr,
         lv_laact   TYPE covp-megbtr,
         lv_nlact   TYPE covp-megbtr.

  LOOP AT gt_covp INTO ls_covp WHERE objnr = fu_objnr.
    CASE ls_covp-vrgng.
      WHEN 'COIN'.
        CASE ls_covp-kstar.
          WHEN '0751500000'.
            ADD ls_covp-megbtr TO fc_megbtr.
            fc_meinh  = ls_covp-meinh.

          WHEN '0751100000' OR '0751210000'.
            PERFORM f_calc_rawpack USING ls_covp-matnr ls_covp-perio ls_covp-gjahr
                                         ls_covp-megbtr
                                   CHANGING lv_raact.
            ADD lv_raact TO fc_raact.

          WHEN '0751200000'.
            PERFORM f_calc_rawpack USING ls_covp-matnr ls_covp-perio ls_covp-gjahr
                                         ls_covp-megbtr
                                   CHANGING lv_paact.
            ADD lv_paact TO fc_paact.
        ENDCASE.

      WHEN 'RKL' OR 'RKLN'. "'KKKS'.
        CASE ls_covp-kstar.
          WHEN '1000000010'.
            ADD ls_covp-wkgbtr TO fc_laact.
            ADD ls_covp-megbtr TO fc_lahac.
          WHEN '1000000020'.
            ADD ls_covp-wkgbtr TO fc_nlact.
            ADD ls_covp-megbtr TO fc_nlhac.
        ENDCASE.
    ENDCASE.
  ENDLOOP.

  fc_megbtr = fc_megbtr * -1.
ENDFORM.                    " F_CALC_ACTUAL_2

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_DATA
*&---------------------------------------------------------------------*
FORM f_summary_data  TABLES   ft_data TYPE STANDARD TABLE
                     USING    fu_reftable.
  DATA : ls_covp    TYPE covp,
         lt_xcovp   TYPE STANDARD TABLE OF covp,
         ls_xcovp   TYPE covp,
         ls_cosp    TYPE cosp,
         lt_xcosp   TYPE STANDARD TABLE OF cosp,
         ls_xcosp   TYPE cosp,
         ls_coss    TYPE coss,
         lt_xcoss   TYPE STANDARD TABLE OF coss,
         ls_xcoss   TYPE coss,
         lv_fwtgx(30),
         lv_fmegx(30).

  FIELD-SYMBOLS <fs> TYPE ANY.

  CASE fu_reftable.
    WHEN 'COVP'.
      lt_xcovp[] = ft_data[].
      SORT lt_xcovp BY objnr matnr.
      LOOP AT lt_xcovp INTO ls_xcovp.
        ls_covp-objnr     = ls_xcovp-objnr.
        ls_covp-matnr     = ls_xcovp-matnr.
        ls_covp-kstar     = ls_xcovp-kstar.
        ls_covp-vrgng     = ls_xcovp-vrgng.
        ls_covp-meinh     = ls_xcovp-meinh.
        ls_covp-megbtr    = ls_xcovp-megbtr.
        ls_covp-wkgbtr    = ls_xcovp-wkgbtr.
        ls_covp-perio     = ls_xcovp-perio.
        ls_covp-gjahr     = ls_xcovp-gjahr.
        IF ls_xcovp-perio = pa_monat AND
          ls_xcovp-gjahr = pa_gjahr.
          COLLECT ls_covp INTO gt_xcovp.
        ENDIF.
        COLLECT ls_covp INTO gt_covp.
        CLEAR ls_covp.
      ENDLOOP.

    WHEN 'COSP'.
      CONCATENATE 'LS_XCOSP-WTG0' pa_monat INTO lv_fwtgx.
      lt_xcosp[] = ft_data[].
      SORT lt_xcosp BY objnr.
      LOOP AT lt_xcosp INTO ls_xcosp.
        ls_cosp-objnr     = ls_xcosp-objnr.
        ls_cosp-kstar     = ls_xcosp-kstar.
        ls_cosp-vrgng     = ls_xcosp-vrgng.

        ASSIGN (lv_fwtgx) TO <fs>.
        ls_cosp-wtg001    = ls_xcosp-wtg001 + ls_xcosp-wtg002 + ls_xcosp-wtg003 +
                            ls_xcosp-wtg004 + ls_xcosp-wtg005 + ls_xcosp-wtg006 +
                            ls_xcosp-wtg007 + ls_xcosp-wtg008 + ls_xcosp-wtg009 +
                            ls_xcosp-wtg010 + ls_xcosp-wtg011 + ls_xcosp-wtg012 +
                            ls_xcosp-wtg013 + ls_xcosp-wtg014 + ls_xcosp-wtg015 +
                            ls_xcosp-wtg016.

        COLLECT ls_cosp INTO gt_cosp.
        CLEAR ls_cosp.
      ENDLOOP.

    WHEN 'COSS'.
      CONCATENATE 'LS_XCOSS-WTG0' pa_monat INTO lv_fwtgx.
      CONCATENATE 'LS_XCOSS-MEG0' pa_monat INTO lv_fmegx.
      lt_xcoss[] = ft_data[].
      SORT lt_xcoss BY objnr.
      LOOP AT lt_xcoss INTO ls_xcoss.
        ls_coss-objnr     = ls_xcoss-objnr.
        ls_coss-kstar     = ls_xcoss-kstar.
        ls_coss-vrgng     = ls_xcoss-vrgng.

        ASSIGN (lv_fwtgx) TO <fs>.
        ls_coss-wtg001    = ls_xcoss-wtg001 + ls_xcoss-wtg002 + ls_xcoss-wtg003 +
                            ls_xcoss-wtg004 + ls_xcoss-wtg005 + ls_xcoss-wtg006 +
                            ls_xcoss-wtg007 + ls_xcoss-wtg008 + ls_xcoss-wtg009 +
                            ls_xcoss-wtg010 + ls_xcoss-wtg011 + ls_xcoss-wtg012 +
                            ls_xcoss-wtg013 + ls_xcoss-wtg014 + ls_xcoss-wtg015 +
                            ls_xcoss-wtg016.
        ASSIGN (lv_fmegx) TO <fs>.
*        ls_coss-meg001    = <fs>.
        ls_coss-meg001    = ls_xcoss-meg001 + ls_xcoss-meg002 + ls_xcoss-meg003 +
                            ls_xcoss-meg004 + ls_xcoss-meg005 + ls_xcoss-meg006 +
                            ls_xcoss-meg007 + ls_xcoss-meg008 + ls_xcoss-meg009 +
                            ls_xcoss-meg010 + ls_xcoss-meg011 + ls_xcoss-meg012 +
                            ls_xcoss-meg013 + ls_xcoss-meg014 + ls_xcoss-meg015 +
                            ls_xcoss-meg016.

        COLLECT ls_coss INTO gt_coss.
        CLEAR ls_coss.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_SUMMARY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CALC_RAWPACK
*&---------------------------------------------------------------------*
FORM f_calc_rawpack  USING    fu_matnr fu_perio fu_gjahr fu_value
                     CHANGING fc_value.
  DATA : ls_mbew    LIKE LINE OF gt_mbew,
         ls_ckmlcr  LIKE LINE OF gt_ckmlcr.

  DATA : lv_pvprs   TYPE p DECIMALS 4.

  CLEAR ls_mbew.
  READ TABLE gt_mbew INTO ls_mbew
                     WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    CLEAR ls_ckmlcr.
    READ TABLE gt_ckmlcr INTO ls_ckmlcr
                         WITH KEY kalnr = ls_mbew-kaln1
                                  poper = fu_perio
                                  bdatj = fu_gjahr.
    IF sy-subrc = 0.
      IF ls_ckmlcr-peinh = 0.
        lv_pvprs = ls_ckmlcr-pvprs.
      ELSE.
        lv_pvprs = ls_ckmlcr-pvprs / ls_ckmlcr-peinh.
      ENDIF.
    ENDIF.
  ENDIF.

  fc_value = fu_value * lv_pvprs.
ENDFORM.                    " F_CALC_RAWPACK

*&---------------------------------------------------------------------*
*&      Form  F_STATUS_ORDER
*&---------------------------------------------------------------------*
FORM f_status_order USING    fu_objnr
                    CHANGING fc_sttxt.
  DATA : lv_udate   TYPE sy-datum,
         lt_jcds    TYPE STANDARD TABLE OF jcds,
         lt_ijcds   TYPE STANDARD TABLE OF jcds,
         lt_ejcds   TYPE STANDARD TABLE OF jcds,
         ls_jcds    LIKE LINE OF gt_jcds,
         ls_ijcds   LIKE LINE OF gt_jcds,
         ls_ejcds   LIKE LINE OF gt_jcds,
         lt_tj02t   TYPE STANDARD TABLE OF tj02t,
         ls_tj02t   LIKE LINE OF lt_tj02t.

  DATA : line       TYPE bsvx-sttxt,
         pos        TYPE i.

  LOOP AT gt_jcds INTO ls_jcds WHERE objnr = fu_objnr.
    IF ls_jcds-stat(1) = 'I'.
      IF ls_jcds-inact IS INITIAL.
        APPEND ls_jcds TO lt_ijcds.
      ELSE.
        APPEND ls_jcds TO lt_ejcds.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT lt_ijcds BY stat chgnr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_ijcds COMPARING stat.
  SORT lt_ejcds BY stat chgnr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_ejcds COMPARING stat.

  LOOP AT lt_ijcds INTO ls_ijcds.
    READ TABLE lt_ejcds INTO ls_ejcds
                        WITH KEY stat = ls_ijcds-stat.
    IF sy-subrc = 0.
      IF ls_ijcds-chgnr > ls_ejcds-chgnr.
        APPEND ls_ijcds TO lt_jcds.
      ENDIF.
    ELSE.
      APPEND ls_ijcds TO lt_jcds.
    ENDIF.
  ENDLOOP.

  IF lt_jcds[] IS NOT INITIAL.
    SELECT *
      FROM tj02t
      INTO CORRESPONDING FIELDS OF TABLE lt_tj02t
      FOR ALL ENTRIES IN lt_jcds
      WHERE istat = lt_jcds-stat
        AND spras = sy-langu.
  ENDIF.

  LOOP AT lt_jcds INTO ls_jcds TO 8.
    CLEAR ls_tj02t.
    READ TABLE lt_tj02t INTO ls_tj02t
                        WITH KEY istat = ls_jcds-stat.
    MOVE ls_tj02t-txt04 TO line+pos(4).
    ADD 5 TO pos.
  ENDLOOP.
  DESCRIBE TABLE lt_jcds LINES sy-tfill.
  IF sy-tfill GT 8.
    MOVE '*' TO line+39(1).
  ENDIF.

  fc_sttxt  = line.

*  CALL FUNCTION 'STATUS_TEXT_EDIT'
*    EXPORTING
*      objnr            = fu_objnr
*      spras            = sy-langu
*    IMPORTING
*      line             = fc_sttxt
*    EXCEPTIONS
*      object_not_found = 1
*      OTHERS           = 2.
ENDFORM.                    " F_STATUS_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_CALC_DIVIDE
*&---------------------------------------------------------------------*
FORM f_calc_divide  USING    fu_value fu_div
                    CHANGING fc_value.

  TRY .
      fc_value = fu_value / fu_div.
    CATCH cx_sy_zerodivide.
  ENDTRY.
ENDFORM.                    " F_CALC_DIVIDE

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_COLOURS
*&---------------------------------------------------------------------*
FORM set_cell_colours  TABLES   ft_color
                       USING    fu_fname fu_col fu_int fu_inv.
  DATA : ls_color TYPE lvc_s_scol,
         lt_color TYPE lvc_t_scol.

  ls_color-fname     = fu_fname.
  ls_color-color-col = fu_col.
  ls_color-color-int = fu_int.
  ls_color-color-inv = fu_inv.
  APPEND ls_color TO ft_color.
  CLEAR ls_color.
ENDFORM.                    " SET_CELL_COLOURS

*&---------------------------------------------------------------------*
*&      Form  F_CALC_STANDARD_2
*&---------------------------------------------------------------------*
FORM f_calc_standard_2  USING    fu_aufnr fu_objnr
                        CHANGING fc_rastd fc_pastd fc_lastd fc_nlstd
                                 fc_lahst fc_nlhst.
  DATA : ls_cosp    LIKE LINE OF gt_cosp,
         ls_coss    LIKE LINE OF gt_coss.

  DATA : lv_raact   TYPE covp-megbtr,
         lv_paact   TYPE covp-megbtr,
         lv_laact   TYPE covp-megbtr,
         lv_nlact   TYPE covp-megbtr.

  LOOP AT gt_cosp INTO ls_cosp WHERE objnr = fu_objnr.
    CASE ls_cosp-vrgng.
      WHEN 'KPPP'.
        CASE ls_cosp-kstar.
          WHEN '0751100000' OR '0751210000'.
            ADD ls_cosp-wtg001 TO fc_rastd.

          WHEN '0751200000'.
            ADD ls_cosp-wtg001 TO fc_pastd.
        ENDCASE.
    ENDCASE.
  ENDLOOP.

  LOOP AT gt_coss INTO ls_coss WHERE objnr = fu_objnr.
    CASE ls_coss-vrgng.
      WHEN 'KPPS'.
        CASE ls_coss-kstar.
          WHEN '1000000010'.
            ADD ls_coss-wtg001 TO fc_lastd.
            ADD ls_coss-meg001 TO fc_lahst.
          WHEN '1000000020'.
            ADD ls_coss-wtg001 TO fc_nlstd.
            ADD ls_coss-meg001 TO fc_nlhst.
        ENDCASE.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_CALC_STANDARD_2

*&---------------------------------------------------------------------*
*&      Form  F_CALC_ACTUAL_1
*&---------------------------------------------------------------------*
FORM f_calc_actual_1  TABLES   ft_resb    STRUCTURE resb
                      USING    fu_gltri fu_wemng fu_objnr fu_aufnr
                      CHANGING fc_megbtr fc_meinh fc_raact fc_paact
                               fc_laact fc_nlact fc_lahac fc_nlhac.

  DATA : lv_perio(6).

  DATA : ls_covp        LIKE LINE OF gt_covp,
         ls_xcovp       LIKE LINE OF gt_xcovp,
         ls_ckmlprkeph  LIKE LINE OF gt_ckmlprkeph,
         ls_keko        LIKE LINE OF gt_keko,
         ls_resb        LIKE LINE OF gt_resb.

  DATA : lv_raact   TYPE ckmlcr-pvprs,
         lv_paact   TYPE ckmlcr-pvprs,
         lv_laact   TYPE ckmlcr-pvprs,
         lv_nlact   TYPE ckmlcr-pvprs.

  DATA : lv_kstm01  TYPE ckmlprkeph-kst001,
         lv_kstm03  TYPE ckmlprkeph-kst003,
         lv_kstm05  TYPE ckmlprkeph-kst005,
         lv_kstm07  TYPE ckmlprkeph-kst007.

  DATA : lv_kstw01  TYPE ckmlprkeph-kst001,
         lv_kstw03  TYPE ckmlprkeph-kst003,
         lv_kstw05  TYPE ckmlprkeph-kst005,
         lv_kstw07  TYPE ckmlprkeph-kst007.

  DATA : lv_kstmx1  TYPE ckmlprkeph-kst001,
         lv_kstmx3  TYPE ckmlprkeph-kst003,
         lv_kstmx5  TYPE ckmlprkeph-kst005,
         lv_kstmx7  TYPE ckmlprkeph-kst007.

  DATA : lv_kstwx1  TYPE ckmlprkeph-kst001,
         lv_kstwx3  TYPE ckmlprkeph-kst003,
         lv_kstwx5  TYPE ckmlprkeph-kst005,
         lv_kstwx7  TYPE ckmlprkeph-kst007.

  LOOP AT gt_xcovp INTO ls_xcovp WHERE objnr = fu_objnr.
    CASE ls_xcovp-vrgng.
      WHEN 'COIN'.
        CASE ls_xcovp-kstar.
          WHEN '0751500000'.
            ADD ls_xcovp-megbtr TO fc_megbtr.
            fc_meinh  = ls_xcovp-meinh.
        ENDCASE.
    ENDCASE.
  ENDLOOP.

  LOOP AT gt_covp INTO ls_covp WHERE objnr = fu_objnr.
    CASE ls_covp-vrgng.
      WHEN 'COIN'.
        CASE ls_covp-kstar.
          WHEN '0751100000' OR '0751210000'.
            PERFORM f_calc_rawpack USING ls_covp-matnr ls_covp-perio ls_covp-gjahr
                                         ls_covp-megbtr
                                   CHANGING lv_raact.
            ADD lv_raact TO fc_raact.

          WHEN '0751200000'.
            PERFORM f_calc_rawpack USING ls_covp-matnr ls_covp-perio ls_covp-gjahr
                                         ls_covp-megbtr
                                   CHANGING lv_paact.
            ADD lv_paact TO fc_paact.
        ENDCASE.

      WHEN 'RKL' OR 'RKLN'. "'KKKS'.
        CASE ls_covp-kstar.
          WHEN '1000000010'.
            ADD ls_covp-wkgbtr TO fc_laact.
            ADD ls_covp-megbtr TO fc_lahac.
          WHEN '1000000020'.
            ADD ls_covp-wkgbtr TO fc_nlact.
            ADD ls_covp-megbtr TO fc_nlhac.
        ENDCASE.
    ENDCASE.
  ENDLOOP.

  fc_megbtr = fc_megbtr * -1.

  LOOP AT gt_ckmlprkeph INTO ls_ckmlprkeph.
    READ TABLE gt_keko INTO ls_keko
                       WITH KEY kalnr = ls_ckmlprkeph-kalnr.
    IF sy-subrc = 0.
      PERFORM f_qty_calculate USING ls_ckmlprkeph fc_megbtr
                                    ls_keko-losau
                              CHANGING lv_kstm01 lv_kstm03 lv_kstm05 lv_kstm07.

      PERFORM f_qty_calculate USING ls_ckmlprkeph fu_wemng
                                    ls_keko-losau
                              CHANGING lv_kstw01 lv_kstw03 lv_kstw05 lv_kstw07.
    ENDIF.
    ADD lv_kstm01 TO lv_kstmx1.
    ADD lv_kstm03 TO lv_kstmx3.
    ADD lv_kstm05 TO lv_kstmx5.
    ADD lv_kstm07 TO lv_kstmx7.

    ADD lv_kstw01 TO lv_kstwx1.
    ADD lv_kstw03 TO lv_kstwx3.
    ADD lv_kstw05 TO lv_kstwx5.
    ADD lv_kstw07 TO lv_kstwx7.
  ENDLOOP.

  CONCATENATE pa_gjahr pa_monat INTO lv_perio.
  IF fu_gltri(6) = lv_perio.
    IF fu_wemng <> fc_megbtr.
      fc_raact = lv_kstmx1 + fc_raact - lv_kstwx1.
      fc_paact = lv_kstmx3 + fc_paact - lv_kstwx3.
      fc_laact = lv_kstmx5 + fc_laact - lv_kstwx5.
      fc_nlact = lv_kstmx7 + fc_nlact - lv_kstwx7.
    ENDIF.
  ELSE.
    fc_raact = lv_kstmx1.
    fc_paact = lv_kstmx3.
    fc_laact = lv_kstmx5.
    fc_nlact = lv_kstmx7.
  ENDIF.
ENDFORM.                    " F_CALC_ACTUAL_1

*&---------------------------------------------------------------------*
*&      Form  F_QTY_CALCULATE
*&---------------------------------------------------------------------*
FORM f_qty_calculate  USING    fs_ckmlprkeph TYPE ckmlprkeph
                               fu_megbtr fu_losau
                      CHANGING fc_kst001 fc_kst003 fc_kst005 fc_kst007.

  PERFORM f_calc_divide USING fs_ckmlprkeph-kst001 fu_losau
                        CHANGING fc_kst001.
  fc_kst001 = fc_kst001 * fu_megbtr.

  PERFORM f_calc_divide USING fs_ckmlprkeph-kst003 fu_losau
                        CHANGING fc_kst003.
  fc_kst003 = fc_kst003 * fu_megbtr.

  PERFORM f_calc_divide USING fs_ckmlprkeph-kst005 fu_losau
                        CHANGING fc_kst005.
  fc_kst005 = fc_kst005 * fu_megbtr.

  PERFORM f_calc_divide USING fs_ckmlprkeph-kst007 fu_losau
                        CHANGING fc_kst007.
  fc_kst007 = fc_kst007 * fu_megbtr.
ENDFORM.                    " F_QTY_CALCULATE
