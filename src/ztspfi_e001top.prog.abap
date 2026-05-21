*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005TOP                                              *
*----------------------------------------------------------------------*
  TABLES: sscrfields,ztspfidt01,ztspfidt02,mseg,mkpf,anlc.

  TYPE-POOLS: truxs.

  TYPES: BEGIN OF ty_upload.
          INCLUDE STRUCTURE ztspfist01.
  TYPES:  ktext   TYPE ktext,
         END OF ty_upload.

  TYPES: BEGIN OF ty_gr,
          werks   TYPE mseg-werks,
          matnr   TYPE mseg-matnr,
          menge   TYPE mseg-menge,
          meins   TYPE mseg-meins,
          konve   TYPE marm-umren,
          qtykonv TYPE mseg-menge,
          bobot   TYPE marm-umren,
          uombob  TYPE marm-meinh,
          qtybob  TYPE mseg-menge,
          fevor   TYPE marc-fevor,
         END OF ty_gr.

  TYPES: BEGIN OF ty_produce,
          fevor   TYPE marc-fevor,
          kostl   TYPE kostl,
          meins   TYPE zmeins,
          qty     TYPE menge_d,
         END OF ty_produce.

  TYPES: BEGIN OF ty_produce2,
          werks   TYPE mseg-werks,
          matnr   TYPE mseg-matnr,
          maktx   TYPE makt-maktx,
          spmon   TYPE spmon,
          fevor   TYPE marc-fevor,
          kostl   TYPE kostl,
          meins   TYPE zmeins,
          qty     TYPE menge_d,
         END OF ty_produce2.

  TYPES: BEGIN OF ty_out,
          spmon        TYPE spmon,
          bukrs        TYPE bukrs,
          anln1        TYPE anln1,
          anln2        TYPE anln2,
          bdatu        TYPE bdatu,
          adatu        TYPE adatu,
          kostl        TYPE kostl,
          gsber        TYPE gsber,
          ndjar        TYPE ndjar,
          aktiv        TYPE aktivd,
          zugdt        TYPE dzugdat,
          retire       TYPE datum,
          sisaumur     TYPE menge_d,
          kapasitas    TYPE zkapasitas,
          totkapasitas TYPE zkapasitas,
          bookval      TYPE kansw,
          depre        TYPE dec_16_03_s,
          qtyprod      TYPE menge_d,
          depreval     TYPE kansw,
          prevnbv      TYPE kansw,
          chkbox(1),
          style       TYPE lvc_t_styl,
          color       TYPE lvc_t_scol,
         END OF ty_out.

  CONSTANTS: gc_kokrs TYPE kokrs VALUE '8010'.

* Refrence Objects To Alv Grid & Custom Container Classes
  DATA: g_container TYPE scrfname VALUE 'CONTAINER',
        g_grid      TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
        g_custom_container TYPE REF TO cl_gui_custom_container,
        gt_fieldcat TYPE lvc_t_fcat WITH HEADER LINE,
        gt_sort     TYPE lvc_t_sort WITH HEADER LINE,
        gs_layout   TYPE lvc_s_layo,
        gv_repid    LIKE sy-repid,
        gs_variant  TYPE disvariant,
        gt_exclude  TYPE ui_functions,
        e_object    TYPE REF TO cl_alv_event_toolbar_set.

  DATA: gr_budat  TYPE RANGE OF budat     WITH HEADER LINE,
        gt_ztspfidt01 TYPE TABLE OF ztspfidt01 WITH HEADER LINE,
        gt_ztspfidt02 TYPE TABLE OF ztspfidt02 WITH HEADER LINE,
        gt_ztspfidt04 TYPE TABLE OF ztspfidt04 WITH HEADER LINE,
        gt_ztspfidt04upd  TYPE TABLE OF ztspfidt04 WITH HEADER LINE,
        gt_cskt   TYPE TABLE OF cskt      WITH HEADER LINE,
        gt_mseg   TYPE TABLE OF mseg      WITH HEADER LINE,
        gt_anla   TYPE TABLE OF anla      WITH HEADER LINE,
        gt_anlb   TYPE TABLE OF anlb      WITH HEADER LINE,
        gt_anlc   TYPE TABLE OF anlc      WITH HEADER LINE,
        gt_anlc2  TYPE TABLE OF anlc      WITH HEADER LINE, "Current year
        gt_anlc3  TYPE TABLE OF anlc      WITH HEADER LINE,
        gt_anep   TYPE TABLE OF anep      WITH HEADER LINE,
        gt_anlz   TYPE TABLE OF anlz      WITH HEADER LINE,
        gt_gr     TYPE TABLE OF ty_gr     WITH HEADER LINE,
        gt_out    TYPE TABLE OF ty_out    WITH HEADER LINE,
        gt_upload TYPE TABLE OF ty_upload WITH HEADER LINE,
        gt_produce TYPE TABLE OF ty_produce WITH HEADER LINE,
        gt_produce2 TYPE TABLE OF ty_produce2 WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_upload>  TYPE ty_upload,
                 <fs_gr>      TYPE ty_gr,
                 <fs_out>     TYPE ty_out.

  DATA : gt_error   TYPE STANDARD TABLE OF bapiret2,
         dynlog     TYPE smp_dyntxt.
