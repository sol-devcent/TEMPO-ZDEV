*----------------------------------------------------------------------*
*   INCLUDE ZF_GSCABTOP                                                *
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: bsis, sscrfields, zfgstype, zfgscab_add, zclnumber.

TYPES: BEGIN OF ty_input,
         ztype     TYPE ztype_gs,
         zsubtype  TYPE zsubtype,
         belnr     TYPE belnr_d,
         buzei     TYPE buzei,
         xblnr     TYPE xblnr1,
         budat     TYPE budat,
         zuonr     TYPE dzuonr,
         vbund     TYPE vbund,
         kunnr     TYPE kunnr,
         waers     TYPE waers,
         wrbtr     TYPE wrbtr,
         wrtxt(15),
         kuntm     TYPE kunnr,
         zdesc     TYPE txt50,
         sgtxt     TYPE sgtxt,
         txt1      TYPE zfgscab-txt1,
         txt2      TYPE zfgscab-txt1,
         txt3      TYPE zfgscab-txt1,
         txt4      TYPE zfgscab-txt1,
         perfr     TYPE zfgscab-perfr,
         perto     TYPE zfgscab-perfr,
         check(1),
         bukrs     TYPE bukrs,
         gsber     TYPE gsber,
         gjahr     TYPE gjahr,
         postdt    TYPE budat,
         promo     LIKE zfgscab_add-promonr,
         actde     LIKE zfgscab_add-actdesc,
         cust      LIKE zfgscab_add-kunnr,
         vat       LIKE zfgscab_add-vat,
         pph       LIKE zfgscab_add-pph,
         fpnr      LIKE zfgscab_add-fpnr,
         fpdat     LIKE zfgscab_add-fpdat,
         filec     LIKE zfgscab_add-filecabang,
         kdgrp     LIKE zclnumber-kdgrp,
       END OF ty_input.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gv_bschl     TYPE bschl.
DATA: gv_status TYPE i,
      gv_fname  TYPE tdsfname,
      gv_bezei  TYPE bezei20,
      gv_city1  TYPE ad_city1,
      gv_jabat1 TYPE zgdtxde_d3titel1,
      gv_jabat2 TYPE zgdtxde_d3titel2,
      gv_zgsno  TYPE zgsno,
      gv_lastno TYPE zgsno,
      gv_error  TYPE sy-tabix,
      gv_butxt  TYPE butxt,
      gv_flag   TYPE xfeld.

DATA: obj_type     LIKE bapiache09-obj_type.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_subtype OCCURS 0,
        zsubtype TYPE zsubtype,
        zstext   TYPE zstext,
        loekz    TYPE loekz,
      END OF gt_subtype.

DATA: BEGIN OF gt_tbsl OCCURS 0,
        bschl TYPE bschl,
        shkzg TYPE shkzg,
        koart TYPE koart,
      END OF gt_tbsl.

DATA: BEGIN OF gt_zfgsnomor OCCURS 0,
        gsber   TYPE gsber,
        spmon   TYPE spmon,
        ztype   TYPE ztype,
        prefix1 TYPE zprefix1,
        prefix2 TYPE zprefix2,
        nomor   TYPE znomor2,
      END OF gt_zfgsnomor.

DATA: BEGIN OF gt_zfgstype OCCURS 0,
        ztype    TYPE ztype_gs,
        zsubtype TYPE zsubtype,
        hkont    TYPE hkont,
      END OF gt_zfgstype.

DATA: BEGIN OF gt_bsis OCCURS 0,
        bukrs TYPE bukrs,
        hkont TYPE hkont,
        augdt TYPE augdt,
        augbl TYPE augbl,
        zuonr TYPE dzuonr,
        gjahr TYPE gjahr,
        belnr TYPE belnr_d,
        buzei TYPE buzei,
        budat TYPE budat,
        bldat TYPE bldat,
        waers TYPE waers,
        xblnr TYPE xblnr1,
        blart TYPE blart,
        bschl TYPE bschl,
        shkzg TYPE shkzg,
        gsber TYPE gsber,
        wrbtr TYPE wrbtr,
        sgtxt TYPE sgtxt,
        vbund TYPE rassc,
      END OF gt_bsis.

DATA: BEGIN OF gt_kna1 OCCURS 0,
        kunnr TYPE kunnr,
        vbund TYPE vbund,
        name1 TYPE ad_name1,
      END OF gt_kna1.

DATA: BEGIN OF gt_bkpf OCCURS 0,
        bukrs TYPE bukrs,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
        stblg TYPE stblg,
      END OF gt_bkpf.

DATA: BEGIN OF gt_zfgscab OCCURS 0,
        bukrs      TYPE bukrs,
        gsber      TYPE gsber,
        belnr      TYPE belnr_d,
        gjahr      TYPE gjahr,
        buzei      TYPE buzei,
        budat      TYPE budat,
        bldat      TYPE bldat,
        xblnr      TYPE xblnr1,
        zuonr      TYPE dzuonr,
        sgtxt      TYPE sgtxt,
        zgsno      TYPE zgsno,
        ztype      TYPE ztype_gs,
        zsubtype   TYPE zsubtype,
        vbund      TYPE rassc,
        kunnr      TYPE kunnr,
        waers      TYPE waers,
        shkzg      TYPE shkzg,
        wrbtr      TYPE wrbtr,
        hkont      TYPE hkont,
        txt1       TYPE ztxt100,
        txt2       TYPE ztxt100,
        txt3       TYPE ztxt100,
        txt4       TYPE ztxt100,
        belnrgs    TYPE belnr_d,
        usergs     TYPE zupos,
        tglgs      TYPE zdpos,
        jamgs      TYPE zzpos,
        belnrrevgs TYPE belnr_d,
        userrevgs  TYPE zupos,
        tglrevgs   TYPE zdpos,
        jamrevgs   TYPE zzpos,
        belnrpost  TYPE belnr_d,
        gjahrpost  TYPE gjahr,
        userpost   TYPE zupos,
        postdt     TYPE budat,
        tglpost    TYPE zdpos,
        jampost    TYPE zzpos,
        belnrrev   TYPE belnr_d,
        userrev    TYPE zurev,
        tglrev     TYPE zdrev,
        kuntm      TYPE kunnr,
        belnrdn    TYPE belnr_d,
        belnrrevdn TYPE belnr_d,
        xref2      TYPE xref2,
        perfr      TYPE budat,
        perto      TYPE budat,
        check(1),
      END OF gt_zfgscab.

DATA: BEGIN OF gt_skat OCCURS 0,
        saknr TYPE saknr,
        txt20 TYPE txt20_skat,
      END OF gt_skat.

DATA: BEGIN OF gt_save OCCURS 0.
        INCLUDE STRUCTURE zfgscab.
      DATA: END OF gt_save.

DATA: BEGIN OF gt_zfgsaccgs OCCURS 0,
        ztype       TYPE ztype_gs,
        zsubtype    TYPE zsubtype,
        gsber       TYPE gsber,
        blart       TYPE blart,
        bschl1      TYPE bschl,
        hkont1      TYPE hkont,
        mwskz1      TYPE mwskz,
        ztax1       TYPE ztax1,
        bschl2      TYPE bschl,
        hkont2      TYPE hkont,
        mwskz2      TYPE mwskz,
        ztax2       TYPE ztax1,
        bschl3      TYPE bschl,
        hkont3      TYPE hkont,
        mwskz3      TYPE mwskz,
        ztax3       TYPE ztax1,
        bschl4      TYPE bschl,
        hkont4      TYPE hkont,
        mwskz4      TYPE mwskz,
        ztax4       TYPE ztax1,
        bschl5      TYPE bschl,
        hkont5      TYPE hkont,
        mwskz5      TYPE mwskz,
        ztax5       TYPE ztax1,
        bschl6      TYPE bschl,
        hkont6      TYPE hkont,
        mwskz6      TYPE mwskz,
        ztax6       TYPE ztax1,
        bschl7      TYPE bschl,
        hkont7      TYPE hkont,
        mwskz7      TYPE mwskz,
        ztax7       TYPE ztax1,
        bschl8      TYPE bschl,
        hkont8      TYPE hkont,
        mwskz8      TYPE mwskz,
        ztax8       TYPE ztax1,
        zpostdn     TYPE zpostdn,
        zprntdn     TYPE zprntdn,
        zinputppn   TYPE zinputppn,
        zinputgsber TYPE zinputgsber,
      END OF gt_zfgsaccgs.

*DATA: BEGIN OF gt_input OCCURS 0,
*        ztype     TYPE ztype_gs,
*        zsubtype  TYPE zsubtype,
*        belnr     TYPE belnr_d,
*        buzei     TYPE buzei,
*        xblnr     TYPE xblnr1,
*        budat     TYPE budat,
*        zuonr     TYPE dzuonr,
*        vbund     TYPE vbund,
*        kunnr     TYPE kunnr,
*        waers     TYPE waers,
*        wrbtr     TYPE wrbtr,
*        wrtxt(15),
*        sgtxt     TYPE sgtxt,
*        txt1      TYPE zfgscab-txt1,
*        txt2      TYPE zfgscab-txt1,
*        txt3      TYPE zfgscab-txt1,
*        txt4      TYPE zfgscab-txt1,
*        check(1),
*        bukrs     TYPE bukrs,
*        gsber     TYPE gsber,
*        gjahr     TYPE gjahr,
*        postdt    TYPE budat,
*        promo     LIKE zfgscab_add-promonr,
*        actde     LIKE zfgscab_add-actdesc,
*        cust      LIKE zfgscab_add-kunnr,
*        vat       LIKE zfgscab_add-vat,
*        pph       LIKE zfgscab_add-pph,
*        fpnr      LIKE zfgscab_add-fpnr,
*        fpdat     LIKE zfgscab_add-fpdat,
*        filec     LIKE zfgscab_add-filecabang,
*      END OF gt_input.

DATA: BEGIN OF gt_gsno OCCURS 0,
        belnr TYPE belnr_d,
        nomor TYPE znomor2,
      END OF gt_gsno.

DATA: gt_header LIKE zfstgs OCCURS 0 WITH HEADER LINE,
      gt_vdata  LIKE zfstgs OCCURS 0 WITH HEADER LINE,
      gt_detail LIKE zfstgs OCCURS 0 WITH HEADER LINE.

DATA: glgs   LIKE TABLE OF bapiacgl09 WITH HEADER LINE,
      apgs   LIKE TABLE OF bapiacap09 WITH HEADER LINE,
      args   LIKE TABLE OF bapiacar09 WITH HEADER LINE,
      extgs  LIKE TABLE OF bapiacextc WITH HEADER LINE,
      currgs LIKE TABLE OF bapiaccr09 WITH HEADER LINE,
      retgs  LIKE TABLE OF bapiret2 WITH HEADER LINE,
      headgs LIKE bapiache09.

DATA: BEGIN OF gt_post OCCURS 0,
        buzeipost       TYPE buzei,
        bldat           TYPE bldat,
        blart           TYPE blart,
        bukrs           TYPE bukrs,
        budat           TYPE budat,
        waers           TYPE waers,
        gsber           TYPE gsber,
        belnr           TYPE belnr_d,
        buzei           TYPE buzei,
        gjahr           TYPE gjahr,
        xblnr           TYPE xblnr1,
        sgtxt           TYPE sgtxt,
        bktxt           TYPE bktxt,
        bschl           TYPE bschl,
        vbund           TYPE vbund,
        account(10),
        description(40),
        wrbtr           TYPE wrbtr,
        koart           TYPE koart,
        mwskz           TYPE mwskz,
        txt1            TYPE ztxt100,
        txt2            TYPE ztxt100,
        txt3            TYPE ztxt100,
        txt4            TYPE ztxt100,
        icon(4),
      END OF gt_post.

DATA: BEGIN OF gt_error OCCURS 0,
        bktxt        TYPE bktxt,
        message(220),
      END OF gt_error.

DATA: gt_zfgscab_add TYPE TABLE OF zfgscab_add WITH HEADER LINE,
      gt_save_add    TYPE TABLE OF zfgscab_add WITH HEADER LINE,
      gv_belnr(10).

CONSTANTS: gc_path TYPE zfilecabang VALUE '/interface3/NIS/Cabang/'.

DATA : gt_input TYPE STANDARD TABLE OF ty_input WITH HEADER LINE,
       gt_temp  TYPE STANDARD TABLE OF ty_input WITH HEADER LINE.

DATA : gs_cust    TYPE zfgstmmt_cust,
       gv_kunnr   TYPE zfgstmmt_cust-kunnr,
       gv_kdgrp   TYPE zfgstmmt_cust-kdgrp.

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.
DATA : dynpfields      TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container        TYPE scrfname VALUE 'CONTAINER',
      g_grid             TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      g_dialog           TYPE REF TO cl_gui_dialogbox_container,
      gt_fieldcat        TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort            TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout          TYPE lvc_s_layo,
      gv_repid           LIKE sy-repid,
      gs_variant         TYPE disvariant,
      gt_exclude         TYPE ui_functions,
      e_object           TYPE REF TO cl_alv_event_toolbar_set.

DATA: g_splitter  TYPE REF TO cl_gui_splitter_container,
      g_cont_top  TYPE REF TO cl_gui_container,
      g_cont_btm  TYPE REF TO cl_gui_container,
      g_dyndoc_id TYPE REF TO cl_dd_document. " Untuk isi header

DATA: gt_clno       TYPE TABLE OF zstclnumber WITH HEADER LINE,
      gt_clno_ori   TYPE TABLE OF zstclnumber,
      gt_zfgscab_cl TYPE TABLE OF zfgscab_cl.

DATA: gt_alv_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE,  "lvc_t_fcat WITH HEADER LINE,
      gd_layout       TYPE slis_layout_alv,   "lvc_s_layo,
      gt_events       TYPE slis_t_event WITH HEADER LINE,
      gt_event_exit   TYPE slis_t_event_exit WITH HEADER LINE.
