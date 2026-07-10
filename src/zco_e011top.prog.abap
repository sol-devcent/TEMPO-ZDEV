*&---------------------------------------------------------------------*
*&  Include  ZCO_E011TOP
*&---------------------------------------------------------------------*

TABLES: ce28010.

TYPES: BEGIN OF ty_ce28010,
         bukrs           TYPE ce28010-bukrs,
         gsber           TYPE ce28010-gsber,
         gjahr           TYPE ce28010-gjahr,
         prctr           TYPE ce28010-prctr,
         rkaufnr         TYPE ce28010-rkaufnr,
         wwsec           TYPE ce28010-wwsec,
         original_budget TYPE ce28010-vv856001,
         rec_waers       TYPE ce28010-rec_waers,
         ktext1          TYPE cepct-ktext,
         ktext2          TYPE aufk-ktext,
         bezek           TYPE t25b5-bezek,
       END OF ty_ce28010.

TYPES: BEGIN OF ty_ce18010,
         rposn           TYPE  ce18010-rposn,
         vv856           TYPE ce18010-vv856,
         budat           TYPE ce18010-budat,
         bukrs           TYPE ce28010-bukrs,
         gsber           TYPE ce18010-gsber,
         gjahr           TYPE ce28010-gjahr,
         prctr           TYPE ce18010-prctr,
         rkaufnr         TYPE ce18010-rkaufnr,
         wwsec           TYPE ce18010-wwsec,
         perio           TYPE ce18010-perio,
         perde           TYPE ce18010-perde,
         rbeln           TYPE ce18010-rbeln,
         paobjnr         TYPE ce18010-paobjnr,
         ebeln           TYPE ekpo-ebeln,
         mon_year        TYPE sy-datum,
         original_budget TYPE ce28010-vv856001,
         rec_waers       TYPE ce18010-rec_waers,
       END OF ty_ce18010.

TYPES: BEGIN OF ty_total_actual,
         total_actual TYPE ce18010-vv856,
         perio        TYPE ce18010-perio,
         rec_waers    TYPE ce18010-rec_waers,
         ebeln        TYPE ekpo-ebeln,
         ebelp        TYPE ekpo-ebelp,
       END OF ty_total_actual.


TYPES: BEGIN OF ty_detl,
         txz01     TYPE ekpo-txz01,
         ebeln     TYPE ekpo-ebeln,
         ebelp     TYPE ekpo-ebelp,
         aedat     TYPE ekpo-aedat,
         netwr     TYPE ekpo-netwr,
         aufnr     TYPE ekkn-aufnr,
         paobjnr   TYPE ekkn-paobjnr,
         prctr     TYPE ekkn-prctr,
         gsber     TYPE ekkn-gsber,
         waers     TYPE ekko-waers,
         rec_waers TYPE ce18010-rec_waers,
         bukrs     TYPE ekko-bukrs,
         gjahr     TYPE bseg-gjahr,
         belnr     TYPE bseg-belnr,
         budat     TYPE ce18010-budat,
         vv856     TYPE ce18010-vv856,
         wwsec     TYPE ce48010_acct-wwsec,
*         wwsec           TYPE ce28010-wwsec,
*         original_budget TYPE ce28010-vv856001,
*         perio           TYPE ce18010-perio,
*         perde           TYPE ce18010-perde,
       END OF ty_detl.

*TYPES: BEGIN OF ty_header,
*         bukrs           TYPE ce28010-bukrs,
*         gsber           TYPE ce28010-gsber,
*         gjahr           TYPE ce28010-gjahr,
*         prctr           TYPE ce28010-prctr,
*         rkaufnr         TYPE ce28010-rkaufnr,
*         wwsec           TYPE ce28010-wwsec,
*         perbl           TYPE ce28010-perbl,
*         rec_waers       TYPE ce28010-rec_waers,
*         original_budget TYPE ce28010-vv856001,
*         spent_budget    TYPE ce18010-vv856,
*         budget_avail    TYPE ce18010-vv856,
*         ktext1          TYPE cepct-ktext,
*         ktext2          TYPE aufk-ktext,
*         bezek           TYPE t25b5-bezek,
*       END OF ty_header.

TYPES: BEGIN OF ty_total_nilai_belum_realisasi,
         total_nilai_belum_realisasi TYPE ekpo-netwr,
         mon_year                    TYPE sy-datum,
         waers                       TYPE ekko-waers,
       END OF ty_total_nilai_belum_realisasi.

TYPES: BEGIN OF ty_budget,
         spent_budget TYPE ce18010-vv856,
         budget_avail TYPE ce18010-vv856,
         rec_waers    TYPE ce18010-rec_waers,
         ebeln        TYPE ekpo-ebeln,
       END OF ty_budget.

TYPES: BEGIN OF ty_total_plan,
         total_plan TYPE ce18010-vv856,
         waers      TYPE ekko-waers,
         gjahr      TYPE ce28010-gjahr,
         perbl      TYPE ce28010-perbl,
       END OF ty_total_plan.

DATA: it_ce28010                     TYPE TABLE OF ty_ce28010,
      it_ce18010                     TYPE TABLE OF ty_ce18010,
      it_total_actual                TYPE TABLE OF ty_total_actual,
      ls_total_actual                TYPE ty_total_actual,
      it_total_nilai_belum_realisasi TYPE TABLE OF ty_total_nilai_belum_realisasi,
      ls_total_nilai_belum_realisasi TYPE ty_total_nilai_belum_realisasi,
      it_detl_helper                 TYPE TABLE OF ty_detl,
      it_bseg                        TYPE TABLE OF bseg,
      it_detl                        TYPE TABLE OF ty_detl,
*      it_header                      TYPE TABLE OF ty_header,

      it_zco_e011_header             TYPE TABLE OF zco_e011_header,
      ls_zco_e011_header             TYPE zco_e011_header,
      it_zco_e011_detl               TYPE TABLE OF zco_e011_detl,
      ls_total_plan                  TYPE ty_total_plan,
      it_total_plan                  TYPE TABLE OF ty_total_plan,
      it_zco_e011_footer             TYPE TABLE OF zco_e011_footer,
      ls_zco_e011_footer             TYPE zco_e011_footer.


DATA: d_layout TYPE slis_layout_alv,
      d_repid  LIKE sy-repid,
      d_print  TYPE slis_print_alv.

DATA: profit_center(255) TYPE c,
      order(255)         TYPE c,
      sec(255)           TYPE c.

DATA: tot_act      TYPE ce18010-vv856,
      belum_real   TYPE ce18010-vv856,
      spent_budget TYPE ce18010-vv856,
      budget_avail TYPE ce18010-vv856.
