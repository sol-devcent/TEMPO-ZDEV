FUNCTION-POOL zgdtxfg001.                   "MESSAGE-ID ..

CONSTANTS:
   c_tdform         TYPE tdform VALUE 'ZGDTXF0003_01',
   c_textelement(10)            VALUE 'WRITE',
   c_len_currency    TYPE i     VALUE 20,
   c_max_line        TYPE i     VALUE 15,
   c_max_item        TYPE i     VALUE 12,  "added by Rahmadi
   c_pos_namajabatan TYPE i     VALUE 70,
   c_spart_unit(2)              VALUE '01',
   c_spart_service(2)           VALUE '03',
   c_spart_usedcar(2)           VALUE '04',
   c_spart_truck(2)             VALUE '05',
   c_idr LIKE zgdtxst0003-trcurr  VALUE 'IDR'.

DATA: d_itemno TYPE i,
      d_itemcount TYPE i,
      d_harga_rp(20),
      d_harga_vls(15),
      d_mpage,
      d_line TYPE i,
      d_sign_date_word(20),
      d_pkp_date_word(20),
      d_cust_address_long(65),
      d_pkp_address_long(65).

DATA: BEGIN OF d_lyt_pkp.
***changed in Tempo to accomodate smartforms
        INCLUDE STRUCTURE zgdtxst0001x.
*        INCLUDE STRUCTURE zgdtxst0001.
*DATA:   pkpaddrs3(80),
DATA  END OF d_lyt_pkp.

DATA: BEGIN OF d_lyt_customer.
***changed in Tempo to accomodate smartforms
        INCLUDE STRUCTURE zgdtxst0002x.
*        INCLUDE STRUCTURE zgdtxst0002.
*DATA:   addrs3(80),
DATA  END OF d_lyt_customer.

DATA: d_total LIKE zgdtxst0004,
      d_dpp_f LIKE zgdtxst0003-dpp_f,
      d_ppn_f LIKE zgdtxst0003-ppn_f.

DATA:BEGIN OF d_lyt_total OCCURS 0. "Copy from ZGDTXst0004
***changed in Tempo to accomodate smartforms
        INCLUDE STRUCTURE zgdtxst0004x.
*        itamtlast(c_len_currency),
*        itdisclast(c_len_currency),
*        dpplast(c_len_currency),
*        fakppn(c_len_currency),
*        fakxppnbm(c_len_currency),
*        dpp_f(c_len_currency),
*        ppn_f(c_len_currency),
DATA      END OF d_lyt_total.

DATA: d_lyt_signature TYPE  zgdtxst0005,
      d_ex_ppnbm(c_len_currency).

DATA: BEGIN OF t_page OCCURS 0.
***changed in Tempo to accomodate Smartforms
        INCLUDE STRUCTURE zgdtxst0009x.
*        fakturno LIKE zgdtxst0003-fakturno,
*        page(3) TYPE n,
*        itamtlast LIKE zgdtxst0003-itamtlast,
*        itcurr LIKE zgdtxst0003-trcurr,
*        line TYPE i,
DATA  END OF t_page.

DATA: BEGIN OF t_item OCCURS 0.
***changed in Tempo to accomodate Smartforms
        INCLUDE STRUCTURE zgdtxst0010x.
*        linenum(3),
*        item     LIKE zgdtxst0003-item,
*        trcurr   LIKE zgdtxst0003-trcurr,
*        rate_tax(15),
*        harga_rp(20),
*        harga_vls(15),
DATA  END OF t_item.

TYPES BEGIN OF type_tax.  "Copy from ZGDTXst0006
***changed for tempo
TYPES:   dpplast(c_len_currency),
         fakppnbm(c_len_currency),
         tarifxpbm(3).
*        INCLUDE STRUCTURE zgdtxst0006x.
***end of change
TYPES END OF type_tax.
DATA: d_tax1 TYPE type_tax,
      d_tax2 TYPE type_tax,
      d_tax3 TYPE type_tax,
      d_tax4 TYPE type_tax,
      d_total_tax(c_len_currency).

DATA: t_pagewindows TYPE STANDARD TABLE OF itcth WITH HEADER LINE,
      t_elements    TYPE STANDARD TABLE OF itcce WITH HEADER LINE.

DATA: t_00001 TYPE STANDARD TABLE OF zgdtxst0001 WITH HEADER LINE,
      t_00002 TYPE STANDARD TABLE OF zgdtxst0002 WITH HEADER LINE,
      t_00003 TYPE STANDARD TABLE OF zgdtxst0003 WITH HEADER LINE,
      t_00004 TYPE STANDARD TABLE OF zgdtxst0004 WITH HEADER LINE,
      t_00005 TYPE STANDARD TABLE OF zgdtxst0005 WITH HEADER LINE,
      t_00006 TYPE STANDARD TABLE OF zgdtxst0006 WITH HEADER LINE.

DATA: d_flag_include_ppn(30).

DATA  d_subtotal_text(10) VALUE 'Sub total'.

***added for tempo
**For Smartforms
DATA: p_tdform LIKE ssfscreen-fname VALUE 'ZGDTXF0001_01',
      p_dest      LIKE tsp03-padest,
      p_disp      LIKE ssfctrlop-preview VALUE 'X'.
***end of Tempo addition


DEFINE m_fill_tax.
  write ft_tax-dpplast  currency ft_pkp-waers to d_tax&1-dpplast.
  write ft_tax-fakppnbm currency ft_pkp-waers to d_tax&1-fakppnbm.
  write ft_tax-tarifxpbm                      to d_tax&1-tarifxpbm
                                                 no-zero.
  add ft_tax-fakppnbm to ld_total_tax.
END-OF-DEFINITION.


DEFINE m_write_tarif_ppnbm.
  write :/5(04) d_tax&1-tarifxpbm no-zero,
           (03) '%',
           (03) 'Rp.',
           (20) d_tax&1-dpplast,
           (06) '  Rp.',
           (20) d_tax&1-fakppnbm.
END-OF-DEFINITION.

*---------------------------------------------------------------------*
*       FORM f_checking                                               *
*---------------------------------------------------------------------*
FORM f_checking
     TABLES   ft_tax STRUCTURE zgdtxst0006
     USING    fu_fakturno
     CHANGING fc_subrc LIKE sy-subrc.

  DATA: ld_line    TYPE i,
        ld_addline TYPE i,
        ld_counter TYPE i.
  CLEAR fc_subrc.
  DESCRIBE TABLE t_item LINES ld_line.

  IF NOT d_ex_ppnbm IS INITIAL.
    ADD 1 TO ld_addline.
  ENDIF.
  ADD 2 TO ld_addline.       "Add Invoice No and Space

  ld_line = ld_line + ld_addline.

  IF ld_line > c_max_line.
    fc_subrc = 1.
*   RAISE data_too_long.
    EXIT.
  ENDIF.

* Check tarif ppnbm in this faktur pajak can not be more than 4 line!
  LOOP AT ft_tax WHERE fakturno = fu_fakturno.
    ADD 1 TO ld_counter.
  ENDLOOP.
  IF ld_counter > 4.
    fc_subrc = 2.
*   RAISE ppnbm_too_long.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_write_data                                             *
*---------------------------------------------------------------------*
FORM f_write_data
     USING fu_display TYPE c
           fu_report  TYPE c
           fu_forex    "added by Rahmadi
           fu_line     "added by Rahmadi
           fu_printer. "added for Tempo

*  DATA: ld_printer TYPE itcta-tdprinter.
  DATA  ld_tabix LIKE sy-tabix.
  DATA  ld_prt LIKE itcta-tdprinter.

  d_line = fu_line.

***added by Rahmadi
  CONCATENATE d_lyt_pkp-pkpaddrs1(60) d_lyt_pkp-pkpcity
              INTO d_pkp_address_long
              SEPARATED BY space.

  CONCATENATE d_lyt_customer-addrs1(60) d_lyt_customer-city
              INTO d_cust_address_long
              SEPARATED BY space.
***end of addition

* Preview Report
  IF fu_report = 'X'.
    NEW-PAGE LINE-SIZE 100.
*-- Header
    PERFORM f_header_tax_pkp.
    PERFORM f_header_tax_pjkp.

*-- Body
    CLEAR: d_itemno, d_itemcount.
    PERFORM f_body_tax USING fu_forex.

*-- Footer
    PERFORM f_footer_total.
    PERFORM f_footer_tgl.
    PERFORM f_footer_ppnbm.
    PERFORM f_footer_nama_jbt.

* Print Sapscript
  ELSE.

* 1. Get windows from sapscript
    IF t_pagewindows[] IS INITIAL.
      CALL FUNCTION 'LOAD_FORM'
           EXPORTING
                form         = c_tdform
                language     = sy-langu
                printer      = 'SAPWIN'
*                printer      = ld_prt
           TABLES
                page_windows = t_pagewindows
                elements     = t_elements.
      CHECK sy-subrc     = 0.
      DELETE t_pagewindows WHERE tdwindow = 'MAIN'.
      SORT: t_pagewindows BY tdwtop,
            t_elements    BY tdwindow.
    ENDIF.

* 2. Open Form & Initialization
    PERFORM f_lyt_open_form
            USING c_tdform fu_display fu_display.

****Added by Rahmadi
* 2a. Write Header/Footer window
    READ TABLE t_item INDEX 1.
    LOOP AT t_pagewindows.
      CHECK t_pagewindows-tdwindow <> 'MAIN' AND
            t_pagewindows-tdwindow <> 'PAJAK' AND
            t_pagewindows-tdwindow <> 'TOTAL'.
      CLEAR t_elements.
      READ TABLE t_elements WITH KEY tdwindow = t_pagewindows-tdwindow
           BINARY SEARCH.
      PERFORM f_lyt_write_form
              USING t_elements-tdevent
                    t_pagewindows-tdwindow.
    ENDLOOP.
****End of addition

* 3. Write Main window for Item table
    CLEAR: t_elements, d_itemno, d_itemcount.
    READ TABLE t_elements WITH KEY tdwindow = 'MAIN'
         BINARY SEARCH.
    LOOP AT t_item.
******Added by Rahmadi --- multiple pages
      CLEAR t_page.
      IF NOT d_mpage IS INITIAL.
        d_itemno = d_itemno + 1.
        d_itemcount = d_itemcount + 1.
        IF ( d_itemno = c_max_item OR
             d_itemcount = d_line )   AND
             d_line > c_max_item.
          READ TABLE t_page WITH KEY fakturno = d_lyt_pkp-fakturno.
          ld_tabix = sy-tabix.
          IF sy-subrc <> 0.
            CLEAR t_page.
          ENDIF.
          IF t_item-trcurr NE c_idr.
           WRITE t_page-itamtlast CURRENCY t_page-itcurr TO d_harga_vls.
          ELSE.
            WRITE t_page-itamtlast CURRENCY t_page-itcurr TO d_harga_rp.
          ENDIF.
        ENDIF.
      ENDIF.
******End of addition
      PERFORM f_lyt_write_form
              USING t_elements-tdevent 'MAIN'.

******Added by Rahmadi --- multiple pages
      IF ( d_itemno = c_max_item OR
           d_itemcount = d_line )   AND
           d_line > c_max_item.
        DELETE t_page INDEX ld_tabix.
        CLEAR: d_itemno, d_harga_rp, d_harga_vls.
      ENDIF.
******End of addition
    ENDLOOP.

* 4. Write Other window
    READ TABLE t_item INDEX 1.
    LOOP AT t_pagewindows.
      CHECK t_pagewindows-tdwindow = 'PAJAK' OR
            t_pagewindows-tdwindow = 'TOTAL'.     "modified by Rahmadi
      CLEAR t_elements.
      READ TABLE t_elements WITH KEY tdwindow = t_pagewindows-tdwindow
           BINARY SEARCH.
      PERFORM f_lyt_write_form
              USING t_elements-tdevent
                    t_pagewindows-tdwindow.
    ENDLOOP.

* 5. Close Form
    PERFORM f_lyt_close_form.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_add_item                                               *
*---------------------------------------------------------------------*
FORM f_add_item
     USING fu_position       TYPE i
           fu_text           TYPE c
           fu_flag_overwrite TYPE c
     CHANGING fc_subrc       LIKE sy-subrc.

  DATA: ld_line     TYPE i,
        ld_position TYPE i.

  CLEAR fc_subrc.
  DESCRIBE TABLE t_item LINES ld_line.

  IF ld_line >= fu_position.
    CLEAR t_item.
    READ TABLE t_item INDEX fu_position.
    IF t_item IS INITIAL OR fu_flag_overwrite = 'X'.
      CLEAR t_item.
      t_item-item = fu_text.
      MODIFY t_item INDEX fu_position.
    ELSE.
      fc_subrc = 4.
    ENDIF.
  ELSE.
    ld_position = fu_position - 1.
    CLEAR t_item.
    WHILE ld_line < ld_position.
      APPEND t_item.
      ADD 1 TO ld_line.
    ENDWHILE.

    t_item-item = fu_text.
    APPEND t_item.
  ENDIF.
ENDFORM.

***************************** PREVIEW PART *****************************

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_TAX_PKP
*&---------------------------------------------------------------------*
FORM f_header_tax_pkp.
  ULINE.

***changed for Tempo
*  WRITE:/(85)'F A K T U R    P A J A K    S T A N D A R' CENTERED.
  WRITE:/(85)'FAKTUR PENJUALAN/FAKTUR PAJAK STANDAR' CENTERED.
***end of Tempo changes

  IF d_lyt_pkp-faktur_type = 'G'.
    WRITE: '(Gabungan)'.
  ENDIF.
  ULINE.
  WRITE:/ 'Kode dan Nomer Seri Faktur Pajak: ',
          d_lyt_pkp-fakturno RIGHT-JUSTIFIED,
*****change request 13/11/2003
*          90 d_lyt_customer-kunnr.
          90 d_lyt_customer-kunrg.
*****end of change request
  ULINE.

  WRITE:/  'Pengusaha Kena Pajak'.
*  IF d_lyt_pkp-faktur_type = 'G'.
*    WRITE: '                (Gabungan)'.
*  ENDIF.
  WRITE:
        /(24) 'N a m a                :', d_lyt_pkp-pkpname,
***modified by Rahmadi
*        /(24) 'A l a m a t            :', d_lyt_pkp-pkpaddrs1(60),
*        /(24) '                       :', d_lyt_pkp-pkpaddrs3(60),
        /(24) 'A l a m a t            :', d_pkp_address_long,
***end of modification
        /(24) 'N.P.W.P                :', d_lyt_pkp-pkpnpwp,
***MODIFIED BY Rahmadi
*        /(24) 'Tanggal Pengukuhan PKP :', d_lyt_pkp-pkpkuh.
        /(24) 'Tanggal Pengukuhan PKP :', d_pkp_date_word.
***end of modification
ENDFORM.                    " F_HEADER_TAX_PKP


*&---------------------------------------------------------------------*
*&      Form  F_HEADER_TAX_PJKP
*&---------------------------------------------------------------------*
FORM f_header_tax_pjkp.

  ULINE.
  WRITE:/     'Pembeli Barang Kena Pajak/Penerima Jasa Kena Pajak',
        /(24) 'N a m a                :', d_lyt_customer-name.
*        /     '                        ', d_lyt_customer-name2.
*  SKIP.
***modified by Rahmadi
  WRITE : /(24) 'A l a m a t            :', d_lyt_customer-addrs1(60),
          /(24) '                       :', d_lyt_customer-addrs3(60),
*  WRITE : /(24) 'A l a m a t            :', d_cust_address_long,
***end of modification
          /(24) 'N.P.W.P                :', d_lyt_customer-npwp.
ENDFORM.                    " F_HEADER_TAX_PJKP

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_MAIN_TABLE
*&---------------------------------------------------------------------*
FORM f_header_main_table USING fu_forex. "added by Rahmadi
  ULINE.
  WRITE:/2(04) 'No.' CENTERED,
          (52) 'Nama Barang Kena Pajak / Jasa Kena Pajak' CENTERED.

***Modified by Rahmadi
  IF fu_forex IS INITIAL.
    WRITE (16) ' '.
  ENDIF.

  IF fu_forex IS INITIAL.
    WRITE:  (23) 'Hrg Jual/Pgtn/U.Mk/' RIGHT-JUSTIFIED.
  ELSE.
    WRITE:  (40) 'Harga Jual/Penggantian/Uang Muka/Termijn' CENTERED.
  ENDIF.
***End of modification

  WRITE:01  sy-vline,
        06  sy-vline.
  IF fu_forex IS INITIAL.
    WRITE:  79  sy-vline.
  ELSE.
    WRITE:  59  sy-vline.
  ENDIF.
  WRITE 100 sy-vline.

  WRITE:/2(04) 'Urut' CENTERED,
          (52) ' '.


***Modified by Rahmadi
  IF fu_forex = 'X'.
    WRITE: (19) 'Valas *)' CENTERED.
    WRITE: (19) 'Rp' CENTERED.
  ELSE.
    WRITE: (19) ' ' CENTERED.
    WRITE: (19) 'Trmjn (Rp.)' CENTERED.
  ENDIF.
*** End of modification

  PERFORM f_body_vline USING fu_forex.
  ULINE.
ENDFORM.                    " F_HEADER_MAIN_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_BODY_TAX
*&---------------------------------------------------------------------*
FORM f_body_tax USING fu_forex.    "added by Rahmadi
  PERFORM f_header_main_table USING fu_forex.
  LOOP AT t_item.

****Added by Rahmadi -- multiple pages
    IF NOT t_item-item IS INITIAL AND
       t_item-item <> d_subtotal_text.
      d_itemno = d_itemno + 1.
      d_itemcount = d_itemcount + 1.
    ENDIF.
****End of addition

    WRITE:/2(04) t_item-linenum NO-ZERO.

****Modified by Rahmadi
    IF fu_forex = 'X'.
      WRITE: (52) t_item-item.
    ELSE.
      WRITE: (70) t_item-item.
    ENDIF.
****End of modification

    IF fu_forex = 'X'.
      IF t_item-trcurr NE c_idr.
        WRITE : (19) t_item-harga_vls.
      ELSE.
        WRITE : (19) ' ',
                (19) t_item-harga_rp.
      ENDIF.
    ELSE.
      WRITE:   (19) t_item-harga_rp.
    ENDIF.
    PERFORM f_body_vline USING fu_forex.

**** Added by Rahmadi -- multiple pages
    IF NOT d_mpage IS INITIAL.
      IF t_item-item = d_subtotal_text.
        PERFORM f_new_page USING fu_forex.
      ENDIF.
    ENDIF.
**** End of addition

  ENDLOOP.
  ULINE.
ENDFORM.                    " F_BODY_TAX

*&---------------------------------------------------------------------*
*&      Form  F_BODY_VLINE
*&---------------------------------------------------------------------*
FORM f_body_vline USING fu_forex.  "added by Rahmadi
  WRITE:01  sy-vline,
        06  sy-vline.

  IF fu_forex = 'X'.
    WRITE:  59  sy-vline.
  ENDIF.
  WRITE:   79  sy-vline,
          100 sy-vline.
ENDFORM.                    " F_BODY_VLINE

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_TAX1
*&---------------------------------------------------------------------*
FORM f_footer_total.
  READ TABLE t_item INDEX 1.
  IF t_item-trcurr NE c_idr.
    WRITE:/       'Harga Jual/Penggantian/Uang Muka/Termijn *)',
             56(20) d_lyt_total-itamtlast.
    ULINE.

    WRITE:/       'Dikurangi Potongan Harga',
           56 d_lyt_total-itdisclast.
  ELSE.
    WRITE:/       'Harga Jual/Penggantian/Uang Muka/Termijn *)',
           80(20) d_lyt_total-itamtlast.
    ULINE.

    WRITE:/       'Dikurangi Potongan Harga',
           80 d_lyt_total-itdisclast.
  ENDIF.
  ULINE.

  WRITE:/       'Dikurangi Uang Muka yang telah diterima'.
  WRITE         80 d_lyt_total-uangmuka.
  ULINE.

  DATA ld_dpp_text(50).
  IF t_item-trcurr NE c_idr.
    ld_dpp_text = 'Dasar Pengenaan Pajak'.
    WRITE:/       ld_dpp_text,
           56(20) d_lyt_total-dpp_f,
           80(20) d_lyt_total-dpplast.
  ELSE.
    CONCATENATE 'Dasar Pengenaan Pajak'
                d_flag_include_ppn
                INTO ld_dpp_text
                SEPARATED BY space.
    WRITE:/       ld_dpp_text,
           80(20) d_lyt_total-dpplast.
  ENDIF.
  ULINE.

  WRITE:/       'PPN = 10% x Dasar Pengenaan Pajak'.
  IF t_item-trcurr NE c_idr.
    WRITE : 56(20) d_lyt_total-ppn_f,
            80(20) d_lyt_total-fakppn.
  ELSE.
    WRITE : 80(20) d_lyt_total-fakppn.
  ENDIF.
  ULINE.

  SKIP.

ENDFORM.                    " F_FOOTER_TAX1

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_TGL
*&---------------------------------------------------------------------*
FORM f_footer_tgl.
  DATA ld_pos TYPE i.
  ld_pos = c_pos_namajabatan - 10.
  WRITE AT :/ld_pos  d_lyt_signature-city,
             70 ', tgl.'.
***modified by Rahmadi
*  WRITE      d_lyt_signature-fakdat.
  WRITE d_sign_date_word.
***end of modification
ENDFORM.                    " F_FOOTER_TGL


*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_PPNBM
*&---------------------------------------------------------------------*
FORM f_footer_ppnbm.
  WRITE:/   'Pajak Penjualan Atas Barang Mewah'.

  WRITE:/5(08) 'TARIF',
          (26) 'DPP',
          (21) 'PPn BM'.

  m_write_tarif_ppnbm 1.
  m_write_tarif_ppnbm 2.
  m_write_tarif_ppnbm 3.
  m_write_tarif_ppnbm 4.

  WRITE :/5(08) 'JUMLAH',
           (03) ' ',
           (20) ' ',
           (06) '  Rp.',
           (20) d_total_tax.

ENDFORM.                    " F_FOOTER_PPNBM

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_NAMA_JBT
*&---------------------------------------------------------------------*
FORM f_footer_nama_jbt.
  WRITE AT :/c_pos_namajabatan  'Nama    : '.
  WRITE    : d_lyt_signature-petugas(20).
  WRITE AT :/c_pos_namajabatan  'Jabatan : '.
  WRITE    : d_lyt_signature-jabat.
  IF t_item-trcurr NE c_idr.
    WRITE :/5 'Catatan : '.
    WRITE AT :/5(10) sy-uline.
    WRITE : /5 'Kurs : Rp ',
               t_item-rate_tax, ' / ',
               '1 ', t_item-trcurr.
  ENDIF.
  ULINE.
ENDFORM.                    " F_FOOTER_NAMA_JBT

*&---------------------------------------------------------------------*
*&      Form  F_ADD_TEXT_1_AND_2
*&---------------------------------------------------------------------*
FORM f_add_text_1_and_2
     USING    fu_text1
              fu_text2
     CHANGING fc_current_position LIKE c_max_line.

  DATA: ld_position       LIKE c_max_line,
        ld_position_space LIKE c_max_line,
        ld_subrc          LIKE sy-subrc.

  ld_position = fc_current_position.

* 1. INSERT TEXT 1 AND TEXT 2
  IF NOT fu_text2 IS INITIAL.
*   Try to Test, is space can be added in above line of pkp-text?
*   Because pkp-text is optional, if there is no space anymore in item,
*   then do not add pkp-text to item
    ld_position_space = ld_position - 3.
    PERFORM f_add_item
            USING    ld_position_space
                     space
                     space
            CHANGING ld_subrc.
    IF ld_subrc = 0.
      ld_position = ld_position - 1.
      PERFORM f_add_item
              USING    ld_position
                       fu_text2
                       space
              CHANGING ld_subrc.
      ld_position = ld_position - 1.
      PERFORM f_add_item
              USING    ld_position
                       fu_text1
                       space
              CHANGING ld_subrc.
    ENDIF.

* 2. INSERT TEXT 1 ONLY IF TEXT 2 IS BLANK
  ELSEIF NOT fu_text1 IS INITIAL.
*   Try to Test, is space can be added in above line of pkp-text?
*   Because pkp-text is optional, if there is no space anymore in item,
*   then do not add pkp-text to item
    ld_position_space = ld_position - 2.
    PERFORM f_add_item
            USING    ld_position_space
                     space
                     space
            CHANGING ld_subrc.
    IF ld_subrc = 0.
      ld_position = ld_position - 1.
      PERFORM f_add_item
              USING    ld_position
                       fu_text1
                       space
              CHANGING ld_subrc.
    ENDIF.
  ENDIF.


  fc_current_position = ld_position.
ENDFORM.                    " F_ADD_TEXT_1_AND_2
