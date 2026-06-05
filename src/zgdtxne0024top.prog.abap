*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0024TOP                                           *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES:
  zgdtxdt0002,
  zgdtxdt0003,
  zgdtxdt0007,
  zgdtxdt0005,
  zgdtxdt0101,
  zgdtxdt0106,
  vbak,
  vbrk.

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

DATA: d_subrc           LIKE sy-subrc,
      d_fakturtype      TYPE c,
      d_files           TYPE zfile,
      d_success(10)     TYPE c VALUE 'Success',
      d_fail(10)        TYPE c VALUE 'Fail',
      d_tx04_lock_subrc LIKE sy-subrc.

CONSTANTS:
  c_type_a(1) TYPE c VALUE 'A',
  c_type_q(1) TYPE c VALUE 'Q',
  c_type_i(1) TYPE c VALUE 'I',
  c_type_s(1) TYPE c VALUE 'S',
  c_type_g(1) TYPE c VALUE 'G'.

DATA: BEGIN OF t_00002 OCCURS 0,
***modified by Rahmadi
*       vkorg LIKE vbrk-vkorg,
*       gsber LIKE vbak-gsber,
*       spart LIKE vbrk-spart,
        bukrs          LIKE zgdtxdt0002-bukrs,
        brnch          LIKE zgdtxdt0002-brnch,
        busln          LIKE zgdtxdt0002-busln,
***end of modification
        vbeln          LIKE vbrk-vbeln,
        gjahr          LIKE vbrk-gjahr,
        fakturno       LIKE zgdtxdt0002-fakturno,
        fakturno1(19),
        xfakturno1(19),
        bilref         LIKE zgdtxdt0002-bilref,
        masatx         LIKE zgdtxdt0002-masatx,
        matnr          LIKE vbrp-matnr,
        flag           TYPE c,
        files          TYPE zfile,
      END OF t_00002.

DATA: BEGIN OF t_00002_insert OCCURS 0.
        INCLUDE STRUCTURE zgdtxdt0011.
      DATA: END OF t_00002_insert.

DATA: BEGIN OF t_list OCCURS 0,
***modified by Rahmadi
*       vkorg LIKE vbrk-vkorg,
*       gsber LIKE vbak-gsber,
*       spart LIKE vbrk-spart,
        bukrs      LIKE zgdtxdt0002-bukrs,
        brnch      LIKE zgdtxdt0002-brnch,
        busln      LIKE zgdtxdt0002-busln,
***end of modification
        vbeln      LIKE vbrk-vbeln,
        gjahr      LIKE vbrk-gjahr,
        fakturno   LIKE zgdtxdt0002-fakturno,
        bilref     LIKE zgdtxdt0002-bilref,
        masatx     LIKE zgdtxdt0002-masatx,
        matnr      LIKE vbrp-matnr,
        status(10) TYPE c,
        icon(5)    TYPE c,
      END OF t_list.

DATA: d_total_delete(6)  TYPE c,
      d_cancel_delete(6) TYPE c,
      d_message_del(100) TYPE c,
      d_flag_intensified.

DATA: d_fakturno TYPE zgdtxdt0003-fakturno.
