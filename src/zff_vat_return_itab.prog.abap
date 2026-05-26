***INCLUDE ZFF_VAT_RETURN_ITAB .

TABLES: lfa1,             " Vendor Master (General Section)
        bsik,             " Accounting: Secondary Index for Vendors
        bsis,             " Accounting: Secondary Index for G/L Accounts
        rbkp,             " Document Header: Invoice Receipt
        rseg,             " Document Item: Incoming Invoice
        bkpf,             " Accounting Document Header
        makt,             " Material Descriptions
        rbma.

TABLES: nast.

TYPES: BEGIN OF ta_itab1,
        bukrs LIKE bsis-bukrs, "Company Code
        hkont LIKE bsis-hkont, "General ledger account
        gjahr LIKE bsis-gjahr, "Fiscal year
        belnr LIKE bsis-belnr, "Accounting document number
        augbl LIKE bsis-augbl, "Document Number of the Clearing Document
        budat LIKE bsis-budat, "Posting date in the document
        bldat LIKE bsis-bldat, "Document date in document
        waers LIKE bsis-waers, "Currency Key
        xblnr LIKE bsis-xblnr, "Reference document number
        blart LIKE bsis-blart, "Document type
        monat LIKE bsis-monat, "Fiscal period
        shkzg LIKE bsis-shkzg, "Debit/credit indicator
        bschl LIKE bsis-bschl, "Posting key
        mwskz LIKE bsis-mwskz, "Tax on sales/purchases code
        dmbtr LIKE bsis-dmbtr, "Amount in local currency
        rbeln LIKE rbkp-belnr, "Document number of an invoice document
        zfbdt LIKE bsis-zfbdt, "Baseline date for due date calculation
        sgtxt LIKE bsis-sgtxt, "Item Text
        lifnr LIKE bsik-lifnr, "Account number of vendor or creditor
        zuonr LIKE bsik-zuonr, "Assignment number
        gsber LIKE bsik-gsber, "Business Area
        awkey LIKE bkpf-awkey, "Object key
        name1 LIKE lfa1-name1,                              "Name 1
        name2 LIKE lfa1-name2,                              "Name 2
        stras(70), "House number and street
        ort01 LIKE lfa1-ort01, "City
        stcd1 LIKE lfa1-stcd1, "Tax number 1
        stceg LIKE lfa1-stceg, "VAT registration number
        stenr LIKE lfa1-stenr, "Tanggal Pengukuhan
        zuonr1 LIKE rbkp-zuonr,
        bktxt LIKE rbkp-bktxt,
       END OF ta_itab1.

TYPES: BEGIN OF ta_itab2,
        gjahr LIKE rseg-gjahr, "Fiscal year
        belnr LIKE rseg-belnr, "Accounting document number
        matnr LIKE rseg-matnr, "Material number
        ebeln LIKE rseg-ebeln, "Item Number of Purchasing Document
        ebelp LIKE rseg-ebelp, "Item Number of Purchasing Document
        buzei LIKE rbma-buzei,
        maktx LIKE makt-maktx, "Material description
        menge LIKE rseg-menge, "Quantity
        bstme LIKE rseg-bstme,
*        BPRBM LIKE RSEG-BPRBM, "Qty invoiced in vendor invoice in PO
*                               "price units
        quant LIKE rseg-menge, "BPRBM - MENGE
        wrbtr LIKE rseg-wrbtr, "Amount in document currency
        rbwwr LIKE rseg-rbwwr, "Invoice amount in document currency of
                               "vendor invoice
        amnt  LIKE rseg-wrbtr, "RBWWR - WRBTR
        kposn LIKE konv-kposn,
       END OF ta_itab2.

TYPES: BEGIN OF ta_itab3.
        INCLUDE STRUCTURE tline.
TYPES:       END OF ta_itab3.

TYPES: BEGIN OF ta_hdr3,
        sgtxt LIKE bsis-sgtxt, "Item Text
        bukrs LIKE bsis-bukrs, "Company Code
        hkont LIKE bsis-hkont, "General ledger account
        gjahr LIKE bsis-gjahr, "Fiscal year
        belnr LIKE bsis-belnr, "Accounting document number
       END OF ta_hdr3.

TYPES: BEGIN OF t_log_error,
            bukrs     LIKE bsis-bukrs,
            hkont     LIKE bsis-hkont,
            gjahr     LIKE bsis-gjahr,
            belnr     LIKE bsis-belnr,
            msg(80),
       END OF t_log_error.


TYPES:   BEGIN OF t_bdc.
        INCLUDE STRUCTURE bdcdata.
TYPES:   END OF t_bdc.
TYPES:   BEGIN OF t_messtab.
        INCLUDE STRUCTURE bdcmsgcoll.
TYPES:   END OF t_messtab.


DATA: i_itab1   TYPE ta_itab1 OCCURS 0,
      i_itab11   TYPE ta_itab1 OCCURS 0,
      wa_itab1  TYPE ta_itab1,
      i_itab2   TYPE ta_itab2 OCCURS 0,
      wa_itab2  TYPE ta_itab2,
      i_itab3   TYPE ta_itab3 OCCURS 0,
      wa_itab3  TYPE ta_itab3,
      i_itab31  TYPE ta_itab3 OCCURS 0,
      i_hdr3   TYPE ta_hdr3 OCCURS 0,
      wa_hdr3  TYPE ta_hdr3,
      i_itab2tmp TYPE ta_itab2 OCCURS 0,
      ln_itab2tmp TYPE i,
      i_log_error TYPE t_log_error OCCURS 0,
      wa_log_error TYPE t_log_error,
      msg(80),
      i_messtab TYPE t_messtab OCCURS 0,
      wa_messtab TYPE t_messtab,
      i_bdc TYPE t_bdc OCCURS 0,
      wa_bdc TYPE t_bdc,
      va_mode(1),
      va_xref3  LIKE bsis-xref3,
      va_hkont1 LIKE bsis-hkont,
      va_hkont2 LIKE bsis-hkont,
      va_gsber  LIKE bsik-gsber,
      va_name1  LIKE lfa1-name1,
      va_name2  LIKE lfa1-name2,
      va_stras(70),
      va_ort01  LIKE lfa1-ort01,
      va_stceg  LIKE lfa1-stceg,
      va_stenr  LIKE lfa1-stenr,
      va_stcd1  LIKE lfa1-stcd1,
      va_date   LIKE bsis-budat,
      va_zuonr1 LIKE rbkp-zuonr,
      va_bktxt  LIKE rbkp-bktxt,
      va_sgtxt  LIKE rseg-sgtxt,
      va_amtrbma LIKE rbma-wrbtr,
      va_shkzg   LIKE rbma-shkzg,
      va_nonr   LIKE zfvatin_nr-nonr.

DATA: va_wrbtr LIKE rseg-wrbtr,
      va_amnt  LIKE rseg-wrbtr,
      va_amnt1 LIKE rseg-wrbtr,
      va_amnt2 LIKE rseg-wrbtr,
      va_ppn   LIKE rseg-wrbtr,
      va_disc  LIKE rseg-wrbtr,
      va_dpp   LIKE rseg-wrbtr.

DATA: text1(20),
      text2(20),
      text3(20),
      text4(20),
      text5(20),
      tgl1 TYPE d,
      tgl2 TYPE d,
      tgl3 TYPE d,
      tgl4 TYPE d,
      tgl5 TYPE d.

DATA: va_blart  LIKE bsis-blart,
      bdcdata   LIKE bdcdata    OCCURS 0 WITH HEADER LINE, "input data
      messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE, "messages
      e_group_opened.            "error session opened (' ' or 'X')

DATA: va_lines  TYPE i,
      va_belnr LIKE bkpf-belnr,
      va_bukrs LIKE bkpf-bukrs,
      va_gjahr LIKE bkpf-gjahr,
      va_lifnr LIKE bsik-lifnr.

DATA : v_mstring(480).         "message string  ...
*TABLES: t100.             "message texts are ther


DATA: faktur1(40),
      faktur2(30),
      faktur3(30),
      faktur4(30),
      faktur5(30),
      fakturx(30),
      fakturx1(30),
      fakturx2(30),
      fakturx3(30),
      fakturx4(30),
      fakturx5(30),
      ebelp(3),    "LIKE RSEG-EBELP,
      maktx  LIKE makt-maktx,
      quant(13),
      wrbtr(15),
      amnt(13),
      amnt1(13),
      amnt2(13),
      amnt3(13),
      ppn(13),
      noret(20),
      disc(13),
      dpp(13),
      menge(13),
      hasat(13).

DATA: name1  LIKE adrc-name1,
      street LIKE adrc-street,
      city1  LIKE adrc-city1,
      npwp   LIKE zftax-npwp,
      names(70),
      streets(100),
      street1(100),
      stceg  LIKE lfa1-stceg,
      stenr  LIKE lfa1-stenr.

DATA: cntr1    TYPE i,
      cntr     TYPE i,
      page1    TYPE i,
      counter  TYPE i,
      counter1 TYPE i.

DATA: BEGIN OF i_hdr4 OCCURS 0,
        bukrs LIKE bsis-bukrs, "Company Code
        hkont LIKE bsis-hkont, "General ledger account
        gjahr LIKE bsis-gjahr, "Fiscal year
        belnr LIKE bsis-belnr, "Accounting document number
        sgtxt LIKE bsis-sgtxt, "Item Text
        shkzg LIKE bsis-shkzg,
        dmbtr LIKE bsis-dmbtr,
      END OF i_hdr4.
