*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_F0013TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,zfbid,zfbih,zfbid_sfa,zfbih_sfa,zfbic_sfa.

TYPE-POOLS: truxs.

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
        bukrs          TYPE bukrs,
        vkbur          TYPE vkbur,
        bbeln          TYPE zbbeln_sfa,
        sfa            TYPE char1,
        bidat          TYPE zbidat,
        zuonr	         TYPE dzuonr,
        fkdat	         TYPE fkdat,
        kunnr	         TYPE kunnr,
        name1	         TYPE name1_gp,
        wrbtr	         TYPE zwert7,
        waers	         TYPE waers,
        bflag          TYPE char1,
        pstat          TYPE char1,
        ptype          TYPE char1,
        parvw          TYPE char10,
        usna1          TYPE ernam,
        erzet          TYPE erzet,
        erdt1          TYPE erdat,
        usna2          TYPE usnam,
        erzet2         TYPE erzet,
        erdt2          TYPE aedat,
        slcod          TYPE zslcod,
        zfbdt          TYPE dzfbdt,
        inp_cash       TYPE zwert7,
        inp_trnsfr     TYPE zwert7,
        inp_giro       TYPE zwert7,
        inp_cash_cn    TYPE zwert7,
        inp_trnsfr_cn  TYPE zwert7,
        inp_cash_exp   TYPE zwert7,
        inp_trnsfr_exp TYPE zwert7,
        nottf          TYPE znotf,
        tglttf         TYPE ztgltf,
        amtttf         TYPE zamtttf,
        inp_fkb_amt    TYPE zwert7,
        inp_fkb_ket    TYPE char20,
        vchr_cr        TYPE zvchrcashrec,
        vchr_br        TYPE zvchrbankrec,
        usnam_post     TYPE char25,
        erdat_post     TYPE udate,
        erzet_post     TYPE uzeit,
        postdoc1       TYPE zpostdoc1,
        postdoc2       TYPE zpostdoc2,
        daily_call_num TYPE num6,
        sdate          TYPE sdate,
        usnam_rel      TYPE char25,
        erdat_rel      TYPE udate,
        erzet_rel      TYPE uzeit,
        usnam_unrel    TYPE char25,
        erdat_unrel    TYPE udate,
        erzet_unrel    TYPE uzeit.
*        chbox       TYPE char1,
*        celltab     TYPE lvc_t_styl,
DATA: END OF gt_out.

DATA: BEGIN OF gt_out2 OCCURS 0,
        bukrs      TYPE bukrs,
        vkbur      TYPE vkbur,
        bbeln      TYPE zbbeln_sfa,
        bidat      TYPE sy-datum,
        sfa        TYPE char1,
        gjahr      TYPE gjahr,
        ba         TYPE zba,
        kunnr	     TYPE kunnr,
        name1	     TYPE name1_gp,
        zfbdt      TYPE dzfbdt,
        bank_check TYPE char10,
        bank_name  TYPE char12,
        vbeln      TYPE vbeln_vf,
        zuonr      TYPE dzuonr,
        slcod      TYPE zslcod,
        bank_dudat TYPE datum,
        nocairb    TYPE znocair,
        nocairc    TYPE znocair,
        vchr_br    TYPE zvchrbankrec,
        hkontbank  TYPE zhkontbank,
        pcair      TYPE zpcair,
        usna1      TYPE usnam,
        erdt1      TYPE erdat,
        usna2      TYPE usnam,
        erdt2      TYPE erdat,
        amount     TYPE zwert7,
        bank_amt   TYPE zwert7,
        zeile      TYPE zeile,
        seqno      TYPE char2,
        postdoc1   TYPE zpostdoc1.
*        chbox       TYPE char1,
*        celltab     TYPE lvc_t_styl,
DATA: END OF gt_out2.

DATA gt_makt  TYPE TABLE OF makt WITH HEADER LINE.
DATA gt_zfbih TYPE TABLE OF zfbih WITH HEADER LINE.
DATA gt_zfbid TYPE TABLE OF zfbid WITH HEADER LINE.
DATA gt_zfbicheck TYPE TABLE OF zfbicheck WITH HEADER LINE.
DATA gt_kna1  TYPE TABLE OF kna1 WITH HEADER LINE.
DATA gt_kna1sfa TYPE TABLE OF kna1 WITH HEADER LINE.
DATA gt_zfbihsfa TYPE TABLE OF zfbih_sfa WITH HEADER LINE.
DATA gt_zfbidsfa TYPE TABLE OF zfbid_sfa WITH HEADER LINE.
DATA gt_zfbidpsfa TYPE TABLE OF zfbidp_sfa WITH HEADER LINE.
DATA gt_zfbicsfa TYPE TABLE OF zfbic_sfa WITH HEADER LINE.

FIELD-SYMBOLS: <fs_out>  LIKE gt_out,
               <fs_out2> LIKE gt_out2.
