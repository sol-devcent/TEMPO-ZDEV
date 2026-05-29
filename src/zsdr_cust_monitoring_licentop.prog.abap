*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005TOP                                              *
*----------------------------------------------------------------------*
  TABLES: s626,csks,bkpf,zcodt001,knvv,knvk.

  TYPE-POOLS: slis.

  TYPES: BEGIN OF ty_out,
           vkbur  TYPE vkbur,
           kdgrp  TYPE kdgrp,
           kvgr3  TYPE kvgr3,
           vkgrp  TYPE vkgrp,
           kunnr  TYPE kunnr,
           name1  TYPE name1_gp,
           name2  TYPE name2_gp,
           abtnr  TYPE abtnr_pa,
           vtext  TYPE vtext,
           name3   TYPE name1_gp,
           expdt  TYPE datum,
           sysdt  TYPE datum,
           expday TYPE int4,
         END OF ty_out.

  DATA: gr_alv      TYPE REF TO cl_salv_table,
        gr_function TYPE REF TO cl_salv_functions,
        gr_events   TYPE REF TO cl_salv_events_table.

  DATA: gt_out   TYPE TABLE OF ty_out,
        gt_knvv  TYPE TABLE OF knvv WITH HEADER LINE,
        gt_knvk  TYPE TABLE OF knvk WITH HEADER LINE,
        gt_kna1  TYPE TABLE OF kna1 WITH HEADER LINE,
        gt_tsabt TYPE TABLE OF tsabt WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_out>  TYPE ty_out.

*----------------------------------------------------------------------*
*       CLASS LCL_HANDLE_EVENTS DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  CLASS lcl_handle_events DEFINITION.
    PUBLIC SECTION.

      METHODS: on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
  ENDCLASS.                    "lcl_handle_events DEFINITION

  DATA: event_handler TYPE REF TO lcl_handle_events.

*----------------------------------------------------------------------*
*       CLASS LCL_HANDLE_EVENTS IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  CLASS lcl_handle_events IMPLEMENTATION.

    METHOD on_link_click.

      READ TABLE gt_out ASSIGNING <fs_out> INDEX row.
      CHECK sy-subrc = 0.

      CASE column.
        WHEN 'KUNNR'.
          SET PARAMETER ID 'KUN'  FIELD <fs_out>-kunnr.
          CALL TRANSACTION 'XD03' AND SKIP FIRST SCREEN.

      ENDCASE.

    ENDMETHOD.                    "on_link_click
  ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
