*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_F0013TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,mara,zfvato,kna1.

TYPE-POOLS: truxs.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container TYPE scrfname VALUE 'CONTAINER',
      g_grid      TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      gt_fieldcat TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort     TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout   TYPE lvc_s_layo,
      gt_exclude  TYPE ui_functions,
      e_object    TYPE REF TO cl_alv_event_toolbar_set.

DATA: BEGIN OF gt_out OCCURS 0,
        vkorg LIKE zfvato-vkorg,
        vkbur LIKE zfvato-vkbur,
        kunrg LIKE zfvato-kunrg,
        vatno LIKE zfvato-vatno,
        vbeln LIKE zfvato-vbeln,
        zuonr LIKE zfvato-vbeln,
        dueyr LIKE zfvato-dueyr,
        dudat LIKE zfvato-dudat,
        vbelv LIKE zfvato-vbelv,
        vatpr LIKE zfvato-vatpr,
        ebeln LIKE ekbe-ebeln,
        belnr LIKE ekbe-belnr,
*        chbox       TYPE char1,
*        celltab     TYPE lvc_t_styl,
      END OF gt_out.

DATA: BEGIN OF gt_lips OCCURS 0,
        vbeln LIKE lips-vbeln,
        posnr LIKE lips-posnr,
        vgbel LIKE lips-vgbel,
      END OF gt_lips.

DATA: BEGIN OF gt_ekbe OCCURS 0,
        ebeln LIKE ekbe-ebeln,
        ebelp LIKE ekbe-ebelp,
        zekkn LIKE ekbe-zekkn,
        vgabe LIKE ekbe-vgabe,
        gjahr LIKE ekbe-gjahr,
        belnr LIKE ekbe-belnr,
        buzei LIKE ekbe-buzei,
        xblnr LIKE ekbe-xblnr,
        shkzg LIKE ekbe-shkzg,
      END OF gt_ekbe.

FIELD-SYMBOLS: <fs_out> LIKE gt_out.

DATA: BEGIN OF download_field OCCURS 0,
        txt_field(20),
      END OF download_field.

DATA : BEGIN OF gt_download OCCURS 0,
         zuonr  TYPE ordnr_v,
         vbeln  TYPE vbeln_vf,
         belnr  TYPE belnr_d,
         gjahr  TYPE gjahr,
         alloc_nmbr	TYPE dzuonr,
         fkdat(10),
       END OF gt_download.

DATA : gv_path      TYPE string,
       gv_filename  TYPE string.
