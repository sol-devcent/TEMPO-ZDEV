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
  SELECT kunnr vkorg vtweg spart vkbur kdgrp kvgr3 vkgrp
    INTO CORRESPONDING FIELDS OF TABLE gt_knvv
    FROM knvv WHERE vkbur IN s_vkbur
                AND vkorg EQ p_vkorg
                AND vtweg EQ '10'
                AND kdgrp IN s_kdgrp
                AND kvgr3 IN s_kvgr3
                AND vkgrp IN s_vkgrp
                AND kunnr IN s_kunnr.

  IF gt_knvv[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'I' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  SELECT kunnr name1 name2
    INTO CORRESPONDING FIELDS OF TABLE gt_kna1
    FROM kna1 FOR ALL ENTRIES IN gt_knvv
    WHERE kunnr = gt_knvv-kunnr
      AND aufsd = space
      AND ktokd IN ('ZC04','ZSU1').

  SELECT parnr kunnr namev name1 abtnr
    INTO CORRESPONDING FIELDS OF TABLE gt_knvk
    FROM knvk FOR ALL ENTRIES IN gt_knvv
    WHERE kunnr EQ gt_knvv-kunnr
*      AND namev NE space
      AND abtnr BETWEEN 'A1' AND 'A9'
      AND abtnr IN s_abtnr.

  IF gt_knvk[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_tsabt
      FROM tsabt "FOR ALL ENTRIES IN gt_knvk
      WHERE spras EQ sy-langu
*        AND abtnr EQ gt_knvk-abtnr.
        AND abtnr LIKE 'A%'
        AND abtnr IN s_abtnr.
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
*  LOOP AT gt_knvk.
*    CLEAR: gt_knvv,gt_kna1,gt_tsabt.
*    READ TABLE gt_knvv WITH KEY kunnr = gt_knvk-kunnr.
*    READ TABLE gt_kna1 WITH KEY kunnr = gt_knvk-kunnr.
*    READ TABLE gt_tsabt WITH KEY abtnr = gt_knvk-abtnr.
  LOOP AT gt_knvv.
    LOOP AT gt_tsabt.
      CLEAR: gt_knvk,gt_kna1.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_knvv-kunnr.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

      READ TABLE gt_knvk WITH KEY kunnr = gt_knvv-kunnr
                                  abtnr = gt_tsabt-abtnr.

      APPEND INITIAL LINE TO gt_out ASSIGNING <fs_out>.
      <fs_out>-vkbur = gt_knvv-vkbur.
      <fs_out>-kdgrp = gt_knvv-kdgrp.
      <fs_out>-kvgr3 = gt_knvv-kvgr3.
      <fs_out>-vkgrp = gt_knvv-vkgrp.
      <fs_out>-kunnr = gt_knvv-kunnr.
      <fs_out>-name1 = gt_kna1-name1.
      <fs_out>-name2 = gt_kna1-name2.
      <fs_out>-abtnr = gt_knvk-abtnr.
      <fs_out>-vtext = gt_tsabt-vtext.
      <fs_out>-name3 = gt_knvk-name1.
      <fs_out>-sysdt = sy-datum.

      IF gt_knvk-namev = space.
        gt_knvk-namev = '00.00.0000'.
        CONCATENATE gt_knvk-namev+6(4) gt_knvk-namev+3(2) gt_knvk-namev(2)
          INTO <fs_out>-expdt.
        <fs_out>-expday = 999999999 * -1.
      ELSE.
        CONCATENATE gt_knvk-namev+6(4) gt_knvk-namev+3(2) gt_knvk-namev(2)
          INTO <fs_out>-expdt.
        <fs_out>-expday = <fs_out>-expdt - <fs_out>-sysdt.
      ENDIF.

      CASE gt_tsabt-abtnr.
        WHEN 'A1' OR 'A4'.
          CLEAR: <fs_out>-expdt,<fs_out>-sysdt,<fs_out>-expday.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  DATA message TYPE REF TO cx_salv_msg.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = gr_alv
                              CHANGING  t_table   = gt_out ).
    CATCH cx_salv_msg INTO message.
      " error handling
  ENDTRY.

  PERFORM f_set_columns.
  PERFORM f_set_total.
  PERFORM f_set_sort.

*-- toolbar funtion
  gr_function = gr_alv->get_functions( ).
  gr_function->set_all( abap_true ).

*-- events
  "events
  gr_events = gr_alv->get_event( ).
  CREATE OBJECT event_handler.
  SET HANDLER event_handler->on_link_click FOR gr_events.

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
  CLEAR: gt_out,gt_knvv,gt_knvk,gt_kna1,gt_tsabt.
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
  lr_column ?= lr_columns->get_column( 'KUNNR' ).
  lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

  lr_column ?= lr_columns->get_column( 'ABTNR' ).
  lr_column->set_long_text( 'Kode Izin' ).
  lr_column->set_medium_text( 'Kode Izin' ).
  lr_column->set_short_text( 'Kode Izin' ).

  lr_column ?= lr_columns->get_column( 'NAME3' ).
  lr_column->set_long_text( 'Kode/nama Izin' ).
  lr_column->set_medium_text( 'Kode/nama Izin' ).
  lr_column->set_short_text( 'Kode/nama' ).

  lr_column ?= lr_columns->get_column( 'EXPDT' ).
  lr_column->set_long_text( 'Expirated Date' ).
  lr_column->set_medium_text( 'Expirated Date' ).
  lr_column->set_short_text( 'Exp. Date' ).

  lr_column ?= lr_columns->get_column( 'SYSDT' ).
  lr_column->set_long_text( 'System Date' ).
  lr_column->set_medium_text( 'System Date' ).
  lr_column->set_short_text( 'Sys. Date' ).

  lr_column ?= lr_columns->get_column( 'EXPDAY' ).
  lr_column->set_long_text( 'Days before Exp' ).
  lr_column->set_medium_text( 'Days before Exp' ).
  lr_column->set_short_text( 'Days Exp' ).
ENDFORM.                    " F_SET_COLUMNS

*&---------------------------------------------------------------------*
*&      Form  F_SET_TOTAL
*&---------------------------------------------------------------------*
FORM f_set_total .
*  DATA: lr_aggregations TYPE REF TO cl_salv_aggregations.

*  lr_aggregations = gr_alv->get_aggregations( ).
*  lr_aggregations->add_aggregation( columnname = 'MTDBUD' ).
*  lr_aggregations->add_aggregation( columnname = 'MTDACT' ).
*  lr_aggregations->add_aggregation( columnname = 'MTDCOM' ).
*  lr_aggregations->add_aggregation( columnname = 'MTDBAL' ).
*  lr_aggregations->add_aggregation( columnname = 'YTDBUD' ).
*  lr_aggregations->add_aggregation( columnname = 'YTDACT' ).
*  lr_aggregations->add_aggregation( columnname = 'YTDCOM' ).
*  lr_aggregations->add_aggregation( columnname = 'YTDBAL' ).
ENDFORM.                    " F_SET_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_SET_SORT
*&---------------------------------------------------------------------*
FORM f_set_sort .
  DATA: lr_groups TYPE REF TO cl_salv_sorts .

  lr_groups = gr_alv->get_sorts( ) .
  lr_groups->add_sort( columnname = 'VKBUR'
                       position   = 1
                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
  lr_groups->add_sort( columnname = 'KDGRP'
                       position   = 2
                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
  lr_groups->add_sort( columnname = 'KVGR3'
                       position   = 3
                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
  lr_groups->add_sort( columnname = 'VKGRP'
                       position   = 4
                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
  lr_groups->add_sort( columnname = 'KUNNR'
                       position   = 5
*                       subtotal   = abap_true
                       sequence   = if_salv_c_sort=>sort_up ).
ENDFORM.                    " F_SET_SORT
