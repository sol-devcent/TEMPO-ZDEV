*&---------------------------------------------------------------------*
*&  Include           ZS_RPT_OPPTOP
*&---------------------------------------------------------------------*
CONSTANTS: c_dnd   TYPE zfield_name VALUE 'DND',
           c_class TYPE zfield_name VALUE 'CLASS',
           c_jwb   TYPE zfield_name VALUE 'JWB',
           c_ewb   TYPE zfield_name VALUE 'EWB'.

DATA: BEGIN OF t_s706 OCCURS 0,
        vrsio    LIKE s706-vrsio,
        spmon    LIKE s706-spmon,
        vkbur    LIKE s706-vkbur,
        pkunwe   LIKE s706-pkunwe,
        mvgr2    LIKE s706-mvgr2,
        mvgr3    LIKE s706-mvgr3,
        vbeln_01 LIKE s706-vbeln_01,
        posnr    LIKE s706-posnr,
        zcount   LIKE s706-zcount,
        matnr    LIKE s706-matnr,
        waerk    LIKE s706-waerk,
        zxx      LIKE s706-zxx,
        zdisc    LIKE s706-zdisc,
        ztotweek LIKE s706-ztotweek,
        matwa    LIKE s706-matwa,
        sisa     LIKE s700-opnbal.
DATA: END OF t_s706.
DATA: BEGIN OF t_s706a OCCURS 0.
        INCLUDE STRUCTURE t_s706.
      DATA: END OF t_s706a.
DATA: BEGIN OF t_s706b OCCURS 0.
        INCLUDE STRUCTURE t_s706.
      DATA: END OF t_s706b.
DATA: BEGIN OF t_s706b_sum OCCURS 0.
        INCLUDE STRUCTURE t_s706.
        DATA:   selisih LIKE s706-ztotweek.
DATA: END OF t_s706b_sum.
DATA: BEGIN OF t_s706_result OCCURS 0.
        INCLUDE STRUCTURE s706.
      DATA: END OF t_s706_result.
DATA: BEGIN OF t_s706_sum OCCURS 0.
        INCLUDE STRUCTURE s706.
        DATA:   selisih LIKE s706-ztotweek.
DATA: END OF t_s706_sum.

DATA: BEGIN OF t_s700 OCCURS 0.
        INCLUDE STRUCTURE s700.
        DATA:   percentage TYPE zdec,
        count      TYPE i.
DATA: END OF t_s700.
DATA: BEGIN OF t_s700a OCCURS 0.
        INCLUDE STRUCTURE t_s700.
      DATA: END OF t_s700a.
DATA: BEGIN OF t_s700_result OCCURS 0.
        INCLUDE STRUCTURE s700.
      DATA: END OF t_s700_result.
DATA: BEGIN OF t_s700_quart OCCURS 0.
        INCLUDE STRUCTURE s700.
        DATA:   ptype TYPE char3,
      END OF t_s700_quart.
DATA: BEGIN OF t_s700_quart_sum OCCURS 0.
        INCLUDE STRUCTURE s700.
      DATA: END OF t_s700_quart_sum.

DATA: BEGIN OF t_s700b OCCURS 0.
        INCLUDE STRUCTURE t_s700.
      DATA: END OF t_s700b.

DATA: BEGIN OF t_s706d OCCURS 0.
        INCLUDE STRUCTURE t_s706.
      DATA: END OF t_s706d.

DATA: BEGIN OF t_count OCCURS 0,
        pkunwe LIKE s700-pkunwe,
        opnbal LIKE s700-opnbal,
        count  TYPE i.
DATA: END OF t_count.

DATA: BEGIN OF t_vkbur OCCURS 0,
        vstel LIKE tvkol-vstel,
        werks LIKE tvkol-werks,
        lgort LIKE tvkol-lgort,
        live  LIKE zplbc-live,
      END OF t_vkbur.

RANGES: r_mvgr2    FOR s706-mvgr2,
        r_rptmvgr2 FOR s706-mvgr2,
        r_mvgr2reg FOR s706-mvgr2.

DATA  BEGIN OF i_s626 OCCURS 1.
DATA: sptag    LIKE s626-sptag,
      vkbur    LIKE s626-vkbur,
      fkart    LIKE s626-fkart,
      vbeln    LIKE s626-vbeln,
      pkunwe   LIKE s626-pkunwe,
      kdgrp    LIKE s626-kdgrp,
      kvgr3    LIKE s626-kvgr3,
      prodh1   LIKE s626-prodh1,
      matkl    LIKE s626-matkl,
      matnr    LIKE s626-matnr,
      umkzwi1  LIKE s626-umkzwi1,
      gukzwi1  LIKE s626-gukzwi1,
      ummenge  LIKE s626-ummenge,
      gumenge  LIKE s626-gumenge,
      mvgr2    LIKE mvke-mvgr2,
      netsales LIKE s626-umkzwi1.
DATA  END   OF i_s626.

DATA: i_s626_1 LIKE i_s626 OCCURS 0 WITH HEADER LINE.
DATA: i_s626_2 LIKE i_s626 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF i_s626_sum OCCURS 0.
        INCLUDE STRUCTURE i_s626.
      DATA: END OF i_s626_sum.
DATA: i_s626_sum_2 LIKE i_s626_sum OCCURS 0 WITH HEADER LINE.
DATA: i_s626_total  LIKE i_s626 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF i_s626_matnr OCCURS 0.
        INCLUDE STRUCTURE i_s626.
      DATA: END OF i_s626_matnr.
DATA: i_s626_matnr_2 LIKE i_s626 OCCURS 0 WITH HEADER LINE.

DATA: percen_ext1  LIKE  zsparameter-percen,
      percen_ext2  LIKE  zsparameter-percen,
      percen_ext3  LIKE  zsparameter-percen,
      percen_ext4  LIKE  zsparameter-percen,
      percen_ext5  LIKE  zsparameter-percen,
      percen_ext6  LIKE  zsparameter-percen,
      percen_ext7  LIKE  zsparameter-percen,
      percen_ext8  LIKE  zsparameter-percen,
      percen_ext9  LIKE  zsparameter-percen,
      percen_ext10 LIKE  zsparameter-percen.

DATA: wa_zsparameter LIKE zsparameter.

DATA: BEGIN OF gt_cntrl OCCURS 0.
        INCLUDE STRUCTURE zspaket_control.
      DATA  END   OF gt_cntrl.
DATA: gt_cntrl_dnd   LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
      gt_cntrl_jwb   LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
      gt_cntrl_ewb   LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
      gt_cntrl_pew   LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
      gt_cntrl_class LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
      gt_cntrl_cwb   LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
      gt_cntrl_ewm   LIKE gt_cntrl OCCURS 0 WITH HEADER LINE,
      gt_cntrl_cdn   LIKE gt_cntrl OCCURS 0 WITH HEADER LINE.

DATA: gt_paket_type LIKE zspaket_type OCCURS 0 WITH HEADER LINE,
      gv_pattern    LIKE zspaket_type-field_value,
      gv_value      LIKE zspaket_type-field_value.

DATA : BEGIN OF gt_knvv OCCURS 0,
         kunnr TYPE kunnr,
         vkorg TYPE vkorg,
         vtweg TYPE vtweg,
         kdgrp TYPE kdgrp,
         vkbur TYPE vkbur,
         kvgr3 TYPE kvgr3.
DATA  END   OF gt_knvv.

DATA: BEGIN OF lt_parameter OCCURS 0.
        INCLUDE STRUCTURE zsparameter.
      DATA: END OF lt_parameter.

DATA: BEGIN OF gt_sum OCCURS 0,
        pkunwe   TYPE kunwe,
        mvgr2    TYPE mvgr2,
        mvgr3    TYPE mvgr3,
        netsales TYPE mc_umkzwi1,
        qty      TYPE mc_ummenge,
      END OF gt_sum.
DATA: gt_sum_2 LIKE gt_sum OCCURS 0 WITH HEADER LINE.
DATA: gt_sum_3 LIKE gt_sum OCCURS 0 WITH HEADER LINE.

DATA: gt_tgtold_quart     LIKE zstarget OCCURS 0 WITH HEADER LINE,
      gt_tgtold_quart_sum LIKE zstarget OCCURS 0 WITH HEADER LINE.

DATA : gv_strikewb1(1),
       gv_strikewb2(1).

DATA : r_konda  TYPE RANGE OF konda,
       r_katr10 TYPE RANGE OF katr10.

DATA : gt_gtcp      TYPE STANDARD TABLE OF zspaket_control,
       gt_mintgt    TYPE STANDARD TABLE OF zspaket_control,
       gt_param     TYPE STANDARD TABLE OF zspaket_control,
       gt_mvgr2slvr TYPE STANDARD TABLE OF zspaket_control,
       gt_clspkt    TYPE STANDARD TABLE OF zspaket_control,
       gt_clsewb    TYPE STANDARD TABLE OF zspaket_control,
       gt_scaleewb  TYPE STANDARD TABLE OF zspaket_control,
       gt_user      TYPE STANDARD TABLE OF usgrp_user.

DATA : gt_cust      TYPE STANDARD TABLE OF knvv.
