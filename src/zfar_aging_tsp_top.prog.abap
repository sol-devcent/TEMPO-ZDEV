*----------------------------------------------------------------------*
*   INCLUDE ZFAR_AGING_TSP_TOP                                         *
*----------------------------------------------------------------------*

TABLES: bsid, bsad, kna1, tgsbt, t016t.

TYPES: BEGIN OF ta_itab,
         gsber   LIKE bsid-gsber,
         kunnr   LIKE bsid-kunnr,
         augbl   LIKE bsid-augbl,
         brsch   LIKE kna1-brsch,
         hkont   LIKE bsid-hkont,
         gjahr   LIKE bsid-gjahr,
         name1   LIKE kna1-name1,
         blart   LIKE bsid-blart,
         zuonr   LIKE bsid-zuonr,
         belnr   LIKE bsid-belnr,
         monat   LIKE bsid-monat,
*** Modify By Budi 10/03/2006
         bldat   LIKE bsid-bldat,
*** End Modify
         budat   LIKE bsid-budat,
         zfbdt   LIKE bsid-zfbdt,
         augdt   LIKE bsid-augdt,
         zbd1t   LIKE bsid-zbd1t,
         zterm   LIKE bsid-zterm,
         shkzg   LIKE bsid-shkzg,
         zbd1tx(3),
         current LIKE bsid-dmbtr,
         wrbtr   LIKE bsid-wrbtr,
         dmbtr   LIKE bsid-dmbtr,
         dmbtr1  LIKE bsid-dmbtr,
         dmbtr2  LIKE bsid-dmbtr,
         dmbtr3  LIKE bsid-dmbtr,
         dmbtr4  LIKE bsid-dmbtr,
         dmbtr5  LIKE bsid-dmbtr,
       END OF ta_itab.

TYPES: BEGIN OF ta_gsber,
         gsber     LIKE bsid-gsber,
         gtext     LIKE tgsbt-gtext,
         begbal    LIKE bsid-dmbtr,
         netsales  LIKE bsid-dmbtr,
         payment   LIKE bsid-dmbtr,
         endbal    LIKE bsid-dmbtr,
         current   LIKE bsid-dmbtr,
         dmbtr1    LIKE bsid-dmbtr,
         dmbtr2    LIKE bsid-dmbtr,
         dmbtr3    LIKE bsid-dmbtr,
         dmbtr4    LIKE bsid-dmbtr,
         dmbtr5    LIKE bsid-dmbtr,
       END OF ta_gsber.

TYPES: BEGIN OF ta_kunnr,
         objkey(25),
         kunnr     LIKE bsid-kunnr,
         gsber     LIKE bsid-gsber,
         augbl     LIKE bsid-augbl,
         gtext     LIKE tgsbt-gtext,
         name1     LIKE kna1-name1,
         shkzg     LIKE bsid-shkzg,
         gjahr     LIKE bsid-gjahr,
         monat     LIKE bsid-monat,
*** Modify By Budi 10/03/2006
         budat   LIKE bsid-budat,
*** End Modify
         blart     LIKE bsid-blart,
         begbal    LIKE bsid-dmbtr,
         dmbtr     LIKE bsid-dmbtr,
         endbal    LIKE bsid-dmbtr,
         current   LIKE bsid-dmbtr,
         dmbtr1    LIKE bsid-dmbtr,
         dmbtr2    LIKE bsid-dmbtr,
         dmbtr3    LIKE bsid-dmbtr,
         dmbtr4    LIKE bsid-dmbtr,
         dmbtr5    LIKE bsid-dmbtr,
         belnr     LIKE bsid-belnr,
       END OF ta_kunnr.

TYPES: BEGIN OF ta_brsch,
         brsch     LIKE kna1-brsch,
         gsber     LIKE bsid-gsber,
         gtext     LIKE tgsbt-gtext,
         name1     LIKE kna1-name1,
         shkzg     LIKE bsid-shkzg,
         gjahr     LIKE bsid-gjahr,
         monat     LIKE bsid-monat,
*** Modify By Budi 10/03/2006
         budat   LIKE bsid-budat,
*** End Modify
         blart     LIKE bsid-blart,
         begbal    LIKE bsid-dmbtr,
         dmbtr     LIKE bsid-dmbtr,
         endbal    LIKE bsid-dmbtr,
         current   LIKE bsid-dmbtr,
         dmbtr1    LIKE bsid-dmbtr,
         dmbtr2    LIKE bsid-dmbtr,
         dmbtr3    LIKE bsid-dmbtr,
         dmbtr4    LIKE bsid-dmbtr,
         dmbtr5    LIKE bsid-dmbtr,
       END OF ta_brsch.

TYPES: BEGIN OF ta_hkont,
         hkont     LIKE bsid-hkont,
         gsber     LIKE bsid-gsber,
         gtext     LIKE tgsbt-gtext,
         name1     LIKE kna1-name1,
         shkzg     LIKE bsid-shkzg,
         gjahr     LIKE bsid-gjahr,
         monat     LIKE bsid-monat,
*** Modify By Budi 10/03/2006
         budat   LIKE bsid-budat,
*** End Modify
         blart     LIKE bsid-blart,
         begbal    LIKE bsid-dmbtr,
         dmbtr     LIKE bsid-dmbtr,
         endbal    LIKE bsid-dmbtr,
         current   LIKE bsid-dmbtr,
         dmbtr1    LIKE bsid-dmbtr,
         dmbtr2    LIKE bsid-dmbtr,
         dmbtr3    LIKE bsid-dmbtr,
         dmbtr4    LIKE bsid-dmbtr,
         dmbtr5    LIKE bsid-dmbtr,
       END OF ta_hkont.

TYPES: BEGIN OF ta_zuonr,
*         objkey(20), "Modify By sol_jonhar 01/10/2020
         belnr     LIKE bsid-belnr,
         augbl     LIKE bsid-augbl,
         zuonr     LIKE bsid-zuonr,
         objkey(20), "Modify By sol_jonhar 01/10/2020
         kunnr     LIKE bsid-kunnr,
         gsber     LIKE bsid-gsber,
         gtext     LIKE tgsbt-gtext,
         name1     LIKE kna1-name1,
         shkzg     LIKE bsid-shkzg,
         monat     LIKE bsid-monat,
*** Modify By Budi 10/03/2006
         budat   LIKE bsid-budat,
*** End Modify
         blart     LIKE bsid-blart,
         begbal    LIKE bsid-dmbtr,
         dmbtr     LIKE bsid-dmbtr,
         endbal    LIKE bsid-dmbtr,
         current   LIKE bsid-dmbtr,
         dmbtr1    LIKE bsid-dmbtr,
         dmbtr2    LIKE bsid-dmbtr,
         dmbtr3    LIKE bsid-dmbtr,
         dmbtr4    LIKE bsid-dmbtr,
         dmbtr5    LIKE bsid-dmbtr,
         gjahr     LIKE bsid-gjahr,
       END OF ta_zuonr.

DATA:  i_itab    TYPE ta_itab OCCURS 0,
       wa_itab   TYPE ta_itab,
       wa_itab_dz TYPE ta_itab,
       i_itab_rv TYPE ta_itab OCCURS 0,
       i_itab_ab TYPE ta_itab OCCURS 0,
       i_itab_dr TYPE ta_itab OCCURS 0,
       i_itab_da TYPE ta_itab OCCURS 0,
       i_itab_za TYPE ta_itab OCCURS 0,
       i_itab_sa TYPE ta_itab OCCURS 0,
       i_itab_dg TYPE ta_itab OCCURS 0,
*** Modify By Budi 10/03/2006
       i_itab_d1 TYPE ta_itab OCCURS 0,
       i_itab_dz TYPE ta_itab OCCURS 0,
*** End Modify
       i_itab_zc TYPE ta_itab OCCURS 0,
       i_itab_zi TYPE ta_itab OCCURS 0,
       i_itab_zk TYPE ta_itab OCCURS 0,
       i_begbal  TYPE ta_itab OCCURS 0,
       wa_begbal TYPE ta_itab,
       i_gsber   TYPE ta_gsber OCCURS 0,
       wa_gsber  TYPE ta_gsber,
       i_kunnr   TYPE ta_kunnr OCCURS 0,
       wa_kunnr  TYPE ta_kunnr,
       i_brsch   TYPE ta_brsch OCCURS 0,
       wa_brsch  TYPE ta_brsch,
       i_hkont   TYPE ta_hkont OCCURS 0,
       wa_hkont  TYPE ta_hkont,
       i_zuonr   TYPE ta_zuonr OCCURS 0,
       i_augbl   TYPE ta_zuonr OCCURS 0 WITH HEADER LINE,
       wa_zuonr  TYPE ta_zuonr.

DATA:  va_kunnr  LIKE kna1-kunnr,
       va_brsch LIKE kna1-brsch,
       va_hkont LIKE bsik-hkont,
       va_brtxt(31),
       va_txt20(25),
       va_belnr  LIKE bsid-belnr,
       va_gjahr1 LIKE bsid-gjahr,
       va_zuonr  LIKE bsid-zuonr,
       va_augbl  LIKE bsid-augbl.

DATA:  va_gerdat1(8),
       va_gerdat2(8),
       va_gerdat3 TYPE sy-datum,
       va_monat1(2) TYPE n,
       va_monat2(2) TYPE n,
       va_gjahr(4) TYPE n.

DATA:  va_amount   LIKE bsid-dmbtr,
       va_begbal   LIKE bsid-dmbtr,
       va_netsales LIKE bsid-dmbtr,
       va_payment  LIKE bsid-dmbtr,
       va_endbal   LIKE bsid-dmbtr,
       va_name1(25),
       va_gtext(25),
       va_begbal1(18),
       va_customer(35),
       va_currency(3).

DATA:  va_current  LIKE bsid-dmbtr,
       va_dmbtr1   LIKE bsid-dmbtr,
       va_dmbtr2   LIKE bsid-dmbtr,
       va_dmbtr3   LIKE bsid-dmbtr,
       va_dmbtr4   LIKE bsid-dmbtr,
       va_dmbtr5   LIKE bsid-dmbtr.

DATA:  total_begbal   LIKE bsid-dmbtr,
       total_netsales LIKE bsid-dmbtr,
       total_payment  LIKE bsid-dmbtr,
       total_endbal   LIKE bsid-dmbtr,
       total_current  LIKE bsid-dmbtr,
       total_dmbtr1   LIKE bsid-dmbtr,
       total_dmbtr2   LIKE bsid-dmbtr,
       total_dmbtr3   LIKE bsid-dmbtr,
       total_dmbtr4   LIKE bsid-dmbtr,
       total_dmbtr5   LIKE bsid-dmbtr.

DATA: text1(16),
      text2(16),
      text3(16),
      text4(16),
      text5(16).

DATA: va_bulan(2),
      va_tahun(4),
      va_bulan_text(9),
      va_period(13),
      va_count TYPE i.

*** Modify By Budi 10/03/2006
DATA: va_ucomm LIKE sy-ucomm,
      va_clear(1),
      va_dmbtr LIKE bsik-dmbtr.
*** End Modify
RANGES s_blart FOR bsid-blart.


DEFINE m_range.
  clear : s_blart.
  s_blart-sign = 'I'.
  s_blart-low  = &1.
  s_blart-option = 'EQ'.
  append s_blart.
END-OF-DEFINITION.
