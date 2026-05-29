*----------------------------------------------------------------------*
*   INCLUDE ZS_SHIPMENT_EXTINTTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, vttk.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
FIELD-SYMBOLS : <fs_vttk>   TYPE STANDARD TABLE,
                <fs_itab>   TYPE STANDARD TABLE,
                <fs_wa>     TYPE ANY,
                <fs>        TYPE ANY.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : gt_dyn_fcat   TYPE lvc_t_fcat,
       wa_dyn_fcat   TYPE lvc_s_fcat,
       gt_dyn_table  TYPE REF TO data,
       wa_line       TYPE REF TO data.

DATA : BEGIN OF gt_ttdst OCCURS 0,
         tplst    TYPE tplst,
         bezei    TYPE bezei20,
       END OF gt_ttdst.

DATA : BEGIN OF gt_vttk OCCURS 0,
         tknum    TYPE tknum,
         shtyp    TYPE shtyp,
         tplst    TYPE tplst,
         erdat    TYPE erdat,
         route    TYPE routr,
         signi    TYPE signi,
         exti1    TYPE exti1,
         datbg    TYPE datbg,
         add04    TYPE vttk_add04,
         dalbg    TYPE dalbg,
         ualbg    TYPE ualbg,
         dalen    TYPE dalend,
         ualen    TYPE ualend,
       END OF gt_vttk.

DATA : BEGIN OF gt_vttp OCCURS 0,
         tknum    TYPE tknum,
         tpnum    TYPE tpnum,
         vbeln    TYPE vbeln_vl,
       END OF gt_vttp.

DATA : BEGIN OF gt_zmshphist OCCURS 0,
         tknum    TYPE tknum,
         vbeln    TYPE vbeln_vl,
         zcount	  TYPE zcount,
         zreason  TYPE zreason2,
       END OF gt_zmshphist.

DATA : BEGIN OF gt_likp OCCURS 0,
         vbeln      TYPE vbeln_vl,
         kunnr      TYPE kunwe,
         route      TYPE route,
         btgew      TYPE gsgew,
         gewei      TYPE gewei,
         volum      TYPE volum_15,
         voleh      TYPE voleh,
         wadat_ist  TYPE wadat_ist,
       END OF gt_likp.

DATA : BEGIN OF gt_lips OCCURS 0,
         vbeln      TYPE vbeln_vl,
         posnr      TYPE posnr_vl,
         kvgr3      TYPE kvgr3,
         vgbel      TYPE vgbel,
         vgpos      TYPE vgpos,
         matnr      TYPE matnr,
         werks      TYPE werks_d,
         lgort      TYPE lgort_d,
         charg      TYPE charg_d,
         lfimg      TYPE lfimg,
       END OF gt_lips.

DATA : BEGIN OF gt_karton OCCURS 0,
         vbeln      TYPE vbeln_vl,
         karton     TYPE lfimg,
       END OF gt_karton.

DATA : BEGIN OF gt_vbap OCCURS 0,
         vbeln      TYPE vbeln_va,
         posnr      TYPE posnr_va,
       END OF gt_vbap.

DATA : BEGIN OF gt_vbak OCCURS 0,
         vbeln      TYPE vbeln_va,
         netwr      TYPE netwr_ak,
         waerk      TYPE waerk,
       END OF gt_vbak.

DATA : BEGIN OF gt_kna1 OCCURS 0,
         kunnr    TYPE kunnr,
         name1    TYPE name1_gp,
         katr1    TYPE katr1,
       END OF gt_kna1.

DATA : BEGIN OF gt_out OCCURS 0,
         matnr   TYPE matnr,
       END OF gt_out.

DATA : gt_zsextrec  TYPE TABLE OF zsextrec WITH HEADER LINE,
       gt_zwmdt003  TYPE STANDARD TABLE OF zwmdt003.

DATA : xfield  TYPE lvc_t_fcat.
