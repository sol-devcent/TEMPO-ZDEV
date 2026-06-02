REPORT zf_bi MESSAGE-ID zs NO STANDARD PAGE HEADING
                                  LINE-COUNT 63(3)
                                  LINE-SIZE  225.


************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :                                                        *
* Created by  :                                                        *
* Created on  :                                                        *
* Version     : 0.0                                                    *
* Include     :                                                        *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935889     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*----------------------------------------------------------------------*
****************************************************
*        Tables                                    *
****************************************************
TABLES: t001,
        zfbih,
        zfbid,
        bseg,
        kna1,
        sscrfields,
        zfbicheck,
        zfbierror,
        bkpf,
        zftransttf.


************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES : BEGIN OF t_itab1,
          bukrs     LIKE zfbih-bukrs,
          bbeln     LIKE zfbih-bbeln,
          gjahr     LIKE zfbid-gjahr,
          bidat     LIKE zfbih-bidat,
          parnr     LIKE zfbih-parnr,
          waers     LIKE zfbih-waers,
          vkbur     LIKE zfbid-vkbur,
          ebelp     LIKE zfbid-ebelp,
          vbeln     LIKE zfbid-vbeln,
          zuonr     LIKE zfbid-zuonr,
          buzei     LIKE zfbid-buzei,
          gsber     LIKE zfbid-gsber,
          fkdat     LIKE zfbid-fkdat,
          kunnr     LIKE zfbid-kunnr,
          parvw     LIKE zfbid-parvw,
          slcod     LIKE zfbid-slcod,
          zfbdt     LIKE zfbid-zfbdt,
          wrbtr     LIKE zfbid-wrbtr,
          pcash     LIKE zfbid-pcash,
          pchek     LIKE zfbid-pchek,
          pytot     LIKE zfbid-pytot,
          resid     LIKE zfbid-resid,
          pcnot     LIKE zfbid-pcnot,
          jmlck     LIKE zfbid-jmlck,
          xblnr     LIKE zfbid-xblnr,
          hkont     LIKE zfbid-hkont,
          usna1     LIKE zfbid-usna1,
          erdt1     LIKE zfbid-erdt1,
          usna2     LIKE zfbid-usna2,
          erdt2     LIKE zfbid-erdt2,
          bflag     LIKE zfbid-bflag,
          pstat     LIKE zfbid-pstat,
          ptype     LIKE zfbid-ptype,
          zuonr1    LIKE zfbid-zuonr, "SLCOD,
          nottf     LIKE zfbid-nottf,
          tglttf    LIKE zfbid-tglttf,
          amtttf    LIKE zfbid-amtttf,
          ptrans    LIKE zfbid-ptrans,
          kdtrf     LIKE zfbid-kdtrf,
          xblnrt    LIKE zfbid-xblnrt,
          residt    LIKE zfbid-resid,
          ptnot     LIKE zfbid-ptnot,
          belnr     TYPE belnr_d,
          budat(10),
          belnrr    TYPE belnr_d,
          name1     TYPE name1_gp,
          amtcar    LIKE zfbid-pcash,
          amttar    LIKE zfbid-pcash,
        END OF t_itab1.

TYPES:   BEGIN OF t_bdc.
           INCLUDE STRUCTURE bdcdata.
         TYPES:   END OF t_bdc.

TYPES:   BEGIN OF t_messtab.
           INCLUDE STRUCTURE bdcmsgcoll.
         TYPES:   END OF t_messtab.

TYPES: BEGIN OF t_log_error,
         bukrs   LIKE bsis-bukrs,
         gjahr   LIKE bsis-gjahr,
         belnr   LIKE bsis-belnr,
         msg(80),
       END OF t_log_error.

DATA : BEGIN OF itab OCCURS 10.
         INCLUDE STRUCTURE zfbid.
         DATA :   amtcar TYPE zfbid-pcash,
         amttar TYPE zfbid-pcash.
DATA : END OF itab.

DATA : BEGIN OF t_totaltemp OCCURS 10,
         pcash  LIKE zfbid-pcash,
         pchek  LIKE zfbid-pchek,
         pcnot  LIKE zfbid-pcnot,
         ptrans LIKE zfbid-ptrans,
         ptnot  LIKE zfbid-ptnot,
         amtttf LIKE zfbid-amtttf,
         amtcar LIKE zfbid-pcash,
         amttar LIKE zfbid-pcash.
DATA : END OF t_totaltemp.

DATA : BEGIN OF t_total OCCURS 10,
         pcash  LIKE zfbid-pcash,
         amtcar LIKE zfbid-pcash,
         pchek  LIKE zfbid-pchek,
         pcnot  LIKE zfbid-pcnot,
         ptrans LIKE zfbid-ptrans,
         amttar LIKE zfbid-pcash,
         ptnot  LIKE zfbid-ptnot,
         amtttf LIKE zfbid-amtttf.
DATA : END OF t_total.

DATA : BEGIN OF itab2 OCCURS 10.
         INCLUDE STRUCTURE zfbicheck.
       DATA : END OF itab2.

DATA:   BEGIN OF t_bdc OCCURS 0.
          INCLUDE STRUCTURE bdcdata.
        DATA:   END OF t_bdc.

DATA:   BEGIN OF messtab OCCURS 0.
          INCLUDE STRUCTURE bdcmsgcoll.
        DATA:   END OF messtab.

DATA: BEGIN OF t_resid OCCURS 0,
        vbeln LIKE zfbid-vbeln,
      END OF t_resid.

DATA: va_check(1),
      va_resid(1),
      va_cash     LIKE zfbid-pcash,
      va_sisa     LIKE zfbid-pcash,
      va_xblnr    LIKE zfbid-xblnr,
      va_error    TYPE i.

DATA: t_hkont LIKE zfacct OCCURS 0 WITH HEADER LINE.

RANGES: ra_hkont FOR bsis-hkont,
        ra_hkont1 FOR bsis-hkont.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
*constants :

************************************************************************
* VARIABLES                                                            *
************************************************************************
DATA: va_lines        TYPE i,
      va_pages        TYPE i,
      v_line_size     TYPE i,
      v_line_size_sum TYPE i,
      va_mark(1),
      va_budat(10),
      va_text(64)     VALUE 'Total',
      va_wrbtr        LIKE bseg-wrbtr,

      amountinv(17)   TYPE n,
      amt1            LIKE bseg-dmbtr,
      amt2            LIKE bseg-dmbtr,
      amt3            LIKE bseg-dmbtr,
      amt4            LIKE bseg-dmbtr,
      amt5            LIKE bseg-dmbtr,
      amt6            LIKE bseg-dmbtr,
      amt7            LIKE bseg-dmbtr,
      amtinv          LIKE bseg-dmbtr,
      paytot          LIKE bseg-dmbtr,
      warning(20),
      tot             LIKE bseg-dmbtr,
      total4          LIKE bseg-dmbtr,
      total9          LIKE bseg-dmbtr,
      tot1            LIKE bseg-dmbtr,
      tot2            LIKE bseg-dmbtr,
      tot3            LIKE bseg-dmbtr,
      tot4            LIKE bseg-dmbtr,
      totttf          LIKE bseg-dmbtr,
      resid(13),fl_test(1),
      totchek         LIKE bseg-dmbtr,
      v_cekno(10), "like zfbicheck-cekno,
      duedt(10), "like zfbicheck-duedt,
      bname           LIKE zfbicheck-bname,
      v_count         TYPE i,
      v_pytot         LIKE bseg-dmbtr,
      i_bdc           TYPE t_bdc OCCURS 0,
      wa_bdc          TYPE t_bdc,
      i_messtab       TYPE t_messtab OCCURS 0,
      wa_messtab      TYPE t_messtab,
      cvn             LIKE zfbid-xblnr,
      txt             LIKE bseg-sgtxt,
      pcn             LIKE zfbid-pcnot,
      pcnt            LIKE zfbid-pcnot,
      totentry        LIKE bseg-dmbtr,
      no(5),flerror(1),
      flagpc(1),
      totcash         LIKE bseg-dmbtr,
      totcn           LIKE bseg-dmbtr,
      test(17),
      fl(1),
      jumlah(255),
      v_lock(1),
      text1           LIKE spell,
      bidat(8),
      bldat(8),
      monat(2),
      date(8),fl_cash(1),
      v_amtcn2        TYPE i,
      v_amtcn3        TYPE i,
      v_amtcn4        TYPE i,
      voucher         LIKE zfbid-xblnr,
      vcn             LIKE zfbid-xblnr,
      vcnt            LIKE zfbid-xblnr,
      vtr             LIKE zfbid-xblnr,
      voucher1(45),zuonr(18),
      sp(1),t_cn TYPE p DECIMALS 0,
      t_cnt           TYPE p DECIMALS 0,
      v_gsber         LIKE bsid-gsber,
      cash(13),poskey(2),
      pytot(13),bktxt(24),
      flag(1),sw TYPE i,
      doctype         LIKE bsis-blart,
      shkzg           LIKE bsid-shkzg,
      vbeln           LIKE zfbid-vbeln,
      v_bbeln         LIKE zfbid-bbeln,
      v_amtcash       LIKE bseg-dmbtr,
      v_amttr         LIKE bseg-dmbtr,
      v_vbtyp         LIKE zsl_hsales-vbtyp,
*               pa_BBELN LIKE ZFBID-BBELN,
      va_nou          TYPE i,
      c1              TYPE i,
      c2              TYPE i,
      c3              TYPE i,
      c4              TYPE i,flpost(1),
      w1              TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
      w5              TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
      w9              TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
      w13             TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
      w17             TYPE i,  w18   TYPE i,  w19   TYPE i,  w19a  TYPE i,
      w20             TYPE i,  w17a  TYPE i,
      w21             TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
      w25             TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
      w29             TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
      w33             TYPE i,  w34   TYPE i,  w35   TYPE i,
      l_name          LIKE kna1-name1.

DATA: i_itab1      TYPE t_itab1 OCCURS 0 WITH HEADER LINE,
      i_itab2      TYPE t_itab1,                                " occurs 0,
      i_log_error  TYPE t_log_error OCCURS 0,
      wa_log_error TYPE t_log_error,
      wa_itab1     TYPE t_itab1.
DATA  msg(80).

DATA : BEGIN OF gt_bsid OCCURS 0,
         bukrs TYPE bukrs,
         kunnr TYPE kunnr,
         augbl TYPE augbl,
         zuonr TYPE dzuonr,
         gjahr TYPE gjahr,
         belnr TYPE belnr_d,
         buzei TYPE buzei,
         budat TYPE budat,
         blart TYPE blart,
       END OF gt_bsid.

DATA : BEGIN OF gt_kna1 OCCURS 0,
         kunnr TYPE kunnr,
         name1 TYPE name1_gp,
       END OF gt_kna1.

DATA : gr_belnr TYPE RANGE OF belnr_d,
       gs_belnr LIKE LINE OF gr_belnr.

************************************************************************
* INCLUDES                                                             *
************************************************************************
INCLUDE <%_list>.
INCLUDE zsheader.

DATA: va_line(1024),
      va_linectr    TYPE i,
      va_mode(1),
      va_list       TYPE slist_listline.

DATA: gt_arpot    TYPE STANDARD TABLE OF zfbid_arpot,
      gt_zfarpoth TYPE STANDARD TABLE OF zfarpoth,
      gv_cash     TYPE zfbid-pcash,
      gv_trans    TYPE zfbid-ptrans.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS  pa_bukrs LIKE  t001-bukrs OBLIGATORY DEFAULT '8020'.
PARAMETERS  pa_vkbur LIKE zfbid-vkbur OBLIGATORY DEFAULT '0201' MODIF ID vkb.
SELECT-OPTIONS so_kunnr FOR zfbid-kunnr MODIF ID kun.
PARAMETERS  pa_bbeln LIKE zfbih-bbeln OBLIGATORY DEFAULT '1' MODIF
ID aac.
SELECT-OPTIONS pabbeln FOR zfbih-bbeln MODIF ID aad.
SELECT-OPTIONS pabidat FOR zfbih-erdt1 MODIF ID aad.
*     PARAMETERS  PA_GJAHR LIKE ZFBIH-GJAHR OBLIGATORY
*         DEFAULT SY-DATUM+0(4).
SELECT-OPTIONS so_budat FOR bkpf-budat MODIF ID bud.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1 USER-COMMAND ars
             DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) TEXT-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-006 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-016 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-007 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio7 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-017 FOR FIELD radio7.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS : txt1(37) DEFAULT TEXT-030 MODIF ID ass .
SELECTION-SCREEN POSITION 39.
PARAMETERS : txt2(27) DEFAULT TEXT-033 MODIF ID ass .

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank1 LIKE zfbicheck-bname MODIF ID dsa.
SELECTION-SCREEN POSITION 26.
PARAMETER : no1 LIKE zfbicheck-cekno MODIF ID dsa.
SELECTION-SCREEN POSITION 39.
PARAMETER : due1 LIKE zfbicheck-duedt MODIF ID dsa.

SELECTION-SCREEN POSITION 50.
PARAMETER : amount1 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no2 LIKE zfbicheck-cekno MODIF ID dsb.
SELECTION-SCREEN POSITION 39.
PARAMETER : due2 LIKE zfbicheck-duedt MODIF ID dsb.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank2 LIKE zfbicheck-bname MODIF ID dsb.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount2 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no3 LIKE zfbicheck-cekno MODIF ID dsc.
SELECTION-SCREEN POSITION 39.
PARAMETER : due3 LIKE zfbicheck-duedt MODIF ID dsc.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank3 LIKE zfbicheck-bname MODIF ID dsc.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount3 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no4 LIKE zfbicheck-cekno MODIF ID dsd.
SELECTION-SCREEN POSITION 39.
PARAMETER : due4 LIKE zfbicheck-duedt MODIF ID dsd.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank4 LIKE zfbicheck-bname MODIF ID dsd.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount4 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no5 LIKE zfbicheck-cekno MODIF ID dse.
SELECTION-SCREEN POSITION 39.
PARAMETER : due5 LIKE zfbicheck-duedt MODIF ID dse.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank5 LIKE zfbicheck-bname MODIF ID dse.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount5 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no6 LIKE zfbicheck-cekno MODIF ID dsf.
SELECTION-SCREEN POSITION 39.
PARAMETER : due6 LIKE zfbicheck-duedt MODIF ID dsf.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank6 LIKE zfbicheck-bname MODIF ID dsf.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount6 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no7 LIKE zfbicheck-cekno MODIF ID dsg.
SELECTION-SCREEN POSITION 39.
PARAMETER : due7 LIKE zfbicheck-duedt MODIF ID dsg.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank7 LIKE zfbicheck-bname MODIF ID dsg.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount7 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no8 LIKE zfbicheck-cekno MODIF ID dsh.
SELECTION-SCREEN POSITION 39.
PARAMETER : due8 LIKE zfbicheck-duedt MODIF ID dsh.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank8 LIKE zfbicheck-bname MODIF ID dsh.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount8 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 26.
PARAMETER : no9 LIKE zfbicheck-cekno MODIF ID dsi.
SELECTION-SCREEN POSITION 39.
PARAMETER : due9 LIKE zfbicheck-duedt MODIF ID dsi.
SELECTION-SCREEN POSITION 1.
PARAMETER : bank9 LIKE zfbicheck-bname MODIF ID dsi.
SELECTION-SCREEN POSITION 50.
PARAMETER : amount9 LIKE zfbid-pchek MODIF ID dsj.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(10) TEXT-031 MODIF ID dsa.

SELECTION-SCREEN POSITION 50.
PARAMETER : total2 LIKE zfbid-pchek MODIF ID ssc.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF SCREEN 500.

SELECTION-SCREEN BEGIN OF SCREEN 600 AS WINDOW.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-034.
SELECTION-SCREEN POSITION 22.
PARAMETER : amtcash LIKE bseg-dmbtr. "amountinv. "zfbid-pchek.
SELECTION-SCREEN COMMENT 45(31) TEXT-035.
SELECTION-SCREEN POSITION 77.
PARAMETER : crvn LIKE zfbid-xblnr.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-037.
SELECTION-SCREEN POSITION 22.
PARAMETER : amtcn  LIKE bseg-wrbtr. "zfbid-pchek.
SELECTION-SCREEN COMMENT 45(31) TEXT-038.
SELECTION-SCREEN POSITION 77.
PARAMETER : cpvn LIKE zfbid-xblnr.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-071.
SELECTION-SCREEN POSITION 22.
PARAMETER : amtcar  LIKE bseg-wrbtr. "zfbid-pchek.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.

* Added by Budi 05/04/2009
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-053.
SELECTION-SCREEN POSITION 22.
PARAMETER : amttr  LIKE bseg-wrbtr. "zfbid-pchek.
SELECTION-SCREEN COMMENT 45(31) TEXT-048.
SELECTION-SCREEN POSITION 77.
PARAMETER : tpvn LIKE zfbid-xblnr.
SELECTION-SCREEN END OF LINE.
* Endadd by Budi 05/04/2009

* Added by Budi 22/07/2009
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-057.
SELECTION-SCREEN POSITION 22.
PARAMETER : amtcnt  LIKE bseg-wrbtr. "zfbid-pchek.
SELECTION-SCREEN COMMENT 45(31) TEXT-058.
SELECTION-SCREEN POSITION 77.
PARAMETER : cpvnt LIKE zfbid-xblnr.
SELECTION-SCREEN END OF LINE.
* Endadd by Budi 22/07/2009

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-072.
SELECTION-SCREEN POSITION 22.
PARAMETER : amttar  LIKE bseg-wrbtr. "zfbid-pchek.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-036.
SELECTION-SCREEN POSITION 22.
PARAMETER : amtcheck LIKE bseg-dmbtr. "zfbid-pchek.

SELECTION-SCREEN COMMENT 45(31) TEXT-043.
SELECTION-SCREEN POSITION 77.
PARAMETER : cdate LIKE sy-datum MODIF ID cdt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(21) TEXT-044.
SELECTION-SCREEN POSITION 22.
PARAMETER : amtttf LIKE zfbid-amtttf.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK acct WITH FRAME.
SELECTION-SCREEN BEGIN OF BLOCK cash1 WITH FRAME TITLE TEXT-049.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-011 MODIF ID ss1.
SELECTION-SCREEN POSITION 16.
PARAMETER : hkontc LIKE bseg-hkont MODIF ID ss1 OBLIGATORY DEFAULT '0112100010'.
SELECTION-SCREEN POSITION 28.
PARAMETER textc  LIKE skat-txt20 MODIF ID ss3.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-012 MODIF ID ss1.
SELECTION-SCREEN POSITION 16.
PARAMETER : budatc LIKE sy-datum OBLIGATORY DEFAULT sy-datum MODIF ID ss1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK cash1.

SELECTION-SCREEN BEGIN OF BLOCK trans1 WITH FRAME TITLE TEXT-050.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-051 MODIF ID ss2.
SELECTION-SCREEN POSITION 16.
PARAMETER : hkonttc LIKE bseg-hkont MODIF ID ss2." OBLIGATORY DEFAULT '0113101010'.
SELECTION-SCREEN POSITION 28.
PARAMETER texttc  LIKE skat-txt20 MODIF ID ss4.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-052 MODIF ID ss2.
SELECTION-SCREEN POSITION 16.
PARAMETER : budattc LIKE sy-datum OBLIGATORY DEFAULT sy-datum MODIF ID ss2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK trans1.
SELECTION-SCREEN END OF BLOCK acct.

SELECTION-SCREEN END OF SCREEN 600.

SELECTION-SCREEN BEGIN OF SCREEN 610 AS WINDOW.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-034.
SELECTION-SCREEN POSITION 24.
PARAMETER : amtcash1 LIKE bseg-dmbtr MODIF ID ssa. "zfbid-pchek
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-073.
SELECTION-SCREEN POSITION 24.
PARAMETER : amtcar1 LIKE bseg-dmbtr MODIF ID ac1. "zfbid-pchek
SELECTION-SCREEN END OF LINE.

* Added by Budi 05/04/2009
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-053.
SELECTION-SCREEN POSITION 24.
PARAMETER : amttr1 LIKE bseg-dmbtr MODIF ID sst. "zfbid-pchek
SELECTION-SCREEN COMMENT 45(7) TEXT-055.
PARAMETER : kdtrf AS CHECKBOX MODIF ID ssu.
SELECTION-SCREEN END OF LINE.
* Endadd by Budi 05/04/2009

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-074.
SELECTION-SCREEN POSITION 24.
PARAMETER : amttar1 LIKE bseg-dmbtr MODIF ID at1. "zfbid-pchek
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-036.
SELECTION-SCREEN POSITION 24.
** Added by Budi.P Req. by SJT 28/10/2009
*PARAMETER : amtchek1 LIKE bseg-dmbtr MODIF ID sss. "zfbid-pchek
PARAMETER : amtchek1 LIKE zfbid-pchek MODIF ID sss.
** End Added by Budi.P Req. by SJT 28/10/2009
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-040.
SELECTION-SCREEN POSITION 24.
PARAMETER : amtcn1 LIKE  bseg-dmbtr  MODIF ID ssb. "zfbid-pchek
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-060.
SELECTION-SCREEN POSITION 24.
PARAMETER : amtcn2 LIKE  bseg-dmbtr MODIF ID sse. "zfbid-pchek
SELECTION-SCREEN END OF LINE.

* Added by Budi 22/07/2009
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) TEXT-059.
SELECTION-SCREEN POSITION 24.
PARAMETER : amtcn3 LIKE  bseg-dmbtr MODIF ID ssf. "zfbid-pchek
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) TEXT-061.
SELECTION-SCREEN POSITION 24.
PARAMETER : amtcn4 LIKE  bseg-dmbtr MODIF ID ssg. "zfbid-pchek
SELECTION-SCREEN END OF LINE.
* Endadd by Budi 22/07/2009

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-039.
SELECTION-SCREEN POSITION 24.
** Added by Budi.P Req. by SJT 28/10/2009
*PARAMETER : total LIKE bseg-dmbtr MODIF ID ssc. "zfbid-pchek
PARAMETER : total LIKE zfbid-pchek MODIF ID ssc.
** End Added by Budi.P Req. by SJT 28/10/2009
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-045.
SELECTION-SCREEN POSITION 24.
PARAMETER : nottf LIKE zfbid-nottf MODIF ID ntf.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) TEXT-046.
SELECTION-SCREEN POSITION 24.
PARAMETER : tglttf LIKE sy-datum MODIF ID ttf.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF SCREEN 610.

SELECTION-SCREEN BEGIN OF SCREEN 620 AS WINDOW.
PARAMETER : crvn_ed LIKE zfbid-xblnr.

SELECTION-SCREEN END OF SCREEN 620.

SELECTION-SCREEN BEGIN OF SCREEN 650 AS WINDOW.
SELECTION-SCREEN BEGIN OF BLOCK cash WITH FRAME TITLE TEXT-049.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-011.
SELECTION-SCREEN POSITION 16.
PARAMETER : hkont LIKE bseg-hkont OBLIGATORY DEFAULT '0112100010'.
SELECTION-SCREEN POSITION 28.
PARAMETER text  LIKE skat-txt20 MODIF ID ssb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-012.
SELECTION-SCREEN POSITION 16.
PARAMETER : budat LIKE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK cash.

SELECTION-SCREEN BEGIN OF BLOCK trans WITH FRAME TITLE TEXT-050.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-051.
SELECTION-SCREEN POSITION 16.
PARAMETER : hkontt LIKE bseg-hkont OBLIGATORY DEFAULT '0113101010'.
SELECTION-SCREEN POSITION 28.
PARAMETER textt  LIKE skat-txt20 MODIF ID ssb.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(14) TEXT-052.
SELECTION-SCREEN POSITION 16.
PARAMETER : budatt LIKE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK trans.
SELECTION-SCREEN END OF SCREEN 650.


************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON hkontc.
  IF amtcash IS NOT INITIAL OR
    amtcn IS NOT INITIAL OR
    amtcar IS NOT INITIAL.
    IF NOT hkontc IN ra_hkont.
      MESSAGE e000(26) WITH TEXT-042.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON hkonttc.
  IF amttr IS NOT INITIAL OR
    amtcnt IS NOT INITIAL OR
    amttar IS NOT INITIAL.
    IF NOT hkonttc IN ra_hkont1.
      MESSAGE e000(26) WITH TEXT-056.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON hkont.
  IF NOT hkont IN ra_hkont.
    MESSAGE e000(26) WITH TEXT-042.
  ENDIF.

AT SELECTION-SCREEN ON hkontt.
  IF NOT hkontt IN ra_hkont1.
    MESSAGE e000(26) WITH TEXT-056.
  ENDIF.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  va_mode = 'N'.
  CLEAR kdtrf.
  PERFORM ranges_hkont.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.

  IF sy-subrc EQ 0.
    pa_vkbur  = lv_parva.
  ENDIF.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
*  PERFORM ranges_hkont.
  PERFORM cek.
  IF radio1 = 'X'.
    PERFORM f_get_data.
    DESCRIBE TABLE i_itab1 LINES v_line_size.

    IF v_line_size > 0.
*      va_lines = va_lines + v_line_size.
      PERFORM cek_lock.
      v_lock = 'X'.
      amtcash = 0.amtcheck = 0.amtcn = 0.amtttf = 0.amttr = 0.amtcnt = 0.
      CALL SELECTION-SCREEN 600 STARTING AT 10 5.
      amt1 = amtcash.amt2 = amtcheck.amt3 = amtcn.amt4 = amttr.amt5 = amtcnt.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.

    IF amtcash <> 0 OR amtcheck <> 0 OR amtcn <> 0 OR amtttf <> 0 OR
       amttr <> 0 OR amtcnt <> 0 OR amtcar <> 0 OR amttar <> 0.
      SET PF-STATUS 'ZF_BI '.
      PERFORM header.
      PERFORM header1.
      PERFORM detail.
    ENDIF.
  ENDIF.

  IF radio3 = 'X'.
    fl_test = 'N'.
    PERFORM f_get_data_post.
    DESCRIBE TABLE i_itab1 LINES v_line_size.
    IF v_line_size > 0.
      PERFORM cek_lock.
      fl = space.
      CALL SELECTION-SCREEN 650 STARTING AT 10 10.
      IF pa_vkbur EQ '0300'.
        IF hkont EQ '0112100000'.
        ELSE.
          MESSAGE i000(26) WITH 'GL  Account harus 0112100000'.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
** Perubahan Accounting Code 22/09/2005
*        IF hkont >= '0112100010' AND hkont <= '0112100020'.
*        ELSE.
*          MESSAGE i000(26) WITH text-042.
*          LEAVE TO SCREEN 0.
*        ENDIF.
**
        IF hkont IN ra_hkont AND hkontt IN ra_hkont1.
        ELSE.
          IF NOT hkont IN ra_hkont.
            MESSAGE i000(26) WITH TEXT-042.
            LEAVE TO SCREEN 0.
          ENDIF.
          IF NOT hkontt IN ra_hkont1.
            MESSAGE i000(26) WITH TEXT-056.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.

      ENDIF.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
    IF flpost = 'X' AND flerror NE 'X'.
      SET PF-STATUS 'ZF_BI_PRINT'.
      PERFORM header_post.
      PERFORM detail_post.
    ENDIF.
  ENDIF.

  IF radio4 = 'X'.
    PERFORM f_get_data_update.
    DESCRIBE TABLE i_itab1 LINES v_line_size.
    IF v_line_size > 0.
      NEW-PAGE LINE-SIZE 182.
      PERFORM p_header1.
      PERFORM p_detail1.
      PERFORM p_total.
      PERFORM footer.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.

  IF radio5 = 'X'.
    PERFORM f_get_data_report.
    DESCRIBE TABLE i_itab1 LINES v_line_size.
    IF v_line_size > 0.
      NEW-PAGE LINE-SIZE 246
               LINE-COUNT 82.
      PERFORM p_header.
      PERFORM p_detail.
      PERFORM p_total.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.

  IF radio7 = 'X'.
    PERFORM f_get_data_report.
    PERFORM f_get_fi_document.

    DESCRIBE TABLE i_itab1 LINES v_line_size.
    IF v_line_size > 0.
      NEW-PAGE LINE-SIZE 169
               LINE-COUNT 82.
      PERFORM p_header_edc.
      PERFORM p_detail_edc.
*      PERFORM p_total.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.

  IF radio6 = 'X'.
    PERFORM get_data_reprint.
    DESCRIBE TABLE i_itab1 LINES v_line_size.
    IF v_line_size > 0.
      PERFORM header_post.
      PERFORM detail_post.
    ELSE.
      MESSAGE i000(26) WITH TEXT-010.
      STOP.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

TOP-OF-PAGE.

END-OF-PAGE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'AAD'.
      screen-active = 0.
    ENDIF.
    IF screen-group1 = 'KUN'.
      screen-active = 0.
    ENDIF.
    IF screen-group1 = 'BUD'.
      screen-active = 0.
    ENDIF.
    IF screen-group1 = 'ASS'.
      screen-input = 0.
    ENDIF.

    PERFORM read_itab.

    IF screen-group1 = 'SS3'.
      screen-input = 0.
    ENDIF.
    IF screen-group1 = 'SS4'.
      screen-input = 0.
    ENDIF.

    IF amtcash = 0.
      IF screen-group1 = 'SSA'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF amtcar = 0.
      IF screen-group1 = 'AC1'.
        screen-input = 0.
      ENDIF.
    ENDIF.
    IF amttar = 0.
      IF screen-group1 = 'AT1'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF amtcheck = 0.
      IF screen-group1 = 'SSS'.
        screen-input = 0.
      ENDIF.
    ENDIF.

* Added by Budi 05/04/2009
    IF amttr = 0.
      IF screen-group1 = 'SST'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF amttr = 0 AND amtcnt = 0.
      IF screen-group1 = 'SSU'.
        screen-input = 0.
      ENDIF.
    ENDIF.
* Endadd by Budi 05/04/2009

    IF amtttf = 0.
      IF screen-group1 = 'NTF'.
        screen-input = 0.
      ENDIF.
      IF screen-group1 = 'TTF'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF screen-group1 = 'SSB'.
      screen-input = 0.
    ENDIF.

    IF screen-group1 = 'SSE'.
      screen-input = 0.
    ENDIF.

    IF screen-group1 = 'SSF'.
      screen-input = 0.
    ENDIF.

    IF screen-group1 = 'SSG'.
      screen-input = 0.
    ENDIF.
    IF screen-group1 = 'SSC'.
      screen-input = 0.
    ENDIF.

    IF amtinv > 0.
      total = amtcash1 + amtchek1 + amttr1 + amtcar1 + amttar1.
      total2 = amtchek1.
    ELSE.
      IF v_vbtyp = 'O' OR
        v_vbtyp = 'N'.
*        total = amtcn1 + amtcn3.
        total = ( amtcn1 * -1 ) + ( amtcn3 * -1 ).
        IF amtchek1 IS NOT INITIAL.
          total = total + amtchek1.
          total2 = amtchek1.
        ENDIF.
        IF amtcn IS NOT INITIAL.
          IF screen-group1 = 'SSB'.
            screen-input = 1.
          ENDIF.
        ENDIF.
        IF amtcnt IS NOT INITIAL.
          IF screen-group1 = 'SSF'.
            screen-input = 1.
          ENDIF.
        ENDIF.
      ELSE.
        total = amtcn2 + amtcn4.
        IF amtchek1 IS NOT INITIAL.
          total = total + amtchek1.
          total2 = amtchek1.
        ENDIF.
        IF amtcn IS NOT INITIAL.
          IF screen-group1 = 'SSE'.
            screen-input = 1.
          ENDIF.
        ENDIF.
        IF amtcnt IS NOT INITIAL.
          IF screen-group1 = 'SSG'.
            screen-input = 1.
          ENDIF.
        ENDIF.
      ENDIF.
** End Added by Budi.P Req. by SJT 08/08/2009

      IF screen-group1 = 'SSA'.
        screen-input = 0.
      ENDIF.
      IF screen-group1 = 'AC1'.
        screen-input = 0.
      ENDIF.
      IF screen-group1 = 'SST'.
        screen-input = 0.
      ENDIF.
** Added by Budi.P Req. by SJT 28/10/2009
*      CLEAR : amtcash1,amtchek1,amttr1.
      CLEAR : amtcash1,amttr1.
** End Added by Budi.P Req. by SJT 28/10/2009
    ENDIF.
    PERFORM text.


    IF radio5 = 'X'.
      IF screen-group1 = 'AAC'.
        screen-active = 0.
      ENDIF.
      IF screen-group1 = 'AAD'.
        screen-active = 1.
      ENDIF.
      pa_bbeln = pabbeln.
    ENDIF.

    IF radio7 = 'X'.
      IF screen-group1 = 'AAC'.
        screen-active = 0.
      ENDIF.
      IF screen-group1 = 'AAD'.
        screen-active = 1.
      ENDIF.
      IF screen-group1 = 'KUN'.
        screen-active = 1.
      ENDIF.
      IF screen-group1 = 'BUD'.
        screen-active = 1.
      ENDIF.
      pa_bbeln = pabbeln.
    ENDIF.

    PERFORM cek_bank.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN.
  DATA : ls_zfarpoth  TYPE zfarpoth.

  LOOP AT SCREEN.
    IF amtcash IS NOT INITIAL OR
      amtcar IS NOT INITIAL OR
      amtcn IS NOT INITIAL OR
      amtcheck IS NOT INITIAL OR
      amttr IS NOT INITIAL OR
      amttar IS NOT INITIAL OR
      amtcnt IS NOT INITIAL.
      IF cdate IS INITIAL.
        MESSAGE e000(zab) WITH 'Voucher date harus diisi'.
      ENDIF.
      IF amtcash IS NOT INITIAL.
        IF amtcn GT amtcash.
          MESSAGE e000(zab) WITH 'CN tidak boleh lebih besar dari DN'.
        ENDIF.
      ENDIF.
      IF amttr IS NOT INITIAL.
        IF amtcnt GT amttr.
          MESSAGE e000(zab) WITH 'CN tidak boleh lebih besar dari DN'.
        ENDIF.
      ENDIF.

*      IF amtcar IS NOT INITIAL OR
*        amttar IS NOT INITIAL.
*        IF gt_zfarpoth[] IS INITIAL.
*          MESSAGE e000(zab) WITH 'Harap input AR Potongan (ZF06P)'.
*        ENDIF.
*      ELSEIF amtcar IS INITIAL AND
      IF amtcar IS INITIAL AND
        amttar IS INITIAL.
        IF gt_zfarpoth[] IS NOT INITIAL.
          READ TABLE gt_zfarpoth INTO ls_zfarpoth INDEX 1.
          MESSAGE e000(zab) WITH 'BI ada AR Potongan' ls_zfarpoth-noarp.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT SCREEN.
    IF nottf IS NOT INITIAL.
      IF tglttf IS INITIAL.
        MESSAGE e000(zab) WITH 'Fill in all required entry fields'.
      ELSE.
        IF tglttf GT sy-datum.
          MESSAGE e000(zab) WITH 'Tgl TTF tidak boleh lebih dari Tgl hari ini'.
        ENDIF.
      ENDIF.
    ELSE.
      IF sy-dynnr = '0610'.
        IF amtcash IS INITIAL AND
          amtcar IS INITIAL AND
          amtcn IS INITIAL AND
          amtcheck IS INITIAL AND
          amttr IS INITIAL AND
          amttar IS INITIAL AND
          amtcnt IS INITIAL.
          MESSAGE e000(zab) WITH 'Fill in all required entry fields'.
        ENDIF.
      ENDIF.
      IF tglttf GT sy-datum.
        MESSAGE e000(zab) WITH 'Tgl TTF tidak boleh lebih dari Tgl hari ini'.
      ENDIF.
    ENDIF.

    IF tglttf IS NOT INITIAL.
      PERFORM f_validasi_ttf USING wa_itab1-zuonr wa_itab1-kunnr.
    ENDIF.
  ENDLOOP.

  CASE sscrfields-ucomm.
    WHEN 'CRET'.
      IF radio3 = 'X' AND pa_vkbur EQ '0300' AND
         hkont EQ '0112100000'.
        flpost = 'X'.
*        PERFORM post2.
        PERFORM post2_new.
** Perubahan Accounting Code 22/09/2005
*      ELSEIF radio3 = 'X' AND pa_vkbur NE '0300' AND
*        hkont >= '0112100010' AND hkont <= '0112100020'.
**
      ELSEIF radio3 = 'X' AND pa_vkbur NE '0300' AND
        hkont IN ra_hkont AND hkontt IN ra_hkont1.
        flpost = 'X'.
*        PERFORM post2.
        PERFORM post2_new.
      ENDIF.
*    WHEN OTHERS.
*      LEAVE TO SCREEN 0.
  ENDCASE.
************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  READ CURRENT LINE FIELD VALUE: wa_itab1-zuonr,wa_itab1-budat,va_mark,
                                 wa_itab1-kunnr.
  DATA : ffield(20), fvalue(20).
  DATA: amtpcasht(12),
        amtpchekt(12),
        amtptranst(12),
        amtpcnott(12),
        amtptnott(12),
        amtcart(12),
        amttart(12),
        l_amtttf(12),
        l_len          TYPE i,
        l_res(1),
        l_vbtyp        LIKE zsl_hsales-vbtyp,
        l_zuonr        LIKE zsl_hsales-vbeln,
        l_amtcash1     LIKE amtcash1,
        l_amtcn1       LIKE amtcn1,
        l_wrbtr        LIKE itab-wrbtr.

  DATA : lv_belnr TYPE belnr_d,
         lv_gjahr TYPE gjahr.

  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.

    WHEN 'WA_ITAB1-ZUONR'.
      IF radio1 = 'X'.
        CLEAR : amtcash1,amtchek1,amttr1,amtcn1,total,amtcn2,nottf,tglttf,amtcn3,amtcn4,l_res,
                amtcar1,amttar1.

        PERFORM read_itab.
        IF ( amtcn <> 0 OR amtcnt <> 0 ) AND i_itab2-wrbtr < 0.
          PERFORM cek_blart.
* PENAMBAHAN BLART 'DA' REQUEST BY LLL ( DEVK909413 )
* BEGIN DELETE
*               IF DOCTYPE EQ 'RV' OR DOCTYPE EQ 'DR' OR DOCTYPE EQ 'DG'
*               OR DOCTYPE EQ 'ZA'.
* END DELETE

** Added by Budi.P Req. by SJT 03/08/2009
** BEGIN INSERT
*          IF doctype EQ 'RV' OR doctype EQ 'DR' OR doctype EQ 'DG'
*          OR doctype EQ 'ZA' OR doctype EQ 'DA'.
** END INSERT
**                 if shkzg = 'H'.
*            IF amtcn <> 0.
*              amtcn1 = i_itab2-wrbtr * -100.
*            ENDIF.
*            IF amtcnt <> 0.
*              amtcn3 = i_itab2-wrbtr * -100.
*            ENDIF.
**                 Else.
**                     AMTCN1 = I_ITAB2-WRBTR * 100.
**                 Endif.
*          ELSE.
**                 if shkzg = 'H'.
*            IF amtcn <> 0.
*              amtcn2 = i_itab2-wrbtr * -100.
*            ENDIF.
*            IF amtcnt <> 0.
*              amtcn4 = i_itab2-wrbtr * -100.
*            ENDIF.
**                 Else.
**                     AMTCN2 = I_ITAB2-WRBTR * 100.
**                 Endif.
*          ENDIF.
          CLEAR: i_itab1,v_vbtyp,amtcn1,amtcn2,amtcn3,amtcn4.
          READ TABLE i_itab1 WITH KEY zuonr = wa_itab1-zuonr.
          SELECT SINGLE vbtyp INTO v_vbtyp FROM vbrk WHERE vbeln = i_itab1-vbeln.
          IF v_vbtyp = 'O'.
*            IF amtcn <> 0.
*              amtcn1 = i_itab2-wrbtr * -100.
*            ENDIF.
*            IF amtcnt <> 0.
*              amtcn3 = i_itab2-wrbtr * -100.
*            ENDIF.
          ELSE.
*            IF amtcn <> 0.
*              amtcn2 = i_itab2-wrbtr * -100.
*            ENDIF.
*            IF amtcnt <> 0.
*              amtcn4 = i_itab2-wrbtr * -100.
*            ENDIF.
          ENDIF.
** End Added by Budi.P Req. by SJT 08/08/2009

        ENDIF.

        CLEAR: t_totaltemp. REFRESH: t_totaltemp.
        READ TABLE  itab
        WITH KEY  zuonr = wa_itab1-zuonr.  "BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF flag = 1.
            amtcash1 = itab-pcash * 100.
            amtchek1 = itab-pchek * 100.
            amttr1   = itab-ptrans * 100.
            amtcar1  = itab-amtcar * 100.
            amttar1  = itab-amttar * 100.
          ELSE.
            amtcash1 = itab-pcash * 100.
            amtchek1 = itab-pchek * 100.
            amttr1   = itab-ptrans * 100.
            amtcar1  = itab-amtcar * 100.
            amttar1  = itab-amttar * 100.
          ENDIF.
          nottf = itab-nottf.
          tglttf = itab-tglttf.
          CLEAR: t_totaltemp.
          t_totaltemp-pcash   = itab-pcash.
          t_totaltemp-pchek   = itab-pchek.
          t_totaltemp-pcnot   = itab-pcnot.
          t_totaltemp-ptnot   = itab-ptnot.
          t_totaltemp-ptrans  = itab-ptrans.
          t_totaltemp-amtttf  = itab-amtttf.
          t_totaltemp-amtcar  = itab-amtcar.
          t_totaltemp-amttar  = itab-amttar.
          APPEND t_totaltemp.
        ENDIF.

* Added 23/11/2012
        PERFORM f_proses_sel_screen USING wa_itab1-zuonr.
* Endadd 23/11/2012

        CALL SELECTION-SCREEN 610 STARTING AT 10 10.

        CHECK sy-subrc = 0.

** Added by Budi.P Req. by SJT 27/07/2009
*        CLEAR: l_len,l_res,l_vbtyp,l_zuonr,l_amtcash1,l_amtcn1.
*        l_len = strlen( wa_itab1-zuonr ) - 1.
*        l_res = wa_itab1-zuonr+l_len(1).
*        IF l_res NE 'R' AND amtcn1 NE 0.
*          l_zuonr = wa_itab1-zuonr.
*          SELECT SINGLE vbtyp INTO l_vbtyp
*            FROM zsl_hsales WHERE vbeln = l_zuonr  AND
*                                  vkbur = pa_vkbur AND
*                                  vkorg = pa_bukrs.
*          IF sy-subrc = 0 AND l_vbtyp = 'O'.
*            amtcash1 = amtcn1 * -1.
*            CLEAR: amtcn1.
*          ELSE.
*            SELECT SINGLE vbtyp INTO l_vbtyp
*              FROM vbrk WHERE vkorg = pa_vkbur       AND
*                              kunrg = wa_itab1-kunnr AND
*                              zuonr = wa_itab1-zuonr AND
*                              vbtyp in ('M','O').
*            IF sy-subrc = 0 AND l_vbtyp = 'O'.
*              amtcash1 = amtcn1 * -1.
*              CLEAR: amtcn1.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*        IF l_res NE 'R' AND amtcn3 NE 0.
*          l_zuonr = wa_itab1-zuonr.
*          SELECT SINGLE vbtyp INTO l_vbtyp
*            FROM zsl_hsales WHERE vbeln = l_zuonr  AND
*                                  vkbur = pa_vkbur AND
*                                  vkorg = pa_bukrs.
*          IF sy-subrc = 0 AND l_vbtyp = 'O'.
*            amttr1 = amtcn3 * -1.
*            CLEAR: amtcn3.
*          ELSE.
*            SELECT SINGLE vbtyp INTO l_vbtyp
*              FROM vbrk WHERE vkorg = pa_vkbur       AND
*                              kunrg = wa_itab1-kunnr AND
*                              zuonr = wa_itab1-zuonr AND
*                              vbtyp in ('M','O').
*            IF sy-subrc = 0 AND l_vbtyp = 'O'.
*              amttr1 = amtcn3 * -1.
*              CLEAR: amtcn3.
*            ENDIF.
*          ENDIF.
*        ENDIF.
** End Added by Budi.P Req. by SJT 27/07/2009

        IF tglttf IS NOT INITIAL.
          WRITE itab-wrbtr CURRENCY 'IDR' TO l_amtttf.
          MODIFY CURRENT LINE
          LINE FORMAT COLOR 4
          FIELD VALUE itab-amtttf FROM l_amtttf.
        ELSE.
          l_wrbtr = 0.
          WRITE l_wrbtr CURRENCY 'IDR' TO l_amtttf.
          MODIFY CURRENT LINE
          LINE FORMAT COLOR 4
          FIELD VALUE itab-amtttf FROM l_amtttf.
        ENDIF.

        IF amtinv < 0 AND amtcn1 <> 0.
          total9 = amtcn1 * -1.
        ENDIF.

        total4 = total / 100.
        READ TABLE  itab
        WITH KEY  zuonr = wa_itab1-zuonr.  "BINARY SEARCH.
        IF sy-subrc EQ 0.
          LOOP AT itab WHERE zuonr = wa_itab1-zuonr.
            DELETE itab.
            flag = 2.
          ENDLOOP.

          PERFORM append_itab.
        ELSE.
          PERFORM append_itab.
        ENDIF.

** Added by Budi.P Req. by SJT 27/07/2009
        v_amtcash = v_amtcash + amtcash1.
        v_amttr = v_amttr + amttr1.
        amtcash1 = abs( amtcash1 ).
        amttr1 = abs( amttr1 ).
** End Added by Budi.P Req. by SJT 27/07/2009

***** Koreksi By sukardi
*        amtpcash2 = amtcash1.
        amtcash1 = ( amtcash1 / 100 ).
        WRITE amtcash1 CURRENCY 'IDR' TO amtpcasht.
        amtcar1 = ( amtcar1 / 100 ).
        WRITE amtcar1 CURRENCY 'IDR' TO amtcart.
        amttar1 = ( amttar1 / 100 ).
        WRITE amttar1 CURRENCY 'IDR' TO amttart.
*        amtpcnot2 = amtcn1 .
        amtcn1   = amtcn1 / 100.
        WRITE amtcn1 CURRENCY 'IDR' TO amtpcnott.
        amttr1 = ( amttr1 / 100 ).
        WRITE amttr1 CURRENCY 'IDR' TO amtptranst.
        amtcn3   = amtcn3 / 100.
        WRITE amtcn3 CURRENCY 'IDR' TO amtptnott.
        MODIFY CURRENT LINE
        LINE FORMAT COLOR 4
        FIELD VALUE itab-pcash FROM amtpcasht               "amtpcash2
                    itab-pcnot FROM amtpcnott               "amtpcnot2
                    itab-ptnot FROM amtptnott               "amtpcnot2
                    itab-ptrans FROM amtptranst
                    itab-amtcar FROM amtcart
                    itab-amttar FROM amttart.            "amtpcnot2

** Added by Budi.P Req. by SJT 27/07/2009
*        l_len = strlen( wa_itab1-zuonr ) - 1.
*        l_res = wa_itab1-zuonr+l_len(1).
*        IF l_res NE 'R' AND amtcn1 NE 0.
*          CLEAR: l_amtcn1,amtcash1.
*          l_amtcash1 = amtcn1.
*          WRITE l_amtcash1 CURRENCY 'IDR' TO amtpcasht.
*          WRITE l_amtcn1 CURRENCY 'IDR' TO amtpcnott.
*          MODIFY CURRENT LINE
*          LINE FORMAT COLOR 4
*          FIELD VALUE itab-pcash FROM amtpcasht               "amtpcash2
*                      itab-pcnot FROM amtpcnott.              "amtpcnot2
*        ENDIF.
** End Added by Budi.P Req. by SJT 27/07/2009

******
*        MODIFY CURRENT LINE
*        LINE FORMAT COLOR 4
*        FIELD VALUE itab-pcash FROM amtcash1
*        itab-pcnot FROM amtcn1.

        PERFORM get_itab2.
        totchek = amount1 + amount2 + amount3 + amount4 + amount5 +
                  amount6 + amount7 + amount8 + amount9 .

        IF amtchek1 EQ 0 AND totchek NE 0.
          READ TABLE  itab
          WITH KEY  zuonr = wa_itab1-zuonr.  "BINARY SEARCH.
          IF sy-subrc EQ 0.
            LOOP AT itab2 WHERE belnr = itab-vbeln
                           AND  zuonr = itab-zuonr.
              DELETE itab2.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF amtchek1 <> 0.
          PERFORM get_itab2.
          CALL SELECTION-SCREEN 500 STARTING AT 10 10.
          PERFORM get_tot_check.

          totchek = amount1 + amount2 + amount3 + amount4 + amount5 +
                    amount6 + amount7 + amount8 + amount9 .

          IF amtchek1 = totchek.
            READ TABLE  itab
           WITH KEY  zuonr = wa_itab1-zuonr.  "BINARY SEARCH.
            IF sy-subrc EQ 0.
              LOOP AT itab2 WHERE belnr = itab-vbeln
                             AND  zuonr = itab-zuonr.
                DELETE itab2.
              ENDLOOP.
              LOOP AT itab WHERE zuonr = wa_itab1-zuonr.
                itab-pchek = amtchek1 / 100.
                MODIFY itab.
              ENDLOOP.

              PERFORM append_itab2.
            ELSE.
              PERFORM append_itab2.
              PERFORM append_itab.
            ENDIF.

*            amtpchek2 = amtchek1.

            amtchek1 = amtchek1 / 100.
            WRITE amtchek1 CURRENCY 'IDR' TO amtpchekt.
            MODIFY CURRENT LINE
            LINE FORMAT COLOR 4
            FIELD VALUE
            itab-pchek FROM amtpchekt.                      "amtpchek2.

*            MODIFY CURRENT LINE
*            LINE FORMAT COLOR 4
*            FIELD VALUE
*            itab-pchek FROM amtchek1.
          ELSE.
            READ TABLE  itab
            WITH KEY  zuonr = wa_itab1-zuonr.  "BINARY SEARCH.
            IF sy-subrc EQ 0.
              LOOP AT itab2 WHERE belnr = itab-vbeln
                             AND  zuonr = itab-zuonr.

                DELETE itab2.
              ENDLOOP.
              LOOP AT itab WHERE zuonr = wa_itab1-zuonr.
                itab-pchek = 0.
                MODIFY itab.
              ENDLOOP.

            ENDIF.
            amtchek1 = 0.
            MODIFY CURRENT LINE
            LINE FORMAT COLOR 4
            FIELD VALUE
            itab-pchek FROM amtchek1.
          ENDIF.
        ENDIF.
        IF amtchek1 = 0.
          amtchek1 = 0.
          MODIFY CURRENT LINE
          LINE FORMAT COLOR 4
          FIELD VALUE
          itab-pchek FROM amtchek1.
        ENDIF.

        IF amtcn2 <> 0.
          v_amtcn2 = amtcn2.
          WRITE v_amtcn2 CURRENCY 'IDR' TO amtpcnott.
          MODIFY CURRENT LINE
          LINE FORMAT COLOR 4
          FIELD VALUE
          itab-pcash FROM amtpcnott.
        ENDIF.

        IF amtcn4 <> 0.
          v_amtcn4 = amtcn4.
          WRITE v_amtcn4 CURRENCY 'IDR' TO amtptnott.
          MODIFY CURRENT LINE
          LINE FORMAT COLOR 4
          FIELD VALUE
          itab-ptrans FROM amtptnott.
        ENDIF.

* total line
        PERFORM f_line_total USING l_res.
      ENDIF.

    WHEN 'WA_ITAB1-BELNR'.
      lv_gjahr = wa_itab1-budat+6(4).
      lv_belnr = fvalue(10).
      SET PARAMETER ID 'BLN' FIELD lv_belnr.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      SET PARAMETER ID 'GJR' FIELD lv_gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    WHEN 'WA_ITAB1-BELNRR'.
      lv_gjahr = wa_itab1-budat+6(4).
      lv_belnr = fvalue(10).
      SET PARAMETER ID 'BLN' FIELD lv_belnr.
      SET PARAMETER ID 'BUK' FIELD pa_bukrs.
      SET PARAMETER ID 'GJR' FIELD lv_gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

  ENDCASE.

  CLEAR : amtcash1,amtchek1,amttr1,total,
          amount1, amount2,amount3,amount4, amount5,
          amount6,amount7, amount8,amount9,
          due1,due2,due3,due4,due5,due6,due7,due8,due9,
          no1,no2,no3,no4,no5,no6,no7,no8,no9,
          bank1,bank2,bank3,bank4,bank5,bank6,bank7,bank8,bank9,
          amtcn1, amtpcasht, amtpchekt, amtpcnott, amtpcnott, amtptranst, itab.

************************************************************************
* AT USER-COMMAND.
************************************************************************
AT USER-COMMAND.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      SET PF-STATUS 'ZF_BI'. "EXCLUDING 'SAVE'.

      IF va_error EQ 1.
        MESSAGE e000(26) WITH
     'Penulisan Bank salah ( hrs diawali dgn Alphabet )'.
      ELSE.
        IF radio1 = 'X'.
          tot  = 0. "amtcash + amtcheck.
          tot1 = 0.amt3 = 0.totttf = 0. tot2 = 0.amt5 = 0.amt6 = 0.amt7 = 0.

          LOOP AT itab.
            IF itab-pcash > 0.
              tot1 = tot1 + ( itab-pcash * 100 ).
            ELSE.
              amt3 = amt3 + ( itab-pcash * 100 ).
            ENDIF.
            IF itab-ptrans > 0.
              tot2 = tot2 + ( itab-ptrans * 100 ).
            ELSE.
              amt5 = amt5 + ( itab-ptrans * 100 ).
            ENDIF.
            tot = tot + ( itab-pchek * 100 ).

            amt3 = amt3 + ( itab-pcnot * 100 ).
            amt5 = amt5 + ( itab-ptnot * 100 ).

            amt6 = amt6 + ( itab-amtcar * 100 ).
            amt7 = amt7 + ( itab-amttar * 100 ).

            totttf = totttf + ( itab-amtttf * 100 ).

            IF itab-amtttf IS NOT INITIAL.
              IF itab-pcash IS NOT INITIAL OR
                itab-pchek IS NOT INITIAL OR
                itab-pcnot IS NOT INITIAL OR
                itab-ptnot IS NOT INITIAL OR
                itab-ptrans IS NOT INITIAL OR
                itab-amtcar IS NOT INITIAL OR
                itab-amttar IS NOT INITIAL.
                MESSAGE e000(26) WITH 'Nilai collection tidak sama'.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF amtttf NE totttf.
            flag = 1.
            MESSAGE e000(26) WITH 'TTF Tidak Sama'.
          ENDIF.

          IF amtcash NE tot1.
            flag = 1.
            MESSAGE e000(26) WITH 'CASH Tidak Sama'.
          ENDIF.

          IF amtcheck NE tot.
            flag = 1.
            MESSAGE e000(26) WITH 'CHECK Tidak Sama'.
          ENDIF.

          IF amttr NE tot2.
            flag = 1.
            MESSAGE e000(26) WITH 'Transfer Tidak Sama'.
          ENDIF.

          t_cn = abs( amt3 ).
          IF  t_cn NE amtcn.
            flag = 1.
            MESSAGE e000(26) WITH 'CN Tunai Tidak Sama'.
          ENDIF.

          t_cnt = abs( amt5 ).
          IF  t_cnt NE amtcnt.
            flag = 1.
            MESSAGE e000(26) WITH 'CN Transfer Tidak Sama'.
          ENDIF.

          IF amt6 <> amtcar.
            flag = 1.
            MESSAGE e000(26) WITH 'Amount Cash AR Potongan Tidak Sama'.
          ENDIF.
          IF amt7 <> amttar.
            flag = 1.
            MESSAGE e000(26) WITH 'Amount Transfer AR Potongan Tidak Sama'.
          ENDIF.

          amt1 = amtcash + amtcheck + amttr + amtcar + amttar - amtcn - amtcnt.
          amt2 = tot1 + tot + amt3 + tot2 + amt5 + amt6 + amt7.

          IF amt1 <> amt2.  "and amtcheck <> tot.
            flag = 1.
            MESSAGE e000(26) WITH TEXT-024.
          ELSE.
            IF amtcheck <> 0.
              SORT itab2 BY cekno.
              v_count = 1.
              LOOP AT itab2.
                IF v_cekno = itab2-cekno.
                  v_count = v_count + 1.
                  itab2-seqno = v_count.
                ELSE.
                  itab2-seqno = 1.
                ENDIF.
                v_cekno = itab2-cekno.
                MODIFY itab2.
              ENDLOOP.
              PERFORM f_update_zfbicheck_01 ON COMMIT.
            ENDIF.

            UPDATE zfbid SET bflag = 'D'
                         WHERE bukrs = pa_bukrs
                           AND vkbur = pa_vkbur
                           AND bbeln = pa_bbeln
                           AND bflag = space.

            LOOP AT itab.
              IF itab-pcash = 0 AND itab-pchek = 0 AND itab-pcnot = 0 AND
                 itab-ptnot = 0 AND itab-ptrans = 0 AND itab-amtcar = 0 AND
                 itab-amttar = 0.
                MOVE 'D' TO itab-bflag.
              ELSE.
                MOVE 'E' TO itab-bflag.
              ENDIF.

              CLEAR gv_cash.
              gv_cash = itab-pcash + itab-amtcar.
              IF itab-wrbtr <> gv_cash AND itab-wrbtr = itab-pytot.
                MOVE 'P' TO itab-pstat.
              ENDIF.

              CLEAR gv_trans.
              gv_trans = itab-ptrans + itab-amttar.
              IF itab-wrbtr <> gv_trans AND itab-wrbtr = itab-pytot.
                MOVE 'P' TO itab-pstat.
              ENDIF.

              IF itab-wrbtr > itab-pytot.
                MOVE 'P' TO itab-pstat.
              ENDIF.

              CLEAR: va_cash.
              va_cash = itab-pcash + itab-ptrans + itab-amtcar + itab-amttar.
              IF itab-wrbtr < va_cash AND itab-wrbtr > 0.
                IF itab-wrbtr LE itab-pcash.
                  itab-resid = abs( itab-wrbtr - ( itab-pcash + itab-amtcar ) ).
                  itab-pcash = itab-wrbtr.
                  IF itab-ptrans NE 0.
                    itab-residt = itab-ptrans.
                    itab-ptrans = 0.
                  ENDIF.
                ELSE.
                  CLEAR va_sisa.
                  va_sisa = itab-wrbtr.
                  IF itab-pcash NE 0.
                    va_sisa = abs( itab-wrbtr - ( itab-pcash + itab-amtcar ) ).
                  ENDIF.
                  IF itab-ptrans NE 0.
                    itab-residt = abs( va_sisa - ( itab-ptrans + itab-amttar ) ).
                    itab-ptrans = va_sisa.
                  ENDIF.
                ENDIF.
                MOVE 'P' TO itab-pstat.
              ENDIF.

              IF ( itab-pcash <> 0 OR itab-ptrans <> 0 OR
                   itab-amtcar <> 0 OR itab-amttar <> 0 ) AND
                   itab-pchek <> 0.
                MOVE 'P1' TO itab-ptype.
                fl_cash = 'X'.
              ENDIF.

              IF ( itab-pcash <> 0 OR itab-ptrans <> 0 OR
                   itab-amtcar <> 0 OR itab-amttar <> 0 ) AND
                   itab-pchek = 0.
                MOVE 'P2' TO itab-ptype.
                fl_cash = 'X'.
              ENDIF.

              IF itab-pcash = 0 AND itab-ptrans = 0 AND
                 itab-amtcar = 0 AND itab-amttar = 0 AND
                 itab-pchek <> 0.
                MOVE 'P3' TO itab-ptype.
              ENDIF.

              IF itab-pcnot <> 0.
                itab-pytot = itab-pcnot.
                fl_cash = 'X'.
              ENDIF.
              IF itab-ptnot <> 0.
                itab-pytot = itab-ptnot.
                fl_cash = 'X'.
              ENDIF.

              PERFORM f_update_zfbid_02.
              COMMIT WORK AND WAIT.
            ENDLOOP.

            LOOP AT itab WHERE pchek <> 0 AND pcash <> 0 AND ptrans <> 0 AND
              amtcar <> 0 AND amttar <> 0.
              LOOP AT itab2 WHERE bbeln EQ itab-bbeln.
                itab-kunnr = itab2-kunnr.
              ENDLOOP.
              PERFORM delete.
            ENDLOOP.

            CLEAR itab.
            SELECT *  INTO TABLE itab FROM zfbid
             WHERE bukrs EQ pa_bukrs AND
             vkbur EQ pa_vkbur AND
             bbeln EQ pa_bbeln AND
             bflag EQ 'D'.
            LOOP AT itab.
              PERFORM delete.
            ENDLOOP.
            PERFORM release_lock.
            IF fl_cash = 'X'.
              PERFORM radio3.
            ENDIF.
          ENDIF.
        ENDIF.

        IF amtcheck IS NOT INITIAL.
          IF amtcash IS INITIAL AND
            amtcn IS INITIAL AND
            amttr IS INITIAL AND
            amtcnt IS INITIAL AND
            amtcar IS INITIAL AND
            amttar IS INITIAL.
            MESSAGE s000(zab) WITH 'Changes have been saved'.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'BACK'.
      PERFORM release_lock.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM release_lock.
      LEAVE TO SCREEN 0.

    WHEN 'CANCEL'.
      PERFORM release_lock.
      LEAVE TO SCREEN 0.

    WHEN 'PRNT'.
      PERFORM print.
  ENDCASE.
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : lv_bbeln   TYPE zfarpoth-bbeln.

  SELECT a~bukrs a~bbeln b~gjahr a~bidat a~parnr a~waers
         a~vkbur b~ebelp b~vbeln b~buzei b~gsber b~fkdat
         b~kunnr b~parvw b~slcod b~zfbdt b~wrbtr b~zuonr
         b~resid b~residt b~ptnot
         INTO CORRESPONDING FIELDS OF TABLE i_itab1
     FROM zfbih AS a JOIN  zfbid AS b ON a~bukrs EQ b~bukrs AND
                                         a~bbeln EQ b~bbeln AND
                                         a~vkbur EQ b~vkbur
*                                             A~GJAHR EQ B~GJAHR
     WHERE a~bukrs EQ pa_bukrs AND
           a~vkbur EQ pa_vkbur AND
*               A~GJAHR EQ PA_GJAHR AND
           a~bbeln EQ pa_bbeln AND
           b~bflag EQ space
           ORDER BY b~vbeln.

  SELECT *
    FROM zfbid_arpot
    INTO CORRESPONDING FIELDS OF TABLE gt_arpot
    WHERE bukrs  = pa_bukrs
      AND vkbur  = pa_bbeln
      AND bbeln  = pa_bbeln.

  lv_bbeln = pa_bbeln.

  SELECT *
    FROM zfarpoth
    INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
    WHERE bukrs    = pa_bukrs
      AND vkbur    = pa_vkbur
      AND bbeln    = lv_bbeln
      AND belnrrev = space.
ENDFORM.                    " f_get_data

*---------------------------------------------------------------------*
*       FORM HEADER                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM header.
  total = amtcash + amtcheck + amttr - amtcn - amtcnt + amtcar + amttar.
  pcn = amtcn * -1.
  pcnt = amtcnt * -1.
  WRITE :/ 'Amount Cash        '.
  WRITE AT 30 amtcash. "currency 'IDR'.
  WRITE :/ 'Amount Chek               '.
  WRITE AT 30 amtcheck. "currency 'IDR'.
  WRITE :/ 'Amount Transfer    '.
  WRITE AT 30 amttr. "currency 'IDR'.
  WRITE :/ 'Amount Cash Payment / CN  '.
  WRITE AT 28 pcn.
  WRITE :/ 'Amount Trans Payment / CN '.
  WRITE AT 28 pcnt.
  WRITE :/ 'Amount Cash AR Potongan '.
  WRITE AT 30 amtcar.
  WRITE :/ 'Amount Trans AR Potongan '.
  WRITE AT 30 amttar.
  WRITE :/ 'Total Collection          '.
  WRITE AT 30 total. "currency 'IDR'.
  WRITE :/ 'Amount TTF                '.
  WRITE AT 30 amtttf. "currency 'IDR'.

ENDFORM.                    "header

*---------------------------------------------------------------------*
*       FORM HEADER1                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM header1.
  WRITE : /(199) sy-uline.
  WRITE:/ sy-vline NO-GAP,(18) 'Delivery No',sy-vline NO-GAP,
              (10) 'Invoice Date',sy-vline NO-GAP,
              (10) 'Cust No.', sy-vline NO-GAP,
              (20) 'Customer Name',sy-vline NO-GAP,
              (18) 'Invoice Amount',sy-vline NO-GAP,
              (12) 'Amount Cash',sy-vline NO-GAP,
              (12) 'Amount Trans',sy-vline NO-GAP,
              (12) 'Cash AR Pot',sy-vline NO-GAP,
              (12) 'Trans AR Pot',sy-vline NO-GAP,
              (12) 'Amount Check',sy-vline NO-GAP,
              (12) 'Cash CN',sy-vline NO-GAP,
              (12) 'Transfer CN',sy-vline NO-GAP,
              (12) 'Amount TTF', sy-vline NO-GAP.
  WRITE : /(199) sy-uline.
ENDFORM.                                                    "header1

*---------------------------------------------------------------------*
*       FORM READ_ITAB                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM read_itab.
  CLEAR i_itab2.
  READ TABLE  i_itab1 INTO i_itab2
  WITH KEY  zuonr1 = wa_itab1-zuonr. "BINARY SEARCH.
  IF sy-subrc EQ 0.
    amtinv =  i_itab2-wrbtr * 100.
    pcn    = i_itab2-pcnot.
    pcnt   = i_itab2-ptnot.
    itab-bukrs = i_itab2-bukrs.
    itab-vkbur = i_itab2-vkbur.
    itab-gjahr = i_itab2-gjahr.
    itab-bbeln = i_itab2-bbeln.
    itab-ebelp = i_itab2-ebelp.
    itab-vbeln = i_itab2-vbeln.
    itab-wrbtr = i_itab2-wrbtr.
    itab-zuonr = i_itab2-zuonr.
    itab-usna1  = sy-uname.
    itab-erdt1 = cdate.
    IF amtchek1 <> 0.
      itab2-bukrs = i_itab2-bukrs.
      itab2-vkbur = i_itab2-vkbur.
      itab2-gjahr = i_itab2-gjahr.
      itab2-kunnr = i_itab2-kunnr.
      itab2-belnr = i_itab2-vbeln.
      itab2-wrbtr = i_itab2-wrbtr.
      itab2-buzei = i_itab2-buzei.
      itab2-zuonr = i_itab2-zuonr.
      itab2-zfbdt = i_itab2-zfbdt.
      itab2-slcod = i_itab2-slcod.
      itab2-gsber = i_itab2-gsber.
      itab2-bbeln = i_itab2-bbeln.
      itab2-usna1  = sy-uname.
      itab2-erdt1 = sy-datum.
    ENDIF.

  ENDIF.
ENDFORM.                    "read_itab

*---------------------------------------------------------------------*
*       FORM APPEND_ITAB                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM append_itab.
*  IF doctype = 'DZ' AND amtcn2 <> 0.
  IF amtcn2 <> 0.
    itab-pcash = amtcn2 / -100.
  ELSE.
    itab-pcash = ( amtcash1 / 100 ).
  ENDIF.

*  IF doctype = 'DZ' AND amtcn4 <> 0.
  IF amtcn4 <> 0.
    itab-ptrans = amtcn4 / -100.
  ELSE.
    itab-ptrans = ( amttr1 / 100 ).
  ENDIF.

  itab-amtcar = ( amtcar1 / 100 ).
  itab-amttar = ( amttar1 / 100 ).

  itab-pchek = amtchek1 / 100.
  itab-pcnot = amtcn1 / -100.
  itab-ptnot = amtcn3 / -100.
*  itab-ptrans = amttr1 / 100.
  itab-kdtrf = kdtrf.

  IF itab-pcnot <> 0.
    itab-xblnr = cpvn.
  ELSE.
    IF itab-pcash <> 0 OR itab-amtcar <> 0.
      itab-xblnr = crvn.
    ENDIF.
  ENDIF.
  IF itab-ptnot <> 0.
    itab-xblnrt = cpvnt.
  ELSE.
    IF itab-ptrans <> 0 OR itab-amttar <> 0.
      itab-xblnrt = tpvn.
    ENDIF.
  ENDIF.
  itab-pytot = total / 100.

  IF tglttf IS NOT INITIAL.
    itab-amtttf  = itab-wrbtr.
    itab-nottf   = nottf.
    itab-tglttf  = tglttf.
  ELSE.
    CLEAR: itab-amtttf, itab-nottf, itab-tglttf.
  ENDIF.
  APPEND itab.
ENDFORM.                    "append_itab

*---------------------------------------------------------------------*
*       FORM APPEND_ITAB2                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM append_itab2.
  IF amount1 <> 0 AND amtchek1 <> 0 AND bank1 NE space AND
     no1 NE space.
    itab2-bname = bank1.
    itab2-cekno = no1.
    itab2-duedt = due1.
    itab2-cchek = amount1 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ELSE.
    amount1 = 0.
  ENDIF.
  IF amount2 <> 0 AND amtchek1 <> 0 AND bank2 NE space AND
     no2 NE space.
    itab2-bname = bank2.
    itab2-cekno = no2.
    itab2-duedt = due2.
    itab2-cchek = amount2 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ELSE.
    amount2 = 0.
  ENDIF.

  IF amount3 <> 0 AND amtchek1 <> 0.
    itab2-bname = bank3.
    itab2-cekno = no3.
    itab2-duedt = due3.
    itab2-cchek = amount3 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ENDIF.

  IF amount4 <> 0 AND amtchek1 <> 0.
    itab2-bname = bank4.
    itab2-cekno = no4.
    itab2-duedt = due4.
    itab2-cchek = amount4 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ENDIF.

  IF amount5 <> 0 AND amtchek1 <> 0.
    itab2-bname = bank5.
    itab2-cekno = no5.
    itab2-duedt = due5.
    itab2-cchek = amount5 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ENDIF.

  IF amount6 <> 0 AND amtchek1 <> 0.
    itab2-bname = bank6.
    itab2-cekno = no6.
    itab2-duedt = due6.
    itab2-cchek = amount6 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ENDIF.

  IF amount7 <> 0 AND amtchek1 <> 0.
    itab2-bname = bank7.
    itab2-cekno = no7.
    itab2-duedt = due7.
    itab2-cchek = amount7 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ENDIF.

  IF amount8 <> 0 AND amtchek1 <> 0.
    itab2-bname = bank8.
    itab2-cekno = no8.
    itab2-duedt = due8.
    itab2-cchek = amount8 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ENDIF.

  IF amount9 <> 0 AND amtchek1 <> 0.
    itab2-bname = bank9.
    itab2-cekno = no9.
    itab2-duedt = due9.
    itab2-cchek = amount9 / 100.
    itab2-blchk = total2 / 100.
    APPEND itab2.
  ENDIF.
ENDFORM.                    "append_itab2

*---------------------------------------------------------------------*
*       FORM DETAIL                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM detail.
  DATA: l_wrbtr   LIKE wa_itab1-wrbtr.

  CLEAR wa_itab1.
  SORT i_itab1 BY kunnr zuonr.
  LOOP AT i_itab1 INTO wa_itab1.
    WRITE:/ sy-vline NO-GAP,(18) wa_itab1-zuonr HOTSPOT ON COLOR 3
             INVERSE ,sy-vline NO-GAP,
             (10) wa_itab1-fkdat,sy-vline NO-GAP,
             (10) wa_itab1-kunnr, sy-vline NO-GAP.
    SELECT SINGLE name1 INTO l_name  FROM kna1 WHERE kunnr
    EQ wa_itab1-kunnr.
    amtinv = wa_itab1-wrbtr.                                " * 100.
    WRITE :  (20) l_name,sy-vline NO-GAP,
             (18) wa_itab1-wrbtr CURRENCY wa_itab1-waers,sy-vline
             NO-GAP,(12) itab-pcash CURRENCY wa_itab1-waers,
             sy-vline NO-GAP,
             (12) itab-ptrans CURRENCY 'IDR', sy-vline NO-GAP,
             (12) itab-amtcar CURRENCY 'IDR', sy-vline NO-GAP,
             (12) itab-amttar CURRENCY 'IDR',sy-vline NO-GAP,
             (12) itab-pchek CURRENCY 'IDR',sy-vline NO-GAP,
             (12) itab-pcnot CURRENCY 'IDR',sy-vline NO-GAP,
             (12) itab-ptnot CURRENCY 'IDR',sy-vline NO-GAP,
             (12) itab-amtttf CURRENCY 'IDR', sy-vline NO-GAP.
*             NO-GAP,(12) itab-pcash CURRENCY 'IDR',sy-vline NO-GAP,
*             (12) itab-pchek CURRENCY 'IDR',sy-vline NO-GAP,
*             (12) itab-pcnot CURRENCY 'IDR',sy-vline NO-GAP.

    wa_itab1-zuonr1 = wa_itab1-zuonr.

    ADD wa_itab1-wrbtr TO va_wrbtr.

    MODIFY i_itab1 FROM wa_itab1.
    CLEAR wa_itab1.
  ENDLOOP.

  WRITE : /(199) sy-uline.
  WRITE:/ sy-vline NO-GAP, (64) va_text,
          sy-vline NO-GAP, (18) va_wrbtr CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-pcash CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-ptrans CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-amtcar CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-amttar CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-pchek CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-pcnot CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-ptnot CURRENCY 'IDR',
          sy-vline NO-GAP, (12) t_total-amtttf CURRENCY 'IDR',
          sy-vline.
  va_lines = sy-linno.
  va_pages = sy-pagno.
  WRITE : /(199) sy-uline.
ENDFORM.                    "detail


*---------------------------------------------------------------------*
*       FORM F_GET_DATA_UPDATE                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data_update.
  SELECT a~bukrs a~bbeln b~gjahr a~bidat a~parnr a~waers
              a~vkbur b~ebelp b~vbeln b~buzei b~gsber b~fkdat
              b~kunnr b~parvw b~slcod b~zfbdt b~wrbtr b~pchek b~pytot
              b~pcash b~usna1 b~erdt1 b~pcnot b~resid b~zuonr b~ptrans
              b~xblnrt b~residt b~ptnot
              INTO CORRESPONDING FIELDS OF TABLE i_itab1
          FROM zfbih AS a JOIN  zfbid AS b ON a~bukrs EQ b~bukrs AND
                                              a~bbeln EQ b~bbeln AND
                                              a~vkbur EQ b~vkbur
*                                             A~GJAHR EQ B~GJAHR
          WHERE a~bukrs EQ pa_bukrs AND
                a~vkbur EQ pa_vkbur AND
*               A~GJAHR EQ PA_GJAHR AND
                a~bbeln EQ pa_bbeln AND
                b~bflag IN ('E','P')
                ORDER BY b~zuonr.

ENDFORM.                    "f_get_data_update

*---------------------------------------------------------------------*
*       FORM READ_ITAB2                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM read_itab2.
  CLEAR i_itab2.
  READ TABLE  i_itab1 INTO i_itab2
  WITH KEY  vbeln = wa_itab1-vbeln BINARY SEARCH.

ENDFORM.                                                    "read_itab2
*&---------------------------------------------------------------------*
*&      Form  read_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_table.
  v_count = 1.
  SELECT * FROM zfbicheck
  WHERE bukrs EQ i_itab2-bukrs AND
        vkbur EQ i_itab2-vkbur AND
        gjahr EQ i_itab2-gjahr AND
        belnr EQ i_itab2-vbeln.

    IF v_count = 1.
      bank1   = zfbicheck-bname.
      no1     = zfbicheck-cekno.
      due1    = zfbicheck-duedt.
      amount1 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 2.
      bank2 = zfbicheck-bname.
      no2   = zfbicheck-cekno.
      due2  = zfbicheck-duedt.
      amount2 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 3.
      bank3 = zfbicheck-bname.
      no3   = zfbicheck-cekno.
      due3  = zfbicheck-duedt.
      amount3 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 4.
      bank4 = zfbicheck-bname.
      no4   = zfbicheck-cekno.
      due4  = zfbicheck-duedt.
      amount4 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 5.
      bank5 = zfbicheck-bname.
      no5   = zfbicheck-cekno.
      due5  = zfbicheck-duedt.
      amount5 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 6.
      bank6 = zfbicheck-bname.
      no6   = zfbicheck-cekno.
      due6  = zfbicheck-duedt.
      amount6 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 7.
      bank7 = zfbicheck-bname.
      no7   = zfbicheck-cekno.
      due7  = zfbicheck-duedt.
      amount7 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 8.
      bank8 = zfbicheck-bname.
      no8   = zfbicheck-cekno.
      due8  = zfbicheck-duedt.
      amount8 = zfbicheck-cchek.
    ENDIF.

    IF v_count = 9.
      bank9 = zfbicheck-bname.
      no9   = zfbicheck-cekno.
      due9  = zfbicheck-duedt.
      amount9 = zfbicheck-cchek.
    ENDIF.


    v_count = v_count + 1.
  ENDSELECT.
ENDFORM.                    " read_table

*************************************************************
FORM f_dynpro USING dynbegin name value.
*************************************************************
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                    "f_dynpro

*---------------------------------------------------------------------*
*       FORM DELETE                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM delete.
  DATA : BEGIN OF itab9 OCCURS 0,
           belnr LIKE bsid-belnr,
           buzei LIKE bsid-buzei,
           blart LIKE bsid-blart,
         END OF itab9.
  REFRESH itab9.CLEAR itab9.

  SELECT  belnr buzei blart INTO TABLE itab9 FROM bsid
  WHERE bukrs EQ pa_bukrs AND kunnr EQ itab-kunnr AND
        zuonr EQ itab-zuonr.
* Tahun
*      AND GJAHR EQ ITAB-GJAHR.
  LOOP AT itab9.
    CLEAR i_bdc.

    PERFORM f_dynpro USING:
              'X' 'SAPMF05L'   '0102',
              ' ' 'BDC_CURSOR'   'RF05L-GJAHR',
   	       ' ' 'BDC_OKCODE'	 '/00',
   	       ' ' 'RF05L-BELNR'     itab9-belnr,
   	       ' ' 'RF05L-BUKRS'     pa_bukrs,
   	       ' ' 'RF05L-GJAHR'     itab-gjahr,
   	       ' ' 'RF05L-XKDEB'     'X',
           	' ' 'RF05L-BUZEI'     itab9-buzei.
    IF wa_itab1-kunnr(2) EQ 'SL'.
      PERFORM f_dynpro USING:
          'X' 'SAPLFCPD'   '0100',
          ' ' 'BDC_CURSOR' 'BSEC-SPRAS',
          ' ' 'BDC_OKCODE' '/00'.
    ENDIF.

    IF itab9-blart EQ 'RV' OR itab9-blart EQ 'ZA'.
      PERFORM f_dynpro USING:
         'X' 'SAPMF05L'    '0301',
         ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
         ' ' 'BDC_OKCODE'  '=AE',
         ' ' 'BSEG-ZLSPR'	 'Z',
         ' ' 'BSEG-SGTXT'  txt.
    ELSE.
      PERFORM f_dynpro USING:
         'X' 'SAPMF05L'    '0301',
         ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
         ' ' 'BDC_OKCODE'  '=AE',
         ' ' 'BSEG-ZLSPR'	 'Z'.
    ENDIF.

    CALL TRANSACTION 'FB09' USING i_bdc MODE va_mode UPDATE 'S'
            MESSAGES INTO messtab.
    PERFORM error.

  ENDLOOP.
ENDFORM.                    "delete

*---------------------------------------------------------------------*
*       FORM OPEN_FOR-PAYMENT                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM open_for-payment.
  DATA : BEGIN OF itab9 OCCURS 0,
           belnr LIKE bsid-belnr,
           gjahr LIKE bsid-gjahr,
           buzei LIKE bsid-buzei,
           blart LIKE bsid-blart,
         END OF itab9.
  REFRESH itab9.CLEAR itab9.

  SELECT  belnr gjahr buzei blart INTO TABLE itab9 FROM bsid
  WHERE bukrs EQ pa_bukrs AND kunnr EQ wa_itab1-kunnr AND
        zuonr EQ wa_itab1-zuonr.
* Tahun
*      AND GJAHR EQ WA_ITAB1-GJAHR.
  LOOP AT itab9.
    CLEAR i_bdc.

    PERFORM f_dynpro USING:
           'X' 'SAPMF05L'    '0102',
           ' ' 'BDC_CURSOR'  'RF05L-GJAHR',
   	       ' ' 'BDC_OKCODE'	 '/00',
   	       ' ' 'RF05L-BELNR' itab9-belnr,
   	       ' ' 'RF05L-BUKRS' pa_bukrs,
   	       ' ' 'RF05L-GJAHR' itab9-gjahr,  "wa_itab1-gjahr,
           ' ' 'RF05L-BUZEI' itab9-buzei,
   	       ' ' 'RF05L-XKDEB' 'X'.
    IF wa_itab1-kunnr(2) EQ 'SL'.
      PERFORM f_dynpro USING:
          'X' 'SAPLFCPD'   '0100',
          ' ' 'BDC_CURSOR' 'BSEC-SPRAS',
          ' ' 'BDC_OKCODE' '/00'.
    ENDIF.

    IF itab9-blart EQ 'RV' OR itab9-blart EQ 'ZA'.
      PERFORM f_dynpro USING:
         'X' 'SAPMF05L'    '0301',
         ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
         ' ' 'BDC_OKCODE'  '=AE',
         ' ' 'BSEG-ZLSPR'	 'Z',
         ' ' 'BSEG-SGTXT'  txt.
    ELSE.
      PERFORM f_dynpro USING:
         'X' 'SAPMF05L'    '0301',
         ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
         ' ' 'BDC_OKCODE'  '=AE',
         ' ' 'BSEG-ZLSPR'	 'Z'.
    ENDIF.

    CALL TRANSACTION 'FB09' USING i_bdc MODE va_mode UPDATE 'S'
            MESSAGES INTO messtab.
    PERFORM error.

  ENDLOOP.
ENDFORM.                    "open_for-payment



*---------------------------------------------------------------------*
*       FORM FULL_PAYMENT                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM full_payment.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
            'X' 'SAPMF05A'   '0103',
            ' ' 'BDC_CURSOR'   'RF05A-XPOS1(02)',
         ' ' 'BDC_OKCODE'  '/00',
         ' ' 'BKPF-BLDAT'  bidat,
         ' ' 'BKPF-BLART'  'DZ',
         ' ' 'BKPF-BUKRS'  pa_bukrs,
         ' ' 'BKPF-BUDAT'  date,
            ' ' 'BKPF-MONAT'  monat,
            ' ' 'BKPF-WAERS'  wa_itab1-waers,
            ' ' 'BKPF-XBLNR'  wa_itab1-xblnr,
            ' ' 'RF05A-KONTO' hkont,
            ' ' 'BSEG-GSBER'  wa_itab1-gsber,
            ' ' 'BSEG-WRBTR'  cash,
            ' ' 'BSEG-VALUT'  ' ',
            ' ' 'BSEG-SGTXT'  txt,
            ' ' 'RF05A-AGKON'  wa_itab1-kunnr,
            ' ' 'RF05A-AGKOA' 'D',
            ' ' 'RF05A-XNOPS' 'X',
            ' ' 'RF05A-XPOS1(01)' '',
            ' ' 'RF05A-XPOS1(02)' 'X',
            ' ' 'RF05A-XPOS1(06)' ' ',
            'X' 'SAPMF05A'    '0731',
            ' ' 'BDC_CURSOR'  'RF05A-SEL01(01)',
            ' ' 'BDC_OKCODE'  '=PA',
            ' ' 'RF05A-SEL01(01)' wa_itab1-vbeln,
            'X' 'SAPDF05X'    '3100',
            ' ' 'BDC_OKCODE'  '=BU',
            ' ' 'BDC_CURSOR'  'DF05B-PSSKT(01)',
            ' ' 'RF05A-ABPOS' '1'.

  CALL TRANSACTION 'F-28' USING i_bdc MODE va_mode UPDATE 'S'
          MESSAGES INTO messtab.
  PERFORM error.
ENDFORM.                    "full_payment

*---------------------------------------------------------------------*
*       FORM PARTIAL_PAYMENT                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM partial_payment.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
  'X' 'SAPMF05A' '0100',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE' '/00',
  ' ' 'BKPF-BLDAT' bidat,
  ' ' 'BKPF-BLART' 'DZ',
  ' ' 'BKPF-BUKRS' pa_bukrs,
  ' ' 'BKPF-BUDAT' date,
  ' ' 'BKPF-MONAT' monat,
  ' ' 'BKPF-WAERS' wa_itab1-waers,
  ' ' 'FS006-DOCID' '*',
  ' ' 'RF05A-NEWBS' '40',
  ' ' 'RF05A-NEWKO' hkont,
  'X' 'SAPMF05A' '0300',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE'  '/00',
  ' ' 'BSEG-WRBTR' cash,
  ' ' 'BSEG-VALUT' date,
  ' ' 'BSEG-SGTXT' txt,
  ' ' 'SAPMF05A'    '0700',
  ' ' 'RF05A-NEWBS' '15',
  ' ' 'RF05A-NEWKO' wa_itab1-kunnr,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPLKACB' '0002',
  ' ' 'BDC_CURSOR' 'COBL-GSBER',
  ' ' 'BDC_OKCODE'  '=ENTE',
  ' ' 'COBL-GSBER' wa_itab1-gsber,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPMF05A' '0301',
  ' ' 'BDC_CURSOR' 'BSEG-ZUONR',
  ' ' 'BDC_OKCODE'  '=BU',
  ' ' 'BSEG-WRBTR' cash,
  ' ' 'BSEG-MWSKZ' '**',
  ' ' 'BSEG-GSBER' wa_itab1-gsber,
  ' ' 'BSEG-ZFBDT' date,
  ' ' 'BSEG-REBZG' wa_itab1-vbeln,
  ' ' 'BSEG-ZUONR' wa_itab1-zuonr,
  ' ' 'BSEG-SGTXT' txt.

  CALL TRANSACTION 'F-21' USING i_bdc MODE va_mode UPDATE 'S'
               MESSAGES INTO messtab.
  PERFORM error.
ENDFORM.                    "partial_payment
*&---------------------------------------------------------------------*
*&      Form  f_get_data_post
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_post.
  DATA : lt_arpot TYPE STANDARD TABLE OF zfbid_arpot,
         ls_itab1 LIKE LINE OF i_itab1,
         ls_arpot LIKE LINE OF lt_arpot.

  SELECT a~bukrs a~bbeln b~gjahr a~bidat a~parnr a~waers
         a~vkbur b~ebelp b~vbeln b~buzei b~gsber b~fkdat
         b~kunnr b~parvw b~slcod b~zfbdt b~wrbtr b~pcash
         b~pcnot b~resid b~zuonr b~pstat b~pytot b~xblnr b~pchek
         b~erdt1 b~ptrans b~xblnrt b~residt b~ptnot
         INTO CORRESPONDING FIELDS OF TABLE i_itab1
     FROM zfbih AS a JOIN  zfbid AS b ON a~bukrs EQ b~bukrs AND
                                         a~bbeln EQ b~bbeln AND
                                         a~vkbur EQ b~vkbur
     WHERE a~bukrs EQ pa_bukrs
       AND a~vkbur EQ pa_vkbur
       AND a~bbeln EQ pa_bbeln
       AND b~bflag EQ 'E'.
*       AND ( b~pcash <> 0 OR b~pcnot < 0 OR b~ptrans <> 0 OR b~ptnot < 0 ) .
*               A~GJAHR EQ PA_GJAHR AND

  SELECT *
    FROM zfbid_arpot
    INTO CORRESPONDING FIELDS OF TABLE lt_arpot
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_vkbur
      AND bbeln = pa_bbeln.

  IF lt_arpot[] IS NOT INITIAL.
    LOOP AT i_itab1 INTO ls_itab1.
      CLEAR ls_arpot.
      READ TABLE lt_arpot INTO ls_arpot
                          WITH KEY bukrs = ls_itab1-bukrs
                                   vkbur = ls_itab1-vkbur
                                   bbeln = ls_itab1-bbeln
                                   ebelp = ls_itab1-ebelp
                                   vbeln = ls_itab1-vbeln.
      IF sy-subrc = 0.
        ls_itab1-amtcar = ls_arpot-amtcar.
        ls_itab1-amttar = ls_arpot-amttar.
        MODIFY i_itab1 FROM ls_itab1.
      ELSE.
        IF ls_itab1-pcash <> 0 OR
          ls_itab1-pcnot < 0 OR
          ls_itab1-ptrans <> 0 OR
          ls_itab1-ptnot < 0.
          CONTINUE.
        ELSE.
          DELETE TABLE i_itab1 FROM ls_itab1.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_get_data_post



*---------------------------------------------------------------------*
*       FORM F_INIT_PRINT                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_print.
  w1   =   4.      w11 = 12.      w21 = 12.      w31 = 10.
  w2   =  10.      w12 = 12.      w22 = 10.      w32 = 12.
  w3   =  30.      w13 = 12.      w23 = 10.      w33 = 12.
  w4   =   4.      w14 = 10.      w24 = 12.      w34 = 10.
  w5   =  10.      w15 = 12.      w25 = 12.      w35 = 10.
  w6   =  10.      w16 = 12.      w26 = 10.
  w7   =  15.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  12.      w18 = 10.      w28 = 12.
  w9   =  12.      w19 = 10.      w29 = 12.
  w10  =  12.      w20 = 12.      w30 = 10.
  c1 = 0.
ENDFORM.                    " f_init_column



*---------------------------------------------------------------------*
*       FORM F_WRITE_PRINT_HEADER                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_print_header.
  DATA: c2 TYPE i.
  PERFORM f_print_header.

  c1 = 1.
  WRITE: / sy-uline.
  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w9 + w10 + w11 + w12 + w13 + w14 + 5.
  WRITE AT c1(c2)  'P E M B A Y A R A N'  CENTERED NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w16.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w9 + w10 + w11 + w12 + w13 + w14 + 5.
  WRITE AT c1(c2)  sy-uline  CENTERED NO-GAP.
  c1 = c2 + c1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w16.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.

  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w11 + w12 + w13 + w14.
  WRITE AT c1(c2)  'Cek / Giro'  CENTERED NO-GAP.
  c1 = c1 + w11 + w12 + 1 + w13 + 1 + w14 + 1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w16.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  sy-uline(w5) NO-GAP  CENTERED.
  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  sy-uline(w6) NO-GAP CENTERED.
  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7)  sy-uline(w7) NO-GAP  CENTERED.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)  sy-uline(w8)  CENTERED NO-GAP.
  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w11)  sy-uline(w11)  CENTERED NO-GAP.
  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w12)  sy-uline(w12)  CENTERED NO-GAP.
  c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w13)  sy-uline(w13)  CENTERED NO-GAP.
  c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w14)  sy-uline(w14)  CENTERED NO-GAP.
  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w16.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1)  'No' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Kode' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Rute' NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w15)  'Rupiah'  CENTERED NO-GAP.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w16)  'Rupiah'  CENTERED NO-GAP.
  c1 = c1 + w16.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.

  WRITE: / sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1)  'Urut' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Outlet' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) 'D E B I T U R' NO-GAP  CENTERED.   c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'List' NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  'Tgl.Dok' NO-GAP  CENTERED. c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  'Due. Date' NO-GAP CENTERED. c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7)  'Bill No. Slm Co.' NO-GAP  CENTERED.
  c1 = c1 + w7.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)  'Rupiah'  CENTERED NO-GAP. c1 = c1 + w8.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w9)  'Jumlah'  CENTERED NO-GAP. c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w10)  'Tunai'  CENTERED NO-GAP. c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w11)  'Rupiah'  CENTERED NO-GAP. c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w12)  'Bank'  CENTERED NO-GAP. c1 = c1 + w12.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w13)  'Nomor'  CENTERED NO-GAP. c1 = c1 + w13.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w14)  'J.Tempo'  CENTERED NO-GAP. c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w15)  'C/N'  CENTERED NO-GAP. c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w16)  'S/F'  CENTERED NO-GAP. c1 = c1 + w16.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE: / sy-uline.
  c1 = 1.
ENDFORM.                    " f_write_column_header


*---------------------------------------------------------------------*
*       FORM F_PRINT_HEADER                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_header.
  DATA: l_vtext LIKE tvstt-vtext.
  SELECT SINGLE vtext INTO l_vtext FROM tvstt
         WHERE  spras EQ 'EN' AND
                vstel EQ pa_vkbur .

  WRITE sy-pagno TO v_current_page.
  SHIFT v_current_page LEFT DELETING LEADING space.
  v_title1 = 'B O R D E R E L   I N K A S O'.

  v_between_header_len =
    sy-linsz - v_left_header_len - v_right_header_len - 10.
  v_right = sy-linsz - v_right_header_len .

  FORMAT COLOR OFF INTENSIFIED ON.
  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINE' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.
  WRITE AT: 20(v_between_header_len) v_title1 CENTERED.

  POSITION v_right.
  WRITE: 'No.  : '   INTENSIFIED OFF,
           pa_bbeln LEFT-JUSTIFIED.
  WRITE:/  l_vtext INTENSIFIED OFF.
  POSITION v_right.
  WRITE: 'Date : ' INTENSIFIED OFF,
          sy-datum DD/MM/YYYY LEFT-JUSTIFIED.
  WRITE:/  'Proses : ' INTENSIFIED OFF,
           sy-datum INTENSIFIED ON,
           sy-uzeit INTENSIFIED ON.

  POSITION v_right.
  WRITE:  c_page  INTENSIFIED OFF,
          v_current_page LEFT-JUSTIFIED.
  IF NOT v_title4 IS INITIAL.
    WRITE AT: (sy-linsz) v_title4 CENTERED.
  ENDIF.

  IF NOT v_title5 IS INITIAL.
    WRITE AT: (sy-linsz) v_title5 CENTERED.
  ENDIF.
ENDFORM.                    " F_WRITE_HEADER
*&---------------------------------------------------------------------*
*&      Form  update_cash
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_cash.
  UPDATE zfbid
     SET xblnr = crvn_ed
     WHERE bukrs = pa_bukrs AND vkbur = pa_vkbur
     AND bbeln = pa_bbeln.


ENDFORM.                    " update_cash
*&---------------------------------------------------------------------*
*&      Form  update_chek
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_chek.
  c1 = 1.
  LOOP AT itab2 WHERE belnr EQ wa_itab1-vbeln
                  AND zuonr EQ wa_itab1-zuonr.
    IF c1 = 1.
      itab2-bname = bank1.
      itab2-cekno = no1.
      itab2-duedt = due1.
      MODIFY itab2.
    ENDIF.

    IF c1 = 2.
      itab2-bname = bank2.
      itab2-cekno = no2.
      itab2-duedt = due2.
      MODIFY itab2.
    ENDIF.

    IF c1 = 3.
      itab2-bname = bank3.
      itab2-cekno = no3.
      itab2-duedt = due3.
      MODIFY itab2.
    ENDIF.

    IF c1 = 4.
      itab2-bname = bank4.
      itab2-cekno = no4.
      itab2-duedt = due4.
      MODIFY itab2.
    ENDIF.

    IF c1 = 5.
      itab2-bname = bank5.
      itab2-cekno = no5.
      itab2-duedt = due5.
      MODIFY itab2.
    ENDIF.

    IF c1 = 6.
      itab2-bname = bank6.
      itab2-cekno = no6.
      itab2-duedt = due6.
      MODIFY itab2.
    ENDIF.

    IF c1 = 7.
      itab2-bname = bank7.
      itab2-cekno = no7.
      itab2-duedt = due7.
      MODIFY itab2.
    ENDIF.

    IF c1 = 8.
      itab2-bname = bank8.
      itab2-cekno = no8.
      itab2-duedt = due8.
      MODIFY itab2.
    ENDIF.

    IF c1 = 9.
      itab2-bname = bank9.
      itab2-cekno = no9.
      itab2-duedt = due9.
      MODIFY itab2.
    ENDIF.

    c1 = c1 + 1.

  ENDLOOP.


ENDFORM.                    " update_chek

*---------------------------------------------------------------------*
*       FORM F_PRINT_DETAIL                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_detail.
  DATA: l_name1    LIKE kna1-name1,
        l_kunde    LIKE vrkpa-kunde,
        l_vrtnr    LIKE knvk-vrtnr,
        l_text(30).
  va_nou = 0.
  total4 = 0. tot = 0. tot1 = 0. totchek = 0.
  LOOP AT i_itab1 INTO wa_itab1.

    c1 = 1.
    va_nou = va_nou + 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    WRITE AT c1(w1) va_nou NO-GAP. c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    WRITE AT c1(w2) wa_itab1-kunnr NO-GAP. c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    CLEAR l_name1.
    SELECT SINGLE name1 INTO l_name1 FROM kna1
       WHERE kunnr EQ wa_itab1-kunnr.

    WRITE AT c1(w3) l_name1 NO-GAP. c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    WRITE AT c1(w4) wa_itab1-parvw NO-GAP. c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    WRITE AT c1(w5) wa_itab1-bidat NO-GAP. c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    WRITE AT c1(w6) wa_itab1-zfbdt NO-GAP. c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    CLEAR l_text.
    CONCATENATE wa_itab1-vbeln  wa_itab1-slcod+6(4)
         INTO l_text SEPARATED BY space.
    WRITE AT c1(w7)  l_text NO-GAP DECIMALS 0.
    c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    WRITE AT c1(w8)   wa_itab1-wrbtr CURRENCY 'IDR' NO-GAP DECIMALS
0.
    c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w9)   wa_itab1-pytot CURRENCY 'IDR' NO-GAP DECIMALS
0.
    c1 = c1 + w9.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w10)   wa_itab1-pcash CURRENCY 'IDR' NO-GAP DECIMALS
0.
    c1 = c1 + w10.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w11)   wa_itab1-pchek CURRENCY 'IDR' NO-GAP DECIMALS
0.
    c1 = c1 + w11.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
    CLEAR : v_cekno,duedt,bname.
    SELECT SINGLE * FROM zfbicheck
    WHERE bukrs EQ pa_bukrs AND
    vkbur EQ pa_vkbur AND belnr EQ wa_itab1-vbeln.
    IF sy-subrc EQ 0.
      v_cekno = zfbicheck-cekno.
      duedt =  zfbicheck-duedt.
      bname = zfbicheck-bname.
    ENDIF.
    WRITE AT c1(w12)    bname NO-GAP.
    c1 = c1 + w12.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w12)   v_cekno NO-GAP.

    c1 = c1 + w13.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
    WRITE AT c1(w13)  duedt NO-GAP.

    c1 = c1 + w14.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w15.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w16.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = 1.
    WRITE: /  sy-vline.
    c1 = c1 + 1.
    c1 = c1 + w1.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w2.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    c1 = c1 + w3.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w4.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w5.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w6.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w7.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w8.
    WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
    c1 = c1 + w9.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w10.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w11.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w12.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w13.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w14.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w15.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = c1 + w16.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    c1 = 1.
    total4 = total4 + wa_itab1-pytot.
    tot = tot + wa_itab1-wrbtr.
    tot1 = tot1 + wa_itab1-pcash.
    totchek = totchek + wa_itab1-pchek.
  ENDLOOP.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  detail_collect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detail_collect.
  CLEAR wa_itab1.
  LOOP AT i_itab1 INTO wa_itab1.
  ENDLOOP.

ENDFORM.                    " detail_collect


*---------------------------------------------------------------------*
*       FORM F_PRINT_TOTAL                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_total.
  WRITE: / sy-uline.
  c1 = 1.
  WRITE: / '  ' .
  c1 = c1 + 1.
  c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  c1 = c1 + 1.
  c1 = c1 + w3.
  c1 = c1 + 1.
  c1 = c1 + w4.
  c1 = c1 + 1.
  c1 = c1 + w5.
  c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w7) 'Jumlah Total ' CENTERED NO-GAP DECIMALS 0.
  c1 = c1 + w7.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w8)   tot CURRENCY 'IDR'  NO-GAP DECIMALS 0..
  c1 = c1 + w8.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w9)   total4 CURRENCY 'IDR'  NO-GAP DECIMALS 0.
  c1 = c1 + w9.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w10)   tot1 CURRENCY 'IDR'  NO-GAP DECIMALS 0.
  c1 = c1 + w10.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w11)   totchek CURRENCY 'IDR'  NO-GAP DECIMALS 0.
  c1 = c1 + w11.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w12.
  c1 = c1 + 1.
  c1 = c1 + w13.
  c1 = c1 + 1.
  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w15.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w16.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  c1 = 1.
  WRITE: / '  ' .
  c1 = c1 + 1.
  c1 = c1 + w1.
  c1 = c1 + 1.
  c1 = c1 + w2.
  c1 = c1 + 1.
  c1 = c1 + w3.
  c1 = c1 + 1.
  c1 = c1 + w4.
  c1 = c1 + 1.
  c1 = c1 + w5.
  c1 = c1 + 1.
  c1 = c1 + w6.
  WRITE AT c1(1) sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w7 + w8 + w9 + w10 + w11 + 4.
  WRITE AT c1(c2) sy-uline NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c1 = c1 + w12.
  c1 = c1 + 1.
  c1 = c1 + w13.
  c1 = c1 + 1.
  c1 = c1 + w14.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  c2 = w15 + w16 + 1.
  WRITE AT c1(c2) sy-uline NO-GAP.
  c1 = c1 + c2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  SKIP 2.
  WRITE: / jumlah.
  SKIP 2.
  c1 = 1.
  WRITE: / 'Diserahkan Tgl  :  .../.../....' .
  c1 = c1 + w1 + w2 + w3 + w4 + w5 + w6 + 6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 'Terima Kembali Tgl : .../.../....'.
  c1 = c1 + w7 + w8 + w9 + w10 + w11 + 4.
  c2 = w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) 'Jumlah Rp : .....................'.
  c1 = 1.
  WRITE: / '(......) Lbr. Faktur / Kwitansi' .
  c1 = c1 + w1 + w2 + w3 + w4 + w5 + w6 + 6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 '(......) Lbr. Faktur / KwitaNsi' .
  c1 = c1 + w7 + w8 + w9 + w10 + w11 + 4.
  c2 = w12 + w13 + w14 + w15 + w16.
  c1 = 1.
  WRITE: / 'Tanda terima penagih' .
  c1 = c1 + w1 + w2 + w3 + w4 + w5 + w6 + 6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 'Seksi Inkaso' .
  c1 = c1 + w7 + w8 + w9 + w10 + w11 + 4.
  c2 = w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) 'Mengetahui Kep. Keuangan.'.
  SKIP 5.
  c1 = 1.
  WRITE: / '(..............................)' .
  c1 = c1 + w1 + w2 + w3 + w4 + w5 + w6 + 6.
  c2 = w7 + w8 + w9 + w10 + w11.
  WRITE AT c1 '(..............................)' .
  c1 = c1 + w7 + w8 + w9 + w10 + w11 + 4.
  c2 = w12 + w13 + w14 + w15 + w16.
  WRITE AT c1(c2) '(..............................)'.
  SKIP 3.
ENDFORM.                    " f_write_

*---------------------------------------------------------------------*
*       FORM JUMLAH                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM jumlah.

  CALL FUNCTION 'SPELL_AMOUNT '
    EXPORTING
      amount                = total4
      currency              = 'IDR'
      language              = 'i'
    IMPORTING
      in_words              = text1
    EXCEPTIONS
      records_not_found     = 1
      records_not_requested = 2
      OTHERS                = 3.
  CONCATENATE text1-word 'RUPIAH' INTO jumlah SEPARATED BY space.

ENDFORM.                    "jumlah
*&---------------------------------------------------------------------*
*&      Form  text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM text.
  SELECT SINGLE txt20 INTO text FROM skat
    WHERE ktopl = 'TSPC' AND spras = 'EN' AND saknr = hkont.
  SELECT SINGLE txt20 INTO textt FROM skat
    WHERE ktopl = 'TSPC' AND spras = 'EN' AND saknr = hkontt.
  SELECT SINGLE txt20 INTO textc FROM skat
    WHERE ktopl = 'TSPC' AND spras = 'EN' AND saknr = hkontc.
  SELECT SINGLE txt20 INTO texttc FROM skat
    WHERE ktopl = 'TSPC' AND spras = 'EN' AND saknr = hkonttc.
ENDFORM.                    " text
*&---------------------------------------------------------------------*
*&      Form  p_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_header.
  DATA: l_vtext LIKE tvst-adrnr,
        street  LIKE adrc-street,
        city1   LIKE adrc-city1.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.

  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINE' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.

  WRITE AT 80 'BUKTI B/I'.
  WRITE:/  street.
  WRITE :/ city1.

  WRITE :/ 'Cetak : ',sy-datum,sy-uzeit.
  WRITE : /(246) sy-uline.

  WRITE : / sy-vline NO-GAP,(6) 'BI No.',sy-vline NO-GAP,(10)  'KODE '
  CENTERED NO-GAP , sy-vline
  NO-GAP,(20) 'NAMA DEBITUR' CENTERED NO-GAP ,sy-vline NO-GAP,(2) 'RY',
  sy-vline NO-GAP,(14) 'NILAI',sy-vline NO-GAP,(14) 'NOMOR+SLM.KODE',
  sy-vline NO-GAP,(14) 'CASH (Rp)',sy-vline NO-GAP,(16) 'Trans (Rp)',sy-vline NO-GAP,
  (14) 'CHEQUE' CENTERED NO-GAP,sy-vline NO-GAP,(10) 'BANK',sy-vline NO-GAP,(10)
  'NO. CHEQUE',  sy-vline NO-GAP,(10) 'JATUH' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'C/N' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'C/N' CENTERED NO-GAP,sy-vline NO-GAP,
  (10) 'Created' CENTERED NO-GAP,sy-vline NO-GAP,
  (10) 'Created' CENTERED NO-GAP,sy-vline NO-GAP,
  (20) space, sy-vline NO-GAP,
  (10) space NO-GAP, sy-vline.

  WRITE :/ sy-vline NO-GAP,(6) ' ',sy-vline NO-GAP,(10) 'OUTLET'
           CENTERED NO-GAP ,sy-vline
 NO-GAP,(20) '' NO-GAP ,sy-vline NO-GAP,(2) '',sy-vline NO-GAP,(14) '',
  sy-vline NO-GAP,(14) '',sy-vline NO-GAP, (14) '',sy-vline NO-GAP,(16) '',sy-vline NO-GAP,
  (14) '(Rp)' CENTERED NO-GAP,sy-vline NO-GAP,(10) '',sy-vline NO-GAP,(10)
  '',sy-vline NO-GAP,(10) 'TEMPO' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'Cash' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'Transfer' CENTERED NO-GAP,sy-vline NO-GAP,
  (10) 'By' CENTERED NO-GAP,sy-vline NO-GAP,(10) 'On' CENTERED NO-GAP,sy-vline NO-GAP,
  (20) 'No.TTF' CENTERED, sy-vline NO-GAP, (10) 'Tgl.TTF' CENTERED NO-GAP, sy-vline.
  WRITE : /(246) sy-uline.

ENDFORM.                    " p_header
*&---------------------------------------------------------------------*
*&      Form  p_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_detail.
  DATA : l_text(30),
         sub1       LIKE bseg-dmbtr,
         sub2       LIKE bseg-dmbtr,
         sub3       LIKE bseg-dmbtr,
         sub4       LIKE bseg-dmbtr,
         sub5       LIKE bseg-dmbtr,
         sub6       LIKE bseg-dmbtr.
  total4 = 0. tot = 0. tot1 = 0. tot2 = 0. totchek = 0. amt1 = 0. amt2 = 0.
  v_bbeln = 0.no = no.

  SORT i_itab1 BY bbeln kunnr zuonr.
  LOOP AT i_itab1 INTO wa_itab1.
    wa_itab1-pcash = wa_itab1-pcash + wa_itab1-resid.
    wa_itab1-ptrans = wa_itab1-ptrans + wa_itab1-residt.
    CONCATENATE wa_itab1-zuonr  wa_itab1-slcod+6(4)
              INTO l_text SEPARATED BY space.
    CLEAR : v_cekno,duedt,bname.
    IF wa_itab1-pchek <> 0.
      SELECT * FROM zfbicheck
                WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur
                AND gjahr EQ wa_itab1-gjahr AND belnr EQ wa_itab1-vbeln
                AND bbeln EQ wa_itab1-bbeln AND zuonr EQ wa_itab1-zuonr.
        IF sy-subrc EQ 0.
          v_cekno = zfbicheck-cekno.
          WRITE zfbicheck-duedt TO duedt.
          bname = zfbicheck-bname.
          wa_itab1-pchek = zfbicheck-cchek.
        ELSE.
          v_cekno = space.
          duedt = space.bname = space.

        ENDIF."WA_ITAB1-BBELN
        no = no + 1.
        WRITE :/ sy-vline NO-GAP,(6) wa_itab1-bbeln,sy-vline NO-GAP,(10)
                      wa_itab1-kunnr NO-GAP.
        SELECT SINGLE name1 INTO l_name  FROM kna1 WHERE kunnr
                   EQ wa_itab1-kunnr.
        WRITE :  sy-vline NO-GAP,(20) l_name NO-GAP,sy-vline NO-GAP,(2)
            wa_itab1-parvw,sy-vline NO-GAP,(14) wa_itab1-wrbtr CURRENCY
                 'IDR',sy-vline NO-GAP,(14) l_text,sy-vline NO-GAP,(14)
                  wa_itab1-pcash CURRENCY 'IDR',sy-vline NO-GAP,(14)
                  wa_itab1-ptrans CURRENCY 'IDR',
                  wa_itab1-kdtrf,sy-vline NO-GAP,(14)
                  wa_itab1-pchek CURRENCY 'IDR' NO-GAP.
        WRITE : sy-vline NO-GAP,(10) bname,sy-vline NO-GAP,(10) v_cekno,
                sy-vline NO-GAP,(10) duedt NO-GAP,sy-vline NO-GAP,
              (14) wa_itab1-pcnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
              (14) wa_itab1-ptnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
                (10) wa_itab1-usna1 NO-GAP,sy-vline NO-GAP,(10)
                 wa_itab1-erdt1 NO-GAP,sy-vline NO-GAP.
        IF wa_itab1-nottf IS INITIAL OR
          wa_itab1-nottf EQ '00000000000000000000'.
          WRITE:  (20) space, sy-vline NO-GAP.
        ELSE.
          SHIFT wa_itab1-nottf LEFT DELETING LEADING '0'.
          WRITE:  (20) wa_itab1-nottf, sy-vline NO-GAP.
        ENDIF.
        IF wa_itab1-tglttf IS INITIAL.
          WRITE:  (10) space NO-GAP, sy-vline.
        ELSE.
          WRITE:  (10) wa_itab1-tglttf NO-GAP, sy-vline.
        ENDIF.
        CLEAR : wa_itab1-pcash,wa_itab1-pcnot,wa_itab1-wrbtr,wa_itab1-ptrans,wa_itab1-ptnot.
      ENDSELECT.
      IF sy-subrc NE 0.
        wa_itab1-pchek = '0'.
        i_itab1-pchek = '0'.
        MODIFY i_itab1 TRANSPORTING pchek.
        no = no + 1.
        WRITE :/ sy-vline NO-GAP,(6) wa_itab1-bbeln,sy-vline NO-GAP,(10)
                     wa_itab1-kunnr NO-GAP.
        SELECT SINGLE name1 INTO l_name  FROM kna1 WHERE kunnr
                   EQ wa_itab1-kunnr.
        WRITE :  sy-vline NO-GAP,(20) l_name NO-GAP,sy-vline NO-GAP,(2)
            wa_itab1-parvw,sy-vline NO-GAP,(14) wa_itab1-wrbtr CURRENCY
                 'IDR',sy-vline NO-GAP,(14) l_text,sy-vline NO-GAP,(14)
                  wa_itab1-pcash CURRENCY 'IDR',sy-vline NO-GAP,(14)
                  wa_itab1-ptrans CURRENCY 'IDR',
                  wa_itab1-kdtrf,sy-vline NO-GAP,(14)
                  wa_itab1-pchek CURRENCY 'IDR' NO-GAP.
        WRITE : sy-vline NO-GAP,(10) bname,sy-vline NO-GAP,(10) v_cekno,
                sy-vline NO-GAP,(10) duedt NO-GAP,sy-vline NO-GAP,
              (14) wa_itab1-pcnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
              (14) wa_itab1-ptnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
                (10) wa_itab1-usna1 NO-GAP,sy-vline NO-GAP,(10)
                 wa_itab1-erdt1 NO-GAP,sy-vline NO-GAP.
        IF wa_itab1-nottf IS INITIAL OR
          wa_itab1-nottf EQ '00000000000000000000'.
          WRITE:  (20) space, sy-vline NO-GAP.
        ELSE.
          SHIFT wa_itab1-nottf LEFT DELETING LEADING '0'.
          WRITE:  (20) wa_itab1-nottf, sy-vline NO-GAP.
        ENDIF.
        IF wa_itab1-tglttf IS INITIAL.
          WRITE:  (10) space NO-GAP, sy-vline.
        ELSE.
          WRITE:  (10) wa_itab1-tglttf NO-GAP, sy-vline.
        ENDIF.
        CLEAR : wa_itab1-pcash,wa_itab1-pcnot,wa_itab1-wrbtr,wa_itab1-ptrans.
      ENDIF.
    ELSE.
      no = no + 1."WA_ITAB1-BBELN

      WRITE :/ sy-vline NO-GAP,(6) wa_itab1-bbeln ,sy-vline NO-GAP,(10)
               wa_itab1-kunnr NO-GAP.
      SELECT SINGLE name1 INTO l_name  FROM kna1 WHERE kunnr
                 EQ wa_itab1-kunnr.
      WRITE :  sy-vline NO-GAP,(20) l_name NO-GAP,sy-vline NO-GAP,(2)
            wa_itab1-parvw,sy-vline NO-GAP,(14) wa_itab1-wrbtr CURRENCY
               'IDR',sy-vline NO-GAP,(14) l_text,sy-vline NO-GAP,(14)
                wa_itab1-pcash CURRENCY 'IDR',sy-vline NO-GAP,(14)
                wa_itab1-ptrans CURRENCY 'IDR',
                wa_itab1-kdtrf,sy-vline NO-GAP,(14)
                wa_itab1-pchek CURRENCY 'IDR' NO-GAP.
      WRITE : sy-vline NO-GAP,(10) bname,sy-vline NO-GAP,(10) v_cekno,
              sy-vline NO-GAP,(10) duedt NO-GAP,sy-vline NO-GAP,
              (14) wa_itab1-pcnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
              (14) wa_itab1-ptnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
              (10) wa_itab1-usna1 NO-GAP,sy-vline NO-GAP,(10)
               wa_itab1-erdt1 NO-GAP,sy-vline NO-GAP.
      IF wa_itab1-nottf IS INITIAL OR
          wa_itab1-nottf EQ '00000000000000000000'.
        WRITE:  (20) space, sy-vline NO-GAP.
      ELSE.
        SHIFT wa_itab1-nottf LEFT DELETING LEADING '0'.
        WRITE:  (20) wa_itab1-nottf, sy-vline NO-GAP.
      ENDIF.
      IF wa_itab1-tglttf IS INITIAL.
        WRITE:  (10) space NO-GAP, sy-vline.
      ELSE.
        WRITE:  (10) wa_itab1-tglttf NO-GAP, sy-vline.
      ENDIF.
    ENDIF.

    AT END OF bbeln.
      SUM.
      sub1 = wa_itab1-wrbtr.
      sub2 = wa_itab1-pcash + wa_itab1-resid.
      sub3 = wa_itab1-ptrans + wa_itab1-residt.
      sub4 = wa_itab1-pchek.
      sub5 = wa_itab1-pcnot.
      sub6 = wa_itab1-ptnot.
      WRITE : /(246) sy-uline.
      WRITE :/ sy-vline.
      WRITE AT 21(10) 'Sub Total : '.
      WRITE AT 46(14) sub1 CURRENCY 'IDR'.
      WRITE AT 78(14) sub2 CURRENCY 'IDR'.
      WRITE AT 94(14) sub3 CURRENCY 'IDR'.
      WRITE AT 110(16) sub4 CURRENCY 'IDR'.
      WRITE AT 160(16) sub5 CURRENCY 'IDR'.
      WRITE AT 175(16) sub6 CURRENCY 'IDR'.
      WRITE AT 246 sy-vline .
      WRITE : /(246) sy-uline.
      no = no + 3.
      sub1 = 0.sub2 = 0. sub3 = 0.sub4 = 0.sub5 = 0.sub6 = 0.
    ENDAT.
    IF no > 67.
*   WRITE : /(180) SY-ULINE.
      NEW-PAGE.
      PERFORM p_header.
      no = 0.
    ENDIF.
    v_bbeln = wa_itab1-bbeln.
    total4 = total4 + wa_itab1-pytot.
    tot = tot + wa_itab1-wrbtr.
    tot1 = tot1 + wa_itab1-pcash.
    tot2 = tot2 + wa_itab1-ptrans.
    totchek = totchek + wa_itab1-pchek.
    amt1 = amt1 + wa_itab1-pcnot.
    amt2 = amt2 + wa_itab1-ptnot.

  ENDLOOP.
ENDFORM.                    " p_detail

*---------------------------------------------------------------------*
*       FORM LINEOUTPUT                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  COLUMN                                                        *
*  -->  LENGTH                                                        *
*  -->  CHAR                                                          *
*---------------------------------------------------------------------*
FORM lineoutput USING column length char.
  DATA linepos TYPE p.
  linepos = column.
  DO length TIMES.
    POSITION linepos. WRITE char.
    ADD 1 TO linepos.
  ENDDO.
ENDFORM.                    "lineoutput
*&---------------------------------------------------------------------*
*&      Form  p_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_total.
  total4 = tot1 + totchek + amt1 + tot2 + amt2.
  WRITE AT /1 'Created By :'.
  CASE 'X'.
    WHEN radio5 OR radio7.
      WRITE AT 14(10) sy-uname.
    WHEN OTHERS.
      WRITE AT 14(10) zfbid-usna1.
      WRITE AT 37 sy-vline NO-GAP.
*    WRITE AT 38(14) total4 CURRENCY 'IDR'  NO-GAP DECIMALS 0.
      WRITE AT 38(14) tot CURRENCY 'IDR'  NO-GAP DECIMALS 0.
      WRITE AT 53 sy-vline NO-GAP.
      WRITE AT 69 sy-vline NO-GAP.
      WRITE AT 70(14) tot1 CURRENCY 'IDR'  NO-GAP DECIMALS 0.
      WRITE AT 85 sy-vline NO-GAP.
      WRITE AT 86(14) tot2 CURRENCY 'IDR'  NO-GAP DECIMALS 0.
      WRITE AT 101 sy-vline NO-GAP.
      WRITE AT 102(14) totchek CURRENCY 'IDR'  NO-GAP DECIMALS 0.
      WRITE AT 116 sy-vline NO-GAP.
      WRITE AT 151 sy-vline NO-GAP.
      WRITE AT 152(14) amt1 CURRENCY 'IDR'  NO-GAP DECIMALS 0.
      WRITE AT 166 sy-vline NO-GAP.
      WRITE AT 167(14) amt2 CURRENCY 'IDR'  NO-GAP DECIMALS 0.
      WRITE AT 181 sy-vline NO-GAP.
      WRITE AT /37(17) sy-uline.
      WRITE AT 69(48) sy-uline.
      WRITE AT 151(31) sy-uline.
  ENDCASE.

  IF radio4 = 'X'.
    PERFORM jumlah.
    SKIP 2.
    WRITE :/ jumlah.
  ENDIF.

ENDFORM.                    " p_total
*&---------------------------------------------------------------------*
*&      Form  footer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM footer.
  WRITE AT /98(6) 'TGL : '.
  WRITE AT 106(10) sy-datum.
  WRITE AT /1(20) 'Seksi Inkaso'.
  WRITE AT 50(20) 'Kep. Keuangan'.
  WRITE AT 100(20) 'Kasir' CENTERED NO-GAP.
  SKIP 2.
  WRITE AT /1(20) '(...........)'.
  WRITE AT 50(20) '(...........)'.
  WRITE AT 100(20) '(...........)' CENTERED NO-GAP.

ENDFORM.                    " footer
*&---------------------------------------------------------------------*
*&      Form  f_get_data_Report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_report.
  DATA : lv_subobject LIKE nriv-subobject,
         lv_year      LIKE nriv-toyear.

  CASE 'X'.
    WHEN radio5.
      SELECT a~bukrs a~bbeln b~gjahr a~bidat a~parnr a~waers
                   a~vkbur b~ebelp b~vbeln b~buzei b~gsber b~fkdat
                   b~kunnr b~parvw b~slcod b~zfbdt b~wrbtr b~pchek b~pytot
                   b~pcash b~usna1 b~erdt1 b~pcnot b~zuonr b~resid b~nottf b~tglttf b~amtttf
                   b~ptrans b~kdtrf b~xblnrt b~residt b~ptnot
                   INTO CORRESPONDING FIELDS OF TABLE i_itab1
               FROM zfbih AS a JOIN  zfbid AS b ON a~bukrs EQ b~bukrs AND
                                                   a~bbeln EQ b~bbeln AND
                                                   a~vkbur EQ b~vkbur
*                                             A~GJAHR EQ B~GJAHR
               WHERE a~bukrs EQ pa_bukrs AND
                     a~vkbur EQ pa_vkbur AND
*               A~GJAHR EQ PA_GJAHR AND
                     a~bbeln IN pabbeln AND
                     b~erdt1 IN pabidat AND
                     b~bflag IN ('D','E','P')
                     ORDER BY b~zuonr.

    WHEN radio7.
      SELECT a~bukrs a~bbeln b~gjahr a~bidat a~parnr a~waers
             a~vkbur b~ebelp b~vbeln b~buzei b~gsber b~fkdat
             b~kunnr b~parvw b~slcod b~zfbdt b~wrbtr b~pchek b~pytot
             b~pcash b~usna1 b~erdt1 b~pcnot b~zuonr b~resid b~nottf
             b~tglttf b~amtttf b~ptrans b~kdtrf b~xblnrt b~residt
             b~ptnot
      INTO CORRESPONDING FIELDS OF TABLE i_itab1
      FROM zfbih AS a JOIN  zfbid AS b ON a~bukrs EQ b~bukrs AND
                                          a~bbeln EQ b~bbeln AND
                                          a~vkbur EQ b~vkbur
      WHERE a~bukrs EQ pa_bukrs
        AND a~vkbur EQ pa_vkbur
        AND a~bbeln IN pabbeln
        AND b~kunnr IN so_kunnr
        AND b~erdt1 IN pabidat
        AND b~bflag IN ('D','E','P')
        AND b~kdtrf EQ 'X'
      ORDER BY b~zuonr.

      lv_subobject  = pa_bukrs.
      IF so_budat[] IS INITIAL.
        lv_year = sy-datum(6).
      ELSE.
        lv_year = so_budat-low(4).
      ENDIF.

      SELECT SINGLE fromnumber tonumber
        FROM nriv
        INTO (gs_belnr-low, gs_belnr-high)
        WHERE object    = 'RF_BELEG'
          AND subobject = lv_subobject
          AND nrrangenr = '01'
          AND toyear    = lv_year.

      gs_belnr-sign     = 'I'.
      gs_belnr-option   = 'BT'.
      APPEND gs_belnr TO gr_belnr.
  ENDCASE.
ENDFORM.                    " f_get_data_Report
*&---------------------------------------------------------------------*
*&      Form  p_header1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_header1.
  DATA: l_vtext LIKE tvst-adrnr,
        street  LIKE adrc-street,
        city1   LIKE adrc-city1.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.

  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINED' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.

  WRITE AT 95 'BUKTI B/I'.
  WRITE:/  street.
  WRITE AT 95'No. B/I    : '.
  WRITE AT 108 pa_bbeln.
  WRITE :/ city1.
  vcn = space.
  SELECT  * FROM zfbid
  WHERE bukrs = pa_bukrs AND bbeln = pa_bbeln
  AND vkbur EQ pa_vkbur AND
  bflag NE 'D'.
    IF zfbid-pcash NE 0 OR zfbid-resid NE 0.
      voucher = zfbid-xblnr.
    ENDIF.
    IF zfbid-pcnot NE 0.
      vcn = zfbid-xblnr.
    ENDIF.
    IF zfbid-ptrans NE 0 OR zfbid-residt NE 0.
      vtr = zfbid-xblnrt.
    ENDIF.
    IF zfbid-ptnot NE 0.
      vcnt = zfbid-xblnrt.
    ENDIF.

  ENDSELECT.
  sp = ' '.
  IF vcn NE space AND voucher NE space.
    sp = '&'.
  ENDIF.
*  CONCATENATE voucher sp vcn INTO voucher1 SEPARATED BY space.
  CONCATENATE voucher vcn vtr vcnt INTO voucher1 SEPARATED BY space.
  WRITE AT 95 'VCR G/L    : '.
  WRITE AT 108 voucher1.
  WRITE AT /95 'Tanggal    : '. WRITE AT 108 zfbid-erdt1.
  WRITE :/ 'Cetak : ',sy-datum,sy-uzeit.
  WRITE : /(181) sy-uline.
  WRITE : / sy-vline NO-GAP,(10)  'KODE ' CENTERED NO-GAP , sy-vline
  NO-GAP,(20) 'NAMA DEBITUR' CENTERED NO-GAP ,sy-vline NO-GAP,(2) 'RY',
  sy-vline NO-GAP,(14) 'NILAI',sy-vline NO-GAP,(14) 'NOMOR+SLM.KODE',
  sy-vline NO-GAP,(14) 'CASH (Rp)',sy-vline NO-GAP,(14) 'Trans (Rp)',
  sy-vline NO-GAP,(14) 'CHEQUE' CENTERED
  NO-GAP,sy-vline NO-GAP,(10) 'BANK',sy-vline NO-GAP,(10) 'NO. CHEQUE',
  sy-vline NO-GAP,(10) 'JATUH' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'C/N' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'C/N' CENTERED NO-GAP,sy-vline NO-GAP.
  WRITE :/ sy-vline NO-GAP,(10) 'OUTLET' CENTERED NO-GAP ,sy-vline
 NO-GAP,(20) '' NO-GAP ,sy-vline NO-GAP,(2) '',sy-vline NO-GAP,(14) '',
  sy-vline NO-GAP,(14) '',sy-vline NO-GAP, (14) '',sy-vline NO-GAP,
  (14) '',sy-vline NO-GAP,(14) ' (Rp)' CENTERED NO-GAP,sy-vline NO-GAP,(10) '',
  sy-vline NO-GAP,(10) '',sy-vline NO-GAP,(10) 'TEMPO' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'Cash' CENTERED NO-GAP,sy-vline NO-GAP,
  (14) 'Transfer' CENTERED NO-GAP,sy-vline NO-GAP.

  WRITE : /(181) sy-uline.

ENDFORM.                                                    " p_header1
*&---------------------------------------------------------------------*
*&      Form  p_detail1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_detail1.
  DATA l_text(30).
  total4 = 0. tot = 0. tot1 = 0. totchek = 0. amt1 = 0. amt2 = 0.
  SORT i_itab1 BY kunnr zuonr.
  LOOP AT i_itab1 INTO wa_itab1.
    wa_itab1-pcash = wa_itab1-pcash + wa_itab1-resid.
    wa_itab1-ptrans = wa_itab1-ptrans + wa_itab1-residt.
    CONCATENATE wa_itab1-zuonr  wa_itab1-slcod+6(4)
              INTO l_text SEPARATED BY space.
    CLEAR : v_cekno,duedt,bname.
    IF wa_itab1-pchek <> 0.
      SELECT * FROM zfbicheck
            WHERE bukrs EQ pa_bukrs AND vkbur EQ pa_vkbur
            AND gjahr EQ wa_itab1-gjahr AND belnr EQ wa_itab1-vbeln
            AND bbeln EQ wa_itab1-bbeln  AND zuonr EQ wa_itab1-zuonr.
        IF sy-subrc EQ 0.
          v_cekno = zfbicheck-cekno.
          WRITE zfbicheck-duedt TO duedt.
          bname = zfbicheck-bname.
          wa_itab1-pchek = zfbicheck-cchek.
        ELSE.
          v_cekno = space.
          duedt = space.bname = space.
        ENDIF.
        WRITE :/ sy-vline NO-GAP,(10) wa_itab1-kunnr NO-GAP.
        SELECT SINGLE name1 INTO l_name  FROM kna1 WHERE kunnr
              EQ wa_itab1-kunnr.
        WRITE :  sy-vline NO-GAP,(20) l_name NO-GAP,sy-vline NO-GAP,(2)
            wa_itab1-parvw,sy-vline NO-GAP,(14) wa_itab1-wrbtr CURRENCY
            'IDR',sy-vline NO-GAP,(14) l_text,sy-vline NO-GAP,(14)
             wa_itab1-pcash CURRENCY 'IDR',sy-vline NO-GAP,(14)
             wa_itab1-ptrans CURRENCY 'IDR',sy-vline NO-GAP,(14)
             wa_itab1-pchek CURRENCY 'IDR' NO-GAP.

        WRITE : sy-vline NO-GAP,(10) bname,sy-vline NO-GAP,(10) v_cekno,
            sy-vline NO-GAP,(10) duedt NO-GAP,sy-vline NO-GAP,
            (14) wa_itab1-pcnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
            (14) wa_itab1-ptnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP.
        total4 = total4 + wa_itab1-pytot.
        tot = tot + wa_itab1-wrbtr.
        tot1 = tot1 + wa_itab1-pcash.
        tot2 = tot2 + wa_itab1-ptrans.
        amt1 = amt1 + wa_itab1-pcnot.
        amt2 = amt2 + wa_itab1-ptnot.
        totchek = totchek + wa_itab1-pchek.

        CLEAR : wa_itab1-pcash,wa_itab1-pcnot,wa_itab1-wrbtr,wa_itab1-ptrans,wa_itab1-pcnot.
      ENDSELECT.
      IF sy-subrc NE 0.
        wa_itab1-pchek = '0'.
        WRITE :/ sy-vline NO-GAP,(10) wa_itab1-kunnr NO-GAP.
        SELECT SINGLE name1 INTO l_name  FROM kna1 WHERE kunnr
              EQ wa_itab1-kunnr.
        WRITE :  sy-vline NO-GAP,(20) l_name NO-GAP,sy-vline NO-GAP,(2)
            wa_itab1-parvw,sy-vline NO-GAP,(14) wa_itab1-wrbtr CURRENCY
            'IDR',sy-vline NO-GAP,(14) l_text,sy-vline NO-GAP,(14)
             wa_itab1-pcash CURRENCY 'IDR',sy-vline NO-GAP,(14)
             wa_itab1-ptrans CURRENCY 'IDR',sy-vline NO-GAP,(14)
             wa_itab1-pchek CURRENCY 'IDR' NO-GAP .

        WRITE : sy-vline NO-GAP,(10) bname,sy-vline NO-GAP,(10) v_cekno,
            sy-vline NO-GAP,(10) duedt NO-GAP,sy-vline NO-GAP,
            (14) wa_itab1-pcnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
            (14) wa_itab1-ptnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP.
        tot = tot + wa_itab1-wrbtr.
        tot1 = tot1 + wa_itab1-pcash.
        amt1 = amt1 + wa_itab1-pcnot.
        amt2 = amt2 + wa_itab1-pcnot.
        totchek = totchek + wa_itab1-pchek.

      ENDIF.
    ELSE.
      WRITE :/ sy-vline NO-GAP,(10) wa_itab1-kunnr NO-GAP.
      SELECT SINGLE name1 INTO l_name  FROM kna1 WHERE kunnr
            EQ wa_itab1-kunnr.
      WRITE :  sy-vline NO-GAP,(20) l_name NO-GAP,sy-vline NO-GAP,(2)
          wa_itab1-parvw,sy-vline NO-GAP,(14) wa_itab1-wrbtr CURRENCY
          'IDR',sy-vline NO-GAP,(14) l_text,sy-vline NO-GAP,(14)
           wa_itab1-pcash CURRENCY 'IDR',sy-vline NO-GAP,(14)
           wa_itab1-ptrans CURRENCY 'IDR',sy-vline NO-GAP,(14)
           wa_itab1-pchek CURRENCY 'IDR' NO-GAP .

      WRITE : sy-vline NO-GAP,(10) bname,sy-vline NO-GAP,(10) v_cekno,
          sy-vline NO-GAP,(10) duedt NO-GAP,sy-vline NO-GAP,
          (14) wa_itab1-pcnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP,
          (14) wa_itab1-ptnot CURRENCY 'IDR' NO-GAP,sy-vline NO-GAP.
      tot = tot + wa_itab1-wrbtr.
      tot1 = tot1 + wa_itab1-pcash.
      tot2 = tot2 + wa_itab1-ptrans.
      amt1 = amt1 + wa_itab1-pcnot.
      amt2 = amt2 + wa_itab1-ptnot.
      totchek = totchek + wa_itab1-pchek.
    ENDIF.
    CLEAR wa_itab1.
  ENDLOOP.
  WRITE : /(181) sy-uline.

ENDFORM.                                                    " p_detail1
*&---------------------------------------------------------------------*
*&      Form  update_flag
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_flag.
  UPDATE zfbid
    SET bflag = 'P'
    WHERE bukrs = wa_itab1-bukrs
      AND vkbur = wa_itab1-vkbur
      AND gjahr = wa_itab1-gjahr
      AND bbeln = wa_itab1-bbeln
      AND vbeln = wa_itab1-vbeln.
ENDFORM.                    " update
*&---------------------------------------------------------------------*
*&      Form  get_chek
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_chek.
  SELECT b~bukrs b~vkbur b~gjahr b~belnr b~bname b~cekno b~duedt
  INTO CORRESPONDING FIELDS OF TABLE itab2
  FROM zfbid AS a JOIN  zfbicheck AS b ON a~bukrs EQ b~bukrs AND
                                          a~vkbur EQ b~vkbur AND
                                          a~gjahr EQ b~gjahr
  WHERE b~bukrs EQ pa_bukrs AND
        b~vkbur EQ pa_vkbur AND
*           B~GJAHR EQ PA_GJAHR AND
        a~bbeln EQ pa_bbeln.

ENDFORM.                    " get_chek
*&---------------------------------------------------------------------*
*&      Form  update_tblcek
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_tblcek.
  SORT itab2 BY cekno.
  v_cekno = 'A'.
  v_count = 1.
  LOOP AT itab2.
    IF v_cekno = itab2-cekno.
      v_count = v_count + 1.
      itab2-seqno = v_count.
    ELSE.
      itab2-seqno = 1.
    ENDIF.
    v_cekno = itab2-cekno.
    MODIFY itab2.
  ENDLOOP.
  LOOP AT itab2.
    UPDATE zfbicheck
         SET bname = itab2-bname duedt = itab2-duedt cekno =
                     itab2-cekno
   WHERE bukrs = itab2-bukrs AND vkbur = itab2-vkbur
        AND gjahr = itab2-gjahr AND belnr = itab2-belnr.

  ENDLOOP.

ENDFORM.                    " update_tblcek
*&---------------------------------------------------------------------*
*&      Form  error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    READ TABLE i_messtab INTO wa_messtab INDEX 1.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_messtab-msgid
        lang = wa_messtab-msgspra
        no   = wa_messtab-msgnr
        v1   = wa_messtab-msgv1
        v2   = wa_messtab-msgv2
        v3   = wa_messtab-msgv3
        v4   = wa_messtab-msgv4
      IMPORTING
        msg  = msg.
    wa_log_error-bukrs = pa_bukrs.
    wa_log_error-gjahr = wa_itab1-gjahr.
    wa_log_error-belnr = wa_itab1-vbeln.
    APPEND wa_log_error TO i_log_error.

    zfbierror-bukrs = wa_log_error-bukrs.
    zfbierror-vkbur = pa_vkbur.
    zfbierror-gjahr = wa_itab1-gjahr.
    zfbierror-belnr = wa_itab1-vbeln.
    zfbierror-bbeln = pa_bbeln.
    zfbierror-tcode = wa_messtab-tcode.
    zfbierror-subrc = sy-subrc.
    zfbierror-uname = sy-uname.
    zfbierror-datum = sy-datum.
    zfbierror-uzeit = sy-uzeit.
    zfbierror-msg   = msg.
    MODIFY  zfbierror.
  ENDIF.

ENDFORM.                    " error
*&---------------------------------------------------------------------*
*&      Form  get_itab2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_itab2.
  READ TABLE itab
      WITH KEY  zuonr = wa_itab1-zuonr.  "BINARY SEARCH.
  IF sy-subrc EQ 0.
    v_count = 1.
    LOOP AT itab2 WHERE belnr = itab-vbeln
                    AND zuonr = itab-zuonr.
      IF v_count = 1.
        bank1   = itab2-bname.
        no1     = itab2-cekno.
        due1    = itab2-duedt.
        amount1 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 2.
        bank2 = itab2-bname.
        no2   = itab2-cekno.
        due2  = itab2-duedt.
        amount2 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 3.
        bank3 = itab2-bname.
        no3   = itab2-cekno.
        due3  = itab2-duedt.
        amount3 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 4.
        bank4 = itab2-bname.
        no4   = itab2-cekno.
        due4  = itab2-duedt.
        amount4 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 5.
        bank5 = itab2-bname.
        no5   = itab2-cekno.
        due5  = itab2-duedt.
        amount5 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 6.
        bank6 = itab2-bname.
        no6   = itab2-cekno.
        due6  = itab2-duedt.
        amount6 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 7.
        bank7 = itab2-bname.
        no7   = itab2-cekno.
        due7  = itab2-duedt.
        amount7 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 8.
        bank8 = itab2-bname.
        no8   = itab2-cekno.
        due8  = itab2-duedt.
        amount8 = itab2-cchek * 100.
      ENDIF.

      IF v_count = 9.
        bank9 = itab2-bname.
        no9   = itab2-cekno.
        due9  = itab2-duedt.
        amount9 = itab2-cchek * 100.
      ENDIF.


      v_count = v_count + 1.

    ENDLOOP.
  ENDIF.
ENDFORM.                                                    " get_itab2
*&---------------------------------------------------------------------*
*&      Form  full_payment_CN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM full_payment_cn.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
            'X' 'SAPMF05A'   '0103',
            ' ' 'BDC_CURSOR'   'RF05A-XPOS1(02)',
         ' ' 'BDC_OKCODE'  '/00',
         ' ' 'BKPF-BLDAT'  bidat,
         ' ' 'BKPF-BLART'  'DZ',
         ' ' 'BKPF-BUKRS'  pa_bukrs,
         ' ' 'BKPF-BUDAT'  date,
            ' ' 'BKPF-MONAT'  monat,
            ' ' 'BKPF-WAERS'  wa_itab1-waers,
            ' ' 'BKPF-XBLNR'  wa_itab1-xblnr,
            ' ' 'RF05A-AUGTX' txt,
            ' ' 'RF05A-KONTO' hkont,
            ' ' 'BSEG-GSBER'  wa_itab1-gsber,
            ' ' 'BSEG-WRBTR'  cash,
            ' ' 'BSEG-VALUT'  ' ',
            ' ' 'BSEG-SGTXT'  txt,
            ' ' 'RF05A-AGKON'  wa_itab1-kunnr,
            ' ' 'RF05A-AGKOA' 'D',
            ' ' 'RF05A-XNOPS' 'X',
            ' ' 'RF05A-XPOS1(01)' '',
            ' ' 'RF05A-XPOS1(02)' 'X',
            ' ' 'RF05A-XPOS1(06)' ' ',
            'X' 'SAPMF05A'    '0731',
            ' ' 'BDC_CURSOR'  'RF05A-SEL01(01)',
            ' ' 'BDC_OKCODE'  '=PA',
            ' ' 'RF05A-SEL01(01)' wa_itab1-vbeln,
            'X' 'SAPDF05X'    '3100',
            ' ' 'BDC_OKCODE'  '=BU',
            ' ' 'BDC_CURSOR'  'DF05B-PSSKT(01)',
            ' ' 'RF05A-ABPOS' '1'.

  CALL TRANSACTION 'F-31' USING i_bdc MODE va_mode UPDATE 'S'
          MESSAGES INTO messtab.
  PERFORM error.

ENDFORM.                    " full_payment_CN
*&---------------------------------------------------------------------*
*&      Form  partial_payment_resid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM partial_payment_resid.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
  'X' 'SAPMF05A' '0100',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE' '/00',
  ' ' 'BKPF-BLDAT' bidat,
  ' ' 'BKPF-BLART' 'DZ',
  ' ' 'BKPF-BUKRS' pa_bukrs,
  ' ' 'BKPF-BUDAT' date,
  ' ' 'BKPF-MONAT' monat,
  ' ' 'BKPF-WAERS' wa_itab1-waers,
  ' ' 'BKPF-XBLNR' wa_itab1-xblnr,
  ' ' 'FS006-DOCID' '*',
  ' ' 'RF05A-NEWBS' '40',
  ' ' 'RF05A-NEWKO' hkont,
  'X' 'SAPMF05A' '0300',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE'  '/00',
  ' ' 'BSEG-WRBTR' pytot,
  ' ' 'BSEG-VALUT' date,
  ' ' 'BSEG-SGTXT' txt,
  ' ' 'RF05A-NEWBS' '15',
  ' ' 'RF05A-NEWKO' wa_itab1-kunnr,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPLKACB' '0002',
  ' ' 'BDC_CURSOR' 'COBL-GSBER',
  ' ' 'BDC_OKCODE'  '=ENTE',
  ' ' 'COBL-GSBER' wa_itab1-gsber,
  ' ' 'BDC_SUBSCR' 'SAPLKACB',
  'X' 'SAPMF05A' '0301',
  ' ' 'BDC_CURSOR' 'RF05A-NEWKO',
  ' ' 'BDC_OKCODE' '/00',
  ' ' 'BSEG-WRBTR' cash,
  ' ' 'BSEG-MWSKZ' '**',
  ' ' 'BSEG-GSBER' wa_itab1-gsber,
  ' ' 'BSEG-ZFBDT' date,
  ' ' 'BSEG-REBZG' wa_itab1-vbeln,
  ' ' 'BSEG-ZUONR' wa_itab1-zuonr,
  ' ' 'BSEG-SGTXT' txt,
  ' ' 'RF05A-NEWBS' '15',
  ' ' 'RF05A-NEWKO' wa_itab1-kunnr,
  'X' 'SAPMF05A' '0301',
  ' ' 'BDC_OKCODE'  '=ZK',
  ' ' 'BSEG-WRBTR' resid,
  ' ' 'BSEG-MWSKZ' '**',
  ' ' 'BSEG-GSBER' wa_itab1-gsber,
  ' ' 'BSEG-ZFBDT' date,
  'X' 'SAPMF05A' '0331',
  ' ' 'BDC_CURSOR' 'BSEG-XREF3',
  ' ' 'BDC_OKCODE' '=BU',
  ' ' 'BSEG-XREF3' wa_itab1-zuonr.

  CALL TRANSACTION 'F-21' USING i_bdc MODE va_mode UPDATE 'S'
               MESSAGES INTO messtab.
  PERFORM error.

ENDFORM.                    " partial_payment_resid
*&---------------------------------------------------------------------*
*&      Form  write_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_error.
  DESCRIBE TABLE i_log_error LINES v_line_size.
  IF v_line_size > 0.
    LOOP AT i_log_error INTO wa_log_error.
      FORMAT COLOR 2.
      WRITE: / wa_log_error-bukrs, sy-vline,
               wa_log_error-gjahr,  sy-vline,
               wa_log_error-belnr,  sy-vline.
      NEW-LINE.
      FORMAT COLOR 6. FORMAT COLOR OFF.
      WRITE:AT 10 ' Error Log : ' INTENSIFIED OFF  COLOR 6,
              wa_log_error-msg INTENSIFIED ON   COLOR 6.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " write_error
*&---------------------------------------------------------------------*
*&      Form  cek_blart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_blart.
  CLEAR: doctype, shkzg.
  SELECT SINGLE blart shkzg INTO (doctype, shkzg) FROM bsid
  WHERE bukrs EQ i_itab2-bukrs AND kunnr EQ i_itab2-kunnr
  AND gjahr EQ i_itab2-gjahr AND belnr EQ i_itab2-vbeln
***** tambahan validasi untuk dapatkan blart
  AND zuonr EQ i_itab2-zuonr.

ENDFORM.                    " cek_blart
*&---------------------------------------------------------------------*
*&      Form  cek_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_lock.
*{   REPLACE        P01K910757                                        1
*\  CALL FUNCTION 'ENQUEUE_E0001'
*\      EXPORTING
*\         bukrs  = pa_bukrs
*\         vkbur = pa_vkbur
*\         bbeln = pa_bbeln
*\*       GJAHR = PA_GJAHR
*\      EXCEPTIONS
*\          foreign_lock   = 4
*\          system_failure = 8.
*\  IF sy-subrc EQ 4.
*\    MESSAGE a000(26) WITH text-041.
*\  ENDIF.
  "Start SOH: Shell Remediation Adjustment 20240325 KRS
  CALL FUNCTION 'ENQUEUE_EZFBIH'
    EXPORTING
      bukrs          = pa_bukrs
      vkbur          = pa_vkbur
      bbeln          = pa_bbeln
*     GJAHR          = PA_GJAHR
    EXCEPTIONS
      foreign_lock   = 4
      system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(26) WITH TEXT-041.
  ENDIF.
  "End SOH: Shell Remediation Adjustment 20240325 KRS
*}   REPLACE

ENDFORM.                    " cek_lock
*&---------------------------------------------------------------------*
*&      Form  release_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock.
*{   REPLACE        P01K910757                                        1
*\  CALL FUNCTION 'DEQUEUE_E0001'
*\    EXPORTING
*\      bukrs = pa_bukrs
*\      vkbur = pa_vkbur
*\      bbeln = pa_bbeln.
*\*       GJAHR = PA_GJAHR.
  "Start SOH: Shell Remediation Adjustment 20240325 KRS
  CALL FUNCTION 'DEQUEUE_EZFBIH'
    EXPORTING
      bukrs = pa_bukrs
      vkbur = pa_vkbur
      bbeln = pa_bbeln.
*       GJAHR = PA_GJAHR.
  "End SOH: Shell Remediation Adjustment 20240325 KRS
*}   REPLACE

ENDFORM.                    " release_lock

*&---------------------------------------------------------------------*
*&      Form  post2_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post2_new .
  DATA: ld_flag      TYPE i,
        ld_poskey(2),
        ld_total     LIKE bseg-dmbtr.

  DATA : lv_cash  TYPE bseg-dmbtr,
         lv_trans TYPE bseg-dmbtr.

* Post Cash Payment & CN Payment Cash
  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.ld_total = 0.lv_cash = 0.
  LOOP AT i_itab1 INTO wa_itab1.
    IF wa_itab1-pcash > 0 OR
      wa_itab1-amtcar > 0.
      ld_poskey  = '15'.
      ld_flag    = 1.
      totcash = totcash + wa_itab1-pcash + wa_itab1-resid +
                wa_itab1-amtcar.
      ld_total = ld_total + wa_itab1-pcash + wa_itab1-resid +
                 wa_itab1-amtcar.
    ELSEIF wa_itab1-pcash < 0 OR
           wa_itab1-amtcar < 0.
      ld_poskey  = '05'.
      ld_flag    = 2.
      ld_total = ld_total + wa_itab1-pcash + wa_itab1-amtcar.
      wa_itab1-pcash = wa_itab1-pcash * -1.
      wa_itab1-amtcar = wa_itab1-amtcar * -1.
      totcash = totcash + wa_itab1-pcash + wa_itab1-amtcar.
    ELSEIF wa_itab1-pcnot <> 0.
      ld_poskey  = '05'.
      ld_flag    = 3.
      totcash = totcash + wa_itab1-pcash + wa_itab1-resid.
      wa_itab1-pcash = wa_itab1-pcnot * -1.
      ld_total = ld_total + wa_itab1-pcnot + wa_itab1-resid.
    ENDIF.

    IF ld_flag IS NOT INITIAL.
      lv_cash = wa_itab1-pcash + wa_itab1-amtcar.
      WRITE lv_cash TO cash  CURRENCY 'IDR' .
      PERFORM init.
      IF radio1 = 'X'.
        monat = budatc+4(2).
        CONCATENATE budatc+6(2) budatc+4(2)
        budatc+0(4) INTO date.
      ELSE.
        monat = budat+4(2).
        CONCATENATE budat+6(2) budat+4(2)
        budat+0(4) INTO date.
      ENDIF.

      poskey = ld_poskey.
      IF va_nou = 0.
        CLEAR: va_xblnr.
        va_xblnr = wa_itab1-xblnr.
        PERFORM post_header.
      ENDIF.
      IF va_nou NE 0.
        PERFORM poskey.
      ENDIF.

      CASE ld_flag.
        WHEN 1.
          IF wa_itab1-resid <> 0.
            WRITE wa_itab1-resid TO cash  CURRENCY 'IDR' .
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            PERFORM detail_resid.
            vbeln = wa_itab1-vbeln.
            CLEAR wa_itab1.
            t_resid-vbeln = vbeln.
            APPEND t_resid.
            LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
              PERFORM poskey.
              lv_cash = wa_itab1-pcash + wa_itab1-amtcar.
              WRITE lv_cash TO cash  CURRENCY 'IDR' .
              PERFORM init.
              IF radio1 = 'X'.
                monat = budatc+4(2).
                CONCATENATE budatc+6(2) budatc+4(2)
                budatc+0(4) INTO date.
              ELSE.
                monat = budat+4(2).
                CONCATENATE budat+6(2) budat+4(2)
                budat+0(4) INTO date.
              ENDIF.
              IF wa_itab1-kunnr(2) = 'SL'.
                PERFORM onetime_cust.
              ENDIF.
              PERFORM post_detail.
            ENDLOOP.
          ENDIF.

          IF wa_itab1-resid = 0.
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            PERFORM post_detail.
          ENDIF.
          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 2.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          IF wa_itab1-resid <> 0.
            IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
              zuonr = wa_itab1-zuonr.
            ELSE.
              CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            ENDIF.
            PERFORM detail_resid.
          ELSE.
            PERFORM post_detail.
          ENDIF.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 3.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          PERFORM post_detail.

          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.
      ENDCASE.
    ENDIF.
    CLEAR: wa_itab1, ld_flag, ld_poskey.
  ENDLOOP.

  IF v_line_size = 1.
    IF ld_total < 0.
      poskey = '50'.
    ELSE.
      poskey = '40'.
    ENDIF.
    wa_itab1-kunnr = hkont.
    PERFORM poskey.
    ld_total  = abs( ld_total ).
    WRITE ld_total TO cash  CURRENCY 'IDR' .
    PERFORM save USING 'CASH'.
  ENDIF.

** Post Check Payment
  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot EQ 0.
    IF wa_itab1-pchek > 0.
      txt = 'Chek No. '.
      SELECT * FROM zfbicheck
      WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
            AND gjahr EQ wa_itab1-gjahr AND belnr EQ wa_itab1-vbeln
            AND bbeln EQ wa_itab1-bbeln.
        v_cekno = zfbicheck-cekno.
        CONCATENATE txt v_cekno INTO txt SEPARATED BY space.
      ENDSELECT.
    ELSE.
      txt = 'Tunai / Transfer'.
    ENDIF.
    PERFORM update_flag ON COMMIT.
    PERFORM open_for-payment.
*    PERFORM update_flag ON COMMIT.
  ENDLOOP.

* Post Transfer Payment & CN Payment Transfer
  CLEAR: ld_flag, ld_poskey.
  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.ld_total = 0.lv_trans = 0.
  LOOP AT i_itab1 INTO wa_itab1.
    IF wa_itab1-ptrans > 0  OR
      wa_itab1-amttar > 0.
      ld_flag  = 1.
      ld_poskey  = '15'.
      ld_total  = ld_total + wa_itab1-ptrans + wa_itab1-residt +
                  wa_itab1-amttar.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt +
                wa_itab1-amttar.
      lv_trans  = wa_itab1-ptrans + wa_itab1-amttar.
      WRITE lv_trans TO cash  CURRENCY 'IDR' .
    ELSEIF wa_itab1-ptrans = 0 AND wa_itab1-residt NE 0.
      ld_flag  = 2.
      ld_poskey  = '15'.
      ld_total  = ld_total + wa_itab1-ptrans + wa_itab1-residt.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
    ELSEIF wa_itab1-ptrans < 0 OR wa_itab1-amttar < 0.
      ld_flag  = 3.
      ld_poskey  = '05'.
      ld_total  = ld_total + wa_itab1-ptrans + wa_itab1-amttar.
      wa_itab1-ptrans = wa_itab1-ptrans * -1.
      wa_itab1-amttar = wa_itab1-amttar * -1.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-amttar.
      lv_trans = wa_itab1-ptrans + wa_itab1-amttar.
      WRITE lv_trans TO cash  CURRENCY 'IDR' .
    ELSEIF wa_itab1-ptnot <> 0.
      ld_flag  = 4.
      ld_poskey  = '05'.
      ld_total  = ld_total + wa_itab1-ptnot + wa_itab1-residt.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
      wa_itab1-pcash = wa_itab1-ptnot * -1.
      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
    ENDIF.

    IF ld_flag  IS NOT INITIAL.
      PERFORM init.
      IF radio1 = 'X'.
        monat = budattc+4(2).
        CONCATENATE budattc+6(2) budattc+4(2)
        budattc+0(4) INTO date.
      ELSE.
        monat = budatt+4(2).
        CONCATENATE budatt+6(2) budatt+4(2)
        budatt+0(4) INTO date.
      ENDIF.

      poskey = ld_poskey  .
      IF va_nou = 0.
        CLEAR: va_xblnr.
        va_xblnr = wa_itab1-xblnrt.
        PERFORM post_header.
      ENDIF.
      IF va_nou NE 0.
        PERFORM poskey.
      ENDIF.

      CASE ld_flag.
        WHEN 1.
          IF wa_itab1-residt <> 0.
            WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            PERFORM detail_resid.
            vbeln = wa_itab1-vbeln.
            CLEAR wa_itab1.
            LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
              PERFORM poskey.
              lv_trans = wa_itab1-ptrans + wa_itab1-amttar.
              WRITE lv_trans TO cash  CURRENCY 'IDR' .
              PERFORM init.
              IF radio1 = 'X'.
                monat = budattc+4(2).
                CONCATENATE budattc+6(2) budattc+4(2)
                budattc+0(4) INTO date.
              ELSE.
                monat = budatt+4(2).
                CONCATENATE budatt+6(2) budatt+4(2)
                budatt+0(4) INTO date.
              ENDIF.
              IF wa_itab1-kunnr(2) = 'SL'.
                PERFORM onetime_cust.
              ENDIF.
              PERFORM post_detail.
            ENDLOOP.
          ENDIF.
          IF wa_itab1-residt = 0.
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            PERFORM post_detail.
          ENDIF.
          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 2.
          IF wa_itab1-residt <> 0.
            WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            PERFORM detail_resid.
            vbeln = wa_itab1-vbeln.
            CLEAR wa_itab1.
          ENDIF.
          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 3.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          IF wa_itab1-resid <> 0.
            IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
              zuonr = wa_itab1-zuonr.
            ELSE.
              CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            ENDIF.
            PERFORM detail_resid.
          ELSE.
            PERFORM post_detail.
          ENDIF.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 4.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          PERFORM post_detail.
          totcn   = totcn + wa_itab1-ptnot.
          va_nou = va_nou + 1.
          v_line_size = 1.
      ENDCASE.
    ENDIF.
    CLEAR: wa_itab1, ld_poskey, ld_flag.
  ENDLOOP.

  IF v_line_size = 1.
    IF ld_total < 0.
      poskey = '50'.
    ELSE.
      poskey = '40'.
    ENDIF.
    wa_itab1-kunnr = hkontt.
    PERFORM poskey.
    ld_total  = abs( ld_total ).
    WRITE ld_total TO cash  CURRENCY 'IDR' .
    PERFORM save USING 'TRANS'.
  ENDIF.

  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot NE 0.
    PERFORM update_flag ON COMMIT.
    PERFORM open_for-payment.
*    PERFORM update_flag ON COMMIT.
  ENDLOOP.
ENDFORM.                                                    " post2_new

*&---------------------------------------------------------------------*
*&      Form  post2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*****FORM post2.
******* Post Cash Payment
*****  totcash = 0.totcn = 0.va_nou = 0.
*****  CLEAR v_line_size.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-pcash > 0.
*****      totcash = totcash + wa_itab1-pcash + wa_itab1-resid.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '15'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnr.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****
*****      IF wa_itab1-resid <> 0.
*****        WRITE wa_itab1-resid TO cash  CURRENCY 'IDR' .
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****        PERFORM detail_resid.
*****        vbeln = wa_itab1-vbeln.
*****        CLEAR wa_itab1.
******        va_resid = 'X'.
*****        t_resid-vbeln = vbeln.
*****        APPEND t_resid.
*****        LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
*****          PERFORM poskey.
*****          WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****          PERFORM init.
*****          IF radio1 = 'X'.
*****            monat = budatc+4(2).
*****            CONCATENATE budatc+6(2) budatc+4(2)
*****            budatc+0(4) INTO date.
*****          ELSE.
*****            monat = budat+4(2).
*****            CONCATENATE budat+6(2) budat+4(2)
*****            budat+0(4) INTO date.
*****          ENDIF.
*****          IF wa_itab1-kunnr(2) = 'SL'.
*****            PERFORM onetime_cust.
*****          ENDIF.
*****          PERFORM post_detail.
*****        ENDLOOP.
*****      ENDIF.
*****      IF wa_itab1-resid = 0.
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        PERFORM post_detail.
*****      ENDIF.
*****      totcn   = totcn + wa_itab1-pcnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '40'.
*****    wa_itab1-kunnr = hkont.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-pcash < 0.
*****      wa_itab1-pcash = wa_itab1-pcash * -1.
*****      totcash = totcash + wa_itab1-pcash.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnr.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
*****        zuonr = wa_itab1-zuonr.
*****      ELSE.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****      ENDIF.
*****      PERFORM detail_resid.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkont.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
******* Post Transfer Payment
*****  totcash = 0.totcn = 0.va_nou = 0.
*****  CLEAR v_line_size.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-ptrans > 0.
*****      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
*****      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budattc+4(2).
*****        CONCATENATE budattc+6(2) budattc+4(2)
*****        budattc+0(4) INTO date.
*****      ELSE.
*****        monat = budatt+4(2).
*****        CONCATENATE budatt+6(2) budatt+4(2)
*****        budatt+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '15'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnrt.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****
*****      IF wa_itab1-residt <> 0.
*****        WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****        PERFORM detail_resid.
*****        vbeln = wa_itab1-vbeln.
*****        CLEAR wa_itab1.
*****        LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
*****          PERFORM poskey.
*****          WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****          PERFORM init.
*****          IF radio1 = 'X'.
*****            monat = budattc+4(2).
*****            CONCATENATE budattc+6(2) budattc+4(2)
*****            budattc+0(4) INTO date.
*****          ELSE.
*****            monat = budatt+4(2).
*****            CONCATENATE budatt+6(2) budatt+4(2)
*****            budatt+0(4) INTO date.
*****          ENDIF.
*****          IF wa_itab1-kunnr(2) = 'SL'.
*****            PERFORM onetime_cust.
*****          ENDIF.
*****          PERFORM post_detail.
*****        ENDLOOP.
*****      ENDIF.
*****      IF wa_itab1-residt = 0.
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        PERFORM post_detail.
*****      ENDIF.
*****      totcn   = totcn + wa_itab1-pcnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ELSE.
*****      IF wa_itab1-ptrans = 0 AND wa_itab1-residt NE 0.
*****        totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
*****        WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****        PERFORM init.
*****        IF radio1 = 'X'.
*****          monat = budattc+4(2).
*****          CONCATENATE budattc+6(2) budattc+4(2)
*****          budattc+0(4) INTO date.
*****        ELSE.
*****          monat = budatt+4(2).
*****          CONCATENATE budatt+6(2) budatt+4(2)
*****          budatt+0(4) INTO date.
*****        ENDIF.
*****
*****        poskey = '15'.
*****        IF va_nou = 0.
*****          CLEAR: va_xblnr.
*****          va_xblnr = wa_itab1-xblnrt.
*****          PERFORM post_header.
*****        ENDIF.
*****        IF va_nou NE 0.
*****          PERFORM poskey.
*****        ENDIF.
*****
*****        IF wa_itab1-residt <> 0.
*****          WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
*****          IF wa_itab1-kunnr(2) = 'SL'.
*****            PERFORM onetime_cust.
*****          ENDIF.
*****          CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****          PERFORM detail_resid.
*****          vbeln = wa_itab1-vbeln.
*****          CLEAR wa_itab1.
******          LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
******            PERFORM poskey.
******            WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
******            PERFORM init.
******            IF radio1 = 'X'.
******              monat = budattc+4(2).
******              CONCATENATE budattc+6(2) budattc+4(2)
******              budattc+0(4) INTO date.
******            ELSE.
******              monat = budatt+4(2).
******              CONCATENATE budatt+6(2) budatt+4(2)
******              budatt+0(4) INTO date.
******            ENDIF.
******            IF wa_itab1-kunnr(2) = 'SL'.
******              PERFORM onetime_cust.
******            ENDIF.
******            PERFORM post_detail.
******          ENDLOOP.
*****        ENDIF.
*****        totcn   = totcn + wa_itab1-pcnot.
*****        va_nou = va_nou + 1.
*****        v_line_size = 1.
*****      ENDIF.
*****
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '40'.
*****    wa_itab1-kunnr = hkontt.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-ptrans < 0.
*****      wa_itab1-ptrans = wa_itab1-ptrans * -1.
*****      totcash = totcash + wa_itab1-ptrans.
*****      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budattc+4(2).
*****        CONCATENATE budattc+6(2) budattc+4(2)
*****        budattc+0(4) INTO date.
*****      ELSE.
*****        monat = budatt+4(2).
*****        CONCATENATE budatt+6(2) budatt+4(2)
*****        budatt+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnrt.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
*****        zuonr = wa_itab1-zuonr.
*****      ELSE.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****      ENDIF.
*****      PERFORM detail_resid.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkontt.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
******* Post Check Payment
*****  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot EQ 0.
*****    IF wa_itab1-pchek > 0.
*****      txt = 'Chek No. '.
*****      SELECT * FROM zfbicheck
*****      WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
*****            AND gjahr EQ wa_itab1-gjahr AND belnr EQ wa_itab1-vbeln
*****            AND bbeln EQ wa_itab1-bbeln.
*****        v_cekno = zfbicheck-cekno.
*****        CONCATENATE txt v_cekno INTO txt SEPARATED BY space.
*****      ENDSELECT.
*****    ELSE.
*****      txt = 'Tunai / Transfer'.
*****    ENDIF.
*****
*****    PERFORM update_flag ON COMMIT.
*****    PERFORM open_for-payment.
******    PERFORM update_flag ON COMMIT.
*****  ENDLOOP.
*****
******* Post CN Payment Cash
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1. "where pcnot <> 0.
*****    IF wa_itab1-pcnot <> 0.
*****      totcash = totcash + wa_itab1-pcash + wa_itab1-resid.
*****      wa_itab1-pcash = wa_itab1-pcnot * -1.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnr.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      PERFORM post_detail.
*****
*****      totcn   = totcn + wa_itab1-pcnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkont.
*****    PERFORM poskey.
*****    totcn = totcn * -1.
*****    WRITE totcn TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
****** Post CN Payment Transfer
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1. "where ptnot <> 0.
*****    IF wa_itab1-ptnot <> 0.
*****      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
*****      wa_itab1-pcash = wa_itab1-ptnot * -1.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnrt.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      PERFORM post_detail.
*****
*****      totcn   = totcn + wa_itab1-ptnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkontt.
*****    PERFORM poskey.
*****    totcn = totcn * -1.
*****    WRITE totcn TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
*****  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot NE 0.
*****    PERFORM update_flag ON COMMIT.
*****    PERFORM open_for-payment.
******    PERFORM update_flag ON COMMIT.
*****  ENDLOOP.
*****ENDFORM.                                                    " post2

*&---------------------------------------------------------------------*
*&      Form  post21_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post21_new .
  DATA: ld_flag      TYPE i,
        ld_poskey(2),
        ld_total     LIKE bseg-dmbtr.

  DATA : lv_cash  TYPE bseg-dmbtr,
         lv_trans TYPE bseg-dmbtr.

* Post Cash Payment & CN Payment Cash
  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.ld_total = 0.lv_cash = 0.
  LOOP AT i_itab1 INTO wa_itab1.
    IF wa_itab1-pcash > 0 OR
      wa_itab1-amtcar > 0.
      ld_poskey  = '15'.
      ld_flag    = 1.
      totcash = totcash + wa_itab1-pcash + wa_itab1-resid +
                wa_itab1-amtcar.
      ld_total = ld_total + wa_itab1-pcash + wa_itab1-resid +
                 wa_itab1-amtcar.
    ELSEIF wa_itab1-pcash < 0 OR
           wa_itab1-amtcar < 0.
      ld_poskey  = '05'.
      ld_flag    = 2.
      ld_total = ld_total + wa_itab1-pcash + wa_itab1-amtcar.
      wa_itab1-pcash = wa_itab1-pcash * -1.
      wa_itab1-amtcar = wa_itab1-amtcar * -1.
      totcash = totcash + wa_itab1-pcash + wa_itab1-amtcar.
    ELSEIF wa_itab1-pcnot <> 0.
      ld_poskey  = '05'.
      ld_flag    = 3.
      totcash = totcash + wa_itab1-pcash + wa_itab1-resid.
      wa_itab1-pcash = wa_itab1-pcnot * -1.
      ld_total = ld_total + wa_itab1-pcnot + wa_itab1-resid.
    ENDIF.

    IF ld_flag IS NOT INITIAL.
      lv_cash = wa_itab1-pcash + wa_itab1-amtcar.
      WRITE lv_cash TO cash  CURRENCY 'IDR' .
*      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
      PERFORM init.
      IF radio1 = 'X'.
        monat = budatc+4(2).
        CONCATENATE budatc+6(2) budatc+4(2)
        budatc+0(4) INTO date.
      ELSE.
        monat = budat+4(2).
        CONCATENATE budat+6(2) budat+4(2)
        budat+0(4) INTO date.
      ENDIF.

      poskey = ld_poskey.
      IF va_nou = 0.
        CLEAR: va_xblnr.
        va_xblnr = wa_itab1-xblnr.
        PERFORM post_header.
      ENDIF.
      IF va_nou NE 0.
        PERFORM poskey.
      ENDIF.

      CASE ld_flag.
        WHEN 1.
          IF wa_itab1-resid <> 0.
            WRITE wa_itab1-resid TO cash  CURRENCY 'IDR' .
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            PERFORM detail_resid.
            vbeln = wa_itab1-vbeln.
            CLEAR wa_itab1.
            t_resid-vbeln = vbeln.
            APPEND t_resid.
            LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
              PERFORM poskey.
              lv_cash = wa_itab1-pcash + wa_itab1-amtcar.
              WRITE lv_cash TO cash  CURRENCY 'IDR' .
*              WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
              PERFORM init.
              IF radio1 = 'X'.
                monat = budatc+4(2).
                CONCATENATE budatc+6(2) budatc+4(2)
                budatc+0(4) INTO date.
              ELSE.
                monat = budat+4(2).
                CONCATENATE budat+6(2) budat+4(2)
                budat+0(4) INTO date.
              ENDIF.
              IF wa_itab1-kunnr(2) = 'SL'.
                PERFORM onetime_cust.
              ENDIF.
              PERFORM post_detail.
            ENDLOOP.
          ENDIF.

          IF wa_itab1-resid = 0.
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            PERFORM post_detail.
          ENDIF.
          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 2.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          IF wa_itab1-resid <> 0.
            IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
              zuonr = wa_itab1-zuonr.
            ELSE.
              CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            ENDIF.
            PERFORM detail_resid.
          ELSE.
            PERFORM post_detail.
          ENDIF.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 3.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          PERFORM post_detail.

          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.
      ENDCASE.
    ENDIF.
    CLEAR: wa_itab1, ld_flag, ld_poskey.
  ENDLOOP.

  IF v_line_size = 1.
    IF ld_total < 0.
      poskey = '50'.
    ELSE.
      poskey = '40'.
    ENDIF.
    wa_itab1-kunnr = hkontc.
    PERFORM poskey.
    ld_total  = abs( ld_total ).
    WRITE ld_total TO cash  CURRENCY 'IDR' .
    PERFORM save USING 'CASH'.
  ENDIF.

** Post Check Payment
  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot EQ 0.
    IF wa_itab1-pchek > 0.
      txt = 'Chek No. '.
      SELECT * FROM zfbicheck
      WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
            AND gjahr EQ wa_itab1-gjahr AND belnr EQ wa_itab1-vbeln
            AND bbeln EQ wa_itab1-bbeln.
        v_cekno = zfbicheck-cekno.
        CONCATENATE txt v_cekno INTO txt SEPARATED BY space.
      ENDSELECT.
    ELSE.
      txt = 'Tunai / Transfer'.
    ENDIF.

    PERFORM update_flag ON COMMIT.
    PERFORM open_for-payment.
*    PERFORM update_flag ON COMMIT.
  ENDLOOP.

* Post Transfer Payment & CN Payment Transfer
  CLEAR: ld_flag, ld_poskey.
  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.ld_total = 0.lv_trans = 0.
  LOOP AT i_itab1 INTO wa_itab1.
    IF wa_itab1-ptrans > 0  OR
      wa_itab1-amttar > 0.
      ld_flag  = 1.
      ld_poskey  = '15'.
      ld_total  = ld_total + wa_itab1-ptrans + wa_itab1-residt +
                  wa_itab1-amttar.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt +
                wa_itab1-amttar.
      lv_trans  = wa_itab1-ptrans + wa_itab1-amttar.
      WRITE lv_trans TO cash  CURRENCY 'IDR' .
*      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
    ELSEIF wa_itab1-ptrans = 0 AND wa_itab1-residt NE 0.
      ld_flag  = 2.
      ld_poskey  = '15'.
      ld_total  = ld_total + wa_itab1-ptrans + wa_itab1-residt.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
    ELSEIF wa_itab1-ptrans < 0 OR wa_itab1-amttar < 0.
      ld_flag  = 3.
      ld_poskey  = '05'.
      ld_total  = ld_total + wa_itab1-ptrans + wa_itab1-amttar.
      wa_itab1-ptrans = wa_itab1-ptrans * -1.
      wa_itab1-amttar = wa_itab1-amttar * -1.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-amttar.
      lv_trans = wa_itab1-ptrans + wa_itab1-amttar.
      WRITE lv_trans TO cash  CURRENCY 'IDR' .
*      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
    ELSEIF wa_itab1-ptnot <> 0.
      ld_flag  = 4.
      ld_poskey  = '05'.
      ld_total  = ld_total + wa_itab1-ptnot + wa_itab1-residt.
      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
      wa_itab1-pcash = wa_itab1-ptnot * -1.
      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
    ENDIF.

    IF ld_flag  IS NOT INITIAL.
      PERFORM init.
      IF radio1 = 'X'.
        monat = budattc+4(2).
        CONCATENATE budattc+6(2) budattc+4(2)
        budattc+0(4) INTO date.
      ELSE.
        monat = budatt+4(2).
        CONCATENATE budatt+6(2) budatt+4(2)
        budatt+0(4) INTO date.
      ENDIF.

      poskey = ld_poskey  .
      IF va_nou = 0.
        CLEAR: va_xblnr.
        va_xblnr = wa_itab1-xblnrt.
        PERFORM post_header.
      ENDIF.
      IF va_nou NE 0.
        PERFORM poskey.
      ENDIF.

      CASE ld_flag.
        WHEN 1.
          IF wa_itab1-residt <> 0.
            WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            PERFORM detail_resid.
            vbeln = wa_itab1-vbeln.
            CLEAR wa_itab1.
            LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
              PERFORM poskey.
              lv_trans = wa_itab1-ptrans + wa_itab1-amttar.
              WRITE lv_trans TO cash  CURRENCY 'IDR' .
*              WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
              PERFORM init.
              IF radio1 = 'X'.
                monat = budattc+4(2).
                CONCATENATE budattc+6(2) budattc+4(2)
                budattc+0(4) INTO date.
              ELSE.
                monat = budatt+4(2).
                CONCATENATE budatt+6(2) budatt+4(2)
                budatt+0(4) INTO date.
              ENDIF.
              IF wa_itab1-kunnr(2) = 'SL'.
                PERFORM onetime_cust.
              ENDIF.
              PERFORM post_detail.
            ENDLOOP.
          ENDIF.
          IF wa_itab1-residt = 0.
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            PERFORM post_detail.
          ENDIF.
          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 2.
          IF wa_itab1-residt <> 0.
            WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
            IF wa_itab1-kunnr(2) = 'SL'.
              PERFORM onetime_cust.
            ENDIF.
            CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            PERFORM detail_resid.
            vbeln = wa_itab1-vbeln.
            CLEAR wa_itab1.
          ENDIF.
          totcn   = totcn + wa_itab1-pcnot.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 3.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          IF wa_itab1-resid <> 0.
            IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
              zuonr = wa_itab1-zuonr.
            ELSE.
              CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
            ENDIF.
            PERFORM detail_resid.
          ELSE.
            PERFORM post_detail.
          ENDIF.
          va_nou = va_nou + 1.
          v_line_size = 1.

        WHEN 4.
          IF wa_itab1-kunnr(2) = 'SL'.
            PERFORM onetime_cust.
          ENDIF.
          PERFORM post_detail.
          totcn   = totcn + wa_itab1-ptnot.
          va_nou = va_nou + 1.
          v_line_size = 1.
      ENDCASE.
    ENDIF.
    CLEAR: wa_itab1, ld_poskey, ld_flag.
  ENDLOOP.

  IF v_line_size = 1.
    IF ld_total < 0.
      poskey = '50'.
    ELSE.
      poskey = '40'.
    ENDIF.
    wa_itab1-kunnr = hkonttc.
    PERFORM poskey.
    ld_total  = abs( ld_total ).
    WRITE ld_total TO cash  CURRENCY 'IDR' .
    PERFORM save USING 'TRANS'.
  ENDIF.

  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot NE 0.
    PERFORM update_flag ON COMMIT.
    PERFORM open_for-payment.
*    PERFORM update_flag ON COMMIT.
  ENDLOOP.
ENDFORM.                    " post21_new

*&---------------------------------------------------------------------*
*&      Form  post21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*****FORM post21.
******* Post Cash Payment
*****  totcash = 0.totcn = 0.va_nou = 0.
*****  CLEAR v_line_size.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-pcash > 0.
*****      totcash = totcash + wa_itab1-pcash + wa_itab1-resid.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '15'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnr.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****
*****      IF wa_itab1-resid <> 0.
*****        WRITE wa_itab1-resid TO cash  CURRENCY 'IDR' .
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****        PERFORM detail_resid.
*****        vbeln = wa_itab1-vbeln.
*****        CLEAR wa_itab1.
******        va_resid = 'X'.
*****        t_resid-vbeln = vbeln.
*****        APPEND t_resid.
*****        LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
*****          PERFORM poskey.
*****          WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****          PERFORM init.
*****          IF radio1 = 'X'.
*****            monat = budatc+4(2).
*****            CONCATENATE budatc+6(2) budatc+4(2)
*****            budatc+0(4) INTO date.
*****          ELSE.
*****            monat = budat+4(2).
*****            CONCATENATE budat+6(2) budat+4(2)
*****            budat+0(4) INTO date.
*****          ENDIF.
*****          IF wa_itab1-kunnr(2) = 'SL'.
*****            PERFORM onetime_cust.
*****          ENDIF.
*****          PERFORM post_detail.
*****        ENDLOOP.
*****      ENDIF.
*****      IF wa_itab1-resid = 0.
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        PERFORM post_detail.
*****      ENDIF.
*****      totcn   = totcn + wa_itab1-pcnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '40'.
*****    wa_itab1-kunnr = hkontc.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-pcash < 0.
*****      wa_itab1-pcash = wa_itab1-pcash * -1.
*****      totcash = totcash + wa_itab1-pcash.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnr.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
*****        zuonr = wa_itab1-zuonr.
*****      ELSE.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****      ENDIF.
*****      PERFORM detail_resid.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkontc.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
******* Post Transfer Payment
*****  totcash = 0.totcn = 0.va_nou = 0.
*****  CLEAR v_line_size.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-ptrans > 0.
*****      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
*****      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budattc+4(2).
*****        CONCATENATE budattc+6(2) budattc+4(2)
*****        budattc+0(4) INTO date.
*****      ELSE.
*****        monat = budatt+4(2).
*****        CONCATENATE budatt+6(2) budatt+4(2)
*****        budatt+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '15'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnrt.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****
*****      IF wa_itab1-residt <> 0.
*****        WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****        PERFORM detail_resid.
*****        vbeln = wa_itab1-vbeln.
*****        CLEAR wa_itab1.
*****        LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
*****          PERFORM poskey.
*****          WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****          PERFORM init.
*****          IF radio1 = 'X'.
*****            monat = budattc+4(2).
*****            CONCATENATE budattc+6(2) budattc+4(2)
*****            budattc+0(4) INTO date.
*****          ELSE.
*****            monat = budatt+4(2).
*****            CONCATENATE budatt+6(2) budatt+4(2)
*****            budatt+0(4) INTO date.
*****          ENDIF.
*****          IF wa_itab1-kunnr(2) = 'SL'.
*****            PERFORM onetime_cust.
*****          ENDIF.
*****          PERFORM post_detail.
*****        ENDLOOP.
*****      ENDIF.
*****      IF wa_itab1-residt = 0.
*****        IF wa_itab1-kunnr(2) = 'SL'.
*****          PERFORM onetime_cust.
*****        ENDIF.
*****        PERFORM post_detail.
*****      ENDIF.
*****      totcn   = totcn + wa_itab1-pcnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ELSE.
*****      IF wa_itab1-ptrans = 0 AND wa_itab1-residt NE 0.
*****        totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
*****        WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****        PERFORM init.
*****        IF radio1 = 'X'.
*****          monat = budattc+4(2).
*****          CONCATENATE budattc+6(2) budattc+4(2)
*****          budattc+0(4) INTO date.
*****        ELSE.
*****          monat = budatt+4(2).
*****          CONCATENATE budatt+6(2) budatt+4(2)
*****          budatt+0(4) INTO date.
*****        ENDIF.
*****
*****        poskey = '15'.
*****        IF va_nou = 0.
*****          CLEAR: va_xblnr.
*****          va_xblnr = wa_itab1-xblnrt.
*****          PERFORM post_header.
*****        ENDIF.
*****        IF va_nou NE 0.
*****          PERFORM poskey.
*****        ENDIF.
*****
*****        IF wa_itab1-residt <> 0.
*****          WRITE wa_itab1-residt TO cash  CURRENCY 'IDR' .
*****          IF wa_itab1-kunnr(2) = 'SL'.
*****            PERFORM onetime_cust.
*****          ENDIF.
*****          CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****          PERFORM detail_resid.
*****          vbeln = wa_itab1-vbeln.
*****          CLEAR wa_itab1.
******          LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln EQ vbeln.
******            PERFORM poskey.
******            WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
******            PERFORM init.
******            IF radio1 = 'X'.
******              monat = budattc+4(2).
******              CONCATENATE budattc+6(2) budattc+4(2)
******              budattc+0(4) INTO date.
******            ELSE.
******              monat = budatt+4(2).
******              CONCATENATE budatt+6(2) budatt+4(2)
******              budatt+0(4) INTO date.
******            ENDIF.
******            IF wa_itab1-kunnr(2) = 'SL'.
******              PERFORM onetime_cust.
******            ENDIF.
******            PERFORM post_detail.
******          ENDLOOP.
*****        ENDIF.
*****        totcn   = totcn + wa_itab1-pcnot.
*****        va_nou = va_nou + 1.
*****        v_line_size = 1.
*****      ENDIF.
*****
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '40'.
*****    wa_itab1-kunnr = hkonttc.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1.
*****    IF wa_itab1-ptrans < 0.
*****      wa_itab1-ptrans = wa_itab1-ptrans * -1.
*****      totcash = totcash + wa_itab1-ptrans.
*****      WRITE wa_itab1-ptrans TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budattc+4(2).
*****        CONCATENATE budattc+6(2) budattc+4(2)
*****        budattc+0(4) INTO date.
*****      ELSE.
*****        monat = budatt+4(2).
*****        CONCATENATE budatt+6(2) budatt+4(2)
*****        budatt+0(4) INTO date.
*****      ENDIF.
*****
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnrt.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      IF wa_itab1-zuonr+9(1) EQ 'R' OR wa_itab1-zuonr+10(1) EQ 'R'.
*****        zuonr = wa_itab1-zuonr.
*****      ELSE.
*****        CONCATENATE wa_itab1-zuonr 'R' INTO zuonr.
*****      ENDIF.
*****      PERFORM detail_resid.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkonttc.
*****    PERFORM poskey.
*****    WRITE totcash TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
******* Post Check Payment
*****  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot EQ 0..
*****    IF wa_itab1-pchek > 0.
*****      txt = 'Chek No. '.
*****      SELECT * FROM zfbicheck
*****      WHERE bukrs EQ wa_itab1-bukrs AND vkbur EQ wa_itab1-vkbur
*****            AND gjahr EQ wa_itab1-gjahr AND belnr EQ wa_itab1-vbeln
*****            AND bbeln EQ wa_itab1-bbeln.
*****        v_cekno = zfbicheck-cekno.
*****        CONCATENATE txt v_cekno INTO txt SEPARATED BY space.
*****      ENDSELECT.
*****    ELSE.
*****      txt = 'Tunai / Transfer'.
*****    ENDIF.
*****
*****    PERFORM update_flag ON COMMIT.
*****    PERFORM open_for-payment.
******    PERFORM update_flag ON COMMIT.
*****  ENDLOOP.
*****
******* Post CN Payment
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1. "where pcnot <> 0.
*****    IF wa_itab1-pcnot <> 0.
*****      totcash = totcash + wa_itab1-pcash + wa_itab1-resid.
*****      wa_itab1-pcash = wa_itab1-pcnot * -1.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnr.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      PERFORM post_detail.
*****
*****      totcn   = totcn + wa_itab1-pcnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkontc.
*****    PERFORM poskey.
*****    totcn = totcn * -1.
*****    WRITE totcn TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
****** Post CN Payment Transfer
*****  totcash = 0.totcn = 0.va_nou = 0.v_line_size = 0.
*****  LOOP AT i_itab1 INTO wa_itab1. "where ptnot <> 0.
*****    IF wa_itab1-ptnot <> 0.
*****      totcash = totcash + wa_itab1-ptrans + wa_itab1-residt.
*****      wa_itab1-pcash = wa_itab1-ptnot * -1.
*****      WRITE wa_itab1-pcash TO cash  CURRENCY 'IDR' .
*****      PERFORM init.
*****      IF radio1 = 'X'.
*****        monat = budatc+4(2).
*****        CONCATENATE budatc+6(2) budatc+4(2)
*****        budatc+0(4) INTO date.
*****      ELSE.
*****        monat = budat+4(2).
*****        CONCATENATE budat+6(2) budat+4(2)
*****        budat+0(4) INTO date.
*****      ENDIF.
*****      poskey = '05'.
*****      IF va_nou = 0.
*****        CLEAR: va_xblnr.
*****        va_xblnr = wa_itab1-xblnrt.
*****        PERFORM post_header.
*****      ENDIF.
*****      IF va_nou NE 0.
*****        PERFORM poskey.
*****      ENDIF.
*****      IF wa_itab1-kunnr(2) = 'SL'.
*****        PERFORM onetime_cust.
*****      ENDIF.
*****      PERFORM post_detail.
*****
*****      totcn   = totcn + wa_itab1-ptnot.
*****      va_nou = va_nou + 1.
*****      v_line_size = 1.
*****    ENDIF.
*****    CLEAR wa_itab1.
*****  ENDLOOP.
*****
*****  IF v_line_size = 1.
*****    poskey = '50'.
*****    wa_itab1-kunnr = hkonttc.
*****    PERFORM poskey.
*****    totcn = totcn * -1.
*****    WRITE totcn TO cash  CURRENCY 'IDR' .
*****    PERFORM save.
*****  ENDIF.
*****
*****  LOOP AT i_itab1 INTO wa_itab1 WHERE pcnot NE 0.
*****    PERFORM update_flag ON COMMIT.
*****    PERFORM open_for-payment.
******    PERFORM update_flag ON COMMIT.
*****  ENDLOOP.
*****
*****ENDFORM.                                                    " post21
*&---------------------------------------------------------------------*
*&      Form  post_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_detail.
  PERFORM f_dynpro USING :
    'X' 'SAPMF05A'    '0301',          "Customer account item
    ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
    ' ' 'BDC_OKCODE'  '=ZK',
    ' ' 'BSEG-WRBTR'   cash,   "Amount in docu. currency
    ' ' 'BSEG-GSBER'   wa_itab1-gsber,   "Business Area
    ' ' 'BSEG-ZFBDT'   bldat,
    ' ' 'BSEG-ZLSPR'   'Z',
    ' ' 'BSEG-ZUONR'   wa_itab1-zuonr,   "Allocation number
    ' ' 'BSEG-SGTXT'   txt,   "Line item text
    'X' 'SAPMF05A' '0331',
    ' ' 'BDC_CURSOR' 'BSEG-XREF1',
    ' ' 'BDC_OKCODE'  '/14',
    ' ' 'BSEG-XREF1' wa_itab1-parvw,
    ' ' 'BSEG-XREF2' wa_itab1-slcod+4(6),
    ' ' 'BSEG-XREF3' wa_itab1-zuonr.

ENDFORM.                    " post_detail
*&---------------------------------------------------------------------*
*&      Form  post_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_header.
  CLEAR i_bdc.
  PERFORM f_dynpro USING:
      'X' 'SAPMF05A'    '0100',
      ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
      ' ' 'BDC_OKCODE'  '/00',
      ' ' 'BKPF-BLDAT'  bidat,    "Date of doc.
      ' ' 'BKPF-BUDAT'  date,    "Post date in doc.
*      ' ' 'BKPF-XBLNR'  wa_itab1-xblnr,    "Reference doc. number
      ' ' 'BKPF-XBLNR'  va_xblnr,    "Reference doc. number
      ' ' 'BKPF-BKTXT'  bktxt,    "Doc. header text
      ' ' 'BKPF-BLART'  'DZ',
      ' ' 'BKPF-BUKRS'  pa_bukrs,    "Company code
      ' ' 'BKPF-WAERS'  'IDR',    "Currency key
      ' ' 'FS006-DOCID' '*',
      ' ' 'RF05A-NEWBS' poskey  ,    "Posting key for next line item
      ' ' 'RF05A-NEWKO' wa_itab1-kunnr.    "Account for next line item

ENDFORM.                    " post_header
*&---------------------------------------------------------------------*
*&      Form  save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save USING fu_proc.
  PERFORM f_dynpro USING:
            'X' 'SAPMF05A'    '0300',
            ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
            ' ' 'BDC_OKCODE'  '/00',
            ' ' 'BSEG-WRBTR' cash,    "Amount in docu. currency
            ' ' 'BSEG-ZUONR' wa_itab1-zuonr,    "Allocation number
            ' ' 'BSEG-SGTXT' txt,    "Line item text
            ' ' 'BDC_OKCODE' '/14',
            'X' 'SAPLKACB'    '0002',
            ' ' 'BDC_CURSOR' 'COBL-GSBER',
            ' ' 'BDC_OKCODE' '=ENTE',
            ' ' 'COBL-GSBER' v_gsber,    "Business Area
            ' ' 'BDC_OKCODE' '/08',
            'X' 'SAPMF05A'    '0700',
            ' ' 'BDC_OKCODE' '=BU'.
*     CLEAR MESSTAB. REFRESH MESSTAB.
  CALL TRANSACTION 'F-21' USING i_bdc MODE va_mode UPDATE 'S'
              MESSAGES INTO messtab.
  IF sy-subrc EQ 0.
    PERFORM error.
    COMMIT WORK AND WAIT.
    PERFORM f_update_document_number USING fu_proc budatc(4).
  ELSE.
    ROLLBACK WORK.
    flerror = 'X'.
    MESSAGE a000(26) WITH TEXT-014.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " save
*&---------------------------------------------------------------------*
*&      Form  poskey
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM poskey.
  PERFORM f_dynpro USING:
     'X' 'SAPMF05A'    '0700',
     ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
     ' ' 'BDC_OKCODE'  '/00',
     ' ' 'RF05A-NEWBS' poskey,"Posting key for next line item
     ' ' 'RF05A-NEWKO' wa_itab1-kunnr."Account for next line item
ENDFORM.                    " poskey
*&---------------------------------------------------------------------*
*&      Form  detail_resid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detail_resid.

  PERFORM f_dynpro USING:
    'X' 'SAPMF05A'    '0301',          "Customer account item
    ' ' 'BDC_CURSOR'  'RF05A-NEWKO',
    ' ' 'BDC_OKCODE'  '=ZK',
    ' ' 'BSEG-WRBTR'   cash,   "Amount in docu. currency
    ' ' 'BSEG-GSBER'   wa_itab1-gsber,   "Business Area
    ' ' 'BSEG-ZFBDT'   bldat,
    ' ' 'BSEG-ZLSPR'   'Z',
    ' ' 'BSEG-ZUONR'   zuonr,   "Allocation number
    ' ' 'BSEG-SGTXT'   txt,   "Line item text
    'X' 'SAPMF05A' '0331',
    ' ' 'BDC_CURSOR' 'BSEG-XREF1',
    ' ' 'BDC_OKCODE'  '/14',
    ' ' 'BSEG-XREF1' wa_itab1-parvw,
    ' ' 'BSEG-XREF2' wa_itab1-slcod+4(6),
    ' ' 'BSEG-XREF3' wa_itab1-zuonr.
ENDFORM.                    " detail_resid
*&---------------------------------------------------------------------*
*&      Form  init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init.

  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8070'.
    SELECT SINGLE vwerk INTO v_gsber FROM knvv
    WHERE kunnr = wa_itab1-kunnr AND vkbur = wa_itab1-vkbur.
  ELSE.
    v_gsber = wa_itab1-gsber.
  ENDIF.

  CASE pa_bukrs.
    WHEN '8020'.
      IF wa_itab1-gsber EQ space.
        wa_itab1-gsber = '0200'.
      ENDIF.
    WHEN '8070'.
      IF wa_itab1-gsber EQ space.
        wa_itab1-gsber = '0700'.
      ENDIF.
    WHEN OTHERS.
      IF wa_itab1-gsber EQ space.
        wa_itab1-gsber = '0200'.
      ENDIF.
  ENDCASE.

  v_count = wa_itab1-bbeln.
  no = v_count.
  CONCATENATE wa_itab1-bidat+6(2) wa_itab1-bidat+4(2)
              wa_itab1-bidat+0(4) INTO bidat.
  CONCATENATE wa_itab1-zfbdt+6(2) wa_itab1-zfbdt+4(2)
              wa_itab1-zfbdt+0(4) INTO bldat.

*  monat = budat+4(2).
*  CONCATENATE budat+6(2) budat+4(2)
*  budat+0(4) INTO date.
  CONCATENATE 'Pembayaran dgn B/I No'
               no INTO txt.

  CONCATENATE 'Pembayaran dgn B/I No' no INTO bktxt.
ENDFORM.                    " init
*&---------------------------------------------------------------------*
*&      Form  header_post
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_post.
  DATA: l_vtext     LIKE tvst-adrnr,
        street      LIKE adrc-street,
        ld_date(25),
        city1       LIKE adrc-city1.

  DATA : ls_itab1  LIKE LINE OF i_itab1,
         lv_amtcar,
         lv_amttar.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.
  WRITE /50(39) 'BUKTI POSTING CASH & TRANSFER'.
  WRITE AT /50 'Tanggal :'.
*  WRITE AT 70 budat.
  IF radio1 EQ 'X'.
    WRITE : 60 budatc,',',budattc.
  ELSE.
    WRITE : 60 budat,',',budatt.
  ENDIF.
  IF pa_bukrs EQ '8020'.
    WRITE: / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE: / 'PT. EURINDO COMBINE' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE: / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.
*   READ TABLE MESSTAB WITH KEY  MSGNR = '312'.
*   IF SY-SUBRC EQ 0.
*      WA_ITAB1-VBELN = MESSTAB-MSGV1.
*   ENDIF.
  WRITE:/  street.
  WRITE :/ city1.
  IF radio1 EQ 'X'.
    WRITE :/ 'GL Account Number : ',hkontc,',',hkonttc.
  ELSE.
    WRITE :/ 'GL Account Number : ',hkont,',',hkontt.
  ENDIF.
  WRITE :/ 'Cetak : ',sy-datum,sy-uzeit.
  IF radio6 NE 'X'.
    sw = 0.
    LOOP AT i_itab1 INTO ls_itab1.
      IF ls_itab1-amtcar <> 0.
        lv_amtcar = 'X'.
      ELSEIF ls_itab1-amttar <> 0.
        lv_amttar = 'X'.
      ENDIF.
    ENDLOOP.

    LOOP AT messtab WHERE msgnr = '312'.
      IF sw = 0.
        WRITE AT 60(10)  'Doc. SAP : '.
        WRITE AT 72(10) messtab-msgv1.
        sw = 1.
      ELSE.
        WRITE :/ ' '.
        WRITE AT 72(10) messtab-msgv1.
      ENDIF.
    ENDLOOP.
  ENDIF.
  FORMAT COLOR 4.
  FORMAT INTENSIFIED OFF.
  WRITE : /(141) sy-uline.
  WRITE :/ sy-vline NO-GAP,
           (3) 'N0.',sy-vline NO-GAP,
           (18) 'NO. DO',sy-vline NO-GAP,
           (10) 'TGL DO',sy-vline NO-GAP,
           (12) 'KODE OUTLET', sy-vline NO-GAP,
           (20) 'NAMA OUTLET',sy-vline NO-GAP,
           (14) 'CASH  (Rp.)',sy-vline NO-GAP,
           (14) 'Trans (Rp.)',sy-vline NO-GAP,
           (15) 'CASH ARPot(Rp.)',sy-vline NO-GAP,
           (16) 'Trans ARPot(Rp.)',sy-vline NO-GAP.
*          'NILAi (Rp.)',sy-vline NO-GAP,(14)
  WRITE : /(141) sy-uline.

ENDFORM.                    " header_post
*&---------------------------------------------------------------------*
*&      Form  detail_post
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detail_post.
  DATA: l_name1 LIKE kna1-name1.

  v_count = 1.tot1 = 0.tot2 = 0.tot3 = 0.tot4 = 0.va_nou = 0.
  LOOP AT i_itab1 INTO wa_itab1 WHERE pcash <> 0 OR resid <> 0 OR
       pcnot <> 0 OR ptrans <> 0 OR ptnot <> 0 OR residt <> 0 OR
       amtcar <> 0 OR amttar <> 0.
    IF va_nou = 1.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      va_nou = 0.
    ELSE.
      FORMAT COLOR 1.
      FORMAT INTENSIFIED OFF.
      va_nou = 1.
    ENDIF.
    IF wa_itab1-pcnot <> 0.
      wa_itab1-pcash = wa_itab1-pcnot.
    ENDIF.
    IF wa_itab1-ptnot <> 0.
      wa_itab1-ptrans = wa_itab1-ptnot.
    ENDIF.
    IF wa_itab1-resid <> 0.
      wa_itab1-pcash = wa_itab1-pcash + wa_itab1-resid.
    ENDIF.
    IF wa_itab1-residt <> 0.
      wa_itab1-ptrans = wa_itab1-ptrans + wa_itab1-residt.
    ENDIF.

    WRITE :/ sy-vline NO-GAP,(3) v_count,sy-vline NO-GAP,
           (18) wa_itab1-zuonr,sy-vline NO-GAP.
    SELECT SINGLE name1 INTO l_name1 FROM kna1
    WHERE kunnr EQ wa_itab1-kunnr.
    WRITE : (10) wa_itab1-fkdat,sy-vline NO-GAP,
            (12) wa_itab1-kunnr,sy-vline NO-GAP,
            (20) l_name1,sy-vline NO-GAP,
            (14) wa_itab1-pcash CURRENCY 'IDR',sy-vline NO-GAP,
            (14) wa_itab1-ptrans CURRENCY 'IDR',sy-vline NO-GAP,
            (15) wa_itab1-amtcar CURRENCY 'IDR',sy-vline NO-GAP,
            (16) wa_itab1-amttar CURRENCY 'IDR',sy-vline NO-GAP.
    v_count = v_count + 1.
    tot1 = tot1 + wa_itab1-pcash.
    tot2 = tot2 + wa_itab1-ptrans.
    tot3 = tot3 + wa_itab1-amtcar.
    tot4 = tot4 + wa_itab1-amttar.
  ENDLOOP.
  FORMAT COLOR OFF.
  WRITE : /(141) sy-uline.
  WRITE AT  /65(10) 'TOTAL'.
  WRITE AT 90 sy-vline NO-GAP.
  WRITE AT 75(14) tot1 CURRENCY 'IDR'.
  WRITE AT 74 sy-vline NO-GAP.
  WRITE AT 91(14) tot2 CURRENCY 'IDR'.

  WRITE AT 106 sy-vline NO-GAP.
  WRITE AT 107(15) tot3 CURRENCY 'IDR'.
  WRITE AT 123 sy-vline NO-GAP.
  WRITE AT 124(16) tot4 CURRENCY 'IDR'.
  WRITE AT 141 sy-vline NO-GAP.
  WRITE AT /74(68) sy-uline.

  WRITE : / 'Printed By'.
  WRITE AT 12(20) sy-uname.
  IF radio6 = 'X'.
    WRITE AT 32(4) 'EX'.
  ENDIF.
ENDFORM.                    " detail_post
*&---------------------------------------------------------------------*
*&      Form  print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print.
  DATA: ld_params   LIKE pri_params,
        vspld       LIKE  usr01-spld,
        ld_arparams LIKE arc_params.
  DATA: ld_layout LIKE sy-paart,     "Druck-Layout
        ld_valid.

* Standardlayout zum im Benutzerstamm eingetragenen Drucker setzen
  SELECT SINGLE spld INTO vspld FROM usr01 WHERE bname = sy-uname.
  PERFORM set_layout(saplspri) USING    vspld 1 sy-linsz 1 sy-linsz
                               CHANGING ld_layout.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      line_size              = sy-linsz
      layout                 = ld_layout
    IMPORTING
      out_parameters         = ld_params
      out_archive_parameters = ld_arparams
      valid                  = ld_valid.
  IF ld_valid EQ 'X'.
    NEW-PAGE PRINT ON PARAMETERS ld_params
                      ARCHIVE PARAMETERS ld_arparams
                      NEW-SECTION NO DIALOG.
    PERFORM header_post.
    PERFORM detail_post.

    LEAVE TO SCREEN 0.
  ENDIF.

  NEW-PAGE PRINT OFF.

ENDFORM.                    " print
*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
          ID 'GSBER' FIELD pa_vkbur
          ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Sales Office' pa_vkbur.
  ENDIF.

ENDFORM.                    " CEK
*&---------------------------------------------------------------------*
*&      Form  ONETIME_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM onetime_cust.
  SELECT SINGLE * FROM kna1 WHERE kunnr EQ wa_itab1-kunnr.
  PERFORM f_dynpro USING :
     'X' 'SAPLFCPD'      '0100',
     ' ' 'BDC_CURSOR'    'BSEC-PSTLZ',
     ' ' 'BDC_OKCODE'    '/00',
     ' ' 'BSEC-ANRED'    kna1-anred,
     ' ' 'BSEC-SPRAS'    kna1-spras,
     ' ' 'BSEC-NAME1'    kna1-name1,
     ' ' 'BSEC-NAME2'    kna1-name2,
     ' ' 'BSEC-ORT01'    kna1-ort01,
     ' ' 'BSEC-PSTLZ'    kna1-pstlz.

ENDFORM.                    " ONETIME_CUST
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_REPRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_reprint.
  SELECT a~bukrs a~bbeln b~gjahr a~bidat a~parnr a~waers
               a~vkbur b~ebelp b~vbeln b~buzei b~gsber b~fkdat
               b~kunnr b~parvw b~slcod b~zfbdt b~wrbtr b~pchek b~pytot
               b~pcash b~usna1 b~erdt1 b~pcnot b~zuonr b~resid b~ptrans
               b~xblnrt b~residt b~ptnot
               INTO CORRESPONDING FIELDS OF TABLE i_itab1
           FROM zfbih AS a JOIN  zfbid AS b ON a~bukrs EQ b~bukrs AND
                                               a~bbeln EQ b~bbeln AND
                                               a~vkbur EQ b~vkbur
*                                             A~GJAHR EQ B~GJAHR
           WHERE a~bukrs EQ pa_bukrs AND
                 a~vkbur EQ pa_vkbur AND
*               A~GJAHR EQ PA_GJAHR AND
                 a~bbeln EQ pa_bbeln AND
                 b~bflag EQ 'P'
                 ORDER BY b~zuonr.

ENDFORM.                    " GET_DATA_REPRINT
*&---------------------------------------------------------------------*
*&      Form  CEK_BANK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_bank.
  IF amount1 > 0.
    IF screen-group1 = 'DSA'.
      screen-required = 1.
    ENDIF.
  ENDIF.

  IF amount2 > 0.
    IF screen-group1 = 'DSB'.
      screen-required = 1.
    ENDIF.
  ENDIF.
  IF amount3 > 0.
    IF screen-group1 = 'DSC'.
      screen-required = 1.
    ENDIF.
  ENDIF.
  IF amount4 > 0.
    IF screen-group1 = 'DSD'.
      screen-required = 1.
    ENDIF.
  ENDIF.
  IF amount5 > 0.
    IF screen-group1 = 'DSE'.
      screen-required = 1.
    ENDIF.
  ENDIF.
  IF amount6 > 0.
    IF screen-group1 = 'DSF'.
      screen-required = 1.
    ENDIF.
  ENDIF.
  IF amount7 > 0.
    IF screen-group1 = 'DSG'.
      screen-required = 1.
    ENDIF.
  ENDIF.
  IF amount8 > 0.
    IF screen-group1 = 'DSH'.
      screen-required = 1.
    ENDIF.
  ENDIF.
  IF amount9 > 0.
    IF screen-group1 = 'DSI'.
      screen-required = 1.
    ENDIF.
  ENDIF.

ENDFORM.                    " CEK_BANK
*&---------------------------------------------------------------------*
*&      Form  GET_TOT_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_tot_check.
  CLEAR: va_check, va_error.

  IF amount1 > 0 AND  bank1 EQ space AND no EQ space.
    CLEAR amount1.
  ENDIF.
  IF amount2 > 0 AND  bank2 EQ space AND no2 EQ space.
    CLEAR amount2.
  ENDIF.
  IF amount3 > 0 AND  bank3 EQ space AND no3 EQ space.
    CLEAR amount3.
  ENDIF.
  IF amount4 > 0 AND  bank4 EQ space AND no4 EQ space.
    CLEAR amount4.
  ENDIF.
  IF amount5 > 0 AND  bank5 EQ space AND no5 EQ space.
    CLEAR amount5.
  ENDIF.
  IF amount6 > 0 AND  bank6 EQ space AND no6 EQ space.
    CLEAR amount6.
  ENDIF.
  IF amount7 > 0 AND  bank7 EQ space AND no7 EQ space.
    CLEAR amount7.
  ENDIF.
  IF amount8 > 0 AND  bank8 EQ space AND no8 EQ space.
    CLEAR amount8.
  ENDIF.
  IF amount9 > 0 AND  bank9 EQ space AND no9 EQ space.
    CLEAR amount9.
  ENDIF.

* tambah check untuk nama bank
  IF bank1 NE space.
    CLEAR: va_check.
    va_check = bank1(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank2 NE space.
    CLEAR: va_check.
    va_check = bank2(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank3 NE space.
    CLEAR: va_check.
    va_check = bank3(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank4 NE space.
    CLEAR: va_check.
    va_check = bank4(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank5 NE space.
    CLEAR: va_check.
    va_check = bank5(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank6 NE space.
    CLEAR: va_check.
    va_check = bank6(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank7 NE space.
    CLEAR: va_check.
    va_check = bank7(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank8 NE space.
    CLEAR: va_check.
    va_check = bank8(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF bank9 NE space.
    CLEAR: va_check.
    va_check = bank9(1).
    IF ' ABCDEFGHIJKLMNOPQRSTUVWXYZ' NA va_check.
      va_error = 1.
    ENDIF.
  ENDIF.

  IF va_error EQ 1.
    MESSAGE e000(26) WITH
    'Penulisan Bank salah ( hrs diawali dgn Alphabet )'.
    CLEAR: amount1, amount2, amount3, amount4, amount5, amount6, amount7,
                amount8, amount9.
  ENDIF.
ENDFORM.                    " GET_TOT_CHECK
*&---------------------------------------------------------------------*
*&      Form  close_for-payment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_for-payment.
  DATA : BEGIN OF itab9 OCCURS 0,
           belnr LIKE bsid-belnr,
           buzei LIKE bsid-buzei,
           blart LIKE bsid-blart,
         END OF itab9.
  REFRESH itab9.CLEAR itab9.

  SELECT  belnr buzei blart INTO TABLE itab9 FROM bsid
  WHERE bukrs EQ pa_bukrs AND kunnr EQ wa_itab1-kunnr AND
        zuonr EQ wa_itab1-zuonr.
* Tahun
*      AND GJAHR EQ WA_ITAB1-GJAHR.
  LOOP AT itab9.
    CLEAR i_bdc.

    PERFORM f_dynpro USING:
                'X' 'SAPMF05L'   '0102',
                ' ' 'BDC_CURSOR'   'RF05L-GJAHR',
   	       ' ' 'BDC_OKCODE'	 '/00',
   	       ' ' 'RF05L-BELNR' itab9-belnr,
   	       ' ' 'RF05L-BUKRS' pa_bukrs,
   	       ' ' 'RF05L-GJAHR' wa_itab1-gjahr,
                ' ' 'RF05L-BUZEI' itab9-buzei,
   	       ' ' 'RF05L-XKDEB' 'X'.
    IF wa_itab1-kunnr(2) EQ 'SL'.
      PERFORM f_dynpro USING:
          'X' 'SAPLFCPD'   '0100',
          ' ' 'BDC_CURSOR' 'BSEC-SPRAS',
          ' ' 'BDC_OKCODE' '/00'.
    ENDIF.

    IF itab9-blart EQ 'RV' OR itab9-blart EQ 'ZA'.
      PERFORM f_dynpro USING:
         'X' 'SAPMF05L'    '0301',
         ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
         ' ' 'BDC_OKCODE'  '=AE',
         ' ' 'BSEG-ZLSPR'	 'B',
         ' ' 'BSEG-SGTXT'  txt.
    ELSE.
      PERFORM f_dynpro USING:
         'X' 'SAPMF05L'    '0301',
         ' ' 'BDC_CURSOR'  'BSEG-ZLSPR',
         ' ' 'BDC_OKCODE'  '=AE',
         ' ' 'BSEG-ZLSPR'	 'B'.
    ENDIF.

    CALL TRANSACTION 'FB09' USING i_bdc MODE va_mode UPDATE 'S'
            MESSAGES INTO messtab.
    PERFORM error.

  ENDLOOP.

ENDFORM.                    " close_for-payment

*&---------------------------------------------------------------------*
*&      Form  ranges_hkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ranges_hkont.
*  ra_hkont-low     = '0112100010'.
*  ra_hkont-high    = '0112100020'.
*  ra_hkont-option  = 'BT'.
*  ra_hkont-sign    = 'I'.
*  APPEND ra_hkont.
*
*  ra_hkont-low     = '0113101010'.
*  ra_hkont-high    = '0113101012'.
*  ra_hkont-option  = 'BT'.
*  ra_hkont-sign    = 'I'.
*  APPEND ra_hkont.
*
*  ra_hkont-low     = '0113102010'.
*  ra_hkont-option  = 'EQ'.
*  ra_hkont-sign    = 'I'.
*  APPEND ra_hkont.
*
*  ra_hkont-low     = '0113104010'.
*  ra_hkont-option  = 'EQ'.
*  ra_hkont-sign    = 'I'.
*  APPEND ra_hkont.
*
*  ra_hkont-low     = '0113107010'.
*  ra_hkont-option  = 'EQ'.
*  ra_hkont-sign    = 'I'.
*  APPEND ra_hkont.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_hkont
    FROM zfacct
    WHERE vtart = 'BI'.
  LOOP AT t_hkont.
    CASE t_hkont-vtype.
      WHEN 'CS'.
        ra_hkont-low     = t_hkont-saknr.
        ra_hkont-option  = 'EQ'.
        ra_hkont-sign    = 'I'.
        APPEND ra_hkont.
      WHEN 'TR'.
        ra_hkont1-low     = t_hkont-saknr.
        ra_hkont1-option  = 'EQ'.
        ra_hkont1-sign    = 'I'.
        APPEND ra_hkont1.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " ranges_hkont

*&---------------------------------------------------------------------*
*&      Form  f_line_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_line_total USING fu_res.

  DATA: ld_pcash(12),
        ld_pchek(12),
        ld_pcnot(12),
        ld_ptnot(12),
        ld_ptrans(12),
        ld_amtttf(12),
        ld_wrbtr(18),
        ld_amtcar(12),
        ld_amttar(12).

  WRITE va_wrbtr CURRENCY 'IDR' TO ld_wrbtr.
  MODIFY LINE va_lines OF PAGE va_pages
  FIELD VALUE
  va_text FROM va_text
  va_wrbtr FROM ld_wrbtr.

  READ TABLE t_totaltemp INDEX 1.
  IF sy-subrc EQ 0.
    t_total-pcash = t_totaltemp-pcash * -1.
    t_total-pchek = t_totaltemp-pchek * -1.
    t_total-pcnot = t_totaltemp-pcnot * -1.
    t_total-ptnot = t_totaltemp-ptnot * -1.
    t_total-ptrans = t_totaltemp-ptrans * -1.
    t_total-amtttf = t_totaltemp-amtttf * -1.
    t_total-amtcar = t_totaltemp-amtcar * -1.
    t_total-amttar = t_totaltemp-amttar * -1.
    COLLECT t_total.
  ENDIF.

  t_total-pcash = itab-pcash.
  t_total-pchek = itab-pchek.
  t_total-pcnot = itab-pcnot.
  t_total-ptnot = itab-ptnot.
  t_total-ptrans = itab-ptrans.
  t_total-amtttf = itab-amtttf.
  t_total-amtcar = itab-amtcar.
  t_total-amttar = itab-amttar.

** Added by Budi.P Req. by SJT 27/07/2009
*  IF fu_res NE 'R' AND itab-pcnot NE 0.
*    t_total-pcash = itab-pcnot.
*    CLEAR t_total-pcnot.
*  ENDIF.
*  IF itab-ptnot NE 0.
*    t_total-ptrans = itab-ptnot.
*    CLEAR t_total-ptnot.
*  ENDIF.
** End Added by Budi.P Req. by SJT 27/07/2009

  COLLECT t_total.
  READ TABLE t_total INDEX 1.
  IF sy-subrc EQ 0.
    WRITE t_total-pcash CURRENCY 'IDR' TO ld_pcash.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-pcash FROM ld_pcash.

    WRITE t_total-pchek CURRENCY 'IDR' TO ld_pchek.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-pchek FROM ld_pchek.

    WRITE t_total-pcnot CURRENCY 'IDR' TO ld_pcnot.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-pcnot FROM ld_pcnot.

    WRITE t_total-ptnot CURRENCY 'IDR' TO ld_ptnot.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-ptnot FROM ld_ptnot.

    WRITE t_total-ptrans CURRENCY 'IDR' TO ld_ptrans.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-ptrans FROM ld_ptrans.

    WRITE t_total-amtttf CURRENCY 'IDR' TO ld_amtttf.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-amtttf FROM ld_amtttf.

    WRITE t_total-amtcar CURRENCY 'IDR' TO ld_amtcar.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-amtcar FROM ld_amtcar.

    WRITE t_total-amttar CURRENCY 'IDR' TO ld_amttar.
    MODIFY LINE va_lines OF PAGE va_pages
    FIELD VALUE
    t_total-amttar FROM ld_amttar.
  ENDIF.
  CLEAR: t_total.
ENDFORM.                    " f_line_total

*&---------------------------------------------------------------------*
*&      Form  radio3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM radio3 .
  fl_test = 'N'.
  PERFORM f_get_data_post.
  DESCRIBE TABLE i_itab1 LINES v_line_size.
  IF v_line_size > 0.
    PERFORM cek_lock.
    fl = space.

    flpost = 'X'.
    PERFORM post21_new.

    IF pa_vkbur EQ '0300'.
      IF hkontc EQ '0112100000'.
      ELSE.
        MESSAGE i000(26) WITH 'GL  Account harus 0112100000'.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE i000(26) WITH TEXT-010.
    STOP.
  ENDIF.
  IF flpost = 'X' AND flerror NE 'X'.
    SET PF-STATUS 'ZF_BI_PRINT'.
    PERFORM header_post.
    PERFORM detail_post.
  ENDIF.
ENDFORM.                                                    " radio3

*&---------------------------------------------------------------------*
*&      Form  f_update_zfbid_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_zfbid_01 .
  UPDATE zfbid SET bflag = 'D'
    WHERE bukrs = pa_bukrs AND vkbur = pa_vkbur
*     AND GJAHR = ITAB-GJAHR
      AND bbeln = pa_bbeln AND bflag EQ space.
ENDFORM.                    " f_update_zfbid_01

*&---------------------------------------------------------------------*
*&      Form  f_update_zfbid_02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_zfbid_02 .
  DATA : ls_arpot  LIKE LINE OF gt_arpot.

  UPDATE zfbid
    SET pcash = itab-pcash pchek = itab-pchek pytot = itab-pytot
        resid = itab-resid bflag = itab-bflag pstat = itab-pstat
        ptype = itab-ptype xblnr = itab-xblnr usna1 = sy-uname
        erdt1 = sy-datum   pcnot = itab-pcnot nottf = itab-nottf
        tglttf = itab-tglttf ptrans = itab-ptrans kdtrf = itab-kdtrf
        xblnrt = itab-xblnrt residt = itab-residt ptnot = itab-ptnot
    WHERE bukrs = itab-bukrs AND vkbur = itab-vkbur
      AND gjahr = itab-gjahr AND bbeln = itab-bbeln
      AND vbeln = itab-vbeln
      AND zuonr = itab-zuonr.

  IF gt_arpot[] IS NOT INITIAL.
    UPDATE zfbid_arpot SET amtcar  = itab-amtcar
                           amttar  = itab-amttar
                       WHERE bukrs = itab-bukrs
                         AND vkbur = itab-vkbur
                         AND bbeln = itab-bbeln
                         AND ebelp = itab-ebelp
                         AND vbeln = itab-vbeln.
  ELSE.
    IF itab-amtcar IS NOT INITIAL OR
      itab-amttar IS NOT INITIAL.
      ls_arpot-bukrs  = itab-bukrs.
      ls_arpot-vkbur  = itab-vkbur.
      ls_arpot-bbeln  = itab-bbeln.
      ls_arpot-ebelp  = itab-ebelp.
      ls_arpot-vbeln  = itab-vbeln.
      ls_arpot-amtcar = itab-amtcar.
      ls_arpot-amttar = itab-amttar.
      INSERT zfbid_arpot FROM ls_arpot.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_update_zfbid_02

*&---------------------------------------------------------------------*
*&      Form  f_update_zfbicheck_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_zfbicheck_01 .
  MODIFY zfbicheck FROM TABLE itab2.
ENDFORM.                    " f_update_zfbicheck_01

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_SEL_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_ZUONR  text
*----------------------------------------------------------------------*
FORM f_proses_sel_screen USING fu_zuonr.
  CLEAR: i_itab1.
  READ TABLE i_itab1 WITH KEY zuonr = fu_zuonr.

  IF amtcash IS NOT INITIAL AND amtcar IS INITIAL AND amtcn IS INITIAL AND
    amttr IS INITIAL AND amtcnt IS INITIAL AND amtcheck IS INITIAL AND
    amtttf IS INITIAL AND amttar IS INITIAL.
    amtcash1 = i_itab1-wrbtr * 100.
    IF amtcash1 LT 0.
      amtcash1 = amtcash1 * -1.
    ENDIF.

  ELSEIF amtcash IS INITIAL AND amtcn IS NOT INITIAL AND amttr IS INITIAL AND
         amtcnt IS INITIAL AND amtcheck IS INITIAL AND amtttf IS INITIAL.
    amtcn1 = i_itab1-wrbtr * 100.
    IF amtcn1 LT 0.
      amtcn1 = amtcn1 * -1.
    ENDIF.

  ELSEIF amtcash IS INITIAL AND amtcn IS INITIAL AND amttr IS NOT INITIAL AND
         amtcnt IS INITIAL AND amtcheck IS INITIAL AND amtttf IS INITIAL.
    amttr1 = i_itab1-wrbtr * 100.
    IF amttr1 LT 0.
      amttr1 = amttr1 * -1.
    ENDIF.

  ELSEIF amtcash IS INITIAL AND amtcn IS INITIAL AND amttr IS INITIAL AND
         amtcnt IS NOT INITIAL AND amtcheck IS INITIAL AND amtttf IS INITIAL.
    amtcn3 = i_itab1-wrbtr * 100.
    IF amtcn3 LT 0.
      amtcn3 = amtcn3 * -1.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PROSES_SEL_SCREEN

*&---------------------------------------------------------------------*
*&      Form  P_HEADER_EDC
*&---------------------------------------------------------------------*
FORM p_header_edc .
  DATA: l_vtext LIKE tvst-adrnr,
        street  LIKE adrc-street,
        city1   LIKE adrc-city1.

  SELECT SINGLE adrnr FROM tvst INTO l_vtext
  WHERE vstel = pa_vkbur.
  IF sy-subrc EQ 0.
    CLEAR: street,  city1.
    SELECT SINGLE street city1 FROM adrc
      INTO (street, city1)
      WHERE addrnumber = l_vtext.
  ENDIF.

  IF pa_bukrs EQ '8020'.
    WRITE : / 'PT. TEMPO' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8030'.
    WRITE : / 'PT. EURINDO COMBINE' INTENSIFIED OFF.
  ELSEIF pa_bukrs EQ '8070'.
    WRITE : / 'PT. SUT' INTENSIFIED OFF.
  ENDIF.

  WRITE AT 80 'REPORT EDC'.
  WRITE : / street.
  WRITE : / city1.

  WRITE : / 'Cetak : ', sy-datum, sy-uzeit.
  WRITE : /(168) sy-uline.

  WRITE : / sy-vline NO-GAP, (10) 'KODE ' CENTERED NO-GAP,
            sy-vline NO-GAP, (20) 'NAMA DEBITUR' CENTERED NO-GAP,
            sy-vline NO-GAP, (2) 'RY',
            sy-vline NO-GAP, (10) 'SLM.KODE',
            sy-vline NO-GAP, (6) 'BI No.',
            sy-vline NO-GAP, (14) 'NOMOR DN',
            sy-vline NO-GAP, (14) 'NILAI',
            sy-vline NO-GAP, (10) 'TANGGAL' CENTERED NO-GAP,
            sy-vline NO-GAP, (14) 'DOCUMENT NO.' CENTERED NO-GAP,
            sy-vline NO-GAP, (18) 'Trans (Rp)',
            sy-vline NO-GAP, (17) 'C/N' CENTERED NO-GAP,
            sy-vline NO-GAP, (14) 'DOCUMENT' CENTERED NO-GAP,
            sy-vline.

  WRITE : / sy-vline NO-GAP, (10) 'OUTLET' CENTERED NO-GAP,
            sy-vline NO-GAP, (20) '' NO-GAP,
            sy-vline NO-GAP, (2) '',
            sy-vline NO-GAP, (10) '',
            sy-vline NO-GAP, (6) '',
            sy-vline NO-GAP, (14) '',
            sy-vline NO-GAP, (14) '',
            sy-vline NO-GAP, (10) 'POSTING' CENTERED NO-GAP,
            sy-vline NO-GAP, (14) 'POSTING' CENTERED NO-GAP,
            sy-vline NO-GAP, (18) '',
            sy-vline NO-GAP, (17) 'Transfer(RP)' CENTERED NO-GAP,
            sy-vline NO-GAP, (14) 'REVERSE' CENTERED NO-GAP,
            sy-vline.
  WRITE : /(168) sy-uline.
ENDFORM.                    " P_HEADER_EDC

*&---------------------------------------------------------------------*
*&      Form  P_DETAIL_EDC
*&---------------------------------------------------------------------*
FORM p_detail_edc .
  DATA : lt_itab LIKE i_itab1 OCCURS 0 WITH HEADER LINE,
         lt_sum  LIKE i_itab1 OCCURS 0 WITH HEADER LINE,
         lt_bsid LIKE gt_bsid OCCURS 0 WITH HEADER LINE,
         lt_reve LIKE gt_bsid OCCURS 0 WITH HEADER LINE.

  DATA : lv_sumkey(60),
         lv_sumtmp(60),
         lv_edckey(10),
         lv_kunnr      LIKE zfbid-kunnr,
         lv_name1      TYPE name1_gp,
         lv_budat(10),
         lv_edc        TYPE int4,
         lv_point(10),
         lv_wrbtr      LIKE zfbid-wrbtr,
         lv_ptrans     LIKE zfbid-ptrans,
         lv_ptnot      LIKE zfbid-ptnot,
         lv_edcgt      TYPE int4,
         lv_wrbtrgt    LIKE zfbid-wrbtr,
         lv_ptransgt   LIKE zfbid-ptrans,
         lv_ptnotgt    LIKE zfbid-ptnot,
         lv_belnrr     TYPE belnr_d.

  LOOP AT gt_bsid.
    IF gt_bsid-augbl = gt_bsid-belnr.
      CONTINUE.
    ENDIF.
    lt_bsid = gt_bsid.
    APPEND lt_bsid.
    CLEAR lt_bsid.
  ENDLOOP.

  SORT lt_bsid BY kunnr zuonr belnr DESCENDING.
  LOOP AT i_itab1 INTO wa_itab1.
    READ TABLE lt_bsid WITH KEY kunnr = wa_itab1-kunnr
                                zuonr = wa_itab1-zuonr.
    IF sy-subrc = 0.
      wa_itab1-belnr   = lt_bsid-belnr.
      WRITE lt_bsid-budat TO wa_itab1-budat DD/MM/YYYY.

      wa_itab1-belnrr  = lt_bsid-augbl.

      READ TABLE gt_kna1 WITH KEY kunnr = wa_itab1-kunnr.
      IF sy-subrc = 0.
        wa_itab1-name1  = gt_kna1-name1.
      ENDIF.
      MODIFY i_itab1 FROM wa_itab1.
      CLEAR wa_itab1.
    ELSE.
      DELETE i_itab1.
    ENDIF.
  ENDLOOP.

  lt_itab[]   = i_itab1[].
  SORT lt_itab BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
  IF lt_itab[] IS NOT INITIAL.
    SELECT kunnr name1
      FROM kna1
      INTO TABLE gt_kna1
      FOR ALL ENTRIES IN lt_itab
      WHERE kunnr = lt_itab-kunnr.
  ENDIF.

* Hitung EDC
  lt_sum[]   = i_itab1[].
  SORT lt_sum BY kunnr budat.
  DELETE ADJACENT DUPLICATES FROM lt_sum COMPARING kunnr budat.
*

  SORT i_itab1 BY kunnr budat.
  LOOP AT gt_kna1.
    LOOP AT i_itab1 INTO wa_itab1 WHERE kunnr = gt_kna1-kunnr.

      IF wa_itab1-belnrr IN gr_belnr.
        CLEAR wa_itab1-belnrr.
      ENDIF.

      WRITE wa_itab1-belnrr TO lv_belnrr NO-ZERO.
      CONDENSE lv_belnrr.

*      IF lv_belnrr CP '1000*'.
*        CLEAR wa_itab1-belnrr.
*      ENDIF.

      IF wa_itab1-belnrr IS NOT INITIAL.
        CLEAR: wa_itab1-ptrans,wa_itab1-ptnot.
      ENDIF.

      CONCATENATE wa_itab1-kunnr wa_itab1-name1 "wa_itab1-budat
        INTO lv_sumtmp SEPARATED BY '#'.

      IF lv_sumkey IS INITIAL.
        lv_sumkey = lv_sumtmp.

      ELSEIF lv_sumkey NE lv_sumtmp.
        IF lv_edc IS INITIAL.
          CLEAR lv_point.
        ELSE.
          lv_point = 'Point'.
        ENDIF.
        SPLIT lv_sumkey AT '#' INTO lv_kunnr lv_name1 lv_budat.

        "Write total
        WRITE : / sy-uline(168).
        WRITE : / sy-vline NO-GAP, (71) 'Total EDC' CENTERED NO-GAP,
                  '' NO-GAP, (14) lv_edc,
                  '' NO-GAP, (25) lv_point NO-GAP,
                  '' NO-GAP, (16) lv_ptrans CURRENCY 'IDR',
                                        ' ',
                  '' NO-GAP, (16) lv_ptnot CURRENCY 'IDR',
                  '' NO-GAP, (14) '' NO-GAP,
                  sy-vline.
        WRITE : / sy-uline(168).

        ADD lv_edc TO lv_edcgt.
        ADD lv_wrbtr TO lv_wrbtrgt.
        ADD lv_ptrans TO lv_ptransgt.
        ADD lv_ptnot TO lv_ptnotgt.
        lv_sumkey = lv_sumtmp.
        CLEAR: lv_wrbtr,lv_ptrans,lv_ptnot,lv_edckey,lv_edc.
      ENDIF.

      WRITE : / sy-vline NO-GAP, (10) wa_itab1-kunnr CENTERED NO-GAP,
                sy-vline NO-GAP, (20) wa_itab1-name1 NO-GAP,
                sy-vline NO-GAP, (2) wa_itab1-parvw,
                sy-vline NO-GAP, (10) wa_itab1-slcod+6(4),
                sy-vline NO-GAP, (6) wa_itab1-bbeln,
                sy-vline NO-GAP, (14) wa_itab1-zuonr,
                sy-vline NO-GAP, (14) wa_itab1-wrbtr CURRENCY 'IDR',
                sy-vline NO-GAP, (10) wa_itab1-budat NO-GAP,
                sy-vline NO-GAP, (14) wa_itab1-belnr NO-GAP HOTSPOT,
                sy-vline NO-GAP, (16) wa_itab1-ptrans CURRENCY 'IDR',
                                      wa_itab1-kdtrf,
                sy-vline NO-GAP, (16) wa_itab1-ptnot CURRENCY 'IDR',
                sy-vline NO-GAP, (14) wa_itab1-belnrr NO-GAP HOTSPOT,
                sy-vline.

      ADD wa_itab1-wrbtr TO lv_wrbtr.
      ADD wa_itab1-ptrans TO lv_ptrans.
      ADD wa_itab1-ptnot TO lv_ptnot.

      "Hitung total EDC
      IF wa_itab1-budat NE lv_edckey.
        lv_edckey = wa_itab1-budat.
        IF wa_itab1-belnrr IS INITIAL.
          ADD 1 TO lv_edc.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_edc IS INITIAL.
      CLEAR lv_point.
    ELSE.
      lv_point = 'Point'.
    ENDIF.
    SPLIT lv_sumkey AT '#' INTO lv_kunnr lv_name1 lv_budat.

    "Write total
    WRITE : / sy-uline(168).
    WRITE : / sy-vline NO-GAP, (71) 'Total EDC' CENTERED NO-GAP,
              '' NO-GAP, (14) lv_edc,
              '' NO-GAP, (25) lv_point NO-GAP,
              '' NO-GAP, (16) lv_ptrans CURRENCY 'IDR',
                                    ' ',
              '' NO-GAP, (16) lv_ptnot CURRENCY 'IDR',
              '' NO-GAP, (14) '' NO-GAP,
              sy-vline.
    WRITE : / sy-uline(168).

    ADD lv_edc TO lv_edcgt.
    ADD lv_wrbtr TO lv_wrbtrgt.
    ADD lv_ptrans TO lv_ptransgt.
    ADD lv_ptnot TO lv_ptnotgt.
    CLEAR: lv_kunnr,lv_name1,lv_budat,lv_wrbtr,lv_ptrans,lv_ptnot.
    CLEAR: lv_sumkey,lv_sumtmp,lv_edckey,lv_edc.
  ENDLOOP.

  IF lv_edcgt IS INITIAL.
    CLEAR lv_point.
  ELSE.
    lv_point = 'Point'.
  ENDIF.

  "Write grand total
  WRITE : / sy-vline NO-GAP, (71) 'Grand Total EDC' CENTERED NO-GAP,
            '' NO-GAP, (14) lv_edcgt,
            '' NO-GAP, (25) lv_point NO-GAP,
            '' NO-GAP, (16) lv_ptransgt CURRENCY 'IDR',
                                  ' ',
            '' NO-GAP, (16) lv_ptnotgt CURRENCY 'IDR',
            '' NO-GAP, (14) '' NO-GAP,
            sy-vline.
  WRITE : / sy-uline(168).
ENDFORM.                    " P_DETAIL_EDC

*&---------------------------------------------------------------------*
*&      Form  F_GET_FI_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_fi_document .
  DATA : lt_zfbid   LIKE i_itab1 OCCURS 0 WITH HEADER LINE.

  lt_zfbid[]  = i_itab1[].
  SORT lt_zfbid BY zuonr kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_zfbid COMPARING zuonr kunnr.

  CHECK lt_zfbid[] IS NOT INITIAL.

  SELECT bukrs kunnr augbl zuonr gjahr belnr buzei budat blart
    FROM bsid
    INTO TABLE gt_bsid
    FOR ALL ENTRIES IN lt_zfbid
    WHERE bukrs = pa_bukrs
      AND kunnr = lt_zfbid-kunnr
      AND zuonr = lt_zfbid-zuonr
      AND blart = 'DZ'
      AND budat IN so_budat.

  SELECT bukrs kunnr augbl zuonr gjahr belnr buzei budat blart
    FROM bsad
    APPENDING TABLE gt_bsid
    FOR ALL ENTRIES IN lt_zfbid
    WHERE bukrs = pa_bukrs
      AND kunnr = lt_zfbid-kunnr
      AND zuonr = lt_zfbid-zuonr
      AND blart = 'DZ'
      AND budat IN so_budat.

  CHECK gt_bsid[] IS NOT INITIAL.

ENDFORM.                    " F_GET_FI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_TTF
*&---------------------------------------------------------------------*
FORM f_validasi_ttf  USING    fu_zuonr fu_kunnr.
  DATA : lt_zfbid TYPE STANDARD TABLE OF zfbid INITIAL SIZE 0,
         ls_zfbid LIKE LINE OF lt_zfbid,
         lv_kunnr TYPE zfttfoutbw-kunnr,
         lv_vkbur TYPE zfbid-vkbur.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_kunnr
    IMPORTING
      output = fu_kunnr.

  PERFORM f_cekcust_soff USING pa_vkbur fu_kunnr
                         CHANGING lv_vkbur.

  IF lt_zfbid[] IS INITIAL.
    SELECT SINGLE kunnr
      FROM zfttfoutbw
      INTO lv_kunnr
      WHERE bukrs = pa_bukrs
        AND vkbur = lv_vkbur
        AND kunnr = fu_kunnr.

    IF lv_kunnr IS INITIAL.
      SELECT SINGLE kunnr
        FROM zfttfoutbd
        INTO lv_kunnr
        WHERE bukrs = pa_bukrs
          AND vkbur = lv_vkbur
          AND kunnr = fu_kunnr.
    ENDIF.

    IF lv_kunnr IS NOT INITIAL.
      SELECT SINGLE *
        FROM zftransttf
        WHERE bukrs = pa_bukrs
*          AND vkbur = pa_vkbur
          AND zuonr = fu_zuonr.
      IF sy-subrc <> 0.
        MESSAGE e000(zab) WITH 'DN belum dibuat Suggest TTF'.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fu_kunnr
      IMPORTING
        output = fu_kunnr.

    SELECT *
      FROM zfbid
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbid
      WHERE bukrs = pa_bukrs
        AND vkbur = pa_vkbur
        AND zuonr = fu_zuonr
        AND kunnr = fu_kunnr.
    IF sy-subrc = 0.
      SORT lt_zfbid BY tglttf DESCENDING.
      READ TABLE lt_zfbid INTO ls_zfbid INDEX 1.
      IF sy-subrc = 0.
        IF ls_zfbid-tglttf IS NOT INITIAL.
          MESSAGE e000(zab) WITH 'DN sudah dibuat tanggal TTF'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_TTF
*&---------------------------------------------------------------------*
*&      Form  F_CEKCUST_SOFF
*&---------------------------------------------------------------------*
FORM f_cekcust_soff  USING    fu_vkbur
                              fu_kunnr
                     CHANGING fc_vkbur.

  SELECT SINGLE zvkbur
    FROM zfarsoff
    INTO fc_vkbur
    WHERE kunnr   = fu_kunnr
      AND zvkbur1 = fu_vkbur.

  IF sy-subrc <> 0.
    fc_vkbur  = fu_vkbur.
  ENDIF.
ENDFORM.                    " F_CEKCUST_SOFF

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
FORM f_update_document_number  USING    fu_proc fu_gjahr.
  DATA : lt_mess  TYPE STANDARD TABLE OF bdcmsgcoll,
         ls_mess  LIKE LINE OF lt_mess,
         lt_arpot TYPE STANDARD TABLE OF zfbid_arpot,
         ls_arpot LIKE LINE OF lt_arpot.

  DATA : lv_lines TYPE i,
         lv_belnr TYPE bkpf-belnr.

  lt_mess[] = messtab[].
  DELETE lt_mess WHERE msgnr <> '312'.
  DESCRIBE TABLE lt_mess LINES lv_lines.

  SELECT *
    FROM zfbid_arpot
    INTO CORRESPONDING FIELDS OF TABLE lt_arpot
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_vkbur
      AND bbeln = pa_bbeln.

  LOOP AT lt_arpot INTO ls_arpot.
    CASE fu_proc.
      WHEN 'CASH'.
        READ TABLE lt_mess INTO ls_mess INDEX 1.
        IF sy-subrc = 0.
          IF ls_arpot-amtcar <> 0.
            PERFORM f_conversi USING ls_mess-msgv1
                               CHANGING lv_belnr.
            UPDATE zfbid_arpot SET belnr1  = lv_belnr
                                   gjahr1  = fu_gjahr
                               WHERE bukrs = ls_arpot-bukrs
                                 AND vkbur = ls_arpot-vkbur
                                 AND bbeln = ls_arpot-bbeln
                                 AND ebelp = ls_arpot-ebelp.
          ENDIF.
        ENDIF.
      WHEN 'TRANS'.
        READ TABLE lt_mess INTO ls_mess INDEX lv_lines.
        IF sy-subrc = 0.
          IF ls_arpot-amttar <> 0.
            PERFORM f_conversi USING ls_mess-msgv1
                               CHANGING lv_belnr.
            UPDATE zfbid_arpot SET belnr2  = lv_belnr
                                   gjahr2  = fu_gjahr
                               WHERE bukrs = ls_arpot-bukrs
                                 AND vkbur = ls_arpot-vkbur
                                 AND bbeln = ls_arpot-bbeln
                                 AND ebelp = ls_arpot-ebelp.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSI
*&---------------------------------------------------------------------*
FORM f_conversi  USING    fu_value
                 CHANGING fc_belnr.
  CLEAR fc_belnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_belnr.
ENDFORM.
