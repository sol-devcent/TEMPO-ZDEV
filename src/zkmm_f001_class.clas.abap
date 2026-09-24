CLASS zkmm_f001_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: lo_alv    TYPE REF TO cl_salv_table.
    TYPES: tt_matnr TYPE RANGE OF afpo-matnr,
           tt_datum TYPE RANGE OF caufv-gstrp.
*    TYPES: tt_result TYPE TABLE OF zkmm_v01 WITH EMPTY KEY.
*    DATA: gt_result TYPE tt_result.
    DATA: gt_result TYPE ztt_zkmm_f001.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
    METHODS:
      on_checkbox_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
    METHODS: run
        IMPORTING s_matnr TYPE tt_matnr
                  p_werks TYPE werks_d
                  s_datum TYPE tt_datum
*                  p_uname TYPE sy-uname
                  lv_program TYPE sy-cprog
        RETURNING VALUE(lv_message) TYPE string.


  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: get_data
      IMPORTING s_matnr          TYPE tt_matnr
                p_werks          TYPE werks_d
                s_datum          TYPE tt_datum
*                p_uname          TYPE sy-uname
      RETURNING VALUE(gt_result) TYPE ztt_zkmm_f001."tt_result.
    METHODS: process_data
        CHANGING gt_result TYPE ztt_zkmm_f001.
    METHODS: prepare
      CHANGING gt_result TYPE ztt_zkmm_f001."tt_result.
    METHODS: report_layout
      IMPORTING lv_program TYPE sy-cprog.
    METHODS: display.
    METHODS: print_form
      IMPORTING lv_formname TYPE ssfscreen-fname
                gt_result   TYPE ztt_zkmm_f001."tt_result.
ENDCLASS.



CLASS ZKMM_F001_CLASS IMPLEMENTATION.


  METHOD display.
    IF lo_alv IS BOUND.
      lo_alv->display( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_data.
    IF p_werks = '3600'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_result FROM zkmm_v01( p_werks = @p_werks )", p_uname = @p_uname )
    WHERE product_fg IN @s_matnr
    AND gstrp IN @s_datum.
    ELSEIF p_werks = '0101' OR p_werks = '0102'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_result FROM zkmm_v02( p_werks = @p_werks )", p_uname = @p_uname )
    WHERE product_fg IN @s_matnr
    AND gstrp IN @s_datum.
    ENDIF.
  ENDMETHOD.


  METHOD on_checkbox_click.

  ENDMETHOD.


  METHOD on_user_command.
    CASE e_salv_function.
      WHEN '&PREV'.
        me->print_form( gt_result = gt_result lv_formname = 'ZKMM_SF001_NEW' ).
    ENDCASE.
  ENDMETHOD.


  METHOD prepare.
    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_alv
          CHANGING  t_table    = gt_result[] ).
      CATCH cx_salv_msg.
    ENDTRY.
    DATA(lo_alv_events) = lo_alv->get_event( ).
    SET HANDLER me->on_checkbox_click FOR lo_alv_events.
    SET HANDLER me->on_user_command FOR lo_alv_events.
  ENDMETHOD.


  METHOD print_form.
    DATA: fc_funcmod TYPE rs38l_fnam.
    DATA: d_ctrl_param TYPE ssfctrlop,
          d_output_opt TYPE ssfcompop.
    DATA(gs_header) = gt_result[ 1 ].
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = lv_formname
      IMPORTING
        fm_name            = fc_funcmod
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc = 0.
      CALL FUNCTION fc_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          gs_header          = gs_header
        TABLES
          gt_result          = gt_result[]
*         wa_hd              = wa_hd
*                               TABLES
*         i_dt               = i_dt.
        .
    ENDIF.


  ENDMETHOD.


  METHOD process_data.
    DATA: lv_nomor TYPE i.
    SORT gt_result BY werks aufnr gstrp rsnum bdter product_fg charg mblnr budat.
    DELETE ADJACENT DUPLICATES FROM gt_result COMPARING werks aufnr gstrp rsnum bdter product_fg charg mblnr budat.
    LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      ADD 1 TO lv_nomor.
      <fs_result>-nomor = lv_nomor.
    ENDLOOP.
  ENDMETHOD.


    METHOD report_layout.
      DATA(lo_columns) = lo_alv->get_columns( ).
      TRY.
          DATA(lo_col_mandt) = lo_columns->get_column( 'MANDT' ).
          lo_col_mandt->set_visible( abap_false ).

          DATA(lo_col_name1) = lo_columns->get_column( 'NAME1' ).
          lo_col_name1->set_visible( abap_false ).

*          DATA(lo_col_gstrp) = lo_columns->get_column( 'GSTRP' ).
*          lo_col_gstrp->set_visible( abap_false ).

          DATA(lo_column_werks) = CAST cl_salv_column_table( lo_columns->get_column( 'WERKS' ) ).
          lo_column_werks->set_long_text( 'Plant' ).
          lo_column_werks->set_medium_text( 'Plant' ).
          lo_column_werks->set_short_text( 'Plant' ).

          DATA(lo_column_nomor) = CAST cl_salv_column_table( lo_columns->get_column( 'NOMOR' ) ).
          lo_column_nomor->set_long_text( 'No' ).
          lo_column_nomor->set_medium_text( 'No' ).
          lo_column_nomor->set_short_text( 'No' ).
          lo_column_nomor->set_output_length( 3 ).

          DATA(lo_column_aufnr) = CAST cl_salv_column_table( lo_columns->get_column( 'AUFNR' ) ).
          lo_column_aufnr->set_long_text( 'PrO' ).
          lo_column_aufnr->set_medium_text( 'PrO' ).
          lo_column_aufnr->set_short_text( 'PrO' ).


          DATA(lo_column_gstrp) = CAST cl_salv_column_table( lo_columns->get_column( 'GSTRP' ) ).
          lo_column_gstrp->set_long_text( 'Basic Start Date' ).
          lo_column_gstrp->set_medium_text( 'Basic Start Date' ).
          lo_column_gstrp->set_short_text( 'BS Date' ).

          DATA(lo_column_rsnum) = CAST cl_salv_column_table( lo_columns->get_column( 'RSNUM' ) ).
          lo_column_rsnum->set_long_text( 'Reservation No.' ).
          lo_column_rsnum->set_medium_text( 'Reservation No.' ).
          lo_column_rsnum->set_short_text( 'Reserv No.' ).

          DATA(lo_column_bdter) = CAST cl_salv_column_table( lo_columns->get_column( 'BDTER' ) ).
          lo_column_bdter->set_long_text( 'MR Date' ).
          lo_column_bdter->set_medium_text( 'MR Date' ).
          lo_column_bdter->set_short_text( 'MR Date' ).

          DATA(lo_column_sgtxt) = CAST cl_salv_column_table( lo_columns->get_column( 'SGTXT' ) ).
          lo_column_sgtxt->set_long_text( 'MR Status' ).
          lo_column_sgtxt->set_medium_text( 'MR Status' ).
          lo_column_sgtxt->set_short_text( 'MR Status' ).
          lo_column_sgtxt->set_output_length( 3 ).

          DATA(lo_column_fg) = CAST cl_salv_column_table( lo_columns->get_column( 'PRODUCT_FG' ) ).
          lo_column_fg->set_long_text( 'Product FG' ).
          lo_column_fg->set_medium_text( 'Product FG' ).
          lo_column_fg->set_short_text( 'Product FG' ).

          DATA(lo_column_charg) = CAST cl_salv_column_table( lo_columns->get_column( 'CHARG' ) ).
          lo_column_charg->set_long_text( 'Batch' ).
          lo_column_charg->set_medium_text( 'Batch' ).
          lo_column_charg->set_short_text( 'Batch' ).

*          DATA(lo_column_matnr) = CAST cl_salv_column_table( lo_columns->get_column( 'MATNR' ) ).
*          lo_column_matnr->set_long_text( 'Material' ).
*          lo_column_matnr->set_medium_text( 'Material' ).
*          lo_column_matnr->set_short_text( 'Material' ).

          DATA(lo_column_maktx) = CAST cl_salv_column_table( lo_columns->get_column( 'MAKTX' ) ).
          lo_column_maktx->set_long_text( 'Material Description' ).
          lo_column_maktx->set_medium_text( 'Material Description' ).
          lo_column_maktx->set_short_text( 'Mat Desc' ).

          DATA(lo_column_mblnr) = CAST cl_salv_column_table( lo_columns->get_column( 'MBLNR' ) ).
          lo_column_mblnr->set_long_text( 'TSS No.' ).
          lo_column_mblnr->set_medium_text( 'TSS No.' ).
          lo_column_mblnr->set_short_text( 'TSS No' ).

          DATA(lo_column_budat) = CAST cl_salv_column_table( lo_columns->get_column( 'BUDAT' ) ).
          lo_column_budat->set_long_text( 'TSS Date' ).
          lo_column_budat->set_medium_text( 'TSS Date' ).
          lo_column_budat->set_short_text( 'TSS Dt' ).

*          DATA(lo_column_bdmng) = CAST cl_salv_column_table( lo_columns->get_column( 'BDMNG' ) ).
*          lo_column_bdmng->set_long_text( 'Quantity' ).
*          lo_column_bdmng->set_medium_text( 'Quantity' ).
*          lo_column_bdmng->set_short_text( 'Quantity' ).
*
*          DATA(lo_column_meins) = CAST cl_salv_column_table( lo_columns->get_column( 'MEINS' ) ).
*          lo_column_meins->set_long_text( 'UoM' ).
*          lo_column_meins->set_medium_text( 'UoM' ).
*          lo_column_meins->set_short_text( 'UoM' ).
        CATCH cx_salv_not_found.
      ENDTRY.

      lo_alv->set_screen_status(
       pfstatus      = 'STANDARD'
       report        = lv_program"sy-repid
       set_functions = lo_alv->c_functions_all ).
    ENDMETHOD.


  METHOD run.

    IF p_werks IS NOT INITIAL. "AND p_uname IS NOT INITIAL.
      gt_result = me->get_data( s_matnr = s_matnr p_werks = p_werks s_datum = s_datum )."p_uname = p_uname ).
      IF gt_result[] IS NOT INITIAL.
        me->process_data( CHANGING gt_result = gt_result[] ).
        IF gt_result[] IS NOT INITIAL.
          me->prepare( CHANGING gt_result = gt_result[] ).
          me->report_layout( lv_program = lv_program ).
          me->display(  ).
        ELSE.
          lv_message = 'No Data'.
      ENDIF.
    ELSE.
      lv_message = 'No Data'.
    ENDIF.
  ELSE.
    lv_message = 'Missing parameters'.
  ENDIF.
ENDMETHOD.
ENDCLASS.
