*----------------------------------------------------------------------*
*   INCLUDE ZFR_FAKTUR_TERBUKA_TOP                                     *
*----------------------------------------------------------------------*

  TYPE-POOLS: slis.

  TABLES: bsid, kna1, knvv, tgsbt, t001, tvbur.

  TYPES: BEGIN OF ta_itab,
           vkbur     LIKE knvv-vkbur,
           vwerk     LIKE knvv-vwerk,
           period(6) TYPE n,
           belnr     LIKE bsid-belnr,
           buzei     LIKE bsid-buzei,
           zuonr     LIKE bsid-zuonr,
           augbl     LIKE bsid-augbl,
           gsber     LIKE bsid-gsber,
           gjahr     LIKE bsid-gjahr,
           kunnr     LIKE bsid-kunnr,
           kdgrp     LIKE knvv-kdgrp,
           budat     LIKE bsid-budat,
           monat     LIKE bsid-monat,
           blart     LIKE bsid-blart,
           zfbdt     LIKE bsid-zfbdt,
           zterm     LIKE bsid-zterm,
           shkzg     LIKE bsid-shkzg,
           dmbtr     LIKE bsid-dmbtr,
           dmbtr1    LIKE bsid-dmbtr,
           kolom1    LIKE bsid-dmbtr,
           kolom2    LIKE bsid-dmbtr,
           kolom3    LIKE bsid-dmbtr,
           kolom4    LIKE bsid-dmbtr,
           kolom5    LIKE bsid-dmbtr,
           kolom6    LIKE bsid-dmbtr,
           kolom7    LIKE bsid-dmbtr,
           kolom8    LIKE bsid-dmbtr,
           other     LIKE bsid-dmbtr,
           cpudt     LIKE bsid-cpudt,
           umskz     LIKE bsid-umskz,
           xref2     LIKE bsid-xref2,
           anln1     LIKE bsid-anln1,
           vbeln     LIKE bsid-vbeln,
         END OF ta_itab.

  TYPES: BEGIN OF ta_belnr,
           belnr  LIKE bsid-belnr,
           zuonr  LIKE bsid-zuonr,
           shkzg  LIKE bsid-shkzg,
           kunnr  LIKE bsid-kunnr,
           kolom1 LIKE bsid-dmbtr,
           kolom2 LIKE bsid-dmbtr,
           kolom3 LIKE bsid-dmbtr,
           kolom4 LIKE bsid-dmbtr,
           kolom5 LIKE bsid-dmbtr,
           kolom6 LIKE bsid-dmbtr,
           kolom7 LIKE bsid-dmbtr,
           kolom8 LIKE bsid-dmbtr,
           other  LIKE bsid-dmbtr,
           saldo  LIKE bsid-dmbtr,
         END OF ta_belnr.

  DATA: BEGIN OF i_outpl OCCURS 0,
          vkbur(4),
          period(8),
          kolom1    LIKE bsid-dmbtr,
          kolom2    LIKE bsid-dmbtr,
          kolom3    LIKE bsid-dmbtr,
          kolom4    LIKE bsid-dmbtr,
          kolom5    LIKE bsid-dmbtr,
          kolom6    LIKE bsid-dmbtr,
          kolom7    LIKE bsid-dmbtr,
          kolom8    LIKE bsid-dmbtr,
          other     LIKE bsid-dmbtr,
          saldo     LIKE bsid-dmbtr.
  DATA:   END OF i_outpl.

  DATA: BEGIN OF i_dataset OCCURS 0,
          vkbur(4),
          period(13),
          kolom1(15),
          kolom2(15),
          kolom3(15),
          kolom4(15),
          kolom5(15),
          kolom6(15),
          kolom7(15),
          kolom8(15),
          other(15),
          saldo(15).
  DATA:   END OF i_dataset.

  DATA: i_itab   TYPE ta_itab OCCURS 0,
        wa_itab  TYPE ta_itab,
        i_itab1  TYPE ta_itab OCCURS 0,
        wa_itab1 TYPE ta_itab,
        i_cek    TYPE ta_itab OCCURS 0,
        wa_cek   TYPE ta_itab,
        i_all    TYPE ta_itab OCCURS 0,
        wa_all   TYPE ta_itab,
        i_all1   TYPE ta_itab OCCURS 0,
        wa_all1  TYPE ta_itab,
        i_belnr  TYPE ta_belnr OCCURS 0,
        wa_belnr TYPE ta_belnr,
        i_itab3  TYPE ta_itab OCCURS 0,
        wa_itab3 TYPE ta_itab.

  DATA: zebra  TYPE i,
        zebra1 TYPE i,
        sw     TYPE i,
        sw1    TYPE i.

  DATA: va_monat1(2)  TYPE n,
        va_monat2(2)  TYPE n,
        va_gjahr(4)   TYPE n,
        va_gerdat1(8),
        va_gerdat2(8).

  DATA: va_gsber      LIKE bsid-gsber,
        va_gsber1     LIKE bsid-gsber,
        va_zuonr      LIKE bsid-zuonr,
        va_butxt      LIKE t001-butxt,
        va_gtext      LIKE tgsbt-gtext,
        va_belnr(10),
        va_zuonr1(18).

  DATA: va_bulan(2),
        va_bulan1(2),
        va_bulan2(3),
        va_bulan3(2),
        va_bulan_text(3),
        va_bulan_text1(9),
        va_period(13),
        va_period1(17).

  DATA: kolom1      LIKE bsid-dmbtr,
        kolom2      LIKE bsid-dmbtr,
        kolom3      LIKE bsid-dmbtr,
        kolom4      LIKE bsid-dmbtr,
        kolom5      LIKE bsid-dmbtr,
        kolom6      LIKE bsid-dmbtr,
        kolom7      LIKE bsid-dmbtr,
        kolom8      LIKE bsid-dmbtr,
        other       LIKE bsid-dmbtr,
        kolom_saldo LIKE bsid-dmbtr.

*  DATA:   KOLOM1      TYPE P,
*          KOLOM2      TYPE P,
*          KOLOM3      TYPE P,
*          KOLOM4      TYPE P,
*          KOLOM5      TYPE P,
*          KOLOM6      TYPE P,
*          KOLOM7      TYPE P,
*          KOLOM8      TYPE P,
*          OTHER       TYPE P,
*          KOLOM_SALDO TYPE P.

  DATA: belnr_kolom1 LIKE bsid-dmbtr,
        belnr_kolom2 LIKE bsid-dmbtr,
        belnr_kolom3 LIKE bsid-dmbtr,
        belnr_kolom4 LIKE bsid-dmbtr,
        belnr_kolom5 LIKE bsid-dmbtr,
        belnr_kolom6 LIKE bsid-dmbtr,
        belnr_kolom7 LIKE bsid-dmbtr,
        belnr_kolom8 LIKE bsid-dmbtr,
        belnr_other  LIKE bsid-dmbtr,
        belnr_saldo  LIKE bsid-dmbtr.

  DATA: total_kolom1      LIKE bsid-dmbtr,
        total_kolom2      LIKE bsid-dmbtr,
        total_kolom3      LIKE bsid-dmbtr,
        total_kolom4      LIKE bsid-dmbtr,
        total_kolom5      LIKE bsid-dmbtr,
        total_kolom6      LIKE bsid-dmbtr,
        total_kolom7      LIKE bsid-dmbtr,
        total_kolom8      LIKE bsid-dmbtr,
        total_other       LIKE bsid-dmbtr,
        total_kolom_saldo LIKE bsid-dmbtr.

*  DATA:   TOTAL_KOLOM1      TYPE P,
*          TOTAL_KOLOM2      TYPE P,
*          TOTAL_KOLOM3      TYPE P,
*          TOTAL_KOLOM4      TYPE P,
*          TOTAL_KOLOM5      TYPE P,
*          TOTAL_KOLOM6      TYPE P,
*          TOTAL_KOLOM7      TYPE P,
*          TOTAL_KOLOM8      TYPE P,
*          TOTAL_OTHER       TYPE P,
*          TOTAL_KOLOM_SALDO TYPE P.

  DATA: va_kolom1      LIKE bsid-dmbtr,
        va_kolom2      LIKE bsid-dmbtr,
        va_kolom3      LIKE bsid-dmbtr,
        va_kolom4      LIKE bsid-dmbtr,
        va_kolom5      LIKE bsid-dmbtr,
        va_kolom6      LIKE bsid-dmbtr,
        va_kolom7      LIKE bsid-dmbtr,
        va_kolom8      LIKE bsid-dmbtr,
        va_other       LIKE bsid-dmbtr,
        va_kolom_saldo LIKE bsid-dmbtr.

  DATA:   canc(1),
          filename(128),
          size           TYPE i.

  DATA: c1  TYPE i,
        w0  TYPE i,
        w1  TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
        w5  TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
*{   INSERT         P01K900245                                        1
        w9a TYPE i,
*}   INSERT
        w9  TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i.


  DATA: BEGIN OF i_out OCCURS 0,
* show
          vkbur      LIKE knvv-vkbur,
          bezei      LIKE tnlst-bezei,
          gtext      LIKE tgsbt-gtext,
          period(13),
          zfbdt      LIKE bsid-zfbdt,
          zterm      LIKE bsid-zterm,
          duedt      LIKE bsid-zfbdt,
          name1(50),
          kdgrp      LIKE knvv-kdgrp,
          belnr      LIKE bsid-belnr,
          zuonr      LIKE bsid-zuonr,
          anln1      LIKE bsid-anln1,
          budat      LIKE bsid-budat,
          xref2      LIKE bsid-xref2,
          klimk      LIKE knkk-klimk,
          duedtbi    LIKE zfbicheck-duedt,
          wrbtrbi    LIKE zfbicheck-wrbtr,
          fkart      LIKE vbrk-fkart,
          kolom01    LIKE bsid-dmbtr,
          kolom02    LIKE bsid-dmbtr,
          kolom03    LIKE bsid-dmbtr,
          kolom04    LIKE bsid-dmbtr,
          kolom05    LIKE bsid-dmbtr,
          kolom06    LIKE bsid-dmbtr,
          kolom07    LIKE bsid-dmbtr,
          kolom08    LIKE bsid-dmbtr,
          kolom09    LIKE bsid-dmbtr,
          kolom10    LIKE bsid-dmbtr,
          kolom11    LIKE bsid-dmbtr,
          kolom12    LIKE bsid-dmbtr,
          kolom13    LIKE bsid-dmbtr,
          kolom14    LIKE bsid-dmbtr,
          kolom15    LIKE bsid-dmbtr,
          kolom16    LIKE bsid-dmbtr,
          kolom17    LIKE bsid-dmbtr,
          kolom18    LIKE bsid-dmbtr,
          kolom19    LIKE bsid-dmbtr,
          kolom20    LIKE bsid-dmbtr,
          kolom21    LIKE bsid-dmbtr,
          kolom22    LIKE bsid-dmbtr,
          kolom23    LIKE bsid-dmbtr,
          kolom24    LIKE bsid-dmbtr,
          kolom25    LIKE bsid-dmbtr,
          kolom26    LIKE bsid-dmbtr,
          kolom99    LIKE bsid-dmbtr,
          dmbtr_rv   LIKE bsid-dmbtr,
* hidden
          gjahr      LIKE bsid-gjahr,
          kunnr      LIKE knvv-kunnr,
          dmbtr      LIKE bsid-dmbtr,
          janytd     LIKE bsid-dmbtr,
          febytd     LIKE bsid-dmbtr,
          marytd     LIKE bsid-dmbtr,
          aprytd     LIKE bsid-dmbtr,
          meiytd     LIKE bsid-dmbtr,
          junytd     LIKE bsid-dmbtr,
          julytd     LIKE bsid-dmbtr,
          augytd     LIKE bsid-dmbtr,
          sepytd     LIKE bsid-dmbtr,
          oktytd     LIKE bsid-dmbtr,
          novytd     LIKE bsid-dmbtr,
          desytd     LIKE bsid-dmbtr,
          aging      TYPE int2,
          tglttf     LIKE zfbid-tglttf,
          leadttf    TYPE zint2,
          rlcn(255),
          awal       TYPE vbrk-netwr,

          noarp      TYPE zfarpotd-noarp,
          rtvnr      TYPE zfarpotd-rtvnr,
        END OF i_out.

  DATA: BEGIN OF i_tvkol OCCURS 0,
          vstel   LIKE tvkol-vstel,
          live    LIKE zplbc-live,
          mixlive LIKE zplbc-mixlive,
          werks   LIKE tvkol-werks,
          lgort   LIKE tvkol-lgort,
        END OF i_tvkol.

  DATA: BEGIN OF gt_zfbid OCCURS 0.
          INCLUDE STRUCTURE zfbid.
        DATA: END OF gt_zfbid.

  RANGES: ta_date FOR bsid-budat.

  DATA: va_switch  TYPE i.

* Data untuk ALV
  DATA: i_fieldcat_alv  TYPE slis_t_fieldcat_alv,
        i_events        TYPE slis_t_event,
        i_list_comments TYPE slis_t_listheader.

  DATA: ta_sort          TYPE slis_t_sortinfo_alv,
        w_variant        LIKE disvariant,
        w_repid          LIKE sy-repid,
        w_callback_ucomm TYPE slis_formname VALUE 'CALLBACK_UCOMM',
        w_print          TYPE slis_print_alv,
        w_layout         TYPE slis_layout_alv,
        w_fieldcat_alv   LIKE LINE OF i_fieldcat_alv,
        w_events         LIKE LINE OF i_events,
        w_list_comments  LIKE LINE OF i_list_comments.

  DATA: BEGIN OF t_zfarsoff_dele OCCURS 0.
          INCLUDE STRUCTURE zfarsoff.
        DATA: END OF t_zfarsoff_dele.
  DATA: BEGIN OF t_zfarsoff_add OCCURS 0.
          INCLUDE STRUCTURE zfarsoff.
        DATA: END OF t_zfarsoff_add.

  DATA  i_itab_add TYPE ta_itab OCCURS 0.

  DATA: gt_knkk      TYPE STANDARD TABLE OF knkk,
        gt_knvpzc    TYPE STANDARD TABLE OF knvp,
        gt_knvpzp    TYPE STANDARD TABLE OF knvp,
        gt_pa0001    TYPE STANDARD TABLE OF pa0001,
        gt_vbrk      TYPE STANDARD TABLE OF vbrk,
        gt_zfbicheck TYPE STANDARD TABLE OF zfbicheck,
        gt_zfbic_sfa TYPE STANDARD TABLE OF zfbic_sfa,
        gt_hsales    TYPE STANDARD TABLE OF zsl_hsales,
        gt_bsid      TYPE ta_itab OCCURS 0.

  DATA : gt_xvbak    TYPE STANDARD TABLE OF vbak,
         gt_xvbrp    TYPE STANDARD TABLE OF vbrp,
         gt_xvbfa    TYPE STANDARD TABLE OF vbfa,
         gt_zfarpotd TYPE STANDARD TABLE OF zfarpotd,
         gt_zfarpoth TYPE STANDARD TABLE OF zfarpoth.
