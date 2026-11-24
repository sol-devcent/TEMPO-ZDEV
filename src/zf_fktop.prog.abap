*----------------------------------------------------------------------*
*   INCLUDE ZF_FKTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, tvbur, kna1, vbrk.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS : gc_zfakty   TYPE zfakty VALUE 'FK'.

DATA : gv_filename  TYPE string,
       gv_files(20),
       gv_nomor     TYPE znumber1.

DATA : gv_subrc   TYPE sy-subrc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : gt_out     LIKE zfstefktr_fk OCCURS 0 WITH HEADER LINE,
       wa_vdata1  LIKE zfstefktr_fk,
       wa_out     LIKE zfstefktr_fk,
       gt_of      LIKE zfstefktr_of OCCURS 0 WITH HEADER LINE,
       wa_vdata2  LIKE zfstefktr_of,
       wa_of      LIKE zfstefktr_of.

DATA : gt_zfnoefaktur  LIKE zfnoefaktur OCCURS 0 WITH HEADER LINE,
       gt_zfvato       TYPE STANDARD TABLE OF zfvato,
       wa_zfvato       TYPE zfvato,
       gt_zfvato1      TYPE STANDARD TABLE OF zfvato,
       wa_zfvato1      TYPE zfvato.

DATA : gt_zplbc TYPE STANDARD TABLE OF zplbc,
       wa_zplbc LIKE zplbc.

DATA : BEGIN OF gt_bkpf OCCURS 0,
         bukrs    TYPE bukrs,
         belnr    TYPE belnr_d,
         gjahr    TYPE gjahr,
         budat    TYPE budat,
       END OF gt_bkpf.

DATA : BEGIN OF gt_s626 OCCURS 0,
         ssour    TYPE ssour,
         vrsio    TYPE vrsio,
         spmon    TYPE spmon,
         sptag    TYPE sptag,
         spwoc    TYPE spwoc,
         spbup    TYPE spbup,
         vkbur    TYPE vkbur,
         fkart    TYPE fkart,
         vbeln    TYPE vbeln_vf,
         pkunwe	  TYPE kunwe,
         matnr    TYPE matnr,
         basme    TYPE meins,
         umkzwi1  TYPE mc_umkzwi1,
         ummenge  TYPE mc_ummenge,
         mwsbp    TYPE mwsbp,
         umkzwi5  TYPE mc_umkzwi5.
DATA   END   OF gt_s626.

DATA :  BEGIN OF gt_mseg OCCURS 0,
          mblnr TYPE mblnr,
          mjahr TYPE mjahr,
          zeile TYPE mblpo,
          matnr TYPE matnr,
          menge TYPE menge_d,
          meins TYPE meins,
          dmbtr TYPE dmbtr,
          waers TYPE waers,
          bukrs TYPE bukrs,
          umwrk TYPE umwrk,
        END OF gt_mseg.

DATA : BEGIN OF gt_makt OCCURS 0,
         matnr    TYPE matnr,
         maktx    TYPE maktx.
DATA   END   OF gt_makt.

DATA : BEGIN OF gt_error OCCURS 0,
         baris    TYPE int4,
         msg(100),
       END OF gt_error.
