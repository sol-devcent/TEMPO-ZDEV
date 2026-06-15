*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.

  CLEAR: usergroup, va_mark.
  SELECT SINGLE usergroup INTO  usergroup
         FROM usgrp_user
         WHERE bname  = sy-uname.

  IF usergroup EQ space.
    MESSAGE e000(zs) WITH 'No Authorization'.
*         Exit.
  ENDIF.

  SELECT SINGLE zgoluser INTO zgoluser FROM zscl_goluser
           WHERE ztype = 'CL' AND
                 usrgroup = usergroup.
  IF sy-subrc NE 0.
    IF usergroup = 'PD'.
    ELSE.
*             message e000(zs) with 'No Authorization'.
      va_mark = 'N'.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_cust  LIKE t_itab OCCURS 0 WITH HEADER LINE.

  IF r_vkbur[] IS INITIAL.
    MESSAGE s000(zs) WITH 'No Authorization SlOff'.
    STOP.
  ELSE.
* Get Detail
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE t_itab
      FROM zscl_sm
      WHERE gjahr = pa_gjahr  AND
            zsmst = pa_zsmst  AND
            vkorg = pa_vkorg  AND
            kkber = pa_kkber  AND
            vkbur IN r_vkbur AND
            kdgrp IN so_kdgrp AND
            kvgr3 IN so_kvgr3 AND
            knkli IN so_knkli.

    l_cust[] = t_itab[].
    SORT l_cust BY knkli.
    DELETE ADJACENT DUPLICATES FROM l_cust COMPARING knkli.

    IF t_itab[] IS NOT INITIAL.
* Get Customer
      SELECT kunnr name1 aufsd vtext
      INTO CORRESPONDING FIELDS OF TABLE t_kna1
      FROM kna1 AS a LEFT OUTER JOIN tvast AS b ON b~spras = sy-langu AND
                                                   b~aufsp = a~aufsd
      FOR ALL ENTRIES IN l_cust
      WHERE kunnr = l_cust-knkli.
    ENDIF.

* Check type report
    IF p_entry IS INITIAL.
      DELETE t_itab WHERE status = space.
    ENDIF.
    IF p_downl IS INITIAL.
      DELETE t_itab WHERE status = 'D'.
    ENDIF.
    IF p_uplod IS INITIAL AND p_upld1 IS INITIAL.
      DELETE t_itab WHERE status = 'U'.
    ENDIF.
    IF p_delet IS INITIAL.
      DELETE t_itab WHERE status = 'H'.
    ENDIF.
    IF p_usula IS INITIAL AND p_rele1 IS INITIAL.
      DELETE t_itab WHERE status = 'P'.
    ENDIF.
    IF p_relec IS INITIAL.
      DELETE t_itab WHERE status = 'X'.
    ENDIF.
    IF p_final IS INITIAL.
      DELETE t_itab WHERE status = 'F'.
    ENDIF.
  ENDIF.

* get Bank Garansi
  IF t_itab[] IS NOT INITIAL.
    t_kdgrp[] = t_itab[].
    t_knkli[] = t_itab[].
    SORT t_kdgrp BY kdgrp.
    SORT t_knkli BY knkli.
    DELETE ADJACENT DUPLICATES FROM t_kdgrp COMPARING kdgrp.
    DELETE t_kdgrp WHERE kdgrp EQ space.
    DELETE ADJACENT DUPLICATES FROM t_knkli COMPARING knkli.

    IF t_knkli[] IS NOT INITIAL.
      SELECT *
        FROM zsbankgrs
        INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_kdgrp
        FOR ALL ENTRIES IN t_kdgrp
        WHERE kdgrp EQ t_kdgrp-kdgrp.
      SELECT *
        FROM zsbankgrs
        INTO CORRESPONDING FIELDS OF TABLE t_zsbankgrs_knkli
        FOR ALL ENTRIES IN t_knkli
        WHERE kunnr EQ t_knkli-knkli.
    ENDIF.
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

  DATA: l_zgoluser LIKE zscl_goluser-zgoluser,
        l_zgoluser1 LIKE zscl_goluser-zgoluser,
        l_zgoluser2 LIKE zscl_goluser-zgoluser,
        l_usergroup LIKE usergroup.

  DATA: ld_klimk_hit  LIKE zscl_sm-klimk_hit,
        ld_found      TYPE i.

  SORT t_kna1 BY kunnr.
  LOOP AT t_itab.
*----------- Validasi untuk bank garansi.
    LOOP AT t_zsbankgrs_knkli WHERE kunnr EQ t_itab-knkli.
      IF t_zsbankgrs_knkli-valid_to GE sy-datum AND t_zsbankgrs_knkli-valid_fr LE sy-datum.
        ld_found  = 1.
        ADD t_zsbankgrs_knkli-wrbtr TO ld_klimk_hit.
      ENDIF.
    ENDLOOP.

    IF ld_found EQ 1.
      IF ld_klimk_hit IS INITIAL.
        sy-subrc  = 4.
      ELSE.
        sy-subrc  = 0.
      ENDIF.
    ELSE.
      sy-subrc  = 4.
    ENDIF.

    IF sy-subrc EQ 0.
      IF t_itab-klimk_hit GT ld_klimk_hit.
        t_itab-klimk_hit = ld_klimk_hit.
        t_itab-klimk_usl = ld_klimk_hit.
      ENDIF.
    ELSE.
      LOOP AT t_zsbankgrs_kdgrp WHERE kdgrp EQ t_itab-kdgrp.
        IF t_zsbankgrs_kdgrp-valid_to GE sy-datum AND t_zsbankgrs_kdgrp-valid_fr LE sy-datum.
          ld_found  = 1.
          ADD t_zsbankgrs_kdgrp-wrbtr TO ld_klimk_hit.
        ENDIF.
      ENDLOOP.

      IF ld_found EQ 1.
        IF ld_klimk_hit IS INITIAL.
          sy-subrc  = 4.
        ELSE.
          sy-subrc  = 0.
        ENDIF.
      ELSE.
        sy-subrc  = 4.
      ENDIF.

      IF sy-subrc EQ 0.
        IF t_itab-klimk_hit GT ld_klimk_hit.
          t_itab-klimk_hit = ld_klimk_hit.
          t_itab-klimk_usl = ld_klimk_hit.
        ENDIF.
      ENDIF.
    ENDIF.
*-----------

    SPLIT t_itab-usergroup AT ',' INTO t_itab-user1 t_itab-user2 t_itab-user3.
* Check Pengajuan release 1 user
    IF p_rele1 IS INITIAL AND p_usula IS NOT INITIAL.
      IF t_itab-status = 'P' AND t_itab-user2 IS NOT INITIAL.
        DELETE t_itab.
        CLEAR: t_itab, ld_klimk_hit.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF p_rele1 IS NOT INITIAL AND p_usula IS INITIAL.
      IF t_itab-status = 'P' AND t_itab-user2 IS INITIAL.
        DELETE t_itab.
        CLEAR: t_itab, ld_klimk_hit.
        CONTINUE.
      ENDIF.
    ENDIF.
* Check Upload release 1 user
    IF p_upld1 IS INITIAL AND p_uplod IS NOT INITIAL.
      IF t_itab-status = 'U' AND t_itab-user2 IS NOT INITIAL.
        DELETE t_itab.
        CLEAR: t_itab, ld_klimk_hit.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF p_upld1 IS NOT INITIAL AND p_uplod IS INITIAL.
      IF t_itab-status = 'U' AND t_itab-user2 IS INITIAL.
        DELETE t_itab.
        CLEAR: t_itab, ld_klimk_hit.
        CONTINUE.
      ENDIF.
    ENDIF.
* Customer name
    CLEAR t_kna1.
    READ TABLE t_kna1 WITH KEY kunnr = t_itab-knkli.
    t_itab-name1 = t_kna1-name1.
    IF t_kna1-aufsd IS NOT INITIAL.
      t_itab-vtext = t_kna1-vtext.
    ENDIF.
* Hitung persen
    IF t_itab-klimk_usl IS NOT INITIAL.
      t_itab-klimk_usl% = ( t_itab-klimk_usl - t_itab-klimk_hit ) / t_itab-klimk_hit * 100.
    ENDIF.
    IF t_itab-klimk_kp IS NOT INITIAL.
      t_itab-klimk_kp% = ( t_itab-klimk_kp - t_itab-klimk_hit ) / t_itab-klimk_hit * 100.
    ENDIF.
* Status Description
    CASE t_itab-status.
      WHEN ' '.
        t_itab-sts_desc = 'Entry'.
      WHEN 'D'.
        t_itab-sts_desc = 'Download'.
      WHEN 'U'.
        IF t_itab-user2 IS INITIAL.
          t_itab-sts_desc = 'Upload'.
        ELSE.
          t_itab-sts_desc = 'Upload R1'.
        ENDIF.
      WHEN 'H'.
        t_itab-sts_desc = 'Delete'.
      WHEN 'P'.
        IF t_itab-user2 IS INITIAL.
          t_itab-sts_desc = 'Pengajuan'.
        ELSE.
          t_itab-sts_desc = 'Pengajuan R1'.
        ENDIF.
      WHEN 'X'.
        t_itab-sts_desc = 'Complete'.
      WHEN 'F'.
        t_itab-sts_desc = 'Final'.
    ENDCASE.

    IF t_itab-status IS INITIAL OR t_itab-status = 'U'.
      IF t_itab-klimk_usl% LE 0.
        CLEAR t_itab-zgol.
      ENDIF.
    ENDIF.

    MODIFY t_itab.
    CLEAR: t_itab, ld_klimk_hit.
  ENDLOOP.

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
  DATA: ft_cat TYPE lvc_s_fcat.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'KNKLI' 'ZSCL_SM' 'KNKLI' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'SORTL' 'KNA1' 'SORTL' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
    'KDGRP' 'S603' 'KDGRP' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KVGR3' 'S603' 'KVGR3' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SLSM1' '' '' 'X' '17' 'SLSM M1' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'SLSM2' '' '' 'X' '17' 'SLSM M2' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'SLSM3' '' '' 'X' '17' 'SLSM M3' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'SLSM4' '' '' 'X' '17' 'SLSM M4' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'SLSM5' '' '' 'X' '17' 'SLSM M5' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'SLSM6' '' '' 'X' '17' 'SLSM M6' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'TOTAL6' '' '' 'X' '17' 'Total 6bl' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'TOTAL3' '' '' 'X' '17' 'Total 3bl' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'COUNT6' '' '' 'X' '6' 'Count6bl' '' '' '' '' '' '' '' '' '' '' '',
    'COUNT3' '' '' 'X' '6' 'Count3bl' '' '' '' '' '' '' '' '' '' '' '',
    'AVRG6' '' '' 'X' '17' 'Average 6bl' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'AVRG3' '' '' 'X' '17' 'Average 3bl' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'MAXVAL' '' '' 'X' '17' 'Max Value' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'HIST' '' '' 'X' '17' 'History' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'KLIMK' '' '' '' '17' 'Current CL' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'GRO' '' '' 'X' '7' 'Growth' '' '' '' '' '' '' '' '' '' '' '',
    'TOP' '' '' 'X' '7' 'TOP' '' '' '' '' '' '' '' '' '' '' '',
    'KLIMK_HIT' '' '' '' '17' 'New CL' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'KLIMK_USL' '' '' '' '17' 'Usul CL' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'KLIMK_USL%' '' '' '' '10' 'Usul CL %' '' '' '' '' '' '' '' '' '' '' '',
    'KLIMK_KP' '' '' '' '17' 'Koreksi CL' '' '' '' '' '' 'WAERS' '' '' '' '' '',
    'KLIMK_KP%' '' '' '' '10' 'Kor CL %' '' '' '' '' '' '' '' '' '' '' '',
    'ZGOL' '' '' '' '10' 'Level' '' '' '' '' '' '' '' '' '' '' '',
    'USER2' '' '' '' '7' 'User 1' '' '' '' '' '' '' '' '' '' '' '',
    'USER3' '' '' '' '7' 'User 2' '' '' '' '' '' '' '' '' '' '' '',
    'REASON' '' '' '' '30' 'Reason' '' '' '' '' '' '' '' '' '' '' '',
*    'STATUS' '' '' '' '6' 'Status' '' '' '' '' '' '' '' '' '' '' ''.
    'STS_DESC' '' '' '' '15' 'Status' '' '' '' '' '' '' '' '' '' '' '',
    'VTEXT' '' '' '' '20' 'Blok Status' '' '' '' '' '' '' '' '' '' '' ''.
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
                          value(fu_key)
                          value(fu_edit).

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
  ld_fieldcat-edit              = fu_edit.
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
        l_vkbur(40),
        l_usrgrp(60).

  CONCATENATE 'Period:' pa_gjahr '/' pa_zsmst INTO l_period SEPARATED BY space.

  SELECT SINGLE bezei INTO l_vkbur FROM tvkbt
    WHERE spras = sy-langu     AND
          vkbur = t_itab-vkbur.
  CONCATENATE 'SlOff:' t_itab-vkbur l_vkbur INTO l_vkbur SEPARATED BY space.

*  CONCATENATE 'User Group:' t_itab-zusergroup '/' 'Golongan:' t_itab-zgoluser
*      INTO l_usrgrp SEPARATED BY space.

  PERFORM f_hdr_uline.
  IF ok_code = '&CONF'.
    PERFORM f_hdr_line1 USING 'CONFIRM Usulan CL Semester'.
  ELSEIF ok_code = 'DELETE'.
    PERFORM f_hdr_line1 USING 'DELETE Usulan CL Semester'.
  ELSE.
    PERFORM f_hdr_line1 USING sy-title.
  ENDIF.

  PERFORM f_hdr_line2 USING l_period.
  PERFORM f_hdr_line3 USING l_vkbur.
*  PERFORM f_hdr_line4 USING l_usrgrp.
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
*  REFRESH: t_itab.
*  CLEAR: t_itab.
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

*  CASE fu_ucomm.
*    WHEN '&IC1'.
*      PERFORM f_usulan USING fu_selfield.
*    WHEN '&SAV'.
*      PERFORM f_post_entries.
*    WHEN '&CONF' OR 'DELETE'.
*      CLEAR ok_code.
*      ok_code = fu_ucomm.
*      PERFORM f_confirm.
*  ENDCASE.
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

  CLEAR: usergroup, zgoluser.
  SELECT SINGLE usergroup INTO  usergroup
         FROM usgrp_user
         WHERE bname  = sy-uname.
  IF usergroup EQ space.
    MESSAGE w000(zs) WITH 'No Authorization'.
    va_mark = 'N'.
  ENDIF.

  SELECT SINGLE zgoluser INTO zgoluser FROM zscl_goluser
           WHERE ztype = 'CL' AND
                 usrgroup = usergroup.
  IF sy-subrc NE 0.
    IF usergroup = 'PD'.
    ELSE.
      MESSAGE w000(zs) WITH 'No Authorization'.
      va_mark = 'N'.
    ENDIF.
  ENDIF.

ENDFORM.                    " init_screen

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE4
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING fu_title.
*--- output line
  PERFORM f_hdr_pad_title USING fu_title '' ''.

ENDFORM.                    " F_HDR_LINE3
