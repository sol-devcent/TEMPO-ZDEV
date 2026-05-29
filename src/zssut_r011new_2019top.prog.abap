*----------------------------------------------------------------------*
*   INCLUDE ZSSUT_R011NEW_2019TOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: tvm2, likp, knvv, knvp, sscrfields.

TYPES : BEGIN OF ty_class,
          kdgrp    TYPE knvv-kdgrp,
          zvaltgt  TYPE zstarget-zvaltgt,
          text(30),
        END OF ty_class.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gv_waerk    TYPE waerk,
      gv_mintgt   TYPE zmintgt,
      gv_date1    LIKE sy-datum,
      gv_date2    LIKE sy-datum,
      gv_value2(10),
      gr_spmon    TYPE RANGE OF spmon,
      gv_tds.

CONSTANTS: gc_vrsio   TYPE vrsio VALUE '000'.

RANGES: r_mvgr2 FOR s706-mvgr2.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_customer OCCURS 0,
        spmon     TYPE spmon,
        vkbur     TYPE vkbur,
        mvgr2     TYPE mvgr2,
        kunnr     TYPE kunnr,
        kunn2     TYPE kunn2,
        name1     TYPE name1_gp,
        kdgrp     TYPE kdgrp,
        katr10    TYPE katr10,
      END OF gt_customer.

DATA: BEGIN OF gt_s619 OCCURS 0,
        vrsio	    TYPE vrsio,
        spmon	    TYPE spmon,
        vkorg	    TYPE vkorg,
        werks	    TYPE werks_d,
        vkbur	    TYPE vkbur,
        kunnr	    TYPE kunwe,
        vbeln	    TYPE vbeln_vl,
        matnr	    TYPE matnr,
        waerk     TYPE waerk,
        vrkme	    TYPE vrkme,
        grosval   TYPE zgrosval,
        lfimg	    TYPE lfimg,
        zdisc     TYPE zdisc,
        mvgr2     TYPE mvgr2,
        mvgr3     TYPE mvgr3,
        zzroutel  TYPE zzroutel,
        grosval1  TYPE zgrosval,
        grosval2  TYPE zgrosval,
      END OF gt_s619.

DATA: BEGIN OF gt_zstarget OCCURS 0,
        vkorg     TYPE vkorg,
        vtweg     TYPE vtweg,
        gjahr     TYPE gjahr,
        spmon     TYPE spmon,
        vkbur     TYPE vkbur,
        kunnr     TYPE kunnr_v,
        matnr     TYPE matnr,
        mvgr2     TYPE mvgr2,
        mvgr3     TYPE mvgr3,
        waerk     TYPE waerk,
        zvaltgt   TYPE zvaltgt,
        class     TYPE zclas,
      END OF gt_zstarget.
DATA : gt_qtgt  LIKE gt_zstarget OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_zsparameter OCCURS 0.
        INCLUDE STRUCTURE zsparameter.
DATA: END OF gt_zsparameter.

DATA: BEGIN OF gt_zsclassopp OCCURS 0.
        INCLUDE STRUCTURE zsclsopp20.
DATA: END OF gt_zsclassopp.

DATA: BEGIN OF gt_header OCCURS 0,
        spmon     TYPE spmon,
        vkbur     TYPE vkbur,
        mvgr2     TYPE mvgr2,
        routel    TYPE zzroutel,
      END OF gt_header.

DATA: BEGIN OF gt_detail OCCURS 0,
        spmon     TYPE spmon,
        vkbur     TYPE vkbur,
        routel    TYPE zzroutel,
        pkunwe    TYPE kunwe,
        name1     TYPE name1_gp,
        waerk     TYPE waerk,
        netsales  TYPE zxx,
        zdisc	    TYPE zdisc,
        target    TYPE zvaltgt,
        target45  TYPE zvaltgt,
        extrawb   TYPE zpercen,
        wbrp      TYPE zxx,
        rtwb      TYPE p DECIMALS 2,
        rth115    TYPE zxx,
        rth215    TYPE zxx,
        netsales1 TYPE zxx,
        netsales2 TYPE zxx,
        wb1%      TYPE zpercen,
        wb2%      TYPE zpercen,
        wb1rp     TYPE zxx,
        wb2rp     TYPE zxx,
        class     TYPE zspaket_control-text,
        pacls(10),
      END OF gt_detail.

DATA: BEGIN OF gt_out OCCURS 0,
        spmon     TYPE spmon,
        vkbur     TYPE vkbur,
        bezei20   TYPE bezei20,
        mvgr2     TYPE mvgr2,
        bezei40   TYPE bezei40,
        routel    TYPE zzroutel,
        name_rt   TYPE name1_gp,
        pkunwe    TYPE kunwe,
        name1     TYPE name1_gp,
        waerk     TYPE waerk,
        netsales  TYPE zxx,
        zdisc	    TYPE zdisc,
        target    TYPE zvaltgt,
        target45  TYPE zvaltgt,
        extrawb   TYPE zpercen,
        wbrp      TYPE zxx,
        rtwb      TYPE zxx,
        rth115    TYPE zxx,
        rth215    TYPE zxx,
        netsales1 TYPE zxx,
        netsales2 TYPE zxx,
        wb1%      TYPE zpercen,
        wb2%      TYPE zpercen,
        wb1rp     TYPE zxx,
        wb2rp     TYPE zxx,
        zstrike   TYPE zstrike,
        zstrike1  TYPE zstrike,
        tgt1      TYPE zxx,
        tgu1      TYPE zxx,
        sls1      TYPE zxx,
        sl11      TYPE zxx,
        str1      TYPE zpercen,
        st11      TYPE zpercen,
        %wb1      TYPE zpercen,
        tgt2      TYPE zxx,
        tgu2      TYPE zxx,
        sls2      TYPE zxx,
        sl12      TYPE zxx,
        str2      TYPE zpercen,
        st12      TYPE zpercen,
        %wb2      TYPE zpercen,
        tgt3      TYPE zxx,
        tgu3      TYPE zxx,
        sls3      TYPE zxx,
        sl13      TYPE zxx,
        str3      TYPE zpercen,
        st13      TYPE zpercen,
        %wb3      TYPE zpercen,
        tgt4      TYPE zxx,
        tgu4      TYPE zxx,
        sls4      TYPE zxx,
        sl14      TYPE zxx,
        str4      TYPE zpercen,
        st14      TYPE zpercen,
        %wb4      TYPE zpercen,
        tgt5      TYPE zxx,
        tgu5      TYPE zxx,
        sls5      TYPE zxx,
        sl15      TYPE zxx,
        str5      TYPE zpercen,
        st15      TYPE zpercen,
        %wb5      TYPE zpercen,
        tgt6      TYPE zxx,
        tgu6      TYPE zxx,
        sls6      TYPE zxx,
        sl16      TYPE zxx,
        str6      TYPE zpercen,
        st16      TYPE zpercen,
        %wb6      TYPE zpercen,
        tgt7      TYPE zxx,
        tgu7      TYPE zxx,
        sls7      TYPE zxx,
        sl17      TYPE zxx,
        str7      TYPE zpercen,
        st17      TYPE zpercen,
        %wb7      TYPE zpercen,
        tgt8      TYPE zxx,
        tgu8      TYPE zxx,
        sls8      TYPE zxx,
        sl18      TYPE zxx,
        str8      TYPE zpercen,
        st18      TYPE zpercen,
        %wb8      TYPE zpercen,
        tgt9      TYPE zxx,
        tgu9      TYPE zxx,
        sls9      TYPE zxx,
        sl19      TYPE zxx,
        str9      TYPE zpercen,
        st19      TYPE zpercen,
        %wb9      TYPE zpercen,
        tgt10      TYPE zxx,
        tgu10      TYPE zxx,
        sls10      TYPE zxx,
        sl110      TYPE zxx,
        str10      TYPE zpercen,
        st110      TYPE zpercen,
        %wb10      TYPE zpercen,
      END OF gt_out.

DATA: BEGIN OF gt_mvgr2 OCCURS 0,
        spmon     TYPE spmon,
        vkbur     TYPE vkbur,
        mvgr2     TYPE mvgr2,
        pkunwe    TYPE kunwe,
        waerk     TYPE waerk,
        totweek   TYPE ztotweek,
      END OF gt_mvgr2.

DATA: BEGIN OF gt_quantity OCCURS 0,
        spmon     TYPE spmon,
        vkbur     TYPE vkbur,
        pkunwe    TYPE kunwe,
        mvgr2     TYPE mvgr2,
        mvgr3     TYPE mvgr3,
        minqty    TYPE bstmi,
        qty       TYPE zqty,
        qty2      TYPE zqty,
      END OF gt_quantity,
      gt_quantity1 LIKE gt_quantity OCCURS 0 WITH HEADER LINE,
      gt_quantity2 LIKE gt_quantity OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_target OCCURS 0,
        vkbur     TYPE vkbur,
        kunnr     TYPE kunnr_v,
        waerk     TYPE waerk,
        zvaltgt   TYPE zvaltgt,
      END OF gt_target.

DATA: BEGIN OF gt_s626 OCCURS 0,
        sptag     TYPE sptag,
        vkbur     TYPE vkbur,
        fkart     TYPE fkart,
        vbeln     TYPE vbeln_vf,
        pkunwe    TYPE kunwe,
        kdgrp     TYPE kdgrp,
        kvgr3     TYPE kvgr3,
        prodh1    TYPE zprodh1,
        matkl     TYPE matkl,
        matnr     TYPE matnr,
        vrsio     TYPE vrsio,
        spmon     TYPE spmon,
        spwoc     TYPE spwoc,
        spbup     TYPE spbup,
        ssour     TYPE ssour,
        stwae     TYPE stwae,
        umkzwi1   TYPE mc_umkzwi1,
        gukzwi1   TYPE mc_gukzwi1,
      END OF gt_s626.

DATA: BEGIN OF gt_a603 OCCURS 0,
        matnr     TYPE matnr,
        mvgr2     TYPE mvgr2,
        mvgr3     TYPE mvgr3,
      END OF gt_a603.

DATA: BEGIN OF gt_key OCCURS 0,
        pkunwe    TYPE kunwe,
        matnr     TYPE matnr,
      END OF gt_key.

DATA: BEGIN OF gt_extrawb OCCURS 0,
        pkunwe    TYPE kunwe,
        waerk     TYPE waerk,
        totweek   TYPE ztotweek,
        oppext    TYPE zoppext,
      END OF gt_extrawb.

DATA  BEGIN OF gt_likp OCCURS 1.
DATA:   vbeln LIKE likp-vbeln,
        erdat LIKE likp-erdat,
        vstel LIKE likp-vstel,
        vkorg LIKE likp-vkorg,
        bldat LIKE likp-bldat,
        wadat_ist LIKE likp-wadat_ist.
DATA  END   OF gt_likp.

DATA: BEGIN OF gt_cntrl OCCURS 0.
        INCLUDE STRUCTURE zspaket_control.
DATA  END   OF gt_cntrl.

DATA  BEGIN OF gt_tvm2 OCCURS 1.
        INCLUDE STRUCTURE tvm2.
DATA  END   OF gt_tvm2.

DATA  BEGIN OF gt_dnd OCCURS 1.
        INCLUDE STRUCTURE zspaket_control.
DATA  END   OF gt_dnd.

DATA : gt_dyn_table  TYPE REF TO data,
       gw_line       TYPE REF TO data,
       gt_dyn_fcat   TYPE lvc_t_fcat.

FIELD-SYMBOLS : <fs_gt> TYPE STANDARD TABLE,
                <fs_gs> TYPE ANY,
                <fs>    TYPE ANY.

DATA : gt_tgtcust   TYPE STANDARD TABLE OF zstarget_control INITIAL SIZE 0,
       gt_clssp     TYPE STANDARD TABLE OF zstarget_control INITIAL SIZE 0.

DATA : gt_mvgr2reg  TYPE STANDARD TABLE OF zspaket_control,
       gt_clspkt    TYPE STANDARD TABLE OF zspaket_control,
       gt_gtcp      TYPE STANDARD TABLE OF zspaket_control,
       gv_2020,
       gt_cltgt     TYPE STANDARD TABLE OF zspaket_control,
       gt_mintgt    TYPE STANDARD TABLE OF zspaket_control,
       gt_class     TYPE STANDARD TABLE OF ty_class,
       gt_param     TYPE STANDARD TABLE OF zspaket_control.

DATA : gr_tgtreg    TYPE RANGE OF mvgr2.
