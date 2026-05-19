*&---------------------------------------------------------------------*
*&  Include           ZDG2MM_R0012TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,nast,afpo.

TYPE-POOLS: truxs.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container TYPE scrfname VALUE 'CONTAINER',
      g_grid      TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
      g_custom_container TYPE REF TO cl_gui_custom_container,
*      G_DYNDOC_ID TYPE REF TO cl_dd_document,
      gt_fieldcat TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort     TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout   TYPE lvc_s_layo,
      gt_exclude  TYPE ui_functions,
      e_object    TYPE REF TO cl_alv_event_toolbar_set,
      gv_row      TYPE lvc_s_row,
      gv_column   TYPE lvc_s_col,
      gv_row_num  TYPE lvc_s_roid.

DATA:
* Reference to document
       dg_dyndoc_id       TYPE REF TO cl_dd_document,
* Reference to split container
       dg_splitter        TYPE REF TO cl_gui_splitter_container,
* Reference to grid container
       dg_parent_grid     TYPE REF TO cl_gui_container,
* Reference to html container
       dg_html_cntrl      TYPE REF TO cl_gui_html_viewer,
* Reference to html container
       dg_parent_html     TYPE REF TO cl_gui_container.

DATA: BEGIN OF gt_out OCCURS 0.
        INCLUDE STRUCTURE ztspppst001.
DATA:   chbox   TYPE char1,
        icon1   TYPE char4,
*        celltab TYPE lvc_t_styl,
      END OF gt_out.

DATA: BEGIN OF gt_phseq OCCURS 0,
        phseq TYPE phseq,
      END OF gt_phseq.

DATA: BEGIN OF gt_batch OCCURS 0,
        matnr TYPE matnr,
        aufnr TYPE aufnr,
        posnr TYPE aposn,
        charg TYPE charg_d,
      END OF gt_batch.

DATA: BEGIN OF gt_batch2 OCCURS 0,
        phseq	TYPE phseq,
        matnr TYPE matnr,
        nomng TYPE char15,
        charg TYPE charg_d,
        seqno TYPE char1,
      END OF gt_batch2.

DATA: BEGIN OF gt_operator OCCURS 0,
        phseq	   TYPE phseq,
        matnr    TYPE matnr,
        nomng    TYPE char15,
        wempf	   TYPE wempf,
        operator TYPE ad_name1,
      END OF gt_operator.

DATA: BEGIN OF gt_pengawas OCCURS 0,
        phseq	   TYPE phseq,
        matnr    TYPE matnr,
        nomng    TYPE char15,
        wempf	   TYPE wempf,
        pengawas TYPE ad_name1,
      END OF gt_pengawas.

DATA: BEGIN OF gt_shtxt OCCURS 0,
        phseq	TYPE phseq,
        matnr TYPE matnr,
        nomng TYPE char15,
        shtxt TYPE ktx01,
      END OF gt_shtxt.


DATA gt_xout  LIKE gt_out OCCURS 0.
DATA gt_xout2 LIKE gt_out OCCURS 0.

DATA gv_title TYPE sytitle.
DATA gt_caufv LIKE caufv.
DATA gt_stko LIKE stko.
DATA gt_makt TYPE STANDARD TABLE OF makt.
DATA gt_makt2 TYPE STANDARD TABLE OF makt.
DATA gt_afpo TYPE STANDARD TABLE OF afpo.
DATA gt_aufm TYPE STANDARD TABLE OF aufm.
DATA gt_mkpf TYPE STANDARD TABLE OF mkpf.
DATA gt_mch1 TYPE STANDARD TABLE OF mch1.
DATA gt_marc TYPE STANDARD TABLE OF marc.
DATA gt_marm TYPE STANDARD TABLE OF marm.
DATA gt_t006a TYPE STANDARD TABLE OF t006a.
DATA gt_afvu TYPE STANDARD TABLE OF afvu.
DATA gt_resb TYPE STANDARD TABLE OF resb.
DATA gt_xresb TYPE STANDARD TABLE OF resb.
DATA gt_ztspppdt001 TYPE STANDARD TABLE OF ztspppdt001.
DATA gt_ztspppdt0011 TYPE STANDARD TABLE OF ztspppdt0011.
DATA gt_ztspppdt0012 TYPE STANDARD TABLE OF ztspppdt0012.
DATA gt_ztspppdt008  TYPE STANDARD TABLE OF ztspppdt008.
DATA gt_ztspppdt007  TYPE STANDARD TABLE OF ztspppdt007.
DATA gt_ztspppdt007d TYPE STANDARD TABLE OF ztspppdt007d.

FIELD-SYMBOLS: <fs_out> LIKE gt_out.

DATA : gv_mtart   TYPE mara-mtart.

DATA : gt_add     TYPE STANDARD TABLE OF zppresb_add,
       gt_afvc    TYPE STANDARD TABLE OF afvc.

TYPES : BEGIN OF ty_mseg,
          mblnr   TYPE mseg-mblnr,
          mjahr   TYPE mseg-mjahr,
          zeile   TYPE mseg-zeile,
          bwart   TYPE mseg-bwart,
          smbln   TYPE mseg-smbln,
          sjahr   TYPE mseg-sjahr,
          smblp   TYPE mseg-smblp,
        END OF ty_mseg.

DATA : gt_mseg    TYPE STANDARD TABLE OF ty_mseg.
