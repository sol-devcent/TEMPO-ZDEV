*----------------------------------------------------------------------*
*   INCLUDE ZM_SP_PRINTTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, likp.

TYPES : BEGIN OF ty_header.
        INCLUDE STRUCTURE zmstsp.
TYPES : END OF ty_header.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA : ref_grid       TYPE REF TO cl_gui_alv_grid,
       gv_number      TYPE znosp.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF gt_detail OCCURS 0.
        INCLUDE STRUCTURE zmstsp.
DATA : END OF gt_detail.

DATA : gs_header TYPE ty_header.

DATA : gt_zmpsiko   TYPE STANDARD TABLE OF zmpsiko,
       wa_zmpsiko   LIKE zmpsiko,
       gt_zmpsiko1  TYPE STANDARD TABLE OF zmpsiko1,
       wa_zmpsiko1  LIKE zmpsiko1.

DATA : gt_zplbc LIKE zplbc OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_likp OCCURS 0,
         vbeln      TYPE vbeln_vl,
         erdat      TYPE erdat,
         vstel      TYPE vstel,
         vkorg      TYPE vkorg,
         lfart      TYPE lfart,
         kunnr      TYPE kunnr,
         wadat_ist  TYPE wadat_ist,
         werks      TYPE werks_d,
         abssc      TYPE abssche_cm,
         stzzu      TYPE stzzu,
         tpgrp      TYPE tpgrp,
         type       TYPE int4,
       END OF gt_likp.

DATA : BEGIN OF gt_lips OCCURS 0,
         vbeln      TYPE vbeln_vl,
         posnr      TYPE posnr_vl,
         matnr      TYPE matnr,
         meins      TYPE meins,
         kcmeng     TYPE kcmeng,
         type       TYPE int4,
       END OF gt_lips.

DATA : BEGIN OF gt_makt OCCURS 0,
         matnr      TYPE matnr,
         normt      TYPE normt,
         maktx      TYPE maktx,
       END OF gt_makt.

DATA: BEGIN OF gt_zmsutdt005 OCCURS 0,
        matnr   TYPE matnr,
        meins   TYPE meins,
        zaun    TYPE zaun,
        umrez   TYPE umrez,
        umren   TYPE umren,
      END OF gt_zmsutdt005.

DATA : BEGIN OF gt_error OCCURS 0,
         vbeln      TYPE vbeln_vl,
         matnr      TYPE matnr,
         jenis(50),
       END OF gt_error.

DATA : BEGIN OF gt_out OCCURS 0,
         vbeln   TYPE vbeln_vl,
         erdat   TYPE erdat,
         matnr   TYPE matnr,
         maktx   TYPE maktx,
         abssc   TYPE abssche_cm,
         stzzu   TYPE stzzu,
         tpgrp   TYPE tpgrp,
         meins   TYPE meins,
         kcmeng  TYPE kcmeng,
       END OF gt_out.

* Smartforms
DATA : p_tdform         LIKE ssfscreen-fname VALUE 'ZM_SURAT_PESANAN_V03',
       d_smrt_funcmod   TYPE rs38l_fnam,
       d_output_opt     TYPE ssfcompop,
       d_ctrl_param     LIKE ssfctrlop,
       d_ssfscreen      LIKE ssfscreen,
       p_disp           LIKE ssfctrlop-preview VALUE 'X'.
