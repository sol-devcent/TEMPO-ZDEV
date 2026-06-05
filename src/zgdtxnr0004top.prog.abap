*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNR0004TOP                                           *
*----------------------------------------------------------------------*

TABLES : zgdtxdt0002,  "Tabel Tax System - Billing Master
         zgdtxdt0003,  "Tabel Tax System - Faktur Pajak
         zgdtxdt0004,  "Tabel Tax System - Total PPN
         zgdtxdt0005,  "Tabel Tax System - Master PKP
         zgdtxdt0009,  "Tabel Tax System - Billing Type
         zgdtxdt0101.  "Tabel Tax System - Branch Text

TABLES : t001.  "Organizational Unit

TYPE-POOLS: slis.

RANGES: r_fkart FOR zgdtxdt0009-fkart.

DATA : gv_coretax TYPE datum.

DATA : BEGIN OF t_pajak OCCURS 10.
****modified for Tempo --- to fit in to eSPT format
         INCLUDE STRUCTURE zgdtxst0013.
** -- Table zGDTXdt0003
*        bukrs      LIKE zGDTXdt0003-bukrs,
*        brnch      LIKE zGDTXdt0003-brnch,
*        masatx     LIKE zGDTXdt0003-masatx,
*        name       LIKE zGDTXdt0003-name,
*        addrs1     LIKE zGDTXdt0003-addrs1,
*        npwp       LIKE zGDTXdt0003-npwp,
*        fakturno   LIKE zGDTXdt0003-fakturno,
*        fakdat     LIKE zGDTXdt0003-fakdat,
*        fakppn     LIKE zGDTXdt0003-fakppn,
****added for MKM by Rahmadi 03/03/2004
*        form       LIKE zGDTXdt0003-form,
****end of addition
** -- Table zGDTXdt0002
** -- Lampiran Faktur Pajak Gabungan
*        vbeln      LIKE zGDTXdt0002-vbeln,
*        posnr      LIKE zGDTXdt0002-posnr,
*        fkdat      LIKE zGDTXdt0002-fkdat,
*        fkart      LIKE zGDTXdt0002-fkart,
*        typex      LIKE zGDTXdt0002-item,
**       qtyxx      like agdb-clustr,
*        qtyxx      LIKE zGDTXdt0002-itqtylast,
*        hrunt      LIKE zGDTXdt0002-itamtlast,
*        karsr      LIKE zGDTXdt0002-itamtlast,
*        optnl      LIKE zGDTXdt0002-itamtlast,
*        itdisclast LIKE zGDTXdt0002-itdisclast,
*        xppnbmlast LIKE zGDTXdt0002-xppnbmlast,
*        dpplast    LIKE zGDTXdt0002-dpplast,
*        ppnlast    LIKE zGDTXdt0002-ppnlast,
*        ppnbmlast  LIKE zGDTXdt0002-ppnbmlast,
*        pstyv      LIKE zGDTXdt0002-pstyv,
****added by Rahmadi
*        pph22      LIKE zGDTXdt0002-pph22,
*        pph23      LIKE zGDTXdt0002-pph23,
*        rangka     LIKE zGDTXdt0002-rangka,
*        mesin      LIKE zGDTXdt0002-mesin,
****end of addition
** -- Laporan Faktur Pajak
*        itdisc     LIKE zGDTXdt0002-itdisc,
*        xppnbm     LIKE zGDTXdt0002-xppnbm,
*        dpp        LIKE zGDTXdt0002-dpp,
*        ppnbm      LIKE zGDTXdt0002-ppnbm,
*        noretur    LIKE  zGDTXdt0002-noretur,
*        dtretur    LIKE zGDTXdt0002-dtretur,
** -- Global
*        karoseri   LIKE zGDTXdt0002-karoseri,
*        itamtlast  LIKE zGDTXdt0002-itamtlast,
*        item       LIKE zGDTXdt0002-item,
*        itqtylast  LIKE zGDTXdt0002-itqtylast,
*        exclude    LIKE zGDTXdt0002-exclude,
*        itoth      LIKE zGDTXdt0002-itoth,
*        itothlast  LIKE zGDTXdt0002-itothlast,  "MD2
*        totfj      LIKE zGDTXdt0002-itamtlast,
*        brnch_text(22),
*        waers      LIKE zGDTXdt0002-waers.
****end of Tempo modification
       DATA : END OF t_pajak.

DATA : BEGIN OF t_alv OCCURS 10.
****modified for Tempo --- to fit in to eSPT format
         INCLUDE STRUCTURE zgdtxst0013.
         DATA : fakturno2(22).
*        INCLUDE STRUCTURE t_pajak.
*DATA : eksbbm LIKE zgdtxdt0002-xppnbmlast.
*DATA : count LIKE agdb-clustr.
****end of Tempo modification
DATA : END OF t_alv.

DATA: BEGIN OF t_download OCCURS 0.
DATA: data(255).
*DATA:   kodepajak  LIKE zgdtxst0013-kodepajak,
*        kodelamp   LIKE zgdtxst0014-kodelamp,
*        kodestat   LIKE zgdtxst0014-kodestat,
*        kodedok    LIKE zgdtxst0014-kodedok,
*        kodenpwp   LIKE zgdtxst0014-kodenpwp,
*        kodenama   LIKE zgdtxst0014-kodenama,
*        kodecabang LIKE zgdtxst0014-kodecabang,
**        kodedigit(2),
*        kodeseri   LIKE zgdtxst0014-kodeseri,
*        kodetgl    LIKE zgdtxst0014-kodetgl,
*        tglssp     LIKE zgdtxst0014-tglssp,
*        kodemstx   LIKE zgdtxst0014-kodemstx,
*        kodethn    LIKE zgdtxst0014-kodethn,
*        koreksi    LIKE zgdtxst0014-koreksi,
*        nilbill    LIKE zgdtxst0014-nilbill,
*        nilppn     LIKE zgdtxst0014-nilppn,
*        nilppnbm   LIKE zgdtxst0014-nilppnbm.
DATA: END OF t_download.

DATA : BEGIN OF t_alv1 OCCURS 10.
         INCLUDE STRUCTURE zgdtxst0013.
       DATA : END OF t_alv1.
DATA: wa_alv1 LIKE t_alv1.

DATA : d_count TYPE i.
DATA : d_fakdat LIKE zgdtxdt0003-fakdat.
DATA : d_masatx LIKE zgdtxdt0003-masatx.
DATA : d_name   LIKE zgdtxdt0003-name.
DATA : d_addrs1 LIKE zgdtxdt0003-addrs1.
DATA : d_npwp   LIKE zgdtxdt0003-npwp.
DATA : d_brnch  LIKE zgdtxdt0003-brnch.

DATA  d_tax_valid  LIKE sy-datum.
DATA  c_local_curr LIKE zgdtxdt0002-itcurr VALUE 'IDR'.
DATA  d_rate_tax   LIKE zgdtxdt0002-rate_tax.
DATA  d_rate_std   LIKE zgdtxdt0002-rate_std.
DATA  d_ratefactor LIKE tcurr-tfact.

* -- MD4
DATA : d_repid,
       d_save(1) TYPE c,
       d_exit(1) TYPE c.
DATA : d_variant    LIKE disvariant,
       d_gx_variant LIKE disvariant.
DATA : d_fpnum(16).
* -- MD4

*ALV stuffs
DATA: repid      LIKE sy-repid.
DATA: fieldcat   TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: keyinfo    TYPE slis_keyinfo_alv.
DATA: color      TYPE slis_t_specialcol_alv WITH HEADER LINE.
DATA: layout     TYPE slis_layout_alv.
DATA: print      TYPE slis_print_alv.
DATA: sort       TYPE slis_t_sortinfo_alv WITH HEADER LINE.
DATA: t_sort TYPE slis_t_sortinfo_alv.
DATA: excluding  TYPE slis_t_extab WITH HEADER LINE.
DATA: tab_events      TYPE slis_t_event,
      tab_events_exit TYPE slis_t_event_exit WITH HEADER LINE,
      comm_event      TYPE slis_alv_event.
DATA: t_color TYPE slis_t_specialcol_alv WITH HEADER LINE.
DATA: t_color_int TYPE slis_t_specialcol_alv WITH HEADER LINE.
DATA: t_color_red TYPE slis_t_specialcol_alv WITH HEADER LINE.

DATA: gt_vbrk TYPE STANDARD TABLE OF vbrk,
      gt_bseg TYPE STANDARD TABLE OF bseg,
      gt_konv TYPE STANDARD TABLE OF konv.
