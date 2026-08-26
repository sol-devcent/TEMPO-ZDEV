FUNCTION z_gdtxfc_print_smartforms.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FI_DISPLAY) TYPE  CHAR01 DEFAULT 'X'
*"     VALUE(FI_REPORT) TYPE  CHAR01 DEFAULT 'X'
*"     REFERENCE(FI_CHECKING_ONLY) TYPE  CHAR01 OPTIONAL
*"     REFERENCE(FI_NONLIVES) TYPE  CHAR01 OPTIONAL
*"     REFERENCE(FI_FOREX) TYPE  CHAR01 OPTIONAL
*"     REFERENCE(FI_MPAGE) TYPE  CHAR01 OPTIONAL
*"     REFERENCE(FI_PRINTER) LIKE  ITCPO-TDDEST OPTIONAL
*"     REFERENCE(FI_BUKRS) LIKE  BSIS-BUKRS
*"  TABLES
*"      FT_PKP STRUCTURE  ZGDTXST0001
*"      FT_CUSTOMER STRUCTURE  ZGDTXST0002
*"      FT_ITEM STRUCTURE  ZGDTXST0003
*"      FT_SIGNATURE STRUCTURE  ZGDTXST0005
*"      FT_TAX STRUCTURE  ZGDTXST0006 OPTIONAL
*"      FT_ERROR_RESULT STRUCTURE  ZGDTXST0001 OPTIONAL
*"  EXCEPTIONS
*"      DATA_TOO_LONG
*"      PPNBM_TOO_LONG
*"      DATE_WORD_NOT_MAINTAINED
*"----------------------------------------------------------------------

  DATA ld_tabix LIKE sy-tabix.
  DATA ld_subtotal LIKE zgdtxst0003-itamtlast.
  DATA ld_subtotal_f LIKE zgdtxst0003-itamtlast.
  DATA ld_line TYPE i.
  DATA ld_item TYPE i.
  DATA ld_count TYPE i.
  DATA ld_spell LIKE spell.
  DATA ld_selisih LIKE zgdtxst0004-fakppn.
  DATA ld_cek LIKE zgdtxst0004-fakppn.

  DATA lt_desc LIKE ft_item OCCURS 0 WITH HEADER LINE.
  DATA ld_langu LIKE sy-langu.

  DATA ld_mwskz TYPE bset-mwskz.
  DATA ld_spart TYPE vbrk-spart.

  d_mpage = fi_mpage.
  d_lyt_tddst = fi_printer.

  REFRESH: ft_error_result, t_page.
  SORT: ft_customer  BY fakturno,
        ft_signature BY fakturno.

  p_disp = fi_display.

***Define Samrtforms for Dragon Glory
  IF fi_bukrs EQ '8230' OR
    fi_bukrs EQ '8050'.
    IF ft_item-trcurr EQ 'IDR'.
      p_tdform  = 'ZDGFI_008'.
    ELSE.
      p_tdform  = 'ZDGFI_011'.
    ENDIF.
  ENDIF.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_output_opt-tdnoprint = p_disp.
  d_output_opt-tddest    = fi_printer.
***End of Smartforms definition

***Process only when the smartforms is defined
  IF d_frm_subrc IS INITIAL AND
     NOT ft_pkp[] IS INITIAL.
* I. Create New Itab for Item
* I.1. Get Master Data
    LOOP AT ft_pkp.

*      MOVE-CORRESPONDING t_crb_head TO lw_crb_head.
*      lt_item[] = t_crb_item[].
*      DELETE lt_item WHERE kunnr <> lw_crb_head-kunnr.
      CLEAR: ft_customer,
             d_total, d_dpp_f, d_ppn_f,
             ft_signature.
      READ TABLE ft_customer  WITH KEY fakturno = ft_pkp-fakturno
           BINARY SEARCH.
      READ TABLE ft_signature WITH KEY fakturno = ft_pkp-fakturno
           BINARY SEARCH.

      d_lyt_pkp       = ft_pkp.
      CONCATENATE d_lyt_pkp-pkpaddrs2
                  d_lyt_pkp-pkpcity
                  d_lyt_pkp-pkppostal
                  INTO d_lyt_pkp-pkpaddrs3
                  SEPARATED BY space.

      CALL FUNCTION 'Z_GET_DATE_WORD'
        EXPORTING
          fi_date                   = d_lyt_pkp-pkpkuh
          fi_langu                  = sy-langu
        IMPORTING
          fe_dateword               = d_pkp_date_word
        EXCEPTIONS
          month_name_not_maintained = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        MESSAGE e000(zab) RAISING date_word_not_maintained.
      ENDIF.

      d_lyt_customer  = ft_customer.
      IF d_lyt_customer-addrs2 IS INITIAL.
        CONCATENATE d_lyt_customer-city
                    d_lyt_customer-postal
                    INTO d_lyt_customer-addrs3
                    SEPARATED BY space.
      ELSE.
        CONCATENATE d_lyt_customer-addrs2
                    d_lyt_customer-city
                    d_lyt_customer-postal
                    INTO d_lyt_customer-addrs3
                    SEPARATED BY space.
      ENDIF.

      d_lyt_signature = ft_signature.

      READ TABLE ft_item WITH KEY fakturno = ft_pkp-fakturno.
      IF ft_item-trcurr = c_idr.
        ld_langu = 'i'.
      ELSE.
        ld_langu = sy-langu.
      ENDIF.
      CALL FUNCTION 'Z_GET_DATE_WORD'
        EXPORTING
          fi_date                   = d_lyt_signature-fakdat
          fi_langu                  = ld_langu
        IMPORTING
          fe_dateword               = d_sign_date_word
        EXCEPTIONS
          month_name_not_maintained = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        MESSAGE e000(zab) RAISING date_word_not_maintained.
      ENDIF.

      DATA: ld_ex_ppnbm LIKE zgdtxst0003-xppnbmlast,
            ld_kwert LIKE ft_item-rate_tax.
      REFRESH t_item.
      CLEAR:  d_lyt_total,
              ld_ex_ppnbm,
              d_ex_ppnbm,
              t_page.

      lt_desc[] = ft_item[].
      DELETE lt_desc WHERE fakturno <> ft_pkp-fakturno.
      DESCRIBE TABLE lt_desc LINES ld_line.

****Write items
      LOOP AT ft_item WHERE fakturno = ft_pkp-fakturno.
        WRITE ft_item-linenum TO t_item-linenum NO-ZERO RIGHT-JUSTIFIED.
        t_item-item     = ft_item-item.
        t_item-trcurr   = ft_item-trcurr.
        t_item-vrkme    = ft_item-vrkme.
        IF ft_item-trcurr IS INITIAL.
          t_item-trcurr = c_idr.
        ENDIF.
        IF NOT t_item-linenum = 0.

*---------Unit price & quantity

***modified untuk harga satuan --> 2 decimals 11/01/2007
*          WRITE ft_item-prcpiece CURRENCY ft_pkp-waers
*          TO  t_item-prcpiece.

          DATA: ld_itamtlast TYPE p DECIMALS 2,
                ld_prcpiece  LIKE zgdtxst0003-itamtlast.
          IF ft_pkp-waers EQ 'IDR'.
            ld_itamtlast = ft_item-itamtlast * 100.
            IF ft_item-itqtylast IS NOT INITIAL.
              ld_prcpiece  = ld_itamtlast / ft_item-itqtylast.
            ENDIF.
            WRITE ld_prcpiece TO t_item-prcpiece.
          ELSE.
            WRITE ft_item-prcpiece CURRENCY ft_pkp-waers
            TO  t_item-prcpiece.
          ENDIF.

          WRITE ft_item-itqtylast UNIT ft_item-vrkme
          TO t_item-qty.

          IF t_item-trcurr NE c_idr.  "For Non IDR
            WRITE ft_item-itamt_f TO t_item-harga_vls
                  CURRENCY t_item-trcurr.

***fixed by Rahmadi
*         multiply it with 100 because in created program, it's
*         divided by 100 (hardcoded) for every rate tax.
*            ld_kwert = ft_item-rate_tax * 100.
*            WRITE ld_kwert TO t_item-rate_tax.
**                  CURRENCY t_item-trcurr.
            WRITE ft_item-rate_tax CURRENCY ft_pkp-waers
                  TO t_item-rate_tax.
***end of fix
*          ELSE.
          ENDIF.
          WRITE ft_item-itamtlast TO t_item-harga_rp
                 CURRENCY ft_pkp-waers.
*          ENDIF.
        ELSE.
          CLEAR : t_item-harga_rp, t_item-harga_vls.
        ENDIF.

        APPEND t_item.
        ADD ft_item-xppnbmlast TO ld_ex_ppnbm.

*------ calculate total
        d_total-fakturno = ft_item-fakturno.
        IF t_item-trcurr NE c_idr.
          ADD ft_item-itamt_f  TO d_total-itamtlast_f.
          ADD ft_item-itdisc_f TO d_total-itdisclast_f.
          ADD ft_item-dpp_f TO d_dpp_f.
          ADD ft_item-ppn_f TO d_ppn_f.
*        ELSE.
*          ADD ft_item-itamtlast  TO d_total-itamtlast.
*          ADD ft_item-itdisclast TO d_total-itdisclast.
        ENDIF.
        ADD ft_item-dpplast    TO d_total-dpplast.
        ADD ft_item-ppnlast    TO d_total-fakppn.
        ADD ft_item-itamtlast  TO d_total-itamtlast.
        ADD ft_item-itdisclast TO d_total-itdisclast.

******multiple pages
        IF NOT d_mpage IS INITIAL.
          ld_item = ld_item + 1.
          ld_count = ld_count + 1.
          IF t_item-trcurr NE c_idr.
            ADD ft_item-itamt_f TO ld_subtotal_f.
*          ELSE.
          ENDIF.
          ADD ft_item-itamtlast TO ld_subtotal.
*          ENDIF.
          IF ld_item = c_max_item OR
             ld_count = ld_line.

            t_page-fakturno = ft_item-fakturno.
            t_page-page = t_page-page + 1.
            t_page-itamtlast_f = ld_subtotal_f.
            t_page-itamtlast = ld_subtotal.
            t_page-itcurr = t_item-trcurr.
            t_page-line = ld_count.
            APPEND t_page.

            IF NOT fi_report IS INITIAL.
*            t_item-pagenum = t_page-page.
*            MODIFY t_item INDEX ld_count.
              CLEAR t_item. t_item-trcurr = t_page-itcurr.
              APPEND t_item.
              t_item-item = d_subtotal_text.
              IF t_item-trcurr NE c_idr.
                WRITE ld_subtotal_f TO t_item-harga_vls
                       CURRENCY ft_pkp-waers.
*              ELSE.
              ENDIF.
              WRITE ld_subtotal TO t_item-harga_rp
                     CURRENCY ft_pkp-waers.
*              ENDIF.
              APPEND t_item.
            ENDIF.

            CLEAR: ld_subtotal, ld_subtotal_f, ld_item, t_page.
          ENDIF.
        ENDIF.
      ENDLOOP.
****end of Item writing

***14122012 Modifikasi untuk TLOG
      IF fi_bukrs EQ '8050'.
        break bcdik.
* Proses untuk mencari dpp pengenaan pajaknya 10% atau 1%
*  caranya PPN / DPP
*
        ld_cek     = 10 / 100.
        ld_selisih = d_total-fakppn / d_total-itamtlast.
        IF ld_selisih NE ld_cek.
          d_total-dpplast = d_total-itamtlast * 10 / 100.
        ENDIF.

*        ld_selisih = d_total-fakppn / d_total-dpplast * 100.
*        IF ld_selisih NE 10.
*          d_total-dpplast = d_total-itamtlast * 10 / 100.
*        ENDIF.

*        d_total-dpplast = d_total-itamtlast * 10 / 100.
*        IF d_total-dpplast eq d_total-fakppn.
*          d_total-dpplast = d_total-itamtlast.
*        ENDIF.
      ENDIF.

****Get total & Header info
      IF NOT d_mpage IS INITIAL.
        CLEAR ld_count.
        SORT t_page BY fakturno page.
      ENDIF.

***      d_lyt_total     = d_total.
***      line diatas diganti dengan line dibawa karna proyek unicode 09-01-2020
      MOVE-CORRESPONDING d_total to d_lyt_total.
*      break bcrmd.
      DATA ld_forex.
      CLEAR: d_lyt_total-itamtlast,
             d_lyt_total-itdisclast,
             d_lyt_total-itamtlast_f,
             d_lyt_total-itdisclast_f,
             d_lyt_total-dpp_f,
             d_lyt_total-ppn_f.
      IF t_item-trcurr NE c_idr.
        ld_forex = 'X'.
        IF d_total-itamtlast_f <> 0.
          WRITE d_total-itamtlast_f TO d_lyt_total-itamtlast_f
                                   CURRENCY t_item-trcurr.
        ENDIF.
        IF d_total-itdisclast_f <> 0.
          WRITE d_total-itdisclast_f TO d_lyt_total-itdisclast_f
                                   CURRENCY t_item-trcurr.
        ENDIF.
        IF d_dpp_f <> 0.
          WRITE d_dpp_f            TO d_lyt_total-dpp_f
                                   CURRENCY t_item-trcurr.
        ENDIF.
        IF d_ppn_f <> 0.
          WRITE d_ppn_f            TO d_lyt_total-ppn_f
                                   CURRENCY t_item-trcurr.
        ENDIF.

      ELSE.
        CLEAR ld_forex.
      ENDIF.
      IF d_total-itamtlast <> 0.
        WRITE d_total-itamtlast  CURRENCY ft_pkp-waers
              TO d_lyt_total-itamtlast.
      ENDIF.
      IF d_total-itdisclast <> 0.
        WRITE d_total-itdisclast CURRENCY ft_pkp-waers
              TO d_lyt_total-itdisclast.
      ENDIF.

*      ENDIF.

      WRITE d_total-dpplast    CURRENCY ft_pkp-waers
            TO d_lyt_total-dpplast.

*    IF NOT fi_nonlive IS INITIAL.
      IF ft_pkp-rectype = 'N'.          "N = Non Live
        d_total-fakppn = d_total-dpplast / 10.
      ENDIF.

      IF fi_bukrs EQ '8230'.
        SELECT SINGLE mwskz
          FROM bset
          INTO ld_mwskz
          WHERE bukrs EQ fi_bukrs AND
                belnr EQ d_lyt_customer-vbeln.

        SELECT SINGLE spart
          FROM vbrk
          INTO ld_spart
          WHERE vbeln EQ d_lyt_customer-vbeln.

        IF ld_spart EQ '60'.
          d_total-fakppn = d_total-dpplast * 1 / 100.
        ELSE.
          IF ld_mwskz EQ 'K3'.
            d_total-fakppn = d_total-dpplast * 1 / 100.
          ELSE.
            d_total-fakppn = d_total-dpplast * 10 / 100.
          ENDIF.
        ENDIF.
      ENDIF.
      WRITE d_total-fakppn     CURRENCY ft_pkp-waers
            TO d_lyt_total-fakppn.

      IF NOT ld_ex_ppnbm IS INITIAL.
        WRITE ld_ex_ppnbm CURRENCY ft_pkp-waers TO d_ex_ppnbm
              LEFT-JUSTIFIED.
      ENDIF.

      DATA ld_pay LIKE d_total-itamtlast.
      DATA ld_pay_f LIKE d_total-itamtlast_f.
      DATA ld_payword LIKE d_total-itamtlast.
*      DATA ld_langu LIKE sy-langu.
      CLEAR ld_langu.
      IF t_item-trcurr NE c_idr.
        ld_pay_f = d_dpp_f + d_ppn_f.
        ld_langu = sy-langu.
      ELSE.
        ld_langu = 'i'.
        CLEAR ld_pay_f.
      ENDIF.
      ld_pay = d_total-dpplast + d_total-fakppn.

      IF t_item-trcurr NE c_idr.
        ld_payword = ld_pay_f.
      ELSE.
        ld_payword = ld_pay.
      ENDIF.

*-----Spell amount
      CALL FUNCTION 'SPELL_AMOUNT'
        EXPORTING
          amount    = ld_payword
          currency  = t_item-trcurr
          language  = ld_langu
        IMPORTING
          in_words  = ld_spell
        EXCEPTIONS
          not_found = 1
          too_large = 2
          OTHERS    = 3.
      IF sy-subrc <> 0.
        CLEAR ld_spell.
      ENDIF.

*-----Amount in words
      DATA l_waers1(40).
      DATA l_waers(6).
      DATA ld_words TYPE char255.
      IF t_item-trcurr NE c_idr.
        SELECT SINGLE ktext
          FROM tcurt
          INTO l_waers1
          WHERE spras EQ sy-langu AND
                waers EQ t_item-trcurr.
        TRANSLATE l_waers1 TO UPPER CASE.
      ENDIF.

      IF ld_spell-currdec EQ 0.
        IF t_item-trcurr EQ c_idr.
          l_waers = 'RUPIAH'.
          CONCATENATE ld_spell-word l_waers INTO ld_words
            SEPARATED BY space.
        ELSE.
          l_waers = t_item-trcurr.
          CONCATENATE l_waers1 ld_spell-word INTO ld_words
            SEPARATED BY space.
        ENDIF.
      ELSE.
        IF t_item-trcurr EQ c_idr.
          l_waers = 'RUPIAH'.
          CONCATENATE ld_spell-word l_waers INTO ld_words
            SEPARATED BY space.
        ELSE.
          IF ld_spell-decword EQ 'ZERO'.
            CONCATENATE l_waers1 ld_spell-word INTO ld_words
              SEPARATED BY space.
          ELSE.
            CONCATENATE l_waers1 ld_spell-word 'AND' ld_spell-decword
                        'CENTS'
                        INTO ld_words
                        SEPARATED BY space.
          ENDIF.
        ENDIF.
      ENDIF.

      DATA: ld_dpp LIKE d_total-dpplast,
            ld_txt(13).
      ld_dpp = d_total-itamtlast - d_total-itdisclast.
      IF ld_dpp = d_total-dpplast.
        CLEAR d_flag_include_ppn.
      ELSE.
*      d_flag_include_ppn = '(100/110) X'.
*--- iso project 05.09.2002
        WRITE ld_dpp TO ld_txt CURRENCY ft_pkp-waers.
        CONCATENATE '(100/110) X' ' ' ld_txt INTO d_flag_include_ppn.
*---
      ENDIF.

* I.2. Delete Tax if Tarif = 0.
      DELETE ft_tax WHERE tarifxpbm = 0.

* I.3. Checking : is data enough to print, or is it too long?
      DATA ld_subrc LIKE sy-subrc.
****Modified by Rahmadi -- multiple pages
      IF d_mpage IS INITIAL.
        PERFORM f_checking
                TABLES   ft_tax
                USING    ft_pkp-fakturno
                CHANGING ld_subrc.
        IF ld_subrc <> 0.
          IF ld_subrc = 1.
            RAISE data_too_long.
          ELSE.
            RAISE ppnbm_too_long.
          ENDIF.

          ft_error_result-vbeln = ft_pkp-vbeln.
          APPEND ft_error_result.
          CONTINUE.
        ENDIF.
      ENDIF.
****End of modification

* I.4. Add Footer on Item itab
      DATA: ld_text(50),
            ld_position       LIKE c_max_line,
            ld_position_space LIKE c_max_line.

*   I.4.a Add Ex PPNBM
      ld_position = c_max_line + 1.
      IF NOT d_ex_ppnbm IS INITIAL.
        ld_position = ld_position - 1.
        CONCATENATE 'Ex PPNBM   ='
                    d_ex_ppnbm
                    INTO ld_text SEPARATED BY space.

        PERFORM f_add_item
                USING    ld_position
                         ld_text
                         'X'
                CHANGING ld_subrc.
      ENDIF.

* I.5. Get Tax
      DATA: ld_total_tax LIKE zgdtxst0006-fakppnbm,
            ld_counter   TYPE i.
      CLEAR: d_tax1,
             d_tax2,
             d_tax3,
             d_tax4,
             ld_counter,
             ld_total_tax,
             d_total_tax.
      LOOP AT ft_tax WHERE fakturno = ft_pkp-fakturno.
        ADD 1 TO ld_counter.
        CASE ld_counter.
          WHEN 1.
            m_fill_tax 1.
          WHEN 2.
            m_fill_tax 2.
          WHEN 3.
            m_fill_tax 3.
          WHEN 4.
            m_fill_tax 4.
        ENDCASE.
      ENDLOOP.
      IF NOT ld_total_tax IS INITIAL.
        WRITE ld_total_tax TO d_total_tax CURRENCY ft_pkp-waers.
      ENDIF.

      CONCATENATE d_lyt_pkp-pkpaddrs1(60) d_lyt_pkp-pkpcity
                  INTO d_pkp_address_long
                  SEPARATED BY space.

      CONCATENATE d_lyt_customer-addrs1(60) d_lyt_customer-city
                  INTO d_cust_address_long
                  SEPARATED BY space.
****end of getting Total & Header info

******************* SMARTFORMS CALL ***********************************
*break bcrmd.
*-------One Spool
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
********to cater multiple printing
        d_ctrl_param-no_close = space.
      ENDAT.

******call the generated function module of the form
      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          fi_display         = fi_display
          fi_report          = fi_report
          fi_checking_only   = fi_checking_only
          fi_nonlives        = fi_nonlives
          fi_forex           = ld_forex
          fi_mpage           = fi_mpage
          fi_printer         = fi_printer
          fi_pkp             = d_lyt_pkp
          fi_customer        = d_lyt_customer
          fi_signature       = d_lyt_signature
          fi_total           = d_lyt_total
          fi_pkp_date        = d_pkp_date_word
          fi_sign_date       = d_sign_date_word
          fi_tax1            = d_tax1
          fi_tax2            = d_tax2
          fi_tax3            = d_tax3
          fi_tax4            = d_tax4
          fi_total_tax       = d_total_tax
          fi_add_long        = d_pkp_address_long
          fi_cust_long       = d_cust_address_long
          fi_pay             = ld_pay
          fi_pay_f           = ld_pay_f
          fi_words           = ld_words
          fi_curr            = t_item-trcurr
          fi_rate            = t_item-rate_tax
          fi_bukrs           = fi_bukrs
        IMPORTING
          job_output_info    = d_job_output_info
        TABLES
          ft_item            = t_item
          ft_error_result    = ft_error_result
          ft_page            = t_page
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          my_exception       = 5
          OTHERS             = 6.
      CASE sy-subrc.
        WHEN 0.
**********Printed indicator
*          IF NOT d_job_output_info-spoolids IS INITIAL.
*            PERFORM f_save_print_counter.
*          ENDIF.
        WHEN OTHERS.
          MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDCASE.

*-----One Spool
      d_ctrl_param-no_open = 'X'.

******************* END OF SMARTFORMS CALL *****************************

    ENDLOOP.
  ENDIF.


ENDFUNCTION.
