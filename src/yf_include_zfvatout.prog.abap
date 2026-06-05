*----------------------------------------------------------------------*
*   INCLUDE YF_INCLUDE_ZFVATIN                                         *
*----------------------------------------------------------------------*

TYPE-POOLS: SLIS.

****************************************************
*        Tables                                    *
****************************************************
TABLES: KNA1,
        BSID,
        BSIS,
        BSAD,
        BKPF,
        TGSB,
        T001,
        ZFTAX,
        ZFVATA1,
        ZFVATA2,
        ZFVATA3,
        zfvatxx.

************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
* TYPE FOR THE DATA OF TABLECONTROL 'TA_TABLE1'
TYPES: BEGIN OF T_TA_TABLE1,
         CHECK(1),
         BUKRS LIKE ZFVATA3-BUKRS,
         GSBER LIKE ZFVATA3-GSBER,
         GJAHR LIKE ZFVATA3-GJAHR,
         MONAT LIKE ZFVATA3-MONAT,
         TXDAT LIKE ZFVATA3-TXDAT,
         TBELN LIKE ZFVATA3-TBELN,
         NAME1 LIKE ZFVATA3-NAME1,
         STCEG LIKE ZFVATA3-STCEG,
         SHKZG LIKE ZFVATA3-SHKZG,
         WAERS LIKE ZFVATA3-WAERS,
         DMBTR LIKE ZFVATA3-DMBTR,
         REMARK LIKE ZFVATA3-REMARK,
         ZSTATUS LIKE ZFVATA3-ZSTATUS,
       END OF T_TA_TABLE1.

TYPES:
  BEGIN OF t_excel,
    row   LIKE alsmex_tabline-row,
    col   LIKE alsmex_tabline-col,
    value LIKE alsmex_tabline-value,
  END OF t_excel.

TYPES: BEGIN OF TA_ITABA1.
         INCLUDE STRUCTURE ZFVATA1.
TYPES: END OF TA_ITABA1.
TYPES: BEGIN OF TA_ITABA2.
         INCLUDE STRUCTURE ZFVATA2.
TYPES: END OF TA_ITABA2.
TYPES: BEGIN OF TA_ITABA3.
         INCLUDE STRUCTURE ZFVATA3.
TYPES: END OF TA_ITABA3.

TYPES : BEGIN OF T_ITAB1,
            BUKRS     LIKE BSIS-BUKRS,
            HKONT     LIKE BSIS-HKONT,
            GJAHR     LIKE BSIS-GJAHR,
            BUDAT     LIKE BSIS-BUDAT,
            BLDAT     LIKE BSIS-BLDAT,
            WAERS     LIKE BSIS-WAERS,
            XBLNR     LIKE BSIS-XBLNR,
            BLART     LIKE BSIS-BLART,
            MONAT     LIKE BSIS-MONAT,
            BSCHL     LIKE BSIS-BSCHL,
            SHKZG     LIKE BSIS-SHKZG,
            MWSKZ     LIKE BSIS-MWSKZ,
            DMBTR     LIKE BSIS-DMBTR,
            SGTXT     LIKE BSIS-SGTXT,
            ZFBDT     LIKE BSIS-ZFBDT,
            BELNR     LIKE BSIS-BELNR,
            XREF3     LIKE BSIS-XREF3,
            KUNNR     LIKE BSID-KUNNR,
            LIFNR     LIKE BSIK-LIFNR,
            ZUONR     LIKE BSIK-ZUONR,
            GSBER     LIKE BSIK-GSBER,
            STCD1     LIKE LFA1-STCD1,
            STCEG     LIKE LFA1-STCEG,
            ANRED     LIKE LFA1-ANRED,
            NAME1     LIKE LFA1-NAME1,
            NAME2     LIKE LFA1-NAME2,
            BKTXT     LIKE BKPF-BKTXT,
            ERROR(30),
        END OF T_ITAB1.

TYPES:   BEGIN OF T_BDC.
          INCLUDE STRUCTURE BDCDATA.
TYPES:   END OF T_BDC.

TYPES:   BEGIN OF T_MESSTAB.
          INCLUDE STRUCTURE BDCMSGCOLL.
TYPES:   END OF T_MESSTAB.
TYPES: BEGIN OF T_LOG_ERROR,
            BUKRS     LIKE BSIS-BUKRS,
            HKONT     LIKE BSIS-HKONT,
            GJAHR     LIKE BSIS-GJAHR,
            BELNR     LIKE BSIS-BELNR,
            MSG(80),
       END OF T_LOG_ERROR.

TYPES: BEGIN OF TA_ITAB,
         KDLAMP(1),
         KDSTAT(1),
         KDDOCU(1),
         NPWP(20),
         NMWP(30),
         KDFKTR(9),
         NOREF(30),
         NOFKTR(30),
         TGLFKT(10),
         BLNPJK(2),
         THNPJK(4),
         PEMBTL(2),
         TARIF(10),
         NILPPN(15),
         NILPPNBM(15),
       END OF TA_ITAB.

TYPES: BEGIN OF TA_ITABT,
         THNPJK(4),
         BLNPJK(2),
         PEMBTL(2),
         KDLAMP(1),
         KDSTAT(1),
         NPWP(15),
         NMWP(30),
         KDDOCU(1),
         KDFKTR(5),
         KDKPP(3),
         NOFKTR(27),
         TGLFKT(10),
         NILPPN(15),
         NILPPNBM(15),
       END OF TA_ITABT.

DATA: BEGIN OF TA_EXCEL OCCURS 0,
         NOURUT TYPE I,
         THNPJK(4),
         BLNPJK(2),
         PEMBTL(2),
         KDLAMP(1),
         KDSTAT(1),
         NPWP(15),
         NMWP(30),
         KDDOCU(1),
         KDFKTR(5),
         KDKPP(3),
         NOFKTR(7),
         TGLFKT(10),
         NILPPN(15),
         NILPPNBM(15),
       END OF TA_EXCEL.

DATA: BEGIN OF TA_EXCEL1 OCCURS 0,
         KDLAMP(1),
         KDSTAT(1),
         KDDOCU(1),
         NPWP(20),
         NMWP(30),
         KDFKTR(9),
         NOREF(30),
         NOFKTR(30),
         TGLFKT(10),
         BLNPJK(2),
         THNPJK(4),
         PEMBTL(2),
         TARIF(10),
         NILPPN(15),
         NILPPNBM(15),
       END OF TA_EXCEL1.

TYPES: BEGIN OF TA_ERROR,
         NMWP(30),
         KDFKTR(5),
         KDKPP(3),
         NOFKTR(27),
         NPWP(15),
      END OF TA_ERROR.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS :
        C_HKONT_220        LIKE BSIS-HKONT VALUE '0315300220',
        C_HKONT_210        LIKE BSIS-HKONT VALUE '0315300210',
        C_HKONT_200        LIKE BSIS-HKONT VALUE '0315300200',
        C_HKONT_211        LIKE BSIS-HKONT VALUE '0315300211',
        C_BLART_SA         LIKE BSIS-BLART VALUE 'SA',
        C_BSCHL_50         LIKE  BSIS-BSCHL VALUE '50',
        C_WAERS_IDR        LIKE BSIS-WAERS VALUE 'IDR'.
************************************************************************
* VARIABLES                                                            *
************************************************************************
* Helpers/auxilliaries

DATA: ID_ITABA1   TYPE TA_ITABA1  OCCURS 0,
      WD_ITABA1   TYPE TA_ITABA1,
      I_ERROR     TYPE TA_ITABA1  OCCURS 0,
      WA_ERROR    TYPE TA_ITABA1,
      I_DELE      TYPE TA_ITABA1  OCCURS 0,
      WA_DELE     TYPE TA_ITABA1,
      ID_ITABA3   TYPE TA_ITABA3  OCCURS 0,
      WD_ITABA3  TYPE TA_ITABA3,
      ID_ITABA2   TYPE TA_ITABA2  OCCURS 0,
      WD_ITABA2  TYPE TA_ITABA2,
      I_ITAB     TYPE TA_ITAB OCCURS 0,
      WA_ITAB    TYPE TA_ITAB,
      i_itabt    TYPE ta_itabt OCCURS 0,
      wa_itabt   TYPE ta_itabt,
      i_excel    TYPE t_excel OCCURS 0,
      wa_excel   TYPE t_excel.

TYPES: BEGIN OF T_DWN_FIELD,
         TXT_FIELD(40),
       END OF T_DWN_FIELD.

DATA: WA_DWN_FIELD TYPE T_DWN_FIELD,
      DWN_FIELD TYPE  T_DWN_FIELD OCCURS 0.

DATA: va_name(128).

DATA: I_ERROR1    TYPE TA_ERROR OCCURS 0,
      WA_ERROR1   TYPE TA_ERROR.

DATA: VA_KE(9), VA_PRD(10), VA_THN(4).
DATA: XOPTION LIKE ITCPP, XOPTION2 LIKE ITCPO.
DATA: I_BDC TYPE T_BDC OCCURS 0,
      WA_BDC TYPE T_BDC,
      I_MESSTAB TYPE T_MESSTAB OCCURS 0,
      WA_MESSTAB TYPE T_MESSTAB,
      I_LOG_ERROR TYPE T_LOG_ERROR OCCURS 0,
      WA_LOG_ERROR TYPE T_LOG_ERROR,
      VA_MODE(1),
      VA_HKONT1 LIKE BSIS-HKONT,
      VA_HKONT2 LIKE BSIS-HKONT,
      I_ITAB1 TYPE T_ITAB1 OCCURS 0,
      I_ITAB1ERR TYPE T_ITAB1 OCCURS 0,
      I_ITAB1A1 TYPE T_ITAB1 OCCURS 0,
      I_ITAB1A2 TYPE T_ITAB1 OCCURS 0,
      I_ITAB1A3 TYPE T_ITAB1 OCCURS 0,
      I_ITAB1XX TYPE T_ITAB1 OCCURS 0,
      WA_ITAB1 TYPE T_ITAB1.

DATA:  MSG(80), TOT_DMBTR LIKE BSEG-DMBTR,
                tot_DMBTR1 LIKE BSEG-DMBTR,
                GRAND_DMBTR LIKE BSEG-DMBTR.
RANGES: TA_DATE FOR SY-DATUM.

DATA:
       C1    TYPE I,
       W1    TYPE I,  W2    TYPE I,  W3    TYPE I,  W4    TYPE I,
       W5    TYPE I,  W6    TYPE I,  W7    TYPE I,  W8    TYPE I,
       W9    TYPE I,  W10   TYPE I,  W11   TYPE I,  W12   TYPE I,
       W13   TYPE I,  W14   TYPE I,  W15   TYPE I,  W16   TYPE I,
       W17   TYPE I,  W18   TYPE I,  W19   TYPE I,  W19A  TYPE I,
       W20   TYPE I,  W17A  TYPE I,
       W21   TYPE I,  W22   TYPE I,  W23   TYPE I,  W24   TYPE I,
       W25   TYPE I,  W26   TYPE I,  W27   TYPE I,  W28   TYPE I,
       W29   TYPE I,  W30   TYPE I,  W31   TYPE I,  W32   TYPE I,
       W33   TYPE I,  W34   TYPE I,  W35   TYPE I.
DATA  VA_TITLE(80).


TYPES: BEGIN OF TA_ITAB1,
         BUKRS    LIKE ZFVATA1-BUKRS,
         BUTXT    LIKE T001-BUTXT,
         NPWP     LIKE ZFTAX-NPWP,
         NPPKP    LIKE ZFTAX-NPPKP,
         PKDAT    LIKE ZFTAX-PKDAT,
         GSBER    LIKE ZFVATA1-GSBER,
         GJAHR    LIKE ZFVATA1-GJAHR,
         MONAT    LIKE ZFVATA1-MONAT,
         TXDAT    LIKE ZFVATA1-TXDAT,
         TBELN    LIKE ZFVATA1-TBELN,
         NAME1    LIKE ZFVATA1-NAME1,
         STCEG    LIKE ZFVATA1-STCEG,
         DMBTR    LIKE ZFVATA1-DMBTR,
         SHKZG    LIKE ZFVATA1-SHKZG,
         REMARK   LIKE ZFVATA1-REMARK,
         ZSTATUS  LIKE ZFVATA1-ZSTATUS,
       END OF TA_ITAB1.

DATA: I_ITABA1     TYPE TA_ITAB1 OCCURS 0,
      WA_ITABA1    TYPE TA_ITAB1.
DATA: I_ITABA2     TYPE TA_ITAB1 OCCURS 0,
      WA_ITABA2    TYPE TA_ITAB1.
DATA: I_ITABA3     TYPE TA_ITAB1 OCCURS 0,
      WA_ITABA3    TYPE TA_ITAB1.

DATA: BUTXT       LIKE T001-BUTXT,
      NPWP        LIKE ZFTAX-NPWP,
      NPPKP       LIKE ZFTAX-NPPKP,
      PKDAT       LIKE ZFTAX-PKDAT,
      NOU(5),
      CNTR  TYPE P,
      CNTR1 TYPE P,
      CNTR2 TYPE P,
      CNTR4 TYPE P,
      CNTR5 TYPE P,
      SPASI(3),
      SWITCH(1),
      NAME1(28),
      DMBTR(15),       "LIKE ZFVATA1-DMBTR,
      DMBTR1(15),
      DMBTRA(11),
      DMBTR3(11),
      TDMBTR      LIKE ZFVATA3-DMBTR,
      TDMBTR1     LIKE ZFVATA1-DMBTR,
      TDMBTR2     LIKE ZFVATA1-DMBTR,
      TDMBTR1X(17),
      TDMBTR2X(17),
      JUMLAH      LIKE ZFVATA1-DMBTR,
      JUMLAH1(17),
      JUMLAH2     LIKE ZFVATA1-DMBTR,
      JUMLAHX(17),
      JUMLAH1X(17),
      JUMLAH2X(17),
      TOTAL       LIKE ZFVATA1-DMBTR,
      TOTAL1(17),
      TOTAL2(17),
      VA_POST(2),
      STCEG       LIKE ZFVATA1-STCEG,
      TBELN       LIKE ZFVATA1-TBELN,
      TXDAT       LIKE ZFVATA1-TXDAT,
      FAKTUR1     LIKE ZFVATA1-DMBTR,
      FAKTUR2     LIKE ZFVATA1-DMBTR,
      FAKTUR3     LIKE ZFVATA1-DMBTR,
      FAKTUR4     LIKE ZFVATA1-DMBTR,
      FAKTUR5     LIKE ZFVATA1-DMBTR,
      FAKTUR6     LIKE ZFVATA1-DMBTR,
      FAKTUR1X(17),
      FAKTUR2X(17),
      FAKTUR3X(17),
      FAKTUR4X(17),
      FAKTUR5X(17),
      FAKTUR6X(17),
      AMNT        TYPE P,
      FKTR1(17),
      FKTR2(17),
      FKTR3(17),
      PAGE(4),
      PAGE1(4),
      PAGE2(4),
      PAGE3(4).

DATA:  VA_XREF3  LIKE BSIS-XREF3,
       VA_XREF4  LIKE BSIS-XREF3,
       VA_XREF3T1  LIKE BSIS-XREF3,
       VA_XREF3T2  LIKE BSIS-XREF3,
       VA_XREF3XX  LIKE BSIS-XREF3,
       VA_BSCHL   LIKE  BSIS-BSCHL,
       VA_XREF3T0  LIKE BSIS-XREF3.

DATA: VA_BETUL      LIKE WA_ITAB-PEMBTL,
      VA_GJAHR      LIKE WA_ITAB-THNPJK,
      VA_KDLAMP     LIKE WA_ITAB-KDLAMP,
      VA_KDSTAT     LIKE WA_ITAB-KDSTAT,
      VA_NPWP       LIKE ZFVATA1-STCEG,
      VA_NMWP       LIKE WA_ITAB-NMWP,
      VA_KDDOCU     LIKE WA_ITAB-KDDOCU,
      VA_KDFKTR     LIKE WA_ITAB-KDFKTR,
      VA_NOFKTR     LIKE WA_ITAB-NOFKTR,
      VA_TGLFKT     LIKE WA_ITAB-TGLFKT,
      VA_NILPPN LIKE WA_ITAB-NILPPN,
      VA_NILPPNBM   LIKE WA_ITAB-NILPPNBM.

DATA: VA_MONAT(2),
      VA_YEAR(4).

DATA: V_SPACE      TYPE I,
      V_LEN        TYPE I,
      CANC(1),
      COUNTER      TYPE I,
      COUNTER1     TYPE I,
      SIZE         TYPE I.

DATA: STATUS(6).

DATA: V_KDLAMP   LIKE TA_EXCEL-KDLAMP,
      V_BETUL    LIKE TA_EXCEL-PEMBTL,
      V_KDSTAT   LIKE TA_EXCEL-KDSTAT,
      V_NPWP     LIKE ZFVATA1-STCEG,
      V_NPWP_IN  TYPE ZFVATA1-STCEG,
      V_NPWP_OUT TYPE ZFVATA1-STCEG,
      V_NMWP     LIKE TA_EXCEL-NMWP,
      V_KDDOCU   LIKE TA_EXCEL-KDDOCU,
      V_KDFKTR   LIKE TA_EXCEL-KDFKTR,
      V_KDKPP    LIKE TA_EXCEL-KDKPP,
      V_NOFKTR   LIKE TA_EXCEL-NOFKTR,
      V_TGLFKT   LIKE TA_EXCEL-TGLFKT,
      V_NILPPN   TYPE P,
      V_NILPPNBM LIKE TA_EXCEL-NILPPNBM.

DATA: FLAG(1),
      OPTION   TYPE I,
      NOURUT   TYPE I,
      ERROR    TYPE I.

DATA: ok_code TYPE sy-ucomm,
      save_ok LIKE ok_code.

DATA: TAB_AGKO LIKE AGKO OCCURS 0 WITH HEADER LINE.

* BEGIN ALV
DATA: GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
      G_EXIT_CAUSED_BY_CALLER,
      GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
      G_REPID LIKE SY-REPID.

*"Callback
DATA:
    GT_EVENTS      TYPE SLIS_T_EVENT,
    GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
    G_STATUS_SET   TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
    G_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
    G_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
    G_TOP_OF_LIST  TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST',
    G_END_OF_LIST  TYPE SLIS_FORMNAME VALUE 'END_OF_LIST',
    XIT_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV,
    XIS_PRINT      TYPE SLIS_PRINT_ALV.

*"Variants
DATA: GS_VARIANT LIKE DISVARIANT,
      G_SAVE.

* END ALV

* INTERNAL TABLE FOR TABLECONTROL 'TA_TABLE1'
DATA:     G_TA_TABLE1_ITAB   TYPE T_TA_TABLE1 OCCURS 0,
          G_TA_TABLE1_WA     TYPE T_TA_TABLE1, "work area
          G_TA_TABLE1_COPIED.           "copy flag

* TYPE FOR THE DATA OF TABLECONTROL 'TA_TABLE2'
TYPES: BEGIN OF T_TA_TABLE2,
         CHECK(1),
         BUKRS LIKE ZFVATA2-BUKRS,
         GSBER LIKE ZFVATA2-GSBER,
         GJAHR LIKE ZFVATA2-GJAHR,
         MONAT LIKE ZFVATA2-MONAT,
         TXDAT LIKE ZFVATA2-TXDAT,
         TBELN LIKE ZFVATA2-TBELN,
         NAME1 LIKE ZFVATA2-NAME1,
         STCEG LIKE ZFVATA2-STCEG,
         SHKZG LIKE ZFVATA2-SHKZG,
         WAERS LIKE ZFVATA2-WAERS,
         DMBTR LIKE ZFVATA2-DMBTR,
         REMARK LIKE ZFVATA2-REMARK,
         ZSTATUS LIKE ZFVATA2-ZSTATUS,
       END OF T_TA_TABLE2.

* INTERNAL TABLE FOR TABLECONTROL 'TA_TABLE2'
DATA:     G_TA_TABLE2_ITAB   TYPE T_TA_TABLE2 OCCURS 0,
          G_TA_TABLE2_WA     TYPE T_TA_TABLE2, "work area
          G_TA_TABLE2_COPIED.           "copy flag

* DECLARATION OF TABLECONTROL 'TA_TABLE1' ITSELF
CONTROLS: TA_TABLE1 TYPE TABLEVIEW USING SCREEN 0910.

* DECLARATION OF TABLECONTROL 'TA_TABLE1' ITSELF
CONTROLS: TA_TABLE2 TYPE TABLEVIEW USING SCREEN 0920.


* LINES OF TABLECONTROL 'TA_TABLE1'
DATA:     G_TA_TABLE1_LINES  LIKE SY-LOOPC.


* LINES OF TABLECONTROL 'TA_TABLE2'
DATA:     G_TA_TABLE2_LINES  LIKE SY-LOOPC.

* TYPE FOR THE DATA OF TABLECONTROL 'TA_TABLE'
TYPES: BEGIN OF T_TA_TABLE,
         CHECK(1),
         BUKRS LIKE ZFVATA1-BUKRS,
         GSBER LIKE ZFVATA1-GSBER,
         GJAHR LIKE ZFVATA1-GJAHR,
         MONAT LIKE ZFVATA1-MONAT,
         TXDAT LIKE ZFVATA1-TXDAT,
         TBELN LIKE ZFVATA1-TBELN,
         NAME1 LIKE ZFVATA1-NAME1,
         STCEG LIKE ZFVATA1-STCEG,
         SHKZG LIKE ZFVATA1-SHKZG,
         WAERS LIKE ZFVATA1-WAERS,
         DMBTR LIKE ZFVATA1-DMBTR,
         REMARK LIKE ZFVATA1-REMARK,
         ZSTATUS LIKE ZFVATA1-ZSTATUS,
       END OF T_TA_TABLE.

* INTERNAL TABLE FOR TABLECONTROL 'TA_TABLE'
DATA:     G_TA_TABLE_ITAB   TYPE T_TA_TABLE OCCURS 0,
          G_TA_TABLE_DELE   TYPE T_TA_TABLE OCCURS 0,
          G_TA_TABLE_WA     TYPE T_TA_TABLE, "work area
          G_TA_TABLE_COPIED.           "copy flag
CONTROLS: TA_TABLE TYPE TABLEVIEW USING SCREEN 0900.
DATA:     G_TA_TABLE_LINES  LIKE SY-LOOPC.


*data: begin of t_zfppnnrd occurs 0.
*      include structure zfppnnrd.
*data: belnrrc like zfppnnrh-belnrrc.
*data: end of t_zfppnnrd.
*
*data: begin of t_zfppnnrd1 occurs 0.
*        include structure t_zfppnnrd.
*data: end of t_zfppnnrd1.
