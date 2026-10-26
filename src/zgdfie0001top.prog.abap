*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPTOP                                   *
*----------------------------------------------------------------------*
TYPE-POOLS cxtab.

INCLUDE <icon>.

CONTROLS: tc_9010 TYPE TABLEVIEW USING SCREEN 9010.
DATA wa_cols TYPE cxtab_column.
DATA wa_ctrl TYPE cxtab_control.
DATA d_kunnr LIKE zgdfidt0003-kunnr.
DATA d_mess.

TABLES: s911,
        t001,
        ekko,
        ekpo,
        zgdfidt0001,
        zgdfidt0002,
        zgdfidt0003,
        zgdfidt0005,
        bkpf,
        bseg,
        tnapr,
        t001w,
        usr21,
        kna1,
        lfa1,
        adrp,
        adrc,
        zftntreason,
        zs911kor,
        usdef.



DATA  d_retcode LIKE sy-subrc.
DATA  d_line_count TYPE i.       " screen line count
DATA  d_tax LIKE konp-kbetr.     " tax rate
DATA  d_alv_desc LIKE disvariant-text.
DATA: d_stras LIKE kna1-stras,
      d_ort01 LIKE kna1-ort01.

TABLES  komp.
TABLES: komk    ,
        komvd   ,
        vbco3   ,
        vbdkr   ,
        vbdpr   ,
        vbdre   .

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA BEGIN OF t_s911 OCCURS 0.
INCLUDE STRUCTURE s911.
DATA END OF t_s911.

DATA: BEGIN OF gt_zgdfidt0005 OCCURS 0,
        spmon  TYPE spmon,
        bukrs  TYPE bukrs,
        ekgrp  TYPE bkgrp,
        bsart  TYPE esart,
        bedat  TYPE ebdat,
        ebeln  TYPE ebeln,
        vrsio  TYPE vrsio,
        zdesc1 TYPE zdesc25,
      END OF gt_zgdfidt0005.

DATA BEGIN OF t_s911kor OCCURS 0.
INCLUDE STRUCTURE zs911kor.
DATA END OF t_s911kor.

DATA t_s911_orig LIKE t_s911 OCCURS 0 WITH HEADER LINE.
DATA t_s911kor_orig LIKE t_s911kor OCCURS 0 WITH HEADER LINE.
DATA t_vrsio LIKE t_s911 OCCURS 0 WITH HEADER LINE.

*DATA BEGIN OF t_bkpf OCCURS 0.
*        INCLUDE STRUCTURE bkpf.
*DATA END OF t_bkpf.

DATA BEGIN OF t_fidt0001 OCCURS 0.
INCLUDE STRUCTURE zgdfidt0001.
DATA END OF t_fidt0001.

DATA BEGIN OF t_fidt0003 OCCURS 0.
INCLUDE STRUCTURE zgdfidt0003.
DATA: sel,
      butxt LIKE t001-butxt,
      namew LIKE adrc-name1,
      namec LIKE adrc-name1.
DATA END OF t_fidt0003.

DATA: BEGIN OF t_ekpo OCCURS 1,
        ebeln LIKE ekpo-ebeln,
      END OF t_ekpo.

DATA: BEGIN OF t_ekpo1 OCCURS 1,
        ebeln LIKE ekpo-ebeln,
        ebelp LIKE ekpo-ebelp,
        loekz LIKE ekpo-loekz,
        knumv LIKE ekko-knumv,
        netwr LIKE ekpo-netwr,
      END OF t_ekpo1.

DATA: BEGIN OF t_ekko OCCURS 1,
        ebeln LIKE ekko-ebeln,
        lifnr LIKE ekko-lifnr,
        knumv LIKE ekko-knumv,
        ebelp LIKE konv-kposn,
        waers LIKE ekko-waers,
      END OF t_ekko.

DATA t_ekkof LIKE t_ekko OCCURS 1 WITH HEADER LINE.

DATA: BEGIN OF t_lfa1 OCCURS 1,
        lifnr LIKE lfa1-lifnr,
        name1 LIKE lfa1-name1,
      END OF t_lfa1.

DATA: BEGIN OF t_t001 OCCURS 1,
        bukrs LIKE t001-bukrs,
        butxt LIKE t001-butxt,
        adrnr LIKE kna1-adrnr,
      END OF t_t001.

DATA: BEGIN OF t_adrc OCCURS 1,
        addrnumber LIKE adrc-addrnumber,
        sort2      LIKE adrc-sort2,
      END OF t_adrc.

DATA: BEGIN OF t_adrcz OCCURS 1,
        addrnumber LIKE adrc-addrnumber,
        street     LIKE adrc-street,
        name_co    LIKE adrc-name_co,
        str_suppl1 LIKE adrc-str_suppl1,
        str_suppl2 LIKE adrc-str_suppl2,
        str_suppl3 LIKE adrc-str_suppl3,
        location   LIKE adrc-location,
        post_code1 LIKE adrc-post_code1,
      END OF t_adrcz.

DATA: BEGIN OF t_kna1 OCCURS 1,
        kunnr LIKE kna1-kunnr,
        name1 LIKE kna1-name1,
        stras LIKE kna1-stras,
        ort01 LIKE kna1-ort01,
        pstlz LIKE kna1-pstlz,
        stceg LIKE kna1-stceg,
        stkzu LIKE kna1-stkzu,
        bukrs LIKE knb1-bukrs,
        zterm LIKE knb1-zterm,
        adrnr LIKE kna1-adrnr,
        stcd1 LIKE kna1-stcd1,
      END OF t_kna1.

*Data: t_9010 type ta_9010 occurs 0 with header line.
DATA: BEGIN OF t_9010 OCCURS 0,
        select,
        no        LIKE ekpo-ebelp,
        kunnr     LIKE kna1-kunnr,
        ekgart(7),
        ekgrp     LIKE ekko-ekgrp,
        bsart     LIKE ekko-bsart,
        vrsio     LIKE s911-vrsio,
        ebeln     LIKE ekko-ebeln,
        sts(3),
        bedat     LIKE ekko-bedat,
        lifnr     LIKE lfa1-lifnr,
        name1     LIKE lfa1-name1,
        belnr     LIKE bkpf-belnr,
        gjahr     LIKE bkpf-gjahr,
        stjah     LIKE s911-stjah,
*        netwr LIKE s911-netwr,
        netwr     LIKE rgvalue-wertv10,
        hwaer     LIKE s911-hwaer,
        kzwi1     LIKE s911-kzwi1,
        namec     LIKE kna1-name1,
        stras     LIKE kna1-stras,
        ort01     LIKE kna1-ort01,
        pstlz     LIKE kna1-pstlz,
        stceg     LIKE kna1-stceg,
        stkzu     LIKE kna1-stkzu,
        kostl     LIKE zgdfidt0001-kostl,
        prctr     LIKE zgdfidt0001-prctr,
        aufnr     LIKE zgdfidt0001-aufnr,
        hkont_rv  LIKE zgdfidt0001-hkont_rv,
        hkont_mt  LIKE zgdfidt0001-hkont_mt,
        txt1      LIKE zgdfidt0001-txt1,
        txt2      LIKE zgdfidt0001-txt2,
        bukrs     LIKE t001-bukrs,
        bukrs_d   LIKE t001-bukrs,
        gsber     LIKE zgdfidt0001-gsber,
        blart     LIKE zgdfidt0001-blart,
        zterm     LIKE knb1-zterm,
        budat     LIKE bkpf-budat,
        bldat     LIKE bkpf-bldat,
        ztag1     LIKE t052-ztag1,
        kostl_mt  LIKE zgdfidt0001-kostl_mt,
        prctr_mt  LIKE zgdfidt0001-prctr_mt,
        belnr_01  LIKE s911-belnr_01,
        bktxt     LIKE bkpf-bktxt,
        xblnr     LIKE bkpf-xblnr,
        erfnam    LIKE s911-erfnam,
        aedat     LIKE s911-aedat,
        fakturno  LIKE zgdtxdt0003-fakturno,
        fakdat    LIKE zgdtxdt0003-fakdat,
        street    LIKE adrc-street,
        kode      LIKE zs911kor-kode,
        bezei     LIKE zftntreason-bezei,
        ztext1    LIKE zs911kor-ztext1,
        ztext2    LIKE zs911kor-ztext2,
        ztext3    LIKE zs911kor-ztext3,
        zuser     LIKE zs911kor-zuser,
        zdate     LIKE zs911kor-zdate,
        adrnr     LIKE kna1-adrnr,
        kidno     LIKE bseg-kidno,
      END OF t_9010.

DATA t_9010x LIKE t_9010 OCCURS 0 WITH HEADER LINE.

DATA BEGIN OF t_crb_head OCCURS 1.
INCLUDE STRUCTURE zgdfist0001.
DATA END OF t_crb_head.

DATA BEGIN OF t_status OCCURS 1.
DATA    icon(4).
INCLUDE STRUCTURE zgdfist0001.
DATA msg(100).
DATA END OF t_status.

DATA BEGIN OF t_crb_item OCCURS 1.
INCLUDE STRUCTURE zgdfist0002.
DATA END OF t_crb_item.

DATA t_item_zero LIKE t_crb_item OCCURS 1 WITH HEADER LINE.

DATA t_minus LIKE t_crb_item OCCURS 1 WITH HEADER LINE.

DATA t_fidt0002 LIKE zgdfidt0002 OCCURS 10000 WITH HEADER LINE.

DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_t052 OCCURS 100,
        zterm LIKE t052-zterm,
        ztag1 LIKE t052-ztag1,
      END OF t_t052.

DATA: BEGIN OF tkomv OCCURS 50.
        INCLUDE STRUCTURE komv.
      DATA: END OF tkomv.

DATA: BEGIN OF t_konv OCCURS 50.
        INCLUDE STRUCTURE konv.
      DATA: END OF t_konv.

DATA: BEGIN OF t_fp OCCURS 1,
        vbeln    LIKE zgdtxdt0002-vbeln,
        gjahr    LIKE zgdtxdt0002-gjahr,
        fakturno LIKE zgdtxdt0002-fakturno,
        fakdat   LIKE zgdtxdt0003-fakdat,
        ppnlast  LIKE zgdtxdt0002-ppnlast,
        form     LIKE zgdtxdt0002-form,
        bukrs    LIKE zgdtxdt0003-bukrs,
        name     LIKE zgdtxdt0003-name,
        addrs1   LIKE zgdtxdt0003-addrs1,
        addrs2   LIKE zgdtxdt0003-addrs2,
        city     LIKE zgdtxdt0003-city,
        postal   LIKE zgdtxdt0003-postal,
      END OF t_fp.

DATA wa_fp LIKE t_fp.

DATA: BEGIN OF t_bkpf OCCURS 1,
        belnr LIKE bkpf-belnr,
        gjahr LIKE bkpf-gjahr,
        bktxt LIKE bkpf-bktxt,
        xblnr LIKE bkpf-xblnr,
      END OF t_bkpf.

DATA: BEGIN OF t_bseg OCCURS 1,
        belnr LIKE bseg-belnr,
        gjahr LIKE bseg-gjahr,
        buzei LIKE bseg-buzei,
        kunnr LIKE bseg-kunnr,
        kidno LIKE bseg-kidno,
      END OF t_bseg.

DATA BEGIN OF t_lock OCCURS 1.
DATA: ebeln LIKE s911-ebeln,
      uname LIKE sy-uname.
DATA END OF t_lock.

DATA: xscreen(1) TYPE c.
DATA  d_screen LIKE sy-dynnr.
DATA  d_par LIKE sy-dynnr.

**Materai constants
DATA d_kostl_mat LIKE zgdfidt0001-kostl VALUE '123'.
DATA d_prctr_mat LIKE zgdfidt0001-prctr VALUE 'dummy'.
DATA d_aufnr_mat LIKE zgdfidt0001-aufnr.

**Data status
DATA d_new(3) VALUE 'NEW'.    "new data
DATA d_cor(3) VALUE 'COR'.    "correction

**Version
DATA d_vrsio_orig LIKE s911-vrsio VALUE '000'.
DATA d_vrsio_dup LIKE s911-vrsio VALUE '001'.

**PO Correction
DATA d_netwr LIKE s911-netwr.  "new PO amount
DATA d_kzwi1 LIKE s911-kzwi1.  "new PO fee
DATA d_hwaer1 LIKE s911-hwaer.
DATA d_hwaer2 LIKE s911-hwaer.
DATA d_hwaer3 LIKE s911-hwaer.

**Tax code - VAT out
DATA d_taxcode LIKE a003-mwskz VALUE 'K5'.

**TNT Company code
DATA d_tnt_bukrs LIKE t001-bukrs VALUE '8160'.

* DECLARATION OF TABLECONTROL 'TC_9030' ITSELF
CONTROLS: tc_9030 TYPE TABLEVIEW USING SCREEN 9030.

* LINES OF TABLECONTROL 'TC_9030'
DATA:     g_tc_9030_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.

DATA: d_petugas  LIKE zgdtxdt0005-petugas,
      d_jabat    LIKE zgdtxdt0005-jabat,
      d_petugas1 LIKE zgdtxdt0005-petugas,
      d_jabat1   LIKE zgdtxdt0005-jabat,
      d_petugas2 LIKE zgdtxdt0005-petugas2,
      d_jabat2   LIKE zgdtxdt0005-jabat2,
      d_petugas3 LIKE zgdtxdt0005-nameadm,
      d_jabat3   LIKE zgdtxdt0005-jabatadm,
      d_brnch    LIKE zgdtxdt0005-brnch,
      d_object   LIKE zgdtxdt0005-objrange.

DATA: va_datab     LIKE zproject-datab,
*      discount LIKE zgdfidt0004-discount,
      va_fakno(17).

DATA: t_zgdtxdt0011 TYPE STANDARD TABLE OF zgdtxdt0011 WITH HEADER LINE.

**WAPU
DATA  d_w VALUE 'W'.
DATA  d_n VALUE 'N'.

**Form
DATA  d_a1 LIKE zgdtxdt0003-form VALUE 'A1'.
DATA  d_a3 LIKE zgdtxdt0003-form VALUE 'A3'.
DATA  d_a5 LIKE zgdtxdt0003-form VALUE 'A5'.

DATA gv_header LIKE ztntsdstf0001h.
DATA gt_detail TYPE TABLE OF ztntsdstf0001d WITH HEADER LINE.
DATA gt_monthnames TYPE TABLE OF t247 WITH HEADER LINE.

DATA : gt_a003 TYPE STANDARD TABLE OF a003,
       gt_konp TYPE STANDARD TABLE OF konp.

DATA : gt_0025      TYPE STANDARD TABLE OF zgdtxdt0025.
DATA : dynpfields   TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

FIELD-SYMBOLS <fs_tab>  TYPE STANDARD TABLE.

DATA : gs_dpp     TYPE zproject,
*       gs_coretax TYPE zproject,
       gs_bkpf    TYPE bkpf,
       gr_coretax TYPE RANGE OF datum.
