*----------------------------------------------------------------------*
*   Comments by Rama                                             *
*----------------------------------------------------------------------*
* Cleanup equipment related code.
* Cleanup Kwitansi related code
* Cleanup Karoseri related code
* Cleanup use of Item category
*


*---




*----------------------------------------------------------------------*
*   INCLUDE ZGDTXFORMSF01                                             *
*----------------------------------------------------------------------*
* This is a common include for TAX SYSTEM programs, consisting of      *
* common routines, macros and variables that might be used by tax-     *
* related programs.                                                    *
*----------------------------------------------------------------------*
* Developed by                                                         *
* - IBM                                                                *
*----------------------------------------------------------------------*
*INCLUDES
INCLUDE zstdxin_atz.   "authorization
* INCLUDE zfaca_e00002.

* For screen manual entry
TABLES: rv60a,
        rm06e.
TABLES: bsad, bsid.
* For Foreign Currency
TABLES: tcurf.

*TABLES
TABLES: vbrk , vbrp, vbak, mara, makt, kna1, equi, equz, bseg, bkpf,
        tvkbt,           " Table text Sales Office.
        tvkot,           " Table text Sales Organisation
        tspat,           " Table text Division
        vbpa , adrc, nriv, inroi,
*        ZGDTXdt0001,
        zgdtxdt0002,
        zgdtxdt0003,
        zgdtxdt0004,
        zgdtxdt0005,
*        ZGDTXdt0006,
        zgdtxdt0007,
        zgdtxdt0008,
        zgdtxdt0009,
*        ZGDTXdt0010,
        zgdtxdt0011,
        zgdtxdt0012,
        zgdtxdt0101,
        zgdtxdt0102,
        zgdtxdt0103,
        zgdtxdt0104,
        zgdtxdt0105,
        zgdtxdt0106,
        zgdtxdt0107.

TABLES : zscust_control.
* TABLES:zfafdt_cashhead, zfafdt_cashcler,
*         zfafdt_tgsber, ZFALDT_PLANTREF.

**CONSTANTS
CONSTANTS :
**T-codes
  c_tcode_sederhana           LIKE sy-tcode  VALUE 'ZGDTXE0002_01',
  c_tcode_satuan              LIKE sy-tcode  VALUE 'ZGDTXE0002',
  c_tcode_gabungan            LIKE sy-tcode  VALUE 'ZGDTXE0003',
  c_tcode_split               LIKE sy-tcode  VALUE 'ZGDTXE0004',
  c_tcode_rpc                 LIKE sy-tcode  VALUE 'ZGDTXE0014',
  c_tcode_period_end_satuan   LIKE sy-tcode  VALUE 'ZGDTXE0002_02',
  c_tcode_period_end_gabungan LIKE sy-tcode  VALUE 'ZGDTXE0003_02',
  c_tcode_period_end_split    LIKE sy-tcode  VALUE 'ZGDTXE0004_02',
  c_tcode_sederhana_single    LIKE sy-tcode  VALUE 'ZGDTXE0002_03',
  c_tcode_sdh_to_standard     LIKE sy-tcode  VALUE 'ZGDTXE0019',
*Added - Handling process Gabungan Otomatis
  c_tcode_gabungan_otomatis   LIKE sy-tcode  VALUE 'ZGDTXE0028_2',
  c_tcode_gabungan_otoakhir   LIKE sy-tcode  VALUE 'ZGDTXE0028',
*End Add

*Maximum number of records for one step selection in ranges
  c_max_ritems                LIKE  sy-tabix VALUE 150,
  c_max_ritems_max            LIKE  sy-tabix VALUE 5000,
**Billing status
  c_status_cancel(10)         VALUE 'Cancelled',
  c_status_ok(10)             VALUE 'OK',
  c_cancel_prefix(5)          VALUE 'BATAL',

**Faktur type
  c_faktur_type_satuan        LIKE zgdtxdt0003-faktur_type VALUE 'S',
  c_faktur_type_gabungan      LIKE zgdtxdt0003-faktur_type VALUE 'G',
  c_faktur_type_split_amount  LIKE zgdtxdt0003-faktur_type VALUE 'A',
  c_faktur_type_split_item    LIKE zgdtxdt0003-faktur_type VALUE 'I',
  c_faktur_type_split_qty     LIKE zgdtxdt0003-faktur_type VALUE 'Q',

**Faktur text
  c_gab_unit1(4)              TYPE c VALUE 'UNIT',
  c_gab_unit2(9)              TYPE c VALUE 'Terlampir',
  c_gab_sparepart(40)         TYPE c VALUE 'SPAREPART Terlampir',
  c_gab_serv_jasa1(40)        TYPE c VALUE 'SESUAI NOTA JASA',
  c_gab_no(40)                TYPE c VALUE 'NOTA JASA ( Terlampir )',
  c_gab_tgl(4)                TYPE c VALUE 'TGL',
  c_gab_serv_jasa2(40)        TYPE c VALUE 'NOTA JASA BENGKEL ( Terlampir )',
  c_gab_serv_part1(40)        TYPE c VALUE 'SESUAI NOTA BARANG',
  c_gab_serv_contr(40)        TYPE c VALUE 'SESUAI BILLING',
  c_gab_serv_part2(40)        TYPE c VALUE 'NO: ',
  c_prctr10(10)               TYPE c VALUE 'KTB',
  c_prctr20(10)               TYPE c VALUE 'MKM',
  c_prctr30(10)               TYPE c VALUE 'KKM',
  c_trlp(13)                  TYPE c VALUE '( Terlampir )',
  c_kwitansi                  TYPE i VALUE '2',

  c_split_unit(4)             TYPE c VALUE 'UNIT',
  c_split_sparepart(40)       TYPE c VALUE 'SPAREPART Terlampir',
  c_split_serv_jasa1(40)      TYPE c VALUE 'SESUAI KWITANSI',
  c_split_serv_jasa2(40)      TYPE c VALUE 'NO:',
  c_split_serv_jasa3(40)      TYPE c VALUE '( Terlampir )',

  c_split_serv_part1(40)      TYPE c VALUE 'SESUAI NOTA BARANG',
  c_split_serv_part2(40)      TYPE c VALUE 'NO:',
  c_split_serv_parts3(40)     TYPE c VALUE '( Terlampir )',
  c_spltamount_fakturno_vbrk  LIKE zgdtxdt0003-fakturno
                                 VALUE 'SPLIT BY AMOUNT',

**Sales Org
  c_vkorg_kkm                 LIKE vbrk-vkorg VALUE '0002',
  c_vkorg_ktb                 LIKE vbrk-vkorg VALUE 'S200',        "'0005',
  c_vkorg_mkm                 LIKE vbrk-vkorg VALUE '0004',
  c_vkorg_ho                  LIKE vbrk-vkorg VALUE '0001',

**Item Category
  c_pstyv_service             LIKE vbrp-pstyv VALUE 'ZRIN',
  c_pstyv_service1            LIKE vbrp-pstyv VALUE 'ZPZH',
  c_pstyv_parts               LIKE vbrp-pstyv VALUE 'ZRRA',
  c_pstyv_parts1              LIKE vbrp-pstyv VALUE 'ZSEN',
  c_pstyv_parts2              LIKE vbrp-pstyv VALUE 'ZSAO',
  c_pstyv_parts3              LIKE vbrp-pstyv VALUE 'ZTAN',
  c_pstyv_parts4              LIKE vbrp-pstyv VALUE 'ZTAO',
  c_pstyv_contr               LIKE vbrp-pstyv VALUE 'ZWVD',
  c_pstyv_contr1              LIKE vbrp-pstyv VALUE 'ZWVN',
  c_pstyv_free                LIKE vbrp-pstyv VALUE 'ZTNN',


**On Help Request
  c_on_help_request_code      LIKE dokhl-object VALUE 'ZGDTX_HELP_CODE',
  c_on_help_request_tax       LIKE dokhl-object VALUE 'ZGDTX_HELP_INCL_TAX',

**Error type
  c_error_karoseri(15)        VALUE 'KAROSERI'.

**Business area
DATA  d_gsber_common     LIKE vbrp-gsber          VALUE '1111'.

**Division
DATA  d_fin_unit         LIKE vbrp-spart          VALUE '00'. "01
DATA  d_sparts           LIKE vbrp-spart          VALUE '02'. "02
DATA  d_service          LIKE vbrp-spart          VALUE '03'. "03
DATA  d_used             LIKE vbrp-spart          VALUE '04'. "04
DATA  d_truck            LIKE vbrp-spart          VALUE '05'. "05
DATA  d_others           LIKE zgdtxdt0102-busln   VALUE '99'. "99
DATA  d_busds            LIKE zgdtxdt0102-busds.
DATA  d_bdesc            LIKE zgdtxdt0101-bdesc.
DATA  d_hoind            LIKE zgdtxdt0101-ho_ind.
DATA  d_smtxt            LIKE zgdtxdt0103-smtxt.
DATA  d_smtxt1           LIKE zgdtxdt0103-smtxt1.
DATA  d_smtxt2           LIKE zgdtxdt0103-smtxt2.
DATA  d_flag.
DATA  d_pkpfl            LIKE zgdtxdt0103-pkpfl.
DATA  d_lock_subrc       LIKE sy-subrc.

**Price type
DATA  d_ptype_mex        LIKE zgdtxdt0008-ptype VALUE 'ME'.
DATA  d_ptype_min        LIKE zgdtxdt0008-ptype VALUE 'MI'.
DATA  d_ptype_vatout     LIKE zgdtxdt0008-ptype VALUE 'VO'.
DATA  d_ptype_vatin      LIKE zgdtxdt0008-ptype VALUE 'VI'.
DATA  d_ptype_pex        LIKE zgdtxdt0008-ptype VALUE 'PE'.
DATA  d_ptype_pin        LIKE zgdtxdt0008-ptype VALUE 'PI'.
DATA  d_ptype_dex        LIKE zgdtxdt0008-ptype VALUE 'DE'.
DATA  d_ptype_din        LIKE zgdtxdt0008-ptype VALUE 'DI'.
DATA  d_ptype_ppnbm      LIKE zgdtxdt0008-ptype VALUE 'BM'.
DATA  d_ptype_xppnbm     LIKE zgdtxdt0008-ptype VALUE 'XP'.
DATA  d_ptype_other      LIKE zgdtxdt0008-ptype VALUE 'OT'.
DATA  d_ptype_stnk       LIKE zgdtxdt0008-ptype VALUE 'ST'.
DATA  d_ptype_npex       LIKE zgdtxdt0008-ptype VALUE 'NP'.
DATA  d_ptype_npin       LIKE zgdtxdt0008-ptype VALUE 'NJ'.
DATA  d_ptype_nz         LIKE zgdtxdt0008-ptype VALUE 'NZ'.
DATA  d_ptype_pl         LIKE zgdtxdt0008-ptype VALUE 'PL'.
DATA  d_ptype_taxin      LIKE zgdtxdt0008-ptype VALUE 'VZ'.
DATA  d_ptype_ndex       LIKE zgdtxdt0008-ptype VALUE 'ND'.
DATA  d_ptype_ndin       LIKE zgdtxdt0008-ptype VALUE 'NW'.
DATA  d_ptype_nother     LIKE zgdtxdt0008-ptype VALUE 'NO'.
DATA  d_ptype_pph22      LIKE zgdtxdt0008-ptype VALUE 'W2'.
DATA  d_ptype_pph23      LIKE zgdtxdt0008-ptype VALUE 'W3'.
DATA  d_tx04_lock_subrc  LIKE sy-subrc.

**Price tax inclusion/exclusion indicator
DATA  d_include_tax                               VALUE 'I'.
DATA  d_exclude_tax                               VALUE 'E'.

*-------- Subject to change to be configurable ---------------------*
**Material group
DATA  d_accsopt          LIKE mara-matkl          VALUE 'ACCS-OPT'.
DATA  d_karoseri         LIKE mara-matkl          VALUE 'KAROSERI'.

**Material type
DATA  d_zfin             LIKE mara-mtart          VALUE 'ZCBU'. "'ZFIN'.
*-------------------------------------------------------------------*

**Karoseri
DATA  d_kara             VALUE 'A'.  "Accessories
DATA  d_kark             VALUE 'K'.  "Karoseri
DATA  d_karu             VALUE 'U'.  "Unit

**Tax divider
DATA  d_taxfactor        TYPE i      VALUE '1000'.

**Divider factor(if tax must be divided by 10)
DATA  d_dpp_divider   TYPE i         VALUE '10'.

**Partner Function
DATA  d_stnk             LIKE vbpa-parvw VALUE 'ZP'.
DATA  d_payer            LIKE vbpa-parvw VALUE 'RG'.
DATA  d_ship_to_party    LIKE vbpa-parvw VALUE 'WE'.
DATA  d_sold_to_party    LIKE vbpa-parvw VALUE 'AG'.
DATA  d_faktur_pajak     LIKE vbpa-parvw VALUE 'Z2'.

**WAPU
DATA  d_w VALUE 'W'.
DATA  d_n VALUE 'N'.

**Form
DATA  d_a1 LIKE zgdtxdt0003-form VALUE 'A1'.
DATA  d_a3 LIKE zgdtxdt0003-form VALUE 'A3'.
DATA  d_a5 LIKE zgdtxdt0003-form VALUE 'A5'.

**VSPO
DATA  d_vspo_common(4) VALUE '1111'.

**PKP officer
DATA  d_aktif1 LIKE zgdtxdt0005-aktif VALUE '1'.
DATA  d_aktif2 LIKE zgdtxdt0005-aktif VALUE '2'.
DATA  d_aktif3 LIKE zgdtxdt0005-aktif VALUE '3'.
DATA  d_aktif4 LIKE zgdtxdt0005-aktif VALUE '4'.
DATA  d_aktif5 LIKE zgdtxdt0005-aktif VALUE '5'.

**Number range object
DATA  d_noret_object LIKE nriv-object VALUE 'ZGDTXRTR'.

**Branch officer
DATA  c_name_kaadm(5) VALUE 'KaADM'.
DATA  c_name_kacab(5) VALUE 'KaCAB'.
DATA  c_jab_kaadm(6)  VALUE 'JbtADM'.
DATA  c_jab_kacab(6)  VALUE 'JbtCAB'.

**Local Currency
DATA  c_local_curr LIKE zgdtxdt0002-itcurr VALUE 'IDR'.
DATA  d_tax_valid  LIKE sy-datum.
DATA  d_rate_tax   LIKE zgdtxdt0002-rate_tax.
DATA  d_rate_std   LIKE zgdtxdt0002-rate_std.
DATA  d_ratefactor LIKE tcurr-tfact.
DATA  d_forfactor LIKE tcurr-tfact.

**Printing mode
DATA  d_prev_first  VALUE 'P'.
DATA  d_direct_save VALUE 'S'.

**VARIABLES
DATA  d_line_count TYPE i.       " screen line count
DATA  d_printx.                   " set to 'X' if faktur is printed
DATA  d_tcode      LIKE sy-tcode.
DATA  d_rpc.                     " set to 'X' if executed by RPC program
*Foreign Currency for RPC. Get original tax rate for RPC
DATA  d_rpc_ratestd LIKE zgdtxdt0002-rate_std.
DATA  d_rpc_ratetax LIKE zgdtxdt0002-rate_tax.

DATA  d_period_end.              " set to 'X' if executed for PERIOD END
DATA  d_pstyv.                   " item category from RPC
DATA  d_petugas    LIKE zgdtxdt0005-petugas.
DATA  d_petugas2   LIKE zgdtxdt0005-petugas2.
DATA  d_petugas_e  LIKE zgdtxdt0005-petugas.
DATA  d_jabat_e    LIKE zgdtxdt0005-jabat.
DATA  d_jabat      LIKE zgdtxdt0005-jabat.
DATA  d_jabat2     LIKE zgdtxdt0005-jabat2.
DATA  d_aktif      LIKE zgdtxdt0005-aktif.
DATA  d_fpone      LIKE zgdtxdt0005-fpone.
DATA  d_fptwo      LIKE zgdtxdt0005-fptwo.
DATA  d_objrange   LIKE nriv-object.
DATA  d_dynnr      LIKE sy-dynnr.
DATA  d_name_kaadm LIKE zgdtxdt0005-petugas.
DATA  d_name_kacab LIKE zgdtxdt0005-petugas.
DATA  d_kaadm      LIKE zgdtxdt0005-jabat.
DATA  d_kacab      LIKE zgdtxdt0005-jabat.
DATA  d_coretax    LIKE zgdtxdt0005-coretax.

DATA: d_hpetugas   LIKE zgdtxdt0005-petugas,
      d_hpetugas2  LIKE zgdtxdt0005-petugas2,
      d_haktif     LIKE zgdtxdt0005-aktif,
      d_hjabat     LIKE zgdtxdt0005-jabat,
      d_hjabat2    LIKE zgdtxdt0005-jabat2,
      d_hfpone     LIKE zgdtxdt0005-fpone,
      d_hfptwo     LIKE zgdtxdt0005-fptwo,
      d_hobjrange  LIKE nriv-object,
      d_hpkpnpwp   LIKE zgdtxdt0005-pkpnpwp,
      d_hpkpname   LIKE zgdtxdt0005-pkpname,
      d_hpkpaddrs1 LIKE zgdtxdt0005-pkpaddrs1,
      d_hpkpaddrs2 LIKE zgdtxdt0005-pkpaddrs2,
      d_hpkpkuh    LIKE zgdtxdt0005-pkpkuh,
      d_hpkpcity   LIKE zgdtxdt0005-pkpcity,
      d_hpkppostal LIKE zgdtxdt0005-pkppostal,
      d_hnr_gsber  LIKE vbrp-gsber,
      d_hnr_brnch  LIKE zgdtxdt0101-brnch,
      d_subrcp     LIKE sy-subrc.

DATA: d_bpetugas   LIKE zgdtxdt0005-petugas,
      d_bpetugas2  LIKE zgdtxdt0005-petugas2,
      d_baktif     LIKE zgdtxdt0005-aktif,
      d_bjabat     LIKE zgdtxdt0005-jabat,
      d_bjabat2    LIKE zgdtxdt0005-jabat2,
      d_bfpone     LIKE zgdtxdt0005-fpone,
      d_bfptwo     LIKE zgdtxdt0005-fptwo,
      d_bobjrange  LIKE nriv-object,
      d_bpkpnpwp   LIKE zgdtxdt0005-pkpnpwp,
      d_bpkpname   LIKE zgdtxdt0005-pkpname,
      d_bpkpaddrs1 LIKE zgdtxdt0005-pkpaddrs1,
      d_bpkpaddrs2 LIKE zgdtxdt0005-pkpaddrs2,
      d_bpkpkuh    LIKE zgdtxdt0005-pkpkuh,
      d_bpkpcity   LIKE zgdtxdt0005-pkpcity,
      d_bpkppostal LIKE zgdtxdt0005-pkppostal,
      d_bnr_gsber  LIKE vbrp-gsber,
      d_bnr_brnch  LIKE zgdtxdt0101-brnch.


DATA: d_des_cc     LIKE t001-butxt,
      d_des_bs     LIKE v_tgsb-gtext,
      d_des_dv     LIKE v_tspa-vtext,
      d_des_vk     LIKE tvkot-vtext,
      d_des_br     LIKE zgdtxdt0101-bdesc,
      d_des_bl     LIKE zgdtxdt0102-busds,
      d_pkpname    LIKE zgdtxdt0005-pkpname,
      d_pkpnpwp    LIKE zgdtxdt0005-pkpnpwp,
      d_pkpaddrs1  LIKE zgdtxdt0005-pkpaddrs1,
      d_pkpaddrs2  LIKE zgdtxdt0005-pkpaddrs2,
      d_pkpkuh     LIKE zgdtxdt0005-pkpkuh,
      d_pkpcity    LIKE zgdtxdt0005-pkpcity,
      d_pkppostal  LIKE zgdtxdt0005-pkppostal,
      d_kunnr      LIKE vbrk-kunrg,
      d_stceg      LIKE vbrk-stceg,
      d_name1      LIKE kna1-name1,
      d_stras      LIKE kna1-stras,
      d_subrc      LIKE sy-subrc,
      d_recnonlive LIKE zgdtxdt0002-rectype,
      sp_rb_act1,                              "radio button for gab
      sp_rb_act2,                              "radio button for gab
      sp_rb_act3,                              "radio button for gab
      sp_rb_act4,                              "radio button for gab
      sp_rb_act5,                              "radio button for gab
      d_nr_gsber   LIKE vbrp-gsber,             "GSBER for Number ranges
      d_nr_brnch   LIKE zgdtxdt0101-brnch.

**SCREEN RADIOBUTTONS
DATA: r_act1, r_act2, r_act3, r_act4, r_act5.

***added by Rahmadi
**BUSINESS LINE
DATA: d_busln_others LIKE zgdtxdt0102-busln VALUE '99'.

**NON-TRADE DATA
DATA: d_fkart_arnt LIKE zgdtxdt0002-fkart VALUE 'ARNT',
      d_fkart_arnr LIKE zgdtxdt0002-fkart VALUE 'ARNR'.
***end of addition

**INTERNAL TABLES
**Internal tables for PRINTING FUNCTION passing parameters
DATA:
  t_fpkp        TYPE STANDARD TABLE OF zgdtxst0001 WITH HEADER LINE,
  t_fcustomer   TYPE STANDARD TABLE OF zgdtxst0002 WITH HEADER LINE,
  t_fitem       TYPE STANDARD TABLE OF zgdtxst0003 WITH HEADER LINE,
  t_fsignature  TYPE STANDARD TABLE OF zgdtxst0005 WITH HEADER LINE,
  t_ftax        TYPE STANDARD TABLE OF zgdtxst0006 WITH HEADER LINE,

**Internal tables for updating tax tables - ZFA..02/03
  t_zgdtxdt0002 TYPE STANDARD TABLE OF zgdtxdt0002 WITH HEADER LINE,
  t_zgdtxdt0003 TYPE STANDARD TABLE OF zgdtxdt0003 WITH HEADER LINE,
  t_zgdtxdt0011 TYPE STANDARD TABLE OF zgdtxdt0011 WITH HEADER LINE.

DATA  BEGIN OF t_txdt0002 OCCURS 1.
INCLUDE STRUCTURE zgdtxdt0002.
DATA  END   OF t_txdt0002.

**MAIN Internal table -- Billing Internal table
**containing NORMAL billings gathered from SAP system
DATA  BEGIN OF t_vbrk OCCURS 1.
INCLUDE STRUCTURE zgdtxst0007.
*DATA:   vbeln        LIKE vbrk-vbeln,
*        posnr        LIKE vbrp-posnr,
*        splitno      LIKE ZGDTXdt0002-splitno,
*        matnr        LIKE vbrp-matnr,
*        fkart        LIKE vbrk-fkart,
*        waerk        LIKE vbrk-waerk,
** Organisation Code
*        vkorg        LIKE vbrk-vkorg,
*        spart        LIKE vbrk-spart,
*        gsber        LIKE vbrp-gsber,
*        prctr        LIKE vbrp-prctr,
*        werks        LIKE vbrp-werks,
** Tax Organisation Codes
*        bukrs        LIKE vbrk-bukrs,
**       --- Added by Rama from IBM
*        brnch        LIKE ZGDTXdt0002-brnch,
*        busln        LIKE ZGDTXdt0002-busln,
*
** Grouping OF Items, This flag will indicate the posnr to which this
** line need to be grouped with rather than reported separately. If this
** Field is blank then the item will be reported separately.
** Field value to be determined in user exit.
*        grpos        LIKE vbrp-posnr,
**       --- EndofAddition by Rama from IBM
*
*        fkdat        LIKE vbrk-fkdat,
*        erdat        LIKE vbrk-erdat,
*        kunrg        LIKE vbrk-kunrg,
*        stceg        LIKE vbrk-stceg,
*        aubel        LIKE vbrp-aubel,   "Sales order
*        knumv        LIKE vbrk-knumv,
*        kalsm        LIKE vbrk-kalsm,
*
*        fkimg        LIKE vbrp-fkimg,
*        ean11        LIKE vbrp-ean11,
*        xblnr        LIKE vbrk-xblnr,
*        sfakn        LIKE vbrk-sfakn,
*        itamt        LIKE konv-kwert,
*        itdisc       LIKE konv-kwert,
*        itoth        LIKE konv-kwert,
*        mwsbp        LIKE vbrp-mwsbp,  "TAX
*        arktx        LIKE vbrp-arktx,
*        ppn          LIKE konv-kwert,
*        ppnbm        LIKE konv-kwert,
*        xppnbm       LIKE konv-kwert,
*        dpp          LIKE konv-kwert,
*        itqty        LIKE vbrp-fkimg,
*        examt        LIKE konv-kwert,
*        inamt        LIKE konv-kwert,
*        itdiscex     LIKE konv-kwert,
*        itdiscin     LIKE konv-kwert,
*        examtlast    LIKE konv-kwert,
*        inamtlast    LIKE konv-kwert,
*        itdiscexlast LIKE konv-kwert,
*        itdiscinlast LIKE konv-kwert,
*        itqtylast    LIKE ZGDTXdt0002-itqtylast,
*        itamtlast    LIKE konv-kwert,
*        itdisclast   LIKE konv-kwert,
*        itothlast    LIKE konv-kwert,
*        dpplast      LIKE konv-kwert,
*        ppnlast      LIKE konv-kwert,
*        ppnbmlast    LIKE konv-kwert,
*        xppnbmlast   LIKE konv-kwert,
**Foreign Currency
*        ppn2         LIKE ZGDTXdt0002-ppn2,
*        ppn2last     LIKE ZGDTXdt0002-ppn2last,
*        ppndate      LIKE ZGDTXdt0002-ppndate,
*        trcurr       LIKE ZGDTXdt0002-trcurr,
*        rate_std     LIKE ZGDTXdt0002-rate_std,
*        rate_tax     LIKE ZGDTXdt0002-rate_tax,
*        kurrf        LIKE vbrk-kurrf, "Billing Rate
*        itamt_f      LIKE konv-kwert,
*        itdisc_f     LIKE konv-kwert,
*        itoth_f      LIKE konv-kwert,
*        ppn_f        LIKE konv-kwert,
*        ppnbm_f      LIKE konv-kwert,
*        xppnbm_f     LIKE konv-kwert,
*        dpp_f        LIKE konv-kwert,
**Foreign Currrency for Faktur Pajak ZGDTXdt0003
*        fakcurr      LIKE ZGDTXdt0003-fakcurr,
*        fakrate      LIKE ZGDTXdt0003-fakrate,
*        bilrate      LIKE ZGDTXdt0003-bilrate,
*        fakppn_f     LIKE ZGDTXdt0003-fakppn_f,
*        fakppnbm_f   LIKE ZGDTXdt0003-fakppnbm_f,
*        fakxppnbm_f  LIKE ZGDTXdt0003-fakxppnbm_f,
*
*        tarifxpbm    LIKE ZGDTXdt0002-tarifxpbm,
*        karoseri     LIKE ZGDTXdt0002-karoseri,
*        pstyv        LIKE vbrp-pstyv,
*        itemdiv      LIKE ZGDTXdt0002-itemdiv,
*        th_buat      LIKE ZGDTXdt0002-th_buat,
*        mesin        LIKE ZGDTXdt0002-mesin,
*        kwitansi     LIKE ZGDTXdt0002-kwitansi,
*        erdt2        LIKE ZGDTXdt0002-erdt2,
*        rectype      LIKE ZGDTXdt0002-rectype,
*        exclude      LIKE ZGDTXdt0002-exclude,
*        skb          LIKE ZGDTXdt0002-skb,
*        dtretur      LIKE ZGDTXdt0002-dtretur,
*        noretur      LIKE ZGDTXdt0002-noretur,
*        masatx       LIKE ZGDTXdt0002-masatx,
*        fakdat       LIKE ZGDTXdt0003-fakdat,
*        fakturno     LIKE ZGDTXdt0003-fakturno,
*        name         LIKE ZGDTXdt0003-name,
*        addrs1       LIKE ZGDTXdt0003-addrs1,
*        addrs2       LIKE ZGDTXdt0003-addrs2,
*        city         LIKE ZGDTXdt0003-city,
*        postal       LIKE ZGDTXdt0003-postal,
*        wapu         LIKE ZGDTXdt0003-wapu,
*        cetakke      LIKE ZGDTXdt0003-cetakke,
*        batal        LIKE ZGDTXdt0003-batal,
*        returcount   LIKE ZGDTXdt0003-returcount,
*        sspdat       LIKE ZGDTXdt0003-sspdat,
*        sspval       LIKE ZGDTXdt0003-sspval,
*        pkpstat      LIKE ZGDTXdt0003-pkpstat,
*        form         LIKE ZGDTXdt0003-form,
*        faktur_type  LIKE ZGDTXdt0003-faktur_type,
*        internal     LIKE ZGDTXdt0002-internal,
*        gjahr        LIKE ZGDTXdt0002-gjahr,
*        belnr        LIKE ZGDTXdt0002-belnr,
*        stnk         LIKE ZGDTXdt0002-stnk,
*        stnklast     LIKE ZGDTXdt0002-stnklast,
*        bemot        LIKE vbrp-bemot,
*        vbelv        LIKE vbfa-vbelv,
*        posnv        LIKE vbfa-posnv,
*        fksto        LIKE vbrk-fksto,
*        top          LIKE sy-datum,
*
*        karos        LIKE ZGDTXdt0002-karoseri.
DATA  END   OF t_vbrk.

DATA t_vbrk0  LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
DATA t_vbrk1  LIKE t_vbrk OCCURS 1 WITH HEADER LINE.

**Cancel billing
DATA t_vbrkc  LIKE t_vbrk OCCURS 1 WITH HEADER LINE.

**Follow-up billing
DATA t_vbrkf  LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
DATA t_vbrkfo LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
DATA t_vbrkfc LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
DATA t_vbrkfx LIKE t_vbrk OCCURS 1 WITH HEADER LINE.

**Accounting documents & Cancellation docs
DATA t_vbfaa  LIKE vbfa   OCCURS 1 WITH HEADER LINE.
DATA t_vbfac  LIKE vbfa   OCCURS 1 WITH HEADER LINE.

**Billings in Screen view (filtered billings - no error)
DATA  BEGIN OF t_vbrkscr OCCURS 1.
DATA: vbeln      LIKE vbrk-vbeln,
      fkdat      LIKE vbrk-fkdat,
      stceg      LIKE vbrk-stceg,
      tax        TYPE c,
      code(3)    TYPE c,
      itamtlast  LIKE konv-kwert,
      itdisclast LIKE konv-kwert,
      dpplast    LIKE konv-kwert,
      ppnlast    LIKE konv-kwert,
      ppnbmlast  LIKE konv-kwert,
      xppnbmlast LIKE konv-kwert,
      gsber      LIKE vbrp-gsber,
      masatx     LIKE zgdtxdt0002-masatx,
      sel(1)     TYPE c,
      vbelv      LIKE vbfa-vbelv,
      name       LIKE zgdtxdt0003-name,
      waerk      LIKE vbrk-waerk,
      memo(20),                                "for RPC
      status(10),                              "for RPC
      fktno      LIKE zgdtxdt0003-fakturno,  "for RPC
      fktno1(21),
      fakdat     LIKE zgdtxdt0003-fakdat,    "for RPC
      karos      LIKE zgdtxdt0002-karoseri,

      trcurr     LIKE zgdtxdt0002-trcurr,
      rate_std   LIKE zgdtxdt0002-rate_std,
      rate_tax   LIKE zgdtxdt0002-rate_tax,
      ppn2       LIKE zgdtxdt0002-ppn2,
      ppn2last   LIKE zgdtxdt0002-ppn2last,
      ppndate    LIKE zgdtxdt0002-ppndate,
      kurrf      LIKE vbrk-kurrf, "Billing Rate
*Field for Foreign Currency
      itamt_f    LIKE konv-kwert,
      itdisc_f   LIKE konv-kwert,
      itoth_f    LIKE konv-kwert,
      ppn_f      LIKE konv-kwert,
      ppnbm_f    LIKE konv-kwert,
      xppnbm_f   LIKE konv-kwert,
      dpp_f      LIKE konv-kwert,
***added by Rahmadi -- field for Invoice Consolidation opt.
      fakgr      LIKE zgdtxdt0003-fakgr,
      kunrg      LIKE zgdtxdt0003-kunrg, "Payer added on 13/11/2003
***added for Tempo
      zterm      LIKE vbrk-zterm,
      ztag1      LIKE t052-ztag1,
      noref,
***end of Tempo addition
      dplast     LIKE konv-kwert,
      END OF t_vbrkscr.

**User selected billings
DATA t_vbrkscr1 LIKE t_vbrkscr OCCURS 1 WITH HEADER LINE.

**Tariff table
DATA   BEGIN OF t_tariff OCCURS 1.
DATA: vbeln     LIKE vbrk-vbeln,
      dpp       LIKE zgdtxdt0002-dpp,
      ppnbm     LIKE zgdtxdt0002-ppnbm,
      tarifxpbm LIKE zgdtxdt0002-tarifxpbm.
DATA   END OF t_tariff.

**Pricing for each billing items
DATA: BEGIN OF t_priceall OCCURS 1,
        vbeln    LIKE vbrk-vbeln,
        posnr    LIKE vbrp-posnr,
        ptype    LIKE zgdtxdt0008-ptype,
        indicate LIKE zgdtxdt0008-indicate,
        ppnbmflg LIKE zgdtxdt0008-ppnbmflg,
        kwert    LIKE konv-kwert,
        kbetr    LIKE konv-kbetr,
        waers    LIKE konv-waers,
      END OF t_priceall.

* added ibm_humayun  hash table
TYPES: BEGIN OF type_priceall,
         vbeln    LIKE vbrk-vbeln,
         posnr    LIKE vbrp-posnr,
         ptype    LIKE zgdtxdt0008-ptype,
         indicate LIKE zgdtxdt0008-indicate,
         ppnbmflg LIKE zgdtxdt0008-ppnbmflg,
         kwert    LIKE konv-kwert,
         kbetr    LIKE konv-kbetr,
         waers    LIKE konv-waers,
       END OF type_priceall.



DATA: t_priceall_hashed TYPE HASHED TABLE OF type_priceall
            WITH UNIQUE KEY vbeln posnr ptype indicate ppnbmflg.
DATA: wa_priceallhashed  TYPE type_priceall.


**Accounting docs
DATA BEGIN OF t_bkpf OCCURS 1.
DATA: belnr LIKE bkpf-belnr,
      budat LIKE bkpf-budat,
      xblnr LIKE bkpf-xblnr.
DATA END OF t_bkpf.

**PKP data
DATA: BEGIN OF t_pkp OCCURS 1,
        masafrom  LIKE zgdtxdt0005-masafrom,
        pkpnpwp   LIKE zgdtxdt0005-pkpnpwp,
        vspo      LIKE zgdtxdt0005-vspo,
        pkpname   LIKE zgdtxdt0005-pkpname,
        pkpaddrs1 LIKE zgdtxdt0005-pkpaddrs1,
        pkpaddrs2 LIKE zgdtxdt0005-pkpaddrs2,
        pkpkuh    LIKE zgdtxdt0005-pkpkuh,
        pkpcity   LIKE zgdtxdt0005-pkpcity,
        pkppostal LIKE zgdtxdt0005-pkppostal,
        petugas   LIKE zgdtxdt0005-petugas,
        petugas2  LIKE zgdtxdt0005-petugas2,
        jabat     LIKE zgdtxdt0005-jabat,
        jabat2    LIKE zgdtxdt0005-jabat2,
        nameadm   LIKE zgdtxdt0005-nameadm,
        jabatadm  LIKE zgdtxdt0005-jabatadm,
        namecab   LIKE zgdtxdt0005-namecab,
        jabatcab  LIKE zgdtxdt0005-jabatcab,
        aktif     LIKE zgdtxdt0005-aktif,
        fpone     LIKE zgdtxdt0005-fpone,
        fptwo     LIKE zgdtxdt0005-fptwo,
        objrange  LIKE zgdtxdt0005-objrange,
        coretax   LIKE zgdtxdt0005-coretax.
DATA  END   OF t_pkp.

**Partner functions
DATA BEGIN OF t_vbpa OCCURS 1.
INCLUDE STRUCTURE vbpa.
*DATA:  vbeln LIKE vbpa-vbeln,
*       parvw LIKE vbpa-parvw,
*       kunnr LIKE vbpa-kunnr,
*       adrnr LIKE vbpa-adrnr.
DATA END OF t_vbpa.

**Customer
DATA BEGIN OF t_kna1 OCCURS 1.
DATA: kunnr LIKE kna1-kunnr,
      stcd1 LIKE kna1-stcd1,
      stceg LIKE kna1-stceg,
      xcpdk LIKE kna1-xcpdk,
      anred LIKE kna1-anred.
DATA END OF t_kna1.

**Address
DATA BEGIN OF t_adrc OCCURS 1.
DATA: addrnumber LIKE adrc-addrnumber,
      title      LIKE adrc-title,
      name1      LIKE adrc-name1,
      name2      LIKE adrc-name2,
      name3      LIKE adrc-name3,
      name4      LIKE adrc-name4,
      str_suppl1 LIKE adrc-str_suppl1,
      street     LIKE adrc-street,
      str_suppl2 LIKE adrc-str_suppl2,
      str_suppl3 LIKE adrc-str_suppl3,
      location   LIKE adrc-location,
      city1      LIKE adrc-city1,
      post_code1 LIKE adrc-post_code1,
      city2      LIKE adrc-city2,
      name_co    LIKE adrc-name_co.
DATA END OF t_adrc.

*--Itab for gabungan
DATA: BEGIN OF t_vbrk_gab OCCURS 0,
        vbeln      LIKE t_vbrk-vbeln,
        matnr      LIKE mara-matnr,        "added by Rahmadi
        item       LIKE zgdtxst0003-item,  "added by Rahmadi
        vkorg      LIKE t_vbrk-vkorg,
        fakno      LIKE zgdtxdt0002-fakturno,
        spart      LIKE t_vbrk-spart,
        itemdiv    LIKE t_vbrk-itemdiv,
        fkimg      LIKE t_vbrk-fkimg,
        itamtlast  LIKE t_vbrk-itamtlast,
        itdisclast LIKE t_vbrk-itdisclast,
        dpplast    LIKE t_vbrk-dpplast,
        ppnlast    LIKE t_vbrk-ppnlast,
        ppnbmlast  LIKE t_vbrk-ppnbmlast,
        xppnbmlast LIKE t_vbrk-xppnbmlast,
        waers      LIKE t_vbrk-waerk,
        pstyv      LIKE t_vbrk-pstyv,
*Foreign Currency
        itamt_f    LIKE t_vbrk-itamt_f,
        itdisc_f   LIKE t_vbrk-itdisc_f,
        itoth_f    LIKE t_vbrk-itoth_f,
        ppn_f      LIKE t_vbrk-ppn_f,
        ppnbm_f    LIKE t_vbrk-ppnbm_f,
        xppnbm_f   LIKE t_vbrk-xppnbm_f,
        dpp_f      LIKE t_vbrk-dpp_f,
        trcurr     LIKE t_vbrk-trcurr,
        rate_std   LIKE t_vbrk-rate_std,
        rate_tax   LIKE t_vbrk-rate_tax,
        kurrf      LIKE vbrk-kurrf, "Billing Rate
        ppn2       LIKE zgdtxdt0002-ppn2,
        ppn2last   LIKE zgdtxdt0002-ppn2last,
      END OF t_vbrk_gab.

**Tariff variants data
DATA: BEGIN OF t_tarif OCCURS 0,
        fakno     LIKE t_vbrk-fakturno,
        vbeln     LIKE t_vbrk-vbeln,
        dpplast   LIKE t_vbrk-dpplast,
        ppnbmlast LIKE t_vbrk-ppnbmlast,
        tarif(3)  TYPE c,
      END OF t_tarif.
*---

**Error log
DATA  BEGIN OF t_error OCCURS 1.
***modified by Rahmadi
*        INCLUDE STRUCTURE t_vbrk.
*DATA:   msg(100).
INCLUDE STRUCTURE zgdtxst0011.
***modified by Rahmadi
DATA  END   OF t_error.

**Tax related config tables Billing type, branch, bus line etc
DATA t_tx00009 LIKE zgdtxdt0009 OCCURS 1 WITH HEADER LINE.
DATA t_tx00101 LIKE zgdtxdt0101 OCCURS 1 WITH HEADER LINE.
DATA t_tx00102 LIKE zgdtxdt0102 OCCURS 1 WITH HEADER LINE.
DATA t_tx00103 LIKE zgdtxdt0103 OCCURS 1 WITH HEADER LINE.

**Billing that has been processed (its faktur has been issued)
DATA BEGIN OF t_process OCCURS 1.
DATA: vbeln    LIKE zgdtxdt0002-vbeln,
      posnr    LIKE zgdtxdt0002-posnr,
      fakturno LIKE zgdtxdt0002-fakturno,
      masatx   LIKE zgdtxdt0002-masatx,
      exclude  LIKE zgdtxdt0002-exclude,
*Foreign Currency
      rate_std LIKE zgdtxdt0002-rate_std,
      rate_tax LIKE zgdtxdt0002-rate_tax,
      delete.
DATA END OF t_process.

**Faktur pajak that has been processed
DATA BEGIN OF t_faktur OCCURS 1.
DATA: fakturno LIKE zgdtxdt0003-fakturno,
      cetakke  LIKE zgdtxdt0003-cetakke.
DATA END OF t_faktur.

**Material data
DATA BEGIN OF t_mara OCCURS 1.
DATA: matnr LIKE mara-matnr,
      matkl LIKE mara-matkl,
      mtart LIKE mara-mtart,
      spart LIKE mara-spart.
DATA END OF t_mara.

**Equipment data
DATA BEGIN OF t_equi OCCURS 1.
DATA: equnr LIKE equi-equnr,
      baujj LIKE equi-baujj,
      mapar LIKE equz-mapar.
DATA END OF t_equi.

**Kwitansi data
DATA BEGIN OF t_kwitansi OCCURS 1.
DATA:  ibeln LIKE vbrk-vbeln.
DATA:  zcsh1(10), " LIKE zfafdt_cashhead-zcsh1,
       erdt2 LIKE vbrk-erdat. "zfafdt_cashhead-erdt2.
DATA END OF t_kwitansi.

***added for Tempo
***Payment term table
DATA: BEGIN OF t_t052 OCCURS 10000,
        zterm LIKE t052-zterm,
        ztag1 LIKE t052-ztag1,
      END OF t_t052.
***end of Tempo addition

*WORK AREA
DATA dw_info LIKE inroi.

DATA va_datab LIKE zproject-datab.
*RANGES
RANGES: r_vbeln        FOR vbrk-vbeln,
        r_fkdat        FOR vbrk-fkdat, "date range for normal billing
        r_fodat        FOR vbrk-fkdat, "date range for follow-up billing
        r_stceg        FOR vbrk-stceg,
        r_stceg_select FOR vbrk-stceg,
        r_fkartn       FOR vbrk-fkart, "normal billing
        r_fkartr       FOR vbrk-fkart, "return billing
        r_fkartp       FOR vbrk-fkart, "price adj. billing
        r_fkartx       FOR vbrk-fkart, "follow-up cancel billing
        r_fkartc       FOR vbrk-fkart, "cancel billing
        r_pstyv        FOR vbrp-pstyv, "item category
*---Account indicator (to determine whether the item is Internal use)
        r_bemot        FOR vbrp-bemot.

***added for tempo
DATA t_period LIKE zgdtxdt0004 OCCURS 10000 WITH HEADER LINE.
RANGES r_per FOR zgdtxdt0004-masatx.
***end of Tempo addition

DATA : gt_zfvatnr_dtl TYPE STANDARD TABLE OF zfvatnr_dtl,
       wa_vat         LIKE zfvatnr_dtl.

DATA : gs_dpp     TYPE zproject,
*       gs_coretax TYPE zproject,
       gr_coretax TYPE RANGE OF datum.

*&---------------------------------------------------------------------*
*&      Macro MACRO_UDF_SELOPT_REST
*&---------------------------------------------------------------------*
*&  This macro prevents user to use only one sign in select option
*&---------------------------------------------------------------------*
DEFINE macro_udf_selopt_rest.
  CLEAR: d_udf_scras, d_udf_optls.
  d_udf_optls-name       = '&1'.
  d_udf_optls-options-eq = 'X'.
  d_udf_optls-options-bt = 'X'.
  APPEND d_udf_optls TO d_udf_restr-opt_list_tab.
  d_udf_scras-kind       = 'S'.
  d_udf_scras-name       = '&1'.
  d_udf_scras-sg_main    = 'I'.
  d_udf_scras-op_main    = '&1'.
  APPEND d_udf_scras TO d_udf_restr-ass_tab.
  IF &2 = 'X'.
    CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
      EXPORTING
        restriction = d_udf_restr
      EXCEPTIONS
        OTHERS      = 1.
  ENDIF.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Macro MACRO_BILLING_TYPE_RANGE
*&---------------------------------------------------------------------*
*&  This macro separates billing based on its type
*&---------------------------------------------------------------------*
DEFINE macro_billing_type_range.
  CLEAR &2. REFRESH &2.
  LOOP AT t_tx00009 WHERE ptype = &1.
    &2-sign = 'I'.
    &2-option = 'EQ'.
    &2-low = t_tx00009-fkart.
    APPEND &2.
  ENDLOOP.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Macro INIT_RANGES
*&---------------------------------------------------------------------*
*&  This macro clears ranges or internal tables
*&---------------------------------------------------------------------*
DEFINE macro_init_ranges.
  CLEAR &1. REFRESH &1.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Macro From Variable
*&---------------------------------------------------------------------*
*&  This macro passing variable to form
*&---------------------------------------------------------------------*
DEFINE mac_from_variabel.
  &1petugas   = &2petugas.
  &1petugas2  = &2petugas2.
  &1jabat     = &2jabat.
  &1jabat2    = &2jabat2.
  &1fpone     = &2fpone.
  &1fptwo     = &2fptwo.
  &1objrange  = &2objrange.
  &1pkpnpwp   = &2pkpnpwp.
  &1pkpname   = &2pkpname.
  &1pkpaddrs1 = &2pkpaddrs1.
  &1pkpaddrs2 = &2pkpaddrs2.
  &1pkpkuh    = &2pkpkuh.
  &1pkpcity   = &2pkpcity.
  &1pkppostal = &2pkppostal.
*  &1nr_gsber  = &3gsber.
  &1nr_brnch  = &3brnch.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Macro Add Range
*&---------------------------------------------------------------------*
*&  This macro add value in range
*&---------------------------------------------------------------------*
DEFINE mac_add_range.
  &1-sign   = 'I'.
  &1-option = 'EQ'.
  &1-low    = &2.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.


*&---------------------------------------------------------------------*
*&      Macro PRICE_NORMALIZATION
*&---------------------------------------------------------------------*
*&  This macro normalizes value to be positive
*&---------------------------------------------------------------------*
DEFINE macro_price_normalization.
  COMPUTE &1 = abs( &1 ).
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Macro MACRO_GET_NRANGES_INFO
*&---------------------------------------------------------------------*
*&  This macro gets additional info for a number range object
*&---------------------------------------------------------------------*
DEFINE macro_get_nranges_info.
  CALL FUNCTION 'NUMBER_RANGE_OBJECT_GET_INFO'
    EXPORTING
      object = &1
    IMPORTING
      info   = &2.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&    Macro MACRO_FAKTUR_FORMATTING
*&---------------------------------------------------------------------*
*&  This macro removes leading zeros in Faktur number
*&---------------------------------------------------------------------*
DEFINE macro_faktur_formatting.
  WHILE &1(1) = '0'.
    SHIFT &1.
  ENDWHILE.
  &2 = &1.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING_DATA
*&---------------------------------------------------------------------*
*&  This routine retrieves normal billings from SAP
*&---------------------------------------------------------------------*
*&  ->FT_VBRK   - Billing table
*&  ->FT_VBELN  - Billing number
*&  ->FT_FKART  - Billing type
*&  ->FT_FKDAT  - Billing date
*&  ->FT_STCEG  - VAT registration no.
*&  ->FT_PSTYV  - Item category - only applicable for SERVICE billings
*&                (division 03) - selected from screen 2000
*&                blank for non-service billings
*&  ->FU_VKORG  - Sales organization/Company code
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&  ->FU_RPC    - 'X' if executed by RPC program, otherwise it's blank
*&---------------------------------------------------------------------*
FORM f_get_billing_data TABLES   ft_vbrk    STRUCTURE t_vbrk
                                 ft_vbeln   STRUCTURE r_vbeln
                                 ft_fkart   STRUCTURE r_fkartn
                                 ft_fkdat   STRUCTURE r_fkdat
                                 ft_stceg   STRUCTURE r_stceg
                                 ft_pstyv   STRUCTURE r_pstyv
                        USING    fu_vkorg
                                 fu_gsber
                                 fu_spart
                                 fu_brnch
                                 fu_busln
                                 fu_bukrs
                                 fu_rpc
*Foreign currency
                                 fu_curr.
  DATA: ld_user  LIKE sy-msgv1,
        ld_subrc LIKE sy-subrc,
        ld_vbelv LIKE t_vbrk-vbeln,
        lw_vbrk  LIKE t_vbrk.

***changed for Tempo --- All faktur type will check currency code
**Only PPN Gabungan will check the currency sign -- NO MORE
*  IF d_tcode = c_tcode_gabungan            OR
*     d_tcode = c_tcode_period_end_gabungan OR
*     d_tcode = c_tcode_gabungan_otomatis   OR
*     d_tcode = c_tcode_gabungan_otoakhir.
* Get Billing docs
  SELECT k~vbeln k~fkart k~waerk k~vkorg k~spart k~fkdat k~erdat
         k~kunrg k~stceg k~bukrs k~knumv k~kalsm k~kunrg k~xblnr
         k~sfakn k~fksto k~kurrf k~zukri k~vbtyp k~zterm
         p~posnr p~matnr p~gsber p~aubel p~ean11 p~mwsbp p~arktx
         p~fkimg p~prctr p~pstyv p~bemot p~werks p~vrkme
         INTO CORRESPONDING FIELDS OF TABLE ft_vbrk
         FROM vbrk AS k INNER JOIN vbrp AS p ON k~vbeln = p~vbeln
         WHERE   k~vbeln IN ft_vbeln AND
                 k~fkart IN ft_fkart AND
* changed by rama
*                   k~vkorg EQ fu_vkorg AND
*                   k~spart EQ fu_spart AND
*                   p~gsber EQ fu_gsber AND
* End of change
                 k~fkdat IN ft_fkdat AND
                 k~waerk EQ fu_curr  AND
                 k~stceg IN ft_stceg AND
                 p~pstyv IN ft_pstyv AND
                 p~fkimg NE 0.
*  ELSE.
** Get Billing docs without checking currency type
*    SELECT k~vbeln k~fkart k~waerk k~vkorg k~spart k~fkdat k~erdat
*           k~kunrg k~stceg k~bukrs k~knumv k~kalsm k~kunrg k~xblnr
*           k~sfakn k~fksto k~kurrf k~zukri k~vbtyp k~zterm
*           p~posnr p~matnr p~gsber p~aubel p~ean11 p~mwsbp p~arktx
*           p~fkimg p~prctr p~pstyv p~bemot  p~werks p~vrkme
*           INTO CORRESPONDING FIELDS OF TABLE ft_vbrk
*           FROM vbrk AS k INNER JOIN vbrp AS p ON k~vbeln = p~vbeln
*           WHERE   k~vbeln IN ft_vbeln AND
*                   k~fkart IN ft_fkart AND
** changed by rama
**                   k~vkorg EQ fu_vkorg AND
**                   k~spart EQ fu_spart AND
**                   p~gsber EQ fu_gsber AND
** End of change
*                   k~fkdat IN ft_fkdat AND
*                   k~stceg IN ft_stceg AND
*                   p~pstyv IN ft_pstyv.
*  ENDIF.
****end of tempo changes


*---- Added by Rama ->
* Need to check whether material is pricing relevent or not.
* If not then delete the item from the list. No need to
* copy it for tax purpose. e.g. for CBU the main item is only
* a BOM header and does not carry any price.

  TABLES: tvap.

  LOOP AT ft_vbrk.

    SELECT SINGLE * FROM tvap
     WHERE pstyv = ft_vbrk-pstyv
       AND kowrr = space.

    IF sy-subrc <> 0.
      DELETE ft_vbrk.
      CONTINUE.
    ENDIF.
**** ----- Add By sukardi (20/04/2006)
*** Req By trias change for Exchange Rate
*** Exchange rate diambil berdasarkan tgl SO bukan Billing
***

    SELECT SINGLE vbelv INTO ld_vbelv FROM vbfa
           WHERE vbeln = ft_vbrk-vbeln AND
                 vbtyp_v = 'J'.
    IF sy-subrc EQ 0.
      SELECT SINGLE wadat_ist INTO ft_vbrk-wadat_ist FROM likp
             WHERE vbeln = ld_vbelv.

    ENDIF.
    CLEAR: ld_vbelv.
    MODIFY ft_vbrk.
    CLEAR: ft_vbrk.
***** Ending Add By Sukardi
  ENDLOOP.
*--- End of addition


  IF sy-subrc = 0.
    SORT ft_vbrk BY vbeln posnr fkdat.

****Moved out, should not be at selection screen -- Tempo
*****Lock selected billings
*    IF fu_rpc IS INITIAL.
*      LOOP AT ft_vbrk.
*        MOVE-CORRESPONDING ft_vbrk TO lw_vbrk.
*        AT NEW vbeln.
*          CLEAR ld_subrc.
*          PERFORM f_lock_billing USING    lw_vbrk
*                                 CHANGING ld_subrc
*                                          ld_user.
*          PERFORM f_process_locked_norm_billing USING lw_vbrk
*                                                      ld_user
*                                                      ld_subrc.
*        ENDAT.
*        AT END OF vbeln.
*          IF ld_subrc <> 0.
*            DELETE ft_vbrk WHERE vbeln =  lw_vbrk-vbeln.
*          ENDIF.
*        ENDAT.
*      ENDLOOP.
*    ENDIF.
****end of Tempo Removal

****Get the whole month as the date range for follow-up docs
    REFRESH r_fodat.

****Retrieval Period for follow-up documents will be limited
****to the month of selected period
****This condition is not applicable for RPC program
    IF fu_rpc IS INITIAL.
      READ TABLE ft_vbrk INDEX 1.
      PERFORM f_get_daterange_of_the_month TABLES   r_fodat
                                           USING    ft_vbrk-fkdat.
    ENDIF.
  ENDIF.

*--- Added by Rama
* Delete those records which do not belong to the selection
* of branch and business line
  PERFORM f_select_branch_billing_data TABLES ft_vbrk
                                       USING  fu_brnch
                                              fu_busln.

* Identify which line items in the billing should be combined
* This grouping should also be changed to user exit
  PERFORM f_determine_group_items TABLES ft_vbrk.
  IF ft_vbrk[] IS INITIAL.
    MESSAGE e000(ztx) WITH 'Billing not found'.
  ENDIF.

*--- End of Addition

ENDFORM.                       "F_GET_BILLING_DATA


*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING_SEDERHANA
*&---------------------------------------------------------------------*
*&  This routine is only applicable for Sederhana process to select
*&  billings needs to be processed as Faktur pajak
*&---------------------------------------------------------------------*
*&  <-FT_VBRK   - Billing data
*&  ->FT_VBELN  - Selected billing numbers
*&  ->FT_FKART  - Selected billing type
*&  ->FU_VKORG  - Sales Organization
*&  ->FU_GSBER  - Business area
*&  ->FU_SPART  - Division
*&  ->FU_MASATX - Tax period
*&---------------------------------------------------------------------*
FORM f_get_billing_sederhana TABLES ft_vbrk STRUCTURE t_vbrk
                                    ft_vbeln STRUCTURE r_vbeln
                                    ft_fkart STRUCTURE r_fkartn
                                    ft_fkdat STRUCTURE r_fkdat
                             USING  fu_vkorg
                                    fu_gsber
                                    fu_spart
                                    fu_brnch
                                    fu_busln
                                    fu_bukrs
                                    fu_masatx
                           CHANGING fc_fakdat.

  DATA ld_user LIKE sy-msgv1.
  DATA ld_subrc LIKE sy-subrc.
  DATA lw_vbrk LIKE t_vbrk.

**Get date range of period (masa pajak)
  CASE d_tcode.
    WHEN c_tcode_sederhana.
****modified by Rahmadi
*-- Sederhana: Billing date is selected from Selection Screen
*      REFRESH r_fodat.
*      PERFORM f_get_daterange_of_period  TABLES r_fodat
*                                         USING  fu_masatx.
      r_fodat[] = ft_fkdat[].
****end of modification
      READ TABLE r_fodat INDEX 1.
      fc_fakdat = r_fodat-low.
    WHEN c_tcode_sederhana_single.
      r_fodat[] = ft_fkdat[].
      READ TABLE r_fodat INDEX 1.
      IF r_fodat-high IS INITIAL.
        fc_fakdat = r_fodat-low.
      ELSE.
        fc_fakdat = r_fodat-high.
      ENDIF.
  ENDCASE.

**Get Billing
  SELECT k~vbeln k~fkart k~waerk k~vkorg k~spart k~fkdat k~erdat
         k~kunrg k~stceg k~bukrs k~knumv k~kalsm k~kunrg k~xblnr
         k~sfakn k~kurrf k~zukri k~vbtyp k~zterm
         p~posnr p~matnr p~gsber p~aubel p~ean11 p~mwsbp p~arktx
         p~fkimg p~prctr p~pstyv p~bemot p~vrkme
         INTO CORRESPONDING FIELDS OF TABLE ft_vbrk
         FROM vbrk AS k INNER JOIN vbrp AS p ON k~vbeln = p~vbeln
         WHERE   k~vbeln IN ft_vbeln AND
                 k~fkart IN ft_fkart AND
* changed by rama
*                 k~vkorg EQ fu_vkorg AND
*                 k~spart EQ fu_spart AND
*                 p~gsber EQ fu_gsber AND
* End of change
                 k~fkdat IN r_fodat.
  IF sy-subrc = 0.
    SORT ft_vbrk BY matnr.
    PERFORM f_get_material_data TABLES ft_vbrk.
    SORT ft_vbrk BY vbeln posnr fkdat.

****Lock selected billings
    LOOP AT ft_vbrk.
      MOVE-CORRESPONDING ft_vbrk TO lw_vbrk.
      AT NEW vbeln.
        CLEAR ld_subrc.
        PERFORM f_lock_billing USING    lw_vbrk
                               CHANGING ld_subrc
                                        ld_user.
        PERFORM f_process_locked_norm_billing USING lw_vbrk
                                                    ld_user
                                                    ld_subrc.
      ENDAT.
      AT END OF vbeln.
        IF ld_subrc <> 0.
          DELETE ft_vbrk WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
      ENDAT.
    ENDLOOP.

  ENDIF.

*--- Added by Rama
* Delete those records which do not belong to the selection
* of branch and business line
  PERFORM f_select_branch_billing_data TABLES ft_vbrk
                                       USING  fu_brnch
                                              fu_busln.

* Identify which line items in the billing should be combined
* This grouping should also be changed to user exit
  PERFORM f_determine_group_items TABLES ft_vbrk.
  IF ft_vbrk[] IS INITIAL.
    MESSAGE e000(ztx) WITH 'Billing not found'.
  ENDIF.

*--- End of Addition

ENDFORM.                    " F_GET_BILLING_SEDERHANA

*&---------------------------------------------------------------------*
*&      Form  F_GET_SUPPORTING_DATA
*&---------------------------------------------------------------------*
*&  This routine retrieves all necessary supporting data such as
*&  price, material, equipment, kwitansi and address
*&---------------------------------------------------------------------*
*&  ->FU_BUKRS  - Company code
*&  ->FU_BRNCH  - Branch
*&  ->FU_BUSLN  - Business Line
*&---------------------------------------------------------------------*
FORM f_get_supporting_data USING  fu_vkorg
                                  fu_gsber
                                  fu_spart
                                  fu_brnch
                                  fu_busln.
*--- Get Price
  PERFORM f_get_price TABLES t_vbrk1  t_priceall.
*                      USING  fu_vkorg fu_spart.

***removed for Tempo --- SHOULD BE INDUSTRY SPECIFIC (Automotive only)
**Get Machine no, Manuf. year
*  PERFORM f_get_equipment_data TABLES t_vbrk1.
***end of Tempo removal

***removed by Rahmadi --- not generic and not relevant
*--Additional info can be put to User Exit for Addt. Info
***Get Kwitansi
*  PERFORM f_get_kwitansi_data TABLES t_vbrk1
*                              USING  fu_vkorg.
***end of removal

ENDFORM.                    " F_GET_SUPPORTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATERANGE_OF_THE_MONTH
*&---------------------------------------------------------------------*
*&  This routine determines date range in a month based on selected
*&  billing date
*&---------------------------------------------------------------------*
*&  <-FT_FODAT  - Date range in a month
*&  ->FU_DATUM  - Billing date
*&---------------------------------------------------------------------*
FORM f_get_daterange_of_the_month TABLES   ft_fodat STRUCTURE r_fodat
                                  USING    fu_datum.

  DATA  ld_date(10).
  DATA  ld_date2(8).
  DATA  ld_year(4).
  DATA  ld_month(2).
  DATA  ld_day(2).
  DATA  ld_mod TYPE i.
  DATA  ld_last_day(2).
  DATA  ld_first LIKE sy-datum.
  DATA  ld_last LIKE sy-datum.

  MOVE fu_datum TO ld_date.
  ld_year = ld_date+0(4).
  ld_month = ld_date+4(2).
  ld_day = ld_date+6(2).

  CONCATENATE ld_year ld_month '01' INTO ld_date2.
  MOVE ld_date2 TO ld_first.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fu_datum
    IMPORTING
      last_day_of_month = ld_last
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  REFRESH ft_fodat.
  CLEAR ft_fodat.
  ft_fodat-low = ld_first.
  ft_fodat-high = ld_last.
  ft_fodat-sign = 'I'.
  ft_fodat-option = 'BT'.
  APPEND ft_fodat.

ENDFORM.                    " F_GET_DATERANGE_OF_THE_MONTH

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATERANGE_OF_PERIOD
*&---------------------------------------------------------------------*
*&  This routine determines date range in a month based on selected
*&  Tax period
*&---------------------------------------------------------------------*
*&  <-FT_FODAT   - Date range in a month
*&  ->FU_MASATX  - Tax period
*&---------------------------------------------------------------------*
FORM f_get_daterange_of_period  TABLES   ft_fodat STRUCTURE r_fodat
                                USING    fu_masatx.

  DATA  ld_date(10).
  DATA  ld_date2(8).
  DATA  ld_year(4).
  DATA  ld_month(2).
  DATA  ld_day(2).
  DATA  ld_mod TYPE i.
  DATA  ld_last_day(2).
  DATA  ld_first LIKE sy-datum.
  DATA  ld_last LIKE sy-datum.

  MOVE fu_masatx TO ld_date.
  ld_year = ld_date+0(4).
  ld_month = ld_date+4(2).

  CONCATENATE ld_year ld_month '01' INTO ld_date2.
  MOVE ld_date2 TO ld_first.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ld_first
    IMPORTING
      last_day_of_month = ld_last
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  REFRESH ft_fodat.
  CLEAR ft_fodat.
  ft_fodat-low = ld_first.
  ft_fodat-high = ld_last.
  ft_fodat-sign = 'I'.
  ft_fodat-option = 'BT'.
  APPEND ft_fodat.

ENDFORM.                    " F_GET_DATERANGE_OF_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_GET_FOLLOWUP_BILL_DATA
*&---------------------------------------------------------------------*
*&  This routine retrieves follow-up billings from SAP
*&---------------------------------------------------------------------*
*&  ->FT_VBFA   - Billing history table
*&                (containing link normal <-> its follow-up)
*&  <-FT_VBRKFO - Follow-up billing produced by this routine
*&  ->FT_FKDAT  - Billing date
*&  ->FT_STCEG  - VAT registration no.
*&  ->FU_VKORG  - Sales organization/Company code
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&---------------------------------------------------------------------*
FORM f_get_followup_bill_data TABLES ft_vbfa STRUCTURE t_vbfaa
                                     ft_vbrkfo STRUCTURE t_vbrk
                                     ft_fkdat STRUCTURE r_fkdat
                                     ft_stceg STRUCTURE r_stceg.
*--- Commented by Rama
*                              USING  fu_vkorg
*                                     fu_spart
*                                     fu_gsber.
*--- Commented by rama
  DATA ld_tabix LIKE sy-tabix.
  DATA lt_vbrkf LIKE t_vbrk OCCURS 0 WITH HEADER LINE.
  DATA ld_subrco LIKE sy-subrc.
  DATA ld_tabixo LIKE sy-tabix.
  DATA ld_subrcs LIKE sy-subrc.
  DATA ld_tabixs LIKE sy-tabix.
  DATA ld_subrcc LIKE sy-subrc.
  DATA:ld_tabixc LIKE sy-tabix,
       ld_to     LIKE sy-tabix,
       ld_from   LIKE sy-tabix.

  DATA: BEGIN OF lt_vbfa OCCURS 0,
          vbeln LIKE  vbfa-vbeln,
          posnn LIKE  vbfa-posnn,
        END OF lt_vbfa.

**Get Billing data
  IF NOT ft_vbfa[] IS INITIAL.
    ld_from = 1.
    ld_to   = c_max_ritems.
    REFRESH: lt_vbrkf.
    DO.
      REFRESH: lt_vbfa.
      LOOP AT ft_vbfa FROM ld_from TO ld_to.
        lt_vbfa-vbeln = ft_vbfa-vbeln.
        lt_vbfa-posnn = ft_vbfa-posnn.
        APPEND lt_vbfa.
      ENDLOOP.
      IF lt_vbfa[] IS INITIAL. EXIT. ENDIF.
      SELECT k~vbeln k~fkart k~waerk k~vkorg k~spart k~fkdat k~erdat
             k~kunrg k~stceg k~bukrs k~knumv k~kalsm k~kunrg k~xblnr
             k~sfakn k~vbtyp k~zterm
             p~posnr p~matnr p~gsber p~aubel p~ean11 p~mwsbp p~arktx
             p~fkimg p~prctr p~pstyv p~bemot p~werks
             APPENDING CORRESPONDING FIELDS OF TABLE lt_vbrkf
             FROM vbrk AS k INNER JOIN vbrp AS p ON k~vbeln = p~vbeln
             FOR ALL ENTRIES IN lt_vbfa
             WHERE p~vbeln = lt_vbfa-vbeln AND
                   p~posnr = lt_vbfa-posnn AND
*--- Commented by Rama - Already organisation info is selected
*                   k~vkorg = fu_vkorg AND
*                   k~spart = fu_spart AND
*                   p~gsber = fu_gsber AND
*--- End of comment
                   k~fkdat IN ft_fkdat AND
                   k~stceg IN ft_stceg.
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.
    ENDDO.

    IF NOT lt_vbrkf[] IS INITIAL.
      SORT lt_vbrkf BY vbeln posnr fkdat.
      SORT ft_vbfa BY vbeln posnn.

******Populate follow-up billing data
      LOOP AT lt_vbrkf.
        CLEAR ld_tabix.
        ld_tabixo = sy-tabix.

*********Lock billing
*        PERFORM f_lock_billing USING lw_vbrk
*                               CHANGING ld_subrc1.

********Check whether its acc docs has been posted
        PERFORM f_check_acc_docs USING  lt_vbrkf
                                        'O'
                                 CHANGING lt_vbrkf-belnr
                                          ld_subrco.
        IF ld_subrco = 0.
          READ TABLE ft_vbfa WITH KEY vbeln = lt_vbrkf-vbeln
                                      posnn = lt_vbrkf-posnr
                                      BINARY SEARCH.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING lt_vbrkf TO ft_vbrkfo.
            ft_vbrkfo-vbelv = ft_vbfa-vbelv.
            ft_vbrkfo-posnv = ft_vbfa-posnv.
            APPEND ft_vbrkfo.
          ELSE.
            CLEAR ft_vbrkfo.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_FOLLOWUP_BILL_DATA

*---------------------------------------------------------------------*
*       FORM f_check_bill_type                                        *
*---------------------------------------------------------------------*
*&  This routine check whether the billing type is Tax-related
*&  Tax programs will only process billing whose types defined in
*&  ZGDTXDt0009 table
*&---------------------------------------------------------------------*
*&  ->FT_VBRK   - Billing table
*&  ->FU_VBRK   - Billing data
*&  ->FU_PTYPE  - Billing type in Tax system
*&                (N-normal; R-return; P-price adj; C-Cancel; X-Follow-
*&                 up Cancel)
*&  ->FU_TABIX  - Index of selected record in Billing table
*&  <-FC_SUBRC  - Return code (Error: FU_SUBRC <> 0)
*&---------------------------------------------------------------------*
FORM f_check_bill_type TABLES ft_vbrk STRUCTURE t_vbrk
                       USING  fu_vbrk LIKE t_vbrk
                              fu_ptype
                              fu_tabix
                       CHANGING fc_subrc.

**Check whether billing type is tax related
  READ TABLE t_tx00009 WITH KEY fkart = fu_vbrk-fkart
                                ptype = fu_ptype
                                BINARY SEARCH.
  fc_subrc = sy-subrc.
  IF fc_subrc <> 0.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    CASE fu_ptype.
      WHEN 'N'.
        CONCATENATE 'Billing type' fu_vbrk-fkart
                    'is not a normal billing'
                    INTO t_error-msg
                    SEPARATED BY space.
    ENDCASE.
    APPEND t_error.
    DELETE ft_vbrk INDEX fu_tabix.
  ENDIF.

ENDFORM.          "F_CHECK_BILL_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_LIST
*&---------------------------------------------------------------------*
*&  This routine displays log in popup screen
*&---------------------------------------------------------------------*
FORM f_popup_list
     USING fu_form
           fu_title
           fu_col
           fu_row
           fu_width
           fu_height
           fu_flag_show_print_button.

  DATA: ld_formname(30) TYPE c,
        ld_repid        LIKE sy-repid.

  ld_formname = fu_form.
  TRANSLATE ld_formname TO UPPER CASE.
  ld_repid = sy-repid.

  CALL FUNCTION 'C14A_POPUP_LIST_DISPLAY'
    EXPORTING
      i_callback              = ld_formname
      i_callback_program      = ld_repid
      i_title                 = fu_title
      i_col                   = fu_col
      i_row                   = fu_row
      i_width                 = fu_width
      i_height                = fu_height
      i_flg_show_print_button = fu_flag_show_print_button
    EXCEPTIONS
      no_callback_specified   = 1
      OTHERS                  = 2.
ENDFORM.                    " F_POPUP_ERROR_LIST

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&  This routine displays error message based on the error code
*&---------------------------------------------------------------------*
*&  <-FU_SUBRC  - Error code
*&---------------------------------------------------------------------*
FORM f_error_message USING    fu_subrc.

*_rem By SAP_DEV06 27-03-2007
*  CASE fu_subrc.
*    WHEN '1'.
*      MESSAGE e501(ztx).
*    WHEN '2'.
*      MESSAGE e502(ztx).
*    WHEN '3'.
*      MESSAGE e503(ztx).
*    WHEN '4'.
*      MESSAGE e504(ztx).
*  ENDCASE.
*_end Of rem By SAP_DEV06 27-03-2007

ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING_TYPE
*&---------------------------------------------------------------------*
*&  This routine collects all Tax-related billing type defined in
*&  ZGDTXDt0009 table, then separated them into several ranges based
*&  on its type.
*&---------------------------------------------------------------------*
FORM f_get_billing_type.

**Get billing type
  SELECT * INTO TABLE t_tx00009 FROM zgdtxdt0009.
  IF sy-subrc = 0.
    SORT t_tx00009 BY fkart ptype.

****Separate billing types
    macro_billing_type_range 'N' r_fkartn. "Normal
    macro_billing_type_range 'R' r_fkartr. "Return
    macro_billing_type_range 'P' r_fkartp. "Price adj.
    macro_billing_type_range 'X' r_fkartx. "Ret/PA Cancel
    macro_billing_type_range 'C' r_fkartc. "Cancel
  ENDIF.

ENDFORM.                    " F_GET_BILLING_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ACCOUNTING
*&---------------------------------------------------------------------*
*&  This routine checks whether the billing has already had its
*&  accounting document posted in BKPF table.
*&  The accounting document will only be considered if it is posted
*&  within the same month as the billing
*&---------------------------------------------------------------------*
*&  ->FT_VBRK   - Billing table
*&  ->FU_VKORG  - Sales organization / Company code
*&  ->FU_BILL   - Billing type -- error message will be generated only
*&                for normal billing (type = 'N')
*&  <-FC_SUBRC  - Return code (Error: FU_SUBRC <> 0)
*&---------------------------------------------------------------------*
FORM f_check_accounting TABLES ft_vbrk STRUCTURE t_vbrk
                        USING fu_vkorg
                              fu_bill
                        CHANGING fc_subrc.

  READ TABLE t_bkpf WITH KEY xblnr+0(10) = ft_vbrk-vbeln
                    BINARY SEARCH.
  IF sy-subrc = 0.
    IF t_bkpf-budat+4(2) <> ft_vbrk-fkdat+4(2).
      fc_subrc = 3.
      IF fu_bill = 'N'.
        MOVE-CORRESPONDING ft_vbrk TO t_error.
        CONCATENATE 'The billing has been posted to month'
                    t_bkpf-budat+4(2)
                    'and cannot be processed in month'
                    ft_vbrk-fkdat+4(2)
                    INTO t_error-msg
                    SEPARATED BY space.
        APPEND t_error.
      ENDIF.
      DELETE ft_vbrk.
    ELSE.
      fc_subrc = 0.
    ENDIF.
  ELSE.
    fc_subrc = 4.
    IF fu_bill = 'N'.
      MOVE-CORRESPONDING ft_vbrk TO t_error.
      t_error-msg = 'Accounting document has not been posted'.
      APPEND t_error.
    ENDIF.
    DELETE ft_vbrk.
  ENDIF.

ENDFORM.                    " F_CHECK_ACCOUNTING

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_TAX_DONE
*&---------------------------------------------------------------------*
*&  This routine checks whether the billing has already had its faktur
*&  pajak processed (stored in ZGDTXDt0002)
*&  This type of billing should not be processed anymore (except for
*&  RPC program)
*&---------------------------------------------------------------------*
*&  ->FT_VBRK   - Billing table
*&  ->FU_VKORG  - Sales organization / Company code
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&  <-FC_SUBRC  - Return code (Error: FU_SUBRC <> 0)
*&---------------------------------------------------------------------*
FORM f_check_tax_done USING  fu_vbrk  LIKE t_vbrk
                             fu_vkorg fu_gsber
                             fu_spart
                    CHANGING fc_subrc.

  READ TABLE t_process WITH KEY vbeln = fu_vbrk-vbeln
                       BINARY SEARCH.
  IF sy-subrc = 0.
    fc_subrc = 5.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    t_error-msg = 'Billing has been processed'.
    APPEND t_error.
  ELSE.
    fc_subrc = 0.
  ENDIF.

ENDFORM.                    " F_CHECK_TAX_DONE

*&---------------------------------------------------------------------*
*&      Form  F_GET_PKP
*&---------------------------------------------------------------------*
*&  This routine gets the PKP for the branch or for the HO based on
*& config in table ZGDTXDT0103 for the particular branch and business
*& line. if PKPFL is X then get Heach office PKP else Branch PKP.
*&---------------------------------------------------------------------*
*&  ->FU_VKORG      - Sales organization / Company code
*&  ->FU_GSBER      - Business Area
*&  ->FU_SPART      - Division
*&  ->FU_BRNCH      - Branch
*&  ->FU_BUSLN      - Business line
*&  ->FU_FAKDAT     - Tax processing date
*&  <-FC_PETUGAS    - Tax officer 1
*&  <-FC_PETUGAS2   - Tax officer 2 (bench)
*&  <-FC_AKTIF      - Active indicator
*&                    (1-Tax officer 1 is active;
*&                     2-Tax officer 2 is active)
*&  <-FC_JABAT      - Tax officer 1 official position
*&  <-FC_JABAT2     - Tax officer 2 official position
*&  <-FC_FPONE      - Prefix 1 for Tax form number
*&  <-FC_FPTWO      - Prefix 2 for Tax form number
*&  <-FC_OBJRANGE   - Number range object id for the tax form
*&  <-FC_PKPNPWP    - Home NPWP
*&  <-FC_PKPNAME    - PKP name
*&  <-FC_PKPADDRS1  - PKP address 1
*&  <-FC_PKPADDRS2  - PKP address 2
*&  <-FC_PKPKUH     - PKP
*&  <-FC_PKPCITY    - PKP City
*&  <-FC_PKPPOSTAL  - PKP postal code
*&  <-FC_NR_GSBER   - Business area used for number range
*&  <-FC_NAME_KAADM - Branch Administration head name
*&  <-FC_NAME_KACAB - Branch Head name
*&  <-FC_KAADM      - Administration head (position)
*&  <-FC_KACAB      - Branch head (position)
*&---------------------------------------------------------------------*
FORM f_get_pkp USING fu_vkorg      fu_gsber    fu_spart
                     fu_brnch      fu_busln    fu_bukrs
                     fu_fakdat
                     fu_flag_reprint fu_fpone  fu_fptwo
          CHANGING fc_petugas    fc_petugas2   fc_aktif     fc_jabat
                   fc_jabat2     fc_fpone      fc_fptwo     fc_objrange
                   fc_pkpnpwp    fc_pkpname    fc_pkpaddrs1 fc_pkpaddrs2
                   fc_pkpkuh     fc_pkpcity    fc_pkppostal fc_nr_brnch
                   fc_name_kaadm fc_name_kacab fc_kaadm     fc_kacab
                   fc_coretax.

  READ TABLE t_tx00103 WITH KEY brnch = fu_brnch
                                busln = fu_busln.

  IF fu_flag_reprint IS INITIAL.
    SELECT masafrom pkpnpwp vspo pkpname pkpaddrs1 pkpaddrs2 pkpkuh
           pkpcity pkppostal aktif petugas petugas2 jabat jabat2
           fpone fptwo objrange nameadm jabatadm namecab jabatcab
           coretax
           INTO CORRESPONDING FIELDS OF TABLE t_pkp
           FROM zgdtxdt0005
* Changed by rama
           WHERE brnch = fu_brnch AND
*           WHERE vkorg = fu_vkorg AND
*                 gsber = fu_gsber AND
* end of Change by rama
                 masafrom <= fu_fakdat.
  ELSE.
    SELECT masafrom pkpnpwp vspo pkpname pkpaddrs1 pkpaddrs2 pkpkuh
           pkpcity pkppostal aktif petugas petugas2 jabat jabat2
           fpone fptwo objrange nameadm jabatadm namecab jabatcab
           coretax
           INTO CORRESPONDING FIELDS OF TABLE t_pkp
           FROM zgdtxdt0005
* Changed by rama
           WHERE brnch = fu_brnch AND
*           WHERE vkorg = fu_vkorg AND
*                 gsber = fu_gsber AND
* end of Change by rama
                 masafrom <= fu_fakdat AND
                 fpone = fu_fpone      AND
                 fptwo = fu_fptwo.
  ENDIF.

  IF sy-subrc = 0.
    SORT t_pkp BY masafrom DESCENDING.
    READ TABLE t_pkp INDEX 1.

    IF t_tx00103-pkpfl IS INITIAL.
      mac_from_variabel d_b t_pkp- fu_.
*      mac_from_variabel fc_ t_pkp- fu_.
      fc_petugas  = t_pkp-petugas.
      fc_petugas2 = t_pkp-petugas2.
      fc_name_kaadm = t_pkp-nameadm.
      fc_name_kacab = t_pkp-namecab.
      fc_kaadm      = t_pkp-jabatadm.
      fc_kacab      = t_pkp-jabatcab.
      fc_coretax    = t_pkp-coretax.
      d_baktif = t_pkp-aktif.
    ELSE.
      PERFORM f_get_pkp_head_office
              USING fu_vkorg    fu_gsber
                    fu_brnch    fu_busln     fu_bukrs
                    fu_fakdat   fu_fpone     fu_fptwo
           CHANGING fc_petugas  fc_petugas2  fc_aktif
                    fc_jabat    fc_jabat2    fc_fpone
                    fc_fptwo    fc_objrange  fc_pkpnpwp
                    fc_pkpname  fc_pkpaddrs1 fc_pkpaddrs2
                    fc_pkpkuh   fc_pkpcity   fc_pkppostal
*                    fc_nr_gsber
                    fc_nr_brnch
                    fc_name_kaadm fc_name_kacab fc_kaadm fc_kacab
                    fc_coretax.
      mac_from_variabel d_h fc_ fc_nr_.
      d_haktif = fc_aktif.
    ENDIF.


  ELSE.
****Use common (head office)
    PERFORM f_get_pkp_head_office
            USING fu_vkorg    fu_gsber
                  fu_brnch    fu_busln     fu_bukrs
                  fu_fakdat   fu_fpone     fu_fptwo
         CHANGING fc_petugas  fc_petugas2  fc_aktif
                  fc_jabat    fc_jabat2    fc_fpone
                  fc_fptwo    fc_objrange  fc_pkpnpwp
                  fc_pkpname  fc_pkpaddrs1 fc_pkpaddrs2
                  fc_pkpkuh   fc_pkpcity   fc_pkppostal
*                  fc_nr_gsber
                  fc_nr_brnch
                  fc_name_kaadm fc_name_kacab fc_kaadm fc_kacab
                  fc_coretax.
    mac_from_variabel d_h fc_ fc_nr_.
    d_haktif = fc_aktif.
  ENDIF.

**Get KaCab & ADH (from STANDARD TEXT)
* Commented by Rama
* Get values from ZGDTXdt0005 table instead for ADH and CAB
*  PERFORM f_get_stdtext
*          USING 'ZFALST_TYT_' fu_gsber:
*                c_name_kaadm fc_name_kaadm,
*                c_name_kacab fc_name_kacab,
*                c_jab_kaadm  fc_kaadm,
*                c_jab_kacab  fc_kacab.
ENDFORM.                    " F_GET_PKP

*&---------------------------------------------------------------------*
*&      Form  F_GET_PKP_HEAD_OFFICE
*&---------------------------------------------------------------------*
*&  This routine retrieves Head office PKP info. This info will only
*&  be retrieved from Head office if only the branch PKP is not
*&  applicable/not found for the selected billing division.
*&---------------------------------------------------------------------*
*&  ->FU_VKORG    - Sales organization / Company code
*&  ->FU_GSBER    - Business Area
*&  ->FU_BRNCH    - Branch
*&  ->FU_BUSLN    - Business line
*&  ->FU_FAKDAT   - Tax processing date
*&  <-FC_PETUGAS  - Tax officer 1
*&  <-FC_PETUGAS2 - Tax officer 2 (bench)
*&  <-FC_AKTIF    - Active indicator
*&                  (1-Tax officer 1 is active;
*&                   2-Tax officer 2 is active)
*&  <-FC_JABAT    - Tax officer 1 official position
*&  <-FC_JABAT2   - Tax officer 2 official position
*&  <-FC_FPONE    - Prefix 1 for Tax form number
*&  <-FC_FPTWO    - Prefix 2 for Tax form number
*&  <-FC_OBJRANGE - Number range object id for the tax form
*&  <-FC_PKPNPWP  - Home NPWP
*&  <-FC_PKPNAME  - PKP name
*&  <-FC_PKPADDRS1- PKP address 1
*&  <-FC_PKPADDRS2- PKP address 2
*&  <-FC_PKPKUH   - PKP
*&  <-FC_PKPCITY  - PKP City
*&  <-FC_PKPPOSTAL- PKP postal code
*&  <-FC_NR_GSBER - Business area used for number range
*&---------------------------------------------------------------------*
FORM f_get_pkp_head_office USING    fu_vkorg
                                    fu_gsber
                                    fu_brnch
                                    fu_busln
                                    fu_bukrs
                                    fu_fakdat
                                    fu_fpone
                                    fu_fptwo
                           CHANGING fc_petugas
                                    fc_petugas2
                                    fc_aktif
                                    fc_jabat
                                    fc_jabat2
                                    fc_fpone
                                    fc_fptwo
                                    fc_objrange
                                    fc_pkpnpwp
                                    fc_pkpname
                                    fc_pkpaddrs1
                                    fc_pkpaddrs2
                                    fc_pkpkuh
                                    fc_pkpcity
                                    fc_pkppostal
*                                    fc_nr_gsber
                                    fc_nr_brnch
                                    fc_name_kaadm
                                    fc_name_kacab
                                    fc_kaadm
                                    fc_kacab
                                    fc_coretax.

  DATA lt_gsber_head LIKE bseg-gsber.
  DATA lt_pkp_head   LIKE t_pkp OCCURS 1 WITH HEADER LINE.
  DATA ld_ho_brnch LIKE zgdtxdt0101-brnch.

*-added by Rahmadi
*--To get a branch that is assigned as Head office of the Company
*--A Company code must have a branch assigned as head office to work
*--with the program
  SELECT SINGLE brnch INTO ld_ho_brnch
                      FROM zgdtxdt0101
                      WHERE bukrs = fu_bukrs AND
                            ho_ind = 'X'.
  IF sy-subrc <> 0.
    MESSAGE e000(ztx)
            WITH 'Head office is not assigned for company code'
                 fu_bukrs.
  ENDIF.
*-end of addition

  SELECT masafrom pkpnpwp vspo pkpname pkpaddrs1 pkpaddrs2 pkpkuh
           pkpcity pkppostal aktif petugas petugas2 jabat jabat2
           fpone fptwo objrange nameadm jabatadm namecab jabatcab
           coretax
           INTO CORRESPONDING FIELDS OF TABLE lt_pkp_head
           FROM zgdtxdt0005
* changed by Rama
           WHERE  bukrs     = fu_bukrs       AND
                  brnch     = ld_ho_brnch    AND  "modif by rahmadi
*           WHERE vkorg     =  fu_vkorg      AND
*                 gsber     =  lt_gsber_head AND
* Changed by rama
                 masafrom <= fu_fakdat.
  IF sy-subrc = 0.
    SORT lt_pkp_head BY masafrom DESCENDING.
    READ TABLE lt_pkp_head INDEX 1.
  ELSE.
    MESSAGE e000(ztx)
            WITH 'Please maintain PKP data for Head office'.
  ENDIF.

  fc_petugas   = lt_pkp_head-petugas.
  fc_petugas2  = lt_pkp_head-petugas2.
  fc_aktif     = lt_pkp_head-aktif.
  fc_jabat     = lt_pkp_head-jabat.
  fc_jabat2    = lt_pkp_head-jabat2.
  fc_fpone     = lt_pkp_head-fpone.
  fc_fptwo     = lt_pkp_head-fptwo.
  fc_objrange  = lt_pkp_head-objrange.
  fc_pkpnpwp   = lt_pkp_head-pkpnpwp.
  fc_pkpname   = lt_pkp_head-pkpname.
  fc_pkpaddrs1 = lt_pkp_head-pkpaddrs1.
  fc_pkpaddrs2 = lt_pkp_head-pkpaddrs2.
  fc_pkpkuh    = lt_pkp_head-pkpkuh.
  fc_pkpcity   = lt_pkp_head-pkpcity.
  fc_pkppostal = lt_pkp_head-pkppostal.
*  fc_nr_gsber  = lt_gsber_head.
  fc_nr_brnch  = ld_ho_brnch.
  fc_name_kaadm = lt_pkp_head-nameadm.
  fc_name_kacab = lt_pkp_head-namecab.
  fc_kaadm      = lt_pkp_head-jabatadm.
  fc_kacab      = lt_pkp_head-jabatcab.
  fc_coretax    = lt_pkp_head-coretax.

ENDFORM.                    " F_GET_PKP_HEAD_OFFICE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CLOSING_PERIOD
*&---------------------------------------------------------------------*
*&  This routine checks whether the tax period for the selected billing
*&  has been closed. The billing should only be processed in an open
*&  period. If this routine is performed for a PERIOD END (AKHIR MASA)
*&  process, global variable D_PERIOD_END must have been set to 'X',
*&  then the user still can proceed it in a month after.
*&---------------------------------------------------------------------*
*&  ->FU_MASATX - Tax period
*&  ->FU_VKORG  - Sales organization / Company code
*&  ->FU_GSBER  - Business Area
*&---------------------------------------------------------------------*
FORM f_check_closing_period USING fu_masatx
                                  fu_vkorg
                                  fu_gsber
                                  fu_brnch
                                  fu_tc.

  DATA ld_month(2)     TYPE n.
  DATA ld_lastmonth(2) TYPE n.
  DATA ld_year(4)      TYPE n.
  DATA ld_lastper      LIKE zgdtxdt0004-masatx.
  DATA ld_closedat     LIKE zgdtxdt0004-closedat.
  DATA ld_masatx       LIKE zgdtxdt0004-masatx.
  DATA ld_masatx0      LIKE zgdtxdt0004-masatx.

**For PERIOD END, Processed billing must be dated a month before
  IF NOT d_period_end IS INITIAL.   "PERIOD END (AKHIR MASA) process
    PERFORM f_get_last_month USING fu_masatx
                             CHANGING ld_masatx0.
  ELSE.                             "CASH BASIS
    ld_masatx0 = fu_masatx.
  ENDIF.
**For CASH BASIS, Faktur date should not be within a closed period
**Check branch based closing period
  SELECT SINGLE masatx closedat INTO (ld_masatx,ld_closedat)
         FROM zgdtxdt0004
* Changed by Rama
* Branch will uniquely identify the company so no need to use bukrs.
*         WHERE vkorg = fu_vkorg AND gsber = fu_gsber   AND
         WHERE brnch = fu_brnch   AND
* end of change by Rama
              masatx = ld_masatx0.
  IF sy-subrc = 0.
***modified by Rahmadi
*    IF fu_tc = 'X'.   "Only for sederhana
*      PERFORM f_get_lastplus USING ld_masatx0.
*    ELSE.
    IF fu_tc IS INITIAL.  "Non Sederhana
***end of modification
      IF ld_closedat <> '00000000'.
        MESSAGE e506(ztx) WITH ld_masatx fu_brnch.
      ENDIF.
    ENDIF.
  ELSE.
    IF fu_tc = 'X'.
      MESSAGE e506(ztx) WITH ld_masatx0.
    ELSE.
      CLEAR: ld_month, ld_year, ld_lastmonth.
      PERFORM f_get_last_month USING ld_masatx0
                               CHANGING ld_lastper.
      MESSAGE e507(ztx) WITH ld_lastper fu_brnch.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CHECK_CLOSING_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRICE
*&---------------------------------------------------------------------*
*&  This routine retrieves all tax-related prices of the selected
*&  billings. All the tax-related prices have their pricing procedure
*&  and pricing condition defined in ZGDTXDt0008 table
*&---------------------------------------------------------------------*
*&  ->FT_VBRK      - Billing table
*&  ->FU_VKORG     - Sales organization / Company code
*&  ->FU_SPART     - Division
*&  <-FT_PRICEALL  - Internal table containing all prices for each
*&                   billing item
*&---------------------------------------------------------------------*
FORM f_get_price TABLES ft_vbrk     STRUCTURE t_vbrk
                        ft_priceall STRUCTURE t_priceall.
*                 USING  fu_vkorg
*                        fu_spart.

  DATA lt_vbrk LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
  DATA ld_from LIKE sy-tabix.
  DATA ld_to   LIKE sy-tabix.
  RANGES: lr_kalsm FOR vbrk-kalsm.

  DATA  BEGIN OF lt_konv OCCURS 1.
  DATA: knumv LIKE konv-knumv,
        kposn LIKE konv-kposn,
        kschl LIKE konv-kschl,
        kwert LIKE konv-kwert,
        kbetr LIKE konv-kbetr,
        waers LIKE konv-waers.
  DATA  END   OF lt_konv.

  DATA lw_konv LIKE lt_konv.

  DATA  BEGIN OF lt_price OCCURS 1.
  DATA: kalsm    LIKE zgdtxdt0008-kalsm,
        ptype    LIKE zgdtxdt0008-ptype,
        indicate LIKE zgdtxdt0008-indicate,
        ppnbmflg LIKE zgdtxdt0008-ppnbmflg,
        kartv    LIKE zgdtxdt0008-kartv.
  DATA  END   OF lt_price.

  DATA lw_price LIKE lt_price.

  DATA: ld_subrc    LIKE sy-subrc,
        ld_idx1     LIKE sy-tabix,
        ld_kwert    LIKE konv-kwert,
        ld_kbetr    LIKE konv-kbetr,
        ld_notfound.

  REFRESH: lr_kalsm.

**Get Billing pricing procedure
  IF NOT ft_vbrk[] IS INITIAL.
    ld_from = 1.
*   c_max_ritems (150) is quite small, it has been change with new
*   variable c_max_ritems_max
*   ld_to   = c_max_ritems.
    ld_to   = c_max_ritems_max.
    REFRESH: lt_konv.
    DO.
      REFRESH: lt_vbrk.
      LOOP AT ft_vbrk FROM ld_from TO ld_to.
        lt_vbrk-knumv = ft_vbrk-knumv.
        lt_vbrk-posnr = ft_vbrk-posnr.
        APPEND lt_vbrk.

*       required in selection below from table ZGDTXDT0008
        lr_kalsm-low = ft_vbrk-kalsm.
        APPEND lr_kalsm.

      ENDLOOP.
      IF lt_vbrk[] IS INITIAL. EXIT. ENDIF.
      SELECT knumv kposn kschl kwert kbetr waers
             APPENDING CORRESPONDING FIELDS OF TABLE lt_konv
             FROM konv
             FOR ALL ENTRIES IN lt_vbrk
             WHERE knumv = lt_vbrk-knumv AND
                   kposn = lt_vbrk-posnr AND
*--- Added by Rama
*    No need to consider accrual conditions so KRUEK will be 'X'
*    Using rebate condition system creates two lines with same condition
*    type but one is used to offset accrual and other for actual credit
*    posting
                   kruek = ' ' AND
*--- End of Addition
***added for Tempo -- take ACTIVE condition ONLY
                   kinak = ' '.
***end of Tempo addition
      ld_from = ld_from + c_max_ritems_max.
      ld_to   = ld_to   + c_max_ritems_max.
    ENDDO.

    IF NOT lt_konv[] IS INITIAL.
      CLEAR: ld_from, ld_to.
******Get price
      REFRESH lt_price.
      ld_from = 1.
      ld_to = c_max_ritems.
*     replace DO and ENDO with direct select  - Humayun
*     performance issue
*      lr_kalsm-sign = 'I'.
*      lr_kalsm-option = 'EQ'.
*      DO.
*        REFRESH lr_kalsm.
*        LOOP AT ft_vbrk FROM ld_from TO ld_to.
*          lr_kalsm-low = ft_vbrk-kalsm.
*          APPEND lr_kalsm.
*        ENDLOOP.
*        IF lr_kalsm[] IS INITIAL.
*          EXIT.
*        ENDIF.
*        ld_from = ld_from + c_max_ritems.
*        ld_to   = ld_to   + c_max_ritems.
*
*        SELECT kalsm kartv ptype indicate ppnbmflg
*               APPENDING CORRESPONDING FIELDS OF TABLE lt_price
*               FROM ZGDTXdt0008
*               WHERE kalsm IN lr_kalsm.
*      ENDDO.
      SORT lr_kalsm BY low.
      DELETE ADJACENT DUPLICATES FROM lr_kalsm COMPARING low.
      IF NOT lr_kalsm[] IS INITIAL.
        SELECT kalsm kartv ptype indicate ppnbmflg
               APPENDING CORRESPONDING FIELDS OF TABLE lt_price
               FROM zgdtxdt0008
               FOR ALL ENTRIES IN lr_kalsm
               WHERE kalsm EQ lr_kalsm-low.
      ENDIF.

      IF NOT lt_price[] IS INITIAL.
        SORT ft_vbrk BY kalsm knumv posnr.
        SORT lt_price BY kalsm ptype kartv.
        DELETE ADJACENT DUPLICATES FROM lt_price
                                   COMPARING kalsm ptype kartv.
        SORT lt_konv BY knumv kposn kschl.
*-------  Assign the prices to the billing items
        CLEAR: lw_konv, lw_price, ld_notfound.
        LOOP AT ft_vbrk.
          READ TABLE lt_price WITH KEY kalsm = ft_vbrk-kalsm
                              BINARY SEARCH.
          IF sy-subrc = 0.
            ld_idx1 = sy-tabix.
            LOOP AT lt_price.
              MOVE-CORRESPONDING lt_price TO lw_price.
              IF lw_price-kalsm = ft_vbrk-kalsm.
                READ TABLE lt_konv WITH KEY knumv = ft_vbrk-knumv
                                            kposn = ft_vbrk-posnr
                                            kschl = lw_price-kartv
                                            BINARY SEARCH.
                IF sy-subrc = 0.
                  IF lw_price-ptype = d_ptype_mex OR
                     lw_price-ptype = d_ptype_min.
                    macro_price_normalization lt_konv-kwert.
                    IF lt_konv-kwert > ld_kwert.
                      ld_kwert      = lt_konv-kwert.
                    ENDIF.
                  ELSE.
                    ld_kwert = ld_kwert + lt_konv-kwert.
                    ld_kbetr = lt_konv-kbetr.
                  ENDIF.
                ENDIF.
              ELSE.
                CONTINUE.
              ENDIF.
              AT END OF ptype.
                IF NOT ld_kwert IS INITIAL.
                  macro_price_normalization ld_kwert.
                  macro_price_normalization ld_kbetr.
                  ft_priceall-vbeln    = ft_vbrk-vbeln.
                  ft_priceall-posnr    = ft_vbrk-posnr.
                  ft_priceall-ptype    = lw_price-ptype.
                  ft_priceall-indicate = lw_price-indicate.
                  ft_priceall-ppnbmflg = lw_price-ppnbmflg.
                  ft_priceall-kwert    = ld_kwert.
                  ft_priceall-kbetr    = ld_kbetr.
                  ft_priceall-waers    = lt_konv-waers.
                  APPEND ft_priceall.
                ENDIF.
                CLEAR: ld_kwert, ld_kbetr, ld_notfound.
              ENDAT.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
        SORT ft_priceall BY vbeln posnr ptype.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_PRICE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACCOUNTING_DOCS
*&---------------------------------------------------------------------*
*&  This routine gets accounting documents for the billing based on
*&  the billing number stored in BKPF-XBLNR
*&---------------------------------------------------------------------*
*&  ->FT_VBRK   - Billing table
*&  ->FU_VKORG  - Sales organization / Company code
*&---------------------------------------------------------------------*
FORM f_get_accounting_docs TABLES ft_vbrk STRUCTURE t_vbrk
                           USING  fu_bukrs.

  IF NOT ft_vbrk[] IS INITIAL.
    SELECT belnr budat xblnr FROM bkpf
                             INTO TABLE t_bkpf
                             FOR ALL ENTRIES IN ft_vbrk
                             WHERE bukrs = fu_bukrs AND
                                   xblnr = ft_vbrk-xblnr.
    IF sy-subrc = 0.
      SORT t_bkpf BY xblnr.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_ACCOUNTING_DOCS

*&---------------------------------------------------------------------*
*&      Form  F_GET_PROCESSED_BILLING
*&---------------------------------------------------------------------*
*&  This routine retrieves all billing has already had its faktur
*&  pajak processed (stored in ZGDTXDt0002)
*&  This type of billing should not be processed anymore (except for
*&  RPC program)
*&---------------------------------------------------------------------*
*&  ->FT_VBRK   - Billing table
*&  ->FU_VKORG  - Sales organization / Company code
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&---------------------------------------------------------------------*
FORM f_get_processed_billing TABLES ft_vbrk STRUCTURE t_vbrk
                             USING fu_vkorg
                                   fu_gsber
                                   fu_spart
                                   fu_brnch
                                   fu_busln
                                   fu_bukrs.

  DATA: ld_from LIKE sy-tabix,
        ld_to   LIKE sy-tabix.

  RANGES: lr_vbeln    FOR vbrk-vbeln,
          lr_fakturno FOR zgdtxdt0003-fakturno.

  IF NOT ft_vbrk[] IS INITIAL.
    REFRESH t_process.
    ld_from = 1.
    ld_to = c_max_ritems.
    lr_vbeln-sign = 'I'.
    lr_vbeln-option = 'EQ'.
    DO.
      REFRESH lr_vbeln.
      LOOP AT ft_vbrk FROM ld_from TO ld_to.
        lr_vbeln-low = ft_vbrk-vbeln.
        APPEND lr_vbeln.
      ENDLOOP.
      IF lr_vbeln[] IS INITIAL.
        EXIT.
      ENDIF.
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.
*Foreign Currency (Tax & Bill Rate only)
      SELECT vbeln posnr fakturno masatx exclude rate_std rate_tax
                   FROM zgdtxdt0002
                   APPENDING CORRESPONDING FIELDS OF TABLE t_process
* Changed by Rama
                   WHERE brnch = fu_brnch AND
                         busln = fu_busln AND
*                   WHERE vkorg = fu_vkorg AND
*                         gsber = fu_gsber AND
*                         spart = fu_spart AND
* end of Change by Rama
                         vbeln IN lr_vbeln.
    ENDDO.

    IF NOT t_process[] IS INITIAL.
      SORT t_process BY vbeln posnr.
    ENDIF.

****Get Faktur pajak data if executed by RPC program
****to determine printing sequence
    IF NOT d_rpc IS INITIAL AND
       NOT t_process[] IS INITIAL.
      CLEAR: ld_from, ld_to.

      REFRESH t_faktur.
      ld_from = 1.
      ld_to = c_max_ritems.
      lr_fakturno-sign = 'I'.
      lr_fakturno-option = 'EQ'.
      DO.
        REFRESH lr_fakturno.
        LOOP AT t_process FROM ld_from TO ld_to.
          lr_fakturno-low = t_process-fakturno.
          APPEND lr_fakturno.
        ENDLOOP.
        IF lr_fakturno[] IS INITIAL.
          EXIT.
        ENDIF.
        ld_from = ld_from + c_max_ritems.
        ld_to   = ld_to   + c_max_ritems.

        SELECT fakturno cetakke
               FROM zgdtxdt0003
               APPENDING CORRESPONDING FIELDS OF TABLE t_faktur
* Changed by Rama
                   WHERE brnch = fu_brnch AND
                         busln = fu_busln AND
*                   WHERE vkorg = fu_vkorg AND
*                         gsber = fu_gsber AND
*                         spart = fu_spart AND
* end of Change by Rama
                     fakturno IN lr_fakturno AND
                     batal = ''.
      ENDDO.

      IF NOT t_faktur[] IS INITIAL.
        SORT t_faktur BY fakturno.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_PROCESSED_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NPWP
*&---------------------------------------------------------------------*
*&  This routine checks whether the customer in the billing has NPWP
*&  (VBRK-STCEG > 10 digits). This kind of NPWP is considered as valid
*&  NPWP. If NPWP in the billing is not valid, the program will give
*&  error.
*&---------------------------------------------------------------------*
*&  ->FT_VBRK   - Billing table
*&  <-FC_NPWP   - NPWP used
*&  <-FC_SUBRC  - Return code (Error: FU_SUBRC <> 0)
*&---------------------------------------------------------------------*
FORM f_check_npwp USING  fu_vbrk LIKE t_vbrk
                  CHANGING fc_subrc
                           fc_npwp.

  DATA ld_length TYPE i.
  DATA ld_npwp LIKE vbrk-stceg.
  DATA ld_xcpdk LIKE kna1-xcpdk.
  DATA ld_subrc LIKE sy-subrc.

  ld_length = strlen( fu_vbrk-stceg ).
  IF sy-datum GE va_datab.
    fc_subrc = 0.
    fc_npwp = fu_vbrk-stceg.
  ELSE.
    IF ld_length <= 10.
      fc_subrc = 3.
      MOVE-CORRESPONDING fu_vbrk TO t_error.
      t_error-msg = 'The customer has no valid NPWP'.
      APPEND t_error.
    ELSE.
      fc_subrc = 0.
      fc_npwp = fu_vbrk-stceg.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_NPWP

*&---------------------------------------------------------------------*
*&      Form  F_GET_CANC_BILL_ACC_DOCS
*&---------------------------------------------------------------------*
*&  This routine retrieves all accounting documents and cancel billings
*&  related to the selected normal billing.
*&---------------------------------------------------------------------*
*&  <-FT_VBFAC  - Cancel Billing table
*&  <-FT_VBFAA  - Accounting documents table
*&  ->FU_VBELN  - Normal billing number
*&  ->FU_POSNR  - Normal billing item number
*&---------------------------------------------------------------------*
FORM f_get_canc_bill_acc_docs TABLES ft_vbfac STRUCTURE t_vbfac
                                     ft_vbfaa STRUCTURE t_vbfaa
                              USING  fu_vbrk  LIKE t_vbrk
                                     fu_top
                            CHANGING fc_sbc
                                     fc_top.

  DATA: lt_vbfa  LIKE vbfa OCCURS 1 WITH HEADER LINE,
        lt_vbfac LIKE vbfa OCCURS 1 WITH HEADER LINE,
        lt_vbfaa LIKE vbfa OCCURS 1 WITH HEADER LINE,
        ld_vbco6 LIKE vbco6,
        ld_can   TYPE c,
        ld_zfbdt LIKE bsid-zfbdt,
        ld_zbd1t LIKE bsid-zbd1t.

  CLEAR fc_sbc.
  ld_vbco6-vbeln = fu_vbrk-vbeln.
  ld_vbco6-posnr = fu_vbrk-posnr.

  CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
    EXPORTING
      comwa         = ld_vbco6
    TABLES
      vbfa_tab      = lt_vbfa
    EXCEPTIONS
      no_vbfa       = 1
      no_vbuk_found = 2
      OTHERS        = 3.

  IF sy-subrc = 0.
****Get Cancelled billing
    lt_vbfac[] = lt_vbfa[].
    DELETE lt_vbfac WHERE NOT vbtyp_n = 'N'.
    APPEND LINES OF lt_vbfac TO ft_vbfac.

*---get cancel number if delivery already deleted
    CLEAR ld_can.
    IF fu_vbrk-fksto = 'X' AND lt_vbfac[] IS INITIAL.
      SELECT SINGLE vbeln INTO ft_vbfac-vbeln
             FROM vbrk
             WHERE sfakn EQ fu_vbrk-vbeln.
      IF sy-subrc = 0.
        ft_vbfac-posnn = fu_vbrk-posnr.
        ft_vbfac-posnv = fu_vbrk-posnr.
        ft_vbfac-vbelv = fu_vbrk-vbeln.
        APPEND ft_vbfac.
        ld_can = 'X'.
      ENDIF.
    ENDIF.

****Get Accounting documents
    lt_vbfaa[] = lt_vbfa[].
    DELETE lt_vbfaa WHERE NOT vbtyp_n = '+'.

*--- cek TOP for billing
    IF NOT lt_vbfaa[] IS INITIAL.
      IF fu_top = 'X'.
        READ TABLE lt_vbfaa WITH KEY vbtyp_v = 'M'.
        IF sy-subrc = 0.
          SELECT SINGLE zfbdt zbd1t INTO (ld_zfbdt, ld_zbd1t)
                 FROM bsid
                 WHERE bukrs EQ fu_vbrk-bukrs
                   AND kunnr EQ fu_vbrk-kunrg
                   AND gjahr EQ lt_vbfaa-erdat+0(4)
                   AND belnr EQ lt_vbfaa-vbeln
                   AND bschl EQ '01'.
          IF sy-subrc = 0.
            PERFORM f_cek_date TABLES lt_vbfaa
                                USING fu_vbrk ld_zfbdt ld_zbd1t
                            CHANGING  fc_sbc  fc_top.
          ELSE.
            SELECT SINGLE zfbdt zbd1t INTO (ld_zfbdt, ld_zbd1t)
                   FROM bsad
                   WHERE bukrs EQ fu_vbrk-bukrs
                     AND kunnr EQ fu_vbrk-kunrg
                     AND gjahr EQ lt_vbfaa-erdat+0(4)
                     AND belnr EQ lt_vbfaa-vbeln
                     AND bschl EQ '01'.

            IF sy-subrc = 0.
              PERFORM f_cek_date TABLES lt_vbfaa
                                  USING fu_vbrk ld_zfbdt ld_zbd1t
                              CHANGING  fc_sbc  fc_top.
            ELSE.
              IF NOT d_period_end IS INITIAL.
                MOVE-CORRESPONDING fu_vbrk TO t_error.
                CONCATENATE 'This Billing has previous '
                            'month term of payment'
                            INTO t_error-msg.
                APPEND t_error.
                REFRESH lt_vbfaa. CLEAR lt_vbfaa.
                fc_sbc = 1.
              ELSE.
                fc_top = fu_vbrk-fkdat.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    APPEND LINES OF lt_vbfaa TO ft_vbfaa.

*---get cancel number if delivery already deleted
    IF ld_can = 'X' AND fu_vbrk-fksto = 'X'.
      SELECT SINGLE belnr INTO ft_vbfaa-vbeln
             FROM bkpf
             WHERE awtyp EQ 'VBRK'
               AND awkey EQ ft_vbfac-vbeln.
      IF sy-subrc = 0.
        ft_vbfaa-posnv = fu_vbrk-posnr.
        ft_vbfaa-vbelv = ft_vbfac-vbeln.
        APPEND ft_vbfaa.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CANC_BILL_ACC_DOCS

*&---------------------------------------------------------------------*
*&      Form  F_GET_RETURN_PRICE_ADJ
*&---------------------------------------------------------------------*
*&  This routine retrieves Return billing & Price Adjustment billing
*&  related to the selected normal billing.
*&  If the follow-up billings have a linked cancel billing linked,
*&  it will be eliminated by the cancel billing (it will not be
*&  considered anymore).
*&---------------------------------------------------------------------*
*&  <-FT_VBRKFO - Follow-up Billing table (Return & Price Adjustment)
*&  <-FT_VBRKFX - Follow-up Cancel Billing table
*&  ->FT_FKDAT  - Billing date range for the follow-up billings
*&  ->FT_STCEG  - NPWP
*&  ->FU_VKORG  - Sales organization / Company code
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&  ->FU_RPC    - 'X' if it is performed by RPC program
*&---------------------------------------------------------------------*
FORM f_get_return_price_adj TABLES ft_vbrkfo STRUCTURE t_vbrk
                                   ft_vbrkfx STRUCTURE t_vbrk
                                   ft_vbrk   STRUCTURE t_vbrk
                                   ft_fkdat  STRUCTURE r_fkdat
                                   ft_stceg  STRUCTURE r_stceg
                            USING  fu_vkorg  fu_gsber
                                   fu_spart  fu_rpc
                                   fu_brnch  fu_busln.

  DATA lt_vbrk   LIKE t_vbrk OCCURS 0 WITH HEADER LINE.
  DATA ld_from   LIKE sy-tabix.
  DATA ld_to     LIKE sy-tabix.

  DATA lt_vbfa   LIKE vbfa OCCURS 1 WITH HEADER LINE.
  DATA lt_vbfas  LIKE vbfa OCCURS 1 WITH HEADER LINE.
  DATA ld_tabixo LIKE sy-tabix.
  DATA ld_tabixx LIKE sy-tabix.
  DATA ld_subrc  LIKE sy-subrc.
  DATA ld_user   LIKE sy-msgv1.
  DATA lw_vbfa   LIKE vbfa.
  DATA lw_vbrk   LIKE t_vbrk.
  DATA lt_cancfo LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
  DATA lw_cancfo LIKE t_vbrk.

**Get Return & Price adjustment billing
  IF NOT ft_vbrk[] IS INITIAL.
    ld_from = 1.
    ld_to   = c_max_ritems.
    REFRESH: lt_vbfa.
    DO.
      REFRESH: lt_vbrk.
      LOOP AT ft_vbrk FROM ld_from TO ld_to.
        lt_vbrk-vbeln = ft_vbrk-vbeln.
        lt_vbrk-posnr = ft_vbrk-posnr.
        APPEND lt_vbrk.
      ENDLOOP.
      IF lt_vbrk[] IS INITIAL. EXIT. ENDIF.
      SELECT vbelv posnv vbeln posnn vbtyp_n
             APPENDING CORRESPONDING FIELDS OF TABLE lt_vbfa
             FROM vbfa
             FOR ALL ENTRIES IN lt_vbrk
             WHERE vbelv = lt_vbrk-vbeln AND
                   posnv = lt_vbrk-posnr AND
                 ( vbtyp_n = 'O' OR
                   vbtyp_n = 'S' OR
****added for Tempo - Debit memo
                   vbtyp_n = 'P' ).
****end of Tempo addition
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.
    ENDDO.

    IF NOT lt_vbfa[] IS INITIAL.
      SORT lt_vbfa BY vbeln posnn.

******Lock selected follow-up billings
      IF fu_rpc IS INITIAL.
        LOOP AT lt_vbfa.
          MOVE-CORRESPONDING lt_vbfa TO lw_vbfa.
          lw_vbrk-vbeln = lw_vbfa-vbeln.
          AT NEW vbeln.
            CLEAR ld_subrc.
            PERFORM f_lock_billing USING    lw_vbrk
                                   CHANGING ld_subrc
                                            ld_user.
            PERFORM f_process_locked_foll_billing TABLES ft_vbrk
                                                  USING lw_vbfa
                                                        ld_user
                                                        ld_subrc.
          ENDAT.
          AT END OF vbeln.
            IF ld_subrc <> 0.
              DELETE lt_vbfa WHERE vbeln = lw_vbrk-vbeln.
            ENDIF.
          ENDAT.
        ENDLOOP.
      ENDIF.


******Separate Follow-up billings from its cancellation docs
      lt_vbfas[] = lt_vbfa[].
      DELETE lt_vbfas WHERE NOT vbtyp_n = 'S'.
      DELETE lt_vbfa WHERE NOT vbtyp_n = 'O'
***added for Tempo -- Debit memo
                       AND NOT vbtyp_n = 'P'.
***end of Tempo addition

      IF NOT lt_vbfa[] IS INITIAL.
        PERFORM f_get_followup_bill_data TABLES lt_vbfa
                                                ft_vbrkfo
                                                ft_fkdat
                                                ft_stceg.
*--- Commented by Rama
* Data on organisation already restricted in billing and hence
* this does not make sense to restrict further.
*                                         USING  fu_vkorg
*                                                fu_spart
*                                                fu_gsber.
*--- End of comment
        SORT ft_vbrkfo BY vbeln posnr.

        IF NOT lt_vbfas[] IS INITIAL.
          PERFORM f_get_followup_bill_data TABLES lt_vbfas
                                                  ft_vbrkfx
                                                  ft_fkdat
                                                  ft_stceg.
*--- Commented by Rama
* Data on organisation already restricted in billing and hence
* this does not make sense to restrict further.
*                                         USING  fu_vkorg
*                                                fu_spart
*                                                fu_gsber.
*--- End of comment
**********Eliminate Return/Price Adj billings with its Cancel billings
          LOOP AT ft_vbrkfx.
            ld_tabixx = sy-tabix.
************Check Preceeding docs
            READ TABLE ft_vbrkfo WITH KEY vbeln = ft_vbrkfx-sfakn
                                          BINARY SEARCH.
            IF sy-subrc = 0.
              ld_tabixo = sy-tabix.
**************Delete Return/Price adjustment that has been cancelled
              MOVE-CORRESPONDING ft_vbrkfo TO lt_cancfo.
              APPEND lt_cancfo.
              MOVE-CORRESPONDING ft_vbrkfx TO lt_cancfo.
              APPEND lt_cancfo.
              DELETE ft_vbrkfo INDEX ld_tabixo.
              DELETE ft_vbrkfx INDEX ld_tabixx.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDLOOP.

*--- Added by Rama
* Delete those records which do not belong to the selection
* of branch and business line
          PERFORM f_select_branch_billing_data TABLES ft_vbrkfx
                                               USING  fu_brnch
                                                      fu_busln.

          IF NOT ft_vbrkfx[] IS INITIAL.
            SORT ft_vbrkfx BY vbelv posnv vbeln posnr fkdat.
          ENDIF.
        ENDIF.

*--- Added by Rama
* Delete those records which do not belong to the selection
* of branch and business line
        PERFORM f_select_branch_billing_data TABLES ft_vbrkfo
                                             USING  fu_brnch
                                                    fu_busln.

        IF NOT ft_vbrkfo[] IS INITIAL.
          SORT ft_vbrkfo BY vbelv posnv vbeln posnr fkdat.
        ENDIF.

********Unlock cancelled billings
        IF NOT lt_cancfo[] IS INITIAL.
          SORT lt_cancfo BY vbeln.
          LOOP AT lt_cancfo.
            MOVE-CORRESPONDING lt_cancfo TO lw_cancfo.
            AT NEW vbeln.
              PERFORM f_unlock_error_billing USING lw_cancfo-vbeln.
            ENDAT.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_RETURN_PRICE_ADJ

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACC_DOCS
*&---------------------------------------------------------------------*
*&  This routine gets posting date (BKPF-BUDAT) of accounting documents
*&  for the billing based on the accounting documents selected in the
*&  Billing history table
*&---------------------------------------------------------------------*
*&  ->FT_VBFAA  - Billing history table containing accounting docs
*&  <-FT_BKPF   - Accounting documents table
*&  ->FU_VKORG  - Sales organization / Company code
*&  ->FU_GJAHR  - Document year
*&---------------------------------------------------------------------*
FORM f_get_acc_docs TABLES ft_bkpf STRUCTURE t_bkpf
                           ft_vbfaa STRUCTURE t_vbfaa
                    USING  fu_bukrs
                           fu_gjahr.

  RANGES: lr_vbeln FOR vbfa-vbeln.

  DATA ld_from LIKE sy-tabix.
  DATA ld_to LIKE sy-tabix.

  IF NOT ft_vbfaa[] IS INITIAL.
    REFRESH ft_bkpf.
    ld_from = 1.
    ld_to = c_max_ritems.
    lr_vbeln-sign = 'I'.
    lr_vbeln-option = 'EQ'.
    DO.
      REFRESH lr_vbeln.
      LOOP AT ft_vbfaa FROM ld_from TO ld_to.
        lr_vbeln-low = ft_vbfaa-vbeln.
        APPEND lr_vbeln.
      ENDLOOP.
      IF lr_vbeln[] IS INITIAL.
        EXIT.
      ENDIF.
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.

      SELECT belnr budat xblnr
             FROM bkpf
             APPENDING CORRESPONDING FIELDS OF TABLE ft_bkpf
*--- Changed by Rama
             WHERE bukrs = fu_bukrs AND
*             WHERE bukrs = fu_vkorg AND
*---- End addition
                   belnr IN lr_vbeln AND
                   gjahr = fu_gjahr.
    ENDDO.

    IF NOT ft_bkpf[] IS INITIAL.
      SORT ft_bkpf BY belnr.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_ACC_DOCS

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ACC_DOCS
*&---------------------------------------------------------------------*
*&  This routine checks whether the billing has already had its
*&  accounting document posted.
*&  The accounting document will only be considered if it is posted
*&  within the same month as the billing (the posting date is considered
*&  stored in billing history table -- VBFA-ERDAT)
*&---------------------------------------------------------------------*
*&  ->FT_VBRK       - Billing table
*&  ->FU_VKORG      - Sales organization / Company code
*&  ->FU_BILLTYPE   - Billing type
*&                    -- error message will be generated only
*&                       for normal billing (type = 'N')
*&  <-FC_BELNR      - Accounting document number
*&  <-FC_SUBRC      - Return code (Error: FU_SUBRC <> 0)
*&---------------------------------------------------------------------*
FORM f_check_acc_docs USING  fu_vbrk LIKE t_vbrk
                             fu_billtype
                      CHANGING fc_belnr
                               fc_subrc.

*-Check accounting documents posting date based on BKPF
  CLEAR : t_vbfaa, t_bkpf.
  READ TABLE t_vbfaa WITH KEY vbelv = fu_vbrk-vbeln
                              posnv = fu_vbrk-posnr
                              BINARY SEARCH.
  READ TABLE t_bkpf WITH KEY belnr = t_vbfaa-vbeln
                             BINARY SEARCH.
  IF sy-subrc = 0.
    IF t_bkpf-budat+4(2) <> fu_vbrk-fkdat+4(2).
      fc_subrc = 3.
      CLEAR fc_belnr.
      IF fu_billtype = 'N'.
        MOVE-CORRESPONDING fu_vbrk TO t_error.
        CONCATENATE 'The billing has been posted to month'
                    t_bkpf-budat+4(2)
                    'and cannot be processed in month'
                    fu_vbrk-fkdat+4(2)
                    INTO t_error-msg
                    SEPARATED BY space.
        APPEND t_error.
      ENDIF.
    ELSE.
      fc_belnr = t_vbfaa-vbeln.
      fc_subrc = 0.
    ENDIF.
  ELSE.
    fc_subrc = 4.
    CLEAR fc_belnr.
    IF fu_billtype = 'N'.
      MOVE-CORRESPONDING fu_vbrk TO t_error.
      t_error-msg = 'Accounting document has not been posted'.
      APPEND t_error.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CHECK_ACC_DOCS

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_AMOUNT
*&---------------------------------------------------------------------*
*&  This routine determines how the price will be displayed in the Tax
*&  form (Faktur pajak). It is only applicable for the price type that
*&  has possibility to be tax-inclusive or tax-exclusive.
*&---------------------------------------------------------------------*
*&  ->FT_VBELN    - Billing number
*&  ->FU_POSNR    - Billing item number
*&  ->FU_PTYPE1   - Price type 1 (tax-exclusive)
*&  ->FU_TYPE2    - Price type 2 (tax-inclusive)
*&  ->FU_TAX      - VAT amount
*&  <-FC_AMOUNT   - Price amount
*&  <-FC_EXAMT    - Price amount (tax-exclusive)
*&  <-FC_INAMT    - Price amount (tax-inclusive)
*&---------------------------------------------------------------------*
FORM f_determine_amount USING   fu_vbeln
                                fu_posnr
                                fu_ptype1
                                fu_ptype2
                                fu_tax
                       CHANGING fc_amount
                                fc_examt
                                fc_inamt.

  READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 ptype = fu_ptype1
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_amount = t_priceall-kwert.
  ELSE.
    READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   ptype = fu_ptype2
                                   BINARY SEARCH.
    IF sy-subrc = 0.
      fc_amount = t_priceall-kwert.
    ELSE.
      fc_amount = 0.
    ENDIF.
  ENDIF.

**Get Amount with Tax Exclusion/Inclusion
  READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 indicate = d_exclude_tax.
  IF sy-subrc = 0.
    fc_examt = fc_amount.
    fc_inamt = fc_amount + ( fu_tax * fc_amount ).
  ELSE.
    READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   indicate = d_include_tax.
    IF sy-subrc = 0.
      fc_inamt = fc_amount.
      fc_examt = fc_amount / ( fu_tax + 1 ).
    ELSE.
      fc_examt = fc_amount.
      fc_inamt = fc_amount.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_DETERMINE_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_PRICE
*&---------------------------------------------------------------------*
*&  This routine determines how the price will be displayed in the Tax
*&  form (Faktur pajak). It is possible that price is tax-inclusive or
*&  tax-exclusive. If a price is PPNBM inclusive, PPNBM amount must be
*&  excluded from the price.
*&---------------------------------------------------------------------*
*&  ->FT_VBELN    - Billing number
*&  ->FU_POSNR    - Billing item number
*&  ->FU_PTYPE1   - Price type 1 (tax-exclusive)
*&  ->FU_TYPE2    - Price type 2 (tax-inclusive)
*&  ->FU_TAX      - VAT amount
*&  ->FU_PPNBM    - PPNBM amount
*&  <-FC_AMOUNT   - Price amount
*&  <-FC_EXAMT    - Price amount (tax-exclusive)
*&  <-FC_INAMT    - Price amount (tax-inclusive)
*&---------------------------------------------------------------------*
FORM f_determine_price USING fu_vbeln  fu_posnr
                             fu_ptype1 fu_ptype2
                             fu_ptype3 fu_ppnbm fu_tax
                    CHANGING fc_amount fc_examt fc_inamt.

  READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 ptype = fu_ptype1
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_amount = t_priceall-kwert.
  ELSE.
    READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   ptype = fu_ptype2
                                   BINARY SEARCH.
    IF sy-subrc = 0.
      fc_amount = t_priceall-kwert.
    ELSE.
      fc_amount = 0.
    ENDIF.
  ENDIF.

*- For another condition type ( PL )
  READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 ptype = fu_ptype3
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_amount = fc_amount + t_priceall-kwert.
  ENDIF.

*----------------------------------------------------------------------*
* Changed by rama
***Exclude PPNBM if it is included in the amount
  IF fc_amount <> 0 AND t_priceall-ppnbmflg = d_include_tax.
    fc_amount = fc_amount - fu_ppnbm.
  ENDIF.
*----------------------------------------------------------------------*

**Get Amount with Tax Exclusion/Inclusion
  READ TABLE t_priceall WITH KEY vbeln    = fu_vbeln
                                 posnr    = fu_posnr
                                 indicate = d_exclude_tax.
  IF sy-subrc = 0.
    fc_examt = fc_amount.
    fc_inamt = fc_amount + ( fu_tax * fc_amount ).
  ELSE.
    READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   indicate = d_include_tax.
    IF sy-subrc = 0.
      fc_inamt = fc_amount.
      fc_examt = fc_amount / ( fu_tax + 1 ).
    ELSE.
      fc_examt = fc_amount.
      fc_inamt = fc_amount.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_DETERMINE_PRICE

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_DPP
*&---------------------------------------------------------------------*
*&  This routine calculates DPP amount
*&---------------------------------------------------------------------*
*&  ->FU_PRICE  - Price amount
*&  ->FU_DISC   - Discount amount
*&  <-FC_DPP    - Calculated DPP amount
*&---------------------------------------------------------------------*
FORM f_determine_dpp USING fu_price fu_disc
                  CHANGING fc_dpp.

  fc_dpp = fu_price - fu_disc.

ENDFORM.                    " F_DETERMINE_DPP

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_VALUE
*&---------------------------------------------------------------------*
*&  This routine selects value for any type of prices displayed on the
*&  Tax form (faktur pajak). The value will only be displayed if it is
*&  not initial
*&---------------------------------------------------------------------*
*&  ->FU_VALUE1  - Value 1
*&  ->FU_VALUE2  - Value 2
*&  <-FC_SELECT  - Selected value
*&---------------------------------------------------------------------*
FORM f_select_value USING fu_value1 fu_value2
                 CHANGING fc_select.

  IF NOT fu_value1 IS INITIAL.
    fc_select = fu_value1.
  ELSE.
    fc_select = fu_value2.
  ENDIF.

ENDFORM.                    " F_SELECT_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_FOLLOWUP_DOCS
*&---------------------------------------------------------------------*
*&  This routine proceeds follow-up documents of a normal billing.
*&  It performs re-calculation of the billing prices depending on the
*&  type of the follow-up billings (Return or Price Adjustment)
*&---------------------------------------------------------------------*
*&  ->FT_VBRKFO   - Follow-up Billing table
*&  ->FU_VBRK     - Normal billing data
*&  ->FU_TAX      - VAT amount
*&  <-FC_ITAMT    - Selling price amount after processing follow-up docs
*&  <-FC_ITDISC   - Discount amount after processing follow-up docs
*&  <-FC_DPP      - DPP amount after processing follow-up docs
*&  <-FC_PPN      - PPN amount after processing follow-up docs
*&  <-FC_PPNBM    - PPNBM amount after processing follow-up docs
*&  <-FC_XPPNBM   - XPPNBM amount after processing follow-up docs
*&  <-FC_ITOTH    - Others amount after processing follow-up docs
*&  <-FC_ITQTY    - Quantity after processing follow-up docs
*&  <-FC_EXAMT    - Selling price (tax-exclusive) amount after
*&                  processing follow-up docs
*&  <-FC_INAMT    - Selling price (tax-inclusive) amount after
*&                  processing follow-up docs
*&  <-FC_ITDISCEX - Discount (tax-exclusive) amount after processing
*&                  follow-up docs
*&  <-FC_ITDISCIN - Discount (tax-inclusive) amount after processing
*&                  follow-up docs
*&  <-FC_STNK     - STNK price amount after processing follow-up docs
*&---------------------------------------------------------------------*
FORM f_followup_docs TABLES   ft_vbrkfo STRUCTURE t_vbrk
                     USING    fu_vbrk   LIKE t_vbrk
                              fu_tax
                     CHANGING fc_itamt  fc_itdisc   fc_dpp
                              fc_ppn    fc_ppnbm    fc_xppnbm
                              fc_itoth  fc_itqty    fc_examt
                              fc_inamt  fc_itdiscex fc_itdiscin
                              fc_stnk
****added by Rahmadi
*--To store PPH 22 & PPH 23 info from the invoices
                              fc_pph22
                              fc_pph23.
****end of addition

  DATA ld_subrcr LIKE sy-tabix.
  DATA ld_tabixo LIKE sy-tabix.
  DATA ld_fkimg  LIKE vbrp-fkimg.
  DATA ld_sitamt LIKE konv-kwert.

**Initialize amount with Normal billing amount
  fc_itamt    = fu_vbrk-itamt.
  fc_itdisc   = fu_vbrk-itdisc.
  fc_dpp      = fu_vbrk-dpp.
  fc_ppn      = fu_vbrk-ppn.
  fc_ppnbm    = fu_vbrk-ppnbm.
  fc_xppnbm   = fu_vbrk-xppnbm.
  fc_itoth    = fu_vbrk-itoth.
  fc_itqty    = fu_vbrk-itqty.
  fc_examt    = fu_vbrk-examt.
  fc_inamt    = fu_vbrk-inamt.
  fc_itdiscex = fu_vbrk-itdiscex.
  fc_itdiscin = fu_vbrk-itdiscin.
  fc_stnk     = fu_vbrk-stnk.
***added by Rahmadi
*--To store PPH 22 & PPH 23 info from the invoices
  fc_pph22    = fu_vbrk-pph22.
  fc_pph23    = fu_vbrk-pph23.
***end of Addition

  LOOP AT ft_vbrkfo WHERE vbelv = fu_vbrk-vbeln AND
                          posnv = fu_vbrk-posnr.
    ld_tabixo = sy-tabix.
    IF ft_vbrkfo-fkart IN r_fkartr.
*----- RETURN
      PERFORM f_amounts    USING ft_vbrkfo
                                 fu_tax
                        CHANGING ft_vbrkfo-itamt
                                 ft_vbrkfo-itdisc
                                 ft_vbrkfo-dpp
                                 ft_vbrkfo-ppn
                                 ft_vbrkfo-ppnbm
                                 ft_vbrkfo-xppnbm
                                 ft_vbrkfo-itoth
                                 ft_vbrkfo-itqty
                                 ft_vbrkfo-examt
                                 ft_vbrkfo-inamt
                                 ft_vbrkfo-itdiscex
                                 ft_vbrkfo-itdiscin
                                 ft_vbrkfo-stnk
*****added by Rahmadi
*--To store PPH 22 & PPH 23 info from the invoices
                                 ft_vbrkfo-pph22
                                 ft_vbrkfo-pph23.
*****end of addition

      fc_itamt    = fc_itamt - ft_vbrkfo-itamt.
      fc_itdisc   = fc_itdisc - ft_vbrkfo-itdisc.
      fc_dpp      = fc_dpp - ft_vbrkfo-dpp.
      fc_ppn      = fc_ppn - ft_vbrkfo-ppn.
      fc_ppnbm    = fc_ppnbm - ft_vbrkfo-ppnbm.
      fc_xppnbm   = fc_xppnbm - ft_vbrkfo-xppnbm.
      fc_itoth    = fc_itoth - ft_vbrkfo-itoth.
      fc_itqty    = fc_itqty - ft_vbrkfo-itqty.
*-----Tempo: to accomodate NR in Credit note form
*-----use quantity in followup billing if qty is zero but
*-----amount is not zero
      IF fc_itqty = 0 AND fc_itamt <> 0.
        fc_itqty = ft_vbrkfo-itqty.
      ENDIF.
*-----end of Tempo changes

      fc_examt    = fc_examt - ft_vbrkfo-examt.
      fc_inamt    = fc_inamt - ft_vbrkfo-inamt.
      fc_itdiscex = fc_itdiscex - ft_vbrkfo-itdiscex.
      fc_itdiscin = fc_itdiscin - ft_vbrkfo-itdiscin.
      fc_stnk     = fc_stnk - ft_vbrkfo-stnk.
****added by Rahmadi
*--Calculate PPH 22 & PPH 23 after processing Follow-up invoices
      fc_pph22    = fc_pph22 - ft_vbrkfo-pph22.
      fc_pph23    = fc_pph23 - ft_vbrkfo-pph23.
****end of addition

*----- Last amount = current amount
      ft_vbrkfo-itamtlast    = ft_vbrkfo-itamt.
      ft_vbrkfo-itdisclast   = ft_vbrkfo-itdisc.
      ft_vbrkfo-dpplast      = ft_vbrkfo-dpp.
      ft_vbrkfo-ppnlast      = ft_vbrkfo-ppn.
      ft_vbrkfo-ppnbmlast    = ft_vbrkfo-ppnbm.
      ft_vbrkfo-xppnbmlast   = ft_vbrkfo-xppnbm.
      ft_vbrkfo-itothlast    = ft_vbrkfo-itoth.
      ft_vbrkfo-itqtylast    = ft_vbrkfo-itqty.
      ft_vbrkfo-examtlast    = ft_vbrkfo-examt.
      ft_vbrkfo-inamtlast    = ft_vbrkfo-inamt.
      ft_vbrkfo-itdiscexlast = ft_vbrkfo-itdiscex.
      ft_vbrkfo-itdiscinlast = ft_vbrkfo-itdiscin.
      ft_vbrkfo-stnklast     = ft_vbrkfo-stnk.
      ft_vbrkfo-trcurr     = ft_vbrkfo-waerk.
      IF ft_vbrkfo-waerk NE c_local_curr.
        IF d_tcode = c_tcode_sederhana OR
           d_tcode = c_tcode_sederhana_single.
*----------- Get tax rate base on ratio defined
*----------- Get base on Billing Date
          PERFORM f_get_tax_rate USING ft_vbrkfo-waerk
                                       fu_vbrk-fkdat
                                       c_local_curr.
        ELSE.
*----------- Get tax rate base on ratio defined
*----------- Get base on Faktur Pajak Date / Faktur Printing date
*----- Koreksi by budi 19/09/2005
*          PERFORM f_get_tax_rate USING ft_vbrkfo-waerk
*                                       fu_vbrk-fakdat
*                                       c_local_curr.
          PERFORM f_get_tax_rate USING ft_vbrkfo-waerk
                                       fu_vbrk-fkdat
                                       c_local_curr.
*----- End of Koreksi by budi 19/09/2005
        ENDIF.
*++++
*----------- Recondition Tax information then save the original
*----------- transactions amount into foreign currency field (F)
        ft_vbrkfo-ppndate = d_tax_valid.
        ft_vbrkfo-itamt_f = ft_vbrkfo-examtlast. "Exclude Tax
        ft_vbrkfo-itdisc_f = ft_vbrkfo-itdiscexlast.
        ft_vbrkfo-itoth_f = ft_vbrkfo-itothlast.
        ft_vbrkfo-dpp_f = ft_vbrkfo-dpplast.
        ft_vbrkfo-ppn_f = ft_vbrkfo-ppnlast.
        ft_vbrkfo-ppnbm_f = ft_vbrkfo-ppnbmlast.
        ft_vbrkfo-xppnbm_f = ft_vbrkfo-xppnbmlast.
        IF d_tcode = c_tcode_satuan OR d_tcode = c_tcode_split.
          ft_vbrkfo-fakppn_f = ft_vbrkfo-ppnlast.
          ft_vbrkfo-fakppnbm_f = ft_vbrkfo-ppnbmlast.
          ft_vbrkfo-fakxppnbm_f = ft_vbrkfo-xppnbmlast.
        ENDIF.
*----------- Translate the billing transaction into local currency
        d_rate_tax = d_rate_tax * d_ratefactor.
        ft_vbrkfo-rate_tax = d_rate_tax / 100.
        ft_vbrkfo-trcurr = ft_vbrkfo-waerk.
        ft_vbrkfo-waerk = c_local_curr.
        ft_vbrkfo-fakcurr = ft_vbrkfo-trcurr.
        ft_vbrkfo-fakrate = ft_vbrkfo-rate_tax.
*----------- Convert DPP & PPN amount into local currency
*----------- This conversion is based on Tax Rate
*----------- Rounding problem when calculating PPN - Hardcode 10%
        ft_vbrkfo-dpp = ft_vbrkfo-dpp * d_rate_tax / 100.
        ft_vbrkfo-dpplast =
                    ft_vbrkfo-dpplast * d_rate_tax / 100.
        IF ft_vbrkfo-spart NE d_used.
          PERFORM f_tax_calc USING fu_vbrk-fkdat '' ft_vbrkfo-dpp 'E'
                             CHANGING ft_vbrkfo-ppn.
          PERFORM f_tax_calc USING fu_vbrk-fkdat '' ft_vbrkfo-dpplast 'E'
                             CHANGING ft_vbrkfo-ppnlast.
          PERFORM f_tax_calc USING fu_vbrk-fkdat '' ft_vbrkfo-dpp 'E'
                             CHANGING ft_vbrkfo-ppn2.
          PERFORM f_tax_calc USING fu_vbrk-fkdat '' ft_vbrkfo-dpplast 'E'
                             CHANGING ft_vbrkfo-ppn2last.

*          ft_vbrkfo-ppn = 10 / 100 * ft_vbrkfo-dpp.
*          ft_vbrkfo-ppnlast = 10 / 100 * ft_vbrkfo-dpplast.
*          ft_vbrkfo-ppn2 = 10 / 100 * ft_vbrkfo-dpp.
*          ft_vbrkfo-ppn2last = 10 / 100 * ft_vbrkfo-dpplast.
        ELSE.
          ft_vbrkfo-ppn = ( 1 / 100 ) * ft_vbrkfo-dpp.
          ft_vbrkfo-ppnlast = ( 1 / 100 ) * ft_vbrkfo-dpplast.
          ft_vbrkfo-ppn2 = ( 1 / 100 ) * ft_vbrkfo-dpp.
          ft_vbrkfo-ppn2last = ( 1 / 100 ) * ft_vbrkfo-dpplast.
        ENDIF.
*----------- Convert Amount,Disc PPNBM into local currency
*----------- This convertion base on Billing Rate / Normal Rate
        d_rate_std = ft_vbrkfo-kurrf * d_ratefactor.
        ft_vbrkfo-rate_std = d_rate_std / 100.
        ft_vbrkfo-bilrate = ft_vbrkfo-rate_std.
        ft_vbrkfo-itdisc = ft_vbrkfo-itdisc * d_rate_std / 100.
        ft_vbrkfo-itdisclast =
        ft_vbrkfo-itdisclast * d_rate_std / 100.
        ft_vbrkfo-itamt = ft_vbrkfo-itamt * d_rate_std / 100.
        ft_vbrkfo-itamtlast =
        ft_vbrkfo-itamtlast * d_rate_std / 100.
        ft_vbrkfo-ppnbm = ft_vbrkfo-ppnbm * d_rate_std / 100.
        ft_vbrkfo-ppnbmlast =
        ft_vbrkfo-ppnbmlast * d_rate_std / 100.
        ft_vbrkfo-xppnbm = ft_vbrkfo-xppnbm * d_rate_std / 100.
        ft_vbrkfo-xppnbmlast =
        ft_vbrkfo-xppnbmlast * d_rate_std / 100.
        ft_vbrkfo-mwsbp = ft_vbrkfo-mwsbp * d_rate_std / 100.
        ft_vbrkfo-examt = ft_vbrkfo-examt * d_rate_std / 100.
        ft_vbrkfo-inamt = ft_vbrkfo-inamt * d_rate_std / 100.
        ft_vbrkfo-itdiscex =
        ft_vbrkfo-itdiscex * d_rate_std / 100.
        ft_vbrkfo-itdiscin =
        ft_vbrkfo-itdiscin * d_rate_std / 100.
        ft_vbrkfo-examtlast =
        ft_vbrkfo-examtlast * d_rate_std / 100.
        ft_vbrkfo-inamtlast =
        ft_vbrkfo-inamtlast * d_rate_std / 100.
        ft_vbrkfo-itdiscinlast =
        ft_vbrkfo-itdiscinlast * d_rate_std / 100.
        ft_vbrkfo-itdiscexlast =
        ft_vbrkfo-itdiscexlast * d_rate_std / 100.
*------------ Tariff must be converted into local currency
        t_tariff-dpp = t_tariff-dpp * d_rate_tax / 100.
        t_tariff-ppnbm = t_tariff-ppnbm * d_rate_std / 100.
*------------ Eliminated rounding problem (Hard code)
        IF ft_vbrkfo-spart NE d_used.
          ft_vbrkfo-ppn2 = 10 / 100 * ft_vbrkfo-dpp.
          ft_vbrkfo-ppn2last = 10 / 100 * ft_vbrkfo-dpplast.
        ELSE.
          ft_vbrkfo-ppn2 = ( 1 / 100 ) * ft_vbrkfo-dpp.
          ft_vbrkfo-ppn2last = ( 1 / 100 ) * ft_vbrkfo-dpplast.
        ENDIF.

*++++
      ELSE. "Local currency
        ft_vbrkfo-rate_tax = 1.
        ft_vbrkfo-rate_std = 1.
        ft_vbrkfo-trcurr = ft_vbrkfo-waerk.
        ft_vbrkfo-fakcurr = ft_vbrkfo-waerk.
        ft_vbrkfo-fakrate = 1.
        ft_vbrkfo-bilrate = 1.

      ENDIF.
      MOVE-CORRESPONDING ft_vbrkfo TO t_vbrkf.
      PERFORM f_filling_up_addt_info USING fu_vbrk
                                     CHANGING t_vbrkf.
      APPEND t_vbrkf.
    ELSEIF ft_vbrkfo-fkart IN r_fkartp.
******PRICE ADJUSTMENT
      PERFORM f_price_adjustment    USING ft_vbrkfo
                                          fu_tax
                                 CHANGING ft_vbrkfo-itamt
                                          ft_vbrkfo-itdisc
                                          ft_vbrkfo-itoth
                                          ft_vbrkfo-ppn
                                          ft_vbrkfo-examt
                                          ft_vbrkfo-inamt
                                          ft_vbrkfo-itdiscex
                                          ft_vbrkfo-itdiscin
******added by Rahmadi
*--To store PPH 22 & PPH 23 info from the invoices
                                          ft_vbrkfo-pph22
                                          ft_vbrkfo-pph23.
******end of addition

      fc_itamt = ft_vbrkfo-itamt.
      fc_itdisc = ft_vbrkfo-itdisc.
      fc_itoth = ft_vbrkfo-itoth.
*----------------------------------------------------------------------*
*   Note: Following condition applies for price adjustment:            *
*         - if the price goes up -> the tax sign will be (-)           *
*         - if the price goes down -> the tax sign will be (+)         *
*           therefore the calculation process must be substraction     *
*         - Price adjustment to a billing can ONLY be done ONCE        *
*----------------------------------------------------------------------*
      fc_ppn      = fc_ppn - ft_vbrkfo-ppn.
      fc_examt    = ft_vbrkfo-examt.
      fc_inamt    = ft_vbrkfo-inamt.
      fc_itdiscex = ft_vbrkfo-itdiscex.
      fc_itdiscin = ft_vbrkfo-itdiscin.
      fc_dpp      = fc_examt - fc_itdiscex.

****added by Rahmadi
*--To store PPH 22 & PPH 23 info from the invoices
      fc_pph22 = fc_pph22 - ft_vbrkfo-pph22.
      fc_pph23 = fc_pph23 - ft_vbrkfo-pph23.
****end of addition

******Last amount = current amount
      ft_vbrkfo-itamtlast    = ft_vbrkfo-itamt.
      ft_vbrkfo-itdisclast   = ft_vbrkfo-itdisc.
      ft_vbrkfo-dpplast      = ft_vbrkfo-dpp.
      ft_vbrkfo-ppnlast      = ft_vbrkfo-ppn.
      ft_vbrkfo-ppnbmlast    = ft_vbrkfo-ppnbm.
      ft_vbrkfo-xppnbmlast   = ft_vbrkfo-xppnbm.
      ft_vbrkfo-itothlast    = ft_vbrkfo-itoth.
      ft_vbrkfo-itqtylast    = ft_vbrkfo-itqty.
      ft_vbrkfo-examtlast    = ft_vbrkfo-examt.
      ft_vbrkfo-inamtlast    = ft_vbrkfo-inamt.
      ft_vbrkfo-itdiscexlast = ft_vbrkfo-itdiscex.
      ft_vbrkfo-itdiscinlast = ft_vbrkfo-itdiscin.
      ft_vbrkfo-stnklast     = ft_vbrkfo-stnk.
      ft_vbrkfo-trcurr     = ft_vbrkfo-waerk.
      IF ft_vbrkfo-waerk NE c_local_curr.
        IF d_tcode = c_tcode_sederhana OR
           d_tcode = c_tcode_sederhana_single.
*----------- Get tax rate base on ratio defined
*----------- Get base on Billing Date
          PERFORM f_get_tax_rate USING ft_vbrkfo-waerk
                                       fu_vbrk-fkdat
                                       c_local_curr.
        ELSE.
*----------- Get tax rate base on ratio defined
*----------- Get base on Faktur Pajak Date / Faktur Printing date
*----- Koreksi by budi 19/09/2005
*          PERFORM f_get_tax_rate USING ft_vbrkfo-waerk
*                                       fu_vbrk-fakdat
*                                       c_local_curr.
          PERFORM f_get_tax_rate USING ft_vbrkfo-waerk
                                       fu_vbrk-fkdat
                                       c_local_curr.
*----- End of Koreksi by budi 19/09/2005
        ENDIF.
*++++
*----------- Recondition Tax information then save the original
*----------- transactions amount into foreign currency field (F)
        ft_vbrkfo-ppndate = d_tax_valid.
        ft_vbrkfo-itamt_f = ft_vbrkfo-examtlast. "Exclude Tax
        ft_vbrkfo-itdisc_f = ft_vbrkfo-itdiscexlast.
        ft_vbrkfo-itoth_f = ft_vbrkfo-itothlast.
        ft_vbrkfo-dpp_f = ft_vbrkfo-dpplast.
        ft_vbrkfo-ppn_f = ft_vbrkfo-ppnlast.
        ft_vbrkfo-ppnbm_f = ft_vbrkfo-ppnbmlast.
        ft_vbrkfo-xppnbm_f = ft_vbrkfo-xppnbmlast.
        IF d_tcode = c_tcode_satuan OR d_tcode = c_tcode_split.
          ft_vbrkfo-fakppn_f = ft_vbrkfo-ppnlast.
          ft_vbrkfo-fakppnbm_f = ft_vbrkfo-ppnbmlast.
          ft_vbrkfo-fakxppnbm_f = ft_vbrkfo-xppnbmlast.
        ENDIF.
*----------- Translate the billing transaction into local currency
        d_rate_tax = d_rate_tax * d_ratefactor.
        ft_vbrkfo-rate_tax = d_rate_tax / 100.
        ft_vbrkfo-trcurr = ft_vbrkfo-waerk.
        ft_vbrkfo-waerk = c_local_curr.
        ft_vbrkfo-fakcurr = ft_vbrkfo-trcurr.
        ft_vbrkfo-fakrate = ft_vbrkfo-rate_tax.
*----------- Convert DPP & PPN amount into local currency
*----------- This convertion base on Tax Rate
*----------- Rounding problem when calculating PPN - Hardcode 10%
        ft_vbrkfo-dpp = ft_vbrkfo-dpp * d_rate_tax / 100.
        ft_vbrkfo-dpplast =
                    ft_vbrkfo-dpplast * d_rate_tax / 100.
        IF ft_vbrkfo-spart NE d_used.
          ft_vbrkfo-ppn = 10 / 100 * ft_vbrkfo-dpp.
          ft_vbrkfo-ppnlast = 10 / 100 * ft_vbrkfo-dpplast.
          ft_vbrkfo-ppn2 = 10 / 100 * ft_vbrkfo-dpp.
          ft_vbrkfo-ppn2last = 10 / 100 * ft_vbrkfo-dpplast.
        ELSE.
          ft_vbrkfo-ppn = ( 1 / 100 ) * ft_vbrkfo-dpp.
          ft_vbrkfo-ppnlast = ( 1 / 100 ) * ft_vbrkfo-dpplast.
          ft_vbrkfo-ppn2 = ( 1 / 100 ) * ft_vbrkfo-dpp.
          ft_vbrkfo-ppn2last = ( 1 / 100 ) * ft_vbrkfo-dpplast.
        ENDIF.
*----------- Convert Amount,Disc PPNBM into local currency
*----------- This convertion base on Billing Rate / Normal Rate
        d_rate_std = ft_vbrkfo-kurrf * d_ratefactor.
        ft_vbrkfo-rate_std = d_rate_std / 100.
        ft_vbrkfo-bilrate = ft_vbrkfo-rate_std.
        ft_vbrkfo-itdisc = ft_vbrkfo-itdisc * d_rate_std / 100.
        ft_vbrkfo-itdisclast =
        ft_vbrkfo-itdisclast * d_rate_std / 100.
        ft_vbrkfo-itamt = ft_vbrkfo-itamt * d_rate_std / 100.
        ft_vbrkfo-itamtlast =
        ft_vbrkfo-itamtlast * d_rate_std / 100.
        ft_vbrkfo-ppnbm = ft_vbrkfo-ppnbm * d_rate_std / 100.
        ft_vbrkfo-ppnbmlast =
        ft_vbrkfo-ppnbmlast * d_rate_std / 100.
        ft_vbrkfo-xppnbm = ft_vbrkfo-xppnbm * d_rate_std / 100.
        ft_vbrkfo-xppnbmlast =
        ft_vbrkfo-xppnbmlast * d_rate_std / 100.
        ft_vbrkfo-mwsbp = ft_vbrkfo-mwsbp * d_rate_std / 100.
        ft_vbrkfo-examt = ft_vbrkfo-examt * d_rate_std / 100.
        ft_vbrkfo-inamt = ft_vbrkfo-inamt * d_rate_std / 100.
        ft_vbrkfo-itdiscex =
        ft_vbrkfo-itdiscex * d_rate_std / 100.
        ft_vbrkfo-itdiscin =
        ft_vbrkfo-itdiscin * d_rate_std / 100.
        ft_vbrkfo-examtlast =
        ft_vbrkfo-examtlast * d_rate_std / 100.
        ft_vbrkfo-inamtlast =
        ft_vbrkfo-inamtlast * d_rate_std / 100.
        ft_vbrkfo-itdiscinlast =
        ft_vbrkfo-itdiscinlast * d_rate_std / 100.
        ft_vbrkfo-itdiscexlast =
        ft_vbrkfo-itdiscexlast * d_rate_std / 100.
*------------ Tariff must be converted into local currency
        t_tariff-dpp = t_tariff-dpp * d_rate_tax / 100.
        t_tariff-ppnbm = t_tariff-ppnbm * d_rate_std / 100.
*------------ Eliminated rounding problem (Hard code)
        IF ft_vbrkfo-spart NE d_used.
          ft_vbrkfo-ppn2 = 10 / 100 * ft_vbrkfo-dpp.
          ft_vbrkfo-ppn2last = 10 / 100 * ft_vbrkfo-dpplast.
        ELSE.
          ft_vbrkfo-ppn2 = ( 1 / 100 ) * ft_vbrkfo-dpp.
          ft_vbrkfo-ppn2last = ( 1 / 100 ) * ft_vbrkfo-dpplast.
        ENDIF.

*++++
      ELSE. "Local currency
        ft_vbrkfo-rate_tax = 1.
        ft_vbrkfo-rate_std = 1.
        ft_vbrkfo-trcurr = ft_vbrkfo-waerk.
        ft_vbrkfo-fakcurr = ft_vbrkfo-waerk.
        ft_vbrkfo-fakrate = 1.
        ft_vbrkfo-bilrate = 1.

      ENDIF.
      MOVE-CORRESPONDING ft_vbrkfo TO t_vbrkf.
      PERFORM f_filling_up_addt_info USING fu_vbrk
                                     CHANGING t_vbrkf.
      APPEND t_vbrkf.
    ELSE.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_FOLLOWUP_DOCS

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_VALUE
*&---------------------------------------------------------------------*
*&  This routine determines the amount based on selected billing and
*&  the price type
*&---------------------------------------------------------------------*
*&  ->FU_VBRK  - Billing data
*&  ->FU_PTYPE - Price type
*&  <-FC_VALUE - Price amount
*&---------------------------------------------------------------------*
FORM f_determine_value USING    fu_vbrk LIKE t_vbrk
                                fu_ptype
                       CHANGING fc_value.

  DATA: ld_vbelv LIKE fu_vbrk-vbelv,
        ld_posnv LIKE fu_vbrk-posnr.


  IF fu_ptype = d_ptype_pl.
    ld_vbelv = fu_vbrk-vbelv.
    ld_posnv = fu_vbrk-posnv.
  ELSE.
    ld_vbelv = fu_vbrk-vbeln.
    ld_posnv = fu_vbrk-posnr.
  ENDIF.

  READ TABLE t_priceall WITH KEY vbeln = ld_vbelv
                                 posnr = ld_posnv
                                 ptype = fu_ptype
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_value = t_priceall-kwert.
  ELSE.
    fc_value = 0.
  ENDIF.

ENDFORM.                    " F_DETERMINE_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_AMOUNTS
*&---------------------------------------------------------------------*
*&  This routine determines all the tax-related price amount based of
*&  the selected billing
*&---------------------------------------------------------------------*
*&  ->FU_VBRK     - Billing data
*&  ->FU_TAX      - VAT amount
*&  <-FC_ITAMT    - Selling price amount
*&  <-FC_ITDISC   - Discount amount
*&  <-FC_DPP      - DPP amount
*&  <-FC_PPN      - PPN amount
*&  <-FC_PPNBM    - PPNBM amount
*&  <-FC_XPPNBM   - XPPNBM amount
*&  <-FC_ITOTH    - Others amount
*&  <-FC_ITQTY    - Quantity
*&  <-FC_EXAMT    - Selling price (tax-exclusive)
*&  <-FC_INAMT    - Selling price (tax-inclusive)
*&  <-FC_ITDISCEX - Discount (tax-exclusive) amount
*&  <-FC_ITDISCIN - Discount (tax-inclusive) amount
*&  <-FC_STNK     - STNK price
*&---------------------------------------------------------------------*
FORM f_amounts USING    fu_vbrk LIKE t_vbrk
                        fu_tax
               CHANGING fc_itamt
                        fc_itdisc
                        fc_dpp
                        fc_ppn
                        fc_ppnbm
                        fc_xppnbm
                        fc_itoth
                        fc_itqty
                        fc_examt
                        fc_inamt
                        fc_itdiscex
                        fc_itdiscin
                        fc_stnk
                        fc_pph22
                        fc_pph23.

  DATA ld_itdisc1 LIKE konv-kwert.
  DATA ld_itdisc2 LIKE konv-kwert.
  DATA ld_itdisc1ex LIKE konv-kwert.
  DATA ld_itdisc2ex LIKE konv-kwert.
  DATA ld_itdisc1in LIKE konv-kwert.
  DATA ld_itdisc2in LIKE konv-kwert.

  DATA : lv_dpp     LIKE zgdtxst0007-dpp,
         lv_selisih LIKE zgdtxst0007-dpp.

**Determine PPNBM
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_ppnbm
                            CHANGING fc_ppnbm.

**Determine PRICE (INCLUDE or EXCLUDE tax)

***added for MKM 09/02/2004 (relevant only for RPC)
  IF sy-tcode = c_tcode_rpc AND
     fu_vbrk-fkart IN r_fkartp.
    PERFORM f_determine_price  USING    fu_vbrk-vbeln
                                        fu_vbrk-posnr
                                        d_ptype_npex
                                        d_ptype_npin
                                        d_ptype_pl
                                        fc_ppnbm
                                        fu_tax
                               CHANGING fc_itamt
                                        fc_examt
                                        fc_inamt.
  ELSE.
***end of addition
    PERFORM f_determine_price  USING    fu_vbrk-vbeln
                                        fu_vbrk-posnr
                                        d_ptype_pex
                                        d_ptype_pin
                                        d_ptype_pl
                                        fc_ppnbm
                                        fu_tax
                               CHANGING fc_itamt
                                        fc_examt
                                        fc_inamt.
  ENDIF.

**Determine DISCOUNT SUM (INCLUDE or EXCLUDE tax)
  PERFORM f_determine_amount USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_dex
                                      d_ptype_din
                                      fu_tax
                             CHANGING ld_itdisc1
                                      ld_itdisc1ex
                                      ld_itdisc1in.

**Determine DISCOUNT MAX (INCLUDE or EXCLUDE tax)
  PERFORM f_determine_amount USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_mex
                                      d_ptype_min
                                      fu_tax
                             CHANGING ld_itdisc2
                                      ld_itdisc2ex
                                      ld_itdisc2in.

**Determine DISCOUNT METHOD (MAX or SUM)
  PERFORM f_select_value  USING    ld_itdisc1
                                   ld_itdisc2
                          CHANGING fc_itdisc.

  PERFORM f_select_value  USING    ld_itdisc1ex
                                   ld_itdisc2ex
                          CHANGING fc_itdiscex.

  PERFORM f_select_value  USING    ld_itdisc1in
                                   ld_itdisc2in
                          CHANGING fc_itdiscin.

**Determine DPP
  PERFORM f_determine_dpp USING fu_vbrk-examt
                                fu_vbrk-itdiscex
                          CHANGING fc_dpp.

  CASE fu_vbrk-vkorg.
*    WHEN '8800'.
*      IF fu_vbrk-busln = '01'.
*        fc_dpp = fc_dpp / 10.
*      ENDIF.
    WHEN '8380'.
      CLEAR lv_dpp.
      lv_dpp      = fu_vbrk-itamt - fu_vbrk-itdisc - fu_vbrk-mwsbp.
      lv_selisih  = lv_dpp - fc_dpp.
      fc_dpp      = fc_dpp + lv_selisih.
    WHEN '8210'.
      CLEAR lv_dpp.
      lv_dpp      = fu_vbrk-itamt - fu_vbrk-itdisc.
      lv_selisih  = lv_dpp - fc_dpp.
      fc_dpp      = fc_dpp + lv_selisih.
  ENDCASE.

**Determine tax
*  fc_ppn = fu_vbrk-mwsbp.
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_vatout
                            CHANGING fc_ppn.

**Determine XPPNBM
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_xppnbm
                            CHANGING fc_xppnbm.

**Determine OTHER
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_other
                            CHANGING fc_itoth.

**Determine STNK
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_stnk
                            CHANGING fc_stnk.

**Determine quantity
  fc_itqty = fu_vbrk-fkimg.

****Added by Rahmadi
*-Determine PPh 22 amount
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_pph22
                            CHANGING fc_pph22.

*-Determine PPh 23 amount
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_pph23
                            CHANGING fc_pph23.
****End of addition

ENDFORM.                    " F_AMOUNTS

*&---------------------------------------------------------------------*
*&      form  f_price_adjustment
*&---------------------------------------------------------------------*
*&  This routine proceeds follow-up documents of a normal billing if the
*&  follow-up document type is Price adjustment
*&---------------------------------------------------------------------*
*&  ->FU_VBRK     - Normal billing data
*&  ->FU_TAX      - VAT amount
*&  <-FC_ITAMT    - Selling price amount after price adjustment
*&  <-FC_ITDISC   - Discount amount after price adjustment
*&  <-FC_PPN      - PPN amount after price adjustment
*&  <-FC_ITOTH    - Others amount after price adjustment
*&  <-FC_EXAMT    - Selling price (tax-exclusive) amount after
*&                  price adjustment
*&  <-FC_INAMT    - Selling price (tax-inclusive) amount after
*&                  price adjustment
*&  <-FC_ITDISCEX - Discount (tax-exclusive) amount after price
*&                  adjustment
*&  <-FC_ITDISCIN - Discount (tax-inclusive) amount after price
*&                  adjustment
*&---------------------------------------------------------------------*
FORM f_price_adjustment USING     fu_vbrk LIKE t_vbrk
                                  fu_tax
                     CHANGING     fc_itamt
                                  fc_itdisc
                                  fc_itoth
                                  fc_ppn
                                  fc_examt
                                  fc_inamt
                                  fc_itdiscex
                                  fc_itdiscin
****added by Rahmadi
*--To store PPH 22 & PPH 23 info from the invoices
                                  fc_pph22
                                  fc_pph23.
****end of addition

  DATA: ld_itamt1 LIKE konv-kwert,
        ld_itamt2 LIKE konv-kwert,
        ld_itamt3 LIKE konv-kwert,
        ld_tax1   LIKE konv-kbetr,
        ld_examt1 LIKE konv-kwert,
        ld_inamt1 LIKE konv-kwert,
        ld_examt2 LIKE konv-kwert,
        ld_inamt2 LIKE konv-kwert.

**Determine NEW PRICE (INCLUDE or EXCLUDE tax)
  PERFORM f_determine_amount USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_npex
                                      d_ptype_npin
                                      fu_tax
                             CHANGING ld_itamt1
                                      ld_examt1
                                      ld_inamt1.

***MKM 19/01/2004 -- determine Debit/Credit note - negative if CN
  IF fu_vbrk-vbtyp = 'O'.   "Credit note
    ld_itamt1 = ld_itamt1 * ( -1 ).
    ld_examt1 = ld_examt1 * ( -1 ).
    ld_inamt1 = ld_inamt1 * ( -1 ).
  ENDIF.
***end of addition 19/01/2004

**EXCEPTION for KTB
**Determine NEW PRICE (for KTB)
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_nz
                         CHANGING ld_itamt2.

  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_pl
                         CHANGING ld_itamt3.

**Determine FIRST TAX
  PERFORM f_determine_pctg USING fu_vbrk
                                 d_ptype_taxin
                        CHANGING ld_tax1.

  ld_tax1 = ld_tax1 / d_taxfactor.

***added for MKM 19/01/2004
  PERFORM f_determine_old_price USING fu_vbrk
                                      fu_tax
                                CHANGING ld_examt2
                                         ld_inamt2
                                         ld_itamt2.
***end of addition

**Total NEW PRICE
****changed for MKM 19/01/2004
*  fc_itamt = ld_itamt1 + ld_itamt2 + ( ld_itamt2 * ld_tax1 )
*                       + ld_itamt3 + ( ld_itamt3 * ld_tax1 ).
*  fc_examt = ld_examt1 + ld_itamt2 + ( ld_itamt2 * ld_tax1 )
*                       + ld_itamt3 + ( ld_itamt3 * ld_tax1 ).
*  fc_inamt = ld_inamt1 + ld_itamt2 + ( ld_itamt2 * ld_tax1 )
*                       + ld_itamt3 + ( ld_itamt3 * ld_tax1 ).
  fc_itamt = ld_itamt1 + ld_itamt2 .
  fc_examt = ld_examt1 + ld_examt2.
  fc_inamt = ld_inamt1 + ld_inamt2.
****end of change

**Determine NEW DISCOUNT (INCLUDE or EXCLUDE TAX)
  PERFORM f_determine_amount USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_ndex
                                      d_ptype_ndin
                                      fu_tax
                             CHANGING fc_itdisc
                                      fc_itdiscex
                                      fc_itdiscin.

**Determine NEW OTHER
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_nother
                            CHANGING fc_itoth.

**Determine tax
***changed for Tempo
  IF fu_vbrk-vbtyp = 'O'.   "Credit note
    fc_ppn = fu_vbrk-mwsbp.
***Put negative tax value for Debit note (tempo)
  ELSE.                  "Debit note
    fc_ppn = ( -1 ) * fu_vbrk-mwsbp.
  ENDIF.
***end of Tempo changes

****added by Rahmadi
**Determine PPh 22
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_pph22
                            CHANGING fc_pph22.

**Determine PPh 23
  PERFORM f_determine_value USING fu_vbrk
                                  d_ptype_pph23
                            CHANGING fc_pph23.
****end of addition

ENDFORM.                    " F_PRICE_ADJUSTMENT

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_PCTG
*&---------------------------------------------------------------------*
*&  This routine determines the percentage value of a price type based
*&  on selected billing and the price type
*&---------------------------------------------------------------------*
*&  ->FU_VBRK  - Billing data
*&  ->FU_PTYPE - Price type
*&  <-FC_VALUE - Price amount
*&---------------------------------------------------------------------*
FORM f_determine_pctg USING     fu_vbrk LIKE t_vbrk
                                fu_ptype
                       CHANGING fc_value.

  READ TABLE t_priceall WITH KEY vbeln = fu_vbrk-vbeln
                                 posnr = fu_vbrk-posnr
                                 ptype = fu_ptype
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_value = t_priceall-kbetr.
  ELSE.
    fc_value = 0.
  ENDIF.

ENDFORM.                    " F_DETERMINE_PCTG

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_TAX_AMOUNT
*&---------------------------------------------------------------------*
*&  This routine checks whether the tax defined for the billing has
*&  some amount. Otherwise, it will be considered as an error and it
*&  will not be processed
*&---------------------------------------------------------------------*
*&  ->FU_VBRK  - Billing data
*&  <-FC_SUBRC - Return code (Error -> FU_SUBRC <> 0)
*&---------------------------------------------------------------------*
FORM f_check_tax_amount USING    fu_vbrk LIKE t_vbrk
                        CHANGING fc_subrc.

  IF fu_vbrk-mwsbp IS INITIAL.
    fc_subrc = 1.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    t_error-msg = 'Billing has no tax to be processed'.
    APPEND t_error.
  ELSE.
    fc_subrc = 0.
  ENDIF.

ENDFORM.                    " F_CHECK_TAX_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_DATA
*&---------------------------------------------------------------------*
*&  This routine retrieves all necessary material master data, and it
*&  it will be stored in global internal table T_MARA
*&---------------------------------------------------------------------*
*&  ->FT_VBRK  - Billing data
*&---------------------------------------------------------------------*
FORM f_get_material_data TABLES   ft_vbrk STRUCTURE t_vbrk.

  DATA ld_from LIKE sy-tabix.
  DATA ld_to LIKE sy-tabix.

  DATA lt_vbrk LIKE t_vbrk OCCURS 0 WITH HEADER LINE.

  RANGES lr_matnr FOR mara-matnr.

  lt_vbrk[] = ft_vbrk[].
  SORT lt_vbrk BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_vbrk COMPARING matnr.

  IF NOT lt_vbrk[] IS INITIAL.
    REFRESH t_mara.
    ld_from = 1.
    ld_to = c_max_ritems.
    lr_matnr-sign = 'I'.
    lr_matnr-option = 'EQ'.
    DO.
      REFRESH lr_matnr.
      LOOP AT lt_vbrk FROM ld_from TO ld_to.
        lr_matnr-low = lt_vbrk-matnr.
        APPEND lr_matnr.
      ENDLOOP.
      IF lr_matnr[] IS INITIAL.
        EXIT.
      ENDIF.
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.

      SELECT matnr matkl mtart spart
             APPENDING CORRESPONDING FIELDS OF TABLE t_mara
             FROM  mara
             WHERE matnr IN lr_matnr.
    ENDDO.

    IF NOT t_mara[] IS INITIAL.
      SORT t_mara BY matnr.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_MATERIAL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_EQUIPMENT_DATA
*&---------------------------------------------------------------------*
*&  This routine retrieves all necessary equipment master data, and it
*&  it will be stored in global internal table T_EQUI
*&---------------------------------------------------------------------*
*&  ->FT_VBRK  - Billing data
*&---------------------------------------------------------------------*
FORM f_get_equipment_data TABLES   ft_vbrk STRUCTURE t_vbrk.

  DATA lt_vbrk LIKE t_vbrk OCCURS 0 WITH HEADER LINE.
  DATA ld_from LIKE sy-tabix.
  DATA ld_to   LIKE sy-tabix.

  IF NOT ft_vbrk[] IS INITIAL.
    ld_from = 1.
    ld_to   = c_max_ritems.
    REFRESH: t_equi.
    DO.
      REFRESH: lt_vbrk.
      LOOP AT ft_vbrk FROM ld_from TO ld_to.
        lt_vbrk-ean11 = ft_vbrk-ean11.
        lt_vbrk-fkdat = ft_vbrk-fkdat.
        APPEND lt_vbrk.
      ENDLOOP.
      IF lt_vbrk[] IS INITIAL. EXIT. ENDIF.
      SELECT equi~equnr equi~baujj equz~mapar
             APPENDING CORRESPONDING FIELDS OF TABLE t_equi
             FROM equi INNER JOIN equz
             ON equi~equnr = equz~equnr
             FOR ALL ENTRIES IN lt_vbrk
             WHERE equz~equnr  = lt_vbrk-ean11 AND
                 ( equz~datbi >= lt_vbrk-fkdat AND
                   equz~datab <= lt_vbrk-fkdat ).
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.
    ENDDO.

    IF NOT t_equi[] IS INITIAL.
      SORT t_equi BY equnr.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_EQUIPMENT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_KWITANSI_DATA
*&---------------------------------------------------------------------*
*&  This routine retrieves all necessary kwitansi data, and it
*&  it will be stored in global internal table T_KWITANSI
*&---------------------------------------------------------------------*
*&  ->FT_VBRK  - Billing data
*&  ->FU_VKORG - Sales organization
*&---------------------------------------------------------------------*
FORM f_get_kwitansi_data TABLES   ft_vbrk STRUCTURE t_vbrk
                         USING    fu_vkorg.

  DATA lt_vbrk LIKE t_vbrk OCCURS 0 WITH HEADER LINE.
  DATA ld_from LIKE sy-tabix.
  DATA ld_to   LIKE sy-tabix.

  RANGES lr_vbeln FOR vbrk-vbeln.

  lt_vbrk[] = ft_vbrk[].
  SORT lt_vbrk BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vbrk COMPARING vbeln.

  IF NOT lt_vbrk[] IS INITIAL.
    REFRESH t_kwitansi.
    ld_from = 1.
    ld_to = c_max_ritems.
    lr_vbeln-sign = 'I'.
    lr_vbeln-option = 'EQ'.
    DO.
      REFRESH lr_vbeln.
      LOOP AT lt_vbrk FROM ld_from TO ld_to.
        lr_vbeln-low = lt_vbrk-vbeln.
        APPEND lr_vbeln.
      ENDLOOP.
      IF lr_vbeln[] IS INITIAL.
        EXIT.
      ENDIF.
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.

*      SELECT a~zcsh1 a~erdt2 b~ibeln
*             APPENDING CORRESPONDING FIELDS OF TABLE t_kwitansi
*             FROM zfafdt_cashhead
*             AS a INNER JOIN zfafdt_cashcler AS b
*             ON a~idkey = b~idkey AND
*                a~bukrs = b~bukrs AND
*                a~gjahr = b~gjahr
*             WHERE b~bukrs = fu_vkorg AND
*                   b~ibeln IN lr_vbeln AND
*                   b~xcanc = ''.

    ENDDO.

    IF NOT  t_kwitansi[] IS INITIAL.
      SORT t_kwitansi BY ibeln zcsh1.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_KWITANSI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_BILLING
*&---------------------------------------------------------------------*
*&  This routine locks all the billings needs to be processed by the
*&  program to make the billing unchangeable during processes performed
*&  by this program
*&---------------------------------------------------------------------*
*&  ->FU_VBRK  - Billing data
*&  <-FC_SUBRC - Return code (Locking failed: FC_SUBRC <> 0)
*&  <-FC_USER  - User name locking the billing if the locking process
*&               fails
*&---------------------------------------------------------------------*
FORM f_lock_billing USING    fu_vbrk LIKE t_vbrk
                    CHANGING fc_subrc
                             fc_user.

  CALL FUNCTION 'ENQUEUE_EVVBRKE'
    EXPORTING
      mode_vbrk      = 'E'
      mandt          = sy-mandt
      vbeln          = fu_vbrk-vbeln
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  fc_subrc = sy-subrc.
  IF fc_subrc = 1.
    fc_user = sy-msgv1.
  ELSE.
    CLEAR fc_user.
  ENDIF.

ENDFORM.                    " F_LOCK_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_FAKTUR_DATE
*&---------------------------------------------------------------------*
*&  This routine checks tax processing date entered in the selection
*&  screen so it will not be earlier than the processed billing date.
*&  It should not also be in the different month as the billing date,
*&  and it should not be within a closed tax period.
*&  If this routine is executed by RPC program, closing period will not
*&  be considered.
*&  If this routine is performed for a PERIOD END (AKHIR MASA) process,
*&  global variable D_PERIOD_END must have been set to 'X', then the
*&  faktur pajak date must be a month after processed billing date.
*&---------------------------------------------------------------------*
*&  ->FT_FKDAT  - Billing date
*&  ->FU_FAKDAT - Tax processing date
*&  ->FU_VKORG  - Sales organization
*&  ->FU_GSBER  - Business Area
*&---------------------------------------------------------------------*
FORM f_faktur_date TABLES ft_fkdat STRUCTURE r_fkdat
                   USING  fu_fakdat
                          fu_vkorg
                          fu_gsber
                          fu_brnch
                          fu_rpc.

  DATA: ld_start   LIKE sy-datum,
        ld_masatx0 LIKE zgdtxdt0004-masatx.

*---------------------------------------------------------------------*
* If this routine is executed by RPC program, closing period will not
* be considered.
*---------------------------------------------------------------------*
* If this routine is executed for PERIOD END (AKHIR MASA) process,
* faktur pajak date must be a month after processed billing date
*---------------------------------------------------------------------*

**Faktur pajak date must be >= latest billing date
  ld_start = ft_fkdat-low.
  ld_start+6(2) = '01'.

  IF ft_fkdat-high IS INITIAL.
    IF fu_fakdat < ld_start OR
       fu_fakdat < ft_fkdat-low.
      MESSAGE e505(ztx) WITH ft_fkdat-low.
    ELSE.
      IF fu_rpc IS INITIAL.
        IF fu_fakdat+0(6) <> ft_fkdat-low+0(6).
          IF NOT d_period_end IS INITIAL.   "PERIOD END
            PERFORM f_get_last_month USING fu_fakdat+0(6)
                                     CHANGING ld_masatx0.
            IF ld_masatx0 <> ft_fkdat-low+0(6).
              MESSAGE e512(ztx).   "not last month
            ENDIF.
          ELSE.
            MESSAGE e511(ztx).     "different month
          ENDIF.
        ELSE.
          IF NOT d_period_end IS INITIAL.      "PERIOD END
            MESSAGE e512(ztx).
          ELSE.
            PERFORM f_check_closing_period USING ft_fkdat-low+0(6)
                                                 fu_vkorg
                                                 fu_gsber
                                                 fu_brnch
                                                 ' '.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF fu_fakdat < ld_start OR
       fu_fakdat < ft_fkdat-high OR
       fu_fakdat < ft_fkdat-low.
      MESSAGE e505(ztx) WITH ft_fkdat-high.
    ELSE.
      IF fu_rpc IS INITIAL.
        IF fu_fakdat+0(6) <> ft_fkdat-high+0(6).
          IF NOT d_period_end IS INITIAL.   "PERIOD END
            PERFORM f_get_last_month USING fu_fakdat+0(6)
                                     CHANGING ld_masatx0.
            IF ld_masatx0 <> ft_fkdat-high+0(6).
              MESSAGE e512(ztx).   "not last month
            ENDIF.
          ELSE.
            MESSAGE e511(ztx).     "different month
          ENDIF.
        ELSE.
          IF NOT d_period_end IS INITIAL.      "PERIOD END
            MESSAGE e512(ztx).
          ELSE.
            PERFORM f_check_closing_period USING ft_fkdat-high+0(6)
                                                 fu_vkorg
                                                 fu_gsber
                                                 fu_brnch
                                                 ' '.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_FAKTUR_DATE

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_BILLING_INFO
*&---------------------------------------------------------------------*
*&  This routine performs data retreival of the selected billings,
*&  Follow-up billings retrieval (including their info) and phase one
*&  filtering (filtering out processed billing and filtering out billing
*&  with unrelated NPWP) -- T_VBRK0 => T_VBRK1
*&---------------------------------------------------------------------*
*&  ->FT_FKDAT  - Billing date
*&  ->FT_STCEG  - VAT registration no.
*&  ->FU_VKORG  - Sales organization/Company code
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&  ->FU_RPC    - 'X' if executed by RPC program, otherwise it's blank
*&---------------------------------------------------------------------*
FORM f_collect_billing_info TABLES ft_fkdat STRUCTURE r_fkdat
                                   ft_stceg STRUCTURE r_stceg
                             USING fu_vkorg fu_gsber fu_spart
                                   fu_brnch fu_busln fu_bukrs
                                   fu_rpc   fu_top.

  DATA: ld_tabix   LIKE sy-tabix, ld_subrc0 LIKE sy-subrc,
        ld_subrc1  LIKE sy-subrc, ld_subrc2 LIKE sy-subrc,
        ld_subrc3  LIKE sy-subrc, ld_subrc4 LIKE sy-subrc,
        ld_flagerr             , ld_kara,
        ld_kark                , ld_gjahr  LIKE bkpf-gjahr,
        lt_vbfaa   LIKE t_vbfaa OCCURS 1 WITH HEADER LINE,
        lw_vbrk    LIKE t_vbrk,
        lt_vbrkfx  LIKE t_vbrk OCCURS 1 WITH HEADER LINE,
        ld_subrcn  LIKE sy-subrc.

  CLEAR:   t_vbfac, t_vbfaa, ld_flagerr.
  REFRESH: t_vbfac, t_vbfaa.

*----  Get processed billing
*---------------------------------------------------------------------*
* If this routine is performed by RPC program, no need to filter out
* processed billings -> T_PROCESS will be empty
*---------------------------------------------------------------------*
  IF fu_rpc IS INITIAL.
    PERFORM f_get_processed_billing TABLES t_vbrk0
                                     USING fu_vkorg
                                           fu_gsber
                                           fu_spart
                                           fu_brnch
                                           fu_busln
                                           fu_bukrs.
  ELSE.
    CLEAR t_process. REFRESH t_process.
  ENDIF.


*---- Get Material data
  PERFORM f_get_material_data TABLES t_vbrk0.

*---- Get Customer address
  PERFORM f_get_address_data TABLES t_vbrk0 t_vbpa t_kna1 t_adrc.

*---- USER EXIT for adding additional data
  PERFORM f_get_additional_data TABLES t_vbrk0.

***added for Tempo
*---Get payment term info
  PERFORM f_get_payment_term TABLES t_vbrk0.
***end of Tempo addition

  DATA: ld_sbc  LIKE sy-subrc, ld_gsbc LIKE sy-subrc.

  SELECT SINGLE datab
    FROM zproject
    INTO va_datab
    WHERE name EQ 'ZGDTAX'.

  LOOP AT t_vbrk0.
    ld_tabix = sy-tabix.
    MOVE-CORRESPONDING t_vbrk0 TO lw_vbrk.

    IF ld_flagerr IS INITIAL.
      CLEAR ld_gsbc.

******added for Tempo
      IF fu_rpc IS INITIAL.          "Only performed for FP creation
        PERFORM f_get_payment_days USING    lw_vbrk-zterm
                                   CHANGING lw_vbrk-ztag1.

***FP date & Tax period determination are customizable through user exit
        CALL FUNCTION 'Z_GDTXFC_EXIT_TAX_PERIOD'
          EXPORTING
            fi_vbrk                 = lw_vbrk
*           FI_BSEG                 =
            fi_busln                = lw_vbrk-busln
          IMPORTING
            fe_fakdat               = lw_vbrk-fakdat
            fe_masatx               = lw_vbrk-masatx
            fe_gjahr                = lw_vbrk-gjahr
          EXCEPTIONS
            fi_bseg_cannot_be_blank = 1
            fi_vbrk_cannot_be_blank = 2
            busline_not_defined     = 3
            OTHERS                  = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        lw_vbrk-yeartx = lw_vbrk-masatx(4).
        PERFORM f_check_tax_closing_period USING    lw_vbrk
                                           CHANGING ld_subrcn.
        BREAK bcdik.
      ELSE.
        ld_subrcn = 0.
      ENDIF.
***-------FP date & Tax period are based on payment term
*          READ TABLE t_tx00101 WITH KEY brnch = lw_vbrk-brnch.
*          CASE t_tx00101-txperdet.
*            WHEN '1'.  "Billing date based
*              lw_vbrk-fakdat = lw_vbrk-fkdat.
*              lw_vbrk-masatx = lw_vbrk-fakdat+0(6).
*              lw_vbrk-gjahr = lw_vbrk-fkdat(4).
*            WHEN '2'.  "Payment term based
*              lw_vbrk-fakdat = lw_vbrk-fkdat + lw_vbrk-ztag1.
*              lw_vbrk-masatx = lw_vbrk-fakdat+0(6).
*              lw_vbrk-gjahr  = lw_vbrk-fakdat+0(4).
*            WHEN OTHERS.
*              lw_vbrk-fakdat = fu_fakdat.
*              lw_vbrk-masatx = fu_fakdat+0(6).
*              lw_vbrk-gjahr  = fu_fakdat+0(4).
*          ENDCASE.
      IF ld_subrcn = 0.
***end of Tempo addition

        IF d_tcode = c_tcode_gabungan.
          PERFORM f_cek_freegoods USING lw_vbrk
                               CHANGING ld_gsbc.
        ENDIF.
        IF ld_gsbc NE 1.
          IF d_tcode = c_tcode_sederhana OR
             d_tcode = c_tcode_sederhana_single.  "CR009 16/04/2002
********Check NPWP length must be < 10 chars (SEDERHANA)
            PERFORM f_check_npwp_sederhana USING lw_vbrk
                                        CHANGING ld_subrc2.
          ELSE.
********Check NPWP length must be > 10 chars (CASH BASIS)
            PERFORM f_check_npwp USING lw_vbrk
                              CHANGING ld_subrc2
                                       lw_vbrk-stceg.
          ENDIF.
          IF ld_subrc2 = 0.
********Check whether Faktur has been processed for the billing
            PERFORM f_check_tax_done USING lw_vbrk  fu_vkorg
                                           fu_gsber fu_spart
                                  CHANGING ld_subrc4.
            IF ld_subrc4 = 0.

*****Removed by Rahmadi
*----Not generic and not relevant
**********Get KAROSERI
*            PERFORM f_get_karoseri_itemdiv USING lw_vbrk-matnr
*                                        CHANGING lw_vbrk-karoseri
*                                                 lw_vbrk-itemdiv.
**        (Karoseri logic is only applicable for FINISHED UNIT
**         otherwise will be BLANK)
*            IF lw_vbrk-spart = d_sparts OR lw_vbrk-spart = d_service.
*              CLEAR lw_vbrk-karoseri.
*            ELSEIF lw_vbrk-spart = d_used OR lw_vbrk-spart = d_truck.
*              lw_vbrk-karoseri = d_karu.
*            ENDIF.
*****End of removal

**-----------------------------------------------------------------*
**   This checking (setting LD_KARK and LD_KARA to 'X') will only be
**   applicable for condition where KAROSERI & ACCESORIES must not
**   be in the same billing
**-----------------------------------------------------------------*

*--------- Get CANCEL billing & ACCOUNTING documents
              PERFORM f_get_canc_bill_acc_docs TABLES t_vbfac t_vbfaa
                                               USING  lw_vbrk fu_top
                                             CHANGING ld_sbc
                                                      lw_vbrk-top.
              IF ld_sbc NE 1.
                MOVE-CORRESPONDING lw_vbrk TO t_vbrk1.
                APPEND t_vbrk1.
              ENDIF.
            ELSE.
              ld_flagerr = 'X'.
            ENDIF.
          ELSE.
            ld_flagerr = 'X'.
          ENDIF.
        ENDIF.
      ELSE.
        ld_flagerr = 'X'.
      ENDIF.
    ENDIF.

    AT END OF vbeln.
*----- Exclude the billing if any of its item is error
      IF NOT ld_flagerr IS INITIAL.
        READ TABLE t_vbrk1 WITH KEY vbeln = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrk1 WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
      ENDIF.
      CLEAR: ld_flagerr, ld_kara, ld_kark.
    ENDAT.
  ENDLOOP.

**Check accounting docs
  IF NOT t_vbfaa[] IS INITIAL.
*---Get Accounting documents posting date
    READ TABLE t_vbrk0 INDEX 1.
    ld_gjahr   = t_vbrk0-fkdat+0(4).
    lt_vbfaa[] = t_vbfaa[].
    SORT lt_vbfaa BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_vbfaa COMPARING vbeln.
    PERFORM f_get_acc_docs TABLES t_bkpf   lt_vbfaa
                           USING  fu_bukrs ld_gjahr.
    SORT t_vbfaa BY vbelv posnv.
  ENDIF.

*--Don't process return price adjusment (RPC TESTING PURPOSE)
  DATA:  ld_skip_followup.
  CLEAR: ld_skip_followup.

  IF ld_skip_followup = 'X'.
    EXIT.
  ENDIF.
*--end of RPC testing purpose

  IF NOT t_vbrk1[] IS INITIAL.
****Get PRICE ADJUSMENT & RETURN billings and their cancel billings
    CLEAR:   t_vbrkfo, t_vbrkfx.
    REFRESH: t_vbrkfo, t_vbrkfx.
    PERFORM f_get_return_price_adj TABLES t_vbrkfo t_vbrkfx t_vbrk1
                                          r_fodat  ft_stceg
                                   USING  fu_vkorg fu_gsber fu_spart
                                          fu_rpc fu_brnch fu_busln.

****Get billing data for CANCEL billing
    IF NOT t_vbfac[] IS INITIAL.
      CLEAR: t_vbrkfc. REFRESH: t_vbrkfc.
      PERFORM f_get_followup_bill_data TABLES t_vbfac  t_vbrkfc
                                              r_fodat  ft_stceg.
*--- Start of comment by rama
* The billing selected earlier already eliminate the organisation and
*  hence it is not required to use this as selection
*                                       USING  fu_vkorg fu_spart
*                                              fu_gsber.
*--- End of comment
      IF NOT t_vbrkfc[] IS INITIAL.
        SORT t_vbrkfc BY vbelv posnv vbeln posnr fkdat.
      ENDIF.
    ENDIF.

****Get Prices for follow-up billings
****RETURN & PRICE ADJUSTMENT
    IF NOT t_vbrkfo[] IS INITIAL.
      PERFORM f_get_price TABLES t_vbrkfo t_priceall.
*                          USING  fu_vkorg fu_spart.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_COLLECT_BILLING_INFO

*&--------------------------------------------------------------------*
*&      FORM f_get_header_data                                        *
*&--------------------------------------------------------------------*
*&  This routine retrieves all header data such as PKP and header text
*&  If the billing belongs to SERVICE division, PKP will depend on the
*&  item category
*&---------------------------------------------------------------------*
*&  ->FT_PSTYV  - Item Category
*&  ->FU_VKORG  - Sales organization
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&  ->FU_FAKDAT - Tax processing date
*&---------------------------------------------------------------------*
FORM f_get_header_data TABLES ft_pstyv STRUCTURE r_pstyv
                       USING  fu_vkorg
                              fu_gsber
                              fu_spart
                              fu_brnch
                              fu_busln
                              fu_bukrs
                              fu_fakdat.

  DATA ld_spart LIKE vbrp-spart.
  DATA ld_pstyv TYPE i.

**Get PKP
  IF NOT ( d_tcode = c_tcode_sederhana OR
           d_tcode = c_tcode_sederhana_single ).  "CR009 16/04/2002
    IF fu_spart = d_service.
******For SERVICE --> Use Item category
      DESCRIBE TABLE ft_pstyv LINES ld_pstyv.
      IF ld_pstyv = 1.
        READ TABLE ft_pstyv INDEX 1.
        IF ft_pstyv-low = c_pstyv_service.
          ld_spart = d_service.
        ELSEIF ft_pstyv-low = c_pstyv_parts.
          ld_spart = d_sparts.
        ENDIF.
      ELSE.
********If more than one item category --> Use common
        ld_spart = d_others.
      ENDIF.
******Get PKP based on Item category/division
      PERFORM f_get_pkp USING    fu_vkorg
                                 fu_gsber
                                 ld_spart
                                 fu_brnch
                                 fu_busln
                                 fu_bukrs
                                 fu_fakdat
                                 space
                                 space
                                 space
                        CHANGING d_petugas
                                 d_petugas2
                                 d_aktif
                                 d_jabat
                                 d_jabat2
                                 d_fpone
                                 d_fptwo
                                 d_objrange
                                 d_pkpnpwp
                                 d_pkpname
                                 d_pkpaddrs1
                                 d_pkpaddrs2
                                 d_pkpkuh
                                 d_pkpcity
                                 d_pkppostal
*                                 d_nr_gsber
                                 d_nr_brnch
                                 d_name_kaadm
                                 d_name_kacab
                                 d_kaadm
                                 d_kacab
                                 d_coretax.
    ELSE.
******For NON-SERVICE --> use Billing division
      PERFORM f_get_pkp USING    fu_vkorg
                                 fu_gsber
                                 fu_spart
                                 fu_brnch
                                 fu_busln
                                 fu_bukrs
                                 fu_fakdat
                                 space
                                 space
                                 space
                        CHANGING d_petugas
                                 d_petugas2
                                 d_aktif
                                 d_jabat
                                 d_jabat2
                                 d_fpone
                                 d_fptwo
                                 d_objrange
                                 d_pkpnpwp
                                 d_pkpname
                                 d_pkpaddrs1
                                 d_pkpaddrs2
                                 d_pkpkuh
                                 d_pkpcity
                                 d_pkppostal
*                                 d_nr_gsber
                                 d_nr_brnch
                                 d_name_kaadm
                                 d_name_kacab
                                 d_kaadm
                                 d_kacab
                                 d_coretax.
    ENDIF.
  ENDIF.

***added by Rahmadi
*--To determine whether which PKP info will be used (Branch or HO)
  IF d_pkpfl IS INITIAL.
    d_aktif = d_baktif.
  ELSE.
    d_aktif = d_haktif.
  ENDIF.
***end of addition

**Get text
  PERFORM f_get_text USING
                           fu_vkorg
                           fu_gsber
                           fu_spart
                           fu_brnch
                           fu_busln
                           fu_bukrs
                  CHANGING
                           d_des_vk
                           d_des_bs
                           d_des_dv
                           d_des_br
                           d_des_bl
                           d_des_cc.
ENDFORM.                    "f_get_header_data

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*&  This routine performs phase two filtering (filtering out cancelled
*&  billings, fully returned billing item, billing whose no posted
*&  accounting docs and Service billings whose no kwitansi assigned to
*&  it) to the selected billing (T_VBRK1 => T_VBRK), then collect all
*&  supporting data to the corresponding billings. It will then also
*&  prepare billing internal table to be displayed on the screen
*&  (T_VBRKSCR) and the error log (T_ERROR).
*&  If this routine executed by RPC program (FU_RPC = 'X'), cancelled
*&  billings will still be kept with its cancellation docs.
*&---------------------------------------------------------------------*
*&  ->FU_VKORG  - Sales organization
*&  ->FU_GSBER  - Business Area
*&  ->FU_SPART  - Division
*&  ->FU_FAKDAT - Tax processing date
*&  ->FU_RPC    - 'X' if performed by RPC program
*&---------------------------------------------------------------------*
FORM f_process_data USING fu_vkorg fu_gsber fu_spart
                          fu_brnch fu_busln fu_bukrs
                          fu_fakdat
                          fu_rpc.

  DATA: ld_tabixn     LIKE sy-tabix, ld_tabixp LIKE sy-tabix,
        ld_tabixc     LIKE sy-tabix, ld_tabixx LIKE sy-tabix,
        ld_subrcn     LIKE sy-subrc, ld_subrcp LIKE sy-subrc,
        ld_subrcc     LIKE sy-subrc, ld_subrcx LIKE sy-subrc,
        ld_flagerr             , ld_cancel,
        ld_rpc_cancel          ,
        ld_cbelnr     LIKE zgdtxdt0002-belnr,
        lw_vbrk       LIKE t_vbrk, ld_tax    LIKE konv-kbetr,
        ld_vatin      LIKE konv-kwert,
        ld_vatout     LIKE konv-kwert,
        lt_vbrkzero   LIKE t_vbrk  OCCURS 1 WITH HEADER LINE,
        lt_unlock     LIKE t_error OCCURS 1 WITH HEADER LINE,
        lt_line       LIKE tline OCCURS 0,
        ld_sbc        LIKE sy-subrc,
        ld_karoseri   LIKE zgdtxdt0002-karoseri,
        ld_dpp        LIKE zgdtxdt0002-dpp,
        ld_ppnbm      LIKE zgdtxdt0002-ppnbm.

  CHECK NOT t_vbrk1[] IS INITIAL.
  SORT t_vbrk1 BY vbeln posnr fkdat.

**Get faktur no. & tax inclusion indicator for RPC program
  IF NOT fu_rpc IS INITIAL.
    PERFORM f_get_processed_billing TABLES t_vbrk1
                                     USING fu_vkorg fu_gsber
                                           fu_spart
                                           fu_brnch
                                           fu_busln
                                           fu_bukrs.
  ENDIF.

  CLEAR: t_vbrkc, t_tariff.
  REFRESH: t_vbrkc, t_tariff.

  SELECT SINGLE datab
    FROM zproject
    INTO va_datab
    WHERE name EQ 'ZGDTAX'.

*****  IF fu_brnch = '8360'.
*****    IF t_vbrk1[] IS NOT INITIAL.
*****      SELECT *
*****        FROM vbrp
*****        INTO CORRESPONDING FIELDS OF TABLE lt_vbrp
*****        FOR ALL ENTRIES IN t_vbrk1
*****        WHERE vbeln = t_vbrk1-vbeln.
*****    ENDIF.
*****  ENDIF.

  LOOP AT t_vbrk1.
    MOVE-CORRESPONDING t_vbrk1 TO lw_vbrk.

    AT NEW vbeln.
      CLEAR: ld_flagerr, ld_cancel, ld_rpc_cancel, t_tariff,ld_karoseri.
      ld_karoseri = lw_vbrk-karoseri.
    ENDAT.

    lw_vbrk-karos = ld_karoseri.
    IF ld_flagerr IS INITIAL.
      PERFORM f_check_acc_docs USING lw_vbrk
                                     'N'
                            CHANGING lw_vbrk-belnr
                                     ld_subrcn.
****removed by Rahmadi
*---Not generic and not relevant
*      IF ld_subrcn = 0.
*
**---Rama--- To Check whether this is required or not
*
*********Check KWITANSI -- Only for SERVICE (Error if no kwitansi)
*        IF lw_vbrk-spart = d_service.
*          PERFORM f_get_kwitansi USING lw_vbrk
*                              CHANGING lw_vbrk-kwitansi lw_vbrk-erdt2
*                                       ld_subrcn.
*          IF lw_vbrk-kwitansi IS INITIAL.
*            lw_vbrk-kwitansi = lw_vbrk-gsber.
*          ENDIF.
*        ELSE.
*
**Legacy Refference Number (Unit/Truck)
**Applicable for Live and Non Live (non live but in SAP R/3)
*          IF lw_vbrk-spart = d_truck OR
*             lw_vbrk-spart = d_fin_unit OR
*             lw_vbrk-spart = d_used.
*
*            PERFORM f_get_legacy_reference USING lw_vbrk
*                                CHANGING lw_vbrk-kwitansi.
*
*            CLEAR ld_subrcn.
*          ENDIF.
*          CLEAR ld_subrcn.
*        ENDIF.
*
**---Rama--- End of Check whether this is required or not rama
****end of removal

      IF ld_subrcn = 0.
**********Check Cancel docs
        READ TABLE t_vbrkfc WITH KEY vbelv = lw_vbrk-vbeln
                                     posnv = lw_vbrk-posnr
                                     BINARY SEARCH.
        IF sy-subrc = 0.
          ld_tabixc = sy-tabix.
          PERFORM f_check_acc_docs USING  t_vbrkfc
                                          'C'
                                 CHANGING ld_cbelnr ld_subrcc.
          IF ld_subrcc = 0.
*---------------------------------------------------------------*
*     If executed by RPC program, keep the cancelled billings
*---------------------------------------------------------------*
            IF fu_rpc IS INITIAL.
              PERFORM f_cancel_billing USING lw_vbrk.
              ld_cancel = 'X'.
            ELSE.
              CLEAR ld_cancel.
              ld_rpc_cancel = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.

**********NO cancel docs
        IF ld_cancel IS INITIAL.
************Get EQUIPMENT
          PERFORM f_get_equi USING lw_vbrk-ean11
                          CHANGING lw_vbrk-th_buat lw_vbrk-mesin.

***removed for Tempo
************Get FAKTUR DATE
*          lw_vbrk-fakdat = fu_fakdat.
*
************Get MASATX
*          lw_vbrk-masatx = fu_fakdat+0(6).
*
*          IF d_period_end IS INITIAL.
*            lw_vbrk-gjahr  = fu_fakdat+0(4).
*          ELSE.
*            lw_vbrk-gjahr = t_vbrk1-fkdat(4).
*          ENDIF.
***end of tempo removal

************Get Tax / VAT out
          PERFORM f_get_vat_out USING    lw_vbrk-vbeln lw_vbrk-posnr
                                CHANGING ld_tax        ld_vatout.

************Get VAT in
          PERFORM f_get_vat_in USING    lw_vbrk-vbeln lw_vbrk-posnr
                               CHANGING ld_vatin.

************Check Internal use (VAT out = VAT in)
          IF ld_vatout = ld_vatin.
            lw_vbrk-internal = 'X'.
          ELSE.
            CLEAR lw_vbrk-internal.
          ENDIF.

************Get ADDRESS
          IF lw_vbrk-internal = 'X'.
            lw_vbrk-name   = d_pkpname.
            lw_vbrk-addrs1 = d_pkpaddrs1.
            lw_vbrk-addrs2 = d_pkpaddrs2.
            lw_vbrk-city   = d_pkpcity.
            lw_vbrk-postal = d_pkppostal.
            lw_vbrk-stceg  = d_pkpnpwp.
          ELSE.
*-------------get customer from text req
            PERFORM f_get_custtext TABLES lt_line
                                    USING lw_vbrk-kunrg
                                 CHANGING lw_vbrk-name  lw_vbrk-addrs1
                                          lw_vbrk-addrs2 lw_vbrk-city
                                          lw_vbrk-postal ld_sbc.
            IF ld_sbc NE 0.
*** Koreksi By Sukardi
              BREAK bcdik.
              IF fu_brnch = '8220' OR fu_brnch = '8180' OR
                fu_brnch = '8210'.
                lw_vbrk-name = fu_vkorg.
              ENDIF.
              PERFORM f_get_address USING lw_vbrk-vbeln
                                 CHANGING lw_vbrk-name  lw_vbrk-addrs1
                                          lw_vbrk-addrs2 lw_vbrk-city
                                          lw_vbrk-postal lw_vbrk-kunnr
                                          lw_vbrk-stceg. "Rahmadi 300604
            ENDIF.
          ENDIF.

************Get WAPU
          IF lw_vbrk-kunnr = lw_vbrk-kunrg.
            PERFORM f_get_wapu USING    lw_vbrk-kunrg
                               CHANGING lw_vbrk-wapu  lw_vbrk-form.
          ELSE.
            PERFORM f_get_wapu USING    lw_vbrk-kunnr
                               CHANGING lw_vbrk-wapu  lw_vbrk-form.
          ENDIF.

*********** Add logic for Dragon Glory
          IF lw_vbrk-vkorg EQ '8050' OR
            lw_vbrk-vkorg EQ '8800'.
            IF lw_vbrk-spart EQ '60'.
              lw_vbrk-form  = d_a5.
            ENDIF.
          ENDIF.

************Get Amount
          PERFORM f_amounts USING    lw_vbrk
                                     ld_tax
                            CHANGING lw_vbrk-itamt    lw_vbrk-itdisc
                                     lw_vbrk-dpp      lw_vbrk-ppn
                                     lw_vbrk-ppnbm    lw_vbrk-xppnbm
                                     lw_vbrk-itoth    lw_vbrk-itqty
                                     lw_vbrk-examt    lw_vbrk-inamt
                                     lw_vbrk-itdiscex lw_vbrk-itdiscin
                                     lw_vbrk-stnk
*****added by Rahmadi
*--To store PPH 22 & PPH 23 amounts of the invoices
                                     lw_vbrk-pph22
                                     lw_vbrk-pph23.
*****end of addition


************Update last updated amounts
          IF ld_rpc_cancel IS INITIAL.
            lw_vbrk-itamtlast    = lw_vbrk-itamt.
            lw_vbrk-itdisclast   = lw_vbrk-itdisc.
            lw_vbrk-dpplast      = lw_vbrk-dpp.
            lw_vbrk-ppnlast      = lw_vbrk-ppn.
            lw_vbrk-ppnbmlast    = lw_vbrk-ppnbm.
            lw_vbrk-xppnbmlast   = lw_vbrk-xppnbm.
            lw_vbrk-itothlast    = lw_vbrk-itoth.
            lw_vbrk-itqtylast    = lw_vbrk-itqty.
            lw_vbrk-examtlast    = lw_vbrk-examt.
            lw_vbrk-inamtlast    = lw_vbrk-inamt.
            lw_vbrk-itdiscexlast = lw_vbrk-itdiscex.
            lw_vbrk-itdiscinlast = lw_vbrk-itdiscin.
            lw_vbrk-stnklast     = lw_vbrk-stnk.
*-------------Process follow-up docs
            PERFORM f_followup_docs
                    TABLES t_vbrkfo
                    USING  lw_vbrk  ld_tax
                 CHANGING  lw_vbrk-itamtlast    lw_vbrk-itdisclast
                           lw_vbrk-dpplast      lw_vbrk-ppnlast
                           lw_vbrk-ppnbmlast    lw_vbrk-xppnbmlast
                           lw_vbrk-itothlast    lw_vbrk-itqtylast
                           lw_vbrk-examtlast    lw_vbrk-inamtlast
                           lw_vbrk-itdiscexlast lw_vbrk-itdiscinlast
                           lw_vbrk-stnklast
****added by Rahmadi
*--To store PPH 22 & PPh 23 info of the billings
                           lw_vbrk-pph22
                           lw_vbrk-pph23.
****end of addition
          ELSE.  " --> Cancelled billing for RPC (all last amount = 0)
            lw_vbrk-itamtlast    = 0. lw_vbrk-itdisclast   = 0.
            lw_vbrk-dpplast      = 0. lw_vbrk-ppnlast      = 0.
            lw_vbrk-ppnbmlast    = 0. lw_vbrk-xppnbmlast   = 0.
            lw_vbrk-itothlast    = 0. lw_vbrk-itqtylast    = 0.
            lw_vbrk-examtlast    = 0. lw_vbrk-inamtlast    = 0.
            lw_vbrk-itdiscexlast = 0. lw_vbrk-itdiscinlast = 0.
            lw_vbrk-stnklast     = 0.
****added by Rahmadi
*--PPH 22 & PPh 23 will be ZERO if the billing is cancelled
            lw_vbrk-pph22 = 0.
            lw_vbrk-pph23 = 0.
****end of addition
          ENDIF.

************Get PPNBM TARIF
*----------------------------------------------------------------------*
*  PPNBM Tariff currently is only applicable for KKM FINISHED UNIT,
*  since KAROSERI TYPE, which is used to determine Tariff amount is
*  only available in KKM finished unit.
*----------------------------------------------------------------------*
          CLEAR: ld_dpp, ld_ppnbm.
          PERFORM f_determine_ppnbm_items USING lw_vbrk
                                          CHANGING ld_dpp
                                                   ld_ppnbm.
*            t_tariff-dpp   = t_tariff-dpp   + lw_vbrk-dpplast.
*            t_tariff-ppnbm = t_tariff-ppnbm + lw_vbrk-ppnbmlast.

          t_tariff-dpp   = t_tariff-dpp   + ld_dpp.
          t_tariff-ppnbm = t_tariff-ppnbm + ld_ppnbm.
***** End of modification.

************Exclude if amount = 0 (after adjusted by the follow-ups)
          IF d_rpc IS INITIAL AND
*------------Changed in Tempo:IF ONLY AMOUNT "AND" QUANTITY IS ZERO
*             ( lw_vbrk-itamtlast LE 0 OR lw_vbrk-itqtylast EQ 0 ).
             ( lw_vbrk-itamtlast LE 0 AND lw_vbrk-itqtylast EQ 0 ).
*-------------end of Tempo changes
            MOVE-CORRESPONDING lw_vbrk TO lt_vbrkzero.
            APPEND lt_vbrkzero.
            CONTINUE.
          ENDIF.

************Get Tax inclusion indicator for RPC program
          IF NOT fu_rpc IS INITIAL.
            READ TABLE t_process WITH KEY vbeln = lw_vbrk-vbeln
                                 BINARY SEARCH.
            IF t_process-exclude IS INITIAL.
              t_vbrkscr-tax = 'X'.
            ELSE.
              CLEAR t_vbrkscr-tax.
            ENDIF.
            lw_vbrk-exclude = t_process-exclude.
          ENDIF.
*----------- For zero ppn add by sukardi req by cosultan IBM Lisa yanti project TDG2
*******
          BREAK bcdik.
          IF fu_brnch = '8220' OR fu_brnch = '8210'.
            IF lw_vbrk-ppnlast EQ 0.
              lw_vbrk-ppnlast = 1.
**** tambahan ceking untuk mengalihkan internal
              IF fu_brnch = '8220' OR fu_brnch = '8180' OR
                fu_brnch = '8210'.
                lw_vbrk-name = fu_vkorg.
              ENDIF.
              CLEAR: lw_vbrk-internal.
              PERFORM f_get_address USING lw_vbrk-vbeln
                                 CHANGING lw_vbrk-name  lw_vbrk-addrs1
                                          lw_vbrk-addrs2 lw_vbrk-city
                                          lw_vbrk-postal lw_vbrk-kunnr
                                          lw_vbrk-stceg. "
*******
            ENDIF.
          ENDIF.
*******
          IF d_rpc IS INITIAL AND
             lw_vbrk-ppnlast LE 0.
            MOVE-CORRESPONDING lw_vbrk TO t_error.
            t_error-msg = 'This billing has no VAT value'.
            APPEND t_error.
          ELSE.
            IF fu_brnch = '8220' OR fu_brnch = '8210'.
              IF lw_vbrk-ppnlast EQ 1.
                lw_vbrk-ppnlast = 0.
              ENDIF.
            ENDIF.
            IF lw_vbrk-waerk NE c_local_curr.
              IF d_tcode = c_tcode_sederhana OR
                 d_tcode = c_tcode_sederhana_single.
*----------- Get tax rate base on ratio defined
*----------- Get base on Billing Date
                PERFORM f_get_tax_rate USING lw_vbrk-waerk
                                             lw_vbrk-fkdat
                                             c_local_curr.
              ELSE.


*----------- Get tax rate base on ratio defined
*----------- Get base on Faktur Pajak Date / Faktur Printing date
*----- Koreksi by budi 19/09/2005
*                PERFORM f_get_tax_rate USING lw_vbrk-waerk
*                                             lw_vbrk-fakdat
*                                             c_local_curr.
*                PERFORM f_get_tax_rate USING lw_vbrk-waerk
*                                             lw_vbrk-fkdat
*                                             c_local_curr.
*----- End of Koreksi by budi 19/09/2005
******* Koreksi by sukardi 20/04/2006
**** Req by trias
**** Exchange Rate diambil berdasarkan
***** Acctual GI Posting (LIKP-WADAT_IST)
                PERFORM f_get_tax_rate USING lw_vbrk-waerk
                                             lw_vbrk-wadat_ist
                                             c_local_curr.

***** Ending Koreksi By sukardi
              ENDIF.
*----------- Recondition Tax information then save the original
*----------- transactions amount into foreign currency field (F)
              lw_vbrk-ppndate = d_tax_valid.
              lw_vbrk-itamt_f = lw_vbrk-examtlast. "Exclude Tax
              lw_vbrk-itdisc_f = lw_vbrk-itdiscexlast. " Exclude Tax
              lw_vbrk-itoth_f = lw_vbrk-itothlast.
              lw_vbrk-dpp_f = lw_vbrk-dpplast.
              lw_vbrk-ppn_f = lw_vbrk-ppnlast.
              lw_vbrk-ppnbm_f = lw_vbrk-ppnbmlast.
              lw_vbrk-xppnbm_f = lw_vbrk-xppnbmlast.
              IF d_tcode = c_tcode_satuan OR d_tcode = c_tcode_split.
                lw_vbrk-fakppn_f = lw_vbrk-ppnlast.
                lw_vbrk-fakppnbm_f = lw_vbrk-ppnbmlast.
                lw_vbrk-fakxppnbm_f = lw_vbrk-xppnbmlast.
              ENDIF.
*----------- Translate the billing transaction into local currency
**************Updated in Tempo:rate no need to multiplied by rate factor
*-------------if using BAPI function
*              d_rate_tax = d_rate_tax * d_ratefactor.
**************End of Tempo update
              lw_vbrk-rate_tax = d_rate_tax / 100.
              lw_vbrk-trcurr = lw_vbrk-waerk.
              lw_vbrk-waerk = c_local_curr.
              lw_vbrk-fakcurr = lw_vbrk-trcurr.
              lw_vbrk-fakrate = lw_vbrk-rate_tax.
* begin new command
**----------- Convert DPP & PPN amount into local currency
**----------- This convertion base on Tax Rate
*              lw_vbrk-dpp = lw_vbrk-dpp * d_rate_tax / 100.
*              lw_vbrk-dpplast = lw_vbrk-dpplast * d_rate_tax / 100.
*              IF lw_vbrk-spart NE d_used.
*                lw_vbrk-ppn = 10 / 100 * lw_vbrk-dpp.
*                lw_vbrk-ppnlast = 10 / 100 * lw_vbrk-dpplast.
*                lw_vbrk-ppn2 = 10 / 100 * lw_vbrk-dpp.
*                lw_vbrk-ppn2last = 10 / 100 * lw_vbrk-dpplast.
*              ELSE.
*                lw_vbrk-ppn = ( 1 / 100 ) * lw_vbrk-dpp.
*                lw_vbrk-ppnlast = ( 1 / 100 ) * lw_vbrk-dpplast.
*                lw_vbrk-ppn2 = ( 1 / 100 ) * lw_vbrk-dpp.
*                lw_vbrk-ppn2last = ( 1 / 100 ) * lw_vbrk-dpplast.
*              ENDIF.
* end new command
              IF lw_vbrk-spart NE d_used.
              ELSE.
                lw_vbrk-ppn = ( 1 / 100 ) * lw_vbrk-dpp.
                lw_vbrk-ppnlast = ( 1 / 100 ) * lw_vbrk-dpplast.
                lw_vbrk-ppn2 = ( 1 / 100 ) * lw_vbrk-dpp.
                lw_vbrk-ppn2last = ( 1 / 100 ) * lw_vbrk-dpplast.
              ENDIF.

              lw_vbrk-ppn = lw_vbrk-ppn * d_rate_tax / 100.
              lw_vbrk-ppnlast = lw_vbrk-ppnlast * d_rate_tax / 100.
              lw_vbrk-ppn2 = lw_vbrk-ppn * d_rate_tax / 100.
              lw_vbrk-ppn2last = lw_vbrk-ppnlast * d_rate_tax / 100.
              lw_vbrk-dpp = lw_vbrk-dpp * d_rate_tax / 100.
              lw_vbrk-dpplast = lw_vbrk-dpplast * d_rate_tax / 100.
*--------- new command


*----------- Convert Amount,Disc PPNBM into local currency
*----------- This convertion base on Billing Rate / Normal Rate
**************Tempo: Use Tax rate ZTAX for the transaction - all pricing
*              d_rate_std = lw_vbrk-kurrf * d_ratefactor.
              d_rate_std = d_rate_tax.
**************End of Tempo change
              lw_vbrk-rate_std = d_rate_std / 100.
              lw_vbrk-bilrate = lw_vbrk-rate_std.
              lw_vbrk-itdisc = lw_vbrk-itdisc * d_rate_std / 100.
              lw_vbrk-itdisclast =
              lw_vbrk-itdisclast * d_rate_std / 100.
              lw_vbrk-itamt = lw_vbrk-itamt * d_rate_std / 100.
              lw_vbrk-itamtlast =
              lw_vbrk-itamtlast * d_rate_std / 100.
              lw_vbrk-ppnbm = lw_vbrk-ppnbm * d_rate_std / 100.
              lw_vbrk-ppnbmlast =
              lw_vbrk-ppnbmlast * d_rate_std / 100.
              lw_vbrk-xppnbm = lw_vbrk-xppnbm * d_rate_std / 100.
              lw_vbrk-xppnbmlast =
              lw_vbrk-xppnbmlast * d_rate_std / 100.
              lw_vbrk-mwsbp = lw_vbrk-mwsbp * d_rate_std / 100.
              lw_vbrk-examt = lw_vbrk-examt * d_rate_std / 100.
              lw_vbrk-inamt = lw_vbrk-inamt * d_rate_std / 100.
              lw_vbrk-itdiscex = lw_vbrk-itdiscex * d_rate_std / 100.
              lw_vbrk-itdiscin = lw_vbrk-itdiscin * d_rate_std / 100.
              lw_vbrk-examtlast =
              lw_vbrk-examtlast * d_rate_std / 100.
              lw_vbrk-inamtlast =
              lw_vbrk-inamtlast * d_rate_std / 100.
              lw_vbrk-itdiscinlast =
              lw_vbrk-itdiscinlast * d_rate_std / 100.
              lw_vbrk-itdiscexlast =
              lw_vbrk-itdiscexlast * d_rate_std / 100.
*------------ Tariff must be converted into local currency
              t_tariff-dpp = t_tariff-dpp * d_rate_tax / 100.
              t_tariff-ppnbm = t_tariff-ppnbm * d_rate_std / 100.
            ELSE.
              lw_vbrk-rate_tax = 1.
              lw_vbrk-rate_std = 1.
              lw_vbrk-trcurr = lw_vbrk-waerk.
              lw_vbrk-fakcurr = lw_vbrk-waerk.
              lw_vbrk-fakrate = 1.
              lw_vbrk-bilrate = 1.
*------------ Eliminated rounding problem (Hard code)
              IF lw_vbrk-spart NE d_used.
                lw_vbrk-ppn2 = 10 / 100 * lw_vbrk-dpp.
                lw_vbrk-ppn2last = 10 / 100 * lw_vbrk-dpplast.
              ELSE.
                lw_vbrk-ppn2 = ( 1 / 100 ) * lw_vbrk-dpp.
                lw_vbrk-ppn2last = ( 1 / 100 ) * lw_vbrk-dpplast.
              ENDIF.
            ENDIF.

****added by Rahmadi -- bugs fixed in Tempo
*---Routine to put USER EXIT for additional data processing
            PERFORM f_additional_data_procs USING lw_vbrk
                                            CHANGING lw_vbrk.
****end of addition

            MOVE-CORRESPONDING lw_vbrk TO t_vbrk.
            APPEND t_vbrk.
            MOVE-CORRESPONDING lw_vbrk TO t_vbrkscr.
            IF sy-datum GE va_datab.
              PERFORM f_modify_tgl_faktur_pajak USING fu_brnch t_vbrkscr-vbeln
                                                CHANGING t_vbrkscr-fakdat.
            ENDIF.
            COLLECT t_vbrkscr.
          ENDIF.
*---------------------------------------------------------------*
*     If executed by RPC program, save the cancel billings
*---------------------------------------------------------------*
          IF NOT ld_rpc_cancel IS INITIAL AND
             NOT fu_rpc IS INITIAL.
            IF t_vbrkfc-waerk NE c_local_curr.
*----------- Recondition Tax information then save the original
*----------- transactions amount into foreign currency field (F)
              t_vbrkfc-itamt_f = t_vbrkfc-examtlast. "Exclude Tax
              t_vbrkfc-itdisc_f = t_vbrkfc-itdiscexlast. " Exclude Tax
              t_vbrkfc-itoth_f = t_vbrkfc-itothlast.
              t_vbrkfc-dpp_f = t_vbrkfc-dpplast.
              t_vbrkfc-ppn_f = t_vbrkfc-ppnlast.
              t_vbrkfc-ppnbm_f = t_vbrkfc-ppnbmlast.
              t_vbrkfc-xppnbm_f = t_vbrkfc-xppnbmlast.
              IF d_tcode = c_tcode_satuan OR d_tcode = c_tcode_split.
                t_vbrkfc-fakppn_f = t_vbrkfc-ppnlast.
                t_vbrkfc-fakppnbm_f = t_vbrkfc-ppnbmlast.
                t_vbrkfc-fakxppnbm_f = t_vbrkfc-xppnbmlast.
              ENDIF.
*----------- Translate the billing transaction into local currency
*                d_rate_tax = d_rate_tax * d_ratefactor.
*                lw_vbrk-rate_tax = d_rate_tax / 100.
              t_vbrkfc-trcurr = t_vbrkfc-waerk.
              t_vbrkfc-waerk = c_local_curr.
              t_vbrkfc-fakcurr = t_vbrkfc-trcurr.
*----------- Convert Amount,Disc PPNBM into local currency
*----------- This convertion base on Billing Rate / Normal Rate
              d_rate_std = t_vbrkfc-kurrf * d_taxfactor.
              t_vbrkfc-rate_std = d_rate_std / 100.
              t_vbrkfc-itdisc = t_vbrkfc-itdisc * d_rate_std / 100.
              t_vbrkfc-itdisclast =
              t_vbrkfc-itdisclast * d_rate_std / 100.
              t_vbrkfc-itamt = t_vbrkfc-itamt * d_rate_std / 100.
              t_vbrkfc-itamtlast =
              t_vbrkfc-itamtlast * d_rate_std / 100.
              t_vbrkfc-ppnbm = t_vbrkfc-ppnbm * d_rate_std / 100.
              t_vbrkfc-ppnbmlast =
              t_vbrkfc-ppnbmlast * d_rate_std / 100.
              t_vbrkfc-xppnbm = t_vbrkfc-xppnbm * d_rate_std / 100.
              t_vbrkfc-xppnbmlast =
              t_vbrkfc-xppnbmlast * d_rate_std / 100.
              t_vbrkfc-mwsbp = t_vbrkfc-mwsbp * d_rate_std / 100.
              t_vbrkfc-examt = t_vbrkfc-examt * d_rate_std / 100.
              t_vbrkfc-inamt = t_vbrkfc-inamt * d_rate_std / 100.
              t_vbrkfc-itdiscex =
              t_vbrkfc-itdiscex * d_rate_std / 100.
              t_vbrkfc-itdiscin =
              t_vbrkfc-itdiscin * d_rate_std / 100.
              t_vbrkfc-examtlast =
              t_vbrkfc-examtlast * d_rate_std / 100.
              t_vbrkfc-inamtlast =
              t_vbrkfc-inamtlast * d_rate_std / 100.
              t_vbrkfc-itdiscinlast =
              t_vbrkfc-itdiscinlast * d_rate_std / 100.
              t_vbrkfc-itdiscexlast =
              t_vbrkfc-itdiscexlast * d_rate_std / 100.
            ELSE.
              t_vbrkfc-trcurr = t_vbrkfc-waerk.
              t_vbrkfc-fakcurr = t_vbrkfc-trcurr.
            ENDIF.
            MOVE-CORRESPONDING t_vbrkfc TO t_vbrkc.
            PERFORM f_filling_up_addt_info USING lw_vbrk
                                        CHANGING t_vbrkc.
            t_vbrkc-vbelv = lw_vbrk-vbeln.
            t_vbrkc-posnv = lw_vbrk-posnr.
            APPEND t_vbrkc.
          ENDIF.
        ELSE.
          ld_flagerr = 'X'.
        ENDIF.
      ELSE.
        ld_flagerr = 'X'.
      ENDIF.
***removed by Rahmadi
*      ELSE.
*        ld_flagerr = 'X'.
*      ENDIF.
***end of removal
    ENDIF.

    AT END OF vbeln.
*---------------------------------------------------------------*
*     If executed by RPC program, billing status will be filled
*---------------------------------------------------------------*
      READ TABLE t_vbrkscr WITH KEY vbeln = lw_vbrk-vbeln.
      IF t_vbrkscr-itamtlast = 0.
        IF NOT fu_rpc IS INITIAL.
          t_vbrkscr-status = c_status_cancel.
          MODIFY t_vbrkscr TRANSPORTING status
                           WHERE vbeln = lw_vbrk-vbeln.
        ELSE.
          ld_flagerr = 'X'.
        ENDIF.
      ENDIF.

******Collect TARIFF TABLE
      IF t_tariff-dpp <> 0 AND
         t_tariff-ppnbm <> 0.
        t_tariff-tarifxpbm = ( t_tariff-ppnbm / t_tariff-dpp ) * 100.
        IF t_tariff-tarifxpbm <> 0.
          t_tariff-vbeln = lw_vbrk-vbeln.
          APPEND t_tariff.
        ELSE.
          CLEAR t_tariff.
        ENDIF.
      ELSE.
        CLEAR t_tariff.
      ENDIF.

*-----Adjust PPNBM in Follow-up docs for kkm finished unit
*-----(for TARIFF purpose)
      PERFORM f_tariff_followup TABLES t_vbrkf
                                USING  lw_vbrk.
      IF NOT fu_rpc IS INITIAL.
        PERFORM f_tariff_followup TABLES t_vbrkc
                                  USING  lw_vbrk.
      ENDIF.

******Proceed ONLY billing with no erroneous item
      IF NOT ld_flagerr IS INITIAL.
        READ TABLE t_vbrk WITH KEY vbeln = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrk WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
        READ TABLE t_vbrkf WITH KEY vbelv = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrkf WHERE vbelv = lw_vbrk-vbeln.
        ENDIF.
        READ TABLE t_vbrkscr WITH KEY vbeln = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrkscr WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
      ENDIF.
      CLEAR ld_flagerr.
    ENDAT.
    CLEAR: t_tariff-dpp.
  ENDLOOP.

**Check quantity zero -- Delete RETURN if ZERO
  IF fu_rpc IS INITIAL.
    IF NOT lt_vbrkzero[] IS INITIAL.
      LOOP AT lt_vbrkzero.
        MOVE-CORRESPONDING lt_vbrkzero TO t_error.
        CONCATENATE 'Material' lt_vbrkzero-matnr
                    'has been fully returned'
                    INTO t_error-msg
                    SEPARATED BY space.
        APPEND t_error.
      ENDLOOP.
    ENDIF.
  ENDIF.

**Unlocking error billings
  IF NOT t_error[] IS INITIAL.
    lt_unlock[] = t_error[].
    SORT lt_unlock BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_unlock COMPARING vbeln.
    LOOP AT lt_unlock.
      PERFORM f_unlock_error_billing USING lt_unlock-vbeln.
    ENDLOOP.
    SORT t_error BY msg vbeln.
  ENDIF.

**Sorting tables
  IF NOT t_vbrkscr[] IS INITIAL.
    SORT t_vbrkscr BY vbeln.
  ENDIF.
  IF NOT t_vbrk[] IS INITIAL.
    SORT t_vbrk BY vbeln posnr.
  ENDIF.
  IF NOT t_vbrkf[] IS INITIAL.
    SORT t_vbrkf BY vbelv posnv.
  ENDIF.
  IF NOT t_tariff[] IS INITIAL.
    SORT t_tariff BY vbeln.
  ENDIF.
  IF NOT fu_rpc IS INITIAL.
    IF NOT t_vbrkc[] IS INITIAL.
      SORT t_vbrkc BY vbelv posnv.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_KAROSERI_ITEMDIV
*&---------------------------------------------------------------------*
*&  This routine determines karoseri (assembly) type and item division
*&  of the material based on the selected record in global table T_MARA
*&---------------------------------------------------------------------*
*&  ->FU_MATNR     - Material number
*&  <-FC_KAROSERI  - Karoseri type
*&  <-FC_ITEMDIV   - Item Division
*&---------------------------------------------------------------------*
FORM f_get_karoseri_itemdiv USING fu_matnr
                         CHANGING fc_karoseri
                                  fc_itemdiv.

  READ TABLE t_mara WITH KEY matnr = fu_matnr
                             BINARY SEARCH.
  IF sy-subrc = 0.
    IF t_mara-matkl = d_accsopt AND
       t_mara-mtart <> d_zfin.
      fc_karoseri = d_kara.
    ELSEIF t_mara-matkl = d_karoseri AND
           t_mara-mtart <> d_zfin.
      fc_karoseri = d_kark.
    ELSEIF t_mara-mtart = d_zfin.
      fc_karoseri = d_karu.
    ELSE.
      CLEAR fc_karoseri.
    ENDIF.
    fc_itemdiv = t_mara-spart.
  ELSE.
    CLEAR fc_karoseri.
  ENDIF.

ENDFORM.                    " F_GET_KAROSERI_ITEMDIV

*&---------------------------------------------------------------------*
*&      Form  F_GET_EQUI
*&---------------------------------------------------------------------*
*&  This routine determines serial number, construction year and
*&  manufacturer part number based on the selected record in global
*&  table T_EQUI
*&---------------------------------------------------------------------*
*&  ->FU_EAN11     - Serial number
*&  <-FC_BAUJJ     - Construction year
*&  <-FC_MAPAR     - manufacturer part number
*&---------------------------------------------------------------------*
FORM f_get_equi USING    fu_ean11
                CHANGING fc_baujj
                         fc_mapar.

  READ TABLE t_equi WITH KEY equnr = fu_ean11
                             BINARY SEARCH.
  IF sy-subrc = 0.
    fc_baujj = t_equi-baujj.
    fc_mapar = t_equi-mapar.
  ELSE.
    CLEAR: fc_baujj, fc_mapar.
  ENDIF.

ENDFORM.                    " F_GET_EQUI

*&---------------------------------------------------------------------*
*&      Form  F_GET_KWITANSI
*&---------------------------------------------------------------------*
*&  This routine determines kwitansi data based on the selected record
*&  in global table T_KWITANSI
*&  Service billing must have kwitansi number attached to it. Otherwise
*&  it will be considered as an error
*&---------------------------------------------------------------------*
*&  ->FU_VBRK     - Billing data
*&  <-FC_KWITANSI - Kwitansi number
*&  <-FC_ERDT2    - kwitansi date
*&  <-FC_SUBRC    - Return code (Error: FC_SUBRC <> 0)
*&---------------------------------------------------------------------*
FORM f_get_kwitansi USING    fu_vbrk LIKE t_vbrk
                    CHANGING fc_kwitansi
                             fc_erdt2
                             fc_subrc.

  DATA lt_kwitansi LIKE t_kwitansi OCCURS 1 WITH HEADER LINE.

  READ TABLE t_kwitansi WITH KEY ibeln = fu_vbrk-vbeln
                        BINARY SEARCH.
  fc_subrc = sy-subrc.
  IF fc_subrc = 0.
*Possible to have more than one kwitansi in a billing
*Get the latest (based on kwitansi number)
    lt_kwitansi[] = t_kwitansi[].                           "CR006
    DELETE lt_kwitansi WHERE NOT ibeln = fu_vbrk-vbeln.     "CR006
    SORT lt_kwitansi BY zcsh1 DESCENDING.                   "CR006
    READ TABLE lt_kwitansi INDEX 1.                         "CR006
    IF sy-subrc = 0.
      IF lt_kwitansi-zcsh1 IS INITIAL.                      "CR006
        CLEAR: fc_kwitansi, fc_erdt2.
        fc_subrc = 8.
      ELSE.
        fc_kwitansi = lt_kwitansi-zcsh1.                    "CR006
        fc_erdt2 = lt_kwitansi-erdt2.                       "CR006
      ENDIF.
    ELSE.
      CLEAR: fc_kwitansi, fc_erdt2.
      fc_subrc = 8.
    ENDIF.
  ELSE.
  ENDIF.
  fc_subrc = 0.

ENDFORM.                    " F_GET_KWITANSI

*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_BILLING
*&---------------------------------------------------------------------*
*&  This routine excludes cancelled billing and put it into error log
*&---------------------------------------------------------------------*
*&  ->FU_VBRK     - Billing number
*&---------------------------------------------------------------------*
FORM f_cancel_billing USING  fu_vbrk LIKE t_vbrk.

  MOVE-CORRESPONDING fu_vbrk TO t_error.
  t_error-msg = 'The billing has been cancelled'.
  APPEND t_error.

ENDFORM.                    " F_CANCEL_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*&  This routine pops up a confirmation windows whenever user decide
*&  to exit the program/transaction
*&---------------------------------------------------------------------*
*&  ->FU_TITLE     - Popup title
*&  ->FU_TEXT1     - Popup text 1
*&  ->FU_TEXT2     - Popup text 2
*&  <-FC_ANSWER    - User action
*&---------------------------------------------------------------------*
FORM f_popup_to_confirm_step USING  fu_title
                                    fu_text1
                                    fu_text2
                           CHANGING fc_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = 'N'
      textline1      = fu_text1
      textline2      = fu_text2
      titel          = fu_title
      start_column   = 25
      start_row      = 6
      cancel_display = 'X'
    IMPORTING
      answer         = fc_answer
    EXCEPTIONS
      OTHERS         = 1.

ENDFORM.                               " POPUP_TO_CONFIRM_STEP

*&---------------------------------------------------------------------*
*&       FORM f_error_list                                             *
*&---------------------------------------------------------------------*
*&  This routine displays all errors logged by the programs stored in
*&  T_ERROR table
*&---------------------------------------------------------------------*
FORM f_error_list.


  SORT t_error BY vbeln msg.
  DELETE ADJACENT DUPLICATES FROM t_error COMPARING vbeln msg.

  IF t_error[] IS INITIAL.
    SKIP 1.
    WRITE: /13 'No error occurs'.
  ELSE.
    ULINE AT /(90).
    WRITE: /  sy-vline NO-GAP, 'Billing doc' NO-GAP,
           13 sy-vline NO-GAP, 'Error message' NO-GAP,
           90 sy-vline.
    ULINE AT /(90).
    LOOP AT t_error.
      WRITE: /  sy-vline NO-GAP, t_error-vbeln NO-GAP,
             13 sy-vline NO-GAP, t_error-msg(60) NO-GAP,
            90 sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(90).
  ENDIF.

ENDFORM.                    "f_error_list

*&---------------------------------------------------------------------*
*&      Form  F_VALID_DATE
*&---------------------------------------------------------------------*
*&  This routine prevents user to enter wrong billing date (later than
*&  faktur date and/or across month
*&---------------------------------------------------------------------*
*&  ->FT_FKDAT     - Billing date range
*&---------------------------------------------------------------------*
FORM f_valid_date TABLES  ft_fkdat STRUCTURE r_fkdat.
  DATA: ld_end LIKE sy-datum.

***changed for Tempo
*  CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
  CALL FUNCTION 'SLS_MISC_GET_LAST_DAY_OF_MONTH'
***end of changes
    EXPORTING
      day_in            = ft_fkdat-low
    IMPORTING
      last_day_of_month = ld_end
    EXCEPTIONS
      day_in_not_valid  = 1
      OTHERS            = 2.

  IF ft_fkdat-high > ld_end.
    MESSAGE e508(ztx). " WITH ft_fkdat-high.
  ENDIF.

ENDFORM.                    " F_VALID_DATE

*&---------------------------------------------------------------------*
*&      Form  F_VALID_DATE_SEDERHANA
*&---------------------------------------------------------------------*
*&  This routine prevents user to enter wrong billing date (later than
*&  faktur date and/or across month
*&---------------------------------------------------------------------*
*&  ->FT_FKDAT     - Billing date range
*&---------------------------------------------------------------------*
FORM f_valid_date_sederhana TABLES  ft_fkdat STRUCTURE r_fkdat
                            USING   fu_masatx.
  DATA: ld_end     LIKE sy-datum,
        ld_masatx1 LIKE zgdtxdt0002-masatx,
        ld_masatx2 LIKE zgdtxdt0002-masatx,
        ld_masatx0 LIKE zgdtxdt0002-masatx.

***changed for Tempo
*  CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
  CALL FUNCTION 'SLS_MISC_GET_LAST_DAY_OF_MONTH'
***end of changes
    EXPORTING
      day_in            = ft_fkdat-low
    IMPORTING
      last_day_of_month = ld_end
    EXCEPTIONS
      day_in_not_valid  = 1
      OTHERS            = 2.

  ld_masatx0 = ft_fkdat-low+0(6).
  ld_masatx1 = ft_fkdat-low+0(6) - 1.
  ld_masatx2 = ft_fkdat-low+0(6) + 2.

  IF ft_fkdat-high IS INITIAL.
    IF ft_fkdat-low GE sy-datum.
      MESSAGE e000(ztx) WITH 'Cannot process future billings'.
    ENDIF.

    IF ft_fkdat-low+0(6) > fu_masatx.
      MESSAGE e000(ztx) WITH 'FP Sederhana can only be processed after'
                             'the end of tax period'
                             fu_masatx+4(2) fu_masatx+0(4).
    ENDIF.
  ELSE.
    IF ft_fkdat-high > ld_end.
      MESSAGE e508(ztx).
    ENDIF.

    IF ft_fkdat-high > sy-datum.
      MESSAGE e000(ztx) WITH 'Cannot process future billings'.
    ENDIF.

    IF ft_fkdat-high+0(6) > fu_masatx.
      MESSAGE e000(ztx) WITH 'FP Sederhana can only be processed after'
                             'the end of tax period'
                             fu_masatx+4(2) fu_masatx+0(4).
    ENDIF.
  ENDIF.

  IF fu_masatx LE ld_masatx1 OR
     fu_masatx GE ld_masatx2.
    MESSAGE e000(ztx) WITH 'Cannot process within selected period'.
  ENDIF.

***remarked so it can be processed within the same month
*  IF fu_masatx = ld_masatx0.
*    PERFORM f_get_lastplus USING ld_masatx0.
*  ENDIF.
***end of remark

ENDFORM.                    " F_VALID_DATE_SEDERHANA

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
*&  This routine clears all variables/internal tables when program
*&  switches from one screen to another screen. Cleared variables will
*&  depend on the step where the program is progressing
*&---------------------------------------------------------------------*
*&  ->FU_STEP     - User step.
*&                  Step 01: Exit processing (back to selection screen)
*&                  Step 02: Exit from preview screen
*&---------------------------------------------------------------------*
FORM f_clear_data USING fu_step.

  CASE fu_step.
    WHEN '01'.
      macro_init_ranges t_vbrk.
      macro_init_ranges t_vbrk1.
      macro_init_ranges t_vbrk0.
      macro_init_ranges t_vbrkf.
      macro_init_ranges t_vbrkfo.
      macro_init_ranges t_vbrkfc.
      macro_init_ranges t_vbrkfx.
      macro_init_ranges t_vbrkscr.
      macro_init_ranges t_vbfaa.
      macro_init_ranges t_vbfac.
      macro_init_ranges t_zgdtxdt0002.
      macro_init_ranges t_zgdtxdt0003.
      macro_init_ranges t_fpkp.
      macro_init_ranges t_fcustomer.
      macro_init_ranges t_fitem.
      macro_init_ranges t_fsignature.
      macro_init_ranges t_ftax.
      macro_init_ranges t_error.
      macro_init_ranges t_process.
      CLEAR: d_rpc, d_period_end, d_printx.
    WHEN '02'.
      macro_init_ranges t_zgdtxdt0002.
      macro_init_ranges t_zgdtxdt0003.
      macro_init_ranges t_fpkp.
      macro_init_ranges t_fcustomer.
      macro_init_ranges t_fitem.
      macro_init_ranges t_fsignature.
      macro_init_ranges t_ftax.
      CLEAR: d_printx.
  ENDCASE.

ENDFORM.                    " F_CLEAR_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_ALL_BILLING
*&---------------------------------------------------------------------*
*&  This routine releases all billings after process has been completed
*&---------------------------------------------------------------------*
FORM f_unlock_all_billing.

  CALL FUNCTION 'DEQUEUE_ALL'
*    EXPORTING
*         _SYNCHRON = ' '
    .
ENDFORM.                    " F_UNLOCK_ALL_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SCREEN
*&---------------------------------------------------------------------*
*&  This routine prepares what to display in the program main screen.
*&  What to display in the screen depends on active PKP the program is
*&  using
*&---------------------------------------------------------------------*
*&  ->FU_AKTIF     - Active PKP office
*&  ->FC_ACT1      - 'X' if tax officer 1 is active
*&  ->FU_ACT2      - 'X' if tax officer 2 is active
*&  ->FU_ACT5      - 'X' if custom tax officer is active
*&---------------------------------------------------------------------*
FORM f_prepare_screen USING fu_aktif
                      CHANGING fc_act1
                               fc_act2
                               fc_act5.

**Get Active PKP Officer
  CASE fu_aktif.
    WHEN '1'.
      fc_act1 = 'X'.
      CLEAR: fc_act2, fc_act5.
    WHEN '2'.
      fc_act2 = 'X'.
      CLEAR: fc_act1, fc_act5.
    WHEN '5'.
      fc_act5 = 'X'.
      CLEAR: fc_act1, fc_act2.
  ENDCASE.

ENDFORM.                    " F_PREPARE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_GET_VKORG_TEXT
*&---------------------------------------------------------------------*
*&  This routine retrieves Sales organization description
*&---------------------------------------------------------------------*
*&  ->FU_VKORG     - Sales organization
*&  ->FC_DES_CC    - Sales organization description
*&---------------------------------------------------------------------*
FORM f_get_vkorg_text USING fu_vkorg
                   CHANGING fc_des_cc.

  SELECT SINGLE vtext INTO fc_des_cc FROM tvkot
         WHERE vkorg = fu_vkorg
           AND spras = sy-langu.

ENDFORM.                    " F_GET_VKORG_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_GSBER_TEXT
*&---------------------------------------------------------------------*
*&  This routine retrieves Business are description
*&---------------------------------------------------------------------*
*&  ->FU_GSBER     - Business Area
*&  ->FC_DES_BS    - Business are description
*&---------------------------------------------------------------------*
FORM f_get_gsber_text USING  fu_gsber
                    CHANGING fc_d_des_bs.

  SELECT SINGLE gtext INTO fc_d_des_bs FROM tgsbt
         WHERE gsber = fu_gsber
           AND spras = sy-langu.

ENDFORM.                    " F_GET_GSBER_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_SPART_TEXT
*&---------------------------------------------------------------------*
*&  This routine retrieves Division description
*&---------------------------------------------------------------------*
*&  ->FU_SPART     - Division
*&  ->FC_DES_CC    - Division description
*&---------------------------------------------------------------------*
FORM f_get_spart_text USING  fu_spart
                   CHANGING  fc_d_des_dv.

  SELECT SINGLE vtext INTO fc_d_des_dv FROM tspat
         WHERE spart = fu_spart
           AND spras = sy-langu.

ENDFORM.                    " F_GET_SPART_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_FAKTUR_NO
*&---------------------------------------------------------------------*
*&    This routine assigns new sequence number to a new faktur pajak.
*&    The assignment is specific for each PKP, therefore the object
*&    range and business area passed to this routine are retrieved from
*&    F_GET_PKP routine as a preceeding process that has to be performed
*&    BEFORE performing this routine.
*&    Before assigning a new number to a new faktur pajak, this routine
*&    will have to check for a reusable number (from a cancelled faktur)
*&    from ZGDTXDt0011 table.
*&---------------------------------------------------------------------*
*&    ->FU_OBJECT   -  Number range Object id
*&    ->FU_GSBER    -  Business area as a sub-object of the number range
*&    ->FU_MASATX   -  Tax period. A reusable number can only be reused
*&                     for a new faktur pajak in a same period
*&    <-FC_FAKTURNO -  New faktur no.
*&    <-FC_SUBRC    -  This parameter will be <> 0 if no new number can
*&                     be assigned to the faktur pajak
*&---------------------------------------------------------------------*
FORM f_get_faktur_no USING fu_object
                           fu_gsber
                           fu_bukrs
                           fu_brnch
                           fu_masatx
                           fu_form
                           fu_fakdat
                           fu_vbeln
                  CHANGING fc_fakturno fc_nocoretax fc_subrc.

  DATA: lt_fakturno TYPE STANDARD TABLE OF zgdtxdt0011
                        WITH HEADER LINE,
        ld_reuse,
        ld_masatx   LIKE zgdtxdt0011-masatx.

  DATA ld_vatbr(3).
  DATA ld_vattrn   LIKE zfvattrn-vattrn.
  DATA ld_vatno1(10).

  RANGES: lr_masatx FOR zgdtxdt0011-masatx.

*  DATA lv_nocoretax   TYPE zgdtxdt0011-nocoretax.

  CLEAR: fc_subrc, ld_masatx, lr_masatx.
  REFRESH lr_masatx.

  ld_masatx = fu_masatx - 1.
  lr_masatx-sign   = 'I'.
  lr_masatx-option = 'EQ'.
  lr_masatx-low    = ld_masatx.
  APPEND lr_masatx.
  lr_masatx-low    = fu_masatx.
  APPEND lr_masatx.

**Get from Cancelled number (reusable)
  SELECT * INTO TABLE lt_fakturno
                FROM  zgdtxdt0011
                WHERE
*                      gsber    EQ fu_gsber  AND
                      brnch    EQ fu_brnch  AND
                      masatx   IN lr_masatx AND
                      objrange EQ fu_object.
  IF sy-subrc = 0.
    SORT lt_fakturno BY fakturno masatx.
    CLEAR ld_reuse.
    CLEAR: sy-subrc, fc_subrc.
    LOOP AT lt_fakturno.
      CALL FUNCTION 'ENQUEUE_EZGDTXDT0011'
        EXPORTING
          mode_zgdtxdt0011 = 'E'
          mandt            = sy-mandt
*         gsber            = fu_gsber
          brnch            = fu_brnch
          fakturno         = lt_fakturno-fakturno
          masatx           = lt_fakturno-masatx
          objrange         = lt_fakturno-objrange
        EXCEPTIONS
          foreign_lock     = 1
          system_failure   = 2
          OTHERS           = 3.
      IF sy-subrc = 0.
        CLEAR ld_reuse.
        MOVE-CORRESPONDING lt_fakturno TO t_zgdtxdt0011.
        APPEND t_zgdtxdt0011.
        fc_fakturno  = lt_fakturno-fakturno.
        fc_nocoretax = lt_fakturno-nocoretax.
*        DELETE zgdtxdt0011 FROM t_zgdtxdt0011.
        EXIT.
      ELSE.
        ld_reuse = 'X'.
        CONTINUE.
      ENDIF.

*        IF lt_fakturno-masatx(4) GT 2006.
*          SELECT SINGLE vattrn vatbr
*            FROM zfvattrn
*            INTO (ld_vattrn, ld_vatbr)
*            WHERE vkorg EQ fu_brnch AND
*                  gform EQ fu_form.
*
*          ld_vatno1 = lt_fakturno-fakturno+6(10).
*          CONCATENATE ld_vattrn '0' ld_vatbr ld_vatno1
*          INTO fc_fakturno.
**          DELETE zgdtxdt0011 FROM lt_fakturno.
*        ELSE.
*          fc_fakturno = lt_fakturno-fakturno.
*        ENDIF.
*        CLEAR ld_reuse.
*        MOVE-CORRESPONDING lt_fakturno TO t_zgdtxdt0011.
*        APPEND t_zgdtxdt0011.
*        EXIT.
*      ELSE.
*        ld_reuse = 'X'.
*        CONTINUE.
*      ENDIF.
    ENDLOOP.

****No number can be reused
    IF NOT ld_reuse IS INITIAL.
      PERFORM f_get_next_number USING fu_object
                                      fu_gsber
                                      fu_bukrs
                                      fu_brnch
                                      fu_masatx
                                      fu_form
                                      space
                                      fu_fakdat
                                      fu_vbeln
                             CHANGING fc_fakturno fc_nocoretax fc_subrc.
    ENDIF.
  ELSE.
****No number can be reused
    PERFORM f_get_next_number USING    fu_object
                                       fu_gsber
                                       fu_bukrs
                                       fu_brnch
                                       fu_masatx
                                       fu_form
                                       space
                                       fu_fakdat
                                       fu_vbeln
                              CHANGING fc_fakturno fc_nocoretax fc_subrc.
  ENDIF.

  IF fc_subrc <> 0.
    MESSAGE a000(ztx) WITH 'Please maintain tax number ranges!'.
  ENDIF.

ENDFORM.                    " F_GET_FAKTUR_NO

*&---------------------------------------------------------------------*
*&      Form  F_NUMBERING
*&---------------------------------------------------------------------*
*&    This routine assigns new sequence number to a new faktur pajak.
*&    A new faktur pajak number will only be assigned when the
*&    faktur pajak is saved/printed. If it is only previewed, a dummy
*&    number (counter) will be assigned temporarily to the selected
*&    faktur pajak
*&---------------------------------------------------------------------*
*&    ->FU_ACTION   -  'SAVE' or 'PREVIEW'
*&    ->FU_FAKTURNO -  Faktur no. to be processed
*&    ->FU_GSBER    -  Business area
*&    ->FU_MASATX   -  Tax period. A reusable number can only be reused
*&                     for a new faktur pajak in a same period
*&    <-FC_FAKTURNO -  New faktur no.
*&    <-FC_SUBRC    -  This parameter will be <> 0 if no new number can
*&                     be assigned to the faktur pajak
*&---------------------------------------------------------------------*
FORM f_numbering USING    fu_action
                          fu_fakturno
                          fu_gsber
                          fu_bukrs
                          fu_brnch
                          fu_masatx
                          fu_form
                          fu_fakdat
                          fu_vbeln
                 CHANGING fc_fakturno
                          fc_nocoretax
                          fc_subrc.
  CLEAR fc_subrc.
  IF fu_action = d_prev_first.
    fc_fakturno = fu_fakturno + 1.
  ELSEIF fu_action = d_direct_save.
    PERFORM f_get_faktur_no USING d_objrange
                                  fu_gsber
                                  fu_bukrs
                                  fu_brnch
                                  fu_masatx
                                  fu_form
                                  fu_fakdat
                                  fu_vbeln
                         CHANGING fc_fakturno fc_nocoretax
                                  fc_subrc.
    IF fc_subrc <> 0.
      MESSAGE a000(ztx) WITH 'Please maintain number ranges'.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_NUMBERING

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDRESS_DATA
*&---------------------------------------------------------------------*
*&  This routine retrieves Customer/tax payer address data
*&---------------------------------------------------------------------*
*&  ->FT_VBRK      - Billing data
*&  <-FT_VBPA      - Partner function data
*&  <-FT_KNA1      - Customer data
*&  <-FT_ADRC      - Address data
*&---------------------------------------------------------------------*
FORM f_get_address_data TABLES   ft_vbrk STRUCTURE t_vbrk
                                 ft_vbpa STRUCTURE t_vbpa
                                 ft_kna1 STRUCTURE t_kna1
                                 ft_adrc STRUCTURE t_adrc.

  DATA ld_from LIKE sy-tabix.
  DATA ld_to LIKE sy-tabix.

  RANGES: lr_vbeln FOR vbpa-vbeln,
          lr_kunnr FOR kna1-kunnr,
          lr_adrnr FOR kna1-adrnr.

  DATA lt_vbrk LIKE t_vbrk OCCURS 0 WITH HEADER LINE.
  DATA lt_vbpa LIKE t_vbpa OCCURS 0 WITH HEADER LINE.
  DATA lt_vbpa1 LIKE t_vbpa OCCURS 0 WITH HEADER LINE.

  lt_vbrk[] = ft_vbrk[].
  SORT lt_vbrk BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_vbrk COMPARING vbeln.

**Get Partner function info
  IF NOT lt_vbrk[] IS INITIAL.
    REFRESH ft_vbpa.
    ld_from = 1.
    ld_to = c_max_ritems.
    lr_vbeln-sign = 'I'.
    lr_vbeln-option = 'EQ'.
    DO.
      REFRESH lr_vbeln.
      LOOP AT lt_vbrk FROM ld_from TO ld_to.
        lr_vbeln-low = lt_vbrk-vbeln.
        APPEND lr_vbeln.
      ENDLOOP.
      IF lr_vbeln[] IS INITIAL.
        EXIT.
      ENDIF.
      ld_from = ld_from + c_max_ritems.
      ld_to   = ld_to   + c_max_ritems.

      SELECT vbeln parvw kunnr adrnr
             APPENDING CORRESPONDING FIELDS OF TABLE ft_vbpa
             FROM vbpa
             WHERE vbeln IN lr_vbeln.
    ENDDO.

    SORT ft_vbpa BY vbeln parvw.
    lt_vbpa[] = ft_vbpa[].
    SORT lt_vbpa BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_vbpa COMPARING kunnr.

    IF NOT lt_vbpa[] IS INITIAL.
      CLEAR: ld_from, ld_to.
******Get WAPU
      REFRESH ft_kna1.
      ld_from = 1.
      ld_to = c_max_ritems.
      lr_kunnr-sign = 'I'.
      lr_kunnr-option = 'EQ'.
      DO.
        REFRESH lr_kunnr.
        LOOP AT lt_vbpa FROM ld_from TO ld_to.
          lr_kunnr-low = lt_vbpa-kunnr.
          APPEND lr_kunnr.
        ENDLOOP.
        IF lr_kunnr[] IS INITIAL.
          EXIT.
        ENDIF.
        ld_from = ld_from + c_max_ritems.
        ld_to   = ld_to   + c_max_ritems.

        SELECT kunnr stcd1 stceg xcpdk anred
               APPENDING CORRESPONDING FIELDS OF TABLE ft_kna1
               FROM kna1
               WHERE kunnr IN lr_kunnr.
      ENDDO.

      IF NOT ft_kna1[] IS INITIAL.
        SORT ft_kna1 BY kunnr.
      ENDIF.

******Get Address
      CLEAR: ld_from, ld_to.
      lt_vbpa1[] = ft_vbpa[].
      SORT lt_vbpa1 BY adrnr.
      DELETE ADJACENT DUPLICATES FROM lt_vbpa1 COMPARING adrnr.
      IF NOT lt_vbpa1[] IS INITIAL.
        REFRESH ft_adrc.
        ld_from = 1.
        ld_to = c_max_ritems.
        lr_adrnr-sign = 'I'.
        lr_adrnr-option = 'EQ'.
        DO.
          REFRESH lr_adrnr.
          LOOP AT lt_vbpa1 FROM ld_from TO ld_to.
            lr_adrnr-low = lt_vbpa1-adrnr.
            APPEND lr_adrnr.
          ENDLOOP.
          IF lr_adrnr[] IS INITIAL.
            EXIT.
          ENDIF.
          ld_from = ld_from + c_max_ritems.
          ld_to   = ld_to   + c_max_ritems.

          SELECT addrnumber title name1 name2 name3 name4 str_suppl1 street str_suppl2 str_suppl3
                 location city1 post_code1 city2 name_co
                 APPENDING CORRESPONDING FIELDS OF TABLE ft_adrc
                 FROM adrc
                 WHERE addrnumber IN lr_adrnr.
        ENDDO.

        IF NOT ft_adrc[] IS INITIAL.
          SORT ft_adrc BY addrnumber.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_ADDRESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_ITEM_CATEGORY_RANGE
*&---------------------------------------------------------------------*
*&  This routine retrieves item category selected by the user for
*&  Service billings (Division 03)
*&---------------------------------------------------------------------*
*&  ->FU_VKORG     - Sales organization
*&  ->FC_DES_CC    - Sales organization description
*&---------------------------------------------------------------------*
FORM f_get_item_category_range TABLES ft_pstyv STRUCTURE r_pstyv
                               USING  fu_service
                                      fu_sparts
                                      fu_both
                                      fu_contra.

  ft_pstyv-sign   = 'I'.
  ft_pstyv-option = 'EQ'.

  CASE 'X'.
    WHEN fu_service.
      ft_pstyv-low = c_pstyv_service.
      APPEND ft_pstyv.
    WHEN fu_sparts.
      ft_pstyv-low = c_pstyv_parts.
      APPEND ft_pstyv.
      ft_pstyv-low = c_pstyv_parts1.
      APPEND ft_pstyv.
      ft_pstyv-low = c_pstyv_parts2.
      APPEND ft_pstyv.
      ft_pstyv-low = c_pstyv_parts3.
      APPEND ft_pstyv.
      ft_pstyv-low = c_pstyv_parts4.
      APPEND ft_pstyv.
    WHEN fu_contra.
      ft_pstyv-low = c_pstyv_contr.
      APPEND ft_pstyv.
      ft_pstyv-low = c_pstyv_contr1.
      APPEND ft_pstyv.
    WHEN fu_both.
      ft_pstyv-low = c_pstyv_service.
      APPEND ft_pstyv.
      ft_pstyv-low = c_pstyv_parts.
      APPEND ft_pstyv.
  ENDCASE.

ENDFORM.                    " F_GET_ITEM_CATEGORY_RANGE

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_DESELECT
*&---------------------------------------------------------------------*
*&  This routine selects/deselects records in the main screen
*&---------------------------------------------------------------------*
*&  ->FU_VALUE   - 'X' if the record is selected, otherwise deselected
*&---------------------------------------------------------------------*
FORM f_select_deselect USING  fu_value.

  t_vbrkscr-sel = fu_value.
  MODIFY t_vbrkscr TRANSPORTING sel
                   WHERE sel <> fu_value.

ENDFORM.                    " F_SELECT_DESELECT

*&---------------------------------------------------------------------*
*&      Form  F_INCLUDE_EXCLUDE_TAX
*&---------------------------------------------------------------------*
*&  This routine is for user to determine whether tax is included or
*&  excluded for the selected billings in the main screen
*&---------------------------------------------------------------------*
*&  ->FU_VALUE   - 'X' if the record tax-inclusive, otherwise
*&                 tax-exclusive
*&---------------------------------------------------------------------*
FORM f_include_exclude_tax USING  fu_value.

  t_vbrkscr-tax = fu_value.
  MODIFY t_vbrkscr TRANSPORTING tax
                   WHERE tax <> fu_value
                     AND sel <> space.

ENDFORM.                    " F_SELECT_DESELECT

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDRESS
*&---------------------------------------------------------------------*
*&  This routine collects address data for the selected billings
*&---------------------------------------------------------------------*
*&  ->FU_VBELN   - Billing number
*&  <-FC_NAME    - Customer/tax payer name
*&  <-FC_ADDRS1  - Customer address 1
*&  <-FC_ADDRS2  - Customer address 2
*&  <-FC_CITY    - Customer city
*&  <-FC_POSTAL  - Customer postal code
*&---------------------------------------------------------------------*
FORM f_get_address USING    fu_vbeln
                   CHANGING fc_name
                            fc_addrs1
                            fc_addrs2
                            fc_city
                            fc_postal
                            fc_kunnr
                            fc_stceg.   "added by Rahmadi 30/06/2004

  DATA: lw_vbpa LIKE t_vbpa.
  DATA: ld_vkorg LIKE vbrk-vkorg.
  DATA: lv_post TYPE i.
*** Add by sukardi
*** Proses untuk mengakali mendapatkan sales organisasi, khusus 8220 dan 8180
  IF fc_name(4) = '8220' OR fc_name(4) = '8180' OR
    fc_name(4) = '8210'.
    ld_vkorg = fc_name(4).
  ENDIF.
*** end add by sukardi
****added by Rahmadi
*--Get Customer information to be displayed in Faktur pajak
*--Use Business Partner FAKTUR PAJAK as first priority
  READ TABLE t_vbpa WITH KEY vbeln = fu_vbeln
                             parvw = d_faktur_pajak
                             BINARY SEARCH.
  IF sy-subrc = 0.
    lw_vbpa = t_vbpa.
  ELSE.
****end of modification
*---Use Business partner STNK as second priority
    READ TABLE t_vbpa WITH KEY vbeln = fu_vbeln
                               parvw = d_stnk
                               BINARY SEARCH.
    IF sy-subrc = 0.
      lw_vbpa = t_vbpa.
    ELSE.
*-----Use business partner PAYER as last priority
      READ TABLE t_vbpa WITH KEY vbeln = fu_vbeln
                                 parvw = d_payer
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        lw_vbpa = t_vbpa.
      ELSE.
        CLEAR lw_vbpa.
      ENDIF.
    ENDIF.
  ENDIF.

  fc_kunnr = lw_vbpa-kunnr.

**added by Rahmadi
  READ TABLE t_kna1 WITH KEY kunnr = lw_vbpa-kunnr
                    BINARY SEARCH.
  fc_stceg  = t_kna1-stceg.  "added by Rahmadi 30/06/2004
**end of addition
  READ TABLE t_adrc WITH KEY addrnumber = lw_vbpa-adrnr
                    BINARY SEARCH.
  IF sy-subrc = 0.
    fc_name = t_adrc-name1.

    IF d_hnr_brnch = '8210'.
      READ TABLE t_vbpa WITH KEY vbeln = fu_vbeln
                                 parvw = d_ship_to_party
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE t_kna1 WITH KEY kunnr = t_vbpa-kunnr
                                   BINARY SEARCH.
        IF sy-subrc = 0.
          IF t_kna1-stceg IS NOT INITIAL.
            lw_vbpa = t_vbpa.
            READ TABLE t_kna1 WITH KEY kunnr = lw_vbpa-kunnr
                                       BINARY SEARCH.
            READ TABLE t_adrc WITH KEY addrnumber = lw_vbpa-adrnr
                                       BINARY SEARCH.
            fc_kunnr = lw_vbpa-kunnr.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF d_hnr_brnch = '8010' OR
      d_hnr_brnch = '8040'.
      SORT t_vbpa BY vbeln parvw.
      READ TABLE t_vbpa WITH KEY vbeln = fu_vbeln
                                 parvw = d_payer
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        SORT t_kna1 BY kunnr.
        READ TABLE t_kna1 WITH KEY kunnr = t_vbpa-kunnr
                                   BINARY SEARCH.
        IF sy-subrc = 0.
          lw_vbpa = t_vbpa.
          SORT t_kna1 BY kunnr.
          READ TABLE t_kna1 WITH KEY kunnr = lw_vbpa-kunnr
                                     BINARY SEARCH.
          SORT t_adrc BY addrnumber.
          READ TABLE t_adrc WITH KEY addrnumber = lw_vbpa-adrnr
                                     BINARY SEARCH.
          fc_kunnr = lw_vbpa-kunnr.
        ENDIF.
      ENDIF.
    ENDIF.

*    IF d_hnr_brnch = '8220'." OR d_hnr_brnch = '8800'.
*      READ TABLE t_vbpa WITH KEY vbeln = fu_vbeln
*                                 parvw = d_ship_to_party
*                                 BINARY SEARCH.
*      IF sy-subrc = 0.
*        READ TABLE t_kna1 WITH KEY kunnr = t_vbpa-kunnr
*                                   BINARY SEARCH.
*        IF sy-subrc = 0.
*          lw_vbpa = t_vbpa.
*          READ TABLE t_kna1 WITH KEY kunnr = lw_vbpa-kunnr
*                                     BINARY SEARCH.
*          READ TABLE t_adrc WITH KEY addrnumber = lw_vbpa-adrnr
*                                     BINARY SEARCH.
*          fc_kunnr = lw_vbpa-kunnr.
*        ENDIF.
*      ENDIF.
*    ENDIF.

*** add by sukard
*    IF ( ld_vkorg = '8220' OR ld_vkorg = '8180' ) AND
*      ( lw_vbpa-kunnr(3) NE 'TSB' AND lw_vbpa-kunnr(3) NE 'NSB' ).
*      fc_addrs1 = t_adrc-street.
*      CONCATENATE  t_adrc-str_suppl1 t_adrc-str_suppl2 INTO fc_addrs2
*      SEPARATED BY space.
*      fc_city = t_adrc-city1.
*    ELSE.
*** end add sukardi

* Revisi by Budi 31/08/2015 req. by SJT
    DATA lt_vbrk1 LIKE t_vbrk1.
    CLEAR lt_vbrk1.
    READ TABLE t_vbrk1 INTO lt_vbrk1 WITH KEY vbeln = fu_vbeln.
    IF lt_vbrk1-vkorg = '8010' OR lt_vbrk1-vkorg = '8030' OR lt_vbrk1-vkorg = '8050' OR
       lt_vbrk1-vkorg = '8090' OR lt_vbrk1-vkorg = '8160' OR lt_vbrk1-vkorg = '8230' OR
       lt_vbrk1-vkorg = '8360' OR lt_vbrk1-vkorg = '8800' OR lt_vbrk1-vkorg = '8040'.

      fc_name = t_adrc-name_co.
      fc_addrs1 = t_adrc-str_suppl1.
      CONCATENATE t_adrc-str_suppl2 t_adrc-str_suppl3 INTO fc_addrs2
        SEPARATED BY space.
      fc_city = t_adrc-location.

*      IF lt_vbrk1-vkorg = '8800' AND ( lw_vbpa-kunnr(5) = 'TBA02' OR lw_vbpa-kunnr(5) = 'TBA05' ).
*        fc_name = 'PT.TEMPO'.
*      ENDIF.
*      IF lt_vbrk1-vkorg = '8800' AND  lw_vbpa-kunnr = 'TBA0246'.
*        fc_addrs1 = 'GEDUNG TEMPO SCAN TOWER LT.16,'.
*        fc_addrs2 = 'JL. HR RASUNA SAID KAV 3-4 SETIABUDI JAKARTA SELATAN DKI JAKARTA RAYA 12950'.
*        CLEAR fc_city.
*      ENDIF.
*      IF lt_vbrk1-vkorg = '8800' AND  lw_vbpa-kunnr = 'TBA0501'.
*        fc_addrs1 = 'JL.RAYA BEKASI KM 28,KEC.MEDAN SATRIA'.
*        fc_addrs2 = ',MEDAN SATRIA,KOTA BEKASI,JAWA BARAT'.
*        CLEAR fc_city.
*      ENDIF.
*      IF lt_vbrk1-vkorg = '8800' AND  lw_vbpa-kunnr = 'TBA2211'.
*        fc_addrs1 = 'RAYA KALIGAWE KM.3 NO.46 TERBOYO '.
*        fc_addrs2 = 'KULON GENUK KOTA SEMARANG JAWA TENGAH'.
*        CLEAR fc_city.
*      ENDIF.
*      IF lt_vbrk1-vkorg = '8800' AND  lw_vbpa-kunnr = 'TBA2212'.
*        fc_addrs1 = 'JL.RADEN RONGGO KM 1,2 DHURI TIRTOMARTHANI '.
*        fc_addrs2 = 'KALASAN,SLEMAN,YOGYAKARTA 55571'.
*        CLEAR fc_city.
*      ENDIF.
*      IF lt_vbrk1-vkorg = '8800' AND  lw_vbpa-kunnr = 'TSB3600B'.
*        fc_addrs1 = 'NGORO INDUSTRIAL PARK PLOT D3-A KUTOGIRANG,'.
*        fc_addrs2 = 'NGORO,KAB.MOJOKERTO,JAWA TIMUR,61385'.
*        CLEAR fc_city.
*      ENDIF.

*      IF lt_vbrk1-vkorg = '8050' AND  lt_vbrk1-kunrg = 'TSB8020'.
*        IF lt_vbrk1-prctr = '0000051101' OR lt_vbrk1-prctr = '0000051102'.
*          fc_addrs1 = 'JL.MT HARYONO NO 7 CAWANG-'.
*          fc_addrs2 = 'KRAMAT JATI JAKARTA TIMUR - DKI JAKARTA'.
*          CLEAR fc_city.
*        ENDIF.
*        IF lt_vbrk1-prctr = '0000051050' OR lt_vbrk1-prctr = '0000051001'.
*          fc_addrs1 = 'JL.RAYA BEKASI KM 28,KEC.MEDAN SATRIA'.
*          fc_addrs2 = ',MEDAN SATRIA,KOTA BEKASI,JAWA BARAT'.
*          CLEAR fc_city.
*        ENDIF.
*        IF lt_vbrk1-prctr = '0000051080'.
*          fc_addrs1 = 'JL.SOEKARNO HATTA KM 8,5 KEDAMAIAN'.
*          fc_addrs2 = ',TANJUNG KARANG TIMUR, BANDAR LAMPUNG 35122'.
*          CLEAR fc_city.
*        ENDIF.
*      ENDIF.
*      IF lt_vbrk1-vkorg = '8050' AND  lt_vbrk1-kunrg = 'TSB8360'.
*        IF lt_vbrk1-prctr = '0000051080'.
*          fc_addrs1 = 'JL.RUNGKUT INDUSTRI III NO.11'.
*          fc_addrs2 = 'KUTISARI,TENGGILIS,MEJOYO,KOTA SURABAYA,JAWA TIMUR'.
*          CLEAR fc_city.
*        ENDIF.
*      ENDIF.
      IF lt_vbrk1-vkorg = '8800' AND lt_vbrk1-kunrg = 'TSB8010'.
        fc_addrs1 = 'GEDUNG TEMPO SCAN TOWER KAV 3-4 LT.16'.
        fc_addrs2 = 'JL.HR RASUNA SAID KUNINGAN TIMUR SETIABUDI JAKARTA SELATAN'.
        fc_city = 'DKI JAKARTA 12950'.
      ENDIF.
      IF lt_vbrk1-vkorg = '8800' AND lt_vbrk1-kunrg = 'TSB8360'.
        fc_addrs1 = 'GEDUNG TEMPO SCAN TOWER LT.16, JL.HR RASUNA SAID KAV. 3-4,'.
        fc_addrs2 = 'KUNINGAN TIMUR, SETIABUDI, JAKARTA SELATAN,'.
        fc_city = 'DKI JAKARTA 12950'.
      ENDIF.
* End revisi by Budi 31/08/2015 req. by SJT
    ELSEIF ( lt_vbrk1-vkorg = '8220' OR lt_vbrk1-vkorg = '8180' OR
      lt_vbrk1-vkorg = '8210' ) AND
    ( lw_vbpa-kunnr(3) NE 'TSB' AND lw_vbpa-kunnr(3) NE 'NSB' ).

      IF lt_vbrk1-vkorg = '8210'.
        SELECT SINGLE *
          FROM zscust_control
          WHERE vkorg       = lt_vbrk1-vkorg
            AND cek         = 'TDN'
            AND field_name  = 'KUNNR'
            AND field_value = lw_vbpa-kunnr.
        IF sy-subrc = 0.
          fc_addrs1 = t_adrc-str_suppl1.
          CONCATENATE t_adrc-str_suppl2 t_adrc-str_suppl3 INTO fc_addrs2
            SEPARATED BY space.
        ELSE.
          fc_addrs1 = t_adrc-str_suppl3.
          CONCATENATE  t_adrc-str_suppl1 t_adrc-str_suppl2 INTO fc_addrs2
          SEPARATED BY space.
          fc_city = t_adrc-city1.
        ENDIF.
*      ELSEIF lt_vbrk1-vkorg = '8220'.
*        fc_addrs1 = t_adrc-name2.
*        CONCATENATE t_adrc-name3 t_adrc-name4 INTO fc_addrs2 SEPARATED BY space.
*        CLEAR fc_city.
      ELSE.
        fc_addrs1 = t_adrc-street.
        CONCATENATE  t_adrc-str_suppl1 t_adrc-str_suppl2 INTO fc_addrs2
        SEPARATED BY space.
        fc_city = t_adrc-city1.

        IF lt_vbrk1-vkorg = '8220' AND ( lw_vbpa-kunnr EQ '0400266287' OR lw_vbpa-kunnr EQ '0400289318' ).
          fc_city = t_adrc-str_suppl3.
        ENDIF.

      ENDIF.
    ELSE.
      IF lt_vbrk1-vkorg = '8380'.
        fc_name = t_adrc-name_co.
      ENDIF.

      IF NOT t_adrc-str_suppl1 IS INITIAL.
        fc_addrs1 = t_adrc-str_suppl1.
      ELSE.
        fc_addrs1 = t_adrc-street.
      ENDIF.
      IF NOT t_adrc-str_suppl2 IS INITIAL.
        fc_addrs2 = t_adrc-str_suppl2.
      ELSE.
        fc_addrs2 = t_adrc-location.
      ENDIF.
*      fc_city = t_adrc-city1.
      fc_city = t_adrc-str_suppl3.
    ENDIF.
*    ENDIF.

*    fc_city = t_adrc-city1.                    "Pindah ke atas
*    IF lt_vbrk1-vkorg = '8220'.
*      CLEAR fc_postal.
*    ELSE.
    fc_postal = t_adrc-post_code1.
*    ENDIF.
    IF lt_vbrk1-vkorg = '8220' AND ( lw_vbpa-kunnr(3) EQ 'TSB' OR lw_vbpa-kunnr(3) EQ 'NSB' ).
      CLEAR fc_postal.
    ENDIF.

**** Tambahan Suk untuk menghilang kodepos jika kodepos = 000000
    CONDENSE fc_postal.
    lv_post = 1.
    IF NOT fc_postal CO ' 1234567890'.
    ELSE.
      lv_post = fc_postal.
    ENDIF.
    IF lv_post = 0.
      CLEAR: fc_postal.
    ENDIF.
********
  ELSE.
    CLEAR: fc_name, fc_addrs1, fc_addrs2, fc_city, fc_postal, fc_kunnr.
  ENDIF.

ENDFORM.                    " F_GET_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  F_GET_WAPU
*&---------------------------------------------------------------------*
*&  This routine collects WAPU data for the selected billings
*&---------------------------------------------------------------------*
*&  ->FU_KUNRG   - Customer number
*&  <-FC_WAPU    - WAPU
*&  <-FC_FORM    - Used Tax form
*&---------------------------------------------------------------------*
FORM f_get_wapu USING    fu_kunrg
                CHANGING fc_wapu
                         fc_form.

  READ TABLE t_kna1 WITH KEY kunnr = fu_kunrg
                    BINARY SEARCH.
  IF sy-subrc = 0.
    IF t_kna1-stcd1+0(1) = d_w.
      fc_wapu = d_w.
      fc_form = d_a3.
    ELSE.
      fc_wapu = d_n.
      fc_form = d_a1.
    ENDIF.
  ELSE.
    CLEAR fc_wapu.
  ENDIF.

ENDFORM.                    " F_GET_WAPU

*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT
*&---------------------------------------------------------------------*
*&  This routine retrieves description data
*&---------------------------------------------------------------------*
*&  ->FU_VKORG   - Sales organization
*&  ->FU_GSBER   - Business Area
*&  ->FU_SPART   - Division
*&  <-FC_VTEXT   - Sales org description
*&  <-FC_GTEXT   - Bus are description
*&  <-FC_STEXT   - Division description
*&---------------------------------------------------------------------*
FORM f_get_text USING
                         fu_vkorg
                         fu_gsber
                         fu_spart
                         fu_brnch
                         fu_busln
                         fu_bukrs
                CHANGING
                         fc_vtext
                         fc_gtext
                         fc_stext
                         fc_brtxt
                         fc_bltxt
                         fc_cctxt.

  PERFORM f_get_vkorg_text USING    fu_vkorg
                           CHANGING fc_vtext.
  PERFORM f_get_gsber_text USING    fu_gsber
                           CHANGING fc_gtext.
  PERFORM f_get_spart_text USING    fu_spart
                           CHANGING fc_stext.
* Added by Rama
* get the description for branch, business line and bukrs
*  READ TABLE t_tx00101 WITH KEY brnch = fu_brnch.
*  fc_brtxt = t_tx00101-bdesc.
  fc_brtxt = d_bdesc.

*  READ TABLE t_tx00102 WITH KEY busln = fu_busln.
*  fc_bltxt = t_tx00102-busds.
  fc_bltxt = d_busds.

  PERFORM f_get_bukrs_text USING    fu_bukrs
                           CHANGING fc_cctxt.

* End of addition

ENDFORM.                    " F_GET_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_ERROR_BILLING
*&---------------------------------------------------------------------*
*&  This routine releases all unused/filtered-out billings
*&---------------------------------------------------------------------*
*&  ->FU_VBELN   - Billing number
*&---------------------------------------------------------------------*
FORM f_unlock_error_billing USING fu_vbeln.

  CALL FUNCTION 'DEQUEUE_EVVBRKE'
    EXPORTING
      mode_vbrk = 'E'
      mandt     = sy-mandt
      vbeln     = fu_vbeln.

ENDFORM.                    " F_UNLOCK_ERROR_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_SELECTED_DATA
*&---------------------------------------------------------------------*
*&  This routine collects all selected billings to be processed.
*&  If no record is selected, warning message will be raised
*&---------------------------------------------------------------------*
*&  <-FC_SUBRC    - <> 0 if no record is selected
*&---------------------------------------------------------------------*
FORM f_selected_data CHANGING fc_subrc.
  READ TABLE t_vbrkscr WITH KEY sel = 'X'.
  fc_subrc = sy-subrc.
  IF fc_subrc = 0.
    t_vbrkscr1[] = t_vbrkscr[].
    DELETE t_vbrkscr1 WHERE sel NE 'X'.
  ELSE.
    MESSAGE s000(ztx) WITH 'Please select record(s)'.
  ENDIF.
ENDFORM.                    " F_SELECTED_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CALL_FUNCTION
*&---------------------------------------------------------------------*
*&  This routine calls printing function to print/preview tax form/
*&  faktur pajak
*&---------------------------------------------------------------------*
*&  ->FU_REPORT    - Preview only
*&  ->FU_DISPLAY   - Display output when printing
*&  ->FU_CHECKING  - Error checking
*&---------------------------------------------------------------------*
FORM f_call_function USING fu_report
                           fu_display
                           fu_checking
                           fu_mpage
                           fu_printer
                           fu_bukrs
                           fu_cust     "added for Tempo
                  CHANGING fc_subrc.

***added for Tempo -- to cater Custom form
  IF fu_cust = 'X'.     "Custom form
    CALL FUNCTION 'Z_GDTXFC_PRINT_SMARTFORMS'
      EXPORTING
        fi_display               = fu_display
        fi_report                = ''
        fi_checking_only         = fu_checking
*       FI_NONLIVES              =
*       FI_FOREX                 =
        fi_mpage                 = fu_mpage
        fi_printer               = fu_printer
        fi_bukrs                 = fu_bukrs
      TABLES
        ft_pkp                   = t_fpkp
        ft_customer              = t_fcustomer
        ft_item                  = t_fitem
        ft_signature             = t_fsignature
        ft_tax                   = t_ftax
*       FT_ERROR_RESULT          =
      EXCEPTIONS
        data_too_long            = 1
        ppnbm_too_long           = 2
        date_word_not_maintained = 3
        OTHERS                   = 4.
    fc_subrc = sy-subrc.

  ELSE.                 "Standard form
    CALL FUNCTION 'Z_GDTXFC_PRINT_FORMS'
      EXPORTING
        fi_display       = fu_display
        fi_report        = fu_report
        fi_checking_only = fu_checking
        fi_mpage         = fu_mpage
        fi_printer       = fu_printer
        fi_bukrs         = fu_bukrs
      TABLES
        ft_pkp           = t_fpkp
        ft_customer      = t_fcustomer
        ft_item          = t_fitem
        ft_signature     = t_fsignature
        ft_tax           = t_ftax
      EXCEPTIONS
        data_too_long    = 1
        ppnbm_too_long   = 2
        OTHERS           = 3.

    fc_subrc = sy-subrc.
  ENDIF.
ENDFORM.                    " F_CALL_FUNCTION

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLES
*&---------------------------------------------------------------------*
*&    This routine will save processed Faktur pajak & billings into
*&    custom table ZGDTXDt0002 & ZGDTXDt0003.
*&    If there are any reusable number used for the processed Faktur
*&    pajak, they will have to be deleted from ZGDTXDt0011 table.
*&    If it is executed by RPC program, it will also insert a cancelled
*&    Faktur pajak number to ZGDTXDt0011 table to make the number
*&    reusable.
*&    This routine can ONLY be performed in a DATABASE COMMIT process
*&    therefore there are no passing parameters allowed to be assigned
*&    to it.
*&---------------------------------------------------------------------*
FORM f_save_to_tables.

  DATA lw_zgdtxdt0003         LIKE zgdtxdt0003.
  DATA lw_zgdtxdt0002         LIKE zgdtxdt0002.
  DATA lt_rpc02               LIKE t_process OCCURS 1 WITH HEADER LINE.
  DATA ld_fakturno            LIKE zgdtxdt0003-fakturno.
  DATA ld_tabix               LIKE sy-tabix.
  DATA ld_tabix_zgdtxdt0003   LIKE sy-tabix.
  DATA ld_subrc               LIKE sy-subrc.
  DATA lw_process             LIKE t_process.
  DATA lw_process0            LIKE t_process.
  DATA lt_sdh_to_std          LIKE t_zgdtxdt0002 OCCURS 1 WITH HEADER LINE.

***Get Header Variable
***added by Rahmadi
*--To determine whether which PKP info will be used (Branch or HO)
  IF d_pkpfl IS INITIAL.
    mac_from_variabel d_ d_b d_bnr_.
  ELSE.
    mac_from_variabel d_ d_h d_hnr_.
  ENDIF.
***end of addition

*-Logic to accomodate Sederhana to Standard conversion process
* Billings to be converted must be deleted from ZPYTXDt0002 table
* before converted to Standard faktur pajak
  IF d_tcode = c_tcode_sdh_to_standard.
    lt_sdh_to_std[] = t_zgdtxdt0002[].
    CLEAR lt_sdh_to_std-fakturno.
    MODIFY lt_sdh_to_std TRANSPORTING fakturno
                         WHERE NOT fakturno IS INITIAL.
    DELETE zgdtxdt0002 FROM TABLE lt_sdh_to_std.
    IF sy-subrc <> 0.
      MESSAGE a513(ztx) WITH 'ZGDTXDT0002'.
    ENDIF.
  ENDIF.

  CASE d_tcode.
    WHEN c_tcode_sederhana OR
         c_tcode_sederhana_single.    "CR009 16/04/2002
******added by Rahmadi
      t_zgdtxdt0002-udate = sy-datum.
      t_zgdtxdt0002-utime = sy-uzeit.
      MODIFY t_zgdtxdt0002 TRANSPORTING udate utime
                           WHERE udate = ''.
******end of addition
      MODIFY zgdtxdt0002 FROM TABLE t_zgdtxdt0002.
      IF sy-subrc <> 0.
        MESSAGE a510(ztx) WITH 'ZGDTXDT0002'.
      ENDIF.

    WHEN OTHERS.
      SORT t_zgdtxdt0003 BY fakturno.
      SORT t_zgdtxdt0002 BY fakturno vbeln.

      IF NOT d_rpc IS INITIAL.
        SORT t_process BY vbeln posnr fakturno.
        lt_rpc02[] = t_process[].
        DELETE t_process WHERE fakturno = c_spltamount_fakturno_vbrk.
      ENDIF.
      ld_tabix = 1.
      DATA ld_tabix_t_zgdtxdt0003 LIKE sy-tabix.
      LOOP AT t_zgdtxdt0003 INTO lw_zgdtxdt0003.
        ld_tabix_t_zgdtxdt0003 = sy-tabix.
        ld_fakturno = lw_zgdtxdt0003-fakturno.
        lw_zgdtxdt0003-udate = sy-datum.
        lw_zgdtxdt0003-utime = sy-uzeit.
        CLEAR t_zgdtxdt0011.

********Get faktur number
****removed by Rahmadi
*---Not Relevant & not Generic
**-------for determine wapu or not
*        IF d_recnonlive NE 'N'.
*          CASE lw_ZGDTXdt0003-spart. "Live brances only
*            WHEN d_service.
*              READ TABLE t_ZGDTXdt0002
*                   WITH KEY fakturno = lw_ZGDTXdt0003-fakturno.
*              IF sy-subrc = 0.
*                IF t_ZGDTXdt0002-pstyv EQ c_pstyv_service.
*                  IF t_ZGDTXdt0002-wapu EQ d_w.
*                    mac_from_variabel d_ d_h d_hnr_.
*                  ELSE.
*                    IF t_pkp-vspo+1(1) = '1'.
*                      mac_from_variabel d_ d_b d_bnr_.
*                    ELSE.
*                      mac_from_variabel d_ d_h d_hnr_.
*                    ENDIF.
*                  ENDIF.
*                ELSE.
*                  IF t_pkp-vspo+2(1) = '1'.
*                    mac_from_variabel d_ d_b d_bnr_.
*                  ELSE.
*                    mac_from_variabel d_ d_h d_hnr_.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            WHEN d_fin_unit OR d_used OR d_truck.
*              IF t_pkp-vspo+0(1) = '1'.
*                mac_from_variabel d_ d_b d_bnr_.
*              ELSE.
*                mac_from_variabel d_ d_h d_hnr_.
*              ENDIF.
*            WHEN d_sparts.
*              IF t_pkp-vspo+2(1) = '1'.
*                mac_from_variabel d_ d_b d_bnr_.
*              ELSE.
*                mac_from_variabel d_ d_h d_hnr_.
*              ENDIF.
*          ENDCASE.
*        ENDIF.
****end of removal
*-------------------------------------*

        IF d_rpc IS INITIAL.
          PERFORM f_numbering USING d_direct_save
                                    ld_fakturno
*                                    d_nr_gsber
                                    lw_zgdtxdt0003-gsber
                                    lw_zgdtxdt0003-bukrs
                                    d_nr_brnch
                                    lw_zgdtxdt0003-masatx
                                    t_zgdtxdt0002-form
                                    lw_zgdtxdt0003-fakdat
                                    lw_zgdtxdt0003-vbeln
                              CHANGING lw_zgdtxdt0003-fakturno
                                       lw_zgdtxdt0003-nocoretax
                                       ld_subrc.
*---------Determine Printing sequence (only for SAVE & PRINT process)
          IF NOT d_printx IS INITIAL.
            lw_zgdtxdt0003-cetakke = 1.
          ELSE.
            lw_zgdtxdt0003-cetakke = 0.
          ENDIF.
        ELSE.   "RPC
          READ TABLE t_zgdtxdt0002 WITH KEY fakturno = ld_fakturno
                                     BINARY SEARCH.
          PERFORM f_get_rpc_faktur_no USING t_zgdtxdt0002-vbeln
                                            t_zgdtxdt0002-posnr
                                            t_zgdtxdt0002-spart
****added by Rahmadi
*--Store Selected Invoice Consolidation option for faktur pajak
                                            d_flag
****end of addition
                                            lw_zgdtxdt0003-faktur_type
                                            'X'
                                      CHANGING lw_zgdtxdt0003-fakturno
                                               ld_subrc.
          IF ld_subrc <> 0.
            PERFORM f_numbering USING d_direct_save
                                      ld_fakturno
*                                      d_nr_gsber
                                      lw_zgdtxdt0003-gsber
                                      lw_zgdtxdt0003-bukrs
                                      d_nr_brnch
                                      lw_zgdtxdt0003-masatx
                                      space
                                      lw_zgdtxdt0003-fakdat
                                      lw_zgdtxdt0003-vbeln
                                CHANGING lw_zgdtxdt0003-fakturno
                                         lw_zgdtxdt0003-nocoretax
                                         ld_subrc.

*-----------Determine Printing sequence (only for SAVE & PRINT process)
            READ TABLE t_faktur
                  WITH KEY fakturno = lw_zgdtxdt0003-fakturno
                  BINARY SEARCH.
            IF sy-subrc = 0.
              IF NOT d_printx IS INITIAL.
                lw_zgdtxdt0003-cetakke = t_faktur-cetakke + 1.
              ELSE.
                lw_zgdtxdt0003-cetakke = t_faktur-cetakke.
              ENDIF.
            ELSE.
              IF NOT d_printx IS INITIAL.
                lw_zgdtxdt0003-cetakke = 1.
              ELSE.
                lw_zgdtxdt0003-cetakke = 0.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

********Save to ZGDTXDt0003
        IF NOT d_rpc IS INITIAL.  "RPC only
          READ TABLE t_faktur
                WITH KEY fakturno = lw_zgdtxdt0003-fakturno
                BINARY SEARCH.
          IF sy-subrc = 0.
            DELETE FROM zgdtxdt0003
                   WHERE fakturno = lw_zgdtxdt0003-fakturno.
            IF sy-subrc <> 0.
              MESSAGE a513(ztx) WITH 'ZGDTXDT0003'.
            ENDIF.
          ENDIF.
        ENDIF.
*-------Insert only if PPN <> 0 (not cancelled/fully returned)
        IF lw_zgdtxdt0003-fakppn <> 0.
          PERFORM f_dpp_change TABLES t_zgdtxdt0002
                               USING lw_zgdtxdt0003 ''.

          INSERT INTO zgdtxdt0003 VALUES lw_zgdtxdt0003.
          IF sy-subrc <> 0.
            MESSAGE a510(ztx) WITH 'ZGDTXDT0003'.

            "KMM3 Project
          ELSE.
            IF lw_zgdtxdt0003-bukrs = '8360'.
              CALL FUNCTION 'ZKMMFI_UPDATE_XREF2'
                EXPORTING
                  pi_bukrs = lw_zgdtxdt0003-bukrs
                  pi_belnr = lw_zgdtxdt0003-vbeln
                  pi_gjahr = lw_zgdtxdt0003-masatx(4)
                  pi_hkont = '0315300210'
                  pi_xref2 = 'PPN_OUT'.
            ENDIF.
          ENDIF.
        ENDIF.

        IF sy-subrc = 0.
**********Prepare data to be saved to ZGDTXDt0002
*---------RPC (for cancelled/fully returned faktur pajak)
          IF NOT d_rpc IS INITIAL.
            IF lw_zgdtxdt0003-fakppn = 0.
*-------------If cancelled => assign faktur pajak no. as reusable number
*             (to be saved in ZGDTXDt0011 table)
              t_process-fakturno = lw_zgdtxdt0003-fakturno.
              t_process-masatx = lw_zgdtxdt0003-masatx.
              t_process-delete = 'X'.
              APPEND t_process.

              CONCATENATE c_cancel_prefix
                          lw_zgdtxdt0003-fakturno+5(12)
                          INTO lw_zgdtxdt0003-fakturno.
            ENDIF.
          ENDIF.
          t_zgdtxdt0002-udate = lw_zgdtxdt0003-udate.
          t_zgdtxdt0002-utime = lw_zgdtxdt0003-utime.
          t_zgdtxdt0002-fakturno = lw_zgdtxdt0003-fakturno.
          MODIFY t_zgdtxdt0002 TRANSPORTING fakturno udate utime
                 WHERE fakturno = ld_fakturno.
          t_zgdtxdt0003-fakturno = lw_zgdtxdt0003-fakturno.
          MODIFY t_zgdtxdt0003 INDEX ld_tabix_t_zgdtxdt0003
                 TRANSPORTING fakturno.

**********Delete used number from ZGDTXDt0011
          READ TABLE t_zgdtxdt0011
               WITH KEY fakturno = lw_zgdtxdt0003-fakturno
*                        gsber    = d_nr_gsber.
                        brnch    = d_nr_brnch.
          IF sy-subrc = 0.
            CALL FUNCTION 'DEQUEUE_EZGDTXDT0011'
              EXPORTING
                mode_zgdtxdt0011 = 'E'
                mandt            = sy-mandt
***modified by Rahmadi
*               gsber            = d_nr_gsber
                brnch            = d_nr_brnch
***end of modification
                fakturno         = lw_zgdtxdt0003-fakturno
                masatx           = t_zgdtxdt0011-masatx
                objrange         = t_zgdtxdt0011-objrange.

            DELETE zgdtxdt0011 FROM t_zgdtxdt0011.
            IF sy-subrc <> 0.
              MESSAGE a513(ztx) WITH 'ZGDTXDT0011'.
            ENDIF.
          ENDIF.
        ENDIF.

        PERFORM f_dpp_change TABLES t_zgdtxdt0002
                             USING lw_zgdtxdt0003 ld_fakturno.
      ENDLOOP.

******Save to ZGDTXDt0002
      IF NOT d_rpc IS INITIAL.  "RPC only
        CLEAR t_zgdtxdt0003.
        SORT lt_rpc02 BY fakturno.
        DELETE ADJACENT DUPLICATES FROM lt_rpc02 COMPARING fakturno.
        LOOP AT lt_rpc02.
          DELETE FROM zgdtxdt0002
                 WHERE fakturno = lt_rpc02-fakturno.
          IF sy-subrc <> 0.
            MESSAGE a513(ztx) WITH 'ZGDTXDT0002'.
          ENDIF.
        ENDLOOP.
      ENDIF.

      INSERT zgdtxdt0002 FROM TABLE t_zgdtxdt0002.
      IF sy-subrc <> 0.
        MESSAGE a510(ztx) WITH 'ZGDTXDT0002'.
      ENDIF.

******RPC: Insert unused/cancelled Faktur no. to ZGDTXDt0011
      IF NOT d_rpc IS INITIAL AND
         NOT t_process[] IS INITIAL.
        SORT t_process BY fakturno.
        CLEAR: lw_process, lw_process0.
        LOOP AT t_process.
          MOVE-CORRESPONDING t_process TO lw_process.
          IF lw_process0-fakturno <> lw_process-fakturno.
*            ZGDTXdt0011-gsber    = d_nr_gsber.
            zgdtxdt0011-brnch    = d_nr_brnch.
            zgdtxdt0011-fakturno = lw_process-fakturno.
            zgdtxdt0011-masatx   = lw_process-masatx.
            zgdtxdt0011-objrange = d_objrange.
            zgdtxdt0011-uname = sy-uname.
            zgdtxdt0011-udate = sy-datum.
            zgdtxdt0011-utime = sy-uzeit.
            MODIFY zgdtxdt0011.
            IF sy-subrc <> 0.
              MESSAGE a510(ztx) WITH 'ZGDTXDT0011'.
            ENDIF.
************Delete record from Master table that not used anymore
            IF t_process-delete IS INITIAL.
              DELETE FROM zgdtxdt0003
                     WHERE fakturno = lw_process-fakturno.
              IF sy-subrc <> 0.
                MESSAGE a513(ztx) WITH 'ZGDTXDT0003'.
              ENDIF.
            ENDIF.
            lw_process0 = lw_process.
          ENDIF.
          lw_process0 = lw_process.
        ENDLOOP.
      ENDIF.

  ENDCASE.

ENDFORM.                    " F_SAVE_TO_TABLES

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SATUAN_FORM
*&---------------------------------------------------------------------*
*&  This routine prepares all selected billing to process their tax
*&  form/faktur pajak, particularly for ONE TO ONE (SATUAN) process.
*&  It will process data in ZGDTXDt0002 & ZGDTXDt0003 formats to
*&  build mandatory internal tables for printing function.
*&---------------------------------------------------------------------*
*&  ->FT_TX00002   - Faktur pajak item data (billing)
*&  ->FT_TX00003   - Faktur pajak header data
*&  ->FU_FLAG      - Determines how the items should be combined
*&                   '1' for Invoice based, '2' for material based
*&                   '3' for Mat'l & Invoice based
*&                   '4' for Custom
*&---------------------------------------------------------------------*
FORM f_prepare_satuan_form TABLES ft_tx00002 STRUCTURE zgdtxdt0002
                                  ft_tx00003 STRUCTURE zgdtxdt0003
                            USING fu_flag
                                  fu_cust.   "added f/ Tempo - cust Form

  DATA lt_tarif      LIKE zgdtxdt0002 OCCURS 1 WITH HEADER LINE.
  DATA lt_norm       LIKE zgdtxdt0002 OCCURS 1 WITH HEADER LINE.
  DATA lw_norm       LIKE lt_norm.
  DATA lw_norm1      LIKE lt_norm.
  DATA ld_itamtlast  LIKE lw_norm-itamtlast.
  DATA ld_itdisclast LIKE lw_norm-itdisclast.
  DATA ld_dpplast    LIKE lw_norm-dpplast.
  DATA ld_xppnbmlast LIKE lw_norm-xppnbmlast.
  DATA ld_ppnlast    LIKE lw_norm-ppnlast.
  DATA ld_itqtylast  LIKE lw_norm-itqtylast.

  DATA ld_ppn2last   LIKE lw_norm-ppn2last.
  DATA ld_dpp_f      LIKE lw_norm-dpp_f.
  DATA ld_ppn_f      LIKE lw_norm-ppn_f.
  DATA ld_itamt_f    LIKE lw_norm-itamt_f.
  DATA ld_itdisc_f   LIKE lw_norm-itdisc_f.
  DATA ld_xppnbm_f   LIKE lw_norm-xppnbm_f.
  DATA ld_trcurr     LIKE lw_norm-trcurr.
  DATA ld_taxrate    LIKE lw_norm-rate_tax.
  DATA ld_prcpiece   LIKE t_vbrk-itamtlast.
  DATA ld_piechar(15).
  DATA ld_pos TYPE i.
  DATA ld_pos1 TYPE i.
  DATA ld_pos2 TYPE i.

  DATA ld_qtychar(5).
  DATA ld_linenum(3) TYPE n.
  DATA ld_item       LIKE t_fitem-item.
  DATA ld_item1      LIKE t_fitem-item.
  DATA ld_item2      LIKE t_fitem-item.
  DATA ld_item3      LIKE t_fitem-item.
  DATA ld_spaces(60).
  DATA ld_mwskz      TYPE bset-mwskz.

  FIELD-SYMBOLS <fs_ftax> LIKE t_ftax.

  CLEAR: t_fpkp, t_fpkp[], t_fcustomer, t_fcustomer[],
         t_fitem, t_fitem[], t_fsignature, t_fsignature[],
         t_ftax, t_ftax[].


  SORT ft_tx00003 BY fakturno.
  SORT ft_tx00002 BY fakturno vbeln matnr posnr.

****Added by Rahmadi
*--Text Formatting purposes
  PERFORM f_reduce_spaces USING    d_smtxt
                                   10
                                   ''
                          CHANGING ld_pos.
  ld_pos1 = ld_pos + 50.
****End of addition

**Proceed ONLY Normal billing (Reference doc = blank)
  lt_norm[] = ft_tx00002[].
  DELETE lt_norm WHERE NOT bilref IS INITIAL OR
                 ( itamtlast = 0 AND itdisclast = 0 ).

**Get data whose tariff
  lt_tarif[] = lt_norm[].
  DELETE lt_tarif WHERE tarifxpbm = 0.
  SORT lt_tarif BY fakturno vbeln tarifxpbm.
  DELETE ADJACENT DUPLICATES FROM lt_tarif
                  COMPARING  fakturno vbeln tarifxpbm.

  CLEAR: lw_norm, lw_norm1.
  LOOP AT lt_norm.
    MOVE-CORRESPONDING lt_norm TO lw_norm.

**** calculte dpp jika ada VAT 1% by Item 14122012
    IF lw_norm-bukrs EQ '8050' OR
      lw_norm-bukrs EQ '8230' OR
      lw_norm-bukrs EQ '8800'.
      SELECT SINGLE mwskz
        FROM bset
        INTO ld_mwskz
        WHERE bukrs EQ lt_norm-bukrs AND
              belnr EQ lt_norm-belnr AND
              gjahr EQ lt_norm-gjahr.
      IF sy-subrc EQ 0.
        IF ld_mwskz EQ 'K3' OR ld_mwskz EQ 'K7'.
          lw_norm-dpplast = lw_norm-itamtlast / 10.
        ENDIF.
      ENDIF.
    ENDIF.

****Filling up Tariff
    t_ftax-fakturno = lw_norm-fakturno.
****DPP for determining tariff is only for PPNBM deductable item
    IF lw_norm-ppnbmlast <> 0.    "added by Rahmadi
      t_ftax-dpplast  = lw_norm-dpplast.
    ELSE.
      CLEAR t_ftax-dpplast.
    ENDIF.
    t_ftax-fakppnbm = lw_norm-ppnbmlast.
    READ TABLE lt_tarif WITH KEY fakturno = lw_norm-fakturno
                                            BINARY SEARCH.
    IF sy-subrc = 0.
      t_ftax-tarifxpbm = lt_tarif-tarifxpbm.
    ELSE.
      CLEAR t_ftax-tarifxpbm.
    ENDIF.
    COLLECT t_ftax.

    IF lw_norm1-fakturno <> lw_norm-fakturno.
      IF sy-tabix = 1.
*-------AT NEW Faktur no.
        READ TABLE ft_tx00003 WITH KEY fakturno = lw_norm-fakturno
                                                  BINARY SEARCH.
        PERFORM f_filling_pkp_satuan USING lw_norm
                                           ft_tx00003-faktur_type
                                           ft_tx00003-wapu
                                           ft_tx00003-gsber
                                           ft_tx00003-brnch
                                           ft_tx00003-busln
                                           ft_tx00003-bukrs
                                           ' '.
        PERFORM f_filling_customer_satuan  USING ft_tx00003.
        PERFORM f_filling_signature_satuan USING ft_tx00003.

* Command for TKM
        "Uang Muka
***        IF lw_norm-bukrs = '8160'.
***          READ TABLE t_ftax ASSIGNING <fs_ftax> WITH KEY fakturno = lw_norm-fakturno.
***          <fs_ftax>-fakdp = ft_tx00003-fakdp.
***        ENDIF.

        CLEAR ld_linenum.
        lw_norm1 = lw_norm.
      ELSE.
*-------AT END Faktur no.
* Changed by rama
        IF fu_flag = '1'.
*        ( lw_norm1-vkorg = c_vkorg_kkm AND
*             lw_norm1-spart = d_fin_unit )   OR
*           ( lw_norm1-vkorg = c_vkorg_kkm AND
*             lw_norm1-spart = d_used )       OR
*           ( lw_norm1-vkorg = c_vkorg_mkm  AND
*             lw_norm1-spart = d_fin_unit )   OR
*           ( lw_norm1-vkorg = c_vkorg_mkm  AND
*             lw_norm1-spart = d_used )       OR
*           ( lw_norm1-vkorg = c_vkorg_mkm  AND
*             lw_norm1-spart = d_truck )      OR
*             lw_norm1-spart = d_sparts.

**********Single item only per Billing (usually for SP)
          PERFORM f_filling_single_item_satuan USING lw_norm1
                                                     '001'
                                                     ld_item
                                                     ld_itamtlast
                                                     ld_itdisclast
                                                     ld_dpplast
                                                     ld_xppnbmlast
                                                     ld_ppnlast
                                                     ld_itamt_f
                                                     ld_itdisc_f
                                                     ld_dpp_f
                                                     ld_xppnbm_f
                                                     ld_ppn_f
                                                     ld_trcurr
                                                     ld_taxrate
                                                     ld_itqtylast "Tempo
                                                     ld_prcpiece. "Tempo
* Changed by rama
        ELSEIF fu_flag = '4'.
**** Comment: MAY NEED TO ADD USER EXIT FOR CUSTOM TEXT
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_service ) OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_service1 ) OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_parts )   OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_parts1 )  OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_parts2 )  OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_parts3 )  OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_parts4 )  OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_contr )   OR
*               ( lw_norm1-spart = d_service         AND
*                 lw_norm1-pstyv = c_pstyv_contr1 ).
**********Multi item (Material + additional info) -- SERVICE
          PERFORM f_filling_multi_item_satuan USING lw_norm1
                                                     '001'
                                                     ld_item1
                                                     ld_item2
                                                     ld_item3
                                                     ld_itamtlast
                                                     ld_itdisclast
                                                     ld_dpplast
                                                     ld_xppnbmlast
                                                     ld_ppnlast
                                                     ld_itamt_f
                                                     ld_itdisc_f
                                                     ld_dpp_f
                                                     ld_xppnbm_f
                                                     ld_ppn_f
                                                     ld_trcurr
                                                     ld_taxrate.
***** End of comment

****Multi materials in Faktur
* Changed by rama
        ELSEIF fu_flag = '2' OR
               fu_flag = '3'.
*               lw_norm-vkorg = c_vkorg_ktb AND
*               lw_norm-spart = d_fin_unit.
          ld_linenum = ld_linenum + 1.
          ld_prcpiece = ld_itamtlast / ld_itqtylast.

****changed for Tempo --- quantity could have decimals
*          WRITE ld_itqtylast DECIMALS 0 TO ld_qtychar.
          WRITE ld_itqtylast TO ld_qtychar UNIT lw_norm1-vrkme.
****end of Tempo changes

          WRITE ld_prcpiece TO ld_piechar CURRENCY lw_norm1-itcurr.
***** Modified by Rahmadi
*          CONCATENATE ld_qtychar c_gab_unit1 c_prctr10 lw_norm1-item
*                      INTO ld_item SEPARATED BY space.
          IF fu_flag = '2'.
****changed for Tempo --- include Mat'l number to the description
            CONCATENATE lw_norm1-matnr
                        lw_norm1-item
                        INTO ld_item
                        SEPARATED BY space.
*            ld_item = lw_norm1-item.
****end of Tempo changes
****Update logic for Tempo -- ITEM must be divided to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
            IF fu_cust = 'X'.
            ELSE.
              ld_item+45(5) = ld_qtychar.
              d_smtxt1 = ld_piechar.
              ld_item+50(ld_pos) = d_smtxt.
              ld_item+ld_pos1(15) = d_smtxt1.
            ENDIF.
          ELSEIF fu_flag = '3'.
            ld_item+0(10) = lw_norm1-vbeln.
            ld_item+11(3) = ' - '.
            ld_item+14(30) = lw_norm1-item.
****Update logic for Tempo -- ITEM must be divided back to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
            IF fu_cust = 'X'.
            ELSE.
              ld_item+45(5) = ld_qtychar.
              d_smtxt1 = ld_piechar.
              ld_item+50(ld_pos) = d_smtxt.
              ld_item+ld_pos1(15) = d_smtxt1.
            ENDIF.
          ENDIF.
***** End of modification

****End of Tempo update 23/05/2005

          PERFORM f_filling_single_item_satuan USING lw_norm1
                                                     ld_linenum
                                                     ld_item
                                                     ld_itamtlast
                                                     ld_itdisclast
                                                     ld_dpplast
                                                     ld_xppnbmlast
                                                     ld_ppnlast
                                                     ld_itamt_f
                                                     ld_itdisc_f
                                                     ld_dpp_f
                                                     ld_xppnbm_f
                                                     ld_ppn_f
                                                     ld_trcurr
                                                     ld_taxrate
                                                     ld_itqtylast "Tempo
                                                     ld_prcpiece. "Tempo

          CLEAR: ld_itamt_f, ld_itdisc_f, ld_dpp_f,
                 ld_xppnbm_f, ld_ppn_f, ld_trcurr, ld_taxrate.
          CLEAR: ld_itamtlast, ld_itdisclast, ld_dpplast,
                 ld_xppnbmlast, ld_ppnlast, ld_itqtylast, t_fitem.
        ENDIF.
        CLEAR: ld_itamt_f, ld_itdisc_f, ld_dpp_f,
               ld_xppnbm_f, ld_ppn_f, ld_trcurr,
               ld_taxrate.

        CLEAR: ld_itamtlast,  ld_itdisclast, ld_dpplast,
               ld_xppnbmlast, ld_ppnlast,    ld_itqtylast, t_fitem.

*-------AT NEW Faktur no.
        READ TABLE ft_tx00003 WITH KEY fakturno = lw_norm-fakturno
                              BINARY SEARCH.
        PERFORM f_filling_pkp_satuan USING lw_norm
                                           ft_tx00003-faktur_type
                                           ft_tx00003-wapu
                                           ft_tx00003-gsber
                                           ft_tx00003-brnch
                                           ft_tx00003-busln
                                           ft_tx00003-bukrs
                                           ' '.

        PERFORM f_filling_customer_satuan  USING ft_tx00003.
        PERFORM f_filling_signature_satuan USING ft_tx00003.

        lw_norm1 = lw_norm.
        CLEAR ld_linenum.
      ENDIF.

      CLEAR ld_item.
    ENDIF.

* Changed by rama
    IF fu_flag = '2' OR
       fu_flag = '3'.
*       lw_norm-vkorg = c_vkorg_ktb AND lw_norm-spart = d_fin_unit.

* Perubahan 14122012 summary by item
      IF lw_norm-bukrs EQ '8050' OR
        lw_norm-bukrs EQ '8800'.
        CONCATENATE lw_norm1-posnr lw_norm1-matnr INTO lw_norm1-matnr.
        CONCATENATE lw_norm-posnr lw_norm-matnr INTO lw_norm-matnr.
      ENDIF.

      IF lw_norm1-matnr <> lw_norm-matnr.
        ld_linenum = ld_linenum + 1.
        ld_prcpiece = ld_itamtlast / ld_itqtylast.
*bcdik
****changed for Tempo --- quantity could have decimals
*          WRITE ld_itqtylast DECIMALS 0 TO ld_qtychar.
        WRITE ld_itqtylast TO ld_qtychar UNIT lw_norm1-vrkme.
****end of Tempo changes
        WRITE ld_prcpiece TO ld_piechar CURRENCY lw_norm1-itcurr.

***** Modified by Rahmadi
*---Material-based consolidation -- Multi materials in Faktur Pajak
*          CONCATENATE ld_qtychar c_gab_unit1 c_prctr10 lw_norm1-item
*                      INTO ld_item SEPARATED BY space.
        IF fu_flag = '2'.
****changed for Tempo --- include Mat'l number to the description
          IF ( lw_norm-bukrs EQ '8050' OR lw_norm-bukrs EQ '8800' ) AND
            lw_norm-busln EQ '99'.
            ld_item = lw_norm1-item.
          ELSE.
            CONCATENATE lw_norm1-matnr
                        lw_norm1-item
                        INTO ld_item
                        SEPARATED BY space.
          ENDIF.
*          ld_item = lw_norm1-item.
****end of Tempo changes
****Update logic for Tempo -- ITEM must be divided back to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
          IF fu_cust = 'X'.
          ELSE.
            ld_item+45(5) = ld_qtychar.
            d_smtxt1 = ld_piechar.
            ld_item+50(ld_pos) = d_smtxt.
            ld_item+ld_pos1(15) = d_smtxt1.
          ENDIF.
        ELSEIF fu_flag = '3'.
          ld_item+0(10) = lw_norm1-vbeln.
          ld_item+11(3) = ' - '.
          ld_item+14(30) = lw_norm1-item.
****Update logic for Tempo -- ITEM must be divided back to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
          IF fu_cust = 'X'.
          ELSE.
            ld_item+45(5) = ld_qtychar.
            d_smtxt1 = ld_piechar.
            ld_item+50(ld_pos) = d_smtxt.
            ld_item+ld_pos1(15) = d_smtxt1.
          ENDIF.
        ENDIF.
***** End of modification

        PERFORM f_filling_single_item_satuan
                USING lw_norm1      ld_linenum    ld_item
                      ld_itamtlast  ld_itdisclast ld_dpplast
                      ld_xppnbmlast ld_ppnlast
                      ld_itamt_f  ld_itdisc_f ld_dpp_f
                      ld_xppnbm_f ld_ppn_f ld_trcurr
                      ld_taxrate
                      ld_itqtylast   "Tempo
                      ld_prcpiece.   "Tempo

        CLEAR: ld_itamt_f,  ld_itdisc_f, ld_dpp_f,
               ld_xppnbm_f, ld_ppn_f, ld_trcurr,
               ld_taxrate.

        CLEAR: ld_itamtlast,  ld_itdisclast, ld_dpplast,
               ld_xppnbmlast, ld_ppnlast,    ld_itqtylast, t_fitem.

        lw_norm1 = lw_norm.
      ENDIF.
    ENDIF.

****Filling up Item Amounts
    ld_itamtlast  = ld_itamtlast  + lw_norm-itamtlast.
    ld_itdisclast = ld_itdisclast + lw_norm-itdisclast.
    ld_dpplast    = ld_dpplast    + lw_norm-dpplast.
    ld_xppnbmlast = ld_xppnbmlast + lw_norm-xppnbmlast.
    ld_ppnlast    = ld_ppnlast    + lw_norm-ppnlast.

    ld_itamt_f  = ld_itamt_f  + lw_norm-itamt_f.
    ld_itdisc_f = ld_itdisc_f + lw_norm-itdisc_f.
    ld_dpp_f    = ld_dpp_f    + lw_norm-dpp_f.
    ld_xppnbm_f = ld_xppnbm_f + lw_norm-xppnbm_f.
    ld_ppn_f    = ld_ppn_f    + lw_norm-ppn_f.
    ld_taxrate  = lw_norm-rate_tax.
    ld_trcurr   = lw_norm-trcurr.

****Quantity is only collected for KTB-FINISHED UNIT
* Changed by rama
*    IF fu_flag = '3' OR
*       fu_flag = '1'.
*       lw_norm-vkorg = c_vkorg_ktb AND
*       lw_norm-spart = d_fin_unit.
    ld_itqtylast  = ld_itqtylast + lw_norm-itqtylast.
*    ENDIF.

****Item description
    ld_prcpiece = ld_itamtlast / ld_itqtylast.
    WRITE ld_prcpiece TO ld_piechar CURRENCY lw_norm1-itcurr.

****changed for Tempo --- quantity could have decimals
*          WRITE ld_itqtylast DECIMALS 0 TO ld_qtychar.
    WRITE ld_itqtylast TO ld_qtychar UNIT lw_norm1-vrkme.
****end of Tempo changes

*** Modified by Rahmadi
*---FU_FLAG determines how the invoices were consolidated
*---for Faktur Pajak
    CASE fu_flag.
      WHEN '1'.
*-----Invoice based: Single line for each invoice
*        ld_item+0(10) = lw_norm-vbeln.   "MKM 19/01/2004
*        ld_item+11(3) = ' - '.           "MKM 19/01/2004
*        ld_item+14(30) = d_smtxt.        "MKM 19/01/2004
*        ld_item+45(5) = ld_qtychar.      "MKM 19/01/2004
*        ld_item+50(10) = d_smtxt1.       "MKM 19/01/2004
*        ld_item+61(10) = d_smtxt2.       "MKM 19/01/2004
        ld_item+0(30) = d_smtxt.          "MKM 19/01/2004
        ld_item+31(10) = lw_norm-vbeln.   "MKM 19/01/2004
        ld_item+41(10) = d_smtxt1.        "MKM 19/01/2004
        ld_item+51(10) = d_smtxt2.        "MKM 19/01/2004
      WHEN '2'.
*-----Material based: Single line for each material
****changed for Tempo --- include Mat'l number to the description
****Update logic for Tempo -- ITEM must be divided to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
        IF ( lw_norm-bukrs EQ '8050' OR lw_norm-bukrs EQ '8800' ) AND
          lw_norm-busln EQ '99'.
          ld_item = lw_norm-item.
        ELSE.
          CONCATENATE lw_norm-matnr
                      lw_norm-item
                      INTO ld_item
                      SEPARATED BY space.
        ENDIF.
*            ld_item = lw_norm-item.
****end of Tempo changes
****Update logic for Tempo -- ITEM must be divided back to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
        IF fu_cust = 'X'.
        ELSE.
          ld_item+45(5) = ld_qtychar.
          d_smtxt1 = ld_piechar.
          ld_item+50(ld_pos) = d_smtxt.
          ld_item+ld_pos1(15) = d_smtxt1.
        ENDIF.
      WHEN '3'.
*-----Material & Invoice based: Line per material per invoice
        ld_item+0(10) = lw_norm-vbeln.
        ld_item+11(3) = ' - '.
        ld_item+14(30) = lw_norm1-item.
****Update logic for Tempo -- ITEM must be divided back to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
        IF fu_cust = 'X'.
        ELSE.
          ld_item+45(5) = ld_qtychar.
          d_smtxt1 = ld_piechar.
          ld_item+50(ld_pos) = d_smtxt.
          ld_item+ld_pos1(15) = d_smtxt1.
        ENDIF.
      WHEN '4'.
*-----Text based: Single line custom text representing 1 invoice
        CONCATENATE lw_norm-vbeln
                    d_smtxt
                    d_smtxt1
                    d_smtxt2
                    INTO ld_item
                    SEPARATED BY space.
    ENDCASE.
*** End of modification

*** Commented out by Rahmadi -- Text generalization
*** MAY NEED USER EXIT FOR CUSTOM LOGIC
*    IF lw_norm-spart = d_fin_unit OR lw_norm-spart = d_used
*       OR lw_norm-spart = d_truck.
*
*      IF lw_norm-vkorg = c_vkorg_kkm.
*        IF ( lw_norm-karoseri = d_karu ) OR
*           ( lw_norm-karoseri = d_kara ).
*
*          IF lw_norm-karoseri = d_karu OR
*             ( lw_norm-karoseri = d_kara AND ld_item IS INITIAL ).
*
*            WRITE lw_norm-itqtylast DECIMALS 0 TO ld_qtychar.
*            CONCATENATE ld_qtychar c_gab_unit1 c_prctr20 lw_norm-item
*                        INTO ld_item SEPARATED BY space.
*          ENDIF.
*        ENDIF.
**This routine must be considered if any new company code live
*      ELSEIF lw_norm-vkorg = c_vkorg_mkm.
*        IF ( lw_norm-karoseri = d_karu ) OR
*             ( lw_norm-karoseri = d_kara ).
*
*          IF lw_norm-karoseri = d_karu OR
*             ( lw_norm-karoseri = d_kara AND ld_item IS INITIAL ).
*
*            WRITE lw_norm-itqtylast DECIMALS 0 TO ld_qtychar.
*            CONCATENATE ld_qtychar c_gab_unit1 c_prctr30 lw_norm-item
*                        INTO ld_item SEPARATED BY space.
*          ENDIF.
*        ENDIF.
*
*      ENDIF.
*    ELSEIF lw_norm-spart = d_sparts.
*      ld_item = c_gab_sparepart.
*    ELSEIF lw_norm-spart = d_service.
*      IF ( lw_norm-pstyv = c_pstyv_parts ) OR
*         ( lw_norm-pstyv = c_pstyv_parts1 ) OR
*         ( lw_norm-pstyv = c_pstyv_parts2 ) OR
*         ( lw_norm-pstyv = c_pstyv_parts3 ) OR
*         ( lw_norm-pstyv = c_pstyv_parts4 ).
*        ld_item1      = c_gab_serv_part1.
*        CONCATENATE c_gab_serv_part2 lw_norm-vbeln c_trlp
*                    INTO ld_item2 SEPARATED BY space.
*      ELSEIF lw_norm-pstyv = c_pstyv_service OR
*             lw_norm-pstyv = c_pstyv_service1.
*        ld_item1 = c_gab_serv_jasa1.
*        CONCATENATE c_gab_serv_part2 lw_norm-vbeln c_trlp
*                    INTO ld_item2 SEPARATED BY space.
*      ELSEIF ( lw_norm-pstyv = c_pstyv_contr ) OR
*             ( lw_norm-pstyv = c_pstyv_contr1 ).
*        ld_item1 = c_gab_serv_contr.
*        CONCATENATE c_gab_serv_part2 lw_norm-vbeln c_trlp
*                    INTO ld_item2 SEPARATED BY space.
*      ENDIF.
*    ENDIF.
*
**----- for Head Office
*    IF lw_norm-vkorg = c_vkorg_ho OR
*       ( lw_norm-vkorg = c_vkorg_mkm AND lw_norm-spart = d_others )
*       OR
*       ( lw_norm-vkorg = c_vkorg_ktb AND lw_norm-spart = d_others )
*       OR
*       ( lw_norm-vkorg = c_vkorg_kkm AND lw_norm-spart = d_others ).
*      ld_linenum = ld_linenum + 1.
*      ld_item = lw_norm-item.
*      PERFORM f_filling_single_item_satuan
*              USING lw_norm1      ld_linenum    ld_item
*                    ld_itamtlast  ld_itdisclast ld_dpplast
*                    ld_xppnbmlast ld_ppnlast
*
*                    ld_itamt_f ld_itdisc_f ld_dpp_f
*                    ld_xppnbm_f ld_ppn_f ld_trcurr
*                    ld_taxrate.
*
*      CLEAR: ld_itamt_f,  ld_itdisc_f, ld_dpp_f,
*             ld_xppnbm_f, ld_ppn_f, ld_trcurr,
*             ld_taxrate.
*
*      CLEAR: ld_itamtlast,  ld_itdisclast, ld_dpplast,
*             ld_xppnbmlast, ld_ppnlast,    ld_itqtylast, t_fitem.
*      lw_norm1 = lw_norm.
*    ENDIF.
**** End of comment

    AT LAST.
*-----AT END Faktur no./Material for the last record only
* Changed by rama
      IF fu_flag = '1'.
*          ( lw_norm-vkorg = c_vkorg_kkm AND
*           lw_norm-spart = d_fin_unit )   OR
*         ( lw_norm-vkorg = c_vkorg_kkm AND
*           lw_norm-spart = d_used )       OR
*           ( lw_norm1-vkorg = c_vkorg_mkm  AND
*             lw_norm1-spart = d_fin_unit )   OR
*           ( lw_norm1-vkorg = c_vkorg_mkm  AND
*             lw_norm1-spart = d_used )       OR
*           ( lw_norm1-vkorg = c_vkorg_mkm  AND
*             lw_norm1-spart = d_truck )      OR
*             lw_norm1-spart = d_sparts.
*
********Single item only (KKM FIN.UNIT or ANY BRAND for PARTS)
        PERFORM f_filling_single_item_satuan
                USING lw_norm       '001'          ld_item
                      ld_itamtlast  ld_itdisclast  ld_dpplast
                      ld_xppnbmlast ld_ppnlast
                      ld_itamt_f  ld_itdisc_f  ld_dpp_f
                      ld_xppnbm_f ld_ppn_f ld_trcurr
                      ld_taxrate
                      ld_itqtylast   "Tempo
                      ld_prcpiece.   "Tempo

        CLEAR: ld_itamt_f,  ld_itdisc_f, ld_dpp_f,
               ld_xppnbm_f, ld_ppn_f, ld_trcurr,
               ld_taxrate.
        CLEAR: ld_itamtlast,  ld_itdisclast, ld_dpplast,
               ld_xppnbmlast, ld_ppnlast, t_fitem.
* Changed by rama
      ELSEIF fu_flag = '4'.
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_service ) OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_service1 ) OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_parts )   OR
*             ( lw_norm1-spart = d_service         AND
*               lw_norm1-pstyv = c_pstyv_service1 ) OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_parts1 )  OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_parts2 )  OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_parts3 )  OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_parts4 )  OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_contr )   OR
*             ( lw_norm-spart = d_service         AND
*               lw_norm-pstyv = c_pstyv_contr1 ).
*
********Multi item (Material + additional info) -- SERVICE
        PERFORM f_filling_multi_item_satuan USING lw_norm
                                                   '001'
                                                   ld_item1
                                                   ld_item2
                                                   ld_item3
                                                   ld_itamtlast
                                                   ld_itdisclast
                                                   ld_dpplast
                                                   ld_xppnbmlast
                                                   ld_ppnlast
                                                   ld_itamt_f
                                                   ld_itdisc_f
                                                   ld_dpp_f
                                                   ld_xppnbm_f
                                                   ld_ppn_f
                                                   ld_trcurr
                                                   ld_taxrate.

        CLEAR: ld_itamt_f,  ld_itdisc_f, ld_dpp_f,
               ld_xppnbm_f, ld_ppn_f, ld_trcurr,
               ld_taxrate.

        CLEAR: ld_itamtlast,  ld_itdisclast, ld_dpplast,
               ld_xppnbmlast, ld_ppnlast,     t_fitem.

****Update logic for Tempo -- ITEM must be divided to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
      ELSEIF fu_flag = '2' OR
             fu_flag = '3'.
* Changed by rama
*             lw_norm-vkorg = c_vkorg_ktb AND
*             lw_norm-spart = d_fin_unit.
********KTB - FINISHED UNIT (Multi materials)
        ld_linenum = ld_linenum + 1.
        ld_prcpiece = ld_itamtlast / ld_itqtylast.

****changed for Tempo --- quantity could have decimals
*          WRITE ld_itqtylast DECIMALS 0 TO ld_qtychar.
        WRITE ld_itqtylast TO ld_qtychar UNIT lw_norm1-vrkme.
****end of Tempo changes
        WRITE ld_prcpiece TO ld_piechar CURRENCY lw_norm1-itcurr.

***** Modified by Rahmadi
*          CONCATENATE ld_qtychar c_gab_unit1 c_prctr10 lw_norm1-item
*                      INTO ld_item SEPARATED BY space.
        IF fu_flag = '2'.
****changed for Tempo --- include Mat'l number to the description
          IF ( lw_norm1-bukrs EQ '8050' OR lw_norm-bukrs EQ '8800' ) AND
            lw_norm1-busln EQ '99'.
            ld_item = lw_norm1-item.
          ELSE.
            CONCATENATE lw_norm1-matnr
                        lw_norm1-item
                        INTO ld_item
                        SEPARATED BY space.
          ENDIF.
*          ld_item = lw_norm1-item.
****end of Tempo changes

****Update logic for Tempo -- ITEM must be divided back to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
          IF fu_cust = 'X'.
          ELSE.
            ld_item+45(5) = ld_qtychar.
            d_smtxt1 = ld_piechar.
            ld_item+50(ld_pos) = d_smtxt.
            ld_item+ld_pos1(15) = d_smtxt1.
          ENDIF.
        ELSEIF fu_flag = '3'.
          ld_item+0(10) = lw_norm1-vbeln.
          ld_item+11(3) = ' - '.
          ld_item+14(30) = lw_norm1-item.
****Update logic for Tempo -- ITEM must be divided back to the original
****fields (logic only applied for CUSTOM FORM (SMARTFORMS) 23/05/2005
**** FU_CUST = 'X')
          IF fu_cust = 'X'.
          ELSE.
            ld_item+45(5) = ld_qtychar.
            d_smtxt1 = ld_piechar.
            ld_item+50(ld_pos) = d_smtxt.
            ld_item+ld_pos1(15) = d_smtxt1.
          ENDIF.
        ENDIF.
***** End of modification
        PERFORM f_filling_single_item_satuan
                USING lw_norm1      ld_linenum    ld_item
                      ld_itamtlast  ld_itdisclast ld_dpplast
                      ld_xppnbmlast ld_ppnlast
                      ld_itamt_f  ld_itdisc_f ld_dpp_f
                      ld_xppnbm_f ld_ppn_f ld_trcurr
                      ld_taxrate
                      ld_itqtylast   "Tempo
                      ld_prcpiece.   "Tempo

        CLEAR: ld_itamt_f,  ld_itdisc_f, ld_dpp_f,
               ld_xppnbm_f, ld_ppn_f, ld_trcurr,
               ld_taxrate.
        CLEAR: ld_itamtlast,  ld_itdisclast, ld_dpplast,
               ld_xppnbmlast, ld_ppnlast,    ld_itqtylast, t_fitem.
      ENDIF.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " F_PREPARE_SATUAN_FORM

*&---------------------------------------------------------------------*
*&       FORM f_filling_pkp_satuan                                     *
*&---------------------------------------------------------------------*
*&  This routine fills up PKP internal table for Printing function
*&---------------------------------------------------------------------*
*&  ->FU_NORM           - Billing data
*&  ->FU_FAKTUR_TYPE    - Tax form/faktur pajak type
*&  ->FU_WAPU           - WAPU
*&  ->FU_GSBER          - Business area
*&---------------------------------------------------------------------*
FORM f_filling_pkp_satuan USING fu_norm LIKE zgdtxdt0002
                                fu_faktur_type
                                fu_wapu
                                fu_gsber
                                fu_brnch
                                fu_busln
                                fu_bukrs
                                fc_line.

  DATA ld_vbeln LIKE t_fpkp-vbeln.

  READ TABLE t_tx00103 WITH KEY brnch = fu_brnch
                                busln = fu_busln.

  t_fpkp-fakturno     = fu_norm-fakturno.

  CASE fu_wapu.
    WHEN d_n.
      ld_vbeln = 'A'.
    WHEN d_w.
      ld_vbeln = 'B'.
  ENDCASE.

  IF  t_tx00103-pkpfl IS INITIAL.
***modified by Rahmadi
*      mac_from_variabel d_ d_b d_hnr_.
    mac_from_variabel d_ d_b d_bnr_.
***end of modification
  ELSE.
    mac_from_variabel d_ d_h d_hnr_.
  ENDIF.

***removed by Rahmadi
*  IF fu_norm-rectype NE 'N'.  "-> only for live
*    CONCATENATE ld_vbeln '-' fu_brnch '-'
*                fu_norm-vbeln
*                INTO t_fpkp-vbeln.
*  ELSE.
***end of removal

  CONCATENATE ld_vbeln '-' fu_brnch '-'
              fu_norm-vbeln
              INTO t_fpkp-vbeln.
*  ENDIF.

  t_fpkp-rectype      = fu_norm-rectype.
  t_fpkp-pkpnpwp      = d_pkpnpwp.
  t_fpkp-pkpkuh       = d_pkpkuh.
  t_fpkp-pkpname      = d_pkpname.
  t_fpkp-pkpaddrs1    = d_pkpaddrs1.
  t_fpkp-pkpaddrs2    = d_pkpaddrs2.
  t_fpkp-waers        = fu_norm-itcurr.
  t_fpkp-kwitansi     = fu_norm-kwitansi.

  t_fpkp-faktur_type  = fu_faktur_type.

  t_fpkp-spart        = fu_norm-busln.

  APPEND t_fpkp.

ENDFORM.                    " F_FILLING_PKP_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_FILLING_CUSTOMER_SATUAN
*&---------------------------------------------------------------------*
*&  This routine fills up Customer internal table for Printing function
*&---------------------------------------------------------------------*
*&  ->FU_TX00003        - Faktur pajak header data
*&---------------------------------------------------------------------*
FORM f_filling_customer_satuan USING fu_tx00003 LIKE zgdtxdt0003.

  MOVE-CORRESPONDING fu_tx00003 TO t_fcustomer.
  APPEND t_fcustomer.

ENDFORM.                    " F_FILLING_CUSTOMER_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_FILLING_SIGNATURE_SATUAN
*&---------------------------------------------------------------------*
*&  This routine fills up Signature internal table for Printing function
*&---------------------------------------------------------------------*
*&  ->FU_TX00003        - Faktur pajak header data
*&---------------------------------------------------------------------*
FORM f_filling_signature_satuan USING fu_tx00003 LIKE zgdtxdt0003.

  t_fsignature-fakturno = fu_tx00003-fakturno.
  t_fsignature-city     = d_pkpcity.
  t_fsignature-fakdat   = fu_tx00003-fakdat.
  IF d_aktif = d_aktif1.
    t_fsignature-petugas = d_petugas.
    t_fsignature-jabat   = d_jabat.
  ELSEIF d_aktif = d_aktif2.
    t_fsignature-petugas = d_petugas2.
    t_fsignature-jabat   = d_jabat2.

  ELSEIF d_aktif = d_aktif3.
    t_fsignature-petugas = d_name_kaadm.
    t_fsignature-jabat   = d_kaadm.
  ELSEIF d_aktif = d_aktif4.
    t_fsignature-petugas = d_name_kacab.
    t_fsignature-jabat   = d_kacab.

***Added by Rahmadi
*--Additional field for freefill text for Tax Signatory
  ELSEIF d_aktif = d_aktif5.
    t_fsignature-petugas = d_petugas_e.
    t_fsignature-jabat   = d_jabat_e.
***end of addition
  ENDIF.
  APPEND t_fsignature.

ENDFORM.                    " F_FILLING_SIGNATURE_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_FILLING_SINGLE_ITEM_SATUAN
*&---------------------------------------------------------------------*
*&  This routine fills up Item internal table for Printing function.
*&  It will only be executed if faktur pajak can only contain single
*&  item.
*&---------------------------------------------------------------------*
*&  ->FU_NORM       - Faktur pajak item data
*&  ->FU_LINENUM    - Line number
*&  ->FU_ITEM       - Item to be displayed in faktur pajak
*&  ->FU_ITAMTLAST  - Price amount
*&  ->FU_DPPLAST    - DPP amount
*&  ->FU_XPPNBMLAST - XPPNBM amount
*&  ->FU_PPNLAST    - PPN amount
*&---------------------------------------------------------------------*
FORM f_filling_single_item_satuan USING    fu_norm LIKE zgdtxdt0002
                                           fu_linenum
                                           fu_item
                                           fu_itamtlast
                                           fu_itdisclast
                                           fu_dpplast
                                           fu_xppnbmlast
                                           fu_ppnlast
                                           fu_itamt_f
                                           fu_itdisc_f
                                           fu_dpp_f
                                           fu_xppnbm_f
                                           fu_ppn_f
                                           fu_trcurr
                                           fu_rate_tax
                                           fu_itqtylast  "added in Tempo
                                           fu_prcpiece.  "added in Tempo

  DATA ld_mwskz      TYPE bset-mwskz.

  t_fitem-fakturno   = fu_norm-fakturno.
  t_fitem-linenum    = fu_linenum.
  t_fitem-item       = fu_item.
  t_fitem-itamtlast  = fu_itamtlast.
  t_fitem-itdisclast = fu_itdisclast.
  t_fitem-dpplast    = fu_dpplast.
  t_fitem-xppnbmlast = fu_xppnbmlast.
  t_fitem-ppnlast    = fu_ppnlast.
***added for Tempo
  t_fitem-vrkme      = fu_norm-vrkme.  "Sales unit
  t_fitem-itqtylast  = fu_itqtylast.   "quantity
  t_fitem-prcpiece   = fu_prcpiece.    "Unit price
***end of Tempo addition

  t_fitem-itamt_f  = fu_itamt_f.
  t_fitem-itdisc_f = fu_itdisc_f.
  t_fitem-dpp_f    = fu_dpp_f.
  t_fitem-xppnbm_f = fu_xppnbm_f.
  t_fitem-ppn_f    = fu_ppn_f.
  t_fitem-trcurr   = fu_trcurr.
  t_fitem-rate_tax = fu_rate_tax.

  APPEND t_fitem.

ENDFORM.                    " F_FILLING_SINGLE_ITEM_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_FILLING_MULTI_ITEM_SATUAN
*&---------------------------------------------------------------------*
*&  This routine fills up Item internal table for Printing function.
*&  It will only be executed if faktur pajak can contain multiple
*&  item.
*&---------------------------------------------------------------------*
*&  ->FU_NORM       - Faktur pajak item data
*&  ->FU_LINENUM    - Line number
*&  ->FU_ITEM1      - Item to be displayed in faktur pajak
*&  ->FU_ITEM2      - Item to be displayed in faktur pajak
*&  ->FU_ITEM3      - Item to be displayed in faktur pajak
*&  ->FU_ITAMTLAST  - Price amount
*&  ->FU_DPPLAST    - DPP amount
*&  ->FU_XPPNBMLAST - XPPNBM amount
*&  ->FU_PPNLAST    - PPN amount
*&---------------------------------------------------------------------*
FORM f_filling_multi_item_satuan USING    fu_norm LIKE zgdtxdt0002
                                          fu_linenum
                                          fu_item1
                                          fu_item2
                                          fu_item3
                                          fu_itamtlast
                                          fu_itdisclast
                                          fu_dpplast
                                          fu_xppnbmlast
                                          fu_ppnlast

                                          fu_itamt_f
                                          fu_itdisc_f
                                          fu_dpp_f
                                          fu_xppnbm_f
                                          fu_ppn_f
                                          fu_trcurr
                                          fu_rate_tax.

  t_fitem-fakturno   = fu_norm-fakturno.
  t_fitem-linenum    = fu_linenum.
  t_fitem-item       = fu_item1.
  t_fitem-itamtlast  = fu_itamtlast.
  t_fitem-itdisclast = fu_itdisclast.
  t_fitem-dpplast    = fu_dpplast.
  t_fitem-xppnbmlast = fu_xppnbmlast.
  t_fitem-ppnlast    = fu_ppnlast.
  t_fitem-itamt_f  = fu_itamt_f.
  t_fitem-itdisc_f = fu_itdisc_f.
  t_fitem-dpp_f    = fu_dpp_f.
  t_fitem-xppnbm_f = fu_xppnbm_f.
  t_fitem-ppn_f    = fu_ppn_f.
  t_fitem-trcurr   = fu_trcurr.
  t_fitem-rate_tax = fu_rate_tax.
  APPEND t_fitem. CLEAR t_fitem.
  t_fitem-fakturno   = fu_norm-fakturno.
  t_fitem-item       = fu_item2.
  APPEND t_fitem.
  t_fitem-fakturno   = fu_norm-fakturno.
  t_fitem-item       = fu_item3.
  APPEND t_fitem.

ENDFORM.                    " F_FILLING_MULTI_ITEM_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_LEADING_ZERO
*&---------------------------------------------------------------------*
*& This routine is delete leading zero of tax number range.
*& I don't simply just move it into packed number, and return it again
*& to character, because tax number range has 20 digits, even though
*& it only has 7 digits, but i prefer the save way...
*& (Note Packed Number has maximum 16 digits)
*&---------------------------------------------------------------------*
FORM f_delete_leading_zero
     CHANGING fc_number.
  DATA:
    ld_length  TYPE i,
    ld_counter TYPE i.
  ld_length = strlen( fc_number ).
  ld_counter = 0.
  WHILE ld_counter < ld_length AND fc_number+ld_counter(1) = '0'.
    ld_counter = ld_counter + 1.
  ENDWHILE.

  ld_length = ld_length - ld_counter.
  fc_number = fc_number+ld_counter(ld_length).

ENDFORM.                    "f_delete_leading_zero

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
*&    This routine assigns new sequence number to a new faktur pajak.
*&    The assignment is specific for each PKP, therefore the object
*&    range and business area passed to this routine are retrieved from
*&    F_GET_PKP routine as a preceeding process that has to be performed
*&    BEFORE performing this routine.
*&---------------------------------------------------------------------*
*&    ->FU_OBJECT   -  Number range Object id
*&    ->FU_GSBER    -  Business area as a sub-object of the number range
*&    <-FC_FAKTURNO -  New faktur no.
*&    <-FC_SUBRC    -  This parameter will be <> 0 if no new number can
*&                     be assigned to the faktur pajak
*&---------------------------------------------------------------------*
FORM f_get_next_number USING fu_object
                             fu_gsber
                             fu_bukrs
                             fu_brnch
                             fu_masatx
                             fu_form
                             fu_asset
                             fu_fakdat
                             fu_vbeln
                    CHANGING fc_fakturno fc_nocoretax fc_subrc.

  DATA lw_nriv     LIKE nriv.
  DATA ld_nrlevel  LIKE nriv-tonumber.
  DATA ld_fakturno LIKE nriv-nrlevel.
  DATA ld_fakno    LIKE nriv-nrlevel.
  DATA ld_posnr    LIKE zfvatnr-posnr.
  DATA ld_vatbr(3).
  DATA ld_vattrn   LIKE zfvattrn-vattrn.
  DATA ld_vatno1(10).

  CLEAR: fc_subrc, ld_posnr.
  fc_subrc = 3.
  ld_posnr = 10.
*  IF fu_masatx(4) GT 2006.

  SELECT SINGLE vattrn vatbr
    FROM zfvattrn
    INTO (ld_vattrn, ld_vatbr)
    WHERE vkorg EQ fu_brnch AND
          gform EQ fu_form.

  IF fu_asset EQ 'X'.
    ld_vattrn = '09'.
  ENDIF.

  IF fu_fakdat > gs_dpp-datab.
    IF ld_vattrn = '01'.
      ld_vattrn = '04'.
    ENDIF.
  ENDIF.

  IF d_coretax = 'X'.
    IF fu_fakdat IN gr_coretax.
      SELECT SINGLE fakturno
        FROM zcoretax0005
        INTO fc_fakturno
        WHERE bukrs  = fu_bukrs
          AND masatx = fu_masatx
          AND belnr  = fu_vbeln.

      CLEAR fc_subrc.
    ELSE.
      PERFORM f_old_fakturno USING fu_brnch fu_masatx fu_object ld_vatbr ld_vattrn
                                   ld_posnr
                             CHANGING fc_fakturno fc_nocoretax fc_subrc.
    ENDIF.
  ELSE.
    SELECT SINGLE fakturno
      FROM zcoretax0005
      INTO fc_fakturno
      WHERE bukrs  = fu_bukrs
        AND masatx = fu_masatx
        AND belnr  = fu_vbeln.
    IF sy-subrc = 0.
      fc_nocoretax = fc_fakturno.
      CLEAR fc_subrc.
    ELSE.
      PERFORM f_old_fakturno USING fu_brnch fu_masatx fu_object ld_vatbr ld_vattrn
                                   ld_posnr
                             CHANGING fc_fakturno fc_nocoretax fc_subrc.
    ENDIF.
  ENDIF.



**--- logic utuk proses sebelum thn 2006
**
***Get record with current number <> 0
**    SELECT SINGLE * INTO lw_nriv FROM nriv
**           WHERE object = fu_object AND
**               subobject = fu_gsber AND
**                 subobject = fu_brnch AND
**                   nrlevel <> '0'.
**    IF sy-subrc = 0.
*****Current no must be <> Last no
**      MOVE lw_nriv-nrlevel TO ld_nrlevel.
**
**      PERFORM f_delete_leading_zero
**              CHANGING ld_nrlevel.
**
*****added by Rahmadi
**      PERFORM f_delete_leading_zero
**              CNGING lw_nriv-tonumber.
*****end of addition
**      IF ld_nrlevel = lw_nriv-tonumber.
*****Modified by Rahmadi
**        SELECT SINGLE * INTO lw_nriv FROM nriv
**               WHERE object = fu_object AND
**              subobject = fu_gsber AND
**                  subobject = fu_brnch AND
**                    nrlevel = '0'.
**        IF sy-subrc <> 0.
**          CLEAR fc_fakturno.
**          fc_subrc = 3.
**          EXIT.
**        ENDIF.
**      CLEAR fc_fakturno.
**      fc_subrc = 2.
**      EXIT.
*****end of modification
**      ENDIF.
**    ELSE.
*****Not found, get NEW nrange id (curr no = '0')
**      SELECT SINGLE * INTO lw_nriv FROM nriv
**             WHERE object = fu_object AND
**              subobject = fu_gsber AND
**                subobject = fu_brnch AND
**                  nrlevel = '0'.
**      IF sy-subrc <> 0.
**        CEAR fc_fakturno.
**        fc_subrc = 3.
**        EXIT.
**      ENDIF.
**    ENDIF.
**
***Get next number in the range
**    CALL FUNCTION 'NUMBER_GET_NEXT'
**      EXPORTING
**        nr_range_nr             = lw_nriv-nrrangenr
**        object                  = fu_object
**        subobject               = lw_nriv-subobject
**      IMPORTING
**        number                  = ld_fakno
**      EXCEPTIONS
**        interval_not_found      = 1
**        number_range_not_intern = 2
**        object_not_found        = 3
**        interval_overflow       = 6
**        OTHERS                  = 7.
**    IF sy-subrc <> 0.
**      CLEAR fc_fakturno.
**      fc_subrc = 3.
**      EXIT.
**    ENDIF.
**
**  macro_faktur_formatting ld_fakno ld_fakturno.
**
**    IF NOT d_fpone IS INITIAL AND NOT d_fptwo IS INITIAL.
**      CONCATENATE d_fpone '-' d_fptwo '-'
**                  ld_fakno+13(7)
**                  INTO fc_fakturno.
**    ELSE.
**      MOVE ld_fakno+13(7) TO fc_fakturno.
**    ENDIF.


ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_COMMIT_SAVE
*&---------------------------------------------------------------------*
*&   This routine performs all faktur pajak data saving process in a
*&   DATABASE COMMIT process
*&---------------------------------------------------------------------*
FORM f_commit_save.

  PERFORM f_save_to_tables ON COMMIT.
  COMMIT WORK AND WAIT.

  IF NOT ( d_tcode = c_tcode_sederhana OR
           d_tcode = c_tcode_sederhana_single ). "CR009 16/04/2002
*---Display created Faktur pajak
    PERFORM f_popup_list
            USING 'F_WRITE_TAX_LIST'
                  'List of Created Faktur Pajak'
                  60
                  5
                  25
                  15
                  'X'.
  ENDIF.

ENDFORM.                    " F_COMMIT_SAVE

*&---------------------------------------------------------------------*
*&       FORM F_write_faktur_list                                      *
*&---------------------------------------------------------------------*
*&    This routine displays all created/amended faktur pajak
*&---------------------------------------------------------------------*
FORM f_write_tax_list.
  DATA: ld_fakturno(21),
        lv_faktur(20),
        lv_datab  TYPE sy-datum.

  DATA : lv_value        TYPE string,
         lv_pattern      TYPE string VALUE '++.++.++.+++-++++++++',
         lv_fakturno(21).

  DATA : gt_vat   LIKE zfvatnr_dtl OCCURS 0 WITH HEADER LINE.

  DATA ld_intensified.
  WRITE : / 'Tax Form Number Created' COLOR COL_HEADING.
  LOOP AT t_zgdtxdt0003.
    IF ld_intensified IS INITIAL.
      FORMAT INTENSIFIED ON.
      ld_intensified = 'X'.
    ELSE.
      FORMAT INTENSIFIED OFF.
      CLEAR ld_intensified.
    ENDIF.

    IF d_coretax <> 'X'.
      IF t_zgdtxdt0003-masatx(4) GT 2006.
        IF t_zgdtxdt0003-fakdat IN gr_coretax.
          lv_value  = t_zgdtxdt0003-fakturno.
          CALL FUNCTION 'ZFTAX_CHECK'
            EXPORTING
              pi_value   = lv_value
              pi_pattern = lv_pattern
              pi_length  = 17
            IMPORTING
              pe_value   = lv_value.
          lv_fakturno = lv_value.
*          WRITE / lv_fakturno COLOR COL_NORMAL.
        ELSE.
          CALL FUNCTION 'ZF_FAKTUR'
            EXPORTING
              bukrs     = t_zgdtxdt0003-bukrs
              fakdat    = t_zgdtxdt0003-fakdat
              masatx    = t_zgdtxdt0003-masatx
              fakturin  = t_zgdtxdt0003-fakturno
              tcode     = sy-tcode
            IMPORTING
              fakturout = ld_fakturno.
          WRITE / ld_fakturno COLOR COL_NORMAL.
        ENDIF.
      ELSE.
        WRITE / t_zgdtxdt0003-fakturno COLOR COL_NORMAL.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_write_tax_list

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*&    This routine prevents unauthorized users to process faktur pajak
*&---------------------------------------------------------------------*
*&    ->FU_VKORG    -  Sales Organization
*&    ->FU_GSBER    -  Business area
*&---------------------------------------------------------------------*
FORM f_authority_check USING fu_vkorg TYPE vkorg
                             fu_gsber TYPE gsber.

  macro_atz_single_vkorg fu_vkorg c_atz_display.
  macro_atz_single_gsber fu_gsber c_atz_display.

ENDFORM.                    " F_AUTHORITY_CHECK

*********************** BEGIN SPLIT PROCESS ***************************
*&---------------------------------------------------------------------*
*&       FORM f_split_collect_funit_item                               *
*&---------------------------------------------------------------------*
*&  This routine collects Faktur pajak item for Split process
*&---------------------------------------------------------------------*
*&  ->FT_ZGDTXDt0002   - Faktur pajak item data (billing)
*&  ->FT_FITEM           - Faktur pajak item in printing function
*&  ->FU_VKORG           - Sales organization
*&  ->FU_FAKTURNO        - Faktur pajak no.
*&  ->FU_FAKTUR_TYPE     - Faktur pajak type
*&  <-FC_SUBRC           - it will be <> 0 if failed
*&---------------------------------------------------------------------*
FORM f_split_collect_funit_item
     TABLES   ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002
              ft_fitem         STRUCTURE t_fitem
     USING    fu_vkorg         TYPE      vkorg
              fu_fakturno      LIKE      t_zgdtxdt0003-fakturno
              fu_faktur_type
     CHANGING fc_subrc         LIKE      sy-subrc.

  DATA : ld_tabix       LIKE sy-tabix,
         ld_tabix2      LIKE sy-tabix,
         ld_matnr       LIKE mara-matnr,
         ld_linenum     TYPE i,
         ld_fitem       LIKE ft_fitem,
         lt_zgdtxdt0002 LIKE ft_zgdtxdt0002 OCCURS 0
                          WITH HEADER LINE,
         ld_string(10).

  CLEAR fc_subrc.

  lt_zgdtxdt0002[] = ft_zgdtxdt0002[].
  CLEAR ld_linenum.

  LOOP AT lt_zgdtxdt0002
       WHERE fakturno EQ fu_fakturno AND
         NOT ppnlast  IS INITIAL     AND
             bilref   IS INITIAL.
*   Note: bilref is initial, which mean that reference number is empty,
*   so we only process billing that have normal type, not billing
*   return, or billing price adjustment, etc...!!

    ADD 1 TO ld_linenum.

*       If it is KKM/mkm Finish Unit, only can split by amount
    IF NOT fu_faktur_type = c_faktur_type_split_amount.
      fc_subrc = 4.
      EXIT.
    ENDIF.

    CLEAR ld_fitem.
    MOVE-CORRESPONDING lt_zgdtxdt0002 TO ld_fitem.
    WRITE lt_zgdtxdt0002-itqtylast TO ld_string
          DECIMALS 0 LEFT-JUSTIFIED.
    CONCATENATE ld_string c_split_unit lt_zgdtxdt0002-item
                INTO ld_fitem-item
                SEPARATED BY space.
    ft_fitem         = ld_fitem.
    ft_fitem-linenum = ld_linenum.
    APPEND ft_fitem.
  ENDLOOP.
ENDFORM.                    "f_split_collect_funit_item

*&---------------------------------------------------------------------*
*&       FORM f_splitcollect_sparepart_item
*&---------------------------------------------------------------------*
*&  This routine collects faktur pajak item for printing process,
*&  particularly for Spare part billing, since it only print 1 item :
*&  'Sparepart Terlampir'. This routine is only applicable for Split
*&  process
*&---------------------------------------------------------------------*
*&  ->FT_ZGDTXDt0002   - Faktur pajak item data (billing)
*&  ->FT_FITEM           - Faktur pajak item for printing function
*&  ->FU_FAKTURNO        - Faktur pajak no.
*&---------------------------------------------------------------------*
FORM f_split_collect_sparepart_item
     TABLES   ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002
              ft_fitem         STRUCTURE t_fitem
     USING    fu_fakturno.

  DATA : ld_linenum TYPE i,
         ld_fitem   LIKE ft_fitem.

  SORT ft_zgdtxdt0002 BY fakturno vbeln posnr.

  ld_fitem-fakturno = ft_zgdtxdt0002-fakturno.
  ld_fitem-vbeln    = ft_zgdtxdt0002-vbeln.
  ld_fitem-matnr    = ft_zgdtxdt0002-matnr.
  ld_fitem-item     = ft_zgdtxdt0002-item.
  CLEAR ld_linenum.

  LOOP AT ft_zgdtxdt0002
       WHERE fakturno EQ  fu_fakturno AND
         NOT ppnlast  IS INITIAL      AND
             bilref   IS INITIAL.
*   Note: bilref is initial, which mean that reference number is empty,
*   so we only process billing that have normal type, not billing
*   return, or billing price adjustment, etc...!!

    ADD ft_zgdtxdt0002-itqtylast
        TO ld_fitem-itqtylast.
    ADD ft_zgdtxdt0002-itamtlast
        TO ld_fitem-itamtlast.
    ADD ft_zgdtxdt0002-itdisclast
        TO ld_fitem-itdisclast.
    ADD ft_zgdtxdt0002-dpplast
        TO ld_fitem-dpplast.
    ADD ft_zgdtxdt0002-ppnlast
        TO ld_fitem-ppnlast.
    ADD ft_zgdtxdt0002-xppnbmlast
        TO ld_fitem-xppnbmlast.

  ENDLOOP.
  IF NOT ld_fitem IS INITIAL.
    ft_fitem = ld_fitem.
    CLEAR ft_fitem-linenum.
    ADD 1 TO ft_fitem-linenum.
    ft_fitem-item = c_split_sparepart.
    APPEND ft_fitem.
  ENDIF.
ENDFORM.                    "f_split_collect_sparepart_item

*&---------------------------------------------------------------------*
*&       FORM f_split_collect_service_item                             *
*&---------------------------------------------------------------------*
*&  This routine collects faktur pajak item for printing process,
*&  particularly for Service billing. This routine is only applicable
*&  for Split process
*&---------------------------------------------------------------------*
*&  ->FT_ZGDTXDt0002   - Faktur pajak item data (billing)
*&  ->FT_FITEM           - Faktur pajak item for printing function
*&  ->FU_FAKTURNO        - Faktur pajak no.
*&---------------------------------------------------------------------*
FORM f_split_collect_service_item
     TABLES   ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002
              ft_fitem         STRUCTURE t_fitem
     USING    fu_fakturno.

  DATA : ld_linenum TYPE i,
         ld_fitem   LIKE ft_fitem.
  CLEAR ft_zgdtxdt0002.
  CLEAR ld_linenum.
  READ TABLE ft_zgdtxdt0002 WITH KEY fakturno = fu_fakturno.

  IF ft_zgdtxdt0002-pstyv = c_pstyv_parts.
*   Do sparepart collect if item category = Spareparts !
*   this billing is for service division for its sparepart
    PERFORM f_split_collect_sparepart_item
            TABLES   ft_zgdtxdt0002
                     ft_fitem
            USING    fu_fakturno.
    EXIT.
  ENDIF.

  CLEAR ft_zgdtxdt0002.
  READ TABLE ft_zgdtxdt0002 WITH KEY fakturno = fu_fakturno.
  ld_fitem-fakturno = ft_zgdtxdt0002-fakturno.
  ld_fitem-vbeln    = ft_zgdtxdt0002-vbeln.
  ld_fitem-matnr    = ft_zgdtxdt0002-matnr.
  ld_fitem-item     = ft_zgdtxdt0002-item.

  LOOP AT ft_zgdtxdt0002
       WHERE fakturno EQ fu_fakturno AND
         NOT ppnlast  IS INITIAL     AND
             bilref   IS INITIAL.

    ADD ft_zgdtxdt0002-itqtylast  TO ld_fitem-itqtylast.
    ADD ft_zgdtxdt0002-itamtlast  TO ld_fitem-itamtlast.
    ADD ft_zgdtxdt0002-itdisclast TO ld_fitem-itdisclast.
    ADD ft_zgdtxdt0002-dpplast    TO ld_fitem-dpplast.
    ADD ft_zgdtxdt0002-ppnlast    TO ld_fitem-ppnlast.
    ADD ft_zgdtxdt0002-xppnbmlast TO ld_fitem-xppnbmlast.

  ENDLOOP.
  IF NOT ld_fitem IS INITIAL.
    ft_fitem = ld_fitem.
    CLEAR ft_fitem-linenum.
    ADD 1 TO ft_fitem-linenum.
    ft_fitem-item = c_split_serv_jasa1.
    APPEND ft_fitem.

    CLEAR ft_fitem.
    ft_fitem-fakturno = ld_fitem-fakturno.
    CONCATENATE 'NO'  ft_zgdtxdt0002-kwitansi
                'TGL' ft_zgdtxdt0002-erdt2
                INTO ft_fitem-item
                SEPARATED BY space.
    APPEND ft_fitem.

    CLEAR ft_fitem.
    ft_fitem-fakturno = ld_fitem-fakturno.
    ft_fitem-item     = c_split_serv_jasa2.
    APPEND ft_fitem.
  ENDIF.
ENDFORM.                    "f_split_collect_service_item

*&---------------------------------------------------------------------*
*&       FORM f_prepare_split_to_display                               *
*&---------------------------------------------------------------------*
*&  This routine prepares all selected billing to process their tax
*&  form/faktur pajak. It will process data in ZGDTXDt0002 &
*&  ZGDTXDt0003 formats to build mandatory 5 internal tables for
*&  printing function. This routine is only applicable for SPLIT PROCESS
*&  (ZGDTX_E00004 program)
*&---------------------------------------------------------------------*
*&  ->FT_ZGDTXDt0002   - Faktur pajak item data (billing)
*&  ->FT_ZGDTXDt0003   - Faktur pajak header data
*&  <-FT_FPKP            - Faktur pajak PKP data
*&  <-FT_FCUSTOMER       - Faktur pajak customer data
*&  <-FT_FITEM           - Faktur pajak item data
*&  <-FT_FSIGNATURE      - Faktur pajak signature data
*&  <-FT_FTAX            - Faktur pajak tariff data
*&---------------------------------------------------------------------*
FORM f_prepare_split_to_display
     TABLES   ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002  "Source
              ft_zgdtxdt0003 STRUCTURE t_zgdtxdt0003  "Source
              ft_fpkp          STRUCTURE t_fpkp           "Target
              ft_fcustomer     STRUCTURE t_fcustomer      "Target
              ft_fitem         STRUCTURE t_fitem          "Target
              ft_fsignature    STRUCTURE t_fsignature     "Target
              ft_ftax          STRUCTURE t_ftax           "Target
     CHANGING fc_subrc         LIKE      sy-subrc.

  REFRESH: t_fpkp,        "structure ZGDTXst0001
           t_fcustomer,   "structure ZGDTXst0002
           t_fitem,       "structure ZGDTXst0003
           t_fsignature,  "structure ZGDTXst0004
           t_ftax.        "structure ZGDTXst0006
  CLEAR:   t_fpkp,
           t_fcustomer,
           t_fitem,
           t_fsignature,
           t_ftax,
           fc_subrc.

  SORT: ft_zgdtxdt0003 BY fakturno,
        ft_zgdtxdt0002 BY fakturno vbeln posnr.

*  IF d_wheeler_type_com IS INITIAL.
*    READ TABLE ft_ZGDTXdt0003 INDEX 1.
*    IF sy-subrc = 0.
*      PERFORM f_set_global_values_bukrs USING ft_ZGDTXdt0003-vkorg.
*    ENDIF.
*  ENDIF.

  LOOP AT ft_zgdtxdt0003
       WHERE faktur_type = c_faktur_type_split_amount OR
             faktur_type = c_faktur_type_split_item   OR
             faktur_type = c_faktur_type_split_qty.

    CLEAR ft_zgdtxdt0002.
    READ TABLE ft_zgdtxdt0002
         WITH KEY fakturno = ft_zgdtxdt0003-fakturno.

*   1. Build PKP Table.
    PERFORM f_filling_pkp_satuan
            USING ft_zgdtxdt0002
                  ft_zgdtxdt0003-faktur_type
                  ft_zgdtxdt0003-wapu
                  ft_zgdtxdt0003-gsber
                  ft_zgdtxdt0003-brnch
                  ft_zgdtxdt0003-busln
                  ft_zgdtxdt0003-bukrs
                  ' '.

*   2. Building Customer Table
    PERFORM f_filling_customer_satuan  USING ft_zgdtxdt0003.

*   3. Building Signature Table
    PERFORM f_filling_signature_satuan USING ft_zgdtxdt0003.

*   4. Build Item Table
    CASE ft_zgdtxdt0002-spart.
      WHEN d_fin_unit OR d_used OR d_truck.
        PERFORM f_split_collect_funit_item
                TABLES ft_zgdtxdt0002
                       ft_fitem
                USING  ft_zgdtxdt0002-vkorg
                       ft_zgdtxdt0003-fakturno
                       ft_zgdtxdt0003-faktur_type
                CHANGING fc_subrc.

      WHEN d_sparts.
        PERFORM f_split_collect_sparepart_item
                TABLES   ft_zgdtxdt0002
                         ft_fitem
                USING    ft_zgdtxdt0003-fakturno.

      WHEN d_service.
        PERFORM f_split_collect_service_item
                TABLES   ft_zgdtxdt0002
                         ft_fitem
                USING    ft_zgdtxdt0003-fakturno.
    ENDCASE.

*   5. Build Tax Table
    LOOP AT ft_zgdtxdt0002 WHERE fakturno = ft_zgdtxdt0003-fakturno.
      ft_ftax-fakturno  = ft_zgdtxdt0002-fakturno.
      ft_ftax-dpplast   = ft_zgdtxdt0002-dpplast.
      ft_ftax-fakppnbm  = ft_zgdtxdt0002-ppnbmlast.
      ft_ftax-tarifxpbm = ft_zgdtxdt0002-tarifxpbm.
      COLLECT ft_ftax.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "f_prepare_split_to_display
*********************** END OF SPLIT PROCESS ***************************

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_GAB_TO_DISPLAY
*&---------------------------------------------------------------------*
*&  This routine prepares all selected billing to process their tax
*&  form/faktur pajak, particulary for GABUNGAN/MERGED PROCESS.
*&  It will process data in ZGDTXDt0002 & ZGDTXDt0003 formats to
*&  build mandatory 5 internal tables for printing function.
*&---------------------------------------------------------------------*
*&  ->FT_ZGDTXDt0002   - Faktur pajak item data (billing)
*&  ->FT_ZGDTXDt0003   - Faktur pajak header data
*&---------------------------------------------------------------------*
FORM f_prepare_gab_to_display TABLES ft_00002 STRUCTURE zgdtxdt0002
                                     ft_00003 STRUCTURE zgdtxdt0003
                              USING  fu_flag.

  DATA: ld_code  LIKE t_vbrkscr-code,
        lt_item  LIKE t_vbrk_gab OCCURS 0 WITH HEADER LINE,
        ld_fakno LIKE zgdtxdt0002-fakturno,
        lt_00002 LIKE ft_00002 OCCURS 0 WITH HEADER LINE,
        ld_line  TYPE i,
        ld_tabix LIKE sy-tabix.

  CLEAR  : t_vbrk_gab, lt_item,
           t_fpkp, t_fcustomer, t_fitem,
           t_fsignature, t_ftax, ld_tabix.
  REFRESH: t_vbrk_gab, lt_item,
           t_fpkp, t_fcustomer, t_fitem,
           t_fsignature, t_ftax.

  SORT ft_00002 BY fakturno vbeln posnr.
  SORT ft_00003 BY fakturno.
  DELETE ft_00002 WHERE bilref NE space.

  lt_00002[] = ft_00002[].

  LOOP AT ft_00002.
    ld_tabix = sy-tabix + 1.
    IF ft_00002-fakturno NE ld_fakno.

**** Commented out by Rahmadi ---not relevant & not generic
*** MAY NEED USER EXIT FOR CUSTOM LOGIC
*      IF ft_00002-spart EQ d_service.
*        CLEAR ld_line.
*        LOOP AT lt_00002 FROM ld_tabix
*                         WHERE fakturno EQ ft_00002-fakturno
*                           AND kwitansi NE ft_00002-kwitansi.
*          ld_line = c_kwitansi.
*          EXIT.
*        ENDLOOP.
*      ENDIF.
**** End of comment

      READ TABLE ft_00003 WITH KEY fakturno =  ft_00002-fakturno
                          BINARY SEARCH.
      PERFORM f_filling_pkp_satuan       USING ft_00002
                                               ft_00003-faktur_type
                                               ft_00003-wapu
                                               ft_00003-gsber
                                               ft_00003-brnch
                                               ft_00003-busln
                                               ft_00003-bukrs
                                               ld_line.
      PERFORM f_filling_customer_satuan  USING ft_00003.
      PERFORM f_filling_signature_satuan USING ft_00003.
      ld_fakno = ft_00002-fakturno.
    ENDIF.
    PERFORM f_pre_gab_vbrk TABLES ft_00002
                                  t_vbrk_gab
                           USING  fu_flag.

  ENDLOOP.

  DELETE t_tarif WHERE tarif = '000'.

  LOOP AT t_vbrk_gab.
****Added by Rahmadi
*---Determine Displayed & Saved items in Faktur Pajak based on the
*---Consolidation option selected
    CASE fu_flag.
      WHEN '1'.
        lt_item-vbeln      = t_vbrk_gab-vbeln.
        CLEAR lt_item-matnr.
      WHEN '2'.
        lt_item-matnr      = t_vbrk_gab-matnr.
        lt_item-item       = t_vbrk_gab-item.
        CLEAR lt_item-vbeln.
      WHEN '3'.
        lt_item-matnr      = t_vbrk_gab-matnr.
        lt_item-item       = t_vbrk_gab-item.
        lt_item-vbeln      = t_vbrk_gab-vbeln.
      WHEN '4'.
        CLEAR: lt_item-vbeln, lt_item-matnr,
               lt_item-item.
    ENDCASE.
****End of addition
    lt_item-fakno      = t_vbrk_gab-fakno.
    lt_item-vkorg      = t_vbrk_gab-vkorg.
    lt_item-pstyv      = t_vbrk_gab-pstyv.
    lt_item-spart      = t_vbrk_gab-spart.
    lt_item-fkimg      = t_vbrk_gab-fkimg.
    lt_item-itamtlast  = t_vbrk_gab-itamtlast.
    lt_item-itdisclast = t_vbrk_gab-itdisclast.
    lt_item-dpplast    = t_vbrk_gab-dpplast.

    lt_item-ppn2last   = t_vbrk_gab-ppn2last.
    lt_item-ppnlast    = t_vbrk_gab-ppnlast.
    lt_item-ppnbmlast  = t_vbrk_gab-ppnbmlast.
    lt_item-xppnbmlast = t_vbrk_gab-xppnbmlast.
    lt_item-waers      = t_vbrk_gab-waers.

    lt_item-itamt_f    = t_vbrk_gab-itamt_f.
    lt_item-itdisc_f   = t_vbrk_gab-itdisc_f.
    lt_item-dpp_f      = t_vbrk_gab-dpp_f.
    lt_item-ppn_f      = t_vbrk_gab-ppn_f.
    lt_item-ppnbm_f    = t_vbrk_gab-ppnbm_f.
    lt_item-xppnbm_f   = t_vbrk_gab-xppnbm_f.

    COLLECT lt_item.
  ENDLOOP.

  PERFORM f_pre_gab_fill_desc TABLES lt_item
                              USING  fu_flag.

ENDFORM.                    " F_PREPARE_GAB_TO_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  F_PRE_GAB_VBRK
*&---------------------------------------------------------------------*
*&  This routine merges all selected billing to process their tax
*&  form/faktur pajak, particulary for GABUNGAN/MERGED PROCESS.
*&---------------------------------------------------------------------*
*&  ->FT_VBRK       - Billing data
*&  ->FT_VBRK_GAB   - Merged billing data
*&---------------------------------------------------------------------*
FORM f_pre_gab_vbrk TABLES ft_vbrk     STRUCTURE zgdtxdt0002
                           ft_vbrk_gab STRUCTURE t_vbrk_gab
                    USING  fu_flag.

**** COmmented out by Rahmadi
*---Not Relevant & Not generic
**-- collect based on Billing number dan jenis.
*  IF ft_vbrk-spart = d_fin_unit.
*    IF ft_vbrk-karoseri NE d_karu AND ft_vbrk-vkorg EQ c_vkorg_kkm.
*      ft_vbrk-itqtylast = 0.
*    ENDIF.
*  ELSE.
*    t_vbrk_gab-itemdiv = ft_vbrk-itemdiv.
*    IF ft_vbrk-spart = d_service.
*      t_vbrk_gab-pstyv   = ft_vbrk-pstyv.
*    ENDIF.
*  ENDIF.
**** end of comment

***Added by Rahmadi
*--Determine displyed & saved items for Faktur pajak based on the
*--consolidation option selected
  CASE fu_flag.
    WHEN '1'.
      CLEAR t_vbrk_gab-matnr.
    WHEN '2'.
      t_vbrk_gab-matnr = ft_vbrk-matnr.
      t_vbrk_gab-item  = ft_vbrk-item.
      CLEAR t_vbrk_gab-vbeln.
    WHEN '3'.
      t_vbrk_gab-matnr = ft_vbrk-matnr.
      t_vbrk_gab-item  = ft_vbrk-item.
  ENDCASE.
***End of Addition

  t_vbrk_gab-vbeln       = ft_vbrk-vbeln.
  t_vbrk_gab-fakno       = ft_vbrk-fakturno.
  t_vbrk_gab-vkorg       = ft_vbrk-vkorg.
  t_vbrk_gab-spart       = ft_vbrk-spart.
  t_vbrk_gab-fkimg       = ft_vbrk-itqtylast.
  t_vbrk_gab-itdisclast  = ft_vbrk-itdisclast.
  t_vbrk_gab-dpplast     = ft_vbrk-dpplast.
*PPN without rounding
  t_vbrk_gab-ppn2last    = ft_vbrk-ppn2last.

  t_vbrk_gab-ppnlast     = ft_vbrk-ppnlast.
  t_vbrk_gab-ppnbmlast   = ft_vbrk-ppnbmlast.
  t_vbrk_gab-xppnbmlast  = ft_vbrk-xppnbmlast.
  t_vbrk_gab-waers       = ft_vbrk-itcurr.
  t_vbrk_gab-itamtlast   = ft_vbrk-itamtlast.
  t_vbrk_gab-itdisclast  = ft_vbrk-itdisclast.

  t_vbrk_gab-itamt_f     = ft_vbrk-itamt_f.
  t_vbrk_gab-itdisc_f    = ft_vbrk-itdisc_f.
  t_vbrk_gab-dpp_f       = ft_vbrk-dpp_f.
  t_vbrk_gab-ppn_f       = ft_vbrk-ppn_f.
  t_vbrk_gab-ppnbm_f     = ft_vbrk-ppnbm_f.
  t_vbrk_gab-xppnbm_f    = ft_vbrk-xppnbm_f.

  COLLECT t_vbrk_gab.

***Modified by Rahmadi
*--Tarif XPBM is relevant only for PPNBM (luxury) taxable items
  IF ft_vbrk-ppnbmlast <> 0.
    t_tarif-fakno          = ft_vbrk-fakturno.
    t_tarif-tarif          = ft_vbrk-tarifxpbm.
    t_tarif-dpplast        = ft_vbrk-dpplast.
    t_tarif-ppnbmlast      = ft_vbrk-ppnbmlast.
    COLLECT t_tarif.
  ENDIF.
***End of modification

ENDFORM.                    " F_PRE_GAB_VBRK

*&---------------------------------------------------------------------*
*&      Form  F_PRE_GAB_FILL_DESC
*&---------------------------------------------------------------------*
*&  This routine fills item description to be displayed in Faktur pajak,
*&  particularly for GABUNGAN/MERGED PROCESS
*&---------------------------------------------------------------------*
*&  ->FT_ITEM       - Faktur pajak item data
*&---------------------------------------------------------------------*
* Requires cleanup Rama
FORM f_pre_gab_fill_desc TABLES ft_item STRUCTURE t_vbrk_gab
                         USING  fu_flag.

  DATA: ld_name(10)    TYPE c,
        ld_quantity(5) TYPE n,
        ld_tabix(3),
        ld_spaces(60),
        ld_pos         TYPE i,
        ld_pos1        TYPE i,
        ld_pos2        TYPE i,
        ld_service     LIKE t_vbrk-vbeln,
        ld_part        LIKE t_vbrk-vbeln,
        lt_vbrk_gab    LIKE t_vbrk_gab OCCURS 0 WITH HEADER LINE,
        ld_prcpiece    LIKE t_vbrk_gab-itamtlast,
        ld_piechar(15).

  CLEAR ld_tabix.

**** Removed by Rahmadi
*** MAY NEED TO PUT USER EXIT FOR CUSTOM LOGIC
*--to get first bil number for print prev to part
*  REFRESH lt_vbrk_gab. CLEAR lt_vbrk_gab.
*  lt_vbrk_gab[] = t_vbrk_gab[].
*  DELETE lt_vbrk_gab WHERE pstyv NE c_pstyv_parts  AND
*                           pstyv NE c_pstyv_parts1 AND
*                           pstyv NE c_pstyv_parts2 AND
*                           pstyv NE c_pstyv_parts3 AND
*                           pstyv NE c_pstyv_parts4.
*
*  IF NOT lt_vbrk_gab[] IS INITIAL.
*    SORT lt_vbrk_gab BY vbeln ASCENDING.
*    READ TABLE lt_vbrk_gab INDEX 1.
*    ld_part = lt_vbrk_gab-vbeln.
*  ENDIF.
*
**--to get first bil number for print prev to service
*  REFRESH lt_vbrk_gab. CLEAR lt_vbrk_gab.
*  lt_vbrk_gab[] = t_vbrk_gab[].
*  DELETE lt_vbrk_gab WHERE pstyv NE c_pstyv_service.
*  IF NOT lt_vbrk_gab[] IS INITIAL.
*    SORT lt_vbrk_gab BY vbeln ASCENDING.
*    READ TABLE lt_vbrk_gab INDEX 1.
*    ld_service = lt_vbrk_gab-vbeln.
*  ENDIF.
*
**--to get first bil number for print prev to contract
*  REFRESH lt_vbrk_gab. CLEAR lt_vbrk_gab.
*  lt_vbrk_gab[] = t_vbrk_gab[].
*  DELETE lt_vbrk_gab WHERE pstyv NE c_pstyv_contr AND
*                           pstyv NE c_pstyv_contr1.
*
*  IF NOT lt_vbrk_gab[] IS INITIAL.
*    SORT lt_vbrk_gab BY vbeln ASCENDING.
*    READ TABLE lt_vbrk_gab INDEX 1.
*    ld_service = lt_vbrk_gab-vbeln.
*  ENDIF.
*** End of removal


  LOOP AT ft_item.
    ADD 1 TO ld_tabix.
    IF t_fitem-fakturno NE ft_item-fakno.
      t_fitem-fakturno = ft_item-fakno.
      ld_tabix = 1.
    ENDIF.
****Added by Rahmadi
*---Determine on how to display items in Faktur Pajak based on the
*---selected invoice consolidation option
    CASE fu_flag.
      WHEN '1'.
        t_fitem-vbeln      = ft_item-vbeln.
      WHEN '2'.
        t_fitem-matnr      = ft_item-matnr.
        t_fitem-item       = ft_item-item.
        CLEAR t_fitem-vbeln.
      WHEN '3'.
        t_fitem-matnr      = ft_item-matnr.
        t_fitem-item       = ft_item-item.
        t_fitem-vbeln      = ft_item-vbeln.
      WHEN '4'.
        CLEAR: t_fitem-vbeln, t_fitem-matnr,
               t_fitem-item.
    ENDCASE.
****End of addition
    t_fitem-linenum    = ld_tabix.
    t_fitem-itqtylast  = ft_item-fkimg.
    t_fitem-itamtlast  = ft_item-itamtlast.
    t_fitem-itdisclast = ft_item-itdisclast.
    t_fitem-dpplast    = ft_item-dpplast.
    t_fitem-ppnlast    = ft_item-ppnlast.
    t_fitem-xppnbmlast = ft_item-xppnbmlast.
*
    t_fitem-itamt_f    = ft_item-itamt_f.
    t_fitem-itdisc_f   = ft_item-itdisc_f.
    t_fitem-dpp_f      = ft_item-dpp_f.
    t_fitem-ppn_f      = ft_item-ppn_f.
    t_fitem-xppnbm_f   = ft_item-xppnbm_f.

****Added by Rahmadi
*---Display items in Faktur Pajak based on selected invoice
*---consolidation option
    ld_prcpiece = t_fitem-itamtlast / t_fitem-itqtylast.

    WRITE: t_fitem-itqtylast TO ld_quantity DECIMALS 0,
           ld_prcpiece TO ld_piechar CURRENCY ft_item-waers.
    CASE fu_flag.
      WHEN '1'.
        t_fitem-item+0(10) = t_fitem-vbeln.
        t_fitem-item+11(3) = ' - '.
        t_fitem-item+14(30) = d_smtxt.
        t_fitem-item+45(5) = ld_quantity.
        t_fitem-item+50(10) = d_smtxt1.
        t_fitem-item+61(10) = d_smtxt2.
      WHEN '2'.
        PERFORM f_reduce_spaces USING    d_smtxt
                                         10
                                         ''
                                CHANGING ld_pos.
        ld_pos1 = ld_pos + 50.
        d_smtxt1 = ld_piechar.
        t_fitem-item+45(5) = ld_quantity.
        t_fitem-item+50(ld_pos) = d_smtxt.
        t_fitem-item+ld_pos1(15) = d_smtxt1.
      WHEN '3'.
        PERFORM f_reduce_spaces USING    d_smtxt
                                         10
                                         ''
                                CHANGING ld_pos.
        CONCATENATE
                    t_fitem-vbeln
                    '-'
                    t_fitem-item
                    INTO t_fitem-item
                    SEPARATED BY space.
        ld_pos1 = ld_pos + 50.
        d_smtxt1 = ld_piechar.
        t_fitem-item+45(5) = ld_quantity.
        t_fitem-item+50(ld_pos) = d_smtxt.
        t_fitem-item+ld_pos1(15) = d_smtxt1.
      WHEN '4'.
        t_fitem-item+0(10) = d_smtxt.
        t_fitem-item+11(10) = d_smtxt1.
        t_fitem-item+21(30) = d_smtxt2.
    ENDCASE.
****End of addition

*** Commented out by Rahmadi due to text generalization
*** MAY NEED TO PUT USER EXIT FOR CUSTOM LOGIC
*    IF ft_item-spart = d_fin_unit.
**----- UNIT
*      IF ft_item-vkorg = c_vkorg_kkm.
*        ld_name = c_prctr20.
*
*      ELSEIF ft_item-vkorg = c_vkorg_mkm.
*        ld_name = c_prctr30.
*
*      ELSEIF ft_item-vkorg = c_vkorg_ktb.
*        ld_name = c_prctr10.
*      ENDIF.
*
*      WRITE: t_fitem-itqtylast TO ld_quantity DECIMALS 0.
*      CONCATENATE ld_quantity c_gab_unit1 ld_name c_gab_unit2
*                  INTO t_fitem-item SEPARATED BY space.
*
*    ELSEIF ft_item-spart = d_truck.
*      ld_name = c_prctr30.
*      WRITE: t_fitem-itqtylast TO ld_quantity DECIMALS 0.
*      CONCATENATE ld_quantity c_gab_unit1 ld_name c_gab_unit2
*                  INTO t_fitem-item SEPARATED BY space.
*
*    ELSEIF ft_item-spart = d_sparts.
*
**----- SPAREPART
*      t_fitem-item = c_gab_sparepart.
*    ELSEIF ft_item-spart = d_service.
*
**----- SERVICE
*      IF ( ft_item-pstyv = c_pstyv_parts )  OR
*         ( ft_item-pstyv = c_pstyv_parts1 ) OR
*         ( ft_item-pstyv = c_pstyv_parts2 ) OR
*
*         ( ft_item-pstyv = c_pstyv_parts3 ) OR
*         ( ft_item-pstyv = c_pstyv_parts4 ).
*
*        t_fitem-item = c_gab_serv_part1.
*        APPEND t_fitem.
*        CLEAR t_fitem.
*        t_fitem-fakturno = ft_item-fakno.
*        t_fitem-item     = c_gab_serv_part2.
*        CONCATENATE c_gab_serv_part2 ld_part c_trlp
*                    INTO t_fitem-item SEPARATED BY space.
*      ELSEIF ft_item-pstyv = c_pstyv_service OR
*             ft_item-pstyv = c_pstyv_service1.
*        t_fitem-item = c_gab_serv_jasa1.
*        APPEND t_fitem.
*        CLEAR t_fitem.
*        t_fitem-fakturno = ft_item-fakno.
*        CONCATENATE c_gab_serv_part2 ld_service c_trlp
*                    INTO t_fitem-item SEPARATED BY space.
*      ELSEIF ft_item-pstyv = c_pstyv_contr.
*        t_fitem-item = c_gab_serv_contr.
*        APPEND t_fitem.
*        CLEAR t_fitem.
*        t_fitem-fakturno = ft_item-fakno.
*        CONCATENATE c_gab_serv_part2 ld_service c_trlp
*                    INTO t_fitem-item SEPARATED BY space.
*      ENDIF.
*    ENDIF.
**** End of comment

    APPEND t_fitem.

  ENDLOOP.

*-- prepare data for tarif
  LOOP AT t_tarif.
    t_ftax-fakturno   = t_tarif-fakno.
    t_ftax-dpplast    = t_tarif-dpplast.
    t_ftax-fakppnbm   = t_tarif-ppnbmlast.
    t_ftax-tarifxpbm  = t_tarif-tarif.
    APPEND t_ftax.
  ENDLOOP.

ENDFORM.                    " F_PRE_GAB_FILL_DESC

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_LOCKED_NORM_BILLING
*&---------------------------------------------------------------------*
*&  This routine marks a billing as an erroneous billing if it is locked
*&  by another user
*&---------------------------------------------------------------------*
*&  ->FT_VBRK       - Billing data
*&  ->FU_USER       - The locking user
*&  ->FU_SUBRC      - Error mode
*&                    1    - if locked by another user,
*&                    2,3  - another errors
*&---------------------------------------------------------------------*
FORM f_process_locked_norm_billing USING fu_vbrk LIKE t_vbrk
                                         fu_user
                                         fu_subrc.

  IF fu_subrc = 1.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    CONCATENATE 'Billing is locked by' fu_user INTO t_error-msg
                                       SEPARATED BY space.
    APPEND t_error.
  ELSEIF fu_subrc = 2 OR fu_subrc = 3.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    t_error-msg = 'Error when processing the billing'.
    APPEND t_error.
  ENDIF.

ENDFORM.                    " F_PROCESS_LOCKED_NORM_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_LOCKED_FOLL_BILLING
*&---------------------------------------------------------------------*
*&  This routine marks a billing as an erroneous billing if its follow-
*&  up billing is locked by another user
*&---------------------------------------------------------------------*
*&  ->FT_VBRK       - Follow-up Billing data
*&  ->FU_VBFA       - Billing history data to get the original billing
*&  ->FU_USER       - The locking user
*&  ->FU_SUBRC      - Error mode
*&                    1    - if locked by another user,
*&                    2,3  - another errors
*&---------------------------------------------------------------------*
FORM f_process_locked_foll_billing TABLES   ft_vbrk STRUCTURE t_vbrk
                                   USING    fu_vbfa LIKE t_vbfaa
                                            fu_user
                                            fu_subrc.

  IF fu_subrc <> 0.
    READ TABLE ft_vbrk WITH KEY vbeln = fu_vbfa-vbelv
                       BINARY SEARCH.
    IF fu_subrc = 1.
      MOVE-CORRESPONDING ft_vbrk TO t_error.
      CONCATENATE 'Its follow-up billing' fu_vbfa-vbeln
                  'is locked by' fu_user
                   INTO t_error-msg SEPARATED BY space.
      APPEND t_error.
    ELSEIF fu_subrc = 2 OR
           fu_subrc = 3.
      MOVE-CORRESPONDING ft_vbrk TO t_error.
      CONCATENATE 'Error when processing its follow-up billing'
                  fu_vbfa-vbeln
                  INTO t_error-msg SEPARATED BY space.
      APPEND t_error.
    ENDIF.
    DELETE ft_vbrk WHERE vbeln = fu_vbfa-vbelv.
  ENDIF.

ENDFORM.                    " F_PROCESS_LOCKED_FOLL_BILLING

*&---------------------------------------------------------------------*
*&       FORM f_on_help_request                                        *
*&---------------------------------------------------------------------*
*&   This routine displays additional info for a displayed field in
*&   the main screen
*&---------------------------------------------------------------------*
*&  ->FU_TITLE      - Info title
*&  ->FU_TEXT       - Text object for the description
*&---------------------------------------------------------------------*
FORM f_on_help_request
     USING fu_title
           fu_text_object LIKE dokhl-object.
  CALL FUNCTION 'POPUP_DISPLAY_TEXT'
    EXPORTING
      language       = sy-langu
      popup_title    = fu_title
      start_column   = 10
      start_row      = 3
      text_object    = fu_text_object
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
ENDFORM.                    "f_on_help_request
*&---------------------------------------------------------------------*
*&      Form  F_FILLING_UP_ADDT_INFO
*&---------------------------------------------------------------------*
*&  This routine duplicates additional info in normal billings to its
*&  follow-up documents (to be saved in ZGDTXDt0002 table)
*&---------------------------------------------------------------------*
*&  ->FU_VBRK      - Normal Billing data
*&  ->FC_VBRKF     - Follow-up document data
*&---------------------------------------------------------------------*
FORM f_filling_up_addt_info USING    fu_vbrk LIKE t_vbrk
                            CHANGING fc_vbrkf LIKE t_vbrkf.

**Get KAROSERI
  fc_vbrkf-karoseri = fu_vbrk-karoseri.
  fc_vbrkf-itemdiv = fu_vbrk-itemdiv.

**Get EQUIPMENT
  fc_vbrkf-th_buat = fu_vbrk-th_buat.
  fc_vbrkf-mesin = fu_vbrk-mesin.

**Get FAKTUR DATE
  fc_vbrkf-fakdat = fu_vbrk-fakdat.

**Get MASATX
  fc_vbrkf-masatx = fu_vbrk-masatx.
  fc_vbrkf-gjahr = fu_vbrk-gjahr.

**Get WAPU
  fc_vbrkf-wapu = fu_vbrk-wapu.

**Get Customer name
  fc_vbrkf-name = fu_vbrk-name.

ENDFORM.                    " F_FILLING_UP_ADDT_INFO

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NPWP_SEDERHANA
*&---------------------------------------------------------------------*
*&  This routine checks whether the processed billing has valid NPWP
*&  data, particularly for SIMPLE/SEDERHANA PROCESS.
*&  Sederhana process only allow billing with NPWP less than 10 digits
*&  to process
*&---------------------------------------------------------------------*
*&  ->FU_VBRK       - Billing data
*&  ->FU_SUBRC      - it will be <> 0 if the condition is not fulfilled
*&---------------------------------------------------------------------*
FORM f_check_npwp_sederhana USING fu_vbrk LIKE t_vbrk
                         CHANGING fc_subrc.

  DATA ld_length TYPE i.

  ld_length = strlen( fu_vbrk-stceg ).
  IF ld_length > 10.
    fc_subrc = 2.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    CONCATENATE 'The customer has NPWP,'
                'Proses Sederhana cannot be used'
                INTO t_error-msg SEPARATED BY space.
    APPEND t_error.
  ELSE.
    fc_subrc = 0.
  ENDIF.

ENDFORM.                    " F_CHECK_NPWP_SEDERHANA

*&---------------------------------------------------------------------*
*&      Form  F_GET_RPC_FAKTUR_NO
*&---------------------------------------------------------------------*
*&      This routine is only applicable if the program is executed by
*&      RPC program. The purpose is to get faktur pajak number for
*&      all the billings corrected by RPC program
*&---------------------------------------------------------------------*
*&     ->FU_VBELN        - Billing number
*&     ->FU_POSNR        - Billing item number
*&     ->FU_SPART        - Division, search key depends on division
*&     ->FU_FAKTUR_TYPE  - Faktur type, search key depends on fak.type
*&     ->FU_DELETE       - Read records should be deleted from itab
*&     <-FC_FAKTURNO     - Faktur pajak number
*&     <-FC_SUBRC        - Error: FC_SUBRC <> 0
*----------------------------------------------------------------------*
FORM f_get_rpc_faktur_no USING    fu_vbeln
                                  fu_posnr
                                  fu_spart
****added by Rahmadi
*---Consider invoice consolidation option
                                  fu_flag
****end of addition
                                  fu_faktur_type
                                  fu_delete
                         CHANGING fc_fakturno
                                  fc_subrc.

****modified by Rahmadi
*  IF fu_spart = d_sparts.
**---Since only one line is saved in ZGDTXDt0002 for each billing for
**   spare parts, the search key will only be billing no.

*---Consolidated by Invoice -- all materials will be saved into 1 line
*   Selection based on invoice
  IF fu_flag = '1'.
****end of modification
    READ TABLE t_process WITH KEY vbeln = fu_vbeln
                                  BINARY SEARCH.
    fc_subrc = sy-subrc.
    IF fc_subrc = 0.
      fc_fakturno = t_process-fakturno.
      IF NOT fu_delete IS INITIAL.
        DELETE t_process WHERE fakturno = fc_fakturno.
      ENDIF.
    ELSE.
      CLEAR fc_fakturno.
    ENDIF.
  ELSE.
    IF fu_faktur_type = c_faktur_type_satuan OR
       fu_faktur_type = c_faktur_type_gabungan.
      READ TABLE t_process WITH KEY vbeln = fu_vbeln
                                    posnr = fu_posnr
                                    BINARY SEARCH.
      fc_subrc = sy-subrc.
      IF fc_subrc = 0.
        fc_fakturno = t_process-fakturno.
        IF NOT fu_delete IS INITIAL.
          DELETE t_process WHERE fakturno = fc_fakturno.
        ENDIF.
      ELSE.
        CLEAR fc_fakturno.
      ENDIF.
    ELSE.
      READ TABLE t_process WITH KEY vbeln = fu_vbeln
                                    BINARY SEARCH.
      fc_subrc = sy-subrc.
      IF fc_subrc = 0.
        fc_fakturno = t_process-fakturno.
        IF NOT fu_delete IS INITIAL.
          DELETE t_process WHERE fakturno = fc_fakturno.
        ENDIF.
      ELSE.
        CLEAR fc_fakturno.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_RPC_FAKTUR_NO

*&---------------------------------------------------------------------*
*&       FORM f_name_formatting                                        *
*&---------------------------------------------------------------------*
*&    This routine converts name displayed on the screen to upper/lower
*&    case form
*&---------------------------------------------------------------------*
*&  ->FU_NAME   - Name to be formatted
*&  <-FC_FNAME  - Formatted name
*&---------------------------------------------------------------------*
FORM f_name_formatting USING VALUE(fu_name)
                       CHANGING fc_fname.

  DATA: BEGIN OF lt_word OCCURS 1,
          word(40),
        END OF lt_word.
  DATA ld_fname(40).
  DATA ld_lword LIKE sy-tabix.
  DATA ld_tabix LIKE sy-tabix.

  CLEAR fc_fname.
  TRANSLATE fu_name TO LOWER CASE.
  SPLIT fu_name AT space INTO TABLE lt_word.
  DESCRIBE TABLE lt_word LINES ld_lword.
  ld_tabix = 1.
  DO.
    IF ld_tabix > ld_lword.
      EXIT.
    ELSE.
      LOOP AT lt_word FROM ld_tabix.
        TRANSLATE lt_word-word+0(1) TO UPPER CASE.
        ld_fname = lt_word-word.
        ld_tabix = ld_tabix + 1.
        EXIT.
      ENDLOOP.
      CONCATENATE fc_fname ld_fname
                  INTO fc_fname
                  SEPARATED BY space.
    ENDIF.
  ENDDO.

  SHIFT fc_fname LEFT DELETING LEADING space.

ENDFORM.                     " F_NAME_FORMATTING

*&---------------------------------------------------------------------*
*&      Form  F_GET_LAST_MONTH
*&---------------------------------------------------------------------*
*&    This routine gets last period (one month earlier)
*&---------------------------------------------------------------------*
*&  ->FU_MASATX   - Current period
*&  <-FC_MASATX   - Last period
*&---------------------------------------------------------------------*
FORM f_get_last_month USING    fu_masatx
                      CHANGING fc_masatx.

  DATA ld_year(4).
  DATA ld_month(2).
  DATA ld_lastmonth(2) TYPE n.

  ld_year = fu_masatx+0(4).
  ld_month = fu_masatx+4(2).
  ld_lastmonth = ld_month - 1.
  IF ld_lastmonth = '00'.
    ld_lastmonth = '12'.
    ld_year = ld_year - 1.
  ENDIF.
  CONCATENATE ld_year ld_lastmonth INTO fc_masatx.

ENDFORM.                    " F_GET_LAST_MONTH

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NPWP_CUST_MASTER
*&---------------------------------------------------------------------*
*&    This routine searches for valid NPWP from Customer master if the
*&    customer in the billing has no valid NPWP. If the customer is a
*&    one time customer, the program will then continue the search in
*&    sales order.
*&---------------------------------------------------------------------*
*&      ->FU_VBRK   - Billing data (with customer number)
*&      <-FC_SUBRC  - it'll be set to 1 if no valid NPWP found in
*&                    customer master, otherwise it will be 0
*&      <-FC_NPWP   - Customer master NPWP
*&---------------------------------------------------------------------*
FORM f_check_npwp_cust_master USING    fu_vbrk LIKE t_vbrk
                              CHANGING fc_subrc
                                       fc_npwp
                                       fc_xcpdk.

  DATA ld_length TYPE i.

  READ TABLE t_kna1 WITH KEY kunnr = fu_vbrk-kunrg
                    BINARY SEARCH.
  IF sy-subrc = 0.
    fc_npwp = t_kna1-stceg.
    fc_xcpdk = t_kna1-xcpdk.
    ld_length = strlen( t_kna1-stceg ).
    IF ld_length <= 10.
      fc_subrc = 1.
    ENDIF.
  ELSE.
    CLEAR: fc_npwp, fc_xcpdk.
    fc_subrc = 1.
  ENDIF.

ENDFORM.                    " F_CHECK_NPWP_CUST_MASTER

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NPWP_SALES_ORDER
*&---------------------------------------------------------------------*
*&    This routine searches for valid NPWP from Sales Order (Ship to
*&    party customer) if the customer in the billing and customer master
*&    has no valid NPWP (for ONE TIME CUSTOMER ONLY).
*&    This case is considered a rare case since one-time customer must
*&    have their account defined in Customer master whenever having
*&    transaction. Therefore, they should already have their NPWP
*&    defined in customer master/billing.
*&    This consideration brings to the usage of direct selection from
*&    database rather than reading from an  internal tables since it
*&    will minimize the effort to amend the logic change in the program.
*&---------------------------------------------------------------------*
*&      ->FU_VBRK   - Billing data (with customer number)
*&      <-FC_SUBRC  - it'll be set to 2 if no valid NPWP found in
*&                    sales order, otherwise it will be 0
*&      <-FC_NPWP   - Sales Order NPWP
*&---------------------------------------------------------------------*
FORM f_check_npwp_sales_order USING    fu_vbrk LIKE t_vbrk
                              CHANGING fc_subrc
                                       fc_npwp.

  DATA ld_length TYPE i.

  SELECT SINGLE stceg INTO fc_npwp
                      FROM vbpa
                      WHERE vbeln = fu_vbrk-aubel AND
                            parvw = d_ship_to_party.
  IF sy-subrc = 0.
    ld_length = strlen( fc_npwp ).
    IF ld_length <= 10.
      fc_subrc = 2.
    ELSE.
      fc_subrc = 0.
    ENDIF.
  ELSE.
    fc_subrc = 2.
  ENDIF.

ENDFORM.                    " F_CHECK_NPWP_SALES_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_SELECTED_DATA_CODE
*&---------------------------------------------------------------------*
*&    This routine is particularly used for GABUNGAN purpose to select
*&    several billings and merged it into several faktur pajak depends
*&    on how many codes defined for the faktur pajak
*&---------------------------------------------------------------------*
*&      <-FC_SUBRC  - it'll be set to 0 if the selection is valid
*&---------------------------------------------------------------------*
FORM f_selected_data_code CHANGING fc_subrc.
  DATA: ld_line     TYPE i,
        ld_code     LIKE t_vbrkscr1-code,
        ld_stceg    LIKE t_vbrkscr1-stceg,
        ld_tax      TYPE c,
        ld_npwp     LIKE t_vbrkscr1-stceg,
        lt_vbrkscr1 LIKE t_vbrkscr1 OCCURS 0 WITH HEADER LINE.

  CLEAR: ld_npwp, lt_vbrkscr1, ld_tax, ld_code, ld_line.

  DESCRIBE TABLE t_vbrkscr1 LINES ld_line.
  IF ld_line LT 2.
    fc_subrc = 4.
    MESSAGE s000(ztx) WITH 'Select another record for gabungan'.
  ELSE.
    lt_vbrkscr1[] = t_vbrkscr1[].
    SORT lt_vbrkscr1 BY code.

    CLEAR : ld_code, ld_stceg.
    LOOP AT lt_vbrkscr1.
      IF lt_vbrkscr1-code NE ld_code OR sy-tabix EQ 1.
        ld_code  = lt_vbrkscr1-code.
        ld_stceg = lt_vbrkscr1-stceg.
        ld_tax   = lt_vbrkscr1-tax.
      ELSE.
        IF lt_vbrkscr1-stceg NE ld_stceg.
          fc_subrc = 4.
          MESSAGE s000(ztx) WITH 'Can not proces in different NPWP'.
          EXIT.
        ELSEIF lt_vbrkscr1-tax NE ld_tax.
          fc_subrc = 4.
          MESSAGE s000(ztx) WITH 'Same item code, must be have same'
                                'include tax'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " F_SELECTED_DATA_CODE

*&---------------------------------------------------------------------*
*&      Form  F_GAB_CHECK_BE4_PREVIEW
*&---------------------------------------------------------------------*
*&    This routine is particularly used for GABUNGAN purpose to prevent
*&    erroneus billings displayed in the screen. Validation checked by
*&    this routine are as follows:
*&    - Billings having XPPNBM can not be merged togethet with billings
*&      having PPNBM.
*&    - A faktur pajak can only contain maximum 4 tariff variant, there-
*&      fore if merged billings contains more, they should be separated.
*&---------------------------------------------------------------------*
FORM f_gab_check_be4_preview.
  DATA : ld_lines TYPE i.

  DATA : BEGIN OF lt_group_ppn OCCURS 0,
           code    LIKE t_vbrkscr1-code,
           ppnbm   TYPE i,
           exppnbm TYPE i,
         END OF lt_group_ppn.

  DATA : BEGIN OF lt_group_tarif OCCURS 0,
           code      LIKE t_vbrkscr1-code,
           tarifxpbm LIKE t_vbrk-tarifxpbm,
         END OF lt_group_tarif.

  DATA : BEGIN OF lt_group_code OCCURS 0,
           code LIKE t_vbrkscr1-code,
           qty  TYPE i,
         END OF lt_group_code.

  CHECK d_subrc = 0.

  LOOP AT t_vbrk.

    CLEAR: lt_group_ppn-exppnbm, lt_group_ppn-ppnbm.
    READ TABLE t_vbrkscr1 WITH KEY vbeln = t_vbrk-vbeln
                          BINARY SEARCH.
    IF sy-subrc = 0.
*---- grouping tarif
      lt_group_tarif-code      = t_vbrkscr1-code.
      lt_group_tarif-tarifxpbm = t_vbrk-tarifxpbm.
      COLLECT lt_group_tarif.

*---- check ppnbm & exppnbm together in one faktur number
      lt_group_ppn-code     = t_vbrkscr1-code.
      IF t_vbrk-ppnbmlast NE 0.
        lt_group_ppn-ppnbm    = 1.
      ENDIF.

      IF t_vbrk-xppnbmlast NE 0.
        lt_group_ppn-exppnbm  = 1.
      ENDIF.

      COLLECT lt_group_ppn.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_group_tarif.
    lt_group_code-code = lt_group_tarif-code.
    lt_group_code-qty  = 1.
    COLLECT lt_group_code.
  ENDLOOP.

  DELETE lt_group_code WHERE qty LE 4.

  DESCRIBE TABLE lt_group_code LINES ld_lines.
  IF ld_lines NE 0.
    d_subrc = 3.
    MESSAGE i000(ztx) WITH 'Tarif more than 4 types'.
  ENDIF.

  DELETE lt_group_ppn WHERE ppnbm   EQ 0
                         OR exppnbm EQ 0.
  DESCRIBE TABLE lt_group_ppn LINES ld_lines.
  IF ld_lines NE 0.
    d_subrc = 3.
    MESSAGE s000(ztx) WITH 'Please split PPnBM and exPPnBM in'
                          'different code'.
  ENDIF.

ENDFORM.                    " F_GAB_CHECK_BE4_PREVIEW

*&---------------------------------------------------------------------*
*&      Form  F_GAB_FILL_00002_00003
*&---------------------------------------------------------------------*
*&    This routine is particularly used for GABUNGAN purpose to build
*&    records to be saved in ZGDTXDt0002 & ZGDTXDt0003 tables
*&    based on selected records on the screen
*&---------------------------------------------------------------------*
*&    ->FT_VBRKSCR    - Selected billings from the screen
*&    <-FT_TX00002    - Data prepared for ZGDTXDt0002 table
*&    <-FT_TX00003    - Data prepared for ZGDTXDt0003 table
*&    ->FU_ACTION     - Preview/Save
*&    ->FC_RPC        - Set to 'X' if executed by RPC program
*&---------------------------------------------------------------------*
FORM f_gab_fill_00002_00003 TABLES ft_vbrkscr STRUCTURE t_vbrkscr
                                   ft_tx00002 STRUCTURE t_zgdtxdt0002
                                   ft_tx00003 STRUCTURE t_zgdtxdt0003
                            USING  fu_action
                                   fc_rpc
                                   fc_spart
                                   fu_flag.

  DATA : ld_faktur_code LIKE zgdtxdt0002-fakturno,
         ld_faktur_rate LIKE zgdtxdt0003-fakrate,
         ld_bil_rate    LIKE zgdtxdt0003-bilrate,
         ld_subrc       LIKE sy-subrc,
         ld_code        LIKE t_vbrkscr1-code,
         ld_fakppn      LIKE zgdtxdt0003-fakppn,
         ld_fakxppnbm   LIKE zgdtxdt0003-fakxppnbm,
         ld_fakppnbm    LIKE zgdtxdt0003-fakppnbm,

         ld_fakppn_f    LIKE zgdtxdt0003-fakppn_f,
         ld_fakxppnbm_f LIKE zgdtxdt0003-fakxppnbm_f,
         ld_fakppnbm_f  LIKE zgdtxdt0003-fakppnbm_f,

         lt_vbrk        LIKE t_vbrk,
         ld_fakturno    LIKE zgdtxdt0002-fakturno,
         lt_tx00002     LIKE ft_tx00002 OCCURS 0 WITH HEADER LINE.

***Added by Rahmadi
*--Additional fields in ZGDTXDT0003 table
  DATA ld_fakdpp LIKE zgdtxdt0003-fakdpp.
  DATA ld_fakpph22 LIKE zgdtxdt0003-fakpph22.
  DATA ld_fakpph23 LIKE zgdtxdt0003-fakpph23.
***End of addition

  DATA : BEGIN OF lt_faktur OCCURS 0,
           code     LIKE t_vbrkscr1-code,
           fakturno LIKE zgdtxdt0002-fakturno,
         END OF lt_faktur.

  DATA lv_nocoretax TYPE zgdtxdt0003-nocoretax.

  CLEAR   : t_zgdtxdt0002, t_zgdtxdt0003, lt_faktur, d_aktif,
            ld_fakturno.
  REFRESH : t_zgdtxdt0002, t_zgdtxdt0003, lt_faktur.

  SORT t_vbrkscr1 BY code.
  SORT t_vbrk BY vbeln.

*-- select all normal billing from t_vbrk
  LOOP AT t_vbrkscr1.
    IF sy-tabix EQ 1 OR t_vbrkscr1-code NE lt_faktur-code.
      IF sy-tabix NE 1.
        PERFORM f_gab_fill_00003 TABLES ft_tx00003
                                 USING  lt_vbrk
                                        ld_fakturno
                                        ld_fakppn
                                        ld_fakxppnbm
                                        ld_fakppnbm
****added by Rahmadi
*---Store PPH 22, PPH 23 & Total DPP to ZGDTXDT0003
                                        ld_fakdpp
                                        ld_fakpph22
                                        ld_fakpph23
****end of addition
                                        ld_fakppn_f
                                        ld_fakxppnbm_f
                                        ld_fakppnbm_f
                                        fu_flag.   "added by Rahmadi
        CLEAR: ld_fakppn, ld_fakxppnbm, ld_fakppnbm,
               ld_fakdpp, ld_fakpph22, ld_fakpph23.
      ENDIF.

      IF fu_action = d_prev_first.
        IF fc_rpc IS INITIAL.
          lt_faktur-fakturno = lt_faktur-fakturno + 1.
          ld_fakturno        = lt_faktur-fakturno.
        ELSE.
          READ TABLE t_process WITH KEY vbeln = t_vbrkscr1.
          IF sy-subrc = 0.
            ld_fakturno = t_process-fakturno.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM f_get_faktur_no USING d_objrange
*                                      d_nr_gsber
                                      t_vbrkscr1-gsber
                                      d_nr_brnch
                                      d_nr_brnch
                                      t_vbrkscr1-masatx
                                      space
                                      t_vbrkscr1-fkdat
                                      t_vbrkscr1-vbeln
                             CHANGING lt_faktur-fakturno
                                      lv_nocoretax
                                      ld_subrc.
        IF ld_subrc = 0.
          ld_fakturno = lt_faktur-fakturno.
        ELSE.
          ld_fakturno = t_vbrkscr1-code.
        ENDIF.
      ENDIF.
      lt_faktur-code = t_vbrkscr1-code.
    ENDIF.

    LOOP AT t_vbrk WHERE vbeln = t_vbrkscr1-vbeln.
      MOVE-CORRESPONDING t_vbrk TO lt_vbrk.
      PERFORM f_gab_fill_00002 TABLES ft_tx00002
                                USING lt_vbrk
                                      t_vbrkscr1
                                      ld_fakturno
                                      fu_flag.  "added by Rahmadi

*-- Collec amounts
      ld_fakppn    = ld_fakppn    + lt_vbrk-ppnlast.
      ld_fakxppnbm = ld_fakxppnbm + lt_vbrk-xppnbmlast.
      ld_fakppnbm  = ld_fakppnbm  + lt_vbrk-ppnbmlast.

****added by Rahmadi
*----Store PPh 22, PPH 23 and DPP total to ZGDTXDT0003
      ld_fakpph22 = ld_fakpph22 + lt_vbrk-pph22.
      ld_fakpph23 = ld_fakpph23 + lt_vbrk-pph23.
      ld_fakdpp = ld_fakdpp + lt_vbrk-dpp.
****end of addition

      ld_fakppn_f    = ld_fakppn_f    + lt_vbrk-ppn_f.
      ld_fakxppnbm_f = ld_fakxppnbm_f + lt_vbrk-xppnbm_f.
      ld_fakppnbm_f  = ld_fakppnbm_f  + lt_vbrk-ppnbm_f.

    ENDLOOP.

    AT LAST.
      PERFORM f_gab_fill_00003 TABLES ft_tx00003
                               USING lt_vbrk
                                     ld_fakturno
                                     ld_fakppn
                                     ld_fakxppnbm
                                     ld_fakppnbm
****added by Rahmadi
*---Store PPH 22, PPH 23 and DPP total to ZGDTXDT0003
                                     ld_fakdpp
                                     ld_fakpph22
                                     ld_fakpph23
****end of addition
                                     ld_fakppn_f
                                     ld_fakxppnbm_f
                                     ld_fakppnbm_f
                                     fu_flag.   "added by Rahmadi
      CLEAR: ld_fakppn, ld_fakxppnbm, ld_fakppnbm,
             ld_fakdpp, ld_fakpph22, ld_fakpph23.
      CLEAR: ld_fakppn_f, ld_fakxppnbm_f, ld_fakppnbm_f.
    ENDAT.
  ENDLOOP.

*-- select all another follow up billing from t_vbrkf
  SORT t_vbrkscr1 BY vbeln.
  lt_tx00002[] = ft_tx00002[].
  SORT lt_tx00002 BY vbeln.
  LOOP AT t_vbrkf.
    READ TABLE t_vbrkscr1 WITH KEY vbeln = t_vbrkf-vbelv
                          BINARY SEARCH.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING t_vbrkf TO ft_tx00002.
      READ TABLE lt_tx00002 WITH KEY vbeln = t_vbrkf-vbelv
                            BINARY SEARCH.
      IF sy-subrc = 0.
        ld_faktur_code = lt_tx00002-fakturno.
      ENDIF.
      ft_tx00002-fakturno = ld_faktur_code.
      IF t_vbrkscr1-tax = 'X'.
        ft_tx00002-itamtlast  = t_vbrkf-inamtlast.
        ft_tx00002-itdisclast = t_vbrkf-itdiscinlast.
        CLEAR ft_tx00002-exclude.
      ELSE.
        ft_tx00002-itamtlast  = t_vbrkf-examtlast.
        ft_tx00002-itdisclast = t_vbrkf-itdiscexlast.
        ft_tx00002-exclude = 'X'.
      ENDIF.
      ft_tx00002-rangka        = t_vbrkf-ean11.
      ft_tx00002-bilref        = t_vbrkf-vbelv.
      ft_tx00002-itcurr        = ft_tx00002-waers = t_vbrkf-waerk.
      ft_tx00002-userid        = sy-uname.

*--Get tariff
****modified by Rahmadi
*---karoseri is not relevant anymore,
*---more generic to use PPNBM taxable item
*      IF ft_tx00002-karoseri = d_karu.
      IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
        READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                            BINARY SEARCH.
        IF sy-subrc = 0.
**bugfix 30/09/2003
*          ft_tx00002-ppnbmlast = ft_tx00002-ppnbm = t_tariff-ppnbm.
          ft_tx00002-ppnbmlast = ft_tx00002-ppnbm.
          ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
**end of bugfix
        ELSE.
          CLEAR: ft_tx00002-ppnbmlast, ft_tx00002-tarifxpbm.
        ENDIF.
      ELSE.
        CLEAR: ft_tx00002-ppnbmlast, ft_tx00002-tarifxpbm.
      ENDIF.
*      ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.  "bugfix 30/09/2003

      APPEND ft_tx00002.
    ENDIF.
  ENDLOOP.

  IF NOT fc_rpc IS INITIAL.
    lt_tx00002[] = ft_tx00002[].
    SORT lt_tx00002 BY vbeln.
    LOOP AT t_vbrkc.
      READ TABLE t_vbrkscr1 WITH KEY vbeln = t_vbrkc-vbelv
                            BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING t_vbrkc TO ft_tx00002.
        READ TABLE lt_tx00002 WITH KEY vbeln = t_vbrkc-vbelv
                              BINARY SEARCH.
        IF sy-subrc = 0.
          ld_faktur_code = lt_tx00002-fakturno.
        ENDIF.

*** Comment: NEED TO RECONSIDER - Rahmadi
*-------Foreign Currency
        IF t_vbrkc-trcurr NE c_local_curr.

          SELECT SINGLE fakrate bilrate
              INTO (ld_faktur_rate, ld_bil_rate)
              FROM zgdtxdt0003
              WHERE
***modified by Rahmadi
*                    vkorg EQ t_vbrkc-vkorg
*                AND gsber EQ t_vbrkc-gsber
                    bukrs EQ t_vbrkc-bukrs
                AND brnch EQ t_vbrkc-brnch
***end of modification
                AND fakturno EQ ld_faktur_code
                AND returcount LE 0.

*Convert Tax amount base on original tax rate
          ft_tx00002-dpp = t_vbrkc-dpp * ld_faktur_rate / 100.
          ft_tx00002-dpplast = t_vbrkc-dpplast * ld_faktur_rate / 100.
          ft_tx00002-ppnbm = t_vbrkc-ppnbm * ld_bil_rate / 100.
          ft_tx00002-ppnbmlast = t_vbrkc-ppnbmlast * ld_bil_rate / 100.
          ft_tx00002-xppnbm = t_vbrkc-xppnbm * ld_bil_rate / 100.
          ft_tx00002-xppnbmlast =
          t_vbrkc-xppnbmlast * ld_bil_rate / 100.

****Commented by Rahmadi HARDCODED LOGIC --- need to reconsider
*PPN = 10 % * DPP (Hardcode - because of rounding problem)
          IF t_vbrkc-spart NE d_used.
            ft_tx00002-ppn = 10 / 100 * ft_tx00002-dpp.
            ft_tx00002-ppnlast = 10 / 100 * ft_tx00002-dpplast.
            ft_tx00002-ppn2 = 10 / 100 * ft_tx00002-dpp.
            ft_tx00002-ppn2last = 10 / 100 * ft_tx00002-dpplast.
          ELSE.
            ft_tx00002-ppn = ( 1 / 100 ) * ft_tx00002-dpp.
            ft_tx00002-ppnlast = ( 1 / 100 ) * ft_tx00002-dpplast.
            ft_tx00002-ppn2 = ( 1 / 100 ) * ft_tx00002-dpp.
            ft_tx00002-ppn2last = ( 1 / 100 ) * ft_tx00002-dpplast.
          ENDIF.
        ELSE.
          IF t_vbrkc-spart NE d_used.
            ft_tx00002-ppn2 = 10 / 100 * ft_tx00002-dpp.
            ft_tx00002-ppn2last = 10 / 100 * ft_tx00002-dpplast.
          ELSE.
            ft_tx00002-ppn2 = ( 1 / 100 ) * ft_tx00002-dpp.
            ft_tx00002-ppn2last = ( 1 / 100 ) * ft_tx00002-dpplast.
          ENDIF.
        ENDIF.
*End Add
**** End of comment

        ft_tx00002-fakturno = ld_faktur_code.
        IF t_vbrkscr1-tax = 'X'.
          ft_tx00002-itamtlast  = t_vbrkc-inamtlast.
          ft_tx00002-itdisclast = t_vbrkc-itdiscinlast.
          CLEAR ft_tx00002-exclude.
        ELSE.
          ft_tx00002-itamtlast  = t_vbrkc-examtlast.
          ft_tx00002-itdisclast = t_vbrkc-itdiscexlast.
          ft_tx00002-exclude = 'X'.
        ENDIF.
        ft_tx00002-bilref        = t_vbrkc-vbelv.
        ft_tx00002-itcurr        = ft_tx00002-waers = t_vbrkc-waerk.
        ft_tx00002-userid        = sy-uname.

*--Get tariff
****modified by Rahmadi
*---Karoseri is no more relevant
*---Use PPNBM taxable item instead
*        IF ft_tx00002-karoseri = d_karu.
        IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
          READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                              BINARY SEARCH.
          IF sy-subrc = 0.
**bugfix 30/09/2003
*            ft_tx00002-ppnbmlast = ft_tx00002-ppnbm = t_tariff-ppnbm.
            ft_tx00002-ppnbmlast = ft_tx00002-ppnbm.
            ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
**end of bugfix
          ELSE.
            CLEAR: ft_tx00002-ppnbmlast, ft_tx00002-tarifxpbm.
          ENDIF.
        ELSE.
          CLEAR: ft_tx00002-ppnbmlast, ft_tx00002-tarifxpbm.
        ENDIF.
*        ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.  "bugfix 30/09/2003

        APPEND ft_tx00002.
      ENDIF.
    ENDLOOP.

  ENDIF.

*** Commented out by Rahmadi due to generalization - Report option
*--Only relevant for Invoice Consolidation option 1 or 4

*  IF fc_spart = d_sparts.
*    PERFORM f_collect_spart TABLES ft_tx00002
*                             USING c_gab_unit2.
*  ENDIF.

*** Added by Rahmadi
****MAY NEED TO PUT USER EXIT FOR CUSTOM TEXT TO BE APPEAR IN FAKTUR
****(opt.4)
  IF fu_flag = '1' OR fu_flag = '4'.
*---Reporting option '1': Consolidated by Invoice
    PERFORM f_collect_spart TABLES ft_tx00002
                            USING d_smtxt
                                  fu_flag.
  ENDIF.
*** End of addition

*-- Get Petugas based on selected radiobutton on the screen
  CASE 'X'.
    WHEN sp_rb_act1.
      d_aktif = d_aktif1.
    WHEN sp_rb_act2.
      d_aktif = d_aktif2.
    WHEN sp_rb_act3.
      d_aktif = d_aktif3.
    WHEN sp_rb_act4.
      d_aktif = d_aktif4.
    WHEN sp_rb_act5.
      d_aktif = d_aktif5.
  ENDCASE.

ENDFORM.                    " F_GAB_FILL_00002_00003


*&---------------------------------------------------------------------*
*&      Form  F_GAB_FILL_00003
*&---------------------------------------------------------------------*
*&    This routine is particularly used for GABUNGAN purpose to fill
*&    records in ZGDTXDt0003 table
*&---------------------------------------------------------------------*
*&    <-FT_TX00003      - Data prepared for ZGDTXDt0003 table
*&    ->FT_VBRK         - billing data
*&    ->FU_FAKTUR_CODE  - Faktur number
*&    ->FU_FAKPPN       - PPN
*&    ->FU_FAKXPPNBM    - XPPNBM
*&    ->FU_FAKPPNBM     - PPNBM
*&---------------------------------------------------------------------*
FORM f_gab_fill_00003 TABLES ft_tx00003 STRUCTURE t_zgdtxdt0003
                      USING ft_vbrk     STRUCTURE t_vbrk
                            fu_faktur_code
                            fu_fakppn
                            fu_fakxppnbm
                            fu_fakppnbm
****added by Rahmadi
*---Store DPP total, PPH 22, PPH 23
                            fu_fakdpp
                            fu_fakpph22
                            fu_fakpph23
****end of addition
                            fu_fakppn_f
                            fu_fakxppnbm_f
                            fu_fakppnbm_f
                            fu_flag.    "added by Rahmadi

  MOVE-CORRESPONDING ft_vbrk TO ft_tx00003.
  ft_tx00003-fakturno    = fu_faktur_code.
  ft_tx00003-batal       = ' '.
  ft_tx00003-returcount  = '00'.
  ft_tx00003-fakppn      = fu_fakppn.
  ft_tx00003-fakxppnbm   = fu_fakxppnbm.
  ft_tx00003-fakppnbm    = fu_fakppnbm.
  ft_tx00003-faktur_type = c_faktur_type_gabungan.
  ft_tx00003-npwp        = ft_vbrk-stceg.
  ft_tx00003-userid      = sy-uname.

  ft_tx00003-fakppn_f      = fu_fakppn_f.
  ft_tx00003-fakxppnbm_f   = fu_fakxppnbm_f.
  ft_tx00003-fakppnbm_f    = fu_fakppnbm_f.

****added by Rahmadi
*---Store Consolidation option, DPP total, PPH 22, PPH 23
  ft_tx00003-fakgr = fu_flag.
  ft_tx00003-fakdpp = fu_fakdpp.
  ft_tx00003-fakpph22 = fu_fakpph22.
  ft_tx00003-fakpph23 = fu_fakpph23.
****end of addition

  APPEND ft_tx00003.
ENDFORM.                    " F_GAB_FILL_00003

*&---------------------------------------------------------------------*
*&      Form  F_GAB_FILL_00002
*&---------------------------------------------------------------------*
*&    This routine is particularly used for GABUNGAN purpose to fill
*&    records in ZGDTXDt0002 table
*&---------------------------------------------------------------------*
*&    <-FT_TX00002      - Data prepared for ZGDTXDt0002 table
*&    ->FU_VBRK         - billing data
*&    ->FU_VBRKSCR1     - billing data selected from the screen
*&    ->FU_FAKTURNO     - Faktur number
*&---------------------------------------------------------------------*
FORM  f_gab_fill_00002 TABLES ft_tx00002  STRUCTURE t_zgdtxdt0002
                        USING fu_vbrk     STRUCTURE t_vbrk
                              fu_vbrkscr1 STRUCTURE t_vbrkscr1
                              fu_fakturno
                              fu_flag.   "added by Rahmadi

  MOVE-CORRESPONDING fu_vbrk TO ft_tx00002.

***Modified by Rahmadi
***MAY NEED PUT USER EXIT LOGIC FOR CUSTOM TEXT ADDITION (Opt.4)
*  IF fu_vbrk-prctr+4(2) = '10'.
*    ft_tx00002-item = c_prctr10.
*  ELSEIF fu_vbrk-prctr+4(2) = '20'.
*    ft_tx00002-item = c_prctr20.
*  ENDIF.

  IF fu_flag = '4'.
    CONCATENATE d_smtxt d_smtxt1 d_smtxt2 fu_vbrk-arktx
                INTO ft_tx00002-item SEPARATED BY space.
  ELSE.
    ft_tx00002-item = fu_vbrk-arktx.
  ENDIF.
***End of modification

  ft_tx00002-fakturno = fu_fakturno.
  IF fu_vbrkscr1-tax = 'X'.
    ft_tx00002-itamtlast   = fu_vbrk-inamtlast.
    ft_tx00002-itdisclast  = fu_vbrk-itdiscinlast.
    CLEAR ft_tx00002-exclude.
  ELSE.
    ft_tx00002-itamtlast   = fu_vbrk-examtlast.
    ft_tx00002-itdisclast  = fu_vbrk-itdiscexlast.
    ft_tx00002-exclude     = 'X'.
  ENDIF.
**Added by Rahmadi -- bugfix #2
  ft_tx00002-rangka        = t_vbrk-ean11.
**end of addition
  ft_tx00002-bilref        = t_vbrk-vbelv.
  ft_tx00002-itcurr        = ft_tx00002-waers = fu_vbrk-waerk.
  ft_tx00002-userid        = sy-uname.

****added by Rahmadi
*--Store Invoice COnsolidation option
  ft_tx00002-fakgr = fu_flag.
****end of addition

*--Get tariff
****modified by Rahmadi
*--karoseri is not relevant to determine XPBM tariff
*--use PPNBM taxable items instead
*  IF ft_tx00002-karoseri = d_karu.
  IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
    READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                        BINARY SEARCH.
    IF sy-subrc = 0.
**bugfix 30/09/2003
*      ft_tx00002-ppnbmlast = ft_tx00002-ppnbm = t_tariff-ppnbm.
      ft_tx00002-ppnbmlast = ft_tx00002-ppnbm.
      ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
**end of bugfix
    ELSE.
      CLEAR: ft_tx00002-ppnbmlast, ft_tx00002-tarifxpbm.
    ENDIF.
  ELSE.
    CLEAR: ft_tx00002-ppnbmlast, ft_tx00002-tarifxpbm.
  ENDIF.
*  ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.  "bugfix 30/09/2003

  APPEND ft_tx00002.
ENDFORM.                    " F_GAB_FILL_00002

*&---------------------------------------------------------------------*
*&      Form  F_TARIFF_FOLLOWUP
*&---------------------------------------------------------------------*
*&    This routine fills tariff to follow-up billings
*&---------------------------------------------------------------------*
*&    ->FT_VBRKF        - Follow-up billings table
*&    ->FU_VBRK         - Normal billings data
*&---------------------------------------------------------------------*
FORM f_tariff_followup TABLES   ft_vbrkf STRUCTURE t_vbrk
                       USING    fu_vbrk LIKE t_vbrk.

  DATA ld_ppnbm LIKE t_vbrkf-ppnbm.
  DATA ld_ppnbmlast LIKE t_vbrkf-ppnbmlast.

  READ TABLE ft_vbrkf WITH KEY vbelv = fu_vbrk-vbeln.
  IF sy-subrc = 0.
    LOOP AT ft_vbrkf WHERE vbelv = fu_vbrk-vbeln.
      t_tariff-vbeln = ft_vbrkf-vbeln.
      t_tariff-ppnbm = ft_vbrkf-ppnbmlast.
      t_tariff-dpp = ft_vbrkf-dpplast.
      IF t_tariff-dpp <> 0.
        t_tariff-tarifxpbm = ( t_tariff-ppnbm / t_tariff-dpp ) * 100.
        IF t_tariff-tarifxpbm <> 0.
          COLLECT t_tariff.
        ELSE.
          CLEAR t_tariff.
        ENDIF.
      ELSE.
        CLEAR t_tariff.
      ENDIF.
    ENDLOOP.
  ELSE.
    CLEAR t_tariff.
  ENDIF.

ENDFORM.                    " F_TARIFF_FOLLOWUP

*&---------------------------------------------------------------------*
*&      Form  F_INVALID_BILLING
*&---------------------------------------------------------------------*
*&    This routine prevents invalid billing to be processed
*&---------------------------------------------------------------------*
*&    ->FT_VBRK    - Billing table
*&    ->FU_VBRK    - Invalid billing data
*&    ->FU_ERROR   - Error type
*&---------------------------------------------------------------------*
* Commented by Rama - Not used by any program!!!
*FORM f_invalid_billing TABLES ft_vbrk STRUCTURE t_vbrk
*                       USING  fu_vbrk LIKE t_vbrk
*                              fu_error.
*
*  CASE fu_error.
*    WHEN c_error_karoseri.
*      READ TABLE ft_vbrk WITH KEY vbeln = fu_vbrk-vbeln.
*      IF sy-subrc = 0.
*        DELETE ft_vbrk WHERE vbeln = fu_vbrk-vbeln.
*      ENDIF.
*      MOVE-CORRESPONDING fu_vbrk TO t_error.
*      CONCATENATE 'Invalid billing:'
*                  'Karoseri cannot be in the same billing'
*                  'with Accesories'
*                  INTO t_error-msg SEPARATED BY space.
*      APPEND t_error.
*  ENDCASE.
*
*ENDFORM.                    " F_INVALID_BILLING

*&---------------------------------------------------------------------*
*&      Form  F_GET_VAT_OUT
*&---------------------------------------------------------------------*
*&      This routine determines tax (percentage & amount) applied for
*&      the billing
*&---------------------------------------------------------------------*
*&     ->FU_VBELN   - Billing number
*&     ->FU_POSNR   - Billing item
*&     <-FC_TAX     - Tax (percentage)
*&     <-FC_VATOUT  - VAT out (amount)
*----------------------------------------------------------------------*
FORM f_get_vat_out USING    fu_vbeln
                            fu_posnr
                   CHANGING fc_tax
                            fc_vatout.

  READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 ptype = d_ptype_vatout
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_tax = t_priceall-kbetr / d_taxfactor.
    fc_vatout = t_priceall-kwert.
  ELSE.
    CLEAR: fc_tax, fc_vatout.
  ENDIF.

ENDFORM.                    " F_GET_VAT_OUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_VAT_OUT_HASHED
*&---------------------------------------------------------------------*
*&      This routine determines tax (percentage & amount) applied for
*&      the billing
*&---------------------------------------------------------------------*
*&     ->FU_VBELN   - Billing number
*&     ->FU_POSNR   - Billing item
*&     <-FC_TAX     - Tax (percentage)
*&     <-FC_VATOUT  - VAT out (amount)
*----------------------------------------------------------------------*
FORM f_get_vat_out_hashed USING    fu_vbeln
                                   fu_posnr
                          CHANGING fc_tax
                                   fc_vatout.

  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                            WITH KEY  vbeln = fu_vbeln
                                      posnr = fu_posnr
                                      ptype = d_ptype_vatout.
  IF sy-subrc = 0.
    fc_tax = wa_priceallhashed-kbetr / d_taxfactor.
    fc_vatout = wa_priceallhashed-kwert.
  ELSE.
    CLEAR: fc_tax, fc_vatout.
  ENDIF.

ENDFORM.                    " F_GET_VAT_OUT_HASHED

*&---------------------------------------------------------------------*
*&      Form  F_GET_VAT_IN
*&---------------------------------------------------------------------*
*&      This routine determines VAT-in amount applied for the billing
*&---------------------------------------------------------------------*
*&     ->FU_VBELN   - Billing number
*&     ->FU_POSNR   - Billing item
*&     <-FC_VATIN   - VAT in (amount)
*----------------------------------------------------------------------*
FORM f_get_vat_in USING    fu_vbeln
                           fu_posnr
                  CHANGING fc_vatin.

  READ TABLE t_priceall WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 ptype = d_ptype_vatin
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_vatin = t_priceall-kwert.
  ELSE.
    CLEAR fc_vatin.
  ENDIF.

ENDFORM.                    " F_GET_VAT_IN

*&---------------------------------------------------------------------*
*&      Form  F_NON_MATCHED_NPWP
*&---------------------------------------------------------------------*
*&    This routine filters out billings whose NPWP other than the one
*&    that is selected in the selection-screen
*&---------------------------------------------------------------------*
*&     ->FT_STCEG   - NPWP selected from selection screen
*&---------------------------------------------------------------------*
FORM f_non_matched_npwp TABLES ft_stceg STRUCTURE r_stceg.

  PERFORM f_process_screen_npwp TABLES t_vbrkscr
                                       ft_stceg.
  PERFORM f_process_npwp_delete TABLES t_vbrk
                                       ft_stceg.
  PERFORM f_process_npwp_delete TABLES t_vbrkf
                                       ft_stceg.

ENDFORM.                    " F_NON_MATCHED_NPWP

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_SCREEN_NPWP
*&---------------------------------------------------------------------*
*&    This routine filters out billings whose NPWP other than the one
*&    that is selected in the selection-screen so it won't be displayed
*&    on the screen
*&---------------------------------------------------------------------*
*&     ->FT_STCEG   - NPWP selected from selection screen
*&     <-FT_VBRKSCR - billing data displayed on the screen
*&---------------------------------------------------------------------*
FORM f_process_screen_npwp TABLES   ft_vbrkscr STRUCTURE t_vbrkscr
                                    ft_stceg STRUCTURE r_stceg.

  DELETE ft_vbrkscr WHERE NOT stceg IN ft_stceg.

ENDFORM.                    " F_PROCESS_SCREEN_NPWP

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_NPWP_DELETE
*&---------------------------------------------------------------------*
*&    This routine filters out billings whose NPWP other than the one
*&    that is selected in the selection-screen to prevent them to be
*&    saved in the tax tables
*&---------------------------------------------------------------------*
*&     ->FT_STCEG   - NPWP selected from selection screen
*&     <-FT_VBRK    - billing data
*&---------------------------------------------------------------------*
FORM f_process_npwp_delete TABLES   ft_vbrk STRUCTURE t_vbrk
                                    ft_stceg STRUCTURE r_stceg.

  DATA lt_vbrk LIKE t_vbrk OCCURS 1 WITH HEADER LINE.

  lt_vbrk[] = ft_vbrk[].
  DELETE ft_vbrk WHERE NOT stceg IN ft_stceg.
  DELETE lt_vbrk WHERE stceg IN ft_stceg.

  IF NOT lt_vbrk[] IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM lt_vbrk COMPARING vbeln.
    LOOP AT lt_vbrk.
      PERFORM f_unlock_error_billing USING lt_vbrk-vbeln.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_PROCESS_NPWP_DELETE

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTTEXT
*&---------------------------------------------------------------------*
FORM f_get_custtext TABLES ft_line STRUCTURE tline
                     USING fu_kunrg
                  CHANGING fc_name
                           fc_addrs1
                           fc_addrs2
                           fc_city
                           fc_postal
                           fc_sbc.

  DATA: ld_name LIKE thead-tdname.
  ld_name = fu_kunrg.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = '0001'
      language                = sy-langu
      name                    = ld_name
      object                  = 'KNA1'
*     ARCHIVE_HANDLE          =
*     IMPORTING               =
*     HEADER                  =
    TABLES
      lines                   = ft_line
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  fc_sbc = sy-subrc.

  IF fc_sbc = 0.
    LOOP AT ft_line WHERE tdline NE space.
      CASE sy-tabix.
        WHEN 1.
          fc_name   = ft_line-tdline.
        WHEN 2.
          fc_addrs1 = ft_line-tdline.
        WHEN 3.
          fc_addrs2 = ft_line-tdline.
        WHEN 4.
          fc_city   = ft_line-tdline.
        WHEN 5.
          fc_postal = ft_line-tdline.
      ENDCASE.
    ENDLOOP.

    IF fc_name EQ space.
      fc_sbc = 4.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_GET_CUSTTEXT


*&---------------------------------------------------------------------*
*&      Form  F_LAST_DATE
*&---------------------------------------------------------------------*
FORM f_last_date USING fu_fkdat
              CHANGING fc_top.

  CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
    EXPORTING
      months  = 1
      olddate = fu_fkdat
    IMPORTING
      newdate = fc_top.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fc_top
    IMPORTING
      last_day_of_month = fc_top
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F_LAST_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CEK_DATE
*&---------------------------------------------------------------------*
FORM f_cek_date TABLES ft_vbfa1 STRUCTURE t_vbfaa
                USING  fu_vbrk  LIKE t_vbrk
                       fu_zfbdt fu_bd1t
              CHANGING fc_sbc   fc_top.

  DATA: ld_top LIKE sy-datum,
        ld_sel TYPE i.

  ld_top = fu_zfbdt + fu_bd1t.
  IF NOT d_period_end IS INITIAL.
    IF fu_vbrk-fkdat+0(6) EQ ld_top+0(6).
      MOVE-CORRESPONDING fu_vbrk TO t_error.
      CONCATENATE 'This Billing has previous month term of payment'
                                           ''  INTO t_error-msg.
      APPEND t_error.
      REFRESH ft_vbfa1. CLEAR ft_vbfa1.
      fc_sbc = 1.
    ELSE.
      ld_sel = ld_top+0(6) - fu_vbrk-fkdat+0(6).
      IF ld_sel > 1.
        PERFORM f_last_date USING fu_vbrk-fkdat
                         CHANGING ld_top.
      ENDIF.
      fc_top = ld_top.
    ENDIF.
  ELSE.
    IF fu_vbrk-fkdat+0(6) NE ld_top+0(6).
      MOVE-CORRESPONDING fu_vbrk TO t_error.
      CONCATENATE 'This Billing has next month term of payment'
                                           ''  INTO t_error-msg.
      APPEND t_error.
      REFRESH ft_vbfa1. CLEAR ft_vbfa1.
      fc_sbc = 1.
    ELSE.
      fc_top = ld_top.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CEK_DATE

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_SPART
*&---------------------------------------------------------------------*
*&  Used for Display option '1' -- Consolidated by Invoice
*&  All items in the invoice will be combined into 1 displayed item,
*&  the quantity will be accumulated, the description will be FC_TEXT
*&---------------------------------------------------------------------*
FORM f_collect_spart TABLES ft_tx00002 STRUCTURE zgdtxdt0002
                     USING fc_text
                           fu_flag.

  DATA: lt_zgdtxdt0002 LIKE zgdtxdt0002 OCCURS 0 WITH HEADER LINE,
        lt_00002       LIKE zgdtxdt0002,
        ld_new         TYPE c.

* Change ZGDTXdt0002 so it only save one record for one faktur pajak
* for sparepart

  SORT ft_tx00002 BY vkorg gsber spart vbeln posnr gjahr fakturno.

  LOOP AT ft_tx00002.
    lt_00002 = ft_tx00002.

    CLEAR ld_new.
    AT NEW vbeln.
      MOVE-CORRESPONDING lt_00002 TO lt_zgdtxdt0002.
      CLEAR: lt_zgdtxdt0002-posnr,
             lt_zgdtxdt0002-matnr,
             lt_zgdtxdt0002-itemdiv,
             lt_zgdtxdt0002-rangka,
             lt_zgdtxdt0002-mesin,
             lt_zgdtxdt0002-th_buat,
             lt_zgdtxdt0002-rectype.

***** Modified by Rahmadi -- Reporting option '1' - Invoice consldt
      CASE fu_flag.
        WHEN '1'.
          CONCATENATE
                      lt_zgdtxdt0002-vbeln
                      fc_text
                      INTO lt_zgdtxdt0002-item
                      SEPARATED BY space.
        WHEN '4'.
          lt_zgdtxdt0002-item = fc_text.
      ENDCASE.
***** End of modification

      ld_new = 'X'.
    ENDAT.

    IF NOT ld_new EQ 'X'.
      ADD: lt_00002-itqty      TO lt_zgdtxdt0002-itqty,
           lt_00002-itqtylast  TO lt_zgdtxdt0002-itqtylast,
           lt_00002-itamt      TO lt_zgdtxdt0002-itamt,
           lt_00002-itamtlast  TO lt_zgdtxdt0002-itamtlast,
           lt_00002-itdisc     TO lt_zgdtxdt0002-itdisc,
           lt_00002-itdisclast TO lt_zgdtxdt0002-itdisclast,
           lt_00002-itoth      TO lt_zgdtxdt0002-itoth,
           lt_00002-itothlast  TO lt_zgdtxdt0002-itothlast,
           lt_00002-dpp        TO lt_zgdtxdt0002-dpp,
           lt_00002-dpplast    TO lt_zgdtxdt0002-dpplast,
           lt_00002-ppn        TO lt_zgdtxdt0002-ppn,
           lt_00002-ppnlast    TO lt_zgdtxdt0002-ppnlast,
           lt_00002-ppnbm      TO lt_zgdtxdt0002-ppnbm,
           lt_00002-ppnbmlast  TO lt_zgdtxdt0002-ppnbmlast,
           lt_00002-xppnbm     TO lt_zgdtxdt0002-xppnbm,
           lt_00002-xppnbmlast TO lt_zgdtxdt0002-xppnbmlast,

           lt_00002-itamt_f      TO lt_zgdtxdt0002-itamt_f,
           lt_00002-itdisc_f     TO lt_zgdtxdt0002-itdisc_f,
           lt_00002-itoth_f      TO lt_zgdtxdt0002-itoth_f,
           lt_00002-dpp_f        TO lt_zgdtxdt0002-dpp_f,
           lt_00002-ppn_f        TO lt_zgdtxdt0002-ppn_f,
           lt_00002-ppnbm_f      TO lt_zgdtxdt0002-ppnbm_f,
           lt_00002-xppnbm_f     TO lt_zgdtxdt0002-xppnbm_f,

           lt_00002-tarifxpbm  TO lt_zgdtxdt0002-tarifxpbm.
    ENDIF.

    AT END OF vbeln.
      APPEND lt_zgdtxdt0002.
    ENDAT.

  ENDLOOP.

  ft_tx00002[] = lt_zgdtxdt0002[].

ENDFORM.                    " F_COLLECT_SPART

*&---------------------------------------------------------------------*
*&      Form  F_CEK_FREEGOODS
*&---------------------------------------------------------------------*
FORM f_cek_freegoods USING fu_vbrk LIKE t_vbrk
                  CHANGING fc_gsbc.

  IF fu_vbrk-pstyv = c_pstyv_free.
    fc_gsbc = '1'.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    t_error-msg = 'The billing should be processed using FP satuan'.
    APPEND t_error.
  ENDIF.

ENDFORM.                    " F_CEK_FREEGOODS

*&---------------------------------------------------------------------*
*&      Form  F_GET_LASTPLUS
*&---------------------------------------------------------------------*
FORM f_get_lastplus USING fu_masatx0.

  DATA: ld_in LIKE sy-datum,
        ld_ot LIKE sy-datum.
  CLEAR: ld_ot, ld_in.

  ld_in = fu_masatx0.
  ld_in+6(2) = '01'.

***changed for Tempo
*  CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
  CALL FUNCTION 'SLS_MISC_GET_LAST_DAY_OF_MONTH'
***end of changes
    EXPORTING
      day_in            = ld_in
    IMPORTING
      last_day_of_month = ld_ot.
* EXCEPTIONS
*   DAY_IN_NOT_VALID        = 1
*   OTHERS                  = 2
  .
  ld_ot = ld_ot + 3.

  IF sy-datum LT ld_ot.
    MESSAGE e000(ztx) WITH 'PPN Sederhana diproses setelah Tgl 3'.
  ENDIF.

ENDFORM.                    " F_GET_LASTPLUS

*&---------------------------------------------------------------------*
*&      Form  F_GET_TAX_RATE
*&---------------------------------------------------------------------*
*       Get the Tax Rate base on billing currency
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_tax_rate USING fd_fcurr  LIKE t_vbrk-waerk
                          fd_fakdat LIKE t_vbrk-fakdat
                          fd_lcurr  LIKE t_vbrk-waerk.

  DATA lw_return LIKE bapireturn1.
  DATA lw_rate LIKE bapi1093_0.

  CLEAR: d_rate_tax,
         d_ratefactor,
         d_tax_valid.
* Get Valid tax rate date
* Selection base on Faktur Pajak date
*break bcrmd.
***Updated in Tempo ---use BAPI function instead of old function
*  CALL FUNCTION 'READ_EXCHANGE_RATE'
*       EXPORTING
*            client            = sy-mandt
*            date              = fd_fakdat
*            foreign_currency  = fd_fcurr
*            local_currency    = fd_lcurr
*            type_of_rate      = 'ZTAX'
*       IMPORTING
*            exchange_rate     = d_rate_tax
*            FOREIGN_FACTOR    = d_forfactor
*            local_factor      = d_ratefactor
*            valid_from_date   = d_tax_valid
**         DERIVED_RATE_TYPE =
**         FIXED_RATE        =
**    EXCEPTIONS
**         NO_RATE_FOUND     = 1
**         NO_FACTORS_FOUND  = 2
**         NO_SPREAD_FOUND   = 3
**         DERIVED_2_TIMES   = 4
**         OVERFLOW          = 5
**         OTHERS            = 6
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

  CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
    EXPORTING
      rate_type  = 'ZTAX'
      from_curr  = fd_fcurr
      to_currncy = fd_lcurr
      date       = fd_fakdat
    IMPORTING
      exch_rate  = lw_rate
      return     = lw_return.
  IF NOT lw_return IS INITIAL.
    MESSAGE e000(zab) WITH lw_return-message.
  ELSE.
    d_rate_tax = lw_rate-exch_rate * lw_rate-to_factor
                 / lw_rate-from_factor.
  ENDIF.

ENDFORM.                    " F_GET_TAX_RATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_LEGACY_REFERENCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_VBRK  text
*      <--P_LW_VBRK_KWITANSI  text
*----------------------------------------------------------------------*
FORM f_get_legacy_reference USING    fu_lw_vbrk LIKE t_vbrk
                            CHANGING fc_lw_kwitansi.

  DATA: ld_refference LIKE bsad-xblnr.
  CLEAR: ld_refference.

  SELECT SINGLE xblnr
         INTO ld_refference
         FROM bsid
         WHERE bukrs EQ fu_lw_vbrk-vkorg AND
               gsber EQ fu_lw_vbrk-gsber AND
               vbeln EQ fu_lw_vbrk-vbeln..

  IF sy-subrc EQ 0.
    fc_lw_kwitansi = ld_refference.
  ELSE.
    fc_lw_kwitansi = fu_lw_vbrk-xblnr.
  ENDIF.
ENDFORM.                    " F_GET_LEGACY_REFERENCE

*&---------------------------------------------------------------------*
*&      Form  F_GET_SIGNOFF
*&---------------------------------------------------------------------*
FORM f_get_stdtext_tax USING fu_tdnam fu_brnch fu_idkey fu_reslt.
  DATA: ld_tdnam     LIKE rssce-tdname,
        ld_idkey(40),
        ld_reslt(72),
        ld_keyin(40).

  DATA: lt_lines   LIKE tline OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_lines.
  CLEAR fu_reslt.
  ld_keyin = fu_idkey.
  CONCATENATE fu_tdnam fu_brnch INTO ld_tdnam.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = 'ST'
      language                = sy-langu
      name                    = ld_tdnam
      object                  = 'TEXT'
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
*   IMPORTING
*     HEADER                  =
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  LOOP AT lt_lines.
    SPLIT lt_lines-tdline AT ':' INTO ld_idkey ld_reslt.
    TRANSLATE ld_idkey TO UPPER CASE.
    IF ld_keyin NE space AND ld_keyin EQ ld_idkey.
      fu_reslt = ld_reslt.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_SIGNOFF


*--- Added by Rama
*&---------------------------------------------------------------------*
*&      Form  F_GET_TAX_CONFIG_DETAILS
*&---------------------------------------------------------------------*
*&  This routine gets all the data from tax configuration tables
*&  including brnch and business line details and the grouping config
*&---------------------------------------------------------------------*
FORM f_get_tax_config_details.

**Get branch codes
  SELECT * INTO TABLE t_tx00101 FROM zgdtxdt0101.
  IF sy-subrc = 0.
    SORT t_tx00101 BY bukrs brnch.
  ENDIF.

  SELECT * INTO TABLE t_tx00102 FROM zgdtxdt0102.
  IF sy-subrc = 0.
    SORT t_tx00102 BY busln.
  ENDIF.

  SELECT * INTO TABLE t_tx00103 FROM zgdtxdt0103.
  IF sy-subrc = 0.
    SORT t_tx00103 BY brnch busln.
  ENDIF.

ENDFORM.                    " F_GET_TAX_CONFIG_DETAILS

*&---------------------------------------------------------------------*
*&      Form  F_GET_SAP_ORG_VALUES
*&---------------------------------------------------------------------*
*&  Based on selection of business line and Branch system will get the
*&  values for the SAP organisation entities.
*&---------------------------------------------------------------------*
FORM f_get_sap_org_values USING    fu_brnch fu_busln
                          CHANGING fu_bukrs.

  READ TABLE t_tx00101 WITH KEY brnch = fu_brnch.
  fu_bukrs = t_tx00101-bukrs.

ENDFORM.                    " f_get_sap_org_values.

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUKRS_TEXT
*&---------------------------------------------------------------------*
*&  This routine retrieves Company Code description
*&---------------------------------------------------------------------*
*&  ->FU_BUKRS     - Company code
*&  ->FC_DES_CC    - Company code description
*&---------------------------------------------------------------------*
FORM f_get_bukrs_text USING fu_bukrs
                   CHANGING fc_des_cc.

  SELECT SINGLE butxt INTO fc_des_cc FROM t001
         WHERE bukrs = fu_bukrs
           AND spras = sy-langu.

ENDFORM.                    " F_GET_BUKRS_TEXT


*&---------------------------------------------------------------------*
*&      Form  F_SELECT_BRANCH_BILLING_DATA
*&---------------------------------------------------------------------*
*&  This routine will determine the branch and business line and also
*&  eliminate those records which do not belong to the selected branch
*&  and business line
*&---------------------------------------------------------------------*
*&  ->FT_VBRK  - Line item data from VBRP and VBRK
*&  ->FU_BRNCH - Branch in selection parameter
*&  ->FU_BUSLN - Business line in selection parameter
*&---------------------------------------------------------------------*
FORM f_select_branch_billing_data TABLES ft_vbrk0 STRUCTURE t_vbrk
                                  USING  fu_brnch
                                         fu_busln.

  DATA lt_error LIKE t_error OCCURS 1 WITH HEADER LINE.
  DATA ld_subrc LIKE sy-subrc.

*------USER EXIT is used to determine BRANCH and BUSINESS LINE--------*
  LOOP AT ft_vbrk0.
    CLEAR ld_subrc.
    CALL FUNCTION 'Z_GDTXFC_EXIT_BRNCH_BUSLN_DET'
      EXPORTING
        fi_vbrk    = ft_vbrk0
      IMPORTING
        fe_vbrk    = ft_vbrk0
        fe_subrc   = ld_subrc
      TABLES
        ft_tx00101 = t_tx00101
        ft_error   = lt_error.
    IF ld_subrc <> 0.
      DELETE ft_vbrk0.
    ELSE.
      MODIFY ft_vbrk0.
    ENDIF.
  ENDLOOP.

***append error records to ERROR LOG
  IF NOT lt_error[] IS INITIAL.
    APPEND LINES OF lt_error TO t_error.
  ENDIF.

* Based on selection parameter delete those which are not
* relevant to be processed.
  IF NOT fu_brnch IS INITIAL AND
     NOT fu_busln IS INITIAL.
    DELETE ft_vbrk0 WHERE brnch <> fu_brnch OR
                          busln <> fu_busln.
  ELSEIF NOT fu_brnch IS INITIAL AND
         fu_busln IS INITIAL.
    DELETE ft_vbrk0 WHERE brnch <> fu_brnch.
  ELSEIF fu_brnch IS INITIAL AND
         NOT fu_busln IS INITIAL.
    DELETE ft_vbrk0 WHERE busln <> fu_busln.
  ENDIF.

ENDFORM.                    " F_SELECT_BRANCH_BILLING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_GROUP_ITEMS
*&---------------------------------------------------------------------*
*&  This routine will determine which of the items need to be grouped
*&  together and will have to be changed for the implementation based
*&  on design at the site
*&---------------------------------------------------------------------*
*&  ->FT_VBRK  - Line item data from VBRP and VBRK
*&---------------------------------------------------------------------*
FORM f_determine_group_items TABLES ft_vbrk STRUCTURE t_vbrk.
  DATA: ld_posnr LIKE ft_vbrk-grpos.
  SORT ft_vbrk BY vbeln posnr.

  LOOP AT ft_vbrk.

    ft_vbrk-grpos = ld_posnr.
    ld_posnr = ft_vbrk-posnr.

    MODIFY ft_vbrk.
  ENDLOOP.

ENDFORM.                    " F_DETERMINE_GROUP_ITEMS
*--- End of Addition by Rama

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDITIONAL_DATA
*&---------------------------------------------------------------------*
*       This routine is where User exit for including additional
*       data can be put.
*       The fields for additional data must be included to structure
*       ZGDTXSTEX01 to make the logic in the user exit recognized
*       by the program
*----------------------------------------------------------------------*
*      -->FT_VBRK  Structure for main internal tables in the program
*----------------------------------------------------------------------*
FORM f_get_additional_data TABLES   ft_vbrk STRUCTURE zgdtxst0007.

*  CALL CUSTOMER-FUNCTION '002'.

ENDFORM.                    " f_get_additional_data

*&---------------------------------------------------------------------*
*&      Form  f_additional_data_procs
*&---------------------------------------------------------------------*
*       This routine is where User exit for processing additional
*       data can be put.
*       The fields for additional data must be included to structure
*       ZGDTXST0007 to make the logic in the user exit recognized
*       by the program
*----------------------------------------------------------------------*
*      -->FU_VBRK  text
*      <--FC_VBRK  text
*----------------------------------------------------------------------*
FORM f_additional_data_procs USING    fu_vbrk LIKE zgdtxst0007
                             CHANGING fc_vbrk LIKE zgdtxst0007.

  CALL FUNCTION 'Z_GDTXFC_EXIT_ADDT_INFO'
    EXPORTING
      fi_vbrk = fu_vbrk
    IMPORTING
      fe_vbrk = fc_vbrk
    TABLES
      ft_vbpa = t_vbpa.

ENDFORM.                    " f_additional_data_procs

*&---------------------------------------------------------------------*
*&      Form  f_determine_ppnbm_items
*&---------------------------------------------------------------------*
*       This routine is where User exit to put logic for determining
*       whether an item in a billing is PPNBM deductable
*----------------------------------------------------------------------*
*      -->P_LW_VBRK  text
*      <--P_T_TARIFF_DPP  text
*      <--P_T_TARIFF_PPNBM  text
*----------------------------------------------------------------------*
FORM f_determine_ppnbm_items USING    fu_vbrk LIKE zgdtxst0007
                             CHANGING fc_dpp
                                      fc_ppnbm.

  DATA ld_subrc LIKE sy-subrc.

***** Modified by Rahmadi
*--USER EXIT to determine PPNBM deductable items
*  (Its DPP will be considered to calculate Tariff XPBM)
  CALL FUNCTION 'Z_GDTXFC_EXIT_PPNBM_ITEM_DETM'
    EXPORTING
      fi_vbrk  = fu_vbrk
    IMPORTING
      fe_subrc = ld_subrc.
  IF ld_subrc = 0.
    fc_dpp = fu_vbrk-dpplast.
    fc_ppnbm = fu_vbrk-ppnbmlast.
  ELSE.
    fc_dpp = 0.
    fc_ppnbm = 0.
  ENDIF.

ENDFORM.                    " f_determine_ppnbm_items

*&---------------------------------------------------------------------*
*&      Form  f_add_spaces
*&---------------------------------------------------------------------*
*       Add Spaces for Item formatting
*----------------------------------------------------------------------*
*      -->FU_ITEM  text
*      <--FC_SPACES  text
*----------------------------------------------------------------------*
FORM f_add_spaces USING    fu_item
                  CHANGING fc_space.

  DATA ld_length TYPE i.
  DATA ld_res TYPE i.

  CLEAR fc_space.
  ld_length = strlen( fu_item ).
  ld_res = 50 - ld_length.
  DO ld_res TIMES.
    CONCATENATE fc_space space INTO fc_space SEPARATED BY space.
  ENDDO.

ENDFORM.                    " f_add_spaces

*&---------------------------------------------------------------------*
*&      Form  f_reduce_spaces
*&---------------------------------------------------------------------*
*       Reduce Spaces for Item formatting
*----------------------------------------------------------------------*
*      -->FU_ITEM  text
*      <--FC_SPACES  text
*----------------------------------------------------------------------*
FORM f_reduce_spaces USING fu_item
                           fu_orig
                           fu_disp
                  CHANGING fc_pos.

  DATA ld_length TYPE i.

  IF NOT fu_item IS INITIAL.
    CLEAR fc_pos.
    IF fu_disp IS INITIAL.
      ld_length = strlen( fu_item ).
      IF ld_length < fu_orig.
        fc_pos = ld_length.
      ELSE.
        fc_pos = fu_orig.
      ENDIF.
    ELSE.
      IF fu_disp > fu_orig.
        fc_pos = fu_orig.
      ELSE.
        fc_pos = fu_disp.
      ENDIF.
    ENDIF.
  ELSE.
    fc_pos = 1.
  ENDIF.

ENDFORM.                    " f_reduce_spaces


*--- Moved by Rama
*&---------------------------------------------------------------------*
*& All codes here having form name with suffix _old can be deleted






*&---------------------------------------------------------------------*
*&      Form  F_GET_PKP
*&---------------------------------------------------------------------*
*&  This routine retrieves PKP info required to print Faktur pajak
*&  (Tax form). Since number range is PKP specific, it will also be
*&  retrieved using this routine.
*&  Branch head (KaCAB) & Administration Head (ADH) are also authorized
*&  to sign faktur pajak in branches therefore these data are also
*&  retrieved from STANDARD TEXT
*&---------------------------------------------------------------------*
*&  ->FU_VKORG      - Sales organization / Company code
*&  ->FU_GSBER      - Business Area
*&  ->FU_SPART      - Division
*&  ->FU_BRNCH      - Branch
*&  ->FU_BUSLN      - Business line
*&  ->FU_FAKDAT     - Tax processing date
*&  <-FC_PETUGAS    - Tax officer 1
*&  <-FC_PETUGAS2   - Tax officer 2 (bench)
*&  <-FC_AKTIF      - Active indicator
*&                    (1-Tax officer 1 is active;
*&                     2-Tax officer 2 is active)
*&  <-FC_JABAT      - Tax officer 1 official position
*&  <-FC_JABAT2     - Tax officer 2 official position
*&  <-FC_FPONE      - Prefix 1 for Tax form number
*&  <-FC_FPTWO      - Prefix 2 for Tax form number
*&  <-FC_OBJRANGE   - Number range object id for the tax form
*&  <-FC_PKPNPWP    - Home NPWP
*&  <-FC_PKPNAME    - PKP name
*&  <-FC_PKPADDRS1  - PKP address 1
*&  <-FC_PKPADDRS2  - PKP address 2
*&  <-FC_PKPKUH     - PKP
*&  <-FC_PKPCITY    - PKP City
*&  <-FC_PKPPOSTAL  - PKP postal code
*&  <-FC_NR_GSBER   - Business area used for number range
*&  <-FC_NAME_KAADM - Branch Administration head name
*&  <-FC_NAME_KACAB - Branch Head name
*&  <-FC_KAADM      - Administration head (position)
*&  <-FC_KACAB      - Branch head (position)
*&---------------------------------------------------------------------*
FORM f_get_pkp_old USING fu_vkorg      fu_gsber    fu_spart
                     fu_brnch      fu_busln    fu_bukrs
                     fu_fakdat
                     fu_flag_reprint fu_fpone  fu_fptwo
          CHANGING fc_petugas    fc_petugas2   fc_aktif     fc_jabat
                   fc_jabat2     fc_fpone      fc_fptwo     fc_objrange
                   fc_pkpnpwp    fc_pkpname    fc_pkpaddrs1 fc_pkpaddrs2
                   fc_pkpkuh     fc_pkpcity    fc_pkppostal
*                   fc_nr_gsber
                   fc_nr_brnch
                   fc_name_kaadm fc_name_kacab fc_kaadm     fc_kacab.

**Get PKP info
*---------------------------------------------------------------------*
* notes: VSPO field determines in which division the PKP is applicable
*        VSPO stands for:
*        V = Finished Unit; S = Service; P = Spare parts; O = Other
*---------------------------------------------------------------------*
  IF fu_flag_reprint IS INITIAL.
    SELECT masafrom pkpnpwp vspo pkpname pkpaddrs1 pkpaddrs2 pkpkuh
           pkpcity pkppostal aktif petugas petugas2 jabat jabat2
           fpone fptwo objrange coretax
           INTO CORRESPONDING FIELDS OF TABLE t_pkp
           FROM zgdtxdt0005
* Changed by rama
           WHERE brnch = fu_brnch AND
*           WHERE vkorg = fu_vkorg AND
*                 gsber = fu_gsber AND
* end of Change by rama
                 masafrom <= fu_fakdat.
  ELSE.
    SELECT masafrom pkpnpwp vspo pkpname pkpaddrs1 pkpaddrs2 pkpkuh
           pkpcity pkppostal aktif petugas petugas2 jabat jabat2
           fpone fptwo objrange coretax
           INTO CORRESPONDING FIELDS OF TABLE t_pkp
           FROM zgdtxdt0005
* Changed by rama
           WHERE brnch = fu_brnch AND
*           WHERE vkorg = fu_vkorg AND
*                 gsber = fu_gsber AND
* end of Change by rama
                 masafrom <= fu_fakdat AND
                 fpone = fu_fpone      AND
                 fptwo = fu_fptwo.
  ENDIF.

  IF sy-subrc = 0.
    SORT t_pkp BY masafrom DESCENDING.
    READ TABLE t_pkp INDEX 1.

    CASE fu_spart.
      WHEN d_fin_unit OR d_used OR d_truck.
        IF t_pkp-vspo+0(1) = '1'.
          mac_from_variabel d_b t_pkp- fu_.
          fc_petugas  = t_pkp-petugas.
          fc_petugas2 = t_pkp-petugas2.
          d_baktif = t_pkp-aktif.
        ELSE.
          PERFORM f_get_pkp_head_office_old
                  USING fu_vkorg    fu_gsber
                        fu_brnch    fu_busln     fu_bukrs
                        fu_fakdat   fu_fpone     fu_fptwo
               CHANGING fc_petugas  fc_petugas2  fc_aktif
                        fc_jabat    fc_jabat2    fc_fpone
                        fc_fptwo    fc_objrange  fc_pkpnpwp
                        fc_pkpname  fc_pkpaddrs1 fc_pkpaddrs2
                        fc_pkpkuh   fc_pkpcity   fc_pkppostal
*                        fc_nr_gsber.
                        fc_nr_brnch.
          mac_from_variabel d_h fc_ fc_nr_.
          d_haktif = fc_aktif.
        ENDIF.
      WHEN d_service.
        mac_from_variabel d_b t_pkp- fu_.
        PERFORM f_get_pkp_head_office_old
                  USING fu_vkorg    fu_gsber
                        fu_brnch    fu_busln    fu_bukrs
                        fu_fakdat   fu_fpone     fu_fptwo
             CHANGING fc_petugas  fc_petugas2  fc_aktif
                      fc_jabat    fc_jabat2    fc_fpone
                      fc_fptwo    fc_objrange  fc_pkpnpwp
                      fc_pkpname  fc_pkpaddrs1 fc_pkpaddrs2
                      fc_pkpkuh   fc_pkpcity   fc_pkppostal
*                      fc_nr_gsber.
                      fc_nr_brnch.
        mac_from_variabel d_h fc_ fc_nr_.
        d_haktif = fc_aktif.
      WHEN d_sparts.
        mac_from_variabel d_b t_pkp- fu_.
        fc_petugas  = t_pkp-petugas.
        fc_petugas2 = t_pkp-petugas2.
        d_baktif = t_pkp-aktif.
        PERFORM f_get_pkp_head_office_old
                USING fu_vkorg    fu_gsber
                      fu_brnch    fu_busln     fu_bukrs
                      fu_fakdat   fu_fpone     fu_fptwo
             CHANGING fc_petugas  fc_petugas2  fc_aktif
                      fc_jabat    fc_jabat2    fc_fpone
                      fc_fptwo    fc_objrange  fc_pkpnpwp
                      fc_pkpname  fc_pkpaddrs1 fc_pkpaddrs2
                      fc_pkpkuh   fc_pkpcity   fc_pkppostal
*                      fc_nr_gsber.
                      fc_nr_brnch.
        mac_from_variabel d_h fc_ fc_nr_.
        d_haktif = fc_aktif.
      WHEN OTHERS.
********Use common (head office)
        PERFORM f_get_pkp_head_office_old
                USING fu_vkorg    fu_gsber
                      fu_brnch    fu_busln     fu_bukrs
                      fu_fakdat   fu_fpone     fu_fptwo
             CHANGING fc_petugas  fc_petugas2  fc_aktif
                      fc_jabat    fc_jabat2    fc_fpone
                      fc_fptwo    fc_objrange  fc_pkpnpwp
                      fc_pkpname  fc_pkpaddrs1 fc_pkpaddrs2
                      fc_pkpkuh   fc_pkpcity   fc_pkppostal
*                      fc_nr_gsber.
                      fc_nr_brnch.
        mac_from_variabel d_h fc_ fc_nr_.
        d_haktif = fc_aktif.
    ENDCASE.
  ELSE.
****Use common (head office)
    PERFORM f_get_pkp_head_office_old
            USING fu_vkorg    fu_gsber
                  fu_brnch    fu_busln     fu_bukrs
                  fu_fakdat   fu_fpone     fu_fptwo
         CHANGING fc_petugas  fc_petugas2  fc_aktif
                  fc_jabat    fc_jabat2    fc_fpone
                  fc_fptwo    fc_objrange  fc_pkpnpwp
                  fc_pkpname  fc_pkpaddrs1 fc_pkpaddrs2
                  fc_pkpkuh   fc_pkpcity   fc_pkppostal
*                  fc_nr_gsber.
                  fc_nr_brnch.
    mac_from_variabel d_h fc_ fc_nr_.
    d_haktif = fc_aktif.
  ENDIF.

**Get KaCab & ADH (from STANDARD TEXT)
  PERFORM f_get_stdtext_tax
          USING 'ZFALST_TYT_' fu_gsber:
                c_name_kaadm fc_name_kaadm,
                c_name_kacab fc_name_kacab,
                c_jab_kaadm  fc_kaadm,
                c_jab_kacab  fc_kacab.
ENDFORM.                    " F_GET_PKP

*&---------------------------------------------------------------------*
*&      Form  F_GET_PKP_HEAD_OFFICE
*&---------------------------------------------------------------------*
*&  This routine retrieves Head office PKP info. This info will only
*&  be retrieved from Head office if only the branch PKP is not
*&  applicable/not found for the selected billing division.
*&---------------------------------------------------------------------*
*&  ->FU_VKORG    - Sales organization / Company code
*&  ->FU_GSBER    - Business Area
*&  ->FU_BRNCH    - Branch
*&  ->FU_BUSLN    - Business line
*&  ->FU_FAKDAT   - Tax processing date
*&  <-FC_PETUGAS  - Tax officer 1
*&  <-FC_PETUGAS2 - Tax officer 2 (bench)
*&  <-FC_AKTIF    - Active indicator
*&                  (1-Tax officer 1 is active;
*&                   2-Tax officer 2 is active)
*&  <-FC_JABAT    - Tax officer 1 official position
*&  <-FC_JABAT2   - Tax officer 2 official position
*&  <-FC_FPONE    - Prefix 1 for Tax form number
*&  <-FC_FPTWO    - Prefix 2 for Tax form number
*&  <-FC_OBJRANGE - Number range object id for the tax form
*&  <-FC_PKPNPWP  - Home NPWP
*&  <-FC_PKPNAME  - PKP name
*&  <-FC_PKPADDRS1- PKP address 1
*&  <-FC_PKPADDRS2- PKP address 2
*&  <-FC_PKPKUH   - PKP
*&  <-FC_PKPCITY  - PKP City
*&  <-FC_PKPPOSTAL- PKP postal code
*&  <-FC_NR_GSBER - Business area used for number range
*&---------------------------------------------------------------------*
FORM f_get_pkp_head_office_old USING    fu_vkorg
                                    fu_gsber
                                    fu_brnch
                                    fu_busln
                                    fu_bukrs
                                    fu_fakdat
                                    fu_fpone
                                    fu_fptwo
                           CHANGING fc_petugas
                                    fc_petugas2
                                    fc_aktif
                                    fc_jabat
                                    fc_jabat2
                                    fc_fpone
                                    fc_fptwo
                                    fc_objrange
                                    fc_pkpnpwp
                                    fc_pkpname
                                    fc_pkpaddrs1
                                    fc_pkpaddrs2
                                    fc_pkpkuh
                                    fc_pkpcity
                                    fc_pkppostal
                                    fc_nr_gsber.

  DATA lt_gsber_head LIKE bseg-gsber.
  DATA lt_pkp_head   LIKE t_pkp OCCURS 1 WITH HEADER LINE.

  SELECT masafrom pkpnpwp vspo pkpname pkpaddrs1 pkpaddrs2 pkpkuh
           pkpcity pkppostal aktif petugas petugas2 jabat jabat2
           fpone fptwo objrange coretax
           INTO CORRESPONDING FIELDS OF TABLE lt_pkp_head
           FROM zgdtxdt0005
* changed by Rama
           WHERE  bukrs     = fu_bukrs       AND
                  brnch     = ''             AND
*           WHERE vkorg     =  fu_vkorg      AND
*                 gsber     =  lt_gsber_head AND
* Changed by rama
                 masafrom <= fu_fakdat.
  IF sy-subrc = 0.
    SORT lt_pkp_head BY masafrom DESCENDING.
    READ TABLE lt_pkp_head INDEX 1.
  ELSE.
    lt_gsber_head = d_gsber_common.
    SELECT masafrom pkpnpwp vspo pkpname pkpaddrs1 pkpaddrs2 pkpkuh
           pkpcity pkppostal aktif petugas petugas2 jabat jabat2
           fpone fptwo objrange coretax
           INTO CORRESPONDING FIELDS OF TABLE lt_pkp_head
           FROM zgdtxdt0005
* changed by Rama
           WHERE  bukrs     = fu_bukrs       AND
                  brnch     = ''             AND
*             WHERE vkorg     = fu_vkorg      AND
*                   gsber     = lt_gsber_head AND
* Changed by rama
                 masafrom <= fu_fakdat.
    IF sy-subrc = 0.
      SORT lt_pkp_head BY masafrom DESCENDING.
      READ TABLE lt_pkp_head INDEX 1.
    ELSE.
      MESSAGE e000(ztx)
              WITH 'Please maintain PKP data for Head office'.
    ENDIF.
  ENDIF.

  fc_petugas   = lt_pkp_head-petugas.
  fc_petugas2  = lt_pkp_head-petugas2.
  fc_aktif     = lt_pkp_head-aktif.
  fc_jabat     = lt_pkp_head-jabat.
  fc_jabat2    = lt_pkp_head-jabat2.
  fc_fpone     = lt_pkp_head-fpone.
  fc_fptwo     = lt_pkp_head-fptwo.
  fc_objrange  = lt_pkp_head-objrange.
  fc_pkpnpwp   = lt_pkp_head-pkpnpwp.
  fc_pkpname   = lt_pkp_head-pkpname.
  fc_pkpaddrs1 = lt_pkp_head-pkpaddrs1.
  fc_pkpaddrs2 = lt_pkp_head-pkpaddrs2.
  fc_pkpkuh    = lt_pkp_head-pkpkuh.
  fc_pkpcity   = lt_pkp_head-pkpcity.
  fc_pkppostal = lt_pkp_head-pkppostal.
  fc_nr_gsber  = lt_gsber_head.

ENDFORM.                    " F_GET_PKP_HEAD_OFFICE


*&---------------------------------------------------------------------*
*&       FORM f_filling_pkp_satuan                                     *
*&---------------------------------------------------------------------*
*&  This routine fills up PKP internal table for Printing function
*&---------------------------------------------------------------------*
*&  ->FU_NORM           - Billing data
*&  ->FU_FAKTUR_TYPE    - Tax form/faktur pajak type
*&  ->FU_WAPU           - WAPU
*&  ->FU_GSBER          - Business area
*&---------------------------------------------------------------------*
FORM f_filling_pkp_satuan_old USING fu_norm LIKE zgdtxdt0002
                                fu_faktur_type
                                fu_wapu
                                fu_gsber
                                fu_brnch
                                fu_busln
                                fu_bukrs
                                fc_line.

  DATA ld_vbeln LIKE t_fpkp-vbeln.
  t_fpkp-fakturno     = fu_norm-fakturno.

  CASE fu_wapu.
    WHEN d_n.
      ld_vbeln = 'A'.
    WHEN d_w.
      ld_vbeln = 'B'.
  ENDCASE.

****removed by Rahmadi
*---not relevant
*  IF fu_norm-rectype NE 'N'.  "-> only for live
*    CASE fu_norm-spart.
*      WHEN d_service.
*        IF fu_norm-spart EQ d_service.
*          CONCATENATE ld_vbeln '-' fu_norm-kwitansi
*                      INTO t_fpkp-vbeln.
*
*          IF fu_norm-pstyv EQ c_pstyv_service.
*            IF fu_wapu EQ d_w.
*              mac_from_variabel d_ d_h d_hnr_.
*            ELSE.
*              IF t_pkp-vspo+1(1) = '1'.
*                mac_from_variabel d_ d_b d_hnr_.
*              ELSE.
*                mac_from_variabel d_ d_h d_hnr_.
*              ENDIF.
*            ENDIF.
*          ELSE.
*            IF t_pkp-vspo+2(1) = '1'.
*              mac_from_variabel d_ d_b d_hnr_.
*            ELSE.
*              mac_from_variabel d_ d_h d_hnr_.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      WHEN d_fin_unit OR d_used OR d_truck.
*        IF t_pkp-vspo+0(1) = '1'.
*          mac_from_variabel d_ d_b d_hnr_.
*        ELSE.
*          mac_from_variabel d_ d_h d_hnr_.
*        ENDIF.
*        CONCATENATE ld_vbeln '-' fu_gsber '-'
*                    fu_norm-vbeln
*                    INTO t_fpkp-vbeln.
*      WHEN d_sparts.
*        IF t_pkp-vspo+2(1) = '1'.
*          mac_from_variabel d_ d_b d_hnr_.
*        ELSE.
*          mac_from_variabel d_ d_h d_hnr_.
*        ENDIF.
*        CONCATENATE ld_vbeln '-' fu_gsber '-'
*                    fu_norm-vbeln
*                    INTO t_fpkp-vbeln.
*      WHEN OTHERS.
*        mac_from_variabel d_ d_h d_hnr_.
*        CONCATENATE ld_vbeln '-' fu_gsber '-'
*                    fu_norm-vbeln
*                    INTO t_fpkp-vbeln.
*    ENDCASE.
*  ELSE.
*    CONCATENATE ld_vbeln '-' fu_gsber '-'
*                fu_norm-vbeln
*                INTO t_fpkp-vbeln.
*  ENDIF.
****end of removal

  t_fpkp-rectype      = fu_norm-rectype.
  t_fpkp-pkpnpwp      = d_pkpnpwp.
  t_fpkp-pkpkuh       = d_pkpkuh.
  t_fpkp-pkpname      = d_pkpname.
  t_fpkp-pkpaddrs1    = d_pkpaddrs1.
  t_fpkp-pkpaddrs2    = d_pkpaddrs2.
  t_fpkp-waers        = fu_norm-itcurr.
  t_fpkp-kwitansi     = fu_norm-kwitansi.
  IF fu_norm-spart EQ d_service.
    IF fc_line < c_kwitansi.
      t_fpkp-faktur_type = ' '.
    ELSE.
      t_fpkp-faktur_type  = fu_faktur_type.
    ENDIF.
  ELSE.
    t_fpkp-faktur_type  = fu_faktur_type.
  ENDIF.
  t_fpkp-spart        = fu_norm-spart.
  APPEND t_fpkp.

ENDFORM.                    " F_FILLING_PKP_SATUAN

*&---------------------------------------------------------------------*
*&      Form  f_lock_tax_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fu_BUKRS  text
*      -->fu_BRNCH  text
*      -->fu_MASATX  text
*----------------------------------------------------------------------*
FORM f_lock_tax_period USING    fu_brnch
                       CHANGING fc_subrc.

  DATA ld_user LIKE sy-msgv1.

  CALL FUNCTION 'ENQUEUE_EZGDTXDT0004'
    EXPORTING
      mode_zgdtxdt0004 = 'E'
      mandt            = sy-mandt
*     BUKRS            =
      brnch            = fu_brnch
*     MASATX           =
*     X_BUKRS          = ' '
*     X_BRNCH          = ' '
*     X_MASATX         = ' '
*     _SCOPE           = '2'
*     _WAIT            = ' '
*     _COLLECT         = ' '
    EXCEPTIONS
      foreign_lock     = 1
      system_failure   = 2
      OTHERS           = 3.
  fc_subrc = sy-subrc.
  ld_user = sy-msgv1.
  IF fc_subrc <> 0.
    IF fc_subrc = 1.
      MESSAGE e000(zab) WITH 'Tax period is locked by'
                             ld_user.
    ELSE.
      MESSAGE e000(zab) WITH 'System failure'.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_lock_tax_period

*---------------------------------------------------------------------*
*       FORM f_unlock_tax_period                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_BRNCH                                                      *
*---------------------------------------------------------------------*
FORM f_unlock_tax_period USING    fu_brnch.

  CALL FUNCTION 'DEQUEUE_EZGDTXDT0004'
    EXPORTING
      mode_zgdtxdt0004 = 'E'
      mandt            = sy-mandt
*     BUKRS            =
      brnch            = fu_brnch
*     MASATX           =
*     X_BUKRS          = ' '
*     X_BRNCH          = ' '
*     X_MASATX         = ' '
*     _SCOPE           = '3'
*     _SYNCHRON        = ' '
*     _COLLECT         = ' '
    .

ENDFORM.                    "f_unlock_tax_period

*&---------------------------------------------------------------------*
*&      Form  f_check_tax_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_tax_period CHANGING fc_subrc LIKE sy-subrc.

  DATA ld_status.
  DATA ld_uname LIKE sy-uname.
  DATA: tx04usr LIKE indx-srtfd VALUE 'ZGDTXDT0106'.

  CALL FUNCTION 'Z_GDTXFC_CHECK_TAX_PERIOD'
    IMPORTING
      fe_status                    = ld_status
      fe_uname                     = ld_uname
    EXCEPTIONS
      program_running              = 1
      tax_period_program_not_found = 2
      OTHERS                       = 3.
  fc_subrc = sy-subrc.
  IF fc_subrc <> 0.
    CASE fc_subrc.
      WHEN 1.
        IMPORT zgdtxdt0106-uname FROM MEMORY ID tx04usr.
        ld_uname = zgdtxdt0106-uname.
        MESSAGE i000(zab) WITH 'Tax period program is still locked by'
                               ld_uname.
      WHEN 2.
        MESSAGE i000(zab) WITH 'Please maintain Tax period program to'
                               'ZGDTXDT0106 table'.
    ENDCASE.
    EXIT.
  ENDIF.

ENDFORM.                    " f_check_tax_period

*&---------------------------------------------------------------------*
*&      Form  f_display_billing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_billing.

  DATA ld_line TYPE i.

*-- get the current index selected by user
  GET CURSOR LINE ld_line.
*  READ TABLE t_vbrkscr INDEX ld_line.
*  IF sy-subrc = 0 AND t_vbrkscr-vbeln <> ''.
  SET PARAMETER ID 'VF' FIELD t_vbrkscr-vbeln.
  CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
*  ENDIF.

ENDFORM.                    " f_display_billing



**********added by ibm_humayun performance tuning**********************
*&---------------------------------------------------------------------*
*&      Form  F_GET_PRICE_HASHED
*&---------------------------------------------------------------------*
*&  This routine retrieves all tax-related prices of the selected
*&  billings. All the tax-related prices have their pricing procedure
*&  and pricing condition defined in ZGDTXDt0008 table
*&---------------------------------------------------------------------*
*&  ->FT_VBRK      - Billing table
*&  ->FU_VKORG     - Sales organization / Company code
*&  ->FU_SPART     - Division
*&  <-FT_PRICEALL  - Internal table containing all prices for each
*&                   billing item
*&---------------------------------------------------------------------*
FORM f_get_price_hashed TABLES    ft_vbrk     STRUCTURE t_vbrk
                        CHANGING  ft_priceall TYPE HASHED TABLE.

  DATA lt_vbrk LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
  DATA ld_from LIKE sy-tabix.
  DATA ld_to   LIKE sy-tabix.
  RANGES: lr_kalsm FOR vbrk-kalsm.

  DATA  BEGIN OF lt_konv OCCURS 1.
  DATA: knumv LIKE konv-knumv,
        kposn LIKE konv-kposn,
        kschl LIKE konv-kschl,
        kwert LIKE konv-kwert,
        kbetr LIKE konv-kbetr,
        waers LIKE konv-waers.
  DATA  END   OF lt_konv.

  DATA lw_konv LIKE lt_konv.

  DATA  BEGIN OF lt_price OCCURS 1.
  DATA: kalsm    LIKE zgdtxdt0008-kalsm,
        ptype    LIKE zgdtxdt0008-ptype,
        indicate LIKE zgdtxdt0008-indicate,
        ppnbmflg LIKE zgdtxdt0008-ppnbmflg,
        kartv    LIKE zgdtxdt0008-kartv.
  DATA  END   OF lt_price.

  DATA lw_price LIKE lt_price.

  DATA: ld_subrc    LIKE sy-subrc,
        ld_idx1     LIKE sy-tabix,
        ld_kwert    LIKE konv-kwert,
        ld_kbetr    LIKE konv-kbetr,
        ld_notfound.

  DATA: wa_pricehashed   TYPE type_priceall.


  REFRESH: lr_kalsm.

**Get Billing pricing procedure
  IF NOT ft_vbrk[] IS INITIAL.
    ld_from = 1.
    ld_to   = c_max_ritems_max.
    REFRESH: lt_konv.
    DO.
      REFRESH: lt_vbrk.
      LOOP AT ft_vbrk FROM ld_from TO ld_to.
        lt_vbrk-knumv = ft_vbrk-knumv.
        lt_vbrk-posnr = ft_vbrk-posnr.
        APPEND lt_vbrk.

*       required in selection below from table ZGDTXDT0008
        lr_kalsm-low = ft_vbrk-kalsm.
        APPEND lr_kalsm.

      ENDLOOP.
      IF lt_vbrk[] IS INITIAL. EXIT. ENDIF.
      SELECT knumv kposn kschl kwert kbetr waers
             APPENDING CORRESPONDING FIELDS OF TABLE lt_konv
             FROM konv
             FOR ALL ENTRIES IN lt_vbrk
             WHERE knumv = lt_vbrk-knumv AND
                   kposn = lt_vbrk-posnr AND
*--- Added by Rama
*    No need to consider accrual conditions so KRUEK will be 'X'
*    Using rebate condition system creates two lines with same condition
*    type but one is used to offset accrual and other for actual credit
*    posting
                   kruek = ' ' AND
*--- End of Addition
***added for Tempo -- Take ACTIVE condition ONLY
                   kinak = ' '.
***end of Tempo addition
      ld_from = ld_from + c_max_ritems_max.
      ld_to   = ld_to   + c_max_ritems_max.
    ENDDO.

    IF NOT lt_konv[] IS INITIAL.
      CLEAR: ld_from, ld_to.
******Get price
      REFRESH lt_price.
      ld_from = 1.
      ld_to = c_max_ritems.
      SORT lr_kalsm BY low.
      DELETE ADJACENT DUPLICATES FROM lr_kalsm COMPARING low.
      IF NOT lr_kalsm[] IS INITIAL.
        SELECT kalsm kartv ptype indicate ppnbmflg
               APPENDING CORRESPONDING FIELDS OF TABLE lt_price
               FROM zgdtxdt0008
               FOR ALL ENTRIES IN lr_kalsm
               WHERE kalsm EQ lr_kalsm-low.
      ENDIF.

      IF NOT lt_price[] IS INITIAL.
        SORT ft_vbrk BY kalsm knumv posnr.
        SORT lt_price BY kalsm ptype kartv.
        DELETE ADJACENT DUPLICATES FROM lt_price
                                   COMPARING kalsm ptype kartv.
        SORT lt_konv BY knumv kposn kschl.
*-------  Assign the prices to the billing items
        CLEAR: lw_konv, lw_price, ld_notfound.
        LOOP AT ft_vbrk.
          READ TABLE lt_price WITH KEY kalsm = ft_vbrk-kalsm
                              BINARY SEARCH.
          IF sy-subrc = 0.
            ld_idx1 = sy-tabix.
            LOOP AT lt_price.
              MOVE-CORRESPONDING lt_price TO lw_price.
              IF lw_price-kalsm = ft_vbrk-kalsm.
                READ TABLE lt_konv WITH KEY knumv = ft_vbrk-knumv
                                            kposn = ft_vbrk-posnr
                                            kschl = lw_price-kartv
                                            BINARY SEARCH.
                IF sy-subrc = 0.
                  IF lw_price-ptype = d_ptype_mex OR
                     lw_price-ptype = d_ptype_min.
                    macro_price_normalization lt_konv-kwert.
                    IF lt_konv-kwert > ld_kwert.
                      ld_kwert      = lt_konv-kwert.
                    ENDIF.
                  ELSE.
                    ld_kwert = ld_kwert + lt_konv-kwert.
                    ld_kbetr = lt_konv-kbetr.
                  ENDIF.
                ENDIF.
              ELSE.
                CONTINUE.
              ENDIF.
              AT END OF ptype.
                IF NOT ld_kwert IS INITIAL.
                  macro_price_normalization ld_kwert.
                  macro_price_normalization ld_kbetr.
*                  ft_priceall-vbeln    = ft_vbrk-vbeln.
*                  ft_priceall-posnr    = ft_vbrk-posnr.
*                  ft_priceall-ptype    = lw_price-ptype.
*                  ft_priceall-indicate = lw_price-indicate.
*                  ft_priceall-ppnbmflg = lw_price-ppnbmflg.
*                  ft_priceall-kwert    = ld_kwert.
*                  ft_priceall-kbetr    = ld_kbetr.
*                  ft_priceall-waers    = lt_konv-waers.
*                  APPEND ft_priceall.

                  wa_pricehashed-vbeln    = ft_vbrk-vbeln.
                  wa_pricehashed-posnr    = ft_vbrk-posnr.
                  wa_pricehashed-ptype    = lw_price-ptype.
                  wa_pricehashed-indicate = lw_price-indicate.
                  wa_pricehashed-ppnbmflg = lw_price-ppnbmflg.
                  wa_pricehashed-kwert    = ld_kwert.
                  wa_pricehashed-kbetr    = ld_kbetr.
                  wa_pricehashed-waers    = lt_konv-waers.
                  INSERT wa_pricehashed INTO TABLE ft_priceall.
                ENDIF.
                CLEAR: ld_kwert, ld_kbetr, ld_notfound.
              ENDAT.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
*       SORT ft_priceall BY vbeln posnr ptype.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_PRICE_hashed



*&---------------------------------------------------------------------*
*&      Form  F_AMOUNTS_HASHED
*&---------------------------------------------------------------------*
*&  This routine determines all the tax-related price amount based of
*&  the selected billing
*&---------------------------------------------------------------------*
*&  ->FU_VBRK     - Billing data
*&  ->FU_TAX      - VAT amount
*&  <-FC_ITAMT    - Selling price amount
*&  <-FC_ITDISC   - Discount amount
*&  <-FC_DPP      - DPP amount
*&  <-FC_PPN      - PPN amount
*&  <-FC_PPNBM    - PPNBM amount
*&  <-FC_XPPNBM   - XPPNBM amount
*&  <-FC_ITOTH    - Others amount
*&  <-FC_ITQTY    - Quantity
*&  <-FC_EXAMT    - Selling price (tax-exclusive)
*&  <-FC_INAMT    - Selling price (tax-inclusive)
*&  <-FC_ITDISCEX - Discount (tax-exclusive) amount
*&  <-FC_ITDISCIN - Discount (tax-inclusive) amount
*&  <-FC_STNK     - STNK price
*&---------------------------------------------------------------------*
FORM f_amounts_hashed USING    fu_vbrk LIKE t_vbrk
                        fu_tax
               CHANGING fc_itamt
                        fc_itdisc
                        fc_dpp
                        fc_ppn
                        fc_ppnbm
                        fc_xppnbm
                        fc_itoth
                        fc_itqty
                        fc_examt
                        fc_inamt
                        fc_itdiscex
                        fc_itdiscin
                        fc_stnk
                        fc_pph22
                        fc_pph23.

  DATA ld_itdisc1 LIKE konv-kwert.
  DATA ld_itdisc2 LIKE konv-kwert.
  DATA ld_itdisc1ex LIKE konv-kwert.
  DATA ld_itdisc2ex LIKE konv-kwert.
  DATA ld_itdisc1in LIKE konv-kwert.
  DATA ld_itdisc2in LIKE konv-kwert.

  CLEAR: fc_itamt,
         fc_itdisc,
         fc_dpp,
         fc_ppn,
         fc_ppnbm,
         fc_xppnbm,
         fc_itoth,
         fc_itqty,
         fc_examt,
         fc_inamt,
         fc_itdiscex,
         fc_itdiscin,
         fc_stnk,
         fc_pph22,
         fc_pph23.

**Determine PPNBM
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
*                            WITH KEY vbeln  = fu_vbrk-vbelv
                            WITH KEY vbeln  = fu_vbrk-vbeln
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_ppnbm.
  fc_ppnbm = wa_priceallhashed-kwert.

**Determine PRICE (INCLUDE or EXCLUDE tax)
  PERFORM f_determine_price_hashed  USING fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_pex
                                      d_ptype_pin
                                      d_ptype_pl
                                      fc_ppnbm
                                      fu_tax
                             CHANGING fc_itamt
                                      fc_examt
                                      fc_inamt.

**Determine DISCOUNT SUM (INCLUDE or EXCLUDE tax)
  PERFORM f_determine_amount_hashed
                             USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_dex
                                      d_ptype_din
                                      fu_tax
                             CHANGING ld_itdisc1
                                      ld_itdisc1ex
                                      ld_itdisc1in.

**Determine DISCOUNT MAX (INCLUDE or EXCLUDE tax)
  PERFORM f_determine_amount_hashed
                             USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_mex
                                      d_ptype_min
                                      fu_tax
                             CHANGING ld_itdisc2
                                      ld_itdisc2ex
                                      ld_itdisc2in.

**Determine DISCOUNT METHOD (MAX or SUM)
  IF NOT ld_itdisc1 IS INITIAL.
    fc_itdisc = ld_itdisc1.
  ELSE.
    fc_itdisc = ld_itdisc2.
  ENDIF.

  IF NOT ld_itdisc1ex IS INITIAL.
    fc_itdiscex = ld_itdisc1ex.
  ELSE.
    fc_itdiscex = ld_itdisc2ex.
  ENDIF.

  IF NOT ld_itdisc1in IS INITIAL.
    fc_itdiscin = ld_itdisc1in.
  ELSE.
    fc_itdiscin = ld_itdisc2in.
  ENDIF.

**Determine DPP
  fc_dpp = fu_vbrk-examt - fu_vbrk-itdiscex.

**Determine tax
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
*                            WITH KEY vbeln  = fu_vbrk-vbelv
                            WITH KEY vbeln  = fu_vbrk-vbeln
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_vatout.
  fc_ppn = wa_priceallhashed-kwert.


**Determine XPPNBM
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
*                            WITH KEY vbeln  = fu_vbrk-vbelv
                            WITH KEY vbeln  = fu_vbrk-vbeln
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_xppnbm.
  fc_xppnbm = wa_priceallhashed-kwert.

**Determine OTHER
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
*                            WITH KEY vbeln  = fu_vbrk-vbelv
                            WITH KEY vbeln  = fu_vbrk-vbeln
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_other.
  fc_itoth = wa_priceallhashed-kwert.

**Determine STNK
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
*                            WITH KEY vbeln  = fu_vbrk-vbelv
                            WITH KEY vbeln  = fu_vbrk-vbeln
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_stnk.
  fc_stnk = wa_priceallhashed-kwert.

**Determine quantity
  fc_itqty = fu_vbrk-fkimg.

****Added by Rahmadi
*-Determine PPh 22 amount
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
*                            WITH KEY vbeln  = fu_vbrk-vbelv
                            WITH KEY vbeln  = fu_vbrk-vbeln
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_pph22.
  fc_pph22 = wa_priceallhashed-kwert.

*-Determine PPh 23 amount
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
*                            WITH KEY vbeln  = fu_vbrk-vbelv
                            WITH KEY vbeln  = fu_vbrk-vbeln
                                     posnr = fu_vbrk-posnr
                                     ptype = d_ptype_pph23.
  fc_pph23 = wa_priceallhashed-kwert.

****End of addition

ENDFORM.                    " F_AMOUNTS_HASHED

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_PRICE_HASHED
*&---------------------------------------------------------------------*
*&  This routine determines how the price will be displayed in the Tax
*&  form (Faktur pajak). It is possible that price is tax-inclusive or
*&  tax-exclusive. If a price is PPNBM inclusive, PPNBM amount must be
*&  excluded from the price.
*&---------------------------------------------------------------------*
*&  ->FT_VBELN    - Billing number
*&  ->FU_POSNR    - Billing item number
*&  ->FU_PTYPE1   - Price type 1 (tax-exclusive)
*&  ->FU_TYPE2    - Price type 2 (tax-inclusive)
*&  ->FU_TAX      - VAT amount
*&  ->FU_PPNBM    - PPNBM amount
*&  <-FC_AMOUNT   - Price amount
*&  <-FC_EXAMT    - Price amount (tax-exclusive)
*&  <-FC_INAMT    - Price amount (tax-inclusive)
*&---------------------------------------------------------------------*
FORM f_determine_price_hashed
                       USING fu_vbeln  fu_posnr fu_ptype1 fu_ptype2
                             fu_ptype3 fu_ppnbm fu_tax
                    CHANGING fc_amount fc_examt fc_inamt.

  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                        WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 ptype = fu_ptype1.
  IF sy-subrc = 0.
    fc_amount = wa_priceallhashed-kwert.
  ELSE.
    READ TABLE t_priceall_hashed INTO wa_priceallhashed
                          WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   ptype = fu_ptype2.
    fc_amount = wa_priceallhashed-kwert.
  ENDIF.

*- For another condition type ( PL )
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                       WITH KEY vbeln = fu_vbeln
                                posnr = fu_posnr
                                ptype = fu_ptype3.
  IF sy-subrc = 0.
    fc_amount = fc_amount + wa_priceallhashed-kwert.
  ENDIF.

*----------------------------------------------------------------------*
* Changed by rama
***Exclude PPNBM if it is included in the amount
  IF fc_amount <> 0 AND wa_priceallhashed-ppnbmflg = d_include_tax.
    fc_amount = fc_amount - fu_ppnbm.
  ENDIF.
*----------------------------------------------------------------------*

**Get Amount with Tax Exclusion/Inclusion
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                        WITH KEY vbeln    = fu_vbeln
                                 posnr    = fu_posnr
                                 indicate = d_exclude_tax.
  IF sy-subrc = 0.
    fc_examt = fc_amount.
    fc_inamt = fc_amount + ( fu_tax * fc_amount ).
  ELSE.
    READ TABLE t_priceall_hashed INTO wa_priceallhashed
                          WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   indicate = d_include_tax.
    IF sy-subrc = 0.
      fc_inamt = fc_amount.
      fc_examt = fc_amount / ( fu_tax + 1 ).
    ELSE.
      fc_examt = fc_amount.
      fc_inamt = fc_amount.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_DETERMINE_PRICE_HASHED

*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_AMOUNT_HASHED
*&---------------------------------------------------------------------*
*&  This routine determines how the price will be displayed in the Tax
*&  form (Faktur pajak). It is only applicable for the price type that
*&  has possibility to be tax-inclusive or tax-exclusive.
*&---------------------------------------------------------------------*
*&  ->FT_VBELN    - Billing number
*&  ->FU_POSNR    - Billing item number
*&  ->FU_PTYPE1   - Price type 1 (tax-exclusive)
*&  ->FU_TYPE2    - Price type 2 (tax-inclusive)
*&  ->FU_TAX      - VAT amount
*&  <-FC_AMOUNT   - Price amount
*&  <-FC_EXAMT    - Price amount (tax-exclusive)
*&  <-FC_INAMT    - Price amount (tax-inclusive)
*&---------------------------------------------------------------------*
FORM f_determine_amount_hashed USING   fu_vbeln
                                fu_posnr
                                fu_ptype1
                                fu_ptype2
                                fu_tax
                       CHANGING fc_amount
                                fc_examt
                                fc_inamt.
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                        WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 ptype = fu_ptype1.
  IF sy-subrc = 0.
    fc_amount = wa_priceallhashed-kwert.
  ELSE.
    READ TABLE t_priceall_hashed INTO wa_priceallhashed
                          WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   ptype = fu_ptype2.
    IF sy-subrc = 0.
      fc_amount = wa_priceallhashed-kwert.
    ELSE.
      fc_amount = 0.
    ENDIF.
  ENDIF.

**Get Amount with Tax Exclusion/Inclusion
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                        WITH KEY vbeln = fu_vbeln
                                 posnr = fu_posnr
                                 indicate = d_exclude_tax.
  IF sy-subrc = 0.
    fc_examt = fc_amount.
    fc_inamt = fc_amount + ( fu_tax * fc_amount ).
  ELSE.
    READ TABLE t_priceall_hashed INTO wa_priceallhashed
                          WITH KEY vbeln = fu_vbeln
                                   posnr = fu_posnr
                                   indicate = d_include_tax.
    IF sy-subrc = 0.
      fc_inamt = fc_amount.
      fc_examt = fc_amount / ( fu_tax + 1 ).
    ELSE.
      fc_examt = fc_amount.
      fc_inamt = fc_amount.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_DETERMINE_AMOUNT_HASHED


*&---------------------------------------------------------------------*
*&      form  f_price_adjustment_HASHED
*&---------------------------------------------------------------------*
*&  This routine proceeds follow-up documents of a normal billing if the
*&  follow-up document type is Price adjustment
*&---------------------------------------------------------------------*
*&  ->FU_VBRK     - Normal billing data
*&  ->FU_TAX      - VAT amount
*&  <-FC_ITAMT    - Selling price amount after price adjustment
*&  <-FC_ITDISC   - Discount amount after price adjustment
*&  <-FC_PPN      - PPN amount after price adjustment
*&  <-FC_ITOTH    - Others amount after price adjustment
*&  <-FC_EXAMT    - Selling price (tax-exclusive) amount after
*&                  price adjustment
*&  <-FC_INAMT    - Selling price (tax-inclusive) amount after
*&                  price adjustment
*&  <-FC_ITDISCEX - Discount (tax-exclusive) amount after price
*&                  adjustment
*&  <-FC_ITDISCIN - Discount (tax-inclusive) amount after price
*&                  adjustment
*&---------------------------------------------------------------------*
FORM f_price_adjustment_hashed USING     fu_vbrk LIKE t_vbrk
                                  fu_tax
                     CHANGING     fc_itamt
                                  fc_itdisc
                                  fc_itoth
                                  fc_ppn
                                  fc_examt
                                  fc_inamt
                                  fc_itdiscex
                                  fc_itdiscin
****added by Rahmadi
*--To store PPH 22 & PPH 23 info from the invoices
                                  fc_pph22
                                  fc_pph23.
****end of addition

  DATA: ld_itamt1 LIKE konv-kwert,
        ld_itamt2 LIKE konv-kwert,
        ld_itamt3 LIKE konv-kwert,
        ld_tax1   LIKE konv-kbetr,
        ld_examt1 LIKE konv-kwert,
        ld_inamt1 LIKE konv-kwert.

**Determine NEW PRICE (INCLUDE or EXCLUDE tax)
  PERFORM f_determine_amount_hashed
                             USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_npex
                                      d_ptype_npin
                                      fu_tax
                             CHANGING ld_itamt1
                                      ld_examt1
                                      ld_inamt1.

**EXCEPTION for KTB
**Determine NEW PRICE (for KTB)
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                            WITH KEY vbeln  = fu_vbrk-vbelv
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_nz.
  ld_itamt2 = wa_priceallhashed-kwert.

  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                            WITH KEY vbeln  = fu_vbrk-vbelv
                                      posnr = fu_vbrk-posnv
                                      ptype = d_ptype_pl.
  ld_itamt3 = wa_priceallhashed-kwert.

**Determine FIRST TAX
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                            WITH KEY vbeln  = fu_vbrk-vbelv
                                      posnr = fu_vbrk-posnv
                                      ptype = d_ptype_taxin.
  ld_tax1 = wa_priceallhashed-kbetr.

  ld_tax1 = ld_tax1 / d_taxfactor.

**Total NEW PRICE
  fc_itamt = ld_itamt1 + ld_itamt2 + ( ld_itamt2 * ld_tax1 )
                       + ld_itamt3 + ( ld_itamt3 * ld_tax1 ).
  fc_examt = ld_examt1 + ld_itamt2 + ( ld_itamt2 * ld_tax1 )
                       + ld_itamt3 + ( ld_itamt3 * ld_tax1 ).
  fc_inamt = ld_inamt1 + ld_itamt2 + ( ld_itamt2 * ld_tax1 )
                       + ld_itamt3 + ( ld_itamt3 * ld_tax1 ).

**Determine NEW DISCOUNT (INCLUDE or EXCLUDE TAX)
  PERFORM f_determine_amount_hashed
                             USING    fu_vbrk-vbeln
                                      fu_vbrk-posnr
                                      d_ptype_ndex
                                      d_ptype_ndin
                                      fu_tax
                             CHANGING fc_itdisc
                                      fc_itdiscex
                                      fc_itdiscin.

**Determine NEW OTHER
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                            WITH KEY vbeln  = fu_vbrk-vbelv
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_nother.
  fc_itoth = wa_priceallhashed-kwert.

**Determine tax
  fc_ppn = fu_vbrk-mwsbp.

****added by Rahmadi
**Determine PPh 22
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                            WITH KEY vbeln  = fu_vbrk-vbelv
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_pph22.
  fc_pph22 = wa_priceallhashed-kwert.

**Determine PPh 23
  CLEAR: wa_priceallhashed.
  READ TABLE t_priceall_hashed INTO wa_priceallhashed
                            WITH KEY vbeln  = fu_vbrk-vbelv
                                      posnr = fu_vbrk-posnr
                                      ptype = d_ptype_pph23.
  fc_pph23 = wa_priceallhashed-kwert.

****end of addition

ENDFORM.                    " F_PRICE_ADJUSTMENT_HASHED

*&---------------------------------------------------------------------*
*&      Form  f_determine_old_price
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_VBRK   text
*      <--FP_VALUE  text
*----------------------------------------------------------------------*
FORM f_determine_old_price USING    fu_vbrk LIKE t_vbrk
                                    fu_tax
                           CHANGING fc_value_ex
                                    fc_value_in
                                    fc_value.

  DATA: ld_vbelv LIKE fu_vbrk-vbelv,
        ld_posnv LIKE fu_vbrk-posnr.


  ld_vbelv = fu_vbrk-vbelv.
  ld_posnv = fu_vbrk-posnv.

  READ TABLE t_priceall WITH KEY vbeln = ld_vbelv
                                 posnr = ld_posnv
                                 ptype = d_ptype_pex
                                 BINARY SEARCH.
  IF sy-subrc = 0.
    fc_value = t_priceall-kwert.
    fc_value_ex = t_priceall-kwert.
    fc_value_in = t_priceall-kwert + ( fu_tax * t_priceall-kwert ).
  ELSE.
    READ TABLE t_priceall WITH KEY vbeln = ld_vbelv
                                   posnr = ld_posnv
                                   ptype = d_ptype_pin
                                   BINARY SEARCH.
    IF sy-subrc = 0.
      fc_value = t_priceall-kwert.
      fc_value_in = t_priceall-kwert.
      fc_value_ex = t_priceall-kwert / ( fu_tax + 1 ).
    ELSE.
      fc_value = fc_value_in = fc_value_ex = 0.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_determine_old_price

*&---------------------------------------------------------------------*
*&      Form  f_get_payment_term
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_VBRK1  text
*----------------------------------------------------------------------*
FORM f_get_payment_term TABLES   ft_vbrk1 STRUCTURE t_vbrk1.

  DATA lt_zterm LIKE t_vbrk1 OCCURS 10 WITH HEADER LINE.

  lt_zterm[] = ft_vbrk1[].
  SORT lt_zterm BY zterm.
  DELETE ADJACENT DUPLICATES FROM lt_zterm COMPARING zterm.

  IF lt_zterm[] IS NOT INITIAL.
    SELECT zterm ztag1
           INTO TABLE t_t052
           FROM t052
           FOR ALL ENTRIES IN lt_zterm
           WHERE zterm = lt_zterm-zterm.
    SORT t_t052 BY zterm.
  ENDIF.

ENDFORM.                    " f_get_payment_term

*&---------------------------------------------------------------------*
*&      Form  f_get_payment_days
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_ZTERM  text
*      <--FC_ZTAG1  text
*----------------------------------------------------------------------*
FORM f_get_payment_days USING    fu_zterm
                        CHANGING fc_ztag1.

  READ TABLE t_t052 WITH KEY zterm = fu_zterm
                    BINARY SEARCH.
  IF sy-subrc = 0.
    fc_ztag1 = t_t052-ztag1.
  ELSE.
    CLEAR fc_ztag1.
  ENDIF.

ENDFORM.                    " f_get_payment_days

*&---------------------------------------------------------------------*
*&      Form  f_check_tax_closing_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fu_MASATX  text
*      <--fc_SUBRCN  text
*----------------------------------------------------------------------*
FORM f_check_tax_closing_period USING    fu_vbrk STRUCTURE t_vbrk
                                CHANGING fc_subrcn.

  SELECT SINGLE * FROM zgdtxdt0004
                  WHERE bukrs = fu_vbrk-bukrs AND
                        brnch = fu_vbrk-brnch AND
                        masatx = fu_vbrk-masatx.
  IF sy-subrc = 0.
    IF zgdtxdt0004-closedat IS INITIAL.
      fc_subrcn = 0.
    ELSE.
      fc_subrcn = 1.
      MOVE-CORRESPONDING fu_vbrk TO t_error.
      CONCATENATE 'Tax period'
                  fu_vbrk-masatx
                  'has been closed'
                  INTO t_error-msg
                  SEPARATED BY space.
      APPEND t_error.
    ENDIF.
  ELSE.
    fc_subrcn = 2.
    MOVE-CORRESPONDING fu_vbrk TO t_error.
    CONCATENATE 'Tax period'
                fu_vbrk-masatx
                'has not been opened'
                INTO t_error-msg
                SEPARATED BY space.
    APPEND t_error.
  ENDIF.

ENDFORM.                    " f_check_tax_closing_period

*&---------------------------------------------------------------------*
*&      Form  f_get_open_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_open_period USING fu_brnch.

***added for Tempo
  CLEAR: t_period, t_period[].
  SELECT * INTO TABLE t_period
           FROM zgdtxdt0004
           WHERE brnch = fu_brnch AND
                 closedat = '00000000'.
  SORT t_period BY brnch masatx.
  LOOP AT t_period.
    CLEAR r_per.
    r_per-sign = 'I'.
    r_per-option = 'EQ'.
    r_per-low = t_period-masatx.
    APPEND r_per.
  ENDLOOP.
***end of Tempo addition

ENDFORM.                    " f_get_open_period

*---------------------------------------------------------------------*
*       FORM f_billing_lock                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_billing_lock TABLES ft_vbrk STRUCTURE t_vbrk.

  DATA lw_vbrk LIKE t_vbrk.
  DATA ld_subrc LIKE sy-subrc.
  DATA ld_user LIKE sy-msgv1.

****Lock selected billings
  IF d_rpc IS INITIAL.
    LOOP AT ft_vbrk.
      MOVE-CORRESPONDING ft_vbrk TO lw_vbrk.
      AT NEW vbeln.
        CLEAR ld_subrc.
        PERFORM f_lock_billing USING    lw_vbrk
                               CHANGING ld_subrc
                                        ld_user.
        PERFORM f_process_locked_norm_billing USING lw_vbrk
                                                    ld_user
                                                    ld_subrc.
      ENDAT.
      AT END OF vbeln.
        IF ld_subrc <> 0.
          DELETE ft_vbrk WHERE vbeln =  lw_vbrk-vbeln.
        ENDIF.
      ENDAT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "f_billing_lock


*&---------------------------------------------------------------------*
*&      Form  f_get_printer_def
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_printer_def USING fu_uname
                       CHANGING fc_print.

  CLEAR fc_print.
  SELECT SINGLE spld INTO fc_print
                     FROM usr01
                     WHERE bname = fu_uname.

ENDFORM.                    " f_get_printer_def

*&---------------------------------------------------------------------*
*&      Form  f_modify_tgl_faktur_pajak
*&---------------------------------------------------------------------*
FORM f_modify_tgl_faktur_pajak  USING    fu_brnch fu_vbeln
                                CHANGING fc_fakdat.
  DATA: ld_vbelv  LIKE vbfa-vbelv.

  IF fu_brnch = '8360'.
    SELECT SINGLE vbelv INTO ld_vbelv FROM vbfa
      WHERE vbeln   EQ fu_vbeln
        AND vbtyp_n EQ '5'
        AND vbtyp_v EQ 'J'.
    IF sy-subrc <> 0.
      SELECT SINGLE vbelv INTO ld_vbelv FROM vbfa
        WHERE vbeln   EQ fu_vbeln
          AND vbtyp_v EQ 'J'.
    ENDIF.
  ELSE.
    SELECT SINGLE vbelv INTO ld_vbelv FROM vbfa
      WHERE vbeln   EQ fu_vbeln
        AND vbtyp_v EQ 'J'.
  ENDIF.

  IF sy-subrc EQ 0.
    SELECT SINGLE wadat_ist INTO fc_fakdat FROM likp
           WHERE vbeln = ld_vbelv.
  ENDIF.
ENDFORM.                    " f_modify_tgl_faktur_pajak

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_FAKTUNO
*&---------------------------------------------------------------------*
FORM f_modify_faktuno  USING    fu_vbeln fu_gjahr
                       CHANGING fc_fakturno.
  DATA: lv_mwskz  TYPE bset-mwskz.

  SELECT SINGLE mwskz
    FROM bset
    INTO lv_mwskz
    WHERE bukrs IN ('8050', '8800')
      AND belnr EQ fu_vbeln
      AND gjahr EQ fu_gjahr.

  IF lv_mwskz EQ 'K3' OR lv_mwskz EQ 'K7'.
    IF fc_fakturno(2) NE '09'.
      CONCATENATE '05' fc_fakturno+2(15) INTO fc_fakturno.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_FAKTUNO

*&---------------------------------------------------------------------*
*&      Form  F_GET_UANG_MUKA
*&---------------------------------------------------------------------*
FORM f_get_uang_muka  TABLES   ft_vbrkscr STRUCTURE t_vbrkscr
                               ft_vbrk1   STRUCTURE t_vbrk1.
  DATA: lt_bkpf TYPE TABLE OF bkpf WITH HEADER LINE,
        lt_bseg TYPE TABLE OF bseg WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_vbrkscr> LIKE t_vbrkscr.

  SELECT bukrs belnr gjahr xblnr bstat
    INTO CORRESPONDING FIELDS OF TABLE lt_bkpf
    FROM bkpf FOR ALL ENTRIES IN ft_vbrk1
    WHERE bukrs EQ ft_vbrk1-vkorg
      AND bstat EQ space
      AND xblnr EQ ft_vbrk1-xblnr
      AND blart EQ 'DR'.

  IF sy-subrc = 0.
    SELECT bukrs belnr gjahr buzei dmbtr hkont
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg
      FROM bseg FOR ALL ENTRIES IN lt_bkpf
      WHERE bukrs EQ lt_bkpf-bukrs
        AND belnr EQ lt_bkpf-belnr
        AND gjahr EQ lt_bkpf-gjahr
        AND hkont EQ '0318120100'.
  ENDIF.

  SORT: lt_bkpf BY bukrs belnr gjahr,
        lt_bseg BY bukrs belnr gjahr,
        ft_vbrk1 BY vbeln,
        ft_vbrkscr BY vbeln.

  LOOP AT lt_bseg.
    READ TABLE lt_bkpf WITH KEY bukrs = lt_bseg-bukrs
                                belnr = lt_bseg-belnr
                                gjahr = lt_bseg-gjahr BINARY SEARCH.
    IF sy-subrc = 0.
      READ TABLE ft_vbrk1 WITH KEY xblnr = lt_bkpf-xblnr.
      IF sy-subrc = 0.
        READ TABLE ft_vbrkscr ASSIGNING <fs_vbrkscr>
                              WITH KEY vbeln = ft_vbrk1-vbeln.
        IF sy-subrc = 0.
          <fs_vbrkscr>-dplast = lt_bseg-dmbtr.
          <fs_vbrkscr>-itamtlast = <fs_vbrkscr>-itamtlast - <fs_vbrkscr>-dplast.
          <fs_vbrkscr>-dpplast = <fs_vbrkscr>-dpplast - <fs_vbrkscr>-dplast.
          <fs_vbrkscr>-ppnlast = <fs_vbrkscr>-dpplast * 10 / 100.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_UANG_MUKA

*&---------------------------------------------------------------------*
*&      Form  F_DPP_CHANGE
*&---------------------------------------------------------------------*
FORM f_dpp_change  TABLES ft_0002   STRUCTURE zgdtxdt0002
                   USING  fw_0003  TYPE zgdtxdt0003 fu_fakturno.
  DATA : lv_lines TYPE i,
         lv_count TYPE i,
         lv_dpp   TYPE zgdtxdt0002-dpp,
         lv_sisa  TYPE zgdtxdt0002-dpp.
  DATA : lt_0002    TYPE STANDARD TABLE OF zgdtxdt0002.

  IF fw_0003-bukrs = '8800' AND
    fw_0003-busln = '01'.
    IF fu_fakturno IS NOT INITIAL.
      lt_0002[] = ft_0002[].
      DELETE lt_0002 WHERE fakturno <> fw_0003-fakturno.
      DESCRIBE TABLE lt_0002 LINES lv_lines.
      LOOP AT ft_0002 WHERE fakturno = fw_0003-fakturno.
        ADD 1 TO lv_count.
        PERFORM f_rounding CHANGING ft_0002-dpp.
        PERFORM f_rounding CHANGING ft_0002-dpplast.
        ADD ft_0002-dpp TO lv_dpp.
        IF lv_count = lv_lines.
          lv_sisa         = fw_0003-fakdpp - lv_dpp.
          ft_0002-dpp     = ft_0002-dpp + lv_sisa.
          ft_0002-dpplast = ft_0002-dpplast + lv_sisa.
        ENDIF.
        MODIFY ft_0002 TRANSPORTING dpp dpplast.
      ENDLOOP.
    ELSE.
      PERFORM f_rounding CHANGING fw_0003-fakdpp.
    ENDIF.
  ELSE.
    IF fw_0003-fakdat > gs_dpp-datab.
      LOOP AT ft_0002 WHERE vbeln = fw_0003-vbeln.
        ft_0002-dpp     = ft_0002-dpp * 11 / 12.
        ft_0002-dpplast = ft_0002-dpplast * 11 / 12.
        ADD ft_0002-dpp TO lv_dpp.
        IF fu_fakturno IS NOT INITIAL.
          MODIFY ft_0002 TRANSPORTING dpp dpplast.
        ENDIF.
      ENDLOOP.
      fw_0003-fakdpp  = lv_dpp.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DPP_CHANGE

*&---------------------------------------------------------------------*
*&      Form  F_ROUNDING
*&---------------------------------------------------------------------*
FORM f_rounding  CHANGING    fc_fakdpp.
  DATA : lv_dpp   TYPE p DECIMALS 4.

  lv_dpp = fc_fakdpp.

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = lv_dpp
      sign          = '-'
    IMPORTING
      output        = fc_fakdpp
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.                    " F_ROUNDING

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_mastx fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE netwr_ak.

  lv_wrbtr  = fu_wrbtr.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
      pi_mastx = fu_mastx
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC

*&---------------------------------------------------------------------*
*&      Form  F_OLD_FAKTURNO
*&---------------------------------------------------------------------*
FORM f_old_fakturno  USING    fu_brnch fu_masatx fu_object fu_vatbr fu_vattrn
                              fu_posnr
                     CHANGING fc_fakturno fc_nocoretax fc_subrc.
  DATA : lr_masatx      TYPE RANGE OF zgdtxdt0011-masatx,
         ls_masatx      LIKE LINE OF lr_masatx,
         lt_fakturno    TYPE STANDARD TABLE OF zgdtxdt0011 WITH HEADER LINE,
         lt_zfvatnr     TYPE STANDARD TABLE OF zfvatnr WITH HEADER LINE,
         lt_zfvatnr_dtl TYPE STANDARD TABLE OF zfvatnr_dtl WITH HEADER LINE.

  DATA : ld_masatx   LIKE zgdtxdt0011-masatx,
         ld_reuse,
         lv_datum    LIKE sy-datum,
         lv_date     LIKE sy-datum,
         ld_vatno    LIKE zfvatnr-vatno,
         l_len       TYPE i,
         l_posisi    TYPE i,
         lc_vatno(8).

  CLEAR : ld_masatx, lr_masatx[].

  ld_masatx = fu_masatx - 1.

  ls_masatx-sign   = 'I'.
  ls_masatx-option = 'EQ'.
  ls_masatx-low    = ld_masatx.
  APPEND ls_masatx TO lr_masatx.
  ls_masatx-low    = fu_masatx.
  APPEND ls_masatx TO lr_masatx.

* check reuseable faktur number
  SELECT *
    FROM zgdtxdt0011
    INTO TABLE lt_fakturno
    WHERE brnch    EQ fu_brnch  AND
          masatx   IN lr_masatx AND
          objrange EQ fu_object.
  IF sy-subrc EQ 0.
    SORT lt_fakturno BY fakturno masatx.
    CLEAR ld_reuse.
    CLEAR: sy-subrc.
    LOOP AT lt_fakturno.
      CALL FUNCTION 'ENQUEUE_EZGDTXDT0011'
        EXPORTING
          mode_zgdtxdt0011 = 'E'
          mandt            = sy-mandt
*         gsber            = fu_gsber
          brnch            = fu_brnch
          fakturno         = lt_fakturno-fakturno
          masatx           = lt_fakturno-masatx
          objrange         = lt_fakturno-objrange
        EXCEPTIONS
          foreign_lock     = 1
          system_failure   = 2
          OTHERS           = 3.
      IF sy-subrc = 0.
        CLEAR ld_reuse.
        MOVE-CORRESPONDING lt_fakturno TO t_zgdtxdt0011.
        APPEND t_zgdtxdt0011.
        EXIT.
      ELSE.
        ld_reuse = 'X'.
        CONTINUE.
      ENDIF.
    ENDLOOP.
*    ld_vatno1 = lt_fakturno-fakturno+6(10).
*    CONCATENATE ld_vattrn '0' ld_vatbr ld_vatno1
*    INTO fc_fakturno.
    fc_fakturno   = lt_fakturno-fakturno.
    fc_nocoretax  = lt_fakturno-nocoretax.
    DELETE zgdtxdt0011 FROM t_zgdtxdt0011.
    CLEAR fc_subrc.
  ELSE.
*--- Tambahan kondisi penomoran faktur pajak mulai dari tahun 2013
    CONCATENATE fu_masatx '01' INTO lv_datum.
    SELECT SINGLE datab  INTO lv_date FROM zproject WHERE name = 'PAJAK2013' AND datab > lv_datum.
    IF sy-subrc EQ 0.
      SELECT SINGLE vatno
        FROM zfvatnr
        INTO ld_vatno
        WHERE vkorg EQ fu_brnch AND
              vkbur EQ fu_vatbr AND
              gjahr EQ fu_masatx(4).

      ld_vatno = ld_vatno + 1.
      UPDATE zfvatnr SET vatno = ld_vatno
                     WHERE vkorg EQ fu_brnch AND
                           vkbur EQ fu_vatbr AND
                           gjahr EQ fu_masatx(4).

      CONCATENATE fu_vattrn '0' fu_vatbr fu_masatx+2(2) ld_vatno
      INTO fc_fakturno.
      CLEAR fc_subrc.
    ELSE.
      SELECT SINGLE *
        FROM zfvatnr
        INTO lt_zfvatnr
        WHERE vkorg EQ fu_brnch AND
              vkbur EQ fu_vatbr AND
              gjahr EQ fu_masatx(4).
      IF lt_zfvatnr-posnr EQ 0.
        SELECT SINGLE *
          FROM zfvatnr_dtl
          INTO lt_zfvatnr_dtl
          WHERE vkorg EQ fu_brnch AND
                vkbur EQ fu_vatbr AND
                gjahr EQ fu_masatx(4) AND
                posnr EQ fu_posnr.
        IF sy-subrc EQ 0.
          CONDENSE lt_zfvatnr_dtl-vatpr.
          l_len = strlen( lt_zfvatnr_dtl-vatpr ).
          IF l_len > 4.
            fc_subrc = 2.
          ELSE.
            UPDATE zfvatnr SET vatno = lt_zfvatnr_dtl-vatfr
                               vatfr = lt_zfvatnr_dtl-vatfr
                               vatto = lt_zfvatnr_dtl-vatto
                               vatcd = lt_zfvatnr_dtl-vatcd
                               vatpr = lt_zfvatnr_dtl-vatpr
                               posnr = lt_zfvatnr_dtl-posnr
                               vatdt = sy-datum
          WHERE vkorg EQ fu_brnch AND
                vkbur EQ fu_vatbr AND
                gjahr EQ fu_masatx(4).
            IF sy-subrc EQ 0.
              lc_vatno = lt_zfvatnr_dtl-vatfr.
              l_posisi = l_len.
              l_len = 8 - l_len.
              lc_vatno = lc_vatno+l_posisi(l_len).
              CONCATENATE fu_vattrn '0' lt_zfvatnr_dtl-vatcd fu_masatx+2(2) lt_zfvatnr_dtl-vatpr lc_vatno
              INTO fc_fakturno.
              CLEAR fc_subrc.
            ENDIF.
          ENDIF.
        ELSE.
          fc_subrc = 3.
        ENDIF.
      ELSE.
        ld_vatno = lt_zfvatnr-vatno + 1.
        IF ld_vatno <= lt_zfvatnr-vatto.
          CONDENSE lt_zfvatnr-vatpr.
          l_len = strlen( lt_zfvatnr-vatpr ).
          IF l_len > 4.
            fc_subrc = 2.
          ELSE.
            UPDATE zfvatnr SET vatno = ld_vatno
                           WHERE vkorg EQ fu_brnch AND
                                 vkbur EQ fu_vatbr AND
                                 gjahr EQ fu_masatx(4).
            l_posisi = l_len.
            l_len = 8 - l_len.
            lc_vatno = ld_vatno+l_posisi(l_len).

            CONCATENATE fu_vattrn '0' lt_zfvatnr-vatcd fu_masatx+2(2) lt_zfvatnr-vatpr lc_vatno
            INTO fc_fakturno.
            CLEAR fc_subrc.
          ENDIF.
        ELSE.
          lt_zfvatnr-posnr = lt_zfvatnr-posnr + 10.
          SELECT SINGLE *
            FROM zfvatnr_dtl
            INTO lt_zfvatnr_dtl
            WHERE vkorg EQ fu_brnch AND
                  vkbur EQ fu_vatbr AND
                  gjahr EQ fu_masatx(4) AND
                  posnr EQ lt_zfvatnr-posnr.
          IF sy-subrc EQ 0.
            UPDATE zfvatnr SET vatno = lt_zfvatnr_dtl-vatfr
                               vatfr = lt_zfvatnr_dtl-vatfr
                               vatto = lt_zfvatnr_dtl-vatto
                               vatcd = lt_zfvatnr_dtl-vatcd
                               vatpr = lt_zfvatnr_dtl-vatpr
                               posnr = lt_zfvatnr_dtl-posnr
                               vatdt = sy-datum
          WHERE vkorg EQ fu_brnch AND
                vkbur EQ fu_vatbr AND
                gjahr EQ fu_masatx(4).
            IF sy-subrc EQ 0.
              CONCATENATE fu_vattrn '0' lt_zfvatnr_dtl-vatcd fu_masatx+2(2) lt_zfvatnr_dtl-vatpr lt_zfvatnr_dtl-vatfr
              INTO fc_fakturno.
              CLEAR fc_subrc.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
