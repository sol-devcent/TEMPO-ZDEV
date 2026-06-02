*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_F0013TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,mara,zssutdt025,zssutdt026,zfbih_sfa,zfbid_sfa,zsfafidt002,
        bsid.

TYPE-POOLS: truxs.

TYPES : BEGIN OF t_bdc.
          INCLUDE STRUCTURE bdcdata.
        TYPES : END OF t_bdc.

TYPES : BEGIN OF t_messtab.
          INCLUDE STRUCTURE bdcmsgcoll.
        TYPES : END OF t_messtab.

TYPES : BEGIN OF ty_bsid,
          bukrs TYPE bsid-bukrs,
          kunnr TYPE bsid-kunnr,
          umsks TYPE bsid-umsks,
          umskz TYPE bsid-umskz,
          augdt TYPE bsid-augdt,
          augbl TYPE bsid-augbl,
          zuonr TYPE bsid-zuonr,
          gjahr TYPE bsid-gjahr,
          belnr TYPE bsid-belnr,
          buzei TYPE bsid-buzei,
          blart TYPE bsid-blart,
          zfbdt TYPE bsid-zfbdt,
          zbd1t TYPE bsid-zbd1t,
          shkzg TYPE bsid-shkzg,
          gsber TYPE bsid-gsber,
          wrbtr TYPE bsid-wrbtr,
          name1 TYPE kna1-name1,
        END OF ty_bsid.

TYPES : BEGIN OF t_itab1,
          kunnr  LIKE  bsid-kunnr,
          zuonr  LIKE  bseg-zuonr,
          bukrs	 LIKE  bsid-bukrs,
          hkont  LIKE   bsid-kunnr,
          gjahr  LIKE   bsid-gjahr,
          belnr  LIKE   bsid-belnr,
          budat  LIKE   bsid-budat,
          bldat  TYPE   bsid-bldat,
          waers  LIKE   bsid-waers,
          xblnr  LIKE   bsid-xblnr,
          blart  LIKE   bsid-blart,
          monat  LIKE   bsid-monat,
          shkzg  LIKE   bsid-shkzg,
          wrbtr  LIKE   bsid-wrbtr,
          zfbdt	 LIKE  bsid-zfbdt,
          zbd1t  LIKE  bsid-zbd1t,
          buzei  LIKE  bsid-buzei,
          gsber  LIKE  bsid-gsber,
          zlspr  LIKE  bsid-zlspr,
          vkbur  LIKE   knvv-vkbur,
          spart  LIKE   knvv-spart,
          parvw  LIKE   zfbid_sfa-parvw,
          kunde  LIKE   vrkpa-kunde,
          namev  LIKE  knvk-namev,
          name1  LIKE  knvk-name1,
          pernr  LIKE  knb1-pernr,
          vbeln  LIKE  zfbid-vbeln,
          fkdat  LIKE  zfbid-fkdat,
          zuonr1 LIKE zfbid-slcod,
          wrbtr1 LIKE bsid-wrbtr,
          xref1  LIKE  bsid-xref1,
          xref2  LIKE  bsid-xref2,
          xref3  LIKE  bsid-xref3,
          bbeln  LIKE  zfbid-bbeln,
          ebelp  LIKE  zfbid-ebelp,
          pstat  LIKE  zfbid-pstat,
          vbund  LIKE  bsid-vbund,
          erdt2  LIKE  zfbid-erdt2,
          umskz  LIKE  bsid-umskz,
        END OF t_itab1.

CONTROLS input  TYPE TABLEVIEW USING SCREEN 500.

DATA: ok_code        TYPE sy-ucomm,
      save_ok        TYPE sy-ucomm,
      fill           TYPE i,
      gv_save(1),
      gv_error(1),
      gv_message(80),
      gv_mode(1)     VALUE 'E'.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container        TYPE scrfname VALUE 'CONTAINER',
      g_grid             TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      gt_fieldcat        TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort            TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout          TYPE lvc_s_layo,
      gv_repid           LIKE sy-repid,
      gs_variant         TYPE disvariant,
      gt_exclude         TYPE ui_functions,
      e_object           TYPE REF TO cl_alv_event_toolbar_set.

DATA: gv_row     TYPE lvc_s_row,
      gv_column  TYPE lvc_s_col,
      gv_row_num TYPE lvc_s_roid.

DATA:
* Reference to document
  dg_dyndoc_id   TYPE REF TO cl_dd_document,
* Reference to split container
  dg_splitter    TYPE REF TO cl_gui_splitter_container,
* Reference to grid container
  dg_parent_grid TYPE REF TO cl_gui_container,
* Reference to html container
  dg_html_cntrl  TYPE REF TO cl_gui_html_viewer,
* Reference to html container
  dg_parent_html TYPE REF TO cl_gui_container.

DATA: BEGIN OF gt_out OCCURS 0,
        kunnr   LIKE  bsid-kunnr,
        name1   LIKE  kna1-name1,
        zuonr   LIKE  bseg-zuonr,
        blart  	LIKE 	bsid-blart,
        bldat	  LIKE 	bsid-bldat,
        belnr	  LIKE 	bsid-belnr,
        zfbdt	  LIKE  bsid-zfbdt,
        wrbtr	  LIKE 	bsid-wrbtr,
        dudat   TYPE  zdudat,
        nottf   TYPE  znotf,
        tglttf  TYPE  ztgltf,
        ztext   TYPE  char50,
        zicon   TYPE  icon_d,
        chbox   TYPE  char1,
        chgrow  TYPE  char1,
*        change  TYPE  char1,
        celltab TYPE lvc_t_styl,
      END OF gt_out.

DATA: BEGIN OF gt_out2 OCCURS 0,
        bbeln      TYPE zbbeln_sfa,
        dcp        TYPE num6,
        sdate      TYPE sdate,
        parnr      TYPE parnr,
        sname      TYPE smnam,
        cnt_out    TYPE int1,
        cnt_dn     TYPE int4,
        amount     TYPE wrbtr,
        "        zicon      TYPE  icon_d,
        filenm_dwn TYPE char25,
        chbox      TYPE char1,
        celltab    TYPE lvc_t_styl,
      END OF gt_out2.

DATA: BEGIN OF gt_out7 OCCURS 0.
        INCLUDE STRUCTURE zfbih_sfa.
        DATA:   sname TYPE smnam,
        parvw TYPE char10,
        vbeln TYPE vbeln_vf,
        gjahr TYPE gjahr,
        zuonr TYPE dzuonr,
        fkdat TYPE fkdat,
        zfbdt TYPE dzfbdt,
        wrbtr TYPE zxx,                                     "zwert7,
        dudat TYPE zdudat,
        kunnr TYPE kunnr,
        name1 LIKE kna1-name1,
*        waers TYPE waers,
*        celltab TYPE lvc_t_styl,
      END OF gt_out7.

DATA: BEGIN OF gt_hdrdwn OCCURS 0,
        doctyp     TYPE char1,
        bukrs      TYPE char4,
        vkbur      TYPE char4,
        gsber      TYPE char4,
        bbeln      TYPE char7,
        bidat      TYPE char10,
        parnr      TYPE char10,
        dsp        TYPE char6,
        sdate      TYPE char10,
        receive_ke TYPE zreceive_ke,
      END OF gt_hdrdwn.

DATA: BEGIN OF gt_itmdwn OCCURS 0,
        doctyp TYPE char1,
        ebelp  TYPE char5,
        kunnr  TYPE char10,
        parvw  TYPE char10,
        blart  TYPE char2,
        zuonr  TYPE char18,
        zfbdt  TYPE char10,
        gjahr  TYPE char4,
        vbeln  TYPE char10,
        fkdat  TYPE char10,
        dudat  TYPE char10,
        wrbtr  TYPE char20,
        ztext  TYPE char50,
      END OF gt_itmdwn.

DATA: i_itab1  TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      i_itab1b TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      wa_itab1 TYPE t_itab1,
      i_itab2  TYPE t_itab1 OCCURS 0,
      i_itab3  TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      wa_itab3 TYPE t_itab1,
      i_itab6  TYPE t_itab1 OCCURS 0 WITH HEADER LINE,
      i_itab7  TYPE t_itab1 OCCURS 0 WITH HEADER LINE.

DATA: i_itab12  TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      wa_itab12 TYPE t_itab1,
      i_itab22  TYPE t_itab1 OCCURS 0,
      i_itab32  TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      wa_itab32 TYPE t_itab1,
      i_itab62  TYPE t_itab1 OCCURS 100 WITH HEADER LINE,
      i_itab72  TYPE t_itab1 OCCURS 100 WITH HEADER LINE.

DATA: i_bdc   TYPE t_bdc OCCURS 0,
      wa_bdc  TYPE t_bdc,
      messtab TYPE t_messtab OCCURS 0.

DATA: gs_bukrs TYPE char70,
      gs_vkbur TYPE char70,
      gs_pernr TYPE char70,
      gs_date  TYPE char70,
      gs_dcp   TYPE char70.

DATA gr_pernr TYPE RANGE OF zssutdt025-pernr WITH HEADER LINE.
DATA gr_sdate TYPE RANGE OF zssutdt025-sdate WITH HEADER LINE.
DATA gr_dcp   TYPE RANGE OF zssutdt025-daily_call_num WITH HEADER LINE.
DATA gr_bbeln TYPE RANGE OF zfbih_sfa-bbeln WITH HEADER LINE.
DATA gs_zsfafidt002 TYPE zsfafidt002.
DATA gt_zsfafidt002 TYPE TABLE OF zsfafidt002 WITH HEADER LINE.
DATA gt_zssutdt025 TYPE TABLE OF zssutdt025 WITH HEADER LINE.
DATA gt_zssutdt026 TYPE TABLE OF zssutdt026 WITH HEADER LINE.
DATA gt_zfbih_sfa  TYPE TABLE OF zfbih_sfa WITH HEADER LINE.
DATA gt_zfbid_sfa  TYPE TABLE OF zfbid_sfa WITH HEADER LINE.
DATA gt_zfbid_sfa2 TYPE TABLE OF zfbid_sfa WITH HEADER LINE.
DATA gt_zfbid_sfa3 TYPE TABLE OF zfbid_sfa WITH HEADER LINE.
DATA gt_zfh_kr1at  TYPE TABLE OF zfh_kr1at WITH HEADER LINE.
DATA gt_zfbid  TYPE TABLE OF zfbid WITH HEADER LINE.
DATA gt_pa0001 TYPE TABLE OF pa0001 WITH HEADER LINE.
DATA gt_channel TYPE TABLE OF zfsfa_channel WITH HEADER LINE.
DATA gt_jh TYPE TABLE OF zfsfa_jh WITH HEADER LINE.
DATA gt_kna1 TYPE TABLE OF kna1 WITH HEADER LINE.
DATA gt_bseg TYPE TABLE OF bseg WITH HEADER LINE.
DATA gt_vout LIKE TABLE OF gt_out WITH HEADER LINE.
DATA gt_out3 LIKE TABLE OF gt_out WITH HEADER LINE.
DATA gt_vout3 LIKE TABLE OF gt_out WITH HEADER LINE.
DATA gt_knvp1 TYPE TABLE OF knvp  WITH HEADER LINE.
DATA gt_knvp2 TYPE TABLE OF knvp  WITH HEADER LINE.
DATA gw_out LIKE gt_out.
DATA gv_bbeln TYPE zbbeln_sfa.
DATA va_bbeln TYPE zbbeln_sfa.
DATA gv_ready TYPE flag.
DATA gv_new   TYPE flag.
DATA gt_download TYPE truxs_t_text_data.
DATA gv_sdate TYPE sdate.
DATA gv_dcp   TYPE num6.
DATA gv_msgfl TYPE flag.

FIELD-SYMBOLS: <fs_out>  LIKE gt_out,
               <fs_out2> LIKE gt_out2,
               <fs_out7> LIKE gt_out7.

DATA : gt_bsid    TYPE STANDARD TABLE OF ty_bsid.
