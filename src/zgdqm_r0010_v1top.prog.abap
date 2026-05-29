*----------------------------------------------------------------------*
*   INCLUDE ZGDQM_R0010_V1TOP                                          *
*----------------------------------------------------------------------*
TYPE-POOLS: soi.
TYPE-POOLS: sydes.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: qals, plmk, sscrfields, aufk.

TYPES : type_doc(64).

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONTROLS: exceldata1    TYPE TABLEVIEW USING SCREEN 0101.

DATA: rows_number       TYPE i,
      columns_number    TYPE i,
      excel_input       TYPE soi_generic_table,
      rangeitem         TYPE soi_range_item,
      errors            TYPE REF TO i_oi_error OCCURS 0
                        WITH HEADER LINE,
      excel_input_wa    TYPE soi_generic_item,
      ranges            TYPE soi_range_list,
      contents          TYPE soi_generic_table,
      rangesdef         TYPE soi_dimension_table,
      struc_generic     TYPE soi_generic_item,
      struc_rangesdef   TYPE soi_dimension_item,
      row(4),
      column(4),
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
*      ranges            TYPE REF TO i_oi_spreadsheet.

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
      has_changed TYPE i,
      is_created.

DATA: va_name1  LIKE rcgmjiot-wrknam,
      va_maktx  LIKE rcgmjiot-matnam,
      va_period(50),
      va_message(50),
      va_error  TYPE i,
      va_switch TYPE i,
      va_lines  TYPE i.

RANGES: ra_stprplan FOR qdsv-stprplan.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_caufv OCCURS 0.
        INCLUDE STRUCTURE caufv.
DATA: END OF t_caufv.

DATA: BEGIN OF t_qals OCCURS 0.
        INCLUDE STRUCTURE qals.
DATA: END OF t_qals.
DATA: BEGIN OF t_qals1 OCCURS 0.
        INCLUDE STRUCTURE qals.
DATA: END OF t_qals1.
DATA: BEGIN OF t_qals2 OCCURS 0.
        INCLUDE STRUCTURE qals.
DATA: END OF t_qals2.

DATA: BEGIN OF t_plas OCCURS 0.
        INCLUDE STRUCTURE plas.
DATA: END OF t_plas.

DATA: BEGIN OF t_plmk OCCURS 0.
        INCLUDE STRUCTURE plmk.
DATA: vornr  LIKE plpo-vornr.
DATA: END OF t_plmk.

DATA: BEGIN OF t_plpo OCCURS 0.
        INCLUDE STRUCTURE plpo.
DATA: END OF t_plpo.

DATA: BEGIN OF t_stichprver OCCURS 0.
        INCLUDE STRUCTURE plmk.
DATA: END OF t_stichprver.

DATA: BEGIN OF t_qdsv OCCURS 0.
        INCLUDE STRUCTURE qdsv.
DATA: END OF t_qdsv.

DATA: BEGIN OF t_qals_04 OCCURS 0.
        INCLUDE STRUCTURE qals.
DATA: END OF t_qals_04.

DATA: BEGIN OF t_charg OCCURS 0.
        INCLUDE STRUCTURE t_qals.
DATA: END OF t_charg.

DATA: BEGIN OF t_lifnr OCCURS 0.
        INCLUDE STRUCTURE t_qals.
DATA: END OF t_lifnr.

DATA: BEGIN OF t_lfa1 OCCURS 0.
        INCLUDE STRUCTURE lfa1.
DATA: END OF t_lfa1.

DATA: BEGIN OF t_mblnr OCCURS 0.
        INCLUDE STRUCTURE t_qals.
DATA: END OF t_mblnr.

DATA: BEGIN OF t_mseg OCCURS 0,
        mblnr  LIKE mseg-mblnr,
        erfmg  LIKE mseg-erfmg,
        erfme  LIKE mseg-erfme.
DATA: END OF t_mseg.

DATA: BEGIN OF t_mkpf OCCURS 0.
        INCLUDE STRUCTURE mkpf.
DATA: END OF t_mkpf.

DATA: BEGIN OF t_mch1 OCCURS 0.
        INCLUDE STRUCTURE mch1.
DATA: END OF t_mch1.

DATA: BEGIN OF t_qdpa OCCURS 0.
        INCLUDE STRUCTURE qdpa.
DATA: END OF t_qdpa.

DATA: BEGIN OF t_qave OCCURS 0.
        INCLUDE STRUCTURE qave.
DATA: END OF t_qave.

DATA: BEGIN OF t_qamv OCCURS 0.
        INCLUDE STRUCTURE qamv.
DATA: END OF t_qamv.

DATA: BEGIN OF t_qasv OCCURS 0.
        INCLUDE STRUCTURE qasv.
DATA: END OF t_qasv.

DATA: BEGIN OF t_qapp OCCURS 0.
        INCLUDE STRUCTURE qapp.
DATA: END OF t_qapp.

DATA: BEGIN OF t_qamr OCCURS 0.
        INCLUDE STRUCTURE qamr.
DATA: END OF t_qamr.

DATA: BEGIN OF t_qasr OCCURS 0.
        INCLUDE STRUCTURE qasr.
DATA: END OF t_qasr.

DATA: BEGIN OF t_qase OCCURS 0.
        INCLUDE STRUCTURE qase.
DATA: END OF t_qase.

DATA: BEGIN OF t_qcpr OCCURS 0.
        INCLUDE STRUCTURE qcpr.
DATA: END OF t_qcpr.

DATA: BEGIN OF t_header OCCURS 0,
        vornr       LIKE plpo-vornr,
        merknr      LIKE plmk-merknr,
        verwmerkm   LIKE qamv-verwmerkm,
        kurztext    LIKE qamv-kurztext,
        masseinhsw  LIKE qamv-masseinhsw,
        sollwert    LIKE qamv-sollwert,
        toleranzun  LIKE qamv-toleranzun,
        toleranzob  LIKE qamv-toleranzob,
        sollwert_c(22),
        toleranzun_c(22),
        stellen(3),
        toleranzob_c(22),
        result(50).
DATA: END OF t_header.

DATA: BEGIN OF t_vdata OCCURS 0.
DATA: budat(10),
      budat1(10),
      mblnr       LIKE qals-mblnr,
      lichn       LIKE qals-lichn,
      charg       LIKE qals-charg,
      losmenge    LIKE qals-losmenge,
      mengeneinh  LIKE qals-mengeneinh,
      lifnr       LIKE qals-lifnr,
      anzgeb      LIKE qals-anzgeb,
      prueflos    LIKE qals-prueflos,
      paendterm   LIKE qals-paendterm,
      ktextlos(105),
      lmenge01    LIKE qals-lmenge01,
      lmenge03    LIKE qals-lmenge03,
      lmenge04    LIKE qals-lmenge04,
      ersteldat(10),
      pruefdatuv(10),
      plnty       LIKE qals-plnty,
      plnnr       LIKE qals-plnnr,
      gesstichpr  LIKE qals-gesstichpr,
      einhprobe   LIKE qals-einhprobe,
      aufnr       LIKE qals-aufnr,
      art         LIKE qals-art,
      erfmg       LIKE mseg-erfmg,
      erfme       LIKE mseg-erfme,
      name1       LIKE lfa1-name1,
      vfdat1(10),
      qndat(10),
      hsdat(10),
      vdatum1(10),
      vdatum2(10),
      status(60),
      udstat(60).
DATA: END OF t_vdata.

DATA: BEGIN OF t_result OCCURS 0.
DATA:   prueflos  LIKE qals-prueflos,
        column    TYPE i,
        row       TYPE i,
        result(50).
DATA: END OF t_result.
