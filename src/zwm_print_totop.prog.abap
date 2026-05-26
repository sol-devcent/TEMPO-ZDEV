*----------------------------------------------------------------------*
*   INCLUDE ZWM_PRINT_TOTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, ltak, ltap, ssfpp, tsp03, vttp, likp.

TYPES : BEGIN OF ty_footer,
          tknum TYPE vttk-tknum,
          kober TYPE lagp-kober,
          lznum TYPE ltak-lznum,
          vbeln TYPE vttp-vbeln,
        END OF ty_footer.

TYPES BEGIN OF ty_out.
INCLUDE STRUCTURE zwmprntto.
TYPES  new.
TYPES  style   TYPE lvc_t_styl.
TYPES END OF ty_out.

TYPES : BEGIN OF ty_pall,
          pallet TYPE p DECIMALS 0,
        END OF ty_pall.

TYPES : BEGIN OF ty_likp,
          vbeln TYPE likp-vbeln,
          kunnr TYPE likp-kunnr,
          name1 TYPE adrc-name1,
          tragr TYPE likp-tragr,
          route TYPE likp-route,
          lfart TYPE likp-lfart,
          lifex TYPE likp-lifex,
        END OF ty_likp.

TYPES : BEGIN OF ty_xlikp.
          INCLUDE STRUCTURE likp.
          TYPES :   tanum      TYPE ltak-tanum,
          druck      TYPE ltak-druck,
          noitm      TYPE ltak-noitm,
          shipt      TYPE kna1-name1,
          soldt      TYPE kna1-name1,
          empst      TYPE lips-empst,
          sel,
          check,
          icon(4),
          style      TYPE lvc_t_styl,
          awbfile(1),
**          awbimage(1),
        END OF ty_xlikp.

TYPES: BEGIN OF ty_lprio,
         tknum TYPE vttp-tknum,
         tpnum TYPE vttp-tpnum,
         vbeln TYPE vttp-vbeln,
*         kunnr TYPE likp-kunnr,
         lprio TYPE likp-lprio,
         lgnum TYPE ltak-lgnum,
         tanum TYPE ltak-tanum,
         tapri TYPE ltak-tapri,
         lznum TYPE ltak-lznum,
         check TYPE char1,
         style TYPE lvc_t_styl,
       END OF ty_lprio.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA : ref_grid   TYPE REF TO cl_gui_alv_grid.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
*DATA : gt_out LIKE zwmprntto OCCURS 0 WITH HEADER LINE.

DATA : gt_out   TYPE STANDARD TABLE OF ty_out WITH HEADER LINE.

DATA : BEGIN OF gt_ltak OCCURS 0,
         lgnum TYPE lgnum,
         tanum TYPE tanum,
         bdatu TYPE ltak_bdatu,
         bzeit TYPE ltak-bzeit,
         mblnr TYPE mblnr,
         mjahr TYPE mjahr,
         benum TYPE lvs_benum,
         drukz TYPE lvs_drukz,
         druck TYPE ltak_druck,
         lznum TYPE ltak-lznum,
         vbeln TYPE ltak-vbeln,
         tapri TYPE ltak-tapri,
         queue TYPE ltak-queue,
         lgtor TYPE ltak-lgtor,
         refnr TYPE ltak-refnr,
         bwlvs TYPE ltak-bwlvs,
         tbnum TYPE ltak-tbnum,
         tknum TYPE vttp-tknum,
         lifex TYPE likp-lifex,
         lgbzo TYPE ltak-lgbzo,
       END   OF gt_ltak.

DATA : BEGIN OF gt_ltap OCCURS 0,
         ename TYPE ltap-qname,
         ezeit TYPE ltap-qzeit,
         edatu TYPE ltap-qdatu,
         meins TYPE ltap-meins,
         lgnum TYPE lgnum,
         tanum TYPE tanum,
         tapos TYPE tapos,
         matnr TYPE matnr,
         werks TYPE werks_d,
         charg TYPE charg_d,
         bestq TYPE bestq,
         altme TYPE lrmei,
         wdatu TYPE lvs_wdatu,
         vltyp TYPE ltap_vltyp,
         vlber TYPE ltap_vlber,
         vlpla TYPE ltap_vlpla,
         vsola TYPE ltap_vsola,
         vsolm TYPE ltap_vsolm,
         nltyp TYPE ltap_nltyp,
         nlber TYPE ltap-nlber,
         nlpla TYPE ltap_nlpla,
         nsola TYPE ltap_nsola,
         nista TYPE ltap_nista,
         nistm TYPE ltap-nistm,
         maktx TYPE maktx,
         vfdat TYPE vfdat,
         lgort TYPE lgort_d,
         pquit TYPE ltap_pquit,
         qplos TYPE ltap-qplos,
         ablad TYPE ltap-ablad,
         vorga TYPE ltap-vorga,
         wenum TYPE ltap-wenum,
         zeugn TYPE ltap-zeugn,
         style TYPE lvc_t_styl,
       END OF gt_ltap.

DATA : BEGIN OF gt_xltap OCCURS 0,
         lgnum TYPE lgnum,
         tanum TYPE tanum,
         tapos TYPE tapos,
         wenum TYPE lvs_wenum,
         zeugn TYPE lvs_zeugn,
         vorga TYPE ltap_vorga,
         nltyp TYPE ltap_nltyp,
       END OF gt_xltap.

DATA : gt_t329d TYPE STANDARD TABLE OF t329d,
       gs_t329p TYPE t329p,
       default  TYPE bapidefaul,
       gt_013   TYPE STANDARD TABLE OF zwmdt013.

DATA : ok_code  TYPE sy-ucomm,
       gv_subrc TYPE sy-subrc.

DATA : gt_likp  TYPE STANDARD TABLE OF ty_likp,
       gt_xlikp TYPE STANDARD TABLE OF ty_xlikp,
       gt_lips  TYPE STANDARD TABLE OF lips,
       gt_vbak  TYPE STANDARD TABLE OF vbak.

DATA : gt_xrldri TYPE STANDARD TABLE OF rldri,
       gt_xrldrh TYPE STANDARD TABLE OF rldrh.

DATA : gt_012   TYPE STANDARD TABLE OF ztdnsddt012,
       gt_tprit TYPE STANDARD TABLE OF tprit,
       gt_pall  TYPE STANDARD TABLE OF ty_pall.

TYPES: BEGIN OF ty_mat_gr,
         matnr TYPE mara-matnr,
         matkl TYPE mara-matkl,
         lgnum TYPE lagp-lgnum,
         lgtyp TYPE lagp-lgtyp,
         lgpla TYPE lagp-lgpla,
         kober TYPE lagp-kober,
       END OF ty_mat_gr.

DATA: it_mat_gr TYPE TABLE OF ty_mat_gr.

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

DATA : gt_vttp    TYPE STANDARD TABLE OF vttp,
       gt_mch1    TYPE STANDARD TABLE OF mch1,
       gv_testrun,
       gv_lgbzo   TYPE t30ct-lgbzo,
       gv_lbzot   TYPE t30ct-lbzot,
       dynpfields TYPE STANDARD TABLE OF dynpread.

DATA: gt_lprio TYPE STANDARD TABLE OF ty_lprio.

DATA: number TYPE string.


TYPES: BEGIN OF ty_route,
         tknum TYPE vttk-tknum,
         route TYPE vttk-route,
         bezei TYPE m_vmtra-bezei,
       END OF ty_route.


DATA: gt_route TYPE TABLE OF ty_route.

TYPES: BEGIN OF ty_temp_sf4,
         matnr TYPE mseg-matnr,
         mblnr TYPE mseg-mblnr,
         maktx TYPE makt-maktx,
         ebeln TYPE mseg-ebeln,
         vfdat TYPE mseg-vfdat,
         charg TYPE mseg-charg,
         menge TYPE mseg-menge,
         meins TYPE mseg-meins,
         lifnr TYPE mseg-lifnr,
         hsdat TYPE mseg-hsdat,
       END OF ty_temp_sf4.

DATA: gt_temp_sf4 TYPE TABLE OF ty_temp_sf4,
      gs_temp_sf4 TYPE ty_temp_sf4,
      gt_mkpf     TYPE TABLE OF mkpf,
      gs_mkpf     TYPE mkpf,
      gt_mlgn     TYPE TABLE OF mlgn,
      gs_mlgn     TYPE mlgn.

DATA: gt_04 TYPE TABLE OF zwm_sf004,
      gs_04 TYPE zwm_sf004.

TYPES: BEGIN OF ty_count_pallet,
         matnr  TYPE mseg-matnr,
         pallet TYPE p DECIMALS 2,
       END OF ty_count_pallet.


TYPES: BEGIN OF ty_calc,
         pallet TYPE i,
         total_pallet TYPE i,
         matnr TYPE mseg-matnr,
         lhmg1  TYPE mlgn-lhmg1,
         carton TYPE i,
         ecer   TYPE i,
       END OF ty_calc.

DATA: gt_count_pallet TYPE TABLE OF ty_count_pallet,
      gs_count_pallet TYPE ty_count_pallet.

DATA: gt_calc TYPE TABLE OF ty_calc,
      gs_calc TYPE ty_calc.
