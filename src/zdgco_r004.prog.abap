*&----------------------------------------------------------------------------*
*& D R A G O N   G L O R Y   P R O J E C T
*&----------------------------------------------------------------------------*
*& RICEF ID              : RCO-13
*& Title                 : COGS Flow Material Report
*& Functional Designer   : Amirullah Amaludin
*& ABAP Developer        : Samanta Limbrada
*& Initial Creation Date : 18.09.2012
*&
*& Overview: (paste business requirement from FuncSpec here)
*& Display detail cost of goods sold flow from raw and packaging material to
*& finished goods with Beginning, Receipt, Consumption, and Ending position.
*&
*& Laporan ini dibutuhkan untuk analisis cost accounting terhadap mutasi
*& inventory semua material RS (raw material, packaging material, semifinished goods,
*& finished goods) mulai dari beginning, receipt, consumption dan ending inventory.
*&
*& The report actually mimics transaction CKM3, but not per material only.
*&
*& Logical DB : N/A
*&
*& Assumption : N/A
*&
*&----------------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&----------------------------------------------------------------------------*
*& Date        By         TR#          Version  Description
*&----------------------------------------------------------------------------*
*& 18.09.2012  SAP_DEV02  DEVK932920   01       Initial creation
*&----------------------------------------------------------------------------*
REPORT  zdgco_r004.


*-----------------------------------------------------------------------
* T A B L E S
*-----------------------------------------------------------------------
TABLES : ckmlcr, marc, mara, mbew, ckmlhd.


*-----------------------------------------------------------------------
* T Y P E S
*-----------------------------------------------------------------------
TYPE-POOLS : slis, ckmd, ckmv0.

TYPES: BEGIN OF ty_mara,
        matnr TYPE mara-matnr,
        mtart TYPE mara-mtart,
        meins TYPE mara-meins,
        matkl TYPE mara-matkl,
        prdha TYPE mara-prdha,
        ean11 TYPE mara-ean11,
      END OF ty_mara,

      BEGIN OF ty_makt,
        matnr TYPE makt-matnr,
        maktx TYPE makt-maktx,
      END OF ty_makt,

      BEGIN OF ty_t001k,
        bwkey TYPE t001k-bwkey,
        bukrs TYPE t001k-bukrs,
      END OF ty_t001k,

      BEGIN OF ty_mbew,
        matnr TYPE mbew-matnr,
        bwkey TYPE mbew-bwkey,
        bwtar TYPE mbew-bwtar,
        bklas TYPE mbew-bklas,
        stprs TYPE mbew-stprs,
        verpr TYPE mbew-verpr,
        peinh TYPE mbew-peinh,
      END OF ty_mbew,

      BEGIN OF ty_marc,
        matnr TYPE marc-matnr,
        werks TYPE marc-werks,
        bstmi TYPE marc-bstmi,
        bstma TYPE marc-bstma,
        dispo TYPE marc-dispo,
      END OF ty_marc,

      BEGIN OF ty_mvke,
        matnr TYPE mvke-matnr,
        vkorg TYPE mvke-vkorg,
        vtweg TYPE mvke-vtweg,
        mvgr1 TYPE mvke-mvgr1,
      END   OF ty_mvke,


      BEGIN OF ty_ckmlhd,
        kalnr TYPE ckmlhd-kalnr,
        matnr TYPE ckmlhd-matnr,
        bwkey TYPE ckmlhd-bwkey,
        bwtar TYPE ckmlhd-bwtar,
        vbeln TYPE ckmlhd-vbeln,
        posnr TYPE ckmlhd-posnr,
      END OF ty_ckmlhd,

      BEGIN OF ty_ckmlcr,
        kalnr TYPE ckmlcr-kalnr,
        poper TYPE ckmlcr-poper,
        bdatj  TYPE ckmlcr-bdatj,
        waers TYPE ckmlcr-waers,
        absalk3 TYPE ckmlcr-absalk3,
        zuumb_o TYPE ckmlcr-zuumb_o,
        abprd_mo TYPE ckmlcr-abprd_mo,
        abkdm_o TYPE ckmlcr-abkdm_o,
        salk3 TYPE ckmlcr-salk3,
        salkv TYPE ckmlcr-salkv,
        ebprd_ea TYPE ckmlcr-ebprd_ea,
        ebkdm_ea TYPE ckmlcr-ebkdm_ea,
        ebprd_ma TYPE ckmlcr-ebprd_ma,
        ebkdm_ma TYPE ckmlcr-ebkdm_ma,
        vnprd_ea TYPE ckmlcr-vnprd_ea,
        pvprs TYPE ckmlcr-pvprs,
        vnprd_o TYPE ckmlcr-vnprd_o,
        vnkdm_o TYPE ckmlcr-vnkdm_o,
        vnkdm_ea TYPE ckmlcr-vnkdm_ea,
*        vnkdm_ost TYPE ckmlcr-vnkdm_ost,
        vnprd_ma TYPE ckmlcr-vnprd_ma,
        vnkdm_ma TYPE ckmlcr-vnkdm_ma,
        abkdm_mo TYPE ckmlcr-abkdm_mo,
        abprd_o TYPE ckmlcr-abprd_o,
      END OF ty_ckmlcr,

      BEGIN OF ty_ckmlpp,
        kalnr TYPE ckmlpp-kalnr,
        poper TYPE ckmlpp-poper,
        bdatj TYPE ckmlpp-bdatj,
        meins TYPE ckmlpp-meins,
        abkumo TYPE ckmlpp-abkumo,
        lbkum TYPE ckmlpp-lbkum,
        vnkumo TYPE ckmlpp-vnkumo,
        zukumo TYPE ckmlpp-zukumo,
        umkumo TYPE ckmlpp-umkumo,
      END OF ty_ckmlpp,

      ty_mlcd TYPE mlcd,

      BEGIN OF ty_t025t,
        bklas TYPE t025t-bklas,
        bkbez TYPE t025t-bkbez,
      END OF ty_t025t,

      BEGIN OF ty_report,
        matnr TYPE ckmlhd-matnr,
        mtart TYPE mara-mtart,
        bklas TYPE mbew-bklas,
        bkbez TYPE t025t-bkbez, "Valuation Class Description
        maktx TYPE makt-maktx,
        matkl TYPE mara-matkl,
        mvgr1 TYPE mvke-mvgr1,
        prdha TYPE mara-prdha,
        ean11 TYPE mara-ean11,
        meins TYPE mlcd-meins,
        bstmi TYPE marc-bstmi,
        bstma TYPE marc-bstma,
        dispo TYPE marc-dispo,
        waers TYPE mlcd-waers,
        bwkey TYPE ckmlhd-bwkey,
        bwtar TYPE ckmlhd-bwtar,
        vbeln TYPE ckmlhd-vbeln,
        posnr TYPE ckmlhd-posnr,
        abkumo TYPE ckmlpp-abkumo,       "Beginning Inventory: Quantity

        absalk3 TYPE ckmlcr-absalk3,     "Beginning Inventory: Amount
        abprd_mo TYPE ckmlcr-abprd_mo,   "Beginning Inventory: Price Differences
        total1 TYPE mlcd-salk3,

        salk3 TYPE mlcd-salk3,           "Beginning Inventory: Price Change

        lbkum_rtot TYPE mlcd-lbkum,

        salk3_rtot TYPE mlcd-salk3,
        estprd_rtot TYPE mlcd-estprd,
        total2 TYPE mlcd-salk3,

        lbkum_ctot TYPE mlcd-lbkum,

        salk3_ctot TYPE mlcd-salk3,
        estprd_ctot TYPE mlcd-estprd,
        total3 TYPE mlcd-salk3,

        lbkum_bf TYPE mlcd-lbkum,        "Receipt-Production Qty

        salk3_bf TYPE mlcd-salk3,        "Receipt-Production Amount
        estprd_bf TYPE mlcd-estprd,      "Receipt-Production Price Difference
        total4 TYPE mlcd-salk3,

        lbkum_bplus TYPE mlcd-lbkum,     "Receipt-Procurement Qty

        salk3_bplus TYPE mlcd-salk3,     "Receipt-Procurement Amount
        estprd_bplus TYPE mlcd-lbkum,    "Receipt-Procurement Price Diffrence
        total5 TYPE mlcd-salk3,

        lbkum_bb TYPE mlcd-lbkum,        "Receipt-PurchaseOrder Qty

        salk3_bb TYPE mlcd-salk3,        "Receipt-PurchaseOrder Amount
        estprd_bb TYPE mlcd-estprd,      "Receipt-PurchaseOrder Price Diffrence
        total6 TYPE mlcd-salk3,

        lbkum_bu TYPE mlcd-lbkum,        "Receipt-StockTransfer Qty
        salk3_bu TYPE mlcd-salk3,        "Receipt-StockTransfer Amount
        estprd_bu TYPE mlcd-estprd,      "Receipt-StockTransfer Price Diffrence
        lbkum_bubm TYPE mlcd-lbkum,      "Receipt-MatTrfPosting Qty
        salk3_bubm TYPE mlcd-salk3,      "Receipt-MatTrfPosting Amount
        estprd_bubm TYPE mlcd-estprd,    "Receipt-MatTrfPosting Price Diffrence
        lbkum_bubs TYPE mlcd-lbkum,      "Receipt-TrfPostSpcStock Qty

        salk3_bubs TYPE mlcd-salk3,      "Receipt-TrfPostSpcStock Amount
        estprd_bubs TYPE mlcd-estprd,    "Receipt-TrfPostSpcStock Price Diffrence
        total7 TYPE mlcd-salk3,

        lbkum_vplus TYPE mlcd-lbkum,     "Consumption-Consumption Qty

        salk3_vplus TYPE mlcd-salk3,     "Consumption-Consumption Amount
        estprd_vplus TYPE mlcd-estprd,   "Consumption-Consumption Price Diffrence
        total8 TYPE mlcd-salk3,

        lbkum_veau TYPE mlcd-lbkum,      "Consumption-ConsumptLvlOrd Qty
        salk3_veau TYPE mlcd-salk3,      "Consumption-ConsumptLvlOrd Amount
        estprd_veau TYPE mlcd-estprd,    "Consumption-ConsumptLvlOrd Price Diffrence
        lbkum_vf TYPE mlcd-lbkum,        "Consumption-Production Qty

        salk3_vf TYPE mlcd-salk3,        "Consumption-Production Amount
        estprd_vf TYPE mlcd-estprd,      "Consumption-Production Price Diffrence
        total9 TYPE mlcd-salk3,

        lbkum_vk TYPE mlcd-lbkum,        "Consumption-CostCenter Qty

        salk3_vk TYPE mlcd-salk3,        "Consumption-CostCenter Amount
        estprd_vk TYPE mlcd-estprd,      "Consumption-CostCenter Price Diffrence
        total10 TYPE mlcd-salk3,

        lbkum_vu TYPE mlcd-lbkum,        "Consumption-StockTransfer Qty
        salk3_vu TYPE mlcd-salk3,        "Consumption-StockTransfer Amount
        estprd_vu TYPE mlcd-estprd,      "Consumption-StockTransfer Price Diffrence
        lbkum_vubm TYPE mlcd-lbkum,      "Consumption-MatTrfPosting Qty
        salk3_vubm TYPE mlcd-salk3,      "Consumption-MatTrfPosting Amount
        estprd_vubm TYPE mlcd-estprd,    "Consumption-MatTrfPosting Price Diffrence
        lbkum_vubs TYPE mlcd-lbkum,      "Consumption-TrfPostSpcStock Qty

        salk3_vubs TYPE mlcd-salk3,      "Consumption-TrfPostSpcStock Amount
        estprd_vubs TYPE mlcd-estprd,    "Consumption-TrfPostSpcStock Price Diffrence
        total11 TYPE mlcd-salk3,

        lbkum_vw TYPE mlcd-lbkum,        "Consumption-WIPProd Qty

        salk3_vw TYPE mlcd-salk3,        "Consumption-WIPProd Amount
        estprd_vw TYPE mlcd-estprd,      "Consumption-WIPProd Price Diffrence
        total12 TYPE mlcd-salk3,

*        lbkum_nc TYPE mlcd-lbkum,        "Not Allocated Qty
*        salk3_nc TYPE mlcd-salk3,        "Not Allocated Amount
        estprd_nc TYPE mlcd-estprd,      "Not Allocated Price Diffrence
        lbkum_nv TYPE mlcd-lbkum,        "Not Distributed-WIPProd Qty

        salk3_nv TYPE mlcd-salk3,        "Not Distributed-WIPProd Amount
        estprd_nv TYPE mlcd-estprd,      "Not Distributed-WIPProd Price Diffrence
        total13 TYPE mlcd-salk3,

        lbkum_end TYPE mlcd-lbkum,       "EndingInventory Qty
        salk3_end TYPE mlcd-salk3,       "EndingInventory Amount
        estprd_end TYPE mlcd-estprd,     "EndingInventory Price Diffrence
        total14 TYPE mlcd-salk3,

        lbkum_bl TYPE mlcd-lbkum,

        salk3_bl TYPE mlcd-salk3,
        estprd_bl TYPE mlcd-estprd,
        total15 TYPE mlcd-salk3,

        estprd_end2 TYPE mlcd-estprd,    "Ending inventory Amount 2
        pvprs TYPE ckmlcr-pvprs,         "Periodic Unit Price

        stprs TYPE mbew-stprs,
        verpr TYPE mbew-verpr,
        peinh TYPE mbew-peinh,

        stdact_percen   TYPE p DECIMALS 2,
        salkv_end       TYPE ckmlcr-salkv,
      END OF ty_report,

      ty_ot_document TYPE LINE OF ckmd_t_document_report,
      ty_tt_ot_document TYPE STANDARD TABLE OF ty_ot_document,

      BEGIN OF ty_nv_data,
        lbkum TYPE mlcd-lbkum, "quantity
        salk3_beg TYPE mlcd-salk3, "amount beginning
        salk3_end TYPE mlcd-salk3, "amount ending
        salk3_con TYPE mlcd-salk3, "amount consumption
        salk3_rcv TYPE mlcd-salk3, "amount receiving
        estprd_beg TYPE mlcd-salk3, "price difference beginning
        estprd_end TYPE mlcd-salk3, "price difference ending
        estprd_con TYPE mlcd-salk3, "price difference consumption
        estprd_rcv TYPE mlcd-salk3, "price difference receiving
      END OF ty_nv_data.

*-----------------------------------------------------------------------
* I N T E R N A L  T A B L E S
*-----------------------------------------------------------------------
DATA: t_mara    TYPE STANDARD TABLE OF ty_mara,
      wa_mara   TYPE ty_mara,
      t_makt    TYPE STANDARD TABLE OF ty_makt,
      wa_makt   TYPE ty_makt,
      t_marc    TYPE STANDARD TABLE OF ty_marc,
      wa_marc   TYPE ty_marc,
      t_t001k   TYPE STANDARD TABLE OF ty_t001k,
      wa_t001k  TYPE ty_t001k,
      t_mbew    TYPE STANDARD TABLE OF ty_mbew,
      wa_mbew   TYPE ty_mbew,
      t_mvke    TYPE STANDARD TABLE OF ty_mvke,
      wa_mvke   TYPE ty_mvke,
      t_ckmlhd  TYPE STANDARD TABLE OF ty_ckmlhd,
      wa_ckmlhd TYPE ty_ckmlhd,
      t_ckmlcr  TYPE STANDARD TABLE OF ty_ckmlcr,
      wa_ckmlcr TYPE ty_ckmlcr,
      t_ckmlpp  TYPE STANDARD TABLE OF ty_ckmlpp,
      wa_ckmlpp TYPE ty_ckmlpp,
      t_mlcd    TYPE STANDARD TABLE OF ty_mlcd,
      wa_mlcd   TYPE ty_mlcd,
      t_t025t   TYPE STANDARD TABLE OF ty_t025t,
      wa_t025t  TYPE ty_t025t,
      t_mlcd_not_alloc TYPE STANDARD TABLE OF mlcd,
      t_report  TYPE STANDARD TABLE OF ty_report,
      wa_report TYPE ty_report.


*-----------------------------------------------------------------------
* G L O B A L  V A R I A B L E S
*-----------------------------------------------------------------------
* For ALV
DATA : t_fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       t_sort          TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       t_events        TYPE slis_t_event WITH HEADER LINE,
       t_event_exit    TYPE slis_t_event_exit WITH HEADER LINE,
       x_layout        TYPE slis_layout_alv,
       x_print         TYPE slis_print_alv,
       d_repid         LIKE sy-repid.

*For BDC Call Transaction
DATA: t_bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
      t_messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
      t_return  TYPE TABLE OF bapiret2 WITH HEADER LINE.

*-----------------------------------------------------------------------
* S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
SELECT-OPTIONS: s_bwkey FOR ckmlhd-bwkey OBLIGATORY,
*                s_bwtar FOR ckmlhd-bwtar,
                s_bklas FOR mbew-bklas,
                s_matnr FOR marc-matnr,
                s_mtart FOR mara-mtart.
*                s_vbeln FOR ckmlhd-vbeln,
*                s_posnr FOR ckmlhd-posnr,
*                s_pspnr FOR ckmlhd-pspnr,
*                s_lifnr FOR ckmlhd-lifnr.
PARAMETERS    : p_monat TYPE ckmlcr-poper OBLIGATORY DEFAULT sy-datum+4(2),
                p_gjahr TYPE ckmlcr-bdatj OBLIGATORY DEFAULT sy-datum(4).
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.
PARAMETERS:     p_zero AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

*-----------------------------------------------------------------------
* I N I T I A L I Z A T I O N
*-----------------------------------------------------------------------
INITIALIZATION.


*-----------------------------------------------------------------------
* A T   S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.


*-----------------------------------------------------------------------
* S T A R T - O F - S E L E C T I O N
*-----------------------------------------------------------------------
START-OF-SELECTION.

* Get Material Ledger Data from CKMLHD, CKMLCR, CKMLPP, and MLHD
  PERFORM f_get_mat_ledger.

* Get additional data from MARA, MAKT, MBEW
  PERFORM f_get_material_data.

* Build Report
  PERFORM f_process_data.


*-----------------------------------------------------------------------
* E N D - O F - S E L E C T I O N
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF t_report[] IS NOT INITIAL.
    PERFORM f_print_report.
  ELSE.
    MESSAGE 'No material ledger data found' TYPE 'S'.
  ENDIF.


*  INCLUDE zco0027f01.


*&---------------------------------------------------------------------*
*&      Form  f_get_mat_ledger
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_mat_ledger.

  PERFORM f_gui_message USING 'Getting header data from CKMLHD..'
                              space.

* Get Material Ledger Header
  CLEAR t_ckmlhd[].
  SELECT kalnr matnr bwkey bwtar vbeln posnr
    INTO TABLE t_ckmlhd
    FROM ckmlhd
   WHERE matnr IN s_matnr
     AND bwkey IN s_bwkey.
*     AND bwtar IN s_bwtar
*     AND vbeln IN s_vbeln
*     AND posnr IN s_posnr
*     AND pspnr IN s_pspnr
*     AND lifnr IN s_lifnr.

  IF t_ckmlhd[] IS INITIAL.
    MESSAGE s398(00) WITH 'No material ledger data found' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM f_gui_message USING 'Getting amount data from CKMLCR..'
                              space.

* Get Material Ledger Amount Data
  SELECT kalnr poper bdatj waers absalk3 zuumb_o abprd_mo abkdm_o
         salk3 salkv ebprd_ea ebkdm_ea ebprd_ma ebkdm_ma vnprd_ea pvprs
         vnprd_o vnkdm_o vnkdm_ea
*        vnkdm_ost
         vnprd_ma vnkdm_ma abkdm_mo abprd_o
    INTO TABLE t_ckmlcr
    FROM ckmlcr
    FOR ALL ENTRIES IN t_ckmlhd
    WHERE kalnr = t_ckmlhd-kalnr
      AND poper = p_monat
      AND bdatj = p_gjahr
      AND curtp = '10'.
  SORT t_ckmlcr BY kalnr.

  PERFORM f_gui_message USING 'Getting quantity data from CKMLPP..'
                              space.

* Get Material Ledger Quantity Data
  SELECT kalnr poper bdatj meins abkumo lbkum
         vnkumo zukumo umkumo
    INTO TABLE t_ckmlpp
    FROM ckmlpp
    FOR ALL ENTRIES IN t_ckmlhd
    WHERE kalnr = t_ckmlhd-kalnr
      AND poper = p_monat
      AND bdatj = p_gjahr.
  SORT t_ckmlpp BY kalnr.

  PERFORM f_gui_message USING 'Getting detail data from MLCD..'
                              space.

** Get Material Ledger Document Data
*  SELECT kalnr poper bdatj categ ptyp meins waers lbkum salk3 estprd estkdm
*         mstprd mstkdm tpprd estkdm_st
*    INTO TABLE t_mlcd
*    FROM mlcd
*    FOR ALL ENTRIES IN t_ckmlhd
*    WHERE kalnr = t_ckmlhd-kalnr
*      AND poper = p_monat
*      AND bdatj = p_gjahr
*      AND curtp = '10'.
*  SORT t_mlcd BY kalnr.


  DATA: lt_kalnr TYPE ckmv0_matobj_tbl,
        lw_kalnr TYPE LINE OF ckmv0_matobj_tbl.

  LOOP AT t_ckmlhd INTO wa_ckmlhd.
    "Create list of cost estimate number which material ledger document is to be found
    lw_kalnr-kalnr = wa_ckmlhd-kalnr.
    APPEND lw_kalnr TO lt_kalnr.

  ENDLOOP.

* Get Material ledger data and  not allocated material ledger data
  CALL FUNCTION 'CKMCD_MLCD_READ'
    EXPORTING
      i_from_bdatj      = p_gjahr
      i_from_poper      = p_monat
    TABLES
      it_kalnr          = lt_kalnr
      ot_mlcd           = t_mlcd
      ot_mlcd_not_alloc = t_mlcd_not_alloc
    EXCEPTIONS
      data_error        = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
  ENDIF.

  "Delete MLCD data whose currency is not in Company Code currency
  DELETE t_mlcd WHERE curtp NE '10'.
  DELETE t_mlcd_not_alloc WHERE curtp NE '10'.

  "Sort for later searching
  SORT t_mlcd BY kalnr.
  SORT t_mlcd_not_alloc BY kalnr.




ENDFORM.                    "f_get_mat_ledger


*&---------------------------------------------------------------------*
*&      Form  f_get_material_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_material_data.

  DATA: lt_material  TYPE STANDARD TABLE OF ty_ckmlhd,
        lt_valuation TYPE STANDARD TABLE OF ty_ckmlhd,
        lt_val_class TYPE STANDARD TABLE OF ty_mbew.

  PERFORM f_gui_message USING 'Getting additional material data..'
                              space.

* Create unique list of material
  CHECK t_ckmlhd[] IS NOT INITIAL.
  CLEAR lt_material[].
  lt_material[] = t_ckmlhd[].
  SORT lt_material[] BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_material[] COMPARING matnr.

* Get Valuation area
  SELECT bwkey bukrs
    FROM t001k
    INTO TABLE t_t001k
    WHERE bwkey IN s_bwkey.

* Get Material Type and UoM
  CLEAR t_mara[].
  SELECT matnr mtart meins matkl prdha ean11
    INTO TABLE t_mara
    FROM mara
    FOR ALL ENTRIES IN lt_material
   WHERE matnr = lt_material-matnr
     AND mtart IN s_mtart.
  SORT t_mara[] BY matnr.

* Get Material Description
  CLEAR t_makt[].
  SELECT matnr maktx
    INTO TABLE t_makt
    FROM makt
     FOR ALL ENTRIES IN lt_material
   WHERE matnr = lt_material-matnr
     AND spras = sy-langu.
  SORT t_makt[] BY matnr.

* Get Material Group 1
  SELECT matnr vkorg vtweg mvgr1
    FROM mvke
    INTO TABLE t_mvke
    FOR ALL ENTRIES IN lt_material
    WHERE matnr EQ lt_material-matnr.

* Create unique list of valuation
  CLEAR lt_valuation[].
  lt_valuation[] = t_ckmlhd[].
  SORT lt_valuation[] BY matnr bwkey bwtar.
  DELETE ADJACENT DUPLICATES FROM lt_valuation[] COMPARING matnr bwkey bwtar.

* Get Valuation Class
  SELECT matnr bwkey bwtar bklas stprs verpr peinh
    INTO TABLE t_mbew
    FROM mbew
     FOR ALL ENTRIES IN lt_valuation
   WHERE matnr = lt_valuation-matnr
     AND bwkey = lt_valuation-bwkey
     AND bwtar = lt_valuation-bwtar
     AND bklas IN s_bklas[].
  SORT t_mbew[] BY matnr bwkey bwtar.

* Get Valuation Class Description
  CHECK t_mbew[] IS NOT INITIAL.
  CLEAR: t_t025t[], lt_val_class[].
  lt_val_class[] = t_mbew[].
  SORT lt_val_class BY bklas.
  DELETE ADJACENT DUPLICATES FROM lt_val_class COMPARING bklas.
  SELECT bklas
         bkbez
    FROM t025t
    INTO TABLE t_t025t
     FOR ALL ENTRIES IN lt_val_class
   WHERE spras = sy-langu
     AND bklas = lt_val_class-bklas.

  CLEAR t_marc[].
  SELECT matnr werks bstmi bstma dispo
    INTO TABLE t_marc
    FROM marc
     FOR ALL ENTRIES IN lt_material
   WHERE matnr = lt_material-matnr
     AND werks = lt_material-bwkey.
  SORT t_marc[] BY matnr werks.

ENDFORM.                    "f_get_material_data


*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA: l_currency      TYPE waers,
        l_index         TYPE sy-tabix.

  DATA: lt_ot_docs TYPE ty_tt_ot_document,
        lw_ot_docs TYPE ty_ot_document,
        lw_nv_data TYPE ty_nv_data.

  PERFORM f_gui_message USING 'Compiling report..'
                              space.

* Populate Report
  CLEAR t_report[].
  LOOP AT t_ckmlhd INTO wa_ckmlhd.

    CLEAR wa_report.
    wa_report-matnr = wa_ckmlhd-matnr.
    wa_report-bwkey = wa_ckmlhd-bwkey.
    wa_report-bwtar = wa_ckmlhd-bwtar.
    wa_report-vbeln = wa_ckmlhd-vbeln.
    wa_report-posnr = wa_ckmlhd-posnr.

*   Filter and Get Material Type
    CLEAR wa_mara.
    READ TABLE t_mara INTO wa_mara
                      WITH KEY matnr = wa_ckmlhd-matnr
                      BINARY SEARCH.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    wa_report-mtart = wa_mara-mtart.
    wa_report-meins = wa_mara-meins.
    wa_report-matkl = wa_mara-matkl.

    CLEAR wa_marc.
    READ TABLE t_marc INTO wa_marc
                      WITH KEY matnr = wa_ckmlhd-matnr
                               werks = wa_ckmlhd-bwkey
                      BINARY SEARCH.
    wa_report-bstmi = wa_marc-bstmi.
    wa_report-bstma = wa_marc-bstma.
    wa_report-dispo = wa_marc-dispo.

    CALL FUNCTION 'ZGET_MEAN'
      EXPORTING
        zmatnr = wa_mara-matnr
        zuom   = wa_mara-meins
      IMPORTING
        zean11 = wa_mara-ean11.

    wa_report-ean11 = wa_mara-ean11.

    IF wa_mara-mtart EQ 'ZCGB'.
*   Get Material Group 1
      READ TABLE t_t001k INTO wa_t001k
                         WITH KEY bwkey = wa_ckmlhd-bwkey.
      READ TABLE t_mvke INTO wa_mvke
                        WITH KEY matnr = wa_ckmlhd-matnr
                                 vkorg = wa_t001k-bukrs.
      wa_report-mvgr1 = wa_mvke-mvgr1.
      wa_report-prdha = wa_mara-prdha.
    ENDIF.

*   Get Material Description
    CLEAR wa_makt.
    READ TABLE t_makt INTO wa_makt
                      WITH KEY matnr = wa_ckmlhd-matnr
                      BINARY SEARCH.
    wa_report-maktx = wa_makt-maktx.

*   Filter and Get Valuation Class
    CLEAR wa_mbew.
    READ TABLE t_mbew INTO wa_mbew
                      WITH KEY matnr = wa_ckmlhd-matnr
                               bwkey = wa_ckmlhd-bwkey
                               bwtar = wa_ckmlhd-bwtar
                      BINARY SEARCH.
    IF sy-subrc NE 0.
      CONTINUE.
    ELSE.
      wa_report-stprs = wa_mbew-stprs.
      wa_report-verpr = wa_mbew-verpr.
      wa_report-peinh = wa_mbew-peinh.

      TRY .
          wa_report-stdact_percen = ( wa_mbew-verpr - wa_mbew-stprs ) / wa_mbew-stprs * 100.

        CATCH cx_sy_zerodivide .

      ENDTRY.
    ENDIF.
    wa_report-bklas = wa_mbew-bklas.

*   Get Valuation Class Description
    CLEAR wa_t025t.
    READ TABLE t_t025t INTO wa_t025t
                   WITH KEY bklas = wa_mbew-bklas.
    IF sy-subrc = 0.
      wa_report-bkbez = wa_t025t-bkbez.
    ENDIF.

    CLEAR: l_currency.

    "---------------------------
    " C K M L P P
    "---------------------------
    CLEAR l_index.
    READ TABLE t_ckmlpp TRANSPORTING NO FIELDS
                        WITH KEY kalnr = wa_ckmlhd-kalnr
                        BINARY SEARCH.
    IF sy-subrc = 0.
      l_index = sy-tabix.
*     Get Beginning & Ending Quantity
      LOOP AT t_ckmlpp INTO wa_ckmlpp FROM l_index.
        IF wa_ckmlpp-kalnr NE wa_ckmlhd-kalnr.
          EXIT.
        ENDIF.
        wa_report-abkumo    = wa_report-abkumo + wa_ckmlpp-abkumo.
        wa_report-lbkum_end = wa_report-lbkum_end + wa_ckmlpp-lbkum.

        "Not distributed quantity:
        lw_nv_data-lbkum = lw_nv_data-lbkum + wa_ckmlpp-lbkum + wa_ckmlpp-vnkumo - ( wa_ckmlpp-zukumo + wa_ckmlpp-umkumo + wa_ckmlpp-abkumo ).
        "ending + consumption - ( receipt + beginning 1 + beginning 2 ).
      ENDLOOP.
    ENDIF.

    CLEAR l_index.
    READ TABLE t_ckmlcr TRANSPORTING NO FIELDS
                        WITH KEY kalnr = wa_ckmlhd-kalnr
                        BINARY SEARCH.
    IF sy-subrc = 0.
      l_index = sy-tabix.

*     Get Beginning & Ending Amount
      LOOP AT t_ckmlcr INTO wa_ckmlcr FROM l_index.

        IF wa_ckmlcr-kalnr NE wa_ckmlhd-kalnr.
          EXIT.
        ENDIF.

        wa_report-absalk3    = wa_report-absalk3 + wa_ckmlcr-absalk3.
        "Beginning price difference
        wa_report-abprd_mo   = wa_report-abprd_mo + wa_ckmlcr-abkdm_mo + wa_ckmlcr-abprd_mo + wa_ckmlcr-abprd_o + wa_ckmlcr-abkdm_o.
        wa_report-estprd_end = wa_report-estprd_end + wa_ckmlcr-ebprd_ea + wa_ckmlcr-ebkdm_ea +
                               wa_ckmlcr-ebprd_ma + wa_ckmlcr-ebkdm_ma.
        wa_report-salk3_end  = wa_report-salk3_end + wa_ckmlcr-salk3.
        wa_report-salkv_end  = wa_report-salkv_end + wa_ckmlcr-salkv.

        wa_report-pvprs      = wa_ckmlcr-pvprs.
        l_currency           = wa_ckmlcr-waers.

        "Not distributed ending amount
        lw_nv_data-salk3_end = lw_nv_data-salk3_end + wa_ckmlcr-salk3.

        "Not distributed beginning amount
        lw_nv_data-salk3_beg = lw_nv_data-salk3_beg + wa_ckmlcr-absalk3.

        "Not distributed ending price difference
        lw_nv_data-estprd_end = lw_nv_data-estprd_end + wa_ckmlcr-ebprd_ea + wa_ckmlcr-ebkdm_ea +
                                wa_ckmlcr-ebprd_ma + wa_ckmlcr-ebkdm_ma.

        "Not distributed beginning price difference
        lw_nv_data-estprd_beg = lw_nv_data-estprd_beg + wa_ckmlcr-abkdm_mo + wa_ckmlcr-abprd_mo + wa_ckmlcr-abprd_o + wa_ckmlcr-abkdm_o.

      ENDLOOP.
      wa_report-waers = l_currency.
    ENDIF.

    "New formula to calculate not allocated difference
    CLEAR l_index.
    READ TABLE t_mlcd_not_alloc TRANSPORTING NO FIELDS
                                WITH KEY kalnr = wa_ckmlhd-kalnr
                                BINARY SEARCH.
    IF sy-subrc = 0.
      l_index = sy-tabix.

*     Get Material Ledger Document Not Allocated
      LOOP AT t_mlcd_not_alloc INTO wa_mlcd FROM l_index.
        IF wa_mlcd-kalnr NE wa_ckmlhd-kalnr.
          EXIT.
        ENDIF.
        "Price difference Not allocated
        wa_report-estprd_nc = wa_report-estprd_nc + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd + wa_mlcd-mstkdm.

        "Not distributed consumption amount
        lw_nv_data-salk3_con = lw_nv_data-salk3_con + wa_mlcd-salk3.

        "Not distributed consumption price difference
        lw_nv_data-estprd_con = lw_nv_data-estprd_con + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd + wa_mlcd-mstkdm.

      ENDLOOP.

    ENDIF.

    "Get Price Change and post closing ML Data Using function module
    IF wa_ckmlhd-kalnr IS NOT INITIAL.
      "Price change material ledger data
      PERFORM f_get_pc_pcml_data USING wa_ckmlhd-kalnr
                                       p_monat
                                       p_gjahr
                                 CHANGING lt_ot_docs[].

      LOOP AT lt_ot_docs INTO lw_ot_docs.
        "Additional beginning amount balance:
        IF lw_ot_docs-categ EQ 'AB'.
          wa_report-absalk3 = wa_report-absalk3 + lw_ot_docs-salk3.

*          "Additional beginning price difference formula:
*          wa_report-abprd_mo = wa_report-abprd_mo + lw_ot_docs-estprd + lw_ot_docs-estkdm + lw_ot_docs-mstprd + lw_ot_docs-mstkdm.
        ENDIF.


        IF lw_ot_docs-categ EQ 'AB' OR ( lw_ot_docs-categ EQ '' AND lw_ot_docs-vgart EQ 'CL' ).
          "Additional beginning quantity balance formula:
          wa_report-abkumo = lw_ot_docs-lbkum + wa_report-abkumo.

          "Not distributed beginning amount:
          lw_nv_data-salk3_beg = lw_nv_data-salk3_beg + lw_ot_docs-salk3.

*          "Not distributed beginning price difference
*          lw_nv_data-estprd_beg = lw_nv_data-estprd_beg + lw_ot_docs-estprd + lw_ot_docs-estkdm + lw_ot_docs-mstprd + lw_ot_docs-mstkdm.

        ENDIF.

        IF lw_ot_docs-categ EQ 'VN'.
          "Not distributed consumption amount
          lw_nv_data-salk3_con = lw_nv_data-salk3_con + lw_ot_docs-salk3.

          "Not distributed price difference consumption amount
          lw_nv_data-estprd_con = lw_nv_data-estprd_con + lw_ot_docs-estprd + lw_ot_docs-estkdm + lw_ot_docs-mstprd + lw_ot_docs-mstkdm.

        ENDIF.

        "Not distributed receipt amount
        IF lw_ot_docs-categ EQ 'ZU'.
          lw_nv_data-salk3_rcv = lw_nv_data-salk3_rcv + lw_ot_docs-salk3.

          "Not distributed price difference receipt amount
          lw_nv_data-estprd_rcv = lw_nv_data-estprd_rcv + lw_ot_docs-estprd + lw_ot_docs-estkdm + lw_ot_docs-mstprd + lw_ot_docs-mstkdm.
        ENDIF.

      ENDLOOP.
    ENDIF.

    CLEAR l_index.
    READ TABLE t_mlcd TRANSPORTING NO FIELDS
                      WITH KEY kalnr = wa_ckmlhd-kalnr
                      BINARY SEARCH.
    IF sy-subrc = 0.
      l_index = sy-tabix.
*     Get Material Ledger Document
      LOOP AT t_mlcd INTO wa_mlcd FROM l_index.
        IF wa_mlcd-kalnr NE wa_ckmlhd-kalnr.
          EXIT.
        ENDIF.
        IF wa_mlcd-categ = 'PC' OR wa_mlcd-ptyp = 'PC'.
          wa_report-salk3 = wa_report-salk3 + wa_mlcd-salk3.
        ELSEIF wa_mlcd-categ = 'ZU'.
          IF wa_mlcd-ptyp = 'BF'.
            wa_report-lbkum_bf = wa_report-lbkum_bf + wa_mlcd-lbkum.
            wa_report-salk3_bf = wa_report-salk3_bf + wa_mlcd-salk3.
            wa_report-estprd_bf = wa_report-estprd_bf + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'B+'.
            wa_report-lbkum_bplus = wa_report-lbkum_bplus + wa_mlcd-lbkum.
            wa_report-salk3_bplus = wa_report-salk3_bplus + wa_mlcd-salk3.
            wa_report-estprd_bplus = wa_report-estprd_bplus + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                     wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'BB'.
            wa_report-lbkum_bb = wa_report-lbkum_bb + wa_mlcd-lbkum.
            wa_report-salk3_bb = wa_report-salk3_bb + wa_mlcd-salk3.
            wa_report-estprd_bb = wa_report-estprd_bb + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'BU'.
            wa_report-lbkum_bu = wa_report-lbkum_bu + wa_mlcd-lbkum.
            wa_report-salk3_bu = wa_report-salk3_bu + wa_mlcd-salk3.
            wa_report-estprd_bu = wa_report-estprd_bu + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'BUBM'.
            wa_report-lbkum_bubm = wa_report-lbkum_bubm + wa_mlcd-lbkum.
            wa_report-salk3_bubm = wa_report-salk3_bubm + wa_mlcd-salk3.
            wa_report-estprd_bubm = wa_report-estprd_bubm + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                    wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'BUBS'.
            wa_report-lbkum_bubs = wa_report-lbkum_bubs + wa_mlcd-lbkum.
            wa_report-salk3_bubs = wa_report-salk3_bubs + wa_mlcd-salk3.
            wa_report-estprd_bubs = wa_report-estprd_bubs + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                    wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'BL'.
            wa_report-lbkum_bl = wa_report-lbkum_bl + wa_mlcd-lbkum.
            wa_report-salk3_bl = wa_report-salk3_bl + wa_mlcd-salk3.
            wa_report-estprd_bl = wa_report-estprd_bl + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ENDIF.
        ELSEIF wa_mlcd-categ = 'VN'.

          IF wa_mlcd-ptyp = 'V+'.
            wa_report-lbkum_vplus = wa_report-lbkum_vplus + wa_mlcd-lbkum.
            wa_report-salk3_vplus = wa_report-salk3_vplus + wa_mlcd-salk3.
            wa_report-estprd_vplus = wa_report-estprd_vplus + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                     wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'B+'.
            wa_report-lbkum_vplus = wa_report-lbkum_vplus + wa_mlcd-lbkum.
            wa_report-salk3_vplus = wa_report-salk3_vplus + wa_mlcd-salk3.
            wa_report-estprd_vplus = wa_report-estprd_vplus + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                     wa_mlcd-mstkdm + wa_mlcd-tpprd.
          ELSEIF wa_mlcd-ptyp = 'VEAU'.
            wa_report-lbkum_veau = wa_report-lbkum_veau + wa_mlcd-lbkum.
            wa_report-salk3_veau = wa_report-salk3_veau + wa_mlcd-salk3.
            wa_report-estprd_veau = wa_report-estprd_veau + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                    wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'VF'.
            wa_report-lbkum_vf = wa_report-lbkum_vf + wa_mlcd-lbkum.
            wa_report-salk3_vf = wa_report-salk3_vf + wa_mlcd-salk3.
            wa_report-estprd_vf = wa_report-estprd_vf + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'VL'.
            wa_report-lbkum_vf = wa_report-lbkum_vf + wa_mlcd-lbkum.
            wa_report-salk3_vf = wa_report-salk3_vf + wa_mlcd-salk3.
            wa_report-estprd_vf = wa_report-estprd_vf + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'VK'.
            wa_report-lbkum_vk = wa_report-lbkum_vk + wa_mlcd-lbkum.
            wa_report-salk3_vk = wa_report-salk3_vk + wa_mlcd-salk3.
            wa_report-estprd_vk = wa_report-estprd_vk + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'VU'.
            wa_report-lbkum_vu = wa_report-lbkum_vu + wa_mlcd-lbkum.
            wa_report-salk3_vu = wa_report-salk3_vu + wa_mlcd-salk3.
            wa_report-estprd_vu = wa_report-estprd_vu + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'VUBM'.
            wa_report-lbkum_vubm = wa_report-lbkum_vubm + wa_mlcd-lbkum.
            wa_report-salk3_vubm = wa_report-salk3_vubm + wa_mlcd-salk3.
            wa_report-estprd_vubm = wa_report-estprd_vubm + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                    wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'VUBS'.
            wa_report-lbkum_vubs = wa_report-lbkum_vubs + wa_mlcd-lbkum.
            wa_report-salk3_vubs = wa_report-salk3_vubs + wa_mlcd-salk3.
            wa_report-estprd_vubs = wa_report-estprd_vubs + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                    wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ELSEIF wa_mlcd-ptyp = 'VW'.
            wa_report-lbkum_vw = wa_report-lbkum_vw + wa_mlcd-lbkum.
            wa_report-salk3_vw = wa_report-salk3_vw + wa_mlcd-salk3.
            wa_report-estprd_vw = wa_report-estprd_vw + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd +
                                  wa_mlcd-mstkdm + wa_mlcd-tpprd.
*             + wa_mlcd-estkdm_st.
          ENDIF.

          "additional formula to calculate beginning balances
        ELSEIF wa_mlcd-categ = 'AB'.

          wa_report-absalk3 = wa_report-absalk3 + wa_mlcd-salk3. "Amount
          wa_report-abkumo = wa_report-abkumo + wa_mlcd-lbkum. "quantity
          wa_report-abprd_mo = wa_report-abprd_mo + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd + wa_mlcd-mstkdm. "Price Difference

        ENDIF.


        IF wa_mlcd-categ EQ 'VN'.
          "Not distributed consumption amount
          lw_nv_data-salk3_con = lw_nv_data-salk3_con + wa_mlcd-salk3.

          "Not distributed consumption price difference
          lw_nv_data-estprd_con = lw_nv_data-estprd_con + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd + wa_mlcd-mstkdm.

        ENDIF.


        IF wa_mlcd-categ EQ 'ZU'.
          "Not distributed receipt amount
          lw_nv_data-salk3_rcv = lw_nv_data-salk3_rcv + wa_mlcd-salk3.

          "Not distributed price difference receipt amount
          lw_nv_data-estprd_rcv = lw_nv_data-estprd_rcv + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd + wa_mlcd-mstkdm.
        ENDIF.


        IF wa_mlcd-categ EQ 'AB'.
          "Not distributed beginning amount
          lw_nv_data-salk3_beg = lw_nv_data-salk3_beg + wa_mlcd-salk3.

          "Not distributed beginning price difference
          lw_nv_data-estprd_beg = lw_nv_data-estprd_beg + wa_mlcd-estprd + wa_mlcd-estkdm + wa_mlcd-mstprd + wa_mlcd-mstkdm.
        ENDIF.

      ENDLOOP.
    ENDIF.

*   Calculate Total Receipt and Consumption
    wa_report-lbkum_rtot = wa_report-lbkum_bf + wa_report-lbkum_bplus + wa_report-lbkum_bb +
                           wa_report-lbkum_bu + wa_report-lbkum_bubm + wa_report-lbkum_bubs +
                           wa_report-lbkum_bl.
    wa_report-lbkum_ctot = wa_report-lbkum_vplus + wa_report-lbkum_veau + wa_report-lbkum_vf +
                           wa_report-lbkum_vk + wa_report-lbkum_vu + wa_report-lbkum_vubm +
                           wa_report-lbkum_vubs + wa_report-lbkum_vw.
    wa_report-salk3_rtot = wa_report-salk3_bf + wa_report-salk3_bplus + wa_report-salk3_bb +
                           wa_report-salk3_bu + wa_report-salk3_bubm + wa_report-salk3_bubs +
                           wa_report-salk3_bl.
    wa_report-salk3_ctot = wa_report-salk3_vplus + wa_report-salk3_veau + wa_report-salk3_vf +
                           wa_report-salk3_vk + wa_report-salk3_vu + wa_report-salk3_vubm +
                           wa_report-salk3_vubs + wa_report-salk3_vw.
    wa_report-estprd_rtot = wa_report-estprd_bf + wa_report-estprd_bplus + wa_report-estprd_bb +
                            wa_report-estprd_bu + wa_report-estprd_bubm + wa_report-estprd_bubs +
                            wa_report-estprd_bl.
*   For Price Diff Consumption Total, also add Not Allocated
    wa_report-estprd_ctot = wa_report-estprd_vplus + wa_report-estprd_veau + wa_report-estprd_vf +
                            wa_report-estprd_vk + wa_report-estprd_vu + wa_report-estprd_vubm +
                            wa_report-estprd_vubs + wa_report-estprd_vw + + wa_report-estprd_nc.

*   Calculate Not Distributed
*   Formula: Ending Balance + Total Consumption -
*            Total Receipt - Beginning Balance - Price Change
    wa_report-lbkum_nv = lw_nv_data-lbkum.
    wa_report-salk3_nv = lw_nv_data-salk3_end + lw_nv_data-salk3_con - lw_nv_data-salk3_rcv - lw_nv_data-salk3_beg - wa_report-salk3.
    wa_report-estprd_nv = lw_nv_data-estprd_end + lw_nv_data-estprd_con - lw_nv_data-estprd_rcv - lw_nv_data-estprd_beg.
    CLEAR: lw_nv_data.

    IF wa_report-salk3_nv LT 0.
      wa_report-salk3_nv = 0.
    ENDIF.

    IF wa_report-lbkum_nv LT 0.
      wa_report-lbkum_nv = 0.
    ENDIF.

*    IF wa_report-estprd_nv LT 0.
*      wa_report-estprd_nv = 0.
*    ENDIF.

    "   Calculate ending amount 2
    "   Formula: Ending Inventory Amount + Ending Inventory Price Difference
*    wa_report-estprd_end2 = wa_report-salk3_end + wa_report-estprd_end.
    wa_report-estprd_end2 = wa_report-salkv_end.

*   If P_ZERO is ticked, do not display material with no movement
    IF p_zero IS NOT INITIAL.
      IF wa_report-lbkum_end IS INITIAL AND
         wa_report-salk3_end IS INITIAL AND
         wa_report-abkumo IS INITIAL AND
         wa_report-absalk3 IS INITIAL AND
         wa_report-lbkum_rtot IS INITIAL AND
         wa_report-lbkum_ctot IS INITIAL AND
         wa_report-salk3_rtot IS INITIAL AND
         wa_report-salk3_ctot IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.

*   Default Currency
    IF wa_report-waers IS INITIAL.
      wa_report-waers = 'IDR'.
    ENDIF.

*   Default Unit of Measure
    IF wa_report-meins IS INITIAL.
      wa_report-meins = 'KG'.
    ENDIF.

*   Calculate Total per Cost Category
    wa_report-total1     = wa_report-absalk3 + wa_report-abprd_mo.
    wa_report-total2     = wa_report-salk3_rtot + wa_report-estprd_rtot.
    wa_report-total3     = wa_report-salk3_ctot + wa_report-estprd_ctot.
    wa_report-total4     = wa_report-salk3_bf + wa_report-estprd_bf.
    wa_report-total5     = wa_report-salk3_bplus + wa_report-estprd_bplus.
    wa_report-total6     = wa_report-salk3_bb + wa_report-estprd_bb.
    wa_report-total7     = wa_report-salk3_bubs + wa_report-estprd_bubs.
    wa_report-total8     = wa_report-salk3_vplus + wa_report-estprd_vplus.
    wa_report-total9     = wa_report-salk3_vf + wa_report-estprd_vf.
    wa_report-total10    = wa_report-salk3_vk + wa_report-estprd_vk.
    wa_report-total11    = wa_report-salk3_vubs + wa_report-estprd_vubs.
    wa_report-total12    = wa_report-salk3_vw + wa_report-estprd_vw.
    wa_report-total13    = wa_report-salk3_nv + wa_report-estprd_nv.
    wa_report-total14    = wa_report-salk3_end + wa_report-estprd_end.
    wa_report-total15    = wa_report-salk3_bl + wa_report-estprd_bl.

** Koreksi 13/11/2014
    wa_report-salk3_end = wa_report-absalk3 + wa_report-salk3_rtot - wa_report-salk3_ctot.
    wa_report-total14 = wa_report-total1 + wa_report-total2 - wa_report-total3.
** End koreksi 13/11/2014

** Koreksi 11/05/2015
    wa_report-total13 = wa_report-total1 + wa_report-total2 - wa_report-total3 - wa_report-estprd_end2.
** End koreksi 11/05/2015

*   Append Ledger to report
    APPEND wa_report TO t_report.

  ENDLOOP.

ENDFORM. " f_process_data.


*&---------------------------------------------------------------------*
*&      Form  f_print_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_print_report.

  FIELD-SYMBOLS: <lfs_fcat> TYPE slis_fieldcat_alv.

  PERFORM f_gui_message USING 'Preparing to display report..' ''.
  PERFORM f_build_fieldcat.
  PERFORM f_build_layout.
  PERFORM f_build_sort.
  PERFORM f_build_events.
  PERFORM f_build_event_exit.
  PERFORM f_build_print.

* Make Material Number as Key (Freeze Pane)
  LOOP AT t_fieldcat ASSIGNING <lfs_fcat>.

    CASE <lfs_fcat>-fieldname.
      WHEN 'MATNR'.
        <lfs_fcat>-key = 'X'.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

  d_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
    i_callback_program                = d_repid
    i_callback_user_command           = 'F_USER_COMMAND'
*    i_background_id                   = 'ALV_BACKGROUND'
    is_layout                         = x_layout
    it_fieldcat                       = t_fieldcat[]
    it_sort                           = t_sort[]
    i_save                            = 'A'
*   IS_VARIANT                        =
    is_print                          = x_print
    it_events                         = t_events[]
    it_event_exit                     = t_event_exit[]
   TABLES
    t_outtab                          = t_report[]
   EXCEPTIONS
    program_error                     = 1
    OTHERS                            = 2.

ENDFORM.                    " f_print_report1


*&---------------------------------------------------------------------*
*&      Form  f_user_command
*&---------------------------------------------------------------------*
*       Dynamic sub routine activated on user double click on ALV List
*----------------------------------------------------------------------*
FORM f_user_command USING f_ucomm     TYPE sy-ucomm         "#EC CALLED
                          i_selfield  TYPE slis_selfield.

  CHECK f_ucomm = '&IC1'.

  CLEAR wa_report.
  READ TABLE t_report
        INTO wa_report
       INDEX i_selfield-tabindex.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  REFRESH: t_bdcdata, t_messtab.
  PERFORM f_call_ckm3n USING wa_report.

ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_call_ckm3n
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REPORT   text
*----------------------------------------------------------------------*
FORM f_call_ckm3n USING p_report TYPE ty_report.
  DATA: lv_matnr TYPE  ckmlhd-matnr,
        lv_bwkey TYPE  ckmlhd-bwkey,
        lv_bwtar TYPE  ckmlhd-bwtar,
        lv_vbeln TYPE  ckmlhd-vbeln,
        lv_posnr TYPE  ckmlhd-posnr,
        lv_pspnr TYPE  ckmlhd-pspnr,
        lv_bdatj TYPE  ckmlpp-bdatj,
        lv_poper TYPE  ckmlpp-poper,
        lv_curtp TYPE  ckmlcr-curtp,
        lv_run_id TYPE  ckml_run_id.

  lv_matnr = p_report-matnr.
  lv_bwkey = p_report-bwkey.
  lv_bwtar = p_report-bwtar.
  lv_vbeln = p_report-vbeln.
  lv_posnr = p_report-posnr.
  lv_poper = p_monat.
  lv_bdatj = p_gjahr.
  lv_curtp = '10'.

  CALL FUNCTION 'CKM8N_ML_DATA_DISPLAY'
    EXPORTING
      i_matnr = lv_matnr
      i_bwkey = lv_bwkey
      i_bwtar = lv_bwtar
      i_vbeln = lv_vbeln
      i_posnr = lv_posnr
      i_pspnr = lv_pspnr
      i_bdatj = lv_bdatj
      i_poper = lv_poper
      i_curtp = lv_curtp.

ENDFORM.                    "f_call_ckm3n



*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR t_bdcdata.
  t_bdcdata-program  = program.
  t_bdcdata-dynpro   = dynpro.
  t_bdcdata-dynbegin = 'X'.
  APPEND t_bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF NOT fval IS INITIAL.
    CLEAR t_bdcdata.
    t_bdcdata-fnam = fnam.
    t_bdcdata-fval = fval.
    APPEND t_bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_fieldcat .
  REFRESH: t_fieldcat.

  PERFORM f_fieldcatg USING 'T_REPORT':
    'MATNR' 'MBEW' 'MATNR' '' '18' 'Material'
       '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '30' 'Description'
       '' '' '' '' '' '' '' '',
    'MATKL' 'MARA' 'MATKL' '' '' ''
       '' '' '' '' '' '' '' '',
    'MVGR1' 'MVKE' 'MVGR1' '' '' ''
       '' '' '' '' '' '' '' '',
    'PRDHA' 'MARA' 'PRDHA' '' '' ''
       '' '' '' '' '' '' '' '',
    'EAN11' 'MARA' 'EAN11' '' '' ''
       '' '' '' '' '' '' '' '',
    'MTART' 'MARA' 'MTART' '' '6' 'M Type'
       '' '' '' '' '' '' '' '',
    'BWKEY' 'CKMLHD' 'BWKEY' '' '10' 'Val. Area'
       '' '' '' '' '' '' '' '',
*    'BWTAR' 'CKMLHD' 'BWTAR' '' '10' 'Val. Type'
*       '' '' '' '' '' '' '' '',
*    'VBELN' 'CKMLHD' 'VBELN' '' '10' 'Sales Order'
*       '' '' '' '' '' '' '' '',
*    'POSNR' 'CKMLHD' 'POSNR' '' '6' 'SO Item'
*       '' '' '' '' '' '' '' '',
    'BKLAS' 'CKMLHD' 'BKLAS' '' '10' 'Val. Class'
       '' '' '' '' '' '' '' '',
    'BKBEZ' 'T025T' 'BKBEZ' '' '25' 'Description'
       '' '' '' '' '' '' '' '',
    'MEINS' 'MARA' 'MEINS' '' '4' 'UoM'
       '' '' '' '' '' '' '' '',
    'BSTMI' 'MARC' 'BSTMI' '' '' ''
       '' '' '' '' '' '' '' '',
    'BSTMA' 'MARC' 'BSTMA' '' '' ''
       '' '' '' '' '' '' '' '',
    'DISPO' 'MARC' 'DISPO' '' '' ''
       '' '' '' '' '' '' '' '',
    'WAERS' 'MBEW' 'WAERS' '' '4' 'Currency'
       '' '' '' '' '' '' '' '',

    'ABKUMO' 'CKMLPP' 'ABKUMO' '' '15' 'Beg Inv Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'ABSALK3' 'CKMLCR' 'ABSALK3' '' '20' 'Beg Inv Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ABPRD_MO' 'CKMLCR' 'ABPRD_MO' '' '15' ' Beg Inv Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL1' 'CKMLCR' 'ABSALK3' '' '20' 'Beg Inv Amt Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'SALK3' 'MLCD' 'SALK3' '' '15' 'Price Change'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_RTOT' 'MLCD' 'LBKUM' '' '15' 'Total Rcpt Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_RTOT' 'MLCD' 'SALK3' '' '20' 'Total Rcpt Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_RTOT' 'MLCD' 'ESTPRD' '' '15' 'Total Rcpt Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL2' 'MLCD' 'SALK3' '' '20' 'Total Rcpt Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_CTOT' 'MLCD' 'LBKUM' '' '15' 'Total Cons Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_CTOT' 'MLCD' 'SALK3' '' '20' 'Total Cons Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_CTOT' 'MLCD' 'ESTPRD' '' '15' 'Total Cons Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL3' 'MLCD' 'SALK3' '' '20' 'Total Cons Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_BF' 'MLCD' 'LBKUM' '' '15' 'Rcpt Prod Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_BF' 'MLCD' 'SALK3' '' '20' 'Rcpt Prod Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_BF' 'MLCD' 'ESTPRD' '' '15' 'Rcpt Prod Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL4' 'MLCD' 'SALK3' '' '20' 'Rcpt Prod Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_BL' 'MLCD' 'LBKUM' '' '15' 'Rcpt SubCont Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_BL' 'MLCD' 'SALK3' '' '20' 'Rcpt SubCont Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_BL' 'MLCD' 'ESTPRD' '' '15' 'Rcpt SubCont Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL15' 'MLCD' 'SALK3' '' '20' 'Rcpt SubCont Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_BPLUS' 'MLCD' 'LBKUM' '' '15' 'Rcpt Proc Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_BPLUS' 'MLCD' 'SALK3' '' '20' 'Rcpt Proc Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_BPLUS' 'MLCD' 'ESTPRD' '' '15' 'Rcpt Proc Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL5' 'MLCD' 'SALK3' '' '20' 'Rcpt Proc Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_BB' 'MLCD' 'LBKUM' '' '15' 'Rcpt PO Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_BB' 'MLCD' 'SALK3' '' '20' 'Rcpt PO Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_BB' 'MLCD' 'ESTPRD' '' '15' 'Rcpt PO Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL6' 'MLCD' 'SALK3' '' '20' 'Rcpt PO Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_BU' 'MLCD' 'LBKUM' '' '15' 'Rcpt STO Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_BU' 'MLCD' 'SALK3' '' '20' 'Rcpt STO Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_BU' 'MLCD' 'ESTPRD' '' '15' 'Rcpt STO Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_BUBM' 'MLCD' 'LBKUM' '' '15' 'Rcpt TP Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_BUBM' 'MLCD' 'SALK3' '' '20' 'Rcpt TP Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_BUBM' 'MLCD' 'ESTPRD' '' '15' 'Rcpt TP Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_BUBS' 'MLCD' 'LBKUM' '' '15' 'Rcpt SO Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_BUBS' 'MLCD' 'SALK3' '' '20' 'Rcpt SO Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_BUBS' 'MLCD' 'ESTPRD' '' '15' 'Rcpt SO Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL7' 'MLCD' 'SALK3' '' '20' 'Rcpt SO Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VPLUS' 'MLCD' 'LBKUM' '' '15' 'Cons Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_VPLUS' 'MLCD' 'SALK3' '' '20' 'Cons Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VPLUS' 'MLCD' 'ESTPRD' '' '15' 'Cons Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL8' 'MLCD' 'SALK3' '' '20' 'Cons Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VEAU' 'MLCD' 'LBKUM' 'X' '15' 'Cons SLO Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_VEAU' 'MLCD' 'SALK3' 'X' '20' 'Cons SLO Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VEAU' 'MLCD' 'ESTPRD' 'X' '15' 'Cons SLO Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VF' 'MLCD' 'LBKUM' '' '15' 'Cons Prod Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_VF' 'MLCD' 'SALK3' '' '20' 'Cons Prod Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VF' 'MLCD' 'ESTPRD' '' '15' 'Cons Prod Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL9' 'MLCD' 'SALK3' '' '20' 'Cons Prod Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VK' 'MLCD' 'LBKUM' '' '15' 'Cons Cctr Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',

    'SALK3_VK' 'MLCD' 'SALK3' '' '20' 'Cons Cctr Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VK' 'MLCD' 'ESTPRD' '' '15' 'Cons Cctr Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL10' 'MLCD' 'SALK3' '' '20' 'Cons Cctr Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VU' 'MLCD' 'LBKUM' '' '15' 'Cons STO Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_VU' 'MLCD' 'SALK3' '' '20' 'Cons STO Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VU' 'MLCD' 'ESTPRD' '' '15' 'Cons STO Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VUBM' 'MLCD' 'LBKUM' '' '15' 'Cons TP Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
    'SALK3_VUBM' 'MLCD' 'SALK3' '' '20' 'Cons TP Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VUBM' 'MLCD' 'ESTPRD' '' '15' 'Cons TP Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VUBS' 'MLCD' 'LBKUM' '' '15' 'Cons SO Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',

    'SALK3_VUBS' 'MLCD' 'SALK3' '' '20' 'Cons SO Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VUBS' 'MLCD' 'ESTPRD' '' '15' 'Cons SO Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL11' 'MLCD' 'SALK3' '' '20' 'Cons SO Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_VW' 'MLCD' 'LBKUM' '' '15' 'Cons WIP Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',

    'SALK3_VW' 'MLCD' 'SALK3' '' '20' 'Cons WIP Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_VW' 'MLCD' 'ESTPRD' '' '15' 'Cons WIP Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL12' 'MLCD' 'SALK3' '' '20' 'Cons WIP Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

*    'LBKUM_NC' 'MLCD' 'LBKUM' '' '15' 'Not Alloc Qty'
*       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
*    'SALK3_NC' 'MLCD' 'SALK3' '' '20' 'Not Alloc Amount'
*       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
*    'ESTPRD_NC' 'MLCD' 'ESTPRD' '' '15' 'Not Alloc Diff'
*       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
*
*    'LBKUM_NV' 'MLCD' 'LBKUM' '' '15' 'Not Distrib Qty'
*       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
*    'SALK3_NV' 'MLCD' 'SALK3' '' '20' 'Not Distrib Amount'
*       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
*    'ESTPRD_NV' 'MLCD' 'ESTPRD' '' '15' 'Not Distrib Diff'
*       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL13' 'MLCD' 'SALK3' '' '20' 'Not Distrib Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'LBKUM_END' 'MLCD' 'LBKUM' '' '15' 'End Inventory Qty'
       'X' '' '0' '' '' 'T_REPORT' 'MEINS' '',
"Hide Ending Inventory Amount and Ending Inventory Difference
"Display Ending Amount 2.
    'SALK3_END' 'MLCD' 'SALK3' 'X' '20' 'End Inventory Amount'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_END' 'MLCD' 'ESTPRD' 'X' '15' 'End Inventory Diff'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'ESTPRD_END2' 'MLCD' 'ESTPRD' '' '15' 'Ending Amount 2'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',
    'TOTAL14' 'MLCD' 'SALK3' 'X' '20' 'End Inventory Act'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'PVPRS' 'CKMLCR' 'PVPRS' '' '20' 'Periodic Unit Price'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'STPRS' 'MBEW' 'STPRS' '' '20' 'Standard Price'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'VERPR' 'MBEW' 'VERPR' '' '20' 'Per Unit Price'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'PEINH' 'MBEW' 'PEINH' '' '20' 'Price Unit'
       'X' '' '0' 'T_REPORT' 'WAERS' '' '' '',

    'STDACT_PERCEN' '' '' '' '20' 'Std vs Act(%)'
       '' '' '' 'T_REPORT' '' '' '' ''.

ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers_t)
                          value(fu_waers_f)
                          value(fu_meins_t)
                          value(fu_meins_f)
                          value(fu_checkbox).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.

  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-ctabname      = fu_waers_t.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-qtabname      = fu_meins_t.
  ld_fieldcat-checkbox      = fu_checkbox.

  APPEND ld_fieldcat TO t_fieldcat.
ENDFORM.                    " F_FIELDCATG


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  x_layout-zebra              = 'X'.
*  x_layout-colwidth_optimize  = 'X'.
*  x_layout-no_colhead = 'X' .
ENDFORM.                    " F_BUILD_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort.

*  CLEAR t_sort.
*  t_sort-fieldname = 'MATNR'.
*  t_sort-up        = 'X'.
*  APPEND t_sort.
*
*  CLEAR t_sort.
*  t_sort-fieldname = 'BWKEY'.
*  t_sort-up        = 'X'.
*  APPEND t_sort.
*
*  CLEAR t_sort.
*  t_sort-fieldname = 'BKLAS'.
*  t_sort-up        = 'X'.
*  APPEND t_sort.

ENDFORM.                    " F_BUILD_SORT


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_events .
  REFRESH: t_events.

  CLEAR t_events.
  t_events-name = slis_ev_user_command.
  t_events-form = 'F_USER_COMMAND'.
  APPEND t_events.

  CLEAR t_events.
  t_events-name = slis_ev_pf_status_set.
  t_events-form = 'F_PF_STATUS_SET'.
  APPEND t_events.

  CLEAR t_events.
  t_events-name = slis_ev_top_of_page.
  t_events-form = 'F_TOP_OF_PAGE'.
  APPEND t_events.

*  CLEAR t_events.
*  t_events-name = slis_ev_end_of_page.
*  t_events-form = 'F_END_OF_PAGE'.
*  APPEND t_events.
ENDFORM.                    " F_BUILD_EVENTS


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT
*&---------------------------------------------------------------------*
FORM f_build_event_exit .
*  clear t_event_exit.
*  t_event_exit-ucomm = '&OUP'.
*  t_event_exit-after = 'X'.
*  append t_event_exit.
ENDFORM.                    " F_BUILD_EVENT_EXIT


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT
*&---------------------------------------------------------------------*
FORM f_build_print .

  x_print-no_print_listinfos = 'X'.
  x_print-no_print_selinfos  = 'X'.
  x_print-no_coverpage       = 'X'.
  x_print-no_print_hierseq_item = 'X'.

ENDFORM.                    " F_BUILD_PRINT


*&---------------------------------------------------------------------*
*&      Form  f_pf_status_set
*&---------------------------------------------------------------------*
FORM f_pf_status_set USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'ALVLIST'.

ENDFORM.                    " f_pf_status_set


*&---------------------------------------------------------------------*
*&      Form  F_top_of_page
*&---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA : lt_info TYPE slis_t_listheader WITH HEADER LINE,
         l_monat(3) TYPE c.

  l_monat = p_monat.
  SHIFT l_monat LEFT DELETING LEADING '0'.

  CLEAR lt_info.
  lt_info-typ  = 'H'.
  lt_info-info = 'Material Ledger Summary Report'.
  APPEND lt_info.

  CLEAR lt_info.
  lt_info-typ  = 'S'.
  lt_info-key  = 'Period      : '.
  lt_info-info = l_monat.
  APPEND lt_info.

  CLEAR lt_info.
  lt_info-typ  = 'S'.
  lt_info-key  = 'Fiscal Year : '.
  lt_info-info = p_gjahr.
  APPEND lt_info.

  CLEAR lt_info.
  lt_info-typ  = 'S'.
  lt_info-key  = 'User        : '.
  lt_info-info = sy-uname.
  APPEND lt_info.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_info[].

ENDFORM.                    " F_top_of_page


*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1
                         fu_text2.

  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.

ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_GET_PC_PCML_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KALNR    Cost Estimate Number
*      -->P_MONAT    Period
*      -->P_GJAHR    Year
*      -->PT_OT_DOCS PCML and PC documents
*----------------------------------------------------------------------*
FORM f_get_pc_pcml_data  USING    p_kalnr TYPE ckmlhd-kalnr
                                  p_monat TYPE ckmlpp-poper
                                  p_gjahr TYPE ckmlpp-bdatj
                         CHANGING pt_ot_docs TYPE ty_tt_ot_document.

  CLEAR: pt_ot_docs[].

  DATA: lt_ot_docs TYPE ckmd_t_document_report.

  CALL FUNCTION 'CKM8N_DOCUMENT_REPORT'
    EXPORTING
      i_kalnr              = p_kalnr
      i_bdatj              = p_gjahr
      i_poper              = p_monat
      i_only_not_mlcd_docs = 'X'
    TABLES
      ot_docs              = lt_ot_docs
    EXCEPTIONS
      no_document_found    = 1
      no_data_found        = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.

  ENDIF.

  pt_ot_docs = lt_ot_docs[].
  DELETE pt_ot_docs WHERE curtp NE '10'.

ENDFORM.                    " F_GET_PC_PCML_DATA
