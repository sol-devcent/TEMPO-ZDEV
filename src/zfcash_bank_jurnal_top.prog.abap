*----------------------------------------------------------------------*
*   INCLUDE ZFCASH_BANK_JURNAL_TOP                                     *
*----------------------------------------------------------------------*

  TABLES: BSIS, T001, SKAT, TCURT, GLT0, TGSB, TGSBT.

  TYPES:  BEGIN OF TA_ITAB,
            BUKRS LIKE BSIS-BUKRS,
            GSBER LIKE BSIS-GSBER,
            HKONT LIKE BSIS-HKONT,
            BUDAT LIKE BSIS-BUDAT,
            GJAHR LIKE BSIS-GJAHR,
            TXT20 LIKE SKAT-TXT20,
            ZUONR LIKE BSIS-ZUONR,
            XBLNR LIKE BSIS-XBLNR,
            SGTXT LIKE BSIS-SGTXT,
            BELNR LIKE BSIS-BELNR,
            SHKZG LIKE BSIS-SHKZG,
            WAERS LIKE BSIS-WAERS,
            DMBTR LIKE BSIS-DMBTR,      "Amount in local currency
            DMBT1 LIKE BSIS-DMBTR,      "Debit for DMBTR
            DMBT2 LIKE BSIS-DMBTR,      "Credit for DMBTR
            WRBTR LIKE BSIS-WRBTR,      "Amount in document currency
            WRBT1 LIKE BSIS-WRBTR,      "Debit for WRBTR
            WRBT2 LIKE BSIS-WRBTR,      "Credit for WRBTR
** Revise by Budi 29/05/2006
            HKONT1 LIKE BSIS-HKONT,
** End Revise by Budi 29/05/2006
          END OF TA_ITAB.

  TYPES:  BEGIN OF TA_ITAB1,
            BUKRS LIKE BSIS-BUKRS,
            GSBER LIKE BSIS-GSBER,
            HKONT LIKE BSIS-HKONT,
            BUDAT LIKE BSIS-BUDAT,
            GJAHR LIKE BSIS-GJAHR,
            ZUONR LIKE BSIS-ZUONR,
            BELNR LIKE BSIS-BELNR,
            SHKZG LIKE BSIS-SHKZG,
            WAERS LIKE BSIS-WAERS,
            DMBTR LIKE BSIS-DMBTR,      "Amount in local currency
            WRBTR LIKE BSIS-WRBTR,      "Amount in document currency
          END OF TA_ITAB1.

  TYPES:  BEGIN OF TA_HKONT,
            HKONT  LIKE BSIS-HKONT,
            GSBER  LIKE BSIS-GSBER,
            BUKRS  LIKE BSIS-BUKRS,
            BUDAT  LIKE BSIS-BUDAT,
            GJAHR  LIKE BSIS-GJAHR,
            ZUONR  LIKE BSIS-ZUONR,
            BELNR  LIKE BSIS-BELNR,
            SHKZG  LIKE BSIS-SHKZG,
            WAERS  LIKE BSIS-WAERS,
            TXT20  LIKE SKAT-TXT20,
            BEGBAL LIKE BSIS-DMBTR,
            DEBET  LIKE BSIS-DMBTR,
            CREDIT LIKE BSIS-WRBTR,
            ENDBAL LIKE BSIS-DMBTR,
          END OF TA_HKONT.

  DATA:   I_ITAB    TYPE TA_ITAB OCCURS 0,
          WA_ITAB   TYPE TA_ITAB,
          I_ITAB1   TYPE TA_ITAB1 OCCURS 0,
          WA_ITAB1  TYPE TA_ITAB1,
          I_HKONT   TYPE TA_HKONT OCCURS 0 WITH HEADER LINE,
          I_HKONT1  TYPE TA_HKONT OCCURS 0 WITH HEADER LINE,
          WA_HKONT  TYPE TA_HKONT.

  DATA:   PAGNO     TYPE I,
          NOURUT(3) TYPE P DECIMALS 0,
          NOURUT_OUT(3),
          VA_HKONT(10) TYPE N,
          VA_HKONT1(10) TYPE N,
          VA_TXT20  LIKE SKAT-TXT20,
          VA_DATE   LIKE SY-DATUM.

  DATA:   VA_DMBTR   LIKE BSIS-DMBTR,
          VA_WRBTR   LIKE BSIS-WRBTR,
          VA_BEGBAL  LIKE BSIS-WRBTR,
          VA_BEGBAL1(20),
          VA_ENDBAL  LIKE BSIS-WRBTR,
          VA_ENDBAL1(20).

  DATA:   TOTAL1    LIKE BSIS-DMBTR,
          VA_TOTAL1 LIKE BSIS-DMBTR,
          TOTAL1_OUT(20),
          DMBT1_OUT(20),
          TOTAL2    LIKE BSIS-DMBTR,
          VA_TOTAL2 LIKE BSIS-DMBTR,
          TOTAL2_OUT(20),
          DMBT2_OUT(20),
          TOTAL3    LIKE BSIS-DMBTR,
          TOTAL4    LIKE BSIS-DMBTR.

  DATA:   BEGBAL_END LIKE BSIS-DMBTR,
          BEGBAL_END_OUT(20),
          TOTAL1_END LIKE BSIS-DMBTR,
          TOTAL1_END_OUT(20),
          TOTAL2_END LIKE BSIS-DMBTR,
          TOTAL2_END_OUT(20),
          ENDBAL_END LIKE BSIS-DMBTR,
          ENDBAL_END_OUT(20).

  DATA:   ZEBRA   TYPE I.

  DATA:   VA_GTEXT LIKE TGSBT-GTEXT,
          VA_KTEXT LIKE TCURT-KTEXT,
          CURRENT(5),
          VA_DESC(30).

  DATA:   VA_ZUONR LIKE BSIS-ZUONR,
          VA_BUDAT LIKE BSIS-BUDAT,
          VA_GJAHR LIKE BSIS-GJAHR,
          VA_BELNR LIKE BSIS-BELNR.

  DATA:   COUNTER TYPE I.

** Revise by Budi 29/05/2006
  TYPES:  BEGIN OF TA_ITAB2,
            BUKRS LIKE BSIS-BUKRS,
            GSBER LIKE BSIS-GSBER,
            HKONT1 LIKE BSIS-HKONT,
            BUDAT LIKE BSIS-BUDAT,
            GJAHR LIKE BSIS-GJAHR,
            TXT20 LIKE SKAT-TXT20,
            ZUONR LIKE BSIS-ZUONR,
            XBLNR LIKE BSIS-XBLNR,
            SGTXT LIKE BSIS-SGTXT,
            BELNR LIKE BSIS-BELNR,
            SHKZG LIKE BSIS-SHKZG,
            WAERS LIKE BSIS-WAERS,
            DMBTR LIKE BSIS-DMBTR,      "Amount in local currency
            DMBT1 LIKE BSIS-DMBTR,      "Debit for DMBTR
            DMBT2 LIKE BSIS-DMBTR,      "Credit for DMBTR
            WRBTR LIKE BSIS-WRBTR,      "Amount in document currency
            WRBT1 LIKE BSIS-WRBTR,      "Debit for WRBTR
            WRBT2 LIKE BSIS-WRBTR,      "Credit for WRBTR
            HKONT LIKE BSIS-HKONT,
          END OF TA_ITAB2.

  DATA:   I_SKAT LIKE SKAT OCCURS 0 WITH HEADER LINE,
          I_ITAB2 TYPE TA_ITAB2 OCCURS 0 WITH HEADER LINE.
** End Revise by Budi 29/05/2006

  DATA  BEGIN OF t_glt0 OCCURS 1.
          INCLUDE STRUCTURE glt0.
  DATA  END   OF t_glt0.

  DATA gv_flag(1).

  CONSTANTS: c_rldnr LIKE glt0-rldnr VALUE '00',
             c_rrcty LIKE glt0-rrcty VALUE '0',
             c_rvers LIKE glt0-rvers VALUE '001',
             c_rpmax LIKE glt0-rpmax VALUE '016'.
