*&---------------------------------------------------------------------*
*&  Include           ZF_DSO_FKARTTOP
*&---------------------------------------------------------------------*
TABLES : bkpf, bseg, bsid, vbrk, vbrp, knvv, vrkpa, mara,
         knvk, tgsb,  kna1, t016, t016t, tvbur, tvkbt,
         t151, t151t, pa0001, t001, tvfk, tvv3t.

TYPES : BEGIN OF ty_itab,
          bukrs   LIKE bsid-bukrs,
          vkbur   LIKE knvv-vkbur,
          gsber   LIKE bsid-gsber,
          budat   LIKE bsid-budat,
          bldat   LIKE bsid-bldat,
          gjahr   LIKE bsid-gjahr,
          belnr   LIKE bsid-belnr,
          fkart   LIKE vbrk-fkart,
          kdgrp   LIKE knvv-kdgrp,
          brsch   LIKE kna1-brsch,
          channel LIKE zfchanel-channel,
          kvgr3   LIKE knvv-kvgr3,
          kunnr   LIKE bsid-kunnr,
          blart   LIKE bsid-blart,
          shkzg   LIKE bsid-shkzg,
          zbd1t   LIKE bsid-zbd1t,
          zfbdt   LIKE bsid-zfbdt,
          zuonr   LIKE bsid-zuonr,
          dmbtr   LIKE bsid-dmbtr,
          xref1   LIKE bsid-xref1,
          xref2   LIKE bsid-xref2,
          name1   LIKE kna1-name1,
          kunde   LIKE vrkpa-kunde,
          parnr   LIKE knvk-parnr,
          vrtnr   LIKE knvk-vrtnr,
          sname   LIKE pa0001-sname,
          ename   LIKE pa0001-ename,
          anln1   LIKE bsid-anln1,
        END OF ty_itab.

TYPES : BEGIN OF ty_result,
          bukrs       LIKE bsid-bukrs,
          vkbur       LIKE knvv-vkbur,
          fkart       LIKE vbrk-fkart,
          channel     LIKE zfchanel-channel,
          kvgr3       LIKE knvv-kvgr3,
          gsber       LIKE bsid-gsber,
          kdgrp       LIKE knvv-kdgrp,
          brsch       LIKE kna1-brsch,
          kunnr       LIKE bsid-kunnr,
          kunde       LIKE vrkpa-kunde,
          name1       LIKE kna1-name1,
          xref1       LIKE bsid-xref1,
          xref2       LIKE bsid-xref2,
          parnr       LIKE knvk-parnr,
          vrtnr       LIKE knvk-vrtnr,
          sname       LIKE pa0001-sname,
          ename       LIKE pa0001-ename,
          anln1       LIKE bsid-anln1,
          avrsales    TYPE p,
          outstanding TYPE p,
        END OF ty_result.

DATA : BEGIN OF t_salesman OCCURS 0.
         INCLUDE STRUCTURE knvp.
       DATA : END OF t_salesman.
DATA : BEGIN OF t_routelist OCCURS 0.
         INCLUDE STRUCTURE knvp.
       DATA : END OF t_routelist.

DATA: i_itab        TYPE ty_itab OCCURS 0,
      i_itab1       TYPE ty_itab OCCURS 0,
      i_itab2       TYPE ty_itab OCCURS 0,
      i_itab3       TYPE ty_itab OCCURS 0,
      i_itab_bsid   TYPE ty_itab OCCURS 0,
      i_itab_bsad   TYPE ty_itab OCCURS 0,
      wa_itab       TYPE ty_itab,
      i_zfchanel    LIKE zfchanel OCCURS 0 WITH HEADER LINE,
      va_dmbtr      TYPE p,
      va_lines      TYPE i,
      wa_result     TYPE ty_result,
      va_lines1     TYPE i,
      wa_result1    TYPE ty_result,
      wa_subtotal   TYPE ty_result,
      wa_subtotal1  TYPE ty_result,
      wa_subtotal2  TYPE ty_result,
      wa_total      TYPE ty_result,
      jml_hari      TYPE i,
      va_channel(1).

RANGES : ra_budat FOR bsid-budat.

DATA : va_nou      TYPE i,
       va_line     TYPE i VALUE 10,
       ctr         TYPE i,
       va_page     TYPE i,
       va_pernr    LIKE pa0001-pernr,
       va_text(30),
       tot_dmbtr1  LIKE regup-dmbtr,
       tot_dmbtr2  LIKE regup-dmbtr,
       c1          TYPE i,
       w0          TYPE i,
       w1          TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
       w5          TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i.

DATA: BEGIN OF t_zfarsoff_dele OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
      DATA: END OF t_zfarsoff_dele.
DATA: BEGIN OF t_zfarsoff_add OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
      DATA: END OF t_zfarsoff_add.

DATA: t_bsid_add  TYPE ty_itab OCCURS 0,
      t_bsad_add  TYPE ty_itab OCCURS 0,
      t_itab1_add TYPE ty_itab OCCURS 0,
      t_itab2_add TYPE ty_itab OCCURS 0.

DATA : gv_kvgr3      TYPE kvgr3.

DATA : gt_tvfkt     TYPE STANDARD TABLE OF tvfkt INITIAL SIZE 0
                                                 WITH HEADER LINE.

DATA : i_result     TYPE STANDARD TABLE OF ty_result INITIAL SIZE 0
                                                     WITH HEADER LINE.
