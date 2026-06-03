*&---------------------------------------------------------------------*
*&  Include           ZS_SLNKA_V1TOP
*&---------------------------------------------------------------------*
TABLES : vbak,vbap,likp,lips,makt,tvko,kna1,vbkd,tvagt,knvv.

TYPE-POOLS: truxs.

TYPES : BEGIN OF ty_subttl,
          poqty    TYPE vbap-kwmeng,
          poval    TYPE vbap-kzwi1,
          doqty    TYPE vbap-kwmeng,
          doval    TYPE vbap-kzwi1,
          unqty    TYPE vbap-kwmeng,
          unval    TYPE vbap-kzwi1,
          line     TYPE p DECIMALS 2,
          docu     TYPE p DECIMALS 2,
          1q       TYPE vbap-kwmeng,
          1v       TYPE vbap-kzwi1,
          2q       TYPE vbap-kwmeng,
          2v       TYPE vbap-kzwi1,
          3q       TYPE vbap-kwmeng,
          3v       TYPE vbap-kzwi1,
          6q       TYPE vbap-kwmeng,
          6v       TYPE vbap-kzwi1,
          podoc    TYPE p DECIMALS 0,
          polin    TYPE p DECIMALS 0,
          dodoc    TYPE p DECIMALS 0,
          dolin    TYPE p DECIMALS 0,
          slqty    TYPE p DECIMALS 2,
          slval    TYPE p DECIMALS 2,
          sllin    TYPE p DECIMALS 2,
          sldoc    TYPE p DECIMALS 2,
        END OF ty_subttl.

TYPES : BEGIN OF ty_char,
          poqty(15),
          poval(15),
          doqty(15),
          doval(15),
          percen(15),
          unqty(15),
          unval(15),
          lead1q(15),
          lead1v(15),
          lead2q(15),
          lead2v(15),
          lead3q(15),
          lead3v(15),
          lead6q(15),
          lead6v(15),
        END OF ty_char.

TYPES : BEGIN OF ty_percen,
          percen   TYPE p DECIMALS 2,
          unqty    TYPE p DECIMALS 2,
          unval    TYPE p DECIMALS 2,
          line     TYPE p DECIMALS 2,
          docu     TYPE p DECIMALS 2,
          1q       TYPE p DECIMALS 2,
          1v       TYPE p DECIMALS 2,
          2q       TYPE p DECIMALS 2,
          2v       TYPE p DECIMALS 2,
          3q       TYPE p DECIMALS 2,
          3v       TYPE p DECIMALS 2,
          6q       TYPE p DECIMALS 2,
          6v       TYPE p DECIMALS 2,
        END OF ty_percen.

TYPES : BEGIN OF ty_sort,
          sort     TYPE i,
          sort1    TYPE i,
          sort2    TYPE i,
          sort3    TYPE i,
          sort4    TYPE i,
          sort5    TYPE i,
          sort6    TYPE i,
          sort7    TYPE i,
          sort8    TYPE i,
        END OF ty_sort.

TYPES : BEGIN OF ty_summary,
          poqty    TYPE p DECIMALS 0,
          poval    TYPE p DECIMALS 2,
          dlqty    TYPE p DECIMALS 0,
          dlval    TYPE p DECIMALS 2,
          podoc    TYPE p DECIMALS 0,
          polin    TYPE p DECIMALS 0,
          dodoc    TYPE p DECIMALS 0,
          dolin    TYPE p DECIMALS 0,
          slqty    TYPE p DECIMALS 2,
          slval    TYPE p DECIMALS 2,
          sllin    TYPE p DECIMALS 2,
          sldoc    TYPE p DECIMALS 2,
        END OF ty_summary.

TYPES : BEGIN OF ty_cntpodo,
          vkbur    TYPE vbak-vkbur,
          vbeln    TYPE likp-vbeln,
        END OF ty_cntpodo.

DATA : BEGIN OF gt_mara OCCURS 0,
         matnr  TYPE matnr,
       END OF gt_mara.

DATA : BEGIN OF i_mara OCCURS 0,
         matnr  TYPE mara-matnr,
         meins  TYPE mara-meins,
       END OF i_mara.

DATA: BEGIN OF t_cust OCCURS 0.
        INCLUDE STRUCTURE zmm_cust_rec.
DATA: END OF t_cust.

DATA : BEGIN OF i_quot OCCURS 0,
         vbeln  LIKE  vbak-vbeln,
         knkli  LIKE  vbak-knkli,
         kunnr  LIKE  vbak-kunnr,
         vkbur  LIKE  vbak-vkbur,
         vkorg  LIKE  vbak-vkorg,
         vtweg  LIKE  vbak-vtweg,
         spart  LIKE  vbak-spart,
         submi  LIKE  vbak-submi,
         erdat  LIKE  vbak-erdat,
         erzet  LIKE  vbak-erzet,
         ernam  LIKE  vbak-ernam,
       END OF i_quot.

DATA : BEGIN OF i_detquot OCCURS 0,
         vkbur  LIKE  vbak-vkbur,
         kukla  LIKE  kna1vv-kukla,
         knkli  LIKE  vbak-knkli,
         vbeln  LIKE  vbak-vbeln,
         matnr  LIKE  vbap-matnr,
         bstnk  LIKE  vbak-bstnk,
         bstdk  LIKE  vbak-bstdk,
         kvgr4  LIKE  knvv-kvgr4,
         name1  LIKE  kna1-name1,
         erdat  LIKE  vbak-erdat,
         posnr  LIKE  vbap-posnr,
         kdmat  LIKE  vbap-kdmat,
         matkl  LIKE  vbap-matkl,
         maktx  LIKE  makt-maktx,
         bsark  LIKE  vbkd-bsark,
         pstyv  LIKE  vbap-pstyv,
         kwmeng LIKE  vbap-kwmeng,
         kzwi1  LIKE  vbap-kzwi1,
         abgru  LIKE  vbap-abgru,
         katr1  LIKE  kna1vv-katr1,
         bzirk  LIKE  kna1vv-bzirk,

         princ  LIKE  zsprlsom-princ,
         prin1  LIKE  zsprlsom-princ,
         prin2  LIKE  zsprlsom-princ,
         kunrl  LIKE  vbpa-kunnr,
         namrl  LIKE  kna1-name1,
         vtext  LIKE  tkukt-vtext,
         vkbvv  LIKE  knvv-vkbur,
         submi  LIKE  vbak-submi,
         erzet  LIKE  vbak-erzet,
         ernam  LIKE  vbak-ernam,
       END OF i_detquot.

DATA : gt_sum05   LIKE i_detquot OCCURS 0,
       gt_sum06   LIKE i_detquot OCCURS 0.

DATA : BEGIN OF i_kna1 OCCURS 0,
         kunnr  LIKE  kna1-kunnr,
         name1  LIKE  kna1-name1,
       END OF i_kna1.

DATA : BEGIN OF i_makt OCCURS 0,
         matnr  LIKE  makt-matnr,
         maktx  LIKE  makt-maktx,
       END OF i_makt.

DATA : BEGIN OF i_knvv OCCURS 0,
         vkbur  LIKE  knvv-vkbur,
         vkorg  LIKE  knvv-vkorg,
         vtweg  LIKE  knvv-vtweg,
         spart  LIKE  knvv-spart,
         kunnr  LIKE  knvv-kunnr,
         kdgrp  LIKE  knvv-kdgrp,
         kvgr4  LIKE  knvv-kvgr4,
       END OF i_knvv.

DATA : BEGIN OF i_vbkd OCCURS 0,
         vbeln  LIKE  vbkd-vbeln,
         bsark  LIKE  vbkd-bsark,
       END OF i_vbkd.

DATA : BEGIN OF i_sales OCCURS 0,
         vbeln  LIKE  vbak-vbeln,
         vgbel  LIKE  vbak-vgbel,
       END OF i_sales.

DATA : BEGIN OF i_delv OCCURS 0,
         vbeln  LIKE  lips-vbeln,
       END OF i_delv.

DATA : BEGIN OF i_detdelv OCCURS 0,
         vbeln      LIKE  likp-vbeln,
         erdat      LIKE  likp-erdat,
         wadat_ist  LIKE  likp-wadat_ist,
         posnr      LIKE  lips-posnr,
         matnr      LIKE  lips-matnr,
         maktx      LIKE  makt-maktx,
         lfimg      LIKE  lips-lfimg,
         kzwi1      LIKE  lips-kzwi1,
         vgbel      LIKE  lips-vgbel,
         vgpos      LIKE  lips-vgpos,
       END OF i_detdelv.

DATA : BEGIN OF i_bill OCCURS 0,
         vbeln  LIKE  vbrk-vbeln,
         zuonr  LIKE  vbrk-zuonr,
         erdat  LIKE  vbrk-erdat,
       END OF i_bill.

DATA : BEGIN OF i_vbpa OCCURS 0,
         vbeln  LIKE  vbpa-vbeln,
         parvw  LIKE  vbpa-parvw,
         kunnr  LIKE  vbpa-kunnr,
         adrnr  LIKE  vbpa-adrnr,
         name1  LIKE  kna1-name1,
       END OF i_vbpa.

DATA  BEGIN OF t_abgru OCCURS 1.
        INCLUDE STRUCTURE zsd_abgru.
DATA  END   OF t_abgru.

DATA : BEGIN OF i_detsales OCCURS 0,
         vbeln  LIKE  vbak-vbeln,
         erdat  LIKE  vbak-erdat,
         posnr  LIKE  vbap-posnr,
         matnr  LIKE  vbap-matnr,
         maktx  LIKE  makt-maktx,
         pstyv  LIKE  vbap-pstyv,
         kwmeng LIKE  vbap-kwmeng,
         kzwi1  LIKE  vbap-kzwi1,
         abgru  LIKE  vbap-abgru,
         vgbel  LIKE  vbak-vgbel,
         vgpos  LIKE  vbap-vgpos,
       END OF i_detsales.

DATA : i_tvkbt TYPE TABLE OF tvkbt WITH HEADER LINE,
       i_tkukt LIKE TABLE OF tkukt WITH HEADER LINE.

DATA : va_text(15),
       gv_kkber     TYPE kkber,
       valuetab     TYPE STANDARD TABLE OF rsparams INITIAL SIZE 0,
       ls_valuetab  TYPE rsparams,
       gv_spmon     TYPE char6,
       gv_subrc     TYPE sy-subrc VALUE 8,
       gv_path      TYPE char128 VALUE '/interface3/DSP/SL_OOS/'.

DATA : gt_dyn_fcat            TYPE lvc_t_fcat,
       gt_dyn_dfcat           TYPE lvc_t_fcat,
       gt_dyn_table           TYPE REF TO data,
       gt_dyn_dtable          TYPE REF TO data,
       gs_line                TYPE REF TO data,
       gs_dline               TYPE REF TO data,
       gv_pos                 TYPE i,
       fieldcat               TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       e_user_command         TYPE slis_formname VALUE 'F_USER_COMMAND',
       disvariant             LIKE disvariant,
       evtab                  TYPE slis_t_event WITH HEADER LINE,
       sortcat                TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       g_exit_caused_by_caller,
       gs_exit_caused_by_user TYPE slis_exit_by_user.

FIELD-SYMBOLS : <fs_output>   TYPE STANDARD TABLE,
                <fs_line>     TYPE ANY,
                <fs>          TYPE ANY.

FIELD-SYMBOLS : <fs_subttl>   TYPE STANDARD TABLE,
                <fs_st>       TYPE ANY.

FIELD-SYMBOLS : <fs_sub>      TYPE ANY,
                <fs_s>        TYPE ANY.

FIELD-SYMBOLS : <fs_subttl1>  TYPE ANY,
                <fs_st1>      TYPE ANY.

FIELD-SYMBOLS : <fs_subttl2>  TYPE ANY,
                <fs_st2>      TYPE ANY.

FIELD-SYMBOLS : <fs_subttl3>  TYPE ANY,
                <fs_st3>      TYPE ANY.

FIELD-SYMBOLS : <fs_subttl4>  TYPE ANY,
                <fs_st4>      TYPE ANY.

FIELD-SYMBOLS : <fs_subttl5>  TYPE ANY,
                <fs_st5>      TYPE ANY.

FIELD-SYMBOLS : <fs_subttl6>  TYPE ANY,
                <fs_st6>      TYPE ANY.

FIELD-SYMBOLS : <fs_percen>   TYPE ANY,
                <fs_prc>      TYPE ANY.

FIELD-SYMBOLS : <fs_download> TYPE STANDARD TABLE,
                <fs_dline>    TYPE ANY,
                <fs_dfield>   TYPE ANY.

DATA : return     TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0,
       groups     TYPE STANDARD TABLE OF bapigroups INITIAL SIZE 0,
       gs_groups  LIKE LINE OF groups.

DATA : gt_knvv    TYPE TABLE OF knvv WITH HEADER LINE.
