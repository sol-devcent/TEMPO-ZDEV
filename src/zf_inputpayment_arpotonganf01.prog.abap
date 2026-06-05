*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_zfarpotd2   LIKE gt_zfarpotd2 OCCURS 0.

  SELECT *
    FROM tbsl
    INTO CORRESPONDING FIELDS OF TABLE gt_tbsl.

  CASE 'X'.
    WHEN p_input.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
        FROM zfarpoth
        WHERE bukrs = p_bukrs AND
              gsber = p_gsber AND
              vkbur = p_vkbur AND
              noarp = p_noarp AND
              mjahr = p_mjahr AND
              belnr NE space  AND
              belnrrev = space AND
              daterev = '00000000' AND
              userrev = space.
      IF gt_zfarpoth[] IS NOT INITIAL.
* Get Detail AR Potongan
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd
          FROM zfarpotd AS a INNER JOIN kna1 AS b ON a~kunnr = b~kunnr
          FOR ALL ENTRIES IN gt_zfarpoth
          WHERE bukrs = p_bukrs AND
                gsber = p_gsber AND
                vkbur = p_vkbur AND
                noarp = gt_zfarpoth-noarp AND
                mjahr = gt_zfarpoth-mjahr AND
                rtvnr IN s_nortv.

        IF gt_zfarpotd[] IS NOT INITIAL.
          gt_xfarpotd[] = gt_zfarpotd[].

          SELECT *
            FROM zfarpotdcn
            INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotdcn
            FOR ALL ENTRIES IN gt_zfarpotd
            WHERE bukrs = gt_zfarpotd-bukrs
              AND gsber = gt_zfarpotd-gsber
              AND vkbur = gt_zfarpotd-vkbur
              AND noarp = gt_zfarpotd-noarp
              AND mjahr = gt_zfarpotd-mjahr
              AND rtvnr = gt_zfarpotd-rtvnr
              AND stblg = space.
        ENDIF.

        LOOP AT gt_zfarpotd.
          IF gt_zfarpotd-posamt GE gt_zfarpotd-rtvamt.
            DELETE gt_zfarpotd. CLEAR gt_zfarpotd.
            CONTINUE.
          ENDIF.
          gt_zfarpotd-zuonr = gt_zfarpotd-rtvnr.
          MODIFY gt_zfarpotd TRANSPORTING zuonr.
        ENDLOOP.

* Get Block AR
        IF gt_zfarpotd[] IS NOT INITIAL.
          SELECT bukrs gsber vkbur noform zuonr belnrpos2
            INTO CORRESPONDING FIELDS OF TABLE gt_zfhkr1at
            FROM zfh_kr1at
            FOR ALL ENTRIES IN gt_zfarpotd
            WHERE bukrs = gt_zfarpotd-bukrs AND
                  gsber = gt_zfarpotd-gsber AND
                  vkbur = gt_zfarpotd-vkbur AND
                  zuonr = gt_zfarpotd-zuonr AND
                  kunnr = gt_zfarpotd-kunnr AND
                  belnrpos2 = space.
        ENDIF.
      ENDIF.

      PERFORM f_get_bi_data.

    WHEN p_revrs.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
        FROM zfarpoth
        WHERE bukrs = p_bukrs AND
              gsber = p_gsber AND
              vkbur = p_vkbur AND
              noarp = p_noarp AND
              mjahr = p_mjahr AND
              budat IN s_budat AND
              belnr NE space  AND
              belnrrev = space AND
              daterev = '00000000' AND
              userrev = space.
      IF sy-subrc = 0.
* Get Detail AR Potongan
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd
          FROM zfarpotd AS a JOIN kna1 AS b ON a~kunnr = b~kunnr
          FOR ALL ENTRIES IN gt_zfarpoth
          WHERE bukrs = p_bukrs AND
                gsber = p_gsber AND
                vkbur = p_vkbur AND
                noarp = gt_zfarpoth-noarp AND
                mjahr = gt_zfarpoth-mjahr." AND
* Get Detail Payment
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd2
          FROM zfarpotd2
          FOR ALL ENTRIES IN gt_zfarpoth
          WHERE bukrs = p_bukrs AND
                gsber = p_gsber AND
                vkbur = p_vkbur AND
                noarp = gt_zfarpoth-noarp AND
                mjahr = gt_zfarpoth-mjahr AND
                belnr = p_belnr.
      ENDIF.

      lt_zfarpotd2[] = gt_zfarpotd2[].
      SORT lt_zfarpotd2 BY bukrs gsber vkbur noarp mjahr belnr.
      DELETE ADJACENT DUPLICATES FROM lt_zfarpotd2
      COMPARING bukrs gsber vkbur noarp mjahr belnr.
      IF lt_zfarpotd2[] IS NOT INITIAL.
        SELECT *
          FROM zfarpotdcn
          INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotdcn
          FOR ALL ENTRIES IN lt_zfarpotd2
          WHERE bukrs = lt_zfarpotd2-bukrs
            AND gsber = lt_zfarpotd2-gsber
            AND vkbur = lt_zfarpotd2-vkbur
            AND noarp = lt_zfarpotd2-noarp
            AND mjahr = lt_zfarpotd2-mjahr
            AND belnr = lt_zfarpotd2-belnr.
      ENDIF.

    WHEN p_lapor OR p_grept.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
        FROM zfarpoth
        WHERE bukrs = p_bukrs AND
              gsber = p_gsber AND
              vkbur = p_vkbur AND
              noarp IN s_noarp AND
              mjahr = p_mjahr AND
              budat IN s_budat.
      IF sy-subrc = 0.
* Get Detail AR Potongan
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd
          FROM zfarpotd AS a JOIN kna1 AS b ON a~kunnr = b~kunnr
          FOR ALL ENTRIES IN gt_zfarpoth
          WHERE bukrs = p_bukrs AND
                gsber = p_gsber AND
                vkbur = p_vkbur AND
                noarp = gt_zfarpoth-noarp AND
                mjahr = gt_zfarpoth-mjahr.
* Get Detail Payment
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd2
          FROM zfarpotd2
          FOR ALL ENTRIES IN gt_zfarpoth
          WHERE bukrs = p_bukrs AND
                gsber = p_gsber AND
                vkbur = p_vkbur AND
                noarp = gt_zfarpoth-noarp AND
                mjahr = gt_zfarpoth-mjahr.
      ENDIF.
  ENDCASE.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  IF p_revrs = 'X'.
    SORT gt_zfarpoth BY bukrs gsber vkbur noarp mjahr.
    SORT gt_zfarpotdet BY bukrs gsber vkbur noarp mjahr posnr belnr.
    PERFORM f_alv_hierarchy TABLES gt_zfarpoth gt_zfarpotdet.

  ELSEIF p_lapor = 'X'.
    SORT gt_zfarpoth BY bukrs gsber vkbur noarp mjahr.
    SORT gt_zfarpotdet BY bukrs gsber vkbur noarp mjahr posnr belnr.
    PERFORM f_alv_hierarchy TABLES gt_zfarpoth gt_zfarpotdet.

  ELSEIF p_grept = 'X'.
    PERFORM f_alv TABLES gt_greport.
  ENDIF.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

*  IF pa_grid IS NOT INITIAL.
*    lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
*    lv_title   = sy-title.
*  ELSE.
*    PERFORM f_build_event       TABLES  t_alv_event[].
*    lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
*  ENDIF.

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

*&---------------------------------------------------------------------*
*&      Form  F_ALV_HIERARCHY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_HDR  text
*      -->P_T_OUT  text
*----------------------------------------------------------------------*
FORM f_alv_hierarchy  TABLES   ft_hdr
                               ft_out.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat_hierarchy TABLES ft_hdr ft_out.
  PERFORM f_build_layout_hierarchy   USING  d_layout.
  PERFORM f_build_sortfield          USING  t_alv_isort[].
  PERFORM f_build_event              TABLES t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_key                USING  d_alv_keyinfo.
  PERFORM f_build_print              USING  d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
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
      i_tabname_header         = 'GT_ZFARPOTH'
      i_tabname_item           = 'GT_ZFARPOTDET'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_hdr
      t_outtab_item            = ft_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_ALV_HIERARCHY

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'GT_GREPORT':
    'BUKRS' 'ZFARPOTH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'ZFARPOTH' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFARPOTH' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
    'NOARP' 'ZFARPOTH' 'NOARP' '' '' '' '' '' '' '' '' '' '' '' '',
    'MJAHR' 'ZFARPOTH' 'MJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDAT' 'ZFARPOTH' 'ERDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'BUDAT' 'ZFARPOTH' 'BUDAT' '' '' 'Post. Date' '' '' '' '' '' '' '' '' '',
    'TXARP' 'ZFARPOTH' 'TXARP' '' '' 'Post. Text' '' '' '' '' '' '' '' '' '',
    'VOUCR' 'ZFARPOTH' 'VOUCR' '' '' 'Post. Voucher' '' '' '' '' '' '' '' '' '',
    'HKONT' 'ZFARPOTH' 'HKONT' '' '' 'Post. Acct.' '' '' '' '' '' '' '' '' '',
    'AMOUNT' 'ZFARPOTH' 'AMOUNT' '' '' 'Post. Amount' '' '' '' 'IDR' '' '' '' '' '',
    'BELNR' 'ZFARPOTH' 'BELNR' '' '' 'Post. Doc.' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFARPOTH' 'GJAHR' '' '' 'Post. Year' '' '' '' '' '' '' '' '' '',
    'BELNRREV' 'ZFARPOTH' 'BELNRREV' '' '' 'Post.Rev.Doc.' '' '' '' '' '' '' '' '' '',
    'BLDAT' 'ZFARPOTH' 'BLDAT' '' '' 'Det.Pay.Date' '' '' '' '' '' '' '' '' '',
    'NODPY' 'ZFARPOTH' 'NODPY' '' '' 'Det.Pay.No' '' '' '' '' '' '' '' '' '',

    'POSNR' 'ZFARPOTD' 'POSNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZFARPOTD' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' 'Customer Name' '' '' '' '' '' '' '' '' '',
    'RTVTYP' 'ZFARPOTD' 'RTVTYP' '' '' 'Type' '' '' '' '' '' '' '' '' '',
    'RTVNR' 'ZFARPOTD' 'RTVNR' '' '' 'No. RTV/Inv.' '' '' '' '' '' '' '' '' '',
    'RTVDT' 'ZFARPOTD' 'RTVDT' '' '' 'Date RTV/Inv.' '' '' '' '' '' '' '' '' '',
    'RTVAMT' 'ZFARPOTD' 'RTVAMT' '' '' 'Amount RTV/Inv.' '' '' '' 'IDR' '' '' '' '' '',
    'POSAMT' 'ZFARPOTD' 'POSAMT' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'INPAMT' 'ZFARPOTD' 'INPAMT' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'RTVKET' 'ZFARPOTD' 'RTVKET' '' '' 'Text RTV/Inv.' '' '' '' '' '' '' '' '' '',
    'DBELNR' 'ZFARPOTD' 'BELNR' '' '' 'Pay. Doc.' '' '' '' '' '' '' '' '' '',
    'DGJAHR' 'ZFARPOTD' 'GJAHR' '' '' 'Pay. Year' '' '' '' '' '' '' '' '' '',
    'DBUDAT' 'ZFARPOTD' 'BUDAT' '' '' 'Pay.Post.Date' '' '' '' '' '' '' '' '' '',
    'DBELNRREV' 'ZFARPOTD' 'BELNRREV' '' '' 'Pay.Rev.Doc.' '' '' '' '' '' '' '' '' '',
    'DTXARP' 'ZFARPOTD' 'TXARP' '' '' 'Pay. Text' '' '' '' '' '' '' '' '' '',
    'DVOUCR' 'ZFARPOTD' 'VOUCR' '' '' 'Pay. Voucher' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcat_hierarchy                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat_hierarchy TABLES ft_hdr ft_out.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'GT_ZFARPOTH':
    'BUKRS' 'ZFARPOTH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'ZFARPOTH' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFARPOTH' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
    'NOARP' 'ZFARPOTH' 'NOARP' '' '' '' '' '' '' '' '' '' '' '' '',
    'MJAHR' 'ZFARPOTH' 'MJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNR' 'ZFARPOTH' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFARPOTH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
*    'BELNRPAY' 'ZFARPOTH' 'BELNR' '' '' 'PaymentNo' '' 'X' '' '' '' '' '' '' '',
*    'GJAHRPAY' 'ZFARPOTH' 'GJAHR' '' '' 'PaymentYr' '' '' '' '' '' '' '' '' '',
    'ERDAT' 'ZFARPOTH' 'ERDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'BUDAT' 'ZFARPOTH' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'HKONT' 'ZFARPOTH' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '',
    'VOUCR' 'ZFARPOTH' 'VOUCR' '' '' '' '' '' '' '' '' '' '' '' '',
    'TXARP' 'ZFARPOTH' 'TXARP' '' '' '' '' '' '' '' '' '' '' '' '',
    'AMOUNT' 'ZFARPOTH' 'AMOUNT' '' '' '' '' '' '' 'IDR' '' '' '' '' ''.
*    'BELNR' 'ZFARPOTH' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '',
*    'GJAHR' 'ZFARPOTH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
*    'BELNRPAY' 'ZFARPOTH' 'BELNR' '' '' 'PaymentNo' '' '' '' '' '' '' '' '' '',
*    'GJAHRPAY' 'ZFARPOTH' 'GJAHR' '' '' 'PaymentYr' '' '' '' '' '' '' '' '' '',
*    'BELNRREV' 'ZFARPOTH' 'BELNRREV' '' '' '' '' '' '' '' '' '' '' '' '',
*    'DATEREV' 'ZFARPOTH' 'DATEREV' '' '' '' '' '' '' '' '' '' '' '' '',
*    'USERREV' 'ZFARPOTH' 'USERREV' '' '' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'GT_ZFARPOTDET':
    'POSNR' 'ZFARPOTD' 'POSNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVTYP' 'ZFARPOTD' 'RTVTYP' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZFARPOTD' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVNR' 'ZFARPOTD' 'RTVNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVDT' 'ZFARPOTD' 'RTVDT' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVAMT' 'ZFARPOTD' 'RTVAMT' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'POSAMT' 'ZFARPOTD' 'POSAMT' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'INPAMT' 'ZFARPOTD' 'INPAMT' '' '' 'Post Amount' '' '' '' 'IDR' '' '' '' '' '',
    'BELNR' 'ZFARPOTD' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFARPOTD' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNRREV' 'ZFARPOTD' 'BELNRREV' '' '' '' '' '' '' '' '' '' '' '' '',
    'DATEREV' 'ZFARPOTD' 'DATEREV' '' '' '' '' '' '' '' '' '' '' '' '',
*    'USERREV' 'ZFARPOTD' 'USERREV' '' '' '' '' '' '' '' '' '' '' '' ''.
    'RTVKET' 'ZFARPOTD' 'RTVKET' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT_hierarchy

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
                          VALUE(fu_input).

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
*  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_layout_hierarchy                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout_hierarchy USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  fu_layout-expand_fieldname  = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
  IF p_revrs = 'X'.
    fu_layout-box_fieldname      = 'CHECK'.
  ENDIF.
ENDFORM.                    "f_build_layout_hierarchy

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

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_ALV_KEYINFO  text
*----------------------------------------------------------------------*
FORM f_build_key  USING fd_alv_keyinfo TYPE slis_keyinfo_alv.
  fd_alv_keyinfo-header01 = 'NOARP'.
  fd_alv_keyinfo-item01   = 'NOARP'.

  fd_alv_keyinfo-header02 = 'MJAHR'.
  fd_alv_keyinfo-item02   = 'MJAHR'.
*
*  fd_alv_keyinfo-header03 = 'BELNRPAY'.
*  fd_alv_keyinfo-item03   = 'BELNR'.
*
*  fd_alv_keyinfo-header04 = 'GJAHRPAY'.
*  fd_alv_keyinfo-item04   = 'GJAHR'.
ENDFORM.                    " F_BUILD_KEY

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
  ld_sort-fieldname = 'BUKRS'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'GSBER'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'NOARP'.
  ld_sort-up        = 'X'.
  IF p_grept = 'X'.
    ld_sort-group     = 'UL'.
  ENDIF.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MJAHR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  IF p_grept = 'X'.
    CLEAR ld_sort.
    ld_sort-fieldname = 'POSNR'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.
  ENDIF.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: ld_title(100).

  CASE 'X'.
    WHEN p_revrs.
      CONCATENATE 'Reverse' sy-title INTO ld_title SEPARATED BY space.
    WHEN p_lapor.
      CONCATENATE 'Report' sy-title INTO ld_title SEPARATED BY space.
    WHEN p_grept.
      CONCATENATE 'General Report' sy-title INTO ld_title SEPARATED BY space.
  ENDCASE.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING ld_title.
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
  CLEAR: gt_zfarpoth, gt_zfarpoth[],gt_zfarpotd, gt_zfarpotd[],
         gt_zfarpotd2, gt_zfarpotd2[].
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
    WHEN p_revrs.
      SET PF-STATUS 'REVERSE'.
    WHEN p_lapor.
      SET PF-STATUS 'STANDARD'.
    WHEN p_grept.
      SET PF-STATUS 'GREPORT'.
  ENDCASE.
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
  DATA: ld_flag(1).

  CASE 'X'.
    WHEN p_input.
      LOOP AT gt_zfarpoth.
        LOOP AT gt_zfarpotd WHERE bukrs = gt_zfarpoth-bukrs AND
                                  gsber = gt_zfarpoth-gsber AND
                                  vkbur = gt_zfarpoth-vkbur AND
                                  noarp = gt_zfarpoth-noarp AND
                                  mjahr = gt_zfarpoth-mjahr.
          READ TABLE gt_zfhkr1at WITH KEY bukrs = gt_zfarpotd-bukrs
                                          gsber = gt_zfarpotd-gsber
                                          vkbur = gt_zfarpotd-vkbur
                                          zuonr = gt_zfarpotd-zuonr.
          IF sy-subrc = 0.
            DELETE gt_zfarpotd.
          ELSE.
            CLEAR: gt_zfarpotd-belnr,gt_zfarpotd-gjahr,gt_zfarpotd-belnrrev,
                   gt_zfarpotd-daterev,gt_zfarpotd-userrev.
            MODIFY gt_zfarpotd TRANSPORTING belnr gjahr belnrrev daterev userrev.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      LOOP AT gt_zfarpoth.
        READ TABLE gt_zfarpotd WITH KEY bukrs = gt_zfarpoth-bukrs
                                        gsber = gt_zfarpoth-gsber
                                        vkbur = gt_zfarpoth-vkbur
                                        noarp = gt_zfarpoth-noarp
                                        mjahr = gt_zfarpoth-mjahr.
        IF sy-subrc NE 0.
          DELETE gt_zfarpoth.
        ENDIF.
      ENDLOOP.

      SORT gt_zfarpoth BY bukrs gsber vkbur noarp mjahr.
      SORT gt_zfarpotd BY bukrs gsber vkbur noarp mjahr posnr.

*      PERFORM f_modify_bi.
      PERFORM f_modify_bi_new.

    WHEN p_revrs.
      LOOP AT gt_zfarpoth.
        LOOP AT gt_zfarpotd WHERE bukrs = gt_zfarpoth-bukrs AND
                                  gsber = gt_zfarpoth-gsber AND
                                  vkbur = gt_zfarpoth-vkbur AND
                                  noarp = gt_zfarpoth-noarp AND
                                  mjahr = gt_zfarpoth-mjahr.
          READ TABLE gt_zfarpotd2 WITH KEY bukrs = gt_zfarpoth-bukrs
                                           gsber = gt_zfarpoth-gsber
                                           vkbur = gt_zfarpoth-vkbur
                                           noarp = gt_zfarpoth-noarp
                                           mjahr = gt_zfarpoth-mjahr
                                           posnr = gt_zfarpotd-posnr
                                           belnrrev = space.
          IF sy-subrc = 0.
            LOOP AT gt_zfarpotd2 WHERE bukrs = gt_zfarpoth-bukrs AND
                                       gsber = gt_zfarpoth-gsber AND
                                       vkbur = gt_zfarpoth-vkbur AND
                                       noarp = gt_zfarpoth-noarp AND
                                       mjahr = gt_zfarpoth-mjahr AND
                                       posnr = gt_zfarpotd-posnr AND
                                       belnrrev = space.
              MOVE-CORRESPONDING gt_zfarpotd TO gt_zfarpotdet.
              WRITE gt_zfarpotd2-belnr TO gt_zfarpotdet-belnr.
              gt_zfarpotdet-gjahr = gt_zfarpotd2-gjahr.
              gt_zfarpotdet-budat = gt_zfarpotd2-budat.
              gt_zfarpotdet-buzet = gt_zfarpotd2-buzet.
              gt_zfarpotdet-bunam = gt_zfarpotd2-bunam.
              gt_zfarpotdet-inpamt = gt_zfarpotd2-rtvamt.
              APPEND gt_zfarpotdet.
            ENDLOOP.
          ELSE.
            DELETE gt_zfarpotd.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      LOOP AT gt_zfarpoth.
        READ TABLE gt_zfarpotd WITH KEY bukrs = gt_zfarpoth-bukrs
                                        gsber = gt_zfarpoth-gsber
                                        vkbur = gt_zfarpoth-vkbur
                                        noarp = gt_zfarpoth-noarp
                                        mjahr = gt_zfarpoth-mjahr.
        IF sy-subrc NE 0.
          DELETE gt_zfarpoth.
        ENDIF.
      ENDLOOP.

    WHEN p_lapor.
      LOOP AT gt_zfarpoth.
        LOOP AT gt_zfarpotd WHERE bukrs = gt_zfarpoth-bukrs AND
                                  gsber = gt_zfarpoth-gsber AND
                                  vkbur = gt_zfarpoth-vkbur AND
                                  noarp = gt_zfarpoth-noarp AND
                                  mjahr = gt_zfarpoth-mjahr.
          LOOP AT gt_zfarpotd2 WHERE bukrs = gt_zfarpoth-bukrs AND
                                     gsber = gt_zfarpoth-gsber AND
                                     vkbur = gt_zfarpoth-vkbur AND
                                     noarp = gt_zfarpoth-noarp AND
                                     mjahr = gt_zfarpoth-mjahr AND
                                     posnr = gt_zfarpotd-posnr.
            MOVE-CORRESPONDING gt_zfarpotd TO gt_zfarpotdet.
            gt_zfarpotdet-belnr = gt_zfarpotd2-belnr.
            gt_zfarpotdet-gjahr = gt_zfarpotd2-gjahr.
            gt_zfarpotdet-budat = gt_zfarpotd2-budat.
            gt_zfarpotdet-buzet = gt_zfarpotd2-buzet.
            gt_zfarpotdet-bunam = gt_zfarpotd2-bunam.
            gt_zfarpotdet-inpamt = gt_zfarpotd2-rtvamt.
            gt_zfarpotdet-belnrrev =  gt_zfarpotd2-belnrrev.
            gt_zfarpotdet-daterev = gt_zfarpotd2-daterev.
            APPEND gt_zfarpotdet.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

    WHEN p_grept.
      LOOP AT gt_zfarpoth.
        LOOP AT gt_zfarpotd WHERE bukrs = gt_zfarpoth-bukrs AND
                                  gsber = gt_zfarpoth-gsber AND
                                  vkbur = gt_zfarpoth-vkbur AND
                                  noarp = gt_zfarpoth-noarp AND
                                  mjahr = gt_zfarpoth-mjahr.
          READ TABLE gt_zfarpotd2 WITH KEY bukrs = gt_zfarpoth-bukrs
                                           gsber = gt_zfarpoth-gsber
                                           vkbur = gt_zfarpoth-vkbur
                                           noarp = gt_zfarpoth-noarp
                                           mjahr = gt_zfarpoth-mjahr
                                           posnr = gt_zfarpotd-posnr.
          IF sy-subrc = 0.
            LOOP AT gt_zfarpotd2 WHERE bukrs = gt_zfarpoth-bukrs AND
                                       gsber = gt_zfarpoth-gsber AND
                                       vkbur = gt_zfarpoth-vkbur AND
                                       noarp = gt_zfarpoth-noarp AND
                                       mjahr = gt_zfarpoth-mjahr AND
                                       posnr = gt_zfarpotd-posnr.
              MOVE-CORRESPONDING gt_zfarpoth TO gt_greport.
              gt_greport-posnr     = gt_zfarpotd-posnr.
              gt_greport-kunnr     = gt_zfarpotd-kunnr.
              gt_greport-name1     = gt_zfarpotd-name1.
              gt_greport-rtvtyp    = gt_zfarpotd-rtvtyp.
              gt_greport-rtvnr     = gt_zfarpotd-rtvnr.
              gt_greport-rtvdt     = gt_zfarpotd-rtvdt.
              gt_greport-rtvamt    = gt_zfarpotd-rtvamt.
              gt_greport-posamt    = gt_zfarpotd-posamt.
              gt_greport-inpamt    = gt_zfarpotd2-rtvamt.
              gt_greport-rtvket    = gt_zfarpotd-rtvket.
              gt_greport-xblnr     = gt_zfarpotd-xblnr.
              gt_greport-dhkont    = gt_zfarpotd-hkont.
              gt_greport-dbelnr    = gt_zfarpotd2-belnr.
              gt_greport-dgjahr    = gt_zfarpotd2-gjahr.
              gt_greport-dbudat    = gt_zfarpotd2-budat.
              gt_greport-dbuzet    = gt_zfarpotd2-buzet.
              gt_greport-dbunam    = gt_zfarpotd2-bunam.
              gt_greport-dbelnrrev = gt_zfarpotd2-belnrrev.
              gt_greport-ddaterev  = gt_zfarpotd2-daterev.
              gt_greport-duserrev  = gt_zfarpotd2-userrev.
              gt_greport-dtxarp    = gt_zfarpotd2-txarp.
              gt_greport-dvoucr    = gt_zfarpotd2-voucr.
              APPEND gt_greport. CLEAR gt_greport.
            ENDLOOP.
          ELSE.
            MOVE-CORRESPONDING gt_zfarpoth TO gt_greport.
            gt_greport-posnr     = gt_zfarpotd-posnr.
            gt_greport-kunnr     = gt_zfarpotd-kunnr.
            gt_greport-name1     = gt_zfarpotd-name1.
            gt_greport-rtvtyp    = gt_zfarpotd-rtvtyp.
            gt_greport-rtvnr     = gt_zfarpotd-rtvnr.
            gt_greport-rtvdt     = gt_zfarpotd-rtvdt.
            gt_greport-rtvamt    = gt_zfarpotd-rtvamt.
            gt_greport-posamt    = gt_zfarpotd-posamt.
            gt_greport-rtvket    = gt_zfarpotd-rtvket.
            gt_greport-xblnr     = gt_zfarpotd-xblnr.
            gt_greport-dhkont    = gt_zfarpotd-hkont.
            APPEND gt_greport. CLEAR gt_greport.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      PERFORM f_hotspot.
    WHEN '&POS'.
      PERFORM f_post_entries.
    WHEN '&RVS'.
      PERFORM f_reverse_posting.
      LEAVE TO SCREEN 0.
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
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CASE 'X'.
    WHEN p_input.
      SET PF-STATUS 'STAT100'.
      SET TITLEBAR '001'.
      DESCRIBE TABLE gt_vdata LINES fill.
      input-lines = fill.
    WHEN p_revrs.
      APPEND 'MARK' TO fcode.
      APPEND 'DMRK' TO fcode.
      APPEND 'SAVE' TO fcode.
      SET PF-STATUS 'STAT200' EXCLUDING fcode.
      SET TITLEBAR '002'.
      DESCRIBE TABLE gt_vdata LINES fill.
      reverse-lines = fill.
  ENDCASE.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA : selisih LIKE zfbid-wrbtr.

  save_ok = ok_code.
  CLEAR: ok_code.

  CASE save_ok.
    WHEN 'ENTER'.
      PERFORM f_validate_data.

    WHEN 'SAVE'.
      CASE 'X'.
        WHEN p_input.
          PERFORM f_validate_data.
          IF gv_error IS INITIAL.
            PERFORM f_posting_bdc.
            selisih = selisih1 + selisih2.
            IF selisih > 0.
              IF hkont1 IS NOT INITIAL.
                PERFORM f_document_post USING '1' hkont1 voucr selisih.
              ENDIF.
            ELSE.
              IF hkont2 IS NOT INITIAL.
                PERFORM f_document_post USING '2' hkont2 voucr selisih.
              ENDIF.
            ENDIF.

            LEAVE TO SCREEN 0.
          ENDIF.
        WHEN p_revrs.
******          PERFORM f_validate_data.
******          IF gv_error IS INITIAL.
*****          PERFORM f_reverse_bdc.
******          ENDIF.
      ENDCASE.

    WHEN '&LOG'.
      PERFORM f_log_screen.

    WHEN '&DEL'.
      PERFORM fcode_delete_row USING  'INPUT'
                                      'GT_VDATA'
                                      'FLAG'.

    WHEN 'MARK'.
      PERFORM fcode_tc_mark_lines USING 'INPUT'
                                        'GT_VDATA'
                                        'FLAG'.

    WHEN 'DMRK'.
      PERFORM fcode_tc_demark_lines USING 'INPUT'
                                          'GT_VDATA'
                                          'FLAG'.

    WHEN 'OTHD'.
      PERFORM f_other_document.

    WHEN 'REVRS'.
      PERFORM f_validate_data.
      IF gv_error IS INITIAL.
        PERFORM f_reverse_bdc.
      ENDIF.

    WHEN '&TAB1' OR '&TAB2' OR '&TAB3' OR
         '&TAB4' OR '&TAB5'.
      PERFORM f_tabstrip_handle_code USING save_ok.

    WHEN 'BACK'.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN 'CANCL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  CASE 'X'.
    WHEN p_input.
      READ TABLE gt_vdata INTO gt_zfarpotd INDEX input-current_line.
      IF pa_cek IS INITIAL.
        IF gt_zfarpotd-vbeln IS NOT INITIAL AND
          gt_zfarpotd-wrbtr IS INITIAL.
          PERFORM f_modify_screen USING '' 'GT_ZFARPOTD-INPAMT' '' '0' ''.
        ENDIF.
      ENDIF.
    WHEN p_revrs.
      READ TABLE gt_vdata INTO gt_zfarpotd INDEX reverse-current_line.
  ENDCASE.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control INPUT.
  PERFORM f_read_table_control.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_CEK_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_HKONT  text
*----------------------------------------------------------------------*
FORM f_cek_hkont  USING  fu_hkont.
  DATA: ld_saknr LIKE zfacct-saknr.

  CLEAR gv_error.
  SELECT SINGLE saknr INTO ld_saknr
    FROM zfacct
    WHERE bukrs = p_bukrs AND
          vtart = 'BI'    AND
          saknr = fu_hkont.
  IF sy-subrc = 0.
    SELECT SINGLE txt20 INTO txt20
      FROM skat
      WHERE spras = sy-langu  AND
            ktopl = 'TSPC'    AND
            saknr = ld_saknr.
  ELSE.
    gv_error = 'X'.
  ENDIF.
ENDFORM.                    " F_CEK_HKONT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SCREEN_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_screen_100 .
  CLEAR gt_zfarpoth.
  READ TABLE gt_zfarpoth WITH KEY bukrs = p_bukrs
                                  gsber = p_gsber
                                  vkbur = p_vkbur
                                  noarp = p_noarp
                                  mjahr = p_mjahr.
  bukrs = p_bukrs.
  gsber = p_gsber.
  vkbur = p_vkbur.
  noarp = p_noarp.
  mjahr = p_mjahr.
*  amount = gt_zfarpoth-amount * 100.
  CONCATENATE gt_zfarpoth-belnr gt_zfarpoth-gjahr
      INTO belnr SEPARATED BY ' / '.

  gt_vdata[] = gt_zfarpotd[].
  LOOP AT gt_vdata.
    gt_vdata-rtvamt = gt_vdata-rtvamt * 100.
    gt_vdata-posamt = gt_vdata-posamt * 100.
    gt_vdata-wrbtr  = gt_vdata-wrbtr * 100.
    MODIFY gt_vdata TRANSPORTING rtvamt posamt wrbtr.
  ENDLOOP.
ENDFORM.                    " F_INIT_SCREEN_100

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SCREEN_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_screen_200 .
  CLEAR gt_zfarpoth.
  READ TABLE gt_zfarpoth WITH KEY bukrs = p_bukrs
                                  gsber = p_gsber
                                  vkbur = p_vkbur
                                  noarp = p_noarp
                                  mjahr = p_mjahr.
  bukrs = p_bukrs.
  gsber = p_gsber.
  vkbur = p_vkbur.
  noarp = p_noarp.
  mjahr = p_mjahr.
  hkont = gt_zfarpoth-hkont.
  budat = gt_zfarpoth-budat.
  voucr = gt_zfarpoth-voucr.
  txarp = gt_zfarpoth-txarp.
  amount = gt_zfarpoth-amount * 100.
  CONCATENATE gt_zfarpoth-belnr gt_zfarpoth-gjahr
      INTO belnr SEPARATED BY ' / '.

  gt_vdata[] = gt_zfarpotdet[].
  LOOP AT gt_vdata.
    gt_vdata-rtvamt = gt_vdata-rtvamt * 100.
    gt_vdata-posamt = gt_vdata-posamt * 100.
    gt_vdata-inpamt = gt_vdata-inpamt * 100.
    MODIFY gt_vdata TRANSPORTING rtvamt posamt inpamt.
  ENDLOOP.
  SORT gt_vdata BY belnr gjahr posnr kunnr.
ENDFORM.                    " F_INIT_SCREEN_200

*&---------------------------------------------------------------------*
*&      Form  F_LOG_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_log_screen .
  CALL SCREEN 101 STARTING AT 10 10 ENDING AT 150 22.
ENDFORM.                    " F_LOG_SCREEN

*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_0101 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_print_error_log.
ENDMODULE.                 " LIST_PROCESSING_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_ERROR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_error_log .
  IF gt_verror[] IS INITIAL.
    SKIP 1.
    WRITE: /13 'No error occurs'.
  ELSE.
    ULINE AT /(150).
    WRITE:/ sy-vline NO-GAP, (5) 'Type' NO-GAP,
            sy-vline NO-GAP, (10) 'Customer' NO-GAP,
            sy-vline NO-GAP, (20) 'Nomor RTV' NO-GAP,
            sy-vline NO-GAP, (10) 'Tanggal RTV' NO-GAP,
            sy-vline NO-GAP, (15) 'Nilai RTV' NO-GAP,
            sy-vline NO-GAP, (30) 'Keterangan RTV' NO-GAP,
            sy-vline NO-GAP, (60) 'E R R O R' NO-GAP,
            sy-vline NO-GAP.
    ULINE AT /(150).
    LOOP AT gt_verror.
      WRITE:/ sy-vline NO-GAP, (5) gt_verror-rtvtyp NO-GAP,
              sy-vline NO-GAP, (10) gt_verror-kunnr NO-GAP,
              sy-vline NO-GAP, (20) gt_verror-rtvnr NO-GAP,
              sy-vline NO-GAP, (10) gt_verror-rtvdt NO-GAP,
              sy-vline NO-GAP, (15) gt_verror-rtvamt NO-GAP,
              sy-vline NO-GAP, (30) gt_verror-rtvket NO-GAP,
              sy-vline NO-GAP, (60) gt_verror-text NO-GAP,
              sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(150).
  ENDIF.
ENDFORM.                    " F_PRINT_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      APPEND INITIAL LINE TO <table>.
*      IF sy-subrc = 0.
*        <tc>-lines = <tc>-lines - 1.
*      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.
  DATA : lv_vbeln TYPE vbfa-vbeln,
         lv_wrbtr TYPE bseg-wrbtr.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
  FIELD-SYMBOLS <fs>         TYPE any.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

    ASSIGN COMPONENT 'VBELN' OF STRUCTURE <wa> TO <fs>.
    lv_vbeln = <fs>.
    ASSIGN COMPONENT 'WRBTR' OF STRUCTURE <wa> TO <fs>.
    lv_wrbtr = <fs>.

    IF lv_vbeln IS NOT INITIAL AND
      lv_wrbtr IS INITIAL.
      CONTINUE.
    ENDIF.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_posting_bdc .
  DATA: ld_bldat(10),
        ld_budat(10),
        ld_rtvdt(10),
        ld_amount(15),
        ld_wrbtr(15),
        ld_flag(1),
        ld_ok(1),
        ld_lines      TYPE i,
        ld_count      TYPE i,
        lt_vdata      LIKE gt_vdata OCCURS 0 WITH HEADER LINE,
        lv_bktxt      TYPE bkpf-bktxt,
        lv_sgtxt      TYPE bseg-sgtxt.

  READ TABLE gt_vdata WITH KEY flag = 'X'.
  IF sy-subrc NE 0.
    ld_ok = 'X'.
  ENDIF.

  IF ld_ok IS NOT INITIAL.
    MESSAGE 'No item selected' TYPE 'E'.
  ENDIF.

  CLEAR: t_bdcdata,t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  lt_vdata[] = gt_vdata[].
  DELETE lt_vdata WHERE flag = space.
  DESCRIBE TABLE lt_vdata LINES ld_lines.

*  WRITE bldat TO ld_bldat.
  WRITE sy-datum TO ld_bldat.
  WRITE budat TO ld_budat.
  WRITE amount TO ld_amount DECIMALS 0.
  REPLACE ',' WITH '' INTO ld_amount.
  REPLACE '.' WITH '' INTO ld_amount.
  REPLACE '.' WITH '' INTO ld_amount.
  REPLACE '.' WITH '' INTO ld_amount.
  REPLACE '.' WITH '' INTO ld_amount.
  CONDENSE ld_amount NO-GAPS.

  lv_bktxt = txarp.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0100',
       ' '  'BDC_OKCODE'    '/00',
       ' '  'BKPF-BLDAT'    ld_budat,
       ' '  'BKPF-BLART'    'DA',
       ' '  'BKPF-BUKRS'    bukrs,
       ' '  'BKPF-BUDAT'    ld_budat,
       ' '  'BKPF-MONAT'    budat+4(2),
       ' '  'BKPF-WAERS'    'IDR',
       ' '  'BKPF-XBLNR'    voucr,
       ' '  'BKPF-BKTXT'    lv_bktxt,
       ' '  'FS006-DOCID'   '*',
       ' '  'RF05A-NEWBS'   '40',
       ' '  'RF05A-NEWKO'   hkont.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0300',
       ' '  'BDC_OKCODE'    '/00',
       ' '  'BSEG-WRBTR'    ld_amount,
       ' '  'BSEG-ZUONR'    voucr,
       ' '  'BSEG-SGTXT'    txarp.

  LOOP AT gt_vdata WHERE flag = 'X'.
    CLEAR: ld_rtvdt,ld_wrbtr.
    WRITE gt_vdata-rtvdt TO ld_rtvdt.
*    WRITE gt_vdata-rtvamt TO ld_wrbtr DECIMALS 0.
    WRITE gt_vdata-inpamt TO ld_wrbtr DECIMALS 0.
    REPLACE ',' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    CONDENSE ld_wrbtr NO-GAPS.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
         ' '  'RF05A-NEWBS'   '19',
         ' '  'RF05A-NEWKO'   gt_vdata-kunnr,
         ' '  'RF05A-NEWUM'   'V'.

    IF ld_flag IS INITIAL.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPLKACB'      '0002',
           ' '  'BDC_OKCODE'    '=ENTE',
           ' '  'COBL-GSBER'    vkbur.
      ld_flag = 'X'.
    ENDIF.

    ADD 1 TO ld_count.
    CONCATENATE gt_vdata-rtvket gt_vdata-vbeln INTO lv_sgtxt
    SEPARATED BY '-'.
    IF ld_count = ld_lines.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05A'      '0303',
           ' '  'BDC_OKCODE'    '=AB',
           ' '  'BSEG-WRBTR'    ld_wrbtr,
           ' '  'BSEG-GSBER'    gsber,
           ' '  'BSEG-ZFBDT'    ld_budat,
           ' '  'BSEG-ZUONR'    gt_vdata-rtvnr,
           ' '  'BSEG-SGTXT'    lv_sgtxt.
    ELSE.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05A'      '0303',
           ' '  'BDC_OKCODE'    '/00',
           ' '  'BSEG-WRBTR'    ld_wrbtr,
           ' '  'BSEG-GSBER'    gsber,
           ' '  'BSEG-ZFBDT'    ld_budat,
           ' '  'BSEG-ZUONR'    gt_vdata-rtvnr,
           ' '  'BSEG-SGTXT'    lv_sgtxt.
    ENDIF.
  ENDLOOP.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0700',
       ' '  'BDC_OKCODE'    '=BU',
       ' '  'BKPF-XBLNR'    voucr,
       ' '  'BKPF-BKTXT'    lv_bktxt.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0700',
       ' '  'BDC_OKCODE'    '=BU'.

  CALL TRANSACTION 'F-21' USING t_bdcdata
                          MODE gv_mode
                          UPDATE 'S'
                          MESSAGES INTO t_bdcmsg.

  READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
    ROLLBACK WORK.
  ELSE.
    READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      PERFORM f_save_to_table.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_POSTING_BDC

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_to_table .
  DATA: ld_belnr LIKE gt_zfarpotd-belnr.

  DATA : lt_zfarpotdcn TYPE STANDARD TABLE OF zfarpotdcn,
         ls_zfarpotdcn LIKE LINE OF lt_zfarpotdcn.

  DATA : ls_xfarpotd LIKE LINE OF gt_xfarpotd.

  DATA : lv_count TYPE i,
         lv_posnr.

  CLEAR t_bdcmsg.
  READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'
                               msgid  = 'F5'
                               msgnr  = '312'.

  CASE 'X'.
    WHEN p_input.
      LOOP AT gt_vdata.
        MOVE-CORRESPONDING gt_vdata TO gt_zfarpotd_sv.
*        gt_zfarpotd_sv-belnr = t_bdcmsg-msgv1.
*        gt_zfarpotd_sv-gjahr = budat(4).
        gt_zfarpotd_sv-txarp = txarp.
        gt_zfarpotd_sv-voucr = voucr.
        gt_zfarpotd_sv-rtvamt = gt_zfarpotd_sv-rtvamt / 100.

        IF gt_vdata-xflag IS NOT INITIAL.
          lv_count = 0.
        ENDIF.

        IF lv_count = 0.
          READ TABLE gt_xfarpotd INTO ls_xfarpotd
                                 WITH KEY bukrs = gt_vdata-bukrs
                                          gsber = gt_vdata-gsber
                                          vkbur = gt_vdata-vkbur
                                          noarp = gt_vdata-noarp
                                          mjahr = gt_vdata-mjahr
                                          kunnr = gt_vdata-kunnr
                                          rtvnr = gt_vdata-rtvnr.
          IF sy-subrc = 0.
            ADD 1 TO lv_count.
            gt_zfarpotd_sv-posamt = ( ( ls_xfarpotd-posamt * 100 ) + gt_zfarpotd_sv-inpamt )
                                    / 100 .
          ENDIF.
        ELSE.
          gt_zfarpotd_sv-posamt = gt_zfarpotd_sv-inpamt / 100 .
        ENDIF.

        CLEAR: gt_zfarpotd_sv-flag,gt_zfarpotd_sv-belnrrev,gt_zfarpotd_sv-daterev,gt_zfarpotd_sv-userrev,
               gt_zfarpotd_sv-inpamt. "gt_zfarpotd_sv-belnr,gt_zfarpotd_sv-gjahr,
*               gt_zfarpotd_sv-budat,gt_zfarpotd_sv-buzet,gt_zfarpotd_sv-bunam.

        PERFORM f_alpha_conversion USING t_bdcmsg-msgv1
                                   CHANGING gt_zfarpotd_sv-belnr.
        gt_zfarpotd_sv-gjahr = budat(4).
        gt_zfarpotd_sv-budat = sy-datum.
        gt_zfarpotd_sv-buzet = sy-uzeit.
        gt_zfarpotd_sv-bunam = sy-uname.

        IF gt_zfarpotd_sv-posamt <> 0.
          COLLECT gt_zfarpotd_sv.
        ENDIF.

*        APPEND gt_zfarpotd_sv.

        MOVE-CORRESPONDING gt_vdata TO gt_zfarpotd2_sv.
*        gt_zfarpotd2_sv-belnr = t_bdcmsg-msgv1.
        PERFORM f_alpha_conversion USING t_bdcmsg-msgv1
                                   CHANGING gt_zfarpotd2_sv-belnr.
*        CONCATENATE '0' t_bdcmsg-msgv1 INTO gt_zfarpotd2_sv-belnr.
        gt_zfarpotd2_sv-gjahr = budat(4).
        gt_zfarpotd2_sv-buzet = sy-uzeit.
        gt_zfarpotd2_sv-bunam = sy-uname.
        gt_zfarpotd2_sv-budat = budat.
        gt_zfarpotd2_sv-txarp = txarp.
        gt_zfarpotd2_sv-voucr = voucr.
        gt_zfarpotd2_sv-rtvamt = gt_vdata-inpamt / 100.
        CLEAR: gt_zfarpotd2_sv-flag,gt_zfarpotd2_sv-belnrrev,
               gt_zfarpotd2_sv-daterev,gt_zfarpotd2_sv-userrev.

        IF gt_zfarpotd2_sv-rtvamt <> 0.
          COLLECT gt_zfarpotd2_sv.
        ENDIF.

*        APPEND gt_zfarpotd2_sv.

        PERFORM f_prepare_table_cn TABLES lt_zfarpotdcn
                                   USING gt_vdata " ls_zfarpotdcn
                                         gt_zfarpotd2_sv-belnr.
      ENDLOOP.

      LOOP AT gt_zfarpotd_sv.
        CLEAR gt_vdata.
        READ TABLE gt_vdata WITH KEY bukrs = gt_zfarpotd_sv-bukrs
                                     gsber = gt_zfarpotd_sv-gsber
                                     vkbur = gt_zfarpotd_sv-vkbur
                                     noarp = gt_zfarpotd_sv-noarp
                                     mjahr = gt_zfarpotd_sv-mjahr
                                     posnr = gt_zfarpotd_sv-posnr.
        IF sy-subrc = 0.
          gt_zfarpotd_sv-rtvamt = gt_vdata-rtvamt / 100.
          MODIFY gt_zfarpotd_sv TRANSPORTING rtvamt.
        ENDIF.
        CLEAR gt_zfarpotd_sv.
      ENDLOOP.

      MODIFY zfarpotd FROM TABLE gt_zfarpotd_sv.
      MODIFY zfarpotd2 FROM TABLE gt_zfarpotd2_sv.
      MODIFY zfarpotdcn FROM TABLE lt_zfarpotdcn.




      CLEAR lt_zfarpotdcn[].


      CONCATENATE 'Payment AR Pot.' gt_zfarpotd2_sv-noarp 'terposting dg no.'
        gt_zfarpotd2_sv-belnr INTO gv_message SEPARATED BY space.

    WHEN p_revrs.
*      LOOP AT gt_vdata WHERE flag = 'X'.
      LOOP AT gt_vdata.
        MOVE-CORRESPONDING gt_vdata TO gt_zfarpotd_rvs.

        READ TABLE gt_zfarpotd2 INTO gt_zfarpotd2_rvs WITH KEY bukrs = gt_vdata-bukrs
                                                               gsber = gt_vdata-gsber
                                                               vkbur = gt_vdata-vkbur
                                                               noarp = gt_vdata-noarp
                                                               mjahr = gt_vdata-mjahr
                                                               posnr = gt_vdata-posnr
                                                               belnr = gt_vdata-belnr.
        IF sy-subrc NE 0.
          WRITE gt_vdata-belnr TO ld_belnr NO-ZERO.
          READ TABLE gt_zfarpotd2 INTO gt_zfarpotd2_rvs WITH KEY bukrs = gt_vdata-bukrs
                                                                 gsber = gt_vdata-gsber
                                                                 vkbur = gt_vdata-vkbur
                                                                 noarp = gt_vdata-noarp
                                                                 mjahr = gt_vdata-mjahr
                                                                 posnr = gt_vdata-posnr
                                                                 belnr = ld_belnr.
        ENDIF.
        CLEAR: gt_zfarpotd_rvs-flag,gt_zfarpotd_rvs-inpamt.
        gt_zfarpotd_rvs-posamt = gt_zfarpotd_rvs-posamt - ( gt_zfarpotd2_rvs-rtvamt * 100 ).
        gt_zfarpotd_rvs-rtvamt = gt_zfarpotd_rvs-rtvamt / 100.
        gt_zfarpotd_rvs-posamt = gt_zfarpotd_rvs-posamt / 100.

        IF gt_zfarpotd_rvs-posamt = 0.
          PERFORM f_alpha_conversion USING t_bdcmsg-msgv1
                                     CHANGING gt_zfarpotd_rvs-belnrrev.
          gt_zfarpotd_rvs-daterev = sy-datum.
          gt_zfarpotd_rvs-userrev = sy-uname.
        ELSE.
          CLEAR : gt_zfarpotd_rvs-belnrrev, gt_zfarpotd_rvs-daterev, gt_zfarpotd_rvs-userrev.
        ENDIF.
        APPEND gt_zfarpotd_rvs.

        PERFORM f_alpha_conversion USING t_bdcmsg-msgv1
                                   CHANGING gt_zfarpotd2_rvs-belnrrev.
*        CONCATENATE '0' t_bdcmsg-msgv1 INTO gt_zfarpotd2_rvs-belnrrev.
        gt_zfarpotd2_rvs-daterev = sy-datum.
        gt_zfarpotd2_rvs-userrev = sy-uname.
        APPEND gt_zfarpotd2_rvs.

*****        READ TABLE gt_zfarpotdcn INTO ls_zfarpotdcn
*****                                 WITH KEY bukrs = gt_zfarpotd2_rvs-bukrs
*****                                          gsber = gt_zfarpotd2_rvs-gsber
*****                                          vkbur = gt_zfarpotd2_rvs-vkbur
*****                                          noarp = gt_zfarpotd2_rvs-noarp
*****                                          mjahr = gt_zfarpotd2_rvs-mjahr
*****                                          belnr = gt_zfarpotd2_rvs-belnr.
*****        IF sy-subrc = 0.
*****          PERFORM f_prepare_table_cn TABLES lt_zfarpotdcn
*****                                     USING gt_vdata ls_zfarpotdcn
*****                                           gt_zfarpotd2_rvs-belnrrev.
*****        ENDIF.
      ENDLOOP.

      MODIFY zfarpotd FROM TABLE gt_zfarpotd_rvs.
      MODIFY zfarpotd2 FROM TABLE gt_zfarpotd2_rvs.
*****      IF lt_zfarpotdcn[] IS NOT INITIAL.
*****        MODIFY zfarpotdcn FROM TABLE lt_zfarpotdcn.
*****      ENDIF.

      TRY .
          UPDATE zfarpotdcn SET stblg = gt_zfarpotd2_rvs-belnrrev
                                stjah = p_mjahr
                            WHERE bukrs = p_bukrs
                              AND gsber = p_gsber
                              AND vkbur = p_vkbur
                              AND noarp = p_noarp
                              AND mjahr = p_mjahr
                              AND belnr = p_belnr.
        CATCH cx_sy_open_sql_db.
      ENDTRY.

      CLEAR lt_zfarpotdcn[].

      CONCATENATE 'Payment AR Pot.' gt_zfarpotd2_rvs-noarp 'terReverse dg no.'
        gt_zfarpotd2_rvs-belnrrev INTO gv_message SEPARATED BY space.
  ENDCASE.

  MESSAGE gv_message TYPE 'S'.
ENDFORM.                    " F_SAVE_TO_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_POSTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reverse_posting .
  LOOP AT gt_zfarpoth_pay WHERE check = 'X'.
    CLEAR: t_bdcdata,t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
         'X'  'SAPMF05A'      '0105',
         ' '  'BDC_OKCODE'    '=BU',
         ' '  'RF05A-BELNS'   gt_zfarpoth_pay-belnrpay,
         ' '  'BKPF-BUKRS'    gt_zfarpoth_pay-bukrs,
         ' '  'RF05A-GJAHS'   gt_zfarpoth_pay-gjahrpay,
         ' '  'UF05A-STGRD'   '01'.

    CALL TRANSACTION 'FB08' USING t_bdcdata
                            MODE 'E'
                            UPDATE 'S'
                            MESSAGES INTO t_bdcmsg.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      ROLLBACK WORK.
    ELSE.
      READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        LOOP AT gt_zfarpotd WHERE bukrs = gt_zfarpoth_pay-bukrs AND
                                  gsber = gt_zfarpoth_pay-gsber AND
                                  vkbur = gt_zfarpoth_pay-vkbur AND
                                  noarp = gt_zfarpoth_pay-noarp AND
                                  mjahr = gt_zfarpoth_pay-mjahr AND
                                  belnr = gt_zfarpoth_pay-belnrpay AND
                                  gjahr = gt_zfarpoth_pay-gjahrpay.
          gt_zfarpotd-belnrrev = t_bdcmsg-msgv1.
          gt_zfarpotd-daterev = sy-datum.
          gt_zfarpotd-userrev = sy-uname.
          MODIFY gt_zfarpotd TRANSPORTING belnrrev daterev userrev.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM f_save_to_table.
ENDFORM.                    " F_REVERSE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_OTHER_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_other_document .
  ps_bukrs = p_bukrs.
  ps_gsber = p_gsber.
  ps_vkbur = p_vkbur.
  ps_mjahr = p_mjahr.
  ps_noarp = p_noarp.

  CALL SELECTION-SCREEN 500 STARTING AT 20 5.
  IF sy-subrc = 0.
    p_bukrs = ps_bukrs.
    p_gsber = ps_gsber.
    p_vkbur = ps_vkbur.
    p_mjahr = ps_mjahr.
    p_noarp = ps_noarp.
    s_nortv[] = ss_nortv[].
    CLEAR: gt_zfarpoth,gt_zfarpotd,gt_zfarpotd2.
    REFRESH: gt_zfarpoth[],gt_zfarpotd[],gt_zfarpotd2[].

    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_init_screen_100.
  ENDIF.
ENDFORM.                    " F_OTHER_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reverse_bdc .
*  READ TABLE gt_vdata WITH KEY flag = 'X'.
  READ TABLE gt_vdata INDEX 1.

  CLEAR: t_bdcdata,t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0105',
       ' '  'BDC_OKCODE'    '=BU',
       ' '  'RF05A-BELNS'   gt_vdata-belnr,
       ' '  'BKPF-BUKRS'    gt_vdata-bukrs,
       ' '  'RF05A-GJAHS'   gt_vdata-gjahr,
       ' '  'UF05A-STGRD'   '01'.

  CALL TRANSACTION 'FB08' USING t_bdcdata
                          MODE 'E'
                          UPDATE 'S'
                          MESSAGES INTO t_bdcmsg.

  READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
    ROLLBACK WORK.
  ELSE.
    READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      PERFORM f_save_to_table.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_REVERSE_BDC

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data .
  DATA: ld_amount   LIKE amount,
        ld_sisa     LIKE amount,
        ld_arpot    LIKE amount,
        lt_vdata    LIKE gt_vdata OCCURS 0 WITH HEADER LINE,
        lr_wrbtr    TYPE RANGE OF zwert7,
        ls_wrbtr    LIKE LINE OF lr_wrbtr,
        lv_wrbtr    TYPE zwert7,
        answer,
        lv_error,
        lv_text(35),
        lv_count    TYPE i,
        lv_inpamt   TYPE zfarpotd-inpamt,
        lv_rtvamt   TYPE zfarpotd-rtvamt,
        lv_posamt   TYPE zfarpotd-posamt,
        lv_biamnt   TYPE zwert7,
        ls_status   LIKE LINE OF gt_status,
        ls_xfarpotd LIKE LINE OF gt_xfarpotd.

  DATA : lt_xdata LIKE gt_vdata OCCURS 0,
         ls_xdata LIKE LINE OF lt_xdata,
         lv_xflag.

  CLEAR : gt_status[], gs_status.

  CASE 'X'.
    WHEN p_input.
      CLEAR gv_error.
      ls_wrbtr-low    = 100 * -1.
      ls_wrbtr-high   = 100.
      ls_wrbtr-sign   = 'E'.
      ls_wrbtr-option = 'BT'.
      APPEND ls_wrbtr TO lr_wrbtr.

      lv_wrbtr        = 100.

* Cek Account number
      PERFORM f_cek_hkont USING hkont.
      IF gv_error IS INITIAL.
* Cek Amount.
        selisih1 = 0.
        selisih2 = 0.

        lt_xdata[] = gt_vdata[].
        SORT lt_xdata BY bukrs gsber vkbur noarp mjahr rtvnr.
        DELETE ADJACENT DUPLICATES FROM lt_xdata
        COMPARING bukrs gsber vkbur noarp mjahr rtvnr.

        LOOP AT lt_xdata INTO ls_xdata.
          CLEAR lv_xflag.
          LOOP AT gt_vdata WHERE bukrs = ls_xdata-bukrs
                             AND gsber = ls_xdata-gsber
                             AND vkbur = ls_xdata-vkbur
                             AND noarp = ls_xdata-noarp
                             AND mjahr = ls_xdata-mjahr
                             AND rtvnr = ls_xdata-rtvnr.
            IF gt_vdata-flag = 'X'.
              IF gt_vdata-selisih GT lv_wrbtr.
                lv_error = 'X'.
                ADD 1 TO lv_text.
              ENDIF.
            ENDIF.
            IF lv_xflag IS INITIAL.
              lv_xflag = 'X'.
              gt_vdata-xflag = lv_xflag.
              MODIFY gt_vdata TRANSPORTING xflag.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        IF lv_error = 'X'.
          CONDENSE lv_text NO-GAPS.
          CONCATENATE 'RTV =' lv_text INTO lv_text
          SEPARATED BY space.
          CALL FUNCTION 'POPUP_TO_DECIDE_INFO'
            EXPORTING
              textline1 = 'Ada Nilai input > 100 nilai CN'
              textline2 = lv_text
              titel     = 'Amount validate'
            IMPORTING
              answer    = answer.
          CASE answer.
            WHEN 'J'.
            WHEN 'A'.
              gv_error = 'X'.
              LOOP AT gt_vdata WHERE flag = 'X'.
                CLEAR gt_vdata-flag.
                IF gt_vdata-selisih GT lv_wrbtr.
                  CLEAR : gt_vdata-selisih, gt_vdata-inpamt.
                ENDIF.
                MODIFY gt_vdata TRANSPORTING selisih inpamt flag.
              ENDLOOP.
          ENDCASE.
        ENDIF.

        lt_vdata[] = gt_vdata[].
        LOOP AT gt_vdata WHERE flag = 'X'.
          CLEAR : ld_sisa, lv_count, lv_inpamt, lv_rtvamt,
                  lv_biamnt, lv_posamt, gt_vdata-icon.
          PERFORM f_check_total_rtv TABLES lt_vdata
                                    USING gt_vdata-kunnr gt_vdata-rtvnr gt_zfarpotd-rtvamt
                                    CHANGING lv_count lv_inpamt lv_rtvamt lv_biamnt lv_posamt.
          IF lv_count = 1.
            ld_sisa   = gt_vdata-rtvamt - gt_vdata-posamt.
            lv_inpamt = gt_vdata-inpamt.
          ELSEIF ( lv_count <> 1 AND gt_vdata-posamt <> 0 ).
            ld_sisa = gt_vdata-rtvamt - gt_vdata-posamt.
          ELSE.
            ld_sisa = gt_vdata-rtvamt - lv_posamt.
          ENDIF.

          IF gt_vdata-vbeln IS NOT INITIAL.
            gt_vdata-selisih = gt_vdata-inpamt - gt_vdata-wrbtr.
          ENDIF.

          IF lv_inpamt > ld_sisa.
            MESSAGE s000(zab) WITH 'Total Amount Input <> Amount RTV' DISPLAY LIKE 'E'.
            gt_vdata-icon = icon_led_red.
            gv_error = 'X'.
          ENDIF.

          MODIFY gt_vdata TRANSPORTING icon inpamt selisih.

          IF gv_error IS INITIAL.
            ADD gt_vdata-inpamt TO ld_amount.
            IF gt_vdata-selisih > 0.
              IF gt_vdata-selisih > lv_wrbtr.
                ADD lv_wrbtr TO selisih1.
              ELSE.
                ADD gt_vdata-selisih TO selisih1.
              ENDIF.
            ELSE.
              ADD gt_vdata-selisih TO selisih2.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF gv_error IS INITIAL.
          IF pa_cek IS NOT INITIAL.
            CLEAR : lv_posamt, lv_rtvamt.
            LOOP AT gt_xfarpotd INTO ls_xfarpotd.
              ADD ls_xfarpotd-posamt TO lv_posamt.
              ADD ls_xfarpotd-rtvamt TO lv_rtvamt.
            ENDLOOP.
            ld_arpot = lv_posamt + ( ld_amount / 100 ).
            IF ld_arpot > lv_rtvamt.
              MESSAGE s000(zab) WITH 'Total input > Total RTV Amount' DISPLAY LIKE 'E'.
              gv_error = 'X'.
            ENDIF.

*            READ TABLE gt_xfarpotd INTO ls_xfarpotd INDEX 1.
*            IF sy-subrc = 0.
*              ld_arpot = ls_xfarpotd-posamt + ( ld_amount / 100 ).
*              IF ld_arpot > ls_xfarpotd-rtvamt.
*                MESSAGE s000(zab) WITH 'Total input > Total RTV Amount' DISPLAY LIKE 'E'.
*                gv_error = 'X'.
*              ENDIF.
*            ENDIF.
          ENDIF.
          CLEAR : lv_posamt, lv_rtvamt.
        ENDIF.

        IF pa_cek IS NOT INITIAL.
          selisih1 = 0.
          selisih2 = 0.
        ENDIF.

        IF gv_error IS INITIAL.
          IF ld_amount = amount.
            IF selisih1 IS NOT INITIAL.
              IF hkont1 IS INITIAL.
                hkont1  = '0912900000'.
              ENDIF.
            ELSE.
              CLEAR hkont1.
            ENDIF.
            IF selisih2 IS NOT INITIAL.
              IF hkont2 IS INITIAL.
                hkont2  = '0911900000'.
              ENDIF.
            ELSE.
              CLEAR hkont2.
            ENDIF.
            MESSAGE 'Data Okay...' TYPE 'S'.
          ELSE.
            gs_status-h1  = icon_led_red.
            MESSAGE s000(zab) WITH 'Amount Salah' DISPLAY LIKE 'E'.
            gv_error = 'X'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE s000(zab) WITH 'G/L Acct. Cash/Bank Salah' DISPLAY LIKE 'E'.
        gv_error = 'X'.
      ENDIF.
      CLEAR ld_amount.

    WHEN p_revrs.
*      CLEAR gv_error.
*      READ TABLE gt_vdata WITH KEY flag = 'X'.
*      IF sy-subrc NE 0.
*        MESSAGE 'Tidak ada record terpilih' TYPE 'S'.
*        gv_error = 'X'.
*      ELSE.
*        lt_vdata[] = gt_vdata[].
*        DELETE lt_vdata WHERE flag NE space.
*        LOOP AT gt_vdata WHERE flag = 'X'.
*          READ TABLE lt_vdata WITH KEY bukrs = gt_vdata-bukrs
*                                       gsber = gt_vdata-gsber
*                                       vkbur = gt_vdata-vkbur
*                                       noarp = gt_vdata-noarp
*                                       mjahr = gt_vdata-mjahr
*                                       belnr = gt_vdata-belnr.
*          IF sy-subrc = 0.
*            MESSAGE 'Semua no. doc. yg sama harus dipilih' TYPE 'S'.
*            gv_error = 'X'.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_HOTSPOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hotspot .

ENDFORM.                    " F_HOTSPOT

*&---------------------------------------------------------------------*
*&      Module  CANCEL  INPUT
*&---------------------------------------------------------------------*
MODULE cancel INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " CANCEL  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_HKONT  INPUT
*&---------------------------------------------------------------------*
MODULE value_hkont INPUT.
  PERFORM f_value_hkont.
ENDMODULE.                 " VALUE_HKONT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_HKONT
*&---------------------------------------------------------------------*
FORM f_value_hkont .
  TYPES : BEGIN OF ty_ska1,
            saknr TYPE skat-saknr,
            txt20 TYPE skat-txt20,
            txt50 TYPE skat-txt50,
          END OF ty_ska1.

  DATA : lt_ska1   TYPE STANDARD TABLE OF ty_ska1,
         ls_ska1   LIKE LINE OF lt_ska1,
         lt_zfacct TYPE STANDARD TABLE OF zfacct,
         ls_zfacct LIKE LINE OF lt_zfacct,
         lt_skat   TYPE STANDARD TABLE OF skat,
         ls_skat   LIKE LINE OF lt_skat.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_subrc TYPE sy-subrc,
         lv_hkont TYPE ska1-saknr.

  SELECT *
    FROM zfacct
    INTO CORRESPONDING FIELDS OF TABLE lt_zfacct
    WHERE bukrs = p_bukrs
      AND vtart = 'BI'.

  IF lt_zfacct[] IS NOT INITIAL.
    SELECT *
      FROM skat
      INTO CORRESPONDING FIELDS OF TABLE lt_skat
      FOR ALL ENTRIES IN lt_zfacct
      WHERE spras = sy-langu
        AND saknr = lt_zfacct-saknr.
  ENDIF.

  LOOP AT lt_zfacct INTO ls_zfacct.
    ls_ska1-saknr   = ls_zfacct-saknr.
    CLEAR ls_skat.
    READ TABLE lt_skat INTO ls_skat
                       WITH KEY saknr = ls_zfacct-saknr.
    IF sy-subrc = 0.
      ls_ska1-txt20   = ls_skat-txt20.
      ls_ska1-txt50   = ls_skat-txt50.
      APPEND ls_ska1 TO lt_ska1.
    ENDIF.
    CLEAR ls_zfacct.
  ENDLOOP.

  ASSIGN lt_ska1[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'SAKNR' 'HKONT'
                          CHANGING lv_subrc.
ENDFORM.                    " F_VALUE_HKONT

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_GET_BI_DATA
*&---------------------------------------------------------------------*
FORM f_get_bi_data .
  DATA : lt_zfarpotd LIKE gt_zfarpotd OCCURS 0,
         ls_zfarpotd LIKE LINE OF lt_zfarpotd,
         lr_auart    TYPE RANGE OF auart,
         ls_auart    LIKE LINE OF lr_auart,
         ls_vbak     LIKE LINE OF gt_vbak,
         lr_vbtyp    TYPE RANGE OF vbtyp_n,
         ls_vbtyp    LIKE LINE OF lr_vbtyp,
         lt_xfbid    TYPE STANDARD TABLE OF zfbid,
         ls_xfbid    LIKE LINE OF lt_xfbid,
         ls_vbfa     LIKE LINE OF gt_vbfa.

  DATA : lt_vbrk TYPE STANDARD TABLE OF vbrk,
         ls_vbrk LIKE LINE OF lt_vbrk.

  ls_auart-low    = 'ZR*'.
  ls_auart-sign   = 'I'.
  ls_auart-option = 'CP'.
  APPEND ls_auart TO lr_auart.
  CLEAR ls_auart.
  ls_auart-low    = 'ZRA*'.
  ls_auart-sign   = 'E'.
  ls_auart-option = 'CP'.
  APPEND ls_auart TO lr_auart.
  CLEAR ls_auart.

  ls_vbtyp-low    = 'O'.
  ls_vbtyp-sign   = 'I'.
  ls_vbtyp-option = 'EQ'.
  APPEND ls_vbtyp TO lr_vbtyp.
  CLEAR ls_vbtyp.
  ls_vbtyp-low    = '6'.
  ls_vbtyp-sign   = 'I'.
  ls_vbtyp-option = 'EQ'.
  APPEND ls_vbtyp TO lr_vbtyp.
  CLEAR ls_vbtyp.

  lt_zfarpotd[] = gt_zfarpotd[].
  SORT lt_zfarpotd BY kunnr bukrs vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_zfarpotd COMPARING kunnr bukrs vkbur.
  IF lt_zfarpotd[] IS NOT INITIAL.
    SELECT *
      FROM vbak
      INTO CORRESPONDING FIELDS OF TABLE gt_vbak
      FOR ALL ENTRIES IN lt_zfarpotd
      WHERE knkli = lt_zfarpotd-kunnr
        AND vkorg = lt_zfarpotd-bukrs
        AND vkbur = lt_zfarpotd-vkbur
        AND auart IN lr_auart.

    LOOP AT gt_vbak INTO ls_vbak.
      CLEAR ls_zfarpotd.
      READ TABLE gt_zfarpotd INTO ls_zfarpotd
                             WITH KEY rtvnr = ls_vbak-bstnk.
      IF sy-subrc <> 0.
        DELETE TABLE gt_vbak FROM ls_vbak.
      ENDIF.
    ENDLOOP.

    IF gt_vbak[] IS NOT INITIAL.
      SELECT *
        FROM vbfa
        INTO CORRESPONDING FIELDS OF TABLE gt_vbfa
        FOR ALL ENTRIES IN gt_vbak
        WHERE vbelv   = gt_vbak-vbeln
          AND vbtyp_n IN lr_vbtyp.

      IF gt_vbfa[] IS NOT INITIAL.
        SELECT *
          FROM vbrk
          INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
          FOR ALL ENTRIES IN gt_vbfa
          WHERE vbeln = gt_vbfa-vbeln
            AND fksto = space.

        LOOP AT gt_vbfa INTO ls_vbfa.
          CLEAR ls_vbrk.
          READ TABLE lt_vbrk INTO ls_vbrk
                             WITH KEY vbeln = ls_vbfa-vbeln.
          IF sy-subrc <> 0.
            DELETE TABLE gt_vbfa FROM ls_vbfa.
          ENDIF.
        ENDLOOP.

        LOOP AT gt_vbak INTO ls_vbak.
          CLEAR ls_vbfa.
          READ TABLE gt_vbfa INTO ls_vbfa
                             WITH KEY vbelv = ls_vbak-vbeln.
          IF sy-subrc <> 0.
            DELETE TABLE gt_vbak FROM ls_vbak.
          ENDIF.
        ENDLOOP.
      ENDIF.

      LOOP AT gt_vbfa INTO ls_vbfa.
        ls_xfbid-bukrs = p_bukrs.
        ls_xfbid-vkbur = p_vkbur.
        ls_xfbid-zuonr = ls_vbfa-vbeln.
        APPEND ls_xfbid TO lt_xfbid.
        CLEAR ls_xfbid.
      ENDLOOP.

      IF lt_xfbid[] IS NOT INITIAL.
        PERFORM f_get_bi TABLES lt_xfbid.
        PERFORM f_get_bi_sfa TABLES lt_xfbid.
        PERFORM f_get_bi_paycust TABLES lt_xfbid.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_BI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BI
*&---------------------------------------------------------------------*
FORM f_get_bi  TABLES   ft_xfbid STRUCTURE zfbid.
  DATA : lt_zfbid TYPE STANDARD TABLE OF zfbid,
         lt_xfbid TYPE STANDARD TABLE OF zfbid,
         ls_zfbid LIKE LINE OF lt_zfbid.

  DATA : lt_zfbih TYPE STANDARD TABLE OF zfbih,
         ls_zfbih LIKE LINE OF lt_zfbih,
         ls_bi    LIKE LINE OF gt_bi.

  SELECT *
    FROM zfbid
    INTO CORRESPONDING FIELDS OF TABLE lt_zfbid
    FOR ALL ENTRIES IN ft_xfbid
    WHERE bukrs = ft_xfbid-bukrs
      AND vkbur = ft_xfbid-vkbur
      AND zuonr = ft_xfbid-zuonr.

  CLEAR : lt_xfbid[].
  lt_xfbid[] = lt_zfbid[].
  SORT lt_xfbid BY bukrs vkbur bbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xfbid COMPARING bukrs vkbur bbeln.
  IF lt_zfbid[] IS NOT INITIAL.
    SELECT *
      FROM zfbih
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbih
      FOR ALL ENTRIES IN lt_zfbid
      WHERE bukrs = lt_zfbid-bukrs
        AND vkbur = lt_zfbid-vkbur
        AND bbeln = lt_zfbid-bbeln.
  ENDIF.

  LOOP AT lt_zfbih INTO ls_zfbih.
    LOOP AT lt_zfbid INTO ls_zfbid WHERE bukrs = ls_zfbih-bukrs
                                     AND vkbur = ls_zfbih-vkbur
                                     AND bbeln = ls_zfbih-bbeln.
      IF ls_zfbid-bflag = 'D'.
        ls_bi-bbeln   = space.
      ELSE.
        ls_bi-bbeln   = ls_zfbih-bbeln.
      ENDIF.
      ls_bi-bidat   = ls_zfbih-bidat.
      ls_bi-zuonr   = ls_zfbid-zuonr.
      ls_bi-wrbtr   = ls_zfbid-wrbtr.
      APPEND ls_bi TO gt_bi.
      CLEAR ls_bi.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_GET_BI

*&---------------------------------------------------------------------*
*&      Form  F_GET_BI_SFA
*&---------------------------------------------------------------------*
FORM f_get_bi_sfa  TABLES   ft_xfbid STRUCTURE zfbid.
  DATA : lt_zfbid_sfa TYPE STANDARD TABLE OF zfbid_sfa,
         lt_xfbid_sfa TYPE STANDARD TABLE OF zfbid_sfa,
         ls_zfbid_sfa LIKE LINE OF lt_zfbid_sfa.

  DATA : lt_zfbih_sfa TYPE STANDARD TABLE OF zfbih_sfa,
         ls_zfbih_sfa LIKE LINE OF lt_zfbih_sfa,
         ls_bi        LIKE LINE OF gt_bi.

  SELECT *
    FROM zfbid_sfa
    INTO CORRESPONDING FIELDS OF TABLE lt_zfbid_sfa
    FOR ALL ENTRIES IN ft_xfbid
    WHERE bukrs = ft_xfbid-bukrs
      AND vkbur = ft_xfbid-vkbur
      AND zuonr = ft_xfbid-zuonr.

  CLEAR : lt_xfbid_sfa[].
  lt_xfbid_sfa[] = lt_zfbid_sfa[].
  SORT lt_xfbid_sfa BY bukrs vkbur bbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xfbid_sfa COMPARING bukrs vkbur bbeln.
  IF lt_xfbid_sfa[] IS NOT INITIAL.
    SELECT *
      FROM zfbih_sfa
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbih_sfa
      FOR ALL ENTRIES IN lt_xfbid_sfa
      WHERE bukrs = lt_xfbid_sfa-bukrs
        AND vkbur = lt_xfbid_sfa-vkbur
        AND bbeln = lt_xfbid_sfa-bbeln.
  ENDIF.

  LOOP AT lt_zfbih_sfa INTO ls_zfbih_sfa.
    LOOP AT lt_zfbid_sfa INTO ls_zfbid_sfa WHERE bukrs = ls_zfbih_sfa-bukrs
                                             AND vkbur = ls_zfbih_sfa-vkbur
                                             AND bbeln = ls_zfbih_sfa-bbeln.
      IF ls_zfbid_sfa-bflag = 'D'.
        ls_bi-bbeln   = space.
      ELSE.
        ls_bi-bbeln   = ls_zfbih_sfa-bbeln.
      ENDIF.
      ls_bi-bidat   = ls_zfbih_sfa-bidat.
      ls_bi-zuonr   = ls_zfbid_sfa-zuonr.
      ls_bi-wrbtr   = ls_zfbid_sfa-wrbtr.
      APPEND ls_bi TO gt_bi.
      CLEAR ls_bi.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_GET_BI_SFA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BI_PAYCUST
*&---------------------------------------------------------------------*
FORM f_get_bi_paycust  TABLES   ft_xfbid STRUCTURE zfbid.
  DATA : lt_zfbid_paycust TYPE STANDARD TABLE OF zfbid_paycust,
         lt_xfbid_paycust TYPE STANDARD TABLE OF zfbid_paycust,
         ls_zfbid_paycust LIKE LINE OF lt_zfbid_paycust.

  DATA : lt_zfbih_paycust TYPE STANDARD TABLE OF zfbih_paycust,
         ls_zfbih_paycust LIKE LINE OF lt_zfbih_paycust,
         ls_bi            LIKE LINE OF gt_bi.

  SELECT *
    FROM zfbid_paycust
    APPENDING CORRESPONDING FIELDS OF TABLE lt_zfbid_paycust
    FOR ALL ENTRIES IN ft_xfbid
    WHERE bukrs = ft_xfbid-bukrs
      AND vkbur = ft_xfbid-vkbur
      AND zuonr = ft_xfbid-zuonr.

  CLEAR : lt_xfbid_paycust[].
  lt_xfbid_paycust[] = lt_zfbid_paycust[].
  SORT lt_xfbid_paycust BY bukrs vkbur bbeln.
  DELETE ADJACENT DUPLICATES FROM lt_xfbid_paycust COMPARING bukrs vkbur bbeln.
  IF lt_xfbid_paycust[] IS NOT INITIAL.
    SELECT *
      FROM zfbih_paycust
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbih_paycust
      FOR ALL ENTRIES IN lt_xfbid_paycust
      WHERE bukrs = lt_xfbid_paycust-bukrs
        AND vkbur = lt_xfbid_paycust-vkbur
        AND bbeln = lt_xfbid_paycust-bbeln.
  ENDIF.

  LOOP AT lt_zfbih_paycust INTO ls_zfbih_paycust.
    LOOP AT lt_zfbid_paycust INTO ls_zfbid_paycust WHERE bukrs = ls_zfbih_paycust-bukrs
                                                     AND vkbur = ls_zfbih_paycust-vkbur
                                                     AND bbeln = ls_zfbih_paycust-bbeln.
      IF ls_zfbid_paycust-bflag = 'D'.
        ls_bi-bbeln   = space.
      ELSE.
        ls_bi-bbeln   = ls_zfbih_paycust-bbeln.
      ENDIF.
      ls_bi-bidat   = ls_zfbih_paycust-bidat.
      ls_bi-zuonr   = ls_zfbid_paycust-zuonr.
      ls_bi-wrbtr   = ls_zfbid_paycust-wrbtr.
      APPEND ls_bi TO gt_bi.
      CLEAR ls_bi.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_GET_BI_PAYCUST

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_BI
*&---------------------------------------------------------------------*
FORM f_modify_bi .
  DATA : ls_vbak LIKE LINE OF gt_vbak,
         ls_vbfa LIKE LINE OF gt_vbfa,
         ls_bi   LIKE LINE OF gt_bi.

  SORT gt_bi BY zuonr bidat DESCENDING bbeln DESCENDING.

  LOOP AT gt_zfarpotd.
    CLEAR ls_vbak.
    READ TABLE gt_vbak INTO ls_vbak
                       WITH KEY bstnk = gt_zfarpotd-rtvnr.
    IF sy-subrc = 0.
      CLEAR ls_vbfa.
      READ TABLE gt_vbfa INTO ls_vbfa
                         WITH KEY vbelv = ls_vbak-vbeln.
      IF sy-subrc = 0.
        gt_zfarpotd-vbeln = ls_vbfa-vbeln.

        CLEAR ls_bi.
        READ TABLE gt_bi INTO ls_bi
                         WITH KEY zuonr = ls_vbfa-vbeln.
        IF sy-subrc = 0.
          gt_zfarpotd-bbeln = ls_bi-bbeln.
          gt_zfarpotd-wrbtr = ls_bi-wrbtr.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY gt_zfarpotd TRANSPORTING vbeln bbeln wrbtr.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_BI

*&---------------------------------------------------------------------*
*&      Module  FILL_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_screen OUTPUT.
  PERFORM f_fill_screen.
ENDMODULE.                 " FILL_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_FILL_SCREEN
*&---------------------------------------------------------------------*
FORM f_fill_screen .
  CASE sy-dynnr.
    WHEN '0100'.
      PERFORM f_modify_screen USING 'POS' '' '0' '0' '1'.

      t_tabstrip-activetab = gt_tabstrip-pressed_tab.
      CASE gt_tabstrip-pressed_tab.
        WHEN ct_tabstrip-tab1.
          gt_tabstrip-subscreen = '0901'.
        WHEN ct_tabstrip-tab2.
          gt_tabstrip-subscreen = '0902'.
        WHEN ct_tabstrip-tab3.
          gt_tabstrip-subscreen = '0903'.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_FILL_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_TABSTRIP_HANDLE_CODE
*&---------------------------------------------------------------------*
FORM f_tabstrip_handle_code  USING    fu_ucomm.
  CASE fu_ucomm.
    WHEN ct_tabstrip-tab1.
      gt_tabstrip-pressed_tab = ct_tabstrip-tab1.
    WHEN ct_tabstrip-tab2.
      gt_tabstrip-pressed_tab = ct_tabstrip-tab2.
    WHEN ct_tabstrip-tab3.
      gt_tabstrip-pressed_tab = ct_tabstrip-tab3.
  ENDCASE.
ENDFORM.                    " F_TABSTRIP_HANDLE_CODE

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_pbo.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  CASE sy-dynnr.
    WHEN '0901'.

    WHEN '0902'.
      CLEAR txt201.
      SELECT SINGLE txt20 INTO txt201
        FROM skat
        WHERE spras = sy-langu
          AND ktopl = 'TSPC'
          AND saknr = hkont1.

      PERFORM f_modify_screen USING 'VCH' '' '0' '' ''.

    WHEN '0903'.
      CLEAR txt202.
      SELECT SINGLE txt20 INTO txt202
        FROM skat
        WHERE spras = sy-langu
          AND ktopl = 'TSPC'
          AND saknr = hkont2.

      PERFORM f_modify_screen USING 'VCH' '' '0' '' ''.
  ENDCASE.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_pai.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_PAI
*&---------------------------------------------------------------------*
FORM f_pai .

ENDFORM.                    " F_PAI

*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_document_post  USING    fu_post fu_hkont fu_voucher fu_wrbtr.
  DATA : obj_type       LIKE bapiache09-obj_type,
         documentheader TYPE bapiache09,
         accountgl      TYPE STANDARD TABLE OF bapiacgl09,
         currencyamount TYPE STANDARD TABLE OF bapiaccr09,
         criteria       TYPE STANDARD TABLE OF bapiackec9,
         extension1     TYPE STANDARD TABLE OF bapiacextc,
         return         TYPE STANDARD TABLE OF bapiret2,
         ls_return      LIKE LINE OF return.

  DATA : lv_bsch1 TYPE bseg-bschl,
         lv_bsch2 TYPE bseg-bschl,
         lv_sgtxt TYPE bseg-sgtxt,
         lv_kostl TYPE bseg-kostl,
         lv_vbund TYPE bseg-vbund,
         lv_belnr TYPE bkpf-belnr,
         lv_gjahr TYPE bkpf-gjahr.

  obj_type = 'BKPF'.

  PERFORM f_prepare_header USING    fu_voucher
                           CHANGING documentheader.

  CASE fu_post.
    WHEN '1'.
      lv_bsch1     = '50'.
      lv_bsch2     = '40'.
      CONCATENATE 'Selisih pembulatan' noarp INTO lv_sgtxt
      SEPARATED BY space.
      CONCATENATE vkbur+1(3) '0401' INTO lv_kostl.
      PERFORM f_alpha_modify CHANGING lv_kostl.
      lv_vbund     = 'OTHERS'.
    WHEN '2'.
      lv_bsch1     = '40'.
      lv_bsch2     = '50'.
      CONCATENATE 'Selisih pembulatan' noarp INTO lv_sgtxt
      SEPARATED BY space.
      CONCATENATE vkbur+1(3) '0401' INTO lv_kostl.
      PERFORM f_alpha_modify CHANGING lv_kostl.
      lv_vbund     = 'OTHERS'.
  ENDCASE.

  PERFORM f_prepare_detail TABLES accountgl currencyamount extension1 criteria
                           USING fu_hkont fu_voucher lv_bsch1 lv_bsch2 fu_wrbtr
                                 lv_sgtxt lv_kostl lv_vbund.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = documentheader
    IMPORTING
      obj_type       = obj_type
    TABLES
      accountgl      = accountgl
      currencyamount = currencyamount
      criteria       = criteria
      extension1     = extension1
      return         = return.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    LOOP AT return INTO ls_return.
      IF ls_return-type = 'S'.
        lv_belnr    = ls_return-message_v2(10).
        lv_gjahr    = ls_return-message_v2+14(4).
      ENDIF.
    ENDLOOP.
    IF lv_belnr IS NOT INITIAL.
      CASE fu_post.
        WHEN '1'.
        WHEN '2'.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DOCUMENT_POST

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_HEADER
*&---------------------------------------------------------------------*
FORM f_prepare_header  USING fu_xblnr
                       CHANGING documentheader   TYPE bapiache09.
  DATA : lv_bktxt   TYPE bkpf-bktxt.

  CLEAR : documentheader.

  documentheader-bus_act    = 'RFBU'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = p_bukrs.
  documentheader-doc_date   = budat.
  documentheader-pstng_date = budat.
  documentheader-doc_type   = 'SA'.
  documentheader-ref_doc_no = fu_xblnr.
  CONCATENATE 'Selisih nilai' noarp INTO documentheader-header_txt
  SEPARATED BY space.
ENDFORM.                    " F_PREPARE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  TABLES   accountgl         STRUCTURE bapiacgl09
                                currencyamount    STRUCTURE bapiaccr09
                                extension1        STRUCTURE bapiacextc
                                criteria          STRUCTURE bapiackec9
                       USING    fu_hkont fu_voucher fu_bsch1 fu_bsch2
                                fu_wrbtr fu_sgtxt fu_kostl fu_vbund.

  DATA : lv_buzei TYPE bseg-buzei,
         lv_count TYPE i.

  CLEAR : accountgl[], currencyamount[], extension1[], criteria[].

  ADD 1 TO lv_count.
  lv_buzei  = lv_count.
  PERFORM f_line_post TABLES  accountgl
                              currencyamount
                              extension1
                              criteria
                      USING   fu_bsch1 lv_buzei fu_sgtxt fu_wrbtr
                              fu_voucher hkont '' fu_vbund.

  ADD 1 TO lv_count.
  lv_buzei  = lv_count.
  PERFORM f_line_post TABLES  accountgl
                              currencyamount
                              extension1
                              criteria
                      USING   fu_bsch2 lv_buzei fu_sgtxt fu_wrbtr
                              fu_voucher fu_hkont fu_kostl fu_vbund.
ENDFORM.                    " F_PREPARE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_LINE_POST
*&---------------------------------------------------------------------*
FORM f_line_post  TABLES   accountgl         STRUCTURE bapiacgl09
                           currencyamount    STRUCTURE bapiaccr09
                           extension1        STRUCTURE bapiacextc
                           criteria          STRUCTURE bapiackec9
                   USING   fu_bschl fu_buzei fu_sgtxt fu_wrbtr
                           fu_voucher fu_hkont fu_kostl fu_vbund.

  DATA : lv_wrbtr           TYPE s626-zdisb1.

  accountgl-itemno_acc         = fu_buzei.
  accountgl-bus_area           = vkbur.
  accountgl-gl_account         = fu_hkont.
  accountgl-alloc_nmbr         = fu_voucher.
  accountgl-item_text          = fu_sgtxt.
  accountgl-costcenter         = fu_kostl.
  accountgl-trade_id           = fu_vbund.
  APPEND accountgl.

  extension1(3)                = fu_buzei.
  extension1+3(2)              = fu_bschl.
  APPEND extension1.

  currencyamount-itemno_acc    = fu_buzei.
  currencyamount-curr_type     = '00'.
  currencyamount-currency      = 'IDR'.
  lv_wrbtr  = abs( fu_wrbtr ).
  lv_wrbtr = lv_wrbtr / 100.
  PERFORM f_value_conversion USING lv_wrbtr fu_bschl
                             CHANGING currencyamount-amt_doccur.
  APPEND currencyamount.
ENDFORM.                    " F_LINE_POST

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_value_conversion  USING    fu_value fu_bschl
                         CHANGING fc_value.
  DATA : ls_tbsl      LIKE LINE OF gt_tbsl,
         lv_value(15).

  lv_value = fu_value.
  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.
  fc_value = lv_value.

  CLEAR ls_tbsl.
  READ TABLE gt_tbsl INTO ls_tbsl
                     WITH KEY bschl = fu_bschl.
  IF ls_tbsl-shkzg = 'H'.
    fc_value = fc_value * -1.
  ENDIF.
ENDFORM.                    " F_VALUE_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_MODIFY
*&---------------------------------------------------------------------*
FORM f_alpha_modify  CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fc_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_ALPHA_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_BI_NEW
*&---------------------------------------------------------------------*
FORM f_modify_bi_new .
  DATA : ls_vbak LIKE LINE OF gt_vbak,
         ls_vbfa LIKE LINE OF gt_vbfa,
         ls_bi   LIKE LINE OF gt_bi.

  DATA : lt_zfarpotd   LIKE gt_zfarpotd OCCURS 0,
         ls_zfarpotd   LIKE LINE OF lt_zfarpotd,
         ls_zfarpotdcn LIKE LINE OF gt_zfarpotdcn.

  DATA : lv_posnr  TYPE zfarpotd-posnr,
         lv_subrc  TYPE sy-subrc,
         lv_posamt TYPE zfarpotdcn-inpamt.

  SORT gt_bi BY zuonr bidat bbeln.
  lt_zfarpotd[] = gt_zfarpotd[].
  CLEAR gt_zfarpotd[].

  LOOP AT lt_zfarpotd INTO ls_zfarpotd.
    CLEAR : ls_vbak.
    LOOP AT gt_vbak INTO ls_vbak WHERE knkli = ls_zfarpotd-kunnr
                                   AND bstnk = ls_zfarpotd-rtvnr.
      ADD 10 TO lv_posnr.
      CLEAR ls_vbfa.
      READ TABLE gt_vbfa INTO ls_vbfa
                         WITH KEY vbelv = ls_vbak-vbeln.
      IF sy-subrc = 0.
        ls_zfarpotd-vbeln = ls_vbfa-vbeln.

        READ TABLE gt_zfarpotdcn INTO ls_zfarpotdcn
                                 WITH KEY bukrs = ls_zfarpotd-bukrs
                                          gsber = ls_zfarpotd-gsber
                                          vkbur = ls_zfarpotd-vkbur
                                          noarp = ls_zfarpotd-noarp
                                          mjahr = ls_zfarpotd-mjahr
                                          rtvnr = ls_zfarpotd-rtvnr
                                          zuonr = ls_zfarpotd-vbeln.
        IF sy-subrc = 0.
          IF pa_cek IS INITIAL.
            lv_posnr = lv_posnr - 10.
            CONTINUE.
          ELSE.
            lv_subrc = 4.
          ENDIF.
        ELSE.
          IF pa_cek IS NOT INITIAL.
            lv_posnr = lv_posnr - 10.
            CONTINUE.
          ENDIF.
        ENDIF.

        IF lv_subrc = 0.
          CLEAR ls_bi.
          LOOP AT gt_bi INTO ls_bi WHERE zuonr = ls_vbfa-vbeln.
            IF ls_zfarpotd-wrbtr IS INITIAL.
              ls_zfarpotd-wrbtr = abs( ls_bi-wrbtr ).
            ENDIF.
          ENDLOOP.
          ls_zfarpotd-bbeln = ls_bi-bbeln.
        ELSE.
*          CLEAR ls_zfarpotd-vbeln.
          CLEAR lv_posamt.
          LOOP AT gt_zfarpotdcn INTO ls_zfarpotdcn
                                WHERE bukrs = ls_zfarpotd-bukrs
                                  AND gsber = ls_zfarpotd-gsber
                                  AND vkbur = ls_zfarpotd-vkbur
                                  AND noarp = ls_zfarpotd-noarp
                                  AND mjahr = ls_zfarpotd-mjahr
                                  AND rtvnr = ls_zfarpotd-rtvnr
                                  AND zuonr = ls_zfarpotd-vbeln.
            ADD ls_zfarpotdcn-inpamt TO lv_posamt.
          ENDLOOP.

          ls_zfarpotd-posamt  = lv_posamt / 100.
          ls_zfarpotd-wrbtr   = ls_zfarpotdcn-wrbtr / 100.
        ENDIF.
      ENDIF.
      ls_zfarpotd-nou = lv_posnr.
      APPEND ls_zfarpotd TO gt_zfarpotd.
      ADD lv_posamt TO inpamt.
      CLEAR : ls_zfarpotd-bbeln, ls_zfarpotd-wrbtr, lv_subrc.
    ENDLOOP.
    IF sy-subrc <> 0.
      IF pa_cek IS INITIAL.
        ADD 10 TO lv_posnr.
        ls_zfarpotd-nou = lv_posnr.
        APPEND ls_zfarpotd TO gt_zfarpotd.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_BI_NEW

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_TOTAL_RTV
*&---------------------------------------------------------------------*
FORM f_check_total_rtv  TABLES   ft_vdata   LIKE gt_xdata
                        USING    fu_kunnr fu_rtvnr fu_rtvamt
                        CHANGING fc_count fc_inpamt fc_rtvamt fc_wrbtr fc_posamt.
  DATA : lv_count      TYPE i,
         lv_inpamt     TYPE zfarpotd-inpamt,
         lv_rtvamt     TYPE zfarpotd-rtvamt,
         lv_posamt     TYPE zfarpotd-posamt,
         lv_wrbtr      TYPE zwert7,
         ls_zfarpotdcn LIKE LINE OF gt_zfarpotdcn.

  LOOP AT ft_vdata WHERE rtvnr = fu_rtvnr
                     AND kunnr = fu_kunnr.
    ADD 1 TO lv_count.
    ADD ft_vdata-inpamt TO lv_inpamt.
    ADD ft_vdata-rtvamt TO lv_rtvamt.
    ADD ft_vdata-wrbtr TO lv_wrbtr.
    ADD ft_vdata-posamt TO lv_posamt.
  ENDLOOP.

  IF lv_count = 1.
    CLEAR ls_zfarpotdcn.
    READ TABLE gt_zfarpotdcn INTO ls_zfarpotdcn
                             WITH KEY rtvnr = fu_rtvnr
                                      stblg = space.
    IF sy-subrc = 0.
      lv_count = lv_count + 1.
    ENDIF.
  ENDIF.

  fc_count  = lv_count.
  fc_inpamt = lv_inpamt.
  fc_rtvamt = lv_rtvamt.
  fc_wrbtr  = lv_wrbtr.
  fc_posamt = lv_posamt.
ENDFORM.                    " F_CHECK_TOTAL_RTV

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group1 fu_name fu_active fu_input fu_invisible.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group1.
        screen-active  = fu_active.
      ENDIF.
      IF screen-name = fu_name.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group1.
        screen-input  = fu_input.
      ENDIF.
      IF screen-name = fu_name.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group1.
        screen-invisible  = fu_invisible.
      ENDIF.
      IF screen-name = fu_name.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_read_table_control .
  DATA : lt_zfarpotd   LIKE gt_zfarpotd OCCURS 0,
         ls_zfarpotd   LIKE LINE OF lt_zfarpotd,
         lt_zfarpotdcn TYPE STANDARD TABLE OF zfarpotdcn,
         ls_zfarpotdcn LIKE LINE OF lt_zfarpotdcn.

  DATA : lv_count   TYPE i.

  CASE 'X'.
    WHEN p_input.
      IF gt_zfarpotd-flag IS INITIAL.
        CLEAR : gt_zfarpotd-icon, gt_zfarpotd-selisih, gt_zfarpotd-inpamt.
      ELSE.
        IF gt_zfarpotd-inpamt IS INITIAL.
          lt_zfarpotd[] = gt_zfarpotd[].
          lt_zfarpotdcn[] = gt_zfarpotdcn[].
          LOOP AT lt_zfarpotd INTO ls_zfarpotd WHERE rtvnr = gt_zfarpotd-rtvnr
                                                 AND kunnr = gt_zfarpotd-kunnr.
            ADD 1 TO lv_count.
          ENDLOOP.
          LOOP AT lt_zfarpotdcn INTO ls_zfarpotdcn WHERE rtvnr = gt_zfarpotd-rtvnr
                                                     AND stblg = space.
            ADD 1 TO lv_count.
          ENDLOOP.

          IF lv_count = 1.
            gt_zfarpotd-inpamt = gt_zfarpotd-rtvamt.
          ELSE.
            gt_zfarpotd-inpamt = gt_zfarpotd-wrbtr.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY gt_vdata FROM gt_zfarpotd INDEX input-current_line.
    WHEN p_revrs.
      MODIFY gt_vdata FROM gt_zfarpotd INDEX reverse-current_line.
  ENDCASE.
ENDFORM.                    " F_READ_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_TABLE_CN
*&---------------------------------------------------------------------*
FORM f_prepare_table_cn  TABLES   ft_zfarpotdcn STRUCTURE zfarpotdcn
                         USING    fs_vdata LIKE gt_vdata
*                                  fs_zfarpotdcn TYPE zfarpotdcn
                                  fu_belnr.
  DATA : ls_zfarpotdcn   TYPE zfarpotdcn.

  CASE 'X'.
    WHEN p_input.
      IF fs_vdata-vbeln IS NOT INITIAL.
        MOVE-CORRESPONDING fs_vdata TO ls_zfarpotdcn.
        ls_zfarpotdcn-belnr   = fu_belnr.
        ls_zfarpotdcn-zuonr   = fs_vdata-vbeln.
        IF pa_cek IS INITIAL.
          ls_zfarpotdcn-selamt  = fs_vdata-selisih.
        ELSE.
          ls_zfarpotdcn-selamt  = 0.
        ENDIF.
        IF ls_zfarpotdcn-inpamt <> 0.
          APPEND ls_zfarpotdcn TO ft_zfarpotdcn.
        ENDIF.
      ENDIF.

    WHEN p_revrs.
*****      MOVE-CORRESPONDING fs_zfarpotdcn TO ls_zfarpotdcn.
*****      ls_zfarpotdcn-stblg = fu_belnr.
*****      ls_zfarpotdcn-stjah = p_mjahr.
*****      APPEND ls_zfarpotdcn TO ft_zfarpotdcn.
  ENDCASE.
ENDFORM.                    " F_PREPARE_TABLE_CN

*&---------------------------------------------------------------------*
*&      Form  F_ALPHA_CONVERSION
*&---------------------------------------------------------------------*
FORM f_alpha_conversion  USING    fu_value
                         CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_ALPHA_CONVERSION
