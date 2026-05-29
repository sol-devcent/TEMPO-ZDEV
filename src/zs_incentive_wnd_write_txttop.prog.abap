*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
TYPE-POOLS : vrm.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: nast,tnapr,s629,vttk.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: param TYPE vrm_id,
      values     TYPE vrm_values,
      value LIKE LINE OF values,
      char2(3).

DATA: gi_vs_pk_tm  TYPE t,
      cr_create_tm TYPE t,
      pk_create_tm TYPE t,
      spgd_vs_gi_tm TYPE t,
      cr_vs_spgd_tm TYPE t,
      do_vs_spgd_tm TYPE t,
      cr_vs_gi_tm TYPE t,
      cr_create_dt(004) TYPE p  DECIMALS 00,
      gi_vs_pk_dt(004)  TYPE p  DECIMALS 00,
      pk_create_dt(004) TYPE p  DECIMALS 00,
      spgd_vs_gi_dt(004) TYPE p  DECIMALS 00,
      cr_vs_spgd_dt(004) TYPE p DECIMALS 00,
      do_vs_spgd_dt(004) TYPE p DECIMALS 00,
      cr_vs_gi_dt(004) TYPE p DECIMALS 00.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
TYPES: BEGIN OF t_objectid,
          objectid LIKE cdhdr-objectid,
          changenr LIKE cdpos-changenr,
       END OF t_objectid.

TYPES: BEGIN OF t_cdpos,
          objectid LIKE cdpos-objectid,
          changenr LIKE cdpos-changenr,
          fname    LIKE cdpos-fname,
          udate    LIKE cdhdr-udate,
          utime    LIKE cdhdr-utime,
       END OF t_cdpos.

TYPES: BEGIN OF t_cdhdr,
          objectid LIKE cdhdr-objectid,
          changenr LIKE cdhdr-changenr,
          udate    LIKE cdhdr-udate,
          utime    LIKE cdhdr-utime,
       END OF t_cdhdr.

DATA: BEGIN OF t_report OCCURS 0,
        vkbur(4),
        bezei(20),
        nama(20),
        bulan(20),
        urutan(3),
        dklk(2),
        text(20),
        tgl01(3),
        tgl02(3),
        tgl03(3),
        tgl04(3),
        tgl05(3),
        tgl06(3),
        tgl07(3),
        tgl08(3),
        tgl09(3),
        tgl10(3),
        tgl11(3),
        tgl12(3),
        tgl13(3),
        tgl14(3),
        tgl15(3),
        tgl16(3),
        tgl17(3),
        tgl18(3),
        tgl19(3),
        tgl20(3),
        tgl21(3),
        tgl22(3),
        tgl23(3),
        tgl24(3),
        tgl25(3),
        tgl26(3),
        tgl27(3),
        tgl28(3),
        tgl29(3),
        tgl30(3),
        tgl31(3),
        tottarget(20),
        totaktual(20),
      END OF t_report.
DATA: gt_report LIKE t_report OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_ft OCCURS 0,
        vkbur LIKE tvkbt-vkbur,
        bezei LIKE tvkbt-bezei,
        nama(20),
        bulan(20),
        urutan(3),
        dklk(2),
        text(20),
        tgl01   TYPE p DECIMALS 0,
        tgl02   TYPE p DECIMALS 0,
        tgl03   TYPE p DECIMALS 0,
        tgl04   TYPE p DECIMALS 0,
        tgl05   TYPE p DECIMALS 0,
        tgl06   TYPE p DECIMALS 0,
        tgl07   TYPE p DECIMALS 0,
        tgl08   TYPE p DECIMALS 0,
        tgl09   TYPE p DECIMALS 0,
        tgl10   TYPE p DECIMALS 0,
        tgl11   TYPE p DECIMALS 0,
        tgl12   TYPE p DECIMALS 0,
        tgl13   TYPE p DECIMALS 0,
        tgl14   TYPE p DECIMALS 0,
        tgl15   TYPE p DECIMALS 0,
        tgl16   TYPE p DECIMALS 0,
        tgl17   TYPE p DECIMALS 0,
        tgl18   TYPE p DECIMALS 0,
        tgl19   TYPE p DECIMALS 0,
        tgl20   TYPE p DECIMALS 0,
        tgl21   TYPE p DECIMALS 0,
        tgl22   TYPE p DECIMALS 0,
        tgl23   TYPE p DECIMALS 0,
        tgl24   TYPE p DECIMALS 0,
        tgl25   TYPE p DECIMALS 0,
        tgl26   TYPE p DECIMALS 0,
        tgl27   TYPE p DECIMALS 0,
        tgl28   TYPE p DECIMALS 0,
        tgl29   TYPE p DECIMALS 0,
        tgl30   TYPE p DECIMALS 0,
        tgl31   TYPE p DECIMALS 0,
      END OF t_ft.

DATA: BEGIN OF t_s629 OCCURS 0,
        spmon LIKE s629-spmon,
        vkorg LIKE s629-vkorg,
        gjahr LIKE s629-gjahr,
        vkbur LIKE s629-vkbur,
        m01   LIKE s629-m01,
        m02   LIKE s629-m02,
        m03   LIKE s629-m03,
        m04   LIKE s629-m04,
        m05   LIKE s629-m05,
        m06   LIKE s629-m06,
        m07   LIKE s629-m07,
        m08   LIKE s629-m08,
        m09   LIKE s629-m09,
        m10   LIKE s629-m10,
        m11   LIKE s629-m11,
        m12   LIKE s629-m12,
      END OF t_s629.
DATA: t_s629_act LIKE t_s629 OCCURS 0  WITH HEADER LINE.

DATA: BEGIN OF t_s628 OCCURS 0,
        spmon LIKE s628-spmon,
        vkorg LIKE s628-vkorg,
        gjahr LIKE s628-gjahr,
        vkbur LIKE s628-vkbur,
        m01   LIKE s628-m01,
        m02   LIKE s628-m02,
        m03   LIKE s628-m03,
        m04   LIKE s628-m04,
        m05   LIKE s628-m05,
        m06   LIKE s628-m06,
        m07   LIKE s628-m07,
        m08   LIKE s628-m08,
        m09   LIKE s628-m09,
        m10   LIKE s628-m10,
        m11   LIKE s628-m11,
        m12   LIKE s628-m12,
      END OF t_s628.

DATA: BEGIN OF t_s603 OCCURS 0,
        ssour TYPE ssour,
        vrsio TYPE vrsio,
        spmon	TYPE spmon,
        sptag	TYPE sptag,
        spwoc	TYPE spwoc,
        spbup	TYPE spbup,
        pkunwe  TYPE kunwe,
        kvgr3	TYPE kvgr3,
        kdgrp	TYPE kdgrp,
        vkbur	TYPE vkbur,
        zshvkb  TYPE vkbur,
        matnr	TYPE matnr,
        prodh1 TYPE zprodh1,
        vkgrp	TYPE vkgrp,
        pvrtnr TYPE vrtnr,
        zzroutel TYPE zzroutel,
        zxx	TYPE zxx,
        zqnetsls TYPE zqnetsls,
        umkzwi1	TYPE mc_umkzwi1,
        gukzwi1	TYPE mc_gukzwi1,
      END OF t_s603.

DATA : t_vttk   TYPE STANDARD TABLE OF vttk INITIAL SIZE 0
                WITH HEADER LINE.

DATA: BEGIN OF t_likp OCCURS 0,
        vbeln LIKE likp-vbeln,
        kunnr LIKE likp-kunnr,
      END OF t_likp.

DATA: BEGIN OF t_kna1 OCCURS 0,
        kunnr LIKE kna1-kunnr,
        name1 LIKE kna1-name1,
        katr1 LIKE kna1-katr1,
        kdgrp LIKE knvv-kdgrp,
        kvgr3 LIKE knvv-kvgr3,
      END OF t_kna1.

DATA: BEGIN OF t_itab OCCURS 0,
         werks LIKE mseg-werks,
         menge LIKE mseg-menge,
         meins LIKE mseg-meins,
         check(1).
DATA: END OF t_itab.

DATA: BEGIN OF wa_dataset,
            lfart(4),
            vstel(4),
            vbeln(10),
            kunnr(10),
            erdat(8),
            erzet(6),
            erdat_spgd(8),
            erzet_spgd(6),
            wadat_ist(8),
            crdat(8),
            crtim(6),
            kdgrp(2),
            kvgr3(3),
            ort01(35),
            kostk(1),
            wbstk(1),
            pdstk(1),
            gi_time(6),
            kodat(8),
            kouhr(6),
            pk_create_dt(4),
            pk_create_tm(6),
            gi_vs_pk_dt(4),
            gi_vs_pk_tm(6),
            cr_create_dt(4),
            cr_create_tm(6),
            cr2_create_dt(4),
            cr2_create_tm(6),
            spgd_vs_gi_dt(4),
            spgd_vs_gi_tm(6),
            cr_vs_spgd_dt(4),
            cr_vs_spgd_tm(6),
            city1(40),
            dlk(2),
            pkdo(4),
            gipk(4),
            spgdgi(4),
            crspgd(4),
            cnt_dn(4),
            lgort(4),
            dospgd(4),
            do_vs_spgd_dt(4),
            do_vs_spgd_tm(6),
            gido(4),
            gi_create_dt(6),
            gi_create_tm(6),
            crdo(4),
            podat(8),
            potim(6),
            erdat_so  TYPE erdat,
            erzet_so  TYPE erzet,
            katr6(3),
            tknum(10),
            add04(10),
            cr_vs_gi_tm(6),
            cr_vs_gi_dt(8),
      END OF wa_dataset.

DATA: BEGIN OF wa_result,
            lfart   LIKE likp-lfart,
            vstel   LIKE likp-vstel,
            vbeln   LIKE likp-vbeln,
            kunnr   LIKE likp-kunnr,
            erdat   LIKE likp-erdat,
            erzet   LIKE likp-erzet,
            erdat_spgd LIKE vttp-erdat,
            erzet_spgd LIKE vttp-erzet,
            wadat_ist LIKE likp-wadat_ist,
            crdat   LIKE zmm_cust_rec-crdat,
            crtim   LIKE zmm_cust_rec-crtim,
            crdatext LIKE zmm_cust_rec-crdat,
            crtimext LIKE zmm_cust_rec-crtim,
            kdgrp   LIKE knvv-kdgrp,
            kvgr3   LIKE knvv-kvgr3,
            ort01   LIKE kna1-ort01,
            kostk   LIKE vbuk-kostk,
            wbstk   LIKE vbuk-wbstk,
            pdstk   LIKE vbuk-pdstk,
            gi_time LIKE likp-erzet,
            kodat   LIKE likp-kodat,
            kouhr   LIKE likp-kouhr,
            pk_create_dt LIKE pk_create_dt,
            pk_create_tm LIKE pk_create_tm,
            gi_vs_pk_dt  LIKE gi_vs_pk_dt,
            gi_vs_pk_tm  LIKE gi_vs_pk_tm,
            cr_create_dt LIKE cr_create_dt,
            cr_create_tm LIKE cr_create_tm,
            spgd_vs_gi_dt LIKE spgd_vs_gi_dt,
            spgd_vs_gi_tm LIKE spgd_vs_gi_tm,
            cr_vs_spgd_dt LIKE cr_vs_spgd_dt,
            cr_vs_spgd_tm LIKE cr_vs_spgd_tm,
            city1   LIKE adrc-city1,
            dlk(2)    TYPE c,
            pkdo   TYPE p,
            gipk   TYPE p,
            spgdgi  TYPE p,
            crspgd  TYPE p,
            cnt_dn TYPE p,
            lgort  LIKE lips-lgort,
            katr1  LIKE kna1-katr1.
DATA:       type(12) TYPE c,
            ktext  LIKE t151t-ktext.
DATA:       bzirk  LIKE knvv-bzirk,
            name1   LIKE kna1-name1,
            dospgd  TYPE p,
            do_vs_spgd_dt LIKE do_vs_spgd_dt,
            do_vs_spgd_tm LIKE do_vs_spgd_tm,
            gido   TYPE p,
            gi_create_dt LIKE cr_create_dt,
            gi_create_tm LIKE cr_create_tm,
            crdo   TYPE p,
            podat     TYPE sy-datum,
            potim     TYPE sy-uzeit,
            erdat_so  TYPE erdat,
            erzet_so  TYPE erzet,
            katr6     LIKE kna1-katr6,
            tknum     LIKE vttk-tknum,
            shtyp     LIKE vttk-shtyp,
            add04     LIKE vttk-add04,
            total     TYPE p DECIMALS 0,
            hit       TYPE p DECIMALS 0,
            nhit      TYPE p DECIMALS 0,
            std       TYPE p DECIMALS 2,
            cr_vs_gi_dt  LIKE cr_vs_gi_dt,
            cr_vs_gi_tm  LIKE cr_vs_gi_tm,
            cr2dt          TYPE sy-datum,
            cr2tm          TYPE sy-uzeit,
            cr2_vs_spgd_dt LIKE cr_vs_spgd_dt,
            cr2_vs_spgd_tm LIKE cr_vs_spgd_tm,
            cr2_vs_gi_dt   LIKE cr_vs_gi_dt,
            cr2_vs_gi_tm   LIKE cr_vs_gi_tm,
            cr2_create_dt  LIKE cr_create_dt,
            cr2_create_tm  LIKE cr_create_tm,
      END OF wa_result.

DATA: BEGIN OF wa_outpl2,
         vstel  LIKE likp-vstel,
         type(12) TYPE c,
         kdgrp  LIKE knvv-kdgrp,
         ktext  LIKE t151t-ktext,
         dlk(2) TYPE c,
         3jam   TYPE p,
         6jam   TYPE p,
         12jam  TYPE p,
         24jam  TYPE p,
         48jam  TYPE p,
         72jam  TYPE p,
         73jam  TYPE p,
         total  TYPE p,
       END OF wa_outpl2.

DATA: BEGIN OF wa_outpl3,
         vstel  LIKE likp-vstel,
         text(3),
         type(12) TYPE c,
         dlk(2) TYPE c,
         kdgrp  LIKE knvv-kdgrp,
         bzirk  LIKE knvv-bzirk,
         ktext  LIKE t151t-ktext,
         shtyp    LIKE vttk-shtyp,
         0hari  TYPE p,
         1hari  TYPE p,
         2hari  TYPE p,
         3hari  TYPE p,
         4hari  TYPE p,
         total  TYPE p,
         std    TYPE p DECIMALS 2,
         target TYPE p DECIMALS 0,
         00hari   TYPE p,
         06hari    TYPE p,
         07hari    TYPE p,
         08hari    TYPE p,
         09hari    TYPE p,
         10hari   TYPE p,
         11hari  TYPE p,
         total1  TYPE p,
         std1    TYPE p DECIMALS 2,
         target1 TYPE p DECIMALS 0,
       END OF wa_outpl3.

DATA: BEGIN OF t_avr OCCURS 0,
        text(3),
        type(12)  TYPE c,
        dlk(2)    TYPE c,
        hari      TYPE p,
        hari1     TYPE p,
        total     TYPE p.
DATA: END OF t_avr.

DATA: BEGIN OF i_vbeln OCCURS 0,
        vbeln LIKE likp-vbeln,
      END OF i_vbeln.

DATA: BEGIN OF i_tvst OCCURS 0,
        vstel LIKE tvst-vstel,
        city1 LIKE adrc-city1.
DATA: END OF i_tvst.

DATA: BEGIN OF gt_rayon OCCURS 0,
        kschl LIKE a777-kschl,
        vkbur LIKE a777-vkbur,
        zdelvp LIKE a777-zdelvp,
        katr1 LIKE a777-katr1,
      END OF gt_rayon.

DATA: BEGIN OF i_listbox OCCURS 0,
        tplst LIKE vttk-tplst,
        exti1 LIKE vttk-exti1,
        tknum LIKE vttk-tknum.
DATA: END OF i_listbox.

DATA: BEGIN OF t_a511 OCCURS 0.
        INCLUDE STRUCTURE a511.
DATA:   valtg TYPE valtg,
      END OF t_a511.

DATA: BEGIN OF t_a511x OCCURS 0.
        INCLUDE STRUCTURE a511.
DATA:   valtg TYPE valtg,
      END OF t_a511x.

DATA: BEGIN OF t_a511y OCCURS 0.
        INCLUDE STRUCTURE a511.
DATA:   valtg TYPE valtg,
      END OF t_a511y.

DATA: BEGIN OF t_vttp OCCURS 0.
        INCLUDE STRUCTURE vttp.
DATA:   kunnr LIKE kna1-kunnr,
      END OF t_vttp.
DATA: t_vttpori LIKE t_vttp OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_lips OCCURS 0,
        vbeln	TYPE vbeln_vl,
        posnr	TYPE posnr_vl,
        lgort	TYPE lgort_d,
      END OF gt_lips.

DATA: BEGIN OF i_custrec OCCURS 0,
        vbeln LIKE zmm_cust_rec-vbeln,
        crdat LIKE zmm_cust_rec-crdat,
        crtim LIKE zmm_cust_rec-crtim,
      END OF i_custrec.

DATA: BEGIN OF i_vbuk OCCURS 0,
        vbeln LIKE vbuk-vbeln,
        kostk LIKE vbuk-kostk,
        wbstk LIKE vbuk-wbstk,
        pdstk LIKE vbuk-pdstk,
      END OF i_vbuk.

DATA: BEGIN OF i_knvv OCCURS 0,
        kunnr LIKE knvv-kunnr,
        kdgrp LIKE knvv-kdgrp,
        kvgr3 LIKE knvv-kvgr3,
        bzirk LIKE knvv-bzirk,
        ort01 LIKE kna1-ort01,
        katr1 LIKE kna1-katr1,
        name1 LIKE kna1-name1,
      END OF i_knvv.

DATA: BEGIN OF gt_tvkbt OCCURS 0,
        vkbur LIKE tvkbt-vkbur,
        bezei LIKE tvkbt-bezei,
      END OF gt_tvkbt.

DATA: BEGIN OF i_t151 OCCURS 0,
         kdgrp LIKE t151t-kdgrp,
         ktext LIKE t151t-ktext,
       END OF i_t151.

DATA: i_slsdist LIKE wa_result OCCURS 0.

DATA: BEGIN OF wa_outpl5,
         bzirk  LIKE knvv-bzirk,
         type(12) TYPE c,
         shtyp    LIKE vttk-shtyp,
         vstel  LIKE likp-vstel,
         text(3),
         dlk(2) TYPE c,
         kdgrp  LIKE knvv-kdgrp,
         ktext  LIKE t151t-ktext,
         00hari   TYPE p,
         06hari    TYPE p,
         07hari    TYPE p,
         08hari    TYPE p,
         09hari    TYPE p,
         10hari   TYPE p,
         total  TYPE p,
         std    TYPE p DECIMALS 2,
         target TYPE p DECIMALS 0,
       END OF wa_outpl5.

DATA: BEGIN OF wa_outpl6.
        INCLUDE STRUCTURE wa_outpl5.
DATA: END OF wa_outpl6.

DATA: BEGIN OF t_a777 OCCURS 0,
        vkorg LIKE a777-vkorg,
        vkbur LIKE a777-vkbur,
        kschl LIKE a777-kschl,
        katr1 LIKE a777-katr1,
        zdaywk LIKE a777-zdaywk,
        kdgrp LIKE a777-kdgrp,
        kvgr3 LIKE a777-kvgr3,
        ztype LIKE a777-ztype,
        zdelvp LIKE a777-zdelvp,
        zminach LIKE a777-zminach,
        zminp LIKE a777-zminp,
        zdiffach LIKE a777-zdiffach,
        zdiffp LIKE a777-zdiffp,
        datbi LIKE a777-datbi,
        datab LIKE a777-datab,
        knumh LIKE a777-knumh,
        kappl LIKE a777-kappl,
        kbetr LIKE konp-kbetr,
      END OF t_a777.

DATA  BEGIN OF gt_tvbur OCCURS 1.
        INCLUDE STRUCTURE tvbur.
DATA  END   OF gt_tvbur.

DATA: va_gjahr LIKE s629-gjahr,
      va_month(2),
      va_bulan(20),
      va_datef  LIKE sy-datum,
      va_datet  LIKE sy-datum,
      va_bezei  LIKE tvkbt-bezei,
      va_zdelvp LIKE a777-zdelvp,
      va_katr1 LIKE a777-katr1,
      va_totinc LIKE zsd_incentive_wnd-tot_incent,
      va_tottarget LIKE zsd_incentive_wnd-tot_incent,
      va_totaktual LIKE zsd_incentive_wnd-tot_incent,
      va_totpercen TYPE i,
      va_percen    LIKE zsd_incentive_wnd-tot_incent,
      va_incentive LIKE zsd_incentive_wnd-tot_incent,
      va_delv      LIKE zsd_incentive_wnd-tot_incent,
      va_whs       LIKE zsd_incentive_wnd-tot_incent,
      va_dlp       LIKE zsd_incentive_wnd-tot_incent,
      va_inctv     LIKE zsd_incentive_wnd-tot_incent,
      i_result  LIKE wa_result OCCURS 0,
      i_result2 LIKE wa_result OCCURS 0,
      i_result3 LIKE wa_result OCCURS 0,
      i_outpl3  LIKE wa_outpl3 OCCURS 0,
      i_bzirk   LIKE wa_result OCCURS 0,
      v_answer(1),
      t_holiday LIKE iscal_day OCCURS 0 WITH HEADER LINE,
      i_spopli  LIKE spopli OCCURS 0 WITH HEADER LINE,
      i_cdhdr   TYPE t_cdhdr  OCCURS 0,
      wa_cdhdr  TYPE t_cdhdr,
      i_cdpos   TYPE t_cdpos OCCURS 0,
      wa_cdpos  TYPE t_cdpos.

DATA: gr_vkbur TYPE RANGE OF vkbur WITH HEADER LINE.

DATA : i_outpl2  LIKE wa_outpl2 OCCURS 0,
       i_outpl6  LIKE wa_outpl6 OCCURS 0,
       crt_date  LIKE selopt OCCURS 0 WITH HEADER LINE,
       ship_to   LIKE selopt OCCURS 0 WITH HEADER LINE,
       del_num   LIKE selopt OCCURS 0 WITH HEADER LINE,
       ent_time  LIKE selopt OCCURS 0 WITH HEADER LINE,
       ra_lgorti LIKE selopt OCCURS 0 WITH HEADER LINE,
       ra_lgorte LIKE selopt OCCURS 0 WITH HEADER LINE,
       so_kvgr3  LIKE selopt OCCURS 0 WITH HEADER LINE.

DATA: va_avr  TYPE i.

*----------------------------------------------------------*
* Smartforms
*----------------------------------------------------------*
DATA: d_ctrl_param     LIKE    ssfctrlop,
*{   REPLACE        P01K900160                                        1
*\      d_output_opt     like    ssfcompop,
      d_output_opt    TYPE    ssfcompop,  "By SAP_DEV06 26-03-2007.
*}   REPLACE
      d_smrt_funcmod   TYPE    rs38l_fnam,
      d_ssfscreen      LIKE    ssfscreen.

DATA: t_lines    LIKE tline OCCURS  0 WITH HEADER LINE,
      d_tdnam    LIKE rssce-tdname.

DATA: BEGIN OF t_detail OCCURS 0.
DATA:   vkbur TYPE vkbur,
        spmon TYPE spmon.
        INCLUDE STRUCTURE zsd_incentive_wnd.
DATA: END OF t_detail.
DATA: gt_detail LIKE t_detail OCCURS 0 WITH HEADER LINE.

DATA: wa_header LIKE zsh_incentive_wnd.

*Dataset
DATA: BEGIN OF wa_detail,
        vkbur(4),
        spmon(6),
        norut(2),
        types(20),
        std_incent(20),
        target(20),
        actual(20),
        persen(20),
        tot_incent(20),
      END OF wa_detail.

DATA: va_filename(70).

*----------------------------------------------------------*
* United
*----------------------------------------------------------*
DATA : gt_zplbc   LIKE zplbc OCCURS 0 WITH HEADER LINE.
DATA : ra_lfart   LIKE selopt OCCURS 0 WITH HEADER LINE.

DATA : ship_pnt   LIKE selopt OCCURS 0 WITH HEADER LINE,
       sales_org  LIKE selopt OCCURS 0 WITH HEADER LINE.

DATA : pa_lfart   TYPE lfart.

RANGES: ra_date   FOR a511-datab.

DATA : gv_day01   TYPE int4,
       gv_day02   TYPE int4,
       gv_day03   TYPE int4,
       gv_day04   TYPE int4,
       gv_day05   TYPE int4,
       gv_day06   TYPE int4.

DATA : ra_ztype TYPE RANGE OF ztypinc WITH HEADER LINE.

DATA : gt_zmshphist   TYPE STANDARD TABLE OF zmshphist,
       gs_zmshphist   TYPE zmshphist.

CONSTANTS : c_51  TYPE zmshphist-zreason VALUE '51',
            c_52  TYPE zmshphist-zreason VALUE '52'.

DATA : dis  TYPE xfeld,
       day  TYPE xfeld,
       wh1  TYPE xfeld,
       wh2  TYPE xfeld,
       dp1  TYPE xfeld,
       dp2  TYPE xfeld,
       det  TYPE xfeld.
