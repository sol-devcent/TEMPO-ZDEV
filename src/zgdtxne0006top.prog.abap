*----------------------------------------------------------------------*
*     INCLUDE ZGDTXNE0006TOP                                           *
*----------------------------------------------------------------------*

*--Table
TABLES : bsis, zgdtxdt0015, zgdtxdt0012,
         zgdtxdt0101, zgdtxdt0102, zgdtxdt0103, zgdtxdt0104,
         zgdtxdt0106, bkpf, bseg.

*-- Ranges
RANGES r_busln FOR zgdtxdt0015-hkontfr OCCURS 0.

*-- CONSTANTS
CONSTANTS : c_shkzg LIKE tbsl-shkzg VALUE 'H',
            c_ho(3) TYPE c VALUE '000'.

**For ALV
TYPE-POOLS: slis.

*--Global Data
DATA : d_error            TYPE i,
       d_oke(1)           TYPE c,
       d_belnrfrom        LIKE bsis-belnr,
       d_belnrto          LIKE bsis-belnr,
       d_gjahr            LIKE bsis-gjahr,
       d_posting(100)     TYPE c,
       d_bisnisunit(40)   TYPE c,
       d_wrongflag        TYPE i,
       d_samefaktur       TYPE i,
       t_fieldcat         TYPE slis_t_fieldcat_alv,
       t_sort             TYPE slis_t_sortinfo_alv,
       t_events           TYPE slis_t_event,
       t_list_top_of_page TYPE slis_t_listheader,
       tab_events         TYPE slis_t_event,
       comm_event         TYPE slis_alv_event,
       d_layout           TYPE slis_layout_alv,
       d_f2code           LIKE sy-ucomm VALUE  '&ETA',
       d_repid            LIKE sy-repid,
       d_variant          LIKE disvariant,
       d_print            TYPE slis_print_alv,
       d_tx04_lock_subrc  LIKE sy-subrc.

*-- Internal Table
DATA : BEGIN OF t_itab OCCURS 0.
         INCLUDE STRUCTURE zgdtxdt0012.
         DATA:   no                TYPE i,
*        waers         LIKE bsis-waers,
         indicator         TYPE i,
         fakturno_old      LIKE zgdtxdt0012-fakturno,
         fakdat_old        LIKE zgdtxdt0012-fakdat,
         qty               TYPE i,
         cek(1)            TYPE c,
         flag_data(1)      TYPE c,
         fakturno_new1(22),
       END OF t_itab.

DATA: t_itab1 LIKE t_itab OCCURS 0 WITH HEADER LINE.

*DATA : BEGIN OF t_bsis OCCURS 0,
*        buzei LIKE bsis-buzei,
*        bukrs LIKE bsis-bukrs,
*        brnch LIKE bsis-brnch,
*        hkont LIKE bsis-hkont,
*        belnr LIKE bsis-belnr,
*        budat LIKE bsis-budat,
*        gjahr LIKE bsis-gjahr,
*        waers LIKE bsis-waers,
*        monat LIKE bsis-monat,
*       END OF t_bsis.
*
DATA   BEGIN OF t_bseg OCCURS 0.    "Acc Doc Data
***modified by Rahmadi
INCLUDE STRUCTURE zgdtxst0008.
*        bukrs  LIKE bseg-bukrs,
*        belnr  LIKE bseg-belnr,
*        gjahr  LIKE bseg-gjahr,
*        buzei  LIKE bseg-buzei,
*        wrbtr  LIKE bseg-wrbtr,
*        fwbas  LIKE bseg-fwbas,
*        zfbdt  LIKE bseg-zfbdt,
*        zuonr  LIKE bseg-zuonr,
*        sgtxt  LIKE bseg-sgtxt,
*        augdt  LIKE bseg-augdt,
*        augbl  LIKE bseg-augbl,
*        menge  LIKE bseg-menge,
*        hkont  LIKE bseg-hkont,
*        lifnr  LIKE bseg-lifnr,
*        bschl  LIKE bseg-bschl,
*        gsber  LIKE bseg-gsber,
*        shkzg  LIKE bseg-shkzg,
*        name1  LIKE lfa1-name1,
*        street LIKE lfa1-stras,
*        stceg  LIKE lfa1-stceg,
*        valut  LIKE bseg-valut,
*        kunnr  LIKE bseg-kunnr,
***end of modification
DATA   END OF t_bseg.

DATA : BEGIN OF t_bseg1 OCCURS 0.      "Vendor Data
***modified by Rahmadi
         INCLUDE STRUCTURE zgdtxst0008.
*          bukrs  LIKE bseg-bukrs,
*          belnr  LIKE bseg-belnr,
*          gjahr  LIKE bseg-gjahr,
*          buzei  LIKE bseg-buzei,
*          wrbtr  LIKE bseg-wrbtr,
*          fwbas  LIKE bseg-fwbas,
*          zfbdt  LIKE bseg-zfbdt,
*          zuonr  LIKE bseg-zuonr,
*          sgtxt  LIKE bseg-sgtxt,
*          augdt  LIKE bseg-augdt,
*          augbl  LIKE bseg-augbl,
*          menge  LIKE bseg-menge,
*          hkont  LIKE bseg-hkont,
*          lifnr  LIKE bseg-lifnr,
*          bschl  LIKE bseg-bschl,
*          gsber  LIKE bseg-gsber,
*          shkzg  LIKE bseg-shkzg,
*          name1  LIKE lfa1-name1,
*          street LIKE lfa1-stras,
*          stceg  LIKE lfa1-stceg,
       DATA    END OF t_bseg1.

DATA t_bseg2 LIKE t_bseg OCCURS 1 WITH HEADER LINE.

DATA : BEGIN OF t_bkpf OCCURS 0,
         bukrs LIKE bkpf-bukrs,
         belnr LIKE bkpf-belnr,
         gjahr LIKE bkpf-gjahr,
         stblg LIKE bkpf-stblg,
         budat LIKE bkpf-budat,
         waers LIKE bkpf-waers,
         monat LIKE bkpf-monat,
         bktxt LIKE bkpf-bktxt,
       END OF t_bkpf.

DATA: BEGIN OF t_bset OCCURS 0,
        bukrs TYPE bset-bukrs,
        belnr TYPE bset-belnr,
        gjahr TYPE bset-gjahr,
        buzei TYPE bset-buzei,
        shkzg TYPE bset-shkzg,
        hwbas TYPE bset-hwbas,
        fwbas TYPE bset-fwbas,
        hwste TYPE bset-hwste,
        fwste TYPE bset-fwste,
      END OF t_bset.

***added by Rahmadi
**Tax related config tables Billing type, branch, bus line etc
DATA t_tx00101 LIKE zgdtxdt0101 OCCURS 1 WITH HEADER LINE.
DATA t_tx00102 LIKE zgdtxdt0102 OCCURS 1 WITH HEADER LINE.
DATA t_tx00103 LIKE zgdtxdt0103 OCCURS 1 WITH HEADER LINE.
***end of addition

DATA  d_flg.

DATA t_period LIKE zgdtxdt0004 OCCURS 10000 WITH HEADER LINE.

DATA gs_coretax   TYPE zproject.
