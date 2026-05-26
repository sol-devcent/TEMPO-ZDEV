*----------------------------------------------------------------------*
*   INCLUDE ZF_KWITANSIF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data CHANGING fc_error.
  SELECT a~kunnr a~name1 a~name2 ort01 pstlz name_co
    FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                   JOIN adrc AS c ON a~adrnr EQ c~addrnumber
    INTO TABLE gt_kna1
    WHERE a~kunnr IN so_kunnr AND
          b~vkbur EQ pa_vkbur.

  SELECT vkbur b~name1 street city1 post_code1
    FROM tvbur AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
    INTO TABLE gt_tvbur
    WHERE vkbur EQ pa_vkbur.

  IF sy-subrc EQ 0.
    CASE 'X'.
      WHEN radio1.
        SELECT SINGLE city1 petugas1 jabat1
          FROM zfkwitt
          INTO (gv_city1, gv_petugas1, gv_jabat1)
          WHERE ztran EQ co_kw1 AND
                vkbur EQ pa_vkbur.
      WHEN radio2.
        SELECT SINGLE city1 petugas1 jabat1
          FROM zfkwitt
          INTO (gv_city1, gv_petugas1, gv_jabat1)
          WHERE ztran EQ co_kw2 AND
                vkbur EQ pa_vkbur.
      WHEN radio3.
        SELECT SINGLE city1 petugas1 jabat1
          FROM zfkwitt
          INTO (gv_city1, gv_petugas1, gv_jabat1)
          WHERE ztran EQ co_ttf AND
                vkbur EQ pa_vkbur.

    ENDCASE.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      gv_fname  = 'ZFKWI1'.
    WHEN radio2.
      gv_fname  = 'ZFKWI2'.
    WHEN radio3.
      gv_fname  = 'ZFTTF'.
  ENDCASE.

  fc_error  = sy-subrc.

  IF radio3 IS NOT INITIAL.
    SELECT bukrs vkbur kunnr zsts status zhit zuserc zdatc zuserl zdatl
      FROM zfkwiout
      INTO TABLE gt_zfkwiout
      FOR ALL ENTRIES IN gt_kna1
      WHERE bukrs EQ pa_bukrs
        AND vkbur EQ pa_vkbur
        AND kunnr EQ gt_kna1-kunnr.
  ELSEIF radio10 IS NOT INITIAL.
    SELECT bukrs vkbur kunnr zsts status zhit zuserc zdatc zuserl zdatl
      FROM zfkwiout
      INTO TABLE gt_zfkwiout
      WHERE bukrs EQ pa_bukrs
        AND vkbur EQ pa_vkbur
        AND kunnr IN so_kunnr.
  ENDIF.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lv_subrc     TYPE sy-subrc,
        lt_lineitems LIKE lineitems OCCURS 0 WITH HEADER LINE.

  DATA : lt_likp       TYPE STANDARD TABLE OF likp INITIAL SIZE 0.

  IF radio9 IS INITIAL.
    IF pa_check IS INITIAL.
      LOOP AT gt_kna1.
        IF radio3 IS NOT INITIAL.
          CLEAR lv_subrc.
          READ TABLE gt_zfkwiout WITH KEY vkbur = pa_vkbur
                                          kunnr = gt_kna1-kunnr.
          IF sy-subrc NE 0.
            gt_error-kunnr  = gt_kna1-kunnr.
            gt_error-msg    = 'Customer belum terdaftar untuk TTF'.
            lv_subrc        = sy-subrc.
          ENDIF.
        ENDIF.

        CLEAR: lt_lineitems, lt_lineitems[].
        CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
          EXPORTING
            companycode = pa_bukrs
            customer    = gt_kna1-kunnr
            keydate     = pa_gstid
          IMPORTING
            return      = return
          TABLES
            lineitems   = lt_lineitems.

        IF lv_subrc IS NOT INITIAL.
          IF lt_lineitems[] IS NOT INITIAL.
            APPEND gt_error.
            CONTINUE.
          ENDIF.
        ENDIF.

        LOOP AT lt_lineitems.
          IF lt_lineitems-doc_type EQ 'RV' OR
            lt_lineitems-doc_type EQ 'DR'.
            lineitems = lt_lineitems.
            APPEND lineitems.

            PERFORM f_get_likp TABLES lt_likp
                               USING lt_lineitems-alloc_nmbr '1'.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      PERFORM f_get_likp TABLES lt_likp
                         USING '' '2'.
    ELSE.
      CASE 'X'.
        WHEN radio1.
          SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
            bldat budat xblnr blart gsber vkbur shkzg waers dmbtr
            zflag1 zflag2 zflag3 zttfdt
            FROM zfkwi
            INTO TABLE gt_zfkwi
            WHERE ztran EQ co_kw1   AND
                  kunnr IN so_kunnr AND
                  nokwi IN so_nokwi.
        WHEN radio2.
          SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
            bldat budat xblnr blart gsber vkbur shkzg waers dmbtr
            zflag1 zflag2 zflag3 zttfdt
            FROM zfkwi
            INTO TABLE gt_zfkwi
            WHERE ztran EQ co_kw2   AND
                  kunnr IN so_kunnr AND
                  nokwi IN so_nokwi.
        WHEN radio3.
          SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
            bldat budat xblnr blart gsber vkbur shkzg waers dmbtr
            zflag1 zflag2 zflag3 zttfdt
            FROM zfkwi
            INTO TABLE gt_zfkwi
            WHERE ztran EQ co_ttf   AND
                  kunnr IN so_kunnr AND
                  nottf IN so_nottf.
      ENDCASE.

      LOOP AT gt_zfkwi.
        PERFORM f_get_likp TABLES lt_likp
                           USING gt_zfkwi-zuonr '1'.
      ENDLOOP.

      PERFORM f_get_likp TABLES lt_likp
                         USING '' '2'.
    ENDIF.
  ELSE.
    SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
      bldat budat xblnr blart gsber vkbur shkzg waers dmbtr
      zflag1 zflag2 zflag3 zttfdt
      FROM zfkwi
      INTO TABLE gt_zfkwi
      WHERE ztran EQ pa_ztran
        AND bukrs EQ pa_bukrs
        AND vkbur EQ pa_vkbur
        AND kunnr IN so_kunnr
        AND bldat IN so_bldat.

    LOOP AT gt_zfkwi.
      PERFORM f_get_likp TABLES lt_likp
                         USING gt_zfkwi-zuonr '1'.
    ENDLOOP.

    PERFORM f_get_likp TABLES lt_likp
                       USING '' '2'.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio7.
      PERFORM f_alv TABLES gt_delete.
    WHEN radio9.
      PERFORM f_alv TABLES gt_zfkwi.
    WHEN radio10.
      PERFORM f_alv TABLES gt_zfkwiout.
    WHEN radio11.
      PERFORM f_alv TABLES gt_nonttf.
    WHEN OTHERS.
      IF pa_check IS INITIAL.
        SORT gt_vdata BY kunnr zuonr belnr.
        PERFORM f_alv TABLES gt_vdata.
      ELSE.
        PERFORM f_alv TABLES gt_reprint.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
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
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  CASE 'X'.
    WHEN radio7.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'ADRC' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUONR' 'BSID' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NOKWI' 'ZFKWI' 'NOKWI' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NOTTF' 'ZFKWI' 'NOTTF' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WAERS' 'BSID' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'BSID' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.
    WHEN radio9.
      PERFORM f_fieldcatg USING ft_report:
        'ZTRAN' 'ZFKWI' 'ZTRAN' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFKWI' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NOKWI' 'ZFKWI' 'NOKWI' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NOTTF' 'ZFKWI' 'NOTTF' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUONR' 'BSID' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BLDAT' 'ZFKWI' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WAERS' 'BSID' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
        'ZTTFDT' 'ZFKWI' 'ZTTFDT' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    WHEN radio10.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFKWIOUT' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'ZFKWIOUT' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFKWIOUT' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZSTS' 'ZFKWIOUT' 'ZSTS' '' '10' 'Approval' '' '' '' '' '' '' '' '' '' '',
        'STATUS' 'ZFKWIOUT' 'STATUS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZHIT' 'ZFKWIOUT' 'ZHIT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUSERC' 'ZFKWIOUT' 'ZUSERC' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZDATC' 'ZFKWIOUT' 'ZDATC' '' '15' 'Input BOM/BOS' '' '' '' '' '' '' '' '' '' '',
        'ZUSERL' 'ZFKWIOUT' 'ZUSERL' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZDATL' 'ZFKWIOUT' 'ZDATL' '' '15' 'Input KP' '' '' '' '' '' '' '' '' '' '',
        'LEAD' 'ZFKWIOUT' 'LEAD' '' '10' 'Lead Time' '' '' '' '' '' '' '' '' '' ''.
    WHEN radio11.
      PERFORM f_fieldcatg USING ft_report:
        'VKORG' 'KNVV' 'VKORG' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VKBUR' 'KNVV' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'KNVV' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '' 'Customer Name' '' '' '' '' '' '' '' '' '' '',
        'ERDAT' 'KNA1' 'ERDAT' '' '' 'Create On' '' '' '' '' '' '' '' '' '' ''.
    WHEN OTHERS.
      IF pa_check IS INITIAL.
        PERFORM f_fieldcatg USING ft_report:
          'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'NAME1' 'ADRC' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ZUONR' 'BSID' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
* Command for Barcode
*****          'VERUR' 'LIKP' 'VERUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BUDAT' 'BSID' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BLDAT' 'BSID' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'WAERS' 'BSID' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'XBLNR' 'BSID' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BLART' 'BSID' 'BLART' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'GSBER' 'BSID' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BELNR' 'BSID' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
        CASE 'X'.
          WHEN radio3.
            PERFORM f_fieldcatg USING ft_report:
              'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.
          WHEN OTHERS.
            PERFORM f_fieldcatg USING ft_report:
              'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' 'X' ''.
        ENDCASE.
        PERFORM f_fieldcatg USING ft_report:
          'WRBTR' 'BSID' 'WRBTR' 'X' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.
      ELSE.
        PERFORM f_fieldcatg USING ft_report:
          'BUKRS' 'BSID' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'KUNNR' 'BSID' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'NAME1' 'ADRC' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'NOKWI' 'ZFKWI' 'NOKWI' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'NOTTF' 'ZFKWI' 'NOTTF' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'WAERS' 'BSID' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'GSBER' 'BSID' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'DMBTR' 'BSID' 'DMBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize).

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
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
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
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  IF radio9 IS INITIAL AND
    radio10 IS INITIAL AND
    radio11 IS INITIAL.
    fu_layout-box_fieldname      = 'CHECK'.
  ENDIF.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CASE 'X'.
    WHEN radio10.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN radio11.
      CLEAR ld_sort.
      ld_sort-fieldname = 'VKORG'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'VKBUR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN OTHERS.
      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'ZUONR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'BELNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
  ENDCASE.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
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
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  CASE 'X'.
    WHEN radio7.
      SET PF-STATUS 'TODELETE'.
    WHEN radio9.
      SET PF-STATUS 'STANDARD'.
    WHEN radio10.
      SET PF-STATUS 'STANDARD'.
    WHEN radio11.
      SET PF-STATUS 'STANDARD'.
    WHEN OTHERS.
      SET PF-STATUS 'TOEXECUTE'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
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
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  DATA : ls_likp  LIKE LINE OF gt_likp.

  IF pa_check IS INITIAL.
    LOOP AT lineitems.
      IF lineitems-alloc_nmbr IN so_zuonr.
        gt_vdata-bukrs  = lineitems-comp_code.
        gt_vdata-kunnr  = lineitems-customer.
        READ TABLE gt_kna1 WITH KEY kunnr = gt_vdata-kunnr.
        IF sy-subrc EQ 0.
          gt_vdata-name1  = gt_kna1-name1.
        ENDIF.
        gt_vdata-zuonr  = lineitems-alloc_nmbr.

        CLEAR ls_likp.
        READ TABLE gt_likp INTO ls_likp WITH KEY vbeln = lineitems-alloc_nmbr.
        IF sy-subrc = 0.
          gt_vdata-verur  = ls_likp-verur.
        ENDIF.

        gt_vdata-gjahr  = lineitems-fisc_year.
        gt_vdata-belnr  = lineitems-doc_no.
        gt_vdata-buzei  = lineitems-item_num.
        gt_vdata-budat  = lineitems-pstng_date.
        gt_vdata-bldat  = lineitems-doc_date.
        gt_vdata-waers  = lineitems-loc_currcy.
        gt_vdata-xblnr  = lineitems-ref_doc_no.
        gt_vdata-blart  = lineitems-doc_type.
        gt_vdata-gsber  = lineitems-bus_area.
        gt_vdata-shkzg  = lineitems-db_cr_ind.
        PERFORM f_amount_modify USING lineitems-loc_currcy lineitems-lc_amount
                                      lineitems-db_cr_ind
                                CHANGING gt_vdata-dmbtr.
        PERFORM f_amount_modify USING lineitems-currency lineitems-amt_doccur
                                      lineitems-db_cr_ind
                                CHANGING gt_vdata-wrbtr.
        APPEND gt_vdata.
      ENDIF.
    ENDLOOP.

    IF gt_vdata[] IS NOT INITIAL.
      CASE 'X'.
        WHEN radio1.
          SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
            bldat budat xblnr blart gsber vkbur shkzg waers dmbtr
            zflag1 zflag2 zflag3
            FROM zfkwi
            INTO TABLE gt_zfkwi
            FOR ALL ENTRIES IN gt_vdata
            WHERE ztran EQ co_kw1         AND
                  bukrs EQ gt_vdata-bukrs AND
                  kunnr EQ gt_vdata-kunnr AND
                  gjahr EQ gt_vdata-gjahr AND
                  belnr EQ gt_vdata-belnr AND
                  buzei EQ gt_vdata-buzei.
        WHEN radio2.
          SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
            bldat budat xblnr blart gsber vkbur shkzg waers dmbtr
            zflag1 zflag2 zflag3
            FROM zfkwi
            INTO TABLE gt_zfkwi
            FOR ALL ENTRIES IN gt_vdata
            WHERE ztran EQ co_kw2         AND
                  bukrs EQ gt_vdata-bukrs AND
                  kunnr EQ gt_vdata-kunnr AND
                  gjahr EQ gt_vdata-gjahr AND
                  belnr EQ gt_vdata-belnr AND
                  buzei EQ gt_vdata-buzei.
        WHEN radio3.
          SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
            bldat budat xblnr blart gsber vkbur shkzg waers dmbtr
            zflag1 zflag2 zflag3
            FROM zfkwi
            INTO TABLE gt_zfkwi
            FOR ALL ENTRIES IN gt_vdata
            WHERE ztran EQ co_ttf         AND
                  bukrs EQ gt_vdata-bukrs AND
                  kunnr EQ gt_vdata-kunnr AND
                  gjahr EQ gt_vdata-gjahr AND
                  belnr EQ gt_vdata-belnr AND
                  buzei EQ gt_vdata-buzei.
      ENDCASE.
    ENDIF.

    SORT gt_vdata BY bukrs kunnr gjahr belnr buzei.
    SORT gt_zfkwi BY bukrs kunnr gjahr belnr buzei.
    LOOP AT gt_vdata.
      CASE 'X'.
        WHEN radio1.
          READ TABLE gt_zfkwi WITH KEY bukrs  = gt_vdata-bukrs
                                       kunnr  = gt_vdata-kunnr
                                       gjahr  = gt_vdata-gjahr
                                       belnr  = gt_vdata-belnr
                                       buzei  = gt_vdata-buzei
                                       zflag1 = space
                                       zflag2 = 'X'
                              BINARY SEARCH.
          IF sy-subrc EQ 0.
            DELETE gt_vdata.
          ENDIF.
        WHEN radio2.
          READ TABLE gt_zfkwi WITH KEY bukrs  = gt_vdata-bukrs
                                       kunnr  = gt_vdata-kunnr
                                       gjahr  = gt_vdata-gjahr
                                       belnr  = gt_vdata-belnr
                                       buzei  = gt_vdata-buzei
                                       zflag1 = 'X'
                                       zflag2 = space
                              BINARY SEARCH.
          IF sy-subrc EQ 0.
            DELETE gt_vdata.
          ENDIF.
        WHEN radio3.
          READ TABLE gt_zfkwi WITH KEY bukrs  = gt_vdata-bukrs
                                       kunnr  = gt_vdata-kunnr
                                       gjahr  = gt_vdata-gjahr
                                       belnr  = gt_vdata-belnr
                                       buzei  = gt_vdata-buzei
                                       zflag3 = 'X'
                              BINARY SEARCH.
          IF sy-subrc EQ 0.
            DELETE gt_vdata.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ELSE.
    LOOP AT gt_zfkwi.
      gt_vdata-bukrs  = gt_zfkwi-bukrs.
      gt_vdata-kunnr  = gt_zfkwi-kunnr.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_zfkwi-kunnr.
      IF sy-subrc EQ 0.
        gt_vdata-name1  = gt_kna1-name1.
      ENDIF.
      gt_vdata-zuonr  = gt_zfkwi-zuonr.

      CLEAR ls_likp.
      READ TABLE gt_likp INTO ls_likp WITH KEY vbeln = gt_zfkwi-zuonr.
      IF sy-subrc = 0.
        gt_vdata-verur  = ls_likp-verur.
      ENDIF.

      gt_vdata-gjahr  = gt_zfkwi-gjahr.
      gt_vdata-belnr  = gt_zfkwi-belnr.
      gt_vdata-buzei  = gt_zfkwi-buzei.
      gt_vdata-nokwi  = gt_zfkwi-nokwi.
      gt_vdata-nottf  = gt_zfkwi-nottf.
      gt_vdata-budat  = gt_zfkwi-budat.
      gt_vdata-bldat  = gt_zfkwi-bldat.
      gt_vdata-waers  = gt_zfkwi-waers.
      gt_vdata-xblnr  = gt_zfkwi-xblnr.
      gt_vdata-blart  = gt_zfkwi-blart.
      gt_vdata-gsber  = gt_zfkwi-gsber.
      gt_vdata-shkzg  = gt_zfkwi-shkzg.
      IF gt_zfkwi-shkzg EQ 'H'.
        gt_vdata-dmbtr  = gt_zfkwi-dmbtr * -1.
      ELSE.
        gt_vdata-dmbtr  = gt_zfkwi-dmbtr.
      ENDIF.
      APPEND gt_vdata.
    ENDLOOP.

    LOOP AT gt_vdata.
      gt_reprint-bukrs  = gt_vdata-bukrs.
      gt_reprint-kunnr  = gt_vdata-kunnr.
      gt_reprint-name1  = gt_vdata-name1.
      gt_reprint-gjahr  = gt_vdata-gjahr.
      gt_reprint-nokwi  = gt_vdata-nokwi.
      gt_reprint-nottf  = gt_vdata-nottf.
      gt_reprint-gsber  = gt_vdata-gsber.
      gt_reprint-waers  = gt_vdata-waers.
      IF gt_vdata-shkzg EQ 'H'.
        gt_reprint-dmbtr  = gt_vdata-dmbtr * -1.
      ELSE.
        gt_reprint-dmbtr  = gt_vdata-dmbtr.
      ENDIF.
      COLLECT gt_reprint.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread LIKE dynpread OCCURS 0 WITH HEADER LINE,
        wa_header   LIKE zfstkwi,
        lv_subrc    TYPE sy-subrc,
        lv_nomor    TYPE znonumc_10,
        lv_lines    TYPE i,
        lv_gjahr    TYPE gjahr,
        lv_gsber    TYPE gsber,
        lv_ztran    TYPE ztran.

  DATA: lt_copy   LIKE zfkwi OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  IF radio7 EQ 'X'.
    IF fu_ucomm EQ '&DEL'.
      PERFORM f_copy_data TABLES lt_copy.
      MESSAGE s000(zab) WITH 'Data already deleted'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    IF fu_ucomm EQ '&LOG'.
      SET TITLEBAR 'LOG'.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.
    ELSE.
      CLEAR: gt_header, gt_header[], gt_detail, gt_detail[].

      PERFORM f_validate_data CHANGING lv_lines lv_gjahr lv_gsber.

      IF gt_error[] IS INITIAL.
        IF lv_lines EQ 1.

          IF pa_check IS INITIAL.
            PERFORM f_lock_table USING lv_gjahr lv_gsber
                                 CHANGING lv_nomor lv_ztran.
          ENDIF.

          PERFORM f_post_entries USING fu_ucomm lv_nomor lv_gsber
                                 CHANGING wa_header
                                          lv_subrc.

          IF lv_subrc EQ 0.
            wa_header-bukrs   = pa_bukrs.
            IF pa_bukrs = '8020' OR pa_bukrs = '8070'.
              wa_header-kunnr   = gt_vdata-kunnr.
            ENDIF.
            PERFORM f_print_form USING wa_header gv_fname fu_ucomm
                                 CHANGING lv_subrc.

            IF sy-subrc IS INITIAL.
              IF fu_ucomm EQ '&POS'.
                IF pa_check IS INITIAL.
                  PERFORM f_save_data USING lv_nomor lv_ztran lv_gjahr lv_gsber.
                ENDIF.
                MESSAGE s000(zab) WITH 'Data already processed'.
                LEAVE TO SCREEN 0.
              ENDIF.
            ENDIF.
          ELSE.
            MESSAGE s000(zab) WITH 'There is no data to be processed'.
          ENDIF.
        ELSE.
          IF lv_lines EQ 99.
          ELSE.
            MESSAGE s000(zab) WITH 'There is any different in your data'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE s000(zab) WITH 'Customer belum diotorisasi FIN HO'.
      ENDIF.

      PERFORM f_unlock_table USING lv_gjahr lv_gsber.

      SORT gt_vdata BY kunnr zuonr belnr.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries USING fu_ucomm fu_nomor fu_gsber
                    CHANGING fwa_header STRUCTURE zfstkwi
                             fc_subrc.
  DATA: lv_name          TYPE tdobname,
        lv_dmbtr         TYPE dmbtr,
        lv_nou           TYPE buzei,
        lv_nokwi         TYPE znomor4,
        lv_nottf         TYPE znomor5,
        lv_fakturno(255),
        wa_vdata         LIKE gt_vdata,
        in_words         LIKE spell OCCURS 0 WITH HEADER LINE.

  SORT gt_vdata BY kunnr zuonr.
  LOOP AT gt_vdata INTO wa_vdata WHERE check EQ 'X'.
    PERFORM f_get_header  USING wa_vdata fu_nomor fu_gsber
                          CHANGING lv_nokwi lv_nottf.

    ADD 1 TO lv_nou.
    wa_vdata-nou  = lv_nou.
    PERFORM f_get_detail  USING wa_vdata fu_nomor fu_ucomm
                                lv_nokwi lv_nottf.

    IF lv_nou EQ 1.
      lv_fakturno = wa_vdata-zuonr.
      SHIFT lv_fakturno LEFT DELETING LEADING space.
    ELSEIF lv_nou LE 19.
      CONCATENATE lv_fakturno ',' wa_vdata-zuonr INTO lv_fakturno
      SEPARATED BY space.
    ENDIF.
  ENDLOOP.

  IF sy-subrc EQ 0.
    LOOP AT gt_header INTO fwa_header.
      READ TABLE gt_tvbur WITH KEY vkbur = pa_vkbur.
      IF sy-subrc EQ 0.
        fwa_header-name1_busa = gt_tvbur-name1.
        fwa_header-stras_busa = gt_tvbur-street.
        fwa_header-ort01_busa = gt_tvbur-city1.
        fwa_header-pstlz_busa = gt_tvbur-post_code1.
      ENDIF.

      READ TABLE gt_kna1 WITH KEY kunnr = fwa_header-kunnr.
      IF sy-subrc EQ 0.
        fwa_header-name1_cust  = gt_kna1-name1.
        fwa_header-name2_cust  = gt_kna1-name2.
        fwa_header-ort01_cust  = gt_kna1-ort01.
        fwa_header-pstlz_cust  = gt_kna1-pstlz.
      ENDIF.

      lv_dmbtr  = abs( fwa_header-dmbtr ).

      CALL FUNCTION 'SPELL_AMOUNT'
        EXPORTING
          amount   = lv_dmbtr
          currency = 'IDR'
          language = 'i'
        IMPORTING
          in_words = in_words.

      WRITE lv_dmbtr TO fwa_header-amount CURRENCY fwa_header-waers.
      IF fwa_header-dmbtr LT 0.
        SHIFT fwa_header-amount LEFT DELETING LEADING space.
        CONCATENATE '(' fwa_header-amount ')' INTO fwa_header-amount
        SEPARATED BY space.
      ENDIF.
      CONCATENATE in_words-word 'RUPIAH' INTO fwa_header-amountt SEPARATED BY space.
      TRANSLATE fwa_header-amountt TO LOWER CASE.

      CONCATENATE 'KWI' pa_vkbur 'PD' INTO fwa_header-graph.
      SELECT SINGLE tdname
        FROM stxbitmaps
        INTO lv_name
        WHERE tdobject  EQ 'GRAPHICS'
          AND tdname    EQ fwa_header-graph
          AND tdid      EQ 'BMAP'
          AND tdbtype   EQ 'BMON'.
      IF sy-subrc NE 0.
        CLEAR fwa_header-graph.
      ENDIF.

      fwa_header-fakturno = lv_fakturno.
      IF radio3 EQ 'X'.
        IF pa_ttfdt IS INITIAL.
          fwa_header-zdate  = '....../....../............'.
        ELSE.
          CONCATENATE pa_ttfdt+6(2) pa_ttfdt+4(2) pa_ttfdt(4) INTO fwa_header-zdate
          SEPARATED BY '/'.
        ENDIF.
      ELSE.
        CONCATENATE pa_gstid+6(2) pa_gstid+4(2) pa_gstid(4) INTO fwa_header-zdate
        SEPARATED BY '/'.
      ENDIF.
      MODIFY gt_header FROM fwa_header.
    ENDLOOP.
  ELSE.
    fc_subrc  = sy-subrc.
  ENDIF.
ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
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
*&      Form  F_AMOUNT_MODIFY
*&---------------------------------------------------------------------*
FORM f_amount_modify  USING    fu_waers fu_amount fu_shkzg
                      CHANGING fc_amount.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      currency             = fu_waers
      amount_external      = fu_amount
      max_number_of_digits = 13
    IMPORTING
      amount_internal      = fc_amount
      return               = return.

  IF fu_shkzg EQ 'H'.
    fc_amount = fc_amount * -1.
  ENDIF.
ENDFORM.                    " F_AMOUNT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER
*&---------------------------------------------------------------------*
FORM f_get_header  USING    fwa_vdata STRUCTURE gt_vdata
                            fu_nomor fu_gsber
                   CHANGING fc_nokwi fc_nottf.

  gt_header-bukrs     = pa_bukrs.
  gt_header-city1     = gv_city1.
  IF gv_petugas IS INITIAL.
    gt_header-petugas1  = gv_petugas1.
  ELSE.
    gt_header-petugas1  = gv_petugas.
  ENDIF.
  gt_header-jabat1    = gv_jabat1.

  IF pa_bukrs = '8380'.
    gt_header-kunnr   = fwa_vdata-kunnr.
  ENDIF.
*  READ TABLE gt_kna1 WITH KEY kunnr = fwa_vdata-kunnr.
*  IF sy-subrc EQ 0.
*    gt_header-name1_cust     = gt_kna1-name1.
*    gt_header-name2_cust     = gt_kna1-name2.
*    gt_header-ort01_cust     = gt_kna1-ort01.
*    gt_header-pstlz_cust     = gt_kna1-pstlz.
*    gt_header-name_co_cust   = gt_kna1-name_co.
*  ELSE.
*    SELECT SINGLE a~name1 b~name2 ort01 pstlz name_co
*      FROM kna1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
*      INTO (gt_header-name1_cust, gt_header-name2_cust, gt_header-ort01_cust,
*            gt_header-pstlz_cust, gt_header-name_co_cust)
*      WHERE kunnr EQ fwa_vdata-kunnr.
*  ENDIF.

  gt_header-name_cust = gv_name.

  IF pa_check IS INITIAL.
    CASE 'X'.
      WHEN radio3.
        CONCATENATE fu_gsber '/' pa_gstid(4) '/' pa_gstid+4(2) '/' fu_nomor INTO gt_header-nottf.
        CLEAR gt_header-nokwi.
      WHEN OTHERS.
        CONCATENATE fu_gsber '/' pa_gstid(4) '/' pa_gstid+4(2) '/' fu_nomor INTO gt_header-nokwi.
        CLEAR gt_header-nottf.
    ENDCASE.
  ELSE.
    gt_header-reprint = 'X'.
    CASE 'X'.
      WHEN radio3.
        gt_header-nottf = fwa_vdata-nottf.
        CLEAR gt_header-nokwi.
      WHEN OTHERS.
        gt_header-nokwi = fwa_vdata-nokwi.
        CLEAR gt_header-nottf.
    ENDCASE.
  ENDIF.

  fc_nokwi  = gt_header-nokwi.
  fc_nottf  = gt_header-nottf.

  gt_header-waers   = fwa_vdata-waers.
  gt_header-dmbtr   = fwa_vdata-dmbtr.
  gt_header-ttfdt   = pa_ttfdt.
  COLLECT gt_header.
  CLEAR gt_header.
ENDFORM.                    " F_GET_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form  USING    fwa_header  STRUCTURE zfstkwi
                            fu_fname fu_ucomm
                   CHANGING fc_subrc.
  DATA: lv_funcname        TYPE tdsfname,
        lwa_output_option  TYPE ssfcompop,
        lwa_control_option TYPE ssfctrlop,
        lv_subrc           TYPE sy-subrc.

* Determine Smartform function module name
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fu_fname
    IMPORTING
      fm_name            = lv_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF pa_check IS INITIAL.
    PERFORM f_barcode CHANGING fwa_header.
    PERFORM f_print_single_form USING lv_funcname fu_ucomm
                                      fwa_header
                                CHANGING fc_subrc.
  ELSE.
    PERFORM f_print_multi_form USING lv_funcname fu_ucomm
                                 fwa_header
                           CHANGING fc_subrc.
  ENDIF.

ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_detail  USING    fwa_vdata STRUCTURE gt_vdata
                            fu_nomor fu_ucomm fu_nokwi fu_nottf.
  DATA: lv_dmbtr  TYPE dmbtr.

  gt_detail-nou     = fwa_vdata-nou.
  SHIFT gt_detail-nou LEFT DELETING LEADING '0'.
  IF pa_bukrs = '8380' AND
    fwa_vdata-verur IS NOT INITIAL.
    CONCATENATE fwa_vdata-zuonr '/' INTO gt_detail-zuonr
    SEPARATED BY space.
  ELSE.
    gt_detail-zuonr   = fwa_vdata-zuonr.
  ENDIF.
  gt_detail-verur   = fwa_vdata-verur.
  gt_detail-bldat   = fwa_vdata-bldat.
  gt_detail-budat   = fwa_vdata-budat.
  lv_dmbtr          = abs( fwa_vdata-dmbtr ).
  WRITE lv_dmbtr TO gt_detail-dmbtrt CURRENCY fwa_vdata-waers.
  IF fwa_vdata-dmbtr LT 0.
    SHIFT gt_detail-dmbtrt LEFT DELETING LEADING space.
    CONCATENATE '(' gt_detail-dmbtrt ')' INTO gt_detail-dmbtrt
    SEPARATED BY space.
  ENDIF.

  gt_detail-nokwi = fwa_vdata-nokwi.
  gt_detail-nottf = fwa_vdata-nottf.
  APPEND gt_detail.

  CASE 'X'.
    WHEN radio1.
      gt_save-ztran = co_kw1.
      gt_save-nokwi = fu_nokwi.
      CLEAR gt_save-nottf.
    WHEN radio2.
      gt_save-ztran = co_kw2.
      gt_save-nokwi = fu_nokwi.
      CLEAR gt_save-nottf.
    WHEN radio3.
      gt_save-ztran = co_ttf.
      gt_save-nottf = fu_nottf.
      CLEAR gt_save-nokwi.
  ENDCASE.

* Preparing saving data
  IF fu_ucomm EQ '&POS'.
    gt_save-bukrs   = pa_bukrs.
    gt_save-vkbur   = pa_vkbur.
    gt_save-kunnr   = fwa_vdata-kunnr.
    gt_save-zuonr   = fwa_vdata-zuonr.
    gt_save-gjahr   = fwa_vdata-gjahr.
    gt_save-belnr   = fwa_vdata-belnr.
    gt_save-buzei   = fwa_vdata-buzei.
    gt_save-bldat   = fwa_vdata-bldat.
    gt_save-budat   = fwa_vdata-budat.
    gt_save-xblnr   = fwa_vdata-xblnr.
    gt_save-blart   = fwa_vdata-blart.
    gt_save-gsber   = fwa_vdata-gsber.
    gt_save-shkzg   = fwa_vdata-shkzg.
    gt_save-waers   = fwa_vdata-waers.
    gt_save-dmbtr   = abs( fwa_vdata-dmbtr ).
    CASE 'X'.
      WHEN radio1.
        gt_save-zflag2  = 'X'.
      WHEN radio2.
        gt_save-zflag1  = 'X'.
      WHEN radio3.
        gt_save-zflag3  = 'X'.
    ENDCASE.

    gt_save-zupld   = sy-datum.
    gt_save-zuplt   = sy-uzeit.
    gt_save-zuplu   = sy-uname.
    gt_save-zttfdt  = pa_ttfdt.
    APPEND gt_save.
  ENDIF.
ENDFORM.                    " F_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  DATA: lv_usrgrp    TYPE xuclass.

  SELECT SINGLE usergroup
    FROM usgrp_user
    INTO lv_usrgrp
    WHERE bname     EQ sy-uname
      AND usergroup IN ('BOM', 'BOS', 'FINHO').
  IF sy-subrc NE 0.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'BOM'.
          screen-active  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'MSG' OR 'ZTR' OR 'BLD' OR 'TTF' OR 'SVK'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio2.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'ZTR' OR 'BLD' OR 'TTF' OR 'SVK'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio3.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'SIG' OR 'MSG' OR 'ZTR' OR 'BLD' OR 'SVK'.
            screen-active  = 0.
        ENDCASE.
        IF pa_bukrs <> '8380'.
          IF screen-group1 = 'TTF'.
            screen-active  = 0.
          ENDIF.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio7.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'MSG' OR 'CHK' OR 'ZUO' OR 'GST' OR
             'ZTR' OR 'BLD' OR 'TTF' OR 'SVK'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio8.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'MSG' OR 'CHK' OR 'ZUO' OR 'GST' OR 'SVK' OR
            'NOT' OR 'NOK' OR 'KUN' OR 'ZTR' OR 'BLD' OR
            'TTF'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio9.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'MSG' OR 'CHK' OR 'GST' OR
            'NOT' OR 'NOK' OR 'ZUO' OR 'TTF' OR 'SVK'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio10.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'MSG' OR 'CHK' OR 'ZUO' OR 'GST' OR
            'NOT' OR 'NOK' OR 'ZTR' OR 'BLD' OR 'TTF' OR 'SVK'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio11.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'MSG' OR 'CHK' OR 'ZUO' OR 'GST' OR 'VKB' OR
            'NOT' OR 'NOK' OR 'ZTR' OR 'BLD' OR 'TTF'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: lt_tvkbt TYPE TABLE OF tvkbt WITH HEADER LINE.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF radio9 IS NOT INITIAL.
    IF pa_ztran IS INITIAL.
      PERFORM f_screen_validate USING 'ZTR' lv_mess.
    ENDIF.
  ENDIF.

  IF pa_bukrs IS INITIAL.
    PERFORM f_screen_validate USING 'BUK' lv_mess.
  ENDIF.

  IF radio11 IS INITIAL.
    IF pa_vkbur IS INITIAL.
      PERFORM f_screen_validate USING 'VKB' lv_mess.
    ELSE.
      AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
               ID 'VKBUR' FIELD pa_vkbur
               ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        CONCATENATE 'You are not authorized for Sales Office' pa_vkbur INTO lv_mess
        SEPARATED BY space.
        PERFORM f_screen_validate USING 'VKB' lv_mess.
      ENDIF.
    ENDIF.
  ELSE.
    IF so_vkbur[] IS INITIAL.
      PERFORM f_screen_validate USING 'SVK' lv_mess.
    ELSE.
      SELECT * INTO TABLE lt_tvkbt
        FROM tvkbt WHERE spras EQ sy-langu
                     AND vkbur IN so_vkbur.
      LOOP AT lt_tvkbt.
        AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
                 ID 'VKBUR' FIELD lt_tvkbt-vkbur
                 ID 'ACTVT' FIELD '01'.
        IF sy-subrc NE 0.
          CONCATENATE 'You are not authorized for Sales Office' lt_tvkbt-vkbur INTO lv_mess
          SEPARATED BY space.
          PERFORM f_screen_validate USING 'VKB' lv_mess.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF radio8 IS INITIAL AND
    radio9 IS INITIAL AND
    radio10 IS INITIAL AND
    radio11 IS INITIAL.
    IF so_kunnr[] IS INITIAL.
      PERFORM f_screen_validate USING 'KUN' lv_mess.
    ENDIF.
  ENDIF.

  IF pa_check IS NOT INITIAL.
    CASE 'X'.
      WHEN radio3.
        IF so_nottf[] IS INITIAL.
          PERFORM f_screen_validate USING 'NOT' lv_mess.
        ENDIF.
      WHEN OTHERS.
        IF so_nokwi[] IS INITIAL.
          PERFORM f_screen_validate USING 'NOK' lv_mess.
        ENDIF.
    ENDCASE.
  ELSE.
    IF radio7 EQ 'X'.
      IF so_nokwi[] IS INITIAL AND
        so_nottf[] IS INITIAL.
        PERFORM f_screen_validate USING 'NOK' lv_mess.
      ELSEIF so_nokwi[] IS NOT INITIAL AND
        so_nottf[] IS NOT INITIAL.
        PERFORM f_screen_validate USING 'NOK' ''.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_VALIDATE
*&---------------------------------------------------------------------*
FORM f_screen_validate  USING    fu_group fu_mess.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH fu_mess.
ENDFORM.                    " F_SCREEN_VALIDATE

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table USING fu_gjahr fu_gsber
                  CHANGING fc_nomor fc_ztran.
  DATA: lv_mess(100).

  CASE 'X'.
    WHEN radio1.
      fc_ztran  = co_kw1.
    WHEN radio2.
      fc_ztran  = co_kw1.
    WHEN radio3.
      fc_ztran  = co_ttf.
  ENDCASE.

  SELECT SINGLE nomor
    FROM zfkwino
    INTO fc_nomor
    WHERE ztran EQ fc_ztran AND
          vkbur EQ pa_vkbur AND
          gjahr EQ fu_gjahr.

  IF fc_nomor IS NOT INITIAL.
    CALL FUNCTION 'ENQUEUE_EZFKWINO'
      EXPORTING
        ztran          = fc_ztran
        vkbur          = pa_vkbur
        gjahr          = fu_gjahr
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.
      CONCATENATE 'Table Lock by' sy-msgv1 INTO lv_mess
      SEPARATED BY space.
      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
        EXPORTING
          popup_title  = 'Error table locking'
          message_text = lv_mess.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
      EXPORTING
        popup_title  = 'Error message'
        message_text = 'Kwitansi/TTF Numbers have not been maintained'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table USING fu_gjahr fu_gsber.
  DATA: lv_ztran  TYPE ztran.

  CASE 'X'.
    WHEN radio1.
      lv_ztran  = co_kw1.
    WHEN radio2.
      lv_ztran  = co_kw1.
    WHEN radio3.
      lv_ztran  = co_ttf.
  ENDCASE.

  CALL FUNCTION 'DEQUEUE_EZFKWINO'
    EXPORTING
      ztran = lv_ztran
      vkbur = pa_vkbur
      gjahr = fu_gjahr.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data USING fu_nomor fu_ztran fu_gjahr fu_gsber.
  DATA: lv_lastno   TYPE znonumc_10.

  INSERT zfkwi FROM TABLE gt_save.

  lv_lastno = fu_nomor + 1.
  UPDATE zfkwino SET nomor  = lv_lastno
  WHERE ztran EQ fu_ztran
    AND vkbur EQ pa_vkbur
    AND gjahr EQ fu_gjahr.

  CHECK gt_zfkwiout IS NOT INITIAL.

  LOOP AT gt_zfkwiout.
    READ TABLE gt_error WITH KEY kunnr = gt_zfkwiout-kunnr.
    IF sy-subrc NE 0.
      UPDATE zfkwiout SET zhit = 'X'
      WHERE bukrs EQ pa_bukrs
        AND vkbur EQ pa_vkbur
        AND kunnr EQ gt_zfkwiout-kunnr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data CHANGING fc_lines fc_gjahr fc_vkbur.
  DATA: lt_vdata LIKE gt_vdata OCCURS 0 WITH HEADER LINE,
        lv_flag  TYPE sy-subrc,
        lv_kunnr TYPE kunnr.

  IF pa_check IS NOT INITIAL.
    LOOP AT gt_reprint.
      IF gt_reprint-check IS INITIAL.
        CLEAR gt_vdata-check.
      ELSE.
        gt_vdata-check = 'X'.
      ENDIF.
      CASE 'X'.
        WHEN radio3.
          MODIFY gt_vdata TRANSPORTING check
                          WHERE nottf EQ gt_reprint-nottf AND
                                gjahr EQ gt_reprint-gjahr.
        WHEN OTHERS.
          MODIFY gt_vdata TRANSPORTING check
                          WHERE nokwi EQ gt_reprint-nokwi AND
                                gjahr EQ gt_reprint-gjahr.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  SORT gt_vdata BY gjahr.
  LOOP AT gt_vdata WHERE check EQ 'X'.
    lt_vdata-gsber  = gt_vdata-gsber.
    IF lv_flag IS INITIAL.
      lv_flag = 1.
      lv_kunnr  = gt_vdata-kunnr.
    ENDIF.
    COLLECT lt_vdata.

    IF radio3 IS NOT INITIAL.
      READ TABLE gt_zfkwiout WITH KEY vkbur = pa_vkbur
                                      kunnr = gt_vdata-kunnr.
      IF sy-subrc EQ 0.
        IF gt_zfkwiout-zsts IS INITIAL.
          IF gt_zfkwiout-zhit IS INITIAL.
            CONTINUE.
          ELSE.
            gt_error-kunnr  = gt_vdata-kunnr.
            gt_error-msg    = 'Customer belum di otorisasi FIN HO'.
            APPEND gt_error.
          ENDIF.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CHECK gt_error[] IS INITIAL.

  DESCRIBE TABLE lt_vdata LINES fc_lines.
  IF fc_lines EQ 1.
    READ TABLE lt_vdata INDEX 1.
    IF sy-subrc EQ 0.
      fc_vkbur  = pa_vkbur.
    ENDIF.
  ENDIF.

  CLEAR: pa_namec, pa_name3.

  READ TABLE gt_kna1 WITH KEY kunnr = lv_kunnr.
  IF sy-subrc EQ 0.
    pa_name1  = gt_kna1-name1.
    pa_name2  = gt_kna1-name_co.
    pa_name3  = gv_petugas1.

    CALL SELECTION-SCREEN 1100 STARTING AT 10 5.
    IF sy-subrc EQ 0.
      CASE 'X'.
        WHEN radio4.
          gv_name     = pa_name1.
          gv_petugas  = pa_name3.
        WHEN radio5.
          gv_name     = pa_name2.
          gv_petugas  = pa_name3.
        WHEN radio6.
          gv_name     = pa_namec.
          gv_petugas  = pa_name3.
      ENDCASE.
    ELSE.
      fc_lines  = 99.
    ENDIF.
  ENDIF.

  fc_gjahr  = pa_gstid(4).
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_SINGLE_FORM
*&---------------------------------------------------------------------*
FORM f_print_single_form  USING    fu_funcname fu_ucomm
                                   fwa_header STRUCTURE zfstkwi
                          CHANGING fc_subrc.

  DATA: lwa_output_option  TYPE ssfcompop,
        lwa_control_option TYPE ssfctrlop.

  CASE fu_ucomm.
    WHEN '&PREV'.
      lwa_output_option-tdnoprint = 'X'.
    WHEN '&POS'.
      lwa_output_option-tdnoprev = 'X'.
  ENDCASE.

  lwa_output_option-tdnewid = 'X'.

  CALL FUNCTION fu_funcname
    EXPORTING
      output_options     = lwa_output_option
      control_parameters = lwa_control_option
      user_settings      = 'X'
      wa_header          = fwa_header
    TABLES
      gt_detail          = gt_detail
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

  IF sy-subrc IS NOT INITIAL.
    LEAVE TO SCREEN 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_PRINT_SINGLE_FORM

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_MULTI_FORM
*&---------------------------------------------------------------------*
FORM f_print_multi_form  USING    fu_funcname fu_ucomm
                                  fwa_header STRUCTURE zfstkwi
                         CHANGING c_subrc.

  DATA: lwa_output_option  TYPE ssfcompop,
        lwa_control_option TYPE ssfctrlop,
        lt_detail          LIKE gt_detail OCCURS 0 WITH HEADER LINE.

  lt_detail[] = gt_detail[].
  CLEAR: gt_detail, gt_detail[].

  CASE fu_ucomm.
    WHEN '&PREV'.
      lwa_output_option-tdnoprint = 'X'.
    WHEN '&POS'.
      lwa_output_option-tdnoprev = 'X'.
  ENDCASE.

  LOOP AT gt_header INTO fwa_header.
    PERFORM f_barcode CHANGING fwa_header.

    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    CASE 'X'.
      WHEN radio3.
        LOOP AT lt_detail WHERE nottf EQ fwa_header-nottf.
          gt_detail = lt_detail.
          APPEND gt_detail.
        ENDLOOP.
      WHEN OTHERS.
        LOOP AT lt_detail WHERE nokwi EQ fwa_header-nokwi.
          gt_detail = lt_detail.
          APPEND gt_detail.
        ENDLOOP.
    ENDCASE.

    CALL FUNCTION fu_funcname
      EXPORTING
        output_options     = lwa_output_option
        control_parameters = lwa_control_option
        user_settings      = 'X'
        wa_header          = fwa_header
      TABLES
        gt_detail          = gt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    IF sy-subrc IS NOT INITIAL.
      LEAVE TO SCREEN 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    lwa_control_option-no_open = 'X'.
    CLEAR: gt_detail, gt_detail[].
  ENDLOOP.
ENDFORM.                    " F_PRINT_MULTI_FORM

*&---------------------------------------------------------------------*
*&      Form  F_GET_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_get_delete_data .
  SELECT a~kunnr a~name1 a~name2 ort01 pstlz name_co
    FROM kna1 AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
                   JOIN adrc AS c ON a~adrnr EQ c~addrnumber
    INTO TABLE gt_kna1
    WHERE a~kunnr IN so_kunnr AND
          b~vkbur EQ pa_vkbur.

  IF gt_kna1[] IS NOT INITIAL.
    IF so_nokwi[] IS NOT INITIAL.
      SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
        bldat budat xblnr blart gsber vkbur shkzg waers dmbtr zflag1
        zflag2 zflag3
        FROM zfkwi
        INTO CORRESPONDING FIELDS OF TABLE gt_delete
        FOR ALL ENTRIES IN gt_kna1
        WHERE bukrs EQ pa_bukrs
          AND kunnr EQ gt_kna1-kunnr
          AND nokwi IN so_nokwi
          AND ztran NE 'DEL'.
    ELSE.
      SELECT ztran bukrs kunnr zuonr nokwi nottf gjahr belnr buzei
        bldat budat xblnr blart gsber vkbur shkzg waers dmbtr zflag1
        zflag2 zflag3
        FROM zfkwi
        INTO CORRESPONDING FIELDS OF TABLE gt_delete
        FOR ALL ENTRIES IN gt_kna1
        WHERE bukrs EQ pa_bukrs
          AND kunnr EQ gt_kna1-kunnr
          AND nottf IN so_nottf
          AND ztran NE 'DEL'.
    ENDIF.
  ENDIF.

  SORT gt_delete BY kunnr.
  SORT gt_kna1 BY kunnr.
  LOOP AT gt_delete.
    READ TABLE gt_kna1 WITH KEY kunnr = gt_delete-kunnr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_delete-name1 = gt_kna1-name1.
      MODIFY gt_delete TRANSPORTING name1.
    ENDIF.
    CLEAR gt_delete.
  ENDLOOP.
ENDFORM.                    " F_GET_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_COPY_DATA
*&---------------------------------------------------------------------*
FORM f_copy_data  TABLES   ft_copy STRUCTURE zfkwi.
  LOOP AT gt_delete WHERE check EQ 'X'.
    MOVE-CORRESPONDING gt_delete TO ft_copy.
    APPEND ft_copy.
  ENDLOOP.

  DELETE zfkwi FROM TABLE ft_copy.

  LOOP AT ft_copy.
    ft_copy-ztran = 'DEL'.
    ft_copy-zupld = sy-datum.
    ft_copy-zuplt = sy-uzeit.
    ft_copy-zuplu = sy-uname.
    MODIFY ft_copy TRANSPORTING ztran zupld zuplt zuplu.
  ENDLOOP.

  INSERT zfkwi FROM TABLE ft_copy.
ENDFORM.                    " F_COPY_DATA

*&---------------------------------------------------------------------*
*&      Form f_dynpro
*&---------------------------------------------------------------------*
FORM f_dynpro USING dynbegin name value.
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                               " F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  F_CEK_LOCK
*&---------------------------------------------------------------------*
FORM f_cek_lock .
  DATA : lt_enq_read TYPE STANDARD TABLE OF seqg7,
         lt_enq_del  TYPE STANDARD TABLE OF seqg3,
         lw_enq_read TYPE seqg7,
         lw_enq_del  TYPE seqg3,
         lv_subrc    TYPE sy-subrc.

  CALL FUNCTION 'ENQUE_READ2'
    EXPORTING
      gclient = sy-mandt
      gname   = ' '
      guname  = '*'
    TABLES
      enq     = lt_enq_read.

  LOOP AT lt_enq_read INTO lw_enq_read
                      WHERE gname EQ 'RSTABLE'
                        AND garg CS 'ZFKWIOUT'.
    MOVE-CORRESPONDING lw_enq_read TO lw_enq_del.
    APPEND lw_enq_del TO lt_enq_del.
  ENDLOOP.

  CALL FUNCTION 'ENQUE_DELETE'
    EXPORTING
      check_upd_requests = 1
    IMPORTING
      subrc              = lv_subrc
    TABLES
      enq                = lt_enq_del.
ENDFORM.                    " F_CEK_LOCK

*&---------------------------------------------------------------------*
*&      Module  STATUS_0501  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0501 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0501  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0501 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " LIST_PROCESSING_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LIST
*&---------------------------------------------------------------------*
FORM f_error_list .
  DATA: ld_zebra  TYPE i.

  WRITE: / sy-uline.
  FORMAT COLOR 1.
  WRITE: / sy-vline, (10) 'Customer',
           sy-vline, (100) 'Message',
           sy-vline.
  WRITE: / sy-uline.
  FORMAT COLOR OFF.
  SORT gt_error BY kunnr.
  LOOP AT gt_error.
    IF ld_zebra IS INITIAL.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED ON.
      ld_zebra  = 1.
    ELSE.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      ld_zebra  = 0.
    ENDIF.
    WRITE: / sy-vline, gt_error-kunnr,
             sy-vline, gt_error-msg,
             sy-vline.
  ENDLOOP.
  WRITE: / sy-uline.
ENDFORM.                    " F_ERROR_LIST

*&---------------------------------------------------------------------*
*&      Form  F_LEAD_TIME
*&---------------------------------------------------------------------*
FORM f_lead_time .
  DATA : lv_lead  TYPE int4.

  LOOP AT gt_zfkwiout.
    CLEAR lv_lead.
    lv_lead  = gt_zfkwiout-zdatl - gt_zfkwiout-zdatc.
    IF lv_lead LT 0.
      CLEAR gt_zfkwiout-lead.
    ELSE.
      gt_zfkwiout-lead = lv_lead.
      SHIFT gt_zfkwiout-lead LEFT DELETING LEADING space.
    ENDIF.
    MODIFY gt_zfkwiout TRANSPORTING lead.
  ENDLOOP.
ENDFORM.                    " F_LEAD_TIME

*&---------------------------------------------------------------------*
*&      Form  F_GET_LIKP
*&---------------------------------------------------------------------*
FORM f_get_likp TABLES   ft_likp  STRUCTURE likp
                USING    fu_zuonr fu_flag.
  DATA : ls_likp  LIKE LINE OF ft_likp.

  CASE fu_flag.
    WHEN '1'.
      ls_likp-vbeln   = fu_zuonr.
      APPEND ls_likp TO ft_likp.
    WHEN '2'.
      SORT ft_likp BY vbeln.
      DELETE ADJACENT DUPLICATES FROM ft_likp COMPARING vbeln.
      IF ft_likp[] IS NOT INITIAL.
        SELECT *
          FROM likp
          INTO CORRESPONDING FIELDS OF TABLE gt_likp
          FOR ALL ENTRIES IN ft_likp
          WHERE vbeln = ft_likp-vbeln.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_LIKP

*&---------------------------------------------------------------------*
*&      Form  F_BARCODE
*&---------------------------------------------------------------------*
FORM f_barcode  CHANGING fwa_header STRUCTURE zfstkwi.
  DATA : lv_gsber(4),
         lv_gjahr(4),
         lv_monat(2),
         lv_nomor(10).

  SPLIT fwa_header-nottf AT '/' INTO lv_gsber lv_gjahr lv_monat lv_nomor.
  CONCATENATE lv_gsber lv_gjahr lv_monat lv_nomor INTO fwa_header-nottf_bc.

  IF pa_check IS NOT INITIAL.
    MODIFY gt_header FROM fwa_header TRANSPORTING nottf_bc.
  ENDIF.
ENDFORM.                    " F_BARCODE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_RADIO11
*&---------------------------------------------------------------------*
FORM f_get_data_radio11 .
  SELECT a~kunnr a~vkorg a~vtweg a~spart a~vkbur
         b~name1 b~aufsd b~ktokd b~erdat
    INTO CORRESPONDING FIELDS OF TABLE gt_nonttf
    FROM knvv AS a JOIN kna1 AS b ON a~kunnr = b~kunnr
    WHERE a~kunnr IN so_kunnr
      AND vkorg EQ pa_bukrs
      AND vkbur IN so_vkbur
      AND b~aufsd EQ space.

  IF gt_nonttf[] IS NOT INITIAL.
    CASE pa_bukrs.
      WHEN '8020'.
        DELETE gt_nonttf WHERE ktokd NE 'ZC04'.
      WHEN '8070'.
        DELETE gt_nonttf WHERE ktokd NE 'ZSU1'.
    ENDCASE.

    SELECT bukrs vkbur kunnr zsts status zhit zuserc zdatc zuserl zdatl
      INTO CORRESPONDING FIELDS OF TABLE gt_zfkwiout
      FROM zfkwiout FOR ALL ENTRIES IN gt_nonttf
      WHERE bukrs EQ pa_bukrs
        AND vkbur EQ gt_nonttf-vkbur
        AND kunnr EQ gt_nonttf-kunnr.

*    SELECT DISTINCT bukrs vkbur kunnr
*      INTO CORRESPONDING FIELDS OF TABLE gt_zfbid_nonttf
*      FROM zfbid FOR ALL ENTRIES IN gt_nonttf
*      WHERE bukrs EQ pa_bukrs
*        AND vkbur EQ gt_nonttf-vkbur
*        AND kunnr EQ gt_nonttf-kunnr
*        AND nottf NE space.

    SORT gt_nonttf BY vkorg vkbur kunnr.
    SORT gt_zfkwiout BY bukrs vkbur kunnr.
*    SORT gt_zfbid_nonttf BY bukrs vkbur kunnr.
    LOOP AT gt_nonttf.
      READ TABLE gt_zfkwiout WITH KEY bukrs = gt_nonttf-vkorg
                                      vkbur = gt_nonttf-vkbur
                                      kunnr = gt_nonttf-kunnr
                                      TRANSPORTING NO FIELDS
                                      BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE gt_nonttf.
        CONTINUE.
*      ELSE.
*        READ TABLE gt_zfbid_nonttf WITH KEY bukrs = gt_nonttf-vkorg
*                                            vkbur = gt_nonttf-vkbur
*                                            kunnr = gt_nonttf-kunnr
*                                            TRANSPORTING NO FIELDS
*                                            BINARY SEARCH.
*        IF sy-subrc NE 0.
*          DELETE gt_nonttf.
*        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_RADIO11
