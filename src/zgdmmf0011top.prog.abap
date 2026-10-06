*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0011TOP
*----------------------------------------------------------------------*
  TABLES: *nast,
          nast,
          tnapr,
          lfa1,
          ekko,
          t001w,
          t685t,
          mara,
          usr21,
          adrp.
  DATA  d_retcode LIKE sy-subrc.

  TABLES: komk    ,
          komvd   ,
          vbdre   .

  DATA: xscreen(1) TYPE c.

  DATA: i_nast    TYPE nast OCCURS 0,
        wa_nast   TYPE nast.

  DATA: wa_hd     TYPE zgdmmst0001,
        wa_deliv  TYPE adrc,
        i_dt      TYPE zgdmmst0011 OCCURS 0,
        wa_dt     TYPE zgdmmst0011,
        wa_dt2    TYPE zgdmmst0011,
        wa_dt3    TYPE zgdmmst0011,
        wa_ekpo   TYPE ekpo,
        wa_ekkn   TYPE ekkn,
        wa_eket   TYPE eket,
        xmmpa     TYPE mmpa OCCURS 0,
        t_konv TYPE konv.

  DATA: BEGIN OF t_eban OCCURS 0,
          banfn   LIKE eban-banfn,
          bnfpo   LIKE eban-bnfpo,
          bednr   LIKE eban-bednr.
  DATA: END OF t_eban.
  DATA: BEGIN OF t_banfn OCCURS 0.
          INCLUDE STRUCTURE t_eban.
  DATA: END OF t_banfn.
  DATA: BEGIN OF t_bednr OCCURS 0.
          INCLUDE STRUCTURE t_eban.
  DATA: END OF t_bednr.

  DATA: BEGIN OF t_ebkn OCCURS 0,
          banfn   LIKE ebkn-banfn,
          bnfpo   LIKE ebkn-bnfpo,
          ablad   LIKE ebkn-ablad.
  DATA: END OF t_ebkn.

  TYPES: BEGIN OF ta_nomon,
           nomon   TYPE char40,
         END OF ta_nomon.
  DATA: i_nomon  TYPE ta_nomon OCCURS 0,
        wa_nomon TYPE ta_nomon.

  DATA: l_name(70),
        l_lines  LIKE tline OCCURS 0,
        wa_lines LIKE tline.

  DATA: va_kwert     LIKE konv-kwert,
        va_absol     LIKE konv-kbetr,
        va_absolper  LIKE konv-kbetr,
        va_ppn01     LIKE konv-kbetr,
        va_ppnval    LIKE konv-kwert,
        va_kschl     LIKE konv-kschl,
        va_vtext     LIKE t685t-vtext,
        va_kunnr     LIKE kna1-kunnr,
        va_stceg     LIKE kna1-stceg,
        va_revisi    TYPE i,
        va_rev       TYPE char30,
        va_import    TYPE i,
        va_tax       TYPE i,
        va_sign      TYPE i.

  DATA : va_rqident  TYPE tsp01-rqident.

  TYPE-POOLS: meein.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print,
        l_doc1  TYPE meein_purchase_doc_print.

  DATA : gt_zmmprnt TYPE STANDARD TABLE OF zmmprnt,
         gs_zmmprnt TYPE zmmprnt.

  DATA : it_attach TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0
                   WITH HEADER LINE.
  DATA : it_message TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0
                    WITH HEADER LINE.

  DATA : gt_ekko  TYPE STANDARD TABLE OF ekko INITIAL SIZE 0 WITH HEADER LINE,
         gs_ekko  TYPE ekko,
         gt_ekpo  TYPE STANDARD TABLE OF ekpo INITIAL SIZE 0 WITH HEADER LINE,
         gt_eket  TYPE STANDARD TABLE OF eket INITIAL SIZE 0 WITH HEADER LINE,
         gt_a934  TYPE STANDARD TABLE OF a934 INITIAL SIZE 0 WITH HEADER LINE,
         gt_konp  TYPE STANDARD TABLE OF konp INITIAL SIZE 0 WITH HEADER LINE.

  DATA : xlsstr   TYPE i,
         xlsend   TYPE i,
         pdfstr   TYPE i,
         pdfend   TYPE i.
