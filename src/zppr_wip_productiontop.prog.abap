*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,marc,makt,aufk,afko,afpo,zdgppedt003.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gd_month_beg LIKE sy-datum,
      gd_month_end LIKE sy-datum,
      gd_werks_name TYPE name1.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_main OCCURS 0,
        werks	TYPE werks_d,
        maktx TYPE maktx,
        meins TYPE meins,
        matnr TYPE matnr,
        bstfe TYPE bstfe,
        wipmg TYPE zwipmg,
        wipbch TYPE bstfe,
        spmon TYPE spmon,
        charg TYPE charg_d,
        aufnr TYPE aufnr,
        ebelp TYPE ebelp,
        aufnr1 TYPE char16,
        wipmgdtl TYPE zwipmg,
*        charg  TYPE char100,
*        aufnr  TYPE char100,
      END OF gt_main.
DATA: gt_main_tmp LIKE gt_main OCCURS 0.

DATA: gt_jest TYPE STANDARD TABLE OF jest,
      wa_jest TYPE jest.

DATA: BEGIN OF gt_aufk OCCURS 0,
        aufnr TYPE aufnr,
        werks	TYPE werks_d,
        objnr	TYPE j_objnr,
      END OF gt_aufk.

DATA: BEGIN OF gt_afko OCCURS 0,
        aufnr TYPE aufnr,
        gltrp	TYPE co_gltrp,
        posnr	TYPE co_posnr,
        psmng	TYPE co_psmng,
        wemng	TYPE co_wemng,
        matnr TYPE matnr,
        charg TYPE charg_d,
        objnr	TYPE j_objnr,
        spmon TYPE spmon,
        werks	TYPE werks_d,
      END OF gt_afko.

DATA: BEGIN OF gt_matnr OCCURS 0,
        matnr TYPE matnr,
      END OF gt_matnr.

DATA: BEGIN OF gt_mara OCCURS 0,
        matnr TYPE matnr,
        maktx TYPE maktx,
        meins TYPE meins,
      END OF gt_mara.

DATA: BEGIN OF gt_marc OCCURS 0,
        matnr	TYPE matnr,
        werks	TYPE werks_d,
        bstfe	TYPE bstfe,
      END OF gt_marc.

DATA: BEGIN OF gt_t003 OCCURS 0.
        INCLUDE STRUCTURE zdgppedt003.
DATA: END OF gt_t003.

DATA: BEGIN OF gt_ekpo OCCURS 0,
        ebeln TYPE  ebeln,
        ebelp TYPE  ebelp,
        matnr TYPE  matnr,
        bukrs TYPE  bukrs,
        werks TYPE  ewerk,
        lgort TYPE  lgort_d,
        elikz TYPE  elikz,
        menge TYPE  etmen,
        wemng TYPE  weemg,
        bedat TYPE  etbdt,
        eindt TYPE  eindt,
        charg TYPE  charg_d,
        spmon TYPE  spmon,
      END OF gt_ekpo.

DATA: gt_t007 TYPE TABLE OF zdgppedt007 WITH HEADER LINE.

*----------------------------------------------------------*
* Constants
*----------------------------------------------------------*
CONSTANTS: c_autyp TYPE auftyp VALUE '40',
           c_teco	 TYPE j_status VALUE 'I0045',   "TECO
           c_dlfl	 TYPE j_status VALUE 'I0076',   "DLFL
           c_zpha	 TYPE mtart VALUE 'ZPHA'.       "ZPHA

*----------------------------------------------------------*
* Field Simbols
*----------------------------------------------------------*
FIELD-SYMBOLS: <fs_t003> TYPE zdgppedt003,
               <fs_aufk> LIKE gt_aufk,
               <fs_afko> LIKE gt_afko,
               <fs_ekpo> LIKE gt_ekpo,
               <fs_main> LIKE gt_main.
