*----------------------------------------------------------------------*
*   INCLUDE ZF_KWITANSITOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: bsid, sscrfields, zfkwi, knvv.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
TYPES: BEGIN OF t_bdc.
        INCLUDE STRUCTURE bdcdata.
TYPES: END OF t_bdc.
TYPES: BEGIN OF t_messtab.
        INCLUDE STRUCTURE bdcmsgcoll.
TYPES: END OF t_messtab.

CONSTANTS: co_kw1   TYPE zfkwi-ztran VALUE 'KW1',
           co_kw2   TYPE zfkwi-ztran VALUE 'KW2',
           co_ttf   TYPE zfkwi-ztran VALUE 'TTF'.

DATA: gv_fname     TYPE tdsfname,
      gv_error     TYPE sy-subrc,
      gv_city1     TYPE ad_city1,
      gv_petugas   TYPE zgdtxde_name1,
      gv_petugas1  TYPE zgdtxde_name1,
      gv_jabat1    TYPE zgdtxde_d3titel1a,
      gv_name      TYPE ad_name1.

DATA: i_bdc      TYPE t_bdc OCCURS 0,
      wa_bdc     TYPE t_bdc,
      i_messtab  TYPE t_messtab OCCURS 0.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: lineitems LIKE bapi3007_2 OCCURS 0 WITH HEADER LINE,
      return    LIKE bapireturn.

DATA: BEGIN OF gt_tvbur OCCURS 0,
        vkbur        TYPE vkbur,
        name1        TYPE name1,
        street       TYPE ad_street,
        city1        TYPE ad_city1,
        post_code1   TYPE ad_pstcd1,
      END OF gt_tvbur.

DATA: BEGIN OF gt_kna1 OCCURS 0,
        kunnr   TYPE kunnr,
        name1   TYPE name1_gp,
        name2   TYPE name2_gp,
        ort01   TYPE ort01_gp,
        pstlz   TYPE pstlz,
        name_co TYPE ad_name_co,
      END OF gt_kna1.

DATA: BEGIN OF gt_zfkwiout OCCURS 0,
        bukrs	  TYPE bukrs,
        vkbur	  TYPE vkbur,
        kunnr	  TYPE kunnr,
        zsts    TYPE zflags,
        status  TYPE zststtf,
        zhit    TYPE zhit,
        zuserc  TYPE zusna1,
        zdatc	  TYPE zdate1,
        zuserl  TYPE zuserl,
        zdatl	  TYPE zdatl,
        lead(4),
      END OF gt_zfkwiout.

DATA: BEGIN OF gt_zfkwi OCCURS 0,
        ztran   TYPE ztran,
        bukrs   TYPE bukrs,
        kunnr   TYPE kunnr,
        zuonr   TYPE zuonr,
        nokwi   TYPE znomor4,
        nottf   TYPE znomor5,
        gjahr   TYPE gjahr,
        belnr   TYPE belnr_d,
        buzei   TYPE buzei,
        bldat   TYPE bldat,
        budat   TYPE budat,
        xblnr   TYPE xblnr,
        blart   TYPE blart,
        gsber   TYPE gsber,
        vkbur   TYPE vkbur,
        shkzg   TYPE shkzg,
        waers   TYPE waers,
        dmbtr   TYPE dmbtr,
        zflag1  TYPE zflag2,
        zflag2  TYPE zflag3,
        zflag3  TYPE zflag4,
        zttfdt  TYPE sy-datum,
      END OF gt_zfkwi.

DATA: BEGIN OF gt_nonttf OCCURS 0,
        vkorg TYPE vkorg,
        vkbur TYPE vkbur,
        kunnr TYPE kunnr,
        name1 TYPE name1,
        vtweg TYPE vtweg,
        spart TYPE spart,
        aufsd TYPE aufsd_x,
        ktokd TYPE ktokd,
        erdat TYPE erdat_rf,
      END OF gt_nonttf.

DATA: BEGIN OF gt_zfbid_nonttf OCCURS 0,
        bukrs TYPE bukrs,
        vkbur TYPE vkbur,
        kunnr TYPE kunnr,
      END OF gt_zfbid_nonttf.

DATA: BEGIN OF gt_delete OCCURS 0.
        INCLUDE STRUCTURE zfkwi.
DATA:   name1   TYPE ad_name1,
        check(1),
      END OF gt_delete.

DATA: BEGIN OF gt_vdata OCCURS 0,
        bukrs   TYPE bukrs,
        kunnr   TYPE kunnr,
        zuonr   TYPE dzuonr,
        verur   TYPE verur_vl,
        gjahr   TYPE gjahr,
        belnr   TYPE belnr_d,
        buzei   TYPE buzei,
        budat   TYPE budat,
        bldat   TYPE bldat,
        waers   TYPE waers,
        xblnr   TYPE xblnr,
        nokwi   TYPE znomor4,
        nottf   TYPE znomor5,
        blart   TYPE blart,
        gsber   TYPE gsber,
        shkzg   TYPE shkzg,
        dmbtr   TYPE dmbtr,
        wrbtr   TYPE wrbtr,
        nou     TYPE buzei,
        name1   TYPE ad_name1,
        check(1),
      END OF gt_vdata.

DATA: BEGIN OF gt_error OCCURS 0,
        kunnr  TYPE kunnr,
        error  TYPE i,
        msg(100).
DATA: END OF gt_error.

DATA: gt_reprint LIKE gt_vdata OCCURS 0 WITH HEADER LINE.

DATA: gt_header   LIKE zfstkwi OCCURS 0 WITH HEADER LINE,
      gt_detail   LIKE zfstkwi OCCURS 0 WITH HEADER LINE,
      gt_save     LIKE zfkwi OCCURS 0 WITH HEADER LINE.

DATA : gt_likp    TYPE STANDARD TABLE OF likp INITIAL SIZE 0.
