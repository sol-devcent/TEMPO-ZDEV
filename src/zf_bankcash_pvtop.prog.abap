*----------------------------------------------------------------------*
*   INCLUDE ZF_BANKCASH_PVTOP
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : bkpf, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF gt_bkpf OCCURS 0,
         bukrs TYPE bukrs,
         belnr TYPE belnr_d,
         gjahr TYPE gjahr,
         blart TYPE blart,
         bldat TYPE bldat,
         budat TYPE budat,
         xblnr TYPE xblnr1,
         bktxt TYPE bktxt,
         waers TYPE waers,
         kursf TYPE kursf,
       END OF gt_bkpf.

DATA : BEGIN OF gt_out OCCURS 0.
         INCLUDE STRUCTURE zfstbankcash.
         DATA :   check(1),
         icon(4),
       END OF gt_out.

DATA : gt_header LIKE zfstbankcash OCCURS 0 WITH HEADER LINE,
       gt_detail LIKE zfstbankcash OCCURS 0 WITH HEADER LINE,
       gs_detail LIKE zfstbankcash.

DATA : BEGIN OF gt_bseg OCCURS 0,
         bukrs TYPE bukrs,
         belnr TYPE belnr_d,
         gjahr TYPE gjahr,
         buzei TYPE buzei,
         buzid TYPE buzid,
         koart TYPE koart,
         gsber TYPE gsber,
         wrbtr TYPE wrbtr,
         zuonr TYPE dzuonr,
         sgtxt TYPE sgtxt,
         kostl TYPE kostl,
         hkont TYPE hkont,
         lifnr TYPE lifnr,
         xbilk TYPE xbilk,
         gvtyp TYPE gvtyp,
         shkzg TYPE shkzg,
         zlspr TYPE dzlspr,
         zbd1t TYPE dzbd1t,
         zfbdt TYPE dzfbdt,
         zterm TYPE dzterm,
         ebeln TYPE ebeln.
DATA   END   OF gt_bseg.

DATA : BEGIN OF gt_lfa1 OCCURS 0,
         lifnr TYPE lifnr,
         name1 TYPE name1_gp.
DATA   END   OF gt_lfa1.

DATA : BEGIN OF gt_t001w OCCURS 0,
         werks  TYPE werks_d,
         name1  TYPE ad_name1,
         street TYPE ad_street.
DATA   END   OF gt_t001w.

DATA : BEGIN OF gt_skat OCCURS 0,
         saknr TYPE saknr,
         txt20 TYPE txt20_skat.
DATA   END   OF gt_skat.

DATA: gt_tax  LIKE gt_bseg OCCURS 0 WITH HEADER LINE.
DATA: gt_zfbank_vendor TYPE TABLE OF zfbank_vendor WITH HEADER LINE.

DATA: gt_error TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.

DATA : ok_code    TYPE sy-ucomm.

DATA : line_length      TYPE i VALUE 254,
       line             TYPE i VALUE 70,
       editor_container TYPE REF TO cl_gui_custom_container,
       text_editor      TYPE REF TO cl_gui_textedit,
       text             TYPE string,
       lines            TYPE STANDARD TABLE OF tline,
       ls_lines         LIKE LINE OF lines.

DATA : gv_toppo(100),
       gv_zbd1t      TYPE bseg-zbd1t,
       gv_budat      TYPE bkpf-budat.

DATA : gt_014           TYPE STANDARD TABLE OF zfidt014.
