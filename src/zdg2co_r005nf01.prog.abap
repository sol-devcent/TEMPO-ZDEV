**----------------------------------------------------------------------*
*   INCLUDE ZDG2CO_R005F01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  PERFORM f_change_line_size.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: ld_datefr LIKE sy-datum,
        ld_dateto LIKE sy-datum.

  IF s_aufnr[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'I'.
    STOP.
  ELSE.
    CONCATENATE p_gjahr '0101' INTO ld_datefr.
    CONCATENATE p_gjahr '1231' INTO ld_dateto.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE t_t001
      FROM t001
      WHERE bukrs = p_bukrs.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE t_tcurr
      FROM tcurr
      WHERE kurst = c_kurst.

    SELECT aufnr auart autyp bukrs werks gsber kokrs ktext objnr
           kostv akstl aufex
      INTO CORRESPONDING FIELDS OF TABLE t_aufk
      FROM aufk
      WHERE kokrs = p_kokrs AND
            bukrs = p_bukrs AND
            akstl IN s_akstl AND
            aufnr IN s_aufnr.

    IF t_aufk[] IS NOT INITIAL.
      SELECT kokrs kostl ktext ltext mctxt
        INTO CORRESPONDING FIELDS OF TABLE t_cskt
        FROM cskt
        FOR ALL ENTRIES IN t_aufk
        WHERE spras = sy-langu  AND
              kokrs = t_aufk-kokrs AND
              kostl = t_aufk-akstl AND
              datbi GE ld_datefr.

      SELECT objnr gjahr wrttp versn wtjhr wljhr twaer
        INTO CORRESPONDING FIELDS OF TABLE t_bpja
        FROM bpja
        FOR ALL ENTRIES IN t_aufk
        WHERE objnr = t_aufk-objnr AND
              gjahr = p_gjahr      AND
              wrttp = c_wrttp      AND
              versn = c_versn.

      SELECT eaufn bukrs anln1 anln2 menge meins txt50
        INTO CORRESPONDING FIELDS OF TABLE t_anla
        FROM anla
        FOR ALL ENTRIES IN t_aufk
        WHERE eaufn = t_aufk-aufnr AND
              bukrs = t_aufk-bukrs AND
              erdat BETWEEN ld_datefr AND ld_dateto.

      IF  t_bpja[] IS INITIAL AND
          t_anla[] IS INITIAL.
        MESSAGE 'No Data' TYPE 'I'.
        STOP.
      ELSE.
        IF t_anla[] IS NOT INITIAL.
          SELECT bukrs anln1 anln2 bdatu adatu kostl
            INTO CORRESPONDING FIELDS OF TABLE t_anlz FROM anlz
            FOR ALL ENTRIES IN t_anla
            WHERE bukrs = t_anla-bukrs
              AND anln1 = t_anla-anln1.
          IF sy-subrc = 0.
            SELECT kokrs kostl ktext ltext mctxt
              INTO CORRESPONDING FIELDS OF TABLE t_cskta
              FROM cskt FOR ALL ENTRIES IN t_anlz
              WHERE spras = sy-langu  AND
                    kokrs = p_kokrs AND
                    kostl = t_anlz-kostl AND
                    datbi GE ld_datefr.
          ENDIF.

          SELECT a~banfn a~bnfpo a~anln1 a~anln2 a~gsber
                 b~preis b~waers b~peinh b~frgdt b~menge b~meins b~erdat
            INTO CORRESPONDING FIELDS OF TABLE t_ebkn
            FROM ebkn AS a JOIN eban AS b ON a~banfn = b~banfn AND
                                             a~bnfpo = b~bnfpo
            FOR ALL ENTRIES IN t_anla
            WHERE a~anln1 = t_anla-anln1 AND
                  a~anln2 = t_anla-anln2 AND
                  a~kokrs = p_kokrs      AND
                  b~frgdt BETWEEN ld_datefr AND ld_dateto AND
                  b~loekz EQ '' AND
                  a~loekz EQ ''.

          SELECT a~anln1 a~anln2 a~gsber a~ebeln a~ebelp
                 b~netpr b~netwr b~peinh b~menge b~meins
                 c~waers c~aedat
            INTO CORRESPONDING FIELDS OF TABLE t_ekkn
            FROM ekkn AS a JOIN ekpo AS b ON a~ebeln = b~ebeln AND
                                             a~ebelp = b~ebelp
                           JOIN ekko AS c ON a~ebeln = c~ebeln
            FOR ALL ENTRIES IN t_anla
            WHERE a~anln1 = t_anla-anln1 AND
                  a~anln2 = t_anla-anln2 AND
                  c~aedat BETWEEN ld_datefr AND ld_dateto AND
                  c~loekz EQ '' AND
                  b~loekz EQ ''.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT t_ebkn.
    t_ebkn-preis  = ( t_ebkn-preis / t_ebkn-peinh ) * t_ebkn-menge.
    MODIFY t_ebkn TRANSPORTING preis.
  ENDLOOP.

  PERFORM f_get_invoice.
  PERFORM f_get_payment.
  PERFORM f_get_good_receipt.
  PERFORM f_get_ppn_pph.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  IF p_alv IS INITIAL.
    SET PF-STATUS 'STATUS100'.
    CASE 'X'.
      WHEN p_rad1.
        IF p_setnm IS INITIAL.
          PERFORM f_listing_report_order.
        ELSE.
          PERFORM f_listing_report.
        ENDIF.
      WHEN p_rad2.
        PERFORM f_write_detail.
    ENDCASE.
  ELSE.
    IF p_setnm IS INITIAL.
      PERFORM f_alv TABLES t_out.
    ELSE.
      PERFORM f_alv_hierarchy TABLES t_hdr t_out.
    ENDIF.
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
      i_tabname_header         = 'T_HDR'
      i_tabname_item           = 'T_OUT'
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

  PERFORM f_fieldcatg USING ft_report:
    'AUFNR' 'AUFK' 'AUFNR' '' '' 'Order' '' '' '' '' '' '' '' '' '' 'X',
    'KTEXT' 'AUFK' 'KTEXT' '' '' 'Order Desc.' '' '' '' '' '' '' '' '' '' 'X',
    'AUFEX' 'AUFK' 'AUFEX' '' '' 'Ext. Order' '' '' '' '' '' '' '' '' '' 'X',
    'AKSTL' 'AUFK' 'AKSTL' '' '' 'CosCtrBudCd' '' '' '' '' '' '' '' '' '' '',
    'PROFT' 'CSKT' 'KTEXT' '' '' 'Cost Center Budger' '' '' '' '' '' '' '' '' '' '',
    'KOSTL' 'CSKT' 'KOSTL' '' '' 'CosCtrActCd' '' '' '' '' '' '' '' '' '' '',
    'KOSTX' 'CSKT' 'KTEXT' '' '' 'Cost Center Actual' '' '' '' '' '' '' '' '' '' '',
*    'GJAHR' 'BPJA' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WTJHR' 'BPJA' 'WTJHR' '' '' 'BudgTransVal' '' '' '' '' '' '' '' '' '' '',
    'TWAER' 'BPJA' 'TWAER' '' '' 'BudgTransCurr' '' '' '' '' '' '' '' '' '' '',
    'WLJHR' 'BPJA' 'WLJHR' '' '' 'BudgLocalVal' '' '' '' '' '' '' '' '' '' '',
    'WAERS' 'T001' 'WAERS' '' '' 'BudgLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'MENGE' 'ANLA' 'MENGE' '' '' 'BudgQuantity' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'ANLA' 'MEINS' '' '' 'BudgUoM' '' '' '' '' '' '' '' '' '' '',
    'PREIS' 'BPJA' 'WTJHR' '' '' 'RFATransVal' '' '' '' '' '' '' '' '' '' '',
    'RFATC' 'EBAN' 'WAERS' '' '' 'RFATransCurr' '' '' '' '' '' '' '' '' '' '',
    'RFALC' 'BPJA' 'WTJHR' '' '' 'RFALocalVal' '' '' '' '' '' '' '' '' '' '',
    'RFALOC' 'T001' 'WAERS' '' '' 'RFALocalCurr' '' '' '' '' '' '' '' '' '' '',
    'RFAQT' 'EBAN' 'MENGE' '' '' 'RFAQuantity' '' '' '' '' '' '' '' '' '' '',
    'RFAUM' 'EBAN' 'MEINS' '' '' 'RFAUoM' '' '' '' '' '' '' '' '' '' '',
    'NETWR' 'EKPO' 'NETWR' '' '' 'PORealTransVal' '' '' '' '' '' '' '' '' '' '',
    'ACTTC' 'EKKO' 'WAERS' '' '' 'PORealTransCurr' '' '' '' '' '' '' '' '' '' '',
    'ACTLC' 'BPJA' 'WTJHR' '' '' 'PORealLocalVal' '' '' '' '' '' '' '' '' '' '',
    'ACTLOC' 'T001' 'WAERS' '' '' 'PORealLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'ACTQT' 'EKPO' 'MENGE' '' '' 'PORealQuantity' '' '' '' '' '' '' '' '' '' '',
    'ACTUM' 'EKPO' 'MEINS' '' '' 'PORealUom' '' '' '' '' '' '' '' '' '' '',
    'GRTC' 'EKBE' 'WRBTR' '' '' 'GRTransVal' '' '' '' '' '' '' '' '' '' '',
    'GRTCC' 'EKBE' 'WAERS' '' '' 'GRTransCurr' '' '' '' '' '' '' '' '' '' '',
    'GRLC' 'EKBE' 'DMBTR' '' '' 'GRLocalVal' '' '' '' '' '' '' '' '' '' '',
    'GRLCC' 'EKBE' 'WAERS' '' '' 'GRLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'GRQTY' 'EKBE' 'MENGE' '' '' 'GRQuantity' '' '' '' '' '' '' '' '' '' '',
    'GRUOM' 'EKBE' 'MEINS' '' '' 'GRUom' '' '' '' '' '' '' '' '' '' '',
    'BUDRFATC' 'BPJA' 'WTJHR' '' '' 'BudRFATransVal' '' '' '' '' '' '' '' '' '' '',
    'BUDRFALC' 'BPJA' 'WTJHR' '' '' 'BudRFALocalVal' '' '' '' '' '' '' '' '' '' '',
    'INVWRBTR' 'BPJA' 'WTJHR' '' '' 'InvTransVal' '' '' '' '' '' '' '' '' '' '',
    'INVWAER2' 'EKBE' 'WAERS' '' '' 'InvTransCurr' '' '' '' '' '' '' '' '' '' '',
    'INVDMBTR' 'BPJA' 'WTJHR' '' '' 'InvLocalVal' '' '' '' '' '' '' '' '' '' '',
    'INVWAER1' 'EKBE' 'WAERS' '' '' 'InvLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'INVMENGE' 'EKBE' 'MENGE' '' '' 'InvQuantity' '' '' '' '' '' '' '' '' '' '',
    'INVMEINS' 'EKBE' 'MEINS' '' '' 'InvUom' '' '' '' '' '' '' '' '' '' '',
    'PAYWRBTR' 'BPJA' 'WTJHR' '' '' 'PayTransVal' '' '' '' '' '' '' '' '' '' '',
    'PAYWAER2' 'EKBE' 'WAERS' '' '' 'PayTransCurr' '' '' '' '' '' '' '' '' '' '',
    'PAYDMBTR' 'BPJA' 'WTJHR' '' '' 'PayLocalVal' '' '' '' '' '' '' '' '' '' '',
    'PAYWAER1' 'EKBE' 'WAERS' '' '' 'PayLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'BI' 'BPJA' 'WTJHR' '' '' 'BalBudInv' '' '' '' '' '' '' '' '' '' '',
    'WAEBI' 'EKBE' 'WAERS' '' '' 'BICurr' '' '' '' '' '' '' '' '' '' '',
    'BP' 'BPJA' 'WTJHR' '' '' 'BalBudPay' '' '' '' '' '' '' '' '' '' '',
    'WAEBP' 'EKBE' 'WAERS' '' '' 'BPCurr' '' '' '' '' '' '' '' '' '' '',
    'IP' 'BPJA' 'WTJHR' '' '' 'BalInvPay' '' '' '' '' '' '' '' '' '' '',
    'WAEIP' 'EKBE' 'WAERS' '' '' 'IPCurr' '' '' '' '' '' '' '' '' '' '',
    'PPN' 'BSEG' 'DMBTR' '' '' 'PPN' '' '' '' '' '' '' '' '' '' '',
    'PPH' 'BSEG' 'DMBTR' '' '' 'PPH' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcat_hierarchy                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat_hierarchy TABLES ft_hdr ft_out.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'T_HDR':
    'SUBSETNAME' 'SETLEAF' 'SETNAME' '' '' 'Group' '' '' '' '' '' '' '' '' '' '',
    'DESCRIPT' '' '' '' '' 'Group Description' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'T_OUT':
    'AUFNR' 'AUFK' 'AUFNR' '' '' 'Order' '' '' '' '' '' '' '' '' '' 'X',
    'KTEXT' 'AUFK' 'KTEXT' '' '' 'Order Desc.' '' '' '' '' '' '' '' '' '' 'X',
    'AUFEX' 'AUFK' 'AUFEX' '' '' 'Ext. Order' '' '' '' '' '' '' '' '' '' 'X',
    'AKSTL' 'AUFK' 'AKSTL' '' '' 'CosCtrBudCd' '' '' '' '' '' '' '' '' '' '',
    'PROFT' 'CSKT' 'KTEXT' '' '' 'Cost Center Budger' '' '' '' '' '' '' '' '' '' '',
    'KOSTL' 'CSKT' 'KOSTL' '' '' 'CosCtrActCd' '' '' '' '' '' '' '' '' '' '',
    'KOSTX' 'CSKT' 'KTEXT' '' '' 'Cost Center Actual' '' '' '' '' '' '' '' '' '' '',
*    'GJAHR' 'BPJA' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WTJHR' 'BPJA' 'WTJHR' '' '' 'BudgTransVal' '' '' '' '' '' '' '' '' '' '',
    'TWAER' 'BPJA' 'TWAER' '' '' 'BudgTransCurr' '' '' '' '' '' '' '' '' '' '',
    'WLJHR' 'BPJA' 'WLJHR' '' '' 'BudgLocalVal' '' '' '' '' '' '' '' '' '' '',
    'WAERS' 'T001' 'WAERS' '' '' 'BudgLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'MENGE' 'ANLA' 'MENGE' '' '' 'BudgQuantity' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'ANLA' 'MEINS' '' '' 'BudgUoM' '' '' '' '' '' '' '' '' '' '',
    'PREIS' 'BPJA' 'WTJHR' '' '' 'RFATransVal' '' '' '' '' '' '' '' '' '' '',
    'RFATC' 'EBAN' 'WAERS' '' '' 'RFATransCurr' '' '' '' '' '' '' '' '' '' '',
    'RFALC' 'BPJA' 'WTJHR' '' '' 'RFALocalVal' '' '' '' '' '' '' '' '' '' '',
    'RFALOC' 'T001' 'WAERS' '' '' 'RFALocalCurr' '' '' '' '' '' '' '' '' '' '',
    'RFAQT' 'EBAN' 'MENGE' '' '' 'RFAQuantity' '' '' '' '' '' '' '' '' '' '',
    'RFAUM' 'EBAN' 'MEINS' '' '' 'RFAUoM' '' '' '' '' '' '' '' '' '' '',
    'NETWR' 'EKPO' 'NETWR' '' '' 'PORealTransVal' '' '' '' '' '' '' '' '' '' '',
    'ACTTC' 'EKKO' 'WAERS' '' '' 'PORealTransCurr' '' '' '' '' '' '' '' '' '' '',
    'ACTLC' 'BPJA' 'WTJHR' '' '' 'PORealLocalVal' '' '' '' '' '' '' '' '' '' '',
    'ACTLOC' 'T001' 'WAERS' '' '' 'PORealLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'ACTQT' 'EKPO' 'MENGE' '' '' 'PORealQuantity' '' '' '' '' '' '' '' '' '' '',
    'ACTUM' 'EKPO' 'MEINS' '' '' 'PORealUom' '' '' '' '' '' '' '' '' '' '',
    'GRTC' 'EKBE' 'WRBTR' '' '' 'GRTransVal' '' '' '' '' '' '' '' '' '' '',
    'GRTCC' 'EKBE' 'WAERS' '' '' 'GRTransCurr' '' '' '' '' '' '' '' '' '' '',
    'GRLC' 'EKBE' 'DMBTR' '' '' 'GRLocalVal' '' '' '' '' '' '' '' '' '' '',
    'GRLCC' 'EKBE' 'WAERS' '' '' 'GRLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'GRQTY' 'EKBE' 'MENGE' '' '' 'GRQuantity' '' '' '' '' '' '' '' '' '' '',
    'GRUOM' 'EKBE' 'MEINS' '' '' 'GRUom' '' '' '' '' '' '' '' '' '' '',
    'BUDRFATC' 'BPJA' 'WTJHR' '' '' 'BudRFATransVal' '' '' '' '' '' '' '' '' '' '',
    'BUDRFALC' 'BPJA' 'WTJHR' '' '' 'BudRFALocalVal' '' '' '' '' '' '' '' '' '' '',
    'INVWRBTR' 'BPJA' 'WTJHR' '' '' 'InvTransVal' '' '' '' '' '' '' '' '' '' '',
    'INVWAER2' 'EKBE' 'WAERS' '' '' 'InvTransCurr' '' '' '' '' '' '' '' '' '' '',
    'INVDMBTR' 'BPJA' 'WTJHR' '' '' 'InvLocalVal' '' '' '' '' '' '' '' '' '' '',
    'INVWAER1' 'EKBE' 'WAERS' '' '' 'InvLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'INVMENGE' 'EKBE' 'MENGE' '' '' 'InvQuantity' '' '' '' '' '' '' '' '' '' '',
    'INVMEINS' 'EKBE' 'MEINS' '' '' 'InvUom' '' '' '' '' '' '' '' '' '' '',
    'PAYWRBTR' 'BPJA' 'WTJHR' '' '' 'PayTransVal' '' '' '' '' '' '' '' '' '' '',
    'PAYWAER2' 'EKBE' 'WAERS' '' '' 'PayTransCurr' '' '' '' '' '' '' '' '' '' '',
    'PAYDMBTR' 'BPJA' 'WTJHR' '' '' 'PayLocalVal' '' '' '' '' '' '' '' '' '' '',
    'PAYWAER1' 'EKBE' 'WAERS' '' '' 'PayLocalCurr' '' '' '' '' '' '' '' '' '' '',
    'BI' 'BPJA' 'WTJHR' '' '' 'BalBudInv' '' '' '' '' '' '' '' '' '' '',
    'WAEBI' 'EKBE' 'WAERS' '' '' 'BICurr' '' '' '' '' '' '' '' '' '' '',
    'BP' 'BPJA' 'WTJHR' '' '' 'BalBudPay' '' '' '' '' '' '' '' '' '' '',
    'WAEBP' 'EKBE' 'WAERS' '' '' 'BPCurr' '' '' '' '' '' '' '' '' '' '',
    'IP' 'BPJA' 'WTJHR' '' '' 'BalInvPay' '' '' '' '' '' '' '' '' '' '',
    'WAEIP' 'EKBE' 'WAERS' '' '' 'IPCurr' '' '' '' '' '' '' '' '' '' '',
    'PPN' 'BSEG' 'DMBTR' '' '' 'PPN' '' '' '' '' '' '' '' '' '' '',
    'PPH' 'BSEG' 'DMBTR' '' '' 'PPH' '' '' '' '' '' '' '' '' '' ''.
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
                          VALUE(fu_input)
                          VALUE(fu_key).

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

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  IF p_setnm IS NOT INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'SUBSETNAME'.
    ld_sort-tabname   = 'T_HDR'.
    ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.
  ENDIF.

  CLEAR ld_sort.
  ld_sort-fieldname = 'AUFNR'.
  ld_sort-tabname   = 'T_OUT'.
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
  DATA: ld_year(50),
        ld_linsz TYPE sylinsz.

  CASE 'X'.
    WHEN p_rad1.
      ld_linsz = 623.
    WHEN p_rad2.
      ld_linsz = 429.
  ENDCASE.

  CONCATENATE 'Year:' p_gjahr INTO ld_year SEPARATED BY space.
  PERFORM f_hdr_ulines.
  PERFORM f_hdr_line1s USING sy-title ld_linsz.
  PERFORM f_hdr_line2s USING '' ld_linsz.
  PERFORM f_hdr_line3s USING ld_year ld_linsz.
  PERFORM f_hdr_ulines.
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
  REFRESH: t_aufk,t_bpja,t_anla,t_ebkn,t_tcurr,t_t001,t_ekkn,t_out.
  CLEAR: t_aufk,t_bpja,t_anla,t_ebkn,t_tcurr,t_t001,t_ekkn,t_out.
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
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: ld_gdatu      LIKE tcurr-gdatu,
*        ld_ukurs LIKE tcurr-ukurs,
        ld_ukurs(15)  TYPE p DECIMALS 5,
        ld_netpr      LIKE ekpo-netpr,
        ld_netwr      LIKE ekpo-netwr,
        ld_value      LIKE bpja-wtjhr, "ekpo-netpr,
        ld_date       LIKE sy-datum,
        ld_cnt        TYPE int4,
        ld_line       TYPE int4,
        ld_subsetname LIKE t_setleaf-setname.

* Summary by Coloum
  LOOP AT t_aufk.
    CLEAR: t_cskt,t_t001,t_anla,t_bpja-wtjhr,t_bpja-wrttp,
           t_bpja-wljhr,t_anlz,t_cskta,t_anla.

    READ TABLE t_t001 WITH KEY bukrs = p_bukrs.
    READ TABLE t_cskt WITH KEY kokrs = t_aufk-kokrs
                               kostl = t_aufk-akstl.
    READ TABLE t_anla WITH KEY eaufn = t_aufk-aufnr
                               bukrs = t_aufk-bukrs.
    READ TABLE t_anlz WITH KEY bukrs = t_aufk-bukrs
                               anln1 = t_anla-anln1.
    READ TABLE t_cskta WITH KEY kokrs = t_aufk-kokrs
                                kostl = t_anlz-kostl.
    t_out-subsetname = ld_subsetname.
    t_out-aufnr = t_aufk-aufnr.
    t_out-ktext = t_aufk-ktext.
    t_out-gjahr = p_gjahr.
*    t_out-waers = t_t001-waers.
    t_out-kostv = t_aufk-kostv.
    t_out-akstl = t_aufk-akstl.
    t_out-aufex = t_aufk-aufex.
    t_out-proft = t_cskt-ktext.
    t_out-kostl = t_anlz-kostl.
    t_out-kostx = t_cskta-ktext.

    LOOP AT t_bpja WHERE objnr = t_aufk-objnr.
      IF t_bpja-twaer = 'IDR'.
        t_bpja-wtjhr = t_bpja-wtjhr * 100.
      ENDIF.
      t_bpja-wljhr = t_bpja-wljhr * 100.

* Summary Budget TC
      IF t_bpja-wtjhr IS NOT INITIAL.
        MOVE-CORRESPONDING t_out TO t_out1.
        t_out1-wtjhr = t_bpja-wtjhr.
        t_out1-twaer = t_bpja-twaer.
        COLLECT t_out1.
        CLEAR: t_out1-wtjhr,t_out1-twaer.
      ENDIF.

* Summary budget LC
      IF t_bpja-wljhr IS NOT INITIAL.
        MOVE-CORRESPONDING t_out TO t_out2.
        t_out2-wljhr = t_bpja-wljhr.
        t_out2-waers = t_t001-waers.
        COLLECT t_out2.
        CLEAR: t_out2-wljhr,t_out2-waers.
      ENDIF.
    ENDLOOP.

    LOOP AT t_anla WHERE eaufn = t_aufk-aufnr AND
                         bukrs = t_aufk-bukrs.

* Summary Budget Qty
      MOVE-CORRESPONDING t_out TO t_out3.
      t_out3-menge = t_anla-menge.
      t_out3-meins = t_anla-meins.
      COLLECT t_out3.
      CLEAR: t_out3-menge,t_out3-meins.

      LOOP AT t_ebkn WHERE anln1 = t_anla-anln1 AND
                           anln2 = t_anla-anln2 AND
                           gsber = t_aufk-gsber.
        IF t_ebkn-bnfpo NE '00010'.                 "Hanya ambil item 10 (req. by FAM 16.091.2016)
          CONTINUE.
        ENDIF.
* Summary RFA TC
        IF t_ebkn-waers = 'IDR'.
          t_ebkn-preis = t_ebkn-preis * 100.
        ENDIF.
        IF t_ebkn-preis IS NOT INITIAL.
          MOVE-CORRESPONDING t_out TO t_out4.
          t_out4-preis = t_ebkn-preis.
          t_out4-rfatc = t_ebkn-waers.
          COLLECT t_out4.
          CLEAR: t_out4-preis,t_out4-rfatc.
        ENDIF.

* Summary RFA LC
        IF t_ebkn-waers = t_t001-waers.
          t_out-rfalc = t_ebkn-preis.
        ELSE.
*& Kalau beda currency maka baca table currency.
          CLEAR: ld_gdatu,ld_ukurs.
          PERFORM f_difference_currency USING    t_ebkn-waers t_t001-waers t_ebkn-frgdt
                                        CHANGING ld_gdatu ld_date ld_ukurs.
          CLEAR: ld_value.
          ld_value = t_ebkn-preis * ld_ukurs.
          t_out-rfalc = ld_value.
        ENDIF.
        IF t_out-rfalc IS NOT INITIAL.
          MOVE-CORRESPONDING t_out TO t_out5.
          t_out5-rfalc = t_out-rfalc.
          t_out5-rfaloc = t_t001-waers.
          COLLECT t_out5.
          CLEAR: t_out5-rfalc,t_out5-rfaloc,t_out-rfalc.
        ENDIF.

* Summary RFA Qty
        IF t_ebkn-menge IS NOT INITIAL.
          MOVE-CORRESPONDING t_out TO t_out6.
          t_out6-rfaqt = t_ebkn-menge.
          t_out6-rfaum = t_ebkn-meins.
          COLLECT t_out6.
          CLEAR: t_out6-rfaqt,t_out6-rfaum.

*          MOVE-CORRESPONDING t_out TO t_out3.
*          t_out3-menge = t_ebkn-menge.
*          t_out3-meins = t_ebkn-meins.
*          COLLECT t_out3.
*          CLEAR: t_out3-menge,t_out3-meins.
        ENDIF.
      ENDLOOP.

      LOOP AT t_ekkn WHERE anln1 = t_anla-anln1 AND
                           anln2 = t_anla-anln2 AND
                           gsber = t_aufk-gsber.
* Summary PO TC
        IF t_ekkn-waers = 'IDR'.
          t_ekkn-netwr = t_ekkn-netwr * 100.
        ENDIF.
        CLEAR ld_netwr.
        ld_netwr = t_ekkn-netwr / t_ekkn-peinh.
        IF ld_netwr IS NOT INITIAL.
          MOVE-CORRESPONDING t_out TO t_out7.
          t_out7-netwr = ld_netwr.
          t_out7-acttc = t_ekkn-waers.
          COLLECT t_out7.
          CLEAR: t_out7-netwr,t_out7-acttc.
        ENDIF.

* Summary PO LC
        IF t_ekkn-waers = t_t001-waers.
          t_out-actlc = ld_netwr.
        ELSE.
          CLEAR: ld_gdatu,ld_ukurs.
*& Kalau beda currency maka baca table currency.
          PERFORM f_difference_currency USING    t_ebkn-waers t_t001-waers t_ekkn-aedat
                                        CHANGING ld_gdatu ld_date ld_ukurs.

          CLEAR: ld_value.
          ld_value = ld_netwr * ld_ukurs.
          t_out-actlc = ld_value.
        ENDIF.

        IF t_out-actlc IS NOT INITIAL.
          MOVE-CORRESPONDING t_out TO t_out8.
          t_out8-actlc = t_out-actlc.
          t_out8-actloc = t_t001-waers.
          COLLECT t_out8.
          CLEAR: t_out8-actlc,t_out8-actloc.
        ENDIF.

        IF t_ekkn-menge IS NOT INITIAL AND t_ekkn-ebelp = '00001'.
          MOVE-CORRESPONDING t_out TO t_out9.
          t_out9-actqt = t_ekkn-menge.
          t_out9-actum = t_ekkn-meins.
          COLLECT t_out9.
          CLEAR: t_out9-actqt,t_out9-actum.
        ENDIF.

* Hitung GR
        LOOP AT gt_ekbe_gr WHERE ebeln = t_ekkn-ebeln
                             AND ebelp = t_ekkn-ebelp.
          IF gt_ekbe_gr-shkzg = 'H'.
            gt_ekbe_gr-wrbtr = gt_ekbe_gr-wrbtr * -1.
            gt_ekbe_gr-dmbtr = gt_ekbe_gr-dmbtr * -1.
            gt_ekbe_gr-menge = gt_ekbe_gr-menge * -1.
          ENDIF.

* Summary GR TC
          IF gt_ekbe_gr-waers = 'IDR'.
            gt_ekbe_gr-wrbtr = gt_ekbe_gr-wrbtr * 100.
          ENDIF.
          IF gt_ekbe_gr-wrbtr IS NOT INITIAL.
            MOVE-CORRESPONDING t_out TO t_out18.
            t_out18-grtc  = gt_ekbe_gr-wrbtr.
            t_out18-grtcc = gt_ekbe_gr-waers.
            COLLECT t_out18.
            CLEAR: t_out18-grtc,t_out18-grtcc.
          ENDIF.

** Summary GR LC
*          IF gt_ekbe_gr-waers = t_t001-waers.
*            t_out-grlc = gt_ekbe_gr-dmbtr * 100.
*          ELSE.
**& Kalau beda currency maka baca table currency.
*            CLEAR: ld_gdatu,ld_ukurs.
*            PERFORM f_difference_currency USING    gt_ekbe_gr-waers t_t001-waers gt_ekbe_gr-budat
*                                          CHANGING ld_gdatu ld_date ld_ukurs.
*            CLEAR: ld_value.
*            ld_value = gt_ekbe_gr-wrbtr * ld_ukurs. "gt_ekbe_gr-dmbtr * ld_ukurs.
*            t_out-grlc = ld_value.
*          ENDIF.
          t_out-grlc = gt_ekbe_gr-dmbtr * 100.

          IF t_out-grlc IS NOT INITIAL.
            MOVE-CORRESPONDING t_out TO t_out19.
            t_out19-grlc = t_out-grlc.
            t_out19-grlcc = t_t001-waers.
            COLLECT t_out19.
            CLEAR: t_out19-grlc,t_out19-grlcc,t_out-grlc.
          ENDIF.

* Summary Invoice Qty
          IF gt_ekbe_gr-menge IS NOT INITIAL.
            MOVE-CORRESPONDING t_out TO t_out20.
            t_out20-grqty = gt_ekbe_gr-menge.
            t_out20-gruom = t_ekkn-meins.
            COLLECT t_out20.
            CLEAR: t_out20-grqty,t_out20-gruom.
          ENDIF.

* PPN& PPH
          LOOP AT gt_bseg WHERE belnr = gt_ekbe_gr-belnr.
            MOVE-CORRESPONDING t_out TO t_out21.
            CASE gt_bseg-hkont.
              WHEN '0142200220'.
                t_out21-ppn = gt_bseg-dmbtr.
              WHEN '0315100040'.
                t_out21-pph = gt_bseg-dmbtr.
              WHEN '0313600500'.
                t_out21-dpp = gt_bseg-dmbtr.
            ENDCASE.
            COLLECT t_out21.
            CLEAR: t_out21-ppn,t_out21-pph.
          ENDLOOP.
        ENDLOOP.

        LOOP AT gt_ekbe WHERE ebeln = t_ekkn-ebeln
                          AND ebelp = t_ekkn-ebelp.
          IF gt_ekbe-shkzg = 'H'.
            gt_ekbe-wrbtr = gt_ekbe-wrbtr * -1.
            gt_ekbe-dmbtr = gt_ekbe-dmbtr * -1.
            gt_ekbe-menge = gt_ekbe-menge * -1.
          ENDIF.
* Summary Invoice TC
          IF gt_ekbe-waers = 'IDR'.
            gt_ekbe-wrbtr = gt_ekbe-wrbtr * 100.
          ENDIF.
          IF gt_ekbe-wrbtr IS NOT INITIAL.
            MOVE-CORRESPONDING t_out TO t_out10.
            t_out10-invwrbtr = gt_ekbe-wrbtr.
            t_out10-invwaer2 = gt_ekbe-waers.
            COLLECT t_out10.
            CLEAR: t_out10-invwrbtr,t_out10-invwaer2.
          ENDIF.

** Summary Invoice LC
*          IF gt_ekbe-waers = t_t001-waers.
*            t_out-invdmbtr = gt_ekbe-dmbtr * 100.
*          ELSE.
**& Kalau beda currency maka baca table currency.
*            CLEAR: ld_gdatu,ld_ukurs.
*            PERFORM f_difference_currency USING    gt_ekbe-waers t_t001-waers gt_ekbe-budat
*                                          CHANGING ld_gdatu ld_date ld_ukurs.
*            CLEAR: ld_value.
*            ld_value = gt_ekbe-wrbtr * ld_ukurs. "gt_ekbe-dmbtr * ld_ukurs.
*            t_out-invdmbtr = ld_value.
*          ENDIF.
          t_out-invdmbtr = gt_ekbe-dmbtr * 100.

          IF t_out-invdmbtr IS NOT INITIAL.
            MOVE-CORRESPONDING t_out TO t_out11.
            t_out11-invdmbtr = t_out-invdmbtr.
            t_out11-invwaer1 = t_t001-waers.
            COLLECT t_out11.
            CLEAR: t_out11-invdmbtr,t_out11-invwaer1,t_out-invdmbtr.
          ENDIF.

* Summary Invoice Qty
          IF gt_ekbe-menge IS NOT INITIAL.
            MOVE-CORRESPONDING t_out TO t_out12.
            t_out12-invmenge = gt_ekbe-menge.
            t_out12-invmeins = t_ekkn-meins.
            COLLECT t_out12.
            CLEAR: t_out12-invmenge,t_out12-invmeins.
          ENDIF.

* PPN& PPH
          LOOP AT gt_bseg WHERE belnr = gt_ekbe-belnr.
            MOVE-CORRESPONDING t_out TO t_out21.
            CASE gt_bseg-hkont.
              WHEN '0142200220'.
                t_out21-ppn = gt_bseg-dmbtr.
              WHEN '0315100040'.
                t_out21-pph = gt_bseg-dmbtr.
              WHEN '0313600500'.
                t_out21-dpp = gt_bseg-dmbtr.
            ENDCASE.
            COLLECT t_out21.
            CLEAR: t_out21-ppn,t_out21-pph.
          ENDLOOP.

          IF NOT line_exists( t_out14[ ebeln = gt_ekbe-ebeln ] ).
            LOOP AT gt_bsak_nkz WHERE belnr = gt_ekbe-belnr.
              LOOP AT gt_bsak_kz WHERE lifnr = gt_bsak_nkz-lifnr
                                   AND augdt = gt_bsak_nkz-augdt
                                   AND augbl = gt_bsak_nkz-augbl.
                IF gt_bsak_kz-shkzg = 'H'.
                  gt_bsak_kz-wrbtr = gt_ekbe-wrbtr * -1.
                  gt_bsak_kz-dmbtr = gt_ekbe-dmbtr * -1.
                ENDIF.
* Summary Payment TC
                IF gt_bsak_kz-waers = 'IDR'.
                  gt_bsak_kz-wrbtr = gt_bsak_kz-wrbtr * 100.
                ENDIF.
                IF gt_bsak_kz-wrbtr IS NOT INITIAL.
                  MOVE-CORRESPONDING t_out TO t_out13.
                  t_out13-ebeln    = gt_ekbe-ebeln.
                  t_out13-paywrbtr = gt_bsak_kz-wrbtr.
                  t_out13-paywaer2 = gt_bsak_kz-waers.
                  COLLECT t_out13.
                  CLEAR: t_out13-paywrbtr,t_out13-paywaer2.
                ENDIF.

* Summary Payment LC
*              IF gt_bsak_kz-waers = t_t001-waers.
*                t_out-paydmbtr = gt_bsak_kz-dmbtr * 100.
*              ELSE.
**& Kalau beda currency maka baca table currency.
*                CLEAR: ld_gdatu,ld_ukurs.
*                PERFORM f_difference_currency USING    gt_bsak_kz-waers t_t001-waers gt_bsak_kz-budat
*                                              CHANGING ld_gdatu ld_date ld_ukurs.
*                CLEAR: ld_value.
*                ld_value = gt_bsak_kz-wrbtr * ld_ukurs.
*                t_out-paydmbtr = ld_value.
*              ENDIF.
                t_out-paydmbtr = gt_bsak_kz-dmbtr * 100.

                IF t_out-paydmbtr IS NOT INITIAL.
                  MOVE-CORRESPONDING t_out TO t_out14.
                  t_out14-ebeln    = gt_ekbe-ebeln.
                  t_out14-paydmbtr = t_out-paydmbtr.
                  t_out14-paywaer1 = t_t001-waers.
                  COLLECT t_out14.
                  CLEAR: t_out14-paydmbtr,t_out14-paywaer1,t_out-paydmbtr.
                ENDIF.
              ENDLOOP.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MOVE-CORRESPONDING t_out TO t_outkey.
    COLLECT t_outkey.
    CLEAR: t_out,t_out1,t_out2,t_out3,t_out4,t_out5,t_out6,
           t_out7,t_out8,t_out9,t_out10,t_out11,t_out12,
           t_out13,t_out14,t_outkey.
  ENDLOOP.

* Modify line number
  SORT t_out1 BY aufnr akstl kostv.
  SORT t_out2 BY aufnr akstl kostv.
  SORT t_out3 BY aufnr akstl kostv.
  SORT t_out4 BY aufnr akstl kostv.
  SORT t_out5 BY aufnr akstl kostv.
  SORT t_out6 BY aufnr akstl kostv.
  SORT t_out7 BY aufnr akstl kostv.
  SORT t_out8 BY aufnr akstl kostv.
  SORT t_out9 BY aufnr akstl kostv.
  SORT t_out10 BY aufnr akstl kostv.
  SORT t_out11 BY aufnr akstl kostv.
  SORT t_out12 BY aufnr akstl kostv.
  SORT t_out13 BY aufnr akstl kostv.
  SORT t_out14 BY aufnr akstl kostv.
  SORT t_out18 BY aufnr akstl kostv.
  SORT t_out19 BY aufnr akstl kostv.
  SORT t_out20 BY aufnr akstl kostv.
  SORT t_out2 BY aufnr akstl kostv.

  LOOP AT t_out1.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out1-line = ld_line.
    MODIFY t_out1 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out2.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out2-line = ld_line.
    MODIFY t_out2 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out3.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out3-line = ld_line.
    MODIFY t_out3 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out4.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out4-line = ld_line.
    MODIFY t_out4 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out5.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out5-line = ld_line.
    MODIFY t_out5 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out6.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out6-line = ld_line.
    MODIFY t_out6 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out7.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out7-line = ld_line.
    MODIFY t_out7 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out8.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out8-line = ld_line.
    MODIFY t_out8 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out9.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out9-line = ld_line.
    MODIFY t_out9 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out10.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out10-line = ld_line.
    MODIFY t_out10 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out11.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out11-line = ld_line.
    MODIFY t_out11 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out12.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out12-line = ld_line.
    MODIFY t_out12 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out13.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out13-line = ld_line.
    MODIFY t_out13 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out14.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out14-line = ld_line.
    MODIFY t_out14 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out18.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out18-line = ld_line.
    MODIFY t_out18 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out19.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out19-line = ld_line.
    MODIFY t_out19 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out20.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out20-line = ld_line.
    MODIFY t_out20 TRANSPORTING line.
  ENDLOOP.
  LOOP AT t_out21.
    AT NEW aufnr.
      CLEAR ld_line.
    ENDAT.
    AT NEW akstl.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_out21-line = ld_line.
    MODIFY t_out21 TRANSPORTING line.
  ENDLOOP.

* Summary by Row
  LOOP AT t_outkey.
    CLEAR: ld_cnt,ld_line.
*    WHILE ld_cnt LT 14.
    WHILE ld_cnt LT 18.
      ADD 1 TO ld_line.
      CLEAR: t_out1,t_out2,t_out3,t_out4,t_out5,t_out6,t_out7,
             t_out8,t_out9,t_out10,t_out11,t_out12,
             t_out13,t_out14,t_out18,t_out19,t_out20,t_out21,ld_cnt.

      READ TABLE t_out1 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-wtjhr = t_out1-wtjhr.
        t_out-twaer = t_out1-twaer.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out2 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-wljhr = t_out2-wljhr.
        t_out-waers = t_out2-waers.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out3 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-menge = t_out3-menge.
        t_out-meins = t_out3-meins.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out4 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-preis = t_out4-preis.
        t_out-rfatc = t_out4-rfatc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out5 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-rfalc = t_out5-rfalc.
        t_out-rfaloc = t_out5-rfaloc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out6 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-rfaqt = t_out6-rfaqt.
        t_out-rfaum = t_out6-rfaum.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out7 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-netwr = t_out7-netwr.
        t_out-acttc = t_out7-acttc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out8 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-actlc = t_out8-actlc.
        t_out-actloc = t_out8-actloc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out9 WITH KEY aufnr = t_outkey-aufnr
                                 akstl = t_outkey-akstl
                                 line  = ld_line.
      IF sy-subrc = 0.
        t_out-actqt = t_out9-actqt.
        t_out-actum = t_out9-actum.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out10 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-invwrbtr = t_out10-invwrbtr.
        t_out-invwaer2 = t_out10-invwaer2.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out11 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-invdmbtr = t_out11-invdmbtr.
        t_out-invwaer1 = t_out11-invwaer1.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out12 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-invmenge = t_out12-invmenge.
        t_out-invmeins = t_out12-invmeins.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out13 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-paywrbtr = t_out13-paywrbtr.
        t_out-paywaer2 = t_out13-paywaer2.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out14 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-paydmbtr = t_out14-paydmbtr.
        t_out-paywaer1 = t_out14-paywaer1.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out18 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-grtc = t_out18-grtc.
        t_out-grtcc = t_out18-grtcc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out19 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-grlc = t_out19-grlc.
        t_out-grlcc = t_out19-grlcc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out20 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-grqty = t_out20-grqty.
        t_out-gruom = t_out20-gruom.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_out21 WITH KEY aufnr = t_outkey-aufnr
                                  akstl = t_outkey-akstl
                                  line  = ld_line.
      IF sy-subrc = 0.
        t_out-ppn = t_out21-ppn * 100.
        t_out-pph = t_out21-pph * 100.
        t_out-dpp = t_out21-dpp * 100.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

*      IF ld_cnt LT 14.
      IF ld_cnt LT 18.
        t_out-aufnr = t_outkey-aufnr.
        t_out-ktext = t_outkey-ktext.
        t_out-akstl = t_outkey-akstl.
        t_out-kostv = t_outkey-kostv.
        t_out-aufex = t_outkey-aufex.
        t_out-proft = t_outkey-proft.
        t_out-kostl = t_outkey-kostl.
        t_out-kostx = t_outkey-kostx.
        APPEND t_out. CLEAR t_out.
      ENDIF.
    ENDWHILE.
  ENDLOOP.

* Modify itab out
  LOOP AT t_out.
    t_out-budrfatc = t_out-wtjhr - t_out-preis.
    t_out-budrfalc = t_out-wljhr - t_out-rfalc.
    t_out-budacttc = t_out-wtjhr - t_out-netwr.
    t_out-budactlc = t_out-wljhr - t_out-actlc.

    t_out-bi       = t_out-wljhr - t_out-invdmbtr.
    IF t_out-bi IS NOT INITIAL.
      t_out-waebi  = t_out-waers.
    ENDIF.
    t_out-bp       = t_out-wljhr - t_out-paydmbtr.
    IF t_out-bp IS NOT INITIAL.
      t_out-waebp  = t_out-waers.
    ENDIF.
    t_out-ip       = t_out-invdmbtr - t_out-paydmbtr.
    IF t_out-ip IS NOT INITIAL.
      t_out-waeip  = t_out-waers.
    ENDIF.

    CLEAR: t_aufk,t_anla,t_ebkn,t_ekkn,gt_ekbe,gt_rbkp,gt_lfa1,
           gt_bsak_nkz,gt_bsak_kz.

*    IF p_bukrs = '8330'.
    READ TABLE t_aufk WITH KEY aufnr = t_out-aufnr.
    READ TABLE t_anla WITH KEY eaufn = t_aufk-aufnr
                               bukrs = t_aufk-bukrs.
    READ TABLE t_ebkn WITH KEY anln1 = t_anla-anln1
                               anln2 = t_anla-anln2
                               gsber = t_aufk-gsber.
    READ TABLE t_ekkn WITH KEY anln1 = t_anla-anln1
                               anln2 = t_anla-anln2
                               gsber = t_aufk-gsber.
    READ TABLE gt_ekbe WITH KEY ebeln = t_ekkn-ebeln
                                ebelp = t_ekkn-ebelp.
    READ TABLE gt_ekbe_gr WITH KEY ebeln = t_ekkn-ebeln
                                   ebelp = t_ekkn-ebelp.
    READ TABLE gt_bsak_nkz WITH KEY belnr = gt_ekbe-belnr.
    READ TABLE gt_bsak_kz WITH KEY lifnr = gt_bsak_nkz-lifnr
                                   augdt = gt_bsak_nkz-augdt
                                   augbl = gt_bsak_nkz-augbl.
    READ TABLE gt_rbkp WITH KEY belnr = gt_ekbe-belnr.
    READ TABLE gt_lfa1 WITH KEY lifnr = gt_rbkp-lifnr.

    t_out-banfn      = t_ebkn-banfn.
    t_out-erdat      = t_ebkn-erdat.
    t_out-ebeln      = t_ekkn-ebeln.
    t_out-aedat      = t_ekkn-aedat.
    t_out-budat_ekbe = gt_ekbe-budat.
    t_out-belnr      = gt_ekbe-belnr.
    t_out-budat_rbkp = gt_rbkp-budat.
    t_out-belnr_bsak = gt_bsak_kz-belnr.
    t_out-budat_bsak = gt_bsak_kz-budat.
    t_out-name1      = gt_lfa1-name1.
    t_out-grno       = gt_ekbe_gr-belnr.
    t_out-grdat      = gt_ekbe_gr-budat.
    t_out-anln1      = t_anla-anln1.
    t_out-txt50      = t_anla-txt50.
*    ENDIF.

    MODIFY t_out TRANSPORTING budrfatc budrfalc budacttc budactlc
                              bi bp ip waebi waebp waeip
                              banfn erdat ebeln aedat budat_ekbe belnr
                              budat_rbkp belnr_bsak budat_bsak name1 grno
                              anln1 txt50.

    PERFORM f_append_itab_popup.
  ENDLOOP.

  IF p_setnm IS NOT INITIAL.
    LOOP AT t_sethier_co.
      APPEND INITIAL LINE TO t_hdr ASSIGNING <fs_hdr>.
      <fs_hdr>-setname    = t_sethier_co-setname.
      <fs_hdr>-subsetname = t_sethier_co-setname.
      <fs_hdr>-descript   = t_sethier_co-descript.

      LOOP AT t_setval_co FROM t_sethier_co-hierlevel TO t_sethier_co-valcount.
        READ TABLE t_out ASSIGNING <fs_out> WITH KEY aufnr = t_setval_co-valfrom.
        IF sy-subrc = 0.
          <fs_out>-subsetname = t_sethier_co-setname.
          <fs_out>-descript   = t_sethier_co-descript.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
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
*&      Form  F_COLLECT_ORDER_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_order_number .
  DATA: ld_groupname TYPE sethier_co-groupname.

  IF p_setnm IS INITIAL AND
     s_aufnr[] IS INITIAL.
    MESSAGE 'Group/Order Number required entries' TYPE 'I'.
    STOP.
  ENDIF.

  IF p_setnm IS NOT INITIAL.
    ld_groupname = p_setnm.
    CALL FUNCTION 'K_GROUP_REMOTE_READ'
      EXPORTING
        setclass   = c_setclass
        groupname  = ld_groupname
      TABLES
        et_sethier = t_sethier_co
        et_setval  = t_setval_co.

    IF t_sethier_co[] IS NOT INITIAL.
      LOOP AT t_sethier_co.
        t_sethier_co-setname = t_sethier_co-groupname.
        MODIFY t_sethier_co TRANSPORTING setname.
      ENDLOOP.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE t_setheadert
        FROM setheadert
        FOR ALL ENTRIES IN t_sethier_co
        WHERE setclass = t_sethier_co-setclass AND
              setname  = t_sethier_co-setname.
    ENDIF.

    LOOP AT t_setval_co.
      s_aufnr-sign   = 'I'.
      IF t_setval_co-valto = t_setval_co-valfrom.
        s_aufnr-option = 'EQ'.
      ELSE.
        s_aufnr-option = 'BT'.
      ENDIF.
      s_aufnr-low    = t_setval_co-valfrom.
      s_aufnr-high   = t_setval_co-valto.
      APPEND s_aufnr. CLEAR s_aufnr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_COLLECT_ORDER_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_ALV_KEYINFO  text
*----------------------------------------------------------------------*
FORM f_build_key  USING fd_alv_keyinfo TYPE slis_keyinfo_alv.
  fd_alv_keyinfo-header01 = 'SUBSETNAME'.
  fd_alv_keyinfo-item01   = 'SUBSETNAME'.
ENDFORM.                    " F_BUILD_KEY
*&---------------------------------------------------------------------*
*&      Form  F_LISTING_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_listing_report .
  DATA: ld_from        TYPE int4,
        ld_to          TYPE int4,
        ld_kolom       TYPE int4,
        ld_sisa        TYPE int4,
        ld_hierlevel   LIKE sethier_co-hierlevel,
        ld_groupname   LIKE sethier_co-groupname,
        ld_hierlevel1  LIKE sethier_co-hierlevel,
        ld_groupname1  LIKE sethier_co-groupname,
        ld_hierlevel2  LIKE sethier_co-hierlevel,
        ld_groupname2  LIKE sethier_co-groupname,
        ld_hierlevel3  LIKE sethier_co-hierlevel,
        ld_groupname3  LIKE sethier_co-groupname,
        ld_hierlevel4  LIKE sethier_co-hierlevel,
        ld_groupname4  LIKE sethier_co-groupname,
        ld_hierlevel5  LIKE sethier_co-hierlevel,
        ld_groupname5  LIKE sethier_co-groupname,
        ld_hierlevel6  LIKE sethier_co-hierlevel,
        ld_groupname6  LIKE sethier_co-groupname,
        ld_hierlevel7  LIKE sethier_co-hierlevel,
        ld_groupname7  LIKE sethier_co-groupname,
        ld_hierlevel8  LIKE sethier_co-hierlevel,
        ld_groupname8  LIKE sethier_co-groupname,
        ld_hierlevel9  LIKE sethier_co-hierlevel,
        ld_groupname9  LIKE sethier_co-groupname,
        ld_hierlevel10 LIKE sethier_co-hierlevel,
        ld_groupname10 LIKE sethier_co-groupname,
        ld_hierlevel11 LIKE sethier_co-hierlevel,
        ld_groupname11 LIKE sethier_co-groupname,
        ld_hierlevel12 LIKE sethier_co-hierlevel,
        ld_groupname12 LIKE sethier_co-groupname,
        ld_hierlevel13 LIKE sethier_co-hierlevel,
        ld_groupname13 LIKE sethier_co-groupname,
        ld_hierlevel14 LIKE sethier_co-hierlevel,
        ld_groupname14 LIKE sethier_co-groupname,
        ld_hierlevel15 LIKE sethier_co-hierlevel,
        ld_groupname15 LIKE sethier_co-groupname,
        ld_hierlevel16 LIKE sethier_co-hierlevel,
        ld_groupname16 LIKE sethier_co-groupname,
        ld_hierlevel17 LIKE sethier_co-hierlevel,
        ld_groupname17 LIKE sethier_co-groupname.

  LOOP AT t_sethier_co.
    va_tabix = sy-tabix.
    SET LEFT SCROLL-BOUNDARY COLUMN 61.

    IF ld_hierlevel IS INITIAL.
      ld_hierlevel = t_sethier_co-hierlevel.
      ld_groupname = t_sethier_co-groupname.
    ELSE.
* Write Subtotal Hierarchy
      IF t_sethier_co-hierlevel LE ld_hierlevel.
        PERFORM f_write_subtotal1 USING ld_hierlevel
                                        ld_groupname.
        PERFORM f_write_skip.
        WHILE t_sethier_co-hierlevel LT ld_hierlevel.
          SUBTRACT 1 FROM ld_hierlevel.
          CASE ld_hierlevel.
            WHEN 1.
              ld_hierlevel = ld_hierlevel1.
              ld_groupname = ld_groupname1.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 2.
              ld_hierlevel = ld_hierlevel2.
              ld_groupname = ld_groupname2.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 3.
              ld_hierlevel = ld_hierlevel3.
              ld_groupname = ld_groupname3.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 4.
              ld_hierlevel = ld_hierlevel4.
              ld_groupname = ld_groupname4.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 5.
              ld_hierlevel = ld_hierlevel5.
              ld_groupname = ld_groupname5.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 6.
              ld_hierlevel = ld_hierlevel6.
              ld_groupname = ld_groupname6.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 7.
              ld_hierlevel = ld_hierlevel7.
              ld_groupname = ld_groupname7.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 8.
              ld_hierlevel = ld_hierlevel8.
              ld_groupname = ld_groupname8.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 9.
              ld_hierlevel = ld_hierlevel9.
              ld_groupname = ld_groupname9.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 10.
              ld_hierlevel = ld_hierlevel10.
              ld_groupname = ld_groupname10.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 11.
              ld_hierlevel = ld_hierlevel11.
              ld_groupname = ld_groupname11.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 12.
              ld_hierlevel = ld_hierlevel12.
              ld_groupname = ld_groupname12.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 13.
              ld_hierlevel = ld_hierlevel13.
              ld_groupname = ld_groupname13.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 14.
              ld_hierlevel = ld_hierlevel14.
              ld_groupname = ld_groupname14.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 15.
              ld_hierlevel = ld_hierlevel15.
              ld_groupname = ld_groupname15.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 16.
              ld_hierlevel = ld_hierlevel16.
              ld_groupname = ld_groupname16.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN 17.
              ld_hierlevel = ld_hierlevel17.
              ld_groupname = ld_groupname17.
              PERFORM f_write_subtotal1 USING ld_hierlevel
                                              ld_groupname.
              PERFORM f_write_skip.
            WHEN OTHERS.
          ENDCASE.
        ENDWHILE.
      ELSE.
        PERFORM f_write_skip.
        CASE ld_hierlevel.
          WHEN 1.
            ld_hierlevel1 = ld_hierlevel.
            ld_groupname1 = ld_groupname.
          WHEN 2.
            ld_hierlevel2 = ld_hierlevel.
            ld_groupname2 = ld_groupname.
          WHEN 3.
            ld_hierlevel3 = ld_hierlevel.
            ld_groupname3 = ld_groupname.
          WHEN 4.
            ld_hierlevel4 = ld_hierlevel.
            ld_groupname4 = ld_groupname.
          WHEN 5.
            ld_hierlevel5 = ld_hierlevel.
            ld_groupname5 = ld_groupname.
          WHEN 6.
            ld_hierlevel6 = ld_hierlevel.
            ld_groupname6 = ld_groupname.
          WHEN 7.
            ld_hierlevel7 = ld_hierlevel.
            ld_groupname7 = ld_groupname.
          WHEN 8.
            ld_hierlevel8 = ld_hierlevel.
            ld_groupname8 = ld_groupname.
          WHEN 9.
            ld_hierlevel9 = ld_hierlevel.
            ld_groupname9 = ld_groupname.
          WHEN 10.
            ld_hierlevel10 = ld_hierlevel.
            ld_groupname10 = ld_groupname.
          WHEN 11.
            ld_hierlevel11 = ld_hierlevel.
            ld_groupname11 = ld_groupname.
          WHEN 12.
            ld_hierlevel12 = ld_hierlevel.
            ld_groupname12 = ld_groupname.
          WHEN 13.
            ld_hierlevel13 = ld_hierlevel.
            ld_groupname13 = ld_groupname.
          WHEN 14.
            ld_hierlevel14 = ld_hierlevel.
            ld_groupname14 = ld_groupname.
          WHEN 15.
            ld_hierlevel15 = ld_hierlevel.
            ld_groupname15 = ld_groupname.
          WHEN 16.
            ld_hierlevel16 = ld_hierlevel.
            ld_groupname16 = ld_groupname.
          WHEN 17.
            ld_hierlevel17 = ld_hierlevel.
            ld_groupname17 = ld_groupname.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
      ld_hierlevel = t_sethier_co-hierlevel.
      ld_groupname = t_sethier_co-groupname.
    ENDIF.

    ld_kolom = t_sethier_co-hierlevel * 3.
    ld_sisa = t_sethier_co-hierlevel MOD 2.
    IF ld_sisa = 0.
      FORMAT INTENSIFIED OFF.
    ELSE.
      FORMAT INTENSIFIED ON.
    ENDIF.

    FORMAT COLOR 7.
    PERFORM f_write_group USING ld_kolom
                                t_sethier_co-groupname
                                t_sethier_co-descript.
    FORMAT COLOR OFF. FORMAT INTENSIFIED OFF.
    IF t_sethier_co-hierlevel IS INITIAL.
      PERFORM f_write_skip.
    ENDIF.

    IF t_sethier_co-valcount IS NOT INITIAL.
      IF ld_from IS INITIAL.
        ld_from = 1.
      ENDIF.
      ld_to = ld_to + t_sethier_co-valcount.
      PERFORM f_write_order USING t_sethier_co-hierlevel
                                  t_sethier_co-groupname
                                  t_sethier_co-descript
                                  ld_kolom
                                  ld_from
                                  ld_to.
      ld_from = ld_to + 1.
    ENDIF.

    AT END OF hierlevel.
*      PERFORM f_write_subtotal1 USING t_sethier_co-hierlevel
*                                      t_sethier_co-groupname.
    ENDAT.
*    PERFORM f_write_skip.
  ENDLOOP.

  PERFORM f_write_subtotal1 USING ld_hierlevel
                                  ld_groupname.
  PERFORM f_write_skip.
  WRITE (624)sy-uline.
  PERFORM f_write_grandtotal.
  WRITE (624)sy-uline.
ENDFORM.                    " F_LISTING_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_GROUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_KOLOM  text
*      -->P_T_SETHIER_CO_GROUPNAME  text
*      -->P_T_SETHIER_CO_DESCRIPT  text
*----------------------------------------------------------------------*
FORM f_write_group  USING    fu_kolom
                             fu_groupname
                             fu_descript.
  DATA: ld_len  TYPE int4,
        ld_sisa TYPE int4.

  ld_len = fu_kolom + 15 + 40.
  IF ld_len GT 60.
    ld_sisa = 40 - ( ld_len - 60 ).
  ELSE.
    ld_sisa = 40.
  ENDIF.

  WRITE: / sy-vline.
  WRITE AT fu_kolom fu_groupname.
  WRITE: fu_descript(ld_sisa),
        60 sy-vline,
        82 sy-vline,
       115 sy-vline,
       148 sy-vline,
       169 sy-vline,
       190 sy-vline,
       205 sy-vline,
       226 sy-vline,
       247 sy-vline,
       262 sy-vline,
       283 sy-vline,
       304 sy-vline,
       319 sy-vline,
       340 sy-vline,
       361 sy-vline,
       376 sy-vline,
       397 sy-vline,
       418 sy-vline,
       439 sy-vline,
       460 sy-vline,
       475 sy-vline,
       496 sy-vline,
       517 sy-vline,
       538 sy-vline,
       559 sy-vline,
       580 sy-vline,
       601 sy-vline,
       623 sy-vline.
ENDFORM.                    " F_WRITE_GROUP

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_HIERLEVEL  text
*      -->FU_GROUPNAME  text
*      -->FU_KOLOM      text
*      -->FU_FROM       text
*      -->FU_TO         text
*----------------------------------------------------------------------*
FORM f_write_order  USING    fu_hierlevel
                             fu_groupname
                             fu_descript
                             fu_kolom
                             fu_from
                             fu_to.

  fu_kolom = fu_kolom + 3.
  LOOP AT  t_setval_co FROM fu_from TO fu_to.
    CLEAR: t_out.
    READ TABLE t_out WITH KEY aufnr = t_setval_co-valfrom.
    WRITE: / sy-vline.
    WRITE AT fu_kolom t_out-aufnr.
    WRITE:            t_out-ktext.
*                      t_out-gjahr.
    WRITE: 60 sy-vline NO-GAP,
              t_out-aufex, sy-vline NO-GAP,
              t_out-akstl,
              t_out-proft, sy-vline NO-GAP,
              t_out-kostl,
              t_out-kostx, sy-vline NO-GAP,
          (16)t_out-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-twaer NO-GAP, sy-vline NO-GAP,
          (16)t_out-wljhr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (10)t_out-menge DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-meins NO-GAP, sy-vline NO-GAP,
          (16)t_out-preis DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-rfatc NO-GAP, sy-vline NO-GAP,
          (16)t_out-rfalc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-rfaloc NO-GAP, sy-vline NO-GAP,
          (10)t_out-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-rfaum NO-GAP, sy-vline NO-GAP,
          (16)t_out-netwr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-acttc NO-GAP, sy-vline NO-GAP,
          (16)t_out-actlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-actloc NO-GAP, sy-vline NO-GAP,
          (10)t_out-actqt DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-actum NO-GAP, sy-vline NO-GAP,
          (16)t_out-grtc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-grtcc NO-GAP, sy-vline NO-GAP,
          (16)t_out-grlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-grlcc NO-GAP, sy-vline NO-GAP,
          (10)t_out-grqty DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-gruom NO-GAP, sy-vline NO-GAP,
          (16)t_out-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-budactlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-invwaer2 NO-GAP, sy-vline NO-GAP,
          (16)t_out-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-invwaer1 NO-GAP, sy-vline NO-GAP,
          (10)t_out-invmenge DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-invmeins NO-GAP, sy-vline NO-GAP,
          (16)t_out-ppn DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-pph DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-paywaer2 NO-GAP, sy-vline NO-GAP,
          (16)t_out-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-paywaer1 NO-GAP, sy-vline NO-GAP,
          (16)t_out-bi DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-bp DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (17)t_out-ip DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP.

    PERFORM f_append_itab_download USING fu_groupname
                                         fu_descript.
  ENDLOOP.
ENDFORM.                    " F_WRITE_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SKIP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_skip .
  WRITE: / sy-vline,
        60 sy-vline,
        82 sy-vline,
       115 sy-vline,
       148 sy-vline,
       169 sy-vline,
       190 sy-vline,
       205 sy-vline,
       226 sy-vline,
       247 sy-vline,
       262 sy-vline,
       283 sy-vline,
       304 sy-vline,
       319 sy-vline,
       340 sy-vline,
       361 sy-vline,
       376 sy-vline,
       397 sy-vline,
       418 sy-vline,
       439 sy-vline,
       460 sy-vline,
       475 sy-vline,
       496 sy-vline,
       517 sy-vline,
       538 sy-vline,
       559 sy-vline,
       580 sy-vline,
       601 sy-vline,
       623 sy-vline.
ENDFORM.                    " F_WRITE_SKIP

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sub_header .
*  IF p_bukrs = '8330'.
*    PERFORM f_sub_header_02.
*  ELSE.
  PERFORM f_sub_header_01.
*  ENDIF.
ENDFORM.                    " F_SUB_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_SUBTOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_subtotal .
  IF t_out-wtjhr IS NOT INITIAL.
    t_subtotal1-hierlevel = t_sethier_co-hierlevel.
    t_subtotal1-subsetname = t_sethier_co-groupname.
    t_subtotal1-wtjhr = t_out-wtjhr.
    t_subtotal1-twaer = t_out-twaer.
    COLLECT t_subtotal1. CLEAR t_subtotal1.
    t_grandtotal1-subsetname = p_setnm.
    t_grandtotal1-wtjhr = t_out-wtjhr.
    t_grandtotal1-twaer = t_out-twaer.
    COLLECT t_grandtotal1. CLEAR t_grandtotal1.
  ENDIF.
  IF t_out-wljhr IS NOT INITIAL.
    t_subtotal2-hierlevel = t_sethier_co-hierlevel.
    t_subtotal2-subsetname = t_sethier_co-groupname.
    t_subtotal2-wljhr = t_out-wljhr.
    t_subtotal2-waers = t_out-waers.
    COLLECT t_subtotal2. CLEAR t_subtotal2.
    t_grandtotal2-subsetname = p_setnm.
    t_grandtotal2-wljhr = t_out-wljhr.
    t_grandtotal2-waers = t_out-waers.
    COLLECT t_grandtotal2. CLEAR t_grandtotal2.
  ENDIF.
  IF t_out-preis IS NOT INITIAL.
    t_subtotal3-hierlevel = t_sethier_co-hierlevel.
    t_subtotal3-subsetname = t_sethier_co-groupname.
    t_subtotal3-preis = t_out-preis.
    t_subtotal3-rfatc = t_out-rfatc.
    COLLECT t_subtotal3. CLEAR t_subtotal3.
    t_grandtotal3-subsetname = p_setnm.
    t_grandtotal3-preis = t_out-preis.
    t_grandtotal3-rfatc = t_out-rfatc.
    COLLECT t_grandtotal3. CLEAR t_grandtotal3.
  ENDIF.
  IF t_out-rfalc IS NOT INITIAL.
    t_subtotal4-hierlevel = t_sethier_co-hierlevel.
    t_subtotal4-subsetname = t_sethier_co-groupname.
    t_subtotal4-rfalc = t_out-rfalc.
    t_subtotal4-rfaloc = t_out-waers.
    COLLECT t_subtotal4. CLEAR t_subtotal4.
    t_grandtotal4-subsetname = p_setnm.
    t_grandtotal4-rfalc = t_out-rfalc.
    t_grandtotal4-rfaloc = t_out-waers.
    COLLECT t_grandtotal4. CLEAR t_grandtotal4.
  ENDIF.
  IF t_out-netwr IS NOT INITIAL.
    t_subtotal5-hierlevel = t_sethier_co-hierlevel.
    t_subtotal5-subsetname = t_sethier_co-groupname.
    t_subtotal5-netwr = t_out-netwr.
    t_subtotal5-acttc = t_out-acttc.
    COLLECT t_subtotal5. CLEAR t_subtotal5.
    t_grandtotal5-subsetname = p_setnm.
    t_grandtotal5-netwr = t_out-netwr.
    t_grandtotal5-acttc = t_out-acttc.
    COLLECT t_grandtotal5. CLEAR t_grandtotal5.
  ENDIF.
  IF t_out-actlc IS NOT INITIAL.
    t_subtotal6-hierlevel = t_sethier_co-hierlevel.
    t_subtotal6-subsetname = t_sethier_co-groupname.
    t_subtotal6-actlc = t_out-actlc.
    t_subtotal6-actloc = t_out-actloc.
    COLLECT t_subtotal6. CLEAR t_subtotal6.
    t_grandtotal6-subsetname = p_setnm.
    t_grandtotal6-actlc = t_out-actlc.
    t_grandtotal6-actloc = t_out-actloc.
    COLLECT t_grandtotal6. CLEAR t_grandtotal6.
  ENDIF.
  IF t_out-budrfatc IS NOT INITIAL.
    t_subtotal7-hierlevel = t_sethier_co-hierlevel.
    t_subtotal7-subsetname = t_sethier_co-groupname.
    t_subtotal7-budrfatc = t_out-budrfatc.
    t_subtotal7-rfatc = t_out-rfatc.
    COLLECT t_subtotal7. CLEAR t_subtotal7.
    t_grandtotal7-subsetname = p_setnm.
    t_grandtotal7-budrfatc = t_out-budrfatc.
    t_grandtotal7-rfatc = t_out-rfatc.
    COLLECT t_grandtotal7. CLEAR t_grandtotal7.
  ENDIF.
  IF t_out-budrfalc IS NOT INITIAL.
    t_subtotal8-hierlevel = t_sethier_co-hierlevel.
    t_subtotal8-subsetname = t_sethier_co-groupname.
    t_subtotal8-budrfalc = t_out-budrfalc.
    t_subtotal8-rfaloc = t_out-waers.
    COLLECT t_subtotal8. CLEAR t_subtotal8.
    t_grandtotal8-subsetname = p_setnm.
    t_grandtotal8-budrfalc = t_out-budrfalc.
    t_grandtotal8-rfaloc = t_out-waers.
    COLLECT t_grandtotal8. CLEAR t_grandtotal8.
  ENDIF.
  IF t_out-budacttc IS NOT INITIAL.
    t_subtotal9-hierlevel = t_sethier_co-hierlevel.
    t_subtotal9-subsetname = t_sethier_co-groupname.
    t_subtotal9-budacttc = t_out-budacttc.
    t_subtotal9-acttc = t_out-acttc.
    COLLECT t_subtotal9. CLEAR t_subtotal9.
    t_grandtotal9-subsetname = p_setnm.
    t_grandtotal9-budacttc = t_out-budacttc.
    t_grandtotal9-acttc = t_out-acttc.
    COLLECT t_grandtotal9. CLEAR t_grandtotal9.
  ENDIF.
  IF t_out-budactlc IS NOT INITIAL.
    t_subtotal10-hierlevel = t_sethier_co-hierlevel.
    t_subtotal10-subsetname = t_sethier_co-groupname.
    t_subtotal10-budactlc = t_out-budactlc.
    t_subtotal10-actloc = t_out-waers.
    COLLECT t_subtotal10. CLEAR t_subtotal10.
    t_grandtotal10-subsetname = p_setnm.
    t_grandtotal10-budactlc = t_out-budactlc.
    t_grandtotal10-actloc = t_out-waers.
    COLLECT t_grandtotal10. CLEAR t_grandtotal10.
  ENDIF.
  IF t_out-invwrbtr IS NOT INITIAL.
    t_subtotal11-hierlevel = t_sethier_co-hierlevel.
    t_subtotal11-subsetname = t_sethier_co-groupname.
    t_subtotal11-invwrbtr = t_out-invwrbtr.
    t_subtotal11-invwaer2 = t_out-invwaer2.
    COLLECT t_subtotal11. CLEAR t_subtotal11.
    t_grandtotal11-subsetname = p_setnm.
    t_grandtotal11-invwrbtr = t_out-invwrbtr.
    t_grandtotal11-invwaer2 = t_out-invwaer2.
    COLLECT t_grandtotal11. CLEAR t_grandtotal11.
  ENDIF.
  IF t_out-invdmbtr IS NOT INITIAL.
    t_subtotal12-hierlevel = t_sethier_co-hierlevel.
    t_subtotal12-subsetname = t_sethier_co-groupname.
    t_subtotal12-invdmbtr = t_out-invdmbtr.
    t_subtotal12-invwaer1 = t_out-invwaer1.
    COLLECT t_subtotal12. CLEAR t_subtotal12.
    t_grandtotal12-subsetname = p_setnm.
    t_grandtotal12-invdmbtr = t_out-invdmbtr.
    t_grandtotal12-invwaer1 = t_out-invwaer1.
    COLLECT t_grandtotal12. CLEAR t_grandtotal12.
  ENDIF.
  IF t_out-paywrbtr IS NOT INITIAL.
    t_subtotal13-hierlevel = t_sethier_co-hierlevel.
    t_subtotal13-subsetname = t_sethier_co-groupname.
    t_subtotal13-paywrbtr = t_out-paywrbtr.
    t_subtotal13-paywaer2 = t_out-paywaer2.
    COLLECT t_subtotal13. CLEAR t_subtotal13.
    t_grandtotal13-subsetname = p_setnm.
    t_grandtotal13-paywrbtr = t_out-paywrbtr.
    t_grandtotal13-paywaer2 = t_out-paywaer2.
    COLLECT t_grandtotal13. CLEAR t_grandtotal13.
  ENDIF.
  IF t_out-paydmbtr IS NOT INITIAL.
    t_subtotal14-hierlevel = t_sethier_co-hierlevel.
    t_subtotal14-subsetname = t_sethier_co-groupname.
    t_subtotal14-paydmbtr = t_out-paydmbtr.
    t_subtotal14-paywaer1 = t_out-paywaer1.
    COLLECT t_subtotal14. CLEAR t_subtotal14.
    t_grandtotal14-subsetname = p_setnm.
    t_grandtotal14-paydmbtr = t_out-paydmbtr.
    t_grandtotal14-paywaer1 = t_out-paywaer1.
    COLLECT t_grandtotal14. CLEAR t_grandtotal14.
  ENDIF.
  IF t_out-bi IS NOT INITIAL.
    t_subtotal15-hierlevel = t_sethier_co-hierlevel.
    t_subtotal15-subsetname = t_sethier_co-groupname.
    t_subtotal15-bi    = t_out-bi.
    t_subtotal15-waebi = t_out-waers.
    COLLECT t_subtotal15. CLEAR t_subtotal15.
    t_grandtotal15-subsetname = p_setnm.
    t_grandtotal15-bi    = t_out-bi.
    t_grandtotal15-waebi = t_out-waers.
    COLLECT t_grandtotal15. CLEAR t_grandtotal15.
  ENDIF.
  IF t_out-bp IS NOT INITIAL.
    t_subtotal16-hierlevel = t_sethier_co-hierlevel.
    t_subtotal16-subsetname = t_sethier_co-groupname.
    t_subtotal16-bp    = t_out-bp.
    t_subtotal16-waebp = t_out-waers.
    COLLECT t_subtotal16. CLEAR t_subtotal16.
    t_grandtotal16-subsetname = p_setnm.
    t_grandtotal16-bp    = t_out-bp.
    t_grandtotal16-waebp = t_out-waers.
    COLLECT t_grandtotal16. CLEAR t_grandtotal16.
  ENDIF.
  IF t_out-ip IS NOT INITIAL.
    t_subtotal17-hierlevel = t_sethier_co-hierlevel.
    t_subtotal17-subsetname = t_sethier_co-groupname.
    t_subtotal17-ip    = t_out-ip.
    t_subtotal17-waeip = t_out-waers.
    COLLECT t_subtotal17. CLEAR t_subtotal17.
    t_grandtotal17-subsetname = p_setnm.
    t_grandtotal17-ip    = t_out-ip.
    t_grandtotal17-waeip = t_out-waers.
    COLLECT t_grandtotal17. CLEAR t_grandtotal17.
  ENDIF.
  IF t_out-grtc IS NOT INITIAL.
    t_subtotal18-hierlevel  = t_sethier_co-hierlevel.
    t_subtotal18-subsetname = t_sethier_co-groupname.
    t_subtotal18-grtc       = t_out-grtc.
    t_subtotal18-grtcc      = t_out-grtcc.
    COLLECT t_subtotal18. CLEAR t_subtotal18.
    t_grandtotal18-subsetname = p_setnm.
    t_grandtotal18-grtc     = t_out-grtc.
    t_grandtotal18-grtcc    = t_out-grtcc.
    COLLECT t_grandtotal18. CLEAR t_grandtotal8.
  ENDIF.
  IF t_out-grlc IS NOT INITIAL.
    t_subtotal19-hierlevel  = t_sethier_co-hierlevel.
    t_subtotal19-subsetname = t_sethier_co-groupname.
    t_subtotal19-grlc       = t_out-grlc.
    t_subtotal19-grlcc      = t_out-grlcc.
    COLLECT t_subtotal19. CLEAR t_subtotal19.
    t_grandtotal19-subsetname = p_setnm.
    t_grandtotal19-grlc     = t_out-grlc.
    t_grandtotal19-grlcc    = t_out-grlcc.
    COLLECT t_grandtotal19. CLEAR t_grandtotal9.
  ENDIF.
ENDFORM.                    " F_COLLECT_SUBTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SUBTOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_subtotal .
  DATA: ld_cnt1     TYPE int4,
        ld_cnt      TYPE int4,
        ld_cnt2     TYPE int4,
        lw_subtotal LIKE t_subtotal.

  DESCRIBE TABLE t_subtotal1 LINES ld_cnt.
  DESCRIBE TABLE t_subtotal2 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal3 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal4 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.

  DO ld_cnt TIMES.
    ADD 1 TO ld_cnt2.
    t_subtotal-subsetname = t_sethier_co-setname.

    CLEAR: t_subtotal1,t_subtotal2,t_subtotal3,t_subtotal4,
           t_subtotal5,t_subtotal6,t_subtotal7,t_subtotal8,
           t_subtotal9,t_subtotal10,t_subtotal11,t_subtotal12,
           t_subtotal13,t_subtotal14,t_subtotal15,t_subtotal16,
           t_subtotal17,t_subtotal18,t_subtotal19,t_subtotal20.
    READ TABLE t_subtotal1 INDEX ld_cnt2.
    READ TABLE t_subtotal2 INDEX ld_cnt2.
    READ TABLE t_subtotal3 INDEX ld_cnt2.
    READ TABLE t_subtotal4 INDEX ld_cnt2.
    READ TABLE t_subtotal5 INDEX ld_cnt2.
    READ TABLE t_subtotal6 INDEX ld_cnt2.
    READ TABLE t_subtotal7 INDEX ld_cnt2.
    READ TABLE t_subtotal8 INDEX ld_cnt2.
    READ TABLE t_subtotal9 INDEX ld_cnt2.
    READ TABLE t_subtotal10 INDEX ld_cnt2.
    READ TABLE t_subtotal11 INDEX ld_cnt2.
    READ TABLE t_subtotal12 INDEX ld_cnt2.
    READ TABLE t_subtotal13 INDEX ld_cnt2.
    READ TABLE t_subtotal14 INDEX ld_cnt2.
    READ TABLE t_subtotal15 INDEX ld_cnt2.
    READ TABLE t_subtotal16 INDEX ld_cnt2.
    READ TABLE t_subtotal17 INDEX ld_cnt2.
    READ TABLE t_subtotal18 INDEX ld_cnt2.
    READ TABLE t_subtotal19 INDEX ld_cnt2.
    READ TABLE t_subtotal20 INDEX ld_cnt2.

    t_subtotal-subsetname = t_subtotal1-subsetname.
    t_subtotal-wtjhr = t_subtotal1-wtjhr.
    t_subtotal-twaer = t_subtotal1-twaer.
    t_subtotal-wljhr = t_subtotal2-wljhr.
    t_subtotal-waers = t_subtotal2-waers.
    t_subtotal-preis = t_subtotal3-preis.
    t_subtotal-rfatc = t_subtotal3-rfatc.
    t_subtotal-rfalc = t_subtotal4-rfalc.
    t_subtotal-rfaloc = t_subtotal4-rfaloc.
    t_subtotal-netwr = t_subtotal5-netwr.
    t_subtotal-acttc = t_subtotal5-acttc.
    t_subtotal-actlc = t_subtotal6-actlc.
    t_subtotal-actloc = t_subtotal6-actloc.
    t_subtotal-budrfatc = t_subtotal7-budrfatc.
    t_subtotal-budrfalc = t_subtotal8-budrfalc.
    t_subtotal-budacttc = t_subtotal9-budacttc.
    t_subtotal-budactlc = t_subtotal10-budactlc.
    t_subtotal-invwaer2 = t_subtotal11-invwaer2.
    t_subtotal-invwrbtr = t_subtotal11-invwrbtr.
    t_subtotal-invwaer1 = t_subtotal12-invwaer1.
    t_subtotal-invdmbtr = t_subtotal12-invdmbtr.
    t_subtotal-paywaer2 = t_subtotal13-paywaer2.
    t_subtotal-paywrbtr = t_subtotal13-paywrbtr.
    t_subtotal-paywaer1 = t_subtotal14-paywaer1.
    t_subtotal-paydmbtr = t_subtotal14-paydmbtr.
    t_subtotal-waebi    = t_subtotal15-waebi.
    t_subtotal-bi       = t_subtotal15-bi.
    t_subtotal-waebp    = t_subtotal16-waebp.
    t_subtotal-bp       = t_subtotal16-bp.
    t_subtotal-waeip    = t_subtotal17-waeip.
    t_subtotal-ip       = t_subtotal17-ip.
    t_subtotal-grtc     = t_subtotal18-grtc.
    t_subtotal-grtcc    = t_subtotal18-grtcc.
    t_subtotal-grlc     = t_subtotal19-grlc.
    t_subtotal-grlcc    = t_subtotal19-grlcc.

    APPEND t_subtotal. CLEAR t_subtotal.
  ENDDO.

  FORMAT COLOR 3 INTENSIFIED OFF.
  LOOP AT t_subtotal.
    WRITE: / sy-vline.
    WRITE: 20 'SUB  TOTAL',
              t_subtotal-subsetname.
    WRITE: 60 sy-vline NO-GAP,
           82 sy-vline NO-GAP,
          115 sy-vline NO-GAP,
          148 sy-vline NO-GAP,
              (16)t_subtotal-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-twaer NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-wljhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-menge DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-meins NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-preis DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-rfatc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-rfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-rfaloc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-rfaum NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-netwr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-acttc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-actlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-actloc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-actqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-actum NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-grtc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-grtcc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-grlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-grlcc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-grqty DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-gruom NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-budactlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invwaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invwaer1 NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-invmenge DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invmeins NO-GAP, sy-vline NO-GAP,
              (16)t_out-ppn DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_out-waers NO-GAP, sy-vline NO-GAP,
              (16)t_out-pph DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_out-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-paywaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-paywaer1 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-bi DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waebi NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-bp DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waebp NO-GAP, sy-vline NO-GAP,
              (17)t_subtotal-ip DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waeip NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  FORMAT COLOR OFF. FORMAT INTENSIFIED OFF.
ENDFORM.                    " F_WRITE_SUBTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_GRANDTOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_grandtotal .
  DATA: ld_cnt1     TYPE int4,
        ld_cnt      TYPE int4,
        ld_cnt2     TYPE int4,
        lw_subtotal LIKE t_subtotal.

  DESCRIBE TABLE t_grandtotal1 LINES ld_cnt.
  DESCRIBE TABLE t_grandtotal2 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal3 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal4 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.

  DO ld_cnt TIMES.
    ADD 1 TO ld_cnt2.
    t_grandtotal-subsetname = t_sethier_co-setname.

    CLEAR: t_grandtotal1,t_grandtotal2,t_grandtotal3,t_grandtotal4,
           t_grandtotal5,t_grandtotal6,t_grandtotal7,t_grandtotal8,
           t_grandtotal9,t_grandtotal10,t_grandtotal11,t_grandtotal12,
           t_grandtotal13,t_grandtotal14,t_grandtotal15,t_grandtotal16,
           t_grandtotal17.
    READ TABLE t_grandtotal1 INDEX ld_cnt2.
    READ TABLE t_grandtotal2 INDEX ld_cnt2.
    READ TABLE t_grandtotal3 INDEX ld_cnt2.
    READ TABLE t_grandtotal4 INDEX ld_cnt2.
    READ TABLE t_grandtotal5 INDEX ld_cnt2.
    READ TABLE t_grandtotal6 INDEX ld_cnt2.
    READ TABLE t_grandtotal7 INDEX ld_cnt2.
    READ TABLE t_grandtotal8 INDEX ld_cnt2.
    READ TABLE t_grandtotal9 INDEX ld_cnt2.
    READ TABLE t_grandtotal10 INDEX ld_cnt2.
    READ TABLE t_grandtotal11 INDEX ld_cnt2.
    READ TABLE t_grandtotal12 INDEX ld_cnt2.
    READ TABLE t_grandtotal13 INDEX ld_cnt2.
    READ TABLE t_grandtotal14 INDEX ld_cnt2.
    READ TABLE t_grandtotal15 INDEX ld_cnt2.
    READ TABLE t_grandtotal16 INDEX ld_cnt2.
    READ TABLE t_grandtotal17 INDEX ld_cnt2.
    READ TABLE t_grandtotal18 INDEX ld_cnt2.
    READ TABLE t_grandtotal19 INDEX ld_cnt2.
    READ TABLE t_grandtotal20 INDEX ld_cnt2.

    t_grandtotal-subsetname = t_grandtotal1-subsetname.
    t_grandtotal-wtjhr = t_grandtotal1-wtjhr.
    t_grandtotal-twaer = t_grandtotal1-twaer.
    t_grandtotal-wljhr = t_grandtotal2-wljhr.
    t_grandtotal-waers = t_grandtotal2-waers.
    t_grandtotal-preis = t_grandtotal3-preis.
    t_grandtotal-rfatc = t_grandtotal3-rfatc.
    t_grandtotal-rfalc = t_grandtotal4-rfalc.
    t_grandtotal-rfaloc = t_grandtotal4-rfaloc.
    t_grandtotal-netwr = t_grandtotal5-netwr.
    t_grandtotal-acttc = t_grandtotal5-acttc.
    t_grandtotal-actlc = t_grandtotal6-actlc.
    t_grandtotal-actloc = t_grandtotal6-actloc.
    t_grandtotal-budrfatc = t_grandtotal7-budrfatc.
    t_grandtotal-budrfalc = t_grandtotal8-budrfalc.
    t_grandtotal-budacttc = t_grandtotal9-budacttc.
    t_grandtotal-budactlc = t_grandtotal10-budactlc.
    t_grandtotal-invwaer2 = t_grandtotal11-invwaer2.
    t_grandtotal-invwrbtr = t_grandtotal11-invwrbtr.
    t_grandtotal-invwaer1 = t_grandtotal12-invwaer1.
    t_grandtotal-invdmbtr = t_grandtotal12-invdmbtr.
    t_grandtotal-paywaer2 = t_grandtotal13-paywaer2.
    t_grandtotal-paywrbtr = t_grandtotal13-paywrbtr.
    t_grandtotal-paywaer1 = t_grandtotal14-paywaer1.
    t_grandtotal-paydmbtr = t_grandtotal14-paydmbtr.
    t_grandtotal-waebi    = t_grandtotal15-waebi.
    t_grandtotal-bi       = t_grandtotal15-bi.
    t_grandtotal-waebp    = t_grandtotal16-waebp.
    t_grandtotal-bp       = t_grandtotal16-bp.
    t_grandtotal-waeip    = t_grandtotal17-waeip.
    t_grandtotal-ip       = t_grandtotal17-ip.
    t_grandtotal-grtc     = t_grandtotal18-grtc.
    t_grandtotal-grtcc    = t_grandtotal18-grtcc.
    t_grandtotal-grlc     = t_grandtotal19-grlc.
    t_grandtotal-grlcc    = t_grandtotal19-grlcc.

    APPEND t_grandtotal. CLEAR t_grandtotal.
  ENDDO.

  FORMAT COLOR 3 INTENSIFIED ON.
  LOOP AT t_grandtotal.
    WRITE: / sy-vline.
    WRITE AT 20 'G R A N D  T O T A L'.
    WRITE: 60 sy-vline NO-GAP,
           82 sy-vline NO-GAP,
          115 sy-vline NO-GAP,
          148 sy-vline NO-GAP,
              (16)t_grandtotal-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-twaer NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-wljhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waers NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-menge DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_grandtotal-meins NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-preis DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-rfatc NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-rfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-rfaloc NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_grandtotal-rfaum NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-netwr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-acttc NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-actlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-actloc NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-actqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_grandtotal-actum NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-grtc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-grtcc NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-grlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-grlcc NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-grqty DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_grandtotal-gruom NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-budactlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-invwaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-invwaer1 NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-invmenge DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-invmeins NO-GAP, sy-vline NO-GAP,
              (16)t_out-ppn DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_out-waers NO-GAP, sy-vline NO-GAP,
              (16)t_out-pph DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_out-waers NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-paywaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-paywaer1 NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-bi DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waebi NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-bp DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waebp NO-GAP, sy-vline NO-GAP,
              (17)t_grandtotal-ip DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waeip NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  FORMAT COLOR OFF. FORMAT INTENSIFIED OFF.
ENDFORM.                    " F_WRITE_GRANDTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SUBTOTAL_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_subtotal_02 .
  DATA: ld_cnt1     TYPE int4,
        ld_cnt      TYPE int4,
        ld_cnt2     TYPE int4,
        lw_subtotal LIKE t_subtotal.

  DESCRIBE TABLE t_subtotal1 LINES ld_cnt.
  DESCRIBE TABLE t_subtotal2 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal3 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal4 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_subtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.

  DO ld_cnt TIMES.
    ADD 1 TO ld_cnt2.
    t_subtotal-subsetname = t_sethier_co-setname.

    CLEAR: t_subtotal1,t_subtotal2,t_subtotal3,t_subtotal4,
           t_subtotal5,t_subtotal6,t_subtotal7,t_subtotal8,
           t_subtotal9,t_subtotal10,t_subtotal11,t_subtotal12,
           t_subtotal13,t_subtotal14,t_subtotal15,t_subtotal16,
           t_subtotal17.
    READ TABLE t_subtotal1 INDEX ld_cnt2.
    READ TABLE t_subtotal2 INDEX ld_cnt2.
    READ TABLE t_subtotal3 INDEX ld_cnt2.
    READ TABLE t_subtotal4 INDEX ld_cnt2.
    READ TABLE t_subtotal5 INDEX ld_cnt2.
    READ TABLE t_subtotal6 INDEX ld_cnt2.
    READ TABLE t_subtotal7 INDEX ld_cnt2.
    READ TABLE t_subtotal8 INDEX ld_cnt2.
    READ TABLE t_subtotal9 INDEX ld_cnt2.
    READ TABLE t_subtotal10 INDEX ld_cnt2.
    READ TABLE t_subtotal11 INDEX ld_cnt2.
    READ TABLE t_subtotal12 INDEX ld_cnt2.
    READ TABLE t_subtotal13 INDEX ld_cnt2.
    READ TABLE t_subtotal14 INDEX ld_cnt2.
    READ TABLE t_subtotal15 INDEX ld_cnt2.
    READ TABLE t_subtotal16 INDEX ld_cnt2.
    READ TABLE t_subtotal17 INDEX ld_cnt2.

    t_subtotal-subsetname = t_subtotal1-subsetname.
    t_subtotal-wtjhr = t_subtotal1-wtjhr.
    t_subtotal-twaer = t_subtotal1-twaer.
    t_subtotal-wljhr = t_subtotal2-wljhr.
    t_subtotal-waers = t_subtotal2-waers.
    t_subtotal-preis = t_subtotal3-preis.
    t_subtotal-rfatc = t_subtotal3-rfatc.
    t_subtotal-rfalc = t_subtotal4-rfalc.
    t_subtotal-rfaloc = t_subtotal4-rfaloc.
    t_subtotal-netwr = t_subtotal5-netwr.
    t_subtotal-acttc = t_subtotal5-acttc.
    t_subtotal-actlc = t_subtotal6-actlc.
    t_subtotal-actloc = t_subtotal6-actloc.
    t_subtotal-budrfatc = t_subtotal7-budrfatc.
    t_subtotal-budrfalc = t_subtotal8-budrfalc.
    t_subtotal-budacttc = t_subtotal9-budacttc.
    t_subtotal-budactlc = t_subtotal10-budactlc.
    t_subtotal-invwaer2 = t_subtotal11-invwaer2.
    t_subtotal-invwrbtr = t_subtotal11-invwrbtr.
    t_subtotal-invwaer1 = t_subtotal12-invwaer1.
    t_subtotal-invdmbtr = t_subtotal12-invdmbtr.
    t_subtotal-paywaer2 = t_subtotal13-paywaer2.
    t_subtotal-paywrbtr = t_subtotal13-paywrbtr.
    t_subtotal-paywaer1 = t_subtotal14-paywaer1.
    t_subtotal-paydmbtr = t_subtotal14-paydmbtr.
    t_subtotal-waebi    = t_subtotal15-waebi.
    t_subtotal-bi       = t_subtotal15-bi.
    t_subtotal-waebp    = t_subtotal16-waebp.
    t_subtotal-bp       = t_subtotal16-bp.
    t_subtotal-waeip    = t_subtotal17-waeip.
    t_subtotal-ip       = t_subtotal17-ip.

    APPEND t_subtotal. CLEAR t_subtotal.
  ENDDO.

  FORMAT COLOR 3 INTENSIFIED OFF.
  LOOP AT t_subtotal.
    WRITE: / sy-vline.
    WRITE: 20 'SUB  TOTAL',
              t_subtotal-subsetname.
    WRITE: 60 sy-vline NO-GAP,
           93 sy-vline NO-GAP,
          126 sy-vline NO-GAP,
              (16)t_subtotal-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-twaer NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-wljhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-menge DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-meins NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-preis DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-rfatc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-rfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-rfaloc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-rfaum NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-netwr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-acttc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-actlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-actloc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-actqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-actum NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-budactlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invwaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invwaer1 NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-invmenge DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invmeins NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (35)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-paywaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-paywaer1 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-bi DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waebi NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-bp DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waebp NO-GAP, sy-vline NO-GAP,
              (17)t_subtotal-ip DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waeip NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  FORMAT COLOR OFF. FORMAT INTENSIFIED OFF.
ENDFORM.                    " F_WRITE_SUBTOTAL_02

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_GRANDTOTAL_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_grandtotal_02 .
  DATA: ld_cnt1     TYPE int4,
        ld_cnt      TYPE int4,
        ld_cnt2     TYPE int4,
        lw_subtotal LIKE t_subtotal.

  DESCRIBE TABLE t_grandtotal1 LINES ld_cnt.
  DESCRIBE TABLE t_grandtotal2 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal3 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal4 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.
  DESCRIBE TABLE t_grandtotal5 LINES ld_cnt1.
  IF ld_cnt1 GT ld_cnt.
    ld_cnt = ld_cnt1.
  ENDIF.

  DO ld_cnt TIMES.
    ADD 1 TO ld_cnt2.
    t_grandtotal-subsetname = t_sethier_co-setname.

    CLEAR: t_grandtotal1,t_grandtotal2,t_grandtotal3,t_grandtotal4,
           t_grandtotal5,t_grandtotal6,t_grandtotal7,t_grandtotal8,
           t_grandtotal9,t_grandtotal10,t_grandtotal11,t_grandtotal12,
           t_grandtotal13,t_grandtotal14,t_grandtotal15,t_grandtotal16,
           t_grandtotal17.
    READ TABLE t_grandtotal1 INDEX ld_cnt2.
    READ TABLE t_grandtotal2 INDEX ld_cnt2.
    READ TABLE t_grandtotal3 INDEX ld_cnt2.
    READ TABLE t_grandtotal4 INDEX ld_cnt2.
    READ TABLE t_grandtotal5 INDEX ld_cnt2.
    READ TABLE t_grandtotal6 INDEX ld_cnt2.
    READ TABLE t_grandtotal7 INDEX ld_cnt2.
    READ TABLE t_grandtotal8 INDEX ld_cnt2.
    READ TABLE t_grandtotal9 INDEX ld_cnt2.
    READ TABLE t_grandtotal10 INDEX ld_cnt2.
    READ TABLE t_grandtotal11 INDEX ld_cnt2.
    READ TABLE t_grandtotal12 INDEX ld_cnt2.
    READ TABLE t_grandtotal13 INDEX ld_cnt2.
    READ TABLE t_grandtotal14 INDEX ld_cnt2.
    READ TABLE t_grandtotal15 INDEX ld_cnt2.
    READ TABLE t_grandtotal16 INDEX ld_cnt2.
    READ TABLE t_grandtotal17 INDEX ld_cnt2.

    t_grandtotal-subsetname = t_grandtotal1-subsetname.
    t_grandtotal-wtjhr = t_grandtotal1-wtjhr.
    t_grandtotal-twaer = t_grandtotal1-twaer.
    t_grandtotal-wljhr = t_grandtotal2-wljhr.
    t_grandtotal-waers = t_grandtotal2-waers.
    t_grandtotal-preis = t_grandtotal3-preis.
    t_grandtotal-rfatc = t_grandtotal3-rfatc.
    t_grandtotal-rfalc = t_grandtotal4-rfalc.
    t_grandtotal-rfaloc = t_grandtotal4-rfaloc.
    t_grandtotal-netwr = t_grandtotal5-netwr.
    t_grandtotal-acttc = t_grandtotal5-acttc.
    t_grandtotal-actlc = t_grandtotal6-actlc.
    t_grandtotal-actloc = t_grandtotal6-actloc.
    t_grandtotal-budrfatc = t_grandtotal7-budrfatc.
    t_grandtotal-budrfalc = t_grandtotal8-budrfalc.
    t_grandtotal-budacttc = t_grandtotal9-budacttc.
    t_grandtotal-budactlc = t_grandtotal10-budactlc.
    t_grandtotal-invwaer2 = t_grandtotal11-invwaer2.
    t_grandtotal-invwrbtr = t_grandtotal11-invwrbtr.
    t_grandtotal-invwaer1 = t_grandtotal12-invwaer1.
    t_grandtotal-invdmbtr = t_grandtotal12-invdmbtr.
    t_grandtotal-paywaer2 = t_grandtotal13-paywaer2.
    t_grandtotal-paywrbtr = t_grandtotal13-paywrbtr.
    t_grandtotal-paywaer1 = t_grandtotal14-paywaer1.
    t_grandtotal-paydmbtr = t_grandtotal14-paydmbtr.
    t_grandtotal-waebi    = t_grandtotal15-waebi.
    t_grandtotal-bi       = t_grandtotal15-bi.
    t_grandtotal-waebp    = t_grandtotal16-waebp.
    t_grandtotal-bp       = t_grandtotal16-bp.
    t_grandtotal-waeip    = t_grandtotal17-waeip.
    t_grandtotal-ip       = t_grandtotal17-ip.

    APPEND t_grandtotal. CLEAR t_grandtotal.
  ENDDO.

  FORMAT COLOR 3 INTENSIFIED ON.
  LOOP AT t_grandtotal.
    WRITE: / sy-vline.
    WRITE AT 20 'G R A N D  T O T A L'.
    WRITE: 60 sy-vline NO-GAP,
           93 sy-vline NO-GAP,
          126 sy-vline NO-GAP,
              (16)t_grandtotal-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-twaer NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-wljhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waers NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-menge DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_grandtotal-meins NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-preis DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-rfatc NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-rfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-rfaloc NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_grandtotal-rfaum NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-netwr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-acttc NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-actlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-actloc NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-actqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_grandtotal-actum NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-budactlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waers NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-invwaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-invwaer1 NO-GAP, sy-vline NO-GAP,
              (10)t_grandtotal-invmenge DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-invmeins NO-GAP, sy-vline NO-GAP,
              (10)' ' NO-GAP, sy-vline NO-GAP,
              (35)' ' NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-paywaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-paywaer1 NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-bi DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waebi NO-GAP, sy-vline NO-GAP,
              (16)t_grandtotal-bp DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waebp NO-GAP, sy-vline NO-GAP,
              (17)t_grandtotal-ip DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_grandtotal-waeip NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  FORMAT COLOR OFF. FORMAT INTENSIFIED OFF.
ENDFORM.                    " F_WRITE_GRANDTOTAL_02

*&---------------------------------------------------------------------*
*&      Form  F_FREE_SUBTOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_subtotal .
  REFRESH: t_subtotal,t_subtotal1,t_subtotal2,t_subtotal3,t_subtotal4,
           t_subtotal5,t_subtotal6,t_subtotal7,t_subtotal8,t_subtotal9,
           t_subtotal10,t_subtotal11,t_subtotal12,t_subtotal13,t_subtotal14,
           t_subtotal18,t_subtotal19,t_subtotal20.
  CLEAR: t_subtotal,t_subtotal1,t_subtotal2,t_subtotal3,t_subtotal4,
         t_subtotal5,t_subtotal6,t_subtotal7,t_subtotal8,t_subtotal9,
         t_subtotal10,t_subtotal11,t_subtotal12,t_subtotal13,t_subtotal14,
         t_subtotal18,t_subtotal19,t_subtotal20.
ENDFORM.                    " F_FREE_SUBTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_LISTING_REPORT_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_listing_report_order .
*  IF p_bukrs = '8330'.
*    PERFORM f_listing_report_order_02.
*  ELSE.
  PERFORM f_listing_report_order_01.
*  ENDIF.
ENDFORM.                    " F_LISTING_REPORT_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_summary_total .
  DATA: ld_from        TYPE int4,
        ld_to          TYPE int4,
        ld_cnt         TYPE int4,
        ld_line        TYPE int4,
        ld_hierlevel   LIKE t_sethier_co-hierlevel,
        ld_groupname   LIKE t_sethier_co-groupname,
        ld_hierlevel1  LIKE t_sethier_co-hierlevel,
        ld_groupname1  LIKE t_sethier_co-groupname,
        ld_hierlevel2  LIKE t_sethier_co-hierlevel,
        ld_groupname2  LIKE t_sethier_co-groupname,
        ld_hierlevel3  LIKE t_sethier_co-hierlevel,
        ld_groupname3  LIKE t_sethier_co-groupname,
        ld_hierlevel4  LIKE t_sethier_co-hierlevel,
        ld_groupname4  LIKE t_sethier_co-groupname,
        ld_hierlevel5  LIKE t_sethier_co-hierlevel,
        ld_groupname5  LIKE t_sethier_co-groupname,
        ld_hierlevel6  LIKE t_sethier_co-hierlevel,
        ld_groupname6  LIKE t_sethier_co-groupname,
        ld_hierlevel7  LIKE t_sethier_co-hierlevel,
        ld_groupname7  LIKE t_sethier_co-groupname,
        ld_hierlevel8  LIKE t_sethier_co-hierlevel,
        ld_groupname8  LIKE t_sethier_co-groupname,
        ld_hierlevel9  LIKE t_sethier_co-hierlevel,
        ld_groupname9  LIKE t_sethier_co-groupname,
        ld_hierlevel10 LIKE t_sethier_co-hierlevel,
        ld_groupname10 LIKE t_sethier_co-groupname,
        ld_hierlevel11 LIKE t_sethier_co-hierlevel,
        ld_groupname11 LIKE t_sethier_co-groupname,
        ld_hierlevel12 LIKE t_sethier_co-hierlevel,
        ld_groupname12 LIKE t_sethier_co-groupname,
        ld_hierlevel13 LIKE t_sethier_co-hierlevel,
        ld_groupname13 LIKE t_sethier_co-groupname,
        ld_hierlevel14 LIKE t_sethier_co-hierlevel,
        ld_groupname14 LIKE t_sethier_co-groupname,
        ld_hierlevel15 LIKE t_sethier_co-hierlevel,
        ld_groupname15 LIKE t_sethier_co-groupname,
        ld_hierlevel16 LIKE t_sethier_co-hierlevel,
        ld_groupname16 LIKE t_sethier_co-groupname,
        ld_hierlevel17 LIKE t_sethier_co-hierlevel,
        ld_groupname17 LIKE t_sethier_co-groupname,
        lt_subtotal    LIKE t_subtotal OCCURS 0 WITH HEADER LINE.

*& Summary by Coloum
  LOOP AT t_sethier_co.
    va_tabix = sy-tabix.

    CASE t_sethier_co-hierlevel.
      WHEN 1.
        ld_hierlevel1 = t_sethier_co-hierlevel.
        ld_groupname1 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel2,ld_groupname2,ld_hierlevel3,ld_groupname3,
               ld_hierlevel4,ld_groupname4,ld_hierlevel5,ld_groupname5,
               ld_hierlevel6,ld_groupname6,ld_hierlevel7,ld_groupname7,
               ld_hierlevel8,ld_groupname8,ld_hierlevel9,ld_groupname9,
               ld_hierlevel10,ld_groupname10,ld_hierlevel11,ld_groupname11,
               ld_hierlevel12,ld_groupname12,ld_hierlevel13,ld_groupname13,
               ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 2.
        ld_hierlevel2 = t_sethier_co-hierlevel.
        ld_groupname2 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel3,ld_groupname3,ld_hierlevel4,ld_groupname4,
               ld_hierlevel5,ld_groupname5,ld_hierlevel6,ld_groupname6,
               ld_hierlevel7,ld_groupname7,ld_hierlevel8,ld_groupname8,
               ld_hierlevel9,ld_groupname9,ld_hierlevel10,ld_groupname10,
               ld_hierlevel11,ld_groupname11,ld_hierlevel12,ld_groupname12,
               ld_hierlevel13,ld_groupname13,ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 3.
        ld_hierlevel3 = t_sethier_co-hierlevel.
        ld_groupname3 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel4,ld_groupname4,ld_hierlevel5,ld_groupname5,
               ld_hierlevel6,ld_groupname6,ld_hierlevel7,ld_groupname7,
               ld_hierlevel8,ld_groupname8,ld_hierlevel9,ld_groupname9,
               ld_hierlevel10,ld_groupname10,ld_hierlevel11,ld_groupname11,
               ld_hierlevel12,ld_groupname12,ld_hierlevel13,ld_groupname13,
               ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 4.
        ld_hierlevel4 = t_sethier_co-hierlevel.
        ld_groupname4 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel5,ld_groupname5,ld_hierlevel6,ld_groupname6,
               ld_hierlevel7,ld_groupname7,ld_hierlevel8,ld_groupname8,
               ld_hierlevel9,ld_groupname9,ld_hierlevel10,ld_groupname10,
               ld_hierlevel11,ld_groupname11,ld_hierlevel12,ld_groupname12,
               ld_hierlevel13,ld_groupname13,ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 5.
        ld_hierlevel5 = t_sethier_co-hierlevel.
        ld_groupname5 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel6,ld_groupname6,ld_hierlevel7,ld_groupname7,
               ld_hierlevel8,ld_groupname8,ld_hierlevel9,ld_groupname9,
               ld_hierlevel10,ld_groupname10,ld_hierlevel11,ld_groupname11,
               ld_hierlevel12,ld_groupname12,ld_hierlevel13,ld_groupname13,
               ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 6.
        ld_hierlevel6 = t_sethier_co-hierlevel.
        ld_groupname6 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel7,ld_groupname7,ld_hierlevel8,ld_groupname8,
               ld_hierlevel9,ld_groupname9,ld_hierlevel10,ld_groupname10,
               ld_hierlevel11,ld_groupname11,ld_hierlevel12,ld_groupname12,
               ld_hierlevel13,ld_groupname13,ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 7.
        ld_hierlevel7 = t_sethier_co-hierlevel.
        ld_groupname7 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel8,ld_groupname8,ld_hierlevel9,ld_groupname9,
               ld_hierlevel10,ld_groupname10,ld_hierlevel11,ld_groupname11,
               ld_hierlevel12,ld_groupname12,ld_hierlevel13,ld_groupname13,
               ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 8.
        ld_hierlevel8 = t_sethier_co-hierlevel.
        ld_groupname8 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel9,ld_groupname9,ld_hierlevel10,ld_groupname10,
               ld_hierlevel11,ld_groupname11,ld_hierlevel12,ld_groupname12,
               ld_hierlevel13,ld_groupname13,ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 9.
        ld_hierlevel9 = t_sethier_co-hierlevel.
        ld_groupname9 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel10,ld_groupname10,ld_hierlevel11,ld_groupname11,
               ld_hierlevel12,ld_groupname12,ld_hierlevel13,ld_groupname13,
               ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 10.
        ld_hierlevel10 = t_sethier_co-hierlevel.
        ld_groupname10 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel11,ld_groupname11,ld_hierlevel12,ld_groupname12,
               ld_hierlevel13,ld_groupname13,ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 11.
        ld_hierlevel11 = t_sethier_co-hierlevel.
        ld_groupname11 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel12,ld_groupname12,ld_hierlevel13,ld_groupname13,
               ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 12.
        ld_hierlevel12 = t_sethier_co-hierlevel.
        ld_groupname12 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel13,ld_groupname13,ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 13.
        ld_hierlevel13 = t_sethier_co-hierlevel.
        ld_groupname13 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel14,ld_groupname14,
               ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 14.
        ld_hierlevel14 = t_sethier_co-hierlevel.
        ld_groupname14 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel15,ld_groupname15,ld_hierlevel16,ld_groupname16,
               ld_hierlevel17,ld_groupname17.
      WHEN 15.
        ld_hierlevel15 = t_sethier_co-hierlevel.
        ld_groupname15 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel16,ld_groupname16,ld_hierlevel17,ld_groupname17.
      WHEN 16.
        ld_hierlevel16 = t_sethier_co-hierlevel.
        ld_groupname16 = t_sethier_co-groupname.
        CLEAR: ld_hierlevel17,ld_groupname17.
      WHEN 17.
        ld_hierlevel17 = t_sethier_co-hierlevel.
        ld_groupname17 = t_sethier_co-groupname.
      WHEN OTHERS.
    ENDCASE.

    IF t_sethier_co-valcount IS NOT INITIAL.
      IF ld_from IS INITIAL.
        ld_from = 1.
      ENDIF.
      ld_to = ld_to + t_sethier_co-valcount.

      LOOP AT  t_setval_co FROM ld_from TO ld_to.

        CLEAR: t_out.
        READ TABLE t_out WITH KEY aufnr = t_setval_co-valfrom.

        CASE t_sethier_co-hierlevel.
          WHEN 1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_grandtotal.

          WHEN 2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_grandtotal.

          WHEN 3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_grandtotal.

          WHEN 4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_grandtotal.

          WHEN 5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_grandtotal.

          WHEN 6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_grandtotal.

          WHEN 7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_grandtotal.

          WHEN 8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_grandtotal.

          WHEN 9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_grandtotal.

          WHEN 10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_grandtotal.

          WHEN 11.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel11
                                              ld_groupname11.
            PERFORM f_collect_grandtotal.

          WHEN 12.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel11
                                              ld_groupname11.
            PERFORM f_collect_subtotal1 USING ld_hierlevel12
                                              ld_groupname12.
            PERFORM f_collect_grandtotal.

          WHEN 13.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel11
                                              ld_groupname11.
            PERFORM f_collect_subtotal1 USING ld_hierlevel12
                                              ld_groupname12.
            PERFORM f_collect_subtotal1 USING ld_hierlevel13
                                              ld_groupname13.
            PERFORM f_collect_grandtotal.

          WHEN 14.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel11
                                              ld_groupname11.
            PERFORM f_collect_subtotal1 USING ld_hierlevel12
                                              ld_groupname12.
            PERFORM f_collect_subtotal1 USING ld_hierlevel13
                                              ld_groupname13.
            PERFORM f_collect_subtotal1 USING ld_hierlevel14
                                              ld_groupname14.
            PERFORM f_collect_grandtotal.

          WHEN 15.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel11
                                              ld_groupname11.
            PERFORM f_collect_subtotal1 USING ld_hierlevel12
                                              ld_groupname12.
            PERFORM f_collect_subtotal1 USING ld_hierlevel13
                                              ld_groupname13.
            PERFORM f_collect_subtotal1 USING ld_hierlevel14
                                              ld_groupname14.
            PERFORM f_collect_subtotal1 USING ld_hierlevel15
                                              ld_groupname15.
            PERFORM f_collect_grandtotal.

          WHEN 16.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel11
                                              ld_groupname11.
            PERFORM f_collect_subtotal1 USING ld_hierlevel12
                                              ld_groupname12.
            PERFORM f_collect_subtotal1 USING ld_hierlevel13
                                              ld_groupname13.
            PERFORM f_collect_subtotal1 USING ld_hierlevel14
                                              ld_groupname14.
            PERFORM f_collect_subtotal1 USING ld_hierlevel15
                                              ld_groupname15.
            PERFORM f_collect_subtotal1 USING ld_hierlevel16
                                              ld_groupname16.
            PERFORM f_collect_grandtotal.

          WHEN 17.
            PERFORM f_collect_subtotal1 USING ld_hierlevel1
                                              ld_groupname1.
            PERFORM f_collect_subtotal1 USING ld_hierlevel2
                                              ld_groupname2.
            PERFORM f_collect_subtotal1 USING ld_hierlevel3
                                              ld_groupname3.
            PERFORM f_collect_subtotal1 USING ld_hierlevel4
                                              ld_groupname4.
            PERFORM f_collect_subtotal1 USING ld_hierlevel5
                                              ld_groupname5.
            PERFORM f_collect_subtotal1 USING ld_hierlevel6
                                              ld_groupname6.
            PERFORM f_collect_subtotal1 USING ld_hierlevel7
                                              ld_groupname7.
            PERFORM f_collect_subtotal1 USING ld_hierlevel8
                                              ld_groupname8.
            PERFORM f_collect_subtotal1 USING ld_hierlevel9
                                              ld_groupname9.
            PERFORM f_collect_subtotal1 USING ld_hierlevel10
                                              ld_groupname10.
            PERFORM f_collect_subtotal1 USING ld_hierlevel11
                                              ld_groupname11.
            PERFORM f_collect_subtotal1 USING ld_hierlevel12
                                              ld_groupname12.
            PERFORM f_collect_subtotal1 USING ld_hierlevel13
                                              ld_groupname13.
            PERFORM f_collect_subtotal1 USING ld_hierlevel14
                                              ld_groupname14.
            PERFORM f_collect_subtotal1 USING ld_hierlevel15
                                              ld_groupname15.
            PERFORM f_collect_subtotal1 USING ld_hierlevel16
                                              ld_groupname16.
            PERFORM f_collect_subtotal1 USING ld_hierlevel17
                                              ld_groupname17.
            PERFORM f_collect_grandtotal.

          WHEN OTHERS.

        ENDCASE.
      ENDLOOP.
      ld_from = ld_to + 1.
    ENDIF.
  ENDLOOP.

*& Modify Line Number.
  LOOP AT  t_subtotal1.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal1-line = ld_line.
    MODIFY t_subtotal1 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal2.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal2-line = ld_line.
    MODIFY t_subtotal2 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal3.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal3-line = ld_line.
    MODIFY t_subtotal3 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal4.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal4-line = ld_line.
    MODIFY t_subtotal4 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal5.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal5-line = ld_line.
    MODIFY t_subtotal5 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal6.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal6-line = ld_line.
    MODIFY t_subtotal6 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal7.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal7-line = ld_line.
    MODIFY t_subtotal7 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal8.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal8-line = ld_line.
    MODIFY t_subtotal8 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal9.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal9-line = ld_line.
    MODIFY t_subtotal9 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal10.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal10-line = ld_line.
    MODIFY t_subtotal10 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal11.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal11-line = ld_line.
    MODIFY t_subtotal11 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal12.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal12-line = ld_line.
    MODIFY t_subtotal12 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal13.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal13-line = ld_line.
    MODIFY t_subtotal13 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal14.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal14-line = ld_line.
    MODIFY t_subtotal14 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal15.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal15-line = ld_line.
    MODIFY t_subtotal15 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal16.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal16-line = ld_line.
    MODIFY t_subtotal16 TRANSPORTING line.
  ENDLOOP.
  LOOP AT  t_subtotal17.
    AT NEW subsetname.
      CLEAR ld_line.
    ENDAT.
    ADD 1 TO ld_line.
    t_subtotal17-line = ld_line.
    MODIFY t_subtotal17 TRANSPORTING line.
  ENDLOOP.

*& Summary by Row
  LOOP AT t_subtotalkey.
    CLEAR: ld_cnt,ld_line.
    WHILE ld_cnt LT 12.
      ADD 1 TO ld_line.
      CLEAR: t_subtotal1,t_subtotal2,t_subtotal3,t_subtotal4,
             t_subtotal5,t_subtotal6,t_subtotal7,t_subtotal8,
             t_subtotal9,t_subtotal10,t_subtotal11,t_subtotal12,
             t_subtotal13,t_subtotal14,t_subtotal15,
             t_subtotal16,t_subtotal17,ld_cnt.

      READ TABLE t_subtotal1 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-wtjhr = t_subtotal1-wtjhr.
        t_subtotal-twaer = t_subtotal1-twaer.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal2 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-wljhr = t_subtotal2-wljhr.
        t_subtotal-waers = t_subtotal2-waers.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal3 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-preis = t_subtotal3-preis.
        t_subtotal-rfatc = t_subtotal3-rfatc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal4 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-rfalc = t_subtotal4-rfalc.
        t_subtotal-rfaloc = t_subtotal4-rfaloc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal5 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-netwr = t_subtotal5-netwr.
        t_subtotal-acttc = t_subtotal5-acttc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal6 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-actlc = t_subtotal6-actlc.
        t_subtotal-actloc = t_subtotal6-actloc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal7 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-budrfatc = t_subtotal7-budrfatc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal8 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-budrfalc = t_subtotal8-budrfalc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal9 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                      subsetname = t_subtotalkey-subsetname
                                      line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-budacttc = t_subtotal9-budacttc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal10 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-budactlc = t_subtotal10-budactlc.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal11 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-invwrbtr = t_subtotal11-invwrbtr.
        t_subtotal-invwaer2 = t_subtotal11-invwaer2.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal12 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-invdmbtr = t_subtotal12-invdmbtr.
        t_subtotal-invwaer1 = t_subtotal12-invwaer1.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal13 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-paywrbtr = t_subtotal13-paywrbtr.
        t_subtotal-paywaer2 = t_subtotal13-paywaer2.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal14 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-paydmbtr = t_subtotal14-paydmbtr.
        t_subtotal-paywaer1 = t_subtotal14-paywaer1.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal15 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-bi    = t_subtotal15-bi.
        t_subtotal-waebi = t_subtotal15-waebi.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal16 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-bp    = t_subtotal16-bp.
        t_subtotal-waebp = t_subtotal16-waebp.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      READ TABLE t_subtotal17 WITH KEY hierlevel = t_subtotalkey-hierlevel
                                       subsetname = t_subtotalkey-subsetname
                                       line = ld_line.
      IF sy-subrc = 0.
        t_subtotal-ip    = t_subtotal17-ip.
        t_subtotal-waeip = t_subtotal17-waeip.
      ELSE.
        ADD 1 TO ld_cnt.
      ENDIF.

      IF ld_cnt LT 17.
        t_subtotal-hierlevel = t_subtotalkey-hierlevel.
        t_subtotal-subsetname = t_subtotalkey-subsetname.
        t_subtotal-line = ld_line.
        APPEND t_subtotal. CLEAR t_subtotal.
      ENDIF.
    ENDWHILE.
  ENDLOOP.
ENDFORM.                    " F_SUMMARY_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_SUBTOTAL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_HIERLEVEL  text
*      -->FU_GROUPNAME  text
*----------------------------------------------------------------------*
FORM f_collect_subtotal1  USING fu_hierlevel
                                fu_groupname.
  t_subtotalkey-hierlevel = fu_hierlevel.
  t_subtotalkey-subsetname = fu_groupname.
  COLLECT t_subtotalkey. CLEAR t_subtotalkey.

  IF t_out-wtjhr IS NOT INITIAL.
    t_subtotal1-hierlevel = fu_hierlevel.
    t_subtotal1-subsetname = fu_groupname.
    t_subtotal1-wtjhr = t_out-wtjhr.
    t_subtotal1-twaer = t_out-twaer.
    COLLECT t_subtotal1. CLEAR t_subtotal1.
  ENDIF.
  IF t_out-wljhr IS NOT INITIAL.
    t_subtotal2-hierlevel = fu_hierlevel.
    t_subtotal2-subsetname = fu_groupname.
    t_subtotal2-wljhr = t_out-wljhr.
    t_subtotal2-waers = t_out-waers.
    COLLECT t_subtotal2. CLEAR t_subtotal2.
  ENDIF.
  IF t_out-preis IS NOT INITIAL.
    t_subtotal3-hierlevel = fu_hierlevel.
    t_subtotal3-subsetname = fu_groupname.
    t_subtotal3-preis = t_out-preis.
    t_subtotal3-rfatc = t_out-rfatc.
    COLLECT t_subtotal3. CLEAR t_subtotal3.
  ENDIF.
  IF t_out-rfalc IS NOT INITIAL.
    t_subtotal4-hierlevel = fu_hierlevel.
    t_subtotal4-subsetname = fu_groupname.
    t_subtotal4-rfalc = t_out-rfalc.
    t_subtotal4-rfaloc = t_out-waers.
    COLLECT t_subtotal4. CLEAR t_subtotal4.
  ENDIF.
  IF t_out-netwr IS NOT INITIAL.
    t_subtotal5-hierlevel = fu_hierlevel.
    t_subtotal5-subsetname = fu_groupname.
    t_subtotal5-netwr = t_out-netwr.
    t_subtotal5-acttc = t_out-acttc.
    COLLECT t_subtotal5. CLEAR t_subtotal5.
  ENDIF.
  IF t_out-actlc IS NOT INITIAL.
    t_subtotal6-hierlevel = fu_hierlevel.
    t_subtotal6-subsetname = fu_groupname.
    t_subtotal6-actlc = t_out-actlc.
    t_subtotal6-actloc = t_out-actloc.
    COLLECT t_subtotal6. CLEAR t_subtotal6.
  ENDIF.
  IF t_out-budrfatc IS NOT INITIAL.
    t_subtotal7-hierlevel = fu_hierlevel.
    t_subtotal7-subsetname = fu_groupname.
    t_subtotal7-budrfatc = t_out-budrfatc.
    t_subtotal7-rfatc = t_out-twaer.
    COLLECT t_subtotal7. CLEAR t_subtotal7.
  ENDIF.
  IF t_out-budrfalc IS NOT INITIAL.
    t_subtotal8-hierlevel = fu_hierlevel.
    t_subtotal8-subsetname = fu_groupname.
    t_subtotal8-budrfalc = t_out-budrfalc.
    t_subtotal8-rfaloc = t_out-waers.
    COLLECT t_subtotal8. CLEAR t_subtotal8.
  ENDIF.
  IF t_out-budacttc IS NOT INITIAL.
    t_subtotal9-hierlevel = fu_hierlevel.
    t_subtotal9-subsetname = fu_groupname.
    t_subtotal9-budacttc = t_out-budacttc.
    t_subtotal9-acttc = t_out-twaer.
    COLLECT t_subtotal9. CLEAR t_subtotal9.
  ENDIF.
  IF t_out-budactlc IS NOT INITIAL.
    t_subtotal10-hierlevel = fu_hierlevel.
    t_subtotal10-subsetname = fu_groupname.
    t_subtotal10-budactlc = t_out-budactlc.
    t_subtotal10-actloc = t_out-waers.
    COLLECT t_subtotal10. CLEAR t_subtotal10.
  ENDIF.
  IF t_out-invwrbtr IS NOT INITIAL.
    t_subtotal11-hierlevel = fu_hierlevel.
    t_subtotal11-subsetname = fu_groupname.
    t_subtotal11-invwrbtr = t_out-invwrbtr.
    t_subtotal11-invwaer2 = t_out-invwaer2.
    COLLECT t_subtotal11. CLEAR t_subtotal11.
  ENDIF.
  IF t_out-invdmbtr IS NOT INITIAL.
    t_subtotal12-hierlevel = fu_hierlevel.
    t_subtotal12-subsetname = fu_groupname.
    t_subtotal12-invdmbtr = t_out-invdmbtr.
    t_subtotal12-invwaer1 = t_out-invwaer1.
    COLLECT t_subtotal12. CLEAR t_subtotal12.
  ENDIF.
  IF t_out-paywrbtr IS NOT INITIAL.
    t_subtotal13-hierlevel = fu_hierlevel.
    t_subtotal13-subsetname = fu_groupname.
    t_subtotal13-paywrbtr = t_out-paywrbtr.
    t_subtotal13-paywaer2 = t_out-paywaer2.
    COLLECT t_subtotal13. CLEAR t_subtotal13.
  ENDIF.
  IF t_out-paydmbtr IS NOT INITIAL.
    t_subtotal14-hierlevel = fu_hierlevel.
    t_subtotal14-subsetname = fu_groupname.
    t_subtotal14-paydmbtr = t_out-paydmbtr.
    t_subtotal14-paywaer1 = t_out-paywaer1.
    COLLECT t_subtotal14. CLEAR t_subtotal14.
  ENDIF.
  IF t_out-bi IS NOT INITIAL.
    t_subtotal15-hierlevel = fu_hierlevel.
    t_subtotal15-subsetname = fu_groupname.
    t_subtotal15-bi = t_out-bi.
    t_subtotal15-waebi = t_out-waebi.
    COLLECT t_subtotal15. CLEAR t_subtotal15.
  ENDIF.
  IF t_out-bp IS NOT INITIAL.
    t_subtotal16-hierlevel = fu_hierlevel.
    t_subtotal16-subsetname = fu_groupname.
    t_subtotal16-bp = t_out-bp.
    t_subtotal16-waebp = t_out-waebp.
    COLLECT t_subtotal16. CLEAR t_subtotal16.
  ENDIF.
  IF t_out-ip IS NOT INITIAL.
    t_subtotal17-hierlevel = fu_hierlevel.
    t_subtotal17-subsetname = fu_groupname.
    t_subtotal17-ip = t_out-ip.
    t_subtotal17-waeip = t_out-waeip.
    COLLECT t_subtotal17. CLEAR t_subtotal17.
  ENDIF.
ENDFORM.                    " F_COLLECT_SUBTOTAL1

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SUBTOTAL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_HIERLEVEL  text
*      -->FU_GROUPNAME  text
*----------------------------------------------------------------------*
FORM f_write_subtotal1  USING    fu_hierlevel
                                 fu_groupname.
  FORMAT COLOR 3 INTENSIFIED OFF.
  LOOP AT t_subtotal WHERE hierlevel = fu_hierlevel AND
                           subsetname = fu_groupname.
    WRITE: / sy-vline.
    WRITE: 20 'SUB TOTAL',
              t_subtotal-subsetname.
    WRITE: 60 sy-vline NO-GAP,
           82 sy-vline NO-GAP,
          115 sy-vline NO-GAP,
          148 sy-vline NO-GAP,
              (16)t_subtotal-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-twaer NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-wljhr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-menge DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-meins NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-preis DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-rfatc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-rfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-rfaloc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-rfaum NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-netwr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-acttc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-actlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-actloc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-actqt DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-actum NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-grtc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-grtcc NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-grlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-grlcc NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-grqty DECIMALS 2 NO-GAP NO-ZERO,
               (4)t_subtotal-gruom NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-budactlc DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invwaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invwaer1 NO-GAP, sy-vline NO-GAP,
              (10)t_subtotal-invmenge DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-invmeins NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-ppn DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-pph DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waers NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-paywaer2 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-paywaer1 NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-bi DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waebi NO-GAP, sy-vline NO-GAP,
              (16)t_subtotal-bp DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waebp NO-GAP, sy-vline NO-GAP,
              (17)t_subtotal-ip DECIMALS 0 NO-GAP NO-ZERO,
               (4)t_subtotal-waeip NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  FORMAT COLOR OFF. FORMAT INTENSIFIED OFF.
ENDFORM.                    " F_WRITE_SUBTOTAL1

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_GRANDTOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_grandtotal .
  IF t_out-wtjhr IS NOT INITIAL.
    t_grandtotal1-wtjhr = t_out-wtjhr.
    t_grandtotal1-twaer = t_out-twaer.
    COLLECT t_grandtotal1. CLEAR t_grandtotal1.
  ENDIF.
  IF t_out-wljhr IS NOT INITIAL.
    t_grandtotal2-wljhr = t_out-wljhr.
    t_grandtotal2-waers = t_out-waers.
    COLLECT t_grandtotal2. CLEAR t_grandtotal2.
  ENDIF.
  IF t_out-preis IS NOT INITIAL.
    t_grandtotal3-preis = t_out-preis.
    t_grandtotal3-rfatc = t_out-rfatc.
    COLLECT t_grandtotal3. CLEAR t_grandtotal3.
  ENDIF.
  IF t_out-rfalc IS NOT INITIAL.
    t_grandtotal4-rfalc = t_out-rfalc.
    t_grandtotal4-rfaloc = t_out-waers.
    COLLECT t_grandtotal4. CLEAR t_grandtotal4.
  ENDIF.
  IF t_out-netwr IS NOT INITIAL.
    t_grandtotal5-netwr = t_out-netwr.
    t_grandtotal5-acttc = t_out-acttc.
    COLLECT t_grandtotal5. CLEAR t_grandtotal5.
  ENDIF.
  IF t_out-actlc IS NOT INITIAL.
    t_grandtotal6-actlc = t_out-actlc.
    t_grandtotal6-actloc = t_out-actloc.
    COLLECT t_grandtotal6. CLEAR t_grandtotal6.
  ENDIF.
  IF t_out-budrfatc IS NOT INITIAL.
    t_grandtotal7-budrfatc = t_out-budrfatc.
    t_grandtotal7-rfatc = t_out-twaer.
    COLLECT t_grandtotal7. CLEAR t_grandtotal7.
  ENDIF.
  IF t_out-budrfalc IS NOT INITIAL.
    t_grandtotal8-budrfalc = t_out-budrfalc.
    t_grandtotal8-rfaloc = t_out-waers.
    COLLECT t_grandtotal8. CLEAR t_grandtotal8.
  ENDIF.
  IF t_out-budacttc IS NOT INITIAL.
    t_grandtotal9-budacttc = t_out-budacttc.
    t_grandtotal9-acttc = t_out-twaer.
    COLLECT t_grandtotal9. CLEAR t_grandtotal9.
  ENDIF.
  IF t_out-budactlc IS NOT INITIAL.
    t_grandtotal10-budactlc = t_out-budactlc.
    t_grandtotal10-actloc = t_out-waers.
    COLLECT t_grandtotal10. CLEAR t_grandtotal10.
  ENDIF.
  IF t_out-invwrbtr IS NOT INITIAL.
    t_grandtotal11-invwrbtr = t_out-invwrbtr.
    t_grandtotal11-invwaer2 = t_out-invwaer2.
    COLLECT t_grandtotal11. CLEAR t_grandtotal11.
  ENDIF.
  IF t_out-invdmbtr IS NOT INITIAL.
    t_grandtotal12-invdmbtr = t_out-invdmbtr.
    t_grandtotal12-invwaer1 = t_out-invwaer1.
    COLLECT t_grandtotal12. CLEAR t_grandtotal12.
  ENDIF.
  IF t_out-paywrbtr IS NOT INITIAL.
    t_grandtotal13-paywrbtr = t_out-paywrbtr.
    t_grandtotal13-paywaer2 = t_out-paywaer2.
    COLLECT t_grandtotal13. CLEAR t_grandtotal13.
  ENDIF.
  IF t_out-paydmbtr IS NOT INITIAL.
    t_grandtotal14-paydmbtr = t_out-paydmbtr.
    t_grandtotal14-paywaer1 = t_out-paywaer1.
    COLLECT t_grandtotal14. CLEAR t_grandtotal14.
  ENDIF.
  IF t_out-bi IS NOT INITIAL.
    t_grandtotal15-bi = t_out-bi.
    t_grandtotal15-waebi = t_out-waebi.
    COLLECT t_grandtotal15. CLEAR t_grandtotal15.
  ENDIF.
  IF t_out-bp IS NOT INITIAL.
    t_grandtotal16-bp = t_out-bp.
    t_grandtotal16-waebp = t_out-waebp.
    COLLECT t_grandtotal16. CLEAR t_grandtotal16.
  ENDIF.
  IF t_out-ip IS NOT INITIAL.
    t_grandtotal17-ip = t_out-ip.
    t_grandtotal17-waeip = t_out-waeip.
    COLLECT t_grandtotal17. CLEAR t_grandtotal17.
  ENDIF.
ENDFORM.                    " F_COLLECT_GRANDTOTAL

*&---------------------------------------------------------------------*
*&      Form  F_GET_INVOICE
*&---------------------------------------------------------------------*
FORM f_get_invoice .
  DATA : lt_ekkn  LIKE t_ekkn OCCURS 0 WITH HEADER LINE.

  lt_ekkn[] = t_ekkn[].
  SORT lt_ekkn BY ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_ekkn COMPARING ebeln ebelp.

  IF lt_ekkn[] IS NOT INITIAL.
    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei budat menge dmbtr
      wrbtr waers shkzg
      FROM ekbe
      INTO TABLE gt_ekbe
      FOR ALL ENTRIES IN lt_ekkn
      WHERE ebeln = lt_ekkn-ebeln
        AND ebelp = lt_ekkn-ebelp
        AND vgabe = '2'
        AND bewtp = 'Q'.

*    IF sy-subrc = 0 AND p_bukrs = '8330'.
    IF sy-subrc = 0.
      SELECT belnr gjahr budat lifnr
        INTO CORRESPONDING FIELDS OF TABLE gt_rbkp
        FROM rbkp FOR ALL ENTRIES IN gt_ekbe
        WHERE belnr EQ gt_ekbe-belnr
          AND gjahr EQ gt_ekbe-gjahr.

*      IF sy-subrc = 0 AND p_bukrs = '8330'.
      IF sy-subrc = 0.
        SELECT lifnr name1
          INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
          FROM lfa1 FOR ALL ENTRIES IN gt_rbkp
          WHERE lifnr EQ gt_rbkp-lifnr.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_INVOICE

*&---------------------------------------------------------------------*
*&      Form  F_DIFFERENCE_CURRENCY
*&---------------------------------------------------------------------*
FORM f_difference_currency  USING    fu_waer1 fu_waer2 fu_datum
                            CHANGING fc_gdatu fc_date fc_ukurs.
  LOOP AT t_tcurr WHERE fcurr = fu_waer1
                    AND tcurr = fu_waer2.
    CLEAR: fc_date.
    CONVERT INVERTED-DATE t_tcurr-gdatu INTO DATE fc_date.
    IF fc_date LE fu_datum.
      IF fc_date GT fc_gdatu.
        fc_gdatu = fc_date.
        fc_ukurs = t_tcurr-ukurs * 1000.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_DIFFERENCE_CURRENCY

*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT
*&---------------------------------------------------------------------*
FORM f_get_payment .
  DATA : lt_ekbe  LIKE gt_ekbe OCCURS 0 WITH HEADER LINE.

  CHECK gt_ekbe[] IS NOT INITIAL.

  lt_ekbe[] = gt_ekbe[].
  SORT lt_ekbe BY belnr.
  DELETE ADJACENT DUPLICATES FROM lt_ekbe COMPARING belnr.

  SELECT bukrs lifnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    budat bldat waers shkzg dmbtr wrbtr
    FROM bsak
    INTO TABLE gt_bsak_nkz
    FOR ALL ENTRIES IN lt_ekbe
    WHERE bukrs = p_bukrs
      AND belnr = lt_ekbe-belnr.

  SORT gt_bsak_nkz BY augdt augbl.
  DELETE ADJACENT DUPLICATES FROM gt_bsak_nkz COMPARING augdt augbl.

  CHECK gt_bsak_nkz[] IS NOT INITIAL.

  SELECT bukrs lifnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    budat bldat waers shkzg dmbtr wrbtr
    FROM bsak
    INTO TABLE gt_bsak_kz
    FOR ALL ENTRIES IN gt_bsak_nkz
    WHERE bukrs = p_bukrs
      AND lifnr = gt_bsak_nkz-lifnr
      AND augdt = gt_bsak_nkz-augdt
      AND augbl = gt_bsak_nkz-augbl
      AND blart = 'KZ'.
ENDFORM.                    " F_GET_PAYMENT

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sub_header_01 .
  FORMAT COLOR COL_HEADING.
  WRITE: / sy-vline,
           'Group',
        19 'Group Description',
        60 sy-vline NO-GAP,
        82 sy-vline NO-GAP,
       115 sy-vline NO-GAP,
       148 sy-vline NO-GAP,
       (56)'B U D G E T' CENTERED,
       205 sy-vline NO-GAP,
       (56)'R F A' CENTERED,
       262 sy-vline NO-GAP,
       (56)'PO Realization' CENTERED,
       319 sy-vline NO-GAP,
       (56)'Goods Receipt' CENTERED,
       376 sy-vline NO-GAP,
       (21)'Bal.Budget - RFA' CENTERED,
       397 sy-vline NO-GAP,
       (21)'Bal.Budget - PO Real' CENTERED,
       418 sy-vline NO-GAP,
       (57)'I N V O I C E' CENTERED,
       475 sy-vline NO-GAP,
       (21)'PPN' CENTERED,
       496 sy-vline NO-GAP,
       (21)'PPH' CENTERED,
       517 sy-vline NO-GAP,
       (42)'P A Y M E N T' CENTERED,
       559 sy-vline NO-GAP,
       (21)'Bal.Budget - Invoice' CENTERED,
       580 sy-vline NO-GAP,
       (21)'Bal.Budget - Payment' CENTERED,
       601 sy-vline NO-GAP,
       (22)'Bal.Invoice - Payment' CENTERED,
       623 sy-vline NO-GAP.

  WRITE: / sy-vline,
        60 sy-vline NO-GAP,
       (22)'External order' CENTERED,
        82 sy-vline NO-GAP,
       (33)'Cost Center Budget' CENTERED,
       115 sy-vline NO-GAP,
       (33)'Cost Center Actual' CENTERED,
       148 sy-vline NO-GAP,
       (58)sy-uline NO-GAP,
       205 sy-vline NO-GAP,
       (57)sy-uline NO-GAP,
       262 sy-vline NO-GAP,
       (57)sy-uline NO-GAP,
       319 sy-vline NO-GAP,
       (57)sy-uline NO-GAP,
       376 sy-vline NO-GAP,
       (42)sy-uline NO-GAP,
       418 sy-vline NO-GAP,
       (57)sy-uline NO-GAP,
       475 sy-vline NO-GAP,
       (42)sy-uline NO-GAP,
       517 sy-vline NO-GAP,
       (42)sy-uline NO-GAP,
       559 sy-vline NO-GAP,
       (21)sy-uline NO-GAP,
       580 sy-vline NO-GAP,
       (21)sy-uline NO-GAP,
       601 sy-vline NO-GAP,
       (22)sy-uline NO-GAP,
       623 sy-vline NO-GAP.

  WRITE: / sy-vline,
         9 'Order',
        23 'Order Description',
        60 sy-vline NO-GAP,
        82 sy-vline NO-GAP,
       115 sy-vline NO-GAP,
       148 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       169 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       190 sy-vline NO-GAP,
       (13)'Quantity',
       205 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       226 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       247 sy-vline NO-GAP,
       (13)'Quantity' CENTERED,
       262 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       283 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       304 sy-vline NO-GAP,
       (13)'Quantity' CENTERED,
       319 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       340 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       361 sy-vline NO-GAP,
       (13)'Quantity' CENTERED,
       376 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       397 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       418 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       439 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       460 sy-vline NO-GAP,
       (13)'Quantity' CENTERED,
       475 sy-vline NO-GAP,
       (21)' ' CENTERED,
       496 sy-vline NO-GAP,
       (21)' ' CENTERED,
       517 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       538 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       559 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       580 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       601 sy-vline NO-GAP,
       (22)'Local Curr.' CENTERED,
       623 sy-vline NO-GAP,
      (624) sy-uline.
  FORMAT COLOR OFF.
ENDFORM.                    " F_SUB_HEADER_01

*&---------------------------------------------------------------------*
*&      Form  F_SUB_HEADER_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sub_header_02 .
  FORMAT COLOR COL_HEADING.
  WRITE: / sy-vline,
           'Group',
        19 'Group Description',
        60 sy-vline NO-GAP,
        93 sy-vline NO-GAP,
       126 sy-vline NO-GAP,
       (56)'B U D G E T' CENTERED,
       183 sy-vline NO-GAP,
      (101)'R F A' CENTERED,
       284 sy-vline NO-GAP,
       (67)'PO Realization' CENTERED,
       352 sy-vline NO-GAP,
       (21)'Bal.Budget - RFA' CENTERED,
       373 sy-vline NO-GAP,
       (21)'Bal.Budget - PO Real' CENTERED,
       394 sy-vline NO-GAP,
       (78)'I N V O I C E' CENTERED,
       473 sy-vline NO-GAP,
       (88)'P A Y M E N T' CENTERED,
       562 sy-vline NO-GAP,
       (21)'Bal.Budget - Invoice' CENTERED,
       583 sy-vline NO-GAP,
       (21)'Bal.Budget - Payment' CENTERED,
       604 sy-vline NO-GAP,
       (22)'Bal.Invoice - Payment' CENTERED,
       626 sy-vline NO-GAP.

  WRITE: / sy-vline,
        60 sy-vline NO-GAP,
       (33)'Cost Center Budget' CENTERED,
        93 sy-vline NO-GAP,
       (33)'Cost Center Actual' CENTERED,
       126 sy-vline NO-GAP,
       (58)sy-uline NO-GAP,
       183 sy-vline NO-GAP,
      (101)sy-uline NO-GAP, "
       284 sy-vline NO-GAP,
       (68)sy-uline NO-GAP, "
       352 sy-vline NO-GAP,
       (41)sy-uline NO-GAP,
       394 sy-vline NO-GAP,
       (79)sy-uline NO-GAP, "
       473 sy-vline NO-GAP,
       (89)sy-uline NO-GAP, "
       562 sy-vline NO-GAP,
       (21)sy-uline NO-GAP,
       583 sy-vline NO-GAP,
       (21)sy-uline NO-GAP,
       604 sy-vline NO-GAP,
       (22)sy-uline NO-GAP,
       626 sy-vline NO-GAP.

  WRITE: / sy-vline,
         9 'Order',
        23 'Order Description',
        60 sy-vline NO-GAP,
        93 sy-vline NO-GAP,
       126 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       147 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       168 sy-vline NO-GAP,
       (13)'Quantity',
       183 sy-vline NO-GAP,
       (10)'Nomor PR' NO-GAP,
       194 sy-vline NO-GAP,
       (10)'Tanggal PR' NO-GAP,
       205 sy-vline NO-GAP,
       (10)'Nomor PO' NO-GAP,
       216 sy-vline NO-GAP,
       (10)'Tanggal PO' NO-GAP,
       227 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       248 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       269 sy-vline NO-GAP,
       (13)'Quantity' CENTERED,
       284 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       305 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       326 sy-vline NO-GAP,
       (13)'Quantity' CENTERED,
       341 sy-vline NO-GAP,
       (10)'Tanggal GR' NO-GAP,
       352 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       373 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       394 sy-vline NO-GAP,
       (10)'Nomor INV' NO-GAP,
       405 sy-vline NO-GAP,
       (10)'TanggalINV' NO-GAP,
       416 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       437 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       458 sy-vline NO-GAP,
       (13)'Quantity' CENTERED,
       473 sy-vline NO-GAP,
       (10)'TanggalPAY' NO-GAP,
       484 sy-vline NO-GAP,
       (35)'Vendor' CENTERED NO-GAP,
       520 sy-vline NO-GAP,
       (21)'Trans. Curr.' CENTERED,
       541 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       562 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       583 sy-vline NO-GAP,
       (21)'Local Curr.' CENTERED,
       604 sy-vline NO-GAP,
       (22)'Local Curr.' CENTERED,
       626 sy-vline NO-GAP,
      (626) sy-uline.
  FORMAT COLOR OFF.
ENDFORM.                    " F_SUB_HEADER_02

*&---------------------------------------------------------------------*
*&      Form  F_LISTING_REPORT_ORDER_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_listing_report_order_01 .
  DATA: ld_from  TYPE int4,
        ld_to    TYPE int4,
        ld_kolom TYPE int4,
        ld_sisa  TYPE int4.

  LOOP AT  t_out.
    SET LEFT SCROLL-BOUNDARY COLUMN 61.
    WRITE: / sy-vline,
             t_out-aufnr,
             t_out-ktext.

    WRITE: 60 sy-vline NO-GAP,
              t_out-aufex, sy-vline NO-GAP,
              t_out-akstl,
              t_out-proft, sy-vline NO-GAP,
              t_out-kostl,
              t_out-kostx, sy-vline NO-GAP,
          (16)t_out-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-twaer NO-GAP, sy-vline NO-GAP,
          (16)t_out-wljhr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (10)t_out-menge DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-meins NO-GAP, sy-vline NO-GAP,
          (16)t_out-preis DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-rfatc NO-GAP, sy-vline NO-GAP,
          (16)t_out-rfalc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-rfaloc NO-GAP, sy-vline NO-GAP,
          (10)t_out-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-rfaum NO-GAP, sy-vline NO-GAP,
          (16)t_out-netwr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-acttc NO-GAP, sy-vline NO-GAP,
          (16)t_out-actlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-actloc NO-GAP, sy-vline NO-GAP,
          (10)t_out-actqt DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-actum NO-GAP, sy-vline NO-GAP,
          (16)t_out-grtc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-grtcc NO-GAP, sy-vline NO-GAP,
          (16)t_out-grlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-grlcc NO-GAP, sy-vline NO-GAP,
          (10)t_out-grqty DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-gruom NO-GAP, sy-vline NO-GAP,
          (16)t_out-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-budactlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-invwaer2 NO-GAP, sy-vline NO-GAP,
          (16)t_out-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-invwaer1 NO-GAP, sy-vline NO-GAP,
          (10)t_out-invmenge DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-invmeins NO-GAP, sy-vline NO-GAP,
          (16)t_out-ppn DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-pph DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-paywaer2 NO-GAP, sy-vline NO-GAP,
          (16)t_out-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-paywaer1 NO-GAP, sy-vline NO-GAP,
          (16)t_out-bi DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waebi NO-GAP, sy-vline NO-GAP,
          (16)t_out-bp DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waebp NO-GAP, sy-vline NO-GAP,
          (17)t_out-ip DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waeip NO-GAP, sy-vline NO-GAP.

    PERFORM f_collect_subtotal.

    PERFORM f_append_itab_download USING t_sethier_co-groupname
                                         t_sethier_co-descript.

    HIDE t_out-aufnr.
  ENDLOOP.

  PERFORM f_write_subtotal.
  PERFORM f_free_subtotal.

  WRITE (624)sy-uline.
  PERFORM f_write_grandtotal.
  WRITE (624)sy-uline.
ENDFORM.                    " F_LISTING_REPORT_ORDER_01

*&---------------------------------------------------------------------*
*&      Form  F_LISTING_REPORT_ORDER_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_listing_report_order_02 .
  DATA: ld_from  TYPE int4,
        ld_to    TYPE int4,
        ld_kolom TYPE int4,
        ld_sisa  TYPE int4.

  LOOP AT  t_out.
    SET LEFT SCROLL-BOUNDARY COLUMN 61.
    WRITE: / sy-vline,
             t_out-aufnr,
             t_out-ktext.

    WRITE: 60 sy-vline NO-GAP,
              t_out-akstl,
              t_out-proft, sy-vline NO-GAP,
              t_out-kostl,
              t_out-kostx, sy-vline NO-GAP,
          (16)t_out-wtjhr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-twaer NO-GAP, sy-vline NO-GAP,
          (16)t_out-wljhr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (10)t_out-menge DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-meins NO-GAP, sy-vline NO-GAP,
          (10)t_out-banfn NO-GAP, sy-vline NO-GAP,
          (10)t_out-erdat NO-GAP, sy-vline NO-GAP,
          (10)t_out-ebeln NO-GAP, sy-vline NO-GAP,
          (10)t_out-aedat NO-GAP, sy-vline NO-GAP,
          (16)t_out-preis DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-rfatc NO-GAP, sy-vline NO-GAP,
          (16)t_out-rfalc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-rfaloc NO-GAP, sy-vline NO-GAP,
          (10)t_out-rfaqt DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-rfaum NO-GAP, sy-vline NO-GAP,
          (16)t_out-netwr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-acttc NO-GAP, sy-vline NO-GAP,
          (16)t_out-actlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-actloc NO-GAP, sy-vline NO-GAP,
          (10)t_out-actqt DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-actum NO-GAP, sy-vline NO-GAP,
          (10)t_out-budat_ekbe NO-GAP, sy-vline NO-GAP,
          (16)t_out-budrfalc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (16)t_out-budactlc DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waers NO-GAP, sy-vline NO-GAP,
          (10)t_out-belnr NO-GAP, sy-vline NO-GAP,
          (10)t_out-budat_rbkp NO-GAP, sy-vline NO-GAP,
          (16)t_out-invwrbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-invwaer2 NO-GAP, sy-vline NO-GAP,
          (16)t_out-invdmbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-invwaer1 NO-GAP, sy-vline NO-GAP,
          (10)t_out-invmenge DECIMALS 2 NO-GAP NO-ZERO,
           (4)t_out-invmeins NO-GAP, sy-vline NO-GAP,
          (10)t_out-budat_bsak NO-GAP, sy-vline NO-GAP,
          (35)t_out-name1 NO-GAP, sy-vline NO-GAP,
          (16)t_out-paywrbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-paywaer2 NO-GAP, sy-vline NO-GAP,
          (16)t_out-paydmbtr DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-paywaer1 NO-GAP, sy-vline NO-GAP,
          (16)t_out-bi DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waebi NO-GAP, sy-vline NO-GAP,
          (16)t_out-bp DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waebp NO-GAP, sy-vline NO-GAP,
          (17)t_out-ip DECIMALS 0 NO-GAP NO-ZERO,
           (4)t_out-waeip NO-GAP, sy-vline NO-GAP.

    PERFORM f_collect_subtotal.
  ENDLOOP.

  PERFORM f_write_subtotal_02.
  PERFORM f_free_subtotal.

  WRITE (626)sy-uline.
  PERFORM f_write_grandtotal_02.
  WRITE (626)sy-uline.
ENDFORM.                    " F_LISTING_REPORT_ORDER_02

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_LINE_SIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_change_line_size .
  IF p_bukrs = '8330'.
    sy-linsz = 626.
  ELSE.
    sy-linsz = 502.
  ENDIF.
ENDFORM.                    " F_CHANGE_LINE_SIZE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hdr_ulines .
  IF p_alv IS INITIAL.
    IF d_hdr_rpt_lines = 'X'.
      CASE 'X'.
        WHEN p_rad1.
          WRITE:(623)sy-uline.
        WHEN p_rad2.
          WRITE:(429)sy-uline.
      ENDCASE.
    ENDIF.
  ELSE.
    PERFORM f_hdr_uline.
  ENDIF.
ENDFORM.                    " F_HDR_ULINES

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_CSV
*&---------------------------------------------------------------------*
FORM f_download_csv .
  TYPES lty_truxs_t_text_data(4096) TYPE c.

  DATA: lv_tabname     TYPE ddobjname,
        lt_downloadcsv TYPE truxs_t_text_data,
        ls_headercsv   TYPE lty_truxs_t_text_data,
        dfies_tab      LIKE dfies OCCURS 0 WITH HEADER LINE,
        lv_file_name   LIKE rlgrap-filename.

  DATA: ld_window_title TYPE string,
        ld_default_exte TYPE string,
        ld_fullpath     TYPE string,
        ld_filename     TYPE string,
        ld_user_action  TYPE i,
        ld_filetype(10).

  FIELD-SYMBOLS: <fs_downloadcsv> TYPE lty_truxs_t_text_data.

  CASE 'X'.
    WHEN p_rad1.
      lv_tabname = 'ZDG2COST005'.
    WHEN p_rad2.
      lv_tabname = 'ZDG2COST005D'.
  ENDCASE.

  "Get struture file
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = lv_tabname
    TABLES
      dfies_tab      = dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc = 0.
    LOOP AT dfies_tab.
      IF ls_headercsv IS INITIAL.
        ls_headercsv = dfies_tab-fieldtext.
      ELSE.
        CONCATENATE ls_headercsv dfies_tab-fieldtext
          INTO ls_headercsv SEPARATED BY ';'.
      ENDIF.
    ENDLOOP.
  ENDIF.

  "Generated itab CSV
  CASE 'X'.
    WHEN p_rad1.
      CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
        EXPORTING
          i_field_seperator    = ';'
        TABLES
          i_tab_sap_data       = gt_zdg2cost005
        CHANGING
          i_tab_converted_data = lt_downloadcsv
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.
    WHEN p_rad2.
      CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
        EXPORTING
          i_field_seperator    = ';'
        TABLES
          i_tab_sap_data       = gt_popup
        CHANGING
          i_tab_converted_data = lt_downloadcsv
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.
  ENDCASE.

  "Insert Header to itab CSV
  INSERT INITIAL LINE INTO lt_downloadcsv INDEX 1 ASSIGNING <fs_downloadcsv>.
  <fs_downloadcsv> = ls_headercsv.

  "Get filename
  ld_window_title = 'Download data'.
  ld_default_exte = 'CSV'.
  CONCATENATE sy-datum sy-uzeit INTO ld_filename
                                SEPARATED BY '_'.

  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      window_title      = ld_window_title
      default_extension = ld_default_exte
      default_file_name = ld_filename
    IMPORTING
      filename          = ld_filename
      fullpath          = ld_fullpath
      user_action       = ld_user_action.

  "Download data
  IF ld_user_action = 9.
  ELSE.
    "Download itab to local file
    ld_filetype = 'ASC'.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename         = ld_fullpath
        filetype         = ld_filetype
*       write_field_separator = 'X'
      TABLES
        data_tab         = lt_downloadcsv
*       fieldnames       = lt_dwn_field
      EXCEPTIONS
        file_write_error = 01
        no_batch         = 04
        unknown_error    = 05
        OTHERS           = 99.

    IF sy-subrc = 0.
      MESSAGE 'File downloaded successfully' TYPE 'S'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DOWNLOAD_CSV

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_ITAB_DOWNLOAD
*&---------------------------------------------------------------------*
FORM f_append_itab_download USING fu_groupname
                                  fu_descript.
  gt_zdg2cost005-groupname = fu_groupname.
  gt_zdg2cost005-descript  = fu_descript.
  gt_zdg2cost005-aufnr     = t_out-aufnr.
  gt_zdg2cost005-ktext     = t_out-ktext.
  gt_zdg2cost005-aufex     = t_out-aufex.
  gt_zdg2cost005-akstl     = t_out-akstl.
  gt_zdg2cost005-proft     = t_out-proft.
  gt_zdg2cost005-kostl     = t_out-kostl.
  gt_zdg2cost005-kostx     = t_out-kostx.
  gt_zdg2cost005-waers     = t_out-waers.
  gt_zdg2cost005-meins     = t_out-meins.
  WRITE: t_out-wtjhr TO gt_zdg2cost005-wtjhr DECIMALS 0,
         t_out-wljhr TO gt_zdg2cost005-wljhr DECIMALS 0,
         t_out-menge TO gt_zdg2cost005-menge DECIMALS 0,
         t_out-preis TO gt_zdg2cost005-preis DECIMALS 0,
         t_out-rfalc TO gt_zdg2cost005-rfalc DECIMALS 0,
         t_out-rfaqt TO gt_zdg2cost005-rfaqt DECIMALS 0,
         t_out-netwr TO gt_zdg2cost005-netwr DECIMALS 0,
         t_out-actlc TO gt_zdg2cost005-actlc DECIMALS 0,
         t_out-actqt TO gt_zdg2cost005-actqt DECIMALS 0,
         t_out-grtc TO gt_zdg2cost005-grtc DECIMALS 0,
         t_out-grlc TO gt_zdg2cost005-grlc DECIMALS 0,
         t_out-grqty TO gt_zdg2cost005-grqty DECIMALS 0,
         t_out-budrfalc TO gt_zdg2cost005-budrfalc DECIMALS 0,
         t_out-budactlc TO gt_zdg2cost005-budactlc DECIMALS 0,
         t_out-invwrbtr TO gt_zdg2cost005-invwrbtr DECIMALS 0,
         t_out-invdmbtr TO gt_zdg2cost005-invdmbtr DECIMALS 0,
         t_out-invmenge TO gt_zdg2cost005-invmenge DECIMALS 0,
         t_out-ppn TO gt_zdg2cost005-ppn DECIMALS 0,
         t_out-pph TO gt_zdg2cost005-pph DECIMALS 0,
         t_out-paywrbtr TO gt_zdg2cost005-paywrbtr DECIMALS 0,
         t_out-paydmbtr TO gt_zdg2cost005-paydmbtr DECIMALS 0,
         t_out-bi TO gt_zdg2cost005-bi DECIMALS 0,
         t_out-bp TO gt_zdg2cost005-bp DECIMALS 0,
         t_out-ip TO gt_zdg2cost005-ip DECIMALS 0.
  APPEND gt_zdg2cost005. CLEAR gt_zdg2cost005.
ENDFORM.                    " F_APPEND_ITAB_DOWNLOAD

*&---------------------------------------------------------------------*
*&      Form  F_GET_GOOD_RECEIPT
*&---------------------------------------------------------------------*
FORM f_get_good_receipt .
  DATA : lt_ekkn  LIKE t_ekkn OCCURS 0 WITH HEADER LINE.

  lt_ekkn[] = t_ekkn[].
  SORT lt_ekkn BY ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_ekkn COMPARING ebeln ebelp.

  IF lt_ekkn[] IS NOT INITIAL.
    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei budat menge dmbtr
      wrbtr waers shkzg
      INTO TABLE gt_ekbe_gr
      FROM ekbe FOR ALL ENTRIES IN lt_ekkn
      WHERE ebeln = lt_ekkn-ebeln
        AND ebelp = lt_ekkn-ebelp
        AND vgabe = '1'
        AND bewtp = 'E'
        AND dmbtr NE 0.
  ENDIF.
ENDFORM.                    " F_GET_GOOD_RECEIPT

*&---------------------------------------------------------------------*
*&      Form  F_GET_PPN_PPH
*&---------------------------------------------------------------------*
FORM f_get_ppn_pph .
  DATA : lt_ekbe LIKE gt_ekbe OCCURS 0 WITH HEADER LINE.

  APPEND LINES OF gt_ekbe TO lt_ekbe.
  APPEND LINES OF gt_ekbe_gr TO lt_ekbe.

  IF lt_ekbe[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr buzei dmbtr hkont
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FROM bseg FOR ALL ENTRIES IN lt_ekbe
      WHERE bukrs = p_bukrs
        AND belnr = lt_ekbe-belnr
        AND gjahr = p_gjahr
        AND hkont IN ('0142200220','0315100040','0313600500').
  ENDIF.
ENDFORM.                    " F_GET_PPN_PPH

*&---------------------------------------------------------------------*
*&      Form  F_LINE_SELECTION
*&---------------------------------------------------------------------*
FORM f_line_selection USING fu_value.
  CLEAR: gt_popup2,gt_popup2[].
  gt_popup2[] = gt_popup[].
  DELETE gt_popup2 WHERE aufnr NE fu_value.

  CALL SCREEN 555 STARTING AT 10  5
                  ENDING AT  150 25.

*  CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
*    EXPORTING
*      endpos_col   = 150
*      endpos_row   = 25
*      startpos_col = 10
*      startpos_row = 4
*      titletext    = 'Confirmation'
*    IMPORTING
*      choise       = gv_option
*    TABLES
*      valuetab     = gt_popup
*    EXCEPTIONS
*      break_off    = 1
*      OTHERS       = 2.
*  IF sy-subrc <> 0.
**     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
ENDFORM.                    " F_LINE_SELECTION

*&---------------------------------------------------------------------*
*&      Module  STATUS_0555  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0555 OUTPUT.
*  SET PF-STATUS 'STATUS555'.
  SET PF-STATUS space.
  SET TITLEBAR 'TITLE555'.
ENDMODULE.                 " STATUS_0555  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0555  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0555 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0555  INPUT

*&---------------------------------------------------------------------*
*&      Module  DISPLAY_LIST  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_list OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  LOOP AT gt_popup2.
    WRITE:/ sy-vline NO-GAP,
            gt_popup2-aufnr NO-GAP, sy-vline NO-GAP,
            gt_popup2-aufex NO-GAP, sy-vline NO-GAP,
            gt_popup2-prno NO-GAP, sy-vline NO-GAP,
            gt_popup2-prdat NO-GAP, sy-vline NO-GAP,
            gt_popup2-prqty NO-GAP, sy-vline NO-GAP,
            gt_popup2-prval NO-GAP, sy-vline NO-GAP,
            gt_popup2-prcur NO-GAP, sy-vline NO-GAP,
            gt_popup2-pono NO-GAP, sy-vline NO-GAP,
            gt_popup2-podat NO-GAP, sy-vline NO-GAP,
            gt_popup2-poqty NO-GAP, sy-vline NO-GAP,
            gt_popup2-poval NO-GAP, sy-vline NO-GAP,
            gt_popup2-pocur NO-GAP, sy-vline NO-GAP,
            gt_popup2-name1 NO-GAP, sy-vline NO-GAP,
            gt_popup2-grno NO-GAP, sy-vline NO-GAP,
            gt_popup2-grdat NO-GAP, sy-vline NO-GAP,
            gt_popup2-grqty NO-GAP, sy-vline NO-GAP,
            gt_popup2-grval NO-GAP, sy-vline NO-GAP,
            gt_popup2-grcur NO-GAP, sy-vline NO-GAP,
            gt_popup2-ivno NO-GAP, sy-vline NO-GAP,
            gt_popup2-ivdat NO-GAP, sy-vline NO-GAP,
            gt_popup2-ivqty NO-GAP, sy-vline NO-GAP,
            gt_popup2-ivval NO-GAP, sy-vline NO-GAP,
            gt_popup2-ivcur NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  WRITE:/(291) sy-uline.
ENDMODULE.                 " DISPLAY_LIST  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_ITAB_POPUP
*&---------------------------------------------------------------------*
FORM f_append_itab_popup .
  APPEND INITIAL LINE TO gt_popup ASSIGNING <fs_popup>.
  <fs_popup>-aufnr = t_out-aufnr.
  <fs_popup>-aufex = t_out-aufex.
  <fs_popup>-anln1 = t_out-anln1.
  <fs_popup>-txt50 = t_out-txt50.
  <fs_popup>-prno  = t_out-banfn.
  WRITE t_out-erdat TO <fs_popup>-prdat.
  WRITE t_out-rfaqt TO <fs_popup>-prqty DECIMALS 2.
  WRITE t_out-rfalc TO <fs_popup>-prval DECIMALS 0.
  <fs_popup>-prcur = t_out-rfaloc.
  <fs_popup>-pono  = t_out-ebeln.
  WRITE t_out-aedat TO <fs_popup>-podat.
  WRITE t_out-actqt TO <fs_popup>-poqty DECIMALS 2.
  WRITE t_out-netwr TO <fs_popup>-poval DECIMALS 0.
  <fs_popup>-name1 = t_out-name1.
  <fs_popup>-grno  = t_out-grno.
  WRITE t_out-grdat TO <fs_popup>-grdat.
  WRITE t_out-grqty TO <fs_popup>-grqty.
  WRITE t_out-grlc TO <fs_popup>-grval.
  <fs_popup>-grcur = t_out-grlcc.
  <fs_popup>-ivno  = t_out-belnr.
  WRITE t_out-budat_ekbe TO <fs_popup>-ivdat.
  WRITE t_out-invmenge TO <fs_popup>-ivqty DECIMALS 2.
  WRITE t_out-invdmbtr TO <fs_popup>-ivval DECIMALS 0.
  <fs_popup>-ivcur = t_out-invwaer1.
  <fs_popup>-belnr_bsak = t_out-belnr_bsak.
  WRITE t_out-budat_bsak TO <fs_popup>-budat_bsak.
  WRITE t_out-ppn TO <fs_popup>-ppn DECIMALS 0.
  WRITE t_out-pph TO <fs_popup>-pph DECIMALS 0.
  WRITE t_out-dpp TO <fs_popup>-dpp DECIMALS 0.
ENDFORM.                    " F_APPEND_ITAB_POPUP

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_POPUP
*&---------------------------------------------------------------------*
FORM f_header_popup .
*  WRITE:/(317) sy-uline.
  WRITE:/ sy-vline NO-GAP,
          (12)'Internal Ord' CENTERED NO-GAP, sy-vline NO-GAP,
          (20)'Job Order' CENTERED NO-GAP, sy-vline NO-GAP,
          (12)'Fixed Asset#' CENTERED NO-GAP, sy-vline NO-GAP,
          (50)'Asset description' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'PR NO.' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'PR DATE' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'PR QTY' CENTERED NO-GAP, sy-vline NO-GAP,
          (15)'PR VALUE' CENTERED NO-GAP, sy-vline NO-GAP,
           (5)'PR CURR' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'PO NO.' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'PO DATE' CENTERED  NO-GAP, sy-vline NO-GAP,
          (10)'PO QTY' CENTERED NO-GAP, sy-vline NO-GAP,
          (15)'PO VALUE' CENTERED NO-GAP, sy-vline NO-GAP,
           (5)'PO CURR' CENTERED NO-GAP, sy-vline NO-GAP,
          (35)'VENDOR' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'GR NO' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'GR DATE' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'GR QTY' CENTERED NO-GAP, sy-vline NO-GAP,
          (15)'GR VALUE' CENTERED NO-GAP, sy-vline NO-GAP,
           (5)'GR CURR' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'INVOICE NO' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'INVOICE DATE' CENTERED NO-GAP, sy-vline NO-GAP,
          (10)'INVOICE QTY' CENTERED NO-GAP, sy-vline NO-GAP,
          (15)'INVOICE VALUE' CENTERED NO-GAP, sy-vline NO-GAP,
           (5)'INVOICE QURR' CENTERED NO-GAP, sy-vline NO-GAP,
          (12)'PAYMENT DOC.' CENTERED NO-GAP, sy-vline NO-GAP,
          (12)'PAYMENT DATE' CENTERED NO-GAP, sy-vline NO-GAP,
          (15)'PPN' CENTERED NO-GAP, sy-vline NO-GAP,
          (15)'PPH' CENTERED NO-GAP, sy-vline NO-GAP,
          (15)'DPP' CENTERED NO-GAP, sy-vline NO-GAP.
  WRITE:/(429) sy-uline.
ENDFORM.                    " F_HEADER_POPUP

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_DETAIL
*&---------------------------------------------------------------------*
FORM f_write_detail .
  LOOP AT gt_popup.
    WRITE:/ sy-vline NO-GAP,
            gt_popup-aufnr NO-GAP, sy-vline NO-GAP,
            gt_popup-aufex NO-GAP, sy-vline NO-GAP,
            gt_popup-anln1 NO-GAP, sy-vline NO-GAP,
            gt_popup-txt50 NO-GAP, sy-vline NO-GAP,
            gt_popup-prno NO-GAP, sy-vline NO-GAP,
            gt_popup-prdat NO-GAP, sy-vline NO-GAP,
            gt_popup-prqty NO-GAP, sy-vline NO-GAP,
            gt_popup-prval NO-GAP, sy-vline NO-GAP,
            gt_popup-prcur NO-GAP, sy-vline NO-GAP,
            gt_popup-pono NO-GAP, sy-vline NO-GAP,
            gt_popup-podat NO-GAP, sy-vline NO-GAP,
            gt_popup-poqty NO-GAP, sy-vline NO-GAP,
            gt_popup-poval NO-GAP, sy-vline NO-GAP,
            gt_popup-pocur NO-GAP, sy-vline NO-GAP,
            gt_popup-name1 NO-GAP, sy-vline NO-GAP,
            gt_popup-grno NO-GAP, sy-vline NO-GAP,
            gt_popup-grdat NO-GAP, sy-vline NO-GAP,
            gt_popup-grqty NO-GAP, sy-vline NO-GAP,
            gt_popup-grval NO-GAP, sy-vline NO-GAP,
            gt_popup-grcur NO-GAP, sy-vline NO-GAP,
            gt_popup-ivno NO-GAP, sy-vline NO-GAP,
            gt_popup-ivdat NO-GAP, sy-vline NO-GAP,
            gt_popup-ivqty NO-GAP, sy-vline NO-GAP,
            gt_popup-ivval NO-GAP, sy-vline NO-GAP,
            gt_popup-ivcur NO-GAP, sy-vline NO-GAP,
            gt_popup-belnr_bsak NO-GAP, sy-vline NO-GAP,
            gt_popup-budat_bsak NO-GAP, sy-vline NO-GAP,
            gt_popup-ppn NO-GAP, sy-vline NO-GAP,
            gt_popup-pph NO-GAP, sy-vline NO-GAP,
            gt_popup-dpp NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  WRITE:/(429) sy-uline.
ENDFORM.                    " F_WRITE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1S
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line1s USING fu_company fu_linsz.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42)    VALUE 'Program: xx',
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_titles USING progname fu_company page_number fu_linsz.
ENDFORM.                    " F_HDR_LINE1S


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2S
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
FORM f_hdr_line2s USING fu_title fu_linsz.
  DATA:
    ld_sysid(18) VALUE 'Client:  XXX(YYY)',
    ld_datum(10).

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.

*--- date
  WRITE sy-datum TO ld_datum.

*--- output line
  PERFORM f_hdr_pad_titles USING ld_sysid fu_title ld_datum fu_linsz.
ENDFORM.                    " F_HDR_LINE2S


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3S
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line3s USING fu_title fu_linsz.
  DATA:
    ld_uzeit(5)  VALUE 'hh:mm',
    ld_uname(21) VALUE 'User:    xx'.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

*--- user
  REPLACE 'xx' WITH sy-uname INTO ld_uname.

*--- output line
  PERFORM f_hdr_pad_titles USING ld_uname fu_title ld_uzeit fu_linsz.

ENDFORM.                    " F_HDR_LINE3S

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLES
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_titles USING v_left_text v_middle_text v_right_text linsz.

  DATA:
    page_width    TYPE i,       " Width of page
    middle_length TYPE i,    " Length of title text
    left_length   TYPE i,      " Length of left text
    right_length  TYPE i,     " Length of right text
    left_start    TYPE i,       " Position on line for start of left tex
    middle_start  TYPE i,     " Position on line for start of middl tex
    right_start   TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
*  page_width = sy-linsz - 1.
  page_width = linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = strlen( v_middle_text ).
  COMPUTE left_length = strlen( v_left_text ).
  COMPUTE right_length = strlen( v_right_text ).

*  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.
  COMPUTE middle_start = ( linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
*  right_start = sy-linsz - left_start - right_length - 1.
  right_start = linsz - left_start - right_length - 1.
  WRITE:/ sy-vline.
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
  WRITE AT linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_TITLE
