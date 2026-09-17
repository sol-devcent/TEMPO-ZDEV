*----------------------------------------------------------------------*
***INCLUDE ZRVCFPR00F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  DATA: BEGIN OF lt_matnr OCCURS 0,
         matnr LIKE mara-matnr,
        END OF lt_matnr.
  DATA: BEGIN OF t_material OCCURS 0,
          matnr LIKE mara-matnr,
          meins LIKE mara-meins,
          maktx LIKE makt-maktx,
        END OF t_material.
  DATA: lt_pgmi TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_pgmi1 TYPE STANDARD TABLE OF pgmi WITH HEADER LINE.
  DATA: lt_mara TYPE STANDARD TABLE OF mara WITH HEADER LINE.
  DATA: lv_nama(15).
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json             TYPE string.
  DATA : lv_str     TYPE string.
  DATA: ls_header TYPE ty_header.
  DATA: ls_temp(15).
  DATA: ls_temp1(15).
  DATA: lv_subrc LIKE sy-subrc.
  DATA: lv_count TYPE i.
  DATA: ls_mara  TYPE ty_mara.

  CLEAR: lv_count.
  SELECT * INTO TABLE lt_pgmi FROM pgmi
    WHERE pgtyp = space
      AND prgrp IN s_prgrp.
  IF lt_pgmi[] IS NOT INITIAL.
    lv_subrc = 4.
    WHILE lv_subrc IS NOT INITIAL.
      ADD 1 TO lv_count.
      PERFORM f_get_material TABLES lt_pgmi
                             USING 'X'
                             CHANGING lv_subrc.
      IF lv_count > 10.
        CLEAR lv_subrc.
      ENDIF.
    ENDWHILE.
  ENDIF.

  SORT gt_mara BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM gt_mara COMPARING matnr werks.
  IF s_matnr IS NOT INITIAL.
    DELETE gt_mara WHERE matnr NOT IN s_matnr.
  ENDIF.

  IF gt_mara[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_eban FROM eban FOR ALL ENTRIES IN gt_mara
      WHERE lfdat IN s_psttr
        AND matnr = gt_mara-matnr "lt_pgmi-nrmit
        AND loekz NE 'X'
        AND frgkz EQ 'X'
        AND fixkz EQ space.
  ENDIF.
  REFRESH: s_matnr, gt_mara.
  CLEAR: gs_count, gt_mara[].
  IF gt_plaf[] IS NOT INITIAL.
    LOOP AT gt_plaf INTO gs_plaf.
      ls_mara-matnr = gs_plaf-matnr..
      APPEND ls_mara TO gt_mara.
      ls_header-plant =  gs_plaf-pwwrk.
      ls_header-sloc =  gs_plaf-lgort.
      ls_header-doc_type = 'PL'.
      ls_header-plan_order =  gs_plaf-plnum.
      WRITE gs_plaf-psttr TO ls_temp DD/MM/YYYY.
      ls_header-delivery_date = ls_temp.

      WRITE gs_plaf-pertr TO ls_temp DD/MM/YYYY.
      ls_header-release_date = ls_temp.
      ls_header-material = gs_plaf-matnr.
      WRITE gs_plaf-gsmng TO ls_temp NO-GAP NO-GROUPING DECIMALS 0.
      ls_header-qty = ls_temp.
      "      ls_header-uom = gs_plaf-meins.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = gs_plaf-meins
          language       = sy-langu
        IMPORTING
          output         = ls_header-uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      APPEND ls_header TO gs_plan_order-plan_order.
      APPEND ls_header TO gt_out.
      ADD 1 TO gs_count.
    ENDLOOP.
  ENDIF.
  IF gt_eban[] IS NOT INITIAL.
    LOOP AT gt_eban INTO gs_eban.
      ls_mara-matnr = gs_eban-matnr.
      APPEND ls_mara TO gt_mara.
      ls_header-plant =  gs_eban-werks.
      ls_header-sloc = gs_eban-lgort.
      ls_header-doc_type = 'PR'. "Purchase Requisition
      ls_header-plan_order =  gs_eban-banfn.
      WRITE gs_eban-lfdat TO ls_temp DD/MM/YYYY.
      ls_header-delivery_date = ls_temp.
      WRITE gs_eban-frgdt TO ls_temp DD/MM/YYYY.
      ls_header-release_date = ls_temp.

      ls_header-material = gs_eban-matnr.
      WRITE gs_eban-menge TO ls_temp NO-GAP NO-GROUPING DECIMALS 0.
      ls_header-qty = ls_temp.
      "      ls_header-uom = gs_eban-meins.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = gs_eban-meins
          language       = sy-langu
        IMPORTING
          output         = ls_header-uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      APPEND ls_header TO gs_plan_order-plan_order.
      APPEND ls_header TO gt_out.
      ADD 1 TO gs_count.
    ENDLOOP.
    IF gt_mara[] IS NOT INITIAL.
      SORT gt_mara BY matnr.
      REFRESH: s_matnr.
      CLEAR: s_matnr.
      DELETE ADJACENT DUPLICATES FROM gt_mara COMPARING matnr.
      LOOP AT gt_mara INTO ls_mara.
        s_matnr-low = ls_mara-matnr.
        s_matnr-sign = 'I'.
        s_matnr-option = 'EQ'.
        APPEND s_matnr.
      ENDLOOP.
      IF s_matnr[] IS NOT INITIAL.
        SUBMIT zhsmmm_i005 WITH p_rad1 = 'X'
                           WITH s_matnr IN s_matnr AND RETURN.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_material  TABLES   ft_pgmi   STRUCTURE pgmi
                     USING    fu_add
                     CHANGING fc_subrc.
  DATA: gt_matnr          TYPE STANDARD TABLE OF range_matnr.
  DATA : lt_pgmi    TYPE STANDARD TABLE OF pgmi,
         lt_mara    TYPE STANDARD TABLE OF ty_mara,
         ls_pgmi    LIKE LINE OF lt_pgmi,
         ls_mara    LIKE LINE OF gt_mara,
         ls_matnr   LIKE LINE OF gt_matnr.

  lt_pgmi[] = ft_pgmi[].

  IF lt_pgmi[] IS NOT INITIAL.
    SELECT marc~matnr marc~werks mara~mtart mara~meins mara~mprof
      FROM marc JOIN mara ON marc~matnr = mara~matnr
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_pgmi
      WHERE marc~matnr = lt_pgmi-nrmit
        AND marc~werks = lt_pgmi-wemit.
    IF sy-subrc = 0.
      IF fu_add IS NOT INITIAL.
        APPEND LINES OF lt_mara TO gt_mara.
      ELSE.
        LOOP AT lt_mara INTO ls_mara WHERE mtart <> gv_mtart.
          ls_matnr-low    = ls_mara-matnr.
          ls_matnr-sign   = 'I'.
          ls_matnr-option = 'EQ'.
          APPEND ls_matnr TO gt_matnr.
          CLEAR ls_matnr.
        ENDLOOP.
      ENDIF.
      CLEAR ft_pgmi[].
      IF lt_pgmi[] IS NOT INITIAL.
        SELECT *
          FROM pgmi
          INTO CORRESPONDING FIELDS OF TABLE ft_pgmi
          FOR ALL ENTRIES IN lt_pgmi
          WHERE pgtyp = space
            AND prgrp = lt_pgmi-nrmit
            AND werks = lt_pgmi-wemit.
        IF sy-subrc <> 0.
          CLEAR fc_subrc.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL


*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
  DATA: lv_fu_selfield TYPE slis_selfield.
  IF p_back IS INITIAL.
    PERFORM f_alv TABLES gt_out.
  ELSE.
    PERFORM f_user_command USING '&PRC' lv_fu_selfield.
  ENDIF.

ENDFORM.                    " F_PRINT_DATA


*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
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
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'GT_OUT' : "ft_report:
    'PLANT' 'EBAN' 'WERKS' '' '' 'Plant' '' '' '' '' '' '' '' '',
    'DOC_TYPE' '' '' '' '' 'Doc Type' '' '' '' '' '' '' '' '',
    'PLAN_ORDER' 'EBAN' 'BANPN' '' '' 'Doc No.' '' '' '' '' '' '' '' '',
    'DELIVERY_DATE' 'EKET' 'EINDT' '' '17' 'Delivery. Date' '' '' '' '' '' '' '' '',
    'RELEASE_DATE' '' '' '' '17' 'Release. Date' '' '' '' '' '' '' '' '',
    'MATERIAL' 'EBAN' 'MATNR' '' '' 'Product No.' '' '' '' '' '' '' '' '',
    'QTY' 'EBAN' 'MENGE' '' '' 'Quantity' '' '' '' '' '' '' '' '',
    'UOM' '' '' '' '' 'Uom' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
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
                          value(fu_checkbox).

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
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
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
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json             TYPE string.
  DATA : lv_str     TYPE string.
**  DATA: ls_header TYPE ty_header.
  DATA: ls_temp(15).
  DATA: ls_temp1(15).
  DATA: lv_nama(15).
  CASE fu_ucomm.
    WHEN '&PRC'.
      IF gs_plan_order-plan_order[] IS NOT INITIAL.
        WRITE sy-datum TO ls_temp DDMMYY.
        WRITE sy-uzeit TO ls_temp1 USING EDIT MASK '______'.
        CONCATENATE 'PL_' ls_temp ls_temp1 INTO lv_nama.
        "    lv_nama = sy-datum.
        CREATE OBJECT cl_json_data
          EXPORTING
            DATA = gs_plan_order.
        cl_json_data->serialize( ).
        gv_json = cl_json_data->get_data( ).
        PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'HSM_SENDPL' sy-subrc lv_str. "ztiam_i0001
        PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/tnt/' 'HSM_SENDPL'.
        IF sy-batch = 'X'.
          WRITE: / 'Send data to WEB'.
          WRITE: / 'Total Line item dikirim : ', gs_count.
          WRITE: / 'Message / Respon from WEB : ', lv_str.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " F_USER_COMMAND
