*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005F01                                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.
  DATA : ls_csks    LIKE LINE OF gt_csks.

  CLEAR s_monat.
  READ TABLE s_monat INDEX 1.
  CONCATENATE p_gjahr '0101' INTO gr_bedat-low.
  CONCATENATE p_gjahr p_monat '01' INTO gr_bedat-high.
  gr_mbedat-low  = gr_bedat-high.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = gr_bedat-high
    IMPORTING
      last_day_of_month = gr_bedat-high.
  gr_bedat-sign = 'I'.
  gr_bedat-option = 'BT'.
  APPEND gr_bedat. CLEAR gr_bedat.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = gr_mbedat-low
    IMPORTING
      last_day_of_month = gr_mbedat-high.
  gr_mbedat-sign = 'I'.
  gr_mbedat-option = 'BT'.
  APPEND gr_mbedat. CLEAR gr_mbedat.

  gr_ybedat[] = gr_bedat[].
  CLEAR gr_ybedat.

  s_monat-sign = 'I'.
  s_monat-option = 'BT'.
  s_monat-low = '01'.
  s_monat-high = p_monat.
  APPEND s_monat. CLEAR s_monat.

  LOOP AT gt_csks INTO ls_csks.
    IF ls_csks-kostl IN s_kostl AND
      ls_csks-gsber IN s_gsber AND
      ls_csks-khinr IN s_khinr.
      CONTINUE.
    ELSE.
      DELETE TABLE gt_csks FROM ls_csks.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_init_data

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_ebkn    TYPE STANDARD TABLE OF ty_ebkn.

  SELECT * INTO TABLE gt_zcodt001
    FROM zcodt001 WHERE bukrs = p_bukrs
                    AND kstar IN s_kstar.

  IF sy-subrc = 0.
* Get Budget
    SELECT kokrs belnr buzei perbl kstar wtg001 wtg002 wtg003
           wtg004 wtg005 wtg006 wtg007 wtg008 wtg009 wtg010
           wtg011 wtg012 twaer objnr
      INTO CORRESPONDING FIELDS OF TABLE gt_coej
      FROM coej FOR ALL ENTRIES IN gt_zcodt001
      WHERE kstar = gt_zcodt001-kstar
        AND gjahr = p_gjahr
        AND kokrs = p_bukrs.

    IF gt_coej[] IS NOT INITIAL.
*      SELECT kokrs kostl objnr
*        INTO CORRESPONDING FIELDS OF TABLE gt_csks
*        FROM csks FOR ALL ENTRIES IN gt_coej
*        WHERE objnr = gt_coej-objnr.
    ENDIF.

* Get Actual
    SELECT bukrs belnr gjahr blart bldat budat monat waers
      INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
      FROM bkpf WHERE bukrs = p_bukrs
                  AND gjahr = p_gjahr
                  AND monat IN s_monat.
    IF gt_bkpf[] IS NOT INITIAL.
      SELECT bukrs belnr gjahr buzei shkzg gsber dmbtr wrbtr kostl hkont
        INTO CORRESPONDING FIELDS OF TABLE gt_bseg
        FROM bseg FOR ALL ENTRIES IN gt_bkpf
        WHERE bukrs = gt_bkpf-bukrs
          AND belnr = gt_bkpf-belnr
          AND gjahr = gt_bkpf-gjahr
          AND gsber IN s_gsber
          AND kostl IN s_kostl
          AND hkont IN s_kstar.
    ENDIF.

* Get Commitment
    SELECT a~banfn a~bnfpo a~werks a~bedat a~ebeln a~ebelp
           b~zebkn b~sakto b~kostl b~netwr
      INTO CORRESPONDING FIELDS OF TABLE gt_ebkn
      FROM eban AS a JOIN ebkn AS b ON a~banfn = b~banfn AND
                                       a~bnfpo = b~bnfpo
      WHERE werks IN s_gsber
        AND bedat IN gr_bedat
        AND kostl IN s_kostl
        AND sakto IN s_kstar.

    lt_ebkn[] = gt_ebkn[].
    DELETE lt_ebkn WHERE kostl IS INITIAL.

    IF lt_ebkn[] IS NOT INITIAL.
      SELECT ebeln bedat waers
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE gt_ekko
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln.

      SELECT ebeln ebelp netwr netpr peinh txz01
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln.

      SELECT ebeln ebelp etenr menge wemng
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE gt_eket
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln.

      SELECT ebeln ebelp zekkn sakto gsber kostl
        FROM ekkn
        INTO CORRESPONDING FIELDS OF TABLE gt_ekkn
        FOR ALL ENTRIES IN lt_ebkn
        WHERE ebeln = lt_ebkn-ebeln
          AND kostl IN s_kostl
          AND sakto IN s_kstar.

      PERFORM f_filter_po.
    ENDIF.
  ELSE.
    MESSAGE 'Please maintain ZCODT001' TYPE 'I' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: lv_field  TYPE char50,
        lv_monat  TYPE monat,
        lv_budget TYPE mc_umkzwi1,
        lv_budget2 TYPE mc_umkzwi1,
        lv_dmbtr  TYPE dmbtr,
        lv_spmon  TYPE spmon,
        lv_netwr  TYPE bwert,
        lv_kgrp1  TYPE char50,
        lv_kgrp2  TYPE char50.

  FIELD-SYMBOLS: <fs_field> TYPE ANY.

* Process Budget
  LOOP AT gt_coej.
    CLEAR: gt_csks,gt_zcodt001,lv_monat,lv_budget,lv_budget2,s_monat.
    READ TABLE gt_csks WITH KEY objnr = gt_coej-objnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_zcodt001 WITH KEY kstar = gt_coej-kstar.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    IF gt_coej-twaer IS INITIAL.
      gt_coej-twaer = 'IDR'.
    ENDIF.

    "Summaries budget
    READ TABLE s_monat INDEX 1.
    lv_monat = s_monat-low.
    WHILE lv_monat LE s_monat-high.
      CLEAR: lv_field.
      UNASSIGN: <fs_field>.
      CONCATENATE 'GT_COEJ-WTG0' lv_monat INTO lv_field.
      ASSIGN (lv_field) TO <fs_field>.
      ADD <fs_field> TO lv_budget.
      ADD 1 TO lv_monat.
    ENDWHILE.

    CLEAR: lv_field.
    UNASSIGN: <fs_field>.
    CONCATENATE 'GT_COEJ-WTG0' p_monat INTO lv_field.
    ASSIGN (lv_field) TO <fs_field>.
    lv_budget2 = <fs_field>.

    CLEAR: lv_kgrp1,lv_kgrp2.
    PERFORM f_get_kgrp USING gt_zcodt001-kgrp1 gt_zcodt001-kgrp2
                       CHANGING lv_kgrp1 lv_kgrp2.

    READ TABLE gt_out ASSIGNING <fs_out>
                      WITH KEY kgrp1 = lv_kgrp1
                               kgrp2 = lv_kgrp2
                               kstar = gt_zcodt001-kstar
                               kostl = gt_csks-kostl.
    IF sy-subrc = 0.
      <fs_out>-mtdbud = <fs_out>-mtdbud + lv_budget2.
      <fs_out>-ytdbud = <fs_out>-ytdbud + lv_budget.

    ELSE.
      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-kgrp1  = lv_kgrp1.
      <fs_out>-kgrp2  = lv_kgrp2.
      <fs_out>-kostl  = gt_csks-kostl.
      <fs_out>-khinr  = gt_csks-khinr.
      <fs_out>-kstar  = gt_zcodt001-kstar.
      <fs_out>-twaer  = gt_coej-twaer.
      <fs_out>-mtdbud = lv_budget2.
      <fs_out>-ytdbud = lv_budget.
      CONCATENATE p_gjahr p_monat INTO <fs_out>-spmon.
    ENDIF.
  ENDLOOP.

* Process Actual
  LOOP AT gt_bseg.
    CLEAR: gt_csks,gt_bkpf,gt_zcodt001,lv_dmbtr.
    READ TABLE gt_zcodt001 WITH KEY kstar = gt_bseg-hkont.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_csks WITH KEY kostl = gt_bseg-kostl.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    CLEAR: lv_kgrp1,lv_kgrp2.
    PERFORM f_get_kgrp USING gt_zcodt001-kgrp1 gt_zcodt001-kgrp2
                       CHANGING lv_kgrp1 lv_kgrp2.

    READ TABLE gt_bkpf WITH KEY bukrs = gt_bseg-bukrs
                                belnr = gt_bseg-belnr
                                gjahr = gt_bseg-gjahr.

    IF gt_bkpf-waers IS INITIAL.
      gt_coej-twaer = 'IDR'.
    ENDIF.

    IF gt_bkpf-monat = p_monat.
      IF gt_bseg-shkzg = 'H'.
        lv_dmbtr = gt_bseg-dmbtr * -1.
      ELSE.
        lv_dmbtr = gt_bseg-dmbtr.
      ENDIF.
    ELSE.
      CLEAR lv_dmbtr.
    ENDIF.

    READ TABLE gt_out ASSIGNING <fs_out>
                      WITH KEY kgrp1 = lv_kgrp1
                               kgrp2 = lv_kgrp2
                               kstar = gt_zcodt001-kstar
                               kostl = gt_bseg-kostl.
    IF sy-subrc = 0.
      <fs_out>-mtdact = <fs_out>-mtdact + lv_dmbtr.
      IF gt_bseg-shkzg = 'H'.
        <fs_out>-ytdact = <fs_out>-ytdact + ( gt_bseg-dmbtr * -1 ).
      ELSE.
        <fs_out>-ytdact = <fs_out>-ytdact + gt_bseg-dmbtr.
      ENDIF.
    ELSE.
      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-kgrp1  = lv_kgrp1.
      <fs_out>-kgrp2  = lv_kgrp2.
      <fs_out>-kostl  = gt_bseg-kostl.
      <fs_out>-kstar  = gt_zcodt001-kstar.
      <fs_out>-twaer  = gt_bkpf-waers.
      <fs_out>-mtdact = lv_dmbtr.
      IF gt_bseg-shkzg = 'H'.
        <fs_out>-ytdact = gt_bseg-dmbtr * -1.
      ELSE.
        <fs_out>-ytdact = gt_bseg-dmbtr.
      ENDIF.
      CONCATENATE p_gjahr p_monat INTO <fs_out>-spmon.
    ENDIF.
  ENDLOOP.

* Process Commitment
  CONCATENATE p_gjahr p_monat INTO lv_spmon.
  LOOP AT gt_ebkn.
    CLEAR: gt_csks,gt_zcodt001,lv_netwr.
    READ TABLE gt_zcodt001 WITH KEY kstar = gt_ebkn-sakto.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    READ TABLE gt_csks WITH KEY kostl = gt_ebkn-kostl.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    CLEAR: lv_kgrp1,lv_kgrp2.
    PERFORM f_get_kgrp USING gt_zcodt001-kgrp1 gt_zcodt001-kgrp2
                       CHANGING lv_kgrp1 lv_kgrp2.

    IF gt_ebkn-bedat(6) = lv_spmon.
      lv_netwr = gt_ebkn-netwr.
    ELSE.
      CLEAR lv_netwr.
    ENDIF.

    READ TABLE gt_out ASSIGNING <fs_out>
                      WITH KEY kgrp1 = lv_kgrp1
                               kgrp2 = lv_kgrp2
                               kstar = gt_zcodt001-kstar
                               kostl = gt_ebkn-kostl.
    IF sy-subrc = 0.
      <fs_out>-mtdcom = <fs_out>-mtdact + lv_netwr.
      <fs_out>-ytdcom = <fs_out>-ytdbud + gt_ebkn-netwr.
    ELSE.
      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-kgrp1  = lv_kgrp1.
      <fs_out>-kgrp2  = lv_kgrp2.
      <fs_out>-kostl  = gt_ebkn-kostl.
      <fs_out>-kstar  = gt_zcodt001-kstar.
      <fs_out>-twaer  = 'IDR'.
      <fs_out>-mtdcom = lv_netwr.
      <fs_out>-ytdcom = gt_ebkn-netwr.
      CONCATENATE p_gjahr p_monat INTO <fs_out>-spmon.
    ENDIF.
  ENDLOOP.

  PERFORM f_calculate_data.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DATA message TYPE REF TO cx_salv_msg.
  DATA lr_events TYPE REF TO cl_salv_events_table.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = gr_alv
                              CHANGING  t_table   = gt_out ).
    CATCH cx_salv_msg INTO message.
      " error handling
  ENDTRY.

  PERFORM f_set_columns.
  PERFORM f_set_total.
  PERFORM f_set_sort.

  gr_function = gr_alv->get_functions( ).
  gr_function->set_all( abap_true ).
  lr_events   = gr_alv->get_event( ).

  CREATE OBJECT gr_events.
  SET HANDLER gr_events->on_double_click FOR lr_events.

  gr_alv->display( ).
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR: gt_out,gt_zcodt001,gt_coej,gt_bseg.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_SET_COLUMNS
*&---------------------------------------------------------------------*
FORM f_set_columns .
*... §4 set the columns technical
  DATA: lr_columns TYPE REF TO cl_salv_columns_table, "cl_salv_columns,
        lr_column  TYPE REF TO cl_salv_column_table.

*... §4.1 optimize columns
  lr_columns = gr_alv->get_columns( ).
  lr_columns->set_optimize( ).

*... §4.2 change the name of the column in ALV
  lr_column ?= lr_columns->get_column( 'KGRP1' ).
  lr_column->set_long_text( 'Group 1' ).
  lr_column->set_medium_text( 'Group 1' ).
  lr_column->set_short_text( 'Group 1' ).

  lr_column ?= lr_columns->get_column( 'KGRP2' ).
  lr_column->set_long_text( 'Group 2' ).
  lr_column->set_medium_text( 'Group 2' ).
  lr_column->set_short_text( 'Group 2' ).

  lr_column ?= lr_columns->get_column( 'KSTAR' ).
  lr_column->set_long_text( 'Cost Element' ).
  lr_column->set_medium_text( 'Cost Element' ).
  lr_column->set_short_text( 'Cost Eleme' ).

  lr_column ?= lr_columns->get_column( 'SPMON' ).
  lr_column->set_long_text( 'Period' ).
  lr_column->set_medium_text( 'Period' ).
  lr_column->set_short_text( 'Period' ).

  lr_column ?= lr_columns->get_column( 'TWAER' ).
  lr_column->set_long_text( 'Currency' ).
  lr_column->set_medium_text( 'Currency' ).
  lr_column->set_short_text( 'Currency' ).

  lr_column ?= lr_columns->get_column( 'MTDBUD' ).
  lr_column->set_long_text( 'MTD Budget' ).
  lr_column->set_medium_text( 'MTD Budget' ).
  lr_column->set_short_text( 'MTD Budget' ).
  lr_column->set_currency_column( 'TWAER' ).

  lr_column ?= lr_columns->get_column( 'MTDACT' ).
  lr_column->set_long_text( 'MTD Actual' ).
  lr_column->set_medium_text( 'MTD Actual' ).
  lr_column->set_short_text( 'MTD Actual' ).
  lr_column->set_currency_column( 'TWAER' ).

  lr_column ?= lr_columns->get_column( 'MTDCOM' ).
  lr_column->set_long_text( 'MTD Commitment' ).
  lr_column->set_medium_text( 'MTD Commitment' ).
  lr_column->set_short_text( 'MTD Commit' ).
  lr_column->set_currency_column( 'TWAER' ).

  lr_column ?= lr_columns->get_column( 'MTDBAL' ).
  lr_column->set_long_text( 'MTD Balance' ).
  lr_column->set_medium_text( 'MTD Balance' ).
  lr_column->set_short_text( 'MTD Balanc' ).
  lr_column->set_currency_column( 'TWAER' ).

  lr_column ?= lr_columns->get_column( 'YTDBUD' ).
  lr_column->set_long_text( 'YTD Budget' ).
  lr_column->set_medium_text( 'YTD Budget' ).
  lr_column->set_short_text( 'YTD Budget' ).
  lr_column->set_currency_column( 'TWAER' ).

  lr_column ?= lr_columns->get_column( 'YTDACT' ).
  lr_column->set_long_text( 'YTD Actual' ).
  lr_column->set_medium_text( 'YTD Actual' ).
  lr_column->set_short_text( 'YTD Actual' ).
  lr_column->set_currency_column( 'TWAER' ).

  lr_column ?= lr_columns->get_column( 'YTDCOM' ).
  lr_column->set_long_text( 'YTD Commitment' ).
  lr_column->set_medium_text( 'YTD Commitment' ).
  lr_column->set_short_text( 'YTD Commit' ).
  lr_column->set_currency_column( 'TWAER' ).

  lr_column ?= lr_columns->get_column( 'YTDBAL' ).
  lr_column->set_long_text( 'YTD Balance' ).
  lr_column->set_medium_text( 'YTD Balance' ).
  lr_column->set_short_text( 'YTD Balanc' ).
  lr_column->set_currency_column( 'TWAER' ).
ENDFORM.                    " F_SET_COLUMNS

*&---------------------------------------------------------------------*
*&      Form  F_SET_TOTAL
*&---------------------------------------------------------------------*
FORM f_set_total .
  DATA: lr_aggregations TYPE REF TO cl_salv_aggregations.

  lr_aggregations = gr_alv->get_aggregations( ).
  lr_aggregations->add_aggregation( columnname = 'MTDBUD' ).
  lr_aggregations->add_aggregation( columnname = 'MTDACT' ).
  lr_aggregations->add_aggregation( columnname = 'MTDCOM' ).
  lr_aggregations->add_aggregation( columnname = 'MTDBAL' ).
  lr_aggregations->add_aggregation( columnname = 'YTDBUD' ).
  lr_aggregations->add_aggregation( columnname = 'YTDACT' ).
  lr_aggregations->add_aggregation( columnname = 'YTDCOM' ).
  lr_aggregations->add_aggregation( columnname = 'YTDBAL' ).
ENDFORM.                    " F_SET_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_SET_SORT
*&---------------------------------------------------------------------*
FORM f_set_sort .
  DATA: lr_groups TYPE REF TO cl_salv_sorts .

  lr_groups = gr_alv->get_sorts( ) .
  lr_groups->add_sort( columnname = 'KGRP1'
                       position   = 1
                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
  lr_groups->add_sort( columnname = 'KGRP2'
                       position   = 2
                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
  lr_groups->add_sort( columnname = 'KOSTL'
                       position   = 3
*                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
  lr_groups->add_sort( columnname = 'KSTAR'
                       position   = 3
*                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
ENDFORM.                    " F_SET_SORT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_MONAT
*&---------------------------------------------------------------------*
FORM f_init_monat .
*  s_monat-sign = 'I'.
*  s_monat-option = 'BT'.
*  s_monat-low = '01'.
*  s_monat-high = sy-datum+4(2).
*  APPEND s_monat. CLEAR s_monat.

  g_repid = sy-repid.
ENDFORM.                    " F_INIT_MONAT

*&---------------------------------------------------------------------*
*&      Form  F_GET_KGRP
*&---------------------------------------------------------------------*
FORM f_get_kgrp  USING    fu_kgrp1
                          fu_kgrp2
                 CHANGING fc_kgrp1
                          fc_kgrp2.
  DATA: lv_text1 LIKE dd07v-ddtext,
        lv_text2 LIKE dd07v-ddtext.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
    EXPORTING
      i_domname  = 'ZKGRP1'
      i_domvalue = fu_kgrp1
    IMPORTING
      e_ddtext   = lv_text1.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
    EXPORTING
      i_domname  = 'ZKGRP2'
      i_domvalue = fu_kgrp2
    IMPORTING
      e_ddtext   = lv_text2.

  CONCATENATE fu_kgrp1 lv_text1 INTO fc_kgrp1
    SEPARATED BY ' - '.
  CONCATENATE fu_kgrp2 lv_text2 INTO fc_kgrp2
    SEPARATED BY ' - '.
ENDFORM.                    " F_GET_KGRP

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_subrc   TYPE sy-subrc,
         ls_csks    LIKE LINE OF gt_csks.

  IF s_kostl[] IS NOT INITIAL OR
    s_gsber[] IS NOT INITIAL.
    IF gt_csks[] IS INITIAL.
      SELECT kokrs kostl objnr gsber khinr
        INTO CORRESPONDING FIELDS OF TABLE gt_csks
        FROM csks
        WHERE kokrs = '8010'
          AND kostl IN s_kostl
          AND gsber IN s_gsber
          AND khinr IN s_khinr.

      lv_subrc = sy-subrc.
    ELSE.
      LOOP AT gt_csks INTO ls_csks.
        IF ls_csks-kostl IN s_kostl AND
          ls_csks-gsber IN s_gsber AND
          ls_csks-khinr IN s_khinr.
          CONTINUE.
        ELSE.
          DELETE TABLE gt_csks FROM ls_csks.
        ENDIF.
      ENDLOOP.
      IF gt_csks[] IS INITIAL.
        lv_subrc = 4.
      ENDIF.
    ENDIF.

    IF lv_subrc <> 0.
      PERFORM f_error_message USING 'CSK' 'Cost Center tidak sesuai dengan Business Area'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

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

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_DATA
*&---------------------------------------------------------------------*
FORM f_calculate_data .
  DATA : ls_out   LIKE LINE OF gt_out,
         ls_ekpo  LIKE LINE OF gt_ekpo.

  DATA : lv_mtdcom    TYPE mc_umkzwi1,
         lv_ytdcom    TYPE mc_umkzwi1,
         lv_mnetwr    TYPE ekpo-netwr,
         lv_ynetwr    TYPE ekpo-netwr,
         lv_mgrwrb    TYPE ekpo-netwr,
         lv_ygrwrb    TYPE ekpo-netwr,
         lv_msaldo    TYPE ekpo-netwr,
         lv_ysaldo    TYPE ekpo-netwr.

  DATA : lt_ebkn  TYPE TABLE OF ty_ebkn WITH HEADER LINE.

  lt_ebkn[] = gt_ebkn[].
  SORT lt_ebkn BY kostl sakto ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_ebkn COMPARING kostl sakto ebeln.

  LOOP AT gt_out INTO ls_out.
    LOOP AT gt_ebkn WHERE kostl = ls_out-kostl
                      AND sakto = ls_out-kstar.
*    LOOP AT lt_ebkn WHERE kostl = ls_out-kostl
*                      AND sakto = ls_out-kstar.

      LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = gt_ebkn-ebeln
                                     AND ebelp = gt_ebkn-ebelp.
*      LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = lt_ebkn-ebeln.
        IF gt_ebkn-bedat IN gr_mbedat.
*        IF lt_ebkn-bedat IN gr_mbedat.
          PERFORM f_get_eket USING ls_ekpo-ebeln ls_ekpo-ebelp
                                   ls_ekpo-netpr ls_ekpo-peinh
                             CHANGING lv_mgrwrb.
          lv_msaldo = ls_ekpo-netwr - lv_mgrwrb.
        ELSE.
          PERFORM f_get_eket USING ls_ekpo-ebeln ls_ekpo-ebelp
                                   ls_ekpo-netpr ls_ekpo-peinh
                             CHANGING lv_ygrwrb.
          lv_ysaldo = ls_ekpo-netwr - lv_ygrwrb.
        ENDIF.

        ADD lv_msaldo TO lv_mnetwr.
        ADD lv_ysaldo TO lv_ynetwr.

        CLEAR : lv_msaldo, lv_ysaldo.
      ENDLOOP.
    ENDLOOP.

    ls_out-mtdcom  = lv_mnetwr.
    ls_out-ytdcom  = lv_ynetwr + lv_mnetwr.

    ls_out-mtdbal  = ls_out-mtdbud - ls_out-mtdact - ls_out-mtdcom.
    ls_out-ytdbal  = ls_out-ytdbud - ls_out-ytdact - ls_out-ytdcom.

    MODIFY gt_out FROM ls_out TRANSPORTING mtdbal ytdbal mtdcom ytdcom.
    CLEAR : ls_out, lv_ynetwr, lv_mnetwr.
  ENDLOOP.
ENDFORM.                    " F_CALCULATE_DATA

*&---------------------------------------------------------------------*
*&      Form  SHOW_CELL_INFO
*&---------------------------------------------------------------------*
FORM show_cell_info  USING   fu_level  TYPE i
                             fu_row    TYPE i
                             fu_column TYPE lvc_fname
                             fu_text   TYPE string.

  TYPES : BEGIN OF ty_ekpo,
            ebeln   TYPE ekpo-ebeln,
            ebelp   TYPE ekpo-ebelp,
            waers   TYPE ekko-waers,
            netwr   TYPE ekpo-netwr,
          END OF ty_ekpo.

  DATA : lt_xekpo   TYPE STANDARD TABLE OF ty_ekpo,
         ls_xekpo   LIKE LINE OF lt_xekpo,
         ls_ekko    LIKE LINE OF gt_ekko,
         ls_ekpo    LIKE LINE OF gt_ekpo,
         ls_out     LIKE LINE OF gt_out.

*  DATA : ls_sd_alv TYPE sd_alv.

  PERFORM f_crt_fieldcat.

  READ TABLE gt_out INTO ls_out INDEX fu_row.
  IF sy-subrc = 0.
    CASE fu_column.
      WHEN 'MTDCOM'.
        LOOP AT gt_ebkn WHERE kostl = ls_out-kostl
                          AND sakto = ls_out-kstar.
          IF gt_ebkn-bedat IN gr_mbedat.
            LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = gt_ebkn-ebeln.
              CLEAR ls_ekko.
              READ TABLE gt_ekko INTO ls_ekko
                                 WITH KEY ebeln = ls_ekpo-ebeln.
              IF sy-subrc = 0.
                ls_xekpo-waers = ls_ekko-waers.
              ENDIF.
              ls_xekpo-ebeln  = ls_ekpo-ebeln.
              ls_xekpo-ebelp  = ls_ekpo-ebelp.
              ls_xekpo-netwr  = ls_ekpo-netwr.
              APPEND ls_xekpo TO lt_xekpo.
              CLEAR ls_xekpo.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

      WHEN 'YTDCOM'.
        LOOP AT gt_ebkn WHERE kostl = ls_out-kostl
                          AND sakto = ls_out-kstar.
          LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = gt_ebkn-ebeln.
            CLEAR ls_ekko.
            READ TABLE gt_ekko INTO ls_ekko
                               WITH KEY ebeln = ls_ekpo-ebeln.
            IF sy-subrc = 0.
              ls_xekpo-waers = ls_ekko-waers.
            ENDIF.
            ls_xekpo-ebeln  = ls_ekpo-ebeln.
            ls_xekpo-ebelp  = ls_ekpo-ebelp.
            ls_xekpo-netwr  = ls_ekpo-netwr.
            APPEND ls_xekpo TO lt_xekpo.
            CLEAR ls_xekpo.
          ENDLOOP.
        ENDLOOP.
    ENDCASE.
  ENDIF.

  IF lt_xekpo[] IS NOT INITIAL.
    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title       = 'PO'
        i_tabname     = '1'
        it_fieldcat   = gt_fieldcat[]
      TABLES
        t_outtab      = lt_xekpo
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.
  ENDIF.
ENDFORM.                    " SHOW_CELL_INFO

*&---------------------------------------------------------------------*
*&      Form  F_CRT_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_crt_fieldcat .
  CLEAR : gt_fieldcat[].
  PERFORM f_click_int_table USING :
    'EBELN' '' '' '' '' '' '' 'EBELN' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'EBELP' '' '' '' '' '' '' 'EBELP' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'WAERS' '' '' '' '' '' '' 'WAERS' 'EKKO' '' '' '' '' '' '' ''
    '' '' '' '' '',
    'NETWR' '' '' 'WAERS' '' '' '' 'NETWR' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' ''.
ENDFORM.                    " F_CRT_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_CLICK_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_click_int_table  USING    fu_fieldname fu_tabname
                                 fu_currency fu_cfieldname fu_quantity
                                 fu_qfieldname fu_checkbox fu_ref_field
                                 fu_ref_table fu_coltext fu_outputlen
                                 fu_inttype fu_no_out fu_edit fu_tech
                                 fu_just fu_key fu_fix fu_icon fu_sum
                                 fu_nosum.
  DATA : ls_dyn_fcat       TYPE slis_fieldcat_alv.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-seltext_l
                               ls_dyn_fcat-seltext_m ls_dyn_fcat-seltext_s.

  ls_dyn_fcat-fieldname       = fu_fieldname.
  ls_dyn_fcat-tabname         = fu_tabname.
  ls_dyn_fcat-currency        = fu_currency.
  ls_dyn_fcat-cfieldname      = fu_cfieldname.
  ls_dyn_fcat-quantity        = fu_quantity.
  ls_dyn_fcat-qfieldname      = fu_qfieldname.
  ls_dyn_fcat-checkbox        = fu_checkbox.
  ls_dyn_fcat-ref_fieldname   = fu_ref_field.
  ls_dyn_fcat-ref_tabname     = fu_ref_table.
  ls_dyn_fcat-edit            = fu_edit.
  ls_dyn_fcat-outputlen       = fu_outputlen.
  ls_dyn_fcat-inttype         = fu_inttype.
  ls_dyn_fcat-no_out          = fu_no_out.
  ls_dyn_fcat-tech            = fu_tech.
  ls_dyn_fcat-just            = fu_just.
  ls_dyn_fcat-key             = fu_key.
  ls_dyn_fcat-fix_column      = fu_fix.
  ls_dyn_fcat-icon            = fu_icon.
  ls_dyn_fcat-do_sum          = fu_sum.
  ls_dyn_fcat-no_sum          = fu_nosum.
  APPEND ls_dyn_fcat TO gt_fieldcat.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_CLICK_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_new_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_NEW_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_PO
*&---------------------------------------------------------------------*
FORM f_filter_po .
  SORT: gt_ekpo BY ebeln ebelp,
        gt_eket BY ebeln ebelp,
        gt_ekkn BY ebeln ebelp.

  LOOP AT gt_ekpo.
    READ TABLE gt_ekkn WITH KEY ebeln = gt_ekpo-ebeln
                                ebelp = gt_ekpo-ebelp
                                BINARY SEARCH
                                TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
    ELSE.
      DELETE gt_ekpo.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_eket.
    READ TABLE gt_ekkn WITH KEY ebeln = gt_eket-ebeln
                                ebelp = gt_eket-ebelp
                                BINARY SEARCH
                                TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
    ELSE.
      DELETE gt_eket.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FILTER_PO

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CC_GROUP
*&---------------------------------------------------------------------*
FORM f_value_cc_group  USING    fu_field.
  TYPES : BEGIN OF ty_xcsks,
            khinr     TYPE csks-khinr,
            descript  TYPE setheadert-descript,
          END OF ty_xcsks.

  DATA : lt_xcsks       TYPE STANDARD TABLE OF ty_xcsks,
         ls_xcsks       LIKE LINE OF lt_xcsks,
         ls_csks        LIKE LINE OF gt_csks,
         lv_subrc       TYPE sy-subrc,
         lv_khinr       TYPE csks-khinr,
         lt_setheadert  TYPE STANDARD TABLE OF setheadert,
         ls_setheadert  LIKE LINE OF lt_setheadert,
         lt_group       TYPE STANDARD TABLE OF setheadert,
         ls_group       LIKE LINE OF lt_group.

  DATA : return_tab     TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return      LIKE LINE OF return_tab.

  SELECT *
    FROM csks
    INTO CORRESPONDING FIELDS OF TABLE gt_csks
    WHERE kokrs = '8010'.

  LOOP AT gt_csks INTO ls_csks.
    ls_xcsks-khinr    = ls_csks-khinr.
    APPEND ls_xcsks TO lt_xcsks.

    ls_group-setname  = ls_csks-khinr.
    APPEND ls_group TO lt_group.
    CLEAR : ls_xcsks, ls_group.
  ENDLOOP.

  SORT lt_group BY setname.
  DELETE ADJACENT DUPLICATES FROM lt_group COMPARING setname.
  IF lt_group[] IS NOT INITIAL.
    SELECT *
      FROM setheadert
      INTO CORRESPONDING FIELDS OF TABLE lt_setheadert
      FOR ALL ENTRIES IN lt_group
      WHERE setclass  = '0101'
        AND subclass  = '8010'
        AND setname   = lt_group-setname
        AND langu     = sy-langu.
  ENDIF.

  SORT lt_xcsks BY khinr.
  DELETE ADJACENT DUPLICATES FROM lt_xcsks COMPARING khinr.
  LOOP AT lt_xcsks INTO ls_xcsks.
    CLEAR ls_setheadert.
    READ TABLE lt_setheadert INTO ls_setheadert
                             WITH KEY setname = ls_xcsks-khinr.
    IF sy-subrc = 0.
      ls_xcsks-descript = ls_setheadert-descript.
      MODIFY lt_xcsks FROM ls_xcsks TRANSPORTING descript.
    ENDIF.
  ENDLOOP.

  ASSIGN lt_xcsks[] TO <fs_tab>.
  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KHINR' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_khinr  = ls_return-fieldval.
      READ TABLE lt_xcsks INTO ls_xcsks WITH KEY khinr = lv_khinr.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_xcsks-khinr ''.
      ENDIF.
    ENDIF.

    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VALUE_CC_GROUP

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.

ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback
