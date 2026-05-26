*----------------------------------------------------------------------*
*   INCLUDE ZF_VATOUT_PROCESS_TOP                                      *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: zfvato,zfvatnr,zfvatnm,vbrk,zsl_hsales,vbfa,sscrfields,vttk.

CONTROLS input TYPE TABLEVIEW USING SCREEN 210.

CONSTANTS: c_dpp_text(30) VALUE '(100/110 x Harga Jual)',
           c_ppn_text(30) VALUE '10% x Dasar Pengenaan Pajak'.

CONSTANTS: c_smartform_name  TYPE tdsfname      VALUE 'ZF_ZF02CW'.

RANGES: r_gjahr FOR bsas-gjahr,
        r_vkbur_sap FOR knvv-vkbur,
        r_vkbur_leg FOR knvv-vkbur.

DATA: gs_header TYPE zgdkomerx,
      gt_item   TYPE STANDARD TABLE OF zgdkomerx,
      wa_item   LIKE LINE OF gt_item,
      gt_subtl  TYPE STANDARD TABLE OF zgdkomerx,
      wa_subtl  LIKE LINE OF gt_subtl,
      gs_total  TYPE zgdtxst0004x.

TYPES: BEGIN OF t_bdc.
         INCLUDE STRUCTURE bdcdata.
       TYPES: END OF t_bdc.
TYPES: BEGIN OF t_messtab.
         INCLUDE STRUCTURE bdcmsgcoll.
       TYPES: END OF t_messtab.

DATA : BEGIN OF i_live OCCURS 0,
         vstel         LIKE  tvkol-vstel,
         werks         LIKE  tvkol-werks,
         lgort         LIKE  tvkol-lgort,
         legacy_branch LIKE zplbc-legacy_branch,
         live          LIKE  zplbc-live,
         vatbr         LIKE  zplbc-vatbr,
       END OF i_live.

DATA : BEGIN OF i_legacy OCCURS 0,
         vkorg      LIKE  zsl_hsales-vkorg,
         vbeln      LIKE  zsl_hsales-vbeln,
         fkdat      LIKE  zsl_hsales-fkdat,
         bldat      LIKE  zsl_hsales-bldat,
         vbtyp      LIKE  zsl_hsales-vbtyp,
         fkart      LIKE  zsl_hsales-fkart,
         netwr      LIKE  zsl_hsales-netwr,
         txdat      LIKE  zsl_hsales-txdat,
         mwsbp      LIKE  zsl_hsales-mwsbp,
         gjahr      LIKE  zsl_hsales-gjahr,
         kunnr      LIKE  zsl_hsales-kunnr,
         curr       LIKE  zsl_hsales-curr,
         vkbur      LIKE  zsl_hsales-vkbur,
         kunde      LIKE  zsl_hsales-kunde,
         spdot      LIKE  zsl_hsales-spdot,
         vrtnr      LIKE  zsl_hsales-vrtnr,
         grswr      LIKE  zsl_hsales-grswr,
         account_no LIKE  zsl_hsales-account_no,
         filename   LIKE zsl_hsales-filename,
         kir        LIKE  zsl_hsales-kir,
         taxcode    LIKE zsl_hsales-taxcode,
         adrnr      LIKE  kna1-adrnr,
         stras      LIKE  kna1-stras,
         ort01      LIKE  kna1-ort01,
         pstlz      LIKE  kna1-pstlz,
         stceg      LIKE  kna1-stceg,
         cityc      LIKE  kna1-cityc,
         gform      LIKE  kna1-gform,
         kdgrp      LIKE  knvv-kdgrp,
         budat      LIKE  zsl_hsales-budat,
         sonr       LIKE  zsl_hsales-sonr,
         status     LIKE  zsl_hsales-status,
       END OF i_legacy.

DATA : BEGIN OF  i_sap OCCURS 0,
         vkorg    LIKE  vbrk-vkorg,
         kunrg    LIKE  vbrk-kunrg,
         vbeln    LIKE  vbrk-vbeln,
         fkdat    LIKE  vbrk-fkdat,
         erdat    LIKE  vbrk-erdat,
         zterm    LIKE  vbrk-zterm,
         vbtyp    LIKE  vbrk-vbtyp,
         fkart    LIKE  vbrk-fkart,
         knumv    LIKE  vbrk-knumv,
         zuonr    LIKE  vbrk-zuonr,
         netwr    LIKE  vbrk-netwr,
         mwsbk    LIKE  vbrk-mwsbk,
         gjahr    LIKE  vbrk-gjahr,
         spart    LIKE  vbrk-spart,
         waerk    LIKE  vbrk-waerk,
         xblnr    LIKE  vbrk-zuonr,
         vkbur    LIKE  knvv-vkbur,
         adrnr    LIKE  kna1-adrnr,
         stras    LIKE  kna1-stras,
         ort01    LIKE  kna1-ort01,
         pstlz    LIKE  kna1-pstlz,
         stceg    LIKE  kna1-stceg,
         cityc    LIKE  kna1-cityc,
         gform    LIKE  kna1-gform,
         kdgrp    LIKE  knvv-kdgrp,
         fkdat_rl LIKE vbrk-fkdat_rl,
       END OF i_sap.

DATA : BEGIN OF  i_saptmp OCCURS 0,
         vkorg LIKE  vbrk-vkorg,
         kunrg LIKE  vbrk-kunrg,
         vbeln LIKE  vbrk-vbeln,
         fkdat LIKE  vbrk-fkdat,
         erdat LIKE  vbrk-erdat,
         zterm LIKE  vbrk-zterm,
         vbtyp LIKE  vbrk-vbtyp,
         fkart LIKE  vbrk-fkart,
         knumv LIKE  vbrk-knumv,
         zuonr LIKE  zmm_cust_rec-vbeln,
       END OF i_saptmp.

DATA : BEGIN OF i_sono OCCURS 0,
         vbeln LIKE  vbrp-vbeln,
         vgbel LIKE  vbrp-vgbel,
         aubel LIKE  vbrp-aubel,
         auart LIKE  vbak-auart,
       END OF i_sono.

DATA : BEGIN OF i_billcor OCCURS 0,
         vbeln LIKE  vbrk-vbeln,
         zuonr LIKE  vbrk-zuonr,
         vbtyp LIKE  vbrk-vbtyp,
         sfakn LIKE  vbrk-sfakn,
         kunrg LIKE  vbrk-kunrg,
         vkbur LIKE  vbrp-vkbur,
       END OF i_billcor.

DATA : BEGIN OF i_bsis OCCURS 0,
         zuonr LIKE  bsis-zuonr,
*         hkont  LIKE  bsis-hkont,
         belnr LIKE  bsis-belnr,
         dmbtr LIKE  bsis-dmbtr,
       END OF i_bsis.

DATA : BEGIN OF i_vbfa OCCURS 0,
         vbelv   LIKE  vbfa-vbelv,
         posnv   LIKE  vbfa-posnv,
         vbeln   LIKE  vbfa-vbeln,
         posnn   LIKE  vbfa-posnn,
         vbtyp_n LIKE vbfa-vbtyp_n,
         erdat   LIKE  vbfa-erdat,
         erzet   LIKE  vbfa-erzet,
         bwart   LIKE  vbfa-bwart,
         budat   LIKE  mkpf-budat,
       END OF i_vbfa.

DATA : BEGIN OF i_vbak OCCURS 0,
         vbeln LIKE vbak-vbeln,
         mahdt LIKE vbak-mahdt,
         ihrez LIKE vbak-ihrez,
         audat LIKE vbak-audat,
         auart LIKE vbak-auart,
       END OF i_vbak.

DATA : BEGIN OF i_adrc OCCURS 0,
         addrnumber LIKE adrc-addrnumber,
         name_co    LIKE adrc-name_co,
         str_suppl1 LIKE adrc-str_suppl1,
         str_suppl2 LIKE adrc-str_suppl2,
         str_suppl3 LIKE adrc-str_suppl3,
       END OF i_adrc.

DATA : BEGIN OF i_adrc_legacy OCCURS 0,
         addrnumber LIKE adrc-addrnumber,
         name_co    LIKE adrc-name_co,
         str_suppl1 LIKE adrc-str_suppl1,
         str_suppl2 LIKE adrc-str_suppl2,
         str_suppl3 LIKE adrc-str_suppl3,
       END OF i_adrc_legacy.

DATA : BEGIN OF i_vbpa OCCURS 0,
         vbeln LIKE vbpa-vbeln,
         parvw LIKE vbpa-parvw,
         kunnr LIKE vbpa-kunnr,
         pernr LIKE vbpa-pernr,
       END OF i_vbpa.

DATA : BEGIN OF i_main OCCURS 0.
         INCLUDE STRUCTURE zfvato.
         DATA :   dpp      LIKE zfvato-netwr,
         gform    LIKE kna1-gform,
         vatbr    LIKE zplbc-vatbr,
         vbeln1   LIKE zsl_hsales-vbeln,
         fkdat_rl LIKE vbrk-fkdat_rl,
         zuodt    LIKE vttp-erdat,
       END OF i_main.

DATA : BEGIN OF i_zbil OCCURS 0.
         INCLUDE STRUCTURE zbil.
         DATA :   vbeln LIKE  vbrp-vbeln,
         vgbel LIKE  vbrp-vgbel,
         aubel LIKE  vbrp-aubel,
       END OF i_zbil.

DATA : s2vkorg  LIKE zfvatnr-vkorg,
       s2vkorgt LIKE tvkot-vtext,
       s2vkbur  LIKE zfvatnr-vkbur,
       s2vkburt LIKE tvkbt-bezei,
       s2vatno  LIKE zfvatnr-vatno,
       s2vatold LIKE zfvatnr-vatold,
       s2posnr  LIKE zfvatnr-posnr,
       s2vatfr  LIKE zfvatnr-vatfr,
       s2vatto  LIKE zfvatnr-vatto,
       s2vatpr  LIKE zfvatnr-vatpr,
       s2vatdt  LIKE zfvatnr-vatdt,
       s2gjahr  LIKE zfvatnr-gjahr,
       vflag1   TYPE i VALUE 0.

DATA : s3vkorg    LIKE zfvatnm-vkorg,
       s3vkorgt   LIKE tvkot-vtext,
       s3vkbur    LIKE zfvatnm-vkbur,
       s3vkburt   LIKE tvkbt-bezei,
       s3vatnm    LIKE zfvatnm-vatnm,
       s3vattl    LIKE zfvatnm-vattl,
       s3object1  LIKE zfvatnm-object1,
       s3vatnm2   LIKE zfvatnm-vatnm2,
       s3vattl2   LIKE zfvatnm-vattl2,
       s3object2  LIKE zfvatnm-object2,
       s3vatnm3   LIKE zfvatnm-vatnm3,
       s3vattl3   LIKE zfvatnm-vattl3,
       s3object3  LIKE zfvatnm-object3,
       s4text(50).

DATA : ok_code LIKE sy-ucomm,
       save_ok LIKE ok_code.

DATA : BEGIN OF i_downvato OCCURS 0,
         vkorg   LIKE  zfvato-vkorg,
         vkbur   LIKE  zfvato-vkbur,
         vatno   LIKE  zfvato-vatno,
         vbeln   LIKE  zfvato-vbeln,
         zuonr   LIKE  zfvato-zuonr,
         vatpr   LIKE  zfvato-vatpr,
         dudat   LIKE  zfvato-dudat,
         dueyr   LIKE  zfvato-dueyr,
         duemm   LIKE  zfvato-duemm,
         netwr   LIKE  zfvato-netwr,
         mwsbk   LIKE  zfvato-mwsbk,
         sortl   LIKE  kna1-sortl,
         name_co LIKE zfvato-name_co,
         stceg   LIKE  zfvato-stceg,
       END OF i_downvato.

DATA : BEGIN OF i_down_field OCCURS 0,
         txt_field(7),
       END OF i_down_field.

DATA : BEGIN OF i_download OCCURS 0,
         brcod(1),
         vbeln(10),
         seqtyp(1),
         seqnr(6),
         outgr(1),
         outcd(6),
         seripjk(10),
         nopjk(10),
         tglpjk      LIKE sy-datum,
         tglprs      LIKE sy-datum,
         jamprs      LIKE sy-uzeit,
         userprs     LIKE sy-uname,
         dpp(10)     TYPE n,
         ppn(10)     TYPE n,
         ketr(40),
         outnm(40),
         npwp(20),
       END OF i_download.

DATA : BEGIN OF i_vatgb OCCURS 0,
         vbeln LIKE vbrp-vbeln,
         zuonr LIKE vbrk-zuonr,
         posnr LIKE vbrp-posnr,
         matnr LIKE vbrp-matnr,
         arktx LIKE vbrp-arktx,
         vrkme LIKE vbrp-vrkme,
         fkimg LIKE vbrp-fkimg,
         netwr LIKE vbrp-netwr,
         mwsbp LIKE vbrp-mwsbp,
         kbetr LIKE konv-kbetr,
         kwert LIKE konv-kwert,
         sdisc LIKE konv-kwert,
         vdisc LIKE konv-kwert,
         cdisc LIKE konv-kwert,
       END OF i_vatgb.

DATA : BEGIN OF i_cust OCCURS 0,
         kunnr      LIKE kna1-kunnr,
         adrnr      LIKE kna1-adrnr,
         stras      LIKE kna1-stras,
         ort01      LIKE kna1-ort01,
         pstlz      LIKE kna1-pstlz,
         cityc      LIKE kna1-cityc,
         stceg      LIKE kna1-stceg,
         gform      LIKE kna1-gform,
         name_co    LIKE adrc-name_co,
         str_suppl1 LIKE adrc-str_suppl1,
         str_suppl2 LIKE adrc-str_suppl2,
         str_suppl3 LIKE adrc-str_suppl3,
       END OF i_cust.

DATA : BEGIN OF i_mseg OCCURS 0,
         mblnr LIKE mseg-mblnr,
         mjahr TYPE mjahr,
         zeile LIKE mseg-zeile,
         matnr LIKE mseg-matnr,
         menge LIKE mseg-menge,
         meins LIKE mseg-meins,
         dmbtr LIKE mseg-dmbtr,
         waers LIKE mseg-waers,
         bukrs LIKE mseg-bukrs,
         kunnr LIKE mseg-kunnr,
         umwrk LIKE mseg-umwrk,
         shkzg LIKE mseg-shkzg,
         werks LIKE mseg-werks,
         sjahr TYPE mjahr,
         smbln LIKE mseg-smbln,
         smblp TYPE mblpo,
       END OF i_mseg.

DATA  BEGIN OF gt_vdata OCCURS 1.
INCLUDE STRUCTURE zfvatnr_dtl.
DATA: flag TYPE char1,
      END   OF gt_vdata.

DATA  BEGIN OF i_zfvatnr_dtl OCCURS 1.
INCLUDE STRUCTURE zfvatnr_dtl.
DATA  END   OF i_zfvatnr_dtl.

TYPES : tsubtotal(14)   TYPE p DECIMALS 2,
        tsubtotal_l(14) TYPE p DECIMALS 2,
        tprice          LIKE vbrp-netwr,
        tdisc(14)       TYPE p DECIMALS 2,
        tpdiscv(14)     TYPE p DECIMALS 0,
        tpdisc(5)       TYPE p DECIMALS 2,
        ttotal(14)      TYPE p DECIMALS 2,
        ttot_value(14)  TYPE p DECIMALS 2,
        ttot_disc(14)   TYPE p DECIMALS 2,
        ttax_base(14)   TYPE p DECIMALS 2,
        ttax_amt(14)    TYPE p DECIMALS 2,
        tmonth(2)       TYPE c.

DATA : vcount         TYPE i,
       flglimit(1),
       vcount_dtl     TYPE i,
       vterm          LIKE t052-ztag1,
       vflg(1), vflg1(1), va_mark(1),
*         va_list TYPE slist_listline,
       vresult        LIKE itcpp,
       xresult        LIKE itcpp,
       voption        LIKE itcpo,
       val(1)         TYPE c,
       vwerks         LIKE tvkol-werks,
       vlgort         LIKE tvkol-lgort,
       pripar         TYPE pri_params,
       arcpar         TYPE arc_params,
       vihrez         LIKE zfvato-ihrez,
       nihrez(12)     TYPE n,
       ovatpr         LIKE zfvatnr-vatpr,
       ovatno         LIKE zfvatnr-vatno,
       ozuonr         LIKE vbrk-zuonr,
       ovkorg         LIKE vbrk-vkorg,
       oname1         LIKE adrc-name_co,
       oname2         LIKE adrc-str_suppl1,
       oname3         LIKE adrc-str_suppl2,
       ocity1         LIKE adrc-str_suppl3,
       opstlz         LIKE adrc-post_code1,
       ostceg         LIKE kna1-stceg,
       ostras         LIKE zfvato-stras,
       oort01         LIKE kna1-ort01,
       oseq           TYPE i,
       omatnr         LIKE vbrp-matnr,
       ofkimg         LIKE vbrp-fkimg,
       oarktx         LIKE vbrp-arktx,
       okbetr         LIKE konv-kbetr,
       okwert         LIKE konv-kwert,
       osubtotal      TYPE tsubtotal,
       osubtotal_l    TYPE tsubtotal_l,
       osdisc         TYPE tdisc,
       ovdisc         TYPE tdisc,
       ocdisc         TYPE tdisc,
       vpdisc         TYPE tpdiscv,
       opdisc         TYPE tpdisc,
       ototal         TYPE ttotal,
       vtot_value     TYPE ttot_value,
       otot_value     TYPE ttot_value,
       otot_gros      TYPE ttot_value,
       otot_disc      TYPE ttot_disc,
       otax_base      TYPE ttax_base,
       otax_amt       TYPE ttax_amt,
       odudat         LIKE zfvato-dudat,
       ocity(40),
       onpwpbaru(51),
       onpwpbaru1(51),
       oobject        LIKE zfvatnm-object1,
*         osign_name LIKE zfvatnm-vatnm,
       osign_name(26),
       osign_title    LIKE zfvatnm-vattl,
       odotyp(1),
       odate(10),
       obln(2),
       ozuonr_ref(20),
       ovbeln         LIKE vbrk-vbeln,
       omonth         TYPE tmonth,
       ovrtnr         LIKE knvk-vrtnr,
       odatum         LIKE zfvato-vatdt,
       okunrg         LIKE vbrk-kunrg,
       oerdat         LIKE vbrk-erdat,
       ogform         LIKE kna1-gform,
       onppkp(35),
       odpp_text(30),
       oppn_text(30).

DATA : i_zfvato       LIKE zfvato OCCURS 0 WITH HEADER LINE,
       i_zfvato_leg   LIKE zfvato OCCURS 0 WITH HEADER LINE,
       i_zsl_dsales   LIKE zsl_dsales OCCURS 0 WITH HEADER LINE,
       i_vbrp         LIKE vbrp OCCURS 0 WITH HEADER LINE,
       i_zfvatnr      LIKE  zfvatnr OCCURS 0 WITH HEADER LINE,
       i_zfvattrn     LIKE  zfvattrn OCCURS 0 WITH HEADER LINE,
       i_zfvattop     LIKE  zfvattop OCCURS 0 WITH HEADER LINE,
       i_zfvatftz     LIKE  zfvatftz OCCURS 0 WITH HEADER LINE,
       i_zmm_cust_rec LIKE zmm_cust_rec OCCURS 0 WITH HEADER LINE,
       i_vbfa_do      LIKE i_vbfa OCCURS 0 WITH HEADER LINE,
       i_vbfa_cn      LIKE i_vbfa OCCURS 0 WITH HEADER LINE,
       wa_zfvatnr_dtl LIKE i_zfvatnr_dtl,
       wa_vat1        LIKE zfvato,
       wa_vatnm       LIKE zfvatnm.

DATA : v_vatto      LIKE zfvatnr-vatto,
       v_vatno      LIKE zfvatnr-vatno,
       v_vatold     LIKE zfvatnr-vatold,
       v_vatpr      LIKE zfvatnr-vatpr,
       v_vatbr      LIKE zplbc-vatbr,
       v_coretax,
       v_filename   LIKE  rlgrap-filename,
       v_live       LIKE zplbc-live,
       v_mixlive    LIKE zplbc-mixlive,
       v_line       TYPE i,
       v_answer(1),
       gw_vdata     LIKE gt_vdata,
       gt_vdata1    LIKE gt_vdata OCCURS 0 WITH HEADER LINE,
       gt_vdata_del LIKE gt_vdata OCCURS 0 WITH HEADER LINE,
       i_header     LIKE i_vbfa OCCURS 0 WITH HEADER LINE,
       i_detail     LIKE i_vbfa OCCURS 0 WITH HEADER LINE,
       i_spopli     LIKE spopli OCCURS 0 WITH HEADER LINE,
       i_koreksi    LIKE i_main OCCURS 0 WITH HEADER LINE,
       i_zbilkor    LIKE i_zbil OCCURS 0 WITH HEADER LINE.

DATA : d_datab         LIKE zproject-datab,
       d_flag          LIKE zproject-flag,
       i_messtab       TYPE t_messtab OCCURS 0,
       wa_messtab      TYPE t_messtab,
       i_bdc           TYPE t_bdc OCCURS 0,
       wa_bdc          TYPE t_bdc,
       va_mode(1),
       fill            TYPE i,
       v_flg_pajak2013 LIKE zproject-flag,
       v_dat_pajak2013 LIKE zproject-datab,
       wa_project      LIKE zproject.

DATA : gv_ucomm   TYPE sy-ucomm.

DATA : r_dudat  TYPE STANDARD TABLE OF bapidlv_range_bldat.

DATA : BEGIN OF i_excel OCCURS 0,
         row   LIKE alsmex_tabline-row,
         col   LIKE alsmex_tabline-col,
         value LIKE alsmex_tabline-value,
       END OF i_excel.

DATA : BEGIN OF gt_record OCCURS 0,
         vkorg      TYPE vkorg,
         vkbur      TYPE vkbur,
         vbeln      TYPE vbeln_vf,
         zuonr      TYPE dzuonr,
         dueyr      TYPE zdueyr,
         name_co    TYPE ad_name_co,
         str_suppl1	TYPE ad_strspp1,
         str_suppl2	TYPE ad_strspp2,
         stras      TYPE ad_strspp3,
         cityc      TYPE cityc,
         stceg      TYPE stceg,
         location   TYPE ad_lctn,
         icon(4),
       END OF gt_record.
DATA : gt_temp   LIKE gt_record OCCURS 0 WITH HEADER LINE,
       wa_record LIKE gt_record.

DATA : BEGIN OF gt_vttk OCCURS 0,
         tknum LIKE vttk-tknum,
         erdat LIKE vttk-erdat,
         datbg LIKE vttk-datbg,
       END OF gt_vttk.

DATA : BEGIN OF gt_vttp OCCURS 0,
         tknum LIKE vttp-tknum,
         tpnum LIKE vttp-tpnum,
         vbeln LIKE vttp-vbeln,
         erdat LIKE vttp-erdat,
       END OF gt_vttp.

DATA : BEGIN OF gt_likp OCCURS 0,
         vbeln     LIKE likp-vbeln,
         wadat_ist LIKE likp-wadat_ist,
       END OF gt_likp.

DATA : BEGIN OF gt_lips OCCURS 0,
         vbeln LIKE lips-vbeln,
         posnr LIKE lips-posnr,
         matnr LIKE lips-matnr,
         lfimg LIKE lips-lfimg,
         meins LIKE lips-meins,
       END OF gt_lips.

FIELD-SYMBOLS: <fs_main> LIKE i_main,
               <fs_isap> LIKE i_sap.

DATA : gt_a934 TYPE STANDARD TABLE OF a934 INITIAL SIZE 0,
       gt_konp TYPE STANDARD TABLE OF konp INITIAL SIZE 0,
       gt_a017 TYPE STANDARD TABLE OF zcdsmm_004 INITIAL SIZE 0,
       gt_mkpf TYPE STANDARD TABLE OF mkpf INITIAL SIZE 0.

DATA : gr_fkart   TYPE RANGE OF fkart.

DATA : gt_vbrp   TYPE STANDARD TABLE OF vbrp.

DATA : gs_dpp     TYPE zproject,
       gs_coretax TYPE zproject,
       gt_005     TYPE STANDARD TABLE OF zcoretax0005.

DATA : gt_vbfa    TYPE STANDARD TABLE OF vbfa.
