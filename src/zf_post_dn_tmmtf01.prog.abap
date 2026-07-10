*&---------------------------------------------------------------------*
*&  Include           ZUPLOAD_FORECASTF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*   CLASSES
*&---------------------------------------------------------------------*
*- Classes
CLASS lcl_handle_events DEFINITION DEFERRED.
DATA : cl_events   TYPE  REF TO lcl_handle_events.
*----------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.

  PUBLIC SECTION.
    METHODS:top_of_page
                FOR EVENT top_of_page OF cl_salv_events_hierseq
      IMPORTING r_top_of_page.

    METHODS:double_click
                FOR EVENT double_click OF cl_salv_events_hierseq
      IMPORTING level row column.

    METHODS:on_user_command
                FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

ENDCLASS.                    "lcl_handle_events DEFINITION
*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_HANDLE_EVENTS
*&---------------------------------------------------------------------*
*        Top Of Page
*----------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD top_of_page.

  ENDMETHOD.                    "top_of_page

  METHOD double_click.
*    break tds_dev01.
*    IF level = '1' AND column = 'EBELN'.
*      CLEAR gs_header.
*      READ TABLE gt_header INTO gs_header INDEX row.
*      SET PARAMETER ID: 'BES' FIELD gs_header-ebeln.
*      CALL TRANSACTION 'ME23N'.
*    ENDIF.
  ENDMETHOD.                    "double_click

  METHOD on_user_command.
    CASE e_salv_function.
      WHEN 'SIM'.
        PERFORM f_posting USING e_salv_function.
        IF gv_err = 'X'.
          MESSAGE 'Amount not balance' TYPE 'S' DISPLAY LIKE 'E'.
          gt_hierseq->refresh( ).
        ENDIF.

        gt_hierseq->refresh( ).

      WHEN 'POST'.
        PERFORM f_posting USING e_salv_function.
        IF gv_err = 'X'.
          MESSAGE 'Amount not balance' TYPE 'S' DISPLAY LIKE 'E'.
          gt_hierseq->refresh( ).
        ENDIF.

*        SORT gt_hdr BY bukrs gjahr invno.
        gr_selections->set_selection_mode( cl_salv_selections=>if_salv_c_selection_mode~none ).
        gt_hierseq->refresh( ).
*          LEAVE TO SCREEN 0.
    ENDCASE.
  ENDMETHOD.                    "on_user_command

ENDCLASS.               "LCL_HANDLE_EVENTS
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  gv_repid = sy-repid.

  SELECT *
    FROM zfiprctr
    INTO CORRESPONDING FIELDS OF TABLE gt_zfiprctr.

  SELECT SINGLE *
    FROM lfb1
    INTO CORRESPONDING FIELDS OF gs_lfb1
    WHERE lifnr = gc_lifnr.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  gv_ucomm = 'SIM'.
  PERFORM f_alv TABLES gt_hdr gt_itm.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'R01'.
        CASE 'X'.
          WHEN radio3.
            screen-active = '0'.
            MODIFY SCREEN.
          WHEN OTHERS.
        ENDCASE.
      WHEN 'R03'.
        CASE 'X'.
          WHEN radio1. "OR radio2.
            screen-active = '0'.
            MODIFY SCREEN.
          WHEN OTHERS.
        ENDCASE.
      WHEN 'GRY'.
        screen-input = '0'.
        MODIFY SCREEN.
      WHEN 'NDS'.
        screen-active = '0'.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.
  IF radio4 <> 'X'.
    PERFORM f_modify_screen USING: 'R04' '0' '' '' '' ''.
  ELSE.
    PERFORM f_modify_screen USING: 'R01' '0' '' '' '' '',
                                   'R05' '0' '' '' '' ''.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'CHK'.
          screen-active = '0'.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length fu_required.
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
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF p_bukrs IS INITIAL.
    MESSAGE 'Please input Company Code' TYPE 'I'.
    STOP.   "RETURN.
  ENDIF.

  IF s_budat[] IS INITIAL.
    MESSAGE 'Please input Period' TYPE 'I'.
    STOP.   "RETURN.
  ENDIF.

  IF p_gjahr IS INITIAL AND radio3 = 'X'.
    MESSAGE 'Please input Fiscal Year' TYPE 'I'.
    STOP.   "RETURN.
  ENDIF.

  IF s_xref2[] IS INITIAL AND radio3 = 'X'.
    MESSAGE 'Please input Nomor DN' TYPE 'I'.
    STOP.   "RETURN.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0200 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_print_error_log.
ENDMODULE.                 " LIST_PROCESSING_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_print_error_log .
*  DATA: lt_ztdnsddt011 TYPE TABLE OF ztdnsddt011 WITH HEADER LINE.
*
*  READ TABLE gt_out ASSIGNING <fs_out> INDEX gv_row_num-row_id.
*
*  SELECT * INTO TABLE lt_ztdnsddt011
*    FROM ztdnsddt011 WHERE bukrs = <fs_out>-bukrs
*                       AND logno = <fs_out>-logno.
*
*  WRITE:/(130) 'E R R O R   L I S T' CENTERED.
*  ULINE AT /(121).
*  WRITE:/ sy-vline NO-GAP,  (10) 'Log number' NO-GAP,
*          sy-vline NO-GAP,   (7) 'Itm#' NO-GAP,
*          sy-vline NO-GAP, (100) 'Message' NO-GAP,
*          sy-vline NO-GAP.
*  ULINE AT /(121).
*
*  LOOP AT lt_ztdnsddt011.
*    WRITE:/ sy-vline NO-GAP,  (10) lt_ztdnsddt011-logno NO-GAP,
*            sy-vline NO-GAP,   (7) lt_ztdnsddt011-logit NO-GAP,
*            sy-vline NO-GAP, (100) lt_ztdnsddt011-message NO-GAP,
*            sy-vline NO-GAP.
*  ENDLOOP.
*  ULINE AT /(121).
ENDFORM.                    " F_PRINT_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_bukrs
    IMPORTING
      output = gv_vbund.

  SELECT *
    FROM zfidt013
    INTO CORRESPONDING FIELDS OF TABLE gt_013.

  SELECT * INTO TABLE gt_zfgscab
    FROM zfgscab WHERE bukrs    EQ gc_bukrs
                   AND vbund    EQ gv_vbund
                   AND zsubtype IN s_subty
                   AND tglpost  IN s_budat
                   AND xref2    IN s_xref2.

  IF gt_zfgscab[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.

  ELSE.
    SELECT *
      FROM t25a6
      INTO CORRESPONDING FIELDS OF TABLE gt_t25a6
      WHERE spras = sy-langu.

    SELECT kunnr name1
      INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FROM kna1 FOR ALL ENTRIES IN gt_zfgscab
      WHERE kunnr = gt_zfgscab-kunnr.

    SELECT kunnr kvgr4
      INTO CORRESPONDING FIELDS OF TABLE gt_knvv
      FROM knvv
      FOR ALL ENTRIES IN gt_zfgscab
      WHERE kunnr = gt_zfgscab-kuntm
        AND vkorg = gt_zfgscab-bukrs.

    SELECT * INTO TABLE gt_zfgscab_hdr
      FROM zfgscab_hdr FOR ALL ENTRIES IN gt_zfgscab
      WHERE xref2 = gt_zfgscab-xref2.

    SELECT * INTO TABLE gt_zfgscab_dtl
      FROM zfgscab_dtl FOR ALL ENTRIES IN gt_zfgscab
      WHERE bukrs = gt_zfgscab-bukrs
        AND gjahr = gt_zfgscab-tglpost(4)
        AND xref2 = gt_zfgscab-xref2
        AND fi_posting = space.
    "      GROUP BY bukrs gjahr xref2.

    IF gt_zfgscab_dtl[] IS NOT INITIAL.
      PERFORM f_get_zfgscab_map.
      PERFORM f_get_marc.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: lv_werks       LIKE marc-werks,
        lv_count       TYPE int4,
        ls_zfgscab_dtl LIKE LINE OF gt_zfgscab_dtl,
        ls_zfgscab_map LIKE LINE OF gt_zfgscab_map,
        ls_cepct       LIKE LINE OF gt_cepct.

  DATA : lt_itm1         TYPE STANDARD TABLE OF ty_itm,
         ls_itm1         LIKE LINE OF lt_itm1,
         lt_itm2         TYPE STANDARD TABLE OF ty_itm,
         ls_itm2         LIKE LINE OF lt_itm2,
         ls_t25a6        LIKE LINE OF gt_t25a6,
         ls_zfgscab_map1 LIKE LINE OF gt_zfgscab_map1,
         ls_013          LIKE LINE OF gt_013.

  LOOP AT gt_zfgscab.
    CLEAR gt_zfgscab_hdr.
    READ TABLE gt_zfgscab_hdr WITH KEY xref2    = gt_zfgscab-xref2.

    READ TABLE gt_zfgscab_dtl INTO DATA(ls_dtl)
                              WITH KEY bukrs    = gt_zfgscab-bukrs
                                       gjahr    = gt_zfgscab-tglpost(4)
                                       xref2    = gt_zfgscab-xref2.
    IF sy-subrc NE 0.
      CONTINUE.
    ELSEIF ls_dtl-exp_sub_grp(1) = 'L'.
      CONTINUE.
    ENDIF.

    CLEAR: gt_kna1.
    READ TABLE gt_kna1 WITH KEY kunnr = gt_zfgscab-kunnr.

    CLEAR gt_knvv.
    READ TABLE gt_knvv WITH KEY kunnr = gt_zfgscab-kuntm.

    APPEND INITIAL LINE TO gt_hdr ASSIGNING <fs_hdr>.
    <fs_hdr>-bukrs      = p_bukrs.
    <fs_hdr>-gjahr      = gt_zfgscab-gjahr.
    <fs_hdr>-bukrs_dtl  = gt_zfgscab-bukrs.
    <fs_hdr>-gjahr_dtl  = gt_zfgscab-tglpost(4).
    <fs_hdr>-vbund      = gt_zfgscab-vbund.
    <fs_hdr>-xref2      = gt_zfgscab-xref2.
    <fs_hdr>-tglpost    = gt_zfgscab-tglpost.
    <fs_hdr>-kunnr      = gt_zfgscab-kunnr.
    <fs_hdr>-name1      = gt_kna1-name1.
    <fs_hdr>-waers      = gt_zfgscab-waers.
    <fs_hdr>-perfr      = gt_zfgscab-perfr.
    <fs_hdr>-perto      = gt_zfgscab-perto.
    <fs_hdr>-sgtxt      = gt_zfgscab-sgtxt.

    CLEAR: lv_count,ls_zfgscab_map.

    LOOP AT gt_zfgscab_dtl WHERE bukrs    = <fs_hdr>-bukrs_dtl
                             AND gjahr    = <fs_hdr>-gjahr_dtl
                             AND xref2    = <fs_hdr>-xref2.
      CLEAR: lv_werks,gt_zfgscab_map,gt_zfgscab_map2,gt_marc,gt_makt,ls_cepct.

      CONCATENATE gt_zfgscab_dtl-bukrs+1(3) '0' INTO lv_werks.

      CASE gt_zfgscab-vbund.
        WHEN '008180'.
          lv_werks = '1800'.
        WHEN '008010'.
          lv_werks = '0100'.
      ENDCASE.

      READ TABLE gt_zfgscab_map WITH KEY vbund    = <fs_hdr>-vbund
                                         gjahr    = gt_zfgscab_dtl-gjahr
                                         exp_type = gt_zfgscab_dtl-exp_sub_grp.  "gt_zfgscab_dtl-exp_type.
      READ TABLE gt_zfgscab_map2 WITH KEY cust_sub_grp = gt_zfgscab_dtl-cust_sub_grp.
      READ TABLE gt_marc WITH KEY matnr = gt_zfgscab_dtl-matnr.
*                                  werks = lv_werks.
      READ TABLE gt_cepct INTO ls_cepct WITH KEY prctr = gt_marc-prctr.
      READ TABLE gt_makt WITH KEY matnr = gt_zfgscab_dtl-matnr.

      IF lv_count IS INITIAL.
        ls_zfgscab_map = gt_zfgscab_map.
      ELSE.
        ADD 1 TO lv_count.
      ENDIF.

      READ TABLE gt_itm ASSIGNING <fs_itm>
                        WITH KEY bukrs = gt_zfgscab_dtl-bukrs
                                 gjahr = gt_zfgscab_dtl-gjahr
                                 xref2 = gt_zfgscab_dtl-xref2
                                 prctr = gt_marc-prctr
                                 matnr = gt_zfgscab_dtl-matnr.

      IF sy-subrc = 0.
        ADD gt_zfgscab_dtl-amount TO <fs_itm>-amount.
        ADD gt_zfgscab_dtl-amount TO <fs_hdr>-amount.
      ELSE.
        APPEND INITIAL LINE TO gt_itm ASSIGNING <fs_itm>.
        <fs_itm>-bukrs        = gt_zfgscab_dtl-bukrs.
        <fs_itm>-gjahr        = gt_zfgscab_dtl-gjahr.
        <fs_itm>-xref2        = gt_zfgscab_dtl-xref2.
        <fs_itm>-prctr        = gt_marc-prctr.
        <fs_itm>-matnr        = gt_zfgscab_dtl-matnr.
        <fs_itm>-maktx        = gt_makt-maktx.
        <fs_itm>-ltext        = ls_cepct-ltext.
        <fs_itm>-exp_type     = gt_zfgscab_dtl-exp_type.
        <fs_itm>-nm_break     = gt_zfgscab_dtl-nm_break.
        <fs_itm>-hkont        = gt_zfgscab_map-hkont.
        <fs_itm>-aufnr        = gt_zfgscab_map-aufnr.
        <fs_itm>-cust_grp     = gt_zfgscab_dtl-cust_grp.

        CLEAR ls_t25a6.
        READ TABLE gt_t25a6 INTO ls_t25a6
                            WITH KEY wwtrz = gt_knvv-kvgr4.
        IF sy-subrc = 0.
          CONCATENATE gt_knvv-kvgr4 ls_t25a6-bezek INTO <fs_itm>-cust_sub_grp
          SEPARATED BY space.
        ENDIF.
*        <fs_itm>-cust_sub_grp = gt_zfgscab_dtl-cust_sub_grp.
        <fs_itm>-amount       = gt_zfgscab_dtl-amount.
        <fs_itm>-currency     = gt_zfgscab_dtl-currency.
        <fs_itm>-gsber        = lv_werks.
        <fs_itm>-wwtrz        = gt_zfgscab_map2-wwtrz.
        <fs_itm>-exp_sub_grp  = gt_zfgscab_dtl-exp_sub_grp.
        CLEAR ls_013.
        READ TABLE gt_013 INTO ls_013
                          WITH KEY exp_sub_grp = gt_zfgscab_dtl-exp_sub_grp.
        IF sy-subrc = 0.
          <fs_itm>-exp_desc  = ls_013-exp_desc.
        ENDIF.
****        IF p_bukrs = '8010' OR
****          p_bukrs = '8180'.
****          <fs_itm>-wwtrz        = gt_knvv-kvgr4.
****        ENDIF.
**        DATA: lv_exp_type TYPE zfgscab_map1-exp_sub_grp.
**        lv_exp_type = gt_zfgscab_dtl-exp_sub_grp.
        LOOP AT gt_zfgscab_map1 INTO ls_zfgscab_map1 WHERE vbund = <fs_hdr>-vbund
                                                       AND gjahr = gt_zfgscab_dtl-gjahr
                                                       AND exp_sub_grp = gt_zfgscab_dtl-exp_sub_grp.
          <fs_itm>-hkont = ls_zfgscab_map1-hkont.
          <fs_itm>-wwtrz = ls_zfgscab_map1-wwtrz.
          <fs_itm>-wwsec = ls_zfgscab_map1-wwsec.
          IF ls_zfgscab_map1-wwtrz = gt_knvv-kvgr4.
            <fs_itm>-aufnr = ls_zfgscab_map1-aufnr.
          ENDIF.
        ENDLOOP.

        IF p_bukrs = '8010' OR
          p_bukrs = '8180'.
          <fs_itm>-wwtrz        = gt_knvv-kvgr4.
        ENDIF.

**        READ TABLE gt_zfgscab_map1 INTO ls_zfgscab_map1
**            WITH KEY bukrs = p_bukrs
**                     gjahr = gt_zfgscab_dtl-gjahr
**                     exp_type = gt_zfgscab_dtl-exp_type
**                     hkont = gt_zfgscab_map-hkont.
**        IF sy-subrc EQ 0.
**          <fs_itm>-aufnr = ls_zfgscab_map1-aufnr.
**          <fs_itm>-wwtrz = ls_zfgscab_map1-wwtrz.
**          <fs_itm>-wwsec = ls_zfgscab_map1-wwsec.
**        ENDIF.
        ADD gt_zfgscab_dtl-amount TO <fs_hdr>-amount.
      ENDIF.
    ENDLOOP.

    IF gt_zfgscab_hdr-pph IS NOT INITIAL.
      <fs_hdr>-pph = gt_zfgscab_hdr-pph.
    ENDIF.
    IF gt_zfgscab_hdr-ppn IS NOT INITIAL.
      <fs_hdr>-ppn = gt_zfgscab_hdr-ppn.
    ENDIF.

****    IF ls_zfgscab_map-pph IS NOT INITIAL.
****      <fs_hdr>-pph = <fs_hdr>-amount * ls_zfgscab_map-pph / 100.
****    ENDIF.
****    IF ls_zfgscab_map-ppn IS NOT INITIAL.
****      <fs_hdr>-ppn = <fs_hdr>-amount * ls_zfgscab_map-ppn / 100.
****    ENDIF.

    IF gt_zfgscab_dtl-fi_posting IS NOT INITIAL.
      <fs_hdr>-chkbx = '2'.
      <fs_hdr>-msg   = 'Already Post'.
    ENDIF.
  ENDLOOP.

  PERFORM f_summaries_item.

  lt_itm2[] = lt_itm1[] = gt_itm[].
  CLEAR gt_itm[].
  SORT lt_itm1 BY prctr.
  DELETE ADJACENT DUPLICATES FROM lt_itm1 COMPARING prctr.
  LOOP AT lt_itm1 INTO ls_itm1.
    CLEAR : lv_count, ls_itm2.
    LOOP AT lt_itm2 INTO ls_itm2 WHERE prctr = ls_itm1-prctr.
      ADD 1 TO lv_count.
      IF lv_count = 2.
        EXIT.
      ENDIF.
    ENDLOOP.
    CASE lv_count.
      WHEN 1.
        APPEND ls_itm1 TO gt_itm.
      WHEN 2.
        CLEAR ls_itm2.
        LOOP AT lt_itm2 INTO ls_itm2 WHERE prctr = ls_itm1-prctr.
          CLEAR : ls_itm2-matnr, ls_itm2-maktx.
          COLLECT ls_itm2 INTO gt_itm.
          CLEAR ls_itm2.
        ENDLOOP.
    ENDCASE.
  ENDLOOP.

  "Check data
  LOOP AT gt_hdr ASSIGNING <fs_hdr>.
    READ TABLE gt_itm WITH KEY bukrs = <fs_hdr>-bukrs
                               gjahr = <fs_hdr>-gjahr
                               xref2 = <fs_hdr>-xref2
                               prctr = space
                               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      <fs_hdr>-chkbx = '2'.
      <fs_hdr>-icon  = icon_led_red.
    ELSE.
      <fs_hdr>-icon  = icon_led_green.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_SKU
*&---------------------------------------------------------------------*
FORM f_process_data_sku .
  DATA: lv_werks       LIKE marc-werks,
        lv_count       TYPE int4,
        ls_zfgscab_dtl LIKE LINE OF gt_zfgscab_dtl,
        ls_zfgscab_map LIKE LINE OF gt_zfgscab_map,
        ls_cepct       LIKE LINE OF gt_cepct.

  DATA : lt_itm1         TYPE STANDARD TABLE OF ty_itm,
         ls_itm1         LIKE LINE OF lt_itm1,
         lt_itm2         TYPE STANDARD TABLE OF ty_itm,
         ls_itm2         LIKE LINE OF lt_itm2,
         ls_t25a6        LIKE LINE OF gt_t25a6,
         ls_zfgscab_map1 LIKE LINE OF gt_zfgscab_map1,
         ls_013          LIKE LINE OF gt_013.

  LOOP AT gt_zfgscab.
    READ TABLE gt_zfgscab_dtl INTO DATA(ls_dtl)
                              WITH KEY bukrs    = gt_zfgscab-bukrs
                                       gjahr    = gt_zfgscab-tglpost(4)
                                       xref2    = gt_zfgscab-xref2.
    IF sy-subrc NE 0.
      CONTINUE.
    ELSEIF ls_dtl-exp_sub_grp(1) NE 'L'.
      CONTINUE.
    ENDIF.

    CLEAR gt_zfgscab_hdr.
    READ TABLE gt_zfgscab_hdr WITH KEY xref2    = gt_zfgscab-xref2.

    CLEAR: gt_kna1.
    READ TABLE gt_kna1 WITH KEY kunnr = gt_zfgscab-kunnr.

    CLEAR gt_knvv.
    READ TABLE gt_knvv WITH KEY kunnr = gt_zfgscab-kuntm.

    APPEND INITIAL LINE TO gt_hdr ASSIGNING <fs_hdr>.
    <fs_hdr>-bukrs      = p_bukrs.
    <fs_hdr>-gjahr      = gt_zfgscab-gjahr.
    <fs_hdr>-bukrs_dtl  = gt_zfgscab-bukrs.
    <fs_hdr>-gjahr_dtl  = gt_zfgscab-tglpost(4).
    <fs_hdr>-vbund      = gt_zfgscab-vbund.
    <fs_hdr>-xref2      = gt_zfgscab-xref2.
    <fs_hdr>-tglpost    = gt_zfgscab-tglpost.
    <fs_hdr>-kunnr      = gt_zfgscab-kunnr.
    <fs_hdr>-name1      = gt_kna1-name1.
    <fs_hdr>-waers      = gt_zfgscab-waers.
    <fs_hdr>-perfr      = gt_zfgscab-perfr.
    <fs_hdr>-perto      = gt_zfgscab-perto.
    <fs_hdr>-sgtxt      = gt_zfgscab-sgtxt.

    CLEAR: lv_count,ls_zfgscab_map.

    LOOP AT gt_zfgscab_dtl WHERE bukrs    = <fs_hdr>-bukrs_dtl
                             AND gjahr    = <fs_hdr>-gjahr_dtl
                             AND xref2    = <fs_hdr>-xref2.
      CLEAR: lv_werks,gt_zfgscab_map,gt_zfgscab_map2,gt_marc,gt_makt,ls_cepct.

      CONCATENATE gt_zfgscab_dtl-bukrs+1(3) '0' INTO lv_werks.

      CASE gt_zfgscab-vbund.
        WHEN '008180'.
          lv_werks = '1800'.
        WHEN '008010'.
          lv_werks = '0100'.
      ENDCASE.

      READ TABLE gt_zfgscab_map WITH KEY vbund    = <fs_hdr>-vbund
                                         gjahr    = gt_zfgscab_dtl-gjahr
                                         exp_type = gt_zfgscab_dtl-exp_sub_grp.  "gt_zfgscab_dtl-exp_type.
      READ TABLE gt_zfgscab_map2 WITH KEY cust_sub_grp = gt_zfgscab_dtl-cust_sub_grp.
      READ TABLE gt_marc WITH KEY matnr = gt_zfgscab_dtl-matnr.
*                                  werks = lv_werks.
      READ TABLE gt_cepct INTO ls_cepct WITH KEY prctr = gt_marc-prctr.
      READ TABLE gt_makt WITH KEY matnr = gt_zfgscab_dtl-matnr.

      IF lv_count IS INITIAL.
        ls_zfgscab_map = gt_zfgscab_map.
      ELSE.
        ADD 1 TO lv_count.
      ENDIF.

      READ TABLE gt_itm ASSIGNING <fs_itm>
                        WITH KEY bukrs = gt_zfgscab_dtl-bukrs
                                 gjahr = gt_zfgscab_dtl-gjahr
                                 xref2 = gt_zfgscab_dtl-xref2
                                 prctr = gt_marc-prctr
                                 matnr = gt_zfgscab_dtl-matnr.

      IF sy-subrc = 0.
        ADD gt_zfgscab_dtl-amount TO <fs_itm>-amount.
        ADD gt_zfgscab_dtl-amount TO <fs_hdr>-amount.
      ELSE.
        APPEND INITIAL LINE TO gt_itm ASSIGNING <fs_itm>.
        <fs_itm>-bukrs        = gt_zfgscab_dtl-bukrs.
        <fs_itm>-gjahr        = gt_zfgscab_dtl-gjahr.
        <fs_itm>-xref2        = gt_zfgscab_dtl-xref2.
        <fs_itm>-prctr        = gt_marc-prctr.
        <fs_itm>-matnr        = gt_zfgscab_dtl-matnr.
        <fs_itm>-maktx        = gt_makt-maktx.
        <fs_itm>-ltext        = ls_cepct-ltext.
        <fs_itm>-exp_type     = gt_zfgscab_dtl-exp_type.
        <fs_itm>-nm_break     = gt_zfgscab_dtl-nm_break.
        <fs_itm>-hkont        = gt_zfgscab_map-hkont.
        <fs_itm>-aufnr        = gt_zfgscab_map-aufnr.
        <fs_itm>-cust_grp     = gt_zfgscab_dtl-cust_grp.

        CLEAR ls_t25a6.
        READ TABLE gt_t25a6 INTO ls_t25a6
                            WITH KEY wwtrz = gt_knvv-kvgr4.
        IF sy-subrc = 0.
          CONCATENATE gt_knvv-kvgr4 ls_t25a6-bezek INTO <fs_itm>-cust_sub_grp
          SEPARATED BY space.
        ENDIF.
*        <fs_itm>-cust_sub_grp = gt_zfgscab_dtl-cust_sub_grp.
        <fs_itm>-amount       = gt_zfgscab_dtl-amount.
        <fs_itm>-currency     = gt_zfgscab_dtl-currency.
        <fs_itm>-gsber        = lv_werks.
        <fs_itm>-wwtrz        = gt_zfgscab_map2-wwtrz.
        <fs_itm>-exp_sub_grp  = gt_zfgscab_dtl-exp_sub_grp.
        CLEAR ls_013.
        READ TABLE gt_013 INTO ls_013
                          WITH KEY exp_sub_grp = gt_zfgscab_dtl-exp_sub_grp.
        IF sy-subrc = 0.
          <fs_itm>-exp_desc  = ls_013-exp_desc.
        ENDIF.
****        IF p_bukrs = '8010' OR
****          p_bukrs = '8180'.
****          <fs_itm>-wwtrz        = gt_knvv-kvgr4.
****        ENDIF.
**        DATA: lv_exp_type TYPE zfgscab_map1-exp_sub_grp.
**        lv_exp_type = gt_zfgscab_dtl-exp_sub_grp.
        LOOP AT gt_zfgscab_map1 INTO ls_zfgscab_map1 WHERE vbund = <fs_hdr>-vbund
                                                       AND gjahr = gt_zfgscab_dtl-gjahr
                                                       AND exp_sub_grp = gt_zfgscab_dtl-exp_sub_grp.
          <fs_itm>-hkont = ls_zfgscab_map1-hkont.
          <fs_itm>-wwtrz = ls_zfgscab_map1-wwtrz.
          <fs_itm>-wwsec = ls_zfgscab_map1-wwsec.
          IF ls_zfgscab_map1-wwtrz = gt_knvv-kvgr4.
            <fs_itm>-aufnr = ls_zfgscab_map1-aufnr.
          ENDIF.
        ENDLOOP.

        IF p_bukrs = '8010' OR
          p_bukrs = '8180'.
          <fs_itm>-wwtrz        = gt_knvv-kvgr4.
        ENDIF.

**        READ TABLE gt_zfgscab_map1 INTO ls_zfgscab_map1
**            WITH KEY bukrs = p_bukrs
**                     gjahr = gt_zfgscab_dtl-gjahr
**                     exp_type = gt_zfgscab_dtl-exp_type
**                     hkont = gt_zfgscab_map-hkont.
**        IF sy-subrc EQ 0.
**          <fs_itm>-aufnr = ls_zfgscab_map1-aufnr.
**          <fs_itm>-wwtrz = ls_zfgscab_map1-wwtrz.
**          <fs_itm>-wwsec = ls_zfgscab_map1-wwsec.
**        ENDIF.
        ADD gt_zfgscab_dtl-amount TO <fs_hdr>-amount.
      ENDIF.
    ENDLOOP.

    IF gt_zfgscab_hdr-pph IS NOT INITIAL.
      <fs_hdr>-pph = gt_zfgscab_hdr-pph.
    ENDIF.
    IF gt_zfgscab_hdr-ppn IS NOT INITIAL.
      <fs_hdr>-ppn = gt_zfgscab_hdr-ppn.
    ENDIF.

****    IF ls_zfgscab_map-pph IS NOT INITIAL.
****      <fs_hdr>-pph = <fs_hdr>-amount * ls_zfgscab_map-pph / 100.
****    ENDIF.
****    IF ls_zfgscab_map-ppn IS NOT INITIAL.
****      <fs_hdr>-ppn = <fs_hdr>-amount * ls_zfgscab_map-ppn / 100.
****    ENDIF.

    IF gt_zfgscab_dtl-fi_posting IS NOT INITIAL.
      <fs_hdr>-chkbx = '2'.
      <fs_hdr>-msg   = 'Already Post'.
    ENDIF.
  ENDLOOP.

*  PERFORM f_summaries_item.

*  lt_itm2[] = lt_itm1[] = gt_itm[].
*  CLEAR gt_itm[].
*  SORT lt_itm1 BY prctr.
*  DELETE ADJACENT DUPLICATES FROM lt_itm1 COMPARING prctr.
*  LOOP AT lt_itm1 INTO ls_itm1.
*    CLEAR : lv_count, ls_itm2.
*    LOOP AT lt_itm2 INTO ls_itm2 WHERE prctr = ls_itm1-prctr.
*      ADD 1 TO lv_count.
*      IF lv_count = 2.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*    CASE lv_count.
*      WHEN 1.
*        APPEND ls_itm1 TO gt_itm.
*      WHEN 2.
*        CLEAR ls_itm2.
*        LOOP AT lt_itm2 INTO ls_itm2 WHERE prctr = ls_itm1-prctr.
*          CLEAR : ls_itm2-matnr, ls_itm2-maktx.
*          COLLECT ls_itm2 INTO gt_itm.
*          CLEAR ls_itm2.
*        ENDLOOP.
*    ENDCASE.
*  ENDLOOP.

  "Check data
  LOOP AT gt_hdr ASSIGNING <fs_hdr>.
    READ TABLE gt_itm WITH KEY bukrs = <fs_hdr>-bukrs
                               gjahr = <fs_hdr>-gjahr
                               xref2 = <fs_hdr>-xref2
                               prctr = space
                               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      <fs_hdr>-chkbx = '2'.
      <fs_hdr>-icon  = icon_led_red.
    ELSE.
      <fs_hdr>-icon  = icon_led_green.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA_SKU

*&---------------------------------------------------------------------*
*&      Form  F_POSTING
*&---------------------------------------------------------------------*
FORM f_posting  USING    fu_ucomm.
  DATA: lt_itm   TYPE TABLE OF ty_itm WITH HEADER LINE,
        ls_itm   LIKE LINE OF lt_itm,
        lv_buzei TYPE bseg-buzei.

  DATA: accountgl         TYPE TABLE OF bapiacgl09,
        accountgl_tmp     TYPE TABLE OF bapiacgl09,
        accountpayable    TYPE TABLE OF bapiacap09,
        accountreceivable TYPE TABLE OF bapiacar09,
        currencyamount    TYPE TABLE OF bapiaccr09,
        extension1        TYPE TABLE OF bapiacextc,
        criteria          TYPE TABLE OF bapiackec9,
        return            TYPE TABLE OF bapiret2.

  DATA: documentheader       TYPE bapiache09,
        ls_accountgl         LIKE LINE OF accountgl,
        ls_accountgl_tmp     LIKE LINE OF accountgl_tmp,
        ls_accountpayable    LIKE LINE OF accountpayable,
        ls_accountreceivable LIKE LINE OF accountreceivable,
        ls_currencyamount    LIKE LINE OF currencyamount,
        ls_extension1        LIKE LINE OF extension1,
        ls_criteria          LIKE LINE OF criteria,
        lv_obj_type          TYPE bapiache09-obj_type,
        ls_return            LIKE LINE OF return.

  lv_obj_type = 'BKPF'.

  "Summaries by PRCTR
  LOOP AT gt_hdr ASSIGNING <fs_hdr> WHERE chkbx = 'X'
                                      AND icon  = icon_led_green.
    LOOP AT gt_itm ASSIGNING <fs_itm> WHERE bukrs = <fs_hdr>-bukrs_dtl
                                        AND gjahr = <fs_hdr>-gjahr_dtl
                                        AND xref2 = <fs_hdr>-xref2.
      MOVE-CORRESPONDING <fs_itm> TO lt_itm.
      CLEAR: lt_itm-matnr,lt_itm-maktx.
      COLLECT lt_itm.
    ENDLOOP.
  ENDLOOP.

  LOOP AT gt_hdr ASSIGNING <fs_hdr> WHERE chkbx = 'X'.
    CLEAR: ls_itm,<fs_hdr>-msg.
    READ TABLE lt_itm INTO ls_itm WITH KEY bukrs = <fs_hdr>-bukrs_dtl
                                           gjahr = <fs_hdr>-gjahr_dtl
                                           xref2 = <fs_hdr>-xref2.

    "documentheader
    documentheader-bus_act    = 'RFBU'.
    documentheader-username   = sy-uname.
    documentheader-comp_code  = p_bukrs.
    documentheader-doc_date   = <fs_hdr>-tglpost.
    documentheader-pstng_date = <fs_hdr>-tglpost.
    documentheader-doc_type   = 'KR'.
*    documentheader-ref_doc_no = <fs_hdr>-xref2.
    DATA(lv_str) = <fs_hdr>-xref2.
    SPLIT lv_str AT '/' INTO: DATA(lv_str1) DATA(lv_str2).
    CONCATENATE lv_str1 'MT' lv_str2 INTO documentheader-ref_doc_no
      SEPARATED BY '/'.

    CONCATENATE ls_itm-exp_type ls_itm-cust_sub_grp
      INTO documentheader-header_txt SEPARATED BY space.
*    documentheader-doc_status = '2'.

    PERFORM f_append_ap TABLES accountpayable
                               extension1
                               currencyamount
                        USING  <fs_hdr>
                               ls_itm
                               lv_buzei.

    LOOP AT lt_itm WHERE bukrs = <fs_hdr>-bukrs_dtl
                     AND gjahr = <fs_hdr>-gjahr_dtl
                     AND xref2 = <fs_hdr>-xref2.

      IF p_bukrs = '8010' AND lt_itm-aufnr IS INITIAL.
        CONTINUE.
      ENDIF.

      PERFORM f_append_gl_item TABLES accountgl
                                      extension1
                                      currencyamount
                               USING  <fs_hdr>
                                      lt_itm
                                      ' '
                                      lv_buzei.

      "criteria
      IF p_bukrs = '8010' OR
        p_bukrs = '8180'.
        ls_criteria-itemno_acc        = lv_buzei.
        ls_criteria-fieldname         = 'WWTRZ'.
        ls_criteria-character         = lt_itm-wwtrz.
        APPEND ls_criteria TO criteria.
        CLEAR ls_criteria.
      ENDIF.

      IF lt_itm-wwsec IS INITIAL.
        CLEAR ls_criteria.
        ls_criteria-itemno_acc        = lv_buzei.
        ls_criteria-fieldname         = 'WWSEC'.
        ls_criteria-character         = lt_itm-aufnr+7(5).
        APPEND ls_criteria TO criteria.
      ELSE.
        CLEAR ls_criteria.
        ls_criteria-itemno_acc        = lv_buzei.
        ls_criteria-fieldname         = 'WWSEC'.
        ls_criteria-character         = lt_itm-wwsec. "lt_itm-aufnr+7(5).
        APPEND ls_criteria TO criteria.
      ENDIF.
    ENDLOOP.

    PERFORM f_append_gl_item TABLES accountgl
                                    extension1
                                    currencyamount
                             USING  <fs_hdr>
                                    lt_itm
                                    ls_itm-exp_type
                                    lv_buzei.

    IF p_susacc = 'X'.
      PERFORM f_append_gl_item_suspend TABLES accountgl
                                              extension1
                                              currencyamount
                                       USING  <fs_hdr>
                                              lt_itm
                                              ls_itm-exp_type
                                              lv_buzei.
    ENDIF.

    CASE fu_ucomm.
      WHEN '&SIM'.
        CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
          EXPORTING
            documentheader = documentheader
          TABLES
            accountgl      = accountgl
            accountpayable = accountpayable
*           accountreceivable = accountreceivable
            currencyamount = currencyamount
            extension1     = extension1
            criteria       = criteria
            return         = return.

        READ TABLE return INTO ls_return WITH KEY type = 'A'.
        IF sy-subrc = 0.
          <fs_hdr>-msg = ls_return-message.
        ELSE.
          READ TABLE return INTO ls_return WITH KEY type = 'E'.
          IF sy-subrc = 0.
            <fs_hdr>-msg = ls_return-message.
          ENDIF.
        ENDIF.

        IF <fs_hdr>-msg IS INITIAL .
          <fs_hdr>-icon  = icon_led_green.
          <fs_hdr>-msg   = 'TO BE POSTED'.
          gv_ucomm = 'POST'.
        ELSE.
          CLEAR: <fs_hdr>-chkbx.
          <fs_hdr>-chkbx = '2'.
          <fs_hdr>-icon  = icon_led_red.
        ENDIF.

      WHEN '&POS'.
        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader = documentheader
          IMPORTING
            obj_type       = lv_obj_type
          TABLES
            accountgl      = accountgl
            accountpayable = accountpayable
*           accountreceivable = accountreceivable
            currencyamount = currencyamount
            extension1     = extension1
            criteria       = criteria
            return         = return.

        READ TABLE return INTO ls_return WITH KEY type = 'A'.
        IF sy-subrc = 0.
          <fs_hdr>-msg = ls_return-message.
        ELSE.
          READ TABLE return INTO ls_return WITH KEY type = 'E'.
          IF sy-subrc = 0.
            <fs_hdr>-msg = ls_return-message.
          ENDIF.
        ENDIF.

        IF <fs_hdr>-msg IS INITIAL .
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          CLEAR: <fs_hdr>-chkbx.
          <fs_hdr>-chkbx = '2'.
          <fs_hdr>-icon  = icon_led_green.

          READ TABLE return INTO ls_return WITH KEY type   = 'S'
                                                    id     = 'RW'
                                                    number = '605'.
          IF sy-subrc = 0.
            CONCATENATE ls_return-message_v2(10) ls_return-message_v2+10(4)
              ls_return-message_v2+14(4) INTO <fs_hdr>-msg SEPARATED BY '/'.
            <fs_hdr>-fi_posting   = ls_return-message_v2(10).
            <fs_hdr>-posting_date = sy-datum.

          ELSE.
            READ TABLE return INTO ls_return WITH KEY type   = 'S'
                                                      id     = 'RW'
                                                      number = '638'.
            IF sy-subrc = 0.
              CONCATENATE ls_return-message_v2(10) ls_return-message_v2+10(4)
                ls_return-message_v2+14(4) INTO <fs_hdr>-msg SEPARATED BY '/'.
              <fs_hdr>-fi_posting   = ls_return-message_v2(10).
              <fs_hdr>-posting_date = sy-datum.

            ELSE.
              CLEAR: <fs_hdr>-chkbx.
              <fs_hdr>-icon  = icon_led_red.
            ENDIF.
          ENDIF.

        ELSE.
          CLEAR: <fs_hdr>-chkbx.
          <fs_hdr>-icon  = icon_led_red.
        ENDIF.
    ENDCASE.

    CLEAR: lv_buzei,accountgl,accountgl_tmp,accountpayable,
           accountreceivable,currencyamount,extension1,criteria,return.
    CLEAR: documentheader,ls_accountgl,ls_accountgl_tmp,ls_accountpayable,
           ls_accountreceivable,ls_currencyamount,ls_extension1 ,ls_criteria,
           lv_obj_type.
  ENDLOOP.
ENDFORM.                    " F_POSTING_BDC

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_SKU
*&---------------------------------------------------------------------*
FORM f_posting_sku  USING    fu_ucomm.
  DATA: lt_itm   TYPE TABLE OF ty_itm WITH HEADER LINE,
        ls_itm   LIKE LINE OF lt_itm,
        lv_buzei TYPE bseg-buzei.

  DATA: accountgl         TYPE TABLE OF bapiacgl09,
        accountgl_tmp     TYPE TABLE OF bapiacgl09,
        accountpayable    TYPE TABLE OF bapiacap09,
        accountreceivable TYPE TABLE OF bapiacar09,
        currencyamount    TYPE TABLE OF bapiaccr09,
        extension1        TYPE TABLE OF bapiacextc,
        criteria          TYPE TABLE OF bapiackec9,
        return            TYPE TABLE OF bapiret2.

  DATA: documentheader       TYPE bapiache09,
        ls_accountgl         LIKE LINE OF accountgl,
        ls_accountgl_tmp     LIKE LINE OF accountgl_tmp,
        ls_accountpayable    LIKE LINE OF accountpayable,
        ls_accountreceivable LIKE LINE OF accountreceivable,
        ls_currencyamount    LIKE LINE OF currencyamount,
        ls_extension1        LIKE LINE OF extension1,
        ls_criteria          LIKE LINE OF criteria,
        lv_obj_type          TYPE bapiache09-obj_type,
        ls_return            LIKE LINE OF return.

  lv_obj_type = 'BKPF'.

  "Summaries by PRCTR
*  LOOP AT gt_hdr ASSIGNING <fs_hdr> WHERE chkbx = 'X'
*                                      AND icon  = icon_led_green.
*    LOOP AT gt_itm ASSIGNING <fs_itm> WHERE bukrs = <fs_hdr>-bukrs_dtl
*                                        AND gjahr = <fs_hdr>-gjahr_dtl
*                                        AND xref2 = <fs_hdr>-xref2.
*      MOVE-CORRESPONDING <fs_itm> TO lt_itm.
*      CLEAR: lt_itm-matnr,lt_itm-maktx.
*      COLLECT lt_itm.
*    ENDLOOP.
*  ENDLOOP.

  LOOP AT gt_hdr ASSIGNING <fs_hdr> WHERE chkbx = 'X'.
    CLEAR: ls_itm,<fs_hdr>-msg.
    READ TABLE gt_itm INTO ls_itm WITH KEY bukrs = <fs_hdr>-bukrs_dtl
                                           gjahr = <fs_hdr>-gjahr_dtl
                                           xref2 = <fs_hdr>-xref2.

    "documentheader
    documentheader-bus_act    = 'RFBU'.
    documentheader-username   = sy-uname.
    documentheader-comp_code  = p_bukrs.
    documentheader-doc_date   = <fs_hdr>-tglpost.
    documentheader-pstng_date = <fs_hdr>-tglpost.
    documentheader-doc_type   = 'KR'.
*    documentheader-ref_doc_no = <fs_hdr>-xref2.
    DATA(lv_str) = <fs_hdr>-xref2.
    SPLIT lv_str AT '/' INTO: DATA(lv_str1) DATA(lv_str2).
    CONCATENATE lv_str1 'MT' lv_str2 INTO documentheader-ref_doc_no
      SEPARATED BY '/'.

    CONCATENATE ls_itm-exp_type ls_itm-cust_sub_grp
      INTO documentheader-header_txt SEPARATED BY space.
*    documentheader-doc_status = '2'.

    PERFORM f_append_ap TABLES accountpayable
                               extension1
                               currencyamount
                        USING  <fs_hdr>
                               ls_itm
                               lv_buzei.

    LOOP AT gt_itm INTO lt_itm
                   WHERE bukrs = <fs_hdr>-bukrs_dtl
                     AND gjahr = <fs_hdr>-gjahr_dtl
                     AND xref2 = <fs_hdr>-xref2.

      IF p_bukrs = '8010' AND lt_itm-aufnr IS INITIAL.
        CONTINUE.
      ENDIF.

      PERFORM f_append_gl_item TABLES accountgl
                                      extension1
                                      currencyamount
                               USING  <fs_hdr>
                                      lt_itm
                                      ' '
                                      lv_buzei.

      "criteria
      IF p_bukrs = '8010' OR
        p_bukrs = '8180'.
        ls_criteria-itemno_acc        = lv_buzei.
        ls_criteria-fieldname         = 'WWTRZ'.
        ls_criteria-character         = lt_itm-wwtrz.
        APPEND ls_criteria TO criteria.
        CLEAR ls_criteria.
      ENDIF.

      IF lt_itm-wwsec IS INITIAL.
        CLEAR ls_criteria.
        ls_criteria-itemno_acc        = lv_buzei.
        ls_criteria-fieldname         = 'WWSEC'.
        ls_criteria-character         = lt_itm-aufnr+7(5).
        APPEND ls_criteria TO criteria.
      ELSE.
        CLEAR ls_criteria.
        ls_criteria-itemno_acc        = lv_buzei.
        ls_criteria-fieldname         = 'WWSEC'.
        ls_criteria-character         = lt_itm-wwsec. "lt_itm-aufnr+7(5).
        APPEND ls_criteria TO criteria.
      ENDIF.
    ENDLOOP.

    PERFORM f_append_gl_item TABLES accountgl
                                    extension1
                                    currencyamount
                             USING  <fs_hdr>
                                    lt_itm
                                    ls_itm-exp_type
                                    lv_buzei.

    IF p_susacc = 'X'.
      PERFORM f_append_gl_item_suspend TABLES accountgl
                                              extension1
                                              currencyamount
                                       USING  <fs_hdr>
                                              lt_itm
                                              ls_itm-exp_type
                                              lv_buzei.
    ENDIF.

    CASE fu_ucomm.
      WHEN '&SIM'.
        CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
          EXPORTING
            documentheader = documentheader
          TABLES
            accountgl      = accountgl
            accountpayable = accountpayable
*           accountreceivable = accountreceivable
            currencyamount = currencyamount
            extension1     = extension1
            criteria       = criteria
            return         = return.

        READ TABLE return INTO ls_return WITH KEY type = 'A'.
        IF sy-subrc = 0.
          <fs_hdr>-msg = ls_return-message.
        ELSE.
          READ TABLE return INTO ls_return WITH KEY type = 'E'.
          IF sy-subrc = 0.
            <fs_hdr>-msg = ls_return-message.
          ENDIF.
        ENDIF.

        IF <fs_hdr>-msg IS INITIAL .
          <fs_hdr>-icon  = icon_led_green.
          <fs_hdr>-msg   = 'TO BE POSTED'.
          gv_ucomm = 'POST'.
        ELSE.
          CLEAR: <fs_hdr>-chkbx.
          <fs_hdr>-chkbx = '2'.
          <fs_hdr>-icon  = icon_led_red.
        ENDIF.

      WHEN '&POS'.
        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader = documentheader
          IMPORTING
            obj_type       = lv_obj_type
          TABLES
            accountgl      = accountgl
            accountpayable = accountpayable
*           accountreceivable = accountreceivable
            currencyamount = currencyamount
            extension1     = extension1
            criteria       = criteria
            return         = return.

        READ TABLE return INTO ls_return WITH KEY type = 'A'.
        IF sy-subrc = 0.
          <fs_hdr>-msg = ls_return-message.
        ELSE.
          READ TABLE return INTO ls_return WITH KEY type = 'E'.
          IF sy-subrc = 0.
            <fs_hdr>-msg = ls_return-message.
          ENDIF.
        ENDIF.

        IF <fs_hdr>-msg IS INITIAL .
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          CLEAR: <fs_hdr>-chkbx.
          <fs_hdr>-chkbx = '2'.
          <fs_hdr>-icon  = icon_led_green.

          READ TABLE return INTO ls_return WITH KEY type   = 'S'
                                                    id     = 'RW'
                                                    number = '605'.
          IF sy-subrc = 0.
            CONCATENATE ls_return-message_v2(10) ls_return-message_v2+10(4)
              ls_return-message_v2+14(4) INTO <fs_hdr>-msg SEPARATED BY '/'.
            <fs_hdr>-fi_posting   = ls_return-message_v2(10).
            <fs_hdr>-posting_date = sy-datum.

          ELSE.
            READ TABLE return INTO ls_return WITH KEY type   = 'S'
                                                      id     = 'RW'
                                                      number = '638'.
            IF sy-subrc = 0.
              CONCATENATE ls_return-message_v2(10) ls_return-message_v2+10(4)
                ls_return-message_v2+14(4) INTO <fs_hdr>-msg SEPARATED BY '/'.
              <fs_hdr>-fi_posting   = ls_return-message_v2(10).
              <fs_hdr>-posting_date = sy-datum.

            ELSE.
              CLEAR: <fs_hdr>-chkbx.
              <fs_hdr>-icon  = icon_led_red.
            ENDIF.
          ENDIF.

        ELSE.
          CLEAR: <fs_hdr>-chkbx.
          <fs_hdr>-icon  = icon_led_red.
        ENDIF.
    ENDCASE.

    CLEAR: lv_buzei,accountgl,accountgl_tmp,accountpayable,
           accountreceivable,currencyamount,extension1,criteria,return.
    CLEAR: documentheader,ls_accountgl,ls_accountgl_tmp,ls_accountpayable,
           ls_accountreceivable,ls_currencyamount,ls_extension1 ,ls_criteria,
           lv_obj_type.
  ENDLOOP.
ENDFORM.                    " F_POSTING_SKU

*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv  TABLES   ft_report1 ft_report2.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat_hierarchy      TABLES  ft_report1 ft_report2.
  PERFORM f_build_layout_hierarchy        USING   d_layout.
  PERFORM f_build_keyinfo_hierarchy       USING   d_alv_keyinfo.
  PERFORM f_build_sortfield_hierarchy     USING   t_alv_isort[].
  PERFORM f_build_event                   TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print_hierarchy         USING   d_print.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      i_tabname_header         = 'GT_HDR'
      i_tabname_item           = 'GT_ITM'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report1
      t_outtab_item            = ft_report2
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_ALV
*---------------------------------------------------------------------*
*       FORM f_build_fieldcat_hierarchy                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat_hierarchy  TABLES ft_report1 ft_report2.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'GT_HDR':
    'CHKBX' '' '' '' '1' '' '' '' '' '' '' '' '' '' '' '',
    'ICON' '' '' '' '10' 'Icon' '' '' '' '' '' '' '' '' '' '',
    'BUKRS' 'ZFGSCAB' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFGSCAB' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'XREF2' 'ZFGSCAB' 'XREF2' '' '' 'Nomor DN' '' '' '' '' '' '' '' '' '' '',
    'TGLPOST' 'ZFGSCAB' 'TGLPOST' '' '' 'Tanggal DN' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZFGSCAB' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '30' 'Customer Name' '' '' '' '' '' '' '' '' '' '',
    'AMOUNT' 'ZFGSCAB_DTL' 'AMOUNT' '' '' '' '' '' '' '' '' 'WAERS' '' '' 'X' '',
    'PPH' 'ZFGSCAB_DTL' 'AMOUNT' '' '' 'PPH' '' '' '' '' '' 'WAERS' '' '' 'X' '',
    'PPN' 'ZFGSCAB_DTL' 'AMOUNT' '' '' 'PPN' '' '' '' '' '' 'WAERS' '' '' 'X' '',
    'WAERS' 'ZFGSCAB' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MSG' '' '' '' '50' 'Posting Message' '' '' '' '' '' '' '' '' '' ''.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_fieldcatg USING 'GT_ITM':
        'PRCTR' 'MARC' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'AUFNR' 'ZFGSCAB_MAP' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
        'LTEXT' 'CEPCT' 'LTEXT' '' '' 'Profit Center Text' '' '' '' '' '' '' '' '' '' '',
*    'MATNR' 'ZFGSCAB_DTL' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '' '' '',
*    'MAKTX' 'MAKT' 'MAKTX' '' '30' '' '' '' '' '' '' '' '' '' '' '',
**    'EXP_TYPE' 'ZFGSCAB_MAP' 'EXP_TYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'EXP_DESC' 'ZFIDT013' 'EXP_DESC' '' '' 'Expense Sub Group' '' '' '' '' '' '' '' '' '' '',
**    'NM_BREAK' 'ZFGSCAB_MAP' 'NM_BREAK' '' '' 'Nama Break' '' '' '' '' '' '' '' '' '' '',
        'WWSEC' 'ZFGSCAB_MAP1' 'WWSEC' '' '' 'SEC' '' '' '' '' '' '' '' '' '' '',
        'HKONT' 'ZFGSCAB_MAP' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'AUFNR' 'ZFGSCAB_MAP' 'AUFNR' '' '8' 'SEC' '' '' '' '' '' '' '' '' '' '',
        'CUST_GRP' '' '' '' '15' 'Cust Group' '' '' '' '' '' '' '' '' '' '',
        'CUST_SUB_GRP' '' '' '' '15' 'Cust Sub Group' '' '' '' '' '' '' '' '' '' '',
        'AMOUNT' 'ZFGSCAB_DTL' 'AMOUNT' '' '' '' '' '' '' '' '' 'CURRENCY' '' '' 'X' '',
        'CURRENCY' 'ZFGSCAB_DTL' 'CURRENCY' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    WHEN radio1a.
      PERFORM f_fieldcatg USING 'GT_ITM':
        'MATNR' 'ZFGSCAB_DTL' 'MATNR' '' '10' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '30' '' '' '' '' '' '' '' '' '' '' '',
        'PRCTR' 'MARC' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'AUFNR' 'ZFGSCAB_MAP' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
*        'LTEXT' 'CEPCT' 'LTEXT' '' '' 'Profit Center Text' '' '' '' '' '' '' '' '' '' '',
**    'EXP_TYPE' 'ZFGSCAB_MAP' 'EXP_TYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'EXP_DESC' 'ZFIDT013' 'EXP_DESC' '' '' 'Expense Sub Group' '' '' '' '' '' '' '' '' '' '',
**    'NM_BREAK' 'ZFGSCAB_MAP' 'NM_BREAK' '' '' 'Nama Break' '' '' '' '' '' '' '' '' '' '',
        'WWSEC' 'ZFGSCAB_MAP1' 'WWSEC' '' '' 'SEC' '' '' '' '' '' '' '' '' '' '',
        'HKONT' 'ZFGSCAB_MAP' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'AUFNR' 'ZFGSCAB_MAP' 'AUFNR' '' '8' 'SEC' '' '' '' '' '' '' '' '' '' '',
        'CUST_GRP' '' '' '' '15' 'Cust Group' '' '' '' '' '' '' '' '' '' '',
        'CUST_SUB_GRP' '' '' '' '15' 'Cust Sub Group' '' '' '' '' '' '' '' '' '' '',
        'AMOUNT' 'ZFGSCAB_DTL' 'AMOUNT' '' '' '' '' '' '' '' '' 'CURRENCY' '' '' 'X' '',
        'CURRENCY' 'ZFGSCAB_DTL' 'CURRENCY' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_HDR'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'GT_ITM'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

ENDFORM.                    " F_build_fieldcat_hierarchy

*---------------------------------------------------------------------*
*       FORM f_build_layout_hierarchy                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout_hierarchy  USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = ' '.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  fu_layout-box_fieldname      = 'CHKBX'.
*  fu_layout-expand_fieldname   = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
*  fu_layout-totals_text        = 'Grand Total'.
*  fu_layout-subtotals_text     = 'Subtotal PRCTR'.
ENDFORM.                    "f_build_layout_hierarchy

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo_hierarchy                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo_hierarchy  USING fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'BUKRS_DTL'.
  fu_keyinfo-item01   = 'BUKRS'.

  fu_keyinfo-header01 = 'GJAHR_DTL'.
  fu_keyinfo-item01   = 'GJAHR'.

  fu_keyinfo-header01 = 'XREF2'.
  fu_keyinfo-item01   = 'XREF2'.
ENDFORM.                    " f_build_keyinfo_hierarchy

*---------------------------------------------------------------------*
*       FORM f_build_sortfield_hierarchy                              *
*---------------------------------------------------------------------*
FORM f_build_sortfield_hierarchy  USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'BUKRS'.
*  ld_sort-tabname   = 'GT_HDR'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'GJAHR'.
*  ld_sort-tabname   = 'GT_HDR'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'XREF2'.
*  ld_sort-tabname   = 'GT_HDR'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PRCTR'.
  ld_sort-tabname   = 'GT_ITM'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'MATNR'.
*  ld_sort-tabname   = 'GT_ITM'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield_hierarchy

*---------------------------------------------------------------------*
*       FORM f_build_print_hierarchy                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print_hierarchy  USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print_hierarchy

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
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
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  DATA fcode TYPE TABLE OF sy-ucomm.
  DATA: is_layout TYPE lvc_s_layo.
  CLEAR: fcode.
  APPEND '&CAN'   TO fcode.
*  APPEND '&FORM'  TO fcode.

  CASE gv_ucomm.
    WHEN 'SIM'.
      APPEND '&POS'  TO fcode.
    WHEN OTHERS.
  ENDCASE.

  sy-lsind = 0.
  IF radio4 <> 'X'.
*    APPEND '&INSHEET' TO fcode.
*    APPEND '&DEL' TO fcode.
    SET PF-STATUS 'STANDARD' EXCLUDING fcode.
  ELSE.
    SET PF-STATUS 'STANDARD2' EXCLUDING fcode.
*    APPEND '&POS'  TO fcode.
*    APPEND '&SIM'  TO fcode.
  ENDIF.
*  SET PF-STATUS 'STANDARD' EXCLUDING fcode.

  CLEAR ref_grid.
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF ref_grid IS NOT INITIAL.
    is_layout-zebra       = 'X'.
    is_layout-no_rowmark  = 'X'.
    is_layout-no_toolbar  = 'X'.
    is_layout-stylefname  = 'STYLE'.

    CALL METHOD ref_grid->set_frontend_layout
      EXPORTING
        is_layout = is_layout.


    CALL METHOD ref_grid->refresh_table_display.

  ENDIF.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.
  IF ref_grid IS NOT INITIAL.
    CALL METHOD ref_grid->check_changed_data( ).
  ENDIF.

  CASE fu_ucomm.
    WHEN '&SALL'.
      PERFORM f_select USING 'X'.
      CALL METHOD ref_grid->refresh_table_display.
    WHEN '&DALL'.
      PERFORM f_select USING ''.
      CALL METHOD ref_grid->refresh_table_display.
    WHEN '&INSHEET'.
      IF radio4 = 'X'.
        DATA: gt_filetable TYPE filetable,
              gv_rc        TYPE i,
              gv_filename  TYPE string.
        DATA: lv_subrc TYPE sy-subrc.
        CLEAR: in_gt_map1[], gt_filetable[].
        CALL METHOD cl_gui_frontend_services=>file_open_dialog
          CHANGING
            file_table = gt_filetable
            rc         = gv_rc.

        IF gt_filetable[] IS NOT INITIAL.
          DATA: filename TYPE rlgrap-filename.
          filename = gt_filetable[ 1 ]-filename.
          CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
            EXPORTING
              filename                = filename
              i_begin_col             = 1
              i_begin_row             = 2
              i_end_col               = 10
              i_end_row               = 99999
            TABLES
              intern                  = intern
            EXCEPTIONS
              inconsistent_parameters = 1
              upload_ole              = 2
              OTHERS                  = 3.
          IF sy-subrc <> 0.
* Implement suitable error handling here

          ELSE.
            LOOP AT intern INTO DATA(wa_intern).
              CASE wa_intern-col.
*          WHEN '001'.
*            APPEND INITIAL LINE TO it_zcodt017 ASSIGNING FIELD-SYMBOL(<fs_zcodt017>).
*            <fs_zcodt017>-bukrs = wa_intern-value.
                WHEN '001'.
*                  DATA: vbund_val TYPE ZFGSCAB_MAP1-vbund.
                  APPEND INITIAL LINE TO in_gt_map1 ASSIGNING FIELD-SYMBOL(<fs_map1>).
                  CONCATENATE '00' wa_intern-value INTO <fs_map1>-vbund."vbund_val.
*                  <fs_map1>-vbund = vbund_val.
*                  <fs_map1>-vbund = wa_intern-value.
                WHEN '002'.
                  <fs_map1>-gjahr = wa_intern-value.
                WHEN '003'.
                  <fs_map1>-exp_sub_grp = wa_intern-value.
                WHEN '004'.
                  <fs_map1>-hkont = wa_intern-value.
                WHEN '005'.
                  <fs_map1>-wwsec = wa_intern-value.
                WHEN '006'.
                  <fs_map1>-wwtrz = wa_intern-value.
                WHEN '007'.
                  <fs_map1>-aufnr = wa_intern-value.
              ENDCASE.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.

      IF in_gt_map1[] IS NOT INITIAL.
        CONCATENATE '00' p_bukrs INTO DATA(vbund_val).
        LOOP AT in_gt_map1 INTO in_gs_map1.
          IF in_gs_map1-vbund <> vbund_val.
            MESSAGE 'Company code not the same as filtered input' TYPE 'E'.
          ENDIF.
        ENDLOOP.
        TYPES: BEGIN OF ty_message,
                 vbund       TYPE zfgscab_map1-vbund,
                 gjahr       TYPE zfgscab_map1-gjahr,
                 exp_sub_grp TYPE zfgscab_map1-exp_sub_grp,
                 hkont       TYPE zfgscab_map1-hkont,
                 wwsec       TYPE zfgscab_map1-wwsec,
                 wwtrz       TYPE zfgscab_map1-wwtrz,
                 message     TYPE char255,
               END OF ty_message.
        DATA: gt_message TYPE TABLE OF ty_message WITH HEADER LINE,
              gs_message TYPE ty_message.
        CLEAR: gt_message[], gs_message.
        LOOP AT in_gt_map1 INTO in_gs_map1.
          READ TABLE gt_map1 INTO gs_map1 WITH KEY vbund = in_gs_map1-vbund gjahr = in_gs_map1-gjahr exp_sub_grp = in_gs_map1-exp_sub_grp hkont = in_gs_map1-hkont wwsec = in_gs_map1-wwsec wwtrz = in_gs_map1-wwtrz.
          MOVE-CORRESPONDING in_gs_map1 TO gs_message.
          IF sy-subrc = 0.
            gs_message-message = 'Duplicate data'.
          ELSE.
            gs_message-message = 'Sucessfully uploaded data'.
          ENDIF.
          APPEND gs_message TO gt_message.
          TRY.
              INSERT zfgscab_map1 FROM in_gs_map1.
*              INSERT zfgscab_map1 FROM TABLE in_gt_map1.
            CATCH cx_sy_open_sql_db.
              lv_subrc = 4.
          ENDTRY.
*          IF lv_subrc = 0.
*            COMMIT WORK AND WAIT.
*            gs_message-message = 'Sucessfully uploaded data'.
**            PERFORM f_get_data_new.
**            fu_selfield-refresh = 'X'.
**            MESSAGE 'Successfully uploaded data' TYPE 'S'.
*          ELSE.
*            gs_message-message = 'Duplicate'.
**            MESSAGE 'Processing error' TYPE 'E'.
*          ENDIF.
        ENDLOOP.
        PERFORM f_get_data_new.
        LOOP AT gt_message INTO gs_message.
          READ TABLE gt_map1 INTO gs_map1 WITH KEY vbund = gs_message-vbund gjahr = gs_message-gjahr exp_sub_grp = gs_message-exp_sub_grp hkont = gs_message-hkont wwsec = gs_message-wwsec wwtrz = gs_message-wwtrz.
          IF sy-subrc = 0.
          gs_map1-message = gs_message-message.
          MODIFY gt_map1 FROM gs_map1 TRANSPORTING message WHERE vbund = gs_message-vbund AND gjahr = gs_message-gjahr AND exp_sub_grp = gs_message-exp_sub_grp AND hkont = gs_message-hkont AND wwsec = gs_message-wwsec AND wwtrz =
gs_message-wwtrz.
          ENDIF.
        ENDLOOP.
*        PERFORM f_get_data_new.
        fu_selfield-refresh = 'X'.
      ELSE.
        MESSAGE 'No data' TYPE 'E'.
      ENDIF.

    WHEN '&DEL'.
      IF radio4 = 'X'.
        DATA: del_lt_map1 TYPE TABLE OF zfgscab_map1,
              del_ls_map1 TYPE zfgscab_map1.
        DATA(lt_map1) = gt_map1[].
        DELETE lt_map1[] WHERE check <> 'X'.
        LOOP AT lt_map1 INTO DATA(ls_map1).
          MOVE-CORRESPONDING ls_map1 TO del_ls_map1.
          APPEND del_ls_map1 TO del_lt_map1.
        ENDLOOP.
        DELETE zfgscab_map1 FROM TABLE del_lt_map1.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
          PERFORM f_get_data_new.
          fu_selfield-refresh = 'X'.
          MESSAGE 'Successfully uploaded data' TYPE 'S'.
        ENDIF.
      ENDIF.
    WHEN '&SIM'.
      IF p_bukrs = '8180' OR p_bukrs = '8010'.
        CALL SELECTION-SCREEN 1001 STARTING AT 20 10 ENDING AT 80 12.
      ENDIF.

      CASE 'X'.
        WHEN radio1.
          PERFORM f_posting USING fu_ucomm.
        WHEN radio1a.
          PERFORM f_posting_sku USING fu_ucomm.
      ENDCASE.
      fu_selfield-refresh = 'X'.

    WHEN '&POS'.
      IF p_bukrs = '8180' OR p_bukrs = '8010'.
        CALL SELECTION-SCREEN 1001 STARTING AT 20 10 ENDING AT 80 12.
      ENDIF.

      CASE 'X'.
        WHEN radio1.
          PERFORM f_posting USING fu_ucomm.
        WHEN radio1a.
          PERFORM f_posting_sku USING fu_ucomm.
      ENDCASE.
      PERFORM f_update_table.
      fu_selfield-refresh = 'X'.
  ENDCASE.
ENDFORM.                    "f_user_command

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_INIT_BUDAT
*&---------------------------------------------------------------------*
FORM f_init_budat .
  s_budat-sign = 'I'.
  s_budat-option = 'BT'.
  CONCATENATE sy-datum(6) '01' INTO s_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = s_budat-low
    IMPORTING
      last_day_of_month = s_budat-high.
  APPEND s_budat.
ENDFORM.                    " F_INIT_BUDAT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SUBTYPE
*&---------------------------------------------------------------------*
FORM f_init_subtype .
  CLEAR s_subty.
  s_subty-sign    = 'I'.
  s_subty-option  = 'EQ'.
  s_subty-low     = '15'.
  APPEND s_subty.
  s_subty-low     = '57'.
  APPEND s_subty.
ENDFORM.                    " F_INIT_SUBTYPE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZFGSCAB_MAP
*&---------------------------------------------------------------------*
FORM f_get_zfgscab_map .
  DATA: lt_zfgscab_dtl TYPE TABLE OF zfgscab_dtl.

  "Get ZFGSCAB_MAP
  lt_zfgscab_dtl[] = gt_zfgscab_dtl[].
  SORT lt_zfgscab_dtl BY bukrs gjahr exp_type.
  DELETE ADJACENT DUPLICATES FROM lt_zfgscab_dtl
    COMPARING bukrs gjahr exp_type.
  SELECT * INTO TABLE gt_zfgscab_map
    FROM zfgscab_map FOR ALL ENTRIES IN lt_zfgscab_dtl
    WHERE vbund = gv_vbund
      AND gjahr = lt_zfgscab_dtl-gjahr
      AND exp_type = lt_zfgscab_dtl-exp_sub_grp(20).  "exp_type.

  SELECT * INTO TABLE gt_zfgscab_map1
    FROM zfgscab_map1 FOR ALL ENTRIES IN lt_zfgscab_dtl
    WHERE vbund = gv_vbund
      AND gjahr = lt_zfgscab_dtl-gjahr.
  "      AND exp_type = lt_zfgscab_dtl-exp_sub_grp(20).  "exp_type.


  "Get ZFGSCAB_MAP2
  lt_zfgscab_dtl[] = gt_zfgscab_dtl[].
  SORT lt_zfgscab_dtl BY cust_sub_grp.
  DELETE ADJACENT DUPLICATES FROM lt_zfgscab_dtl
    COMPARING cust_sub_grp.
  SELECT * INTO TABLE gt_zfgscab_map2
    FROM zfgscab_map2 FOR ALL ENTRIES IN lt_zfgscab_dtl
    WHERE cust_sub_grp = lt_zfgscab_dtl-cust_sub_grp.
ENDFORM.                    " F_GET_ZFGSCAB_MAP

*&---------------------------------------------------------------------*
*&      Form  F_GET_MARC
*&---------------------------------------------------------------------*
FORM f_get_marc .
  DATA: BEGIN OF lt_zfgscab_dtl OCCURS 0.
          INCLUDE STRUCTURE zfgscab_dtl.
          DATA:   werks TYPE werks_d,
        END OF lt_zfgscab_dtl.

  DATA : ls_marc     LIKE LINE OF gt_marc,
         ls_zfiprctr LIKE LINE OF gt_zfiprctr.

  LOOP AT gt_zfgscab_dtl.
    MOVE-CORRESPONDING gt_zfgscab_dtl TO lt_zfgscab_dtl.
    CONCATENATE lt_zfgscab_dtl-bukrs+1(3) '0' INTO lt_zfgscab_dtl-werks.
    APPEND lt_zfgscab_dtl.
  ENDLOOP.

  "Get marc
  DATA(lv_werks) = |{ p_bukrs+1(3) }| & |%|.
  SORT lt_zfgscab_dtl BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_zfgscab_dtl
    COMPARING matnr. "werks.
  SELECT matnr werks prctr
    INTO CORRESPONDING FIELDS OF TABLE gt_marc
    FROM marc FOR ALL ENTRIES IN lt_zfgscab_dtl
    WHERE matnr = lt_zfgscab_dtl-matnr
*      AND werks = lv_werks.   "lt_zfgscab_dtl-werks.
      AND werks LIKE lv_werks
      AND prctr NE 'DUMMY'.

  IF gt_marc[] IS NOT INITIAL.
    LOOP AT gt_marc INTO ls_marc.
      CLEAR ls_zfiprctr.
      READ TABLE gt_zfiprctr INTO ls_zfiprctr
                             WITH KEY prctr = ls_marc-prctr.
      IF sy-subrc = 0.
        ls_marc-prctr = ls_zfiprctr-prctr1.
        MODIFY gt_marc FROM ls_marc
                       TRANSPORTING prctr.
      ENDIF.
    ENDLOOP.

    SELECT *
      FROM cepct
      INTO CORRESPONDING FIELDS OF TABLE gt_cepct
      FOR ALL ENTRIES IN gt_marc
      WHERE spras = sy-langu
        AND prctr = gt_marc-prctr
        AND datbi >= sy-datum
        AND kokrs = '8010'.
  ENDIF.
  "Get makt
  DELETE ADJACENT DUPLICATES FROM lt_zfgscab_dtl
    COMPARING matnr.
  SELECT matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_makt
    FROM makt FOR ALL ENTRIES IN lt_zfgscab_dtl
    WHERE matnr = lt_zfgscab_dtl-matnr
      AND spras = sy-langu.
ENDFORM.                    " F_GET_MARC

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_GL_ITEM
*&---------------------------------------------------------------------*
FORM f_append_gl_item  TABLES   ft_accgl STRUCTURE bapiacgl09
                                ft_ext   STRUCTURE bapiacextc
                                ft_curr  STRUCTURE bapiaccr09
                       USING    fu_hdr   TYPE ty_hdr
                                fu_itm   TYPE ty_itm
                                fu_exp_type
                                fu_buzei.
  DATA: ls_accgl TYPE bapiacgl09,
        ls_ext   TYPE bapiacextc,
        ls_curr  TYPE bapiaccr09.
  DATA: lv_pph       LIKE fu_hdr-pph,
        lv_perfr(10),
        lv_perto(10),
        lv_str1      TYPE string,
        lv_str2      TYPE string.

  IF fu_exp_type IS INITIAL.
    "accountgl
    ADD 1 TO fu_buzei.
    ls_accgl-itemno_acc   = fu_buzei.
    ls_accgl-gl_account   = fu_itm-hkont.

*    ls_accgl-alloc_nmbr   = fu_hdr-xref2.
    lv_str1 = fu_hdr-xref2.
    SPLIT lv_str1 AT '/' INTO lv_str1 lv_str2.
    CONCATENATE lv_str1 'MT' lv_str2 INTO ls_accgl-alloc_nmbr
    SEPARATED BY '/'.

*    IF p_bukrs NE '8180'.
    ls_accgl-profit_ctr   = fu_itm-prctr.
    ls_accgl-material     = fu_itm-matnr.
*    ENDIF.

    CONCATENATE fu_hdr-bukrs+1(3) '0' INTO ls_accgl-bus_area.
*    CONCATENATE 'C' fu_itm-prctr+4(6) fu_itm-aufnr+7(5)
*      INTO ls_accgl-orderid.
    ls_accgl-orderid = fu_itm-aufnr.
    WRITE fu_hdr-perfr TO lv_perfr DD/MM/YYYY.
    WRITE fu_hdr-perto TO lv_perto DD/MM/YYYY.
    CONCATENATE lv_perfr lv_perto fu_hdr-sgtxt fu_itm-cust_sub_grp fu_itm-exp_sub_grp
    INTO ls_accgl-item_text
    SEPARATED BY space.
    APPEND ls_accgl TO ft_accgl.

    "extension1
    ls_ext(3)                = fu_buzei.
    ls_ext+3(2)              = '40'.
    APPEND ls_ext TO ft_ext.

    "currencyamount
    ls_curr-itemno_acc    = fu_buzei.
    ls_curr-curr_type     = '00'.
    ls_curr-currency      = fu_itm-currency.
    ls_curr-amt_doccur    = fu_itm-amount * 100.
    APPEND ls_curr TO ft_curr.
  ELSE.
*    CASE  fu_exp_type.
*      WHEN 'FIXED REBATE'.
*        "accountgl #1
*        ADD 1 TO fu_buzei.
*        ls_accgl-itemno_acc   = fu_buzei.
*        ls_accgl-gl_account   = '0122373000'.
*        ls_accgl-alloc_nmbr   = fu_hdr-xref2.
*        IF p_bukrs NE '8180'.
*          ls_accgl-profit_ctr   = fu_itm-prctr.
*        ENDIF.
*        CONCATENATE fu_hdr-bukrs+1(3) '0' INTO ls_accgl-bus_area.
*        APPEND ls_accgl TO ft_accgl.
*
*        "extension1 #1
*        ls_ext(3)             = fu_buzei.
*        ls_ext+3(2)           = '40'.
*        APPEND ls_ext TO ft_ext.
*
*        "currencyamount #1
*        ls_curr-itemno_acc    = fu_buzei.
*        ls_curr-curr_type     = '00'.
*        ls_curr-currency      = fu_itm-currency.
*        lv_pph = fu_hdr-pph * 100.
*        ls_curr-amt_doccur    = lv_pph.
*        APPEND ls_curr TO ft_curr.
*
*        "accountgl #2
*        ADD 1 TO fu_buzei.
*        ls_accgl-itemno_acc   = fu_buzei.
*        ls_accgl-gl_account   = '0315100040'.
*        ls_accgl-alloc_nmbr   = fu_hdr-xref2.
*        IF p_bukrs NE '8180'.
*          ls_accgl-profit_ctr   = fu_itm-prctr.
*        ENDIF.
*        CONCATENATE fu_hdr-bukrs+1(3) '0' INTO ls_accgl-bus_area.
*        APPEND ls_accgl TO ft_accgl.
*
*        "extension1 #1
*        ls_ext(3)             = fu_buzei.
*        ls_ext+3(2)           = '50'.
*        APPEND ls_ext TO ft_ext.
*
*        "currencyamount #1
*        ls_curr-itemno_acc    = fu_buzei.
*        ls_curr-curr_type     = '00'.
*        ls_curr-currency      = fu_itm-currency.
*        ls_curr-amt_doccur    = lv_pph * -1.
*        APPEND ls_curr TO ft_curr.
*
*      WHEN 'CONDITIONAL REBATE'.
    IF p_bukrs = '8180' OR
      p_bukrs = '8010'.
      ADD 1 TO fu_buzei.
      ls_accgl-itemno_acc   = fu_buzei.
      ls_accgl-gl_account   = p_hkont.  "'0315100040'.

*      ls_accgl-alloc_nmbr   = fu_hdr-xref2.
      lv_str1 = fu_hdr-xref2.
      SPLIT lv_str1 AT '/' INTO lv_str1 lv_str2.
      CONCATENATE lv_str1 'MT' lv_str2 INTO ls_accgl-alloc_nmbr
      SEPARATED BY '/'.

      IF p_bukrs NE '8180' AND
        p_bukrs NE '8010'.
        ls_accgl-profit_ctr   = fu_itm-prctr.
      ENDIF.
      CONCATENATE fu_hdr-bukrs+1(3) '0' INTO ls_accgl-bus_area.
      WRITE fu_hdr-perfr TO lv_perfr DD/MM/YYYY.
      WRITE fu_hdr-perto TO lv_perto DD/MM/YYYY.
      CONCATENATE lv_perfr lv_perto fu_hdr-sgtxt fu_itm-cust_sub_grp fu_itm-exp_sub_grp
      INTO ls_accgl-item_text
      SEPARATED BY space.
      APPEND ls_accgl TO ft_accgl.

      "extension1 #1
      ls_ext(3)             = fu_buzei.
      ls_ext+3(2)           = '50'.
      APPEND ls_ext TO ft_ext.

      "currencyamount #1
      ls_curr-itemno_acc    = fu_buzei.
      ls_curr-curr_type     = '00'.
      ls_curr-currency      = fu_itm-currency.
      ls_curr-amt_doccur    = fu_hdr-pph * -100.
      APPEND ls_curr TO ft_curr.

      IF fu_hdr-ppn <> 0.
        CLEAR gt_zfgscab_hdr.
        READ TABLE gt_zfgscab_hdr WITH KEY xref2 = fu_hdr-xref2.

        ADD 1 TO fu_buzei.
        ls_accgl-itemno_acc   = fu_buzei.
        CASE p_bukrs.
          WHEN '8010'.
            ls_accgl-gl_account   = '0142200220'.
*            ls_accgl-profit_ctr   = fu_itm-prctr.
*            ls_accgl-item_text    = fu_hdr-xref2.
            lv_str1 = fu_hdr-xref2.
            SPLIT lv_str1 AT '/' INTO lv_str1 lv_str2.
            CONCATENATE lv_str1 'MT' lv_str2 INTO ls_accgl-item_text
            SEPARATED BY '/'.

            ls_accgl-alloc_nmbr   = gt_zfgscab_hdr-vatno.

          WHEN '8180'.
            ls_accgl-gl_account   = '0142200210'.
*            ls_accgl-item_text    = fu_hdr-xref2.
            lv_str1 = fu_hdr-xref2.
            SPLIT lv_str1 AT '/' INTO lv_str1 lv_str2.
            CONCATENATE lv_str1 'MT' lv_str2 INTO ls_accgl-item_text
            SEPARATED BY '/'.

            ls_accgl-alloc_nmbr   = gt_zfgscab_hdr-vatno.
        ENDCASE.
        CONCATENATE fu_hdr-bukrs+1(3) '0' INTO ls_accgl-bus_area.
        APPEND ls_accgl TO ft_accgl.

        "extension1 #1
        ls_ext(3)             = fu_buzei.
        ls_ext+3(2)           = '40'.
        APPEND ls_ext TO ft_ext.

        "currencyamount #1
        ls_curr-itemno_acc    = fu_buzei.
        ls_curr-curr_type     = '00'.
        ls_curr-currency      = fu_itm-currency.
        ls_curr-amt_doccur    = fu_hdr-ppn * 100.
        APPEND ls_curr TO ft_curr.
      ENDIF.
    ENDIF.
*    ENDCASE.
  ENDIF.
ENDFORM.                    " F_APPEND_GL_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_GL_ITEM_SUSPEND
*&---------------------------------------------------------------------*
FORM f_append_gl_item_suspend  TABLES   ft_accgl STRUCTURE bapiacgl09
                                        ft_ext   STRUCTURE bapiacextc
                                        ft_curr  STRUCTURE bapiaccr09
                               USING    fu_hdr   TYPE ty_hdr
                                        fu_itm   TYPE ty_itm
                                        fu_exp_type
                                        fu_buzei.
  DATA: ls_accgl TYPE bapiacgl09,
        ls_ext   TYPE bapiacextc,
        ls_curr  TYPE bapiaccr09.
  DATA: lv_pph       LIKE fu_hdr-pph,
        lv_perfr(10),
        lv_perto(10),
        lv_str1      TYPE string,
        lv_str2      TYPE string.

  "accountgl
  ADD 1 TO fu_buzei.
  ls_accgl-itemno_acc   = fu_buzei.

  CASE p_bukrs.
    WHEN '8010'.
      ls_accgl-gl_account = '0122373000'.
    WHEN '8180'.
      ls_accgl-gl_account = '0122371100'.
    WHEN OTHERS.
      ls_accgl-gl_account = fu_itm-hkont.
  ENDCASE.

  lv_str1 = fu_hdr-xref2.
  SPLIT lv_str1 AT '/' INTO lv_str1 lv_str2.
  CONCATENATE lv_str1 'MT' lv_str2 INTO ls_accgl-alloc_nmbr
  SEPARATED BY '/'.

*  ls_accgl-profit_ctr   = fu_itm-prctr.

  CONCATENATE fu_hdr-bukrs+1(3) '0' INTO ls_accgl-bus_area.
*    CONCATENATE 'C' fu_itm-prctr+4(6) fu_itm-aufnr+7(5)
*      INTO ls_accgl-orderid.
*  ls_accgl-orderid = fu_itm-aufnr.
  WRITE fu_hdr-perfr TO lv_perfr DD/MM/YYYY.
  WRITE fu_hdr-perto TO lv_perto DD/MM/YYYY.
  CONCATENATE lv_perfr lv_perto fu_hdr-sgtxt fu_itm-cust_sub_grp fu_itm-exp_sub_grp
  INTO ls_accgl-item_text
  SEPARATED BY space.
  APPEND ls_accgl TO ft_accgl.

  "extension1
  ls_ext(3)                = fu_buzei.
  ls_ext+3(2)              = '40'.
  APPEND ls_ext TO ft_ext.

  "currencyamount
  ls_curr-itemno_acc    = fu_buzei.
  ls_curr-curr_type     = '00'.
  ls_curr-currency      = fu_itm-currency.
  ls_curr-amt_doccur    = fu_hdr-pph * 100.
  APPEND ls_curr TO ft_curr.
ENDFORM.                    " F_APPEND_GL_ITEM_SUSPEND

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_AP
*&---------------------------------------------------------------------*
FORM f_append_ap  TABLES   ft_ap   STRUCTURE bapiacap09
                           ft_ext  STRUCTURE bapiacextc
                           ft_curr STRUCTURE bapiaccr09
                  USING    fu_hdr  TYPE ty_hdr
                           fu_itm  TYPE ty_itm
                           fu_buzei.
  DATA: ls_ap   TYPE bapiacap09,
        ls_ext  TYPE bapiacextc,
        ls_curr TYPE bapiaccr09.

  DATA: lv_perfr(10),
        lv_perto(10),
        lv_str1      TYPE string,
        lv_str2      TYPE string.

  "accountpayable
  ADD 1 TO fu_buzei.
  ls_ap-itemno_acc       = fu_buzei.
  ls_ap-vendor_no        = gc_lifnr.
  ls_ap-pmnttrms         = gs_lfb1-zterm.

*  ls_ap-alloc_nmbr       = fu_hdr-xref2.
  lv_str1 = fu_hdr-xref2.
  SPLIT lv_str1 AT '/' INTO lv_str1 lv_str2.
  CONCATENATE lv_str1 'MT' lv_str2 INTO ls_ap-alloc_nmbr
  SEPARATED BY '/'.

  ls_ap-bline_date       = fu_hdr-tglpost.
  CONCATENATE fu_hdr-bukrs+1(3) '0' INTO ls_ap-bus_area.

  WRITE fu_hdr-perfr TO lv_perfr DD/MM/YYYY.
  WRITE fu_hdr-perto TO lv_perto DD/MM/YYYY.
  CONCATENATE lv_perfr lv_perto fu_hdr-sgtxt fu_itm-cust_sub_grp fu_itm-exp_sub_grp
  INTO ls_ap-item_text
  SEPARATED BY space.

*  CONCATENATE fu_hdr-xref2 fu_itm-exp_type fu_itm-cust_sub_grp
*    INTO ls_ap-item_text SEPARATED BY ','.
  APPEND ls_ap TO ft_ap.

  ls_ext(3)                = fu_buzei.
  ls_ext+3(2)              = '31'.
  APPEND ls_ext TO ft_ext.

  ls_curr-itemno_acc    = fu_buzei.
  ls_curr-curr_type     = '00'.
  ls_curr-currency      = fu_hdr-waers.

  IF p_bukrs = '8180' OR
    p_bukrs = '8010'.
    IF p_susacc = 'X'.
      ls_curr-amt_doccur    = ( fu_hdr-amount + fu_hdr-ppn ) * -100.
    ELSE.
      ls_curr-amt_doccur    = ( ( fu_hdr-amount - fu_hdr-pph ) + fu_hdr-ppn ) * -100.
    ENDIF.
  ELSE.
    ls_curr-amt_doccur    = fu_hdr-amount * -100.
  ENDIF.
  APPEND ls_curr TO ft_curr.
ENDFORM.                    " F_APPEND_AP

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TABLE
*&---------------------------------------------------------------------*
FORM f_update_table .
  DATA: lt_zfgscab_dtl TYPE TABLE OF zfgscab_dtl WITH HEADER LINE.

  LOOP AT gt_hdr ASSIGNING <fs_hdr>
                 WHERE fi_posting IS NOT INITIAL.
    UPDATE zfgscab_dtl SET fi_posting   = <fs_hdr>-fi_posting
                           posting_date = <fs_hdr>-posting_date
                       WHERE bukrs = <fs_hdr>-bukrs_dtl
                         AND gjahr = <fs_hdr>-gjahr_dtl
                         AND xref2 = <fs_hdr>-xref2.
  ENDLOOP.
ENDFORM.                    " F_UPDATE_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARIES_ITEM
*&---------------------------------------------------------------------*
FORM f_summaries_item .
  DATA: lt_itm TYPE TABLE OF ty_itm WITH HEADER LINE.

  LOOP AT gt_itm INTO DATA(ls_itm).
    MOVE-CORRESPONDING ls_itm TO lt_itm.
    CLEAR: lt_itm-matnr,lt_itm-maktx,lt_itm-nm_break.
    COLLECT lt_itm.
  ENDLOOP.

  IF lt_itm[] IS NOT INITIAL.
    gt_itm[] = lt_itm[].
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACC_PPH
*&---------------------------------------------------------------------*
FORM f_get_acc_pph  CHANGING fc_hkont.
  DATA lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  SELECT * INTO TABLE @DATA(lt_hkont)
    FROM zfgscab_accpph WHERE bukrs = @p_bukrs.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield   = 'HKONT'   "field of internal table
      value_org  = 'S'
    TABLES
      value_tab  = lt_hkont
      return_tab = lt_return[].
  READ TABLE lt_return INDEX 1.
  WRITE lt_return-fieldval TO fc_hkont.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_3
*&---------------------------------------------------------------------*
FORM f_process_3 .
  SELECT bukrs, gjahr, xref2, a~matnr, maktx, exp_type, exp_sub_grp, cust_grp,
         cust_sub_grp, nm_break, amount, currency, zflag, fi_posting, posting_date
    INTO TABLE @DATA(lt_dtl)
    FROM zfgscab_dtl AS a JOIN makt AS b ON b~matnr = a~matnr
    WHERE bukrs = @p_bukrs
      AND gjahr = @p_gjahr
      AND xref2 IN @s_xref2.

  IF sy-subrc NE 0.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  TRY.
      "Create ALV table object for the output data table
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_tab)
                              CHANGING  t_table      = lt_dtl ).
      lo_tab->get_functions( )->set_all( ).
      lo_tab->get_columns( )->set_optimize( ).
      lo_tab->get_display_settings( )->set_striped_pattern( abap_true ).

      DATA(lo_columns) = lo_tab->get_columns( ).

      DATA(lo_column) = lo_columns->get_column( 'EXP_TYPE' ).
      lo_column->set_long_text( 'Expand Type').
      lo_column->set_medium_text( 'Expand Type' ).
      lo_column->set_short_text( 'ExpandType' ).

      lo_column = lo_columns->get_column( 'EXP_SUB_GRP' ).
      lo_column->set_long_text( 'Expand Sub Group').
      lo_column->set_medium_text( 'Expand Sub Group' ).
      lo_column->set_short_text( 'ExpandSGrp' ).

      lo_column = lo_columns->get_column( 'CUST_GRP' ).
      lo_column->set_long_text( 'Customer Group').
      lo_column->set_medium_text( 'Customer Group' ).
      lo_column->set_short_text( 'CustomerGr' ).

      lo_column = lo_columns->get_column( 'CUST_SUB_GRP' ).
      lo_column->set_long_text( 'Customer Sub Group').
      lo_column->set_medium_text( 'Customer Sub Group' ).
      lo_column->set_short_text( 'CustomerSG' ).

      lo_column = lo_columns->get_column( 'NM_BREAK' ).
      lo_column->set_long_text( 'Nm break').
      lo_column->set_medium_text( 'Nm break' ).
      lo_column->set_short_text( 'Nm break' ).

      lo_tab->display( ).

    CATCH cx_root.
      MESSAGE 'Error in ALV creation' TYPE 'E'.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_FILTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SELECTIONS  text
*----------------------------------------------------------------------*
FORM f_selection_filter  TABLES   p_selections STRUCTURE vimsellist.
  DATA: selection TYPE vimsellist.
  IF p_bukrs IS NOT INITIAL.
    selection-viewfield = 'VBUND'.
    selection-value = p_bukrs.
    selection-and_or = 'AND'.
    selection-operator = 'EQ'.
    APPEND selection TO p_selections.
  ENDIF.
  IF p_gjahr IS NOT INITIAL.
    selection-viewfield = 'GJAHR'.
    selection-value = p_gjahr.
    selection-and_or = 'AND'.
    selection-operator = 'EQ'.
    APPEND selection TO p_selections.
  ENDIF.
  IF s_esg[] IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'EXP_SUB_GRP'
        append_conjunction = 'AND'
      TABLES
        sellist            = selections
        rangetab           = s_esg[].
  ENDIF.
  IF s_hkont[] IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'HKONT'
        append_conjunction = 'AND'
      TABLES
        sellist            = selections
        rangetab           = s_hkont[].
  ENDIF.
  IF s_wwsec[] IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'WWSEC'
        append_conjunction = 'AND'
      TABLES
        sellist            = selections
        rangetab           = s_wwsec[].
  ENDIF.
  IF s_wwtrz[] IS NOT INITIAL.
    CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
      EXPORTING
        fieldname          = 'WWTRZ'
        append_conjunction = 'AND'
      TABLES
        sellist            = selections
        rangetab           = s_wwtrz[].

  ENDIF.


ENDFORM.

FORM f_get_data_new.
  DATA: vbund_data TYPE zfgscab_map1-vbund.
  CONCATENATE '00' p_bukrs INTO vbund_data.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_map1
    FROM zfgscab_map1
    WHERE vbund = vbund_data
    AND gjahr = p_gjahr
    AND exp_sub_grp IN s_esg
    AND hkont IN s_hkont
    AND wwsec IN s_wwsec
    AND wwtrz IN s_wwtrz.
ENDFORM.

FORM f_print_data_new.
  DATA: g_repid   TYPE sy-repid.
  g_repid = sy-repid.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
  CLEAR: lt_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZFGSCAB_MAP1_STRUCT'
    CHANGING
      ct_fieldcat      = lt_fieldcat.

  LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
    CASE <fs_fieldcat>-fieldname.
      WHEN 'CHECK'.
        <fs_fieldcat>-seltext_s = 'Check'.
        <fs_fieldcat>-seltext_m = 'Check'.
        <fs_fieldcat>-seltext_l = 'Check'.
        <fs_fieldcat>-reptext_ddic = 'Check'.
        <fs_fieldcat>-checkbox = 'X'.
        <fs_fieldcat>-input = 'X'.
        <fs_fieldcat>-edit = 'X'.
        <fs_fieldcat>-outputlen = '3'.
      WHEN 'VBUND'.
        <fs_fieldcat>-seltext_s = 'Company Code'.
        <fs_fieldcat>-seltext_m = 'Company Code'.
        <fs_fieldcat>-seltext_l = 'Company Code'.
        <fs_fieldcat>-reptext_ddic = 'Company Code'.
      WHEN 'GJAHR'.
        <fs_fieldcat>-seltext_s = 'Year'.
        <fs_fieldcat>-seltext_m = 'Year'.
        <fs_fieldcat>-seltext_l = 'Year'.
        <fs_fieldcat>-reptext_ddic = 'Year'.
      WHEN 'EXP_SUB_GRP'.
        <fs_fieldcat>-seltext_s = 'Expend Sub Group'.
        <fs_fieldcat>-seltext_m = 'Expend Sub Group'.
        <fs_fieldcat>-seltext_l = 'Expend Sub Group'.
        <fs_fieldcat>-reptext_ddic = 'Expend Sub Group'.
      WHEN 'HKONT'.
        <fs_fieldcat>-seltext_s = 'G/L Account'.
        <fs_fieldcat>-seltext_m = 'G/L Account'.
        <fs_fieldcat>-seltext_l = 'G/L Account'.
        <fs_fieldcat>-reptext_ddic = 'G/L Account'.
      WHEN 'WWSEC'.
        <fs_fieldcat>-seltext_s = 'Support Exp Category'.
        <fs_fieldcat>-seltext_m = 'Support Exp Category'.
        <fs_fieldcat>-seltext_l = 'Support Exp Category'.
        <fs_fieldcat>-reptext_ddic = 'Support Exp Category'.
      WHEN 'WWTRZ'.
        <fs_fieldcat>-seltext_s = 'Key Account'.
        <fs_fieldcat>-seltext_m = 'Key Account'.
        <fs_fieldcat>-seltext_l = 'Key Account'.
        <fs_fieldcat>-reptext_ddic = 'Key Account'.
      WHEN 'AUFNR'.
        <fs_fieldcat>-seltext_s = 'Order'.
        <fs_fieldcat>-seltext_m = 'Order'.
        <fs_fieldcat>-seltext_l = 'Order'.
        <fs_fieldcat>-reptext_ddic = 'Order'.
*        <fs_fieldcat>-outputlen = '10'.
      WHEN 'MESSAGE'.
        <fs_fieldcat>-seltext_s = 'Message'.
        <fs_fieldcat>-seltext_m = 'Message'.
        <fs_fieldcat>-seltext_l = 'Message'.
        <fs_fieldcat>-reptext_ddic = 'Message'.
        <fs_fieldcat>-outputlen = '50'.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
*     i_callback_top_of_page   = 'TOP-OF-PAGE'
      it_fieldcat              = lt_fieldcat
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_default                = 'X'
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_map1.



ENDFORM.

FORM top-of-page.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4422   text
*----------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  IF radio4 = 'X'.
    LOOP AT gt_map1 INTO gs_map1.
      gs_map1-check = fu_check.
      MODIFY gt_map1 FROM gs_map1.
    ENDLOOP.
  ENDIF.
ENDFORM.
