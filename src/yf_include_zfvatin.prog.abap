*----------------------------------------------------------------------*
*   INCLUDE YF_INCLUDE_ZFVATIN                                         *
*----------------------------------------------------------------------*

TYPE-POOLS: SLIS.

****************************************************
*        Tables                                    *
****************************************************
Tables: LFA1,
        RBKP,
        BSIK,
        BSIS,
        TGSB,
        ZFVATB1,
        ZFVATB4,
        ZFVATVEND,
        ZFVATB1_TEMP,
        zftax,
        t001,
        BSAS.

************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
* TYPE FOR THE DATA OF TABLECONTROL 'TA_TABLE'
TYPES: BEGIN OF T_TA_TABLE,
         CHECK(1),
         BUKRS LIKE ZFVATB1-BUKRS,
         GSBER LIKE ZFVATB1-GSBER,
         GJAHR LIKE ZFVATB1-GJAHR,
         MONAT LIKE ZFVATB1-MONAT,
         TXDAT LIKE ZFVATB1-TXDAT,
         TBELN LIKE ZFVATB1-TBELN,
         NAME1 LIKE ZFVATB1-NAME1,
         STCEG LIKE ZFVATB1-STCEG,
         SHKZG LIKE ZFVATB1-SHKZG,
         WAERS LIKE ZFVATB1-WAERS,
         MWSBK LIKE ZFVATB1-MWSBK,
         REMARK LIKE ZFVATB1-REMARK,
         ZSTATUS LIKE ZFVATB1-ZSTATUS,
       END OF T_TA_TABLE.

* TYPE FOR THE DATA OF TABLECONTROL 'TA_TABLE1'
TYPES: BEGIN OF T_TA_TABLE1,
         CHECK(1),
         BUKRS LIKE ZFVATB4-BUKRS,
         GSBER LIKE ZFVATB4-GSBER,
         GJAHR LIKE ZFVATB4-GJAHR,
         MONAT LIKE ZFVATB4-MONAT,
         TXDAT LIKE ZFVATB4-TXDAT,
         TBELN LIKE ZFVATB4-TBELN,
         NAME1 LIKE ZFVATB4-NAME1,
         SHKZG LIKE ZFVATB4-SHKZG,
         STCEG LIKE ZFVATB4-STCEG,
         WAERS LIKE ZFVATB4-WAERS,
         MWSBK LIKE ZFVATB4-MWSBK,
         REMARK LIKE ZFVATB4-REMARK,
         ZSTATUS LIKE ZFVATB4-ZSTATUS,
       END OF T_TA_TABLE1.

TYPES:
  BEGIN OF t_excel,
    row   LIKE alsmex_tabline-row,
    col   LIKE alsmex_tabline-col,
    value LIKE alsmex_tabline-value,
  END OF t_excel.

types : Begin of t_itab1,
            bukrs     like bsis-bukrs,
            hkont     like bsis-hkont,
            gjahr     like bsis-gjahr,
            BUDAT     like bsis-budat,
            BLDAT     like bsis-BLDAT,
            WAERS     like bsis-WAERS,
            XBLNR     like bsis-XBLNR,
            BLART     like bsis-BLART,
            MONAT     like bsis-MONAT,
            BSCHL     like bsis-BSCHL,
            SHKZG     like bsis-SHKZG,
            MWSKZ     like bsis-MWSKZ,
            DMBTR     like bsis-dmbtr,
            SGTXT     like bsis-SGTXT,
            ZFBDT     like bsis-zfbdt,
            Belnr     like bsik-belnr,
            LIFNR     like BSIK-LIFNR,
            ZUONR     like BSIK-ZUONR,
            GSBER     like BSIK-GSBER,
            STCD1     like LFA1-STCD1,
            STCEG     like LFA1-STCEG,
            anred     like lfa1-anred,
            name1     like lfa1-name1,
            name2     like lfa1-name2,
            reindat   like RBKP-REINDAT,
        End of t_itab1,

        Begin of t_itab2,
            BUkrs	     Like  Bsis-BUKRS,
            GJAHR	     Like  Bsis-GJAHR,
            BELNR	     Like  Bsis-BELNR,
            BUDAT	     Like  Bsis-BUDAT,
            BLART	     Like  Bsis-BLART,
            SGTXT	     Like  Bsis-SGTXT,
            ZFBDT	     Like  Bsis-ZFBDT,
            LIFNR	     Like  BSIK-LIFNR,
            GSBER	     Like  BSIK-GSBER,
            STCD1	     Like  LFA1-STCD1,
            STCEG	     Like  LFA1-STCEG,
        End of t_itab2,

        Begin of t_itab3,
            BUkrs      Like  BSIS-BUKRS,
            GJAHR      Like  BSIS-GJAHR,
            BELNR      Like  BSIS-BELNR,
            BUDAT      Like  BSIS-BUDAT,
            BLDAT      Like  BSIS-BLDAT,
            XBLNR      Like  BSIS-XBLNR,
            BLART      Like  BSIS-BLART,
            MONAT      Like  BSIS-MONAT,
            BSCHL      Like  BSIS-BSCHL,
            SHKZG      Like  BSIS-SHKZG,
            MWSKZ      Like  BSIS-MWSKZ,
            DMBTR      Like  BSIS-DMBTR,
            SGTXT      Like  BSIS-SGTXT,
            ZFBDT      Like  BSIS-ZFBDT,
            ZUONR      Like  BSIS-ZUONR,
            GSBER      Like  BSIS-GSBER,
            BKTXT      Like  BKPF-BKTXT,
            XREF3      like bsis-xref3,
            TXMTS(1),
            error(30),
        End Of t_itab3,

        Begin of t_itab4,
            BURKS	     Like  ZFVATB4-BUKRS,
            GSBER	     Like  ZFVATB4-GSBER,
            GJAHR	     Like  ZFVATB4-GJAHR,
            TBELN	     Like  ZFVATB4-TBELN,
            MWSBK	     Like  ZFVATB4-MWSBK,
*            LIFNR	     Like  ZFVATB4-LIFNR,
            STCEG	     Like  LFA1-STCEG,
            NPPKP	     Like  LFA1-STCD2,
            BKTXT	     Like  BKPF-BKTXT,
        End of t_itab4,
        Begin of t_itab5,
            BURKS	     Like  BSAS-BUKRS,
            GJAHR	     Like  BSAS-GJAHR,
            BELNR	     Like  BSAS-BELNR,
            BUDAT	     Like  BSAS-BUDAT,
            BLDAT	     Like  BSAS-BLDAT,
            XBLNR	     Like  BSAS-XBLNR,
            BLART	     Like  BSAS-BLART,
            MONAT	     Like  BSAS-MONAT,
            BSCHL	     Like  BSAS-BSCHL,
            SHKZG	     Like  BSAS-SHKZG,
            MWSKZ	     Like  BSAS-MWSKZ,
            DMBTR	     Like  BSAS-DMBTR,
            SGTXT	     Like  BSAS-SGTXT,
            ZFBDT	     Like  BSAS-ZFBDT,
            ZUONR	     Like  BSAS-ZUONR,
            GSBER	     Like  BSAS-GSBER,
            BKTXT	     Like  BKPF-BKTXT,
            TXMTS(1),
        End of t_itab5.

Types: Begin of t_log_error,
            bukrs     like bsis-bukrs,
            hkont     like bsis-hkont,
            gjahr     like bsis-gjahr,
            Belnr     like bsis-belnr,
            msg(80),
       End of t_log_error.
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

Types:   BEGIN OF T_BDC.
          INCLUDE STRUCTURE BDCDATA.
Types:   END OF T_BDC.
Types:   begin of t_messtab.
          include structure bdcmsgcoll.
Types:   end of t_messtab.
TYPES: BEGIN OF TA_ITABB1.
         INCLUDE STRUCTURE ZFVATB1.
TYPES: END OF TA_ITABB1.

TYPES: BEGIN OF TA_ITABB4.
         INCLUDE STRUCTURE ZFVATB4.
TYPES: END OF TA_ITABB4.


************************************************************************
* CONSTANTS                                                            *
************************************************************************
constants :
        c_hkont_200        like bsis-hkont value '0142200200',
        c_hkont_100        like bsis-hkont value '0142200100',
        c_hkont_210        like bsis-hkont value '0142200210',
        c_hkont_220        like bsis-hkont value '0142200220',
        c_blart_RE         like bsis-blart value 'RE',
        c_blart_RC         like bsis-blart value 'RC',
        c_BLART_TR         like bsis-blart value 'TR',
        c_BLART_SA         like bsis-blart value 'SA',
        c_BSCHL_40         Like  BSIS-BSCHL value '40',
        c_BSCHL_50         Like  BSIS-BSCHL value '50',
        c_WAERS_idr        like bsis-WAERS value 'IDR',
        c_AUGTX(30)        Value 'VAT - input Reconciliation'.
constants: c_hkont         like bsis-hkont value '0142200210'.
************************************************************************
* VARIABLES                                                            *
************************************************************************
* Helpers/auxilliaries
data: I_ITABB1   TYPE TA_ITABB1  OCCURS 0,
      WA_ITABB1  TYPE TA_ITABB1,
      I_DELE     TYPE TA_ITABB1  OCCURS 0,
      WA_DELE    TYPE TA_ITABB1,
      I_ERROR    TYPE TA_ITABB1  OCCURS 0,
      WA_ERROR   TYPE TA_ITABB1,
      I_ITABB4   TYPE TA_ITABB4  OCCURS 0,
      WA_ITABB4  TYPE TA_ITABB4,
      I_ITAB     TYPE TA_ITAB OCCURS 0,
      WA_ITAB    TYPE TA_ITAB,
      i_itabt    TYPE ta_itabt OCCURS 0,
      wa_itabt   TYPE ta_itabt,
      i_excel    TYPE t_excel OCCURS 0,
      wa_excel   TYPE t_excel,
      WA_ZFVATB1_TEMP LIKE ZFVATB1_TEMP.

DATA: I_ERROR1    TYPE TA_ERROR OCCURS 0,
      WA_ERROR1   TYPE TA_ERROR.

data: va_ke(9), va_ctr type i.
data: xoption like ITCPP, xoption2 like ITCPO.
  data: begin of ta_b1 occurs 0.
          include structure zfvatb1.
  data: end of ta_b1.
  data: begin of ta_b1_hdr occurs 0.
          include structure zfvatb1.
  data: end of ta_b1_hdr.
  data: begin of ta_b1_dtl occurs 0.
          include structure zfvatb1.
  data: end of ta_b1_dtl.

  data: begin of ta_b4 occurs 0.
          include structure zfvatb4.
  data: end of ta_b4.
  data: begin of ta_b4_hdr occurs 0.
          include structure zfvatb4.
  data: end of ta_b4_hdr.
  data: begin of ta_b4_dtl occurs 0.
          include structure zfvatb4.
  data: end of ta_b4_dtl.

  data: va_prd(10), va_thn(4), va_no type i,
        va_totaL   LIKE ZFVATB1-MWSBK,
        va_line    type i,
        va_tot_mts type p,
        va_tot     type p,
        va_tot_oth type p,
        va_positif LIKE ZFVATB1-MWSBK,
        va_negatif LIKE ZFVATB1-MWSBK,
        va_tot_41  LIKE ZFVATB1-MWSBK,
        VA_TOT_POS41 LIKE ZFVATB1-MWSBK,
        VA_TOT_NEG41 LIKE ZFVATB1-MWSBK,
        va_tot_42  LIKE ZFVATB1-MWSBK,
        VA_TOT_POS42 LIKE ZFVATB1-MWSBK,
        VA_TOT_NEG42 LIKE ZFVATB1-MWSBK,
        va_tot_43  LIKE ZFVATB1-MWSBK,
        VA_TOT_POS43 LIKE ZFVATB1-MWSBK,
        VA_TOT_NEG43 LIKE ZFVATB1-MWSBK,
        va_tot_44  LIKE ZFVATB1-MWSBK,
        VA_TOT_POS44 LIKE ZFVATB1-MWSBK,
        VA_TOT_NEG44 LIKE ZFVATB1-MWSBK,
        va_tot_47  LIKE ZFVATB1-MWSBK,
        VA_TOT_POS47 LIKE ZFVATB1-MWSBK,
        VA_TOT_NEG47 LIKE ZFVATB1-MWSBK,
        VA_MASUK LIKE ZFVATB1-MWSBK,
        VA_TOTAL1 LIKE ZFVATB1-MWSBK.

DATA: va_name(128).

TYPES: BEGIN OF T_DWN_FIELD,
         TXT_FIELD(40),
       END OF T_DWN_FIELD.

DATA: WA_DWN_FIELD TYPE T_DWN_FIELD,
      DWN_FIELD TYPE  T_DWN_FIELD OCCURS 0.

ranges: ta_date for zfvatb4-txdat.

data: i_itab1 type t_itab1 occurs 0,
      wa_itab1 type t_itab1,
      i_itab2 type t_itab2 occurs 0,
      wa_itab2 type t_itab2,
      i_itab3 type t_itab3 occurs 0,
      i_itab3_err type t_itab3 occurs 0,
      wa_itab3 type t_itab3,
      I_itab3A type t_itab3 OCCURS 0,
      wa_itab3A type t_itab3,
      I_itab3B type t_itab3 OCCURS 0,
      wa_itab3B type t_itab3,
      i_itab4 type t_itab4 occurs 0,
      wa_itab4 type t_itab4,
      i_itab5 type t_itab5 occurs 0,
      wa_itab5 type t_itab5,
      tot_dmbtr like bsis-dmbtr,
      grand_dmbtr like  bsis-dmbtr,
      i_log_error type t_log_error occurs 0,
      wa_log_error type t_log_error,
      msg(80),
      va_BSCHL     Like  BSIS-BSCHL,
      i_messtab type t_messtab occurs 0,
      wa_messtab type t_messtab,
      i_bdc type T_BDC occurs 0,
      wa_bdc type t_bdc,
      va_mode(1),
      va_xref3  like bsis-xref3,
      va_xref341  like bsis-xref3,
      va_xref342  like bsis-xref3,
      va_xref343  like bsis-xref3,
      va_xref344  like bsis-xref3,
      va_xref345  like bsis-xref3,
      va_xref346  like bsis-xref3,
      va_xref347  like bsis-xref3,
      va_xref348  like bsis-xref3,
      va_xref349  like bsis-xref3,
      va_hkont1 like bsis-hkont,
      va_hkont2 like bsis-hkont.

DATA  va_cnt type i.
data  va_BLART         like bsis-blart.
DATA: VA_BETUL      LIKE WA_ITAB-PEMBTL,
      VA_GJAHR      LIKE WA_ITAB-THNPJK,
      VA_KDLAMP     LIKE WA_ITAB-KDLAMP,
      VA_KDSTAT     LIKE WA_ITAB-KDSTAT,
      VA_NPWP       LIKE ZFVATB1-STCEG,
      VA_NMWP       LIKE WA_ITAB-NMWP,
      VA_KDDOCU     LIKE WA_ITAB-KDDOCU,
      VA_KDFKTR     LIKE WA_ITAB-KDFKTR,
      VA_NOFKTR     LIKE WA_ITAB-NOFKTR,
      VA_TGLFKT     LIKE WA_ITAB-TGLFKT,
      VA_NILPPN     LIKE WA_ITAB-NILPPN,
      VA_NILPPNBM   LIKE WA_ITAB-NILPPNBM.

DATA: V_KDLAMP   LIKE TA_EXCEL-KDLAMP,
      V_BETUL    LIKE TA_EXCEL-PEMBTL,
      V_KDSTAT   LIKE TA_EXCEL-KDSTAT,
      V_NPWP     LIKE TA_EXCEL-NPWP,
      V_NPWP_IN  LIKE ZFVATB1-STCEG,
      V_NPWP_OUT LIKE ZFVATB1-STCEG,
      V_NMWP     LIKE TA_EXCEL-NMWP,
      V_KDDOCU   LIKE TA_EXCEL-KDDOCU,
      V_KDFKTR   LIKE TA_EXCEL-KDFKTR,
      V_KDKPP    LIKE TA_EXCEL-KDKPP,
      V_NOFKTR   LIKE TA_EXCEL-NOFKTR,
      V_TGLFKT   LIKE TA_EXCEL-TGLFKT,
      V_NILPPN   TYPE P,
      V_NILPPNBM LIKE TA_EXCEL-NILPPNBM.

DATA: v_space      TYPE I,
      v_len        TYPE I,
      CNTR         TYPE I,
      FLAG(1),
      OPTION   TYPE I,
      CANC(1),
      COUNTER      TYPE I,
      SIZE         TYPE I,
      ERROR        TYPE I.

data:
       c1    type i,
       w1    type i,  w2    type i,  w3    type i,  w4    type i,
       w5    type i,  w6    type i,  w7    type i,  w8    type i,
       w9    type i,  w10   type i,  w11   type i,  w12   type i,
       w13   type i,  w14   type i,  w15   type i,  w16   type i,
       w17   type i,  w18   type i,  w19   type i,  w19a  type i,
       w20   type i,  w17a  type i,
       w21   type i,  w22   type i,  w23   type i,  w24   type i,
       w25   type i,  w26   type i,  w27   type i,  w28   type i,
       w29   type i,  w30   type i,  w31   type i,  w32   type i,
       w33   type i,  w34   type i,  w35   type i.

DATA: FPSD TYPE I,
      NOURUT   TYPE I.

DATA: MWSBK(13),
      TOTAL(17),
      TOTAL1(17),
      MASUK(17),
      TOT_41(17),
      TOT_42(17),
      TOT_43(17),
      TOT_44(17),
      TOT_47(17),
      NEGATIF(17).

DATA: TAB_AGKO LIKE AGKO OCCURS 0 WITH HEADER LINE.

DATA: GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
      G_EXIT_CAUSED_BY_CALLER,
      GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
      G_REPID LIKE SY-REPID.

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

* INTERNAL TABLE FOR TABLECONTROL 'TA_TABLE'
DATA:     G_TA_TABLE_ITAB   TYPE T_TA_TABLE OCCURS 0,
          G_TA_TABLE_WA     TYPE T_TA_TABLE, "work area
          G_TA_TABLE_COPIED.           "copy flag

* DECLARATION OF TABLECONTROL 'TA_TABLE' ITSELF
CONTROLS: TA_TABLE TYPE TABLEVIEW USING SCREEN 0900.

* LINES OF TABLECONTROL 'TA_TABLE'
DATA:     G_TA_TABLE_LINES  LIKE SY-LOOPC.

* INTERNAL TABLE FOR TABLECONTROL 'TA_TABLE1'
DATA:     G_TA_TABLE1_ITAB   TYPE T_TA_TABLE1 OCCURS 0,
          G_TA_TABLE1_WA     TYPE T_TA_TABLE1, "work area
          G_TA_TABLE1_COPIED.           "copy flag

* DECLARATION OF TABLECONTROL 'TA_TABLE1' ITSELF
CONTROLS: TA_TABLE1 TYPE TABLEVIEW USING SCREEN 0910.

* LINES OF TABLECONTROL 'TA_TABLE1'
DATA:     G_TA_TABLE1_LINES  LIKE SY-LOOPC.

DATA:     OK_CODE LIKE SY-UCOMM,
          SAVE_OK LIKE OK_CODE.

data:  VA_BUKRS LIKE ZFVATB4-BUKRS.
