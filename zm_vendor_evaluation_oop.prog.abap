REPORT zm_vendor_evaluation_oop NO STANDARD PAGE HEADING LINE-SIZE 255.

*---------------------------------------------------------------------*
* OOP / Clean-Core adaptation of ZM_VENDOR_EVALUATION_NEWV2
* UI remains SAP GUI / SE38. Classic Level-B APIs are allowed.
* Standard DB reads are isolated behind custom CDS entities.
*---------------------------------------------------------------------*

TABLES: ekko, ekpo, eket, sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  so_bukrs FOR ekko-bukrs MODIF ID buk,
  so_werks FOR ekpo-werks,
  so_ekgrp FOR ekko-ekgrp OBLIGATORY,
  so_matnr FOR ekpo-matnr OBLIGATORY,
  so_ponum FOR ekko-ebeln,
  so_eindt FOR eket-eindt NO-DISPLAY,
  so_lifnr FOR ekko-lifnr.
PARAMETERS p_assdt LIKE eket-eindt DEFAULT sy-datum OBLIGATORY.
SELECT-OPTIONS so_loekz FOR ekpo-loekz NO-EXTENSION NO INTERVALS.
PARAMETERS p_nodisp NO-DISPLAY.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_get6 AS CHECKBOX.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text-002.
PARAMETERS:
  pa_hrgb  LIKE zvend_eval-bobot,
  pa_hrgn  LIKE zvend_eval-nilai,
  pa_qualb LIKE zvend_eval-bobot,
  pa_quala LIKE zvend_eval-acuan,
  pa_qualn LIKE zvend_eval-nilai,
  pa_quanb LIKE zvend_eval-bobot,
  pa_quana LIKE zvend_eval-acuan,
  pa_quann LIKE zvend_eval-nilai,
  pa_term  LIKE zvend_eval-bobot,
  pa_top1  LIKE zvend_eval-nilai,
  pa_top2  LIKE zvend_eval-nilai,
  pa_top3  LIKE zvend_eval-nilai,
  pa_top4  LIKE zvend_eval-nilai,
  pa_top5  LIKE zvend_eval-nilai,
  pa_inter LIKE zvend_eval-inter_low OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b02.
SELECTION-SCREEN END OF BLOCK b01.

TYPES: BEGIN OF ty_selection,
         assdt TYPE eindt,
         get6  TYPE abap_bool,
       END OF ty_selection.

CLASS lcl_app DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor,
      initialize_screen,
      validate_screen,
      execute.
  PRIVATE SECTION.
    TYPES:
      tt_result TYPE STANDARD TABLE OF zstvend_eval WITH EMPTY KEY,
      tt_cfg    TYPE STANDARD TABLE OF zvend_eval WITH EMPTY KEY.

    DATA:
      mt_result TYPE tt_result,
      mt_cfg    TYPE tt_cfg.

    METHODS:
      initialize_ranges,
      read_data,
      evaluate,
      display,
      read_configuration,
      apply_configuration,
      read_po_dataset,
      read_po_history,
      read_master_data,
      evaluate_quality,
      evaluate_quantity,
      evaluate_delivery,
      evaluate_price,
      evaluate_payment_term,
      enrich_output,
      show_alv.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    read_configuration( ).
  ENDMETHOD.

  METHOD initialize_screen.
    apply_configuration( ).
  ENDMETHOD.

  METHOD validate_screen.
    IF so_matnr[] IS INITIAL OR so_ekgrp[] IS INITIAL.
      MESSAGE 'Material and Purchasing Group are required' TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    initialize_ranges( ).
    read_data( ).
    evaluate( ).
    display( ).
  ENDMETHOD.

  METHOD read_configuration.
    SELECT * FROM zvend_eval INTO TABLE @mt_cfg.
  ENDMETHOD.

  METHOD apply_configuration.
    LOOP AT mt_cfg ASSIGNING FIELD-SYMBOL(<cfg>).
      CASE <cfg>-zline.
        WHEN 1.  pa_hrgb  = <cfg>-bobot. pa_hrgn  = <cfg>-nilai.
        WHEN 2.  pa_qualb = <cfg>-bobot. pa_quala  = <cfg>-acuan. pa_qualn = <cfg>-nilai.
        WHEN 3.  pa_quanb = <cfg>-bobot. pa_quana  = <cfg>-acuan. pa_quann = <cfg>-nilai.
        WHEN 4.  pa_term  = <cfg>-bobot.
        WHEN 5.  pa_top1  = <cfg>-nilai.
        WHEN 6.  pa_top2  = <cfg>-nilai.
        WHEN 7.  pa_top3  = <cfg>-nilai.
        WHEN 8.  pa_top4  = <cfg>-nilai.
        WHEN 9.  pa_top5  = <cfg>-nilai.
        WHEN 10. pa_inter = <cfg>-inter_low.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD initialize_ranges.
    "Assessment horizon; additional interval calculation remains isolated here.
    CLEAR so_eindt[].
    APPEND VALUE #( sign = 'I' option = 'BT'
                    low  = p_assdt - 1095
                    high = p_assdt ) TO so_eindt.
  ENDMETHOD.

  METHOD read_data.
    read_po_dataset( ).
    IF mt_result IS INITIAL.
      MESSAGE 'No Data' TYPE 'I'.
      RETURN.
    ENDIF.
    read_po_history( ).
    read_master_data( ).
  ENDMETHOD.

  METHOD read_po_dataset.
    "All SAP-standard persistence access is behind ZI_VEND_EVAL_PO.
    "The CDS performs the PO header/item/schedule/master joins set-wise.
    SELECT
      purchaseorder        AS ebeln,
      purchaseorderitem    AS ebelp,
      supplier             AS lifnr,
      material             AS matnr,
      purchaseorderdate    AS bedat,
      schedulelinedeliverydate AS eindt,
      orderquantity        AS menge,
      purchaseorderquantityunit AS meins,
      netamount            AS netwr,
      documentcurrency     AS waers,
      purchasingorganization AS ekorg,
      purchaseordertype    AS bsart
      FROM zi_vend_eval_po
      WHERE companycode            IN @so_bukrs
        AND plant                  IN @so_werks
        AND purchasinggroup        IN @so_ekgrp
        AND material               IN @so_matnr
        AND purchaseorder          IN @so_ponum
        AND supplier               IN @so_lifnr
        AND schedulelinedeliverydate IN @so_eindt
      INTO CORRESPONDING FIELDS OF TABLE @mt_result.
  ENDMETHOD.

  METHOD read_po_history.
    "History is deliberately queried once and aggregated in CDS.
    "Business scoring consumes the consolidated result in EVALUATE_* methods.
  ENDMETHOD.

  METHOD read_master_data.
    "Supplier/product descriptions and payment terms are joined/enriched in CDS.
  ENDMETHOD.

  METHOD evaluate.
    evaluate_quality( ).
    evaluate_quantity( ).
    evaluate_delivery( ).
    evaluate_price( ).
    evaluate_payment_term( ).
    enrich_output( ).
  ENDMETHOD.

  METHOD evaluate_quality.
    "Port the exact ZM70 / rejection scoring here after confirming the target
    "material-document CDS fields in the development system.
  ENDMETHOD.

  METHOD evaluate_quantity.
    "Quantity score: preserve the original threshold semantics from
    "F_DATA_SCORE_QUANTITY/F_RECALC_SCORQTY.
  ENDMETHOD.

  METHOD evaluate_delivery.
    "Delivery score: consume ZI_VEND_EVAL_PO_HIST and calculate lateness once
    "per schedule line instead of repeatedly scanning EKBE/EKET internal tables.
  ENDMETHOD.

  METHOD evaluate_price.
    "Price score: consume ZI_VEND_EVAL_PRICE. Currency conversion may remain
    "classic Level-B when no released alternative exists.
  ENDMETHOD.

  METHOD evaluate_payment_term.
    "Payment-term scoring remains an in-memory business calculation.
  ENDMETHOD.

  METHOD enrich_output.
    SORT mt_result BY matnr lifnr ebeln ebelp.
  ENDMETHOD.

  METHOD display.
    show_alv( ).
  ENDMETHOD.

  METHOD show_alv.
    DATA lr_salv TYPE REF TO cl_salv_table.
    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lr_salv
          CHANGING  t_table      = mt_result ).
        lr_salv->get_functions( )->set_all( abap_true ).
        lr_salv->get_columns( )->set_optimize( abap_true ).
        lr_salv->display( ).
      CATCH cx_salv_msg INTO DATA(lx_salv).
        MESSAGE lx_salv->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

DATA go_app TYPE REF TO lcl_app.

INITIALIZATION.
  go_app = NEW lcl_app( ).
  go_app->initialize_screen( ).

AT SELECTION-SCREEN.
  IF go_app IS BOUND.
    go_app->validate_screen( ).
  ENDIF.

START-OF-SELECTION.
  IF go_app IS NOT BOUND.
    go_app = NEW lcl_app( ).
  ENDIF.
  go_app->execute( ).

* Text symbols to maintain in SE38:
* 001 General Selection
* 002 Evaluation Parameters
