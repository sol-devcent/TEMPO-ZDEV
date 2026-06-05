*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNR0001TOP                                           *
*----------------------------------------------------------------------*
TABLES : zgdtxdt0012,
         zgdtxdt0004.


DATA : BEGIN OF t_zgdtxdt0012 OCCURS 0.
****modified for Tempo --- to accomodate eSPT
         INCLUDE STRUCTURE zgdtxst0012.
         DATA : fakturno2(22).
*       no         LIKE sy-tabix,
*       name       LIKE zGDTXdt0012-name,
*       npwp       LIKE zGDTXdt0012-npwp,
*       fakturno   LIKE zGDTXdt0012-fakturno,
*       fakdat     LIKE zGDTXdt0012-fakdat,
*       item       LIKE zGDTXdt0012-item,
*       itqty      TYPE i,                    "LIKE zGDTXdt0012-itqty,
*       itamt      TYPE p DECIMALS 2,         "LIKE zGDTXdt0012-itamt,
*       fakppnc    TYPE p DECIMALS 2,         "LIKE zGDTXdt0012-fakppn,
*       fakppnd    TYPE p DECIMALS 2,         "LIKE zGDTXdt0012-fakppn,
*       belnr      LIKE zGDTXdt0012-belnr,
*       budat      LIKE zGDTXdt0012-budat,
*       waers      LIKE zGDTXdt0012-waers,   "by Rahmadi
*       form       LIKE zGDTXdt0012-form,    "by Rahmadi for MKM
*       credit     LIKE zGDTXdt0012-credit,  "by Rahmadi for MKM
*       masatx     LIKE zGDTXdt0012-masatx.  "by Rahmadi for MKM
****end of Tempo modification
DATA : END OF t_zgdtxdt0012.

DATA: BEGIN OF t_download OCCURS 0.
DATA: data(255).
*DATA:   kodepajak  LIKE zgdtxst0013-kodepajak,
*        kodelamp   LIKE zgdtxst0014-kodelamp,
*        kodestat   LIKE zgdtxst0014-kodestat,
*        kodedok    LIKE zgdtxst0014-kodedok,
*        kodenpwp   LIKE zgdtxst0014-kodenpwp,
*        kodenama   LIKE zgdtxst0014-kodenama,
*        kodecabang LIKE zgdtxst0014-kodecabang,
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

DATA BEGIN OF t_zgdtxdt0024 OCCURS 0.
INCLUDE STRUCTURE zgdtxdt0024.
DATA END OF t_zgdtxdt0024.

DATA : d_index LIKE sy-tabix.

TYPE-POOLS: slis.

DATA: t_fieldcat         TYPE slis_t_fieldcat_alv,
      t_sort             TYPE slis_t_sortinfo_alv,
      t_events           TYPE slis_t_event,
      t_event_exit       TYPE slis_t_event_exit WITH HEADER LINE,
      t_list_top_of_page TYPE slis_t_listheader,
      tab_events         TYPE slis_t_event,
      comm_event         TYPE slis_alv_event,
      d_layout           TYPE slis_layout_alv,
      d_f2code           LIKE sy-ucomm VALUE  '&ETA',
      d_repid            LIKE sy-repid,
      d_variant          LIKE disvariant,
      d_print            TYPE slis_print_alv,
      d_keyinfo          TYPE slis_keyinfo_alv.
