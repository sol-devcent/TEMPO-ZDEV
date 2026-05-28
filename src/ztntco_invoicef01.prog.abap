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
        PERFORM f_proses_faktur_pajak.
        PERFORM f_print.

        SORT gt_hdr BY bukrs gjahr invno.
        gr_selections->set_selection_mode( cl_salv_selections=>if_salv_c_selection_mode~none ).
        gt_hierseq->refresh( ).
*          LEAVE TO SCREEN 0.

      WHEN 'CANCEL'.
        PERFORM f_reverse_invoice.

        SORT gt_hdr BY bukrs gjahr invno.
        gr_selections->set_selection_mode( cl_salv_selections=>if_salv_c_selection_mode~none ).
        gt_hierseq->refresh( ).

      WHEN 'RPRNT'.
        PERFORM f_reprint.
        gt_hierseq->refresh( ).
    ENDCASE.
  ENDMETHOD.                    "on_user_command

ENDCLASS.               "LCL_HANDLE_EVENTS
*----------------------------------------------------------------------*


**---------------------------------------------------------------------*
**       CLASS lcl_event_handler DEFINITION
**---------------------------------------------------------------------*
*CLASS lcl_event_handler DEFINITION .
*  PUBLIC SECTION .
*    METHODS:
***Handle data changed
*    handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
*                        IMPORTING er_data_changed,
***Hot spot Handler
*    handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
*                         IMPORTING e_row_id e_column_id es_row_no,
***Double Click Handler
*    handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
*                        IMPORTING e_row e_column es_row_no,
***Top Of Page
*    top_of_page FOR EVENT top_of_page OF cl_gui_alv_grid
*                IMPORTING e_dyndoc_id,
***Handle Toolbar
*    handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
*                   IMPORTING e_object e_interactive,
*
***Handle User Command
*     handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
*       IMPORTING e_ucomm.
*ENDCLASS.                    "lcl_event_handler DEFINITION
*
**---------------------------------------------------------------------*
**       CLASS lcl_event_handler IMPLEMENTATION
**---------------------------------------------------------------------*
*CLASS lcl_event_handler IMPLEMENTATION.
*  METHOD handle_data_changed.
*    DATA: ls_good         TYPE lvc_s_modi.
*
*    FIELD-SYMBOLS: <fs_detail> TYPE zfist001.
*
**    CASE 'X'.
**      WHEN r4.
**        LOOP AT er_data_changed->mt_good_cells INTO ls_good.
**          CLEAR: lv_ratetyp_act,lv_timln.
**          CALL METHOD er_data_changed->get_cell_value
**            EXPORTING
**              i_row_id    = ls_good-row_id
**              i_fieldname = 'RATETYP_ACT'
**            IMPORTING
**              e_value     = lv_ratetyp_act.
**          CALL METHOD er_data_changed->get_cell_value
**            EXPORTING
**              i_row_id    = ls_good-row_id
**              i_fieldname = 'TIMLN'
**            IMPORTING
**              e_value     = lv_timln.
**
*** Change Tarif Act
**          IF lv_ratetyp_act IS NOT INITIAL OR
**             lv_timln IS NOT INITIAL.
**            READ TABLE gt_out2 ASSIGNING <fs_out2>
**                               INDEX ls_good-row_id.
**
**            <fs_out2>-ratetyp_act = lv_ratetyp_act.
**            <fs_out2>-timln       = lv_timln.
**
**            CLEAR gt_zratetr001.
**            READ TABLE gt_zratetr001 INTO ls_zratetr001
**                                     WITH KEY bukrs   = <fs_out2>-bukrs
**                                              gjahr   = <fs_out2>-gjahr
**                                              revtyp  = <fs_out2>-revtyp
**                                              ratetyp = <fs_out2>-ratetyp_act.
**
**            IF <fs_out2>-linno(2) = 'CC'.
**              <fs_out2>-tarif_act = ls_zratetr001-tarifcc / 100.
**            ELSE.
**              <fs_out2>-tarif_act = ls_zratetr001-tarifphm / 100.
**            ENDIF.
**            <fs_out2>-amount_act  = <fs_out2>-tarif_act * <fs_out2>-zqty.
**
*** Change Net Amount
**            <fs_out2>-net_amount = <fs_out2>-amount_act * <fs_out2>-timln / 100.
**          ENDIF.
**        ENDLOOP.
**
**      WHEN r5.
**        LOOP AT er_data_changed->mt_good_cells INTO ls_good.
**          CLEAR: lv_ratetyp_act,lv_timln.
**          CALL METHOD er_data_changed->get_cell_value
**            EXPORTING
**              i_row_id    = ls_good-row_id
**              i_fieldname = 'FACTOR'
**            IMPORTING
**              e_value     = lv_factor.
**
**          IF lv_factor IS NOT INITIAL.
**            READ TABLE gt_out4 ASSIGNING <fs_out4>
**                               INDEX ls_good-row_id.
**
**            <fs_out4>-factor = lv_factor.
**
**            CLEAR gt_zaloktr01sum.
**            READ TABLE gt_zaloktr01sum INTO ls_zaloktr01sum
**                                       WITH KEY bukrs = <fs_out4>-bukrs
**                                                gjahr = <fs_out4>-gjahr
**                                                revtyp = <fs_out4>-revtyp
**                                                zgrp  = <fs_out4>-zgrp
**                                                zsgrp = <fs_out4>-zsgrp.
**            <fs_out4>-amount = <fs_out4>-net_amount * <fs_out4>-factor / ls_zaloktr01sum-factor.
**          ENDIF.
**        ENDLOOP.
**
**      WHEN OTHERS.
**    ENDCASE.
*
*    IF er_data_changed->mt_good_cells[] IS NOT INITIAL.
*      CALL METHOD g_grid->refresh_table_display( ).
*    ENDIF.
*
*  ENDMETHOD.                    "on_data_changed
*
**Handle Hotspot Click
*  METHOD handle_hotspot_click .
*    CLEAR: gv_row,gv_column,gv_row_num.
*    gv_row  = e_row_id.
*    gv_column = e_column_id.
*    gv_row_num = es_row_no.
*
**    IF gv_column = 'LOGNO'.
**      READ TABLE gt_out INTO gw_out
**                        INDEX gv_row_num-row_id.
**      IF gw_out-logno IS NOT INITIAL.
**        CALL SCREEN 200 STARTING AT 10 10 ENDING AT 150 22.
**      ENDIF.
**    ENDIF.
*  ENDMETHOD.                    "lcl_event_handler
*
**Handle Double Click
*  METHOD  handle_double_click.
*
*  ENDMETHOD.                    "handle_double_click
*
*  METHOD top_of_page.                   "implementation
** Top-of-page event
*    PERFORM event_top_of_page USING dg_dyndoc_id.
*  ENDMETHOD.                            "top_of_page
*
**Handle Toolbar
*  METHOD  handle_toolbar.
*    DATA: lw_toolbar TYPE stb_button,
*          lv_text    TYPE char30.
*
*    CASE 'X'.
*      WHEN r1.
*        lv_text = 'Create Invoice'.
*      WHEN r2.
*        lv_text = 'Reprint Invoice'.
*      WHEN r3.
*        lv_text = 'Reverse Invoice'.
*    ENDCASE.
*
*    IF r1 = 'X' OR r2 = 'X' OR r3 = 'X'.
*      CLEAR lw_toolbar.
*      MOVE 0 TO lw_toolbar-butn_type.
*      APPEND lw_toolbar TO e_object->mt_toolbar.
*      CLEAR lw_toolbar.
*      MOVE 'EXEC'              TO lw_toolbar-function.
*      MOVE icon_execute_object TO lw_toolbar-icon.
**      MOVE text-005            TO lw_toolbar-quickinfo.
**      MOVE text-005            TO lw_toolbar-text.
*      MOVE lv_text            TO lw_toolbar-quickinfo.
*      MOVE lv_text            TO lw_toolbar-text.
*      MOVE ' '                 TO lw_toolbar-disabled.
*      APPEND lw_toolbar TO e_object->mt_toolbar.
*    ENDIF.
*  ENDMETHOD.                    "handle_toolbar
*
*  METHOD handle_user_command.                   "implementation
*    CASE e_ucomm.
*      WHEN 'EXEC'.
*        CASE 'X'.
*          WHEN r1.
*            LEAVE TO SCREEN 0.
*          WHEN r2.
*            LEAVE TO SCREEN 0.
*          WHEN r3.
*            LEAVE TO SCREEN 0.
*          WHEN r4.
*            PERFORM f_cetak_form.
*        ENDCASE.
**        PERFORM f_get_selected_rows.
**        PERFORM f_posting_document_fi.
**        CALL METHOD g_grid->refresh_table_display.
*    ENDCASE.
*  ENDMETHOD.                            "handle_user_command
*ENDCLASS.                    "LCL_EVENT_HANDLER IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  gv_repid = sy-repid.

  IF r4 = 'X'.
    CLEAR gv_chkbx.
  ELSE.
    gv_chkbx = 'X'.
  ENDIF.

  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF gs_dpp
      WHERE name = 'DPP12'.

  PERFORM f_coretax_validate.

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
*  PERFORM f_alv.
  PERFORM f_alv2 TABLES gt_hdr gt_itm.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory .
  CLEAR gt_upload.
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'RA5'.
        screen-active = '0'.
        MODIFY SCREEN.
      WHEN 'GRY'.
        screen-input = '0'.
        MODIFY SCREEN.
      WHEN 'NDS'.
        screen-active = '0'.
        MODIFY SCREEN.
      WHEN 'LIN'.
        IF r1 = 'X' OR r2 = 'X' OR r3 = 'X' OR r4 = 'X' OR r5 = 'X'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'DAT'.
        IF r1 = 'X' OR r2 = 'X' OR r3 = 'X' OR r5 = 'X'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'INV'.
        IF r3 = 'X'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'IN3'.
        IF r1 = 'X' OR r2 = 'X' OR r5 = 'X'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF p_bukrs IS INITIAL.
    MESSAGE 'Please input Company Code' TYPE 'I'.
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
*&      Form  F_INSERT_LOG_ITAB
*&---------------------------------------------------------------------*
FORM f_insert_log_itab  USING    fu_upload STRUCTURE ztdnsdst004
                                 fu_text.
  MOVE-CORRESPONDING fu_upload TO gt_outlog.

  CLEAR gt_outlog-vcr_encrp.
  gt_outlog-vcr_encrp = fu_text.

  CLEAR: gt_outlog-vcrexp.
  CONCATENATE fu_upload-vcrexp+6(4) fu_upload-vcrexp+3(2) fu_upload-vcrexp(2)
    INTO gt_outlog-vcrexp.

  APPEND gt_outlog.
ENDFORM.                    " F_INSERT_LOG_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_CETAK_FORM
*&---------------------------------------------------------------------*
FORM f_cetak_form .
*  DATA: lt_row    TYPE lvc_t_row,
*        lt_roid   TYPE lvc_t_roid,
*        ls_roid   TYPE lvc_s_roid,
*        lv_lines  TYPE i,
*        lv_subrc  LIKE sy-subrc.
*
*  DATA: lt_out2   TYPE TABLE OF zrevtr001 WITH HEADER LINE.
*
*  lt_out2[] = gt_out2[].
*  DELETE lt_out2 WHERE zflg = space.
*
*  IF lt_out2[] IS NOT INITIAL.
*    IF r8 = 'X'.
*      PERFORM f_prepare_selection_screen TABLES lt_out2.
*    ENDIF.
*
*    CALL SELECTION-SCREEN 212 STARTING AT 30 5
*                              ENDING AT 150 20.
*
*    IF sy-subrc = 0.
*      PERFORM f_prepare_print2 TABLES lt_out2.
**      PERFORM f_print_form.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_CETAK_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT
*&---------------------------------------------------------------------*
FORM f_prepare_print TABLES ft_roid.
*  DATA: ls_roid       TYPE lvc_s_roid,
*        lv_qty        TYPE zquan,
*        lv_amount     TYPE dmbtr,
*        lv_net_amount TYPE dmbtr,
*        lv_waerk      TYPE waerk.
*
*  READ TABLE ft_roid INTO ls_roid INDEX 1.
*
*  CLEAR: gs_header,gs_detail,gt_detail[],gt_zrevtr001_upd,gt_zrevtr001_upd[].
*
*  "Prepare data update
*  UNASSIGN <fs_out2>.
*  READ TABLE gt_out2 ASSIGNING <fs_out2> INDEX ls_roid-row_id.
*  <fs_out2>-invno    = p_invno.
*  <fs_out2>-invdt    = p_invdt.
*  <fs_out2>-kunnr    = p_kunnr.
*  <fs_out2>-name1    = gv_name1.
*  <fs_out2>-invno2   = p_invno2.
*  <fs_out2>-wrk01    = p_wrk01.
*  <fs_out2>-wrk02    = p_wrk02.
*  <fs_out2>-wrk03    = p_wrk03.
*  <fs_out2>-apr01    = p_apr01.
*  <fs_out2>-apr02    = p_apr02.
*  <fs_out2>-apr03    = p_apr03.
*  <fs_out2>-sign01   = p_sign01.
*  <fs_out2>-sign02   = p_sign02.
*  <fs_out2>-sign03   = p_sign03.
*
*  IF <fs_out2>-ratetyp_act IS INITIAL.
*    <fs_out2>-ratetyp_act = <fs_out2>-ratetyp.
*    <fs_out2>-tarif_act   = <fs_out2>-tarif.
*    <fs_out2>-amount_act  = <fs_out2>-amount.
*  ENDIF.
*
*  IF <fs_out2>-timln IS INITIAL.
*    <fs_out2>-timln = 100.
*    <fs_out2>-net_amount = <fs_out2>-amount_act * <fs_out2>-timln / 100.
*  ENDIF.
*
*  "Prepare print header
*  gs_header-bukrs   = <fs_out2>-bukrs.
*  gs_header-invno   = <fs_out2>-invno.
*  gs_header-name1   = gv_name1.
*  gs_header-title   = 'BERITA ACARA PENYELESAIAN PENGERJAAN & PENAGIHAN'.
*  gs_header-invno2  = <fs_out2>-invno2.
*  gs_header-wrk01   = <fs_out2>-wrk01.
*  gs_header-wrk02   = <fs_out2>-wrk02.
*  gs_header-wrk03   = <fs_out2>-wrk03.
*  gs_header-apr01   = <fs_out2>-apr01.
*  gs_header-apr02   = <fs_out2>-apr02.
*  gs_header-apr03   = <fs_out2>-apr03.
*  gs_header-sign01  = <fs_out2>-sign01.
*  gs_header-sign02  = <fs_out2>-sign02.
*  gs_header-sign03  = <fs_out2>-sign03.
*  WRITE <fs_out2>-invdt TO gs_header-tanggal.
**  WRITE <fs_out2>-amount TO gs_header-amount CURRENCY <fs_out2>-waerk.
*  PERFORM f_get_addr_bukrs USING <fs_out2>-bukrs
*                           CHANGING gs_header-butxt
*                                    gs_header-city1
*                                    gs_header-tel_number
*                                    gs_header-fax_number.
*
*  LOOP AT ft_roid INTO ls_roid.
*    UNASSIGN <fs_out2>.
*    READ TABLE gt_out2 ASSIGNING <fs_out2> INDEX ls_roid-row_id.
*
*    <fs_out2>-invno    = p_invno.
*    <fs_out2>-invdt    = p_invdt.
*    <fs_out2>-kunnr    = p_kunnr.
*    <fs_out2>-name1    = gv_name1.
*    <fs_out2>-invno2   = p_invno2.
*    <fs_out2>-wrk01    = p_wrk01.
*    <fs_out2>-wrk02    = p_wrk02.
*    <fs_out2>-wrk03    = p_wrk03.
*    <fs_out2>-apr01    = p_apr01.
*    <fs_out2>-apr02    = p_apr02.
*    <fs_out2>-apr03    = p_apr03.
*    <fs_out2>-sign01   = p_sign01.
*    <fs_out2>-sign02   = p_sign02.
*    <fs_out2>-sign03   = p_sign03.
*
*    gs_detail-bukrs     = <fs_out2>-bukrs.
*    gs_detail-invno     = <fs_out2>-invno.
*    gs_detail-linno     = <fs_out2>-linno.
*    gs_detail-produk    = <fs_out2>-mattx.
*    gs_detail-ket       = <fs_out2>-keterangan.
*    WRITE <fs_out2>-zqty TO gs_detail-zqty DECIMALS 0.
*    WRITE <fs_out2>-tarif_act TO gs_detail-tarif CURRENCY <fs_out2>-waerk.
*    WRITE <fs_out2>-amount_act TO gs_detail-amount CURRENCY <fs_out2>-waerk.
*    WRITE <fs_out2>-timln TO gs_detail-timln DECIMALS 0.
*    WRITE <fs_out2>-net_amount TO gs_detail-net_amount CURRENCY <fs_out2>-waerk.
*
*    lv_waerk = <fs_out2>-waerk.
*    ADD: <fs_out2>-zqty TO lv_qty,
*         <fs_out2>-amount_act TO lv_amount,
*         <fs_out2>-net_amount TO lv_net_amount.
*
**    READ TABLE gt_ztr_revenue_mst WITH KEY revtyp = <fs_out2>-revtyp.
**    gs_detail-pekerjaan = gt_ztr_revenue_mst-revtxt.
**    READ TABLE gt_ztr_rate_mst WITH KEY ratetyp = <fs_out2>-ratetyp.
**    gs_detail-pekerjaan = gt_ztr_rate_mst-ratetxt.
*
*    APPEND gs_detail TO gt_detail. CLEAR gs_detail.
*    APPEND <fs_out2> TO gt_zrevtr001_upd.
*  ENDLOOP.
*
*  WRITE lv_qty TO gs_header-qty DECIMALS 0.
*  WRITE lv_amount TO gs_header-amount CURRENCY lv_waerk.
*  WRITE lv_net_amount TO gs_header-net_amount CURRENCY lv_waerk.
ENDFORM.                    " F_PREPARE_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form USING fu_net fu_waerk.
  DATA: lt_detail TYPE TABLE OF ztntsdstf0001d WITH HEADER LINE,
        ls_header TYPE ztntsdstf0001h,
        lv_tax    TYPE char2.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    PERFORM f_move_header USING fu_net fu_waerk
                          CHANGING ls_header.
    PERFORM f_move_detail TABLES lt_detail.

*      call the generated function module of the form
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        gv_header          = ls_header
        taxrate            = lv_tax
        reprint            = 'X'
        tax                = 'J'
        multi              = ' '
      IMPORTING
        job_output_info    = d_job_output_info
      TABLES
        gt_detail          = lt_detail[].

    IF sy-subrc IS INITIAL.

      CLEAR: gs_header,gt_detail[].
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_GET_TAGIHAN
*&---------------------------------------------------------------------*
FORM f_get_tagihan  USING    fu_zqty
                             fu_tarif
                    CHANGING fc_amount.
  fc_amount = fu_zqty * fu_tarif.
ENDFORM.                    " F_GET_TAGIHAN

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRINTER
*&---------------------------------------------------------------------*
FORM f_get_printer  CHANGING fc_dest.
  DATA: default TYPE bapidefaul,
        return  TYPE STANDARD TABLE OF bapiret2.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = default
    TABLES
      return   = return.

  fc_dest = default-spld.
ENDFORM.                    " F_GET_PRINTER

*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv .
  PERFORM f_relat_tables.

  CALL METHOD cl_salv_hierseq_table=>factory(
    EXPORTING
      t_binding_level1_level2 = gt_binding
    IMPORTING
      r_hierseq               = gt_hierseq
    CHANGING
      t_table_level1          = gt_hdr
      t_table_level2          = gt_itm
  ).

*- Building TOP-OF-PAGE
  PERFORM build_header CHANGING gt_top_content.
  gt_hierseq->set_top_of_list( gt_top_content ).

*- Event for TOP-OF-PAGE
  gt_events = gt_hierseq->get_event( ).
  CREATE OBJECT cl_events.
  SET HANDLER cl_events->top_of_page FOR gt_events.
  SET HANDLER cl_events->on_user_command FOR gt_events.
*  SET HANDLER cl_events->double_click FOR gt_events.

  PERFORM f_change_column_text_level1.
  PERFORM f_change_column_text_level2.
  PERFORM f_get_functions.
ENDFORM.                    " F_ALV


*---------------------------------------------------------------------*
*      Form  BUILD_HEADER
*---------------------------------------------------------------------*
*  Build Header Line for the ALV - Changing the Label of the ALV header
*----------------------------------------------------------------------*
FORM build_header  CHANGING cr_content TYPE REF TO cl_salv_form_element.
  DATA: lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_1 TYPE REF TO cl_salv_form_layout_grid,
        lr_label  TYPE REF TO cl_salv_form_label,
        lr_text   TYPE REF TO cl_salv_form_text,
        l_text    TYPE string,
        lv_title  TYPE char50.

  CREATE OBJECT lr_grid.

  lr_grid->add_row( ).
  lr_grid_1 = lr_grid->create_grid(
  row    = 1
  column = 1 ).
  lr_label = lr_grid_1->create_label(
  row     = 1
  column  = 1
  text    = ' Program:'
  tooltip = 'Program' ).

  lr_text = lr_grid_1->create_text(
  row     = 1
  column  = 2
  text    = sy-repid
  tooltip = sy-repid ).
  lr_label->set_label_for( lr_text ).

  lr_label = lr_grid_1->create_label(
  row    = 2
  column = 1
  text    = ' Date:'
  tooltip = 'Date' ).

  lr_text = lr_grid_1->create_text(
  row    = 2
  column = 2
  text    = sy-datum
  tooltip = sy-datum ).
  lr_label->set_label_for( lr_text ).
  cr_content = lr_grid.

  lr_label = lr_grid_1->create_label(
  row    = 2
  column = 35
  text    = ''
  tooltip = 'Title' ).

  lr_text = lr_grid_1->create_text(
  row    = 2
  column = 35
  text    = sy-title
  tooltip = sy-title ).
  lr_label->set_label_for( lr_text ).
  cr_content = lr_grid.

  lr_label = lr_grid_1->create_label(
  row    = 2
  column = 70
  text    = 'Time:'
  tooltip = 'Date' ).

  lr_text = lr_grid_1->create_text(
  row    = 2
  column = 71
  text    = sy-uzeit
  tooltip = sy-uzeit ).
  lr_label->set_label_for( lr_text ).
  cr_content = lr_grid.
ENDFORM.                    " BUILD_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_RELAT_TABLES
*&---------------------------------------------------------------------*
FORM f_relat_tables .
  gs_binding-master = 'BUKRS'.
  gs_binding-slave  = 'BUKRS'.
  APPEND gs_binding TO gt_binding.

  gs_binding-master = 'GJAHR'.
  gs_binding-slave  = 'GJAHR'.
  APPEND gs_binding TO gt_binding.

  gs_binding-master = 'LINNO'.
  gs_binding-slave  = 'LINNO'.
  APPEND gs_binding TO gt_binding.

  gs_binding-master = 'INVNO'.
  gs_binding-slave  = 'INVNO'.
  APPEND gs_binding TO gt_binding.

ENDFORM.                    " F_RELAT_TABLES


*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_COLUMN_TEXT_LEVEL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_column_text_level1 .
  gt_columns = gt_hierseq->get_columns( level = 1 ).

*... set expand column
  gt_columns->set_expand_column( 'EXPAND' ).

*... set items expanded
  gr_level = gt_hierseq->get_level( 1 ).
  gr_level->set_items_expanded( ).

  gt_column ?= gt_columns->get_column( 'BUKRS' ).
*  gt_column->set_output_length( '4' ).
  gt_column->set_short_text( 'CoCd' ).

  gt_column ?= gt_columns->get_column( 'GJAHR' ).
  gt_column->set_short_text( 'Year' ).

  gt_column ?= gt_columns->get_column( 'LINNO' ).
  gt_column->set_short_text( 'Line No.' ).

  gt_column ?= gt_columns->get_column( 'INVNO' ).
  gt_column->set_output_length( '30' ).
  gt_column->set_short_text( 'Nomor' ).
  gt_column->set_medium_text( 'Nomor' ).
  gt_column->set_long_text( 'Nomor' ).

  gt_column ?= gt_columns->get_column( 'BKTXT' ).
  gt_column->set_output_length( '25' ).
  gt_column->set_short_text( 'Hdr Txt' ).
  gt_column->set_medium_text( 'Header Text' ).
  gt_column->set_long_text( 'Header Text' ).

  gt_column ?= gt_columns->get_column( 'INVDT' ).
  gt_column->set_short_text( 'Date' ).
  gt_column->set_medium_text( 'Date' ).
  gt_column->set_long_text( 'Date' ).

  gt_column ?= gt_columns->get_column( 'NAME1' ).
  gt_column->set_short_text( 'Cust. Name' ).

  gt_column ?= gt_columns->get_column( 'ZQTY' ).
  gt_column->set_decimals( '0' ).
  gt_column->set_short_text( 'Quantity' ).

  gt_column ?= gt_columns->get_column( 'TARIF' ).
  gt_column->set_currency_column( 'WAERK' ).
  gt_column->set_short_text( 'Tarif' ).
  gt_column->set_medium_text( 'Tarif' ).
  gt_column->set_long_text( 'Tarif' ).

  gt_column ?= gt_columns->get_column( 'AMOUNT' ).
  gt_column->set_currency_column( 'WAERK' ).
  gt_column->set_short_text( 'Tagihan' ).
  gt_column->set_medium_text( 'Tagihan' ).
  gt_column->set_long_text( 'Tagihan' ).

  gt_column ?= gt_columns->get_column( 'NET_AMOUNT' ).
  gt_column->set_currency_column( 'WAERK' ).
  gt_column->set_short_text( 'Net Amount' ).
  gt_column->set_medium_text( 'Net Amount' ).
  gt_column->set_long_text( 'Net Amount' ).

  gt_column ?= gt_columns->get_column( 'WAERK' ).
  gt_column->set_short_text( 'Curr.' ).
ENDFORM.                    " F_CHANGE_COLUMN_TEXT_LEVEL1

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_COLUMN_TEXT_LEVEL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_column_text_level2 .
  gt_columns = gt_hierseq->get_columns( level = 2 ).

  gt_columns->set_optimize( abap_true ).

  gt_column ?= gt_columns->get_column( 'BUKRS' ).
  gt_column->set_visible( space ).

  gt_column ?= gt_columns->get_column( 'GJAHR' ).
  gt_column->set_visible( space ).

  gt_column ?= gt_columns->get_column( 'LINNO' ).
  gt_column->set_visible( space ).

  gt_column ?= gt_columns->get_column( 'INVNO' ).
  gt_column->set_visible( space ).

  gt_column ?= gt_columns->get_column( 'KOSTL' ).
*  gt_column->set_output_length( '10' ).
  gt_column->set_short_text( 'Cost Ctr' ).

  gt_column ?= gt_columns->get_column( 'ZXREF' ).
  gt_column->set_output_length( '30' ).
  gt_column->set_short_text( 'Info Order' ).

  gt_column ?= gt_columns->get_column( 'BGITM' ).
  gt_column->set_visible( space ).
*  gt_column->set_short_text( 'Budget Itm' ).

  gt_column ?= gt_columns->get_column( 'ITMDSC' ).
  gt_column->set_output_length( '50' ).
  gt_column->set_short_text( 'Item Desc.' ).

  gt_column ?= gt_columns->get_column( 'AMOUNT' ).
  gt_column->set_currency_column( 'WAERK' ).
  gt_column->set_short_text( 'Alokasi' ).
  gt_column->set_medium_text( 'Alokasi' ).
  gt_column->set_long_text( 'Alokasi' ).

  gt_column ?= gt_columns->get_column( 'WAERK' ).
  gt_column->set_short_text( 'Curr.' ).
ENDFORM.                    " F_CHANGE_COLUMN_TEXT_LEVEL2

*&---------------------------------------------------------------------*
*&      Form  F_GET_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_functions .
  gt_hierseq->set_screen_status(
    pfstatus   =  'SALV_STANDARD'
    report     =  gv_repid ).

  gt_functions = gt_hierseq->get_functions( ).
  gt_functions->set_all( abap_true ).

  TRY.
      gt_functions->set_function( name = '&OUP' boolean = abap_false ).
    CATCH cx_salv_not_found .
    CATCH cx_salv_wrong_call .
  ENDTRY.
  TRY.
      gt_functions->set_function( name = '&ODN' boolean = abap_false ).
    CATCH cx_salv_not_found .
    CATCH cx_salv_wrong_call .
  ENDTRY.
  TRY.
      gt_functions->set_function( name = '&ILT' boolean = abap_false ).
    CATCH cx_salv_not_found .
    CATCH cx_salv_wrong_call .
  ENDTRY.

  CASE 'X'.
    WHEN r1.
      TRY.
          gt_functions->set_function( name = 'CANCEL' boolean = abap_false ).
        CATCH cx_salv_not_found .
        CATCH cx_salv_wrong_call .
      ENDTRY.
      TRY.
          gt_functions->set_function( name = 'FORM' boolean = abap_false ).
        CATCH cx_salv_not_found .
        CATCH cx_salv_wrong_call .
      ENDTRY.
    WHEN r2.
      gt_functions->set_function( name = 'POST' boolean = abap_false ).
      gt_functions->set_function( name = 'SIM' boolean = abap_false ).
      gt_functions->set_function( name = 'CANCEL' boolean = abap_false ).
    WHEN r3.
      gt_functions->set_function( name = 'POST' boolean = abap_false ).
      gt_functions->set_function( name = 'SIM' boolean = abap_false ).
      TRY.
          gt_functions->set_function( name = 'FORM' boolean = abap_false ).
        CATCH cx_salv_not_found .
        CATCH cx_salv_wrong_call .
      ENDTRY.
    WHEN r4.
      gt_functions->set_function( name = 'POST' boolean = abap_false ).
      gt_functions->set_function( name = 'SIM' boolean = abap_false ).
      gt_functions->set_function( name = 'CANCEL' boolean = abap_false ).
      TRY.
          gt_functions->set_function( name = 'FORM' boolean = abap_false ).
        CATCH cx_salv_not_found .
        CATCH cx_salv_wrong_call .
      ENDTRY.
  ENDCASE.

*- Zebra Layout
  gt_display = gt_hierseq->get_display_settings( ).
  gt_display->set_striped_pattern( cl_salv_display_settings=>true ).

*- Enable the save layout buttons
  key-report = sy-repid.
  gt_layout = gt_hierseq->get_layout( ).
  gt_layout->set_key( key ).
  gt_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
  gt_layout->set_default( abap_true ).

  gr_selections = gt_hierseq->get_selections( level = 1 ).
  gr_selections->set_selection_mode( cl_salv_selections=>if_salv_c_selection_mode~multiple ).
*  gr_selections->set_selection_mode( cl_salv_selections=>if_salv_c_selection_mode~single ).
*  gr_selections->set_selection_mode( cl_salv_selections=>if_salv_c_selection_mode~none ).

  IF r4 = 'X'.
    gr_selections->set_selection_mode( cl_salv_selections=>if_salv_c_selection_mode~none ).
  ENDIF.

  gt_hierseq->display( ).
ENDFORM.                    " F_GET_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRINT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_OUT2  text
*----------------------------------------------------------------------*
*FORM f_prepare_print2  TABLES   ft_out2 STRUCTURE zrevtr001.
*  DATA: lv_qty        TYPE zquan,
*        lv_amount     TYPE dmbtr,
*        lv_net_amount TYPE dmbtr,
*        lv_waerk      TYPE waerk,
*        lt_header     TYPE TABLE OF zrevtr001 WITH HEADER LINE.
*
*  lt_header[] = ft_out2[].
*  SORT lt_header BY invno.
*  DELETE ADJACENT DUPLICATES FROM lt_header COMPARING invno.
*
*  CLEAR: gs_header,gs_detail,gt_detail[],gt_zrevtr001_upd,gt_zrevtr001_upd[].
*  CLEAR: gt_ztr_rate_mst[],gt_ztr_revenue_mst[].
*
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ztr_rate_mst
*    FROM ztr_rate_mst.
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_ztr_revenue_mst
*    FROM ztr_revenue_mst.
*
*  LOOP AT lt_header.
*    "Prepare print header
*    IF r8 = 'X'.
*      gs_header-bukrs   = lt_header-bukrs.
*      gs_header-invno   = lt_header-invno.
**      gs_header-name1   = gv_name1.
*      gs_header-title   = 'BERITA ACARA PENYELESAIAN PENGERJAAN & PENAGIHAN'.
*      gs_header-invno2  = lt_header-invno2.
*      gs_header-wrk01   = lt_header-wrk01.
*      gs_header-wrk02   = lt_header-wrk02.
*      gs_header-wrk03   = lt_header-wrk03.
*      gs_header-apr01   = lt_header-apr01.
*      gs_header-apr02   = lt_header-apr02.
*      gs_header-apr03   = lt_header-apr03.
*      gs_header-sign01  = lt_header-sign01.
*      gs_header-sign02  = lt_header-sign02.
*      gs_header-sign03  = lt_header-sign03.
*      WRITE lt_header-invdt TO gs_header-tanggal.
*
*      SELECT SINGLE name1 INTO gs_header-name1
*        FROM kna1 WHERE kunnr = lt_header-kunnr.
*
*    ELSE.
*      gs_header-bukrs   = p_bukrs.
*      gs_header-invno   = p_invno.
*      gs_header-name1   = gv_name1.
*      gs_header-title   = 'BERITA ACARA PENYELESAIAN PENGERJAAN & PENAGIHAN'.
*      gs_header-invno2  = p_invno2.
*      gs_header-wrk01   = p_wrk01.
*      gs_header-wrk02   = p_wrk02.
*      gs_header-wrk03   = p_wrk03.
*      gs_header-apr01   = p_apr01.
*      gs_header-apr02   = p_apr02.
*      gs_header-apr03   = p_apr03.
*      gs_header-sign01  = p_sign01.
*      gs_header-sign02  = p_sign02.
*      gs_header-sign03  = p_sign03.
*      WRITE p_invdt TO gs_header-tanggal.
*    ENDIF.
*
*    PERFORM f_get_addr_bukrs USING p_bukrs
*                             CHANGING gs_header-butxt
*                                      gs_header-city1
*                                      gs_header-tel_number
*                                      gs_header-fax_number.
*
*    "Prepare print detail
*    LOOP AT ft_out2 ASSIGNING <fs_out2> WHERE invno = lt_header-invno.
*      <fs_out2>-invno    = p_invno.
*      <fs_out2>-invdt    = p_invdt.
*      <fs_out2>-kunnr    = p_kunnr.
*      <fs_out2>-name1    = gv_name1.
*      <fs_out2>-invno2   = p_invno2.
*      <fs_out2>-wrk01    = p_wrk01.
*      <fs_out2>-wrk02    = p_wrk02.
*      <fs_out2>-wrk03    = p_wrk03.
*      <fs_out2>-apr01    = p_apr01.
*      <fs_out2>-apr02    = p_apr02.
*      <fs_out2>-apr03    = p_apr03.
*      <fs_out2>-sign01   = p_sign01.
*      <fs_out2>-sign02   = p_sign02.
*      <fs_out2>-sign03   = p_sign03.
*
*      IF <fs_out2>-ratetyp_act IS INITIAL.
*        <fs_out2>-ratetyp_act = <fs_out2>-ratetyp.
*        <fs_out2>-tarif_act   = <fs_out2>-tarif.
*        <fs_out2>-amount_act  = <fs_out2>-amount.
*      ENDIF.
*
*      IF <fs_out2>-timln IS INITIAL.
*        <fs_out2>-timln = 100.
*        <fs_out2>-net_amount = <fs_out2>-amount_act * <fs_out2>-timln / 100.
*      ENDIF.
*
*      gs_detail-bukrs     = <fs_out2>-bukrs.
*      gs_detail-invno     = <fs_out2>-invno.
*      gs_detail-linno     = <fs_out2>-linno.
*      gs_detail-produk    = <fs_out2>-mattx.
*      gs_detail-ket       = <fs_out2>-keterangan.
*      WRITE <fs_out2>-zqty TO gs_detail-zqty DECIMALS 0.
*      WRITE <fs_out2>-tarif_act TO gs_detail-tarif CURRENCY <fs_out2>-waerk.
*      WRITE <fs_out2>-amount_act TO gs_detail-amount CURRENCY <fs_out2>-waerk.
*      WRITE <fs_out2>-timln TO gs_detail-timln DECIMALS 0.
*      WRITE <fs_out2>-net_amount TO gs_detail-net_amount CURRENCY <fs_out2>-waerk.
*
*      lv_waerk = <fs_out2>-waerk.
*      ADD: <fs_out2>-zqty TO lv_qty,
*           <fs_out2>-amount_act TO lv_amount,
*           <fs_out2>-net_amount TO lv_net_amount.
*
*      CLEAR: gt_ztr_revenue_mst,gt_ztr_rate_mst.
*      READ TABLE gt_ztr_revenue_mst WITH KEY revtyp = <fs_out2>-revtyp.
*      READ TABLE gt_ztr_rate_mst WITH KEY ratetyp = <fs_out2>-ratetyp.
*      CONCATENATE gt_ztr_revenue_mst-revtxt gt_ztr_rate_mst-ratetxt
*        INTO gs_detail-pekerjaan.
*
*      APPEND gs_detail TO gt_detail. CLEAR gs_detail.
*      APPEND <fs_out2> TO gt_zrevtr001_upd.
*    ENDLOOP.
*
*    WRITE lv_qty TO gs_header-qty DECIMALS 0.
*    WRITE lv_amount TO gs_header-amount CURRENCY lv_waerk.
*    WRITE lv_net_amount TO gs_header-net_amount CURRENCY lv_waerk.
*
** Print form
*    PERFORM f_print_form.
*  ENDLOOP.
*ENDFORM.                    " F_PREPARE_PRINT2

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA: lt_zrevtr001 TYPE TABLE OF zrevtr001.

  CASE 'X'.
    WHEN r1.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zrevtr001
        FROM zrevtr001 WHERE bukrs = '8140'
                         AND gjahr = p_gjahr
                         AND linno IN s_linno
                         AND revtyp = '04'
                         AND invno IN s_invno
                         AND invno NE space
                         AND postdoc NE space
                         AND postdoc_tnt EQ space.

    WHEN r5.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zrevtr001
        FROM zrevtr001 WHERE bukrs = '8140'
                         AND gjahr = p_gjahr
                         AND invno IN s_invno
                         AND postdoc NE space
                         AND postdoc_tnt NE space
                         AND postname_tnt NE space
                         AND fakturno_tnt = space.

    WHEN r2.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zrevtr001
        FROM zrevtr001 WHERE bukrs = '8140'
                         AND gjahr = p_gjahr
                         AND invno IN s_invno
                         AND fakturno_tnt IN s_fakno
                         AND postdoc_tnt NE space
*                         AND fakturno_tnt NE space
                         AND postname_tnt NE space.


    WHEN r3.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zrevtr001
        FROM zrevtr001 WHERE bukrs = '8140'
                         AND gjahr = p_gjahr
                         AND invno IN s_invno
                         AND fakturno_tnt IN s_fakno
                         AND postdoc_tnt NE space
                         AND postname_tnt NE space.

    WHEN r4.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zrevtr001
        FROM zrevtr001 WHERE bukrs = '8140'
                         AND gjahr = p_gjahr
                         AND invno IN s_invno
                         AND fakturno_tnt IN s_fakno
                         AND postdate_tnt IN s_postdt
                         AND postdoc_tnt NE space
                         AND postname_tnt NE space.
  ENDCASE.

  IF gt_zrevtr001[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  lt_zrevtr001[] = gt_zrevtr001[].
  SORT lt_zrevtr001 BY ratetyp.
  DELETE ADJACENT DUPLICATES FROM lt_zrevtr001 COMPARING ratetyp.
  IF lt_zrevtr001[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_zratetr001
      FROM zratetr001 FOR ALL ENTRIES IN lt_zrevtr001
      WHERE ratetyp = lt_zrevtr001-ratetyp.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zaloktr02
    FROM zaloktr02 FOR ALL ENTRIES IN gt_zrevtr001
    WHERE bukrs = '8140'
      AND gjahr = gt_zrevtr001-gjahr
      AND bgitm = gt_zrevtr001-linno
      AND invno = gt_zrevtr001-invno.

  IF gt_zaloktr02[] IS NOT INITIAL.
    SELECT kokrs kostl datbi datab bukrs gsber prctr
      INTO CORRESPONDING FIELDS OF TABLE gt_csks
      FROM csks FOR ALL ENTRIES IN gt_zaloktr02
      WHERE kokrs = gc_kokrs
        AND kostl = gt_zaloktr02-kostl.
    IF gt_csks[] IS NOT INITIAL.
      SELECT aufnr auart bukrs gsber prctr
        INTO CORRESPONDING FIELDS OF TABLE gt_coas
        FROM coas FOR ALL ENTRIES IN gt_csks
        WHERE aufnr LIKE gc_aufnr
          AND bukrs = gt_csks-bukrs
          AND gsber = gt_csks-gsber
          AND prctr = gt_csks-prctr.
    ENDIF.
  ENDIF.

  SELECT * INTO TABLE gt_ztr_order_mst
    FROM ztr_order_mst.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA: ls_zrevtr001 LIKE LINE OF gt_zrevtr001.
  DATA: ls_zratetr001 LIKE LINE OF gt_zratetr001.

  SORT gt_zrevtr001 BY bukrs gjahr invno invdt.

  LOOP AT gt_zrevtr001.
    "Collect Header
    MOVE-CORRESPONDING gt_zrevtr001 TO gs_hdr.
    IF gs_hdr-kunnr = 'TSB8010'.
      gs_hdr-kunnr = 'TSB0101'.
    ENDIF.

    CASE 'X'.
      WHEN r1.
        gs_hdr-postdate = gt_zrevtr001-postdate.
      WHEN OTHERS.
        gs_hdr-postdate = gt_zrevtr001-postdate_tnt.
        gs_hdr-postyear = gt_zrevtr001-postyear_tnt.
        gs_hdr-bktxt    = gt_zrevtr001-bktxt_tnt.
        gs_hdr-postdoc  = gt_zrevtr001-postdoc_tnt.
        gs_hdr-fakturno = gt_zrevtr001-fakturno_tnt.
    ENDCASE.

    CLEAR: gs_hdr-linno,gs_hdr-invdt,gs_hdr-ratetyp,ls_zrevtr001.
    READ TABLE gt_zrevtr001 INTO ls_zrevtr001 WITH KEY bukrs = gt_zrevtr001-bukrs
                                                       gjahr = gt_zrevtr001-gjahr
                                                       invno = gt_zrevtr001-invno.
    gs_hdr-invdt = ls_zrevtr001-invdt.
    COLLECT gs_hdr INTO gt_hdr.

    "Collect Detail
    LOOP AT gt_zaloktr02 WHERE bukrs = gt_zrevtr001-bukrs
                           AND gjahr = gt_zrevtr001-gjahr
                           AND bgitm = gt_zrevtr001-linno
                           AND invno = gt_zrevtr001-invno.
      MOVE-CORRESPONDING gt_zaloktr02 TO gs_itm.
      gs_itm-linno    = gt_zaloktr02-bgitm.
      gs_itm-ratetyp  = gt_zrevtr001-ratetyp.

      IF gt_zaloktr02-kostl = '0001400106'.
        gs_itm-kostl = '0001600104'.
      ELSE.
        gs_itm-kostl = '0001600101'.
      ENDIF.


      CLEAR: ls_zratetr001.
      READ TABLE gt_zratetr001 INTO ls_zratetr001 WITH KEY bukrs = gt_zrevtr001-bukrs
                                                           gjahr = gt_zrevtr001-gjahr
                                                           ratetyp = gt_zrevtr001-ratetyp.
      gs_itm-ratetxt  = ls_zratetr001-ratetxt.
      gs_itm-zgrp     = gt_zrevtr001-zgrp.
      gs_itm-factory  = gt_zrevtr001-factory.
      gs_itm-zqty     = gt_zrevtr001-zqty.
      gs_itm-revtyp   = gt_zrevtr001-revtyp.
      gs_itm-subdt    = gt_zrevtr001-subdt.
      gs_itm-aprdt    = gt_zrevtr001-aprdt.
      APPEND gs_itm TO gt_itm.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_POSTING
*&---------------------------------------------------------------------*
FORM f_posting  USING    fu_ucomm.
  DATA: lv_bktxt         TYPE bktxt,
        lv_item_text(50),
        lv_item          TYPE posnr_acc,
        ls_h             TYPE bapiache09,
        lv_objkey        TYPE bapiache09-obj_key,
        lt_c             TYPE TABLE OF bapiaccr09,
        ls_c             LIKE LINE OF lt_c,
        lt_gl            TYPE TABLE OF bapiacgl09,
        ls_gl            LIKE LINE OF lt_gl,
        lt_ar            TYPE TABLE OF bapiacar09,
        ls_ar            LIKE LINE OF lt_ar,
        lt_tax           TYPE TABLE OF bapiactx09,
        ls_tax           LIKE LINE OF lt_tax,
        lt_r             TYPE TABLE OF bapiret2.

  DATA: lv_amt01  TYPE wrbtr,
        lv_amt40  TYPE wrbtr,
        lv_amt50  TYPE wrbtr,
        lv_amount TYPE wrbtr.

  DATA: ls_11    TYPE zproject,
        ls_12    TYPE zproject,
        lr_datum TYPE RANGE OF datum,
        ls_datum LIKE LINE OF lr_datum.

  CLEAR gv_err.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF ls_11
    WHERE name = 'PPN11'
      AND flag = 'X'.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF ls_12
    WHERE name = 'PPN12'
      AND flag = 'X'.

  ls_datum-low    = ls_11-datab.
  ls_datum-high   = ls_12-datab.
  ls_datum-sign   = 'I'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO lr_datum.

  READ TABLE gt_hdr WITH KEY chkbx = 'X'
                    TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    CLEAR: gt_zaloktr02sum[].
    LOOP AT gt_zaloktr02.
      MOVE-CORRESPONDING gt_zaloktr02 TO gt_zaloktr02sum.
      CLEAR: gt_zaloktr02sum-bgitm,gt_zaloktr02sum-kostl,
             gt_zaloktr02sum-zxref,gt_zaloktr02sum-itmdsc.
      COLLECT gt_zaloktr02sum. CLEAR gt_zaloktr02sum.
    ENDLOOP.

    LOOP AT gt_hdr ASSIGNING <fs_hdr> WHERE chkbx = 'X'.
      CLEAR: lv_bktxt,lv_item,ls_h,lt_gl[],lt_c[],lt_r[].

      CLEAR gt_zaloktr02sum.
      READ TABLE gt_zaloktr02sum WITH KEY bukrs = <fs_hdr>-bukrs
                                          gjahr = <fs_hdr>-gjahr
                                          invno = <fs_hdr>-invno.

      IF <fs_hdr>-net_amount = gt_zaloktr02sum-amount.
        CLEAR: lv_amt01,lv_amt40,lv_amt50,lv_amount.
*        lv_amt40  = <fs_hdr>-net_amount * 2 / 100.
        lv_amount = <fs_hdr>-net_amount * 2 * 100.
        lv_amt40  = ( lv_amount DIV 100 ) / 100.
*        lv_amt50 = <fs_hdr>-net_amount * 11 / 100.
        CLEAR lv_amount.
*        lv_amount = <fs_hdr>-net_amount * 11 * 100.

        IF <fs_hdr>-postdate IN lr_datum.
          lv_amount = <fs_hdr>-net_amount * 11 * 100.
        ELSEIF <fs_hdr>-postdate > ls_12-datab.
          lv_amount = <fs_hdr>-net_amount * 12 * 100.
        ENDIF.

        lv_amt50  = ( lv_amount DIV 100 ) / 100.
        lv_amt01  = <fs_hdr>-net_amount + lv_amt50 - lv_amt40.

        "Header
        ls_h-username   = sy-uname.
        ls_h-bus_act    = 'RFBU'.
        ls_h-doc_type   = 'DR'.
        ls_h-comp_code  = '8160'.
        ls_h-doc_date   = <fs_hdr>-postdate.
        ls_h-pstng_date = <fs_hdr>-postdate.
        ls_h-fisc_year  = <fs_hdr>-postdate(4).
        ls_h-fis_period = <fs_hdr>-postdate+4(2).
        ls_h-ref_doc_no = <fs_hdr>-linno.
        ls_h-header_txt = <fs_hdr>-linno.
        IF <fs_hdr>-bktxt IS NOT INITIAL.
          ls_h-header_txt = <fs_hdr>-bktxt.
        ENDIF.

        " 01 Item AR
        CLEAR ls_ar.
        ADD 1 TO lv_item.
        ls_ar-itemno_acc  = lv_item.
        ls_ar-customer    = <fs_hdr>-kunnr.
        ls_ar-bus_area    = '1600'.
        ls_ar-alloc_nmbr  = <fs_hdr>-invno. "<fs_hdr>-bktxt.   "<fs_hdr>-linno.
        ls_ar-item_text   = <fs_hdr>-invno.
*        ls_ar-bline_date  = sy-datum.
        SELECT SINGLE zterm INTO ls_ar-pmnttrms
          FROM knb1 WHERE kunnr = <fs_hdr>-kunnr
                      AND bukrs = '8140'.
        APPEND ls_ar TO lt_ar.
        PERFORM f_collect_item_currency TABLES lt_c
                                        USING  lv_item
                                               <fs_hdr>-waerk
                                               lv_amt01
                                               '+'.

        " 40 Item GL
        CLEAR ls_ar.
        ADD 1 TO lv_item.
        ls_ar-itemno_acc  = lv_item.
        ls_ar-gl_account  = '0142100020'.
        ls_ar-bus_area    = '1600'.
        ls_ar-alloc_nmbr  = <fs_hdr>-invno.   "<fs_hdr>-bktxt.   "<fs_hdr>-linno.
        ls_ar-item_text   = <fs_hdr>-invno.
        ls_ar-bline_date  = sy-datum.
        APPEND ls_ar TO lt_ar.
        PERFORM f_collect_item_currency TABLES lt_c
                                        USING  lv_item
                                               <fs_hdr>-waerk
                                               lv_amt40
                                               '+'.

        " 50 Item GL
        CLEAR ls_gl.
        ADD 1 TO lv_item.
        ls_gl-itemno_acc  = lv_item.
        ls_gl-gl_account  = '0315300210'.
        ls_gl-bus_area    = '1600'.
        ls_gl-alloc_nmbr  = <fs_hdr>-invno.   "<fs_hdr>-bktxt.   "<fs_hdr>-linno.
        ls_gl-item_text   = <fs_hdr>-invno.
        APPEND ls_gl TO lt_gl.
        PERFORM f_collect_item_currency TABLES lt_c
                                        USING  lv_item
                                               <fs_hdr>-waerk
                                               lv_amt50
                                               '-'.

        LOOP AT gt_itm INTO gs_itm WHERE bukrs = <fs_hdr>-bukrs
                                     AND gjahr = <fs_hdr>-gjahr
                                     AND invno = <fs_hdr>-invno.
          CLEAR: ls_gl,gt_zratetr001.
*          READ TABLE gt_ztr_rate_mst WITH KEY ratetyp = gs_itm-ratetyp.

          ADD 1 TO lv_item.
          ls_gl-itemno_acc  = lv_item.
          ls_gl-gl_account  = '0612110000'.
          ls_gl-bus_area    = '1600'.
*          ls_gl-alloc_nmbr  = gs_itm-bgitm.
          CONCATENATE gs_itm-bgitm gs_itm-ratetyp
            INTO ls_gl-alloc_nmbr SEPARATED BY '-'.
          ls_gl-item_text   = gs_itm-invno.   "gt_ztr_rate_mst-ratetxt.
          ls_gl-costcenter  = gs_itm-kostl.

          IF gs_itm-kostl = '0001600101'.
            ls_gl-orderid = 'TNT100002'.
          ELSE.
            ls_gl-orderid = 'TNT100001'.
          ENDIF.
*          ls_gl-trade_id = 'OUTLET'.
*          PERFORM f_get_order USING gs_itm-bukrs
*                                    gs_itm-kostl
*                                    gs_itm-zgrp
*                                    gs_itm-revtyp
*                                    <fs_hdr>-kunnr
*                              CHANGING ls_gl-orderid.
          APPEND ls_gl TO lt_gl.

          PERFORM f_collect_item_currency TABLES lt_c
                                          USING  lv_item
                                                 <fs_hdr>-waerk
                                                 gs_itm-amount
                                                 '-'.
        ENDLOOP.

        CASE fu_ucomm.
          WHEN '&SIM'.
            CLEAR lv_objkey.
            REFRESH lt_r.
            CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
              EXPORTING
                documentheader    = ls_h
              TABLES
                accountgl         = lt_gl
                accountreceivable = lt_ar
*               accounttax        = lt_tax
                currencyamount    = lt_c
*               criteria          = t_copa
                return            = lt_r.

            READ TABLE lt_r WITH KEY type = 'S' TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              <fs_hdr>-icon = icon_okay.
              <fs_hdr>-chkbx    = '0'.
            ELSE.
              <fs_hdr>-icon = icon_cancel.
            ENDIF.
            CLEAR <fs_hdr>-chkbx.

          WHEN '&POS'.
            CLEAR lv_objkey.
            REFRESH lt_r.
            CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
              EXPORTING
                documentheader    = ls_h
              IMPORTING
                obj_key           = lv_objkey
              TABLES
                accountgl         = lt_gl
                accountreceivable = lt_ar
*               accounttax        = lt_tax
                currencyamount    = lt_c
*               criteria          = t_copa
                return            = lt_r.

            READ TABLE lt_r WITH KEY type = 'S' TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = 'X'.

              "Update itab header
              <fs_hdr>-icon     = icon_okay.
              <fs_hdr>-chkbx    = '2'.
              <fs_hdr>-postdoc  = lv_objkey(10).
              <fs_hdr>-postyear = lv_objkey+14(4).
              <fs_hdr>-postname = sy-uname.
*              <fs_hdr>-postdate = sy-datum.

              "update itab gt_zrevtr001
              CLEAR: gt_zrevtr001.
              gt_zrevtr001-bktxt_tnt    = <fs_hdr>-bktxt.
              gt_zrevtr001-postdoc_tnt  = <fs_hdr>-postdoc.
              gt_zrevtr001-postyear_tnt = <fs_hdr>-postyear.
              gt_zrevtr001-postname_tnt = <fs_hdr>-postname.
              gt_zrevtr001-postdate_tnt = <fs_hdr>-postdate.
              MODIFY gt_zrevtr001 TRANSPORTING bktxt_tnt postdoc_tnt postyear_tnt postname_tnt postdate_tnt
                                   WHERE bukrs = <fs_hdr>-bukrs
                                     AND gjahr = <fs_hdr>-gjahr
*                                     AND linno = <fs_hdr>-linno
                                     AND invno = <fs_hdr>-invno.

              "Update table zrevtr001
              UPDATE zrevtr001 SET bktxt_tnt    = <fs_hdr>-bktxt
                                   postdoc_tnt  = <fs_hdr>-postdoc
                                   postyear_tnt = <fs_hdr>-postyear
                                   postname_tnt = <fs_hdr>-postname
                                   postdate_tnt = <fs_hdr>-postdate
                               WHERE bukrs = <fs_hdr>-bukrs
                                 AND gjahr = <fs_hdr>-gjahr
*                                 AND linno = <fs_hdr>-linno
                                 AND invno = <fs_hdr>-invno.

*              INSERT zrevtr001 FROM TABLE gt_zrevtr001.

            ELSE.
              <fs_hdr>-icon = icon_cancel.
              <fs_hdr>-msg = 'Ada error saat posting'.
            ENDIF.
            CLEAR <fs_hdr>-chkbx.
        ENDCASE.

      ELSE.
        <fs_hdr>-icon = icon_cancel.
        <fs_hdr>-msg = 'Amount not balance'.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_POSTING_BDC

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ITEM_CURRENCY
*&---------------------------------------------------------------------*
FORM f_collect_item_currency  TABLES   ft_c STRUCTURE bapiaccr09
                              USING    fu_item
                                       fu_waerk
                                       fu_amount
                                       fu_sign.
  DATA: ls_c          LIKE LINE OF ft_c.

  CLEAR ls_c.
  ls_c-itemno_acc = fu_item.
  ls_c-currency   = fu_waerk.
  CASE fu_sign.
    WHEN '+'.
      ls_c-amt_doccur = fu_amount * 100.
    WHEN '-'.
      ls_c-amt_doccur = fu_amount * -100.
  ENDCASE.
  APPEND ls_c TO ft_c.
ENDFORM.                    " F_COLLECT_ITEM_CURRENCY

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER
*&---------------------------------------------------------------------*
FORM f_get_order  USING    fu_bukrs
                           fu_kostl
                           fu_zgrp
                           fu_revtyp
                           fu_kunnr
                  CHANGING fc_orderid.

*  CLEAR: gt_csks,gt_coas.
*  READ TABLE gt_csks WITH KEY kostl = fu_kostl.
*  READ TABLE gt_coas WITH KEY bukrs = fu_bukrs
*                              prctr = gt_csks-prctr.
*  fc_orderid = gt_coas-aufnr.
  CLEAR gt_ztr_order_mst.
  READ TABLE gt_ztr_order_mst WITH KEY revtyp = fu_revtyp
                                       zgrp = fu_zgrp.
  fc_orderid = gt_ztr_order_mst-aufnr.

  CASE fu_kunnr.
    WHEN '2300000002'.
      CONCATENATE fc_orderid 'TDN' INTO fc_orderid.
    WHEN 'TSB8330'.
      CONCATENATE fc_orderid 'PLI' INTO fc_orderid.
    WHEN 'TSB8360'.
      CONCATENATE fc_orderid 'KMM' INTO fc_orderid.
    WHEN '2300000017'.
      CONCATENATE fc_orderid 'TMP' INTO fc_orderid.
    WHEN OTHERS.
      CONCATENATE fc_orderid fu_kunnr+3(4) INTO fc_orderid.
  ENDCASE.
ENDFORM.                    " F_GET_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_FAKTUR_PAJAK
*&---------------------------------------------------------------------*
FORM f_proses_faktur_pajak .
  DATA: lt_bkpf TYPE TABLE OF bkpf WITH HEADER LINE,
        lt_hdr  TYPE TABLE OF ty_hdr WITH HEADER LINE.

  lt_hdr[] = gt_hdr[].
  DELETE lt_hdr WHERE postdoc IS INITIAL.

  IF lt_hdr[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr blart bldat budat monat
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf
      FROM bkpf FOR ALL ENTRIES IN lt_hdr
      WHERE bukrs = '8160'
        AND belnr = lt_hdr-postdoc
        AND gjahr = lt_hdr-postyear.

    SORT: gt_hdr BY bukrs postdoc postyear,
          lt_hdr BY bukrs postdoc postyear,
          lt_bkpf BY bukrs belnr gjahr.

    LOOP AT lt_hdr.
      READ TABLE gt_hdr ASSIGNING <fs_hdr>
                        WITH KEY bukrs     = '8160'
                                 postdoc   = lt_hdr-postdoc
                                 postyear  = lt_hdr-postyear
                                 BINARY SEARCH.

      CLEAR lt_bkpf.
      READ TABLE lt_bkpf WITH KEY bukrs = '8160'
                                  belnr = lt_hdr-postdoc
                                  gjahr = lt_hdr-postyear
                                  BINARY SEARCH.

      PERFORM f_process_non_trade(zgdfi_e0001) USING    lt_bkpf-bukrs
                                                        lt_bkpf-belnr
                                                        lt_bkpf-monat
                                                        lt_bkpf-gjahr
                                               CHANGING <fs_hdr>-fakturno.

      IF <fs_hdr>-fakturno IS NOT INITIAL.
        gt_zrevtr001-fakturno_tnt = <fs_hdr>-fakturno.
        MODIFY gt_zrevtr001 TRANSPORTING fakturno_tnt
                             WHERE bukrs = <fs_hdr>-bukrs
                               AND gjahr = <fs_hdr>-gjahr
*                               AND linno = <fs_hdr>-linno
                               AND invno = <fs_hdr>-invno.

        UPDATE zrevtr001 SET fakturno_tnt = <fs_hdr>-fakturno
                         WHERE bukrs = <fs_hdr>-bukrs
                           AND gjahr = <fs_hdr>-gjahr
*                           AND linno = <fs_hdr>-linno
                           AND invno = <fs_hdr>-invno.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROSES_FAKTUR_PAJAK

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_INVOICE
*&---------------------------------------------------------------------*
FORM f_reverse_invoice .
  DATA: lv_subrc LIKE sy-subrc.

  READ TABLE gt_hdr WITH KEY chkbx = 'X'
                    TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.

    LOOP AT gt_hdr ASSIGNING <fs_hdr> WHERE chkbx = 'X'.
      IF <fs_hdr>-fakturno IS NOT INITIAL.
        PERFORM f_cancel_fp USING     <fs_hdr>-bukrs
                                      <fs_hdr>-fakturno
                            CHANGING  lv_subrc.
      ENDIF.

      IF lv_subrc IS INITIAL.
        IF <fs_hdr>-fakturno IS NOT INITIAL.
          UPDATE zrevtr001 SET fakturno_tnt = space
                           WHERE bukrs  = '8140'
                             AND gjahr  = <fs_hdr>-gjahr
                             AND fakturno_tnt = <fs_hdr>-fakturno.
          CLEAR <fs_hdr>-fakturno.
        ENDIF.

        PERFORM f_reverse_posting USING <fs_hdr>-bukrs
                                        <fs_hdr>-postdoc
                                        <fs_hdr>-postyear
                                  CHANGING  lv_subrc.

        IF lv_subrc IS INITIAL.
          UPDATE zrevtr001 SET postdoc_tnt  = space
                               postyear_tnt = space
                               postname_tnt = space
                               postdate_tnt = space
                               bktxt_tnt = space
                           WHERE bukrs  = '8140'
                             AND gjahr  = <fs_hdr>-gjahr
                             AND postdoc_tnt = <fs_hdr>-postdoc.
          CLEAR: <fs_hdr>-postdoc,<fs_hdr>-postyear,<fs_hdr>-postname,
                 <fs_hdr>-postdate.
        ENDIF.
      ENDIF.
      CLEAR lv_subrc.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_REVERSE_INVOICE

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_FP
*&---------------------------------------------------------------------*
FORM f_cancel_fp  USING    fu_bukrs
                           fu_fakturno
                  CHANGING fc_subrc.

  REFRESH: t_bdcdata.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'ZGDTX_E0024'               '1000',
   ' '  'BDC_OKCODE'                '=PROSES',
   ' '  'P_BUKRS'                   '8160',
   ' '  'P_BRNCH'                   '8160',
   ' '  'P_BUSLN'                   '99',
   ' '  'P_SDH'                     ' ',
   ' '  'P_STD'                     'X'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'ZGDTX_E0024'               '1000',
   ' '  'BDC_OKCODE'                '=ONLI',
   ' '  'P_BUKRS'                   '8160',
   ' '  'P_BRNCH'                   '8160',
   ' '  'P_BUSLN'                   '99',
   ' '  'P_STD'                     'X',
   ' '  'P_FAKTUR'                  fu_fakturno.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'SAPMSSY0'                  '0120',
   ' '  'BDC_OKCODE'                '=&DEL'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'SAPLSPO1'                  '0500',
   ' '  'BDC_OKCODE'                '=OPT1'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'SAPMSSY0'                  '0120',
   ' '  'BDC_OKCODE'                '=GBCK'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'ZGDTX_E0024'               '1000',
   ' '  'BDC_OKCODE'                '/EE'.

  d_bdc_batch = 'E'.
  PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                          t_bdcmsg
                                   USING 'ZGDTXE0024' d_bdc_tctxt.

  IF d_bdc_error = 0.
    CLEAR fc_subrc.
  ELSE.
    fc_subrc = 4.
  ENDIF.

  REFRESH: t_bdcdata.
ENDFORM.                    " F_CANCEL_FP

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_POSTING
*&---------------------------------------------------------------------*
FORM f_reverse_posting  USING    fu_bukrs
                                 fu_postdoc
                                 fu_postyear
                        CHANGING fc_subrc.

  REFRESH: t_bdcdata.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
    'X' 'SAPMF05A'                '0105',
    ' ' 'BDC_OKCODE'              '=BU',
    ' ' 'RF05A-BELNS'             fu_postdoc,
    ' ' 'BKPF-BUKRS'              '8160',
    ' ' 'RF05A-GJAHS'             fu_postyear,
    ' ' 'UF05A-STGRD'             '01'.

  d_bdc_batch = 'E'.
  PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                          t_bdcmsg
                                   USING 'FB08' d_bdc_tctxt.

  IF d_bdc_error = 0.
    CLEAR fc_subrc.
  ELSE.
    fc_subrc = 4.
  ENDIF.

  REFRESH: t_bdcdata.
ENDFORM.                    " F_REVERSE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_REPRINT
*&---------------------------------------------------------------------*
FORM f_reprint .
  READ TABLE gt_hdr WITH KEY chkbx = 'X'
                    TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    CALL SELECTION-SCREEN 212 STARTING AT 30 5
                              ENDING AT 150 20.
    IF sy-subrc = 0.

      LOOP AT gt_hdr ASSIGNING <fs_hdr> WHERE chkbx = 'X'.
*        READ TABLE gt_zrevtr001 WITH KEY bukrs = <fs_hdr>-bukrs
*                                         gjahr = <fs_hdr>-gjahr
*                                         invno = <fs_hdr>-invno.
        gs_header-title       = 'FAKTUR PAJAK'.
        gs_header-bukrs       = <fs_hdr>-bukrs.
        gs_header-invno       = <fs_hdr>-invno .
        gs_header-bktxt       = <fs_hdr>-bktxt.
        gs_header-sign        = 'K. LANNY LISTIYANI D'.
*        gs_header-sign        = 'ROSITA YUNIAR'.

        IF <fs_hdr>-postdate IN gr_coretax.
          WRITE <fs_hdr>-fakturno TO gs_header-fakturno
                                      USING EDIT MASK '__.__.__-___.________'.
        ELSE.
          WRITE <fs_hdr>-fakturno TO gs_header-fakturno
                                      USING EDIT MASK '___.___-__.________'.
        ENDIF.

        PERFORM f_get_tanggal USING    <fs_hdr>-bukrs       "gt_zrevtr001-bukrs
                                       <fs_hdr>-kunnr       "gt_zrevtr001-kunnr
                                       <fs_hdr>-postdate    "gt_zrevtr001-postdate
                              CHANGING gs_header-tanggal
                                       gs_header-duedate.

        PERFORM f_get_addr_bukrs USING    gs_header-bukrs
                                 CHANGING gs_header-butxt
                                          gs_header-street
                                          gs_header-city1
                                          gs_header-post_code1
                                          gs_header-stceg
                                          gs_header-tel_number
                                          gs_header-fax_number.

        PERFORM f_get_addr_kunnr USING    <fs_hdr>-kunnr    "gt_zrevtr001-kunnr
                                 CHANGING gs_header-name1
                                          gs_header-xstreet
                                          gs_header-str_suppl2
                                          gs_header-xcity1
                                          gs_header-xpost_code1
                                          gs_header-xstceg.

        PERFORM f_append_dtl_lines USING <fs_hdr>-bukrs
                                         <fs_hdr>-gjahr
                                         <fs_hdr>-invno.

        PERFORM f_get_total USING    '8160'   "<fs_hdr>-bukrs
                                     <fs_hdr>-postdoc
                                     <fs_hdr>-postyear
                                     <fs_hdr>-net_amount
                                     <fs_hdr>-waerk
                            CHANGING gs_header-jual
                                     gs_header-diskon
                                     gs_header-dpp
                                     gs_header-ppn
                                     gs_header-materai
                                     gs_header-bayar
                                     gs_header-says.

* Print form
        PERFORM f_print_form USING <fs_hdr>-net_amount
                                   <fs_hdr>-waerk.
        CLEAR: gs_header,gs_detail,gt_detail.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_REPRINT

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDR_BUKRS
*&---------------------------------------------------------------------*
FORM f_get_addr_bukrs  USING    fu_bukrs
                       CHANGING fc_butxt
                                fc_street
                                fc_city1
                                fc_post_code1
                                fc_stceg
                                fc_tel_number
                                fc_fax_number.
  DATA: lv_adrnr TYPE adrnr.

  SELECT SINGLE butxt adrnr stceg
    INTO (fc_butxt,lv_adrnr,fc_stceg)
    FROM t001 WHERE bukrs = fu_bukrs.

  SELECT SINGLE street city2 post_code1 tel_number fax_number
    INTO (fc_street,fc_city1,fc_post_code1,fc_tel_number,fc_fax_number)
    FROM adrc WHERE addrnumber = lv_adrnr.

  TRANSLATE fc_butxt TO UPPER CASE.

  CONDENSE: fc_butxt,
            fc_street,
            fc_city1,
            fc_post_code1,
            fc_stceg,
            fc_tel_number,
            fc_fax_number.
ENDFORM.                    " F_GET_ADDR_BUKRS

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDR_KUNNR
*&---------------------------------------------------------------------*
FORM f_get_addr_kunnr  USING    fu_kunnr
                       CHANGING fc_name1
                                fc_str_suppl1
                                fc_str_suppl2
                                fc_str_suppl3
                                fc_post_code1
                                fc_stceg.
  DATA: lv_adrnr TYPE adrnr.

  SELECT SINGLE name1 adrnr stceg
    INTO (fc_name1,lv_adrnr,fc_stceg)
    FROM kna1 WHERE kunnr = fu_kunnr.

  SELECT SINGLE str_suppl1 str_suppl2 str_suppl3 post_code1
    INTO (fc_str_suppl1,fc_str_suppl2,fc_str_suppl3,fc_post_code1)
    FROM adrc WHERE addrnumber = lv_adrnr.

  IF fu_kunnr = 'TSB8160' OR fu_kunnr = 'TSB8090'.
    CLEAR fc_post_code1.
  ENDIF.

  CONDENSE: fc_name1,
            fc_str_suppl1,
            fc_str_suppl2,
            fc_str_suppl3,
            fc_post_code1,
            fc_stceg.
ENDFORM.                    " F_GET_ADDR_KUNNR

*&---------------------------------------------------------------------*
*&      Form  F_GET_TANGGAL
*&---------------------------------------------------------------------*
FORM f_get_tanggal  USING    fu_bukrs
                             fu_kunnr
                             fu_postdate
                    CHANGING fu_tanggal
                             fu_duedate.
  DATA: lv_zterm       TYPE dzterm,
        lv_ztag1       TYPE dztage,
        lv_dudat       TYPE datum,
        lt_month_names TYPE TABLE OF t247 WITH HEADER LINE.

  SELECT SINGLE zterm INTO lv_zterm
    FROM knb1 WHERE kunnr = fu_kunnr
                AND bukrs = fu_bukrs.

  SELECT SINGLE ztag1 INTO lv_ztag1
    FROM t052 WHERE zterm = lv_zterm.

  lv_dudat = fu_postdate + lv_ztag1.

  CALL FUNCTION 'Z_GET_DATE_WORD'
    EXPORTING
      fi_date     = fu_postdate
      fi_langu    = 'i'
    IMPORTING
      fe_dateword = fu_tanggal.

*  CALL FUNCTION 'Z_GET_DATE_WORD'
*    EXPORTING
*      fi_date     = lv_dudat
*      fi_langu    = 'i'
*    IMPORTING
*      fe_dateword = fu_duedate.

  WRITE: fu_postdate TO fu_tanggal,
         lv_dudat    TO fu_duedate.
  CONDENSE: fu_tanggal,fu_duedate.
ENDFORM.                    " F_GET_TANGGAL

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_DTL_LINES
*&---------------------------------------------------------------------*
FORM f_append_dtl_lines  USING fu_bukrs
                               fu_gjahr
                               fu_invno.
  DATA: lt_itm     TYPE TABLE OF ty_itm WITH HEADER LINE,
        lv_ratetxt TYPE zratetxt,
        lv_norut   TYPE int1.

  LOOP AT gt_itm INTO gs_itm WHERE bukrs = fu_bukrs
                               AND gjahr = fu_gjahr
                               AND invno = fu_invno.
    CLEAR gt_zratetr001.
    READ TABLE gt_zratetr001 WITH KEY ratetyp = gs_itm-ratetyp.
*    CONCATENATE gs_itm-ratetyp gt_zratetr001-ratetxt
*      INTO lt_itm-itmdsc SEPARATED BY '-'.

    lt_itm-itmdsc = gt_zratetr001-ratetxt.
    lt_itm-amount = gs_itm-amount.
    lt_itm-waerk  = gs_itm-waerk.
    COLLECT lt_itm. CLEAR lt_itm.
  ENDLOOP.

  LOOP AT lt_itm.
    ADD 1 TO lv_norut.
    gs_detail-linno = lv_norut.
    gs_detail-pekerjaan = lt_itm-itmdsc.
    WRITE lt_itm-amount TO gs_detail-net_amount
      CURRENCY lt_itm-waerk.

    CONDENSE: gs_detail-linno, gs_detail-pekerjaan,gs_detail-net_amount.

    APPEND gs_detail TO gt_detail. CLEAR gs_detail.
  ENDLOOP.

  CONCATENATE 'Menunjuk:' fu_invno
    INTO gs_detail-pekerjaan SEPARATED BY space.
  CONDENSE gs_detail-pekerjaan.
  APPEND gs_detail TO gt_detail. CLEAR gs_detail.
ENDFORM.                    " F_APPEND_DTL_LINES

*&---------------------------------------------------------------------*
*&      Form  F_GET_TOTAL
*&---------------------------------------------------------------------*
FORM f_get_total  USING    fu_bukrs
                           fu_postdoc
                           fu_postyear
                           fu_net_amount
                           fu_waerk
                  CHANGING fc_jual
                           fc_diskon
                           fc_dpp
                           fc_ppn
                           fc_materai
                           fc_bayar
                           fc_says.
  DATA: lv_dmbtr LIKE bseg-dmbtr,
        lv_total LIKE bseg-dmbtr,
        ls_spell LIKE spell.

  SELECT SINGLE dmbtr INTO lv_dmbtr
    FROM bseg WHERE bukrs = fu_bukrs
                AND belnr = fu_postdoc
                AND gjahr = fu_postyear
                AND hkont IN ('315300210','0315300210').

  lv_total = fu_net_amount + lv_dmbtr.

  fc_diskon = fc_materai = '0'.
  WRITE fu_net_amount TO fc_jual
    CURRENCY fu_waerk.
  WRITE lv_dmbtr TO fc_ppn
    CURRENCY fu_waerk.
  WRITE lv_total TO fc_bayar
    CURRENCY fu_waerk.
  fc_dpp = fc_jual.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount   = lv_total
      currency = fu_waerk
*     FILLER   = ' '
      language = 'i'
    IMPORTING
      in_words = ls_spell.
  CONCATENATE ls_spell-word 'RUPIAH'
   INTO fc_says SEPARATED BY space.

  CALL FUNCTION 'STRING_UPPER_LOWER_CASE'
    EXPORTING
      delimiter = '/'
      string1   = fc_says
    IMPORTING
      string    = fc_says.

  CONDENSE: fc_jual,
            fc_diskon,
            fc_dpp,
            fc_ppn,
            fc_materai,
            fc_bayar,
            fc_says.
ENDFORM.                    " F_GET_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_PRINT
*&---------------------------------------------------------------------*
FORM f_print .
  DATA: lt_hdr  TYPE TABLE OF ty_hdr WITH HEADER LINE.

  lt_hdr[] = gt_hdr[].
**  DELETE lt_hdr WHERE fakturno IS INITIAL
**                  AND postdoc IS INITIAL.
  DELETE lt_hdr WHERE postdoc IS INITIAL.

  IF lt_hdr[] IS NOT INITIAL.
    LOOP AT lt_hdr ASSIGNING <fs_hdr>.
**      IF <fs_hdr>-postdate >= gs_coretax-datab.
**        CONTINUE.
**      ENDIF.

*      READ TABLE gt_zrevtr001 WITH KEY bukrs = <fs_hdr>-bukrs
*                                       gjahr = <fs_hdr>-gjahr
*                                       invno = <fs_hdr>-invno.
      gs_header-title       = 'FAKTUR PAJAK'.
      gs_header-bukrs       = <fs_hdr>-bukrs.   "gt_zrevtr001-bukrs.
      gs_header-invno       = <fs_hdr>-invno.   "gt_zrevtr001-invno.
      gs_header-bktxt       = <fs_hdr>-bktxt.   "gt_zrevtr001-bktxt.
      gs_header-sign        = 'K. LANNY LISTIYANI D'.
*      gs_header-sign        = 'ROSITA YUNIAR'.

      WRITE <fs_hdr>-fakturno TO gs_header-fakturno
                                  USING EDIT MASK '___.___-__.________'.

      PERFORM f_get_tanggal USING    <fs_hdr>-bukrs       "gt_zrevtr001-bukrs
                                     <fs_hdr>-kunnr       "gt_zrevtr001-kunnr
                                     <fs_hdr>-postdate    "gt_zrevtr001-postdate
                            CHANGING gs_header-tanggal
                                     gs_header-duedate.

      PERFORM f_get_addr_bukrs USING    gs_header-bukrs
                               CHANGING gs_header-butxt
                                        gs_header-street
                                        gs_header-city1
                                        gs_header-post_code1
                                        gs_header-stceg
                                        gs_header-tel_number
                                        gs_header-fax_number.

      PERFORM f_get_addr_kunnr USING    <fs_hdr>-kunnr    "gt_zrevtr001-kunnr
                               CHANGING gs_header-name1
                                        gs_header-xstreet
                                        gs_header-str_suppl2
                                        gs_header-xcity1
                                        gs_header-xpost_code1
                                        gs_header-xstceg.

      PERFORM f_append_dtl_lines USING <fs_hdr>-bukrs
                                       <fs_hdr>-gjahr
                                       <fs_hdr>-invno.

      PERFORM f_get_total USING    '8160'   "<fs_hdr>-bukrs
                                   <fs_hdr>-postdoc
                                   <fs_hdr>-postyear
                                   <fs_hdr>-net_amount
                                   <fs_hdr>-waerk
                          CHANGING gs_header-jual
                                   gs_header-diskon
                                   gs_header-dpp
                                   gs_header-ppn
                                   gs_header-materai
                                   gs_header-bayar
                                   gs_header-says.

* Print form
      PERFORM f_print_form USING <fs_hdr>-net_amount
                                 <fs_hdr>-waerk.
      CLEAR: gs_header,gs_detail,gt_detail.

    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_ALV2
*&---------------------------------------------------------------------*
FORM f_alv2  TABLES   ft_report1 ft_report2.
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
      i_tabname_header         = 'T_HDR'
      i_tabname_item           = 'T_ITM'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report1
      t_outtab_item            = ft_report2
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_ALV2

*---------------------------------------------------------------------*
*       FORM f_build_fieldcat_hierarchy                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat_hierarchy  TABLES ft_report1 ft_report2.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'T_HDR':
    'CHKBX' '' '' '' '1' '' '' '' '' '' '' '' '' '' '' '',
    'ICON' '' '' '' '10' 'Icon' '' '' '' '' '' '' '' '' '' '',
    'BUKRS' 'ZREVTR001' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZREVTR001' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
*    'LINNO' 'ZREVTR001' 'LINNO' '' '' '' '' '' '' '' '' '' '' '' '' ''.

  IF r1 = 'X'.
    PERFORM f_fieldcatg USING 'T_HDR':
      'POSTDATE' 'ZREVTR001' 'POSTDATE' '' '12' 'Invoice Date' '' '' '' '' '' '' '' '' 'X' '',
      'BKTXT' 'BKPF' 'BKTXT' '' '' 'Invoice No.' '' '' '' '' '' '' '' '' 'X' ''.
  ELSE.
    PERFORM f_fieldcatg USING 'T_HDR':
      'POSTDATE' 'ZREVTR001' 'POSTDATE' '' '12' 'Invoice Date' '' '' '' '' '' '' '' '' '' '',
      'BKTXT' 'BKPF' 'BKTXT' '' '' 'Invoice No.' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.

  PERFORM f_fieldcatg USING 'T_HDR':
    'INVNO' 'ZREVTR001' 'INVNO' '' '30' 'Pra Inv No.' '' '' '' '' '' '' '' '' '' '',
    'INVDT' 'ZREVTR001' 'INVDT' '' '12' 'Pra Inv Date' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZREVTR001' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NET_AMOUNT' 'ZREVTR001' 'NET_AMOUNT' '' '' '' '' '' '' '' '' 'WAERK' '' '' '' '',
    'WAERK' 'ZREVTR001' 'WAERK' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'POSTDOC' 'ZREVTR001' 'POSTDOC' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'POSTYEAR' 'ZREVTR001' 'POSTYEAR' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'POSTNAME' 'ZREVTR001' 'POSTNAME' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'POSTDATE' 'ZREVTR001' 'POSTDATE' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'FAKTURNO' 'ZREVTR001' 'FAKTURNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MSG' '' '' '' '50' 'Message' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'T_ITM':
    'LINNO' 'ZREVTR001' 'LINNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KOSTL' 'ZALOKTR02' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'RATETYP' 'ZREVTR001' 'RATETYP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'RATETXT' 'ZRATETR001' 'RATETXT' '' '50' '' '' '' '' '' '' '' '' '' '' '',
    'ZGRP' 'ZREVTR001' 'ZGRP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'FACTORY' 'ZREVTR001' 'FACTORY' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZQTY' 'ZREVTR001' 'ZQTY' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'REVTYP' 'ZREVTR001' 'REVTYP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZXREF' 'ZALOKTR02' 'ZXREF' '' '50' '' '' '' '' '' '' '' '' '' '' '',
    'ITMDSC' 'ZALOKTR02' 'ITMDSC' '' '50' '' '' '' '' '' '' '' '' '' '' '',
    'AMOUNT' 'ZALOKTR02' 'AMOUNT' '' '' 'Amount' 'X' '' '' '' '' 'WAERK' '' '' '' '',
    'WAERK' 'ZALOKTR02' 'WAERK' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SUBDT' 'ZREVTR001' 'SUBDT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'APRDT' 'ZREVTR001' 'APRDT' '' '' '' '' '' '' '' '' '' '' '' '' ''.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'T_HDR'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'T_ITM'
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
*  fu_layout-box_fieldname      = 'CHKBX'.
*  fu_layout-expand_fieldname   = 'EXPAND'.
  fu_layout-expand_all         = 'X'.

  IF gv_chkbx = 'X'.
    fu_layout-box_fieldname      = 'CHKBX'.
  ENDIF.
ENDFORM.                    "f_build_layout_hierarchy

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo_hierarchy                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo_hierarchy  USING fu_keyinfo TYPE slis_keyinfo_alv.
  fu_keyinfo-header01 = 'BUKRS'.
  fu_keyinfo-item01   = 'BUKRS'.

  fu_keyinfo-header01 = 'GJAHR'.
  fu_keyinfo-item01   = 'GJAHR'.

*  fu_keyinfo-header01 = 'LINNO'.
*  fu_keyinfo-item01   = 'LINNO'.

  fu_keyinfo-header01 = 'INVNO'.
  fu_keyinfo-item01   = 'INVNO'.
ENDFORM.                    " f_build_keyinfo_hierarchy

*---------------------------------------------------------------------*
*       FORM f_build_sortfield_hierarchy                              *
*---------------------------------------------------------------------*
FORM f_build_sortfield_hierarchy  USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'OCHDN'.
*  ld_sort-tabname   = 'T_POSHDR'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'OCDLNID'.
*  ld_sort-tabname   = 'T_POS'.
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
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'SEQTYP'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'SEQNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

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

  CASE 'X'.
    WHEN r1.
      APPEND '&CAN'   TO fcode.
      APPEND '&FORM'  TO fcode.
      APPEND '&FP'    TO fcode.
      APPEND '&LOG'   TO fcode.
    WHEN r5.
      APPEND '&SIM'   TO fcode.
      APPEND '&POS'   TO fcode.
      APPEND '&CAN'   TO fcode.
      APPEND '&FORM'  TO fcode.
    WHEN r2.
      APPEND '&SIM'   TO fcode.
      APPEND '&POS'   TO fcode.
      APPEND '&CAN'   TO fcode.
      APPEND '&FP'    TO fcode.
      APPEND '&LOG'   TO fcode.
    WHEN r3.
      APPEND '&SIM'   TO fcode.
      APPEND '&POS'   TO fcode.
      APPEND '&FORM'  TO fcode.
      APPEND '&FP'    TO fcode.
      APPEND '&LOG'   TO fcode.
    WHEN r4.
      APPEND '&SIM'   TO fcode.
      APPEND '&POS'   TO fcode.
      APPEND '&CAN'   TO fcode.
      APPEND '&FORM'  TO fcode.
      APPEND '&FP'    TO fcode.
      APPEND '&LOG'   TO fcode.
  ENDCASE.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA : lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA : lv_lines       TYPE i.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&SIM'.
      PERFORM f_posting USING fu_ucomm.
      fu_selfield-refresh = 'X'.

    WHEN '&FP'.
      PERFORM f_proses_fp.
      fu_selfield-refresh = 'X'.

    WHEN '&LOG'.
      DESCRIBE TABLE gt_bapiret2 LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO gt_bapiret2.
      ENDIF.

      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_bapiret2.

    WHEN '&POS'.
      PERFORM f_posting USING fu_ucomm.
      PERFORM f_proses_faktur_pajak.
      PERFORM f_print.
      fu_selfield-refresh = 'X'.

    WHEN '&CAN'.
      PERFORM f_reverse_invoice.

    WHEN '&FORM'.
      PERFORM f_reprint.
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
*&      Form  F_MOVE_HEADER
*&---------------------------------------------------------------------*
FORM f_move_header  USING    fu_net fu_waerk
                    CHANGING fc_header STRUCTURE ztntsdstf0001h.

  DATA: ls_11    TYPE zproject,
        ls_12    TYPE zproject,
        lr_datum TYPE RANGE OF datum,
        ls_datum LIKE LINE OF lr_datum,
        lv_budat TYPE sy-datum,
        lv_wrbtr TYPE bseg-wrbtr.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF ls_11
    WHERE name = 'PPN11'
      AND flag = 'X'.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF ls_12
    WHERE name = 'PPN12'
      AND flag = 'X'.

  ls_datum-low    = ls_11-datab.
  ls_datum-high   = ls_12-datab.
  ls_datum-sign   = 'I'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO lr_datum.

  fc_header-title     = 'FAKTUR'.
  fc_header-xblnr     = gs_header-bktxt.
  fc_header-fakno     = gs_header-fakturno.
  fc_header-bstkd     = '-'.
  fc_header-bstdk     = '-'.
  fc_header-spno      = '-'.
  fc_header-bldat     = '-'.
  fc_header-ztag1     = '30'.
  fc_header-dudat     = gs_header-duedate.
  fc_header-name1_ag  = fc_header-name1_rg  = gs_header-name1.
  fc_header-addr1_ag  = fc_header-addr1_rg  = gs_header-xstreet.
  fc_header-addr2_ag  = fc_header-addr2_rg  = gs_header-str_suppl2.
  fc_header-addr3_ag  = fc_header-addr3_rg  = gs_header-xcity1.
  fc_header-addr4_ag  = fc_header-addr4_rg  = gs_header-xpost_code1.
  fc_header-stceg_ag  = fc_header-stceg_rg  = gs_header-xstceg.
  fc_header-harga_jual = gs_header-jual.
  fc_header-disc_val  = '-'. "gs_header-diskon.
  fc_header-uang_muka = '-'.
  fc_header-dpp       = gs_header-dpp.
  fc_header-ppn       = gs_header-ppn.
  fc_header-materai   = '-'.
  fc_header-nilai_fak = gs_header-bayar.
  fc_header-terbilang = gs_header-says.
  fc_header-budat     = gs_header-tanggal.
  fc_header-vbeln     = <fs_hdr>-postdoc.
  fc_header-nameadm   = gs_header-sign.
  fc_header-jabatadm  = 'FINANCE MANAGER'.

  CONCATENATE gs_header-tanggal+6(4) gs_header-tanggal+3(2)
              gs_header-tanggal(2)
  INTO lv_budat.

  IF lv_budat > gs_dpp-datab.
    fc_header-ppncd     = '00'.
    lv_wrbtr = fu_net * 11 / 12.
    WRITE lv_wrbtr TO fc_header-dpp CURRENCY fu_waerk.
    CONDENSE fc_header-dpp NO-GAPS.
  ELSE.
    IF lv_budat IN gr_coretax.
      fc_header-ppncd     = '00'.
    ELSE.
      IF lv_budat IN lr_datum.
        fc_header-ppncd     = '11'.
      ELSEIF lv_budat > ls_12-datab.
        fc_header-ppncd     = '12'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MOVE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_DETAIL
*&---------------------------------------------------------------------*
FORM f_move_detail  TABLES   ft_detail STRUCTURE ztntsdstf0001d.
  DATA: ld_count TYPE int4.

  LOOP AT gt_detail INTO gs_detail.
    ADD 1 TO ld_count.
    IF ld_count = 1.
      APPEND INITIAL LINE TO ft_detail.
    ENDIF.

    ft_detail-norut   = gs_detail-linno.
    ft_detail-maktx   = gs_detail-pekerjaan.
    ft_detail-jumlah  = gs_detail-net_amount.
    APPEND ft_detail.

    IF ld_count GE 10.
      CLEAR ld_count.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MOVE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_FP
*&---------------------------------------------------------------------*
FORM f_proses_fp .
  DATA: lt_bkpf  TYPE TABLE OF bkpf WITH HEADER LINE,
        lt_hdr   TYPE TABLE OF ty_hdr WITH HEADER LINE,
        ls_error TYPE bapiret2.

  CLEAR gt_bapiret2[].

  lt_hdr[] = gt_hdr[].
  DELETE lt_hdr WHERE fakturno IS NOT INITIAL.

  IF lt_hdr[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr blart bldat budat monat
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf
      FROM bkpf FOR ALL ENTRIES IN lt_hdr
      WHERE bukrs = '8160'
        AND belnr = lt_hdr-postdoc
        AND gjahr = lt_hdr-postyear.

    SORT: gt_hdr BY bukrs postdoc postyear,
          lt_hdr BY bukrs postdoc postyear,
          lt_bkpf BY bukrs belnr gjahr.

    LOOP AT lt_hdr ASSIGNING <fs_hdr>.
      CLEAR lt_bkpf.
      READ TABLE lt_bkpf WITH KEY bukrs = '8160'
                                  belnr = <fs_hdr>-postdoc
                                  gjahr = <fs_hdr>-postyear
                                  BINARY SEARCH.

      PERFORM f_process_non_trade(zgdfi_e0001) USING    lt_bkpf-bukrs
                                                        lt_bkpf-belnr
                                                        lt_bkpf-monat
                                                        lt_bkpf-gjahr
                                               CHANGING <fs_hdr>-fakturno.

      IF <fs_hdr>-fakturno IS NOT INITIAL.
        gt_zrevtr001-fakturno_tnt = <fs_hdr>-fakturno.
        MODIFY gt_hdr FROM <fs_hdr>
                      TRANSPORTING fakturno
                      WHERE bukrs = <fs_hdr>-bukrs
                        AND gjahr = <fs_hdr>-gjahr
                        AND invno = <fs_hdr>-invno.

        MODIFY gt_zrevtr001 TRANSPORTING fakturno_tnt
                             WHERE bukrs = <fs_hdr>-bukrs
                               AND gjahr = <fs_hdr>-gjahr
                               AND invno = <fs_hdr>-invno.

        UPDATE zrevtr001 SET fakturno_tnt = <fs_hdr>-fakturno
                         WHERE bukrs = <fs_hdr>-bukrs
                           AND gjahr = <fs_hdr>-gjahr
                           AND invno = <fs_hdr>-invno.
      ELSE.
        ls_error-type       = 'E'.
        ls_error-id         = 'ZAB'.
        ls_error-number     = '000'.
        ls_error-message_v1 = 'Invoice'.
        ls_error-message_v2 = <fs_hdr>-invno.
        ls_error-message_v3 = 'No. FP belum ada di CORETAX'.
        APPEND ls_error TO gt_bapiret2.
        CLEAR ls_error.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CORETAX_VALIDATE
*&---------------------------------------------------------------------*
FORM f_coretax_validate .
  DATA : ls_project TYPE zproject,
         ls_coretax LIKE LINE OF gr_coretax.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'CORETAX'.
  ls_coretax-low = ls_project-datab.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'ZGDCORETAX'.
  ls_coretax-high   = ls_project-datab.
  ls_coretax-sign   = 'I'.
  ls_coretax-option = 'BT'.
  APPEND ls_coretax TO gr_coretax.
ENDFORM.
