*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_zihqmr006 DEFINITION.

  PUBLIC SECTION.
    CLASS-DATA: lo_alv    TYPE REF TO cl_salv_table.
    TYPES: tt_budat TYPE RANGE OF budat,
           tt_werks TYPE RANGE OF werks_d,
           tt_matnr TYPE RANGE OF matnr,
           tt_lifnr TYPE RANGE OF lifnr.
    CLASS-DATA: is_budat TYPE tt_budat,
                is_werks TYPE tt_werks,
                is_matnr TYPE tt_matnr,
                is_lifnr TYPE tt_lifnr.
    CLASS-DATA: va_plant TYPE char3,
                ra_bwart TYPE RANGE OF bwart.

    TYPES: BEGIN OF ty_mkpf,
             mblnr  TYPE mkpf-mblnr,
             mjahr  TYPE mkpf-mjahr,
             budat  TYPE mkpf-budat,
             cpudt  TYPE mkpf-cpudt,
             cputm  TYPE mkpf-cputm,
             tcode2 TYPE mkpf-tcode2,
           END OF ty_mkpf.
    CLASS-DATA: t_mkpf TYPE TABLE OF ty_mkpf WITH EMPTY KEY.

    TYPES: BEGIN OF ty_mseg,
             mblnr  TYPE mseg-mblnr,
             budat  TYPE mkpf-budat,
             mjahr  TYPE mseg-mjahr,
             zeile  TYPE mseg-zeile,
             bwart  TYPE mseg-bwart,
             shkzg  TYPE mseg-shkzg,
             matnr  TYPE mseg-matnr,
             werks  TYPE mseg-werks,
             charg  TYPE mseg-charg,
             lifnr  TYPE mseg-lifnr,
             menge  TYPE mseg-menge,
             meins  TYPE mseg-meins,
             ebeln  TYPE mseg-ebeln,
             ebelp  TYPE mseg-ebelp,
             smbln  TYPE mseg-smbln,
             cpudt  TYPE mkpf-cpudt,
             cputm  TYPE mkpf-cputm,
             tcode2 TYPE mkpf-tcode2,
           END OF ty_mseg.
    CLASS-DATA: t_mseg TYPE TABLE OF ty_mseg WITH EMPTY KEY.

    TYPES: BEGIN OF ty_msegdata.
             INCLUDE TYPE ty_mseg.
           TYPES: END OF ty_msegdata.
    CLASS-DATA: t_msegdata TYPE TABLE OF ty_msegdata WITH EMPTY KEY.

    TYPES:  BEGIN OF ty_lifnr.
              INCLUDE TYPE ty_mseg.
            TYPES:  END OF ty_lifnr.
    CLASS-DATA: t_lifnr TYPE TABLE OF ty_lifnr WITH EMPTY KEY.

    TYPES:  BEGIN OF ty_matnr.
              INCLUDE TYPE ty_mseg.
            TYPES:  END OF ty_matnr.
    CLASS-DATA: t_matnr TYPE TABLE OF ty_matnr WITH EMPTY KEY.

    TYPES: BEGIN OF ty_lfa1,
             lifnr TYPE lfa1-lifnr,
             name1 TYPE lfa1-name1,
           END OF ty_lfa1.
    CLASS-DATA: t_lfa1 TYPE TABLE OF ty_lfa1 WITH EMPTY KEY.

    TYPES: BEGIN OF ty_makt,
             matnr TYPE makt-matnr,
             maktx TYPE makt-maktx,
           END OF ty_makt.
    CLASS-DATA: t_makt TYPE TABLE OF ty_makt WITH EMPTY KEY.

    TYPES: BEGIN OF ty_qmdata,
             mblnr     TYPE qals-mblnr,
             zeile     TYPE qals-zeile,
             mjahr     TYPE qals-mjahr,
             matnr     TYPE qals-matnr,
             charg     TYPE qals-charg,
             lmenge01  TYPE qals-lmenge01,
             lmenge04  TYPE qals-lmenge04,
             qkennzahl TYPE qave-qkennzahl,
             vcode     TYPE qave-vcode,
             vdatum    TYPE qave-vdatum,
           END OF ty_qmdata.
    CLASS-DATA: t_qmdata TYPE TABLE OF ty_qmdata WITH EMPTY KEY.

    TYPES: BEGIN OF ty_viqmel,
             matnr    TYPE viqmel-matnr,
             mawerk   TYPE viqmel-mawerk,
             charg    TYPE viqmel-charg,
             qmdat    TYPE viqmel-qmdat,
             qmnum    TYPE viqmel-qmnum,
             qmtxt    TYPE viqmel-qmtxt,
             prueflos TYPE viqmel-prueflos,
             rkmng    TYPE viqmel-rkmng,
             qmgrp    TYPE viqmel-qmgrp,
             qmcod    TYPE viqmel-qmcod,
             mblnr    TYPE viqmel-mblnr,
           END OF ty_viqmel.
    CLASS-DATA: t_viqmel TYPE TABLE OF ty_viqmel WITH EMPTY KEY.

    TYPES: BEGIN OF ty_eket,
             ebeln TYPE eket-ebeln,
             ebelp TYPE eket-ebelp,
             etenr TYPE eket-etenr,
             eindt TYPE eket-eindt,
             wemng TYPE eket-wemng,
             menge TYPE eket-menge,
           END OF ty_eket.
    CLASS-DATA: t_eket TYPE TABLE OF ty_eket WITH EMPTY KEY.

    TYPES: BEGIN OF ty_ekpo,
             ebeln TYPE ekpo-ebeln,
             ebelp TYPE ekpo-ebelp,
             meins TYPE ekpo-meins,
             menge TYPE ekpo-menge,
             bprme TYPE ekpo-bprme,
             lmein TYPE ekpo-lmein,
             bpumn TYPE ekpo-bpumn,
             bpumz TYPE ekpo-bpumz,
             umren TYPE ekpo-umren,
             umrez TYPE ekpo-umrez,
           END OF ty_ekpo.
    CLASS-DATA: t_ekpo TYPE TABLE OF ty_ekpo WITH EMPTY KEY.

    TYPES: BEGIN OF ty_ekbe,
             ebeln TYPE ekbe-ebeln,
             ebelp TYPE ekbe-ebelp,
             belnr TYPE ekbe-belnr,
             budat TYPE ekbe-budat,
             cpudt TYPE ekbe-cpudt,
             cputm TYPE ekbe-cputm,
             shkzg TYPE ekbe-shkzg,
             menge TYPE ekbe-menge,
             charg TYPE ekbe-charg,
             bwart TYPE ekbe-bwart,
             lfbnr TYPE ekbe-lfbnr,
             lfpos TYPE ekbe-lfpos,
           END OF ty_ekbe.
    CLASS-DATA: t_ekbe TYPE TABLE OF ty_ekbe WITH EMPTY KEY.

    TYPES:  BEGIN OF ty_ekbe1.
              INCLUDE TYPE ty_ekbe.
            TYPES:  END OF ty_ekbe1.
    CLASS-DATA: t_ekbe1 TYPE TABLE OF ty_ekbe1 WITH EMPTY KEY.

    TYPES: BEGIN OF ty_out,
             lifnr     TYPE mseg-lifnr,
             name1     TYPE lfa1-name1,
             atwrt     TYPE atwrt,
             matnr     TYPE mseg-matnr,
             maktx     TYPE makt-maktx,
             meins     TYPE mseg-meins,
             werks     TYPE mseg-werks,
             ebeln     TYPE mseg-ebeln,
             ebelp     TYPE mseg-ebelp,
             poqtyout  TYPE ekpo-menge,
             etenr     TYPE eket-etenr,
             eindt     TYPE eket-eindt,
             podlvqty  TYPE eket-menge,
             mblnr     TYPE mseg-mblnr,
             zeile     TYPE mseg-zeile,
             menge101  TYPE mseg-menge,
             menge102  TYPE mseg-menge,
             menge122  TYPE mseg-menge,
             menge123  TYPE mseg-menge,
             budat     TYPE mkpf-budat,
             charg     TYPE mseg-charg,
             povgr     TYPE ekpo-menge,
             percen    TYPE p LENGTH 15 DECIMALS 2,
             openpo    TYPE ekpo-menge,
             tmdif     TYPE i,
             qkennzahl TYPE qkennzahl,
             vcode     TYPE qave-vcode,
             vdatum    TYPE qave-vdatum,
             lmenge01  TYPE qals-lmenge01,
             lmenge04  TYPE qals-lmenge04,
             qmdat     TYPE viqmel-qmdat,
             qmgrp     TYPE viqmel-qmgrp,
             qmcod     TYPE viqmel-qmcod,
             qmnum     TYPE viqmel-qmnum,
             qmtxt     TYPE viqmel-qmtxt,
             rkmng     TYPE viqmel-rkmng,
             cputm     TYPE mkpf-cputm,
             cpudt     TYPE mkpf-cpudt,
             menge     TYPE mseg-menge,
             wemng     TYPE eket-wemng,
             prueflos  TYPE viqmel-prueflos,
             pouom     TYPE ekpo-meins,
             poqty     TYPE ekpo-menge,
             rdtv      TYPE ekpo-menge,

           END OF ty_out.
    CLASS-DATA: t_out TYPE TABLE OF ty_out WITH EMPTY KEY.

    TYPES: BEGIN OF ty_mch1,
             matnr    TYPE matnr,
             charg    TYPE charg_d,
             cuobj_bm TYPE cuobj_bm,
             objek    TYPE objnum,
           END   OF ty_mch1.
    CLASS-DATA: gt_mch1 TYPE TABLE OF ty_mch1 WITH EMPTY KEY.

    TYPES: BEGIN OF ty_ausp,
             objek TYPE objnum,
             atwrt TYPE atwrt,
           END   OF ty_ausp.
    CLASS-DATA: gt_ausp TYPE TABLE OF ty_ausp WITH EMPTY KEY.

    METHODS: constructor
      IMPORTING so_budat TYPE tt_budat
                so_werks TYPE tt_werks
                so_matnr TYPE tt_matnr
                so_lifnr TYPE tt_lifnr.
    METHODS: run
      IMPORTING lv_program TYPE sy-cprog
                title_name TYPE sy-title
                id         TYPE sy-sysid
                mandt      TYPE sy-mandt
                datum      TYPE sy-datum
                username   TYPE sy-uname
                uzeit      TYPE sy-uzeit.
    CLASS-METHODS: prepare.
    CLASS-METHODS: pf_status
      IMPORTING lv_program TYPE sy-cprog .
    CLASS-METHODS: top_of_page
      IMPORTING title_name   TYPE sy-title
                program_name TYPE sy-cprog
                id           TYPE sy-sysid
                mandt        TYPE sy-mandt
                datum        TYPE sy-datum
                username     TYPE sy-uname
                uzeit        TYPE sy-uzeit.
    CLASS-METHODS: report_layout.
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
    CLASS-METHODS init_data.
    CLASS-METHODS get_data.
    CLASS-METHODS: process_data.
    CLASS-METHODS: free_memory.

ENDCLASS.

CLASS lcl_zihqmr006 IMPLEMENTATION.
  METHOD on_user_command.

  ENDMETHOD.
  METHOD on_checkbox_click.

  ENDMETHOD.
  METHOD constructor.
    is_budat = so_budat[].
    is_werks = so_werks[].
    is_matnr = so_matnr[].
    is_lifnr = so_lifnr[].
  ENDMETHOD.
  METHOD run.
    init_data(  ).
    get_data( ).
    process_data(  ).
    free_memory(  ).
    prepare(  ).
    pf_status( lv_program = lv_program ).
    top_of_page( title_name = title_name program_name = lv_program datum = datum id = id mandt = mandt username = username uzeit = uzeit ).
    report_layout( ).
    sort_fields(  ).
    display(  ).
    free_memory(  ).
  ENDMETHOD.
  METHOD prepare.
    DATA: lo_layout TYPE REF TO cl_salv_layout,
          ls_key    TYPE salv_s_layout_key.
    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_alv
          CHANGING  t_table    = t_out[] ).
      CATCH cx_salv_msg.
    ENDTRY.

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

    DATA(lv_mandt) = |({ mandt })|.
    CONCATENATE 'Client: ' id lv_mandt INTO client SEPARATED BY space.
    lo_header->create_text( row = 2 column = 1 text = client ).

    lo_header->create_text( row = 2 column = 3 text = datum ).

    CONCATENATE 'User: ' username INTO user  SEPARATED BY space.
    lo_header->create_text( row = 3 column = 1 text = user ).
    lo_header->create_text( row = 3 column = 3 text = uzeit ).

    lo_alv->set_top_of_list( lo_header ).

  ENDMETHOD.
  METHOD report_layout.
    DATA(lo_columns) = lo_alv->get_columns( ).
    TRY.
        DATA(lo_col_cputm) = lo_columns->get_column( 'CPUTM' ).
        lo_col_cputm->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_cpudt) = lo_columns->get_column( 'CPUDT' ).
        lo_col_cpudt->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_menge) = lo_columns->get_column( 'MENGE' ).
        lo_col_menge->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_wemng) = lo_columns->get_column( 'WEMNG' ).
        lo_col_wemng->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_prueflos) = lo_columns->get_column( 'PRUEFLOS' ).
        lo_col_prueflos->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_poqty) = lo_columns->get_column( 'POQTY' ).
        lo_col_poqty->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_col_rdtv) = lo_columns->get_column( 'RDTV' ).
        lo_col_rdtv->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_pouom) = lo_columns->get_column( 'POUOM' ).
        lo_column_pouom->set_long_text( 'PO UoM' ).
        lo_column_pouom->set_medium_text( 'PO UoM' ).
        lo_column_pouom->set_short_text( 'PO UoM' ).
        lo_column_pouom->set_visible( abap_false ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_lifnr) = lo_columns->get_column( 'LIFNR' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_name1) = lo_columns->get_column( 'NAME1' ).
        lo_column_name1->set_long_text( 'Vendor Description' ).
        lo_column_name1->set_medium_text( 'Vendor Description' ).
        lo_column_name1->set_short_text( 'Vend Desc.' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_atwrt) = lo_columns->get_column( 'ATWRT' ).
        lo_column_atwrt->set_long_text( 'Manufacturer' ).
        lo_column_atwrt->set_medium_text( 'Manufacturer' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_matnr) = lo_columns->get_column( 'MATNR' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_maktx) = lo_columns->get_column( 'MAKTX' ).
        lo_column_maktx->set_long_text( 'Material Description' ).
        lo_column_maktx->set_medium_text( 'Material Description' ).
        lo_column_maktx->set_short_text( 'Mat Desc.' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_meins) = lo_columns->get_column( 'MEINS' ).
        lo_column_meins->set_long_text( 'UoM' ).
        lo_column_meins->set_medium_text( 'UoM' ).
        lo_column_meins->set_short_text( 'UoM' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_werks) = lo_columns->get_column( 'WERKS' ).
        lo_column_werks->set_long_text( 'Plant' ).
        lo_column_werks->set_medium_text( 'Plant' ).
        lo_column_werks->set_short_text( 'Plant' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_ebeln) = lo_columns->get_column( 'EBELN' ).
        lo_column_ebeln->set_long_text( 'PO No.' ).
        lo_column_ebeln->set_medium_text( 'PO No' ).
        lo_column_ebeln->set_short_text( 'PO No' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_ebelp) = lo_columns->get_column( 'EBELP' ).
        lo_column_ebelp->set_long_text( 'PO Item No.' ).
        lo_column_ebelp->set_medium_text( 'PO Item No' ).
        lo_column_ebelp->set_short_text( 'PO Item No' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_poqtyout) = lo_columns->get_column( 'POQTYOUT' ).
        lo_column_poqtyout->set_long_text( 'PO Qty' ).
        lo_column_poqtyout->set_medium_text( 'PO Qty' ).
        lo_column_poqtyout->set_short_text( 'PO Qty' ).
        lo_column_poqtyout->set_quantity_column( 'MEINS' ).
        lo_column_poqtyout->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    DATA(lo_aggregations_poqtyout) = lo_alv->get_aggregations( ).
    TRY.
        lo_aggregations_poqtyout->add_aggregation(
          columnname  = 'POQTYOUT'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.
    TRY.
        DATA(lo_column_etenr) = lo_columns->get_column( 'ETENR' ).
        lo_column_etenr->set_long_text( 'PO Sched. Delv. Line' ).
        lo_column_etenr->set_medium_text( 'PO Sched. Delv. Line' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_eindt) = lo_columns->get_column( 'EINDT' ).
        lo_column_eindt->set_long_text( 'PO Sched. Delv. Date' ).
        lo_column_eindt->set_medium_text( 'PO Sched. Delv. Date' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_podlvqty) = lo_columns->get_column( 'PODLVQTY' ).
        lo_column_podlvqty->set_long_text( 'PO Sched. Delv. Qty' ).
        lo_column_podlvqty->set_medium_text( 'PO Sched. Delv. Qty' ).
        lo_column_podlvqty->set_quantity_column( 'MEINS' ).
        lo_column_podlvqty->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    DATA(lo_aggregations_podlvqty) = lo_alv->get_aggregations( ).
    TRY.
        lo_aggregations_podlvqty->add_aggregation(
          columnname  = 'PODLVQTY'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.
    TRY.
        DATA(lo_column_mblnr) = lo_columns->get_column( 'MBLNR' ).
        lo_column_mblnr->set_long_text( 'Material Doc.' ).
        lo_column_mblnr->set_medium_text( 'Material Doc.' ).
        lo_column_mblnr->set_short_text( 'Mat Doc.' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_zeile) = lo_columns->get_column( 'ZEILE' ).
        lo_column_zeile->set_long_text( 'GR Item No.' ).
        lo_column_zeile->set_medium_text( 'GR Item No.' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_menge101) = lo_columns->get_column( 'MENGE101' ).
        lo_column_menge101->set_long_text( 'GR Qty' ).
        lo_column_menge101->set_medium_text( 'GR Qty' ).
        lo_column_menge101->set_short_text( 'GR Qty' ).
        lo_column_menge101->set_quantity_column( 'MEINS' ).
        lo_column_menge101->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    DATA(lo_aggregations_menge101) = lo_alv->get_aggregations( ).
    TRY.
        lo_aggregations_menge101->add_aggregation(
          columnname  = 'MENGE101'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.
    TRY.
        DATA(lo_column_menge102) = lo_columns->get_column( 'MENGE102' ).
        lo_column_menge102->set_long_text( 'Cancel GR Qty' ).
        lo_column_menge102->set_medium_text( 'Cancel GR Qty' ).
        lo_column_menge102->set_quantity_column( 'MEINS' ).
        lo_column_menge102->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    DATA(lo_aggregations_menge102) = lo_alv->get_aggregations( ).
    TRY.
        lo_aggregations_menge102->add_aggregation(
          columnname  = 'MENGE102'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.
    TRY.
        DATA(lo_column_menge122) = lo_columns->get_column( 'MENGE122' ).
        lo_column_menge122->set_long_text( 'RDTV Qty' ).
        lo_column_menge122->set_medium_text( 'RDTV Qty' ).
        lo_column_menge122->set_quantity_column( 'MEINS' ).
        lo_column_menge122->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    DATA(lo_aggregations_menge122) = lo_alv->get_aggregations( ).
    TRY.
        lo_aggregations_menge122->add_aggregation(
          columnname  = 'MENGE122'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.
    TRY.
        DATA(lo_column_menge123) = lo_columns->get_column( 'MENGE123' ).
        lo_column_menge123->set_long_text( 'Cancel RDTV Qty' ).
        lo_column_menge123->set_medium_text( 'Cancel RDTV Qty' ).
        lo_column_menge123->set_quantity_column( 'MEINS' ).
        lo_column_menge123->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    DATA(lo_aggregations_menge123) = lo_alv->get_aggregations( ).
    TRY.
        lo_aggregations_menge123->add_aggregation(
          columnname  = 'MENGE123'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.
    TRY.
        DATA(lo_column_budat) = lo_columns->get_column( 'BUDAT' ).
        lo_column_budat->set_long_text( 'Posting Date' ).
        lo_column_budat->set_medium_text( 'Posting Date' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_charg) = lo_columns->get_column( 'CHARG' ).
        lo_column_charg->set_long_text( 'Internal Batch' ).
        lo_column_charg->set_medium_text( 'Internal Batch' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_povgr) = lo_columns->get_column( 'POVGR' ).
        lo_column_povgr->set_long_text( 'Qty OSO' ).
        lo_column_povgr->set_medium_text( 'Qty OSO' ).
        lo_column_povgr->set_quantity_column( 'MEINS' ).
        lo_column_povgr->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    DATA(lo_aggregations_povgr) = lo_alv->get_aggregations( ).
    TRY.
        lo_aggregations_povgr->add_aggregation(
          columnname  = 'POVGR'
          aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
    ENDTRY.
    TRY.
        DATA(lo_column_percen) = lo_columns->get_column( 'PERCEN' ).
        lo_column_percen->set_long_text( '% Qty OSO' ).
        lo_column_percen->set_medium_text( '% Qty OSO' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_openpo) = lo_columns->get_column( 'OPENPO' ).
        lo_column_openpo->set_long_text( 'Open PO Sched. Delv. Qty' ).
        lo_column_openpo->set_quantity_column( 'POUOM' ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_tmdif) = lo_columns->get_column( 'TMDIF' ).
        lo_column_tmdif->set_long_text( 'Time Diff. Delv ( Days )' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    IF va_plant IS NOT INITIAL.
      TRY.
          DATA(lo_column_qkennzahl) = lo_columns->get_column( 'QKENNHAZL' ).
        CATCH cx_salv_not_found.
      ENDTRY.
    ELSE.
      TRY.
          DATA(lo_col_qkennzahl) = lo_columns->get_column( 'QKENNHAZL' ).
          lo_col_qkennzahl->set_visible( abap_false ).
        CATCH cx_salv_not_found.
      ENDTRY.
    ENDIF.
    TRY.
        DATA(lo_column_vcode) = lo_columns->get_column( 'VCODE' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_vdatum) = lo_columns->get_column( 'VDATUM' ).
        lo_column_vdatum->set_long_text( 'UD Date' ).
        lo_column_vdatum->set_medium_text( 'UD Date' ).
        lo_column_vdatum->set_short_text( 'UD Date' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_lmenge01) = lo_columns->get_column( 'LMENGE01' ).
        lo_column_lmenge01->set_long_text( 'UU Stock' ).
        lo_column_lmenge01->set_medium_text( 'UU Stock' ).
        lo_column_lmenge01->set_short_text( 'UU Stock' ).
        lo_column_lmenge01->set_quantity_column( 'MEINS' ).
        lo_column_lmenge01->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_lmenge04) = lo_columns->get_column( 'LMENGE04' ).
        lo_column_lmenge04->set_quantity_column( 'MEINS' ).
        lo_column_lmenge04->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_qmdat) = lo_columns->get_column( 'QMDAT' ).
        lo_column_qmdat->set_long_text( 'Notif.Date' ).
        lo_column_qmdat->set_medium_text( 'Notif.Date' ).
        lo_column_qmdat->set_short_text( 'Notif.Date' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_qmgrp) = lo_columns->get_column( 'QMGRP' ).
        lo_column_qmgrp->set_long_text( 'Coding' ).
        lo_column_qmgrp->set_medium_text( 'Coding' ).
        lo_column_qmgrp->set_short_text( 'Coding' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_qmcod) = lo_columns->get_column( 'QMCOD' ).
        lo_column_qmcod->set_long_text( 'Coding Code' ).
        lo_column_qmcod->set_medium_text( 'Coding Code' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_qmnum) = lo_columns->get_column( 'QMNUM' ).
        lo_column_qmnum->set_long_text( 'Notif.No.' ).
        lo_column_qmnum->set_medium_text( 'Notif.No.' ).
        lo_column_qmnum->set_short_text( 'Notif.No.' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_qmtxt) = lo_columns->get_column( 'QMTXT' ).
        lo_column_qmtxt->set_long_text( 'Notifaction Description' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        DATA(lo_column_rkmng) = lo_columns->get_column( 'RKMNG' ).
        lo_column_rkmng->set_long_text( 'Complaint Qty' ).
        lo_column_rkmng->set_medium_text( 'Complaint Qty' ).
        lo_column_rkmng->set_quantity_column( 'MEINS' ).
        lo_column_rkmng->set_sign( abap_true ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
  ENDMETHOD.
  METHOD sort_fields.
    DATA(lo_sorts) = lo_alv->get_sorts( ).

    TRY.

        lo_sorts->add_sort(
          columnname = 'EBELN'
          position   = 1
          sequence   = if_salv_c_sort=>sort_up
          subtotal   = abap_false ).


        lo_sorts->add_sort(
          columnname = 'EBELP'
          position   = 2
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
    DATA: ls_bwart LIKE LINE OF ra_bwart.
    ls_bwart-low     = '101'.
    ls_bwart-sign    = 'I'.
    ls_bwart-option  = 'EQ'.
    APPEND ls_bwart TO ra_bwart.
    ls_bwart-low     = '102'.
    ls_bwart-sign    = 'I'.
    ls_bwart-option  = 'EQ'.
    APPEND ls_bwart TO ra_bwart.
    ls_bwart-low     = '122'.
    ls_bwart-sign    = 'I'.
    ls_bwart-option  = 'EQ'.
    APPEND ls_bwart TO ra_bwart.
    ls_bwart-low     = '123'.
    ls_bwart-sign    = 'I'.
    ls_bwart-option  = 'EQ'.
    APPEND ls_bwart TO ra_bwart.

    LOOP AT is_werks INTO DATA(ls_werks).
      IF ls_werks-low = '3301' OR
        ls_werks-low = '3302'.
        va_plant  = 'PLI'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_data.
    DATA : lt_mch1  TYPE TABLE OF ty_mseg WITH EMPTY KEY.
    DATA : lv_atinn TYPE atinn.

*  SELECT mblnr mjahr budat cpudt cputm tcode2
*    FROM mkpf
*    INTO CORRESPONDING FIELDS OF TABLE t_mkpf
*    WHERE budat IN so_budat.

*  IF t_mkpf[] IS NOT INITIAL.
    SELECT a~mblnr a~mjahr a~zeile a~bwart a~shkzg
           a~matnr a~werks a~charg a~lifnr a~menge
           a~meins a~ebeln a~ebelp a~smbln
           b~budat b~cpudt b~cputm b~tcode2
      FROM mseg AS a JOIN mkpf AS b ON a~mblnr EQ b~mblnr AND
                                       a~mjahr EQ b~mjahr
      INTO CORRESPONDING FIELDS OF TABLE t_mseg
*      FOR ALL ENTRIES IN t_mkpf
      WHERE a~matnr  IN is_matnr     AND
            a~werks  IN is_werks     AND
            a~bwart  IN ra_bwart     AND
            a~lifnr  IN is_lifnr     AND
            b~budat  IN is_budat.

*    LOOP AT t_msegdata.
*      IF t_msegdata-bwart EQ '101'.
*        READ TABLE t_msegdata WITH KEY smbln = t_msegdata-mblnr.
*        IF sy-subrc NE 0.
*          t_mseg = t_msegdata.
*          APPEND t_mseg.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.

    IF t_mseg[] IS NOT INITIAL.
      t_lifnr[] = t_mseg[].
      SORT t_lifnr BY lifnr.
      DELETE ADJACENT DUPLICATES FROM t_lifnr COMPARING lifnr.
      t_matnr[] = t_mseg[].
      SORT t_matnr BY matnr.
      DELETE ADJACENT DUPLICATES FROM t_matnr COMPARING matnr.

      IF t_lifnr[] IS NOT INITIAL.
        SELECT lifnr name1
          FROM lfa1
          INTO CORRESPONDING FIELDS OF TABLE t_lfa1
          FOR ALL ENTRIES IN t_lifnr
          WHERE lifnr EQ t_lifnr-lifnr.
      ENDIF.

      IF t_matnr[] IS NOT INITIAL.
        SELECT matnr maktx
          FROM makt
          INTO CORRESPONDING FIELDS OF TABLE t_makt
          FOR ALL ENTRIES IN t_matnr
          WHERE matnr EQ t_matnr-matnr AND
                spras EQ sy-langu.
      ENDIF.

      SELECT a~mblnr a~zeile a~mjahr a~lmenge01 a~lmenge04 a~prueflos a~matnr a~charg
             b~qkennzahl b~vcode b~vdatum
        FROM qals AS a JOIN qave AS b ON a~prueflos EQ b~prueflos
        INTO CORRESPONDING FIELDS OF TABLE t_qmdata
        FOR ALL ENTRIES IN t_mseg
        WHERE mblnr EQ t_mseg-mblnr AND
              zeile EQ t_mseg-zeile AND
              mjahr EQ t_mseg-mjahr.

      SELECT matnr mawerk charg qmdat qmnum qmtxt prueflos rkmng
             qmgrp qmcod mblnr
        FROM viqmel
        INTO CORRESPONDING FIELDS OF TABLE t_viqmel
        FOR ALL ENTRIES IN t_mseg
        WHERE matnr    EQ t_mseg-matnr AND
              mawerk   EQ t_mseg-werks AND
              charg    EQ t_mseg-charg AND
              qmgrp    NE space        AND
              qmcod    NE space        AND
              kzloesch NE 'X'.

      SELECT ebeln ebelp etenr eindt wemng menge
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE t_eket
        FOR ALL ENTRIES IN t_mseg
        WHERE ebeln EQ t_mseg-ebeln AND
              ebelp EQ t_mseg-ebelp.

      SELECT ebeln ebelp menge meins bprme lmein bpumn bpumz umren umrez
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE t_ekpo
        FOR ALL ENTRIES IN t_mseg
        WHERE ebeln EQ t_mseg-ebeln AND
              ebelp EQ t_mseg-ebelp.

      SELECT ebeln ebelp belnr budat cpudt cputm shkzg menge charg
             bwart lfbnr lfpos
        FROM ekbe
        INTO CORRESPONDING FIELDS OF TABLE t_ekbe
        FOR ALL ENTRIES IN t_mseg
        WHERE ebeln EQ t_mseg-ebeln AND
              ebelp EQ t_mseg-ebelp AND
              bewtp EQ 'E'.

*      LOOP AT t_ekbe.
*        CASE t_ekbe-bwart.
*          WHEN '122'.
*            t_ekbe1  = t_ekbe.
*            APPEND t_ekbe1.
*        ENDCASE.
*      ENDLOOP.

      lt_mch1[] = t_mseg[].
      SORT lt_mch1 BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM lt_mch1 COMPARING matnr charg.
      CHECK lt_mch1[] IS NOT INITIAL.
      SELECT matnr charg cuobj_bm
        FROM mch1
        INTO TABLE gt_mch1
        FOR ALL ENTRIES IN lt_mch1
        WHERE matnr = lt_mch1-matnr
          AND charg = lt_mch1-charg.

      IF sy-subrc = 0.
        CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
          EXPORTING
            input  = 'ZMF'
          IMPORTING
            output = lv_atinn.

        LOOP AT gt_mch1 ASSIGNING FIELD-SYMBOL(<fs_mch1>).
          <fs_mch1>-objek = <fs_mch1>-cuobj_bm.
*        MODIFY gt_mch1 TRANSPORTING objek.
        ENDLOOP.

        SELECT objek atwrt
          FROM ausp
          INTO TABLE gt_ausp
          FOR ALL ENTRIES IN gt_mch1
          WHERE objek = gt_mch1-objek
            AND atinn = lv_atinn.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD process_data.
    DATA: ld_povgr       TYPE ekpo-menge,
          ld_mblnr       TYPE mseg-mblnr,
          ld_flag        TYPE i,
          ld_menge       TYPE ekbe-menge,
          ld_menge1      TYPE ekbe-menge,
          ld_addmenge    TYPE ekbe-menge,
          ld_etenr       TYPE eket-etenr,
          ld_line        TYPE i,
          ld_schedline   TYPE i,
          ld_notif_line1 TYPE i,
          openpo_flag    TYPE i,
          flag_timediff  TYPE i,
          ld_eket_qty    TYPE i,
          ld_previousgr  TYPE i,
          ld_qty_gr      TYPE i.
    DATA: lv_ebeln_a TYPE mseg-ebeln,
          lv_ebelp_a TYPE mseg-ebelp,
          lv_ebeln_b TYPE mseg-ebeln,
          lv_ebelp_b TYPE mseg-ebelp.
*  SORT t_mseg BY ebeln ebelp matnr mblnr charg.
*  SORT t_ekbe BY ebeln ebelp belnr. "budat cpudt cputm.

    SORT t_mseg BY ebeln ebelp budat mblnr.
    SORT t_ekbe BY ebeln ebelp budat belnr.

    LOOP AT t_mseg INTO DATA(ls_mseg).
      APPEND INITIAL LINE TO t_out ASSIGNING FIELD-SYMBOL(<fs_out>).
      <fs_out>-mblnr  = ls_mseg-mblnr.
      <fs_out>-zeile  = ls_mseg-zeile.
      <fs_out>-matnr  = ls_mseg-matnr.
      <fs_out>-werks  = ls_mseg-werks.
      <fs_out>-charg  = ls_mseg-charg.
      <fs_out>-menge  = ls_mseg-menge.
      <fs_out>-lifnr  = ls_mseg-lifnr.
      <fs_out>-meins  = ls_mseg-meins.
      <fs_out>-ebeln  = ls_mseg-ebeln.
      <fs_out>-ebelp  = ls_mseg-ebelp.

      <fs_out>-budat  = ls_mseg-budat.
      <fs_out>-cpudt  = ls_mseg-cpudt.
      <fs_out>-cputm  = ls_mseg-cputm.

      READ TABLE gt_mch1 INTO DATA(ls_mch1) WITH KEY matnr = ls_mseg-matnr
                                  charg = ls_mseg-charg.
      IF sy-subrc = 0.
        READ TABLE gt_ausp INTO DATA(ls_ausp) WITH KEY objek = ls_mch1-objek.
        IF sy-subrc = 0.
          <fs_out>-atwrt   = ls_ausp-atwrt.
        ENDIF.
      ENDIF.

      READ TABLE t_lfa1 INTO DATA(ls_lfa1) WITH KEY lifnr = ls_mseg-lifnr.
      IF sy-subrc EQ 0.
        <fs_out>-name1  = ls_lfa1-name1.
      ENDIF.

      READ TABLE t_makt INTO DATA(ls_makt) WITH KEY matnr = ls_mseg-matnr.
      IF sy-subrc EQ 0.
        <fs_out>-maktx  = ls_makt-maktx.
      ENDIF.

*    READ TABLE t_mkpf WITH KEY mblnr = t_mseg-mblnr
*                               mjahr = t_mseg-mjahr.
*    IF sy-subrc EQ 0.
*      t_out-budat  = t_mkpf-budat.
*      t_out-cpudt  = t_mkpf-cpudt.
*      t_out-cputm  = t_mkpf-cputm.
*    ENDIF.

      READ TABLE t_ekpo INTO DATA(ls_ekpo) WITH KEY ebeln = ls_mseg-ebeln
                                 ebelp = ls_mseg-ebelp.
      IF sy-subrc EQ 0.
        <fs_out>-pouom  = ls_ekpo-meins.
        <fs_out>-poqty  = ls_ekpo-menge.

*     Convert GR qty if PO UoM <> GR UoM (ekpo-meins <> mseg-meins)
        IF ls_ekpo-meins NE ls_mseg-meins.
          IF ls_ekpo-meins NE ls_ekpo-bprme AND ls_mseg-meins EQ ls_ekpo-bprme.
            <fs_out>-menge = ls_mseg-menge * ls_ekpo-bpumn / ls_ekpo-bpumz.
          ELSE.
            IF ls_ekpo-meins NE ls_ekpo-lmein AND ls_mseg-meins EQ ls_ekpo-lmein.
              <fs_out>-menge = ls_mseg-menge * ls_ekpo-umren / ls_ekpo-umrez.
            ENDIF.
          ENDIF.
        ENDIF.
*     ---end Convert
      ENDIF.

      CASE ls_mseg-bwart.
        WHEN '101'.
          <fs_out>-menge101 = <fs_out>-menge.
        WHEN '102'.
          <fs_out>-menge    = <fs_out>-menge * -1.
          <fs_out>-menge102 = <fs_out>-menge.
        WHEN '122'.
          <fs_out>-menge    = <fs_out>-menge * -1.
          <fs_out>-menge122 = <fs_out>-menge.
        WHEN '123'.
          <fs_out>-menge123 = <fs_out>-menge.
      ENDCASE.

*    CHANGE THIS CODE
*      ON CHANGE OF ls_mseg-ebeln OR ls_mseg-ebelp.
*        CLEAR: ld_etenr, flag_timediff.
*      ENDON.
      IF lv_ebeln_a <> ls_mseg-ebeln OR lv_ebelp_a <> ls_mseg-ebelp.
        lv_ebeln_a = ls_mseg-ebeln.
        lv_ebelp_a = ls_mseg-ebelp.
        CLEAR: ld_etenr, flag_timediff.
      ENDIF.


      ADD 1 TO ld_etenr.

*   Get OSO Qty
      LOOP AT t_ekbe INTO DATA(ls_ekbe) WHERE ebeln EQ <fs_out>-ebeln AND
                           ebelp EQ <fs_out>-ebelp.

        IF ls_ekbe-shkzg EQ 'H'.
          ls_ekbe-menge = ls_ekbe-menge * -1.
        ENDIF.

        IF ls_ekbe-budat EQ <fs_out>-budat AND
          ls_ekbe-belnr GT <fs_out>-mblnr.
          EXIT.
        ENDIF.

        IF ls_ekbe-budat LE <fs_out>-budat.
          CASE ls_ekbe-bwart.
            WHEN 101.
              IF ld_flag IS INITIAL.
                ld_flag = 1.
                <fs_out>-povgr = <fs_out>-poqty - ls_ekbe-menge.
              ELSE.
                <fs_out>-povgr = ld_povgr - ls_ekbe-menge.
              ENDIF.
            WHEN 102.
              IF ld_flag IS INITIAL.
                ld_flag = 1.
                <fs_out>-povgr = <fs_out>-poqty - ls_ekbe-menge.
              ELSE.
                <fs_out>-povgr = ld_povgr - ls_ekbe-menge.
              ENDIF.
            WHEN 122.
              IF ld_flag IS INITIAL.
                ld_flag = 1.
                <fs_out>-povgr = <fs_out>-poqty - ls_ekbe-menge.
              ELSE.
                <fs_out>-povgr = ld_povgr - ls_ekbe-menge.
              ENDIF.
            WHEN 123.
              IF ld_flag IS INITIAL.
                ld_flag = 1.
                <fs_out>-povgr = <fs_out>-poqty - ls_ekbe-menge.
              ELSE.
                <fs_out>-povgr = ld_povgr - ls_ekbe-menge.
              ENDIF.
          ENDCASE.
          ld_povgr = <fs_out>-povgr.
        ENDIF.

*      IF t_ekbe-belnr LE t_out-mblnr.
*        IF t_ekbe-budat EQ t_out-budat.
*          IF t_ekbe-cpudt GT t_out-cpudt.
*            IF t_ekbe-cputm LT t_out-cputm.
*              IF t_ekbe-bwart NE '122'.
*                EXIT.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*        IF ld_flag IS INITIAL.
*          ld_flag = 1.
*          t_out-povgr = t_out-poqty - t_ekbe-menge.
*        ELSE.
*          t_out-povgr = ld_povgr - t_ekbe-menge.
*        ENDIF.
*        ld_povgr = t_out-povgr.
*      ENDIF.
      ENDLOOP.

*   Get RDTV Qty
*    LOOP AT t_ekbe1 WHERE lfbnr EQ t_out-mblnr AND
*                          lfpos EQ t_out-ebelp.
*      IF t_ekbe1-shkzg EQ 'H'.
*        t_ekbe1-menge = t_ekbe1-menge * -1.
*      ENDIF.
*      ADD t_ekbe1-menge TO t_out-rdtv.
*    ENDLOOP.
      CLEAR: ld_flag.

*    CHANGE THIS CODE
*      ON CHANGE OF ls_mseg-ebeln OR ls_mseg-ebelp.
*        <fs_out>-poqtyout  = <fs_out>-poqty.
*        CLEAR : openpo_flag, ld_menge, ld_addmenge, ld_schedline.
*      ENDON.

      IF lv_ebeln_b <> ls_mseg-ebeln OR lv_ebelp_b <> ls_mseg-ebelp.
        lv_ebeln_b = ls_mseg-ebeln.
        lv_ebelp_b = ls_mseg-ebelp.
        <fs_out>-poqtyout  = <fs_out>-poqty.
        CLEAR : openpo_flag, ld_menge, ld_addmenge, ld_schedline.
      ENDIF.

*   Get % OSO Qty
      IF <fs_out>-poqty IS NOT INITIAL.
        <fs_out>-percen  = <fs_out>-povgr * 100 / <fs_out>-poqty.
      ENDIF.

* UD Process
      READ TABLE t_qmdata INTO DATA(ls_qmdata) WITH KEY mblnr = ls_mseg-mblnr
                                   mjahr = ls_mseg-mjahr
                                   matnr = ls_mseg-matnr
                                   charg = ls_mseg-charg.
*   Get UD Code, UD date, UD Qty (UU & Block stock)
      IF sy-subrc EQ 0.
        <fs_out>-lmenge01  = ls_qmdata-lmenge01.
        <fs_out>-lmenge04  = ls_qmdata-lmenge04.
        <fs_out>-qkennzahl = ls_qmdata-qkennzahl.
        <fs_out>-vcode     = ls_qmdata-vcode.
        <fs_out>-vdatum    = ls_qmdata-vdatum.
      ENDIF.

*   Get PO schedule delivery, time difference
      CLEAR : ld_line.
      LOOP AT t_eket INTO DATA(ls_eket) WHERE ebeln EQ ls_mseg-ebeln AND
                           ebelp EQ ls_mseg-ebelp.
        ADD 1 TO ld_line.
        IF ld_line GT 1.
          EXIT.
        ENDIF.
      ENDLOOP.

      ld_addmenge  = <fs_out>-poqty - <fs_out>-povgr. " + t_out-rdtv.
      ld_menge = ld_addmenge.
      ld_qty_gr = <fs_out>-menge.

      LOOP AT t_eket INTO ls_eket WHERE ebeln EQ <fs_out>-ebeln AND
                           ebelp EQ <fs_out>-ebelp.
        <fs_out>-eindt     = ls_eket-eindt.
        <fs_out>-etenr     = ls_eket-etenr.
        <fs_out>-podlvqty  = ls_eket-menge.

*     Change Qty OSO (if there is an RDTV).
*      IF t_out-rdtv IS NOT INITIAL.
*        t_out-povgr = t_out-povgr - t_out-rdtv.
*      ENDIF.

        IF ld_menge GE <fs_out>-podlvqty.
          ld_menge      = ld_menge - <fs_out>-podlvqty.
          IF ld_line GT 1.
            <fs_out>-openpo  = 0.
            IF ls_eket-etenr GT ld_schedline.
              <fs_out>-tmdif  = <fs_out>-budat - ls_eket-eindt.
              ld_schedline = ls_eket-etenr.
            ENDIF.
          ELSE.
            <fs_out>-openpo  = <fs_out>-povgr.
            <fs_out>-tmdif   = <fs_out>-budat - ls_eket-eindt.
          ENDIF.
        ELSE.
          IF openpo_flag IS INITIAL.
            ld_menge      = <fs_out>-podlvqty - ld_menge.
            IF ld_line GT 1.
              <fs_out>-openpo  = ld_menge.

*           Check "Schedule Qty PO", if it changed then input "time difference"
              IF ld_menge NE <fs_out>-podlvqty.
                <fs_out>-tmdif = <fs_out>-budat - ls_eket-eindt.

*             This "IF" is used if "Schedule Qty PO"(that has full-qty) opens again now(because of RDTV/Cancel GR)
                IF ld_schedline GE ls_eket-etenr.
                  ld_schedline = ls_eket-etenr - 1.
                ENDIF.
              ENDIF.

            ELSE.
              <fs_out>-openpo  = <fs_out>-povgr.
              <fs_out>-tmdif   = <fs_out>-budat - ls_eket-eindt.
            ENDIF.
            openpo_flag = 1.
            ld_menge = 0.
          ELSE.
            IF ld_line GT 1.
              <fs_out>-openpo  = <fs_out>-podlvqty.
            ELSE.
              <fs_out>-openpo  = <fs_out>-povgr.
              <fs_out>-tmdif   = <fs_out>-budat - ls_eket-eindt.
            ENDIF.
          ENDIF.
        ENDIF.

*     This "IF" is used to handle "time difference" if there is a "GR history" that isn't displayed from the first time of GR.
        IF flag_timediff IS INITIAL AND <fs_out>-openpo = 0 AND ld_qty_gr LT ld_addmenge.
          ld_eket_qty = ld_eket_qty + ls_eket-menge.
          ld_previousgr = ld_addmenge - ld_qty_gr.
          IF ld_eket_qty LE ld_previousgr.
            <fs_out>-tmdif = 0.
          ENDIF.
        ENDIF.

*        APPEND t_out.
*        CLEAR: t_out-vcode, t_out-vdatum, t_out-lmenge01, t_out-lmenge04, t_out-menge,
*               t_out-poqtyout, t_out-menge101, t_out-menge102, t_out-menge122, t_out-menge123,
*               t_out-povgr, t_out-percen, t_out-podlvqty, t_out-etenr, t_out-openpo,
*               t_out-rdtv, t_out-tmdif.
      ENDLOOP.
      flag_timediff = 1.
      CLEAR: openpo_flag, ld_eket_qty, ld_previousgr, ld_qty_gr.

      ld_mblnr = <fs_out>-mblnr.

* Notification Process
      LOOP AT t_viqmel INTO DATA(ls_viqmel) WHERE matnr  EQ ls_mseg-matnr AND
                             mawerk EQ ls_mseg-werks AND
                             charg  EQ ls_mseg-charg.

*        CLEAR: t_out-vcode, t_out-vdatum, t_out-lmenge01, t_out-lmenge04, t_out-menge,
*               t_out-menge101, t_out-menge102, t_out-menge122, t_out-menge123,
*               t_out-povgr, t_out-percen,  t_out-tmdif, t_out-poqtyout, t_out-podlvqty,
*               t_out-etenr, t_out-openpo, t_out-rdtv, t_out-eindt, t_out-poqty, t_out-qmdat,
*               t_out-qmnum, t_out-qmtxt, t_out-rkmng, t_out-prueflos.

        IF ls_viqmel-qmdat GE <fs_out>-budat.
          IF ls_viqmel-prueflos IS INITIAL.
            <fs_out>-qmdat    = ls_viqmel-qmdat.
            <fs_out>-qmnum    = ls_viqmel-qmnum.
            <fs_out>-qmgrp    = ls_viqmel-qmgrp.
            <fs_out>-qmcod    = ls_viqmel-qmcod.
            <fs_out>-qmtxt    = ls_viqmel-qmtxt.
            <fs_out>-rkmng    = ls_viqmel-rkmng.
            <fs_out>-prueflos = ls_viqmel-prueflos.

*            APPEND t_out.
          ELSE.
            LOOP AT t_out INTO DATA(ls_out) WHERE mblnr EQ ls_viqmel-mblnr AND
                                matnr EQ ls_mseg-matnr   AND
                                charg EQ ls_mseg-charg.
              IF ld_notif_line1 IS INITIAL.
                ls_out-qmdat    = ls_viqmel-qmdat.
                ls_out-qmnum    = ls_viqmel-qmnum.
                ls_out-qmgrp    = ls_viqmel-qmgrp.
                ls_out-qmcod    = ls_viqmel-qmcod.
                ls_out-qmtxt    = ls_viqmel-qmtxt.
                ls_out-rkmng    = ls_viqmel-rkmng.
                ls_out-prueflos = ls_viqmel-prueflos.

                MODIFY t_out FROM ls_out TRANSPORTING qmdat qmnum qmgrp qmcod qmtxt rkmng prueflos.
                ld_notif_line1 = 1.
              ENDIF.
            ENDLOOP.
            CLEAR: ld_notif_line1.
          ENDIF.
        ENDIF.
      ENDLOOP.

*      CLEAR: t_out.
    ENDLOOP.
  ENDMETHOD.

  METHOD free_memory.
    REFRESH: t_msegdata, t_mseg, t_mkpf, t_viqmel, t_eket,
             t_ekpo, t_lifnr, t_matnr, t_lfa1, t_makt.
    CLEAR: t_msegdata, t_mseg, t_mkpf, t_viqmel, t_eket,
           t_ekpo, t_lifnr, t_matnr, t_lfa1, t_makt.
  ENDMETHOD.
ENDCLASS.
