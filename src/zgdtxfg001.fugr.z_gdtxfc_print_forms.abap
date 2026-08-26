FUNCTION z_gdtxfc_print_forms.
*"----------------------------------------------------------------------
*"*"Local interface:
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
  DATA ld_line TYPE i.
  DATA ld_item TYPE i.
  DATA ld_count TYPE i.
  DATA ld_langu LIKE sy-langu.

  DATA lt_desc LIKE ft_item OCCURS 0 WITH HEADER LINE.

  DATA ld_pkp LIKE ft_pkp.
  DATA ld_tax LIKE ft_tax.

***added by Rahmadi
  d_mpage = fi_mpage.
  d_lyt_tddst = fi_printer.
***end of addition

  REFRESH: ft_error_result, t_page.
  SORT: ft_customer  BY fakturno,
        ft_signature BY fakturno.

* I. Create New Itab for Item
* I.1. Get Master Data
  LOOP AT ft_pkp.
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

***added by Rahmadi
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
***end of addition

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

***added by Rahmadi
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
***end of addition

    DATA: ld_ex_ppnbm LIKE zgdtxst0003-xppnbmlast,
          ld_kwert LIKE ft_item-rate_tax.
    REFRESH t_item.
    CLEAR:  d_lyt_total,
            ld_ex_ppnbm,
            d_ex_ppnbm,
            t_page.

****Added by Rahmadi -- multiple pages
    lt_desc[] = ft_item[].
    DELETE lt_desc WHERE fakturno <> ft_pkp-fakturno.
    DESCRIBE TABLE lt_desc LINES ld_line.
****End of addition

    LOOP AT ft_item WHERE fakturno = ft_pkp-fakturno.
      WRITE ft_item-linenum TO t_item-linenum NO-ZERO RIGHT-JUSTIFIED.
      t_item-item     = ft_item-item.
      t_item-trcurr   = ft_item-trcurr.
      IF ft_item-trcurr IS INITIAL.
        t_item-trcurr = c_idr.
      ENDIF.
      IF NOT t_item-linenum = 0.
        IF t_item-trcurr NE c_idr.  "For Non IDR
          WRITE ft_item-itamt_f TO t_item-harga_vls
                CURRENCY t_item-trcurr.

*         multiply it with 100 because in created program, it's
*         divided by 100 (hardcoded) for every rate tax.
          ld_kwert = ft_item-rate_tax * 100.
          WRITE ld_kwert TO t_item-rate_tax.
*                CURRENCY t_item-trcurr.
        ELSE.
          WRITE ft_item-itamtlast TO t_item-harga_rp
                 CURRENCY ft_pkp-waers.
        ENDIF.
      ELSE.
        CLEAR : t_item-harga_rp, t_item-harga_vls.
      ENDIF.

      APPEND t_item.
      ADD ft_item-xppnbmlast TO ld_ex_ppnbm.

*------ calculate total
      d_total-fakturno = ft_item-fakturno.
      IF t_item-trcurr NE c_idr.
        ADD ft_item-itamt_f  TO d_total-itamtlast.
        ADD ft_item-itdisc_f TO d_total-itdisclast.
        ADD ft_item-dpp_f TO d_dpp_f.
        ADD ft_item-ppn_f TO d_ppn_f.
      ELSE.
        ADD ft_item-itamtlast  TO d_total-itamtlast.
        ADD ft_item-itdisclast TO d_total-itdisclast.
      ENDIF.
      ADD ft_item-dpplast    TO d_total-dpplast.
      ADD ft_item-ppnlast    TO d_total-fakppn.

******Added by Rahmadi  -- multiple pages
      IF NOT d_mpage IS INITIAL.
        ld_item = ld_item + 1.
        ld_count = ld_count + 1.
        IF t_item-trcurr NE c_idr.
          ADD ft_item-itamt_f TO ld_subtotal.
        ELSE.
          ADD ft_item-itamtlast TO ld_subtotal.
        ENDIF.
        IF ld_item = c_max_item OR
           ld_count = ld_line.

          t_page-fakturno = ft_item-fakturno.
          t_page-page = t_page-page + 1.
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
              WRITE ld_subtotal TO t_item-harga_vls
                     CURRENCY ft_pkp-waers.
            ELSE.
              WRITE ld_subtotal TO t_item-harga_rp
                     CURRENCY ft_pkp-waers.
            ENDIF.
            APPEND t_item.
          ENDIF.

          CLEAR: ld_subtotal, ld_item, t_page.
        ENDIF.
      ENDIF.
******End of addition

    ENDLOOP.

    IF NOT d_mpage IS INITIAL.
      CLEAR ld_count.
      SORT t_page BY fakturno page.
    ENDIF.
****    d_lyt_total     = d_total.
****    line diatas diganti dengan line dibawa karna proyek uni code 09-01-20202
    MOVE-CORRESPONDING d_total to d_lyt_total.
    IF t_item-trcurr NE c_idr.
      WRITE d_total-itamtlast  TO d_lyt_total-itamtlast
                               CURRENCY t_item-trcurr.
      WRITE d_total-itdisclast TO d_lyt_total-itdisclast
                               CURRENCY t_item-trcurr.
      WRITE d_dpp_f            TO d_lyt_total-dpp_f
                               CURRENCY t_item-trcurr.
      WRITE d_ppn_f            TO d_lyt_total-ppn_f
                               CURRENCY t_item-trcurr.
    ELSE.
      WRITE d_total-itamtlast  CURRENCY ft_pkp-waers
            TO d_lyt_total-itamtlast.
      WRITE d_total-itdisclast CURRENCY ft_pkp-waers
            TO d_lyt_total-itdisclast.
    ENDIF.

    "Uang Muka Perubahan terjadi ditahun 2016 dan tidak naik ke p01 dikoreksi tgl 15 juli 2020
    "by SUK diskusi dengan abun
***    CLEAR ld_tax.
***    READ TABLE ft_tax INTO ld_tax INDEX 1.
***    IF ft_pkp-vbeln+2(4) EQ '8160'.
***      d_total-fakdp = ld_tax-fakdp.
***      d_total-dpplast = d_total-dpplast - d_total-fakdp.
***      d_total-fakppn = d_total-dpplast / 10.
***      WRITE d_total-fakdp    CURRENCY ft_pkp-waers
***            TO d_lyt_total-uangmuka.
***    ENDIF.

    WRITE d_total-dpplast    CURRENCY ft_pkp-waers
          TO d_lyt_total-dpplast.

*    IF NOT fi_nonlive IS INITIAL.
    IF ft_pkp-rectype = 'N'.          "N = Non Live
      d_total-fakppn = d_total-dpplast / 10.
    ENDIF.
    WRITE d_total-fakppn     CURRENCY ft_pkp-waers
          TO d_lyt_total-fakppn.

    IF NOT ld_ex_ppnbm IS INITIAL.
      WRITE ld_ex_ppnbm CURRENCY ft_pkp-waers TO d_ex_ppnbm
            LEFT-JUSTIFIED.
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

*   If used car, the tax is only 1%, not 10%.
*   So we divide dpp by 10 (ppn is already multiply with 1%), and
*   give notes while printing with '0,1 X'
    IF d_lyt_pkp-spart = c_spart_usedcar.
      CONCATENATE d_flag_include_ppn '0,1 X'
                  INTO d_flag_include_ppn
                  SEPARATED BY space.
      d_total-dpplast = d_total-dpplast / 10.
      WRITE d_total-dpplast CURRENCY ft_pkp-waers
            TO d_lyt_total-dpplast.
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

**** Comment: Rahmadi: NEED TO ADD USER EXIT FOR CUSTOM LOGIC
**   I.4.b Add Invoice No
*    ld_position = ld_position - 1.
*    IF ft_pkp-spart EQ c_spart_service.
*      CONCATENATE 'Kwitansi No ='
*                  ft_pkp-vbeln
*                  INTO ld_text SEPARATED BY space.
*
*    ELSE.
*      CONCATENATE 'Invoice No ='
*                  ft_pkp-vbeln
*                  INTO ld_text SEPARATED BY space.
*    ENDIF.
*
*    IF ft_pkp-spart EQ c_spart_unit OR ft_pkp-spart EQ c_spart_truck.
*      IF NOT ( ft_pkp-kwitansi IS INITIAL     OR
**               ft_pkp-kwitansi+5(10) = ft_pkp-vbeln+7(10) ).
*               ft_pkp-kwitansi(10) = ft_pkp-vbeln+7(10) ).
*        CONCATENATE ld_text '(' ft_pkp-kwitansi ')'
*                    INTO ld_text.
*      ENDIF.
*    ENDIF.

*    PERFORM f_add_item
*            USING    ld_position
*                     ld_text
*                     'X'
*            CHANGING ld_subrc.
*
**   I.4.c Add Text 1 and 2
*    PERFORM f_add_text_1_and_2
*            USING    ft_pkp-text1
*                     ft_pkp-text2
*            CHANGING ld_position.
*
**   I.4.d Add Space
*    ld_position = ld_position - 1.
*    PERFORM f_add_item
*            USING    ld_position
*                     space
*                     'X'
*            CHANGING ld_subrc.
**** End of comment

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

* II. Write Data
    IF fi_checking_only = space.
      PERFORM f_write_data
              USING fi_display
                    fi_report
                    fi_forex     "added by Rahmadi
                    ld_line      "added by Rahmadi
                    fi_printer.  "added for Tempo
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
