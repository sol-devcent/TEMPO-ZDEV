REPORT zmr_incentif_wnd NO STANDARD PAGE HEADING
                        LINE-SIZE 225.
TYPE-POOLS: slis.
DATA: gi_vs_pk_tm        TYPE t,
      cr_create_tm       TYPE t,
      pk_create_tm       TYPE t,
      spgd_vs_gi_tm      TYPE t,
      cr_vs_spgd_tm      TYPE t,
      do_vs_spgd_tm      TYPE t,
      cr_vs_do_tm        TYPE t,
      cr_vs_gi_tm        TYPE t,
      cr_create_dt(004)  TYPE p  DECIMALS 00,
      gi_vs_pk_dt(004)   TYPE p  DECIMALS 00,
      pk_create_dt(004)  TYPE p  DECIMALS 00,
      spgd_vs_gi_dt(004) TYPE p  DECIMALS 00,
      cr_vs_spgd_dt(004) TYPE p DECIMALS 00,
      do_vs_spgd_dt(004) TYPE p DECIMALS 00,
      cr_vs_do_dt(004)   TYPE p DECIMALS 00,
      cr_vs_gi_dt(004)   TYPE p DECIMALS 00.

TABLES: likp, knvv, sscrfields, tvst.

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

TYPES : BEGIN OF ty_out,
          keterangan(10),
          vstel          LIKE likp-vstel,
          name1          LIKE t001w-name1,
          type(12),
          kdgrp          LIKE knvv-kdgrp,
          dlk(2),
          bzirk          LIKE knvv-bzirk,
          total          TYPE p,
          target         TYPE p,
          targetx        TYPE p,

          0              TYPE p,
          1              TYPE p,
          2              TYPE p,
          3              TYPE p,
          4              TYPE p,
          5              TYPE p,
          0x             TYPE p,
          1x             TYPE p,
          2x             TYPE p,
          3x             TYPE p,
          4x             TYPE p,
          5x             TYPE p,
          0y             TYPE p,
          1y             TYPE p,
          2y             TYPE p,
          3y             TYPE p,
          4y             TYPE p,
          5y             TYPE p,

          hit            TYPE p,
          hitx           TYPE p,
          hity           TYPE p,
          hitnew         TYPE p,

          jgi            TYPE p,
          jsh            TYPE p,
          jcr            TYPE p.
TYPES : END OF ty_out.

TYPES : BEGIN OF ty_mara,
          matnr TYPE mara-matnr,
          meins TYPE mara-meins,
          tempb TYPE mara-tempb,
          maktx TYPE makt-maktx,
          umren TYPE marm-umren,
          umrez TYPE marm-umrez,
        END OF ty_mara.

TYPES : BEGIN OF ty_drho,
          vkbur  TYPE vbrp-vkbur,
          vbeln  TYPE vbrp-vbeln,
          kunnr  TYPE likp-kunnr,
          name1  TYPE adrc-name1,
          kdgrp  LIKE knvv-kdgrp,
          dlk(2),
          matnr  TYPE mara-matnr,
          maktx  TYPE makt-maktx,
          tempb  TYPE t143t-tempb,
          tbtxt  TYPE t143t-tbtxt,
          erdat  TYPE likp-erdat,
          lfimg  TYPE lips-lfimg,
          vrkme  TYPE lips-vrkme,
          umren  TYPE marm-umren,
          umrez  TYPE marm-umrez,
          hocar  TYPE p DECIMALS 2,
          rocar  TYPE p DECIMALS 0,
        END OF ty_drho.

DATA: BEGIN OF i_tvst OCCURS 0,
        vstel LIKE tvst-vstel,
        city1 LIKE adrc-city1.
DATA: END OF i_tvst.

DATA: BEGIN OF i_t151 OCCURS 0,
        kdgrp LIKE t151t-kdgrp,
        ktext LIKE t151t-ktext,
      END OF i_t151.

DATA: BEGIN OF i_spmon OCCURS 0,
        spmon LIKE s031-spmon,
      END OF i_spmon.

DATA: BEGIN OF i_vbeln OCCURS 0,
        vbeln LIKE likp-vbeln,
      END OF i_vbeln.

*-----------------------------*
* Define Structure for output
*-----------------------------*
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
        erdat_so         TYPE erdat,
        erzet_so         TYPE erzet,
        katr6(3),
        tknum(10),
        add04(10),
        cr_vs_gi_tm(6),
        cr_vs_gi_dt(8),
      END OF wa_dataset.

DATA: BEGIN OF wa_result,
        lfart         LIKE likp-lfart,
        vstel         LIKE likp-vstel,
        vbeln         LIKE likp-vbeln,
        kunnr         LIKE likp-kunnr,
        erdat         LIKE likp-erdat,
        erzet         LIKE likp-erzet,
        erdat_spgd    LIKE vttp-erdat,
        erzet_spgd    LIKE vttp-erzet,
        wadat_ist     LIKE likp-wadat_ist,
        crdat         LIKE zmm_cust_rec-crdat,
        crtim         LIKE zmm_cust_rec-crtim,
        crdatext      LIKE zmm_cust_rec-crdat,
        crtimext      LIKE zmm_cust_rec-crtim,
        kdgrp         LIKE knvv-kdgrp,
        kvgr3         LIKE knvv-kvgr3,
        ort01         LIKE kna1-ort01,
        kostk         LIKE vbuk-kostk,
        wbstk         LIKE vbuk-wbstk,
        pdstk         LIKE vbuk-pdstk,
        gi_time       LIKE likp-erzet,
        kodat         LIKE likp-kodat,
        kouhr         LIKE likp-kouhr,
        pk_create_dt  LIKE pk_create_dt,
        pk_create_tm  LIKE pk_create_tm,
        gi_vs_pk_dt   LIKE gi_vs_pk_dt,
        gi_vs_pk_tm   LIKE gi_vs_pk_tm,
        cr_create_dt  LIKE cr_create_dt,
        cr_create_tm  LIKE cr_create_tm,
        spgd_vs_gi_dt LIKE spgd_vs_gi_dt,
        spgd_vs_gi_tm LIKE spgd_vs_gi_tm,
        cr_vs_spgd_dt LIKE cr_vs_spgd_dt,
        cr_vs_spgd_tm LIKE cr_vs_spgd_tm,
        city1         LIKE adrc-city1,
        dlk(2)        TYPE c,
        pkdo          TYPE p,
        gipk          TYPE p,
        spgdgi        TYPE p,
        crspgd        TYPE p,
        cnt_dn        TYPE p,
        lgort         LIKE lips-lgort,
        katr1         LIKE kna1-katr1.
DATA: type(12) TYPE c,
      ktext    LIKE t151t-ktext.
DATA: bzirk          LIKE knvv-bzirk,
      name1          LIKE kna1-name1,
      dospgd         TYPE p,
      do_vs_spgd_dt  LIKE do_vs_spgd_dt,
      do_vs_spgd_tm  LIKE do_vs_spgd_tm,
      gido           TYPE p,
      gi_create_dt   LIKE cr_create_dt,
      gi_create_tm   LIKE cr_create_tm,
      crdo           TYPE p,
      podat          TYPE sy-datum,
      potim          TYPE sy-uzeit,
      erdat_so       TYPE erdat,
      erzet_so       TYPE erzet,
      katr6          LIKE kna1-katr6,
      tknum          LIKE vttk-tknum,
      add04          LIKE vttk-add04,
      total          TYPE p DECIMALS 0,
      hit            TYPE p DECIMALS 0,
      nhit           TYPE p DECIMALS 0,
      std            TYPE p DECIMALS 2,
      cr_vs_gi_dt    LIKE cr_vs_gi_dt,
      cr_vs_gi_tm    LIKE cr_vs_gi_tm,
      cr2dt          TYPE sy-datum,
      cr2tm          TYPE sy-uzeit,
      cr2_vs_spgd_dt LIKE cr_vs_spgd_dt,
      cr2_vs_spgd_tm LIKE cr_vs_spgd_tm,
      cr2_vs_gi_dt   LIKE cr_vs_gi_dt,
      cr2_vs_gi_tm   LIKE cr_vs_gi_tm,
      cr2_create_dt  LIKE cr_create_dt,
      cr2_create_tm  LIKE cr_create_tm,
      END OF wa_result.

DATA: ls_extpay  LIKE wa_result.

DATA: BEGIN OF wa_outpl,
        vstel    LIKE likp-vstel,
        type(12) TYPE c,
        kdgrp    LIKE knvv-kdgrp,
        ktext    LIKE t151t-ktext,
        dlk(2)   TYPE c,
        pkdo     TYPE p,
        gipk     TYPE p,
        spgdgi   TYPE p,
        crspgd   TYPE p,
        dospgd   TYPE p,
        total    TYPE p,
        cnt_dn   TYPE p,
        gido     TYPE p,
        crdo     TYPE p,
      END OF wa_outpl.

DATA: BEGIN OF wa_outpl2,
        vstel    LIKE likp-vstel,
        type(12) TYPE c,
        kdgrp    LIKE knvv-kdgrp,
        ktext    LIKE t151t-ktext,
        dlk(2)   TYPE c,
        3jam     TYPE p,
        6jam     TYPE p,
        12jam    TYPE p,
        24jam    TYPE p,
        48jam    TYPE p,
        72jam    TYPE p,
        73jam    TYPE p,
        total    TYPE p,
      END OF wa_outpl2.

DATA: BEGIN OF wa_outpl3,
        vstel    LIKE likp-vstel,
        text(3),
        type(12) TYPE c,
        dlk(2)   TYPE c,
        kdgrp    LIKE knvv-kdgrp,
        bzirk    LIKE knvv-bzirk,
        ktext    LIKE t151t-ktext,
        0hari    TYPE p,
        1hari    TYPE p,
        2hari    TYPE p,
        3hari    TYPE p,
        4hari    TYPE p,
        total    TYPE p,
        std      TYPE p DECIMALS 2,
        target   TYPE p DECIMALS 0,
      END OF wa_outpl3.
DATA: BEGIN OF wa_outpl4,
        vstel    LIKE likp-vstel,
        type(12) TYPE c,
        kdgrp    LIKE knvv-kdgrp,
        ktext    LIKE t151t-ktext,
        dlk(2)   TYPE c,
        0hari    TYPE p,
        1hari    TYPE p,
        2hari    TYPE p,
        3hari    TYPE p,
        4hari    TYPE p,
        total    TYPE p,
        std      TYPE p DECIMALS 2,
      END OF wa_outpl4.
DATA: BEGIN OF wa_outpl5,
        bzirk    LIKE knvv-bzirk,
        type(12) TYPE c,
        vstel    LIKE likp-vstel,
        text(3),
        dlk(2)   TYPE c,
        kdgrp    LIKE knvv-kdgrp,
        ktext    LIKE t151t-ktext,
        00hari   TYPE p,
        06hari   TYPE p,
        07hari   TYPE p,
        08hari   TYPE p,
        09hari   TYPE p,
        10hari   TYPE p,
*         11hari  TYPE p,
        total    TYPE p,
        std      TYPE p DECIMALS 2,
        target   TYPE p DECIMALS 0,
      END OF wa_outpl5.
DATA: BEGIN OF wa_outpl6.
        INCLUDE STRUCTURE wa_outpl5.
      DATA: END OF wa_outpl6.
DATA: BEGIN OF wa_outpl7.
        INCLUDE STRUCTURE wa_outpl5.
      DATA: END OF wa_outpl7.

DATA: BEGIN OF t_avr OCCURS 0,
        text(3),
        type(12) TYPE c,
        dlk(2)   TYPE c,
        hari     TYPE p,
        hari1    TYPE p,
        total    TYPE p.
DATA: END OF t_avr.

DATA: i_cdhdr   TYPE t_cdhdr  OCCURS 0,
      wa_cdhdr  TYPE t_cdhdr,
      i_cdpos   TYPE t_cdpos OCCURS 0,
      wa_cdpos  TYPE t_cdpos,
      i_result  LIKE wa_result OCCURS 0,
      i_result2 LIKE wa_result OCCURS 0,
      i_result3 LIKE wa_result OCCURS 0,
      i_slsdist LIKE wa_result OCCURS 0,
      i_extpay  LIKE wa_result OCCURS 0,
      i_outpl   LIKE wa_outpl  OCCURS 0,
      i_outpl2  LIKE wa_outpl2 OCCURS 0,
      i_outpl3  LIKE wa_outpl3 OCCURS 0,
      i_outpl4  LIKE wa_result OCCURS 0,
      i_outpl6  LIKE wa_outpl6 OCCURS 0,
      judul(70) TYPE c,
      month(70) TYPE c,
      i_bzirk   LIKE wa_result OCCURS 0,
      va_ucomm  LIKE sy-ucomm.

DATA : BEGIN OF i_custrec OCCURS 0,
         vbeln LIKE zmm_cust_rec-vbeln,
         crdat LIKE zmm_cust_rec-crdat,
         crtim LIKE zmm_cust_rec-crtim,
       END OF i_custrec.
DATA: BEGIN OF t_vbkd OCCURS 0,
        vbeln LIKE vbkd-vbeln,
        posnr LIKE vbkd-posnr,
        bstdk LIKE vbkd-bstdk.
DATA: END OF t_vbkd.

DATA: BEGIN OF t_a511 OCCURS 0.
        INCLUDE STRUCTURE a511.
      DATA: END OF t_a511.
DATA: BEGIN OF t_a511x OCCURS 0.
        INCLUDE STRUCTURE a511.
      DATA: END OF t_a511x.
DATA: BEGIN OF t_a511y OCCURS 0.
        INCLUDE STRUCTURE a511.
      DATA: END OF t_a511y.

DATA: BEGIN OF t_vttp OCCURS 0.
        INCLUDE STRUCTURE vttp.
      DATA: END OF t_vttp.

DATA : t_vttk   TYPE STANDARD TABLE OF vttk INITIAL SIZE 0
                WITH HEADER LINE.

DATA: va_avr TYPE i,
      gv_day TYPE int4.

RANGES: ra_lgorti FOR lips-lgort,
        ra_lgorte FOR lips-lgort,
        ra_date   FOR a511-datab.

DATA : gv_day01 TYPE int4,
       gv_day02 TYPE int4,
       gv_day03 TYPE int4,
       gv_day04 TYPE int4,
       gv_day05 TYPE int4,
       gv_day06 TYPE int4.
*       gv_day07   TYPE int4.

DATA : gv_flag    TYPE sy-subrc.

DATA : gt_zplbc   LIKE zplbc OCCURS 0 WITH HEADER LINE.
DATA : ra_lfart  LIKE selopt OCCURS 0 WITH HEADER LINE,
       sales_org LIKE selopt OCCURS 0 WITH HEADER LINE.

DATA : gt_out     TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0.

DATA : BEGIN OF gt_excel OCCURS 0,
         row   LIKE alsmex_tabline-row,
         col   LIKE alsmex_tabline-col,
         value LIKE alsmex_tabline-value,
       END OF gt_excel.

DATA : gt_001   TYPE STANDARD TABLE OF zghmmdt001,
       gt_lips  TYPE STANDARD TABLE OF lips,
       gt_mara  TYPE STANDARD TABLE OF ty_mara,
       gt_marm  TYPE STANDARD TABLE OF marm,
       gt_t143t TYPE STANDARD TABLE OF t143t,
       gt_drho  TYPE STANDARD TABLE OF ty_drho.

DATA : gv_quarter     TYPE zghmmdt001-quarter,
       gv_mjahr       TYPE zghmmdt001-mjahr,
       gv_standar(50),
       gv_actual(50).

DATA : gv_uline     TYPE i.

SELECTION-SCREEN: BEGIN OF BLOCK prog
                           WITH FRAME TITLE TEXT-f58.

PARAMETER :
    dc LIKE knvv-vtweg  DEFAULT '10' NO-DISPLAY,
    div LIKE knvv-spart DEFAULT '00' NO-DISPLAY,
    pa_path(52) DEFAULT '\\tdsdev01\interface\DO-Monitor\' LOWER CASE
    NO-DISPLAY,
    pa_rho  TYPE xfeld NO-DISPLAY.

PARAMETERS:
  pa_vkorg  LIKE likp-vkorg DEFAULT '8020' MODIF ID vko." NO-DISPLAY.

PARAMETERS:
  pa_lfart  LIKE likp-lfart MODIF ID lfa.

SELECT-OPTIONS :
    ship_pnt FOR likp-vstel OBLIGATORY MEMORY ID vst MODIF ID tds,
    ship_to  FOR likp-kunnr MODIF ID sht,
    so_kvgr3 FOR knvv-kvgr3 MODIF ID kv3,
    del_num  FOR likp-vbeln MODIF ID xxx,
    crt_date FOR likp-erdat MODIF ID crt,
    ent_time FOR likp-erzet MODIF ID xxx.

PARAMETERS pa_filnm   LIKE rlgrap-filename MODIF ID upl.

PARAMETERS united AS CHECKBOX MODIF ID uni.
PARAMETERS cr_date AS CHECKBOX MODIF ID crd.
PARAMETERS cr AS CHECKBOX MODIF ID crx.
*PARAMETER :
*    p_spmon LIKE s031-spmon MODIF ID yyy
*                            OBLIGATORY
*                            DEFAULT sy-datum(6).

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK lb1 WITH FRAME TITLE TEXT-080.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS inc RADIOBUTTON GROUP grp DEFAULT 'X' USER-COMMAND outbut.
SELECTION-SCREEN : COMMENT 3(45) TEXT-003 FOR FIELD inc.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS dpl RADIOBUTTON GROUP grp .
SELECTION-SCREEN : COMMENT 3(45) TEXT-004 FOR FIELD dpl.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS det RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-005 FOR FIELD det.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS day RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-006 FOR FIELD day.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS dis RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-008 FOR FIELD dis.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS dp1 RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-012 FOR FIELD dp1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS dp2 RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-013 FOR FIELD dp2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS wh1 RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-009 FOR FIELD wh1.
SELECTION-SCREEN POSITION 50.
PARAMETERS pa_chwh1 AS CHECKBOX MODIF ID pc1.
SELECTION-SCREEN : COMMENT 53(8) TEXT-015 FOR FIELD pa_chwh1 MODIF ID pc1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS wh2 RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-010 FOR FIELD wh2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS sum RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-014 FOR FIELD sum.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS dsl RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-011 FOR FIELD dsl.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS tds RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-007 FOR FIELD tds.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS upl RADIOBUTTON GROUP grp MODIF ID upl.
SELECTION-SCREEN : COMMENT 3(45) TEXT-016 FOR FIELD upl MODIF ID upl.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS rho RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(45) TEXT-017 FOR FIELD rho.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK lb1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK direct
                  WITH FRAME TITLE TEXT-f59.

PARAMETERS: p_vari LIKE disvariant-variant.

SELECTION-SCREEN: END OF BLOCK direct.
SELECTION-SCREEN: END OF BLOCK prog.

SELECTION-SCREEN SKIP.

PARAMETERS: p_buff AS CHECKBOX DEFAULT 'X' USER-COMMAND outbut.
*PARAMETERS: p_buff NO-DISPLAY.
PARAMETERS: dtl      AS CHECKBOX USER-COMMAND outbut MODIF ID rad,
            fieldnm  TYPE slis_fieldname MODIF ID rad,
            vstel    LIKE likp-vstel MODIF ID rad,
            type(12) MODIF ID rad,
            kdgrp    LIKE knvv-kdgrp MODIF ID rad,
            ktext    LIKE t151t-ktext MODIF ID rad,
            dlk(2)   MODIF ID rad.

PARAMETERS: p_hist AS CHECKBOX USER-COMMAND outbut.
* Include for ALV report
*~~~~~~~~~~~~~~~~*
INCLUDE zabp_alv.
*~~~~~~~~~~~~~~~~*
TOP-OF-PAGE.
  CLEAR judul.
  CASE crt_date-low+4(2).
    WHEN '01'. judul = 'January'.
    WHEN '02'. judul = 'February'.
    WHEN '03'. judul = 'March'.
    WHEN '04'. judul = 'April'.
    WHEN '05'. judul = 'May'.
    WHEN '06'. judul = 'June'.
    WHEN '07'. judul = 'July'.
    WHEN '08'. judul = 'August'.
    WHEN '09'. judul = 'September'.
    WHEN '10'. judul = 'October'.
    WHEN '11'. judul = 'November'.
    WHEN '12'. judul = 'December'.
  ENDCASE.

  month = judul.

  CONCATENATE 'Period : ' judul crt_date-low(4) INTO judul SEPARATED BY space.
  CASE 'X'.
    WHEN wh1.
      WRITE: /(150) 'Warehouse performance level (by Date)' CENTERED.
      WRITE: /(150) judul CENTERED.
    WHEN wh2.
      WRITE: /(150) 'Warehouse performance level (Outlet Khusus)' CENTERED.
      WRITE: /(150) judul CENTERED.
    WHEN rho.
      WRITE: /(100) sy-title CENTERED.
      WRITE: /(100) judul CENTERED.
    WHEN OTHERS.
      WRITE: /(150) sy-title CENTERED.
      WRITE: /(150) judul CENTERED.
  ENDCASE.

  SKIP 1.
  FORMAT COLOR 1.

  CASE 'X'.
    WHEN rho.
      CONCATENATE 'Standar Q' gv_quarter INTO gv_standar.
      CONCATENATE 'Actual' month gv_mjahr INTO gv_actual
      SEPARATED BY space.
      WRITE: / sy-uline(100).
      WRITE: / sy-vline, (4) 'Shpt',
               sy-vline, (20) gv_standar,
               sy-vline, (20) 'Actual',
               sy-vline, (20) 'Growth (%)',
               sy-vline, (20) 'Point',
               sy-vline.

    WHEN OTHERS.
*      IF cr IS INITIAL.
      PERFORM f_header_163.
*      ELSE.
*        IF day IS NOT INITIAL.
*          PERFORM f_header_163.
*        ELSE.
*          PERFORM f_header_176.
*        ENDIF.
*      ENDIF.
  ENDCASE.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.

*  IF sy-opsys EQ 'AIX'.
  pa_path = '/interface/DO-Monitor/'.
*  ENDIF.
  g_repid = sy-repid.
  PERFORM variant_init.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.

  IF sy-subrc EQ 0.
    pa_vkorg  = lv_parva.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

* Search help untuk period
  INCLUDE rmcs0f0m.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_spmon.
*  PERFORM monat_f4.

AT SELECTION-SCREEN.
  SELECT vstel city1 FROM tvst
  INNER JOIN adrc ON tvst~adrnr = adrc~addrnumber
  INTO TABLE i_tvst
  WHERE vstel IN ship_pnt.
  SORT i_tvst.
  LOOP AT i_tvst.
    AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
        ID 'ACTVT' FIELD '03'
        ID 'VSTEL' FIELD i_tvst-vstel.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH 'You are not authorized with Ship. Point'
       i_tvst-vstel.
    ENDIF.
  ENDLOOP.

  IF p_buff = ''.
    MESSAGE i002(zz) WITH
    'You must run in background if buffer switch off'.
  ENDIF.

  PERFORM pai_of_selection_screen.

  IF dtl EQ 'X'.
    CLEAR: inc.
    MODIFY SCREEN.
  ENDIF.

  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
    WHEN space.
      PERFORM f_validate_screen.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE 'X'.
      WHEN det OR rho.
        IF screen-group1 = 'YYY'.
          screen-input = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      WHEN OTHERS.
        IF screen-group1 = 'XXX'.
          screen-input = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.
          REFRESH : del_num, ent_time.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF tds IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'YYY' OR
        screen-group1 = 'TDS'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-group1 = 'RAD'.
      screen-active  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  CASE 'X'.
    WHEN inc.
      PERFORM f_selection_output USING : 'SHT', 'KV3', 'UNI', 'CRD', 'PC1',
                                         'UPL', 'CRX'.
      CLEAR : ship_to[], so_kvgr3[], ship_to, so_kvgr3, united.
    WHEN dpl.
      PERFORM f_selection_output USING : 'SHT', 'KV3', 'UNI', 'PC1', 'CRD',
                                         'UPL', 'CRX'.
      CLEAR : ship_to[], so_kvgr3[], ship_to, so_kvgr3, united.
    WHEN det.
      PERFORM f_selection_output USING : 'UNI', 'CRD', 'PC1', 'UPL', 'CRX'.
      CLEAR : united.
    WHEN dp1.
      PERFORM f_selection_output USING : 'PC1', 'UPL', 'CRX'.
    WHEN dp2.
      PERFORM f_selection_output USING : 'PC1', 'UPL', 'CRX'.
    WHEN day.
      PERFORM f_selection_output USING : 'PC1', 'UPL'.
    WHEN dis.
      PERFORM f_selection_output USING : 'PC1', 'UPL'.
    WHEN sum.
      PERFORM f_selection_output USING : 'PC1', 'UPL', 'CRX'.
    WHEN wh1.
      PERFORM f_selection_output USING : 'SHT', 'KV3', 'CRD', 'UPL', 'CRX'.
      CLEAR : ship_to[], so_kvgr3[], ship_to, so_kvgr3.
    WHEN wh2.
      PERFORM f_selection_output USING : 'SHT', 'KV3', 'CRD', 'PC1', 'UPL',
                                         'CRX'.
      CLEAR : ship_to[], so_kvgr3[], ship_to, so_kvgr3.
    WHEN dsl.
      PERFORM f_selection_output USING : 'SHT', 'KV3', 'PC1', 'UPL', 'CRX'.
      CLEAR : ship_to[], so_kvgr3[], ship_to, so_kvgr3.
    WHEN tds.
      PERFORM f_selection_output USING : 'SHT', 'KV3', 'UNI', 'CRD', 'PC1',
                                         'UPL', 'CRX'.
      CLEAR : ship_to[], so_kvgr3[], ship_to, so_kvgr3, united.
    WHEN upl.
      PERFORM f_selection_output USING : 'VKO', 'LFA', 'TDS', 'CRT', 'SHT',
                                         'KV3', 'UNI', 'CRD', 'PC1', 'CRX'.
      CLEAR : ship_to[], so_kvgr3[], ship_to, so_kvgr3, united, pa_lfart,
              pa_vkorg, crt_date.
    WHEN rho.
      PERFORM f_selection_output USING : 'CRD', 'PC1', 'UPL', 'SHT',
                                         'KV3', 'XXX', 'CRX'.
      CLEAR : united.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_filnm.
  PERFORM f_get_filename.

AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'CHOOSE'.
      PERFORM f_choose.
  ENDCASE.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: ld_flag   TYPE i,
        ld_dis(1),
        ld_dsl(1),
        ld_wh2(1),
        ld_dp2(1).

  PERFORM f_init_data.

  CASE 'X'.
    WHEN upl.
      PERFORM f_upload_xls.
    WHEN rho.
      PERFORM f_submit_rho.

    WHEN OTHERS.
      ra_lgorte-low    = '100*'.
      ra_lgorte-sign   = 'E'.
      ra_lgorte-option = 'CP'.
      APPEND ra_lgorte.
      ra_lgorti-low    = '100*'.
      ra_lgorti-sign   = 'I'.
      ra_lgorti-option = 'CP'.
      APPEND ra_lgorti.

* United condition
      IF united IS NOT INITIAL.
        CASE 'X'.
          WHEN wh1 OR wh2.
            PERFORM f_united USING '1' pa_vkorg.
          WHEN day OR dis OR dsl OR dp1 OR dp2 OR sum.
            PERFORM f_united USING '1' pa_vkorg.
        ENDCASE.
      ELSE.
        ra_lfart-low    = pa_lfart.
        ra_lfart-sign   = 'I'.
        ra_lfart-option = 'EQ'.
        APPEND ra_lfart.
      ENDIF.

      IF p_buff = '' AND sy-batch <> 'X' AND sy-uzeit < '150000'.
        MESSAGE i014(zz).
        LEAVE LIST-PROCESSING.
      ENDIF.

      IF tds IS NOT INITIAL.
        SUBMIT zm_getdata_do VIA SELECTION-SCREEN AND RETURN.
      ELSE.
        PERFORM f_init_date.
        PERFORM f_get_a511.
*    IF det = 'X'.
**      CLEAR p_spmon.
        PERFORM calc_spmon.
*    ELSE.
*      REFRESH crt_date.
*    ENDIF.
        PERFORM select_data.
        PERFORM f_get_spgd.
        PERFORM f_process_data_from_db.
*  PERFORM f_get_lead_time.

        CASE 'X'.
          WHEN day OR wh1 OR dp1.
            ld_flag = 0.
          WHEN dis OR wh2 OR dp2.
            ld_flag = 1.
            IF dis IS NOT INITIAL.
              ld_dis = 'X'.
            ENDIF.
            IF dp2 IS NOT INITIAL.
              ld_dp2 = 'X'.
            ENDIF.
            IF wh2 IS NOT INITIAL.
              ld_wh2 = 'X'.
            ENDIF.
          WHEN rho.
        ENDCASE.

        IF sum IS INITIAL.
          IF dsl IS INITIAL.
            PERFORM f_sales_district USING ld_flag.
            PERFORM f_detail_slk USING ld_flag 'MM' ld_dis ld_wh2 ld_dp2.
          ELSE.
            PERFORM f_ext_expendition.
          ENDIF.
        ENDIF.

        PERFORM process_data.

        IF dtl EQ 'X'.
          PERFORM f_detail_process USING vstel type kdgrp ktext dlk '' fieldnm ''.
        ENDIF.

        IF day EQ 'X' OR dis EQ 'X' OR dsl EQ 'X' OR wh1 EQ 'X' OR wh2 EQ 'X' OR
          dp1 EQ 'X' OR dp2 EQ 'X'.
          SET PF-STATUS '100'.
          CASE 'X'.
            WHEN day.
              SET TITLEBAR 'XXX' WITH TEXT-006.
            WHEN dis.
              SET TITLEBAR 'XXX' WITH TEXT-008.
            WHEN dp1.
              SET TITLEBAR 'XXX' WITH TEXT-012.
            WHEN dp2.
              SET TITLEBAR 'XXX' WITH TEXT-013.
            WHEN wh1.
              SET TITLEBAR 'XXX' WITH TEXT-009.
            WHEN wh2.
              SET TITLEBAR 'XXX' WITH TEXT-010.
          ENDCASE.

          PERFORM f_write_day.

*        ELSEIF rho EQ 'X'.
*          SET PF-STATUS '100'.
*          SET TITLEBAR 'XXX' WITH text-017.
*          PERFORM f_get_lips.
*          PERFORM f_detail_rho_process.
*          IF pa_rho IS INITIAL.
*            PERFORM f_write_rho.
*          ELSE.
*            PERFORM f_export_memory.
*          ENDIF.
        ELSEIF sum EQ 'X'.
          PERFORM f_process_summary.
          PERFORM f_write_summary.
        ENDIF.
      ENDIF.
  ENDCASE.

  INCLUDE zm_incentif_united.

END-OF-SELECTION.

*********************************** ALV *******************************

  IF day IS INITIAL AND dis IS INITIAL AND
     dp1 IS INITIAL AND dp2 IS INITIAL AND
     dsl IS INITIAL AND
     wh1 IS INITIAL AND wh2 IS INITIAL AND
     sum IS INITIAL.
    PERFORM alv_prep.
  ENDIF.

  CLEAR judul.
  CASE crt_date-low+4(2).
    WHEN '01'. judul = 'January'.
    WHEN '02'. judul = 'February'.
    WHEN '03'. judul = 'March'.
    WHEN '04'. judul = 'April'.
    WHEN '05'. judul = 'May'.
    WHEN '06'. judul = 'June'.
    WHEN '07'. judul = 'July'.
    WHEN '08'. judul = 'August'.
    WHEN '09'. judul = 'September'.
    WHEN '10'. judul = 'October'.
    WHEN '11'. judul = 'November'.
    WHEN '12'. judul = 'December'.
  ENDCASE.

*-----------------------------------------------------------*
*                 Proses  Display list
*-----------------------------------------------------------*
  IF dtl EQ 'X' AND
    vstel IS NOT INITIAL.
    REFRESH: i_result, i_outpl, i_outpl2, i_outpl3.
    CONCATENATE 'Delivery performance level (by Date)'
                judul crt_date-low(4)
    INTO judul SEPARATED BY space.
    PERFORM layout_init USING gs_layout judul 'X'.
    PERFORM showlist USING 'I_OUTPL4' judul ''.
  ENDIF.

  CASE 'X'.
    WHEN det.
      REFRESH: i_outpl, i_outpl2, i_outpl3.
      judul = 'Incentive Dept. WnD Delivery Level (Detail)'.
      PERFORM layout_init USING gs_layout judul 'X'.
      PERFORM showlist USING 'I_RESULT' judul e_user_command.
      REFRESH: i_result, i_outpl, i_outpl2, i_outpl3.
    WHEN inc.
      REFRESH: i_result, i_outpl2, i_outpl3.
      CONCATENATE 'Incentive Dept. WnD Delivery Level for period'
                  judul crt_date-low(4)
      INTO judul SEPARATED BY space.
      PERFORM layout_init USING gs_layout judul 'X'.
      PERFORM showlist USING 'I_OUTPL' judul ''.
      REFRESH: i_result, i_outpl, i_outpl2, i_outpl3.
    WHEN dpl.
      REFRESH: i_result, i_outpl, i_outpl3.
      CONCATENATE 'Delivery Performance Level for period'
                  judul crt_date-low(4)
      INTO judul SEPARATED BY space.
      PERFORM layout_init USING gs_layout judul 'X'.
      PERFORM showlist USING 'I_OUTPL2' judul ''.
      REFRESH: i_result, i_outpl, i_outpl2, i_outpl3.
    WHEN day.
*      REFRESH: i_result, i_outpl, i_outpl2.
*      CONCATENATE 'Delivery performance level (by Date)'
*                  judul p_spmon(4)
*      INTO judul SEPARATED BY space.
*      PERFORM layout_init USING gs_layout judul 'X'.
*      PERFORM showlist USING 'I_OUTPL3' judul ''.
    WHEN sum.
      REFRESH: i_result, i_outpl, i_outpl3.
      judul = 'Summary Report'.
      PERFORM layout_init USING gs_layout judul 'X'.
      PERFORM showlist USING 'GT_OUT' judul ''.
      REFRESH: i_result, i_outpl, i_outpl2, i_outpl3.
  ENDCASE.


*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data.
  DATA    : i_objectid     TYPE t_objectid OCCURS 0,
            wa_objectid    TYPE t_objectid,
            l_dataset1(70),
            n              TYPE i,
            lv_dpl(1).

  REFRESH : i_objectid, i_cdpos, i_cdhdr, i_result.
  CLEAR   : wa_objectid, wa_cdpos, wa_cdhdr, wa_result.
*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '10'
      text       = 'Data is being read...'.
*-----------------------------------------------------*
  IF p_buff = 'X'.
*----------------------*
* Ambil data dari text
*----------------------*
    lv_dpl  = dpl.

    CASE 'X'.
      WHEN det.
        LOOP AT i_tvst.
          LOOP AT i_spmon.
            PERFORM f_dataset USING pa_path i_tvst-vstel i_spmon-spmon 'MM' 'X' ''.
          ENDLOOP.
        ENDLOOP.
      WHEN rho.
        LOOP AT i_tvst.
          LOOP AT i_spmon.
            PERFORM f_dataset USING pa_path i_tvst-vstel i_spmon-spmon 'MM' 'X' ''.
          ENDLOOP.
        ENDLOOP.
      WHEN OTHERS.
        LOOP AT i_tvst.
          PERFORM f_dataset USING pa_path i_tvst-vstel crt_date-low 'MM' '' lv_dpl.
        ENDLOOP.
    ENDCASE.

    PERFORM f_kdgrp04.

    IF p_hist = ''.
* Untuk data hari ini jangan dimasukkan karena akan dibaca lagi
      PERFORM f_delete_today_transaction.

      PERFORM f_get_sales_district.

      IF i_vbeln[] IS NOT INITIAL.
        PERFORM f_get_do USING ''.
      ENDIF.

* Cek apakah ada data hari ini yang akan ditampilkan
*      IF ( det = ''  AND crt_date-low(6) = sy-datum(6) )
*      OR ( det = 'X' AND sy-datum IN crt_date ).
      IF sy-datum IN crt_date.
        PERFORM f_get_do USING 'X'.
      ENDIF.
    ENDIF.
  ELSE.
*--------------------------------------------------------*
* Jika tidak menggunakan buffer ambil data dari database
*--------------------------------------------------------*
    IF det = ''.
*      CONCATENATE p_spmon '01' INTO crt_date-low.
*      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
*        EXPORTING
*          day_in            = crt_date-low
*        IMPORTING
*          last_day_of_month = crt_date-high.
*      crt_date-sign   = 'I'. crt_date-option = 'BT'.
*      APPEND crt_date.
    ENDIF.

    SELECT likp~lfart likp~vstel likp~vbeln likp~kunnr likp~erdat
           likp~erzet likp~podat likp~potim likp~wadat_ist
           zmm_cust_rec~crdat zmm_cust_rec~crtim
           knvv~kdgrp knvv~kvgr3 kna1~ort01 kna1~katr1 kna1~name1
           vbuk~kostk vbuk~wbstk vbuk~pdstk knvv~bzirk
    INTO CORRESPONDING FIELDS OF TABLE i_result2
    FROM ( likp
           LEFT JOIN zmm_cust_rec
           ON zmm_cust_rec~vbeln = likp~vbeln
           INNER JOIN knvv
           ON knvv~kunnr = likp~kunnr
           AND knvv~vkorg = likp~vkorg
           INNER JOIN kna1
           ON kna1~kunnr = knvv~kunnr
           INNER JOIN vbuk
           ON vbuk~vbeln = likp~vbeln )
           WHERE likp~vstel IN ship_pnt
             AND likp~kunnr IN ship_to
             AND likp~vbeln IN del_num
             AND likp~erdat IN crt_date
             AND likp~erzet IN ent_time
             AND knvv~vtweg EQ dc
             AND knvv~spart EQ div
             AND knvv~kvgr3 IN so_kvgr3.
*   Jika tidak ada data, keluar
    IF sy-subrc <> 0.
      MESSAGE s260(aq).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  IF united IS NOT INITIAL.
    PERFORM f_modify_united TABLES i_result.
    PERFORM f_modify_united TABLES i_result2.
  ENDIF.

*----------------------------------------------------------------------*
* Proses cleansing data from database
*----------------------------------------------------------------------*
* Kalau pakai left join, harus delete data berikut ini
  PERFORM f_cleansing_data.

  CASE 'X'.
    WHEN dpl.
      PERFORM f_move_data USING lv_dpl.
    WHEN day OR dtl OR dis OR wh1 OR wh2 OR dsl OR dp1 OR dp2 OR sum.
      PERFORM f_move_data USING ''.
    WHEN OTHERS.
  ENDCASE.

  PERFORM f_change_document.

  PERFORM f_field_modify.

ENDFORM.                    " SELECT_DATA

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data.
  DATA: ld_day       LIKE a511-zday3,
        ld_create_dt LIKE wa_result-cr_create_dt,
        ld_create_tm LIKE wa_result-cr_create_tm.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '80'
      text       = 'Data is being process...'.
*------------------------------------------------------*
  SELECT kdgrp ktext FROM t151t
  INTO TABLE i_t151
  WHERE spras EQ 'EN'.
  SORT i_t151 BY kdgrp.
  SORT i_result BY vbeln.
  SORT i_custrec BY vbeln.
  SORT t_vbkd BY vbeln.

  va_avr  = 1.
  LOOP AT i_result INTO wa_result.

    CLEAR : wa_outpl, wa_outpl2, i_t151, wa_outpl3.

*----------------------------------------
* Calculation for KPI evaluation criteria
*----------------------------------------
    IF dpl = ''.
      IF ( day = '' AND dis = '' AND dsl = '' AND wh1 = '' AND wh2 = '' AND
           dp1 = '' AND dp2 = '' AND sum = '' ) AND dtl = ''.
*    If wa_result-kdgrp = '06'.
*       continue.
*    Endif.
        wa_outpl-vstel  = wa_result-vstel.
        wa_outpl-kdgrp  = wa_result-kdgrp.
        wa_outpl-dlk    = wa_result-dlk.
        wa_outpl-cnt_dn = wa_result-cnt_dn.
        wa_outpl-pkdo   = wa_result-pkdo.
        wa_outpl-gipk   = wa_result-gipk.
        wa_outpl-gido   = wa_result-gido.
        wa_outpl-crdo   = wa_result-crdo.
        wa_outpl-spgdgi  = wa_result-spgdgi.
        wa_outpl-crspgd  = wa_result-crspgd.
        wa_outpl-dospgd  = wa_result-dospgd.

        READ TABLE i_t151
           WITH KEY kdgrp = wa_outpl-kdgrp
           BINARY SEARCH.
        wa_outpl-ktext = i_t151-ktext.

        CASE wa_outpl-kdgrp.
          WHEN '04' OR '05' OR '07' OR '10' OR '11' OR 'T1'.
*            wa_outpl-type = 'TRM'.
            wa_outpl-type = 'GT'.
          WHEN '03'.
*            wa_outpl-type = 'MVR'.
            wa_outpl-type = 'MT'.
          WHEN '02' OR '06' OR '08' OR '09'.
            wa_outpl-type = 'Corp. Pharma'.
        ENDCASE.

        wa_outpl-total = wa_outpl-pkdo + wa_outpl-gipk + wa_outpl-spgdgi +
                         wa_outpl-crspgd + wa_outpl-dospgd + wa_outpl-gido +
                         wa_outpl-crdo.

        COLLECT wa_outpl INTO i_outpl.

*  -------------------------------------------
*   Calculation for Delivery performance level (by Date)
*  -------------------------------------------
      ELSEIF day = 'X' OR dtl = 'X' OR dis = 'X' OR dsl = 'X' OR
             wh1 = 'X' OR wh2 = 'X' OR dp1 = 'X' OR dp2 = 'X' OR
             sum = 'X'.
        wa_outpl3-vstel = wa_result-vstel.
        wa_outpl3-kdgrp = wa_result-kdgrp.
        wa_outpl3-dlk = wa_result-dlk.
        wa_outpl3-bzirk = wa_result-bzirk.

        READ TABLE i_t151
           WITH KEY kdgrp = wa_outpl3-kdgrp
           BINARY SEARCH.
        wa_outpl3-ktext = i_t151-ktext.

        CASE wa_outpl3-kdgrp.
          WHEN '04' OR '05' OR '07' OR '10' OR '11' OR 'T1'.
*            wa_outpl3-type = 'TRM'.
            wa_outpl3-type = 'GT'.
          WHEN '03'.
            IF wa_result-kvgr3 = '031' OR wa_result-kvgr3 = '034'.
              wa_outpl3-ktext = 'SM Key account'.
            ENDIF.
*            wa_outpl3-type = 'MVR'.
            wa_outpl3-type = 'MT'.
          WHEN '02' OR '06' OR '08' OR '09'.
            wa_outpl3-type = 'Corp. Pharma'.
        ENDCASE.

*        PERFORM f_hitung_lead_time CHANGING wa_outpl3-0hari wa_outpl3-1hari wa_outpl3-2hari
*                                            wa_outpl3-3hari wa_outpl3-4hari.
        CLEAR ld_create_dt.
        IF day = 'X' OR dtl = 'X' OR dis = 'X' OR dsl = 'X'.
          ld_create_dt = wa_result-cr_create_dt.
        ELSEIF dp1 = 'X' OR dp2 = 'X'.
          ld_create_dt = wa_result-cr_vs_spgd_dt.
        ELSEIF wh1 = 'X' OR wh2 = 'X'.
          ld_create_dt = wa_result-do_vs_spgd_dt.
        ENDIF.

*        CASE wa_result-cr_create_dt.
        CASE ld_create_dt.
*          WHEN 999.
*            wa_outpl3-0hari  = 1.
          WHEN 0.
            wa_outpl3-0hari  = 1.
          WHEN 1.
            wa_outpl3-1hari  = 1.
          WHEN 2.
            wa_outpl3-2hari  = 1.
          WHEN 3.
            wa_outpl3-3hari  = 1.
          WHEN 999.
            IF cr_date = 'X'.
              IF wa_result-crdat IS NOT INITIAL.
                wa_outpl3-4hari  = 1.
              ENDIF.
            ELSE.
              wa_outpl3-4hari  = 1.
            ENDIF.
          WHEN OTHERS.
            wa_outpl3-4hari  = 1.
        ENDCASE.

        wa_outpl3-total = wa_outpl3-0hari + wa_outpl3-1hari + wa_outpl3-2hari +
                          wa_outpl3-3hari + wa_outpl3-4hari.

        COLLECT wa_outpl3 INTO i_outpl3.
      ENDIF.
*-------------------------------------------
* Calculation for Delivery performance Level
*-------------------------------------------
    ELSEIF dpl = 'X'.
      wa_outpl2-vstel = wa_result-vstel.
      wa_outpl2-kdgrp = wa_result-kdgrp.
      wa_outpl2-dlk = wa_result-dlk.

      READ TABLE i_t151
         WITH KEY kdgrp = wa_outpl2-kdgrp
         BINARY SEARCH.
      wa_outpl2-ktext = i_t151-ktext.

      CASE wa_outpl2-kdgrp.
        WHEN '04' OR '05' OR '07' OR '10' OR '11' OR 'T1'.
*          wa_outpl2-type = 'TRM'.
          wa_outpl2-type = 'GT'.
        WHEN '03'.
          IF wa_result-kvgr3 = '031' OR wa_result-kvgr3 = '034'.
            wa_outpl2-ktext = 'SM Key account'.
          ENDIF.
*          wa_outpl2-type = 'MVR'.
          wa_outpl2-type = 'MT'.
        WHEN '02' OR '06' OR '08' OR '09'.
          wa_outpl2-type = 'Corp. Pharma'.
      ENDCASE.

      CASE wa_result-cr_create_dt.
*        WHEN 0 OR 999.
        WHEN 0.
          IF wa_result-cr_create_tm(2) < 3.
            wa_outpl2-3jam  = '1'.
          ELSEIF wa_result-cr_create_tm(2) < 6.
            wa_outpl2-6jam  = '1'.
          ELSEIF wa_result-cr_create_tm(2) < 12.
            wa_outpl2-12jam = '1'.
          ELSEIF wa_result-cr_create_tm(2) < 24.
            wa_outpl2-24jam = '1'.
          ENDIF.
        WHEN 1.
          wa_outpl2-48jam = '1'.
        WHEN 2.
          wa_outpl2-72jam = '1'.
        WHEN 999.
          wa_outpl2-73jam = '1'.
        WHEN OTHERS.
          wa_outpl2-73jam = '1'.
      ENDCASE.

      wa_outpl2-total = wa_outpl2-3jam + wa_outpl2-6jam + wa_outpl2-12jam +
                       wa_outpl2-24jam + wa_outpl2-48jam + wa_outpl2-72jam +
                       wa_outpl2-73jam.

      COLLECT wa_outpl2 INTO i_outpl2.
    ENDIF.

    IF day EQ 'X' OR dis EQ 'X' OR dsl EQ 'X' OR wh1 EQ 'X' OR wh2 EQ 'X' OR
      dp1 EQ 'X' OR dp2 EQ 'X' OR sum EQ 'X'.
      wa_result-ktext = wa_outpl3-ktext.
      wa_result-type = wa_outpl3-type.
      MODIFY i_result FROM wa_result TRANSPORTING ktext type.
    ENDIF.
  ENDLOOP.

  IF dpl = ''.
    IF ( day = '' AND dis = '' AND dp1 = '' AND dp2 = '' AND wh1 = '' AND wh2 = '' )
      AND dtl = '' AND dsl = '' AND sum = ''.
      SORT i_outpl BY vstel type dlk.
    ELSE.
      CLEAR: wa_outpl3, ld_day.
      SORT i_outpl3 BY type.
      LOOP AT i_outpl3 INTO wa_outpl3.
        PERFORM f_hitung_average USING wa_outpl3 va_avr ''.
        IF wa_outpl3-kdgrp = '01'.
          READ TABLE i_t151
             WITH KEY kdgrp = wa_outpl3-kdgrp
             BINARY SEARCH.
          wa_outpl3-ktext = i_t151-ktext.
        ENDIF.

        PERFORM f_target_calculate USING    pa_vkorg wa_outpl3 ''
                                   CHANGING ld_day.

        CASE wa_outpl3-dlk.
          WHEN 'DK'.
            CASE wa_outpl3-type.
              WHEN 'Corp. Pharma'.
                PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                               wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari
                                               '' '' wa_outpl3-total
                                         CHANGING wa_outpl3-std.
              WHEN 'GT'.
                PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                               wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari
                                               '' '' wa_outpl3-total
                                         CHANGING wa_outpl3-std.
              WHEN 'MT'.
                PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                               wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari
                                               '' '' wa_outpl3-total
                                         CHANGING wa_outpl3-std.
            ENDCASE.
          WHEN 'LK'.
            PERFORM f_get_percentage USING ld_day '' wa_outpl3-0hari wa_outpl3-1hari
                                           wa_outpl3-2hari wa_outpl3-3hari wa_outpl3-4hari
                                           '' '' wa_outpl3-total
                                     CHANGING wa_outpl3-std.
        ENDCASE.
        MODIFY i_outpl3 FROM wa_outpl3.
      ENDLOOP.
      SORT i_outpl3 BY vstel type dlk.

      IF dis EQ 'X' OR wh2 EQ 'X' OR dsl = 'X' OR dp2 = 'X'.
        PERFORM f_average_khusus USING ld_day 'X'.
      ENDIF.
    ENDIF.
  ELSEIF dpl = 'X'.
    CLEAR wa_outpl2.
    LOOP AT i_outpl2 INTO wa_outpl2 WHERE kdgrp = '01'.
      READ TABLE i_t151
         WITH KEY kdgrp = wa_outpl2-kdgrp
         BINARY SEARCH.
      wa_outpl2-ktext = i_t151-ktext.
      MODIFY i_outpl2 FROM wa_outpl2.
    ENDLOOP.
    SORT i_outpl2 BY vstel type dlk.
  ENDIF.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '100'
      text       = 'Data is being process...'.
*------------------------------------------------------*
  REFRESH : i_t151, i_tvst.
  CLEAR   : wa_result.
ENDFORM.                    " PROCESS_DATA


*&---------------------------------------------------------------------*
*&      Form  ALV_PREP
*&---------------------------------------------------------------------*
FORM alv_prep.

  IF dtl EQ 'X'.
    PERFORM build_cat USING 'VSTEL' 5 '' '' 'C710' ''
                            'VSTEL' 'LIKP' '' '' 'X' '' 'X' '' ''.
    PERFORM build_cat USING 'KDGRP' 4 'Type Outlet' '' 'C300' ''
                            'KDGRP' 'KNVV' '' '' 'X' '' 'X' '' ''.
    PERFORM build_cat USING 'KVGR3' 4 'Sub Cust.Group' '' 'C500' ''
                            'KVGR3' 'KNVV' '' '' 'X' '' 'X' '' ''.
    PERFORM build_cat USING 'VBELN' 10 'Delivery' '' 'C100' ''
                            'VBELN' 'LIKP' '' '' 'X' '' 'X' '' ''.
    PERFORM build_cat USING 'KUNNR' 8 'Ship-to' '' 'C600' ''
                            'KUNNR' 'LIKP' '' '' 'X' '' 'X' '' ''.
    PERFORM build_cat USING 'NAME1' 22 'Name of Ship-to party' '' 'C600' ''
                            'KUNNR' 'NAME1' '' '' 'X' '' 'X' '' ''.
    PERFORM build_cat USING 'ORT01' 15 'Cust.City' 'CHAR' '' ''
                            '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CITY1' 15 'Branch City' 'CHAR' '' ''
                            '' '' '' '' '' '' '' '' ''.
*    PERFORM build_cat USING 'ERDAT_SO' 10 'SO Date' '' '' ''
*                            '' '' '' '' '' '' '' '' ''.
*    PERFORM build_cat USING 'ERZET_SO' 8 'SO Time' '' '' ''
*                            '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'ERDAT' 10 'DO Date' '' '' ''
                            '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'ERZET' 8 'DO Time' '' '' ''
                            'ERZET' 'LIKP' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'KODAT' 10 'Pick.Date' '' '' ''
                            'KODAT' 'LIKP' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'KOUHR' 8 'Pick.Time' '' '' ''
                            'KOUHR' 'LIKP' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'WADAT_IST' 10 'Act GI Date' '' '' ''
                            'WADAT_IST' 'LIKP' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'GI_TIME' 8 'GI Time' 'TIMS' '' ''
                            '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'ERDAT_SPGD' 10 'Ship.Date' '' '' ''
                            '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'ERZET_SPGD' 10 'Ship.Time' '' '' ''
                            '' '' '' '' '' '' '' '' ''.
    IF dsl IS NOT INITIAL AND gv_flag IS NOT INITIAL.
      PERFORM build_cat USING 'CRDATEXT' 12 'CR Date Ext' '' '' ''
                              '' '' '' '' '' '' '' '' ''.
      PERFORM build_cat USING 'CRTIMEXT' 10 'CR Time Ext' '' '' ''
                              '' '' '' '' '' '' '' '' ''.
    ENDIF.
    PERFORM build_cat USING 'CRDAT' 10 'CR Date' 'DATS' '' ''
                            '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CRTIM' 8 'CR Time' 'TIMS' '' ''
                            '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'PK_CREATE_DT' 10 'Pick. Vs DO date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'PK_CREATE_TM' 8 'Pick. Vs DO Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'GI_VS_PK_DT' 10 'GI Vs Pick. Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'GI_VS_PK_TM' 8 'GI Vs Pick. Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'SPGD_VS_GI_DT' 10 'Ship Vs GI Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'SPGD_VS_GI_TM' 8 'Ship Vs GI Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CR_VS_SPGD_DT' 10 'CR Vs Ship.Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'CR_VS_SPGD_TM' 8 'CR Vs Ship.Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'DO_VS_SPGD_DT' 10 'Ship Vs DO Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'DO_VS_SPGD_TM' 8 'Ship Vs DO Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CR_VS_GI_DT' 10 'CR Vs GI Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'CR_VS_GI_TM' 8 'CR Vs GI Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CR_CREATE_DT' 10 'CR Vs DO Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'CR_CREATE_TM' 8 'CR Vs DO Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'GI_CREATE_DT' 10 'GI Vs DO Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
    PERFORM build_cat USING 'GI_CREATE_TM' 8 'GI Vs DO Time' 'TIMS' ''
                            '' '' '' '' '' '' '' '' '' ''.
    PERFORM build_cat USING 'LFART' 4 'DlvTy' '' '' ''
                            'LFART' 'LIKP' '' '' '' '' 'X' '' ''.
    PERFORM build_cat USING 'DLK' 5 'DK/LK' 'CHAR' 'C600' ''
                            '' '' '' '' 'X' '' '' '' ''.
    PERFORM build_cat USING 'PKDO' 5 'Picking/DO' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' ''.
    PERFORM build_cat USING 'GIPK' 5 'GI/Picking' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' ''.
    PERFORM build_cat USING 'SPGDGI' 5 'Ship/GI' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CRSPGD' 5 'CR/Ship' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' ''.
    PERFORM build_cat USING 'DOSPGD' 5 'Ship/DO' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' ''.
    PERFORM build_cat USING 'GIDO' 5 'GI/DO' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CRDO' 5 'CR/DO' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' ''.
    PERFORM build_cat USING 'CNT_DN' 6 'Total DN' 'DEC' '' ''
                            '' '' 'X' '' '' '' '' '' '26'.
    IF cr IS NOT INITIAL.
      PERFORM build_cat USING 'CR2DT' 6 'CR2 Date' '' '' ''
                              '' '' '' '' '' '' '' '' '29'.
      PERFORM build_cat USING 'CR2TM' 6 'CR2 Time' '' '' ''
                              '' '' '' '' '' '' '' '' '30'.
      PERFORM build_cat USING 'CR2_VS_SPGD_DT' 10 'CR2 Vs Ship.Date' 'DEC' ''
                              '' '' '' '' '' '' '' '' 'R' '31'.
      PERFORM build_cat USING 'CR2_VS_SPGD_TM' 8 'CR2 Vs Ship.Time' 'TIMS' ''
                              '' '' '' '' '' '' '' '' '' '32'.
      PERFORM build_cat USING 'CR2_VS_GI_DT' 10 'CR2 Vs GI Date' 'DEC' ''
                              '' '' '' '' '' '' '' '' 'R' '33'.
      PERFORM build_cat USING 'CR2_VS_GI_TM' 8 'CR2 Vs GI Time' 'TIMS' ''
                              '' '' '' '' '' '' '' '' '' '34'.
      PERFORM build_cat USING 'CR2_CREATE_DT' 10 'CR2 Vs DO Date' 'DEC' ''
                              '' '' '' '' '' '' '' '' 'R' '35'.
      PERFORM build_cat USING 'CR2_CREATE_TM' 8 'CR2 Vs DO Time' 'TIMS' ''
                              '' '' '' '' '' '' '' '' '' '36'.
    ENDIF.
  ELSE.
    CASE 'X'.
      WHEN day.
*        PERFORM build_cat USING 'VSTEL' 5 '' '' 'C710' ''
*                                'VSTEL' 'LIKP' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_czat USING 'DLK' 5 'DK/LK' 'CHAR' 'C600' ''
*                                '' '' '' '' 'X' '' '' '' ''.
*        PERFORM build_cat USING 'TYPE' 10 'Grup Outlet' '' 'C500' ''
*                                '' '' '' '' 'X' '' '' '' ''.
*        PERFORM build_cat USING 'KDGRP' 4 'Type Outlet' '' 'C300' ''
*                                'KDGRP' 'KNVV' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING 'KTEXT' 4 'Desc' '' 'C100' ''
*                                'KTEXT' 'T151T' '' '' '' '' 'X' '' ''.
*        PERFORM build_cat USING '0HARI' 5 '0 Hari' 'DEC' '' ''
*                                '' '' 'X' 'X' '' '' '' '' ''.
*        PERFORM build_cat USING '1HARI' 5 '1 Hari' 'DEC' '' ''
*                                '' '' 'X' 'X' '' '' '' '' ''.
*        PERFORM build_cat USING '2HARI' 5 '2 Hari' 'DEC' '' ''
*                                '' '' 'X' 'X' '' '' '' '' ''.
*        PERFORM build_cat USING '3HARI' 5 '3 Hari' 'DEC' '' ''
*                                '' '' 'X' 'X' '' '' '' '' ''.
*        PERFORM build_cat USING '4HARI' 5 '> 3 Hari' 'DEC' '' ''
*                                '' '' 'X' 'X' '' '' '' '' ''.
*        PERFORM build_cat USING 'TOTAL' 5 'Total' 'DEC' '' ''
*                                '' '' 'X' '' '' '' '' '' ''.
*        PERFORM build_cat USING 'STD' 5 '% STD' 'DEC' '' ''
*                                '' '' '' '' '' '' '' '' ''.
      WHEN sum.
        PERFORM build_cat USING 'KETERANGAN' 10 'Keterangan' '' '' ''
                                '' '' '' '' '' '' '' '' ''.
        PERFORM build_cat USING 'VSTEL' 5 '' '' '' ''
                                'VSTEL' 'LIKP' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'NAME1' 20 '' '' '' ''
                                'NAME1' 'T001W' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'TYPE' 20 'Channel' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'KDGRP' 5 'CGrp' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'DLK' 10 'DK/LK' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'BZIRK' 10 'District' '' '' ''
                                'KNVV' 'BZIRK' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'TOTAL' 10 'DN' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.

        PERFORM build_cat USING 'JGI' 10 'Jumlah GI' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'JSH' 10 'Jumlah Shipment' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'JCR' 10 'Jumlah CR' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.

        PERFORM build_cat USING 'TARGET' 10 'Target' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'TARGETX' 15 'Target Khusus' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.

*        PERFORM build_cat USING '0' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '1' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '2' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '3' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '4' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '5' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*
*        PERFORM build_cat USING '0X' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '1X' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '2X' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '3X' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '4X' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '5X' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*
*        PERFORM build_cat USING '0Y' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '1Y' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '2Y' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '3Y' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '4Y' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING '5Y' 10 '' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.

        PERFORM build_cat USING 'HIT' 10 'HIT' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'HITX' 10 'HIT Khusus' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
*        PERFORM build_cat USING 'HITY' 10 'HIT Khusus' '' '' ''
*                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'HITNEW' 10 'HIT New' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.

      WHEN rho.
        PERFORM build_cat USING 'VKBUR' 5 '' '' 'C710' ''
                                'VKBUR' 'LIPS' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'VBELN' 10 'Delivery' '' 'C100' ''
                                'VBELN' 'LIKP' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'KUNNR' 8 'Ship-to' '' 'C600' ''
                                'KUNNR' 'LIKP' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'NAME1' 22 'Name of Ship-to party' '' 'C600' ''
                                'KUNNR' 'NAME1' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'KDGRP' 4 'Type Outlet' '' 'C300' ''
                                'KDGRP' 'KNVV' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'DLK' 10 'DK/LK' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'MATNR' 15 'Material' '' 'C300' ''
                                'MATNR' 'MARA' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'MAKTX' 25 'Description' '' 'C300' ''
                                'MAKTX' 'MAKT' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'TBTXT' 15 'Storage Type' '' '' ''
                                '' '' '' '' 'X' '' 'X' '' ''.
        PERFORM build_cat USING 'ERDAT' 15 'Date' '' '' '' '' '' '' ''
                                'X' '' 'X' '' ''.
        PERFORM f_fieldcatg USING 'LFIMG' '' '' '' '20' 'Absolute Invcd.qty'
                                  '' '' '' '' '' '' 'VRKME' '' '' '' ''.
        PERFORM f_fieldcatg USING 'UMREZ' '' '' '' '20' 'Numerator'
                                  '' '' '' '' '' '' 'VRKME' '' '' '' ''.
        PERFORM f_fieldcatg USING 'HOCAR' '' '' '' '20' 'Handling Out'
                                  '' '' '' '' 'CAR' '' '' '' '' '' ''.
        PERFORM f_fieldcatg USING 'ROCAR' '' '' '' '20' 'Handling Out(CAR)'
                                  '' '' '' '' 'CAR' '' '' '' '' '' ''.

      WHEN OTHERS.
        PERFORM build_cat USING 'VSTEL' 5 '' '' 'C710' ''
                                'VSTEL' 'LIKP' '' '' 'X' '' 'X' '' ''.
        IF det = ''.
          PERFORM build_cat USING 'TYPE' 10 'Grup Outlet' '' 'C500' ''
                                  '' '' '' '' 'X' '' '' '' ''.
        ENDIF.
        PERFORM build_cat USING 'KDGRP' 4 'Type Outlet' '' 'C300' ''
                                'KDGRP' 'KNVV' '' '' 'X' '' 'X' '' ''.
        IF det = ''.
          PERFORM build_cat USING 'KTEXT' 4 'Desc' '' 'C100' ''
                                  'KTEXT' 'T151T' '' '' '' '' 'X' '' ''.
          PERFORM build_cat USING 'TOTAL' 6 'Total' '' '' ''
                                  '' '' 'X' '' '' '' '' '' 15.
        ELSE.
          PERFORM build_cat USING 'KVGR3' 4 'Sub Cust. Group' '' 'C500' ''
                                  'KVGR3' 'KNVV' '' '' 'X' '' 'X' '' ''.
          PERFORM build_cat USING 'VBELN' 10 'Delivery' '' 'C100' ''
                                  'VBELN' 'LIKP' '' '' 'X' '' 'X' '' ''.
          PERFORM build_cat USING 'KUNNR' 8 'Ship-to' '' 'C600' ''
                                  'KUNNR' 'LIKP' '' '' 'X' '' 'X' '' ''.
          PERFORM build_cat USING 'NAME1' 22 'Name of Ship-to party' '' 'C600' ''
                                  'KUNNR' 'NAME1' '' '' 'X' '' 'X' '' ''.
          PERFORM build_cat USING 'ORT01' 15 'Cust. City' 'CHAR' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CITY1' 15 'Branch City' 'CHAR' '' ''
                                  '' '' '' '' '' '' '' '' ''.
*          PERFORM build_cat USING 'ERDAT_SO' 10 'SO Date' '' '' ''
*                                  '' '' '' '' '' '' '' '' ''.
*          PERFORM build_cat USING 'ERZET_SO' 8 'SO Time' '' '' ''
*                                  '' '' '' '' '' '' '' '' ''.

          PERFORM build_cat USING 'ERDAT' 10 'DO Date' '' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'ERZET' 8 'DO Time' '' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'KODAT' 10 'Pick.Date' '' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'KOUHR' 8 'Pick.Time' '' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'WADAT_IST' 10 'Act GI Date' '' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'GI_TIME' 8 'GI Time' 'TIMS' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'ERDAT_SPGD' 10 'Ship.Date' '' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'ERZET_SPGD' 10 'Ship.Time' '' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CRDAT' 10 'CR Date' 'DATS' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CRTIM' 8 'CR Time' 'TIMS' '' ''
                                  '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'PK_CREATE_DT' 10 'Pick.Vs DO date' 'DEC' ''
                                  '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'PK_CREATE_TM' 8 'Pick.Vs DO Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'GI_VS_PK_DT' 10 'GI Vs Pick.Date' 'DEC' ''
                                  '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'GI_VS_PK_TM' 8 'GI Vs Pick.Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CR_VS_GI_DT' 10 'CR Vs GI Date' 'DEC' ''
                            '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'CR_VS_GI_TM' 8 'CR Vs GI Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'SPGD_VS_GI_DT' 10 'Ship. Vs GI Date' 'DEC' ''
                                  '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'SPGD_VS_GI_TM' 8 'Ship. Vs GI Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CR_VS_SPGD_DT' 10 'CR Vs Ship. Date' 'DEC' ''
                                  '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'CR_VS_SPGD_TM' 8 'CR Vs Ship. Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'DO_VS_SPGD_DT' 10 'Ship. Vs DO Date' 'DEC' ''
                                  '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'DO_VS_SPGD_TM' 8 'Ship. Vs DO Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CR_CREATE_DT' 10 'CR Vs DO Date' 'DEC' ''
                                  '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'CR_CREATE_TM' 8 'CR Vs DO Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'GI_CREATE_DT' 10 'GI Vs DO Date' 'DEC' ''
                                  '' '' '' '' '' '' '' '' 'R' ''.
          PERFORM build_cat USING 'GI_CREATE_TM' 8 'GI Vs DO Time' 'TIMS' ''
                                  '' '' '' '' '' '' '' '' '' ''.
          PERFORM build_cat USING 'LFART' 4 'DlvTy' '' '' ''
                                  'LFART' 'LIKP' '' '' '' '' 'X' '' ''.
        ENDIF.

        PERFORM build_cat USING 'DLK' 5 'DK/LK' 'CHAR' 'C600' ''
                                '' '' '' '' 'X' '' '' '' ''.
        IF dpl = ''.
          PERFORM build_cat USING 'PKDO' 5 'Picking/DO' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING 'GIPK' 5 'GI/Picking' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING 'SPGDGI' 5 'Ship./GI' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CRSPGD' 5 'CR/Ship.' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING 'DOSPGD' 5 'Ship./DO' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING 'GIDO' 5 'GI/DO' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CRDO' 5 'CR/DO' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING 'CNT_DN' 6 'Total DN' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' '26'.
        ELSE.
          PERFORM build_cat USING '3JAM' 5 '< 3 JAM' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING '6JAM' 5 '< 6 JAM' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING '12JAM' 5 '< 12 JAM' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING '24JAM' 5 '< 24 JAM' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING '48JAM' 5 '< 48 JAM' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING '72JAM' 5 '< 72 JAM' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
          PERFORM build_cat USING '73JAM' 5 '> 72 JAM' 'DEC' '' ''
                                  '' '' 'X' '' '' '' '' '' ''.
        ENDIF.
    ENDCASE.
  ENDIF.

*---------------------------------*
* Jika mau build catalog standart
*---------------------------------*
*  If DET = 'X'.
*    PERFORM BUILDCAT_STRUC Using 'WA_RESULT'.
*  Elseif INC = 'X'.
*    PERFORM BUILDCAT_STRUC Using 'WA_OUTPL'.
*  Elseif DPL = 'X'.
*    PERFORM BUILDCAT_STRUC Using 'WA_OUTPL2'.
*  Endif.

  PERFORM eventtab_build USING gt_events[].
  PERFORM fill_sort.
  PERFORM sp_group_build USING er_sp_group[].

* Untuk protect maintain variant berdasarkan otorisasi di PID
* 'SD_VARIANT_MAINTAIN'
  PERFORM reuse_berechtigung_setzen(sapmv75a)
          CHANGING e_save.
* Cuma boleh maintain local variant
  IF e_save = ''.
    e_save = 'U'.
  ENDIF.

  er_variant = e_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = e_save
    CHANGING
      cs_variant = er_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = er_variant-variant.
  ENDIF.
  PERFORM comment_build USING gt_list_top_of_page[].

ENDFORM.                    " ALV_PREP

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       AT USER COMMAND                                               *
*---------------------------------------------------------------------*
*       --> R_UCOMM                                                   *
*       --> RS_SELFIELD                                               *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.
  DATA: feld(10) TYPE c, d_lgort LIKE mseg-lgort.
  DATA: BEGIN OF lt_rsparams OCCURS 0,
          selname(8),
          kind(1),
          sign(1),
          option(2),
          low(45),
          high(45),
        END OF lt_rsparams.

  rs_selfield-refresh = 'X'.
  va_ucomm  = r_ucomm.
  CASE r_ucomm.
    WHEN  'FEHL' OR '&IC1'.
      IF rs_selfield-value NE 0.
        LOOP AT i_outpl3 INTO wa_outpl3.
          lt_rsparams-selname = 'SHIP_PNT'.
          lt_rsparams-kind    = 'P'.
          lt_rsparams-sign    = 'I'.
          lt_rsparams-option  = 'EQ'.
          lt_rsparams-low     = wa_outpl3-vstel.
          COLLECT lt_rsparams.
        ENDLOOP.
        lt_rsparams-selname = 'P_BUFF'.
        lt_rsparams-kind    = 'P'.
        lt_rsparams-sign    = 'I'.
        lt_rsparams-option  = 'EQ'.
        lt_rsparams-low     = space.
        APPEND lt_rsparams.

        lt_rsparams-selname = 'P_SPMON'.
        lt_rsparams-kind    = 'P'.
        lt_rsparams-sign    = 'I'.
        lt_rsparams-option  = 'EQ'.
        lt_rsparams-low     = crt_date-low(6).
        APPEND lt_rsparams.

        lt_rsparams-selname = 'DTL'.
        lt_rsparams-kind    = 'P'.
        lt_rsparams-sign    = 'I'.
        lt_rsparams-option  = 'EQ'.
        lt_rsparams-low     = 'X'.
        APPEND lt_rsparams.

        READ TABLE i_outpl3 INTO wa_outpl3 INDEX rs_selfield-tabindex.
        IF sy-subrc EQ 0.
          lt_rsparams-selname = 'FIELDNM'.
          lt_rsparams-kind    = 'P'.
          lt_rsparams-sign    = 'I'.
          lt_rsparams-option  = 'EQ'.
          lt_rsparams-low     = rs_selfield-fieldname.
          APPEND lt_rsparams.
          lt_rsparams-selname = 'VSTEL'.
          lt_rsparams-kind    = 'P'.
          lt_rsparams-sign    = 'I'.
          lt_rsparams-option  = 'EQ'.
          lt_rsparams-low     = wa_outpl3-vstel.
          APPEND lt_rsparams.
          lt_rsparams-selname = 'TYPE'.
          lt_rsparams-kind    = 'P'.
          lt_rsparams-sign    = 'I'.
          lt_rsparams-option  = 'EQ'.
          lt_rsparams-low     = wa_outpl3-type.
          APPEND lt_rsparams.
          lt_rsparams-selname = 'KDGRP'.
          lt_rsparams-kind    = 'P'.
          lt_rsparams-sign    = 'I'.
          lt_rsparams-option  = 'EQ'.
          lt_rsparams-low     = wa_outpl3-kdgrp.
          APPEND lt_rsparams.
          lt_rsparams-selname = 'KTEXT'.
          lt_rsparams-kind    = 'P'.
          lt_rsparams-sign    = 'I'.
          lt_rsparams-option  = 'EQ'.
          lt_rsparams-low     = wa_outpl3-ktext.
          APPEND lt_rsparams.
          lt_rsparams-selname = 'DLK'.
          lt_rsparams-kind    = 'P'.
          lt_rsparams-sign    = 'I'.
          lt_rsparams-option  = 'EQ'.
          lt_rsparams-low     = wa_outpl3-dlk.
          APPEND lt_rsparams.
        ENDIF.

        SUBMIT zmr_incentif_wnd WITH SELECTION-TABLE lt_rsparams AND RETURN.
      ENDIF.
*  VIA SELECTION-SCREEN AND RETURN
*      case RS_SELFIELD-SEL_TAB_FIELD.
*        when '1-VBELN'.
*          set parameter id  'VL' field RS_SELFIELD-VALUE.
*          call transaction 'VL03N' and skip first screen.
*      Endcase.
*      RS_SELFIELD-COL_STABLE = 'X'.
*      RS_SELFIELD-ROW_STABLE = 'X'.
  ENDCASE.

ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  FILL_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sort.
  DATA: fieldsort TYPE slis_sortinfo_alv.

  IF dtl EQ 'X'.
  ELSE.
    CASE 'X'.
*      WHEN day.
*        fieldsort-spos = '1'.
*        fieldsort-fieldname = 'VSTEL'.
*        fieldsort-up   = 'X'.
*        APPEND fieldsort TO ta_sort.
*
*        fieldsort-spos = '2'.
*        fieldsort-fieldname = 'DLK'.
*        fieldsort-up   = 'X'.
*        APPEND fieldsort TO ta_sort.
*
*        fieldsort-spos = '3'.
*        fieldsort-fieldname = 'TYPE'.
*        fieldsort-up   = 'X'.
*        fieldsort-subtot = 'X'.
*        APPEND fieldsort TO ta_sort.

      WHEN sum.
        fieldsort-spos      = '1'.
        fieldsort-fieldname = 'KETERANGAN'.
        fieldsort-up        = 'X'.
        fieldsort-group     = 'UL'.
        APPEND fieldsort TO ta_sort.

      WHEN rho.
*        fieldsort-spos = '1'.
*        fieldsort-fieldname = 'VKBUR'.
*        fieldsort-up   = 'X'.
*        APPEND fieldsort TO ta_sort.
*        fieldsort-spos = '2'.
*        fieldsort-fieldname = 'VBELN'.
*        fieldsort-up   = 'X'.
*        APPEND fieldsort TO ta_sort.

      WHEN OTHERS.
***** Sort Data
        fieldsort-spos = '1'.
        fieldsort-fieldname = 'VSTEL'.
        fieldsort-up   = 'X'.
        APPEND fieldsort TO ta_sort.

        IF det = ''.
          fieldsort-spos = '2'.
          fieldsort-fieldname = 'TYPE'.
          fieldsort-up   = 'X'.
          APPEND fieldsort TO ta_sort.
        ENDIF.

        fieldsort-spos = '3'.
        fieldsort-fieldname = 'KDGRP'.
        fieldsort-up   = 'X'.
        APPEND fieldsort TO ta_sort.

        fieldsort-spos = '4'.
        fieldsort-fieldname = 'DLK'.
        fieldsort-up   = 'X'.
        IF det = 'X'.
          fieldsort-subtot = 'X'.
*  FIELDSORT-EXPA   = 'X'.
        ENDIF.
        APPEND fieldsort TO ta_sort.
    ENDCASE.
  ENDIF.
ENDFORM.                    " FILL_SORT
*&---------------------------------------------------------------------*
*&      Form  CALC_SPMON
*&---------------------------------------------------------------------*
FORM calc_spmon.
  DATA : spmon_low  LIKE s031-spmon,
         spmon_high LIKE s031-spmon.

* Jika range date tidak kosong
  IF NOT crt_date IS INITIAL.
    SORT crt_date BY sign option low.
*-------------------------*
* Proses untuk data range
*-------------------------*
    LOOP AT crt_date WHERE ( sign = 'I' AND option = 'BT'
                       AND high <> '00000000' ) OR
                           ( sign = 'E' AND option = 'NB'
                       AND high <> '00000000' ).
      i_spmon-spmon = crt_date-low(6).
      APPEND i_spmon.
      i_spmon-spmon = crt_date-high(6).
      APPEND i_spmon.
    ENDLOOP.

    SORT i_spmon.
    DELETE ADJACENT DUPLICATES FROM i_spmon COMPARING spmon.
* Baca minimum range
    READ TABLE i_spmon INDEX 1.
    spmon_low = i_spmon.
    IF spmon_low = '000000'.
      spmon_low = '200301'.
    ENDIF.

* Baca maximum range
    SORT i_spmon DESCENDING.
    READ TABLE i_spmon INDEX 1.
    spmon_high = i_spmon.
    REFRESH i_spmon.

    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.

*--------------------------*
* Proses untuk data single
*--------------------------*
    LOOP AT crt_date WHERE ( sign = 'I' AND option = 'EQ'
                       AND high = '00000000' ) OR
                           ( sign = 'E' AND option = 'NE'
                       AND high = '00000000' ).
      i_spmon-spmon = crt_date-low(6).
      APPEND i_spmon.
    ENDLOOP.

*--------------------------------*
* Proses untuk data greater than
*--------------------------------*
    spmon_low  = '999912'.
    spmon_high = sy-datum(6).
    LOOP AT crt_date WHERE sign = 'I' AND
                         ( option = 'GT' OR option = 'GE' ).
      IF spmon_low > crt_date-low(6).
        spmon_low = crt_date-low(6).
      ENDIF.
    ENDLOOP.

    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.

*--------------------------------*
* Proses untuk data less than
*--------------------------------*
    spmon_low  = '200301'.
    spmon_high = '000000'.
    LOOP AT crt_date WHERE sign = 'I' AND
                         ( option = 'LT' OR option = 'LE' ).
      IF spmon_high < crt_date-low(6).
        spmon_high = crt_date-low(6).
      ENDIF.
    ENDLOOP.

    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.

    SORT i_spmon.
    DELETE ADJACENT DUPLICATES FROM i_spmon COMPARING spmon.
  ELSE.

*--------------------------------*
* Proses untuk data blank
*--------------------------------*
    spmon_low  = '200301'.
    spmon_high = sy-datum(6).
    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.
  ENDIF.

ENDFORM.                    " CALC_SPMON

*&---------------------------------------------------------------------*
*&      Form  f_get_holiday
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_DATETO    text
*      -->FU_DATEFR    text
*      <--FC_DAY       text
*----------------------------------------------------------------------*
FORM f_get_holiday  USING    fu_dateto
                             fu_datefr
                    CHANGING fc_day.

  DATA: BEGIN OF lt_holidays OCCURS 0.
          INCLUDE STRUCTURE iscal_day.
        DATA: END OF lt_holidays.
  DATA: ld_day(004) TYPE p  DECIMALS 00.

  CALL FUNCTION 'HOLIDAY_GET'
    EXPORTING
      holiday_calendar           = 'T1'
      factory_calendar           = 'T1'
      date_from                  = fu_datefr
      date_to                    = fu_dateto
    TABLES
      holidays                   = lt_holidays
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      date_has_invalid_format    = 3
      date_inconsistency         = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    DESCRIBE TABLE lt_holidays LINES ld_day.
    fc_day = fc_day - ld_day.
  ENDIF.

ENDFORM.                    " f_get_holiday

*&---------------------------------------------------------------------*
*&      Form  f_detail_process
*&---------------------------------------------------------------------*
FORM f_detail_process USING fu_vstel fu_type fu_kdgrp
                            fu_ktext fu_dlk fu_bzirk fu_fieldnm fu_kunnr.

  DATA : lv_day   TYPE int3,
         lv_day01 TYPE int3,
         lv_day02 TYPE int3,
         lv_day03 TYPE int3,
         lv_day04 TYPE int3.

  DATA : wa_extpay LIKE wa_result,
         lv_kunnr  TYPE kna1-kunnr.

  CLEAR: i_outpl4.
  REFRESH: i_outpl4.

  IF fu_fieldnm(9) EQ 'WA_OUTPL3'.
    READ TABLE i_outpl3 INTO wa_outpl3 WITH KEY vstel = fu_vstel
                                                type  = fu_type
                                                kdgrp = fu_kdgrp
                                                ktext = fu_ktext
                                                dlk   = fu_dlk.
    LOOP AT i_result INTO wa_result WHERE vstel EQ fu_vstel AND
                                          type  EQ fu_type AND
                                          kdgrp EQ fu_kdgrp AND
                                          ktext EQ fu_ktext AND
                                          dlk   EQ fu_dlk.
      CASE fu_fieldnm+10(1).
        WHEN '0'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              IF wa_result-do_vs_spgd_dt EQ 0.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              IF wa_result-cr_vs_spgd_dt EQ 0.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              IF wa_result-cr_create_dt EQ 0.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.

        WHEN '1'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              IF wa_result-do_vs_spgd_dt EQ 1.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              IF wa_result-cr_vs_spgd_dt EQ 1.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              IF wa_result-cr_create_dt EQ 1.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '2'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              IF wa_result-do_vs_spgd_dt EQ 2.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              IF wa_result-cr_vs_spgd_dt EQ 2.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              IF wa_result-cr_create_dt EQ 2.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '3'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              IF wa_result-do_vs_spgd_dt EQ 3.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              IF wa_result-cr_vs_spgd_dt EQ 3.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              IF wa_result-cr_create_dt EQ 3.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '4'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              IF wa_result-do_vs_spgd_dt GT 3.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              IF wa_result-cr_vs_spgd_dt GT 3.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              IF wa_result-cr_create_dt GT 3.
                IF cr_date = 'X'.
                  IF wa_result-crdat IS NOT INITIAL.
                    APPEND wa_result TO i_outpl4.
                  ENDIF.
                ELSE.
                  APPEND wa_result TO i_outpl4.
                ENDIF.
              ENDIF.
          ENDCASE.
        WHEN OTHERS.
          IF cr_date = 'X'.
            IF wa_result-crdat IS NOT INITIAL.
              APPEND wa_result TO i_outpl4.
            ENDIF.
          ELSE.
            APPEND wa_result TO i_outpl4.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ELSEIF fu_fieldnm(9) EQ 'WA_OUTPL6'.
    READ TABLE t_a511 WITH KEY zday1 = fu_bzirk.
    IF sy-subrc EQ 0.
      CASE 'X'.
        WHEN dis OR day.
          lv_day  = t_a511-zday5 + t_a511-zday6.
        WHEN wh1 OR wh2.
          lv_day  = t_a511-zday3 + t_a511-zday4 +
                    t_a511-zday5.
        WHEN dp1 OR dp2.
          lv_day  = t_a511-zday6.
        WHEN OTHERS.
          lv_day  = t_a511-zday3 + t_a511-zday4 +
                    t_a511-zday5 + t_a511-zday6.
      ENDCASE.
    ENDIF.

    READ TABLE i_outpl6 INTO wa_outpl6 WITH KEY vstel = fu_vstel
                                                type  = fu_type
                                                kdgrp = fu_kdgrp
                                                ktext = fu_ktext
                                                dlk   = fu_dlk
                                                bzirk = fu_bzirk.

    LOOP AT i_slsdist INTO wa_result WHERE vstel EQ fu_vstel AND
                                           type  EQ fu_type AND
                                           kdgrp EQ fu_kdgrp AND
                                           ktext EQ fu_ktext AND
                                           dlk   EQ fu_dlk   AND
                                           bzirk EQ fu_bzirk.
      CASE fu_fieldnm+10(2).
        WHEN '00'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              IF wa_result-do_vs_spgd_dt LT lv_day.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              IF wa_result-cr_vs_spgd_dt LT lv_day.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              IF wa_result-cr_create_dt LT lv_day.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '06'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              IF wa_result-do_vs_spgd_dt EQ lv_day.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              IF wa_result-cr_vs_spgd_dt EQ lv_day.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              IF wa_result-cr_create_dt EQ lv_day.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '07'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              lv_day01  = lv_day + 1.
              IF wa_result-do_vs_spgd_dt EQ lv_day01.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              lv_day01  = lv_day + 1.
              IF wa_result-cr_vs_spgd_dt EQ lv_day01.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              lv_day01  = lv_day + 1.
              IF wa_result-cr_create_dt EQ lv_day01.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '08'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              lv_day02  = lv_day + 2.
              IF wa_result-do_vs_spgd_dt EQ lv_day02.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              lv_day02  = lv_day + 2.
              IF wa_result-cr_vs_spgd_dt EQ lv_day02.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              lv_day02  = lv_day + 2.
              IF wa_result-cr_create_dt EQ lv_day02.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '09'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              lv_day03  = lv_day + 3.
              IF wa_result-do_vs_spgd_dt EQ lv_day03.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              lv_day03  = lv_day + 3.
              IF wa_result-cr_vs_spgd_dt EQ lv_day03.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              lv_day03  = lv_day + 3.
              IF wa_result-cr_create_dt EQ lv_day03.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '10'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              lv_day04  = lv_day + 4.
              IF wa_result-do_vs_spgd_dt EQ lv_day04.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              lv_day04  = lv_day + 4.
              IF wa_result-cr_vs_spgd_dt GE lv_day04.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              lv_day04  = lv_day + 4.
              IF wa_result-cr_create_dt GE lv_day04.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN '11'.
          CASE 'X'.
            WHEN wh1 OR wh2.
              lv_day04  = lv_day + 4.
              IF wa_result-do_vs_spgd_dt GT lv_day04.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN dp1 OR dp2.
              lv_day04  = lv_day + 4.
              IF wa_result-cr_vs_spgd_dt GT lv_day04.
                APPEND wa_result TO i_outpl4.
              ENDIF.
            WHEN OTHERS.
              lv_day04  = lv_day + 4.
              IF wa_result-cr_create_dt GT lv_day04.
                APPEND wa_result TO i_outpl4.
              ENDIF.
          ENDCASE.
        WHEN OTHERS.
          APPEND wa_result TO i_outpl4.
      ENDCASE.
    ENDLOOP.
  ELSEIF fu_fieldnm(9) EQ 'LS_EXTPAY'.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fu_kunnr
      IMPORTING
        output = lv_kunnr.

    CASE fu_fieldnm.
      WHEN 'LS_EXTPAY-TOTAL'.
        LOOP AT i_extpay INTO wa_extpay WHERE kunnr = lv_kunnr.
          APPEND wa_extpay TO i_outpl4.
        ENDLOOP.
      WHEN 'LS_EXTPAY-NHIT'.
        LOOP AT i_extpay INTO wa_extpay WHERE kunnr = lv_kunnr
                                          AND nhit NE 0.
          APPEND wa_extpay TO i_outpl4.
        ENDLOOP.
      WHEN 'LS_EXTPAY-HIT'.
        LOOP AT i_extpay INTO wa_extpay WHERE kunnr = lv_kunnr
                                          AND hit NE 0.
          APPEND wa_extpay TO i_outpl4.
        ENDLOOP.
    ENDCASE.
  ENDIF.
ENDFORM.                    " f_detail_process

*&---------------------------------------------------------------------*
*&      Form  f_write_day
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_day .
  DATA: ld_zebra      TYPE i,
        ld_flag       TYPE i,
        ld_dlk        LIKE wa_outpl3-dlk,
        ld_subttl(55).

  DATA: ld_avr      TYPE p DECIMALS 2,
        ld_avrcp    TYPE p DECIMALS 2,
        ld_avrtrm   TYPE p DECIMALS 2,
        ld_avrmvr   TYPE p DECIMALS 2,
        ld_avrdktrm TYPE p DECIMALS 2,
        ld_avrdkcp  TYPE p DECIMALS 2,
        ld_avrdkmvr TYPE p DECIMALS 2,
        ld_avrlkcp  TYPE p DECIMALS 2,
        ld_avrlktrm TYPE p DECIMALS 2,
        ld_avrlkmvr TYPE p DECIMALS 2,
        ld_cp       TYPE i,
        ld_trm      TYPE i,
        ld_mvr      TYPE i,
        ld_avrttl   TYPE i.

  DATA: ld_day   LIKE a511-zday4,
        ld_kdgrp LIKE a511-kdgrp,
        ld_bzirk LIKE a511-zday1.

  va_avr  = 2.
  WRITE: sy-uline(gv_uline).
  SORT i_outpl3 BY vstel type dlk.
  LOOP AT i_outpl3 INTO wa_outpl3.
    ADD wa_outpl3-0hari TO wa_outpl4-0hari.
    ADD wa_outpl3-1hari TO wa_outpl4-1hari.
    ADD wa_outpl3-2hari TO wa_outpl4-2hari.
    ADD wa_outpl3-3hari TO wa_outpl4-3hari.
    ADD wa_outpl3-4hari TO wa_outpl4-4hari.
    ADD wa_outpl3-total TO wa_outpl4-total.

    ld_dlk   = wa_outpl3-dlk.
    ld_kdgrp = wa_outpl3-kdgrp.
    ld_bzirk = wa_outpl3-bzirk.

    IF ld_zebra IS INITIAL.
      ld_zebra = 1.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
    ELSE.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      CLEAR: ld_zebra.
    ENDIF.

    PERFORM f_target_calculate USING    pa_vkorg wa_outpl3 'X'
                               CHANGING wa_outpl3-target.

    WRITE: / sy-vline NO-GAP, wa_outpl3-vstel NO-GAP,
             sy-vline, wa_outpl3-type,
             sy-vline, (3) wa_outpl3-dlk,
             sy-vline, (8) wa_outpl3-kdgrp,
             sy-vline NO-GAP, wa_outpl3-ktext NO-GAP.
    WRITE:   sy-vline, (10) wa_outpl3-target,
             sy-vline.
    WRITE:   (10) wa_outpl3-0hari HOTSPOT,
             sy-vline, (10) wa_outpl3-1hari HOTSPOT,
             sy-vline, (10) wa_outpl3-2hari HOTSPOT,
             sy-vline, (10) wa_outpl3-3hari HOTSPOT,
             sy-vline, (10) wa_outpl3-4hari HOTSPOT.
*    IF dis IS NOT INITIAL AND
*      cr IS NOT INITIAL.
*      WRITE:   sy-vline, (10) wa_outpl3-5hari HOTSPOT.
*    ENDIF.
    WRITE:   sy-vline, (10) wa_outpl3-total HOTSPOT,
             sy-vline, (10) wa_outpl3-std,
             sy-vline.

    CASE ld_dlk.
      WHEN 'DK'.
        CASE wa_outpl3-type.
          WHEN 'Corp. Pharma'.
            ADD wa_outpl3-std TO ld_avrdkcp.
            ADD 1 TO ld_cp.
          WHEN 'GT'.
            ADD wa_outpl3-std TO ld_avrdktrm.
            ADD 1 TO ld_trm.
          WHEN 'MT'.
            ADD wa_outpl3-std TO ld_avrdkmvr.
            ADD 1 TO ld_mvr.
        ENDCASE.

      WHEN 'LK'.
        CASE wa_outpl3-type.
          WHEN 'Corp. Pharma'.
            ADD wa_outpl3-std TO ld_avrlkcp.
            ADD 1 TO ld_cp.
          WHEN 'GT'.
            ADD wa_outpl3-std TO ld_avrlktrm.
            ADD 1 TO ld_trm.
          WHEN 'MT'.
            ADD wa_outpl3-std TO ld_avrlkmvr.
            ADD 1 TO ld_mvr.
        ENDCASE.
    ENDCASE.

    AT END OF dlk.
      READ TABLE t_a511 WITH KEY vkorg = pa_vkorg
                                 zday1 = wa_outpl3-bzirk.
      IF sy-subrc EQ 0.
        ld_day  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5 + t_a511y-zday6.
      ELSE.
        READ TABLE t_a511 WITH KEY vkorg = pa_vkorg
                                   vkbur = wa_outpl3-vstel
                                   katr1 = ld_dlk
                                   kdgrp = ld_kdgrp.
        IF sy-subrc EQ 0.
          ld_day  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5 + t_a511-zday6.
        ELSE.
          READ TABLE t_a511x WITH KEY vkorg = pa_vkorg
                                      vkbur = space
                                      katr1 = ld_dlk
                                      kdgrp = ld_kdgrp.
          IF sy-subrc EQ 0.
            ld_day  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5 + t_a511x-zday6.
          ELSE.
            CLEAR: ld_day.
          ENDIF.
        ENDIF.
      ENDIF.

      WRITE: sy-uline(gv_uline).
      FORMAT COLOR 3.
      FORMAT INTENSIFIED OFF.
      CONCATENATE 'Sub total :' wa_outpl3-type '-' wa_outpl3-dlk INTO ld_subttl SEPARATED BY space.
      WRITE: / sy-vline, (68) ld_subttl,
               sy-vline, (10) wa_outpl4-0hari,
               sy-vline, (10) wa_outpl4-1hari,
               sy-vline, (10) wa_outpl4-2hari,
               sy-vline, (10) wa_outpl4-3hari,
               sy-vline, (10) wa_outpl4-4hari.
*      IF dis IS NOT INITIAL AND
*        cr IS NOT INITIAL.
*        WRITE:   sy-vline, (10) wa_outpl4-5hari.
*      ENDIF.
      WRITE:   sy-vline, (10) wa_outpl4-total,
               sy-vline, (10) space,
               sy-vline.
      WRITE: sy-uline(gv_uline).
      CLEAR: wa_outpl4.
    ENDAT.
  ENDLOOP.

  IF dis EQ 'X' OR wh2 EQ 'X' OR dp2 EQ 'X'.
    SORT i_outpl6 BY bzirk type.
    LOOP AT i_outpl6 INTO wa_outpl6.
      ADD wa_outpl6-00hari TO wa_outpl5-00hari.
      ADD wa_outpl6-06hari TO wa_outpl5-06hari.
      ADD wa_outpl6-07hari TO wa_outpl5-07hari.
      ADD wa_outpl6-08hari TO wa_outpl5-08hari.
      ADD wa_outpl6-09hari TO wa_outpl5-09hari.
      ADD wa_outpl6-10hari TO wa_outpl5-10hari.
*      ADD wa_outpl6-11hari TO wa_outpl5-11hari.
      ADD wa_outpl6-total TO wa_outpl5-total.

      ADD wa_outpl6-00hari TO wa_outpl7-00hari.
      ADD wa_outpl6-06hari TO wa_outpl7-06hari.
      ADD wa_outpl6-07hari TO wa_outpl7-07hari.
      ADD wa_outpl6-08hari TO wa_outpl7-08hari.
      ADD wa_outpl6-09hari TO wa_outpl7-09hari.
      ADD wa_outpl6-10hari TO wa_outpl7-10hari.
*      ADD wa_outpl6-11hari TO wa_outpl7-11hari.
      ADD wa_outpl6-total TO wa_outpl7-total.

      ON CHANGE OF wa_outpl6-bzirk.
        PERFORM f_header_district USING wa_outpl6-bzirk
                                  CHANGING ld_flag.
        CLEAR: ld_zebra.
      ENDON.

      IF ld_zebra IS INITIAL.
        ld_zebra = 1.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
        CLEAR: ld_zebra.
      ENDIF.

      READ TABLE t_a511y WITH KEY vkorg = pa_vkorg
                                  zday1 = wa_outpl6-bzirk.
      IF sy-subrc EQ 0.
        CASE 'X'.
          WHEN wh1 OR wh2.
            wa_outpl6-target  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5.
          WHEN dp1 OR dp2.
            wa_outpl6-target  = t_a511y-zday6.
          WHEN dis OR day.
            wa_outpl6-target  = t_a511y-zday5 + t_a511y-zday6.
          WHEN OTHERS.
            wa_outpl6-target  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5 + t_a511y-zday6.
        ENDCASE.
      ENDIF.

      READ TABLE t_avr WITH KEY type = wa_outpl6-type
                                dlk  = wa_outpl6-dlk.
      IF sy-subrc EQ 0.
        PERFORM f_hitung_average_khusus USING wa_outpl6 va_avr sy-tabix.
      ENDIF.

      WRITE: / sy-vline NO-GAP, wa_outpl6-vstel NO-GAP,
               sy-vline, wa_outpl6-type,
               sy-vline, (3) wa_outpl6-dlk,
               sy-vline, (8) wa_outpl6-kdgrp,
               sy-vline NO-GAP, wa_outpl6-ktext NO-GAP.
      WRITE:   sy-vline, (10) wa_outpl6-target,
               sy-vline.
      WRITE:   (10) wa_outpl6-00hari HOTSPOT,
               sy-vline, (10) wa_outpl6-06hari HOTSPOT,
               sy-vline, (10) wa_outpl6-07hari HOTSPOT,
               sy-vline, (10) wa_outpl6-08hari HOTSPOT,
               sy-vline, (10) wa_outpl6-09hari HOTSPOT,
               sy-vline, (10) wa_outpl6-10hari HOTSPOT.
*      IF cr IS NOT INITIAL.
*        WRITE: sy-vline, (10) wa_outpl6-11hari HOTSPOT.
*      ENDIF.
      WRITE:   sy-vline, (10) wa_outpl6-total HOTSPOT,
               sy-vline, (10) wa_outpl6-std,
               sy-vline.
      HIDE wa_outpl6-bzirk.

      CASE wa_outpl6-type.
        WHEN 'Corp. Pharma'.
          ADD wa_outpl6-std TO ld_avrlkcp.
          ADD 1 TO ld_cp.
        WHEN 'GT'.
          ADD wa_outpl6-std TO ld_avrlktrm.
          ADD 1 TO ld_trm.
        WHEN 'MT'.
          ADD wa_outpl6-std TO ld_avrlkmvr.
          ADD 1 TO ld_mvr.
      ENDCASE.

      AT END OF type.
        WRITE: sy-uline(189).
        FORMAT COLOR 3.
        FORMAT INTENSIFIED OFF.
        CONCATENATE 'Sub total :' wa_outpl6-bzirk '-' wa_outpl6-type INTO ld_subttl SEPARATED BY space.
        WRITE: / sy-vline, (68) ld_subttl,
                 sy-vline, (10) wa_outpl5-00hari,
                 sy-vline, (10) wa_outpl5-06hari,
                 sy-vline, (10) wa_outpl5-07hari,
                 sy-vline, (10) wa_outpl5-08hari,
                 sy-vline, (10) wa_outpl5-09hari,
                 sy-vline, (10) wa_outpl5-10hari,
*                 sy-vline, (10) wa_outpl5-11hari,
                 sy-vline, (10) wa_outpl5-total,
                 sy-vline, (10) space,
                 sy-vline.
        WRITE: sy-uline(189).
        CLEAR: wa_outpl5.
      ENDAT.

      AT END OF bzirk.
        FORMAT COLOR 3.
        FORMAT INTENSIFIED OFF.
        CONCATENATE 'Total :' wa_outpl6-bzirk INTO ld_subttl SEPARATED BY space.
        WRITE: / sy-vline, (68) ld_subttl,
                 sy-vline, (10) wa_outpl7-00hari,
                 sy-vline, (10) wa_outpl7-06hari,
                 sy-vline, (10) wa_outpl7-07hari,
                 sy-vline, (10) wa_outpl7-08hari,
                 sy-vline, (10) wa_outpl7-09hari,
                 sy-vline, (10) wa_outpl7-10hari,
*                 sy-vline, (10) wa_outpl7-11hari,
                 sy-vline, (10) wa_outpl7-total,
                 sy-vline, (10) space,
                 sy-vline.
        WRITE: sy-uline(189).
        CLEAR: wa_outpl7.
      ENDAT.
    ENDLOOP.
  ELSEIF dsl IS NOT INITIAL.
    PERFORM f_write_exp_expendition.
  ENDIF.

  SKIP 1.
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED ON.

  IF pa_chwh1 IS NOT INITIAL.
    PERFORM f_footer_rekap_wp.
  ELSE.
    PERFORM f_footer_new.
  ENDIF.
*  PERFORM f_footer_old.
ENDFORM.                    " f_write_day

*&---------------------------------------------------------------------*
*&      Form  f_choose
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_choose.
  DATA : ffield(20), fvalue(255).
  DATA : lv_day   TYPE int3,
         lv_vstel TYPE lips-vkbur.

  CLEAR gv_flag.

  GET CURSOR FIELD ffield VALUE fvalue.

  CASE 'X'.
    WHEN rho.
      IF xit_fieldcat[] IS INITIAL.
        PERFORM alv_prep.
      ENDIF.
      lv_vstel = fvalue.
      SELECT SINGLE *
        FROM tvst
        WHERE vstel = lv_vstel.
      IF sy-subrc = 0.
        PERFORM layout_init USING gs_layout judul 'X'.
        PERFORM showlist USING 'GT_DRHO' judul ''.
      ENDIF.

    WHEN OTHERS.
      IF ffield(9) EQ 'WA_OUTPL3'.
        READ CURRENT LINE FIELD VALUE: wa_outpl3-vstel wa_outpl3-type wa_outpl3-kdgrp
                                       wa_outpl3-ktext wa_outpl3-dlk.

        GET CURSOR FIELD ffield VALUE fvalue.
        PERFORM f_detail_process USING wa_outpl3-vstel wa_outpl3-type wa_outpl3-kdgrp
                                       wa_outpl3-ktext wa_outpl3-dlk '' ffield ''.
      ELSEIF ffield(9) EQ 'WA_OUTPL6'.
        READ CURRENT LINE FIELD VALUE: wa_outpl6-vstel wa_outpl6-type wa_outpl6-kdgrp
                                       wa_outpl6-ktext wa_outpl6-dlk wa_outpl6-bzirk.

        GET CURSOR FIELD ffield VALUE fvalue.
        PERFORM f_detail_process USING wa_outpl6-vstel wa_outpl6-type wa_outpl6-kdgrp
                                       wa_outpl6-ktext wa_outpl6-dlk wa_outpl6-bzirk ffield ''.
      ELSEIF ffield(9) EQ 'LS_EXTPAY'.
        gv_flag = 1.
        READ CURRENT LINE FIELD VALUE: ls_extpay-kunnr.

        PERFORM f_detail_process USING '' '' '' '' '' '' ffield ls_extpay-kunnr.
      ELSE.
        dtl = 'Y'.
      ENDIF.

      IF dsl IS NOT INITIAL AND ( ffield = 'WA_OUTPL3-STD' OR ffield = 'LS_EXTPAY-STD' ).
        fvalue = 0.
      ENDIF.

      IF dsl IS NOT INITIAL AND fvalue = 0.
        CLEAR dtl.
      ELSE.
        IF dtl  = 'Y'.
          CLEAR dtl.
        ELSE.
          dtl = 'X'.
        ENDIF.
      ENDIF.

      PERFORM alv_prep.

      IF dtl EQ 'X'.
        CLEAR: judul.
        CONCATENATE 'Delivery performance level (by Date)'
                    judul crt_date-low(4)
        INTO judul SEPARATED BY space.
        PERFORM layout_init USING gs_layout judul 'X'.
        PERFORM showlist USING 'I_OUTPL4' judul ''.
      ENDIF.
  ENDCASE.

  REFRESH: ta_sort, gt_events, gt_list_top_of_page, xit_fieldcat, er_sp_group.

  CLEAR: ta_sort, gs_layout, g_exit_caused_by_caller, gs_exit_caused_by_user, g_repid, gt_events,
         gt_list_top_of_page, g_top_of_page, xit_fieldcat, xis_print, e_save, er_sp_group, e_exit,
         e_user_command.
ENDFORM.                    " f_choose

*&---------------------------------------------------------------------*
*&      Form  F_GET_LEAD_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_lead_time .
  IF i_result[] IS NOT INITIAL.
    SELECT vbeln crdat crtim
      FROM zmm_cust_rec
      INTO CORRESPONDING FIELDS OF TABLE i_custrec
      FOR ALL ENTRIES IN i_result
      WHERE vbeln EQ i_result-vbeln.

    SELECT vbeln posnr bstdk
      FROM vbkd
      INTO CORRESPONDING FIELDS OF TABLE t_vbkd
      FOR ALL ENTRIES IN i_result
      WHERE vbeln EQ i_result-vbeln.
  ENDIF.
ENDFORM.                    " F_GET_LEAD_TIME

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_LEAD_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_lead_time CHANGING fc_0hari fc_1hari fc_2hari fc_3hari fc_4hari.

ENDFORM.                    " F_HITUNG_LEAD_TIME

*&---------------------------------------------------------------------*
*&      Form  F_DK_LK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_dk_lk  USING    fu_datab fu_datbi fu_erdat fu_kodat fu_vstel fu_vkbur fu_pk_create_dt
                       fu_gi_vs_pk_dt fu_spgd_vs_gi_dt fu_cr_vs_spgd_dt fu_do_vs_spgd_dt
                       fu_gi_create_dt fu_cr_vs_do_dt
              CHANGING fc_result_pkdo fc_result_gipk fc_result_spgdgi fc_result_crspgd
                       fc_result_dospgd fc_result_gido fc_result_crdo.

  RANGES: lr_datum FOR a511-datab.

  lr_datum-low    = fu_datab.
  lr_datum-high   = fu_datbi.
  lr_datum-sign   = 'I'.
  lr_datum-option = 'BT'.
  APPEND lr_datum.

  IF fu_datab IS INITIAL AND
    fu_datbi IS INITIAL.
    CLEAR: fc_result_pkdo, fc_result_gipk, fc_result_spgdgi, fc_result_crspgd, fc_result_dospgd,
           fc_result_gido, fc_result_crdo.
  ELSE.
    IF fu_erdat IN lr_datum.
      IF fu_kodat IN lr_datum.
        IF wa_result-pk_create_dt <= fu_pk_create_dt.
          fc_result_pkdo = '1'.
        ENDIF.
      ELSE.
        CLEAR: fc_result_pkdo.
      ENDIF.

      IF wa_result-gi_create_dt <= fu_gi_create_dt.
        fc_result_gido = '1'.
      ENDIF.

      IF wa_result-gi_vs_pk_dt <= fu_gi_vs_pk_dt AND
        wa_result-wadat_ist NE '00000000' AND
        wa_result-kodat NE '00000000'.
        fc_result_gipk = '1'.
      ENDIF.

      IF wa_result-spgd_vs_gi_dt <= fu_spgd_vs_gi_dt.
        fc_result_spgdgi = '1'.
      ENDIF.

      IF wa_result-cr_vs_spgd_dt <= fu_cr_vs_spgd_dt.
        fc_result_crspgd = '1'.
      ENDIF.

      IF wa_result-do_vs_spgd_dt <= fu_do_vs_spgd_dt.
        fc_result_dospgd = '1'.
      ENDIF.

      IF wa_result-cr_create_dt <= fu_cr_vs_do_dt.
        fc_result_crdo = '1'.
      ENDIF.
    ELSE.
      CLEAR: fc_result_pkdo, fc_result_gipk, fc_result_spgdgi, fc_result_crspgd,
             fc_result_dospgd, fc_result_gido, fc_result_crdo.
    ENDIF.
  ENDIF.

  IF fu_vstel IS NOT INITIAL.
    IF fu_vkbur IS NOT INITIAL.
      IF fu_vstel NE fu_vkbur.
        CLEAR: fc_result_pkdo, fc_result_gipk, fc_result_spgdgi, fc_result_crspgd,
               fc_result_gido, fc_result_crdo.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DK_LK

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_DISTRICT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_district USING fu_bzirk
                       CHANGING fc_flag.
  DATA: ld_bztxt     LIKE t171t-bztxt,
        l_day        TYPE int4,
        lv_day(10),
        lv_day01(10),
        lv_day02(10),
        lv_day03(10),
        lv_day04(10),
        lv_day05(10),
        lv_day06(10).
*        lv_day07(10).

  SELECT SINGLE bztxt
    FROM t171t
    INTO ld_bztxt
    WHERE spras EQ sy-langu AND
          bzirk EQ fu_bzirk.

  READ TABLE t_a511 WITH KEY zday1 = fu_bzirk.
  IF sy-subrc EQ 0.
    CASE 'X'.
      WHEN dis OR day.
        lv_day  = t_a511-zday5 + t_a511-zday6.
      WHEN wh2 OR wh1.
        lv_day  = t_a511-zday3 + t_a511-zday4 +
                  t_a511-zday5.
      WHEN dp2 OR dp1.
        lv_day  = t_a511-zday6.
      WHEN OTHERS.
        lv_day  = t_a511-zday3 + t_a511-zday4 +
                  t_a511-zday5 + t_a511-zday6.
    ENDCASE.
  ENDIF.
  l_day   = lv_day.

  SHIFT lv_day LEFT DELETING LEADING space.
  CONCATENATE '<' lv_day 'hari' INTO lv_day01
  SEPARATED BY space.
  CONCATENATE lv_day 'hari' INTO lv_day02
  SEPARATED BY space.

  gv_day01 = lv_day.
  gv_day02 = lv_day.

  DO 3 TIMES.
    l_day = l_day + 1.
    lv_day  = l_day.
    SHIFT lv_day LEFT DELETING LEADING space.
    CASE sy-index.
      WHEN 1.
        CONCATENATE lv_day 'hari' INTO lv_day03
        SEPARATED BY space.
        gv_day03 = lv_day.

      WHEN 2.
        CONCATENATE lv_day 'hari' INTO lv_day04
        SEPARATED BY space.
        gv_day04 = lv_day.

      WHEN 3.
        CONCATENATE lv_day 'hari' INTO lv_day05
        SEPARATED BY space.
        gv_day05 = lv_day.

*      WHEN 4.
*        CONCATENATE lv_day 'hari' INTO lv_day06
*        SEPARATED BY space.
*        gv_day06 = lv_day.
    ENDCASE.
  ENDDO.

  CONCATENATE '>' lv_day 'hari' INTO lv_day06
  SEPARATED BY space.
  gv_day06 = lv_day.

  SKIP 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR OFF.
  WRITE: / ld_bztxt.
  FORMAT COLOR 1.
  WRITE: / sy-uline(189).
  WRITE: / sy-vline NO-GAP, 'Shpt' NO-GAP,
           sy-vline, 'Group Outlet',
           sy-vline NO-GAP, 'DK/LK' NO-GAP,
           sy-vline NO-GAP, 'Cust.Group' NO-GAP,
           sy-vline, (18) 'Name',
           sy-vline, (10) 'Target',
           sy-vline, (10) lv_day01,
           sy-vline, (10) lv_day02,
           sy-vline, (10) lv_day03,
           sy-vline, (10) lv_day04,
           sy-vline, (10) lv_day05,
           sy-vline, (10) lv_day06,
*           sy-vline, (10) lv_day07,
           sy-vline, (10) 'Total',
           sy-vline, (10) '% STD',
           sy-vline.
  WRITE: / sy-uline(189).


*           sy-vline, (10) '< 3 hari',
*           sy-vline, (10) '4 hari',
*           sy-vline, (10) '5 hari',
*           sy-vline, (10) '6 hari',
*           sy-vline, (10) '7 hari',
*           sy-vline, (10) '8 hari',
*           sy-vline, (10) '> 8 hari',

ENDFORM.                    " F_HEADER_DISTRICT

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_footer_new .
  DATA: ld_average TYPE p DECIMALS 2,
        ld_hari    LIKE t_avr-hari,
        ld_total   LIKE t_avr-total.

  WRITE:/ sy-uline(72),
        / sy-vline, (20) 'Channel',
          sy-vline, (6) space,
          sy-vline, (10) 'Total',
          sy-vline, (10) 'HIT',
          sy-vline, (10) '%',
          sy-vline.
  WRITE:/ sy-uline(72).

  PERFORM f_write_footer USING '' 'Corp. Pharma' ld_average
                         CHANGING ld_hari ld_total.
  PERFORM f_write_footer USING '' 'GT' ld_average
                         CHANGING ld_hari ld_total.
  PERFORM f_write_footer USING '' 'MT' ld_average
                         CHANGING ld_hari ld_total.

  ld_average  = ( ld_hari / ld_total ) * 100.
  WRITE:/ sy-vline, (20) 'Total',
          sy-vline, (6) space,
          sy-vline, (10) ld_total,
          sy-vline, (10) ld_hari,
          sy-vline, (10) ld_average,
          sy-vline.
  WRITE:/ sy-uline(72).

ENDFORM.                    " F_FOOTER_NEW

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_OLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_footer_old .
  DATA: ld_avr      TYPE p DECIMALS 2,
        ld_avrcp    TYPE p DECIMALS 2,
        ld_avrtrm   TYPE p DECIMALS 2,
        ld_avrmvr   TYPE p DECIMALS 2,
        ld_avrdktrm TYPE p DECIMALS 2,
        ld_avrdkcp  TYPE p DECIMALS 2,
        ld_avrdkmvr TYPE p DECIMALS 2,
        ld_avrlkcp  TYPE p DECIMALS 2,
        ld_avrlktrm TYPE p DECIMALS 2,
        ld_avrlkmvr TYPE p DECIMALS 2,
        ld_cp       TYPE i,
        ld_trm      TYPE i,
        ld_mvr      TYPE i,
        ld_avrttl   TYPE i.

  IF ld_cp IS NOT INITIAL.
    ld_avrcp  = ( ld_avrdkcp + ld_avrlkcp ) / ld_cp.
    ADD 1 TO ld_avrttl.
  ENDIF.
  WRITE: / 'Corporate pharma : ', ld_avrcp.

  IF ld_trm IS NOT INITIAL.
    ld_avrtrm  = ( ld_avrdktrm + ld_avrlktrm ) /  ld_trm.
    ADD 1 TO ld_avrttl.
  ENDIF.
  WRITE: / 'General trade    : ', ld_avrtrm.

  IF ld_mvr IS NOT INITIAL.
    ld_avrmvr  = ( ld_avrdkmvr + ld_avrlkmvr ) / ld_mvr.
    ADD 1 TO ld_avrttl.
  ENDIF.
  WRITE: / 'Modern trade     : ', ld_avrmvr.
  SKIP 1.
  IF ld_avrttl IS NOT INITIAL.
    ld_avr  = ( ld_avrcp + ld_avrtrm + ld_avrmvr ) / ld_avrttl.
  ENDIF.
  WRITE: / 'Average              : ', ld_avr.
ENDFORM.                    " F_FOOTER_OLD

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FOOTER
*&---------------------------------------------------------------------*
FORM f_write_footer  USING  fu_flag fu_type fu_average
                     CHANGING fc_hari fc_total.
  DATA: ld_text(20),
        ld_average  TYPE p DECIMALS 2,
        ld_total    LIKE t_avr-total,
        ld_hari     LIKE t_avr-hari.

  CASE fu_flag.
    WHEN 'X'.
      CASE fu_type.
        WHEN 'Corp. Pharma'.
          ld_text = 'Corporate pharma'.
        WHEN 'GT'.
          ld_text = 'General trade'.
        WHEN 'MT'.
          ld_text = 'Modern trade'.
      ENDCASE.

      LOOP AT t_avr WHERE type = fu_type.
        ADD t_avr-total TO ld_total.
        ADD t_avr-hari1 TO ld_hari.
      ENDLOOP.

      ld_average  = ( ld_hari / ld_total ) * 100.

      WRITE: / sy-vline, (20) ld_text,
               sy-vline, (10) ld_total,
               sy-vline, (10) ld_hari,
               sy-vline, (10) ld_average,
               sy-vline.
      WRITE:/ sy-uline(63).

    WHEN OTHERS.
      READ TABLE t_avr WITH KEY type = fu_type
                                dlk  = 'DK'.
      IF sy-subrc EQ 0.
        IF t_avr-total IS NOT INITIAL.
          fu_average  = ( t_avr-hari / t_avr-total ) * 100.
        ELSE.
          CLEAR: fu_average, t_avr.
        ENDIF.
      ELSE.
        CLEAR: fu_average, t_avr.
      ENDIF.
      WRITE: / sy-vline, (20) space,
               sy-vline, (6) 'DK',
               sy-vline, (10) t_avr-total,
               sy-vline, (10) t_avr-hari,
               sy-vline, (10) fu_average,
               sy-vline.
      ADD t_avr-hari TO fc_hari.
      ADD t_avr-total TO fc_total.

      CASE fu_type.
        WHEN 'Corp. Pharma'.
          ld_text = 'Corporate pharma'.
        WHEN 'GT'.
          ld_text = 'General trade'.
        WHEN 'MT'.
          ld_text = 'Modern trade'.
      ENDCASE.

      WRITE:/ sy-vline, (20) ld_text,
              sy-vline NO-GAP, sy-uline(47) NO-GAP,
              sy-vline.

      READ TABLE t_avr WITH KEY type = fu_type
                                dlk  = 'LK'.
      IF sy-subrc EQ 0.
        IF t_avr-total IS NOT INITIAL.
          fu_average  = ( t_avr-hari / t_avr-total ) * 100.
        ELSE.
          CLEAR: fu_average, t_avr.
        ENDIF.
      ELSE.
        CLEAR: fu_average, t_avr.
      ENDIF.
      WRITE: / sy-vline, (20) space,
               sy-vline, (6) 'LK',
               sy-vline, (10) t_avr-total,
               sy-vline, (10) t_avr-hari,
               sy-vline, (10) fu_average,
               sy-vline.
      WRITE:/ sy-uline(72).
      ADD t_avr-hari TO fc_hari.
      ADD t_avr-total TO fc_total.
  ENDCASE.
ENDFORM.                    " F_WRITE_FOOTER

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_date .
  ra_date[] = crt_date[].
  READ TABLE ra_date INDEX 1.
*  CLEAR ra_date. REFRESH ra_date.
*  CONCATENATE p_spmon '01' INTO ra_date-low.
*  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
*    EXPORTING
*      day_in            = ra_date-low
*    IMPORTING
*      last_day_of_month = ra_date-high.
*  ra_date-sign   = 'I'.
*  ra_date-option = 'BT'.
*  APPEND ra_date.
ENDFORM.                    " F_INIT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1902   text
*----------------------------------------------------------------------*
FORM f_selection_output  USING    fu_value.
  LOOP AT SCREEN.
    IF screen-group1 = fu_value.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " F_SELECTION_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_validate_screen .
  DATA : lv_count   TYPE i.

  CASE 'X'.
    WHEN upl.
      IF pa_filnm IS INITIAL.
        PERFORM f_screen_error USING 'UPL'.
      ENDIF.
    WHEN rho.
      IF pa_vkorg IS INITIAL.
        PERFORM f_screen_error USING 'VKO'.
      ENDIF.
      IF pa_lfart IS INITIAL.
        PERFORM f_screen_error USING 'LFA'.
      ENDIF.
      IF crt_date[] IS INITIAL.
        PERFORM f_screen_error USING 'CRT'.
      ENDIF.

      LOOP AT crt_date.
        ADD 1 TO lv_count.
        IF lv_count > 1.
          DELETE crt_date.
          CONTINUE.
        ENDIF.
        IF crt_date-high IS INITIAL.
          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              day_in            = crt_date-low
            IMPORTING
              last_day_of_month = crt_date-high
            EXCEPTIONS
              day_in_no_date    = 1
              OTHERS            = 2.
          IF sy-subrc = 0.
            MODIFY crt_date.
          ENDIF.
        ENDIF.
***        IF crt_date-low+4(2) <> crt_date-high+4(2).
***          PERFORM f_screen_error USING 'CRT'.
***        ENDIF.
      ENDLOOP.

      PERFORM f_get_quarter.

    WHEN OTHERS.
      IF pa_vkorg IS INITIAL.
        PERFORM f_screen_error USING 'VKO'.
      ENDIF.
      IF pa_lfart IS INITIAL.
        PERFORM f_screen_error USING 'LFA'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_EXT_EXPENDITION
*&---------------------------------------------------------------------*
FORM f_ext_expendition .
  DATA: wa_extpay  LIKE wa_result.

  LOOP AT i_result INTO wa_result.
    CLEAR : wa_result-bzirk.
    MODIFY i_result FROM wa_result TRANSPORTING bzirk.
    IF wa_result-add04(3) = 'EXT' AND
      wa_result-katr6 IS NOT INITIAL.
      wa_extpay  = wa_result.
      APPEND wa_extpay TO i_extpay.
      DELETE i_result.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_EXT_EXPENDITION

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_EXP_EXPENDITION
*&---------------------------------------------------------------------*
FORM f_write_exp_expendition .
  DATA : lt_extpay  LIKE wa_result OCCURS 0.

  DATA : lt_zsextrec  TYPE STANDARD TABLE OF zsextrec INITIAL SIZE 0
                      WITH HEADER LINE.

  DATA : wa_extpay  LIKE wa_result.
  DATA : ld_zebra    TYPE i,
         lv_count    TYPE p DECIMALS 0,
         lv_crdat    TYPE sy-datum,
         lv_crtim    TYPE sy-uzeit,
         lv_text(20).
  DATA : lv_total TYPE p DECIMALS 0,
         lv_hit   TYPE p DECIMALS 0,
         lv_nhit  TYPE p DECIMALS 0,
         lv_std   TYPE p DECIMALS 0.

  SKIP 1.
  FORMAT INTENSIFIED ON.
  FORMAT COLOR OFF.
  WRITE: / 'Delivery Expedition External'.
  FORMAT COLOR 1.
  WRITE: / sy-uline(gv_uline).
  WRITE: / sy-vline NO-GAP, 'Shpt' NO-GAP,
           sy-vline, 'Group Outlet',
           sy-vline NO-GAP, 'DK/LK' NO-GAP,
           sy-vline NO-GAP, 'Cust.Group' NO-GAP,
           sy-vline, (10) 'Outlet',
           sy-vline, (24) 'Name',
           sy-vline, (10) 'Target',
           sy-vline, (15) 'Total Delv.Ext.',
           sy-vline, (15) 'Not Hit',
           sy-vline, (15) 'HIT',
           sy-vline, (15) '% STD',
           sy-vline.
  WRITE: / sy-uline(gv_uline).

  lt_extpay[] = i_extpay[].
  SORT lt_extpay BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_extpay COMPARING vbeln.
  IF lt_extpay[] IS NOT INITIAL.
    SELECT *
      FROM zsextrec
      INTO CORRESPONDING FIELDS OF TABLE lt_zsextrec
      FOR ALL ENTRIES IN lt_extpay
      WHERE vbeln = lt_extpay-vbeln.
  ENDIF.

  CLEAR : lt_extpay[], lt_extpay.

  SORT i_extpay BY kunnr.
  LOOP AT i_extpay INTO wa_extpay.
    ls_extpay-vstel = wa_extpay-vstel.
    ls_extpay-type  = wa_extpay-type.
    ls_extpay-dlk   = wa_extpay-dlk.
    ls_extpay-kdgrp = wa_extpay-kdgrp.
    ls_extpay-kunnr = wa_extpay-kunnr.
    ls_extpay-name1 = wa_extpay-name1.
    ls_extpay-katr6 = wa_extpay-katr6.
    ls_extpay-total = 1.

    CLEAR : lv_crdat, lv_crtim, lv_count, lt_zsextrec.
    READ TABLE lt_zsextrec WITH KEY vbeln = wa_extpay-vbeln.
    IF sy-subrc = 0.
      lv_crdat = lt_zsextrec-crdat.
      lv_crtim = lt_zsextrec-crtim.
      wa_extpay-crdatext  = lt_zsextrec-crdat.
      wa_extpay-crtimext  = lt_zsextrec-crtim.
    ENDIF.

    IF lv_crdat <> '00000000'.
      lv_count = lv_crdat - wa_extpay-erdat_so.
      PERFORM f_get_holiday USING lv_crdat
                                  wa_extpay-erdat_so
                            CHANGING lv_count.
      IF lv_crtim < wa_extpay-erzet_so.
        lv_count = lv_count - 1.
      ENDIF.
    ELSE.
      lv_count = 999.
    ENDIF.

    IF lv_count <= wa_extpay-katr6.
      ls_extpay-hit   = 1.
    ELSE.
      ls_extpay-nhit  = 1.
    ENDIF.

    wa_extpay-hit = ls_extpay-hit.
    wa_extpay-nhit = ls_extpay-nhit.

    COLLECT ls_extpay INTO lt_extpay.
    CLEAR ls_extpay.

    MODIFY i_extpay FROM wa_extpay TRANSPORTING hit nhit crdatext crtimext.
  ENDLOOP.

  LOOP AT lt_extpay INTO ls_extpay.
    ls_extpay-std = ( ls_extpay-hit / ls_extpay-total ) * 100.

    ADD ls_extpay-hit   TO lv_hit.
    ADD ls_extpay-nhit  TO lv_nhit.
    ADD ls_extpay-total TO lv_total.

    IF ld_zebra IS INITIAL.
      ld_zebra = 1.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
    ELSE.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      CLEAR: ld_zebra.
    ENDIF.

    CASE ls_extpay-kdgrp.
      WHEN '04' OR '05' OR '07' OR '10' OR '11' OR 'T1'.
        ls_extpay-type = 'GT'.
      WHEN '03'.
        IF ls_extpay-kvgr3 = '031' OR ls_extpay-kvgr3 = '034'.
          ls_extpay-ktext = 'SM Key account'.
        ENDIF.
        ls_extpay-type = 'MT'.
      WHEN '02' OR '06' OR '08' OR '09'.
        ls_extpay-type = 'Corp. Pharma'.
    ENDCASE.

    t_avr-type   = ls_extpay-type.
    t_avr-dlk    = ls_extpay-dlk.
    t_avr-hari   = ls_extpay-hit.
    t_avr-total  = ls_extpay-total.
    COLLECT t_avr.

    WRITE: / sy-vline NO-GAP, ls_extpay-vstel NO-GAP,
             sy-vline, ls_extpay-type,
             sy-vline, (3) ls_extpay-dlk,
             sy-vline, (8) ls_extpay-kdgrp,
             sy-vline, ls_extpay-kunnr,
             sy-vline NO-GAP, (25) ls_extpay-name1,
             sy-vline, (10) ls_extpay-katr6,
             sy-vline, (15) ls_extpay-total,
             sy-vline, (15) ls_extpay-nhit,
             sy-vline, (15) ls_extpay-hit,
             sy-vline, (15) ls_extpay-std,
             sy-vline.
  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED OFF.

  WRITE: / sy-uline(gv_uline).
  WRITE: / sy-vline, (87) 'Total',
           sy-vline, (15) lv_total,
           sy-vline, (15) lv_nhit,
           sy-vline, (15) lv_hit,
           sy-vline, (15) lv_std,
           sy-vline.
  WRITE: / sy-uline(gv_uline).
ENDFORM.                    " F_WRITE_EXP_EXPENDITION

*&---------------------------------------------------------------------*
*&      Form  F_TARGET_CALCULATE
*&---------------------------------------------------------------------*
FORM f_target_calculate  USING    fu_vkorg
                                  fwa_outpl3  LIKE wa_outpl3
                                  fu_average
                         CHANGING fc_day.

  READ TABLE t_a511y WITH KEY vkorg = fu_vkorg
                              zday1 = fwa_outpl3-bzirk.
  IF sy-subrc EQ 0.
    CASE 'X'.
      WHEN wh1 OR wh2.
        fc_day  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5.
      WHEN dp1 OR dp2.
        fc_day  = t_a511y-zday6.
      WHEN OTHERS.
        fc_day  = t_a511y-zday5 + t_a511y-zday6.
    ENDCASE.
  ELSE.
    READ TABLE t_a511 WITH KEY vkorg = fu_vkorg
                               vkbur = fwa_outpl3-vstel
                               katr1 = fwa_outpl3-dlk
                               kdgrp = fwa_outpl3-kdgrp.
    IF sy-subrc EQ 0.
      CASE 'X'.
        WHEN wh1 OR wh2.
          fc_day  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5.
        WHEN dp1 OR dp2.
          fc_day  = t_a511-zday6.
        WHEN OTHERS.
          fc_day  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5 + t_a511-zday6.
      ENDCASE.
    ELSE.
      READ TABLE t_a511x WITH KEY vkorg = pa_vkorg
                                  vkbur = space
                                  katr1 = fwa_outpl3-dlk
                                  kdgrp = fwa_outpl3-kdgrp.
      IF sy-subrc EQ 0.
        CASE 'X'.
          WHEN wh1 OR wh2.
            fc_day  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5.
          WHEN dp1 OR dp2.
            fc_day  = t_a511x-zday6.
          WHEN OTHERS.
            IF fwa_outpl3-dlk = 'DK'.
              fc_day  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5 + t_a511x-zday6.
            ELSEIF fwa_outpl3-dlk = 'LK'.
              fc_day  = t_a511x-zday5 + t_a511x-zday6.
            ENDIF.
        ENDCASE.
      ELSE.
        CLEAR: fc_day.
      ENDIF.
    ENDIF.

    IF fu_average IS NOT INITIAL.
      READ TABLE t_avr WITH KEY type = wa_outpl3-type
                                dlk  = wa_outpl3-dlk.
      IF sy-subrc EQ 0.
        PERFORM f_hitung_average USING wa_outpl3 va_avr sy-tabix.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_TARGET_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_SUMMARY
*&---------------------------------------------------------------------*
FORM f_process_summary .
  DATA : lt_t001w  TYPE STANDARD TABLE OF t001w INITIAL SIZE 0,
         ls_t001w  LIKE LINE OF lt_t001w,
         lt_result LIKE wa_result OCCURS 0.

  DATA : lt_outpl3  LIKE wa_outpl3 OCCURS 0.

  DATA : lv_count  TYPE int4,
         ls_out    LIKE LINE OF gt_out,
         ls_result LIKE LINE OF i_result.
  DATA : lv_0 TYPE p,
         lv_1 TYPE p,
         lv_2 TYPE p,
         lv_3 TYPE p,
         lv_4 TYPE p,
         lv_5 TYPE p.
  DATA : lv_0x TYPE p,
         lv_1x TYPE p,
         lv_2x TYPE p,
         lv_3x TYPE p,
         lv_4x TYPE p,
         lv_5x TYPE p.

  SELECT *
    FROM t001w
    INTO CORRESPONDING FIELDS OF TABLE lt_t001w.

  lt_result[] = i_result[].
  DELETE lt_result WHERE bzirk = space.

  SORT i_outpl3 BY vstel type dlk bzirk.

  LOOP AT i_outpl3 INTO wa_outpl3.
    CLEAR wa_outpl3-ktext.
    COLLECT wa_outpl3 INTO lt_outpl3.
  ENDLOOP.

  DO 3 TIMES.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        ls_out-keterangan = 'WDP'.
      WHEN 2.
        ls_out-keterangan = 'WP'.
      WHEN 3.
        ls_out-keterangan = 'DP'.
    ENDCASE.

    LOOP AT lt_outpl3 INTO wa_outpl3.
      ls_out-vstel  = wa_outpl3-vstel.
      CLEAR ls_t001w.
      READ TABLE lt_t001w INTO ls_t001w
                          WITH KEY werks = wa_outpl3-vstel.
      IF sy-subrc = 0.
        ls_out-name1  = ls_t001w-name1.
      ENDIF.
      ls_out-type   = wa_outpl3-type.
      ls_out-kdgrp  = wa_outpl3-kdgrp.
      ls_out-dlk    = wa_outpl3-dlk.
      ls_out-total  = wa_outpl3-total.
      ls_out-bzirk  = wa_outpl3-bzirk.

      PERFORM f_summary_target USING ls_out-keterangan wa_outpl3
                               CHANGING ls_out-target ls_out-targetx.

      CLEAR : ls_out-0, ls_out-1, ls_out-2,
              ls_out-3, ls_out-4, ls_out-5,
              ls_out-0x, ls_out-1x, ls_out-2x,
              ls_out-3x, ls_out-4x, ls_out-5x.

      LOOP AT i_result INTO ls_result WHERE vstel = wa_outpl3-vstel
                                        AND dlk   = wa_outpl3-dlk
                                        AND kdgrp = wa_outpl3-kdgrp
                                        AND bzirk = wa_outpl3-bzirk.
        PERFORM f_split_days USING ls_out-keterangan ls_result ''
                             CHANGING lv_0 lv_1 lv_2 lv_3 lv_4 lv_5.
        ADD lv_0 TO ls_out-0.
        ADD lv_1 TO ls_out-1.
        ADD lv_2 TO ls_out-2.
        ADD lv_3 TO ls_out-3.
        ADD lv_4 TO ls_out-4.
        ADD lv_5 TO ls_out-5.

        IF ls_result-bzirk IS INITIAL.
          ADD lv_0 TO ls_out-0x.
          ADD lv_1 TO ls_out-1x.
          ADD lv_2 TO ls_out-2x.
          ADD lv_3 TO ls_out-3x.
          ADD lv_4 TO ls_out-4x.
          ADD lv_5 TO ls_out-5x.
        ENDIF.

        PERFORM f_transaction_count USING ls_result
                                    CHANGING ls_out-jgi ls_out-jsh ls_out-jcr.
      ENDLOOP.

      CLEAR : ls_out-0y, ls_out-1y, ls_out-2y,
              ls_out-3y, ls_out-4y, ls_out-5y.

      LOOP AT lt_result INTO ls_result WHERE vstel = wa_outpl3-vstel
                                         AND dlk   = wa_outpl3-dlk
                                         AND kdgrp = wa_outpl3-kdgrp
                                         AND bzirk = wa_outpl3-bzirk.
        PERFORM f_split_days USING ls_out-keterangan ls_result ''
                             CHANGING lv_0x lv_1x lv_2x lv_3x lv_4x lv_5x.

        ADD lv_0x TO ls_out-0y.
        ADD lv_1x TO ls_out-1y.
        ADD lv_2x TO ls_out-2y.
        ADD lv_3x TO ls_out-3y.
        ADD lv_4x TO ls_out-4y.
        ADD lv_5x TO ls_out-5y.
      ENDLOOP.

      READ TABLE gt_out WITH KEY keterangan = ls_out-keterangan
                                 vstel  = ls_out-vstel
                                 name1  = ls_out-name1
                                 type   = ls_out-type
                                 kdgrp  = ls_out-kdgrp
                                 dlk    = ls_out-dlk
                                 bzirk  = ls_out-bzirk
                                 TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CLEAR: ls_out-target,ls_out-targetx.
      ENDIF.

      COLLECT ls_out INTO gt_out.
      CLEAR : ls_out-hit, ls_out-hitx, ls_out-hity,
              ls_out-jgi, ls_out-jsh, ls_out-jcr.
    ENDLOOP.
  ENDDO.

  LOOP AT gt_out INTO ls_out.
    IF ls_out-bzirk IS INITIAL.
      CASE ls_out-target.
        WHEN 0.
          ls_out-hitnew = ls_out-0.
        WHEN 1.
          ls_out-hitnew = ls_out-0 + ls_out-1.
        WHEN 2.
          ls_out-hitnew = ls_out-0 + ls_out-1 + ls_out-2.
        WHEN 3.
          ls_out-hitnew = ls_out-0 + ls_out-1 + ls_out-2 +
                          ls_out-3.
        WHEN OTHERS.
          ls_out-hitnew = ls_out-0 + ls_out-1 + ls_out-2 + ls_out-3 +
                          ls_out-4.
      ENDCASE.
    ELSE.
      CASE ls_out-targetx.
        WHEN 0.
          ls_out-hitnew = ls_out-0y.
        WHEN 1.
          ls_out-hitnew = ls_out-0y + ls_out-1y.
        WHEN 2.
          ls_out-hitnew = ls_out-0y + ls_out-1y + ls_out-2y.
        WHEN 3.
          ls_out-hitnew = ls_out-0y + ls_out-1y + ls_out-2y +
                          ls_out-3y.
        WHEN OTHERS.
          ls_out-hitnew = ls_out-0y + ls_out-1y + ls_out-2y +
                          ls_out-3y + ls_out-4y.
      ENDCASE.
    ENDIF.

    CASE ls_out-target.
      WHEN 0.
        ls_out-hit   = ls_out-0.
        ls_out-hitx  = ls_out-0x.
      WHEN 1.
        ls_out-hit   = ls_out-0 + ls_out-1.
        ls_out-hitx  = ls_out-0x + ls_out-1x.
      WHEN 2.
        ls_out-hit   = ls_out-0 + ls_out-1 + ls_out-2.
        ls_out-hitx  = ls_out-0x + ls_out-1x + ls_out-2x.
      WHEN 3.
        ls_out-hit   = ls_out-0 + ls_out-1 + ls_out-2 +
                       ls_out-3.
        ls_out-hitx  = ls_out-0x + ls_out-1x + ls_out-2x +
                       ls_out-3x.
      WHEN OTHERS.
        ls_out-hit   = ls_out-0 + ls_out-1 + ls_out-2 + ls_out-3 +
                       ls_out-4.
        ls_out-hitx  = ls_out-0x + ls_out-1x + ls_out-2x + ls_out-3x +
                       ls_out-4x.
    ENDCASE.

    CASE ls_out-targetx.
      WHEN 0.
        ls_out-hity  = ls_out-0y.
      WHEN 1.
        ls_out-hity  = ls_out-0y + ls_out-1y.
      WHEN 2.
        ls_out-hity  = ls_out-0y + ls_out-1y + ls_out-2y.
      WHEN 3.
        ls_out-hity  = ls_out-0y + ls_out-1y + ls_out-2y +
                       ls_out-3y.
      WHEN OTHERS.
        ls_out-hity  = ls_out-0y + ls_out-1y + ls_out-2y +
                       ls_out-3y + ls_out-4y.
    ENDCASE.

    ls_out-hitx = ls_out-hitx + ls_out-hity.
    MODIFY gt_out FROM ls_out TRANSPORTING hit hitx hity hitnew.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SUMMARY
*&---------------------------------------------------------------------*
FORM f_write_summary .
  PERFORM alv_prep.
ENDFORM.                    " F_WRITE_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_TARGET
*&---------------------------------------------------------------------*
FORM f_summary_target  USING    fu_keterangan
                                fwa_outpl3  LIKE wa_outpl3
                       CHANGING fc_day fc_dayx.

  CLEAR : fc_day, fc_dayx.

  READ TABLE t_a511y WITH KEY zday1 = fwa_outpl3-bzirk.
  IF sy-subrc EQ 0.
    CASE fu_keterangan.
      WHEN 'WP'.
        fc_dayx  = t_a511y-zday3 + t_a511y-zday4 + t_a511y-zday5.
      WHEN 'DP'.
        fc_dayx  = t_a511y-zday6.
      WHEN 'WDP'.
        fc_dayx  = t_a511y-zday5 + t_a511y-zday6.
    ENDCASE.
  ELSE.
    READ TABLE t_a511 WITH KEY vkbur = fwa_outpl3-vstel
                               katr1 = fwa_outpl3-dlk
                               kdgrp = fwa_outpl3-kdgrp.
    IF sy-subrc EQ 0.
      CASE fu_keterangan.
        WHEN 'WP'.
          fc_day  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5.
        WHEN 'DP'.
          fc_day  = t_a511-zday6.
        WHEN 'WDP'.
          fc_day  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5 + t_a511-zday6.
      ENDCASE.
    ELSE.
      READ TABLE t_a511x WITH KEY vkbur = space
                                  katr1 = fwa_outpl3-dlk
                                  kdgrp = fwa_outpl3-kdgrp.
      IF sy-subrc EQ 0.
        CASE fu_keterangan.
          WHEN 'WP'.
            fc_day  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5.
          WHEN 'DP'.
            fc_day  = t_a511x-zday6.
          WHEN 'WDP'.
            IF fwa_outpl3-dlk = 'DK'.
              fc_day  = t_a511x-zday3 + t_a511x-zday4 + t_a511x-zday5 + t_a511x-zday6.
            ELSEIF fwa_outpl3-dlk = 'LK'.
              fc_day  = t_a511x-zday5 + t_a511x-zday6.
            ENDIF.
        ENDCASE.
      ELSE.
        CLEAR: fc_day.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SUMMARY_TARGET

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_DAYS
*&---------------------------------------------------------------------*
FORM f_split_days  USING    fu_keterangan
                            fs_result  LIKE wa_result
                            fu_xbzirk
                   CHANGING fc_0 fc_1 fc_2 fc_3 fc_4 fc_5.

  DATA : lv_day  TYPE p DECIMALS 0,
         lv_xday TYPE p DECIMALS 0,
         lv_01   TYPE p DECIMALS 0,
         lv_02   TYPE p DECIMALS 0,
         lv_03   TYPE p DECIMALS 0,
         lv_04   TYPE p DECIMALS 0.

  CLEAR : fc_0, fc_1, fc_2, fc_3, fc_4.

  CASE fu_keterangan.
    WHEN 'WP'.
      lv_day = fs_result-do_vs_spgd_dt.
    WHEN 'DP'.
      lv_day = fs_result-cr_vs_spgd_dt.
    WHEN 'WDP'.
      lv_day = fs_result-cr_create_dt.
  ENDCASE.

  IF fu_xbzirk IS INITIAL.
    CASE lv_day.
      WHEN 0.
        fc_0  = 1.
      WHEN 1.
        fc_1  = 1.
      WHEN 2.
        fc_2  = 1.
      WHEN 3.
        fc_3  = 1.
      WHEN 999.
        IF cr_date = 'X'.
          IF fs_result-crdat IS NOT INITIAL.
            fc_4  = 1.
          ENDIF.
        ELSE.
          fc_4  = 1.
        ENDIF.
      WHEN OTHERS.
        fc_4  = 1.
    ENDCASE.
  ELSE.
    READ TABLE t_a511 WITH KEY zday1 = fs_result-bzirk.
    IF sy-subrc EQ 0.
      CASE fu_keterangan.
        WHEN 'WDP'.
          lv_xday  = t_a511-zday5 + t_a511-zday6.
        WHEN 'WP'.
          lv_xday  = t_a511-zday3 + t_a511-zday4 + t_a511-zday5.
        WHEN 'DP'.
          lv_xday  = t_a511-zday6.
      ENDCASE.
    ENDIF.

    lv_01  = lv_xday + 1.
    lv_02  = lv_xday + 2.
    lv_03  = lv_xday + 3.
    lv_04  = lv_xday + 4.

    IF lv_day LT lv_xday.
      fc_0  = 1.
    ENDIF.

    CASE lv_day.
      WHEN lv_xday.
        fc_1  = 1.
      WHEN lv_01.
        fc_2  = 1.
      WHEN lv_02.
        fc_3  = 1.
      WHEN lv_03.
        fc_4  = 1.
    ENDCASE.

    IF lv_day GT lv_03.
      IF cr_date = 'X'.
        IF fs_result-crdat IS NOT INITIAL.
          fc_5  = 1.
        ENDIF.
      ELSE.
        fc_5  = 1.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SPLIT_DAYS

*&---------------------------------------------------------------------*
*&      Form  F_FOOTER_REKAP_WP
*&---------------------------------------------------------------------*
FORM f_footer_rekap_wp .
  DATA: ld_average TYPE p DECIMALS 2,
        ld_hari    LIKE t_avr-hari,
        ld_total   LIKE t_avr-total.

  WRITE:/ sy-uline(63),
        / sy-vline, (20) 'Channel',
          sy-vline, (10) 'Total',
          sy-vline, (10) 'HIT',
          sy-vline, (10) '%',
          sy-vline.
  WRITE:/ sy-uline(63).

  PERFORM f_write_footer USING 'X' 'Corp. Pharma' ld_average
                         CHANGING ld_hari ld_total.
  PERFORM f_write_footer USING 'X' 'GT' ld_average
                         CHANGING ld_hari ld_total.
  PERFORM f_write_footer USING 'X' 'MT' ld_average
                         CHANGING ld_hari ld_total.

  LOOP AT t_avr.
    ADD t_avr-total TO ld_total.
    ADD t_avr-hari1 TO ld_hari.
  ENDLOOP.

  ld_average  = ( ld_hari / ld_total ) * 100.
  WRITE:/ sy-vline, (20) 'Total',
          sy-vline, (10) ld_total,
          sy-vline, (10) ld_hari,
          sy-vline, (10) ld_average,
          sy-vline.
  WRITE:/ sy-uline(63).
ENDFORM.                    " F_FOOTER_REKAP_WP

*&---------------------------------------------------------------------*
*&      Form  F_GET_FILENAME
*&---------------------------------------------------------------------*
FORM f_get_filename .
  DATA: v_repid LIKE sy-repid.
  v_repid = sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = v_repid
      dynpro_number = sy-dynnr
      field_name    = 'PA_FILNM'
    IMPORTING
      file_name     = pa_filnm
    EXCEPTIONS
      OTHERS        = 1.

  IF sy-subrc <> 0.
    CLEAR pa_filnm.
  ENDIF.
ENDFORM.                    " F_GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_XLS
*&---------------------------------------------------------------------*
FORM f_upload_xls .
  DATA : ls_001   LIKE LINE OF gt_001.

  REFRESH gt_excel. CLEAR gt_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pa_filnm
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  SORT gt_excel BY row col.
  LOOP AT gt_excel.
    CASE gt_excel-col.
      WHEN '0001'.
        ls_001-bukrs        = gt_excel-value.
      WHEN '0002'.
        ls_001-werks        = gt_excel-value.
      WHEN '0003'.
        ls_001-quarter      = gt_excel-value.
      WHEN '0004'.
        ls_001-mjahr        = gt_excel-value.
      WHEN '0005'.
        PERFORM f_unit_conversion USING gt_excel-value
                                  CHANGING ls_001-menge.
      WHEN '0006'.
        PERFORM f_uom_conversion USING gt_excel-value
                                 CHANGING ls_001-meins.
    ENDCASE.
    AT END OF row.
      APPEND ls_001 TO gt_001.
      CLEAR ls_001.
    ENDAT.
  ENDLOOP.

  MODIFY zghmmdt001 FROM TABLE gt_001.
  MESSAGE s000(zab) WITH 'Data already uploaded'.
ENDFORM.                    " F_UPLOAD_XLS

*&---------------------------------------------------------------------*
*&      Form  F_UNIT_CONVERSION
*&---------------------------------------------------------------------*
FORM f_unit_conversion  USING    fu_value
                        CHANGING fc_value.
  DATA : lv_value(20).

  lv_value = fu_value.

  TRANSLATE lv_value USING '. '.
  TRANSLATE lv_value USING ',.'.
  CONDENSE lv_value NO-GAPS.

  fc_value = lv_value.
ENDFORM.                    " F_UNIT_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
FORM f_uom_conversion  USING    fu_value
                       CHANGING fc_value.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = fu_value
    IMPORTING
      output         = fc_value
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_UOM_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_GET_LIPS
*&---------------------------------------------------------------------*
FORM f_get_lips .
  DATA : lt_lips TYPE STANDARD TABLE OF lips,
         lt_mara TYPE STANDARD TABLE OF ty_mara.

  IF i_result[] IS NOT INITIAL.
    SELECT *
      FROM lips
      INTO CORRESPONDING FIELDS OF TABLE gt_lips
      FOR ALL ENTRIES IN i_result
      WHERE vbeln = i_result-vbeln.

    lt_lips[] = gt_lips[].
    SORT lt_lips[] BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING matnr.
    IF lt_lips[] IS NOT INITIAL.
      SELECT mara~matnr mara~meins mara~tempb
             makt~maktx
        FROM mara JOIN makt ON mara~matnr = makt~matnr
        INTO CORRESPONDING FIELDS OF TABLE gt_mara
        FOR ALL ENTRIES IN lt_lips
        WHERE mara~matnr = lt_lips-matnr
          AND makt~spras = sy-langu.

      SELECT matnr umrez
        FROM marm
        INTO CORRESPONDING FIELDS OF TABLE gt_marm
        FOR ALL ENTRIES IN lt_lips
        WHERE matnr = lt_lips-matnr
          AND meinh = 'KAR'.

      lt_mara[] = gt_mara[].
      SORT lt_mara BY tempb.
      DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING tempb.
      IF lt_mara[] IS NOT INITIAL.
        SELECT tempb tbtxt
          FROM t143t
          INTO CORRESPONDING FIELDS OF TABLE gt_t143t
          FOR ALL ENTRIES IN lt_mara
          WHERE tempb = lt_mara-tempb
            AND spras = sy-langu.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_LIPS

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_RHO
*&---------------------------------------------------------------------*
FORM f_write_rho .
  DATA : lt_result LIKE wa_result OCCURS 0,
         ls_result LIKE LINE OF lt_result,
         lv_zebra  TYPE i,
         ls_001    LIKE LINE OF gt_001,
         ls_drho   LIKE LINE OF gt_drho,
         lv_menge  TYPE p DECIMALS 0,
         lv_rocar  TYPE p DECIMALS 0,
         lv_growth TYPE p DECIMALS 2,
         lv_point  TYPE p DECIMALS 0.

  lt_result[] = i_result[].
  SORT lt_result BY vstel.
  DELETE ADJACENT DUPLICATES FROM lt_result COMPARING vstel.
  IF lt_result[] IS NOT INITIAL.
    WRITE : sy-uline(100).
    LOOP AT lt_result INTO ls_result.
      IF lv_zebra IS INITIAL.
        lv_zebra = 1.
        FORMAT COLOR 1.
        FORMAT INTENSIFIED OFF.
      ELSE.
        FORMAT COLOR 2.
        FORMAT INTENSIFIED OFF.
        CLEAR: lv_zebra.
      ENDIF.

      CLEAR ls_001.
      READ TABLE gt_001 INTO ls_001 WITH KEY werks = ls_result-vstel.
      IF ls_001-meins IS INITIAL.
        ls_001-meins  = 'KAR'.
      ENDIF.

      LOOP AT gt_drho INTO ls_drho WHERE vkbur = ls_result-vstel.
        ADD ls_drho-rocar TO lv_rocar.
      ENDLOOP.

      lv_menge  = ls_001-menge.
      lv_growth = ( lv_rocar / lv_menge - 1 ) * 100.
      IF lv_growth >= 15.
        lv_point = 1.
      ENDIF.

      WRITE: / sy-vline, ls_result-vstel,
               sy-vline, (20) ls_001-menge UNIT ls_001-meins,
               sy-vline, (20) lv_rocar,
               sy-vline, (20) lv_growth,
               sy-vline, (20) lv_point,
               sy-vline.

      CLEAR ls_result.
    ENDLOOP.
    WRITE : / sy-uline(100).
  ENDIF.
ENDFORM.                    " F_WRITE_RHO

*&---------------------------------------------------------------------*
*&      Form  F_GET_QUARTER
*&---------------------------------------------------------------------*
FORM f_get_quarter .
  DATA : lv_fiscp TYPE umc_y_fiscper,
         lv_calcq TYPE umc_ys_dimvals.

  CONCATENATE crt_date-low+4(2) crt_date-low(4) INTO lv_fiscp.
  CALL FUNCTION 'CONVERSION_EXIT_PERI7_INPUT'
    EXPORTING
      input           = lv_fiscp
    IMPORTING
      output          = lv_fiscp
    EXCEPTIONS
      input_not_valid = 1
      OTHERS          = 2.

  CALL FUNCTION 'UMC_FISCPER_TO_CALQUARTER'
    EXPORTING
      i_fiscper     = lv_fiscp
    IMPORTING
      es_calquarter = lv_calcq
    EXCEPTIONS
      invalid       = 1
      OTHERS        = 2.

  gv_quarter = lv_calcq-bw_val_nam+4(1).
  gv_mjahr   = lv_calcq-bw_val_nam(4).

  SELECT *
    FROM zghmmdt001
    INTO CORRESPONDING FIELDS OF TABLE gt_001
    WHERE bukrs   = pa_vkorg
      AND werks   IN ship_pnt
      AND quarter = gv_quarter
      AND mjahr   = gv_mjahr.
ENDFORM.                    " F_GET_QUARTER

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_RHO_PROCESS
*&---------------------------------------------------------------------*
FORM f_detail_rho_process .
  DATA : ls_result LIKE LINE OF i_result,
         ls_drho   LIKE LINE OF gt_drho,
         ls_lips   LIKE LINE OF gt_lips,
         ls_mara   LIKE LINE OF gt_mara,
         ls_marm   LIKE LINE OF gt_marm,
         ls_t143t  LIKE LINE OF gt_t143t.

  DATA : lt_xlips TYPE STANDARD TABLE OF lips,
         ls_xlips LIKE LINE OF lt_xlips.

  lt_xlips[] = gt_lips[].

  LOOP AT i_result INTO ls_result.
    ls_drho-vkbur = ls_result-vstel.
    ls_drho-vbeln = ls_result-vbeln.
    ls_drho-kunnr = ls_result-kunnr.
    ls_drho-name1 = ls_result-name1.
    ls_drho-kdgrp = ls_result-kdgrp.
    ls_drho-dlk   = ls_result-dlk.

    LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_result-vbeln.
      IF ls_lips-uecha IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      ls_drho-matnr = ls_lips-matnr.
      ls_drho-vrkme = ls_lips-vrkme.
      ls_drho-erdat = ls_lips-erdat.
      CLEAR ls_mara.
      READ TABLE gt_mara INTO ls_mara
                         WITH KEY matnr = ls_lips-matnr.
      IF sy-subrc = 0.
        ls_drho-maktx = ls_mara-maktx.
        ls_drho-umren = ls_mara-umren.
        ls_drho-umrez = ls_mara-umrez.
        ls_drho-tempb = ls_mara-tempb.
        CLEAR ls_t143t.
        READ TABLE gt_t143t INTO ls_t143t WITH KEY tempb = ls_mara-tempb.
        IF sy-subrc = 0.
          ls_drho-tbtxt = ls_t143t-tbtxt.
        ELSE.
          CLEAR ls_drho-tbtxt.
        ENDIF.

        ls_drho-lfimg = ls_lips-lfimg.

        LOOP AT lt_xlips INTO ls_xlips WHERE vbeln = ls_lips-vbeln
                                         AND uecha = ls_lips-posnr.
          ADD ls_xlips-lfimg TO ls_drho-lfimg.
        ENDLOOP.

        CLEAR : ls_drho-hocar, ls_drho-rocar.
        CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
          EXPORTING
            input                = ls_drho-lfimg
            matnr                = ls_drho-matnr
            meinh                = 'KAR'
            meins                = ls_drho-vrkme
          IMPORTING
            output               = ls_drho-hocar
          EXCEPTIONS
            conversion_not_found = 1
            input_invalid        = 2
            material_not_found   = 3
            meinh_not_found      = 4
            meins_missing        = 5
            no_meinh             = 6
            output_invalid       = 7
            overflow             = 8
            OTHERS               = 9.

        CALL FUNCTION 'ROUND'
          EXPORTING
            input         = ls_drho-hocar
            sign          = '+'
          IMPORTING
            output        = ls_drho-rocar
          EXCEPTIONS
            input_invalid = 1
            overflow      = 2
            type_invalid  = 3
            OTHERS        = 4.
      ENDIF.
      CLEAR ls_marm.
      READ TABLE gt_marm INTO ls_marm WITH KEY matnr = ls_lips-matnr.
      IF sy-subrc = 0.
        ls_drho-umrez = ls_marm-umrez.
      ELSE.
        CLEAR ls_drho-umrez.
      ENDIF.
      APPEND ls_drho TO gt_drho.
    ENDLOOP.
    CLEAR ls_drho.
  ENDLOOP.
ENDFORM.                    " F_DETAIL_RHO_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize)
                          VALUE(fu_edit).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  ld_fieldcat-edit              = fu_edit.
  APPEND ld_fieldcat TO xit_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_EXPORT_MEMORY
*&---------------------------------------------------------------------*
FORM f_export_memory .
  DATA : ls_result    LIKE LINE OF i_result,
         lv_idmem(40).

  CONCATENATE sy-uname 'RHO' INTO lv_idmem.
  EXPORT : gt_drho i_result gt_001 TO MEMORY ID lv_idmem.
ENDFORM.                    " F_EXPORT_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_RHO
*&---------------------------------------------------------------------*
FORM f_submit_rho .
  DATA: BEGIN OF lt_rsparams OCCURS 0,
          selname(8),
          kind(1),
          sign(1),
          option(2),
          low(45),
          high(45),
        END OF lt_rsparams.

  IF pa_vkorg IS NOT INITIAL.
    lt_rsparams-selname = 'SO_VKORG'.
    lt_rsparams-kind    = 'S'.
    lt_rsparams-sign    = 'I'.
    lt_rsparams-option  = 'EQ'.
    lt_rsparams-low     = pa_vkorg.
    APPEND lt_rsparams.
  ENDIF.
  IF pa_lfart IS NOT INITIAL.
    lt_rsparams-selname = 'SO_LFART'.
    lt_rsparams-kind    = 'S'.
    lt_rsparams-sign    = 'I'.
    lt_rsparams-option  = 'EQ'.
    lt_rsparams-low     = pa_lfart.
    APPEND lt_rsparams.
  ENDIF.
  IF ship_pnt[] IS NOT INITIAL.
    LOOP AT ship_pnt.
      lt_rsparams-selname = 'SO_VSTEL'.
      lt_rsparams-kind    = 'S'.
      lt_rsparams-sign    = ship_pnt-sign.
      lt_rsparams-option  = ship_pnt-option.
      lt_rsparams-low     = ship_pnt-low.
      lt_rsparams-high    = ship_pnt-high.
      APPEND lt_rsparams.
    ENDLOOP.
  ENDIF.
  IF crt_date[] IS NOT INITIAL.
    LOOP AT ship_pnt.
      lt_rsparams-selname = 'SO_ERDAT'.
      lt_rsparams-kind    = 'S'.
      lt_rsparams-sign    = crt_date-sign.
      lt_rsparams-option  = crt_date-option.
      lt_rsparams-low     = crt_date-low.
      lt_rsparams-high    = crt_date-high.
      APPEND lt_rsparams.
    ENDLOOP.
  ENDIF.
  lt_rsparams-selname = 'UNITED'.
  lt_rsparams-kind    = 'P'.
  lt_rsparams-sign    = 'I'.
  lt_rsparams-option  = 'EQ'.
  lt_rsparams-low     = united.
  APPEND lt_rsparams.

  SUBMIT zmmrho WITH SELECTION-TABLE lt_rsparams AND RETURN.
ENDFORM.                    " F_SUBMIT_RHO

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_MODIFY
*&---------------------------------------------------------------------*
FORM f_field_modify .
  DATA : lt_zsextrec TYPE STANDARD TABLE OF zsextrec,
         ls_zsextrec LIKE LINE OF lt_zsextrec.

  SELECT *
    FROM zsextrec
    INTO CORRESPONDING FIELDS OF TABLE lt_zsextrec
    FOR ALL ENTRIES IN i_result
    WHERE vbeln = i_result-vbeln.

  LOOP AT i_result INTO wa_result.
    CLEAR ls_zsextrec.
    READ TABLE lt_zsextrec INTO ls_zsextrec
                           WITH KEY vbeln = wa_result-vbeln.
    IF sy-subrc = 0.
      wa_result-cr2dt = ls_zsextrec-crdat.
      wa_result-cr2tm = ls_zsextrec-crtim.

      PERFORM f_date_calculate USING    wa_result-cr2dt wa_result-erdat_spgd
                                        wa_result-cr2tm wa_result-erzet_spgd
                               CHANGING wa_result-cr2_vs_spgd_dt
                                        wa_result-cr2_vs_spgd_tm.

      PERFORM f_date_calculate USING    wa_result-cr2dt wa_result-wadat_ist
                                        wa_result-cr2tm wa_result-gi_time
                               CHANGING wa_result-cr2_vs_gi_dt
                                        wa_result-cr2_vs_gi_tm.

      PERFORM f_date_calculate USING    wa_result-cr2dt wa_result-erdat
                                        wa_result-cr2tm wa_result-erzet
                               CHANGING wa_result-cr2_create_dt
                                        wa_result-cr2_create_tm.

    ELSE.
      wa_result-cr2dt           = wa_result-crdat.
      wa_result-cr2tm           = wa_result-crtim.
      wa_result-cr2_vs_spgd_dt  = wa_result-cr_vs_spgd_dt.
      wa_result-cr2_vs_spgd_tm  = wa_result-cr_vs_spgd_tm.
      wa_result-cr2_vs_gi_dt    = wa_result-cr_vs_gi_dt.
      wa_result-cr2_vs_gi_tm    = wa_result-cr_vs_gi_tm.
      wa_result-cr2_create_dt   = wa_result-cr_create_dt.
      wa_result-cr2_create_tm   = wa_result-cr_create_tm.
    ENDIF.
    MODIFY i_result FROM wa_result TRANSPORTING cr2_vs_spgd_dt
                                                cr2_vs_spgd_tm
                                                cr2_vs_gi_dt cr2_vs_gi_tm
                                                cr2_create_dt cr2_create_tm
                                                cr2dt cr2tm.
    CLEAR wa_result.
  ENDLOOP.
ENDFORM.                    " F_FIELD_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_DATE_CALCULATE
*&---------------------------------------------------------------------*
FORM f_date_calculate  USING    fu_date1 fu_date2 fu_time1 fu_time2
                       CHANGING fc_date fc_time.
  IF fu_date1 <> '00000000'.
    fc_date = fu_date1 - fu_date2.
    PERFORM f_get_holiday USING fu_date1 fu_date2
                          CHANGING fc_date.
    IF fu_time1 < fu_time2.
      fc_date = fc_date - 1.
    ENDIF.
  ELSE.
    fc_date = 999.
  ENDIF.

  IF fu_date1 <> '000000'.
    fc_time = fu_time1 - fu_time2.
  ENDIF.
ENDFORM.                    " F_DATE_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  CASE 'X'.
    WHEN day.
    WHEN dis.
    WHEN OTHERS.
      CLEAR cr.
  ENDCASE.

*  IF cr IS INITIAL.
  gv_uline  = 163.
*  ELSE.
*    IF day IS NOT INITIAL.
*      gv_uline  = 163.
*    ELSE.
*      gv_uline  = 176.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_163
*&---------------------------------------------------------------------*
FORM f_header_163 .
  WRITE: / sy-uline(gv_uline).
  WRITE: / sy-vline NO-GAP, 'Shpt' NO-GAP,
           sy-vline, 'Group Outlet',
           sy-vline NO-GAP, 'DK/LK' NO-GAP,
           sy-vline NO-GAP, 'Cust.Group' NO-GAP,
           sy-vline, (18) 'Name',
           sy-vline, (10) 'Target',
           sy-vline, (10) '0 hari',
           sy-vline, (10) '1 hari',
           sy-vline, (10) '2 hari',
           sy-vline, (10) '3 hari',
           sy-vline, (10) '> 3 hari',
           sy-vline, (10) 'Total',
           sy-vline, (10) '% STD',
           sy-vline.
ENDFORM.                    " F_HEADER_163

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_176
*&---------------------------------------------------------------------*
FORM f_header_176 .
  WRITE: / sy-uline(gv_uline).
  WRITE: / sy-vline NO-GAP, 'Shpt' NO-GAP,
           sy-vline, 'Group Outlet',
           sy-vline NO-GAP, 'DK/LK' NO-GAP,
           sy-vline NO-GAP, 'Cust.Group' NO-GAP,
           sy-vline, (18) 'Name',
           sy-vline, (10) 'Target',
           sy-vline, (10) '0 hari',
           sy-vline, (10) '1 hari',
           sy-vline, (10) '2 hari',
           sy-vline, (10) '3 hari',
           sy-vline, (10) '> 3 hari',
           sy-vline, (10) '> 7 hari',
           sy-vline, (10) 'Total',
           sy-vline, (10) '% STD',
           sy-vline.
ENDFORM.                    " F_HEADER_176

*&---------------------------------------------------------------------*
*&      Form  F_TRANSACTION_COUNT
*&---------------------------------------------------------------------*
FORM f_transaction_count  USING    fs_result  LIKE wa_result
                          CHANGING fc_jgi fc_jsh fc_jcr.
  IF fs_result-wadat_ist IS NOT INITIAL.
    ADD 1 TO fc_jgi.
  ENDIF.
  IF fs_result-erdat_spgd IS NOT INITIAL.
    ADD 1 TO fc_jsh.
  ENDIF.
  IF fs_result-crdat IS NOT INITIAL.
    ADD 1 TO fc_jcr.
  ENDIF.
ENDFORM.                    " F_TRANSACTION_COUNT
