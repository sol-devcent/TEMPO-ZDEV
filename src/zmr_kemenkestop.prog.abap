*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP
*----------------------------------------------------------------------*
TYPE-POOLS: p99sg,vrm.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: mardh,mard,bkpf,mkpf,mseg.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
*CONSTANTS: gc_lgort LIKE mseg-lgort VALUE '3000'.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_makt OCCURS 0,
        matnr TYPE matnr,
        maktx TYPE maktx,
        meins TYPE meins,
        normt	TYPE normt,
      END   OF gt_makt.
DATA: gt_makt2 LIKE gt_makt OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_mseg OCCURS 0,
        mblnr	TYPE mblnr,
        mjahr	TYPE mjahr,
        zeile	TYPE mblpo,
        line_id TYPE mb_line_id,
        parent_id TYPE mb_parent_id,
        bwart	TYPE bwart,
        xauto	TYPE mb_xauto,
        matnr	TYPE matnr,
        werks	TYPE werks_d,
        lgort	TYPE lgort_d,
        charg	TYPE charg_d,
        lifnr	TYPE elifn,
        kunnr	TYPE ekunn,
        menge	TYPE menge_d,
        meins	TYPE meins,
        ebeln	TYPE bstnr,
        ebelp	TYPE ebelp,
        sjahr	TYPE mjahr,
        smbln	TYPE mblnr,
        smblp	TYPE mblpo,
        elikz	TYPE elikz,
        sgtxt	TYPE sgtxt,
        shkzg TYPE shkzg,
        budat TYPE budat,
        xblnr TYPE xblnr1,
        wempf TYPE wempf,
        grund TYPE mb_grbew,
        umwrk TYPE umwrk,
        umlgo TYPE umlgo,
        flag  TYPE char1,
      END OF gt_mseg.

DATA: BEGIN OF gw_header,
        bukrs TYPE bukrs,
        butxt TYPE butxt,
        werks TYPE werks_d,
        name1 TYPE name1,
        adrnr TYPE adrnr,
        name3 TYPE ad_name3,
        gjahr TYPE gjahr,
        quart TYPE char50,
      END OF gw_header.

DATA: BEGIN OF gt_bpom OCCURS 0,
        matnr          TYPE matnr,
        bets           TYPE charg_d,
        norut          TYPE numc3,
        komposisi	     TYPE zkompos,
        maktx          TYPE maktx,
        btk_sedia	     TYPE zsedia,
        kekuatan_sedia TYPE zkekuatan,
        kemasan        TYPE zkemasan,
        vfdat          TYPE vfdat,
        lifnr          TYPE lifnr,
        name1          TYPE name1,
        saw_jumlah     TYPE menge_d,
        in_jumlah      TYPE menge_d,
        in_name1       TYPE name1,
        in_code        TYPE char10,
        out_jumlah     TYPE menge_d,
        out_name1      TYPE name1,
        out_code       TYPE char10,
        sak_jumlah     TYPE menge_d,
        ket            TYPE char30,
        meins          TYPE meins,
      END OF gt_bpom.

DATA: BEGIN OF gt_kemenkes OCCURS 0,
        matnr          TYPE matnr,
*        bets           TYPE charg_d,
        norut          TYPE numc3,
        nie            TYPE znie,
        maktx          TYPE maktx,
        maktx2         TYPE maktx,
        meins          TYPE meins,
        kemasan        TYPE zkemasan,
        saw_jumlah     TYPE menge_d,
*        vfdat          TYPE vfdat,
        in_name1       TYPE name1_gp,
        in_ket         TYPE char30,
        in_code        TYPE char10,
        in_pabrik      TYPE menge_d,
        in_pabrik_code TYPE char10,
        in_pabrik_name TYPE char40,
        in_pbf         TYPE menge_d,
        in_pbf_code    TYPE char10,
        in_pbf_name    TYPE char40,
        in_retur       TYPE menge_d,
        in_other       TYPE menge_d,
        out_rs         TYPE menge_d,
        out_apotek     TYPE menge_d,
        out_pbf        TYPE menge_d,
        out_pbf_code   TYPE char10,
        out_pbf_name   TYPE char40,
        out_dinkes     TYPE menge_d,
        out_puskesmas  TYPE menge_d,
        out_klinik     TYPE menge_d,
        out_tobat      TYPE menge_d,
        out_retur      TYPE menge_d,
        out_other      TYPE menge_d,
        out_name1      TYPE name1,
        out_ket        TYPE name1,
        out_code       TYPE char10,
        nilai          TYPE stprs,
        sak_jumlah     TYPE menge_d,
      END OF gt_kemenkes.

DATA: BEGIN OF gt_a510 OCCURS 0,
        matnr TYPE matnr,
        knumh TYPE knumh,
      END OF gt_a510 .

DATA: gt_t001l TYPE TABLE OF t001l WITH HEADER LINE,
      gt_lfa1  TYPE TABLE OF lfa1  WITH HEADER LINE,
      gt_konp  TYPE TABLE OF konp  WITH HEADER LINE,
      gt_ekko  TYPE TABLE OF ekko  WITH HEADER LINE,
      gt_t001w TYPE TABLE OF t001w WITH HEADER LINE,
      gt_lfa1_101  TYPE TABLE OF lfa1  WITH HEADER LINE,
      gt_kna1_655  TYPE TABLE OF kna1  WITH HEADER LINE,
      gt_mseg_305  TYPE TABLE OF mseg  WITH HEADER LINE,
      gt_mseg_641  TYPE TABLE OF mseg  WITH HEADER LINE,
      gt_ztspmmdt002 TYPE TABLE OF ztspmmdt002 WITH HEADER LINE,
      gt_ztspmmdt003 TYPE TABLE OF ztspmmdt003 WITH HEADER LINE,
      gt_ztspmmdt003in TYPE TABLE OF ztspmmdt003 WITH HEADER LINE,
      gt_ztspmmdt003out TYPE TABLE OF ztspmmdt003 WITH HEADER LINE,
      gt_ztspmmdt005 TYPE TABLE OF ztspmmdt005 WITH HEADER LINE.

DATA: gr_in   TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out  TYPE RANGE OF bwart WITH HEADER LINE,
      gr_in0  TYPE RANGE OF bwart WITH HEADER LINE,
      gr_in1  TYPE RANGE OF bwart WITH HEADER LINE,
      gr_in2  TYPE RANGE OF bwart WITH HEADER LINE,
      gr_in9  TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out0 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out1 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out2 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out3 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out4 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out5 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out6 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out7 TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out9 TYPE RANGE OF bwart WITH HEADER LINE.

DATA: gt_opnstk   TYPE zmmtt_opnstk,
      gw_opnstk   LIKE LINE OF gt_opnstk,
      gt_opnstk2  TYPE zmmtt_opnstk,
      gw_opnstk2  LIKE LINE OF gt_opnstk2,
      gw_quarter  TYPE p99sg_quarter.

DATA: lo_excel             TYPE REF TO zcl_excel,
      lo_worksheet         TYPE REF TO zcl_excel_worksheet,
      lo_style_right       TYPE REF TO zcl_excel_style,
      ls_table_settings    TYPE zexcel_s_table_settings,
      lv_style_right_guid  TYPE zexcel_cell_style,
      column_dimension     TYPE REF TO zcl_excel_worksheet_columndime.

DATA: gt_zmmst_bpom TYPE TABLE OF zmmst_bpom,
      gs_zmmst_bpom LIKE LINE OF gt_zmmst_bpom,
      gt_zmmst_kemenkes TYPE TABLE OF zmmst_kemenkes2,
      gs_zmmst_kemenkes LIKE LINE OF gt_zmmst_kemenkes.

FIELD-SYMBOLS: <fs_bpom>     LIKE gt_bpom,
               <fs_kemenkes> LIKE gt_kemenkes.
