*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_zihqmr003 DEFINITION.

  PUBLIC SECTION.
    CLASS-DATA: lo_alv    TYPE REF TO cl_salv_table.
    TYPES: BEGIN OF ty_main,
             icon(4),
             werks    TYPE mchb-werks,
             matnr    TYPE mchb-matnr,
             maktx    TYPE makt-maktx,
             charg    TYPE mchb-charg,
             lgort    TYPE mchb-lgort,
             clabs    TYPE mchb-clabs,
             slabs    TYPE mkol-slabs,
             lblab    TYPE mslb-lblab,
             ceinm    TYPE mchb-ceinm,
             cspem    TYPE mchb-cspem,
             seinm    TYPE mkol-seinm,
             sspem    TYPE mkol-sspem,
             cinsm    TYPE mchb-cinsm,
             sinsm    TYPE mkol-sinsm,
             lbins    TYPE mslb-lbins,
             lbein    TYPE mslb-lbein,
             ersda    TYPE mchb-ersda,
             meins    TYPE mara-meins,
             qndat    TYPE mcha-qndat,
             vfdat    TYPE mch1-vfdat,
             qnday    TYPE int4,
             xlabs    TYPE mchb-clabs,
             text(30),
             note     TYPE dfbatch-kztxt,
           END OF ty_main.

    TYPES: BEGIN OF ty_matnr,
             matnr TYPE mara-matnr,
             meins TYPE mara-meins,
           END OF ty_matnr.

    TYPES: BEGIN OF ty_mcha,
             matnr TYPE mcha-matnr,
             werks TYPE mcha-werks,
             charg TYPE mcha-charg,
             qndat TYPE mcha-qndat,
             vfdat TYPE mch1-vfdat,
           END OF ty_mcha.
    TYPES: BEGIN OF ty_mseg,
             mblnr  TYPE mseg-mblnr,
             mjahr  TYPE mseg-mjahr,
             zeile  TYPE mseg-zeile,
             matnr  TYPE mseg-matnr,
             lgort  TYPE mseg-lgort,
             charg  TYPE mseg-charg,
             tcode2 TYPE mkpf-tcode2,
             cpudt  TYPE mkpf-cpudt,
           END OF ty_mseg.
    TYPES: tt_matnr TYPE RANGE OF matnr,
           tt_datab TYPE RANGE OF kodatab.
    TYPES: tt_datum TYPE RANGE OF datum.
    CLASS-DATA: iv_werks TYPE koth700-werks,
                iv_mtart TYPE koth700-mtart,
                is_matnr TYPE tt_matnr,
                is_date  TYPE tt_datab,
                is_date1 TYPE tt_datab,
                iv_vari  TYPE disvariant-variant,
                iv_rad01 TYPE char1,
                iv_rad02 TYPE char1.
    CLASS-DATA: t_main  TYPE TABLE OF ty_main WITH EMPTY KEY,
                t_matnr TYPE TABLE OF ty_matnr WITH EMPTY KEY,
                t_mcha  TYPE TABLE OF ty_mcha WITH EMPTY KEY,
                t_mseg  TYPE TABLE OF ty_mseg WITH EMPTY KEY.
    METHODS: constructor
      IMPORTING p_werks TYPE koth700-werks
                p_mtart TYPE koth700-mtart
                s_matnr TYPE tt_matnr
                s_date  TYPE tt_datab
                s_date1 TYPE tt_datab
                p_vari  TYPE disvariant-variant
                p_rad01 TYPE char1
                p_rad02 TYPE char1.
    METHODS: run
      IMPORTING lv_program TYPE sy-cprog
                title_name TYPE sy-title
                id TYPE sy-sysid
                mandt TYPE sy-mandt
                datum TYPE sy-datum
                username TYPE sy-uname
                uzeit TYPE sy-uzeit.
    CLASS-METHODS: init_data
      IMPORTING rad01          TYPE char1
                rad02          TYPE char1
                date           TYPE tt_datab
                date1          TYPE tt_datab
      RETURNING VALUE(gr_date) TYPE tt_datum.
    CLASS-METHODS: get_note
      IMPORTING lv_matnr TYPE matnr
                lv_charg TYPE charg_d.
    CLASS-METHODS: prepare.
    CLASS-METHODS: pf_status
      IMPORTING lv_program TYPE sy-cprog .
    CLASS-METHODS: top_of_page
      IMPORTING title_name TYPE sy-title
                program_name TYPE sy-cprog
                id TYPE sy-sysid
                mandt TYPE sy-mandt
                datum TYPE sy-datum
                username TYPE sy-uname
                uzeit TYPE sy-uzeit.
    CLASS-METHODS: report_layout
      IMPORTING rad01 TYPE char1
                rad02 TYPE char1
                werks TYPE koth700-werks.
    CLASS-METHODS: sort_fields.
    CLASS-METHODS: display.
    CLASS-METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
    CLASS-METHODS:
      on_checkbox_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS: get_data
      IMPORTING werks   TYPE koth700-werks
                mtart   TYPE koth700-mtart
                matnr   TYPE tt_matnr
                date    TYPE tt_datab
                date1   TYPE tt_datab
*                vari    TYPE disvariant-variant
                rad01   TYPE char1
                rad02   TYPE char1
                gr_date TYPE tt_datum.
    CLASS-METHODS: process_rad02
      IMPORTING werks TYPE koth700-werks.
    CLASS-METHODS: validate_data
      IMPORTING werks TYPE koth700-werks
                rad01 TYPE char1
                rad02 TYPE char1.
    CLASS-METHODS: get_t001w
    RETURNING VALUE(ls_t001w) TYPE t001w.
ENDCLASS.

CLASS lcl_zihqmr003 IMPLEMENTATION.
  METHOD on_user_command.

  ENDMETHOD.
  METHOD on_checkbox_click.

  ENDMETHOD.
  METHOD constructor.
    iv_werks = p_werks.
    iv_mtart = p_mtart.
    is_matnr = s_matnr[].
    is_date = s_date[].
    is_date1 = s_date1[].
    iv_vari = p_vari.
    iv_rad01 = p_rad01.
    iv_rad02 = p_rad02.
  ENDMETHOD.
  METHOD run.
    DATA: gr_date TYPE RANGE OF datum.
    gr_date = init_data( rad01 = iv_rad01 rad02 = iv_rad02 date = is_date date1 = is_date1 ).
    get_data( werks = iv_werks mtart = iv_mtart matnr = is_matnr
    date = is_date date1 = is_date1 gr_date = gr_date
    rad01 = iv_rad01 rad02 = iv_rad02
    ).
    validate_data( rad01 = iv_rad01 rad02 = iv_rad02 werks = iv_werks ).
    prepare(  ).
    pf_status(  lv_program = lv_program ).
    top_of_page( title_name = title_name program_name = lv_program datum = datum id = id mandt = mandt username = username uzeit = uzeit ).
    report_layout( rad01 = iv_rad01 rad02 = iv_rad02 werks = iv_werks ).
    sort_fields(  ).
    display(  ).
  ENDMETHOD.
  METHOD prepare.
    DATA: lo_layout TYPE REF TO cl_salv_layout,
          ls_key    TYPE salv_s_layout_key.
    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_alv
          CHANGING  t_table    = t_main[] ).
      CATCH cx_salv_msg.
    ENDTRY.

    lo_layout = lo_alv->get_layout( ).
    ls_key-report = sy-repid.
    lo_layout->set_key( ls_key ).
    lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

    IF iv_vari IS NOT INITIAL.
      lo_layout->set_initial_layout( iv_vari ).
    ENDIF.
    DATA(lo_alv_events) = lo_alv->get_event( ).
    SET HANDLER on_checkbox_click FOR lo_alv_events.
    SET HANDLER on_user_command FOR lo_alv_events.
  ENDMETHOD.
  METHOD pf_status.
      lo_alv->set_screen_status(
           pfstatus      = 'STANDARD'
           report        = lv_program "sy-repid
           set_functions = lo_alv->c_functions_all ).
  ENDMETHOD.
  METHOD top_of_page.
    DATA: lo_header TYPE REF TO cl_salv_form_layout_grid,
          lo_column TYPE REF TO cl_salv_form_grid_column.
    DATA: title   TYPE char70,
          period  TYPE char70,
          date1   TYPE char10,
          dateh   TYPE char10,
          werks   TYPE char40,
          program TYPE char100,
          client  TYPE char100,
          user    TYPE char50.

    lo_header = NEW #( ).
    CONCATENATE 'Program: ' program_name INTO program SEPARATED BY space.
    lo_header->create_text( row = 1 column = 1 text = program ).

    CONCATENATE title_name iv_mtart INTO title SEPARATED BY space.
    lo_header->create_text( row = 1 column = 2 text = title ).

    DATA(lv_mandt) = |({ mandt })|.
    CONCATENATE 'Client: ' id lv_mandt INTO client SEPARATED BY space.
    lo_header->create_text( row = 2 column = 1 text = client ).

    DATA(ls_t001w) = get_t001w(  ).
    CONCATENATE 'Plant' iv_werks '-' ls_t001w-name1 INTO werks SEPARATED BY space.
    lo_header->create_text( row = 2 column = 2 text = werks ).

    lo_header->create_text( row = 2 column = 3 text = datum ).

    CONCATENATE 'User: ' username INTO user  SEPARATED BY space.
    lo_header->create_text( row = 3 column = 1 text = user ).
    IF iv_rad01 = 'X'.
      WRITE is_date[ 1 ]-low TO date1 DD/MM/YYYY.
      WRITE is_date[ 1 ]-high TO dateh DD/MM/YYYY.
      CONCATENATE 'Next Inspection Date' date1 'to' dateh INTO period
                  SEPARATED BY space.
      lo_header->create_text( row = 3 column = 2 text = period ).
    ENDIF.

    IF iv_rad02 = 'X'.
      WRITE is_date1[ 1 ]-low TO date1 DD/MM/YYYY.
      WRITE is_date1[ 1 ]-high TO dateh DD/MM/YYYY.
      CONCATENATE 'Expiration Date' date1 'to' dateh INTO period
                  SEPARATED BY space.
      lo_header->create_text( row = 3 column = 2 text = period ).
    ENDIF.
    lo_header->create_text( row = 3 column = 3 text = uzeit ).

    lo_alv->set_top_of_list( lo_header ).

  ENDMETHOD.
  METHOD report_layout.
    DATA(lo_columns) = lo_alv->get_columns( ).
    TRY.
        DATA(lo_col_werks) = lo_columns->get_column( 'WERKS' ).
        lo_col_werks->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_slabs) = lo_columns->get_column( 'SLABS' ).
        lo_col_slabs->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_lblab) = lo_columns->get_column( 'LBLAB' ).
        lo_col_lblab->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_seinm) = lo_columns->get_column( 'SEINM' ).
        lo_col_seinm->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_sspem) = lo_columns->get_column( 'SSPEM' ).
        lo_col_sspem->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_cinsm) = lo_columns->get_column( 'CINSM' ).
        lo_col_cinsm->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_sinsm) = lo_columns->get_column( 'SINSM' ).
        lo_col_sinsm->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_lbins) = lo_columns->get_column( 'LBINS' ).
        lo_col_lbins->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_lbein) = lo_columns->get_column( 'LBEIN' ).
        lo_col_lbein->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_ersda) = lo_columns->get_column( 'ERSDA' ).
        lo_col_ersda->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_qnday) = CAST cl_salv_column_table( lo_columns->get_column( 'QNDAY' ) ).
        lo_col_qnday->set_long_text( 'Days' ).
        lo_col_qnday->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_xlabs) = CAST cl_salv_column_table( lo_columns->get_column( 'XLABS' ) ).
        lo_col_xlabs->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_icon) = CAST cl_salv_column_table( lo_columns->get_column( 'ICON' ) ).
        lo_column_icon->set_long_text( 'Icon' ).
        lo_column_icon->set_medium_text( 'Icon' ).
        lo_column_icon->set_short_text( 'Icon' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_matnr) = CAST cl_salv_column_table( lo_columns->get_column( 'MATNR' ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_maktx) = CAST cl_salv_column_table( lo_columns->get_column( 'MAKTX' ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_charg) = CAST cl_salv_column_table( lo_columns->get_column( 'CHARG' ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_lgort) = CAST cl_salv_column_table( lo_columns->get_column( 'LGORT' ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_clabs) = CAST cl_salv_column_table( lo_columns->get_column( 'CLABS' ) ).
        lo_column_clabs->set_quantity_column( 'MEINS' ).
        lo_column_clabs->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

    IF rad02 IS NOT INITIAL.
      TRY.
          DATA(lo_column_ceinm) = CAST cl_salv_column_table( lo_columns->get_column( 'CEINM' ) ).
          lo_column_ceinm->set_quantity_column( 'MEINS' ).
          lo_column_ceinm->set_sign( abap_true ).
        CATCH cx_salv_data_error.
        CATCH cx_salv_not_found.
      ENDTRY.
      IF werks = '2300'.
        TRY.
            DATA(lo_column_cspem) = CAST cl_salv_column_table( lo_columns->get_column( 'CSPEM' ) ).
            lo_column_cspem->set_quantity_column( 'MEINS' ).
            lo_column_cspem->set_sign( abap_true ).
          CATCH cx_salv_data_error.
          CATCH cx_salv_not_found.
        ENDTRY.
      ELSE.
        TRY.
            DATA(lo_col_cspem) = CAST cl_salv_column_table( lo_columns->get_column( 'CSPEM' ) ).
            lo_col_cspem->set_visible( abap_false ).
            lo_col_cspem->set_quantity_column( 'MEINS' ).
            lo_col_cspem->set_sign( abap_true ).
          CATCH cx_salv_data_error.
          CATCH cx_salv_not_found.
        ENDTRY.
      ENDIF.
    ELSE.
      TRY.
          DATA(lo_col_ceinm) = CAST cl_salv_column_table( lo_columns->get_column( 'CEINM' ) ).
          lo_col_ceinm->set_visible( abap_false ).
          lo_col_ceinm->set_quantity_column( 'MEINS' ).
          lo_col_ceinm->set_sign( abap_true ).
        CATCH cx_salv_data_error.
        CATCH cx_salv_not_found.
      ENDTRY.
      TRY.
          lo_col_cspem = CAST cl_salv_column_table( lo_columns->get_column( 'CSPEM' ) ).
          lo_col_cspem->set_visible( abap_false ).
          lo_col_cspem->set_quantity_column( 'MEINS' ).
          lo_col_cspem->set_sign( abap_true ).
        CATCH cx_salv_data_error.
        CATCH cx_salv_not_found.
      ENDTRY.
    ENDIF.
    TRY.
        DATA(lo_column_meins) = CAST cl_salv_column_table( lo_columns->get_column( 'MEINS' ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_qndat) = CAST cl_salv_column_table( lo_columns->get_column( 'QNDAT' ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_vfdat) = CAST cl_salv_column_table( lo_columns->get_column( 'VFDAT' ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_text) = CAST cl_salv_column_table( lo_columns->get_column( 'TEXT' ) ).
        lo_column_text->set_long_text( 'Comments' ).
        lo_column_text->set_medium_text( 'Comments' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_note) = CAST cl_salv_column_table( lo_columns->get_column( 'NOTE' ) ).
        lo_column_note->set_long_text( 'Note' ).
        lo_column_note->set_medium_text( 'Note' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    DATA(lo_aggregations_clabs) = lo_alv->get_aggregations( ).

    TRY.
        lo_aggregations_clabs->add_aggregation(
          columnname  = 'CLABS'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.

    DATA(lo_aggregations_ceinm) = lo_alv->get_aggregations( ).

    TRY.
        lo_aggregations_ceinm->add_aggregation(
          columnname  = 'CEINM'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.

    DATA(lo_aggregations_cspem) = lo_alv->get_aggregations( ).

    TRY.
        lo_aggregations_cspem->add_aggregation(
          columnname  = 'CSPEM'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.

  ENDMETHOD.
  METHOD sort_fields.
    DATA(lo_sorts) = lo_alv->get_sorts( ).

    TRY.

        lo_sorts->add_sort(
          columnname = 'QNDAY'
          position   = 1
          sequence   = if_salv_c_sort=>sort_up
          subtotal   = abap_false ).


        lo_sorts->add_sort(
          columnname = 'MATNR'
          position   = 2
          sequence   = if_salv_c_sort=>sort_up
        ).

        lo_sorts->add_sort(
                columnname = 'CHARG'
                position   = 3
                sequence   = if_salv_c_sort=>sort_up
              ).

        lo_sorts->add_sort(
          columnname = 'LGORT'
          position   = 4
          sequence   = if_salv_c_sort=>sort_up
        ).
      CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
    ENDTRY.

  ENDMETHOD.
  METHOD display.
    IF lo_alv IS BOUND.
      lo_alv->display( ).
    ENDIF.
  ENDMETHOD.

  METHOD init_data.
    CLEAR: t_main, t_matnr, t_mcha.
    REFRESH: t_main, t_matnr, t_mcha.

    CASE 'X'.
      WHEN rad01.
        gr_date[] = date[].
      WHEN rad02.
        gr_date[] = date1[].
    ENDCASE.
  ENDMETHOD.
  METHOD get_data.
    DATA : l_mtart TYPE koth700-mtart.
    DATA : lv_qndat TYPE int4.

* Get Material Type
***  IF s_date-high IS INITIAL.
***    IF s_date-low IS INITIAL.
    SELECT SINGLE mtart INTO l_mtart
      FROM koth700
      WHERE kappl = 'V'         AND
            kschl = mtart     AND
            mtart = mtart     AND
            werks = werks.
***    ELSE.
***      SELECT SINGLE mtart INTO l_mtart
***        FROM koth700
***        WHERE kappl = 'V'         AND
***              kschl = p_mtart     AND
***              mtart = p_mtart     AND
***              werks = p_werks     AND
***              datbi GE s_date-low AND
***              datab LE s_date-low.
***    ENDIF.
***  ELSE.
***    SELECT SINGLE mtart INTO l_mtart
***      FROM koth700
***      WHERE kappl = 'V'         AND
***            kschl = p_mtart     AND
***            mtart = p_mtart     AND
***            werks = p_werks     AND
***            datbi GE s_date-high AND
***            datab LE s_date-high.
***  ENDIF.

    CHECK NOT l_mtart IS INITIAL.

* Get Material Number
    SELECT a~matnr meins INTO TABLE t_matnr
      FROM mara AS a JOIN marc AS b ON b~matnr = a~matnr
      WHERE a~matnr IN matnr
        AND a~mtart EQ l_mtart
        AND b~werks EQ werks.

    CHECK NOT t_matnr[] IS INITIAL.

* Get Main Data
    CASE 'X'.
      WHEN rad01.
        SELECT a~matnr werks lgort charg clabs ceinm cspem cinsm ersda
               b~maktx
          INTO CORRESPONDING FIELDS OF TABLE t_main
          FROM mchb AS a JOIN makt AS b ON a~matnr = b~matnr
          FOR ALL ENTRIES IN t_matnr
          WHERE a~matnr = t_matnr-matnr
            AND werks = werks.
*          AND clabs NE 0.

        SELECT a~matnr werks lgort charg slabs seinm sspem sinsm ersda
               b~maktx
          APPENDING CORRESPONDING FIELDS OF TABLE t_main
          FROM mkol AS a JOIN makt AS b ON a~matnr = b~matnr
          FOR ALL ENTRIES IN t_matnr
          WHERE a~matnr = t_matnr-matnr
            AND werks   = werks.
*          AND slabs   NE 0.

        SELECT a~matnr werks charg lblab lbein lbins
               b~maktx
          APPENDING CORRESPONDING FIELDS OF TABLE t_main
          FROM mslb AS a JOIN makt AS b ON a~matnr = b~matnr
          FOR ALL ENTRIES IN t_matnr
          WHERE a~matnr = t_matnr-matnr
            AND werks   = werks.
*          AND lblab   NE 0.

      WHEN rad02.
        SELECT a~matnr werks lgort charg clabs ceinm cspem ersda
               b~maktx
          INTO CORRESPONDING FIELDS OF TABLE t_main
          FROM mchb AS a JOIN makt AS b ON a~matnr = b~matnr
          FOR ALL ENTRIES IN t_matnr
          WHERE a~matnr = t_matnr-matnr
            AND werks = werks.

        SELECT a~matnr werks lgort charg slabs seinm sspem ersda
               b~maktx
          APPENDING CORRESPONDING FIELDS OF TABLE t_main
          FROM mkol AS a JOIN makt AS b ON a~matnr = b~matnr
          FOR ALL ENTRIES IN t_matnr
          WHERE a~matnr = t_matnr-matnr
            AND werks   = werks.

        SELECT a~matnr werks charg lblab lbein
               b~maktx
          APPENDING CORRESPONDING FIELDS OF TABLE t_main
          FROM mslb AS a JOIN makt AS b ON a~matnr = b~matnr
          FOR ALL ENTRIES IN t_matnr
          WHERE a~matnr = t_matnr-matnr
            AND werks   = werks.
    ENDCASE.

    CHECK NOT t_main[] IS INITIAL.

* Get Next Inspection Date
    CASE 'X'.
      WHEN rad01.
        SELECT a~matnr a~werks a~charg b~qndat b~vfdat
          INTO TABLE t_mcha
          FROM mcha AS a JOIN mch1 AS b ON a~matnr = b~matnr AND
                                           a~charg = b~charg
          FOR ALL ENTRIES IN t_main
          WHERE a~matnr = t_main-matnr
            AND a~werks = werks
            AND a~charg = t_main-charg
            AND b~qndat IN gr_date.
      WHEN rad02.
        SELECT a~matnr a~werks a~charg b~qndat b~vfdat
          INTO TABLE t_mcha
          FROM mcha AS a JOIN mch1 AS b ON a~matnr = b~matnr AND
                                           a~charg = b~charg
          FOR ALL ENTRIES IN t_main
          WHERE a~matnr = t_main-matnr
            AND a~werks = werks
            AND a~charg = t_main-charg
            AND b~vfdat IN gr_date.
    ENDCASE.

* Completed Itab
    CASE 'X'.
      WHEN rad01.
        SORT t_matnr BY matnr.
        SORT t_mcha BY matnr werks charg.
        SORT t_main BY matnr werks charg.
        LOOP AT t_main ASSIGNING FIELD-SYMBOL(<fs_main>).
          IF <fs_main>-slabs IS NOT INITIAL.
            <fs_main>-clabs = <fs_main>-slabs.
*          MODIFY t_main TRANSPORTING clabs.
          ENDIF.

          IF <fs_main>-lblab IS NOT INITIAL.
            <fs_main>-clabs = <fs_main>-lblab.
*          MODIFY t_main TRANSPORTING clabs.
          ENDIF.

*          PERFORM f_modify_xclab USING : t_main-clabs,
*                                         t_main-slabs,
*                                         t_main-lblab,
*                                         t_main-cinsm,
*                                         t_main-sinsm,
*                                         t_main-lbins.
          IF <fs_main>-clabs IS NOT INITIAL.
            <fs_main>-xlabs = <fs_main>-clabs .
          ENDIF.
          IF <fs_main>-slabs IS NOT INITIAL.
            <fs_main>-xlabs = <fs_main>-slabs.
          ENDIF.
          IF <fs_main>-lblab IS NOT INITIAL.
            <fs_main>-xlabs = <fs_main>-lblab.
          ENDIF.
          IF <fs_main>-cinsm IS NOT INITIAL.
            <fs_main>-xlabs = <fs_main>-cinsm.
          ENDIF.
          IF <fs_main>-sinsm IS NOT INITIAL.
            <fs_main>-xlabs = <fs_main>-sinsm.
          ENDIF.
          IF <fs_main>-lbins IS NOT INITIAL.
            <fs_main>-xlabs = <fs_main>-lbins.
          ENDIF.
*          CLEAR: t_matnr, t_mcha.
          READ TABLE t_mcha INTO DATA(ls_mcha) WITH KEY matnr = <fs_main>-matnr
                                     werks = <fs_main>-werks
                                     charg = <fs_main>-charg.
          IF sy-subrc = 0.
            READ TABLE t_matnr INTO DATA(ls_matnr) WITH KEY matnr = <fs_main>-matnr.
            <fs_main>-meins = ls_matnr-meins.
            <fs_main>-qndat = ls_mcha-qndat.
            <fs_main>-vfdat = ls_mcha-vfdat.
*          MODIFY t_main.
          ELSE.
            DELETE t_main.
            CONTINUE.
          ENDIF.

          <fs_main>-qnday = <fs_main>-qndat - sy-datum.
          IF <fs_main>-qnday LE 3.
            <fs_main>-icon = icon_red_light.
          ELSEIF <fs_main>-qnday LE 7.
            <fs_main>-icon = icon_yellow_light.
          ELSE.
            <fs_main>-icon = icon_green_light.
          ENDIF.
*        MODIFY t_main TRANSPORTING qnday icon.
*        CLEAR t_main.
        ENDLOOP.

      WHEN rad02.
        process_rad02( werks = werks ).
*      PERFORM f_process_rad02.
    ENDCASE.
  ENDMETHOD.
  METHOD process_rad02.
    DATA : lt_main    TYPE TABLE OF ty_main.

    SORT t_matnr BY matnr.
    SORT t_mcha BY matnr werks charg.
    SORT t_main BY matnr werks charg.
    LOOP AT t_main ASSIGNING FIELD-SYMBOL(<fs_main>).
      IF <fs_main>-slabs IS NOT INITIAL.
        <fs_main>-clabs = <fs_main>-slabs.
      ENDIF.
      IF <fs_main>-lblab IS NOT INITIAL.
        <fs_main>-clabs = <fs_main>-lblab.
      ENDIF.
      IF <fs_main>-seinm IS NOT INITIAL.
        <fs_main>-ceinm = <fs_main>-seinm.
      ENDIF.
      IF <fs_main>-lbein IS NOT INITIAL.
        <fs_main>-ceinm = <fs_main>-lbein.
      ENDIF.
      IF <fs_main>-sspem  IS NOT INITIAL.
        <fs_main>-cspem = <fs_main>-sspem.
      ENDIF.
*    IF t_main-slabs IS NOT INITIAL.
*      t_main-clabs = t_main-slabs.
*    ENDIF.
*
*    IF t_main-lblab IS NOT INITIAL.
*      t_main-clabs = t_main-lblab.
*    ENDIF.
*
*    IF t_main-seinm IS NOT INITIAL.
*      t_main-ceinm = t_main-seinm.
*    ENDIF.
*
*    IF t_main-lbein IS NOT INITIAL.
*      t_main-ceinm = t_main-lbein.
*    ENDIF.
*
*    IF t_main-sspem IS NOT INITIAL.
*      t_main-cspem = t_main-sspem.
*    ENDIF.
*
*    CLEAR: t_matnr, t_mcha.
      READ TABLE t_mcha INTO DATA(ls_mcha) WITH KEY matnr = <fs_main>-matnr
                                 werks = <fs_main>-werks
                                 charg = <fs_main>-charg.
      IF sy-subrc = 0.
        READ TABLE t_matnr INTO DATA(ls_matnr) WITH KEY matnr = <fs_main>-matnr.
        <fs_main>-meins = ls_matnr-meins.
        <fs_main>-qndat = ls_mcha-qndat.
        <fs_main>-vfdat = ls_mcha-vfdat.
      ELSE.
        DELETE t_main.
        CONTINUE.
      ENDIF.

      <fs_main>-qnday = <fs_main>-vfdat - sy-datum.
      IF <fs_main>-qnday LE 0.
        <fs_main>-icon = icon_red_light.
      ELSEIF <fs_main>-qnday LE 3.
        <fs_main>-icon = icon_yellow_light.
      ELSE.
        <fs_main>-icon = icon_green_light.
      ENDIF.

*      MODIFY t_main TRANSPORTING clabs ceinm cspem meins qndat vfdat qnday icon.
*      CLEAR t_main.
    ENDLOOP.

    lt_main[] = t_main[].
    DELETE lt_main WHERE cspem IS INITIAL.
    SORT lt_main BY matnr charg.
    DELETE ADJACENT DUPLICATES FROM lt_main COMPARING matnr charg.
    IF lt_main[] IS NOT INITIAL.
      SELECT mseg~mblnr mseg~mjahr zeile matnr lgort charg tcode2 cpudt
      FROM mseg JOIN mkpf ON mseg~mblnr = mkpf~mblnr
                         AND mseg~mjahr = mkpf~mjahr
      INTO TABLE t_mseg
      FOR ALL ENTRIES IN lt_main
      WHERE matnr = lt_main-matnr
        AND lgort = lt_main-lgort
        AND charg = lt_main-charg
        AND werks = werks
        AND bwart = '344'
        AND xauto = space.
    ENDIF.
  ENDMETHOD.
  METHOD validate_data.
    SORT t_mseg BY matnr charg mblnr DESCENDING.
    LOOP AT t_main ASSIGNING FIELD-SYMBOL(<fs_main>).
      IF <fs_main>-cspem IS NOT INITIAL.
*        CLEAR t_mseg.
        READ TABLE t_mseg INTO DATA(ls_mseg) WITH KEY matnr = <fs_main>-matnr
                                   charg = <fs_main>-charg.
        IF sy-subrc = 0.
          IF ls_mseg-tcode2 <> 'QA07'.
            CLEAR <fs_main>-cspem.
*            MODIFY t_main TRANSPORTING cspem.
          ENDIF.
        ELSE.
          CLEAR <fs_main>-cspem.
*          MODIFY t_main TRANSPORTING cspem.
        ENDIF.
      ENDIF.
      IF <fs_main>-clabs IS NOT INITIAL.
        <fs_main>-xlabs = <fs_main>-clabs.
      ELSEIF <fs_main>-cinsm IS NOT INITIAL.
      ENDIF.
    ENDLOOP.

    CASE werks.
      WHEN '3600'.
        DELETE t_main WHERE clabs IS INITIAL
                        AND ceinm IS INITIAL.
      WHEN '2300'.
*      DELETE t_main WHERE clabs IS INITIAL
*                      AND ceinm IS INITIAL
*                      AND cspem IS INITIAL.
        CASE 'X'.
          WHEN rad01.
            DELETE t_main WHERE clabs IS INITIAL.
          WHEN rad02.
            DELETE t_main WHERE clabs IS INITIAL
                            AND ceinm IS INITIAL
                            AND cspem IS INITIAL.
        ENDCASE.

      WHEN '0101' OR '0102'.
        CASE 'X'.
          WHEN rad01.
            DELETE t_main WHERE xlabs IS INITIAL.
          WHEN rad02.
            DELETE t_main WHERE clabs IS INITIAL.
        ENDCASE.

      WHEN OTHERS.
        DELETE t_main WHERE clabs IS INITIAL.
    ENDCASE.

    LOOP AT t_main INTO DATA(ls_main).
      get_note( lv_matnr = ls_main-matnr lv_charg = ls_main-charg ).
*      PERFORM f_get_note USING t_main-matnr t_main-charg.
    ENDLOOP.
  ENDMETHOD.
  METHOD get_note.
    DATA : lv_name  TYPE thead-tdname,
           lt_lines TYPE STANDARD TABLE OF tline,
           ls_lines LIKE LINE OF lt_lines,
           ls_main  TYPE ty_main.

    lv_name(18)    = lv_matnr.
    lv_name+22(10) = lv_charg.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'VERM'
        language                = sy-langu
        name                    = lv_name
        object                  = 'CHARGE'
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.

    IF sy-subrc = 0.
      READ TABLE lt_lines INTO ls_lines INDEX 1.
      IF sy-subrc = 0.
        ls_main-note = ls_lines-tdline.
        MODIFY t_main FROM ls_main TRANSPORTING note WHERE matnr = lv_matnr AND charg = lv_charg.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD get_t001w.
   SELECT SINGLE * INTO ls_t001w FROM t001w
    WHERE werks = iv_werks.
  ENDMETHOD.
ENDCLASS.
