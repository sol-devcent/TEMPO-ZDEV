FUNCTION-POOL ZQDRS MESSAGE-ID QD.

TABLES:
  QDPA,
  QDPP.
* qdps.
* qdsv.
*
DATA:
*-----------------------------------------------------------------------
* Hilfsfelder
*-----------------------------------------------------------------------
* Konstanten
  C_LOSUMF_MAX         TYPE F                 VALUE 10000000000,
* Schalter
  C_JA                 TYPE C                 VALUE 'J',
  C_NEIN               TYPE C                 VALUE 'N',
* Zeichen
  C_KREUZ                                     VALUE 'X',
* Variablen
  G_KZSKIP             LIKE QDPS-KZSKIP,
  G_LOSMENGE_F         TYPE F,
  G_MOD_F              TYPE F,
  G_PRSCHAERFE         LIKE QDPS-PRSCHAERFE,
  G_ZAEHLPOS           LIKE QDPP-ZAEHLPOS,
* Prüfpunktausprägungen
  G_KZRAST             LIKE QDSV-KZRAST,
  C_OHNE               LIKE QDSV-KZRAST        VALUE ' ',
  C_FE                 LIKE QDSV-KZRAST        VALUE 'X',
  C_PM                 LIKE QDSV-KZRAST        VALUE '1',
  C_PROB               LIKE QDSV-KZRAST        VALUE '2',
*-----------------------------------------------------------------------
* Zahlen
*-----------------------------------------------------------------------
* Zahlen fuer SUBRC
  C_RC_0               LIKE SY-SUBRC          VALUE 0,
  C_RC_1               LIKE SY-SUBRC          VALUE 1,
* Zahlendefinition (integer)
  C_I_0                LIKE SY-TABIX          VALUE 0,
  C_I_1                LIKE SY-TABIX          VALUE 1,
* Zahlendefinition (character)
  C_C_4                TYPE C                 VALUE '4',
* Zahlendefinition (FLTP)
  C_F_0                TYPE F                 VALUE 0,
  C_F_1                TYPE F                 VALUE 1,
*-----------------------------------------------------------------------
* Interne Tabellen
*-----------------------------------------------------------------------
* Memorytabelle bereits gelesener AQL-Werte
  BEGIN OF G_AQL_TAB OCCURS 10,
    STPRPLAN   LIKE QDPP-STPRPLAN,
    AQLWERT    LIKE QDPP-AQLWERT,
    ZAEHLPOS   LIKE QDPP-ZAEHLPOS,
  END   OF G_AQL_TAB,
* Memorytabelle bereits gelesener Stichprobenanweisungen
  BEGIN OF G_ANW_TAB OCCURS 0,
    GRUNDGESAMTHEIT TYPE F,
    STPRPLAN        LIKE QDPA-STPRPLAN,
    ZAEHLPOS        LIKE QDPA-ZAEHLPOS,
    PRSCHAERFE      LIKE QDPA-PRSCHAERFE,
    STPRUMF         LIKE QDPA-STPRUMF,
    ANNAHMEZ        LIKE QDPA-ANNAHMEZ,
    RUECKWEZ        LIKE QDPA-RUECKWEZ,
    KFAKTOR         LIKE QDPA-KFAKTOR,
    KFAKTORNI       LIKE QDPA-KFAKTORNI,
    STPRANZ         LIKE QDPA-STPRANZ,
  END   OF G_ANW_TAB.

* INT2 -> INT4 Problematik EE
  INCLUDE MQEEAT99.

*
