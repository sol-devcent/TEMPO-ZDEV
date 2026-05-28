*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.
  REFRESH: i_kunnr, r_kunnr, i_s603, i_average, i_mard, i_s940e.
  CLEAR  : i_kunnr, r_kunnr, i_s603, i_average, i_mard, i_s940e.

ENDFORM.                    "f_init_data


*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: i_s940_vkbur TYPE t_s940 OCCURS 0,
        d_kcreq    TYPE s940-kcreq.

  REFRESH: i_s940_vkbur.
  CLEAR: i_s940_vkbur.

* baca material yang ada di S940E
  SELECT matnr
  FROM s940e
  INTO TABLE i_s940e
  WHERE vkorg = p_vkorg AND
        vtweg = p_vtweg AND
        vkbur = wa_vkbur-vkbur AND
        konob = v_konob AND
        kvgr5 = 'KA' AND
        matnr IN s_matnr.

  SORT i_s940e BY matnr.
  DELETE i_s940e WHERE matnr = '##################'.
  DELETE i_s940e WHERE matnr IS INITIAL.

  DELETE ADJACENT DUPLICATES FROM i_s940e COMPARING matnr.

  IF i_s940e[] IS INITIAL.
    EXIT.
  ENDIF.

* Isi data s_matnr dengan data dari i_s940e
  CLEAR : s_matnr, wa_s940e.
  REFRESH s_matnr.
  LOOP AT i_s940e INTO wa_s940e.
    s_matnr-low = wa_s940e-matnr.
    s_matnr-option = 'EQ'.
    s_matnr-sign   = 'I'.
    APPEND s_matnr.
  ENDLOOP.

* Baca data product allocation dari S940
  SELECT * FROM s940 INTO TABLE i_s940_vkbur
  WHERE vrsio = '000' AND
        spmon = v_spmon AND
        vkorg = p_vkorg AND
        vtweg = p_vtweg AND
        vkbur = wa_vkbur-vkbur AND
        konob = v_konob AND
        spwoc = '000000' AND
        spbup = '000000' AND
        matnr IN s_matnr.

* Baca ending stock material
  SELECT matnr werks lgort labst
  INTO TABLE i_mard
  FROM mard
  FOR ALL ENTRIES IN i_s940e
  WHERE werks = wa_vkbur-vkbur AND
         matnr = i_s940e-matnr AND
         lgort IN s_lgort AND
         labst NE 0.

* Baca outstanding order dan kurangi ending stock material
  DATA: x_omeng LIKE vbbe-omeng.

  CLEAR wa_mard.
  LOOP AT i_mard INTO wa_mard.
    CLEAR: x_omeng.
    SELECT SUM( omeng ) FROM vbbe INTO x_omeng
        WHERE vbtyp = 'J' AND
              werks = wa_mard-werks AND
              lgort = wa_mard-lgort AND
              matnr = wa_mard-matnr.
    wa_mard-labst = wa_mard-labst - x_omeng.
    MODIFY i_mard FROM wa_mard.
  ENDLOOP.

*-----------------------------------------------------------------*
*    Proses untuk mendapatkan average sales untuk customer KA     *
*-----------------------------------------------------------------*
  IF p_date+6(2) BETWEEN '01' AND '07' OR p_avr EQ 'X'.

* Baca customer yang group KA
    SELECT vkbur  kunnr kvgr5 FROM knvv
        INTO TABLE i_kunnr
        WHERE kunnr IN r_kunnr AND
              vkorg = p_vkorg AND
              vtweg = p_vtweg AND
              vkbur = wa_vkbur-vkbur AND
              kvgr5 = 'KA'.

* Mulai Juli 2005 customer Cengkareng pindah ke Bekasi
    IF v_spmon > '200506' AND wa_vkbur-vkbur = '0201'.
      SELECT vkbur  kunnr kvgr5 FROM knvv
          APPENDING TABLE i_kunnr
          WHERE kunnr IN r_kunnr AND
                vkorg = p_vkorg AND
                vtweg = p_vtweg AND
                vkbur = '0202' AND
                kvgr5 = 'KA'.
    ENDIF.
* Isi data r_kunnr dari i_kunnr
    CLEAR : r_kunnr, wa_kunnr.
    REFRESH r_kunnr.
    LOOP AT i_kunnr INTO wa_kunnr.
      r_kunnr-low = wa_kunnr-kunnr.
      r_kunnr-option = 'EQ'.
      r_kunnr-sign   = 'I'.
      APPEND r_kunnr.
      CLEAR wa_kunnr.
    ENDLOOP.

* Baca data history sales
    REFRESH: i_s603.
    CLEAR: i_s603.

* Mulai Juli 2005 customer Cengkareng pindah ke Bekasi
    IF v_spmon > '200506' AND wa_vkbur-vkbur = '0201'.
      SELECT spmon pkunwe vkbur matnr ummenge gumenge basme
      FROM s603
      INTO TABLE i_s603
      WHERE ssour  EQ space    AND
            vrsio  EQ '000'    AND
            pkunwe IN r_kunnr  AND
          ( vkbur  EQ wa_vkbur-vkbur OR
            vkbur  EQ '0202' ) AND
            matnr  IN s_matnr  AND
            spmon  IN r_spmon.
    ELSE.
      SELECT spmon pkunwe vkbur matnr ummenge gumenge basme
      FROM s603
      INTO TABLE i_s603
      WHERE ssour  EQ space     AND
            vrsio  EQ '000'    AND
            pkunwe IN r_kunnr  AND
            vkbur  EQ wa_vkbur-vkbur AND
            matnr  IN s_matnr  AND
            spmon  IN r_spmon.
    ENDIF.

    SORT i_s603 BY matnr spmon vkbur.
    CLEAR: wa_s603, wa_average.

    LOOP AT i_s603 INTO wa_s603.
      wa_average-vkbur = wa_vkbur-vkbur.
      wa_average-matnr = wa_s603-matnr.
      wa_average-basme = wa_s603-basme.
      wa_average-perio = 0.
      ON CHANGE OF wa_s603-spmon OR wa_s603-matnr.
        wa_average-perio = 1.
      ENDON.
      wa_average-netqty = wa_s603-ummenge + wa_s603-gumenge.
      COLLECT wa_average INTO i_average.
    ENDLOOP.

  ENDIF.
*-----------------------------------------------------------------*
*                        Start process data                       *
*-----------------------------------------------------------------*
  CLEAR: wa_s940e.

  SORT i_mard BY matnr vkbur.
  SORT i_s940_vkbur BY spmon vkorg vtweg vkbur
              konob kvgr5 matnr vrsio spwoc spbup.
  SORT i_average BY vkbur matnr.

  LOOP AT i_s940e INTO wa_s940e.
* Proses untuk KA
    READ TABLE i_s940_vkbur INTO wa_s940 WITH
       KEY spmon = v_spmon
           vkorg = p_vkorg
           vtweg = p_vtweg
           vkbur = wa_vkbur-vkbur
           konob = 'PER_MAT'
           kvgr5 = 'KA'
           matnr = wa_s940e-matnr
           vrsio = '000'
           spwoc = '000000'
           spbup = '000000'
       BINARY SEARCH.
* Jika minggu ke 2,3,4
    IF sy-subrc EQ 0.
      wa_s940-vrsio = vrsio.
      IF p_avr EQ 'X'.
        READ TABLE i_average INTO wa_average
        WITH KEY matnr = wa_s940e-matnr
        BINARY SEARCH.
        IF sy-subrc NE 0.
          CLEAR wa_average.
          wa_average-basme = 'ZPA'.
          wa_average-perio = 1.
        ENDIF.
        wa_s940-kcreq = wa_average-netqty / wa_average-perio.
      ENDIF.
* Jika minggu ke 1
    ELSE.
      READ TABLE i_average INTO wa_average
      WITH KEY matnr = wa_s940e-matnr
      BINARY SEARCH.
      IF sy-subrc NE 0.
        CLEAR wa_average.
        wa_average-vkbur = wa_vkbur-vkbur.
        wa_average-matnr = wa_s940e-matnr.
        wa_average-basme = 'ZPA'.
        wa_average-perio = 1.
      ENDIF.

      wa_s940-basme = wa_average-basme.
      wa_s940-konob = 'PER_MAT'.
      wa_s940-vkorg = p_vkorg.
      wa_s940-vtweg = p_vtweg.
      wa_s940-spwoc = '000000'.
      wa_s940-spbup = '000000'.
      wa_s940-vrsio = vrsio.
      wa_s940-spmon = v_spmon.
      wa_s940-vkbur = wa_vkbur-vkbur.
      wa_s940-matnr = wa_s940e-matnr.
      wa_s940-kvgr5 = 'KA'.
      wa_s940-kcreq = wa_average-netqty / wa_average-perio.
      wa_s940-aemenge = 0.
    ENDIF.

    IF p_date+6(2) BETWEEN '01' AND '07'.
      wa_s940-kcqty = wa_s940-kcreq * p_bobot1 / 100.
    ELSEIF p_date+6(2) BETWEEN '08' AND '15'.
      wa_s940-kcqty = wa_s940-aemenge +
                      wa_s940-kcreq * p_bobot2 / 100.
    ELSEIF p_date+6(2) BETWEEN '16' AND '23'.
      wa_s940-kcqty = wa_s940-aemenge +
                      wa_s940-kcreq * p_bobot3 / 100.
    ELSE.
      wa_s940-kcqty = wa_s940-aemenge +
                      wa_s940-kcreq * p_bobot4 / 100.
    ENDIF.

*     perform f_prod_alloc using wa_vkbur-vkbur
*                          changing wa_s940-kcqty.

    APPEND  wa_s940 TO i_s940.

* Simpan data average untuk KA
    d_kcreq = wa_s940-kcreq.
* Prosess Mask (#)
    READ TABLE i_s940_vkbur INTO wa_s940 WITH
       KEY spmon = v_spmon
           vkorg = p_vkorg
           vtweg = p_vtweg
           vkbur = wa_vkbur-vkbur
           konob = 'PER_MAT'
           kvgr5 = '###'
           matnr = wa_s940e-matnr
           vrsio = '000'
           spwoc = '000000'
           spbup = '000000'
        BINARY SEARCH.

    IF sy-subrc EQ 0.
      wa_s940-vrsio = vrsio.
    ELSE.
      wa_s940-kvgr5 = '###'.
      wa_s940-aemenge = 0.
    ENDIF.

    IF p_date+6(2) BETWEEN '01' AND '07'.
      wa_s940-kcqty = d_kcreq * p_bobot1 / 100.
    ELSEIF p_date+6(2) BETWEEN '08' AND '15'.
      wa_s940-kcqty = - wa_s940-aemenge +
                        d_kcreq * p_bobot2 / 100.
    ELSEIF p_date+6(2) BETWEEN '16' AND '23'.
      wa_s940-kcqty = - wa_s940-aemenge +
                        d_kcreq * p_bobot3 / 100.
    ELSE.
      wa_s940-kcqty = - wa_s940-aemenge +
                        d_kcreq * p_bobot4 / 100.
    ENDIF.

*     READ TABLE i_MARD INTO wa_MARD WITH
*         KEY MATNR = wa_s940-MATNR
*             WERKS = wa_s940-VKBUR
*             LGORT = '1000'
**             LGORT = p_lgort
*         BINARY SEARCH.
*     if sy-subrc ne 0.
*        WA_MARD-LABST = 0.
*     endif.
*     wa_s940-kcqty = WA_MARD-LABST - wa_s940-kcqty.

    PERFORM f_prod_alloc USING wa_vkbur-vkbur
                         CHANGING wa_s940-kcqty.

    wa_s940-kcreq = 0.
    APPEND  wa_s940 TO i_s940.

    CLEAR: wa_average, wa_s940.
  ENDLOOP.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
*perform F_SET_PF_STATUS.
*pERFORM F_USER_COMMAND.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.
*Perform f_set_pf_status.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
    is_layout                      = d_layout
    it_fieldcat                    = t_alv_fieldcat[]
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
    it_sort                        = t_alv_isort[]
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
    i_default                      = 'X'
    i_save                         = 'A'
    is_variant                     = d_alv_variant
    it_events                      = t_alv_event[]
    it_event_exit                  = t_event_exit[]
    is_print                       = d_print
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = ft_report
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "f_alv


*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
*     Write: / wa_s940-vrsio, sy-vline,
*              wa_s940-spmon, sy-vline,
*              wa_s940-konob, sy-vline,
*              wa_s940-vkorg, sy-vline,
*              wa_s940-vtweg, sy-vline,
*              wa_s940-vkbur, sy-vline,
*              wa_s940-kvgr5, sy-vline,
*              wa_s940-basme, sy-vline,
*              wa_s940-kcqty, sy-vline,
*              wa_s940-kcreq, sy-vline.

  REFRESH: t_alv_fieldcat.
  IF upl IS NOT INITIAL.
    CASE 'X'.
      WHEN p_ptt.
        PERFORM f_fieldcatg USING ft_report:
         'VRSIO' 'S940' 'VRSIO' '' '' '' '' '' '' '' '' '' '' '',
         'SPMON' 'S940' 'SPMON' '' '' '' '' '' '' '' '' '' '' '',
         'KONOB' 'S940' 'KONOB' '' '' '' '' '' '' '' '' '' '' '',
         'VKORG' 'S940' 'VKORG' '' '' '' '' '' '' '' '' '' '' '',
         'VTWEG' 'S940' 'VTWEG' '' '' '' '' '' '' '' '' '' '' '',
         'VKBUR' 'S940' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '',
         'KVGR5' 'S940' 'KVGR5' '' '' '' '' '' '' '' '' '' '' '',
         'MATNR' 'S940' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
         'BASME' 'S940' 'BASME' '' '' '' '' '' '' '' '' '' '' '',
         'KCQTY' 'S940' 'KCQTY' '' '' '' '' '' '' '' '' '' 'BASME' '',
         'AEMENGE' 'S940' 'AEMENGE' '' '' '' '' '' '' '' '' '' 'BASME' '',
         'KCREQ' 'S940' 'KCREQ' '' '' '' '' '' '' '' '' '' 'BASME' ''.
      WHEN p_tdn.
        PERFORM f_fieldcatg USING ft_report:
         'VRSIO' 'S940' 'VRSIO' '' '' '' '' '' '' '' '' '' '' '',
         'SPMON' 'S940' 'SPMON' '' '' '' '' '' '' '' '' '' '' '',
         'KONOB' 'S940' 'KONOB' '' '' '' '' '' '' '' '' '' '' '',
         'VKORG' 'S940' 'VKORG' '' '' '' '' '' '' '' '' '' '' '',
         'VTWEG' 'S940' 'VTWEG' '' '' '' '' '' '' '' '' '' '' '',
         'VKBUR' 'S940' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '',
         'KVGR5' 'S940' 'KVGR5' '' '' '' '' '' '' '' '' '' '' '',
         'MATNR' 'S940' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
         'BASME' 'S940' 'BASME' '' '' '' '' '' '' '' '' '' '' '',
         'AEMENGE' 'S940' 'AEMENGE' '' '' '' '' '' '' '' '' '' 'BASME' '',
         'KCREQ' 'S940' 'KCREQ' '' '' '' '' '' '' '' '' '' 'BASME' '',
         'KCQTY' 'S940' 'KCQTY' '' '' '' '' '' '' '' '' '' 'BASME' '',
         'KLTBK' 'S940' 'KLTBK' '' '' '' '' '' '' '' '' '' 'BASME' '',
         'BUCHM' 'S940' 'BUCHM' '' '' 'Req. Qty' '' '' '' '' '' '' 'BASME' '',
         'MKABEST' 'S940' 'MKABEST' '' '' 'Allc. Qty' '' '' '' '' '' '' 'BASME' ''.
*         'LABST' 'MARD' 'LABST' '' '' 'Stock' '' '' '' '' '' '' 'BASME' ''.
    ENDCASE.

  ELSE.
    PERFORM f_fieldcatg USING ft_report:
     'VRSIO' 'S940' 'VRSIO' '' '' '' '' '' '' '' '' '' '' '',
     'SPMON' 'S940' 'SPMON' '' '' '' '' '' '' '' '' '' '' '',
     'KONOB' 'S940' 'KONOB' '' '' '' '' '' '' '' '' '' '' '',
     'VKORG' 'S940' 'VKORG' '' '' '' '' '' '' '' '' '' '' '',
     'VTWEG' 'S940' 'VTWEG' '' '' '' '' '' '' '' '' '' '' '',
     'VKBUR' 'S940' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '',
     'KVGR5' 'S940' 'KVGR5' '' '' '' '' '' '' '' '' '' '' '',
     'MATNR' 'S940' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
     'BASME' 'S940' 'BASME' '' '' '' '' '' '' '' '' '' '' '',
     'KCQTY' 'S940' 'KCQTY' '' '' '' '' '' '' '' '' '' '' '',
     'AEMENGE' 'S940' 'AEMENGE' '' '' '' '' '' '' '' '' '' '' '',
     'KCREQ' 'S940' 'KCREQ' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.

*
*   'MAKTX'  'MAKT' 'MAKTX' '' '40' 'Description' ''
*   '' '' '' '' '' '' '',
*   'BDMNG'  'RESB' 'BDMNG' '' '15' 'Quantity' ''
*   '' '' '3' '' 'MEINS' '' 'MEINS',
*   'MEINS'  'RESB' 'MEINS' '' '6' 'UoM' ''
*   '' '' '' '' '' '' ''.
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
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency    = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
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
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.

ENDFORM.                    "f_build_layout


*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
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
*  ld_sort-group     = '*'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*  ld_sort-fieldname = 'GSTRP'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = '*'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*  ld_sort-fieldname = 'MATNR'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = ' '.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*  CLEAR ld_sort.

ENDFORM.                    "f_build_sortfield



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

*  PERFORM f_hdr_uline.
  PERFORM f_hdr_line4 USING ''.
*  PERFORM f_hdr_uline.

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
  REFRESH: i_kunnr, r_kunnr, i_s603, i_average, i_mard, i_s940e.
  CLEAR: i_kunnr, r_kunnr, i_s603, i_average, i_mard, i_s940e.

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
  CASE 'X'.
    WHEN upl.
      SET PF-STATUS  'TOEXECUTE'.
    WHEN OTHERS.
      SET PF-STATUS  'TOEXECUTE' EXCLUDING '&UPD'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status1 USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS  'SET2'.

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
  sy-lsind = 0.
  CASE fu_ucomm.
    WHEN '&PO'.
*      PERFORM f_process_order.
    WHEN '&UPD'.
      LOOP AT gt_out INTO wa_s940.
        MODIFY s940 FROM wa_s940.
      ENDLOOP.

      PERFORM f_send_api.

      MESSAGE s000(zab) WITH 'Data already updated'.
      LEAVE TO SCREEN 0.
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


*data: gs_lineinfo type kkblo_lineinfo.
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.
ENDFORM.                    "f_after_line_output

*&---------------------------------------------------------------------*
*&      Form  f_print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data.
*  SORT i_itab1 BY werks gstrp matnr.
*  PERFORM f_alv TABLES i_itab1.

  CALL SCREEN 100.

ENDFORM.                    "


*&---------------------------------------------------------------------*
*&      Form  f_hdr_line4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0515   text
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING    value(p_0515).
*  DATA: v_left_text(40),
*        v_right_text(40),
*        l_sw(1),
*        v_product(62),
*        l_plnbez LIKE wa_linkx-plnbez.
*  DATA:
*    page_number(10) VALUE 'Page: nnnn',
*    progname(42) VALUE 'Program : xx',
*    ld_progname(20),
*    page(4),
*    l_lenght TYPE i,
*    ld_sysid(30) VALUE 'Client      : XXX(YYY)',
*    ld_datum(10).
*
**--- Program & Page number
*  CLEAR: v_left_text, v_right_text.
*  page = sy-pagno.
*  REPLACE 'nnnn' WITH page INTO page_number.
*  IF sy-cprog EQ sy-repid.
*    REPLACE 'xx' WITH sy-repid INTO progname.
*  ELSE.
*    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
*    REPLACE 'xx' WITH ld_progname INTO progname.
*  ENDIF.
*  PERFORM f_hdr_pad_title1 USING progname sy-title page_number.
*  CLEAR: v_left_text, v_right_text.
**--- system info  & Date
*  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
*  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.
*  WRITE sy-datum TO ld_datum.
*  CONCATENATE 'Date  : ' ld_datum INTO v_right_text
*                             SEPARATED BY space.
*  CONCATENATE 'Client            : ' sy-sysid(3) '(' sy-mandt ')'
*              INTO v_left_text   SEPARATED BY space.
*  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
**--- Plant & Name
*  CLEAR: v_left_text, v_right_text.
*  CONCATENATE 'Plant             : '  i_itab1-werks INTO v_left_text
*                           SEPARATED BY space.
*  CONCATENATE 'Name  : ' i_itab1-name INTO v_right_text
*                           SEPARATED BY space.
*  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
*  CLEAR: v_left_text, v_right_text.
**--- Product
*  REFRESH: i_linkx_tmp.
*  CLEAR: i_linkx_tmp.
*  LOOP AT i_linkx INTO wa_linkx WHERE nomor = i_itab1-nomor.
*    APPEND wa_linkx TO i_linkx_tmp.
*    CLEAR: wa_linkx.
*  ENDLOOP.
*  DELETE ADJACENT DUPLICATES FROM i_linkx_tmp COMPARING plnbez charg.
*  IF i_linkx_tmp IS INITIAL.
*  ELSE.
*    CLEAR: v_product, l_plnbez.
*    l_sw = 0.
*    SORT i_linkx_tmp BY plnbez charg.
*    LOOP AT i_linkx_tmp INTO wa_linkx.
*      IF l_plnbez <> wa_linkx-plnbez.
*        CONCATENATE wa_linkx-maktx
*                     '('
*                     wa_linkx-plnbez
*                     ')'
*                     INTO v_product.
*        WRITE: /  '  Product : ', v_product .
*        WRITE: /  '  Batch   : '.
*        IF wa_linkx-charg IS INITIAL.
*        ELSE.
*          WRITE wa_linkx-charg.
*        ENDIF.
*      ELSE.
*        IF sy-colno < 72.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            IF sy-colno < 15.
*              WRITE wa_linkx-charg.
*            ELSE.
*              WRITE: ',', wa_linkx-charg.
*            ENDIF.
*          ENDIF.
*        ELSE.
*          WRITE: /  '            '.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            WRITE wa_linkx-charg.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*      l_plnbez = wa_linkx-plnbez.
*      CLEAR: wa_linkx.
*    ENDLOOP.
*  ENDIF.
*  CLEAR: v_left_text, v_right_text.
**--- Basic Start date
*  WRITE i_itab1-gstrp  TO ld_datum.
*  CONCATENATE 'Basic Start date : ' ld_datum INTO v_left_text
*                           SEPARATED BY space.
*  PERFORM f_hdr_pad_title1 USING    v_left_text '' v_right_text.
*
ENDFORM.                    " f_hdr_line4


*---------------------------------------------------------------------*
*       FORM f_hdr_pad_title1                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  V_LEFT_TEXT                                                   *
*  -->  V_MIDDLE_TEXT                                                 *
*  -->  V_RIGHT_TEXT                                                  *
*---------------------------------------------------------------------*
FORM f_hdr_pad_title1 USING v_left_text v_middle_text v_right_text.

  DATA:
      page_width TYPE i,       " Width of page
      middle_length TYPE i,    " Length of title text
      left_length TYPE i,      " Length of left text
      right_length TYPE i,     " Length of right text
      left_start TYPE i,       " Position on line for start of left tex
      middle_start TYPE i,     " Position on line for start of middl tex
      right_start TYPE i.      " Position on line for start of right tex


*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = STRLEN( v_middle_text ).
  COMPUTE left_length = STRLEN( v_left_text ).
  COMPUTE right_length = STRLEN( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_length = 20.
  right_start = sy-linsz - left_start - right_length - 1.
*  WRITE:/ sy-vline.
  WRITE: / ' '.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
*  WRITE AT sy-linsz sy-vline.
ENDFORM.                    " f_hdr_line4

*&---------------------------------------------------------------------*
*&      Form  F_PROD_ALLOC
*&---------------------------------------------------------------------*
FORM f_prod_alloc  USING fu_vkbur
                   CHANGING fc_kcqty.

  DATA: lt_zsloc2  LIKE zsloc2 OCCURS 0 WITH HEADER LINE.
  DATA: ld_labst   LIKE mard-labst.

  SELECT DISTINCT vkbur lgort
    FROM zsloc2
    INTO CORRESPONDING FIELDS OF TABLE lt_zsloc2
    WHERE vkbur EQ fu_vkbur AND
          lgort IN s_lgort.

  LOOP AT s_lgort.
*    read table lt_zsloc2 with key vkbur = fu_vkbur
*                                  lgort = s_lgort-low.
*    if sy-subrc eq 0.
    READ TABLE i_mard INTO wa_mard WITH
        KEY matnr = wa_s940-matnr
            werks = wa_s940-vkbur
            lgort = s_lgort-low
        BINARY SEARCH.
    IF sy-subrc NE 0.
      ld_labst  = 0.
    ELSE.
      ADD wa_mard-labst TO ld_labst.
    ENDIF.
*    endif.
  ENDLOOP.
  fc_kcqty = ld_labst - fc_kcqty.
ENDFORM.                    " F_PROD_ALLOC

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .
  IF upl IS NOT INITIAL.
    IF p_filenm IS INITIAL.
      PERFORM f_error_selection_screen USING 'UPL' '0'.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN onl.
      AUTHORITY-CHECK OBJECT 'ZM11_ONL'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        MESSAGE e000(zab) WITH 'You are not authorized'.
      ENDIF.
    WHEN upl.
      AUTHORITY-CHECK OBJECT 'ZM11_UPL'
                ID 'ACTVT' FIELD '01'.
      IF sy-subrc NE 0.
        MESSAGE e000(zab) WITH 'You are not authorized'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'You are not authorized'.
  ENDCASE.

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
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_VALUE_ON_REQUEST
*&---------------------------------------------------------------------*
FORM f_f4_value_on_request  CHANGING fc_filenm.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-repid
      dynpro_number = sy-dynnr
      field_name    = 'C:\'
    IMPORTING
      file_name     = fc_filenm.
ENDFORM.                    " F_F4_VALUE_ON_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_GET_UPLOAD_FILE
*&---------------------------------------------------------------------*
FORM f_get_upload_file .
  DATA : ls_upld    LIKE gt_upld,
         lt_tvkol   TYPE STANDARD TABLE OF tvkol,
         ls_tvkol   TYPE tvkol.

  DATA : lt_upld    LIKE gt_upld OCCURS 0 WITH HEADER LINE.
  DATA : lt_mara    TYPE STANDARD TABLE OF mara INITIAL SIZE 0
                    WITH HEADER LINE.
  DATA : BEGIN OF lv_month,
           year(4),
           month(2),
         END OF lv_month.

  SELECT *
    FROM tvkol
    INTO CORRESPONDING FIELDS OF TABLE lt_tvkol.

  CLEAR : gt_excel[], gt_excel, gv_message.

  IF p_filenm IS NOT INITIAL.
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = p_filenm
        i_begin_col             = 1
        i_begin_row             = 2
        i_end_col               = 75
        i_end_row               = 65000
      TABLES
        intern                  = gt_excel
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CASE 'X'.
      WHEN p_ptt.
        SORT gt_excel BY row col.
        LOOP AT gt_excel.
          CASE gt_excel-col.
            WHEN '0001'.
              CONCATENATE gt_excel-value+3(4) gt_excel-value(2) INTO ls_upld-spmon.
            WHEN '0002'.
              ls_upld-vkorg       = gt_excel-value.
            WHEN '0003'.
              ls_upld-werks       = gt_excel-value.
            WHEN '0004'.
              ls_upld-lgort       = gt_excel-value.
            WHEN '0005'.
              ls_upld-matnr       = gt_excel-value.
            WHEN '0006'.
              ls_upld-kcqty       = gt_excel-value.
            WHEN '0007'.
              ls_upld-basme       = gt_excel-value.
          ENDCASE.
          AT END OF row.
            READ TABLE lt_tvkol INTO ls_tvkol
                                WITH KEY werks = ls_upld-werks
                                         lgort = ls_upld-lgort.
            IF sy-subrc = 0.
              ls_upld-vkbur = ls_tvkol-vstel.
            ENDIF.
            APPEND ls_upld TO gt_upld.
            CLEAR : ls_upld, ls_tvkol.
          ENDAT.
        ENDLOOP.

      WHEN p_tdn.
        SORT gt_excel BY row col.
        LOOP AT gt_excel.
          CASE gt_excel-col.
            WHEN '0001'.
              ls_upld-vkorg       = gt_excel-value.
            WHEN '0002'.
              CONCATENATE gt_excel-value+3(4) gt_excel-value(2) INTO ls_upld-spmon.
            WHEN '0003'.
              ls_upld-vkbur       = gt_excel-value.
            WHEN '0004'.
              ls_upld-matnr       = gt_excel-value.
            WHEN '0005'.
              ls_upld-kcqty       = gt_excel-value.
            WHEN '0006'.
              ls_upld-basme       = gt_excel-value.
          ENDCASE.
          AT END OF row.
            READ TABLE lt_tvkol INTO ls_tvkol
                                WITH KEY vstel = ls_upld-vkbur.
            IF sy-subrc = 0.
              ls_upld-werks = ls_tvkol-werks.
              ls_upld-lgort = ls_tvkol-lgort.
            ENDIF.
            APPEND ls_upld TO gt_upld.
            CLEAR : ls_upld, ls_tvkol.
          ENDAT.
        ENDLOOP.
    ENDCASE.
  ENDIF.

  lt_upld[] = gt_upld[].
  SORT lt_upld BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_upld COMPARING matnr.
  IF lt_upld[] IS NOT INITIAL.
    SELECT matnr meins
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_upld
      WHERE matnr = lt_upld-matnr.
  ENDIF.

  CLEAR ls_upld.
  LOOP AT gt_upld INTO ls_upld.
    IF ls_upld-spmon LT sy-datum(6).
      gv_message = 'Period LT current month'.   "Tidak boleh bulan sebelumnya
      EXIT.
    ENDIF.

    CLEAR lv_month.
    IF lv_month-year LT '2022'.                 "Validasi Periode
      CONTINUE.
    ELSEIF lv_month-month LT '01' OR lv_month-month GT '12'.
      CONTINUE.
    ENDIF.

    READ TABLE lt_mara WITH KEY matnr = ls_upld-matnr.
    IF sy-subrc = 0.
      IF ls_upld-basme IS INITIAL.
        ls_upld-basme = lt_mara-meins.
      ELSEIF ls_upld-basme <> lt_mara-meins.
        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input                = ls_upld-kcqty
            unit_in              = ls_upld-basme
            unit_out             = lt_mara-meins
          IMPORTING
            output               = ls_upld-kcqty
          EXCEPTIONS
            conversion_not_found = 1
            division_by_zero     = 2
            input_invalid        = 3
            output_invalid       = 4
            overflow             = 5
            type_invalid         = 6
            units_missing        = 7
            unit_in_not_found    = 8
            unit_out_not_found   = 9
            OTHERS               = 10.
      ENDIF.
      MODIFY gt_upld FROM ls_upld TRANSPORTING basme kcqty.
      CLEAR ls_upld.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_UPLOAD_FILE

*&---------------------------------------------------------------------*
*&      Form  F_GET_EXISTING_S940
*&---------------------------------------------------------------------*
FORM f_get_existing_s940 .
  DATA : lt_s940e TYPE STANDARD TABLE OF s940e INITIAL SIZE 0
                  WITH HEADER LINE,
         ls_s940e TYPE s940e.

  IF gt_upld[] IS NOT INITIAL.
    SELECT *
      FROM s940
      INTO CORRESPONDING FIELDS OF TABLE gt_s940
      FOR ALL ENTRIES IN gt_upld
      WHERE vrsio = co_vrsio
        AND spmon = gt_upld-spmon
        AND sptag = co_sptag
        AND spwoc = co_spwoc
        AND spbup = co_spbup
        AND konob = co_konob
        AND vkorg = gt_upld-vkorg
        AND vtweg = co_vtweg
*        AND vkbur = gt_upld-vkbur
        AND matnr = gt_upld-matnr.
  ENDIF.

  IF gt_upld[] IS NOT INITIAL.
    SELECT *
      FROM s940e
      INTO CORRESPONDING FIELDS OF TABLE lt_s940e
      FOR ALL ENTRIES IN gt_upld
      WHERE konob = co_konob
        AND vkorg = gt_upld-vkorg
        AND vtweg = co_vtweg
        AND vkbur = gt_upld-vkbur
        AND matnr = gt_upld-matnr.
  ENDIF.

  LOOP AT gt_upld.
    READ TABLE lt_s940e WITH KEY konob = co_konob
                                 vkorg = gt_upld-vkorg
                                 vtweg = co_vtweg
                                 vkbur = gt_upld-vkbur
                                 matnr = gt_upld-matnr.
    IF sy-subrc <> 0.
      gv_subrc  = 8.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_EXISTING_S940

*&---------------------------------------------------------------------*
*&      Form  F_GET_ENDING_STOCK_MATERIAL
*&---------------------------------------------------------------------*
FORM f_get_ending_stock_material .
  IF gt_upld[] IS NOT INITIAL.
    SELECT matnr werks lgort labst
        INTO CORRESPONDING FIELDS OF TABLE gt_mard
        FROM mard
        FOR ALL ENTRIES IN gt_upld
        WHERE werks = gt_upld-werks
          AND matnr = gt_upld-matnr
*          AND lgort = gt_upld-lgort
          AND lgort IN ('1000','1001')
          AND labst <> 0.
  ENDIF.
ENDFORM.                    " F_GET_ENDING_STOCK_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_OUTSTANDING_STOCK_AKHIR
*&---------------------------------------------------------------------*
FORM f_outstanding_stock_akhir .
  DATA : lv_omeng   LIKE vbbe-omeng,
         ls_mard    TYPE mard.

  DATA : lt_vbbe    TYPE STANDARD TABLE OF vbbe,
         ls_vbbe    TYPE vbbe.

  IF gt_mard[] IS NOT INITIAL.
    SELECT vbeln posnr etenr matnr werks lgort omeng
      FROM vbbe
      INTO CORRESPONDING FIELDS OF TABLE gt_vbbe
      FOR ALL ENTRIES IN gt_mard
        WHERE matnr = gt_mard-matnr
          AND werks = gt_mard-werks
          AND lgort = gt_mard-lgort
          AND vbtyp = 'J'.

    SORT gt_vbbe BY matnr werks lgort.
    LOOP AT gt_vbbe INTO wa_vbbe.
      ls_vbbe-matnr  = wa_vbbe-matnr.
      ls_vbbe-werks  = wa_vbbe-werks.
      ls_vbbe-lgort  = wa_vbbe-lgort.
      ls_vbbe-omeng  = wa_vbbe-omeng.
      COLLECT ls_vbbe INTO lt_vbbe.
      CLEAR ls_vbbe.
    ENDLOOP.
  ENDIF.

  SORT gt_mard BY matnr werks lgort.
  SORT lt_vbbe BY matnr werks lgort.

  CLEAR : ls_mard, ls_vbbe.
  LOOP AT gt_mard INTO ls_mard.
    CLEAR : lv_omeng.
    READ TABLE lt_vbbe INTO ls_vbbe
                       WITH KEY matnr = ls_mard-matnr
                                werks = ls_mard-werks
                                lgort = ls_mard-lgort
                       BINARY SEARCH.
    IF sy-subrc = 0.
      ls_mard-labst = ls_mard-labst - ls_vbbe-omeng.
      MODIFY gt_mard FROM ls_mard TRANSPORTING labst.
    ENDIF.
    CLEAR : ls_mard, ls_vbbe.
  ENDLOOP.
ENDFORM.                    " F_OUTSTANDING_STOCK_AKHIR

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_S940
*&---------------------------------------------------------------------*
FORM f_modify_s940 .
  DATA : ls_s940  TYPE s940,
         ls_mard  TYPE mard,
         lv_labst TYPE labst,
         lv_buchm TYPE buchm,
         lv_mkabest TYPE mc_mkabest,
         lv_kcqty TYPE kcqty.

  SORT gt_mard BY matnr werks.
  SORT gt_upld BY spmon vkorg vkbur matnr.
  SORT gt_s940 BY spmon vkorg vtweg vkbur konob kvgr5 matnr vrsio spwoc spbup.

  CASE 'X'.
    WHEN p_ptt.
      LOOP AT gt_upld.
* Input data for KA
        READ TABLE gt_s940 INTO ls_s940 WITH KEY spmon = gt_upld-spmon
                                                 vkorg = gt_upld-vkorg
                                                 vtweg = co_vtweg
                                                 vkbur = gt_upld-vkbur
                                                 konob = co_konob
                                                 kvgr5 = co_kvgr5
                                                 matnr = gt_upld-matnr
                                                 vrsio = co_vrsio
                                                 spwoc = co_spwoc
                                                 spbup = co_spbup
                                        BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_s940-kcqty   = gt_upld-kcqty.
        ELSE.
          ls_s940-basme   = gt_upld-basme.
          ls_s940-konob   = co_konob.
          ls_s940-vkorg   = gt_upld-vkorg.
          ls_s940-vtweg   = co_vtweg.
          ls_s940-spwoc   = co_spwoc.
          ls_s940-spbup   = co_spbup.
          ls_s940-vrsio   = co_vrsio.
          ls_s940-spmon   = gt_upld-spmon.
          ls_s940-vkbur   = gt_upld-vkbur.
          ls_s940-matnr   = gt_upld-matnr.
          ls_s940-kvgr5   = co_kvgr5.
          ls_s940-kcqty   = gt_upld-kcqty.
          ls_s940-kltbk   = gt_upld-kcqty.
          ls_s940-aemenge = 0.
        ENDIF.
        APPEND ls_s940 TO gt_out.
        CLEAR ls_s940.

* Input data for ###
        READ TABLE gt_s940 INTO ls_s940 WITH KEY spmon = gt_upld-spmon
                                                 vkorg = gt_upld-vkorg
                                                 vtweg = co_vtweg
                                                 vkbur = gt_upld-vkbur
                                                 konob = co_konob
                                                 kvgr5 = '###'
                                                 matnr = gt_upld-matnr
                                                 vrsio = co_vrsio
                                                 spwoc = co_spwoc
                                                 spbup = co_spbup
                                        BINARY SEARCH.
        IF sy-subrc EQ 0.
        ELSE.
          ls_s940-basme   = gt_upld-basme.
          ls_s940-konob   = co_konob.
          ls_s940-vkorg   = gt_upld-vkorg.
          ls_s940-vtweg   = co_vtweg.
          ls_s940-spwoc   = co_spwoc.
          ls_s940-spbup   = co_spbup.
          ls_s940-vrsio   = co_vrsio.
          ls_s940-spmon   = gt_upld-spmon.
          ls_s940-vkbur   = gt_upld-vkbur.
          ls_s940-matnr   = gt_upld-matnr.
          ls_s940-kvgr5   = '###'.
          ls_s940-kcqty   = gt_upld-kcqty.
          ls_s940-kltbk   = gt_upld-kcqty.
          ls_s940-aemenge = 0.
        ENDIF.

*    CLEAR ls_mard.
*    READ TABLE gt_mard INTO ls_mard WITH KEY matnr = ls_s940-matnr
*                                             werks = gt_upld-werks
*                                             lgort = gt_upld-lgort
*                                    BINARY SEARCH.
*    IF sy-subrc = 0.
*      ls_s940-kcqty = ls_mard-labst - gt_upld-kcqty.
*    ELSE.
*      ls_s940-kcqty = ls_mard-labst - gt_upld-kcqty.
*    ENDIF.
        CLEAR lv_labst.
        LOOP AT gt_mard INTO ls_mard WHERE matnr = ls_s940-matnr
                                       AND werks = gt_upld-werks.
          lv_labst = lv_labst + ls_mard-labst.
        ENDLOOP.
        ls_s940-kcqty = lv_labst - gt_upld-kcqty.
        ls_s940-kltbk = ls_s940-kcqty.

        APPEND ls_s940 TO gt_out.
        CLEAR ls_s940.
      ENDLOOP.

    WHEN p_tdn.
      LOOP AT gt_upld.
* Input data for KA
*        READ TABLE gt_s940 INTO ls_s940 WITH KEY spmon = gt_upld-spmon
*                                                 vkorg = gt_upld-vkorg
*                                                 vtweg = co_vtweg
*                                                 vkbur = gt_upld-vkbur
*                                                 konob = co_konob
*                                                 kvgr5 = co_kvgr5
*                                                 matnr = gt_upld-matnr
*                                                 vrsio = co_vrsio
*                                                 spwoc = co_spwoc
*                                                 spbup = co_spbup
*                                        BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          IF gt_upld-kcqty LT ls_s940-buchm.
*            CONTINUE.
*          ELSE.
*            ls_s940-buchm   = gt_upld-kcqty.
*          ENDIF.
*        ELSE.
*          ls_s940-basme   = gt_upld-basme.
*          ls_s940-konob   = co_konob.
*          ls_s940-vkorg   = gt_upld-vkorg.
*          ls_s940-vtweg   = co_vtweg.
*          ls_s940-spwoc   = co_spwoc.
*          ls_s940-spbup   = co_spbup.
*          ls_s940-vrsio   = co_vrsio.
*          ls_s940-spmon   = gt_upld-spmon.
*          ls_s940-vkbur   = gt_upld-vkbur.
*          ls_s940-matnr   = gt_upld-matnr.
*          ls_s940-kvgr5   = co_kvgr5.
**          ls_s940-kcqty   = gt_upld-kcqty.
**          ls_s940-kltbk   = gt_upld-kcqty.
*          ls_s940-buchm   = gt_upld-kcqty.
*          ls_s940-aemenge = 0.
*        ENDIF.
*        APPEND ls_s940 TO gt_out.
*        CLEAR ls_s940.

* Input data for ###
        CLEAR: ls_s940,lv_labst,lv_buchm,lv_kcqty.
        READ TABLE gt_s940 INTO ls_s940 WITH KEY spmon = gt_upld-spmon
                                                 vkorg = gt_upld-vkorg
                                                 vtweg = co_vtweg
                                                 vkbur = gt_upld-vkbur
                                                 konob = co_konob
                                                 kvgr5 = '###'
                                                 matnr = gt_upld-matnr
                                                 vrsio = co_vrsio
                                                 spwoc = co_spwoc
                                                 spbup = co_spbup
                                        BINARY SEARCH.
        IF sy-subrc EQ 0.
*          IF gt_upld-kcqty LT ls_s940-buchm.    "Koreksi qty Alloc tdk boleh lebih kecil
*            CONTINUE.
*          ENDIF.
          lv_buchm        = ls_s940-buchm.
          lv_mkabest      = ls_s940-mkabest.
          ls_s940-buchm   = gt_upld-kcqty.
          ls_s940-mkabest = 0.
        ELSE.
          ls_s940-basme   = gt_upld-basme.
          ls_s940-konob   = co_konob.
          ls_s940-vkorg   = gt_upld-vkorg.
          ls_s940-vtweg   = co_vtweg.
          ls_s940-spwoc   = co_spwoc.
          ls_s940-spbup   = co_spbup.
          ls_s940-vrsio   = co_vrsio.
          ls_s940-spmon   = gt_upld-spmon.
          ls_s940-vkbur   = gt_upld-vkbur.
          ls_s940-matnr   = gt_upld-matnr.
          ls_s940-kvgr5   = '###'.
*          ls_s940-kcqty   = gt_upld-kcqty.
*          ls_s940-kltbk   = gt_upld-kcqty.
          ls_s940-buchm   = gt_upld-kcqty.
          ls_s940-aemenge = 0.
        ENDIF.

*        LOOP AT gt_mard INTO ls_mard WHERE matnr = ls_s940-matnr
*                                       AND werks = gt_upld-werks.
*          lv_labst = lv_labst + ls_mard-labst.
*        ENDLOOP.
*        lv_labst = lv_labst - ls_s940-aemenge.
*
*        IF lv_labst GE ls_s940-buchm.
*          ls_s940-mkabest = ls_s940-buchm.
*          ls_s940-kcqty = lv_labst - ls_s940-buchm.
*        ELSE.
*          ls_s940-mkabest = lv_labst.
*          ls_s940-kcqty = ls_s940-aemenge.
*        ENDIF.

        lv_kcqty = ls_s940-kcqty - ls_s940-aemenge.

        IF lv_kcqty GE ls_s940-buchm.
          ls_s940-mkabest = ls_s940-buchm.
          ls_s940-kcqty = lv_kcqty - ls_s940-buchm.
        ELSEIF lv_kcqty LE 0.
          ls_s940-mkabest = 0.
        ELSE.
          ls_s940-mkabest = lv_kcqty.
          ls_s940-kcqty = ls_s940-aemenge.
        ENDIF.

        IF lv_buchm IS NOT INITIAL.
          ADD lv_buchm TO ls_s940-buchm.
        ENDIF.

        IF lv_mkabest IS NOT INITIAL.
          ADD lv_mkabest TO ls_s940-mkabest.
        ENDIF.

        MOVE-CORRESPONDING ls_s940 TO gt_out.
        APPEND gt_out.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_S940

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS 'PF100' EXCLUDING '&POS'.

  SET TITLEBAR 'TITLE'.

  PERFORM f_excluding_toolbar.

ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar .
  DATA : ls_exclude   TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO gs_exclude.
  CLEAR ls_exclude.
ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Module  DOCKING_AND_SPLIT_CONTAINER  OUTPUT
*&---------------------------------------------------------------------*
MODULE docking_and_split_container OUTPUT.
  DATA : lv_contname(20).

  lv_contname   = 'CC_OUT'.

  IF g_outcont IS INITIAL.
    CREATE OBJECT g_outcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_outcont
        rows    = 1
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_container.
  ENDIF.
ENDMODULE.                 " DOCKING_AND_SPLIT_CONTAINER  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  OUT  OUTPUT
*&---------------------------------------------------------------------*
MODULE out OUTPUT.
*  IF g_outgrid IS INITIAL.
*    CREATE OBJECT event_receiver.
*
*    CREATE OBJECT g_outgrid
*      EXPORTING
*        i_appl_events = selected
*        i_parent      = g_outcont.
*
*    PERFORM f_build_fieldcat.
*    PERFORM f_build_layout.
*    PERFORM f_build_sort_tab.
*
*    gs_variant-report = gv_repid.
*
*    SET HANDLER event_receiver->handle_user_command
*                event_receiver->handle_menu_button
*                event_receiver->handle_toolbar
*                event_receiver->handle_data_changed FOR g_outgrid.
*
*    CALL METHOD g_outgrid->set_table_for_first_display
*      EXPORTING
*        is_layout            = gs_layout_alv
*        i_save               = 'A'
*        is_variant           = gs_variant
*        i_default            = 'X'
*        it_toolbar_excluding = gs_exclude
*      CHANGING
*        it_sort              = gt_sort_grid[]
*        it_outtab            = gt_out[]
*        it_fieldcatalog      = gt_fieldcat[].
*
*    CALL METHOD cl_gui_control=>set_focus
*      EXPORTING
*        control = g_outgrid.
*
*    CALL METHOD cl_gui_cfw=>flush.
*  ENDIF.
*
*  PERFORM f_alv_refresh.
ENDMODULE.                 " OUT  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SEND_API
*&---------------------------------------------------------------------*
FORM f_send_api .
  DATA: lt_out LIKE TABLE OF gt_out WITH HEADER LINE,
        lt_mat LIKE TABLE OF mara,
        ls_mat LIKE LINE OF lt_mat.

  DATA: lv_status  TYPE char1,
        lv_message TYPE char100.

  IF upl = 'X' AND p_tdn = 'X'.
    lt_out[] = gt_out[].
    SORT gt_out BY vkbur matnr.
    SORT lt_out BY vkbur.
    DELETE ADJACENT DUPLICATES FROM lt_out COMPARING vkbur.

    LOOP AT lt_out.
      CLEAR: lt_mat,ls_mat.
      LOOP AT gt_out WHERE vkbur = lt_out-vkbur.
        ls_mat-matnr = gt_out-matnr.
        COLLECT ls_mat INTO lt_mat.
      ENDLOOP.

      CALL FUNCTION 'ZTDNSD_F0003'
        EXPORTING
          proses       = 'TDN_TRD'
          sales_office = lt_out-vkbur
          periode      = lt_out-spmon
          api          = ' '
        IMPORTING
          status       = lv_status
          MESSAGE      = lv_message
        TABLES
          t_material   = lt_mat.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SEND_API
