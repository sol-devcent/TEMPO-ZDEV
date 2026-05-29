*----------------------------------------------------------------------*
*   INCLUDE ZPM_BREAKDOWNTOP                                           *
*----------------------------------------------------------------------*
TYPE-POOLS: soi.
TYPE-POOLS: sydes.
TYPE-POOLS: gfw.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: sscrfields, itob, bsis.

TYPES : type_doc(64).

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: rows_number       TYPE i,
      columns_number    TYPE i,
      errors            TYPE REF TO i_oi_error OCCURS 0
                        WITH HEADER LINE,
      ranges            TYPE soi_range_list,
      contents          TYPE soi_generic_table,
      rangesdef         TYPE soi_dimension_table,
      struc_generic     TYPE soi_generic_item,
      struc_rangesdef   TYPE soi_dimension_item,
      data(256),
      count             TYPE i.

* Container object to provide an area
DATA: container         TYPE REF TO cl_gui_custom_container.
* Central Object of the Office integration
DATA: control           TYPE REF TO i_oi_container_control.
* Object variable for the MS Office document
DATA: document          TYPE REF TO i_oi_document_proxy.
* Objet variable for the MS Excel document # control document
DATA: sheet_interface   TYPE REF TO i_oi_spreadsheet.
* Object for the Business Document
DATA: bds_doc           TYPE REF TO cl_bds_document_set.
* Object for the link server
DATA: link_server       TYPE REF TO i_oi_link_server.
* Auto. Queue to sent to presentation server, #X# : Not sent directly
DATA: no_flush,
* Storage for error messages
      error             TYPE REF TO i_oi_error,
* Message result
      retcode(256)      TYPE c.

* SOI_DOCTYPE_WORD_DOCUMENT = Word.Document, see Type pools SOI
DATA: document_type(80) VALUE soi_doctype_excel_sheet,
      document_format(6),
      doc_url           TYPE bapiuri-uri. "MSDocument URL Address

* Error Handling after call a method
CLASS c_oi_errors DEFINITION LOAD.
* IDs:
DATA: doc_classname     TYPE sbdst_classname,
      doc_classtype     TYPE sbdst_classtype,
      doc_object_key    TYPE sbdst_object_key,
      doc_mimetype      LIKE bapicompon-mimetype.

*document description for getting business doc object
DATA: is_output,
      is_created.

RANGES: ra_ausbs  FOR viqmel-ausbs.

DATA: va_jam(10),
      va_menit(4),
      va_kasus(5),
      va_mesin(10),
      va_period(6),
      va_kerja(10),
      va_percen(10),
      va_datum  LIKE sy-datum,
      va_times  TYPE i.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_viqmel OCCURS 0.
        INCLUDE STRUCTURE viqmel.
DATA: END OF t_viqmel.

DATA: BEGIN OF t_eqkt OCCURS 0.
        INCLUDE STRUCTURE eqkt.
DATA: END OF t_eqkt.

DATA: BEGIN OF t_itob OCCURS 0.
        INCLUDE STRUCTURE itob.
DATA: END OF t_itob.

DATA: BEGIN OF t_afko OCCURS 0,
        aufnr  LIKE afko-aufnr,
        aufpl  LIKE afko-aufpl,
        aplzl  LIKE afvc-aplzl,
        ltxa1  LIKE afvc-ltxa1,
        vornr  LIKE afvc-vornr.
DATA: END OF t_afko.

DATA: BEGIN OF t_caufv OCCURS 0,
        aufnr  LIKE afko-aufnr,
        rsnum  LIKE resb-rsnum,
        vornr  LIKE afvc-vornr,
        posnr  LIKE resb-posnr,
        meins  LIKE resb-meins,
        bdmng  LIKE resb-bdmng,
        maktx  LIKE makt-maktx.
DATA: END OF t_caufv.

DATA: BEGIN OF t_vdata OCCURS 0,
        qmnum  LIKE viqmel-qmnum,
        aufnr  LIKE afko-aufnr,
        aufpl  LIKE afko-aufpl,
        aplzl  LIKE afvc-aplzl,
        strmn  LIKE viqmel-strmn,
        strur  LIKE viqmel-strur,
        ausbs  LIKE viqmel-ausbs,
        auztb  LIKE viqmel-auztb,
        maueh  LIKE viqmel-maueh,
        auszt  LIKE viqmel-auszt,
        pltxt  LIKE iflotx-pltxt,
        eqktx  LIKE eqkt-eqktx,
        qmtxt  LIKE viqmel-qmtxt,
        ltxa1  LIKE afvc-ltxa1,
        vornr  LIKE afvc-vornr,
        rsnum  LIKE resb-rsnum,
        posnr  LIKE resb-posnr,
        meins  LIKE resb-meins,
        bdmng  LIKE resb-bdmng,
        maktx  LIKE makt-maktx,
        jam(10),
        menit(4).
DATA: END OF t_vdata.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE t_vdata.
DATA: END OF t_out.

DATA: BEGIN OF t_radio3 OCCURS 0.
        INCLUDE STRUCTURE zpmstbd.
DATA: END OF t_radio3.
