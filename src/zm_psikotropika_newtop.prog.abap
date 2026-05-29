*----------------------------------------------------------------------*
*   INCLUDE ZM_PSIKOTROPIKA_CSVTOP
*----------------------------------------------------------------------*
*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
  TABLES : sscrfields, s031.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
  CONSTANTS : gc_delim    TYPE zdelim VALUE ';',
              _1000       TYPE lgort_d VALUE '1000',
              con_tab     TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.

  DATA : gv_path      TYPE string,
         gv_filename  TYPE string,
         gv_files(20).

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
  DATA : BEGIN OF gt_tvkol OCCURS 0,
           vstel  TYPE vstel,
           werks  TYPE werks_d,
           lgort  TYPE lgort_d,
         END OF gt_tvkol.

  DATA : BEGIN OF gt_mara OCCURS 0,
           matnr  TYPE matnr,
           meins  TYPE meins,
         END OF gt_mara.

  DATA : BEGIN OF gt_mch1 OCCURS 0,
           matnr  TYPE matnr,
           charg  TYPE charg_d,
           vfdat  TYPE vfdat,
         END OF gt_mch1.

*DATA : BEGIN OF gt_wlc OCCURS 0,
*         matnr  TYPE matnr,
*         charg  TYPE charg_d,
*         vfdat  TYPE vfdat,
*         werks  TYPE werks_d,
*         lgort  TYPE lgort_d,
*       END OF gt_wlc.

  DATA : BEGIN OF gt_stock OCCURS 0,
           matnr  TYPE matnr,
           werks  TYPE werks_d,
           lgort  TYPE lgort_d,
           charg  TYPE charg_d,
           lfgja  TYPE lfgja,
           lfmon  TYPE lfmon,
           clabs  TYPE labst,
           cinsm  TYPE insme,
           cspem  TYPE speme,
         END OF gt_stock.

  DATA : BEGIN OF gt_trans OCCURS 0,
           charg  TYPE charg_d,
           in     TYPE labst,
           out    TYPE labst,
         END OF gt_trans.

  DATA : BEGIN OF gt_key OCCURS 0,
           matnr  TYPE matnr,
           werks  TYPE werks_d,
           lgort  TYPE lgort_d,
           bwart  TYPE bwart,
         END OF gt_key.

  DATA : BEGIN OF gt_mkpf OCCURS 0,
           mblnr  TYPE mblnr,
           mjahr  TYPE mjahr,
           budat  TYPE budat,
           bldat  TYPE bldat,
           xblnr  TYPE xblnr,
         END OF gt_mkpf.

  DATA : BEGIN OF gt_kna1 OCCURS 0,
           kunnr    TYPE kunnr,
           name1    TYPE name1_gp,
           name_co  TYPE ad_name_co,
           name4    TYPE name4_gp,
         END OF gt_kna1.

  DATA : BEGIN OF gt_ekpo OCCURS 0,
           ebeln  TYPE ebeln,
           ebelp  TYPE ebelp,
           werks  TYPE werks_d,
           lgort  TYPE lgort_d,
         END OF gt_ekpo.

*DATA : BEGIN OF gt_mseg1 OCCURS 0,
*         mblnr  TYPE mblnr,
*         mjahr  TYPE mjahr,
*         werks  TYPE werks_d,
*         lgort  TYPE lgort_d,
*       END OF gt_mseg1.
*DATA : gt_mseg2 LIKE gt_mseg1 OCCURS 0 WITH HEADER LINE,
*       gt_mseg3 LIKE gt_mseg1 OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF gt_mseg OCCURS 0,
          mblnr	TYPE mblnr,
          mjahr	TYPE mjahr,
          zeile	TYPE posnr_nach,    "mblpo,
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

  DATA: gv_bukrs    TYPE bukrs,
        gr_bwart    TYPE RANGE OF bwart   WITH HEADER LINE,
        gr_bwartin  TYPE RANGE OF bwart   WITH HEADER LINE,
        gr_bwartout TYPE RANGE OF bwart   WITH HEADER LINE,
        gr_werks    TYPE RANGE OF werks_d WITH HEADER LINE,
        gr_lgort    TYPE RANGE OF lgort_d WITH HEADER LINE,
        gr_budat    TYPE RANGE OF budat   WITH HEADER LINE,
        gr_charg    TYPE RANGE OF charg_d WITH HEADER LINE,
        gt_opnstk   TYPE TABLE OF zmmst_opnstk WITH HEADER LINE,
        gt_vbfa     TYPE TABLE OF vbfa    WITH HEADER LINE.

  DATA: gt_t001l TYPE TABLE OF t001l WITH HEADER LINE,
        gt_lfa1  TYPE TABLE OF lfa1  WITH HEADER LINE,
        gt_ekko  TYPE TABLE OF ekko  WITH HEADER LINE,
        gt_t001w TYPE TABLE OF t001w WITH HEADER LINE,
        gt_lfa1_101  TYPE TABLE OF lfa1  WITH HEADER LINE,
        gt_kna1_655  TYPE TABLE OF kna1  WITH HEADER LINE,
        gt_mseg_305  TYPE TABLE OF mseg  WITH HEADER LINE,
        gt_mseg_641  TYPE TABLE OF mseg  WITH HEADER LINE.

  DATA: BEGIN OF gt_out OCCURS 0,
          norut   TYPE int3,
          budat   TYPE budat,
          matnr   TYPE matnr,
          meins   TYPE meins,
          salaw   TYPE labst,
          sawchg  TYPE charg_d,
          indoc   TYPE mblnr,
          intxt   TYPE text50,
          inqty   TYPE menge_d,
          inchg   TYPE charg_d,
          incode  TYPE char10,
          outdoc  TYPE mblnr,
          outtxt  TYPE text50,
          outqty  TYPE menge_d,
          outchg  TYPE charg_d,
          outcode TYPE char10,
          salak   TYPE labst,
          sakchg  TYPE charg_d,
          vfdat   TYPE vfdat,
          werks   TYPE werks_d,
          lgort   TYPE lgort_d,
          vkbur   TYPE vkbur,
        END OF gt_out.

  DATA : BEGIN OF gt_download OCCURS 0,
           fieldline(15000),
         END OF gt_download.

  DATA : BEGIN OF gt_temp OCCURS 0,
            fieldline(15000),
         END OF gt_temp.

  DATA : wa_out   LIKE zmpsiko_csv.

  FIELD-SYMBOLS: <fs_out> LIKE gt_out.

  CONSTANTS: gc_tcode TYPE tcode VALUE 'ZM23CN'.
