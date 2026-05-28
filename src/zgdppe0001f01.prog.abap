*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.
  CLEAR: v_ind_save, va_ctr.
  REFRESH: i_itab, i_itab1, i_itab2, i_caufv, i_afpo, i_resb,
           i_matnr, i_mard, i_itab_tmp, i_zgdppdt0001, i_link,
           i_bapiresbc, i_linkx, i_linkx_tmp, i_marc, i_makt.
  FREE:    i_itab, i_itab1, i_itab2, i_caufv, i_afpo, i_resb,
           i_matnr, i_mard, i_itab_tmp, i_zgdppdt0001, i_link,
           i_bapiresbc, i_linkx, i_linkx_tmp, i_marc, i_makt.
  CLEAR:   i_itab, i_itab1, i_itab2, i_caufv, i_afpo, i_resb,
           i_matnr, i_mard, i_itab_tmp, i_zgdppdt0001, i_link,
           i_bapiresbc, i_linkx, i_linkx_tmp, i_marc, i_makt, wa_linkx,
           wa_itab, wa_itab1, wa_itab2, wa_caufv, wa_afpo, wa_resb,
           wa_matnr, wa_mard, wa_zgdppdt0001, wa_link, wa_bapiresbc.

  IF option = 3.
    SELECT SINGLE name1
      FROM t001w
      INTO gv_name1
      WHERE werks = p_werks.

    SELECT SINGLE lgobe
      FROM t001l
      INTO gv_lgobe
      WHERE werks = p_werks
        AND lgort = p_lgort.

    SELECT SINGLE lgobe
      FROM t001l
      INTO gv_umlbe
      WHERE werks = p_werks
        AND lgort = p_umlgo.
  ENDIF.

  gv_old  = 'X'.
ENDFORM.                    "f_init_data


*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : l_sw(1).

  DATA : ls_caufv   LIKE LINE OF gt_caufv,
         lv_field   TYPE vrm_id,
         ls_values  TYPE vrm_value,
         lv_key(12),
         lv_aufnr(12).

  DATA : lt_resb    TYPE ta_resb OCCURS 0,
         ls_resb    LIKE LINE OF i_resb.

  CASE option.
    WHEN 1.
***comment by Rahmadi: Sebisa mungkin jangan select *, krn field CAUFV
***banyuak banget
      SELECT *
        FROM caufv
        INTO CORRESPONDING FIELDS OF TABLE i_caufv
        WHERE aufnr  IN s_aufnr AND
              autyp  EQ '40' AND
              werks  EQ p_werks AND
              plnbez IN s_plnbez AND
              fevor  IN s_fevor AND
              gstrp  IN s_gstrp.

      DELETE i_caufv WHERE plnbez = space.
      DELETE i_caufv WHERE plnbez IS INITIAL.
* add by MKO to improve performance
      DELETE i_caufv WHERE idat2 <> '00000000'.
      DELETE i_caufv WHERE loekz = 'X'.
* end add
      SELECT * FROM zgdppdt0001
        INTO CORRESPONDING FIELDS OF TABLE i_zgdppdt0001
        FOR ALL ENTRIES IN i_caufv
            WHERE aufnr = i_caufv-aufnr AND
                  nctrl <> 'C'.
      SORT i_zgdppdt0001  BY aufnr matnr.
      CLEAR: l_sw.
      LOOP AT i_caufv INTO wa_caufv.
        IF wa_caufv-plnbez IS INITIAL.
          DELETE i_caufv.
          CONTINUE.
        ENDIF.
        SORT i_zgdppdt0001 BY aufnr matnr fevor mtart lgort. "binary search harus di sort 21-May-2007
        READ TABLE i_zgdppdt0001 INTO wa_zgdppdt0001 WITH
            KEY aufnr = wa_caufv-aufnr
                matnr = wa_caufv-plnbez
                fevor = wa_caufv-fevor
                mtart = p_mtart
                lgort = p_lgort
            BINARY SEARCH.
        IF sy-subrc EQ 0.
          DELETE i_caufv.
          CONTINUE.
        ENDIF.
        SELECT SINGLE * FROM jest
               WHERE objnr = wa_caufv-objnr AND
                     ( stat  = 'I0001' OR stat  = 'I0002' ).
        IF sy-subrc EQ 0.
          CONTINUE.
        ELSE.
          DELETE i_caufv.
        ENDIF.
*      CALL FUNCTION 'STATUS_TEXT_EDIT'
*           EXPORTING
*                objnr            = wa_caufv-objnr
*                spras            = sy-langu
*           IMPORTING
*                line             = wa_caufv-sttxt
*                user_line        = wa_caufv-sttxt
*           EXCEPTIONS
*                object_not_found = 1.
*****Comment by Rahmadi: mendingan search pake pattern? CP *REL*
*****krn posisi bisa di mana aja
*      IF wa_caufv-sttxt(3) = 'REL'.
*        MODIFY i_caufv FROM wa_caufv.
*      ELSE.
*        DELETE i_caufv.
*      ENDIF.
      ENDLOOP.

      IF i_caufv[] IS INITIAL.
        EXIT.
      ENDIF.

      SELECT * FROM afpo AS a JOIN makt AS b ON b~matnr = a~matnr
                              JOIN mara AS c ON c~matnr = a~matnr
        INTO CORRESPONDING FIELDS OF TABLE i_afpo
        FOR ALL ENTRIES IN i_caufv
            WHERE a~aufnr = i_caufv-aufnr AND
*****comment by Rahmadi: 'e' apa 'E' yah? di language artinya beda
                  ( b~spras = 'e' OR b~spras = 'EN' ).

*****comment by Rahmadi: JOIN nya jangan banyak-banyak - max 2 join aja
*****suggestion: MARA~MARC aja yg di-join trus buat select all entries
*****di RESB & MAKT
*****ALL ENTRIES harus pakai KEY, AUFNR tidak bisa dipakai utk RESB
*****krn bukan key ataupun index di RESB
*****mau rundingan dulu sama Dedy apakah ada link lain, kalo tidak ada
*****mungkin kepaksa harus bikin index baru

      IF i_caufv[] IS NOT INITIAL.
        PERFORM f_get_operation_detail.

        SELECT a~rsnum a~aufnr a~matnr a~aufnr a~charg a~werks
               a~lgort a~bdter a~vornr
               a~bdmng a~meins a~baugr a~objnr b~maktx c~mtart c~matkl
          FROM resb AS a JOIN makt AS b ON b~matnr = a~matnr
                         JOIN mara AS c ON c~matnr = a~matnr
          INTO CORRESPONDING FIELDS OF TABLE i_resb
          FOR ALL ENTRIES IN i_caufv
              WHERE a~aufnr = i_caufv-aufnr AND
                    a~werks = p_werks AND
                    a~lgort = p_lgort AND
                    b~spras = sy-langu AND
                    c~mtart = p_mtart.

        PERFORM f_cek_operation_detail.
      ENDIF.

      APPEND LINES OF i_resb TO i_matnr.
      SORT i_matnr BY matnr werks lgort.
      DELETE ADJACENT DUPLICATES FROM i_matnr
            COMPARING ALL FIELDS.

      IF i_matnr[] IS NOT INITIAL.
        IF p_werks = '0101' OR
          p_werks = '0102'.
          SELECT matnr werks FROM marc
            INTO CORRESPONDING FIELDS OF TABLE i_marc
            FOR ALL ENTRIES IN i_matnr
                WHERE matnr = i_matnr-matnr AND
                      werks = i_matnr-werks AND
                      bstrf NE 0.
        ELSE.
          SELECT matnr werks bstrf  FROM marc
            INTO CORRESPONDING FIELDS OF TABLE i_marc
            FOR ALL ENTRIES IN i_matnr
                WHERE matnr = i_matnr-matnr AND
                      werks = i_matnr-werks AND
                      bstrf NE 0.
        ENDIF.
      ENDIF.

      REFRESH: i_aufnr.
      CLEAR: i_aufnr.
      SELECT werks aufnr mtart fevor FROM zgdppdt0001
        INTO CORRESPONDING FIELDS OF TABLE i_aufnr
            WHERE  werks = p_werks AND
                   lgort = p_lgort AND
                   nctrl <> 'C'.
      IF i_matnr[] IS INITIAL.
        SELECT * FROM mard
          INTO CORRESPONDING FIELDS OF TABLE i_mard
          FOR ALL ENTRIES IN i_matnr
              WHERE matnr = i_matnr-matnr AND
                    werks = i_matnr-werks AND
                    lgort = p_lgort AND
                    labst NE 0.
        EXIT.
      ELSE.
****comment by Rahmadi
*****ALL ENTRIES harus pakai KEY, AUFNR tidak bisa dipakai utk RESB
*****mau rundingan dulu sama Dedy apakah ada link lain, kalo tidak ada
*****mungkin kepaksa harus bikin index baru
        IF i_aufnr[] IS NOT INITIAL.
          SELECT a~matnr a~bdmng  b~mtart FROM resb AS a
               JOIN mara AS b ON a~matnr = b~matnr
               INTO TABLE i_resbstock
               FOR ALL ENTRIES IN i_aufnr
               WHERE a~aufnr = i_aufnr-aufnr AND
                     a~werks = i_aufnr-werks AND
*                 A~FEVOR = I_AUFNR-FEVOR AND
                     a~kzear NE 'X' AND
                     a~xloek NE 'X'.
        ENDIF.

        SORT i_resbstock BY matnr.

        IF i_matnr[] IS NOT INITIAL.
          SELECT * FROM mard AS a JOIN mara AS b ON a~matnr = b~matnr
            INTO CORRESPONDING FIELDS OF TABLE i_mard
            FOR ALL ENTRIES IN i_matnr
                WHERE a~matnr = i_matnr-matnr AND
                      a~werks = i_matnr-werks AND
                      a~lgort = p_lgort AND
                      a~labst NE 0 AND
                      b~mtart = p_mtart.
        ENDIF.

*        LOOP AT i_mard INTO wa_mard.
*          IF wa_mard-mtart = p_mtart.
*            LOOP AT i_resbstock INTO wa_resbstock
*                     WHERE matnr = wa_mard-matnr AND
*                           mtart = wa_mard-mtart.
*              IF wa_mard-labst >= wa_resbstock-bdmng.
*                wa_mard-labst = wa_mard-labst - wa_resbstock-bdmng.
*              ELSE.
*                wa_mard-labst = 0.
*                EXIT.
*              ENDIF.
*            ENDLOOP.
*
*            IF wa_mard-labst = 0.
*              DELETE i_mard.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.
      ENDIF.

      IF i_mard[] IS NOT INITIAL.
        SELECT matnr werks lgort charg clabs
          FROM mchb
          INTO CORRESPONDING FIELDS OF TABLE gt_mchb
          FOR ALL ENTRIES IN i_mard
          WHERE matnr = i_mard-matnr
            AND werks = i_mard-werks
            AND lgort = p_lgort
            AND clabs <> 0.
      ENDIF.

      PERFORM f_reservation.
      PERFORM f_tambah_stock USING 'LGORT'.
      PERFORM f_calculate_stock USING 'LGORT'.

      PERFORM f_reservation_311.
      PERFORM f_tambah_stock USING 'UMLGO'.
      PERFORM f_calculate_stock USING 'UMLGO'.

      CLEAR lt_resb[].
      SORT i_resb BY aufnr matnr.
      LOOP AT i_resb INTO ls_resb.
        CLEAR ls_resb-objnr.
        COLLECT ls_resb INTO lt_resb.
        CLEAR ls_resb.
      ENDLOOP.
      i_resb[] = lt_resb[].

    WHEN 2.
      IF radio1 = 'X'  OR radio3 = 'X'.
        IF radio1 = 'X'.
          SELECT * FROM zgdppdt0001
            INTO CORRESPONDING FIELDS OF TABLE i_zgdppdt0001
                WHERE werks = p_werks AND
                      rsnum IN s_rsnum AND
                      gstrp IN s_gstrp1 AND
*                      lgort = p_lgort AND
                      nctrl <> 'C'.
        ELSE.
          SELECT * FROM zgdppdt0001
            INTO CORRESPONDING FIELDS OF TABLE i_zgdppdt0001
                WHERE werks = p_werks AND
                      rsnum IN s_rsnum1 AND
*                      lgort = p_lgort AND
                      nctrl <> 'C'.
        ENDIF.
        LOOP AT i_zgdppdt0001 INTO wa_zgdppdt0001.
          wa_link-rsnum = wa_zgdppdt0001-rsnum.
          wa_matnr-matnr = wa_zgdppdt0001-matnr.
          APPEND wa_link TO i_link.
          APPEND wa_matnr TO i_matnr.
          CLEAR: wa_zgdppdt0001.
        ENDLOOP.
        DELETE ADJACENT DUPLICATES FROM i_link
             COMPARING rsnum.
        DELETE ADJACENT DUPLICATES FROM i_matnr
             COMPARING matnr.

        IF i_matnr[] IS NOT INITIAL.
          SELECT a~matnr a~maktx c~mtart FROM makt AS a
                               JOIN mara AS c ON c~matnr = a~matnr
            INTO CORRESPONDING FIELDS OF TABLE i_makt
            FOR ALL ENTRIES IN i_matnr
                WHERE a~matnr = i_matnr-matnr AND
                          ( spras = 'e' OR spras = 'EN' ).
        ENDIF.

        IF i_link[] IS NOT INITIAL.
          SELECT a~rsnum a~aufnr a~matnr a~aufnr a~charg a~werks
                 a~lgort a~bdter
                 a~bdmng a~meins a~baugr a~objnr a~sgtxt b~maktx "c~bstrf
            FROM resb AS a JOIN makt AS b ON b~matnr = a~matnr
            INTO CORRESPONDING FIELDS OF TABLE i_itab
            FOR ALL ENTRIES IN i_link
                WHERE a~rsnum = i_link-rsnum AND
                      a~werks = p_werks AND
                      a~lgort = p_umlgo AND
                      ( b~spras = 'e' OR b~spras = 'EN' ).
        ENDIF.
      ENDIF.

      IF radio2 = 'X'.
        SELECT * FROM zgdppdt0001
          INTO CORRESPONDING FIELDS OF TABLE i_zgdppdt0001
              WHERE werks = p_werks AND
                    rsnum = p_rsnum AND
*                    lgort = p_lgort AND
                    nctrl <> 'C'.

        IF i_zgdppdt0001[] IS NOT INITIAL.
          IF p_werks = '0101' OR p_werks = '0102'.
            PERFORM f_additional_data_for_cancel.
          ENDIF.
        ENDIF.

        IF p_werks = '0101' OR p_werks = '0102' OR
           p_werks = '0901'.
          LOOP AT i_zgdppdt0001 INTO wa_zgdppdt0001.
            wa_link-rsnum = wa_zgdppdt0001-rsnum.
            wa_matnr-matnr = wa_zgdppdt0001-matnr.
            APPEND wa_link TO i_link.
            APPEND wa_matnr TO i_matnr.
            CLEAR: wa_zgdppdt0001.
          ENDLOOP.
          DELETE ADJACENT DUPLICATES FROM i_link
               COMPARING rsnum.
          DELETE ADJACENT DUPLICATES FROM i_matnr
               COMPARING matnr.

          IF i_matnr[] IS NOT INITIAL.
            SELECT a~matnr a~maktx c~mtart FROM makt AS a
                                 JOIN mara AS c ON c~matnr = a~matnr
              INTO CORRESPONDING FIELDS OF TABLE i_makt
              FOR ALL ENTRIES IN i_matnr
                  WHERE a~matnr = i_matnr-matnr AND
                            ( spras = 'e' OR spras = 'EN' ).
          ENDIF.

          IF i_link[] IS NOT INITIAL.
            SELECT a~rsnum a~aufnr a~matnr a~aufnr a~charg a~werks
                   a~lgort a~bdter
                   a~bdmng a~meins a~baugr a~objnr a~sgtxt b~maktx "c~bstrf
              FROM resb AS a JOIN makt AS b ON b~matnr = a~matnr
              INTO CORRESPONDING FIELDS OF TABLE i_itab
              FOR ALL ENTRIES IN i_link
                  WHERE a~rsnum = i_link-rsnum AND
                        a~werks = p_werks AND
                        a~lgort = p_umlgo AND
                        ( b~spras = 'e' OR b~spras = 'EN' ).
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 3.
      SELECT *
        FROM caufv
        INTO CORRESPONDING FIELDS OF TABLE gt_caufv
        WHERE aufnr IN so_aufnr
          AND werks = p_werks.

      IF gt_caufv[] IS NOT INITIAL.
        PERFORM f_check_status.

        SELECT *
          FROM afpo
          INTO CORRESPONDING FIELDS OF TABLE gt_afpo
          FOR ALL ENTRIES IN gt_caufv
          WHERE aufnr = gt_caufv-aufnr.
      ENDIF.

      PERFORM f_get_bom.
  ENDCASE.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
*PERFORM f_set_pf_status.
*PERFORM F_TOP_OF_PAGE.
*PERFORM F_USER_COMMAND.
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

  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
   'MATNR'  'RESB' 'MATNR' '' '18'  'Material Comp.'  ''
   '' '' '' '' '' '' '' '' '',
   'MAKTX'  'MAKT' 'MAKTX' '' '40' 'Description' ''
   '' '' '' '' '' '' '' '' ''.

  IF option = 2.
    PERFORM f_fieldcatg USING ft_report:
     'BDMNG'  'RESB' 'BDMNG' '' '15' 'Quantity' ''
     '' '3' '' '' '' 'MEINS' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING ft_report:
     'BDMNG'  'RESB' 'BDMNG' '' '15' 'Quantity' ''
     '' '3' '' '' '' 'MEINS' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING ft_report:
   'MEINS'  'RESB' 'MEINS' '' '6' 'UoM' ''
   '' '' '' '' '' '' '' '' ''.

  IF option = 2.
    IF p_werks = '0101' OR p_werks = '0102' OR
       p_werks = '0901'.
      PERFORM f_fieldcatg USING ft_report:
       'MSG'  '' '' '' '50' 'Message' ''
       '' '' '' '' '' '' '' '' ''.
    ENDIF.
  ENDIF.
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
                          value(fu_edit).

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
  ld_fieldcat-input         = fu_input.
  ld_fieldcat-edit          = fu_edit.
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

  IF option = 2 AND radio2 = 'X' AND
     ( p_werks = '0101' OR p_werks = '0102' OR
       p_werks = '0901' ).
    fu_layout-box_fieldname      = 'CHKBOX'.
  ENDIF.
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

  CLEAR ld_sort.
  ld_sort-fieldname = 'WERKS'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  ld_sort-fieldname = 'GSTRP'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  ld_sort-fieldname = 'MATNR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = ' '.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.

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

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page1.

*  PERFORM f_hdr_uline.
  PERFORM f_hdr_line5 USING ''.
  PERFORM f_write_product.
*  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page1


*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR: v_ind_save, va_ctr.
  REFRESH: i_itab, i_itab1, i_itab2, i_caufv, i_afpo, i_resb,
           i_matnr, i_mard, i_itab_tmp, i_zgdppdt0001, i_link,
           i_bapiresbc, i_linkx, i_linkx_tmp, i_marc, i_makt.
  FREE:    i_itab, i_itab1, i_itab2, i_caufv, i_afpo, i_resb,
           i_matnr, i_mard, i_itab_tmp, i_zgdppdt0001, i_link,
           i_bapiresbc, i_linkx, i_linkx_tmp, i_marc, i_makt.
  CLEAR:   i_itab, i_itab1, i_itab2, i_caufv, i_afpo, i_resb,
           i_matnr, i_mard, i_itab_tmp, i_zgdppdt0001, i_link,
           i_bapiresbc, i_linkx, i_linkx_tmp, i_marc, i_makt, wa_linkx,
           wa_itab, wa_itab1, wa_itab2, wa_caufv, wa_afpo, wa_resb,
           wa_matnr, wa_mard, wa_zgdppdt0001, wa_link, wa_bapiresbc.


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
  SET PF-STATUS  'TOEXECUTE'.

ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status1 USING rt_extab TYPE slis_t_extab.
  DATA fcode TYPE TABLE OF sy-ucomm.

  IF option = 2 AND radio2 = 'X' AND
     ( p_werks = '0101' OR p_werks = '0102' OR
       p_werks = '0901' ).
  ELSE.
    APPEND '&CANCL' TO fcode.
  ENDIF.

  sy-lsind = 0.
  SET PF-STATUS  'SET2' EXCLUDING fcode.

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
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.
  DATA: l_ctr TYPE i.
  DATA: l_batch(25),
        l_link(52),
        l_sw(1),
        nomor TYPE i.

  DATA : ls_mchb   LIKE LINE OF gt_mchb,
         limit     TYPE vrfmg,
         p_limit   TYPE tvarvc-low.

  RANGES: r_link   FOR l_link,
          r_batch  FOR l_batch.

  SELECT SINGLE low INTO p_limit
    FROM tvarvc WHERE name = 'ZPP_RES_STOCK_THR_LIM'.

  nomor  = 0.
  REFRESH: i_itab, i_linkx_tmp. FREE: i_itab, i_linkx_tmp.
  CLEAR: i_itab, i_linkx_tmp.
  break bcsuk.
  LOOP AT i_caufv INTO wa_caufv.
    MOVE-CORRESPONDING wa_caufv TO wa_itab.
    SORT i_afpo BY aufnr matnr. "binary search harus di sort 21-May-2007
    READ TABLE i_afpo INTO wa_afpo WITH
         KEY aufnr = wa_caufv-aufnr
             matnr = wa_caufv-plnbez
         BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_itab-charg = wa_afpo-charg.
      wa_itab-matname = wa_afpo-maktx.
      wa_itab-mtart   = wa_afpo-mtart.
    ELSE.
      CONTINUE.
    ENDIF.
    LOOP AT i_resb INTO wa_resb WHERE aufnr = wa_caufv-aufnr.
      IF wa_resb-bdmng = 0.
        CONTINUE.
      ENDIF.
      MOVE-CORRESPONDING wa_caufv TO wa_itab.
      MOVE-CORRESPONDING wa_resb TO wa_itab.
      wa_itab-charg = wa_afpo-charg.
      IF wa_itab-mtart = p_mtart.
        APPEND wa_itab TO i_itab.
      ENDIF.
      CLEAR: wa_resb.
    ENDLOOP.
    CLEAR: wa_itab, wa_caufv, wa_afpo, wa_resb.
  ENDLOOP.
  DELETE i_itab WHERE plnbez = space.

  REFRESH: r_batch, r_link, i_itab1.
  FREE: i_itab1, r_batch, r_link.
  CLEAR: l_sw, i_itab1, r_batch, r_link,l_ctr.
  l_sw = 0.

  SORT i_itab BY werks gstrp matnr.
  LOOP AT i_itab INTO wa_itab.
    ON CHANGE OF wa_itab-werks OR
                 wa_itab-gstrp OR
                 wa_itab-matnr.
      IF l_sw = 0.
        l_sw = 1.
      ELSE.
        SORT i_mard BY werks matnr lgort.
        READ TABLE i_mard INTO wa_mard WITH
              KEY matnr = wa_itab1-matnr
                  werks = wa_itab1-werks
                  lgort = p_lgort
              BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF gt_mchb[] IS NOT INITIAL.
            LOOP AT gt_mchb INTO ls_mchb WHERE matnr = wa_itab1-matnr
                                           AND werks = wa_itab1-werks.
              IF wa_itab1-bdmng IS INITIAL.
                CONTINUE.
              ENDIF.
              limit = ls_mchb-clabs / wa_itab1-bdmng.
              IF limit < p_limit.
                wa_mard-labst = wa_mard-labst - ls_mchb-clabs.
              ENDIF.
              DELETE gt_mchb.
            ENDLOOP.
          ENDIF.
          IF wa_mard-labst < wa_itab1-bdmng.
            wa_itab1-bdmng = wa_itab1-bdmng - wa_mard-labst + wa_mard-qtymin.

            IF wa_itab1-bdmng NE 0.
              SORT i_marc BY werks matnr.
              READ TABLE i_marc INTO wa_marc WITH
                    KEY matnr = wa_itab1-matnr
                        werks = wa_itab1-werks
                    BINARY SEARCH.
              IF sy-subrc EQ 0.
                wa_itab1-bstrf = wa_marc-bstrf.
              ENDIF.
              IF wa_itab1-bstrf IS INITIAL OR wa_itab1-bstrf = 0.
              ELSE.
                PERFORM f_calc_reservation_qty USING wa_itab1
                                               CHANGING wa_itab1-bdmng.
              ENDIF.
            ENDIF.

            ADD 1 TO nomor.
            wa_itab1-nomor = nomor.
*                    wa_itab1-bdmng = wa_itab1-bdmng / 10.
            APPEND wa_itab1 TO i_itab1.

            LOOP AT i_linkx_tmp INTO wa_linkx.
              wa_linkx-nomor = nomor.
              MODIFY i_linkx_tmp FROM wa_linkx.
            ENDLOOP.
            APPEND LINES OF i_linkx_tmp TO i_linkx.
            REFRESH: i_linkx_tmp. CLEAR: i_linkx_tmp.
            wa_mard-labst = wa_mard-labst - wa_itab1-bdmng.
            IF wa_mard-labst <= 0.
              wa_mard-labst = 0.
            ENDIF.
            MODIFY i_mard FROM wa_mard TRANSPORTING labst
                    WHERE matnr = wa_itab1-matnr.
*            CLEAR: wa_itab1.
          ELSE.
            wa_status-aufnr = wa_itab1-aufnr.
            MOVE-CORRESPONDING wa_status TO i_status.
            APPEND i_status.

            wa_mard-labst = wa_mard-labst - wa_itab1-bdmng.
            MODIFY i_mard FROM wa_mard TRANSPORTING labst
                    WHERE matnr = wa_itab1-matnr.
          ENDIF.
        ELSE.
          ADD 1 TO nomor.
          wa_itab1-nomor = nomor.
*                wa_itab1-bdmng = wa_itab1-bdmng / 10.
          IF wa_itab1-bdmng NE 0.
            SORT i_marc BY werks matnr.
            CLEAR wa_marc.
            READ TABLE i_marc INTO wa_marc WITH
                  KEY matnr = wa_itab1-matnr
                      werks = wa_itab1-werks
                  BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_itab1-bstrf = wa_marc-bstrf.
            ENDIF.
            IF wa_itab1-bstrf IS INITIAL OR wa_itab1-bstrf = 0.
            ELSE.
              PERFORM f_calc_reservation_qty USING wa_itab1
                                             CHANGING wa_itab1-bdmng.
            ENDIF.
          ENDIF.
          APPEND wa_itab1 TO i_itab1.

          LOOP AT i_linkx_tmp INTO wa_linkx.
            wa_linkx-nomor = nomor.
            MODIFY i_linkx_tmp FROM wa_linkx.
          ENDLOOP.
          APPEND LINES OF i_linkx_tmp TO i_linkx.
          REFRESH: i_linkx_tmp. CLEAR: i_linkx_tmp.
        ENDIF.

        REFRESH: r_batch, r_link.
        FREE: r_batch, r_link.
        CLEAR: l_sw, r_batch, r_link, wa_itab1, l_ctr, wa_itab1.
      ENDIF.

      wa_itab1-gstrp = wa_itab-gstrp.
      wa_itab1-bdter = wa_itab-bdter.
      wa_itab1-werks = p_werks.
      wa_itab1-name  = sy-uname.
      wa_itab1-date  = sy-datum.
      wa_itab1-matnr = wa_itab-matnr.
      wa_itab1-maktx = wa_itab-maktx.
      wa_itab1-bstrf = wa_itab-bstrf.
      wa_itab1-meins = wa_itab-meins.
      wa_itab1-fevor = wa_itab-fevor.
      wa_itab1-aufnr = wa_itab-aufnr.
      wa_itab1-matkl = wa_itab-matkl.
    ENDON.

    l_sw = 1.
    ADD wa_itab-bdmng TO wa_itab1-bdmng.
    CLEAR: l_batch.
    CONCATENATE  wa_itab-plnbez '(' wa_itab-charg ')' INTO l_batch.
    IF r_batch IS INITIAL.
      l_ctr = 1.
      r_batch-low = l_batch.
      r_batch-high = l_batch.
      r_batch-sign = 'I'.
      r_batch-option = 'EQ'.
      APPEND r_batch.
      wa_itab1-product = l_batch.
    ENDIF.

    IF l_batch IN r_batch.
    ELSE.
      r_batch-low = l_batch.
      r_batch-high = l_batch.
      r_batch-sign = 'I'.
      r_batch-option = 'EQ'.
      APPEND r_batch.
      IF l_ctr = 2.
        CONCATENATE wa_itab1-product l_batch
           INTO wa_itab1-product SEPARATED BY '|'.
        l_ctr = 1.
      ELSE.
        CONCATENATE wa_itab1-product l_batch
           INTO wa_itab1-product SEPARATED BY ';'.
        ADD 1 TO l_ctr.
      ENDIF.
    ENDIF.

    CLEAR: l_link.
    CONCATENATE  wa_itab-aufnr  wa_itab-plnbez  wa_itab-charg
                 wa_itab-gstrp  wa_itab-fevor
                 wa_itab-mtart INTO l_link SEPARATED BY ':'.
    IF r_link IS INITIAL.
      r_link-low = l_link.
      r_link-high = l_link.
      r_link-sign = 'I'.
      r_link-option = 'EQ'.
      APPEND r_link.
      wa_itab1-link = l_link.

      wa_linkx-aufnr = wa_itab-aufnr.
      wa_linkx-charg  = wa_itab-charg.
      wa_linkx-plnbez = wa_itab-plnbez.
      wa_linkx-gstrp  = wa_itab-gstrp.
      wa_linkx-maktx  = wa_itab-matname.
      wa_linkx-fevor  = wa_itab-fevor.
      wa_linkx-mtart  = wa_itab-mtart.
      APPEND wa_linkx TO i_linkx_tmp.
    ENDIF.

    IF l_link IN r_link.
    ELSE.
      r_link-low = l_link.
      r_link-high = l_link.
      r_link-sign = 'I'.
      r_link-option = 'EQ'.
      APPEND r_link.
      CONCATENATE wa_itab1-link l_link
         INTO wa_itab1-link SEPARATED BY '|'.

      wa_linkx-aufnr = wa_itab-aufnr.
      wa_linkx-charg  = wa_itab-charg.
      wa_linkx-plnbez = wa_itab-plnbez.
      wa_linkx-gstrp  = wa_itab-gstrp.
      wa_linkx-maktx  = wa_itab-matname.
      wa_linkx-fevor  = wa_itab-fevor.
      wa_linkx-mtart  = wa_itab-mtart.
      APPEND wa_linkx TO i_linkx_tmp.
    ENDIF.
    CLEAR: wa_itab.
  ENDLOOP.

  IF l_sw = 0.
    l_sw = 1.
  ELSE.
    SORT i_mard BY werks matnr lgort.
    READ TABLE i_mard INTO wa_mard WITH
          KEY matnr = wa_itab1-matnr
              werks = wa_itab1-werks
              lgort = p_lgort
          BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF gt_mchb[] IS NOT INITIAL.
        LOOP AT gt_mchb INTO ls_mchb WHERE matnr = wa_itab1-matnr
                                       AND werks = wa_itab1-werks.
          IF wa_itab1-bdmng IS INITIAL.
            CONTINUE.
          ENDIF.
          limit = ls_mchb-clabs / wa_itab1-bdmng.
          IF limit < p_limit.
            wa_mard-labst = wa_mard-labst - ls_mchb-clabs.
          ENDIF.
          DELETE gt_mchb.
        ENDLOOP.
      ENDIF.
      IF wa_mard-labst < wa_itab1-bdmng.
        wa_itab1-bdmng = wa_itab1-bdmng -  wa_mard-labst + wa_mard-qtymin.

        IF wa_itab1-bdmng NE 0.
          SORT i_marc BY werks matnr.
          READ TABLE i_marc INTO wa_marc WITH
                KEY matnr = wa_itab1-matnr
                    werks = wa_itab1-werks
                BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_itab1-bstrf = wa_marc-bstrf.
          ENDIF.
          IF wa_itab1-bstrf IS INITIAL OR wa_itab1-bstrf = 0.
          ELSE.
            PERFORM f_calc_reservation_qty USING wa_itab1
                                           CHANGING wa_itab1-bdmng.
          ENDIF.
        ENDIF.

        ADD 1 TO nomor.
        wa_itab1-nomor = nomor.
*                    wa_itab1-bdmng = wa_itab1-bdmng / 10.
        APPEND wa_itab1 TO i_itab1.

        LOOP AT i_linkx_tmp INTO wa_linkx.
          wa_linkx-nomor = nomor.
          MODIFY i_linkx_tmp FROM wa_linkx.
        ENDLOOP.
        APPEND LINES OF i_linkx_tmp TO i_linkx.
        REFRESH: i_linkx_tmp. CLEAR: i_linkx_tmp.
        wa_mard-labst = wa_mard-labst - wa_itab1-bdmng.
        IF wa_mard-labst <= 0.
          wa_mard-labst = 0.
        ENDIF.
        MODIFY i_mard FROM wa_mard TRANSPORTING labst
                WHERE matnr = wa_itab1-matnr.
*            CLEAR: wa_itab1.
      ELSE.
        wa_status-aufnr = wa_itab1-aufnr.
        MOVE-CORRESPONDING wa_status TO i_status.
        APPEND i_status.

        wa_mard-labst = wa_mard-labst - wa_itab1-bdmng.
        MODIFY i_mard FROM wa_mard TRANSPORTING labst
                WHERE matnr = wa_itab1-matnr.
*        APPEND wa_itab1 TO i_itab1.
      ENDIF.
    ELSE.
      ADD 1 TO nomor.
      wa_itab1-nomor = nomor.
*                wa_itab1-bdmng = wa_itab1-bdmng / 10.
      IF wa_itab1-bdmng NE 0.
        SORT i_marc BY werks matnr.
        CLEAR wa_marc.
        READ TABLE i_marc INTO wa_marc WITH
              KEY matnr = wa_itab1-matnr
                  werks = wa_itab1-werks
              BINARY SEARCH.
        IF sy-subrc EQ 0.
          wa_itab1-bstrf = wa_marc-bstrf.
        ENDIF.
        IF wa_itab1-bstrf IS INITIAL OR wa_itab1-bstrf = 0.
        ELSE.
          PERFORM f_calc_reservation_qty USING wa_itab1
                                         CHANGING wa_itab1-bdmng.
        ENDIF.
      ENDIF.
      APPEND wa_itab1 TO i_itab1.

      LOOP AT i_linkx_tmp INTO wa_linkx.
        wa_linkx-nomor = nomor.
        MODIFY i_linkx_tmp FROM wa_linkx.
      ENDLOOP.
      APPEND LINES OF i_linkx_tmp TO i_linkx.
      REFRESH: i_linkx_tmp. CLEAR: i_linkx_tmp.

      REFRESH: r_batch, r_link.
      FREE: r_batch, r_link.
      CLEAR: l_sw, r_batch, r_link, wa_itab1, l_ctr, wa_itab1.
    ENDIF.

************    SORT i_marc BY matnr werks.
************    READ TABLE i_marc INTO wa_marc WITH
************          KEY matnr = wa_itab1-matnr
************              werks = wa_itab1-werks
************          BINARY SEARCH.
************    IF sy-subrc EQ 0.
************      wa_itab1-bstrf = wa_marc-bstrf.
************    ENDIF.
************    IF wa_itab1-bstrf IS INITIAL OR wa_itab1-bstrf = 0.
************    ELSE.
************      mod = wa_itab1-bdmng MOD wa_itab1-bstrf.
************      IF mod <> 0.
************        wa_itab1-bdmng = wa_itab1-bdmng - mod + wa_itab1-bstrf.
************      ENDIF.
************    ENDIF.
************    SORT i_mard BY matnr werks lgort.
************    READ TABLE i_mard INTO wa_mard WITH
************          KEY matnr = wa_itab1-matnr
************              werks = wa_itab1-werks
************              lgort = p_lgort
************          BINARY SEARCH.
************    IF sy-subrc EQ 0.
************      IF wa_mard-labst < wa_itab1-bdmng.
************        wa_itab1-bdmng = wa_itab1-bdmng - wa_mard-labst + wa_mard-qtymin.
************        ADD 1 TO nomor.
************        wa_itab1-nomor = nomor.
*************            wa_itab1-bdmng = wa_itab1-bdmng / 10.
************        APPEND wa_itab1 TO i_itab1.
************        LOOP AT i_linkx_tmp INTO wa_linkx.
************          wa_linkx-nomor = nomor.
************          MODIFY i_linkx_tmp FROM wa_linkx.
************        ENDLOOP.
************        APPEND LINES OF i_linkx_tmp TO i_linkx.
************
************        REFRESH: i_linkx_tmp. CLEAR: i_linkx_tmp.
************        wa_mard-labst = wa_mard-labst - wa_itab1-bdmng.
************        IF wa_mard-labst <= 0.
************          wa_mard-labst = 0.
************        ENDIF.
************        MODIFY i_mard FROM wa_mard TRANSPORTING labst
************                WHERE matnr = wa_itab1-matnr.
************        CLEAR: wa_itab1.
************      ELSE.
************        wa_mard-labst = wa_mard-labst - wa_itab1-bdmng.
************        MODIFY i_mard FROM wa_mard TRANSPORTING labst
************                WHERE matnr = wa_itab1-matnr.
************      ENDIF.
************    ELSE.
************      ADD 1 TO nomor.
************      wa_itab1-nomor = nomor.
*************        wa_itab1-bdmng = wa_itab1-bdmng / 10.
************      APPEND wa_itab1 TO i_itab1.
************      LOOP AT i_linkx_tmp INTO wa_linkx.
************        wa_linkx-nomor = nomor.
************        MODIFY i_linkx_tmp FROM wa_linkx.
************      ENDLOOP.
************      APPEND LINES OF i_linkx_tmp TO i_linkx.
************      REFRESH: i_linkx_tmp. CLEAR: i_linkx_tmp, wa_itab1.
************    ENDIF.
************    REFRESH: r_batch, r_link.
************    FREE: r_link, r_batch.
************    CLEAR: l_sw, r_link, r_batch.
************    CLEAR: wa_itab1.
  ENDIF.

  SORT i_itab1 BY werks gstrp matnr.
  break bcsuk.

  DELETE ADJACENT DUPLICATES FROM i_linkx
      COMPARING  aufnr plnbez charg gstrp fevor mtart.
  SORT i_linkx BY nomor plnbez charg.

ENDFORM.                    " f_validate_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA : lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA : lv_subrc       TYPE sy-subrc.

  REFRESH: lt_dynpread.
  sy-lsind = 0.
  CASE fu_ucomm.
    WHEN '&PO'.
      PERFORM f_validasi_po CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        PERFORM f_process_order.
      ELSE.
        MESSAGE s000(zab) WITH 'Ada quantity yang kurang dari 0'
        DISPLAY LIKE 'E'.
      ENDIF.

    WHEN '&NOTE'.
      CALL SCREEN 400 STARTING AT 10 10.
  ENDCASE.
ENDFORM.                    "f_user_command

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command1 USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.
  IF option = 2.
    IF radio1 = 'X' OR
       ( radio2 = 'X' AND p_werks = '0101' ) OR
       ( radio2 = 'X' AND p_werks = '0102' ) OR
       ( radio2 = 'X' AND p_werks = '0901' ).
      CASE fu_ucomm.
        WHEN '&CANCL'.
          PERFORM f_cancel_reservation.
        WHEN '&SAV'.
        WHEN '&BCK'.
          LEAVE SCREEN.
        WHEN '&OUT'.
          LEAVE SCREEN.
        WHEN '&PRN'.
          break bcsuk.
          PERFORM print..
        WHEN '&CNL'.
          LEAVE PROGRAM.
      ENDCASE.
    ENDIF.
  ELSE.
    CASE fu_ucomm.
      WHEN '&SAV'.
        IF v_ind_save IS INITIAL.
          PERFORM f_save_to_table.
          MESSAGE i010(zz) WITH
              'Data Sudah disimpan'.
          v_ind_save = 1.
        ELSE.
          MESSAGE i010(zz) WITH
              'Data Sudah disimpan'.
        ENDIF.
        sy-lsind = 0.

      WHEN '&BCK'.
        IF v_ind_save IS INITIAL.
          MESSAGE i010(zz) WITH
              'Data Belum disimpan'.
        ELSEIF  v_ind_save = 1.
          MESSAGE i010(zz) WITH
              'Data Sudah disimpan & Belum dicetak'.
        ELSEIF  v_ind_save = 2.
          MESSAGE i010(zz) WITH
              'Data Sudah disimpan dan di cetak'.
*          LEAVE PROGRAM.
        ENDIF.
        LEAVE PROGRAM.
      WHEN '&OUT'.
        IF v_ind_save IS INITIAL.
          MESSAGE i010(zz) WITH
              'Data Belum disimpan & dicetak'.
        ELSEIF  v_ind_save = 1.
          MESSAGE i010(zz) WITH
              'Data Sudah disimpan & Data Belum dicetak'.
        ELSEIF  v_ind_save = 2.
          MESSAGE i010(zz) WITH
              'Data Sudah disimpan dan di cetak'.
        ENDIF.
        LEAVE PROGRAM.
      WHEN '&CNL'.
        IF v_ind_save IS INITIAL.
          MESSAGE i010(zz) WITH
              'Transaksi dibatalkan'.
          LEAVE PROGRAM.
        ELSEIF  v_ind_save = 1.
          MESSAGE i010(zz) WITH
              'Data Harus dicetak'.
        ELSEIF  v_ind_save = 2.
          MESSAGE i010(zz) WITH
              'Transaksi Complete'.
          LEAVE PROGRAM.
        ENDIF.

      WHEN '&PRN'.
        IF v_ind_save IS INITIAL.
          MESSAGE i010(zz) WITH
             'Data belum disimpan'.
        ELSEIF  v_ind_save = 1.
          PERFORM print..
          v_ind_save = 2.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    "f_user_command1

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
  SORT i_itab1 BY werks gstrp matnr.
  PERFORM f_alv TABLES i_itab1.

ENDFORM.                    "

*&---------------------------------------------------------------------*
*&      Form  f_process_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_order.

*  PERFORM f_validate_data_bapi.
  PERFORM f_new_validate_data_bapi.
  PERFORM f_write_result.
ENDFORM.                    " f_process_order

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0515   text
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING    value(p_0515).
  DATA: v_left_text(40),
        v_right_text(40),
        l_sw(1),
        v_product(62),
        v_charg(23),
        l_plnbez LIKE wa_linkx-plnbez.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE 'Program : xx',
    ld_progname(20),
    page(4),
    l_lenght TYPE i,
    ld_sysid(30) VALUE 'Client      : XXX(YYY)',
    ld_datum(10).

*--- Program & Page number
  CLEAR: v_left_text, v_right_text.
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.
  PERFORM f_hdr_pad_title1 USING progname sy-title page_number.
  CLEAR: v_left_text, v_right_text.
*--- system info  & Date
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.
  WRITE sy-datum TO ld_datum.
  CONCATENATE 'Date  : ' ld_datum INTO v_right_text
                             SEPARATED BY space.
  CONCATENATE 'Client            : ' sy-sysid(3) '(' sy-mandt ')'
              INTO v_left_text   SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
*--- Plant & Name
  CLEAR: v_left_text, v_right_text.
  CONCATENATE 'Plant             : '  i_itab1-werks INTO v_left_text
                           SEPARATED BY space.
  CONCATENATE 'Name  : ' i_itab1-name INTO v_right_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
  CLEAR: v_left_text, v_right_text.
*--- Product
  REFRESH: i_linkx_tmp.
  CLEAR: i_linkx_tmp.
  LOOP AT i_linkx INTO wa_linkx WHERE gstrp = i_itab1-gstrp.
*  LOOP AT i_linkx INTO wa_linkx WHERE nomor = i_itab1-nomor.
    APPEND wa_linkx TO i_linkx_tmp.
    CLEAR: wa_linkx.
  ENDLOOP.
  SORT i_linkx_tmp BY plnbez charg.
  DELETE ADJACENT DUPLICATES FROM i_linkx_tmp COMPARING plnbez charg.
  IF i_linkx_tmp IS INITIAL.
  ELSE.
    CLEAR: v_product, l_plnbez.
    l_sw = 0.
    SORT i_linkx_tmp BY plnbez charg.
    LOOP AT i_linkx_tmp INTO wa_linkx.
      CLEAR v_charg.
      CONCATENATE wa_linkx-charg wa_linkx-aufnr
        INTO v_charg SEPARATED BY '/'.

      IF l_plnbez <> wa_linkx-plnbez.
        CONCATENATE wa_linkx-maktx
                     '('
                     wa_linkx-plnbez
                     ')'
                     INTO v_product.
        WRITE: /  '  Product : ', v_product .
        WRITE: /  '  Batch   : '.
*        IF wa_linkx-charg IS INITIAL.
*        ELSE.
*          WRITE wa_linkx-charg.
*        ENDIF.
        IF v_charg IS INITIAL.
        ELSE.
          WRITE v_charg.
        ENDIF.
      ELSE.
        IF sy-colno < 72.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            IF sy-colno < 15.
*              WRITE wa_linkx-charg.
*            ELSE.
*              WRITE: ',', wa_linkx-charg.
*            ENDIF.
*          ENDIF.
          IF v_charg IS INITIAL.
          ELSE.
            IF sy-colno < 25.
              WRITE v_charg.
            ELSE.
              WRITE: ',', v_charg.
            ENDIF.
          ENDIF.
        ELSE.
          WRITE: /  '            '.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            WRITE wa_linkx-charg.
*          ENDIF.
          IF v_charg IS INITIAL.
          ELSE.
            WRITE v_charg.
          ENDIF.
        ENDIF.
      ENDIF.
      l_plnbez = wa_linkx-plnbez.
      CLEAR: wa_linkx.
    ENDLOOP.
  ENDIF.
  CLEAR: v_left_text, v_right_text.
*--- Basic Start date
  WRITE i_itab1-gstrp  TO ld_datum.
  CONCATENATE 'Basic Start date : ' ld_datum INTO v_left_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING    v_left_text '' v_right_text.

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
*&      Form  f_validate_data_bapi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data_bapi.
  DATA: l_sw(1).
  l_sw = 1.
  REFRESH: i_bapiresbc, i_bapireturn, i_itab2, i_itab_tmp.
  CLEAR: wa_itab, wa_bapirkpfc, wa_bapiresbc, i_itab2, i_itab_tmp,
        i_bapiresbc,i_bapireturn.
  SORT i_itab1 BY werks gstrp.
  LOOP AT i_itab1 INTO wa_itab1.
    ON CHANGE OF wa_itab1-werks OR
                 wa_itab1-gstrp.
      IF l_sw <> 1.
***        PERFORM f_bapi_reservation.
        REFRESH: i_itab_tmp, i_bapiresbc.
        CLEAR: i_itab_tmp, i_bapiresbc, wa_bapiresbc.
      ENDIF.
      wa_bapirkpfc-plant    = wa_itab1-werks.
      wa_bapirkpfc-res_date = wa_itab1-gstrp.
      wa_bapirkpfc-created_by = wa_itab1-name.
      wa_bapirkpfc-move_type  = '311'.
      wa_bapirkpfc-move_plant = wa_itab1-werks.
      wa_bapirkpfc-move_stloc = p_lgort.
    ENDON.
    l_sw = 0.
    wa_bapiresbc-material   = wa_itab1-matnr.
    wa_bapiresbc-plant      = p_werks.
    wa_bapiresbc-store_loc  = p_umlgo.
    wa_bapiresbc-quantity   = wa_itab1-bdmng.
    wa_bapiresbc-unit       = wa_itab1-meins.
    wa_bapiresbc-req_date   = wa_itab1-gstrp.
    APPEND wa_bapiresbc TO i_bapiresbc.
    APPEND wa_itab1 TO i_itab_tmp.
    CLEAR: wa_itab1.
  ENDLOOP.
  IF l_sw <> 1.
***    PERFORM f_bapi_reservation.
    REFRESH: i_itab_tmp.
    CLEAR: i_itab_tmp.
  ENDIF.
  DELETE ADJACENT DUPLICATES FROM i_link COMPARING ALL FIELDS.

ENDFORM.                    " f_validate_data_bapi
*&---------------------------------------------------------------------*
*&      Form  f_bapi_reservation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bapi_reservation CHANGING fc_res_no.
  DATA: l_error_found(1).
  REFRESH: i_bapireturn.
  CLEAR: i_bapireturn,  l_error_found.
  CALL FUNCTION 'BAPI_RESERVATION_CREATE'
    EXPORTING
      reservation_header = wa_bapirkpfc
      no_commit          = 'X'
      movement_auto      = 'X'
    IMPORTING
      reservation        = fc_res_no
    TABLES
      reservation_items  = i_bapiresbc
      return             = i_bapireturn.
  CLEAR: l_error_found.
  LOOP AT i_bapireturn INTO wa_bapireturn.
    IF wa_bapireturn-type  = 'E'.
      MESSAGE i000(zgd) WITH wa_bapireturn-message.
      l_error_found = 'E'.
      EXIT.
    ELSE.
    ENDIF.
  ENDLOOP.
  IF l_error_found <> 'E'.
    LOOP AT i_itab_tmp INTO wa_itab2.
      wa_itab2-rsnum = fc_res_no.
      MODIFY i_itab_tmp FROM wa_itab2.
      wa_link-link = wa_itab2-link.
      wa_link-rsnum = wa_itab2-rsnum.
      APPEND wa_link TO i_link.
    ENDLOOP.
    APPEND LINES OF i_itab_tmp TO i_itab2.
  ENDIF.

ENDFORM.                    " f_bapi_reservation
*&---------------------------------------------------------------------*
*&      Form  f_write_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_result.
  SORT i_itab2 BY werks rsnum gstrp matnr.
  PERFORM f_alv1 TABLES i_itab2.
ENDFORM.                    " f_write_result

*---------------------------------------------------------------------*
*       FORM f_Save_To_Table                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_save_to_table.
  DATA: v_link(500),
        v_line(500),
        v_line1(50),
        v_aufnr(12),
        v_matnr(18),
        v_gstrp(10),
        v_charg(10),
        v_fevor(3),
        v_mtart(4).
  REFRESH: i_zgdppdt0001.
  CLEAR: i_zgdppdt0001, wa_zgdppdt0001.
  LOOP AT i_link INTO wa_link.
    CLEAR: v_link, v_line, v_line1,
           v_aufnr, v_matnr, v_gstrp, v_charg.
    v_link = wa_link-link.
    DO 100 TIMES.
      IF v_link IS INITIAL.
        EXIT.
      ENDIF.
      SPLIT v_link AT '|' INTO v_line1 v_line.
      IF v_line1 IS INITIAL.
        EXIT.
      ELSE.
        SPLIT v_line1 AT ':' INTO
            v_aufnr v_matnr v_charg v_gstrp v_fevor v_mtart.
        wa_zgdppdt0001-werks = p_werks.
        wa_zgdppdt0001-rsnum = wa_link-rsnum.
        wa_zgdppdt0001-gstrp = v_gstrp.
        wa_zgdppdt0001-matnr = v_matnr.
        wa_zgdppdt0001-aufnr = v_aufnr.
        wa_zgdppdt0001-charg = v_charg.
        wa_zgdppdt0001-uname = sy-uname.
        wa_zgdppdt0001-udate = sy-datum.
        wa_zgdppdt0001-utime = sy-uzeit.
        wa_zgdppdt0001-lgort = p_lgort.
        wa_zgdppdt0001-fevor = v_fevor.
        wa_zgdppdt0001-mtart = v_mtart.
        APPEND wa_zgdppdt0001 TO i_zgdppdt0001.
        v_link = v_line.
        CLEAR: v_line1, v_line, v_aufnr, v_matnr, v_gstrp, v_charg.
      ENDIF.
    ENDDO.
    CLEAR: wa_link.
  ENDLOOP.

  SORT i_itab2 BY nomor.
  LOOP AT i_linkx INTO wa_linkx.
    READ TABLE i_itab2 INTO wa_itab2 WITH KEY nomor = wa_linkx-nomor
    BINARY SEARCH.
    IF sy-subrc = 0.
      wa_linkx-rsnum = wa_itab2-rsnum.
      MODIFY i_linkx FROM wa_linkx.
    ENDIF.
  ENDLOOP.

  SORT i_linkx BY aufnr plnbez charg gstrp rsnum.

  DELETE i_linkx WHERE rsnum IS INITIAL.

  DELETE ADJACENT DUPLICATES FROM i_linkx
      COMPARING aufnr plnbez charg gstrp rsnum fevor mtart.

  DELETE ADJACENT DUPLICATES FROM i_zgdppdt0001
      COMPARING werks rsnum matnr aufnr charg lgort fevor mtart.

  LOOP AT i_zgdppdt0001 INTO wa_zgdppdt0001.
    MOVE-CORRESPONDING wa_zgdppdt0001 TO zgdppdt0001.
    MODIFY zgdppdt0001.
  ENDLOOP.
*
  COMMIT WORK.

  PERFORM f_create_tr.

*
*  Refresh: i_zgdppdt0001, i_itab2, i_itab.
  CLEAR: i_zgdppdt0001.
ENDFORM.                    " f_write_result
*&---------------------------------------------------------------------*
*&      Form  f_alv1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ITAB3  text
*----------------------------------------------------------------------*
FORM f_alv1 TABLES ft_report.
*PERFORM f_set_pf_status1.
*PERFORM F_USER_COMMAND1.
*PERFORM F_TOP_OF_PAGE1.
*  PERFORM f_hdr_line5 USING ''.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield1  USING   t_alv_isort[].
  PERFORM f_build_event1      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS1'
    i_callback_user_command        = 'F_USER_COMMAND1'
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
ENDFORM.                                                    " f_alv1
*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_REPORT  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report.

  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
   'MATERIAL'   'BAPIRKPFC' 'MATERIAL'   '' '18'
   'Raw Material' '' '' '' '' '' '' '' '' '' '',
   'OJTXB'   'STPO' 'OJTXB'   '' '40'
   'Description' '' '' '' '' '' '' '' '' '' '',
   'QUANTITY'   'BAPIRKPFC' 'QUANTITY'   '' '15'
   'Quantity' '' '' '' '' '' 'UNIT' '' '' '' '',
   'UNIT'       'BAPIRKPFC' 'UNIT'       '' '6'
   'UoM' '' '' '' '' '' '' '' '' '' '',
   'REQ_DATE'   'BAPIRKPFC' 'REQ_DATE'   '' '10'
   'Date' '' '' '' '' '' '' '' '' '' ''.
*    'Dummy'  ''      'DUMMY' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " f_build_fieldcat1
*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_ALV_ISORT[]  text
*----------------------------------------------------------------------*
FORM f_build_sortfield1 USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'WERKS'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  ld_sort-fieldname = 'GSTRP'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  ld_sort-fieldname = 'RSNUM'.
  ld_sort-up        = 'X'.
  ld_sort-group     = '*'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    " f_build_sortfield1
*&---------------------------------------------------------------------*
*&      Form  f_hdr_line5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0482   text
*----------------------------------------------------------------------*
FORM f_hdr_line5 USING    value(p_0515).
  DATA: v_left_text(40),
        v_right_text(40),
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE 'Program : xx',
    ld_progname(20),
    page(4),
    l_ln TYPE i,
    l_lenght TYPE i,
    ld_sysid(30) VALUE 'Client      : XXX(YYY)',
    ld_datum(10).
**--- Program & Page number
  CLEAR: v_left_text, v_right_text.
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.
  PERFORM f_hdr_pad_title1 USING progname sy-title page_number.
  CLEAR: v_left_text, v_right_text.
**--- system info  & Date
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.
  WRITE sy-datum TO ld_datum.
  CONCATENATE 'Date  : ' ld_datum INTO v_right_text
                             SEPARATED BY space.
  CONCATENATE 'Client            : ' sy-sysid(3) '(' sy-mandt ')'
              INTO v_left_text   SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
**--- Plant & Name
  CLEAR: v_left_text, v_right_text.
  CONCATENATE 'Plant             : '  i_itab2-werks INTO v_left_text
                           SEPARATED BY space.
  CONCATENATE 'Name  : ' i_itab2-name INTO v_right_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
  CLEAR: v_left_text, v_right_text.
**--- Res No
  CLEAR: v_left_text, v_right_text.
  CONCATENATE 'Reservation No    : '  i_itab2-rsnum INTO v_left_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' ''.
  CLEAR: v_left_text, v_right_text.
**--- Basic Start date
  WRITE i_itab2-gstrp  TO ld_datum.
  CONCATENATE 'Basic Start date : ' ld_datum INTO v_left_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING    v_left_text '' v_right_text.
ENDFORM.                    " f_hdr_line5
*&---------------------------------------------------------------------*
*&      Form  f_build_event1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_ALV_EVENT[]  text
*----------------------------------------------------------------------*
FORM f_build_event1 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE1'.
  APPEND ft_events.

*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE1'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.

ENDFORM.                    " f_build_event1

*&---------------------------------------------------------------------*
*&      Form  f_cetak_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cetak_form.
  DATA: l_sw(1), l_ctr TYPE i,
        lv_gstrp    TYPE caufv-gstrp.
  l_sw = 1.
  w1 =  3.
  w2 = 10.
  w3 = 40.
  w4 = 17.
  w5 =  4.
  va_ctr = 0. l_ctr = 0.
  SORT i_itab2 BY werks rsnum gstrp matnr.
  LOOP AT i_itab2 INTO wa_itab2.
    ON CHANGE OF wa_itab2-werks OR
                 wa_itab2-gstrp.
      IF l_sw <> 1.
        PERFORM f_write_footer USING wa_itab2-gstrp.
      ENDIF.
      PERFORM f_write_header.
      CLEAR: va_ctr.
    ENDON.
    l_sw = 0.
    ADD 1 TO va_ctr.
    ADD 1 TO l_ctr.
    PERFORM f_write_detail.
    IF l_ctr = 50.
      PERFORM f_write_footer USING wa_itab2-gstrp.
      PERFORM f_write_header.
      l_ctr = 0.
    ENDIF.
    lv_gstrp  = wa_itab2-gstrp.
    CLEAR: wa_itab2.
  ENDLOOP.
  IF l_sw <> 1.
    PERFORM f_write_footer USING lv_gstrp.
  ENDIF.
ENDFORM.                    " f_cetak_form


*          if r_charg is initial.
*             r_charg-low = wa_itab-charg.
*             r_charg-high = wa_itab-charg.
*             r_charg-sign = 'I'.
*             r_charg-option = 'EQ'.
*             Append r_charg.
*             wa_itab1-batch = wa_itab-charg.
*          Endif.
*          if wa_itab-charg in r_charg.
*          Else.
*             r_charg-low = wa_itab-charg.
*             r_charg-high = wa_itab-charg.
*             r_charg-sign = 'I'.
*             r_charg-option = 'EQ'.
*             Append r_charg.
*             Concatenate wa_itab1-batch wa_itab-charg
*                  into wa_itab1-batch separated by ';'.
*          Endif.
*          if r_plnbez is initial.
*             r_plnbez-low = wa_itab-plnbez.
*             r_plnbez-high = wa_itab-plnbez.
*             r_plnbez-sign = 'I'.
*             r_plnbez-option = 'EQ'.
*             Append r_plnbez.
*             wa_itab1-material = wa_itab-plnbez.
*          Endif.
*          if wa_itab-plnbez in r_plnbez.
*          Else.
*             r_plnbez-low = wa_itab-plnbez.
*             r_plnbez-high = wa_itab-plnbez.
*             r_plnbez-sign = 'I'.
*             r_plnbez-option = 'EQ'.
*             Append r_plnbez.
*             Concatenate wa_itab1-material wa_itab-plnbez
*                into wa_itab1-material separated by ';'.
*          Endif.
*          if r_AufNr is initial.
*             r_AufNr-low = wa_itab-AufNr.
*             r_AufNr-high = wa_itab-AufNr.
*             r_AufNr-sign = 'I'.
*             r_AufNr-option = 'EQ'.
*             Append r_AufNr.
*             wa_itab1-po_no = wa_itab-AufNr.
*          Endif.
*          if wa_itab-AufNr in r_AufNr.
*          Else.
*             r_AufNr-low = wa_itab-AufNr.
*             r_AufNr-high = wa_itab-AufNr.
*             r_AufNr-sign = 'I'.
*             r_AufNr-option = 'EQ'.
*             Append r_AufNr.
*             Concatenate wa_itab1-po_no wa_itab-AufNr
*                into wa_itab1-po_no separated by ';'.
*          Endif.
*&---------------------------------------------------------------------*
*&      Form  f_write_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header.
*  PERFORM f_hdr_line5 USING ''.
*  PERFORM f_write_product.


  DATA: v_product(62),
        v_charg(23),
        l_plnbez LIKE wa_linkx-plnbez.

  DATA: v_left_text(40),
          v_right_text(40),
      page_number(10) VALUE 'Page: nnnn',
      progname(42) VALUE 'Program : xx',
      ld_progname(20),
      page(4),
      l_ln TYPE i,
      l_lenght TYPE i,
      ld_sysid(30) VALUE 'Client      : XXX(YYY)',
      ld_datum(10).
  NEW-PAGE.
**--- Program & Page number
  CLEAR: v_left_text, v_right_text.
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.
  PERFORM f_hdr_pad_title1 USING progname sy-title page_number.
  CLEAR: v_left_text, v_right_text.
**--- system info  & Date
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.
  WRITE sy-datum TO ld_datum.
  CONCATENATE 'Date  : ' ld_datum INTO v_right_text
                             SEPARATED BY space.
  CONCATENATE 'Client            : ' sy-sysid(3) '(' sy-mandt ')'
              INTO v_left_text   SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
**--- Plant & Name
  CLEAR: v_left_text, v_right_text.

  CONCATENATE 'Plant             : '  wa_itab2-werks INTO v_left_text
                           SEPARATED BY space.
  CONCATENATE 'Name  : ' wa_itab2-name INTO v_right_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' v_right_text.
  CLEAR: v_left_text, v_right_text.
**--- Res No
  CLEAR: v_left_text, v_right_text.
  CONCATENATE 'Reservation No    : '  wa_itab2-rsnum INTO v_left_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING v_left_text '' ''.
  CLEAR: v_left_text, v_right_text.
**--- Basic Start date
  WRITE wa_itab2-gstrp  TO ld_datum.
  CONCATENATE 'Basic Start date : ' ld_datum INTO v_left_text
                           SEPARATED BY space.
  PERFORM f_hdr_pad_title1 USING    v_left_text '' v_right_text.
*--- Product
  REFRESH: i_linkx_tmp.
  CLEAR: i_linkx_tmp.
  SORT i_linkx BY rsnum.
  LOOP AT i_linkx INTO wa_linkx WHERE rsnum = wa_itab2-rsnum.
    APPEND wa_linkx TO i_linkx_tmp.
    CLEAR: wa_linkx.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM i_linkx_tmp COMPARING plnbez charg.
  IF i_linkx_tmp IS INITIAL.
  ELSE.
    CLEAR: v_product, l_plnbez.
    SORT i_linkx_tmp BY plnbez charg.
    LOOP AT i_linkx_tmp INTO wa_linkx.
      CLEAR v_charg.
      CONCATENATE wa_linkx-charg wa_linkx-aufnr
        INTO v_charg SEPARATED BY '/'.

      IF l_plnbez <> wa_linkx-plnbez.
        CONCATENATE wa_linkx-maktx
                     '('
                     wa_linkx-plnbez
                     ')'
                     INTO v_product.
        WRITE: /  '  Product : ', v_product .
        WRITE: /  '  Batch   : '.
*        IF wa_linkx-charg IS INITIAL.
*        ELSE.
*          WRITE wa_linkx-charg.
*        ENDIF.
        IF v_charg IS INITIAL.
        ELSE.
          WRITE v_charg.
        ENDIF.
      ELSE.
        IF sy-colno < 72.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            WRITE: ',', wa_linkx-charg.
*          ENDIF.
          IF v_charg IS INITIAL.
          ELSE.
            WRITE: ',', v_charg.
          ENDIF.
        ELSE.
          WRITE: /  '            '.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            WRITE wa_linkx-charg.
*          ENDIF.
          IF v_charg IS INITIAL.
          ELSE.
            WRITE v_charg.
          ENDIF.
        ENDIF.
      ENDIF.
      l_plnbez = wa_linkx-plnbez.
      CLEAR: wa_linkx.
    ENDLOOP.
  ENDIF.
  SKIP 1.
  WRITE / sy-uline(85).
  c1 = 1.
  NEW-LINE.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w1 'Nou' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w2 'Material' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w3 'Description' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w4 'Quantity' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 'Unit' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  c1 = 1.
  WRITE: / sy-uline(85).
ENDFORM.                    " f_write_header
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
  DATA: l_text(17).
  c1 = 1.
  NEW-LINE.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w1 va_ctr ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w2 wa_itab2-matnr ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w3 wa_itab2-maktx ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  WRITE wa_itab2-bdmng UNIT wa_itab2-meins TO l_text.
  PERFORM f_write_text USING c1 w4 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 wa_itab2-meins 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_footer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_footer USING fu_gstrp.
  DATA : ls_notes   LIKE LINE OF gt_notes.
  CLEAR ls_notes.
  READ TABLE gt_notes INTO ls_notes
                      WITH KEY gstrp = fu_gstrp.

  WRITE: / sy-uline(85).
  SKIP 1.
  WRITE: / '  Note     : ', ls_notes-sgtxt.
  SKIP 1.
  WRITE: / '  Supervisor Sub Warehouse'.
  SKIP 5.
  WRITE: / '  (......................)'.
  SKIP 1.
ENDFORM.                    " f_write_footer



*&---------------------------------------------------------------------*
*&      Form  f_write_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C  text
*      -->P_W  text
*      -->P_S  text
*----------------------------------------------------------------------*
FORM f_write_text USING    p_c TYPE i
                           p_w TYPE i
                           p_s
                           p_t.
  IF p_t = 'C'.
    WRITE AT p_c(p_w)  p_s NO-GAP  CENTERED.
  ELSE.
    WRITE AT p_c(p_w)  p_s NO-GAP.
  ENDIF.
  p_c = p_c + p_w.

ENDFORM.                    " f_write_text

*&---------------------------------------------------------------------*
*&      Form  print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print.
  DATA: ld_params   LIKE pri_params,
         vspld LIKE  usr01-spld,
         ld_arparams LIKE arc_params.
  DATA: ld_layout   LIKE sy-paart,     "Druck-Layout
        ld_valid.

  NEW-PAGE LINE-SIZE 80.
* Standardlayout zum im Benutzerstamm eingetragenen Drucker setzen
  SELECT SINGLE spld INTO vspld FROM usr01 WHERE bname = sy-uname.
  PERFORM set_layout(saplspri) USING    vspld 1 sy-linsz 1 sy-linsz
                               CHANGING ld_layout.
  CALL FUNCTION 'GET_PRINT_PARAMETERS'
       EXPORTING
            immediately            = 'X'
            cover_page             = space
            sap_cover_page         = space
*            RELEASE                = 'X'
*            NEW_LIST_ID            = SPACE
            host_cover_page        = space
            line_size              = 80
            layout                 = ld_layout
       IMPORTING
            out_parameters         = ld_params
            out_archive_parameters = ld_arparams
            valid                  = ld_valid.
  IF sy-subrc EQ 0.
    NEW-PAGE PRINT ON PARAMETERS ld_params
                   ARCHIVE PARAMETERS ld_arparams
                   NEW-SECTION NO DIALOG.
    PERFORM f_cetak_form.
    NEW-PAGE PRINT OFF.
  ENDIF.


ENDFORM.                    " print
*&---------------------------------------------------------------------*
*&      Form  f_validate_data21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data21.
  DATA: l_ctr TYPE i.
  DATA: mod LIKE wa_itab-bdmng,
        l_batch(25),
        l_link(45),
        nomor TYPE i,
        l_sw(1).
  DATA : ls_notes   LIKE LINE OF gt_notes.

  RANGES: r_link   FOR l_link,
          r_batch  FOR l_batch.
  break bcsuk.
  SORT i_itab BY werks bdter matnr.
  REFRESH: r_batch, r_link, i_itab2.
  FREE: i_itab2, r_batch, r_link.
  CLEAR: l_sw, i_itab1, r_batch, r_link,l_ctr, nomor.
  REFRESH: i_linkx_tmp, i_linkx. CLEAR: i_linkx_tmp, i_linkx.
  CLEAR: nomor.
  SORT i_itab BY rsnum gstrp matnr.
  LOOP AT i_itab INTO wa_itab.
    ON CHANGE OF wa_itab-rsnum.
      ADD 1 TO nomor.
      LOOP AT i_zgdppdt0001 INTO wa_zgdppdt0001
           WHERE rsnum = wa_itab-rsnum.
        wa_linkx-nomor  = nomor.
        wa_linkx-rsnum  = wa_itab-rsnum.
        wa_linkx-aufnr  = wa_zgdppdt0001-aufnr.
        wa_linkx-charg  = wa_zgdppdt0001-charg.
        wa_linkx-plnbez = wa_zgdppdt0001-matnr.
        wa_linkx-gstrp  = wa_zgdppdt0001-gstrp.
*{   INSERT         P01K910252                                        1
        "Start SOH: Shell SCI Adjustment 20240221 RZL
        SORT i_makt by matnr.
        "End SOH: Shell SCI Adjustment 20240221 RZL
*}   INSERT
        READ TABLE i_makt INTO wa_makt WITH
             KEY matnr = wa_zgdppdt0001-matnr
             BINARY SEARCH.
        IF sy-subrc EQ 0.
          wa_linkx-maktx  = wa_makt-maktx.
        ELSE.
          CLEAR: wa_linkx-maktx.
        ENDIF.
        APPEND wa_linkx TO i_linkx.
      ENDLOOP.
    ENDON.
    MOVE-CORRESPONDING wa_itab TO wa_itab1.
    wa_itab1-nomor = nomor.
    wa_itab1-gstrp = wa_itab-bdter.
    APPEND wa_itab1 TO i_itab2.
    CLEAR: wa_itab, wa_itab1.
  ENDLOOP.

  LOOP AT i_itab2 INTO wa_itab1.
    ls_notes-gstrp  = wa_itab1-gstrp.
    ls_notes-sgtxt  = wa_itab1-sgtxt.
    APPEND ls_notes TO gt_notes.
    CLEAR ls_notes.
  ENDLOOP.

  SORT gt_notes BY gstrp.
  DELETE ADJACENT DUPLICATES FROM gt_notes COMPARING gstrp.
ENDFORM.                    " f_validate_data21
*&---------------------------------------------------------------------*
*&      Form  f_write_product
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_product.
  DATA:
        v_product(62),
        v_charg(23),
        l_plnbez LIKE wa_linkx-plnbez.
*--- Product
  REFRESH: i_linkx_tmp.
  CLEAR: i_linkx_tmp.
  LOOP AT i_linkx INTO wa_linkx WHERE gstrp = i_itab2-gstrp.
*  LOOP AT i_linkx INTO wa_linkx WHERE nomor = i_itab2-nomor.
    APPEND wa_linkx TO i_linkx_tmp.
    CLEAR: wa_linkx.
  ENDLOOP.
  SORT i_linkx_tmp BY plnbez charg.
  DELETE ADJACENT DUPLICATES FROM i_linkx_tmp COMPARING plnbez charg.
  IF i_linkx_tmp IS INITIAL.
  ELSE.
    CLEAR: v_product, l_plnbez.
    SORT i_linkx_tmp BY plnbez charg.
    LOOP AT i_linkx_tmp INTO wa_linkx.
      CLEAR v_charg.
      CONCATENATE wa_linkx-charg wa_linkx-aufnr
        INTO v_charg SEPARATED BY '/'.

      IF l_plnbez <> wa_linkx-plnbez.
        CONCATENATE wa_linkx-maktx
                     '('
                     wa_linkx-plnbez
                     ')'
                     INTO v_product.
        WRITE: /  '  Product : ', v_product .
        WRITE: /  '  Batch   : '.
*        IF wa_linkx-charg IS INITIAL.
*        ELSE.
*          WRITE wa_linkx-charg.
*        ENDIF.
        IF v_charg IS INITIAL.
        ELSE.
          WRITE v_charg.
        ENDIF.

      ELSE.
        IF sy-colno < 72.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            WRITE: ',', wa_linkx-charg.
*          ENDIF.
          IF v_charg IS INITIAL.
          ELSE.
            WRITE: ',', v_charg.
          ENDIF.
        ELSE.
          WRITE: /  '            '.
*          IF wa_linkx-charg IS INITIAL.
*          ELSE.
*            WRITE wa_linkx-charg.
*          ENDIF.
          IF v_charg IS INITIAL.
          ELSE.
            WRITE v_charg.
          ENDIF.
        ENDIF.
      ENDIF.
      l_plnbez = wa_linkx-plnbez.
      CLEAR: wa_linkx.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_write_product

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  IF p_werks IS INITIAL.
    PERFORM f_error_message USING 'PWE' ''.
  ENDIF.

  IF p_umlgo IS INITIAL.
    PERFORM f_error_message USING 'PUM' ''.
  ENDIF.

  IF p_lgort IS INITIAL.
    IF option = 1 OR option = 3.
      PERFORM f_error_message USING 'PLG' ''.
    ENDIF.
  ENDIF.

*  IF so_aufnr[] IS INITIAL.
*    PERFORM f_error_message USING 'SAU' ''.
*  ENDIF.
*
*  IF pa_mtart IS INITIAL.
*    PERFORM f_error_message USING 'PMT' ''.
*  ENDIF.

ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_RESERVATION
*&---------------------------------------------------------------------*
FORM f_cancel_reservation .
  DATA: lt_itab2  TYPE TABLE OF ta_itab1 WITH HEADER LINE,
        lt_resbx  TYPE TABLE OF resb WITH HEADER LINE,
        lt_ltbc   TYPE TABLE OF ltbc WITH HEADER LINE,
        lt_ltbp   TYPE TABLE OF ltbp WITH HEADER LINE,
        ls_ltbk   TYPE ltbk,
        lt_zgdppdt0001 TYPE TABLE OF zgdppdt0001 WITH HEADER LINE.

  lt_itab2[] = i_itab2[].
  DELETE lt_itab2 WHERE chkbox NE 'X'.

  IF lt_itab2[] IS NOT INITIAL.

    "Change reservation
*{   REPLACE        P01K910252                                        1
*\    SELECT * INTO TABLE lt_resbx
*\      FROM resb FOR ALL ENTRIES IN lt_itab2
*\      WHERE rsnum = lt_itab2-rsnum
*\        AND matnr = lt_itab2-matnr.
"Start SOH: Shell SCI Adjustment 20240221 RZL
    "Start SOH: Shell SCI Adjustment 20240221 RZL
    SELECT * INTO TABLE lt_resbx
      FROM resb FOR ALL ENTRIES IN lt_itab2
      WHERE rsnum = lt_itab2-rsnum
        AND matnr = lt_itab2-matnr ORDER BY PRIMARY KEY.
"End SOH: Shell SCI Adjustment 20240221 RZL
*}   REPLACE

    lt_resbx-xloek = 'X'.
    MODIFY lt_resbx TRANSPORTING xloek WHERE xloek = space.

    CALL FUNCTION 'MB_CHANGE_RESERVATION'
         EXPORTING
           change_resb = 'X'
           change_rkpf = ' '
           new_resb    = ' '
         TABLES
*           dis         =
           xresb       = lt_resbx.
*           xresbn      =
*           xreul       =
*           xreuld      =
*           xreuln      =
*           xrkpf       =
*           zresb       =.

    "Cancel TR
    SELECT SINGLE * INTO ls_ltbk
      FROM ltbk WHERE tbktx = p_rsnum.      "rsnum = p_rsnum.

    SELECT * INTO TABLE lt_ltbp
      FROM ltbp FOR ALL ENTRIES IN lt_itab2
      WHERE lgnum = ls_ltbk-lgnum
        AND tbnum = ls_ltbk-tbnum
        AND matnr = lt_itab2-matnr.

    LOOP AT lt_ltbp.
      lt_ltbc-lgnum   = lt_ltbp-lgnum.
      lt_ltbc-tbnum   = lt_ltbp-tbnum.
      lt_ltbc-tbpos   = lt_ltbp-tbpos.
      lt_ltbc-menga   = lt_ltbp-menga.
      APPEND lt_ltbc.
    ENDLOOP.

    IF lt_ltbc[] IS NOT INITIAL.
      CALL FUNCTION 'L_TR_CANCEL'
        TABLES
          t_ltbc               = lt_ltbc
        EXCEPTIONS
          item_error           = 1
          no_update_item_error = 2
          no_update_no_entry   = 3
          OTHERS               = 4.

      IF sy-subrc IS INITIAL.
        SELECT * INTO TABLE lt_zgdppdt0001
          FROM zgdppdt0001 FOR ALL ENTRIES IN lt_itab2
          WHERE werks = lt_itab2-werks
            AND rsnum = lt_itab2-rsnum
            AND gstrp = lt_itab2-gstrp
            AND matnr = lt_itab2-matnr
            AND aufnr = lt_itab2-aufnr.

        lt_zgdppdt0001-nctrl = 'C'.
        MODIFY lt_zgdppdt0001 TRANSPORTING nctrl WHERE nctrl = space.

        TRY .
            MODIFY zgdppdt0001 FROM TABLE lt_zgdppdt0001.
          CATCH cx_sy_open_sql_db INTO oref.
            lv_message = oref->get_text( ).
        ENDTRY.

        IF lv_message IS INITIAL.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
    ENDIF.

    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_CANCEL_RESERVATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_RESB
*&---------------------------------------------------------------------*
FORM f_get_resb .
  DATA: lt_resb TYPE TABLE OF resb WITH HEADER LINE,
        lt_ltak TYPE TABLE OF ltak WITH HEADER LINE,
        lt_ltap TYPE TABLE OF ltap WITH HEADER LINE,
        lt_ltbp TYPE TABLE OF ltbp WITH HEADER LINE,
        ls_ltbk TYPE ltbk.

  IF option = 2 AND radio2 = 'X' AND
     ( p_werks = '0101' OR p_werks = '0102' ).
    SELECT SINGLE * INTO ls_ltbk
      FROM ltbk WHERE tbktx = p_rsnum.          "rsnum = p_rsnum.

    SELECT lgnum tbnum tbpos elikz matnr werks charg menge meins tanum
      INTO CORRESPONDING FIELDS OF TABLE lt_ltbp
      FROM ltbp WHERE lgnum = ls_ltbk-lgnum
                  AND tbnum = ls_ltbk-tbnum.

    IF lt_ltbp[] IS NOT INITIAL.
      SELECT a~lgnum a~tanum tapos matnr werks charg
        INTO CORRESPONDING FIELDS OF TABLE lt_ltap
        FROM ltap AS a JOIN ltak AS b ON a~lgnum = b~lgnum AND
                                         a~tanum = b~tanum
        FOR ALL ENTRIES IN lt_ltbp
        WHERE a~lgnum = lt_ltbp-lgnum
          AND a~tanum = lt_ltbp-tanum
          AND a~matnr = lt_ltbp-matnr
          AND b~tbnum = ls_ltbk-tbnum.
    ENDIF.
  ENDIF.

  SELECT rsnum rspos xloek matnr werks lgort umwrk umlgo
    INTO CORRESPONDING FIELDS OF TABLE lt_resb
    FROM resb FOR ALL ENTRIES IN i_itab2
    WHERE rsnum = i_itab2-rsnum
      AND matnr = i_itab2-matnr.

  SORT i_itab2 BY rsnum matnr.
  SORT lt_resb BY rsnum matnr.

  LOOP AT i_itab2.
    CLEAR lt_resb.
    READ TABLE lt_resb WITH KEY rsnum = i_itab2-rsnum.
    i_itab2-lgort = lt_resb-umlgo.
    MODIFY i_itab2 TRANSPORTING lgort.

    IF option = 2 AND radio2 = 'X'.
      CASE p_werks.
        WHEN '0101' OR '0102'.
          CLEAR: lt_ltbp,lt_resb,lt_ltap.
          READ TABLE lt_ltbp WITH KEY matnr = i_itab2-matnr.
          IF lt_ltbp-elikz IS NOT INITIAL.
            READ TABLE lt_resb WITH KEY matnr = i_itab2-matnr.
            IF lt_resb-xloek = 'X'.
              i_itab2-chkbox = '2'.
              i_itab2-msg = 'Item is deleted'.
              MODIFY i_itab2 TRANSPORTING chkbox msg.
            ELSE.
              READ TABLE lt_ltap WITH KEY matnr = i_itab2-matnr.
              IF sy-subrc = 0.
                i_itab2-chkbox = '2'.
                i_itab2-msg = 'TO already created'.
                MODIFY i_itab2 TRANSPORTING chkbox msg.
              ENDIF.
            ENDIF.
          ENDIF.

        WHEN '0901'.
          CLEAR: lt_resb.
          READ TABLE lt_resb WITH KEY matnr = i_itab2-matnr.
          IF lt_resb-xloek = 'X'.
            i_itab2-chkbox = '2'.
            i_itab2-msg = 'Item is deleted'.
            MODIFY i_itab2 TRANSPORTING chkbox msg.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_RESB
