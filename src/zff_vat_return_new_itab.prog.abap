***INCLUDE ZFF_VAT_RETURN_ITAB .

TABLES: LFA1,             " Vendor Master (General Section)
        BSIK,             " Accounting: Secondary Index for Vendors
        BSIS,             " Accounting: Secondary Index for G/L Accounts
        RBKP,             " Document Header: Invoice Receipt
        RSEG,             " Document Item: Incoming Invoice
        BKPF,             " Accounting Document Header
        MAKT,             " Material Descriptions
        RBMA.

TABLES: NAST.

TYPES: BEGIN OF TA_ITAB1,
        BUKRS LIKE BSIS-BUKRS, "Company Code
        HKONT LIKE BSIS-HKONT, "General ledger account
        GJAHR LIKE BSIS-GJAHR, "Fiscal year
        BELNR LIKE BSIS-BELNR, "Accounting document number
        AUGBL LIKE BSIS-AUGBL, "Document Number of the Clearing Document
        BUDAT LIKE BSIS-BUDAT, "Posting date in the document
        BLDAT LIKE BSIS-BLDAT, "Document date in document
        WAERS LIKE BSIS-WAERS, "Currency Key
        XBLNR LIKE BSIS-XBLNR, "Reference document number
        BLART LIKE BSIS-BLART, "Document type
        MONAT LIKE BSIS-MONAT, "Fiscal period
        SHKZG LIKE BSIS-SHKZG, "Debit/credit indicator
        BSCHL LIKE BSIS-BSCHL, "Posting key
        MWSKZ LIKE BSIS-MWSKZ, "Tax on sales/purchases code
        DMBTR LIKE BSIS-DMBTR, "Amount in local currency
        RBELN LIKE RBKP-BELNR, "Document number of an invoice document
        ZFBDT LIKE BSIS-ZFBDT, "Baseline date for due date calculation
        SGTXT LIKE BSIS-SGTXT, "Item Text
        LIFNR LIKE BSIK-LIFNR, "Account number of vendor or creditor
        ZUONR LIKE BSIK-ZUONR, "Assignment number
        GSBER LIKE BSIK-GSBER, "Business Area
        AWKEY LIKE BKPF-AWKEY, "Object key
        NAME1 LIKE LFA1-NAME1, "Name 1
        NAME2 LIKE LFA1-NAME2, "Name 2
        STRAS(70), "House number and street
        ORT01 LIKE LFA1-ORT01, "City
        CITY1 LIKE ADRC-CITY1,
        STCD1 LIKE LFA1-STCD1, "Tax number 1
        STCEG LIKE LFA1-STCEG, "VAT registration number
        STENR LIKE LFA1-STENR, "Tanggal Pengukuhan
        ZUONR1 LIKE RBKP-ZUONR,
        BKTXT LIKE RBKP-BKTXT,
        check(1),
       END OF TA_ITAB1.

TYPES: BEGIN OF TA_ITAB2,
        GJAHR LIKE RSEG-GJAHR, "Fiscal year
        BELNR LIKE RSEG-BELNR, "Accounting document number
        MATNR LIKE RSEG-MATNR, "Material number
        EBELP LIKE RSEG-EBELP, "Item Number of Purchasing Document
        BUZEI LIKE RBMA-BUZEI,
        MAKTX LIKE MAKT-MAKTX, "Material description
        MENGE LIKE RSEG-MENGE, "Quantity
        bstme LIKE rseg-bstme,
*        BPRBM LIKE RSEG-BPRBM, "Qty invoiced in vendor invoice in PO
*                               "price units
        QUANT LIKE RSEG-MENGE, "BPRBM - MENGE
        WRBTR LIKE RSEG-WRBTR, "Amount in document currency
        RBWWR LIKE RSEG-RBWWR, "Invoice amount in document currency of
                               "vendor invoice
        AMNT  LIKE RSEG-WRBTR, "RBWWR - WRBTR
        shkzg LIKE rseg-shkzg,
       END OF TA_ITAB2.

TYPES: BEGIN OF TA_ITAB3.
             include structure tline.
Types:       END OF TA_ITAB3.

TYPES: BEGIN OF TA_HDR3,
        SGTXT LIKE BSIS-SGTXT, "Item Text
        BUKRS LIKE BSIS-BUKRS, "Company Code
        HKONT LIKE BSIS-HKONT, "General ledger account
        GJAHR LIKE BSIS-GJAHR, "Fiscal year
        BELNR LIKE BSIS-BELNR, "Accounting document number
       END OF TA_HDR3.

Types: Begin of t_log_error,
            bukrs     like bsis-bukrs,
            hkont     like bsis-hkont,
            gjahr     like bsis-gjahr,
            Belnr     like bsis-belnr,
            msg(80),
       End of t_log_error.


Types:   BEGIN OF T_BDC.
          INCLUDE STRUCTURE BDCDATA.
Types:   END OF T_BDC.
Types:   begin of t_messtab.
          include structure bdcmsgcoll.
Types:   end of t_messtab.


DATA: I_ITAB1   TYPE TA_ITAB1 OCCURS 0,
      I_ITAB11   TYPE TA_ITAB1 OCCURS 0,
      WA_ITAB1  TYPE TA_ITAB1,
      I_ITAB2   TYPE TA_ITAB2 OCCURS 0,
      WA_ITAB2  TYPE TA_ITAB2,
      I_ITAB3   TYPE TA_ITAB3 OCCURS 0,
      WA_ITAB3  TYPE TA_ITAB3,
      I_ITAB31  TYPE TA_ITAB3 OCCURS 0,
      I_HDR3   TYPE TA_HDR3 OCCURS 0,
      WA_HDR3  TYPE TA_HDR3,
      I_ITAB2tmp TYPE TA_ITAB2 OCCURS 0,
      ln_ITAB2tmp TYPE i,
      i_log_error type t_log_error occurs 0,
      wa_log_error type t_log_error,
      msg(80),
      i_messtab type t_messtab occurs 0,
      wa_messtab type t_messtab,
      i_bdc type T_BDC occurs 0,
      wa_bdc type t_bdc,
      va_mode(1),
      va_xref3  like bsis-xref3,
      va_hkont1 like bsis-hkont,
      va_hkont2 like bsis-hkont,
      VA_GSBER  LIKE BSIK-GSBER,
      VA_NAME1  LIKE LFA1-NAME1,
      VA_NAME2  LIKE LFA1-NAME2,
      VA_STRAS(70),
      VA_ORT01  LIKE LFA1-ORT01,
      VA_STCEG  LIKE LFA1-STCEG,
      VA_STENR  LIKE LFA1-STENR,
      VA_STCD1  LIKE LFA1-STCD1,
      VA_DATE   LIKE BSIS-BUDAT,
      VA_ZUONR1 LIKE RBKP-ZUONR,
      VA_BKTXT  LIKE RBKP-BKTXT,
      VA_SGTXT  LIKE RSEG-SGTXT,
      VA_AMTRBMA LIKE RBMA-WRBTR,
      VA_SHKZG   LIKE RBMA-SHKZG.

DATA: VA_AMNT  LIKE RSEG-WRBTR,
      VA_AMNT1 LIKE RSEG-WRBTR,
      VA_AMNT2 LIKE RSEG-WRBTR,
      VA_PPN   LIKE RSEG-WRBTR,
      VA_DISC  LIKE RSEG-WRBTR,
      VA_DPP   LIKE RSEG-WRBTR.

DATA: TEXT1(20),
      TEXT2(20),
      TEXT3(20),
      TEXT4(20),
      TEXT5(20),
      TGL1 TYPE D,
      TGL2 TYPE D,
      TGL3 TYPE D,
      TGL4 TYPE D,
      TGL5 TYPE D.

data: va_BLART  like bsis-blart,
      bdcdata   like bdcdata    occurs 0 with header line, "input data
      messtab like bdcmsgcoll occurs 0 with header line, "messages
      e_group_opened.            "error session opened (' ' or 'X')

DATA: VA_LINES  TYPE I,
      VA_BELNR LIKE BKPF-BELNR,
      VA_BUKRS LIKE BKPF-BUKRS,
      VA_GJAHR like bkpf-gjahr,
      VA_LIFNR LIKE BSIK-LIFNR.

data : v_mstring(480).         "message string  ...
*tables: t100.             "message texts are ther


DATA: FAKTUR1(40),
      FAKTUR2(30),
      FAKTUR3(30),
      FAKTUR4(30),
      FAKTUR5(30),
      FAKTURX(30),
      FAKTURX1(30),
      FAKTURX2(30),
      FAKTURX3(30),
      FAKTURX4(30),
      FAKTURX5(30),
      EBELP(3),    "LIKE RSEG-EBELP,
      MAKTX  LIKE MAKT-MAKTX,
      QUANT(13),
      WRBTR(15),
      AMNT(13),
      AMNT1(13),
      AMNT2(13),
      AMNT3(13),
      PPN(13),
      NORET(20),
      DISC(13),
      DPP(13).

DATA: NAME1  LIKE ADRC-NAME1,
      STREET LIKE ADRC-STREET,
      CITY1  LIKE ADRC-CITY1,
      NPWP   LIKE ZFTAX-NPWP,
      NAMES(70),
      STREETS(100),
      STREET1(100),
      STCEG  LIKE LFA1-STCEG,
      STENR  LIKE LFA1-STENR.

DATA: CNTR1    TYPE I,
      CNTR     TYPE I,
      PAGE1    TYPE I,
      COUNTER  TYPE I,
      COUNTER1 TYPE I.

DATA: BEGIN OF I_HDR4 OCCURS 0,
        BUKRS LIKE BSIS-BUKRS, "Company Code
        HKONT LIKE BSIS-HKONT, "General ledger account
        GJAHR LIKE BSIS-GJAHR, "Fiscal year
        BELNR LIKE BSIS-BELNR, "Accounting document number
        BUZEI LIKE BSIS-BUZEI,
        SGTXT LIKE BSIS-SGTXT, "Item Text
        SHKZG LIKE BSIS-SHKZG,
        DMBTR LIKE BSIS-DMBTR,
      END OF I_HDR4.

DATA: gt_bseg TYPE TABLE OF bseg WITH HEADER LINE.
