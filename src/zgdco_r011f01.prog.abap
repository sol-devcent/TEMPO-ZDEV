*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005F01                                              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*CLASS lcl_event_handler DEFINITION.
*  PUBLIC SECTION.
*    METHODS:
*      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
*        IMPORTING
*          er_data_changed.
*ENDCLASS.                    "lcl_main DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_main IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*CLASS lcl_event_handler IMPLEMENTATION.
*  METHOD handle_data_changed.
*    DATA: ls_good   TYPE lvc_s_modi,
*          lv_berat  TYPE char10,
*          lv_cntr   TYPE numc3.
*
*    FIELD-SYMBOLS: <fs_detail> TYPE zfist001.
*
*    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
*      CLEAR: lv_berat,lv_cntr.
*      CALL METHOD er_data_changed->get_cell_value
*        EXPORTING
*          i_row_id    = ls_good-row_id
*          i_fieldname = 'BERAT'
*        IMPORTING
*          e_value     = lv_berat.
*      CALL METHOD er_data_changed->get_cell_value
*        EXPORTING
*          i_row_id    = ls_good-row_id
*          i_fieldname = 'CNTR'
*        IMPORTING
*          e_value     = lv_cntr.
*
**      READ TABLE gt_fg ASSIGNING <fs_fg>
**                           INDEX ls_good-row_id.
**
**      <fs_fg>-berat = lv_berat.
**      <fs_fg>-cntr  = lv_cntr.
*    ENDLOOP.
*
**    CALL METHOD g_grid->refresh_table_display( ).
*
*  ENDMETHOD.                    "on_data_changed
*ENDCLASS.                    "lcl_main IMPLEMENTATION

*DATA: g_event_handler TYPE REF TO lcl_event_handler.

*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.
  gv_repid = sy-repid.
  gs_variant-report = gv_repid.
  gs_variant-variant = pa_vari.

  PERFORM f_init_setleaf USING p_bukrs p_gsber.
  PERFORM f_init_new_cost_center USING p_gsber.

  gv_labor  = 'LABOR'.
  CASE p_bukrs.
    WHEN '8330'.
      gv_kstar = '1000000015'.
      gv_nonlbr = 'MACH'.
    WHEN OTHERS.
      gv_kstar = '1000000020'.
      gv_nonlbr = 'NONLBR'.
  ENDCASE.
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
  PERFORM f_cost_center_group.
  PERFORM f_get_setleaf.
  PERFORM f_get_coep_moh.
  PERFORM f_get_coep_prd.
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
  DATA: lt_out1         TYPE TABLE OF ty_out1 WITH HEADER LINE,
        ls_setleafgrps  LIKE LINE OF gt_setleafgrp,
        ls_zcodt007s    LIKE LINE OF gt_zcodt007,
        ls_zcodt008     LIKE LINE OF gt_zcodt008.

  "Summaries by group
  LOOP AT gt_coepmoh.
    CLEAR: gt_setleaf.
    READ TABLE gt_setleaf WITH KEY valfrom = gt_coepmoh-kstar.

    lt_out1-bukrs   = gt_coepmoh-bukrs.
    lt_out1-gsber   = gt_coepmoh-gsber.
    lt_out1-perio   = gt_coepmoh-perio.
    lt_out1-gjahr   = gt_coepmoh-gjahr.
    lt_out1-kostls  = gt_coepmoh-objnr+6(10).
    lt_out1-kstar   = gt_coepmoh-kstar.
    lt_out1-setname = gt_setleaf-setname.
    lt_out1-wogbtr  = gt_coepmoh-wogbtr.
    lt_out1-owaer   = gt_coepmoh-owaer.

    CASE lt_out1-setname.
      WHEN 'FIX_LABOR'.
        lt_out1-zgroup = '1'.
      WHEN 'VAR_LABOR'.
        lt_out1-zgroup = '2'.
      WHEN 'FIX_NONLBR'.
        lt_out1-zgroup = '3'.
      WHEN 'VAR_NONLBR'.
        lt_out1-zgroup = '4'.
    ENDCASE.
    COLLECT lt_out1. CLEAR lt_out1.
  ENDLOOP.

  DELETE lt_out1 WHERE wogbtr IS INITIAL.

  " Check Receiver Cost Center type 2
*  LOOP AT lt_out1.
*    CLEAR: ls_setleafgrps,ls_zcodt007s.
*    LOOP AT gt_setleafgrp INTO ls_setleafgrps
*                          WHERE valfrom = lt_out1-kostls.
*      READ TABLE gt_zcodt007 INTO ls_zcodt007s
*                             WITH KEY setnames = ls_setleafgrps-setname.
*      IF sy-subrc = 0.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*
*    CASE ls_zcodt007s-types.
*      WHEN '1'.
*        lt_out1-types = '1'.
*        MODIFY lt_out1 TRANSPORTING types.
*
*      WHEN '2'.
*        CLEAR: ls_setleafgrps,ls_zcodt008.
*        LOOP AT gt_setleafgrp INTO ls_setleafgrps
*                              WHERE setname = ls_zcodt007s-setnamer.
*          READ TABLE gt_zcodt008 INTO ls_zcodt008
*                                 WITH KEY kostl = ls_setleafgrps-valfrom.
*          IF sy-subrc = 0.
*            READ TABLE gt_coepprd_lbr WITH KEY objnr+6(10) = ls_zcodt008-kostl
*                                      TRANSPORTING NO FIELDS.
*            IF sy-subrc = 0.
*              lt_out1-types = '2'.
*            ELSE.
*              READ TABLE gt_coepprd_nlbr WITH KEY objnr+6(10) = ls_zcodt008-kostl
*                                        TRANSPORTING NO FIELDS.
*              IF sy-subrc = 0.
*                lt_out1-types = '2'.
*              ELSE.
*                lt_out1-types = '1'.
*              ENDIF.
*            ENDIF.
*            MODIFY lt_out1 TRANSPORTING types.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*
*      WHEN OTHERS.
*    ENDCASE.
*  ENDLOOP.

  " Append itab OUT
  LOOP AT lt_out1.
    MOVE-CORRESPONDING lt_out1 TO gt_out1.

    CLEAR: ls_setleafgrps,ls_zcodt007s.
*    READ TABLE gt_setleafgrp INTO ls_setleafgrps
*                             WITH KEY valfrom = gt_out1-kostls.
    LOOP AT gt_setleafgrp INTO ls_setleafgrps
                          WHERE valfrom = gt_out1-kostls.
      READ TABLE gt_zcodt007 INTO ls_zcodt007s
                             WITH KEY setnames = ls_setleafgrps-setname.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.
    ENDLOOP.

    CASE gt_out1-setname.
      WHEN 'FIX_LABOR'.     "zgroup = '1'
        CASE ls_zcodt007s-types.
          WHEN '1'.
            LOOP AT gt_coepprde_lbr.
              READ TABLE gt_setleafgrp WITH KEY setname = ls_zcodt007s-setnamee
                                                valfrom = gt_coepprde_lbr-objnr+6(10)
                                                TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.

              MULTIPLY gt_coepprde_lbr-megbtr BY -1.
              gt_out1-zlabor = 'FLBR'.
              gt_out1-kstar  = lt_out1-kstar.
              gt_out1-kostlr = gt_coepprde_lbr-objnr+6(10).
              gt_out1-megbtr = gt_coepprde_lbr-megbtr.
              gt_out1-meinh  = gt_coepprde_lbr-meinh.
              gt_out1-amount = gt_out1-wogbtr * gt_coepprde_lbr-megbtr.
              ADD gt_coepprde_lbr-megbtr TO gv_megbtr_lbr.
*              IF gv_megbtr_lbr IS NOT INITIAL.
*                gt_out1-amount = gt_out1-wogbtr * gt_coepprd_lbr-megbtr /
*                                 gv_megbtr_lbr.
*              ENDIF.
              APPEND gt_out1.

              PERFORM f_collect_summary USING gt_out1-bukrs gt_out1-gsber gt_out1-perio
                                              gt_out1-gjahr gt_out1-kostls gt_out1-kostlr
                                              gt_out1-wogbtr gt_out1-megbtr gt_out1-zlabor.

              CLEAR: gt_out1-kostlr,gt_out1-megbtr,gt_out1-meinh,gt_out1-amount.
            ENDLOOP.

          WHEN '2' OR '3'.
            LOOP AT gt_coepprd_lbr WHERE objnr+6(10) = gt_out1-kostls.
              READ TABLE gt_setleafgrp WITH KEY setname = ls_zcodt007s-setnamer
                                                valfrom = gt_coepprd_lbr-objnr+6(10)
                                                TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.

              MULTIPLY gt_coepprd_lbr-megbtr BY -1.
              gt_out1-zlabor = 'FLBR'.
              gt_out1-kstar  = lt_out1-kstar.
              gt_out1-kostlr = gt_coepprd_lbr-objnr+6(10).
              gt_out1-megbtr = gt_coepprd_lbr-megbtr.
              gt_out1-meinh  = gt_coepprd_lbr-meinh.
              gt_out1-amount = gt_out1-wogbtr * gt_coepprd_lbr-megbtr.
              ADD gt_coepprd_lbr-megbtr TO gv_megbtr_lbr.
*                IF gv_megbtr_lbr IS NOT INITIAL.
*                  gt_out1-amount = gt_out1-wogbtr * gt_coepprd_lbr-megbtr /
*                                   gv_megbtr_lbr.
*                ENDIF.
              APPEND gt_out1.

              PERFORM f_collect_summary USING gt_out1-bukrs gt_out1-gsber gt_out1-perio
                                              gt_out1-gjahr gt_out1-kostls gt_out1-kostlr
                                              gt_out1-wogbtr gt_out1-megbtr gt_out1-zlabor.

              CLEAR: gt_out1-kostlr,gt_out1-megbtr,gt_out1-meinh,gt_out1-amount.
            ENDLOOP.
        ENDCASE.

      WHEN 'VAR_LABOR'.     "zgroup = '2'
        CASE ls_zcodt007s-types.
          WHEN '1' OR '2' OR '3'.
            LOOP AT gt_coepprd_lbr.
              IF ls_zcodt007s-types = '03'.
                IF gt_coepprd_lbr-objnr+6(10) NE gt_out1-kostls.
                  CONTINUE.
                ENDIF.
              ENDIF.

              READ TABLE gt_setleafgrp WITH KEY setname = ls_zcodt007s-setnamer
                                                valfrom = gt_coepprd_lbr-objnr+6(10)
                                                TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.

              MULTIPLY gt_coepprd_lbr-megbtr BY -1.
              gt_out1-zlabor = 'VLBR'.
              gt_out1-kstar  = lt_out1-kstar.
              gt_out1-kostlr = gt_coepprd_lbr-objnr+6(10).
              gt_out1-megbtr = gt_coepprd_lbr-megbtr.
              gt_out1-meinh  = gt_coepprd_lbr-meinh.
              gt_out1-amount = gt_out1-wogbtr * gt_coepprd_lbr-megbtr.
              ADD gt_coepprd_lbr-megbtr TO gv_megbtr_lbr.
*              IF gv_megbtr_lbr IS NOT INITIAL.
*                gt_out1-amount = gt_out1-wogbtr * gt_coepprd_lbr-megbtr /
*                                 gv_megbtr_lbr.
*              ENDIF.
              APPEND gt_out1.

              PERFORM f_collect_summary USING gt_out1-bukrs gt_out1-gsber gt_out1-perio
                                              gt_out1-gjahr gt_out1-kostls gt_out1-kostlr
                                              gt_out1-wogbtr gt_out1-megbtr gt_out1-zlabor.

              CLEAR: gt_out1-kostlr,gt_out1-megbtr,gt_out1-meinh,gt_out1-amount.
            ENDLOOP.

          WHEN OTHERS.
        ENDCASE.

      WHEN 'FIX_NONLBR'.    "zgroup = '3'
        CASE ls_zcodt007s-types.
          WHEN '1'.
            LOOP AT gt_coepprde_nlbr.
              READ TABLE gt_setleafgrp WITH KEY setname = ls_zcodt007s-setnamee
                                                valfrom = gt_coepprde_nlbr-objnr+6(10)
                                                TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.

              MULTIPLY gt_coepprde_nlbr-megbtr BY -1.
              gt_out1-zlabor = 'FNLBR'.
              gt_out1-kstar  = lt_out1-kstar.
              gt_out1-kostlr = gt_coepprde_nlbr-objnr+6(10).
              gt_out1-megbtr = gt_coepprde_nlbr-megbtr.
              gt_out1-meinh  = gt_coepprde_nlbr-meinh.
              gt_out1-amount = gt_out1-wogbtr * gt_coepprde_nlbr-megbtr.
              ADD gt_coepprde_nlbr-megbtr TO gv_megbtr_nlbr.
*              IF gv_megbtr_nlbr IS NOT INITIAL.
*                gt_out1-amount = gt_out1-wogbtr * gt_coepprd_nlbr-megbtr /
*                                 gv_megbtr_nlbr.
*              ENDIF.
              APPEND gt_out1.

              PERFORM f_collect_summary USING gt_out1-bukrs gt_out1-gsber gt_out1-perio
                                              gt_out1-gjahr gt_out1-kostls gt_out1-kostlr
                                              gt_out1-wogbtr gt_out1-megbtr gt_out1-zlabor.

              CLEAR: gt_out1-kostlr,gt_out1-megbtr,gt_out1-meinh,gt_out1-amount.
            ENDLOOP.

          WHEN '2' OR '3'.
            LOOP AT gt_coepprd_nlbr WHERE objnr+6(10) = gt_out1-kostls.
              READ TABLE gt_setleafgrp WITH KEY setname = ls_zcodt007s-setnamer
                                                valfrom = gt_coepprd_nlbr-objnr+6(10)
                                                TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.

              MULTIPLY gt_coepprd_nlbr-megbtr BY -1.
              gt_out1-zlabor = 'FNLBR'.
              gt_out1-kstar  = lt_out1-kstar.
              gt_out1-kostlr = gt_coepprd_nlbr-objnr+6(10).
              gt_out1-megbtr = gt_coepprd_nlbr-megbtr.
              gt_out1-meinh  = gt_coepprd_nlbr-meinh.
              gt_out1-amount = gt_out1-wogbtr * gt_coepprd_nlbr-megbtr.
              ADD gt_coepprd_nlbr-megbtr TO gv_megbtr_nlbr.
*                IF gv_megbtr_nlbr IS NOT INITIAL.
*                  gt_out1-amount = gt_out1-wogbtr * gt_coepprd_nlbr-megbtr /
*                                   gv_megbtr_nlbr.
*                ENDIF.
              APPEND gt_out1.

              PERFORM f_collect_summary USING gt_out1-bukrs gt_out1-gsber gt_out1-perio
                                              gt_out1-gjahr gt_out1-kostls gt_out1-kostlr
                                              gt_out1-wogbtr gt_out1-megbtr gt_out1-zlabor.

              CLEAR: gt_out1-kostlr,gt_out1-megbtr,gt_out1-meinh,gt_out1-amount.
            ENDLOOP.
        ENDCASE.

      WHEN 'VAR_NONLBR'.    "zgroup = '4'
        CASE ls_zcodt007s-types.
          WHEN '1' OR '2' OR '03'.
            LOOP AT gt_coepprd_nlbr.
              IF ls_zcodt007s-types = '03'.
                IF gt_coepprd_nlbr-objnr+6(10) NE gt_out1-kostls.
                  CONTINUE.
                ENDIF.
              ENDIF.

              READ TABLE gt_setleafgrp WITH KEY setname = ls_zcodt007s-setnamer
                                                valfrom = gt_coepprd_nlbr-objnr+6(10)
                                                TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF.

              MULTIPLY gt_coepprd_nlbr-megbtr BY -1.
              gt_out1-zlabor = 'VNLBR'.
              gt_out1-kstar  = lt_out1-kstar.
              gt_out1-kostlr = gt_coepprd_nlbr-objnr+6(10).
              gt_out1-megbtr = gt_coepprd_nlbr-megbtr.
              gt_out1-meinh  = gt_coepprd_nlbr-meinh.
              gt_out1-amount = gt_out1-wogbtr * gt_coepprd_nlbr-megbtr.
              ADD gt_coepprd_nlbr-megbtr TO gv_megbtr_nlbr.
*              IF gv_megbtr_nlbr IS NOT INITIAL.
*                gt_out1-amount = gt_out1-wogbtr * gt_coepprd_nlbr-megbtr /
*                                 gv_megbtr_nlbr.
*              ENDIF.
              APPEND gt_out1.

              PERFORM f_collect_summary USING gt_out1-bukrs gt_out1-gsber gt_out1-perio
                                              gt_out1-gjahr gt_out1-kostls gt_out1-kostlr
                                              gt_out1-wogbtr gt_out1-megbtr gt_out1-zlabor.

              CLEAR: gt_out1-kostlr,gt_out1-megbtr,gt_out1-meinh,gt_out1-amount.
            ENDLOOP.
          WHEN OTHERS.
        ENDCASE.
    ENDCASE.
  ENDLOOP.

  PERFORM f_summaries_qty.

  LOOP AT gt_out1 ASSIGNING <fs_out1>.
    CLEAR: gt_out1s1,gt_out1s3.
*    READ TABLE gt_out1s1 WITH KEY bukrs  = <fs_out1>-bukrs
*                                  gsber  = <fs_out1>-gsber
*                                  perio  = <fs_out1>-perio
*                                  gjahr  = <fs_out1>-gjahr
*                                  kostls = <fs_out1>-kostls
*                                  kostlr = <fs_out1>-kostlr
*                                  zlabor = <fs_out1>-zlabor.
    READ TABLE gt_out1s3 WITH KEY bukrs  = <fs_out1>-bukrs
                                  gsber  = <fs_out1>-gsber
                                  perio  = <fs_out1>-perio
                                  gjahr  = <fs_out1>-gjahr
                                  kostls = <fs_out1>-kostls
                                  zlabor = <fs_out1>-zlabor.

    <fs_out1>-amount = <fs_out1>-megbtr * <fs_out1>-wogbtr /
                       gt_out1s3-megbtr.
  ENDLOOP.

  SORT gt_out1 BY bukrs gsber perio gjahr zgroup kostls kstar kostlr.

  CASE 'X'.
    WHEN butt1.
      PERFORM f_process_data1.
    WHEN butt2.
      PERFORM f_process_data2.
    WHEN butt3.
      PERFORM f_process_data2.
      PERFORM f_process_data3.
  ENDCASE.
ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
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
  REFRESH: gr_fixlbr,gr_varlbr,gr_fixnlbr,gr_varnlbr,gt_out1,gt_out2,gt_out3,
           gt_coepmoh,gt_coepprd,gt_coepprd_lbr,gt_coepprd_nlbr,gt_coepprd_3,
           gt_setleaf,gt_csksmoh,gt_csksprd,gt_csksprd_lbr,gt_csksprd_nlbr.
  CLEAR: gv_megbtr_lbr,gv_megbtr_nlbr.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

  IF g_custom_container IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    PERFORM f_build_fieldcat.
    PERFORM f_build_layout.
    PERFORM f_build_sortfield.
    PERFORM f_toolbar_excluding.

* Create_object_container
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.

* Create_object_grid
    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_custom_container.

    CASE 'X'.
      WHEN butt1.
* Create_display_ALV
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_out1[]
            it_sort              = gt_sort[].
      WHEN butt2.
* Create_display_ALV
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_out2[]
            it_sort              = gt_sort[].
      WHEN butt3.
* Create_display_ALV
        CALL METHOD g_grid->set_table_for_first_display
          EXPORTING
            is_layout            = gs_layout
            it_toolbar_excluding = gt_exclude
            i_default            = 'X'
            i_save               = 'A'
            is_variant           = gs_variant
          CHANGING
            it_fieldcatalog      = gt_fieldcat[]
            it_outtab            = gt_out3[]
            it_sort              = gt_sort[].
    ENDCASE.

* When edit display
*    CALL METHOD g_grid->register_edit_event
*      EXPORTING
*        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Data Change Handler
*    CREATE OBJECT g_event_handler.
*    SET HANDLER g_event_handler->handle_data_changed FOR g_grid.

  ELSE.
    CALL METHOD g_grid->refresh_table_display( ).
  ENDIF.
ENDMODULE.                 " PBO100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  CLEAR gt_fieldcat[].

  CASE 'X'.
    WHEN butt1.
      PERFORM f_fieldcatg USING 'GT_OUT1':
        'BUKRS' 'COEP' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'COEP' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PERIO' 'COEP' 'PERIO' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'COEP' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTLS' '' '' '' '20' 'Sender Cost Center' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LTEXTS' '' '' '' '40' 'Sender Cost Center Desc.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTLR' '' '' '' '20' 'Receiver Cost Center' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LTEXTR' '' '' '' '40' 'Receiver Cost Center Desc.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KSTAR' 'COEP' 'KSTAR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LTEXTK' '' '' '' '40' 'Cost Element Desc.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'SETNAME' 'SETLEAF' 'SETNAME' '' '' 'Cost Element Group' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WOGBTR' 'COEP' 'WOGBTR' '' '' 'Total Value' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'OWAER' 'COEP' 'OWAER' '' '' 'Currency' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEGBTR' 'COEP' 'MEGBTR' '' '' 'Total Hour' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' '',
        'MEINH' 'COEP' 'MEINH' '' '' 'UoM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'AMOUNT' 'COEP' 'WOGBTR' '' '' 'Amount' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' ''.
    WHEN butt2.
      PERFORM f_fieldcatg USING 'GT_OUT2':
        'BUKRS' 'COEP' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'COEP' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PERIO' 'COEP' 'PERIO' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'COEP' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'CSKS' 'KOSTL' '' '' 'Cost Center' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LTEXT' '' '' '' '40' 'Cost Center Desc.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WOGBTR1' '' '' '' '20' 'Fix Labor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR2' '' '' '' '20' 'Var Labor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR12' '' '' '' '20' 'Total Labor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR3' '' '' '' '20' 'Fix NonLabor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR4' '' '' '' '20' 'Var NonLabor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR34' '' '' '' '20' 'Total NonLabor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'OWAER' 'COEP' 'OWAER' '' '' 'Currency' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEGBTR1' '' '' '' '12' 'Labor HR' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' '',
        'MEGBTR2' '' '' '' '12' 'NonLabor HR' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' '',
        'MEINH' 'COEP' 'MEINH' '' '' 'UoM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'AMOUNT1' '' '' '' '20' 'Rate Fix Labor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'AMOUNT2' '' '' '' '20' 'Rate Var Labor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'AMOUNT3' '' '' '' '20' 'Rate Fix NonLabor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'AMOUNT4' '' '' '' '20' 'Rate Var NonLabor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' ''.
    WHEN butt3.
      PERFORM f_fieldcatg USING 'GT_OUT3':
        'BUKRS' 'COEP' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'COEP' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PERIO' 'COEP' 'PERIO' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'COEP' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'PLNBEZ' 'AFKO' 'PLNBEZ' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'OBJNR' 'COEP' 'OBJNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'CSKS' 'KOSTL' '' '' 'Cost Center' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LTEXTS' '' '' '' '40' 'Cost Center Desc.' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEGBTR1' '' '' '' '12' 'Labor HR' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' '',
        'MEGBTR2' '' '' '' '12' 'NonLabor HR' '' '' '' '' '' '' 'MEINH' '' '' '' '' '' '' '',
        'MEINH' 'COEP' 'MEINH' '' '' 'UoM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WOGBTR1' '' '' '' '20' 'Fix Labor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR2' '' '' '' '20' 'Var Labor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR3' '' '' '' '20' 'Fix NonLabor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'WOGBTR4' '' '' '' '20' 'Var NonLabor Cost' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'OWAER' 'COEP' 'OWAER' '' '' 'Currency' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'AMOUNT1' '' '' '' '20' 'Total Fix Labor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'AMOUNT2' '' '' '' '20' 'Total Var Labor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'AMOUNT3' '' '' '' '20' 'Total Fix NonLabor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' '',
        'AMOUNT4' '' '' '' '20' 'Total Var NonLabor' '' '' '' '' '' 'OWAER' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING   value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_emphasize)
                          value(fu_hotspot)
                          value(fu_edit)
                          value(fu_no_zero)
                          value(fu_just).

  DATA: ld_fieldcat  TYPE  lvc_t_fcat WITH HEADER LINE.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-hotspot           = fu_hotspot.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-no_zero           = fu_no_zero.
  ld_fieldcat-just              = fu_just.
  APPEND ld_fieldcat TO gt_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout-zebra       = 'X'.
  gs_layout-cwidth_opt  = 'X'.
  gs_layout-col_opt     = 'X'.
  gs_layout-no_headers  = space.
  gs_layout-no_rowmark  = 'X'.
*  gs_layout-no_toolbar  = 'X'.
*  gs_layout-stylefname  = 'CELLTAB'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield .
  CLEAR gt_sort[].

*  CLEAR gt_sort.
*  gt_sort-spos      = '1'.
*  gt_sort-fieldname = 'BUKRS'.
*  APPEND gt_sort.
*
*  CLEAR gt_sort.
*  gt_sort-spos      = '2'.
*  gt_sort-fieldname = 'GSBER'.
*  APPEND gt_sort.

*  CASE 'X'.
*    WHEN p_radio1.
*      CLEAR gt_sort.
*      gt_sort-spos      = '1'.
*      gt_sort-fieldname = 'MATERIAL'.
*      APPEND gt_sort.
*
*    WHEN p_radio2.
*    WHEN OTHERS.
*  ENDCASE.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Module  PAI100  INPUT
*&---------------------------------------------------------------------*
MODULE pai100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'ESC' OR 'CANC'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      LEAVE TO SCREEN 0.

    WHEN 'BUTT1'.
      SET SCREEN 0.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      CLEAR: g_custom_container,gt_fieldcat[],gt_sort[].
      CLEAR: butt2,butt3.
      butt1 = 'X'.

      IF gt_out1[] IS INITIAL.
        PERFORM f_get_data.
        PERFORM f_process_data.
      ENDIF.
      PERFORM f_print_data.

    WHEN 'BUTT2'.
      SET SCREEN 0.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      CLEAR: g_custom_container,gt_fieldcat[],gt_sort[].
      CLEAR: butt1,butt3.
      butt2 = 'X'.

      IF gt_out1[] IS INITIAL.
        PERFORM f_get_data.
        PERFORM f_process_data.
      ELSEIF gt_out2[] IS INITIAL.
        PERFORM f_process_data2.
      ENDIF.
      PERFORM f_print_data.

    WHEN 'BUTT3'.
      SET SCREEN 0.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      CLEAR: g_custom_container,gt_fieldcat[],gt_sort[].
      CLEAR: butt1,butt2.
      butt3 = 'X'.

      IF gt_out1[] IS INITIAL.
        PERFORM f_get_data.
        PERFORM f_process_data.
      ELSEIF gt_out2[] IS INITIAL.
        PERFORM f_get_coep_prd_3.
        PERFORM f_process_data2.
        PERFORM f_process_data3.
      ELSEIF gt_out3[] IS INITIAL.
        PERFORM f_get_coep_prd_3.
        PERFORM f_process_data3.
      ENDIF.
      PERFORM f_print_data.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " PAI100  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
FORM f_toolbar_excluding .
  DATA ls_exclude TYPE ui_func.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND ls_exclude TO gt_exclude.
ENDFORM.                    " F_TOOLBAR_EXCLUDING

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv  CHANGING fc_variant.
  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.

  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_INIT_KHINR
*&---------------------------------------------------------------------*
*FORM f_init_khinr  USING    fu_bukrs
*                            fu_gsber.
*  CASE fu_bukrs.
*    WHEN '8360'.
*      p_khinrm = 'MOH_KMM3'.
*      p_khinrp = 'PRD_KMM3'.
*    WHEN OTHERS.
*  ENDCASE.
*ENDFORM.                    " F_INIT_KHINR

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SETLEAF
*&---------------------------------------------------------------------*
FORM f_init_setleaf  USING    fu_bukrs
                              fu_gsber.
  CLEAR: gt_zcodt007,s_setnmm,s_setnmp.
  CLEAR: gt_zcodt007[],s_setnmm[],s_setnmp[].
  SELECT * INTO TABLE gt_zcodt007
    FROM zcodt007 WHERE werks = fu_gsber
                    AND types IN s_types.

  LOOP AT gt_zcodt007.
    IF gt_zcodt007-setnames IS NOT INITIAL.
      s_setnmm-sign   = 'I'.
      s_setnmm-option = 'EQ'.
      s_setnmm-low    = gt_zcodt007-setnames.
      APPEND s_setnmm. CLEAR s_setnmm.
    ENDIF.

    IF gt_zcodt007-setnamer IS NOT INITIAL.
      s_setnmp-sign   = 'I'.
      s_setnmp-option = 'EQ'.
      s_setnmp-low    = gt_zcodt007-setnamer.
      APPEND s_setnmp. CLEAR s_setnmp.
    ENDIF.

*    CASE fu_gsber.
*      WHEN '0101' OR '0901'.
    IF gt_zcodt007-setnamee IS NOT INITIAL.
      s_setnme-sign   = 'I'.
      s_setnme-option = 'EQ'.
      s_setnme-low    = gt_zcodt007-setnamee.
      APPEND s_setnme. CLEAR s_setnme.
    ENDIF.
*      WHEN OTHERS.
*    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_INIT_SETLEAF

*&---------------------------------------------------------------------*
*&      Form  F_COST_CENTER_GROUP
*&---------------------------------------------------------------------*
FORM f_cost_center_group .
  DATA: lt_csks       TYPE TABLE OF csks WITH HEADER LINE.

  IF s_setnme[] IS INITIAL.
    SELECT * INTO TABLE gt_setleafgrp
      FROM setleaf WHERE setclass = '0101'
                     AND subclass = '8010'
                     AND ( setname IN s_setnmm OR
                           setname IN s_setnmp ).
  ELSE.
    SELECT * INTO TABLE gt_setleafgrp
      FROM setleaf WHERE setclass = '0101'
                     AND subclass = '8010'
                     AND ( setname IN s_setnmm OR
                           setname IN s_setnmp OR
                           setname IN s_setnme ).
  ENDIF.

  IF gt_setleafgrp[] IS NOT INITIAL.
    SELECT kokrs kostl datbi datab bukrs gsber khinr prctr objnr
      INTO CORRESPONDING FIELDS OF TABLE lt_csks
      FROM csks FOR ALL ENTRIES IN gt_setleafgrp
      WHERE kokrs = gv_kokrs
        AND kostl = gt_setleafgrp-valfrom(10)
        AND bukrs = p_bukrs
        AND gsber = p_gsber.

    LOOP AT lt_csks.
      CLEAR gt_setleafgrp.
*      READ TABLE gt_setleafgrp WITH KEY valfrom = lt_csks-kostl.
      LOOP AT gt_setleafgrp WHERE valfrom = lt_csks-kostl.
        IF gt_setleafgrp-setname IN s_setnmm AND
           s_setnmm[] IS NOT INITIAL.
          MOVE-CORRESPONDING lt_csks TO gt_csksmoh.
          APPEND gt_csksmoh. CLEAR gt_csksmoh.

        ELSEIF gt_setleafgrp-setname IN s_setnmp AND
               s_setnmp[] IS NOT INITIAL.
          MOVE-CORRESPONDING lt_csks TO gt_csksprd.
          APPEND gt_csksprd. CLEAR gt_csksprd.

        ELSEIF gt_setleafgrp-setname IN s_setnme AND
               s_setnme[] IS NOT INITIAL.
          MOVE-CORRESPONDING lt_csks TO gt_csksprde.
          APPEND gt_csksprde. CLEAR gt_csksprde.
        ENDIF.

        READ TABLE gt_zcodt007 WITH KEY setnamer = gt_setleafgrp-setname.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING lt_csks TO gt_csksprd.
          APPEND gt_csksprd. CLEAR gt_csksprd.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT gt_csksprd.
      gt_csksprd-objnr(2) = 'KL'.

      MOVE-CORRESPONDING gt_csksprd TO gt_csksprd_lbr.
*      CONCATENATE gt_csksprd-objnr 'LABOR' INTO gt_csksprd_lbr-objnr.
      CONCATENATE gt_csksprd-objnr gv_labor INTO gt_csksprd_lbr-objnr.
      APPEND gt_csksprd_lbr.

      MOVE-CORRESPONDING gt_csksprd TO gt_csksprd_nlbr.
*      CONCATENATE gt_csksprd-objnr 'NONLBR' INTO gt_csksprd_nlbr-objnr.
      CONCATENATE gt_csksprd-objnr gv_nonlbr INTO gt_csksprd_nlbr-objnr.
      APPEND gt_csksprd_nlbr.
    ENDLOOP.

    LOOP AT gt_csksprde.
      gt_csksprde-objnr(2) = 'KL'.

      MOVE-CORRESPONDING gt_csksprde TO gt_csksprde_lbr.
*      CONCATENATE gt_csksprd-objnr 'LABOR' INTO gt_csksprd_lbr-objnr.
      CONCATENATE gt_csksprde-objnr gv_labor INTO gt_csksprde_lbr-objnr.
      APPEND gt_csksprde_lbr.

      MOVE-CORRESPONDING gt_csksprde TO gt_csksprde_nlbr.
*      CONCATENATE gt_csksprd-objnr 'NONLBR' INTO gt_csksprd_nlbr-objnr.
      CONCATENATE gt_csksprde-objnr gv_nonlbr INTO gt_csksprde_nlbr-objnr.
      APPEND gt_csksprde_nlbr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_COST_CENTER_GROUP

*&---------------------------------------------------------------------*
*&      Form  F_GET_SETLEAF
*&---------------------------------------------------------------------*
FORM f_get_setleaf .
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
    FROM setleaf WHERE setclass = '0102'
                   AND subclass = 'TSPC'
                   AND setname IN ('FIX_LABOR','FIX_NONLBR',
                                   'VAR_LABOR','VAR_NONLBR').

  LOOP AT gt_setleaf.
    CASE gt_setleaf-setname.
      WHEN 'FIX_LABOR'.
        CLEAR gr_fixlbr.
        gr_fixlbr-sign = 'I'.
        gr_fixlbr-option = 'EQ'.
        gr_fixlbr-low = gt_setleaf-valfrom.
        APPEND gr_fixlbr.
      WHEN 'VAR_LABOR'.
        CLEAR gr_varlbr.
        gr_varlbr-sign = 'I'.
        gr_varlbr-option = 'EQ'.
        gr_varlbr-low = gt_setleaf-valfrom.
        APPEND gr_varlbr.
      WHEN 'FIX_NONLBR'.
        CLEAR gr_fixnlbr.
        gr_fixnlbr-sign = 'I'.
        gr_fixnlbr-option = 'EQ'.
        gr_fixnlbr-low = gt_setleaf-valfrom.
        APPEND gr_fixnlbr.
      WHEN 'VAR_NONLBR'.
        CLEAR gr_varnlbr.
        gr_varnlbr-sign = 'I'.
        gr_varnlbr-option = 'EQ'.
        gr_varnlbr-low = gt_setleaf-valfrom.
        APPEND gr_varnlbr.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_GET_SETLEAF

*&---------------------------------------------------------------------*
*&      Form  F_GET_COEP_MOH
*&---------------------------------------------------------------------*
FORM f_get_coep_moh .
  DATA: lr_kstar TYPE RANGE OF coep-kstar WITH HEADER LINE.

  APPEND LINES OF gr_fixlbr  TO lr_kstar.
  APPEND LINES OF gr_varlbr  TO lr_kstar.
  APPEND LINES OF gr_fixnlbr TO lr_kstar.
  APPEND LINES OF gr_varnlbr TO lr_kstar.

  IF gt_csksmoh[] IS NOT INITIAL.
    SELECT kokrs belnr buzei perio gjahr objnr kstar wogbtr owaer
           bukrs gsber vrgng wrttp
      INTO CORRESPONDING FIELDS OF TABLE gt_coepmoh
      FROM coep FOR ALL ENTRIES IN gt_csksmoh
      WHERE kokrs = gv_kokrs
        AND perio = p_perio
        AND objnr = gt_csksmoh-objnr
        AND gjahr = p_gjahr
        AND kstar IN lr_kstar
        AND vrgng NOT LIKE 'KS%'
        AND wrttp = '04'.
  ENDIF.

  "# PRD
  IF gt_csksprd[] IS NOT INITIAL.
    SELECT kokrs belnr buzei perio gjahr objnr kstar wogbtr owaer
           bukrs gsber vrgng wrttp
      INTO CORRESPONDING FIELDS OF TABLE gt_coepprd
      FROM coep FOR ALL ENTRIES IN gt_csksprd
      WHERE kokrs = gv_kokrs
        AND perio = p_perio
        AND objnr = gt_csksprd-objnr
        AND gjahr = p_gjahr
        AND kstar IN lr_kstar
        AND vrgng NOT LIKE 'KS%'
        AND wrttp = '04'.
  ENDIF.

*  IF gt_csksprde[] IS NOT INITIAL.
*    SELECT kokrs belnr buzei perio gjahr objnr kstar wogbtr owaer
*           bukrs gsber
*      APPENDING CORRESPONDING FIELDS OF TABLE gt_coepprd
*      FROM coep FOR ALL ENTRIES IN gt_csksprde
*      WHERE kokrs = gv_kokrs
*        AND perio = p_perio
*        AND objnr = gt_csksprde-objnr
*        AND gjahr = p_gjahr
*        AND kstar IN lr_kstar
*        AND vrgng NOT LIKE 'KS%'.
*  ENDIF.

  "# PRDE
  IF gt_csksprde[] IS NOT INITIAL.
    SELECT kokrs belnr buzei perio gjahr objnr kstar wogbtr owaer
           bukrs gsber vrgng wrttp
      INTO CORRESPONDING FIELDS OF TABLE gt_coepprde
      FROM coep FOR ALL ENTRIES IN gt_csksprde
      WHERE kokrs = gv_kokrs
        AND perio = p_perio
        AND objnr = gt_csksprde-objnr
        AND gjahr = p_gjahr
        AND kstar IN lr_kstar
        AND vrgng NOT LIKE 'KS%'
        AND wrttp = '04'.

    "Append lines to # PRD
*    APPEND LINES OF gt_coepprde TO gt_coepprd.
  ENDIF.
ENDFORM.                    " F_GET_COEP_MOH

*&---------------------------------------------------------------------*
*&      Form  F_GET_COEP_PRD
*&---------------------------------------------------------------------*
FORM f_get_coep_prd .
  DATA: lt_coepprd_lbr  TYPE TABLE OF coep WITH HEADER LINE,
        lt_coepprd_nlbr TYPE TABLE OF coep WITH HEADER LINE,
        lt_coepprde_lbr  TYPE TABLE OF coep WITH HEADER LINE,
        lt_coepprde_nlbr TYPE TABLE OF coep WITH HEADER LINE.

  "PRD
  IF gt_csksprd_lbr[] IS NOT INITIAL.
    SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
           bukrs gsber vrgng wrttp
      INTO CORRESPONDING FIELDS OF TABLE lt_coepprd_lbr
      FROM coep FOR ALL ENTRIES IN gt_csksprd_lbr
      WHERE kokrs = gv_kokrs
        AND perio = p_perio
        AND objnr = gt_csksprd_lbr-objnr
        AND gjahr = p_gjahr
        AND kstar = '1000000010'
        AND vrgng = 'RKL'
        AND wrttp = '04'.
  ENDIF.

*  IF gt_csksprde_lbr[] IS NOT INITIAL.
*    SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
*           bukrs gsber vrgng
*      APPENDING CORRESPONDING FIELDS OF TABLE lt_coepprd_lbr
*      FROM coep FOR ALL ENTRIES IN gt_csksprde_lbr
*      WHERE kokrs = gv_kokrs
*        AND perio = p_perio
*        AND objnr = gt_csksprde_lbr-objnr
*        AND gjahr = p_gjahr
*        AND kstar = '1000000010'
*        AND vrgng = 'RKL'.
*  ENDIF.

  IF gt_csksprd_nlbr[] IS NOT INITIAL.
    SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
           bukrs gsber vrgng wrttp
      INTO CORRESPONDING FIELDS OF TABLE lt_coepprd_nlbr
      FROM coep FOR ALL ENTRIES IN gt_csksprd_nlbr
      WHERE kokrs = gv_kokrs
        AND perio = p_perio
        AND objnr = gt_csksprd_nlbr-objnr
        AND gjahr = p_gjahr
        AND kstar = gv_kstar  "'1000000020'
        AND vrgng = 'RKL'
        AND wrttp = '04'.
  ENDIF.

*  IF gt_csksprde_nlbr[] IS NOT INITIAL.
*    SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
*           bukrs gsber vrgng
*      APPENDING CORRESPONDING FIELDS OF TABLE lt_coepprd_nlbr
*      FROM coep FOR ALL ENTRIES IN gt_csksprde_nlbr
*      WHERE kokrs = gv_kokrs
*        AND perio = p_perio
*        AND objnr = gt_csksprde_nlbr-objnr
*        AND gjahr = p_gjahr
*        AND kstar = gv_kstar  "'1000000020'
*        AND vrgng = 'RKL'.
*  ENDIF.

  "Summaries itab
  LOOP AT lt_coepprd_lbr.
    CLEAR: lt_coepprd_lbr-belnr,lt_coepprd_lbr-buzei.
    MOVE-CORRESPONDING lt_coepprd_lbr TO gt_coepprd_lbr.
    COLLECT gt_coepprd_lbr.
*    ADD gt_coepprd_lbr2-megbtr TO gv_megbtr_lbr.
  ENDLOOP.

  LOOP AT lt_coepprd_nlbr.
    CLEAR: lt_coepprd_nlbr-belnr,lt_coepprd_nlbr-buzei.
    MOVE-CORRESPONDING lt_coepprd_nlbr TO gt_coepprd_nlbr.
    COLLECT gt_coepprd_nlbr.
*    ADD gt_coepprd_nlbr2-megbtr TO gv_megbtr_nlbr.
  ENDLOOP.

*  MULTIPLY: gv_megbtr_lbr BY -1,
*            gv_megbtr_nlbr BY -1.

  "EXIS
  IF gt_csksprde_lbr[] IS NOT INITIAL.
    SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
           bukrs gsber vrgng wrttp
      INTO CORRESPONDING FIELDS OF TABLE lt_coepprde_lbr
      FROM coep FOR ALL ENTRIES IN gt_csksprde_lbr
      WHERE kokrs = gv_kokrs
        AND perio = p_perio
        AND objnr = gt_csksprde_lbr-objnr
        AND gjahr = p_gjahr
        AND kstar = '1000000010'
        AND vrgng = 'RKL'
        AND wrttp = '04'.
  ENDIF.

  IF gt_csksprde_nlbr[] IS NOT INITIAL.
    SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
           bukrs gsber vrgng wrttp
      INTO CORRESPONDING FIELDS OF TABLE lt_coepprde_nlbr
      FROM coep FOR ALL ENTRIES IN gt_csksprde_nlbr
      WHERE kokrs = gv_kokrs
        AND perio = p_perio
        AND objnr = gt_csksprde_nlbr-objnr
        AND gjahr = p_gjahr
        AND kstar = gv_kstar  "'1000000020'
        AND vrgng = 'RKL'
        AND wrttp = '04'.
  ENDIF.

  "Summaries itab
  LOOP AT lt_coepprde_lbr.
    CLEAR: lt_coepprde_lbr-belnr,lt_coepprde_lbr-buzei.
    MOVE-CORRESPONDING lt_coepprde_lbr TO gt_coepprde_lbr.
    COLLECT gt_coepprde_lbr.
*    ADD gt_coepprde_lbr2-megbtr TO gv_megbtr_lbr.
  ENDLOOP.

  LOOP AT lt_coepprde_nlbr.
    CLEAR: lt_coepprde_nlbr-belnr,lt_coepprde_nlbr-buzei.
    MOVE-CORRESPONDING lt_coepprde_nlbr TO gt_coepprde_nlbr.
    COLLECT gt_coepprde_nlbr.
*    ADD gt_coepprde_nlbr2-megbtr TO gv_megbtr_nlbr.
  ENDLOOP.

*  MULTIPLY: gv_megbtr_lbr BY -1,
*            gv_megbtr_nlbr BY -1.

  IF butt3 = 'X'.
    PERFORM f_get_coep_prd_3.
  ENDIF.
ENDFORM.                    " F_GET_COEP_PRD

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA1
*&---------------------------------------------------------------------*
FORM f_process_data1 .
  DATA: lt_cskts TYPE TABLE OF cskt WITH HEADER LINE,
        lt_csktr TYPE TABLE OF cskt WITH HEADER LINE,
        lt_csku  TYPE TABLE OF csku WITH HEADER LINE.

  "Modify Description
  IF gt_out1[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_cskts
      FROM cskt FOR ALL ENTRIES IN gt_out1
      WHERE spras = sy-langu
        AND kokrs = '8010'
        AND kostl = gt_out1-kostls.

    SELECT * INTO TABLE lt_csktr
      FROM cskt FOR ALL ENTRIES IN gt_out1
      WHERE spras = sy-langu
        AND kokrs = '8010'
        AND kostl = gt_out1-kostlr.

    SELECT * INTO TABLE lt_csku
      FROM csku FOR ALL ENTRIES IN gt_out1
      WHERE spras = sy-langu
        AND ktopl = 'TSPC'
        AND kstar = gt_out1-kstar.
  ENDIF.

  LOOP AT gt_out1 ASSIGNING <fs_out1>.
    CLEAR: lt_cskts,lt_csktr,lt_csku.
    READ TABLE lt_cskts WITH KEY kostl = <fs_out1>-kostls.
    READ TABLE lt_csktr WITH KEY kostl = <fs_out1>-kostlr.
    READ TABLE lt_csku  WITH KEY kstar = <fs_out1>-kstar.
    <fs_out1>-ltexts = lt_cskts-ltext.
    <fs_out1>-ltextr = lt_csktr-ltext.
    <fs_out1>-ltextk = lt_csku-ltext.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA2
*&---------------------------------------------------------------------*
FORM f_process_data2 .
  DATA: lt_cskt TYPE TABLE OF cskt WITH HEADER LINE.

  LOOP AT gt_out1.
    READ TABLE gt_out2 ASSIGNING <fs_out2>
                       WITH KEY bukrs = gt_out1-bukrs
                                gsber = gt_out1-gsber
                                perio = gt_out1-perio
                                gjahr = gt_out1-gjahr
                                kostl = gt_out1-kostlr.
    IF sy-subrc = 0.
      "Do nothing
    ELSE.
      APPEND INITIAL LINE TO gt_out2 ASSIGNING <fs_out2>.
      <fs_out2>-bukrs = gt_out1-bukrs.
      <fs_out2>-gsber = gt_out1-gsber.
      <fs_out2>-perio = gt_out1-perio.
      <fs_out2>-gjahr = gt_out1-gjahr.
      <fs_out2>-kostl = gt_out1-kostlr.
      <fs_out2>-owaer = gt_out1-owaer.
    ENDIF.

    CASE gt_out1-setname.
      WHEN 'FIX_LABOR'.
        ADD gt_out1-amount TO <fs_out2>-wogbtr1.
      WHEN 'VAR_LABOR'.
        ADD gt_out1-amount TO <fs_out2>-wogbtr2.
      WHEN 'FIX_NONLBR'.
        ADD gt_out1-amount TO <fs_out2>-wogbtr3.
      WHEN 'VAR_NONLBR'.
        ADD gt_out1-amount TO <fs_out2>-wogbtr4.
    ENDCASE.
  ENDLOOP.

  LOOP AT gt_coepprd_lbr.
    MULTIPLY gt_coepprd_lbr-megbtr BY -1.
    READ TABLE gt_out2 ASSIGNING <fs_out2>
                       WITH KEY bukrs = gt_coepprd_lbr-bukrs
                                gsber = gt_coepprd_lbr-gsber
                                perio = gt_coepprd_lbr-perio
                                gjahr = gt_coepprd_lbr-gjahr
                                kostl = gt_coepprd_lbr-objnr+6(10).
    IF sy-subrc = 0.
      ADD gt_coepprd_lbr-megbtr TO <fs_out2>-megbtr1.
      <fs_out2>-meinh = gt_coepprd_lbr-meinh.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_coepprd_nlbr.
    MULTIPLY gt_coepprd_nlbr-megbtr BY -1.
    READ TABLE gt_out2 ASSIGNING <fs_out2>
                       WITH KEY bukrs = gt_coepprd_nlbr-bukrs
                                gsber = gt_coepprd_nlbr-gsber
                                perio = gt_coepprd_nlbr-perio
                                gjahr = gt_coepprd_nlbr-gjahr
                                kostl = gt_coepprd_nlbr-objnr+6(10).
    IF sy-subrc = 0.
      ADD gt_coepprd_nlbr-megbtr TO <fs_out2>-megbtr2.
      <fs_out2>-meinh = gt_coepprd_lbr-meinh.
    ENDIF.
  ENDLOOP.

  "Modify Description
  IF gt_out2[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_cskt
      FROM cskt FOR ALL ENTRIES IN gt_out2
      WHERE spras = sy-langu
        AND kokrs = '8010'
        AND kostl = gt_out2-kostl.
  ENDIF.

  LOOP AT gt_out2 ASSIGNING <fs_out2>.
    CLEAR: lt_cskt.
    READ TABLE lt_cskt WITH KEY kostl = <fs_out2>-kostl.
    <fs_out2>-ltext = lt_cskt-ltext.

    IF <fs_out2>-megbtr1 IS NOT INITIAL.
      <fs_out2>-amount1 = <fs_out2>-wogbtr1 / <fs_out2>-megbtr1.
      <fs_out2>-amount2 = <fs_out2>-wogbtr2 / <fs_out2>-megbtr1.
    ENDIF.
    IF <fs_out2>-megbtr2 IS NOT INITIAL.
      <fs_out2>-amount3 = <fs_out2>-wogbtr3 / <fs_out2>-megbtr2.
      <fs_out2>-amount4 = <fs_out2>-wogbtr4 / <fs_out2>-megbtr2.
    ENDIF.

    <fs_out2>-wogbtr12 = <fs_out2>-wogbtr1 + <fs_out2>-wogbtr2.
    <fs_out2>-wogbtr34 = <fs_out2>-wogbtr3 + <fs_out2>-wogbtr4.
    <fs_out2>-megbtr12 = <fs_out2>-megbtr1 + <fs_out2>-megbtr2.
  ENDLOOP.

  SORT gt_out2 BY bukrs gsber perio gjahr kostl.
ENDFORM.                    " F_PROCESS_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA3
*&---------------------------------------------------------------------*
FORM f_process_data3 .
  DATA: lv_kostl TYPE csks-kostl.
  DATA: lt_cskt  TYPE TABLE OF cskt WITH HEADER LINE,
        lt_csku  TYPE TABLE OF csku WITH HEADER LINE.

  LOOP AT gt_coepprd_3.
    CLEAR: gt_afko,gt_makt.
    READ TABLE gt_afko WITH KEY aufnr = gt_coepprd_3-objnr+2(12).
    READ TABLE gt_makt WITH KEY matnr = gt_afko-plnbez.

    gt_out3-bukrs   = gt_coepprd_3-bukrs.
    gt_out3-gsber   = gt_coepprd_3-gsber.
    gt_out3-perio   = gt_coepprd_3-perio.
    gt_out3-gjahr   = gt_coepprd_3-gjahr.
    gt_out3-objnr   = gt_coepprd_3-objnr.
    gt_out3-meinh   = gt_coepprd_3-meinh.
    gt_out3-plnbez  = gt_afko-plnbez.
    gt_out3-maktx   = gt_makt-maktx.
    gt_out3-kostl   = gt_coepprd_3-parob+6(10).
*    gt_out3-kstar   = gt_coepprd_3-kstar.

    CASE p_bukrs.
      WHEN '8330'.
        CASE gt_coepprd_3-kstar.
          WHEN '1000000010'.
            gt_out3-megbtr1 = gt_coepprd_3-megbtr.
          WHEN '1000000015'.
            gt_out3-megbtr2 = gt_coepprd_3-megbtr.
        ENDCASE.
      WHEN OTHERS.
        CASE gt_coepprd_3-kstar.
          WHEN '1000000010'.
            gt_out3-megbtr1 = gt_coepprd_3-megbtr.
          WHEN '1000000020'.
            gt_out3-megbtr2 = gt_coepprd_3-megbtr.
        ENDCASE.
    ENDCASE.

    COLLECT gt_out3. CLEAR gt_out3.
  ENDLOOP.

  "Modify Description
  IF gt_out3[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_cskt
      FROM cskt FOR ALL ENTRIES IN gt_out3
      WHERE spras = sy-langu
        AND kokrs = '8010'
        AND kostl = gt_out3-kostl.

    SELECT * INTO TABLE lt_csku
      FROM csku FOR ALL ENTRIES IN gt_out3
      WHERE spras = sy-langu
        AND ktopl = 'TSPC'
        AND kstar = gt_out3-kstar.
  ENDIF.

  LOOP AT gt_out3 ASSIGNING <fs_out3>.
    CLEAR: gt_out2,lt_cskt,lt_csku.
    READ TABLE gt_out2 WITH KEY kostl = <fs_out3>-kostl.
    READ TABLE lt_cskt WITH KEY kostl = <fs_out3>-kostl.
    READ TABLE lt_csku WITH KEY kstar = <fs_out3>-kstar.

    <fs_out3>-ltexts = lt_cskt-ltext.
    <fs_out3>-ltextu = lt_csku-ltext.
    <fs_out3>-wogbtr1 = gt_out2-amount1.
    <fs_out3>-wogbtr2 = gt_out2-amount2.
    <fs_out3>-wogbtr3 = gt_out2-amount3.
    <fs_out3>-wogbtr4 = gt_out2-amount4.
    <fs_out3>-owaer   = gt_out2-owaer.
    <fs_out3>-amount1 = <fs_out3>-megbtr1 * gt_out2-amount1.
    <fs_out3>-amount2 = <fs_out3>-megbtr1 * gt_out2-amount2.
    <fs_out3>-amount3 = <fs_out3>-megbtr2 * gt_out2-amount3.
    <fs_out3>-amount4 = <fs_out3>-megbtr2 * gt_out2-amount4.

*    CASE gt_coepprd_3-kstar.
*      WHEN '1000000010'.
*        <fs_out3>-amount1 = <fs_out3>-megbtr1 * <fs_out3>-wogbtr1.
*        <fs_out3>-amount2 = <fs_out3>-megbtr1 * <fs_out3>-wogbtr2.
*      WHEN '1000000020'.
*        <fs_out3>-amount3 = <fs_out3>-megbtr2 * <fs_out3>-wogbtr3.
*        <fs_out3>-amount4 = <fs_out3>-megbtr2 * <fs_out3>-wogbtr4.
*    ENDCASE.
  ENDLOOP.

  SORT gt_out3 BY bukrs gsber perio gjahr objnr kostl.
ENDFORM.                    " F_PROCESS_DATA2

*&---------------------------------------------------------------------*
*&      Form  F_GET_AFKO
*&---------------------------------------------------------------------*
FORM f_get_afko .
  DATA: lt_coepprd_3 TYPE TABLE OF coep WITH HEADER LINE.

  LOOP AT gt_coepprd_3.
    MOVE-CORRESPONDING gt_coepprd_3 TO lt_coepprd_3.
    lt_coepprd_3-objnr = gt_coepprd_3-objnr+2(12).
    APPEND lt_coepprd_3.
  ENDLOOP.

  IF lt_coepprd_3[] IS NOT INITIAL.
    SELECT aufnr plnbez
      INTO CORRESPONDING FIELDS OF TABLE gt_afko
      FROM afko FOR ALL ENTRIES IN lt_coepprd_3
      WHERE aufnr = lt_coepprd_3-objnr(12).

    IF gt_afko[] IS NOT INITIAL.
      SELECT * INTO TABLE gt_makt
        FROM makt FOR ALL ENTRIES IN gt_afko
        WHERE matnr = gt_afko-plnbez
          AND spras = sy-langu.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_AFKO

*&---------------------------------------------------------------------*
*&      Form  F_GET_COEP_PRD_3
*&---------------------------------------------------------------------*
FORM f_get_coep_prd_3 .
  DATA: lt_coepprd_3 TYPE TABLE OF coep WITH HEADER LINE.

  CASE p_bukrs.
    WHEN '8330'.
      SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
             bukrs gsber vrgng parob wrttp
        INTO CORRESPONDING FIELDS OF TABLE lt_coepprd_3
        FROM coep
        WHERE kokrs = gv_kokrs
          AND perio = p_perio
          AND objnr LIKE 'OR%'
          AND gjahr = p_gjahr
          AND kstar IN ('1000000010','1000000015')
          AND vrgng = 'RKL'
          AND bukrs = p_bukrs
          AND gsber = p_gsber
          AND wrttp = '04'.
    WHEN OTHERS.
      SELECT kokrs belnr buzei perio gjahr objnr kstar megbtr meinh
             bukrs gsber vrgng parob wrttp
        INTO CORRESPONDING FIELDS OF TABLE lt_coepprd_3
        FROM coep
        WHERE kokrs = gv_kokrs
          AND perio = p_perio
          AND objnr LIKE 'OR%'
          AND gjahr = p_gjahr
          AND kstar IN ('1000000010','1000000020')
          AND vrgng = 'RKL'
          AND bukrs = p_bukrs
          AND gsber = p_gsber
          AND wrttp = '04'.
  ENDCASE.

  "Summaries itab
  LOOP AT lt_coepprd_3.
    CLEAR: lt_coepprd_3-belnr,
           lt_coepprd_3-buzei.
    MOVE-CORRESPONDING lt_coepprd_3 TO gt_coepprd_3.
    COLLECT gt_coepprd_3.
  ENDLOOP.

  PERFORM f_get_afko.
ENDFORM.                    " F_GET_COEP_PRD_3

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_SUMMARY
*&---------------------------------------------------------------------*
FORM f_collect_summary  USING    fu_bukrs fu_gsber fu_perio fu_gjahr
                                 fu_kostls fu_kostlr fu_wogbtr fu_megbtr
                                 fu_zlabor.
  gt_out1s1-bukrs   = gt_out1s2-bukrs   = fu_bukrs.
  gt_out1s1-gsber   = gt_out1s2-gsber   = fu_gsber.
  gt_out1s1-perio   = gt_out1s2-perio   = fu_perio.
  gt_out1s1-gjahr   = gt_out1s2-gjahr   = fu_gjahr.
  gt_out1s1-kostls  = gt_out1s2-kostls  = fu_kostls.
  gt_out1s1-kostlr  = gt_out1s2-kostlr  = fu_kostlr.

  gt_out1s1-wogbtr = fu_wogbtr.
  gt_out1s1-zlabor = fu_zlabor.
  COLLECT gt_out1s1. CLEAR gt_out1s1.

  READ TABLE gt_out1s2 WITH KEY bukrs  = fu_bukrs
                                gsber  = fu_gsber
                                perio  = fu_perio
                                gjahr  = fu_gjahr
                                kostls = fu_kostls
                                kostlr = fu_kostlr
                                zlabor = fu_zlabor
                                TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    gt_out1s2-megbtr = fu_megbtr.
    gt_out1s2-zlabor = fu_zlabor.
    APPEND gt_out1s2. CLEAR gt_out1s2.
  ENDIF.
ENDFORM.                    " F_COLLECT_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARIES_QTY
*&---------------------------------------------------------------------*
FORM f_summaries_qty .
  LOOP AT gt_out1s2.
    MOVE-CORRESPONDING gt_out1s2 TO gt_out1s3.
    CLEAR gt_out1s3-kostlr.
    COLLECT gt_out1s3. CLEAR gt_out1s3.
  ENDLOOP.
ENDFORM.                    " F_SUMMARIES_QTY

*&---------------------------------------------------------------------*
*&      Form  F_INIT_NEW_COST_CENTER
*&---------------------------------------------------------------------*
FORM f_init_new_cost_center  USING    fu_gsber.
  SELECT * INTO TABLE gt_zcodt008
    FROM zcodt008 WHERE werks = fu_gsber.

  LOOP AT gt_zcodt008.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gt_zcodt008-kostl
      IMPORTING
        output = gt_zcodt008-kostl.
    MODIFY gt_zcodt008 TRANSPORTING kostl.
  ENDLOOP.
ENDFORM.                    " F_INIT_NEW_COST_CENTER
