*&---------------------------------------------------------------------*
*&  Include           ZCO_COST_ANALYSISCL1
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application DEFINITION.
  PUBLIC SECTION.
    METHODS :
      handle_item_double_click
        FOR EVENT item_double_click
        OF cl_gui_alv_tree
        IMPORTING fieldname node_key.
ENDCLASS.               "lcl_application  DEFINITION

*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
  METHOD  handle_item_double_click.
    DATA : node_text        TYPE lvc_value,
           item_layout      TYPE lvc_t_layi,
           node_layout      TYPE lvc_s_layn.

    DATA : ls_detail  TYPE ty_detail,
           ls_alv     TYPE ty_detail,
           ls_mara    TYPE mara,
           lv_objnr   LIKE caufv-objnr,
           lt_alv     TYPE STANDARD TABLE OF ty_detail.

    DATA : ls_xmara   LIKE LINE OF gt_xmara,
           lv_matnr   TYPE mara-matnr.

    CLEAR : gs_header.

    CALL METHOD g_tree->get_outtab_line
      EXPORTING
        i_node_key     = node_key
      IMPORTING
        e_node_text    = node_text
        et_item_layout = item_layout
        es_node_layout = node_layout.

    IF node_layout-n_image = icon_order.
      gs_header-aufnr = node_text.
      PERFORM f_get_parent USING    node_key
                           CHANGING node_text.
      gs_header-plnbez  = node_text.

      PERFORM f_display_header USING    '' '' ''
                               CHANGING lv_objnr.
    ELSE.
      lv_matnr  = node_text.
      CLEAR ls_xmara.
      READ TABLE gt_xmara INTO ls_xmara
                          WITH KEY matnr = lv_matnr.
      PERFORM f_display_header USING    '1' ls_xmara-matnr ls_xmara-meins
                               CHANGING lv_objnr.
    ENDIF.

    CLEAR : gt_alv[], gt_alv.

    IF lv_objnr IS NOT INITIAL.
      SORT gt_detail BY objnr.
      LOOP AT gt_detail INTO ls_detail WHERE objnr = lv_objnr.
        PERFORM f_detail_to_alv TABLES   lt_alv
                                USING    ls_detail.
      ENDLOOP.

      SORT lt_alv BY objnr kstar sourc hrkft DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_alv COMPARING objnr kstar sourc.

      PERFORM f_actual_qty_val TABLES lt_alv.

      PERFORM f_plan_qty_val TABLES lt_alv.

      PERFORM f_target_qty_val TABLES lt_alv.

      SORT lt_alv BY kstar sourc.
      PERFORM f_collect_alv_data TABLES lt_alv
                                 USING ''.
    ELSE.
      lv_matnr  = node_text.
      PERFORM f_display_detail USING lv_matnr.
    ENDIF.

    PERFORM f_calc_act_amount USING lv_objnr.

  ENDMETHOD.                    "handle_item_double_click
ENDCLASS.               "lcl_application  IMPLEMENTATION
