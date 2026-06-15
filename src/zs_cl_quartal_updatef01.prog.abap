*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  IF p_entry IS NOT INITIAL.
    PERFORM f_append_status_ranges USING ''.
  ENDIF.
  IF p_downl IS NOT INITIAL.
    PERFORM f_append_status_ranges USING 'D'.
  ENDIF.
  IF p_uplod IS NOT INITIAL.
    PERFORM f_append_status_ranges USING 'U'.
  ENDIF.
  IF p_usula IS NOT INITIAL.
    PERFORM f_append_status_ranges USING 'P'.
  ENDIF.
  IF p_relec IS NOT INITIAL.
    PERFORM f_append_status_ranges USING 'X'.
  ENDIF.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_knkli LIKE zscl_sm-knkli,
        l_cust  LIKE t_itab OCCURS 0 WITH HEADER LINE.

* Get Detail
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE t_itab
    FROM zscl_sm
    WHERE gjahr = pa_gjahr  AND
          zsmst = pa_zsmst  AND
          vkorg = pa_vkorg  AND
          vkbur IN so_vkbur  AND
          kkber IN so_kkber  AND
          kdgrp IN so_kdgrp AND
          kvgr3 IN so_kvgr3 AND
          knkli IN so_knkli AND
*          status IN ('X','U',' ').
          status IN r_status.

  l_cust[] = t_itab[].
  SORT l_cust BY knkli.
  DELETE ADJACENT DUPLICATES FROM l_cust COMPARING knkli.

  PERFORM f_get_knkk TABLES l_cust.

  IF t_itab[] IS NOT INITIAL.
* Get Customer
    SELECT kunnr name1
    INTO CORRESPONDING FIELDS OF TABLE t_kna1
    FROM kna1
    FOR ALL ENTRIES IN l_cust
    WHERE kunnr = l_cust-knkli.
  ENDIF.
ENDFORM.                    "f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA: lt_itab LIKE t_itab OCCURS 0.
  DATA: ld_flag TYPE i.

  SORT t_kna1 BY kunnr.
  LOOP AT t_itab.
* Customer name
    CLEAR t_kna1.
    READ TABLE t_kna1 WITH KEY kunnr = t_itab-knkli.
    t_itab-name1 = t_kna1-name1.
* User Group
    SPLIT t_itab-usergroup AT ',' INTO t_itab-user1 t_itab-user2 t_itab-user3.
* Hitung persen
    IF t_itab-klimk_usl IS NOT INITIAL.
      t_itab-klimk_usl% = ( t_itab-klimk_usl - t_itab-klimk_hit ) / t_itab-klimk_hit * 100.
    ENDIF.
    IF t_itab-klimk_kp IS NOT INITIAL.
      t_itab-klimk_kp% = ( t_itab-klimk_kp - t_itab-klimk_hit ) / t_itab-klimk_hit * 100.
    ENDIF.
* Update Master Data
    ld_flag  = 1.
    PERFORM f_update_db USING ld_flag
                        CHANGING t_itab-message.

    IF t_itab-message = 'OK'.
      t_itab-status = 'F'.
    ENDIF.
* Modify itab
    MODIFY t_itab TRANSPORTING name1 status user2 user3 klimk_usl% klimk_kp% message.
    CLEAR t_itab.
  ENDLOOP.

  LOOP AT t_zknkk.
* Update Master Data
    ld_flag  = 2.
    PERFORM f_update_db USING ld_flag
                        CHANGING t_itab-message.
  ENDLOOP.

  lt_itab[] = t_itab[].
  DELETE lt_itab WHERE status NE 'F'.

  MODIFY zscl_sm FROM TABLE lt_itab.
  IF sy-subrc = 0.
    COMMIT WORK.
    PERFORM f_download.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES t_itab.
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
    'KNKLI' 'ZSCL_SM' 'KNKLI' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'SORTL' 'KNA1' 'SORTL' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' 'X',
    'KDGRP' 'S603' 'KDGRP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KVGR3' 'S603' 'KVGR3' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SLSM1' '' '' 'X' '17' 'SLSM M1' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM2' '' '' 'X' '17' 'SLSM M2' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM3' '' '' 'X' '17' 'SLSM M3' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM4' '' '' 'X' '17' 'SLSM M4' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM5' '' '' 'X' '17' 'SLSM M5' '' '' '' '' '' 'WAERS' '' '' '' '',
    'SLSM6' '' '' 'X' '17' 'SLSM M6' '' '' '' '' '' 'WAERS' '' '' '' '',
    'TOTAL6' '' '' 'X' '17' 'Total 6bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'TOTAL3' '' '' 'X' '17' 'Total 3bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'COUNT6' '' '' 'X' '6' 'Count6bl' '' '' '' '' '' '' '' '' '' '',
    'COUNT3' '' '' 'X' '6' 'Count3bl' '' '' '' '' '' '' '' '' '' '',
    'AVRG6' '' '' 'X' '17' 'Average 6bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'AVRG3' '' '' 'X' '17' 'Average 3bl' '' '' '' '' '' 'WAERS' '' '' '' '',
    'MAXVAL' '' '' 'X' '17' 'Max Value' '' '' '' '' '' 'WAERS' '' '' '' '',
    'HIST' '' '' 'X' '17' 'History' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK' '' '' '' '17' 'Current CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'GRO' '' '' 'X' '7' 'Growth' '' '' '' '' '' '' '' '' '' '',
    'TOP' '' '' 'X' '7' 'TOP' '' '' '' '' '' '' '' '' '' '',
    'KLIMK_HIT' '' '' '' '17' 'New CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK_USL' '' '' '' '17' 'Usul CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK_USL%' '' '' '' '10' 'Usul CL %' '' '' '' '' '' '' '' '' '' '',
    'KLIMK_KP' '' '' '' '17' 'Koreksi CL' '' '' '' '' '' 'WAERS' '' '' '' '',
    'KLIMK_KP%' '' '' '' '10' 'Kor CL %' '' '' '' '' '' '' '' '' '' '',
    'ZGOL' '' '' '' '7' 'Level' '' '' '' '' '' '' '' '' '' '',
    'USER2' '' '' '' '7' 'User 1' '' '' '' '' '' '' '' '' '' '',
    'USER3' '' '' '' '7' 'User 2' '' '' '' '' '' '' '' '' '' '',
    'REASON' '' '' '' '30' 'Reason' '' '' '' '' '' '' '' '' '' '',
    'MESSAGE' '' '' '' '30' 'Update CL Message' '' '' '' '' '' '' '' '' '' ''.
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
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_key).

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
  ld_fieldcat-key               = fu_key.
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
*  fu_layout-box_fieldname      = 'CHECK'.
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
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KNKLI'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: l_period(40),
        l_spmon1(7),
        l_spmon2(7),
        l_vkbur(40).

  CONCATENATE 'Period:' pa_gjahr '/' pa_zsmst INTO l_period SEPARATED BY space.

  SELECT SINGLE bezei INTO l_vkbur FROM tvkbt
    WHERE spras = sy-langu     AND
          vkbur = t_itab-vkbur.
  CONCATENATE 'SlOff:' t_itab-vkbur l_vkbur INTO l_vkbur SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING l_period.
  PERFORM f_hdr_line3 USING l_vkbur.
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
  REFRESH: t_itab, t_kna1, t_knkk, t_zscl_gro.
  CLEAR: t_itab, t_kna1, t_knkk, t_zscl_gro.
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

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.
  CLEAR ok_code.
  ok_code = fu_ucomm.

  CASE fu_ucomm.
*    WHEN '&IC1'.
*      PERFORM f_usulan USING fu_selfield.
*    WHEN '&SAV'.
*      PERFORM f_post_entries.
*    WHEN '&CONF'.
*      PERFORM f_confirm.
  ENDCASE.
ENDFORM.                    "f_user_command

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
*&      Form  init_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_screen .
  DATA: l_date LIKE sy-datum.
*** Credit control area
*  so_kkber-low    = '8000'.
*  so_kkber-sign   = 'I'.
*  so_kkber-option = 'EQ'.
*  APPEND so_kkber.
ENDFORM.                    " init_screen

*&---------------------------------------------------------------------*
*&      Form  f_update_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_db USING fu_flag
                 CHANGING message.

  CASE fu_flag.
    WHEN 1.
      knka-kunnr = t_itab-knkli.

      SELECT SINGLE  * FROM knkk
        WHERE kunnr = knka-kunnr AND
              kkber = t_itab-kkber.

      MOVE-CORRESPONDING knkk TO yknkk.

      IF t_itab-status = 'X'.                 "Release Complete
        IF t_itab-klimk_kp = 0.
          knkk-dbekr = t_itab-klimk_usl * 100.
        ELSE.
          knkk-dbekr = t_itab-klimk_kp * 100.
        ENDIF.
      ELSE.
        knkk-dbekr = t_itab-klimk_hit * 100.
      ENDIF.
      knkk-klimk = knkk-dbekr / 100.
      knkk-knkli = t_itab-knkli.
      knkk-aedat = sy-datum.
      knkk-aenam = sy-uname.
      knkk-kkber = t_itab-kkber.

    WHEN 2.
      knka-kunnr = t_zknkk-kunnr.

      SELECT SINGLE  * FROM knkk
        WHERE kunnr = knka-kunnr AND
              kkber = t_zknkk-kkber.

      MOVE-CORRESPONDING knkk TO yknkk.

      knkk-dbekr = 1.
      knkk-klimk = 1 / 100.
      knkk-aedat = sy-datum.
      knkk-aenam = sy-uname.
  ENDCASE.

  CALL FUNCTION 'CREDITLIMIT_CHANGE' IN UPDATE TASK
    EXPORTING
      i_knka   = knka
      i_knkk   = knkk
      upd_knka = ''
      upd_knkk = 'U'
      yknka    = knka
      yknkk    = yknkk
      xneua    = ''
      xrefl    = ''.
  IF sy-subrc EQ 0.
    message = 'OK'.
  ELSE.
    message = 'Update Gagal'.
  ENDIF.

ENDFORM.                    " f_update_db

*&---------------------------------------------------------------------*
*&      Form  f_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download .

ENDFORM.                    " f_download

*&---------------------------------------------------------------------*
*&      Form  f_get_knkk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_knkk TABLES lt_cust STRUCTURE t_itab.
  DATA: BEGIN OF lt_kna1 OCCURS 0,
          kunnr  LIKE kna1-kunnr,
          sortl  LIKE kna1-sortl,
          aufsd  LIKE kna1-aufsd.
  DATA: END OF lt_kna1.

  SELECT a~kunnr a~kkber klimk dbwae dbekr
    FROM knkk AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr
    INTO CORRESPONDING FIELDS OF TABLE t_zknkk
    WHERE a~kunnr IN so_knkli AND
          a~kkber IN so_kkber AND
          b~vkorg EQ pa_vkorg AND
          b~kdgrp IN so_kdgrp AND
          b~vkbur IN so_vkbur AND
          b~kvgr3 IN so_kvgr3.

  SORT lt_cust BY knkli.
  SORT t_zknkk BY kunnr.

  IF t_zknkk[] IS NOT INITIAL.
    SELECT kunnr sortl aufsd
      FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE lt_kna1
      FOR ALL ENTRIES IN t_zknkk
      WHERE kunnr EQ t_zknkk-kunnr AND
*            aufsd NE space         AND
            ktokd IN ('ZC04','ZSU1').
  ENDIF.

  SORT lt_kna1 BY kunnr.
  LOOP AT t_zknkk.
    READ TABLE lt_kna1 WITH KEY kunnr = t_zknkk-kunnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE lt_cust WITH KEY knkli = t_zknkk-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF lt_kna1-aufsd EQ space.
          DELETE t_zknkk.
        ENDIF.
      ENDIF.
    ELSE.
      DELETE t_zknkk.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_get_knkk

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_STATUS_RANGES
*&---------------------------------------------------------------------*
FORM f_append_status_ranges  USING fu_status.
  CLEAR r_status.
  r_status-sign = 'I'.
  r_status-option = 'EQ'.
  r_status-low = fu_status.
  APPEND r_status.
ENDFORM.                    " F_APPEND_STATUS_RANGES
