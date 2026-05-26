*----------------------------------------------------------------------*
*   INCLUDE ZFNOTA_RETURTOP                                            *
*----------------------------------------------------------------------*
INCLUDE ole2incl.
INCLUDE <icon>.

TYPE-POOLS: meein, icon, vrm.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: vbrk, vbrp, bsid, bsad, kna1, sscrfields, zfppnnrh, zfppnnrh_d, zfppnnrd,
        bsis, bsas, zfnrclose, knvv, vbak, nast, zsrange, zfnrrange, tvkbt.

TYPES: BEGIN OF t_bdc.
         INCLUDE STRUCTURE bdcdata.
       TYPES: END OF t_bdc.
TYPES: BEGIN OF t_messtab.
         INCLUDE STRUCTURE bdcmsgcoll.
       TYPES: END OF t_messtab.

TYPES: BEGIN OF ty_text,
         bukrs TYPE bseg-bukrs,
         vkbur TYPE tvbur-vkbur,
         kunnr TYPE numc10,
         monat TYPE zfppnnrh-monat,
         gjahr TYPE zfppnnrh-gjahr,
         zuonr TYPE bseg-zuonr,
         budat TYPE char10,
         nonr  TYPE zfppnnrh-nonr,
         nrdt  TYPE char10,
         dppnr TYPE char20,
         ppnnr TYPE char20,
         ttlnr TYPE char20,
       END OF ty_text.

TYPES: BEGIN OF ty_data,
         bukrs TYPE bseg-bukrs,
         vkbur TYPE tvbur-vkbur,
         kunnr TYPE kna1-kunnr,
         monat TYPE zfppnnrh-monat,
         gjahr TYPE zfppnnrh-gjahr,
         zuonr TYPE bseg-zuonr,
         budat TYPE zfppnnrd-budat,
         waers TYPE zfppnnrd-waers,
         dppcn TYPE zfppnnrh-dppcn,
         ppncn TYPE zfppnnrh-ppncn,
         ttlcn TYPE zfppnnrh-ttlcn,
         nonr  TYPE zfppnnrh-nonr,
         nrdt  TYPE zfppnnrh-nrdt,
         dppnr TYPE zfppnnrh-dppnr,
         ppnnr TYPE zfppnnrh-ppnnr,
         ttlnr TYPE zfppnnrh-ttlnr,
         vatpr TYPE zfppnnrh-vatpr1,
         vatdt TYPE zfppnnrh-vatdt1,
       END OF ty_data.

TYPES: BEGIN OF ty_out.
         INCLUDE TYPE ty_data.
         TYPES:   icon(4),
       END OF ty_out.

TYPES: BEGIN OF ty_snr.
         INCLUDE TYPE ty_data.
         TYPES:   count TYPE i,
       END OF ty_snr.
TYPES: BEGIN OF ty_sum.
         INCLUDE TYPE ty_data.
         TYPES:   count TYPE i,
       END OF ty_sum.

TYPES: BEGIN OF ty_kna1,
         kunnr   TYPE kna1-kunnr,
         stceg   TYPE kna1-stceg,
         name1   TYPE adrc-name1,
         name_co TYPE adrc-name_co,
       END OF ty_kna1.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS : gc_kunnr  TYPE kunnr VALUE 'TSB8071'.

DATA: va_error     TYPE i,
      va_brcode    LIKE znrmap-brcode,
      va_mixlive   LIKE znrmap-mixlive,
      va_name(100),
      va_perio(6),
      va_proc      TYPE i,
      va_live      LIKE zplbc-live,
      va_stkza     LIKE kna1-stkza,
      va_lock      TYPE i,
      d_alv_desc   LIKE disvariant-text,
      va_amtcn     LIKE vbrk-netwr,
      va_auth      TYPE i,
      name1        LIKE adrc-name1,
      name_co      LIKE adrc-name_co,
      va_gform     LIKE kna1-gform,
      va_fkdat     LIKE vbrk-fkdat,
      va_legacy    TYPE i.

DATA: gv_gsber    TYPE gsber,
      gv_brcod(1).

DATA: va_count      TYPE i,
      va_subrc      TYPE sy-subrc,
      i_bdc         TYPE t_bdc OCCURS 0,
      wa_bdc        TYPE t_bdc,
      i_messtab     TYPE t_messtab OCCURS 0,
      va_doc        TYPE meein_purchase_doc_print,
      va_preview    TYPE i,
      va_commit     TYPE i,
      va_valid      TYPE i,
      va_spld       TYPE usr01-spld,
      va_reprint(1),
      va_nmpem(20),
      va_japem(20),
      va_cabang(20),
      va_vkbur      LIKE knvv-vkbur,
      va_koreksi(1).

RANGES: ra_monat  FOR bsis-monat,
        ra_fkart  FOR vbrk-fkart,
        ra_ranges FOR zfnrrange-range_min.

DATA : gv_vatpr1     LIKE zfppnnrh-vatpr1,
       gv_vatdt1     LIKE zfppnnrh-vatdt1,
       gv_name_co    LIKE zfvato-name_co,
       gv_str_suppl1 LIKE zfvato-str_suppl1,
       gv_str_suppl2 LIKE zfvato-str_suppl2,
       gv_stras      LIKE zfvato-stras,
       gv_stceg      LIKE zfvato-stceg,
       gv_subrc      TYPE sy-subrc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_zfnrcustm OCCURS 0.
        INCLUDE STRUCTURE zfnrcustm.
      DATA: END OF t_zfnrcustm.
DATA: va_valcust LIKE sy-subrc,
      va_retval  LIKE sy-subrc,
      va_ranges  TYPE i.

DATA: BEGIN OF t_zfppnnrdtl OCCURS 0.
        INCLUDE STRUCTURE zfppnnrdtl.
      DATA: END OF t_zfppnnrdtl.

DATA: BEGIN OF t_detail OCCURS 0.
        INCLUDE STRUCTURE zfstnrd.
        DATA:   vkorg      LIKE vbrk-vkorg,
        fkdat      LIKE vbrk-fkdat,
        vkbur      LIKE vbrp-vkbur,
        amtcn      LIKE vbrk-netwr,
        vatcn      LIKE vbrk-netwr,
        account_no LIKE zsl_hsales-account_no,
        ktgrd      LIKE vbrk-ktgrd,
        mwsbk      LIKE vbrk-mwsbk,
        fkart      LIKE vbrk-fkart,
        auart      LIKE vbak-auart,
        aubel      LIKE vbrp-aubel,
        cityc      LIKE vbrk-cityc,
        augru_auft LIKE vbrp-augru_auft.
DATA: END OF t_detail.

DATA: BEGIN OF t_data OCCURS 0.
        INCLUDE STRUCTURE zfstnrd.
        DATA:   vkorg      LIKE vbrk-vkorg,
        fkdat      LIKE vbrk-fkdat,
        vkbur      LIKE vbrp-vkbur,
        amtcn      LIKE vbrk-netwr,
        vatcn      LIKE vbrk-netwr,
        account_no LIKE zsl_hsales-account_no,
        ktgrd      LIKE vbrk-ktgrd,
        mwsbk(15),
        fkart      LIKE vbrk-fkart,
        auart      LIKE vbak-auart,
        aubel      LIKE vbrp-aubel.
DATA: END OF t_data.

DATA: BEGIN OF t_out1 OCCURS 0.
        INCLUDE STRUCTURE t_data.
        DATA: zuonr    LIKE bsis-zuonr,
        check(1).
DATA: END OF t_out1.

DATA: BEGIN OF t_data1 OCCURS 0,
        vrsio   LIKE zfppnnrh-vrsio,
        bukrs   LIKE zfppnnrh-bukrs,
        vkbur   LIKE zfppnnrd-vkbur,
        kunnr   LIKE zfppnnrh-kunnr,
        name1   LIKE zfppnnrh-name1,
        name_co LIKE zfppnnrh-name_co,
        stceg   LIKE zfppnnrh-stceg,
        ktgrd   LIKE vbrk-ktgrd,
        nonr    LIKE zfppnnrh-nonr,
        nrdt    LIKE zfppnnrh-nrdt,
        monat   LIKE zfppnnrh-monat,
        gjahr   LIKE zfppnnrh-gjahr,
        belnr   LIKE zfppnnrd-belnr,
        zuonr   LIKE zfppnnrd-zuonr,
        budat   LIKE zfppnnrd-budat,
        waers   LIKE zfppnnrd-waers,
        dppnr   LIKE zfppnnrh-dppnr,
        ppnnr   LIKE zfppnnrh-ppnnr,
        ttlnr   LIKE zfppnnrh-ttlnr,
        dppcn   LIKE zfppnnrh-dppcn,
        ppncn   LIKE zfppnnrh-ppncn,
        ttlcn   LIKE zfppnnrh-ttlcn,
        belnrrc LIKE zfppnnrh-belnrrc,
        mwsbk   LIKE vbrk-mwsbk,
        fkart   LIKE vbrk-fkart.
DATA: vatpr1 LIKE zfppnnrh-vatpr1,
      vatpr2 LIKE zfppnnrh-vatpr2,
      vatpr3 LIKE zfppnnrh-vatpr3,
      vatpr4 LIKE zfppnnrh-vatpr4.
DATA: nppkp  LIKE kna1-stceg,
      status LIKE zfppnnrd-status,
      zdesc  LIKE zfnrstatus-zdesc,
      refnr  LIKE zfppnnrd-refnr.
DATA: erdt1    TYPE sy-datum,
      vatdtsap TYPE sy-datum,
      vatdt1   TYPE sy-datum.
DATA:   extend(120).
DATA: END OF t_data1.

DATA: BEGIN OF t_vdata OCCURS 0,
        bukrs    LIKE zfppnnrd-bukrs,
        vkbur    LIKE zfppnnrd-vkbur,
        kunnr    LIKE zfppnnrd-kunnr,
        name1    LIKE zfppnnrh-name1,
        name_co  LIKE zfppnnrh-name_co,
        stceg    LIKE zfppnnrh-stceg,
        nppkp    LIKE kna1-stceg,
        monat    LIKE zfppnnrh-monat,
        gjahr    LIKE zfppnnrh-gjahr,
        belnrrc  LIKE zfppnnrh-belnrrc,
        zuonr    LIKE zfppnnrd-zuonr,
        budat    LIKE zfppnnrd-budat,
        ppncn    LIKE zfppnnrh-ppncn,
        ppnnr    LIKE zfppnnrh-ppnnr,
        nonr     LIKE zfppnnrh-nonr,
        nrdt     LIKE zfppnnrh-nrdt,
        status   LIKE zfppnnrd-status,
        refnr    LIKE zfppnnrd-refnr,
        icon(4),
        error(1).
DATA: END OF t_vdata.

DATA: BEGIN OF t_data2 OCCURS 0,
        vbeln      LIKE vbrk-vbeln,
        vbtyp      LIKE vbrk-vbtyp,
        waerk      LIKE vbrk-waerk,
        vkorg      LIKE vbrk-vkorg,
        fkdat      LIKE vbrk-fkdat,
        netwr      LIKE vbrk-netwr,
        kunrg      LIKE vbrk-kunrg,
        vkbur      LIKE vbrp-vkbur,
        amtcn      LIKE vbrk-netwr,
        vatcn      LIKE vbrk-netwr,
        account_no LIKE zsl_hsales-account_no,
        stceg      LIKE vbrk-stceg,
        ktgrd      LIKE vbrk-ktgrd,
        mwsbk      LIKE vbrk-mwsbk,
        fkart      LIKE vbrk-fkart,
        auart      LIKE vbak-auart,
        aubel      LIKE vbrp-aubel,
        cityc      LIKE vbrk-cityc,
        augru_auft LIKE vbrp-augru_auft.
DATA: END OF t_data2.

DATA: BEGIN OF t_zfppnnrh OCCURS 0.
        INCLUDE STRUCTURE zfppnnrh.
        DATA: vkbur  LIKE zfppnnrd-vkbur,
        status LIKE zfppnnrd-status,
        belnr  LIKE zfppnnrd-belnr.
DATA: END OF t_zfppnnrh.

DATA: BEGIN OF t_close OCCURS 0.
        INCLUDE STRUCTURE zfnrclose.
      DATA: END OF t_close.

DATA: BEGIN OF t_zfnrvalid OCCURS 0.
        INCLUDE STRUCTURE zfnrvalid.
      DATA: END OF t_zfnrvalid.

DATA: BEGIN OF t_out2 OCCURS 0.
        INCLUDE STRUCTURE t_zfppnnrh.
        DATA: zuonr    LIKE bsis-zuonr,
        check(1).
DATA: END OF t_out2.

DATA: BEGIN OF t_delete OCCURS 0.
        INCLUDE STRUCTURE zfppnnrh_d.
      DATA: END OF t_delete.

DATA: BEGIN OF t_zfppnnrd OCCURS 0.
        INCLUDE STRUCTURE zfppnnrd.
      DATA: END OF t_zfppnnrd.
DATA: BEGIN OF t_zfppnnrh_d OCCURS 0.
        INCLUDE STRUCTURE zfppnnrh_d.
        DATA:   extend(120).
DATA: END OF t_zfppnnrh_d.

DATA: BEGIN OF t_kna1 OCCURS 0,
        kunnr   LIKE kna1-kunnr,
        name1   LIKE kna1-name1,
        stceg   LIKE kna1-stceg,
        sortl   LIKE kna1-sortl,
        gform   LIKE kna1-gform,
        stkza   LIKE kna1-stkza,
        name_co LIKE adrc-name_co.
DATA: END OF t_kna1.

DATA: BEGIN OF t_knvv OCCURS 0.
        INCLUDE STRUCTURE knvv.
      DATA: END OF t_knvv.

DATA: BEGIN OF t_data_tab OCCURS 0,
        data_tab(750).
DATA: END OF t_data_tab.

DATA: BEGIN OF t_record OCCURS 0,
        brcod(1),
        type(2),
        outgr(1),
        outcd(6),
        nomor(50),
        tanggal(8),
        bln(2),
        thn(4),
        ktr1(30),
        ktr2(30),
        dpp(15),
        ppn(15),
        total(15),
        seq1(1),
        dok1(6),
        tgl1(8),
        ket1(30),
        val1(15),
        seq2(1),
        dok2(6),
        tgl2(8),
        ket2(30),
        val2(15),
        seq3(1),
        dok3(6),
        tgl3(8),
        ket3(30),
        val3(15),
        seq4(1),
        dok4(6),
        tgl4(8),
        ket4(30),
        val4(15),
        seq5(1),
        dok5(6),
        tgl5(8),
        ket5(30),
        val5(15),
        seq6(1),
        dok6(6),
        tgl6(8),
        ket6(30),
        val6(15),
        seq7(1),
        dok7(6),
        tgl7(8),
        ket7(30),
        val7(15),
        seq8(1),
        dok8(6),
        tgl8(8),
        ket8(30),
        val8(15),
        seq9(1),
        dok9(6),
        tgl9(8),
        ket9(30),
        val9(15),
        userid(3),
        waktu(15),
        status(1),
        kdpjk(2).
DATA: END OF t_record.

DATA: BEGIN OF t_record1 OCCURS 0.
        INCLUDE STRUCTURE t_record.
        DATA: kunnr        LIKE kna1-kunnr,
        name1        LIKE adrc-name1,
        stceg        LIKE kna1-stceg,
        beln1        LIKE zfppnnrd-belnr,
        beln2        LIKE zfppnnrd-belnr,
        beln3        LIKE zfppnnrd-belnr,
        beln4        LIKE zfppnnrd-belnr,
        beln5        LIKE zfppnnrd-belnr,
        beln6        LIKE zfppnnrd-belnr,
        beln7        LIKE zfppnnrd-belnr,
        beln8        LIKE zfppnnrd-belnr,
        beln9        LIKE zfppnnrd-belnr,
        vatpr1       LIKE zfppnnrh-vatpr1,
        vatpr2       LIKE zfppnnrh-vatpr2,
        vatpr3       LIKE zfppnnrh-vatpr3,
        vatpr4       LIKE zfppnnrh-vatpr4,
        message(100).
DATA: END OF t_record1.
DATA: BEGIN OF t_count OCCURS 0,
        kunnr LIKE kna1-kunnr,
        nonr  LIKE zfppnnrh-nonr,
        count TYPE i.
DATA: END OF t_count.

DATA: BEGIN OF t_out3 OCCURS 0.
        INCLUDE STRUCTURE t_zfppnnrh.
        DATA: check(1),
        icon(4),
        icon1(4),
        message(100).
DATA: END OF t_out3.

DATA: BEGIN OF t_vbrk OCCURS 0.
        INCLUDE STRUCTURE vbrk.
      DATA: END OF t_vbrk.

DATA: BEGIN OF t_zsl_hsales OCCURS 0.
        INCLUDE STRUCTURE zsl_hsales.
      DATA: END OF t_zsl_hsales.

DATA: BEGIN OF t_zsl_dsales OCCURS 0.
        INCLUDE STRUCTURE zsl_dsales.
      DATA: END OF t_zsl_dsales.
DATA: BEGIN OF t_matnr OCCURS 0.
        INCLUDE STRUCTURE t_zsl_dsales.
      DATA: END OF t_matnr.
DATA: BEGIN OF t_matnr1 OCCURS 0.
        INCLUDE STRUCTURE t_detail.
      DATA: END OF t_matnr1.
DATA: BEGIN OF t_mara OCCURS 0,
        matnr LIKE mara-matnr,
        meins LIKE mara-meins,
        maktx LIKE makt-maktx.
DATA: END OF t_mara.

DATA: BEGIN OF t_out4 OCCURS 0.
        INCLUDE STRUCTURE t_data1.
      DATA: END OF t_out4.

DATA: BEGIN OF t_out5 OCCURS 0.
        INCLUDE STRUCTURE t_zfppnnrh.
        DATA: selisih  LIKE zfppnnrh-ppnnr,
        hkont    LIKE bsis-hkont,
        check(1),
        icon(4),
        msg(100).
DATA: END OF t_out5.

DATA: BEGIN OF t_out6 OCCURS 0.
        INCLUDE STRUCTURE zfstnrd.
      DATA: END OF t_out6.

DATA: BEGIN OF t_subtotal OCCURS 0.
        INCLUDE STRUCTURE zfstnrd.
      DATA: END OF t_subtotal.

DATA: BEGIN OF t_error OCCURS 0.
        INCLUDE STRUCTURE t_zfppnnrh.
        DATA: msg(100).
DATA: END OF t_error.
DATA: BEGIN OF t_error1 OCCURS 0.
        INCLUDE STRUCTURE t_data.
        DATA: msg(100).
DATA: END OF t_error1.
DATA: BEGIN OF t_error2 OCCURS 0.
        INCLUDE STRUCTURE zsl_hsales.
        DATA: msg(100).
DATA: END OF t_error2.
DATA: BEGIN OF t_error3 OCCURS 0.
        INCLUDE STRUCTURE t_vdata.
        DATA: msg(100).
DATA: END OF t_error3.

DATA: BEGIN OF t_zfnrhkont OCCURS 0.
        INCLUDE STRUCTURE zfnrhkont.
      DATA: END OF t_zfnrhkont.

DATA: BEGIN OF t_bsis OCCURS 0.
        INCLUDE STRUCTURE bsis.
      DATA: END OF t_bsis.

DATA: BEGIN OF t_faktur OCCURS 0,
        nonr   LIKE zfppnnrh-nonr,
        faktur LIKE tline-tdline.
DATA: END OF t_faktur.

DATA: BEGIN OF t_zfnrrange OCCURS 0.
        INCLUDE STRUCTURE zfnrrange.
      DATA: END OF t_zfnrrange.

DATA: t_zfnrstatus  LIKE zfnrstatus OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_radio11 OCCURS 0.
*        bukrs   LIKE zfppnnrh-bukrs,
*        vkbur   LIKE zfppnnrd-vkbur,
*        kunnr(10),
*        monat   LIKE zfppnnrh-monat,
*        gjahr   LIKE zfppnnrh-gjahr,
*        belnr   LIKE zfppnnrd-belnr,
*        zuonr   LIKE zfppnnrd-zuonr,
*        budat   LIKE zfppnnrd-budat,
*        nonr    LIKE zfppnnrd-nonr,
*        nrdt    LIKE zfppnnrd-nrdt,
*        status  LIKE zfppnnrd-status,
*        zdesc   LIKE zfnrstatus-zdesc,
*        refnr   LIKE zfppnnrd-refnr.
        INCLUDE STRUCTURE t_data1.
      DATA: END OF t_radio11.

DATA: BEGIN OF t_excel OCCURS 0,
        row   LIKE alsmex_tabline-row,
        col   LIKE alsmex_tabline-col,
        value LIKE alsmex_tabline-value.
DATA: END OF t_excel.

DATA: BEGIN OF t_vatno OCCURS 0,
        zuonr LIKE zfvato-zuonr,
        dudat LIKE zfvato-dudat,
        vatpr LIKE zfvato-vatpr.
DATA: END OF t_vatno.

DATA: vrmnm TYPE vrm_id,
      vrmls TYPE vrm_values,
      value LIKE LINE OF vrmls.

DATA: p_tdform LIKE ssfscreen-fname VALUE 'ZFNOTA_RETUR_FORM',
      p_disp   LIKE ssfctrlop-preview VALUE 'X'.

DATA: BEGIN OF t_header OCCURS 0.
        INCLUDE STRUCTURE zfstnrh.
      DATA: END OF t_header.
DATA: wa_header TYPE zfstnrh.

DATA: t_alamat TYPE zgdtxdt0005 OCCURS 0 WITH HEADER LINE.
DATA: t_zfstppnnr TYPE TABLE OF zfstppnnr WITH HEADER LINE.

DATA: document_output_info TYPE ssfcrespd,
      job_output_info      TYPE ssfcrescl,
      job_output_options   TYPE ssfcresop.

DATA: va_nonr       LIKE zfppnnrh-nonr,
      va_zuonr      LIKE zfppnnrd-zuonr,
*      va_kunnr(10),
      va_kunnr      LIKE zfppnnrd-kunnr,
      va_monat      LIKE zfppnnrd-monat,
      va_gjahr      LIKE zfppnnrd-gjahr,
      va_belnr      LIKE zfppnnrd-belnr,
      va_name1      LIKE adrc-name1,
      va_alamat     LIKE adrc-str_suppl1,
      va_kota(100),
      va_npwp       LIKE kna1-stceg,
      va_nppkp      LIKE kna1-stceg,
      va_status     LIKE zfppnnrd-status,
      va_zdesc      LIKE zfnrstatus-zdesc,
      va_refnr      LIKE zfppnnrd-refnr,
      va_usrgrp     LIKE usgrp_user-usergroup,
      wa_zfnrcncust LIKE zfnrcncust.

DATA: h_excel TYPE ole2_object,        " Excel object
      h_mapl  TYPE ole2_object,        " list of workbooks
      h_map   TYPE ole2_object,        " workbook
      h_zl    TYPE ole2_object,        " cell
      h_f     TYPE ole2_object.        " font

DATA: BEGIN OF gt_excel OCCURS 0,
        row   TYPE kcd_ex_row_n,
        col   TYPE kcd_ex_col_n,
        value TYPE char50,
      END OF gt_excel.

DATA: gt_data       TYPE STANDARD TABLE OF ty_data,
      gt_out        TYPE STANDARD TABLE OF ty_out,
      gt_kna1       TYPE STANDARD TABLE OF ty_kna1,
      gt_bapiret2   TYPE STANDARD TABLE OF bapiret2,
      gt_zfppnnrh   TYPE STANDARD TABLE OF zfppnnrh,
      gt_zfppnnrd   TYPE STANDARD TABLE OF zfppnnrd,
      gt_zfppnnrdtl TYPE STANDARD TABLE OF zfppnnrdtl,
      gt_vbrk       TYPE STANDARD TABLE OF vbrk,
      gt_vbrp       TYPE STANDARD TABLE OF vbrp.

DATA : gt_sum         TYPE STANDARD TABLE OF ty_sum.

DATA: gv_extension TYPE pc_fext,
      gt_text      TYPE STANDARD TABLE OF ty_text.
