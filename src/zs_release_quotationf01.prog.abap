*----------------------------------------------------------------------*
*   INCLUDE ZS_RELEASE_QUOTATIONF01                                    *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA : return     TYPE STANDARD TABLE OF bapiret2,
         groups     TYPE STANDARD TABLE OF bapigroups,
         ls_groups  LIKE LINE OF groups.

  CLEAR : gv_alkes, gv_tds.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  LOOP AT groups INTO ls_groups.
    IF ls_groups-usergroup(3) = 'TDS'.
      gv_tds = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  AUTHORITY-CHECK OBJECT 'ZRELALKES'
    ID 'ACTVT' FIELD '01'.
  IF sy-subrc = 0.
    gv_alkes  = 'X'.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZRELALKALL'
    ID 'ACTVT' FIELD '01'.
  IF sy-subrc = 0.
    gv_tds = 'X'.
  ENDIF.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: ld_error  TYPE i,
        ld_count  TYPE i.
  DATA: BEGIN OF lt_jest OCCURS 0.
          INCLUDE STRUCTURE jest.
  DATA: END OF lt_jest.
  DATA: BEGIN OF lt_vbuk OCCURS 0.
          INCLUDE STRUCTURE vbuk.
  DATA: END OF lt_vbuk.

  SELECT objnr
    FROM jest
    INTO CORRESPONDING FIELDS OF TABLE lt_jest
    WHERE
*          objnr LIKE 'VB%'  AND
          stat  EQ 'E0001'  AND
          inact EQ space.

  SORT lt_jest BY objnr.
  DELETE lt_jest WHERE objnr(2) <> 'VB'.
  LOOP AT lt_jest.
    t_jest-objnr  = lt_jest-objnr.
    t_jest-vbeln  = lt_jest-objnr+2(10).
    IF t_jest-vbeln IN so_vbeln.
      COLLECT t_jest.
    ENDIF.
  ENDLOOP.

  IF t_jest[] IS NOT INITIAL.
    SELECT vtweg spart vbeln vkbur kunnr netwr waerk knumv kvgr3 auart
      FROM vbak
      INTO CORRESPONDING FIELDS OF TABLE t_vbak
      FOR ALL ENTRIES IN t_jest
      WHERE vbeln EQ t_jest-vbeln  AND
            vkorg EQ pa_vkorg      AND
            vtweg IN so_vtweg      AND
            spart IN so_spart      AND
            vkbur IN so_vkbur      AND
            audat IN so_audat      AND
            auart IN so_auart.
  ENDIF.

  IF t_vbak[] IS NOT INITIAL.
    IF gv_tds IS INITIAL.
      SELECT vbeln posnr mvgr1
        FROM vbap
        INTO CORRESPONDING FIELDS OF TABLE t_vbap
        FOR ALL ENTRIES IN t_vbak
        WHERE vbeln = t_vbak-vbeln.
    ENDIF.

    SELECT vbeln abstk
      FROM vbuk
      INTO CORRESPONDING FIELDS OF TABLE lt_vbuk
      FOR ALL ENTRIES IN t_vbak
      WHERE vbeln EQ t_vbak-vbeln.

    SORT t_vbak BY vbeln.
    SORT lt_vbuk BY vbeln.
    LOOP AT t_vbak.
      IF t_vbak-vkbur IS NOT INITIAL.
        AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
                 ID 'ACTVT' FIELD '03'
                 ID 'VKORG' FIELD pa_vkorg
                 ID 'VTWEG' FIELD t_vbak-vtweg
                 ID 'SPART' FIELD t_vbak-spart
                 ID 'VKBUR' FIELD t_vbak-vkbur.
        IF sy-subrc EQ 4.
          va_error = 4.
          DELETE t_vbak.
        ELSEIF sy-subrc <> 0.
          va_error  = sy-subrc.
          DELETE t_vbak.
        ELSEIF sy-subrc EQ 0.
          READ TABLE lt_vbuk WITH KEY vbeln = t_vbak-vbeln
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF lt_vbuk-abstk EQ 'B' OR
              lt_vbuk-abstk EQ 'C'.
              DELETE t_vbak.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES t_out.
ENDFORM.                    "f_print_data

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

  PERFORM f_fieldcatg USING ft_report:
    'VBELN' 'VBAK' 'VBELN' '' '' '' '' 'X' '' '' '' '' '' '',
    'VKBUR' 'VBAK' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'VBAK' 'KUNNR' '' '' 'Account' '' '' '' '' '' '' '' '',
    'NAME1' 'ADRC' 'NAME1' '' '' 'Name' '' '' '' '' '' '' '' '',
    'KVGR3' 'VBAK' 'KVGR3' '' '' 'ScGrp' '' '' '' '' '' '' '' '',
    'AUART' 'VBAK' 'AUART' '' '' 'Type' '' '' '' '' '' '' '' '',
    'VALUE' '' '' '' '15' 'Value' '' '' '' '' '' 'WAERK' '' '',
    'ICON' '' '' '' '4' 'Sts.' '' 'X' '' '' '' '' '' '',
    'TEXT' '' '' '' '30' 'Keterangan' '' '' '' '' '' '' '' ''.
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
  fu_layout-box_fieldname      = 'CHECK'.
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

  CLEAR ld_sort.
  ld_sort-fieldname = 'VBELN'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
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
  REFRESH: t_out.
  CLEAR: t_out.
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
  IF t_out[] IS INITIAL.
    SET PF-STATUS 'STANDARD'.
  ELSE.
    SET PF-STATUS 'TOEXEC'.
  ENDIF.
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
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: BEGIN OF lt_adrc OCCURS 0,
          kunnr  LIKE kna1-kunnr,
          name1  LIKE adrc-name1.
  DATA: END OF lt_adrc.

  DATA: BEGIN OF lt_kunnr OCCURS 0.
          INCLUDE STRUCTURE vbak.
  DATA: END OF lt_kunnr.

  DATA: BEGIN OF lt_knumv OCCURS 0.
          INCLUDE STRUCTURE vbak.
  DATA: END OF lt_knumv.

  DATA: BEGIN OF lt_konv OCCURS 0,
          knumv  LIKE konv-knumv,
          kposn  LIKE konv-kposn,
          stunr  LIKE konv-stunr,
          zaehk  LIKE konv-zaehk,
          kwert  LIKE konv-kwert.
  DATA: END OF lt_konv.

  DATA: ld_kwert  LIKE konv-kwert.
  DATA: lt_knvk   TYPE TABLE OF knvk WITH HEADER LINE,
        ld_expdt  TYPE datum,
        ld_sysdt  TYPE datum,
        ld_expday TYPE int4.

  IF gv_tds IS INITIAL.
    LOOP AT t_vbap.
      IF gv_alkes IS NOT INITIAL.
        IF t_vbap-mvgr1 <> '04'.
          DELETE t_vbap.
        ENDIF.
      ELSE.
        IF t_vbap-mvgr1 = '04'.
          DELETE t_vbap.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF t_vbak[] IS NOT INITIAL.
    lt_knumv[] = lt_kunnr[] = t_vbak[].
    SORT lt_kunnr BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.
    SORT lt_knumv BY knumv.
    DELETE ADJACENT DUPLICATES FROM lt_knumv COMPARING knumv.

    IF lt_kunnr[] IS NOT INITIAL.
      SELECT a~kunnr b~name1
        FROM kna1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
        INTO CORRESPONDING FIELDS OF TABLE lt_adrc
        FOR ALL ENTRIES IN lt_kunnr
        WHERE a~kunnr EQ lt_kunnr-kunnr.

      SELECT parnr kunnr namev name1 abtnr
        INTO CORRESPONDING FIELDS OF TABLE lt_knvk
        FROM knvk FOR ALL ENTRIES IN lt_kunnr
        WHERE kunnr EQ lt_kunnr-kunnr
          AND abtnr IN ('A2','A3','A5').
    ENDIF.

    IF lt_knumv[] IS NOT INITIAL.
      SELECT knumv kposn stunr zaehk kwert
        FROM konv
        INTO CORRESPONDING FIELDS OF TABLE lt_konv
        FOR ALL ENTRIES IN lt_knumv
        WHERE knumv EQ lt_knumv-knumv AND
              kappl EQ 'V'            AND
              kschl EQ 'ZVAT'.
    ENDIF.
  ENDIF.

  SORT t_jest BY vbeln.
  SORT t_vbak BY vbeln.
  LOOP AT t_vbak.
    IF gv_tds IS INITIAL.
      READ TABLE t_vbap WITH KEY vbeln = t_vbak-vbeln.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
    ENDIF.
    READ TABLE t_jest WITH KEY vbeln = t_vbak-vbeln
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_out-objnr  = t_jest-objnr.
    ELSE.
      CLEAR: t_out-objnr.
    ENDIF.
    t_out-vtweg  = t_vbak-vtweg.
    t_out-spart  = t_vbak-spart.
    t_out-vbeln  = t_vbak-vbeln.
    t_out-vkbur  = t_vbak-vkbur.
    t_out-kunnr  = t_vbak-kunnr.
    READ TABLE lt_adrc WITH KEY kunnr = t_vbak-kunnr.
    IF sy-subrc EQ 0.
      t_out-name1  = lt_adrc-name1.
    ENDIF.
    t_out-waerk  = t_vbak-waerk.
    t_out-kvgr3  = t_vbak-kvgr3.
    t_out-auart  = t_vbak-auart.
    CLEAR: ld_kwert.
    LOOP AT lt_konv WHERE knumv EQ t_vbak-knumv.
      ADD lt_konv-kwert TO ld_kwert.
    ENDLOOP.
    t_out-value  = t_vbak-netwr + ld_kwert.

* Hitung license
    CLEAR: ld_expdt,ld_sysdt,ld_expday.
    ld_sysdt = sy-datum.
    LOOP AT lt_knvk WHERE kunnr = t_vbak-kunnr.
      IF lt_knvk-namev = space.
        lt_knvk-namev = '00.00.0000'.
        CONCATENATE lt_knvk-namev+6(4) lt_knvk-namev+3(2) lt_knvk-namev(2)
          INTO ld_expdt.
        ld_expday = 999999999 * -1.
      ELSE.
        CONCATENATE lt_knvk-namev+6(4) lt_knvk-namev+3(2) lt_knvk-namev(2)
          INTO ld_expdt.
        ld_expday = ld_expdt - ld_sysdt.
      ENDIF.
      IF ld_expday le 90.
        t_out-text = 'CEK CUST. LICENSE'.
        EXIT.
      ENDIF.
    ENDLOOP.

    APPEND t_out.
    CLEAR: t_out.
  ENDLOOP.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&PRC'.
      PERFORM f_post_entries.
      LEAVE TO SCREEN 0.

    WHEN  'FEHL' OR '&IC1'.
      READ TABLE t_out INDEX fu_selfield-tabindex.
      CASE fu_selfield-sel_tab_field.
        WHEN 'T_OUT-VBELN'.
          SET PARAMETER ID 'AUN' FIELD t_out-vbeln.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        WHEN 'T_OUT-ICON'.
          READ TABLE t_error WITH KEY vbeln = t_out-vbeln.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
              EXPORTING
                message_text = t_error-msg.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.
  DATA: t_jest_upd LIKE jest_upd OCCURS 0 WITH HEADER LINE.

  LOOP AT t_out.
    IF t_out-check EQ 'X'.
      DATA: estat_inactive  LIKE tj30-estat VALUE 'E0001',
            estat_active    LIKE tj30-estat VALUE 'E0002',
            stsma           LIKE jsto-stsma VALUE 'Y001'.

      SELECT SINGLE * FROM jsto WHERE objnr = t_out-objnr.

      IF NOT estat_inactive IS INITIAL.
        SELECT SINGLE * INTO t_jest_upd FROM jest
          WHERE objnr = t_out-objnr
            AND stat  = estat_inactive.
        IF sy-subrc = 0.
          CALL FUNCTION 'I_CHANGE_STATUS' IN UPDATE TASK
            EXPORTING
              objnr          = t_out-objnr
              estat_inactive = estat_inactive
              estat_active   = estat_active
              stsma          = stsma.
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
*            PERFORM f_create_so.
            PERFORM f_create_so_new.
          ENDIF.
        ELSE.
          t_out-icon  = icon_led_red.
          MODIFY t_out TRANSPORTING icon.
          t_error-vbeln = t_out-vbeln.
          t_error-msg   = 'Harap menunggu beberapa saat untuk release quotation !'.
          APPEND t_error.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  PERFORM f_alv TABLES t_out.
ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  F_CREATE_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_so .
  DATA: salesdocument_ex    LIKE bapivbeln-vbeln,
        documenttype        LIKE bapisdhd1-doc_type,
        return              LIKE bapiret2  OCCURS 0 WITH HEADER LINE,
        order_header_inx    LIKE bapisdh1x OCCURS 0 WITH HEADER LINE,
        testrun(1).

  DATA: estat_inactive  LIKE tj30-estat VALUE 'E0002',
        estat_active    LIKE tj30-estat VALUE 'E0001',
        stsma           LIKE jsto-stsma VALUE 'Y001'.

  SELECT SINGLE auara
    FROM tvak
    INTO documenttype
    WHERE auart EQ t_out-auart.

  CALL FUNCTION 'BAPI_SALESDOCUMENT_COPY'
    EXPORTING
      salesdocument    = t_out-vbeln
      documenttype     = documenttype
      testrun          = testrun
    IMPORTING
      salesdocument_ex = salesdocument_ex
    TABLES
      return           = return.

  IF salesdocument_ex IS NOT INITIAL.
    COMMIT WORK AND WAIT.
    DELETE t_out.
  ELSE.
    ROLLBACK WORK.
    t_out-icon = icon_led_red.
    MODIFY t_out TRANSPORTING icon.

    LOOP AT return.
      t_error-vbeln = t_out-vbeln.
      t_error-msg   = return-message.
      APPEND t_error.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CREATE_SO

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_SO_NEW
*&---------------------------------------------------------------------*
FORM f_create_so_new .
  DATA : rspar_tab    TYPE TABLE OF rsparams,
         rspar_line   LIKE LINE OF rspar_tab.
  DATA : lv_idmsg(40),
         lv_vbeln     TYPE vbak-vbeln,
         lv_auart     TYPE vbak-auart.

  CALL FUNCTION 'BUFFER_REFRESH_ALL'.
  CONCATENATE sy-uname 'DOCOPY' INTO lv_idmsg.

  FREE MEMORY ID lv_idmsg.

  lv_vbeln  = t_out-vbeln.
  lv_auart  = t_out-auart.

  rspar_line-selname = 'PA_VBELN'.
  rspar_line-kind    = 'P'.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = lv_vbeln.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

  rspar_line-selname = 'PA_AUART'.
  rspar_line-kind    = 'P'.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = lv_auart.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

  SUBMIT zs_doccopy WITH SELECTION-TABLE rspar_tab
  AND RETURN.

  IMPORT t_error TO t_error FROM MEMORY ID lv_idmsg.

  READ TABLE t_error INDEX 1.
  IF t_error-icon = icon_led_green.
    DELETE t_out.
  ENDIF.
ENDFORM.                    " F_CREATE_SO_NEW
